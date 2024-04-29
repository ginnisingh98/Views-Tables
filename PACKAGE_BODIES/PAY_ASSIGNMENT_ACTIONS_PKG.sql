--------------------------------------------------------
--  DDL for Package Body PAY_ASSIGNMENT_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ASSIGNMENT_ACTIONS_PKG" AS
/* $Header: pyasa01t.pkb 120.3.12010000.1 2008/07/27 22:03:38 appldev ship $ */
/*

   PRODUCT
   Oracle*Payroll
   --
   NAME
      pyasa01t.pkh
   --
   DESCRIPTION
      Contains routines used to support the Assignment level windows in the
      Payroll Process Results window.
   --
   MODIFIED (DD-MON-YYYY)
   dkerr	 40.0      02-NOV-1993        Created
   dkerr	 40.4      11-APP-1996        Added get_action_status and
					      get_payment_status to support
					      void payments process.
   jalloun                 30-JUL-1996        Added error handling.
   dkerr	 40.7      05-SEP-1996        Bug 394529 :
					      Test for external manual payments
					      and magnetic tape. Changed cursor
					      and variable names appropriately.
   sbilling	 40.8      30-MAR-1998        Bug 596810 :
				              Added extra case ('A') on
					      action_type filter on cursor
					      get_locking_payments.
   nbristow     115.2      27-JUN-2000        Changed get_action_status to
                                              handle Continuous Calc.
   nbristow     115.3      12-JUN-2001        Change to get_action_status to
                                              handle RetroNotifications.
   exjones                 16-JAN-2002        Added ability to enable/disable
                                              get_action_status to improve
                                              query performance in PAYWSACT
   exjones      115.5      03-MAY-2002        Added dbdrv commands
   M.Reid       115.8      29-MAY-2003        Added get_payment_status_code
                                              function for bug 2976050
   A.Logue      115.6      13-JUN-2003        Added message_line_exists
                                              function for 2981945
   SuSivasu     115.10     16-Sep-2003        Modified get_action_status to
                                              call PAY_CC_PROCESS_UTILS.
                                              get_asg_act_status.
   nbristow     115.11     23-MAY-2006        Changed get_payment_status
                                              to include the Postal Payment
   alogue       115.12     22-JAN-2007        Added archive_assignment_start_date
                                              and archive_person_start_date.
   alogue       115.13     29-JAN-2007        Handled future started asgs/pers
                                              in above.
*/
--
 g_action_status_enabled varchar2(1) := 'Y';
 g_asg_id per_all_assignments_f.assignment_id%type := null;
 g_asg_eff_date date := null;
 g_asg_date date := null;
 g_per_id per_all_people_f.person_id%type := null;
 g_per_eff_date date := null;
 g_per_date date := null;
--
 procedure update_row(p_rowid                          in varchar2,
		      p_action_status                  in varchar2 ) is
  begin
  --
   update PAY_ASSIGNMENT_ACTIONS
   set    ACTION_STATUS   = p_action_status
   where  ROWID           = p_rowid;
  --
  end update_row;
--
-------------------------------------------------------------------------------
  procedure delete_row(p_rowid   in varchar2) is
  --
  begin
  --
    delete from PAY_ASSIGNMENT_ACTIONS
    where  ROWID = p_rowid;
  --
  end delete_row;
--
  procedure lock_row (p_rowid                          in varchar2,
		      p_action_status                  in varchar2 ) is

  --
    cursor C is select *
                from   PAY_ASSIGNMENT_ACTIONS
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

-------------------------------------------------------------------------------

 function  get_action_status ( p_assignment_action_id in number,
			       p_action_type          in varchar2,
			       p_action_status        in varchar2 )
  return varchar2  is
-- Bug 2976915.
-- This function now uses the PAY_CC_PROCESS_UTILS.get_asg_act_status
-- function to derive its value.
-- --
-- -- A given assignment action is void if there is a payroll action of type 'D'
-- -- locks ( though PAY_ACTION_INTERLOCKS ) the assignment action.
-- -- Note that this cursor does not check whether the void assignment action has
-- -- a status of complete
-- --
-- cursor c_is_voided ( p_assignment_action_id in number ) is
--   select intloc.locking_action_id
--   from   pay_assignment_actions assact,
-- 	 pay_action_interlocks  intloc,
-- 	 pay_payroll_actions    pact
--   where  intloc.locked_action_id  = p_assignment_action_id
--   and    intloc.locking_action_id = assact.assignment_action_id
--   and    assact.payroll_action_id = pact.payroll_action_id
--   and    pact.action_type         = 'D';
-- --
-- cursor run_modified (p_assignment_action_id in number ) is
-- select paa.assignment_action_id
-- from
--      pay_payroll_actions ppa,
--      pay_assignment_actions paa
-- where paa.assignment_action_id = p_assignment_action_id
-- and   paa.payroll_action_id = ppa.payroll_action_id
-- and   paa.action_status = 'C'
-- and exists (select ''
--               from pay_process_events ppe
--              where ppe.assignment_id = paa.assignment_id
--                and ppe.effective_date < ppa.effective_date
--                and ppe.change_type in ('GRE', 'DATE_EARNED', 'DATE_PROCESSED')
--                and ppe.status <> 'C'
--            )
-- and not exists (select ''
--                   from pay_assignment_actions paa1, -- Prepay/Costing
--                        pay_action_interlocks  pai1,
--                        pay_assignment_actions paa2,-- Payment/Trans GL
--                        pay_action_interlocks  pai2
--                  where pai1.locked_action_id = paa.assignment_action_id
--                    and pai1.locking_action_id = paa1.assignment_action_id
--                    and pai2.locked_action_id = paa1.assignment_action_id
--                    and pai2.locking_action_id = paa2.assignment_action_id);
-- --
-- cursor prepay_modified (p_assignment_action_id in number ) is
-- select paa.assignment_action_id
-- from
--      pay_payroll_actions ppa,
--      pay_assignment_actions paa
-- where paa.assignment_action_id = p_assignment_action_id
-- and   paa.payroll_action_id = ppa.payroll_action_id
-- and   paa.action_status = 'C'
-- and not exists (select ''
--                   from pay_assignment_actions paa1, -- Payment/Trans GL
--                        pay_action_interlocks  pai1
--                  where pai1.locked_action_id = paa.assignment_action_id
--                    and pai1.locking_action_id = paa1.assignment_action_id)
-- and (exists (select ''
--               from pay_process_events ppe
--              where ppe.assignment_id = paa.assignment_id
--                and ppe.effective_date < ppa.effective_date
--                and ppe.change_type in ('PAYMENT')
--                and ppe.status <> 'C'
--             )
--    or
--      exists (select ''
--               from pay_action_interlocks pai,
--                    pay_assignment_actions paa2,
--                    pay_payroll_actions    ppa2
--              where pai.locking_action_id = paa.assignment_action_id
--                and pai.locked_action_id = paa2.assignment_action_id
--                and paa2.payroll_action_id = ppa2.payroll_action_id
--                and ppa2.action_type in ('R','Q')
--                and exists (select ''
--                              from pay_process_events ppe
--                             where ppe.assignment_id = paa2.assignment_id
--                               and ppe.effective_date < ppa2.effective_date
--                               and ppe.change_type in ('GRE', 'DATE_EARNED', 'DATE_PROCESSED')
--                               and ppe.status <> 'C'
--                           )
--               )
--      );
-- --
-- cursor cost_modified (p_assignment_action_id in number ) is
-- select paa.assignment_action_id
-- from
--      pay_payroll_actions ppa,
--      pay_assignment_actions paa
-- where paa.assignment_action_id = p_assignment_action_id
-- and   paa.payroll_action_id = ppa.payroll_action_id
-- and   paa.action_status = 'C'
-- and not exists (select ''
--                   from pay_assignment_actions paa1, -- Payment/Trans GL
--                        pay_action_interlocks  pai1
--                  where pai1.locked_action_id = paa.assignment_action_id
--                    and pai1.locking_action_id = paa1.assignment_action_id)
-- and exists (select ''
--               from pay_process_events ppe
--              where ppe.assignment_id = paa.assignment_id
--                and ppe.effective_date < ppa.effective_date
--                and ppe.change_type in ('COST_CENTRE')
--                and ppe.status <> 'C'
--            )
-- and exists (select ''
--               from pay_action_interlocks pai,
--                    pay_assignment_actions paa2,
--                    pay_payroll_actions    ppa2
--              where pai.locking_action_id = paa.assignment_action_id
--                and pai.locked_action_id = paa2.assignment_action_id
--                and paa2.payroll_action_id = ppa2.payroll_action_id
--                and ppa2.action_type in ('R','Q')
--                and exists (select ''
--                              from pay_process_events ppe
--                             where ppe.assignment_id = paa2.assignment_id
--                               and ppe.effective_date < ppa2.effective_date
--                               and ppe.change_type in ('GRE', 'DATE_EARNED', 'DATE_PROCESSED')
--                               and ppe.status <> 'C'
--                           )
--              );
-- --
-- --
-- l_return_value    hr_lookups.meaning%type ;
-- l_dummy_action_id pay_assignment_actions.assignment_action_id%type ;
-- ischanged         boolean;
begin
-- --
--   if g_action_status_enabled = 'N' then
--     return null;
--   end if;
-- --
--   if ( p_action_type in ('R', 'Q')) then
-- --
--      ischanged := FALSE;
-- --
--      -- Check Run change.
----       open run_modified( p_assignment_action_id );
--      fetch run_modified into l_dummy_action_id ;
--      if run_modified%found then
--        ischanged := TRUE;
--      end if;
--      close run_modified ;
-- --
--      if (ischanged) then
--         l_return_value := hr_general.decode_lookup('ACTION_STATUS','MO');
--      else
--         l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
--      end if;
-- --
--   elsif ( p_action_type in ('P', 'U')) then
-- --
--      ischanged := FALSE;
-- --
--      -- Check Prepay change.
--      open prepay_modified( p_assignment_action_id );
--      fetch prepay_modified into l_dummy_action_id ;
--      if prepay_modified%found then
--        ischanged := TRUE;
--      end if;
--      close prepay_modified ;
-- --
--      if (ischanged) then
--         l_return_value := hr_general.decode_lookup('ACTION_STATUS','MO');
--      else
--         l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
--      end if;
-- --
--   elsif ( p_action_type = 'C') then
-- --
--      ischanged := FALSE;
-- --
--      -- Check Costing change.
--      open cost_modified( p_assignment_action_id );
--      fetch cost_modified into l_dummy_action_id ;
--      if cost_modified%found then
--        ischanged := TRUE;
--      end if;
--      close cost_modified ;
-- --
--      if (ischanged) then
--         l_return_value := hr_general.decode_lookup('ACTION_STATUS','MO');
--      else
--         l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
--      end if;
-- --
-- --
--   elsif ( p_action_type = 'H' ) then
--      open c_is_voided( p_assignment_action_id ) ;
--      fetch c_is_voided into l_dummy_action_id ;
--      if c_is_voided%found then
-- 	l_return_value := hr_general.decode_lookup('ACTION_STATUS','V');
--      else
-- 	l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
--      end if;
--      close c_is_voided ;
--   else
-- 	l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
--   end if;
--   return ( l_return_value ) ;
    return (PAY_CC_PROCESS_UTILS.get_asg_act_status(p_assignment_action_id,
                                                   p_action_type,
                                                   p_action_status));
end get_action_status ;
-- --
procedure enable_action_status is
begin
    g_action_status_enabled := 'Y';
end enable_action_status;
--
procedure disable_action_status is
begin
    g_action_status_enabled := 'N';
end disable_action_status;
--
function action_status_enabled return varchar2 is
begin
  return g_action_status_enabled;
end action_status_enabled;
--
-------------------------------------------------------------------------------
function  get_payment_status_code ( p_assignment_action_id in number,
			            p_pre_payment_id       in number )
return varchar2 is
 --
 -- This cursor retrieves all completed payments for the given
 -- assignment action
 --
 cursor get_locking_payments ( p_assignment_action_id number,
			       p_pre_payment_id       number ) is
    select aac.assignment_action_id,
	   aac.action_status,
	   pac.action_type
    from   pay_payroll_actions    pac,
	   pay_assignment_actions aac,
	   pay_action_interlocks  loc
    where  loc.locked_action_id  = p_assignment_action_id
    and    loc.locking_action_id = aac.assignment_action_id
    and    aac.pre_payment_id    = p_pre_payment_id
    and    aac.action_status     = 'C'
    and    pac.payroll_action_id = aac.payroll_action_id
    and    pac.action_type  in ('H','E','M','A', 'PP') ;
 --
 -- This cursor retrieves a void action which locks a given
 -- check action.
 --
 cursor get_locking_void_action ( p_assignment_action_id number ) is
    select aac.assignment_action_id
    from   pay_payroll_actions    pac,
	   pay_assignment_actions aac,
	   pay_action_interlocks  loc
    where  loc.locked_action_id  = p_assignment_action_id
    and    loc.locking_action_id = aac.assignment_action_id
    and    aac.payroll_action_id = pac.payroll_action_id
    and    pac.action_type       = 'D' ;

 status_code           hr_lookups.lookup_code%type ;
 l_void_assact         pay_assignment_actions.assignment_action_id%type ;
 found_payment         boolean    := FALSE ;
 found_non_void_action boolean    := FALSE ;

begin

  for theRow in get_locking_payments( p_assignment_action_id ,
				      p_pre_payment_id )  loop
     exit when found_non_void_action = TRUE ;

     found_payment := TRUE ;

     --
     -- Only check actions can be voided
     --
     open get_locking_void_action ( theRow.assignment_action_id ) ;
     fetch get_locking_void_action into l_void_assact ;

     if get_locking_void_action%notfound
     then
        found_non_void_action := TRUE ;
     end if;

     close get_locking_void_action ;

  end loop ;


  --
  -- If there was a check action found then return 'Paid' if a non-voided action
  -- was found
  --
  if ( found_payment = TRUE )
  then

      if ( found_non_void_action = TRUE ) then

	 status_code := 'P' ;

      else

	 status_code := 'V' ;

      end if;

  else

	status_code  := 'U' ;

  end if;

  return( status_code );

end get_payment_status_code ;

function  get_payment_status  (p_assignment_action_id in number,
                               p_pre_payment_id       in number)
return varchar2 is
begin

  return( hr_general.decode_lookup('PAY_STATUS',
    get_payment_status_code (p_assignment_action_id, p_pre_payment_id) ) ) ;

end get_payment_status;

--
-------------------------------------------------------------------------------
function message_line_exists (p_assignment_action_id in number)
return varchar2 is
--
l_exists varchar2(1);
--
begin
--
  begin
    select 'Y'
    into l_exists
    from dual
    where exists (
                   select null
                   from pay_message_lines pml
                   where pml.source_id   = p_assignment_action_id
                   and   pml.source_type = 'A');
  exception
    when others then
      l_exists := 'N';
  end;

  return l_exists;
end message_line_exists;
--
-------------------------------------------------------------------------------
function archive_assignment_start_date (p_assignment_id  in number,
                                        p_effective_date in date)
return date is
--
l_date date := null;
--
begin
--
  if (g_asg_id is not null and p_assignment_id = g_asg_id
      and p_effective_date = g_asg_eff_date) then
     l_date := g_asg_date;
  else

     select max(asg.effective_start_date)
       into l_date
       from per_all_assignments_f asg
      where asg.assignment_id = p_assignment_id
        and asg.effective_start_date <= p_effective_date;

     if l_date is null then

      select max(asg.effective_start_date)
        into l_date
        from per_all_assignments_f asg
       where asg.assignment_id = p_assignment_id
         and asg.effective_start_date >= p_effective_date;
     end if;

     g_asg_id := p_assignment_id;
     g_asg_eff_date := p_effective_date;
     g_asg_date := l_date;
  end if;

  return l_date;
end archive_assignment_start_date;
--
-------------------------------------------------------------------------------
function archive_person_start_date (p_person_id  in number,
                                    p_effective_date in date)
return date is
--
l_date date := null;
--
begin
--
  if (g_per_id is not null and p_person_id = g_per_id
       and p_effective_date =  g_per_eff_date) then
      l_date := g_per_date;
  else
     select max(pep.effective_start_date)
       into l_date
       from per_all_people_f pep
      where pep.person_id = p_person_id
        and pep.effective_start_date <= p_effective_date;

     if l_date is null then

      select max(pep.effective_start_date)
        into l_date
        from per_all_people_f pep
       where pep.person_id = p_person_id
         and pep.effective_start_date >= p_effective_date;
     end if;

     g_per_id := p_person_id;
     g_per_eff_date := p_effective_date;
     g_per_date := l_date;
  end if;

  return l_date;
end archive_person_start_date;
--

END PAY_ASSIGNMENT_ACTIONS_PKG;

/
