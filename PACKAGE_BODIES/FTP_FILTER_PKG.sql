--------------------------------------------------------
--  DDL for Package Body FTP_FILTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTP_FILTER_PKG" as
/* $Header: ftpfiltb.pls 120.7.12000000.2 2007/08/08 07:40:28 shishank ship $ */

   --Created by RKNANDA. Removed all hardcoded parts
   function get_eng_where_clause_new(
      err_code out nocopy number,
      err_msg out nocopy varchar2 ,
      data_set_id in number,
      period_id in number,
      table_alias in varchar2,
      table_name in varchar2,
      ledger_id in number default NULL,
      filter_id in number default NULL,  -- Condition Rule
      eff_date in date default NULL,
      working_copy_flg in char default 'N' -- working copy flag
   ) return long is
      ds_w_clause long := null;
      filt_clause long := null;
      disp_pred varchar2(5);
      ret_pred_type varchar2(5);
      logging varchar2(5);
      l_return_status    varchar2(1);
      l_msg_count        number;
      l_msg_data         varchar2(240);

   begin

      --data_set_id SHOULD be IODD as expected by gen_ds_wclause_by_tablename
      -- generate data set portion first
      FEM_DS_WHERE_CLAUSE_GENERATOR.FEM_Gen_DS_WClause_PVT (
       p_api_version       => 1.0
       ,p_init_msg_list    => FND_API.G_FALSE
       ,p_encoded          => FND_API.G_TRUE
       ,x_return_status    => l_return_status
       ,x_msg_count        => err_code /*l_msg_count*/
       ,x_msg_data         => err_msg /*l_msg_data*/
       ,p_ds_io_def_id     => data_set_id
       ,p_output_period_id => period_id
       ,p_table_name       => table_name
       ,p_table_alias      => table_alias
       ,p_ledger_id        => ledger_id
       ,p_where_clause     => ds_w_clause
      );

      /*if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       Get_Put_Messages (
         p_msg_count => l_msg_count
         ,p_msg_data => l_msg_data
       );
       raise l_request_prep_error;
      end if;*/

      /*fem_ds_where_clause_generator.FEM_Gen_DS_WClause_PVT(
         err_code,
         err_msg,
         data_set_id,
         period_id,
         table_alias,
         table_name,
         ledger_id,
         ds_w_clause
      );*/

      -- get Cond Rule SQL

      disp_pred := 'N';
      ret_pred_type := 'BOTH';
      logging := 'Y';
      err_code := 0;
      if (filter_id <> 0 ) then
         FEM_CONDITIONS_API.GENERATE_CONDITION_PREDICATE(
             err_code, err_msg, filter_id,
             FND_DATE.date_to_canonical(eff_date),
             table_name,
             table_alias, disp_pred, ret_pred_type, logging,
             filt_clause  );-- out
      end if;

      if (err_code = 0) then
         if ds_w_clause is not null and filt_clause is not null then
            ds_w_clause := '(' || ds_w_clause || ') and (' || filt_clause || ')'
                           || ' and ( ledger_id = ' || ledger_id || ')';
         elsif filt_clause is not null then
            ds_w_clause := filt_clause ||' and ( ledger_id = ' ||ledger_id||')';
         elsif ds_w_clause is not null then
            ds_w_clause := '('||ds_w_clause||') and ( ledger_id ='||ledger_id||')';
         end if;
      elsif ds_w_clause is not null then
         ds_w_clause := '('||ds_w_clause||') and ( ledger_id ='||ledger_id||')';
      end if;

      return ds_w_clause;
   end get_eng_where_clause_new;

end FTP_FILTER_PKG;

/
