--------------------------------------------------------
--  DDL for Package Body PQH_GENERIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GENERIC" as
/* $Header: pqgnfnb.pkb 120.3 2006/05/02 03:04:19 ghshanka noship $ */
--
-- Created by : Sanej Nair (SCNair)
--  Version Date        Author         Comment
--  -------+-----------+--------------+---------------------------------------+
--  115.1  27-Feb-2000 Sanej Nair     Initial Version
--  ==========================================================================
-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+
--
g_package       varchar2(33)   := '  PQH_GENERIC.';  -- Global package name
-- added for the bug 5052820
--
l_eff_date date ;
upd_where varchar2(1) :='N';
--
-- end of bug 5052820
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< generic_fn >-------------------------------|
-- ---------------------------------------------------------------------------+
--
-- Description:
--    This handles transactions like Positions copy, Jobs updates etc.
--
-- Access Status:
--   Internal Use Only.
--
Procedure generic_fn( p_copy_entity_txn_id       in  number ,
                      p_master_required_flag     in  varchar2 default 'Y' ) is
  --
  -- local variables
  --
  l_proc                    varchar2(72) := g_package||'generic_fn';
  l_reset_flag              varchar2(10) ;
  l_cet                     number       ;
  l_cer1                    number       ;
  l_cer2                    number       ;
  l_status                  pqh_copy_entity_txns.status%TYPE;
  l_transaction_category_id pqh_transaction_categories.transaction_category_id%TYPE;
  l_transaction_short_name  pqh_transaction_categories.short_name%TYPE;
  l_name                    pqh_copy_entity_txns.display_name%TYPE;
  l_master_table_route_id   pqh_table_route.table_route_id%TYPE;
  l_effective_date          varchar2(30); -- would hold date in char format
  l_function_context        pqh_copy_entity_contexts.context%TYPE;
  l_context                 pqh_copy_entity_txns.context%TYPE;
  l_function_type_cd        pqh_copy_entity_functions.function_type_cd%TYPE;
  l_pre_copy_function_name  pqh_copy_entity_functions.pre_copy_function_name%TYPE;
  l_copy_function_name      pqh_copy_entity_functions.copy_function_name%TYPE;
  l_post_copy_function_name pqh_copy_entity_functions.post_copy_function_name%TYPE;
  l_dt_mode varchar2(50):=null;
  --
  -- cursor for master table id
  --
  cursor c_info (v_copy_entity_txn_id number) is
     select   tct.transaction_category_id
              , cet.copy_entity_txn_id
              , tct.short_name
              , cet.display_name name
		    , cet.datetrack_mode dt_mode
              , tct.master_table_route_id
              , to_char(nvl(cet.src_effective_date,sysdate),'RRRR/MM/DD HH24:MI:SS') effective_date
              , cet.context  -- application_id
              , cec.context gbl_context
     from     pqh_copy_entity_txns cet
              , pqh_transaction_categories_vl tct
              , pqh_copy_entity_contexts cec
     where    tct.transaction_category_id  = cet.transaction_category_id
     and      cec.transaction_short_name   = tct.short_name
     and      cec.application_short_name   is null
     and      cec.legislation_code         is null
     and      cec.responsibility_key       is null
     and      cet.copy_entity_txn_id = v_copy_entity_txn_id
     for  update of copy_entity_txn_id;
  --
  -- Cursor for table details
  --
  cursor c_tab_details(v_table_route_id      number ) is
     select  trt.from_clause
             , trt.where_clause
             , trt.table_alias
     from    pqh_table_route trt
     where   trt.table_route_id = v_table_route_id;
  --
  -- Cursor for dependent table details
  --
  cursor c_dep_details(v_copy_entity_txn_id  number) is
     select  trt.from_clause
             , trt.table_route_id
             , trt.where_clause
             , trt.table_alias
     from    pqh_table_route trt
             , pqh_copy_entity_prefs cep
     where   cep.copy_entity_txn_id      = v_copy_entity_txn_id
     and     cep.table_route_id          = trt.table_route_id
     and     cep.select_flag             = 'Y' ;
  --
  -- Cursor for all selected target records
  --
  cursor c_target is
     select cer.* , src.information1 src_information1
     from   pqh_copy_entity_results cer ,
            pqh_copy_entity_results src
     where  cer.copy_entity_txn_id        = p_copy_entity_txn_id
	and    cer.src_copy_entity_result_id = src.copy_entity_result_id
     and    src.number_of_copies <> 0
     and    cer.number_of_copies =  1
     and    cer.result_type_cd   = 'TARGET'
	order  by cer.src_copy_entity_result_id;  -- to group targets by source.
--	for update of cer.status ; ora 1002 out of sequence error.

  --
  -- Cursor for transaction attributes
  --
  cursor c_attribs(v_copy_entity_txn_id number,v_table_route_id number,v_attribute_type varchar2) is
	select  upper(att.column_name) column_name
             , upper(att.column_type) column_type
             , upper(sat.ddf_column_name) ddf_column_name
     from    pqh_attributes att
             , pqh_special_attributes sat
             , pqh_txn_category_attributes tca
             , pqh_copy_entity_txns cet
     where   att.attribute_id              = tca.attribute_id
     and     att.master_table_route_id     = v_table_route_id
     and     tca.txn_category_attribute_id = sat.txn_category_attribute_id
     and     cet.transaction_category_id   = tca.transaction_category_id
     and     sat.attribute_type_cd         = v_attribute_type
     and     cet.copy_entity_txn_id        = v_copy_entity_txn_id
     and     sat.ddf_column_name          is not null
     and     att.enable_flag               = 'Y'
     and     tca.select_flag               = 'Y'
     and     sat.enable_flag               = 'Y'
     and     sat.context                   = pqh_generic.g_gbl_context; --application_id
     --and     cet.context                   = sat.context; --application_id
  --
  -- Cursor for changeable attributes
  --
  cursor c_change(v_copy_entity_txn_id number, v_table_route_id number) is
     select  pqh_generic.get_alias(upper(att.column_name)) column_name
             , upper(att.column_type) column_type
             , upper(sat1.ddf_column_name) ddf_column_name
             , sat1.context context
             , sat.context context_s
     from    pqh_attributes att
             , pqh_special_attributes sat
             , pqh_special_attributes sat1
             , pqh_txn_category_attributes tca
             , pqh_copy_entity_txns cet
     where   att.attribute_id              = tca.attribute_id
     and     att.master_table_route_id     = v_table_route_id
     and     tca.txn_category_attribute_id = sat.txn_category_attribute_id
     and     cet.transaction_category_id   = tca.transaction_category_id
     and     sat.attribute_type_cd         = 'CHANGEABLE'
     and     sat1.attribute_type_cd       in ('DISPLAY','SEGMENT')
     and     sat.txn_category_attribute_id = sat1.txn_category_attribute_id
     and     att.enable_flag               = 'Y'
     and     tca.select_flag               = 'Y'
     and     sat.enable_flag               = 'Y'
     and     sat1.enable_flag              = 'Y'
     and     cet.copy_entity_txn_id        = v_copy_entity_txn_id
     and     sat.context                   = sat1.context -- application_id
     and     sat.context                   = pqh_generic.g_gbl_context
     and     sat1.ddf_column_name          is not null ;
  --
  cursor c_status(v_status in varchar2) is
    select status
    from pqh_copy_entity_results
    where result_type_cd     = 'TARGET'
    and   copy_entity_txn_id = p_copy_entity_txn_id
    and   status             = v_status
    and   number_of_copies   <> 0
    and   rownum             < 2 ;
  --
  cursor c_table_route (v_alias in varchar2) is
    select table_route_id
    from   pqh_table_route
    where  table_alias like v_alias ;
  --
  cursor c_dt is
    select ddf_column_name
    from    pqh_special_attributes s
	   ,pqh_txn_category_attributes c
	   ,pqh_attributes a
    where a.attribute_id = c.attribute_id
    and   c.txn_category_attribute_id = s.txn_category_attribute_id
    and   a.enable_flag = 'Y'
    and   c.select_flag = 'Y'
    and   s.enable_flag = 'Y'
    and   s.context     = pqh_generic.g_gbl_context
    and   s.attribute_type_cd in ('SELECT', 'PARAMETER','DISPLAY')
    and   a.column_name like 'DATETRACK%MODE%'
    and   s.ddf_column_name is not null
    and   rownum < 2;
    --
  function get_function_details( p_table_route_id           in number
                               , p_transaction_short_name   in varchar2
                               , p_context                  in varchar2
                               , p_function_type_cd        out nocopy varchar2
                               , p_pre_copy_function_name  out nocopy varchar2
                               , p_copy_function_name      out nocopy varchar2
                               , p_post_copy_function_name out nocopy varchar2 )
  return varchar2 is
  --
  cursor c_con is
     select cec.application_short_name, cec.legislation_code, cec.responsibility_key
     from pqh_copy_entity_contexts cec
     where cec.context                = p_context
     and   cec.transaction_short_name = p_transaction_short_name;
  --
  cursor c_all is
     select cec.context, cec.application_short_name, cec.legislation_code, cec.responsibility_key,
     cef.function_type_cd, cef.pre_copy_function_name, cef.copy_function_name, cef.post_copy_function_name
     from pqh_copy_entity_contexts cec, pqh_copy_entity_functions cef
     where cec.context                = cef.context
     and   cef.table_route_id         = p_table_route_id
     and   cec.transaction_short_name = p_transaction_short_name;
  begin
  --
  -- Context Assumption : context on the copy entity txns is the reference.
  --
  hr_utility.set_location('Get Fnc txn sht nam:'||p_transaction_short_name, 51);
  hr_utility.set_location('        context    :'||p_context, 52);
  hr_utility.set_location('        table route:'||p_table_route_id, 53);
  p_function_type_cd        := '' ;
  p_pre_copy_function_name  := '' ;
  p_copy_function_name      := '' ;
  p_post_copy_function_name := '' ;
  --
  for rec in c_con loop
     --
     for erec in c_all loop
        hr_utility.set_location(' appl shrt nam  :'||rec.application_short_name||'-'||erec.application_short_name, 53);
        hr_utility.set_location(' Leg code  :'||rec.legislation_code||'-'||erec.legislation_code, 54);
        hr_utility.set_location(' Resp Key  :'||rec.responsibility_key||'-'||erec.responsibility_key, 55);
        if nvl(rec.application_short_name,hr_api.g_varchar2) = nvl(erec.application_short_name,hr_api.g_varchar2) and
           nvl(rec.legislation_code,hr_api.g_varchar2)       = nvl(erec.legislation_code,hr_api.g_varchar2)       and
           nvl(rec.responsibility_key,hr_api.g_varchar2)     = nvl(erec.responsibility_key,hr_api.g_varchar2)    then
          --
          p_function_type_cd        := erec.function_type_cd ;
          p_pre_copy_function_name  := erec.pre_copy_function_name ;
          p_copy_function_name      := erec.copy_function_name ;
          p_post_copy_function_name := erec.post_copy_function_name ;
          return (erec.context) ;
        end if;
     end loop;
     --
     for erec in c_all loop
        if nvl(rec.application_short_name,hr_api.g_varchar2) = nvl(erec.application_short_name,hr_api.g_varchar2) and
           nvl(rec.legislation_code,hr_api.g_varchar2)       = nvl(erec.legislation_code,hr_api.g_varchar2)       and
           erec.responsibility_key                           is null                                              then
          --
          p_function_type_cd        := erec.function_type_cd ;
          p_pre_copy_function_name  := erec.pre_copy_function_name ;
          p_copy_function_name      := erec.copy_function_name ;
          p_post_copy_function_name := erec.post_copy_function_name ;
          return (erec.context) ;
        end if;
     end loop;
     --
     for erec in c_all loop
        if nvl(rec.application_short_name,hr_api.g_varchar2) = nvl(erec.application_short_name,hr_api.g_varchar2) and
           erec.legislation_code                             is null                                               and
           nvl(rec.responsibility_key,hr_api.g_varchar2)     = nvl(erec.responsibility_key,hr_api.g_varchar2)    then
          --
          p_function_type_cd        := erec.function_type_cd ;
          p_pre_copy_function_name  := erec.pre_copy_function_name ;
          p_copy_function_name      := erec.copy_function_name ;
          p_post_copy_function_name := erec.post_copy_function_name ;
          return (erec.context) ;
        end if;
     end loop;
     --
     for erec in c_all loop
        if nvl(rec.application_short_name,hr_api.g_varchar2) = nvl(erec.application_short_name,hr_api.g_varchar2) and
           erec.legislation_code                             is null                                               and
           erec.responsibility_key                           is null                                              then
          --
          p_function_type_cd        := erec.function_type_cd ;
          p_pre_copy_function_name  := erec.pre_copy_function_name ;
          p_copy_function_name      := erec.copy_function_name ;
          p_post_copy_function_name := erec.post_copy_function_name ;
          return (erec.context) ;
        end if;
     end loop;
     --
     for erec in c_all loop
        if erec.application_short_name is null   and
           erec.legislation_code       is null   and
           erec.responsibility_key     is null  then
          --
          p_function_type_cd        := erec.function_type_cd ;
          p_pre_copy_function_name  := erec.pre_copy_function_name ;
          p_copy_function_name      := erec.copy_function_name ;
          p_post_copy_function_name := erec.post_copy_function_name ;
          return (erec.context) ;
        end if;
     end loop;
     --
  end loop; --c_con
  --
  exception when others then
p_function_type_cd      := null;
p_pre_copy_function_name  := null;
p_copy_function_name      := null;
p_post_copy_function_name := null;
  raise;
  end get_function_details;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- populate local variables with
  -- transaction_category_id => which identifies the transaction
  -- master_table_route_id   => the master table associated with the transaction
  -- context                 => context associated with the transaction
  --
  for rec1 in c_info(p_copy_entity_txn_id) loop
     --
     l_transaction_category_id := rec1.transaction_category_id ;
     --
     l_transaction_short_name  := rec1.short_name              ;
     --
     l_name                    := rec1.name                    ;
     --
     l_master_table_route_id   := rec1.master_table_route_id   ;
     --
     l_effective_date          := rec1.effective_date          ;
     --
     l_context                 := rec1.context                 ;
     --
     pqh_generic.g_context     := l_context                    ;
     --
     pqh_generic.g_txn_id      := p_copy_entity_txn_id         ;
     --
     pqh_generic.g_gbl_context := rec1.gbl_context             ;
     l_dt_mode := rec1.dt_mode;
     --
     for i in c_dt loop
       execute immediate 'update pqh_copy_entity_results set '||i.ddf_column_name||' = '''||rec1.dt_mode
				   ||''' where copy_entity_txn_id = '||to_char(p_copy_entity_txn_id)
				   ||' and result_type_cd = ''TARGET'''
				   ||' and number_of_copies = 1 and status in (''TGT_P'',''TGT_ERR'')' ;
     end loop; --c_dt
     --
     update pqh_copy_entity_results
     set status = 'COMPLETED'
     where copy_entity_txn_id = rec1.copy_entity_txn_id
	and   result_type_cd     = 'SOURCE'
     and   number_of_copies     <> 0
	and   copy_entity_result_id not in (select src_copy_entity_result_id from pqh_copy_entity_results
								 where copy_entity_txn_id = rec1.copy_entity_txn_id
								 and   result_type_cd     = 'TARGET'
								 and   number_of_copies  <> 1 ) ;
     --
     update pqh_copy_entity_results
     set status = 'TGT_P'
     where copy_entity_txn_id = rec1.copy_entity_txn_id
	and   result_type_cd     = 'TARGET'
     and   number_of_copies   = 0
	and   status             = 'TGT_ERR' ;
	--
     update pqh_copy_entity_txns
     set status = nvl(l_status, 'COMPLETED')
     where copy_entity_txn_id = rec1.copy_entity_txn_id;
     --
     exit;
  end loop; -- c_info
  --
  -- get cer /cet information for error log
  for i in c_table_route ('CET') loop
	l_cet := i.table_route_id ;
  end loop;
  --
  for i in c_table_route ('CER1') loop
	l_cer1 := i.table_route_id ;
  end loop;
  --
  for i in c_table_route ('CER2') loop
	l_cer2 := i.table_route_id ;
  end loop;
  --
  -- start error log
  --
  pqh_process_batch_log.start_log (p_batch_id  => p_copy_entity_txn_id,
                                   p_module_cd => nvl(l_transaction_short_name, 'ERROR- GEN CPY') ,
							p_log_context => l_name ) ;
  --
  hr_utility.set_location('         '||l_proc ||' rec2', 5);
  --
  for rec2 in c_target loop
  --
	update pqh_copy_entity_results
	set    status = 'COMPLETED'
	where  copy_entity_result_id = rec2.copy_entity_result_id ;
	--
     pqh_generic.g_result_id := rec2.copy_entity_result_id ;
     l_reset_flag := 'Y' ;
     --
     pqh_process_batch_log.set_context_level (p_txn_id  => rec2.src_copy_entity_result_id,
                                              p_txn_table_route_id => l_cer1,-- trt for source
                                              p_level              => 1,
                                              p_log_context        => rec2.src_information1 );
     --
     assign_value(p_column_name   => 'EFFECTIVE_DATE'
                  , p_column_type => 'D'
                  , p_value       => l_effective_date
                  , p_reset_flag  => l_reset_flag
                  , p_source_flag => 'Y' );
     --
     l_reset_flag := 'N' ;
     --
     -- for every target record repoplated PLtable with new PK details
     --
     hr_utility.set_location('         '||l_proc ||' rec3', 5);
     --
     for rec3 in c_attribs(rec2.copy_entity_txn_id, l_master_table_route_id, 'PRIMARY_KEY') loop
     --
        dynamic_pltab_populate (p_ddf_column_name         => rec3.ddf_column_name
                                , p_copy_entity_result_id => rec2.src_copy_entity_result_id
                                , p_copy_entity_txn_id    => rec2.copy_entity_txn_id
                                , p_column_name           => get_alias(rec3.column_name)
                                , p_column_type           => rec3.column_type
                                , p_reset_flag            => l_reset_flag  -- delete before populate flag
                                , p_source_flag           => 'Y'  ) ;      -- specify source/target PLtable
        --
        -- Change reset flag to N
     end loop; -- c_attribs
     --
     -- for every target record repoplated PLtable with column details of new rec
     --
     l_reset_flag := 'Y' ;
     --
     hr_utility.set_location('         '||l_proc ||' rec4', 5);
     --
     for rec4 in c_change(rec2.copy_entity_txn_id, l_master_table_route_id) loop
     --
     -- poplated PLtable with new changeable details which the user postentially could have changed
     --
        dynamic_pltab_populate (p_ddf_column_name         => rec4.ddf_column_name
                                , p_copy_entity_result_id => rec2.copy_entity_result_id
                                , p_copy_entity_txn_id    => rec2.copy_entity_txn_id
                                , p_column_name           => get_alias(rec4.column_name)
                                , p_column_type           => rec4.column_type
                                , p_reset_flag            => l_reset_flag  -- delete before populate flag
                                , p_source_flag           => 'N'  ) ;      -- specify source/target PLtable
        --
        -- for every target record repoplated PLtable with column details of new rec
        --
        l_reset_flag := 'N' ;
        --
     end loop; -- c_change
     --
     hr_utility.set_location(l_proc||'   : after change', 111);
     --
     for rec5 in c_attribs(rec2.copy_entity_txn_id, l_master_table_route_id, 'PARAMETER') loop
     --
     -- poplated PLtable with parameter details which the transaction expects on the global table
     --
        dynamic_pltab_populate (p_ddf_column_name         => rec5.ddf_column_name
                                , p_copy_entity_result_id => rec2.copy_entity_result_id
                                , p_copy_entity_txn_id    => rec2.copy_entity_txn_id
                                , p_column_name           => get_alias(rec5.column_name)
                                , p_column_type           => rec5.column_type
                                , p_reset_flag            => 'N'       -- delete before populate flag
                                , p_source_flag           => 'N'  ) ;  -- specify source/target PLtable
     end loop; -- c_attribs
     --
     hr_utility.set_location(l_proc||'   : after attribs', 111);
     --
     -- the following loop is only for debugging purposes
     --
     for i in nvl(PQH_GENERIC.g_source_pk_table.first,0)..nvl(PQH_GENERIC.g_source_pk_table.last,-1) loop
        begin
        hr_utility.set_location(i||'S- '||PQH_GENERIC.g_source_pk_table(i).column_name||'- '
                                 ||       PQH_GENERIC.g_source_pk_table(i).column_type||'- '
                                 ||       PQH_GENERIC.g_source_pk_table(i).value,11);
        hr_utility.set_location(i||'T- '||PQH_GENERIC.g_target_pk_table(i).column_name||'- '
                                 ||       PQH_GENERIC.g_target_pk_table(i).column_type||'- '
                                 ||       PQH_GENERIC.g_target_pk_table(i).value,11);
        exception when others then null;
        end;
     end loop;
     --
     populate_table;
     --
     -- check if master copy is required (in case of duplicate rec on form, master would not be required)
     --
     if  p_master_required_flag = 'Y' then
        hr_utility.set_location('on master '||p_master_required_flag, 5);
	-- start of bug 5052820
	--
         if (pqh_generic.g_gbl_context ='Global Position Update'
	      and l_dt_mode ='UPDATE_CHANGE_INSERT') then
         upd_where :='Y';
         end if;
	--
	-- end of bug 5052820
        --
        g_level   := 1    ; -- 1 implying the master
        g_success := true ;
        l_function_context := get_function_details
                               ( p_table_route_id          => l_master_table_route_id
                               , p_transaction_short_name  => l_transaction_short_name
                               , p_context                 => l_context
                               , p_function_type_cd        => l_function_type_cd
                               , p_pre_copy_function_name  => l_pre_copy_function_name
                               , p_copy_function_name      => l_copy_function_name
                               , p_post_copy_function_name => l_post_copy_function_name  );
        --
        for rec6 in c_tab_details(l_master_table_route_id) loop
           --
           pqh_process_batch_log.set_context_level (p_txn_id  => rec2.copy_entity_result_id,
                                                    p_txn_table_route_id => l_cer2 , -- trt for target
                                                    p_level              => 2,
                                                    p_log_context        => rec2.information1 );
           begin
              savepoint start_process;
              --
              process_copy( p_copy_entity_txn_id   => rec2.copy_entity_txn_id
                        , p_table_route_id      => l_master_table_route_id
                        , p_from_clause         => rec6.from_clause
                        , p_table_alias         => rec6.table_alias
                        , p_where_clause        => rec6.where_clause
                        , p_pre_copy_proc       => l_pre_copy_function_name
                        , p_copy_proc           => l_copy_function_name
                        , p_post_copy_proc      => l_post_copy_function_name);
              --
              hr_utility.set_location('on master heading for upd', 499);
              update pqh_copy_entity_results
              set  number_of_copies = '0'
              where copy_entity_result_id = rec2.copy_entity_result_id
              and   status               in ('COMPLETED','DPT_ERR') ;
           exception
              when others then
                  hr_utility.set_location('on master exception', 500);
                  pqh_generic.v_err := sqlerrm;
                  Raise_Error(p_copy_entity_result_id => rec2.copy_entity_result_id,
                              p_msg_code              => 'ERR:');
           end ;
           exit; -- master record is always just one
        end loop; -- c_tab_details
        --
     end if; -- p_master_required_flag
     -- Dependent starts
     g_level   := 2    ; -- 2 implying the first dependents
     --
     if ( p_master_required_flag = 'Y' and g_success) or p_master_required_flag <> 'Y' then
        hr_utility.set_location('On Details ', 51);
     --
        for rec7 in c_dep_details(rec2.copy_entity_txn_id) loop
           hr_utility.set_location('on dependent '||rec7.table_route_id, 5);
           --
           l_function_context := get_function_details
                                  ( p_table_route_id          => rec7.table_route_id
                                  , p_transaction_short_name  => l_transaction_short_name
                                  , p_context                 => l_context
                                  , p_function_type_cd        => l_function_type_cd
                                  , p_pre_copy_function_name  => l_pre_copy_function_name
                                  , p_copy_function_name      => l_copy_function_name
                                  , p_post_copy_function_name => l_post_copy_function_name  );
           --
           --    Call copy process to copy dependents.
           --
           begin
           savepoint start_process;
           process_copy(  p_copy_entity_txn_id  => rec2.copy_entity_txn_id
                        , p_table_route_id      => rec7.table_route_id
                        , p_from_clause         => rec7.from_clause
                        , p_table_alias         => rec7.table_alias
                        , p_where_clause        => rec7.where_clause
                        , p_pre_copy_proc       => l_pre_copy_function_name
                        , p_copy_proc           => l_copy_function_name
                        , p_post_copy_proc      => l_post_copy_function_name);
           exception
           when others then
               Raise_Error(p_copy_entity_result_id => rec2.copy_entity_result_id,
                           p_msg_code              => 'WRN:');
           end ;
           --
        end loop; --c_dep_details
        --
    end if; -- dependent check for master success / no master
   -- End Dependent
   --
  end loop; --c_target
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  pqh_process_batch_log.end_log ;
  --
End generic_fn;
--
-- Generic Function to be called from concurrent program
--
Procedure generic_fn( errbuf                    out nocopy  varchar2,
                      retcode                   out nocopy  varchar2 ,
				  argument1                      varchar2 ,
				  argument2                      varchar2 default null ,
				  argument3                      varchar2 default null ,
				  argument4                      varchar2 default null ,
				  argument5                      varchar2 default null ,
				  argument6                      varchar2 default null ,
				  argument7                      varchar2 default null ,
				  argument8                      varchar2 default null ,
				  argument9                      varchar2 default null ,
				  argument10                     varchar2 default null ,
				  argument11                     varchar2 default null ,
				  argument12                     varchar2 default null ,
				  argument13                     varchar2 default null ,
				  argument14                     varchar2 default null ,
				  argument15                     varchar2 default null ,
				  argument16                     varchar2 default null ,
				  argument17                     varchar2 default null ,
				  argument18                     varchar2 default null ,
				  argument19                     varchar2 default null ,
				  argument20                     varchar2 default null ,
				  argument21                     varchar2 default null ,
				  argument22                     varchar2 default null ,
				  argument23                     varchar2 default null ,
				  argument24                     varchar2 default null ,
				  argument25                     varchar2 default null ,
				  argument26                     varchar2 default null ,
				  argument27                     varchar2 default null ,
				  argument28                     varchar2 default null ,
				  argument29                     varchar2 default null ,
				  argument30                     varchar2 default null ,
				  argument31                     varchar2 default null ,
				  argument32                     varchar2 default null ,
				  argument33                     varchar2 default null ,
				  argument34                     varchar2 default null ,
				  argument35                     varchar2 default null ,
				  argument36                     varchar2 default null ,
				  argument37                     varchar2 default null ,
				  argument38                     varchar2 default null ,
				  argument39                     varchar2 default null ,
				  argument40                     varchar2 default null ,
				  argument41                     varchar2 default null ,
				  argument42                     varchar2 default null ,
				  argument43                     varchar2 default null ,
				  argument44                     varchar2 default null ,
				  argument45                     varchar2 default null ,
				  argument46                     varchar2 default null ,
				  argument47                     varchar2 default null ,
				  argument48                     varchar2 default null ,
				  argument49                     varchar2 default null ,
				  argument50                     varchar2 default null ,
				  argument51                     varchar2 default null ,
				  argument52                     varchar2 default null ,
				  argument53                     varchar2 default null ,
				  argument54                     varchar2 default null ,
				  argument55                     varchar2 default null ,
				  argument56                     varchar2 default null ,
				  argument57                     varchar2 default null ,
				  argument58                     varchar2 default null ,
				  argument59                     varchar2 default null ,
				  argument60                     varchar2 default null ,
				  argument61                     varchar2 default null ,
				  argument62                     varchar2 default null ,
				  argument63                     varchar2 default null ,
				  argument64                     varchar2 default null ,
				  argument65                     varchar2 default null ,
				  argument66                     varchar2 default null ,
				  argument67                     varchar2 default null ,
				  argument68                     varchar2 default null ,
				  argument69                     varchar2 default null ,
				  argument70                     varchar2 default null ,
				  argument71                     varchar2 default null ,
				  argument72                     varchar2 default null ,
				  argument73                     varchar2 default null ,
				  argument74                     varchar2 default null ,
				  argument75                     varchar2 default null ,
				  argument76                     varchar2 default null ,
				  argument77                     varchar2 default null ,
				  argument78                     varchar2 default null ,
				  argument79                     varchar2 default null ,
				  argument80                     varchar2 default null ,
				  argument81                     varchar2 default null ,
				  argument82                     varchar2 default null ,
				  argument83                     varchar2 default null ,
				  argument84                     varchar2 default null ,
				  argument85                     varchar2 default null ,
				  argument86                     varchar2 default null ,
				  argument87                     varchar2 default null ,
				  argument88                     varchar2 default null ,
				  argument89                     varchar2 default null ,
				  argument90                     varchar2 default null ,
				  argument91                     varchar2 default null ,
				  argument92                     varchar2 default null ,
				  argument93                     varchar2 default null ,
				  argument94                     varchar2 default null ,
				  argument95                     varchar2 default null ,
				  argument96                     varchar2 default null ,
				  argument97                     varchar2 default null ,
				  argument98                     varchar2 default null ,
				  argument99                     varchar2 default null ,
				  argument100                    varchar2 default null
				  ) is
begin
 hr_utility.trace('Starting.. ');
 hr_utility.trace(argument1);
  --
  pqh_generic.g_calling_mode := 'CONCURRENT' ;
  pqh_generic.v_err  := '';
  g_conc_warn_flag := false;
  --
  generic_fn ( p_copy_entity_txn_id => argument1 );
  --
  if g_conc_warn_flag then
     retcode := 1 ;
  else
     retcode := 0;
  end if; --g_conc_warn_flag
  --
exception
  when others then
     errbuf  := sqlerrm ;
     retcode := 2 ;
end generic_fn;
--
-- Generic Function to be called from Forms etc. specifying the calling mode
--
function generic_fn( p_copy_entity_txn_id       in  number ,
                     p_txn_short_name           in  varchar2 ,
                     p_calling_mode             in  varchar2 ) return number is
l_req  number := -1 ;
begin
  --
  if p_calling_mode = 'FORM' then
     l_req := fnd_request.submit_request( application => 'PQH'
                                        , program     => 'PQHGNCPG'
                                        , argument1   => p_copy_entity_txn_id
                                        , argument2   => p_txn_short_name );
     return (l_req);
  end if;
  --
  pqh_generic.g_calling_mode := p_calling_mode ;
  --
  generic_fn ( p_copy_entity_txn_id => p_copy_entity_txn_id );
  --
  return (l_req);
--
end generic_fn;
--
Procedure process_copy(p_copy_entity_txn_id      in       varchar2 ,
                       p_table_route_id          in       varchar2 ,
                       p_from_clause             in       varchar2 ,
                       p_table_alias             in       varchar2 ,
                       p_where_clause            in       varchar2 ,
                       p_pre_copy_proc           in       varchar2 ,
                       p_copy_proc               in       varchar2 ,
                       p_post_copy_proc          in       varchar2 ,
                       p_validate                in       boolean default false ) is
--
-- local variables
--
l_proc               varchar2(72)   := g_package||'process_copy';
l_cursor             integer;
l_exec               integer;
l_set_session        varchar2(32000) ;
l_string             varchar2(32000) := ' ';
l_attribute          varchar2(32000) := ' ';
l_parameter          varchar2(32000) := ' ';
l_pk_val             varchar2(32000) := ' ';
l_column             varchar2(32000) := ' ';
l_where              varchar2(32000) ;
l_pre_copy_proc      varchar2(32000) ;
l_copy_proc          varchar2(32000) ;
l_post_copy_proc     varchar2(32000) ;
l_log                varchar2(2000)  ;
l_l                  varchar2(32000) ;
i                    number;
--
-- cursor to fetch specified attributes
--
cursor c_attrib(v_attrib_type varchar2) is
   select pa.column_name
          , pa.column_type
          , pa.width
          , get_alias(pa.column_name) param
          , decode(upper(pa.column_type)
                   , 'D' ,'L_'||get_alias(pa.column_name)||' DATE'
                   , 'V' ,'L_'||get_alias(pa.column_name)||' VARCHAR2'||'('||pa.width||')'
                   , 'C' ,'L_'||get_alias(pa.column_name)||' CHAR'    ||'('||pa.width||')'
                   , 'N' ,'L_'||get_alias(pa.column_name)||' NUMBER'  ||decode(pa.width,'0','','('||pa.width||')')
                   , 'L' ,'L_'||get_alias(pa.column_name)||' LONG'
                   , 'B' ,'L_'||get_alias(pa.column_name)||' BOOLEAN'
                   , 'L_'||get_alias(pa.column_name)||' '||pa.column_type||'('||pa.width||')') var_def
   from     pqh_attributes pa
            , pqh_txn_category_attributes tca
            , pqh_copy_entity_txns cet
            , pqh_special_attributes sat
   where    pa.master_table_route_id      = p_table_route_id
   and      pa.attribute_id               = tca.attribute_id
   and      cet.copy_entity_txn_id        = p_copy_entity_txn_id
   and      cet.transaction_category_id   = tca.transaction_category_id
   and      sat.txn_category_attribute_id = tca.txn_category_attribute_id
   and      sat.attribute_type_cd         = v_attrib_type --SELECT/PARAMETER/PRIMARY_KEY
   and      pa.enable_flag                = 'Y'
   and      tca.select_flag               = 'Y'
   and      sat.enable_flag               = 'Y'
   and      sat.context                   = pqh_generic.g_gbl_context ;
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Build table attributes, parameters and variables
  --
  for e_rec in c_attrib('SELECT') loop
    if c_attrib%rowcount = 1 then
      l_column     := e_rec.column_name ;                          -- columns for the cursor
      l_parameter  := 'P_'||e_rec.param ||'=>L_'||e_rec.param;     -- parameter for the functions
      l_attribute  := e_rec.var_def     ||'; ' ;                   -- Variable to be defined for the attributes
      l_string     :=  assign_part(e_rec.param, 'SELECT')       ;  -- assignment string
   else
      l_column     := l_column   ||','   ||e_rec.column_name ||' ';             -- columns for the cursor
      l_parameter  := l_parameter||', P_'||e_rec.param   ||'=>L_'||e_rec.param; -- parameter for functions
      l_attribute  := l_attribute||' '   ||e_rec.var_def ||'; ';                -- Variables definition
      l_string     := l_string   || assign_part(e_rec.param, 'SELECT')       ;  -- assignment string
    end if; --c_attrib%rowcount = 1
   --

    if e_rec.param = 'EFFECTIVE_START_DATE' then
	  l_string := l_string||' hr_utility.set_location(''Rec.Eff strt dt''||rec.effective_start_date,1000); ';
    end if ;

  end loop; -- c_attrib loop
  --
  --hr_utility.set_location('         '||l_proc||' param/attribs', 10);
  --
  -- parameters are for the functions
  -- attributes are for variable definitions
  --
  for e_rec in c_attrib('PARAMETER') loop
    if l_parameter is not null then
       l_parameter  := l_parameter||', P_'||e_rec.param   ||'=>L_'||e_rec.param; -- parameter for functions
    else
       l_parameter  := ', P_'     ||e_rec.param||'=>L_'     ||e_rec.param;
    end if; --l_parameter is not null
    --
    if l_attribute is not null then
       l_attribute  := l_attribute||'   '   ||e_rec.var_def ||'; ';                -- Variables definition
    else
       l_attribute  := e_rec.var_def   ||'; ';
    end if; --l_attribute is not null
    --
    l_string     := l_string   || assign_part(e_rec.param, 'PARAMETER')       ;  -- assignment string
  end loop; -- c_attrib loop
  --
  -- add l_effective_date to the variable list to facilitate the use while setting session_date
  --
  if instr(upper(l_attribute), 'L_EFFECTIVE_DATE') = 0 then
     l_attribute := l_attribute ||' l_effective_date date;';
  end if;
  --
  --hr_utility.set_location('         '||l_proc||' pri key', 10);
  --
  --
  -- loop to store values on the target table which would potentially affect the child records
  --

  l_pk_val :=  'if pqh_generic.g_level = 1 then PQH_GENERIC.g_target_pk_table.delete;'
               || 'PQH_GENERIC.assign_value(p_column_name   => ''L_EFFECTIVE_DATE'''
                                        ||' , p_column_type => ''D'''
                                        ||' , p_value       => L_EFFECTIVE_DATE'
                                        ||'); end if; ';
  --
  for e_rec in c_attrib('PRIMARY_KEY') loop
        l_pk_val := l_pk_val ||
                    ' PQH_GENERIC.assign_value(p_column_name   => '''||e_rec.param ||''''
                                           ||' , p_column_type => '''||e_rec.column_type ||''''
                                           ||' , p_value       => '  ||'L_'              ||e_rec.param
                                           ||'); ' ;
  end loop; -- c_attrib
  --
  for e_rec in c_attrib('ERROR_KEY') loop
     l_log := ' pqh_generic.log_error(p_table_route_id => '||p_table_route_id||',p_err_key => L_'|| e_rec.param ||');';
     --
  end loop; -- c_attrib
  --
  hr_utility.set_location('         '||l_proc||' repl where', 10);
  --
  --
  -- Replace where clause
  --
  pqh_refresh_data.replace_where_params(upper(p_where_clause),'N','',l_where);
  --
  -- Suffix parameters if function name is available for pre/copy/post
  -- start of bug 5052820
  --
   if (upd_where='Y') then
   l_where:=l_where||' and '''|| nvl(l_eff_date,trunc(sysdate)) ||''' between effective_start_date
           and effective_end_date';
end if;
--
-- end of bug 5052820
  --
  if p_pre_copy_proc is null then
     l_pre_copy_proc  := 'null ';
  else
     l_pre_copy_proc  := p_pre_copy_proc||'('||l_parameter||')';
  end if; --p_pre_copy_proc is not null
  hr_utility.set_location(l_proc||' pcp: '||l_pre_copy_proc,5);
  --
  if p_copy_proc is null then
     l_copy_proc      := 'null ';
  else
     l_copy_proc      := p_copy_proc||'('||l_parameter||')';
  end if; --p_copy_proc is not null
  hr_utility.set_location(l_proc||' cp: '||p_copy_proc,5);
  --
  if p_post_copy_proc is null then
     l_post_copy_proc := 'null ';
  else
     l_post_copy_proc := p_post_copy_proc||'('||l_parameter||')';
  end if; --p_post_copy_proc is not null
  hr_utility.set_location(l_proc||' pcp: '||l_post_copy_proc,5);
  --
  -- set session date incase the same is not set.
  --
  if (upd_where='N') then
  l_set_session := 'declare v_eff_date date;'
                 ||'cursor c1 is select effective_date from fnd_sessions where session_id = userenv(''sessionid''); '
                 ||'begin '
                 ||'l_effective_date := pqh_generic.get_src_effective_date ; '
                 ||'if c1%isopen then close c1; end if; '
                 ||'open c1; fetch c1 into v_eff_date; '
                 ||'if c1%notfound then '
                 ||'insert into fnd_sessions(session_id, effective_date)'
                 ||' values (userenv(''sessionid''), nvl(l_effective_date, trunc(sysdate)) ); '
                 ||'elsif l_effective_date <> v_eff_date then '
                 ||'update fnd_sessions set effective_date=l_effective_date where session_id=userenv(''sessionid''); '
                 ||'end if; '
                 ||'close c1; '
                 ||'end ;' ;
  --
  else
  l_set_session := 'declare v_eff_date date;'
                 ||'cursor c1 is select effective_date from fnd_sessions where session_id = userenv(''sessionid''); '
                 ||'begin '
                 ||'l_effective_date := pqh_generic.get_trg_effective_date ; '
                 ||'if c1%isopen then close c1; end if; '
                 ||'open c1; fetch c1 into v_eff_date; '
                 ||'if c1%notfound then '
                 ||'insert into fnd_sessions(session_id, effective_date)'
                 ||' values (userenv(''sessionid''),  nvl(l_effective_date, trunc(sysdate)) ); '
                 ||'elsif l_effective_date <> v_eff_date then '
                 ||'update fnd_sessions set effective_date=l_effective_date where session_id=userenv(''sessionid''); '
                 ||'end if; '
                 ||'close c1; '
                 ||'end ;' ;

  end if;
  -- bug 5052820 modified the above l_set_session  by changing the call to get_trg_effective_date

  hr_utility.set_location(l_proc||' L_efffective_date: '||to_char(pqh_generic.get_src_effective_date,'MM/DD/RRRR'),51);
  --
/**
 * Bug Fix: 3032847
 * Describe: to copy the work choice
 **/
  l_l := 'declare '
         || l_attribute
         || ' cursor c_at is select '
         || nvl(l_column,'')
         || ' from  '
         || p_from_clause
         || ' where '
         || l_where
         || '; '
         || 'begin '
         || l_set_session
         || ' for Rec in c_at loop '
         || 'begin '
         || l_string
         || l_pre_copy_proc
         || '; '
         || l_copy_proc
         || '; '
         || l_post_copy_proc
         || '; '
         || l_pk_val
         || 'exception '
         ||  ' when  others then '
         ||  '  PQH_GENERIC.g_conc_warn_flag := true; '
         ||  '  PQH_GENERIC.v_err := substr(sqlerrm, 1, 4000) ; '
         ||  l_log
         || 'end; '
         || 'end loop; '
         || 'end; ' ;
  --
  -- trace the dyn statement
  --
  hr_utility.trace('BEGIN SPOOL DYN STATEMENT-PQH_GENERIC ');

  hr_utility.trace(substr(l_l,1,2000 ));
  hr_utility.trace(substr(l_l,2001,2000 ));
  hr_utility.trace(substr(l_l,4001,2000 ));
  hr_utility.trace(substr(l_l,6001,2000 ));
  hr_utility.trace(substr(l_l,8001,2000 ));
  hr_utility.trace(substr(l_l,10001,2000 ));
  hr_utility.trace(substr(l_l,12001,2000 ));
  hr_utility.trace(substr(l_l,14001,2000 ));
  hr_utility.trace(substr(l_l,16001,2000 ));
  hr_utility.trace(substr(l_l,18001,2000 ));
  hr_utility.trace(substr(l_l,20001,2000 ));
  hr_utility.trace(substr(l_l,22001,2000 ));
  hr_utility.trace(substr(l_l,24001,2000 ));
  hr_utility.trace(substr(l_l,26001,2000 ));
  hr_utility.trace(substr(l_l,28001,2000 ));
  hr_utility.trace(substr(l_l,30001,2000 ));
  --hr_utility.trace(' ');
  hr_utility.trace('END SPOOL DYN STATEMENT-PQH_GENERIC ');
  --
  --
  -- Build PL/SQL Statement
  --
  hr_utility.set_location(l_proc||' : Starting function calls ',5);
  execute immediate l_l;
/* 'declare '

                      || l_attribute
                      || ' cursor c_at is select '
                      || nvl(l_column,'')
                      || ' from '
                      || p_from_clause
                      || ' where '
                      || l_where
                      || '; '
                      || 'begin '
                      || 'hr_utility.set_location(''Start dyn statement'',1); '
                      || l_set_session
                      || 'hr_utility.set_location(''after session_date: eff dt= ''||l_effective_date ,1); '
                      || 'hr_utility.set_location(''effective start Date''||l_effective_start_date ,1); '
                      || 'for Rec in c_at loop '
                      || 'begin '
                      || 'hr_utility.set_location(''inside loop'',1); '
                      || l_string
                      || l_pre_copy_proc
                      || '; '
                      || l_copy_proc
                      || '; '
                      || l_post_copy_proc
                      || '; '
                      || l_pk_val
                      || 'exception '
                      ||  ' when others then '
                      ||  '  PQH_GENERIC.v_err := substr(sqlerrm, 1, 4000) ; '
                      ||  l_log
                      || 'end; '
                      || 'end loop; '
                      || 'end; ' ;
*/
  hr_utility.set_location(nvl(substr(PQH_GENERIC.v_err,1  ,100),'Completed...'),5);
  hr_utility.set_location(nvl(substr(PQH_GENERIC.v_err,100,100),'************'),5);

end process_copy;

procedure populate_table
is
l_sr_type varchar2(10);
l_tg_type varchar2(10);
l_tg_val  varchar2(2000);

begin
   --
   -- to replace the where params.. a global plsql table is to be populated.
   --
   hr_utility.set_location('Entering :'||g_package||'populate_table ',25);
   pqh_refresh_data.g_refresh_tab.delete;
   --
   for i in nvl(PQH_GENERIC.g_source_pk_table.first,0)..nvl(PQH_GENERIC.g_source_pk_table.last,-1) loop
      --
      pqh_refresh_data.g_refresh_tab(i).column_name := upper(PQH_GENERIC.g_source_pk_table(i).column_name);
      --
      l_sr_type := substr(PQH_GENERIC.g_source_pk_table(i).column_type,1,1);
      --
      if l_sr_type = 'D' or l_sr_type = 'd' then
         --
         l_tg_type := 'N';
         --
         if length(PQH_GENERIC.g_source_pk_table(i).value) = 10 then
            l_tg_val  := ' to_date('''||PQH_GENERIC.g_source_pk_table(i).value||''',''MM/DD/RRRR'') ';
         else
              l_tg_type := 'D';
              l_tg_val  := PQH_GENERIC.g_source_pk_table(i).value ;
         end if; -- if length(g_source_pk_table)
        --
      elsif l_sr_type = 'V' or l_sr_type = 'v' then
         --
         l_tg_type := 'V';
         l_tg_val  := PQH_GENERIC.g_source_pk_table(i).value ;
      else
         --
         l_tg_type := 'N';
         l_tg_val  := PQH_GENERIC.g_source_pk_table(i).value ;
      end if; --if l_sr_type =
      --
       pqh_refresh_data.g_refresh_tab(i).column_type  := l_tg_type;
       pqh_refresh_data.g_refresh_tab(i).txn_val      := l_tg_val;
       pqh_refresh_data.g_refresh_tab(i).shadow_val   := l_tg_val;
       pqh_refresh_data.g_refresh_tab(i).main_val     := l_tg_val;
       pqh_refresh_data.g_refresh_tab(i).refresh_flag := 'N';
       pqh_refresh_data.g_refresh_tab(i).updt_flag    := 'N';
      --
   end loop ; --for i in PQH_GENERIC.g_source_pk_table.first..PQH_GENERIC.g_source_pk_table.last loop
   hr_utility.set_location('Leaving :'||g_package||'populate_table ',25);
end populate_table;

procedure Raise_Error(p_copy_entity_result_id in number,
                      p_msg_code in varchar2)
is
begin
   --
   -- update the status with error/warning message
   --
   rollback ;
   --
   hr_utility.set_location(pqh_generic.v_err,10);
--   update pqh_copy_entity_results
--   set status = substr(substr(p_msg_code,1,1)||replace(pqh_generic.v_err,'ORA'),1,30)
--      ,number_of_copies = '0'
--   where copy_entity_result_id = p_copy_entity_result_id;
--   commit;
   if pqh_generic.g_calling_mode = 'CONCURRENT' then
      fnd_file.new_line (fnd_file.log,1);
      fnd_file.put_line (fnd_file.log, p_msg_code);
      fnd_file.new_line (fnd_file.log,1);
      fnd_file.put_line (fnd_file.log, pqh_generic.v_err);
   end if;
   pqh_generic.v_err  := '';
   hr_utility.set_location('**********************',10);
   hr_utility.set_location(sqlerrm,10);
   hr_utility.set_location('.......Oops..Error !!!',10);
   hr_utility.set_location('**********************',10);
   --hr_utility.raise_error;
end Raise_Error;
--
function assign_part( p_column_name in varchar2 ,
                      p_attrib_type in varchar2 ) return varchar2 is
l_type  varchar2(10);
l_val   varchar2(2000);
begin
   --
   -- Assigning a variable with data selected from the database
   -- if the target global is populated with a value the same is used
   -- else the data from the selected source cursor is used.
   --
   for i in nvl(PQH_GENERIC.g_target_pk_table.first,0)..nvl(PQH_GENERIC.g_target_pk_table.last,-1) loop
      --
      --      if instr(upper(p_column_name),upper(PQH_GENERIC.g_target_pk_table(i).column_name)) > 0  then
      if upper(PQH_GENERIC.g_target_pk_table(i).column_name) = upper(p_column_name) then
          --
          l_type := substr(PQH_GENERIC.g_target_pk_table(i).column_type,1,1);
          --
          if l_type = 'D' or l_type = 'd' then
            --
            if length(PQH_GENERIC.g_target_pk_table(i).value) = 18 then
               l_val  := ' to_date('''||PQH_GENERIC.g_target_pk_table(i).value||''',''RRRR/MM/DDHH24:MI:SS'') ';
               return('L_'||p_column_name||' := '||l_val||';' );
            elsif length(PQH_GENERIC.g_target_pk_table(i).value) = 19 then
               l_val  := ' to_date('''||PQH_GENERIC.g_target_pk_table(i).value||''',''RRRR/MM/DD HH24:MI:SS'') ';
               return('L_'||p_column_name||' := '||l_val||';' );
            elsif length(PQH_GENERIC.g_target_pk_table(i).value) = 10 then
               l_val  := ' to_date('''||PQH_GENERIC.g_target_pk_table(i).value||''',''MM/DD/RRRR'') ';
               return('L_'||p_column_name||' := '||l_val||';' );
            else
              l_val  := PQH_GENERIC.g_target_pk_table(i).value ;
              return('L_'||p_column_name||' := '''||replace(l_val,'''','''''')||''';' );
            end if; -- if length(g_source_pk_table)
            --
          elsif (l_type = 'N' or l_type = 'n') and l_val is not null then
             -- addition of l_val is not null is vide bug 3373486
             --
            l_val  := PQH_GENERIC.g_target_pk_table(i).value ;
            return('L_'||p_column_name||' := '||l_val||';' );
            --
          else
             --
            l_val  := PQH_GENERIC.g_target_pk_table(i).value ;
            return('L_'||p_column_name||' := '''||replace(l_val,'''','''''')||''';' );
          end if; --if l_type =
          --
          hr_utility.set_location('assign :'||' := '''||l_val||'''',100);
     end if;
   end loop;
   --
   -- If no match was found then return assign only where the attribute type is not PARAMETER
   --
   if p_attrib_type = 'PARAMETER' then
      return('');
   else
      return('L_'||p_column_name||' := Rec.'||p_column_name||';');
   end if;
end assign_part;
--
function get_src_effective_date return date is
  l_type  varchar2(10);
  l_val   date := trunc(sysdate);
begin
   --
   -- Assigning a variable with data selected from the database
   -- if the source global is populated with a value the same is used
   -- else the data from the selected source cursor is used.
   --
   for i in nvl(PQH_GENERIC.g_source_pk_table.first,0)..nvl(PQH_GENERIC.g_source_pk_table.last,-1) loop
      --
      if upper(PQH_GENERIC.g_source_pk_table(i).column_name) = 'EFFECTIVE_DATE' then
          --
          l_type := substr(PQH_GENERIC.g_source_pk_table(i).column_type,1,1);
          --
          if l_type = 'D' or l_type = 'd' then
            --
            if length(PQH_GENERIC.g_source_pk_table(i).value) = 18 then
               l_val  :=  to_date(PQH_GENERIC.g_source_pk_table(i).value,'RRRR/MM/DDHH24:MI:SS') ;
               return(l_val );
            elsif length(PQH_GENERIC.g_source_pk_table(i).value) = 19 then
               l_val  := to_date(PQH_GENERIC.g_source_pk_table(i).value,'RRRR/MM/DD HH24:MI:SS');
               return(l_val );
            elsif length(PQH_GENERIC.g_source_pk_table(i).value) = 10 then
               l_val  := to_date(PQH_GENERIC.g_source_pk_table(i).value,'MM/DD/RRRR') ;
               return(l_val );
            else
              l_val  := PQH_GENERIC.g_source_pk_table(i).value ;
               return(l_val );
            end if; -- if length(g_source_pk_table)
            --
          else
             --
            return(l_val);
          end if; --if l_type =
          --
     end if;
   end loop;
   --
return(l_val);
exception when others then
  return(l_val);
end get_src_effective_date ;
--
-- start of bug 5052820
--
function get_trg_effective_date return date is
  l_type  varchar2(10);
  l_val   date := trunc(sysdate);
begin
  --
  IF ( l_eff_date IS NOT NULL ) THEN
  RETURN (l_eff_date);
  ELSE
  RETURN (pqh_generic.get_src_effective_date);
  end if;
exception when others then
  return(l_val);
end get_trg_effective_date ;
--
-- edn of bug 5052820
procedure assign_value(p_column_name varchar2,
                       p_column_type varchar2,
                       p_value       varchar2,
                       p_reset_flag  varchar2 default 'N',
                       p_source_flag varchar2 default 'N')
is
  l_count  number;
  l_check    boolean := true;

begin
  --
  -- This populated the source and target plsql table with details to be used at a later point and time
  --
  hr_utility.set_location('Entering : '||g_package||'assign_value '||p_source_flag,15);
  hr_utility.set_location('         : '||'column_name '||substr(p_column_name,1,60),15);
  hr_utility.set_location('         : '||'column_type '||substr(p_column_type,1,60),15);
  hr_utility.set_location('         : '||'value '      ||substr(p_value,1,60),15);
  hr_utility.set_location('         : '||'reset_flag ' ||substr(p_reset_flag,1,60),15);
  --
  if upper(p_source_flag) = 'Y' then
  --
      if p_reset_flag = 'Y' then
          PQH_GENERIC.g_target_pk_table.delete;
          --
      end if; -- p_reset_flag = 'Y'
      --
      if  nvl(PQH_GENERIC.g_source_pk_table.last,0) <> 0 then
        for i in PQH_GENERIC.g_source_pk_table.first..PQH_GENERIC.g_source_pk_table.last loop
         if PQH_GENERIC.g_source_pk_table(i).column_name  = upper(p_column_name) then
            PQH_GENERIC.g_source_pk_table(i).column_name := upper(p_column_name) ;
            PQH_GENERIC.g_source_pk_table(i).column_type := upper(p_column_type) ;
            PQH_GENERIC.g_source_pk_table(i).value       := p_value ;
            l_check := false ;
            exit;
         end if;  --PL Table Check
        end loop; -- source PL table loop
      end if;
      --
      if l_check then
         l_count := nvl(PQH_GENERIC.g_source_pk_table.last,0);
         PQH_GENERIC.g_source_pk_table(l_count+1).column_name := upper(p_column_name) ;
         PQH_GENERIC.g_source_pk_table(l_count+1).column_type := upper(p_column_type) ;
         PQH_GENERIC.g_source_pk_table(l_count+1).value       := p_value ;
	 end if; -- l_check
  else
  --
  -- start of the bug 5052820
  --
   if(substr(p_column_name,1,60)='EFFECTIVE_DATE') then
      l_eff_date :=fnd_date.canonical_to_date(p_value);
   end if;
  --
  -- end of the bug 5052820
       if p_reset_flag = 'Y' then
          PQH_GENERIC.g_target_pk_table.delete;
          --
      end if; -- p_reset_flag = 'Y'
      --
      if  nvl(PQH_GENERIC.g_target_pk_table.last,0) <> 0 then
        for i in PQH_GENERIC.g_target_pk_table.first..PQH_GENERIC.g_target_pk_table.last loop
         if PQH_GENERIC.g_target_pk_table(i).column_name  = upper(p_column_name) then
            PQH_GENERIC.g_target_pk_table(i).column_name := upper(p_column_name) ;
            PQH_GENERIC.g_target_pk_table(i).column_type := upper(p_column_type) ;
            PQH_GENERIC.g_target_pk_table(i).value       := p_value ;
            l_check := false ;
            exit;
         end if;  --PL Table Check
        end loop; --target PL table loop
      end if;
      --
	 if l_check then
         l_count := nvl(PQH_GENERIC.g_target_pk_table.last,0);
         PQH_GENERIC.g_target_pk_table(l_count+1).column_name := upper(p_column_name) ;
         PQH_GENERIC.g_target_pk_table(l_count+1).column_type := upper(p_column_type) ;
         PQH_GENERIC.g_target_pk_table(l_count+1).value       := p_value ;
      end if; --l_check
  end if; -- p_source_flag = 'Y'
  --
  hr_utility.set_location('Leaving : '||g_package||'assign_value ',15);
end assign_value;
--
Procedure dynamic_pltab_populate (p_ddf_column_name           in varchar2
                                  , p_copy_entity_result_id   in number
                                  , p_copy_entity_txn_id      in number
                                  , p_column_name             in varchar2
                                  , p_column_type             in varchar2
                                  , p_reset_flag              in varchar2
                                  , p_source_flag             in varchar2) is
begin
   --
   -- Assigns values to the plsql table from identified ddf_column
   --
   hr_utility.set_location('Entering :'||g_package||'dynamic_pltab_pop '||p_source_flag,11);
   hr_utility.set_location('         : '||'ddf_column_name ='||p_ddf_column_name,15);
   hr_utility.set_location('         : '||'column_name ='||p_column_name,15);
   execute immediate 'declare '
               || 'cursor c1 is '
               || 'select cer.'||p_ddf_column_name ||' value '
               || 'from pqh_copy_entity_results cer '
               || 'where cer.copy_entity_result_id = '||p_copy_entity_result_id ||' '
               || 'and cer.copy_entity_txn_id = '||p_copy_entity_txn_id ||'; '
               || 'begin '
               ||    'for i in c1 loop '
               ||    'pqh_generic.assign_value( p_column_name => '''|| p_column_name   ||''''
               ||                             ',p_column_type => '''|| p_column_type   ||''''
               ||                             ',p_value       => i.value '
               ||                             ',p_reset_flag  => '''|| p_reset_flag    ||''''
               ||                             ',p_source_flag => '''|| p_source_flag   ||''' ); '
               ||    'end loop; '
               || 'end; ';

   hr_utility.set_location('Leaving :'||g_package||'dynamic_pltab_pop ',11);
end dynamic_pltab_populate;


function get_alias(p_column_name in varchar2) return varchar2
is
begin
   return( substr(substr(p_column_name,instr(rtrim(p_column_name), '.',1)+1),
                  instr(rtrim(substr(p_column_name,instr(rtrim(p_column_name), '.',1)+1)),
                  ' ', -1 ,1)+1) );
end;
--
--
function get_user_pref( p_user_id                    number
                        , p_transaction_category_id  number
                  , p_table_route_id           number )
return boolean is
--
-- used from forms .. needs changes
--
  l_pref1   number(15);
  l_pref2   number(15);
  l_pref3   number(15);
  l_pref4   number(15);
  l_pref5   number(15);
  l_pref6   number(15);
  l_pref7   number(15);
  l_pref8   number(15);
  l_pref9   number(15);
  l_pref10  number(15);
  l_pref11  number(15);
  l_pref12  number(15);
--
--cursor c_rec is
--   select pref1, pref2, pref3, pref4,  pref5,  pref6,
--          pref7, pref8, pref9, pref10, pref11, pref12
--   from   pqh_user_copy_preference
--   where  user_id = p_user_id
--   and    transaction_category_id = p_transaction_category_id ;
--
begin
   --
--   open c_rec;
   --
--   fetch c_rec into l_pref1, l_pref2, l_pref3, l_pref4,  l_pref5,  l_pref6,
--                    l_pref7, l_pref8, l_pref9, l_pref10, l_pref11, l_pref12 ;
   --
--   if c_rec%notfound then
--      return (true);
--   end if;
   --
   if l_pref1 = p_table_route_id or
      l_pref2 = p_table_route_id or
      l_pref3 = p_table_route_id or
      l_pref4 = p_table_route_id or
      l_pref5 = p_table_route_id or
      l_pref6 = p_table_route_id or
      l_pref7 = p_table_route_id or
      l_pref8 = p_table_route_id or
      l_pref9 = p_table_route_id or
      l_pref10 = p_table_route_id or
      l_pref11 = p_table_route_id or
      l_pref12 = p_table_route_id then
      return (true);
   else
      return (false);
   end if;
   --
--   close c_rec;
   --
end get_user_pref;
--
procedure log_error (p_table_route_id        in varchar2 ,
                     p_err_key               in varchar2 ) is
--
l_calling_mode               varchar2(60) := pqh_generic.g_calling_mode;
l_copy_entity_result_id      number       := nvl(pqh_generic.g_result_id,-999.00);
l_src_copy_entity_result_id  number       ;
l_status                     varchar2(30) ;
--
cursor c_tgt is
   select copy_entity_txn_id,
          src_copy_entity_result_id
   from pqh_copy_entity_results
   where copy_entity_result_id = l_copy_entity_result_id ;
--
cursor c_src (l_src_id in number, l_status in varchar2) is
   select copy_entity_txn_id,
          copy_entity_result_id
   from pqh_copy_entity_results
   where copy_entity_result_id = l_src_id
   and   status in ( 'COMPLETED', 'DPT_ERR')
   and   status <> l_status  ;
--
begin
g_success := false; -- set the flag to identify the fail (helps identify master fail)
--
-- This procedure needs to be completed with error logging mechanisms
-- and status updates for TXN/SRC/TGT Records
--
hr_utility.trace('Result id :'||l_copy_entity_result_id);
hr_utility.trace('Call mode :'||l_calling_mode);
hr_utility.trace('Table id  :'||p_table_route_id);
hr_utility.trace('Err Key   :'||p_err_key);
hr_utility.trace('Err :'||substr(v_err,1,255));
hr_utility.trace('Err :'||substr(v_err,255,255));
hr_utility.trace('Err :'||substr(v_err,510,255));
--
if nvl(pqh_generic.g_level,1) = 2 then
   pqh_process_batch_log.set_context_level (p_txn_id             => nvl(p_err_key, l_copy_entity_result_id),
                                            p_txn_table_route_id => p_table_route_id,
                                            p_level              => 3,
                                            p_log_context        => p_err_key);
   --
   pqh_process_batch_log.insert_log ( p_message_type_cd => 'ERROR',
                                      p_message_text    => pqh_generic.v_err );
   --
   l_status := 'DPT_ERR' ;
   update pqh_copy_entity_results
   set status = 'DPT_ERR',
       number_of_copies = 0
   where copy_entity_result_id = l_copy_entity_result_id;
else
-- for target records the context is already set before starting the dyn calls
--
--   pqh_process_batch_log.set_context_level (p_txn_id             => l_copy_entity_result_id,
--                                            p_txn_table_route_id => p_table_route_id,
--                                            p_level              => 2,
--                                            p_log_context        => l_copy_entity_result_id );
   --
   pqh_process_batch_log.insert_log ( p_message_type_cd => 'ERROR',
                                      p_message_text    => pqh_generic.v_err );
   --
   l_status := 'TGT_ERR' ;
   update pqh_copy_entity_results
   set status = 'TGT_ERR'
   where copy_entity_result_id = l_copy_entity_result_id;
   --
end if;
--
for i in c_tgt loop
   --
   l_src_copy_entity_result_id := i.src_copy_entity_result_id ;
end loop;
--
for i in c_src (l_src_copy_entity_result_id, 'NONE' ) loop
    update pqh_copy_entity_results
    set status = l_status
    where copy_entity_result_id = i.copy_entity_result_id;
    --
    update pqh_copy_entity_txns
    set status = l_status
    where copy_entity_txn_id = i.copy_entity_txn_id
    and status  <> 'TGT_ERR';
    --
end loop;
--
pqh_generic.v_err := '';
--
end log_error;
--
end PQH_GENERIC;

/
