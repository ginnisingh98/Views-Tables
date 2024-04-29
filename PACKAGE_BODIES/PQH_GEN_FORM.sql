--------------------------------------------------------
--  DDL for Package Body PQH_GEN_FORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GEN_FORM" as
/* $Header: pqgnfnf.pkb 120.2.12010000.2 2009/02/23 11:11:49 skura ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< PQH_GEN_FORM >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Created by : Sanej Nair (SCNair)
--
-- Description:
--    This handles internal Generic form support functionalities.
--
-- Access Status:
--   Internal Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
-- Created by : Sanej Nair (SCNair)
--  Version Date        Author         Comment
--  -------+-----------+--------------+----------------------------------------
--  115.0  27-Feb-2000 Sanej Nair     Initial Version
--  ==========================================================================

g_package       varchar2(80)  := '  PQH_GEN_FORM.';
g_code          varchar2(30)  ;
g_meaning       varchar2(240) ;
-- forllowing variables are for caching BG (context bg function usage)
g_private_bg_id    number(15);
g_private_txn_id   number(15);
--
-- Procedure to create source records / retrive number of records likey to be retrived
--
procedure create_source ( p_copy_entity_txn_id     number
                        , p_delimiter              varchar2
                        , p_count              out nocopy number
                        , p_msg                out nocopy varchar2
                        , p_copies                 number default 1
                        , p_row_count              boolean ) is

-- local Variables
l_ins            varchar2(32000);
l_sel            varchar2(32000);
l_where          varchar2(32000);
l_session_id     fnd_sessions.session_id%type;
l_effective_date date;
--
-- Primary Cursor fetching txn related details
--
cursor c_txn is
select e.copy_entity_txn_id
     , e.transaction_category_id
     , e.txn_category_attribute_id
     , e.context_business_group_id
     , e.src_effective_date
     , e.context -- application_id
     , a.information_category
     , replace(a.information1, '''','''''') information1
     , replace(a.information2, '''','''''') information2
     , replace(a.information3, '''','''''') information3
     , replace(a.information4, '''','''''') information4
     , replace(a.information5, '''','''''') information5
     , replace(a.information6, '''','''''') information6
     , replace(a.information7, '''','''''') information7
     , replace(a.information8, '''','''''') information8
     , replace(a.information9, '''','''''') information9
     , replace(a.information10, '''','''''') information10
     , replace(a.information11, '''','''''') information11
     , replace(a.information12, '''','''''') information12
     , replace(a.information13, '''','''''') information13
     , replace(a.information14, '''','''''') information14
     , replace(a.information15, '''','''''') information15
     , replace(a.information16, '''','''''') information16
     , replace(a.information17, '''','''''') information17
     , replace(a.information18, '''','''''') information18
     , replace(a.information19, '''','''''') information19
     , replace(a.information20, '''','''''') information20
     , replace(a.information21, '''','''''') information21
     , replace(a.information22, '''','''''') information22
     , replace(a.information23, '''','''''') information23
     , replace(a.information24, '''','''''') information24
     , replace(a.information25, '''','''''') information25
     , replace(a.information26, '''','''''') information26
     , replace(a.information27, '''','''''') information27
     , replace(a.information28, '''','''''') information28
     , replace(a.information29, '''','''''') information29
     , replace(a.information30, '''','''''') information30
     , t.from_clause
     , t.where_clause
     , c.master_table_route_id
from  pqh_copy_entity_txns e
      , pqh_copy_entity_attribs a
      , pqh_transaction_categories c
      , pqh_table_route t
where e.copy_entity_txn_id          = a.copy_entity_txn_id
  and a.row_type_cd                 = 'CRITERIA'
  and c.transaction_category_id     = e.transaction_category_id
  and c.master_table_route_id       = t.table_route_id
  and e.copy_entity_txn_id          = p_copy_entity_txn_id ;

--
-- Cursor to decode information based on inner cursor
--
cursor dec (column_name      varchar2
           ,ddf_column_name  varchar2
           ,information1     varchar2
           ,information2     varchar2
           ,information3     varchar2
           ,information4     varchar2
           ,information5     varchar2
           ,information6     varchar2
           ,information7     varchar2
           ,information8     varchar2
           ,information9     varchar2
           ,information10    varchar2
           ,information11    varchar2
           ,information12    varchar2
           ,information13    varchar2
           ,information14    varchar2
           ,information15    varchar2
           ,information16    varchar2
           ,information17    varchar2
           ,information18    varchar2
           ,information19    varchar2
           ,information20    varchar2
           ,information21    varchar2
           ,information22    varchar2
           ,information23    varchar2
           ,information24    varchar2
           ,information25    varchar2
           ,information26    varchar2
           ,information27    varchar2
           ,information28    varchar2
           ,information29    varchar2
           ,information30    varchar2
           ,p_delimiter      varchar2 )
is
select decode(upper(ddf_column_name)
       ,'INFORMATION1', decode(information1,null, column_name, ''''||information1 ||'''')
       ,'INFORMATION2', decode(information2,null, column_name, ''''||information2 ||'''')
       ,'INFORMATION3', decode(information3,null, column_name, ''''||information3 ||'''')
       ,'INFORMATION4', decode(information4,null, column_name, ''''||information4 ||'''')
       ,'INFORMATION5', decode(information5,null, column_name, ''''||information5 ||'''')
       ,'INFORMATION6', decode(information6,null, column_name, ''''||information6 ||'''')
       ,'INFORMATION7', decode(information7,null, column_name, ''''||information7 ||'''')
       ,'INFORMATION8', decode(information8,null, column_name, ''''||information8 ||'''')
       ,'INFORMATION9', decode(information9,null, column_name, ''''||information9 ||'''')
       ,'INFORMATION10',decode(information10,null,column_name, ''''||information10||'''')
       ,'INFORMATION11',decode(information11,null,column_name, ''''||information11||'''')
       ,'INFORMATION12',decode(information12,null,column_name, ''''||information12||'''')
       ,'INFORMATION13',decode(information13,null,column_name, ''''||information13||'''')
       ,'INFORMATION14',decode(information14,null,column_name, ''''||information14||'''')
       ,'INFORMATION15',decode(information15,null,column_name, ''''||information15||'''')
       ,'INFORMATION16',decode(information16,null,column_name, ''''||information16||'''')
       ,'INFORMATION17',decode(information17,null,column_name, ''''||information17||'''')
       ,'INFORMATION18',decode(information18,null,column_name, ''''||information18||'''')
       ,'INFORMATION19',decode(information19,null,column_name, ''''||information19||'''')
       ,'INFORMATION20',decode(information20,null,column_name, ''''||information20||'''')
       ,'INFORMATION21',decode(information21,null,column_name, ''''||information21||'''')
       ,'INFORMATION22',decode(information22,null,column_name, ''''||information22||'''')
       ,'INFORMATION23',decode(information23,null,column_name, ''''||information23||'''')
       ,'INFORMATION24',decode(information24,null,column_name, ''''||information24||'''')
       ,'INFORMATION25',decode(information25,null,column_name, ''''||information25||'''')
       ,'INFORMATION26',decode(information26,null,column_name, ''''||information26||'''')
       ,'INFORMATION27',decode(information27,null,column_name, ''''||information27||'''')
       ,'INFORMATION28',decode(information28,null,column_name, ''''||information28||'''')
       ,'INFORMATION29',decode(information29,null,column_name, ''''||information29||'''')
       ,'INFORMATION30',decode(information30,null,column_name, ''''||information30||'''')
       , column_name) info
from dual where rownum < 2;

--
-- cursor to fetch details on what is stored where and what goes where for the dynamic sql
--
cursor c_sat (p_attribute_type_cd       varchar2
             ,p_transaction_category_id number) is
select upper(a.column_name ) column_name
      , a.column_type
      , pqh_generic.get_alias(a.column_name) alias
      , decode(column_type,'D', 'fnd_date.date_to_canonical('|| substr(a.column_name,1,instr(a.column_name||' ', ' ',1)-1) ||')'||' '||pqh_generic.get_alias(column_name)
                          , column_name ) col_dt_name
      , a.width
      , upper(s.ddf_column_name ) ddf_column_name
      , upper(s.ddf_value_column_name ) ddf_value_column_name
      , c.value_set_id
      , s.context  -- application_id a
from pqh_special_attributes s
     , pqh_txn_category_attributes c
     , pqh_attributes a
where s.txn_category_attribute_id = c.txn_category_attribute_id
  and c.attribute_id              = a.attribute_id
  and c.transaction_category_id   = p_transaction_category_id
  and s.attribute_type_cd         = p_attribute_type_cd
  and s.context                   = pqh_gen_form.g_gbl_context
  and c.select_flag               = 'Y'
  and a.enable_flag               = 'Y' ;
--
cursor c_session is
   select session_id, effective_date
   from fnd_sessions
   where session_id = userenv('sessionid')
   for update of effective_date;
--
--internal function
--
function find_like_or_equal(p_string in varchar2) return varchar2 is
  l_like  varchar2(10) := ' like ';
  l_equal varchar2(10) := '=';
begin
  if instr(p_string, '%') > 0 or instr(p_string, '_') > 0 then
     return l_like;
  end if;
  --
  return l_equal;
exception when others then
  return l_like ;
end find_like_or_equal;
--
begin
--
hr_utility.set_location(g_package||'create_source: Entering',1);
--
-- The primary cursor, this ideally would have just row with information pretaining to the txn
--
for rec in c_txn loop
   -- set session_date as per user request
   open c_session ;
   fetch c_session into l_session_id, l_effective_date;
   --
   if c_session%notfound then
        insert into fnd_sessions (session_id, effective_date)
                    values       ( userenv('sessionid'), nvl(rec.src_effective_date, trunc(sysdate)));
   else
        update fnd_sessions
        set effective_date = nvl(rec.src_effective_date,trunc(sysdate))
        where current of c_session;
   end if;
   close c_session;
   --
   pqh_gen_form.populate_context(rec.copy_entity_txn_id);
   --
   if not(p_row_count) then

      hr_utility.set_location(g_package||'create_source: inside c_txn',2);
      --
      -- l_ins would hold the string call to create source records on the results table
      --
      l_ins := 'pqh_copy_entity_results_api.create_copy_entity_result '||
               '( '||
               'p_copy_entity_result_id  => l_var '||
               ',p_object_version_number => l_var '||
               ',p_result_type_cd        => ''SOURCE'' '||
               ',p_status                => ''SRC_P'' '||
               ',p_number_of_copies      => '|| nvl(p_copies,1) ||
               ',p_copy_entity_txn_id    => '||p_copy_entity_txn_id         ||
               ',p_effective_date        => trunc(sysdate)' ;

      --
      -- l_sel would hold the string call to select from the txn entity (eg position table, job table etc)
      --
      l_sel := 'Select 1 pqh_$$_unique' ;
      --
      -- cursor to pick the names of diplayable items on the form for given txn, responsibility etc.
      --
      for e_rec in c_sat('DISPLAY', rec.transaction_category_id) loop
        hr_utility.set_location(g_package||'create_source: inside c_sat D',3);
        if e_rec.context = pqh_gen_form.g_gbl_context then
           if not( instr(l_ins, e_rec.ddf_column_name||'=>') <> 0 ) then
                l_ins := l_ins ||
                         ',P_' ||e_rec.ddf_column_name||'=>i.'|| e_rec.alias;
           end if; --instr(l_ins, e_rec.ddf_column_name) = 0
           --
           if e_rec.ddf_value_column_name is not null and e_rec.column_type = 'D' then
               if not( instr(l_ins, e_rec.ddf_value_column_name||'=>') <> 0 ) then
                  l_ins := l_ins ||
                           ',P_' ||e_rec.ddf_value_column_name||'=>i.'||e_rec.alias ;
               end if; --instr(l_ins, e_rec.ddf_column_name) = 0
           end if; -- ddf_value_column_name + date
           --
		 -- problem if a date column would have value set on it...may have to change the check below
		 --
           if e_rec.ddf_value_column_name is not null and e_rec.column_type <> 'D' then
               if not( instr(l_ins, e_rec.ddf_value_column_name||'=>') <> 0 ) then
                  l_ins := l_ins ||
                           ',P_' ||e_rec.ddf_value_column_name
                                 ||' =>  rtrim(pqh_gen_form.get_value_from_id( i.'|| e_rec.alias
                                 ||','''||e_rec.value_set_id||'''))';
               end if; --instr(l_ins, e_rec.ddf_column_name) = 0
           end if; -- ddf_value_column_name
           --
           if not( instr(l_sel, ' '||e_rec.column_name||' ') <> 0 ) then
                l_sel := l_sel ||', '||e_rec.col_dt_name||' ' ;
           end if; -- instr(l_ins, e_rec.col_dt_name) = 0
        end if; -- Display
      end loop ; -- c_sat display
      --
      -- cursor to pick the names of primary key items for given txn.
      --
      for e_rec in c_sat('PRIMARY_KEY', rec.transaction_category_id) loop
        hr_utility.set_location(g_package||'create_source: inside c_sat P',3);
        if e_rec.context = pqh_gen_form.g_gbl_context then
   	    if not( instr(l_ins, e_rec.ddf_column_name||'=>') <> 0 ) then
                l_ins := l_ins ||
                         ',P_' ||e_rec.ddf_column_name||'=>i.'|| e_rec.alias;
            end if; --instr(l_ins, e_rec.ddf_column_name) = 0

	    if not( instr(l_sel, ' '||e_rec.col_dt_name||' ') <> 0 ) then
                l_sel := l_sel ||', '||e_rec.col_dt_name||' ' ;
            end if; -- instr(l_ins, e_rec.col_dt_name) = 0
        end if; -- Primary Key
      end loop ; -- c_sat primary_key
      -- HIDDEN column addition
      for e_rec in c_sat('HIDDEN', rec.transaction_category_id) loop
        hr_utility.set_location(g_package||'create_source: inside c_sat H',31);
        if e_rec.context = pqh_gen_form.g_gbl_context then
   	    if not( instr(l_ins, e_rec.ddf_column_name||'=>') <> 0 ) then
                l_ins := l_ins ||
                         ',P_' ||e_rec.ddf_column_name||'=>i.'|| e_rec.alias;
            end if; --instr(l_ins, e_rec.ddf_column_name) = 0

	    if not( instr(l_sel, ' '||e_rec.col_dt_name||' ') <> 0 ) then
                l_sel := l_sel ||', '||e_rec.col_dt_name||' ' ;
            end if; -- instr(l_ins, e_rec.col_dt_name) = 0
        end if; --
      end loop ; -- c_sat HIDDEN column
      -- SEGMENTs
      for e_rec in c_sat('SEGMENT', rec.transaction_category_id) loop
        hr_utility.set_location(g_package||'create_source: inside c_sat S',32);
        if e_rec.context = pqh_gen_form.g_gbl_context then
            if not( instr(l_ins, e_rec.ddf_column_name||'=>') <> 0 ) then
                l_ins := l_ins ||
                         ',P_' ||e_rec.ddf_column_name||'=>i.'|| e_rec.alias;
            end if; --instr(l_ins, e_rec.ddf_column_name) = 0

            if not( instr(l_sel, ' '||e_rec.col_dt_name||' ') <> 0 ) then
                l_sel := l_sel ||', '||e_rec.col_dt_name||' ' ;
            end if; -- instr(l_ins, e_rec.col_dt_name) = 0
        end if; -- Segments
      end loop ; -- c_sat segments

   end if; -- p_row_count
   --
   -- Building where condition with information entered by the user as criteria, l_where hold where string
   --
   pqh_refresh_data.g_refresh_tab.delete;

   if rec.context_business_group_id is not null then
      pqh_refresh_data.g_refresh_tab(1).column_name  := 'BUSINESS_GROUP_ID';
      pqh_refresh_data.g_refresh_tab(1).column_type  := 'N';
      pqh_refresh_data.g_refresh_tab(1).txn_val      := rec.context_business_group_id ;
      pqh_refresh_data.g_refresh_tab(1).shadow_val   := rec.context_business_group_id ;
      pqh_refresh_data.g_refresh_tab(1).main_val     := rec.context_business_group_id ;
      pqh_refresh_data.g_refresh_tab(1).refresh_flag := 'N';
      pqh_refresh_data.g_refresh_tab(1).updt_flag    := 'N';
   end if;

   pqh_refresh_data.replace_where_params(rec.where_clause,'N','',l_where);
   --;
   l_where := ' Where '||nvl(l_where, '1=1')||' ';
   --
   for e_rec in c_sat('CRITERIA', rec.transaction_category_id) loop
     if e_rec.context = pqh_gen_form.g_gbl_context then
        --
        hr_utility.set_location(g_package||'create_source: inside c_sat 2',4);
        for i in dec (e_rec.column_name, e_rec.ddf_column_name, rec.information1
                      ,rec.information2, rec.information3, rec.information4
                      ,rec.information5, rec.information6, rec.information7
                      ,rec.information8, rec.information9, rec.information10
                      ,rec.information11, rec.information12, rec.information13
                      ,rec.information14, rec.information15, rec.information16
                      ,rec.information17, rec.information18, rec.information19
                      ,rec.information20, rec.information21, rec.information22
                      ,rec.information23, rec.information24, rec.information25
                      ,rec.information26, rec.information27, rec.information28
                      ,rec.information29, rec.information30, p_delimiter) loop
        hr_utility.set_location(g_package||'create_source: inside c_dec ',5);
        --
	   -- COLUMN_NAME like COLUMN_NAME fails if the value is null and hence decided to form where
	   -- on if there is a value (SCNair 05/25/00 UK)
	   --
	   if e_rec.column_name <> i.info then
           if e_rec.column_type = 'D' then
              l_where := l_where || ' and ' || e_rec.column_name ||
                         find_like_or_equal(i.info) ||'fnd_date.canonical_to_date('||i.info||')' ;
           else
              l_where := l_where || ' and ' || e_rec.column_name ||find_like_or_equal(i.info)||i.info ;
           end if;
	   end if;
        end loop ; --dec
        --
     end if; -- for global context of txn_short_name
   end loop ; -- c_sat changeable
   hr_utility.set_location(g_package||'create_source: after c_dec ',6);
   hr_utility.trace('BEGIN l_where PQH_GEN_FORM');
   hr_utility.trace(substr(l_where,1,2000));
   hr_utility.trace(substr(l_where,2001,2000));
   hr_utility.trace(substr(l_where,4001,2000));
   hr_utility.trace(substr(l_where,6001,2000));
   hr_utility.trace(substr(l_where,8001,2000));
   hr_utility.trace(substr(l_where,10001,2000));
   hr_utility.trace(substr(l_where,12001,2000));
   hr_utility.trace(substr(l_where,14001,2000));
   hr_utility.trace(substr(l_where,16001,2000));
   hr_utility.trace(substr(l_where,18001,2000));
   hr_utility.trace(substr(l_where,20001,2000));
   hr_utility.trace(substr(l_where,22001,2000));
   hr_utility.trace(substr(l_where,24001,2000));
   hr_utility.trace(substr(l_where,26001,2000));
   hr_utility.trace(substr(l_where,28001,2000));
   hr_utility.trace(substr(l_where,30001,2000));
   hr_utility.trace('END l_where PQH_GEN_FORM');
   --
   -- Replace where clause
   --
   if p_row_count then
      g_count := '';
      g_msg   := '';
      hr_utility.set_location(g_package||'create_source: before count ',7);
      execute immediate 'begin select count(*) into pqh_gen_form.g_count from '||rec.from_clause ||l_where ||';'||
                        ' exception when no_data_found then pqh_gen_form.g_count := 0;'||
                        ' when others then pqh_gen_form.g_msg := sqlerrm; end; ';
      p_count := g_count;
      p_msg   := g_msg ;
   else
      l_ins := l_ins || ');';
      hr_utility.set_location(g_package||'create_source: after l_ins ',7);
      l_sel := l_sel || ' from ' || rec.from_clause ||l_where||';' ;
      hr_utility.set_location(g_package||'create_source: after l_sel ',8);
      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      hr_utility.trace('BEGIN l_SEL PQH_GEN_FORM');
      hr_utility.trace(substr(l_sel,1,2000));
      hr_utility.trace(substr(l_sel,2001,2000));
      hr_utility.trace(substr(l_sel,4001,2000));
      hr_utility.trace(substr(l_sel,6001,2000));
      hr_utility.trace(substr(l_sel,8001,2000));
      hr_utility.trace(substr(l_sel,10001,2000));
      hr_utility.trace(substr(l_sel,12001,2000));
      hr_utility.trace(substr(l_sel,14001,2000));
      hr_utility.trace(substr(l_sel,16001,2000));
      hr_utility.trace(substr(l_sel,18001,2000));
      hr_utility.trace(substr(l_sel,20001,2000));
      hr_utility.trace(substr(l_sel,22001,2000));
      hr_utility.trace(substr(l_sel,24001,2000));
      hr_utility.trace(substr(l_sel,26001,2000));
      hr_utility.trace(substr(l_sel,28001,2000));
      hr_utility.trace(substr(l_sel,30001,2000));
      hr_utility.trace(substr(l_sel,32001,2000));
      hr_utility.trace('END l_SEL PQH_GEN_FORM');
      --
      hr_utility.trace('BEGIN l_INS PQH_GEN_FORM');
      hr_utility.trace(substr(l_ins,1,2000));
      hr_utility.trace(substr(l_ins,2001,2000));
      hr_utility.trace(substr(l_ins,4001,2000));
      hr_utility.trace(substr(l_ins,6001,2000));
      hr_utility.trace(substr(l_ins,8001,2000));
      hr_utility.trace(substr(l_ins,10001,2000));
      hr_utility.trace(substr(l_ins,12001,2000));
      hr_utility.trace(substr(l_ins,14001,2000));
      hr_utility.trace(substr(l_ins,16001,2000));
      hr_utility.trace(substr(l_ins,18001,2000));
      hr_utility.trace(substr(l_ins,20001,2000));
      hr_utility.trace(substr(l_ins,22001,2000));
      hr_utility.trace(substr(l_ins,24001,2000));
      hr_utility.trace(substr(l_ins,26001,2000));
      hr_utility.trace(substr(l_ins,28001,2000));
      hr_utility.trace(substr(l_ins,30001,2000));
      hr_utility.trace(substr(l_ins,32001,2000));
      hr_utility.trace('END l_INS PQH_GEN_FORM');
      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      execute immediate 'declare l_var number; cursor c_a is '|| l_sel||' begin for i in c_a loop '
                        ||l_ins||' end loop; end;';

      hr_utility.set_location(g_package||'create_source: after execute of ins api',9);
   end if; -- p_row_count
end loop ; -- c_txn

hr_utility.set_location(g_package||'create_source: Leaving',1);
exception when others then
p_count              := null;
p_msg                := null;
raise;
end create_source;
--
-- Over load ; to be called to perform source create
--
procedure create_source ( p_copy_entity_txn_id     number
                        , p_delimiter              varchar2
                        , p_copies                 number default 1
                        , p_msg                out nocopy varchar2) is
--
-- local variable
--
l_count     number;
l_row_count boolean := false;
begin
   create_source ( p_copy_entity_txn_id  => p_copy_entity_txn_id
                  , p_delimiter          => p_delimiter
                  , p_count              => l_count
                  , p_msg                => p_msg
                  , p_copies             => p_copies
                  , p_row_count          => l_row_count );
end;
--
-- To be called to perform source count
--
procedure count_source ( p_copy_entity_txn_id     number
                        , p_delimiter             varchar2
                        , p_count              out nocopy number
                        , p_msg                out nocopy varchar2 ) is
--
-- local variable
--
l_count     number;
l_row_count boolean := true;
begin
   create_source ( p_copy_entity_txn_id  => p_copy_entity_txn_id
                  , p_delimiter          => p_delimiter
                  , p_count              => p_count
                  , p_msg                => p_msg
                  , p_row_count          => l_row_count );
end;
--
procedure recount_source ( p_copy_entity_txn_id     number
                          , p_delimiter             varchar2
                          , p_count              out nocopy number
                          , p_msg                out nocopy varchar2 ) is
--
-- local variable
--
l_count     number;
l_row_count boolean := true;
begin
   --
   delete from pqh_copy_entity_results
   where  copy_entity_txn_id = p_copy_entity_txn_id;
   --
   create_source ( p_copy_entity_txn_id  => p_copy_entity_txn_id
                  , p_delimiter          => p_delimiter
                  , p_count              => p_count
                  , p_msg                => p_msg
                  , p_row_count          => l_row_count );
end;
--
procedure update_source (p_copy_entity_result_id          number
                         , p_count                        number
                         , p_object_version_number in out nocopy number ) is

begin
  pqh_copy_entity_results_api.update_copy_entity_result
          ( p_validate              =>  false
          , p_copy_entity_result_id => p_copy_entity_result_id
          , p_number_of_copies      => p_count
          , p_object_version_number => p_object_version_number
          , p_effective_date        => trunc(sysdate)
          , p_long_attribute1       => null
          ) ;

end update_source;
--
Procedure create_target ( p_copy_entity_txn_id  number
                        , p_ld1                 varchar2                  --(ld => flex delimter)
                        , p_lf1                 varchar2   default null   --(lf => flex code)
                        , p_ln1                 varchar2   default null   --(ln => flex numb)
                        , p_ld2                 varchar2   default null
                        , p_lf2                 varchar2   default null
                        , p_ln2                 varchar2   default null
                        , p_batch_status    out nocopy varchar2 ) is
--
l_txn_category_attribute_id  pqh_special_attributes.txn_category_attribute_id%type;
l_replacement_type_cd        pqh_copy_entity_txns.replacement_type_cd%type ;
l_start_with                 pqh_copy_entity_txns.start_with%type;
l_increment_by               pqh_copy_entity_txns.increment_by%type;
l_mast_trt_id                pqh_transaction_categories.master_table_route_id%type;
l_transaction_id             pqh_transaction_categories.transaction_category_id%type;
l_warn                       number(15);
l_copies                     number(15);
l_copy_entity_result_id      number(15);
l_ovn                        number(15);
--
cursor c_txn is
   select cet.txn_category_attribute_id
          , cet.replacement_type_cd
          , cet.start_with
          , cet.increment_by
          , cet.transaction_category_id
          , tct.master_table_route_id
          , cet.context context -- application_id
   from pqh_copy_entity_txns cet
        , pqh_transaction_categories tct
   where  copy_entity_txn_id = p_copy_entity_txn_id
   and    tct.transaction_category_id = cet.transaction_category_id;
--
cursor c_change is
   select copy_entity_attrib_id
          , information1
          , information2
          , information3
          , information4
          , information5
          , information6
          , information7
          , information8
          , information9
          , information10
          , information11
          , information12
          , information13
          , information14
          , information15
          , information16
          , information17
          , information18
          , information19
          , information20
          , information21
          , information22
          , information23
          , information24
          , information25
          , information26
          , information27
          , information28
          , information29
          , information30
   from  pqh_copy_entity_attribs
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   row_type_cd        = 'CHANGEABLE' ;
--
cursor c_ch_kf (p_flex in varchar2) is
   select copy_entity_attrib_id
          , row_type_cd
          , information_category
          , information1
          , information2
          , information3
          , information4
          , information5
          , information6
          , information7
          , information8
          , information9
          , information10
          , information11
          , information12
          , information13
          , information14
          , information15
          , information16
          , information17
          , information18
          , information19
          , information20
          , information21
          , information22
          , information23
          , information24
          , information25
          , information26
          , information27
          , information28
          , information29
          , information30
   from  pqh_copy_entity_attribs
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   information_category = p_flex;
--
cursor c_candidate is
   select copy_entity_result_id
          , number_of_copies copies
          , information1
          , information2
          , information3
          , information4
          , information5
          , information6
          , information7
          , information8
          , information9
          , information10
          , information11
          , information12
          , information13
          , information14
          , information15
          , information16
          , information17
          , information18
          , information19
          , information20
          , information21
          , information22
          , information23
          , information24
          , information25
          , information26
          , information27
          , information28
          , information29
          , information30
          , information31
          , information32
          , information33
          , information34
          , information35
          , information36
          , information37
          , information38
          , information39
          , information40
          , information41
          , information42
          , information43
          , information44
          , information45
          , information46
          , information47
          , information48
          , information49
          , information50
          , information51
          , information52
          , information53
          , information54
          , information55
          , information56
          , information57
          , information58
          , information59
          , information60
          , information61
          , information62
          , information63
          , information64
          , information65
          , information66
          , information67
          , information68
          , information69
          , information70
          , information71
          , information72
          , information73
          , information74
          , information75
          , information76
          , information77
          , information78
          , information79
          , information80
          , information81
          , information82
          , information83
          , information84
          , information85
          , information86
          , information87
          , information88
          , information89
          , information90,
  information91   ,
  information92   ,
  information93   ,
  information94   ,
  information95   ,
  information96   ,
  information97   ,
  information98   ,
  information99   ,
  information100  ,
  information101  ,
  information102  ,
  information103  ,
  information104  ,
  information105  ,
  information106  ,
  information107  ,
  information108  ,
  information109  ,
  information110  ,
  information111  ,
  information112  ,
  information113  ,
  information114  ,
  information115  ,
  information116  ,
  information117  ,
  information118  ,
  information119  ,
  information120  ,
  information121  ,
  information122  ,
  information123  ,
  information124  ,
  information125  ,
  information126  ,
  information127  ,
  information128  ,
  information129  ,
  information130  ,
  information131  ,
  information132  ,
  information133  ,
  information134  ,
  information135  ,
  information136  ,
  information137  ,
  information138  ,
  information139  ,
  information140  ,
  information141  ,
  information142  ,
  information143  ,
  information144  ,
  information145  ,
  information146  ,
  information147  ,
  information148  ,
  information149  ,
  information150  ,
  information151  ,
  information152  ,
  information153  ,
  information154  ,
  information155  ,
  information156  ,
  information157  ,
  information158  ,
  information159  ,
  information160  ,
  information161  ,
  information162  ,
  information163  ,
  information164  ,
  information165  ,
  information166  ,
  information167  ,
  information168  ,
  information169  ,
  information170  ,
  information171  ,
  information172  ,
  information173  ,
  information174  ,
  information175  ,
  information176  ,
  information177  ,
  information178  ,
  information179  ,
  information180
          , object_version_number
   from pqh_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   number_of_copies  <> 0
   and   result_type_cd     = 'SOURCE'
   for update of copy_entity_result_id;
--
cursor c_attrib(v_table_route_id in number) is
   select upper(pqh_generic.get_alias(att.column_name)) column_alias,
          upper(sat.ddf_column_name) ddf_column_name,
          upper(sat1.ddf_column_name) changeable_column_name,
          sat.context context, -- application_id
          sat1.context context_s1 -- application_id
   from pqh_special_attributes sat,
        pqh_txn_category_attributes tca,
        pqh_transaction_categories tct,
        pqh_attributes att,
        pqh_special_attributes sat1
   where sat.txn_category_attribute_id =  tca.txn_category_attribute_id
   and   tca.attribute_id              =  att.attribute_id
   and   tct.master_table_route_id     =  v_table_route_id
   and   tct.transaction_category_id   =  tca.transaction_category_id
   and   sat.txn_category_attribute_id =  sat1.txn_category_attribute_id
   and   sat.context                   =  sat1.context
   and   sat.context                   =  pqh_gen_form.g_gbl_context
   and   tca.select_flag               = 'Y'
   and   att.enable_flag               = 'Y'
   and   sat.attribute_type_cd         in ('DISPLAY')
   and   sat1.attribute_type_cd        =  'CHANGEABLE'
   and   sat.txn_category_attribute_id not in
   (select txn_category_attribute_id from pqh_special_attributes
    where context = pqh_gen_form.g_gbl_context
    and   attribute_type_cd = 'KEY_FLEX');
--
cursor c_id (p_transaction_category_id in number) is
select  upper(s.ddf_column_name ) ddf_column_name
      , upper(s.ddf_value_column_name ) ddf_value_column_name
      , c.value_set_id
      , s.context context -- application_id
from pqh_special_attributes s
     , pqh_txn_category_attributes c
where s.txn_category_attribute_id = c.txn_category_attribute_id
  and c.transaction_category_id   = p_transaction_category_id
  and s.ddf_column_name          <> 'INFORMATION1'
  and s.attribute_type_cd         = 'DISPLAY'
  and s.context                   = pqh_gen_form.g_gbl_context
  and c.value_set_id             is not null
  and s.ddf_value_column_name    is not null ;
--
    procedure apply_changes
    is
    l_changeable_column_name varchar2(80);
    begin
    hr_utility.set_location(g_package||'Create_target>>apply_changes: Entering',1);
    hr_utility.set_location('Infor 1 '||pqh_gen_form.g_information1,1);
    hr_utility.set_location('Infor 3 '||pqh_gen_form.g_information3,1);
    hr_utility.set_location('Infor 4 '||pqh_gen_form.g_information4,1);
    hr_utility.set_location('C Infor 2 '||pqh_gen_form.c_information2,1);
    for k in 1..180 loop
       for j in nvl(PQH_GEN_FORM.g_attrib_tab.first,0)..nvl(PQH_GEN_FORM.g_attrib_tab.last,-1) loop
          begin
          if pqh_gen_form.g_attrib_tab(j).ddf_column_name = 'INFORMATION'||to_char(k) then
             l_changeable_column_name := pqh_gen_form.g_attrib_tab(j).changeable_column_name ;
             hr_utility.set_location(l_changeable_column_name||'->'||pqh_gen_form.g_attrib_tab(j).ddf_column_name,111);
   --
   -- Bug 5249887: dynamic select into has been failing for some unknown reason; alternative assignment seems to work.
   --             execute immediate 'begin select nvl(pqh_gen_form.c_'||l_changeable_column_name
   --                             ||',pqh_gen_form.g_'||pqh_gen_form.g_attrib_tab(j).ddf_column_name ||') into '
   --                             || 'pqh_gen_form.g_'||pqh_gen_form.g_attrib_tab(j).ddf_column_name
   --                             || ' from fnd_dual where rownum < 2; end;';
                execute immediate 'begin pqh_gen_form.g_'||pqh_gen_form.g_attrib_tab(j).ddf_column_name
                             ||':= nvl(pqh_gen_form.c_'||l_changeable_column_name
                             ||',pqh_gen_form.g_'||pqh_gen_form.g_attrib_tab(j).ddf_column_name ||'); end;';

             hr_utility.set_location( nvl(pqh_gen_form.c_information1,'Info 1')||'='
                                         ||pqh_gen_form.g_attrib_tab(j).ddf_column_name ,112);
             exit;
          end if;
          exception when no_data_found then
              hr_utility.set_location('no data on-'||j,113);
              hr_utility.trace(substr(sqlerrm,1,255));
              hr_utility.trace( 'begin pqh_gen_form.g_'||pqh_gen_form.g_attrib_tab(j).ddf_column_name
                             ||':= nvl(pqh_gen_form.c_'||l_changeable_column_name
                             ||',pqh_gen_form.g_'||pqh_gen_form.g_attrib_tab(j).ddf_column_name ||'); end;');
          end;
       end loop; -- g_attrib_tab scan
    end loop; -- source information scan
    hr_utility.set_location('Infor 1 '||pqh_gen_form.g_information1,1);
    hr_utility.set_location('Infor 3 '||pqh_gen_form.g_information3,1);
    hr_utility.set_location('Infor 4 '||pqh_gen_form.g_information4,1);
    hr_utility.set_location('C Infor 2 '||pqh_gen_form.c_information2,1);
    --l_changeable_column_name := pqh_gen_form.g_attrib_tab(1000).changeable_column_name ;
    hr_utility.set_location(g_package||'Create_target>>apply_changes: Leaving',1);
    end apply_changes ;
    --
    procedure apply_kf (p_flex in varchar2, p_ite in varchar2)
    is
    l_str    varchar2(4000);
    --
    cursor c_sat is
       select sat.ddf_column_name ddf_column_name,
		    to_number(substr(column_name,instr(upper(column_name),'SEGMENT')+7,2)) nos
       from pqh_special_attributes sat,
            pqh_txn_category_attributes tca,
            pqh_attributes att
       where sat.txn_category_attribute_id = tca.txn_category_attribute_id
       and   tca.attribute_id              = att.attribute_id
       and   tca.select_flag               = 'Y'
       and   att.enable_flag               = 'Y'
       and   sat.attribute_type_cd         = 'SEGMENT'
       and   sat.flex_code                 = p_flex
       and   sat.context                   = pqh_gen_form.g_gbl_context
       order by to_number(substr(column_name,instr(column_name,'SEGMENT')+7,2)) ;
    begin
    hr_utility.set_location(g_package||'create_target>>apply_kf: Entering',1);
    --
    for i in c_sat loop
       l_str := l_str ||'pqh_gen_form.g_'||i.ddf_column_name ||' := nvl(pqh_gen_form.k'||p_ite||'_information'||i.nos
				  ||',pqh_gen_form.g_'||i.ddf_column_name ||');';
    end loop;

    if l_str is not null then
        l_str := 'Begin '||l_str||' end;';
        hr_utility.trace(substr(l_str,1,255));
        hr_utility.trace(substr(l_str,256,255));
        hr_utility.trace(substr(l_str,511,255));
        hr_utility.trace(substr(l_str,766,255));
        hr_utility.trace(substr(l_str,1021,255));
        hr_utility.trace(substr(l_str,1276,255));
        hr_utility.trace(substr(l_str,1531,255));
        hr_utility.trace(substr(l_str,1786,255));
        hr_utility.trace(substr(l_str,2041,255));
        hr_utility.trace(substr(l_str,2296,255));
        hr_utility.trace(substr(l_str,2551,255));
        hr_utility.trace(substr(l_str,2806,255));
        hr_utility.trace(substr(l_str,3061,255));
        hr_utility.trace(substr(l_str,3316,255));
        hr_utility.trace(substr(l_str,3571,255));
        hr_utility.trace(substr(l_str,3826,255));
        execute immediate l_str ;
    end if;

    hr_utility.set_location(g_package||'create_target>>apply_kf: Leaving',1);
    end apply_kf;
    --
    procedure apply_special_attrib ( p_txn_category_attribute_id in number
                                   , p_index                     in number
                                   , p_replacement_type_cd       in varchar2
                                   , p_start_with                in varchar2
                                   , p_increment_by              in varchar2) is

                         --         , p_lf1                       in varchar2
                         --         , p_lf2                       in varchar2
                         --         , p_ln1                       in varchar2
                         --         , p_ln2                       in varchar2) is

    --
    l_val           varchar2(2000);
    l_cat_value     varchar2(2000);
    l_str           varchar2(32000);
    l_id_from_value varchar2(200);
    l_fd            varchar2(10);
    l_fn            varchar2(10);
    l_appl_id       number(10);
    l_col           varchar2(100);
    l_number        number(10);
    l_start_with    varchar2(1000) := replace(p_start_with,'''','''''');

    cursor c_sat is
       select upper(st.ddf_column_name) ddf_column_name
             , nvl(upper(st.ddf_value_column_name), upper(st.ddf_column_name)) col_name
             , tc.value_set_id
             , upper(st.ddf_value_column_name) ddf_value_column_name
             , st.attribute_type_cd, st.flex_code
             , pqh_gen_form.get_segment(ata.column_name) segment
          from pqh_special_attributes st,
               pqh_txn_category_attributes tc,
               pqh_attributes ata
          where st.txn_category_attribute_id = tc.txn_category_attribute_id
          and   ata.attribute_id             = tc.attribute_id
          and   st.attribute_type_cd     in ('SEGMENT','DISPLAY')
          and   st.context                   = pqh_gen_form.g_gbl_context
          and   tc.select_flag               = 'Y'
          and   ata.enable_flag              = 'Y'
          and   st.txn_category_attribute_id in
                (select sat.txn_category_attribute_id
                from pqh_special_attributes sat
                where sat.context                   = pqh_gen_form.g_gbl_context
                and   sat.attribute_type_cd         = 'CHANGEABLE'
                and   sat.txn_category_attribute_id = p_txn_category_attribute_id ); -- special_attribute
    --
    cursor c_kf_seg (v_id_fc in varchar2, v_id_fn in varchar2, v_appl_id in number)is
      select application_column_name, segment_num, seg_no, rownum from (
       select application_column_name,
              segment_num,
              to_number(substr(application_column_name, instr(upper(application_column_name),'SEGMENT')+7)) seg_no
	  from fnd_id_flex_segments
	  where id_flex_code   = v_id_fc
	  and   id_flex_num    = v_id_fn
	  and   application_id = v_appl_id
       and   enabled_flag   = 'Y'
       and   display_flag   = 'Y'
       order by segment_num);
    --
    cursor c_col (p_flex in varchar2) is
       select ddf_column_name from pqh_special_attributes
       where  flex_code = p_flex
        and   context = pqh_gen_form.g_gbl_context
        and   attribute_type_cd = 'KEY_FLEX' ;
    begin
    hr_utility.set_location(g_package||'create_target>>apply_special_attribs: Entering',1);
    for rec in c_sat loop
       if p_index = 1 then
          execute immediate 'begin pqh_gen_form.g_initial_value := replace(pqh_gen_form.g_'||rec.col_name|| ','''''''','''''''''''') ; end;';
       end if;
       --
       begin
          if to_number(l_start_with) = 0 or true then
             l_val := nvl(l_start_with, 0) +(p_index-1)* nvl(p_increment_by,0) ;
          end if;
       exception
       when value_error then
             l_val := l_start_with ||to_char((p_index-1)* p_increment_by) ;
       end ;
       --
       if p_replacement_type_cd = 'REPLACE' then
          l_cat_value := nvl(l_val, l_start_with);
       elsif p_replacement_type_cd = 'PREFIX' then
          l_cat_value := l_val || g_initial_value ;
       elsif p_replacement_type_cd = 'SUFFIX' then
          l_cat_value := g_initial_value || l_val ;
       else
		return; -- there is nothing to be done
       end if;
       --
       if rec.ddf_value_column_name is not null and
          rec.value_set_id is not null          then
          l_id_from_value := pqh_gen_form.get_id_from_value(p_value    => l_cat_value
                                                            ,p_vset_id => rec.value_set_id);
          if l_cat_value is not null and
             l_id_from_value is not null then
             execute immediate 'begin pqh_gen_form.g_'||rec.ddf_column_name ||' :='''|| l_id_from_value||''';'||
                               'pqh_gen_form.g_'||rec.ddf_value_column_name ||' :='''|| l_cat_value||'''; end;';
          else
             execute immediate 'begin pqh_gen_form.g_'||rec.ddf_value_column_name||' :='''||g_initial_value||'''; end;';
		   l_warn := '0';
          end if;
       elsif rec.ddf_value_column_name is null and
          l_cat_value is not null then
          execute immediate 'begin pqh_gen_form.g_'||rec.ddf_column_name ||' :='''|| l_cat_value||'''; end;';
       end if;
       --
       if rec.attribute_type_cd = 'SEGMENT' then
          hr_utility.set_location(g_package||'create_target>>apply_special_attribs: Kf segment',5);

          if rec.flex_code = p_lf1 then
             l_fn := p_ln1;
             l_fd := p_ld1;
          elsif rec.flex_code = p_lf2 then
             l_fn := p_ln2;
             l_fd := p_ld2;
          end if;
          if rec.flex_code in ('COST', 'GRP') then
             l_appl_id := 801 ;
          else
             l_appl_id := 800 ;
          end if;
          --
          for a in c_kf_seg(rec.flex_code, l_fn, l_appl_id) loop
             if a.application_column_name = rec.segment then
                l_number := a.rownum ;
                exit;
             end if;
          end loop;
          --
          for a in c_col(rec.flex_code) loop
             l_col := a.ddf_column_name ;
          end loop;
          --

          l_str:=   'a := fnd_flex_ext.breakup_segments (pqh_gen_form.g_'||l_col||','''||l_fd||''', l_ac_seg); '
                  ||'for i in 1..greatest(a,'||to_char(l_number)||') loop '
                  ||'l_ch_seg(i) := null; end loop;'
                  ||'for i in 1..a loop l_ch_seg(i) := l_ac_seg(i); end loop;'
                  ||' hr_utility.set_location(''dyn ac:''|| pqh_gen_form.g_'||l_col||',2001);'
                  ||'l_ch_seg('||to_char(l_number)||') := '''||l_cat_value||'''; '
                  ||'l_val := fnd_flex_ext.concatenate_segments(greatest(a,'||to_char(l_number)
                  ||'), l_ch_seg,'''||l_fd||'''); '
                  ||'pqh_gen_form.g_'||l_col||' := l_val; ';
          --
          l_str:= 'declare j number := 0; l_a varchar2(300); a number; l_val varchar2(2000);'
                ||' l_ac_seg FND_FLEX_EXT.SegmentArray ; l_ch_seg FND_FLEX_EXT.SegmentArray; begin '||l_str||' end;';
          hr_utility.trace(substr(l_str,1,255));
          hr_utility.trace(substr(l_str,256,255));
          hr_utility.trace(substr(l_str,511,255));
          hr_utility.trace(substr(l_str,766,255));
          hr_utility.trace(substr(l_str,1021,255));
          hr_utility.trace(substr(l_str,1276,255));
          hr_utility.trace(substr(l_str,1531,255));
          hr_utility.trace(substr(l_str,1786,255));
          hr_utility.trace(substr(l_str,2041,255));
          hr_utility.trace(substr(l_str,2296,255));
          hr_utility.trace(substr(l_str,2551,255));
          hr_utility.trace(substr(l_str,2806,255));
          hr_utility.trace(substr(l_str,3061,255));
          hr_utility.trace(substr(l_str,3316,255));
          hr_utility.trace(substr(l_str,3571,255));
          hr_utility.trace(substr(l_str,3826,255));

          execute immediate l_str;
          --
       end if ; --attribute is a SEGMENT
    end loop; -- c_sat
    hr_utility.set_location(g_package||'create_target>>apply_special_attrib: Leaving',1);
    end apply_special_attrib;
    --
    procedure concat_segs (p_trt_id in number,  p_flex in varchar2, p_kf_num in varchar2, p_kd  in varchar2)
    is
    l_str     varchar2(32000);
    l_appl_id number(15) ;
    l_ch_seg  FND_FLEX_EXT.SegmentArray ;
    l_ac_seg  FND_FLEX_EXT.SegmentArray ;

    cursor c_sat(v_table_route_id number) is
       select sat.ddf_column_name ddf_column_name,
              substr(pqh_generic.get_alias(column_name)
                    ,instr(upper(pqh_generic.get_alias(column_name)),'SEGMENT')+7) seg_no
       from pqh_special_attributes sat,
            pqh_txn_category_attributes tca,
            pqh_attributes att
       where sat.txn_category_attribute_id = tca.txn_category_attribute_id
       and   tca.attribute_id              = att.attribute_id
       and   att.master_table_route_id     = v_table_route_id
       and   tca.select_flag               = 'Y'
       and   att.enable_flag               = 'Y'
       and   sat.attribute_type_cd         = 'SEGMENT'
       and   sat.flex_code                 = p_flex
       and   sat.context                   = pqh_gen_form.g_gbl_context
       order by to_number(substr(pqh_generic.get_alias(column_name)
                                ,instr(upper(pqh_generic.get_alias(column_name)),'SEGMENT')+7)) ;

    cursor c_flex is
       select ddf_column_name
       from pqh_special_attributes sat,
            pqh_txn_category_attributes tca,
            pqh_attributes att
       where sat.txn_category_attribute_id = tca.txn_category_attribute_id
       and   tca.attribute_id              = att.attribute_id
       and   tca.select_flag               = 'Y'
       and   att.enable_flag               = 'Y'
       and   sat.attribute_type_cd         = 'KEY_FLEX'
       and   sat.flex_code                 = p_flex
       and   sat.context                   = pqh_gen_form.g_gbl_context ;

    cursor c_kf_seg (v_id_fc in varchar2, v_id_fn in varchar2, v_appl_id in number)is
       select application_column_name,
              segment_num,
              to_number(substr(application_column_name, instr(upper(application_column_name),'SEGMENT')+7)) seg_no
	  from fnd_id_flex_segments
	  where id_flex_code   = v_id_fc
	  and   id_flex_num    = v_id_fn
	  and   application_id = v_appl_id
       and   enabled_flag   = 'Y'
       and   display_flag   = 'Y'
       order by segment_num;

    cursor c_change is
       select sat2.ddf_column_name ch_col, sat.ddf_column_name ac_col
       from pqh_special_attributes sat,
            pqh_special_attributes sat2,
            pqh_txn_category_attributes tca,
            pqh_attributes att
       where sat.txn_category_attribute_id = tca.txn_category_attribute_id
       and   sat.txn_category_attribute_id = sat2.txn_category_attribute_id
       and   tca.attribute_id              = att.attribute_id
       and   tca.select_flag               = 'Y'
       and   att.enable_flag               = 'Y'
       and   sat.attribute_type_cd         = 'KEY_FLEX'
       and   sat2.attribute_type_cd        = 'CHANGEABLE'
       and   sat.flex_code                 = p_flex
       and   sat2.context                  = pqh_gen_form.g_gbl_context
       and   sat.context                   = pqh_gen_form.g_gbl_context ;

    begin
    hr_utility.set_location(g_package||'create_target>>concat_segs: Entering',1);

    for l in c_change loop

       l_str:= l_str||'c := fnd_flex_ext.breakup_segments (nvl(pqh_gen_form.c_'||l.ch_col
                    ||',pqh_gen_form.g_'||l.ac_col||'),'''||p_kd||''', l_ch_seg); '
                    ||'a := fnd_flex_ext.breakup_segments (nvl(pqh_gen_form.g_'||l.ac_col
                    ||',pqh_gen_form.c_'||l.ch_col||'),'''||p_kd||''', l_ac_seg); '
                    ||' hr_utility.set_location(''dyn ch:''|| pqh_gen_form.c_'||l.ch_col||',1001);'
                    ||' hr_utility.set_location(''dyn ac:''|| pqh_gen_form.g_'||l.ac_col||',1002);'
                    ||'for z in 1..c loop begin '
                    ||'l_c := nvl(l_ch_seg(z),''$PQH_unq$''); '
                    ||'exception when no_data_found then '
                    ||'l_c := ''$PQH_unq$''; end ; begin '
                    ||'l_a := nvl(l_ac_seg(z),''$PQH_unq$''); '
                    ||'exception when no_data_found then '
                    ||'l_a := ''$PQH_unq$''; end ; '
                    ||'if l_c <> l_a then if l_c <> ''$PQH_unq$'' then '
                    ||'l_ac_seg(z) := l_c; elsif l_a <> ''$PQH_unq$'' then l_ac_seg(z) := l_a; '
                    ||'else  l_ac_seg(z) := null; end if; end if; end loop; '
                    ||'l_val := fnd_flex_ext.concatenate_segments(c, l_ac_seg,'''||p_kd||'''); '
                    ||'pqh_gen_form.g_'||l.ac_col||' := l_val; ';
     end loop;
     --
     if l_str is not null then
     l_str:= 'declare j number := 0; l_a varchar2(300); l_c varchar2(300); a number; c number; l_val varchar2(2000);'
		 ||' l_ch_seg FND_FLEX_EXT.SegmentArray ; l_ac_seg FND_FLEX_EXT.SegmentArray ; begin '||l_str||' end;';
        hr_utility.trace(substr(l_str,1,255));
        hr_utility.trace(substr(l_str,256,255));
        hr_utility.trace(substr(l_str,511,255));
        hr_utility.trace(substr(l_str,766,255));
        hr_utility.trace(substr(l_str,1021,255));
        hr_utility.trace(substr(l_str,1276,255));
        hr_utility.trace(substr(l_str,1531,255));
        hr_utility.trace(substr(l_str,1786,255));
        hr_utility.trace(substr(l_str,2041,255));
        hr_utility.trace(substr(l_str,2296,255));
        hr_utility.trace(substr(l_str,2551,255));
        hr_utility.trace(substr(l_str,2806,255));
        hr_utility.trace(substr(l_str,3061,255));
        hr_utility.trace(substr(l_str,3316,255));
        hr_utility.trace(substr(l_str,3571,255));
        hr_utility.trace(substr(l_str,3826,255));

        execute immediate l_str;
     end if;
/*
This part of code is commented out nocopy as this results is id on kf concat.
The reason why it still remain:
    For reconstructing the rule breaker.

       if p_flex in ('COST', 'GRP') then
          l_appl_id := 801 ;
       else
          l_appl_id := 800 ;
       end if;
       --
       if  p_kd is not null then
          l_str := 'declare j number := 0; l_val varchar2(2000); all_segs FND_FLEX_EXT.SegmentArray ; begin ';
          for k in c_kf_seg (p_flex, p_kf_num, l_appl_id) loop
             for i in c_sat(p_trt_id) loop
                if i.seg_no = k.seg_no then
                   l_str := l_str ||' j:= j+1; all_segs(j):= pqh_gen_form.g_'||i.ddf_column_name||';';
                end if;
             end loop;-- c_sat
          end loop;
          --
		for j in c_flex loop
             l_str := l_str||' l_val := fnd_flex_ext.concatenate_segments(j, all_segs,'''||p_kd||''');'
                           ||' pqh_gen_form.g_'||j.ddf_column_name||' := l_val; end; ';
          end loop;
          --
          hr_utility.trace(substr(l_str,1,2000));
          execute immediate l_str;
       end if; --p_kd
*/
    hr_utility.set_location(g_package||'create_target>>concat_segs: Leaving',1);
    end concat_segs;
    --
begin
  --
  hr_utility.set_location(g_package||'create_target: Entering',1);
  --
  delete from pqh_copy_entity_results
  where result_type_cd     = 'TARGET'
  and   copy_entity_txn_id = p_copy_entity_txn_id;
  --
  for rec in c_txn loop
     l_txn_category_attribute_id  :=  rec.txn_category_attribute_id ;
     l_replacement_type_cd        :=  rec.replacement_type_cd ;
     l_start_with                 :=  rec.start_with ;
     l_increment_by               :=  rec.increment_by ;
     l_mast_trt_id                :=  rec.master_table_route_id ;
     l_transaction_id             :=  rec.transaction_category_id ;
     pqh_gen_form.populate_context(p_copy_entity_txn_id);
     exit ;  -- should ideally loop only once
  end loop ; -- c_txn
  hr_utility.set_location(g_package||'create_target: Clear Table',10);
  --
  PQH_GEN_FORM.g_attrib_tab.delete; -- clear table
  --
  hr_utility.set_location(g_package||'create_target: c_attrib',1);
  hr_utility.set_location('           context: '||pqh_gen_form.g_context,11);
  for rec in c_attrib(l_mast_trt_id) loop
        pqh_gen_form.g_attrib_tab(c_attrib%rowcount).column_alias           := rec.column_alias ;
        pqh_gen_form.g_attrib_tab(c_attrib%rowcount).ddf_column_name        := rec.ddf_column_name ;
        pqh_gen_form.g_attrib_tab(c_attrib%rowcount).changeable_column_name := rec.changeable_column_name ;
  end loop; -- c_attrib
  --
  hr_utility.set_location(g_package||'create_target: c_change',11);
  for rec in c_change loop
      c_information1          := rec.information1  ;
      c_information2          := rec.information2  ;
      c_information3          := rec.information3  ;
      c_information4          := rec.information4  ;
      c_information5          := rec.information5  ;
      c_information6          := rec.information6  ;
      c_information7          := rec.information7  ;
      c_information8          := rec.information8  ;
      c_information9          := rec.information9  ;
      c_information10         := rec.information10 ;
      c_information11         := rec.information11 ;
      c_information12         := rec.information12 ;
      c_information13         := rec.information13 ;
      c_information14         := rec.information14 ;
      c_information15         := rec.information15 ;
      c_information16         := rec.information16 ;
      c_information17         := rec.information17 ;
      c_information18         := rec.information18 ;
      c_information19         := rec.information19 ;
      c_information20         := rec.information20 ;
      c_information21         := rec.information21 ;
      c_information22         := rec.information22 ;
      c_information23         := rec.information23 ;
      c_information24         := rec.information24 ;
      c_information25         := rec.information25 ;
      c_information26         := rec.information26 ;
      c_information27         := rec.information27 ;
      c_information28         := rec.information28 ;
      c_information29         := rec.information29 ;
      c_information30         := rec.information30 ;
      --
      exit ; -- should ideally have only one record.
      --
  end loop ; -- rec in c_change
--for i in 1..30 loop
--  execute immediate 'begin pqh_gen_form.c_information20 := pqh_gen_form.c_information'||i||'; end;';
--  hr_utility.set_location('attrib table: c_information'||i||' '||pqh_gen_form.c_information20,12);
--end loop;
  --
  if p_lf1 is not null then
  for rec in c_ch_kf (p_lf1) loop
     k1_information1          := rec.information1  ;
     k1_information2          := rec.information2  ;
     k1_information3          := rec.information3  ;
     k1_information4          := rec.information4  ;
     k1_information5          := rec.information5  ;
     k1_information6          := rec.information6  ;
     k1_information7          := rec.information7  ;
     k1_information8          := rec.information8  ;
     k1_information9          := rec.information9  ;
     k1_information10         := rec.information10 ;
     k1_information11         := rec.information11 ;
     k1_information12         := rec.information12 ;
     k1_information13         := rec.information13 ;
     k1_information14         := rec.information14 ;
     k1_information15         := rec.information15 ;
     k1_information16         := rec.information16 ;
     k1_information17         := rec.information17 ;
     k1_information18         := rec.information18 ;
     k1_information19         := rec.information19 ;
     k1_information20         := rec.information20 ;
     k1_information21         := rec.information21 ;
     k1_information22         := rec.information22 ;
     k1_information23         := rec.information23 ;
     k1_information24         := rec.information24 ;
     k1_information25         := rec.information25 ;
     k1_information26         := rec.information26 ;
     k1_information27         := rec.information27 ;
     k1_information28         := rec.information28 ;
     k1_information29         := rec.information29 ;
     k1_information30         := rec.information30 ;
      --
      exit ; -- should ideally have only one record.
      --
  end loop ; -- rec in c_ch_kf1
  end if;
  --
  if p_lf2 is not null then
  for rec in c_ch_kf (p_lf2) loop
     k2_information1          := rec.information1  ;
     k2_information2          := rec.information2  ;
     k2_information3          := rec.information3  ;
     k2_information4          := rec.information4  ;
     k2_information5          := rec.information5  ;
     k2_information6          := rec.information6  ;
     k2_information7          := rec.information7  ;
     k2_information8          := rec.information8  ;
     k2_information9          := rec.information9  ;
     k2_information10         := rec.information10 ;
     k2_information11         := rec.information11 ;
     k2_information12         := rec.information12 ;
     k2_information13         := rec.information13 ;
     k2_information14         := rec.information14 ;
     k2_information15         := rec.information15 ;
     k2_information16         := rec.information16 ;
     k2_information17         := rec.information17 ;
     k2_information18         := rec.information18 ;
     k2_information19         := rec.information19 ;
     k2_information20         := rec.information20 ;
     k2_information21         := rec.information21 ;
     k2_information22         := rec.information22 ;
     k2_information23         := rec.information23 ;
     k2_information24         := rec.information24 ;
     k2_information25         := rec.information25 ;
     k2_information26         := rec.information26 ;
     k2_information27         := rec.information27 ;
     k2_information28         := rec.information28 ;
     k2_information29         := rec.information29 ;
     k2_information30         := rec.information30 ;
      --
      exit ; -- should ideally have only one record.
      --
  end loop ; -- rec in c_ch_kf2
  end if;
  --
  hr_utility.set_location(g_package||'create_target: c_candidate',12);
  for rec in c_candidate loop
      g_information1          := rec.information1  ;
      g_information2          := rec.information2  ;
      g_information3          := rec.information3  ;
      g_information4          := rec.information4  ;
      g_information5          := rec.information5  ;
      g_information6          := rec.information6  ;
      g_information7          := rec.information7  ;
      g_information8          := rec.information8  ;
      g_information9          := rec.information9  ;
      g_information10         := rec.information10 ;
      g_information11         := rec.information11 ;
      g_information12         := rec.information12 ;
      g_information13         := rec.information13 ;
      g_information14         := rec.information14 ;
      g_information15         := rec.information15 ;
      g_information16         := rec.information16 ;
      g_information17         := rec.information17 ;
      g_information18         := rec.information18 ;
      g_information19         := rec.information19 ;
      g_information20         := rec.information20 ;
      g_information21         := rec.information21 ;
      g_information22         := rec.information22 ;
      g_information23         := rec.information23 ;
      g_information24         := rec.information24 ;
      g_information25         := rec.information25 ;
      g_information26         := rec.information26 ;
      g_information27         := rec.information27 ;
      g_information28         := rec.information28 ;
      g_information29         := rec.information29 ;
      g_information30         := rec.information30 ;
      g_information31         := rec.information31 ;
      g_information32         := rec.information32 ;
      g_information33         := rec.information33 ;
      g_information34         := rec.information34 ;
      g_information35         := rec.information35 ;
      g_information36         := rec.information36 ;
      g_information37         := rec.information37 ;
      g_information38         := rec.information38 ;
      g_information39         := rec.information39 ;
      g_information40         := rec.information40 ;
      g_information41         := rec.information41 ;
      g_information42         := rec.information42 ;
      g_information43         := rec.information43 ;
      g_information44         := rec.information44 ;
      g_information45         := rec.information45 ;
      g_information46         := rec.information46 ;
      g_information47         := rec.information47 ;
      g_information48         := rec.information48 ;
      g_information49         := rec.information49 ;
      g_information50         := rec.information50 ;
      g_information51         := rec.information51 ;
      g_information52         := rec.information52 ;
      g_information53         := rec.information53 ;
      g_information54         := rec.information54 ;
      g_information55         := rec.information55 ;
      g_information56         := rec.information56 ;
      g_information57         := rec.information57 ;
      g_information58         := rec.information58 ;
      g_information59         := rec.information59 ;
      g_information60         := rec.information60 ;
      g_information61         := rec.information61 ;
      g_information62         := rec.information62 ;
      g_information63         := rec.information63 ;
      g_information64         := rec.information64 ;
      g_information65         := rec.information65 ;
      g_information66         := rec.information66 ;
      g_information67         := rec.information67 ;
      g_information68         := rec.information68 ;
      g_information69         := rec.information69 ;
      g_information70         := rec.information70 ;
      g_information71         := rec.information71 ;
      g_information72         := rec.information72 ;
      g_information73         := rec.information73 ;
      g_information74         := rec.information74 ;
      g_information75         := rec.information75 ;
      g_information76         := rec.information76 ;
      g_information77         := rec.information77 ;
      g_information78         := rec.information78 ;
      g_information79         := rec.information79 ;
      g_information80         := rec.information80 ;
      g_information81         := rec.information81 ;
      g_information82         := rec.information82 ;
      g_information83         := rec.information83 ;
      g_information84         := rec.information84 ;
      g_information85         := rec.information85 ;
      g_information86         := rec.information86 ;
      g_information87         := rec.information87 ;
      g_information88         := rec.information88 ;
      g_information89         := rec.information89 ;
      g_information90         := rec.information90 ;
      g_information91         := rec.information91 ;
      g_information92         := rec.information92 ;
      g_information93         := rec.information93 ;
      g_information94         := rec.information94 ;
      g_information95         := rec.information95 ;
      g_information96         := rec.information96 ;
      g_information97         := rec.information97 ;
      g_information98         := rec.information98 ;
      g_information99         := rec.information99 ;
      g_information100        := rec.information100;
      g_information101        := rec.information101;
      g_information102        := rec.information102;
      g_information103        := rec.information103;
      g_information104        := rec.information104;
      g_information105        := rec.information105;
      g_information106        := rec.information106;
      g_information107        := rec.information107;
      g_information108        := rec.information108;
      g_information109        := rec.information109;
      g_information110        := rec.information110;
      g_information111        := rec.information111;
      g_information112        := rec.information112;
      g_information113        := rec.information113;
      g_information114        := rec.information114;
      g_information115        := rec.information115;
      g_information116        := rec.information116;
      g_information117        := rec.information117;
      g_information118        := rec.information118;
      g_information119        := rec.information119;
      g_information120        := rec.information120;
      g_information121        := rec.information121;
      g_information122        := rec.information122;
      g_information123        := rec.information123;
      g_information124        := rec.information124;
      g_information125        := rec.information125;
      g_information126        := rec.information126;
      g_information127        := rec.information127;
      g_information128        := rec.information128;
      g_information129        := rec.information129;
      g_information130        := rec.information130;
      g_information131        := rec.information131;
      g_information132        := rec.information132;
      g_information133        := rec.information133;
      g_information134        := rec.information134;
      g_information135        := rec.information135;
      g_information136        := rec.information136;
      g_information137        := rec.information137;
      g_information138        := rec.information138;
      g_information139        := rec.information139;
      g_information140        := rec.information140;
      g_information141        := rec.information141;
      g_information142        := rec.information142;
      g_information143        := rec.information143;
      g_information144        := rec.information144;
      g_information145        := rec.information145;
      g_information146        := rec.information146;
      g_information147        := rec.information147;
      g_information148        := rec.information148;
      g_information149        := rec.information149;
      g_information150        := rec.information150;
      g_information151        := rec.information151;
      g_information152        := rec.information152;
      g_information153        := rec.information153;
      g_information154        := rec.information154;
      g_information155        := rec.information155;
      g_information156        := rec.information156;
      g_information157        := rec.information157;
      g_information158        := rec.information158;
      g_information159        := rec.information159;
      g_information160        := rec.information160;
      g_information161        := rec.information161;
      g_information162        := rec.information162;
      g_information163        := rec.information163;
      g_information164        := rec.information164;
      g_information165        := rec.information165;
      g_information166        := rec.information166;
      g_information167        := rec.information167;
      g_information168        := rec.information168;
      g_information169        := rec.information169;
      g_information170        := rec.information170;
      g_information171        := rec.information171;
      g_information172        := rec.information172;
      g_information173        := rec.information173;
      g_information174        := rec.information174;
      g_information175        := rec.information175;
      g_information176        := rec.information176;
      g_information177        := rec.information177;
      g_information178        := rec.information178;
      g_information179        := rec.information179;
      g_information180        := rec.information180;
     --
      l_copies                := rec.copies;
     --
     apply_changes ; -- changes on the ddf
     --
	if p_lf1 is not null then
	   apply_kf(p_lf1, '1');
        concat_segs (l_mast_trt_id,p_lf1, p_ln1, p_ld1)  ;
     end if;
     --
	if p_lf2 is not null then
	   apply_kf(p_lf2, '2');
        concat_segs (l_mast_trt_id,p_lf2, p_ln2, p_ld2)  ;
     end if;
     --
     hr_utility.set_location(g_package||'create_target: l_copies',13);
     for e_rec in c_id(l_transaction_id) loop
           execute immediate 'begin pqh_gen_form.g_'||e_rec.ddf_value_column_name ||':= rtrim('
                           ||'pqh_gen_form.get_value_from_id(pqh_gen_form.g_'||e_rec.ddf_column_name ||','''
                                                            ||e_rec.value_set_id||''')); end;';
           hr_utility.trace('Tgt Loop : '||e_rec.ddf_value_column_name ||' - '||e_rec.ddf_column_name);
     end loop; --c_id
     --
     hr_utility.set_location('Infor 1 '||pqh_gen_form.g_information1,1);
     hr_utility.set_location('Infor 3 '||pqh_gen_form.g_information3,1);
     hr_utility.set_location('Infor 4 '||pqh_gen_form.g_information4,1);
     hr_utility.set_location('C Infor 2 '||pqh_gen_form.c_information2,1);
     for  i in 1..l_copies loop

        hr_utility.set_location('Infor 1 '||pqh_gen_form.g_information1,1);
        hr_utility.set_location('Infor 3 '||pqh_gen_form.g_information3,1);
        hr_utility.set_location('Infor 4 '||pqh_gen_form.g_information4,1);
        hr_utility.set_location('C Infor 2 '||pqh_gen_form.c_information2,1);
        apply_special_attrib ( p_txn_category_attribute_id   => l_txn_category_attribute_id
                               , p_index                     => i
                               , p_replacement_type_cd       => l_replacement_type_cd
                               , p_start_with                => l_start_with
                               , p_increment_by              => l_increment_by);
--                               , p_lf1                       => p_lf1
--                               , p_lf2                       => p_lf2
--                               , p_ln1                       => p_ln1
--                               , p_ln2                       => p_ln2);
        --
        pqh_copy_entity_results_api.create_copy_entity_result
                (
                 p_validate                      => FALSE
                ,p_copy_entity_result_id         => l_copy_entity_result_id
                ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                ,p_result_type_cd                => 'TARGET'
                ,p_number_of_copies              => nvl(l_warn, '1') -- l_warn not null => warnings
                ,p_status                        => 'TGT_P'
                ,p_src_copy_entity_result_id     => rec.copy_entity_result_id
                ,p_information_category          => ''
                ,p_information1                  => g_information1
                ,p_information2                  => g_information2
                ,p_information3                  => g_information3
                ,p_information4                  => g_information4
                ,p_information5                  => g_information5
                ,p_information6                  => g_information6
                ,p_information7                  => g_information7
                ,p_information8                  => g_information8
                ,p_information9                  => g_information9
                ,p_information10                 => g_information10
                ,p_information11                 => g_information11
                ,p_information12                 => g_information12
                ,p_information13                 => g_information13
                ,p_information14                 => g_information14
                ,p_information15                 => g_information15
                ,p_information16                 => g_information16
                ,p_information17                 => g_information17
                ,p_information18                 => g_information18
                ,p_information19                 => g_information19
                ,p_information20                 => g_information20
                ,p_information21                 => g_information21
                ,p_information22                 => g_information22
                ,p_information23                 => g_information23
                ,p_information24                 => g_information24
                ,p_information25                 => g_information25
                ,p_information26                 => g_information26
                ,p_information27                 => g_information27
                ,p_information28                 => g_information28
                ,p_information29                 => g_information29
                ,p_information30                 => g_information30
                ,p_information31                 => g_information31
                ,p_information32                 => g_information32
                ,p_information33                 => g_information33
                ,p_information34                 => g_information34
                ,p_information35                 => g_information35
                ,p_information36                 => g_information36
                ,p_information37                 => g_information37
                ,p_information38                 => g_information38
                ,p_information39                 => g_information39
                ,p_information40                 => g_information40
                ,p_information41                 => g_information41
                ,p_information42                 => g_information42
                ,p_information43                 => g_information43
                ,p_information44                 => g_information44
                ,p_information45                 => g_information45
                ,p_information46                 => g_information46
                ,p_information47                 => g_information47
                ,p_information48                 => g_information48
                ,p_information49                 => g_information49
                ,p_information50                 => g_information50
                ,p_information51                 => g_information51
                ,p_information52                 => g_information52
                ,p_information53                 => g_information53
                ,p_information54                 => g_information54
                ,p_information55                 => g_information55
                ,p_information56                 => g_information56
                ,p_information57                 => g_information57
                ,p_information58                 => g_information58
                ,p_information59                 => g_information59
                ,p_information60                 => g_information60
                ,p_information61                 => g_information61
                ,p_information62                 => g_information62
                ,p_information63                 => g_information63
                ,p_information64                 => g_information64
                ,p_information65                 => g_information65
                ,p_information66                 => g_information66
                ,p_information67                 => g_information67
                ,p_information68                 => g_information68
                ,p_information69                 => g_information69
                ,p_information70                 => g_information70
                ,p_information71                 => g_information71
                ,p_information72                 => g_information72
                ,p_information73                 => g_information73
                ,p_information74                 => g_information74
                ,p_information75                 => g_information75
                ,p_information76                 => g_information76
                ,p_information77                 => g_information77
                ,p_information78                 => g_information78
                ,p_information79                 => g_information79
                ,p_information80                 => g_information80
                ,p_information81                 => g_information81
                ,p_information82                 => g_information82
                ,p_information83                 => g_information83
                ,p_information84                 => g_information84
                ,p_information85                 => g_information85
                ,p_information86                 => g_information86
                ,p_information87                 => g_information87
                ,p_information88                 => g_information88
                ,p_information89                 => g_information89
                ,p_information90                 => g_information90
                ,p_information91                 => g_information91
                ,p_information92                 => g_information92
                ,p_information93                 => g_information93
                ,p_information94                 => g_information94
                ,p_information95                 => g_information95
                ,p_information96                 => g_information96
                ,p_information97                 => g_information97
                ,p_information98                 => g_information98
                ,p_information99                 => g_information99
                ,p_information100                => g_information100
                ,p_information101                => g_information101
                ,p_information102                => g_information102
                ,p_information103                => g_information103
                ,p_information104                => g_information104
                ,p_information105                => g_information105
                ,p_information106                => g_information106
                ,p_information107                => g_information107
                ,p_information108                => g_information108
                ,p_information109                => g_information109
                ,p_information110                => g_information110
                ,p_information111                => g_information111
                ,p_information112                => g_information112
                ,p_information113                => g_information113
                ,p_information114                => g_information114
                ,p_information115                => g_information115
                ,p_information116                => g_information116
                ,p_information117                => g_information117
                ,p_information118                => g_information118
                ,p_information119                => g_information119
                ,p_information120                => g_information120
                ,p_information121                => g_information121
                ,p_information122                => g_information122
                ,p_information123                => g_information123
                ,p_information124                => g_information124
                ,p_information125                => g_information125
                ,p_information126                => g_information126
                ,p_information127                => g_information127
                ,p_information128                => g_information128
                ,p_information129                => g_information129
                ,p_information130                => g_information130
                ,p_information131                => g_information131
                ,p_information132                => g_information132
                ,p_information133                => g_information133
                ,p_information134                => g_information134
                ,p_information135                => g_information135
                ,p_information136                => g_information136
                ,p_information137                => g_information137
                ,p_information138                => g_information138
                ,p_information139                => g_information139
                ,p_information140                => g_information140
                ,p_information141                => g_information141
                ,p_information142                => g_information142
                ,p_information143                => g_information143
                ,p_information144                => g_information144
                ,p_information145                => g_information145
                ,p_information146                => g_information146
                ,p_information147                => g_information147
                ,p_information148                => g_information148
                ,p_information149                => g_information149
                ,p_information150                => g_information150
                ,p_information151                => g_information151
                ,p_information152                => g_information152
                ,p_information153                => g_information153
                ,p_information154                => g_information154
                ,p_information155                => g_information155
                ,p_information156                => g_information156
                ,p_information157                => g_information157
                ,p_information158                => g_information158
                ,p_information159                => g_information159
                ,p_information160                => g_information160
                ,p_information161                => g_information161
                ,p_information162                => g_information162
                ,p_information163                => g_information163
                ,p_information164                => g_information164
                ,p_information165                => g_information165
                ,p_information166                => g_information166
                ,p_information167                => g_information167
                ,p_information168                => g_information168
                ,p_information169                => g_information169
                ,p_information170                => g_information170
                ,p_information171                => g_information171
                ,p_information172                => g_information172
                ,p_information173                => g_information173
                ,p_information174                => g_information174
                ,p_information175                => g_information175
                ,p_information176                => g_information176
                ,p_information177                => g_information177
                ,p_information178                => g_information178
                ,p_information179                => g_information179
                ,p_information180                => g_information180
                ,p_object_version_number         => l_ovn
                ,p_effective_date                => trunc(sysdate)
                );

     end loop; -- 1..rec.number_of_copies
     update pqh_copy_entity_results
     set    status = 'TGT_P'
     where  copy_entity_result_id = rec.copy_entity_result_id;
     --
	if l_warn is not null and p_batch_status is null then
	   p_batch_status := 'WARN';
     end if;
	--
	l_warn := ''; -- reset to no warnings
	--
  end loop; -- c_candidate
hr_utility.set_location(g_package||'create_target: Leaving',1);
exception when others then
p_batch_status := null;
raise;
end create_target;
--
function get_sql_from_vset_id(p_vset_id            in number,
                              p_add_where_clause   in varchar2 default null,
                              p_where_on_id        in boolean  default false )
return varchar2 is
  l_v_r  fnd_vset.valueset_r;
  l_v_dr fnd_vset.valueset_dr;
  l_str  varchar2(4000);
  l_whr  varchar2(4000);
  l_ord  varchar2(4000);
  l_col  varchar2(4000);
begin
--
fnd_vset.get_valueset(valueset_id => p_vset_id ,
                      valueset    => l_v_r,
                      format      => l_v_dr);
--
if l_v_r.table_info.table_name is null then
   return ('');
end if;
--
if l_v_r.table_info.id_column_name is null then
   return ('');
end if;
--
if l_v_r.table_info.value_column_name is null then
   return ('');
end if;
--
if p_add_where_clause is not null then
   if p_where_on_id then
      l_col := substr(l_v_r.table_info.id_column_name,1,instr(l_v_r.table_info.id_column_name||' ', ' '));
   else
      l_col := substr(l_v_r.table_info.value_column_name,1,instr(l_v_r.table_info.value_column_name||' ', ' '));
   end if;
   --
   l_whr := substr(l_v_r.table_info.where_clause||' ',1,
                   instr(upper(l_v_r.table_info.where_clause||' ORDER BY'),'ORDER BY')-1);
   l_ord := substr(l_v_r.table_info.where_clause,
                   instr(upper(l_v_r.table_info.where_clause||'ORDER BY'),'ORDER BY'));

   if instr(upper(l_whr),'WHERE') > 0 then
       l_whr := l_whr||' and '||l_col || p_add_where_clause||' and rownum < 2  ';
   else
      l_whr := 'Where '||l_col || p_add_where_clause||' and rownum < 2 ' ;
   end if;
   l_str := 'select '||l_v_r.table_info.id_column_name||','
                     ||l_v_r.table_info.value_column_name
                     ||' into pqh_gen_form.g_v_id, pqh_gen_form.g_v_value '
                     ||' from '
                     ||l_v_r.table_info.table_name||' '||l_whr;
   --
else
   l_whr := l_v_r.table_info.where_clause ;
   l_str := 'select '||substr(l_v_r.table_info.id_column_name,1,instr(l_v_r.table_info.id_column_name||' ',' '))||','
                     ||substr(l_v_r.table_info.value_column_name,1,instr(l_v_r.table_info.value_column_name||' ',' '))
                     ||' from '
                     ||l_v_r.table_info.table_name||' '||l_whr;
   --
end if;
--
return (l_str);
end get_sql_from_vset_id;
--
function get_value_from_id(p_id      in varchar2,
                           p_vset_id in varchar2) return varchar2 is
l_sql varchar2(4000);
l_cnt number;
begin
pqh_gen_form.g_v_value := '';
if p_id is null then
   return('');
end if;
--
if p_vset_id is null then
   return(p_id);
end if;
--
begin
l_cnt := pqh_gen_form.g_vset_tab.count ;
for j in nvl(PQH_GEN_FORM.g_vset_tab.first,0)..nvl(PQH_GEN_FORM.g_vset_tab.last,-1) loop
   if pqh_gen_form.g_vset_tab(j).vset_id = p_vset_id then
      if pqh_gen_form.g_vset_tab(j).code = p_id then
         return(pqh_gen_form.g_vset_tab(j).meaning);
      end if;
   end if;
end loop;
exception when no_data_found then null; -- in case the table is yet to be populated
end;
--
l_sql := get_sql_from_vset_id(p_vset_id          => p_vset_id,
                              p_add_where_clause => ' = '''||p_id||''''  ,
                              p_where_on_id      => true        );
--
execute immediate 'Begin '||l_sql ||'; end;';
--
pqh_gen_form.g_vset_tab(nvl(l_cnt,0)+1).vset_id := p_vset_id;
pqh_gen_form.g_vset_tab(nvl(l_cnt,0)+1).code    := p_id;
pqh_gen_form.g_vset_tab(nvl(l_cnt,0)+1).meaning := pqh_gen_form.g_v_value;
--
return(pqh_gen_form.g_v_value);
--
exception
when no_data_found then
    pqh_gen_form.g_v_id := '';
    pqh_gen_form.g_v_value := '';
    return(''); --Modified for bug 7411098
when others then
    pqh_gen_form.g_v_id := '';
    pqh_gen_form.g_v_value := '';
    return(p_id||'-'||substr(sqlerrm,1,125));
    --raise ;
end get_value_from_id;
--
function get_id_from_value(p_value   in varchar2,
                           p_vset_id in varchar2) return varchar2 is
l_sql varchar2(4000);
begin
if p_value is null then
   return('');
end if;
--
if p_vset_id is null then
   return(p_value);
end if;
--
l_sql := get_sql_from_vset_id(p_vset_id          => p_vset_id,
                              p_add_where_clause => ' = '''||p_value ||''''  ,
                              p_where_on_id      => false       );
--
execute immediate 'Begin '||l_sql ||'; end;';
--
return(pqh_gen_form.g_v_id);
--
exception
when no_data_found then
    pqh_gen_form.g_v_id := '';
    pqh_gen_form.g_v_value := '';
    return('');
when others then
    pqh_gen_form.g_v_id := '';
    pqh_gen_form.g_v_value := '';
    return('');
    --raise ;
end get_id_from_value;
--
function populate_prefs(p_copy_entity_txn_id       in number
                       , p_transaction_category_id in number ) return boolean
is
l_ovn number;
--
cursor c_tab is
   select distinct tr.table_route_id, tr.display_name
      from  pqh_table_route tr
            , pqh_attributes_vl a
            , pqh_txn_category_attributes c
            , pqh_transaction_categories cat
      where a.master_table_route_id     = tr.table_route_id
      and   a.attribute_id              = c.attribute_id
      and   tr.table_route_id           <> cat.master_table_route_id
      and   cat.transaction_category_id = c.transaction_category_id
      and   c.select_flag               = 'Y'
      and   a.enable_flag               = 'Y'
      and   c.transaction_category_id   = nvl(p_transaction_category_id,-99);

   --
cursor c_check is
   select null from pqh_copy_entity_prefs where copy_entity_txn_id = nvl(p_copy_entity_txn_id,-99);
--
begin
--
for i in c_check loop
   return true;
end loop;

for rec in c_tab loop
    pqh_copy_entity_prefs_api.create_copy_entity_pref (
                  p_validate                 => false
                 ,p_copy_entity_pref_id      => l_ovn
                 ,p_table_route_id           => rec.table_route_id
                 ,p_copy_entity_txn_id       => p_copy_entity_txn_id
                 ,p_select_flag              => 'Y'
                 ,p_object_version_number    => l_ovn
                 ,p_effective_date           => trunc(sysdate) );

end loop;  -- rec in tab
--
if l_ovn is null then
   return(false);
else
   return(true);
end if;
--
end populate_prefs;
--
function get_legislation_code (p_business_group_id in varchar2) return varchar2
is
cursor c_leg is
   select legislation_code from per_business_groups
   where business_group_id = nvl(p_business_group_id, -99) ;
begin
  for i in c_leg loop
     return(i.legislation_code);
  end loop;
  --
  return('NULL');
  --
end get_legislation_code;
--
function get_alr(p_application_id          in  number
                ,p_responsibility_id       in  number
                ,p_business_group_id       in  varchar2
                ,p_transaction_short_name  in  varchar2
                ,p_application_short_name  out nocopy varchar2
                ,p_legislation_code        out nocopy varchar2
                ,p_responsibility_key      out nocopy varchar2
                ,p_gbl_context             out nocopy varchar2   )   return varchar2
is

cursor c_one is
    select context
           ,application_short_name
           ,legislation_code
           ,responsibility_key
    from   pqh_copy_entity_contexts
    where  transaction_short_name = p_transaction_short_name ;

cursor c_gbl is
    select context
    from   pqh_copy_entity_contexts
    where  transaction_short_name = p_transaction_short_name    -- +++ ENSURE index on txn_short_name +++
    and    nvl(upper(application_short_name), 'NULL') = 'NULL'
    and    nvl(upper(legislation_code)      , 'NULL') = 'NULL'
    and    nvl(upper(responsibility_key)    , 'NULL') = 'NULL';

cursor c_appl is
    select application_short_name
    from   fnd_application
    where  application_id = p_application_id ;

cursor c_resp is
    select responsibility_key
    from   fnd_responsibility
    where  responsibility_id = p_responsibility_id ;
begin
   hr_utility.set_location('Entering alr : ',100);
   --
   -- get application short name to determine context
   --
   for i in c_appl loop
      p_application_short_name := i.application_short_name ;
   end loop;
   hr_utility.set_location('         a   : '||p_application_short_name ,100);
   --
   -- get legislation_code to help determine context
   --
   p_legislation_code := pqh_gen_form.get_legislation_code(p_business_group_id);
   hr_utility.set_location('          l  : '||p_legislation_code ,100);
   --
   -- read responsibility short name to facilitate deriving context
   --
   for i in c_resp loop
      p_responsibility_key := i.responsibility_key ;
   end loop;
   hr_utility.set_location('          r  : '||p_responsibility_key ,100);
   --
   for rec in c_gbl loop
       p_gbl_context              := rec.context ;
       pqh_gen_form.g_txn_name    := p_transaction_short_name ;
       pqh_gen_form.g_gbl_context := rec.context ;
   end loop; --c_gbl
   --
   for i in c_one loop
      --
      if nvl(i.application_short_name, 'NULL') = p_application_short_name  and
         nvl(i.legislation_code      , 'NULL') = p_legislation_code        and
         nvl(i.responsibility_key    , 'NULL') = p_responsibility_key      then
         p_application_short_name := i.application_short_name ;
         p_legislation_code       := i.legislation_code ;
         p_responsibility_key     := i.responsibility_key ;
         pqh_gen_form.g_context   := i.context;
         return (i.context);
      end if ; -- alr
   end loop; --c_one
      --
   for i in c_one loop
      if nvl(i.application_short_name  , 'NULL') = p_application_short_name  and
         nvl(upper(i.legislation_code) , 'NULL') = 'NULL'                    and
         nvl(i.responsibility_key      , 'NULL') = p_responsibility_key      then
         p_application_short_name := i.application_short_name ;
         p_legislation_code       := 'NULL' ;
         p_responsibility_key     := i.responsibility_key ;
         pqh_gen_form.g_context   := i.context;
         return (i.context);
      end if ; -- a r
   end loop; --c_one
      --
   for i in c_one loop
      if nvl(upper(i.application_short_name), 'NULL') = 'NULL'                    and
         nvl(i.legislation_code             , 'NULL') = p_legislation_code        and
         nvl(i.responsibility_key           , 'NULL') = p_responsibility_key      then
         p_application_short_name := 'NULL';
         p_legislation_code       := i.legislation_code ;
         p_responsibility_key     := i.responsibility_key ;
         pqh_gen_form.g_context   := i.context;
         return (i.context);
      end if ; --  lr
   end loop; --c_one
      --
   for i in c_one loop
      if nvl(i.application_short_name    , 'NULL') = p_application_short_name  and
         nvl(i.legislation_code          , 'NULL') = p_legislation_code        and
         nvl(upper(i.responsibility_key) , 'NULL') = 'NULL'                    then
         p_application_short_name := i.application_short_name ;
         p_legislation_code       := i.legislation_code ;
         p_responsibility_key     := 'NULL' ;
         pqh_gen_form.g_context   := i.context;
         return (i.context);
      end if ; -- al
   end loop; --c_one
      --
   for i in c_one loop
      if nvl(upper(i.application_short_name), 'NULL') = 'NULL'                  and
         nvl(upper(i.legislation_code)      , 'NULL') = 'NULL'                  and
         nvl(i.responsibility_key           , 'NULL') = p_responsibility_key    then
         p_application_short_name := 'NULL' ;
         p_legislation_code       := 'NULL' ;
         p_responsibility_key     := i.responsibility_key ;
         pqh_gen_form.g_context   := i.context;
         return (i.context);
      end if ; --   r
   end loop; --c_one
      --
   for i in c_one loop
      if nvl(upper(i.application_short_name), 'NULL') = 'NULL'             and
         nvl(i.legislation_code             , 'NULL') = p_legislation_code and
         nvl(upper(i.responsibility_key)    , 'NULL') = 'NULL'             then
         p_application_short_name := 'NULL' ;
         p_legislation_code       := i.legislation_code ;
         p_responsibility_key     := 'NULL' ;
         pqh_gen_form.g_context   := i.context;
         return (i.context);
      end if ; --  l
   end loop; --c_one
      --
   for i in c_one loop
      if nvl(i.application_short_name    , 'NULL') = p_application_short_name  and
         nvl(upper(i.legislation_code)   , 'NULL') = 'NULL'                    and
         nvl(upper(i.responsibility_key) , 'NULL') = 'NULL'                    then
         p_application_short_name := i.application_short_name ;
         p_legislation_code       := 'NULL' ;
         p_responsibility_key     := 'NULL' ;
         pqh_gen_form.g_context   := i.context;
         return (i.context);
      end if ; -- a
   end loop; --c_one
      --
   for i in c_one loop
      if nvl(upper(i.application_short_name), 'NULL') = 'NULL'  and
         nvl(upper(i.legislation_code)      , 'NULL') = 'NULL'  and
         nvl(upper(i.responsibility_key)    , 'NULL') = 'NULL'  then
         p_application_short_name := 'NULL' ;
         p_legislation_code       := 'NULL' ;
         p_responsibility_key     := 'NULL' ;
         pqh_gen_form.g_context   := i.context;
         return (i.context);
      end if ; -- null (global)

   end loop; --c_one
   --
   hr_utility.set_location('Leaving alr : ',100);
   exception when others then
p_application_short_name  := null;
p_legislation_code        := null;
p_responsibility_key      := null;
p_gbl_context             := null;
raise;
end get_alr;
--
procedure populate_context(p_copy_entity_txn_id in number)
is
cursor c_txn is
   select short_name, context
   from pqh_copy_entity_txns cet,
        pqh_transaction_categories tct
   where cet.transaction_category_id = tct.transaction_category_id
   and   cet.copy_entity_txn_id      = p_copy_entity_txn_id ;
--
cursor c_gbl(v_context in varchar2) is
    select ce1.context
    from   pqh_copy_entity_contexts ce1, pqh_copy_entity_contexts ce2
    where  ce1.transaction_short_name = ce2.transaction_short_name
    and    ce2.context                = v_context
    and    nvl(upper(ce1.application_short_name), 'NULL') = 'NULL'
    and    nvl(upper(ce1.legislation_code)      , 'NULL') = 'NULL'
    and    nvl(upper(ce1.responsibility_key)    , 'NULL') = 'NULL';
begin
if pqh_gen_form.g_context is null then
   for i in c_txn loop
       pqh_gen_form.g_context := i.context ;
   end loop;
end if;
--
if pqh_gen_form.g_gbl_context is null then
   for i in c_gbl(pqh_gen_form.g_context) loop
       pqh_gen_form.g_gbl_context := i.context ;
   end loop;
end if;
end;
--
procedure chk_transaction_category (p_short_name              in out nocopy varchar2,
                                    p_transaction_category_id in out nocopy varchar2,
                                    p_transaction_id          in     varchar2,
                                    p_member_cd                  out nocopy varchar2,
                                    p_name                       out nocopy varchar2)
is
cursor c_short_name is
  select transaction_category_id,
         member_cd,
         name
  from pqh_transaction_categories_vl
  where short_name = p_short_name
  and   business_group_id is null ;
--
cursor c_txn_cat_id is
  select short_name,
         member_cd,
         name
  from pqh_transaction_categories_vl
  where transaction_category_id = p_transaction_category_id;
--
cursor c_txn_id is
   select transaction_category_id
   from pqh_copy_entity_txns
   where copy_entity_txn_id = p_transaction_id ;

l_short_name varchar2(30) := p_short_name;
l_transaction_category_id number := p_transaction_category_id;
begin
  if p_transaction_id is not null then
     for i in c_txn_id loop
         p_transaction_category_id := i.transaction_category_id ;
     end loop;
  end if;
  --
  if p_short_name is not null then
     for i in c_short_name loop
         p_transaction_category_id := i.transaction_category_id ;
         p_member_cd               := i.member_cd ;
         p_name                    := i.name ;
     end loop;
  elsif p_transaction_category_id is not null then
     for i in c_txn_cat_id loop
         p_short_name := i.short_name ;
         p_member_cd  := i.member_cd ;
         p_name       := i.name ;
     end loop;
  end if;
exception when others then
p_short_name              := l_short_name;
p_transaction_category_id := l_transaction_category_id;
p_member_cd               := null;
p_name			  := null;
raise;
end chk_transaction_category;
--
function get_transaction_type (p_transaction_category_id in number
                              , p_context                in varchar2)
return varchar2
is
cursor c_tran is
   select function_type_cd
   from   pqh_transaction_categories tct
          ,pqh_copy_entity_functions cef
   where  tct.master_table_route_id   = cef.table_route_id
   and    cef.context                 = p_context
   and    tct.transaction_category_id = p_transaction_category_id ;
begin
   for i in c_tran loop
      return i.function_type_cd;
   end loop;
return ('NULL');
end get_transaction_type;
--
function my_con return varchar2 is
begin
--
return (pqh_gen_form.g_context);
--
end;
--
function get_look (p_code in varchar2) return varchar2
is
--
cursor c_look is
  select meaning from hr_lookups
  where lookup_type = 'PQH_GEN_LOV'
  and   lookup_code = nvl(p_code,'NULL');
--
begin
  if p_code = g_code then
     return g_meaning ;
  end if;
  --
  for i in c_look loop
     g_code := p_code ;
     g_meaning := i.meaning ;
	return (i.meaning);
  end loop;
  --
  return('');
end;
--
function  kf(p_string    in varchar2 ,
             p_delimiter in varchar2 ) return varchar2 is
--
   l_xname      varchar2(240);
   l_name       varchar2(240);
   l_start      number;
   l_end        number;
   l_delimiter  varchar2(1)   := p_delimiter ;
   l_2delimiter varchar2(2);
--
begin
if l_delimiter is not null then
  l_xname := p_string;

  l_2delimiter := l_delimiter || l_delimiter ;
  if substr( l_xname, 1, 1) = l_delimiter then
    l_xname := '%' || l_xname;
  end if;
  while true
  loop
    if instr(l_xname, l_2delimiter) <> 0 then
      l_name := substr(l_xname, 1, to_number(instr(l_xname, l_2delimiter)) );
      l_name := l_name || '%' ;
      l_start :=  instr(l_xname, l_2delimiter) + 1;
      l_end := length(l_xname) - instr(l_xname, l_2delimiter);
      l_name := l_name || substr( l_xname, l_start, l_end);
      l_xname := l_name;
    else
      exit;
    end if;
  end loop;
  if substr( l_xname, length(l_xname), 1) = l_delimiter then
    l_xname := l_xname || '%';
  end if;
  return(l_xname);
end if;
--
return(p_string);
end kf;
--
procedure delete_source (p_validate                in boolean
				    , p_copy_entity_result_id  in number
				    , p_object_version_number  in number
				    , p_effective_date         in date)
is
l_ovn number := p_object_version_number;
  cursor c_tgt is
	select copy_entity_result_id, object_version_number
	from pqh_copy_entity_results
	where src_copy_entity_result_id = p_copy_entity_result_id ;
begin
   for i in c_tgt loop
    pqh_copy_entity_results_api.delete_copy_entity_result
	     (p_validate => FALSE
	     ,p_copy_entity_result_id => i.copy_entity_result_id
	     ,p_object_version_number => i.object_version_number
	     ,p_effective_date        => p_effective_date );
    end loop;
    --
    pqh_copy_entity_results_api.delete_copy_entity_result
          (p_validate              => p_validate
	     ,p_copy_entity_result_id => p_copy_entity_result_id
	     ,p_object_version_number => l_ovn
	     ,p_effective_date        => p_effective_date );

end delete_source;
--
procedure flip_selection (p_mode                  in varchar2,
					 p_copy_entity_txn_id    in number  ,
					 p_copy_entity_result_id in number   default null ,
					 p_block                 in varchar2 default 'SOURCE',
					 p_select_value          in varchar2  )
is
begin
--
if p_mode = 'INVERT' then
   update pqh_copy_entity_results
   set number_of_copies = decode(number_of_copies,0, nvl(p_select_value,1), 0)
   where copy_entity_txn_id    = p_copy_entity_txn_id
   --and   src_copy_entity_result_id = nvl(p_copy_entity_result_id, -99)
   and   nvl(src_copy_entity_result_id,-99) = nvl(p_copy_entity_result_id, nvl(src_copy_entity_result_id,-99))
   and   status          not in ('COMPLETED', 'DPT_ERR')
   and   result_type_cd        = p_block ;
elsif p_mode = 'NONE' then
   update pqh_copy_entity_results
   set number_of_copies = 0
   where copy_entity_txn_id    = p_copy_entity_txn_id
   and   nvl(src_copy_entity_result_id,-99) = nvl(p_copy_entity_result_id, nvl(src_copy_entity_result_id,-99))
   and   status          not in ('COMPLETED', 'DPT_ERR')
   and   result_type_cd        = p_block ;
elsif p_mode = 'ALL' then
   update pqh_copy_entity_results
   set number_of_copies =  nvl(p_select_value,1)
   where copy_entity_txn_id    = p_copy_entity_txn_id
   and   nvl(src_copy_entity_result_id,-99) = nvl(p_copy_entity_result_id, nvl(src_copy_entity_result_id,-99))
   and   status          not in ('COMPLETED', 'DPT_ERR')
   and   result_type_cd        = p_block ;
end if;
--
end flip_selection;
--
function check_id_flex_struct ( p_id_flex_code varchar2,
                                p_id_flex_num  number ) return boolean is
--
-- declare cursor
--
cursor get_flex_struct IS
select
	'Y'
from    fnd_compiled_id_flex_structs fcf,
        fnd_id_flex_structures fs
where  fcf.id_flex_code	= p_id_flex_code
and    fcf.id_flex_num	= p_id_flex_num
and    fs.id_flex_code	= fcf.id_flex_code
and    fs.id_flex_num	= fcf.id_flex_num
and    fs.dynamic_inserts_allowed_flag = 'Y';
--
l_struct_exists varchar2(1) := 'N';
--
BEGIN
--
-- get flex struct
--
  open  get_flex_struct;
  fetch get_flex_struct into l_struct_exists;
  close get_flex_struct;
--
-- check flex struct
--
  if (l_struct_exists = 'Y') then
      return TRUE;
  else
      return FALSE;
  end if;
--
end check_id_flex_struct;
--
function context_bg return varchar2
is
--
cursor c_bg is
   select context_business_group_id
   from pqh_copy_entity_txns
   where copy_entity_txn_id = pqh_gen_form.g_txn_id;
begin

if pqh_gen_form.g_txn_id is not null then
  if g_private_txn_id is not null and
     g_private_bg_id  is not null and
     g_private_txn_id = pqh_gen_form.g_txn_id then

      return (g_private_bg_id) ;
  end if;
  --
  for i in c_bg loop
    g_private_bg_id  := i.context_business_group_id;
    g_private_txn_id := pqh_gen_form.g_txn_id;
    return (i.context_business_group_id);
  end loop;
end if;

end context_bg;
--
procedure set_txn_id (p_txn_id in number) is
begin
   pqh_gen_form.g_txn_id := p_txn_id ;

end ;
--
procedure set_dt (p_dt_mode in varchar2, p_dt_desc in varchar2) is
  l_upd   boolean := true;
  l_updt  boolean := true;
  cursor c_dt (p_type in varchar2) is
    select ddf_column_name, ddf_value_column_name
    from Pqh_special_attributes s
	   ,pqh_txn_category_attributes c
	   ,pqh_attributes a
    where a.attribute_id = c.attribute_id
    and   c.txn_category_attribute_id = s.txn_category_attribute_id
    and   a.enable_flag = 'Y'
    and   c.select_flag = 'Y'
    and   s.context     = pqh_gen_form.g_gbl_context
    and   s.attribute_type_cd = p_type
    and   a.column_name like 'DATETRACK_MODE'
    and   s.ddf_column_name is not null;
    --
begin
    for i in c_dt('DISPLAY') loop
	  if i.ddf_value_column_name is not null then
       execute immediate 'update pqh_copy_entity_results set '||i.ddf_value_column_name||' = '''||p_dt_desc
				   ||''' where copy_entity_txn_id = '||to_char(pqh_gen_form.g_txn_id)
				   ||' and result_type_cd = ''TARGET'''
				   ||' and number_of_copies = 1 and status in (''TGT_P'',''TGT_ERR'')' ;
       end if;
       execute immediate 'update pqh_copy_entity_results set '||i.ddf_column_name||' = '''||p_dt_mode
				   ||''' where copy_entity_txn_id = '||to_char(pqh_gen_form.g_txn_id)
				   ||' and result_type_cd = ''TARGET'''
				   ||' and number_of_copies = 1 and status in (''TGT_P'',''TGT_ERR'')' ;

       l_upd := FALSE;
    end loop; --c_dt
    --
    if l_upd then
    for i in c_dt('SELECT') loop
	  if i.ddf_value_column_name is not null then
       execute immediate 'update pqh_copy_entity_results set '||i.ddf_value_column_name||' = '''||p_dt_desc
				   ||''' where copy_entity_txn_id = '||to_char(pqh_gen_form.g_txn_id)
				   ||' and result_type_cd = ''TARGET'''
				   ||' and number_of_copies = 1 and status in (''TGT_P'',''TGT_ERR'')' ;
       end if;
       execute immediate 'update pqh_copy_entity_results set '||i.ddf_column_name||' = '''||p_dt_mode
				   ||''' where copy_entity_txn_id = '||to_char(pqh_gen_form.g_txn_id)
				   ||' and result_type_cd = ''TARGET'''
				   ||' and number_of_copies = 1 and status in (''TGT_P'',''TGT_ERR'')' ;

       l_upd := FALSE;
    end loop; --c_dt
    end if;
    --
    if l_upd then
    for i in c_dt('PARAMETER') loop
	  if i.ddf_value_column_name is not null then
       execute immediate 'update pqh_copy_entity_results set '||i.ddf_value_column_name||' = '''||p_dt_desc
				   ||''' where copy_entity_txn_id = '||to_char(pqh_gen_form.g_txn_id)
				   ||' and result_type_cd = ''TARGET'''
				   ||' and number_of_copies = 1 and status in (''TGT_P'',''TGT_ERR'')' ;
       end if;
       execute immediate 'update pqh_copy_entity_results set '||i.ddf_column_name||' = '''||p_dt_mode
				   ||''' where copy_entity_txn_id = '||to_char(pqh_gen_form.g_txn_id)
				   ||' and result_type_cd = ''TARGET'''
				   ||' and number_of_copies = 1 and status in (''TGT_P'',''TGT_ERR'')' ;

       l_upd := FALSE;
    end loop; --c_dt
    end if;
    --
end set_dt;
--
function check_valueset_type (p_valueset_id in varchar2) return varchar2 is

cursor c_vset is
   select validation_type
   from fnd_flex_value_sets
   where flex_value_set_id = p_valueset_id;
begin

--return if valueset id is null
if p_valueset_id is null then
   return 'Y' ;
end if;

hr_utility.set_location('value of valueset_id : '||p_valueset_id, 11);
for i in c_vset loop
   if i.validation_type in ('N') then -- , 'I') then (commented I..can be taken up for enhancement)
      return 'Y';
   end if;
end loop;

return 'N';

end check_valueset_type;
--
function get_segment(p_col in varchar2) return varchar2 is
l_col varchar2(200) ;
begin

l_col := upper(p_col);
l_col := rtrim(substr(l_col,instr(l_col,'SEGMENT'),instr(substr(l_col, instr(l_col, 'SEGMENT'))||' ',' ')));
return (substr(l_col,1,instr(l_col||'_','_')-1));

end get_segment;
--
END PQH_GEN_FORM;

/
