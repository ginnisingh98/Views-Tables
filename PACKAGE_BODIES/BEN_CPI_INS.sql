--------------------------------------------------------
--  DDL for Package Body BEN_CPI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPI_INS" as
/* $Header: becpirhi.pkb 120.0 2005/05/28 01:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpi_ins.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_group_per_in_ler_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_group_per_in_ler_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  ben_cpi_ins.g_group_per_in_ler_id_i := p_group_per_in_ler_id;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;
End set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure inserts a row into the HR_APPLICATION_OWNERSHIPS table
--   when the row handler is called in the appropriate mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column  IN varchar2
                               ,p_pk_value   IN varchar2) IS
--
CURSOR csr_definition IS
  SELECT product_short_name
    FROM hr_owner_definitions
   WHERE session_id = hr_startup_data_api_support.g_session_id;
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode IN
                               ('STARTUP','GENERIC')) THEN
     --
     FOR c1 IN csr_definition LOOP
       --
       INSERT INTO hr_application_ownerships
         (key_name
         ,key_value
         ,product_name
         )
       VALUES
         (p_pk_column
         ,fnd_number.number_to_canonical(p_pk_value)
         ,c1.product_short_name
         );
     END LOOP;
  END IF;
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_app_ownerships >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  create_app_ownerships(p_pk_column, to_char(p_pk_value));
END create_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec in out nocopy ben_cpi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_cpi_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_cwb_person_info
  --
  insert into ben_cwb_person_info
      (group_per_in_ler_id
      ,assignment_id
      ,person_id
      ,supervisor_id
      ,effective_date
      ,full_name
      ,brief_name
      ,custom_name
      ,supervisor_full_name
      ,supervisor_brief_name
      ,supervisor_custom_name
      ,legislation_code
      ,years_employed
      ,years_in_job
      ,years_in_position
      ,years_in_grade
      ,employee_number
      ,start_date
      ,original_start_date
      ,adjusted_svc_date
      ,base_salary
      ,base_salary_change_date
      ,payroll_name
      ,performance_rating
      ,performance_rating_type
      ,performance_rating_date
      ,business_group_id
      ,organization_id
      ,job_id
      ,grade_id
      ,position_id
      ,people_group_id
      ,soft_coding_keyflex_id
      ,location_id
      ,pay_rate_id
      ,assignment_status_type_id
      ,frequency
      ,grade_annulization_factor
      ,pay_annulization_factor
      ,grd_min_val
      ,grd_max_val
      ,grd_mid_point
      ,grd_quartile
      ,grd_comparatio
      ,emp_category
      ,change_reason
      ,normal_hours
      ,email_address
      ,base_salary_frequency
      ,new_assgn_ovn
      ,new_perf_event_id
      ,new_perf_review_id
      ,post_process_stat_cd
      ,feedback_rating
      ,feedback_comments
      ,object_version_number
      ,custom_segment1
      ,custom_segment2
      ,custom_segment3
      ,custom_segment4
      ,custom_segment5
      ,custom_segment6
      ,custom_segment7
      ,custom_segment8
      ,custom_segment9
      ,custom_segment10
      ,custom_segment11
      ,custom_segment12
      ,custom_segment13
      ,custom_segment14
      ,custom_segment15
      ,custom_segment16
      ,custom_segment17
      ,custom_segment18
      ,custom_segment19
      ,custom_segment20
      ,people_group_name
      ,people_group_segment1
      ,people_group_segment2
      ,people_group_segment3
      ,people_group_segment4
      ,people_group_segment5
      ,people_group_segment6
      ,people_group_segment7
      ,people_group_segment8
      ,people_group_segment9
      ,people_group_segment10
      ,people_group_segment11
      ,ass_attribute_category
      ,ass_attribute1
      ,ass_attribute2
      ,ass_attribute3
      ,ass_attribute4
      ,ass_attribute5
      ,ass_attribute6
      ,ass_attribute7
      ,ass_attribute8
      ,ass_attribute9
      ,ass_attribute10
      ,ass_attribute11
      ,ass_attribute12
      ,ass_attribute13
      ,ass_attribute14
      ,ass_attribute15
      ,ass_attribute16
      ,ass_attribute17
      ,ass_attribute18
      ,ass_attribute19
      ,ass_attribute20
      ,ass_attribute21
      ,ass_attribute22
      ,ass_attribute23
      ,ass_attribute24
      ,ass_attribute25
      ,ass_attribute26
      ,ass_attribute27
      ,ass_attribute28
      ,ass_attribute29
      ,ass_attribute30
      ,ws_comments
      ,cpi_attribute_category
      ,cpi_attribute1
      ,cpi_attribute2
      ,cpi_attribute3
      ,cpi_attribute4
      ,cpi_attribute5
      ,cpi_attribute6
      ,cpi_attribute7
      ,cpi_attribute8
      ,cpi_attribute9
      ,cpi_attribute10
      ,cpi_attribute11
      ,cpi_attribute12
      ,cpi_attribute13
      ,cpi_attribute14
      ,cpi_attribute15
      ,cpi_attribute16
      ,cpi_attribute17
      ,cpi_attribute18
      ,cpi_attribute19
      ,cpi_attribute20
      ,cpi_attribute21
      ,cpi_attribute22
      ,cpi_attribute23
      ,cpi_attribute24
      ,cpi_attribute25
      ,cpi_attribute26
      ,cpi_attribute27
      ,cpi_attribute28
      ,cpi_attribute29
      ,cpi_attribute30
      ,feedback_date
      )
  Values
    (p_rec.group_per_in_ler_id
    ,p_rec.assignment_id
    ,p_rec.person_id
    ,p_rec.supervisor_id
    ,p_rec.effective_date
    ,p_rec.full_name
    ,p_rec.brief_name
    ,p_rec.custom_name
    ,p_rec.supervisor_full_name
    ,p_rec.supervisor_brief_name
    ,p_rec.supervisor_custom_name
    ,p_rec.legislation_code
    ,p_rec.years_employed
    ,p_rec.years_in_job
    ,p_rec.years_in_position
    ,p_rec.years_in_grade
    ,p_rec.employee_number
    ,p_rec.start_date
    ,p_rec.original_start_date
    ,p_rec.adjusted_svc_date
    ,p_rec.base_salary
    ,p_rec.base_salary_change_date
    ,p_rec.payroll_name
    ,p_rec.performance_rating
    ,p_rec.performance_rating_type
    ,p_rec.performance_rating_date
    ,p_rec.business_group_id
    ,p_rec.organization_id
    ,p_rec.job_id
    ,p_rec.grade_id
    ,p_rec.position_id
    ,p_rec.people_group_id
    ,p_rec.soft_coding_keyflex_id
    ,p_rec.location_id
    ,p_rec.pay_rate_id
    ,p_rec.assignment_status_type_id
    ,p_rec.frequency
    ,p_rec.grade_annulization_factor
    ,p_rec.pay_annulization_factor
    ,p_rec.grd_min_val
    ,p_rec.grd_max_val
    ,p_rec.grd_mid_point
    ,p_rec.grd_quartile
    ,p_rec.grd_comparatio
    ,p_rec.emp_category
    ,p_rec.change_reason
    ,p_rec.normal_hours
    ,p_rec.email_address
    ,p_rec.base_salary_frequency
    ,p_rec.new_assgn_ovn
    ,p_rec.new_perf_event_id
    ,p_rec.new_perf_review_id
    ,p_rec.post_process_stat_cd
    ,p_rec.feedback_rating
    ,p_rec.feedback_comments
    ,p_rec.object_version_number
    ,p_rec.custom_segment1
    ,p_rec.custom_segment2
    ,p_rec.custom_segment3
    ,p_rec.custom_segment4
    ,p_rec.custom_segment5
    ,p_rec.custom_segment6
    ,p_rec.custom_segment7
    ,p_rec.custom_segment8
    ,p_rec.custom_segment9
    ,p_rec.custom_segment10
    ,p_rec.custom_segment11
    ,p_rec.custom_segment12
    ,p_rec.custom_segment13
    ,p_rec.custom_segment14
    ,p_rec.custom_segment15
    ,p_rec.custom_segment16
    ,p_rec.custom_segment17
    ,p_rec.custom_segment18
    ,p_rec.custom_segment19
    ,p_rec.custom_segment20
    ,p_rec.people_group_name
    ,p_rec.people_group_segment1
    ,p_rec.people_group_segment2
    ,p_rec.people_group_segment3
    ,p_rec.people_group_segment4
    ,p_rec.people_group_segment5
    ,p_rec.people_group_segment6
    ,p_rec.people_group_segment7
    ,p_rec.people_group_segment8
    ,p_rec.people_group_segment9
    ,p_rec.people_group_segment10
    ,p_rec.people_group_segment11
    ,p_rec.ass_attribute_category
    ,p_rec.ass_attribute1
    ,p_rec.ass_attribute2
    ,p_rec.ass_attribute3
    ,p_rec.ass_attribute4
    ,p_rec.ass_attribute5
    ,p_rec.ass_attribute6
    ,p_rec.ass_attribute7
    ,p_rec.ass_attribute8
    ,p_rec.ass_attribute9
    ,p_rec.ass_attribute10
    ,p_rec.ass_attribute11
    ,p_rec.ass_attribute12
    ,p_rec.ass_attribute13
    ,p_rec.ass_attribute14
    ,p_rec.ass_attribute15
    ,p_rec.ass_attribute16
    ,p_rec.ass_attribute17
    ,p_rec.ass_attribute18
    ,p_rec.ass_attribute19
    ,p_rec.ass_attribute20
    ,p_rec.ass_attribute21
    ,p_rec.ass_attribute22
    ,p_rec.ass_attribute23
    ,p_rec.ass_attribute24
    ,p_rec.ass_attribute25
    ,p_rec.ass_attribute26
    ,p_rec.ass_attribute27
    ,p_rec.ass_attribute28
    ,p_rec.ass_attribute29
    ,p_rec.ass_attribute30
    ,p_rec.ws_comments
    ,p_rec.cpi_attribute_category
    ,p_rec.cpi_attribute1
    ,p_rec.cpi_attribute2
    ,p_rec.cpi_attribute3
    ,p_rec.cpi_attribute4
    ,p_rec.cpi_attribute5
    ,p_rec.cpi_attribute6
    ,p_rec.cpi_attribute7
    ,p_rec.cpi_attribute8
    ,p_rec.cpi_attribute9
    ,p_rec.cpi_attribute10
    ,p_rec.cpi_attribute11
    ,p_rec.cpi_attribute12
    ,p_rec.cpi_attribute13
    ,p_rec.cpi_attribute14
    ,p_rec.cpi_attribute15
    ,p_rec.cpi_attribute16
    ,p_rec.cpi_attribute17
    ,p_rec.cpi_attribute18
    ,p_rec.cpi_attribute19
    ,p_rec.cpi_attribute20
    ,p_rec.cpi_attribute21
    ,p_rec.cpi_attribute22
    ,p_rec.cpi_attribute23
    ,p_rec.cpi_attribute24
    ,p_rec.cpi_attribute25
    ,p_rec.cpi_attribute26
    ,p_rec.cpi_attribute27
    ,p_rec.cpi_attribute28
    ,p_rec.cpi_attribute29
    ,p_rec.cpi_attribute30
    ,p_rec.feedback_date
    );
  --
  ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpi_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec  in out nocopy ben_cpi_shd.g_rec_type
  ) is
--
  Cursor C_Sel2 is
    Select null
      from ben_cwb_person_info
     where group_per_in_ler_id =
             ben_cpi_ins.g_group_per_in_ler_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  If (ben_cpi_ins.g_group_per_in_ler_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','ben_cwb_person_info');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.group_per_in_ler_id :=
      ben_cpi_ins.g_group_per_in_ler_id_i;
    ben_cpi_ins.g_group_per_in_ler_id_i := null;
  Else
     null;
/*    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.group_per_in_ler_id;
    Close C_Sel1; */
  End If;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                          in ben_cpi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    -- insert ownerships if applicable
    create_app_ownerships
      ('GROUP_PER_IN_LER_ID', p_rec.group_per_in_ler_id
      );
    --
    --
    ben_cpi_rki.after_insert
      (p_group_per_in_ler_id
      => p_rec.group_per_in_ler_id
      ,p_assignment_id
      => p_rec.assignment_id
      ,p_person_id
      => p_rec.person_id
      ,p_supervisor_id
      => p_rec.supervisor_id
      ,p_effective_date
      => p_rec.effective_date
      ,p_full_name
      => p_rec.full_name
      ,p_brief_name
      => p_rec.brief_name
      ,p_custom_name
      => p_rec.custom_name
      ,p_supervisor_full_name
      => p_rec.supervisor_full_name
      ,p_supervisor_brief_name
      => p_rec.supervisor_brief_name
      ,p_supervisor_custom_name
      => p_rec.supervisor_custom_name
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_years_employed
      => p_rec.years_employed
      ,p_years_in_job
      => p_rec.years_in_job
      ,p_years_in_position
      => p_rec.years_in_position
      ,p_years_in_grade
      => p_rec.years_in_grade
      ,p_employee_number
      => p_rec.employee_number
      ,p_start_date
      => p_rec.start_date
      ,p_original_start_date
      => p_rec.original_start_date
      ,p_adjusted_svc_date
      => p_rec.adjusted_svc_date
      ,p_base_salary
      => p_rec.base_salary
      ,p_base_salary_change_date
      => p_rec.base_salary_change_date
      ,p_payroll_name
      => p_rec.payroll_name
      ,p_performance_rating
      => p_rec.performance_rating
      ,p_performance_rating_type
      => p_rec.performance_rating_type
      ,p_performance_rating_date
      => p_rec.performance_rating_date
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_organization_id
      => p_rec.organization_id
      ,p_job_id
      => p_rec.job_id
      ,p_grade_id
      => p_rec.grade_id
      ,p_position_id
      => p_rec.position_id
      ,p_people_group_id
      => p_rec.people_group_id
      ,p_soft_coding_keyflex_id
      => p_rec.soft_coding_keyflex_id
      ,p_location_id
      => p_rec.location_id
      ,p_pay_rate_id
      => p_rec.pay_rate_id
      ,p_assignment_status_type_id
      => p_rec.assignment_status_type_id
      ,p_frequency
      => p_rec.frequency
      ,p_grade_annulization_factor
      => p_rec.grade_annulization_factor
      ,p_pay_annulization_factor
      => p_rec.pay_annulization_factor
      ,p_grd_min_val
      => p_rec.grd_min_val
      ,p_grd_max_val
      => p_rec.grd_max_val
      ,p_grd_mid_point
      => p_rec.grd_mid_point
      ,p_grd_quartile
      => p_rec.grd_quartile
      ,p_grd_comparatio
      => p_rec.grd_comparatio
      ,p_emp_category
      => p_rec.emp_category
      ,p_change_reason
      => p_rec.change_reason
      ,p_normal_hours
      => p_rec.normal_hours
      ,p_email_address
      => p_rec.email_address
      ,p_base_salary_frequency
      => p_rec.base_salary_frequency
      ,p_new_assgn_ovn
      => p_rec.new_assgn_ovn
      ,p_new_perf_event_id
      => p_rec.new_perf_event_id
      ,p_new_perf_review_id
      => p_rec.new_perf_review_id
      ,p_post_process_stat_cd
      => p_rec.post_process_stat_cd
      ,p_feedback_rating
      => p_rec.feedback_rating
      ,p_feedback_comments
      => p_rec.feedback_comments
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_custom_segment1
      => p_rec.custom_segment1
      ,p_custom_segment2
      => p_rec.custom_segment2
      ,p_custom_segment3
      => p_rec.custom_segment3
      ,p_custom_segment4
      => p_rec.custom_segment4
      ,p_custom_segment5
      => p_rec.custom_segment5
      ,p_custom_segment6
      => p_rec.custom_segment6
      ,p_custom_segment7
      => p_rec.custom_segment7
      ,p_custom_segment8
      => p_rec.custom_segment8
      ,p_custom_segment9
      => p_rec.custom_segment9
      ,p_custom_segment10
      => p_rec.custom_segment10
      ,p_custom_segment11
      => p_rec.custom_segment11
      ,p_custom_segment12
      => p_rec.custom_segment12
      ,p_custom_segment13
      => p_rec.custom_segment13
      ,p_custom_segment14
      => p_rec.custom_segment14
      ,p_custom_segment15
      => p_rec.custom_segment15
      ,p_custom_segment16
      => p_rec.custom_segment16
      ,p_custom_segment17
      => p_rec.custom_segment17
      ,p_custom_segment18
      => p_rec.custom_segment18
      ,p_custom_segment19
      => p_rec.custom_segment19
      ,p_custom_segment20
      => p_rec.custom_segment20
      ,p_people_group_name
      => p_rec.people_group_name
      ,p_people_group_segment1
      => p_rec.people_group_segment1
      ,p_people_group_segment2
      => p_rec.people_group_segment2
      ,p_people_group_segment3
      => p_rec.people_group_segment3
      ,p_people_group_segment4
      => p_rec.people_group_segment4
      ,p_people_group_segment5
      => p_rec.people_group_segment5
      ,p_people_group_segment6
      => p_rec.people_group_segment6
      ,p_people_group_segment7
      => p_rec.people_group_segment7
      ,p_people_group_segment8
      => p_rec.people_group_segment8
      ,p_people_group_segment9
      => p_rec.people_group_segment9
      ,p_people_group_segment10
      => p_rec.people_group_segment10
      ,p_people_group_segment11
      => p_rec.people_group_segment11
      ,p_ass_attribute_category
      => p_rec.ass_attribute_category
      ,p_ass_attribute1
      => p_rec.ass_attribute1
      ,p_ass_attribute2
      => p_rec.ass_attribute2
      ,p_ass_attribute3
      => p_rec.ass_attribute3
      ,p_ass_attribute4
      => p_rec.ass_attribute4
      ,p_ass_attribute5
      => p_rec.ass_attribute5
      ,p_ass_attribute6
      => p_rec.ass_attribute6
      ,p_ass_attribute7
      => p_rec.ass_attribute7
      ,p_ass_attribute8
      => p_rec.ass_attribute8
      ,p_ass_attribute9
      => p_rec.ass_attribute9
      ,p_ass_attribute10
      => p_rec.ass_attribute10
      ,p_ass_attribute11
      => p_rec.ass_attribute11
      ,p_ass_attribute12
      => p_rec.ass_attribute12
      ,p_ass_attribute13
      => p_rec.ass_attribute13
      ,p_ass_attribute14
      => p_rec.ass_attribute14
      ,p_ass_attribute15
      => p_rec.ass_attribute15
      ,p_ass_attribute16
      => p_rec.ass_attribute16
      ,p_ass_attribute17
      => p_rec.ass_attribute17
      ,p_ass_attribute18
      => p_rec.ass_attribute18
      ,p_ass_attribute19
      => p_rec.ass_attribute19
      ,p_ass_attribute20
      => p_rec.ass_attribute20
      ,p_ass_attribute21
      => p_rec.ass_attribute21
      ,p_ass_attribute22
      => p_rec.ass_attribute22
      ,p_ass_attribute23
      => p_rec.ass_attribute23
      ,p_ass_attribute24
      => p_rec.ass_attribute24
      ,p_ass_attribute25
      => p_rec.ass_attribute25
      ,p_ass_attribute26
      => p_rec.ass_attribute26
      ,p_ass_attribute27
      => p_rec.ass_attribute27
      ,p_ass_attribute28
      => p_rec.ass_attribute28
      ,p_ass_attribute29
      => p_rec.ass_attribute29
      ,p_ass_attribute30
      => p_rec.ass_attribute30
      ,p_ws_comments
      => p_rec.ws_comments
      ,p_cpi_attribute_category
      => p_rec.cpi_attribute_category
      ,p_cpi_attribute1
      => p_rec.cpi_attribute1
      ,p_cpi_attribute2
      => p_rec.cpi_attribute2
      ,p_cpi_attribute3
      => p_rec.cpi_attribute3
      ,p_cpi_attribute4
      => p_rec.cpi_attribute4
      ,p_cpi_attribute5
      => p_rec.cpi_attribute5
      ,p_cpi_attribute6
      => p_rec.cpi_attribute6
      ,p_cpi_attribute7
      => p_rec.cpi_attribute7
      ,p_cpi_attribute8
      => p_rec.cpi_attribute8
      ,p_cpi_attribute9
      => p_rec.cpi_attribute9
      ,p_cpi_attribute10
      => p_rec.cpi_attribute10
      ,p_cpi_attribute11
      => p_rec.cpi_attribute11
      ,p_cpi_attribute12
      => p_rec.cpi_attribute12
      ,p_cpi_attribute13
      => p_rec.cpi_attribute13
      ,p_cpi_attribute14
      => p_rec.cpi_attribute14
      ,p_cpi_attribute15
      => p_rec.cpi_attribute15
      ,p_cpi_attribute16
      => p_rec.cpi_attribute16
      ,p_cpi_attribute17
      => p_rec.cpi_attribute17
      ,p_cpi_attribute18
      => p_rec.cpi_attribute18
      ,p_cpi_attribute19
      => p_rec.cpi_attribute19
      ,p_cpi_attribute20
      => p_rec.cpi_attribute20
      ,p_cpi_attribute21
      => p_rec.cpi_attribute21
      ,p_cpi_attribute22
      => p_rec.cpi_attribute22
      ,p_cpi_attribute23
      => p_rec.cpi_attribute23
      ,p_cpi_attribute24
      => p_rec.cpi_attribute24
      ,p_cpi_attribute25
      => p_rec.cpi_attribute25
      ,p_cpi_attribute26
      => p_rec.cpi_attribute26
      ,p_cpi_attribute27
      => p_rec.cpi_attribute27
      ,p_cpi_attribute28
      => p_rec.cpi_attribute28
      ,p_cpi_attribute29
      => p_rec.cpi_attribute29
      ,p_cpi_attribute30
      => p_rec.cpi_attribute30
      ,p_feedback_date
      => p_rec.feedback_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PERSON_INFO'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec                          in out nocopy ben_cpi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call the supporting insert validate operations
  --
  ben_cpi_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ben_cpi_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_cpi_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_cpi_ins.post_insert
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  if g_debug then
     hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_group_per_in_ler_id            in     number
  ,p_assignment_id                  in     number   default null
  ,p_person_id                      in     number   default null
  ,p_supervisor_id                  in     number   default null
  ,p_effective_date                 in     date     default null
  ,p_full_name                      in     varchar2 default null
  ,p_brief_name                     in     varchar2 default null
  ,p_custom_name                    in     varchar2 default null
  ,p_supervisor_full_name           in     varchar2 default null
  ,p_supervisor_brief_name          in     varchar2 default null
  ,p_supervisor_custom_name         in     varchar2 default null
  ,p_legislation_code               in     varchar2 default null
  ,p_years_employed                 in     number   default null
  ,p_years_in_job                   in     number   default null
  ,p_years_in_position              in     number   default null
  ,p_years_in_grade                 in     number   default null
  ,p_employee_number                in     varchar2 default null
  ,p_start_date                     in     date     default null
  ,p_original_start_date            in     date     default null
  ,p_adjusted_svc_date              in     date     default null
  ,p_base_salary                    in     number   default null
  ,p_base_salary_change_date        in     date     default null
  ,p_payroll_name                   in     varchar2 default null
  ,p_performance_rating             in     varchar2 default null
  ,p_performance_rating_type        in     varchar2 default null
  ,p_performance_rating_date        in     date     default null
  ,p_business_group_id              in     number   default null
  ,p_organization_id                in     number   default null
  ,p_job_id                         in     number   default null
  ,p_grade_id                       in     number   default null
  ,p_position_id                    in     number   default null
  ,p_people_group_id                in     number   default null
  ,p_soft_coding_keyflex_id         in     number   default null
  ,p_location_id                    in     number   default null
  ,p_pay_rate_id                    in     number   default null
  ,p_assignment_status_type_id      in     number   default null
  ,p_frequency                      in     varchar2 default null
  ,p_grade_annulization_factor      in     number   default null
  ,p_pay_annulization_factor        in     number   default null
  ,p_grd_min_val                    in     number   default null
  ,p_grd_max_val                    in     number   default null
  ,p_grd_mid_point                  in     number   default null
  ,p_grd_quartile                   in     varchar2 default null
  ,p_grd_comparatio                 in     number   default null
  ,p_emp_category                   in     varchar2 default null
  ,p_change_reason                  in     varchar2 default null
  ,p_normal_hours                   in     number   default null
  ,p_email_address                  in     varchar2 default null
  ,p_base_salary_frequency          in     varchar2 default null
  ,p_new_assgn_ovn                  in     number   default null
  ,p_new_perf_event_id              in     number   default null
  ,p_new_perf_review_id             in     number   default null
  ,p_post_process_stat_cd           in     varchar2 default null
  ,p_feedback_rating                in     varchar2 default null
  ,p_feedback_comments              in     varchar2 default null
  ,p_custom_segment1                in     varchar2 default null
  ,p_custom_segment2                in     varchar2 default null
  ,p_custom_segment3                in     varchar2 default null
  ,p_custom_segment4                in     varchar2 default null
  ,p_custom_segment5                in     varchar2 default null
  ,p_custom_segment6                in     varchar2 default null
  ,p_custom_segment7                in     varchar2 default null
  ,p_custom_segment8                in     varchar2 default null
  ,p_custom_segment9                in     varchar2 default null
  ,p_custom_segment10               in     varchar2 default null
  ,p_custom_segment11               in     number   default null
  ,p_custom_segment12               in     number   default null
  ,p_custom_segment13               in     number   default null
  ,p_custom_segment14               in     number   default null
  ,p_custom_segment15               in     number   default null
  ,p_custom_segment16               in     number   default null
  ,p_custom_segment17               in     number   default null
  ,p_custom_segment18               in     number   default null
  ,p_custom_segment19               in     number   default null
  ,p_custom_segment20               in     number   default null
  ,p_people_group_name              in     varchar2 default null
  ,p_people_group_segment1          in     varchar2 default null
  ,p_people_group_segment2          in     varchar2 default null
  ,p_people_group_segment3          in     varchar2 default null
  ,p_people_group_segment4          in     varchar2 default null
  ,p_people_group_segment5          in     varchar2 default null
  ,p_people_group_segment6          in     varchar2 default null
  ,p_people_group_segment7          in     varchar2 default null
  ,p_people_group_segment8          in     varchar2 default null
  ,p_people_group_segment9          in     varchar2 default null
  ,p_people_group_segment10         in     varchar2 default null
  ,p_people_group_segment11         in     varchar2 default null
  ,p_ass_attribute_category         in     varchar2 default null
  ,p_ass_attribute1                 in     varchar2 default null
  ,p_ass_attribute2                 in     varchar2 default null
  ,p_ass_attribute3                 in     varchar2 default null
  ,p_ass_attribute4                 in     varchar2 default null
  ,p_ass_attribute5                 in     varchar2 default null
  ,p_ass_attribute6                 in     varchar2 default null
  ,p_ass_attribute7                 in     varchar2 default null
  ,p_ass_attribute8                 in     varchar2 default null
  ,p_ass_attribute9                 in     varchar2 default null
  ,p_ass_attribute10                in     varchar2 default null
  ,p_ass_attribute11                in     varchar2 default null
  ,p_ass_attribute12                in     varchar2 default null
  ,p_ass_attribute13                in     varchar2 default null
  ,p_ass_attribute14                in     varchar2 default null
  ,p_ass_attribute15                in     varchar2 default null
  ,p_ass_attribute16                in     varchar2 default null
  ,p_ass_attribute17                in     varchar2 default null
  ,p_ass_attribute18                in     varchar2 default null
  ,p_ass_attribute19                in     varchar2 default null
  ,p_ass_attribute20                in     varchar2 default null
  ,p_ass_attribute21                in     varchar2 default null
  ,p_ass_attribute22                in     varchar2 default null
  ,p_ass_attribute23                in     varchar2 default null
  ,p_ass_attribute24                in     varchar2 default null
  ,p_ass_attribute25                in     varchar2 default null
  ,p_ass_attribute26                in     varchar2 default null
  ,p_ass_attribute27                in     varchar2 default null
  ,p_ass_attribute28                in     varchar2 default null
  ,p_ass_attribute29                in     varchar2 default null
  ,p_ass_attribute30                in     varchar2 default null
  ,p_ws_comments                    in     varchar2 default null
  ,p_cpi_attribute_category         in     varchar2 default null
  ,p_cpi_attribute1                 in     varchar2 default null
  ,p_cpi_attribute2                 in     varchar2 default null
  ,p_cpi_attribute3                 in     varchar2 default null
  ,p_cpi_attribute4                 in     varchar2 default null
  ,p_cpi_attribute5                 in     varchar2 default null
  ,p_cpi_attribute6                 in     varchar2 default null
  ,p_cpi_attribute7                 in     varchar2 default null
  ,p_cpi_attribute8                 in     varchar2 default null
  ,p_cpi_attribute9                 in     varchar2 default null
  ,p_cpi_attribute10                in     varchar2 default null
  ,p_cpi_attribute11                in     varchar2 default null
  ,p_cpi_attribute12                in     varchar2 default null
  ,p_cpi_attribute13                in     varchar2 default null
  ,p_cpi_attribute14                in     varchar2 default null
  ,p_cpi_attribute15                in     varchar2 default null
  ,p_cpi_attribute16                in     varchar2 default null
  ,p_cpi_attribute17                in     varchar2 default null
  ,p_cpi_attribute18                in     varchar2 default null
  ,p_cpi_attribute19                in     varchar2 default null
  ,p_cpi_attribute20                in     varchar2 default null
  ,p_cpi_attribute21                in     varchar2 default null
  ,p_cpi_attribute22                in     varchar2 default null
  ,p_cpi_attribute23                in     varchar2 default null
  ,p_cpi_attribute24                in     varchar2 default null
  ,p_cpi_attribute25                in     varchar2 default null
  ,p_cpi_attribute26                in     varchar2 default null
  ,p_cpi_attribute27                in     varchar2 default null
  ,p_cpi_attribute28                in     varchar2 default null
  ,p_cpi_attribute29                in     varchar2 default null
  ,p_cpi_attribute30                in     varchar2 default null
  ,p_feedback_date                  in     date     default null
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ben_cpi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_cpi_shd.convert_args
    (p_group_per_in_ler_id
    ,p_assignment_id
    ,p_person_id
    ,p_supervisor_id
    ,p_effective_date
    ,p_full_name
    ,p_brief_name
    ,p_custom_name
    ,p_supervisor_full_name
    ,p_supervisor_brief_name
    ,p_supervisor_custom_name
    ,p_legislation_code
    ,p_years_employed
    ,p_years_in_job
    ,p_years_in_position
    ,p_years_in_grade
    ,p_employee_number
    ,p_start_date
    ,p_original_start_date
    ,p_adjusted_svc_date
    ,p_base_salary
    ,p_base_salary_change_date
    ,p_payroll_name
    ,p_performance_rating
    ,p_performance_rating_type
    ,p_performance_rating_date
    ,p_business_group_id
    ,p_organization_id
    ,p_job_id
    ,p_grade_id
    ,p_position_id
    ,p_people_group_id
    ,p_soft_coding_keyflex_id
    ,p_location_id
    ,p_pay_rate_id
    ,p_assignment_status_type_id
    ,p_frequency
    ,p_grade_annulization_factor
    ,p_pay_annulization_factor
    ,p_grd_min_val
    ,p_grd_max_val
    ,p_grd_mid_point
    ,p_grd_quartile
    ,p_grd_comparatio
    ,p_emp_category
    ,p_change_reason
    ,p_normal_hours
    ,p_email_address
    ,p_base_salary_frequency
    ,p_new_assgn_ovn
    ,p_new_perf_event_id
    ,p_new_perf_review_id
    ,p_post_process_stat_cd
    ,p_feedback_rating
    ,p_feedback_comments
    ,null
    ,p_custom_segment1
    ,p_custom_segment2
    ,p_custom_segment3
    ,p_custom_segment4
    ,p_custom_segment5
    ,p_custom_segment6
    ,p_custom_segment7
    ,p_custom_segment8
    ,p_custom_segment9
    ,p_custom_segment10
    ,p_custom_segment11
    ,p_custom_segment12
    ,p_custom_segment13
    ,p_custom_segment14
    ,p_custom_segment15
    ,p_custom_segment16
    ,p_custom_segment17
    ,p_custom_segment18
    ,p_custom_segment19
    ,p_custom_segment20
    ,p_people_group_name
    ,p_people_group_segment1
    ,p_people_group_segment2
    ,p_people_group_segment3
    ,p_people_group_segment4
    ,p_people_group_segment5
    ,p_people_group_segment6
    ,p_people_group_segment7
    ,p_people_group_segment8
    ,p_people_group_segment9
    ,p_people_group_segment10
    ,p_people_group_segment11
    ,p_ass_attribute_category
    ,p_ass_attribute1
    ,p_ass_attribute2
    ,p_ass_attribute3
    ,p_ass_attribute4
    ,p_ass_attribute5
    ,p_ass_attribute6
    ,p_ass_attribute7
    ,p_ass_attribute8
    ,p_ass_attribute9
    ,p_ass_attribute10
    ,p_ass_attribute11
    ,p_ass_attribute12
    ,p_ass_attribute13
    ,p_ass_attribute14
    ,p_ass_attribute15
    ,p_ass_attribute16
    ,p_ass_attribute17
    ,p_ass_attribute18
    ,p_ass_attribute19
    ,p_ass_attribute20
    ,p_ass_attribute21
    ,p_ass_attribute22
    ,p_ass_attribute23
    ,p_ass_attribute24
    ,p_ass_attribute25
    ,p_ass_attribute26
    ,p_ass_attribute27
    ,p_ass_attribute28
    ,p_ass_attribute29
    ,p_ass_attribute30
    ,p_ws_comments
    ,p_cpi_attribute_category
    ,p_cpi_attribute1
    ,p_cpi_attribute2
    ,p_cpi_attribute3
    ,p_cpi_attribute4
    ,p_cpi_attribute5
    ,p_cpi_attribute6
    ,p_cpi_attribute7
    ,p_cpi_attribute8
    ,p_cpi_attribute9
    ,p_cpi_attribute10
    ,p_cpi_attribute11
    ,p_cpi_attribute12
    ,p_cpi_attribute13
    ,p_cpi_attribute14
    ,p_cpi_attribute15
    ,p_cpi_attribute16
    ,p_cpi_attribute17
    ,p_cpi_attribute18
    ,p_cpi_attribute19
    ,p_cpi_attribute20
    ,p_cpi_attribute21
    ,p_cpi_attribute22
    ,p_cpi_attribute23
    ,p_cpi_attribute24
    ,p_cpi_attribute25
    ,p_cpi_attribute26
    ,p_cpi_attribute27
    ,p_cpi_attribute28
    ,p_cpi_attribute29
    ,p_cpi_attribute30
    ,p_feedback_date
    );
  --
  -- Having converted the arguments into the ben_cpi_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_cpi_ins.ins
     (l_rec
     );
  --
  p_object_version_number := l_rec.object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End ins;
--
end ben_cpi_ins;

/
