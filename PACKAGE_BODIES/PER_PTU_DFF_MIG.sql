--------------------------------------------------------
--  DDL for Package Body PER_PTU_DFF_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PTU_DFF_MIG" AS
/* $Header: peptumig.pkb 120.0 2005/05/31 15:56:30 appldev noship $ */
--
-- Declare the TABLE TYPEs.
--
TYPE MIG_TAB_TYPE IS TABLE OF PER_ALL_PEOPLE_F%ROWTYPE INDEX BY BINARY_INTEGER;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< initialization >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE initialization(p_payroll_action_id in number)
is
begin
 --
 -- Set WHO column globals...
 --
 g_program_id := fnd_profile.value('CONC_PROGRAM_ID');
 g_request_id := fnd_profile.value('CONC_REQUEST_ID');
 g_program_application_id := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
 g_update_date := trunc(sysdate);
 --
end initialization;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< submit_migration >----------------------------|
-- ----------------------------------------------------------------------------
--
-- The procedure is the main procedure called by migration concurent program
--
PROCEDURE submit_migration(errbuf              out NOCOPY varchar2,
                           retcode             out NOCOPY number,
                           p_business_group_id number
                          -- p_report_mode       varchar2
                          ) is
  --
  l_business_group_id  number;
  l_report_mode        varchar2(100) := 'ALL'; -- Default is to run for ALL.
  l_count1             number;
  l_count2             number;
  l_count3             number;
  l_effective_date     date;
  l_request_id         number;
  l_request_data varchar2(100);
  l_status       varchar2(100);
  l_phase        varchar2(100);
  l_dev_status   varchar2(100);
  l_dev_phase    varchar2(100);
  l_message      varchar2(100);
  l_call_status boolean;
  --
  l_error_desc         varchar2(1000);
  l_prev_mig_successful varchar2(1) := 'N';
  --
  cursor csr_is_alrady_run_for_bg(p_business_group_id number) IS
  select ERROR_DESCRIPTION
  from   PER_PTU_DFF_MIG_FAILED_PEOPLE
  where  nvl(business_group_id,-1) = nvl(p_business_group_id,-1)
  and    person_id = hr_api.g_number;
  --
  cursor csr_prev_run_all_bgs IS
  select ERROR_DESCRIPTION
  from   PER_PTU_DFF_MIG_FAILED_PEOPLE
  where  person_id = hr_api.g_number
  and    business_group_id is null;
  --
BEGIN
     --
     -- Check for re-start status
     --
     l_request_data := fnd_conc_global.request_data;
     --
     --
     if l_request_data is not null then
       --
       fnd_file.put_line(fnd_file.log,'restart' );
       --
       l_call_status :=  fnd_concurrent.get_request_status(
   				           request_id => l_request_data,
                           phase    => l_phase,
                           status   => l_status,
                           dev_phase => l_dev_phase,
                           dev_status => l_dev_status,
                           message    => l_message);
       --
       if l_dev_phase = 'COMPLETE' and l_dev_status = 'ERROR' then
         errbuf := l_message;
         retcode := 2;
       else
         retcode := 0;
       end if;
       --
       return;
       --
     end if;
     --
     -- Intialize local variables
     --
     l_business_group_id := p_business_group_id;
    -- l_report_mode       := p_report_mode;
     l_effective_date    := trunc(sysdate);
     --
     -- Set the report mode by checking the data in
     -- table PER_PTU_DFF_MIG_FAILED_PEOPLE.
     --
     open csr_is_alrady_run_for_bg(l_business_group_id);
     fetch csr_is_alrady_run_for_bg into l_error_desc;
     if csr_is_alrady_run_for_bg%found then
       --
       -- For the given bg, the migration was completed previously
       -- Check for the status of previous run.
       --
       IF l_error_desc = 'FAILED' then
         --
         -- In the previous run the migration was failed for this bg.
         -- So, now process only failed records in this bg.
         --
         l_report_mode := 'FAILED';
         --
       ELSIF l_error_desc = 'SUCCESS' then
         --
         -- In the previous run the migration was successful
         -- for this bg. Therefore no need to run the process again.
         -- Set the exit flag.
         --
         l_prev_mig_successful := 'Y';
         --
       END IF;
       --
     else
       --
       -- NO previous run was submitted for this BG.
       -- This is first time the concurrent request is submitted
       -- for this BG. Check if there is a previous request for all
       -- BGs(i.e with Bg as null) and the status of that previous run (for all BGs).
       -- If the previous run for all BGs is completed successfully,
       -- then no need to run this request. If not, run for the failed
       -- people in this bg.
       --
       open  csr_prev_run_all_bgs;
       fetch csr_prev_run_all_bgs into l_error_desc;
       if csr_prev_run_all_bgs%found then
         --
         -- There is a previous run for all BGs.
         --
         if l_error_desc = 'SUCCESS' then
           --
           -- The previous run for all the BGs was successful
           -- Therefore no need to run this request.
           --
           l_prev_mig_successful := 'Y';
           --
         elsif l_error_desc = 'FAILED' then
           --
           -- The previous run for all BGs was failed
           -- Therefore run for the failed persons in this BG.
           --
           l_report_mode := 'FAILED';
           --
         end if;
         --
       else
         --
         -- There is no previous request for all BGs (i.e with BG as null).
         -- Therefore process all the persons in this BG.
         l_report_mode := 'ALL';
         --
       end if;
       --
     end if;
     --
     close csr_is_alrady_run_for_bg;
     --
     --
     -- Check whether the mapping tables have the mappings data.
     --
     SELECT COUNT(*)
     INTO   l_count1
     FROM   PER_PTU_DFF_MAPPING_HEADERS;
     --
     -- Validate that mapping is complete.
     --
     SELECT COUNT(*)
     INTO   l_count2
     FROM   PER_PTU_DFF_MAPPING_HEADERS
     WHERE  DATA_MAPPING_COMPLETE = 'N';
     /*
     --
     -- check if all the contexts are migrated.
     --
     SELECT COUNT(*)
     INTO   l_count3
     FROM   PER_PTU_DFF_MAPPING_HEADERS
     WHERE  nvl(MIGRATION_STATUS,'PENDING') = 'COMPLETE';
     */
     --
     IF l_prev_mig_successful = 'Y' THEN
       --
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'For the selected business group, the migration has already completed successfully.');
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'You cannot repeat the migration process.');
       --
       -- mark the request as warning.
       --
       retcode := 1;
       --
     ELSIF l_count1 = 0 OR l_count2 <> 0 THEN
        --
	--
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'You must map all Person DFF contexts that need migration');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'before you start the migration process.');
        --
        -- Fix for bug 4018678. Mark the request as errored.
        --
        retcode := 2;
        --
     /*
     ELSIF l_count3 <> 0 THEN
        --
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Person DFF data for all the Persons is already migrated.');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'No need to run the migration process again.');
        --
     */
     ELSE
        --
        l_request_id := fnd_request.submit_request(application => 'PER',
                                program     => 'PER_PTU_DFF_MIG',
                                sub_request => TRUE,
				argument1   => 'ARCHIVE',
				argument2   => 'PEPTUDFFMIG',
				argument3   => 'HR_PROCESS',
				argument4   => l_effective_date,
				argument5   => l_effective_date,
				argument6   => 'PROCESS',
				argument7   => fnd_profile.value('PER_BUSINESS_GROUP_ID'),
				argument8   => null,
				argument9   => null,
				argument10   => 'REPORT_MODE='||l_report_mode,
				argument11  => 'BUSINESS_GROUP_ID='||l_business_group_id);
       --
       -- set pause status for the main concurrent request until the child completes.
       --
       if l_request_id = 0 then
         --
      	 errbuf := fnd_message.get;
         retcode := 2;
         --
       else
         --
         fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                     request_data=> l_request_id );
         retcode := 0;
   	     --
       end if;
       --
     END IF;
END;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< range_cursor >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure contains the cursor definition required to populate the
-- PAY_POPULATION_RANGES table.
--
PROCEDURE range_cursor (pactid in number, sqlstr out NOCOPY varchar2) is
 --
 l_report_mode varchar2(100);
 l_business_group_id  number;
 --
BEGIN
--
   SELECT pay_core_utils.get_parameter('REPORT_MODE', ppa.legislative_parameters),
          pay_core_utils.get_parameter('BUSINESS_GROUP_ID', ppa.legislative_parameters)
   INTO l_report_mode, l_business_group_id
   FROM pay_payroll_actions ppa
   WHERE ppa.payroll_action_id = pactid;
   --
   IF  (l_report_mode = 'ALL') THEN
    --
    -- Run for all records.
    --
    sqlstr := 'SELECT    DISTINCT PERSON_ID
        FROM      PER_ALL_PEOPLE_F PPF
                 ,pay_payroll_actions ppa
        WHERE ppa.payroll_action_id = :payroll_action_id
       AND   PPF.BUSINESS_GROUP_ID
                = NVL(pay_core_utils.get_parameter(''BUSINESS_GROUP_ID'', ppa.legislative_parameters), PPF.BUSINESS_GROUP_ID)
       ORDER BY PPF.PERSON_ID';
    --
  ELSIF (l_report_mode = 'FAILED') THEN
    --
    -- Run for failed records
    --
    sqlstr := 'SELECT DISTINCT PERSON_ID
               FROM   PER_PTU_DFF_MIG_FAILED_PEOPLE PPF
                     ,pay_payroll_actions ppa
               WHERE ppa.payroll_action_id = :payroll_action_id
               AND  PPF.ERROR_DESCRIPTION <> ''SUCCESS''
               AND PPF.BUSINESS_GROUP_ID
               = NVL(pay_core_utils.get_parameter(''BUSINESS_GROUP_ID'', ppa.legislative_parameters), PPF.BUSINESS_GROUP_ID)
               ORDER BY PPF.PERSON_ID';
    --
  END IF;
--
END range_cursor;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< action_creation >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure contains the code required to populate the
-- PAY_ASSIGNMENT_ACTIONS table.
--
------------------------------------------------------------------------------------
PROCEDURE action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is
  --
  -- Fix for bug 4027193. Only select persons who are in unsuccessful
  -- migration business groups.
  --
  CURSOR csr_process_all(p_business_group_id number) IS
  SELECT DISTINCT PPF.PERSON_ID PERSON_ID
  FROM   PER_ALL_PEOPLE_F  PPF
  	,pay_payroll_actions ppa
  WHERE  PPF.PERSON_ID BETWEEN STPERSON AND ENDPERSON
  AND    ppa.payroll_action_id = pactid
  AND    ppf.business_group_id = nvl(p_business_group_id,ppf.business_group_id)
  AND    ppf.business_group_id not in
         (select nvl(business_group_id,-1)
          from PER_PTU_DFF_MIG_FAILED_PEOPLE
          where ERROR_DESCRIPTION = 'SUCCESS'
          AND   PERSON_ID = hr_api.g_number)
  AND   (PPF.ATTRIBUTE1 IS NOT NULL OR
         PPF.ATTRIBUTE2 IS NOT NULL OR
	 PPF.ATTRIBUTE3 IS NOT NULL OR
	 PPF.ATTRIBUTE4 IS NOT NULL OR
	 PPF.ATTRIBUTE5 IS NOT NULL OR
	 PPF.ATTRIBUTE6 IS NOT NULL OR
	 PPF.ATTRIBUTE7 IS NOT NULL OR
	 PPF.ATTRIBUTE8 IS NOT NULL OR
	 PPF.ATTRIBUTE9 IS NOT NULL OR
	 PPF.ATTRIBUTE10 IS NOT NULL OR
	 PPF.ATTRIBUTE11 IS NOT NULL OR
	 PPF.ATTRIBUTE12 IS NOT NULL OR
	 PPF.ATTRIBUTE13 IS NOT NULL OR
	 PPF.ATTRIBUTE14 IS NOT NULL OR
	 PPF.ATTRIBUTE15 IS NOT NULL OR
	 PPF.ATTRIBUTE16 IS NOT NULL OR
	 PPF.ATTRIBUTE17 IS NOT NULL OR
	 PPF.ATTRIBUTE18 IS NOT NULL OR
	 PPF.ATTRIBUTE19 IS NOT NULL OR
	 PPF.ATTRIBUTE20 IS NOT NULL OR
	 PPF.ATTRIBUTE21 IS NOT NULL OR
	 PPF.ATTRIBUTE22 IS NOT NULL OR
	 PPF.ATTRIBUTE23 IS NOT NULL OR
	 PPF.ATTRIBUTE24 IS NOT NULL OR
	 PPF.ATTRIBUTE25 IS NOT NULL OR
	 PPF.ATTRIBUTE26 IS NOT NULL OR
	 PPF.ATTRIBUTE27 IS NOT NULL OR
	 PPF.ATTRIBUTE28 IS NOT NULL OR
	 PPF.ATTRIBUTE29 IS NOT NULL OR
         PPF.ATTRIBUTE30 IS NOT NULL)
  ORDER BY PPF.PERSON_ID;
--
CURSOR csr_process_failed(p_business_group_id number) IS
SELECT  DISTINCT PPF.PERSON_ID PERSON_ID
FROM    PER_PTU_DFF_MIG_FAILED_PEOPLE PPF
WHERE   PPF.BUSINESS_GROUP_ID = NVL(p_business_group_id, PPF.BUSINESS_GROUP_ID)
AND     PPF.ERROR_DESCRIPTION <> 'SUCCESS'
ORDER BY PPF.PERSON_ID;
--
lockingactid number;
l_business_group_id number;
l_report_mode varchar2(100);

BEGIN
  --
  SELECT pay_core_utils.get_parameter('REPORT_MODE', ppa.legislative_parameters),
          pay_core_utils.get_parameter('BUSINESS_GROUP_ID', ppa.legislative_parameters)
   INTO l_report_mode,l_business_group_id
   FROM pay_payroll_actions ppa
   WHERE ppa.payroll_action_id = pactid;
   --
   -- Run for all
   --
  IF  (l_report_mode = 'ALL') THEN
    FOR per_rec in csr_process_all(l_business_group_id) LOOP
     --
     -- Create the assignment action to represnt the person combination.
     --
     SELECT PAY_ASSIGNMENT_ACTIONS_S.NEXTVAL
       INTO LOCKINGACTID
       FROM DUAL;
      --
      -- insert into pay_assignment_actions.
      --
      hr_nonrun_asact.insact(lockingactid => lockingactid,
                             assignid     => -1,
                             pactid       => pactid,
			     chunk        => chunk,
			     greid        => null,
			     object_id    => per_rec.person_id,
		             object_type  => 'PER_ALL_PEOPLE_F');
    END LOOP;
    --
  ELSIF (l_report_mode = 'FAILED') THEN
    --
    -- Run for failed records
    --
    FOR per_rec in csr_process_failed(l_business_group_id) LOOP
     --
     -- Create the assignment action to represnt the person combination.
     --
     SELECT PAY_ASSIGNMENT_ACTIONS_S.NEXTVAL
       INTO LOCKINGACTID
       FROM DUAL;
      --
      -- insert into pay_assignment_actions.
      --
      hr_nonrun_asact.insact(lockingactid => lockingactid,
                             assignid     => -1,
                             pactid       => pactid,
			     chunk        => chunk,
			     greid        => null,
			     object_id    => per_rec.person_id,
		             object_type  => 'PER_ALL_PEOPLE_F');
   END LOOP;
   --
 END IF;
 --
END action_creation;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< retrive_mapping >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Mapping function which take the p_mig_rec record along with the
-- attribte_category and returns a ptu dff attribute data record.
--
-- For composite person contexts like EMP_APL, if p_mig_rec attribute_category
-- is EMP, then we need to send the values of only PTU_ATTRIBUTES which are
-- defined for basic EMP Attribute in the mapping form.
--
FUNCTION RETRIVE_MAPPING(p_mig_rec PER_ALL_PEOPLE_F%ROWTYPE,
                         p_person_rec_context varchar2)
RETURN PER_PERSON_TYPE_USAGES_F%ROWTYPE
IS
  --
  TYPE ATTR_TABLE_TYPE IS TABLE OF PER_PTU_DFF_MAPPING_LINES%ROWTYPE
          INDEX BY BINARY_INTEGER;
  --
  l_attr_table ATTR_TABLE_TYPE;
  --
  TYPE PER_DATA_TABLE_TYPE IS TABLE OF PER_ALL_PEOPLE_F.ATTRIBUTE1%TYPE
                               INDEX BY BINARY_INTEGER;
  --
  l_per_data_table PER_DATA_TABLE_TYPE;
  --
  l_ptu_attrs_data_rec PER_PERSON_TYPE_USAGES_F%ROWTYPE ;
  --
BEGIN
  --
  -- Populate the mapping table.
  --
  FOR attr_rec IN (SELECT H.PER_DFF_CONTEXT_FIELD_CODE,
      	      	          L.PER_DFF_ATTRIBUTE,
		          L.PTU_DFF_CONTEXT_FIELD_CODE,
		          L.PTU_DFF_ATTRIBUTE,
   		          TO_NUMBER (SUBSTR (L.PER_DFF_ATTRIBUTE,10)) ATTRIBUTE_NUM
                    FROM  PER_PTU_DFF_MAPPING_HEADERS H,
		          PER_PTU_DFF_MAPPING_LINES L
                    WHERE H.MAPPING_HEADER_ID = L.MAPPING_HEADER_ID
		    AND   H.DATA_MAPPING_COMPLETE = 'Y'
                    AND   H.PER_DFF_CONTEXT_FIELD_CODE =
                               NVL (p_person_rec_context, 'Global Data Elements')
	            AND   L.PTU_DFF_CONTEXT_FIELD_CODE in
                           (p_mig_rec.attribute_category, 'Global Data Elements')
                    ORDER BY ATTRIBUTE_NUM)
  LOOP
    --
    -- Populate PLSQL table with user defined mapping for the given context
    -- and 'Global Attributes' with table index as Person DFF Attribute Number.
    --
    l_attr_table(attr_rec.ATTRIBUTE_NUM).PER_DFF_ATTRIBUTE := attr_rec.PER_DFF_ATTRIBUTE;
    l_attr_table(attr_rec.ATTRIBUTE_NUM).PTU_DFF_CONTEXT_FIELD_CODE := attr_rec.PTU_DFF_CONTEXT_FIELD_CODE;
    l_attr_table(attr_rec.ATTRIBUTE_NUM).PTU_DFF_ATTRIBUTE := attr_rec.PTU_DFF_ATTRIBUTE;
    --
  END LOOP;
  --
  l_per_data_table(1)  := p_mig_rec.attribute1;
  l_per_data_table(2)  := p_mig_rec.attribute2;
  l_per_data_table(3)  := p_mig_rec.attribute3;
  l_per_data_table(4)  := p_mig_rec.attribute4;
  l_per_data_table(5)  := p_mig_rec.attribute5;
  l_per_data_table(6)  := p_mig_rec.attribute6;
  l_per_data_table(7)  := p_mig_rec.attribute7;
  l_per_data_table(8)  := p_mig_rec.attribute8;
  l_per_data_table(9)  := p_mig_rec.attribute9;
  l_per_data_table(10) := p_mig_rec.attribute10;
  l_per_data_table(11) := p_mig_rec.attribute11;
  l_per_data_table(12) := p_mig_rec.attribute12;
  l_per_data_table(13) := p_mig_rec.attribute13;
  l_per_data_table(14) := p_mig_rec.attribute14;
  l_per_data_table(15) := p_mig_rec.attribute15;
  l_per_data_table(16) := p_mig_rec.attribute16;
  l_per_data_table(17) := p_mig_rec.attribute17;
  l_per_data_table(18) := p_mig_rec.attribute18;
  l_per_data_table(19) := p_mig_rec.attribute19;
  l_per_data_table(20) := p_mig_rec.attribute20;
  l_per_data_table(21) := p_mig_rec.attribute21;
  l_per_data_table(22) := p_mig_rec.attribute22;
  l_per_data_table(23) := p_mig_rec.attribute23;
  l_per_data_table(24) := p_mig_rec.attribute24;
  l_per_data_table(25) := p_mig_rec.attribute25;
  l_per_data_table(26) := p_mig_rec.attribute26;
  l_per_data_table(27) := p_mig_rec.attribute27;
  l_per_data_table(28) := p_mig_rec.attribute28;
  l_per_data_table(29) := p_mig_rec.attribute29;
  l_per_data_table(30) := p_mig_rec.attribute30;
  --
  FOR i in 1..30 LOOP
  --
  IF l_attr_table.EXISTS(i) THEN
    --
    IF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE1' THEN
      --
      l_ptu_attrs_data_rec.attribute1 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE2' THEN
      --
      l_ptu_attrs_data_rec.attribute2 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE3' THEN
      --
      l_ptu_attrs_data_rec.attribute3 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE4' THEN
      --
      l_ptu_attrs_data_rec.attribute4 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE5' THEN
      --
      l_ptu_attrs_data_rec.attribute5 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE6' THEN
      --
      l_ptu_attrs_data_rec.attribute6 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE7' THEN
      --
      l_ptu_attrs_data_rec.attribute7 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE8' THEN
      --
      l_ptu_attrs_data_rec.attribute8 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE9' THEN
      --
      l_ptu_attrs_data_rec.attribute9 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE10' THEN
      --
      l_ptu_attrs_data_rec.attribute10 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE11' THEN
      --
      l_ptu_attrs_data_rec.attribute11 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE12' THEN
      --
      l_ptu_attrs_data_rec.attribute12 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE13' THEN
      --
      l_ptu_attrs_data_rec.attribute13 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE14' THEN
      --
      l_ptu_attrs_data_rec.attribute14 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE15' THEN
      --
      l_ptu_attrs_data_rec.attribute15 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE16' THEN
      --
      l_ptu_attrs_data_rec.attribute16 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE17' THEN
      --
      l_ptu_attrs_data_rec.attribute17 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE18' THEN
      --
      l_ptu_attrs_data_rec.attribute18 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE19' THEN
      --
      l_ptu_attrs_data_rec.attribute19 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE20' THEN
      --
      l_ptu_attrs_data_rec.attribute20 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE21' THEN
      --
      l_ptu_attrs_data_rec.attribute21 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE22' THEN
      --
      l_ptu_attrs_data_rec.attribute22 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE23' THEN
      --
      l_ptu_attrs_data_rec.attribute23 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE24' THEN
      --
      l_ptu_attrs_data_rec.attribute24 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE25' THEN
      --
      l_ptu_attrs_data_rec.attribute25 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE26' THEN
      --
      l_ptu_attrs_data_rec.attribute26 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE27' THEN
      --
      l_ptu_attrs_data_rec.attribute27 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE28' THEN
      --
      l_ptu_attrs_data_rec.attribute28 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE29' THEN
      --
      l_ptu_attrs_data_rec.attribute29 := l_per_data_table(i);
      --
    ELSIF l_attr_table(i).PTU_DFF_ATTRIBUTE ='ATTRIBUTE30' THEN
      --
      l_ptu_attrs_data_rec.attribute30 := l_per_data_table(i);
      --
    END IF;
    --
  END IF;
  --
  END LOOP;
  --
  return l_ptu_attrs_data_rec;
  --
END RETRIVE_MAPPING;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_sub_attr_string >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Function to return the PTU Attribute mapping strings of a
-- basic PTU context mapped for a composite Person context.
-- Example : If the Person Context is EMP_APL and the attributes are A1 and A2.
--           A1 is mapped to A10 for EMP PTU context and
--           A2 is ampped to A20 for APL PTU context.
--           This function returns A1 for the imput values EMP_APL and EMP.
--
FUNCTION GET_SUB_ATTR_STRING (P_PER_CONTEXT IN VARCHAR2
                             ,P_PTU_CONTEXT IN VARCHAR2)
RETURN VARCHAR2
IS
  --
  l_dff_attr_str varchar2(2000);
  --
BEGIN
  --
  FOR attr_rec IN (SELECT L.PER_DFF_ATTRIBUTE
                   FROM   PER_PTU_DFF_MAPPING_LINES L,
                          PER_PTU_DFF_MAPPING_HEADERS H
                   WHERE  H.MAPPING_HEADER_ID = L.MAPPING_HEADER_ID
                   AND    H.DATA_MAPPING_COMPLETE = 'Y'
		   AND    L.PTU_DFF_CONTEXT_FIELD_CODE in
                          (P_PTU_CONTEXT,'Global Data Elements')
                   AND    H.PER_DFF_CONTEXT_FIELD_CODE IN
                         (P_PER_CONTEXT,'Global Data Elements'))
  LOOP
    --
    -- String of DFF Attributes used for a context.
    -- Comma is appended to each attribute so that ATTRIBUTE1 and
    -- ATTRIBUTE10 can be distinguished using the INSTR command.
    --
    l_dff_attr_str := l_dff_attr_str || attr_rec.PER_DFF_ATTRIBUTE || ',';
    --
  END LOOP;
  --
  return l_dff_attr_str;
  --
END GET_SUB_ATTR_STRING;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< populate_mig_new_table >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This function is to populate the PER mig table data into PTU mig table data
-- if the context is composite.
-- This procedure converts the distinct person DFF record to distinct PTU DFF
-- record.
--
FUNCTION populate_mig_new_table(p_mig_tab MIG_TAB_TYPE)
RETURN MIG_TAB_TYPE
IS
  --
  CURSOR csr_basic_ptu_data(p_context varchar2) IS
  SELECT distinct ptu_dff_context_field_code
  FROM   per_ptu_dff_mapping_headers mh
        ,per_ptu_dff_mapping_lines   ml
  WHERE  mh.mapping_header_id = ml.mapping_header_id
  AND    mh.per_dff_context_field_code = p_context
  AND    ml.ptu_dff_context_field_code <> 'Global Data Elements';
  --
  j number := 1;
  MIG_TAB_NEW MIG_TAB_TYPE;
  l_sub_per_rec PER_ALL_PEOPLE_F%ROWTYPE;
  --
  l_dff_attr_str varchar2(2000);
  --
BEGIN
  --
  FOR diff_context_rec in csr_basic_ptu_data(p_mig_tab(1).attribute_category) LOOP
  --
  l_dff_attr_str := GET_SUB_ATTR_STRING(p_mig_tab(1).attribute_category
                                ,diff_context_rec.ptu_dff_context_field_code);
  --
  FOR i IN 1..p_mig_tab.COUNT LOOP
    --
    l_sub_per_rec.person_id            := p_mig_tab(i).person_id;
    l_sub_per_rec.effective_start_date := p_mig_tab(i).effective_start_date;
    l_sub_per_rec.effective_end_date   := p_mig_tab(i).effective_end_date;
    l_sub_per_rec.person_type_id       := p_mig_tab(i).person_type_id;
    l_sub_per_rec.business_group_id    := p_mig_tab(i).business_group_id;
    l_sub_per_rec.attribute_category   := diff_context_rec.ptu_dff_context_field_code;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE1,') > 0) THEN
      --
      l_sub_per_rec.attribute1 := p_mig_tab(i).attribute1;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE2,')  > 0) THEN
      --
      l_sub_per_rec.attribute2  := p_mig_tab(i).attribute2;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE3,')  > 0) THEN
      --
      l_sub_per_rec.attribute3  := p_mig_tab(i).attribute3;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE4,')  > 0) THEN
      --
      l_sub_per_rec.attribute4  := p_mig_tab(i).attribute4;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE5,')  > 0) THEN
      --
      l_sub_per_rec.attribute5  := p_mig_tab(i).attribute5;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE6,')  > 0) THEN
      --
      l_sub_per_rec.attribute6  := p_mig_tab(i).attribute6;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE7,')  > 0) THEN
      --
      l_sub_per_rec.attribute7  := p_mig_tab(i).attribute7;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE8,')  > 0) THEN
      --
      l_sub_per_rec.attribute8  := p_mig_tab(i).attribute8;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE9,')  > 0) THEN
      --
      l_sub_per_rec.attribute9  := p_mig_tab(i).attribute9;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE10,') > 0) THEN
      --
      l_sub_per_rec.attribute10 := p_mig_tab(i).attribute10;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE11,') > 0) THEN
      --
      l_sub_per_rec.attribute11 := p_mig_tab(i).attribute11;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE12,') > 0) THEN
      --
      l_sub_per_rec.attribute12 := p_mig_tab(i).attribute12;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE13,') > 0) THEN
      --
      l_sub_per_rec.attribute13 := p_mig_tab(i).attribute13;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE14,') > 0) THEN
      --
      l_sub_per_rec.attribute14 := p_mig_tab(i).attribute14;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE15,') > 0) THEN
      --
      l_sub_per_rec.attribute15 := p_mig_tab(i).attribute15;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE16,') > 0) THEN
      --
      l_sub_per_rec.attribute16 := p_mig_tab(i).attribute16;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE17,') > 0) THEN
      --
      l_sub_per_rec.attribute17 := p_mig_tab(i).attribute17;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE18,') > 0) THEN
      --
      l_sub_per_rec.attribute18 := p_mig_tab(i).attribute18;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE19,') > 0) THEN
      --
      l_sub_per_rec.attribute19 := p_mig_tab(i).attribute19;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE20,') > 0) THEN
      --
      l_sub_per_rec.attribute20 := p_mig_tab(i).attribute20;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE21,') > 0) THEN
      --
      l_sub_per_rec.attribute21 := p_mig_tab(i).attribute21;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE22,') > 0) THEN
      --
      l_sub_per_rec.attribute22 := p_mig_tab(i).attribute22;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE23,') > 0) THEN
      --
      l_sub_per_rec.attribute23 := p_mig_tab(i).attribute23;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE24,') > 0) THEN
      --
      l_sub_per_rec.attribute24 := p_mig_tab(i).attribute24;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE25,') > 0) THEN
      --
      l_sub_per_rec.attribute25 := p_mig_tab(i).attribute25;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE26,') > 0) THEN
      --
      l_sub_per_rec.attribute26 := p_mig_tab(i).attribute26;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE27,') > 0) THEN
      --
      l_sub_per_rec.attribute27 := p_mig_tab(i).attribute27;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE28,') > 0) THEN
      --
      l_sub_per_rec.attribute28 := p_mig_tab(i).attribute28;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE29,') > 0) THEN
      --
      l_sub_per_rec.attribute29 := p_mig_tab(i).attribute29;
      --
    END IF;
    --
    IF (INSTR(l_dff_attr_str,'ATTRIBUTE30,') > 0) THEN
      --
      l_sub_per_rec.attribute30 := p_mig_tab(i).attribute30;
      --
    END IF;
    --
    j := MIG_TAB_NEW.count;
    --
    IF j <> 0 then
    --
     IF l_sub_per_rec.effective_start_date = MIG_TAB_NEW(j).effective_end_date+1 AND
       nvl(MIG_TAB_NEW(j).attribute1,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute1,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute2,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute2,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute3,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute3,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute4,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute4,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute5,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute5,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute6,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute6,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute7,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute7,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute8,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute8,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute9,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute9,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute10,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute10,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute11,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute11,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute12,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute12,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute13,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute13,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute14,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute14,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute15,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute15,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute16,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute16,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute17,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute17,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute18,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute18,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute19,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute19,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute20,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute20,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute21,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute21,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute22,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute22,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute23,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute23,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute24,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute24,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute25,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute25,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute26,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute26,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute27,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute27,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute28,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute28,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute29,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute29,hr_api.g_varchar2) AND
       nvl(MIG_TAB_NEW(j).attribute30,hr_api.g_varchar2)
         = nvl(l_sub_per_rec.attribute30,hr_api.g_varchar2) THEN
      --
      -- Both the records are same and continuous. So just move the EED to the EED
      -- of second record.
      --
      MIG_TAB_NEW(j).effective_end_date := l_sub_per_rec.effective_end_date;
      --
     ELSE
      --
      -- The records are not continuous or attribute data is not same.
      -- Therefore add one more row.
      --
      MIG_TAB_NEW(MIG_TAB_NEW.count+1) := l_sub_per_rec;
      --
     END IF;
     --
    ELSE
     --
     MIG_TAB_NEW(1) := l_sub_per_rec; -- this is the first record.
     --
    END IF;  -- j check
    --
  END LOOP; -- mig_tab loop.
  --
  END LOOP;
  --
  return MIG_TAB_NEW;
  --
END populate_mig_new_table;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< is_context_composite >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Function to check whether the context is composite or not.
--
FUNCTION is_context_composite(p_context varchar2)
RETURN BOOLEAN
IS
  --
  /*
  CURSOR csr_is_composite_spt(p_System_Person_Type varchar2) IS
  SELECT 'Y'
  FROM   per_person_types
  WHERE  system_person_type = p_system_person_type
  AND    system_person_type not in ('APL','EMP','EX_APL','EX_EMP','OTHER');
  --
  CURSOR csr_is_composite_ptid(p_Person_Type_ID number) IS
  SELECT 'Y'
  FROM   per_person_types
  WHERE  person_type_id = p_person_type_id
  AND    system_person_type not in ('APL','EMP','EX_APL','EX_EMP','OTHER');
  --
  CURSOR csr_is_composite_upt(p_User_Person_Type varchar2) IS
  SELECT 'Y'
  FROM   per_person_types
  WHERE  user_person_type = p_user_person_type
  AND    system_person_type not in ('APL','EMP','EX_APL','EX_EMP','OTHER');
  */
  --
  CURSOR csr_is_composite_spt(p_System_Person_Type varchar2) IS
  SELECT 'Y'
  FROM   per_person_types
  WHERE  system_person_type = p_system_person_type
  AND    system_person_type in ('EMP_APL','EX_EMP_APL','APL_EX_APL');
  --
  CURSOR csr_is_composite_ptid(p_Person_Type_ID number) IS
  SELECT 'Y'
  FROM   per_person_types
  WHERE  person_type_id = p_person_type_id
  AND    system_person_type in ('EMP_APL','EX_EMP_APL','APL_EX_APL');
  --
  CURSOR csr_is_composite_upt(p_User_Person_Type varchar2) IS
  SELECT 'Y'
  FROM   per_person_types
  WHERE  user_person_type = p_user_person_type
  AND    system_person_type in ('EMP_APL','EX_EMP_APL','APL_EX_APL');
  --
  l_composite     varchar2(1);
  l_context_field VARCHAR2(120);
  --
BEGIN
  --
  SELECT PER_DFF_CONTEXT_FIELD_NAME
  INTO   l_context_field
  FROM 	 PER_PTU_DFF_MAPPING_HEADERS
  WHERE	 PER_DFF_CONTEXT_FIELD_CODE =  p_context;
  --
  IF l_context_field = 'SYSTEM_PERSON_TYPE' THEN
    --
    OPEN csr_is_composite_spt(p_context);
    FETCH csr_is_composite_spt INTO l_composite;
    IF csr_is_composite_spt%FOUND THEN
      --
      CLOSE csr_is_composite_spt;
      return TRUE;
      --
    ELSE
      --
      CLOSE csr_is_composite_spt;
      return FALSE;
      --
    END IF;
    --
  ELSIF l_context_field in ('USER_PERSON_TYPE' , 'PTU_PERSON_TYPE') THEN
    --
    OPEN csr_is_composite_upt(p_context);
    FETCH csr_is_composite_upt INTO l_composite;
    IF csr_is_composite_upt%FOUND THEN
      --
      CLOSE csr_is_composite_upt;
      return TRUE;
      --
    ELSE
      --
      CLOSE csr_is_composite_upt;
      return FALSE;
      --
    END IF;
    --
  ELSIF l_context_field = 'PERSON_TYPE_ID' THEN
    --
    OPEN csr_is_composite_ptid(to_number(p_context));
    FETCH csr_is_composite_ptid INTO l_composite;
    IF csr_is_composite_ptid%FOUND THEN
      --
      CLOSE csr_is_composite_ptid;
      return TRUE;
      --
    ELSE
      --
      CLOSE csr_is_composite_ptid;
      return FALSE;
      --
    END IF;
    --
  END IF;
  --
END is_context_composite;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_ptu >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure does the actual updation of PTU record by calling the
-- PTU API.
--
PROCEDURE UPDATE_PTU (P_CONTEXT IN VARCHAR2, P_MIG_TAB IN MIG_TAB_TYPE) IS
  --
  -- cursor variable type.
  --
  TYPE PTU_RECORD_CSR_TYPE IS REF CURSOR RETURN PER_PERSON_TYPE_USAGES_F%ROWTYPE;
  --
  -- cursor variable declaration.
  --
  csrv_ptu_rec PTU_RECORD_CSR_TYPE;
  --
  -- local variables.
  --
  l_person_rec_context varchar2(60);
  -- the above variable holds the person level context i.e mig_tab(1).attribute_category.
  l_context_field varchar2(60);
  l_person_id number;
  l_business_group_id number;
  l_system_person_type varchar2(60);
  l_person_type_id number;
  l_user_person_type   varchar2(120);
  l_esd date;
  l_eed date;
  l_exists varchar2(1);
  l_error_desc varchar2(500);
  l_error_code varchar2(60);
  l_data_str  varchar2(2000);
  l_datetrack_mode varchar2(60);
  l_effective_date date;
  l_effective_start_date date;
  l_effective_end_date date;
  l_object_version_number number;
  --
  -- record types.
  --
  p_mig_rec PER_ALL_PEOPLE_F%rowtype; -- same as table type MIG_TAB_TYPE
  ptu_rec   PER_PERSON_TYPE_USAGES_F%rowtype;
  l_ptu_attrs_data_rec PER_PERSON_TYPE_USAGES_F%rowtype;
  mig_tab_new MIG_TAB_TYPE;
  --
  -- Cursors.
  --
  CURSOR csr_future_records_exists(p_person_type_usage_id number,
                                   p_effective_date date) IS
  SELECT 'Y'
  FROM   PER_PERSON_TYPE_USAGES_F
  WHERE  person_type_usage_id = p_person_type_usage_id
  AND    effective_start_date > p_effective_date;
  --
  -- User defined exceptions.
  --
  -- UPDATE_PTU_CALL_EXC EXCEPTION;
  --
BEGIN
  --
  --
  -- In the mapping header table check the context field used by Person DFF.
  -- ********** check this from the FND tables????????
  SELECT PER_DFF_CONTEXT_FIELD_NAME
  INTO   l_context_field
  FROM 	 PER_PTU_DFF_MAPPING_HEADERS
  WHERE	 PER_DFF_CONTEXT_FIELD_CODE =  P_CONTEXT;
  --
  IF is_context_composite(p_context) THEN
    --
    mig_tab_new := populate_mig_new_table(p_mig_tab);
    --
  ELSE
    --
    mig_tab_new := p_mig_tab; -- it is valid.
    --
  END IF;
  --
  -- Copy the person level context into a local variable to pass
  -- it to retrive_mapping function.
  --
  l_person_rec_context := p_mig_tab(1).attribute_category;
  --
  -----------------------------------------------------------------------------
  FOR  i IN 1..MIG_TAB_NEW.COUNT LOOP
  --
  -- initialize the variables.
  --
  p_mig_rec := MIG_TAB_NEW(i);
  --
  l_person_id := p_mig_rec.person_id;
  l_business_group_id := p_mig_rec.business_group_id;
  l_esd := p_mig_rec.effective_start_date;
  l_eed  := p_mig_rec.effective_end_date;
  --
  IF l_context_field = 'SYSTEM_PERSON_TYPE' THEN
    --
    -- copy the conext value into local variable.
    --
    l_system_person_type := p_mig_rec.attribute_category;
    --
    -- Open the cursor variable.
    --
    OPEN csrv_ptu_rec FOR
      SELECT *
      FROM   PER_PERSON_TYPE_USAGES_F PPTU
      WHERE  PPTU.PERSON_ID = l_person_id
      AND    (PPTU.EFFECTIVE_END_DATE >= l_esd
              AND PPTU.EFFECTIVE_START_DATE <= l_eed)
      AND    EXISTS (SELECT 1
                     FROM   PER_PERSON_TYPES PPT
                     WHERE  PPT.PERSON_TYPE_ID = PPTU.PERSON_TYPE_ID
                     AND    PPT.BUSINESS_GROUP_ID = l_business_group_id
                     AND    PPT.SYSTEM_PERSON_TYPE = l_system_person_type)
      ORDER BY PERSON_TYPE_ID, EFFECTIVE_START_DATE;
    --
  ELSIF l_context_field = 'PERSON_TYPE_ID' THEN
    --
    -- copy the conext value into local variable.
    --
    l_person_type_id := to_number(p_mig_rec.attribute_category);
    --
    -- Open the cursor variable.
    --
    OPEN csrv_ptu_rec FOR
      SELECT *
      FROM   PER_PERSON_TYPE_USAGES_F PPTU
      WHERE  PPTU.PERSON_ID = l_person_id
      AND    (PPTU.EFFECTIVE_END_DATE >= l_esd
              AND PPTU.EFFECTIVE_START_DATE <= l_eed)
       AND   EXISTS(SELECT 1
                    FROM    PER_PERSON_TYPES PPT
                    WHERE PPT.PERSON_TYPE_ID = PPTU.PERSON_TYPE_ID
                    AND   PPT.BUSINESS_GROUP_ID = l_business_group_id
                    AND   PPT.PERSON_TYPE_ID = l_person_type_id)
       ORDER BY  PERSON_TYPE_ID, EFFECTIVE_START_DATE;
    --
  ELSIF l_context_field in ('USER_PERSON_TYPE' , 'PTU_PERSON_TYPE') THEN
    --
    -- copy the conext value into local variable.
    --
    l_user_person_type := p_mig_rec.attribute_category;
    --
    -- Open the cursor variable.
    --
    OPEN csrv_ptu_rec FOR
      SELECT *
      FROM   PER_PERSON_TYPE_USAGES_F PPTU
      WHERE  PPTU.PERSON_ID = l_person_id
      AND    (PPTU.EFFECTIVE_END_DATE >= l_esd
              AND PPTU.EFFECTIVE_START_DATE <= l_eed)
      AND    EXISTS(SELECT 1
                    FROM   PER_PERSON_TYPES PPT
                    WHERE  PPT.PERSON_TYPE_ID = PPTU.PERSON_TYPE_ID
                    AND	   PPT.BUSINESS_GROUP_ID = l_business_group_id
                    AND    PPT.USER_PERSON_TYPE = l_user_person_type)
      ORDER BY PERSON_TYPE_ID, EFFECTIVE_START_DATE;
    --
  END IF;
  --
  --
  LOOP
    --
    -- fetch from cursor variable.
    --
    FETCH csrv_ptu_rec INTO ptu_rec;
    EXIT WHEN csrv_ptu_rec%NOTFOUND; -- exit when lst row is fetched.
    --
    -- Compare the effective dates of the PTU records with migration record
    -- and call the HR_PERSON_TYPE_USAGE_API to modify the PTU records.
    --
    -- While using the UPDATE mode, ckech for the existance of any future
    -- dt records. If found update the current record in UPDATE_CHANGE_INSERT mode.
    --
    IF ptu_rec.effective_start_date >= p_mig_rec.effective_start_date AND
       ptu_rec.effective_end_date   <= p_mig_rec.effective_end_date   THEN
      --
      -- Update the PTU record in CORRECTION mode with the changes.
      --
      l_effective_date        := ptu_rec.effective_start_date;
      l_object_version_number := ptu_rec.object_version_number;
      l_datetrack_mode       := 'CORRECTION';
      --
    ELSIF ptu_rec.effective_start_date < p_mig_rec.effective_start_date AND
          ptu_rec.effective_end_date between p_mig_rec.effective_start_date
	                                   and p_mig_rec.effective_end_date THEN
      --
      -- Update the PTU record in UPDATE mode with the changes.
      --
      l_effective_date        := p_mig_rec.effective_start_date;
      l_object_version_number := ptu_rec.object_version_number;
      --
      -- If future dt records exist, then use UPDATE_CHANGE_INSERT mode.
      --
      OPEN csr_future_records_exists(ptu_rec.person_type_usage_id, l_effective_date);
      FETCH csr_future_records_exists INTO l_exists;
      IF csr_future_records_exists%FOUND THEN
        --
        l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
	--
      ELSE
        --
        l_datetrack_mode := 'UPDATE';
	--
      END IF;
      --
      CLOSE csr_future_records_exists;
      --
    ELSIF ptu_rec.effective_end_date > p_mig_rec.effective_end_date AND
          ptu_rec.effective_start_date between p_mig_rec.effective_start_date
	                                   and p_mig_rec.effective_end_date THEN
      --
      -- Update the PTU record in UPDATE mode with no changes
      -- with effecitve_date as p_mig_rec.effective_end_date+1.
      --
      l_object_version_number := ptu_rec.object_version_number;
      --
      -- If future dt records exist, then use UPDATE_CHANGE_INSERT mode.
      --
      OPEN csr_future_records_exists(ptu_rec.person_type_usage_id,
                                     p_mig_rec.effective_end_date+1);
      FETCH csr_future_records_exists INTO l_exists;
      IF csr_future_records_exists%FOUND THEN
        --
        l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
	--
      ELSE
        --
        l_datetrack_mode := 'UPDATE';
	--
      END IF;
      --
      CLOSE csr_future_records_exists;
      --
      HR_PERSON_TYPE_USAGE_API.UPDATE_PERSON_TYPE_USAGE
             (p_validate              => false
             ,p_person_type_usage_id  => ptu_rec.person_type_usage_id
             ,p_effective_date        => p_mig_rec.effective_end_date+1
             ,p_datetrack_mode        => l_datetrack_mode
             ,p_object_version_number => l_object_version_number
             ,p_effective_start_date  => l_effective_start_date
             ,p_effective_end_date    => l_effective_end_date
             );
      --
      -- Now, Update the PTU record which starts on ptu_rec.effective_start_date
      -- using CORRECTION mode with the changes.
      --
      l_effective_date        := ptu_rec.effective_start_date;
      l_datetrack_mode       := 'CORRECTION';
      --
      -- As the object version number is changed, get the new.
      --
      SELECT object_version_number
      INTO   l_object_version_number
      FROM   PER_PERSON_TYPE_USAGES_F
      WHERE  person_type_usage_id = ptu_rec.person_type_usage_id
      AND    effective_start_date = ptu_rec.effective_start_date
      AND    effective_end_date   = p_mig_rec.effective_end_date;
      --
    ELSIF ptu_rec.effective_start_date < p_mig_rec.effective_start_date AND
          ptu_rec.effective_end_date   > p_mig_rec.effective_end_date  THEN
      --
      -- Update the PTU record in UPDATE mode with effective_date
      -- as p_mig_rec.effective_start_date without changes.
      --
      l_object_version_number := ptu_rec.object_version_number;
      --
      OPEN csr_future_records_exists(ptu_rec.person_type_usage_id,
                                     p_mig_rec.effective_start_date);
      FETCH csr_future_records_exists INTO l_exists;
      IF csr_future_records_exists%FOUND THEN
        --
        l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
	--
      ELSE
        --
        l_datetrack_mode := 'UPDATE';
	--
      END IF;
      --
      CLOSE csr_future_records_exists;
      --
      HR_PERSON_TYPE_USAGE_API.UPDATE_PERSON_TYPE_USAGE
             (p_validate              => false
             ,p_person_type_usage_id  => ptu_rec.person_type_usage_id
             ,p_effective_date        => p_mig_rec.effective_start_date
             ,p_datetrack_mode        => l_datetrack_mode
             ,p_object_version_number => l_object_version_number
             ,p_effective_start_date  => l_effective_start_date
             ,p_effective_end_date    => l_effective_end_date
             );
      --
      -- Again, update the PTU record in UPDATE mode with effective_date
      -- as p_mig_rec.effecitve_end_date+1.
      --
      OPEN csr_future_records_exists(ptu_rec.person_type_usage_id,
                                     p_mig_rec.effective_end_date+1);
      FETCH csr_future_records_exists INTO l_exists;
      IF csr_future_records_exists%FOUND THEN
        --
        l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
	--
      ELSE
        --
        l_datetrack_mode := 'UPDATE';
	--
      END IF;
      --
      CLOSE csr_future_records_exists;
      --
      HR_PERSON_TYPE_USAGE_API.UPDATE_PERSON_TYPE_USAGE
             (p_validate              => false
             ,p_person_type_usage_id  => ptu_rec.person_type_usage_id
             ,p_effective_date        => p_mig_rec.effective_end_date+1
             ,p_datetrack_mode        => l_datetrack_mode
             ,p_object_version_number => l_object_version_number
             ,p_effective_start_date  => l_effective_start_date
             ,p_effective_end_date    => l_effective_end_date
             );
      --
      -- Now, CORRECT the PTU record with effective_start_date =
      -- p_mig_rec.effective_start_date.
      --
      l_effective_date        := p_mig_rec.effective_start_date;
      l_datetrack_mode       := 'CORRECTION';
      --
      -- As the object version number is changed, get the new.
      --
      SELECT object_version_number
      INTO   l_object_version_number
      FROM   PER_PERSON_TYPE_USAGES_F
      WHERE  person_type_usage_id = ptu_rec.person_type_usage_id
      AND    effective_start_date = p_mig_rec.effective_start_date
      AND    effective_end_date   = p_mig_rec.effective_end_date;
      --
    END IF;
    --
    -- Identify the respective PTU DFF attributes to be updated from the
    -- mapping lines table by calling function RETRIVE_MAPPING.
    --
    l_ptu_attrs_data_rec := RETRIVE_MAPPING(p_mig_rec,l_person_rec_context);
    --
    -- Following is the common update procedure to update the PTU record.
    --
    HR_PERSON_TYPE_USAGE_API.UPDATE_PERSON_TYPE_USAGE
    (
     p_validate              => false
    ,p_person_type_usage_id  => ptu_rec.person_type_usage_id
    ,p_effective_date        => l_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_object_version_number => l_object_version_number
    ,p_attribute_category    => p_mig_rec.attribute_category -- ****
    ,p_attribute1  => nvl(l_ptu_attrs_data_rec.attribute1, hr_api.g_varchar2)
    ,p_attribute2  => nvl(l_ptu_attrs_data_rec.attribute2, hr_api.g_varchar2)
    ,p_attribute3  => nvl(l_ptu_attrs_data_rec.attribute3, hr_api.g_varchar2)
    ,p_attribute4  => nvl(l_ptu_attrs_data_rec.attribute4, hr_api.g_varchar2)
    ,p_attribute5  => nvl(l_ptu_attrs_data_rec.attribute5, hr_api.g_varchar2)
    ,p_attribute6  => nvl(l_ptu_attrs_data_rec.attribute6, hr_api.g_varchar2)
    ,p_attribute7  => nvl(l_ptu_attrs_data_rec.attribute7, hr_api.g_varchar2)
    ,p_attribute8  => nvl(l_ptu_attrs_data_rec.attribute8, hr_api.g_varchar2)
    ,p_attribute9  => nvl(l_ptu_attrs_data_rec.attribute9, hr_api.g_varchar2)
    ,p_attribute10 => nvl(l_ptu_attrs_data_rec.attribute10, hr_api.g_varchar2)
    ,p_attribute11 => nvl(l_ptu_attrs_data_rec.attribute11, hr_api.g_varchar2)
    ,p_attribute12 => nvl(l_ptu_attrs_data_rec.attribute12, hr_api.g_varchar2)
    ,p_attribute13 => nvl(l_ptu_attrs_data_rec.attribute13, hr_api.g_varchar2)
    ,p_attribute14 => nvl(l_ptu_attrs_data_rec.attribute14, hr_api.g_varchar2)
    ,p_attribute15 => nvl(l_ptu_attrs_data_rec.attribute15, hr_api.g_varchar2)
    ,p_attribute16 => nvl(l_ptu_attrs_data_rec.attribute16, hr_api.g_varchar2)
    ,p_attribute17 => nvl(l_ptu_attrs_data_rec.attribute17, hr_api.g_varchar2)
    ,p_attribute18 => nvl(l_ptu_attrs_data_rec.attribute18, hr_api.g_varchar2)
    ,p_attribute19 => nvl(l_ptu_attrs_data_rec.attribute19, hr_api.g_varchar2)
    ,p_attribute20 => nvl(l_ptu_attrs_data_rec.attribute20, hr_api.g_varchar2)
    ,p_attribute21 => nvl(l_ptu_attrs_data_rec.attribute21, hr_api.g_varchar2)
    ,p_attribute22 => nvl(l_ptu_attrs_data_rec.attribute22, hr_api.g_varchar2)
    ,p_attribute23 => nvl(l_ptu_attrs_data_rec.attribute23, hr_api.g_varchar2)
    ,p_attribute24 => nvl(l_ptu_attrs_data_rec.attribute24, hr_api.g_varchar2)
    ,p_attribute25 => nvl(l_ptu_attrs_data_rec.attribute25, hr_api.g_varchar2)
    ,p_attribute26 => nvl(l_ptu_attrs_data_rec.attribute26, hr_api.g_varchar2)
    ,p_attribute27 => nvl(l_ptu_attrs_data_rec.attribute27, hr_api.g_varchar2)
    ,p_attribute28 => nvl(l_ptu_attrs_data_rec.attribute28, hr_api.g_varchar2)
    ,p_attribute29 => nvl(l_ptu_attrs_data_rec.attribute29, hr_api.g_varchar2)
    ,p_attribute30 => nvl(l_ptu_attrs_data_rec.attribute30, hr_api.g_varchar2)
    ,p_effective_start_date  => l_effective_start_date
    ,p_effective_end_date    => l_effective_end_date
    );
    --
  END LOOP; -- ptu records loop.
  --
  -- close the cursor variable.
  --
  CLOSE csrv_ptu_rec;
  --
  -- check for success or failure. Update the concurrent request OUTPUT file.
  --

  END LOOP; -- mig table loop.
  --
  ---------------------------------------------------------------------------------
  --
  -- Add exception block over here.
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      raise;
      --
END UPDATE_PTU;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_attribute_string >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Function to get the qualifying DFF attributes for a context from the mapping
-- table and return them in a string. Global Attributes will be included in all
-- the strings.
--
FUNCTION GET_ATTRIBUTE_STRING (P_CONTEXT IN VARCHAR2)
RETURN VARCHAR2
IS
  --
  l_dff_attr_str varchar2(2000);
  --
BEGIN
  --
  FOR attr_rec IN (SELECT L.PER_DFF_ATTRIBUTE
                   FROM   PER_PTU_DFF_MAPPING_LINES L,
                          PER_PTU_DFF_MAPPING_HEADERS H
                   WHERE  H.MAPPING_HEADER_ID = L.MAPPING_HEADER_ID
                   AND    H.DATA_MAPPING_COMPLETE = 'Y'
                   AND    H.PER_DFF_CONTEXT_FIELD_CODE IN
                         (P_CONTEXT,'Global Data Elements'))
  LOOP
    --
    -- String of DFF Attributes used for a context.
    -- Comma is appended to each attribute so that ATTRIBUTE1 and
    -- ATTRIBUTE10 can be distinguished using the INSTR command.
    --
    l_dff_attr_str := l_dff_attr_str || attr_rec.PER_DFF_ATTRIBUTE || ',';
    --
  END LOOP;
  --
  return l_dff_attr_str;
  --
END GET_ATTRIBUTE_STRING;
--
-- ----------------------------------------------------------------------------
-- |------------------< maintain_failed_people_data >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure maintain_failed_people_data
  (p_person_id number
  ,p_business_group_id number
  ,p_request_id number
  ,p_error_desc varchar2
  ,p_attr_category varchar2
  ) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
BEGIN
  --
  UPDATE PER_PTU_DFF_MIG_FAILED_PEOPLE
  SET    ERROR_DESCRIPTION = p_error_desc,
         REQUEST_ID = p_request_id
  WHERE  PERSON_ID = p_person_id;
  --
  IF SQL%rowcount = 0 THEN
    --
    INSERT INTO PER_PTU_DFF_MIG_FAILED_PEOPLE
      (PERSON_ID,
       BUSINESS_GROUP_ID,
       REQUEST_ID,
       ERROR_DESCRIPTION,
       ATTRIBUTE_CATEGORY,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN)
      select p_person_id, p_business_group_id,
             p_request_id, p_error_desc,
             p_attr_category,fnd_global.user_id,
             sysdate, fnd_global.user_id,sysdate, fnd_global.login_id
      from dual;
      --
   END IF;
   --
   commit; --pragma commit
   --
END maintain_failed_people_data;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< write_log >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to write the person record tothe concurrent log file.
--
procedure write_log(p_data_str varchar2) IS
  --
  l_data     varchar2(80);
  l_start    number;
  --
begin
  --
  fnd_file.put_line(fnd_file.log, rpad('-', 78, '-'));
  --
  l_start := 1;
  --
  -- In chunks of 75 characters per line add this
  -- string to the concurrent log file.
  --
  LOOP
    --
    l_data := substr(p_data_str,l_start,75);
    l_start := l_start+75;
    exit when l_data is null;
    fnd_file.put_line(fnd_file.log,l_data);
    --
  END LOOP;
  --
end write_log;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< archive_data >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure contains the code required to process each record within the
-- PAY_ASSIGNMENT_ACTIONS table.
--  The procedure performs the actual migration.
--
PROCEDURE archive_data (p_assactid      in number,
                        p_effective_date in date)
IS
  --
  -- Variable declaration
  --
  l_last_per_attr_str VARCHAR2(5000);
  l_this_per_attr_str VARCHAR2(5000);
  l_log_str           VARCHAR2(5000);
  l_dff_attr_str      VARCHAR2(400);
  l_count             NUMBER :=1;
  l_error_desc        VARCHAR2(1000);
  l_error_code        VARCHAR2(1000);
  l_report_mode       varchar2(30);
  l_full_name         PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
  --
  -- Record Type
  --
  l_mig_rec      PER_ALL_PEOPLE_F%ROWTYPE;
  l_mig_rec_null PER_ALL_PEOPLE_F%ROWTYPE;
  --
  -- Table Type
  --
  l_mig_tab      MIG_TAB_TYPE;
  l_mig_tab_null MIG_TAB_TYPE;
  --
  -- Identify the person records that qualify for migration.
  -- Should have context in mapping header table with at least
  -- one attribute mapping record in mapping lines.
  -- The ORDER BY clause used here is very important as this cursor is used to
  -- recognize the  distinct DFF data for continuous Person records.
  --
  CURSOR csr_per(p_assactid in number) IS
  SELECT PPF.PERSON_ID, PPF.FULL_NAME, PPF.EFFECTIVE_START_DATE,
         PPF.EFFECTIVE_END_DATE,PERSON_TYPE_ID,BUSINESS_GROUP_ID,
	 NVL(PPF.ATTRIBUTE_CATEGORY, 'Global Data Elements') ATTRIBUTE_CATEGORY,
         ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
	 ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
	 ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,
	 ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,ATTRIBUTE19,ATTRIBUTE20,
	 ATTRIBUTE21,ATTRIBUTE22,ATTRIBUTE23,ATTRIBUTE24,ATTRIBUTE25,
	 ATTRIBUTE26,ATTRIBUTE27,ATTRIBUTE28,ATTRIBUTE29,ATTRIBUTE30
  FROM    PER_ALL_PEOPLE_F PPF
  WHERE   PPF.ATTRIBUTE_CATEGORY IN
          (SELECT H.PER_DFF_CONTEXT_FIELD_CODE
           FROM   PER_PTU_DFF_MAPPING_HEADERS H
           WHERE  H.DATA_MAPPING_COMPLETE = 'Y'
           AND EXISTS
               (SELECT 1
                FROM   PER_PTU_DFF_MAPPING_LINES L
                WHERE  H.MAPPING_HEADER_ID          = L.MAPPING_HEADER_ID))
  AND EXISTS
      (SELECT 1
       FROM   PAY_ASSIGNMENT_ACTIONS ASS
       WHERE  ASS.ASSIGNMENT_ACTION_ID = P_ASSACTID
       AND    ASS.OBJECT_ID = PPF.PERSON_ID)
  ORDER BY PPF.PERSON_ID, PPF.ATTRIBUTE_CATEGORY,
           PPF.EFFECTIVE_START_DATE, PPF.EFFECTIVE_END_DATE;
  --
  --
BEGIN
  --
  -- Get the report mode into local variable.
  --
  SELECT pay_core_utils.get_parameter('REPORT_MODE', ppa.legislative_parameters)
  INTO   l_report_mode
  FROM   pay_payroll_actions ppa
        ,pay_assignment_actions paa
  WHERE  ppa.payroll_action_id = paa.payroll_action_id
  AND    paa.assignment_action_id = p_assactid;
  --
  -- save point.
  --
  SAVEPOINT PROCESS_PERSON;
  --
  -- Loop through the person records
  --
  FOR per_rec IN csr_per(p_assactid) LOOP
    --
    --
    -- Log the person data after building the log_string..
    --
    l_log_str :=
      to_char(per_rec.person_id)||','||
      per_rec.full_name||','||
      to_char(per_rec.effective_start_date,'DD-MON-RRRR')||','||
      to_char(per_rec.effective_end_date,'DD-MON-RRRR')||','||
      to_char(per_rec.person_type_id)||','||
      to_char(per_rec.business_group_id)||','||
      per_rec.attribute_category||','||
      per_rec.attribute1||','||
      per_rec.attribute2||','||
      per_rec.attribute3||','||
      per_rec.attribute4||','||
      per_rec.attribute5||','||
      per_rec.attribute6||','||
      per_rec.attribute7||','||
      per_rec.attribute8||','||
      per_rec.attribute9||','||
      per_rec.attribute10||','||
      per_rec.attribute11||','||
      per_rec.attribute12||','||
      per_rec.attribute13||','||
      per_rec.attribute14||','||
      per_rec.attribute15||','||
      per_rec.attribute16||','||
      per_rec.attribute17||','||
      per_rec.attribute18||','||
      per_rec.attribute19||','||
      per_rec.attribute20||','||
      per_rec.attribute21||','||
      per_rec.attribute22||','||
      per_rec.attribute23||','||
      per_rec.attribute24||','||
      per_rec.attribute25||','||
      per_rec.attribute26||','||
      per_rec.attribute27||','||
      per_rec.attribute28||','||
      per_rec.attribute29||','||
      per_rec.attribute30;
    --
    write_log(l_log_str);
    --
    -- For a new Context, get the qualifying DFF attributes from mapping
    -- table and store them in the following string which is used for
    -- identifying the a migration fields in the corresponding person record
    -- eg. If the flexfield context uses ATTRIBUTE1 AND 3 then the string
    -- will look like 'ATTRIBUTE1,ATTRIBUTE3,'.
    -- Comma is appended to each attribute so that ATTRIBUTE1 and
    -- ATTRIBUTE10 can be distinguished using the INSTR command
    --
    IF (l_dff_attr_str IS NULL) OR
       per_rec.attribute_category <> l_mig_rec.attribute_category THEN
      --
      l_dff_attr_str := GET_ATTRIBUTE_STRING(per_rec.attribute_category);
      --
    END IF;
    --
    -- The data string for the attribute values in use by DFF
    --
    l_this_per_attr_str := '';
    --
    SELECT DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE1,' ) ,0,'', per_rec.ATTRIBUTE1) ||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE2,' ) ,0,'', per_rec.ATTRIBUTE2) ||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE3,' ) ,0,'', per_rec.ATTRIBUTE3) ||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE4,' ) ,0,'', per_rec.ATTRIBUTE4) ||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE5,' ) ,0,'', per_rec.ATTRIBUTE5) ||
           DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE6,' ) ,0,'', per_rec.ATTRIBUTE6) ||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE7,' ) ,0,'', per_rec.ATTRIBUTE7) ||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE8,' ) ,0,'', per_rec.ATTRIBUTE8) ||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE9,' ) ,0,'', per_rec.ATTRIBUTE9) ||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE10,') ,0,'', per_rec.ATTRIBUTE10)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE11,') ,0,'', per_rec.ATTRIBUTE11)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE12,') ,0,'', per_rec.ATTRIBUTE12)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE13,') ,0,'', per_rec.ATTRIBUTE13)||
           DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE14,') ,0,'', per_rec.ATTRIBUTE14)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE15,') ,0,'', per_rec.ATTRIBUTE15)||
           DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE16,') ,0,'', per_rec.ATTRIBUTE16)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE17,') ,0,'', per_rec.ATTRIBUTE17)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE18,') ,0,'', per_rec.ATTRIBUTE18)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE19,') ,0,'', per_rec.ATTRIBUTE19)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE20,') ,0,'', per_rec.ATTRIBUTE20)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE21,') ,0,'', per_rec.ATTRIBUTE21)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE22,') ,0,'', per_rec.ATTRIBUTE22)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE23,') ,0,'', per_rec.ATTRIBUTE23)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE24,') ,0,'', per_rec.ATTRIBUTE24)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE25,') ,0,'', per_rec.ATTRIBUTE25)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE26,') ,0,'', per_rec.ATTRIBUTE26)||
           DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE27,') ,0,'', per_rec.ATTRIBUTE27)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE28,') ,0,'', per_rec.ATTRIBUTE28)||
           DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE29,') ,0,'', per_rec.ATTRIBUTE29)||
	   DECODE (INSTR(l_dff_attr_str, 'ATTRIBUTE30,') ,0,'', per_rec.ATTRIBUTE30)
    INTO   l_this_per_attr_str
    FROM   DUAL;
    --
    -- If no attributes are found then assign a comma to the string
    -- in order to avoid comparison failure due to a null value.
    --
    l_this_per_attr_str := NVL(l_this_per_attr_str, ',');
    --
    -- Identify the distinct Person DFF data for same context in a
    -- continuous period (3rd statement in the IF condition checks the continuity)
    --
    IF (per_rec.person_id <> l_mig_rec.person_id OR
       per_rec.attribute_category <> l_mig_rec.attribute_category OR
       per_rec.effective_start_date <> l_mig_rec.effective_end_date+1 OR
       per_rec.person_type_id <> l_mig_rec.person_type_id OR
       per_rec.business_group_id <> l_mig_rec.business_group_id OR
       l_this_per_attr_str <> l_last_per_attr_str)
       THEN
       --
       -- **************************************************************
       -- code flow is changed.
       --
       --
       -- Assign the values to the table.
       --
       -- take a local variable to process the index.
       --
       l_count := l_mig_tab.count;
       --
       l_mig_tab(l_count+1).person_id      := l_mig_rec.person_id;
       l_mig_tab(l_count+1).person_type_id := l_mig_rec.person_type_id;
       l_mig_tab(l_count+1).attribute_category := l_mig_rec.attribute_category;
       l_mig_tab(l_count+1).effective_start_date := l_mig_rec.effective_start_date;
       l_mig_tab(l_count+1).effective_end_date   := l_mig_rec.effective_end_date;
       l_mig_tab(l_count+1).business_group_id    := l_mig_rec.business_group_id;
       l_mig_tab(l_count+1).attribute1  := l_mig_rec.attribute1;
       l_mig_tab(l_count+1).attribute2  := l_mig_rec.attribute2;
       l_mig_tab(l_count+1).attribute3  := l_mig_rec.attribute3;
       l_mig_tab(l_count+1).attribute4  := l_mig_rec.attribute4;
       l_mig_tab(l_count+1).attribute5  := l_mig_rec.attribute5;
       l_mig_tab(l_count+1).attribute6  := l_mig_rec.attribute6;
       l_mig_tab(l_count+1).attribute7  := l_mig_rec.attribute7;
       l_mig_tab(l_count+1).attribute8  := l_mig_rec.attribute8;
       l_mig_tab(l_count+1).attribute9  := l_mig_rec.attribute9;
       l_mig_tab(l_count+1).attribute10 := l_mig_rec.attribute10;
       l_mig_tab(l_count+1).attribute11 := l_mig_rec.attribute11;
       l_mig_tab(l_count+1).attribute12 := l_mig_rec.attribute12;
       l_mig_tab(l_count+1).attribute13 := l_mig_rec.attribute13;
       l_mig_tab(l_count+1).attribute14 := l_mig_rec.attribute14;
       l_mig_tab(l_count+1).attribute15 := l_mig_rec.attribute15;
       l_mig_tab(l_count+1).attribute16 := l_mig_rec.attribute16;
       l_mig_tab(l_count+1).attribute17 := l_mig_rec.attribute17;
       l_mig_tab(l_count+1).attribute18 := l_mig_rec.attribute18;
       l_mig_tab(l_count+1).attribute19 := l_mig_rec.attribute19;
       l_mig_tab(l_count+1).attribute20 := l_mig_rec.attribute20;
       l_mig_tab(l_count+1).attribute21 := l_mig_rec.attribute21;
       l_mig_tab(l_count+1).attribute22 := l_mig_rec.attribute22;
       l_mig_tab(l_count+1).attribute23 := l_mig_rec.attribute23;
       l_mig_tab(l_count+1).attribute24 := l_mig_rec.attribute24;
       l_mig_tab(l_count+1).attribute25 := l_mig_rec.attribute25;
       l_mig_tab(l_count+1).attribute26 := l_mig_rec.attribute26;
       l_mig_tab(l_count+1).attribute27 := l_mig_rec.attribute27;
       l_mig_tab(l_count+1).attribute28 := l_mig_rec.attribute28;
       l_mig_tab(l_count+1).attribute29 := l_mig_rec.attribute29;
       l_mig_tab(l_count+1).attribute30 := l_mig_rec.attribute30;
       --
       IF (per_rec.person_id <> l_mig_rec.person_id OR
         per_rec.attribute_category <> l_mig_rec.attribute_category)  THEN
	 --
	 -- Update the PTU records.
	 --
	 UPDATE_PTU(l_mig_rec.ATTRIBUTE_CATEGORY ,l_mig_tab);
	 --
	 -- Once the table is processed, delete the table.
	 --
	 l_mig_tab.delete;
	 --
         -- reset the l_dff_attr_str as the attribute_category is changed.
         --
         --
       END IF;
       --
       -- Reset the migration record and local variables.
       --
       l_mig_rec := l_mig_rec_null;
       --
    END IF;
    --
    -- Form the distinct attribute set record for migration.
    --
    -- Assign Person ID, Person Type ID, Business Group Id to the new attribute
    -- set record, it gets reset when attribute set changes and respective PTU is
    -- updated.
    --
    l_mig_rec.person_id := NVL(l_mig_rec.person_id,per_rec.person_id);
    l_mig_rec.person_type_id := NVL(l_mig_rec.person_type_id,per_rec.person_type_id);
    l_mig_rec.business_group_id := NVL(l_mig_rec.business_group_id,per_rec.business_group_id);
    --
    -- The start date for the attribute set is the start date of the first record.
    --
    l_mig_rec.effective_start_date := NVL(l_mig_rec.effective_start_date,
                                            per_rec.effective_start_date);
    --
    -- The end date for the attribute set is the end date of the last record.
    --
    l_mig_rec.effective_end_date := per_rec.effective_end_date;
    --
    -- Assign DFF values to the new attribute set, it gets reset when attribute set
    -- changes and respective PTU is updated.
    --
    IF (l_mig_rec.attribute_category IS NULL) THEN
      --
      l_mig_rec.attribute_category := per_rec.attribute_category;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE1,') > 0) THEN
        --
        l_mig_rec.attribute1 := per_rec.attribute1;
	--
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE2,')  > 0) THEN
        --
        l_mig_rec.attribute2  := per_rec.attribute2;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE3,')  > 0) THEN
        --
        l_mig_rec.attribute3  := per_rec.attribute3;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE4,')  > 0) THEN
        --
        l_mig_rec.attribute4  := per_rec.attribute4;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE5,')  > 0) THEN
        --
        l_mig_rec.attribute5  := per_rec.attribute5;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE6,')  > 0) THEN
        --
        l_mig_rec.attribute6  := per_rec.attribute6;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE7,')  > 0) THEN
        --
        l_mig_rec.attribute7  := per_rec.attribute7;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE8,')  > 0) THEN
        --
        l_mig_rec.attribute8  := per_rec.attribute8;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE9,')  > 0) THEN
        --
        l_mig_rec.attribute9  := per_rec.attribute9;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE10,') > 0) THEN
        --
        l_mig_rec.attribute10 := per_rec.attribute10;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE11,') > 0) THEN
        --
        l_mig_rec.attribute11 := per_rec.attribute11;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE12,') > 0) THEN
        --
        l_mig_rec.attribute12 := per_rec.attribute12;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE13,') > 0) THEN
        --
        l_mig_rec.attribute13 := per_rec.attribute13;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE14,') > 0) THEN
        --
        l_mig_rec.attribute14 := per_rec.attribute14;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE15,') > 0) THEN
        --
        l_mig_rec.attribute15 := per_rec.attribute15;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE16,') > 0) THEN
        --
        l_mig_rec.attribute16 := per_rec.attribute16;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE17,') > 0) THEN
        --
        l_mig_rec.attribute17 := per_rec.attribute17;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE18,') > 0) THEN
        --
        l_mig_rec.attribute18 := per_rec.attribute18;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE19,') > 0) THEN
        --
        l_mig_rec.attribute19 := per_rec.attribute19;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE20,') > 0) THEN
        --
        l_mig_rec.attribute20 := per_rec.attribute20;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE21,') > 0) THEN
        --
        l_mig_rec.attribute21 := per_rec.attribute21;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE22,') > 0) THEN
        --
        l_mig_rec.attribute22 := per_rec.attribute22;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE23,') > 0) THEN
        --
        l_mig_rec.attribute23 := per_rec.attribute23;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE24,') > 0) THEN
        --
        l_mig_rec.attribute24 := per_rec.attribute24;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE25,') > 0) THEN
        --
        l_mig_rec.attribute25 := per_rec.attribute25;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE26,') > 0) THEN
        --
        l_mig_rec.attribute26 := per_rec.attribute26;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE27,') > 0) THEN
        --
        l_mig_rec.attribute27 := per_rec.attribute27;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE28,') > 0) THEN
        --
        l_mig_rec.attribute28 := per_rec.attribute28;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE29,') > 0) THEN
        --
        l_mig_rec.attribute29 := per_rec.attribute29;
        --
      END IF;
      --
      IF (INSTR(l_dff_attr_str,'ATTRIBUTE30,') > 0) THEN
        --
        l_mig_rec.attribute30 := per_rec.attribute30;
        --
      END IF;
      --
    END IF;
    --
    -- Store the string of used attribute values for this record.
    --
    l_last_per_attr_str := l_this_per_attr_str;
    --
  END LOOP;
  --
  -- Perform the migration for the last person context in the loop
  -- Assign the values to the table.
  --
  IF l_mig_rec.person_id is not null THEN
  --
  l_count := l_mig_tab.COUNT;
  --
  l_mig_tab(l_count+1).person_id      := l_mig_rec.person_id;
  l_mig_tab(l_count+1).person_type_id := l_mig_rec.person_type_id;
  l_mig_tab(l_count+1).attribute_category := l_mig_rec.attribute_category;
  l_mig_tab(l_count+1).effective_start_date := l_mig_rec.effective_start_date;
  l_mig_tab(l_count+1).effective_end_date   := l_mig_rec.effective_end_date;
  l_mig_tab(l_count+1).business_group_id    := l_mig_rec.business_group_id;
  l_mig_tab(l_count+1).attribute1  := l_mig_rec.attribute1;
  l_mig_tab(l_count+1).attribute2  := l_mig_rec.attribute2;
  l_mig_tab(l_count+1).attribute3  := l_mig_rec.attribute3;
  l_mig_tab(l_count+1).attribute4  := l_mig_rec.attribute4;
  l_mig_tab(l_count+1).attribute5  := l_mig_rec.attribute5;
  l_mig_tab(l_count+1).attribute6  := l_mig_rec.attribute6;
  l_mig_tab(l_count+1).attribute7  := l_mig_rec.attribute7;
  l_mig_tab(l_count+1).attribute8  := l_mig_rec.attribute8;
  l_mig_tab(l_count+1).attribute9  := l_mig_rec.attribute9;
  l_mig_tab(l_count+1).attribute10 := l_mig_rec.attribute10;
  l_mig_tab(l_count+1).attribute11 := l_mig_rec.attribute11;
  l_mig_tab(l_count+1).attribute12 := l_mig_rec.attribute12;
  l_mig_tab(l_count+1).attribute13 := l_mig_rec.attribute13;
  l_mig_tab(l_count+1).attribute14 := l_mig_rec.attribute14;
  l_mig_tab(l_count+1).attribute15 := l_mig_rec.attribute15;
  l_mig_tab(l_count+1).attribute16 := l_mig_rec.attribute16;
  l_mig_tab(l_count+1).attribute17 := l_mig_rec.attribute17;
  l_mig_tab(l_count+1).attribute18 := l_mig_rec.attribute18;
  l_mig_tab(l_count+1).attribute19 := l_mig_rec.attribute19;
  l_mig_tab(l_count+1).attribute20 := l_mig_rec.attribute20;
  l_mig_tab(l_count+1).attribute21 := l_mig_rec.attribute21;
  l_mig_tab(l_count+1).attribute22 := l_mig_rec.attribute22;
  l_mig_tab(l_count+1).attribute23 := l_mig_rec.attribute23;
  l_mig_tab(l_count+1).attribute24 := l_mig_rec.attribute24;
  l_mig_tab(l_count+1).attribute25 := l_mig_rec.attribute25;
  l_mig_tab(l_count+1).attribute26 := l_mig_rec.attribute26;
  l_mig_tab(l_count+1).attribute27 := l_mig_rec.attribute27;
  l_mig_tab(l_count+1).attribute28 := l_mig_rec.attribute28;
  l_mig_tab(l_count+1).attribute29 := l_mig_rec.attribute29;
  l_mig_tab(l_count+1).attribute30 := l_mig_rec.attribute30;
  --
  -- Update the PTU records
  --
  UPDATE_PTU(l_mig_rec.ATTRIBUTE_CATEGORY, l_mig_tab);
  --
  -- Once the table is processed, delete the table.
  --
  l_mig_tab.delete;
  --
  END IF;
  --
  -- Insert/Update table for re-processing person_ids.
  --
  UPDATE PER_PTU_DFF_MIG_FAILED_PEOPLE
  SET    ERROR_DESCRIPTION = 'SUCCESS',
         REQUEST_ID = g_request_id
  WHERE  PERSON_ID = l_mig_rec.person_id;
  --
  -- Maintain the log for success person IDs.
  --
  fnd_file.put_line(fnd_file.log, 'Successfully migrated the person DFF data.');
  --
EXCEPTION
  --
  WHEN others THEN
    --
    ROLLBACK TO PROCESS_PERSON;
    --
    -- Get the error details.
    --
    l_error_desc   := SQLERRM;
    l_error_code   := to_char(SQLCODE);
    --
    -- Maintain the log for the failure record.
    --
    -- Fix for bug 4012947. Corrected the following log message.
    --
    fnd_file.put_line(fnd_file.log, 'Failed migrating the person DFF data.');
    fnd_file.put_line(fnd_file.log, l_error_code||' '||l_error_desc);
    --
    -- Update if exists otherwise insert using the autonomous proc..
    --
    maintain_failed_people_data
           (p_person_id => l_mig_rec.person_id
           ,p_business_group_id => l_mig_rec.business_group_id
           ,p_request_id => g_request_id
           ,p_error_desc => substr(l_error_code||l_error_desc,1,990)
           ,p_attr_category => l_mig_rec.ATTRIBUTE_CATEGORY
           );
    --
    /*
    UPDATE PER_PTU_DFF_MIG_FAILED_PEOPLE
    SET    ERROR_DESCRIPTION = substr(l_error_code||l_error_desc,1,990),
           REQUEST_ID = g_request_id
    WHERE  PERSON_ID = l_mig_rec.person_id;
    --
    IF SQL%rowcount = 0 THEN
      --
      INSERT INTO PER_PTU_DFF_MIG_FAILED_PEOPLE
      (PERSON_ID,
       BUSINESS_GROUP_ID,
       REQUEST_ID,
       ERROR_DESCRIPTION,
       ATTRIBUTE_CATEGORY,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN)
      select l_mig_rec.person_id, l_mig_rec.business_group_id,
             g_request_id, substr(l_error_code||l_error_desc,1,990),
             l_mig_rec.ATTRIBUTE_CATEGORY,fnd_global.user_id,
             sysdate, fnd_global.user_id,sysdate, fnd_global.login_id
      from dual;
      --
    END IF;
    --
    */
    --
    raise;
  --
END archive_data;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< deinitialization >----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is used to update the migration_status in table
-- PER_PTU_DFF_MAPPING_HEADERS.
-- Then we call the standard deinit procedure pay_archive.standard_deinit.
--
PROCEDURE deinitialization(pactid in number) IS
  --
  l_business_group_id number;
  l_person_id number;
  --
  cursor csr_failed_people(p_bg_id number) IS
  select person_id
  from   PER_PTU_DFF_MIG_FAILED_PEOPLE
  where  business_group_id = nvl(p_bg_id,business_group_id)
  and    ERROR_DESCRIPTION <> 'SUCCESS'
  and    PERSON_ID <> hr_api.g_number;
  --
  --
BEGIN
  --
  -- The user can run the migration process for a single BG. If it is successful,
  -- then updating header table will result in no run for another BG in next request.
  -- Therefore use person_id and business_group_id combination to check whether the process
  -- for a perticular Bg was successful or not.
  --
  -- Check the table PER_PTU_DFF_MIG_FAILED_PEOPLE for failed people for the given BG.
  -- If any person record is found as failed then insert a record with person_id as
  -- hr_api.g_number and business_group_id as current business_group_id and
  -- error_description as FAILED. If no person record is failed then insert the above
  -- record with error_description as SUCCESS. This error_description is used in
  -- procedure submit_migration to decide whetehr this request is re-run or a fresh
  -- request.
  --
  SELECT pay_core_utils.get_parameter('BUSINESS_GROUP_ID', ppa.legislative_parameters)
  INTO  l_business_group_id
  FROM pay_payroll_actions ppa
  WHERE ppa.payroll_action_id = pactid;
  --
  open csr_failed_people(l_business_group_id);
   fetch csr_failed_people into l_person_id;
   IF csr_failed_people%found THEN
     --
     UPDATE PER_PTU_DFF_MIG_FAILED_PEOPLE
     SET    ERROR_DESCRIPTION = 'FAILED',
            REQUEST_ID = g_request_id
     WHERE  PERSON_ID = hr_api.g_number
     and    nvl(business_group_id,-1) = nvl(l_business_group_id,-1);
     --
     IF SQL%rowcount = 0 THEN
      --
      INSERT INTO PER_PTU_DFF_MIG_FAILED_PEOPLE
      (PERSON_ID,
       BUSINESS_GROUP_ID,
       REQUEST_ID,
       ERROR_DESCRIPTION,
       ATTRIBUTE_CATEGORY,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN)
       select hr_api.g_number, l_business_group_id,
              g_request_id, 'FAILED',
              null,fnd_global.user_id,
              sysdate, fnd_global.user_id,sysdate,
              fnd_global.login_id
       from dual;
       --
     END IF;
     --
   ELSE
     --
     UPDATE PER_PTU_DFF_MIG_FAILED_PEOPLE
     SET    ERROR_DESCRIPTION = 'SUCCESS',
            REQUEST_ID = g_request_id
     WHERE  PERSON_ID = hr_api.g_number
     and    nvl(business_group_id,-1) = nvl(l_business_group_id,-1);
     --
     IF SQL%rowcount = 0 THEN
      INSERT INTO PER_PTU_DFF_MIG_FAILED_PEOPLE
      (PERSON_ID,
       BUSINESS_GROUP_ID,
       REQUEST_ID,
       ERROR_DESCRIPTION,
       ATTRIBUTE_CATEGORY,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN)
       select hr_api.g_number, l_business_group_id,
             g_request_id, 'SUCCESS',
             null,fnd_global.user_id,
             sysdate, fnd_global.user_id,sysdate,
             fnd_global.login_id
      from dual;
     --
     END IF;
   END IF;
   --
   close csr_failed_people;
  --

  --
  /*
  UPDATE PER_PTU_DFF_MAPPING_HEADERS HEADER
  SET    HEADER.MIGRATION_STATUS = 'COMPLETE'
        ,HEADER.REQUEST_ID = g_request_id
  WHERE  HEADER.DATA_MAPPING_COMPLETE = 'Y'
  AND    NOT EXISTS
         (SELECT NULL
	  FROM   PER_PTU_DFF_MIG_FAILED_PEOPLE FAILED
	  WHERE  FAILED.ATTRIBUTE_CATEGORY = HEADER.PER_DFF_CONTEXT_FIELD_CODE
          AND    FAILED.ERROR_DESCRIPTION <> 'SUCCESS');
  */
  --
  -- Now call the default deinit proc.
  --
  pay_archive.standard_deinit(pactid);
  --
END deinitialization;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< submit_perDFFpurge >---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE submit_perDFFpurge(errbuf              out NOCOPY varchar2,
                             retcode             out NOCOPY number,
                             p_purge_scope       VARCHAR2,
                             p_context           VARCHAR2) is
  --
  --
  -- Identify the contexts in the mapping header table for which
  -- migration is complete.
  --
  -- After the implemention of migration for specific business group, the
  -- migration_complete column doesn't have any meaning.
  -- No check against it.
  --
  CURSOR c_per_context IS
  SELECT PER_DFF_CONTEXT_FIELD_CODE
  FROM   PER_PTU_DFF_MAPPING_HEADERS
  WHERE  PER_DFF_CONTEXT_FIELD_CODE = DECODE (p_purge_scope, 'ALL',
                          PER_DFF_CONTEXT_FIELD_CODE, p_context);
  --
  --
  --
  l_dff_attr_str varchar2(2000);
  l_count  number;
  --
BEGIN
  --
  -- Loop through the migrated contexts selected by above cursor.
  --
  FOR  l_context_rec IN c_per_context LOOP
    --
    -- Get the attribute string for ATTRIBUTES migrated for the context.
    --
    l_dff_attr_str := GET_ATTRIBUTE_STRING(l_context_rec. PER_DFF_CONTEXT_FIELD_CODE);
    --
    -- Update the migrated person DFF attributes to null, IF attribute exist in the
    -- migrated attribute string.
    --
    UPDATE PER_ALL_PEOPLE_F papf
    SET papf.ATTRIBUTE_CATEGORY = ''
       ,papf.ATTRIBUTE1 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE1,'), 0, papf.ATTRIBUTE1, '')
       ,papf.ATTRIBUTE2 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE2,'), 0, papf.ATTRIBUTE2, '')
       ,papf.ATTRIBUTE3 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE3,'), 0, papf.ATTRIBUTE3, '')
       ,papf.ATTRIBUTE4 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE4,'), 0, papf.ATTRIBUTE4, '')
       ,papf.ATTRIBUTE5 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE5,'), 0, papf.ATTRIBUTE5, '')
       ,papf.ATTRIBUTE6 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE6,'), 0, papf.ATTRIBUTE6, '')
       ,papf.ATTRIBUTE7 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE7,'), 0, papf.ATTRIBUTE7, '')
       ,papf.ATTRIBUTE8 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE8,'), 0, papf.ATTRIBUTE8, '')
       ,papf.ATTRIBUTE9 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE9,'), 0, papf.ATTRIBUTE9, '')
       ,papf.ATTRIBUTE10 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE10,'), 0, papf.ATTRIBUTE10, '')
       ,papf.ATTRIBUTE11 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE11,'), 0, papf.ATTRIBUTE11, '')
       ,papf.ATTRIBUTE12 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE12,'), 0, papf.ATTRIBUTE12, '')
       ,papf.ATTRIBUTE13 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE13,'), 0, papf.ATTRIBUTE13, '')
       ,papf.ATTRIBUTE14 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE14,'), 0, papf.ATTRIBUTE14, '')
       ,papf.ATTRIBUTE15 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE15,'), 0, papf.ATTRIBUTE15, '')
       ,papf.ATTRIBUTE16 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE16,'), 0, papf.ATTRIBUTE16, '')
       ,papf.ATTRIBUTE17 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE17,'), 0, papf.ATTRIBUTE17, '')
       ,papf.ATTRIBUTE18 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE18,'), 0, papf.ATTRIBUTE18, '')
       ,papf.ATTRIBUTE19 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE19,'), 0, papf.ATTRIBUTE19, '')
       ,papf.ATTRIBUTE20 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE20,'), 0, papf.ATTRIBUTE20, '')
       ,papf.ATTRIBUTE21 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE21,'), 0, papf.ATTRIBUTE21, '')
       ,papf.ATTRIBUTE22 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE22,'), 0, papf.ATTRIBUTE22, '')
       ,papf.ATTRIBUTE23 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE23,'), 0, papf.ATTRIBUTE23, '')
       ,papf.ATTRIBUTE24 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE24,'), 0, papf.ATTRIBUTE24, '')
       ,papf.ATTRIBUTE25 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE25,'), 0, papf.ATTRIBUTE25, '')
       ,papf.ATTRIBUTE26 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE26,'), 0, papf.ATTRIBUTE26, '')
       ,papf.ATTRIBUTE27 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE27,'), 0, papf.ATTRIBUTE27, '')
       ,papf.ATTRIBUTE28 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE28,'), 0, papf.ATTRIBUTE28, '')
       ,papf.ATTRIBUTE29 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE29,'), 0, papf.ATTRIBUTE29, '')
       ,papf.ATTRIBUTE30 = DECODE (INSTR (l_dff_attr_str , 'ATTRIBUTE30,'), 0, papf.ATTRIBUTE30, '')
    WHERE papf.ATTRIBUTE_CATEGORY = l_context_rec.PER_DFF_CONTEXT_FIELD_CODE
    and not exists
       (select failed.person_id
        from   PER_PTU_DFF_MIG_FAILED_PEOPLE failed
        where  failed.person_id = papf.person_id
        and    failed.error_description <> 'SUCCESS');
    --
    -- Summary Report in LOG file.
    --
    l_count := SQL%ROWCOUNT;
    --
    fnd_file.put_line (fnd_file.log, 'Context='||l_context_rec.PER_DFF_CONTEXT_FIELD_CODE||
                       ' Records Updated= '||to_char(l_count));
    --
  END LOOP;
  --
END submit_perDFFpurge;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< populate_mapping_tables >------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is called from mapping form to populate the mappping tables.
--
PROCEDURE populate_mapping_tables IS
  --
  CURSOR csr_already_populated IS
  SELECT 'Y'
  FROM   DUAL
  WHERE  EXISTS
        (SELECT NULL
	 FROM   PER_PTU_DFF_MAPPING_HEADERS
	);
  --
  l_populated varchar2(1);
  --
BEGIN
  --
  -- Check whether the data is already populated.
  --
  OPEN csr_already_populated;
  FETCH csr_already_populated INTO l_populated;
  IF csr_already_populated%FOUND THEN
    --
    CLOSE csr_already_populated;
    null;
    return;
    --
  END IF;
  --
  CLOSE csr_already_populated;
  --
  -- Populate Header table which holds the context details.
  --
  INSERT INTO PER_PTU_DFF_MAPPING_HEADERS
  ( MAPPING_HEADER_ID,
    PER_DFF_CONTEXT_FIELD_CODE,
    PER_DFF_CONTEXT_FIELD_NAME,
    PER_DFF_CONTEXT_FIELD_DESC,
    DATA_MAPPING_COMPLETE,
    REQUEST_ID,
    MIGRATION_STATUS,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN )
   SELECT PER_PTU_DFF_MAPPING_HEADERS_S.NEXTVAL,
          FDFC.DESCRIPTIVE_FLEX_CONTEXT_CODE,
	  FDFV.DEFAULT_CONTEXT_FIELD_NAME,
          FDFC.DESCRIPTIVE_FLEX_CONTEXT_NAME,
	  'N', -- data mapping complete
	  NULL, -- request id
	  NULL, -- migration status
	  fnd_global.user_id,
	  sysdate,
	  fnd_global.user_id,
	  sysdate,
	  fnd_global.login_id
   FROM   FND_DESCR_FLEX_CONTEXTS_VL FDFC,
	  FND_DESCRIPTIVE_FLEXS_VL FDFV
   WHERE  FDFC.DESCRIPTIVE_FLEXFIELD_NAME = FDFV.DESCRIPTIVE_FLEXFIELD_NAME
   AND	  FDFC.ENABLED_FLAG = 'Y'
   AND    FDFC.DESCRIPTIVE_FLEX_CONTEXT_CODE <> 'Global Data Elements'
   AND	  FDFV.DESCRIPTIVE_FLEXFIELD_NAME = 'PER_PEOPLE';
  --
  -- Populate Lines table which holds the attribute usage details.
  --
  INSERT INTO PER_PTU_DFF_MAPPING_LINES
  ( MAPPING_LINE_ID,
    MAPPING_HEADER_ID,
    PER_DFF_ATTRIBUTE,
    PER_END_USER_COLUMN_NAME,
    PTU_DFF_CONTEXT_FIELD_CODE,
    PTU_DFF_CONTEXT_FIELD_DESC,
    PTU_DFF_ATTRIBUTE,
    PTU_END_USER_COLUMN_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN )
   SELECT PER_PTU_DFF_MAPPING_LINES_S.nextval,
          MH.MAPPING_HEADER_ID,
	  FDFU.APPLICATION_COLUMN_NAME,
          FDFU.END_USER_COLUMN_NAME,
	  NULL,  -- PTU_DFF_CONTEXT_FIELD_CODE
	  NULL,  -- PTU_DFF_CONTEXT_FIELD_DESC
	  NULL,  -- PTU_DFF_ATTRIBUTE
	  NULL,  -- PTU_END_USER_COLUMN_NAME
          fnd_global.user_id,
	  sysdate,
	  fnd_global.user_id,
	  sysdate,
	  fnd_global.login_id
   FROM   FND_DESCR_FLEX_COL_USAGE_VL FDFU,
          FND_DESCR_FLEX_CONTEXTS_VL FDFC,
	  PER_PTU_DFF_MAPPING_HEADERS MH
   WHERE  FDFU.DESCRIPTIVE_FLEXFIELD_NAME = FDFC.DESCRIPTIVE_FLEXFIELD_NAME
   AND    FDFU.DESCRIPTIVE_FLEX_CONTEXT_CODE   = FDFC.DESCRIPTIVE_FLEX_CONTEXT_CODE
   AND    FDFC.ENABLED_FLAG = 'Y'
   AND    FDFU.ENABLED_FLAG = 'Y'
   AND    FDFC.DESCRIPTIVE_FLEXFIELD_NAME = 'PER_PEOPLE'
   AND    MH.PER_DFF_CONTEXT_FIELD_CODE = FDFC.DESCRIPTIVE_FLEX_CONTEXT_CODE;
  --
  commit;
  --
END populate_mapping_tables;
--
END;

/
