--------------------------------------------------------
--  DDL for Package Body PAY_PAYROLL_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYROLL_ACTIONS_PKG" AS
/* $Header: pypra02t.pkb 120.8.12010000.2 2008/08/06 08:14:26 ubhat ship $
--
   PRODUCT
   Oracle*Payroll
   --
   NAME
      pypra02t.pkb
   --
   DESCRIPTION
      Contains routines used to support the Payroll Action level window
      Payroll Process Results form.
   --
   MODIFIED (DD-MON-YYYY)
   dkerr	 40.0      02-NOV-1993        Created
   dkerr	 40.5      11-APP-1996        Added header
					      Modified get_status to display details
					      for voided payments process actions.
   jalloun                 30-JUL-1996        Added error handling.
   dkerr         40.11     18-MAR-1998        Added bind variable routines for
                                              bug 643154.
   nbristow      40.12     26-MAY-1998        Added name value for Archive
                                              processes.
   nbristow      40.13     02-JUN-1998        Now check report category
                                              for Archive process.
   mreid        110.4      10-SEP-1998        Removed show errors.
   nbristow     110.5      14-SEP-1998        Added GRE for the archiver.
   mreid        110.6      18-SEP-1998        Fixed truncated lines in
                                              set_where procedure.
   sdoshi       115.8      06-APR-1999        Flexible Dates Conversion
   mreid        115.9      07-MAR-2000        Changed get_archiver cursor for
                                              performance bugfix 1224836
   mreid        115.11     20-APR-2001        Bugfix 1711873 - added hint to
                                              full_name select
   mreid        115.13     28-JUN-2001        Bugfix 1855543 - rewrote
                                              balance adjustment name select.
   exjones      115.14     14-AUG-2001        Allow the g_server_validate thing
                                              to switch off the v_name fetch
                                              for performance in PAYWSACT
   jtomkins     115.15     30-OCT-2001        Added function latest_balance_exists
                                              for performance support of
                                              pay_balances_v (1509490)
   kkawol       115.16     02-NOV-2001        v_name procedure altered for purge.
                                              Added get_purge_phase.
   dsaxby       115.17     28-JAN-2002        Added dbdrv commands.
   jbarker      115.18     06-SEP-2002        Added support for BEE status type in
                                              v_name procedure.
   alogue       115.20     06-JAN-2003        Performance fix to get_balance_adjustment
                                              in v_name function. Bug 2653089.
   mreid        115.21     24-FEB-2003        Bug 2802446 - corrected possible
                                              invalid number in US archive
                                              retrieval (added Hint)
   SuSivasu     115.22     04-APR-2003        Fixed the issue in Bug 2802446, where by
                                              using pay_core_utils.get_parameter to extract GRE info.
   JBarker      115.23     11-JUN-2003	      Added decode_cheque_type function
   alogue       115.24     24-FEB-2003        Bug 3166075 - fix v_name procedure for
                                              archiver.
   tvankayl     115.25     29-DEC-2003        Bug 3261430 - v_name procedure
					      modified to return process names
					      for all archiver processes.
   alogue       115.26     24-JUN-2004        Further Performance fixes to get_person_name
                                              and get_balance_adjustment in v_name
                                              function. Bug 3720619.
   adkumar      115.27     30-JUL-2004        Bug No. 3665606. Batch Balance Adjustment process
                                              should display <Assignment Set> - <Element Name>
					      becuase the process may have multiple assignment
					      actions.
   tvankayl     115.28     29-AUG-2005        Bug 4584489. Support for Action Type 'CP'.
   SuSivasu     115.29     21-OCT-2005        Added support for SERVER_VALIDATION in
                                              get_char_bindvar.
   alogue       115.30     04-JAN-2006        Performance Repository fix to get_archiver
                                              cursor.
   alogue       115.31     28-MAR-2007        Support for single latest balance table in
                                              latest_balance_exists. Bug 5956216.
   alogue       115.32     26-JUL-2007        Bug 6130796 - check within v_name procedure
                                              pay_payroll_actions_pkg.get_char_bindvar('ACTION_TYPE')
                                              is same as action_type passed in.
   mshingan     115.33     21-AUG-2007        Bug 6353676 - Translated element set name is used.
                                              Cursor get_element_set_name is using pay_element_sets_tl
                                              instead of pay_element_sets.
   mshingan     115.34     21-AUG-2007        Bug 6353676 - changed declaration of variable l_eltset.
   mshingan     115.35     22-AUG-2007        Bug 6353676 - Translated element set name functionality
                                              is available only in r12 and not in 11i.Hence added
                                              new cursor for R12.
   ckesanap     115.36     08-Jul-2008        Bug 5892723 - Modified the v_name() procedure for
                                              action_type 'V'. Assignment set is passed as Name for
					      batch reversal process.
*/
--
 --
 --  GLOBAL VARIABLES
 --
 g_business_group_id 		number ;
 g_payroll_id        		number ;
 g_period_date_from  		date   ;
 g_period_date_to    		date   ;
 g_action_type       		varchar2(60);
 g_server_validate   		boolean;
 g_cached_business_group_id	number;        -- used in decode_cheque_type function
 g_cached_cheque_type		varchar2(30);  -- used in decode_cheque_type function
 --
 --  PRIVATE PROCEDURES
 --
 -- To simplify patching. This routine does not require the db patch which gives
 -- the required purity assertion to raise_application_error. It simply raises a value_error
 --
 procedure invalid_argument( p_procedure_name in varchar2,
                             p_parameter_name in varchar2 ) is
 begin
    raise value_error ;
 end invalid_argument;
--
 --  PUBLIC PROCEDURES
 --
 procedure update_row(p_rowid                          in varchar2,
		      p_action_status                  in varchar2 ) is
  begin
  --
   update PAY_PAYROLL_ACTIONS
   set    ACTION_STATUS             = p_action_status
    where  ROWID = p_rowid;
  --
  end update_row;
--
------------------------------------------------------------------------------------
  procedure delete_row(p_rowid   in varchar2) is
  --
  begin
  --
    delete from PAY_PAYROLL_ACTIONS
    where  ROWID = p_rowid;
  --
  end delete_row;
--
------------------------------------------------------------------------------------
  procedure lock_row (p_rowid                          in varchar2,
		      p_action_status                  in varchar2 ) is
--
  --
    cursor C is select *
                from   PAY_PAYROLL_ACTIONS
                where  rowid = p_rowid
                for update of PAYROLL_ACTION_ID NOWAIT ;
  --
    rowinfo  C%rowtype;
  --
  begin
  --
    open C;
    fetch C into rowinfo;
    close C;
    --
    if ( (rowinfo.ACTION_STATUS             = p_action_status)
     or  (rowinfo.ACTION_STATUS             is null and p_action_status
	  is null ))
    then
       return ;
    else
       fnd_message.set_name( 'FND' , 'FORM_RECORD_CHANGED');
       app_exception.raise_exception ;
    end if;
  end lock_row;
--
------------------------------------------------------------------------------------
 function v_action_status(p_payroll_action_id     in number,
                          p_payroll_action_status in varchar2,
			  p_request_id            in number)
      return varchar2 is
 begin
   return v_action_status(p_payroll_action_id,
                          p_payroll_action_status,
                          p_request_id,
                          FALSE);
 end v_action_status;
 --
 function v_action_status(p_payroll_action_id     in number,
                          p_payroll_action_status in varchar2,
			  p_request_id            in number,
                          p_force                 in boolean)
      return varchar2 is
 l_status      varchar2(80) ;
 l_dummy       number ;
--
 cursor c1 is
     select 1
     from   pay_assignment_actions
     where  payroll_action_id = p_payroll_action_id
     and    action_status in ('E','M','U');
--
 cursor c2 is
    select status.meaning
    from   fnd_concurrent_requests r,
	   fnd_lookups		   status
    where  r.request_id       = p_request_id
    and    r.status_code      = status.lookup_code
    and    r.phase_code       = 'C'
    and    status.lookup_type = 'CP_STATUS_CODE' ;
--
 begin
 --
   if (not p_force) and (not g_server_validate) then
     return hr_general.decode_lookup('ACTION_STATUS',p_payroll_action_status);
   end if;
 --
   if ( p_payroll_action_status = 'C' ) then
--
      open c1 ;
      fetch c1 into l_dummy ;
      if c1%found then
         l_status := hr_general.decode_lookup( 'ACTION_STATUS' , 'I') ;
      else
         l_status := hr_general.decode_lookup( 'ACTION_STATUS' , 'C') ;
      end if ;
      close c1 ;
--
   elsif ( p_payroll_action_status = 'P' and p_request_id is not null ) then
--
      -- If the Payroll Action is marked as Processing check that the
      -- concurrent request is not already complete. If it is complete
      -- then return the request status otherwise decode the 'P' status.
--
      open c2 ;
      fetch c2 into l_status ;
      if c2%notfound
      then
	  l_status := hr_general.decode_lookup('ACTION_STATUS','P');
      end if;
      close c2 ;
--
   else
--
      l_status := hr_general.decode_lookup('ACTION_STATUS',p_payroll_action_status ) ;
--
   end if ;
   --
   return l_status ;
 --
 end v_action_status;
--
------------------------------------------------------------------------------------
 function v_messages_exist(p_payroll_action_id in number) return varchar2  is
 l_status varchar2(1) ;
 l_dummy  number ;
 cursor c1 is
    select 1
    from   pay_message_lines
    where  source_id   = p_payroll_action_id
    and    source_type = 'P'   ;
  begin
      open c1 ;
      fetch c1 into l_dummy ;
      if c1%found then
         l_status := 'Y' ;
      else
         l_status := 'N' ;
      end if ;
      close c1 ;
   --
   return (l_status) ;
 --
 end v_messages_exist ;
--
 function  v_name(p_payroll_action_id     in number,
                  p_action_type           in varchar2,
                  p_consolidation_set_id  in number,
                  p_display_run_number    in number,
                  p_element_set_id        in number,
                  p_assignment_set_id     in number,
                  p_effective_date        in date ) return varchar2 is
 begin
   return v_name(
     p_payroll_action_id,
     p_action_type,
     p_consolidation_set_id,
     p_display_run_number,
     p_element_set_id,
     p_assignment_set_id,
     p_effective_date,
     FALSE
   );
 end v_name;
--
 function  v_name(p_payroll_action_id     in number,
                  p_action_type           in varchar2,
                  p_consolidation_set_id  in number,
                  p_display_run_number    in number,
                  p_element_set_id        in number,
                  p_assignment_set_id     in number,
                  p_effective_date        in date,
                  p_force                 in boolean ) return varchar2 is
l_status varchar2(2000) ;
l_element_name pay_element_types_f_tl.element_name%type;
l_asset   hr_assignment_sets.assignment_set_name%type ;
l_eltset  pay_element_sets_tl.element_set_name%type ;
l_dummy  number ;
l_report_type pay_payroll_actions.report_type%type;

--bug no. 3665606
l_element_type_id   pay_payroll_actions.element_type_id%type;
l_legislative_parameters pay_payroll_actions.legislative_parameters%type;


cursor get_consolidation_set is
   select consolidation_set_name
   from   pay_consolidation_sets
   where  consolidation_set_id = p_consolidation_set_id ;
--
--
cursor get_element_set is
   select els.element_set_name
   from   pay_element_sets    els
   where  els.element_set_id  = p_element_set_id ;

-- Bug 6353676
-- the translated Element Set Name is available in R12 only.
cursor get_element_set_r12 is
   select pes_tl.element_set_name
   from   pay_element_sets_tl pes_tl
   where  pes_tl.element_set_id  = p_element_set_id
   and	  pes_tl.language = USERENV('LANG');
--
cursor get_assignment_set is
   select ast.assignment_set_name
   from   hr_assignment_sets ast
   where  ast.assignment_set_id = p_assignment_set_id;
--
cursor get_purge_phase is
   select hr_general.decode_lookup('PURGE_PHASE', to_char(ppa.purge_phase))
   from   pay_payroll_actions ppa
   where  ppa.payroll_action_id = p_payroll_action_id;
--
cursor get_person_name is
  select /*+ INDEX
                   (aac PAY_ASSIGNMENT_ACTIONS_N50,
                    peo PER_PEOPLE_F_PK,
                    asg PER_ASSIGNMENTS_F_PK)
             USE_NL(aac, peo, asg) */
         peo.full_name
 	,pac.element_type_id        --bug no. 3665606
	,pac.legislative_parameters --bug no. 3665606
  from   pay_assignment_actions aac,
         pay_payroll_actions    pac,
         per_all_people_f           peo,
         per_all_assignments_f      asg
  where  pac.payroll_action_id = p_payroll_action_id
  and    aac.payroll_action_id = pac.payroll_action_id
  and    asg.assignment_id     = aac.assignment_id
  and    p_effective_date between asg.effective_start_date
                          and    asg.effective_end_date
  and    peo.person_id         = asg.person_id
  and    p_effective_date between peo.effective_start_date
                          and    peo.effective_end_date  ;
--
--
cursor get_balance_adjustment is
  select /*+ ORDERED
           INDEX(rrs PAY_RUN_RESULTS_N50)
           USE_NL(rrs)*/
         tl.element_name
  from   pay_payroll_actions    pac,
         pay_assignment_actions aac,
         pay_run_results        rrs,
         pay_element_types_f    ety,
         pay_element_types_f_tl tl
  where  pac.payroll_action_id    = p_payroll_action_id
  and    aac.payroll_action_id    = pac.payroll_action_id
  and    aac.assignment_action_id = rrs.assignment_action_id
  and    rrs.element_type_id      = ety.element_type_id
  and    ety.element_type_id      = tl.element_type_id
  and    p_effective_date between ety.effective_start_date
                          and     ety.effective_end_date;
--
-- Get the archive details for the SQWL
-- Note that this has some US specific coding.
--
cursor get_archiver is
select /*+ INDEX (pac PAY_PAYROLL_ACTIONS_PK) */
       pus.state_name||'-'||pac.report_type||decode(hou.name,
                                        NULL, NULL, '-'||hou.name)
from   pay_us_states pus,
       hr_organization_units hou,
       pay_payroll_actions pac,
       per_business_groups_perf bg
where pac.payroll_action_id = p_payroll_action_id
and   pac.report_qualifier = pus.state_abbrev
and   pac.report_category is not null
and   bg.business_group_id = pac.business_group_id
and   bg.legislation_code in ('US', 'CA')
and   hou.organization_id(+) = pay_core_utils.get_parameter('TRANSFER_GRE',pac.legislative_parameters)
--
--                        decode(instr(pac.legislative_parameters,
--                                     'TRANSFER_GRE'),
--                               0, -1,
--                               substr(pac.legislative_parameters,
--                                      instr(pac.legislative_parameters,
--                                            'TRANSFER_GRE') + 13)
--                              )
union
select /*+ INDEX (pac PAY_PAYROLL_ACTIONS_PK) */
       'Federal-'||pac.report_type||decode(hou.name,
                                 NULL, NULL, '-'||hou.name)
from    hr_all_organization_units hou,
        pay_payroll_actions pac
where pac.payroll_action_id = p_payroll_action_id
and   pac.report_category is not null
and   pac.report_qualifier = 'FED'
and   hou.organization_id(+) = pay_core_utils.get_parameter('TRANSFER_GRE',pac.legislative_parameters);
--
--                         decode(instr(pac.legislative_parameters,
--                                     'TRANSFER_GRE'),
--                               0, -1,
--                               substr(pac.legislative_parameters,
--                                      instr(pac.legislative_parameters,
--                                            'TRANSFER_GRE') + 13)
--                              );
--
--
cursor get_archiver_gu is
-- derives the process names for Generic Upgrade Archiver Processes.
select pud.name
from pay_upgrade_definitions_vl pud,
     pay_payroll_actions pac
where pac.payroll_action_id = p_payroll_action_id
  and pud.short_name = pay_core_utils.get_parameter('UPG_DEF_NAME',pac.legislative_parameters);

cursor get_report_type is
select pac.report_type
from  pay_payroll_actions pac
where pac.payroll_action_id = p_payroll_action_id;


cursor get_archiver_others is
select rfmtl.display_name
from   pay_payroll_actions pac,
       pay_report_format_mappings_f rfm,
       pay_report_format_mappings_tl rfmtl
where pac.payroll_action_id = p_payroll_action_id
  and pac.report_type = rfm.report_type
  and pac.report_qualifier = rfm.report_qualifier
  and pac.report_category  = rfm.report_category
  and p_effective_date between rfm.effective_start_date and rfm.effective_end_date
  and rfm.report_format_mapping_id = rfmtl.report_format_mapping_id
  and rfmtl.language = USERENV('LANG');


-- In the case of the Void process the payroll action of the assoicated
-- ChequeWriter run is not kept on the void payroll action record.
-- Instead it has to be retrieved through the interlock records it retrieves.
--
cursor get_void_chq is
  select fnd_date.date_to_canonical(pacc.effective_date)||'-'||to_char(pacv.start_cheque_number)
			    ||'-'||to_char(pacv.end_cheque_number)
  from   pay_payroll_actions pacc,
	 pay_payroll_actions pacv
  where  pacv.payroll_action_id = p_payroll_action_id
  and    pacc.payroll_action_id = pacv.target_payroll_action_id ;
--
cursor batch_names is
  select pbh.batch_name
  from pay_batch_headers pbh,
       pay_payroll_actions ppa
 where ppa.batch_id = pbh.batch_id
   and ppa.payroll_action_id = p_payroll_action_id;
--
begin
   -- Don't do anything if we've switched off this fetch from the
   -- form, just return quickly for the view fetch, we'll fill in
   -- the details manually later (in the POST-QUERY)
   -- N.B. This means you can't QBE on the action Name
   if (not p_force) and (not g_server_validate) then
     RETURN NULL;
   end if;
--
   if pay_payroll_actions_pkg.get_char_bindvar('ACTION_TYPE') is not null then
      if ( p_action_type <> pay_payroll_actions_pkg.get_char_bindvar('ACTION_TYPE') ) then
         RETURN NULL;
      end if;
   end if;
--
   if ( p_action_type in  ( 'C' , 'P' , 'M' , 'T' , 'H' , 'A', 'CP' ) ) then
      open  get_consolidation_set ;
      fetch get_consolidation_set into l_status ;
      close get_consolidation_set ;
   elsif ( p_action_type = 'R' ) then
--
      if ( p_assignment_set_id is not null ) then
         open get_assignment_set ;
         fetch get_assignment_set into l_asset ;
	 close get_assignment_set ;
      end if;

      if ( p_element_set_id is not null ) then
        if (PAY_ADHOC_UTILS_PKG.chk_post_r11i = 'Y') then
            open get_element_set_r12 ;
            fetch get_element_set_r12 into l_eltset ;
            close get_element_set_r12 ;
        else
            open get_element_set ;
            fetch get_element_set into l_eltset ;
            close get_element_set ;
        end if;
      end if;
      l_status := p_display_run_number||'-'||l_asset||'-'||l_eltset ;
--
   elsif ( p_action_type = 'V' ) THEN                                   -- Bug 5892723
       if ( p_assignment_set_id is not null ) then
         open get_assignment_set ;
         fetch get_assignment_set into l_asset ;
	     close get_assignment_set ;
	     l_status := l_asset;
       else
         open get_person_name ;
         fetch get_person_name into l_status, l_element_type_id, l_legislative_parameters;
         close get_person_name ;
       end if;
   elsif ( p_action_type in ( 'Q' , 'E' ) ) then
--
      open get_person_name ;
      fetch get_person_name into l_status, l_element_type_id, l_legislative_parameters;
      close get_person_name ;
      if ( p_action_type = 'Q' ) then
         l_status := p_display_run_number||'-'||l_status ;
      end if;
--
   elsif ( p_action_type = 'B' ) then
--
      open get_person_name;
      fetch get_person_name into l_status, l_element_type_id, l_legislative_parameters;
      close get_person_name;
      open  get_balance_adjustment ;
      fetch get_balance_adjustment into l_element_name;
      close get_balance_adjustment ;

     --bug no. 3665606
    /* l_status := l_status||'-'||l_element_name; */

      -- Batch Balance Adjustment by PYUGEN
      if l_element_type_id is not null then
         if p_assignment_set_id is not null then
            open get_assignment_set ;
            fetch get_assignment_set into l_asset ;
   	    close get_assignment_set ;
	    l_status := l_asset||'-'||l_element_name;
         else
	    l_status := l_element_name;
         end if;
      elsif l_legislative_parameters is not null then
         --
         -- Batch Balance Adjustment by pay_bal_adjust.init_batch
         --
         l_status := l_legislative_parameters;
      else
         -- Ordinary Balance Adjustment
         --
         -- If no batch_name is set for pay_bal_adjust.init_batch procedure in
         -- batch balance adjustment, v_name will pass through this routine.
         --
         l_status := l_status||'-'||l_element_name;
      end if;
      --
   elsif ( p_action_type = 'D' ) then
--
      open  get_void_chq  ;
      fetch get_void_chq into l_status ;
      close get_void_chq  ;
   elsif ( p_action_type = 'X' ) then

      open  get_archiver  ;
      fetch get_archiver into l_status ;
      if get_archiver%notfound then
         l_status := null;
      end if;
      close get_archiver  ;

      if l_status is null then
        open  get_report_type;
        fetch get_report_type into l_report_type ;
        close get_report_type ;

	if l_report_type = 'GENERIC_UPGRADE' then
	   open  get_archiver_gu  ;
      	   fetch get_archiver_gu into l_status ;
           if get_archiver_gu%notfound then
                l_status := null;
	   end if;
	   close get_archiver_gu ;
	else
	   open get_archiver_others;
	   fetch get_archiver_others into l_status;
	   if get_archiver_others%notfound then
                l_status := null;
           end if;
           close get_archiver_others;
        end if;

      end if;
--
   elsif ( p_action_type = 'Z' ) then

      open  get_purge_phase  ;
      fetch get_purge_phase into l_status ;
      if get_purge_phase%notfound then
         l_status := null;
      end if;
      close get_purge_phase;
--
   elsif ( p_action_type = 'BEE' ) then
--
   open batch_names;
   fetch batch_names into l_status;
   if batch_names%notfound then
      l_status := null;
   end if;
   close batch_names;
--
   else
      l_status := null ;
   end if;
--
--
   return (l_status) ;
--
end v_name;
-----------------------------------------------------------------------------------
 procedure set_query_bindvar( p_context_name  in varchar2,
                              p_context_value in varchar2 ) is
 begin

      hr_utility.trace( 'pay_payroll_actions_pkg.set_query_bindvar : '
                        ||p_context_name||'='||p_context_value);

      if ( upper(p_context_name) = 'BUSINESS_GROUP_ID' )
      then
            g_business_group_id := to_number(p_context_value) ;
      elsif ( upper(p_context_name) = 'PAYROLL_ID' )
      then
            g_payroll_id := to_number(p_context_value) ;
      elsif ( upper(p_context_name) = 'PERIOD_DATE_FROM' )
      then
            g_period_date_from := to_date(p_context_value,'YYYY/MM/DD');
      elsif ( upper(p_context_name) = 'PERIOD_DATE_TO' )
      then
            g_period_date_to := to_date(p_context_value,'YYYY/MM/DD');
      elsif ( upper(p_context_name) = 'ACTION_TYPE')
      then
            g_action_type := p_context_value;
      elsif ( upper(p_context_name) = 'SERVER_VALIDATE')
      then
            g_server_validate := (p_context_value='Y');
      else
            invalid_argument('pay_payroll_actions_pkg.set_query_bindvar',p_context_value);
      end if;

  end set_query_bindvar ;
-----------------------------------------------------------------------------------
 function get_num_bindvar( p_context_name in varchar2 ) return number is
 l_return_value number ;
 begin
      if ( upper(p_context_name) = 'BUSINESS_GROUP_ID' )
      then
            l_return_value := g_business_group_id ;
      elsif ( upper(p_context_name) = 'PAYROLL_ID' )
      then
            l_return_value := g_payroll_id ;
      else
        invalid_argument('pay_payroll_actions_pkg.get_num_bindvar',p_context_name);
      end if;

      return (l_return_value) ;

 end get_num_bindvar ;

------------------------------------------------------------------------------------
 function get_char_bindvar ( p_context_name in varchar2 ) return varchar2 is
 l_return_value varchar2(60);
 begin
 --
      if ( upper(p_context_name) = 'ACTION_TYPE')
      then
            l_return_value := g_action_type ;
      elsif ( upper(p_context_name) = 'SERVER_VALIDATE')
      then
            if g_server_validate then
               l_return_value := 'Y';
            else
               l_return_value :='N';
            end if;
      else
            invalid_argument('pay_payroll_actions_pkg.get_char_bindvar',p_context_name);
      end if;
      return (l_return_value) ;
 --
  end get_char_bindvar;
-----------------------------------------------------------------------------------
 function get_date_bindvar( p_context_name in varchar2 ) return date is
 l_return_value date ;
 begin

      if ( upper(p_context_name) = 'PERIOD_DATE_FROM' )
      then
            l_return_value := g_period_date_from ;
      elsif ( upper(p_context_name) = 'PERIOD_DATE_TO' )
      then
            l_return_value := g_period_date_to ;
      else
            invalid_argument('pay_payroll_actions_pkg.get_date_bindvar',p_context_name);
      end if;

      return (l_return_value) ;

  end get_date_bindvar;
-----------------------------------------------------------------------------------

 procedure set_where ( p_payroll_id in number,
                       p_date_from  in date,
                       p_date_to    in date,
                       p_action_type in varchar2,
                       p_server_validate in varchar2 default 'Y'   ) is
 begin
     set_query_bindvar( 'BUSINESS_GROUP_ID',fnd_profile.value('PER_BUSINESS_GROUP_ID'));
     set_query_bindvar( 'PAYROLL_ID',       to_number(p_payroll_id));
     set_query_bindvar( 'PERIOD_DATE_FROM', nvl(to_char(p_date_from,'YYYY/MM/DD'),
                                                to_char(hr_general.start_of_time,'YYYY/MM/DD')));
     set_query_bindvar( 'PERIOD_DATE_TO',   nvl(to_char(p_date_to,'YYYY/MM/DD'),
                                                to_char(hr_general.end_of_time,'YYYY/MM/DD')));
     set_query_bindvar( 'ACTION_TYPE',      p_action_type );
     set_query_bindvar( 'SERVER_VALIDATE',  p_server_validate );
 end set_where;
--
 procedure set_where ( p_payroll_id in number,
                       p_date_from  in date,
                       p_date_to    in date,
                       p_action_type in varchar2) is
 begin
   set_where(p_payroll_id,p_date_from,p_date_to,p_action_type,'Y');
 end set_where;
-----------------------------------------------------------------------------------

 function latest_balance_exists(p_assignment_action_id in number
                               ,p_defined_balance_id   in number) return varchar2 is
--
 l_exists  varchar2(1) := 'N';
--
 cursor c_asg_lb_exists is
   select 'Y'
   from   pay_assignment_latest_balances
   where  assignment_action_id = p_assignment_action_id
   and    defined_balance_id   = p_defined_balance_id;
--
 cursor c_per_lb_exists is
   select 'Y'
   from pay_person_latest_balances
   where  assignment_action_id = p_assignment_action_id
   and    defined_balance_id   = p_defined_balance_id;
--
 cursor c_lb_exists is
   select 'Y'
   from pay_latest_balances
   where  assignment_action_id = p_assignment_action_id
   and    defined_balance_id   = p_defined_balance_id;
 begin
--
  open  c_asg_lb_exists;
  fetch c_asg_lb_exists into l_exists;
  if c_asg_lb_exists%FOUND then
  --
    close c_asg_lb_exists;
    return(l_exists);
  --
  else
  --
    open  c_per_lb_exists;
    fetch c_per_lb_exists into l_exists;
    if c_per_lb_exists%FOUND then
    --
      close c_per_lb_exists;
      return(l_exists);
    --
    else
    --
      open  c_lb_exists;
      fetch c_lb_exists into l_exists;
      if c_lb_exists%FOUND then
      --
        close c_lb_exists;
        return(l_exists);
      --
      else
      --
        l_exists := 'N';
        return(l_exists);
      --
      end if;
    --
    end if;
  --
  end if;
--
end;
---------------------------------------------------------------------

function decode_cheque_type ( p_business_group_id number) return varchar2 is
--
--  returns the correct action type for the cheque writer process depending
--  on the current legislation code
--
  cursor csr_cheque_name  ( p_bus_grp_id number) is
    select pli.validation_name
    from pay_legislative_field_info pli,
         per_business_groups pbg
    where pli.legislation_code = pbg.legislation_code
    and pbg.business_group_id = p_bus_grp_id
    and pli.rule_type = 'H'
    and pli.field_name = 'CHEQUE_CHECK';
--
  l_cheque_type  varchar2 (30);
--
begin
--
  --  if the bus grp id passed is the same as the one cached then
  --  return the cached cheque_type value, otherwise get the new
  --  cheque_type value
  --
  if ( p_business_group_id = g_cached_business_group_id ) then
    l_cheque_type := g_cached_cheque_type;
  else
    open csr_cheque_name ( p_business_group_id );
      fetch csr_cheque_name into l_cheque_type;
    close csr_cheque_name;
    --
    --  populate new cache values
    --
    g_cached_business_group_id := p_business_group_id;
    g_cached_cheque_type := l_cheque_type;
    --
  end if;

  return l_cheque_type;
--
end decode_cheque_type;
---------------------------------------------------------------------
END PAY_PAYROLL_ACTIONS_PKG;

/
