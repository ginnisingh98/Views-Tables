--------------------------------------------------------
--  DDL for Package Body PAY_BAL_ADJUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BAL_ADJUST" as
/* $Header: pybaladj.pkb 120.5.12010000.2 2008/10/01 06:12:11 ankagarw ship $ */
/*
  NOTES
  o The first implementation of the batch balance adjustment does
    not make use of the (yet to be designed) batch adjutment tables.
    Therefore, this process either runs or fails in one commit, as
    there is no place to store the information about the adjustments
    to allow re-runs.  Therefore, any error causes an immediate
    exit from the entire process, all work having been lost.
  o The upcoming proper batch version may even use the datapump
    tables, but this is not decided yet.
*/

/*---------------------------------------------------------------------------*/
/*-------------------------- constant definitions ---------------------------*/
/*---------------------------------------------------------------------------*/
g_number constant number:= hr_api.g_number;

/*---------------------------------------------------------------------------*/
/*------------------------ balance adjustment types -------------------------*/
/*---------------------------------------------------------------------------*/
type info_r is record
(
   batchid     number,
   effdate     date,
   busgrpid    number,
   legcode     varchar2(30),
   asgid       number,
   assactid    number,
   payid       number,
   runtypeid   number,
   batch_mode  varchar2(30),
   tax_unit_id number,
   purge_mode  boolean,
   action_type varchar2(30)

);

/*---------------------------------------------------------------------------*/
/*----------------------- balance adjustment globals ------------------------*/
/*---------------------------------------------------------------------------*/
g_info  info_r;
g_curr_chunk_no number := 1;
g_no_asg_act number := 1;

/*---------------------------------------------------------------------------*/
/*--------------------- local functions and procedures ----------------------*/
/*---------------------------------------------------------------------------*/

/*
 *  This is a cover for a reset to the
 *  global information variable.  Called to reset after the
 *  batch has been processed.
 */
procedure purge_batch_info is
begin
   g_info.batchid     := null;
   g_info.effdate     := null;
   g_info.busgrpid    := null;
   g_info.legcode     := null;
   g_info.asgid       := null;
   g_info.assactid    := null;
   g_info.payid       := null;
   g_info.runtypeid   := null;
   g_info.tax_unit_id := null;
   g_info.purge_mode  := null;
   g_info.action_type := null;
end purge_batch_info;

/*
 *  Insert an assignment action for a particular assignment
 *  to be processed by the balance adjustment.  Note that there
 *  is one assignment action per assignment/balance adjustment.
 *  Therefore, there can be more than one assignment action per
 *  assignnment attached to the payroll action.
 */
function insert_assact
(
   p_info             in out nocopy info_r,
   p_element_entry_id in            number,
   run_type_id        in            number default null
) return number is
   l_assactid number;
   l_payid    number;
   l_tax_unit_id number:= p_info.tax_unit_id;
   l_chunk_size number;
   l_found boolean;
begin


  pay_core_utils.get_action_parameter('CHUNK_SIZE',l_chunk_size,l_found);

  if (l_found=FALSE)
  then
   l_chunk_size := 20;
  end if;
   --
   -- Identify the tax unit
   --
   if l_tax_unit_id is null then

     l_tax_unit_id := hr_dynsql.get_tax_unit
                        (p_assignment_id  => p_info.asgid
                        ,p_effective_date => p_info.effdate
                        );
   end if;

   -- Look for an existing assignment action.
   select act.assignment_action_id
   into   l_assactid
   from   pay_assignment_actions act
   where  act.payroll_action_id = p_info.batchid
   and    nvl(act.tax_unit_id, g_number) = nvl(l_tax_unit_id, g_number)
   and    act.assignment_id     = p_info.asgid;

   hr_utility.trace('(existing) l_assactid : ' || l_assactid);

   return(l_assactid);

exception when no_data_found then
   -- Need to create new assignment action.
   -- Also trashes the latest balances.
   hrassact.inassact_main
     (pactid              => p_info.batchid
     ,asgid               => p_info.asgid
     ,p_ass_action_seq    => null
     ,p_serial_number     => null
     ,p_pre_payment_id    => null
     ,p_element_entry     => p_element_entry_id
     ,p_asg_lock          => TRUE
     ,taxunt              => l_tax_unit_id
     ,p_purge_mode        => p_info.purge_mode
     ,p_run_type_id       => run_type_id
     );

   -- Get the action id of that created.
   hr_utility.set_location('insert_assact', 20);
   select act.assignment_action_id
   into   l_assactid
   from   pay_assignment_actions act
   where  act.payroll_action_id = p_info.batchid
   and    act.assignment_id     = p_info.asgid
   and    nvl(act.tax_unit_id, g_number) = nvl(l_tax_unit_id, g_number);

   hr_utility.trace('(new) l_assactid : ' || l_assactid);

   update pay_assignment_actions
   set chunk_number = g_curr_chunk_no
   where assignment_action_id= l_assactid;

   g_no_asg_act := g_no_asg_act + 1;
   if g_no_asg_act > l_chunk_size
   then
     g_curr_chunk_no := g_curr_chunk_no +1;
     g_no_asg_act :=1;
   end if;


   return(l_assactid);

end insert_assact;

/*
 *  Get some information about the batch getting processed.
 *  Also performs some validation on that batch.
 */
function get_batch_info
(
   p_batch_id in number
) return info_r is
   l_business_group_id number;
   l_legislation_code  varchar2(30);
   l_payroll_id        number;
   l_effective_date    date;
   l_mode              varchar2(30);
   l_info              info_r;
   l_action_type       varchar2(30);
begin
   if(p_batch_id <> g_info.batchid or g_info.batchid is null) then
      -- Re-set the assignment information.
      g_info.asgid := null;
      g_info.runtypeid := null;
      g_info.tax_unit_id := null;
      g_info.purge_mode  := null;

      -- Get information for the batch.
      -- We perform a basic check here that we are not
      -- effectively processing a batch we shouldn't be.
      select pac.business_group_id,
             pac.effective_date,
             pac.payroll_id,
             pbg.legislation_code,
             pac.batch_process_mode,
             pac.action_type
      into   l_business_group_id,
             l_effective_date,
             l_payroll_id,
             l_legislation_code,
             l_mode,
             l_action_type
      from   pay_payroll_actions pac,
             per_business_groups pbg
      where  pac.payroll_action_id        = p_batch_id
      and    pac.action_status            <> 'C'
      and    pbg.business_group_id        = pac.business_group_id;

      -- Everything ok - store information in global record.
      g_info.batchid    := p_batch_id;
      g_info.busgrpid   := l_business_group_id;
      g_info.legcode    := l_legislation_code;
      g_info.effdate    := l_effective_date;
      g_info.payid      := l_payroll_id;
      g_info.batch_mode := l_mode;
      g_info.action_type:= l_action_type;

      -- Output information the first time round.
      hr_utility.trace('batchid  : ' || g_info.batchid);
      hr_utility.trace('effdate  : ' || fnd_date.date_to_canonical(l_info.effdate));
      hr_utility.trace('busgrpid : ' || g_info.busgrpid);
      hr_utility.trace('asgid    : ' || g_info.asgid);
      hr_utility.trace('mode     : ' || g_info.batch_mode);
      hr_utility.trace('acttype  : ' || g_info.action_type);

   end if;

   l_info := g_info;

   return(l_info);

end get_batch_info;

/*
 *  Function returns record holding relevant
 *  information about the assignment.
 *  Returns the information in the general
 *  information record.
 *
 *  Note that the current implementation of
 *  this function uses the existing hrassact
 *  inassact procedure.  This avoids the need
 *  to clone the logic for retrospective
 *  adjustments.  However, this means that
 *  it needs to be passed the element_entry_id
 *  (which is used in latest balance trashing)
 *  and therefore has to be called after the
 *  element entry creation.
 */
function get_asg_info
(
   p_info             in info_r,
   p_assignment_id    in number,
   p_element_entry_id in number,
   run_type_id        in number  default null,
   p_tax_unit_id      in number  default null,
   p_purge_mode       in boolean default false
) return info_r is
   l_info     info_r;
   l_assactid number;
begin

   -- If anything relevant has changed, we need to
   -- (re)derive the information.
   if(g_info.asgid is null
      or g_info.asgid <> p_assignment_id
      or nvl(g_info.runtypeid, g_number) <> nvl(run_type_id, g_number)
      or nvl(g_info.tax_unit_id, g_number) <> nvl(p_tax_unit_id, g_number)
      ) then

      hr_utility.trace('batchid : ' || p_info.batchid);

      g_info.asgid   := p_assignment_id;
      g_info.runtypeid   := run_type_id;
      g_info.tax_unit_id := p_tax_unit_id;
      g_info.purge_mode  := p_purge_mode;

      -- May need to insert an assignment action.
      g_info.assactid := insert_assact(g_info, p_element_entry_id,run_type_id);

      -- Output information first time round.
      hr_utility.trace('assignment_id        : ' || p_assignment_id);
      hr_utility.trace('business_group_id    : ' || g_info.busgrpid);
      hr_utility.trace('assignment_action_id : ' || g_info.assactid);
      hr_utility.trace('run_type_id          : ' || g_info.runtypeid);

   end if;

   -- Return the information.
   l_info := g_info;

   return(l_info);

end get_asg_info;

/*---------------------------------------------------------------------------*/
/*------------------ global functions and procedures ------------------------*/
/*---------------------------------------------------------------------------*/

/*
 *  Initialises the batch balance adjustment run.
 *  Must be called before the adjust_balance procedures.
 *  Currently, this inserts a payroll action against which
 *  the Balance Adjustments will be processed.
 */
function init_batch
(
   p_batch_name           in varchar2 default null,
   p_effective_date       in date,
   p_consolidation_set_id in number,
   p_payroll_id           in number,
   p_action_type          in varchar2 default 'B',   -- for balance adjustment.
   p_batch_mode           in varchar2 default 'STANDARD',
   p_prepay_flag          in varchar2 default 'Y'
) return number is
   l_proc              varchar2(72) := 'pay_bal_adjust.init_batch';
   l_business_group_id number;
   l_payroll_action_id number;
   l_exists            number;
   l_time_period_id    number;

   cursor csr_time_period
   is
   select
     ptp.time_period_id
   from
     per_time_periods ptp
   where
       ptp.payroll_id = p_payroll_id
   and p_effective_date between ptp.start_date
                            and ptp.end_date;

begin
   hr_utility.set_location('Entering: '||l_proc, 5);

   -- Get the business group from consolidation set
   -- and validate at same time.
   -- Also check that payroll_id passed in is valid.
   select con.business_group_id,
          pay_payroll_actions_s.nextval
   into   l_business_group_id,
          l_payroll_action_id
   from   pay_consolidation_sets con,
          pay_all_payrolls_f     prl
   where  con.consolidation_set_id = p_consolidation_set_id
   and    prl.payroll_id           = p_payroll_id
   and    p_effective_date between
          prl.effective_start_date and prl.effective_end_date
   ;
   --
   -- Obtain the time period
   --
   open csr_time_period;
   fetch csr_time_period into l_time_period_id;
   close csr_time_period;

   -- We can now insert the payroll action.
   insert  into pay_payroll_actions (
           payroll_action_id,
           action_type,
           business_group_id,
           consolidation_set_id,
           payroll_id,
           action_population_status,
           action_status,
           effective_date,
           date_earned,
           action_sequence,
           legislative_parameters,
           future_process_mode,
           batch_process_mode,
           object_version_number,
           time_period_id,
           creation_date)
   values (l_payroll_action_id,
           p_action_type,
           l_business_group_id,
           p_consolidation_set_id,
           p_payroll_id,
           'P',
           'U',
           p_effective_date,
           p_effective_date,
           pay_payroll_actions_s.nextval,
           p_batch_name,
           p_prepay_flag,
           p_batch_mode,
           1,
           l_time_period_id,
           sysdate);

   hr_utility.trace('batch_id : ' || l_payroll_action_id);

   -- Crude validation of modes.
   if(p_batch_mode not in ('STANDARD', 'NO_COMMIT')) then
      ff_utils.assert(false, 'init_batch:1');
   end if;

   hr_utility.set_location('Leaving: '||l_proc, 100);
   --
   return(l_payroll_action_id);

end init_batch;


procedure set_lat_balances
(
   p_assignment_id              in  number  default null,
   p_original_entry_id          in number   default null,
   p_element_entry_id           in number   default null,
   p_effdate                    in date     default null,
   p_busgrpid                   in number   default null,
   p_legcode                    in varchar2 default null,
   p_assactid                   in number   default null,
   p_action_type                in varchar2 default 'B',
   p_run_result_id              in number
)
is
  udca  hrassact.context_details;
  tax_unit number;
begin

  /*
   * 3482270.
   * This update is no longer necessary, hence commented out.
   *
   -- Update the inserted run result appropriately.
   update pay_run_results prr
   set    prr.assignment_action_id = p_assactid
         ,prr.source_id = nvl(p_original_entry_id, prr.source_id)
         ,prr.status = 'P'
   where  prr.source_id            = p_element_entry_id
   and    prr.source_type = 'E';
   */

   select tax_unit_id
   into tax_unit
   from pay_assignment_actions
   where assignment_action_id = p_assactid;
--
   hrassact.set_action_context (p_assactid,
                                p_run_result_id,
                                p_element_entry_id,
                                tax_unit,
                                p_assignment_id,
                                p_busgrpid,
                                p_legcode,
                                p_original_entry_id,
                                udca
                                );

   if p_action_type = 'B' then

     -- Make call to maintain latest balances.
     hrassact.maintain_lat_bal (
                assactid => p_assactid,
                rrid     => p_run_result_id,
                eentryid => p_element_entry_id,
                effdate  => p_effdate,
                udca     => udca);
   end if;


end;

/*
 *  Balance Adjustment.
 *  For calling information, please see the header.
 */
procedure adjust_balance
(
   p_batch_id                   in  number,
   p_assignment_id              in  number,
   p_element_link_id            in  number,

   --
   -- Element Entry Values Table
   --
   p_num_entry_values           IN  number,
   p_input_value_id_tbl         IN  hr_entry.number_table,
   p_entry_value_tbl            IN  hr_entry.varchar2_table,

   -- Costing information.
   p_balance_adj_cost_flag      in varchar2 default null,
   p_cost_allocation_keyflex_id in number   default null,
   p_attribute_category         in varchar2 default null,
   p_attribute1                 in varchar2 default null,
   p_attribute2                 in varchar2 default null,
   p_attribute3                 in varchar2 default null,
   p_attribute4                 in varchar2 default null,
   p_attribute5                 in varchar2 default null,
   p_attribute6                 in varchar2 default null,
   p_attribute7                 in varchar2 default null,
   p_attribute8                 in varchar2 default null,
   p_attribute9                 in varchar2 default null,
   p_attribute10                in varchar2 default null,
   p_attribute11                in varchar2 default null,
   p_attribute12                in varchar2 default null,
   p_attribute13                in varchar2 default null,
   p_attribute14                in varchar2 default null,
   p_attribute15                in varchar2 default null,
   p_attribute16                in varchar2 default null,
   p_attribute17                in varchar2 default null,
   p_attribute18                in varchar2 default null,
   p_attribute19                in varchar2 default null,
   p_attribute20                in varchar2 default null,
   p_run_type_id                in number   default null,
   p_original_entry_id          in number   default null,
   p_tax_unit_id                in number   default null,
   p_purge_mode                 in boolean  default false
) is
   l_info                    info_r;
   l_consetid                number;

   -- Returns from the API.
   l_create_warning          boolean;

   --
   -- Declare cursors and local variables
   --
   l_run_result_id 	   number;
   l_jc_name 		   varchar2(30);
   l_rr_sparse		   boolean;
   l_rr_sparse_jc          boolean;
   l_rule_mode		   varchar2(30);
   l_status		   varchar2(30);
l_found boolean;
   l_element_entry_id      pay_element_entries_f.element_entry_id%TYPE;
   l_object_version_number pay_element_entries_f.object_version_number%TYPE;
   l_effective_start_date  pay_element_entries_f.effective_start_date%TYPE;
   l_effective_end_date    pay_element_entries_f.effective_end_date%TYPE;
   l_process_in_run_flag   pay_element_types_f.process_in_run_flag%TYPE;
   l_closed_for_entry_flag pay_element_types_f.closed_for_entry_flag%TYPE;
   l_period_status         per_time_periods.status%TYPE;
   l_date_on_which_time_served_ok date;
   l_date_on_which_old_enough date;
   l_dummy                 varchar2(1);

   l_proc                  varchar2(72) := 'pay_bal_adjust.adjust_balance';
   l_element_name          pay_element_types_f.element_name%TYPE;
   l_legislation_code      pay_element_types_f.legislation_code%TYPE;

   -- bug 659393, added variables for storing all dates pased in and truncate them
   l_effective_date        date;
   --
   -- Bugfix 2665492
   -- l_costable_type needed to hold the costable_type of the element link
   --
   l_costable_type         pay_element_links_f.costable_type%TYPE;
   --
   CURSOR c_output_variables IS
      SELECT ee.object_version_number
        FROM pay_element_entries_f ee
       WHERE l_element_entry_id = ee.element_entry_id
          -- bug 675794, added date condition to select correct row
         AND l_effective_date BETWEEN ee.effective_start_date
                                 AND ee.effective_end_date;

   CURSOR c_assignment_details IS
      SELECT ptp.status
        FROM per_time_periods      ptp,
             per_all_assignments_f pas
       WHERE pas.assignment_id = p_assignment_id
         AND pas.payroll_id = ptp.payroll_id
         AND l_effective_date BETWEEN ptp.start_date
                                  AND ptp.end_date
         AND l_effective_date BETWEEN pas.effective_start_date
                                  AND pas.effective_end_date;

   CURSOR c_entry_exists IS
      SELECT 'X'
        FROM pay_element_entries_f  ee,
             pay_element_types_f    et,
             pay_element_links_f    el
       WHERE el.element_link_id = ee.element_link_id
         AND el.element_link_id = p_element_link_id
         AND el.element_type_id = et.element_type_id
         AND ee.assignment_id = p_assignment_id
         AND l_effective_date BETWEEN ee.effective_start_date
                                  AND ee.effective_end_date
         AND l_effective_date BETWEEN el.effective_start_date
                                  AND el.effective_end_date
         AND l_effective_date BETWEEN et.effective_start_date
                                  AND et.effective_end_date
         AND et.multiple_entries_allowed_flag = 'N'
         AND ee.entry_type = 'E';

   CURSOR c_element_info IS
      SELECT et.closed_for_entry_flag,
             et.process_in_run_flag,
             et.element_name,
             et.legislation_code,
      --
      --  Bugfix 2665492
      --  Retrieve the element_link costable_type
      --
             el.costable_type
        FROM pay_element_types_f et,
             pay_element_links_f el
       WHERE el.element_link_id = p_element_link_id
         AND el.element_type_id = et.element_type_id
         AND l_effective_date BETWEEN el.effective_start_date
                                  AND el.effective_end_date
         AND l_effective_date BETWEEN et.effective_start_date
                                  AND et.effective_end_date;


BEGIN

   --
   -- Issue a savepoint
   --
   savepoint adjust_balance;

   -- Validate the batch we are passing in, fetching
   -- the information if necessary.
   l_info := get_batch_info(p_batch_id);
   l_effective_date := trunc(l_info.effdate);
   l_effective_start_date := l_effective_date;

   hr_utility.set_location(l_proc, 70);

-- can't justify why this is used yet
/*
   OPEN c_entry_exists;
   FETCH c_entry_exists
   INTO l_dummy;
   IF c_entry_exists%FOUND THEN
      CLOSE c_entry_exists;
      hr_utility.set_location(l_proc, 80);
      hr_utility.set_message(801,'HR_7455_PLK_ELE_ENTRY_EXISTS');
      hr_utility.raise_error;
   END IF;
   CLOSE c_entry_exists;
*/
   hr_utility.set_location(l_proc, 90);
   OPEN c_element_info;
   FETCH c_element_info
   INTO l_closed_for_entry_flag,
        l_process_in_run_flag,
        l_element_name,
        l_legislation_code,
   --
   -- Bugfix 2665492
   -- Fetch the element_link costable_type
   --
        l_costable_type;

   IF c_element_info%NOTFOUND THEN
      CLOSE c_element_info;
      hr_utility.set_location(l_proc, 95);
      hr_utility.set_message(801,'HR_6132_ELE_ENTRY_LINK_MISSING');
      hr_utility.raise_error;
   END IF;
   CLOSE c_element_info;
--
   hr_utility.set_location(l_proc, 100);
   OPEN c_assignment_details;
   FETCH c_assignment_details
   INTO  l_period_status;
   --
   -- bug 685930, commented this out as it is done by the api, and for non-recurring entries only.
   --
   CLOSE c_assignment_details;

   IF l_closed_for_entry_flag = 'Y' THEN

     hr_utility.set_location(l_proc, 110);
     hr_utility.set_message(801,'HR_6064_ELE_ENTRY_CLOSED_ELE');
     hr_utility.raise_error;

   -- Error will not be raised for VERTEX, Workers Compensation element with
   -- Legislation code as US. Bug No 506819

   ELSIF (l_period_status = 'C' AND l_process_in_run_flag = 'Y'
         AND l_element_name not in ('US_TAX_VERTEX','VERTEX','Workers Compensation')
         AND l_legislation_code <> 'US') THEN

     hr_utility.set_location(l_proc, 120);
     hr_utility.set_message(801,'HR_6074_ELE_ENTRY_CLOSE_PERIOD');
     hr_utility.raise_error;

   --
   -- Bugfix 2665492
   -- Ensure that element_link is costable if cost_allocation_keyflex_id
   -- is not null
   --
   ELSIF l_costable_type = 'N' and p_cost_allocation_keyflex_id IS NOT NULL THEN
     --
     hr_utility.set_location(l_proc,130);
     hr_utility.set_message(801,'HR_7453_PLK_NON_COSTABLE_ELE');
     hr_utility.set_warning;
     --
   END IF;

   hr_entry.return_qualifying_conditions (p_assignment_id,
                                         p_element_link_id,
                                         l_effective_date,
                                         l_date_on_which_time_served_ok,
                                         l_date_on_which_old_enough     );

   IF l_effective_date < l_date_on_which_time_served_ok THEN
      hr_utility.set_message(801, 'HR_ELE_ENTRY_QUAL_LOS');
      hr_utility.set_warning;
   ELSIF l_effective_date < l_date_on_which_old_enough THEN
      hr_utility.set_message(801, 'HR_ELE_ENTRY_QUAL_AGE');
      hr_utility.set_warning;
   END IF;


   hr_utility.set_location(l_proc, 350);
     hr_entry_api.insert_element_entry
     (
      p_effective_start_date => l_effective_start_date,
      p_effective_end_date   => l_effective_end_date,
      p_element_entry_id     => l_element_entry_id,
      p_original_entry_id    => p_original_entry_id,
      p_assignment_id        => p_assignment_id,
      p_element_link_id      => p_element_link_id,
      -- create all elements as type 'F' with NULL creator
      p_creator_type         => 'B',
      p_entry_type           => 'B',
      p_creator_id           => l_info.assactid,
      p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id,
      p_attribute_category   => p_attribute_category,
      p_attribute1           => p_attribute1,
      p_attribute2           => p_attribute2,
      p_attribute3           => p_attribute3,
      p_attribute4           => p_attribute4,
      p_attribute5           => p_attribute5,
      p_attribute6           => p_attribute6,
      p_attribute7           => p_attribute7,
      p_attribute8           => p_attribute8,
      p_attribute9           => p_attribute9,
      p_attribute10          => p_attribute10,
      p_attribute11          => p_attribute11,
      p_attribute12          => p_attribute12,
      p_attribute13          => p_attribute13,
      p_attribute14          => p_attribute14,
      p_attribute15          => p_attribute15,
      p_attribute16          => p_attribute16,
      p_attribute17          => p_attribute17,
      p_attribute18          => p_attribute18,
      p_attribute19          => p_attribute19,
      p_attribute20          => p_attribute20,
      p_num_entry_values     => p_num_entry_values,
      p_input_value_id_tbl   => p_input_value_id_tbl,
      p_entry_value_tbl      => p_entry_value_tbl);


   -- calc jur code name
   pay_core_utils.get_leg_context_iv_name
                      ('JURISDICTION_CODE',
                       l_info.legcode,
                       l_jc_name,
                       l_found);
   if (l_found = FALSE) then
     l_jc_name := 'Jurisdiction';
   end if;

   -- set rr sparse leg_rule
   pay_core_utils.get_legislation_rule('RR_SPARSE',
                                       l_info.legcode,
                                       l_rule_mode,
                                       l_found
                                      );
   if (l_found = FALSE) then
     l_rule_mode := 'N';
   end if;

   if upper(l_rule_mode)='Y'
   then
      -- Confirm Enabling Upgrade has been made by customer
      pay_core_utils.get_upgrade_status(l_info.busgrpid,
                               'ENABLE_RR_SPARSE',
                               l_status);

      if upper(l_status)='N'
      then
         l_rule_mode := 'N';
      end if;
   end if;

   if upper(l_rule_mode)='Y'
   then
    l_rr_sparse:=TRUE;
   else
    l_rr_sparse :=FALSE;
   end if;
--
   pay_core_utils.get_upgrade_status(l_info.busgrpid,
                               'RR_SPARSE_JC',
                               l_status);
--
   if upper(l_status)='Y'
   then
    l_rr_sparse_jc :=TRUE;
   else
    l_rr_sparse_jc :=FALSE;
   end if;
--
   IF hr_utility.check_warning THEN
      l_create_warning       := TRUE;
      hr_utility.clear_warning;
   END IF;
   --
   -- Set all output arguments
   --
   OPEN  c_output_variables;
   FETCH c_output_variables
   INTO  l_object_version_number;
   CLOSE c_output_variables;

   -- Get information related to the assignment.
   -- See comments for this function.
   l_info := get_asg_info(l_info
                         ,p_assignment_id
                         ,l_element_entry_id
                         ,p_run_type_id
                         ,p_tax_unit_id
                         ,p_purge_mode
                         );
--
   -- create run result
   pay_run_result_pkg.create_run_result(
			    p_element_entry_id  => l_element_entry_id,
                            p_session_date      => l_effective_date,
                            p_business_group_id => l_info.busgrpid,
                            p_jc_name           => l_jc_name,
                            p_rr_sparse         => l_rr_sparse,
                            p_rr_sparse_jc      => l_rr_sparse_jc,
                            p_asg_action_id     => l_info.assactid,
                            p_run_result_id     => l_run_result_id);


   -- Set the creator information.  Doing this here because
   -- the entry api doesn't allow us to on insert (which seems odd)
   -- and don't see the point of going all out to use the
   -- update API.  May re-address when do 'proper' batch version.
   -- Also, balance_adj_cost_flag is not supported yet by API.
   update pay_element_entries_f pee
   set    pee.creator_id            = l_info.assactid,
          pee.creator_type          = 'B',
          pee.balance_adj_cost_flag = p_balance_adj_cost_flag
   where  pee.element_entry_id      = l_element_entry_id
   and    l_info.effdate between
          pee.effective_start_date and pee.effective_end_date;

   set_lat_balances( p_assignment_id ,
                     p_original_entry_id,
                     l_element_entry_id,
                     l_info.effdate,
                     l_info.busgrpid,
                     l_info.legcode,
                     l_info.assactid,
                     l_info.action_type,
                     l_run_result_id
                    );

   --
   -- Create asg run balances based on the run result.
   --
   pay_balance_pkg.create_rr_asg_balances
     (p_run_result_id    => l_run_result_id
     );

exception
when others then
   rollback to adjust_balance;
   --
   -- Clear the global cache
   --
   purge_batch_info;

   -- Output some final information about the error.
   hr_utility.trace('** exception information **');
   hr_utility.trace('l_info.batchid          : ' || l_info.batchid);
   hr_utility.trace('l_info.assactid         : ' || l_info.assactid);
   hr_utility.trace('l_info.payid            : ' || l_info.payid);
   hr_utility.trace('l_effective_start_date  : ' || l_effective_start_date);
   hr_utility.trace('l_effective_end_date    : ' || l_effective_end_date);
   hr_utility.trace('l_element_entry_id      : ' || l_element_entry_id);
   hr_utility.trace('l_object_version_number : ' || l_object_version_number);

   raise;
end adjust_balance;
procedure adjust_balance
(
   p_batch_id                   in  number,
   p_assignment_id              in  number,
   p_element_link_id            in  number,
   p_input_value_id1            in  number   default null,
   p_input_value_id2            in  number   default null,
   p_input_value_id3            in  number   default null,
   p_input_value_id4            in  number   default null,
   p_input_value_id5            in  number   default null,
   p_input_value_id6            in  number   default null,
   p_input_value_id7            in  number   default null,
   p_input_value_id8            in  number   default null,
   p_input_value_id9            in  number   default null,
   p_input_value_id10           in  number   default null,
   p_input_value_id11           in  number   default null,
   p_input_value_id12           in  number   default null,
   p_input_value_id13           in  number   default null,
   p_input_value_id14           in  number   default null,
   p_input_value_id15           in  number   default null,
   p_entry_value1               in  varchar2 default null,
   p_entry_value2               in  varchar2 default null,
   p_entry_value3               in  varchar2 default null,
   p_entry_value4               in  varchar2 default null,
   p_entry_value5               in  varchar2 default null,
   p_entry_value6               in  varchar2 default null,
   p_entry_value7               in  varchar2 default null,
   p_entry_value8               in  varchar2 default null,
   p_entry_value9               in  varchar2 default null,
   p_entry_value10              in  varchar2 default null,
   p_entry_value11              in  varchar2 default null,
   p_entry_value12              in  varchar2 default null,
   p_entry_value13              in  varchar2 default null,
   p_entry_value14              in  varchar2 default null,
   p_entry_value15              in  varchar2 default null,

   -- Costing information.
   p_balance_adj_cost_flag      in varchar2 default null,
   p_cost_allocation_keyflex_id in number   default null,
   p_attribute_category         in varchar2 default null,
   p_attribute1                 in varchar2 default null,
   p_attribute2                 in varchar2 default null,
   p_attribute3                 in varchar2 default null,
   p_attribute4                 in varchar2 default null,
   p_attribute5                 in varchar2 default null,
   p_attribute6                 in varchar2 default null,
   p_attribute7                 in varchar2 default null,
   p_attribute8                 in varchar2 default null,
   p_attribute9                 in varchar2 default null,
   p_attribute10                in varchar2 default null,
   p_attribute11                in varchar2 default null,
   p_attribute12                in varchar2 default null,
   p_attribute13                in varchar2 default null,
   p_attribute14                in varchar2 default null,
   p_attribute15                in varchar2 default null,
   p_attribute16                in varchar2 default null,
   p_attribute17                in varchar2 default null,
   p_attribute18                in varchar2 default null,
   p_attribute19                in varchar2 default null,
   p_attribute20                in varchar2 default null,
   p_run_type_id                in number   default null,
   p_original_entry_id          in number   default null,
   p_tax_unit_id                in number   default null,
   p_purge_mode                 in boolean  default false
) is
   l_info                    info_r;
   l_consetid                number;

   -- Returns from the API.
   l_effective_start_date    date;
   l_effective_end_date      date;
   l_element_entry_id        number;
   l_object_version_number   number;
   l_create_warning          boolean;

   l_dummy number;

   l_run_result_id 	   number;
   l_jc_name 		   varchar2(30);
   l_rr_sparse		   boolean;
   l_rr_sparse_jc          boolean;
   l_rule_mode		   varchar2(30);
   l_status		   varchar2(30);
l_found boolean;
begin

   --
   -- Issue a savepoint
   --
   savepoint adjust_balance;

   -- Validate the batch we are passing in, fetching
   -- the information if necessary.
   l_info := get_batch_info(p_batch_id);

   -- Create the element entry.
   py_element_entry_api.create_element_entry (
      p_effective_date             => l_info.effdate,
      p_business_group_id          => l_info.busgrpid,
      p_original_entry_id          => p_original_entry_id,
      p_assignment_id              => p_assignment_id,
      p_element_link_id            => p_element_link_id,
      p_entry_type                 => 'B',   -- Balance Adjustment entry.
      p_creator_type               => 'B',
      p_input_value_id1            => p_input_value_id1,
      p_input_value_id2            => p_input_value_id2,
      p_input_value_id3            => p_input_value_id3,
      p_input_value_id4            => p_input_value_id4,
      p_input_value_id5            => p_input_value_id5,
      p_input_value_id6            => p_input_value_id6,
      p_input_value_id7            => p_input_value_id7,
      p_input_value_id8            => p_input_value_id8,
      p_input_value_id9            => p_input_value_id9,
      p_input_value_id10           => p_input_value_id10,
      p_input_value_id11           => p_input_value_id11,
      p_input_value_id12           => p_input_value_id12,
      p_input_value_id13           => p_input_value_id13,
      p_input_value_id14           => p_input_value_id14,
      p_input_value_id15           => p_input_value_id15,
      p_entry_value1               => p_entry_value1,
      p_entry_value2               => p_entry_value2,
      p_entry_value3               => p_entry_value3,
      p_entry_value4               => p_entry_value4,
      p_entry_value5               => p_entry_value5,
      p_entry_value6               => p_entry_value6,
      p_entry_value7               => p_entry_value7,
      p_entry_value8               => p_entry_value8,
      p_entry_value9               => p_entry_value9,
      p_entry_value10              => p_entry_value10,
      p_entry_value11              => p_entry_value11,
      p_entry_value12              => p_entry_value12,
      p_entry_value13              => p_entry_value13,
      p_entry_value14              => p_entry_value14,
      p_entry_value15              => p_entry_value15,

      -- Costing information.
      p_cost_allocation_keyflex_id => p_cost_allocation_keyflex_id,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_attribute16                => p_attribute16,
      p_attribute17                => p_attribute17,
      p_attribute18                => p_attribute18,
      p_attribute19                => p_attribute19,
      p_attribute20                => p_attribute20,
      p_effective_start_date       => l_effective_start_date,
      p_effective_end_date         => l_effective_end_date,
      p_element_entry_id           => l_element_entry_id,
      p_object_version_number      => l_object_version_number,
      p_create_warning             => l_create_warning);

   -- calc jur code name
   pay_core_utils.get_leg_context_iv_name
                      ('JURISDICTION_CODE',
                       l_info.legcode,
                       l_jc_name,
                       l_found);
   if (l_found = FALSE) then
     l_jc_name := 'Jurisdiction';
   end if;


   -- set rr sparse leg_rule
   pay_core_utils.get_legislation_rule('RR_SPARSE',
                                       l_info.legcode,
                                       l_rule_mode,
                                       l_found
                                      );
   if (l_found = FALSE) then
     l_rule_mode := 'N';
   end if;

   if upper(l_rule_mode)='Y'
   then
      -- Confirm Enabling Upgrade has been made by customer
      pay_core_utils.get_upgrade_status(l_info.busgrpid,
                               'ENABLE_RR_SPARSE',
                               l_status);

      if upper(l_status)='N'
      then
         l_rule_mode := 'N';
      end if;
   end if;

   if upper(l_rule_mode)='Y'
   then
    l_rr_sparse:=TRUE;
   else
    l_rr_sparse :=FALSE;
   end if;
--
   pay_core_utils.get_upgrade_status(l_info.busgrpid,
                                'RR_SPARSE_JC',
                                l_status);
--
   if upper(l_status)='Y'
   then
    l_rr_sparse_jc :=TRUE;
   else
    l_rr_sparse_jc :=FALSE;
   end if;
--
   -- Get information related to the assignment.
   -- See comments for this function.
   l_info := get_asg_info(l_info
                         ,p_assignment_id
                         ,l_element_entry_id
                         ,p_run_type_id
                         ,p_tax_unit_id
                         ,p_purge_mode
                         );
--
   -- create run result
   pay_run_result_pkg.create_run_result(
                            p_element_entry_id  => l_element_entry_id,
                            p_session_date      => l_info.effdate,
                            p_business_group_id => l_info.busgrpid,
                            p_jc_name           => l_jc_name,
                            p_rr_sparse         => l_rr_sparse,
                            p_rr_sparse_jc      => l_rr_sparse_jc,
                            p_asg_action_id     => l_info.assactid,
                            p_run_result_id     => l_run_result_id);
--

   -- Set the creator information.  Doing this here because
   -- the entry api doesn't allow us to on insert (which seems odd)
   -- and don't see the point of going all out to use the
   -- update API.  May re-address when do 'proper' batch version.
   -- Also, balance_adj_cost_flag is not supported yet by API.
   update pay_element_entries_f pee
   set    pee.creator_id            = l_info.assactid,
          pee.creator_type          = 'B',
          pee.balance_adj_cost_flag = p_balance_adj_cost_flag
   where  pee.element_entry_id      = l_element_entry_id
   and    l_info.effdate between
          pee.effective_start_date and pee.effective_end_date;

   set_lat_balances( p_assignment_id ,
                     p_original_entry_id,
                     l_element_entry_id,
                     l_info.effdate,
                     l_info.busgrpid,
                     l_info.legcode,
                     l_info.assactid,
                     l_info.action_type,
                     l_run_result_id
                    );

   --
   -- Create asg run balances based on the run result.
   --
   pay_balance_pkg.create_rr_asg_balances
     (p_run_result_id    => l_run_result_id
     );

exception
when others then
   rollback to adjust_balance;
   --
   -- Clear the global cache
   --
   purge_batch_info;

   -- Output some final information about the error.
   hr_utility.trace('** exception information **');
   hr_utility.trace('l_info.batchid          : ' || l_info.batchid);
   hr_utility.trace('l_info.effdate          : ' || l_info.effdate);
   hr_utility.trace('l_info.assactid         : ' || l_info.assactid);
   hr_utility.trace('l_info.payid            : ' || l_info.payid);
   hr_utility.trace('l_info.batch_mode       : ' || l_info.batch_mode);
   hr_utility.trace('l_effective_start_date  : ' || l_effective_start_date);
   hr_utility.trace('l_effective_end_date    : ' || l_effective_end_date);
   hr_utility.trace('l_element_entry_id      : ' || l_element_entry_id);
   hr_utility.trace('l_object_version_number : ' || l_object_version_number);

   raise;

end adjust_balance;

/*
 *  Currently has the job of updating the payroll action table
 *  to indicate that the balance adjustments have been processed.
 *  Also performs commit.
 *  Will eventually be the code that actually processes the
 *  balance adjustments.
 */
procedure process_batch
(
   p_batch_id in number
) is
--
   cursor get_rb_asg_actions(p_pact_id number)
   is
   select assignment_action_id
   from   pay_assignment_actions
   where  payroll_action_id = p_pact_id;
   --
   l_info      info_r;
   l_timperid  number;
   l_processed number;
   l_mode      varchar2(30);
   l_proc            varchar2(80):= ' pay_bal_adjust.process_batch';
begin
   --
   -- Issue a savepoint
   --
   savepoint process_batch;

   -- See if batch can be processed.
   l_info := get_batch_info(p_batch_id);

   hr_utility.trace('batchid  : ' || l_info.batchid);
   hr_utility.trace('effdate  : ' || fnd_date.date_to_canonical(l_info.effdate));
   hr_utility.trace('busgrpid : ' || l_info.busgrpid);
   hr_utility.trace('mode     : ' || l_info.batch_mode);

   --
   -- Need to add balance adjustment support for pay_run_balances. 1st for
   -- assignment run balances then for group run balances.
   -- NOTE: While the only commit unit in balance adjustments is done in this
   -- procedure we can do both asg and group balances here. If a commit unit is
   -- ever put earlier in the bal adj process, the support for asg leve run
   -- balances may need moving to the balance adjust procedure(s).
   --
   -- Bug 3354765.
   -- The creation of asg run balances has been moved to be processed
   -- in adjust_balance.

   -- for each_row in get_rb_asg_actions(l_info.batchid) loop
   --  pay_balance_pkg.create_all_asg_balances(each_row.assignment_action_id);
   -- end loop;

   pay_balance_pkg.create_all_group_balances(l_info.batchid);

   -- Obtain the time_period_id for this batch.
   select ptp.time_period_id
   into   l_timperid
   from   per_time_periods ptp
   where  ptp.payroll_id = l_info.payid
   and    l_info.effdate between
          ptp.start_date and ptp.end_date;

   -- Stamp payroll action with the time_period_id and
   -- payroll_id whilst setting the statuses to success.
   update pay_payroll_actions pac
   set    pac.action_status            = 'C',
          pac.action_population_status = 'C',
          pac.time_period_id           = l_timperid
   where  pac.payroll_action_id = p_batch_id;

   -- One item of information.
   select count(*)
   into   l_processed
   from   pay_assignment_actions act
   where  act.payroll_action_id = l_info.batchid
   and    act.action_status     = 'C';

   hr_utility.trace('Asgs processed : ' || l_processed);

   purge_batch_info;  -- any global information shut down.
   --
   -- Only commit if 'STANDARD' processing mode.
   if(l_info.batch_mode = 'STANDARD') then
      hr_utility.trace('STANDARD mode : COMMIT');
      commit;
   end if;

exception
   when others then
     --
     hr_utility.set_location(l_proc, 30);
     --
     rollback to process_batch;
     purge_batch_info;
     raise;
end process_batch;

procedure rerun_batch
(
   p_batch_id in number,
   p_busgrpid in number,
   p_effdate in date,
   p_legcode in varchar2,
   p_assignment_action_id in number
) is
 l_original_entry_id number;
 l_element_entry_id number;
 l_element_link_id number;
 l_assignment_id number;
  l_input_value_id_tbl hr_entry.number_table;
  l_entry_value_tbl    hr_entry.varchar2_table;

   l_run_result_id 	   number;
   l_jc_name 		   varchar2(30);
   l_rr_sparse		   boolean;
   l_rr_sparse_jc          boolean;
   l_rule_mode		   varchar2(30);
   l_status		   varchar2(30);
l_found boolean;
begin

select assignment_id
into l_assignment_id
from pay_assignment_actions
where assignment_action_id=p_assignment_action_id;

select  ee.element_entry_id,
	ee.element_link_id,
	ee.original_entry_id
into    l_element_entry_id,
	l_element_link_id,
	l_original_entry_id
from    pay_element_entries_f ee
where   ee.creator_id = p_assignment_action_id
and     ee.assignment_id = l_assignment_id
and     ee.creator_type='B'
and     ee.entry_type = 'B'
and     p_effdate between ee.effective_start_date and ee.effective_end_date;




   -- calc jur code name
   pay_core_utils.get_leg_context_iv_name
                      ('JURISDICTION_CODE',
                       p_legcode,
                       l_jc_name,
                       l_found);
   if (l_found = FALSE) then
     l_jc_name := 'Jurisdiction';
   end if;


   -- set rr sparse leg_rule
   pay_core_utils.get_legislation_rule('RR_SPARSE',
                                       p_legcode,
                                       l_rule_mode,
                                       l_found
                                      );
   if (l_found = FALSE) then
     l_rule_mode := 'N';
   end if;

   if upper(l_rule_mode)='Y'
   then
      -- Confirm Enabling Upgrade has been made by customer
      pay_core_utils.get_upgrade_status(p_busgrpid,
                               'ENABLE_RR_SPARSE',
                               l_status);

      if upper(l_status)='N'
      then
         l_rule_mode := 'N';
      end if;
   end if;

   if upper(l_rule_mode)='Y'
   then
    l_rr_sparse:=TRUE;
   else
    l_rr_sparse :=FALSE;
   end if;
--
   pay_core_utils.get_upgrade_status(p_busgrpid,
                                'RR_SPARSE_JC',
                                l_status);
--
   if upper(l_status)='Y'
   then
    l_rr_sparse_jc :=TRUE;
   else
    l_rr_sparse_jc :=FALSE;
   end if;
--
   -- create run result
   pay_run_result_pkg.create_run_result(
                            p_element_entry_id  => l_element_entry_id,
                            p_session_date      => p_effdate,
                            p_business_group_id => p_busgrpid,
                            p_jc_name           => l_jc_name,
                            p_rr_sparse         => l_rr_sparse,
                            p_rr_sparse_jc      => l_rr_sparse_jc,
                            p_asg_action_id     => p_assignment_action_id,
                            p_run_result_id     => l_run_result_id);

 set_lat_balances ( l_assignment_id ,
		    l_original_entry_id,
		    l_element_entry_id,
		    p_effdate,
		    p_busgrpid,
		    p_legcode,
		    p_assignment_action_id,
                    'B',
                    l_run_result_id
                  );

  pay_balance_pkg.create_all_asg_balances(p_assignment_action_id);

end rerun_batch;

procedure create_ee
(
   p_ele_type in number,
   p_busgrpid in number,
   p_effdate in date,
   p_legcode in varchar2,
   p_assignment_action_id in number,
   p_assignment_id in number,
   p_entry_id in out nocopy number,
   p_balcostflg in varchar2,
   p_costkflx_id in number
)
is


l_start_date date;
l_end_date date;
l_link_id number;
l_found boolean;

begin

-- see if entry already exists (i.e a rerun )

select element_entry_id
into p_entry_id
from pay_element_entries_f
where  assignment_id=p_assignment_id
and  entry_type='B'
and creator_id=p_assignment_action_id
and p_effdate between effective_start_date and effective_end_date;


exception
when others then
-- get info needed to create ee
l_link_id := hr_entry_api.get_link(p_assignment_id,p_ele_type,p_effdate);

/*
select tp.start_date,tp.end_date
into l_start_date,l_end_date
from  per_time_periods tp,per_all_assignments_f asg
where asg.assignment_id = p_assignment_id
and   asg.payroll_id=tp.payroll_id
and   p_effdate between tp.start_date and tp.end_date
and   p_effdate between asg.effective_start_date and asg.effective_end_date;
*/


l_start_date:=p_effdate;
-- create ee

     hr_entry_api.insert_element_entry
     (
      p_effective_start_date => l_start_date,
      p_effective_end_date   => l_end_date,
      p_element_entry_id     => p_entry_id,
      p_assignment_id        => p_assignment_id,
      p_element_link_id      => l_link_id,
      p_creator_type         => 'B',
      p_entry_type           => 'B',
      p_cost_allocation_keyflex_id =>p_costkflx_id,
      p_creator_id           => p_assignment_action_id);

    update pay_element_entries_f
    set balance_adj_cost_flag = p_balcostflg
    where element_entry_id = p_entry_id;

end create_ee;


procedure get_context(p_ele_type in number,
		p_assignment_id in number,
		p_assignment_action_id in number,
		p_effdate in date,
		p_bus_grp in number,
		p_entry_id in number,
		p_inp_name varchar2,
		p_context_value out nocopy varchar2)
is
begin

 if (p_inp_name = 'PAYROLL_ID') then
    select payroll_id
    into p_context_value
    from per_all_assignments_f
    where assignment_id=p_assignment_id
    and p_effdate between effective_start_date and effective_end_date;
 elsif (p_inp_name = 'ASSIGNMENT_ID') then
	p_context_value := p_assignment_id;
 elsif (p_inp_name = 'ASSIGNMENT_ACTION_ID') then
	p_context_value := p_assignment_action_id;
 elsif (p_inp_name = 'TAX_UNIT_ID') then
    select tax_unit_id
    into p_context_value
    from pay_assignment_actions
    where assignment_action_id = p_assignment_action_id;
 elsif (p_inp_name = 'ELEMENT_ENTRY_ID') then
	p_context_value := p_entry_id;
 elsif (p_inp_name  = 'ELEMENT_TYPE_ID') then
	p_context_value := p_ele_type;
 elsif (p_inp_name = 'BUSINESS_GROUP_ID') then
	p_context_value := p_bus_grp;
 elsif (p_inp_name = 'PAYROLL_ACTION_ID') then
    select payroll_action_id
    into p_context_value
    from pay_assignment_actions
    where assignment_action_id =p_assignment_action_id;
 elsif (p_inp_name = 'DATE_EARNED') then
	p_context_value := fnd_date.date_to_canonical(p_effdate);
 end if;

end get_context;

procedure run_formula(   p_ele_type in number,
   p_busgrpid in number,
   p_effdate in date,
   p_legcode in varchar2,
   p_assignment_action_id in number,
   p_assignment_id in number,
   p_entry_id in number,
   p_run_result_id in number)
is
  cursor form_outputs  (p_ele_type number,p_effdate date,
                          p_formula_id number,p_out_name varchar2)
  is
     select input_value_id,frr.result_rule_type,frr.severity_level
     from pay_formula_result_rules_f frr,
	  pay_status_processing_rules_f spr
     where spr.element_type_id= p_ele_type
     and   spr.formula_id = p_formula_id
     and   spr.status_processing_rule_id  = frr.status_processing_rule_id
     and   upper(frr.result_name) = upper(p_out_name)
     and   p_effdate between spr.effective_start_date and spr.effective_end_date
     and   p_effdate between frr.effective_start_date and frr.effective_end_date;

   v_inputs           ff_exec.inputs_t;
   v_outputs          ff_exec.outputs_t;
   l_formula_id       number;
   l_formula_name     varchar2(80);
   inp_name 	      varchar2(240);
   out_name 	      varchar2(240);
   out_value 	      varchar2(255);
   inp_value	      varchar2(240);
   l_jc_name               varchar2(30);
   l_rr_sparse             boolean;
   l_rr_sparse_jc          boolean;
   l_rule_mode		   varchar2(30);
   l_status		   varchar2(30);
l_found boolean;



begin

   -- calc jur code name
   pay_core_utils.get_leg_context_iv_name
                      ('JURISDICTION_CODE',
                       p_legcode,
                       l_jc_name,
                       l_found);
   if (l_found = FALSE) then
     l_jc_name := 'Jurisdiction';
   end if;

   -- set rr sparse leg_rule
   pay_core_utils.get_legislation_rule('RR_SPARSE',
                                       p_legcode,
                                       l_rule_mode,
                                       l_found
                                      );
   if (l_found = FALSE) then
     l_rule_mode := 'N';
   end if;

   if upper(l_rule_mode)='Y'
   then
      -- Confirm Enabling Upgrade has been made by customer
      pay_core_utils.get_upgrade_status(p_busgrpid,
                               'ENABLE_RR_SPARSE',
                               l_status);

      if upper(l_status)='N'
      then
         l_rule_mode := 'N';
      end if;
   end if;

   if upper(l_rule_mode)='Y'
   then
    l_rr_sparse:=TRUE;
   else
    l_rr_sparse :=FALSE;
   end if;
--
   pay_core_utils.get_upgrade_status(p_busgrpid,
                               'RR_SPARSE_JC',
                               l_status);
--
   if upper(l_status)='Y'
   then
    l_rr_sparse_jc :=TRUE;
   else
    l_rr_sparse_jc :=FALSE;
   end if;
--
-- get formula id
select formula_id
into l_formula_id
from pay_status_processing_rules_f
where element_type_id =p_ele_type
and  processing_rule='B'
and  p_effdate between effective_start_date and effective_end_date;

   hr_utility.trace('l_formula_id : ' || l_formula_id);

-- init formula
ff_exec.init_formula(l_formula_id, p_effdate, v_inputs, v_outputs);

-- set inputs
   if(v_inputs.count >= 1) then
      --
      -- Set up the inputs and contexts to formula.
      for i in v_inputs.first..v_inputs.last loop
	inp_name:=v_inputs(i).name;
	-- see if equivalent entry value
	hr_utility.trace('input name : ' || inp_name);

	begin
	select ee.screen_entry_value
	into inp_value
	from pay_element_entry_values_f ee,
	     pay_input_values_f iv
	where ee.element_entry_id=p_entry_id
	and  ee.input_value_id=iv.input_value_id
	and upper(iv.name)=upper(inp_name)
	and p_effdate between  iv.effective_start_date and iv.effective_end_date
	and p_effdate between  ee.effective_start_date and ee.effective_end_date;

	v_inputs(i).value:=inp_value;
	hr_utility.trace('input value : ' || inp_value);

	exception
	  when no_data_found then
	  -- see if context
	  get_context(p_ele_type, p_assignment_id,
		p_assignment_action_id, p_effdate, p_busgrpid ,
		p_entry_id,inp_name,v_inputs(i).value);
	end;

      end loop;
   end if;


-- run formula
   ff_exec.run_formula(v_inputs, v_outputs);


-- process results
   for i in v_outputs.first..v_outputs.last loop

    out_name:=v_outputs(i).name;
    out_value:=v_outputs(i).value;

    hr_utility.trace('output name : ' || out_name);
    hr_utility.trace('output value : ' || out_value);

    for outputs in form_outputs(p_ele_type,p_effdate,l_formula_id,out_name)
    loop
     hr_utility.trace('input_value_id: ' || to_char(outputs.input_value_id));
     hr_utility.trace('result_rule_type: ' || outputs.result_rule_type);
     hr_utility.trace('severity level: ' || outputs.severity_level);


     if (outputs.result_rule_type='M' and out_value is not NULL)
     then
--
        /* Message Result */
--
      pay_core_utils.push_message(801,NULL,out_value,outputs.severity_level);
      if (outputs.severity_level='F')
      then
       -- error asgnment
         seLect formula_name
         into l_formula_name
         from ff_formulas_f
         where formula_id = l_formula_id
         and p_effdate between effective_start_date and effective_end_date;

         hr_utility.set_message(801, 'HR_51120_HRPROC_ERR_OCC_ON_FML');
         hr_utility.set_message_token('FMLANAME',l_formula_name);
         hr_utility.raise_error;
      end if;
--
     elsif (outputs.result_rule_type = 'D' and out_value is not null ) then
--
        /* Direct Result */
        pay_run_result_pkg.maintain_rr_value(
                                  p_run_result_id       => p_run_result_id,
                                  p_session_date        => p_effdate,
                                  p_input_value_id      => outputs.input_value_id,
                                  p_value               => out_value,
                                  p_formula_result_flag => 'Y',
                                  p_jc_name             => l_jc_name,
                                  p_rr_sparse           => l_rr_sparse,
                                  p_rr_sparse_jc        => l_rr_sparse_jc,
                                  p_mode                => 'DIRECT'
                                );
--
     elsif (outputs.result_rule_type = 'I' and out_value is not null ) then
--
        /* Indirect Result */
--
        declare
          l_ind_ele_type_id pay_input_values_f.element_type_id%type;
          l_rr_id           pay_run_results.run_result_id%type;
        begin
--
           select element_type_id
             into l_ind_ele_type_id
             from pay_input_values_f
            where input_value_id = outputs.input_value_id
              and p_effdate between effective_start_date
                                and effective_end_date;
--
           begin
--
             select prr.run_result_id
               into l_rr_id
               from pay_run_results prr
              where element_type_id = l_ind_ele_type_id
                and source_id = p_entry_id
                and source_type = 'I'
                and assignment_action_id = p_assignment_action_id;
--
              pay_run_result_pkg.maintain_rr_value(
                                  p_run_result_id       => l_rr_id,
                                  p_session_date        => p_effdate,
                                  p_input_value_id      => outputs.input_value_id,
                                  p_value               => out_value,
                                  p_formula_result_flag => 'Y',
                                  p_jc_name             => l_jc_name,
                                  p_rr_sparse           => l_rr_sparse,
                                  p_rr_sparse_jc        => l_rr_sparse_jc,
                                  p_mode                => 'INDIRECT'
                                );
--
           exception
               when no_data_found then
--
                   pay_run_result_pkg.create_indirect_rr(
                            p_element_type_id   => l_ind_ele_type_id,
                            p_run_result_id     => p_run_result_id,
                            p_session_date      => p_effdate,
                            p_business_group_id => p_busgrpid,
                            p_jc_name           => l_jc_name,
                            p_rr_sparse         => l_rr_sparse,
                            p_rr_sparse_jc      => l_rr_sparse_jc,
                            p_asg_action_id     => p_assignment_action_id,
                            p_ind_run_result_id => l_rr_id
                           );
--
                   pay_run_result_pkg.maintain_rr_value(
                                  p_run_result_id       => l_rr_id,
                                  p_session_date        => p_effdate,
                                  p_input_value_id      => outputs.input_value_id,
                                  p_value               => out_value,
                                  p_formula_result_flag => 'Y',
                                  p_jc_name             => l_jc_name,
                                  p_rr_sparse           => l_rr_sparse,
                                  p_rr_sparse_jc        => l_rr_sparse_jc,
                                  p_mode                => 'INDIRECT'
                                );
--
           end;
        end;
--
     end if;
    end loop;
   end loop;

end run_formula;

procedure process_bal_adj
(
   p_ele_type in number,
   p_busgrpid in number,
   p_effdate in date,
   p_legcode in varchar2,
   p_assignment_action_id in number,
   p_assignment_id in number,
   p_balcostflg in varchar2,
   p_costkflx_id in number
)
is
 l_entry_id number;
   l_jc_name               varchar2(30);
   l_rr_sparse             boolean;
   l_rr_sparse_jc          boolean;
   l_rule_mode             varchar2(30);
   l_status                varchar2(30);
   l_found                 boolean;
   l_run_result_id         pay_run_results.run_result_id%type;
   --
   -- cursor to retrieve the generated run results
   --
   cursor csr_run_results(p_assact_id  number
                         ,p_eentry_id  number
                         )
   is
     select rr.run_result_id
     from   pay_run_results rr
     where
         rr.assignment_action_id = p_assact_id
     and rr.source_id            = p_eentry_id
     and rr.source_type in ('E', 'I')
     ;

begin


-- create ele_entry
  create_ee(p_ele_type,p_busgrpid,p_effdate,p_legcode,p_assignment_action_id,p_assignment_id,l_entry_id,p_balcostflg,p_costkflx_id);
   hr_utility.trace('l_entry_id : ' || l_entry_id);

   -- calc jur code name
   pay_core_utils.get_leg_context_iv_name
                      ('JURISDICTION_CODE',
                       p_legcode,
                       l_jc_name,
                       l_found);
   if (l_found = FALSE) then
     l_jc_name := 'Jurisdiction';
   end if;


   -- set rr sparse leg_rule
   pay_core_utils.get_legislation_rule('RR_SPARSE',
                                       p_legcode,
                                       l_rule_mode,
                                       l_found
                                      );
   if (l_found = FALSE) then
     l_rule_mode := 'N';
   end if;

   if upper(l_rule_mode)='Y'
   then
      -- Confirm Enabling Upgrade has been made by customer
      pay_core_utils.get_upgrade_status(p_busgrpid,
                               'ENABLE_RR_SPARSE',
                               l_status);

      if upper(l_status)='N'
      then
         l_rule_mode := 'N';
      end if;
   end if;

   if upper(l_rule_mode)='Y'
   then
    l_rr_sparse:=TRUE;
   else
    l_rr_sparse :=FALSE;
   end if;
--
   pay_core_utils.get_upgrade_status(p_busgrpid,
                                'RR_SPARSE_JC',
                                l_status);
--
   if upper(l_status)='Y'
   then
    l_rr_sparse_jc :=TRUE;
   else
    l_rr_sparse_jc :=FALSE;
   end if;
--
   -- create run result
   pay_run_result_pkg.create_run_result(
                            p_element_entry_id  => l_entry_id,
                            p_session_date      => p_effdate,
                            p_business_group_id => p_busgrpid,
                            p_jc_name           => l_jc_name,
                            p_rr_sparse         => l_rr_sparse,
                            p_rr_sparse_jc      => l_rr_sparse_jc,
                            p_asg_action_id     => p_assignment_action_id,
                            p_run_result_id     => l_run_result_id);
--
--run formula
  run_formula(p_ele_type,
              p_busgrpid,
              p_effdate,
              p_legcode,
              p_assignment_action_id,
              p_assignment_id,
              l_entry_id,
              l_run_result_id);

  --   balnces
  for rr_rec in csr_run_results
                  (p_assignment_action_id
                  ,l_entry_id)
  loop
    set_lat_balances
      (p_assignment_id     => p_assignment_id
      ,p_original_entry_id => null
      ,p_element_entry_id  => l_entry_id
      ,p_effdate           => p_effdate
      ,p_busgrpid          => p_busgrpid
      ,p_legcode           => p_legcode
      ,p_assactid          => p_assignment_action_id
      ,p_action_type       => 'B'
      ,p_run_result_id     => rr_rec.run_result_id
      );
  end loop;

  --
  -- Bug 3211015. Added the call to create_all_asg_balances instead of
  -- calling it in set_lat_balances.
  --
  pay_balance_pkg.create_all_asg_balances(p_assignment_action_id);

end process_bal_adj;

end pay_bal_adjust;

/
