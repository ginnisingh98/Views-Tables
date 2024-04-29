--------------------------------------------------------
--  DDL for Package Body CN_FORMULA_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_FORMULA_GEN_PKG" AS
-- $Header: cnfmgenb.pls 120.19.12010000.4 2009/10/23 08:50:48 rajukum ship $

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_FORMULA_GEN_PKG';

TYPE str_tbl_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE id_tbl_type  IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
TYPE commission_clmns_tbl_type  IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;

-- following type def added for Formula Perf 11.5.10 Enhancments
TYPE exp_tbl_clmn_names_type IS record
                             (exp_type_name     VARCHAR2(3),
                              calc_sql_exp_id   cn_calc_sql_exps.calc_sql_exp_id%TYPE,
                              table_alias       cn_objects.name%TYPE,
                              table_name        cn_objects.name%type,
                              table_object_id   cn_objects.object_id%TYPE,
                              schema            cn_objects.schema%TYPE,
                              column_object_id  cn_objects.object_id%TYPE,
                              column_alias      cn_objects.name%TYPE,
                              column_name       cn_objects.schema%TYPE,
                              variable_name     VARCHAR2(61),
                              alias_added	BOOLEAN
                              );



TYPE exp_tbl_names_type IS record
                             (exp_type_name     VARCHAR2(3),
                              calc_sql_exp_id   cn_calc_sql_exps.calc_sql_exp_id%TYPE,
                              table_alias       cn_objects.name%TYPE,
                              table_name        cn_objects.name%TYPE,
                              table_object_id   cn_objects.object_id%TYPE,
                              schema            cn_objects.schema%TYPE,
                              variable_name     VARCHAR2(61),
                              column_name_list  VARCHAR2(32000)
                              );

TYPE comm_tbl_clmn_names_type IS record
                             (table_alias       cn_objects.name%TYPE,
                              table_name        cn_objects.name%TYPE,
                              column_name       cn_objects.schema%TYPE,
                              column_alias      cn_objects.name%TYPE);




TYPE exp_tbl_names_tbl_type IS TABLE OF exp_tbl_names_type INDEX BY BINARY_INTEGER;

TYPE exp_tbl_dtls_tbl_type IS TABLE OF exp_tbl_clmn_names_type INDEX BY BINARY_INTEGER;

TYPE parsed_elmnts_tbl_type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

TYPE exp_other_tabused_tbl_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

TYPE comm_tbl_clmn_nms_tbl_type IS TABLE OF comm_tbl_clmn_names_type INDEX BY BINARY_INTEGER;

g_org_id                    cn_calc_formulas.org_id%TYPE;
g_formula_id                cn_calc_formulas.calc_formula_id%TYPE;
g_trx_group_code            cn_calc_formulas.trx_group_code%TYPE;
g_itd_flag                  cn_calc_formulas.itd_flag%TYPE;
g_cumulative_flag           cn_calc_formulas.cumulative_flag%TYPE;
g_perf_measure_id           cn_calc_formulas.perf_measure_id%TYPE;
g_split_flag                cn_calc_formulas.split_flag%TYPE;
g_number_dim                cn_calc_formulas.number_dim%TYPE;
g_formula_type              cn_calc_formulas.formula_type%TYPE;
g_rollover_flag             VARCHAR2(1) := 'N';
g_cumulative_input_no       NUMBER := 1;

g_pe_reference_tbl          str_tbl_type;
g_pe_id_tbl                 id_tbl_type;
g_no_trx_flag               BOOLEAN := FALSE;

g_rate_flag                 BOOLEAN := FALSE;
g_external_table_id         NUMBER;

g_pq_target_flag            BOOLEAN := FALSE;
g_pq_payment_flag           BOOLEAN := FALSE;
g_spq_target_flag           BOOLEAN := FALSE;
g_spq_payment_flag          BOOLEAN := FALSE;

-- following global variables added for Formula Perf  11.5.10 Enhancments

-- store expression table column details
g_exp_tbl_dtls_tbl          exp_tbl_dtls_tbl_type;

-- stores expression table xref details
g_tbl_names_tbl             exp_tbl_names_tbl_type;

-- stores a list of unique table names referred to by this formula
g_uniq_tbl_names_tbl        exp_tbl_names_tbl_type;

--table to indicate whether a expression used anyother table
-- other than the standard table
g_other_tabused_tbl         exp_other_tabused_tbl_type;

--table to indicate whether a expression uses any non pl/sql function like decode
g_non_plsql_func_used_tbl   exp_other_tabused_tbl_type;

--table to hold column names of commission header and lines
g_comm_tbl_clmn_nms_tbl     comm_tbl_clmn_nms_tbl_type;

g_ch_flag                   BOOLEAN := FALSE;

--sequence of the input expression which matches with the perf expression
g_perf_input_expr_seq       NUMBER := 0;

-- +======================================================================+
-- +                   Procedure Parse                                    +
-- + Procedure Added for 11.5.10 Peformance Enhancment                    +
-- + Parse breaks string delimited by '|' into member elements and        +
-- + returns the elements in an array.                                    +
-- +======================================================================+

PROCEDURE parse( x_strtosplit       IN VARCHAR2 ,
                 x_parsed_elmts_tbl OUT NOCOPY parsed_elmnts_tbl_type) IS
    bigstr   varchar2(15000) := x_strtosplit;
    smlstr   varchar2(15000);
    idxval   number;
    counter  number := 1;
BEGIN
    LOOP
       idxval:= NVL(instr( bigstr, '|' ),0);
       IF idxval = 0 THEN
          smlstr:= bigstr;
       ELSE
          smlstr:= substr( bigstr, 1, idxval - 1 );
          bigstr:= substr( bigstr, idxval + 1 );
       END IF;
       x_parsed_elmts_tbl(counter) := smlstr;
       counter := counter +1;

       IF idxval = 0 THEN
          EXIT;
       END IF ;
    END LOOP;
exception
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.parse.exception',
         	          sqlerrm);
    end if;
    raise;
END parse;


-- +======================================================================+
-- +                   Procedure init_tab_column_list                     +
-- + Procedure Added for 11.5.10 Peformance Enhancment                    +
-- + Process input,output,perf expressions                                +
-- + populate the table names  columns used into g_exp_tbl_dtls_tbl       +
-- + populate the uniq table names   into g_uniq_tbl_names_tbl            +
-- + populate the table names   used into g_tbl_names_tbl                 +
-- +======================================================================+
PROCEDURE init_tab_column_list (p_formula_id  IN NUMBER) IS
CURSOR formula_expressions IS
SELECT formula_exps.exp_type_name exp_type_name,
       dbms_lob.substr(piped_sql_from) sql_from,
       dbms_lob.substr(piped_sql_select) sql_select,
       cse.CALC_SQL_EXP_ID CALC_SQL_EXP_ID
FROM cn_calc_sql_exps_all cse,(SELECT 'PRF' exp_type_name,perf_measure_id exp_id
                                  FROM cn_calc_formulas_all
                                  WHERE calc_formula_id = p_formula_id
                                    AND org_id = g_org_id
                                  UNION ALL
                                  SELECT 'OUT' exp_type_name,output_exp_id exp_id
                                  FROM cn_calc_formulas_all
                                  WHERE calc_formula_id = p_formula_id
                                    AND org_id = g_org_id
                                  UNION ALL
                                  SELECT 'INP' exp_type_name,calc_sql_exp_id exp_id
                                  FROM cn_formula_inputs_all
                                  WHERE calc_formula_id = p_formula_id
                                    AND org_id = g_org_id) formula_exps
WHERE cse.CALC_SQL_EXP_ID = formula_exps.exp_id;

-- get list of tables which can be used for expression building
CURSOR osc_elements IS
    SELECT user_name,schema, name, alias, object_id
      FROM cn_objects_all
     WHERE calc_eligible_flag = 'Y'
       AND object_type in ('TBL', 'VIEW')
       AND user_name is not null
       AND object_id < 0
       AND name like 'CN%'
       AND org_id = g_org_id
   ORDER BY user_name;

-- get list of columns which can be used in expression building
CURSOR table_columns(p_table_id number) is
    SELECT user_name, name ,object_id ,alias
      FROM cn_objects_all
     WHERE table_id = p_table_id
       AND calc_formula_flag = 'Y'
       AND object_type = 'COL'
       AND org_id = g_org_id
  ORDER BY user_name;

--get alias of commlines table
CURSOR comm_line_alias is
    SELECT alias
      FROM cn_objects_all
     WHERE name = 'CN_COMMISSION_LINES'
       AND object_type in ('TBL', 'VIEW')
       AND org_id = g_org_id;


l_parsed_elmnts_tbl    parsed_elmnts_tbl_type;
l_parsed_clmn_tbl      parsed_elmnts_tbl_type;
l_variable_name        VARCHAR2(70);
counter_1              NUMBER(10) := 1;
counter_2              NUMBER(10) := 1;
counter_3              NUMBER(10) := 1;
counter_4              NUMBER(10) := 1;
l_table_object_id      cn_objects.object_id%type;
l_comm_tbl_clmn_names_tbl comm_tbl_clmn_names_type;
l_comm_line_alias      VARCHAR2(100);

-- declare null variables for intialization
-- fix for bug 3203673
l_null_exp_tbl_dtls_tbl          exp_tbl_dtls_tbl_type;
l_null_tbl_names_tbl             exp_tbl_names_tbl_type;
l_null_uniq_tbl_names_tbl        exp_tbl_names_tbl_type;
l_null_other_tabused_tbl         exp_other_tabused_tbl_type;
l_null_non_plsql_func_used_tbl   exp_other_tabused_tbl_type;
l_null_comm_tbl_clmn_nms_tbl     comm_tbl_clmn_nms_tbl_type;


-- Add all the columns of commission lines and header which has to be passed to
-- cn_formula_common_pkg.update_trx
g_comm_clmns_names  VARCHAR2(32000) :=
'COMMISSION_LINE_ID|COMMISSION_HEADER_ID|CREDITED_SALESREP_ID|SRP_PLAN_ASSIGN_ID|QUOTA_ID|CREDIT_TYPE_ID|PROCESSED_DATE|'||
'PROCESSED_PERIOD_ID|PAY_PERIOD_ID|COMMISSION_AMOUNT|COMMISSION_RATE|RATE_TIER_ID|TIER_SPLIT|INPUT_ACHIEVED|' ||
'OUTPUT_ACHIEVED|PERF_ACHIEVED|POSTING_STATUS|PENDING_STATUS|CREATED_DURING|TRX_TYPE|ERROR_REASON|STATUS' ;

BEGIN
-- intialize all the global variables so that multiple calls
-- from same session does not give unexpected results.
-- fix for bug 3203673
g_exp_tbl_dtls_tbl        := l_null_exp_tbl_dtls_tbl;
g_tbl_names_tbl           := l_null_tbl_names_tbl;
g_uniq_tbl_names_tbl      := l_null_uniq_tbl_names_tbl;
g_other_tabused_tbl       := l_null_other_tabused_tbl;
g_non_plsql_func_used_tbl := l_null_non_plsql_func_used_tbl;
g_comm_tbl_clmn_nms_tbl   := l_null_comm_tbl_clmn_nms_tbl;
g_ch_flag                 := FALSE;
g_perf_input_expr_seq     := 0;

OPEN comm_line_alias;
FETCH comm_line_alias INTO l_comm_line_alias;
CLOSE comm_line_alias;

-- convert all the columns which was intialized into the string
-- g_comm_clmns_names into a pl/sql table and then add it to
-- l_comm_tbl_clmn_names_tbl
parse(g_comm_clmns_names,l_parsed_elmnts_tbl);
FOR i in 1..l_parsed_elmnts_tbl.COUNT LOOP
  l_comm_tbl_clmn_names_tbl.table_name  := 'CN_COMMISSION_LINES';
  l_comm_tbl_clmn_names_tbl.table_alias := l_comm_line_alias;
  l_comm_tbl_clmn_names_tbl.column_name := l_parsed_elmnts_tbl(i);

  g_comm_tbl_clmn_nms_tbl(counter_4) := l_comm_tbl_clmn_names_tbl;
  counter_4 := counter_4 +1;
END LOOP;

FOR expression_rec IN  formula_expressions LOOP
    counter_1 := 1;
    -- get list of tables used in the expression
    parse(expression_rec.sql_from,l_parsed_elmnts_tbl);
    FOR table_rec IN osc_elements LOOP
        --for every table in the list of seeded tables check whether it is used in the
        --expression if yes populate details into g_tbl_names_tbl ,g_uniq_tbl_names_tbl
        --and g_exp_tbl_dtls_tbl plsql table.
        FOR i in 1..l_parsed_elmnts_tbl.COUNT LOOP
           IF INSTR(l_parsed_elmnts_tbl(i),table_rec.name ||' '||table_rec.alias) > 0 THEN
              g_tbl_names_tbl(counter_1).calc_sql_exp_id := expression_rec.calc_sql_exp_id;
              g_tbl_names_tbl(counter_1).exp_type_name   := expression_rec.exp_type_name;
              g_tbl_names_tbl(counter_1).table_name      := table_rec.name;
              g_tbl_names_tbl(counter_1).table_object_id := table_rec.object_id;
              g_tbl_names_tbl(counter_1).schema          := table_rec.schema;
              g_tbl_names_tbl(counter_1).table_alias     := table_rec.alias;

              --if commission header is used set the g_ch_flag to true.
              IF LOWER(table_rec.name) = LOWER('CN_COMMISSION_HEADERS') THEN
                 g_ch_flag  := TRUE;
              END IF;


              IF LENGTH(REPLACE(table_rec.name,'_',NULL)) > 24 THEN
                 l_variable_name := 'g_'||lower(substr(REPLACE(table_rec.name,'_',NULL),1,24))||'_rec';
              ELSE
                 l_variable_name := 'g_'||lower(REPLACE(table_rec.name,'_',NULL)) ||'_rec';
              END IF;
              g_tbl_names_tbl(counter_1).variable_name     := l_variable_name;


              IF NOT g_uniq_tbl_names_tbl.EXISTS(table_rec.object_id) THEN
                 g_uniq_tbl_names_tbl(table_rec.object_id).table_name      := table_rec.name;
                 g_uniq_tbl_names_tbl(table_rec.object_id).schema          := table_rec.schema;
                 g_uniq_tbl_names_tbl(table_rec.object_id).table_alias     := table_rec.alias;
                 g_uniq_tbl_names_tbl(table_rec.object_id).variable_name   := l_variable_name;
              END IF;
              --get list of columns used in this tables and populate l_parsed_clmn_tbl
              parse(expression_rec.sql_select,l_parsed_clmn_tbl);
              FOR c in 1..l_parsed_clmn_tbl.COUNT LOOP
                  FOR column_rec IN table_columns(table_rec.object_id) LOOP
                     IF l_parsed_clmn_tbl(c) = table_rec.alias||'.'||column_rec.name or
                        instr(l_parsed_clmn_tbl(c), table_rec.alias|| '.'||column_rec.name||',') > 0 or
                        instr(l_parsed_clmn_tbl(c), table_rec.alias|| '.'||column_rec.name||')') > 0 or
                        instr(l_parsed_clmn_tbl(c), table_rec.alias|| '.'||column_rec.name||'+') > 0 or
                        instr(l_parsed_clmn_tbl(c), table_rec.alias|| '.'||column_rec.name||'-') > 0 or
                        instr(l_parsed_clmn_tbl(c), table_rec.alias|| '.'||column_rec.name||'*') > 0 or
                        instr(l_parsed_clmn_tbl(c), table_rec.alias|| '.'||column_rec.name||'/') > 0
                     THEN
                        g_exp_tbl_dtls_tbl(counter_2).exp_type_name    :=  expression_rec.exp_type_name;
                        g_exp_tbl_dtls_tbl(counter_2).CALC_SQL_EXP_ID  :=  expression_rec.CALC_SQL_EXP_ID;
                        g_exp_tbl_dtls_tbl(counter_2).table_alias      :=  table_rec.alias;
                        g_exp_tbl_dtls_tbl(counter_2).table_name       :=  table_rec.name;
                        g_exp_tbl_dtls_tbl(counter_2).table_object_id  :=  table_rec.object_id;
                        g_exp_tbl_dtls_tbl(counter_2).schema           :=  table_rec.schema;
                        g_exp_tbl_dtls_tbl(counter_2).column_object_id :=  column_rec.object_id;
                        g_exp_tbl_dtls_tbl(counter_2).column_alias     :=  column_rec.alias  ;
                        g_exp_tbl_dtls_tbl(counter_2).column_name      :=  column_rec.name;

                        IF LENGTH(REPLACE(table_rec.alias,'_',NULL)) > 24 THEN
                           l_variable_name := 'g_'||lower(substr(REPLACE(table_rec.name,'_',NULL),1,24))
                                                        ||'_rec.'||column_rec.name;
                        ELSE
                           l_variable_name := 'g_'||lower(REPLACE(table_rec.name,'_',NULL))
                                                        ||'_rec.'||column_rec.name;
                        END IF;

                        g_exp_tbl_dtls_tbl(counter_2).variable_name      :=   l_variable_name;
                        counter_2 := counter_2 + 1;

                        -- build a comma seperated list of column names for this table
                        IF NVL(INSTR(g_uniq_tbl_names_tbl(table_rec.object_id).column_name_list||',',
                                table_rec.alias||'.'||column_rec.name||','),0) = 0 THEN

                           IF NVL(length(g_uniq_tbl_names_tbl(table_rec.object_id).column_name_list),0) > 0         THEN
                              g_uniq_tbl_names_tbl(table_rec.object_id).column_name_list :=
                              g_uniq_tbl_names_tbl(table_rec.object_id).column_name_list ||',';
                           END IF ;
                           g_uniq_tbl_names_tbl(table_rec.object_id).column_name_list :=
                                  g_uniq_tbl_names_tbl(table_rec.object_id).column_name_list
                                  ||table_rec.alias||'.'||column_rec.name;
                        END IF;



                        -- if the column belongs to commission lines or header add it to
                        -- g_comm_tbl_clmn_nms_tbl plsql table
/*
                        IF(INSTR(table_rec.name,'CN_COMMISSION_HEADERS') >0 OR
                           INSTR(table_rec.name,'CN_COMMISSION_LINES') >0 ) AND
                           INSTR(g_comm_clmns_names||'|',column_rec.name||'|') = 0
                        THEN
*/
                        IF((INSTR(table_rec.name,'CN_COMMISSION_LINES') >0 OR
                            INSTR(table_rec.name,'CN_COMMISSION_HEADERS') >0) AND
                           INSTR(g_comm_clmns_names||'|',column_rec.name||'|') = 0)
                        THEN
                           l_comm_tbl_clmn_names_tbl.table_name  := table_rec.name;
                           l_comm_tbl_clmn_names_tbl.table_alias := table_rec.alias;
                           l_comm_tbl_clmn_names_tbl.column_name := column_rec.name;
			   l_comm_tbl_clmn_names_tbl.column_alias := null;
                           g_exp_tbl_dtls_tbl(counter_2 - 1).alias_added := false;

                           g_comm_tbl_clmn_nms_tbl(counter_4) := l_comm_tbl_clmn_names_tbl;

                           -- add it to the g_comm_clmns_names so that we can check whether it
                           -- is already added.
                           g_comm_clmns_names := g_comm_clmns_names ||'|'||column_rec.name;
                           counter_4 := counter_4 +1;
                        ELSIF (INSTR(table_rec.name,'CN_COMMISSION_HEADERS') >0 AND
                               INSTR(g_comm_clmns_names||'|',column_rec.name||'|') < 329)
                        THEN
                            g_exp_tbl_dtls_tbl(counter_2 - 1).alias_added := true;
                            IF (INSTR(g_comm_clmns_names||'|',table_rec.alias||'_'||column_rec.name||'|') = 0) THEN
                               l_comm_tbl_clmn_names_tbl.table_name  := table_rec.name;
                               l_comm_tbl_clmn_names_tbl.table_alias := table_rec.alias;
                               l_comm_tbl_clmn_names_tbl.column_name := column_rec.name;
                               l_comm_tbl_clmn_names_tbl.column_alias := table_rec.alias||'_'||column_rec.name;


                               g_comm_tbl_clmn_nms_tbl(counter_4) := l_comm_tbl_clmn_names_tbl;

                               -- add it to the g_comm_clmns_names so that we can check whether it
                               -- is already added.
                               g_comm_clmns_names := g_comm_clmns_names ||'|'||table_rec.alias||'_'||column_rec.name;
                               counter_4 := counter_4 +1;
                            END IF;
                        END IF;
                     END IF;
                  END LOOP;

              END LOOP;
              counter_1 := counter_1 + 1;
           END IF;

         END LOOP;

    END LOOP;

    --if no of tables parsed and added to the list is less then no of tables parsed
    --then some non standard table is used set the flag g_other_tabused_tbl to indicate this
    IF l_parsed_elmnts_tbl.COUNT > counter_1 THEN
        g_other_tabused_tbl(expression_rec.CALC_SQL_EXP_ID) := 'Y';
    ELSE
        IF NOT g_other_tabused_tbl.EXISTS(expression_rec.CALC_SQL_EXP_ID) THEN
            g_other_tabused_tbl(expression_rec.CALC_SQL_EXP_ID) := 'N';
        END IF;
    END IF;
    --if non plsql function is used set the flag to Y
    IF  INSTR(LOWER(expression_rec.sql_select),'decode(') >0 THEN
          IF NOT g_non_plsql_func_used_tbl.EXISTS(expression_rec.calc_sql_exp_id) THEN
                    g_non_plsql_func_used_tbl(expression_rec.calc_sql_exp_id) := 'Y';
                 END IF;
    ELSE
          IF NOT g_non_plsql_func_used_tbl.EXISTS(expression_rec.calc_sql_exp_id) THEN
                   g_non_plsql_func_used_tbl(expression_rec.calc_sql_exp_id) := 'N';
          END IF;
    END IF;
END LOOP;

exception
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.init_tab_column_list.exception',
         	          sqlerrm);
    end if;
    raise;
END init_tab_column_list;


-- return the smaller number if both <> 0.
PROCEDURE get_min ( p_min IN OUT NOCOPY number, p_max number) IS
BEGIN
   IF p_min =0 and p_max <> 0 THEN
      p_min := p_max;
    ELSIF p_min <> 0 and p_max <> 0 THEN
      IF p_min > p_max THEN
         p_min := p_max;
      END IF;
   END IF;
END;

-- lower a string except the sections that are contained in single quotes
function lower_str(p_str varchar2) return varchar2 is
  l_str  varchar2(8000) := p_str;
  l_pos1 pls_integer;
  l_pos2 pls_integer;
  x_str varchar2(8000) := '';
begin
  l_pos1 := instr(l_str, '''', 1);
  l_pos2 := instr(l_str, '''', l_pos1+1);
  while (l_pos1 > 0) loop
    x_str := x_str || lower(substr(l_str, 1, l_pos1)) || substr(l_str, l_pos1+1, l_pos2-l_pos1);
    l_str := substr(l_str, l_pos2+1);
    l_pos1 := instr(l_str, '''', 1);
    l_pos2 := instr(l_str, '''', l_pos1+1);
  end loop;
  x_str := x_str || lower(l_str);
  return x_str;
exception
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.lower_str.exception',
         	          sqlerrm);
    end if;
    raise;
end;

-- search the next occurence of delimiter '+ - * / ( ) ' in sql_select portion and return the position
FUNCTION search_delimiter_select ( p_input_str varchar2, p_start number)
  RETURN  number IS
     l_position_min         NUMBER ;
     l_position         NUMBER;
BEGIN
   l_position_min := instr( p_input_str, '*', p_start) ;
   l_position := instr(p_input_str, '-', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, '+', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, '/', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, '(', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, ')', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, ',', p_start);
   get_min(l_position_min, l_position);

   return l_position_min;
END;


-- search the next occurence of delimiter ', ' in sql_from portion and return the position
FUNCTION search_delimiter_from ( p_input_str varchar2, p_start  number) RETURN
  NUMBER IS
     l_position_min        number :=0;
     l_position          NUMBER;
BEGIN
   l_position := instr(p_input_str, ',', p_start);
   get_min(l_position_min, l_position);
   return l_position_min;
END;

-- search the next occurence of delimiter 'and ' in sql_where portion and return the position
FUNCTION search_delimiter_where ( p_input_str varchar2, p_start number)
  RETURN  number IS
     l_position_min        number :=0;
     l_position         NUMBER;
BEGIN
   l_position := instr(p_input_str, 'and', p_start);
   get_min(l_position_min, l_position);
   return l_position_min;
END;

-- search the next occurence of delimiter empty space in COMMENT and return the position
FUNCTION search_delimiter_comment ( p_input_str varchar2, p_start number)
  RETURN  number IS
     l_position_min        number :=0;
     l_position         NUMBER;
BEGIN
   l_position := instr(p_input_str, ' ', p_start);
   get_min(l_position_min, l_position);
   return l_position_min;
END search_delimiter_comment ;

-- split the long sql statement into pieces less than 80 characters and return the position
PROCEDURE split_long_sql ( body_code        IN OUT NOCOPY cn_utils.code_type,
                           p_input_str      VARCHAR2  ,
                           sql_type   VARCHAR2        )
  IS
     l_length NUMBER;    /* total length of input string */
     l_start  NUMBER;    /* the start position of current split */
     l_next   NUMBER;    /* position of next delimiter */
     l_next_prev NUMBER; /* position of previous delimiter */
     l_limit  NUMBER;    /* the upper boundary of current split */

     l_sql_segment_length NUMBER := 80;
BEGIN
   l_start := 1;
   l_limit := l_start + l_sql_segment_length;

   l_length := Length(p_input_str);
   l_next := l_start;
   l_next_prev := l_start;

   WHILE l_limit < l_length LOOP
      WHILE l_next < l_limit LOOP
         /* the postion of l_next delimiter is not beyong the upper boudaryyet  */
         l_next_prev := l_next;

         IF sql_type = 'SELECT' THEN
            l_next := search_delimiter_select(p_input_str, l_next_prev+1 );
          ELSIF sql_type = 'FROM' THEN
            l_next := search_delimiter_from(p_input_str, l_next_prev+1 );
          ELSIF sql_type = 'WHERE' THEN
            l_next := search_delimiter_where(p_input_str, l_next_prev+1 );
          ELSIF sql_type = 'COMMENT' THEN
            l_next := search_delimiter_comment(p_input_str, l_next_prev+1 );
         END IF;

         IF l_next = 0 THEN  /* no more delimiter */
            EXIT;
         END IF;
      END LOOP;

      IF sql_type = 'COMMENT' THEN
         cn_utils.appindcr(body_code, '-- ' || substr(p_input_str, l_start,
                           l_next_prev -  l_start) );
       ELSE
         cn_utils.appindcr(body_code, substr(p_input_str, l_start,
                                             l_next_prev - l_start));
      END IF;

      l_start := l_next_prev ;
      l_limit := l_start + l_sql_segment_length;

      IF l_next = 0 THEN  /* no more delimiter */
         EXIT;
      END IF;
   END LOOP;

   IF sql_type = 'COMMENT' THEN
      cn_utils.appindcr(body_code, '--' || substr(p_input_str, l_start,
                        l_length -  l_start  + 1));
    ELSE
      cn_utils.appindcr(body_code, substr(p_input_str, l_start,
                                          l_length - l_start  + 1));
   END IF;
END split_long_sql;

-- initialize the procedure boilerplate
PROCEDURE proc_init_boilerplate (code                IN OUT NOCOPY cn_utils.code_type,
                                 procedure_name                cn_obj_procedures_v.name%TYPE,
                                 description                cn_obj_procedures_v.description%TYPE)
  IS
     X_userid        VARCHAR2(20);
BEGIN
   SELECT user INTO X_userid FROM sys.dual;

   cn_utils.appendcr(code, '--');
   cn_utils.appendcr(code, '-- Procedure Name');
   cn_utils.appendcr(code, '--   ' || procedure_name);
   cn_utils.appendcr(code, '-- Purpose');
   split_long_sql(code, description, 'COMMENT');
   cn_utils.appendcr(code, '-- History');
   cn_utils.appendcr(code, '--   ' || SYSDATE || '          ' || X_userid || '     Created');
   cn_utils.appendcr(code, '--');
END proc_init_boilerplate;

-- initialize the procedure
PROCEDURE proc_init(procedure_name                cn_obj_procedures_v.name%TYPE,
                    description                cn_obj_procedures_v.description%TYPE,
                    parameter_list                cn_obj_procedures_v.parameter_list%TYPE,
                    procedure_type                cn_obj_procedures_v.procedure_type%TYPE,
                    return_type                cn_obj_procedures_v.return_type%TYPE,
                    package_id                cn_obj_procedures_v.package_id%TYPE,
                    repository_id                cn_obj_procedures_v.repository_id%TYPE,
                    spec_code        IN OUT NOCOPY cn_utils.code_type,
                    body_code        IN OUT NOCOPY cn_utils.code_type) IS
BEGIN
    -- Generate boilerplate comments
    proc_init_boilerplate(spec_code, procedure_name, description);
    proc_init_boilerplate(body_code, procedure_name, description);

    -- Generate procedure header and parameters in both spec and body
    IF (procedure_type = 'P') THEN
      IF (parameter_list IS NOT NULL) THEN
         split_long_sql(spec_code, 'PROCEDURE ' || procedure_name ||
                        ' (' || parameter_list || ')', 'FROM');
         split_long_sql(body_code, 'PROCEDURE ' || procedure_name ||
                        ' (' || parameter_list || ')', 'FROM');
      ELSE
         cn_utils.appendcr(spec_code, 'PROCEDURE ' || procedure_name);
         cn_utils.appendcr(body_code, 'PROCEDURE ' || procedure_name);
      END IF;
     ELSIF (procedure_type = 'F') THEN
       IF (parameter_list IS NOT NULL) THEN
          split_long_sql(spec_code, 'FUNCTION ' || procedure_name ||
                         ' (' || parameter_list || ')', 'FROM');
          split_long_sql(body_code, 'FUNCTION ' || procedure_name ||
                         ' (' || parameter_list || ')', 'FROM');
        ELSE
          cn_utils.appendcr(spec_code, 'FUNCTION ' || procedure_name);
          cn_utils.appendcr(body_code, 'FUNCTION ' || procedure_name);
       END IF;
    END IF;

    IF (procedure_type = 'F') THEN
      cn_utils.appendcr(spec_code, ' RETURN ' || return_type);
      cn_utils.appendcr(body_code, ' RETURN ' || return_type);
    END IF;

    cn_utils.appendcr(spec_code, ';');
    cn_utils.appendcr(spec_code);
    cn_utils.appendcr(body_code, ' IS');
END proc_init;

--   initialize global variables in this package
PROCEDURE generate_init(p_formula_id cn_calc_formulas.calc_formula_id%TYPE) IS
   i       pls_integer := 0;  -- index into PL/SQL tables
   b       pls_integer;       -- beginning position of an occurence of xxxxPE.
   l       pls_integer;       -- length of sql_select
   p1      pls_integer;       -- temporary position pointer
   p2      pls_integer;       -- temporary position pointer

   CURSOR exprs IS
      SELECT dbms_lob.substr(piped_sql_select) sql_select
        FROM cn_calc_sql_exps_all
        WHERE calc_sql_exp_id IN (SELECT perf_measure_id
                                  FROM cn_calc_formulas_all
                                  WHERE calc_formula_id = p_formula_id
                                    AND org_id = g_org_id
                                  UNION ALL
                                  SELECT output_exp_id
                                  FROM cn_calc_formulas_all
                                  WHERE calc_formula_id = p_formula_id
                                    AND org_id = g_org_id
                                  UNION ALL
                                  SELECT calc_sql_exp_id
                                  FROM cn_formula_inputs_all
                                  WHERE calc_formula_id = p_formula_id
                                    AND org_id = g_org_id);
   CURSOR exprs2 IS
      SELECT dbms_lob.substr(piped_sql_select) sql_select
        FROM cn_calc_sql_exps_all
        WHERE calc_sql_exp_id IN (SELECT output_exp_id
                                  FROM cn_calc_formulas_all
                                  WHERE calc_formula_id = p_formula_id
                                    AND org_id = g_org_id
                                  UNION ALL
                                  SELECT calc_sql_exp_id
                                  FROM cn_formula_inputs_all
                                  WHERE calc_formula_id = p_formula_id
                                    AND org_id = g_org_id);

   -- Added for 11.5.10 Performance Enhancments
   CURSOR perf_measure_input_seq_cur IS
      SELECT rate_dim_sequence
      FROM   cn_formula_inputs_all
      WHERE  calc_formula_id = p_formula_id
      AND    calc_sql_exp_id = g_perf_measure_id;
BEGIN
  SELECT calc_formula_id, trx_group_code, itd_flag, cumulative_flag, perf_measure_id, split_flag,
         number_dim, formula_type
    INTO g_formula_id, g_trx_group_code, g_itd_flag, g_cumulative_flag, g_perf_measure_id, g_split_flag,
         g_number_dim, g_formula_type
    FROM cn_calc_formulas_all
   WHERE calc_formula_id = p_formula_id
     AND org_id = g_org_id;

  g_pe_reference_tbl.delete;
  g_pe_id_tbl.delete;
  g_no_trx_flag := FALSE;
  g_cumulative_input_no := 1;
  g_rollover_flag := 'N';

  -- Added for 11.5.10 Performance Enhancments
  OPEN perf_measure_input_seq_cur;
  FETCH perf_measure_input_seq_cur INTO g_perf_input_expr_seq;
  CLOSE perf_measure_input_seq_cur;

  FOR expr IN exprs LOOP
     IF (instr(expr.sql_select, 'CSPQ.TOTAL_ROLLOVER', 1,1) > 0) THEN
        g_rollover_flag := 'Y';
     END IF;

     l := length(expr.sql_select);
     b := 1;

     LOOP
        b := instr(expr.sql_select, 'PE.', b, 1);

        IF (b = 0) THEN EXIT; END IF;
        IF not(substr(expr.sql_select, b-1, 1) between '0' and '9') THEN EXIT; END IF;

        p1 := instr(expr.sql_select, '(', (b-l), 1);
        p2 := instr(expr.sql_select, ')', b, 1);
        g_pe_reference_tbl(i) := substr(expr.sql_select, p1+1, p2-p1-1);

        FOR j IN 0..(i-1) LOOP
           IF (g_pe_reference_tbl(j) = g_pe_reference_tbl(i)) THEN
              g_pe_reference_tbl.DELETE(i);
              EXIT;
            ELSIF (j = (i-1)) THEN
              i := i + 1;
           END IF;
        END LOOP;

        IF (i = 0) THEN
           i := 1;
        END IF;
        b := b + 4;
     END LOOP;
  END LOOP;

  -- get ids
  IF (g_pe_reference_tbl.COUNT > 0) THEN
     FOR i IN g_pe_reference_tbl.first..g_pe_reference_tbl.last LOOP
        g_pe_id_tbl(i) := substr(g_pe_reference_tbl(i), 1, (instr(g_pe_reference_tbl(i), 'P', 1, 1) - 1));
     END LOOP;
  END IF;

  IF (g_formula_type = 'C' AND g_pe_reference_tbl.COUNT > 0) THEN
     g_no_trx_flag := TRUE;
     FOR expr IN exprs2 LOOP
        IF (instr(expr.sql_select,  'CL.', 1, 1) = 1 OR
            instr(expr.sql_select, '|CL.', 1, 1) > 0 OR
            instr(expr.sql_select, '(CL.', 1, 1) > 0 OR
            instr(expr.sql_select, '+CL.', 1, 1) > 0 OR
            instr(expr.sql_select, '-CL.', 1, 1) > 0 OR
            instr(expr.sql_select, '*CL.', 1, 1) > 0 OR
            instr(expr.sql_select, '/CL.', 1, 1) > 0 OR
            instr(expr.sql_select,  'CH.', 1, 1) = 1 OR
            instr(expr.sql_select, '|CH.', 1, 1) > 0 OR
            instr(expr.sql_select, '(CH.', 1, 1) > 0 OR
            instr(expr.sql_select, '+CH.', 1, 1) > 0 OR
            instr(expr.sql_select, '-CH.', 1, 1) > 0 OR
            instr(expr.sql_select, '*CH.', 1, 1) > 0 OR
            instr(expr.sql_select, '/CH.', 1, 1) > 0 OR
            instr(expr.sql_select, 'p_commission_line_id', 1, 1) > 0)
          THEN
           g_no_trx_flag := FALSE;
           EXIT;
        END IF;
     END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.generate_init.exception',
         	          sqlerrm);
    end if;
    raise;
END;

--   Get the object_id in cn_objects for formula, if not exist, create it.
PROCEDURE check_create_object(x_name                cn_objects.name%TYPE,
                              x_object_type        cn_objects.object_type%TYPE,
                              x_object_id        IN OUT NOCOPY cn_objects.object_id%TYPE,
                              x_repository_id cn_repositories.repository_id%TYPE)
  IS
     dummy        NUMBER;
     x_rowid        ROWID;
BEGIN
   -- check whether formula package exist in cn_objects
   SELECT  COUNT(*)
     INTO  dummy
     FROM cn_objects_all
     WHERE name = x_name
     AND object_type = x_object_type
     AND org_id = g_org_id;

   IF dummy = 0 THEN
      x_object_id := cn_utils.get_object_id;

      cn_objects_pkg.insert_row( x_rowid                   => x_rowid,
                                 x_object_id               => x_object_id,
                                 x_org_id                  => g_org_id,
                                 x_dependency_map_complete => 'N',
                                 x_name                    => x_name,
                                 x_description             => null,
                                 x_object_type             => x_object_type,
                                 x_repository_id           => X_repository_id,
                                 x_next_synchronization_date => null,
                                 x_synchronization_frequency => null,
                                 x_object_status           => 'A',
                                 x_object_value            => NULL );

    ELSIF dummy = 1 THEN
      SELECT  object_id INTO  x_object_id
        FROM  cn_objects_all
        WHERE  name = x_name
        AND  object_type = x_object_type
        AND org_id = g_org_id;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.check_create_object.exception',
         	          sqlerrm);
    end if;
    raise;
END check_create_object;

--   get the table alias
FUNCTION get_table_alias (p_input_from VARCHAR2, p_table_name VARCHAR2 )
  RETURN VARCHAR2 IS
     x_table_alias  VARCHAR2(30);
     l_table_position NUMBER;
     l_comma_position NUMBER;
     l_space_position NUMBER;
BEGIN
   l_table_position := instr(p_input_from, p_table_name);

   IF l_table_position > 0 THEN
      l_space_position := instr(p_input_from, ' ', l_table_position);
      l_comma_position := instr(p_input_from, ',', l_table_position);

      IF l_comma_position = 0 THEN
         l_comma_position := Length(p_input_from) + 1;
      END IF;
      x_table_alias := rtrim(ltrim(substr(p_input_from, l_space_position, l_comma_position-l_space_position), ' '), ' ');
      RETURN lower(x_table_alias);
    ELSE
      RETURN NULL;
   END IF ;
END get_table_alias;


--   get the table alias from cn_objects
FUNCTION get_table_alias_from_cn (p_table_name VARCHAR2 )
  RETURN VARCHAR2 IS
     x_table_alias  VARCHAR2(30);
     CURSOR p_table_alias_csr(l_table_name VARCHAR2) IS
        SELECT alias
          FROM cn_objects_all
          WHERE name = Upper(l_table_name)
          AND object_type = 'TBL'
          AND org_id = g_org_id;
BEGIN
   OPEN p_table_alias_csr(p_table_name);
   FETCH p_table_alias_csr INTO x_table_alias;
   CLOSE p_table_alias_csr;

   RETURN lower(x_table_alias);
END get_table_alias_from_cn;

--   check whether the sql_segment already exists
FUNCTION check_sql_stmt_existence (p_sql_select VARCHAR2,
                                   p_sql_stmt   VARCHAR2 )
  RETURN BOOLEAN IS
BEGIN
   IF instr(p_sql_select, p_sql_stmt) > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
   END IF;
END check_sql_stmt_existence;

-- Build WHERE clause for cn_commission_lines
PROCEDURE make_calc_type(p_line_alias VARCHAR2,
                         p_header_alias VARCHAR2,
                         x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_sql_stmt     VARCHAR2(1000);
BEGIN
   l_sql_stmt := ' and (( g_calc_type = ''FORECAST'' and '|| p_line_alias ||'.trx_type = ''FORECAST'') ';
   l_sql_stmt := l_sql_stmt || ' or (g_calc_type = ''BONUS'' and '|| p_line_alias ||'.trx_type = ''BONUS'') ';
   l_sql_stmt := l_sql_stmt || ' or (g_calc_type = ''COMMISSION'' and '|| p_line_alias || '.trx_type not in (''BONUS'', ''FORECAST'', ''GRP''))) ';
   IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
      x_sql_where := x_sql_where || l_sql_stmt;
   END IF;
END make_calc_type;

--       Build WHERE clause for cn_commission_lines
PROCEDURE make_srp_plan_pe_hid_pid_st(p_line_alias VARCHAR2,
                                      p_header_alias VARCHAR2,
                                      x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_sql_stmt     VARCHAR2(1000);
BEGIN
     l_sql_stmt := ' and '|| p_line_alias || '.credited_salesrep_id = p_salesrep_id';
     IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
        x_sql_where := x_sql_where || l_sql_stmt;
     END IF;

     l_sql_stmt := ' and '|| p_line_alias || '.srp_plan_assign_id = p_srp_plan_assign_id';
     IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
        x_sql_where := x_sql_where || l_sql_stmt;
     END IF;

     l_sql_stmt := ' and '|| p_line_alias || '.quota_id = p_quota_id';
     IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
        x_sql_where := x_sql_where || l_sql_stmt;
     END IF;

     if (p_header_alias is not null) then
     l_sql_stmt := ' and '|| p_header_alias || '.commission_header_id = ' || p_line_alias || '.commission_header_id';
     IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
        x_sql_where := x_sql_where || l_sql_stmt;
     END IF;
     end if;

     l_sql_stmt := ' and '|| p_line_alias || '.processed_period_id between p_start_period_id and p_period_id';
     IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
        x_sql_where := x_sql_where || l_sql_stmt;
     END IF;

     l_sql_stmt := ' and ' || p_line_alias || '.status = ''CALC'' ';
     IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
        x_sql_where := x_sql_where || l_sql_stmt;
     END IF;
END make_srp_plan_pe_hid_pid_st;

--       Build WHERE clause for cn_commission_lines
PROCEDURE handle_comm_lines_where( x_sql_select IN OUT NOCOPY VARCHAR2,
                                   x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                   x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_line_alias  VARCHAR2(30);
     l_header_alias VARCHAR2(30);
     l_sql_stmt     VARCHAR2(1000);
BEGIN
     -- Check if cn_commission_lines in FROM clause
     l_line_alias := get_table_alias (x_sql_from, 'cn_commission_lines');
     IF l_line_alias IS NOT NULL THEN
        -- for individual transaction
        IF g_trx_group_code = 'INDIVIDUAL' THEN
           l_sql_stmt := ' and ' || l_line_alias || '.commission_line_id = p_commission_line_id';

           IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
              x_sql_where := x_sql_where || l_sql_stmt;
           END IF;

         ELSIF g_trx_group_code = 'GROUP' THEN
           -- Group By Case: for all transaction
           -- get header table alias
           IF check_sql_stmt_existence(x_sql_from, 'cn_commission_headers') THEN
              l_header_alias := get_table_alias (x_sql_from, 'cn_commission_headers');
            ELSE -- comm_header not in sql_from yet, add it and get its alias
              l_header_alias := get_table_alias_from_cn('cn_commission_headers');
              x_sql_from := x_sql_from || ', cn_commission_headers ' || l_header_alias;
           END IF ;

           make_srp_plan_pe_hid_pid_st(l_line_alias, l_header_alias, x_sql_where);
           make_calc_type(l_line_alias, l_header_alias, x_sql_where);

        END IF; -- end of 'group by'
    elsif (g_trx_group_code = 'GROUP' and instr(x_sql_select, 'p_commission_line_id', 1, 1) > 0) then

      l_line_alias := get_table_alias_from_cn('cn_commission_lines');
      x_sql_from := x_sql_from || ', cn_commission_lines ' || l_line_alias;
      x_sql_select := replace(x_sql_select, 'p_commission_line_id', l_line_alias || '.commission_line_id');

	   make_srp_plan_pe_hid_pid_st(l_line_alias, l_header_alias, x_sql_where);
	   make_calc_type(l_line_alias, l_header_alias, x_sql_where);
     END IF; -- end of l_line_alias existence
END handle_comm_lines_where;

--       Build WHERE clause for cn_commission_headers if chosen
PROCEDURE handle_comm_headers_where( x_sql_select IN OUT NOCOPY VARCHAR2,
                                     x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                     x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_line_alias  VARCHAR2(30);
     l_header_alias VARCHAR2(30);
     l_sql_stmt     VARCHAR2(1000);
BEGIN
     -- Check if cn_commission_headers in FROM clause
     l_header_alias := get_table_alias (x_sql_from, 'cn_commission_headers');

     IF l_header_alias IS NOT NULL THEN
        -- get the alias for cn_commisson_lines
        IF check_sql_stmt_existence(x_sql_from, 'cn_commission_lines') THEN
           l_line_alias := get_table_alias (x_sql_from, 'cn_commission_lines');
         ELSE -- comm_lines not in sql_from yet, add it and get its alias
           l_line_alias := get_table_alias_from_cn('cn_commission_lines');
           x_sql_from := x_sql_from || ', cn_commission_lines ' || l_line_alias;
        END IF ;

        -- for individual transaction
        IF g_trx_group_code = 'INDIVIDUAL' THEN
           l_sql_stmt := ' and ' || l_line_alias || '.commission_line_id = p_commission_line_id';

           IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
              x_sql_where := x_sql_where || l_sql_stmt;
           END IF;

           l_sql_stmt := ' and '|| l_header_alias || '.commission_header_id' || ' = ' || l_line_alias ||'.commission_header_id';
           IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
              x_sql_where := x_sql_where || l_sql_stmt;
           END IF;
         ELSIF g_trx_group_code = 'GROUP' THEN
           -- Group By Case: for all transaction
           make_srp_plan_pe_hid_pid_st(l_line_alias, l_header_alias, x_sql_where);
           make_calc_type(l_line_alias, l_header_alias, x_sql_where);
        END IF; -- end of 'group by'
     END IF; -- end of l_line_alias existence
END handle_comm_headers_where;

--       Build WHERE clause for cn_quotas if chosen
PROCEDURE handle_cn_quotas_where( x_sql_select IN OUT NOCOPY VARCHAR2,
                                  x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                  x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_quota_alias  VARCHAR2(30);
     l_p_quota_alias VARCHAR2(30);
     l_sql_stmt     VARCHAR2(1000);
BEGIN
     g_pq_payment_flag := FALSE;
     g_pq_target_flag  := FALSE;

     l_quota_alias := get_table_alias (x_sql_from, 'cn_quotas');

     IF l_quota_alias IS NOT NULL THEN
        l_sql_stmt := ' and '|| l_quota_alias || '.quota_id = ' || 'p_quota_id';
        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;

        IF g_itd_flag = 'Y' THEN
           -- g_itd_flag = 'Y', replace cn_quota.target with cn_period_quotas.itd_target

           IF instr(x_sql_select, l_quota_alias||'.target') > 0  THEN
              g_pq_target_flag := TRUE;

              x_sql_select := replace( x_sql_select, l_quota_alias ||'.target', '1' );
           END IF;

           IF instr(x_sql_select, l_quota_alias||'.payment_amount') > 0 THEN
              g_pq_payment_flag := TRUE;

              -- get the alias for cn_period_quotas
              IF check_sql_stmt_existence(x_sql_from, 'cn_period_quotas') THEN
                 l_p_quota_alias := get_table_alias(x_sql_from, 'cn_period_quotas');
               ELSE -- period_quotas not in sql_from yet, add it and get its alias
                 l_p_quota_alias := get_table_alias_from_cn('cn_period_quotas');
                 x_sql_from := x_sql_from || ', cn_period_quotas ' || l_p_quota_alias;
              END IF ;

              l_sql_stmt := ' and '|| l_p_quota_alias ||'.quota_id' || ' = p_quota_id';
              IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
                 x_sql_where := x_sql_where || l_sql_stmt;
              END IF;

              l_sql_stmt := ' and '|| l_p_quota_alias ||'.period_id' || ' = p_period_id';
              IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
                 x_sql_where := x_sql_where || l_sql_stmt;
              END IF;

              x_sql_select := replace( x_sql_select,
                                       l_quota_alias ||'.payment_amount',
                                       l_p_quota_alias ||'.itd_payment' );
           END IF; -- there is cn_quotas.target/payment_amount selected
        END IF ;-- itd = 'Y'
     END IF;
END handle_cn_quotas_where;

--       Build WHERE clause for cn_srp_period_quotas if chosen
PROCEDURE handle_srp_p_quotas_where( x_sql_select IN OUT NOCOPY VARCHAR2,
                                     x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                     x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_sp_quota_alias  VARCHAR2(30);
     l_sql_stmt     VARCHAR2(1000);
BEGIN
     g_spq_payment_flag := FALSE;
     g_spq_target_flag  := FALSE;

     l_sp_quota_alias := get_table_alias(x_sql_from, 'cn_srp_period_quotas');

     IF l_sp_quota_alias IS NOT NULL THEN
        l_sql_stmt := ' and '|| l_sp_quota_alias || '.salesrep_id = ' || 'p_salesrep_id';
        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;

        l_sql_stmt := ' and '|| l_sp_quota_alias ||'.quota_id' || ' = p_quota_id';
        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;

        l_sql_stmt := ' and '|| l_sp_quota_alias ||'.period_id' || ' = p_period_id';
        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;

        l_sql_stmt := ' and '|| l_sp_quota_alias ||'.srp_plan_assign_id' || ' = p_srp_plan_assign_id';
        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;

        -- itd = 'Y' and
        IF g_itd_flag = 'Y' THEN

           IF instr(x_sql_select, l_sp_quota_alias||'.period_payment') > 0  THEN
              g_spq_payment_flag := TRUE;

              x_sql_select := replace( x_sql_select, l_sp_quota_alias ||'.period_payment', l_sp_quota_alias ||'.itd_payment' );
            ELSIF (instr(x_sql_select, l_sp_quota_alias || '.itd_payment') > 0) THEN
              g_spq_payment_flag := TRUE;
           END IF;

           IF instr(x_sql_select, l_sp_quota_alias||'.target_amount') > 0 THEN
              g_spq_target_flag := TRUE;

              IF (g_pq_payment_flag OR g_spq_payment_flag or g_no_trx_flag) THEN
                x_sql_select := replace( x_sql_select, l_sp_quota_alias ||'.target_amount', l_sp_quota_alias ||'.itd_payment' );
              else
                x_sql_select := replace( x_sql_select, l_sp_quota_alias ||'.target_amount', '1' );
              end if;
            ELSIF (instr(x_sql_select, l_sp_quota_alias || '.itd_target') > 0) THEN
              g_spq_target_flag := TRUE;

              if (g_pq_payment_flag OR g_spq_payment_flag or g_no_trx_flag) then
                null;
              else
                x_sql_select := REPLACE( x_sql_select, l_sp_quota_alias || '.itd_target', '1');
              end if;

              IF (g_rollover_flag = 'Y') THEN
                 x_sql_select := REPLACE(x_sql_select, l_sp_quota_alias || '.total_rollover', 0);
              END IF;
           END IF;
        END IF;
     END IF;
END handle_srp_p_quotas_where;

--       Build WHERE clause for cn_srp_quota_assigns if chosen
PROCEDURE handle_srp_q_assigns_where( x_sql_select IN OUT NOCOPY VARCHAR2,
                                      x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                      x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_sq_assign_alias  VARCHAR2(30);
     l_sql_stmt     VARCHAR2(1000);
BEGIN
     l_sq_assign_alias := get_table_alias(x_sql_from, 'cn_srp_quota_assigns');

     IF l_sq_assign_alias IS NOT NULL THEN
        l_sql_stmt := ' and '|| l_sq_assign_alias ||'.quota_id' || ' = p_quota_id';
        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;

        l_sql_stmt := ' and '|| l_sq_assign_alias ||'.srp_plan_assign_id' || ' = p_srp_plan_assign_id';
        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;

        IF (g_itd_flag = 'Y' AND instr(x_sql_select, l_sq_assign_alias || '.payment_amount') > 0) THEN
           g_spq_payment_flag := TRUE;
        END IF;
     END IF;
END handle_srp_q_assigns_where;

--       Build WHERE clause for cn_srp_plan_assigns if chosen
PROCEDURE handle_srp_p_assigns_where( x_sql_select IN OUT NOCOPY VARCHAR2,
                                      x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                      x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_sp_assign_alias  VARCHAR2(30);
     l_sql_stmt     VARCHAR2(1000);
BEGIN
     l_sp_assign_alias := get_table_alias(x_sql_from, 'cn_srp_plan_assigns');

     IF l_sp_assign_alias IS NOT NULL THEN
        l_sql_stmt := ' and '|| l_sp_assign_alias ||'.srp_plan_assign_id' || ' = p_srp_plan_assign_id';
        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;
     END IF;
END handle_srp_p_assigns_where;

--       Build WHERE clause for cn_salesreps if chosen
PROCEDURE handle_cn_salesreps_where( x_sql_select IN OUT NOCOPY VARCHAR2,
                                     x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                     x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_srp_alias  VARCHAR2(30);
     l_sql_stmt     VARCHAR2(1000);
BEGIN
     l_srp_alias := get_table_alias(x_sql_from, 'cn_salesreps');

     IF l_srp_alias IS NOT NULL THEN
        l_sql_stmt := ' and '|| l_srp_alias ||'.salesrep_id' || ' = p_salesrep_id';
        l_sql_stmt := ' and '|| l_srp_alias ||'.org_id' || ' = g_org_id';
        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;
     END IF;
END handle_cn_salesreps_where;

--       Build WHERE clause for cn_srp_periods if chosen
PROCEDURE handle_cn_srp_periods_where( x_sql_select IN OUT NOCOPY VARCHAR2,
                                       x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                       x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_srp_alias  VARCHAR2(30);
     l_sql_stmt     VARCHAR2(1000);
BEGIN
     l_srp_alias := get_table_alias(x_sql_from, 'cn_srp_periods');

     IF l_srp_alias IS NOT NULL THEN
        l_sql_stmt := ' and '|| l_srp_alias ||'.salesrep_id' || ' = p_salesrep_id';
        l_sql_stmt := l_sql_stmt || ' and '|| l_srp_alias ||'.period_id' || ' = p_period_id';
        l_sql_stmt := l_sql_stmt || ' and '|| l_srp_alias ||'.credit_type_id' || ' = p_credit_type_id';
        l_sql_stmt := l_sql_stmt || ' and '|| l_srp_alias ||'.role_id' || ' = p_role_id';
        l_sql_stmt := l_sql_stmt || ' and '|| l_srp_alias ||'.org_id' || ' = g_org_id';

        IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
           x_sql_where := x_sql_where || l_sql_stmt;
        END IF;
     END IF;
END handle_cn_srp_periods_where;

--       Build WHERE clause if any external table is included
PROCEDURE separate_tbl_alias ( p_input_sql   VARCHAR2,
                               p_start       NUMBER,
                               x_table_name  OUT NOCOPY VARCHAR2,
                               x_table_alias OUT NOCOPY VARCHAR2,
                               x_end_flag    OUT NOCOPY BOOLEAN ,
                               x_new_start   OUT NOCOPY NUMBER    )
  IS
     l_position_space NUMBER;
     l_position_comma NUMBER;
BEGIN
     IF (p_start = 1) THEN
        l_position_space := instr(p_input_sql, ' ', p_start, 2);
      ELSE
        l_position_space := instr(p_input_sql, ' ', p_start);
        IF (l_position_space = p_start) THEN
           l_position_space := instr(p_input_sql, ' ', p_start + 1);
        END IF;
     END IF;
     l_position_comma := instr(p_input_sql, ',', p_start);

     IF l_position_comma = 0 THEN
        -- the search has reach the end
        x_end_flag := TRUE;

        IF l_position_space > 0 THEN
           if (p_start = 1) then
              x_table_name := trim(both ' ' FROM substr(p_input_sql, 6, (l_position_space - 6)));
            else
              x_table_name := trim(both ' ' FROM substr(p_input_sql, p_start, (l_position_space - p_start)) );
           end if;
           x_table_alias := trim( both ' ' FROM substr(p_input_sql, l_position_space+1, (Length(p_input_sql) - l_position_space + 1)));
        END IF;

      ELSE
        x_end_flag := FALSE;

        if (p_start = 1) then
           x_table_name := trim(both ' ' FROM substr(p_input_sql, 6, (l_position_space - 6)));
         else
           x_table_name := trim(both ' ' FROM substr(p_input_sql, p_start, (l_position_space - p_start)) );
        end if;
        x_table_alias := trim(both ' ' FROM substr(p_input_sql, l_position_space, l_position_comma - l_position_space) );
        x_new_start := l_position_comma + 1;
     END IF;
END separate_tbl_alias;

--       Build WHERE clause if any external table is included
PROCEDURE handle_external_tables( x_sql_select IN OUT NOCOPY VARCHAR2,
                                  x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                  x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_sql_stmt VARCHAR2(1000);
     l_table_name VARCHAR2(30);
     l_table_alias VARCHAR2(30);
     l_end_flag    BOOLEAN;
     l_start_position NUMBER;
     l_start_position_old NUMBER;  --Fix for bug 9001039 .

     CURSOR l_all_column_pairs_csr(l_calc_ext_table_id NUMBER)IS
        SELECT lower(obj1.name) internal_column_name, lower(obj2.name) external_column_name
          FROM cn_calc_ext_tbl_dtls_all detail,
          cn_objects_all obj1,
          cn_objects_all obj2
          WHERE detail.calc_ext_table_id = l_calc_ext_table_id
          AND obj1.object_id = detail.internal_column_id
          AND obj1.org_id = detail.org_id
          AND obj2.object_id = detail.external_column_id
          AND obj2.org_id = detail.org_id;

     CURSOR l_ext_table_csr IS
        SELECT map.calc_ext_table_id,
          lower(obj.name) internal_table_name,
          trim( both ' ' FROM lower(obj.alias) )  internal_table_alias,
          lower(l_table_name) external_table_name,
          lower(l_table_alias) external_table_alias
          FROM cn_objects_all obj,
          cn_calc_ext_tables_all map
          WHERE  lower(map.alias) = l_table_alias
          AND map.org_id = g_org_id
          AND obj.object_id = map.internal_table_id
          AND obj.org_id = map.org_id;
BEGIN
     l_end_flag := FALSE;
     l_start_position := 1;
     l_start_position_old := 1;

     WHILE l_end_flag <> TRUE LOOP
        separate_tbl_alias( x_sql_from,
                            l_start_position_old,
                            l_table_name,
                            l_table_alias,
                            l_end_flag,
                            l_start_position   );

       l_start_position_old :=   l_start_position;

        FOR l_table IN l_ext_table_csr LOOP
           -- if external table found in x_sql_from, check if the internal table name not in x_sql_from yet, add it
           IF NOT check_sql_stmt_existence(x_sql_from, l_table.internal_table_name) THEN
              l_sql_stmt := NULL;
              l_sql_stmt := ' , '|| l_table.internal_table_name || ' ' || l_table.internal_table_alias;
              x_sql_from := x_sql_from || l_sql_stmt;
           END IF;

           -- add join condition for this relationship
           FOR l_pair IN l_all_column_pairs_csr(l_table.calc_ext_table_id) LOOP
              l_sql_stmt := ' and ' || l_table.internal_table_alias || '.' ||
                l_pair.internal_column_name || ' = ' || l_table.external_table_alias || '.' || l_pair.external_column_name ;
              IF NOT check_sql_stmt_existence(x_sql_where, l_sql_stmt) THEN
                 x_sql_where := x_sql_where || l_sql_stmt;
              END IF;
           END LOOP;
        END LOOP;
     END LOOP;
END handle_external_tables;

--Build order by clause if any external table is included in bonus type formula
PROCEDURE handle_bonus_ex_tbl_orderby( x_sql_select IN OUT NOCOPY VARCHAR2,
                                       x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                       x_sql_where IN OUT NOCOPY VARCHAR2,
                                       p_mode  VARCHAR2 )
  IS
     l_table_name VARCHAR2(30);
     l_table_alias VARCHAR2(30);
     l_end_flag    BOOLEAN;
     l_start_position NUMBER;

     l_sql_stmt VARCHAR2(1000);
     l_counter NUMBER := 0;
     l_sql_select VARCHAR2(4000);
     l_sql_where VARCHAR2(1000);

     CURSOR l_all_columns_csr IS
        SELECT  col.table_id, lower(col.name) column_name
          FROM cn_calc_ext_tables_all map,
          cn_objects_all col
          WHERE map.alias = l_table_alias
          AND map.org_id = g_org_id
          AND col.table_id = map.external_table_id
          AND col.org_id = map.org_id
          AND col.object_type = 'COL'
          AND primary_key = 'Y'
          AND position IS NOT NULL
            ORDER BY position;

BEGIN
     -- assume only one external table will be used. p_mode can be 'OUTPUT', 'PERF', 'INPUT1', 'INPUT'
     l_end_flag := FALSE;
     l_start_position := 1;

     WHILE l_end_flag <> TRUE LOOP
        separate_tbl_alias( x_sql_from,
                            l_start_position+0,
                            l_table_name,
                            l_table_alias,
                            l_end_flag,
                            l_start_position   );

        FOR l_col IN l_all_columns_csr LOOP
           -- if external table found in x_sql_from
           l_counter := 1;

           IF p_mode = 'INPUT1' THEN
              g_external_table_id := l_col.table_id;
           END IF;

           IF p_mode = 'INPUT0' THEN
              IF l_all_columns_csr%rowcount = 1 THEN
                 l_sql_select := 'select ' ||  l_table_alias || '.'||  l_col.column_name ;
               ELSE
                 l_sql_select := l_sql_select || ', ' || l_table_alias || '.'||  l_col.column_name ;
              END IF;
           END IF;

           IF p_mode = 'INPUT0 ' THEN
              IF l_all_columns_csr%rowcount = 1 THEN
                 l_sql_stmt :=  ' order by ' || l_table_alias || '.'|| l_col.column_name ;
               ELSIF l_all_columns_csr%rowcount > 1 THEN
                 l_sql_stmt :=  l_sql_stmt || '  ,' || l_table_alias || '.'|| l_col.column_name;
              END IF;
            ELSE
              l_sql_where := l_sql_where || ' and ' || l_table_alias || '.' || l_col.column_name || ' = ' || 'l_parameter_'||
                To_char(l_all_columns_csr%rowcount);
           END IF;
        END LOOP;
        EXIT WHEN l_counter = 1;
     END LOOP;

     x_sql_where := x_sql_where || l_sql_where || l_sql_stmt;
     IF p_mode = 'INPUT0' THEN
        x_sql_select := l_sql_select;
      ELSE
        x_sql_select := x_sql_select || l_sql_select;
     END IF;
exception
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.handle_bonus_ex_tbl_orderby.exception',
         	          sqlerrm);
    end if;
    raise;
END handle_bonus_ex_tbl_orderby;

--       take care of RateResult in output_sql_select
PROCEDURE handle_output_sql_select( x_sql_select IN OUT NOCOPY VARCHAR2,
                                    x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                    x_sql_where IN OUT NOCOPY VARCHAR2 )
  IS
     l_position   NUMBER;
     l_operator_position NUMBER;
BEGIN
     -- Find the place of RateResult
     l_position := instr(x_sql_select, 'rateresult');

     IF l_position > 0 THEN
        -- In ITD case, need to cumulate outputportion without RateResult
        IF (g_itd_flag = 'Y') THEN --IF g_itd_flag = 'Y' OR g_trx_group_code = 'GROUP' THEN
           l_operator_position := search_delimiter_select(x_sql_select, l_position);

           IF l_operator_position = 0 THEN
              -- there is only 'rateresult' found in output, nothing else
              x_sql_select := replace(x_sql_select, substr(x_sql_select, l_position, length('rateresult')), 'p_rate');
            ELSIF (g_pq_payment_flag OR g_spq_payment_flag) THEN
	      x_sql_select := replace(x_sql_select, substr(x_sql_select, l_position, length('rateresult')), 'p_rate');
            ELSE
              x_sql_select := replace(x_sql_select, substr(x_sql_select, l_position, l_operator_position - l_position +1 ), ' ');
           END IF;
         ELSE
           x_sql_select := replace(x_sql_select, substr(x_sql_select, l_position, length('rateresult')), 'p_rate');
        END IF;
     END IF;

     x_sql_select := replace(x_sql_select, 'cspq.input_achieved_itd', '(g_input_achieved_itd(1) + g_input_achieved)');
END handle_output_sql_select;

-- take care of modifying the sql_from and contruction sql_where
PROCEDURE construct_sql_from_where( x_sql_select IN OUT NOCOPY VARCHAR2,
                                    x_sql_from IN OUT NOCOPY VARCHAR2 ,
                                    x_sql_where IN OUT NOCOPY VARCHAR2 ) IS
BEGIN
     handle_external_tables(x_sql_select, x_sql_from, x_sql_where);
     handle_comm_lines_where(x_sql_select, x_sql_from, x_sql_where);
     handle_comm_headers_where(x_sql_select, x_sql_from, x_sql_where);
     handle_cn_quotas_where(x_sql_select, x_sql_from, x_sql_where);
     handle_cn_srp_periods_where(x_sql_select, x_sql_from, x_sql_where);
     handle_srp_p_quotas_where(x_sql_select, x_sql_from, x_sql_where);
     handle_srp_q_assigns_where(x_sql_select, x_sql_from, x_sql_where);
     handle_srp_p_assigns_where(x_sql_select, x_sql_from, x_sql_where);
     handle_cn_salesreps_where( x_sql_select, x_sql_from, x_sql_where);
END construct_sql_from_where;

--   create the global variables for the formula package
PROCEDURE  pkg_variables(spec_code        IN OUT NOCOPY cn_utils.code_type,
                         body_code        IN OUT NOCOPY cn_utils.code_type )  IS

-- Added for 11.5.10 Performance Enhancments
l_counter              NUMBER(15);
l_variable_declaration VARCHAR2(1000);
l_table_object_id      cn_objects.object_id%type;

BEGIN
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '  g_commission_payed_ptd      NUMBER;');
     cn_utils.appindcr(body_code, '  g_commission_payed_itd      NUMBER;');
     cn_utils.appindcr(body_code, '  g_input_achieved_ptd        cn_formula_common_pkg.num_table_type;');
     cn_utils.appindcr(body_code, '  g_input_achieved_itd        cn_formula_common_pkg.num_table_type;');
     cn_utils.appindcr(body_code, '  g_output_achieved_ptd       NUMBER;');
     cn_utils.appindcr(body_code, '  g_output_achieved_itd       NUMBER;');
     cn_utils.appindcr(body_code, '  g_perf_achieved_ptd         NUMBER;');
     cn_utils.appindcr(body_code, '  g_perf_achieved_itd         NUMBER;');
     cn_utils.appindcr(body_code, '  g_rollover_flag             VARCHAR2(1) := ' || ''''||g_rollover_flag||''''||';');
     cn_utils.appindcr(body_code, '  g_intel_calc_flag           VARCHAR2(1);');
     cn_utils.appindcr(body_code, '  g_calc_type                 VARCHAR2(30);');
     cn_utils.appindcr(body_code, '  g_select_status_flag        VARCHAR2(30);');
     cn_utils.appindcr(body_code, '  g_formula_id                NUMBER := ' || g_formula_id || ' ; ');
     cn_utils.appindcr(body_code, '  g_number_dim                NUMBER := ' || g_number_dim || ' ; ');
     cn_utils.appindcr(body_code, '  g_split_flag                VARCHAR2(1) := ' || ''''|| g_split_flag ||''''||' ; ');
     cn_utils.appindcr(body_code, '  g_trx_group_code            VARCHAR2(30) := '|| ''''|| g_trx_group_code ||''''||' ; ');
     cn_utils.appindcr(body_code, '  g_itd_flag                  VARCHAR2(1) := ' || ''''|| g_itd_flag ||''''||' ; ');
     cn_utils.appindcr(body_code, '  g_input_achieved            NUMBER;');
     cn_utils.appindcr(body_code, '  g_output_achieved           NUMBER;');
     cn_utils.appindcr(body_code, '  g_org_id                    NUMBER := ' || g_org_id || ';');


     -- Added for 11.5.10 Performance Enhancments
     -- Declare record variable for each table accessed in input/output/perf expressions
     l_table_object_id := g_uniq_tbl_names_tbl.FIRST;
     FOR l_counter IN 1..g_uniq_tbl_names_tbl.COUNT LOOP
        IF INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_LINES') =  0  AND
           INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_HEADERS') = 0 THEN

                l_variable_declaration :=  g_uniq_tbl_names_tbl(l_table_object_id).variable_name;
                l_variable_declaration := l_variable_declaration||'                       '
                                          ||g_uniq_tbl_names_tbl(l_table_object_id).table_name
                                          ||'%ROWTYPE;';
                cn_utils.appindcr(body_code,'  '|| l_variable_declaration);
        END IF;
        l_table_object_id :=  g_uniq_tbl_names_tbl.NEXT(l_table_object_id);
     END LOOP;

     -- Added for 11.5.10 Performance Enhancments
     -- Declare record type to hold all columns fetched from CH and CL tables
     cn_utils.appendcr(body_code);
      cn_utils.appindcr(body_code ,'TYPE comm_type IS RECORD ');
      cn_utils.appindcr(body_code ,'(');
      FOR i IN g_comm_tbl_clmn_nms_tbl.FIRST..g_comm_tbl_clmn_nms_tbl.LAST LOOP

          IF i <> g_comm_tbl_clmn_nms_tbl.LAST THEN
           cn_utils.appindcr(body_code ,'          '||nvl(g_comm_tbl_clmn_nms_tbl(i).column_alias, g_comm_tbl_clmn_nms_tbl(i).column_name)||'            '||g_comm_tbl_clmn_nms_tbl(i).table_name||'.'||g_comm_tbl_clmn_nms_tbl(i).column_name||'%TYPE,'  );
          ELSE
           cn_utils.appindcr(body_code ,'          '||nvl(g_comm_tbl_clmn_nms_tbl(i).column_alias, g_comm_tbl_clmn_nms_tbl(i).column_name)||'            '||g_comm_tbl_clmn_nms_tbl(i).table_name||'.'||g_comm_tbl_clmn_nms_tbl(i).column_name||'%TYPE'  );
          END IF;

      END LOOP;

      cn_utils.appindcr(body_code ,');');
      cn_utils.appindcr(body_code ,' g_commission_rec                comm_type ;');



     -- create package variables for pe references
     IF (g_pe_reference_tbl.COUNT > 0) THEN
        FOR i IN g_pe_reference_tbl.first..g_pe_reference_tbl.last LOOP
           cn_utils.appendcr(body_code, '  g_'||REPLACE(g_pe_reference_tbl(i), '.', '_')||'      NUMBER;');
        END LOOP;
     END IF;
     cn_utils.appendcr(body_code);
END pkg_variables;

PROCEDURE convert_clob_to_string ( p_clob_loc clob, x_string OUT NOCOPY VARCHAR2) IS
     l_amount NUMBER;
BEGIN
     l_amount := dbms_lob.getlength(p_clob_loc);
     dbms_lob.read( p_clob_loc, l_amount, 1 , x_string);

     IF (g_pe_id_tbl.COUNT > 0) THEN
        FOR i IN g_pe_id_tbl.first..g_pe_id_tbl.last LOOP
           x_string := REPLACE(x_string, g_pe_id_tbl(i)||'PE.', 'g_'||g_pe_id_tbl(i)||'PE_');
        END LOOP;
     END IF;
END convert_clob_to_string;

--   construct the get_input procedure for the formula package.
PROCEDURE get_input (         spec_code        IN OUT NOCOPY cn_utils.code_type,
                        body_code        IN OUT NOCOPY cn_utils.code_type )
  IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;
    package_spec_id        cn_obj_packages_v.package_id%TYPE;
    x_repository_id        cn_repositories.repository_id%TYPE;

    l_input_sql_select        varchar2(8000);
    l_input_sql_from        varchar2(4000);
    l_input_sql_where   varchar2(4000) := 'WHERE 1=1 ';

    l_input_sql_select_clob clob;
    l_input_sql_from_clob   clob;

    l_counter NUMBER;
    l_dim_unit_code VARCHAR2(30);

    CURSOR l_mul_inputs_csr IS
       SELECT rate_dim_sequence, calc_sql_exp_id, nvl(split_flag, 'N') split_flag, nvl(cumulative_flag, 'N') cumulative_flag
         FROM cn_formula_inputs_all
        WHERE calc_formula_id = g_formula_id
          AND org_id = g_org_id
        ORDER BY rate_dim_sequence;

    -- cursor to get the dim_unit_code
    CURSOR dim_type(p_rate_dim_sequence NUMBER) IS
       SELECT dim_unit_code
         FROM cn_rate_dimensions_all
        WHERE rate_dimension_id = (SELECT rate_dimension_id
                                     FROM cn_rate_sch_dims_all
                                    WHERE rate_dim_sequence = p_rate_dim_sequence
                                      AND rate_schedule_id = (SELECT rate_schedule_id
                                                                FROM cn_rt_formula_asgns_all
                                                               WHERE calc_formula_id = g_formula_id
                                                                 AND org_id = g_org_id
                                                                 AND ROWNUM = 1));

    CURSOR l_sql_select_from_csr (l_calc_sql_exp_id NUMBER) IS
       SELECT  sql_select input_sql_select, sql_from input_sql_from
         FROM  cn_calc_sql_exps_all
         WHERE calc_sql_exp_id = l_calc_sql_exp_id;

BEGIN
     procedure_name := 'get_input';
     procedure_desc := 'This procedure is to calculate the input';
     parameter_list := 'p_commission_line_id NUMBER, p_salesrep_id NUMBER,' ||
       'p_period_id NUMBER, p_quota_id    NUMBER, p_srp_plan_assign_id NUMBER,' ||
       'p_processed_date DATE, x_mul_input_tbl IN OUT NOCOPY cn_formula_common_pkg.mul_input_tbl_type';
     IF g_trx_group_code = 'GROUP' THEN
        parameter_list := parameter_list || ', p_endofinterval_flag VARCHAR2, p_start_period_id NUMBER';
     END IF;

     proc_init(procedure_name, procedure_desc, parameter_list,
               'P', null , package_spec_id, x_repository_id,
               spec_code, body_code);

     cn_utils.appindcr(body_code, '  l_input              NUMBER;');
     cn_utils.appindcr(body_code, '  l_input_string     VARCHAR2(30);');
     cn_utils.appindcr(body_code, '  l_itd_target       NUMBER;');
     cn_utils.appendcr(body_code);
     cn_utils.appendcr(body_code, 'BEGIN');

     IF g_trx_group_code = 'INDIVIDUAL' THEN
        l_counter := 1;
        FOR l_mul_input IN l_mul_inputs_csr LOOP
           OPEN dim_type(l_mul_input.rate_dim_sequence);
           FETCH dim_type INTO l_dim_unit_code;
           CLOSE dim_type;

           l_input_sql_where  := 'WHERE 1=1 ';

           OPEN l_sql_select_from_csr(l_mul_input.calc_sql_exp_id);
           FETCH l_sql_select_from_csr INTO l_input_sql_select_clob, l_input_sql_from_clob;
           CLOSE l_sql_select_from_csr;

           convert_clob_to_string(l_input_sql_select_clob, l_input_sql_select);
           l_input_sql_select := lower_str( 'select ' || l_input_sql_select );
           convert_clob_to_string(l_input_sql_from_clob, l_input_sql_from);
           l_input_sql_from := lower( 'from ' || l_input_sql_from );

           -- if other tables other than the standard tables are used in
           -- the input expression we will retain the select statment in
           -- get input othewise we will replace it with a expression using
           -- global variable which are prepopulated in calculate_quota
           IF g_other_tabused_tbl(l_mul_input.calc_sql_exp_id) = 'Y' THEN

              construct_sql_from_where (l_input_sql_select,
                                        l_input_sql_from,
                                        l_input_sql_where );
              split_long_sql( body_code, l_input_sql_select, 'SELECT');

              IF (l_dim_unit_code = 'STRING') THEN
                 cn_utils.appindcr(body_code, ' into l_input_string ');
               ELSE
                 cn_utils.appindcr(body_code, '   into l_input ');
              END IF;
              split_long_sql( body_code, l_input_sql_from, 'FROM');
              split_long_sql( body_code, l_input_sql_where||';', 'WHERE');
           ELSE
              -- Added for 11.5.10 Performance Enhancments
              -- Replace the select with a expression which uses the prefetched column values
              -- held in record variables

              -- Added the call to below procedure for bugfix 3574402
              construct_sql_from_where (l_input_sql_select,
	                                              l_input_sql_from,
	                                              l_input_sql_where );


              IF g_non_plsql_func_used_tbl(l_mul_input.calc_sql_exp_id) = 'N' THEN
                      IF (l_dim_unit_code = 'STRING') THEN
                          cn_utils.appindcr(body_code, ' l_input_string := ');
                      ELSE
                          cn_utils.appindcr(body_code, 'l_input := ');
                      END IF;
              ELSE
                     cn_utils.appindcr(body_code,'SELECT ');
              END IF;
              -- add the select clause of the expression with column names replaced with
              -- global package variables
              FOR i in 1..g_exp_tbl_dtls_tbl.COUNT LOOP
                 IF  g_exp_tbl_dtls_tbl(i).CALC_SQL_EXP_ID = l_mul_input.calc_sql_exp_id THEN
                    IF (g_exp_tbl_dtls_tbl(i).table_name <> 'CN_COMMISSION_LINES' AND
                       g_exp_tbl_dtls_tbl(i).table_name <> 'CN_COMMISSION_HEADERS' ) THEN
                       l_input_sql_select :=  REPLACE(l_input_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                   g_exp_tbl_dtls_tbl(i).column_name),
                                                                   g_exp_tbl_dtls_tbl(i).variable_name);

                    ELSIF (g_exp_tbl_dtls_tbl(i).table_name = 'CN_COMMISSION_HEADERS')THEN
            			/* column name from CN_COMMISSION_HEADERS could have been added with a 'CH_' in front of the column name
            			or not. To identify whether CH_ was added in front of the column name, use g_exp_tbl_dtls_tbl.alias_added
            			boolena varriable
            			*/
            			if (g_exp_tbl_dtls_tbl(i).alias_added = true) then
            	                       l_input_sql_select :=  REPLACE(l_input_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                               g_exp_tbl_dtls_tbl(i).column_name),
                                                                               'g_commission_rec'||'.'||g_exp_tbl_dtls_tbl(i).table_alias||'_'||g_exp_tbl_dtls_tbl(i).column_name);
            			else
            	                       l_input_sql_select :=  REPLACE(l_input_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                               g_exp_tbl_dtls_tbl(i).column_name),
                                                                               'g_commission_rec'||'.'||g_exp_tbl_dtls_tbl(i).column_name);
            			end if;
                    ELSE
                       l_input_sql_select :=  REPLACE(l_input_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                   g_exp_tbl_dtls_tbl(i).column_name),
                                                                   'g_commission_rec'||'.'||g_exp_tbl_dtls_tbl(i).column_name);
                    END IF;
                 END IF;
              END LOOP;
              -- if non plsq function like DECODE is used we cannot use just an expression
              -- so select expression from dual;
              IF g_non_plsql_func_used_tbl(l_mul_input.calc_sql_exp_id) = 'N' THEN
                 -- fix for bug 3187576
                 --cn_utils.appindcr(body_code,REPLACE(l_input_sql_select,'select',NULL)||';');
                 split_long_sql( body_code, REPLACE(l_input_sql_select,'select',NULL)||';', 'SELECT');

              ELSE
                 -- fix for bug 3187576
                 --cn_utils.appindcr(body_code,REPLACE(l_input_sql_select,'select',NULL));
                 split_long_sql( body_code, REPLACE(l_input_sql_select,'select',NULL), 'SELECT');

                 IF (l_dim_unit_code = 'STRING') THEN
                              cn_utils.appindcr(body_code, ' into l_input_string ');
                 ELSE
                              cn_utils.appindcr(body_code, '   into l_input ');
                 END IF;
                 cn_utils.appindcr(body_code, '   FROM  DUAL; ');
              END IF;
            END IF;

           cn_utils.appendcr(body_code);

           IF (l_dim_unit_code = 'STRING') THEN
             cn_utils.appindcr(body_code, '  l_input_string := nvl(l_input_string, ''''); ');
           ELSE
             cn_utils.appindcr(body_code, '  l_input := nvl(l_input, 0); ');
           END IF;

           cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter ||').rate_dim_sequence := ' || l_mul_input.rate_dim_sequence || ' ; ' );

           IF (l_dim_unit_code = 'STRING') THEN
              cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter || ').input_string := l_input_string;' );
            ELSE
              cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter || ').input_amount := l_input;' );
              cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter ||').amount := l_input;' );
           END IF;

           IF (l_mul_input.cumulative_flag = 'N') THEN --IF g_cumulative_flag = 'N'  THEN
              -- 1.single input with non accumulative
              -- 2.multiple inputs case is always non accumulative
              IF (l_mul_input.split_flag <> 'N') THEN --IF g_split_flag <> 'N' THEN -- need to split
                 cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter || ').base_amount := 0;' );
               ELSE -- non cumulative with no split
                 cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter || ').base_amount := l_input;' );
              END IF;
            ELSE -- single input with cumulative_flag ON. we need to distinguish
              IF (g_cumulative_input_no = 1) THEN
                 g_cumulative_input_no := l_counter;
              END IF;

              IF g_itd_flag = 'N' THEN
                 IF (l_mul_input.split_flag <> 'N') THEN --IF g_split_flag <> 'N' THEN -- need to split
                    cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter || ').base_amount := g_input_achieved_itd('||l_mul_input.rate_dim_sequence||');' );
                  ELSE
                    cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter || ').base_amount := g_input_achieved_itd('||l_mul_input.rate_dim_sequence||') + l_input;' );
                 END IF;
               ELSE -- g_itd_flag = 'Y'
                 cn_utils.appendcr(body_code);
                 IF g_pq_target_flag OR g_spq_target_flag  THEN
                    IF g_pq_target_flag THEN
                       cn_utils.appindcr(body_code, '  l_itd_target := cn_formula_common_pkg.get_pq_itd_target ');
                       cn_utils.appindcr(body_code, '                              ( p_period_id, p_quota_id  );' );
                    END IF;

                    IF g_spq_target_flag THEN
                       cn_utils.appindcr(body_code, '  l_itd_target := cn_formula_common_pkg.get_spq_itd_target ');
                       cn_utils.appindcr(body_code, '                         ( p_salesrep_id, p_srp_plan_assign_id, ' );
                       cn_utils.appindcr(body_code, '                           p_period_id, p_quota_id             ); ');
                    END IF;

                    cn_utils.appendcr(body_code);

                    IF (l_mul_input.split_flag <> 'N') THEN --IF g_split_flag <> 'N' THEN
                       cn_utils.appindcr(body_code, '  x_mul_input_tbl('|| l_counter || ').amount := (l_input+ g_input_achieved_itd('||l_mul_input.rate_dim_sequence||')) ');
                       cn_utils.appindcr(body_code, '     /l_itd_target;' );
                       cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter || ').base_amount := 0;' );
                     ELSE
                       --cn_utils.appindcr(body_code, '  x_mul_input_tbl('|| l_counter || ').amount := l_input / l_itd_target; ');
                       cn_utils.appindcr(body_code, '  x_mul_input_tbl('|| l_counter || ').base_amount := (l_input+ g_input_achieved_itd('||l_mul_input.rate_dim_sequence||'))');
                       cn_utils.appindcr(body_code, '      /l_itd_target;' );
                       cn_utils.appindcr(body_code, '  x_mul_input_tbl('|| l_counter || ').amount := x_mul_input_tbl('|| l_counter || ').base_amount; ');
                    END IF;
                  ELSE
                    IF (l_mul_input.split_flag <> 'N') THEN --IF g_split_flag <> 'N' THEN
                       cn_utils.appindcr(body_code, '  x_mul_input_tbl('|| l_counter || ').amount := l_input+ g_input_achieved_itd('||l_mul_input.rate_dim_sequence||');' );
                       cn_utils.appindcr(body_code, '  x_mul_input_tbl(' || l_counter || ').base_amount := 0;' );
                     ELSE
                       --cn_utils.appindcr(body_code, '  x_mul_input_tbl('|| l_counter || ').amount := l_input; ');
                       cn_utils.appindcr(body_code, '  x_mul_input_tbl('|| l_counter || ').base_amount := l_input+ g_input_achieved_itd('||l_mul_input.rate_dim_sequence||');' );
                       cn_utils.appindcr(body_code, '  x_mul_input_tbl('|| l_counter || ').amount := x_mul_input_tbl('|| l_counter || ').base_amount; ');
                    END IF;
                 END IF;
              END IF;
           END IF;
           cn_utils.appendcr(body_code);
           l_counter := l_counter+1;
        END LOOP;
      ELSE -- g_trx_group_code = 'GROUP'
        cn_utils.appindcr(body_code, ' IF p_commission_line_id IS NOT NULL THEN ');
        cn_utils.appendcr(body_code);

        g_trx_group_code := 'INDIVIDUAL';
        l_counter :=1;
        FOR l_mul_input IN l_mul_inputs_csr LOOP
           l_input_sql_where  := 'WHERE 1=1 ';

           OPEN l_sql_select_from_csr(l_mul_input.calc_sql_exp_id);
           FETCH l_sql_select_from_csr INTO l_input_sql_select_clob, l_input_sql_from_clob;
           CLOSE l_sql_select_from_csr;

           convert_clob_to_string(l_input_sql_select_clob, l_input_sql_select);
           l_input_sql_select := lower_str( 'select ' || l_input_sql_select );
           convert_clob_to_string(l_input_sql_from_clob, l_input_sql_from);
           l_input_sql_from := lower( 'from ' || l_input_sql_from );

           construct_sql_from_where (l_input_sql_select,
                                     l_input_sql_from,
                                     l_input_sql_where );

           split_long_sql( body_code, l_input_sql_select, 'SELECT');
           cn_utils.appindcr(body_code, '   into l_input ');
           split_long_sql( body_code, l_input_sql_from, 'FROM');
           split_long_sql( body_code, l_input_sql_where||';', 'WHERE');


           cn_utils.appindcr(body_code, '  l_input := nvl(l_input, 0); ');

        END LOOP;
        cn_utils.appindcr(body_code, ' ELSE  ');
        cn_utils.appendcr(body_code);

        g_trx_group_code := 'GROUP';
        l_counter :=1;
        FOR l_mul_input IN l_mul_inputs_csr LOOP

           l_input_sql_where  := 'WHERE 1=1 ';

           OPEN l_sql_select_from_csr(l_mul_input.calc_sql_exp_id);
           FETCH l_sql_select_from_csr INTO l_input_sql_select_clob, l_input_sql_from_clob;
           CLOSE l_sql_select_from_csr;

           convert_clob_to_string(l_input_sql_select_clob, l_input_sql_select);
           l_input_sql_select := lower_str( 'select ' || l_input_sql_select );
           convert_clob_to_string(l_input_sql_from_clob, l_input_sql_from);
           l_input_sql_from := lower( 'from ' || l_input_sql_from );

           construct_sql_from_where (l_input_sql_select,
                                     l_input_sql_from,
                                     l_input_sql_where );

           cn_utils.appindcr(body_code, ' BEGIN ');
           split_long_sql( body_code, l_input_sql_select, 'SELECT');
           cn_utils.appindcr(body_code, '   into l_input ');
           split_long_sql( body_code, l_input_sql_from, 'FROM');
           split_long_sql( body_code, l_input_sql_where||';', 'WHERE');
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '  l_input := nvl(l_input, 0); ');
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, ' EXCEPTION WHEN OTHERS THEN ');
           cn_utils.appindcr(body_code, '   if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
           cn_utils.appindcr(body_code, '      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
           cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.get_input.exception'', ');
           cn_utils.appindcr(body_code, '	          sqlerrm); ');
           cn_utils.appindcr(body_code, '   end if; ');
           cn_utils.appindcr(body_code, '   cn_message_pkg.debug(''Exception occurs in get_input: ''); ');
           cn_utils.appindcr(body_code, '   cn_message_pkg.debug(sqlerrm); ');
           cn_utils.appindcr(body_code, '   raise; ');
           cn_utils.appindcr(body_code, ' END; ');
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '  l_input := nvl(l_input,0); ');
           cn_utils.appindcr(body_code, '  x_mul_input_tbl('||
                             l_counter ||').rate_dim_sequence := '
                             || l_mul_input.rate_dim_sequence || ' ; ' );
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '    x_mul_input_tbl('|| l_counter ||
                             ').input_amount := l_input; ');
           cn_utils.appindcr(body_code, '    x_mul_input_tbl('|| l_counter ||
                             ').amount := l_input; ');

           IF (l_mul_input.split_flag <> 'N') THEN --IF g_split_flag <> 'N' THEN
              cn_utils.appindcr(body_code, '    x_mul_input_tbl('|| l_counter ||
                                ').base_amount := 0; ');
            ELSE
              cn_utils.appindcr(body_code, '    x_mul_input_tbl('|| l_counter ||
                                ').base_amount := l_input; ');
           END IF;


           cn_utils.appindcr(body_code, 'g_input_achieved := x_mul_input_tbl(1).input_amount; ');

           l_counter := l_counter+1;
        END LOOP;
        cn_utils.appindcr(body_code, ' END IF;  ');
     END IF;

     if (g_trx_group_code <> 'GROUP') then
       cn_utils.appindcr(body_code, 'g_input_achieved := x_mul_input_tbl(1).input_amount; ');
     end if;

     cn_utils.appindcr(body_code, 'EXCEPTION WHEN OTHERS THEN ');
     cn_utils.appindcr(body_code, '  if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
     cn_utils.appindcr(body_code, '     FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
     cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.get_input.exception'', ');
     cn_utils.appindcr(body_code, '	          sqlerrm); ');
     cn_utils.appindcr(body_code, '  end if; ');
     cn_utils.appindcr(body_code, '  cn_message_pkg.debug(''Exception occurs in get_input: ''); ');
     cn_utils.appindcr(body_code, '  cn_message_pkg.debug(sqlerrm); ');
     cn_utils.appindcr(body_code, '  raise; ');

     cn_utils.proc_end( procedure_name, 'N', body_code );
EXCEPTION
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.get_input.exception',
         	          sqlerrm);
    end if;
    raise;
END get_input;

--   construct the get_commission procedure for the formula package.
PROCEDURE get_commission (spec_code        IN OUT NOCOPY cn_utils.code_type,
                          body_code        IN OUT NOCOPY cn_utils.code_type )
IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;
    package_spec_id        cn_obj_packages_v.package_id%TYPE;
    x_repository_id        cn_repositories.repository_id%TYPE;

    l_output_sql_select        varchar2(8000);
    l_output_sql_from        varchar2(4000);
    l_output_sql_where   varchar2(4000) := 'WHERE 1=1 ';

    l_operator_position NUMBER;
    l_operator          VARCHAR2(1);

    l_output_sql_select_clob clob;
    l_output_sql_from_clob   clob;
    l_out_calc_sql_exp_id   cn_calc_sql_exps.calc_sql_exp_id%TYPE;

    CURSOR l_sql_select_from_csr IS
       SELECT calc_sql_exp_id,
              sql_select output_sql_select,
              sql_from output_sql_from
         FROM cn_calc_sql_exps_all
        WHERE calc_sql_exp_id = (SELECT output_exp_id
                                   FROM cn_calc_formulas_all
                                  WHERE calc_formula_id = g_formula_id
                                    AND org_id = g_org_id);

BEGIN
     procedure_name := 'get_commission';
     procedure_desc := 'This procedure is to calculate the commission';
     parameter_list := 'p_commission_line_id NUMBER, p_salesrep_id NUMBER, p_period_id NUMBER, p_quota_id NUMBER, p_srp_plan_assign_id NUMBER, p_rate NUMBER';
     IF g_trx_group_code = 'GROUP' THEN
       parameter_list := parameter_list || ', p_endofinterval_flag VARCHAR2, p_start_period_id NUMBER';
     END IF;

     proc_init(procedure_name, procedure_desc, parameter_list,'F', 'NUMBER', package_spec_id, x_repository_id,spec_code, body_code);

     cn_utils.appindcr(body_code, '  l_commission              NUMBER;');
     cn_utils.appindcr(body_code, '  l_output              NUMBER;');
     cn_utils.appendcr(body_code);
     cn_utils.appendcr(body_code, 'BEGIN');

     IF g_trx_group_code = 'INDIVIDUAL' THEN
        OPEN l_sql_select_from_csr;
        FETCH l_sql_select_from_csr INTO l_out_calc_sql_exp_id,l_output_sql_select_clob, l_output_sql_from_clob;
        CLOSE l_sql_select_from_csr;

        convert_clob_to_string(l_output_sql_select_clob, l_output_sql_select);
        l_output_sql_select := lower_str( 'select ' || l_output_sql_select );
        convert_clob_to_string(l_output_sql_from_clob, l_output_sql_from);
        l_output_sql_from := lower( 'from ' || l_output_sql_from );

        -- found out whether rateresult is used in output sql and what's the operator if any
        g_rate_flag := check_sql_stmt_existence(l_output_sql_select, 'rateresult');

        l_operator_position := search_delimiter_select(l_output_sql_select, 1);
        IF l_operator_position > 0 THEN
           l_operator := substr(l_output_sql_select, l_operator_position, 1);
        END IF;

        construct_sql_from_where(l_output_sql_select, l_output_sql_from, l_output_sql_where);
        handle_output_sql_select(l_output_sql_select, l_output_sql_from, l_output_sql_where);

        -- Added for 11.5.10 Performance Enhancments
        -- if other tables other than the standard tables are used in
        -- the output expression we will retain the select statment in
        -- otherwise Replace the select with a expression which uses
        -- the prefetched column values held in record variables

        IF g_other_tabused_tbl(l_out_calc_sql_exp_id) = 'Y' THEN
           split_long_sql( body_code, l_output_sql_select, 'SELECT');
           cn_utils.appindcr(body_code, '   into l_commission ');
           split_long_sql( body_code, l_output_sql_from, 'FROM');
           split_long_sql( body_code, l_output_sql_where||';', 'WHERE');
        ELSE
           IF g_non_plsql_func_used_tbl(l_out_calc_sql_exp_id) = 'N' THEN
              cn_utils.appindcr(body_code, 'l_commission := ');
           ELSE
              cn_utils.appindcr(body_code,'SELECT ');
           END IF;
           FOR i in 1..g_exp_tbl_dtls_tbl.COUNT LOOP
              IF  g_exp_tbl_dtls_tbl(i).CALC_SQL_EXP_ID = l_out_calc_sql_exp_id THEN
                 IF (g_exp_tbl_dtls_tbl(i).table_name <> 'CN_COMMISSION_LINES' AND
                     g_exp_tbl_dtls_tbl(i).table_name <> 'CN_COMMISSION_HEADERS' ) THEN
                     l_output_sql_select :=  REPLACE(l_output_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                   g_exp_tbl_dtls_tbl(i).column_name),
                                                                   g_exp_tbl_dtls_tbl(i).variable_name);
                 ELSIF (g_exp_tbl_dtls_tbl(i).table_name = 'CN_COMMISSION_HEADERS')THEN
            			/* column name from CN_COMMISSION_HEADERS could have been added with a 'CH_' in front of the column name
            			or not. To identify whether CH_ was added in front of the column name, use g_exp_tbl_dtls_tbl.alias_added
            			boolena varriable
            			*/
            			if (g_exp_tbl_dtls_tbl(i).alias_added = true) then
            	                       l_output_sql_select :=  REPLACE(l_output_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                               g_exp_tbl_dtls_tbl(i).column_name),
                                                                               'g_commission_rec'||'.'||g_exp_tbl_dtls_tbl(i).table_alias||'_'||g_exp_tbl_dtls_tbl(i).column_name);
            			else
            	                       l_output_sql_select :=  REPLACE(l_output_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                               g_exp_tbl_dtls_tbl(i).column_name),
                                                                               'g_commission_rec'||'.'||g_exp_tbl_dtls_tbl(i).column_name);
            			end if;
                 ELSE
                     l_output_sql_select :=  REPLACE(l_output_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                   g_exp_tbl_dtls_tbl(i).column_name),
                                                                   'g_commission_rec'||'.'||g_exp_tbl_dtls_tbl(i).column_name);
                 END IF;
              END IF;
           END LOOP;
           IF g_non_plsql_func_used_tbl(l_out_calc_sql_exp_id) = 'N' THEN
              -- fix for bug 3187576
              --cn_utils.appindcr(body_code,REPLACE(l_output_sql_select,'select',NULL)||';');
              split_long_sql( body_code, REPLACE(l_output_sql_select,'select',NULL)||';', 'SELECT');
           ELSE
              -- fix for bug 3187576
              --cn_utils.appindcr(body_code,REPLACE(l_output_sql_select,'select',NULL));
              split_long_sql( body_code, REPLACE(l_output_sql_select,'select',NULL), 'SELECT');
              cn_utils.appindcr(body_code, '   into l_commission ');
              cn_utils.appindcr(body_code, '   FROM  DUAL; ');
           END IF;
        END IF;

        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '   l_commission := nvl(l_commission, 0); ');

        IF g_itd_flag = 'Y' THEN
           IF g_pq_payment_flag OR g_spq_payment_flag THEN
              -- OR g_no_trx_flag THEN
              -- since itd_payment is used, we don't need to accumulate output_achieved
              cn_utils.appindcr(body_code, '  g_output_achieved := 0; ');
              cn_utils.appindcr(body_code, '  l_commission := l_commission - '|| ' g_commission_payed_itd ;' );
            ELSE -- we need to accumulate the output
              cn_utils.appindcr(body_code, '  g_output_achieved := l_commission; ');
              -- if x_rate is used in output
              IF g_rate_flag THEN
                 IF l_operator_position > 0 THEN
                    cn_utils.appindcr(body_code, '  l_commission := p_rate '||l_operator||
                                      ' (g_output_achieved_itd + g_output_achieved) - g_commission_payed_itd;');
                  ELSE
                    cn_utils.appindcr(body_code, '  l_commission := p_rate - '|| 'g_commission_payed_itd ;' );
                 END IF;
               ELSE
                 cn_utils.appindcr(body_code, '  l_commission := g_output_achieved_itd + g_output_achieved - g_commission_payed_itd ;');
              END IF;
           END IF;
        END IF;
     ELSE  -- group by case
        cn_utils.appindcr(body_code, '  IF p_commission_line_id IS NOT NULL THEN ');
        cn_utils.appendcr(body_code);
        -- construct the code for testing trx by trx
        g_trx_group_code := 'INDIVIDUAL';
        l_output_sql_where := 'WHERE 1=1 ';

        OPEN l_sql_select_from_csr;
        FETCH l_sql_select_from_csr INTO l_out_calc_sql_exp_id,l_output_sql_select_clob, l_output_sql_from_clob;
        CLOSE l_sql_select_from_csr;

        convert_clob_to_string(l_output_sql_select_clob, l_output_sql_select);
        l_output_sql_select := lower_str( 'select ' || l_output_sql_select );
        convert_clob_to_string(l_output_sql_from_clob, l_output_sql_from);
        l_output_sql_from := lower( 'from ' || l_output_sql_from );

        -- found out whether rateresult is used in output sql and what's the operator if any
        g_rate_flag := check_sql_stmt_existence(l_output_sql_select, 'rateresult');

        construct_sql_from_where(l_output_sql_select, l_output_sql_from, l_output_sql_where);
        handle_output_sql_select(l_output_sql_select, l_output_sql_from, l_output_sql_where);

        split_long_sql( body_code, l_output_sql_select, 'SELECT');
        cn_utils.appindcr(body_code, '   into l_commission ');
        split_long_sql( body_code, l_output_sql_from, 'FROM');
        split_long_sql( body_code, l_output_sql_where||';', 'WHERE');
        cn_utils.appindcr(body_code, '   l_commission := nvl(l_commission, 0); ');
        cn_utils.appindcr(body_code, '  ELSE                          ');
        cn_utils.appendcr(body_code);
        -- construct the code for computing the output and commission
        g_trx_group_code := 'GROUP';
        l_output_sql_where := 'WHERE 1=1 ';

        OPEN l_sql_select_from_csr;
        FETCH l_sql_select_from_csr INTO l_out_calc_sql_exp_id,l_output_sql_select_clob, l_output_sql_from_clob;
        CLOSE l_sql_select_from_csr;

        convert_clob_to_string(l_output_sql_select_clob, l_output_sql_select);
        l_output_sql_select := lower_str( 'select ' || l_output_sql_select );
        convert_clob_to_string(l_output_sql_from_clob, l_output_sql_from);
        l_output_sql_from := lower( 'from ' || l_output_sql_from );

        construct_sql_from_where(l_output_sql_select, l_output_sql_from, l_output_sql_where);
        handle_output_sql_select(l_output_sql_select, l_output_sql_from, l_output_sql_where);

        cn_utils.appindcr(body_code, ' BEGIN ');
        split_long_sql( body_code, l_output_sql_select, 'SELECT');
        cn_utils.appindcr(body_code, '   into l_commission ');
        split_long_sql( body_code, l_output_sql_from, 'FROM');
        split_long_sql( body_code, l_output_sql_where||';', 'WHERE');
        cn_utils.appindcr(body_code, '   l_commission := nvl(l_commission, 0); ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, 'EXCEPTION WHEN NO_DATA_FOUND THEN ');
        cn_utils.appindcr(body_code, '    l_commission := nvl(l_commission,0); ');
        cn_utils.appindcr(body_code, ' when others then ');
        cn_utils.appindcr(body_code, '   if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
        cn_utils.appindcr(body_code, '      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
        cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.get_commission.exception'', ');
        cn_utils.appindcr(body_code, '	          sqlerrm); ');
        cn_utils.appindcr(body_code, '   end if; ');
        cn_utils.appindcr(body_code, '   cn_message_pkg.debug(''Exception occurs in get_commission: ''); ');
        cn_utils.appindcr(body_code, '   cn_message_pkg.debug(sqlerrm); ');
        cn_utils.appindcr(body_code, '   raise; ');
        cn_utils.appindcr(body_code, 'END;');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '      g_output_achieved_ptd := '||'l_commission - g_output_achieved_itd ;' );
        cn_utils.appindcr(body_code, '      g_output_achieved_itd := l_commission; ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '  END IF; ' );
     END IF;

     cn_utils.appindcr(body_code, '  return l_commission; '        );

     cn_utils.appindcr(body_code, 'EXCEPTION WHEN OTHERS THEN ');
     cn_utils.appindcr(body_code, '   if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
     cn_utils.appindcr(body_code, '      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
     cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.get_commission.exception'', ');
     cn_utils.appindcr(body_code, '	          sqlerrm); ');
     cn_utils.appindcr(body_code, '   end if; ');
     cn_utils.appindcr(body_code, '   cn_message_pkg.debug(''Exception occurs in get_commission: ''); ');
     cn_utils.appindcr(body_code, '   cn_message_pkg.debug(sqlerrm); ');
     cn_utils.appindcr(body_code, '   raise; ');

     cn_utils.proc_end( procedure_name, 'N', body_code );
EXCEPTION
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.get_commission.exception',
         	          sqlerrm);
    end if;
    raise;
END get_commission;

--construct the get_perf procedure for the formula package.
PROCEDURE get_perf (spec_code        IN OUT NOCOPY cn_utils.code_type,
                    body_code        IN OUT NOCOPY cn_utils.code_type )
IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;
    package_spec_id        cn_obj_packages_v.package_id%TYPE;
    x_repository_id        cn_repositories.repository_id%TYPE;

    l_perf_sql_select        varchar2(8000);
    l_perf_sql_from        varchar2(4000);
    l_perf_sql_where   varchar2(4000) := 'WHERE 1=1 ';

    l_perf_sql_select_clob  clob;
    l_perf_sql_from_clob        clob;
    l_input_sql_exp_id          cn_calc_sql_exps.calc_sql_exp_id%TYPE;

    CURSOR l_perf_select_from_csr IS
        select sql_select, sql_from
          from cn_calc_sql_exps_all
          where calc_sql_exp_id = g_perf_measure_id;

    CURSOR l_input_select_from_csr IS
       SELECT calc_sql_exp_id,
              sql_select input_sql_select,
              sql_from input_sql_from
         FROM cn_calc_sql_exps_all
         WHERE calc_sql_exp_id = (SELECT calc_sql_exp_id
                                  FROM cn_formula_inputs_all
                                  WHERE calc_formula_id = g_formula_id
                                  AND org_id = g_org_id
                                  AND rate_dim_sequence = 1);

BEGIN
     procedure_name := 'get_perf';
     procedure_desc := 'This procedure is to accumulate performance measure.';
     parameter_list := 'p_commission_line_id NUMBER, p_salesrep_id NUMBER,' ||
       'p_period_id NUMBER, p_quota_id NUMBER, p_srp_plan_assign_id NUMBER, p_start_date DATE';
     IF g_trx_group_code = 'GROUP' THEN
        parameter_list := parameter_list || ', p_endofinterval_flag VARCHAR2 ' ||
          ', p_start_period_id NUMBER';
     END IF;

     IF g_formula_type = 'B' THEN
        parameter_list := parameter_list || ',p_credit_type_id NUMBER, '||
          'p_role_id NUMBER';
     END IF;

     proc_init(procedure_name, procedure_desc, parameter_list,'F', 'NUMBER' ,
               package_spec_id, x_repository_id,spec_code, body_code);

     cn_utils.appindcr(body_code, '  l_perf              NUMBER;');
     cn_utils.appendcr(body_code);
     cn_utils.appendcr(body_code, 'BEGIN');

     IF g_trx_group_code = 'INDIVIDUAL' THEN
        IF g_perf_measure_id IS NOT NULL THEN
           OPEN l_perf_select_from_csr;
           FETCH l_perf_select_from_csr
             INTO l_perf_sql_select_clob, l_perf_sql_from_clob;
           CLOSE l_perf_select_from_csr;

           convert_clob_to_string( l_perf_sql_select_clob, l_perf_sql_select);
           l_perf_sql_select := lower_str('select ' || l_perf_sql_select);
           convert_clob_to_string( l_perf_sql_from_clob, l_perf_sql_from);
           l_perf_sql_from := lower('from ' || l_perf_sql_from);

         ELSE   /* default to be the input with the lowest input_sequence */
           OPEN l_input_select_from_csr;
           FETCH l_input_select_from_csr
           INTO  l_input_sql_exp_id,l_perf_sql_select_clob, l_perf_sql_from_clob;
           CLOSE l_input_select_from_csr;

           convert_clob_to_string( l_perf_sql_select_clob, l_perf_sql_select);
           l_perf_sql_select := lower_str('select ' || l_perf_sql_select);
           convert_clob_to_string( l_perf_sql_from_clob, l_perf_sql_from);
           l_perf_sql_from := lower('from ' || l_perf_sql_from);
        END IF;


        construct_sql_from_where(l_perf_sql_select,
                                 l_perf_sql_from,
                                 l_perf_sql_where     );
        -- Added for 11.5.10 Performance Enhancments
        -- Replace the select with a expression which uses
        -- the prefetched column values held in record variables
        IF g_other_tabused_tbl(NVL(g_perf_measure_id,l_input_sql_exp_id)) = 'Y' THEN
           split_long_sql( body_code, l_perf_sql_select, 'SELECT');
           cn_utils.appindcr(body_code, '   into l_perf ');
           split_long_sql( body_code, l_perf_sql_from, 'FROM');
           split_long_sql( body_code, l_perf_sql_where||';', 'WHERE');
        ELSE
           IF g_non_plsql_func_used_tbl(NVL(g_perf_measure_id,l_input_sql_exp_id)) = 'N' THEN
                   cn_utils.appindcr(body_code, 'l_perf := ');
           ELSE
                   cn_utils.appindcr(body_code,'SELECT ');
           END IF;
           FOR i in 1..g_exp_tbl_dtls_tbl.COUNT LOOP
              IF  g_exp_tbl_dtls_tbl(i).CALC_SQL_EXP_ID = NVL(g_perf_measure_id,l_input_sql_exp_id) THEN
                 IF (g_exp_tbl_dtls_tbl(i).table_name <> 'CN_COMMISSION_LINES' AND
                   g_exp_tbl_dtls_tbl(i).table_name <> 'CN_COMMISSION_HEADERS' ) THEN
                       l_perf_sql_select :=  REPLACE(l_perf_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                g_exp_tbl_dtls_tbl(i).column_name),
                                                                g_exp_tbl_dtls_tbl(i).variable_name);
                 ELSIF (g_exp_tbl_dtls_tbl(i).table_name = 'CN_COMMISSION_HEADERS')THEN
            			/* column name from CN_COMMISSION_HEADERS could have been added with a 'CH_' in front of the column name
            			or not. To identify whether CH_ was added in front of the column name, use g_exp_tbl_dtls_tbl.alias_added
            			boolena varriable
            			*/
            			if (g_exp_tbl_dtls_tbl(i).alias_added = true) then
            	                       l_perf_sql_select :=  REPLACE(l_perf_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                               g_exp_tbl_dtls_tbl(i).column_name),
                                                                               'g_commission_rec'||'.'||g_exp_tbl_dtls_tbl(i).table_alias||'_'||g_exp_tbl_dtls_tbl(i).column_name);
            			else
            	                       l_perf_sql_select :=  REPLACE(l_perf_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                               g_exp_tbl_dtls_tbl(i).column_name),
                                                                               'g_commission_rec'||'.'||g_exp_tbl_dtls_tbl(i).column_name);
            			end if;
                 ELSE
                       l_perf_sql_select :=  REPLACE(l_perf_sql_select,lower(g_exp_tbl_dtls_tbl(i).table_alias||'.'||
                                                                g_exp_tbl_dtls_tbl(i).column_name),
                                                                'g_commission_rec'||'.'||g_exp_tbl_dtls_tbl(i).column_name);
                 END IF;
              END IF;
           END LOOP;
           IF g_non_plsql_func_used_tbl(NVL(g_perf_measure_id,l_input_sql_exp_id)) = 'N' THEN
              -- fix for bug 3187576
              --cn_utils.appindcr(body_code,REPLACE(l_perf_sql_select,'select',NULL)||';');
              split_long_sql( body_code, REPLACE(l_perf_sql_select,'select',NULL)||';', 'SELECT');
           ELSE
              -- fix for bug 3187576
              --cn_utils.appindcr(body_code,REPLACE(l_perf_sql_select,'select',NULL));
              split_long_sql( body_code, REPLACE(l_perf_sql_select,'select',NULL), 'SELECT');
              cn_utils.appindcr(body_code, '   into l_perf ');
              cn_utils.appindcr(body_code, '   FROM  DUAL; ');
           END IF;
        END IF;
        cn_utils.appindcr(body_code, '   l_perf := nvl(l_perf, 0); ');
     ELSE -- group by case
            cn_utils.appindcr(body_code, '  IF p_commission_line_id IS NOT NULL THEN ');
        cn_utils.appendcr(body_code);
        -- construct the code for testing trx by trx
        g_trx_group_code := 'INDIVIDUAL';
        l_perf_sql_where := 'WHERE 1=1 ';

        IF g_perf_measure_id IS NOT NULL THEN
           OPEN l_perf_select_from_csr;
           FETCH l_perf_select_from_csr
             INTO l_perf_sql_select_clob, l_perf_sql_from_clob;
           CLOSE l_perf_select_from_csr;

           convert_clob_to_string( l_perf_sql_select_clob, l_perf_sql_select);
           l_perf_sql_select := lower_str('select sum( ' || l_perf_sql_select || ' ) ' );
           convert_clob_to_string( l_perf_sql_from_clob, l_perf_sql_from);
           l_perf_sql_from := lower('from ' || l_perf_sql_from);

         ELSE   /* default to be the input with the lowest input_sequence */
           OPEN l_input_select_from_csr;
           FETCH l_input_select_from_csr
             INTO  l_input_sql_exp_id,l_perf_sql_select_clob, l_perf_sql_from_clob;
           CLOSE l_input_select_from_csr;

           convert_clob_to_string( l_perf_sql_select_clob, l_perf_sql_select);
           l_perf_sql_select := lower_str('select ' || l_perf_sql_select );
           convert_clob_to_string( l_perf_sql_from_clob, l_perf_sql_from);
           l_perf_sql_from := lower('from ' || l_perf_sql_from);

        END IF;
        construct_sql_from_where(l_perf_sql_select,
                                 l_perf_sql_from,
                                 l_perf_sql_where     );

        split_long_sql( body_code, l_perf_sql_select, 'SELECT');
        cn_utils.appindcr(body_code, '   into l_perf ');
        split_long_sql( body_code, l_perf_sql_from, 'FROM');
        split_long_sql( body_code, l_perf_sql_where||';', 'WHERE');

        cn_utils.appindcr(body_code, '   l_perf := nvl(l_perf, 0); ');

        cn_utils.appindcr(body_code, ' ELSE                          ');
        cn_utils.appendcr(body_code);
        -- construct the code for computing the perf
        g_trx_group_code := 'GROUP';
        l_perf_sql_where := 'WHERE 1=1 ';

        IF g_perf_measure_id IS NOT NULL THEN
           OPEN l_perf_select_from_csr;
           FETCH l_perf_select_from_csr
             INTO l_perf_sql_select_clob, l_perf_sql_from_clob;
           CLOSE l_perf_select_from_csr;

           convert_clob_to_string( l_perf_sql_select_clob, l_perf_sql_select);
           l_perf_sql_select := lower_str('select sum( ' || l_perf_sql_select || ' ) ' );
           convert_clob_to_string( l_perf_sql_from_clob, l_perf_sql_from);
           l_perf_sql_from := lower('from ' || l_perf_sql_from);

         ELSE   /* default to be the input with the lowest input_sequence */
           OPEN l_input_select_from_csr;
           FETCH l_input_select_from_csr
             INTO  l_input_sql_exp_id,l_perf_sql_select_clob, l_perf_sql_from_clob;
           CLOSE l_input_select_from_csr;

           convert_clob_to_string( l_perf_sql_select_clob, l_perf_sql_select);
           l_perf_sql_select := lower_str('select ' || l_perf_sql_select );
           convert_clob_to_string( l_perf_sql_from_clob, l_perf_sql_from);
           l_perf_sql_from := lower('from ' || l_perf_sql_from);
        END IF;
        construct_sql_from_where(l_perf_sql_select,
                                 l_perf_sql_from,
                                 l_perf_sql_where     );

        cn_utils.appindcr(body_code, '   BEGIN ');
        split_long_sql( body_code, l_perf_sql_select, 'SELECT');
        cn_utils.appindcr(body_code, '   into l_perf ');
        split_long_sql( body_code, l_perf_sql_from, 'FROM');
        split_long_sql( body_code, l_perf_sql_where||';', 'WHERE');
        cn_utils.appindcr(body_code, '   l_perf := nvl(l_perf, 0); ');
        cn_utils.appindcr(body_code, '   EXCEPTION WHEN NO_DATA_FOUND THEN ');
        cn_utils.appindcr(body_code, '      l_perf := nvl(l_perf,0); ');
        cn_utils.appindcr(body_code, '      WHEN others then ');
        cn_utils.appindcr(body_code, '        if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
        cn_utils.appindcr(body_code, '          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
        cn_utils.appindcr(body_code, '             ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.get_perf.exception'', ');
        cn_utils.appindcr(body_code, '	            sqlerrm); ');
        cn_utils.appindcr(body_code, '        end if; ');
        cn_utils.appindcr(body_code, '        cn_message_pkg.debug(''Exception occurs in get_perf: ''); ');
        cn_utils.appindcr(body_code, '        cn_message_pkg.debug(sqlerrm); ');
        cn_utils.appindcr(body_code, '        raise; ');
        cn_utils.appindcr(body_code, '   END;');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '  END IF;  ');
     END IF;
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '  return l_perf;        ');

     cn_utils.appindcr(body_code, 'EXCEPTION WHEN OTHERS THEN ');
     cn_utils.appindcr(body_code, '   if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
     cn_utils.appindcr(body_code, '      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
     cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.get_perf.exception'', ');
     cn_utils.appindcr(body_code, '	          sqlerrm); ');
     cn_utils.appindcr(body_code, '   end if; ');
     cn_utils.appindcr(body_code, '   cn_message_pkg.debug(''Exception occurs in get_perf: ''); ');
     cn_utils.appindcr(body_code, '   cn_message_pkg.debug(sqlerrm); ');
     cn_utils.appindcr(body_code, '   raise; ');

     cn_utils.proc_end( procedure_name, 'N', body_code );
EXCEPTION
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.get_perf.exception',
         	          sqlerrm);
    end if;
    raise;
END get_perf;

--   construct the call to cn_formula_common_pkg.calculate_init;
PROCEDURE calc_init (spec_code        IN OUT NOCOPY cn_utils.code_type,
                     body_code        IN OUT NOCOPY cn_utils.code_type )
IS
BEGIN
    cn_utils.appendcr(body_code);
    cn_utils.appindcr(body_code, '  cn_formula_common_pkg.calculate_init( p_srp_plan_assign_id,' ||' p_salesrep_id, ' );
    cn_utils.appindcr(body_code, '              p_period_id, p_quota_id,  p_start_date, ');
    cn_utils.appindcr(body_code, '                     p_process_all_flag,  g_intel_calc_flag, g_calc_type,');
    cn_utils.appindcr(body_code, '              g_trx_group_code, g_itd_flag, g_rollover_flag,');
    cn_utils.appindcr(body_code, '              g_commission_payed_ptd, g_commission_payed_itd,');
    cn_utils.appindcr(body_code, '              g_input_achieved_ptd, g_input_achieved_itd,');
    cn_utils.appindcr(body_code, '              g_output_achieved_ptd, g_output_achieved_itd,');
    cn_utils.appindcr(body_code, '              g_perf_achieved_ptd, g_perf_achieved_itd,');
    cn_utils.appindcr(body_code, '              g_select_status_flag);');
    cn_utils.appendcr(body_code);

    -- resolve pe references
    IF (g_pe_reference_tbl.COUNT > 0) THEN
       FOR i IN g_pe_reference_tbl.first..g_pe_reference_tbl.last LOOP
          cn_utils.appendcr(body_code, '  select ' || REPLACE(g_pe_reference_tbl(i), g_pe_id_tbl(i)||'PE.', ''));
          cn_utils.appendcr(body_code, '    into g_' || REPLACE(g_pe_reference_tbl(i), '.', '_'));
          cn_utils.appendcr(body_code, '    from cn_srp_period_quotas');
          cn_utils.appendcr(body_code, '   where srp_plan_assign_id = p_srp_plan_assign_id');
          cn_utils.appendcr(body_code, '     and period_id = p_period_id');
          cn_utils.appendcr(body_code, '     and quota_id = ' || g_pe_id_tbl(i) || ';');
          cn_utils.appendcr(body_code);
       END LOOP;
    END IF;

END calc_init;

--   construct the call to cn_formula_common_pkg.calculate_roll;
PROCEDURE calc_roll (spec_code        IN OUT NOCOPY cn_utils.code_type,
                     body_code        IN OUT NOCOPY cn_utils.code_type )
IS
     l_sql_select VARCHAR2(8000);

     CURSOR exps IS
        SELECT dbms_lob.substr(sql_select) sql_select
          FROM cn_calc_sql_exps_all
          WHERE calc_sql_exp_id = (SELECT calc_sql_exp_id
                                    FROM cn_formula_inputs_all
                                   WHERE calc_formula_id = g_formula_id
                                   AND org_id = g_org_id
                                   AND rate_dim_sequence = (SELECT MIN(rate_dim_sequence)
                                                            FROM cn_formula_inputs_all
                                                            WHERE calc_formula_id = g_formula_id
                                                            AND org_id = g_org_id
                                                            AND cumulative_flag = 'Y'));
BEGIN
   OPEN exps;
   FETCH exps INTO l_sql_select;
   CLOSE exps;

   IF (g_cumulative_flag = 'Y') THEN
      IF (instr(l_sql_select, '/CSQA.TARGET', 1, 1) > 0 OR
          instr(l_sql_select, '/(CSQA.TARGET+CSPQ.TOTAL_ROLLOVER)', 1, 1) > 0 OR
          instr(l_sql_select, '/(CSPQ.TOTAL_ROLLOVER+CSQA.TARGET)', 1, 1) > 0) THEN
         cn_utils.appendcr(body_code);
         cn_utils.appendcr(body_code, ' SELECT csqa.target + nvl(cspq.total_rollover, 0)');
         cn_utils.appendcr(body_code, '   INTO l_rollover ');
         cn_utils.appendcr(body_code, '   FROM cn_srp_quota_assigns_all csqa, cn_srp_period_quotas_all cspq ');
         cn_utils.appendcr(body_code, '  WHERE csqa.srp_plan_assign_id = p_srp_plan_assign_id ');
         cn_utils.appendcr(body_code, '    AND csqa.quota_id = p_quota_id ');
         cn_utils.appendcr(body_code, '    AND cspq.srp_plan_assign_id = p_srp_plan_assign_id ');
         cn_utils.appendcr(body_code, '    AND cspq.quota_id = p_quota_id ');
         cn_utils.appendcr(body_code, '    AND cspq.period_id = p_period_id; ');
         cn_utils.appendcr(body_code);
         cn_utils.appendcr(body_code, ' l_rollover := l_rollover * (1 - g_input_achieved_itd(' || g_cumulative_input_no ||') ); ');

       ELSIF (instr(l_sql_select, '/CSPQ.ITD_TARGET', 1, 1) > 0 OR
              instr(l_sql_select, '/(CSPQ.ITD_TARGET+CSPQ.TOTAL_ROLLOVER)', 1, 1) > 0 OR
              instr(l_sql_select, '/(CSPQ.TOTAL_ROLLOVER+CSPQ.ITD_TARGET)', 1, 1) > 0) THEN
         cn_utils.appendcr(body_code);
         cn_utils.appendcr(body_code, ' SELECT cspq.itd_target + nvl(cspq.total_rollover, 0)');
         cn_utils.appendcr(body_code, '   INTO l_rollover ');
         cn_utils.appendcr(body_code, '   FROM cn_srp_period_quotas_all cspq ');
         cn_utils.appendcr(body_code, '  WHERE cspq.srp_plan_assign_id = p_srp_plan_assign_id ');
         cn_utils.appendcr(body_code, '    AND cspq.quota_id = p_quota_id ');
         cn_utils.appendcr(body_code, '    AND cspq.period_id = p_period_id; ');
         cn_utils.appendcr(body_code);
         cn_utils.appendcr(body_code, ' l_rollover := l_rollover * (1 - g_input_achieved_itd(' || g_cumulative_input_no ||') ); ');

       ELSIF (g_itd_flag = 'Y') THEN
         cn_utils.appendcr(body_code);
         cn_utils.appendcr(body_code, ' SELECT cspq.itd_target - g_input_achieved_itd(' || g_cumulative_input_no || ') ');
         cn_utils.appendcr(body_code, '   INTO l_rollover ');
         cn_utils.appendcr(body_code, '   FROM cn_srp_period_quotas_all cspq ');
         cn_utils.appendcr(body_code, '  WHERE cspq.srp_plan_assign_id = p_srp_plan_assign_id ');
         cn_utils.appendcr(body_code, '    AND cspq.quota_id = p_quota_id ');
         cn_utils.appendcr(body_code, '    AND cspq.period_id = p_period_id; ');
       ELSE
         cn_utils.appendcr(body_code);
         cn_utils.appendcr(body_code, ' SELECT csqa.target - g_input_achieved_itd(' || g_cumulative_input_no || ') ');
         cn_utils.appendcr(body_code, '   INTO l_rollover ');
         cn_utils.appendcr(body_code, '   FROM cn_srp_quota_assigns_all csqa ');
         cn_utils.appendcr(body_code, '  WHERE csqa.srp_plan_assign_id = p_srp_plan_assign_id ');
         cn_utils.appendcr(body_code, '    AND csqa.quota_id = p_quota_id; ');

      END IF;
   END IF;

   cn_utils.appindcr(body_code, '  cn_formula_common_pkg.calculate_roll( p_salesrep_id,'||
                     'p_period_id, p_quota_id,');
   cn_utils.appindcr(body_code, '             p_srp_plan_assign_id,  p_calc_type,');
   cn_utils.appindcr(body_code, '             g_input_achieved_ptd, g_input_achieved_itd,');
   cn_utils.appindcr(body_code, '             g_output_achieved_ptd, g_output_achieved_itd,');
   cn_utils.appindcr(body_code, '             g_perf_achieved_ptd, g_perf_achieved_itd, ');
   cn_utils.appindcr(body_code, '             l_rollover );');
   cn_utils.appendcr(body_code);
END calc_roll;

--   construct the cursor for individual case
PROCEDURE individual_cursor (spec_code        IN OUT NOCOPY cn_utils.code_type,
                             body_code        IN OUT NOCOPY cn_utils.code_type )         IS
BEGIN
    cn_utils.appendcr(body_code);
    cn_utils.appindcr(body_code, '  CURSOR l_lines_csr IS  ');
    cn_utils.appindcr(body_code, '    SELECT ');

    -- Added for 11.5.10 Performance Enhancments
    -- Add column names of CH and CL which are used in the input/output/perf expression
    FOR i IN g_comm_tbl_clmn_nms_tbl.FIRST..g_comm_tbl_clmn_nms_tbl.LAST LOOP
      IF i <> g_comm_tbl_clmn_nms_tbl.LAST THEN
          cn_utils.appindcr(body_code ,'         '||g_comm_tbl_clmn_nms_tbl(i).table_alias||'.'||g_comm_tbl_clmn_nms_tbl(i).column_name||',');
      ELSE
          cn_utils.appindcr(body_code ,'         '||g_comm_tbl_clmn_nms_tbl(i).table_alias||'.'||g_comm_tbl_clmn_nms_tbl(i).column_name);
      END IF;
    END LOOP;

    -- Changed for 11.5.10 Performance Enhancments
    -- only if CH is used add the table in the from clause
    IF g_ch_flag THEN
        cn_utils.appindcr(body_code, '    FROM cn_commission_lines_all cl, cn_commission_headers_all ch ');
    ELSE
        cn_utils.appindcr(body_code, '    FROM cn_commission_lines_all cl');
    END IF;

    cn_utils.appindcr(body_code, '    WHERE cl.credited_salesrep_id = p_salesrep_id            ');
    cn_utils.appindcr(body_code, '      AND cl.quota_id = p_quota_id                           ');
    cn_utils.appindcr(body_code, '      AND cl.srp_plan_assign_id = p_srp_plan_assign_id              ');
    cn_utils.appindcr(body_code, '      AND cl.processed_period_id = p_period_id            ');
    cn_utils.appindcr(body_code, '      AND cl.processed_date >= p_start_date               ');


    -- Changed for 11.5.10 Performance Enhancments
    -- only if CH is used add the table in the where clause
    IF g_ch_flag THEN
      cn_utils.appindcr(body_code, '      AND ch.commission_header_id = cl.commission_header_id');
    END IF;
    cn_utils.appindcr(body_code, '      AND substr(cl.pre_processed_code, 4,1) = ''C''  ');
    cn_utils.appindcr(body_code, '      AND ( (g_select_status_flag = ''PCX'' and              ');
    cn_utils.appindcr(body_code, '              cl.status in (''POP'', ''CALC'', ''XCALC'') )   ');
    cn_utils.appindcr(body_code, '         OR (g_select_status_flag = ''P'' and cl.status = ''POP'') )');
    cn_utils.appindcr(body_code, '      AND (( g_calc_type = ''FORECAST'' and                  ');
    cn_utils.appindcr(body_code, '              cl.trx_type = ''FORECAST'')                 ');
    cn_utils.appindcr(body_code, '           OR (g_calc_type = ''BONUS'' and  cl.trx_type = ''BONUS'' )');
    cn_utils.appindcr(body_code, '           OR (g_calc_type = ''COMMISSION'' and              ');
    cn_utils.appindcr(body_code, '               cl.trx_type NOT IN (''BONUS'',''FORECAST'',''GRP'') )) ');
    cn_utils.appindcr(body_code, '    ORDER by cl.processed_date        asc ');
    cn_utils.appindcr(body_code, '              ,cl.commission_line_id      asc ');
    cn_utils.appindcr(body_code, '           ;                              ');
    cn_utils.appendcr(body_code);
END individual_cursor;

--   construct the code to update global variables
PROCEDURE update_variables(spec_code        IN OUT NOCOPY cn_utils.code_type,
                           body_code        IN OUT NOCOPY cn_utils.code_type )
IS
BEGIN
     cn_utils.appendcr(body_code);
     IF g_itd_flag = 'Y' THEN
        cn_utils.appindcr(body_code, '   g_output_achieved_ptd := g_output_achieved_ptd + g_output_achieved ;' );
        cn_utils.appindcr(body_code, '   g_output_achieved_itd := g_output_achieved_itd + g_output_achieved; ' );
     END IF;
     cn_utils.appindcr(body_code, '   g_perf_achieved_ptd := g_perf_achieved_ptd+ l_perf; ');
     cn_utils.appindcr(body_code, '   g_perf_achieved_itd := g_perf_achieved_itd+ l_perf; ');

     FOR i IN 1..g_number_dim LOOP
        cn_utils.appindcr(body_code, '   g_input_achieved_ptd('||i||') := g_input_achieved_ptd('||i||') + l_input('||i||');        ');
        cn_utils.appindcr(body_code, '   g_input_achieved_itd('||i||') := g_input_achieved_itd('||i||') + l_input('||i||');        ');
     END LOOP;

     cn_utils.appindcr(body_code, '   g_commission_payed_ptd := g_commission_payed_ptd + l_commission;        ');
     cn_utils.appindcr(body_code, '   g_commission_payed_itd := g_commission_payed_itd + l_commission;        ');
     cn_utils.appendcr(body_code);
END update_variables;

--   construct the calculate_quota procdure which will be invoked from the dispatcher in calc engine
PROCEDURE calculate_quota (spec_code        IN OUT NOCOPY cn_utils.code_type,
                           body_code        IN OUT NOCOPY cn_utils.code_type )
IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;
    package_spec_id        cn_obj_packages_v.package_id%TYPE;
    x_repository_id        cn_repositories.repository_id%TYPE;

    l_rate_dim_sequence  NUMBER;
    l_output_sql_select        varchar2(8000);
    l_output_sql_select_clob clob;


    l_input_sql_select        varchar2(8000);
    l_input_sql_from        varchar2(4000);
    l_input_sql_where   varchar2(4000) := 'WHERE 1=1 ';
    l_input_sql_select_clob clob;
    l_input_sql_from_clob   clob;

    l_operator_position NUMBER;
    l_operator          VARCHAR2(1);

    l_counter NUMBER(15);
    l_variable_declaration VARCHAR2(400);
    l_table_object_id       cn_objects.object_id%type;

    CURSOR itd_inputs IS
       SELECT calc_sql_exp_id, rate_dim_sequence, split_flag, cumulative_flag
         FROM cn_formula_inputs_all
        WHERE calc_formula_id = g_formula_id
          AND org_id = g_org_id
        ORDER BY rate_dim_sequence;
BEGIN
     procedure_name := 'calculate_quota';
     procedure_desc := 'This procedure is the hook to the calculation engine';

     parameter_list := 'p_srp_plan_assign_id NUMBER, p_salesrep_id NUMBER, p_period_id NUMBER, ';
     parameter_list := parameter_list || 'p_start_date DATE, p_quota_id NUMBER, ';
     parameter_list := parameter_list || 'p_process_all_flag VARCHAR2, p_intel_calc_flag VARCHAR2, ';
     parameter_list := parameter_list || ' p_calc_type VARCHAR2, p_credit_type_id NUMBER, x_latest_processed_date OUT NOCOPY DATE  ';

     proc_init(procedure_name, procedure_desc, parameter_list,
               'P', null , package_spec_id, x_repository_id,
               spec_code, body_code);

     cn_utils.appindcr(body_code, '  l_mul_input_tbl            cn_formula_common_pkg.mul_input_tbl_type; ');
     cn_utils.appindcr(body_code, '  l_rate                     NUMBER;');
     cn_utils.appindcr(body_code, '  l_rate_tier_id             NUMBER;');
     cn_utils.appindcr(body_code, '  l_tier_split               NUMBER;');
     cn_utils.appindcr(body_code, '  l_input                    cn_formula_common_pkg.num_table_type; ');
     cn_utils.appindcr(body_code, '  l_commission               NUMBER; ');
     cn_utils.appindcr(body_code, '  l_perf                     NUMBER; ');
     cn_utils.appindcr(body_code, '  l_itd_target               NUMBER; ');
     cn_utils.appindcr(body_code, '  l_itd_payment              NUMBER; ');
     cn_utils.appindcr(body_code, '  l_rollover                 NUMBER := 0; ');
     cn_utils.appindcr(body_code, '  l_debug_flag               VARCHAR2(1) := fnd_profile.value(''CN_DEBUG''); ');
     cn_utils.appindcr(body_code, '  l_processed_date           DATE; ');
     cn_utils.appindcr(body_code, '  l_error_reason             VARCHAR2(150); ');
     cn_utils.appindcr(body_code, '  l_name                     VARCHAR2(255); ');
     cn_utils.appindcr(body_code, '  l_trx_rec_old              cn_formula_common_pkg.trx_rec_type; ');
     cn_utils.appindcr(body_code, '  l_trx_rec_new              cn_formula_common_pkg.trx_rec_type; ');
     cn_utils.appindcr(body_code, '  l_trx_rec_null             cn_formula_common_pkg.trx_rec_type; ');

     IF g_trx_group_code = 'GROUP' THEN
        cn_utils.appindcr(body_code, '  l_endofinterval_flag       VARCHAR2(1); ');
        cn_utils.appindcr(body_code, '  l_start_period_id          NUMBER(15); ');
        cn_utils.appindcr(body_code, '  l_grp_trx_rec              cn_formula_common_pkg.trx_rec_type; ');
     END IF;
     cn_utils.appendcr(body_code);

     --  constrcut the cursor to loop through trxs
     IF (NOT(g_no_trx_flag)) THEN
        individual_cursor(spec_code, body_code);
     END IF;


     -- Added for 11.5.10 Performance Enhancments
     -- Declare cursors which will fetch all columns of tables
     -- used in input/output/perf expressions.
     IF g_trx_group_code = 'INDIVIDUAL' THEN
        l_table_object_id := g_uniq_tbl_names_tbl.FIRST;
        FOR l_counter IN 1..g_uniq_tbl_names_tbl.COUNT LOOP
           IF INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_LINES') =  0  AND
              INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_HEADERS') = 0 THEN
               IF LENGTH(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL)) > 24 THEN
                   l_variable_declaration := 'l_'||lower(substr(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL),1,24))||'_cur';
               ELSE
                   l_variable_declaration := 'l_'||lower(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL)) ||'_cur';
               END IF;
               cn_utils.appendcr(body_code);
               cn_utils.appindcr(body_code, '  CURSOR '||l_variable_declaration||'  IS');
               l_input_sql_where  := 'WHERE 1=1 ';
               l_input_sql_select := lower_str( '    select ' ||g_uniq_tbl_names_tbl(l_table_object_id).column_name_list);
               l_input_sql_from := lower( '   from ' ||g_uniq_tbl_names_tbl(l_table_object_id).table_name||' '||
                                                    g_uniq_tbl_names_tbl(l_table_object_id).table_alias);
               construct_sql_from_where (l_input_sql_select,
                                             l_input_sql_from,
                                         l_input_sql_where );
               --split_long_sql( body_code, l_input_sql_select, 'SELECT');
               cn_utils.appindcr(body_code, 'SELECT * ');

               split_long_sql( body_code, l_input_sql_from, 'FROM');
               split_long_sql( body_code, l_input_sql_where||';', 'WHERE');
           END IF;
           l_table_object_id :=  g_uniq_tbl_names_tbl.NEXT(l_table_object_id);
        END LOOP;
     END IF;


     cn_utils.appendcr(body_code);
     cn_utils.appendcr(body_code, 'BEGIN');
     cn_utils.appindcr(body_code, '  g_intel_calc_flag := p_intel_calc_flag;');
     cn_utils.appindcr(body_code, '  g_calc_type := p_calc_type;');
     calc_init(spec_code, body_code);

     FOR i IN 1..g_number_dim LOOP
   	  cn_utils.appindcr(body_code, '  l_input('||i||') := 0;        ');
     END LOOP;

     -- Added for 11.5.10 Performance Enhancments
     -- Declare open fetch statment which will fetch all columns of tables
     -- used in input/output/perf expressions.into global variables
     IF g_trx_group_code = 'INDIVIDUAL' THEN
        l_table_object_id := g_uniq_tbl_names_tbl.FIRST;
        FOR l_counter IN 1..g_uniq_tbl_names_tbl.COUNT LOOP
           IF INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_LINES') =  0  AND
              INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_HEADERS') = 0 THEN

               IF LENGTH(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL)) > 24 THEN
                   l_variable_declaration := 'l_'||lower(substr(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL),1,24))||'_cur';
               ELSE
                   l_variable_declaration := 'l_'||lower(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL)) ||'_cur';
               END IF;
               cn_utils.appendcr(body_code);
               cn_utils.appindcr(body_code, '  OPEN '||l_variable_declaration||' ;' );
               cn_utils.appindcr(body_code, '  FETCH '||l_variable_declaration||'  INTO ' ||g_uniq_tbl_names_tbl(l_table_object_id).variable_name||' ;' );

               cn_utils.appindcr(body_code, '  CLOSE '||l_variable_declaration||' ;' );

            END IF;
            l_table_object_id :=  g_uniq_tbl_names_tbl.NEXT(l_table_object_id);
         END LOOP;
      END IF;


     IF (g_trx_group_code = 'INDIVIDUAL' AND NOT(g_no_trx_flag)) THEN
        -- for individual case we don't need to accumulate output_achieved
        cn_utils.appindcr(body_code, '  Open l_lines_csr; ');
        cn_utils.appindcr(body_code, '  LOOP ');
        cn_utils.appindcr(body_code, '   l_trx_rec_new := l_trx_rec_null; ');
        cn_utils.appindcr(body_code, '   FETCH l_lines_csr into g_commission_rec; ');
        cn_utils.appindcr(body_code, '     EXIT WHEN l_lines_csr%notfound; ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '   BEGIN ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.COMMISSION_LINE_ID    :=  g_commission_rec.COMMISSION_LINE_ID;        ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.COMMISSION_HEADER_ID  :=  g_commission_rec.COMMISSION_HEADER_ID;        ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.SALESREP_ID           :=  g_commission_rec.CREDITED_SALESREP_ID;         ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.SRP_PLAN_ASSIGN_ID    :=  g_commission_rec.SRP_PLAN_ASSIGN_ID;          ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.QUOTA_ID              :=  g_commission_rec.QUOTA_ID;                    ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.CREDIT_TYPE_ID        :=  g_commission_rec.CREDIT_TYPE_ID;              ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.PROCESSED_DATE        :=  g_commission_rec.PROCESSED_DATE;              ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.PROCESSED_PERIOD_ID   :=  g_commission_rec.PROCESSED_PERIOD_ID;         ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.PAY_PERIOD_ID         :=  g_commission_rec.PAY_PERIOD_ID;               ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.COMMISSION_AMOUNT     :=  g_commission_rec.COMMISSION_AMOUNT;           ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.COMMISSION_RATE       :=  g_commission_rec.COMMISSION_RATE;             ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.RATE_TIER_ID          :=  g_commission_rec.RATE_TIER_ID;                ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.TIER_SPLIT            :=  g_commission_rec.TIER_SPLIT;                  ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.INPUT_ACHIEVED        :=  g_commission_rec.INPUT_ACHIEVED;              ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.OUTPUT_ACHIEVED       :=  g_commission_rec.OUTPUT_ACHIEVED;             ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.PERF_ACHIEVED         :=  g_commission_rec.PERF_ACHIEVED;               ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.POSTING_STATUS        :=  g_commission_rec.POSTING_STATUS;              ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.PENDING_STATUS        :=  g_commission_rec.PENDING_STATUS;              ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.CREATED_DURING        :=  g_commission_rec.CREATED_DURING;              ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.TRX_TYPE              :=  g_commission_rec.TRX_TYPE;                    ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.ERROR_REASON          :=  g_commission_rec.ERROR_REASON;               ');
        cn_utils.appindcr(body_code ,'     l_trx_rec_old.STATUS                   :=  g_commission_rec.STATUS;                         ');

        cn_utils.appindcr(body_code, '     get_input(l_trx_rec_old.commission_line_id, p_salesrep_id, ');
        cn_utils.appindcr(body_code, '                p_period_id, p_quota_id, ');
        cn_utils.appindcr(body_code, '                p_srp_plan_assign_id, l_trx_rec_old.processed_date, ');
        cn_utils.appindcr(body_code, '                l_mul_input_tbl  );');

        cn_utils.appindcr(body_code, '     if (l_debug_flag = ''Y'') then');
        cn_utils.appindcr(body_code, '       cn_message_pkg.debug('' ''); ');
        cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Transaction (line ID='' || l_trx_rec_old.commission_line_id||'')'' );');
        FOR i IN 1..g_number_dim LOOP
           cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Input='' || l_mul_input_tbl('||i||').amount || l_mul_input_tbl('||i||').input_string );');
        END LOOP;
        cn_utils.appindcr(body_code, '     end if; ');
        cn_utils.appendcr(body_code);

        IF g_rate_flag THEN
           cn_utils.appindcr(body_code, '     cn_formula_common_pkg.get_rates( p_salesrep_id, p_srp_plan_assign_id,');
           cn_utils.appindcr(body_code, '                 p_period_id, p_quota_id , g_split_flag,g_itd_flag, ' );
           cn_utils.appindcr(body_code, '                 l_trx_rec_old.processed_date, g_number_dim,l_mul_input_tbl, ');
           cn_utils.appindcr(body_code, '                 g_formula_id,l_rate, l_rate_tier_id, l_tier_split ); ');

           cn_utils.appindcr(body_code, '     if (l_debug_flag = ''Y'') then');
           cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Commission rate='' || l_rate);');
           cn_utils.appindcr(body_code, '     end if; ');
        END IF;

        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '     l_commission := get_commission( l_trx_rec_old.commission_line_id,');
        cn_utils.appindcr(body_code, '                  p_salesrep_id, p_period_id, p_quota_id, ');
        cn_utils.appindcr(body_code, '                  p_srp_plan_assign_id,        l_rate); ');
        cn_utils.appindcr(body_code, '     if (l_debug_flag = ''Y'') then');
        cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Output='' || l_commission);');
        cn_utils.appindcr(body_code, '     end if; ');

        IF g_perf_input_expr_seq >0 THEN
               cn_utils.appindcr(body_code,'       l_perf :=l_mul_input_tbl('||g_perf_input_expr_seq||').input_amount;  ');

        ELSIF g_perf_measure_id IS  NULL THEN
               cn_utils.appindcr(body_code,'       l_perf :=l_mul_input_tbl('||1||').input_amount;  ');

        ELSE
                cn_utils.appindcr(body_code, '     l_perf := get_perf(l_trx_rec_old.commission_line_id, p_salesrep_id,');
                cn_utils.appindcr(body_code, '                          p_period_id, p_quota_id, ');
                cn_utils.appindcr(body_code, '                          p_srp_plan_assign_id, l_trx_rec_old.processed_date);');

                cn_utils.appindcr(body_code, '     if (l_debug_flag = ''Y'') then');
                cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Performance measure='' || l_perf);');
                cn_utils.appindcr(body_code, '     end if; ');
        END IF;

        FOR i IN 1..g_number_dim LOOP
           cn_utils.appindcr(body_code, '       l_input('||i||') := l_mul_input_tbl('||i||').input_amount;        ');
        END LOOP;

        cn_utils.appindcr(body_code, '     x_latest_processed_date := l_trx_rec_old.processed_date;    ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '     l_trx_rec_new.status := ''CALC''; ');
        cn_utils.appindcr(body_code, '     l_trx_rec_new.credit_type_id := p_credit_type_id; ');
        cn_utils.appindcr(body_code, '     l_trx_rec_new.commission_amount := l_commission; ');
        cn_utils.appindcr(body_code, '     l_trx_rec_new.commission_rate := l_rate; ');
        cn_utils.appindcr(body_code, '     l_trx_rec_new.rate_tier_id := l_rate_tier_id ; ');
        cn_utils.appindcr(body_code, '     l_trx_rec_new.tier_split := l_tier_split ; ');
        IF g_number_dim > 1 THEN
           cn_utils.appindcr(body_code, '     l_trx_rec_new.input_achieved := l_input(1) ; ');
         ELSE
           cn_utils.appindcr(body_code, '     l_trx_rec_new.input_achieved := l_input(1) ; ');
        END IF;
        IF g_itd_flag = 'Y' THEN
           cn_utils.appindcr(body_code, '     l_trx_rec_new.output_achieved := g_output_achieved ; ');
         ELSE
           --  output_achieved = 0 since no need to accumulate output for individual non itd case
           cn_utils.appindcr(body_code, '     l_trx_rec_new.output_achieved := 0 ; ');
        END IF;
        cn_utils.appindcr(body_code, '     l_trx_rec_new.perf_achieved := l_perf ; ');
        cn_utils.appendcr(body_code);
        -- update package variables
        update_variables(spec_code, body_code);
        cn_utils.appindcr(body_code, '   EXCEPTION when others then        ');
        cn_utils.appindcr(body_code, '     l_trx_rec_new.error_reason := substr(sqlerrm,1,150); ');
        cn_utils.appindcr(body_code, '     l_trx_rec_new.status := ''XCALC'' ; ');
        cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Exception occurs while calculating commission line: ''); ');
        cn_utils.appindcr(body_code, '     cn_message_pkg.debug(sqlerrm); ');
        cn_utils.appindcr(body_code, '   END;   ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '   cn_formula_common_pkg.update_trx(l_trx_rec_old, l_trx_rec_new) ; ');
        cn_utils.appindcr(body_code, '  END LOOP;');
        cn_utils.appindcr(body_code, '  CLOSE l_lines_csr; ');
        cn_utils.appendcr(body_code);

        -- need to create 'ITD' trx if there is no calc trx in this period
        IF g_itd_flag = 'Y' THEN
           cn_utils.appindcr(body_code, '  IF cn_formula_common_pkg.check_itd_calc_trx( p_salesrep_id, ');
           cn_utils.appindcr(body_code, '            p_srp_plan_assign_id, p_period_id, p_quota_id ) = FALSE THEN ');
           cn_utils.appindcr(body_code, '    BEGIN ');
           -- get input
           cn_utils.appendcr(body_code);

           -- if there is more than one input, take care of the non-cumulative inputs
           IF g_number_dim > 1 THEN
             cn_utils.appindcr(body_code, '       g_commission_rec := null; ');
             cn_utils.appindcr(body_code, '       get_input(null, p_salesrep_id, ');
             cn_utils.appindcr(body_code, '                 p_period_id, p_quota_id, ');
             cn_utils.appindcr(body_code, '                 p_srp_plan_assign_id, l_trx_rec_old.processed_date, ');
             cn_utils.appindcr(body_code, '                 l_mul_input_tbl  );');

			 FOR i IN 1..g_number_dim LOOP
               cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Input='' || l_mul_input_tbl('||i||').amount || l_mul_input_tbl('||i||').input_string );');
             END LOOP;
             cn_utils.appendcr(body_code);
           END IF;

           FOR itd_input IN itd_inputs LOOP
              cn_utils.appindcr(body_code, '      l_mul_input_tbl('||itd_input.rate_dim_sequence||').rate_dim_sequence := '
                                || itd_input.rate_dim_sequence || ';' );

              SELECT  sql_select input_sql_select, sql_from input_sql_from
                INTO l_input_sql_select_clob, l_input_sql_from_clob
                FROM cn_calc_sql_exps_all
                WHERE calc_sql_exp_id = itd_input.calc_sql_exp_id
				  AND org_id = g_org_id;

              convert_clob_to_string( l_input_sql_select_clob, l_input_sql_select );
              l_input_sql_select := lower_str( 'select ' || l_input_sql_select);
              convert_clob_to_string(l_input_sql_from_clob, l_input_sql_from);
              l_input_sql_from := lower( 'from ' || l_input_sql_from );

              construct_sql_from_where (l_input_sql_select,
                                        l_input_sql_from,
                                        l_input_sql_where );


              IF g_pq_target_flag OR g_spq_target_flag  THEN
                 -- get itd_target
                 IF g_pq_target_flag THEN
                    cn_utils.appindcr(body_code, '      l_itd_target := cn_formula_common_pkg.get_pq_itd_target ');
                    cn_utils.appindcr(body_code, '                              ( p_period_id, p_quota_id  );' );
                 END IF;

                 IF g_spq_target_flag THEN
                    cn_utils.appindcr(body_code, '      l_itd_target := cn_formula_common_pkg.get_spq_itd_target ');
                    cn_utils.appindcr(body_code, '                         ( p_salesrep_id, p_srp_plan_assign_id, ' );
                    cn_utils.appindcr(body_code, '                           p_period_id, p_quota_id             ); ');
                 END IF;

                 cn_utils.appendcr(body_code);

                 IF itd_input.split_flag <> 'N' THEN
                    cn_utils.appindcr(body_code, '      l_mul_input_tbl('||itd_input.rate_dim_sequence||').base_amount := 0;' );
                  ELSE
                    IF itd_input.cumulative_flag = 'Y' THEN
                      cn_utils.appindcr(body_code, '      l_mul_input_tbl('||itd_input.rate_dim_sequence||').base_amount := g_input_achieved_itd('
                                      ||itd_input.rate_dim_sequence||') / l_itd_target;' );
                    ELSE
                      cn_utils.appindcr(body_code, '      l_mul_input_tbl('||itd_input.rate_dim_sequence||').base_amount := l_mul_input_tbl('||itd_input.rate_dim_sequence||').base_amount / l_itd_target;' );
					END IF;
                 END IF;

                 IF itd_input.cumulative_flag = 'Y' THEN
                   cn_utils.appindcr(body_code, '      l_mul_input_tbl('||itd_input.rate_dim_sequence||').amount := g_input_achieved_itd('
                                   ||itd_input.rate_dim_sequence||')/l_itd_target;' );
                 ELSE
                   cn_utils.appindcr(body_code, '      l_mul_input_tbl('||itd_input.rate_dim_sequence||').amount := l_mul_input_tbl('||itd_input.rate_dim_sequence||').amount/l_itd_target;' );
				 END IF;
               ELSE
                 IF itd_input.split_flag <> 'N' THEN
                    cn_utils.appindcr(body_code, '      l_mul_input_tbl('||itd_input.rate_dim_sequence||').base_amount := 0;' );
                  ELSE
                    IF itd_input.cumulative_flag = 'Y' THEN
                      cn_utils.appindcr(body_code, '      l_mul_input_tbl('||itd_input.rate_dim_sequence||').base_amount := g_input_achieved_itd('
                                      ||itd_input.rate_dim_sequence||');' );
					END IF;
                 END IF;

                 IF itd_input.cumulative_flag = 'Y' THEN
                   cn_utils.appindcr(body_code, '      l_mul_input_tbl('||itd_input.rate_dim_sequence||').amount := g_input_achieved_itd('
                                   ||itd_input.rate_dim_sequence||');' );
                 END IF;
              END IF;
           END LOOP;

           -- get processed date
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '      SELECT least(p.end_date,nvl(spa.end_date,p.end_date),nvl(q.end_date,p.end_date)) ');
           cn_utils.appindcr(body_code, '        INTO l_processed_date ');
           cn_utils.appindcr(body_code, '        FROM cn_acc_period_statuses_v p,cn_srp_plan_assigns_all spa,cn_quotas_all q  ');
           cn_utils.appindcr(body_code, '       WHERE p.period_id = p_period_id ');
           cn_utils.appindcr(body_code, '         AND p.org_id = spa.org_id ');
           cn_utils.appindcr(body_code, '         AND spa.srp_plan_assign_id = p_srp_plan_assign_id ');
           cn_utils.appindcr(body_code, '         AND q.quota_id = p_quota_id; ');
           -- get rates
           IF g_rate_flag THEN
              cn_utils.appindcr(body_code, '      cn_formula_common_pkg.get_rates( p_salesrep_id, p_srp_plan_assign_id,');
              cn_utils.appindcr(body_code, '                 p_period_id, p_quota_id , g_split_flag,g_itd_flag, ' );
              cn_utils.appindcr(body_code, '                 l_processed_date, g_number_dim,l_mul_input_tbl, ');
              cn_utils.appindcr(body_code, '                 g_formula_id,l_rate, l_rate_tier_id, l_tier_split ); ');
           END IF;

           -- get output
           cn_utils.appendcr(body_code);
           IF g_itd_flag = 'Y' THEN
              SELECT  sql_select output_sql_select
                INTO l_output_sql_select_clob
                FROM cn_calc_sql_exps_all
                WHERE org_id = g_org_id
				  AND calc_sql_exp_id = (SELECT output_exp_id
                                         FROM  cn_calc_formulas_all
                                         WHERE  calc_formula_id = g_formula_id
										   AND org_id = g_org_id);

              convert_clob_to_string( l_output_sql_select_clob, l_output_sql_select );
              l_output_sql_select := lower_str( 'select ' || l_output_sql_select);

              g_rate_flag := check_sql_stmt_existence(l_output_sql_select, 'rateresult');

              l_operator_position := search_delimiter_select(l_output_sql_select, 1);
              IF l_operator_position > 0 THEN
                 l_operator := substr(l_output_sql_select, l_operator_position, 1);
              END IF;

              SELECT  sql_select input_sql_select, sql_from input_sql_from
                INTO l_input_sql_select_clob, l_input_sql_from_clob
                FROM cn_calc_sql_exps_all
                WHERE org_id = g_org_id
				  AND calc_sql_exp_id = (SELECT output_exp_id
                                         FROM  cn_calc_formulas_all
                                         WHERE  calc_formula_id = g_formula_id
										   AND org_id = g_org_id);

              convert_clob_to_string( l_input_sql_select_clob, l_input_sql_select );
              l_input_sql_select := lower_str( 'select ' || l_input_sql_select);
              convert_clob_to_string(l_input_sql_from_clob, l_input_sql_from);
              l_input_sql_from := lower( 'from ' || l_input_sql_from );

              construct_sql_from_where (l_input_sql_select,
                                        l_input_sql_from,
                                        l_input_sql_where );

              IF g_pq_payment_flag OR g_spq_payment_flag THEN
                 -- get itd_payment
                 IF g_pq_payment_flag THEN
                    cn_utils.appindcr(body_code, '      l_itd_payment := cn_formula_common_pkg.get_pq_itd_payment ');
                    cn_utils.appindcr(body_code, '                              ( p_period_id, p_quota_id  );' );
                 END IF;

                 IF g_spq_payment_flag THEN
                    cn_utils.appindcr(body_code, '      l_itd_payment := cn_formula_common_pkg.get_spq_itd_payment ');
                    cn_utils.appindcr(body_code, '                         ( p_salesrep_id, p_srp_plan_assign_id, ' );
                    cn_utils.appindcr(body_code, '                           p_period_id, p_quota_id             ); ');
                 END IF;

           IF g_rate_flag THEN
                    IF l_operator_position > 0 THEN
            -- clku bug 2877815, call get-commission to calculate ITD results correctly
               cn_utils.appindcr(body_code, ' l_commission := get_commission( l_trx_rec_old.commission_line_id, ');
               cn_utils.appindcr(body_code, '                                 p_salesrep_id, p_period_id, p_quota_id, ');
               cn_utils.appindcr(body_code, '                                 p_srp_plan_assign_id,        l_rate);');

                    END IF;
                  ELSE
            -- clku bug 2877815, call get-commission to calculate ITD results correctly
                    cn_utils.appindcr(body_code, '       l_commission := get_commission( l_trx_rec_old.commission_line_id, ');
            cn_utils.appindcr(body_code, '                                 p_salesrep_id, p_period_id, p_quota_id, ');
            cn_utils.appindcr(body_code, '                                 p_srp_plan_assign_id,        l_rate); ');


                 END IF;
               ELSE
                 -- if x_rate is used in output
                 IF g_rate_flag THEN
                    IF l_operator_position > 0 THEN
                       cn_utils.appindcr(body_code, '      l_commission := l_rate '||
                                         l_operator ||' g_output_achieved_itd ');
                       cn_utils.appindcr(body_code, '                   - g_commission_payed_itd ;' );
                     ELSE
                       cn_utils.appindcr(body_code, '      l_commission := l_rate - '||
                                         ' g_commission_payed_itd ;' );
                    END IF;
                  ELSE
                    cn_utils.appindcr(body_code, '      l_commission := g_output_achieved_itd '||
                                      '- g_commission_payed_itd ;' );
                 END IF;
              END IF;
           END IF;

           -- create itd trx
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '      l_trx_rec_new := l_trx_rec_null; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.status := ''CALC''; ');
             cn_utils.appindcr(body_code, '      l_trx_rec_new.credit_type_id := p_credit_type_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.salesrep_id := p_salesrep_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.created_during := ''CALC''; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.srp_plan_assign_id := p_srp_plan_assign_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.quota_id := p_quota_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.processed_date := l_processed_date; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.processed_period_id := p_period_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.pay_period_id :=  p_period_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.posting_status := ''UNPOSTED''; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.pending_status := null; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.trx_type := ''ITD'' ; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.commission_amount := l_commission ;');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.commission_rate := l_rate ; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.rate_tier_id := l_rate_tier_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.tier_split := l_tier_split ; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.input_achieved := 0; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.output_achieved:= 0; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.perf_achieved := 0; ');
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '      cn_formula_common_pkg.create_trx(l_trx_rec_new); ');
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '      g_commission_payed_ptd := g_commission_payed_ptd + l_commission;        ');
           cn_utils.appindcr(body_code, '      g_commission_payed_itd := g_commission_payed_itd + l_commission;        ');
           cn_utils.appindcr(body_code, '    EXCEPTION WHEN OTHERS THEN ');
           cn_utils.appindcr(body_code, '      if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
           cn_utils.appindcr(body_code, '        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
           cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.calculate_quota.exception'', ');
           cn_utils.appindcr(body_code, '	          sqlerrm); ');
           cn_utils.appindcr(body_code, '      end if; ');
           cn_utils.appindcr(body_code, '      cn_message_pkg.debug( ''Failed to create ITD commission line'' ); ');
           cn_utils.appindcr(body_code, '    END ; ');
           cn_utils.appindcr(body_code, '  END IF; ');
           cn_utils.appendcr(body_code);
        END IF;
      ELSIF (g_trx_group_code = 'GROUP' AND NOT(g_no_trx_flag)) THEN
        cn_utils.appindcr(body_code, '  l_endofinterval_flag := ''N'';                          ');
        cn_utils.appindcr(body_code, '  Open l_lines_csr; ');
        cn_utils.appindcr(body_code, '  LOOP ');
        cn_utils.appindcr(body_code, '   l_trx_rec_new := l_trx_rec_null; ');
        cn_utils.appindcr(body_code, '   FETCH l_lines_csr into g_commission_rec; ');
        cn_utils.appindcr(body_code, '     EXIT WHEN l_lines_csr%notfound; ');
        cn_utils.appindcr(body_code, '   BEGIN ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.COMMISSION_LINE_ID    :=  g_commission_rec.COMMISSION_LINE_ID;        ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.COMMISSION_HEADER_ID  :=  g_commission_rec.COMMISSION_HEADER_ID;        ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.SALESREP_ID  :=  g_commission_rec.CREDITED_SALESREP_ID;         ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.SRP_PLAN_ASSIGN_ID    :=  g_commission_rec.SRP_PLAN_ASSIGN_ID;          ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.QUOTA_ID              :=  g_commission_rec.QUOTA_ID;                    ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.CREDIT_TYPE_ID        :=  g_commission_rec.CREDIT_TYPE_ID;              ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.PROCESSED_DATE        :=  g_commission_rec.PROCESSED_DATE;              ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.PROCESSED_PERIOD_ID   :=  g_commission_rec.PROCESSED_PERIOD_ID;         ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.PAY_PERIOD_ID         :=  g_commission_rec.PAY_PERIOD_ID;               ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.COMMISSION_AMOUNT     :=  g_commission_rec.COMMISSION_AMOUNT;           ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.COMMISSION_RATE       :=  g_commission_rec.COMMISSION_RATE;             ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.RATE_TIER_ID          :=  g_commission_rec.RATE_TIER_ID;                ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.TIER_SPLIT            :=  g_commission_rec.TIER_SPLIT;                  ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.INPUT_ACHIEVED        :=  g_commission_rec.INPUT_ACHIEVED;              ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.OUTPUT_ACHIEVED       :=  g_commission_rec.OUTPUT_ACHIEVED;             ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.PERF_ACHIEVED         :=  g_commission_rec.PERF_ACHIEVED;               ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.POSTING_STATUS        :=  g_commission_rec.POSTING_STATUS;              ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.PENDING_STATUS        :=  g_commission_rec.PENDING_STATUS;              ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.CREATED_DURING        :=  g_commission_rec.CREATED_DURING;              ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.TRX_TYPE              :=  g_commission_rec.TRX_TYPE;                    ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.ERROR_REASON          :=  g_commission_rec.ERROR_REASON;               ');
        cn_utils.appindcr(body_code ,'l_trx_rec_old.STATUS                   :=  g_commission_rec.STATUS;                         ');

        cn_utils.appindcr(body_code, '    get_input(l_trx_rec_old.commission_line_id, p_salesrep_id, ');
        cn_utils.appindcr(body_code, '              p_period_id, p_quota_id, ');
        cn_utils.appindcr(body_code, '              p_srp_plan_assign_id, p_start_date, ');
        cn_utils.appindcr(body_code, '              l_mul_input_tbl, l_endofinterval_flag, null);');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '    l_commission := get_commission(l_trx_rec_old.commission_line_id,');
        cn_utils.appindcr(body_code, '                  p_salesrep_id, p_period_id, p_quota_id, ');
        cn_utils.appindcr(body_code, '                  p_srp_plan_assign_id, l_rate, ');
        cn_utils.appindcr(body_code, '                  l_endofinterval_flag, null);');
        cn_utils.appendcr(body_code);
        IF g_perf_input_expr_seq >0 THEN
               cn_utils.appindcr(body_code,'       l_perf :=l_mul_input_tbl('||g_perf_input_expr_seq||').input_amount;  ');

        ELSIF g_perf_measure_id IS  NULL THEN
               cn_utils.appindcr(body_code,'       l_perf :=l_mul_input_tbl('||1||').input_amount;  ');

        ELSE
                   cn_utils.appindcr(body_code, '    l_perf := get_perf(l_trx_rec_old.commission_line_id, p_salesrep_id,');
                cn_utils.appindcr(body_code, '                 p_period_id,p_quota_id, p_srp_plan_assign_id, ');
                cn_utils.appindcr(body_code, '                 p_start_date, l_endofinterval_flag, null);');

                cn_utils.appindcr(body_code, '     if (l_debug_flag = ''Y'') then');
                cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Performance measure='' || l_perf);');
                cn_utils.appindcr(body_code, '     end if; ');
        END IF;

        cn_utils.appindcr(body_code, '    x_latest_processed_date := l_trx_rec_old.processed_date;    ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '    l_trx_rec_new.status := ''CALC''; ');
        cn_utils.appindcr(body_code, '    l_trx_rec_new.credit_type_id := p_credit_type_id; ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '   EXCEPTION when others then        ');
        cn_utils.appindcr(body_code, '    l_trx_rec_new.error_reason := substr(sqlerrm,1,150); ');
        cn_utils.appindcr(body_code, '    l_trx_rec_new.status := ''XCALC'' ; ');
		cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Exception occurs while calculating commission line: ''); ');
        cn_utils.appindcr(body_code, '     cn_message_pkg.debug(sqlerrm); ');
        cn_utils.appindcr(body_code, '   END;   ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '   cn_formula_common_pkg.update_trx(l_trx_rec_old, l_trx_rec_new) ; ');
        cn_utils.appindcr(body_code, '  END LOOP;  ');
        cn_utils.appindcr(body_code, '  CLOSE l_lines_csr; ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '    l_start_period_id := ' );
        cn_utils.appindcr(body_code, '        cn_formula_common_pkg.get_start_period_id( '||
                          'p_quota_id, p_period_id);');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '  IF cn_formula_common_pkg.EndOfGroupByInterval(p_quota_id, '||
                          'p_period_id, p_srp_plan_assign_id) THEN ');
        cn_utils.appindcr(body_code, '    l_endofinterval_flag := ''Y''; ');
        cn_utils.appindcr(body_code, '  END IF;  ');

        -- get processed date
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '      SELECT least(p.end_date,nvl(spa.end_date,p.end_date),nvl(q.end_date,p.end_date)) ');
        cn_utils.appindcr(body_code, '        INTO l_processed_date ');
        cn_utils.appindcr(body_code, '        FROM cn_acc_period_statuses_v p,cn_srp_plan_assigns_all spa,cn_quotas_all q  ');
        cn_utils.appindcr(body_code, '       WHERE p.period_id = p_period_id ');
        cn_utils.appindcr(body_code, '         AND spa.srp_plan_assign_id = p_srp_plan_assign_id ');
        cn_utils.appindcr(body_code, '         AND p.org_id = spa.org_id ');
        cn_utils.appindcr(body_code, '         AND q.quota_id = p_quota_id; ');

        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, ' BEGIN ');
        cn_utils.appindcr(body_code, '  get_input(null, p_salesrep_id, p_period_id,');
        cn_utils.appindcr(body_code, '            p_quota_id, p_srp_plan_assign_id, ');
        cn_utils.appindcr(body_code, '            l_processed_date, l_mul_input_tbl, ');
        cn_utils.appindcr(body_code, '            l_endofinterval_flag,l_start_period_id );');

        cn_utils.appindcr(body_code, '  if (l_debug_flag = ''Y'') then');
        FOR i IN 1..g_number_dim LOOP
           cn_utils.appindcr(body_code, '    cn_message_pkg.debug(''Input=''||l_mul_input_tbl('||i||').amount);');
           cn_utils.appindcr(body_code, '    l_input('||i||') := l_mul_input_tbl('||i||').input_amount;        ');
        END LOOP;
        cn_utils.appindcr(body_code, '  end if; ');

        cn_utils.appendcr(body_code);
        IF g_rate_flag THEN
           cn_utils.appindcr(body_code, '  cn_formula_common_pkg.get_rates( p_salesrep_id, p_srp_plan_assign_id , ');
           cn_utils.appindcr(body_code, '            p_period_id, p_quota_id , g_split_flag,g_itd_flag, ');
           cn_utils.appindcr(body_code, '            l_processed_date, g_number_dim,l_mul_input_tbl, ' );
           cn_utils.appindcr(body_code, '            g_formula_id, l_rate, l_rate_tier_id, l_tier_split ); ');
           cn_utils.appindcr(body_code, '  if (l_debug_flag = ''Y'') then');
           cn_utils.appindcr(body_code, '    cn_message_pkg.debug(''Commission rate='' || l_rate);');
           cn_utils.appindcr(body_code, '  end if; ');
        END IF;
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '  l_commission := get_commission(null,p_salesrep_id, ');
        cn_utils.appindcr(body_code, '            p_period_id, p_quota_id,  ');
        cn_utils.appindcr(body_code, '            p_srp_plan_assign_id, l_rate, ' );
        cn_utils.appindcr(body_code, '            l_endofinterval_flag,l_start_period_id ); ');
        cn_utils.appindcr(body_code, '  if (l_debug_flag = ''Y'') then');
        cn_utils.appindcr(body_code, '    cn_message_pkg.debug(''Output='' || l_commission);');
        cn_utils.appindcr(body_code, '  end if; ');

        cn_utils.appendcr(body_code);

        IF g_perf_input_expr_seq >0 THEN
               cn_utils.appindcr(body_code,'       l_perf :=l_mul_input_tbl('||g_perf_input_expr_seq||').input_amount;  ');

        ELSIF g_perf_measure_id IS  NULL THEN
               cn_utils.appindcr(body_code,'       l_perf :=l_mul_input_tbl('||1||').input_amount;  ');

        ELSE
        cn_utils.appindcr(body_code, '  l_perf := get_perf(null, p_salesrep_id, p_period_id, ');
        cn_utils.appindcr(body_code, '                     p_quota_id, p_srp_plan_assign_id, null,');
        cn_utils.appindcr(body_code, '                     l_endofinterval_flag, l_start_period_id );');
        cn_utils.appindcr(body_code, '     if (l_debug_flag = ''Y'') then');
        cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Performance measure='' || l_perf);');
        cn_utils.appindcr(body_code, '     end if; ');
        END IF;
        cn_utils.appindcr(body_code, '     if (l_debug_flag = ''Y'') then');
        cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Performance measure='' || l_perf);');
        cn_utils.appindcr(body_code, '     end if; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.status := ''CALC''; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.credit_type_id := p_credit_type_id; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.commission_amount := l_commission ;');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.commission_rate := l_rate ; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.rate_tier_id := l_rate_tier_id; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.tier_split := l_tier_split ; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.input_achieved := l_input(1); ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.output_achieved:= l_commission ; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.perf_achieved := l_perf; ');
        cn_utils.appindcr(body_code, ' EXCEPTION WHEN OTHERS THEN ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.status := ''XCALC''; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.error_reason := substr(sqlerrm, 1, 150); ');
        cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Exception occurs while calculating commission line: ''); ');
        cn_utils.appindcr(body_code, '     cn_message_pkg.debug(sqlerrm); ');
        cn_utils.appindcr(body_code, ' END ; ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '  IF l_endofinterval_flag = ''Y'' THEN      ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.salesrep_id := p_salesrep_id; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.created_during := ''CALC''; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.srp_plan_assign_id := p_srp_plan_assign_id; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.quota_id := p_quota_id; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.processed_date := l_processed_date; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.processed_period_id := p_period_id; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.pay_period_id :=  p_period_id; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.posting_status := ''UNPOSTED''; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.pending_status := null; ');
        cn_utils.appindcr(body_code, '     l_grp_trx_rec.trx_type := ''GRP'' ; ');
        cn_utils.appindcr(body_code, '     cn_formula_common_pkg.create_trx(l_grp_trx_rec); ');
        cn_utils.appindcr(body_code, '  END IF;   ');

        -- update package global variables
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '  g_perf_achieved_ptd := l_perf - g_perf_achieved_itd; ');
        cn_utils.appindcr(body_code, '  g_perf_achieved_itd := l_perf; ');
        FOR i IN 1..g_number_dim LOOP
           cn_utils.appindcr(body_code, '    g_input_achieved_ptd('||i||') := l_input('||i||') - g_input_achieved_itd('||i||') ; ');
           cn_utils.appindcr(body_code, '    g_input_achieved_itd('||i||') := l_input('||i||'); ');
        END LOOP;
        cn_utils.appindcr(body_code, '  g_commission_payed_ptd := l_commission - g_commission_payed_itd; ');
        cn_utils.appindcr(body_code, '  g_commission_payed_itd := l_commission;        ');
        cn_utils.appendcr(body_code);
      ELSIF (g_no_trx_flag) THEN
           cn_utils.appindcr(body_code, '  BEGIN ');
           cn_utils.appindcr(body_code, '    get_input(null, p_salesrep_id, p_period_id, p_quota_id, ');
           cn_utils.appindcr(body_code, '              p_srp_plan_assign_id, l_trx_rec_old.processed_date, l_mul_input_tbl  );');
           cn_utils.appindcr(body_code, '    if (l_debug_flag = ''Y'') then');
           FOR i IN 1..g_number_dim LOOP
              cn_utils.appindcr(body_code, '    cn_message_pkg.debug(''Input='' || l_mul_input_tbl('||i||').amount);');
           END LOOP;
           cn_utils.appindcr(body_code, '     end if; ');
           cn_utils.appendcr(body_code);

           -- get processed date
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '    SELECT least(p.end_date,nvl(spa.end_date,p.end_date),nvl(q.end_date,p.end_date)) into l_processed_date ');
           cn_utils.appindcr(body_code, '      FROM cn_acc_period_statuses_v p,cn_srp_plan_assigns_all spa,cn_quotas_all q  ');
           cn_utils.appindcr(body_code, '     WHERE p.period_id = p_period_id ');
           cn_utils.appindcr(body_code, '           and spa.srp_plan_assign_id = p_srp_plan_assign_id ');
           cn_utils.appindcr(body_code, '           and p.org_id = spa.org_id ');
           cn_utils.appindcr(body_code, '           and q.quota_id = p_quota_id; ');
           -- get rates
           IF g_rate_flag THEN
              cn_utils.appindcr(body_code, '    cn_formula_common_pkg.get_rates(p_salesrep_id, p_srp_plan_assign_id,');
              cn_utils.appindcr(body_code, '                                    p_period_id, p_quota_id , g_split_flag,g_itd_flag, ' );
              cn_utils.appindcr(body_code, '                                    l_processed_date, g_number_dim,l_mul_input_tbl, ');
              cn_utils.appindcr(body_code, '                                    g_formula_id,l_rate, l_rate_tier_id, l_tier_split ); ');
           END IF;

           -- get output
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '    l_commission := get_commission(null, p_salesrep_id, p_period_id, p_quota_id, p_srp_plan_assign_id, l_rate);');

           FOR i IN 1..g_number_dim LOOP
              cn_utils.appindcr(body_code, '       l_input('||i||') := l_mul_input_tbl('||i||').input_amount;        ');
           END LOOP;

           IF g_perf_input_expr_seq >0 THEN
                  cn_utils.appindcr(body_code,'       l_perf :=l_mul_input_tbl('||g_perf_input_expr_seq||').input_amount;  ');

           ELSIF g_perf_measure_id IS  NULL THEN
                  cn_utils.appindcr(body_code,'       l_perf :=l_mul_input_tbl('||1||').input_amount;  ');

           ELSE
                   cn_utils.appindcr(body_code, '     l_perf := get_perf(null, p_salesrep_id,');
                   cn_utils.appindcr(body_code, '                          p_period_id, p_quota_id, ');
                   cn_utils.appindcr(body_code, '                          p_srp_plan_assign_id, null);');

                   cn_utils.appindcr(body_code, '     if (l_debug_flag = ''Y'') then');
                   cn_utils.appindcr(body_code, '       cn_message_pkg.debug(''Performance measure='' || l_perf);');
                   cn_utils.appindcr(body_code, '     end if; ');
           END IF;

           -- create itd trx
           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '      l_trx_rec_new := l_trx_rec_null; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.status := ''CALC''; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.credit_type_id := p_credit_type_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.salesrep_id := p_salesrep_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.created_during := ''CALC''; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.srp_plan_assign_id := p_srp_plan_assign_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.quota_id := p_quota_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.processed_date := l_processed_date; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.processed_period_id := p_period_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.pay_period_id :=  p_period_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.posting_status := ''UNPOSTED''; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.pending_status := null; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.trx_type := ''ITD'' ; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.commission_amount := l_commission ;');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.commission_rate := l_rate ; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.rate_tier_id := l_rate_tier_id; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.tier_split := l_tier_split ; ');
/*
           cn_utils.appindcr(body_code, '      l_trx_rec_new.input_achieved := 0; ');
           cn_utils.appindcr(body_code, '      l_trx_rec_new.output_achieved:= 0; ');
*/

           IF g_number_dim > 1 THEN
              cn_utils.appindcr(body_code, '     l_trx_rec_new.input_achieved := l_input(1) ; ');
            ELSE
              cn_utils.appindcr(body_code, '     l_trx_rec_new.input_achieved := l_input(1) ; ');
           END IF;
           IF g_itd_flag = 'Y' THEN
              cn_utils.appindcr(body_code, '     l_trx_rec_new.output_achieved := g_output_achieved ; ');
            ELSE
              --  output_achieved = 0 since no need to accumulate output for individual non itd case
              cn_utils.appindcr(body_code, '     l_trx_rec_new.output_achieved := 0 ; ');
           END IF;
           cn_utils.appindcr(body_code, '     l_trx_rec_new.perf_achieved := l_perf ; ');
           cn_utils.appendcr(body_code);


           cn_utils.appendcr(body_code);
           cn_utils.appindcr(body_code, '      cn_formula_common_pkg.create_trx(l_trx_rec_new); ');
           cn_utils.appendcr(body_code);

           -- update package variables
           cn_utils.appendcr(body_code);
           IF g_itd_flag = 'Y' THEN
              cn_utils.appindcr(body_code, '   g_output_achieved_ptd := g_output_achieved_ptd + g_output_achieved ;' );
              cn_utils.appindcr(body_code, '   g_output_achieved_itd := g_output_achieved_itd + g_output_achieved; ' );
           END IF;

           cn_utils.appindcr(body_code, '   g_perf_achieved_ptd := g_perf_achieved_ptd+ l_perf; ');
           cn_utils.appindcr(body_code, '   g_perf_achieved_itd := g_perf_achieved_itd+ l_perf; ');

           FOR i IN 1..g_number_dim LOOP
              cn_utils.appindcr(body_code, '   g_input_achieved_ptd('||i||') := g_input_achieved_ptd('||i||') + l_input('||i||');        ');
              cn_utils.appindcr(body_code, '   g_input_achieved_itd('||i||') := g_input_achieved_itd('||i||') + l_input('||i||');        ');
           END LOOP;

           cn_utils.appindcr(body_code, '   g_commission_payed_ptd := g_commission_payed_ptd + l_commission;        ');
           cn_utils.appindcr(body_code, '   g_commission_payed_itd := g_commission_payed_itd + l_commission;        ');
           cn_utils.appendcr(body_code);

/*
           cn_utils.appindcr(body_code, '      g_commission_payed_ptd := g_commission_payed_ptd + l_commission;        ');
           cn_utils.appindcr(body_code, '      g_commission_payed_itd := g_commission_payed_itd + l_commission;        ');
*/
           cn_utils.appindcr(body_code, '    EXCEPTION WHEN OTHERS THEN ');
           cn_utils.appindcr(body_code, '      if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
           cn_utils.appindcr(body_code, '        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
           cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.calculate_quota.exception'', ');
           cn_utils.appindcr(body_code, '	          sqlerrm); ');
           cn_utils.appindcr(body_code, '      end if; ');

           cn_utils.appindcr(body_code, '      cn_message_pkg.debug( ''Failed to create ITD commission line'' ); ');
           cn_utils.appindcr(body_code, '    END ; ');
     END IF;

     calc_roll(spec_code, body_code);

     cn_utils.appindcr(body_code, ' EXCEPTION ' );
     cn_utils.appindcr(body_code, '   when others then ');
     IF (NOT(g_no_trx_flag)) THEN
     cn_utils.appindcr(body_code, '     IF l_lines_csr%isopen THEN ' );
     cn_utils.appindcr(body_code, '       CLOSE l_lines_csr; ');
     cn_utils.appindcr(body_code, '     END IF; ');
     END IF;
     cn_utils.appindcr(body_code, '     if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
     cn_utils.appindcr(body_code, '       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
     cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.calculate_quota.exception'', ');
     cn_utils.appindcr(body_code, '	          sqlerrm); ');
     cn_utils.appindcr(body_code, '     end if; ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Exception occurs in formula calculate_quota:''); ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(sqlerrm); ');
     cn_utils.appindcr(body_code, '     raise; ');
     cn_utils.proc_end( procedure_name, 'N', body_code );
EXCEPTION
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.calculate_quota.exception',
         	          sqlerrm);
    end if;
    raise;
END calculate_quota;

--   construct the get_result procedure which will be invoked if this formula is used as an embeded formula
PROCEDURE get_result (spec_code        IN OUT NOCOPY cn_utils.code_type,
                      body_code        IN OUT NOCOPY cn_utils.code_type )
IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;
    package_spec_id        cn_obj_packages_v.package_id%TYPE;
    x_repository_id        cn_repositories.repository_id%TYPE;

    l_counter NUMBER(15);
    l_variable_declaration VARCHAR2(400);
    l_table_object_id       cn_objects.object_id%type;
    l_input_sql_select        varchar2(8000);
    l_input_sql_from        varchar2(4000);
    l_input_sql_where   varchar2(4000) := 'WHERE 1=1 ';
    l_input_sql_select_clob clob;
    l_input_sql_from_clob   clob;
BEGIN
     procedure_name := 'get_result';
     procedure_desc := 'This procedure is invoked if this formula is used as an embeded formula';
     parameter_list := 'p_commission_line_id NUMBER';

     proc_init(procedure_name, procedure_desc, parameter_list,
               'F', 'NUMBER' , package_spec_id, x_repository_id,
               spec_code, body_code);

     cn_utils.appindcr(body_code, '  l_mul_input_tbl    cn_formula_common_pkg.mul_input_tbl_type;');
     cn_utils.appindcr(body_code, '  l_rate              NUMBER;');
     cn_utils.appindcr(body_code, '  l_rate_tier_id     NUMBER;');
     cn_utils.appindcr(body_code, '  l_tier_split             NUMBER;');
     cn_utils.appindcr(body_code, '  l_commission              NUMBER;');
     cn_utils.appindcr(body_code, '  p_salesrep_id      NUMBER(15); ');
     cn_utils.appindcr(body_code, '  p_period_id        NUMBER(15); ');
     cn_utils.appindcr(body_code, '  p_quota_id         NUMBER(15); ');
     cn_utils.appindcr(body_code, '  p_processed_date   DATE ; ');
     cn_utils.appindcr(body_code, '  p_srp_plan_assign_id NUMBER(15); ');
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '  CURSOR l_comm_line_csr IS ');
    cn_utils.appindcr(body_code, '    SELECT ');

    -- Added for 11.5.10 Performance Enhancments
    -- Add column names of CH and CL which are used in the input/output/perf expression
    FOR i IN g_comm_tbl_clmn_nms_tbl.FIRST..g_comm_tbl_clmn_nms_tbl.LAST LOOP
      IF i <> g_comm_tbl_clmn_nms_tbl.LAST THEN
          cn_utils.appindcr(body_code ,'         '||g_comm_tbl_clmn_nms_tbl(i).table_alias||'.'||g_comm_tbl_clmn_nms_tbl(i).column_name||',');
      ELSE
          cn_utils.appindcr(body_code ,'         '||g_comm_tbl_clmn_nms_tbl(i).table_alias||'.'||g_comm_tbl_clmn_nms_tbl(i).column_name);
      END IF;
    END LOOP;
    IF g_ch_flag THEN
        cn_utils.appindcr(body_code, '    FROM cn_commission_lines cl, cn_commission_headers ch ');
    ELSE
        cn_utils.appindcr(body_code, '    FROM cn_commission_lines cl');
    END IF;
    cn_utils.appindcr(body_code, '    where cl.commission_line_id = p_commission_line_id ');
    IF g_ch_flag THEN
      cn_utils.appindcr(body_code, '      AND ch.commission_header_id = cl.commission_header_id');
    END IF;
    cn_utils.appindcr(body_code, ';');

     -- Added for 11.5.10 Performance Enhancments
     -- Declare cursors which will fetch all columns of tables
     -- used in input/output/perf expressions.
     IF g_trx_group_code = 'INDIVIDUAL' THEN
        l_table_object_id := g_uniq_tbl_names_tbl.FIRST;
        FOR l_counter IN 1..g_uniq_tbl_names_tbl.COUNT LOOP
           IF INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_LINES') =  0  AND
              INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_HEADERS') = 0 THEN
               IF LENGTH(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL)) > 24 THEN
                   l_variable_declaration := 'l_'||lower(substr(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL),1,24))||'_cur';
               ELSE
                   l_variable_declaration := 'l_'||lower(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL)) ||'_cur';
               END IF;
               cn_utils.appendcr(body_code);
               cn_utils.appindcr(body_code, '  CURSOR '||l_variable_declaration||'  IS');
               l_input_sql_where  := 'WHERE 1=1 ';
               l_input_sql_select := lower_str( '  select ' ||g_uniq_tbl_names_tbl(l_table_object_id).column_name_list);
               l_input_sql_from := lower( '   from ' ||g_uniq_tbl_names_tbl(l_table_object_id).table_name||' '||
                                                    g_uniq_tbl_names_tbl(l_table_object_id).table_alias);
               construct_sql_from_where (l_input_sql_select,
                                             l_input_sql_from,
                                         l_input_sql_where );
               --split_long_sql( body_code, l_input_sql_select, 'SELECT');
                 cn_utils.appindcr(body_code, 'SELECT * ');

               split_long_sql( body_code, l_input_sql_from, 'FROM');
               split_long_sql( body_code, l_input_sql_where||';', 'WHERE');
           END IF;
           l_table_object_id :=  g_uniq_tbl_names_tbl.NEXT(l_table_object_id);
        END LOOP;
     END IF;


     cn_utils.appendcr(body_code, 'BEGIN');
     -- Added for 11.5.10 Performance Enhancments
     -- Declare cursors which will fetch all columns of tables
     -- used in input/output/perf expressions.
     cn_utils.appindcr(body_code, '  OPEN l_comm_line_csr ; ');
     cn_utils.appindcr(body_code, '  FETCH l_comm_line_csr into g_commission_rec;');
     cn_utils.appindcr(body_code, '  CLOSE l_comm_line_csr; ');
     cn_utils.appindcr(body_code ,'  p_salesrep_id   :=   g_commission_rec.CREDITED_SALESREP_ID;         ');
     cn_utils.appindcr(body_code ,'  p_period_id     :=   g_commission_rec.PROCESSED_PERIOD_ID;         ');
     cn_utils.appindcr(body_code ,'  p_quota_id      :=   g_commission_rec.quota_id;         ');
     cn_utils.appindcr(body_code ,'  p_srp_plan_assign_id   :=   g_commission_rec.srp_plan_assign_id;         ');
     cn_utils.appindcr(body_code ,'  p_processed_date :=   g_commission_rec.processed_date;         ');

     cn_utils.appendcr(body_code);

     -- Added for 11.5.10 Performance Enhancments
     -- Declare fetch statment which will fetch all columns of tables
     -- used in input/output/perf expressions.
     IF g_trx_group_code = 'INDIVIDUAL' THEN
        l_table_object_id := g_uniq_tbl_names_tbl.FIRST;
        FOR l_counter IN 1..g_uniq_tbl_names_tbl.COUNT LOOP
           IF INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_LINES') =  0  AND
              INSTR(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'CN_COMMISSION_HEADERS') = 0 THEN

               IF LENGTH(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL)) > 24 THEN
                   l_variable_declaration := 'l_'||lower(substr(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL),1,24))||'_cur';
               ELSE
                   l_variable_declaration := 'l_'||lower(REPLACE(g_uniq_tbl_names_tbl(l_table_object_id).table_name,'_',NULL)) ||'_cur';
               END IF;
               cn_utils.appendcr(body_code);
               cn_utils.appindcr(body_code, '  OPEN '||l_variable_declaration||' ;' );
               cn_utils.appindcr(body_code, '  FETCH '||l_variable_declaration||'  INTO ' ||g_uniq_tbl_names_tbl(l_table_object_id).variable_name||' ;' );
               cn_utils.appindcr(body_code, '  CLOSE '||l_variable_declaration||' ;' );
            END IF;
            l_table_object_id :=  g_uniq_tbl_names_tbl.NEXT(l_table_object_id);
         END LOOP;
      END IF;

     IF g_trx_group_code = 'INDIVIDUAL' AND g_itd_flag = 'N' AND g_cumulative_flag = 'N' THEN
        cn_utils.appindcr(body_code, '  get_input(p_commission_line_id, p_salesrep_id, ');
        cn_utils.appindcr(body_code, '            p_period_id, p_quota_id, ');
        cn_utils.appindcr(body_code, '            p_srp_plan_assign_id, p_processed_date, ');
        cn_utils.appindcr(body_code, '            l_mul_input_tbl  );');
        cn_utils.appendcr(body_code);
        IF g_rate_flag THEN
           cn_utils.appindcr(body_code, '  cn_formula_common_pkg.get_rates( p_salesrep_id, p_srp_plan_assign_id , ');
           cn_utils.appindcr(body_code, '            p_period_id, p_quota_id , g_split_flag,g_itd_flag, ');
           cn_utils.appindcr(body_code, '            p_processed_date, g_number_dim,l_mul_input_tbl, ');
           cn_utils.appindcr(body_code, '            g_formula_id, l_rate , l_rate_tier_id, l_tier_split ); ');
        END IF;
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '  l_commission := get_commission( p_commission_line_id, ');
        cn_utils.appindcr(body_code, '                  p_salesrep_id, p_period_id, p_quota_id, ');
        cn_utils.appindcr(body_code, '                  p_srp_plan_assign_id, l_rate); ');
     END IF;

     cn_utils.appindcr(body_code, '  return l_commission; ');
     cn_utils.appendcr(body_code);

     cn_utils.proc_end( procedure_name, 'N', body_code );

EXCEPTION
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.get_result.exception',
         	          sqlerrm);
    end if;
    raise;
END get_result;

 --   construct the update_revclass_perf procedure for the formula package.
PROCEDURE update_revclass_perf (spec_code        IN OUT NOCOPY cn_utils.code_type,
                                body_code        IN OUT NOCOPY cn_utils.code_type )
IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;
    package_spec_id        cn_obj_packages_v.package_id%TYPE;
    x_repository_id        cn_repositories.repository_id%TYPE;

    l_input_sql_select        varchar2(8000);
    l_input_sql_from        varchar2(4000);
    l_input_sql_where   varchar2(4000) := 'WHERE 1=1';

    l_input_sql_select_clob clob;
    l_input_sql_from_clob   clob;

    l_sql_stmt          VARCHAR2(1000);
    l_line_alias        VARCHAR2(30);
    l_header_alias      VARCHAR2(30);

BEGIN
     procedure_name := 'update_revclass_perf';
     procedure_desc := 'To accumulate performance by revenue classes in group by case.'||
       'This is a call back when updating plan element subledger ' ;
     parameter_list := 'p_salesrep_id NUMBER, p_period_id NUMBER, ';
     parameter_list := parameter_list || 'p_quota_id NUMBER, p_srp_plan_assign_id NUMBER';

     proc_init(procedure_name, procedure_desc, parameter_list,
               'P', null, package_spec_id, x_repository_id,
               spec_code, body_code);

     cn_utils.appindcr(body_code, '  l_perf              NUMBER;');
     cn_utils.appindcr(body_code, '  CURSOR l_rev_classes_csr IS ');
     cn_utils.appindcr(body_code, '    SELECT revenue_class_id, srp_per_quota_rc_id');
     cn_utils.appindcr(body_code, '      FROM cn_srp_per_quota_rc_all rc');
     cn_utils.appindcr(body_code, '     WHERE rc.srp_plan_assign_id = p_srp_plan_assign_id');
     cn_utils.appindcr(body_code, '       AND rc.salesrep_id = p_salesrep_id');
     cn_utils.appindcr(body_code, '          AND rc.period_id = p_period_id');
     cn_utils.appindcr(body_code, '          AND rc.quota_id = p_quota_id;');

     cn_utils.appendcr(body_code);
     cn_utils.appendcr(body_code, 'BEGIN');

     IF g_perf_measure_id IS NOT NULL THEN
        select sql_select, sql_from
          into l_input_sql_select_clob, l_input_sql_from_clob
          from cn_calc_sql_exps_all
          where calc_sql_exp_id = g_perf_measure_id
		    and org_id = g_org_id;

        convert_clob_to_string(l_input_sql_select_clob, l_input_sql_select);
        l_input_sql_select := lower_str( 'select ' || l_input_sql_select );
        convert_clob_to_string(l_input_sql_from_clob, l_input_sql_from);
        l_input_sql_from := lower( 'from ' || l_input_sql_from );

      ELSE   /* default to be the input with the lowest input_sequence */
        SELECT sql_select input_sql_select, sql_from input_sql_from
          INTO l_input_sql_select_clob, l_input_sql_from_clob
          FROM cn_calc_sql_exps_all
          WHERE org_id = g_org_id
		    AND calc_sql_exp_id = (SELECT calc_sql_exp_id
                                   FROM cn_formula_inputs_all
                                   WHERE calc_formula_id = g_formula_id
                                   AND org_id = g_org_id
                                   AND rate_dim_sequence = 1);

        convert_clob_to_string(l_input_sql_select_clob, l_input_sql_select);
        l_input_sql_select := lower_str( 'select ' || l_input_sql_select );
        convert_clob_to_string(l_input_sql_from_clob, l_input_sql_from);
        l_input_sql_from := lower( 'from ' || l_input_sql_from );

     END IF;

     construct_sql_from_where(l_input_sql_select,
                              l_input_sql_from ,
                              l_input_sql_where   );

     -- get header table alias
     IF check_sql_stmt_existence(l_input_sql_from, 'cn_commission_headers') THEN
        l_header_alias := get_table_alias (l_input_sql_from, 'cn_commission_headers');
      ELSE -- comm_header not in sql_from yet, add it and get its alias
        l_header_alias := get_table_alias_from_cn('cn_commission_headers');
        l_input_sql_from := l_input_sql_from || ', cn_commission_headers_all ' || l_header_alias;
     END IF ;
     -- get the alias for cn_commisson_lines
     IF check_sql_stmt_existence(l_input_sql_from, 'cn_commission_lines') THEN
        l_line_alias := get_table_alias (l_input_sql_from, 'cn_commission_lines');
      ELSE -- comm_lines not in sql_from yet, add it and get its alias
        l_line_alias := get_table_alias_from_cn('cn_commission_lines');
        l_input_sql_from := l_input_sql_from || ', cn_commission_lines_all ' || l_line_alias;
     END IF ;

     -- Changed by Zack to handle the hierarchy revenue class case
     l_input_sql_from := l_input_sql_from || ', cn_quota_rules_all cn_cqr ';

     make_srp_plan_pe_hid_pid_st(l_line_alias, l_header_alias, l_input_sql_where);

     l_sql_stmt := ' and '|| l_line_alias || '.processed_period_id between p_start_period_id and p_period_id';
     IF check_sql_stmt_existence(l_input_sql_where, l_sql_stmt) THEN
        l_input_sql_where := REPLACE(l_input_sql_where, l_sql_stmt, ' ' );

        l_sql_stmt := ' and '|| l_line_alias || '.processed_period_id = p_period_id';
        l_input_sql_where := l_input_sql_where || l_sql_stmt;
     END IF;

     make_calc_type(l_line_alias, l_header_alias, l_input_sql_where);

     l_sql_stmt := ' and '|| l_line_alias || '.quota_rule_id = '||' cn_cqr.quota_rule_id ';
     l_sql_stmt := l_sql_stmt ||' and cn_cqr.revenue_class_id = l_rev_class.revenue_class_id ';

     IF NOT check_sql_stmt_existence(l_input_sql_where, l_sql_stmt) THEN
        l_input_sql_where := l_input_sql_where || l_sql_stmt;
     END IF;

     IF g_perf_measure_id IS NOT NULL THEN
        l_input_sql_select := REPLACE(l_input_sql_select, 'select', 'select sum(');
        l_input_sql_select := l_input_sql_select || ' ) ';
     END IF;

     cn_utils.appindcr(body_code, ' FOR l_rev_class IN l_rev_classes_csr LOOP ');
     split_long_sql( body_code, l_input_sql_select, 'SELECT');
     cn_utils.appindcr(body_code, '   into l_perf ');
     split_long_sql( body_code, l_input_sql_from, 'FROM');
     split_long_sql( body_code, l_input_sql_where||';', 'WHERE');
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '   l_perf := nvl(l_perf, 0); ');


     cn_utils.appindcr(body_code, '   UPDATE cn_srp_per_quota_rc_all');
     cn_utils.appindcr(body_code, '         SET period_to_date = l_perf');
     cn_utils.appindcr(body_code, '    WHERE srp_per_quota_rc_id = l_rev_class.srp_per_quota_rc_id;');
     cn_utils.appindcr(body_code, ' END LOOP; ' );

     cn_utils.proc_end( procedure_name, 'N', body_code );
EXCEPTION
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.update_revclass_perf.exception',
         	          sqlerrm);
    end if;
    raise;
END update_revclass_perf;

--   construct the calculate_quota procdure which will be invoked from the dispatcher in calc engine
PROCEDURE calculate_bonus_quota (spec_code        IN OUT NOCOPY cn_utils.code_type,
                                 body_code        IN OUT NOCOPY cn_utils.code_type )
IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;
    package_spec_id        cn_obj_packages_v.package_id%TYPE;
    x_repository_id        cn_repositories.repository_id%TYPE;

    l_input_sql_select        VARCHAR2(8000);
    l_input_sql_from        varchar2(4000);
    l_input_sql_select_clob clob;
    l_input_sql_from_clob   clob;
    l_input_sql_where   varchar2(4000) := 'WHERE 1=1 ';
    l_counter NUMBER;
    l_ctr NUMBER;
    l_dim_unit_code VARCHAR2(30);

    CURSOR l_mul_inputs_csr IS
       SELECT calc_sql_exp_id, rate_dim_sequence, nvl(split_flag, 'N') split_flag
         FROM cn_formula_inputs_all
         WHERE calc_formula_id = g_formula_id
         AND org_id = g_org_id
         ORDER BY rate_dim_sequence;

    -- cursor to get the dim_unit_code
    CURSOR dim_type(p_rate_dim_sequence NUMBER) IS
       SELECT dim_unit_code
	 FROM cn_rate_dimensions_all
	 WHERE rate_dimension_id = (SELECT rate_dimension_id
				    FROM cn_rate_sch_dims_all
				    WHERE rate_dim_sequence = p_rate_dim_sequence
				      AND rate_schedule_id = (SELECT rate_schedule_id
							      FROM cn_rt_formula_asgns_all
							      WHERE calc_formula_id = g_formula_id
                                    AND org_id = g_org_id
							      AND ROWNUM = 1));

    CURSOR l_input_sql_select_from_csr (l_calc_sql_exp_id NUMBER) IS
       SELECT  sql_select input_sql_select, sql_from input_sql_from
         FROM  cn_calc_sql_exps_all
         WHERE calc_sql_exp_id = l_calc_sql_exp_id
		   AND org_id = g_org_id;

    l_output_sql_select        varchar2(8000);
    l_output_sql_from        varchar2(4000);
    l_output_sql_select_clob clob;
    l_output_sql_from_clob   clob;

    l_output_sql_where   varchar2(4000) := 'WHERE 1=1 ';

    CURSOR l_output_select_from_csr IS
       SELECT  sql_select output_sql_select, sql_from output_sql_from
         FROM cn_calc_sql_exps_all
         WHERE calc_sql_exp_id = (SELECT output_exp_id
                                  FROM  cn_calc_formulas_all
                                  WHERE  calc_formula_id = g_formula_id
                                    AND org_id = g_org_id);

    CURSOR l_perf_select_from_csr IS
       select  sql_select, sql_from
         from cn_calc_sql_exps_all
         where calc_sql_exp_id = g_perf_measure_id;

    CURSOR l_inp_perf_select_from_csr IS
       SELECT sql_select input_sql_select, sql_from input_sql_from
         FROM cn_calc_sql_exps_all
         WHERE calc_sql_exp_id = (SELECT calc_sql_exp_id
                                  FROM cn_formula_inputs_all
                                  WHERE calc_formula_id = g_formula_id
                                  AND org_id = g_org_id
                                  AND rate_dim_sequence = 1);

    l_perf_sql_select        varchar2(8000);
    l_perf_sql_from        varchar2(4000);
    l_perf_sql_select_clob clob;
    l_perf_sql_from_clob   clob;

    l_perf_sql_where   varchar2(4000) := 'WHERE 1=1 ';

    CURSOR l_all_columns_csr (l_table_id NUMBER ) IS
       SELECT lower(name) column_name, data_type
         FROM cn_objects_all
         WHERE table_id = l_table_id
         AND org_id = g_org_id
         AND object_type = 'COL'
         AND primary_key = 'Y'
         AND position IS NOT NULL
           ORDER BY position;
BEGIN
     procedure_name := 'calculate_quota';
     procedure_desc := 'This procedure is the hook to the calculation engine';

     parameter_list := 'p_srp_plan_assign_id NUMBER, p_salesrep_id NUMBER, p_period_id NUMBER, ';
     parameter_list := parameter_list || 'p_start_date DATE, p_quota_id NUMBER, p_process_all_flag VARCHAR2, ';
     parameter_list := parameter_list || ' p_intel_calc_flag VARCHAR2, p_calc_type VARCHAR2 ';
     parameter_list := parameter_list || ',p_credit_type_id NUMBER, p_role_id NUMBER, x_latest_processed_date OUT NOCOPY DATE           ';

     proc_init(procedure_name, procedure_desc, parameter_list, 'P', null , package_spec_id, x_repository_id, spec_code, body_code);

     cn_utils.appindcr(body_code, '  l_mul_input_tbl           ' || 'cn_formula_common_pkg.mul_input_tbl_type; ');
     cn_utils.appindcr(body_code, '  p_rate                     NUMBER;');
     cn_utils.appindcr(body_code, '  l_rate_tier_id             NUMBER(15); ');
     cn_utils.appindcr(body_code, '  l_tier_split               NUMBER(15); ');
     cn_utils.appindcr(body_code, '  l_input                    cn_formula_common_pkg.num_table_type; ');
     cn_utils.appindcr(body_code, '  l_input_string             VARCHAR2(30);');
     cn_utils.appindcr(body_code, '  l_commission               NUMBER; ');
     cn_utils.appindcr(body_code, '  l_perf                     NUMBER; ');
     cn_utils.appindcr(body_code, '  l_processed_date           DATE; ');
     cn_utils.appindcr(body_code, '  l_error_reason             VARCHAR2(150); ');
     cn_utils.appindcr(body_code, '  l_name                     VARCHAR2(255); ');
     cn_utils.appindcr(body_code, '  l_trx_rec                  cn_formula_common_pkg.trx_rec_type; ');
     cn_utils.appindcr(body_code, '  l_trx_rec_null             cn_formula_common_pkg.trx_rec_type; ');
     cn_utils.appindcr(body_code, '  l_rollover                 NUMBER := 0; ');
     cn_utils.appendcr(body_code);

     -- constructing input cursor here
     l_counter := 1;
     FOR l_mul_input IN l_mul_inputs_csr LOOP
        l_input_sql_where  := 'WHERE 1=1 ';

        OPEN l_input_sql_select_from_csr(l_mul_input.calc_sql_exp_id);
        FETCH l_input_sql_select_from_csr
          INTO l_input_sql_select_clob, l_input_sql_from_clob;
        CLOSE l_input_sql_select_from_csr;

        convert_clob_to_string(l_input_sql_select_clob, l_input_sql_select);
        l_input_sql_select := lower_str( 'select ' || l_input_sql_select );
        convert_clob_to_string(l_input_sql_from_clob, l_input_sql_from);
        l_input_sql_from := lower( 'from ' || l_input_sql_from );

        construct_sql_from_where (l_input_sql_select,
                                  l_input_sql_from,
                                  l_input_sql_where );
        -- special logic for first input
        IF l_mul_inputs_csr%rowcount = 1 THEN
           g_external_table_id := NULL;
           handle_bonus_ex_tbl_orderby(l_input_sql_select,
                                       l_input_sql_from,
                                       l_input_sql_where,
                                       'INPUT1' );
           -- if there is external_table in input
           -- declare the parameters corresponding to the primray key columns of the external tbl
           IF g_external_table_id IS NOT NULL THEN
              FOR l_column IN l_all_columns_csr(g_external_table_id) LOOP
                 l_ctr := l_all_columns_csr%rowcount;
                 IF l_column.data_type IN ('CHAR', 'VARCHAR2', 'NCHAR', 'NVARCHAR2' ) THEN
                    cn_utils.appindcr(body_code, '  l_parameter_'|| l_ctr
                                      || '    ' || l_column.data_type || ' (1000); ' );
                  ELSE
                    cn_utils.appindcr(body_code, '  l_parameter_'|| l_ctr
                                      || '    ' || l_column.data_type || ';' );
                 END IF;
              END LOOP;
           END IF;
           cn_utils.appendcr(body_code);

           cn_utils.appindcr(body_code, '  CURSOR l_input_csr_'|| l_counter || ' IS ' );
           split_long_sql( body_code, l_input_sql_select, 'SELECT');
           split_long_sql( body_code, l_input_sql_from, 'FROM');
           split_long_sql( body_code, l_input_sql_where||';', 'WHERE');
           cn_utils.appendcr(body_code);

           IF g_external_table_id IS NOT NULL THEN
              l_input_sql_where  := 'WHERE 1=1 ';

              OPEN l_input_sql_select_from_csr(l_mul_input.calc_sql_exp_id);
              FETCH l_input_sql_select_from_csr
                INTO l_input_sql_select_clob, l_input_sql_from_clob;
              CLOSE l_input_sql_select_from_csr;

              convert_clob_to_string(l_input_sql_select_clob, l_input_sql_select);
              l_input_sql_select := lower_str( 'select ' || l_input_sql_select );
              convert_clob_to_string(l_input_sql_from_clob, l_input_sql_from);
              l_input_sql_from := lower( 'from ' || l_input_sql_from );

              construct_sql_from_where (l_input_sql_select,
                                        l_input_sql_from,
                                        l_input_sql_where );

              handle_bonus_ex_tbl_orderby(l_input_sql_select,
                                          l_input_sql_from,
                                          l_input_sql_where,
                                          'INPUT0' );

              cn_utils.appindcr(body_code, '  CURSOR l_input_csr_0 IS ' );
              split_long_sql( body_code, l_input_sql_select, 'SELECT');
              split_long_sql( body_code, l_input_sql_from, 'FROM');
              split_long_sql( body_code, l_input_sql_where||';', 'WHERE');
              cn_utils.appendcr(body_code);
           END IF;

         ELSE
           handle_bonus_ex_tbl_orderby(l_input_sql_select,
                                       l_input_sql_from,
                                       l_input_sql_where,
                                       'INPUT' );

           cn_utils.appindcr(body_code, '  CURSOR l_input_csr_'|| l_counter || ' IS ' );
           split_long_sql( body_code, l_input_sql_select, 'SELECT');
           split_long_sql( body_code, l_input_sql_from, 'FROM');
           split_long_sql( body_code, l_input_sql_where||';', 'WHERE');
           cn_utils.appendcr(body_code);
        END IF;

        l_counter := l_counter+1;
     END LOOP;

     -- constructing output_cursro here
     OPEN l_output_select_from_csr;
     FETCH l_output_select_from_csr
       INTO l_output_sql_select_clob, l_output_sql_from_clob;
     CLOSE l_output_select_from_csr;

     convert_clob_to_string(l_output_sql_select_clob, l_output_sql_select);
     l_output_sql_select := lower_str( 'select ' || l_output_sql_select );
     convert_clob_to_string(l_output_sql_from_clob, l_output_sql_from);
     l_output_sql_from := lower( 'from ' || l_output_sql_from );

     g_rate_flag := check_sql_stmt_existence(l_output_sql_select, 'rateresult');

     construct_sql_from_where(l_output_sql_select,
                              l_output_sql_from,
                              l_output_sql_where    );

     handle_output_sql_select(l_output_sql_select,
                              l_output_sql_from,
                              l_output_sql_where    );

     handle_bonus_ex_tbl_orderby(l_output_sql_select,
                                 l_output_sql_from,
                                 l_output_sql_where,
                                 'OUTPUT' );

     cn_utils.appindcr(body_code, '  CURSOR l_output_csr IS ' );
     split_long_sql( body_code, l_output_sql_select, 'SELECT');
     split_long_sql( body_code, l_output_sql_from, 'FROM');
     split_long_sql( body_code, l_output_sql_where||';', 'WHERE');
     cn_utils.appendcr(body_code);

     -- constructing perf_cursor here
     IF g_perf_measure_id IS NOT NULL THEN
        OPEN l_perf_select_from_csr;
        FETCH l_perf_select_from_csr
          INTO l_perf_sql_select_clob, l_perf_sql_from_clob;
        CLOSE l_perf_select_from_csr;

        convert_clob_to_string( l_perf_sql_select_clob, l_perf_sql_select);
        l_perf_sql_select := lower_str('select sum( ' || l_perf_sql_select || ' ) ' );
        convert_clob_to_string( l_perf_sql_from_clob, l_perf_sql_from);
        l_perf_sql_from := lower('from ' || l_perf_sql_from);
      ELSE   /* default to be the input with the lowest input_sequence */
        OPEN l_inp_perf_select_from_csr;
        FETCH l_inp_perf_select_from_csr
          INTO l_perf_sql_select_clob, l_perf_sql_from_clob;
        CLOSE l_inp_perf_select_from_csr;

        convert_clob_to_string( l_perf_sql_select_clob, l_perf_sql_select);
        l_perf_sql_select := lower_str('select sum( ' || l_perf_sql_select || ' ) ' );
        convert_clob_to_string( l_perf_sql_from_clob, l_perf_sql_from);
        l_perf_sql_from := lower('from ' || l_perf_sql_from);
     END IF;

     construct_sql_from_where(l_perf_sql_select,
                              l_perf_sql_from,
                              l_perf_sql_where     );

     handle_bonus_ex_tbl_orderby(l_perf_sql_select,
                                 l_perf_sql_from,
                                 l_perf_sql_where,
                                 'PERF'            );

     cn_utils.appindcr(body_code, '  CURSOR l_perf_csr IS ' );
     split_long_sql( body_code, l_perf_sql_select, 'SELECT');
     split_long_sql( body_code, l_perf_sql_from, 'FROM');
     split_long_sql( body_code, l_perf_sql_where||';', 'WHERE');

     -- finish contructing input/output/perf cursors
     cn_utils.appendcr(body_code, 'BEGIN');
     cn_utils.appindcr(body_code, '  g_intel_calc_flag := p_intel_calc_flag;');
     cn_utils.appindcr(body_code, '  g_calc_type := p_calc_type;');
     calc_init(spec_code, body_code);

     FOR i IN 1..g_number_dim LOOP
	cn_utils.appindcr(body_code, '  l_input('||i||') := 0;        ');
     END LOOP;

     IF g_external_table_id IS NOT NULL THEN
        cn_utils.appindcr(body_code, ' FOR l_csr_0 IN l_input_csr_0 LOOP ');
        cn_utils.appindcr(body_code, '   BEGIN ');
        FOR l_column IN l_all_columns_csr(g_external_table_id) LOOP
           cn_utils.appindcr(body_code, '     l_parameter_'||
                             To_char(l_all_columns_csr%rowcount) || ' := l_csr_0.'
                             || l_column.column_name || ' ;');
        END LOOP;
        cn_utils.appendcr(body_code);
      ELSE
        cn_utils.appindcr(body_code, '   BEGIN ');
     END IF;
     cn_utils.appindcr(body_code, '  l_trx_rec  := l_trx_rec_null; ');
     FOR l_mul_input IN l_mul_inputs_csr LOOP
        l_ctr := l_mul_inputs_csr%rowcount;
        cn_utils.appindcr(body_code, '     OPEN l_input_csr_' || l_ctr || ' ;' );

	OPEN dim_type(l_mul_input.rate_dim_sequence);
	FETCH dim_type INTO l_dim_unit_code;
	CLOSE dim_type;

	IF (l_dim_unit_code = 'STRING') THEN
	   cn_utils.appindcr(body_code, '     FETCH l_input_csr_' || l_ctr||' INTO l_input_string; ');
	ELSE
	   cn_utils.appindcr(body_code, '     FETCH l_input_csr_' || l_ctr||' INTO l_input('||l_mul_input.rate_dim_sequence||'); ');
        END IF;

        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '     IF l_input_csr_'|| l_ctr || '%notfound THEN ');
        cn_utils.appindcr(body_code, '        raise no_data_found; ');
        cn_utils.appindcr(body_code, '     END IF;  ');
        cn_utils.appendcr(body_code);
        cn_utils.appindcr(body_code, '     l_mul_input_tbl(' || l_ctr ||').rate_dim_sequence := '
                          || l_mul_input.rate_dim_sequence || ' ; ' );

        IF (l_dim_unit_code = 'STRING') THEN
          cn_utils.appindcr(body_code, '     l_mul_input_tbl('|| l_ctr ||').input_string := l_input_string;' );
        ELSE
          cn_utils.appindcr(body_code, '     l_mul_input_tbl('|| l_ctr ||').input_amount := l_input('||l_mul_input.rate_dim_sequence||');');
          cn_utils.appindcr(body_code, '     l_mul_input_tbl('|| l_ctr ||').amount := l_input('||l_mul_input.rate_dim_sequence||');' );
        END IF;

        IF (l_mul_input.split_flag <> 'N') THEN --IF g_split_flag <> 'N' THEN
           cn_utils.appindcr(body_code, '     l_mul_input_tbl(' || l_ctr || ').base_amount := 0;' );
         ELSE
           cn_utils.appindcr(body_code, '     l_mul_input_tbl(' || l_ctr || ').base_amount := l_input('||l_mul_input.rate_dim_sequence||');' );
        END IF;
        cn_utils.appindcr(body_code, '     CLOSE l_input_csr_' || l_ctr || ' ;' );
        cn_utils.appendcr(body_code);
     END LOOP;

     --cn_utils.appindcr(body_code, '     l_input := l_mul_input_tbl(1).input_amount; ');
     cn_utils.appendcr(body_code);
     -- get_rates
     IF g_rate_flag THEN
        cn_utils.appindcr(body_code, '     cn_formula_common_pkg.get_rates( p_salesrep_id, p_srp_plan_assign_id,');
        cn_utils.appindcr(body_code, '                 p_period_id, p_quota_id , g_split_flag, g_itd_flag,');
        cn_utils.appindcr(body_code, '                 p_start_date, g_number_dim,l_mul_input_tbl, ');
        cn_utils.appindcr(body_code, '                 g_formula_id, p_rate, l_rate_tier_id, l_tier_split ); ');
        cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Commission rate=''|| p_rate);');
     END IF;
     cn_utils.appendcr(body_code);
     -- get_commission
     cn_utils.appindcr(body_code, '     OPEN l_output_csr; ');
     cn_utils.appindcr(body_code, '     FETCH l_output_csr INTO l_commission; ');
     cn_utils.appindcr(body_code, '     IF l_output_csr%notfound THEN ');
     cn_utils.appindcr(body_code, '        raise no_data_found; ');
     cn_utils.appindcr(body_code, '     END IF;  ');
     cn_utils.appindcr(body_code, '     CLOSE l_output_csr; ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Output=''||l_commission);');
     cn_utils.appendcr(body_code);
     -- get perf need more thought
     cn_utils.appindcr(body_code, '     OPEN l_perf_csr; ');
     cn_utils.appindcr(body_code, '     FETCH l_perf_csr INTO l_perf; ');
     cn_utils.appindcr(body_code, '     IF l_perf_csr%notfound THEN ');
     cn_utils.appindcr(body_code, '        raise no_data_found; ');
     cn_utils.appindcr(body_code, '     END IF;  ');
     cn_utils.appindcr(body_code, '     CLOSE l_perf_csr; ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Performance measure=''||l_perf);');
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '     x_latest_processed_date := p_start_date;    ');
     cn_utils.appendcr(body_code);
     -- update all global variables
     update_variables(spec_code, body_code);
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '     l_trx_rec.commission_amount := l_commission ;');
     cn_utils.appindcr(body_code, '     l_trx_rec.commission_rate := p_rate ; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.rate_tier_id := l_rate_tier_id ;');
     cn_utils.appindcr(body_code, '     l_trx_rec.tier_split := l_tier_split ;');
     cn_utils.appindcr(body_code, '     l_trx_rec.input_achieved := g_input_achieved_itd(1); ');
     cn_utils.appindcr(body_code, '     l_trx_rec.output_achieved := g_output_achieved_itd; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.perf_achieved := l_perf; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.status := ''CALC''; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.credit_type_id := p_credit_type_id; ');
     cn_utils.appindcr(body_code, '   EXCEPTION WHEN OTHERS THEN ');

     FOR l_mul_input IN l_mul_inputs_csr LOOP
        l_ctr := l_mul_inputs_csr%rowcount;
        cn_utils.appindcr(body_code, '     IF l_input_csr_' || l_ctr || '%isopen THEN ' );
        cn_utils.appindcr(body_code, '        CLOSE l_input_csr_' || l_ctr || ' ;' );
        cn_utils.appindcr(body_code, '     END IF; ');
     END LOOP;
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '     IF l_output_csr%isopen THEN ' );
     cn_utils.appindcr(body_code, '        CLOSE l_output_csr; ');
     cn_utils.appindcr(body_code, '     END IF; ');
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '     IF l_perf_csr%isopen THEN ' );
     cn_utils.appindcr(body_code, '        CLOSE l_perf_csr; ');
     cn_utils.appindcr(body_code, '     END IF; ');
     cn_utils.appendcr(body_code);
     -- how to handle exception  -->create a trx with status 'XCALC' that has the error_reason
     cn_utils.appindcr(body_code, '     l_trx_rec.error_reason := substr(sqlerrm,1,150);  ');
     cn_utils.appindcr(body_code, '     l_trx_rec.status := ''XCALC''; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.commission_amount := 0 ;');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Exception occurs in formula calculate_bonus_quota:''); ' );
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(sqlerrm); ' );
     cn_utils.appindcr(body_code, '   END; ');
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '     l_trx_rec.salesrep_id := p_salesrep_id; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.srp_plan_assign_id := p_srp_plan_assign_id; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.quota_id := p_quota_id; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.processed_date := p_start_date; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.processed_period_id := p_period_id; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.pay_period_id :=  p_period_id; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.posting_status := ''UNPOSTED''; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.pending_status := null; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.created_during := ''CALC''; ');
     cn_utils.appindcr(body_code, '     l_trx_rec.trx_type := ''BONUS'' ; ');
     cn_utils.appindcr(body_code, '     cn_formula_common_pkg.create_trx(l_trx_rec); ');
     -- create_bonus_trx;
     cn_utils.appendcr(body_code);
     IF g_external_table_id IS NOT NULL THEN
        cn_utils.appindcr(body_code, ' END LOOP; ');
        -- cn_utils.appindcr(body_code, ' CLOSE l_input_csr_0; ');
     END IF;
     -- contructing calc_roll
     calc_roll(spec_code, body_code);
     cn_utils.appindcr(body_code, ' EXCEPTION ' );
     cn_utils.appindcr(body_code, '   when others then ');
     FOR l_mul_input IN l_mul_inputs_csr LOOP
        l_ctr := l_mul_inputs_csr%rowcount;
        cn_utils.appindcr(body_code, '     IF l_input_csr_' || l_ctr || '%isopen THEN ' );
        cn_utils.appindcr(body_code, '        CLOSE l_input_csr_' || l_ctr || ' ;' );
        cn_utils.appindcr(body_code, '     END IF; ');
     END LOOP;
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '     IF l_output_csr%isopen THEN ' );
     cn_utils.appindcr(body_code, '        CLOSE l_output_csr; ');
     cn_utils.appindcr(body_code, '     END IF; ');
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '     IF l_perf_csr%isopen THEN ' );
     cn_utils.appindcr(body_code, '        CLOSE l_perf_csr; ');
     cn_utils.appindcr(body_code, '     END IF; ');
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '     if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
     cn_utils.appindcr(body_code, '       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
     cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.calculate_bonus_quota.exception'', ');
     cn_utils.appindcr(body_code, '	          sqlerrm); ');
     cn_utils.appindcr(body_code, '     end if; ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Exception occurs in calculate_bonsu_quota:''); ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(sqlerrm); ' );
     cn_utils.appindcr(body_code, '     raise; ');

     cn_utils.proc_end( procedure_name, 'N', body_code );
EXCEPTION
  when others then
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.calculate_bonus_quota.exception',
         	          sqlerrm);
    end if;
    raise;
END calculate_bonus_quota;

--   construct the get_forecast_commission procdure which will be invoked by Income Planner
PROCEDURE get_forecast_commission(spec_code        IN OUT NOCOPY cn_utils.code_type,
                                  body_code        IN OUT NOCOPY cn_utils.code_type )
IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;

    l_rate_dim_sequence NUMBER;
    l_sql_select        VARCHAR2(8000);
    l_sql_from          VARCHAR2(4000);
    l_sql_where         VARCHAR2(4000);
    l_counter           NUMBER := 1;
    l_dim_unit_code     VARCHAR2(30);
    l_calc_sql_exp_id   NUMBER;
    l_output_exp_id     NUMBER;

    l_operator_position NUMBER;
    l_operator          VARCHAR2(1);

    CURSOR f_output IS
       SELECT f_output_exp_id
         FROM cn_calc_formulas_all
         WHERE calc_formula_id = g_formula_id
           AND org_id = g_org_id;

    CURSOR f_inputs IS
       SELECT rate_dim_sequence, f_calc_sql_exp_id, cumulative_flag, split_flag
         FROM cn_formula_inputs_all
         WHERE calc_formula_id = g_formula_id
           AND org_id = g_org_id;

    CURSOR dim_type(p_rate_dim_sequence NUMBER) IS
       SELECT dim_unit_code
         FROM cn_rate_dimensions_all
         WHERE rate_dimension_id = (SELECT rate_dimension_id
                                    FROM cn_rate_sch_dims_all
                                    WHERE rate_dim_sequence = p_rate_dim_sequence
                                      AND rate_schedule_id = (SELECT rate_schedule_id
                                                              FROM cn_rt_formula_asgns_all
                                                              WHERE calc_formula_id = g_formula_id
                                                              AND org_id = g_org_id
                                                              AND ROWNUM = 1));

    CURSOR sql_statement(p_calc_sql_exp_id NUMBER) IS
       SELECT  dbms_lob.substr(sql_select), dbms_lob.substr(sql_from)
         FROM  cn_calc_sql_exps_all
         WHERE calc_sql_exp_id = p_calc_sql_exp_id;
BEGIN
     OPEN f_output;
     FETCH f_output INTO l_output_exp_id;
     CLOSE f_output;

     -- if there is no forecasting expressions, then return
     IF (l_output_exp_id IS NULL) THEN
        RETURN;
     END IF;

     procedure_name := 'get_forecast_commission';
     procedure_desc := '   Called by Income Planner to forecast commissions';

     parameter_list := 'p_srp_plan_assign_id NUMBER, p_salesrep_id NUMBER, ';
     parameter_list := parameter_list || 'p_start_period_id NUMBER, p_forecast_period_id NUMBER, p_quota_id NUMBER,  ';
     parameter_list := parameter_list || 'p_forecast_amount NUMBER, x_projected_commission OUT NOCOPY NUMBER ';

     proc_init(procedure_name, procedure_desc, parameter_list,
               'P', null , null, null,
               spec_code, body_code);

     cn_utils.appindcr(body_code, '  l_mul_input_tbl            ' || 'cn_formula_common_pkg.mul_input_tbl_type; ');
     cn_utils.appindcr(body_code, '  p_rate                     NUMBER;');
     cn_utils.appindcr(body_code, '  l_rate_tier_id             NUMBER;');
     cn_utils.appindcr(body_code, '  l_tier_split               NUMBER;');
     cn_utils.appindcr(body_code, '  l_input                    NUMBER; ');
     cn_utils.appindcr(body_code, '  l_input_string             VARCHAR2(30); ');
     cn_utils.appindcr(body_code, '  l_commission               NUMBER; ');
     cn_utils.appindcr(body_code, '  l_itd_target               NUMBER; ');
     cn_utils.appindcr(body_code, '  l_itd_payment              NUMBER; ');
     cn_utils.appindcr(body_code, '  l_processed_date           DATE; ');
     cn_utils.appindcr(body_code, '  p_period_id                NUMBER; ');
     cn_utils.appindcr(body_code, '  p_start_date               DATE; ');
     cn_utils.appindcr(body_code, '  p_process_all_flag         VARCHAR2(1) := ''Y'';');
     cn_utils.appendcr(body_code, 'BEGIN');

     cn_utils.appindcr(body_code, '  g_calc_type := ''FORECAST'';');

     cn_utils.appindcr(body_code, '  p_period_id := p_start_period_id; ');

     -- when initialize _itd global variables, set the period_id to be the first period in the forecasting interval


     /*cn_utils.appindcr(body_code, '  p_period_id := cn_api.get_acc_period_id(trunc(sysdate));');
     cn_utils.appindcr(body_code, '  if (p_period_type = ''Q'') then ');
     cn_utils.appindcr(body_code, '    p_period_id := cn_formula_common_pkg.get_quarter_start_period_id(p_quota_id, p_period_id);');
     cn_utils.appindcr(body_code, '  elsif (p_period_type = ''Y'') then ');
     cn_utils.appindcr(body_code, '    p_period_id := cn_formula_common_pkg.get_start_period_id(p_quota_id, p_period_id);');
     cn_utils.appindcr(body_code, '  end if; ');*/


     calc_init(spec_code, body_code);

     /*cn_utils.appindcr(body_code, '  if (p_period_type = ''Q'') then ');
     cn_utils.appindcr(body_code, '    p_period_id := cn_formula_common_pkg.get_quarter_end_period_id(p_quota_id, p_period_id);');
     cn_utils.appindcr(body_code, '  elsif (p_period_type = ''Y'') then ');
     cn_utils.appindcr(body_code, '    p_period_id := cn_formula_common_pkg.get_end_period_id(p_quota_id, p_period_id);');
     cn_utils.appindcr(body_code, '  end if; ');*/


     cn_utils.appindcr(body_code, '  p_period_id := p_forecast_period_id; ');

     FOR input IN f_inputs LOOP
        OPEN dim_type(input.rate_dim_sequence);
        FETCH dim_type INTO l_dim_unit_code;
        CLOSE dim_type;

        l_sql_where := 'WHERE 1 = 1 ';

        OPEN sql_statement(input.f_calc_sql_exp_id);
        FETCH sql_statement INTO l_sql_select, l_sql_from;
        CLOSE sql_statement;

        l_sql_select := REPLACE(l_sql_select, 'ForecastAmount', 'p_forecast_amount');
        l_sql_select := 'select ' || lower_str(l_sql_select);
        l_sql_from := 'from ' || lower(l_sql_from);

        construct_sql_from_where(l_sql_select, l_sql_from, l_sql_where);

        split_long_sql(body_code, l_sql_select, 'SELECT');
        IF (l_dim_unit_code = 'STRING') THEN
           cn_utils.appindcr(body_code, ' into l_input_string ');
         ELSE
           cn_utils.appindcr(body_code, ' into l_input ');
        END IF;
        split_long_sql(body_code, l_sql_from, 'FROM');
        split_long_sql(body_code, l_sql_where || ';', 'WHERE');

        cn_utils.appindcr(body_code, '  l_input := nvl(l_input, 0); ');
        cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter || ').rate_dim_sequence := ' || input.rate_dim_sequence || ';');

        IF (l_dim_unit_code = 'STRING') THEN
           cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter || ').input_string := l_input_string;' );
         ELSE
           cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter || ').input_amount := l_input;' );
           cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter ||').amount := l_input;' );
        END IF;

        IF (input.cumulative_flag = 'N') THEN --IF (g_cumulative_flag = 'N') THEN
           IF (input.split_flag <> 'N') THEN --IF (g_split_flag <> 'N') THEN
              cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter || ').base_amount := 0;');
            ELSE
              cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter || ').base_amount := l_input;');
           END IF;
         ELSE
           IF g_itd_flag = 'N' THEN
              IF (input.split_flag <> 'N') THEN --IF g_split_flag <> 'N' THEN
                 IF (g_trx_group_code = 'GROUP') THEN
                    cn_utils.appindcr(body_code, ' l_mul_input_tbl(' || l_counter || ').base_amount := 0;');
                  ELSE
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter || ').base_amount := g_input_achieved_itd('
                                      ||input.rate_dim_sequence||');' );
                 END IF;
               ELSE
                 IF (g_trx_group_code = 'GROUP') THEN
                    cn_utils.appindcr(body_code, ' l_mul_input_tbl(' || l_counter || ').base_amount := l_input;');
                  ELSE
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter || ').base_amount := g_input_achieved_itd('||
                                      input.rate_dim_sequence||')+ l_input;' );
                 END IF;
              END IF;
            ELSE
              cn_utils.appendcr(body_code);
              IF g_pq_target_flag OR g_spq_target_flag  THEN
                 IF g_pq_target_flag THEN
                    cn_utils.appindcr(body_code, '  l_itd_target := cn_formula_common_pkg.get_pq_itd_target ');
                    cn_utils.appindcr(body_code, '                              ( p_period_id, p_quota_id  );' );
                 END IF;

                 IF g_spq_target_flag THEN
                    cn_utils.appindcr(body_code, '  l_itd_target := cn_formula_common_pkg.get_spq_itd_target ');
                    cn_utils.appindcr(body_code, '                         ( p_salesrep_id, p_srp_plan_assign_id, ' );
                    cn_utils.appindcr(body_code, '                           p_period_id, p_quota_id             ); ');

                    IF (g_rollover_flag = 'Y') THEN
                       cn_utils.appindcr(body_code, ' SELECT l_itd_target + total_rollover ');
                       cn_utils.appindcr(body_code, '   INTO l_itd_target ');
                       cn_utils.appindcr(body_code, '   FROM cn_srp_period_quotas_all ');
                       cn_utils.appindcr(body_code, '  WHERE srp_plan_assign_id = p_srp_plan_assign_id ');
                       cn_utils.appindcr(body_code, '    AND quota_id = p_quota_id ');
                       cn_utils.appindcr(body_code, '    AND period_id = p_period_id; ');
                    END IF;
                 END IF;

                 cn_utils.appendcr(body_code);

                 IF (input.split_flag <> 'N') THEN --IF g_split_flag <> 'N' THEN
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl('|| l_counter || ').amount := (l_input + g_input_achieved_itd('
                                      ||input.rate_dim_sequence||')) ');
                    cn_utils.appindcr(body_code, '     /l_itd_target;' );
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter || ').base_amount := 0;' );
                  ELSE
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl('|| l_counter || ').amount := l_input / l_itd_target; ');
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl('|| l_counter || ').base_amount := (l_input + g_input_achieved_itd('
                                      ||input.rate_dim_sequence||'))');
                    cn_utils.appindcr(body_code, '      /l_itd_target;' );
                 END IF;
               ELSE
                 IF (input.split_flag <> 'N') THEN --IF g_split_flag <> 'N' THEN
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl('|| l_counter || ').amount := l_input + g_input_achieved_itd('
                                      ||input.rate_dim_sequence||');' );
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl(' || l_counter || ').base_amount := 0;' );
                  ELSE
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl('|| l_counter || ').amount := l_input; ');
                    cn_utils.appindcr(body_code, '  l_mul_input_tbl('|| l_counter || ').base_amount := l_input + g_input_achieved_itd('
                                      ||input.rate_dim_sequence||');' );
                 END IF;
              END IF;
           END IF;
        END IF;
        cn_utils.appendcr(body_code);
        l_counter := l_counter+1;
     END LOOP;

     OPEN f_output;
     FETCH f_output INTO l_calc_sql_exp_id;
     CLOSE f_output;

     OPEN sql_statement(l_calc_sql_exp_id);
     FETCH sql_statement INTO l_sql_select, l_sql_from;

     l_sql_select := REPLACE(l_sql_select, 'ForecastAmount', 'p_forecast_amount');
     l_sql_select := lower_str( 'select ' || l_sql_select);
     l_sql_from := lower('from ' || l_sql_from);
     l_sql_where := 'where 1 = 1 ';

     g_rate_flag := check_sql_stmt_existence(l_sql_select, 'rateresult');

     l_operator_position := search_delimiter_select(l_sql_select, 1);
     IF l_operator_position > 0 THEN
        l_operator := substr(l_sql_select, l_operator_position, 1);
     END IF;

     IF g_rate_flag THEN
        -- get processed date (end_date of the last period in the forecast date range)
        cn_utils.appindcr(body_code, '      SELECT end_date into l_processed_date ');
        cn_utils.appindcr(body_code, '        FROM cn_acc_period_statuses_v             ');
        cn_utils.appindcr(body_code, '        WHERE period_id = p_period_id       ');
        cn_utils.appindcr(body_code, '          AND org_id = g_org_id;       ');

        cn_utils.appindcr(body_code, '  cn_formula_common_pkg.get_rates( p_salesrep_id, p_srp_plan_assign_id,');
        cn_utils.appindcr(body_code, '                 p_period_id, p_quota_id , g_split_flag,g_itd_flag, ' );
        cn_utils.appindcr(body_code, '                 l_processed_date, g_number_dim,l_mul_input_tbl, ');
        cn_utils.appindcr(body_code, '                 g_formula_id, p_rate, l_rate_tier_id, l_tier_split ); ');
     END IF;

     construct_sql_from_where(l_sql_select, l_sql_from, l_sql_where);
     handle_output_sql_select(l_sql_select, l_sql_from, l_sql_where);
     split_long_sql(body_code, l_sql_select, 'SELECT');
     cn_utils.appindcr(body_code, '  into l_commission');
     split_long_sql(body_code, l_sql_from, 'FROM');
     split_long_sql(body_code, l_sql_where || ';', 'WHERE');
     cn_utils.appendcr(body_code);
     cn_utils.appindcr(body_code, '   l_commission := nvl(l_commission, 0); ');

     IF g_itd_flag = 'Y' THEN
        IF (g_pq_payment_flag OR g_spq_payment_flag) THEN
           IF (g_rate_flag) THEN
              IF (l_operator_position > 0) THEN
                 cn_utils.appindcr(body_code, '  l_commission := p_rate ' || l_operator || ' l_commission - g_commission_payed_itd;');
              END IF;
            ELSE
              cn_utils.appindcr(body_code, '  l_commission := l_commission - g_commission_payed_itd;');
           END IF;
         ELSE
           cn_utils.appindcr(body_code, '  g_output_achieved := l_commission;');
           IF (g_rate_flag) THEN
              IF (l_operator_position > 0) THEN
                 cn_utils.appindcr(body_code, '  l_commission := p_rate ' || l_operator ||
                                   ' (g_output_achieved_itd + g_output_achieved) - g_commission_payed_itd;');
               ELSE
                 cn_utils.appindcr(body_code, '  l_commission := p_rate - g_commission_payed_itd;');
              END IF;
            ELSE
              cn_utils.appindcr(body_code, '  l_commission := g_output_achieved_itd + g_output_achieved - g_commission_payed_itd;');
           END IF;
        END IF;
     END IF;

     cn_utils.appindcr(body_code, '  x_projected_commission := l_commission;' );

     cn_utils.appindcr(body_code, 'EXCEPTION ' );
     cn_utils.appindcr(body_code, '  when others then ');
     cn_utils.appindcr(body_code, '     if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
     cn_utils.appindcr(body_code, '       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
     cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.get_forecast_commission.exception'', ');
     cn_utils.appindcr(body_code, '	          sqlerrm); ');
     cn_utils.appindcr(body_code, '     end if; ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Exception occurs in get_forecast_commission: ''); ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(sqlerrm); ');
     cn_utils.proc_end(procedure_name, 'N', body_code );
EXCEPTION
  WHEN OTHERS THEN
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.get_forecast_commission.exception',
         	          sqlerrm);
    end if;
    raise;
END get_forecast_commission;

--- Private Function used only by get_estimated_payout procedure for SFP
FUNCTION get_sql_select(p_piped_sql_select IN VARCHAR2) RETURN VARCHAR2
IS
  l_piped_sql_select varchar2(8000);
  l_piped_sql_select_copy varchar2(8000);
  l_sql_select varchar2(8000);

  l_pipe_found number := 0;
  l_dot_found number := 0;
  l_index number := 0;
  l_begin number:= 1;

  l_segment VARCHAR2(4000);
  l_segment_orig VARCHAR2(4000);

  l_revenue VARCHAR2(30);
  l_unit VARCHAR2(30);
  l_target_replace VARCHAR2(1000);

BEGIN

l_piped_sql_select := p_piped_sql_select;
l_piped_sql_select_copy := l_piped_sql_select;

 LOOP

  l_pipe_found := INSTR(l_piped_sql_select_copy,'|', l_begin);

  IF l_pipe_found = 0
   THEN
       exit;
  END IF;

  l_segment_orig := substr(l_piped_sql_select_copy, l_begin, l_pipe_found-l_begin );

--  dbms_output.put_line(l_segment_orig);

  l_dot_found := INSTR(l_segment_orig,'.');

  IF l_dot_found <> 0 THEN

  l_revenue := 'UPPER(''REVENUE'')';
  l_unit := 'UPPER(''UNIT'')';

  l_target_replace :=  'DECODE(qc.quota_unit_code,' || l_revenue ||
  ', ( ROUND(NVL(sqc.prorated_amount,0)/NVL(pt.rounding_factor, 1))*NVL(pt.rounding_factor, 1)) ,'
  || l_unit ||
  ', (NVL(sqc.prorated_amount,0)),( ROUND(NVL(sqc.prorated_amount,0)/NVL(pt.rounding_factor, 1))*NVL(pt.rounding_factor, 1))  ) ' ;

     SELECT DECODE(l_segment_orig,
                   'CH.TRANSACTION_AMOUNT', 'p_est_achievement',
                   'CH.QUANTITY', 'p_est_achievement',
                   'CSQA.TARGET', l_target_replace,
                   'CSQA.PAYMENT_AMOUNT', 'payment_amount',
                   l_segment_orig
                   )
     INTO l_segment
     FROM dual;

     IF l_segment_orig = l_segment THEN
        l_segment := '1';
     END IF;

     l_piped_sql_select := REPLACE(l_piped_sql_select,l_segment_orig, l_segment);
  END IF;

  l_begin := l_pipe_found + 1;

 END LOOP;

  l_sql_select := REPLACE(l_piped_sql_select,'|', '');

  RETURN l_sql_select;

EXCEPTION
  WHEN OTHERS THEN
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.get_sql_select.exception',
         	          sqlerrm);
    end if;
    raise;
END;

--   construct the get_estimated_payout procdure which will be invoked by SFP quota modeling
PROCEDURE get_estimated_payout(spec_code        IN OUT NOCOPY cn_utils.code_type,
                               body_code        IN OUT NOCOPY cn_utils.code_type )
IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;

    l_sql_select        VARCHAR2(8000);
    l_piped_sql_select  VARCHAR2(8000);
    l_sql_from          VARCHAR2(4000);
    l_sql_where         VARCHAR2(4000);
    l_calc_sql_exp_id   NUMBER;
    l_output_exp_id     NUMBER;
    l_modeling_flag     VARCHAR2(30);


    CURSOR output IS
       SELECT output_exp_id, modeling_flag
         FROM cn_calc_formulas_all
         WHERE calc_formula_id = g_formula_id
           AND org_id = g_org_id;

    CURSOR input IS
       SELECT calc_sql_exp_id
         FROM cn_formula_inputs_all
         WHERE calc_formula_id = g_formula_id
          AND org_id = g_org_id;

    CURSOR sql_statement(p_calc_sql_exp_id NUMBER) IS
       SELECT  dbms_lob.substr(piped_sql_select), dbms_lob.substr(sql_select), dbms_lob.substr(sql_from)
         FROM  cn_calc_sql_exps_all
         WHERE calc_sql_exp_id = p_calc_sql_exp_id;
BEGIN
     OPEN output;
     FETCH output INTO l_output_exp_id, l_modeling_flag;
     CLOSE output;

     -- if it is not a modeling formula, then return
     IF (nvl(l_modeling_flag, 'N') <> 'Y') THEN
        RETURN;
     END IF;

     procedure_name := 'get_estimated_payout';
     procedure_desc := '   Called by Quota Modeling to calculate payout';

     parameter_list := 'p_srp_quota_cate_id IN NUMBER, p_est_achievement IN NUMBER, ';
     parameter_list := parameter_list || 'x_estimated_payout OUT NOCOPY NUMBER, x_return_status OUT NOCOPY VARCHAR2 ';

     proc_init(procedure_name, procedure_desc, parameter_list,
               'P', null , null, null,
               spec_code, body_code);

     cn_utils.appindcr(body_code, '  l_rate                     NUMBER;');
     cn_utils.appindcr(body_code, '  l_rate_tier_id             NUMBER;');
     cn_utils.appindcr(body_code, '  l_tier_split               NUMBER;');
     cn_utils.appindcr(body_code, '  l_amount                   NUMBER; ');
     cn_utils.appendcr(body_code, 'BEGIN');
     cn_utils.appendcr(body_code, '  x_return_status := fnd_api.g_ret_sts_success; ');

     OPEN input;
     FETCH input INTO l_calc_sql_exp_id;
     CLOSE input;

     l_sql_where := 'where sqc.srp_quota_cate_id = p_srp_quota_cate_id and sqc.role_id = pt.role_id and sqc.quota_category_id = qc.quota_category_id ';

     OPEN sql_statement(l_calc_sql_exp_id);
     FETCH sql_statement INTO l_piped_sql_select, l_sql_select, l_sql_from;
     CLOSE sql_statement;


     l_sql_select := get_sql_select(l_piped_sql_select);

     l_sql_select := lower_str('select ' || l_sql_select);
     l_sql_from := lower('from cn_srp_quota_cates sqc, cn_role_details_v pt, cn_quota_categories qc');

     split_long_sql(body_code, l_sql_select, 'SELECT');

     cn_utils.appindcr(body_code, ' into l_amount ');

     split_long_sql(body_code, l_sql_from, 'FROM');
     split_long_sql(body_code, l_sql_where || ';', 'WHERE');

     OPEN sql_statement(l_output_exp_id);
     FETCH sql_statement INTO l_piped_sql_select, l_sql_select, l_sql_from;
     CLOSE sql_statement;


     l_sql_select := get_sql_select(l_piped_sql_select);


     l_sql_select :=  lower_str('select ' || l_sql_select);

     l_sql_from := lower('from cn_srp_quota_cates sqc, cn_role_details_v pt, cn_quota_categories qc');
     l_sql_where := 'where sqc.srp_quota_cate_id = p_srp_quota_cate_id and sqc.role_id = pt.role_id and sqc.quota_category_id = qc.quota_category_id ';
     g_rate_flag := check_sql_stmt_existence(l_sql_select, 'rateresult');
     l_sql_select := REPLACE(l_sql_select, 'rateresult', 'l_rate');

     IF g_rate_flag THEN
        cn_utils.appindcr(body_code, '  cn_sfp_formula_cmn_pkg.get_rates( p_srp_quota_cate_id, ');
        cn_utils.appindcr(body_code, '                                    g_split_flag, ''N'', ' );
        cn_utils.appindcr(body_code, '                                    l_amount, ');
        cn_utils.appindcr(body_code, '                                    l_rate, l_rate_tier_id, l_tier_split ); ');
     END IF;

     split_long_sql(body_code, l_sql_select, 'SELECT');
     cn_utils.appindcr(body_code, '  into x_estimated_payout ');
     split_long_sql(body_code, l_sql_from, 'FROM');
     split_long_sql(body_code, l_sql_where || ';', 'WHERE');
     cn_utils.appendcr(body_code);

     cn_utils.appindcr(body_code, 'EXCEPTION ' );
     cn_utils.appindcr(body_code, '  when zero_divide then ');
     cn_utils.appindcr(body_code, '     x_return_status := ''Z''; ');
     cn_utils.appindcr(body_code, '  when others then ');
     cn_utils.appindcr(body_code, '     x_return_status := fnd_api.g_ret_sts_error; ');
     cn_utils.appindcr(body_code, '     if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then ');
     cn_utils.appindcr(body_code, '       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, ');
     cn_utils.appindcr(body_code, '          ''cn.plsql.cn_formula_'||g_formula_id||'_pkg.get_estimated_payout.exception'', ');
     cn_utils.appindcr(body_code, '	          sqlerrm); ');
     cn_utils.appindcr(body_code, '     end if; ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(''Exception occurs in get_estimated_payout: ''); ');
     cn_utils.appindcr(body_code, '     cn_message_pkg.debug(sqlerrm); ');
     cn_utils.proc_end(procedure_name, 'N', body_code );
EXCEPTION
  WHEN OTHERS THEN
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.get_estimated_payout.exception',
         	          sqlerrm);
    end if;
    raise;
END get_estimated_payout;

--   invoke all formula component constructors to create formula
FUNCTION create_formula (p_formula_id        number) RETURN BOOLEAN IS
    package_name        cn_obj_packages_v.name%TYPE;
    package_type        cn_obj_packages_v.package_type%TYPE := 'FML';
    package_spec_id        cn_obj_packages_v.package_id%TYPE;
    package_body_id        cn_obj_packages_v.package_id%TYPE;
    package_spec_desc        cn_obj_packages_v.description%TYPE;
    package_body_desc        cn_obj_packages_v.description%TYPE;
    spec_code                cn_utils.code_type;
    body_code                cn_utils.code_type;
    dummy               NUMBER(7);
    l_module_id                number(15);
    l_repository_id        cn_repositories.repository_id%TYPE;
BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.begin',
			    	'Beginning of create_formula procedure ...');
   end if;

    cn_utils.set_org_id(g_org_id);

     SELECT repository_id
       INTO l_repository_id
       FROM cn_repositories_all
      WHERE org_id = g_org_id;
     package_name := 'cn_formula_' || abs(p_formula_id) || '_' || abs(g_org_id) || '_pkg';

     check_create_object(package_name, 'PKS', package_spec_id, l_repository_id);
     check_create_object(package_name, 'PKB', package_body_id, l_repository_id);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.statement',
			    	'The formula package name is '||package_name);
   end if;

     cn_message_pkg.debug('The formula package name is ' ||package_name);

     generate_init(p_formula_id);

     -- Added for 11.5.10 formula performance Enhancment
     -- populate all necessary plsql tables with details
     -- of tables and columns used in all the expressions
     -- of this formula
     init_tab_column_list(p_formula_id);

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.progress',
			    	'After generate_init in create_formula');
   end if;

     cn_message_pkg.debug( 'after generate_init ');

     cn_utils.pkg_init(l_module_id, package_name, null, package_type, 'FORMULA',
               package_spec_id, package_body_id, package_spec_desc,
               package_body_desc, spec_code, body_code);

     pkg_variables(spec_code, body_code);

     IF g_formula_type = 'C' THEN
        get_input(spec_code, body_code);
        cn_message_pkg.debug( 'after get_input');
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.progress',
			    	'After generating get_input in create_formula');
        end if;


        get_perf(spec_code, body_code);
        cn_message_pkg.debug( 'after get_perf ');
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.progress',
			    	'After generating get_perf in create_formula');
        end if;

        get_commission(spec_code, body_code);
        cn_message_pkg.debug( 'after get_commission');
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.progress',
			    	'After generating get_commission in create_formula');
        end if;
     END IF;

     IF g_formula_type = 'C' THEN
        calculate_quota(spec_code, body_code);
        cn_message_pkg.debug( 'after calculate_quota ');
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.progress',
			    	'After generating calculate_quota in create_formula');
        end if;
      ELSIF g_formula_type = 'B' THEN
        calculate_bonus_quota(spec_code, body_code);
        cn_message_pkg.debug( 'after calculate_bonus_quota ');
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.progress',
			    	'After generating calculate_bonus_quota in create_formula');
        end if;
     END IF;

     IF (g_trx_group_code = 'INDIVIDUAL' AND g_itd_flag = 'N' AND g_cumulative_flag = 'N' AND g_formula_type = 'C') THEN
        get_result(spec_code, body_code);
        cn_message_pkg.debug( 'after get_result ');
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.progress',
			    	'After generating get_result in create_formula');
        end if;
     END IF;

     IF g_trx_group_code = 'GROUP' THEN
        update_revclass_perf(spec_code, body_code);
        cn_message_pkg.debug( 'after update_revclass_perf ');
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.progress',
			    	'After generating update_revclass_perf in create_formula');
        end if;
     END IF;

     IF (g_formula_type = 'C') THEN
        get_forecast_commission(spec_code, body_code);
        cn_message_pkg.debug( 'after get_forecast_commission');
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.progress',
			    	'After generating get_forecast_commission in create_formula');
        end if;
     END IF;

     get_estimated_payout(spec_code, body_code);

     cn_utils.pkg_end(package_name, spec_code, body_code);

     cn_utils.unset_org_id;
     RETURN TRUE;

     if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.create_formula.end',
			    	'End of create_formula');
     end if;
EXCEPTION
  when others then
    cn_utils.unset_org_id;
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.parse.exception',
         	          sqlerrm);
    end if;
    raise;
END create_formula;

  -- API name         : generate_formula
  -- Type        : Private.
  -- Pre-reqs        :
  -- Usage        :
  --
  -- Desc         : create a formula package and store in cn_sources, then submit a concurrent
  --              spool the code to a file and get it compiled against the database.
  --
  -- Parameters        :
  --  IN        :  p_api_version       NUMBER      Require
  --                    p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  --                    p_commit               VARCHAR2    Optional (FND_API.G_FALSE)
  --                    p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT        :  x_return_status     VARCHAR2(1)
  --                    x_msg_count               NUMBER
  --                    x_msg_data               VARCHAR2(2000)
  --  IN        :  p_formula_id        NUMBER(15)  Require
  --
  --  OUT       :  x_process_audit_id  NUMBER(15)
  --
  --
  -- Version        : Current version        1.0
  --                  Initial version         1.0
  --
  -- Notes        :
  --
  -- End of comments
PROCEDURE generate_formula
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_formula_id            IN  NUMBER,
      p_org_id                IN  NUMBER,
      x_process_audit_id      OUT NOCOPY NUMBER
      )
IS
    l_api_name       CONSTANT VARCHAR2(30) := 'Generate_Formula';
    l_api_version    CONSTANT NUMBER :=1.0;

    l_creation_status         BOOLEAN;
    l_request_id                NUMBER;
    l_file_name                VARCHAR2(200);
    l_call_status         BOOLEAN;
    l_dummy                          VARCHAR2(500);
    l_dev_phase                    VARCHAR2(80);
    l_dev_status                   VARCHAR2(80) := 'INCOMPLETE';
    l_status            BOOLEAN;

    sqlstring dbms_sql.varchar2s;
    empty_sqlstring dbms_sql.varchar2s;
    cursor1 INTEGER;
    i INTEGER;

    j INTEGER;
    new_line_flag BOOLEAN:=TRUE;
    retval number;

    l_pkg_object_id  NUMBER(15);
    l_error_count    NUMBER;

    l_formula_name   VARCHAR2(100);
BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT        generate_formula;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                          p_api_version ,
                                          l_api_name    ,
                                          G_PKG_NAME )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;


     -- Codes start here

     if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.generate_formula.begin',
			    	'Beginning of generate_formula ...');
     end if;

     g_org_id := p_org_id;

     l_formula_name := 'cn_formula_'|| abs(p_formula_id) || '_' || abs(g_org_id) || '_pkg';

     l_status := create_formula(p_formula_id);

     IF l_status THEN   /* formula created successfully. Continue to install it. */
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.generate_formula.progress',
			    	'Generate the PL/SQL code successfully in generate_formula');
        end if;

        SELECT co.object_id
          INTO l_pkg_object_id
          FROM cn_objects_all co
         WHERE co.name =  l_formula_name
           AND co.object_type = 'PKS'
           AND co.org_id = g_org_id;

        SELECT cs.text bulk collect INTO sqlstring
          FROM cn_source_all cs
         WHERE cs.object_id = l_pkg_object_id
           AND cs.org_id = g_org_id
         ORDER BY cs.line_no ;

        i:=1;
        j:= sqlstring.count;

        cursor1:=DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(cursor1,sqlstring,i,j,new_line_flag,DBMS_SQL.V7);
        retval:=DBMS_SQL.EXECUTE(cursor1);
        DBMS_SQL.CLOSE_CURSOR(cursor1);

        sqlstring := empty_sqlstring;

        SELECT co.object_id
          INTO l_pkg_object_id
          FROM cn_objects_all co
          WHERE co.name =  l_formula_name
          AND co.object_type = 'PKB'
          AND co.org_id = g_org_id;

        SELECT cs.text bulk collect INTO sqlstring
          FROM cn_source_all cs
          WHERE cs.object_id = l_pkg_object_id
            AND cs.org_id = g_org_id
          ORDER BY cs.line_no ;

        i:= 1;
        j:= sqlstring.count;

        cursor1:=DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(cursor1,sqlstring,i,j,new_line_flag,DBMS_SQL.V7);
        retval:=DBMS_SQL.EXECUTE(cursor1);
        DBMS_SQL.CLOSE_CURSOR(cursor1);

        -- check whether package is installed successfully
        SELECT  COUNT(*)
          INTO  l_error_count
          FROM user_errors
          WHERE name = 'CN_FORMULA_'|| abs(p_formula_id) || '_' || abs(g_org_id) || '_PKG'
          AND  TYPE IN ('PACKAGE', 'PACKAGE BODY');

        IF l_error_count = 0 THEN
           UPDATE cn_calc_formulas_all
              SET formula_status = 'COMPLETE'
            WHERE calc_formula_id = p_formula_id
              AND org_id = g_org_id;

           if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.generate_formula.progress',
			    	'Compiled formula package successfullly in generate_formula');
           end if;
         ELSE
           UPDATE cn_calc_formulas_all
              SET formula_status = 'INCOMPLETE'
            WHERE calc_formula_id = p_formula_id
              AND org_id = g_org_id;

           x_return_status := FND_API.g_ret_sts_error;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
              fnd_message.set_name('CN', 'CN_FORMULA_COMPILE_ERR');
              FND_MSG_PUB.ADD;
              if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                    'cn.plsql.cn_formula_gen_pkg.generate_formula.error',
			    	FALSE);
              end if;

           END IF;

           if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.generate_formula.progress',
			    	'Failed to Compile formula package in generate_formula');
           end if;

        END IF;
      ELSE  -- failed to created formula package
        if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.generate_formula.progress',
			    	'Failed to generate the PL/SQL code in generate_formula');
        end if;

        UPDATE cn_calc_formulas_all
           SET formula_status = 'INCOMPLETE'
         WHERE calc_formula_id = p_formula_id
           AND org_id = g_org_id;

        x_return_status := FND_API.g_ret_sts_error;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
           fnd_message.set_name('CN', 'CN_FORMULA_COMPILE_ERR');
           FND_MSG_PUB.ADD;
        END IF;

     END IF;


     if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_formula_gen_pkg.generate_formula.progress',
			    	'End of generate_formula');
     end if;

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
       ( p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
       );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO generate_formula;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO generate_formula;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN OTHERS THEN
        ROLLBACK TO generate_formula;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     'cn.plsql.cn_formula_gen_pkg.generate_formula.exception',
         	          sqlerrm);
    end if;
END generate_formula;

PROCEDURE generate_formula_conc(errbuf       OUT NOCOPY     VARCHAR2,
		                        retcode      OUT NOCOPY     NUMBER,
                                p_org_id                    NUMBER)
IS
   l_process_audit_id NUMBER;
   l_return_status    VARCHAR2(30);
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(2000);

   CURSOR formulas IS
      SELECT calc_formula_id, org_id
	FROM cn_calc_formulas
	WHERE org_id = nvl(p_org_id, org_id);

  CURSOR compile_pkg_cur IS
     select object_name || ' ' ||
     decode(object_type, 'PACKAGE BODY','compile body','PACKAGE','compile') stmt
     from user_objects
     where object_name like 'CN_FORMULA%PKG'
     and substr(object_name, 12, 1)in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
     and object_type like 'PACKAGE%'
     and status = 'INVALID';

  CURSOR drop_pkg_cur IS
     select object_name stmt
     from user_objects
     where object_name like 'CN_FORMULA%PKG'
     and substr(object_name, 12, 1)in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
     and object_type like 'PACKAGE%'
     and status = 'INVALID';

BEGIN
   FOR formula IN formulas LOOP
      cn_formula_gen_pkg.generate_formula(p_api_version   => 1.0,
					  x_return_status     => l_return_status,
					  x_msg_count         => l_msg_count,
					  x_msg_data          => l_msg_data,
					  p_formula_id        => formula.calc_formula_id,
					  p_org_id            => formula.org_id,
					  x_process_audit_id  => l_process_audit_id
					  );
   END LOOP;

   -- Try one round of compiling the invalid formula packages
   FOR i in compile_pkg_cur
   LOOP
     begin
      execute immediate 'alter package '|| i.stmt;
     exception
      when others then
	    null;
     end;
   END LOOP;

   -- Drop the formula package if still invalid
   FOR i in drop_pkg_cur
   LOOP
     begin
      execute immediate 'drop package '|| i.stmt;
     exception
      when others
        then
	  null;
     end;
   END LOOP;

   retcode := 0;
   errbuf := 'Batch runner completes successfully.';
EXCEPTION
   WHEN OTHERS THEN
     retcode := 2;
     errbuf  := sqlerrm;
END generate_formula_conc;

END cn_formula_gen_pkg;

/
