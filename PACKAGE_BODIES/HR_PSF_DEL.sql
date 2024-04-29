--------------------------------------------------------
--  DDL for Package Body HR_PSF_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PSF_DEL" as
/* $Header: hrpsfrhi.pkb 120.6.12010000.6 2009/11/26 10:02:00 brsinha ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'hr_psf_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_delete_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic for the datetrack
--   delete modes: ZAP, DELETE, FUTURE_CHANGE and DELETE_NEXT_CHANGE. The
--   execution is as follows:
--   1) If the delete mode is DELETE_NEXT_CHANGE then delete where the
--      effective start date is equal to the validation start date.
--   2) If the delete mode is not DELETE_NEXT_CHANGE then delete
--      all rows for the entity where the effective start date is greater
--      than or equal to the validation start date.
--   3) To raise any errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This is an internal private procedure which must be called from the
--   delete_dml procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_dml
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72);
--
Begin
if g_debug then
 l_proc   := g_package||'dt_delete_dml';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
if g_debug then
    hr_utility.set_location(l_proc, 10);
end if;
    --
    -- Delete the where the effective start date is equal
    -- to the validation end date.
    --
    delete from hr_all_positions_f
    where       position_id = p_rec.position_id
    and    effective_start_date = p_validation_start_date;
    --
  Else
if g_debug then
    hr_utility.set_location(l_proc, 15);
end if;
    --
    -- Delete the row(s) where the effective start date is greater than
    -- or equal to the validation start date.
    --
    delete from hr_all_positions_f
    where        position_id = p_rec.position_id
    and    effective_start_date >= p_validation_start_date;
    --
  End If;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end if;
--
Exception
  When Others Then
    Raise;
End dt_delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_dml
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) ;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc   := g_package||'delete_dml';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  dt_delete_dml(p_rec         => p_rec,
      p_effective_date  => p_effective_date,
      p_datetrack_mode  => p_datetrack_mode,
            p_validation_start_date => p_validation_start_date,
      p_validation_end_date   => p_validation_end_date);
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_delete process controls the execution of dml
--   for the datetrack modes: DELETE, FUTURE_CHANGE
--   and DELETE_NEXT_CHANGE only.
--
-- Prerequisites:
--   This is an internal procedure which is called from the pre_delete
--   procedure.
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
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_delete
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) ;
--
Begin
if g_debug then
  l_proc  := g_package||'dt_pre_delete';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  If (p_datetrack_mode <> 'ZAP') then
    --
    p_rec.effective_start_date := hr_psf_shd.g_old_rec.effective_start_date;
    --
    If (p_datetrack_mode = 'DELETE') then
      p_rec.effective_end_date := p_validation_start_date - 1;
    Else
      p_rec.effective_end_date := p_validation_end_date;
    End If;
    --
    -- Update the current effective end date record
    --
    hr_psf_shd.upd_effective_end_date
      (p_effective_date         => p_effective_date,
       p_base_key_value         => p_rec.position_id,
       p_new_effective_end_date => p_rec.effective_end_date,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date  => p_validation_end_date,
       p_object_version_number  => p_rec.object_version_number);
  Else
    p_rec.effective_start_date := null;
    p_rec.effective_end_date   := null;
  End If;
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End dt_pre_delete;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pre_delete_checks >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE pre_delete_checks(p_position_id        in  number
                           ,p_business_group_id  in  number
                           ,p_datetrack_mode  in  varchar2
                           ) is
 --
  l_exists                   varchar2(1);
  l_pos_structure_element_id number;
  l_sql_text                 VARCHAR2(2000);
  l_oci_out                  VARCHAR2(1);
  l_sql_cursor               NUMBER;
  l_rows_fetched             NUMBER;
  l_proc                  varchar2(72) ;

begin
if g_debug then
 l_proc                    := g_package||'pre_delete_checks';
 hr_utility.set_location('Entering : ' || l_proc, 10);
end if;
 if p_datetrack_mode = 'ZAP' then
if g_debug then
     hr_utility.set_location(l_proc, 20);
end if;
     l_exists := NULL;
--     if p_hr_ins = 'Y' then
         l_exists := NULL;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(SELECT  NULL
                      from    PER_BUDGET_ELEMENTS BE
                      where   BE.POSITION_ID = p_position_id);
         exception when no_data_found then
                       null;
         end;
         if l_exists = '1' then
           hr_utility.set_message(800,'HR_PSF_DEL_FAIL_BGT_ELE');
           hr_utility.raise_error;
         end if;
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 30);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(SELECT  NULL
                      from    PER_VACANCIES VAC
                      where   VAC.POSITION_ID = p_position_id);
         exception when no_data_found then
                       null;
         end;
         if l_exists = '1' then
           hr_utility.set_message(800,'PER_7861_DEL_POS_REC_ACT');
           hr_utility.raise_error;
         end if;
if g_debug then
         hr_utility.set_location(l_proc, 40);
end if;
/****** Commented for bug 9146790 ********
         begin
         select  e.pos_structure_element_id
         into    l_pos_structure_element_id
         from    per_pos_structure_elements e
         where   e.parent_position_id = p_position_id
         and     not exists (
                             select  null
         from    per_pos_structure_elements e2
         where   e2.subordinate_position_id = p_position_id)
         and     1 = (
                      select  count(e3.pos_structure_element_id)
                      from    per_pos_structure_elements e3
                      where   e3.parent_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
****** Commented for bug 9146790 ********/

         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 50);
end if;
         --if l_pos_structure_element_id is null then                    -- condition removed (Bug 9146790)
            begin
            select '1'
            into l_exists
            from sys.dual
            where exists(SELECT  NULL
                      FROM   PER_POS_STRUCTURE_ELEMENTS PSE
                      WHERE  PSE.PARENT_POSITION_ID      = p_position_id
                      OR     PSE.SUBORDINATE_POSITION_ID = p_position_id) ;
            exception when no_data_found then
                        null;
            end;
if g_debug then
            hr_utility.set_location(l_proc, 60);
end if;
            if l_exists = '1' then
               hr_utility.set_message(800,'PER_7416_POS_IN_POS_HIER');
               hr_utility.raise_error;
            end if;
        -- end if;							-- Bug 9146790
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 70);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(SELECT  NULL
                      FROM PER_VALID_GRADES VG1
                      WHERE business_group_id + 0 = p_business_group_id
                      AND VG1.POSITION_ID = p_position_id);
         exception when no_data_found then
                        null;
         end;
if g_debug then
         hr_utility.set_location(l_proc, 80);
end if;
         if l_exists = '1' then
               hr_utility.set_message(801,'PER_7865_DEF_POS_DEL_GRADE');
               hr_utility.raise_error;
         end if;
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 90);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_job_requirements jre1
                      where jre1.position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7866_DEF_POS_DEL_REQ');
             hr_utility.raise_error;
         end if;
         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 100);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_job_evaluations jev1
                      where jev1.position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;
         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7867_DEF_POS_DEL_EVAL');
             hr_utility.raise_error;
         end if;

         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 110);
end if;
         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from hr_all_positions_f
                      where successor_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7996_POS_SUCCESSOR_REF');
             hr_utility.raise_error;
         end if;

         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 120);
end if;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from hr_All_positions_f
                      where relief_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
             hr_utility.set_message(801,'PER_7997_POS_RELIEF_REF');
             hr_utility.raise_error;
         end if;

         l_exists := NULL;
if g_debug then
         hr_utility.set_location(l_proc, 130);
end if;

         begin
         select '1'
         into l_exists
         from sys.dual
         where exists(select  null
                      from per_mm_positions
                      where new_position_id = p_position_id);
         exception when no_data_found then
                        null;
         end;

         if l_exists = '1' then
             hr_utility.set_message(800,'HR_52776_NOT_DEL_MM_POSITIONS');
             hr_utility.raise_error;
         end if;
if g_debug then
         hr_utility.set_location(l_proc, 140);
end if;

--     end if;
    -- fix for bug 8439584
    --
    -- is po installed?
    --
--    if p_po_ins = 'Y' then
      begin
        l_sql_text := 'select null '
           ||' from sys.dual '
           ||' where exists( select null '
           ||'    from   po_system_parameters '
           ||'    where  security_position_structure_id = '
           ||to_char(p_position_id)
           ||' ) '
           ||' or exists( select null '
           ||'    from   po_employee_hierarchies '
           ||'    where  employee_position_id = '
           ||to_char(p_position_id)
           ||' or    superior_position_id = '
           ||to_char(p_position_id)
           ||' ) '
	   ||' or exists( select null '
           ||'    from   PO_POSITION_CONTROLS_ALL '
           ||'    where  position_id = '
           ||to_char(p_position_id)
           ||' )' ;
      --
      -- Open Cursor for Processing Sql statment.
      --
      -- fix for bug 8439584
if g_debug then
      hr_utility.set_location(l_proc, 150);
end if;
      l_sql_cursor := dbms_sql.open_cursor;
      --
      -- Parse SQL statement.
      --
      dbms_sql.parse(l_sql_cursor, l_sql_text, dbms_sql.v7);
      --
      -- Map the local variables to each returned Column
      --
if g_debug then
      hr_utility.set_location(l_proc, 160);
end if;
      dbms_sql.define_column(l_sql_cursor, 1,l_oci_out,1);
      --
      -- Execute the SQL statement.
      --
if g_debug then
      hr_utility.set_location(l_proc, 170);
end if;
      l_rows_fetched := dbms_sql.execute(l_sql_cursor);
      --
      if (dbms_sql.fetch_rows(l_sql_cursor) > 0)
      then
         hr_utility.set_message(800,'HR_6048_PO_POS_DEL_POS_CONT');
         hr_utility.raise_error;
      end if;
      --
      -- Close cursor used for processing SQL statement.
      --
      dbms_sql.close_cursor(l_sql_cursor);
if g_debug then
      hr_utility.set_location(l_proc, 180);
end if;
      end;
--    end if;
    --
    --  Ref Int check for OTA.
    --
    per_ota_predel_validation.ota_predel_pos_validation(p_position_id);
if g_debug then
    hr_utility.set_location('Leaving : ' || l_proc, 300);
end if;
    --
  end if;
end pre_delete_checks;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_delete_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete
   (p_rec          in out nocopy hr_psf_shd.g_rec_type,
    p_effective_date  in   date,
    p_datetrack_mode  in   varchar2,
    p_validation_start_date in   date,
    p_validation_end_date   in   date) is
--
  l_proc varchar2(72) ;
--
cursor vgr is
select valid_grade_id, object_version_number from per_valid_grades
where position_id = p_rec.position_id;
Begin
if g_debug then
 l_proc   := g_package||'pre_delete';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  -- pre delete checks
  pre_delete_checks(p_position_id       => p_rec.position_id
                   ,p_business_group_id => p_rec.business_group_id
                   ,p_datetrack_mode    => p_datetrack_mode);
/*
  --
  -- Delete record from PER_POSITION_LIST
  --
  if (p_datetrack_mode = 'ZAP') then
    open c1;
    fetch c1 into l_view_all_positions_flag;
    close c1;
    --
    if l_view_all_positions_flag <> 'Y' then
      Delete from PER_POSITION_LIST
      WHERE  position_id = p_rec.Position_id;
    end if;
  end if;
  */
  --
  --  Delete from per_valid_grades rows corresponding to the position being deleted.
  --
if (p_datetrack_mode = 'ZAP') then
   for each_rec in vgr loop
      per_vgr_del.del(p_valid_grade_id => each_rec.valid_grade_id,
            p_object_version_number => each_rec.object_version_number);
   end loop;
end if;
    --
    dt_pre_delete
    (p_rec                => p_rec,
     p_effective_date        => p_effective_date,
     p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
    --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled
--
-- Developer Implementation Notes:
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete
   (p_rec          in hr_psf_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72) ;
--
Begin
if g_debug then
l_proc    := g_package||'post_delete';
--
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- User Hook
  --
  Begin
  hr_psf_rkd.after_delete(
  p_position_id                  => p_rec.position_id    ,
  p_effective_date       => p_effective_date ,
  p_effective_start_date_o       => hr_psf_shd.g_old_rec.effective_start_date      ,
  p_effective_end_date_o         => hr_psf_shd.g_old_rec.effective_end_date        ,
  p_availability_status_id_o     => hr_psf_shd.g_old_rec.availability_status_id    ,
  p_business_group_id_o          => hr_psf_shd.g_old_rec.business_group_id         ,
  p_entry_step_id_o              => hr_psf_shd.g_old_rec.entry_step_id             ,
  p_entry_grade_rule_id_o        => hr_psf_shd.g_old_rec.entry_grade_rule_id       ,
  p_job_id_o                     => hr_psf_shd.g_old_rec.job_id                    ,
  p_location_id_o                => hr_psf_shd.g_old_rec.location_id               ,
  p_organization_id_o            => hr_psf_shd.g_old_rec.organization_id           ,
  p_pay_freq_payroll_id_o        => hr_psf_shd.g_old_rec.pay_freq_payroll_id       ,
  p_position_definition_id_o     => hr_psf_shd.g_old_rec.position_definition_id    ,
  p_position_transaction_id_o    => hr_psf_shd.g_old_rec.position_transaction_id   ,
  p_prior_position_id_o          => hr_psf_shd.g_old_rec.prior_position_id         ,
  p_relief_position_id_o         => hr_psf_shd.g_old_rec.relief_position_id        ,
  p_entry_grade_id_o             => hr_psf_shd.g_old_rec.entry_grade_id            ,
  p_successor_position_id_o      => hr_psf_shd.g_old_rec.successor_position_id     ,
  p_supervisor_position_id_o     => hr_psf_shd.g_old_rec.supervisor_position_id    ,
  p_amendment_date_o             => hr_psf_shd.g_old_rec.amendment_date            ,
  p_amendment_recommendation_o   => hr_psf_shd.g_old_rec.amendment_recommendation  ,
  p_amendment_ref_number_o       => hr_psf_shd.g_old_rec.amendment_ref_number      ,
  p_bargaining_unit_cd_o         => hr_psf_shd.g_old_rec.bargaining_unit_cd        ,
  p_comments_o                   => hr_psf_shd.g_old_rec.comments                  ,
  p_current_job_prop_end_date_o  => hr_psf_shd.g_old_rec.current_job_prop_end_date ,
  p_current_org_prop_end_date_o  => hr_psf_shd.g_old_rec.current_org_prop_end_date ,
  p_avail_status_prop_end_date_o => hr_psf_shd.g_old_rec.avail_status_prop_end_date,
  p_date_effective_o             => hr_psf_shd.g_old_rec.date_effective            ,
  p_date_end_o                   => hr_psf_shd.g_old_rec.date_end                  ,
  p_earliest_hire_date_o         => hr_psf_shd.g_old_rec.earliest_hire_date        ,
  p_fill_by_date_o               => hr_psf_shd.g_old_rec.fill_by_date              ,
  p_frequency_o                  => hr_psf_shd.g_old_rec.frequency                 ,
  p_fte_o                        => hr_psf_shd.g_old_rec.fte                       ,
  p_max_persons_o                => hr_psf_shd.g_old_rec.max_persons               ,
  p_name_o                       => hr_psf_shd.g_old_rec.name                      ,
  p_overlap_period_o             => hr_psf_shd.g_old_rec.overlap_period            ,
  p_overlap_unit_cd_o            => hr_psf_shd.g_old_rec.overlap_unit_cd           ,
  p_pay_term_end_day_cd_o        => hr_psf_shd.g_old_rec.pay_term_end_day_cd       ,
  p_pay_term_end_month_cd_o      => hr_psf_shd.g_old_rec.pay_term_end_month_cd     ,
  p_permanent_temporary_flag_o   => hr_psf_shd.g_old_rec.permanent_temporary_flag  ,
  p_permit_recruitment_flag_o    => hr_psf_shd.g_old_rec.permit_recruitment_flag   ,
  p_position_type_o              => hr_psf_shd.g_old_rec.position_type             ,
  p_posting_description_o        => hr_psf_shd.g_old_rec.posting_description       ,
  p_probation_period_o           => hr_psf_shd.g_old_rec.probation_period          ,
  p_probation_period_unit_cd_o   => hr_psf_shd.g_old_rec.probation_period_unit_cd  ,
  p_replacement_required_flag_o  => hr_psf_shd.g_old_rec.replacement_required_flag ,
  p_review_flag_o                => hr_psf_shd.g_old_rec.review_flag               ,
  p_seasonal_flag_o              => hr_psf_shd.g_old_rec.seasonal_flag             ,
  p_security_requirements_o      => hr_psf_shd.g_old_rec.security_requirements     ,
  p_status_o                     => hr_psf_shd.g_old_rec.status                    ,
  p_term_start_day_cd_o          => hr_psf_shd.g_old_rec.term_start_day_cd         ,
  p_term_start_month_cd_o        => hr_psf_shd.g_old_rec.term_start_month_cd       ,
  p_time_normal_finish_o         => hr_psf_shd.g_old_rec.time_normal_finish        ,
  p_time_normal_start_o          => hr_psf_shd.g_old_rec.time_normal_start         ,
  p_update_source_cd_o           => hr_psf_shd.g_old_rec.update_source_cd          ,
  p_working_hours_o              => hr_psf_shd.g_old_rec.working_hours             ,
  p_works_council_approval_fla_o => hr_psf_shd.g_old_rec.works_council_approval_flag,
  p_work_period_type_cd_o        => hr_psf_shd.g_old_rec.work_period_type_cd       ,
  p_work_term_end_day_cd_o       => hr_psf_shd.g_old_rec.work_term_end_day_cd      ,
  p_work_term_end_month_cd_o     => hr_psf_shd.g_old_rec.work_term_end_month_cd    ,
  p_proposed_fte_for_layoff_o    => hr_psf_shd.g_old_rec.proposed_fte_for_layoff   ,
  p_proposed_date_for_layoff_o   => hr_psf_shd.g_old_rec.proposed_date_for_layoff  ,
  p_pay_basis_id_o               => hr_psf_shd.g_old_rec.pay_basis_id              ,
  p_supervisor_id_o              => hr_psf_shd.g_old_rec.supervisor_id             ,
  p_copied_to_old_table_flag_o   => hr_psf_shd.g_old_rec.copied_to_old_table_flag  ,
  p_information1_o               => hr_psf_shd.g_old_rec.information1              ,
  p_information2_o               => hr_psf_shd.g_old_rec.information2              ,
  p_information3_o               => hr_psf_shd.g_old_rec.information3              ,
  p_information4_o               => hr_psf_shd.g_old_rec.information4              ,
  p_information5_o               => hr_psf_shd.g_old_rec.information5              ,
  p_information6_o               => hr_psf_shd.g_old_rec.information6              ,
  p_information7_o               => hr_psf_shd.g_old_rec.information7              ,
  p_information8_o               => hr_psf_shd.g_old_rec.information8              ,
  p_information9_o               => hr_psf_shd.g_old_rec.information9              ,
  p_information10_o              => hr_psf_shd.g_old_rec.information10             ,
  p_information11_o              => hr_psf_shd.g_old_rec.information11             ,
  p_information12_o              => hr_psf_shd.g_old_rec.information12             ,
  p_information13_o              => hr_psf_shd.g_old_rec.information13             ,
  p_information14_o              => hr_psf_shd.g_old_rec.information14             ,
  p_information15_o              => hr_psf_shd.g_old_rec.information15             ,
  p_information16_o              => hr_psf_shd.g_old_rec.information16             ,
  p_information17_o              => hr_psf_shd.g_old_rec.information17             ,
  p_information18_o              => hr_psf_shd.g_old_rec.information18             ,
  p_information19_o              => hr_psf_shd.g_old_rec.information19             ,
  p_information20_o              => hr_psf_shd.g_old_rec.information20             ,
  p_information21_o              => hr_psf_shd.g_old_rec.information21             ,
  p_information22_o              => hr_psf_shd.g_old_rec.information22             ,
  p_information23_o              => hr_psf_shd.g_old_rec.information23             ,
  p_information24_o              => hr_psf_shd.g_old_rec.information24             ,
  p_information25_o              => hr_psf_shd.g_old_rec.information25             ,
  p_information26_o              => hr_psf_shd.g_old_rec.information26             ,
  p_information27_o              => hr_psf_shd.g_old_rec.information27             ,
  p_information28_o              => hr_psf_shd.g_old_rec.information28             ,
  p_information29_o              => hr_psf_shd.g_old_rec.information29             ,
  p_information30_o              => hr_psf_shd.g_old_rec.information30             ,
  p_information_category_o       => hr_psf_shd.g_old_rec.information_category      ,
  p_attribute1_o                 => hr_psf_shd.g_old_rec.attribute1                ,
  p_attribute2_o                 => hr_psf_shd.g_old_rec.attribute2                ,
  p_attribute3_o                 => hr_psf_shd.g_old_rec.attribute3                ,
  p_attribute4_o                 => hr_psf_shd.g_old_rec.attribute4                ,
  p_attribute5_o                 => hr_psf_shd.g_old_rec.attribute5                ,
  p_attribute6_o                 => hr_psf_shd.g_old_rec.attribute6                ,
  p_attribute7_o                 => hr_psf_shd.g_old_rec.attribute7                ,
  p_attribute8_o                 => hr_psf_shd.g_old_rec.attribute8                ,
  p_attribute9_o                 => hr_psf_shd.g_old_rec.attribute9                ,
  p_attribute10_o                => hr_psf_shd.g_old_rec.attribute10               ,
  p_attribute11_o                => hr_psf_shd.g_old_rec.attribute11               ,
  p_attribute12_o                => hr_psf_shd.g_old_rec.attribute12               ,
  p_attribute13_o                => hr_psf_shd.g_old_rec.attribute13               ,
  p_attribute14_o                => hr_psf_shd.g_old_rec.attribute14               ,
  p_attribute15_o                => hr_psf_shd.g_old_rec.attribute15               ,
  p_attribute16_o                => hr_psf_shd.g_old_rec.attribute16               ,
  p_attribute17_o                => hr_psf_shd.g_old_rec.attribute17               ,
  p_attribute18_o                => hr_psf_shd.g_old_rec.attribute18               ,
  p_attribute19_o                => hr_psf_shd.g_old_rec.attribute19               ,
  p_attribute20_o                => hr_psf_shd.g_old_rec.attribute20               ,
  p_attribute21_o                => hr_psf_shd.g_old_rec.attribute21               ,
  p_attribute22_o                => hr_psf_shd.g_old_rec.attribute22               ,
  p_attribute23_o                => hr_psf_shd.g_old_rec.attribute23               ,
  p_attribute24_o                => hr_psf_shd.g_old_rec.attribute24               ,
  p_attribute25_o                => hr_psf_shd.g_old_rec.attribute25               ,
  p_attribute26_o                => hr_psf_shd.g_old_rec.attribute26               ,
  p_attribute27_o                => hr_psf_shd.g_old_rec.attribute27               ,
  p_attribute28_o                => hr_psf_shd.g_old_rec.attribute28               ,
  p_attribute29_o                => hr_psf_shd.g_old_rec.attribute29               ,
  p_attribute30_o                => hr_psf_shd.g_old_rec.attribute30               ,
  p_attribute_category_o         => hr_psf_shd.g_old_rec.attribute_category        ,
  p_request_id_o                 => hr_psf_shd.g_old_rec.request_id                ,
  p_program_application_id_o     => hr_psf_shd.g_old_rec.program_application_id    ,
  p_program_id_o                 => hr_psf_shd.g_old_rec.program_id                ,
  p_program_update_date_o        => hr_psf_shd.g_old_rec.program_update_date       ,
  p_object_version_number_o      => hr_psf_shd.g_old_rec.object_version_number     );
  --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_ALL_POSITIONS'
        ,p_hook_type   => 'AD'
        );
  end;
  --
  hr_psf_shd.position_wf_sync(p_rec.position_id , p_validation_start_date);
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec        in out nocopy  hr_psf_shd.g_rec_type,
  p_effective_date   in    date,
  p_datetrack_mode   in    varchar2,
  p_validate            in      boolean default false
  ) is
--
  l_proc       varchar2(72) ;
  l_validation_start_date  date;
  l_validation_end_date    date;
--
  cursor c1 is
  select availability_status_id
  from hr_all_positions_f
  where position_id = p_rec.position_id;
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc         := g_package||'del';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- Ensure that the DateTrack delete mode is valid
  --
  dt_api.validate_dt_del_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to delete.
  --
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_per_per;
  End If;
  --
  hr_psf_shd.lck
   (p_effective_date  => p_effective_date,
          p_datetrack_mode  => p_datetrack_mode,
          p_position_id  => p_rec.position_id,
          p_object_version_number => p_rec.object_version_number,
          p_validation_start_date => l_validation_start_date,
          p_validation_end_date   => l_validation_end_date);
  --
  -- get availability_status
  --
  if p_rec.availability_status_id is null then
    open c1;
    fetch c1 into p_rec.availability_status_id;
    close c1;
  end if;
  --
  -- Call the supporting delete validate operation
  --
  hr_psf_bus.delete_validate
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Delete the row.
  --
  delete_dml
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- Call the supporting post-delete operation
  --
  post_delete
   (p_rec          => p_rec,
    p_effective_date  => p_effective_date,
    p_datetrack_mode  => p_datetrack_mode,
    p_validation_start_date => l_validation_start_date,
    p_validation_end_date   => l_validation_end_date);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;

Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_per_per;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_position_id     in   number,
  p_effective_start_date     out nocopy date,
  p_effective_end_date       out nocopy date,
  p_object_version_number in out nocopy number,
  p_effective_date     in     date,
  p_datetrack_mode     in     varchar2,
  p_validate              in     boolean default false,
  p_security_profile_id in number default hr_security.get_security_profile
  ) is
--
  l_rec     hr_psf_shd.g_rec_type;
  l_proc varchar2(72);
--
Begin
g_debug := hr_utility.debug_enabled;
if g_debug then
 l_proc   := g_package||'del';
  hr_utility.set_location('Entering:'||l_proc, 5);
end if;
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.position_id     := p_position_id;
  l_rec.object_version_number    := p_object_version_number;
  l_rec.security_profile_id   := p_security_profile_id;

  --
  -- Having converted the arguments into the psf_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_effective_date, p_datetrack_mode, p_validate);
  --
  -- Set the out arguments
  --
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date  := l_rec.effective_start_date;
  p_effective_end_date    := l_rec.effective_end_date;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end if;
End del;

end hr_psf_del;

/
