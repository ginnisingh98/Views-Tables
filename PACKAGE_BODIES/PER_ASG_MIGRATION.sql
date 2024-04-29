--------------------------------------------------------
--  DDL for Package Body PER_ASG_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASG_MIGRATION" AS
/* $Header: peasgmig.pkb 115.1 2003/12/08 08:18:57 adhunter noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< migrateAsgProjAsgEnd >------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates a chunk of Assignment records, populating the column
--   projected_assignment_end from values in per_periods_of_placement.
--
--  Don't update the row if there is any DT instance for this PKid or any in the
-- same placement which have projected_assignment_end populated with non-null value
--
--  Update if all DT instances are null with projected_placement_end_date
--
procedure migrateAsgProjAsgEnd(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number) IS
--
TYPE dateTab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE personidTab IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE projectedEndDateTab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
--
startDates dateTab;
personIds  personidTab;
projDates  projectedEndDateTab;
--
cursor csr_projected_end is
select date_start,person_id,projected_termination_date
from   per_periods_of_placement
where  period_of_placement_id between p_start_pkid and p_end_pkid
and    projected_termination_date is not null;
--
l_rows_processed number := 0;
--
BEGIN
  --
  open csr_projected_end;
  fetch csr_projected_end BULK COLLECT INTO startDates,personIds,projDates;
  --
  if personIds.COUNT > 0 then
    FORALL i in personIds.FIRST..personIds.LAST
    update per_all_assignments_f paf1
    set    paf1.projected_assignment_end = projDates(i)
    where  paf1.period_of_placement_date_start = startDates(i)
    and    paf1.person_id = personIds(i)
    and    not exists (select null
		       from   per_all_assignments_f paf2
		       where  paf1.assignment_id
			    = paf2.assignment_id
		       and    paf2.projected_assignment_end is not null);
    --
    l_rows_processed := SQL%ROWCOUNT;
    --
  end if;
  close csr_projected_end;
END migrateAsgProjAsgEnd;

end per_asg_migration;

/
