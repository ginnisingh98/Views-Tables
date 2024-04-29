--------------------------------------------------------
--  DDL for Package Body HR_LEAVING_REASON_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEAVING_REASON_MIG" as
/* $Header: pelearea.pkb 115.4 2002/12/06 11:14:44 pkakar noship $ */

-- Package Variables
--
   g_package  varchar2(33) := 'hr_leaving_reason_mig. ';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_LEAVING_REASON >------------------------|
-- ----------------------------------------------------------------------------
--
procedure leave_reas_mig
(ERRBUF                         out nocopy             varchar2
,RETCODE                        out nocopy             number
,p_existing_leaving_reason	in 		VARCHAR2
,p_seeded_leaving_reason	in 		VARCHAR2
,p_date				in	        varchar2)

 IS
  --
  -- Declare cursors and local variables
  --
  l_proc                     VARCHAR2(72) := g_package||'leave_reas_mig';
  l_leaving_reason           VARCHAR(30)  := p_seeded_leaving_reason;
  l_object_version_number    per_periods_of_service.object_version_number%TYPE;
  l_count		     NUMBER       := 0;
  l_total_records            NUMBER;
  l_effective_date           DATE        := fnd_date.canonical_to_date(p_date);
  --
 -- The following cursor selects all the employee's what have a specific leaving
 -- reason, which has been specified by the customer when running the concurrent
 -- program.
 --

  cursor csr_pds is
     select pos.period_of_service_id , pos.object_version_number
     from   per_periods_of_service pos
     where  pos.leaving_reason = p_existing_leaving_reason
     order  by pos.period_of_service_id;

  --

begin

  hr_utility.set_location('Entering:'||l_proc, 10);
  hr_utility.set_location('Existing Leaving Reason = '||p_existing_leaving_reason, 20);
  hr_utility.set_location('Seeded Leaving Reason   = '||p_seeded_leaving_reason, 25);
--
  ERRBUF  := NULL;
  RETCODE := 0;

  for pds_rec in csr_pds Loop
  --
  l_total_records := csr_pds%rowcount;

  l_object_version_number := pds_rec.object_version_number;
  hr_utility.set_location('Period_of_service_id = '|| pds_rec.period_of_service_id, 30);
  --
  l_count := l_count + 1;
  --
       hr_periods_of_service_api.update_pds_details(
        p_effective_date        => l_effective_date
       ,p_period_of_service_id  => pds_rec.period_of_service_id
       ,p_object_version_number => l_object_version_number
       ,p_leaving_reason	=> p_seeded_leaving_reason
       );

  	--
	if l_count = 100 then
	   commit;
   	   hr_utility.set_location('Committed : '||l_count||' records.', 40);
	   l_count := 0;
	end if;
  	--
  --

  End loop;
  --
  hr_utility.set_location('Total records: '||l_total_records||' records.', 50);
  --
  hr_utility.set_location('Updating lookup table : FND_LOOKUP_VALUES', 60);

    Update fnd_lookup_values
    set end_date_active = l_effective_date, enabled_flag = 'N'
    where lookup_type = 'LEAV_REAS'
    and lookup_code = p_existing_leaving_reason;
  --
  hr_utility.set_location('Updated lookup table : FND_LOOKUP_VALUES', 60);
  --
   -- the following is a migration of the ZA_TERMINATION_CATEGORIES
 --
   if hr_general2.is_legislation_install('PER','ZA') then
	--
        hr_utility.set_location('    Entering ZA Migration ', 70);
        --
 	  per_za_utility_pkg.za_term_cat_update(
 	  p_existing_leaving_reason =>  p_existing_leaving_reason
 	 ,p_seeded_leaving_reason   =>  p_seeded_leaving_reason
         );
	--
         hr_utility.set_location('    Leaving ZA Migration ', 70);
   --
   end if;

 --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End leave_reas_mig;
end HR_LEAVING_REASON_MIG;

/
