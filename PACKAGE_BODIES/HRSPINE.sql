--------------------------------------------------------
--  DDL for Package Body HRSPINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRSPINE" as
/* $Header: pespines.pkb 120.2.12010000.2 2008/08/06 09:38:02 ubhat ship $ */
--
--
--Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pespines.pkb
   ***************************************************************************
   ********** SEE PROCEDURE SPINE FOR NEW FULL PROCESS DESCRIPTION ***********
   ***************************************************************************

   DESCRIPTION
      Procedure for the spinal automatic incrementing process.
      Its job is to move each entitled employee up to the
      next point on his pay spine (thus increasing his salary), unless
      he has reached the maximum point allowed on his grade or
      assignment.  An employee is 'entitled' to be incremented if he
      is on the input parent spine, and the increment flag on his
      placement is 'Y'.  Additionally he may have to satisfy partial
      group matching on his assignment flex.
--
   MODULE DESCRIPTION
--
      IF concatenated segments specified
          LOOP for the number of segments
              extract and align segments
          END LOOP
      END IF
      LOOP for each assignment
--
        FETCH Cursor - Details of spinal placements entitled to be incremented
            including the next step each will be set to.
            - Note this is not neccessarily the next sequence number,
              but the step with the lowest sequence number for the spine
              which is greater than the current step's sequence.
--
          UPDATE Placement to end on P_Effective_Run_Date
--
          INSERT New placement starting on P_Effective_Run_Date until the end
                 of time.  Has same values as the curent placement.
      END LOOP
--
  NOTES
     adapted from an earlier release of a 'C' program for spinal incrementing,
     first written by AMcI.
     This PL/SQL procedure is called by the run report screen (SRS).  The
     group keyflex is passed to this procedure as a concatenated string, (or
     null when no group keyflex is specified).  When the concatenated string
     is null, no group partial matching is performed and all valid employees
     are incremented.
     When a People group keyflex has been specified, the procedure has to first
     separate the concatenated string into the individual segments.  A further
     complication is that the display order of the segments as passed to
     this procedure may be a different order to the way it is stored on the
     people group table.  The segments are re-aligned to match the segments
     on the people group table before the partial matching is performed.
--
  MODIFIED (DD-MON-YYYY)
     mwcallag   17-JUN-1993 - created.
     rfine      23-NOV-1994 - Suppressed index on business_group_id
     amills     05-DEC-1995 - Changed date format to DDMMYYYY for
                              translation.
     dkerr	14-MAR-1996 - 349633 - Removed hard-coded month names
     jrhodes    18-FEB-1997 - 626703 - Added Application_ID and ID_Flex_Code
                                       to query on FND_ID_FLEX_STRUCTURES
                                       and FND_ID_FLEX_SEGMENTS
     stlocke	13-JUN-2001 - Updated the process so that it calls the api
			      rather doing the dml in this package.
			      The process now also passes the increment_number,
			      and performs processing to allow reporting.
     stlocke    12-DEC-2001 - Added additional params and processing to allow
			      the user to specify a business rule to increment
			      by such as employee's date of birth.

rem Change List
rem ===========
rem
rem Version Date        Author         Comment
rem -------+-----------+--------------+----------------------------------------
rem 115.39  13-MAR-2002 stlocke        Changed main select cursors so as to remove
rem				       per_qualifications and hr_soft_coding_keyflex
rem				       tables as if no data in tables then cursor
rem				       will return no rows.
rem 115.40  14-MAR-2002 stlocke	       Commented in commit and exit
rem 115.41  25-APR-2002 stlocke	       Added functions used for employee increment
rem				       results report.
rem 115.42  30-APR-2002 stlocke        Added code in increment available to see
rem				       if the special ceiling has been set, if so
rem				       the set grade ceiling to same value.
rem 115.43  10-MAY-2002 stlocke        Fixed issues in employee increment results
rem				       functions for returning last values where
rem				       grade scale has changed but there has been an
rem				       update return null as values for old.
rem 115.44  14-MAY-2002 stlocke	       Updated so that id grade scale ceiling is step
rem				       assignment is on and the special ceiling is
rem				       higher, process will increment assignment.
rem 115.45  17-MAY-2002 stlocke        Added full details on each section of
rem                                    the increment process
rem 115.47  06-JUN-2002 stlocke	       Completed infile documentation.
rem 115.49  08-APR-2003 vbanner        Added error handling.
rem                                    Bug 2444703.
rem 115.50  04-JUL-2003 vanantha       Bug 2999551.
rem				       Modified cursor csr_assignment_business_rule
rem 				       to handle 'leapyear' problem
rem 115.51  15-JUN-2005 bshukla        Bug 4432200 - Removed hard coding of
rem                                    schema 'psp'
rem 115.53  12-May-2008 brsinha        Bug 6969602. Changed cursor csr_assignment_business_rule
rem				       in the procudre spine.
rem ==========================================================================
*/

/* ------------------------------------------------------------------- --
-- Function to return the spinal point that was updated		       --
-- ------------------------------------------------------------------- */

Function func_old_spinal_point
  (p_placement_id		in number
  ,p_effective_start_date	in date
  ,p_step_id			in number
  ,p_grade_rate			in number) return varchar2 as

Cursor csr_old_spinal_point is
select substr(psp1.spinal_point,1,20)
from  per_spinal_point_placements_f spp1,
      per_spinal_point_placements_f spp,
      per_spinal_points             psp1,
      per_spinal_point_steps_f      sps1,
      per_spinal_point_steps_f      sps2
      --pay_grade_rules_f             pgr2
where spp1.step_id                 <> p_step_id -- 343
and   spp1.effective_end_date       = p_effective_start_date -1
and   spp.effective_start_date	    = p_effective_start_date
and   spp1.placement_id		        = p_placement_id
and   psp1.parent_spine_id          = spp1.parent_spine_id
and   spp1.step_id                  = sps1.step_id
and   spp.step_id                   = sps2.step_id
and   sps1.grade_spine_id           = sps2.grade_spine_id
and   spp.placement_id		        = spp1.placement_id
and   sps1.spinal_point_id          = psp1.spinal_point_id;
--
l_old_spinal_point varchar2(20);
--
begin
--
open csr_old_spinal_point;
fetch csr_old_spinal_point into l_old_spinal_point;
if csr_old_spinal_point%notfound then

  -- Need to return a message if there is no previous spinal point

  l_old_spinal_point := 'Updated First Record';

end if;

close csr_old_spinal_point;

  return l_old_spinal_point;

end func_old_spinal_point;

/* ------------------------------------------------------------------- --
-- Function to return the previous  spinal value                       --
-- ------------------------------------------------------------------- */

Function func_old_spinal_value
  (p_placement_id               in number
  ,p_effective_start_date       in date
  ,p_step_id                    in number
  ,p_grade_rate                 in number) return number  as

Cursor csr_old_spinal_value is
select pgr2.value
from  per_spinal_point_placements_f spp1,
      per_spinal_point_placements_f spp,
      per_spinal_points             psp1,
      per_spinal_point_steps_f      sps1,
      pay_grade_rules_f             pgr2,
      per_spinal_point_steps_f      sps2
where p_step_id                     <> spp1.step_id
and   spp1.effective_end_date       = p_effective_start_date -1
and   spp.effective_start_date      = p_effective_start_date
and   spp1.placement_id             = p_placement_id
and   psp1.parent_spine_id          = spp1.parent_spine_id
and   spp1.step_id                  = sps1.step_id
and   spp.step_id		    = sps2.step_id
and   sps1.grade_spine_id	    = sps2.grade_spine_id
and   spp.placement_id              = spp1.placement_id
and   sps1.spinal_point_id          = psp1.spinal_point_id
and   pgr2.grade_or_spinal_point_id = sps1.spinal_point_id
and   pgr2.rate_id                  = (select min(rate_id)
                                          from pay_grade_rules_f pgr4
                                          where pgr4.grade_or_spinal_point_id = pgr2.grade_or_spinal_point_id
                                          and (to_number(p_grade_rate) = pgr4.rate_id
                                            or to_number(p_grade_rate) is null));

l_old_spinal_value number;

begin

open csr_old_spinal_value;
fetch csr_old_spinal_value into l_old_spinal_value;
if csr_old_spinal_value%notfound then

  -- If this is the first spinal point of the current grade then return a value of zero

  l_old_spinal_value := 0;

end if;

close csr_old_spinal_value;

  return l_old_spinal_value;

end func_old_spinal_value;

/* ------------------------------------------------------------------- */
-- Function to check that the record was an increment		       --
-- ------------------------------------------------------------------- --
--								       --
-- This process works by opening each cursor stated below to see if    --
-- they can return a record. If they can then the record should not be --
-- displayed for the reason stated above each cursor.	 	       --
-- 								       --
/* ------------------------------------------------------------------- */

Function func_increment
  (p_placement_id		in number
  ,p_effective_start_date	in date
  ,p_step_id			in number
  ,p_grade_spine_id		in number) return number as

-- Local variables set for each cursor, set to -1 as this can never be a
-- placement id

l_increment1 number := -1;
l_increment2 number := -1;
l_increment3 number := -1;
l_increment4 number := -1;

/* *** First Ever SPP Record Catch *** */

Cursor csr_increment1 is
select spp.placement_id
from   per_spinal_point_placements_f spp
where  spp.object_version_number = 1
and    spp.placement_id         = p_placement_id
and    spp.effective_start_date = p_effective_start_date;

/* *** No step update in record, so no grade increment */

Cursor csr_increment2 is
select spp.placement_id
from   per_spinal_point_placements_f spp,
       per_spinal_point_steps_f sps
where  spp.step_id	      = p_step_id
and    spp.placement_id       = p_placement_id
and    spp.effective_end_date = p_effective_start_date -1
and    sps.grade_spine_id     = p_grade_spine_id
and    sps.step_id            = spp.step_id;

/* *** Step was auto created when grade scale changed on assignment form *** */

Cursor csr_increment3 is
select spp.placement_id
from   per_spinal_point_placements_f spp,
       per_spinal_point_steps sps
where  spp.placement_id         = p_placement_id
and    spp.effective_start_date = p_effective_start_date
and    sps.grade_spine_id      <> p_grade_spine_id
and    spp.last_updated_by      = -1
and    spp.reason               = '';

/* *** First Spinal Point Of Grade Scale *** */

Cursor csr_increment4 is
select spp.placement_id
from   per_spinal_point_placements_f spp,
       per_spinal_point_steps_f sps,
       per_spinal_points psp
where  spp.placement_id         = p_placement_id
and    spp.effective_start_date = p_effective_start_date
and    spp.step_id              = p_step_id
and    sps.step_id		= spp.step_id
and    sps.spinal_point_id      = psp.spinal_point_id
and    psp.spinal_point_id       = (select psp1.spinal_point_id
				    from per_spinal_points psp1
				    where psp1.parent_spine_id = spp.parent_spine_id
				    and  psp1.sequence = (select min(sequence)
				                         from per_spinal_points psp2,
							 per_grade_spines_f pgs
							 where psp2.parent_spine_id = pgs.parent_spine_id
							 and pgs.grade_spine_id = p_grade_spine_id
							 and psp2.parent_spine_id = psp1.parent_spine_id));

-- Cursor to return all placement id's where they
-- have not been found by any of the previous cursors.

Cursor csr_all_placements is
select distinct spp.placement_id
from   per_spinal_point_placements_f spp,
       per_spinal_point_steps_f sps
where  spp.placement_id         = p_placement_id
and    spp.effective_start_date = p_effective_start_date
and    spp.step_id              = sps.step_id
and    spp.step_id              = p_step_id
and    (spp.placement_id        <> l_increment1
    and spp.placement_id        <> l_increment2
    and spp.placement_id        <> l_increment3
    and spp.placement_id        <> l_increment4);

l_dummy number := -1;
l_function varchar2(30) := 'Increment Function';

begin

hr_utility.set_location(l_function,10);
hr_utility.set_location('p_placement_id - '||p_placement_id,50);
hr_utility.set_location('p_effective_start_date - '||p_effective_start_date,50);
hr_utility.set_location('p_step_id - '||p_step_id,50);
hr_utility.set_location('p_grade_spine_id - '||p_grade_spine_id,50);

open csr_increment1;
fetch csr_increment1 into l_increment1;
close csr_increment1;

hr_utility.set_location('l_increment1 (1st SPP Record) - '||l_increment1,60);

open csr_increment2;
fetch csr_increment2 into l_increment2;
close csr_increment2;

hr_utility.set_location('l_increment2 (No Step Change) - '||l_increment2,60);

open csr_increment3;
fetch csr_increment3 into l_increment3;
close csr_increment3;

hr_utility.set_location('l_increment3 (Grade Scale Auto Change) - '||l_increment3,60);

open csr_increment4;
fetch csr_increment4 into l_increment4;
close csr_increment4;

hr_utility.set_location('l_increment4 (1st Grade Spinal Point) - '||l_increment4,60);

open csr_all_placements;
fetch csr_all_placements into l_dummy;
close csr_all_placements;

hr_utility.set_location('l_dummy (Placement ID to be returned) - '||l_dummy,70);

hr_utility.set_location('End of '||l_function,80);

return l_dummy;

end func_increment;

/* ------------------------------------------------------------------- */
-- Procedure to check if the busines rule is being passed.             --
-- If it is to test if the effective date is between the business rule --
-- date from and the business rule date to.                            --
--								       --
-- Processing logic of procedure - 				       --
-- 								       --
-- 1. Check p_business_rule parameter set, if not then check that none --
--    of the other business rule parameters are being passed.	       --
-- 2. Check that p_business_rule is a valid business rule	       --
-- 3. Check that both the business rule dates fram and to are set      --
-- 4. Check that the date_from parameter is not grater than the        --
--    date_to parameter.					       --
-- 5. Check that the gap between date_from and date_to is not greater  --
--    than 1 year.						       --
-- 6. Check the dependant_date is valid.			       --
-- 7. Check that the effectvie date is between date_from and date_to.  --
--								       --
/* ------------------------------------------------------------------- */

Procedure business_rule_check
  (p_effective_date             in date
  ,p_business_rule              in varchar2
  ,p_br_date_from               in date
  ,p_br_date_to                 in date
  ,p_year_from			in number
  ,p_year_to			in number
  ,p_dependant_date             in varchar2
  ,p_br_flag                    out nocopy boolean) is

  l_br_flag      boolean;
  l_br_date_from date;
  l_br_date_to   date;
  l_package	 varchar2(30) := 'Business Rule Check';

begin

hr_utility.set_location(l_package,1);
hr_utility.set_location('p_business_rule - '||p_business_rule,1);
hr_utility.set_location('p_br_date_from - '||p_br_date_from,1);
hr_utility.set_location('p_br_date_to - '||p_br_date_to,1);
hr_utility.set_location('p_dependant_date - '||p_dependant_date,1);

--
-- Check if the business rule has not been set that all other business rule
-- only parameters are null, else raise an error.
--

if p_business_rule is null then
   if p_br_date_from is not null
   or p_br_date_to is not null
   or p_dependant_date is not null then

    fnd_message.set_name('PER', 'HR_289506_SPP_BR_NULL');
    hr_utility.raise_error;

   end if;

end if;

--
-- Check that the business rule and all dates etc are valid
--

l_br_date_from := p_br_date_from;
l_br_date_to   := p_br_date_to;

if p_business_rule is not null then

  --
  -- Check the business rule is valid
  --
  -- Currently business rules available are:
  --
  --    Anniversary Of Joining (AOJ)
  --    Date Of Birth	       (DOB)
  --    Adjusted Service Date  (ASD)
  --    Latest Hire Date       (LHD)
  --

    if p_business_rule not IN ('AOJ','DOB','ASD','LHD') then

	fnd_message.set_name('PER', 'HR_289507_SPP_BR_INVALID');
        hr_utility.raise_error;

    end if;

  --
  -- Check to see what dates have been passed, if they are both null then set
  -- them to the effective date, so that the business rule check succeeds.
  --
  if p_br_date_from is null
    or p_br_date_to is null then

      fnd_message.set_name('PER', 'HR_289510_SPP_BR_DATE_NULL');
      hr_utility.raise_error;

  elsif nvl(l_br_date_to,l_br_date_from) < nvl(l_br_date_from,l_br_date_to) then

    -- The business rule date from is greater than the date to
    -- so raise an error accordingly

    fnd_message.set_name('PER', 'HR_289500_SPP_BR_DATE');
    hr_utility.raise_error;

 elsif nvl(l_br_date_to,l_br_date_from) >= nvl(l_br_date_from,l_br_date_to) then

    -- The business rule dates are valid, now check that the gap between is not
    -- greater than 1 year, coded to include problems with leap year.

    if months_between (l_br_date_to,l_br_date_from) >= 12 then

      -- Gap is greater than one year, so raise error

      fnd_message.set_name('PER', 'HR_289501_SPP_BR_YEAR_GREATER');
      hr_utility.raise_error;

    end if;

  end if;

  --
  -- Check that the dependant date is set
  --
  if p_dependant_date is null then

    -- raise error as process doesn't know what date to increment assignments on

     fnd_message.set_name('PER', 'HR_289502_SPP_DEPEND_DATE');
     hr_utility.raise_error;

  end if;

  --
  -- Check that the effective date is between the date from and the date to
  --

  if (p_effective_date <= nvl(p_br_date_to,p_effective_date)
    and p_effective_date >= nvl(p_br_date_from,p_effective_date)) then

    l_br_flag := true;

  else

    --
    -- Raise error due to effective date not being between business rule dates
    --

    fnd_message.set_name('PER', 'HR_289503_SPP_EFF_BR_DATE');
    hr_utility.raise_error;

  end if;

  --
  -- Check that the year from year is less than the year to year
  --

  if nvl(p_year_from,p_year_to) > nvl(p_year_to,p_year_from) then

    --
    -- Raise error due to year from being greater than the year to
    --

    fnd_message.set_name('PER', 'HR_289504_SPP_BR_YEAR_FROM_TO');
    hr_utility.raise_error;

  end if;

else

  -- Business rule is not being used

  l_br_flag := false;

end if;

  p_br_flag := l_br_flag;

end business_rule_check;

/* -------------------------------------------------------------------- */
-- Procedure to update the spinal point and then to generate the 	--
-- relevant reports, depending on whether the process complete 		--
-- successfully								--
--									--
-- Processing logic of procedure - 					--
--									--
-- 1. Set local update and exception variable from the passed values	--
-- 2. If l_update = Y then						--
--    a. Get the next sequence unitl the increment_number = l_count of  --
--       the sequence fetch.						--
--    b. Check if the new spinal_point is equal to either the grade max --
--       point or the ceiling set.					--
--    c. Get the step_id for the new point.				--
--    d. Call to the update_spp process to update the table data.	--
--    e. Call to the process to populate the what if report to report	--
--       on the assignments that have been updated.			--
--    End if								--
-- 3. If l_exception_report1 = Y then					--
--    a. Call to the process to populate the exception report to report --
--       on assignments that failed to be incremented or that were	--
--       incremented but hit some kind of ceiling whilst being updated.	--
--    End if								--
/* -------------------------------------------------------------------- */

   Procedure update_report_exception
     (p_datetrack_mode                  in varchar2
     ,p_effective_date                  in date
     ,p_placement_id                    in number
     ,p_object_version_number           in number
     ,p_increment_number                in number
     ,p_reason                          in varchar2
     ,p_effective_start_date            in date
     ,p_assignment_id                   in number
     ,p_parent_spine_id                 in number
     ,p_spinal_point_id                 in number
     ,p_rate_id                         in number
     ,p_lc_step_id                      in number
     ,p_exception_report1               in varchar2
     ,p_end_date                        in date
     ,p_orig_increment_number           in number
     ,p_sequence_number                 in number
     ,p_grade_spine_id                  in number
     ,p_update                          in varchar2
     ,p_max_special_sequence_number     in number
     ,p_max_special_spinal_point        in number
     ,p_max_sequence_number             in number
     ,p_max_spinal_point                in number) is

  l_next_sequence_number        number;
  l_next_spinal_point           number;
  l_exception_report1           varchar2(2);
  l_update                      varchar2(2);
  l_zero                        number :=0;      -- constant zero
  l_new_step_id                 number;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_increment                   number;
  l_object_version_number       number;

  --
  -- cursor to get the next sequence number
  -- and the next spinal point for the grade
  --
    cursor csr_next_sequence(p_sequence             number,
                             p_grade_spine_id       number,
                             p_effective_date       date) is
    select sequence,spinal_point_id
    from per_spinal_point_steps_f
    where sequence > p_sequence
    and grade_spine_id = p_grade_spine_id
    and p_effective_date between effective_start_date
                             and effective_end_date
    order by sequence;
--
begin
--
  l_update := p_update;
  l_exception_report1 := p_exception_report1;
  --
  -- ------------------------------------------------------------------
  -- gets the sequence number and the next spinal point id
  -- of the grade and loops until l_zero = increment by number
  -- ------------------------------------------------------------------
     if l_update = 'Y' then

        open csr_next_sequence(p_sequence_number,
                               p_grade_spine_id,
                               p_effective_date);
        loop

          FETCH csr_next_sequence into l_next_sequence_number,
                                       l_next_spinal_point;

          if csr_next_sequence%notfound then
            hr_utility.set_location('MAX POINT REACHED!',20);
              l_update := 'N';
              l_exception_report1 := 'Y';
            exit;

          else
            hr_utility.set_location('FOUND',21);
              l_zero := l_zero+1;
              l_update := 'Y';

              if p_increment_number = l_zero then
                exit;
              end if;
          end if;
        end loop;
        close csr_next_sequence;

        l_zero := 0;
  --
  -- ------------------------------------------------------------------
  -- Check if the new spinal_point_id is equal to either of the max
  -- spinal point id's. If so report after update
  -- ------------------------------------------------------------------
  --
     if (l_next_sequence_number = p_max_sequence_number
     and l_next_spinal_point = p_max_spinal_point)
     or (l_next_sequence_number = p_max_special_sequence_number
     and l_next_spinal_point = p_max_special_spinal_point)
     then
        l_exception_report1 := 'Y';
     end if;
  --
  -- ------------------------------------------------------------------
  -- select statement to get new step id for assignment
  -- ------------------------------------------------------------------
  --
  BEGIN
     hr_utility.set_location('get step id',1313);
     hr_utility.set_location('p_grade_spine_id '||p_grade_spine_id,1313);
     hr_utility.set_location('l_next_spinal_point '||l_next_spinal_point,1313);
     hr_utility.set_location('l_next_sequence_number '
                             ||l_next_sequence_number,1313);
     select step_id
     into l_new_step_id
     from per_spinal_point_steps_f
     where sequence = l_next_sequence_number
     and grade_spine_id = p_grade_spine_id
     and spinal_point_id = l_next_spinal_point;
  EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      hr_utility.set_location('NO_DATA_FOUND',1314);
      hr_utility.set_location('step id',1314);
      hr_utility.set_location('not found for l_next_sequence_number'
                              ||l_next_sequence_number, 1314);
      hr_utility.set_location('p_grade_spine_id '||p_grade_spine_id,1314);
      hr_utility.set_location('l_next_spinal_point '||l_next_spinal_point,1314);
   END;
  --
  -- Now update all the records using the api
  --
     l_effective_start_date := p_effective_start_date;
     l_effective_end_date := p_end_date;
     l_object_version_number := p_object_version_number;
     --
     --
       hr_sp_placement_api.update_spp
         (p_datetrack_mode             => p_datetrack_mode
         ,p_effective_date             => P_Effective_Date
         ,p_placement_id               => p_placement_id
         ,p_object_version_number      => l_object_version_number
         ,p_step_id                    => l_new_step_id
         ,p_increment_number           => p_increment_number
         ,p_reason                     => p_reason
         ,p_effective_start_date       => l_effective_start_date
         ,p_effective_end_date         => l_effective_end_date
         );
         --
     hr_utility.set_location ('Before HR_SPP_EXCEPTION_DATA.populate_spp_table',101);
     hr_utility.set_location ('l_exception_report_1 = '||l_exception_report1,151);
     --
     ----------------------------------------------------------------------------
     -- Update the what if table with the updated record
     -- --------------------------------------------------------------------------
        hr_utility.set_location ('HR_SPP_WI_DATA.populate_spp_wi_table',121);
        hr_utility.set_location ('HR_SPP_WI_DATA - Placement:'||p_placement_id,121);
        hr_utility.set_location ('HR_SPP_WI_DATA - Assignment:'||p_assignment_id,121);
        --
          HR_SPP_WI_DATA.populate_spp_wi_table
            (p_placement_id           => p_placement_id
            ,p_assignment_id          => p_assignment_id
            ,p_effective_date         => P_Effective_Date
            ,p_parent_spine_id        => p_parent_spine_id
            ,p_step_id                => l_new_step_id
            ,p_spinal_point_id        => p_spinal_point_id
            ,p_rate_id                => p_rate_id);
            --
         l_update := 'Y';

     else

         l_new_step_id := p_lc_step_id;

     end if;


   -- --------------------------------------------------------------------------
   -- Now if l_exception_report_1 or l_exception_report_2 is set to 'Y' then the
   -- record has to be reported
   -- --------------------------------------------------------------------------
   --
   if (l_exception_report1 = 'Y')
   then
      hr_utility.set_location
      ('Populating HR_SPP_EXCEPTION_DATA.populate_spp_table',102);
      -- vik failing with no data found here.
      -- but why doesn't the comment show up on the trace?
      HR_SPP_EXCEPTION_DATA.populate_spp_table
        (p_effective_date             => P_Effective_Date
        ,p_placement_id               => p_placement_id
        ,p_effective_start_date       => p_effective_start_date
        ,p_effective_end_date         => p_end_date
        ,p_assignment_id              => p_assignment_id
        ,p_parent_spine_id            => p_parent_spine_id
        ,p_increment_number           => p_increment_number
        ,p_original_increment_number  => p_orig_increment_number
        ,p_sequence_number            => p_sequence_number
        ,p_next_sequence_number       => l_next_sequence_number
        ,p_spinal_point_id            => p_spinal_point_id
        ,p_step_id                    => p_lc_step_id
        ,p_new_step_id                => l_new_step_id
        ,p_grade_spine_id             => p_grade_spine_id
        ,p_update                     => l_update
        );
    --
   end if;
--
end update_report_exception;
--
/* -------------------------------------------------------------------- */
-- Process to check that the current assignment can be incremented      --
-- Also retrieves relevant values to use                                --
--									--
-- Processing logic of procedure - 					--
-- 									--
-- 1. Set datetrack mode according to the end date.			--
-- 2. Get step_id and seuence number for future step record if it 	--
--    exists.								--
-- 3. Get max ceiling step for grade scale and the assignment special 	--
--    ceiling step, then set to highest step based on sequence.		--
-- 4. Check if assignment is already at a limit.			--
-- 5. Get sequence for the ceiling.					--
-- 6. Get max number of steps left on the current grade.		--
-- 7. Compare the increment number and this number ad set accordingly.	--
--									--
/* -------------------------------------------------------------------- */

procedure check_increment_available
  (p_placement_id                in number
  ,p_end_date                    in date
  ,p_effective_date              in date
  ,p_effective_start_date        in date
  ,p_datetrack_mode              in out nocopy varchar2
  ,p_assignment_id               in number
  ,p_parent_spine_id             in number
  ,p_grade_spine_id              in number
  ,p_step_id                     in number
  ,p_sequence_number             in number
  ,p_increment_number            in number
  ,p_exception_report1           out nocopy varchar2
  ,p_update                      out nocopy varchar2
  ,p_increment                   out nocopy number
  ,p_max_sequence_number	 out nocopy number
  ,p_max_special_sequence_number out nocopy number
  ,p_max_spinal_point_id	 out nocopy number
  ,p_max_special_spinal_point_id out nocopy number) is


  l_max_end_date                date;
  l_datetrack_mode              varchar2(30);
  l_future_sequence_id          number;
  l_update                      varchar2(2); -- Able to update record
  l_increment                   number; -- new increment number
  l_max_ceiling_step_id         number;
  l_max_ceiling_sequence	number;
  l_special_ceiling_sequence	number;
  l_special_ceiling_step_id     number;
  l_grade_max_step_id           number;
  l_grade_max_sequence          number;
  l_max_sequence_number         number;
  l_max_special_sequence_number number;
  l_max_spinal_point_id         number;
  l_max_special_spinal_point_id number;
  l_max_count                   number;
  l_exception_report1           varchar2(2);
  l_future_grade_spine_id	number;


begin

  hr_utility.set_location('Entering check_increment_available procedure',5);

  l_future_sequence_id := null;
  l_update := 'Y';

  -- ------------------------------------------------------------------
  -- set the datetrack mode according to the end date
  -- ------------------------------------------------------------------
  BEGIN
     select max(effective_end_date)
     into l_max_end_date
     from per_spinal_point_placements_f
     where placement_id = p_placement_id;
  EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        hr_utility.set_location('NO_DATA_FOUND',1315);
        hr_utility.set_location('max(effective_end_date) ',1315);
        hr_utility.set_location('not found for p_placement_id '
                                ||p_placement_id, 1315);
  END;
  --
       if (p_end_date = l_max_end_date)
       and (P_Effective_Date <> p_effective_start_date)
       then
          hr_utility.set_location('Datetrack mode = UPDATE',10);
          l_datetrack_mode := 'UPDATE';
       elsif
          (P_Effective_Date = p_effective_start_date)
           then
              hr_utility.set_location('Datetrack mode = CORRECTION',10);
              l_datetrack_mode := 'CORRECTION';
       else
           hr_utility.set_location('Datetrack mode = UPDATE_CHANGE_INSERT',10);
           l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
       end if;
     --
     p_datetrack_mode := l_datetrack_mode;
  --
  -- ------------------------------------------------------------------
  -- Get the step_id,sequence number for the future record
  -- ------------------------------------------------------------------
     hr_utility.set_location('max_end_date:'||l_max_end_date,170);
     hr_utility.set_location('L_End_Date:'||p_end_date,170);
     hr_utility.set_location('p_placement_id - '||p_placement_id,333);
       if p_end_date <> hr_api.g_eot
       and p_end_date <> l_max_end_date
       then
          BEGIN
             select nvl(sps.sequence,-99),nvl(sps.grade_spine_id,-99)
               into l_future_sequence_id,
                    l_future_grade_spine_id
               from per_spinal_point_steps_f sps,
                    per_spinal_point_placements_f spp
              where spp.effective_start_date = p_end_date + 1
              and   spp.placement_id = p_placement_id
              and   spp.step_id = sps.step_id;
          EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  hr_utility.set_location('NO_DATA_FOUND',1316);
                  hr_utility.set_location('sps.grade_spine_id ',1316);
                  hr_utility.set_location('not found for p_placement_id '
                                          ||p_placement_id, 1316);
          END;
          --
          if nvl(l_future_grade_spine_id,-99) <> p_grade_spine_id
          then
             --
             l_future_sequence_id := -99;
             --
          end if;
              --
              -- Report on the future record
              --
              l_exception_report1 := 'Y';
              --
       end if;
  --
  hr_utility.set_location('Ceiling fetch',170);
  --
  -- ------------------------------------------------------------------
  -- Get the max ceiling step_id for the pay scale and the special
  -- ceiling step id for the assignment
  -- ------------------------------------------------------------------
  BEGIN
     select pgs.ceiling_step_id, nvl(paa.special_ceiling_step_id,pgs.ceiling_step_id)
     into l_max_ceiling_step_id,l_special_ceiling_step_id
     from per_grade_spines_f pgs,
          per_all_assignments_f paa
     where paa.assignment_id = p_assignment_id
     and   pgs.parent_spine_id = p_parent_spine_id
     and   pgs.grade_spine_id = p_grade_spine_id
     and   pgs.grade_id = paa.grade_id
     and   P_Effective_Date between pgs.effective_start_date
                                and pgs.effective_end_date
     and   P_Effective_Date between paa.effective_start_date
                                and paa.effective_end_date;
  EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        hr_utility.set_location('NO_DATA_FOUND',1400);
        hr_utility.set_location('pgs ceiling_step_id ',1400);
        hr_utility.set_location('not found for p_assignment_id'
                              ||p_assignment_id, 1400);
        hr_utility.set_location('p_parent_spine_id '||p_parent_spine_id, 1400);
        hr_utility.set_location('p_grade_spine_id '||p_grade_spine_id, 1400);
  END;
  --
  hr_utility.set_location('Max step and sequence fetch',170);

  if l_max_ceiling_step_id <> l_special_ceiling_step_id then -- 115.42 Update

    l_max_ceiling_step_id := l_special_ceiling_step_id;

  end if;
  --
  BEGIN
    select sequence
    into   l_special_ceiling_sequence
    from   per_spinal_point_steps_f sps
    where  sps.grade_spine_id = p_grade_spine_id
    and    sps.step_id = l_special_ceiling_step_id
    and    p_effective_date between effective_start_date and effective_end_date;
 EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        hr_utility.set_location('NO_DATA_FOUND',1500);
        hr_utility.set_location('special_ceiling_sequence ',1500);
        hr_utility.set_location('not found for l_special_ceiling_step_id '
                              ||l_special_ceiling_step_id, 1500);
        hr_utility.set_location('p_grade_spine_id '||p_grade_spine_id, 1500);
  END;
  -- ------------------------------------------------------------------
  -- Get the max step_id and seuence for the grade
  -- ------------------------------------------------------------------
  BEGIN
     select sps.step_id, sequence
     into l_grade_max_step_id, l_grade_max_sequence
     from per_spinal_point_steps_f sps
     where sps.grade_spine_id = p_grade_spine_id
     and   sps.sequence = (select max(sequence)
                           from per_spinal_point_steps_f psp1
                           where grade_spine_id = p_grade_spine_id
                           and p_effective_date
                           between effective_start_date and effective_end_date);
 EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        hr_utility.set_location('NO_DATA_FOUND',1500);
        hr_utility.set_location('sequence and step id',1500);
        hr_utility.set_location('not found for max grade sequence and ', 1500);
        hr_utility.set_location('p_grade_spine_id '||p_grade_spine_id, 1500);
  END;
  --
  if l_special_ceiling_sequence <> l_grade_max_sequence
  then
     l_grade_max_step_id := l_special_ceiling_step_id;
     l_grade_max_sequence := l_special_ceiling_sequence;
  end if;
  --
  hr_utility.set_location(' ***** ANOTHER PROBLEM ***** ',333);
  hr_utility.set_location('l_grade_max_step_id - '||l_grade_max_step_id,333);
  hr_utility.set_location('l_grade_max_sequence - '||l_grade_max_sequence,333);
  hr_utility.set_location('l_special_ceiling_step_id - '||l_special_ceiling_step_id,333);
  hr_utility.set_location('l_special_ceiling_sequence - '||l_special_ceiling_sequence,333);
  hr_utility.set_location('l_future_sequence_id - '||l_future_sequence_id,333);
  --
  if l_future_sequence_id = -99 or l_future_sequence_id is null
  then
     l_future_sequence_id := l_grade_max_sequence;
  end if;
  --
  hr_utility.set_location('l_grade_max_step_id:'||l_grade_max_step_id,200);
  hr_utility.set_location('l_grade_max_sequence:'||l_grade_max_sequence,200);
  --
  -- ------------------------------------------------------------------
  -- Check if assignment already at a grade limit
  -- ------------------------------------------------------------------
     hr_utility.set_location('Ceiling Reached?',201);
     hr_utility.set_location('Step ID '||p_step_id,201);
     hr_utility.set_location('l_special_ceiling_step_id '||l_special_ceiling_step_id,201);
     hr_utility.set_location('max_ceiling_step_id '||l_max_ceiling_step_id,201);
     --
     if (l_special_ceiling_step_id = p_step_id
     or l_grade_max_step_id = p_step_id)
     then
        l_update := 'N';
        l_exception_report1 := 'Y';
     end if;
     --
     hr_utility.set_location('l_update '||l_update,201);
  --
  -- ------------------------------------------------------------------
  -- Get the sequence number for the two ceiling step id's along with
  -- the spinal_point_id for the max ceiling
  -- ------------------------------------------------------------------
     hr_utility.set_location('sequence number for the two ceiling',202);
     hr_utility.set_location(l_max_ceiling_step_id,203);
     hr_utility.set_location(l_special_ceiling_step_id,204);
     BEGIN
       select psp1.sequence,
              nvl(psp2.sequence,99999999),
              psp1.spinal_point_id,
              psp2.spinal_point_id
       into l_max_sequence_number,
            l_max_special_sequence_number,
            l_max_spinal_point_id,
            l_max_special_spinal_point_id
       from per_spinal_points psp1,
            per_spinal_points psp2,
            per_spinal_point_steps_f sps1,
            per_spinal_point_steps_f sps2
       where psp1.spinal_point_id = sps1.spinal_point_id
       and   psp2.spinal_point_id = sps2.spinal_point_id
       and   sps1.step_id = l_max_ceiling_step_id
       and   sps2.step_id = l_special_ceiling_step_id;
     EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        hr_utility.set_location('NO_DATA_FOUND',1600);
        hr_utility.set_location('sequence and point ids ',1600);
        hr_utility.set_location('not found for l_max_ceiling_step_id '
                                ||l_max_ceiling_step_id, 1600);
        hr_utility.set_location('and l_special_ceiling_step_id '
                                ||l_special_ceiling_step_id, 1600);
     END;
  --
  -- ------------------------------------------------------------------
  -- Select the max number of steps left for the grade - Also compare
  -- the two limits and stop if reached
  -- ------------------------------------------------------------------
  --
     hr_utility.set_location('******* CEILING ERROR CATCH *********',333);
     hr_utility.set_location('l_max_sequence_number - '||l_max_sequence_number,333);
     hr_utility.set_location('l_max_special_sequence_number - '||l_max_special_sequence_number,333);
     hr_utility.set_location('l_grade_max_sequence - '||l_grade_max_sequence,333);
     hr_utility.set_location('l_future_sequence_id - '||l_future_sequence_id,333);
     hr_utility.set_location('p_sequence_number - '||p_sequence_number,333);
     BEGIN
        select count(sps.sequence)
        into l_max_count
        from per_spinal_point_steps_f sps
        where sps.sequence > p_sequence_number
        and sps.grade_spine_id = p_grade_spine_id
        and sps.sequence <= l_max_sequence_number
        and sps.sequence <= l_max_special_sequence_number
        and sps.sequence <= l_grade_max_sequence
        and sps.sequence <= l_future_sequence_id
        and p_effective_date between sps.effective_start_date
                                and sps.effective_end_date
        order by sps.sequence;
     EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        hr_utility.set_location('NO_DATA_FOUND',1700);
        hr_utility.set_location('max spinal point count ',1700);
        hr_utility.set_location('not found for p_grade_spine_id '
                                ||p_grade_spine_id, 1700);
        hr_utility.set_location('and > p_sequence_number '
                                ||p_sequence_number, 1700);
        hr_utility.set_location('l_max_sequence_number '
                                ||l_max_sequence_number, 1700);
        hr_utility.set_location('l_max_special_sequence_number '
                                ||l_max_special_sequence_number, 1700);
        hr_utility.set_location('l_future_sequence_id '
                                ||l_future_sequence_id, 1700);
        hr_utility.set_location('l_grade_max_sequence '
                                ||l_grade_max_sequence, 1700);
     END;
     hr_utility.set_location ('hrspine.spine', 1222);
     hr_utility.set_location ('count(sps.sequence):'||L_Max_Count,12222);
  -- ------------------------------------------------------------------
  -- Checks the increment by number is not greater than
  -- the max number of steps left for the grade
  -- ------------------------------------------------------------------
  --
     hr_utility.set_location('Assign Value to l_increment',140);
       --
       l_increment := p_increment_number;
       --
       hr_utility.set_location('Value = '||l_increment,140);
       hr_utility.set_location('Max Count Value = '||L_Max_Count,141);
       --
         if l_increment > L_Max_Count
         then
            l_increment := L_Max_Count;
            l_exception_report1 := 'Y';
         end if;
      --
         if L_Max_Count = 0
         then
            hr_utility.set_location('L_Max_Count = 0 so update denied',141);
            l_update := 'N';
         end if;
  --
  p_increment := l_increment;
  p_update := l_update;
  p_exception_report1 := l_exception_report1;
  l_max_sequence_number         := p_max_sequence_number;
  l_max_special_sequence_number := p_max_special_sequence_number;
  l_max_spinal_point_id         := p_max_spinal_point_id;
  l_max_special_spinal_point_id := p_max_special_spinal_point_id;
  --
  hr_utility.set_location('Exiting check_increment_available procedure',15);
  --
end check_increment_available;
--
/* -------------------------------------------------------------------- */
-- Procedure checks that other dependant parameters are all valid 	--
-- -------------------------------------------------------------------- --
--								  	--
-- Check that where parameters depend on other parameters to be   	--
-- processed that they exist and are valid. For instance if       	--
-- qualification status is not null, qualification type must also not	--
-- be null.							  	--
-- 								  	--
-- Processing logic of procedure -                                      --
--                                                                      --
-- 1. Check organization structure parameters.				--
-- 2. Check qualification parameters.					--
-- 3. Check legal entity parameters.					--
--									--
/* -------------------------------------------------------------------- */
--
procedure constraint_check
  (p_org_structure_top_node     in number default null
  ,p_org_structure_ver_id       in number default null
  ,p_qual_status                in varchar2 default null
  ,p_qual_type                  in number default null
  ,p_business_group_id          in number
  ,p_legal_entity               in number default null) is
  --
  l_dummy number;
  --
  --
  -- Legal Entity check cursor
  --
    cursor csr_legal_entity is
    select 1
    from hr_legal_entities
    where organization_id = p_legal_entity
    and business_group_id = p_business_group_id;
--
begin
--
    --
    -- Check if org_structure - Either both parameters have to be passed
    --                          or neither.
    --

    if p_org_structure_top_node is not null
    or p_org_structure_ver_id is not null
    then
       if p_org_structure_top_node is null
       or p_org_structure_ver_id is null
       then
          -- Raise error
          fnd_message.set_name('PER', 'HR_289280_SPP_INC_ORG_STRUCT');
          hr_utility.raise_error;
       end if;
    end if;
    --
    -- Check qualifications - Either both parameters have to be passed
    --                        or neither.
    --
    if p_qual_status is not null
    then
       if p_qual_type is null
       then
          -- Raise error
          fnd_message.set_name('PER', 'HR_289290_SPP_INC_QUAL');
          hr_utility.raise_error;
       end if;
    end if;
    --
    --
    -- Legal Entity check - US only
    --
    --
    if p_legal_entity is not null then
     open csr_legal_entity;
     fetch csr_legal_entity into l_dummy;
      if csr_legal_entity%notfound then
      fnd_message.set_name('PER', 'HR_289291_SPP_INC_LEGAL_ENTITY');
      hr_utility.raise_error;
     end if;
    close csr_legal_entity;
    end if;
    --
end constraint_check;
--
/*----------------------------- spine ---------------------------------*/
/*
   NAME
      spine   - entry point for the spinal incrementing process
   -----------
   DESCRIPTION
   -----------
     The process has been updated to supply many new features to the increment
     process. The first and most import one is that an assignment can be
     incremented by greater than just one point. This is determined by a new
     parameter on the grade step placement form, Increment Number, this is a
     mandatory parameter. This allows the user to change the number of steps
     that an assignment goes up by each time.
     (Within this process there is a check procedure that finds the number of
     valid steps left for the assignment on its current grade and if the
     increment number is greater than this then the number is set to the number
     of steps left on the grade.)

     The second main new feature is the abbility to run the process in a 'What If'
     mode. What this means is that you can run the increment process in a rollback
     mode. Because of the addition or reporting that has been added to the process
     it is possible to run the Increment process but without commiting the database,
     so that you can see who is incremented and by how much, who is not incremented,
     and who is incremented but reaches some kind of ceiling during the process.

     There has also been the addition of many new parameters to the Increment process
     to allow the user to restrict which assignments are incremented.

     In addition to standard restriction parameters that maps to table columns there
     has also been the addition of business rule parameters. What these do is to
     allow the user to increment an assignment based on say the employee's date of
     birth. This also allows the restriction for a date period, so you could specify
     that you wish to increment all those employee's that have a birthday in march.

     There are also an additional two parameters that allow you to specify an age range,
     so for the example just given you could also specify 21 - 30 so you would only
     increment employee's who had a birthday in march and were between the ages of 21
     to 30. This increment will be performed based on the business rule effective date.
     This means that the increment can be done on the date of birth for each employee,
     the start of the next month etc.
*/


/* -------------------------------------------------------------------- */
-- Main Entry Point To Increment Procedure 				--
-- -------------------------------------------------------------------- --
--                                                                      --
-- Depending on if the business rule parameters have been set call the  --
-- correct code and try to increment the valid assignments.		--
--                                                                      --
-- Processing logic of procedure -                                      --
--                                                                      --
-- 1. Check business group id passed is valid.				--
-- 2. Call the businss rule check procedure.				--
-- 3. Call the constraint check procedure				--
-- 4. If the concat segs parameter is not null then correctly set 	--
--    concat seg values.						--
-- 5. If business_rule is null then					--
--    a. Call check increment available procedure.			--
--    b. Call update report exception procedure.			--
--									--
-- 6. Else if business_rule is not null then				--
--    a. Check date_from and date_to parameters for year overlap.	--
--    b. Set local dates / years accordingly.				--
--    c. Call cursor to return all assignment info for business rule	--
--       process, loop following until no more rows.			--
--    d. When no data found set the local variables to null.		--
--    e. If l_first_call flag = FALSE then				--
--	 1. Check if the copied assign param matches fetched assign_id  --
--	    and set local parameters accordingly.			--
--       2. Depending on business rule selected, check dates for copy   --
--          to fetch version and set local params accordingly.		--
--       3. Check if the year loops over an end of year and set the	--
--	    appropriate year accordingly etc.				--
--	 4. Depending on the dependant date set the effective dates	--
--	    accordingly.						--
--       5. Fetch details of assignment to be incremented using main 	--
-- 	    select cursor.						--
--	 6. Call check increment available procedure.			--
--	 7. Call update report exception procedure.			--
--  7. Update table per_parent_spines to set the date for 		--
--     last_automatic_increment_date.					--
--                                                                      --
/* -------------------------------------------------------------------- */

procedure spine
(
    P_Parent_Spine_ID      	in number default null,
    P_Effective_Date       	in date,
    p_id_flex_num          	in number default null,
    p_concat_segs          	in varchar2 default null,
    P_Business_Group_ID		in number,
    p_collective_agreement_id   in number default null,
    p_person_id			in number default null,
    p_payroll_id  		in number default null,
    p_organization_id		in number default null,
    p_legal_entity		in number default null,
    p_org_structure_ver_id	in number default null,
    p_qual_type			in number default null,
    p_qual_status		in varchar2 default null,
    p_org_structure_top_node    in number default null,
    p_rate_id			in number default null,
    p_business_rule             in varchar2 default null,
    p_dependant_date            in varchar2 default null,
    p_br_date_from              in date default null,
    p_br_date_to                in date default null,
    p_year_from                 in number default null,
    p_year_to			in number default null,
    p_message_number	 out nocopy varchar2
) is
--
-- this cursor is used to get the order of the segments from the foundation
-- table
--
cursor c1 is
select   application_column_name
from     fnd_id_flex_segments
where    id_flex_num   = p_id_flex_num
and      application_id = 801
and      id_flex_code = 'GRP'
and      enabled_flag  = 'Y'
order by segment_num;
--
-- the list of local segments:
--
l_seg1       pay_people_groups.segment1%type;
l_seg2       pay_people_groups.segment2%type;
l_seg3       pay_people_groups.segment3%type;
l_seg4       pay_people_groups.segment4%type;
l_seg5       pay_people_groups.segment5%type;
l_seg6       pay_people_groups.segment6%type;
l_seg7       pay_people_groups.segment7%type;
l_seg8       pay_people_groups.segment8%type;
l_seg9       pay_people_groups.segment9%type;
l_seg10      pay_people_groups.segment10%type;
l_seg11      pay_people_groups.segment11%type;
l_seg12      pay_people_groups.segment12%type;
l_seg13      pay_people_groups.segment13%type;
l_seg14      pay_people_groups.segment14%type;
l_seg15      pay_people_groups.segment15%type;
l_seg16      pay_people_groups.segment16%type;
l_seg17      pay_people_groups.segment17%type;
l_seg18      pay_people_groups.segment18%type;
l_seg19      pay_people_groups.segment19%type;
l_seg20      pay_people_groups.segment20%type;
l_seg21      pay_people_groups.segment21%type;
l_seg22      pay_people_groups.segment22%type;
l_seg23      pay_people_groups.segment23%type;
l_seg24      pay_people_groups.segment24%type;
l_seg25      pay_people_groups.segment25%type;
l_seg26      pay_people_groups.segment26%type;
l_seg27      pay_people_groups.segment27%type;
l_seg28      pay_people_groups.segment28%type;
l_seg29      pay_people_groups.segment29%type;
l_seg30      pay_people_groups.segment30%type;
--
l_seg_value  pay_people_groups.segment1%type;
l_concat_sep varchar2(1);         -- the concatenated delimiter
l_count      number := 0;         -- the count of the individual segments
l_pos        number := 1;         -- the position of the individual segment
l_pos_sep    number;              -- the position of the separator
l_length     number;              -- the length of the string
l_message_number_count number;
--
l_increment             number;            -- local increment number
LC_Placement_ID         number;
LC_Step_ID              number;
LC_Assignment_ID        number;
LC_Auto_Increment_Flag  varchar2 (1);
LC_Spinal_Point_ID      number;
LC_New_Step_ID          number;
LC_Parent_Spine_ID      number;
L_Pass_String           varchar2 (16) := '***************';
L_End_Date              date;
LC_Sequence_Number       number; -- current sequence number
LC_Increment_Number      number; -- increment number for assignment
LC_Effective_Start_Date  date;
--
--
-- Parameters added when api created for dml on per_spinal_point_placements_f
--
l_datetrack_mode varchar2(30) := 'UPDATE_CHANGE_INSERT';
l_reason         varchar2(30) := 'AI';
LC_Object_Version_Number per_spinal_point_placements_f.object_version_number%TYPE;
l_effective_start_date per_spinal_point_placements_f.effective_start_date%TYPE;
l_grade_spine_id       per_grade_spines_f.grade_spine_id%TYPE;
l_update	       varchar2(2);
l_update2	       varchar2(2);
l_exception_report1   varchar2(2);
l_exception_report2   varchar2(2);
--
/* Parameters added for temp addition to process for business rule inclusion */
--
  l_br_flag			boolean;
  l_effective_date		date;
  l_max_sequence_number         number;
  l_max_special_sequence_number number;
  l_max_spinal_point_id         number;
  l_max_special_spinal_point_id number;
  l_br_assignment_id		number;
  l_br_date_of_birth		date;
  l_br_annivarsary_of_joining	date;
  l_br_latest_hire_date		date;
  l_br_adjusted_svc_date	date;
  l_payroll_id			number;
  l_copy_br_assignment_id       number;
  l_copy_br_date_of_birth       date;
  l_copy_br_anniv_of_joining   	date;
  l_copy_br_latest_hire_date    date;
  l_copy_br_adjusted_svc_date   date;
  l_copy_payroll_id		number;
  l_duplicate_flag		boolean := FALSE;
  l_duplicate_error_flag	boolean := FALSE;
  l_first_call_flag		boolean := TRUE;
  l_br_update			varchar2(2) := 'N';
  l_temp_year			varchar2(30);
  l_effective_year		varchar2(30);
  l_effective_month		varchar2(30);
  l_earliest_start_date		date := to_date('01/01/1901','DD/MM/YYYY');
  --
  l_br_date_from_temp1		varchar2(30);
  l_br_date_to_temp1          	varchar2(30);
  l_year_from_temp		varchar2(5);
  l_year_to_temp		varchar2(5);
  l_year_temp			varchar2(5);
  --
  l_br_date_from		date;
  l_br_date_to			date;
  l_year_loop			varchar2(2);
  l_year_loop_count		number := 1;
--
-- Main select cursor to find all assignments that are eligble to have an
-- increment
-- This returns all data needed to perform the increment
-- All variables from increment process are in where clause of cursor
--
CURSOR C_Spinal_Placements_Cursor IS
  SELECT distinct spp.placement_id,
         spp.step_id,
         spp.assignment_id,
         spp.auto_increment_flag,
         sps.spinal_point_id,
	 spp.parent_spine_id,
	 psp.sequence,
 	 NVL(spp.increment_number,0),
         spp.object_version_number,
	 spp.effective_start_date,
 	 spp.effective_end_date,
         pgs.grade_spine_id
  FROM   per_all_assignments_f	       asg,
         per_grade_spines_f            pgs,
         per_spinal_points             psp1,
         per_spinal_point_steps_f      sps1,
         per_spinal_points             psp,
         per_spinal_point_steps_f      sps,
         per_spinal_point_placements_f spp
  WHERE  (p_parent_spine_id is null -- PARENT_SPINE_ID
	  OR
	  (spp.parent_spine_id is not null
	   and spp.parent_spine_id  = P_Parent_Spine_ID))
  AND    spp.business_group_id   = P_Business_Group_ID
  AND    spp.step_id             = sps.step_id
  AND    sps.grade_spine_id      = pgs.grade_spine_id
  AND    sps.spinal_point_id     = psp.spinal_point_id
  AND    spp.auto_increment_flag = 'Y'
  AND    psp1.parent_spine_id    = spp.parent_spine_id
  AND    sps1.grade_spine_id     = sps.grade_spine_id
  AND    sps1.spinal_point_id    = psp1.spinal_point_id
  AND    pgs.grade_id            = asg.grade_id
  AND    asg.assignment_id       = spp.assignment_id
  AND    (p_collective_agreement_id is NULL -- COLLECTIVE_AGREEMENT_ID
	  OR
 	  (asg.collective_agreement_id is not null
	   and asg.collective_agreement_id = p_collective_agreement_id))
  AND    (p_business_rule is NULL -- Only use assignment id if business rule is not null
	  OR
	  (p_business_rule is not null
	   and asg.assignment_id = l_copy_br_assignment_id))
  AND    (p_person_id is NULL -- PERSON_ID
          OR
          (asg.person_id is not null
	   and asg.person_id = p_person_id))
  AND    (p_payroll_id is NULL -- PAYROLL_ID
          OR
          (asg.payroll_id is not null
	   and asg.payroll_id = p_payroll_id))
  AND    (p_organization_id is NULL -- ORGANIZATION_ID
          OR
          (asg.organization_id is not null
           and asg.organization_id = p_organization_id))
  AND    (p_legal_entity is NULL -- LEGAL ENTITY
          OR
          exists (select 1
                  from hr_soft_coding_keyflex sck
                  where asg.soft_coding_keyflex_id is not null
                  and asg.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
                  and sck.segment1 = p_legal_entity))
  AND    (p_qual_type is NULL
	  OR
	  exists (select 1
                  from per_qualifications pq
                  where asg.person_id = pq.person_id
	          and pq.qualification_type_id = p_qual_type))
  AND    (p_qual_status is NULL
	  OR
	  exists (select 1
                  from per_qualifications pq
                  where asg.person_id = pq.person_id
                  and pq.qualification_type_id = p_qual_type
	          and pq.status = p_qual_status))
  AND    (p_org_structure_ver_id is NULL -- OGANIZATION HIERARCHY
	  OR
	  (exists
	   (select 1
	   from per_org_structure_elements ose
           where ose.org_structure_version_id = p_org_structure_ver_id
	   and asg.organization_id = ose.organization_id_child
	   connect by prior ose.organization_id_child = ose.organization_id_parent
	   and     ose.org_structure_version_id = p_org_structure_ver_id
           start with ose.organization_id_parent = p_org_structure_top_node
           and     ose.org_structure_version_id = p_org_structure_ver_id)))
  AND    l_effective_date BETWEEN spp.effective_start_date
			      AND spp.effective_end_date
  AND    l_effective_date BETWEEN sps.effective_start_date
                              AND sps.effective_end_date
  AND    l_effective_date BETWEEN pgs.effective_start_date
                              AND pgs.effective_end_date
  AND    l_effective_date BETWEEN asg.effective_start_date
                              AND asg.effective_end_date
  AND    l_effective_date BETWEEN sps1.effective_start_date
                              AND sps1.effective_end_date
  AND    psp1.sequence = psp.sequence;

--
-- Now declare the group match cursor.  This is the same as that above,
-- but does additional restriction by NOT NULL groups of the input keyflex.
--
CURSOR C_Key_Spinal_Placements_Cursor IS
  SELECT distinct spp.placement_id,
         spp.step_id,
         spp.assignment_id,
         spp.auto_increment_flag,
         sps.spinal_point_id,
	 spp.parent_spine_id,
	 psp.sequence,
	 NVL(spp.increment_number,0),
         spp.object_version_number,
	 spp.effective_start_date,
	 spp.effective_end_date,
         pgs.grade_spine_id
  FROM   per_all_assignments_f	       asg,
         pay_people_groups             ppg,
         per_grade_spines_f            pgs,
         per_spinal_points             psp1,
         per_spinal_point_steps_f      sps1,
         per_spinal_points             psp,
         per_spinal_point_steps_f      sps,
         per_spinal_point_placements_f spp
  WHERE  (p_parent_spine_id is null -- PARENT_SPINE_ID
          OR
          (spp.parent_spine_id is not null
           and spp.parent_spine_id  = P_Parent_Spine_ID))
  AND    spp.business_group_id   = P_Business_Group_ID
  AND    spp.step_id             = sps.step_id
  AND    sps.grade_spine_id      = pgs.grade_spine_id
  AND    sps.spinal_point_id     = psp.spinal_point_id
  AND    spp.auto_increment_flag = 'Y'
  AND    psp1.parent_spine_id    = spp.parent_spine_id
  AND    sps1.grade_spine_id     = sps.grade_spine_id
  AND    sps1.spinal_point_id    = psp1.spinal_point_id
  AND    pgs.grade_id            = asg.grade_id
  AND    asg.assignment_id       = spp.assignment_id
  AND    (p_collective_agreement_id is NULL -- COLLECTIVE_AGREEMENT_ID
          OR
          (asg.collective_agreement_id is not null
           and asg.collective_agreement_id = p_collective_agreement_id))
  AND    (p_business_rule is NULL -- Only use assignment id if business rule is not null
          OR
          (p_business_rule is not null
           and asg.assignment_id = l_copy_br_assignment_id))
  AND    (p_person_id is NULL -- PERSON_ID
          OR
          (asg.person_id is not null
           and asg.person_id = p_person_id))
  AND    (p_payroll_id is NULL -- PAYROLL_ID
          OR
          (asg.payroll_id is not null
           and asg.payroll_id = p_payroll_id))
  AND    (p_organization_id is NULL -- ORGANIZATION_ID
          OR
          (asg.organization_id is not null
           and asg.organization_id = p_organization_id))
  AND    (p_legal_entity is NULL -- LEGAL ENTITY
          OR
          exists (select 1
                  from hr_soft_coding_keyflex sck
                  where asg.soft_coding_keyflex_id is not null
                  and asg.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
                  and sck.segment1 = p_legal_entity))
  AND    (p_qual_type is NULL
          OR
          exists (select 1
                  from per_qualifications pq
                  where asg.person_id = pq.person_id
                  and pq.qualification_type_id = p_qual_type))
  AND    (p_qual_status is NULL
          OR
          exists (select 1
                  from per_qualifications pq
                  where asg.person_id = pq.person_id
                  and pq.qualification_type_id = p_qual_type
                  and pq.status = p_qual_status))
  AND    (p_org_structure_ver_id is NULL -- OGANIZATION HIERARCHY
          OR
          (exists
           (select 1
           from per_org_structure_elements ose
           where ose.org_structure_version_id = p_org_structure_ver_id
           and asg.organization_id = ose.organization_id_child
         connect by prior ose.organization_id_child = ose.organization_id_parent
           and     ose.org_structure_version_id = p_org_structure_ver_id
           start with ose.organization_id_parent = p_org_structure_top_node
           and     ose.org_structure_version_id = p_org_structure_ver_id)))
  AND 	 l_effective_date  BETWEEN spp.effective_start_date
                               AND spp.effective_end_date
  AND    l_effective_date  BETWEEN sps.effective_start_date
                               AND sps.effective_end_date
  AND    l_effective_date  BETWEEN pgs.effective_start_date
                               AND pgs.effective_end_date
  AND    l_effective_date  BETWEEN asg.effective_start_date
                               AND asg.effective_end_date
  AND    l_effective_date  BETWEEN sps1.effective_start_date
                               AND sps1.effective_end_date
  AND    l_effective_date  BETWEEN sps.effective_start_date
			       AND asg.effective_end_date
  AND    psp1.sequence = psp.sequence
  AND    asg.people_group_id     = ppg.people_group_id
  AND    NVL(l_seg1, NVL( ppg.Segment1, L_Pass_String)) =
         NVL(ppg.Segment1, L_Pass_String)
  AND    NVL(l_seg2, NVL( ppg.Segment2, L_Pass_String)) =
         NVL(ppg.Segment2, L_Pass_String)
  AND    NVL(l_seg3, NVL( ppg.Segment3, L_Pass_String)) =
         NVL(ppg.Segment3, L_Pass_String)
  AND    NVL(l_seg4, NVL( ppg.Segment4, L_Pass_String)) =
         NVL(ppg.Segment4, L_Pass_String)
  AND    NVL(l_seg5, NVL( ppg.Segment5, L_Pass_String)) =
         NVL(ppg.Segment5, L_Pass_String)
  AND    NVL(l_seg6, NVL( ppg.Segment6, L_Pass_String)) =
         NVL(ppg.Segment6, L_Pass_String)
  AND    NVL(l_seg7, NVL( ppg.Segment7, L_Pass_String)) =
         NVL(ppg.Segment7, L_Pass_String)
  AND    NVL(l_seg8, NVL( ppg.Segment8, L_Pass_String)) =
         NVL(ppg.Segment8, L_Pass_String)
  AND    NVL(l_seg9, NVL( ppg.Segment9, L_Pass_String)) =
         NVL(ppg.Segment9, L_Pass_String)
  AND    NVL(l_seg10, NVL( ppg.Segment10, L_Pass_String)) =
         NVL(ppg.Segment10, L_Pass_String)
  AND    NVL(l_seg11, NVL( ppg.Segment11, L_Pass_String)) =
         NVL(ppg.Segment11, L_Pass_String)
  AND    NVL(l_seg12, NVL( ppg.Segment12, L_Pass_String)) =
         NVL(ppg.Segment12, L_Pass_String)
  AND    NVL(l_seg13, NVL( ppg.Segment13, L_Pass_String)) =
         NVL(ppg.Segment13, L_Pass_String)
  AND    NVL(l_seg14, NVL( ppg.Segment14, L_Pass_String)) =
         NVL(ppg.Segment14, L_Pass_String)
  AND    NVL(l_seg15, NVL( ppg.Segment15, L_Pass_String)) =
         NVL(ppg.Segment15, L_Pass_String)
  AND    NVL(l_seg16, NVL( ppg.Segment16, L_Pass_String)) =
         NVL(ppg.Segment16, L_Pass_String)
  AND    NVL(l_seg17, NVL( ppg.Segment17, L_Pass_String)) =
         NVL(ppg.Segment17, L_Pass_String)
  AND    NVL(l_seg18, NVL( ppg.Segment18, L_Pass_String)) =
         NVL(ppg.Segment18, L_Pass_String)
  AND    NVL(l_seg19, NVL( ppg.Segment19, L_Pass_String)) =
         NVL(ppg.Segment19, L_Pass_String)
  AND    NVL(l_seg20, NVL( ppg.Segment20, L_Pass_String)) =
         NVL(ppg.Segment20, L_Pass_String)
  AND    NVL(l_seg21, NVL( ppg.Segment21, L_Pass_String)) =
         NVL(ppg.Segment21, L_Pass_String)
  AND    NVL(l_seg22, NVL( ppg.Segment22, L_Pass_String)) =
         NVL(ppg.Segment22, L_Pass_String)
  AND    NVL(l_seg23, NVL( ppg.Segment23, L_Pass_String)) =
         NVL(ppg.Segment23, L_Pass_String)
  AND    NVL(l_seg24, NVL( ppg.Segment24, L_Pass_String)) =
         NVL(ppg.Segment24, L_Pass_String)
  AND    NVL(l_seg25, NVL( ppg.Segment25, L_Pass_String)) =
         NVL(ppg.Segment25, L_Pass_String)
  AND    NVL(l_seg26, NVL( ppg.Segment26, L_Pass_String)) =
         NVL(ppg.Segment26, L_Pass_String)
  AND    NVL(l_seg27, NVL( ppg.Segment27, L_Pass_String)) =
         NVL(ppg.Segment27, L_Pass_String)
  AND    NVL(l_seg28, NVL( ppg.Segment28, L_Pass_String)) =
         NVL(ppg.Segment28, L_Pass_String)
  AND    NVL(l_seg29, NVL( ppg.Segment29, L_Pass_String)) =
         NVL(ppg.Segment29, L_Pass_String)
  AND    NVL(l_seg30, NVL( ppg.Segment30, L_Pass_String)) =
         NVL(ppg.Segment30, L_Pass_String);
  --
  --
  -- Cursor to get all assignments and there effective dates if business rule is used
  -- This simply returns all assignments that could be incremented, and the business rule
  -- dates so that the rest of the processing can determine when the increment should be
  -- taking place and then use the cursors above to determin if they are eligible
  --
  cursor csr_assignment_business_rule is
          select paa.assignment_id,
 		pap.date_of_birth,
 		pos.date_start,
 		pap.original_date_of_hire,
 		pos.adjusted_svc_date,
 		paa.payroll_id
 	 from   per_all_people_f pap,
 		per_periods_of_service pos,
 		per_all_assignments_f paa,
 		per_spinal_point_placements_f spp
 	 where  spp.assignment_id = paa.assignment_id
 	 and	paa.person_id 	  = pap.person_id
 	 and	pos.person_id	  = pap.person_id
 	 and    spp.business_group_id = p_business_group_id
 	 and    spp.effective_end_date >= l_br_date_from
 	 and    (('AOJ' = p_business_rule -- ***** ANNIVERSARY OF JOINING *****   --Bug #2999551
 		 and add_months(pap.original_date_of_hire, (to_number(substr(l_year_temp, 2, 4))- to_number(to_char(pap.original_date_of_hire,'YYYY')))*12)
 		 between l_br_date_from  and l_br_date_to
 		 and paa.period_of_service_id = pos.period_of_service_id
 		 and pap.original_date_of_hire between decode(p_year_to, null, l_earliest_start_date,
 							       add_months(l_br_date_from, - (p_year_to * 12)))
 						    and decode(p_year_from, null, l_br_date_to,
 							       add_months(l_br_date_to, - (p_year_from * 12))))
          or     ('DOB' = p_business_rule -- ***** DATE OF BIRTH *****       --Bug #2999551
 		  and add_months(pap.date_of_birth, (to_number(substr(l_year_temp, 2, 4))-to_number(to_char(pap.date_of_birth,'YYYY')))*12)
 		  between l_br_date_from and l_br_date_to
                  and pap.date_of_birth between decode(p_year_to, null, l_earliest_start_date,
                                                        add_months(l_br_date_from, - (p_year_to * 12)))
                                             and decode(p_year_from, null, l_br_date_to,
 						       add_months(l_br_date_to, - (p_year_from * 12))))
 	 or     ('ASD' = p_business_rule -- ***** AJUSTED SERVICE DATE *****
 		  and pos.adjusted_svc_date is not null      --Bug #2999551
		  AND    paa.period_of_service_id = pos.period_of_service_id  -- bug 6969602
 		  and add_months(pos.adjusted_svc_date, (to_number(substr(l_year_temp, 2, 4))- to_number(to_char(pos.adjusted_svc_date,'YYYY')))*12)
 		  between l_br_date_from  and l_br_date_to
                  and pos.adjusted_svc_date between decode(p_year_to, null, l_earliest_start_date,
                                                            add_months(l_br_date_from, - (p_year_to * 12)))
                                                 and decode(p_year_from, null, l_br_date_to,
                                                            add_months(l_br_date_to, - (p_year_from * 12))))
          or     ('LHD' = p_business_rule -- ***** LATEST HIRE DATE *****   --Bug # 2999551
 		  and add_months(pos.date_start, (to_number(substr(l_year_temp, 2, 4))- to_number(to_char(pos.date_start,'YYYY')))*12)
 		  between l_br_date_from and l_br_date_to
 		  and paa.period_of_service_id = pos.period_of_service_id
                  and pos.date_start between decode(p_year_to, null, l_earliest_start_date,
                                                     add_months(l_br_date_from, - (p_year_to * 12)))
                                          and decode(p_year_from, null, l_br_date_to,
                                                     add_months(l_br_date_to, - (p_year_from * 12)))))
 	 order by paa.assignment_id;

  --
  -- Cursor to get the next pay period
  --
  cursor csr_pay_period is
	 select ptp.start_date
	 from per_time_periods ptp
	 where ptp.payroll_id = l_copy_payroll_id
	 and   ptp.start_date > l_effective_date;
--
BEGIN
    --
    -- Check that the business group passed is valid
    --
    hr_api.validate_bus_grp_id
     (p_business_group_id    => P_Business_Group_ID);
    --

    --
    -- Check if the business rule is being used and if so that all required parameters are valid
    --
    business_rule_check
      (p_effective_date	=> p_effective_date
      ,p_business_rule	=> p_business_rule
      ,p_br_date_from	=> p_br_date_from
      ,p_br_date_to	=> p_br_date_to
      ,p_year_to	=> p_year_to
      ,p_year_from	=> p_year_from
      ,p_dependant_date => p_dependant_date
      ,p_br_flag	=> l_br_flag);

    -- hr_utility.set_location('HRSPINE - Business Rule = '||l_br_flag,55);

    --
    -- Check that all the constraints are correct
    --
    constraint_check
      (p_org_structure_top_node     => p_org_structure_top_node
      ,p_org_structure_ver_id       => p_org_structure_ver_id
      ,p_qual_status                => p_qual_status
      ,p_qual_type                  => p_qual_type
      ,p_business_group_id	        => p_business_group_id
      ,p_legal_entity		        => p_legal_entity);

    hr_utility.trace ('concat string = ' || p_concat_segs);
    --
    if (p_concat_segs is not null)
    then
       hr_utility.set_location ('hrspine.spine', 2);
       --
       BEGIN
          select concatenated_segment_delimiter
            into l_concat_sep
            from fnd_id_flex_structures
           where id_flex_num  = p_id_flex_num
             and application_id = 801
             and id_flex_code = 'GRP';
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             hr_utility.set_location('NO_DATA_FOUND',1900);
        hr_utility.set_location('concatenated_segment_delimiter ',1900);
        hr_utility.set_location('not found for p_id_flex_num '
                                ||p_id_flex_num, 1900);
      END;
        --
        -- loop through for each segment, and re-arrange into the correct
        -- segment order as held on the table pay_people_groups
        --
        for c1rec in c1 loop
            l_count := l_count + 1;
            l_pos_sep   := instr (p_concat_segs, l_concat_sep, 1, l_count);
            --
            if (l_pos_sep = 0) then    -- the search failed (end of string)
                l_seg_value := rtrim (substr (p_concat_segs, l_pos));
            else
                l_length := l_pos_sep - l_pos;
                l_seg_value := substr (p_concat_segs, l_pos, l_length);
            end if;
            l_pos := l_pos + l_length + 1;       -- skip on to next segment
            hr_utility.trace ((c1rec.application_column_name || ' = ')
                            || l_seg_value);
            if    (c1rec.application_column_name = 'SEGMENT1') then
                l_seg1 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT2') then
                l_seg2 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT3') then
                l_seg3 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT4') then
                l_seg4 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT5') then
                l_seg5 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT6') then
                l_seg6 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT7') then
                l_seg7 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT8') then
                l_seg8 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT9') then
                l_seg9 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT10') then
                l_seg10 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT11') then
                l_seg11 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT12') then
                l_seg12 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT13') then
                l_seg13 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT14') then
                l_seg14 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT15') then
                l_seg15 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT16') then
                l_seg16 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT17') then
                l_seg17 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT18') then
                l_seg18 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT19') then
                l_seg19 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT20') then
                l_seg20 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT21') then
                l_seg21 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT22') then
                l_seg22 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT23') then
                l_seg23 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT24') then
                l_seg24 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT25') then
                l_seg25 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT26') then
                l_seg26 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT27') then
                l_seg27 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT28') then
                l_seg28 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT29') then
                l_seg29 := l_seg_value;
            elsif (c1rec.application_column_name = 'SEGMENT30') then
                l_seg30 := l_seg_value;
            else
                hr_utility.trace ('ERROR : unknown application column name');
            end if;
        end loop;
        hr_utility.set_location ('hrspine.spine', 4);
        hr_utility.set_location('Seg 1 - '||l_seg1,4);
	hr_utility.set_location('Seg 15 - '||l_seg15,4);
    end if;
    --
    --  Set the count to see if any data is updated
    --
    	l_message_number_count := 0;
    --
    -- If the user is not using a business rule then use the old cursor
    --
    if l_br_flag = FALSE then
    --
	l_effective_date := p_effective_date;
    --
    -- Open the correct cursor
    --
	    if (p_concat_segs is null)
        then
               open C_Spinal_Placements_Cursor;
	    else
               open C_Key_Spinal_Placements_Cursor;
 	    end if;
        --
        LOOP
           if (p_concat_segs is null) then
               --
               -- fetch standard cursor, no group partial matching
               --
               /*** vik ***/
               hr_utility.set_location ('hrspine.spine', 51);
               FETCH C_Spinal_Placements_Cursor
               INTO  LC_Placement_ID,
                     LC_Step_ID,
                     LC_Assignment_ID,
                     LC_Auto_Increment_Flag,
                     LC_Spinal_Point_ID,
	                 LC_Parent_Spine_ID,
	                 LC_Sequence_Number,
              	     LC_Increment_Number,
                     LC_Object_Version_Number,
	                 LC_Effective_Start_Date,
	                 L_End_Date,
	                 l_grade_spine_id;
               --  vik
               if (C_Spinal_Placements_Cursor%notfound)
               then
                  hr_utility.set_location ('hrspine.spine', 69);
                  hr_utility.set_location ('no data found', 69);
                  hr_utility.set_location ('in C_Spinal_Placements_Cursor',69);
                  hr_utility.set_location ('for'||TO_CHAR(LC_Assignment_ID),69);
                  hr_utility.set_location ('and for'||TO_CHAR(LC_Placement_ID),69);
                  hr_utility.set_location ('for'|| P_Parent_Spine_ID,69);
               else
                 hr_utility.set_location ('hrspine.spine', 79);
                 hr_utility.set_location ('C_Spinal_Placements_Cur success',79);
                 hr_utility.set_location ('for '||TO_CHAR(LC_Assignment_ID),79);
                 hr_utility.set_location ('and for '||TO_CHAR(LC_Placement_ID),79);
                 hr_utility.set_location ('for'|| P_Parent_Spine_ID,79);
               end if;
               --
	       l_message_number_count := l_message_number_count + 1;
               --
               EXIT when C_Spinal_Placements_Cursor%notfound;
               --
            else
                --
                -- fetch key cursor, with group partial matching
                --
                hr_utility.set_location ('hrspine.spine', 6);
                FETCH C_Key_Spinal_Placements_Cursor
                INTO  LC_Placement_ID,
                      LC_Step_ID,
                      LC_Assignment_ID,
                      LC_Auto_Increment_Flag,
                      LC_Spinal_Point_ID,
                      LC_Parent_Spine_ID,
                      LC_Sequence_Number,
                      LC_Increment_Number,
                      LC_Object_Version_Number,
                      LC_Effective_Start_Date,
		              L_End_Date,
		              l_grade_spine_id;
                      --
		       l_message_number_count := l_message_number_count + 1;
                      --
                EXIT when C_Key_Spinal_Placements_Cursor%notfound;
            end if;
	    --
	    --
	    -- Call the procedure to check if assignment selected can be
        -- incremented
        --
              check_increment_available
             (p_placement_id               	=> LC_Placement_ID
             ,p_end_date                   	=> L_End_Date
             ,p_effective_date             	=> l_effective_date
             ,p_effective_start_date       	=> LC_Effective_Start_Date
             ,p_datetrack_mode             	=> l_datetrack_mode
             ,p_assignment_id              	=> LC_Assignment_ID
             ,p_parent_spine_id            	=> LC_Parent_Spine_ID
             ,p_grade_spine_id             	=> l_grade_spine_id
             ,p_step_id                    	=> LC_Step_ID
             ,p_sequence_number            	=> LC_Sequence_Number
             ,p_increment_number           	=> LC_Increment_Number
             ,p_exception_report1          	=> l_exception_report1
             ,p_update                    	=> l_update
             ,p_increment                 	=> l_increment
  		     ,p_max_sequence_number	      	=> l_max_sequence_number
  		     ,p_max_special_sequence_number	=> l_max_special_sequence_number
  		     ,p_max_spinal_point_id		=> l_max_spinal_point_id
  		     ,p_max_special_spinal_point_id	=> l_max_special_spinal_point_id );

	    --
   	    -- Call procedure to update the record and report on records
            -- updated and missed
    	    --

               update_report_exception
                 (p_datetrack_mode             	 => l_datetrack_mode
                 ,p_effective_date             	 => l_effective_date
                 ,p_placement_id               	 => LC_Placement_ID
                 ,p_object_version_number      	 => LC_Object_Version_Number
                 ,p_increment_number           	 => l_increment
                 ,p_reason                     	 => l_reason
                 ,p_effective_start_date       	 => LC_Effective_Start_Date
                 ,p_assignment_id              	 => LC_Assignment_ID
                 ,p_parent_spine_id            	 => LC_Parent_Spine_ID
                 ,p_spinal_point_id            	 => LC_Spinal_Point_ID
                 ,p_rate_id                    	 => p_rate_id
                 ,p_lc_step_id                 	 => LC_Step_ID
                 ,p_exception_report1          	 => l_exception_report1
                 ,p_end_date                   	 => L_End_Date
                 ,p_orig_increment_number     	 => LC_Increment_Number
                 ,p_sequence_number            	 => LC_Sequence_Number
                 ,p_grade_spine_id             	 => l_grade_spine_id
                 ,p_update                     	 => l_update
                 ,p_max_special_sequence_number  => l_max_special_sequence_number
                 ,p_max_special_spinal_point     => l_max_special_spinal_point_id
		 ,p_max_sequence_number          => l_max_sequence_number
                 ,p_max_spinal_point             => l_max_spinal_point_id);

                 l_exception_report1 := 'N';

            END LOOP;

   	 Elsif l_br_flag = TRUE then

	    -- ================================================================================
	    -- Business Rule Processing
	    -- ================================================================================

	    if to_date(to_char(p_br_date_to,'YYYY'),'YYYY') > to_date(to_char(p_br_date_from,'YYYY'),'YYYY') then

		hr_utility.set_location('Setting new Business Rule dates',1);

		l_year_from_temp := substr(to_char(p_br_date_from,'DD-MM-RRRR'),6,5); -- Year to
		hr_utility.set_location(l_year_from_temp,1);

		l_br_date_to_temp1 := '31-12'||l_year_from_temp;
		hr_utility.set_location(l_br_date_to_temp1,1);

		l_year_to_temp := substr(to_char(p_br_date_to,'DD-MM-RRRR'),6,5); -- Year from
		hr_utility.set_location(l_year_to_temp,2);

		l_br_date_from_temp1 := '01-01'||l_year_to_temp;
                hr_utility.set_location(l_br_date_from_temp1,2);

		l_year_loop := 'Y';

	    else

		   l_year_loop := 'N';
		   l_year_loop_count := 2;

	    end if;

	    LOOP
         -- Year wrap issue, set the effective dates accordingly
		 -- The reason ther is a problem is that you cant determine which year to look
		 -- up a date, so the process has to devide into two sections, run through once
		 -- for the end of the first year and then again for the start of the second year

		if l_year_loop = 'Y' and l_year_loop_count = 1 then

		   hr_utility.set_location('== p_br_date_from == '||p_br_date_from,3);
		   hr_utility.set_location('== l_br_date_to_temp1 == '||l_br_date_to_temp1,3);
		   l_br_date_from := to_date(to_char(p_br_date_from,'DD-MM-RRRR'),'DD-MM-RRRR');
		   l_br_date_to   := to_date(l_br_date_to_temp1,'DD-MM-RRRR');
		   l_year_temp    := l_year_from_temp;

		elsif l_year_loop = 'Y' and l_year_loop_count = 2 then

		   l_br_date_from := to_date(l_br_date_from_temp1,'DD-MM-RRRR');
		   l_br_date_to   := to_date(to_char(p_br_date_to,'DD-MM-RRRR'),'DD-MM-RRRR');
		   l_year_temp    := l_year_to_temp;

		else

		  l_br_date_from := p_br_date_from;
		  l_br_date_to   := p_br_date_to;
		  l_year_temp    := substr(to_char(p_br_date_from,'DD-MM-RRRR'),6,5);

		end if;


	      hr_utility.set_location('Business Rule Set +++++++++++',10);

              open csr_assignment_business_rule;

	    LOOP

            -- ================================================================================
	    -- First find all the people who have a grade step placement for the business group
            -- ================================================================================

	         hr_utility.set_location('p_business_rule - '||p_business_rule,10);
             hr_utility.set_location('p_br_date_from - '||l_br_date_from,10);
             hr_utility.set_location('p_br_date_to - '||l_br_date_to,10);
             hr_utility.set_location('p_year_from - '||p_year_from,10);
             hr_utility.set_location('p_year_to - '||p_year_to,10);
	         hr_utility.set_location('l_year_temp - '||l_year_temp,10);
             hr_utility.set_location('l_earliest_start_date - '||to_char(l_earliest_start_date,'DD-MM-YYYY'),10);

	      fetch csr_assignment_business_rule into l_br_assignment_id,
						      l_br_date_of_birth,
						      l_br_annivarsary_of_joining,
						      l_br_latest_hire_date,
						      l_br_adjusted_svc_date,
						      l_payroll_id;

	      if csr_assignment_business_rule%notfound then

		-- Last record has been already fetched so set all variables to null so that when they are
  		-- compared later they will differ, as values currently will match

		l_br_assignment_id := null;
		l_br_date_of_birth := null;
                l_br_annivarsary_of_joining := null;
                l_br_latest_hire_date := null;
                l_br_adjusted_svc_date := null;
		l_payroll_id := null;

	      end if;

             hr_utility.set_location('l_br_assignment_id,'||l_br_assignment_id,15);
             hr_utility.set_location('l_br_date_of_birth,'||l_br_date_of_birth,15);
             hr_utility.set_location('l_br_annivarsary_of_joining,'||l_br_annivarsary_of_joining,15);
             hr_utility.set_location('l_br_latest_hire_date,'||l_br_latest_hire_date,15);
             hr_utility.set_location('l_br_adjusted_svc_date,'||l_br_adjusted_svc_date,15);
             hr_utility.set_location('l_copy_br_assignment_id = '||l_copy_br_assignment_id,16);
             hr_utility.set_location('l_br_assignment_id = '||l_br_assignment_id,16);

		l_br_update := 'N';

	      if l_first_call_flag = FALSE then

		hr_utility.set_location('l_first_call_flag = FALSE',20);

                -- Check if the next record has the same assignment id

                if l_copy_br_assignment_id = l_br_assignment_id then

		hr_utility.set_location('Assignments Match - Duplicates',25);

                   l_duplicate_flag := TRUE;

                else

                hr_utility.set_location('Assignments Don''t Match - No Duplicates',25);

                   l_duplicate_flag := FALSE;
	           l_br_update := 'Y';

                end if;

		-- ================================================================================
		-- Find out the business rule being used and set the effetive date accordingly
		-- ================================================================================

		   if p_business_rule = 'DOB' then -- ** DATE OF BIRTH ** --

		   hr_utility.set_location('p_business_rule - '||p_business_rule,30);

		      if l_duplicate_flag = TRUE
			and l_copy_br_date_of_birth <> l_br_date_of_birth then

			 l_br_update := 'N';
			 l_duplicate_error_flag := TRUE; -- Incase next record is same assignment

		      end if;

		      -- Check that the date of birth is not null
		      if l_copy_br_date_of_birth is null then

			 l_br_update := 'N';

		      else

                     	 l_effective_date := l_copy_br_date_of_birth;

                      end if;

              	   elsif p_business_rule = 'AOJ' then -- ** ANNIVERSARY OF JOINING ** --

                   hr_utility.set_location('p_business_rule - '||p_business_rule,30);

                     if l_duplicate_flag = TRUE
                        and l_copy_br_anniv_of_joining <> l_br_annivarsary_of_joining then

			 hr_utility.set_location('Anniversary Of Joining Changed!',1);
                         l_br_update := 'N';
                         l_duplicate_error_flag := TRUE; -- Incase next record is same assignment

		     end if;

                       l_effective_date := l_copy_br_anniv_of_joining;

              	   elsif p_business_rule = 'ASD' then -- ** ADJUSTED SERVICE DATE ** --

                   hr_utility.set_location('p_business_rule - '||p_business_rule,30);

		     if l_duplicate_flag = TRUE
                        and l_copy_br_adjusted_svc_date <>l_br_adjusted_svc_date then

                         l_br_update := 'N';
                         l_duplicate_error_flag := TRUE; -- Incase next record is same assignment

                     end if;

                       -- Check that the adjusted service date is not null

                       if l_copy_br_adjusted_svc_date is null then

                     	 l_br_update := 'N';

                       else

                     	 l_effective_date := l_copy_br_adjusted_svc_date;

                       end if;

                    elsif p_business_rule = 'LHD' then -- ** LATEST HIRE DATE ** --

                   hr_utility.set_location('p_business_rule - '||p_business_rule,30);

                     if l_duplicate_flag = TRUE
                        and l_copy_br_latest_hire_date <> l_br_latest_hire_date then

			 hr_utility.set_location('Duplicate but Latest Hire Date Changed',1);
                         l_br_update := 'N';
                         l_duplicate_error_flag := TRUE; -- Incase next record is same assignment

                     end if;

                       l_effective_date := l_copy_br_latest_hire_date;

              	    else

			-- Invalid Business Rule
				hr_utility.set_location('Invalid Business Rule',1);

			    fnd_message.set_name('PER', 'HR_289507_SPP_BR_INVALID');
    			    hr_utility.raise_error;

		    end if;


		-- ==================================================================================================
		-- Check if the from and to date wrap over a year, if so get the appropiate year for employee
		-- ==================================================================================================

		l_temp_year := to_char(l_effective_date,'DD/MM')||'/';
                if l_temp_year = '29/02/' then
                   l_effective_date := l_effective_date + 1;
                end if;
		if to_date(to_char(p_br_date_to,'YYYY'),'YYYY') > to_date(to_char(p_br_date_from,'YYYY'),'YYYY') then

		   hr_utility.set_location('Business Rule Dates Over Two Years',31);

		   -- use l_effective_year for l_br_date_from year
		   -- and l_effective_month for l_br_date_to year
		   -- and l_temp_year for l_effective_date
		   l_effective_year := to_char(p_br_date_from, 'YYYY');
		   l_effective_month := to_char(p_br_date_to, 'YYYY');
		   l_temp_year := to_char(l_effective_date,'DD/MM')||'/';

		   hr_utility.set_location('l_temp_year '||l_temp_year,75);

		   if to_date(l_temp_year||l_effective_year,'DD-MM-YYYY') >= p_br_date_from then

			hr_utility.set_location('End of year',31);

			l_effective_year := to_char(p_br_date_from,'YYYY');
                   	l_effective_month := to_char(l_effective_date,'DD/MM')||'/';
                   	l_temp_year := l_effective_month||l_effective_year;

			l_effective_date := to_date(l_temp_year,'DD/MM/YYYY');

		   elsif to_date(l_temp_year||l_effective_month,'DD-MM-YYYY') <= p_br_date_to then

			hr_utility.set_location('Start of year',31);

                        l_effective_year := to_char(p_br_date_to,'YYYY');
                        l_effective_month := to_char(l_effective_date,'DD/MM')||'/';
                        l_temp_year := l_effective_month||l_effective_year;

			l_effective_date := to_date(l_temp_year,'DD/MM/YYYY');

		   end if;

		elsif to_date(to_char(p_br_date_to,'YYYY'),'YYYY') = to_date(to_char(p_br_date_from,'YYYY'),'YYYY') then

		   hr_utility.set_location('Business Rule Over One Year',31);

		   l_effective_year := to_char(p_br_date_from,'YYYY');
		   l_effective_month := to_char(l_effective_date,'DD/MM')||'/';
		   l_temp_year := l_effective_month||l_effective_year;

		   hr_utility.set_location('l_temp_year '||l_temp_year,31);

		   l_effective_date := to_date(l_temp_year,'DD/MM/YYYY');

		end if;

		-- ===============================================================================
		-- Dependant Rule Date Set
		--
		-- Depending on the dependant date selected in the concurrent process set the
		-- effective date to use
		--
                -- ===============================================================================

		hr_utility.set_location('---------  Dependant Date Rule - '||p_dependant_date,32);

		if p_dependant_date = 'DD1' then -- ## Effective Date ##

                hr_utility.set_location('Dependant Date Rule - Effectvie Date',33);

		   l_effective_date := p_effective_date;

		elsif p_dependant_date = 'DD2' then -- ## Business Rule effective Date  ##

                hr_utility.set_location('Dependant Date Rule - Business Rule Effective Date',33);

		   l_effective_date := l_effective_date;

		elsif p_dependant_date = 'DD3' then -- ## Start Of Next Month ##

		hr_utility.set_location('Dependant Date Rule - Start Of Next Month',33);
		hr_utility.set_location('l_effective_date = '||l_effective_date,33);

		   l_effective_date := last_day(l_effective_date)+1;

		elsif p_dependant_date = 'DD4' then -- ## Start Of next pay period ##

		 hr_utility.set_location('Pay Period Dependant Date',33);

		   if l_copy_payroll_id is null then

		 	hr_utility.set_location('Null Payroll Id',33);

			l_update2 := 'N';
			l_exception_report2 := 'Y';

		   else

			l_update2 := 'Y';
                        l_exception_report2 := 'N';
			open csr_pay_period;
			fetch csr_pay_period into l_effective_date;
			close csr_pay_period;

		 	hr_utility.set_location('Payroll Exists - l_effective_date - '||l_effective_date,33);

		   end if;

		else

		   -- Invalid Dependant Date

		       fnd_message.set_name('PER', 'HR_289508_SPP_BR_DEP_DATE');
    		       hr_utility.raise_error;

 		end if; -- End of dependant date set

	      hr_utility.set_location('l_br_update - '||l_br_update,40);
	      hr_utility.set_location('++ New effective date - '||l_effective_date,40);

	    	if l_br_update = 'Y'

	 	  and l_duplicate_flag = FALSE
		  and l_duplicate_error_flag = FALSE then

		hr_utility.set_location('++++++++++++++ UPDATING ++++++++++++++++++',45);

            	-- ================================================================================
            	-- Call the main cursor to retrieve all information required - Assignment Id used
            	-- ================================================================================

           -- Open the correct cursor

             if (p_concat_segs is null) then
               open C_Spinal_Placements_Cursor;
            else
               open C_Key_Spinal_Placements_Cursor;
            end if;

		LOOP

            	if (p_concat_segs is null) then
                   --
                   -- fetch standard cursor, no group partial matching
                   --
                   hr_utility.set_location ('hrspine.spine', 52);
                   FETCH C_Spinal_Placements_Cursor
                   INTO  LC_Placement_ID,
                         LC_Step_ID,
                         LC_Assignment_ID,
                         LC_Auto_Increment_Flag,
                         LC_Spinal_Point_ID,
                         LC_Parent_Spine_ID,
                         LC_Sequence_Number,
                         LC_Increment_Number,
                         LC_Object_Version_Number,
                         LC_Effective_Start_Date,
                         L_End_Date,
                         l_grade_spine_id;

			l_message_number_count := l_message_number_count + 1;

                   EXIT when C_Spinal_Placements_Cursor%notfound;

                else
                   --
                   -- fetch key cursor, with group partial matching
                   --
                   hr_utility.set_location ('hrspine.spine', 6);
                   FETCH C_Key_Spinal_Placements_Cursor
                   INTO  LC_Placement_ID,
                         LC_Step_ID,
                         LC_Assignment_ID,
                         LC_Auto_Increment_Flag,
                         LC_Spinal_Point_ID,
                         LC_Parent_Spine_ID,
                         LC_Sequence_Number,
                         LC_Increment_Number,
                         LC_Object_Version_Number,
                         LC_Effective_Start_Date,
                         L_End_Date,
                         l_grade_spine_id;

 			l_message_number_count := l_message_number_count + 1;

                   EXIT when C_Key_Spinal_Placements_Cursor%notfound;
                end if;
                --
		hr_utility.set_location('Placement Found - '||LC_Placement_ID,45);
                hr_utility.set_location('############# Effective Date ###### '||l_effective_date,45);
                --
                -- Call the procedure to heck if assignment selected can be incremented
                --

                  check_increment_available
                    (p_placement_id                 => LC_Placement_ID
                    ,p_end_date                     => L_End_Date
                    ,p_effective_date               => l_effective_date
                    ,p_effective_start_date         => LC_Effective_Start_Date
                    ,p_datetrack_mode               => l_datetrack_mode
                    ,p_assignment_id                => LC_Assignment_ID
                    ,p_parent_spine_id              => LC_Parent_Spine_ID
                    ,p_grade_spine_id               => l_grade_spine_id
                    ,p_step_id                      => LC_Step_ID
                    ,p_sequence_number              => LC_Sequence_Number
                    ,p_increment_number             => LC_Increment_Number
                    ,p_exception_report1            => l_exception_report1
                    ,p_update                       => l_update
                    ,p_increment                    => l_increment
                    ,p_max_sequence_number          => l_max_sequence_number
                    ,p_max_special_sequence_number  => l_max_special_sequence_number
                    ,p_max_spinal_point_id          => l_max_spinal_point_id
                    ,p_max_special_spinal_point_id  => l_max_special_spinal_point_id );

                hr_utility.set_location('############# Effective Date ###### '||l_effective_date,45);

		    if l_update = 'N' or l_update2 = 'N' then

			l_update := 'N';

		    end if;

		    if l_exception_report1 = 'Y' or l_exception_report2 = 'Y' then

			l_exception_report1 := 'Y';

		    end if;
                --
                -- Call procedure to update the record and report on records
                -- updated and missed
                --

                   update_report_exception
                     (p_datetrack_mode               => l_datetrack_mode
                     ,p_effective_date               => l_effective_date
                     ,p_placement_id                 => LC_Placement_ID
                     ,p_object_version_number        => LC_Object_Version_Number
                     ,p_increment_number             => l_increment
                     ,p_reason                       => l_reason
                     ,p_effective_start_date         => LC_Effective_Start_Date
                     ,p_assignment_id                => LC_Assignment_ID
                     ,p_parent_spine_id              => LC_Parent_Spine_ID
                     ,p_spinal_point_id              => LC_Spinal_Point_ID
                     ,p_rate_id                      => p_rate_id
                     ,p_lc_step_id                   => LC_Step_ID
                     ,p_exception_report1            => l_exception_report1
                     ,p_end_date                     => L_End_Date
                     ,p_orig_increment_number        => LC_Increment_Number
                     ,p_sequence_number              => LC_Sequence_Number
                     ,p_grade_spine_id               => l_grade_spine_id
                     ,p_update                       => l_update
                     ,p_max_special_sequence_number  => l_max_special_sequence_number
                     ,p_max_special_spinal_point     => l_max_special_spinal_point_id
                     ,p_max_sequence_number          => l_max_sequence_number
                     ,p_max_spinal_point             => l_max_spinal_point_id);

                     l_exception_report1 := 'N';
                     l_duplicate_error_flag := FALSE;

		     END LOOP;

           -- close the correct cursor

             if (p_concat_segs is null) then
               close C_Spinal_Placements_Cursor;
            else
               close C_Key_Spinal_Placements_Cursor;
            end if;

		    end if; -- l_br_update = Y

	      else

		exit when csr_assignment_business_rule%notfound;

	      end if; -- l_first_call_flag

	  -- assign the new parameters to the copy local parameters so that
      -- when the loop start again
 	  -- the next record can be retrieved into the orginal parameters

                  l_copy_br_assignment_id       := l_br_assignment_id;
                  l_copy_br_date_of_birth       := l_br_date_of_birth;
                  l_copy_br_anniv_of_joining    := l_br_annivarsary_of_joining;
                  l_copy_br_latest_hire_date    := l_br_latest_hire_date;
                  l_copy_br_adjusted_svc_date   := l_br_adjusted_svc_date;
		  l_copy_payroll_id		:= l_payroll_id;


	    if l_first_call_flag = TRUE then

		l_first_call_flag := FALSE;

	    else

            	exit when csr_assignment_business_rule%notfound;

	    end if;

            END LOOP;

	        close csr_assignment_business_rule;

		l_first_call_flag := TRUE;

		exit when l_year_loop_count = 2;

		l_year_loop_count := l_year_loop_count + 1;

	    END LOOP;  -- Year wrap issue


	 End if;

          -- -----------------------------------------------------------
          -- set last auto inc. date on parent spine
          -- -----------------------------------------------------------
            hr_utility.set_location ('hrspine.spine', 11);
            UPDATE per_parent_spines
            SET    last_automatic_increment_date = P_Effective_Date,
                   last_update_date              = sysdate,
                   program_update_date           = sysdate
            WHERE  parent_spine_id               = P_Parent_Spine_ID;
            --
	    -- Set the out parameter
            --
	    if l_message_number_count = 0 then
           --
		   p_message_number := 'PER_289573_SPP_NO_DATA';
                hr_utility.set_location ('officially no data.spine', 11);
        --
	    else
        --
		   p_message_number := null;
           hr_utility.set_location ('hrspine.spine shd be sweet', 11);
	    end if;
        hr_utility.set_location ('hrspine.spine', 12);
        --
END spine;
--
END hrspine;

/
