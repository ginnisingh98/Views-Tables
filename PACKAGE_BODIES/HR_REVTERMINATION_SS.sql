--------------------------------------------------------
--  DDL for Package Body HR_REVTERMINATION_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_REVTERMINATION_SS" AS
/* $Header: hrrevtrmwrs.pkb 120.0.12010000.4 2010/05/21 12:52:07 pthoonig noship $ */

  -- Package scope global variables.
  -- The canonical date format has to use hyphens instead of slashes, ie.
  -- "RRRR/MM/DD" will give a java IllegalArgument error because the java
  -- dateValue() is expecting the date string in "rrrr-mm-dd" format.
  -- All date fields are converted to canonical date formats and return to
  -- the java caller.
  g_date_format  constant varchar2(10):='RRRR-MM-DD';
  g_package      constant varchar2(30) := 'HR_REVTERMINATION_SS';
  g_debug  boolean;

cursor csr_person_type(l_person_id Number) is
select pps.SYSTEM_PERSON_TYPE
FROM
PER_PERSON_TYPES pps,
PER_PERSON_TYPE_USAGES_F pptf
where pptf.person_id = l_person_id
AND pptf.person_type_id = pps.person_type_id
AND pptf.effective_start_date = (select max(effective_start_date) from PER_PERSON_TYPE_USAGES_F patf1 where patf1.person_id = pptf.person_id);

cursor csr_get_person_type(l_person_type_id Number) is
select pps.SYSTEM_PERSON_TYPE
from PER_PERSON_TYPES pps
where pps.person_type_id = l_person_type_id;

  /*
  ||===========================================================================
  || PROCEDURE: ex_emp_process_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Save Termination Transaction to transaction table
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Transaction details that need to be saved to transaction table
  ||
  || out nocopy Arguments:
  ||     None.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Writes to transaction table
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */
  PROCEDURE ex_emp_process_save (
                   p_validate    		  in     number  default 0
                  ,p_effective_date               in     varchar2
                  ,p_item_type                    in     wf_items.item_type%TYPE
                  ,p_item_key                     in     wf_items.item_key%TYPE
                  ,p_actid                        in     varchar2
                  ,p_transaction_mode             in     varchar2 DEFAULT '#'
                  ,p_period_of_service_id         in     number    default hr_api.g_number
                  ,p_object_version_number        in     number
                  ,p_person_id                    in     number
                  ,p_login_person_id              in     number
                  ,p_actual_termination_date      in     varchar2
                  ,p_last_standard_process_date   in     varchar2
                  ,p_leaving_reason               in     varchar2
                  ,p_comments                     in     varchar2 default hr_api.g_varchar2
                  ,p_notified_termination_date    in     varchar2
                  ,p_review_proc_call             in     varchar2
                  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
                  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information_category     in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information1             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information2             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information3             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information4             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information5             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information6             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information7             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information8             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information9             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information10            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information11            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information12            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information13            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information14            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information15            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information16            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information17            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information18            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information19            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information20            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information21            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information22            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information23            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information24            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information25            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information26            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information27            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information28            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information29            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information30            in     varchar2 default hr_api.g_varchar2
                  ,p_person_type_id               in number
                  ,p_assignment_status_type_id    in number
                  ,p_rehire_recommendation        in     varchar2 default hr_api.g_varchar2
                  ,p_rehire_reason                in     varchar2 default hr_api.g_varchar2
                  ,p_projected_termination_date   in     varchar2 default hr_api.g_varchar2
                  ,p_final_process_date           in     varchar2 default hr_api.g_varchar2
                   ,p_clear_details               in     varchar2 default 'Y'
                  ,p_error_message                out nocopy    long

                  )

 IS
   lv_cnt                  INTEGER ;
   lv_activity_name          wf_item_activity_statuses_v.activity_name%TYPE;
   ln_transaction_id         NUMBER;
   lv_result                 VARCHAR2(100);
   ltt_trans_step_ids        hr_util_web.g_varchar2_tab_type;
   ln_transaction_step_id    hr_api_transaction_steps.transaction_step_id%TYPE;
   ltt_trans_obj_vers_num    hr_util_web.g_varchar2_tab_type;
   ln_trans_step_rows        NUMBER  default 0;
   ln_ovn                    hr_api_transaction_steps.object_version_number%TYPE;
	 l_person_type VARCHAR2(100);
   l_fut_actns_exist_warning boolean;
   l_actual_termination_date date;
   l_person_type_id          number;

cursor csr_get_person_type_id(l_person_id Number) is
select pps.person_type_id
FROM
PER_PERSON_TYPES pps,
PER_PERSON_TYPE_USAGES_F pptf
where pptf.person_id = l_person_id
AND pptf.person_type_id = pps.person_type_id
AND pps.SYSTEM_PERSON_TYPE = 'EX_EMP';

l_proc constant varchar2(100) := g_package || ' ex_emp_process_save';
 BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);

l_actual_termination_date := to_date(p_actual_termination_date,g_date_format);

SAVEPOINT revterminate_ee;

open csr_get_person_type_id(p_person_id);
fetch csr_get_person_type_id into l_person_type_id;
close csr_get_person_type_id;

IF p_transaction_mode <> 'SAVE_FOR_LATER' THEN

open csr_get_person_type(l_person_type_id);
fetch csr_get_person_type into l_person_type;
close csr_get_person_type;

if l_person_type = 'EX_EMP' then

hr_ex_employee_api.reverse_terminate_employee
  (p_validate => false
  ,p_person_id  => p_person_id
  ,p_actual_termination_date => l_actual_termination_date
  ,p_clear_details      => p_clear_details
  );
end if;

    IF hr_java_conv_util_ss.get_boolean (p_number => p_validate)
    THEN
       -- validate mode is true, rollback all the changes
       rollback to revterminate_ee;
    END IF;
--Now dump the data in transaction table
END IF;

lv_cnt := 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PERSON_ID';
  gtt_transaction_steps(lv_cnt).param_value := p_person_id;
  gtt_transaction_steps(lv_cnt).param_data_type := 'NUMBER';


  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_EFFECTIVE_DATE';
  gtt_transaction_steps(lv_cnt).param_value := p_effective_date;
  gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_OBJECT_VERSION_NUMBER';
  gtt_transaction_steps(lv_cnt).param_value := p_object_version_number;
  gtt_transaction_steps(lv_cnt).param_data_type := 'NUMBER';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PERSON_TYPE_ID';
  gtt_transaction_steps(lv_cnt).param_value := l_person_type_id;
  gtt_transaction_steps(lv_cnt).param_data_type := 'NUMBER';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PERIODS_OF_SERVICE_ID';
  gtt_transaction_steps(lv_cnt).param_value := p_period_of_service_id;
  gtt_transaction_steps(lv_cnt).param_data_type := 'NUMBER';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ACTUAL_TERMINATION_DATE';
  gtt_transaction_steps(lv_cnt).param_value := p_actual_termination_date;
  gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';

 -- IF p_final_process_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    gtt_transaction_steps(lv_cnt).param_name := 'P_FINAL_PROCESS_DATE';
    gtt_transaction_steps(lv_cnt).param_value := p_final_process_date;
    gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';
--  END IF;

 -- IF p_notified_termination_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    gtt_transaction_steps(lv_cnt).param_name := 'P_NOTIFIED_TERMINATION_DATE';
    gtt_transaction_steps(lv_cnt).param_value := p_notified_termination_date;
    gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';
 -- END IF;

 -- IF p_last_standard_process_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    gtt_transaction_steps(lv_cnt).param_name := 'P_LAST_STANDARD_PROCESS_DATE';
    gtt_transaction_steps(lv_cnt).param_value := p_last_standard_process_date;
    gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';
 -- END IF;

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_TERMINATION_REASON';
  gtt_transaction_steps(lv_cnt).param_value := p_leaving_reason;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

--  IF p_projected_termination_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    gtt_transaction_steps(lv_cnt).param_name := 'P_PROJECTED_TERMINATION_DATE';
    gtt_transaction_steps(lv_cnt).param_value := p_projected_termination_date;
    gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';
 -- END IF;

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_REHIRE_RECOMMENDATION';
  gtt_transaction_steps(lv_cnt).param_value := p_rehire_recommendation;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_REHIRE_REASON';
  gtt_transaction_steps(lv_cnt).param_value := p_rehire_reason;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_COMMENTS';
  gtt_transaction_steps(lv_cnt).param_value := p_comments;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';
  ------------------------------------------------------------
  -- DFF Segments
  ------------------------------------------------------------
  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE_CATEGORY';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute_category;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE1';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute1;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE2';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute2;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE3';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute3;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE4';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute4;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE5';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute5;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE6';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute6;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE7';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute7;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE8';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute8;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE9';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute9;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE10';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute10;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE11';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute11;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE12';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute12;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE13';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute13;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE14';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute14;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE15';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute15;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE16';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute16;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE17';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute17;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE18';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute18;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE19';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute19;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE20';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute20;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';


  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION_CATEGORY';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information_category;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION1';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information1;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION2';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information2;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION3';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information3;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION4';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information4;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION5';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information5;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION6';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information6;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION7';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information7;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION8';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information8;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION9';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information9;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION10';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information10;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION11';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information11;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION12';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information12;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION13';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information13;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION14';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information14;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION15';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information15;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION16';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information16;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION17';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information17;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION18';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information18;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION19';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information19;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION20';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information20;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

      lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION21';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information21;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION22';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information22;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION23';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information23;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION24';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information24;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION25';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information25;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION26';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information26;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION27';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information27;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION28';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information28;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION29';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information29;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PDS_INFORMATION30';
  gtt_transaction_steps(lv_cnt).param_value := p_pds_information30;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_CLEAR_DETAILS';
  gtt_transaction_steps(lv_cnt).param_value := p_clear_details;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

    ----------------------------------------------------------------------
    -- Store the activity internal name for this particular
    -- activity with other information.
    ----------------------------------------------------------------------
    lv_activity_name := hr_revtermination_ss.gv_TERMINATION_ACTIVITY_NAME;
     lv_cnt := lv_cnt + 1;
    hr_revtermination_ss.gtt_transaction_steps(lv_cnt).param_name
      := 'P_ACTIVITY_NAME';
    hr_revtermination_ss.gtt_transaction_steps(lv_cnt).param_value
      := lv_activity_name;
    hr_revtermination_ss.gtt_transaction_steps(lv_cnt).param_data_type
      := 'VARCHAR2';

     ----------------------------------------------------------------------
    -- Store the the Review Procedure Call and
    -- activity id with other information.
    ----------------------------------------------------------------------
     lv_cnt := lv_cnt + 1;
    hr_revtermination_ss.gtt_transaction_steps(lv_cnt).param_name
      := 'P_REVIEW_PROC_CALL';
    hr_revtermination_ss.gtt_transaction_steps(lv_cnt).param_value
      := p_review_proc_call;
    hr_revtermination_ss.gtt_transaction_steps(lv_cnt).param_data_type
      := 'VARCHAR2';

     lv_cnt := lv_cnt + 1;
    hr_revtermination_ss.gtt_transaction_steps(lv_cnt).param_name
      := 'P_REVIEW_ACTID';
    hr_revtermination_ss.gtt_transaction_steps(lv_cnt).param_value
      := p_actid;
    hr_revtermination_ss.gtt_transaction_steps(lv_cnt).param_data_type
      := 'VARCHAR2';

    ---------------------------------------------------------------------
    -- Check if there is already a transaction for this process?
    ---------------------------------------------------------------------
    ln_transaction_id := hr_transaction_ss.get_transaction_id (
                           p_Item_Type => p_item_type,
                           p_Item_Key  => p_item_key
                         );

     IF ln_transaction_id IS NULL
    THEN

      -------------------------------------------------------------------
      -- Create a new transaction
      -------------------------------------------------------------------
      hr_transaction_ss.start_transaction (
        itemtype                => p_item_type,
        itemkey                 => p_item_key,
        actid                   => TO_NUMBER(p_actid),
        funmode                 => 'RUN',
        p_login_person_id       => p_login_person_id,
        result                  => lv_result
      );

      ln_transaction_id := hr_transaction_ss.get_transaction_id (
                             p_Item_Type => p_item_type,
                             p_Item_Key => p_item_key
                           );
    END IF;

    ---------------------------------------------------------------------
    -- There is already a transaction for this process.
    -- Retieve the transaction step for this current
    -- activity. We will update this transaction step with
    -- the new information.
    ---------------------------------------------------------------------
    hr_transaction_api.get_transaction_step_info (
      p_Item_Type             => p_item_type,
      p_Item_Key              => p_item_key,
      p_activity_id           => to_number(p_actid),
      p_transaction_step_id   => ltt_trans_step_ids,
      p_object_version_number => ltt_trans_obj_vers_num,
      p_rows                  => ln_trans_step_rows
    );

    IF ln_trans_step_rows < 1
    THEN

      --------------------------------------------------------------------
      -- There is no transaction step for this transaction.
      -- Create a step within this new transaction
      --------------------------------------------------------------------
      hr_transaction_api.create_transaction_step (
        p_validate              => false,
        p_creator_person_id     => p_login_person_id,
        p_transaction_id        => ln_transaction_id,
        p_api_name              => g_package || '.PROCESS_API',
        p_Item_Type             => p_item_type,
        p_Item_Key              => p_item_key,
        p_activity_id           => TO_NUMBER(p_actid),
        p_transaction_step_id   => ln_transaction_step_id,
        p_object_version_number => ln_ovn
      );
    ELSE

      --------------------------------------------------------------------
      -- There are transaction steps for this transaction.
      -- Get the Transaction Step ID for this activity.
      --------------------------------------------------------------------
      ln_transaction_step_id  :=
        hr_transaction_ss.get_activity_trans_step_id (
          p_activity_name     => lv_activity_name,
          p_trans_step_id_tbl => ltt_trans_step_ids
        );

    END IF;

    hr_transaction_ss.save_transaction_step (
      p_item_Type           => p_item_type,
      p_item_Key            => p_item_key,
      p_actid               => TO_NUMBER(p_actid),
      p_login_person_id     => p_login_person_id,
      p_transaction_step_id => ln_transaction_step_id,
      p_api_name            => 'hr_revtermination_ss.ex_emp_process_save',
      p_transaction_data    => hr_revtermination_ss.gtt_transaction_steps
    );
--end of transaction logic
hr_utility.set_location('Leaving: '|| l_proc,20);
 EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
hr_utility.set_location('EXCEPTION: '|| SQLERRM,555);
   p_error_message := hr_utility.get_message;
   -- rollback the changes in case of exception
      rollback to revterminate_ee;


 END ex_emp_process_save;



PROCEDURE ex_cwk_process_save
(  p_validate                      in     number  default 0
  ,p_item_type                    in     wf_items.item_type%TYPE
  ,p_item_key                     in     wf_items.item_key%TYPE
  ,p_actid                        in     varchar2
  ,p_transaction_mode             in     varchar2 DEFAULT '#'
  ,p_effective_date               in     varchar2
  ,p_person_id                    in     number
  ,p_date_start                   in     varchar2
  ,p_object_version_number        in     number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_actual_termination_date      in     varchar2      default to_char(hr_api.g_date)
  ,p_final_process_date           in     varchar2
  ,p_last_standard_process_date   in     varchar2
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_projected_termination_date   in     varchar2      default to_char(hr_api.g_date)
  ,p_rehire_recommendation        in     varchar2  default hr_api.g_varchar2
  ,p_rehire_reason                in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_review_proc_call             in     varchar2  default hr_api.g_varchar2
  ,p_effective_date_option        in     varchar2  default hr_api.g_varchar2
  ,p_login_person_id              in     number
  ,p_clear_details                 in     varchar2 default 'Y'
  ,p_fut_actns_exist_warning         out nocopy number
  ,p_error_message                 out nocopy    long

) Is

  -- Local params for Saving Transaction
  lv_cnt                    integer;
  lv_activity_name          wf_item_activity_statuses_v.activity_name%TYPE;
  lv_result                 varchar2(100);
  ln_transaction_id         number;
  ltt_trans_obj_vers_num    hr_util_web.g_varchar2_tab_type;
  ln_trans_step_rows        NUMBER  default 0;
  ltt_trans_step_ids        hr_util_web.g_varchar2_tab_type;
  ln_transaction_step_id    hr_api_transaction_steps.transaction_step_id%TYPE;
  ln_ovn                    hr_api_transaction_steps.object_version_number%TYPE;

  -- In out params for terminate_placement
  l_object_version_number      per_periods_of_placement.object_version_number%TYPE;
  l_final_process_date         per_periods_of_placement.final_process_Date%TYPE;
  l_last_standard_process_date
               per_periods_of_placement.last_standard_process_date%TYPE;

	l_person_type varchar2(50);
  l_actual_termination_date date;
  l_fut_actns_exist_warning boolean;
  l_person_type_id          number;

cursor csr_get_person_type_id(l_person_id Number) is
select pps.person_type_id
FROM
PER_PERSON_TYPES pps,
PER_PERSON_TYPE_USAGES_F pptf
where pptf.person_id = l_person_id
AND pptf.person_type_id = pps.person_type_id
AND pps.SYSTEM_PERSON_TYPE = 'EX_CWK';

  l_proc constant varchar2(100) := g_package || ' ex_cwk_process_save';


BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
p_fut_actns_exist_warning := 0;
l_actual_termination_date := to_date(p_actual_termination_date,g_date_format);

SAVEPOINT revterminate_ee;

open csr_get_person_type_id(p_person_id);
fetch csr_get_person_type_id into l_person_type_id;
close csr_get_person_type_id;

IF p_transaction_mode <> 'SAVE_FOR_LATER' THEN
open csr_get_person_type(l_person_type_id);
fetch csr_get_person_type into l_person_type;
close csr_get_person_type;


if l_person_type = 'EX_CWK' then

hr_contingent_worker_api.reverse_terminate_placement
  (p_validate  => false
  ,p_person_id   => p_person_id
  ,p_actual_termination_date => l_actual_termination_date
  ,p_clear_details   => p_clear_details
  ,p_fut_actns_exist_warning  => l_fut_actns_exist_warning
  );

	if l_fut_actns_exist_warning then
		p_fut_actns_exist_warning := 1;
	else
		p_fut_actns_exist_warning := 0;
	end if;

end if;

    IF hr_java_conv_util_ss.get_boolean (p_number => p_validate)
    THEN
       -- validate mode is true, rollback all the changes
       rollback to revterminate_ee;
    END IF;
end if;
  ---- All validations successful, proceed and save transaction.

  lv_cnt := 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PERSON_ID';
  gtt_transaction_steps(lv_cnt).param_value := p_person_id;
  gtt_transaction_steps(lv_cnt).param_data_type := 'NUMBER';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_DATE_START';
  gtt_transaction_steps(lv_cnt).param_value := p_date_start;
  gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_EFFECTIVE_DATE';
  gtt_transaction_steps(lv_cnt).param_value := p_effective_date;
  gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_OBJECT_VERSION_NUMBER';
  gtt_transaction_steps(lv_cnt).param_value := p_object_version_number;
  gtt_transaction_steps(lv_cnt).param_data_type := 'NUMBER';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_PERSON_TYPE_ID';
  gtt_transaction_steps(lv_cnt).param_value := l_person_type_id;
  gtt_transaction_steps(lv_cnt).param_data_type := 'NUMBER';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ACTUAL_TERMINATION_DATE';
  gtt_transaction_steps(lv_cnt).param_value := p_actual_termination_date;
  gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';

  IF p_final_process_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    gtt_transaction_steps(lv_cnt).param_name := 'P_FINAL_PROCESS_DATE';
    gtt_transaction_steps(lv_cnt).param_value := p_final_process_date;
    gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';
  END IF;

  IF p_last_standard_process_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    gtt_transaction_steps(lv_cnt).param_name := 'P_LAST_STANDARD_PROCESS_DATE';
    gtt_transaction_steps(lv_cnt).param_value := p_last_standard_process_date;
    gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';
  END IF;

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_TERMINATION_REASON';
  gtt_transaction_steps(lv_cnt).param_value := p_termination_reason;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  IF p_projected_termination_date IS NOT NULL THEN
    lv_cnt := lv_cnt + 1;
    gtt_transaction_steps(lv_cnt).param_name := 'P_PROJECTED_TERMINATION_DATE';
    gtt_transaction_steps(lv_cnt).param_value := p_projected_termination_date;
    gtt_transaction_steps(lv_cnt).param_data_type := 'DATE';
  END IF;

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_REHIRE_RECOMMENDATION';
  gtt_transaction_steps(lv_cnt).param_value := p_rehire_recommendation;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_REHIRE_REASON';
  gtt_transaction_steps(lv_cnt).param_value := p_rehire_reason;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  ------------------------------------------------------------
  -- DFF Segments
  ------------------------------------------------------------
  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE_CATEGORY';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute_category;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE1';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute1;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE2';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute2;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE3';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute3;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE4';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute4;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE5';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute5;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE6';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute6;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE7';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute7;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE8';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute8;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE9';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute9;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE10';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute10;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE11';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute11;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE12';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute12;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE13';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute13;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE14';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute14;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE15';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute15;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE16';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute16;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE17';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute17;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE18';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute18;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE19';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute19;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE20';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute20;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE21';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute21;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE22';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute22;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE23';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute23;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE24';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute24;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE25';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute25;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE26';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute26;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE27';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute27;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE28';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute28;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE29';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute29;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ATTRIBUTE30';
  gtt_transaction_steps(lv_cnt).param_value := p_attribute30;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION_CATEGORY';
  gtt_transaction_steps(lv_cnt).param_value := p_information_category;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION1';
  gtt_transaction_steps(lv_cnt).param_value := p_information1;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION2';
  gtt_transaction_steps(lv_cnt).param_value := p_information2;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION3';
  gtt_transaction_steps(lv_cnt).param_value := p_information3;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION4';
  gtt_transaction_steps(lv_cnt).param_value := p_information4;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION5';
  gtt_transaction_steps(lv_cnt).param_value := p_information5;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION6';
  gtt_transaction_steps(lv_cnt).param_value := p_information6;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION7';
  gtt_transaction_steps(lv_cnt).param_value := p_information7;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION8';
  gtt_transaction_steps(lv_cnt).param_value := p_information8;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION9';
  gtt_transaction_steps(lv_cnt).param_value := p_information9;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION10';
  gtt_transaction_steps(lv_cnt).param_value := p_information10;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION11';
  gtt_transaction_steps(lv_cnt).param_value := p_information11;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION12';
  gtt_transaction_steps(lv_cnt).param_value := p_information12;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION13';
  gtt_transaction_steps(lv_cnt).param_value := p_information13;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION14';
  gtt_transaction_steps(lv_cnt).param_value := p_information14;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION15';
  gtt_transaction_steps(lv_cnt).param_value := p_information15;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION16';
  gtt_transaction_steps(lv_cnt).param_value := p_information16;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION17';
  gtt_transaction_steps(lv_cnt).param_value := p_information17;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION18';
  gtt_transaction_steps(lv_cnt).param_value := p_information18;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION19';
  gtt_transaction_steps(lv_cnt).param_value := p_information19;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION20';
  gtt_transaction_steps(lv_cnt).param_value := p_information20;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

      lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION21';
  gtt_transaction_steps(lv_cnt).param_value := p_information21;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION22';
  gtt_transaction_steps(lv_cnt).param_value := p_information22;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION23';
  gtt_transaction_steps(lv_cnt).param_value := p_information23;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION24';
  gtt_transaction_steps(lv_cnt).param_value := p_information24;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION25';
  gtt_transaction_steps(lv_cnt).param_value := p_information25;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION26';
  gtt_transaction_steps(lv_cnt).param_value := p_information26;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION27';
  gtt_transaction_steps(lv_cnt).param_value := p_information27;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION28';
  gtt_transaction_steps(lv_cnt).param_value := p_information28;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION29';
  gtt_transaction_steps(lv_cnt).param_value := p_information29;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_INFORMATION30';
  gtt_transaction_steps(lv_cnt).param_value := p_information30;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_CLEAR_DETAILS';
  gtt_transaction_steps(lv_cnt).param_value := p_clear_details;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  ----------------------------------------------------------------------
  -- Store the activity internal name for this particular
  -- activity with other information.
  ----------------------------------------------------------------------
  lv_activity_name := HR_REVTERMINATION_SS.gv_TERMINATION_ACTIVITY_NAME;
  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_ACTIVITY_NAME';
  gtt_transaction_steps(lv_cnt).param_value := lv_activity_name;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  ----------------------------------------------------------------------
  -- Store the the Review Procedure Call and
  -- activity id with other information.
  ----------------------------------------------------------------------
  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_REVIEW_PROC_CALL';
  IF p_review_proc_call IS NULL THEN
      gtt_transaction_steps(lv_cnt).param_value
          := wf_engine.GetActivityAttrText( p_item_type,p_item_key, p_actid
                                        ,'HR_REVIEW_REGION_ITEM', False);
  ELSE
      gtt_transaction_steps(lv_cnt).param_value := p_review_proc_call;
  END IF;

  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';
  lv_cnt := lv_cnt + 1;
  gtt_transaction_steps(lv_cnt).param_name := 'P_REVIEW_ACTID';
  gtt_transaction_steps(lv_cnt).param_value := p_actid;
  gtt_transaction_steps(lv_cnt).param_data_type := 'VARCHAR2';

  -------------------------------------------------------------------
  -- Check if Transaction Already Exists !
  -------------------------------------------------------------------

  ln_transaction_id := hr_transaction_ss.get_transaction_id (
                            p_Item_Type => p_item_type,
                            p_Item_Key  => p_item_key
                       );

  IF ln_transaction_id IS NULL THEN
    -- Create a New Transaction
    hr_transaction_ss.start_transaction (
        itemtype                => p_item_type,
        itemkey                 => p_item_key,
        actid                   => TO_NUMBER(p_actid),
        funmode                 => 'RUN',
        p_effective_date_option => p_effective_date_option,
        p_login_person_id       => p_login_person_id,
        result                  => lv_result
    );

    ln_transaction_id := hr_transaction_ss.get_transaction_id (
                            p_Item_Type => p_item_type,
                            p_Item_Key  => p_item_key
                         );
  END IF;

  ---------------------------------------------------------------------
  -- There is already a transaction for this process.
  -- Retieve the transaction step for this current
  -- activity. We will update this transaction step with
  -- the new information.
  ---------------------------------------------------------------------

    hr_transaction_api.get_transaction_step_info(
             p_item_type                => p_item_type
            ,p_item_key                 => p_item_key
            ,p_activity_id              => to_number(p_actid)
            ,p_transaction_step_id      => ltt_trans_step_ids
            ,p_object_version_number    => ltt_trans_obj_vers_num
            ,p_rows                     => ln_trans_step_rows
         );

    IF ln_trans_step_rows < 1
    THEN
      --------------------------------------------------------------------
      -- There is no transaction step for this transaction.
      -- Create a step within this new transaction
      --------------------------------------------------------------------
      hr_transaction_api.create_transaction_step (
        p_validate              => false,
        p_creator_person_id     => p_login_person_id,
        p_transaction_id        => ln_transaction_id,
        p_api_name              => g_package || '.PROCESS_API',
        p_Item_Type             => p_item_type,
        p_Item_Key              => p_item_key,
        p_activity_id           => TO_NUMBER(p_actid),
        p_transaction_step_id   => ln_transaction_step_id,
        p_object_version_number => ln_ovn
      );
    ELSE
      --------------------------------------------------------------------
      -- There are transaction steps for this transaction.
      -- Get the Transaction Step ID for this activity.
      --------------------------------------------------------------------
      ln_transaction_step_id  :=
        hr_transaction_ss.get_activity_trans_step_id (
          p_activity_name     => lv_activity_name,
          p_trans_step_id_tbl => ltt_trans_step_ids
        );

    END IF;
    -- Save Transaction Step.

    hr_transaction_ss.save_transaction_step (
      p_item_Type           => p_item_type,
      p_item_Key            => p_item_key,
      p_actid               => TO_NUMBER(p_actid),
      p_login_person_id     => p_login_person_id,
      p_transaction_step_id => ln_transaction_step_id,
      p_api_name            => 'hr_revtermination_ss.ex_cwk_process_save',
      p_transaction_data    => gtt_transaction_steps
    );

EXCEPTION
when others then
hr_utility.set_location('EXCEPTION: '|| l_proc,555);
   p_error_message := hr_utility.get_message;
   -- rollback the changes in case of exception
      rollback to revterminate_ee;

END ex_cwk_process_save;
  /*
  ||=======================================================================
  || PROCEDURE   : process_api
  || DESCRIPTION : This procedure gets data stored in the transaction table
  ||             : and call the APIs in update mode
  ||=======================================================================
  */
  PROCEDURE process_api (
    p_validate            IN BOOLEAN DEFAULT FALSE,
    p_transaction_step_id IN NUMBER DEFAULT NULL,
    p_effective_date      IN VARCHAR2 DEFAULT NULL
  )
  IS

    -- For SAVE_FOR_LATER


    lv_rehire_recommendation        per_all_people_f.rehire_recommendation%TYPE;
    lv_rehire_reason                per_all_people_f.rehire_reason%TYPE;
    lv_person_id                    per_periods_of_placement.person_id%TYPE;
    lv_actual_termination_date      per_periods_of_placement.actual_termination_date%TYPE;
    lv_clear_details varchar2(10) default 'Y';
    l_person_type varchar2(25);
    l_fut_actns_exist_warning boolean;
    l_proc    varchar2(100) := g_package ||'process_api';
    l_person_type_id                number;

    -- to print the error message
    l_err_msg                     long default null;

  BEGIN

    hr_utility.set_location('Entering: ' || l_proc,5  );

lv_person_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERSON_ID');

l_person_type_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERSON_TYPE_ID');

     open csr_get_person_type(l_person_type_id);
fetch csr_get_person_type into l_person_type;
close csr_get_person_type;

savepoint ex_emp_savepoint;

if l_person_type = 'EX_CWK' then


              lv_actual_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ACTUAL_TERMINATION_DATE');

    lv_clear_details :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_CLEAR_DETAILS');


hr_contingent_worker_api.reverse_terminate_placement
  (p_validate  => p_validate
  ,p_person_id   => lv_person_id
  ,p_actual_termination_date => lv_actual_termination_date
  ,p_clear_details   => lv_clear_details
  ,p_fut_actns_exist_warning  => l_fut_actns_exist_warning
  );


end if;

if l_person_type = 'EX_EMP' then


   lv_actual_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ACTUAL_TERMINATION_DATE');

    lv_clear_details :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_CLEAR_DETAILS');


 hr_ex_employee_api.reverse_terminate_employee
  (p_validate => false
  ,p_person_id  => lv_person_id
  ,p_actual_termination_date => lv_actual_termination_date
  ,p_clear_details      => lv_clear_details
  );


end if;

hr_utility.set_location(' Leaving: ' || l_proc,15);

EXCEPTION
   WHEN OTHERS THEN
     l_err_msg := hr_utility.get_message;
     hr_utility.set_location('EXCEPTION '|| l_err_msg || ':  ' || l_proc,5600);
     rollback to ex_emp_savepoint;
     RAISE;
END process_api;

procedure checkPersonType( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     )

is
  -- local variables
   c_proc constant varchar2(30) := 'checkPersonType';
   lv_person_id  per_all_people_f.person_id%type;
   l_person_type VARCHAR2(100) default 'EX_EMP';

begin
   g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
     end if;
   if ( funmode = wf_engine.eng_run ) then
        begin
    		lv_person_id:=wf_engine.getitemattrnumber(p_item_type,p_item_key,'CURRENT_PERSON_ID',true);
		open csr_person_type(lv_person_id);
		fetch csr_person_type into l_person_type;
		close csr_person_type;
        exception
  	when others then
    	null;
    end;
   end if;

  result := l_person_type;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    raise;
end checkPersonType;
PROCEDURE getCwkTransactionDetails
(  p_transaction_step_id          in      varchar2
  ,p_person_id                    out nocopy     number
  ,p_date_start                   out nocopy     Date
  ,p_object_version_number        out nocopy     number
  ,p_person_type_id               out nocopy     number
  ,p_actual_termination_date      out nocopy     Date
  ,p_final_process_date           out nocopy     Date
  ,p_last_standard_process_date   out nocopy     Date
  ,p_termination_reason           out nocopy     varchar2
  ,p_rehire_recommendation        out nocopy     varchar2
  ,p_rehire_reason                out nocopy     varchar2
  ,p_projected_termination_date   out nocopy     Date
  ,p_attribute_category           out nocopy     varchar2
  ,p_attribute1                   out nocopy     varchar2
  ,p_attribute2                   out nocopy     varchar2
  ,p_attribute3                   out nocopy     varchar2
  ,p_attribute4                   out nocopy     varchar2
  ,p_attribute5                   out nocopy     varchar2
  ,p_attribute6                   out nocopy     varchar2
  ,p_attribute7                   out nocopy     varchar2
  ,p_attribute8                   out nocopy     varchar2
  ,p_attribute9                   out nocopy     varchar2
  ,p_attribute10                  out nocopy     varchar2
  ,p_attribute11                  out nocopy     varchar2
  ,p_attribute12                  out nocopy     varchar2
  ,p_attribute13                  out nocopy     varchar2
  ,p_attribute14                  out nocopy     varchar2
  ,p_attribute15                  out nocopy     varchar2
  ,p_attribute16                  out nocopy     varchar2
  ,p_attribute17                  out nocopy     varchar2
  ,p_attribute18                  out nocopy     varchar2
  ,p_attribute19                  out nocopy     varchar2
  ,p_attribute20                  out nocopy     varchar2
  ,p_attribute21                  out nocopy     varchar2
  ,p_attribute22                  out nocopy     varchar2
  ,p_attribute23                  out nocopy     varchar2
  ,p_attribute24                  out nocopy     varchar2
  ,p_attribute25                  out nocopy     varchar2
  ,p_attribute26                  out nocopy     varchar2
  ,p_attribute27                  out nocopy     varchar2
  ,p_attribute28                  out nocopy     varchar2
  ,p_attribute29                  out nocopy     varchar2
  ,p_attribute30                  out nocopy     varchar2
  ,p_information_category         out NOCOPY     varchar2
  ,p_information1                 out nocopy     varchar2
  ,p_information2                 out nocopy     varchar2
  ,p_information3                 out nocopy     varchar2
  ,p_information4                 out nocopy     varchar2
  ,p_information5                 out nocopy     varchar2
  ,p_information6                 out nocopy     varchar2
  ,p_information7                 out nocopy     varchar2
  ,p_information8                 out nocopy     varchar2
  ,p_information9                 out nocopy     varchar2
  ,p_information10                out nocopy     varchar2
  ,p_information11                out nocopy     varchar2
  ,p_information12                out nocopy     varchar2
  ,p_information13                out nocopy     varchar2
  ,p_information14                out nocopy     varchar2
  ,p_information15                out nocopy     varchar2
  ,p_information16                out nocopy     varchar2
  ,p_information17                out nocopy     varchar2
  ,p_information18                out nocopy     varchar2
  ,p_information19                out nocopy     varchar2
  ,p_information20                out nocopy     varchar2
  ,p_information21                out nocopy     varchar2
  ,p_information22                out nocopy     varchar2
  ,p_information23                out nocopy     varchar2
  ,p_information24                out nocopy     varchar2
  ,p_information25                out nocopy     varchar2
  ,p_information26                out nocopy     varchar2
  ,p_information27                out nocopy     varchar2
  ,p_information28                out nocopy     varchar2
  ,p_information29                out nocopy     varchar2
  ,p_information30                out nocopy     varchar2
  ,p_clear_details                out nocopy     varchar2
) IS

l_proc    varchar2(72) := g_package ||'getCwkTransactionDetails';

BEGIN

hr_utility.set_location('Entering:' || l_proc, 5);
  --
    p_person_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERSON_ID');
  --
    p_date_start :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_DATE_START');
  --
    p_object_version_number :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_OBJECT_VERSION_NUMBER');
  --
    p_person_type_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERSON_TYPE_ID');

    p_actual_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ACTUAL_TERMINATION_DATE');
  --
    p_final_process_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_FINAL_PROCESS_DATE');
  --
    p_last_standard_process_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_LAST_STANDARD_PROCESS_DATE');
  --
    p_termination_reason :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_TERMINATION_REASON');
  --
    p_rehire_recommendation :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REHIRE_RECOMMENDATION');
  --
    p_rehire_reason :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REHIRE_REASON');
  --
    p_projected_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PROJECTED_TERMINATION_DATE');
  --
    p_attribute_category :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE_CATEGORY');
  --
    p_attribute1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE1');
  --
    p_attribute2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE2');
  --
    p_attribute3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE3');
  --
    p_attribute4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE4');
  --
    p_attribute5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE5');
  --
    p_attribute6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE6');
  --
    p_attribute7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE7');
  --
    p_attribute8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE8');
  --
    p_attribute9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE9');
  --
    p_attribute10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE10');
  --
    p_attribute11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE11');
  --
    p_attribute12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE12');
  --
    p_attribute13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE13');
  --
    p_attribute14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE14');
  --
    p_attribute15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE15');
  --
    p_attribute16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE16');
  --
    p_attribute17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE17');
  --
    p_attribute18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE18');
  --
    p_attribute19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE19');
  --
    p_attribute20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE20');
  --
    p_attribute21 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE21');
  --
    p_attribute22 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE22');
  --
    p_attribute23 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE23');
  --
    p_attribute24 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE24');
  --
    p_attribute25 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE25');
  --
    p_attribute26 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE26');
  --
    p_attribute27 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE27');
  --
    p_attribute28 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE28');
  --
    p_attribute29 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE29');
  --
    p_attribute30 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE30');
  --
    p_information_category :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION_CATEGORY');
  --
    p_information1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION1');
  --
    p_information2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION2');
  --
    p_information3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION3');
  --
    p_information4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION4');
  --
    p_information5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION5');
  --
    p_information6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION6');
  --
    p_information7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION7');
  --
    p_information8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION8');
  --
    p_information9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION9');
  --
    p_information10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION10');
  --
    p_information11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION11');
  --
    p_information12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION12');
  --
    p_information13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION13');
  --
    p_information14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION14');
  --
    p_information15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION15');
  --
    p_information16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION16');
  --
    p_information17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION17');
  --
    p_information18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION18');
  --
    p_information19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION19');
  --
    p_information20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION20');

  --
    p_information21 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION21');
  --
    p_information22 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION22');
  --
    p_information23 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION23');
  --
    p_information24 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION24');
  --
    p_information25 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION25');
  --
    p_information26 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION26');
  --
    p_information27 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION27');
  --
    p_information28 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION28');
  --
    p_information29 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION29');
  --
    p_information30 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_INFORMATION30');

		p_clear_details :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_CLEAR_DETAILS');

hr_utility.set_location('SSHR: Leaving:' || l_proc, 10);

END getCwkTransactionDetails;

PROCEDURE getEmpTransactionDetails
(  p_transaction_step_id          in      varchar2
  ,p_person_id                    out nocopy     number
  ,period_of_service_id           out nocopy     number
  ,p_object_version_number        out nocopy     number
  ,p_actual_termination_date      out nocopy     Date
  ,p_leaving_reason                out nocopy    varchar2
  ,p_notified_termination_date     out nocopy    Date
  ,p_comments                      out nocopy    varchar2
  ,p_last_standard_process_date    out nocopy    Date
  ,p_projected_termination_date   out nocopy     Date
  ,p_final_process_date           out nocopy     Date
  ,p_rehire_recommendation       out nocopy    varchar2
  ,p_attribute_category           out nocopy     varchar2
  ,p_attribute1                   out nocopy     varchar2
  ,p_attribute2                   out nocopy     varchar2
  ,p_attribute3                   out nocopy     varchar2
  ,p_attribute4                   out nocopy     varchar2
  ,p_attribute5                   out nocopy     varchar2
  ,p_attribute6                   out nocopy     varchar2
  ,p_attribute7                   out nocopy     varchar2
  ,p_attribute8                   out nocopy     varchar2
  ,p_attribute9                   out nocopy     varchar2
  ,p_attribute10                  out nocopy     varchar2
  ,p_attribute11                  out nocopy     varchar2
  ,p_attribute12                  out nocopy     varchar2
  ,p_attribute13                  out nocopy     varchar2
  ,p_attribute14                  out nocopy     varchar2
  ,p_attribute15                  out nocopy     varchar2
  ,p_attribute16                  out nocopy     varchar2
  ,p_attribute17                  out nocopy     varchar2
  ,p_attribute18                  out nocopy     varchar2
  ,p_attribute19                  out nocopy     varchar2
  ,p_attribute20                  out nocopy     varchar2
  ,p_pds_information_category         out NOCOPY     varchar2
  ,p_pds_information1                 out nocopy     varchar2
  ,p_pds_information2                 out nocopy     varchar2
  ,p_pds_information3                 out nocopy     varchar2
  ,p_pds_information4                 out nocopy     varchar2
  ,p_pds_information5                 out nocopy     varchar2
  ,p_pds_information6                 out nocopy     varchar2
  ,p_pds_information7                 out nocopy     varchar2
  ,p_pds_information8                 out nocopy     varchar2
  ,p_pds_information9                 out nocopy     varchar2
  ,p_pds_information10                out nocopy     varchar2
  ,p_pds_information11                out nocopy     varchar2
  ,p_pds_information12                out nocopy     varchar2
  ,p_pds_information13                out nocopy     varchar2
  ,p_pds_information14                out nocopy     varchar2
  ,p_pds_information15                out nocopy     varchar2
  ,p_pds_information16                out nocopy     varchar2
  ,p_pds_information17                out nocopy     varchar2
  ,p_pds_information18                out nocopy     varchar2
  ,p_pds_information19                out nocopy     varchar2
  ,p_pds_information20                out nocopy     varchar2
  ,p_pds_information21                out nocopy     varchar2
  ,p_pds_information22                out nocopy     varchar2
  ,p_pds_information23                out nocopy     varchar2
  ,p_pds_information24                out nocopy     varchar2
  ,p_pds_information25                out nocopy     varchar2
  ,p_pds_information26                out nocopy     varchar2
  ,p_pds_information27                out nocopy     varchar2
  ,p_pds_information28                out nocopy     varchar2
  ,p_pds_information29                out nocopy     varchar2
  ,p_pds_information30                out nocopy     varchar2
  ,p_clear_details                out nocopy     varchar2
) IS

l_proc    varchar2(72) := g_package ||'getEmpTransactionDetails';

BEGIN
hr_utility.set_location('Entering:' || l_proc, 5);

  --
    p_person_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERSON_ID');
--
    period_of_service_id :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PERIODS_OF_SERVICE_ID');

--
    p_object_version_number :=
      hr_transaction_api.get_number_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_OBJECT_VERSION_NUMBER');
  --

    p_actual_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ACTUAL_TERMINATION_DATE');
  --
    p_final_process_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_FINAL_PROCESS_DATE');

  --
    p_last_standard_process_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_LAST_STANDARD_PROCESS_DATE');
  --
     p_notified_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_NOTIFIED_TERMINATION_DATE');
  --
    p_leaving_reason :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_TERMINATION_REASON');

  --
    p_rehire_recommendation :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REHIRE_RECOMMENDATION');
  --
    p_leaving_reason :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REHIRE_REASON');
  --
    p_comments :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_COMMENTS');
  --
    p_projected_termination_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PROJECTED_TERMINATION_DATE');
  --
    p_attribute_category :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE_CATEGORY');
  --
    p_attribute1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE1');
  --
    p_attribute2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE2');
  --
    p_attribute3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE3');
  --
    p_attribute4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE4');
  --
    p_attribute5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE5');
  --
    p_attribute6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE6');
  --
    p_attribute7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE7');
  --
    p_attribute8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE8');
  --
    p_attribute9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE9');
  --
    p_attribute10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE10');
  --
    p_attribute11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE11');
  --
    p_attribute12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE12');
  --
    p_attribute13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE13');
  --
    p_attribute14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE14');
  --
    p_attribute15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE15');
  --
    p_attribute16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE16');
  --
    p_attribute17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE17');
  --
    p_attribute18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE18');
  --
    p_attribute19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE19');
  --
    p_attribute20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_ATTRIBUTE20');
  --

      p_pds_information_category :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION_CATEGORY');
  --
    p_pds_information1 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION1');
  --
    p_pds_information2 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION2');
  --
    p_pds_information3 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION3');
  --
    p_pds_information4 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION4');
  --
    p_pds_information5 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION5');
  --
    p_pds_information6 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION6');
  --
    p_pds_information7 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION7');
  --
    p_pds_information8 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION8');
  --
    p_pds_information9 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION9');
  --
    p_pds_information10 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION10');
  --
    p_pds_information11 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION11');
  --
    p_pds_information12 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION12');
  --
    p_pds_information13 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION13');
  --
    p_pds_information14 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION14');
  --
    p_pds_information15 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION15');
  --
    p_pds_information16 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION16');
  --
    p_pds_information17 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION17');
  --
    p_pds_information18 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION18');
  --
    p_pds_information19 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION19');
  --
    p_pds_information20 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION20');

  --
    p_pds_information21 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION21');
  --
    p_pds_information22 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION22');
  --
    p_pds_information23 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION23');
  --
    p_pds_information24 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION24');
  --
    p_pds_information25 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION25');
  --
    p_pds_information26 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION26');
  --
    p_pds_information27 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION27');
  --
    p_pds_information28 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION28');
  --
    p_pds_information29 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION29');
  --
    p_pds_information30 :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PDS_INFORMATION30');

		p_clear_details :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_CLEAR_DETAILS');

hr_utility.set_location('Leaving:' || l_proc, 10);

END getEmpTransactionDetails;

END hr_revtermination_ss;

/
