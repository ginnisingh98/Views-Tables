--------------------------------------------------------
--  DDL for Package Body PQH_STS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_STS_INS" as
/* $Header: pqstsrhi.pkb 120.0 2005/05/29 02:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_sts_ins.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_statutory_situation_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_statutory_situation_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin

 g_debug := hr_utility.debug_enabled;

   if g_debug then
   --
     hr_utility.set_location('Entering:'||l_proc, 10);
   --
   end if;
  --
  pqh_sts_ins.g_statutory_situation_id_i := p_statutory_situation_id;
  --
     if g_debug then
     --
       hr_utility.set_location(' Leaving:'||l_proc, 20);
     --
     end if;

End set_base_key_value;
--
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
  (p_rec in out nocopy pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
     if g_debug then
     --
       hr_utility.set_location('Entering:'||l_proc, 5);
     --
     End if;

  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: pqh_fr_stat_situations
  --
  insert into pqh_fr_stat_situations
      (statutory_situation_id
      ,business_group_id
      ,situation_name
      ,type_of_ps
      ,situation_type
      ,sub_type
      ,source
      ,location
      ,reason
      ,default_flag
      ,date_from
      ,date_to
      ,request_type
      ,employee_agreement_needed
      ,manager_agreement_needed
      ,print_arrette
      ,reserve_position
      ,allow_progression_flag
      ,extend_probation_period_flag
      ,remuneration_paid
      ,pay_share
      ,pay_periods
      ,frequency
      ,first_period_max_duration
      ,min_duration_per_request
      ,max_duration_per_request
      ,max_duration_whole_career
      ,renewable_allowed
      ,max_no_of_renewals
      ,max_duration_per_renewal
      ,max_tot_continuous_duration
      ,object_version_number
      ,remunerate_assign_status_id
      )
  Values
    (p_rec.statutory_situation_id
    ,p_rec.business_group_id
    ,p_rec.situation_name
    ,p_rec.type_of_ps
    ,p_rec.situation_type
    ,p_rec.sub_type
    ,p_rec.source
    ,p_rec.location
    ,p_rec.reason
    ,p_rec.is_default
    ,p_rec.date_from
    ,p_rec.date_to
    ,p_rec.request_type
    ,p_rec.employee_agreement_needed
    ,p_rec.manager_agreement_needed
    ,p_rec.print_arrette
    ,p_rec.reserve_position
    ,p_rec.allow_progressions
    ,p_rec.extend_probation_period
    ,p_rec.remuneration_paid
    ,p_rec.pay_share
    ,p_rec.pay_periods
    ,p_rec.frequency
    ,p_rec.first_period_max_duration
    ,p_rec.min_duration_per_request
    ,p_rec.max_duration_per_request
    ,p_rec.max_duration_whole_career
    ,p_rec.renewable_allowed
    ,p_rec.max_no_of_renewals
    ,p_rec.max_duration_per_renewal
    ,p_rec.max_tot_continuous_duration
    ,p_rec.object_version_number
    ,p_rec.remunerate_assign_status_id
    );
  --
  --
  --
     if g_debug then
   --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    --
    End if;

Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_sts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_sts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_sts_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec  in out nocopy pqh_sts_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select pqh_fr_stat_situations_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from pqh_fr_stat_situations
     where statutory_situation_id =
             pqh_sts_ins.g_statutory_situation_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
     if g_debug then
   --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
   End if;
  --
  If (pqh_sts_ins.g_statutory_situation_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','pqh_fr_stat_situations');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.statutory_situation_id :=
      pqh_sts_ins.g_statutory_situation_id_i;
    pqh_sts_ins.g_statutory_situation_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.statutory_situation_id;
    Close C_Sel1;
  End If;
  --
     if g_debug then
   --
     hr_utility.set_location(' Leaving:'||l_proc, 10);
     --
     End if;
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
  (p_effective_date               in date
  ,p_rec                          in pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
     if g_debug then
   --
     hr_utility.set_location('Entering:'||l_proc, 5);
   --
     end if;
  begin
    --
    pqh_sts_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_statutory_situation_id
      => p_rec.statutory_situation_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_situation_name
      => p_rec.situation_name
      ,p_type_of_ps
      => p_rec.type_of_ps
      ,p_situation_type
      => p_rec.situation_type
      ,p_sub_type
      => p_rec.sub_type
      ,p_source
      => p_rec.source
      ,p_is_default
      => p_rec.is_default
      ,p_location
      => p_rec.location
      ,p_reason
      => p_rec.reason
      ,p_date_from
      => p_rec.date_from
      ,p_date_to
      => p_rec.date_to
      ,p_request_type
      => p_rec.request_type
      ,p_employee_agreement_needed
      => p_rec.employee_agreement_needed
      ,p_manager_agreement_needed
      => p_rec.manager_agreement_needed
      ,p_print_arrette
      => p_rec.print_arrette
      ,p_reserve_position
      => p_rec.reserve_position
      ,p_allow_progressions
      => p_rec.allow_progressions
      ,p_extend_probation_period
      => p_rec.extend_probation_period
      ,p_remuneration_paid
      => p_rec.remuneration_paid
      ,p_pay_share
      => p_rec.pay_share
      ,p_pay_periods
      => p_rec.pay_periods
      ,p_frequency
      => p_rec.frequency
      ,p_first_period_max_duration
      => p_rec.first_period_max_duration
      ,p_min_duration_per_request
      => p_rec.min_duration_per_request
      ,p_max_duration_per_request
      => p_rec.max_duration_per_request
      ,p_max_duration_whole_career
      => p_rec.max_duration_whole_career
      ,p_renewable_allowed
      => p_rec.renewable_allowed
      ,p_max_no_of_renewals
      => p_rec.max_no_of_renewals
      ,p_max_duration_per_renewal
      => p_rec.max_duration_per_renewal
      ,p_max_tot_continuous_duration
      => p_rec.max_tot_continuous_duration
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_remunerate_assign_status_id
      => p_rec.remunerate_assign_status_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_STAT_SITUATIONS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
    if g_debug then
    --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    --
    End if;
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_sts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin

 g_debug := hr_utility.debug_enabled;

   if g_debug then
     --
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
   End if;
  --
  -- Call the supporting insert validate operations
  --
  pqh_sts_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pqh_sts_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pqh_sts_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pqh_sts_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
     if g_debug then
   --
     hr_utility.set_location('Leaving:'||l_proc, 20);
   --
    End if;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_business_group_id              in     number
  ,p_situation_name                 in     varchar2
  ,p_type_of_ps                     in     varchar2
  ,p_situation_type                 in     varchar2
  ,p_sub_type                       in     varchar2 default null
  ,p_source                         in     varchar2 default null
  ,p_location                       in     varchar2 default null
  ,p_reason                         in     varchar2 default null
  ,p_is_default                     in     varchar2 default null
  ,p_date_from                      in     date     default null
  ,p_date_to                        in     date     default null
  ,p_request_type                   in     varchar2 default null
  ,p_employee_agreement_needed      in     varchar2 default null
  ,p_manager_agreement_needed       in     varchar2 default null
  ,p_print_arrette                  in     varchar2 default null
  ,p_reserve_position               in     varchar2 default null
  ,p_allow_progressions             in     varchar2 default null
  ,p_extend_probation_period        in     varchar2 default null
  ,p_remuneration_paid              in     varchar2 default null
  ,p_pay_share                      in     number   default null
  ,p_pay_periods                    in     number   default null
  ,p_frequency                      in     varchar2 default null
  ,p_first_period_max_duration      in     number   default null
  ,p_min_duration_per_request       in     number   default null
  ,p_max_duration_per_request       in     number   default null
  ,p_max_duration_whole_career      in     number   default null
  ,p_renewable_allowed              in     varchar2 default null
  ,p_max_no_of_renewals             in     number   default null
  ,p_max_duration_per_renewal       in     number   default null
  ,p_max_tot_continuous_duration    in     number   default null
  ,p_remunerate_assign_status_id    in     number   default null
  ,p_statutory_situation_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   pqh_sts_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin

 g_debug := hr_utility.debug_enabled;

  if g_debug then
   --
    hr_utility.set_location('Entering:'||l_proc, 5);
   --
   End if;
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_sts_shd.convert_args
    (null
    ,p_business_group_id
    ,p_situation_name
    ,p_type_of_ps
    ,p_situation_type
    ,p_sub_type
    ,p_source
    ,p_location
    ,p_reason
    ,p_is_default
    ,trunc(p_date_from)
    ,trunc(p_date_to)
    ,p_request_type
    ,p_employee_agreement_needed
    ,p_manager_agreement_needed
    ,p_print_arrette
    ,p_reserve_position
    ,p_allow_progressions
    ,p_extend_probation_period
    ,p_remuneration_paid
    ,p_pay_share
    ,p_pay_periods
    ,p_frequency
    ,p_first_period_max_duration
    ,p_min_duration_per_request
    ,p_max_duration_per_request
    ,p_max_duration_whole_career
    ,p_renewable_allowed
    ,p_max_no_of_renewals
    ,p_max_duration_per_renewal
    ,p_max_tot_continuous_duration
    ,null
    ,p_remunerate_assign_status_id
    );
  --
  -- Having converted the arguments into the pqh_sts_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pqh_sts_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_statutory_situation_id := l_rec.statutory_situation_id;
  p_object_version_number := l_rec.object_version_number;
  --
     if g_debug then
   --
     hr_utility.set_location(' Leaving:'||l_proc, 10);
    --
    End if;
End ins;
--
end pqh_sts_ins;

/
