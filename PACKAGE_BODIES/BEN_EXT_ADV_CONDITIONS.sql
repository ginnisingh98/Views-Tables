--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ADV_CONDITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ADV_CONDITIONS" as
/* $Header: benxadvc.pkb 120.9 2007/10/08 23:56:45 tjesumic noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
        Extract Advanced Conditions
Purpose
        This package determines if a record or person should be excluded from
        the extract. It uses dynamic sql.
History
        Date      Version  Who         What?
        ----      -------  ----------- ----------------------------------------
        07/29/99  115.0    Ty Hayden   Created.
        09/27/99  115.1    Ty Hayden   Added prevent_duplicates.
        10/07/99  115.2    Ty Hayden   Added change event procedures.
        10/07/99  115.3    Ty Hayden   Fix for signal warning.
        01/21/00  115.4    Ty Hayden   Fix for data element conditions.
        29/01/01  115.6    tilak       bug 1579767 the error messages fixed
        30/01/01  115.7    tilak       bug 1579767 the error messages fixed
                                       for user defined error too
        26/11/01  115.8    dschwart/   Bug#1969853: rcd_in_file did not handle
                           BBurns/     the case where number is passed in as a
                           QSmith      string correctly.  Altered to check the
                                       format mask so it a number passed as a string
                                       could be handled correctly.
        15/mar/01 115.9    tjesumic    DBDRV fixed
        23/Dec/02 115.11   rpgupta     Nocopy changes
        20/Oct/03 115.12   tjesumic    chg_evt_chg_evt_incl procedire changed to validate the
                                       g_data_elmt_list for the data element in rcd level
                                       instead of g_rcd_list. g_data_elmt_list_id added to  validate
                                       correct advance condition
        05/02/04  115.13    nhunur     removed the unwanted commits.
        01/Feb/05 115.14    tjesumic   300 elements allowed in  a record
        21/Jun/05 115.15    tjesumic   pernnserver ,  chg_rcd_merge added
        21/Jun/05 115.16    tjesumic   no copy added in chg_rcd_merge
        29/Sep/05 115.17    tjesumic   adv condition changed into  dbms_sql and bind variable
        07/Now/05 115.18    tjesumic   dynamic adv condition added
        02/Feb/06 115.19    tjesumic   new  exception  added to restart the error person
        04/25/06  115.20    tjesumic   new global qdded g_ext_adv_ct_validation
        04/27/06  115.21    tjesumic   numeric validation is fixed
        05/10/06  115.22    tjesumic   numeric validation is fixed
        10/08/07  115.23    tjesumic   cuplication validation cursor changed. the values are extracted and validated for performance

*/
--
g_package              varchar2(30) := ' ben_ext_adv_conditions.';
--
Type num_list is table of varchar2(1)
Index by binary_integer;

Type id_list is table of number
Index by binary_integer;
--
g_rcd_list num_list;
g_data_elmt_list num_list;

g_data_elmt_list_id  id_list;

TYPE ext_adv_conditions  IS RECORD
      ( name   varchar2(50),
        value  varchar2(500)
      );
TYPE t_ext_adv_conditions  IS TABLE OF ext_adv_conditions INDEX BY Binary_Integer;


--
-- ----------------------------------------------------------------------------
-- |--------------------< write_warning >-----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure WRITE_WARNING
           (p_err_name in varchar2,
            p_err_no   in number default null,
            p_element   in varchar2 default null ) is
--
  l_proc     varchar2(72)    := g_package||'write_warning';
  l_err_name varchar2(2000)  := p_err_name ;
  l_err_no   number          :=  p_err_no ;
--
begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
--  form is changed to take the error message and name from error table
--  only customised message is sent as parameter to error text bug: 1579767
--  instead of error name the null sent as param
--  p_err_no is added as param ,so if err_no sent then name considered as
--  customised messagr
   if p_err_no is null then
      --assumed the name is error name
      l_err_no   :=  to_number(substr(p_err_name,5,5)) ;
      l_err_name :=  null ;
   end if ;
   --if element name is sent get the message to write
   if p_err_no is not null and p_element is not null then
      l_err_name :=  ben_ext_fmt.get_error_msg(p_err_no,p_err_name,p_element ) ;
   end if ;

   if ben_ext_person.g_business_group_id is not null then
     ben_ext_util.write_err
      (p_err_num => l_err_no,        -- to_number(substr(p_err_name,5,5)),
       p_err_name => l_err_name,     --p_err_name,
       p_typ_cd => 'W',
       p_person_id => ben_ext_person.g_person_id,
       p_business_group_id => ben_ext_person.g_business_group_id,
       p_ext_rslt_id => ben_extract.g_ext_rslt_id);
   end if;
--
hr_utility.set_location('Exiting'||l_proc, 15);
--
--
end write_warning;
--

Function  Strip_quote (p_data in varchar2)
          return   varchar2 is


l_proc     varchar2(72) := g_package||'Strip_quotes';
l_ret_val varchar2(500) ;
begin

hr_utility.set_location('Entering'||l_proc, 5);
hr_utility.set_location('date '||p_data , 5);
l_ret_val := ltrim(rtrim(p_data)) ;
if  substr(l_ret_val,1,1) = '''' then
    l_ret_val := substr(l_ret_val,2) ;
end if ;


if  substr(l_ret_val,length(l_ret_val)) = '''' then
    l_ret_val := substr(l_ret_val,1,length(l_ret_val)-1) ;
end if ;

hr_utility.set_location('Exiting'||l_proc, 15);
return l_ret_val ;
end ;
-- ----------------------------------------------------------------------------
-- |--------------------< rcd_in_file >-----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure rcd_in_file(p_ext_rcd_in_file_id in number,
                          p_sprs_cd in varchar2,
                          p_exclude_this_rcd_flag out nocopy boolean) is

cursor c_xwc(p_ext_rcd_in_file_id in number)  is
 select xwc.oper_cd,
             xwc.val,
             xwc.and_or_cd,
             xer.seq_num,
             xwc.cond_ext_data_elmt_id,
             xrc.name,
             substr(xel.frmt_mask_cd,1,1) xel_frmt_mask_cd,
             xel.data_elmt_typ_cd,
             xel.data_elmt_rl,
             xel.ext_fld_id,
             fld.frmt_mask_typ_cd,
             xer.ext_rcd_id
  from ben_ext_where_clause xwc,
           ben_ext_data_elmt_in_rcd xer,
           ben_ext_rcd  xrc,
           ben_ext_data_elmt xel,
           ben_ext_fld fld
  where xwc.ext_rcd_in_file_id = p_ext_rcd_in_file_id
 and xwc.cond_ext_data_elmt_in_rcd_id = xer.ext_data_elmt_in_rcd_id
 and xer.ext_rcd_id = xrc.ext_rcd_id
 and xel.ext_data_elmt_id = xer.ext_data_elmt_id
 and xel.ext_fld_id = fld.ext_fld_id(+)
 order by xwc.seq_num;



cursor c_cond_xwc(p_ext_data_elmt_id   number,
                  p_Ext_rcd_id         number)  is
 select xer.seq_num
  from  ben_ext_data_elmt_in_rcd xer,
        ben_ext_data_elmt xel,
        ben_ext_fld fld
  where xer.ext_rcd_id = p_Ext_rcd_id
    and xel.ext_data_elmt_id = xer.ext_data_elmt_id
    and xel.ext_data_elmt_id = p_ext_data_elmt_id
     and xel.ext_fld_id = fld.ext_fld_id(+)
   ;

--
l_proc     varchar2(72) := g_package||'rcd_in_file';
l_condition varchar2(1);
l_cnt number;
l_cond_cnt  number;
l_value_without_quotes varchar2(500);
l_dynamic_condition varchar2(9999);
l_rcd_name    ben_ext_rcd.name%type ;
l_cond_seq    number  ;
--
l_ext_adv_conditions   t_ext_adv_conditions ;
l_ext_adv_data         t_ext_adv_conditions ;
l_cursor_name INTEGER;
l_dummy_num   integer ;
l_dummy_var   varchar2(500) ;
l_exclude_flag  boolean ;

--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
  ben_ext_adv_conditions.g_ext_adv_ct_validation := 'N' ;
  p_exclude_this_rcd_flag := false;
  if p_sprs_cd = null then
     return;
  end if;

  --

  --
  l_cnt      := 0;
  l_cond_cnt := 0;

  ben_ext_adv_ct_check.rcd_in_file(p_ext_rcd_in_file_id    => p_ext_rcd_in_file_id  ,
                                   p_sprs_cd               => p_sprs_cd  ,
                                   p_exclude_this_rcd_flag =>  l_exclude_flag  ) ;

  if  ben_ext_adv_conditions.g_ext_adv_ct_validation <> 'N' then
      p_exclude_this_rcd_flag :=  nvl(l_exclude_flag, false) ;
      return ;
  end if ;




  l_dynamic_condition := 'begin if    ';
  for xwc in c_xwc(p_ext_rcd_in_file_id) loop
    l_cnt := l_cnt +1;

    hr_utility.set_location('count '||l_cnt , 5);
    l_ext_adv_data(l_cnt).name := ':A'||to_char(l_cnt) ;

    -- strip all quotes out of any values.
    l_value_without_quotes := replace(ben_ext_fmt.g_val_tab(xwc.seq_num),'''');
    --
    --
    if (xwc.frmt_mask_typ_cd = 'N' or
        xwc.xel_frmt_mask_cd = 'N' or
        xwc.data_elmt_typ_cd = 'R')
       and
       l_value_without_quotes is not null
    then
       begin
          --  test for numeric value
          if xwc.oper_cd = 'IN' then
             l_ext_adv_data(l_cnt).value   := l_value_without_quotes;
          else
             l_ext_adv_data(l_cnt).value   := to_number(l_value_without_quotes);
          end if;

       exception when others then
          -- quotes needed, not numeric value
          l_ext_adv_data(l_cnt).value   :=  l_value_without_quotes;
       end;
    else
      -- quotes needed, not numeric value
      l_ext_adv_data(l_cnt).value   :=   l_value_without_quotes;
    end if;

    l_dynamic_condition := l_dynamic_condition || l_ext_adv_data(l_cnt).name  ;

    l_dynamic_condition := l_dynamic_condition || ' ' || xwc.oper_cd  ||' '  ;

    ----- get the value into array
    if xwc.oper_cd in ( 'BETWEEN','NOT BETWEEN') then

         l_cond_cnt := l_cond_cnt +1;
         l_dummy_var :=  xwc.val ;
         hr_utility.set_location  ( ' l_dummy_var  ' || l_dummy_var , 99 ) ;
         l_dummy_num := instr(upper(l_dummy_var), 'AND') ;
         l_ext_adv_conditions(l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;

         -- if the data lement is number change the value to number
         if (xwc.frmt_mask_typ_cd = 'N' or
            xwc.xel_frmt_mask_cd = 'N' or
            xwc.data_elmt_typ_cd = 'R')  then

           begin
             l_ext_adv_conditions( l_cond_cnt).value :=  to_number(strip_quote(substr(l_dummy_var,1,l_dummy_num-1)) )  ;
             hr_utility.set_location(' number between 1 ' || l_ext_adv_conditions( l_cond_cnt).value , 99 ) ;
           exception when others then
             l_ext_adv_conditions( l_cond_cnt).value :=  strip_quote(substr(l_dummy_var,1,l_dummy_num-1))  ;
           end ;

           l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || ' AND  '  ;
           l_cond_cnt := l_cond_cnt +1;
           l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;

           begin
             l_ext_adv_conditions( l_cond_cnt).value :=  to_number(strip_quote( substr(l_dummy_var, l_dummy_num+4)))  ;
             hr_utility.set_location(' number between 2 ' || l_ext_adv_conditions( l_cond_cnt).value , 99 ) ;
           exception when others then
             l_ext_adv_conditions( l_cond_cnt).value :=  strip_quote( substr(l_dummy_var, l_dummy_num+4))  ;
           end ;
           l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || '  '  ;

         else

            l_ext_adv_conditions( l_cond_cnt).value :=  strip_quote(substr(l_dummy_var,1,l_dummy_num-1))  ;
            l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || ' AND  '  ;

            l_cond_cnt := l_cond_cnt +1;
            l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;
            l_ext_adv_conditions( l_cond_cnt).value :=  strip_quote( substr(l_dummy_var, l_dummy_num+4))  ;
            l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || '  '  ;
         end if ;



    elsif xwc.oper_cd in ( 'IN','NOT IN') then

          l_dummy_var :=  replace(replace(xwc.val,'('), ')')  ;
          l_dynamic_condition := l_dynamic_condition || ' ( ' ;
          Loop

             l_dummy_num := instr(l_dummy_var, ',') ;
             if  l_dummy_num = 0 then exit  ; end if ;
             l_cond_cnt := l_cond_cnt +1;
             l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;
             l_ext_adv_conditions( l_cond_cnt).value := strip_quote(  substr(l_dummy_var, 1, l_dummy_num-1))  ;
             l_dynamic_condition := l_dynamic_condition ||   l_ext_adv_conditions( l_cond_cnt).name || ' ,  '  ;
             l_dummy_var  := substr(l_dummy_var, l_dummy_num+1) ;
          end Loop  ;
          if l_dummy_var is not null then
             l_cond_cnt := l_cond_cnt +1;
             l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;
             l_ext_adv_conditions( l_cond_cnt).value := strip_quote( l_dummy_var)  ;
             l_dynamic_condition := l_dynamic_condition ||   l_ext_adv_conditions( l_cond_cnt).name || '  '  ;
          end if ;
          l_dynamic_condition := l_dynamic_condition || ' ) ' ;
   elsif xwc.oper_cd in ( 'IS NULL','IS NOT NULL') then
           -- do nothing
           null ;
    else
      l_cond_cnt := l_cond_cnt +1;
      l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;
      l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || ' '  ;

      if xwc.cond_ext_data_elmt_id is not null then
         open c_cond_xwc (xwc.cond_ext_data_elmt_id , xwc.ext_rcd_id )  ;
         fetch c_cond_xwc into l_cond_seq ;
         close c_cond_xwc  ;

         if l_cond_seq is not null then
            l_ext_adv_conditions( l_cond_cnt).value :=  replace(ben_ext_fmt.g_val_tab(l_cond_seq),'''');
         else
            l_ext_adv_conditions( l_cond_cnt).value := strip_quote(xwc.val)  ;
         end if ;

      else
         l_ext_adv_conditions( l_cond_cnt).value := strip_quote(xwc.val)  ;
      end if ;

      -- if the data element is number change the value to number
      if (xwc.frmt_mask_typ_cd = 'N' or
            xwc.xel_frmt_mask_cd = 'N' or
            xwc.data_elmt_typ_cd = 'R')  then

         begin
           l_ext_adv_conditions( l_cond_cnt).value := to_number(l_ext_adv_conditions( l_cond_cnt).value) ;
             hr_utility.set_location(' number =' || l_ext_adv_conditions( l_cond_cnt).value , 99 ) ;
         exception when others then
            null ;
         end  ;

       end if ;
    end if ;

    l_dynamic_condition := l_dynamic_condition || ' ' || xwc.and_or_cd || ' ' ;
    hr_utility.set_location('  condition    '||  l_value_without_quotes   , 3);
    l_rcd_name := xwc.name ;

  end loop;
  -- if there is no data for advanced conditions, exit this program.
  if l_cnt = 0 then
    return;
  end if;
  hr_utility.set_location('out of loop   '  , 5);
  l_dynamic_condition := l_dynamic_condition ||
         ' then :l_condition := ''T''; else :l_condition := ''F''; end if; end;';
  begin
    --execute immediate l_dynamic_condition using OUT l_condition;

   hr_utility.set_location('  parsing  '||  l_cnt  , 3);
   l_cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor_name, l_dynamic_condition,dbms_sql.v7) ;
   hr_utility.set_location('  parse the cursor  '||  l_cnt  , 3);
   for i in 1 .. l_cnt
   Loop

      hr_utility.set_location('  bind   data  '||  l_ext_adv_data(i).name || l_ext_adv_data(i).value  , 3);
      dbms_sql.bind_variable(l_cursor_name, l_ext_adv_data(i).name,
                                                 l_ext_adv_data(i).value);
   end loop ;


   for i in 1 .. l_cond_cnt
   Loop

      hr_utility.set_location('  bind   cond  '||  l_ext_adv_conditions(i).name || l_ext_adv_conditions(i).value  , 5);
      dbms_sql.bind_variable(l_cursor_name, l_ext_adv_conditions(i).name,
                                                 l_ext_adv_conditions(i).value);
   end loop ;
   dbms_sql.bind_variable(l_cursor_name, ':l_condition' , l_condition, 1 ) ;
    --
   l_cnt := dbms_sql.execute(l_cursor_name ) ;

   dbms_sql.variable_Value(l_cursor_name, ':l_condition'  ,  l_condition )  ;

   dbms_sql.close_cursor(l_cursor_name);
   hr_utility.set_location( 'return from dbms_sql   ' || l_condition   , 99 ) ;

  exception
    when others then
      hr_utility.set_location( 'except  ' || substr(sqlerrm,1,100), 99  ) ;
      fnd_file.put_line(fnd_file.log,
        'Error in Advanced Conditions while processing this dynamic sql statement: ');
      fnd_file.put_line(fnd_file.log, l_dynamic_condition);
      IF dbms_sql.is_open(l_cursor_name) THEN
         dbms_sql.close_cursor(l_cursor_name);
      end if ;

      raise;  -- such that the error processing in ben_ext_thread occurs.
  end;


  if l_condition   = 'T'      then

    if p_sprs_cd = 'A' then   -- rollback record
      p_exclude_this_rcd_flag := true;
    elsif p_sprs_cd = 'B' then  -- rollback person
      p_exclude_this_rcd_flag := true;
      raise ben_ext_person.required_error;
    elsif p_sprs_cd = 'C' then  -- rollback person and error
      p_exclude_this_rcd_flag := true;
      ben_ext_person.g_elmt_name := l_rcd_name ;
      ben_ext_person.g_err_num := 92679;
      ben_ext_person.g_err_name := 'BEN_92679_EXT_USER_DEFINED_ERR';
      raise ben_ext_person.detail_restart_error;
    elsif p_sprs_cd = 'H' then  -- signal warning
      write_warning ('BEN_92678_EXT_USER_DEFINED_WRN',92678,l_rcd_name);

    end if;

  else -- l_condition = 'F'

    if p_sprs_cd = 'D' then -- rollback record
      p_exclude_this_rcd_flag := true;
    elsif p_sprs_cd = 'E' then  -- rollback person
      p_exclude_this_rcd_flag := true;
      raise ben_ext_person.required_error;
    elsif p_sprs_cd = 'F' then  -- rollback person and error
      p_exclude_this_rcd_flag := true;
      ben_ext_person.g_elmt_name := l_rcd_name ;
      ben_ext_person.g_err_num := 92679;
      ben_ext_person.g_err_name := 'BEN_92679_EXT_USER_DEFINED_ERR';
      raise ben_ext_person.detail_restart_error;
    elsif p_sprs_cd = 'K' then  -- signal warning
      write_warning ('BEN_92678_EXT_USER_DEFINED_WRN',92678,l_rcd_name);

    end if;
  --
  end if;
--
hr_utility.set_location('Exiting'||l_proc, 15);
--
end rcd_in_file;
--
-- ----------------------------------------------------------------------------
-- |--------------------< data_elmt_in_rcd >-----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure data_elmt_in_rcd(p_ext_rcd_id in number,
                           p_exclude_this_rcd_flag out nocopy boolean) is
--
 cursor c_xer(p_ext_rcd_id in number) is
  select xer.seq_num,
         xer.sprs_cd,
         xer.ext_data_elmt_in_rcd_id,
         xdm.name
  from  ben_ext_data_elmt_in_rcd xer,
        ben_ext_data_elmt  xdm
        where ext_rcd_id = p_ext_rcd_id
        and xer.sprs_cd is not null
        and xer.ext_data_elmt_id = xdm.ext_data_elmt_id ;
--
--
cursor c_xwc(p_ext_data_elmt_in_rcd_id in number)  is
  select xwc.oper_cd,
             xwc.val,
             xwc.and_or_cd,
             xwc.cond_ext_data_elmt_id,
             xer.seq_num,
             substr(xel.frmt_mask_cd,1,1) xel_frmt_mask_cd,
             xel.data_elmt_typ_cd,
             xel.data_elmt_rl,
             xer.ext_rcd_id ,
             fld.frmt_mask_typ_cd
  from ben_ext_where_clause xwc,
       ben_ext_data_elmt_in_rcd xer,
       ben_ext_data_elmt xel,
       ben_ext_fld fld
  where xwc.ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id
 and xwc.cond_ext_data_elmt_in_rcd_id = xer.ext_data_elmt_in_rcd_id
 and xel.ext_data_elmt_id = xer.ext_data_elmt_id
 and xel.ext_fld_id = fld.ext_fld_id(+)
 order by xwc.seq_num;
--
 cursor c_cond_xwc(p_ext_data_elmt_id   number,
                   p_Ext_rcd_id         number)  is
 select xer.seq_num
  from  ben_ext_data_elmt_in_rcd xer,
        ben_ext_data_elmt xel,
        ben_ext_fld fld
  where xer.ext_rcd_id = p_Ext_rcd_id
    and xel.ext_data_elmt_id = xer.ext_data_elmt_id
    and xel.ext_data_elmt_id = p_ext_data_elmt_id
     and xel.ext_fld_id = fld.ext_fld_id(+)
   ;


l_proc     varchar2(72) := g_package||'data_elmt_in_rcd';
l_condition varchar2(1);
l_cnt number;
l_cond_seq  number;
l_value_without_quotes varchar2(500);
l_dynamic_condition varchar2(9999);
--
l_ext_adv_conditions   t_ext_adv_conditions ;
l_ext_adv_data         t_ext_adv_conditions ;
l_cursor_name INTEGER;
l_dummy_num   integer ;
l_dummy_var   varchar2(500) ;
l_cond_cnt  number;
l_exclude_flag  boolean ;
--
  l_val_tab_mirror   ben_ext_fmt.ValTabTyp;
--
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
  ben_ext_adv_conditions.g_ext_adv_ct_validation := 'N' ;
--
  p_exclude_this_rcd_flag := false;



  ben_ext_adv_ct_check.data_elmt_in_rcd(p_ext_rcd_id            => p_ext_rcd_id ,
                                        p_exclude_this_rcd_flag => l_exclude_flag ) ;

  if  ben_ext_adv_conditions.g_ext_adv_ct_validation <> 'N' then
      p_exclude_this_rcd_flag :=  nvl(l_exclude_flag, false) ;
      return ;
  end if ;


--
-- make mirror image of table for evaluation, since values in the real table
-- are changing (being nullified).
--
  l_val_tab_mirror := ben_ext_fmt.g_val_tab;
--
for xer in c_xer(p_ext_rcd_id) loop
  --
  l_cnt       := 0;
  l_cond_cnt  := 0 ;
  l_dynamic_condition := 'begin If ';
  for xwc in c_xwc(xer.ext_data_elmt_in_rcd_id) loop
    l_cnt := l_cnt +1;
    l_ext_adv_data(l_cnt).name := ':A'||to_char(l_cnt) ;
   -- strip all quotes out of any values.
    l_value_without_quotes := replace(l_val_tab_mirror(xwc.seq_num),'''');

    if (xwc.frmt_mask_typ_cd = 'N' or
        xwc.xel_frmt_mask_cd = 'N' or
        xwc.data_elmt_typ_cd = 'R')
       and
       l_value_without_quotes is not null
    then
       begin
          --  test for numeric value
          if xwc.oper_cd = 'IN' then
             l_ext_adv_data(l_cnt).value   := l_value_without_quotes;
          else
             l_ext_adv_data(l_cnt).value   := to_number(l_value_without_quotes);
          end if;

       exception when others then
          -- quotes needed, not numeric value
          l_ext_adv_data(l_cnt).value   :=  l_value_without_quotes;
       end;
    else
      -- quotes needed, not numeric value
      l_ext_adv_data(l_cnt).value   :=   l_value_without_quotes;
    end if;

    l_dynamic_condition := l_dynamic_condition || ' ' || l_ext_adv_data(l_cnt).name || ' ' || xwc.oper_cd  || ' ' ;
    hr_utility.set_location(' oper code ' || xwc.oper_cd , 99 ) ;
     ----- get the value into array
    if xwc.oper_cd in ( 'BETWEEN','NOT BETWEEN') then

         l_cond_cnt := l_cond_cnt +1;
         l_dummy_var :=  xwc.val ;
         hr_utility.set_location  ( ' l_dummy_var  ' || l_dummy_var , 99 ) ;
         l_dummy_num := instr(upper(l_dummy_var), 'AND') ;
         l_ext_adv_conditions(l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;
         -- if the data lement is number change the value to number
         if (xwc.frmt_mask_typ_cd = 'N' or
            xwc.xel_frmt_mask_cd = 'N' or
            xwc.data_elmt_typ_cd = 'R')  then

           begin
             l_ext_adv_conditions( l_cond_cnt).value :=  to_number(strip_quote(substr(l_dummy_var,1,l_dummy_num-1)) )  ;
             hr_utility.set_location(' number between 1 ' || l_ext_adv_conditions( l_cond_cnt).value , 99 ) ;
           exception when others then
             l_ext_adv_conditions( l_cond_cnt).value :=  strip_quote(substr(l_dummy_var,1,l_dummy_num-1))  ;
           end ;

           l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || ' AND  '  ;
           l_cond_cnt := l_cond_cnt +1;
           l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;

           begin
             l_ext_adv_conditions( l_cond_cnt).value :=  to_number(strip_quote( substr(l_dummy_var, l_dummy_num+4)))  ;
             hr_utility.set_location(' number between 2 ' || l_ext_adv_conditions( l_cond_cnt).value , 99 ) ;
           exception when others then
             l_ext_adv_conditions( l_cond_cnt).value :=  strip_quote( substr(l_dummy_var, l_dummy_num+4))  ;
             hr_utility.set_location(' number between 2 ' || l_ext_adv_conditions( l_cond_cnt).value , 99 ) ;
           end ;
           l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || '  '  ;

         else

            l_ext_adv_conditions( l_cond_cnt).value :=  strip_quote(substr(l_dummy_var,1,l_dummy_num-1))  ;
            l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || ' AND  '  ;

            l_cond_cnt := l_cond_cnt +1;
            l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;
            l_ext_adv_conditions( l_cond_cnt).value :=  strip_quote( substr(l_dummy_var, l_dummy_num+4))  ;
            l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || '  '  ;
         end if ;


    elsif xwc.oper_cd in ( 'IN','NOT IN') then

          l_dummy_var :=  replace(replace(xwc.val,'('), ')')  ;
          l_dynamic_condition := l_dynamic_condition || ' ( ' ;
          Loop

             l_dummy_num := instr(l_dummy_var, ',') ;
             if  l_dummy_num = 0 then exit  ; end if ;
             l_cond_cnt := l_cond_cnt +1;
             l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;
             l_ext_adv_conditions( l_cond_cnt).value := strip_quote(  substr(l_dummy_var, 1, l_dummy_num-1))  ;
             l_dynamic_condition := l_dynamic_condition ||   l_ext_adv_conditions( l_cond_cnt).name || ' ,  '  ;
             l_dummy_var  := substr(l_dummy_var, l_dummy_num+1) ;
          end Loop  ;
          if l_dummy_var is not null then
             l_cond_cnt := l_cond_cnt +1;
             l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;
             l_ext_adv_conditions( l_cond_cnt).value := strip_quote( l_dummy_var)  ;
             l_dynamic_condition := l_dynamic_condition ||   l_ext_adv_conditions( l_cond_cnt).name || '  '  ;
          end if ;
          l_dynamic_condition := l_dynamic_condition || ' ) ' ;
   elsif xwc.oper_cd in ( 'IS NULL','IS NOT NULL') then
          -- do nothing
          null ;
    else
        l_cond_cnt := l_cond_cnt +1;
        l_ext_adv_conditions( l_cond_cnt).name := ':B'||to_char(l_cond_cnt) ;
        l_dynamic_condition := l_dynamic_condition || l_ext_adv_conditions( l_cond_cnt).name || ' '  ;

        if xwc.cond_ext_data_elmt_id is not null then
           open c_cond_xwc (xwc.cond_ext_data_elmt_id , xwc.ext_rcd_id )  ;
           fetch c_cond_xwc into l_cond_seq ;
           close c_cond_xwc  ;

           if l_cond_seq is not null then
              l_ext_adv_conditions( l_cond_cnt).value :=  replace(l_val_tab_mirror(l_cond_seq),'''');
           else
              l_ext_adv_conditions( l_cond_cnt).value := strip_quote(xwc.val)  ;
           end if ;
        else
           l_ext_adv_conditions( l_cond_cnt).value := strip_quote(xwc.val)  ;
        end if ;
        -- if the data element is number change the value to number
        if (xwc.frmt_mask_typ_cd = 'N' or
            xwc.xel_frmt_mask_cd = 'N' or
            xwc.data_elmt_typ_cd = 'R')  then

           begin
             l_ext_adv_conditions( l_cond_cnt).value := to_number(l_ext_adv_conditions( l_cond_cnt).value) ;
             hr_utility.set_location(' number = ' || l_ext_adv_conditions( l_cond_cnt).value , 99 ) ;
           exception when others then
              null ;
         end  ;

       end if ;

    end if ;
    l_dynamic_condition := l_dynamic_condition || ' ' || xwc.and_or_cd || ' ' ;


  end loop;
  -- if there is no data for advanced conditions, bypass rest of this program.
  if l_cnt > 0 then

      l_dynamic_condition := l_dynamic_condition ||
      ' then :l_condition := ''T''; else :l_condition := ''F''; end if; end;';
  begin
     --execute immediate l_dynamic_condition using OUT l_condition;
     l_cursor_name := dbms_sql.open_cursor;
     dbms_sql.parse(l_cursor_name, l_dynamic_condition,dbms_sql.v7) ;
     hr_utility.set_location('  parse the cursor  '||  l_cnt  , 3);
     for i in 1 .. l_cnt
     Loop
        hr_utility.set_location('  bind   '||  l_ext_adv_data(i).name || l_ext_adv_data(i).value  , 3);
        dbms_sql.bind_variable(l_cursor_name, l_ext_adv_data(i).name,
                                                 l_ext_adv_data(i).value);
     end loop ;

     -- bind the values from conditions
     for i in 1 .. l_cond_cnt
     Loop

       hr_utility.set_location('  bind   cond  '||  l_ext_adv_conditions(i).name || l_ext_adv_conditions(i).value  , 5);
       dbms_sql.bind_variable(l_cursor_name, l_ext_adv_conditions(i).name,
                                                 l_ext_adv_conditions(i).value);
     end loop ;

     dbms_sql.bind_variable(l_cursor_name, ':l_condition' , l_condition, 1 ) ;
     --
     l_cnt := dbms_sql.execute(l_cursor_name ) ;
     dbms_sql.variable_Value(l_cursor_name, ':l_condition'  ,  l_condition )  ;
     dbms_sql.close_cursor(l_cursor_name);
  exception
    when others then
      -- this needs replaced with a message for translation.
      fnd_file.put_line(fnd_file.log,
        'Error in Advanced Conditions while processing this dynamic sql statement: ');
      fnd_file.put_line(fnd_file.log, l_dynamic_condition);
      If dbms_sql.is_open(l_cursor_name) THEN
         dbms_sql.close_cursor(l_cursor_name);
      end if ;
      raise;  -- such that the error processing in ben_ext_thread occurs.
  end;
  --
  hr_utility.set_location( 'return from dbms_sql   ' || l_condition   , 99 ) ;
  --
  if l_condition = 'T' then

    if xer.sprs_cd = 'A' then  -- rollback record
       p_exclude_this_rcd_flag := true;
       exit;
    elsif xer.sprs_cd = 'B' then  -- rollback person
       p_exclude_this_rcd_flag := true;
       raise ben_ext_person.required_error;
    elsif xer.sprs_cd = 'C' then  -- rollback person and error
       p_exclude_this_rcd_flag := true;
       ben_ext_person.g_elmt_name := xer.name ;
       ben_ext_person.g_err_num := 92312;
       ben_ext_person.g_err_name := 'BEN_92312_EXT_USER_DEFINED_ERR';
       raise ben_ext_person.detail_error;
    elsif xer.sprs_cd = 'G' then -- nullify data element
       ben_ext_fmt.g_val_tab(xer.seq_num) := null;
    elsif xer.sprs_cd = 'H' then  -- signal warning
       write_warning ('BEN_92313_EXT_USER_DEFINED_WRN',92313,xer.name);
    elsif xer.sprs_cd = 'I' then -- nullify data element and signal warning
       ben_ext_fmt.g_val_tab(xer.seq_num) := null;
       write_warning ('BEN_92313_EXT_USER_DEFINED_WRN',92313,xer.name);
    end if;

  else -- l_condition = 'F'

    if xer.sprs_cd = 'D' then  -- rollback record
       p_exclude_this_rcd_flag := true;
       exit;
    elsif xer.sprs_cd = 'E' then  -- rollback person
       p_exclude_this_rcd_flag := true;
       raise ben_ext_person.required_error;
    elsif xer.sprs_cd = 'F' then  -- rollback person and error
       p_exclude_this_rcd_flag := true;
       ben_ext_person.g_err_num := 92312;
       ben_ext_person.g_elmt_name := xer.name ;
       ben_ext_person.g_err_name := 'BEN_92312_EXT_USER_DEFINED_ERR';
       raise ben_ext_person.detail_error;
    elsif xer.sprs_cd = 'J' then -- nullify data element
       ben_ext_fmt.g_val_tab(xer.seq_num) := null;
    elsif xer.sprs_cd = 'K' then  -- signal warning
       write_warning ('BEN_92313_EXT_USER_DEFINED_WRN',92313,xer.name);
    elsif xer.sprs_cd = 'L' then -- nullify data element and signal warning
       ben_ext_fmt.g_val_tab(xer.seq_num) := null;
       write_warning ('BEN_92313_EXT_USER_DEFINED_WRN',92313,xer.name);
    end if;
    --
  end if;
  --
  end if;
  --
 end loop;
--
hr_utility.set_location('Exiting'||l_proc, 15);
--
end data_elmt_in_rcd;
--
-- ----------------------------------------------------------------------------
-- |--------------------< prevent duplicates >-----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure prevent_duplicates(p_ext_rslt_id in number,
                          p_person_id in number,
                          p_any_or_all_cd in varchar2,
                          p_ext_rcd_id in number,
                          p_exclude_this_rcd_flag out nocopy boolean) is
--
l_proc     varchar2(72) := g_package||'prevent_duplicates';
l_dummy    varchar2(1);
--
/*
 This curosr ischanged for performance

cursor c_check_for_dup_rcds is
  select 'x'
  from ben_ext_rslt_dtl xrd
  where xrd.ext_rslt_id = p_ext_rslt_id
  and   xrd.person_id = p_person_id
  and   xrd.ext_rcd_id = p_ext_rcd_id
  and   nvl(xrd.val_01,'X') = nvl(ben_ext_fmt.g_val_tab(1),'X')
  and   nvl(xrd.val_02,'X') = nvl(ben_ext_fmt.g_val_tab(2),'X')
  and   nvl(xrd.val_03,'X') = nvl(ben_ext_fmt.g_val_tab(3),'X')
  and   nvl(xrd.val_04,'X') = nvl(ben_ext_fmt.g_val_tab(4),'X')
  and   nvl(xrd.val_05,'X') = nvl(ben_ext_fmt.g_val_tab(5),'X')
  and   nvl(xrd.val_06,'X') = nvl(ben_ext_fmt.g_val_tab(6),'X')
  and   nvl(xrd.val_07,'X') = nvl(ben_ext_fmt.g_val_tab(7),'X')
  and   nvl(xrd.val_08,'X') = nvl(ben_ext_fmt.g_val_tab(8),'X')
  and   nvl(xrd.val_09,'X') = nvl(ben_ext_fmt.g_val_tab(9),'X')
  and   nvl(xrd.val_10,'X') = nvl(ben_ext_fmt.g_val_tab(10),'X')
  and   nvl(xrd.val_11,'X') = nvl(ben_ext_fmt.g_val_tab(11),'X')
  and   nvl(xrd.val_12,'X') = nvl(ben_ext_fmt.g_val_tab(12),'X')
  and   nvl(xrd.val_13,'X') = nvl(ben_ext_fmt.g_val_tab(13),'X')
  and   nvl(xrd.val_14,'X') = nvl(ben_ext_fmt.g_val_tab(14),'X')
  and   nvl(xrd.val_15,'X') = nvl(ben_ext_fmt.g_val_tab(15),'X')
  and   nvl(xrd.val_16,'X') = nvl(ben_ext_fmt.g_val_tab(16),'X')
  and   nvl(xrd.val_17,'X') = nvl(ben_ext_fmt.g_val_tab(17),'X')
  and   nvl(xrd.val_18,'X') = nvl(ben_ext_fmt.g_val_tab(18),'X')
  and   nvl(xrd.val_19,'X') = nvl(ben_ext_fmt.g_val_tab(19),'X')
  and   nvl(xrd.val_20,'X') = nvl(ben_ext_fmt.g_val_tab(20),'X')
  and   nvl(xrd.val_21,'X') = nvl(ben_ext_fmt.g_val_tab(21),'X')
  and   nvl(xrd.val_22,'X') = nvl(ben_ext_fmt.g_val_tab(22),'X')
  and   nvl(xrd.val_23,'X') = nvl(ben_ext_fmt.g_val_tab(23),'X')
  and   nvl(xrd.val_24,'X') = nvl(ben_ext_fmt.g_val_tab(24),'X')
  and   nvl(xrd.val_25,'X') = nvl(ben_ext_fmt.g_val_tab(25),'X')
  and   nvl(xrd.val_26,'X') = nvl(ben_ext_fmt.g_val_tab(26),'X')
  and   nvl(xrd.val_27,'X') = nvl(ben_ext_fmt.g_val_tab(27),'X')
  and   nvl(xrd.val_28,'X') = nvl(ben_ext_fmt.g_val_tab(28),'X')
  and   nvl(xrd.val_29,'X') = nvl(ben_ext_fmt.g_val_tab(29),'X')
  and   nvl(xrd.val_30,'X') = nvl(ben_ext_fmt.g_val_tab(30),'X')
  and   nvl(xrd.val_31,'X') = nvl(ben_ext_fmt.g_val_tab(31),'X')
  and   nvl(xrd.val_32,'X') = nvl(ben_ext_fmt.g_val_tab(32),'X')
  and   nvl(xrd.val_33,'X') = nvl(ben_ext_fmt.g_val_tab(33),'X')
  and   nvl(xrd.val_34,'X') = nvl(ben_ext_fmt.g_val_tab(34),'X')
  and   nvl(xrd.val_35,'X') = nvl(ben_ext_fmt.g_val_tab(35),'X')
  and   nvl(xrd.val_36,'X') = nvl(ben_ext_fmt.g_val_tab(36),'X')
  and   nvl(xrd.val_37,'X') = nvl(ben_ext_fmt.g_val_tab(37),'X')
  and   nvl(xrd.val_38,'X') = nvl(ben_ext_fmt.g_val_tab(38),'X')
  and   nvl(xrd.val_39,'X') = nvl(ben_ext_fmt.g_val_tab(39),'X')
  and   nvl(xrd.val_40,'X') = nvl(ben_ext_fmt.g_val_tab(40),'X')
  and   nvl(xrd.val_41,'X') = nvl(ben_ext_fmt.g_val_tab(41),'X')
  and   nvl(xrd.val_42,'X') = nvl(ben_ext_fmt.g_val_tab(42),'X')
  and   nvl(xrd.val_43,'X') = nvl(ben_ext_fmt.g_val_tab(43),'X')
  and   nvl(xrd.val_44,'X') = nvl(ben_ext_fmt.g_val_tab(44),'X')
  and   nvl(xrd.val_45,'X') = nvl(ben_ext_fmt.g_val_tab(45),'X')
  and   nvl(xrd.val_46,'X') = nvl(ben_ext_fmt.g_val_tab(46),'X')
  and   nvl(xrd.val_47,'X') = nvl(ben_ext_fmt.g_val_tab(47),'X')
  and   nvl(xrd.val_48,'X') = nvl(ben_ext_fmt.g_val_tab(48),'X')
  and   nvl(xrd.val_49,'X') = nvl(ben_ext_fmt.g_val_tab(49),'X')
  and   nvl(xrd.val_50,'X') = nvl(ben_ext_fmt.g_val_tab(50),'X')
  and   nvl(xrd.val_51,'X') = nvl(ben_ext_fmt.g_val_tab(51),'X')
  and   nvl(xrd.val_52,'X') = nvl(ben_ext_fmt.g_val_tab(52),'X')
  and   nvl(xrd.val_53,'X') = nvl(ben_ext_fmt.g_val_tab(53),'X')
  and   nvl(xrd.val_54,'X') = nvl(ben_ext_fmt.g_val_tab(54),'X')
  and   nvl(xrd.val_55,'X') = nvl(ben_ext_fmt.g_val_tab(55),'X')
  and   nvl(xrd.val_56,'X') = nvl(ben_ext_fmt.g_val_tab(56),'X')
  and   nvl(xrd.val_57,'X') = nvl(ben_ext_fmt.g_val_tab(57),'X')
  and   nvl(xrd.val_58,'X') = nvl(ben_ext_fmt.g_val_tab(58),'X')
  and   nvl(xrd.val_59,'X') = nvl(ben_ext_fmt.g_val_tab(59),'X')
  and   nvl(xrd.val_60,'X') = nvl(ben_ext_fmt.g_val_tab(60),'X')
  and   nvl(xrd.val_61,'X') = nvl(ben_ext_fmt.g_val_tab(61),'X')
  and   nvl(xrd.val_62,'X') = nvl(ben_ext_fmt.g_val_tab(62),'X')
  and   nvl(xrd.val_63,'X') = nvl(ben_ext_fmt.g_val_tab(63),'X')
  and   nvl(xrd.val_64,'X') = nvl(ben_ext_fmt.g_val_tab(64),'X')
  and   nvl(xrd.val_65,'X') = nvl(ben_ext_fmt.g_val_tab(65),'X')
  and   nvl(xrd.val_66,'X') = nvl(ben_ext_fmt.g_val_tab(66),'X')
  and   nvl(xrd.val_67,'X') = nvl(ben_ext_fmt.g_val_tab(67),'X')
  and   nvl(xrd.val_68,'X') = nvl(ben_ext_fmt.g_val_tab(68),'X')
  and   nvl(xrd.val_69,'X') = nvl(ben_ext_fmt.g_val_tab(69),'X')
  and   nvl(xrd.val_70,'X') = nvl(ben_ext_fmt.g_val_tab(70),'X')
  and   nvl(xrd.val_71,'X') = nvl(ben_ext_fmt.g_val_tab(71),'X')
  and   nvl(xrd.val_72,'X') = nvl(ben_ext_fmt.g_val_tab(72),'X')
  and   nvl(xrd.val_73,'X') = nvl(ben_ext_fmt.g_val_tab(73),'X')
  and   nvl(xrd.val_74,'X') = nvl(ben_ext_fmt.g_val_tab(74),'X')
  and   nvl(xrd.val_75,'X') = nvl(ben_ext_fmt.g_val_tab(75),'X')
  and   nvl(xrd.val_76,'X') = nvl(ben_ext_fmt.g_val_tab(76),'X')
  and   nvl(xrd.val_77,'X') = nvl(ben_ext_fmt.g_val_tab(77),'X')
  and   nvl(xrd.val_78,'X') = nvl(ben_ext_fmt.g_val_tab(78),'X')
  and   nvl(xrd.val_79,'X') = nvl(ben_ext_fmt.g_val_tab(79),'X')
  and   nvl(xrd.val_80,'X') = nvl(ben_ext_fmt.g_val_tab(80),'X')
  and   nvl(xrd.val_81,'X') = nvl(ben_ext_fmt.g_val_tab(81),'X')
  and   nvl(xrd.val_82,'X') = nvl(ben_ext_fmt.g_val_tab(82),'X')
  and   nvl(xrd.val_83,'X') = nvl(ben_ext_fmt.g_val_tab(83),'X')
  and   nvl(xrd.val_84,'X') = nvl(ben_ext_fmt.g_val_tab(84),'X')
  and   nvl(xrd.val_85,'X') = nvl(ben_ext_fmt.g_val_tab(85),'X')
  and   nvl(xrd.val_86,'X') = nvl(ben_ext_fmt.g_val_tab(86),'X')
  and   nvl(xrd.val_87,'X') = nvl(ben_ext_fmt.g_val_tab(87),'X')
  and   nvl(xrd.val_88,'X') = nvl(ben_ext_fmt.g_val_tab(88),'X')
  and   nvl(xrd.val_89,'X') = nvl(ben_ext_fmt.g_val_tab(89),'X')
  and   nvl(xrd.val_90,'X') = nvl(ben_ext_fmt.g_val_tab(90),'X')
  and   nvl(xrd.val_91,'X') = nvl(ben_ext_fmt.g_val_tab(91),'X')
  and   nvl(xrd.val_92,'X') = nvl(ben_ext_fmt.g_val_tab(92),'X')
  and   nvl(xrd.val_93,'X') = nvl(ben_ext_fmt.g_val_tab(93),'X')
  and   nvl(xrd.val_94,'X') = nvl(ben_ext_fmt.g_val_tab(94),'X')
  and   nvl(xrd.val_95,'X') = nvl(ben_ext_fmt.g_val_tab(95),'X')
  and   nvl(xrd.val_96,'X') = nvl(ben_ext_fmt.g_val_tab(96),'X')
  and   nvl(xrd.val_97,'X') = nvl(ben_ext_fmt.g_val_tab(97),'X')
  and   nvl(xrd.val_98,'X') = nvl(ben_ext_fmt.g_val_tab(98),'X')
  and   nvl(xrd.val_99,'X') = nvl(ben_ext_fmt.g_val_tab(99),'X')
  and   nvl(xrd.val_100,'X') = nvl(ben_ext_fmt.g_val_tab(100),'X')
  and   nvl(xrd.val_101,'X') = nvl(ben_ext_fmt.g_val_tab(101),'X')
  and   nvl(xrd.val_102,'X') = nvl(ben_ext_fmt.g_val_tab(102),'X')
  and   nvl(xrd.val_103,'X') = nvl(ben_ext_fmt.g_val_tab(103),'X')
  and   nvl(xrd.val_104,'X') = nvl(ben_ext_fmt.g_val_tab(104),'X')
  and   nvl(xrd.val_105,'X') = nvl(ben_ext_fmt.g_val_tab(105),'X')
  and   nvl(xrd.val_106,'X') = nvl(ben_ext_fmt.g_val_tab(106),'X')
  and   nvl(xrd.val_107,'X') = nvl(ben_ext_fmt.g_val_tab(107),'X')
  and   nvl(xrd.val_108,'X') = nvl(ben_ext_fmt.g_val_tab(108),'X')
  and   nvl(xrd.val_109,'X') = nvl(ben_ext_fmt.g_val_tab(109),'X')
  and   nvl(xrd.val_110,'X') = nvl(ben_ext_fmt.g_val_tab(110),'X')
  and   nvl(xrd.val_111,'X') = nvl(ben_ext_fmt.g_val_tab(111),'X')
  and   nvl(xrd.val_112,'X') = nvl(ben_ext_fmt.g_val_tab(112),'X')
  and   nvl(xrd.val_113,'X') = nvl(ben_ext_fmt.g_val_tab(113),'X')
  and   nvl(xrd.val_114,'X') = nvl(ben_ext_fmt.g_val_tab(114),'X')
  and   nvl(xrd.val_115,'X') = nvl(ben_ext_fmt.g_val_tab(115),'X')
  and   nvl(xrd.val_116,'X') = nvl(ben_ext_fmt.g_val_tab(116),'X')
  and   nvl(xrd.val_117,'X') = nvl(ben_ext_fmt.g_val_tab(117),'X')
  and   nvl(xrd.val_118,'X') = nvl(ben_ext_fmt.g_val_tab(118),'X')
  and   nvl(xrd.val_119,'X') = nvl(ben_ext_fmt.g_val_tab(119),'X')
  and   nvl(xrd.val_120,'X') = nvl(ben_ext_fmt.g_val_tab(120),'X')
  and   nvl(xrd.val_121,'X') = nvl(ben_ext_fmt.g_val_tab(121),'X')
  and   nvl(xrd.val_122,'X') = nvl(ben_ext_fmt.g_val_tab(122),'X')
  and   nvl(xrd.val_123,'X') = nvl(ben_ext_fmt.g_val_tab(123),'X')
  and   nvl(xrd.val_124,'X') = nvl(ben_ext_fmt.g_val_tab(124),'X')
  and   nvl(xrd.val_125,'X') = nvl(ben_ext_fmt.g_val_tab(125),'X')
  and   nvl(xrd.val_126,'X') = nvl(ben_ext_fmt.g_val_tab(126),'X')
  and   nvl(xrd.val_127,'X') = nvl(ben_ext_fmt.g_val_tab(127),'X')
  and   nvl(xrd.val_128,'X') = nvl(ben_ext_fmt.g_val_tab(128),'X')
  and   nvl(xrd.val_129,'X') = nvl(ben_ext_fmt.g_val_tab(129),'X')
  and   nvl(xrd.val_130,'X') = nvl(ben_ext_fmt.g_val_tab(130),'X')
  and   nvl(xrd.val_131,'X') = nvl(ben_ext_fmt.g_val_tab(131),'X')
  and   nvl(xrd.val_132,'X') = nvl(ben_ext_fmt.g_val_tab(132),'X')
  and   nvl(xrd.val_133,'X') = nvl(ben_ext_fmt.g_val_tab(133),'X')
  and   nvl(xrd.val_134,'X') = nvl(ben_ext_fmt.g_val_tab(134),'X')
  and   nvl(xrd.val_135,'X') = nvl(ben_ext_fmt.g_val_tab(135),'X')
  and   nvl(xrd.val_136,'X') = nvl(ben_ext_fmt.g_val_tab(136),'X')
  and   nvl(xrd.val_137,'X') = nvl(ben_ext_fmt.g_val_tab(137),'X')
  and   nvl(xrd.val_138,'X') = nvl(ben_ext_fmt.g_val_tab(138),'X')
  and   nvl(xrd.val_139,'X') = nvl(ben_ext_fmt.g_val_tab(139),'X')
  and   nvl(xrd.val_140,'X') = nvl(ben_ext_fmt.g_val_tab(140),'X')
  and   nvl(xrd.val_141,'X') = nvl(ben_ext_fmt.g_val_tab(141),'X')
  and   nvl(xrd.val_142,'X') = nvl(ben_ext_fmt.g_val_tab(142),'X')
  and   nvl(xrd.val_143,'X') = nvl(ben_ext_fmt.g_val_tab(143),'X')
  and   nvl(xrd.val_144,'X') = nvl(ben_ext_fmt.g_val_tab(144),'X')
  and   nvl(xrd.val_145,'X') = nvl(ben_ext_fmt.g_val_tab(145),'X')
  and   nvl(xrd.val_146,'X') = nvl(ben_ext_fmt.g_val_tab(146),'X')
  and   nvl(xrd.val_147,'X') = nvl(ben_ext_fmt.g_val_tab(147),'X')
  and   nvl(xrd.val_148,'X') = nvl(ben_ext_fmt.g_val_tab(148),'X')
  and   nvl(xrd.val_149,'X') = nvl(ben_ext_fmt.g_val_tab(149),'X')
  and   nvl(xrd.val_150,'X') = nvl(ben_ext_fmt.g_val_tab(150),'X')
  and   nvl(xrd.val_151,'X') = nvl(ben_ext_fmt.g_val_tab(151),'X')
  and   nvl(xrd.val_152,'X') = nvl(ben_ext_fmt.g_val_tab(152),'X')
  and   nvl(xrd.val_153,'X') = nvl(ben_ext_fmt.g_val_tab(153),'X')
  and   nvl(xrd.val_154,'X') = nvl(ben_ext_fmt.g_val_tab(154),'X')
  and   nvl(xrd.val_155,'X') = nvl(ben_ext_fmt.g_val_tab(155),'X')
  and   nvl(xrd.val_156,'X') = nvl(ben_ext_fmt.g_val_tab(156),'X')
  and   nvl(xrd.val_157,'X') = nvl(ben_ext_fmt.g_val_tab(157),'X')
  and   nvl(xrd.val_158,'X') = nvl(ben_ext_fmt.g_val_tab(158),'X')
  and   nvl(xrd.val_159,'X') = nvl(ben_ext_fmt.g_val_tab(159),'X')
  and   nvl(xrd.val_160,'X') = nvl(ben_ext_fmt.g_val_tab(160),'X')
  and   nvl(xrd.val_161,'X') = nvl(ben_ext_fmt.g_val_tab(161),'X')
  and   nvl(xrd.val_162,'X') = nvl(ben_ext_fmt.g_val_tab(162),'X')
  and   nvl(xrd.val_163,'X') = nvl(ben_ext_fmt.g_val_tab(163),'X')
  and   nvl(xrd.val_164,'X') = nvl(ben_ext_fmt.g_val_tab(164),'X')
  and   nvl(xrd.val_165,'X') = nvl(ben_ext_fmt.g_val_tab(165),'X')
  and   nvl(xrd.val_166,'X') = nvl(ben_ext_fmt.g_val_tab(166),'X')
  and   nvl(xrd.val_167,'X') = nvl(ben_ext_fmt.g_val_tab(167),'X')
  and   nvl(xrd.val_168,'X') = nvl(ben_ext_fmt.g_val_tab(168),'X')
  and   nvl(xrd.val_169,'X') = nvl(ben_ext_fmt.g_val_tab(169),'X')
  and   nvl(xrd.val_170,'X') = nvl(ben_ext_fmt.g_val_tab(170),'X')
  and   nvl(xrd.val_171,'X') = nvl(ben_ext_fmt.g_val_tab(171),'X')
  and   nvl(xrd.val_172,'X') = nvl(ben_ext_fmt.g_val_tab(172),'X')
  and   nvl(xrd.val_173,'X') = nvl(ben_ext_fmt.g_val_tab(173),'X')
  and   nvl(xrd.val_174,'X') = nvl(ben_ext_fmt.g_val_tab(174),'X')
  and   nvl(xrd.val_175,'X') = nvl(ben_ext_fmt.g_val_tab(175),'X')
  and   nvl(xrd.val_176,'X') = nvl(ben_ext_fmt.g_val_tab(176),'X')
  and   nvl(xrd.val_177,'X') = nvl(ben_ext_fmt.g_val_tab(177),'X')
  and   nvl(xrd.val_178,'X') = nvl(ben_ext_fmt.g_val_tab(178),'X')
  and   nvl(xrd.val_179,'X') = nvl(ben_ext_fmt.g_val_tab(179),'X')
  and   nvl(xrd.val_180,'X') = nvl(ben_ext_fmt.g_val_tab(180),'X')
  and   nvl(xrd.val_181,'X') = nvl(ben_ext_fmt.g_val_tab(181),'X')
  and   nvl(xrd.val_182,'X') = nvl(ben_ext_fmt.g_val_tab(182),'X')
  and   nvl(xrd.val_183,'X') = nvl(ben_ext_fmt.g_val_tab(183),'X')
  and   nvl(xrd.val_184,'X') = nvl(ben_ext_fmt.g_val_tab(184),'X')
  and   nvl(xrd.val_185,'X') = nvl(ben_ext_fmt.g_val_tab(185),'X')
  and   nvl(xrd.val_186,'X') = nvl(ben_ext_fmt.g_val_tab(186),'X')
  and   nvl(xrd.val_187,'X') = nvl(ben_ext_fmt.g_val_tab(187),'X')
  and   nvl(xrd.val_188,'X') = nvl(ben_ext_fmt.g_val_tab(188),'X')
  and   nvl(xrd.val_189,'X') = nvl(ben_ext_fmt.g_val_tab(189),'X')
  and   nvl(xrd.val_190,'X') = nvl(ben_ext_fmt.g_val_tab(190),'X')
  and   nvl(xrd.val_191,'X') = nvl(ben_ext_fmt.g_val_tab(191),'X')
  and   nvl(xrd.val_192,'X') = nvl(ben_ext_fmt.g_val_tab(192),'X')
  and   nvl(xrd.val_193,'X') = nvl(ben_ext_fmt.g_val_tab(193),'X')
  and   nvl(xrd.val_194,'X') = nvl(ben_ext_fmt.g_val_tab(194),'X')
  and   nvl(xrd.val_195,'X') = nvl(ben_ext_fmt.g_val_tab(195),'X')
  and   nvl(xrd.val_196,'X') = nvl(ben_ext_fmt.g_val_tab(196),'X')
  and   nvl(xrd.val_197,'X') = nvl(ben_ext_fmt.g_val_tab(197),'X')
  and   nvl(xrd.val_198,'X') = nvl(ben_ext_fmt.g_val_tab(198),'X')
  and   nvl(xrd.val_199,'X') = nvl(ben_ext_fmt.g_val_tab(199),'X')
  and   nvl(xrd.val_200,'X') = nvl(ben_ext_fmt.g_val_tab(200),'X')
  and   nvl(xrd.val_201,'X') = nvl(ben_ext_fmt.g_val_tab(201),'X')
  and   nvl(xrd.val_202,'X') = nvl(ben_ext_fmt.g_val_tab(202),'X')
  and   nvl(xrd.val_203,'X') = nvl(ben_ext_fmt.g_val_tab(203),'X')
  and   nvl(xrd.val_204,'X') = nvl(ben_ext_fmt.g_val_tab(204),'X')
  and   nvl(xrd.val_205,'X') = nvl(ben_ext_fmt.g_val_tab(205),'X')
  and   nvl(xrd.val_206,'X') = nvl(ben_ext_fmt.g_val_tab(206),'X')
  and   nvl(xrd.val_207,'X') = nvl(ben_ext_fmt.g_val_tab(207),'X')
  and   nvl(xrd.val_208,'X') = nvl(ben_ext_fmt.g_val_tab(208),'X')
  and   nvl(xrd.val_209,'X') = nvl(ben_ext_fmt.g_val_tab(209),'X')
  and   nvl(xrd.val_210,'X') = nvl(ben_ext_fmt.g_val_tab(210),'X')
  and   nvl(xrd.val_211,'X') = nvl(ben_ext_fmt.g_val_tab(211),'X')
  and   nvl(xrd.val_212,'X') = nvl(ben_ext_fmt.g_val_tab(212),'X')
  and   nvl(xrd.val_213,'X') = nvl(ben_ext_fmt.g_val_tab(213),'X')
  and   nvl(xrd.val_214,'X') = nvl(ben_ext_fmt.g_val_tab(214),'X')
  and   nvl(xrd.val_215,'X') = nvl(ben_ext_fmt.g_val_tab(215),'X')
  and   nvl(xrd.val_216,'X') = nvl(ben_ext_fmt.g_val_tab(216),'X')
  and   nvl(xrd.val_217,'X') = nvl(ben_ext_fmt.g_val_tab(217),'X')
  and   nvl(xrd.val_218,'X') = nvl(ben_ext_fmt.g_val_tab(218),'X')
  and   nvl(xrd.val_219,'X') = nvl(ben_ext_fmt.g_val_tab(219),'X')
  and   nvl(xrd.val_220,'X') = nvl(ben_ext_fmt.g_val_tab(220),'X')
  and   nvl(xrd.val_221,'X') = nvl(ben_ext_fmt.g_val_tab(221),'X')
  and   nvl(xrd.val_222,'X') = nvl(ben_ext_fmt.g_val_tab(222),'X')
  and   nvl(xrd.val_223,'X') = nvl(ben_ext_fmt.g_val_tab(223),'X')
  and   nvl(xrd.val_224,'X') = nvl(ben_ext_fmt.g_val_tab(224),'X')
  and   nvl(xrd.val_225,'X') = nvl(ben_ext_fmt.g_val_tab(225),'X')
  and   nvl(xrd.val_226,'X') = nvl(ben_ext_fmt.g_val_tab(226),'X')
  and   nvl(xrd.val_227,'X') = nvl(ben_ext_fmt.g_val_tab(227),'X')
  and   nvl(xrd.val_228,'X') = nvl(ben_ext_fmt.g_val_tab(228),'X')
  and   nvl(xrd.val_229,'X') = nvl(ben_ext_fmt.g_val_tab(229),'X')
  and   nvl(xrd.val_230,'X') = nvl(ben_ext_fmt.g_val_tab(230),'X')
  and   nvl(xrd.val_231,'X') = nvl(ben_ext_fmt.g_val_tab(231),'X')
  and   nvl(xrd.val_232,'X') = nvl(ben_ext_fmt.g_val_tab(232),'X')
  and   nvl(xrd.val_233,'X') = nvl(ben_ext_fmt.g_val_tab(233),'X')
  and   nvl(xrd.val_234,'X') = nvl(ben_ext_fmt.g_val_tab(234),'X')
  and   nvl(xrd.val_235,'X') = nvl(ben_ext_fmt.g_val_tab(235),'X')
  and   nvl(xrd.val_236,'X') = nvl(ben_ext_fmt.g_val_tab(236),'X')
  and   nvl(xrd.val_237,'X') = nvl(ben_ext_fmt.g_val_tab(237),'X')
  and   nvl(xrd.val_238,'X') = nvl(ben_ext_fmt.g_val_tab(238),'X')
  and   nvl(xrd.val_239,'X') = nvl(ben_ext_fmt.g_val_tab(239),'X')
  and   nvl(xrd.val_240,'X') = nvl(ben_ext_fmt.g_val_tab(240),'X')
  and   nvl(xrd.val_241,'X') = nvl(ben_ext_fmt.g_val_tab(241),'X')
  and   nvl(xrd.val_242,'X') = nvl(ben_ext_fmt.g_val_tab(242),'X')
  and   nvl(xrd.val_243,'X') = nvl(ben_ext_fmt.g_val_tab(243),'X')
  and   nvl(xrd.val_244,'X') = nvl(ben_ext_fmt.g_val_tab(244),'X')
  and   nvl(xrd.val_245,'X') = nvl(ben_ext_fmt.g_val_tab(245),'X')
  and   nvl(xrd.val_246,'X') = nvl(ben_ext_fmt.g_val_tab(246),'X')
  and   nvl(xrd.val_247,'X') = nvl(ben_ext_fmt.g_val_tab(247),'X')
  and   nvl(xrd.val_248,'X') = nvl(ben_ext_fmt.g_val_tab(248),'X')
  and   nvl(xrd.val_249,'X') = nvl(ben_ext_fmt.g_val_tab(249),'X')
  and   nvl(xrd.val_250,'X') = nvl(ben_ext_fmt.g_val_tab(250),'X')
  and   nvl(xrd.val_251,'X') = nvl(ben_ext_fmt.g_val_tab(251),'X')
  and   nvl(xrd.val_252,'X') = nvl(ben_ext_fmt.g_val_tab(252),'X')
  and   nvl(xrd.val_253,'X') = nvl(ben_ext_fmt.g_val_tab(253),'X')
  and   nvl(xrd.val_254,'X') = nvl(ben_ext_fmt.g_val_tab(254),'X')
  and   nvl(xrd.val_255,'X') = nvl(ben_ext_fmt.g_val_tab(255),'X')
  and   nvl(xrd.val_256,'X') = nvl(ben_ext_fmt.g_val_tab(256),'X')
  and   nvl(xrd.val_257,'X') = nvl(ben_ext_fmt.g_val_tab(257),'X')
  and   nvl(xrd.val_258,'X') = nvl(ben_ext_fmt.g_val_tab(258),'X')
  and   nvl(xrd.val_259,'X') = nvl(ben_ext_fmt.g_val_tab(259),'X')
  and   nvl(xrd.val_260,'X') = nvl(ben_ext_fmt.g_val_tab(260),'X')
  and   nvl(xrd.val_261,'X') = nvl(ben_ext_fmt.g_val_tab(261),'X')
  and   nvl(xrd.val_262,'X') = nvl(ben_ext_fmt.g_val_tab(262),'X')
  and   nvl(xrd.val_263,'X') = nvl(ben_ext_fmt.g_val_tab(263),'X')
  and   nvl(xrd.val_264,'X') = nvl(ben_ext_fmt.g_val_tab(264),'X')
  and   nvl(xrd.val_265,'X') = nvl(ben_ext_fmt.g_val_tab(265),'X')
  and   nvl(xrd.val_266,'X') = nvl(ben_ext_fmt.g_val_tab(266),'X')
  and   nvl(xrd.val_267,'X') = nvl(ben_ext_fmt.g_val_tab(267),'X')
  and   nvl(xrd.val_268,'X') = nvl(ben_ext_fmt.g_val_tab(268),'X')
  and   nvl(xrd.val_269,'X') = nvl(ben_ext_fmt.g_val_tab(269),'X')
  and   nvl(xrd.val_270,'X') = nvl(ben_ext_fmt.g_val_tab(270),'X')
  and   nvl(xrd.val_271,'X') = nvl(ben_ext_fmt.g_val_tab(271),'X')
  and   nvl(xrd.val_272,'X') = nvl(ben_ext_fmt.g_val_tab(272),'X')
  and   nvl(xrd.val_273,'X') = nvl(ben_ext_fmt.g_val_tab(273),'X')
  and   nvl(xrd.val_274,'X') = nvl(ben_ext_fmt.g_val_tab(274),'X')
  and   nvl(xrd.val_275,'X') = nvl(ben_ext_fmt.g_val_tab(275),'X')
  and   nvl(xrd.val_276,'X') = nvl(ben_ext_fmt.g_val_tab(276),'X')
  and   nvl(xrd.val_277,'X') = nvl(ben_ext_fmt.g_val_tab(277),'X')
  and   nvl(xrd.val_278,'X') = nvl(ben_ext_fmt.g_val_tab(278),'X')
  and   nvl(xrd.val_279,'X') = nvl(ben_ext_fmt.g_val_tab(279),'X')
  and   nvl(xrd.val_280,'X') = nvl(ben_ext_fmt.g_val_tab(280),'X')
  and   nvl(xrd.val_281,'X') = nvl(ben_ext_fmt.g_val_tab(281),'X')
  and   nvl(xrd.val_282,'X') = nvl(ben_ext_fmt.g_val_tab(282),'X')
  and   nvl(xrd.val_283,'X') = nvl(ben_ext_fmt.g_val_tab(283),'X')
  and   nvl(xrd.val_284,'X') = nvl(ben_ext_fmt.g_val_tab(284),'X')
  and   nvl(xrd.val_285,'X') = nvl(ben_ext_fmt.g_val_tab(285),'X')
  and   nvl(xrd.val_286,'X') = nvl(ben_ext_fmt.g_val_tab(286),'X')
  and   nvl(xrd.val_287,'X') = nvl(ben_ext_fmt.g_val_tab(287),'X')
  and   nvl(xrd.val_288,'X') = nvl(ben_ext_fmt.g_val_tab(288),'X')
  and   nvl(xrd.val_289,'X') = nvl(ben_ext_fmt.g_val_tab(289),'X')
  and   nvl(xrd.val_290,'X') = nvl(ben_ext_fmt.g_val_tab(290),'X')
  and   nvl(xrd.val_291,'X') = nvl(ben_ext_fmt.g_val_tab(291),'X')
  and   nvl(xrd.val_292,'X') = nvl(ben_ext_fmt.g_val_tab(292),'X')
  and   nvl(xrd.val_293,'X') = nvl(ben_ext_fmt.g_val_tab(293),'X')
  and   nvl(xrd.val_294,'X') = nvl(ben_ext_fmt.g_val_tab(294),'X')
  and   nvl(xrd.val_295,'X') = nvl(ben_ext_fmt.g_val_tab(295),'X')
  and   nvl(xrd.val_296,'X') = nvl(ben_ext_fmt.g_val_tab(296),'X')
  and   nvl(xrd.val_297,'X') = nvl(ben_ext_fmt.g_val_tab(297),'X')
  and   nvl(xrd.val_298,'X') = nvl(ben_ext_fmt.g_val_tab(298),'X')
  and   nvl(xrd.val_299,'X') = nvl(ben_ext_fmt.g_val_tab(299),'X')
  and   nvl(xrd.val_300,'X') = nvl(ben_ext_fmt.g_val_tab(300),'X')
  ;


*/


cursor c_check_for_dup_rcds
    (c_rslt_id   number
    ,c_per_id    number
    ,c_extrcd_id number
    )
  is SELECT
         xrd.val_01,
         xrd.val_02,
         xrd.val_03,
         xrd.val_04,
         xrd.val_05,
         xrd.val_06,
         xrd.val_07,
         xrd.val_08,
         xrd.val_09,
         xrd.val_10,
         xrd.val_11,
         xrd.val_12,
         xrd.val_13,
         xrd.val_14,
         xrd.val_15,
         xrd.val_16,
         xrd.val_17,
         xrd.val_18,
         xrd.val_19,
         xrd.val_20,
         xrd.val_21,
         xrd.val_22,
         xrd.val_23,
         xrd.val_24,
         xrd.val_25,
         xrd.val_26,
         xrd.val_27,
         xrd.val_28,
         xrd.val_29,
         xrd.val_30,
         xrd.val_31,
         xrd.val_32,
         xrd.val_33,
         xrd.val_34,
         xrd.val_35,
         xrd.val_36,
         xrd.val_37,
         xrd.val_38,
         xrd.val_39,
         xrd.val_40,
         xrd.val_41,
         xrd.val_42,
         xrd.val_43,
         xrd.val_44,
         xrd.val_45,
         xrd.val_46,
         xrd.val_47,
         xrd.val_48,
         xrd.val_49,
         xrd.val_50,
         xrd.val_51,
         xrd.val_52,
         xrd.val_53,
         xrd.val_54,
         xrd.val_55,
         xrd.val_56,
         xrd.val_57,
         xrd.val_58,
         xrd.val_59,
         xrd.val_60,
         xrd.val_61,
         xrd.val_62,
         xrd.val_63,
         xrd.val_64,
         xrd.val_65,
         xrd.val_66,
         xrd.val_67,
         xrd.val_68,
         xrd.val_69,
         xrd.val_70,
         xrd.val_71,
         xrd.val_72,
         xrd.val_73,
         xrd.val_74,
         xrd.val_75,
         xrd.val_76,
         xrd.val_77,
         xrd.val_78,
         xrd.val_79,
         xrd.val_80,
         xrd.val_81,
         xrd.val_82,
         xrd.val_83,
         xrd.val_84,
         xrd.val_85,
         xrd.val_86,
         xrd.val_87,
         xrd.val_88,
         xrd.val_89,
         xrd.val_90,
         xrd.val_91,
         xrd.val_92,
         xrd.val_93,
         xrd.val_94,
         xrd.val_95,
         xrd.val_96,
         xrd.val_97,
         xrd.val_98,
         xrd.val_99,
         xrd.val_100,
         xrd.val_101,
         xrd.val_102,
         xrd.val_103,
         xrd.val_104,
         xrd.val_105,
         xrd.val_106,
         xrd.val_107,
         xrd.val_108,
         xrd.val_109,
         xrd.val_110,
         xrd.val_111,
         xrd.val_112,
         xrd.val_113,
         xrd.val_114,
         xrd.val_115,
         xrd.val_116,
         xrd.val_117,
         xrd.val_118,
         xrd.val_119,
         xrd.val_120,
         xrd.val_121,
         xrd.val_122,
         xrd.val_123,
         xrd.val_124,
         xrd.val_125,
         xrd.val_126,
         xrd.val_127,
         xrd.val_128,
         xrd.val_129,
         xrd.val_130,
         xrd.val_131,
         xrd.val_132,
         xrd.val_133,
         xrd.val_134,
         xrd.val_135,
         xrd.val_136,
         xrd.val_137,
         xrd.val_138,
         xrd.val_139,
         xrd.val_140,
         xrd.val_141,
         xrd.val_142,
         xrd.val_143,
         xrd.val_144,
         xrd.val_145,
         xrd.val_146,
         xrd.val_147,
         xrd.val_148,
         xrd.val_149,
         xrd.val_150,
         xrd.val_151,
         xrd.val_152,
         xrd.val_153,
         xrd.val_154,
         xrd.val_155,
         xrd.val_156,
         xrd.val_157,
         xrd.val_158,
         xrd.val_159,
         xrd.val_160,
         xrd.val_161,
         xrd.val_162,
         xrd.val_163,
         xrd.val_164,
         xrd.val_165,
         xrd.val_166,
         xrd.val_167,
         xrd.val_168,
         xrd.val_169,
         xrd.val_170,
         xrd.val_171,
         xrd.val_172,
         xrd.val_173,
         xrd.val_174,
         xrd.val_175,
         xrd.val_176,
         xrd.val_177,
         xrd.val_178,
         xrd.val_179,
         xrd.val_180,
         xrd.val_181,
         xrd.val_182,
         xrd.val_183,
         xrd.val_184,
         xrd.val_185,
         xrd.val_186,
         xrd.val_187,
         xrd.val_188,
         xrd.val_189,
         xrd.val_190,
         xrd.val_191,
         xrd.val_192,
         xrd.val_193,
         xrd.val_194,
         xrd.val_195,
         xrd.val_196,
         xrd.val_197,
         xrd.val_198,
         xrd.val_199,
         xrd.val_200,
         xrd.val_201,
         xrd.val_202,
         xrd.val_203,
         xrd.val_204,
         xrd.val_205,
         xrd.val_206,
         xrd.val_207,
         xrd.val_208,
         xrd.val_209,
         xrd.val_210,
         xrd.val_211,
         xrd.val_212,
         xrd.val_213,
         xrd.val_214,
         xrd.val_215,
         xrd.val_216,
         xrd.val_217,
         xrd.val_218,
         xrd.val_219,
         xrd.val_220,
         xrd.val_221,
         xrd.val_222,
         xrd.val_223,
         xrd.val_224,
         xrd.val_225,
         xrd.val_226,
         xrd.val_227,
         xrd.val_228,
         xrd.val_229,
         xrd.val_230,
         xrd.val_231,
         xrd.val_232,
         xrd.val_233,
         xrd.val_234,
         xrd.val_235,
         xrd.val_236,
         xrd.val_237,
         xrd.val_238,
         xrd.val_239,
         xrd.val_240,
         xrd.val_241,
         xrd.val_242,
         xrd.val_243,
         xrd.val_244,
         xrd.val_245,
         xrd.val_246,
         xrd.val_247,
         xrd.val_248,
         xrd.val_249,
         xrd.val_250,
         xrd.val_251,
         xrd.val_252,
         xrd.val_253,
         xrd.val_254,
         xrd.val_255,
         xrd.val_256,
         xrd.val_257,
         xrd.val_258,
         xrd.val_259,
         xrd.val_260,
         xrd.val_261,
         xrd.val_262,
         xrd.val_263,
         xrd.val_264,
         xrd.val_265,
         xrd.val_266,
         xrd.val_267,
         xrd.val_268,
         xrd.val_269,
         xrd.val_270,
         xrd.val_271,
         xrd.val_272,
         xrd.val_273,
         xrd.val_274,
         xrd.val_275,
         xrd.val_276,
         xrd.val_277,
         xrd.val_278,
         xrd.val_279,
         xrd.val_280,
         xrd.val_281,
         xrd.val_282,
         xrd.val_283,
         xrd.val_284,
         xrd.val_285,
         xrd.val_286,
         xrd.val_287,
         xrd.val_288,
         xrd.val_289,
         xrd.val_290,
         xrd.val_291,
         xrd.val_292,
         xrd.val_293,
         xrd.val_294,
         xrd.val_295,
         xrd.val_296,
         xrd.val_297,
         xrd.val_298,
         xrd.val_299,
         xrd.val_300
    from ben_ext_rslt_dtl xrd
    where xrd.ext_rslt_id = c_rslt_id
    and   xrd.person_id = c_per_id
    and   xrd.ext_rcd_id = c_extrcd_id
    ;



--
begin
--
hr_utility.set_location('Entering'||l_proc, 5);
--
p_exclude_this_rcd_flag := false;
--
if p_any_or_all_cd = 'Y' then

  for  row in  c_check_for_dup_rcds
           (c_rslt_id   => p_ext_rslt_id
           ,c_per_id    => p_person_id
           ,c_extrcd_id => p_ext_rcd_id
           )
   Loop


     if nvl(row.val_01,'X') = nvl(ben_ext_fmt.g_val_tab(1),'X')
        and nvl(row.val_02,'X') = nvl(ben_ext_fmt.g_val_tab(2),'X')
        and nvl(row.val_03,'X') = nvl(ben_ext_fmt.g_val_tab(3),'X')
        and nvl(row.val_04,'X') = nvl(ben_ext_fmt.g_val_tab(4),'X')
        and nvl(row.val_05,'X') = nvl(ben_ext_fmt.g_val_tab(5),'X')
        and nvl(row.val_06,'X') = nvl(ben_ext_fmt.g_val_tab(6),'X')
        and nvl(row.val_07,'X') = nvl(ben_ext_fmt.g_val_tab(7),'X')
        and nvl(row.val_08,'X') = nvl(ben_ext_fmt.g_val_tab(8),'X')
        and nvl(row.val_09,'X') = nvl(ben_ext_fmt.g_val_tab(9),'X')
        and nvl(row.val_10,'X') = nvl(ben_ext_fmt.g_val_tab(10),'X')
        and nvl(row.val_11,'X') = nvl(ben_ext_fmt.g_val_tab(11),'X')
        and nvl(row.val_12,'X') = nvl(ben_ext_fmt.g_val_tab(12),'X')
        and nvl(row.val_13,'X') = nvl(ben_ext_fmt.g_val_tab(13),'X')
        and nvl(row.val_14,'X') = nvl(ben_ext_fmt.g_val_tab(14),'X')
        and nvl(row.val_15,'X') = nvl(ben_ext_fmt.g_val_tab(15),'X')
        and nvl(row.val_16,'X') = nvl(ben_ext_fmt.g_val_tab(16),'X')
        and nvl(row.val_17,'X') = nvl(ben_ext_fmt.g_val_tab(17),'X')
        and nvl(row.val_18,'X') = nvl(ben_ext_fmt.g_val_tab(18),'X')
        and nvl(row.val_19,'X') = nvl(ben_ext_fmt.g_val_tab(19),'X')
        and nvl(row.val_20,'X') = nvl(ben_ext_fmt.g_val_tab(20),'X')
        and nvl(row.val_21,'X') = nvl(ben_ext_fmt.g_val_tab(21),'X')
        and nvl(row.val_22,'X') = nvl(ben_ext_fmt.g_val_tab(22),'X')
        and nvl(row.val_23,'X') = nvl(ben_ext_fmt.g_val_tab(23),'X')
        and nvl(row.val_24,'X') = nvl(ben_ext_fmt.g_val_tab(24),'X')
        and nvl(row.val_25,'X') = nvl(ben_ext_fmt.g_val_tab(25),'X')
        and nvl(row.val_26,'X') = nvl(ben_ext_fmt.g_val_tab(26),'X')
        and nvl(row.val_27,'X') = nvl(ben_ext_fmt.g_val_tab(27),'X')
        and nvl(row.val_28,'X') = nvl(ben_ext_fmt.g_val_tab(28),'X')
        and nvl(row.val_29,'X') = nvl(ben_ext_fmt.g_val_tab(29),'X')
        and nvl(row.val_30,'X') = nvl(ben_ext_fmt.g_val_tab(30),'X')
        and nvl(row.val_31,'X') = nvl(ben_ext_fmt.g_val_tab(31),'X')
        and nvl(row.val_32,'X') = nvl(ben_ext_fmt.g_val_tab(32),'X')
        and nvl(row.val_33,'X') = nvl(ben_ext_fmt.g_val_tab(33),'X')
        and nvl(row.val_34,'X') = nvl(ben_ext_fmt.g_val_tab(34),'X')
        and nvl(row.val_35,'X') = nvl(ben_ext_fmt.g_val_tab(35),'X')
        and nvl(row.val_36,'X') = nvl(ben_ext_fmt.g_val_tab(36),'X')
        and nvl(row.val_37,'X') = nvl(ben_ext_fmt.g_val_tab(37),'X')
        and nvl(row.val_38,'X') = nvl(ben_ext_fmt.g_val_tab(38),'X')
        and nvl(row.val_39,'X') = nvl(ben_ext_fmt.g_val_tab(39),'X')
        and nvl(row.val_40,'X') = nvl(ben_ext_fmt.g_val_tab(40),'X')
        and nvl(row.val_41,'X') = nvl(ben_ext_fmt.g_val_tab(41),'X')
        and nvl(row.val_42,'X') = nvl(ben_ext_fmt.g_val_tab(42),'X')
        and nvl(row.val_43,'X') = nvl(ben_ext_fmt.g_val_tab(43),'X')
        and nvl(row.val_44,'X') = nvl(ben_ext_fmt.g_val_tab(44),'X')
        and nvl(row.val_45,'X') = nvl(ben_ext_fmt.g_val_tab(45),'X')
        and nvl(row.val_46,'X') = nvl(ben_ext_fmt.g_val_tab(46),'X')
        and nvl(row.val_47,'X') = nvl(ben_ext_fmt.g_val_tab(47),'X')
        and nvl(row.val_48,'X') = nvl(ben_ext_fmt.g_val_tab(48),'X')
        and nvl(row.val_49,'X') = nvl(ben_ext_fmt.g_val_tab(49),'X')
        and nvl(row.val_50,'X') = nvl(ben_ext_fmt.g_val_tab(50),'X')
        and nvl(row.val_51,'X') = nvl(ben_ext_fmt.g_val_tab(51),'X')
        and nvl(row.val_52,'X') = nvl(ben_ext_fmt.g_val_tab(52),'X')
        and nvl(row.val_53,'X') = nvl(ben_ext_fmt.g_val_tab(53),'X')
        and nvl(row.val_54,'X') = nvl(ben_ext_fmt.g_val_tab(54),'X')
        and nvl(row.val_55,'X') = nvl(ben_ext_fmt.g_val_tab(55),'X')
        and nvl(row.val_56,'X') = nvl(ben_ext_fmt.g_val_tab(56),'X')
        and nvl(row.val_57,'X') = nvl(ben_ext_fmt.g_val_tab(57),'X')
        and nvl(row.val_58,'X') = nvl(ben_ext_fmt.g_val_tab(58),'X')
        and nvl(row.val_59,'X') = nvl(ben_ext_fmt.g_val_tab(59),'X')
        and nvl(row.val_60,'X') = nvl(ben_ext_fmt.g_val_tab(60),'X')
        and nvl(row.val_61,'X') = nvl(ben_ext_fmt.g_val_tab(61),'X')
        and nvl(row.val_62,'X') = nvl(ben_ext_fmt.g_val_tab(62),'X')
        and nvl(row.val_63,'X') = nvl(ben_ext_fmt.g_val_tab(63),'X')
        and nvl(row.val_64,'X') = nvl(ben_ext_fmt.g_val_tab(64),'X')
        and nvl(row.val_65,'X') = nvl(ben_ext_fmt.g_val_tab(65),'X')
        and nvl(row.val_66,'X') = nvl(ben_ext_fmt.g_val_tab(66),'X')
        and nvl(row.val_67,'X') = nvl(ben_ext_fmt.g_val_tab(67),'X')
        and nvl(row.val_68,'X') = nvl(ben_ext_fmt.g_val_tab(68),'X')
        and nvl(row.val_69,'X') = nvl(ben_ext_fmt.g_val_tab(69),'X')
        and nvl(row.val_70,'X') = nvl(ben_ext_fmt.g_val_tab(70),'X')
        and nvl(row.val_71,'X') = nvl(ben_ext_fmt.g_val_tab(71),'X')
        and nvl(row.val_72,'X') = nvl(ben_ext_fmt.g_val_tab(72),'X')
        and nvl(row.val_73,'X') = nvl(ben_ext_fmt.g_val_tab(73),'X')
        and nvl(row.val_74,'X') = nvl(ben_ext_fmt.g_val_tab(74),'X')
        and nvl(row.val_75,'X') = nvl(ben_ext_fmt.g_val_tab(75),'X')
        and nvl(row.val_76,'X') = nvl(ben_ext_fmt.g_val_tab(76),'X')
        and nvl(row.val_77,'X') = nvl(ben_ext_fmt.g_val_tab(77),'X')
        and nvl(row.val_78,'X') = nvl(ben_ext_fmt.g_val_tab(78),'X')
        and nvl(row.val_79,'X') = nvl(ben_ext_fmt.g_val_tab(79),'X')
        and nvl(row.val_80,'X') = nvl(ben_ext_fmt.g_val_tab(80),'X')
        and nvl(row.val_81,'X') = nvl(ben_ext_fmt.g_val_tab(81),'X')
        and nvl(row.val_82,'X') = nvl(ben_ext_fmt.g_val_tab(82),'X')
        and nvl(row.val_83,'X') = nvl(ben_ext_fmt.g_val_tab(83),'X')
        and nvl(row.val_84,'X') = nvl(ben_ext_fmt.g_val_tab(84),'X')
        and nvl(row.val_85,'X') = nvl(ben_ext_fmt.g_val_tab(85),'X')
        and nvl(row.val_86,'X') = nvl(ben_ext_fmt.g_val_tab(86),'X')
        and nvl(row.val_87,'X') = nvl(ben_ext_fmt.g_val_tab(87),'X')
        and nvl(row.val_88,'X') = nvl(ben_ext_fmt.g_val_tab(88),'X')
        and nvl(row.val_89,'X') = nvl(ben_ext_fmt.g_val_tab(89),'X')
        and nvl(row.val_90,'X') = nvl(ben_ext_fmt.g_val_tab(90),'X')
        and nvl(row.val_91,'X') = nvl(ben_ext_fmt.g_val_tab(91),'X')
        and nvl(row.val_92,'X') = nvl(ben_ext_fmt.g_val_tab(92),'X')
        and nvl(row.val_93,'X') = nvl(ben_ext_fmt.g_val_tab(93),'X')
        and nvl(row.val_94,'X') = nvl(ben_ext_fmt.g_val_tab(94),'X')
        and nvl(row.val_95,'X') = nvl(ben_ext_fmt.g_val_tab(95),'X')
        and nvl(row.val_96,'X') = nvl(ben_ext_fmt.g_val_tab(96),'X')
        and nvl(row.val_97,'X') = nvl(ben_ext_fmt.g_val_tab(97),'X')
        and nvl(row.val_98,'X') = nvl(ben_ext_fmt.g_val_tab(98),'X')
        and nvl(row.val_99,'X') = nvl(ben_ext_fmt.g_val_tab(99),'X')
        and nvl(row.val_100,'X') = nvl(ben_ext_fmt.g_val_tab(100),'X')
        and nvl(row.val_101,'X') = nvl(ben_ext_fmt.g_val_tab(101),'X')
        and nvl(row.val_102,'X') = nvl(ben_ext_fmt.g_val_tab(102),'X')
        and nvl(row.val_103,'X') = nvl(ben_ext_fmt.g_val_tab(103),'X')
        and nvl(row.val_104,'X') = nvl(ben_ext_fmt.g_val_tab(104),'X')
        and nvl(row.val_105,'X') = nvl(ben_ext_fmt.g_val_tab(105),'X')
        and nvl(row.val_106,'X') = nvl(ben_ext_fmt.g_val_tab(106),'X')
        and nvl(row.val_107,'X') = nvl(ben_ext_fmt.g_val_tab(107),'X')
        and nvl(row.val_108,'X') = nvl(ben_ext_fmt.g_val_tab(108),'X')
        and nvl(row.val_109,'X') = nvl(ben_ext_fmt.g_val_tab(109),'X')
        and nvl(row.val_110,'X') = nvl(ben_ext_fmt.g_val_tab(110),'X')
        and nvl(row.val_111,'X') = nvl(ben_ext_fmt.g_val_tab(111),'X')
        and nvl(row.val_112,'X') = nvl(ben_ext_fmt.g_val_tab(112),'X')
        and nvl(row.val_113,'X') = nvl(ben_ext_fmt.g_val_tab(113),'X')
        and nvl(row.val_114,'X') = nvl(ben_ext_fmt.g_val_tab(114),'X')
        and nvl(row.val_115,'X') = nvl(ben_ext_fmt.g_val_tab(115),'X')
        and nvl(row.val_116,'X') = nvl(ben_ext_fmt.g_val_tab(116),'X')
        and nvl(row.val_117,'X') = nvl(ben_ext_fmt.g_val_tab(117),'X')
        and nvl(row.val_118,'X') = nvl(ben_ext_fmt.g_val_tab(118),'X')
        and nvl(row.val_119,'X') = nvl(ben_ext_fmt.g_val_tab(119),'X')
        and nvl(row.val_120,'X') = nvl(ben_ext_fmt.g_val_tab(120),'X')
        and nvl(row.val_121,'X') = nvl(ben_ext_fmt.g_val_tab(121),'X')
        and nvl(row.val_122,'X') = nvl(ben_ext_fmt.g_val_tab(122),'X')
        and nvl(row.val_123,'X') = nvl(ben_ext_fmt.g_val_tab(123),'X')
        and nvl(row.val_124,'X') = nvl(ben_ext_fmt.g_val_tab(124),'X')
        and nvl(row.val_125,'X') = nvl(ben_ext_fmt.g_val_tab(125),'X')
        and nvl(row.val_126,'X') = nvl(ben_ext_fmt.g_val_tab(126),'X')
        and nvl(row.val_127,'X') = nvl(ben_ext_fmt.g_val_tab(127),'X')
        and nvl(row.val_128,'X') = nvl(ben_ext_fmt.g_val_tab(128),'X')
        and nvl(row.val_129,'X') = nvl(ben_ext_fmt.g_val_tab(129),'X')
        and nvl(row.val_130,'X') = nvl(ben_ext_fmt.g_val_tab(130),'X')
        and nvl(row.val_131,'X') = nvl(ben_ext_fmt.g_val_tab(131),'X')
        and nvl(row.val_132,'X') = nvl(ben_ext_fmt.g_val_tab(132),'X')
        and nvl(row.val_133,'X') = nvl(ben_ext_fmt.g_val_tab(133),'X')
        and nvl(row.val_134,'X') = nvl(ben_ext_fmt.g_val_tab(134),'X')
        and nvl(row.val_135,'X') = nvl(ben_ext_fmt.g_val_tab(135),'X')
        and nvl(row.val_136,'X') = nvl(ben_ext_fmt.g_val_tab(136),'X')
        and nvl(row.val_137,'X') = nvl(ben_ext_fmt.g_val_tab(137),'X')
        and nvl(row.val_138,'X') = nvl(ben_ext_fmt.g_val_tab(138),'X')
        and nvl(row.val_139,'X') = nvl(ben_ext_fmt.g_val_tab(139),'X')
        and nvl(row.val_140,'X') = nvl(ben_ext_fmt.g_val_tab(140),'X')
        and nvl(row.val_141,'X') = nvl(ben_ext_fmt.g_val_tab(141),'X')
        and nvl(row.val_142,'X') = nvl(ben_ext_fmt.g_val_tab(142),'X')
        and nvl(row.val_143,'X') = nvl(ben_ext_fmt.g_val_tab(143),'X')
        and nvl(row.val_144,'X') = nvl(ben_ext_fmt.g_val_tab(144),'X')
        and nvl(row.val_145,'X') = nvl(ben_ext_fmt.g_val_tab(145),'X')
        and nvl(row.val_146,'X') = nvl(ben_ext_fmt.g_val_tab(146),'X')
        and nvl(row.val_147,'X') = nvl(ben_ext_fmt.g_val_tab(147),'X')
        and nvl(row.val_148,'X') = nvl(ben_ext_fmt.g_val_tab(148),'X')
        and nvl(row.val_149,'X') = nvl(ben_ext_fmt.g_val_tab(149),'X')
        and nvl(row.val_150,'X') = nvl(ben_ext_fmt.g_val_tab(150),'X')
        and nvl(row.val_151,'X') = nvl(ben_ext_fmt.g_val_tab(151),'X')
        and nvl(row.val_152,'X') = nvl(ben_ext_fmt.g_val_tab(152),'X')
        and nvl(row.val_153,'X') = nvl(ben_ext_fmt.g_val_tab(153),'X')
        and nvl(row.val_154,'X') = nvl(ben_ext_fmt.g_val_tab(154),'X')
        and nvl(row.val_155,'X') = nvl(ben_ext_fmt.g_val_tab(155),'X')
        and nvl(row.val_156,'X') = nvl(ben_ext_fmt.g_val_tab(156),'X')
        and nvl(row.val_157,'X') = nvl(ben_ext_fmt.g_val_tab(157),'X')
        and nvl(row.val_158,'X') = nvl(ben_ext_fmt.g_val_tab(158),'X')
        and nvl(row.val_159,'X') = nvl(ben_ext_fmt.g_val_tab(159),'X')
        and nvl(row.val_160,'X') = nvl(ben_ext_fmt.g_val_tab(160),'X')
        and nvl(row.val_161,'X') = nvl(ben_ext_fmt.g_val_tab(161),'X')
        and nvl(row.val_162,'X') = nvl(ben_ext_fmt.g_val_tab(162),'X')
        and nvl(row.val_163,'X') = nvl(ben_ext_fmt.g_val_tab(163),'X')
        and nvl(row.val_164,'X') = nvl(ben_ext_fmt.g_val_tab(164),'X')
        and nvl(row.val_165,'X') = nvl(ben_ext_fmt.g_val_tab(165),'X')
        and nvl(row.val_166,'X') = nvl(ben_ext_fmt.g_val_tab(166),'X')
        and nvl(row.val_167,'X') = nvl(ben_ext_fmt.g_val_tab(167),'X')
        and nvl(row.val_168,'X') = nvl(ben_ext_fmt.g_val_tab(168),'X')
        and nvl(row.val_169,'X') = nvl(ben_ext_fmt.g_val_tab(169),'X')
        and nvl(row.val_170,'X') = nvl(ben_ext_fmt.g_val_tab(170),'X')
        and nvl(row.val_171,'X') = nvl(ben_ext_fmt.g_val_tab(171),'X')
        and nvl(row.val_172,'X') = nvl(ben_ext_fmt.g_val_tab(172),'X')
        and nvl(row.val_173,'X') = nvl(ben_ext_fmt.g_val_tab(173),'X')
        and nvl(row.val_174,'X') = nvl(ben_ext_fmt.g_val_tab(174),'X')
        and nvl(row.val_175,'X') = nvl(ben_ext_fmt.g_val_tab(175),'X')
        and nvl(row.val_176,'X') = nvl(ben_ext_fmt.g_val_tab(176),'X')
        and nvl(row.val_177,'X') = nvl(ben_ext_fmt.g_val_tab(177),'X')
        and nvl(row.val_178,'X') = nvl(ben_ext_fmt.g_val_tab(178),'X')
        and nvl(row.val_179,'X') = nvl(ben_ext_fmt.g_val_tab(179),'X')
        and nvl(row.val_180,'X') = nvl(ben_ext_fmt.g_val_tab(180),'X')
        and nvl(row.val_181,'X') = nvl(ben_ext_fmt.g_val_tab(181),'X')
        and nvl(row.val_182,'X') = nvl(ben_ext_fmt.g_val_tab(182),'X')
        and nvl(row.val_183,'X') = nvl(ben_ext_fmt.g_val_tab(183),'X')
        and nvl(row.val_184,'X') = nvl(ben_ext_fmt.g_val_tab(184),'X')
        and nvl(row.val_185,'X') = nvl(ben_ext_fmt.g_val_tab(185),'X')
        and nvl(row.val_186,'X') = nvl(ben_ext_fmt.g_val_tab(186),'X')
        and nvl(row.val_187,'X') = nvl(ben_ext_fmt.g_val_tab(187),'X')
        and nvl(row.val_188,'X') = nvl(ben_ext_fmt.g_val_tab(188),'X')
        and nvl(row.val_189,'X') = nvl(ben_ext_fmt.g_val_tab(189),'X')
        and nvl(row.val_190,'X') = nvl(ben_ext_fmt.g_val_tab(190),'X')
        and nvl(row.val_191,'X') = nvl(ben_ext_fmt.g_val_tab(191),'X')
        and nvl(row.val_192,'X') = nvl(ben_ext_fmt.g_val_tab(192),'X')
        and nvl(row.val_193,'X') = nvl(ben_ext_fmt.g_val_tab(193),'X')
        and nvl(row.val_194,'X') = nvl(ben_ext_fmt.g_val_tab(194),'X')
        and nvl(row.val_195,'X') = nvl(ben_ext_fmt.g_val_tab(195),'X')
        and nvl(row.val_196,'X') = nvl(ben_ext_fmt.g_val_tab(196),'X')
        and nvl(row.val_197,'X') = nvl(ben_ext_fmt.g_val_tab(197),'X')
        and nvl(row.val_198,'X') = nvl(ben_ext_fmt.g_val_tab(198),'X')
        and nvl(row.val_199,'X') = nvl(ben_ext_fmt.g_val_tab(199),'X')
        and nvl(row.val_200,'X') = nvl(ben_ext_fmt.g_val_tab(200),'X')
        and nvl(row.val_201,'X') = nvl(ben_ext_fmt.g_val_tab(201),'X')
        and nvl(row.val_202,'X') = nvl(ben_ext_fmt.g_val_tab(202),'X')
        and nvl(row.val_203,'X') = nvl(ben_ext_fmt.g_val_tab(203),'X')
        and nvl(row.val_204,'X') = nvl(ben_ext_fmt.g_val_tab(204),'X')
        and nvl(row.val_205,'X') = nvl(ben_ext_fmt.g_val_tab(205),'X')
        and nvl(row.val_206,'X') = nvl(ben_ext_fmt.g_val_tab(206),'X')
        and nvl(row.val_207,'X') = nvl(ben_ext_fmt.g_val_tab(207),'X')
        and nvl(row.val_208,'X') = nvl(ben_ext_fmt.g_val_tab(208),'X')
        and nvl(row.val_209,'X') = nvl(ben_ext_fmt.g_val_tab(209),'X')
        and nvl(row.val_210,'X') = nvl(ben_ext_fmt.g_val_tab(210),'X')
        and nvl(row.val_211,'X') = nvl(ben_ext_fmt.g_val_tab(211),'X')
        and nvl(row.val_212,'X') = nvl(ben_ext_fmt.g_val_tab(212),'X')
        and nvl(row.val_213,'X') = nvl(ben_ext_fmt.g_val_tab(213),'X')
        and nvl(row.val_214,'X') = nvl(ben_ext_fmt.g_val_tab(214),'X')
        and nvl(row.val_215,'X') = nvl(ben_ext_fmt.g_val_tab(215),'X')
        and nvl(row.val_216,'X') = nvl(ben_ext_fmt.g_val_tab(216),'X')
        and nvl(row.val_217,'X') = nvl(ben_ext_fmt.g_val_tab(217),'X')
        and nvl(row.val_218,'X') = nvl(ben_ext_fmt.g_val_tab(218),'X')
        and nvl(row.val_219,'X') = nvl(ben_ext_fmt.g_val_tab(219),'X')
        and nvl(row.val_220,'X') = nvl(ben_ext_fmt.g_val_tab(220),'X')
        and nvl(row.val_221,'X') = nvl(ben_ext_fmt.g_val_tab(221),'X')
        and nvl(row.val_222,'X') = nvl(ben_ext_fmt.g_val_tab(222),'X')
        and nvl(row.val_223,'X') = nvl(ben_ext_fmt.g_val_tab(223),'X')
        and nvl(row.val_224,'X') = nvl(ben_ext_fmt.g_val_tab(224),'X')
        and nvl(row.val_225,'X') = nvl(ben_ext_fmt.g_val_tab(225),'X')
        and nvl(row.val_226,'X') = nvl(ben_ext_fmt.g_val_tab(226),'X')
        and nvl(row.val_227,'X') = nvl(ben_ext_fmt.g_val_tab(227),'X')
        and nvl(row.val_228,'X') = nvl(ben_ext_fmt.g_val_tab(228),'X')
        and nvl(row.val_229,'X') = nvl(ben_ext_fmt.g_val_tab(229),'X')
        and nvl(row.val_230,'X') = nvl(ben_ext_fmt.g_val_tab(230),'X')
        and nvl(row.val_231,'X') = nvl(ben_ext_fmt.g_val_tab(231),'X')
        and nvl(row.val_232,'X') = nvl(ben_ext_fmt.g_val_tab(232),'X')
        and nvl(row.val_233,'X') = nvl(ben_ext_fmt.g_val_tab(233),'X')
        and nvl(row.val_234,'X') = nvl(ben_ext_fmt.g_val_tab(234),'X')
        and nvl(row.val_235,'X') = nvl(ben_ext_fmt.g_val_tab(235),'X')
        and nvl(row.val_236,'X') = nvl(ben_ext_fmt.g_val_tab(236),'X')
        and nvl(row.val_237,'X') = nvl(ben_ext_fmt.g_val_tab(237),'X')
        and nvl(row.val_238,'X') = nvl(ben_ext_fmt.g_val_tab(238),'X')
        and nvl(row.val_239,'X') = nvl(ben_ext_fmt.g_val_tab(239),'X')
        and nvl(row.val_240,'X') = nvl(ben_ext_fmt.g_val_tab(240),'X')
        and nvl(row.val_241,'X') = nvl(ben_ext_fmt.g_val_tab(241),'X')
        and nvl(row.val_242,'X') = nvl(ben_ext_fmt.g_val_tab(242),'X')
        and nvl(row.val_243,'X') = nvl(ben_ext_fmt.g_val_tab(243),'X')
        and nvl(row.val_244,'X') = nvl(ben_ext_fmt.g_val_tab(244),'X')
        and nvl(row.val_245,'X') = nvl(ben_ext_fmt.g_val_tab(245),'X')
        and nvl(row.val_246,'X') = nvl(ben_ext_fmt.g_val_tab(246),'X')
        and nvl(row.val_247,'X') = nvl(ben_ext_fmt.g_val_tab(247),'X')
        and nvl(row.val_248,'X') = nvl(ben_ext_fmt.g_val_tab(248),'X')
        and nvl(row.val_249,'X') = nvl(ben_ext_fmt.g_val_tab(249),'X')
        and nvl(row.val_250,'X') = nvl(ben_ext_fmt.g_val_tab(250),'X')
        and nvl(row.val_251,'X') = nvl(ben_ext_fmt.g_val_tab(251),'X')
        and nvl(row.val_252,'X') = nvl(ben_ext_fmt.g_val_tab(252),'X')
        and nvl(row.val_253,'X') = nvl(ben_ext_fmt.g_val_tab(253),'X')
        and nvl(row.val_254,'X') = nvl(ben_ext_fmt.g_val_tab(254),'X')
        and nvl(row.val_255,'X') = nvl(ben_ext_fmt.g_val_tab(255),'X')
        and nvl(row.val_256,'X') = nvl(ben_ext_fmt.g_val_tab(256),'X')
        and nvl(row.val_257,'X') = nvl(ben_ext_fmt.g_val_tab(257),'X')
        and nvl(row.val_258,'X') = nvl(ben_ext_fmt.g_val_tab(258),'X')
        and nvl(row.val_259,'X') = nvl(ben_ext_fmt.g_val_tab(259),'X')
        and nvl(row.val_260,'X') = nvl(ben_ext_fmt.g_val_tab(260),'X')
        and nvl(row.val_261,'X') = nvl(ben_ext_fmt.g_val_tab(261),'X')
        and nvl(row.val_262,'X') = nvl(ben_ext_fmt.g_val_tab(262),'X')
        and nvl(row.val_263,'X') = nvl(ben_ext_fmt.g_val_tab(263),'X')
        and nvl(row.val_264,'X') = nvl(ben_ext_fmt.g_val_tab(264),'X')
        and nvl(row.val_265,'X') = nvl(ben_ext_fmt.g_val_tab(265),'X')
        and nvl(row.val_266,'X') = nvl(ben_ext_fmt.g_val_tab(266),'X')
        and nvl(row.val_267,'X') = nvl(ben_ext_fmt.g_val_tab(267),'X')
        and nvl(row.val_268,'X') = nvl(ben_ext_fmt.g_val_tab(268),'X')
        and nvl(row.val_269,'X') = nvl(ben_ext_fmt.g_val_tab(269),'X')
        and nvl(row.val_270,'X') = nvl(ben_ext_fmt.g_val_tab(270),'X')
        and nvl(row.val_271,'X') = nvl(ben_ext_fmt.g_val_tab(271),'X')
        and nvl(row.val_272,'X') = nvl(ben_ext_fmt.g_val_tab(272),'X')
        and nvl(row.val_273,'X') = nvl(ben_ext_fmt.g_val_tab(273),'X')
        and nvl(row.val_274,'X') = nvl(ben_ext_fmt.g_val_tab(274),'X')
        and nvl(row.val_275,'X') = nvl(ben_ext_fmt.g_val_tab(275),'X')
        and nvl(row.val_276,'X') = nvl(ben_ext_fmt.g_val_tab(276),'X')
        and nvl(row.val_277,'X') = nvl(ben_ext_fmt.g_val_tab(277),'X')
        and nvl(row.val_278,'X') = nvl(ben_ext_fmt.g_val_tab(278),'X')
        and nvl(row.val_279,'X') = nvl(ben_ext_fmt.g_val_tab(279),'X')
        and nvl(row.val_280,'X') = nvl(ben_ext_fmt.g_val_tab(280),'X')
        and nvl(row.val_281,'X') = nvl(ben_ext_fmt.g_val_tab(281),'X')
        and nvl(row.val_282,'X') = nvl(ben_ext_fmt.g_val_tab(282),'X')
        and nvl(row.val_283,'X') = nvl(ben_ext_fmt.g_val_tab(283),'X')
        and nvl(row.val_284,'X') = nvl(ben_ext_fmt.g_val_tab(284),'X')
        and nvl(row.val_285,'X') = nvl(ben_ext_fmt.g_val_tab(285),'X')
        and nvl(row.val_286,'X') = nvl(ben_ext_fmt.g_val_tab(286),'X')
        and nvl(row.val_287,'X') = nvl(ben_ext_fmt.g_val_tab(287),'X')
        and nvl(row.val_288,'X') = nvl(ben_ext_fmt.g_val_tab(288),'X')
        and nvl(row.val_289,'X') = nvl(ben_ext_fmt.g_val_tab(289),'X')
        and nvl(row.val_290,'X') = nvl(ben_ext_fmt.g_val_tab(290),'X')
        and nvl(row.val_291,'X') = nvl(ben_ext_fmt.g_val_tab(291),'X')
        and nvl(row.val_292,'X') = nvl(ben_ext_fmt.g_val_tab(292),'X')
        and nvl(row.val_293,'X') = nvl(ben_ext_fmt.g_val_tab(293),'X')
        and nvl(row.val_294,'X') = nvl(ben_ext_fmt.g_val_tab(294),'X')
        and nvl(row.val_295,'X') = nvl(ben_ext_fmt.g_val_tab(295),'X')
        and nvl(row.val_296,'X') = nvl(ben_ext_fmt.g_val_tab(296),'X')
        and nvl(row.val_297,'X') = nvl(ben_ext_fmt.g_val_tab(297),'X')
        and nvl(row.val_298,'X') = nvl(ben_ext_fmt.g_val_tab(298),'X')
        and nvl(row.val_299,'X') = nvl(ben_ext_fmt.g_val_tab(299),'X')
        and nvl(row.val_300,'X') = nvl(ben_ext_fmt.g_val_tab(300),'X')
      then
         p_exclude_this_rcd_flag := true;
         exit ;
      end if ;

   End Loop ;

  /*
  open c_check_for_dup_rcds;
  fetch c_check_for_dup_rcds into l_dummy;
  if c_check_for_dup_rcds%found then
    p_exclude_this_rcd_flag := true;
  end if;
  close c_check_for_dup_rcds;
  */

end if;
--
hr_utility.set_location('Exiting'||l_proc, 15);
--
end prevent_duplicates;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chg_evt_incl >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chg_evt_incl
         (p_ext_rcd_in_file_id      in number default null,
          p_rcd_seq_num             in number default null,
          p_ext_data_elmt_in_rcd_id in number default null,
          p_data_elmt_seq_num       in number default null,
          p_chg_evt_cd              in varchar2,
          p_exclude_flag   out nocopy boolean) is
--
l_proc     varchar2(72) := g_package||'chg_evt_incl';
--
cursor c_rcd_chg_evt_exist is
  select null
    from ben_ext_incl_chg xic
    where xic.ext_rcd_in_file_id = p_ext_rcd_in_file_id;
--
cursor c_data_elmt_chg_evt_exist is
  select null
    from ben_ext_incl_chg xic
    where xic.ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id;
--
cursor c_incl_rcd is
  select null
    from ben_ext_incl_chg xic
    where xic.ext_rcd_in_file_id = p_ext_rcd_in_file_id
     and xic.chg_evt_cd = p_chg_evt_cd;
--
cursor c_incl_data_elmt is
  select null
    from ben_ext_incl_chg xic
    where xic.ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id
     and xic.chg_evt_cd = p_chg_evt_cd;
--
l_exclude_flag boolean;
l_dummy varchar2(1);
--
begin
--
hr_utility.set_location('Entering'||l_proc, 5);
--
l_exclude_flag := false;
--

hr_utility.set_location('p_ext_rcd_in_file_id'||p_ext_rcd_in_file_id, 5);
hr_utility.set_location('p_rcd_seq_nu'||p_rcd_seq_num, 5);
if p_ext_rcd_in_file_id is not null then
  --
  -- for each record load a 'Y' or 'N' into table indicating that
  -- that there is or is not change events for this record.
  -- This is done only once per record.
  --
  if g_rcd_list.exists(p_rcd_seq_num)    then
    --
     hr_utility.set_location('p_ext_rcd_in_file_id found ', 5);
    null;
  else
    --
    open c_rcd_chg_evt_exist;
    fetch c_rcd_chg_evt_exist into l_dummy;
    if c_rcd_chg_evt_exist%found then
       g_rcd_list(p_rcd_seq_num) := 'Y';

    else
       g_rcd_list(p_rcd_seq_num) := 'N';
    end if;
    close c_rcd_chg_evt_exist;
  end if;
  --
  -- No (N) change events defined for the record is an automatic
  -- include.
  --
  if g_rcd_list(p_rcd_seq_num) = 'Y' then
    --
    open c_incl_rcd;
    fetch c_incl_rcd into l_dummy;
    if c_incl_rcd%notfound then
       l_exclude_flag := true;
    end if;
    close c_incl_rcd;
    --
  end if;
    --
end if;
--
hr_utility.set_location('p_ext_data_elmt_in_rcd_id'||p_ext_data_elmt_in_rcd_id, 15);
hr_utility.set_location('p_data_elmt_seq_num'||p_data_elmt_seq_num, 15);

if p_ext_data_elmt_in_rcd_id is not null then
  --
  if  g_data_elmt_list.exists(p_data_elmt_seq_num) and
      g_data_elmt_list_id(p_data_elmt_seq_num) = p_ext_data_elmt_in_rcd_id  then
    --
    hr_utility.set_location('p_ext_data_elmt_in_rcd_id found', 15);
    null;
  else
    open c_data_elmt_chg_evt_exist;
    fetch c_data_elmt_chg_evt_exist into l_dummy;
    if c_data_elmt_chg_evt_exist%found then
       g_data_elmt_list(p_data_elmt_seq_num) := 'Y';
    else
       g_data_elmt_list(p_data_elmt_seq_num) := 'N';
    end if;
     g_data_elmt_list_id(p_data_elmt_seq_num) := p_ext_data_elmt_in_rcd_id ;
    close c_data_elmt_chg_evt_exist;
  end if;
  --
  if g_data_elmt_list(p_data_elmt_seq_num) = 'Y' then
    --
    open c_incl_data_elmt;
    fetch c_incl_data_elmt into l_dummy;
    if c_incl_data_elmt%notfound then
       l_exclude_flag := true;
    end if;
    close c_incl_data_elmt;
    --
  end if;
    --
end if;
--
p_exclude_flag := l_exclude_flag;

-- to be removed
hr_utility.set_location('Exiting'||l_proc, 15);
--
end chg_evt_incl;
--


procedure chg_rcd_merge (
   p_ext_rslt_id                    in  number    default null
  ,p_ext_rcd_id                     in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_val_01                         in out nocopy  varchar2
  ,p_val_02                         in out nocopy  varchar2
  ,p_val_03                         in out nocopy  varchar2
  ,p_val_04                         in out nocopy  varchar2
  ,p_val_05                         in out nocopy  varchar2
  ,p_val_06                         in out nocopy  varchar2
  ,p_val_07                         in out nocopy  varchar2
  ,p_val_08                         in out nocopy  varchar2
  ,p_val_09                         in out nocopy  varchar2
  ,p_val_10                         in out nocopy  varchar2
  ,p_val_11                         in out nocopy  varchar2
  ,p_val_12                         in out nocopy  varchar2
  ,p_val_13                         in out nocopy  varchar2
  ,p_val_14                         in out nocopy  varchar2
  ,p_val_15                         in out nocopy  varchar2
  ,p_val_16                         in out nocopy  varchar2
  ,p_val_17                         in out nocopy  varchar2
  ,p_val_19                         in out nocopy  varchar2
  ,p_val_18                         in out nocopy  varchar2
  ,p_val_20                         in out nocopy  varchar2
  ,p_val_21                         in out nocopy  varchar2
  ,p_val_22                         in out nocopy  varchar2
  ,p_val_23                         in out nocopy  varchar2
  ,p_val_24                         in out nocopy  varchar2
  ,p_val_25                         in out nocopy  varchar2
  ,p_val_26                         in out nocopy  varchar2
  ,p_val_27                         in out nocopy  varchar2
  ,p_val_28                         in out nocopy  varchar2
  ,p_val_29                         in out nocopy  varchar2
  ,p_val_30                         in out nocopy  varchar2
  ,p_val_31                         in out nocopy  varchar2
  ,p_val_32                         in out nocopy  varchar2
  ,p_val_33                         in out nocopy  varchar2
  ,p_val_34                         in out nocopy  varchar2
  ,p_val_35                         in out nocopy  varchar2
  ,p_val_36                         in out nocopy  varchar2
  ,p_val_37                         in out nocopy  varchar2
  ,p_val_38                         in out nocopy  varchar2
  ,p_val_39                         in out nocopy  varchar2
  ,p_val_40                         in out nocopy  varchar2
  ,p_val_41                         in out nocopy  varchar2
  ,p_val_42                         in out nocopy  varchar2
  ,p_val_43                         in out nocopy  varchar2
  ,p_val_44                         in out nocopy  varchar2
  ,p_val_45                         in out nocopy  varchar2
  ,p_val_46                         in out nocopy  varchar2
  ,p_val_47                         in out nocopy  varchar2
  ,p_val_48                         in out nocopy  varchar2
  ,p_val_49                         in out nocopy  varchar2
  ,p_val_50                         in out nocopy  varchar2
  ,p_val_51                         in out nocopy  varchar2
  ,p_val_52                         in out nocopy  varchar2
  ,p_val_53                         in out nocopy  varchar2
  ,p_val_54                         in out nocopy  varchar2
  ,p_val_55                         in out nocopy  varchar2
  ,p_val_56                         in out nocopy  varchar2
  ,p_val_57                         in out nocopy  varchar2
  ,p_val_58                         in out nocopy  varchar2
  ,p_val_59                         in out nocopy  varchar2
  ,p_val_60                         in out nocopy  varchar2
  ,p_val_61                         in out nocopy  varchar2
  ,p_val_62                         in out nocopy  varchar2
  ,p_val_63                         in out nocopy  varchar2
  ,p_val_64                         in out nocopy  varchar2
  ,p_val_65                         in out nocopy  varchar2
  ,p_val_66                         in out nocopy  varchar2
  ,p_val_67                         in out nocopy  varchar2
  ,p_val_68                         in out nocopy  varchar2
  ,p_val_69                         in out nocopy  varchar2
  ,p_val_70                         in out nocopy  varchar2
  ,p_val_71                         in out nocopy  varchar2
  ,p_val_72                         in out nocopy  varchar2
  ,p_val_73                         in out nocopy  varchar2
  ,p_val_74                         in out nocopy  varchar2
  ,p_val_75                         in out nocopy  varchar2
  ,p_val_76                         in out nocopy  varchar2
  ,p_val_77                         in out nocopy  varchar2
  ,p_val_78                         in out nocopy  varchar2
  ,p_val_79                         in out nocopy  varchar2
  ,p_val_80                         in out nocopy  varchar2
  ,p_val_81                         in out nocopy  varchar2
  ,p_val_82                         in out nocopy  varchar2
  ,p_val_83                         in out nocopy  varchar2
  ,p_val_84                         in out nocopy  varchar2
  ,p_val_85                         in out nocopy  varchar2
  ,p_val_86                         in out nocopy  varchar2
  ,p_val_87                         in out nocopy  varchar2
  ,p_val_88                         in out nocopy  varchar2
  ,p_val_89                         in out nocopy  varchar2
  ,p_val_90                         in out nocopy  varchar2
  ,p_val_91                         in out nocopy  varchar2
  ,p_val_92                         in out nocopy  varchar2
  ,p_val_93                         in out nocopy  varchar2
  ,p_val_94                         in out nocopy  varchar2
  ,p_val_95                         in out nocopy  varchar2
  ,p_val_96                         in out nocopy  varchar2
  ,p_val_97                         in out nocopy  varchar2
  ,p_val_98                         in out nocopy  varchar2
  ,p_val_99                         in out nocopy  varchar2
  ,p_val_100                        in out nocopy  varchar2
  ,p_val_101                         in out nocopy  varchar2
  ,p_val_102                         in out nocopy  varchar2
  ,p_val_103                         in out nocopy  varchar2
  ,p_val_104                         in out nocopy  varchar2
  ,p_val_105                         in out nocopy  varchar2
  ,p_val_106                         in out nocopy  varchar2
  ,p_val_107                         in out nocopy  varchar2
  ,p_val_108                         in out nocopy  varchar2
  ,p_val_109                         in out nocopy  varchar2
  ,p_val_110                         in out nocopy  varchar2
  ,p_val_111                         in out nocopy  varchar2
  ,p_val_112                         in out nocopy  varchar2
  ,p_val_113                         in out nocopy  varchar2
  ,p_val_114                         in out nocopy  varchar2
  ,p_val_115                         in out nocopy  varchar2
  ,p_val_116                         in out nocopy  varchar2
  ,p_val_117                         in out nocopy  varchar2
  ,p_val_119                         in out nocopy  varchar2
  ,p_val_118                         in out nocopy  varchar2
  ,p_val_120                         in out nocopy  varchar2
  ,p_val_121                         in out nocopy  varchar2
  ,p_val_122                         in out nocopy  varchar2
  ,p_val_123                         in out nocopy  varchar2
  ,p_val_124                         in out nocopy  varchar2
  ,p_val_125                         in out nocopy  varchar2
  ,p_val_126                         in out nocopy  varchar2
  ,p_val_127                         in out nocopy  varchar2
  ,p_val_128                         in out nocopy  varchar2
  ,p_val_129                         in out nocopy  varchar2
  ,p_val_130                         in out nocopy  varchar2
  ,p_val_131                         in out nocopy  varchar2
  ,p_val_132                         in out nocopy  varchar2
  ,p_val_133                         in out nocopy  varchar2
  ,p_val_134                         in out nocopy  varchar2
  ,p_val_135                         in out nocopy  varchar2
  ,p_val_136                         in out nocopy  varchar2
  ,p_val_137                         in out nocopy  varchar2
  ,p_val_138                         in out nocopy  varchar2
  ,p_val_139                         in out nocopy  varchar2
  ,p_val_140                         in out nocopy  varchar2
  ,p_val_141                         in out nocopy  varchar2
  ,p_val_142                         in out nocopy  varchar2
  ,p_val_143                         in out nocopy  varchar2
  ,p_val_144                         in out nocopy  varchar2
  ,p_val_145                         in out nocopy  varchar2
  ,p_val_146                         in out nocopy  varchar2
  ,p_val_147                         in out nocopy  varchar2
  ,p_val_148                         in out nocopy  varchar2
  ,p_val_149                         in out nocopy  varchar2
  ,p_val_150                         in out nocopy  varchar2
  ,p_val_151                         in out nocopy  varchar2
  ,p_val_152                         in out nocopy  varchar2
  ,p_val_153                         in out nocopy  varchar2
  ,p_val_154                         in out nocopy  varchar2
  ,p_val_155                         in out nocopy  varchar2
  ,p_val_156                         in out nocopy  varchar2
  ,p_val_157                         in out nocopy  varchar2
  ,p_val_158                         in out nocopy  varchar2
  ,p_val_159                         in out nocopy  varchar2
  ,p_val_160                         in out nocopy  varchar2
  ,p_val_161                         in out nocopy  varchar2
  ,p_val_162                         in out nocopy  varchar2
  ,p_val_163                         in out nocopy  varchar2
  ,p_val_164                         in out nocopy  varchar2
  ,p_val_165                         in out nocopy  varchar2
  ,p_val_166                         in out nocopy  varchar2
  ,p_val_167                         in out nocopy  varchar2
  ,p_val_168                         in out nocopy  varchar2
  ,p_val_169                         in out nocopy  varchar2
  ,p_val_170                         in out nocopy  varchar2
  ,p_val_171                         in out nocopy  varchar2
  ,p_val_172                         in out nocopy  varchar2
  ,p_val_173                         in out nocopy  varchar2
  ,p_val_174                         in out nocopy  varchar2
  ,p_val_175                         in out nocopy  varchar2
  ,p_val_176                         in out nocopy  varchar2
  ,p_val_177                         in out nocopy  varchar2
  ,p_val_178                         in out nocopy  varchar2
  ,p_val_179                         in out nocopy  varchar2
  ,p_val_180                         in out nocopy  varchar2
  ,p_val_181                         in out nocopy  varchar2
  ,p_val_182                         in out nocopy  varchar2
  ,p_val_183                         in out nocopy  varchar2
  ,p_val_184                         in out nocopy  varchar2
  ,p_val_185                         in out nocopy  varchar2
  ,p_val_186                         in out nocopy  varchar2
  ,p_val_187                         in out nocopy  varchar2
  ,p_val_188                         in out nocopy  varchar2
  ,p_val_189                         in out nocopy  varchar2
  ,p_val_190                         in out nocopy  varchar2
  ,p_val_191                         in out nocopy  varchar2
  ,p_val_192                         in out nocopy  varchar2
  ,p_val_193                         in out nocopy  varchar2
  ,p_val_194                         in out nocopy  varchar2
  ,p_val_195                         in out nocopy  varchar2
  ,p_val_196                         in out nocopy  varchar2
  ,p_val_197                         in out nocopy  varchar2
  ,p_val_198                         in out nocopy  varchar2
  ,p_val_199                         in out nocopy  varchar2
  ,p_val_200                         in out nocopy  varchar2
  ,p_val_201                         in out nocopy  varchar2
  ,p_val_202                         in out nocopy  varchar2
  ,p_val_203                         in out nocopy  varchar2
  ,p_val_204                         in out nocopy  varchar2
  ,p_val_205                         in out nocopy  varchar2
  ,p_val_206                         in out nocopy  varchar2
  ,p_val_207                         in out nocopy  varchar2
  ,p_val_208                         in out nocopy  varchar2
  ,p_val_209                         in out nocopy  varchar2
  ,p_val_210                         in out nocopy  varchar2
  ,p_val_211                         in out nocopy  varchar2
  ,p_val_212                         in out nocopy  varchar2
  ,p_val_213                         in out nocopy  varchar2
  ,p_val_214                         in out nocopy  varchar2
  ,p_val_215                         in out nocopy  varchar2
  ,p_val_216                         in out nocopy  varchar2
  ,p_val_217                         in out nocopy  varchar2
  ,p_val_219                         in out nocopy  varchar2
  ,p_val_218                         in out nocopy  varchar2
  ,p_val_220                         in out nocopy  varchar2
  ,p_val_221                         in out nocopy  varchar2
  ,p_val_222                         in out nocopy  varchar2
  ,p_val_223                         in out nocopy  varchar2
  ,p_val_224                         in out nocopy  varchar2
  ,p_val_225                         in out nocopy  varchar2
  ,p_val_226                         in out nocopy  varchar2
  ,p_val_227                         in out nocopy  varchar2
  ,p_val_228                         in out nocopy  varchar2
  ,p_val_229                         in out nocopy  varchar2
  ,p_val_230                         in out nocopy  varchar2
  ,p_val_231                         in out nocopy  varchar2
  ,p_val_232                         in out nocopy  varchar2
  ,p_val_233                         in out nocopy  varchar2
  ,p_val_234                         in out nocopy  varchar2
  ,p_val_235                         in out nocopy  varchar2
  ,p_val_236                         in out nocopy  varchar2
  ,p_val_237                         in out nocopy  varchar2
  ,p_val_238                         in out nocopy  varchar2
  ,p_val_239                         in out nocopy  varchar2
  ,p_val_240                         in out nocopy  varchar2
  ,p_val_241                         in out nocopy  varchar2
  ,p_val_242                         in out nocopy  varchar2
  ,p_val_243                         in out nocopy  varchar2
  ,p_val_244                         in out nocopy  varchar2
  ,p_val_245                         in out nocopy  varchar2
  ,p_val_246                         in out nocopy  varchar2
  ,p_val_247                         in out nocopy  varchar2
  ,p_val_248                         in out nocopy  varchar2
  ,p_val_249                         in out nocopy  varchar2
  ,p_val_250                         in out nocopy  varchar2
  ,p_val_251                         in out nocopy  varchar2
  ,p_val_252                         in out nocopy  varchar2
  ,p_val_253                         in out nocopy  varchar2
  ,p_val_254                         in out nocopy  varchar2
  ,p_val_255                         in out nocopy  varchar2
  ,p_val_256                         in out nocopy  varchar2
  ,p_val_257                         in out nocopy  varchar2
  ,p_val_258                         in out nocopy  varchar2
  ,p_val_259                         in out nocopy  varchar2
  ,p_val_260                         in out nocopy  varchar2
  ,p_val_261                         in out nocopy  varchar2
  ,p_val_262                         in out nocopy  varchar2
  ,p_val_263                         in out nocopy  varchar2
  ,p_val_264                         in out nocopy  varchar2
  ,p_val_265                         in out nocopy  varchar2
  ,p_val_266                         in out nocopy  varchar2
  ,p_val_267                         in out nocopy  varchar2
  ,p_val_268                         in out nocopy  varchar2
  ,p_val_269                         in out nocopy  varchar2
  ,p_val_270                         in out nocopy  varchar2
  ,p_val_271                         in out nocopy  varchar2
  ,p_val_272                         in out nocopy  varchar2
  ,p_val_273                         in out nocopy  varchar2
  ,p_val_274                         in out nocopy  varchar2
  ,p_val_275                         in out nocopy  varchar2
  ,p_val_276                         in out nocopy  varchar2
  ,p_val_277                         in out nocopy  varchar2
  ,p_val_278                         in out nocopy  varchar2
  ,p_val_279                         in out nocopy  varchar2
  ,p_val_280                         in out nocopy  varchar2
  ,p_val_281                         in out nocopy  varchar2
  ,p_val_282                         in out nocopy  varchar2
  ,p_val_283                         in out nocopy  varchar2
  ,p_val_284                         in out nocopy  varchar2
  ,p_val_285                         in out nocopy  varchar2
  ,p_val_286                         in out nocopy  varchar2
  ,p_val_287                         in out nocopy  varchar2
  ,p_val_288                         in out nocopy  varchar2
  ,p_val_289                         in out nocopy  varchar2
  ,p_val_290                         in out nocopy  varchar2
  ,p_val_291                         in out nocopy  varchar2
  ,p_val_292                         in out nocopy  varchar2
  ,p_val_293                         in out nocopy  varchar2
  ,p_val_294                         in out nocopy  varchar2
  ,p_val_295                         in out nocopy  varchar2
  ,p_val_296                         in out nocopy  varchar2
  ,p_val_297                         in out nocopy  varchar2
  ,p_val_298                         in out nocopy  varchar2
  ,p_val_299                         in out nocopy  varchar2
  ,p_val_300                         in out nocopy  varchar2
  ,p_ext_rcd_in_file_id             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_ext_rslt_dtl_id                out nocopy number
  ,p_ext_chg_rcd_mode               out nocopy varchar2
 ) is



  cursor c_ext_rslt_dtls is
  select *   from
  ben_ext_rslt_dtl
  where ext_rslt_id        = p_ext_rslt_id
    and (person_id         = p_person_id or p_person_id is null )  -- for subgroup
    and ext_rcd_id         = p_ext_rcd_id
    and ext_rcd_in_file_id = p_ext_rcd_in_file_id
    ;

 l_proc varchar2(70) ;
 l_ext_rslt  c_ext_rslt_dtls%rowtype ;
begin

 l_proc :=  g_package|| '.chg_rcd_merge' ;
 hr_utility.set_location('Entering'||l_proc, 5);

 p_ext_chg_rcd_mode := 'C'  ;
 open  c_ext_rslt_dtls ;
 fetch c_ext_rslt_dtls into  l_ext_rslt ;
 if c_ext_rslt_dtls%notfound  then
    close c_ext_rslt_dtls ;
    hr_utility.set_location('Mode '||p_ext_chg_rcd_mode, 15);
    hr_utility.set_location('Exiting'||l_proc, 15);
    Return  ;
 end if ;
 close c_ext_rslt_dtls ;

 p_ext_chg_rcd_mode := 'U' ;
 p_object_version_number := l_ext_rslt.object_version_number ;
 p_ext_rslt_dtl_id       := l_ext_rslt.ext_rslt_dtl_id       ;

  -- if the parameter valu is null get the table valu
  p_val_01   :=  nvl(p_val_01 ,l_ext_rslt.val_01  ) ;
  p_val_02   :=  nvl(p_val_02 ,l_ext_rslt.val_02  ) ;
  p_val_03   :=  nvl(p_val_03 ,l_ext_rslt.val_03  ) ;
  p_val_04   :=  nvl(p_val_04 ,l_ext_rslt.val_04  ) ;
  p_val_05   :=  nvl(p_val_05 ,l_ext_rslt.val_05  ) ;
  p_val_06   :=  nvl(p_val_06 ,l_ext_rslt.val_06  ) ;
  p_val_07   :=  nvl(p_val_07 ,l_ext_rslt.val_07  ) ;
  p_val_08   :=  nvl(p_val_08 ,l_ext_rslt.val_08  ) ;
  p_val_09   :=  nvl(p_val_09 ,l_ext_rslt.val_09  ) ;
  p_val_10   :=  nvl(p_val_10 ,l_ext_rslt.val_10  ) ;
  p_val_11   :=  nvl(p_val_11 ,l_ext_rslt.val_11  ) ;
  p_val_12   :=  nvl(p_val_12 ,l_ext_rslt.val_12  ) ;
  p_val_13   :=  nvl(p_val_13 ,l_ext_rslt.val_13  ) ;
  p_val_14   :=  nvl(p_val_14 ,l_ext_rslt.val_14  ) ;
  p_val_15   :=  nvl(p_val_15 ,l_ext_rslt.val_15  ) ;
  p_val_16   :=  nvl(p_val_16 ,l_ext_rslt.val_16  ) ;
  p_val_17   :=  nvl(p_val_17 ,l_ext_rslt.val_17  ) ;
  p_val_19   :=  nvl(p_val_19 ,l_ext_rslt.val_19  ) ;
  p_val_18   :=  nvl(p_val_18 ,l_ext_rslt.val_18  ) ;
  p_val_20   :=  nvl(p_val_20 ,l_ext_rslt.val_20  ) ;
  p_val_21   :=  nvl(p_val_21 ,l_ext_rslt.val_21  ) ;
  p_val_22   :=  nvl(p_val_22 ,l_ext_rslt.val_22  ) ;
  p_val_23   :=  nvl(p_val_23 ,l_ext_rslt.val_23  ) ;
  p_val_24   :=  nvl(p_val_24 ,l_ext_rslt.val_24  ) ;
  p_val_25   :=  nvl(p_val_25 ,l_ext_rslt.val_25  ) ;
  p_val_26   :=  nvl(p_val_26 ,l_ext_rslt.val_26  ) ;
  p_val_27   :=  nvl(p_val_27 ,l_ext_rslt.val_27  ) ;
  p_val_28   :=  nvl(p_val_28 ,l_ext_rslt.val_28  ) ;
  p_val_29   :=  nvl(p_val_29 ,l_ext_rslt.val_29  ) ;
  p_val_30   :=  nvl(p_val_30 ,l_ext_rslt.val_30  ) ;
  p_val_31   :=  nvl(p_val_31 ,l_ext_rslt.val_31  ) ;
  p_val_32   :=  nvl(p_val_32 ,l_ext_rslt.val_32  ) ;
  p_val_33   :=  nvl(p_val_33 ,l_ext_rslt.val_33  ) ;
  p_val_34   :=  nvl(p_val_34 ,l_ext_rslt.val_34  ) ;
  p_val_35   :=  nvl(p_val_35 ,l_ext_rslt.val_35  ) ;
  p_val_36   :=  nvl(p_val_36 ,l_ext_rslt.val_36  ) ;
  p_val_37   :=  nvl(p_val_37 ,l_ext_rslt.val_37  ) ;
  p_val_38   :=  nvl(p_val_38 ,l_ext_rslt.val_38  ) ;
  p_val_39   :=  nvl(p_val_39 ,l_ext_rslt.val_39  ) ;
  p_val_40   :=  nvl(p_val_40 ,l_ext_rslt.val_40  ) ;
  p_val_41   :=  nvl(p_val_41 ,l_ext_rslt.val_41  ) ;
  p_val_42   :=  nvl(p_val_42 ,l_ext_rslt.val_42  ) ;
  p_val_43   :=  nvl(p_val_43 ,l_ext_rslt.val_43  ) ;
  p_val_44   :=  nvl(p_val_44 ,l_ext_rslt.val_44  ) ;
  p_val_45   :=  nvl(p_val_45 ,l_ext_rslt.val_45  ) ;
  p_val_46   :=  nvl(p_val_46 ,l_ext_rslt.val_46  ) ;
  p_val_47   :=  nvl(p_val_47 ,l_ext_rslt.val_47  ) ;
  p_val_48   :=  nvl(p_val_48 ,l_ext_rslt.val_48  ) ;
  p_val_49   :=  nvl(p_val_49 ,l_ext_rslt.val_49  ) ;
  p_val_50   :=  nvl(p_val_50 ,l_ext_rslt.val_50  ) ;
  p_val_51   :=  nvl(p_val_51 ,l_ext_rslt.val_51  ) ;
  p_val_52   :=  nvl(p_val_52 ,l_ext_rslt.val_52  ) ;
  p_val_53   :=  nvl(p_val_53 ,l_ext_rslt.val_53  ) ;
  p_val_54   :=  nvl(p_val_54 ,l_ext_rslt.val_54  ) ;
  p_val_55   :=  nvl(p_val_55 ,l_ext_rslt.val_55  ) ;
  p_val_56   :=  nvl(p_val_56 ,l_ext_rslt.val_56  ) ;
  p_val_57   :=  nvl(p_val_57 ,l_ext_rslt.val_57  ) ;
  p_val_58   :=  nvl(p_val_58 ,l_ext_rslt.val_58  ) ;
  p_val_59   :=  nvl(p_val_59 ,l_ext_rslt.val_59  ) ;
  p_val_60   :=  nvl(p_val_60 ,l_ext_rslt.val_60  ) ;
  p_val_61   :=  nvl(p_val_61 ,l_ext_rslt.val_61  ) ;
  p_val_62   :=  nvl(p_val_62 ,l_ext_rslt.val_62  ) ;
  p_val_63   :=  nvl(p_val_63 ,l_ext_rslt.val_63  ) ;
  p_val_64   :=  nvl(p_val_64 ,l_ext_rslt.val_64  ) ;
  p_val_65   :=  nvl(p_val_65 ,l_ext_rslt.val_65  ) ;
  p_val_66   :=  nvl(p_val_66 ,l_ext_rslt.val_66  ) ;
  p_val_67   :=  nvl(p_val_67 ,l_ext_rslt.val_67  ) ;
  p_val_68   :=  nvl(p_val_68 ,l_ext_rslt.val_68  ) ;
  p_val_69   :=  nvl(p_val_69 ,l_ext_rslt.val_69  ) ;
  p_val_70   :=  nvl(p_val_70 ,l_ext_rslt.val_70  ) ;
  p_val_71   :=  nvl(p_val_71 ,l_ext_rslt.val_71  ) ;
  p_val_72   :=  nvl(p_val_72 ,l_ext_rslt.val_72  ) ;
  p_val_73   :=  nvl(p_val_73 ,l_ext_rslt.val_73  ) ;
  p_val_74   :=  nvl(p_val_74 ,l_ext_rslt.val_74  ) ;
  p_val_75   :=  nvl(p_val_75 ,l_ext_rslt.val_75  ) ;
  p_val_76   :=  nvl(p_val_76 ,l_ext_rslt.val_76  ) ;
  p_val_77   :=  nvl(p_val_77 ,l_ext_rslt.val_77  ) ;
  p_val_78   :=  nvl(p_val_78 ,l_ext_rslt.val_78  ) ;
  p_val_79   :=  nvl(p_val_79 ,l_ext_rslt.val_79  ) ;
  p_val_80   :=  nvl(p_val_80 ,l_ext_rslt.val_80  ) ;
  p_val_81   :=  nvl(p_val_81 ,l_ext_rslt.val_81  ) ;
  p_val_82   :=  nvl(p_val_82 ,l_ext_rslt.val_82  ) ;
  p_val_83   :=  nvl(p_val_83 ,l_ext_rslt.val_83  ) ;
  p_val_84   :=  nvl(p_val_84 ,l_ext_rslt.val_84  ) ;
  p_val_85   :=  nvl(p_val_85 ,l_ext_rslt.val_85  ) ;
  p_val_86   :=  nvl(p_val_86 ,l_ext_rslt.val_86  ) ;
  p_val_87   :=  nvl(p_val_87 ,l_ext_rslt.val_87  ) ;
  p_val_88   :=  nvl(p_val_88 ,l_ext_rslt.val_88  ) ;
  p_val_89   :=  nvl(p_val_89 ,l_ext_rslt.val_89  ) ;
  p_val_90   :=  nvl(p_val_90 ,l_ext_rslt.val_90  ) ;
  p_val_91   :=  nvl(p_val_91 ,l_ext_rslt.val_91  ) ;
  p_val_92   :=  nvl(p_val_92 ,l_ext_rslt.val_92  ) ;
  p_val_93   :=  nvl(p_val_93 ,l_ext_rslt.val_93  ) ;
  p_val_94   :=  nvl(p_val_94 ,l_ext_rslt.val_94  ) ;
  p_val_95   :=  nvl(p_val_95 ,l_ext_rslt.val_95  ) ;
  p_val_96   :=  nvl(p_val_96 ,l_ext_rslt.val_96  ) ;
  p_val_97   :=  nvl(p_val_97 ,l_ext_rslt.val_97  ) ;
  p_val_98   :=  nvl(p_val_98 ,l_ext_rslt.val_98  ) ;
  p_val_99   :=  nvl(p_val_99 ,l_ext_rslt.val_99  ) ;
  p_val_100  :=  nvl(p_val_100,l_ext_rslt.val_100 ) ;
  p_val_101  :=  nvl(p_val_101,l_ext_rslt.val_101 ) ;
  p_val_102  :=  nvl(p_val_102,l_ext_rslt.val_102 ) ;
  p_val_103  :=  nvl(p_val_103,l_ext_rslt.val_103 ) ;
  p_val_104  :=  nvl(p_val_104,l_ext_rslt.val_104 ) ;
  p_val_105  :=  nvl(p_val_105,l_ext_rslt.val_105 ) ;
  p_val_106  :=  nvl(p_val_106,l_ext_rslt.val_106 ) ;
  p_val_107  :=  nvl(p_val_107,l_ext_rslt.val_107 ) ;
  p_val_108  :=  nvl(p_val_108,l_ext_rslt.val_108 ) ;
  p_val_109  :=  nvl(p_val_109,l_ext_rslt.val_109 ) ;
  p_val_110  :=  nvl(p_val_110,l_ext_rslt.val_110 ) ;
  p_val_111  :=  nvl(p_val_111,l_ext_rslt.val_111 ) ;
  p_val_112  :=  nvl(p_val_112,l_ext_rslt.val_112 ) ;
  p_val_113  :=  nvl(p_val_113,l_ext_rslt.val_113 ) ;
  p_val_114  :=  nvl(p_val_114,l_ext_rslt.val_114 ) ;
  p_val_115  :=  nvl(p_val_115,l_ext_rslt.val_115 ) ;
  p_val_116  :=  nvl(p_val_116,l_ext_rslt.val_116 ) ;
  p_val_117  :=  nvl(p_val_117,l_ext_rslt.val_117 ) ;
  p_val_119  :=  nvl(p_val_119,l_ext_rslt.val_119 ) ;
  p_val_118  :=  nvl(p_val_118,l_ext_rslt.val_118 ) ;
  p_val_120  :=  nvl(p_val_120,l_ext_rslt.val_120 ) ;
  p_val_121  :=  nvl(p_val_121,l_ext_rslt.val_121 ) ;
  p_val_122  :=  nvl(p_val_122,l_ext_rslt.val_122 ) ;
  p_val_123  :=  nvl(p_val_123,l_ext_rslt.val_123 ) ;
  p_val_124  :=  nvl(p_val_124,l_ext_rslt.val_124 ) ;
  p_val_125  :=  nvl(p_val_125,l_ext_rslt.val_125 ) ;
  p_val_126  :=  nvl(p_val_126,l_ext_rslt.val_126 ) ;
  p_val_127  :=  nvl(p_val_127,l_ext_rslt.val_127 ) ;
  p_val_128  :=  nvl(p_val_128,l_ext_rslt.val_128 ) ;
  p_val_129  :=  nvl(p_val_129,l_ext_rslt.val_129 ) ;
  p_val_130  :=  nvl(p_val_130,l_ext_rslt.val_130 ) ;
  p_val_131  :=  nvl(p_val_131,l_ext_rslt.val_131 ) ;
  p_val_132  :=  nvl(p_val_132,l_ext_rslt.val_132 ) ;
  p_val_133  :=  nvl(p_val_133,l_ext_rslt.val_133 ) ;
  p_val_134  :=  nvl(p_val_134,l_ext_rslt.val_134 ) ;
  p_val_135  :=  nvl(p_val_135,l_ext_rslt.val_135 ) ;
  p_val_136  :=  nvl(p_val_136,l_ext_rslt.val_136 ) ;
  p_val_137  :=  nvl(p_val_137,l_ext_rslt.val_137 ) ;
  p_val_138  :=  nvl(p_val_138,l_ext_rslt.val_138 ) ;
  p_val_139  :=  nvl(p_val_139,l_ext_rslt.val_139 ) ;
  p_val_140  :=  nvl(p_val_140,l_ext_rslt.val_140 ) ;
  p_val_141  :=  nvl(p_val_141,l_ext_rslt.val_141 ) ;
  p_val_142  :=  nvl(p_val_142,l_ext_rslt.val_142 ) ;
  p_val_143  :=  nvl(p_val_143,l_ext_rslt.val_143 ) ;
  p_val_144  :=  nvl(p_val_144,l_ext_rslt.val_144 ) ;
  p_val_145  :=  nvl(p_val_145,l_ext_rslt.val_145 ) ;
  p_val_146  :=  nvl(p_val_146,l_ext_rslt.val_146 ) ;
  p_val_147  :=  nvl(p_val_147,l_ext_rslt.val_147 ) ;
  p_val_148  :=  nvl(p_val_148,l_ext_rslt.val_148 ) ;
  p_val_149  :=  nvl(p_val_149,l_ext_rslt.val_149 ) ;
  p_val_150  :=  nvl(p_val_150,l_ext_rslt.val_150 ) ;
  p_val_151  :=  nvl(p_val_151,l_ext_rslt.val_151 ) ;
  p_val_152  :=  nvl(p_val_152,l_ext_rslt.val_152 ) ;
  p_val_153  :=  nvl(p_val_153,l_ext_rslt.val_153 ) ;
  p_val_154  :=  nvl(p_val_154,l_ext_rslt.val_154 ) ;
  p_val_155  :=  nvl(p_val_155,l_ext_rslt.val_155 ) ;
  p_val_156  :=  nvl(p_val_156,l_ext_rslt.val_156 ) ;
  p_val_157  :=  nvl(p_val_157,l_ext_rslt.val_157 ) ;
  p_val_158  :=  nvl(p_val_158,l_ext_rslt.val_158 ) ;
  p_val_159  :=  nvl(p_val_159,l_ext_rslt.val_159 ) ;
  p_val_160  :=  nvl(p_val_160,l_ext_rslt.val_160 ) ;
  p_val_161  :=  nvl(p_val_161,l_ext_rslt.val_161 ) ;
  p_val_162  :=  nvl(p_val_162,l_ext_rslt.val_162 ) ;
  p_val_163  :=  nvl(p_val_163,l_ext_rslt.val_163 ) ;
  p_val_164  :=  nvl(p_val_164,l_ext_rslt.val_164 ) ;
  p_val_165  :=  nvl(p_val_165,l_ext_rslt.val_165 ) ;
  p_val_166  :=  nvl(p_val_166,l_ext_rslt.val_166 ) ;
  p_val_167  :=  nvl(p_val_167,l_ext_rslt.val_167 ) ;
  p_val_168  :=  nvl(p_val_168,l_ext_rslt.val_168 ) ;
  p_val_169  :=  nvl(p_val_169,l_ext_rslt.val_169 ) ;
  p_val_170  :=  nvl(p_val_170,l_ext_rslt.val_170 ) ;
  p_val_171  :=  nvl(p_val_171,l_ext_rslt.val_171 ) ;
  p_val_172  :=  nvl(p_val_172,l_ext_rslt.val_172 ) ;
  p_val_173  :=  nvl(p_val_173,l_ext_rslt.val_173 ) ;
  p_val_174  :=  nvl(p_val_174,l_ext_rslt.val_174 ) ;
  p_val_175  :=  nvl(p_val_175,l_ext_rslt.val_175 ) ;
  p_val_176  :=  nvl(p_val_176,l_ext_rslt.val_176 ) ;
  p_val_177  :=  nvl(p_val_177,l_ext_rslt.val_177 ) ;
  p_val_178  :=  nvl(p_val_178,l_ext_rslt.val_178 ) ;
  p_val_179  :=  nvl(p_val_179,l_ext_rslt.val_179 ) ;
  p_val_180  :=  nvl(p_val_180,l_ext_rslt.val_180 ) ;
  p_val_181  :=  nvl(p_val_181,l_ext_rslt.val_181 ) ;
  p_val_182  :=  nvl(p_val_182,l_ext_rslt.val_182 ) ;
  p_val_183  :=  nvl(p_val_183,l_ext_rslt.val_183 ) ;
  p_val_184  :=  nvl(p_val_184,l_ext_rslt.val_184 ) ;
  p_val_185  :=  nvl(p_val_185,l_ext_rslt.val_185 ) ;
  p_val_186  :=  nvl(p_val_186,l_ext_rslt.val_186 ) ;
  p_val_187  :=  nvl(p_val_187,l_ext_rslt.val_187 ) ;
  p_val_188  :=  nvl(p_val_188,l_ext_rslt.val_188 ) ;
  p_val_189  :=  nvl(p_val_189,l_ext_rslt.val_189 ) ;
  p_val_190  :=  nvl(p_val_190,l_ext_rslt.val_190 ) ;
  p_val_191  :=  nvl(p_val_191,l_ext_rslt.val_191 ) ;
  p_val_192  :=  nvl(p_val_192,l_ext_rslt.val_192 ) ;
  p_val_193  :=  nvl(p_val_193,l_ext_rslt.val_193 ) ;
  p_val_194  :=  nvl(p_val_194,l_ext_rslt.val_194 ) ;
  p_val_195  :=  nvl(p_val_195,l_ext_rslt.val_195 ) ;
  p_val_196  :=  nvl(p_val_196,l_ext_rslt.val_196 ) ;
  p_val_197  :=  nvl(p_val_197,l_ext_rslt.val_197 ) ;
  p_val_198  :=  nvl(p_val_198,l_ext_rslt.val_198 ) ;
  p_val_199  :=  nvl(p_val_199,l_ext_rslt.val_199 ) ;
  p_val_200  :=  nvl(p_val_200,l_ext_rslt.val_200 ) ;
  p_val_201  :=  nvl(p_val_201,l_ext_rslt.val_201 ) ;
  p_val_202  :=  nvl(p_val_202,l_ext_rslt.val_202 ) ;
  p_val_203  :=  nvl(p_val_203,l_ext_rslt.val_203 ) ;
  p_val_204  :=  nvl(p_val_204,l_ext_rslt.val_204 ) ;
  p_val_205  :=  nvl(p_val_205,l_ext_rslt.val_205 ) ;
  p_val_206  :=  nvl(p_val_206,l_ext_rslt.val_206 ) ;
  p_val_207  :=  nvl(p_val_207,l_ext_rslt.val_207 ) ;
  p_val_208  :=  nvl(p_val_208,l_ext_rslt.val_208 ) ;
  p_val_209  :=  nvl(p_val_209,l_ext_rslt.val_209 ) ;
  p_val_210  :=  nvl(p_val_210,l_ext_rslt.val_210 ) ;
  p_val_211  :=  nvl(p_val_211,l_ext_rslt.val_211 ) ;
  p_val_212  :=  nvl(p_val_212,l_ext_rslt.val_212 ) ;
  p_val_213  :=  nvl(p_val_213,l_ext_rslt.val_213 ) ;
  p_val_214  :=  nvl(p_val_214,l_ext_rslt.val_214 ) ;
  p_val_215  :=  nvl(p_val_215,l_ext_rslt.val_215 ) ;
  p_val_216  :=  nvl(p_val_216,l_ext_rslt.val_216 ) ;
  p_val_217  :=  nvl(p_val_217,l_ext_rslt.val_217 ) ;
  p_val_219  :=  nvl(p_val_219,l_ext_rslt.val_219 ) ;
  p_val_218  :=  nvl(p_val_218,l_ext_rslt.val_218 ) ;
  p_val_220  :=  nvl(p_val_220,l_ext_rslt.val_220 ) ;
  p_val_221  :=  nvl(p_val_221,l_ext_rslt.val_221 ) ;
  p_val_222  :=  nvl(p_val_222,l_ext_rslt.val_222 ) ;
  p_val_223  :=  nvl(p_val_223,l_ext_rslt.val_223 ) ;
  p_val_224  :=  nvl(p_val_224,l_ext_rslt.val_224 ) ;
  p_val_225  :=  nvl(p_val_225,l_ext_rslt.val_225 ) ;
  p_val_226  :=  nvl(p_val_226,l_ext_rslt.val_226 ) ;
  p_val_227  :=  nvl(p_val_227,l_ext_rslt.val_227 ) ;
  p_val_228  :=  nvl(p_val_228,l_ext_rslt.val_228 ) ;
  p_val_229  :=  nvl(p_val_229,l_ext_rslt.val_229 ) ;
  p_val_230  :=  nvl(p_val_230,l_ext_rslt.val_230 ) ;
  p_val_231  :=  nvl(p_val_231,l_ext_rslt.val_231 ) ;
  p_val_232  :=  nvl(p_val_232,l_ext_rslt.val_232 ) ;
  p_val_233  :=  nvl(p_val_233,l_ext_rslt.val_233 ) ;
  p_val_234  :=  nvl(p_val_234,l_ext_rslt.val_234 ) ;
  p_val_235  :=  nvl(p_val_235,l_ext_rslt.val_235 ) ;
  p_val_236  :=  nvl(p_val_236,l_ext_rslt.val_236 ) ;
  p_val_237  :=  nvl(p_val_237,l_ext_rslt.val_237 ) ;
  p_val_238  :=  nvl(p_val_238,l_ext_rslt.val_238 ) ;
  p_val_239  :=  nvl(p_val_239,l_ext_rslt.val_239 ) ;
  p_val_240  :=  nvl(p_val_240,l_ext_rslt.val_240 ) ;
  p_val_241  :=  nvl(p_val_241,l_ext_rslt.val_241 ) ;
  p_val_242  :=  nvl(p_val_242,l_ext_rslt.val_242 ) ;
  p_val_243  :=  nvl(p_val_243,l_ext_rslt.val_243 ) ;
  p_val_244  :=  nvl(p_val_244,l_ext_rslt.val_244 ) ;
  p_val_245  :=  nvl(p_val_245,l_ext_rslt.val_245 ) ;
  p_val_246  :=  nvl(p_val_246,l_ext_rslt.val_246 ) ;
  p_val_247  :=  nvl(p_val_247,l_ext_rslt.val_247 ) ;
  p_val_248  :=  nvl(p_val_248,l_ext_rslt.val_248 ) ;
  p_val_249  :=  nvl(p_val_249,l_ext_rslt.val_249 ) ;
  p_val_250  :=  nvl(p_val_250,l_ext_rslt.val_250 ) ;
  p_val_251  :=  nvl(p_val_251,l_ext_rslt.val_251 ) ;
  p_val_252  :=  nvl(p_val_252,l_ext_rslt.val_252 ) ;
  p_val_253  :=  nvl(p_val_253,l_ext_rslt.val_253 ) ;
  p_val_254  :=  nvl(p_val_254,l_ext_rslt.val_254 ) ;
  p_val_255  :=  nvl(p_val_255,l_ext_rslt.val_255 ) ;
  p_val_256  :=  nvl(p_val_256,l_ext_rslt.val_256 ) ;
  p_val_257  :=  nvl(p_val_257,l_ext_rslt.val_257 ) ;
  p_val_258  :=  nvl(p_val_258,l_ext_rslt.val_258 ) ;
  p_val_259  :=  nvl(p_val_259,l_ext_rslt.val_259 ) ;
  p_val_260  :=  nvl(p_val_260,l_ext_rslt.val_260 ) ;
  p_val_261  :=  nvl(p_val_261,l_ext_rslt.val_261 ) ;
  p_val_262  :=  nvl(p_val_262,l_ext_rslt.val_262 ) ;
  p_val_263  :=  nvl(p_val_263,l_ext_rslt.val_263 ) ;
  p_val_264  :=  nvl(p_val_264,l_ext_rslt.val_264 ) ;
  p_val_265  :=  nvl(p_val_265,l_ext_rslt.val_265 ) ;
  p_val_266  :=  nvl(p_val_266,l_ext_rslt.val_266 ) ;
  p_val_267  :=  nvl(p_val_267,l_ext_rslt.val_267 ) ;
  p_val_268  :=  nvl(p_val_268,l_ext_rslt.val_268 ) ;
  p_val_269  :=  nvl(p_val_269,l_ext_rslt.val_269 ) ;
  p_val_270  :=  nvl(p_val_270,l_ext_rslt.val_270 ) ;
  p_val_271  :=  nvl(p_val_271,l_ext_rslt.val_271 ) ;
  p_val_272  :=  nvl(p_val_272,l_ext_rslt.val_272 ) ;
  p_val_273  :=  nvl(p_val_273,l_ext_rslt.val_273 ) ;
  p_val_274  :=  nvl(p_val_274,l_ext_rslt.val_274 ) ;
  p_val_275  :=  nvl(p_val_275,l_ext_rslt.val_275 ) ;
  p_val_276  :=  nvl(p_val_276,l_ext_rslt.val_276 ) ;
  p_val_277  :=  nvl(p_val_277,l_ext_rslt.val_277 ) ;
  p_val_278  :=  nvl(p_val_278,l_ext_rslt.val_278 ) ;
  p_val_279  :=  nvl(p_val_279,l_ext_rslt.val_279 ) ;
  p_val_280  :=  nvl(p_val_280,l_ext_rslt.val_280 ) ;
  p_val_281  :=  nvl(p_val_281,l_ext_rslt.val_281 ) ;
  p_val_282  :=  nvl(p_val_282,l_ext_rslt.val_282 ) ;
  p_val_283  :=  nvl(p_val_283,l_ext_rslt.val_283 ) ;
  p_val_284  :=  nvl(p_val_284,l_ext_rslt.val_284 ) ;
  p_val_285  :=  nvl(p_val_285,l_ext_rslt.val_285 ) ;
  p_val_286  :=  nvl(p_val_286,l_ext_rslt.val_286 ) ;
  p_val_287  :=  nvl(p_val_287,l_ext_rslt.val_287 ) ;
  p_val_288  :=  nvl(p_val_288,l_ext_rslt.val_288 ) ;
  p_val_289  :=  nvl(p_val_289,l_ext_rslt.val_289 ) ;
  p_val_290  :=  nvl(p_val_290,l_ext_rslt.val_290 ) ;
  p_val_291  :=  nvl(p_val_291,l_ext_rslt.val_291 ) ;
  p_val_292  :=  nvl(p_val_292,l_ext_rslt.val_292 ) ;
  p_val_293  :=  nvl(p_val_293,l_ext_rslt.val_293 ) ;
  p_val_294  :=  nvl(p_val_294,l_ext_rslt.val_294 ) ;
  p_val_295  :=  nvl(p_val_295,l_ext_rslt.val_295 ) ;
  p_val_296  :=  nvl(p_val_296,l_ext_rslt.val_296 ) ;
  p_val_297  :=  nvl(p_val_297,l_ext_rslt.val_297 ) ;
  p_val_298  :=  nvl(p_val_298,l_ext_rslt.val_298 ) ;
  p_val_299  :=  nvl(p_val_299,l_ext_rslt.val_299 ) ;
  p_val_300  :=  nvl(p_val_300,l_ext_rslt.val_300 ) ;


  hr_utility.set_location('Mode '||p_ext_chg_rcd_mode, 15);
  hr_utility.set_location('Exiting'||l_proc, 15);

End   chg_rcd_merge  ;


--
End ben_ext_adv_conditions;

/
