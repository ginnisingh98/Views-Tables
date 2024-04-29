--------------------------------------------------------
--  DDL for Package Body HR_BALANCE_FEEDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BALANCE_FEEDS" as
/* $Header: pybalfed.pkb 120.5 2006/08/10 13:33:59 alogue noship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    hr_balance_feeds
  Purpose

    This package supports the maintenance of balance feeds either by
    generating them according to system events ie. adding a balance
    classification or providing utilities to allow the manual creation of
    balance feeds. A balance feed is an intersection between a balance and an
    input value and the following basic rules must be met :

    1. Legislation / Business group must match (see table below).
    2. The units of the balance must match thst of the input value and the
       output currency of the input value must match the balances currency if
       monetary units are involved.
    3. There are other specific rules which affect the eligibility for
       creating balance feeds ie. adding a Pay Value, adding a Sub
       Classification Rule, etc...

       NB. all system generated balance feeds must match on the Pay Value
	   input value.

    The following table lists the combinations of business group /
    startup data that will match to create balance feeds subject to the
    other conditions being met ie. units etc...

       Input Value    |   Balance Type    |   Balance Feed
     Bg Id   Leg Code | Bg Id    Leg Code | Bg Id    Leg Code
    --------------------------------------------------------
       1              |   1               |   1
       1              |            GB     |   1
               GB     |   1               |   1
               GB     |            GB     |            GB
       1              |   2               |     NO MATCH
    --------------------------------------------------------

    where Bus Grp 1 and Bus Grp 2 have a legislation of GB.

  Notes

  History
    01-Mar-94  J.S.Hobbs   40.0   Date created.
    15-Mar-94  J.S.Hobbs   40.1   Corrected the setting of legislation code
                                  and business group id for balance feeds.
    15-Mar-94  J.S.Hobbs   40.2   Added to group by clause in ins_bf_bal_class
				  to allow the change 40.1 to work !
    02-Jun-94  J.S.Hobbs   40.3   Fixed G844. The matching of input values to
				  balance types now works correctly when
				  there is a difference in ownership eg.
				  legislation input value and user balance
				  etc... Also corrected the setting of
				  business group / legislation on balance feeds
				  created due to sub classification rules.
    19-Aug-94  J.S.Hobbs   40.6   Fixed G1243  Corrected problem with creating
				  balance feeds that span business groups.
    25-Aug-94  J.S.Hobbs   40.7   Fixed G1268  Corrected problem with cursor
				  csr_bal_feed in bf_chk_proc_run_results
				  where it was failing to find the balance
				  feed..
    23-Nov-94  rfine       40.8   Suppressed index on business_group_id
    16-Jul-95  D.Kerr	   40.9   Modified the manual_bal_feeds_exist
				  function to support initial balance feeds.
    01-Mar-99  J. Moyano  115.1   MLS changes. Added references to _TL tables.
    10-Feb-00  A.Logue    115.3   Utf8 support : pay_input_values_f.name
                                  extended to 80 characters.
    14-Feb-01  M.Reid     115.4   Rewrote csr_proc_run_result due to CBO
                                  choosing non-optimal plan
    23-Mar-01  J.Tomkins  115.5   Bug. 1366796. Added Error 72033 regarding
                                  delete next change for element type with
                                  input values. Amended del_bf_input_value to
                                  include this message.
    11-Jun-01  M.Reid     115.6   Bug 1783351.  Removed suppression of BG id
                                  for CBO to allow the view to be merged.
    30-JUL-02  RThirlby   115.7   Bug 2430399 Added p_mode parameter to
                                  ins_bf_bal_class, so can be called from
                                  hr_legislation, and not raise an error in
                                  ins_bal_feed, if the feed already exists.
  05-AUG-2002  RThirlby   115.8   Removed development debug statements.
    31-Oct-02  A.Logue    115.9   Performance fix in cursor
                                  csr_bf_upd_del_sub_class_rule. Bug 2649208.
    10-Dec-02  A.Logue    115.10  Performance fix to cursor csr_bal_feed
                                  in bf_chk_proc_run_results. Bug 2668076.
    29-JAN-03  RThirlby   115.11  Bug 2767760 - Issues with creation of feeds
                                  due to translated pay value input value name
                                  being used, instead of the base table name.
                                  Search for this bug no. for further details.
                                  NB - also fixed a compilation error caused
                                  by a change in version 115.10.
   14-APR-2003 RThirlby  115.12   Bug 2888183. Added p_mode parameter to
                                  ins_bf_sub_class_rule and ins_bf_pay_value,
                                  so they can be called from
                                  hr_legislation_elements, and not raise an
                                  error in ins_bal_feed, if the feed already
                                  exists.
   24-FEB-2005 M.Reid    115.13   Bug 4187885.  Added no unnest hint as 10g
                                  workaround for ST bug 3120429
   22-NOV-2005 A.Logue   115.14   Rewrote csr_proc_run_result due to CBO
                                  choosing non-optimal plan
   29-DEC-2005 A.Logue   115.15   Rewrote csr_proc_run_result due to CBO
                                  choosing non-optimal plan. Bug 4914604.
   17-JAN-2006 A.Logue   115.16   Reimplemented csr_proc_run_result for
                                  balance feed creation for performance.
                                  Bug 4958471.
   15-FEB-2006 A.Logue   115.17   Further performance enhancments to
                                  feed insertion code.
                                  Bug 5040393.
   10-AUG-2006 A.Logue   115.18   Disable changed balance value check in
                                  bf_chk_proc_run_results for new balance feeds
                                  if CHANGED_BALANCE_VALUE_CHECK
                                  pay_action_parameter set to N. Bug 5442547.
 ============================================================================*/
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.lock_balance_type                                       --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Takes a row level lock out on a specified balance type.                  --
 ------------------------------------------------------------------------------
--
 procedure lock_balance_type
 (
  p_balance_type_id number
 ) is
--
   cursor csr_lock_balance
	  (
	   p_balance_type_id number
          ) is
     select bt.balance_type_id
     from   pay_balance_types bt
     where  bt.balance_type_id = p_balance_type_id
     for update;
--
   v_balance_type_id number;
--
 begin
--
   -- Lock the balance type. This is used by balance feed code to ensure that
   -- the balance feeds being manipulated cannot be changed by another process
   -- ie. all balance feed code requires an exclusive lock on the relevent
   -- balance type before processing can start.
   open csr_lock_balance(p_balance_type_id);
   fetch csr_lock_balance into v_balance_type_id;
   if csr_lock_balance%notfound then
     close csr_lock_balance;
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
				  'hr_balance_feeds.lock_balance_type');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   else
     close csr_lock_balance;
   end if;
--
 end lock_balance_type;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.bal_classifications_exist                               --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns TRUE if a balance classification exists.                         --
 ------------------------------------------------------------------------------
--
 function bal_classifications_exist
 (
  p_balance_type_id number
 ) return boolean is
--
   cursor csr_classifications_exist is
     select bcl.classification_id
     from   pay_balance_classifications bcl
     where  bcl.balance_type_id = p_balance_type_id;
--
   v_classification_id number;
--
 begin
--
   open csr_classifications_exist;
   fetch csr_classifications_exist into v_classification_id;
   if csr_classifications_exist%found then
     close csr_classifications_exist;
     return (TRUE);
   else
     close csr_classifications_exist;
     return (FALSE);
   end if;
--
 end bal_classifications_exist;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.manual_bal_feeds_exist                                  --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns TRUE if a manual balance feed exists.                            --
 -- A balance type has a manual balance feed if it has balance feeds whose   --
 -- associated element classification is not a balance initialization one    --
 -- and if the balance type has no associated balance classifications        --
 ------------------------------------------------------------------------------
--
 function manual_bal_feeds_exist
 (
  p_balance_type_id number
 ) return boolean is
--
   cursor csr_manual_feeds_exist is
     select bf.balance_feed_id
     from   pay_balance_feeds_f         bf,
	    pay_input_values_f          inv,
	    pay_element_types_f         elt,
	    pay_element_classifications ec
     where  bf.balance_type_id                      = p_balance_type_id
       and  bf.input_value_id                       = inv.input_value_id
       and  inv.element_type_id                     = elt.element_type_id
       and  elt.classification_id                   = ec.classification_id
       and  nvl(ec.balance_initialization_flag,'N') = 'N'
       and  not exists
	      (select null
	       from   pay_balance_classifications bc
	       where  bc.balance_type_id = bf.balance_type_id);
--
   v_bal_feed_id number;
--
 begin
--
   open csr_manual_feeds_exist;
   fetch csr_manual_feeds_exist into v_bal_feed_id;
   if csr_manual_feeds_exist%found then
     close csr_manual_feeds_exist;
     return (TRUE);
   else
     close csr_manual_feeds_exist;
     return (FALSE);
   end if;
--
 end manual_bal_feeds_exist;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.pay_value_name                                          --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns the translated name for the 'Pay Value'.                         --
 ------------------------------------------------------------------------------
--
 function pay_value_name return varchar2 is
--
   v_pay_value_name varchar2(80);
--
 begin
--
   begin
     select hl.meaning
     into   v_pay_value_name
     from   hr_lookups hl
     where  hl.lookup_type = 'NAME_TRANSLATIONS'
       and  hl.lookup_code = 'PAY VALUE';
   exception
     when no_data_found then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
				    'hr_balance_feeds.pay_value_name');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
   end;
--
   return v_pay_value_name;
--
 end pay_value_name;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.is_pay_value                                            --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns TRUE if input value is a Pay Value.                              --
 ------------------------------------------------------------------------------
--
 function is_pay_value
 (
  p_input_value_id number
 ) return boolean is
--
   cursor csr_pay_value
	  (
	   p_input_value_id number,
	   p_pay_value_name varchar2
          ) is
     select iv.input_value_id
     from   pay_input_values_f iv
     where  iv.input_value_id = p_input_value_id
       and  iv.name = p_pay_value_name;
--
   v_input_value_id number;
   v_pay_value_name varchar2(80);
--
 begin
--
   -- Get translated name for pay value
   -- v_pay_value_name := hr_balance_feeds.pay_value_name;
   -- Bug 2767760 - search for this bug number for full explanation of these
   -- changes.
   -- Set variable to base table pay value input value name
      v_pay_value_name := 'Pay Value';
--
   open csr_pay_value
	  (p_input_value_id,
	   v_pay_value_name);
   fetch csr_pay_value into v_input_value_id;
   if csr_pay_value%found then
     close csr_pay_value;
     return (TRUE);
   else
     close csr_pay_value;
     return (FALSE);
   end if;
--
 end is_pay_value;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.is_primary_class                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns if the classification is primary / sub classification.           --
 ------------------------------------------------------------------------------
--
 function is_primary_class
 (
  p_classification_id number
 ) return boolean is
--
   v_parent_classification_id number;
--
 begin
--
   -- Check to see if classification is primary or secondary.
   begin
     select ecl.parent_classification_id
     into   v_parent_classification_id
     from   pay_element_classifications ecl
     where  ecl.classification_id = p_classification_id;
   exception
     when no_data_found then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
				    'hr_balance_feeds.is_primary_class');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
   end;
--
   if v_parent_classification_id is null then
     return (TRUE);
   else
     return (FALSE);
   end if;
--
 end is_primary_class;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.bal_feed_end_date                                       --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns the correct end date for a balance feed. It takes into account   --
 -- the end date of the input value and also any future balance feeds.       --
 ------------------------------------------------------------------------------
--
 function bal_feed_end_date
 (
  p_balance_feed_id       number,
  p_balance_type_id       number,
  p_input_value_id        number,
  p_session_date          date,
  p_validation_start_date date
 ) return date is
--
   v_next_bal_feed_start_date date;
   v_max_inp_val_end_date     date;
   v_bal_feed_end_date        date;
--
 begin
--
   -- Make sure that no balance classifications exist when creating a manual
   -- balance feed
   if hr_balance_feeds.bal_classifications_exist(p_balance_type_id) then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
				  'hr_balance_feeds.bal_feed_end_date');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
   -- Get the start date of the earliest future balance feed if it exists.
   begin
     select min(bf.effective_start_date)
     into   v_next_bal_feed_start_date
     from   pay_balance_feeds_f bf
     where  bf.balance_type_id = p_balance_type_id
       and  bf.input_value_id = p_input_value_id
       and  bf.effective_end_date >= p_session_date
       and  bf.balance_feed_id <> nvl(p_balance_feed_id,0);
   exception
     when no_data_found then
       null;
   end;
--
   -- If there are no future balance feeds , get the max end date of the
   -- input value.
   if v_next_bal_feed_start_date is null then
     begin
       select max(iv.effective_end_date)
       into   v_max_inp_val_end_date
       from   pay_input_values_f iv
       where  iv.input_value_id = p_input_value_id;
     exception
       when no_data_found then
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
				      'hr_balance_feeds.bal_feed_end_date');
         hr_utility.set_message_token('STEP','2');
         hr_utility.raise_error;
     end;
     v_bal_feed_end_date := v_max_inp_val_end_date;
   else
     v_bal_feed_end_date := v_next_bal_feed_start_date - 1;
   end if;
--
   -- Trying to open up a balance feed that would either overlap with an
   -- existing balance feed or extend beyond the lifetime of the input value
   -- on which it is based.
   if v_bal_feed_end_date < p_validation_start_date then
     if v_next_bal_feed_start_date is null then
       -- Trying to extend the end date of the balance feed past the end date
       -- of the input value.
       hr_utility.set_message(801, 'HR_7048_BAL_FEED_PAST_INP_VAL');
     else
       -- Trying to extend the end date of the balance feed such that it will
       -- overlap with existing balance feeds.
       hr_utility.set_message(801, 'HR_7047_BAL_FEED_FUT_EXIST');
     end if;
     hr_utility.raise_error;
   end if;
--
   return v_bal_feed_end_date;
--
 end bal_feed_end_date;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.ins_bal_feed                                            --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Creates a balance feed.
 -- Parameter p_mode added so the procedure can be called from the form or   --
 -- from the startup data deliver mechanism (hr_legislation, pelegins.pkb).  --
 -- In FORM mode the procedure will not change. In 'startup' mode, if a feed --
 -- already exists, then the error will not be raised, and the code will     --
 -- continue its loop for creating balance feeds.
 ------------------------------------------------------------------------------
--
 procedure ins_bal_feed
 (
  p_effective_start_date date,
  p_effective_end_date   date,
  p_business_group_id    number,
  p_legislation_code     varchar2,
  p_balance_type_id      number,
  p_input_value_id       number,
  p_scale                number,
  p_legislation_subgroup varchar2,
  p_mode                 varchar2 default 'FORM'
 ) is
--
 begin
--
   -- Create a balance feed making sure that a balance feed does not already
   -- exist.
   insert into pay_balance_feeds_f
   (balance_feed_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    legislation_code,
    balance_type_id,
    input_value_id,
    scale,
    legislation_subgroup,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date)
   select
    pay_balance_feeds_s.nextval,
    p_effective_start_date,
    p_effective_end_date,
    p_business_group_id,
    p_legislation_code,
    p_balance_type_id,
    p_input_value_id,
    p_scale,
    p_legislation_subgroup,
    trunc(sysdate),
    0,
    0,
    0,
    trunc(sysdate)
   from sys.dual
   where not exists
	 (select null
	  from   pay_balance_feeds_f bf
	  where  bf.input_value_id = p_input_value_id
	    and  bf.balance_type_id = p_balance_type_id
	    and  p_effective_start_date <= bf.effective_end_date
	    and  p_effective_end_date >= bf.effective_start_date);
--
   -- Check to see if a balance feed was created. If not then an existing
   -- balance feed overlapped with the one being created.
     if sql%rowcount = 0 then
       if p_mode = 'FORM' then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_balance_feeds.ins_bal_feed');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
       elsif p_mode = 'STARTUP' then
         hr_utility.set_location('hr_balance_feeds.ins_bal_feed', 10);
       else -- p_mode is something other than FORM or Startup - error
         hr_utility.set_location('hr_balance_feeds.ins_bal_feed', 20);
       end if;
     end if;
--
 end ins_bal_feed;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.ins_bf_bal_class                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Creates balance feeds when a balance classification has been added.      --
 ------------------------------------------------------------------------------
--
 procedure ins_bf_bal_class
 (
  p_balance_type_id           number,
  p_balance_classification_id number,
  p_mode                      varchar2 default 'FORM'
 ) is
--
   --
   -- Finds all balance feeds that should be created as the direct result of
   -- adding a classification to a balance NB the first part of the UNION
   -- deals with primary classifications and the second paret deals with
   -- secondary classifications ie. they are mutually exclusive.
   --
   cursor csr_pay_value_bal_class
	  (
	   p_balance_classification_id number,
           p_pay_value_name            varchar2
          ) is
     select bt.balance_type_id,
	    iv.input_value_id,
	    bc.scale,
	    min(iv.effective_start_date) effective_start_date,
	    max(iv.effective_end_date) effective_end_date,
            nvl(iv.business_group_id,bt.business_group_id) business_group_id,
            decode(nvl(iv.business_group_id,bt.business_group_id),
	           null, nvl(iv.legislation_code,bt.legislation_code),
			 null) legislation_code
           ,bt.balance_name
           ,ec.classification_name
           ,et.element_name
     from   pay_input_values_f iv,
	    pay_element_types_f et,
	    pay_element_classifications ec,
	    pay_balance_classifications bc,
	    pay_balance_types bt,
	    per_business_groups_perf ivbg,
	    per_business_groups_perf btbg
     where  bc.balance_classification_id = p_balance_classification_id
       and  ec.classification_id = bc.classification_id
       and  ec.parent_classification_id is null
       and  bt.balance_type_id = bc.balance_type_id
       and  et.classification_id = ec.classification_id
       and  iv.element_type_id = et.element_type_id
       and  iv.name = p_pay_value_name
       and  substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
       and  (bt.balance_uom <> 'M' or
            (bt.balance_uom = 'M' and
             bt.currency_code = et.output_currency_code))
       and  iv.effective_start_date between et.effective_start_date
                                        and et.effective_end_date
       /*
	  Join are to get the legislation code for the business groups of the
	  balance and input value being matched.
       */
       and  iv.business_group_id = ivbg.business_group_id (+)
       and  bt.business_group_id = btbg.business_group_id (+)
       /*
	  Match on business group OR
          Business groups do not match so try to match on legislation NB.
          need to protect against the case where the business groups are
          different but share the same legislation code.
       */
       and  (
	     nvl(ivbg.business_group_id,-1) = nvl(btbg.business_group_id,-2) or
	    (
	     nvl(iv.legislation_code,nvl(ivbg.legislation_code,'GENERIC')) =
	     nvl(bt.legislation_code,nvl(btbg.legislation_code,'GENERIC')) and
             nvl(iv.business_group_id, nvl(bt.business_group_id, -1)) =
	     nvl(bt.business_group_id, nvl(iv.business_group_id, -1))
	    )
	    )
     group by bt.balance_type_id,
	      iv.input_value_id,
	      bc.scale,
              nvl(iv.business_group_id,bt.business_group_id),
              decode(nvl(iv.business_group_id,bt.business_group_id),
	             null, nvl(iv.legislation_code,bt.legislation_code),
			   null)
           ,bt.balance_name
           ,ec.classification_name
           ,et.element_name
     union
     select bt.balance_type_id,
	    iv.input_value_id,
	    bc.scale,
	    scr.effective_start_date,
	    scr.effective_end_date,
            nvl(iv.business_group_id,
                nvl(scr.business_group_id,
                    bt.business_group_id)) business_group_id,
            decode(nvl(iv.business_group_id,
                       nvl(scr.business_group_id,
                           bt.business_group_id)),
                   null, nvl(iv.legislation_code,
                             nvl(scr.legislation_code,
                                 bt.legislation_code)),
                         null) legislation_code
           ,bt.balance_name
           ,ec.classification_name
           ,et.element_name
     from   pay_sub_classification_rules_f scr,
	    pay_element_types_f et,
	    pay_input_values_f iv,
	    pay_element_classifications ec,
	    pay_balance_classifications bc,
	    pay_balance_types bt,
	    per_business_groups_perf ivbg,
	    per_business_groups_perf btbg
     where  bc.balance_classification_id = p_balance_classification_id
       and  ec.classification_id = bc.classification_id
       and  ec.parent_classification_id is not null
       and  bt.balance_type_id = bc.balance_type_id
       and  scr.classification_id = ec.classification_id
       and  et.element_type_id = scr.element_type_id
       and  iv.element_type_id = et.element_type_id
       and  iv.name = p_pay_value_name
       and  substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
       and  (bt.balance_uom <> 'M' or
            (bt.balance_uom = 'M' and
             bt.currency_code = et.output_currency_code))
       and  scr.effective_start_date between et.effective_start_date
                                         and et.effective_end_date
       and  scr.effective_start_date between iv.effective_start_date
                                         and iv.effective_end_date
       /*
	  Join are to get the legislation code for the business groups of the
	  balance and input value being matched.
       */
       and  iv.business_group_id = ivbg.business_group_id (+)
       and  bt.business_group_id = btbg.business_group_id (+)
       /*
	  Match on business group OR
          Business groups do not match so try to match on legislation NB.
          need to protect against the case where the business groups are
          different but share the same legislation code.
       */
       and  (
	     nvl(ivbg.business_group_id,-1) = nvl(btbg.business_group_id,-2) or
	    (
	     nvl(iv.legislation_code,nvl(ivbg.legislation_code,'GENERIC')) =
	     nvl(bt.legislation_code,nvl(btbg.legislation_code,'GENERIC')) and
             nvl(iv.business_group_id, nvl(bt.business_group_id, -1)) =
	     nvl(bt.business_group_id, nvl(iv.business_group_id, -1))
	    )
	    );
--
   v_pay_value_name varchar2(80);
--
 begin
--
   -- Lock balance type to ensure balance feeds are consistent.
   hr_balance_feeds.lock_balance_type
     (p_balance_type_id);
--
   -- Make sure that no manual balance feeds exist when creating a balance
   -- classification.
   if hr_balance_feeds.manual_bal_feeds_exist(p_balance_type_id) then
--
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'hr_balance_feeds.ins_bf_bal_class');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
--
   end if;
--
   -- Get translated name for the pay value.
   -- v_pay_value_name := hr_balance_feeds.pay_value_name;
   --
   -- Bug 2767760 - search for this bug number for full explanation of these
   -- changes.
   -- Set variable to base table pay value input value name
      v_pay_value_name := 'Pay Value';
--
   for v_iv_rec in csr_pay_value_bal_class
		     (p_balance_classification_id,
                      v_pay_value_name) loop
--
   hr_utility.trace('bt: '||v_iv_rec.balance_name);
   hr_utility.trace('clas: '||v_iv_rec.classification_name);
   hr_utility.trace('et: '||v_iv_rec.element_name);
     -- Create balance feed.
     hr_balance_feeds.ins_bal_feed
       (v_iv_rec.effective_start_date,
        v_iv_rec.effective_end_date,
        v_iv_rec.business_group_id,
        v_iv_rec.legislation_code,
        v_iv_rec.balance_type_id,
        v_iv_rec.input_value_id,
        v_iv_rec.scale,
        null,
        p_mode);
--
   end loop;
--
 end ins_bf_bal_class;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.upd_del_bf_bal_class                                    --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- When updating or deleting a balance classification cascade to linked     --
 -- balance feeds NB. the parameter p_mode is used to specify which ie.      --
 -- 'UPDATE' or 'DELETE'.                                                    --
 ------------------------------------------------------------------------------
--
 procedure upd_del_bf_bal_class
 (
  p_mode                      varchar2,
  p_balance_classification_id number,
  p_scale                     number
 ) is
--
   --
   -- Find all balance feeds that are linked to the balance classification.
   --
   cursor csr_bal_feeds_bal_class
          (
           p_balance_classification_id number
          ) is
     select bf.rowid row_id
     from   pay_balance_feeds_f bf,
	    pay_balance_classifications bc,
	    pay_balance_types bt,
	    pay_element_classifications ec
     where  bc.balance_classification_id = p_balance_classification_id
       and  bt.balance_type_id = bc.balance_type_id
       and  bf.balance_type_id = bt.balance_type_id
       and  ec.classification_id = bc.classification_id
       and ((ec.parent_classification_id is null and
	     exists
               (select null
                from   pay_element_types_f et,
	               pay_input_values_f iv
                where  iv.input_value_id = bf.input_value_id
                  and  et.element_type_id = iv.element_type_id
                  and  et.classification_id = bc.classification_id))
        or  (ec.parent_classification_id is not null and
             exists
	       (select null
	        from   pay_sub_classification_rules_f scr,
		       pay_input_values_f iv
                where  iv.input_value_id = bf.input_value_id
	          and  scr.element_type_id = iv.element_type_id
	          and  scr.classification_id = bc.classification_id)))
     for update;
--
 begin
--
   -- Find all affected balance feeds.
   for v_bf_rec in csr_bal_feeds_bal_class(p_balance_classification_id) loop
--
     if p_mode = 'UPDATE' then
--
       update pay_balance_feeds_f bf
       set    bf.scale = p_scale
       where  bf.rowid = v_bf_rec.row_id;
--
     elsif p_mode = 'DELETE' then
--
       delete from pay_balance_feeds_f bf
       where  bf.rowid = v_bf_rec.row_id;
--
     else
--
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
		      'hr_balance_feeds.upd_del_bf_bal_class');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
--
     end if;
--
   end loop;
--
 end upd_del_bf_bal_class;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.ins_bf_pay_value                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Creates balance feeds when a pay value is created.                       --
 ------------------------------------------------------------------------------
--
 procedure ins_bf_pay_value
 (
  p_input_value_id number
 ,p_mode           varchar2 default 'FORM'
 ) is
--
   --
   -- Finds all balance feeds that should be created as a direct result of
   -- creating a pay value NB. only searches for balance classifications that
   -- match the primary classification of the element type.
   --
   cursor csr_bal_types_prim_class
	  (
	   p_input_value_id number
          ) is
     select bt.balance_type_id,
	    bc.scale,
	    iv.effective_start_date,
	    iv.effective_end_date,
            nvl(iv.business_group_id,bt.business_group_id) business_group_id,
            decode(nvl(iv.business_group_id,bt.business_group_id),
                   null, nvl(iv.legislation_code,bt.legislation_code),
                         null) legislation_code
     from   pay_balance_types bt,
            pay_balance_classifications bc,
            pay_element_types_f et,
            pay_input_values_f iv,
	    per_business_groups_perf ivbg,
	    per_business_groups_perf btbg
     where  iv.input_value_id = p_input_value_id
       and  et.element_type_id = iv.element_type_id
       and  bc.classification_id = et.classification_id
       and  bt.balance_type_id = bc.balance_type_id
       and  substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
       and  (bt.balance_uom <> 'M' or
            (bt.balance_uom = 'M' and
             bt.currency_code = et.output_currency_code))
       and  iv.effective_start_date between et.effective_start_date
                                        and et.effective_end_date
       /*
	  Join are to get the legislation code for the business groups of the
	  balance and input value being matched.
       */
       and  iv.business_group_id = ivbg.business_group_id (+)
       and  bt.business_group_id = btbg.business_group_id (+)
       /*
	  Match on business group OR
          Business groups do not match so try to match on legislation NB.
          need to protect against the case where the business groups are
          different but share the same legislation code.
       */
       and  (
	     nvl(ivbg.business_group_id,-1) = nvl(btbg.business_group_id,-2) or
	    (
	     nvl(iv.legislation_code,nvl(ivbg.legislation_code,'GENERIC')) =
	     nvl(bt.legislation_code,nvl(btbg.legislation_code,'GENERIC')) and
             nvl(iv.business_group_id, nvl(bt.business_group_id, -1)) =
	     nvl(bt.business_group_id, nvl(iv.business_group_id, -1))
	    )
	    )
     for update of bt.balance_type_id;
--
   --
   -- Finds all balance feeds that should be created as a direct result of
   -- creating a pay value NB. only searches for balance classifications that
   -- match any sub classification of the element type.
   --
   cursor csr_bal_types_sub_class
	  (
	   p_input_value_id number
          ) is
     select bt.balance_type_id,
	    bc.scale,
	    scr.effective_start_date,
	    scr.effective_end_date,
            nvl(iv.business_group_id,
		nvl(scr.business_group_id,
	            bt.business_group_id)) business_group_id,
            decode(nvl(iv.business_group_id,
		       nvl(scr.business_group_id,
		           bt.business_group_id)),
	           null, nvl(iv.legislation_code,
			     nvl(scr.legislation_code,
			         bt.legislation_code)),
			 null) legislation_code
     from   pay_input_values_f iv,
	    pay_balance_classifications bc,
	    pay_balance_types bt,
	    pay_element_types_f et,
	    pay_sub_classification_rules_f scr,
	    per_business_groups_perf ivbg,
	    per_business_groups_perf btbg
     where  iv.input_value_id = p_input_value_id
       and  et.element_type_id = iv.element_type_id
       and  scr.element_type_id = et.element_type_id
       and  bc.classification_id = scr.classification_id
       and  bt.balance_type_id = bc.balance_type_id
       and  substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
       and  (bt.balance_uom <> 'M' or
            (bt.balance_uom = 'M' and
             bt.currency_code = et.output_currency_code))
       and  iv.effective_start_date between et.effective_start_date
                                        and et.effective_end_date
       /*
	  Join are to get the legislation code for the business groups of the
	  balance and input value being matched.
       */
       and  iv.business_group_id = ivbg.business_group_id (+)
       and  bt.business_group_id = btbg.business_group_id (+)
       /*
	  Match on business group OR
          Business groups do not match so try to match on legislation NB.
          need to protect against the case where the business groups are
          different but share the same legislation code.
       */
       and  (
	     nvl(ivbg.business_group_id,-1) = nvl(btbg.business_group_id,-2) or
	    (
	     nvl(iv.legislation_code,nvl(ivbg.legislation_code,'GENERIC')) =
	     nvl(bt.legislation_code,nvl(btbg.legislation_code,'GENERIC')) and
             nvl(iv.business_group_id, nvl(bt.business_group_id, -1)) =
	     nvl(bt.business_group_id, nvl(iv.business_group_id, -1))
	    )
	    )
     for update of bt.balance_type_id;

 begin
--
   -- Create balance feeds for balance types that has a balance classification
   -- that matches that of the element type.
   for v_bt_rec in csr_bal_types_prim_class
		     (p_input_value_id) loop
--
     -- Create balance feed.
     hr_balance_feeds.ins_bal_feed
       (v_bt_rec.effective_start_date,
        v_bt_rec.effective_end_date,
        v_bt_rec.business_group_id,
        v_bt_rec.legislation_code,
        v_bt_rec.balance_type_id,
        p_input_value_id,
        v_bt_rec.scale,
        null,
        p_mode);
--
   end loop;
--
   -- Create balance feeds for balance types that have a balance classification
   -- that matches sub classification rules for the element type.
   for v_bt_rec in csr_bal_types_sub_class
		     (p_input_value_id) loop
--
     -- Create balance feed.
     hr_balance_feeds.ins_bal_feed
       (v_bt_rec.effective_start_date,
        v_bt_rec.effective_end_date,
        v_bt_rec.business_group_id,
        v_bt_rec.legislation_code,
        v_bt_rec.balance_type_id,
        p_input_value_id,
        v_bt_rec.scale,
        null,
        p_mode);
--
   end loop;
--
 end ins_bf_pay_value;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.ins_bf_sub_class_rule                                   --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Creates automatic balance feeds when a sub classification rule is added. --
 ------------------------------------------------------------------------------
--
 procedure ins_bf_sub_class_rule
 (
  p_sub_classification_rule_id number
 ,p_mode                       varchar2 default 'FORM'
 ) is
--
   --
   -- Finds balance feeds that should be created as a direct result of
   -- creating a sub classification rule ie. find any balance classifications
   -- that match.
   --
   cursor csr_pay_value_sub_class_rule
          (
           p_sub_classification_rule_id number,
           p_pay_value_name             varchar2
          ) is
     select bt.balance_type_id,
	    iv.input_value_id,
	    bc.scale,
	    scr.effective_start_date,
	    scr.effective_end_date,
            nvl(iv.business_group_id,
		nvl(scr.business_group_id,
	            bt.business_group_id)) business_group_id,
            decode(nvl(iv.business_group_id,
		       nvl(scr.business_group_id,
		           bt.business_group_id)),
	           null, nvl(iv.legislation_code,
			     nvl(scr.legislation_code,
			         bt.legislation_code)),
			 null) legislation_code
     from   pay_sub_classification_rules_f scr,
	    pay_element_types_f et,
	    pay_input_values_f iv,
	    pay_balance_classifications bc,
	    pay_balance_types bt,
	    per_business_groups_perf ivbg,
	    per_business_groups_perf btbg
     where  scr.sub_classification_rule_id = p_sub_classification_rule_id
       and  bc.classification_id = scr.classification_id
       and  bt.balance_type_id = bc.balance_type_id
       and  et.element_type_id = scr.element_type_id
       and  iv.element_type_id = et.element_type_id
       and  iv.name = p_pay_value_name
       and  substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
       and  (bt.balance_uom <> 'M' or
            (bt.balance_uom = 'M' and
             bt.currency_code = et.output_currency_code))
       and  scr.effective_start_date between et.effective_start_date
                                         and et.effective_end_date
       and  scr.effective_start_date between iv.effective_start_date
                                         and iv.effective_end_date
       /*
	  Join are to get the legislation code for the business groups of the
	  balance and input value being matched.
       */
       and  iv.business_group_id = ivbg.business_group_id (+)
       and  bt.business_group_id = btbg.business_group_id (+)
       /*
	  Match on business group OR
          Business groups do not match so try to match on legislation NB.
          need to protect against the case where the business groups are
          different but share the same legislation code.
       */
       and  (
	     nvl(ivbg.business_group_id,-1) = nvl(btbg.business_group_id,-2) or
	    (
	     nvl(iv.legislation_code,nvl(ivbg.legislation_code,'GENERIC')) =
	     nvl(bt.legislation_code,nvl(btbg.legislation_code,'GENERIC')) and
             nvl(iv.business_group_id, nvl(bt.business_group_id, -1)) =
	     nvl(bt.business_group_id, nvl(iv.business_group_id, -1))
	    )
	    )
     for update of bt.balance_type_id;
--
   v_pay_value_name varchar2(80);
--
 begin
--
   -- Get translated name for the pay value.
--   v_pay_value_name := hr_balance_feeds.pay_value_name;
--
-- Bug 2767760 - variable is set to the base table value for iv name. We must
-- use base table values rather than translation table names, because if an
-- input_value is created in a French instance, the translated name for all
-- installed languages will be the original French name.
-- If a change is then made in a US instance, the function pay_value_name
-- will return the seeded lookup for pay value input value name as 'Pay Value'.
-- When this value is passed in as the translated iv name, no rows will be
-- returned, as the translated input value name will be the French name
-- 'Valeur salaire'. Thus all cursors in this package that use the translated
-- iv name have been changed to search for the base table name, and the
-- variable for the pay value input value name will also be that of the base
-- table - 'Pay Value'.
--
-- get the base table name for the pay value
  v_pay_value_name := 'Pay Value';
--
   for v_bt_rec in csr_pay_value_sub_class_rule
		     (p_sub_classification_rule_id,
		      v_pay_value_name) loop
--
     -- Create balance feed.
     hr_balance_feeds.ins_bal_feed
       (v_bt_rec.effective_start_date,
        v_bt_rec.effective_end_date,
        v_bt_rec.business_group_id,
        v_bt_rec.legislation_code,
        v_bt_rec.balance_type_id,
        v_bt_rec.input_value_id,
        v_bt_rec.scale,
        null,
        p_mode);
--
   end loop;
--
 end ins_bf_sub_class_rule;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.del_bf_input_value                                      --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Adjusts or removes balance feeds when an input value is deleted NB.      --
 -- when shortening an input value all related balance feeds are shortened.  --
 -- When extending a balance feed then only automatic balance feeds are      --
 -- extended.                                                                --
 ------------------------------------------------------------------------------
--
 procedure del_bf_input_value
 (
  p_input_value_id        number,
  p_dt_mode               varchar2,
  p_validation_start_date date,
  p_validation_end_date   date
 ) is
--
   c_eot constant date := to_date('31/12/4712','DD/MM/YYYY');
--
   -- Find all balance feeds for an input value.
   cursor csr_bal_feeds_zap
	  (
	   p_input_value_id number
          ) is
     select bf.rowid row_id
     from   pay_balance_feeds_f bf,
	    pay_balance_types bt
     where  bf.input_value_id = p_input_value_id
       and  bt.balance_type_id = bf.balance_type_id
     for update;
--
   -- Find all balance feeds for an input value that start after a specified
   -- date.
   cursor csr_bal_feeds_delete
	  (
	   p_input_value_id        number,
	   p_validation_start_date date
          ) is
     select bf.rowid row_id
     from   pay_balance_feeds_f bf,
	    pay_balance_types bt
     where  bf.input_value_id = p_input_value_id
       and  bf.effective_start_date >= p_validation_start_date
       and  bt.balance_type_id = bf.balance_type_id
     for update;
--
   -- Find all balance feeds for an input value that straddles a specified
   -- date.
   cursor csr_bal_feeds_update
	  (
	   p_input_value_id        number,
	   p_validation_start_date date
          ) is
     select bf.rowid row_id
     from   pay_balance_feeds_f bf,
	    pay_balance_types bt
     where  bf.input_value_id = p_input_value_id
       and  bf.effective_end_date >= p_validation_start_date
       and  bt.balance_type_id = bf.balance_type_id
     for update;
--
   -- Find the latest balance feed records for all balance feeds for an input
   -- value NB. it only selects balance feeds which were automatically
   -- created.
   cursor csr_bal_feeds_extend
	  (
	   p_input_value_id number
          ) is
     select bf.rowid row_id
     from   pay_balance_feeds_f bf,
	    pay_balance_types bt
     where  bf.input_value_id = p_input_value_id
       and  bt.balance_type_id = bf.balance_type_id
       and  bf.effective_end_date =
	      (select max(bf2.effective_end_date)
	       from   pay_balance_feeds_f bf2
	       where  bf2.balance_feed_id = bf.balance_feed_id)
       and  exists
	      (select null
	       from   pay_balance_classifications bc
	       where  bc.balance_type_id = bf.balance_type_id)
     for update;
--
 begin
--
   -- Input value is being removed so all balance feeds for the input value
   -- have to be removed.
   if p_dt_mode = 'ZAP' then
--
     for v_bf_rec in csr_bal_feeds_zap
		       (p_input_value_id) loop
--
       delete from pay_balance_feeds_f bf
       where  bf.rowid = v_bf_rec.row_id;
--
     end loop;
--
   -- Input value is being shortened so all balance feeds for the input value
   -- that would exist past the new end date of the input value have to be
   -- shortened. All balance feeds that exist after the new end date have to
   -- be removed.
   elsif p_dt_mode = 'DELETE' then
--
     for v_bf_rec in csr_bal_feeds_delete
		       (p_input_value_id,
			p_validation_start_date) loop
--
       delete from pay_balance_feeds_f bf
       where  bf.rowid = v_bf_rec.row_id;
--
     end loop;
--
     for v_bf_rec in csr_bal_feeds_update
		       (p_input_value_id,
			p_validation_start_date) loop
--
       update pay_balance_feeds_f bf
       set    bf.effective_end_date = p_validation_start_date - 1
       where  bf.rowid = v_bf_rec.row_id;
--
     end loop;
--
   -- Input value is being extended so all automatic balance feeds that were
   -- set according to the end date of the input value will have to be
   -- extended NB. manual balance feeds are not extended.
   elsif (p_dt_mode = 'DELETE_NEXT_CHANGE' and
	  p_validation_end_date = c_eot)
      or  p_dt_mode = 'FUTURE_CHANGE' then
--
     -- See if input value being extended is the Pay Value NB. automatic
     -- balance feeds are only created for the Pay Value. Extend the balance
     -- feed to the new end date of the input value.
     if hr_balance_feeds.is_pay_value(p_input_value_id) then
--
       for v_bf_rec in csr_bal_feeds_extend
			 (p_input_value_id) loop
--
         update pay_balance_feeds_f bf
	 set    bf.effective_end_date = p_validation_end_date
	 where  bf.rowid = v_bf_rec.row_id;
--
       end loop;
--
     end if;
--
   else
--
     if p_dt_mode = 'DELETE_NEXT_CHANGE' then
       hr_utility.set_message(801,'HR_72033_CANNOT_DNC_RECORD');
       hr_utility.raise_error;
     else
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','hr_balance_feeds.del_bf_input_value');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
     end if;
--
   end if;
--
 end del_bf_input_value;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.del_bf_sub_class_rule                                   --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Adjusts or removes balance feeds when a sub classification rule is       --
 -- deleted NB. this only affects automatic balance feeds.                   --
 ------------------------------------------------------------------------------
--
 procedure del_bf_sub_class_rule
 (
  p_sub_classification_rule_id number,
  p_dt_mode                    varchar2,
  p_validation_start_date      date,
  p_validation_end_date        date
 ) is
--
   --
   -- Find all balance feeds that were created as a direct result of adding
   -- the sub classification rule.
   --
   cursor csr_bal_feeds_sub_class_rule
	  (
	   p_sub_classification_rule_id number,
	   p_pay_value_name             varchar2
          ) is
     select bf.rowid row_id
     from   pay_sub_classification_rules_f scr,
	    pay_input_values_f iv,
	    pay_balance_feeds_f bf,
	    pay_balance_classifications bc,
	    pay_balance_types bt
     where  scr.sub_classification_rule_id = p_sub_classification_rule_id
       and  iv.element_type_id = scr.element_type_id
       and  iv.name = p_pay_value_name
       and  bc.classification_id = scr.classification_id
       and  bt.balance_type_id = bc.balance_type_id
       and  bf.balance_type_id = bt.balance_type_id
       and  bf.input_value_id = iv.input_value_id
       and  bf.effective_start_date = scr.effective_start_date
       and  bf.effective_end_date   = scr.effective_end_date
       and  scr.effective_start_date between iv.effective_start_date
					 and iv.effective_end_date
     for update;
--
   v_pay_value_name varchar2(80);
--
 begin
--
   -- Get translated name for pay value
   -- v_pay_value_name := hr_balance_feeds.pay_value_name;
   --
   -- Bug 2767760 - search for this bug number for full explanation of these
   -- changes.
   -- Set variable to base table pay value input value name
      v_pay_value_name := 'Pay Value';
--
   -- Sub classification rule is being removed. Need to remove all automatic
   -- balance feeds that were created as a direct result of adding the sub
   -- classification rule.
   if p_dt_mode = 'ZAP' then
--
     for v_bf_rec in csr_bal_feeds_sub_class_rule
		       (p_sub_classification_rule_id,
			v_pay_value_name) loop
--
       delete from pay_balance_feeds_f bf
       where  bf.rowid = v_bf_rec.row_id;
--
     end loop;
--
   -- Sub classification rule is being shortened. Need to shorten all automatic
   -- balance feeds that were created as a direct result of adding the sub
   -- classification rule.
   elsif p_dt_mode = 'DELETE' then
--
     for v_bf_rec in csr_bal_feeds_sub_class_rule
		       (p_sub_classification_rule_id,
			v_pay_value_name) loop
--
       update pay_balance_feeds_f bf
       set    bf.effective_end_date = p_validation_start_date - 1
       where  bf.rowid = v_bf_rec.row_id;
--
     end loop;
--
   -- Sub classification rule is being extended. Need to extend all automatic
   -- balance feeds that were created as a direct result of adding the sub
   -- classification rule NB. sub classification rules cannot be updated so
   -- 'DELETE_NEXT_CHANGE' will always open up a sub classification rule.
   elsif p_dt_mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE') then
--
     for v_bf_rec in csr_bal_feeds_sub_class_rule
		       (p_sub_classification_rule_id,
			v_pay_value_name) loop
--
       update pay_balance_feeds_f bf
       set    bf.effective_end_date = p_validation_end_date
       where  bf.rowid = v_bf_rec.row_id;
--
     end loop;
--
   else
--
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
				  'hr_balance_feeds.del_bf_sub_class_rule');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
--
   end if;
--
 end del_bf_sub_class_rule;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_balance_feeds.bf_chk_proc_run_results                                 --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Detects if a change in a balance feed could result in a change of a      --
 -- balance value ie. the period over which the balance feed changes         --
 -- overlaps with a processed run result NB. the change in balance feed      --
 -- couold be caused by a manual change, removing a sub classification etc.. --
 ------------------------------------------------------------------------------
--
 function bf_chk_proc_run_results
 (
  p_mode                       varchar2,
  p_dml_mode                   varchar2,
  p_balance_type_id            number,
  p_classification_id          number,
  p_balance_classification_id  number,
  p_balance_feed_id            number,
  p_sub_classification_rule_id number,
  p_input_value_id             number,
  p_validation_start_date      date,
  p_validation_end_date        date
 ) return boolean is
--
   cursor csr_bf_ins_bal_class
	  (
	   p_balance_type_id   number,
	   p_classification_id number,
           p_pay_value_name    varchar2
          ) is
     select iv.input_value_id,
	    min(iv.effective_start_date) effective_start_date,
	    max(iv.effective_end_date) effective_end_date
     from   pay_input_values_f iv,
	    pay_element_types_f et,
	    pay_element_classifications ec,
	    pay_balance_types bt,
	    per_business_groups_perf ivbg,
	    per_business_groups_perf btbg
     where  bt.balance_type_id = p_balance_type_id
       and  ec.classification_id = p_classification_id
       and  ec.parent_classification_id is null
       and  et.classification_id = ec.classification_id
       and  iv.element_type_id = et.element_type_id
       and  iv.name = p_pay_value_name
       and  substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
       and  (bt.balance_uom <> 'M' or
            (bt.balance_uom = 'M' and
             bt.currency_code = et.output_currency_code))
       and  iv.effective_start_date between et.effective_start_date
                                        and et.effective_end_date
       /*
	  Join are to get the legislation code for the business groups of the
	  balance and input value being matched.
       */
       and  iv.business_group_id = ivbg.business_group_id (+)
       and  bt.business_group_id = btbg.business_group_id (+)
       /*
	  Match on business group OR
          Business groups do not match so try to match on legislation NB.
          need to protect against the case where the business groups are
          different but share the same legislation code.
       */
       and  (
	     nvl(ivbg.business_group_id,-1) = nvl(btbg.business_group_id,-2) or
	    (
	     nvl(iv.legislation_code,nvl(ivbg.legislation_code,'GENERIC')) =
	     nvl(bt.legislation_code,nvl(btbg.legislation_code,'GENERIC')) and
             nvl(iv.business_group_id, nvl(bt.business_group_id, -1)) =
	     nvl(bt.business_group_id, nvl(iv.business_group_id, -1))
	    )
	    )
     group by iv.input_value_id
     union
     select iv.input_value_id,
	    scr.effective_start_date,
	    scr.effective_end_date
     from   pay_sub_classification_rules_f scr,
	    pay_element_types_f et,
	    pay_input_values_f iv,
	    pay_element_classifications ec,
	    pay_balance_types bt,
	    per_business_groups_perf ivbg,
	    per_business_groups_perf btbg
     where  bt.balance_type_id = p_balance_type_id
       and  ec.classification_id = p_classification_id
       and  ec.parent_classification_id is not null
       and  scr.classification_id = ec.classification_id
       and  et.element_type_id = scr.element_type_id
       and  iv.element_type_id = et.element_type_id
       and  iv.name = p_pay_value_name
       and  substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
       and  (bt.balance_uom <> 'M' or
            (bt.balance_uom = 'M' and
             bt.currency_code = et.output_currency_code))
       and  scr.effective_start_date between et.effective_start_date
                                         and et.effective_end_date
       and  scr.effective_start_date between iv.effective_start_date
                                         and iv.effective_end_date
       /*
	  Join are to get the legislation code for the business groups of the
	  balance and input value being matched.
       */
       and  iv.business_group_id = ivbg.business_group_id (+)
       and  bt.business_group_id = btbg.business_group_id (+)
       /*
	  Match on business group OR
          Business groups do not match so try to match on legislation NB.
          need to protect against the case where the business groups are
          different but share the same legislation code.
       */
       and  (
	     nvl(ivbg.business_group_id,-1) = nvl(btbg.business_group_id,-2) or
	    (
	     nvl(iv.legislation_code,nvl(ivbg.legislation_code,'GENERIC')) =
	     nvl(bt.legislation_code,nvl(btbg.legislation_code,'GENERIC')) and
             nvl(iv.business_group_id, nvl(bt.business_group_id, -1)) =
	     nvl(bt.business_group_id, nvl(iv.business_group_id, -1))
	    )
	    );
--
   cursor csr_bf_upd_del_bal_class
          (
           p_balance_classification_id number
          ) is
     select bf.balance_feed_id
     from   pay_balance_feeds_f bf,
	    pay_balance_classifications bc,
	    pay_element_classifications ec
     where  bc.balance_classification_id = p_balance_classification_id
       and  bf.balance_type_id = bc.balance_type_id
       and  ec.classification_id = bc.classification_id
       and ((ec.parent_classification_id is null and
	     exists
               (select null
                from   pay_element_types_f et,
	               pay_input_values_f iv
                where  iv.input_value_id = bf.input_value_id
                  and  et.element_type_id = iv.element_type_id
                  and  et.classification_id = bc.classification_id))
        or  (ec.parent_classification_id is not null and
             exists
	       (select null
	        from   pay_sub_classification_rules_f scr,
		       pay_input_values_f iv
                where  iv.input_value_id = bf.input_value_id
	          and  scr.element_type_id = iv.element_type_id
	          and  scr.classification_id = bc.classification_id)))
       and  exists
	      (select null
	       from   pay_run_results rr,
		      pay_run_result_values rrv
               where  rrv.input_value_id = bf.input_value_id
		 and  rr.run_result_id = rrv.run_result_id
		 and  rr.status like 'P%');
--
   cursor csr_bal_feed
          (
           p_input_value_id        number,
	   p_validation_start_date date,
	   p_validation_end_date   date
          ) is
     select 1
     from   dual
     where  exists
	      (select /*+ ORDERED USE_NL(rrv rr aa pa)
                          INDEX(rrv PAY_RUN_RESULT_VALUES_PK) */ null
	       from   pay_run_result_values rrv,
                      pay_run_results rr,
		      pay_assignment_actions aa,
		      pay_payroll_actions pa
               where  rrv.input_value_id = p_input_value_id
		 and  rr.run_result_id = rrv.run_result_id
		 and  rr.status like 'P%'
		 and  aa.assignment_action_id = rr.assignment_action_id
		 and  pa.payroll_action_id = aa.payroll_action_id
		 and  pa.effective_date between p_validation_start_date
					    and p_validation_end_date);
--
   -- Finds all balance feeds that should be created as a direct result of
   -- creating a sub classification rule ie. find any balance classifications
   -- that match.
   cursor csr_bf_ins_sub_class_rule
          (
           p_classification_id number,
           p_pay_value_name    varchar2
          ) is
     select iv.input_value_id,
	    scr.effective_start_date,
	    scr.effective_end_date
     from   pay_sub_classification_rules_f scr,
	    pay_element_types_f et,
	    pay_input_values_f iv,
	    pay_balance_classifications bc,
	    pay_balance_types bt,
	    per_business_groups_perf ivbg,
	    per_business_groups_perf btbg
     where  bc.classification_id = p_classification_id
       and  bt.balance_type_id = bc.balance_type_id
       and  et.element_type_id = scr.element_type_id
       and  iv.element_type_id = et.element_type_id
       and  iv.name = p_pay_value_name
       and  substr(iv.uom,1,1) = substr(bt.balance_uom,1,1)
       and  (bt.balance_uom <> 'M' or
            (bt.balance_uom = 'M' and
             bt.currency_code = et.output_currency_code))
       and  scr.effective_start_date between et.effective_start_date
                                         and et.effective_end_date
       and  scr.effective_start_date between iv.effective_start_date
                                         and iv.effective_end_date
       /*
	  Join are to get the legislation code for the business groups of the
	  balance and input value being matched.
       */
       and  iv.business_group_id = ivbg.business_group_id (+)
       and  bt.business_group_id = btbg.business_group_id (+)
       /*
	  Match on business group OR
          Business groups do not match so try to match on legislation NB.
          need to protect against the case where the business groups are
          different but share the same legislation code.
       */
       and  (
	     nvl(ivbg.business_group_id,-1) = nvl(btbg.business_group_id,-2) or
	    (
	     nvl(iv.legislation_code,nvl(ivbg.legislation_code,'GENERIC')) =
	     nvl(bt.legislation_code,nvl(btbg.legislation_code,'GENERIC')) and
             nvl(iv.business_group_id, nvl(bt.business_group_id, -1)) =
	     nvl(bt.business_group_id, nvl(iv.business_group_id, -1))
	    )
	    );
--
   cursor csr_bf_upd_del_sub_class_rule
	  (
	   p_sub_classification_rule_id number,
	   p_validation_start_date      date,
	   p_validation_end_date        date
          ) is
     select bf.balance_feed_id
     from   pay_sub_classification_rules_f scr,
	    pay_input_values_f iv,
	    pay_balance_feeds_f bf,
	    pay_balance_classifications bc
     where  scr.sub_classification_rule_id = p_sub_classification_rule_id
       and  iv.element_type_id = scr.element_type_id
       and  bc.classification_id = scr.classification_id
       and  bf.balance_type_id = bc.balance_type_id
       and  bf.input_value_id = iv.input_value_id
       and  bf.effective_start_date = scr.effective_start_date
       and  bf.effective_end_date   = scr.effective_end_date
       and  scr.effective_start_date between iv.effective_start_date
					 and iv.effective_end_date
       and  exists
	      (select /*+ ORDERED*/
                      null
	       from   pay_run_result_values rrv,
                      pay_run_results rr,
		      pay_assignment_actions aa,
		      pay_payroll_actions pa
               where  rrv.input_value_id = bf.input_value_id
		 and  rr.run_result_id = rrv.run_result_id
		 and  rr.status like 'P%'
		 and  aa.assignment_action_id = rr.assignment_action_id
		 and  pa.payroll_action_id = aa.payroll_action_id
		 and  pa.effective_date between p_validation_start_date
					    and p_validation_end_date);
--
   cursor csr_proc_run_result
	  (
	   p_input_value_id        number,
	   p_validation_start_date date,
	   p_validation_end_date   date
          ) is
     select 1
       from dual
      where
            exists (select /*+ FIRST_ROWS ORDERED
                               USE_NL(rrv rr aa pa)
                               INDEX(rrv PAY_RUN_RESULT_VALUES_PK)
                               INDEX(rr PAY_RUN_RESULTS_PK)
                               INDEX(aa PAY_ASSIGNMENT_ACTIONS_PK)
                               INDEX(pa PAY_PAYROLL_ACTIONS_PK)
                          */ 1
                    from   pay_run_result_values rrv,
                           pay_run_results rr,
                           pay_assignment_actions aa,
                           pay_payroll_actions pa
                    where  rrv.input_value_id = p_input_value_id
                      and  rr.run_result_id = rrv.run_result_id
                      and  rr.status like 'P%'
                      and  aa.assignment_action_id = rr.assignment_action_id
                      and  pa.payroll_action_id = aa.payroll_action_id
                      and  pa.effective_date between p_validation_start_date
                                                 and p_validation_end_date);
--
   cursor csr_proc
	  (
	   p_validation_start_date date,
	   p_validation_end_date   date
          ) is
     select /*+ INDEX(pa pay_payroll_actions_n5)*/
            payroll_action_id
       from pay_payroll_actions pa
      where pa.effective_date between p_validation_start_date
                                  and p_validation_end_date
        and action_type in ('R', 'Q', 'B', 'I', 'V')
      order by payroll_action_id desc;
--
   cursor csr_rrv_exists
          (
           p_input_value_id        number
          ) is
     select 1
       from dual
      where
            exists (select 1
                    from   pay_run_result_values rrv
                    where  rrv.input_value_id = p_input_value_id);
--
   cursor csr_proc_feed_result
	  (
	   p_payroll_action_id     number,
	   p_input_value_id        number
          ) is
     select 1
       from dual
      where
            exists (select /*+ FIRST_ROWS ORDERED
                               USE_NL(rr aa rrv)
                               INDEX(rrv PAY_RUN_RESULT_VALUES_N50)
                               INDEX(rr PAY_RUN_RESULTS_N50)
                               INDEX(aa PAY_ASSIGNMENT_ACTIONS_N50)
                          */ 1
                    from   pay_assignment_actions aa,
                           pay_run_results rr,
                           pay_run_result_values rrv
                    where  rrv.input_value_id = p_input_value_id
                      and  rr.run_result_id = rrv.run_result_id
                      and  rr.status like 'P%'
                      and  aa.assignment_action_id = rr.assignment_action_id
                      and  aa.payroll_action_id = p_payroll_action_id);

   v_bf_id          number;
   v_pay_value_name varchar2(80);
   v_rrv_found      boolean := FALSE;
   v_rr_rec         csr_proc_run_result%rowtype;
   v_pfr_rec        csr_proc_feed_result%rowtype;
   v_iv_id          number;
   v_rrv_exists     number := -1;
   v_check_value    pay_action_parameters.parameter_name%type;
--
 begin
--
   -- Get translated name for pay value
   -- v_pay_value_name := hr_balance_feeds.pay_value_name;
   -- Bug 2767760 - search for this bug number for full explanation of these
   -- changes.
   -- Set variable to base table pay value input value name
      v_pay_value_name := 'Pay Value';
--
   if (p_mode = 'BALANCE_CLASSIFICATION' and
       p_dml_mode = 'UPDATE_DELETE' and
       p_balance_classification_id is not null) then
--
     open csr_bf_upd_del_bal_class
	    (p_balance_classification_id);
     fetch csr_bf_upd_del_bal_class into v_bf_id;
     if csr_bf_upd_del_bal_class%found then
       close csr_bf_upd_del_bal_class;
       return (TRUE);
     else
       close csr_bf_upd_del_bal_class;
       return (FALSE);
     end if;
--
   elsif (p_mode = 'BALANCE_FEED' and
	  p_dml_mode = 'UPDATE_DELETE' and
	  p_balance_feed_id is not null) then
--
     select distinct input_value_id
     into   v_iv_id
     from   pay_balance_feeds_f
     where  balance_feed_id = p_balance_feed_id;
--
     open csr_bal_feed
	    (v_iv_id,
	     p_validation_start_date,
	     p_validation_end_date);
     fetch csr_bal_feed into v_bf_id;
     if csr_bal_feed%found then
       close csr_bal_feed;
       return (TRUE);
     else
       close csr_bal_feed;
       return (FALSE);
     end if;
--
   elsif (p_mode = 'SUB_CLASSIFICATION_RULE' and
	  p_dml_mode = 'UPDATE_DELETE' and
	  p_sub_classification_rule_id is not null) then
--
     open csr_bf_upd_del_sub_class_rule
	    (p_sub_classification_rule_id,
	     p_validation_start_date,
	     p_validation_end_date);
     fetch csr_bf_upd_del_sub_class_rule into v_bf_id;
     if csr_bf_upd_del_sub_class_rule%found then
       close csr_bf_upd_del_sub_class_rule;
       return (TRUE);
     else
       close csr_bf_upd_del_sub_class_rule;
       return (FALSE);
     end if;
--
   elsif (p_mode = 'SUB_CLASSIFICATION_RULE' and
	  p_dml_mode = 'INSERT' and
	  p_classification_id is not null) then
--
     for v_iv_rec in csr_bf_ins_sub_class_rule
	               (p_classification_id,
                        v_pay_value_name) loop
--
       open csr_proc_run_result
	      (v_iv_rec.input_value_id,
	       v_iv_rec.effective_start_date,
	       v_iv_rec.effective_end_date);
       fetch csr_proc_run_result into v_rr_rec;
       if csr_proc_run_result%found then
	 close csr_proc_run_result;
	 v_rrv_found := TRUE;
	 exit;
       else
	 close csr_proc_run_result;
       end if;
--
     end loop;
--
     if v_rrv_found then
       return (TRUE);
     else
       return (FALSE);
     end if;
--
   elsif (p_mode = 'BALANCE_CLASSIFICATION' and
          p_dml_mode = 'INSERT' and
          p_classification_id is not null) then
--
     for v_iv_rec in csr_bf_ins_bal_class
	               (p_balance_type_id,
			p_classification_id,
                        v_pay_value_name) loop
--
       open csr_proc_run_result
	      (v_iv_rec.input_value_id,
	       v_iv_rec.effective_start_date,
	       v_iv_rec.effective_end_date);
       fetch csr_proc_run_result into v_rr_rec;
       if csr_proc_run_result%found then
	 close csr_proc_run_result;
	 v_rrv_found := TRUE;
	 exit;
       else
	 close csr_proc_run_result;
       end if;
--
     end loop;
--
     if v_rrv_found then
       return (TRUE);
     else
       return (FALSE);
     end if;
--
   elsif (p_mode = 'BALANCE_FEED' and
	  p_dml_mode = 'INSERT' and
	  p_input_value_id is not null) then
--
     --
     -- Check if this warning check has been disabled
     --
     begin
        select parameter_value
        into v_check_value
        from pay_action_parameters pap
        where pap.parameter_name = 'CHANGED_BALANCE_VALUE_CHECK';

     exception
        when others then
           v_check_value := 'Y';
     end;

     if v_check_value = 'N' then
        v_rrv_found := FALSE;
     else
        for proc in csr_proc
	    (p_validation_start_date,
	     p_validation_end_date) loop

           if (v_rrv_exists = -1) then
             open csr_rrv_exists
                  (p_input_value_id);
             fetch csr_rrv_exists into v_rrv_exists;
             if csr_rrv_exists%notfound then
	       close csr_rrv_exists;
               exit;
             else
	       close csr_rrv_exists;
             end if;
           end if;

             open csr_proc_feed_result
	       (proc.payroll_action_id,
                p_input_value_id);
             fetch csr_proc_feed_result into v_pfr_rec;
             if csr_proc_feed_result%found then
	       close csr_proc_feed_result;
	       v_rrv_found := TRUE;
	       exit;
             else
	       close csr_proc_feed_result;
             end if;
        end loop;
     end if;
--
     if v_rrv_found then
       return (TRUE);
     else
       return (FALSE);
     end if;
--
   else
--
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
				  'hr_balance_feeds.bf_chk_proc_run_results');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
--
   end if;
--
 end bf_chk_proc_run_results;
--
end HR_BALANCE_FEEDS;

/
