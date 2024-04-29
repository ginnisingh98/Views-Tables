--------------------------------------------------------
--  DDL for Package Body PQH_GENERIC_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GENERIC_PURGE" AS
/* $Header: pqgenpur.pkb 120.0 2005/05/29 01:55:57 appldev noship $ */
 -- ----------------------------------------------------------------------------
 -- |                     Private Global Definitions                           |
 -- ----------------------------------------------------------------------------
 --
   g_package varchar2(33) := 'pqh_generic_purge.';  -- Global Package Name
   g_purge_txn_catg_id NUMBER;  --transaction category id for PURGE
   g_short_name    varchar2(50); --short name for use in deleting Process Log entries
   g_error_flag BOOLEAN DEFAULT FALSE;
   g_effective_date   DATE;
   g_wf_txn_catg_id   NUMBER;
   g_master_alias     varchar2(30);
 --
/*  -------------Variable Declarations --------------------------------------
  l_master_tab_route_id pqh_table_route.table_route_id%TYPE;
  l_master_table_alias  pqh_table_route.table_alias%TYPE;
  l_master_pk_value             NUMBER(15);
  pk_column_name                pqh_attributes.column_name%TYPE;
  g_error_flag BOOLEAN DEFAULT FALSE;
  retcode NUMBER;
  l_effective_date  DATE;
*/

/* function added by kgowripe */
 FUNCTION  get_transaction_category_id(p_short_name IN varchar2) RETURN Number IS

 CURSOR csr_local_txn_catg IS
   SELECT  transaction_category_id
   FROM    pqh_transaction_categories
   WHERE   short_name = p_short_name;
   l_txn_catg_id   NUMBER;
   l_proc  varchar2(80) := g_package||'get_transaction_category_id';
 BEGIN
     hr_utility.set_location('Entering '||l_proc,10);
     OPEN csr_local_txn_catg;
     FETCH csr_local_txn_catg INTO l_txn_catg_id;
     CLOSE csr_local_txn_catg;
     hr_utility.set_location('Leaving '||l_proc,20);
     RETURN  l_txn_catg_id;
 END get_transaction_category_id;

 PROCEDURE table_route_details(p_table_alias IN varchar2,
                                   p_primary_key_flag IN Varchar2 DEFAULT NULL,
                                   p_table_route_id OUT NOCOPY NUMBER,
                                   p_from_clause    OUT NOCOPY VARCHAR2,
                                   p_where_clause   OUT NOCOPY VARCHAR2,
                                   p_primary_key_col    OUT NOCOPY VARCHAR2) IS
  CURSOR  csr_table_route(p_alias IN pqh_table_route.TABLE_alias%TYPE) is
  SELECT table_route_id,
         from_clause,
         where_clause
  FROM   pqh_table_route
  WHERE  table_alias = p_alias;

 CURSOR csr_col_name(p_table_route_id IN NUMBER,
                     p_col_type_cd IN VARCHAR2) IS
 SELECT   upper(att.column_name) column_name
 FROM     pqh_attributes att
        , pqh_special_attributes sat
        , pqh_txn_category_attributes tca
 WHERE   att.attribute_id              = tca.attribute_id
   AND   att.master_table_route_id     = p_table_route_id
   AND   tca.transaction_category_id   = g_purge_txn_catg_id
   AND   tca.txn_category_attribute_id = sat.txn_category_attribute_id
   AND   sat.attribute_type_cd         = p_col_type_cd; --'PRIMARY_KEY';

   l_proc  varchar2(80) := g_package||'table_route_details';

 BEGIN
 hr_utility.set_location('Entering '||l_proc,10);
 OPEN csr_table_route(p_table_alias);
 FETCH csr_table_route INTO p_table_route_id, p_from_clause, p_where_clause;
 CLOSE csr_table_route;

 IF NVL(p_primary_key_flag,'N') = 'Y' THEN
    OPEN csr_col_name(p_table_route_id,'PRIMARY_KEY');
    FETCH csr_col_name INTO p_primary_key_col;
    CLOSE csr_col_name;
 END IF;
 hr_utility.set_location('leaving '||l_proc,20);
 END table_route_details;

 PROCEDURE delete_wf_data(p_pk_value  IN NUMBER) IS
 l_proc    varchar2(80) := g_package||'delete_wf_data';
 l_select varchar2(2000);
 l_item_key varchar2(80);
 l_item_type  Varchar2(30) := 'PQHGEN'; --Item type for PQH workflow
 BEGIN
 --
 hr_utility.set_location('Entering '||l_proc,10);
 --
 hr_utility.set_location('Item Type PQHGEN',11);
 hr_utility.set_location('Item Key '||g_wf_txn_catg_id||'-'||p_pk_value,12);
-- EXECUTE IMMEDIATE l_select  INTO l_wf_txn_catg_id USING p_pk_value;

 IF g_wf_txn_catg_id IS NOT NULL THEN
 --
     hr_utility.set_location('Deleting WF data '||l_proc,15);
 --
     l_item_key := g_wf_txn_catg_id||'-'||p_pk_value;
     wf_engine.abortprocess(itemtype => l_item_type,
                            itemkey => l_item_key);
     wf_purge.total(itemtype => l_item_type
                   ,itemkey  => l_item_key);


 END IF;
 hr_utility.set_location('Leaving '||l_proc,20);
 EXCEPTION
   When No_data_found THEN
      NULL;
   WHEN Others THEN
      hr_utility.set_location('Error '||sqlErrm,16);
      hr_utility.set_location('Leaving '||L_proc,18);
 END;

 PROCEDURE delete_process_log_data(p_pk_value    IN Number ) IS
 CURSOR  csr_process_log_id(p_txn_value IN NUMBER,
                            p_short_name IN VARCHAR2) IS
     SELECT process_log_id,object_version_number
     FROM   pqh_process_log
     WHERE  module_cd = UPPER(p_short_name)
     START WITH process_log_id = (SELECT process_log_id
                                  FROM   pqh_process_log
                                  WHERE  module_cd = UPPER(p_short_name)
                                  AND    master_process_log_id IS NULL
                                  AND    txn_id = p_txn_value)
     CONNECT BY master_process_log_id = PRIOR process_log_id
     ORDER BY level DESC;
     l_proc   varchar2(80) := g_package||'delete_process_log_data';
  BEGIN
      if g_short_name = 'BUDGET_WORKSHEET' THEN
        g_short_name := 'APPROVE_WORKSHEET';
      end if;
      hr_utility.set_location('Entering '||l_proc,10);
      FOR i IN csr_process_log_id(p_pk_value,g_short_name)
      LOOP
        pqh_process_log_api.delete_process_log
          (p_validate                =>   false
          ,p_process_log_id          =>   i.process_log_id
          ,p_object_version_number   =>   i.object_version_number
          ,p_effective_date          =>   SYSDATE
          );
      END LOOP;
      hr_utility.set_location('Leaving '||l_proc,10);
  END;

 ----------------------------------------------------------------------------------------------------
 --                 PQH_GEN_PURGE TO CALL ALL OTHER PROCEDURES
 -------------------------------------------------------------------------------------------------
 PROCEDURE pqh_gen_purge
 (errbuf       OUT NOCOPY VARCHAR2,
  retcode      OUT NOCOPY NUMBER,
  p_alias      IN pqh_table_route.table_alias%TYPE,
  paramname1   IN pqh_attributes.column_name%TYPE ,
  paramvalue1  IN VARCHAR2 ,
  paramname2   IN pqh_attributes.column_name%TYPE,
  paramvalue2  IN VARCHAR2 ,
  paramname3   IN pqh_attributes.column_name%TYPE ,
  paramvalue3  IN VARCHAR2 ,
  paramname4   IN pqh_attributes.column_name%TYPE ,
  paramvalue4  IN VARCHAR2 ,
  paramname5   IN pqh_attributes.column_name%TYPE ,
  paramvalue5  IN VARCHAR2 ,
  p_effective_date IN DATE )
  IS
    l_proc 				varchar2(72) := g_package||'gen_purge';
    l_master_alias                      pqh_table_route.table_alias%TYPE;
    l_master_tab_route_id               pqh_table_route.table_route_id%TYPE;
    pk_col_name                         pqh_attributes.column_name%TYPE;
    l_select_stmt                       VARCHAR2(8000);
    l_from_clause_txn                   pqh_table_route.from_clause%TYPE;
    l_where_clause_in_txn               pqh_table_route.where_clause%TYPE;
    l_where_clause_out_txn              pqh_table_route.where_clause%TYPE;
    l_all_txn_rows_array                dbms_sql.varchar2_table;
    l_tot_txn_rows                      NUMBER;
    l_parent_pk_value                   NUMBER;
    i                                   NUMBER default 1 ;
    l_select    varchar2(2000);

 BEGIN

   hr_utility.set_location('entering: ' ||l_proc,1000);
   l_master_alias := p_alias;
   g_master_alias := p_alias;
   g_effective_date := p_effective_date;
   --Added by kgowripe
   g_purge_txn_catg_id := get_transaction_category_id('PURGE');
   l_all_txn_rows_array.DELETE;
  --get table route information for master table
   table_route_details(p_table_alias => l_master_alias
                      ,p_primary_key_flag => 'Y'
                      ,p_table_route_id => l_master_tab_route_id
                      ,p_from_clause => l_from_clause_txn
                      ,p_where_clause => l_where_clause_in_txn
                      ,p_primary_key_col => pk_col_name);

   l_select_stmt :='select ' || ' ' || ' TO_CHAR(' || pk_col_name || ')';
   hr_utility.set_location('select stme:' || l_select_stmt,1010);
--
   populate_pltable
   (l_master_tab_route_id  => l_master_tab_route_id,
    paramname1             => paramname1,
    paramvalue1  	   => paramvalue1,
    paramname2  	   => paramname2,
    paramvalue2  	   => paramvalue2,
    paramname3             => paramname3,
    paramvalue3 	   => paramvalue3,
    paramname4   	   => paramname4,
    paramvalue4  	   => paramvalue4,
    paramname5    	   => paramname5,
    paramvalue5     	   => paramvalue5);
--
 hr_utility.set_location('where_in:'||substr(l_where_clause_in_txn,1,100),1020);
 hr_utility.set_location('where_in:'||substr(l_where_clause_in_txn,100,100),1021);
--
   pqh_refresh_data.replace_where_params_purge
     (p_where_clause_in   =>  l_where_clause_in_txn,
      p_txn_tab_flag      =>  'N',
      p_txn_id            =>  '',
      p_where_clause_out  =>  l_where_clause_out_txn );
--
   hr_utility.set_location('where_out:'||substr(l_where_clause_out_txn,1,75),1023);
   hr_utility.set_location('where_out:'||substr(l_where_clause_out_txn,75,75),1024);
--
   pqh_refresh_data.get_all_rows
   (p_select_stmt     =>  l_select_stmt,
    p_from_clause      => l_from_clause_txn,
    p_where_clause     => l_where_clause_out_txn,
    p_total_columns    => 1,--Since we are selecting only the primary key only
    p_total_rows       => l_tot_txn_rows,
    p_all_txn_rows     => l_all_txn_rows_array );
--

   --Now all the pk values satisffying the criteria is in the table..l_all_txn_rows_array
   FOR i in NVL(l_all_txn_rows_array.FIRST,0)..NVL(l_all_txn_rows_array.LAST,-1)
   LOOP
     l_parent_pk_value := l_all_txn_rows_array(i);
     savepoint s1;
     l_select := 'SELECT  wf_transaction_category_id  '||'   FROM '||l_from_clause_txn||' WHERE '||pk_col_name||' = :1';

      EXECUTE IMMEDIATE l_select  INTO g_wf_txn_catg_id USING l_parent_pk_value;
      hr_utility.set_location('wf_txn_catg_id  '||g_wf_txn_catg_id,12);
--
     del_child_records(l_master_alias ,l_parent_pk_value );
--
     enter_conc_log(p_pk_value        => l_parent_pk_value,
     		    tab_rou_id        => l_master_tab_route_id,
     		    p_from_clause_txn => l_from_clause_txn,
      	            p_pk_col_name     => pk_col_name);
--
     call_delete_api(p_tab_route_id      =>  l_master_tab_route_id,
                     p_pk_value          =>  l_parent_pk_value,
                     p_from_clause_txn   =>  l_from_clause_txn,
                     p_pk_col_name       =>  pk_col_name);
--

     if g_error_flag = TRUE then
       fnd_message.set_name('PQH','PQH_PURGE_TXN_FAIL');
       g_error_flag := FALSE;
     else
       fnd_message.set_name('PQH','PQH_PURGE_TXN_SUCC');
     end if;
     fnd_file.put(fnd_file.log,fnd_message.get);
     fnd_file.put_line(fnd_file.log,' ');
     commit;
   END LOOP;
   hr_utility.set_location('leaving: ' ||l_proc,1100);

  END pqh_gen_purge;
 -----------------------------------------------------------------------------------------
   --			FUNCTION GET_COL_TYPE
 -----------------------------------------------------------------------------------------
   FUNCTION get_col_type(p_column_name IN pqh_attributes.column_name%TYPE,
              l_master_table_route_id in pqh_table_route.table_route_id%TYPE )
   RETURN VARCHAR2
   IS
     CURSOR
       csr_get_tr_type (p_column_name IN pqh_attributes.column_name%TYPE,
                     l_master_table_route_id IN pqh_table_route.table_route_id%TYPE ) IS
     SELECT   column_type
     FROM     pqh_attributes
     WHERE    column_name = UPPER(p_column_name)
       AND    master_table_route_id = l_master_table_route_id;

     CURSOR   csr_get_type (p_column_name IN pqh_attributes.column_name%TYPE) IS
     SELECT   column_type
     FROM     pqh_attributes
     WHERE    column_name = UPPER(p_column_name)
       AND    master_table_route_id is null ;
      l_dummy varchar2(1);
    BEGIN
      if l_master_table_route_id is not null then
         OPEN csr_get_tr_type(p_column_name,l_master_table_route_id);
         FETCH csr_get_tr_type INTO l_dummy;
         CLOSE csr_get_tr_type;
      else
         OPEN csr_get_type(p_column_name);
         FETCH csr_get_type INTO l_dummy;
         CLOSE csr_get_type;
      end if;
      RETURN l_dummy;

  END get_col_type;
 -------------------------------------------------------------------------------------------------
 --                                 POPULATE_PLTABLE
 -------------------------------------------------------------------------------------------------
 PROCEDURE populate_pltable
 (l_master_tab_route_id IN PQH_TABLE_ROUTE.TABLE_ROUTE_ID%TYPE,
  paramname1   IN pqh_attributes.column_name%TYPE,
  paramvalue1  IN VARCHAR2,
  paramname2   IN pqh_attributes.column_name%TYPE,
  paramvalue2  IN VARCHAR2,
  paramname3   IN pqh_attributes.column_name%TYPE,
  paramvalue3  IN VARCHAR2,
  paramname4   IN pqh_attributes.column_name%TYPE,
  paramvalue4  IN VARCHAR2,
  paramname5   IN pqh_attributes.column_name%TYPE,
  paramvalue5  IN VARCHAR2) IS
    l_proc 				varchar2(72) := g_package||'populate_pltable';
    i number := 1;
 BEGIN
   hr_utility.set_location('entering: ' ||l_proc,1200);
   pqh_refresh_data.g_refresh_tab.DELETE;
   --populate the g_refresh_tab to be used in replace_where_params_purge
   pqh_refresh_data.g_refresh_tab(1).column_name := paramname1;
   hr_utility.set_location(paramname1||'-'||get_col_type(paramname1,l_master_tab_route_id)||'-'||l_master_tab_route_id,1201);
   if get_col_type(paramname1,l_master_tab_route_id) = 'D' then
      pqh_refresh_data.g_refresh_tab(1).txn_val := ' fnd_date.canonical_to_date('''||paramvalue1||''')';
      pqh_refresh_data.g_refresh_tab(1).column_type := 'N';
   else
      pqh_refresh_data.g_refresh_tab(1).txn_val := paramvalue1;
      pqh_refresh_data.g_refresh_tab(1).column_type := get_col_type(paramname1,l_master_tab_route_id);
   end if;
   pqh_refresh_data.g_refresh_tab(2).column_name := paramname2;
   hr_utility.set_location(paramname2||'-'||get_col_type(paramname2,l_master_tab_route_id)||'-'||l_master_tab_route_id,1202);
   if get_col_type(paramname2,l_master_tab_route_id) = 'D' then
      pqh_refresh_data.g_refresh_tab(2).txn_val := ' fnd_date.canonical_to_date('''||paramvalue2||''')';
      pqh_refresh_data.g_refresh_tab(2).column_type := 'N';
   else
      pqh_refresh_data.g_refresh_tab(2).txn_val := paramvalue2;
      pqh_refresh_data.g_refresh_tab(2).column_type := get_col_type(paramname2,l_master_tab_route_id);
   end if;
   pqh_refresh_data.g_refresh_tab(3).column_name := paramname3;
   hr_utility.set_location(paramname3||'-'||get_col_type(paramname3,l_master_tab_route_id)||'-'||l_master_tab_route_id,1203);
   if get_col_type(paramname3,l_master_tab_route_id) = 'D' then
      pqh_refresh_data.g_refresh_tab(3).txn_val := ' fnd_date.canonical_to_date('''||paramvalue3||''')';
      pqh_refresh_data.g_refresh_tab(3).column_type := 'N';
   else
      pqh_refresh_data.g_refresh_tab(3).txn_val := paramvalue3;
      pqh_refresh_data.g_refresh_tab(3).column_type := get_col_type(paramname3,l_master_tab_route_id);
   end if;
   pqh_refresh_data.g_refresh_tab(4).column_name := paramname4;
   hr_utility.set_location(paramname4||'-'||get_col_type(paramname4,l_master_tab_route_id)||'-'||l_master_tab_route_id,1204);
   if get_col_type(paramname4,l_master_tab_route_id) = 'D' then
      pqh_refresh_data.g_refresh_tab(4).txn_val := ' fnd_date.canonical_to_date('''||paramvalue4||''')';
      pqh_refresh_data.g_refresh_tab(4).column_type := 'N';
   else
      pqh_refresh_data.g_refresh_tab(4).txn_val := paramvalue4;
      pqh_refresh_data.g_refresh_tab(4).column_type := get_col_type(paramname4,l_master_tab_route_id);
   end if;
   pqh_refresh_data.g_refresh_tab(5).column_name := paramname5;
   hr_utility.set_location(paramname5||'-'||get_col_type(paramname5,l_master_tab_route_id)||'-'||l_master_tab_route_id,1205);
   if get_col_type(paramname5,l_master_tab_route_id) = 'D' then
      pqh_refresh_data.g_refresh_tab(5).txn_val := ' fnd_date.canonical_to_date('''||paramvalue5||''')';
      pqh_refresh_data.g_refresh_tab(5).column_type := 'N';
   else
      pqh_refresh_data.g_refresh_tab(5).txn_val := paramvalue5;
      pqh_refresh_data.g_refresh_tab(5).column_type := get_col_type(paramname5,l_master_tab_route_id);
   end if;
  -- display values of g_refresh_tab array

  FOR i IN 1..5 LOOP
  If pqh_refresh_data.g_refresh_tab(i).column_name = 'SHORT_NAME' THEN
      g_short_name:= pqh_refresh_data.g_refresh_tab(i).txn_val;
  END IF;
   hr_utility.set_location(pqh_refresh_data.g_refresh_tab(i).column_name,10);
   hr_utility.set_location(pqh_refresh_data.g_refresh_tab(i).column_type,11);
   hr_utility.set_location(pqh_refresh_data.g_refresh_tab(i).txn_val,12);
   END LOOP;
    hr_utility.set_location('leaving: ' ||l_proc,1300);
 END populate_pltable;
 ----------------------------------------------------------------------------------------------
 --                                 DEL_CHILD_RECORDS
 ----------------------------------------------------------------------------------------------
 PROCEDURE del_child_records
 (p_alias_name          IN pqh_table_route.table_alias%TYPE,
  p_parent_pk_value     IN NUMBER) IS
   l_proc 		varchar2(72) := g_package||'del_child_records';
   l_alias_name         pqh_table_route.table_alias%TYPE default null;
   l_tab_route_id       pqh_table_route.table_route_id%TYPE;
   c_pk_col_name        pqh_attributes.column_name%TYPE;
   l_select_stmt        varchar2(8000) DEFAULT null;
   l_parent_pk_value    number;
   --
   l_all_child_rows_array       dbms_sql.varchar2_table;
   l_child_alias                pqh_table_route.table_alias%TYPE;
   l_from_clause_txn            pqh_table_route.from_clause%type;
   l_where_clause_in_txn        pqh_table_route.where_clause%type;
   l_where_clause_out_txn       pqh_table_route.where_clause%type;
   l_tot_txn_rows               NUMBER;
   l_error_flag			  BOOLEAN;
   i NUMBER :=1 ;
/* Re-writing the cursor for Purging all the child/grand-child tables
   CURSOR
     get_child_alias(p_alias_name in pqh_table_route.table_alias%type) IS
   SELECT
     child_node_type
   FROM
     per_gen_hier_node_types
   WHERE
     parent_node_type = UPPER(p_alias_name) AND hierarchy_type = 'GENERIC_PURGE';
*/
  CURSOR csr_child_alias(p_alias_name IN pqh_table_route.table_alias%TYPE) IS
   SELECT child_node_type
   FROM   per_gen_hier_node_types
   WHERE  hierarchy_type = 'GENERIC_PURGE'
   START WITH parent_node_type = UPPER(p_alias_name)
   CONNECT BY parent_node_type = PRIOR child_node_type;

 BEGIN
   hr_utility.set_location('entering: ' ||l_proc,1500);
   l_parent_pk_value := p_parent_pk_value;
   l_alias_name := p_alias_name;
   OPEN csr_child_alias(l_alias_name);
   LOOP
     FETCH csr_child_alias INTO l_child_alias;
     EXIT WHEN csr_child_alias%NOTFOUND;
/*

     OPEN get_table_id(l_child_alias);
     LOOP
       FETCH get_table_id INTO l_tab_route_id;
       EXIT WHEN get_table_id%NOTFOUND;
     END LOOP;
     CLOSE get_table_id;
    --get the PK column name
     OPEN get_pk_col_name(l_tab_route_id);
     LOOP
       FETCH get_pk_col_name INTO c_pk_col_name;
       EXIT WHEN get_pk_col_name%NOTFOUND;
     END LOOP;
     CLOSE get_pk_col_name;
     OPEN c3_from_where ( l_tab_route_id  ) ;
     LOOP
       -- this gets the from and where clause , one row only
       FETCH c3_from_where INTO l_from_clause_txn, l_where_clause_in_txn;
       EXIT WHEN c3_from_where%NOTFOUND;
     END LOOP;
     CLOSE c3_from_where ;
*/
   l_all_child_rows_array.DELETE;
   table_route_details(p_table_alias => l_child_alias
                      ,p_primary_key_flag => 'Y'
                      ,p_table_route_id => l_tab_route_id
                      ,p_from_clause => l_from_clause_txn
                      ,p_where_clause => l_where_clause_in_txn
                      ,p_primary_key_col => c_pk_col_name);

     l_select_stmt :='select '|| c_pk_col_name ;
     hr_utility.set_location('Parent key value '||l_parent_pk_value,20);
     pqh_refresh_data.replace_where_params_purge
       ( p_where_clause_in   =>  l_where_clause_in_txn,
         p_txn_tab_flag      =>  'Y',
         p_txn_id            =>  l_parent_pk_value,
         p_where_clause_out  =>  l_where_clause_out_txn );

     pqh_refresh_data.get_all_rows
           (p_select_stmt      => l_select_stmt,
            p_from_clause      => l_from_clause_txn,
            p_where_clause     => l_where_clause_out_txn,
            p_total_columns    => 1,
            p_total_rows       => l_tot_txn_rows,
            p_all_txn_rows     => l_all_child_rows_array );
     FOR i in NVL(l_all_child_rows_array.FIRST,0)..NVL(l_all_child_rows_array.LAST,-1)
     LOOP
       hr_utility.set_location('Child alias '||l_child_alias,20);
       hr_utility.set_location('child pk '||l_all_child_rows_array(i),25);
       del_child_records(l_child_alias,l_all_child_rows_array(i));
       hr_utility.set_location('Deleting Child alias '||l_child_alias,20);
       hr_utility.set_location('Deleting child pk '||l_all_child_rows_array(i),25);
       call_delete_api
            (p_tab_route_id      =>  l_tab_route_id,
             p_pk_value          =>  l_all_child_rows_array(i),
             p_from_clause_txn   =>  l_from_clause_txn,
             p_pk_col_name       =>  c_pk_col_name);


     END LOOP;
   END LOOP;
   CLOSE csr_child_alias;
 hr_utility.set_location('leaving: ' ||l_proc,1600);
 END del_child_records;
 -----------------------------------------------------------------------------------------
 --                                         CALL_DELETE_API
 ------------------------------------------------------------------------------------------
 Procedure call_delete_api
     (p_tab_route_id         IN pqh_table_route.table_route_id%TYPE,
      p_pk_value             IN NUMBER,
      p_from_clause_txn      IN pqh_table_route.from_clause%TYPE,
      p_pk_col_name          IN pqh_attributes.column_name%TYPE) IS
    --  p_errror_flag 	     OUT BOOLEAN ) IS
      --This Cursor will get the delete api to be called for the respective tables.
   ---------------------Cursor and Variable Declarations-------------------------------------
   CURSOR
     csr_delete_api_name( p_table_route_id IN pqh_table_route.table_route_id%TYPE) IS
   SELECT   copy_function_name
   FROM     pqh_copy_entity_functions
   WHERE    table_route_id = p_table_route_id;
    /*
     CURSOR
     get_process_log_id(p_txn_value IN NUMBER,
     			l_short_name IN VARCHAR2) IS
      SELECT
         process_log_id from pqh_process_log
      WHERE txn_id = p_txn_value AND module_cd = UPPER(l_short_name);

     CURSOR get_plog_ovn(l_process_log_id IN NUMBER) IS
     SELECT
     	object_version_number from pqh_process_log
    WHERE
      process_log_id = l_process_log_id;
   */
      --
    l_proc     varchar2(72) := g_package||'call_delete_api';
    l_dummy_in varchar2(4000);
    l_dummy_out varchar2(4000);
    l_select_stmt varchar2(8000);
--    l_ovn_value  dbms_sql.varchar2_table;
    -- l_plog_value  dbms_sql.varchar2_table;
    l_from_clause_txn pqh_table_route.from_clause%type;
    l_where_clause_in_txn pqh_table_route.where_clause%type;
    l_where_clause_out_txn pqh_table_route.where_clause%type;
    l_ovn_rows number;
    l_pk_value Number;
    l_ovn NUMBER;
    l_dummy_out1 varchar2(4000);
     l_dummy_out2 varchar2(4000);
    l_pk_col_name PQH_ATTRIBUTES.COLUMN_NAME%TYPE;
    l_process_log_id NUMBER;
    -----------------------------------------------------------------------------------------
    BEGIN
    hr_utility.set_location('entering: ' ||l_proc,1700);
    l_pk_value := p_pk_value;
    l_pk_col_name := p_pk_col_name;
-- l_plog_value.DELETE;
--    l_ovn_value.DELETE;
    l_from_clause_txn := p_from_clause_txn;


/*
    l_select_stmt := ' select object_version_number ' ;
    l_where_clause_in_txn :=  ' c_pk_col_name = <l_pk_value> ' ;
    l_where_clause_in_txn := replace(l_where_clause_in_txn , 'c_pk_col_name' , l_pk_col_name);
    --dbms_output.put_line('after ovn where replace' || l_where_clause_in_txn);
    pqh_refresh_data.replace_where_params_purge
    ( p_where_clause_in   => l_where_clause_in_txn,
      p_txn_tab_flag      =>  'Y',
      p_txn_id            =>  l_pk_value,
      p_where_clause_out  =>  l_where_clause_out_txn );
--
     pqh_refresh_data.get_all_rows
             (p_select_stmt     => l_select_stmt,
             p_from_clause      => l_from_clause_txn,
             p_where_clause     => l_where_clause_out_txn,
             p_total_columns    => 1,
             p_total_rows       => l_ovn_rows,
             p_all_txn_rows     => l_ovn_value );
    l_ovn := l_ovn_value(1);
*/
    l_select_stmt := 'SELECT  object_version_number   FROM  '||l_from_clause_txn||'   WHERE   '||l_pk_col_name||' = :1';
    EXECUTE IMMEDIATE l_select_stmt INTO l_ovn  USING l_pk_value ;
--
    OPEN csr_delete_api_name(p_tab_route_id);
    FETCH csr_delete_api_name INTO l_dummy_in;
    CLOSE csr_delete_api_name;
    hr_utility.set_location('l_dummy_in'||substr(l_dummy_in,1,50),1710);
    hr_utility.set_location('l_dummy_in'||substr(l_dummy_in,51,50),1720);
   -- l_dummy_in := replace(l_dummy_in, 'R_OBJECT_VERSION_NUMBER' , l_ovn_value(1));

    l_dummy_in := replace(l_dummy_in,  '<p_effective_date>', g_effective_date);
    pqh_refresh_data.replace_where_params_purge
     ( p_where_clause_in   =>  l_dummy_in,
       p_txn_tab_flag      =>  'Y',
       p_txn_id            =>  l_pk_value,
       p_where_clause_out  =>  l_dummy_out);
  --
  hr_utility.set_location('l_dummy_out'||substr(l_dummy_out,1,50),1750);
  hr_utility.set_location('l_dummy_out'||substr(l_dummy_out,51,50),1760);
  hr_utility.set_location('l_dummy_out'||substr(l_dummy_out,101,50),1770);
  hr_utility.set_location('l_dummy_out'||substr(l_dummy_out,151,50),1780);
  hr_utility.set_location('l_dummy_out'||substr(l_dummy_out,201,50),1790);
  hr_utility.set_location('l_dummy_out'||substr(l_dummy_out,251,50),1800);
  hr_utility.set_location('l_dummy_out'||substr(l_dummy_out,301,50),1810);
  hr_utility.set_location('l_dummy_out'||substr(l_dummy_out,351,50),1820);
  --Execute the procedure to delete the record with passed PK value.
     l_dummy_out1 := substr(l_dummy_out,1,instr(l_dummy_out,'R_OBJECT_VERSION_NUMBER')-1 );
     l_dummy_out2 := substr(l_dummy_out,instr(l_dummy_out,'R_OBJECT_VERSION_NUMBER') +length('R_OBJECT_VERSION_NUMBER'),length(l_dummy_out));

--code added for deleting any workflow notifications sent for the Transaction
     IF g_master_alias IN ('PPTX','PPWS','PBPR') THEN
          delete_wf_data(p_pk_value => l_pk_value);
     END IF;
--
--added by kgowripe for deleting the Process log data corresponding to a transaction
     delete_process_log_data(p_pk_value => l_pk_value);
--
       EXECUTE IMMEDIATE  'DECLARE ' ||
                          ' p_ovn NUMBER;' ||
                          'BEGIN ' ||
                           'p_ovn :=' || l_ovn || ';' ||
                           l_dummy_out1 ||
                            'p_ovn' ||
                          l_dummy_out2|| ';'||
                          'END;' ;

hr_utility.set_location('leaving: ' ||l_proc,1900);

EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location(SQLERRM,15);
--    retcode:=2;
    rollback  to s1;
    g_error_flag := TRUE;
--
END call_delete_api;
 ----------------------------------------------------------------------------------------------
 --                                ENTER_CONC_LOG
 ----------------------------------------------------------------------------------------------
 PROCEDURE enter_conc_log(p_pk_value IN NUMBER,
 			  TAB_ROU_ID IN NUMBER,
 			  p_from_clause_txn IN pqh_table_route.from_clause%TYPE,
  			  p_pk_col_name IN pqh_attributes.column_name%TYPE)
  			 -- p_error_flag IN boolean)
  IS
  ------------------------DECLARATIONS----------------------------------------------------------
  --
 CURSOR
 	csr_err_col_name(p_table_route_id IN pqh_table_route.table_route_id%TYPE) IS
        SELECT  upper(att.column_name) column_name
        FROM    pqh_attributes att
              , pqh_special_attributes sat
              , pqh_txn_category_attributes tca
        WHERE   att.attribute_id              = tca.attribute_id
        and     att.master_table_route_id     = p_table_route_id
        and     tca.transaction_category_id   =  g_purge_txn_catg_id
        and     tca.txn_category_attribute_id = sat.txn_category_attribute_id
        and     sat.attribute_type_cd         = 'ERROR_KEY';
 lcol varchar2(50);
 l_select varchar2(8000);
 L_txn_value DBMS_SQL.VARCHAR2_TABLE;
 l_where_clause varchar2(8000);
 l_tot_columns number :=0;
 l_tot_rows number;
 L_from_clause varchar2(4000);
 i number;
-- l_error_flag boolean;
 --
 BEGIN
 -- l_error_flag := g_error_flag;
 l_select := 'select ';
 OPEN csr_ERR_col_name(tab_rou_id);
 LOOP
 FETCH csr_err_col_name INTO LCOL;
 EXIT WHEN csr_err_col_name%NOTFOUND;
 l_select := l_select || 'TO_CHAR('||lcol ||'),';
 l_tot_columns := l_tot_columns +1;
 END LOOP;
 L_SELECT := RTRIM(L_SELECT,',');
 CLOSE csr_err_col_name;
 L_WHERE_CLAUSE := p_pk_col_name || '=' || p_pk_value;

 l_from_clause := p_from_clause_txn;
 pqh_refresh_data.get_all_rows
            (p_select_stmt     => l_select,
            p_from_clause      => l_from_clause,
            p_where_clause     => l_where_clause,
            p_total_columns    => l_tot_columns,
            p_total_rows       => l_tot_rows,
            p_all_txn_rows     => l_txn_value );
  --dbms_output.put_line('totrows:' ||  l_tot_rows);
--
 FOR i IN NVL(l_txn_value.first,0)..NVL(l_txn_value.last,-1)
 LOOP
 fnd_file.put(fnd_file.log,l_txn_value(i)|| '  ');
 END LOOP;

END enter_conc_log;
END PQH_GENERIC_PURGE;

/
