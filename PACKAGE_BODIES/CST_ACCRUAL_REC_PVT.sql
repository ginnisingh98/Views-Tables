--------------------------------------------------------
--  DDL for Package Body CST_ACCRUAL_REC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_ACCRUAL_REC_PVT" AS
/* $Header: CSTACRHB.pls 120.20.12010000.3 2008/12/30 15:21:56 smsasidh ship $ */

G_PKG_NAME 	constant varchar2(30) := 'CST_Accrual_Rec_PVT';
G_LOG_HEADER	constant varchar2(40) := 'cst.plsql.CST_Accrual_Rec_PVT';
G_LOG_LEVEL	constant number       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 -- Start of comments
 --	API name 	: Get_Accounts
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Get all the "default accounts" for a given operating unit.
 --                       Only distint accrual account IDs are return.
 --	Parameters	:
 --	IN		: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier.
 --     OUT             : x_count       OUT NOCOPY NUBMER	Required
 --  			        Succes Indicator
 --				1  => Success
 --				-1 => Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure get_accounts( p_ou_id in number,
 			 x_count out nocopy number,
			 x_err_num out nocopy number,
			 x_err_code out nocopy varchar2,
			 x_err_msg out nocopy varchar2) is

   l_api_version  constant number := 1.0;
   l_api_name	  constant varchar2(30) := 'get_accounts';
   l_full_name	  constant varchar2(60) := g_pkg_name || '.' || l_api_name;
   l_module	  constant varchar2(60) := 'cst.plsql.' || l_full_name;
   l_uLog 	  constant boolean := fnd_log.test(fnd_log.level_unexpected, l_module);
   l_unLog        constant boolean := l_uLog and (fnd_log.level_unexpected >= g_log_level);
   l_errorLog	  constant boolean := l_uLog and (fnd_log.level_error >= g_log_level);
   l_exceptionLog constant boolean := l_errorLog and (fnd_log.level_exception >= g_log_level);
   l_pLog 	  constant boolean := l_exceptionLog and (fnd_log.level_procedure >= g_log_level);
   l_sLog	  constant boolean := l_pLog and (fnd_log.level_statement >= g_log_level);
   l_stmt_num	  number;

 begin

   l_stmt_num := 5;

   if(l_pLog) then
     fnd_log.string(fnd_log.level_procedure, g_log_header || '.' || l_api_name ||
		    '.begin', 'get_accounts << ' || 'p_ou_id := ' || to_char(p_ou_id));
   end if;

   /* Print out the parameters to the Message Stack */
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Operating Unit: ' || to_char(p_ou_id));

   l_stmt_num := 10;

   INSERT into cst_accrual_accounts(
           operating_unit_id,
           accrual_account_id,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           request_id,
           program_application_id,
           program_id,
           program_update_date
           )
   /* Grabs accrual accounts that have been part of a purchase order */
  SELECT
    t.org_id,
    t.accrual_account_id,
    sysdate,                    --last_update_date,
    FND_GLOBAL.USER_ID,         --last_updated_by,
    FND_GLOBAL.USER_ID,         --last_update_login,
    sysdate,                    --creation_date,
    FND_GLOBAL.USER_ID,         --created_by,
    FND_GLOBAL.CONC_REQUEST_ID, --request_id,
    FND_GLOBAL.PROG_APPL_ID,    --program_application_id,
    FND_GLOBAL.CONC_PROGRAM_ID, --program_id,
    sysdate
  FROM
  (select distinct p_ou_id org_id, paat.accrual_account_id accrual_account_id
   from   po_accrual_accounts_temp_all paat
   where  paat.org_id = p_ou_id
   and not exists (
       select 1
       from cst_accrual_accounts caa
       where caa.accrual_account_id = paat.accrual_account_id
       and   caa.operating_unit_id = p_ou_id)
   and exists ( select 1
                  from financials_system_params_all fsp,
                       gl_sets_of_books gsb,
                       gl_code_combinations gcc
                 where gsb.set_of_books_id      = fsp.set_of_books_id
                   and fsp.org_id               = p_ou_id
                   and gcc.code_combination_id  = paat.accrual_account_id
                   and gcc.chart_of_accounts_id = gsb.chart_of_accounts_id
               )

   union
   /* Grabs the default Purchasing accrual account */
   select distinct p_ou_id org_id, psp.accrued_code_combination_id accrual_account_id
   from   po_system_parameters_all psp
   where  psp.accrued_code_combination_id is not null
   and    psp.org_id = p_ou_id
   and not exists (
       select 1
       from cst_accrual_accounts caa
       where caa.accrual_account_id = psp.accrued_code_combination_id
       and   caa.operating_unit_id = p_ou_id)
   and exists  ( select 1
                   from financials_system_params_all fsp,
                        gl_sets_of_books gsb,
                        gl_code_combinations gcc
                  where gsb.set_of_books_id      = fsp.set_of_books_id
                    and fsp.org_id               = p_ou_id
                    and gcc.code_combination_id  = psp.accrued_code_combination_id
                    and gcc.chart_of_accounts_id = gsb.chart_of_accounts_id
                    )

   union
   /* Grabs the accrual account for each inventory organization*/
   select distinct p_ou_id org_id, mp.ap_accrual_account accrual_account_id
   from   mtl_parameters mp
   where  mp.ap_accrual_account is not null
   and    exists (
     select 1
     from   hr_organization_information hoi
     where  hoi.organization_id = mp.organization_id
     and    hoi.org_information_context = 'Accounting Information'
     and    hoi.org_information3 = to_char(p_ou_id))
   and not exists (
       select 1
       from cst_accrual_accounts caa
       where caa.accrual_account_id = mp.ap_accrual_account
       and   caa.operating_unit_id = p_ou_id)
   and exists ( select 1
                  from financials_system_params_all fsp,
                       gl_sets_of_books gsb,
                       gl_code_combinations gcc
                 where gsb.set_of_books_id      = fsp.set_of_books_id
                   and fsp.org_id               = p_ou_id
                   and gcc.code_combination_id  = mp.ap_accrual_account
                   and gcc.chart_of_accounts_id = gsb.chart_of_accounts_id
              )
   ) t ;


   x_count := sql%rowcount;

   commit;

   return;

   exception
     when others then
       rollback;
       x_count := -1;
       x_err_num := SQLCODE;
       x_err_code := NULL;
       x_err_msg := 'CST_Accrual_Rec_PVT.get_accounts() ' || SQLERRM;
       fnd_message.set_name('BOM','CST_UNEXPECTED');
       fnd_message.set_token('TOKEN',SQLERRM);
       if(l_unLog) then
         fnd_log.message(fnd_log.level_unexpected, g_log_header || '.' || l_api_name
			 || '(' || to_char(l_stmt_num) || ')', FALSE);
       end if;
       fnd_msg_pub.add;
       return;

 end get_accounts;

 -- Start of comments
 --	API name 	: Flip_Flag
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Sets the write_off_select_flag column in the appropriate
 --                       database tables to 'Y' or NULL.
 --	Parameters	:
 --	IN		: p_row_id	IN VARCHAR2		Required
 --				Row Identifier
 -- 			: p_bit		IN VARCHAR2		Required
 --				Determines whether to set the column to 'Y' or NULL
 --				FND_API.G_TRUE => 'Y'
 --				FND_API.G_FALSE => NULL
 --			: p_prog	IN NUMBER		Required
 --				Codes which tables's write_off_select_flag column will be altered
 --				0 => cst_reconciliation_summary (AP and PO Form)
 --		                1 => cst_misc_reconciliation (Miscellaneous Form)
 --                             2 => cst_write_offs (View Write-Offs Form)
 --     OUT             : x_count       OUT NOCOPY VARCHAR2	Required
 --  			        Succes Indicator
 --				FND_API.G_TRUE  => Success
 --				FND_API.G_FALSE => Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure flip_flag ( p_row_id in varchar2,
		       p_bit in varchar2,
		       p_prog in number,
 		       x_count out nocopy varchar2,
		       x_err_num out nocopy number,
	               x_err_code out nocopy varchar2,
		       x_err_msg out nocopy varchar2) is

   l_api_version  constant number := 1.0;
   l_api_name	  constant varchar2(30) := 'flip_flag';
   l_full_name	  constant varchar2(60) := g_pkg_name || '.' || l_api_name;
   l_module	  constant varchar2(60) := 'cst.plsql.' || l_full_name;
   l_uLog 	  constant boolean := fnd_log.test(fnd_log.level_unexpected, l_module);
   l_unLog        constant boolean := l_uLog and (fnd_log.level_unexpected >= g_log_level);
   l_errorLog	  constant boolean := l_uLog and (fnd_log.level_error >= g_log_level);
   l_exceptionLog constant boolean := l_errorLog and (fnd_log.level_exception >= g_log_level);
   l_pLog 	  constant boolean := l_exceptionLog and (fnd_log.level_procedure >= g_log_level);
   l_sLog	  constant boolean := l_pLog and (fnd_log.level_statement >= g_log_level);
   l_stmt_num	  number;

 begin

   l_stmt_num := 5;

   if(l_pLog) then
     fnd_log.string(fnd_log.level_procedure, g_log_header || '.' || l_api_name ||
		    '.begin', 'flip_flag << '
		    || 'p_row_id := ' || p_row_id
		    || 'p_bit := ' || p_bit
		    || 'p_prog := ' || to_char(p_prog));
   end if;

   /* Print out the parameters to the Message Stack */
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Row ID: ' || p_row_id);
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Flag Checked: ' || p_bit);
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Table Select: ' || to_char(p_prog));

   l_stmt_num := 10;

   if(fnd_api.to_boolean(p_bit)) then
 --{
     if(p_prog = 0) then
   --{
       update cst_reconciliation_summary
       set    write_off_select_flag = 'Y'
       where  rowid = p_row_id;
   --}
     elsif(p_prog = 1) then
   --{
       update cst_misc_reconciliation
       set    write_off_select_flag = 'Y'
       where  rowid = p_row_id;
   --}
     elsif(p_prog = 2) then
   --{
       update cst_write_offs
       set    write_off_select_flag = 'Y'
       where  rowid = p_row_id;
   --}
     end if; /* p_prog=0, p_prog=1, p_prog=2 */
 --}
   elsif(not fnd_api.to_boolean(p_bit)) then
 --{
     if(p_prog = 0) then
   --{
       update cst_reconciliation_summary
       set    write_off_select_flag = null
       where  rowid = p_row_id;
   --}
     elsif(p_prog = 1) then
   --{
       update cst_misc_reconciliation
       set    write_off_select_flag = null
       where  rowid = p_row_id;
   --}
     elsif(p_prog = 2) then
   --{
       update cst_write_offs
       set    write_off_select_flag = null
       where  rowid = p_row_id;
   --}
     end if; /* p_prog=0, p_prog=1, p_prog=2 */
 --}
   end if; /* fnd_api.to_boolean(p_bit) */

   x_count := fnd_api.g_true;
   return;

   exception
     when others then
   --{
       rollback;
       x_count := fnd_api.g_false;
       x_err_num := SQLCODE;
       x_err_code := NULL;
       x_err_msg := 'CST_Accrual_Rec_PVT.flip_flag() ' || SQLERRM;
       fnd_message.set_name('BOM','CST_UNEXPECTED');
       fnd_message.set_token('TOKEN',SQLERRM);
       if(l_unLog) then
         fnd_log.message(fnd_log.level_unexpected, g_log_header || '.' || l_api_name
			 || '(' || to_char(l_stmt_num) || ')', FALSE);
       end if;
       fnd_msg_pub.add;
       return;
   --}

 end flip_flag;

 -- Start of comments
 --	API name 	: Calc_Age_In_Days
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Calculates age in days using the profile option CST_ACCRUAL_AGE_IN_DAYS
 --	Parameters	:
 --	IN		: p_lrd		IN DATE			Required
 --				Last Receipt Date
 -- 			: p_lid		IN DATE			Required
 --				Last Invoice Date
 --     OUT             : x_count       OUT NOCOPY NUBMER	Required
 --  			        Age In Days Value
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure calc_age_in_days ( p_lrd in date,
			      p_lid in date,
			      x_count out nocopy number,
		              x_err_num out nocopy number,
	                      x_err_code out nocopy varchar2,
		              x_err_msg out nocopy varchar2) is

   l_api_version  constant number := 1.0;
   l_api_name	  constant varchar2(30) := 'calc_age_in_days';
   l_full_name	  constant varchar2(60) := g_pkg_name || '.' || l_api_name;
   l_module	  constant varchar2(60) := 'cst.plsql.' || l_full_name;
   l_uLog 	  constant boolean := fnd_log.test(fnd_log.level_unexpected, l_module);
   l_unLog        constant boolean := l_uLog and (fnd_log.level_unexpected >= g_log_level);
   l_errorLog	  constant boolean := l_uLog and (fnd_log.level_error >= g_log_level);
   l_exceptionLog constant boolean := l_errorLog and (fnd_log.level_exception >= g_log_level);
   l_pLog 	  constant boolean := l_exceptionLog and (fnd_log.level_procedure >= g_log_level);
   l_sLog	  constant boolean := l_pLog and (fnd_log.level_statement >= g_log_level);
   l_stmt_num	  number;

 begin

   l_stmt_num := 5;

   if(l_pLog) then
     fnd_log.string(fnd_log.level_procedure, g_log_header || '.' || l_api_name ||
		    '.begin', 'procedure cal_age_in_days << '
		    || 'p_lrd := ' || to_char(p_lrd, 'YYYY/MM/DD HH24:MI:SS')
		    || 'p_lid := ' || to_char(p_lid, 'YYYY/MM/DD HH24:MI:SS'));
   end if;

   /* Print out the parameters to the Message Stack */
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Last Receipt Date: ' || to_char(p_lrd, 'YYYY/MM/DD HH24:MI:SS'));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Last Invoice Date: ' || to_char(p_lid, 'YYYY/MM/DD HH24:MI:SS'));

   l_stmt_num := 10;

   /*
      If profile option set to last receipt date, then use the last receipt date
      to calculate Age in Days unless it is null, then use last invoice date
   */
   if(fnd_profile.value('CST_ACCRUAL_AGE_IN_DAYS') = '1') then
 --{
     if(p_lrd is not null) then
   --{
       x_count := trunc(sysdate - p_lrd);
       return;
   --}
     else
   --{
       x_count := trunc(sysdate - p_lid);
       return;
   --}
     end if; /* p_lrd is not null */
 --}
   /*
      If profile option set to use the last activity date, the use the later of the
      last receipt date or last invoice date to calculate Age in Days.  If one of the
      date values is null, use the non-null value.
   */
   else
 --{
     if(p_lid is null) then
   --{
       x_count := trunc(sysdate - p_lrd);
       return;
   --}
     elsif(p_lrd is null) then
   --{
       x_count := trunc(sysdate - p_lid);
       return;
   --}
     else
   --{
       if(p_lrd >= p_lid) then
     --{
         x_count := trunc(sysdate - p_lrd);
         return;
     --}
       else
     --{
	 x_count := trunc(sysdate - p_lid);
         return;
     --}
       end if; /* p_lrd >= p_lid */
   --}
     end if; /* p_lid is null, p_lrd is null */
 --}
   end if; /* fnd_profile.value('CST_ACCRUAL_AGE_IN_DAYS') = 1 */

   exception
     when others then
   --{
       rollback;
       x_count := -1;
       x_err_num := SQLCODE;
       x_err_code := NULL;
       x_err_msg := 'CST_Accrual_Rec_PVT.calc_age_in_days() ' || SQLERRM;
       fnd_message.set_name('BOM','CST_UNEXPECTED');
       fnd_message.set_token('TOKEN',SQLERRM);
       if(l_unLog) then
         fnd_log.message(fnd_log.level_unexpected, g_log_header || '.' || l_api_name
			 || '(' || to_char(l_stmt_num) || ')', FALSE);
       end if;
       fnd_msg_pub.add;
       return;
   --}

 end calc_age_in_days;

 -- Start of comments
 --	API name 	: Calc_Age_In_Days
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Calculates age in days using the profile option CST_ACCRUAL_AGE_IN_DAYS
 --	Parameters	:
 --	IN		: p_lrd		IN DATE			Required
 --				Last Receipt Date
 -- 			: p_lid		IN DATE			Required
 --				Last Invoice Date
 --     RETURN          : NUMBER
 --  			        Age In Days Value
 --				{x > -1} => Normal Completion
 --				-1	 => Error
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 function  calc_age_in_days ( p_lrd in date,
			      p_lid in date) return number is

   l_api_version  constant number := 1.0;
   l_api_name	  constant varchar2(30) := 'calc_age_in_days';
   l_full_name	  constant varchar2(60) := g_pkg_name || '.' || l_api_name;
   l_module	  constant varchar2(60) := 'cst.plsql.' || l_full_name;
   l_uLog 	  constant boolean := fnd_log.test(fnd_log.level_unexpected, l_module);
   l_unLog        constant boolean := l_uLog and (fnd_log.level_unexpected >= g_log_level);
   l_errorLog	  constant boolean := l_uLog and (fnd_log.level_error >= g_log_level);
   l_exceptionLog constant boolean := l_errorLog and (fnd_log.level_exception >= g_log_level);
   l_pLog 	  constant boolean := l_exceptionLog and (fnd_log.level_procedure >= g_log_level);
   l_sLog	  constant boolean := l_pLog and (fnd_log.level_statement >= g_log_level);
   l_stmt_num	  number;

 begin

   l_stmt_num := 5;

   if(l_pLog) then
     fnd_log.string(fnd_log.level_procedure, g_log_header || '.' || l_api_name ||
		    '.begin', 'function calc_age_in_days << '
 		    || 'p_lrd := ' || to_char(p_lrd, 'YYYY/MM/DD HH24:MI:SS')
		    || 'p_lid := ' || to_char(p_lid, 'YYYY/MM/DD HH24:MI:SS'));
   end if;

   /* Print out the parameters to the Message Stack */
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Last Receipt Date: ' || to_char(p_lrd, 'YYYY/MM/DD HH24:MI:SS'));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Last Invoice Date: ' || to_char(p_lid, 'YYYY/MM/DD HH24:MI:SS'));

   l_stmt_num := 10;

   /*
      If profile option set to last receipt date, then use the last receipt date
      to calculate Age in Days unless it is null, then use last invoice date
   */
   if(fnd_profile.value('CST_ACCRUAL_AGE_IN_DAYS') = '1') then
 --{
     if(p_lrd is not null) then
   --{
       return trunc(sysdate - p_lrd);
   --}
     else
   --{
       return trunc(sysdate - p_lid);
   --}
     end if; /* p_lrd is not null */
 --}
   /*
      If profile option set to use the last activity date, the use the later of the
      last receipt date or last invoice date to calculate Age in Days.  If one of the
      date values is null, use the non-null value.
   */
   else
 --{
     if(p_lid is null) then
   --{
       return trunc(sysdate - p_lrd);
   --}
     elsif(p_lrd is null) then
   --{
       return trunc(sysdate - p_lid);
   --}
     else
   --{
       if(p_lrd >= p_lid) then
     --{
         return trunc(sysdate - p_lrd);
     --}
       else
     --{
	 return trunc(sysdate - p_lid);
     --}
       end if; /* p_lrd >= p_lid */
   --}
     end if; /* p_lid is null, p_lrd is null */
 --}
   end if; /* fnd_profile.value('CST_ACCRUAL_AGE_IN_DAYS') = 1 */

   exception
     when others then
   --{
       rollback;
       fnd_message.set_name('BOM','CST_UNEXPECTED');
       fnd_message.set_token('TOKEN',SQLERRM);
       if(l_unLog) then
         fnd_log.message(fnd_log.level_unexpected, g_log_header || '.' || l_api_name
			 || '(' || to_char(l_stmt_num) || ')', FALSE);
       end if;
       fnd_msg_pub.add;
       return -1;
   --}

 end calc_age_in_days;

 -- Start of comments
 --	API name 	: Update_All
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Sets all the write_off_select_flags to 'Y' in the appropriate
 --                       table whose rows are returned by the where clause
 --	Parameters	:
 --	IN		: p_where	IN VARCHAR2		Required
 --				Where Clause
 -- 			: p_prog	IN NUMBER		Required
 --				Codes which table's write_off_select_flag column will be altered
 --		  	     	0 => cst_reconciliation_summary (AP and PO Form)
 --		       		1 => cst_misc_reconciliation (Miscellaneous Form)
 --                    		2 => cst_write_offs (View Write-Offs Form)
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_out       	OUT NOCOPY NUBMER	Required
 --				Sum of distributions/transactions selected
 --			: x_tot		OUT NOCOPY NUMBER	Required
 --  			        Number of rows selected for update
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure update_all ( p_where in varchar2,
                        p_prog in number,
		        p_ou_id in number,
		        x_out out nocopy number,
		        x_tot out nocopy number,
		        x_err_num out nocopy number,
	                x_err_code out nocopy varchar2,
		        x_err_msg out nocopy varchar2) is

   l_api_version  constant number := 1.0;
   l_api_name	  constant varchar2(30) := 'update_all';
   l_full_name	  constant varchar2(60) := g_pkg_name || '.' || l_api_name;
   l_module	  constant varchar2(60) := 'cst.plsql.' || l_full_name;
   l_uLog 	  constant boolean := fnd_log.test(fnd_log.level_unexpected, l_module);
   l_unLog        constant boolean := l_uLog and (fnd_log.level_unexpected >= g_log_level);
   l_errorLog	  constant boolean := l_uLog and (fnd_log.level_error >= g_log_level);
   l_exceptionLog constant boolean := l_errorLog and (fnd_log.level_exception >= g_log_level);
   l_pLog 	  constant boolean := l_exceptionLog and (fnd_log.level_procedure >= g_log_level);
   l_sLog	  constant boolean := l_pLog and (fnd_log.level_statement >= g_log_level);
   l_stmt_num	  number;

 begin

   l_stmt_num := 5;

   if(l_pLog) then
     fnd_log.string(fnd_log.level_procedure, g_log_header || '.' || l_api_name ||
		    '.begin', 'update_all << '
		    || 'p_where := ' || p_where
		    || 'p_prog := ' || to_char(p_prog)
		    || 'p_ou := ' || to_char(p_ou_id));
   end if;

   /* Print out the parameters to the Message Stack */
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Where Clause: ' || SUBSTRB(p_where,10000));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Table Select: ' || to_char(p_prog));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Operating Unit: ' || to_char(p_ou_id));

   l_stmt_num := 10;

   execute immediate p_where;

   l_stmt_num := 15;

   if(p_prog = 0) then
 --{
     select  count(*), sum(po_balance + ap_balance + write_off_balance)
     into    x_tot, x_out
     from    cst_reconciliation_summary
     where   operating_unit_id = p_ou_id
     and     write_off_select_flag = 'Y';
 --}
   elsif(p_prog = 1) then
 --{
     select count(*), sum(amount)
     into   x_tot, x_out
     from   cst_misc_reconciliation
     where  operating_unit_id = p_ou_id
     and    write_off_select_flag = 'Y';
 --}
   end if; /* p_prog = 0, p_prog = 1 */

   return;

   exception
     when others then
   --{
       rollback;
       x_tot := -1;
       x_out := -1;
       x_err_num := SQLCODE;
       x_err_code := NULL;
       x_err_msg := 'CST_Accrual_Rec_PVT.update_all() ' || SQLERRM;
       fnd_message.set_name('BOM','CST_UNEXPECTED');
       fnd_message.set_token('TOKEN',SQLERRM);
       if(l_unLog) then
         fnd_log.message(fnd_log.level_unexpected, g_log_header || '.' || l_api_name
			 || '(' || to_char(l_stmt_num) || ')', FALSE);
       end if;
       fnd_msg_pub.add;
       return;
   --}

 end update_all;

 -- Start of comments
 --	API name 	: Insert_Misc_Data_All
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Write-off transactions selected in the Miscellaneous
 --  			  Accrual Write-Off Form in Costing tables.  Proecedue will also generate
 --   			  Write-Off events in SLA.  At the end, all the written-off transactions are
 --   			  removed from cst_misc_reconciliation.
 --	Parameters	:
 --	IN		: p_wo_date	IN DATE			Required
 --				Write-Off Date
 -- 			: p_off_id	IN NUMBER		Required
 --				Offset Account
 -- 			: p_rea_id	IN NUMBER		Optional
 --				Write-Off Reason
 --			: p_comments	IN VARCHAR2		Optional
 --				Write-Off Comments
 --			: p_sob_id	IN NUMBER		Required
 --				Ledger/Set of Books
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_count      	OUT NOCOPY NUBMER	Required
 --  			        Success Indicator
 --				{x > 0} => Success
 --				-1	=> Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure insert_misc_data_all(
 			    p_wo_date in date,
			    p_off_id in number,
			    p_rea_id in number,
			    p_comments in varchar2,
			    p_sob_id in number,
			    p_ou_id in number,
   		            x_count out nocopy number,
		            x_err_num out nocopy number,
	                    x_err_code out nocopy varchar2,
		            x_err_msg out nocopy varchar2) is

   l_api_version  constant number := 1.0;
   l_api_name	  constant varchar2(30) := 'insert_misc_data_all';
   l_full_name	  constant varchar2(60) := g_pkg_name || '.' || l_api_name;
   l_module	  constant varchar2(60) := 'cst.plsql.' || l_full_name;
   l_uLog 	  constant boolean := fnd_log.test(fnd_log.level_unexpected, l_module);
   l_unLog        constant boolean := l_uLog and (fnd_log.level_unexpected >= g_log_level);
   l_errorLog	  constant boolean := l_uLog and (fnd_log.level_error >= g_log_level);
   l_exceptionLog constant boolean := l_errorLog and (fnd_log.level_exception >= g_log_level);
   l_pLog 	  constant boolean := l_exceptionLog and (fnd_log.level_procedure >= g_log_level);
   l_sLog	  constant boolean := l_pLog and (fnd_log.level_statement >= g_log_level);
   l_stmt_num	  number;
   l_rows	  number;
   l_le_id 	  number;
   /* Cursor to hold all select miscellaneous transactions*/
   cursor c_wo(l_ou_id number) is
   select  po_accrual_write_offs_s.nextval l_wo_id,
	   accrual_account_id,
	   transaction_date,
	   amount,
	   entered_amount,
	   quantity,
	   currency_code,
	   currency_conversion_type,
	   currency_conversion_rate,
	   currency_conversion_date,
	   transaction_type_code,
	   invoice_distribution_id,
	   inventory_transaction_id,
	   po_distribution_id,
	   inventory_item_id,
	   vendor_id,
	   inventory_organization_id,
	   operating_unit_id,
	   last_update_date,
	   last_updated_by,
	   last_update_login,
	   creation_date,
	   created_by,
	   request_id,
	   program_application_id,
	   program_id,
	   program_update_date,
           ae_header_id,
           ae_line_num
   from    cst_misc_reconciliation
   where   operating_unit_id = l_ou_id
   and     write_off_select_flag = 'Y';

 begin

   l_stmt_num := 5;

   if(l_pLog) then
     fnd_log.string(fnd_log.level_procedure, g_log_header || '.' || l_api_name ||
		    '.begin', 'insert_misc_data_all << '
		    || 'p_wo_date := ' || to_char(p_wo_date, 'YYYY/MM/DD HH24:MI:SS')
		    || 'p_off_id := ' || to_char(p_off_id)
		    || 'p_rea_id := ' || to_char(p_rea_id)
		    || 'p_comments := ' || p_comments
		    || 'p_sob_id := ' || to_char(p_sob_id)
 		    || 'p_ou_id := ' || to_char(p_ou_id));
   end if;

   /* Print out the parameters to the Message Stack */
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Write-Off Date: ' || to_char(p_wo_date, 'YYYY/MM/DD HH24:MI:SS'));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Offset Account: ' || to_char(p_off_id));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Write-Off Reason: ' || to_char(p_rea_id));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Comments: ' || p_comments);
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Set of Books: ' || to_char(p_sob_id));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Operating Unit: ' || to_char(p_ou_id));

   l_stmt_num := 10;

   /* Check whether any transactions have been selected for write-off */
   select count(*)
   into   l_rows
   from   cst_misc_reconciliation
   where  operating_unit_id = p_ou_id
   and    write_off_select_flag = 'Y';

   if(l_rows > 0) then
 --{
     l_stmt_num := 15;

     for c_wo_rec in c_wo(p_ou_id) loop
   --{
       /*
          If it is an inventory transaction, the Legal Entity will be derived
          by the inventory organization ID, For miscellaneous invoices, the
	  Legal Entity will be derived from the AP Invoices table.
       */
       if(c_wo_rec.inventory_transaction_id is not null) then
     --{
         select org_information2
         into   l_le_id
    	 from   hr_organization_information
   	 where  organization_id = c_wo_rec.inventory_organization_id
         and    org_information_context = 'Accounting Information';
     --}
       else
     --{
	 select apia.legal_entity_id
	 into   l_le_id
    	 from   ap_invoices_all 	     apia,
		ap_invoice_distributions_all aida
 	 where  aida.invoice_distribution_id = c_wo_rec.invoice_distribution_id
	 and    apia.invoice_id = aida.invoice_id;
     --}
       end if; /* c_wo_rec.inventory_transaction_id is not null */

       l_stmt_num := 20;

       /* Insert necessary information into SLA events temp table */
       insert into xla_events_int_gt
       (
         application_id,
  	 ledger_id,
  	 legal_entity_id,
  	 entity_code,
  	 source_id_int_1,
 	 event_class_code,
  	 event_type_code,
  	 event_date,
  	 event_status_code,
         --BUG#7226250
  	 security_id_int_2,
  	 transaction_date,
         reference_date_1,
         transaction_number
       )
       values
       (
  	 707,
  	 p_sob_id,
  	 l_le_id,
 	 'WO_ACCOUNTING_EVENTS',
  	 c_wo_rec.l_wo_id,
  	 'ACCRUAL_WRITE_OFF',
  	 'ACCRUAL_WRITE_OFF',
  	 p_wo_date,
  	 XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
  	 p_ou_id,
  	 p_wo_date,
         INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(p_wo_date,p_ou_id),
         to_char(c_wo_rec.l_wo_id)
       );

       l_stmt_num := 25;

       /*
          Insert the selected miscellaneous transactions into
          Costing's Write-Off tables
       */
       insert all
       into cst_write_offs
       (
 	 write_off_id,
	 transaction_date,
	 accrual_account_id,
	 offset_account_id,
	 write_off_amount,
	 entered_amount,
	 currency_code,
	 currency_conversion_type,
	 currency_conversion_rate,
	 currency_conversion_date,
	 transaction_type_code,
	 invoice_distribution_id,
 	 inventory_transaction_id,
	 po_distribution_id,
	 reason_id,
	 comments,
	 inventory_item_id,
	 vendor_id,
	 legal_entity_id,
	 operating_unit_id,
	 last_update_date,
	 last_updated_by,
 	 last_update_login,
	 creation_date,
	 created_by,
	 request_id,
	 program_application_id,
	 program_id,
	 program_update_date
       )
       values
       (
   	 c_wo_rec.l_wo_id,
  	 p_wo_date,
  	 c_wo_rec.accrual_account_id,
  	 p_off_id,
   	 (-1) * c_wo_rec.amount,
   	 (-1) * c_wo_rec.entered_amount,
   	 c_wo_rec.currency_code,
   	 c_wo_rec.currency_conversion_type,
   	 c_wo_rec.currency_conversion_rate,
   	 c_wo_rec.currency_conversion_date,
   	 'WRITE OFF',
   	 c_wo_rec.invoice_distribution_id,
   	 c_wo_rec.inventory_transaction_id,
   	 c_wo_rec.po_distribution_id,
   	 p_rea_id,
   	 p_comments,
   	 c_wo_rec.inventory_item_id,
   	 c_wo_rec.vendor_id,
   	 l_le_id,
   	 p_ou_id,
   	 sysdate,                    --last_update_date,
   	 FND_GLOBAL.USER_ID,         --last_updated_by,
   	 FND_GLOBAL.USER_ID,         --last_update_login,
   	 sysdate,                    --creation_date,
   	 FND_GLOBAL.USER_ID,         --created_by,
   	 FND_GLOBAL.CONC_REQUEST_ID, --request_id,
   	 FND_GLOBAL.PROG_APPL_ID,    --program_application_id,
  	 FND_GLOBAL.CONC_PROGRAM_ID, --program_id,
   	 sysdate                     -- program_update_date
       )
       into cst_write_off_details
       (
 	 write_off_id,
 	 transaction_date,
 	 amount,
	 entered_amount,
	 quantity,
	 currency_code,
	 currency_conversion_type,
	 currency_conversion_rate,
	 currency_conversion_date,
	 transaction_type_code,
	 invoice_distribution_id,
	 inventory_transaction_id,
	 inventory_organization_id,
	 operating_unit_id,
         last_update_date,
         last_updated_by,
         last_update_login,
         creation_date,
         created_by,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         ae_header_id,
         ae_line_num
       )
       values
       (
    	 c_wo_rec.l_wo_id,
    	 c_wo_rec.transaction_date,
    	 c_wo_rec.amount,
   	 c_wo_rec.entered_amount,
   	 c_wo_rec.quantity,
   	 c_wo_rec.currency_code,
   	 c_wo_rec.currency_conversion_type,
   	 c_wo_rec.currency_conversion_rate,
   	 c_wo_rec.currency_conversion_date,
   	 c_wo_rec.transaction_type_code,
   	 c_wo_rec.invoice_distribution_id,
   	 c_wo_rec.inventory_transaction_id,
   	 c_wo_rec.inventory_organization_id,
   	 p_ou_id,
   	 sysdate,                      --last_update_date,
   	 FND_GLOBAL.USER_ID,           --last_updated_by,
   	 FND_GLOBAL.USER_ID,           --last_update_login,
   	 sysdate,                      --creation_date,
   	 FND_GLOBAL.USER_ID,           --created_by,
   	 FND_GLOBAL.CONC_REQUEST_ID,   --request_id,
   	 FND_GLOBAL.PROG_APPL_ID,      --program_application_id,
   	 FND_GLOBAL.CONC_PROGRAM_ID,   --program_id,
   	 sysdate,                      --program_update_date,
         c_wo_rec.ae_header_id,
         c_wo_rec.ae_line_num
       )
       select c_wo_rec.l_wo_id,
 	      c_wo_rec.accrual_account_id,
 	      c_wo_rec.transaction_date,
	      c_wo_rec.amount,
	      c_wo_rec.entered_amount,
	      c_wo_rec.quantity,
   	      c_wo_rec.currency_code,
	      c_wo_rec.currency_conversion_type,
	      c_wo_rec.currency_conversion_rate,
	      c_wo_rec.currency_conversion_date,
	      c_wo_rec.transaction_type_code,
	      c_wo_rec.invoice_distribution_id,
	      c_wo_rec.inventory_transaction_id,
	      c_wo_rec.po_distribution_id,
	      c_wo_rec.inventory_item_id,
	      c_wo_rec.vendor_id,
	      c_wo_rec.inventory_organization_id,
	      c_wo_rec.operating_unit_id,
              c_wo_rec.ae_header_id,
              c_wo_rec.ae_line_num
       from   cst_misc_reconciliation
       where  rownum = 1;
   --}
     end loop; /* for c_wo_rec in c_wo(p_ou_id) */

     l_stmt_num := 30;

     /* Delete written-off transactions from Costing's Miscellaneous table */
     delete from cst_misc_reconciliation
     where  operating_unit_id = p_ou_id
     and    write_off_select_flag = 'Y';


     l_stmt_num := 35;

     /*
        Call SLA's bulk events generator which uses the values previously
        inserted into SLA's event temp table
     */
     xla_events_pub_pkg.create_bulk_events(p_source_application_id => 201,
                                           p_application_id => 707,
	    			           p_ledger_id => p_sob_id,
				           p_entity_type_code => 'WO_ACCOUNTING_EVENTS');

     commit;
 --}
   else
 --{
     x_count := -1;
     return;
 --}
   end if; /* l_rows > 0 */

   x_count :=  l_rows;
   return;

   exception
     when others then
   --{
       rollback;
       x_count := -1;
       x_err_num := SQLCODE;
       x_err_code := NULL;
       x_err_msg := 'CST_Accrual_Rec_PVT.insert_misc_data_all() ' || SQLERRM;
       fnd_message.set_name('BOM','CST_UNEXPECTED');
       fnd_message.set_token('TOKEN',SQLERRM);
       if(l_unLog) then
         fnd_log.message(fnd_log.level_unexpected, g_log_header || '.' || l_api_name
			 || '(' || to_char(l_stmt_num) || ')', FALSE);
       end if;
       fnd_msg_pub.add;
      return;
   --}
 end insert_misc_data_all;

 -- Start of comments
 --	API name 	: Insert_Appo_Data_All
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Write-off PO distributions selected in the AP and PO
 --   		          Accrual Write-Off Form in Costing tables.  Proecedue will also generate
 --   			  Write-Off events in SLA.  A single write-off event will be generated
 --   			  regardless of the number of transactions that make up the PO distribution.
 --   			  At the end, all the written-off PO distributions
 --   			  and individual AP and PO transactions are removed from
 --   			  cst_reconciliation_summary and cst_ap_po_reconciliation..
 --	Parameters	:
 --	IN		: p_wo_date	IN DATE			Required
 --				Write-Off Date
 -- 			: p_rea_id	IN NUMBER		Optional
 --				Write-Off Reason
 --			: p_comments	IN VARCHAR2		Optional
 --				Write-Off Comments
 --			: p_sob_id	IN NUMBER		Required
 --				Ledger/Set of Books
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_count      	OUT NOCOPY NUBMER	Required
 --  			        Success Indicator
 --				{x > 0} => Success
 --				-1	=> Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure insert_appo_data_all(
 			        p_wo_date in date,
			        p_rea_id in number,
			    	p_comments in varchar2,
			    	p_sob_id in number,
			    	p_ou_id in number,
   		            	x_count out nocopy number,
		            	x_err_num out nocopy number,
	                    	x_err_code out nocopy varchar2,
		            	x_err_msg out nocopy varchar2) is

   l_api_version  constant number := 1.0;
   l_api_name	  constant varchar2(30) := 'insert_appo_data_all';
   l_full_name	  constant varchar2(60) := g_pkg_name || '.' || l_api_name;
   l_module	  constant varchar2(60) := 'cst.plsql.' || l_full_name;
   l_uLog 	  constant boolean := fnd_log.test(fnd_log.level_unexpected, l_module);
   l_unLog        constant boolean := l_uLog and (fnd_log.level_unexpected >= g_log_level);
   l_errorLog	  constant boolean := l_uLog and (fnd_log.level_error >= g_log_level);
   l_exceptionLog constant boolean := l_errorLog and (fnd_log.level_exception >= g_log_level);
   l_pLog 	  constant boolean := l_exceptionLog and (fnd_log.level_procedure >= g_log_level);
   l_sLog	  constant boolean := l_pLog and (fnd_log.level_statement >= g_log_level);
   l_stmt_num	  number;
   l_rows 	  number;
   l_ent_sum	  number;
   l_off_id	  number;
   l_erv_id	  number;
   l_wo_cc	  varchar2(30);
   l_wo_ct	  varchar2(30);
   l_wo_cr	  number;
   l_wo_cd	  date;

   /* Cusor to hold all the PO distributions selected in the AP and PO form*/
   cursor c_wo(l_ou_id number) is
   select po_accrual_write_offs_s.nextval l_wo_id,
	  (po_balance + ap_balance + write_off_balance) l_tot_bal,
	  po_distribution_id,
	  accrual_account_id,
 	  destination_type_code,
	  inventory_item_id,
	  vendor_id,
	  operating_unit_id,
	  last_update_date,
	  last_updated_by,
	  last_update_login,
	  creation_date,
	  created_by,
	  request_id,
	  program_application_id,
	  program_id,
	  program_update_date
   from   cst_reconciliation_summary
   where  operating_unit_id = l_ou_id
   and    write_off_select_flag = 'Y';

 begin

   l_stmt_num := 5;

   if(l_pLog) then
     fnd_log.string(fnd_log.level_procedure, g_log_header || '.' || l_api_name ||
		    '.begin', 'insert_appo_data_all << '
		    || 'p_wo_date := ' || to_char(p_wo_date, 'YYYY/MM/DD HH24:MI:SS')
		    || 'p_rea_id := ' || to_char(p_rea_id)
		    || 'p_comments := ' || p_comments
		    || 'p_sob_id := ' || to_char(p_sob_id)
 		    || 'p_ou_id := ' || to_char(p_ou_id));
   end if;

   /* Print out the parameters to the Message Stack */
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Write-Off Date: ' || to_char(p_wo_date, 'YYYY/MM/DD HH24:MI:SS'));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Write-Off Reason: ' || to_char(p_rea_id));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Comments: ' || p_comments);
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Set of Books: ' || to_char(p_sob_id));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Operating Unit: ' || to_char(p_ou_id));

   l_stmt_num := 10;

   /* Make sure user selected PO distributions to write-off */
   select count(*)
   into   l_rows
   from   cst_reconciliation_summary
   where  operating_unit_id = p_ou_id
   and    write_off_select_flag = 'Y';

   if(l_rows > 0) then
 --{
     l_stmt_num := 15;

     for c_wo_rec in c_wo(p_ou_id) loop
   --{
       /* Insert necessary information into SLA events temp table */
       insert into xla_events_int_gt
       (
  	 application_id,
  	 ledger_id,
  	 entity_code,
  	 source_id_int_1,
  	 event_class_code,
  	 event_type_code,
  	 event_date,
  	 event_status_code,
         --BUG#7226250
  	 security_id_int_2,
  	 transaction_date,
         reference_date_1,
         transaction_number
       )
       values
       (
  	 707,
  	 p_sob_id,
  	 'WO_ACCOUNTING_EVENTS',
  	 c_wo_rec.l_wo_id,
 	 'ACCRUAL_WRITE_OFF',
 	 'ACCRUAL_WRITE_OFF',
 	 p_wo_date,
 	 XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
 	 p_ou_id,
 	 p_wo_date,
         INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(p_wo_date,p_ou_id),
         to_char(c_wo_rec.l_wo_id)
       );

       l_stmt_num := 20;

       /*
          Insert the individual AP and/or PO transactions into
          the write-off details table
       */
       insert into cst_write_off_details
       (
	 write_off_id,
	 transaction_date,
	 amount,
	 entered_amount,
	 quantity,
	 currency_code,
	 currency_conversion_type,
	 currency_conversion_rate,
	 currency_conversion_date,
	 transaction_type_code,
 	 rcv_transaction_id,
	 invoice_distribution_id,
	 write_off_transaction_id,
	 inventory_organization_id,
	 operating_unit_id,
         last_update_date,
         last_updated_by,
         last_update_login,
         creation_date,
         created_by,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         ae_header_id,
         ae_line_num
       )
       select c_wo_rec.l_wo_id,
    	      capr.transaction_date,
 	      capr.amount,
	      capr.entered_amount,
	      capr.quantity,
	      capr.currency_code,
	      capr.currency_conversion_type,
	      capr.currency_conversion_rate,
	      capr.currency_conversion_date,
	      capr.transaction_type_code,
	      capr.rcv_transaction_id,
	      capr.invoice_distribution_id,
	      capr.write_off_id,
	      capr.inventory_organization_id,
	      capr.operating_unit_id,
              sysdate,                     --last_update_date,
              FND_GLOBAL.USER_ID,          --last_updated_by,
              FND_GLOBAL.USER_ID,          --last_update_login,
              sysdate,                     --creation_date,
              FND_GLOBAL.USER_ID,          --created_by,
              FND_GLOBAL.CONC_REQUEST_ID,  --request_id,
              FND_GLOBAL.PROG_APPL_ID,     --program_application_id,
              FND_GLOBAL.CONC_PROGRAM_ID,  --program_id,
              sysdate,                     --program_update_date,
              capr.ae_header_id,
              capr.ae_line_num
       from   cst_ap_po_reconciliation  capr
       where  capr.po_distribution_id = c_wo_rec.po_distribution_id
       and    capr.accrual_account_id = c_wo_rec.accrual_account_id
       and    capr.operating_unit_id  = c_wo_rec.operating_unit_id;

       l_stmt_num := 25;

       /* Get the sum of the entered amount */
       select sum(capr.entered_amount)
       into   l_ent_sum
       from   cst_ap_po_reconciliation capr
       where  capr.po_distribution_id = c_wo_rec.po_distribution_id
       and    capr.accrual_account_id = c_wo_rec.accrual_account_id
       and    capr.operating_unit_id  = c_wo_rec.operating_unit_id;

       /* Get all the currency information and offset/erv accounts based on the PO match type */
      /* the offset account is selected as follows.If the destination type code is Expense, get the charge account
         else get the variance account from the po distribution */

       select decode(pod.destination_type_code,'EXPENSE',pod.code_combination_id,
                                                         pod.variance_account_id
                    ),
  	      decode(poll.match_option, 'P', pod.variance_account_id,
 	        decode(pod.destination_type_code,'EXPENSE', pod.code_combination_id,-1)),
	      poh.currency_code,
	      poh.rate_type,
	      decode(poll.match_option, 'P', pod.rate_date, trunc(p_wo_date))
       into   l_off_id,
 	      l_erv_id,
    	      l_wo_cc,
	      l_wo_ct,
	      l_wo_cd
       from   po_distributions_all    pod,
	      po_line_locations_all   poll,
	      po_headers_all	      poh
       where  pod.po_distribution_id = c_wo_rec.po_distribution_id
       and    pod.org_id = p_ou_id
       and    poh.po_header_id = pod.po_header_id
       and    poll.line_location_id = pod.line_location_id;

       l_stmt_num := 26;

       /* For the case of match to receipt, when NO rate is defined, use the rate and the currency conversion date from
          the po header */

       BEGIN

       select decode(poll.match_option, 'P',NVL(pod.rate,1),
                     gl_currency_api.get_rate(poh.currency_code, gsb.currency_code,
                                              trunc(p_wo_date),poh.rate_type)
                    )
          into l_wo_cr
         from  po_distributions_all   pod,
               po_line_locations_all  poll,
               po_headers_all         poh,
               gl_sets_of_books       gsb
         where pod.po_distribution_id  = c_wo_rec.po_distribution_id
           and pod.org_id              = p_ou_id
           and poh.po_header_id        = pod.po_header_id
           and poll.line_location_id   = pod.line_location_id
           and gsb.set_of_books_id     = pod.set_of_books_id ;

       EXCEPTION
       WHEN gl_currency_api.NO_RATE THEN

          Select NVL(pod.rate,1),
                 pod.rate_date
            into l_wo_cr,
                 l_wo_cd
            from po_distributions_all pod
          where pod.po_distribution_id = c_wo_rec.po_distribution_id
            and pod.org_id             = p_ou_id ;

       END;

       l_stmt_num := 28;

       /* Need to further determine ERV account if erv_id = -1 */

       if(((l_wo_cr is null) or (l_ent_sum is null)) and (l_erv_id is not null)) then
     --{
         l_erv_id := null;
     --}
       elsif(l_erv_id = -1) then
     --{
         if(c_wo_rec.l_tot_bal > (l_wo_cr * l_ent_sum)) then
       --{
           select  rate_var_gain_ccid
           into    l_erv_id
           from    financials_system_params_all
           where   org_id = p_ou_id;
       --}
         else
       --{
           select  rate_var_loss_ccid
           into    l_erv_id
           from    financials_system_params_all
           where   org_id = p_ou_id;
       --}
         end if; /* c_wo_rec.l_tot_bal > (l_wo_cr + l_ent_sum) */
     --}
       end if; /* ((l_wo_cr is null) or (l_ent_sum is null)) and (l_erv_id is not null) */

       l_stmt_num := 30;

       /*
          Insert the PO distribution information, as well as the extra values
          recently calcuated into the write-off headers table.
       */
       insert into cst_write_offs
       (
 	 write_off_id,
 	 transaction_date,
	 accrual_account_id,
	 offset_account_id,
	 erv_account_id,
	 write_off_amount,
 	 entered_amount,
 	 currency_code,
 	 currency_conversion_type,
	 currency_conversion_rate,
 	 currency_conversion_date,
 	 transaction_type_code,
 	 po_distribution_id,
	 reason_id,
	 comments,
 	 destination_type_code,
 	 inventory_item_id,
 	 vendor_id,
	 operating_unit_id,
         last_update_date,
         last_updated_by,
         last_update_login,
         creation_date,
         created_by,
         request_id,
         program_application_id,
         program_id,
         program_update_date
       )
       values
       (
   	 c_wo_rec.l_wo_id,
	 p_wo_date,
   	 c_wo_rec.accrual_account_id,
   	 l_off_id,
   	 l_erv_id,
   	 (-1) * c_wo_rec.l_tot_bal,
    	 (-1) * l_ent_sum,
    	 l_wo_cc,
    	 l_wo_ct,
   	 l_wo_cr,
    	 l_wo_cd,
    	 'WRITE OFF',
   	 c_wo_rec.po_distribution_id,
   	 p_rea_id,
   	 p_comments,
   	 c_wo_rec.destination_type_code,
   	 c_wo_rec.inventory_item_id,
   	 c_wo_rec.vendor_id,
   	 p_ou_id,
   	 sysdate,                     --last_update_date,
   	 FND_GLOBAL.USER_ID,          --last_updated_by,
   	 FND_GLOBAL.USER_ID,          --last_update_login,
   	 sysdate,                     --creation_date,
   	 FND_GLOBAL.USER_ID,          --created_by,
   	 FND_GLOBAL.CONC_REQUEST_ID,  --request_id,
   	 FND_GLOBAL.PROG_APPL_ID,     --program_application_id,
   	 FND_GLOBAL.CONC_PROGRAM_ID,  --program_id,
   	 sysdate                      --program_update_date
       );
   --}
     end loop; /* for c_wo_rec in c_wo(p_ou_id) */

     l_stmt_num := 35;
     /*
        First delete the individual transactions from cst_ap_po_reconciliation
        as to maintain referential integretiy.
     */
     delete from cst_ap_po_reconciliation capr
     where  exists (
            select 'X'
  	    from   cst_reconciliation_summary crs
  	    where  capr.operating_unit_id  = crs.operating_unit_id
	    and    capr.po_distribution_id = crs.po_distribution_id
	    and    capr.accrual_account_id = crs.accrual_account_id
 	    and    crs.write_off_select_flag = 'Y');

     l_stmt_num := 40;

     /*
        Once all the individual transaction have been deleted, removed the
        header information from cst_reconciliation_summary
     */
     delete from cst_reconciliation_summary
     where  operating_unit_id = p_ou_id
     and    write_off_select_flag = 'Y';

     l_stmt_num := 45;
     /*
        Call SLA's bulk events generator which uses the values previously
        inserted into SLA's event temp table
     */
     xla_events_pub_pkg.create_bulk_events(p_source_application_id => 201,
                                           p_application_id => 707,
	   			           p_ledger_id => p_sob_id,
				           p_entity_type_code => 'WO_ACCOUNTING_EVENTS');

     commit;
 --}
   else
 --{
     x_count := -1;
     return;
 --}
   end if; /* l_rows > 0 */

   x_count :=  l_rows;
   return;

   exception
     when others then
   --{
       rollback;
       x_count := -1;
       x_err_num := SQLCODE;
       x_err_code := NULL;
       x_err_msg := 'CST_Accrual_Rec_PVT.insert_appo_data_all() ' || SQLERRM;
       fnd_message.set_name('BOM','CST_UNEXPECTED');
       fnd_message.set_token('TOKEN',SQLERRM);
       if(l_unLog) then
         fnd_log.message(fnd_log.level_unexpected, g_log_header || '.' || l_api_name
			 || '(' || to_char(l_stmt_num) || ')', FALSE);
       end if;
       fnd_msg_pub.add;
       return;
   --}
 end insert_appo_data_all;

 -- Start of comments
 --	API name 	: Is_Reversible
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Checks whether a specific write-off distribution is reversible.
 --    			  A write-off is reversible if the write-off was performed in release 12 and later,
 --  			  has the transaction type code 'WRITE OFF', has not alredy been reversed and is
 --   			  not already part of another write-off distribution.
 --	Parameters	:
 --	IN		: p_wo_id	IN NUMBER		Required
 --				Write-Off Date
 --			: p_txn_c	IN VARCHAR2		Required
 --				Transaction Type
 --			: p_off_id	IN NUMBER		Required
 --				Offset Accont
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_count      	OUT NOCOPY NUBMER	Required
 --  			        Reversible Indicator
 --				FND_API.G_TRUE  => Reversible
 --				FND_API.G_FALSE	=> Not Reversible
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure is_reversible(
			p_wo_id in number,
			p_txn_c in varchar2,
			p_off_id in number,
			p_ou_id in number,
 		        x_count out nocopy varchar2,
		        x_err_num out nocopy number,
	                x_err_code out nocopy varchar2,
		        x_err_msg out nocopy varchar2) is

   l_api_version  constant number := 1.0;
   l_api_name	  constant varchar2(30) := 'is_reversible';
   l_full_name	  constant varchar2(60) := g_pkg_name || '.' || l_api_name;
   l_module	  constant varchar2(60) := 'cst.plsql.' || l_full_name;
   l_uLog 	  constant boolean := fnd_log.test(fnd_log.level_unexpected, l_module);
   l_unLog        constant boolean := l_uLog and (fnd_log.level_unexpected >= g_log_level);
   l_errorLog	  constant boolean := l_uLog and (fnd_log.level_error >= g_log_level);
   l_exceptionLog constant boolean := l_errorLog and (fnd_log.level_exception >= g_log_level);
   l_pLog 	  constant boolean := l_exceptionLog and (fnd_log.level_procedure >= g_log_level);
   l_sLog	  constant boolean := l_pLog and (fnd_log.level_statement >= g_log_level);
   l_stmt_num	  number;
   l_enabled      number;

 begin

   l_stmt_num := 5;

   if(l_pLog) then
     fnd_log.string(fnd_log.level_procedure, g_log_header || '.' || l_api_name ||
		    '.begin', 'is_reversible << '
		    || 'p_wo_id := ' || to_char(p_wo_id)
		    || 'p_txn_c := ' || p_txn_c
		    || 'p_off_id := ' || to_char(p_off_id)
		    || 'p_ou_id := ' || to_char(p_ou_id));
   end if;

   /* Print out the parameters to the Message Stack */
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Write-Of ID: ' || to_char(p_wo_id));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Transaction Type: ' || p_txn_c);
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Offset Account: ' || to_char(p_off_id));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Operating Unit: ' || to_char(p_ou_id));

   l_stmt_num := 10;

   /* Make sure distribution is not already a reversal */
   if(p_txn_c = 'WRITE OFF') then
 --{
     l_stmt_num := 15;
     /*
	Check whether the write-off was done in Release 12 or later
        Pre-Release 12 write-offs will not have an offset account
     */
     if(p_off_id is not null) then
   --{
       l_stmt_num := 20;
       /*
          Check whether current write-off has not already been reversed by
          searching the header table to see if the current distributions
          write-off ID is another distributions reversal ID
       */
       select  count(*)
       into    l_enabled
       from    cst_write_offs
       where   reversal_id = p_wo_id
       and     operating_unit_id = p_ou_id;
       if(l_enabled = 0) then
     --{
 	 l_stmt_num := 25;
         /*
            Finally check whether the current distribution has been part
            of another write-off by taking the current distribution's
            write-off ID and seeing if it matches a row's
            write_off_transaction_id column in the details table
         */
	 select  count(*)
	 into    l_enabled
	 from    cst_write_off_details
	 where   write_off_transaction_id = p_wo_id
         and     operating_unit_id = p_ou_id;
 	 if(l_enabled = 0) then
       --{
	   l_stmt_num := 30;
           /* If all the tests pass, write-off is reversible */
	   x_count := fnd_api.g_true;
	   return;
       --}
         end if; /* l_enabled = 0 */
     --}
       end if; /* l_enabled = 0 */
   --}
     end if; /* p_off_id is not null */
 --}
   end if; /* p_txn_c = 'WRITE OFF' */

   /* Indicates a test failed and therefore the write-off is not reversible */
   x_count := fnd_api.g_false;
   return;

   exception
     when others then
       rollback;
       x_count := fnd_api.g_false;
       x_err_num := SQLCODE;
       x_err_code := NULL;
       x_err_msg := 'CST_Accrual_Rec_PVT.is_reversible() ' || SQLERRM;
       fnd_message.set_name('BOM','CST_UNEXPECTED');
       fnd_message.set_token('TOKEN',SQLERRM);
       if(l_unLog) then
         fnd_log.message(fnd_log.level_unexpected, g_log_header || '.' || l_api_name
			 || '(' || to_char(l_stmt_num) || ')', FALSE);
       end if;
       fnd_msg_pub.add;
       return;

 end is_reversible;

 -- Start of comments
 --	API name 	: Reverse_Write_Offs
 --	Type		: Private
 --	Pre-reqs	: None.
 --	Function	: Performs a write-off reversal and insert distributions and/or
 --    			  individual transactions back into the appropriate tables.
 --			  If the reversing miscellaneous write-offs, then a write-off
 --                       reversal is created and the individual miscellaneous transactions
 --			  is inserted back into cst_misc_reconciliation.  If reversing an
 --			  AP and PO distribution, then a write-off reversal is created and all
 --   		 	  the individual AP and PO transactions in addition to all write-offs
 --			  and reversals sharing the same PO distribution ID and accrual account
 --			  are summed up and if they equal a non-zero value, they are inserted
 --			  into the cst_reconciliation_summary and cst_ap_po_reconciliation
 --			  as appropriate (see package body).
 --	Parameters	:
 --	IN		: p_wo_date	IN DATE			Required
 --				Write-Off Date
 -- 			: p_rea_id	IN NUMBER		Optional
 --				Write-Off Reason
 --			: p_comments	IN VARCHAR2		Optional
 --				Write-Off Comments
 --			: p_sob_id	IN NUMBER		Required
 --				Ledger/Set of Books
 --			: p_ou_id	IN NUMBER		Required
 --				Operating Unit Identifier
 --     OUT             : x_count      	OUT NOCOPY NUBMER	Required
 --  			        Success Indicator
 --				{x > 0} => Success
 --				-1	=> Failure
 --                     : x_err_num	OUT NOCOPY NUMBER	Required
 --                             Standard Error Parameter
 --                     : x_err_code	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --                     : x_err_msg	OUT NOCOPY VARCHAR2	Required
 --                             Standard Error Parameter
 --	Version	: Current version	1.0
 --		  Previous version 	1.0
 --		  Initial version 	1.0
 -- End of comments
 procedure reverse_write_offs(
 			    p_wo_date in date,
			    p_rea_id in number,
			    p_comments in varchar2,
			    p_sob_id in number,
			    p_ou_id in number,
   		            x_count out nocopy number,
		            x_err_num out nocopy number,
	                    x_err_code out nocopy varchar2,
		            x_err_msg out nocopy varchar2) is

   l_api_version  constant number := 1.0;
   l_api_name	  constant varchar2(30) := 'reverse_write_offs';
   l_full_name	  constant varchar2(60) := g_pkg_name || '.' || l_api_name;
   l_module	  constant varchar2(60) := 'cst.plsql.' || l_full_name;
   l_uLog 	  constant boolean := fnd_log.test(fnd_log.level_unexpected, l_module);
   l_unLog        constant boolean := l_uLog and (fnd_log.level_unexpected >= g_log_level);
   l_errorLog	  constant boolean := l_uLog and (fnd_log.level_error >= g_log_level);
   l_exceptionLog constant boolean := l_errorLog and (fnd_log.level_exception >= g_log_level);
   l_pLog 	  constant boolean := l_exceptionLog and (fnd_log.level_procedure >= g_log_level);
   l_sLog	  constant boolean := l_pLog and (fnd_log.level_statement >= g_log_level);
   l_stmt_num	  number;
   l_rows	  number;
   l_po_proc	  number;
   /* Cursor to hold all the distributions marked for reversal */
   cursor c_wo(l_ou_id number) is
   select po_accrual_write_offs_s.nextval l_wo_id,
	  write_off_id l_rev_id,
	  accrual_account_id,
	  offset_account_id,
	  erv_account_id,
	  write_off_amount amount,
	  entered_amount,
	  currency_code,
	  currency_conversion_type,
	  currency_conversion_rate,
	  currency_conversion_date,
	  po_distribution_id,
	  invoice_distribution_id,
	  inventory_transaction_id,
 	  destination_type_code,
	  inventory_item_id,
	  vendor_id,
	  legal_entity_id,
	  operating_unit_id,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by,
          request_id,
          program_application_id,
          program_id,
          program_update_date
   from   cst_write_offs
   where  operating_unit_id = l_ou_id
   and    write_off_select_flag = 'Y';

 begin

   l_stmt_num := 5;

   if(l_pLog) then
     fnd_log.string(fnd_log.level_procedure, g_log_header || '.' || l_api_name ||
		    '.begin', 'reverse_write_offs << '
		    || 'p_wo_date := ' || to_char(p_wo_date, 'YYYY/MM/DD HH24:MI:SS')
		    || 'p_rea_id := ' || to_char(p_rea_id)
		    || 'p_comments := ' || p_comments
		    || 'p_sob_id := ' || to_char(p_sob_id)
		    || 'p_ou_id := ' || to_char(p_ou_id));
   end if;

   /* Print out the parameters to the Message Stack */
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Reversal Date: ' || to_char(p_wo_date, 'YYYY/MM/DD HH24:MI:SS'));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Reversal Reason: ' || to_char(p_rea_id));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Comments: ' || p_comments);
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Set of Books: ' || to_char(p_sob_id));
   fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, 'Operating Unit: ' || to_char(p_ou_id));

   l_stmt_num := 10;

   /* Check that the user has selected distributions to reverse */
   select count(*)
   into   l_rows
   from   cst_write_offs
   where  operating_unit_id = p_ou_id
   and    write_off_select_flag = 'Y';

   if(l_rows > 0) then
 --{
     l_stmt_num := 15;

     for c_wo_rec in c_wo(p_ou_id) loop
   --{
       /* Insert the necessary information into SLA's event temp table */
       insert into xla_events_int_gt
       (
         application_id,
         ledger_id,
         legal_entity_id,
         entity_code,
      	 source_id_int_1,
      	 event_class_code,
      	 event_type_code,
      	 event_date,
      	 event_status_code,
         --BUG#7226250
      	 security_id_int_2,
      	 transaction_date,
         reference_date_1,
         transaction_number
       )
       values
       (
     	 707,
     	 p_sob_id,
     	 c_wo_rec.legal_entity_id,
     	 'WO_ACCOUNTING_EVENTS',
     	 c_wo_rec.l_wo_id,
     	 'ACCRUAL_WRITE_OFF',
     	'ACCRUAL_WRITE_OFF',
     	 p_wo_date,
     	 XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
     	 p_ou_id,
     	 p_wo_date,
         INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(p_wo_date,p_ou_id),
         to_char(c_wo_rec.l_wo_id)
       );

       l_stmt_num := 20;

       /* Insert the reversal into the headers table */
       insert into cst_write_offs
       (
	 write_off_id,
	 transaction_date,
 	 accrual_account_id,
 	 offset_account_id,
	 erv_account_id,
	 write_off_amount,
	 entered_amount,
	 currency_code,
 	 currency_conversion_type,
 	 currency_conversion_rate,
 	 currency_conversion_date,
	 transaction_type_code,
	 po_distribution_id,
         invoice_distribution_id,
         inventory_transaction_id,
	 reversal_id,
	 reason_id,
	 comments,
	 destination_type_code,
	 inventory_item_id,
	 vendor_id,
 	 legal_entity_id,
	 operating_unit_id,
         last_update_date,
         last_updated_by,
         last_update_login,
         creation_date,
         created_by,
         request_id,
         program_application_id,
         program_id,
         program_update_date
       )
       values
       (
	 c_wo_rec.l_wo_id,
	 p_wo_date,
	 c_wo_rec.accrual_account_id,
	 c_wo_rec.offset_account_id,
	 c_wo_rec.erv_account_id,
 	 (-1) * c_wo_rec.amount,
	 (-1) * c_wo_rec.entered_amount,
	 c_wo_rec.currency_code,
	 c_wo_rec.currency_conversion_type,
	 c_wo_rec.currency_conversion_rate,
	 c_wo_rec.currency_conversion_date,
	 'REVERSE WRITE OFF',
	 c_wo_rec.po_distribution_id,
         c_wo_rec.invoice_distribution_id,
         c_wo_rec.inventory_transaction_id,
	 c_wo_rec.l_rev_id,
	 p_rea_id,
	 p_comments,
	 c_wo_rec.destination_type_code,
	 c_wo_rec.inventory_item_id,
	 c_wo_rec.vendor_id,
	 c_wo_rec.legal_entity_id,
	 c_wo_rec.operating_unit_id,
         sysdate,                     --last_update_date,
         FND_GLOBAL.USER_ID,          --last_updated_by,
         FND_GLOBAL.USER_ID,          --last_update_login,
         sysdate,                     --creation_date,
         FND_GLOBAL.USER_ID,          --created_by,
         FND_GLOBAL.CONC_REQUEST_ID,  --request_id,
         FND_GLOBAL.PROG_APPL_ID,     --program_application_id,
         FND_GLOBAL.CONC_PROGRAM_ID,  --program_id,
         sysdate                      --program_update_date
       );

       l_stmt_num := 25;

       /*
          Insert the details from the previous write-off but with the new write-off ID
          into the write-off details table
       */
       insert into cst_write_off_details
       (
	 write_off_id,
	 transaction_date,
	 amount,
	 entered_amount,
	 quantity,
	 currency_code,
	 currency_conversion_type,
	 currency_conversion_rate,
	 currency_conversion_date,
	 transaction_type_code,
	 rcv_transaction_id,
	 invoice_distribution_id,
	 inventory_transaction_id,
	 write_off_transaction_id,
	 inventory_organization_id,
	 operating_unit_id,
         last_update_date,
         last_updated_by,
         last_update_login,
         creation_date,
         created_by,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         ae_header_id,
         ae_line_num
       )
       select c_wo_rec.l_wo_id,
  	      cwod.transaction_date,
	      cwod.amount,
	      cwod.entered_amount,
	      cwod.quantity,
	      cwod.currency_code,
	      cwod.currency_conversion_type,
	      cwod.currency_conversion_rate,
	      cwod.currency_conversion_date,
	      cwod.transaction_type_code,
	      cwod.rcv_transaction_id,
	      cwod.invoice_distribution_id,
	      cwod.inventory_transaction_id,
	      cwod.write_off_transaction_id,
	      cwod.inventory_organization_id,
	      cwod.operating_unit_id,
              sysdate,                     --last_update_date,
              FND_GLOBAL.USER_ID,          --last_updated_by,
              FND_GLOBAL.USER_ID,          --last_update_login,
              sysdate,                     --creation_date,
              FND_GLOBAL.USER_ID,          --created_by,
              FND_GLOBAL.CONC_REQUEST_ID,  --request_id,
              FND_GLOBAL.PROG_APPL_ID,     --program_application_id,
              FND_GLOBAL.CONC_PROGRAM_ID,  --program_id,
              sysdate,                     --program_update_date,
              cwod.ae_header_id,
              cwod.ae_line_num
       from   cst_write_off_details cwod
       where  cwod.write_off_id = c_wo_rec.l_rev_id
       and    cwod.operating_unit_id = c_wo_rec.operating_unit_id;

       l_stmt_num := 30;

       /* Need to re-insert transations, either Miscellaneous or AP-PO*/
       /* Doing Miscellaneous */
       if((c_wo_rec.po_distribution_id is null) or
          (c_wo_rec.inventory_transaction_id is not null and c_wo_rec.po_distribution_id is not null) or
          (c_wo_rec.invoice_distribution_id is not null)) then
     --{
	 l_stmt_num := 35;

         insert into cst_misc_reconciliation
         (
  	   transaction_date,
	   amount,
	   entered_amount,
	   quantity,
	   currency_code,
	   currency_conversion_type,
	   currency_conversion_rate,
	   currency_conversion_date,
	   invoice_distribution_id,
	   inventory_transaction_id,
	   po_distribution_id,
	   accrual_account_id,
	   transaction_type_code,
	   inventory_item_id,
	   vendor_id,
	   inventory_organization_id,
	   operating_unit_id,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           ae_header_id,
           ae_line_num
         )
         select cwod.transaction_date,
	        cwod.amount,
	        cwod.entered_amount,
	        cwod.quantity,
	        cwod.currency_code,
	        cwod.currency_conversion_type,
	        cwod.currency_conversion_rate,
	        cwod.currency_conversion_date,
	        cwod.invoice_distribution_id,
	        cwod.inventory_transaction_id,
	        cwo.po_distribution_id,
	        cwo.accrual_account_id,
	        cwod.transaction_type_code,
	        cwo.inventory_item_id,
	        cwo.vendor_id,
	        cwod.inventory_organization_id,
	        cwod.operating_unit_id,
                sysdate,                     --last_update_date,
                FND_GLOBAL.USER_ID,          --last_updated_by,
                FND_GLOBAL.USER_ID,          --last_update_login,
                sysdate,                     --creation_date,
                FND_GLOBAL.USER_ID,          --created_by,
                FND_GLOBAL.CONC_REQUEST_ID,  --request_id,
                FND_GLOBAL.PROG_APPL_ID,     --program_application_id,
                FND_GLOBAL.CONC_PROGRAM_ID,  --program_id,
                sysdate,                     --program_update_date,
                cwod.ae_header_id,
                cwod.ae_line_num
         from   cst_write_off_details cwod,
	        cst_write_offs	      cwo
         where  cwo.write_off_id = c_wo_rec.l_wo_id
         and    cwo.operating_unit_id = c_wo_rec.operating_unit_id
         and    cwod.write_off_id = cwo.write_off_id
         and    cwod.operating_unit_id = cwo.operating_unit_id;

	 l_stmt_num := 40;
     --}
       /* AP PO */
       elsif((c_wo_rec.po_distribution_id is not null) and
             (c_wo_rec.inventory_transaction_id is null) and
             (c_wo_rec.invoice_distribution_id is null)) then
     --{
	 l_stmt_num := 45;

         /*
            Look whether a rebuild has occurred, meaning CRS will have rows for a given
	    po_distribution_id/accrual_account_id pair
         */
         select count(*)
         into   l_po_proc
         from   cst_reconciliation_summary
         where  po_distribution_id = c_wo_rec.po_distribution_id
         and    accrual_account_id = c_wo_rec.accrual_account_id
         and    operating_unit_id  = c_wo_rec.operating_unit_id;

         /* No records in CRS so insert relevant records from CWOD and CWO  */
         if(l_po_proc = 0) then
       --{
	   l_stmt_num := 50;

           insert into cst_ap_po_reconciliation
     	   (
 	     transaction_date,
	     amount,
	     entered_amount,
	     quantity,
	     currency_code,
	     currency_conversion_type,
 	     currency_conversion_rate,
	     currency_conversion_date,
	     po_distribution_id,
	     rcv_transaction_id,
	     invoice_distribution_id,
	     accrual_account_id,
	     transaction_type_code,
	     write_off_id,
	     inventory_organization_id,
	     operating_unit_id,
             last_update_date,
       	     last_updated_by,
             last_update_login,
             creation_date,
             created_by,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             ae_header_id,
             ae_line_num
	   )
	   select cwod.transaction_date,
	          cwod.amount,
	          cwod.entered_amount,
	          cwod.quantity,
	          cwod.currency_code,
	          cwod.currency_conversion_type,
 	          cwod.currency_conversion_rate,
	          cwod.currency_conversion_date,
	          cwo.po_distribution_id,
	          cwod.rcv_transaction_id,
 	          cwod.invoice_distribution_id,
	          cwo.accrual_account_id,
	          cwod.transaction_type_code,
	          cwod.write_off_transaction_id,
	          cwod.inventory_organization_id,
	          cwod.operating_unit_id,
                  sysdate,                         --last_update_date,
                  FND_GLOBAL.USER_ID,              --last_updated_by,
                  FND_GLOBAL.USER_ID,              --last_update_login,
                  sysdate,                         --creation_date,
                  FND_GLOBAL.USER_ID,              --created_by,
                  FND_GLOBAL.CONC_REQUEST_ID,      --request_id,
                  FND_GLOBAL.PROG_APPL_ID,         --program_application_id,
                  FND_GLOBAL.CONC_PROGRAM_ID,      --program_id,
                  sysdate,                         --program_update_date,
                  cwod.ae_header_id,
                  cwod.ae_line_num
           from   cst_write_offs	 cwo,
	          cst_write_off_details  cwod
           where  cwo.write_off_id = c_wo_rec.l_wo_id
           and    cwo.po_distribution_id = c_wo_rec.po_distribution_id
           and    cwo.accrual_account_id = c_wo_rec.accrual_account_id
           and    cwo.operating_unit_id  = c_wo_rec.operating_unit_id
           and    cwod.write_off_id = cwo.write_off_id
           and    cwod.operating_unit_id = cwo.operating_unit_id;

	   l_stmt_num := 55;

           /* Next insert the new write-off header and reversal header into CAPR */
           insert into cst_ap_po_reconciliation
           (
	     transaction_date,
	     amount,
	     entered_amount,
	     currency_code,
	     currency_conversion_type,
 	     currency_conversion_rate,
	     currency_conversion_date,
	     po_distribution_id,
	     accrual_account_id,
	     transaction_type_code,
	     write_off_id,
	     operating_unit_id,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by,
             request_id,
             program_application_id,
             program_id,
             program_update_date
           )
           select cwo.transaction_date,
	          cwo.write_off_amount,
	          cwo.entered_amount,
	          cwo.currency_code,
                  cwo.currency_conversion_type,
 	          cwo.currency_conversion_rate,
	          cwo.currency_conversion_date,
                  cwo.po_distribution_id,
                  cwo.accrual_account_id,
	          cwo.transaction_type_code,
	          cwo.write_off_id,
	          cwo.operating_unit_id,
                  sysdate,                            --last_update_date,
                  FND_GLOBAL.USER_ID,                 --last_updated_by,
                  FND_GLOBAL.USER_ID,                 --last_update_login,
                  sysdate,                            --creation_date,
                  FND_GLOBAL.USER_ID,                 --created_by,
                  FND_GLOBAL.CONC_REQUEST_ID,         --request_id,
                  FND_GLOBAL.PROG_APPL_ID,            --program_application_id,
                  FND_GLOBAL.CONC_PROGRAM_ID,         --program_id,
                  sysdate                             --program_update_date
           from   cst_write_offs cwo
           where  cwo.write_off_id in (c_wo_rec.l_wo_id, c_wo_rec.l_rev_id)
           and    cwo.po_distribution_id = c_wo_rec.po_distribution_id
           and    cwo.accrual_account_id = c_wo_rec.accrual_account_id
           and    cwo.operating_unit_id  = c_wo_rec.operating_unit_id;

	   l_stmt_num := 60;

           /* Insert the data into the summary table */
           insert into cst_reconciliation_summary
           (
	     po_distribution_id,
	     accrual_account_id,
	     po_balance,
             ap_balance,
	     write_off_balance,
	     last_receipt_date,
	     last_invoice_dist_date,
	     last_write_off_date,
	     inventory_item_id,
	     vendor_id,
	     destination_type_code,
	     operating_unit_id,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by,
             request_id,
             program_application_id,
             program_id,
             program_update_date
           )
           select cwo.po_distribution_id,
	          cwo.accrual_account_id,
	   	  sum(decode(capr.write_off_id,NULL,
                    decode(capr.invoice_distribution_id,NULL,
		      capr.amount,0),0)),
	          sum(decode(capr.invoice_distribution_id,NULL,0,capr.amount)),
	          sum(decode(capr.write_off_id,NULL,0,capr.amount)),
	          max(decode(capr.write_off_id,NULL,
                    decode(capr.invoice_distribution_id,NULL,
		      capr.transaction_date,NULL),NULL)),
	          max(decode(capr.invoice_distribution_id,NULL,NULL,capr.transaction_date)),
	          max(decode(capr.write_off_id,NULL,NULL,capr.transaction_date)),
		  cwo.inventorY_item_id,
		  cwo.vendor_id,
		  cwo.destination_type_code,
		  cwo.operating_unit_id,
                  sysdate,                             --last_update_date,
                  FND_GLOBAL.USER_ID,                  --last_updated_by,
                  FND_GLOBAL.USER_ID,                  --last_update_login,
                  sysdate,                             --creation_date,
                  FND_GLOBAL.USER_ID,                  --created_by,
                  FND_GLOBAL.CONC_REQUEST_ID,          --request_id,
                  FND_GLOBAL.PROG_APPL_ID,             --program_application_id,
                  FND_GLOBAL.CONC_PROGRAM_ID,          --program_id,
                  sysdate                              --program_update_date
	   from   cst_ap_po_reconciliation  capr,
	   	  cst_write_offs	    cwo
           where  cwo.write_off_id = c_wo_rec.l_wo_id
 	   and    cwo.operating_unit_id = c_wo_rec.operating_unit_id
	   and    capr.po_distribution_id = cwo.po_distribution_id
	   and    capr.accrual_account_id = cwo.accrual_account_id
    	   and    capr.operating_unit_id  = cwo.operating_unit_id
	   group by cwo.po_distribution_id,
	      	    cwo.accrual_account_id,
		    cwo.inventory_item_id,
		    cwo.vendor_id,
		    cwo.destination_type_code,
		    cwo.operating_unit_id,
                    cwo.last_update_date,
                    cwo.last_updated_by,
                    cwo.last_update_login,
                    cwo.creation_date,
                    cwo.created_by,
                    cwo.request_id,
                    cwo.program_application_id,
                    cwo.program_id,
                    cwo.program_update_date;

	   l_stmt_num := 65;
       --}
           /*
             Rebuild has occured, decide if reversal would balance the account
             for the given po distribution ID
           */
         else
       --{
	   l_stmt_num := 70;

           select  (po_balance + ap_balance + write_off_balance)
           into    l_po_proc
           from    cst_reconciliation_summary
           where   po_distribution_id = c_wo_rec.po_distribution_id
           and     accrual_account_id = c_wo_rec.accrual_account_id
           and     operating_unit_id  = c_wo_rec.operating_unit_id;

           /* If it balances, remove entries from reconciliation tables */
           if(l_po_proc + (-1 * c_wo_rec.amount) = 0) then
         --{
	     l_stmt_num := 75;

             delete  from cst_ap_po_reconciliation
             where   po_distribution_id = c_wo_rec.po_distribution_id
             and     accrual_account_id = c_wo_rec.accrual_account_id
             and     operating_unit_id  = c_wo_rec.operating_unit_id;

	     l_stmt_num := 80;

             delete  from cst_reconciliation_summary
             where   po_distribution_id = c_wo_rec.po_distribution_id
             and     accrual_account_id = c_wo_rec.accrual_account_id
             and     operating_unit_id  = c_wo_rec.operating_unit_id;
         --}
         /* If it doesn't, update wo_balance in CRS and insert reversal only in CAPR */
           else
         --{
	     l_stmt_num := 85;

             update  cst_reconciliation_summary crs
             set     crs.write_off_balance = crs.write_off_balance + (-1 * c_wo_rec.amount)
             where   po_distribution_id = c_wo_rec.po_distribution_id
             and     accrual_account_id = c_wo_rec.accrual_account_id
             and     operating_unit_id  = c_wo_rec.operating_unit_id;

	     l_stmt_num := 90;

             insert into cst_ap_po_reconciliation
             (
		transaction_date,
		amount,
		entered_amount,
		currency_code,
		currency_conversion_type,
 		currency_conversion_rate,
	        currency_conversion_date,
		po_distribution_id,
		accrual_account_id,
		transaction_type_code,
		write_off_id,
		operating_unit_id,
        	last_update_date,
       		last_updated_by,
        	last_update_login,
        	creation_date,
        	created_by,
        	request_id,
        	program_application_id,
        	program_id,
        	program_update_date
             )
             select   cwo.transaction_date,
		      cwo.write_off_amount,
		      cwo.entered_amount,
		      cwo.currency_code,
		      cwo.currency_conversion_type,
 		      cwo.currency_conversion_rate,
	              cwo.currency_conversion_date,
		      cwo.po_distribution_id,
		      cwo.accrual_account_id,
		      cwo.transaction_type_code,
		      cwo.write_off_id,
		      cwo.operating_unit_id,
	              sysdate,                      --last_update_date,
        	      FND_GLOBAL.USER_ID,           --last_updated_by,
        	      FND_GLOBAL.USER_ID,           --last_update_login,
        	      sysdate,                      --creation_date,
        	      FND_GLOBAL.USER_ID,           --created_by,
        	      FND_GLOBAL.CONC_REQUEST_ID,   --request_id,
        	      FND_GLOBAL.PROG_APPL_ID,      --program_application_id,
        	      FND_GLOBAL.CONC_PROGRAM_ID,   --program_id,
        	      sysdate                       --program_update_date
             from     cst_write_offs cwo
             where    cwo.write_off_id = c_wo_rec.l_wo_id
             and      cwo.po_distribution_id = c_wo_rec.po_distribution_id
             and      cwo.accrual_account_id = c_wo_rec.accrual_account_id
             and      cwo.operating_unit_id  = c_wo_rec.operating_unit_id;

	     l_stmt_num := 95;
         --}
           end if; /* l_po_proc + (-1 * c_wo_rec.amount) = 0 */
       --}
         end if; /* l_po_proc = 0 */
     --}
       end if; /* (c_wo_rec.po_distribution_id is null) or
                  (c_wo_rec.invoice_distribution_id is not null),
		  (c_wo_rec.po_distribution_id is null) or
                  (c_wo_rec.invoice_distribution_id is not null)
	       */
   --}
     end loop; /* for c_wo_rec in c_wo(p_ou_id) */

     l_stmt_num := 100;
     /*
        Call SLA's bulk events generator which uses the values previously
        inserted into SLA's event temp table
     */
     xla_events_pub_pkg.create_bulk_events(p_source_application_id => 201,
                                           p_application_id => 707,
				           p_ledger_id => p_sob_id,
				           p_entity_type_code => 'WO_ACCOUNTING_EVENTS');

     /* need to reset the write_off_select_flag back  CWO back to NULL */

     Update cst_write_offs
     set   write_off_select_flag = NULL
     where operating_unit_id = p_ou_id
     and   write_off_select_flag = 'Y';

     commit;
 --}
   else
 --{
     x_count := -1;
     return;
 --}
   end if; /* l_rows > 0 */

   x_count :=  l_rows;
   return;

   exception
     when others then
   --{
       rollback;
       x_count := -1;
       x_err_num := SQLCODE;
       x_err_code := NULL;
       x_err_msg := 'CST_Accrual_Rec_PVT.reverse_write_offs() ' || SQLERRM;
       fnd_message.set_name('BOM','CST_UNEXPECTED');
       fnd_message.set_token('TOKEN',SQLERRM);
       if(l_unLog) then
         fnd_log.message(fnd_log.level_unexpected, g_log_header || '.' || l_api_name
			 || '(' || to_char(l_stmt_num) || ')', FALSE);
       end if;
       fnd_msg_pub.add;
       return;
   --}
 end reverse_write_offs;

end CST_ACCRUAL_REC_PVT;

/
