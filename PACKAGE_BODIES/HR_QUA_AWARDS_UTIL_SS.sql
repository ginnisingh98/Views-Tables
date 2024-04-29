--------------------------------------------------------
--  DDL for Package Body HR_QUA_AWARDS_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUA_AWARDS_UTIL_SS" AS
/* $Header: hrquawrs.pkb 120.3.12010000.4 2009/07/21 07:52:08 rvagvala ship $*/


-- ---------------------------------------------------------------------------
-- delete_entire_qua
-- delete all qualification details, the attendance details for
-- the school at which the qualification was attained and any
-- subjects
-- ---------------------------------------------------------------------------

PROCEDURE delete_entire_qua
  (p_validate                in boolean
  ,p_qualification_id        in varchar2
  ,p_pq_object_version_number in varchar2
  ,p_attendance_id           in varchar2
  ,p_pea_object_version_number in varchar2
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
) IS
  --Bug#3236273

  cursor subjects_for_qua(p_qualification_id in varchar2)is
    select  subjects_taken_id,object_version_number
    from    per_subjects_taken per
    where   per.qualification_id = p_qualification_id;

    l_cursor_record  subjects_for_qua%ROWTYPE;
    l_proc   varchar2(72)  := g_package||'delete_entire_qua';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  savepoint delete_entire_qua;

  --
  -- delete all subjects
  --

  --Bug#3236273
  hr_utility.set_location('Opening and  Fetching subjects_for_qua :'||l_proc,10);
  open subjects_for_qua(p_qualification_id => p_qualification_id);
  fetch subjects_for_qua into l_cursor_record;
  hr_utility.set_location('Entering while loop:'||l_proc,15);
  WHILE subjects_for_qua%FOUND LOOP

  --FOR i IN 1..NVL(p_qua_subjects.count,0) LOOP
    IF l_cursor_record.subjects_taken_id IS NOT null THEN

      per_sbt_del.del_tl
         (p_subjects_taken_id => l_cursor_record.subjects_taken_id);
      per_sub_del.del
         (p_validate => p_validate
          ,p_subjects_taken_id  => l_cursor_record.subjects_taken_id
          ,p_object_version_number => l_cursor_record.object_version_number);
    END IF;
    fetch subjects_for_qua into l_cursor_record;
  END LOOP;
  hr_utility.set_location('Exiting For Loop:'||l_proc,20);
  close subjects_for_qua;

  --
  -- delete qualification
  --
  --per_qua_del.del
  PER_QUALIFICATIONS_API.DELETE_QUALIFICATION
    (p_validate => p_validate
    ,p_qualification_id => p_qualification_id
    ,p_object_version_number => p_pq_object_version_number);

  --
  -- delete attendance
  --
  BEGIN
    IF p_attendance_id IS NOT null THEN
          hr_utility.set_location('p_attendance_id IS NOT null:'||l_proc,30);
          per_esa_del.del
        (p_validate => p_validate
        ,p_attendance_id => p_attendance_id
        ,p_object_version_number => p_pea_object_version_number);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
            null;
  END;

  IF p_validate = TRUE THEN
  hr_utility.set_location('p_validate = TRUE:'||l_proc,35);
    rollback to delete_entire_qua;
  END IF;

hr_utility.set_location('Exiting:'||l_proc,25);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    rollback to delete_entire_qua;
    raise;

END delete_entire_qua;

-- ---------------------------------------------------------------------------
-- process_api
-- ---------------------------------------------------------------------------

PROCEDURE process_api
  (p_validate               in boolean
  ,p_transaction_step_id    in number
  ,p_effective_date        in varchar2 default null
  ) is

  l_mode            varchar2(2000);

  l_qualifications         SSHR_QUA_TAB_TYP;
  l_qua_subjects           SSHR_QUA_SUBJECT_TAB_TYP;
  l_qua_attendance         SSHR_QUA_ATTENDANCE_TAB_TYP;
  l_selected_person_id     number;
  l_proc   varchar2(72)  := g_package||'process_api';

   --
   -- SSHR Attachment feature changes : 8691102
   --
   l_attach_status varchar2(80);

BEGIN
  --
  -- get user date format
  --
  --get entire qualification data from transaction table
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  get_entire_qua
          (p_transaction_step_id => p_transaction_step_id
          ,p_mode => l_mode
          ,p_qualifications => l_qualifications
          ,p_qua_subjects => l_qua_subjects
          ,p_qua_attendance => l_qua_attendance);

  l_selected_person_id := to_number(
    hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SELECTED_PERSON_ID'));

  IF l_qualifications(1).delete_flag = 'Y' THEN
    hr_utility.set_location('l_qualifications(1).delete_flag = Y:'||l_proc,10);
    delete_entire_qua
      (p_validate                => p_validate
      ,p_qualification_id        => l_qualifications(1).qualification_id
      ,p_pq_object_version_number =>
              l_qualifications(1).object_version_number
      ,p_attendance_id           => l_qualifications(1).attendance_id
      ,p_pea_object_version_number =>
             l_qua_attendance(1).object_version_number
      ,p_qua_subjects            => l_qua_subjects);
  ELSE
        hr_utility.set_location('l_qualifications(1).delete_flag != Y:'||l_proc,15);
    validate_api
     (p_validate                => p_validate
     ,p_mode                    => l_mode
     ,p_selected_person_id      => l_selected_person_id
     ,p_qualifications          => l_qualifications
     ,p_qua_subjects            => l_qua_subjects
     ,p_qua_attendance          => l_qua_attendance);
  END IF;


  hr_utility.set_location('merge_attachments Start : l_selected_person_id = ' || l_selected_person_id || ' ' ||l_proc, 20);

  HR_UTIL_MISC_SS.merge_attachments( p_dest_entity_name => 'PER_PEOPLE_F'
                           ,p_dest_pk1_value => l_selected_person_id
                           ,p_return_status => l_attach_status);

  hr_utility.set_location('merge_attachments End: l_attach_status = ' || l_attach_status || ' ' ||l_proc, 25);

  hr_utility.set_location('Exiting:'||l_proc, 30);

end process_api;
-- ---------------------------------------------------------------------------
-- field_changed
-- ---------------------------------------------------------------------------

FUNCTION field_changed(p_field1  in varchar2
                      ,p_field2  in varchar2)
RETURN BOOLEAN IS
l_proc   varchar2(72)  := g_package||'field_changed';
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  IF p_field1 IS null AND p_field2 IS null
    OR
         p_field1 IS NOT null AND p_field2 IS NOT null AND
         p_field1 = p_field2 THEN
         hr_utility.set_location('Return FALSE:'||l_proc, 10);
        RETURN FALSE;
  ELSE
    --fnd_message.set_name('PER',p_field1||'-'||p_field2);
    --hr_utility.raise_error;
    hr_utility.set_location('Return TRUE:'||l_proc, 10);
    RETURN TRUE;
  END IF;

END field_changed;


/* Bug8364149 Start

  New function introduced to verify if there are any changes done to school information

*/

FUNCTION is_attendance_changed (p_qua_attendance in SSHR_QUA_ATTENDANCE_TAB_TYP,p_qualifications in SSHR_QUA_TAB_TYP)
RETURN BOOLEAN IS

  cursor csr_attendance(p_attendance_id in number) is
  select *
  from per_establishment_attendances
  where attendance_id = p_attendance_id;
  l_subject_count       number;

  cursor csr_establishment(p_establishment_id in number) is
  select name
  from   per_establishments
  where  establishment_id = p_establishment_id;

  l_changed                      boolean;

  v_attendance          csr_attendance%ROWTYPE;
  v_establishment       csr_establishment%ROWTYPE;

  l_proc   varchar2(72)  := g_package||'is_establishment_changed';

BEGIN

  hr_utility.set_location('p_qualifications(1).attendance_id  ' ||p_qualifications(1).attendance_id , 1);

  IF p_qualifications(1).attendance_id is not null THEN

    OPEN csr_attendance(p_qualifications(1).attendance_id);
    FETCH csr_attendance INTO v_attendance;
    IF csr_attendance%NOTFOUND THEN
      CLOSE csr_attendance;
      hr_utility.set_location('csr_attendance%NOTFOUND, RETURN TRUE:'||l_proc,35);
      RETURN TRUE;
    END IF;
    CLOSE csr_attendance;

    hr_utility.set_location('establishment_id',40);

    IF field_changed(v_attendance.establishment_id
                  ,p_qua_attendance(1).establishment_id) THEN
    hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,40);
      RETURN TRUE;
    END IF;
    IF v_attendance.establishment_id IS NOT NULL THEN
      OPEN csr_establishment(v_attendance.establishment_id);
      FETCH csr_establishment INTO v_establishment;
      CLOSE csr_establishment;
      IF field_changed(v_establishment.name
                  ,p_qua_attendance(1).establishment) THEN
            hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,45);
        RETURN TRUE;
      END IF;
    ELSE
      IF field_changed(v_attendance.establishment
                  ,p_qua_attendance(1).establishment) THEN
            hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,50);
        RETURN TRUE;
      END IF;
    END IF;
    IF field_changed(to_char(v_attendance.attended_start_date,
                   FORMAT_RRRR_MM_DD)
                  ,to_char(p_qua_attendance(1).attended_start_date,
                   FORMAT_RRRR_MM_DD)) THEN
          hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,55);
      RETURN TRUE;
    END IF;
    IF field_changed(to_char(v_attendance.attended_end_date,
                   FORMAT_RRRR_MM_DD)
                  ,to_char(p_qua_attendance(1).attended_end_date,
                   FORMAT_RRRR_MM_DD)) THEN
          hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,60);
      RETURN TRUE;
    END IF;
    IF field_changed(NVL(v_attendance.full_time,'N')
                  ,NVL(p_qua_attendance(1).full_time,'N')) THEN
    hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,65);
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute_category
                  ,p_qua_attendance(1).attribute_category) THEN
      hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,70);
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute1
                  ,p_qua_attendance(1).attribute1) THEN
      hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,75);
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute2
                  ,p_qua_attendance(1).attribute2) THEN
        hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,85);
        RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute3
                  ,p_qua_attendance(1).attribute3) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute4
                  ,p_qua_attendance(1).attribute4) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute5
                  ,p_qua_attendance(1).attribute5) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute6
                  ,p_qua_attendance(1).attribute6) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute7
                  ,p_qua_attendance(1).attribute7) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute8
                  ,p_qua_attendance(1).attribute8) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute9
                  ,p_qua_attendance(1).attribute9) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute10
                  ,p_qua_attendance(1).attribute10) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute11
                  ,p_qua_attendance(1).attribute11) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute12
                  ,p_qua_attendance(1).attribute12) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute13
                  ,p_qua_attendance(1).attribute13) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute14
                  ,p_qua_attendance(1).attribute14) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute15
                  ,p_qua_attendance(1).attribute15) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute16
                  ,p_qua_attendance(1).attribute16) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute17
                  ,p_qua_attendance(1).attribute17) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute18
                  ,p_qua_attendance(1).attribute18) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute19
                  ,p_qua_attendance(1).attribute19) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute20
                  ,p_qua_attendance(1).attribute20) THEN
      RETURN TRUE;
    END IF;
  END IF; --end check attendance

  RETURN FALSE;

END is_attendance_changed;

-- Bug8364149 End




-- ---------------------------------------------------------------------------
-- is_entire_qua_changed
-- ---------------------------------------------------------------------------
FUNCTION is_entire_qua_changed
  (p_qualifications          in SSHR_QUA_TAB_TYP
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance          in SSHR_QUA_ATTENDANCE_TAB_TYP
)

RETURN BOOLEAN IS


  cursor csr_qualification(p_qualification_id in number) is
  select *
  from per_qualifications
  where qualification_id=p_qualification_id;

  cursor csr_attendance(p_attendance_id in number) is
  select *
  from per_establishment_attendances
  where attendance_id = p_attendance_id;

  cursor csr_subject(p_subject_taken_id in number) is
  select *
  from per_subjects_taken
  where subjects_taken_id = p_subject_taken_id;

  cursor csr_establishment(p_establishment_id in number) is
  select name
  from   per_establishments
  where  establishment_id = p_establishment_id;

  l_subject_count       number;

  l_changed                      boolean;

  v_qualification       csr_qualification%ROWTYPE;
  v_attendance          csr_attendance%ROWTYPE;
  v_subject             csr_subject%ROWTYPE;
  v_establishment       csr_establishment%ROWTYPE;
  l_proc   varchar2(72)  := g_package||'is_entire_qua_changed';

BEGIN
  --
  --new qualification
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  IF p_qualifications(1).qualification_id IS null THEN
    hr_utility.set_location('qualification_id =null, RETURN TRUE:'||l_proc,10);
    RETURN TRUE;
  END IF;

  --
  --updated qualification
  --
  l_changed := FALSE;

  OPEN csr_qualification(p_qualifications(1).qualification_id);
  FETCH csr_qualification INTO v_qualification;
  CLOSE csr_qualification;

  IF (v_qualification.attendance_id is null and p_qua_attendance(1).establishment_id is not null)
  THEN
    hr_utility.set_location(' establishment change '||l_proc,10);
    RETURN TRUE;
  END IF;

  --IF field_changed(v_qualification.party_id
  --                ,p_qualifications(1).party_id) THEN
  --  RETURN TRUE;
  --END IF;

  IF field_changed(v_qualification.title
                  ,p_qualifications(1).title) THEN
    hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,10);
    RETURN TRUE;
  END IF;

  IF field_changed(to_char(v_qualification.start_date,FORMAT_RRRR_MM_DD)
                  ,to_char(p_qualifications(1).start_date,FORMAT_RRRR_MM_DD)) THEN
    hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,15);
    RETURN TRUE;
  END IF;

  IF field_changed(to_char(v_qualification.end_date,FORMAT_RRRR_MM_DD)
                  ,to_char(p_qualifications(1).end_date,FORMAT_RRRR_MM_DD)) THEN
    hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,20);
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.status
                  ,p_qualifications(1).status) THEN
    hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,25);
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attendance_id
                  ,p_qualifications(1).attendance_id) THEN
    hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,30);
    RETURN TRUE;
  END IF;

  IF p_qualifications(1).attendance_id is not null THEN
    OPEN csr_attendance(p_qualifications(1).attendance_id);
    FETCH csr_attendance INTO v_attendance;
    IF csr_attendance%NOTFOUND THEN
      CLOSE csr_attendance;
      hr_utility.set_location('csr_attendance%NOTFOUND, RETURN TRUE:'||l_proc,35);
      RETURN TRUE;
    END IF;
    CLOSE csr_attendance;
  END IF;

  --check attendance
  IF p_qualifications(1).attendance_id is not null THEN

    IF field_changed(v_attendance.establishment_id
                  ,p_qua_attendance(1).establishment_id) THEN
    hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,40);
      RETURN TRUE;
    END IF;
    IF v_attendance.establishment_id IS NOT NULL THEN
      OPEN csr_establishment(v_attendance.establishment_id);
      FETCH csr_establishment INTO v_establishment;
      CLOSE csr_establishment;
      IF field_changed(v_establishment.name
                  ,p_qua_attendance(1).establishment) THEN
            hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,45);
        RETURN TRUE;
      END IF;
    ELSE
      IF field_changed(v_attendance.establishment
                  ,p_qua_attendance(1).establishment) THEN
            hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,50);
        RETURN TRUE;
      END IF;
    END IF;
    IF field_changed(to_char(v_attendance.attended_start_date,
                   FORMAT_RRRR_MM_DD)
                  ,to_char(p_qua_attendance(1).attended_start_date,
                   FORMAT_RRRR_MM_DD)) THEN
          hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,55);
      RETURN TRUE;
    END IF;
    IF field_changed(to_char(v_attendance.attended_end_date,
                   FORMAT_RRRR_MM_DD)
                  ,to_char(p_qua_attendance(1).attended_end_date,
                   FORMAT_RRRR_MM_DD)) THEN
          hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,60);
      RETURN TRUE;
    END IF;
    IF field_changed(NVL(v_attendance.full_time,'N')
                  ,NVL(p_qua_attendance(1).full_time,'N')) THEN
    hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,65);
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute_category
                  ,p_qua_attendance(1).attribute_category) THEN
      hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,70);
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute1
                  ,p_qua_attendance(1).attribute1) THEN
      hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,75);
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute2
                  ,p_qua_attendance(1).attribute2) THEN
        hr_utility.set_location('if field_changed(..,..), RETURN TRUE:'||l_proc,85);
        RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute3
                  ,p_qua_attendance(1).attribute3) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute4
                  ,p_qua_attendance(1).attribute4) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute5
                  ,p_qua_attendance(1).attribute5) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute6
                  ,p_qua_attendance(1).attribute6) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute7
                  ,p_qua_attendance(1).attribute7) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute8
                  ,p_qua_attendance(1).attribute8) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute9
                  ,p_qua_attendance(1).attribute9) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute10
                  ,p_qua_attendance(1).attribute10) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute11
                  ,p_qua_attendance(1).attribute11) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute12
                  ,p_qua_attendance(1).attribute12) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute13
                  ,p_qua_attendance(1).attribute13) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute14
                  ,p_qua_attendance(1).attribute14) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute15
                  ,p_qua_attendance(1).attribute15) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute16
                  ,p_qua_attendance(1).attribute16) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute17
                  ,p_qua_attendance(1).attribute17) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute18
                  ,p_qua_attendance(1).attribute18) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute19
                  ,p_qua_attendance(1).attribute19) THEN
      RETURN TRUE;
    END IF;
    IF field_changed(v_attendance.attribute20
                  ,p_qua_attendance(1).attribute20) THEN
      RETURN TRUE;
    END IF;
  END IF; --end check attendance

  IF field_changed(v_qualification.attribute_category
                  ,p_qualifications(1).attribute_category) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute1
                  ,p_qualifications(1).attribute1) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute2
                  ,p_qualifications(1).attribute2) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute3
                  ,p_qualifications(1).attribute3) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute4
                  ,p_qualifications(1).attribute4) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute5
                  ,p_qualifications(1).attribute5) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute6
                  ,p_qualifications(1).attribute6) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute7
                  ,p_qualifications(1).attribute7) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute8
                  ,p_qualifications(1).attribute8) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute9
                  ,p_qualifications(1).attribute9) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute10
                  ,p_qualifications(1).attribute10) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute11
                  ,p_qualifications(1).attribute11) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute12
                  ,p_qualifications(1).attribute12) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute13
                  ,p_qualifications(1).attribute13) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute14
                  ,p_qualifications(1).attribute14) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute15
                  ,p_qualifications(1).attribute15) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute16
                  ,p_qualifications(1).attribute16) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute17
                  ,p_qualifications(1).attribute17) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute18
                  ,p_qualifications(1).attribute18) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute19
                  ,p_qualifications(1).attribute19) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.attribute20
                  ,p_qualifications(1).attribute20) THEN
    RETURN TRUE;
  END IF;

  --IF field_changed(v_qualification.qua_information_category
  --                ,p_qualifications(1).qua_information_category) THEN
  --  RETURN TRUE;
  --END IF;

  IF field_changed(v_qualification.qua_information1
                  ,p_qualifications(1).qua_information1) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.qua_information2
                  ,p_qualifications(1).qua_information2) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information3
                  ,p_qualifications(1).qua_information3) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information4
                  ,p_qualifications(1).qua_information4) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information5
                  ,p_qualifications(1).qua_information5) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information6
                  ,p_qualifications(1).qua_information6) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information7
                  ,p_qualifications(1).qua_information7) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information8
                  ,p_qualifications(1).qua_information8) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information9
                  ,p_qualifications(1).qua_information9) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information10
                  ,p_qualifications(1).qua_information10) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information11
                  ,p_qualifications(1).qua_information11) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information12
                  ,p_qualifications(1).qua_information12) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information13
                  ,p_qualifications(1).qua_information13) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information14
                  ,p_qualifications(1).qua_information14) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information15
                  ,p_qualifications(1).qua_information15) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information16
                  ,p_qualifications(1).qua_information16) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information17
                  ,p_qualifications(1).qua_information17) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information18
                  ,p_qualifications(1).qua_information18) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information19
                  ,p_qualifications(1).qua_information19) THEN
    RETURN TRUE;
  END IF;
  IF field_changed(v_qualification.qua_information20
                  ,p_qualifications(1).qua_information20) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.grade_attained
                  ,p_qualifications(1).grade_attained) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.tuition_method
                  ,p_qualifications(1).tuition_method) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.fee
                  ,p_qualifications(1).fee) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.fee_currency
                  ,p_qualifications(1).fee_currency) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.reimbursement_arrangements
                  ,p_qualifications(1).reimbursement_arrangements) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.training_completed_amount
                  ,p_qualifications(1).training_completed_amount) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.training_completed_units
                  ,p_qualifications(1).training_completed_units) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.total_training_amount
                  ,p_qualifications(1).total_training_amount) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.awarding_body
                  ,p_qualifications(1).awarding_body) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.group_ranking
                  ,p_qualifications(1).group_ranking) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(to_char(v_qualification.awarded_date,
                   FORMAT_RRRR_MM_DD)
                  ,to_char(p_qualifications(1).awarded_date,
                   FORMAT_RRRR_MM_DD)
                  ) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.license_number
                  ,p_qualifications(1).license_number) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.license_restrictions
                  ,p_qualifications(1).license_restrictions) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(to_char(v_qualification.expiry_date,
                   FORMAT_RRRR_MM_DD)
                  ,to_char(p_qualifications(1).expiry_date,
                   FORMAT_RRRR_MM_DD)
                  ) THEN
    RETURN TRUE;
  END IF;

  IF field_changed(v_qualification.comments
                  ,p_qualifications(1).comments) THEN
    RETURN TRUE;
  END IF;


  l_subject_count := p_qua_subjects.count;

  hr_utility.set_location('Entering For Loop:'||l_proc,100);
  FOR i IN 1..l_subject_count LOOP
    IF p_qua_subjects(i).subjects_taken_id IS null AND
          p_qua_subjects(i).delete_flag = 'N' THEN
          --a new subject is added
          RETURN TRUE;
        END IF;
        IF p_qua_subjects(i).subjects_taken_id IS NOT null AND
          p_qua_subjects(i).delete_flag = 'Y' THEN
          --a subject is deleted
          RETURN TRUE;
        END IF;
    IF p_qua_subjects(i).subjects_taken_id IS NOT null AND
          p_qua_subjects(i).delete_flag = 'N' THEN
      OPEN csr_subject(p_qua_subjects(i).subjects_taken_id);
      FETCH csr_subject INTO v_subject;
      IF csr_subject%NOTFOUND THEN
        CLOSE csr_subject;
        RETURN TRUE;
      ELSE
        CLOSE csr_subject;
      END IF;
      IF field_changed(v_subject.major
                      ,p_qua_subjects(i).major) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(to_char(v_subject.start_date,
                            FORMAT_RRRR_MM_DD)
                          ,to_char(p_qua_subjects(i).start_date,
                            FORMAT_RRRR_MM_DD)) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(to_char(v_subject.end_date,
                            FORMAT_RRRR_MM_DD)
                          ,to_char(p_qua_subjects(i).end_date,
                            FORMAT_RRRR_MM_DD)) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.subject_status
                      ,p_qua_subjects(i).subject_status) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.grade_attained
                      ,p_qua_subjects(i).grade_attained) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute_category
                      ,p_qua_subjects(i).attribute_category) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute1
                      ,p_qua_subjects(i).attribute1) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute2
                      ,p_qua_subjects(i).attribute2) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute3
                      ,p_qua_subjects(i).attribute3) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute4
                      ,p_qua_subjects(i).attribute4) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute5
                      ,p_qua_subjects(i).attribute5) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute6
                      ,p_qua_subjects(i).attribute6) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute7
                      ,p_qua_subjects(i).attribute7) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute8
                      ,p_qua_subjects(i).attribute8) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute9
                      ,p_qua_subjects(i).attribute9) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute10
                      ,p_qua_subjects(i).attribute10) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute11
                      ,p_qua_subjects(i).attribute11) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute12
                      ,p_qua_subjects(i).attribute12) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute13
                      ,p_qua_subjects(i).attribute13) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute14
                      ,p_qua_subjects(i).attribute14) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute15
                      ,p_qua_subjects(i).attribute15) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute16
                      ,p_qua_subjects(i).attribute16) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute17
                      ,p_qua_subjects(i).attribute17) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute18
                      ,p_qua_subjects(i).attribute18) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute19
                      ,p_qua_subjects(i).attribute19) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.attribute20
                      ,p_qua_subjects(i).attribute20) THEN
        RETURN TRUE;
      END IF;

      --IF field_changed(v_subject.sub_information_category
      --                ,p_qua_subjects(i).sub_information_category) THEN
      --  RETURN TRUE;
      --END IF;
      IF field_changed(v_subject.sub_information1
                      ,p_qua_subjects(i).sub_information1) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information2
                      ,p_qua_subjects(i).sub_information2) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information3
                      ,p_qua_subjects(i).sub_information3) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information4
                      ,p_qua_subjects(i).sub_information4) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information5
                      ,p_qua_subjects(i).sub_information5) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information6
                      ,p_qua_subjects(i).sub_information6) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information7
                      ,p_qua_subjects(i).sub_information7) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information8
                      ,p_qua_subjects(i).sub_information8) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information9
                      ,p_qua_subjects(i).sub_information9) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information10
                      ,p_qua_subjects(i).sub_information10) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information11
                      ,p_qua_subjects(i).sub_information11) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information12
                      ,p_qua_subjects(i).sub_information12) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information13
                      ,p_qua_subjects(i).sub_information13) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information14
                      ,p_qua_subjects(i).sub_information14) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information15
                      ,p_qua_subjects(i).sub_information15) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information16
                      ,p_qua_subjects(i).sub_information16) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information17
                      ,p_qua_subjects(i).sub_information17) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information18
                      ,p_qua_subjects(i).sub_information18) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information19
                      ,p_qua_subjects(i).sub_information19) THEN
        RETURN TRUE;
      END IF;
      IF field_changed(v_subject.sub_information20
                      ,p_qua_subjects(i).sub_information20) THEN
        RETURN TRUE;
      END IF;
    END IF;
  END LOOP;
  hr_utility.set_location('Exiting For Loop:'||l_proc,105);
  hr_utility.set_location('Exiting:'||l_proc, 110);

  RETURN FALSE;

END is_entire_qua_changed;

procedure delete_transaction_step
  (p_item_type in varchar2
  ,p_item_key  in varchar2
  ,p_creator_person_id in number) is

  cursor c_get_transaction_step_id(p_transaction_id number) is
  select transaction_step_id
    from hr_api_transaction_steps
   where transaction_id = p_transaction_id;

  l_transaction_id           hr_api_transactions.transaction_id%type;
  l_transaction_step_id      hr_api_transaction_steps.transaction_step_id%type;
  l_proc   varchar2(72)  := g_package||'delete_transaction_step';

begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  l_transaction_id := hr_transaction_ss.get_transaction_id
                              (p_item_type => p_item_type
                              ,p_item_key  => p_item_key);
  if l_transaction_id is not null then
    hr_utility.set_location('l_transaction_id is not null:'||l_proc,10);
    open c_get_transaction_step_id(l_transaction_id);
    fetch c_get_transaction_step_id into l_transaction_step_id;
    close c_get_transaction_step_id;
    if l_transaction_step_id is not null then
      hr_utility.set_location('if l_transaction_step_id is not null:'||l_proc,15);
      hr_transaction_ss.delete_transaction_step
        (l_transaction_step_id,null,p_creator_person_id);
    end if;
  end if;

hr_utility.set_location('Exiting:'||l_proc, 20);
end delete_transaction_step;


-- start of function decode_value

function decode_value (p_expression in boolean,
        		       p_true       in varchar2,
		               p_false      in varchar2)
                       return varchar2 is
                       l_proc   varchar2(72)  := g_package||'decode_value';
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_expression then
    hr_utility.set_location('if p_expression= true:'||l_proc,10);
    return p_true;
  else
    hr_utility.set_location('if p_expression=false:'||l_proc,15);
    return p_false;
  end if;
Exception
  when others then
    hr_utility.set_location('Exception:Others'||l_proc,555);
    rollback;
    raise;
end decode_value;

-- end of function decode_value

-- start of function get_qualification_type

/*
This method returns the qualification type give the qualification type id
*/

function get_qualification_type(p_qualification_type_id   in number)
                                return varchar2 is

CURSOR csr_qua_type IS
       SELECT
       name
       FROM
       per_qualification_types
       WHERE qualification_type_id = p_qualification_type_id;

l_name per_qualification_types.name%TYPE;
l_proc   varchar2(72)  := g_package||'get_qualification_type';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  OPEN csr_qua_type;
  FETCH csr_qua_type INTO l_name;
  CLOSE csr_qua_type;

  hr_utility.set_location('Exiting:'||l_proc, 10);
  RETURN l_name;

Exception
  when others then
hr_utility.set_location('Exception:Others'||l_proc,555);
    rollback;
    raise;
END get_qualification_type;

-- end of function get_qualification_type

-- start of procedure  get_pending_transaction_ids

/*
This method returns the list of Qualifications or Awards that are pending approval for a person. All
the values are concatenated and passed as out nocopy params to the java code. The column separator is
'^' and the row separator is '?'
*/
procedure get_pending_transaction_ids
  (p_item_type		    in varchar2
  ,p_selected_person_id in varchar2
  ,p_mode               in varchar2
  ,p_process_name       in varchar2
  ,p_activity_name      in varchar2
  ,p_qualifications     out nocopy SSHR_QUA_TAB_TYP
  ,p_qua_attendance     out nocopy SSHR_QUA_ATTENDANCE_TAB_TYP
  ,p_transaction_steps  out nocopy SSHR_TRN_TAB_TYP
  )
  IS

  l_transaction_step_id hr_util_misc_web.g_varchar2_tab_type;
  l_total_rec_count number := 0;

  l_mode            varchar2(2000);

  l_qualifications         SSHR_QUA_TAB_TYP;
  l_qua_subjects           SSHR_QUA_SUBJECT_TAB_TYP;
  l_qua_attendance         SSHR_QUA_ATTENDANCE_TAB_TYP;
  l_selected_person_id     number;
  l_proc   varchar2(72)  := g_package||'get_pending_transaction_ids';

BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);
   hr_qua_awards_util_ss.get_pending_transaction_steps
     (p_item_type => p_item_type
     ,p_selected_person_id => p_selected_person_id
     ,p_mode => p_mode
     ,p_process_name => p_process_name
     ,p_activity_name => p_activity_name
     ,p_transaction_step_id => l_transaction_step_id);

   l_total_rec_count := nvl(l_transaction_step_id.COUNT,0);

   p_qualifications := SSHR_QUA_TAB_TYP();
   p_qua_attendance := SSHR_QUA_ATTENDANCE_TAB_TYP();
   p_transaction_steps := SSHR_TRN_TAB_TYP();

   hr_utility.set_location('Entering For Loop:'||l_proc,10);
   FOR i IN 1..l_total_rec_count LOOP
     if l_transaction_step_id(i) is not null then
       --
       --get entire qualification data from transaction table
       --
       get_entire_qua
          (p_transaction_step_id => l_transaction_step_id(i)
          ,p_mode => l_mode
          ,p_qualifications => l_qualifications
          ,p_qua_subjects => l_qua_subjects
          ,p_qua_attendance => l_qua_attendance);

       p_qua_attendance.extend;
       p_qua_attendance(i) := l_qua_attendance(1);
       p_qualifications.extend;
       p_qualifications(i) := l_qualifications(1);

       p_transaction_steps.extend;
       p_transaction_steps(i) := SSHR_TRN_OBJ_TYP(
         l_transaction_step_id(i));

     end if;

   END LOOP;
   hr_utility.set_location('Exiting For Loop:'||l_proc,15);
   hr_utility.set_location('Exiting:'||l_proc, 20);
Exception

  when others then
    hr_utility.set_location('Exception:Others'||l_proc,555);
    rollback;
    raise;
END get_pending_transaction_ids;

-- end of procedure get_pending_transaction_ids


-- start of function is_qualification_in_pending

/*
This method returns whether a given qualification id is pending approval or not. This function
is called from java code.
*/
function is_qualification_in_pending

(
   p_item_type		    in varchar2
  ,p_selected_person_id in varchar2
  ,p_mode               in varchar2
  ,p_process_name       in varchar2
  ,p_activity_name      in varchar2
  ,p_qualification_id   in number
 )

 return varchar2 is

 l_pending_found varchar2(1);
 l_transaction_step_id  hr_util_misc_web.g_varchar2_tab_type;
 l_qualification_id number;
 l_proc   varchar2(72)  := g_package||'is_qualification_in_pending';

Begin

   hr_utility.set_location('Entering:'||l_proc, 5);
   get_pending_transaction_steps
     (p_item_type => p_item_type
	 ,p_selected_person_id => p_selected_person_id
     ,p_mode => p_mode
     ,p_process_name => p_process_name
     ,p_activity_name => p_activity_name
	 ,p_transaction_step_id => l_transaction_step_id);

   l_pending_found := 'N';

   hr_utility.set_location('Entering For Loop:'||l_proc,10);
   FOR i IN 1..NVL(l_transaction_step_id.count,0) LOOP
     l_qualification_id :=
       hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => l_transaction_step_id(i)
         ,p_name                => 'P_QUALIFICATION_ID');
	 IF l_qualification_id = p_qualification_id THEN
	   l_pending_found := 'Y';
	   EXIT;
	 END IF;
  END LOOP;
  hr_utility.set_location('Exiting For Loop:'||l_proc,15);

  hr_utility.set_location('Exiting:'||l_proc, 15);
  RETURN l_pending_found;

Exception
  when others then
    hr_utility.set_location('Exception:Others'||l_proc,555);
    raise;
end is_qualification_in_pending;

-- end of function is_qualification_in_pending

-- Start of Procedure validate_qualification
/*
This method is being called from the java code when creating/editing a qualification or an award.
*/
PROCEDURE validate_qualification
  (p_validate                in VARCHAR2
  ,p_save_mode               in varchar2
  ,p_mode                    in varchar2
  ,p_creator_person_id       in number
  ,p_selected_person_id      in number
  ,p_item_type               in varchar2
  ,p_item_key                in varchar2
  ,p_act_id                  in varchar2
  ,p_proc_call               in varchar2
  ,p_error_message           in out nocopy varchar2
  ,p_subjects_error_message  in out nocopy varchar2
  ,p_qualifications          in SSHR_QUA_TAB_TYP
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance          in SSHR_QUA_ATTENDANCE_TAB_TYP) is

  l_app_exception exception;

  l_transaction_step_id     number;
  l_validate                boolean := true;
  l_changed                 boolean := false;
  l_subject_count           number := 0;
  l_error_message	    varchar2(3000);
  l_proc   varchar2(72)  := g_package||'validate_qualification';

-- start of begin for validate_qualification

Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_validate = 'Y' then
    hr_utility.set_location('p_validate = N:'||l_proc,10);
    l_validate := true;
  else
    l_validate := false;
  end if;

  --check if there are any changes
  if p_qualifications(1).delete_flag is null or
     p_qualifications(1).delete_flag = 'N' then
    hr_utility.set_location('delete_flag = N:'||l_proc,15);
    l_changed := is_entire_qua_changed
      (p_qualifications     => p_qualifications
       ,p_qua_subjects      => p_qua_subjects
       ,p_qua_attendance    => p_qua_attendance);
    IF l_changed = FALSE THEN
      hr_utility.set_location('l_changed = FALSE THEN:'||l_proc,25);
      delete_transaction_step
        (p_item_type => p_item_type
        ,p_item_key => p_item_key
        ,p_creator_person_id => p_creator_person_id);
    END IF;
  end if;

if l_changed = TRUE THEN
        hr_utility.set_location('l_changed = TRUE THEN:'||l_proc,30);
  if (p_qualifications(1).delete_flag is null or
      p_qualifications(1).delete_flag = 'N')
     and p_save_mode <> 'SAVE_FOR_LATER'
     then
    hr_utility.set_location('Delete flag = N and not SFL'||l_proc,35);
    hr_qua_awards_util_ss.check_errors
      (p_ignore_sub_date_boundaries => 'N'
      ,p_mode                       =>  p_mode
      ,p_qualifications             =>  p_qualifications
      ,p_qua_subjects               =>  p_qua_subjects
      ,p_qua_attendance             =>  p_qua_attendance
      ,p_error_message              =>  p_error_message
      ,p_subjects_error_message     =>  p_subjects_error_message);

    if nvl(length(p_error_message),0) > 0 or
       nvl(length(p_subjects_error_message),0) > 0 then
      hr_utility.set_location('Exception:l_app_exception'||l_proc,555);
      raise l_app_exception;
    end if;
  end if;

  --should not do validation if user wants to delete the current qualification.
  if (p_qualifications(1).delete_flag is null or
      p_qualifications(1).delete_flag = 'N') and
      p_save_mode <> 'SAVE_FOR_LATER' then
    hr_utility.set_location('Delete flag = N and not SFL'||l_proc,40);
    hr_qua_awards_util_ss.validate_api
      (p_validate       => l_validate
      ,p_mode           => p_mode
      ,p_selected_person_id => p_selected_person_id
      ,p_qualifications => p_qualifications
      ,p_qua_subjects   => p_qua_subjects
      ,p_qua_attendance => p_qua_attendance
      );
  end if;
end if; --l_changed

if l_changed = TRUE or p_qualifications(1).delete_flag = 'Y' THEN

      hr_utility.set_location('Delete flag = Y or changed=True'||l_proc,40);
  hr_qua_awards_util_ss.save_transaction_step
    (p_item_type           => p_item_type
    ,p_item_key            => p_item_key
    ,p_actid               => to_number(p_act_id)
    ,p_transaction_step_id => l_transaction_step_id
    ,p_mode                => p_mode
    ,p_creator_person_id   => p_creator_person_id
    ,p_selected_person_id  => p_selected_person_id
    ,p_qualifications      => p_qualifications
    ,p_qua_subjects        => p_qua_subjects
    ,p_qua_attendance      => p_qua_attendance
    ,p_proc_call           => p_proc_call);
end if;

Exception
  when l_app_exception then
    hr_utility.set_location('Exception:l_app_exception'||l_proc,555);
    rollback;
  -- Fix bug 2899882.
  -- should directly raise error. Otherwise the tokens in the messages are
  -- lost.
  --when hr_utility.hr_error then
  --  hr_message.provide_error;
  --  p_error_message := nvl(p_error_message,'')||'!'||'|'||'PAGE'||'|'||
  --      hr_message.last_message_app||'|'||hr_message.last_message_name||
  --      '|'||'!';
  --  rollback;
  when others then
  hr_utility.set_location('Exception:Others'||l_proc,555);
    rollback;
    -- Bug Fix 3103716
    l_error_message := hr_utility.get_message;
    IF l_error_message is null THEN
        raise;
    ELSE
      p_error_message :=  nvl(p_error_message,'')||'!'||'|'||'PAGE'||'|'||'PER'||'|'|| l_error_message ||'|_ValidateAPIError|'||'!';
    END IF;
    hr_utility.set_location('Exiting:'||l_proc, 45);
End; -- end of validate_qualification

-- end of procedure validate_qualification

-- start of procedure save_transaction_step

PROCEDURE save_transaction_step
  (p_item_type               in varchar2
  ,p_item_key                in varchar2
  ,p_actid                   in number
  ,p_transaction_step_id	 in out nocopy number
  ,p_mode                    in varchar2
  ,p_creator_person_id       in number
  ,p_selected_person_id      in number
  ,p_qualifications          in SSHR_QUA_TAB_TYP
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance          in SSHR_QUA_ATTENDANCE_TAB_TYP
  ,p_proc_call in varchar2 ) IS

  l_result VARCHAR2(100);
  l_transaction_id             number;
  l_trn_object_version_number  hr_api_transaction_steps.object_version_number%TYPE;
  l_subject_count           number;
  l_proc   varchar2(72)  := g_package||'save_transaction_step';

BEGIN


  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_qua_awards_util_ss.start_transaction
    (itemtype => p_item_type
    ,itemkey => p_item_key
    ,actid => p_actid
    ,funmode => 'RUN'
    ,p_selected_person_id => p_qualifications(1).person_id
    ,p_creator_person_id => p_creator_person_id
    ,result => l_result);

  l_transaction_id := hr_transaction_ss.get_transaction_id
    (p_item_type   => p_item_type
    ,p_item_key    => p_item_key);

  --create a transaction step for this transaction.

  hr_transaction_api.create_transaction_step
    (p_validate              => FALSE
    ,p_creator_person_id     => p_creator_person_id
    ,p_transaction_id        => l_transaction_id
    ,p_api_name              => HR_QUA_AWARDS_UTIL_SS.API_NAME
    ,p_item_type             => p_item_type
    ,p_item_key              => p_item_key
    ,p_transaction_step_id   => p_transaction_step_id
    ,p_object_version_number => l_trn_object_version_number);


  --save to transaction table

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'p_mode'
    ,p_value               => p_mode);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_SELECTED_PERSON_ID'
    ,p_value               => p_selected_person_id);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_PERSON_ID'
    ,p_value               => p_qualifications(1).person_id);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_BUSINESS_GROUP_ID'
    ,p_value               => p_qualifications(1).business_group_id);


  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_DELETE_FLAG'
    ,p_value               => p_qualifications(1).delete_flag);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_QUALIFICATION_ID'
    ,p_value               => p_qualifications(1).qualification_id);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_QUALIFICATION_TYPE_ID'
    ,p_value               => p_qualifications(1).qualification_type_id);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_OBJECT_VERSION_NUMBER'
    ,p_value               => p_qualifications(1).object_version_number);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_TITLE'
    ,p_value               => p_qualifications(1).title);

  hr_transaction_api.set_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_START_DATE'
    ,p_value               => p_qualifications(1).start_date);

  hr_transaction_api.set_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_END_DATE'
    ,p_value               => p_qualifications(1).end_date);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_STATUS'
    ,p_value               => p_qualifications(1).status);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_GRADE_ATTAINED'
    ,p_value               => p_qualifications(1).grade_attained);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_TUITION_METHOD'
    ,p_value               => p_qualifications(1).tuition_method);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_FEE'
    ,p_value               => p_qualifications(1).fee);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_FEE_CURRENCY'
    ,p_value               => p_qualifications(1).fee_currency);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_REIMBURSEMENT'
    ,p_value               => p_qualifications(1).reimbursement_arrangements);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_COMPLETED_AMOUNT'
    ,p_value               => p_qualifications(1).training_completed_amount);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_COMPLETED_UNITS'
    ,p_value               => p_qualifications(1).training_completed_units);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_TOTAL_AMOUNT'
    ,p_value               => p_qualifications(1).total_training_amount);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_COMMENTS'
    ,p_value               => p_qualifications(1).comments);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_AWARDING_BODY'
    ,p_value               => p_qualifications(1).awarding_body);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_GROUP_RANKING'
    ,p_value               => p_qualifications(1).group_ranking);

  hr_transaction_api.set_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_AWARDED_DATE'
    ,p_value               => p_qualifications(1).awarded_date);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_LICENSE_NUMBER'
    ,p_value               => p_qualifications(1).license_number);

  hr_transaction_api.set_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_EXPIRY_DATE'
    ,p_value               => p_qualifications(1).expiry_date);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_LICENSE_RESTRICTIONS'
    ,p_value               => p_qualifications(1).license_restrictions);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_PERSON_ID'
    ,p_value               => p_qua_attendance(1).person_id);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_ESTABLISHMENT_ID'
    ,p_value               => p_qua_attendance(1).establishment_id);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PE_NAME'
    ,p_value               => p_qua_attendance(1).establishment);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_ATTENDANCE_ID'
    ,p_value               => p_qualifications(1).attendance_id);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_OBJECT_VERSION_NUMBER'
    ,p_value               => p_qua_attendance(1).object_version_number);

  hr_transaction_api.set_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_START_DATE'
    ,p_value               => p_qua_attendance(1).attended_start_date);

  hr_transaction_api.set_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_END_DATE'
    ,p_value               => p_qua_attendance(1).attended_end_date);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_FULL_TIME'
    ,p_value               => p_qua_attendance(1).full_time);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE_CATEGORY'
    ,p_value               => p_qualifications(1).attribute_category);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE1'
    ,p_value               => p_qualifications(1).attribute1);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE2'
    ,p_value               => p_qualifications(1).attribute2);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE3'
    ,p_value               => p_qualifications(1).attribute3);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE4'
    ,p_value               => p_qualifications(1).attribute4);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE5'
    ,p_value               => p_qualifications(1).attribute5);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE6'
    ,p_value               => p_qualifications(1).attribute6);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE7'
    ,p_value               => p_qualifications(1).attribute7);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE8'
    ,p_value               => p_qualifications(1).attribute8);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE9'
    ,p_value               => p_qualifications(1).attribute9);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE10'
    ,p_value               => p_qualifications(1).attribute10);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE11'
    ,p_value               => p_qualifications(1).attribute11);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE12'
    ,p_value               => p_qualifications(1).attribute12);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE13'
    ,p_value               => p_qualifications(1).attribute13);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE14'
    ,p_value               => p_qualifications(1).attribute14);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE15'
    ,p_value               => p_qualifications(1).attribute15);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE16'
    ,p_value               => p_qualifications(1).attribute16);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE17'
    ,p_value               => p_qualifications(1).attribute17);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE18'
    ,p_value               => p_qualifications(1).attribute18);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE19'
    ,p_value               => p_qualifications(1).attribute19);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_ATTRIBUTE20'
    ,p_value               => p_qualifications(1).attribute20);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION_CATEGORY'
    ,p_value               => p_qualifications(1).qua_information_category);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION1'
    ,p_value               => p_qualifications(1).qua_information1);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION2'
    ,p_value               => p_qualifications(1).qua_information2);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION3'
    ,p_value               => p_qualifications(1).qua_information3);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION4'
    ,p_value               => p_qualifications(1).qua_information4);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION5'
    ,p_value               => p_qualifications(1).qua_information5);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION6'
    ,p_value               => p_qualifications(1).qua_information6);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION7'
    ,p_value               => p_qualifications(1).qua_information7);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION8'
    ,p_value               => p_qualifications(1).qua_information8);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION9'
    ,p_value               => p_qualifications(1).qua_information9);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION10'
    ,p_value               => p_qualifications(1).qua_information10);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION11'
    ,p_value               => p_qualifications(1).qua_information11);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION12'
    ,p_value               => p_qualifications(1).qua_information12);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION13'
    ,p_value               => p_qualifications(1).qua_information13);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION14'
    ,p_value               => p_qualifications(1).qua_information14);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION15'
    ,p_value               => p_qualifications(1).qua_information15);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION16'
    ,p_value               => p_qualifications(1).qua_information16);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION17'
    ,p_value               => p_qualifications(1).qua_information17);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION18'
    ,p_value               => p_qualifications(1).qua_information18);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION19'
    ,p_value               => p_qualifications(1).qua_information19);
  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PQ_QUA_INFORMATION20'
    ,p_value               => p_qualifications(1).qua_information20);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PARTY_ID'
    ,p_value               => p_qualifications(1).party_id);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE_CATEGORY'
    ,p_value               => p_qua_attendance(1).attribute_category);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE1'
    ,p_value               => p_qua_attendance(1).attribute1);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE2'
    ,p_value               => p_qua_attendance(1).attribute2);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE3'
    ,p_value               => p_qua_attendance(1).attribute3);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE4'
    ,p_value               => p_qua_attendance(1).attribute4);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE5'
    ,p_value               => p_qua_attendance(1).attribute5);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE6'
    ,p_value               => p_qua_attendance(1).attribute6);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE7'
    ,p_value               => p_qua_attendance(1).attribute7);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE8'
    ,p_value               => p_qua_attendance(1).attribute8);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE9'
    ,p_value               => p_qua_attendance(1).attribute9);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE10'
    ,p_value               => p_qua_attendance(1).attribute10);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE11'
    ,p_value               => p_qua_attendance(1).attribute11);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE12'
    ,p_value               => p_qua_attendance(1).attribute12);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE13'
    ,p_value               => p_qua_attendance(1).attribute13);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE14'
    ,p_value               => p_qua_attendance(1).attribute14);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE15'
    ,p_value               => p_qua_attendance(1).attribute15);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE16'
    ,p_value               => p_qua_attendance(1).attribute16);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE17'
    ,p_value               => p_qua_attendance(1).attribute17);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE18'
    ,p_value               => p_qua_attendance(1).attribute18);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE19'
    ,p_value               => p_qua_attendance(1).attribute19);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_PEA_ATTRIBUTE20'
    ,p_value               => p_qua_attendance(1).attribute20);

  l_subject_count := NVL(p_qua_subjects.count,0);

   hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_SUBJECT_COUNT'
    ,p_value               => l_subject_count);

  hr_utility.set_location('Entering For Loop:'||l_proc,10);
  FOR i IN 1..l_subject_count LOOP

    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUBJECTS_TAKEN_ID'||i
      ,p_value               => p_qua_subjects(i).subjects_taken_id);

	hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_PST_OBJECT_VERSION_NUMBER'||i
      ,p_value               => p_qua_subjects(i).object_version_number);

	hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_PST_SUBJECT'||i
      ,p_value               => p_qua_subjects(i).subject);

    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_PST_MAJOR'||i
      ,p_value               => p_qua_subjects(i).major);

    hr_transaction_api.set_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_person_id           => p_creator_person_id
       ,p_name                => 'P_PST_START_DATE'||i
       ,p_value           => p_qua_subjects(i).start_date);

    hr_transaction_api.set_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_person_id           => p_creator_person_id
       ,p_name                => 'P_PST_END_DATE'||i
       ,p_value               => p_qua_subjects(i).end_date);

    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_PST_SUBJECT_STATUS'||i
      ,p_value               => p_qua_subjects(i).subject_status);

	hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_PST_GRADE_ATTAINED'||i
      ,p_value               => p_qua_subjects(i).grade_attained);

    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_PST_DELETE_FLAG'||i
      ,p_value               => p_qua_subjects(i).delete_flag);

    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_PST_ATTRIBUTE_CATEGORY'||i
      ,p_value               => p_qua_subjects(i).attribute_category);

    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE1_PST'||i
      ,p_value               => p_qua_subjects(i).attribute1);

    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE2_PST'||i
      ,p_value               => p_qua_subjects(i).attribute2);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE3_PST'||i
      ,p_value               => p_qua_subjects(i).attribute3);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE4_PST'||i
      ,p_value               => p_qua_subjects(i).attribute4);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE5_PST'||i
      ,p_value               => p_qua_subjects(i).attribute5);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE6_PST'||i
      ,p_value               => p_qua_subjects(i).attribute6);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE7_PST'||i
      ,p_value               => p_qua_subjects(i).attribute7);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE8_PST'||i
      ,p_value               => p_qua_subjects(i).attribute8);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE9_PST'||i
      ,p_value               => p_qua_subjects(i).attribute9);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE10_PST'||i
      ,p_value               => p_qua_subjects(i).attribute10);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE11_PST'||i
      ,p_value               => p_qua_subjects(i).attribute11);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE12_PST'||i
      ,p_value               => p_qua_subjects(i).attribute12);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE13_PST'||i
      ,p_value               => p_qua_subjects(i).attribute13);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE14_PST'||i
      ,p_value               => p_qua_subjects(i).attribute14);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE15_PST'||i
      ,p_value               => p_qua_subjects(i).attribute15);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE16_PST'||i
      ,p_value               => p_qua_subjects(i).attribute16);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE17_PST'||i
      ,p_value               => p_qua_subjects(i).attribute17);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE18_PST'||i
      ,p_value               => p_qua_subjects(i).attribute18);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE19_PST'||i
      ,p_value               => p_qua_subjects(i).attribute19);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_ATTRIBUTE20_PST'||i
      ,p_value               => p_qua_subjects(i).attribute20);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION_CATEGORY'||i
      ,p_value               => p_qua_subjects(i).sub_information_category);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION1_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information1);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION2_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information2);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION3_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information3);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION4_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information4);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION5_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information5);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION6_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information6);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION7_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information7);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION8_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information8);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION9_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information9);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION10_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information10);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION11_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information11);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION12_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information12);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION13_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information13);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION14_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information14);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION15_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information15);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION16_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information16);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION17_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information17);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION18_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information18);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION19_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information19);
    hr_transaction_api.set_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_person_id           => p_creator_person_id
      ,p_name                => 'P_SUB_INFORMATION20_PST'||i
      ,p_value               => p_qua_subjects(i).sub_information20);

  END LOOP;
  hr_utility.set_location('Exiting For Loop:'||l_proc,15);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_REVIEW_PROC_CALL'
    ,p_value               => p_proc_call);

  hr_transaction_api.set_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_person_id           => p_creator_person_id
    ,p_name                => 'P_REVIEW_ACTID'
    ,p_value               => p_actid);

hr_utility.set_location('Exiting:'||l_proc, 20);
Exception
 when others then
 hr_utility.set_location('Exception:Others'||l_proc,555);
    rollback;
    raise;
END save_transaction_step;

-- Start of Procedure validate_api
PROCEDURE validate_api
  (p_validate                in boolean
  ,p_mode                    in varchar2
  ,p_selected_person_id      in number
  ,p_qualifications          in SSHR_QUA_TAB_TYP
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance          in SSHR_QUA_ATTENDANCE_TAB_TYP
  ) IS
  CURSOR csr_school_changed(p_establishment in varchar2
                           ,p_attendance_id in number
                           ,p_establishment_id in number)
         IS
         SELECT null
         FROM
         per_establishment_attendances
         WHERE
         attendance_id = p_attendance_id
         AND NVL(establishment_id,-1) = NVL(p_establishment_id,-1)
         AND NVL(UPPER(establishment),-1) = NVL(UPPER(p_establishment),-1);

  CURSOR csr_attendance(p_business_group_id in number
                       ,p_establishment_id in number
        	       ,p_start_date in date
                       ,p_establishment in varchar2
                       ,p_selected_person_id in number)
        IS
        SELECT attendance_id
        FROM
        per_establishment_attendances
        WHERE
        PERSON_ID = p_selected_person_id
        AND (/*
	     Bug 8364149 Start Commented to allow

	     attended_start_date is null
	     and p_start_date is null
	   or

	    Bug 8364149 End
	   */ attended_start_date = p_start_date)
        AND business_group_id = p_business_group_id
        AND (p_establishment_id is not null
          AND establishment_id = p_establishment_id
         OR p_establishment is not null
          AND UPPER(establishment) = UPPER(p_establishment));

  CURSOR csr_qualification_dates(p_qualification_id in number)
         IS
         SELECT
         start_date
        ,end_date
         FROM
         per_qualifications
         WHERE
         qualification_id = p_qualification_id;

  cursor c1(p_establishment in varchar2
           ,p_attendance_id in number
           ,p_school_id in number
	   ,p_attended_start_date in date
           ,p_attended_end_date in date
           ,p_qualification_type_id in number
           ,p_title in varchar2
           ,p_selected_person_id in number) is
         select
         null
         from
         per_establishment_attendances per,
         per_qualifications pq
         where
         per.person_id = p_selected_person_id
         and    (p_establishment is not null
             and UPPER(per.establishment) = UPPER(p_establishment)
              or p_school_id is not null and per.establishment_id is not null
             and per.establishment_id = p_school_id)
         and     per.attendance_id <> nvl(p_attendance_id,-1)
         and     (p_attended_start_date
         between per.attended_start_date
         and     nvl(per.attended_end_date,hr_api.g_eot)
         or nvl(p_attended_end_date,hr_api.g_eot)
         between per.attended_start_date
         and     nvl(per.attended_end_date,hr_api.g_eot))
         and per.attendance_id =  pq.attendance_id
         and pq.qualification_type_id = p_qualification_type_id
         --and nvl(pq.party_id, -1) = nvl(p_party_id,-1)
         and nvl(pq.title,-1) = nvl(p_title,-1);

  cursor csr_get_establishment_id(p_establishment in varchar2) is
  select establishment_id
  from per_establishments
  where upper(name) = upper(p_establishment);

  cursor csr_ok_to_del_attendance(p_attendance_id in number) is
  select count(*)
  from per_qualifications
  where attendance_id = p_attendance_id;

  l_attendance_count             number;
  l_school_name_id               number;
  l_qualification_id		 number;
  l_pq_object_version_number     number;
  l_attendance_id                number;
  l_old_attendance_id            number;
  l_establishment_id             number;
  l_establishment                varchar2(2000);
  l_pea_object_version_number    number;
  l_subjects_taken_id            number;
  l_pst_object_version_number    number;
  l_school_changed               varchar2(1);
  l_start_date                   date;
  l_end_date                     date;
  l_dummy                        varchar2(1);
  l_new_school_allowed           varchar2(10);
  l_proc   varchar2(72)  := g_package||'validate_api';
-- 8712282 Fix
  l_changed boolean;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  savepoint validate_qua;

  l_old_attendance_id := p_qualifications(1).attendance_id;

  l_establishment := p_qua_attendance(1).establishment;

  --check if attendance already exists
  if p_mode = HR_QUA_AWARDS_UTIL_SS.EDUCATION THEN

    hr_utility.set_location('p_mode = HR_QUA_AWARDS_UTIL_SS.EDUCATION THEN:'||l_proc,10);
    l_establishment_id := p_qua_attendance(1).establishment_id;

    --if the school is entered (not picked from the LOV),
    if l_establishment_id is null then
    hr_utility.set_location('l_establishment_id is null then:'||l_proc,20);
      OPEN csr_get_establishment_id(p_qua_attendance(1).establishment);
      FETCH csr_get_establishment_id into l_school_name_id;
      IF csr_get_establishment_id%FOUND THEN
        hr_utility.set_location('csr_get_establishment_id%FOUND:'||l_proc,25);
        l_establishment_id := l_school_name_id;
        FETCH csr_get_establishment_id into l_school_name_id;
        IF csr_get_establishment_id%FOUND THEN
          hr_utility.set_location('csr_get_establishment_id%FOUND:'||l_proc,30);
          CLOSE csr_get_establishment_id;
          fnd_message.set_name('PER','HR_SCHOOL_NAME_NOT_UNIQUE');
          hr_utility.raise_error;
        END IF;
      ELSE
        l_new_school_allowed := fnd_profile.value('HR_SSHR_NEW_SCHOOL');
        if l_new_school_allowed = 'N' THEN
          hr_utility.set_location('l_new_school_allowed=N:'||l_proc,35);
          CLOSE csr_get_establishment_id;
          fnd_message.set_name('PER','HR_SCHOOL_NAME_NOT_EXIST');
          hr_utility.raise_error;
        END IF;
      END IF;
      CLOSE csr_get_establishment_id;
    end if;

    --check attendance overlap
    OPEN c1(p_establishment => p_qua_attendance(1).establishment
           ,p_school_id => p_qua_attendance(1).establishment_id
           ,p_attendance_id => p_qualifications(1).attendance_id
           ,p_attended_start_date => p_qua_attendance(1).attended_start_date
           ,p_attended_end_date => p_qua_attendance(1).attended_end_date
           ,p_qualification_type_id => p_qualifications(1).qualification_type_id
           ,p_title => p_qualifications(1).title
           ,p_selected_person_id => p_selected_person_id);
    FETCH c1 into l_dummy;
      if c1%found then
        close c1;
        fnd_message.set_name('PAY','HR_51847_QUA_REC_EXISTS');
        hr_utility.raise_error;
       end if;
    CLOSE c1;

    OPEN csr_attendance
           (p_business_group_id => p_qualifications(1).business_group_id
            ,p_establishment_id => p_qua_attendance(1).establishment_id
            ,p_start_date => p_qua_attendance(1).attended_start_date
            ,p_establishment => p_qua_attendance(1).establishment
            ,p_selected_person_id => p_selected_person_id);
    FETCH csr_attendance INTO l_attendance_id;
    IF csr_attendance%NOTFOUND THEN
      l_attendance_id := null;
    END IF;
    CLOSE csr_attendance;

    if l_establishment_id is null then
      l_establishment := p_qua_attendance(1).establishment;
    else
      l_establishment := null;
    end if;
  end if;

  l_qualification_id := p_qualifications(1).qualification_id;

  if l_qualification_id is null then --a new qualification
    --insert attendance only for qua
    if p_mode = HR_QUA_AWARDS_UTIL_SS.EDUCATION THEN

       if l_attendance_id IS null THEN

         hr_utility.set_location('qualification id is null,mode is EDUCATION,attendance id is null:'||l_proc,45);
         --attendance is not exist, then insert a new one
         --hr_qua_awards_util_ss.ins
         per_esa_ins.ins
           (p_validate => FALSE
           ,p_effective_date => sysdate
           ,p_attendance_id  => l_attendance_id
           ,p_business_group_id => p_qualifications(1).business_group_id
           ,p_person_id => p_selected_person_id
           ,p_establishment_id => l_establishment_id
           ,p_establishment =>
                  decode_value
                    (p_expression => l_establishment_id IS NOT null
                    ,p_true => null
                    ,p_false => p_qua_attendance(1).establishment)
           ,p_attended_start_date => p_qua_attendance(1).attended_start_date
           ,p_attended_end_date => p_qua_attendance(1).attended_end_date
           ,p_full_time  => NVL(p_qua_attendance(1).full_time,'N')
           ,p_attribute_category => p_qua_attendance(1).attribute_category
           ,p_attribute1 => p_qua_attendance(1).attribute1
           ,p_attribute2 => p_qua_attendance(1).attribute2
           ,p_attribute3 => p_qua_attendance(1).attribute3
           ,p_attribute4 => p_qua_attendance(1).attribute4
           ,p_attribute5 => p_qua_attendance(1).attribute5
           ,p_attribute6 => p_qua_attendance(1).attribute6
           ,p_attribute7 => p_qua_attendance(1).attribute7
           ,p_attribute8 => p_qua_attendance(1).attribute8
           ,p_attribute9 => p_qua_attendance(1).attribute9
           ,p_attribute10 => p_qua_attendance(1).attribute10
           ,p_attribute11 => p_qua_attendance(1).attribute11
           ,p_attribute12 => p_qua_attendance(1).attribute12
           ,p_attribute13 => p_qua_attendance(1).attribute13
           ,p_attribute14 => p_qua_attendance(1).attribute14
           ,p_attribute15 => p_qua_attendance(1).attribute15
           ,p_attribute16 => p_qua_attendance(1).attribute16
           ,p_attribute17 => p_qua_attendance(1).attribute17
           ,p_attribute18 => p_qua_attendance(1).attribute18
           ,p_attribute19 => p_qua_attendance(1).attribute19
           ,p_attribute20 => p_qua_attendance(1).attribute20
        ,p_object_version_number => l_pea_object_version_number);
      end if;
    end if; --end insert attendance

    --insert qualification for both qua and award
    --per_qua_ins.ins
    PER_QUALIFICATIONS_API.CREATE_QUALIFICATION
      (p_validate => FALSE
      ,p_effective_date => sysdate
      ,p_qualification_type_id => p_qualifications(1).qualification_type_id
      ,p_qualification_id => l_qualification_id
      ,p_business_group_id => p_qualifications(1).business_group_id
      ,p_object_version_number => l_pq_object_version_number
      ,p_person_id => decode_value(
           p_expression => l_attendance_id IS NOT null
          ,p_true => null
          ,p_false => p_selected_person_id)
     ,p_title => p_qualifications(1).title
     ,p_status => p_qualifications(1).status
     ,p_start_date => p_qualifications(1).start_date
     ,p_end_date => p_qualifications(1).end_date
     --,p_party_id => p_qualifications(1).party_id
     ,p_attendance_id => l_attendance_id
     ,p_grade_attained => p_qualifications(1).grade_attained
     ,p_awarded_date => p_qualifications(1).awarded_date
     ,p_fee => p_qualifications(1).fee
     ,p_fee_currency => p_qualifications(1).fee_currency
     ,p_training_completed_amount =>
          p_qualifications(1).training_completed_amount
     ,p_reimbursement_arrangements =>
          p_qualifications(1).reimbursement_arrangements
     ,p_training_completed_units =>
          p_qualifications(1).training_completed_units
     ,p_total_training_amount => p_qualifications(1).total_training_amount
     ,p_license_number => p_qualifications(1).license_number
     ,p_expiry_date => p_qualifications(1).expiry_date
     ,p_license_restrictions => p_qualifications(1).license_restrictions
     ,p_awarding_body => p_qualifications(1).awarding_body
     ,p_tuition_method => p_qualifications(1).tuition_method
     ,p_group_ranking => p_qualifications(1).group_ranking
     ,p_comments => substr(p_qualifications(1).comments,1,2000)
     ,p_attribute_category => p_qualifications(1).attribute_category
     ,p_attribute1 => p_qualifications(1).attribute1
     ,p_attribute2 => p_qualifications(1).attribute2
     ,p_attribute3 => p_qualifications(1).attribute3
     ,p_attribute4 => p_qualifications(1).attribute4
     ,p_attribute5 => p_qualifications(1).attribute5
     ,p_attribute6 => p_qualifications(1).attribute6
     ,p_attribute7 => p_qualifications(1).attribute7
     ,p_attribute8 => p_qualifications(1).attribute8
     ,p_attribute9 => p_qualifications(1).attribute9
     ,p_attribute10 => p_qualifications(1).attribute10
     ,p_attribute11 => p_qualifications(1).attribute11
     ,p_attribute12 => p_qualifications(1).attribute12
     ,p_attribute13 => p_qualifications(1).attribute13
     ,p_attribute14 => p_qualifications(1).attribute14
     ,p_attribute15 => p_qualifications(1).attribute15
     ,p_attribute16 => p_qualifications(1).attribute16
     ,p_attribute17 => p_qualifications(1).attribute17
     ,p_attribute18 => p_qualifications(1).attribute18
     ,p_attribute19 => p_qualifications(1).attribute19
     ,p_attribute20 => p_qualifications(1).attribute20
     ,p_qua_information_category => p_qualifications(1).qua_information_category
     ,p_qua_information1 => p_qualifications(1).qua_information1
     ,p_qua_information2 => p_qualifications(1).qua_information2
     ,p_qua_information3 => p_qualifications(1).qua_information3
     ,p_qua_information4 => p_qualifications(1).qua_information4
     ,p_qua_information5 => p_qualifications(1).qua_information5
     ,p_qua_information6 => p_qualifications(1).qua_information6
     ,p_qua_information7 => p_qualifications(1).qua_information7
     ,p_qua_information8 => p_qualifications(1).qua_information8
     ,p_qua_information9 => p_qualifications(1).qua_information9
     ,p_qua_information10 => p_qualifications(1).qua_information10
     ,p_qua_information11 => p_qualifications(1).qua_information11
     ,p_qua_information12 => p_qualifications(1).qua_information12
     ,p_qua_information13 => p_qualifications(1).qua_information13
     ,p_qua_information14 => p_qualifications(1).qua_information14
     ,p_qua_information15 => p_qualifications(1).qua_information15
     ,p_qua_information16 => p_qualifications(1).qua_information16
     ,p_qua_information17 => p_qualifications(1).qua_information17
     ,p_qua_information18 => p_qualifications(1).qua_information18
     ,p_qua_information19 => p_qualifications(1).qua_information19
     ,p_qua_information20 => p_qualifications(1).qua_information20
    );

     --insert subject for both qua and award
     hr_utility.set_location('Entering For Loop:'||l_proc,55);
     for i in 1..NVL(p_qua_subjects.count, 0) loop
       if p_qua_subjects(i).delete_flag = 'N' then
         per_sub_ins.ins
	      (p_validate => FALSE
	      ,p_effective_date => sysdate
	      ,p_subjects_taken_id => l_subjects_taken_id
	      ,p_start_date => p_qua_subjects(i).start_date
	      ,p_end_date => p_qua_subjects(i).end_date
	      ,p_major => p_qua_subjects(i).major
	      ,p_subject_status => p_qua_subjects(i).subject_status
              ,p_subject => p_qua_subjects(i).subject
	      ,p_grade_attained => p_qua_subjects(i).grade_attained
	      ,p_qualification_id => l_qualification_id
	      ,p_object_version_number => l_pst_object_version_number
              ,p_attribute_category => p_qua_subjects(i).attribute_category
              ,p_attribute1 => p_qua_subjects(i).attribute1
              ,p_attribute2 => p_qua_subjects(i).attribute2
              ,p_attribute3 => p_qua_subjects(i).attribute3
              ,p_attribute4 => p_qua_subjects(i).attribute4
              ,p_attribute5 => p_qua_subjects(i).attribute5
              ,p_attribute6 => p_qua_subjects(i).attribute6
              ,p_attribute7 => p_qua_subjects(i).attribute7
              ,p_attribute8 => p_qua_subjects(i).attribute8
              ,p_attribute9 => p_qua_subjects(i).attribute9
              ,p_attribute10 => p_qua_subjects(i).attribute10
              ,p_attribute11 => p_qua_subjects(i).attribute11
              ,p_attribute12 => p_qua_subjects(i).attribute12
              ,p_attribute13 => p_qua_subjects(i).attribute13
              ,p_attribute14 => p_qua_subjects(i).attribute14
              ,p_attribute15 => p_qua_subjects(i).attribute15
              ,p_attribute16 => p_qua_subjects(i).attribute16
              ,p_attribute17 => p_qua_subjects(i).attribute17
              ,p_attribute18 => p_qua_subjects(i).attribute18
              ,p_attribute19 => p_qua_subjects(i).attribute19
              ,p_attribute20 => p_qua_subjects(i).attribute20
              ,p_sub_information_category => p_qua_subjects(i).sub_information_category
              ,p_sub_information1 => p_qua_subjects(i).sub_information1
              ,p_sub_information2 => p_qua_subjects(i).sub_information2
              ,p_sub_information3 => p_qua_subjects(i).sub_information3
              ,p_sub_information4 => p_qua_subjects(i).sub_information4
              ,p_sub_information5 => p_qua_subjects(i).sub_information5
              ,p_sub_information6 => p_qua_subjects(i).sub_information6
              ,p_sub_information7 => p_qua_subjects(i).sub_information7
              ,p_sub_information8 => p_qua_subjects(i).sub_information8
              ,p_sub_information9 => p_qua_subjects(i).sub_information9
              ,p_sub_information10 => p_qua_subjects(i).sub_information10
              ,p_sub_information11 => p_qua_subjects(i).sub_information11
              ,p_sub_information12 => p_qua_subjects(i).sub_information12
              ,p_sub_information13 => p_qua_subjects(i).sub_information13
              ,p_sub_information14 => p_qua_subjects(i).sub_information14
              ,p_sub_information15 => p_qua_subjects(i).sub_information15
              ,p_sub_information16 => p_qua_subjects(i).sub_information16
              ,p_sub_information17 => p_qua_subjects(i).sub_information17
              ,p_sub_information18 => p_qua_subjects(i).sub_information18
              ,p_sub_information19 => p_qua_subjects(i).sub_information19
              ,p_sub_information20 => p_qua_subjects(i).sub_information20
               );

         per_sbt_ins.ins_tl
              (p_language_code =>  hr_api.userenv_lang
              ,p_subjects_taken_id => l_subjects_taken_id
              ,p_grade_attained => p_qua_subjects(i).grade_attained
              );
       end if;
     end loop;
     hr_utility.set_location('Exiting For Loop:'||l_proc,60);
  else --update an existing qua or award

    l_pq_object_version_number := p_qualifications(1).object_version_number;
    l_pea_object_version_number := p_qua_attendance(1).object_version_number;

    --update attendance only for qua
    if p_mode = HR_QUA_AWARDS_UTIL_SS.EDUCATION then
      OPEN csr_school_changed(l_establishment
                             ,p_qualifications(1).attendance_id
                             ,p_qua_attendance(1).establishment_id);
      FETCH csr_school_changed INTO l_dummy;
      IF csr_school_changed%found THEN
        CLOSE csr_school_changed;
        l_school_changed := 'N';
      ELSE
        CLOSE csr_school_changed;
        l_school_changed := 'Y';
      END IF;

      if l_school_changed = 'Y'  and l_establishment is null then  --establishment_id changed.
        --if l_attendance_id is null then  --create a new attendance
          per_esa_ins.ins
            (p_validate => FALSE
            ,p_effective_date => sysdate
            ,p_attendance_id  => l_attendance_id
            ,p_business_group_id => p_qualifications(1).business_group_id
            ,p_person_id => p_selected_person_id
            ,p_establishment_id => l_establishment_id
            ,p_establishment => decode_value(p_expression =>
                         l_establishment_id IS NOT null
                              ,p_true => null
                              ,p_false => p_qua_attendance(1).establishment)
            ,p_attended_start_date => p_qua_attendance(1).attended_start_date
            ,p_attended_end_date => p_qua_attendance(1).attended_end_date
            ,p_full_time  => NVL(p_qua_attendance(1).full_time,'N')
           ,p_attribute_category => p_qua_attendance(1).attribute_category
           ,p_attribute1 => p_qua_attendance(1).attribute1
           ,p_attribute2 => p_qua_attendance(1).attribute2
           ,p_attribute3 => p_qua_attendance(1).attribute3
           ,p_attribute4 => p_qua_attendance(1).attribute4
           ,p_attribute5 => p_qua_attendance(1).attribute5
           ,p_attribute6 => p_qua_attendance(1).attribute6
           ,p_attribute7 => p_qua_attendance(1).attribute7
           ,p_attribute8 => p_qua_attendance(1).attribute8
           ,p_attribute9 => p_qua_attendance(1).attribute9
           ,p_attribute10 => p_qua_attendance(1).attribute10
           ,p_attribute11 => p_qua_attendance(1).attribute11
           ,p_attribute12 => p_qua_attendance(1).attribute12
           ,p_attribute13 => p_qua_attendance(1).attribute13
           ,p_attribute14 => p_qua_attendance(1).attribute14
           ,p_attribute15 => p_qua_attendance(1).attribute15
           ,p_attribute16 => p_qua_attendance(1).attribute16
           ,p_attribute17 => p_qua_attendance(1).attribute17
           ,p_attribute18 => p_qua_attendance(1).attribute18
           ,p_attribute19 => p_qua_attendance(1).attribute19
           ,p_attribute20 => p_qua_attendance(1).attribute20
           ,p_object_version_number => l_pea_object_version_number);
      else
      --Bug 8364149
      l_changed := is_attendance_changed
        ( p_qua_attendance    => p_qua_attendance,p_qualifications => p_qualifications );

	      if(l_changed = true) then
		per_esa_upd.upd
		       (p_validate => FALSE
		       ,p_effective_date => sysdate
		   ,p_attendance_id  => l_old_attendance_id
		   ,p_establishment_id => l_establishment_id
		   ,p_establishment => decode_value(p_expression =>
				 l_establishment_id IS NOT null
				      ,p_true => null
				      ,p_false => p_qua_attendance(1).establishment)
		   ,p_attended_start_date => p_qua_attendance(1).attended_start_date
		   ,p_attended_end_date => p_qua_attendance(1).attended_end_date
		   ,p_full_time  => NVL(p_qua_attendance(1).full_time,'N')
		   ,p_attribute_category => p_qua_attendance(1).attribute_category
		   ,p_attribute1 => p_qua_attendance(1).attribute1
		   ,p_attribute2 => p_qua_attendance(1).attribute2
		   ,p_attribute3 => p_qua_attendance(1).attribute3
		   ,p_attribute4 => p_qua_attendance(1).attribute4
		   ,p_attribute5 => p_qua_attendance(1).attribute5
		   ,p_attribute6 => p_qua_attendance(1).attribute6
		   ,p_attribute7 => p_qua_attendance(1).attribute7
		   ,p_attribute8 => p_qua_attendance(1).attribute8
		   ,p_attribute9 => p_qua_attendance(1).attribute9
		   ,p_attribute10 => p_qua_attendance(1).attribute10
		   ,p_attribute11 => p_qua_attendance(1).attribute11
		   ,p_attribute12 => p_qua_attendance(1).attribute12
		   ,p_attribute13 => p_qua_attendance(1).attribute13
		   ,p_attribute14 => p_qua_attendance(1).attribute14
		   ,p_attribute15 => p_qua_attendance(1).attribute15
		   ,p_attribute16 => p_qua_attendance(1).attribute16
		   ,p_attribute17 => p_qua_attendance(1).attribute17
		   ,p_attribute18 => p_qua_attendance(1).attribute18
		   ,p_attribute19 => p_qua_attendance(1).attribute19
		   ,p_attribute20 => p_qua_attendance(1).attribute20
		   ,p_object_version_number => l_pea_object_version_number);
		  l_attendance_id := l_old_attendance_id;
	     end if;
      end if;
    end if; --end update attendance

    -- update qua record for both qua and award
    --per_qua_upd.upd
    PER_QUALIFICATIONS_API.UPDATE_QUALIFICATION
             (p_validate => FALSE
             ,p_effective_date => sysdate
             ,p_qualification_id => p_qualifications(1).qualification_id
             --,p_business_group_id => p_qualifications(1).business_group_id
             ,p_object_version_number =>
                   l_pq_object_version_number
             --,p_person_id => decode_value(p_expression =>
             --                      l_attendance_id IS null
             --,p_true => p_qualifications(1).person_id
             --,p_false => null)
             ,p_title => p_qualifications(1).title
             ,p_status => p_qualifications(1).status
             ,p_start_date => p_qualifications(1).start_date
             ,p_end_date => p_qualifications(1).end_date
             ,p_attendance_id => l_attendance_id
             ,p_grade_attained => p_qualifications(1).grade_attained
             ,p_awarded_date => p_qualifications(1).awarded_date
             ,p_fee => p_qualifications(1).fee
             ,p_fee_currency => p_qualifications(1).fee_currency
             ,p_training_completed_amount =>
                      p_qualifications(1).training_completed_amount
             ,p_reimbursement_arrangements =>
                      p_qualifications(1).reimbursement_arrangements
             ,p_training_completed_units =>
                      p_qualifications(1).training_completed_units
             ,p_total_training_amount =>
                      p_qualifications(1).total_training_amount
             ,p_license_number => p_qualifications(1).license_number
             ,p_expiry_date => p_qualifications(1).expiry_date
             ,p_license_restrictions => p_qualifications(1).license_restrictions
             ,p_awarding_body => p_qualifications(1).awarding_body
             ,p_tuition_method => p_qualifications(1).tuition_method
             ,p_group_ranking => p_qualifications(1).group_ranking
             ,p_comments => substr(p_qualifications(1).comments,1,2000)
             ,p_attribute_category => p_qualifications(1).attribute_category
             ,p_attribute1 => p_qualifications(1).attribute1
             ,p_attribute2 => p_qualifications(1).attribute2
             ,p_attribute3 => p_qualifications(1).attribute3
             ,p_attribute4 => p_qualifications(1).attribute4
             ,p_attribute5 => p_qualifications(1).attribute5
             ,p_attribute6 => p_qualifications(1).attribute6
             ,p_attribute7 => p_qualifications(1).attribute7
             ,p_attribute8 => p_qualifications(1).attribute8
             ,p_attribute9 => p_qualifications(1).attribute9
             ,p_attribute10 => p_qualifications(1).attribute10
             ,p_attribute11 => p_qualifications(1).attribute11
             ,p_attribute12 => p_qualifications(1).attribute12
             ,p_attribute13 => p_qualifications(1).attribute13
             ,p_attribute14 => p_qualifications(1).attribute14
             ,p_attribute15 => p_qualifications(1).attribute15
             ,p_attribute16 => p_qualifications(1).attribute16
             ,p_attribute17 => p_qualifications(1).attribute17
             ,p_attribute18 => p_qualifications(1).attribute18
             ,p_attribute19 => p_qualifications(1).attribute19
             ,p_attribute20 => p_qualifications(1).attribute20
             ,p_qua_information_category => p_qualifications(1).qua_information_category
             ,p_qua_information1 => p_qualifications(1).qua_information1
             ,p_qua_information2 => p_qualifications(1).qua_information2
             ,p_qua_information3 => p_qualifications(1).qua_information3
             ,p_qua_information4 => p_qualifications(1).qua_information4
             ,p_qua_information5 => p_qualifications(1).qua_information5
             ,p_qua_information6 => p_qualifications(1).qua_information6
             ,p_qua_information7 => p_qualifications(1).qua_information7
             ,p_qua_information8 => p_qualifications(1).qua_information8
             ,p_qua_information9 => p_qualifications(1).qua_information9
             ,p_qua_information10 => p_qualifications(1).qua_information10
             ,p_qua_information11 => p_qualifications(1).qua_information11
             ,p_qua_information12 => p_qualifications(1).qua_information12
             ,p_qua_information13 => p_qualifications(1).qua_information13
             ,p_qua_information14 => p_qualifications(1).qua_information14
             ,p_qua_information15 => p_qualifications(1).qua_information15
             ,p_qua_information16 => p_qualifications(1).qua_information16
             ,p_qua_information17 => p_qualifications(1).qua_information17
             ,p_qua_information18 => p_qualifications(1).qua_information18
             ,p_qua_information19 => p_qualifications(1).qua_information19
             ,p_qua_information20 => p_qualifications(1).qua_information20
            );

    -- update subject record for both qua and award
    hr_utility.set_location('Entering For Loop:'||l_proc,65);
    FOR i IN 1..NVL(p_qua_subjects.count, 0) LOOP
            l_subjects_taken_id := p_qua_subjects(i).subjects_taken_id;
            l_pst_object_version_number :=
                  p_qua_subjects(i).object_version_number;
      IF p_qua_subjects(i).delete_flag = 'N' THEN
        IF l_subjects_taken_id IS null THEN

	           --insert subject
            per_sub_ins.ins
                     (p_validate => FALSE
              	     ,p_effective_date => sysdate
 	             ,p_subjects_taken_id => l_subjects_taken_id
 	             ,p_start_date => p_qua_subjects(i).start_date
	             ,p_end_date => p_qua_subjects(i).end_date
	             ,p_major => p_qua_subjects(i).major
 	             ,p_subject_status => p_qua_subjects(i).subject_status
 	             ,p_subject => p_qua_subjects(i).subject
	             ,p_grade_attained => p_qua_subjects(i).grade_attained
	             ,p_qualification_id => p_qualifications(1).qualification_id
	             ,p_object_version_number => l_pst_object_version_number
                     ,p_attribute_category => p_qua_subjects(i).attribute_category
                     ,p_attribute1 => p_qua_subjects(i).attribute1
                     ,p_attribute2 => p_qua_subjects(i).attribute2
                     ,p_attribute3 => p_qua_subjects(i).attribute3
                     ,p_attribute4 => p_qua_subjects(i).attribute4
                     ,p_attribute5 => p_qua_subjects(i).attribute5
                     ,p_attribute6 => p_qua_subjects(i).attribute6
                     ,p_attribute7 => p_qua_subjects(i).attribute7
                     ,p_attribute8 => p_qua_subjects(i).attribute8
                     ,p_attribute9 => p_qua_subjects(i).attribute9
                     ,p_attribute10 => p_qua_subjects(i).attribute10
                     ,p_attribute11 => p_qua_subjects(i).attribute11
                     ,p_attribute12 => p_qua_subjects(i).attribute12
                     ,p_attribute13 => p_qua_subjects(i).attribute13
                     ,p_attribute14 => p_qua_subjects(i).attribute14
                     ,p_attribute15 => p_qua_subjects(i).attribute15
                     ,p_attribute16 => p_qua_subjects(i).attribute16
                     ,p_attribute17 => p_qua_subjects(i).attribute17
                     ,p_attribute18 => p_qua_subjects(i).attribute18
                     ,p_attribute19 => p_qua_subjects(i).attribute19
                     ,p_attribute20 => p_qua_subjects(i).attribute20
                     ,p_sub_information_category => p_qua_subjects(i).sub_information_category
                     ,p_sub_information1 => p_qua_subjects(i).sub_information1
                     ,p_sub_information2 => p_qua_subjects(i).sub_information2
                     ,p_sub_information3 => p_qua_subjects(i).sub_information3
                     ,p_sub_information4 => p_qua_subjects(i).sub_information4
                     ,p_sub_information5 => p_qua_subjects(i).sub_information5
                     ,p_sub_information6 => p_qua_subjects(i).sub_information6
                     ,p_sub_information7 => p_qua_subjects(i).sub_information7
                     ,p_sub_information8 => p_qua_subjects(i).sub_information8
                     ,p_sub_information9 => p_qua_subjects(i).sub_information9
                     ,p_sub_information10 => p_qua_subjects(i).sub_information10
                     ,p_sub_information11 => p_qua_subjects(i).sub_information11
                     ,p_sub_information12 => p_qua_subjects(i).sub_information12
                     ,p_sub_information13 => p_qua_subjects(i).sub_information13
                     ,p_sub_information14 => p_qua_subjects(i).sub_information14
                     ,p_sub_information15 => p_qua_subjects(i).sub_information15
                     ,p_sub_information16 => p_qua_subjects(i).sub_information16
                     ,p_sub_information17 => p_qua_subjects(i).sub_information17
                     ,p_sub_information18 => p_qua_subjects(i).sub_information18
                     ,p_sub_information19 => p_qua_subjects(i).sub_information19
                     ,p_sub_information20 => p_qua_subjects(i).sub_information20
                   );
            per_sbt_ins.ins_tl
              (p_language_code =>  hr_api.userenv_lang
              ,p_subjects_taken_id => l_subjects_taken_id
              ,p_grade_attained => p_qua_subjects(i).grade_attained
              );
        ELSE

               --update subject
                per_sub_upd.upd(p_validate => FALSE
                  ,p_effective_date => sysdate
                  ,p_subjects_taken_id => l_subjects_taken_id
                  ,p_start_date => p_qua_subjects(i).start_date
                  ,p_end_date => p_qua_subjects(i).end_date
	          ,p_major => p_qua_subjects(i).major
                  ,p_subject_status => p_qua_subjects(i).subject_status
                  ,p_subject => p_qua_subjects(i).subject
                  ,p_grade_attained => p_qua_subjects(i).grade_attained
                  ,p_qualification_id => p_qualifications(1).qualification_id
                  ,p_object_version_number => l_pst_object_version_number
                  ,p_attribute_category => p_qua_subjects(i).attribute_category
                  ,p_attribute1 => p_qua_subjects(i).attribute1
                  ,p_attribute2 => p_qua_subjects(i).attribute2
                  ,p_attribute3 => p_qua_subjects(i).attribute3
                  ,p_attribute4 => p_qua_subjects(i).attribute4
                  ,p_attribute5 => p_qua_subjects(i).attribute5
                  ,p_attribute6 => p_qua_subjects(i).attribute6
                  ,p_attribute7 => p_qua_subjects(i).attribute7
                  ,p_attribute8 => p_qua_subjects(i).attribute8
                  ,p_attribute9 => p_qua_subjects(i).attribute9
                  ,p_attribute10 => p_qua_subjects(i).attribute10
                  ,p_attribute11 => p_qua_subjects(i).attribute11
                  ,p_attribute12 => p_qua_subjects(i).attribute12
                  ,p_attribute13 => p_qua_subjects(i).attribute13
                  ,p_attribute14 => p_qua_subjects(i).attribute14
                  ,p_attribute15 => p_qua_subjects(i).attribute15
                  ,p_attribute16 => p_qua_subjects(i).attribute16
                  ,p_attribute17 => p_qua_subjects(i).attribute17
                  ,p_attribute18 => p_qua_subjects(i).attribute18
                  ,p_attribute19 => p_qua_subjects(i).attribute19
                  ,p_attribute20 => p_qua_subjects(i).attribute20
                  ,p_sub_information_category => p_qua_subjects(i).sub_information_category
                  ,p_sub_information1 => p_qua_subjects(i).sub_information1
                  ,p_sub_information2 => p_qua_subjects(i).sub_information2
                  ,p_sub_information3 => p_qua_subjects(i).sub_information3
                  ,p_sub_information4 => p_qua_subjects(i).sub_information4
                  ,p_sub_information5 => p_qua_subjects(i).sub_information5
                  ,p_sub_information6 => p_qua_subjects(i).sub_information6
                  ,p_sub_information7 => p_qua_subjects(i).sub_information7
                  ,p_sub_information8 => p_qua_subjects(i).sub_information8
                  ,p_sub_information9 => p_qua_subjects(i).sub_information9
                  ,p_sub_information10 => p_qua_subjects(i).sub_information10
                  ,p_sub_information11 => p_qua_subjects(i).sub_information11
                  ,p_sub_information12 => p_qua_subjects(i).sub_information12
                  ,p_sub_information13 => p_qua_subjects(i).sub_information13
                  ,p_sub_information14 => p_qua_subjects(i).sub_information14
                  ,p_sub_information15 => p_qua_subjects(i).sub_information15
                  ,p_sub_information16 => p_qua_subjects(i).sub_information16
                  ,p_sub_information17 => p_qua_subjects(i).sub_information17
                  ,p_sub_information18 => p_qua_subjects(i).sub_information18
                  ,p_sub_information19 => p_qua_subjects(i).sub_information19
                  ,p_sub_information20 => p_qua_subjects(i).sub_information20
                );
            per_sbt_upd.upd_tl
              (p_language_code =>  hr_api.userenv_lang
              ,p_subjects_taken_id => l_subjects_taken_id
              ,p_grade_attained => p_qua_subjects(i).grade_attained
              );

    	END IF;
      ELSE
        IF l_subjects_taken_id IS NOT null THEN
          per_sbt_del.del_tl
            (p_subjects_taken_id => l_subjects_taken_id);
	  per_sub_del.del(p_validate => FALSE
               ,p_subjects_taken_id  => l_subjects_taken_id
               ,p_object_version_number => l_pst_object_version_number);
        END IF;
      END IF;
    END LOOP;
    hr_utility.set_location('Exiting For Loop:'||l_proc,70);
  END IF;

  IF p_validate = TRUE THEN
    rollback to validate_qua;
  END IF;
hr_utility.set_location('Exiting:'||l_proc, 15);
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    rollback to validate_qua;
    raise;
END validate_api;

-- End of Procedure validate_api

-- Start of Procedure start_transaction
Procedure start_transaction(itemtype     in     varchar2
                           ,itemkey      in     varchar2
                           ,actid        in     number
                           ,funmode      in     varchar2
                           ,p_selected_person_id in number
                           ,p_creator_person_id in number
                           ,result         out nocopy  varchar2) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_transaction_privilege    hr_api_transactions.transaction_privilege%type;
  l_transaction_id           hr_api_transactions.transaction_id%type;
  l_transaction_step_id      hr_api_transaction_steps.transaction_step_id%type;
  l_proc   varchar2(72)  := g_package||'start_transaction';

--  l_person_id        hr_api_transactions.creator_person_id%type := p_selected_person_id;

Cursor c_get_transaction_step_id
       is
       select
       transaction_step_id
       from
       hr_api_transaction_steps
       where
       transaction_id = l_transaction_id;

Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  if funmode = 'RUN' then
  hr_utility.set_location('funmode=RUN:'||l_proc,10);
    savepoint start_transaction;

    -- check to see if the TRANSACTION_ID attribute has been created
    if hr_workflow_utility.item_attribute_exists
        	(p_item_type => itemtype
                ,p_item_key  => itemkey
                ,p_name      => 'TRANSACTION_ID') then

      -- the TRANSACTION_ID exists so ensure that it is null


      if hr_transaction_ss.get_transaction_id
		(p_item_type => itemtype
                ,p_item_key  => itemkey) is not null then

        -- a current transaction is in progress we cannot overwrite it
        -- get the Transaction Step Id
        hr_utility.set_location('If itemtype and itemKey is not null:'||l_proc,15);
        l_transaction_id := hr_transaction_ss.get_transaction_id
                              (p_item_type => itemtype
                              ,p_item_key  => itemkey);
        open c_get_transaction_step_id;
        fetch c_get_transaction_step_id into l_transaction_step_id;
        close c_get_transaction_step_id;
        hr_transaction_ss.delete_transaction_step
          (l_transaction_step_id,null,p_creator_person_id);
      end if;
    end if;
      -- the TRANSACTION_ID attribute has not been created. create it.
    hr_transaction_ss.start_transaction
        (itemtype => itemtype
        ,itemkey => itemkey
        ,actid => actid
        ,funmode => funmode
        ,p_selected_person_id => p_selected_person_id
        ,p_login_person_id => p_creator_person_id
        ,result => result);

    result := 'SUCCESS';

elsif funmode = 'CANCEL' then
    null;
end if;

hr_utility.set_location('Exiting:'||l_proc, 20);
Exception
  when others then
    hr_utility.set_location('Exception:Others'||l_proc,555);
    rollback to start_transaction;
    raise;
End start_transaction;

-- End of Procedure start_transaction

-- Start of Function get_pending_items
Function get_pending_items
  (p_item_type in wf_items.item_type%type
  ,p_api_name in varchar2
  ,p_current_person_id in number
  ,p_result_code in varchar2
  ) return hr_workflow_service.active_wf_trans_items_list is

  -- Local cursor definitions
 cursor csr_pending_items  is
    select transaction_step_id, activity_id, t.item_key
    from  hr_api_transactions t, hr_api_transaction_steps ts
         ,wf_item_activity_statuses s
    where t.selected_person_id = p_current_person_id
    and t.status = 'Y'
    and t.item_type = p_item_type
    and t.transaction_id = ts.transaction_id
    and ts.api_name  = p_api_name
    and t.item_type = s.item_type
    and t.item_key = s.item_key
    and s.activity_result_code = p_result_code;

  -- Local variable definitions
 l_count  integer;
 l_active_wf_items_list  hr_workflow_service.active_wf_trans_items_list;
 l_proc   varchar2(72)  := g_package||'get_pending_items';
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_count := 0;
  hr_utility.set_location('Entering For Loop:'||l_proc,10);
  For I in csr_pending_items Loop
    l_count := l_count + 1;
    l_active_wf_items_list(l_count).active_item_key := I.item_key;
    l_active_wf_items_list(l_count).activity_id := I.activity_id;
    l_active_wf_items_list(l_count).trans_step_id := I.transaction_step_id;
  End Loop;
  hr_utility.set_location('Exiting For Loop:'||l_proc,15);
  hr_utility.set_location('Exiting:'||l_proc, 20);
  return l_active_wf_items_list;
End get_pending_items;

-- Start of Procedure get_pending_transaction_steps

Procedure get_pending_transaction_steps
  (p_item_type          in varchar2
  ,p_selected_person_id in varchar2
  ,p_mode               in varchar2
  ,p_process_name       in varchar2
  ,p_activity_name     in varchar2
  ,p_transaction_step_id out nocopy hr_util_misc_web.g_varchar2_tab_type) IS

  l_active_item_keys hr_workflow_service.active_wf_trans_items_list;
  l_pending_count  number;
  l_transaction_step_id  hr_api_transaction_steps.transaction_step_id%type;
  l_trs_object_version_number hr_api_transaction_steps.object_version_number%type;
  l_is_workflow_complete varchar2(1) := 'N';
  j number := 1;
  l_result_code varchar2(30);
  l_proc   varchar2(72)  := g_package||'get_pending_transaction_steps';

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  IF p_mode = HR_QUA_AWARDS_UTIL_SS.EDUCATION THEN
    hr_utility.set_location('mode=EDUCATION :'||l_proc,10);
    l_result_code := HR_QUA_AWARDS_UTIL_SS.EDUCATION_CHANGED;
  ELSE
    hr_utility.set_location('mode!=Education:'||l_proc,15);
    l_result_code := HR_QUA_AWARDS_UTIL_SS.AWARD_CHANGED;
  END IF;

    l_active_item_keys :=
        get_pending_items
         (p_item_type => p_item_type
         ,p_api_name => HR_QUA_AWARDS_UTIL_SS.API_NAME
         ,p_current_person_id => p_selected_person_id
         ,p_result_code => l_result_code
         );

     l_pending_count := NVL(l_active_item_keys.count,0);

     hr_utility.set_location('Entering For Loop:'||l_proc,20);
     FOR i IN 1..l_pending_count LOOP
        p_transaction_step_id(j) := l_active_item_keys(i).trans_step_id;
        j := j +1;
     END LOOP;
     hr_utility.set_location('Exiting For Loop:'||l_proc,25);

hr_utility.set_location('Exiting:'||l_proc, 30);
END get_pending_transaction_steps;


-- End of Procedure get_pending_transaction_steps

-- start of procedure check_errors

PROCEDURE check_errors
  (p_ignore_sub_date_boundaries  in varchar2
  ,p_mode                    in varchar2
  ,p_qualifications          in SSHR_QUA_TAB_TYP
  ,p_qua_subjects            in SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance          in SSHR_QUA_ATTENDANCE_TAB_TYP
  ,p_error_message           out nocopy varchar2
  ,p_subjects_error_message  out nocopy varchar2) IS

  cursor c1(p_start_date in date,
            p_end_date in date,
            p_person_id in number,
            p_business_group_id in number,
            p_qualification_type_id in number,
            p_attendance_id in number,
            p_title in varchar2,
            p_qualification_id number) is
    select null
    from   per_qualifications per
    where  per.qualification_type_id = p_qualification_type_id
    --and    nvl(per.party_id,-1) = nvl(p_party_id,-1)
    and    nvl(per.person_id,-1) = nvl(p_person_id,-1)
    and    nvl(per.attendance_id,-1) = nvl(p_attendance_id,-1)
    and    per.business_group_id +0 = p_business_group_id
    and    per.title = p_title
    and    per.qualification_id <> nvl(p_qualification_id,-1)
    and    (nvl(per.start_date,hr_api.g_sot)
    between nvl(p_start_date,hr_api.g_sot)
    and     nvl(p_end_date,hr_api.g_eot)
    or      nvl(per.end_date,nvl(per.start_date,p_start_date))
    between nvl(p_start_date,hr_api.g_sot)
    and     nvl(p_end_date,hr_api.g_eot));

  l_date_test                    date;
  l_pea_start_date               date;
  l_pea_end_date                 date;
  l_number_test                  number;
  l_error                        boolean;
  l_pq_date_error                boolean;
  l_pea_date_error               boolean;
  l_length                       number;
  l_start_date                   date;
  l_end_date                     date;
  l_fee1                         number(15,2);
  l_fee2                         number;
  l_dummy                        varchar2(1);
  l_proc   varchar2(72)  := g_package||'check_errors';


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  BEGIN
    l_length := length(p_qualifications(1).comments);
    IF l_length > 2000 THEN
	  --fnd_message.set_name('PER','HR_COMMENT_EXCEED_MAX_LENGTH');
      --hr_utility.raise_error;
      hr_utility.set_location('length>2000:'||l_proc,10);
      p_error_message := nvl(p_error_message,'')||'!'||'|'||'Comments'||'|'||'PER'||'|'||'HR_COMMENT_EXCEED_MAX_LENGTH'||'|'||'!';
	END IF;
  EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Exception:Others'||l_proc,555);
       raise;
  END;

  IF p_mode = HR_QUA_AWARDS_UTIL_SS.EDUCATION THEN
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ATT_OVERLAP
  -- CHK_ATTENDED_START_DATE
  -- CHK_ATTENDED_END_DATE
  -- CHK_ATT_TO_DATE
  hr_utility.set_location('mode is Education:'||l_proc,20);
  l_pea_date_error := FALSE;

  BEGIN
    IF p_qua_attendance(1).attended_start_date is not null and
       p_qua_attendance(1).attended_end_date is not null and
       p_qua_attendance(1).attended_start_date >
            p_qua_attendance(1).attended_end_date THEN
        --fnd_message.set_name('PER','HR_51496_ESA_ATT_END_DATE');
        --hr_utility.raise_error;
        hr_utility.set_location('Startdate>EndDate:'||l_proc,25);
        p_error_message := nvl(p_error_message,'')||'!'||'|'||'AttendedStartDate'||'|'||'PER'||'|'||'HR_51496_ESA_ATT_END_DATE'||'|'||'!';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    l_pea_date_error := TRUE;
        raise;
  END;

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_START_DATE
  -- CHK_END_DATE
  l_pq_date_error := FALSE;

  IF l_pq_date_error = FALSE AND l_pea_date_error = FALSE THEN
    -- the start date and end date are valid values.
    -- qualification record that uses the establishment
    -- attendance id do not have a qualification start date that falls
    -- outside of the attendance start dates.
    IF p_qualifications(1).start_date is not null and
      p_qualifications(1).end_date is not null and
      p_qualifications(1).start_date > p_qualifications(1).end_date
    THEN
      --fnd_message.set_name('PAY','HR_51853_QUA_DATE_INV');
      --hr_utility.raise_error;
      hr_utility.set_location('StartDate>endDate:'||l_proc,30);
      p_error_message := nvl(p_error_message,'')||'!'||'|'||'StartDate'||'|'||'PAY'||'|'||'HR_51853_QUA_DATE_INV'||'|'||'!';
    END IF;
    IF p_mode = HR_QUA_AWARDS_UTIL_SS.EDUCATION THEN
      IF p_qualifications(1).start_date is not null and
        p_qua_attendance(1).attended_start_date is not null and
        p_qualifications(1).start_date < p_qua_attendance(1).attended_start_date
      THEN
        --fnd_message.set_name('PAY','HR_51841_QUA_DATES_OUT_ESA');
        --hr_utility.raise_error;
        hr_utility.set_location('startdate<attended_start_date:'||l_proc,35);
        p_error_message := nvl(p_error_message,'')||'!'||'|'||'StartDate'||'|'||'PAY'||'|'||'HR_51841_QUA_DATES_OUT_ESA'||'|'||'!';
      END IF;
      IF p_qualifications(1).end_date is not null
        and p_qua_attendance(1).attended_end_date is not null
        and p_qualifications(1).end_date > p_qua_attendance(1).attended_end_date
      THEN
        --fnd_message.set_name('PAY','HR_51841_QUA_DATES_OUT_ESA');
        --hr_utility.raise_error;
        hr_utility.set_location('end_date>attended_end_date:'||l_proc,40);
        p_error_message := nvl(p_error_message,'')||'!'||'|'||'EndDate'||'|'||'PAY'||'|'||'HR_51841_QUA_DATES_OUT_ESA'||'|'||'!';
      END IF;
    END IF;
  END IF;

  IF l_pq_date_error = FALSE THEN
    BEGIN
    --
    -- Business Rule Mapping
    -- =====================
    -- CHK_QUAL_OVERLAP
    hr_utility.set_location('date_error=FALSE:'||l_proc,45);
    OPEN c1(p_qualifications(1).start_date,
            p_qualifications(1).end_date,
            p_qualifications(1).person_id,
            p_qualifications(1).business_group_id,
            p_qualifications(1).qualification_type_id,
            p_qualifications(1).attendance_id,
            p_qualifications(1).title,
            p_qualifications(1).qualification_id);
    FETCH c1 into l_dummy;
    if c1%found then
      hr_utility.set_location('c1%found:'||l_proc,50);
      close c1;
      fnd_message.set_name('PAY','HR_51847_QUA_REC_EXISTS');
      hr_utility.raise_error;
      end if;
    CLOSE c1;
    EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Exception:Others'||l_proc,555);
       raise;
    END;
  END IF;
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FEE
  -- CHK_FEE_CURRENCY
  l_error := FALSE;
  BEGIN
      per_qua_bus.chk_fee
        (p_qualification_id      => p_qualifications(1).qualification_id,
         p_fee                   => p_qualifications(1).fee,
         p_fee_currency          => p_qualifications(1).fee_currency,
         p_object_version_number => p_qualifications(1).object_version_number);
    EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Exception:Others'||l_proc,555);
      raise;
    END;
  END IF;

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_AWARDED_DATE
  l_error := FALSE;
  IF l_error = FALSE AND l_pq_date_error = FALSE THEN
    BEGIN
      per_qua_bus.chk_awarded_date
        (p_qualification_id      => p_qualifications(1).qualification_id,
         p_awarded_date          => p_qualifications(1).awarded_date,
         p_start_date            => p_qualifications(1).start_date,
         p_object_version_number => p_qualifications(1).object_version_number);
    EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Exception:Others'||l_proc,555);
      raise;
    END;
  END IF;

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_START_DATE
  -- CHK_END_DATE
  hr_utility.set_location('Entering For Loop:'||l_proc,55);
  FOR i IN 1..NVL(p_qua_subjects.count,0) LOOP
  IF p_qua_subjects(i).delete_flag = 'N' THEN
    l_error := FALSE;
    IF l_error = FALSE AND l_pq_date_error = FALSE THEN
      BEGIN
   	    -- the start date of the subject is before the end
        -- date of the subject.
        -- the start and end dates of the subject are within
        -- the start and end dates of the qualification.
        IF p_qua_subjects(i).start_date is not null and
           p_qua_subjects(i).end_date is not null and
           p_qua_subjects(i).start_date > p_qua_subjects(i).end_date
        THEN
          --fnd_message.set_name('PAY','HR_51816_SUB_START_DATE_INV');
          --hr_utility.raise_error;
           p_subjects_error_message := nvl(p_subjects_error_message,'')||'!'||'|'||to_char(i-1)||'|'||'StartDate'||'|'||'PAY'||'|'||'HR_51816_SUB_START_DATE_INV'||'|'||'!';
        END IF;
	IF p_ignore_sub_date_boundaries = 'N' THEN
          IF p_qua_subjects(i).start_date
            < p_qualifications(1).start_date THEN
            --fnd_message.set_name('PAY','HR_51817_SUB_START_DATE_QUAL');
            --hr_utility.raise_error;
            p_subjects_error_message := nvl(p_subjects_error_message,'')||'!'||'|'||to_char(i-1)||'|'||'StartDate'||'|'||'PAY'||'|'||'HR_51817_SUB_START_DATE_QUAL'||'|'||'!';
          END IF;
	END IF;
      EXCEPTION
        WHEN OTHERS THEN
        hr_utility.set_location('Exception:Others'||l_proc,555);
        raise;
      END;
    END IF;
  END IF;
  END LOOP;
  hr_utility.set_location('Exiting For Loop:'||l_proc,60);
  hr_utility.set_location('Exiting:'||l_proc, 65);
Exception
  when others then
    hr_utility.set_location('Exception:Others'||l_proc,555);
    raise;
END check_errors;

-- end of procedures check_errors

-- start of procedure get_entire_qua
/*
This method returns all the details for a Qualification/Award given a qualification id. This method
is being called from the java code to get the old values in the review page.
*/


PROCEDURE get_entire_qua
  (p_transaction_step_id    in varchar2
  ,p_mode                   out nocopy varchar2
  ,p_qualifications         out nocopy SSHR_QUA_TAB_TYP
  ,p_qua_subjects           out nocopy SSHR_QUA_SUBJECT_TAB_TYP
  ,p_qua_attendance         out nocopy SSHR_QUA_ATTENDANCE_TAB_TYP) IS

  l_subject_count           number;
  l_qua_count               number := 1;
  l_attendance_count        number := 1;
  l_proc   varchar2(72)  := g_package||'get_entire_qua';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);
  p_mode :=
    hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_MODE');

  l_subject_count := to_number(
    hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUBJECT_COUNT'));

  p_qua_attendance := SSHR_QUA_ATTENDANCE_TAB_TYP();

  hr_utility.set_location('Entering For Loop:'||l_proc,10);
  FOR i IN 1..NVL(l_attendance_count,0) LOOP
    p_qua_attendance.extend;
    p_qua_attendance(i) :=  SSHR_QUA_ATTENDANCE_OBJ_TYP(
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTENDANCE_ID')),
      hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_START_DATE'),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_PERSON_ID')),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_FULL_TIME'),
      hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_END_DATE'),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ESTABLISHMENT_ID')),
      to_number(hr_transaction_api.get_varchar2_value
        (p_transaction_step_id =>  p_transaction_step_id
        ,p_name                => 'P_PEA_OBJECT_VERSION_NUMBER')),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_BUSINESS_GROUP_ID'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE_CATEGORY'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE1'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE2'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE3'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE4'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE5'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE6'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE7'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE8'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE9'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE10'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE11'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE12'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE13'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE14'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE15'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE16'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE17'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE18'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE19'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PEA_ATTRIBUTE20'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PE_NAME'),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PARTY_ID'))
    );
  END LOOP;
  hr_utility.set_location('Exiting For Loop:'||l_proc,15);

  p_qualifications := SSHR_QUA_TAB_TYP();

    hr_utility.set_location('Entering For Loop:'||l_proc,20);
  FOR i IN 1..NVL(l_qua_count,0) LOOP
    p_qualifications.extend;
    p_qualifications(i) :=  SSHR_QUA_OBJ_TYP(
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_QUALIFICATION_ID')),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_DELETE_FLAG'),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_BUSINESS_GROUP_ID')),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_OBJECT_VERSION_NUMBER')),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_PERSON_ID')),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_TITLE'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_GRADE_ATTAINED'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_STATUS'),
      hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_AWARDED_DATE'),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_FEE')),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_FEE_CURRENCY'),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_COMPLETED_AMOUNT')),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_REIMBURSEMENT'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_COMPLETED_UNITS'),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_TOTAL_AMOUNT')),
      hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_START_DATE'),
      hr_transaction_api.get_date_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_PQ_END_DATE'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_LICENSE_NUMBER'),
      hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_EXPIRY_DATE'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_LICENSE_RESTRICTIONS'),
      null, --PROJECTED_COMPLETION_DATE
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_AWARDING_BODY'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_TUITION_METHOD'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_GROUP_RANKING'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_COMMENTS'),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_QUALIFICATION_TYPE_ID')),
      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTENDANCE_ID')),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE_CATEGORY'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE1'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE2'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE3'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE4'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE5'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE6'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE7'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE8'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE9'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE10'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE11'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE12'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE13'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE14'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE15'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE16'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE17'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE18'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE19'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_ATTRIBUTE20'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION_CATEGORY'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION1'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION2'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION3'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION4'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION5'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION6'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION7'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION8'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION9'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION10'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION11'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION12'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION13'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION14'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION15'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION16'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION17'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION18'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION19'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_QUA_INFORMATION20'),
      null,null,null,null,
      /*hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_PROFESSIONAL_BODY_NAME'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_MEMBERSHIP_NUMBER'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_MEMBERSHIP_CATEGORY'),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PQ_SUBS_PAYMENT_METHOD'),*/
      hr_transaction_api.get_number_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PARTY_ID')
    );
  END LOOP;
  hr_utility.set_location('Exiting For Loop:'||l_proc,25);


  -- now get the subject details
  p_qua_subjects := SSHR_QUA_SUBJECT_TAB_TYP();

  hr_utility.set_location('Entering For Loop:'||l_proc,30);
  FOR i IN 1..NVL(l_subject_count,0) LOOP
    p_qua_subjects.extend;
    p_qua_subjects(i) :=  SSHR_QUA_SUBJECT_OBJ_TYP(

      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUBJECTS_TAKEN_ID'||i)),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PST_DELETE_FLAG'||i),

      hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PST_START_DATE'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PST_MAJOR'||i),
      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PST_SUBJECT_STATUS'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PST_SUBJECT'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PST_GRADE_ATTAINED'||i),

      hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PST_END_DATE'||i),

      hr_transaction_api.get_number_value
         (p_transaction_step_id =>  p_transaction_step_id
         ,p_name                => 'P_QUALIFICATION_ID'),

      to_number(hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PST_OBJECT_VERSION_NUMBER'||i)),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_PST_ATTRIBUTE_CATEGORY'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE1_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE2_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE3_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE4_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE5_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE6_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE7_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE8_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE9_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE10_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE11_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE12_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE13_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE14_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE15_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE16_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE17_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE18_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE19_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ATTRIBUTE20_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION_CATEGORY'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION1_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION2_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION3_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION4_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION5_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION6_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION7_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION8_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION9_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION10_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION11_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION12_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION13_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION14_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION15_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION16_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION17_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION18_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION19_PST'||i),

      hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_SUB_INFORMATION20_PST'||i)
      );

  END LOOP;
  hr_utility.set_location('Exiting For Loop:'||l_proc,35);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    RAISE;
END get_entire_qua;


-- end of procedure get_entire_qua


Procedure rollback_transaction_step
( p_transaction_step_id varchar2
 ) is
 l_proc   varchar2(72)  := g_package||'rollback_transaction_step';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  delete from hr_api_transaction_values where transaction_step_id = p_transaction_step_id;
  delete from hr_api_transaction_steps where transaction_step_id = p_transaction_step_id;
  hr_utility.set_location('Exiting:'||l_proc, 15);

Exception
 when others then
   hr_utility.set_location('Exception:Others'||l_proc,555);
   raise;
End rollback_transaction_step;

/*
This method is returns the qualification id given a transaction step id.
*/

Function get_qualification_id ( p_transaction_step_id number )
         return Number is

    l_qualification_id number := 0;
    l_proc   varchar2(72)  := g_package||'get_qualification_id';
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  l_qualification_id :=
    hr_transaction_api.get_varchar2_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'p_qualification_id');

  hr_utility.set_location('Exiting:'||l_proc, 15);
  return nvl(l_qualification_id,0);
Exception
  when others then
    hr_utility.set_location('Exception:Others'||l_proc,555);
    raise;
End;

/*
This method is used to delete the data from the transaction tables for a given transaction step id
*/
Procedure delete_transaction_step ( p_transaction_step_id in number,
                                    p_creator_person_id in number ) IS
                                    l_proc   varchar2(72)  := g_package||'delete_transaction_step';

Begin

    -- delete the old transaction values
    hr_utility.set_location('Entering:'||l_proc, 5);
    hr_transaction_ss.delete_transaction_step(p_transaction_step_id,null,p_creator_person_id);
    hr_utility.set_location('Exiting:'||l_proc, 15);
Exception
 when others then
   hr_utility.set_location('Exception:Others'||l_proc,555);
   raise;
End;


END hr_qua_awards_util_ss;

--end of package hr_qua_awards_util_ss

/
