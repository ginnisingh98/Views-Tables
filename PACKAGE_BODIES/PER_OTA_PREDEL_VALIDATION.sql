--------------------------------------------------------
--  DDL for Package Body PER_OTA_PREDEL_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OTA_PREDEL_VALIDATION" as
/* $Header: peperota.pkb 115.3 2002/12/07 00:07:02 dhmulia ship $ */

PROCEDURE ota_predel_job_validation(p_job_id number) is
--
g_dummy_number  number;
--l_sql_text VARCHAR2(2000);
l_status VARCHAR2(1);
l_industry VARCHAR2(1);
--l_oci_out VARCHAR2(1);
--l_sql_cursor NUMBER;
--l_rows_fetched NUMBER;


l_exists	varchar2(1);
--

Cursor CSR_JOB IS
Select null
from   ota_event_associations
where  job_id =  p_job_id;

begin
  --
  --  Check there are no values in ota_event_association
  --
  hr_utility.set_location('PER_OTA_PREDEL_VALIDATION.ota_predel_job_validation', 10);
  --
  --
  --
  -- is ota installed?
  --
  if (fnd_installation.get(appl_id => 810
                          ,dep_appl_id => 810
                          ,status => l_status
                          ,industry => l_industry))
  then
    --
    -- If fully installed (l_status = 'I')
    --
    if l_status = 'I'
    then
  -- Dynamic SQL cursor to get round the problem of Table not existing.
  -- Shouldn't be a problem after 10.6, but better safe than sorry.
  -- This uses a similar method to OCI but Via PL/SQL instead.
  --
  --
    begin
     For job in CSR_JOB
      LOOP
       fnd_message.set_name('PAY','HR_7995_OTA_RECORD_EXISTS');
       fnd_message.raise_error;

      END LOOP;

    end;
    end if;
  end if;
end ota_predel_job_validation;
--
--
PROCEDURE ota_predel_pos_validation(p_position_id number) is
--
l_exists varchar2(1);
l_status VARCHAR2(1);
l_industry VARCHAR2(1);

Cursor CSR_POS IS
Select null
from   ota_event_associations
where  position_id =  p_position_id;

begin
  --
  --  Check there are no values in ota_event_association
  --
  --
  hr_utility.set_location('PER_OTA_PREDEL_VALIDATION.ota_predel_pos_validation', 10);
  --
  --
  -- is ota installed?
  if (fnd_installation.get(appl_id => 810
                          ,dep_appl_id => 810
                          ,status => l_status
                          ,industry => l_industry))
  then
    --
    -- If fully installed (l_status = 'I')
    --
    if l_status = 'I'
    then
      begin
         For pos in CSR_POS
       LOOP
         fnd_message.set_name('PAY','HR_7995_OTA_RECORD_EXISTS');
         fnd_message.raise_error;

       END LOOP;
      end;
    end if;
  end if;
end ota_predel_pos_validation;
--
--
PROCEDURE ota_predel_org_validation(p_organization_id number) is
--
l_exists varchar2(1);
l_status VARCHAR2(1);
l_industry VARCHAR2(1);


CURSOR  CSR_ORG
IS
select null
from sys.dual
where exists(select null
             from   ota_events
             where  organization_id = p_organization_id)
   or exists(select null
             from   ota_delegate_bookings
             where  organization_id = p_organization_id)
   or exists(select null
             from   ota_event_associations
             where  organization_id = p_organization_id)
   or exists( select null
              from   ota_finance_headers
              where  organization_id = p_organization_id)
   or exists( select null from   ota_activity_versions
              where  developer_organization_id = p_organization_id)
   or exists( select null from   ota_events
              where  training_center_id = p_organization_id);
--   or exists( select null from   ota_notrng_histories
--              where  organization_id = p_organization_id)   ;
begin
  --
  --  Check there are no values in ota_delegate_bookings
  --				   ota_events
  --				   ota_event_associations
  --				   ota_finance_headers
  --				   ota_activity_versions
  -- 				   ota_notrng_histories
  --
  hr_utility.set_location('PER_OTA_PREDEL_VALIDATION.ota_predel_org_validation', 10);
  --
  --
  -- is ota installed?
  --
  if (fnd_installation.get(appl_id => 810
                          ,dep_appl_id => 810
                          ,status => l_status
                          ,industry => l_industry))
  then
    --
    -- If fully installed (l_status = 'I')
    --
    if l_status = 'I'
    then
      begin
        For pos in CSR_ORG
         LOOP
          fnd_message.set_name('PAY','HR_7995_OTA_RECORD_EXISTS');
          fnd_message.raise_error;

         END LOOP;
      end;
    end if;
  end if;
end ota_predel_org_validation;
--
--
PROCEDURE ota_predel_per_validation(p_person_id number) is
--
l_exists varchar2(1);
l_status VARCHAR2(1);
l_industry VARCHAR2(1);

CURSOR CSR_PER
IS
select null
from sys.dual
where exists(select null
             from   ota_activity_versions
             where  controlling_person_id = p_person_id)
   or exists(select null
             from   ota_delegate_bookings
             where  delegate_person_id = p_person_id
              or    sponsor_person_id = p_person_id)
   or exists(select null
             from   ota_events
             where  owner_id = p_person_id)
   or exists(select null
             from   ota_notrng_histories
             where  person_id = p_person_id and
                    organization_id is not null);
begin
    --
    --  Check there are no values in ota_delegate_bookings
    --				     ota_activity_versions
    --				     ota_events
    --				     ota_notrng_histories
    --
    hr_utility.set_location('PER_OTA_PREDEL_VALIDATION.ota_predel_per_validation', 10);
    --
    -- is ota installed?
  --
  if (fnd_installation.get(appl_id => 810
                          ,dep_appl_id => 810
                          ,status => l_status
                          ,industry => l_industry))
  then
    --
    -- If fully installed (l_status = 'I')
    --
    if l_status = 'I'
    then
      begin
         For pos in CSR_PER
         LOOP
          fnd_message.set_name('PAY','HR_7995_OTA_RECORD_EXISTS');
          fnd_message.raise_error;

         END LOOP;
      end;
    end if;
  end if;
end ota_predel_per_validation;
--
--
PROCEDURE ota_predel_asg_validation(p_assignment_id number) is
--
l_exists varchar2(1);
l_status VARCHAR2(1);
l_industry VARCHAR2(1);

Cursor CSR_ASG
IS
select null
from   ota_delegate_bookings
where  delegate_assignment_id = p_assignment_id
or        sponsor_assignment_id = p_assignment_id ;


begin
    --
    --  Check there are no values in ota_delegate_bookings
    --
    hr_utility.set_location('PER_OTA_PREDEL_VALIDATION.ota_predel_asg_validation', 10);
    --
    --
    -- is ota installed?
  --
  if (fnd_installation.get(appl_id => 810
                          ,dep_appl_id => 810
                          ,status => l_status
                          ,industry => l_industry))
  then
    --
    -- If fully installed (l_status = 'I')
    --
    if l_status = 'I'
    then
      begin
        For pos in CSR_ASG
         LOOP
          fnd_message.set_name('PAY','HR_7995_OTA_RECORD_EXISTS');
          fnd_message.raise_error;

         END LOOP;
      end;
    end if;
  end if;
end ota_predel_asg_validation;
--
--
END PER_OTA_PREDEL_VALIDATION;

/
