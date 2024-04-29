--------------------------------------------------------
--  DDL for Package Body PER_PYP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PYP_INS" as
/* $Header: pepyprhi.pkb 120.17.12010000.7 2009/06/11 05:33:59 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)        := '  per_pyp_ins.';  -- Global package name
--
-- the following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_pay_proposal_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_pay_proposal_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
begin
  hr_utility.set_location('entering:'||l_proc, 10);
  --
  per_pyp_ins.g_pay_proposal_id_i := p_pay_proposal_id;
  --
  hr_utility.set_location(' leaving:'||l_proc, 20);
end set_base_key_value;
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy per_pyp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_pyp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_pay_proposals
  --
  insert into per_pay_proposals
  (     pay_proposal_id,
        assignment_id,
        event_id,
        business_group_id,
        change_date,
        comments,
        last_change_date,
        next_perf_review_date,
        next_sal_review_date,
        performance_rating,
        proposal_reason,
        proposed_salary_n,
        review_date,
        forced_ranking,
  date_to,
        performance_review_id,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        object_version_number,
        multiple_components,
        approved
  )
  Values
  (     p_rec.pay_proposal_id,
        p_rec.assignment_id,
        null,
        p_rec.business_group_id,
        p_rec.change_date,
        p_rec.comments,
        p_rec.last_change_date,
        null,
        p_rec.next_sal_review_date,
        null,
        p_rec.proposal_reason,
        p_rec.proposed_salary_n,
        null,
        p_rec.forced_ranking,
  p_rec.date_to,
        p_rec.performance_review_id,
  p_rec.attribute_category,
  p_rec.attribute1,
  p_rec.attribute2,
  p_rec.attribute3,
  p_rec.attribute4,
  p_rec.attribute5,
  p_rec.attribute6,
  p_rec.attribute7,
  p_rec.attribute8,
  p_rec.attribute9,
  p_rec.attribute10,
  p_rec.attribute11,
  p_rec.attribute12,
  p_rec.attribute13,
  p_rec.attribute14,
  p_rec.attribute15,
  p_rec.attribute16,
  p_rec.attribute17,
  p_rec.attribute18,
  p_rec.attribute19,
  p_rec.attribute20,
  p_rec.object_version_number,
  p_rec.multiple_components,
  p_rec.approved
  );
  --
  per_pyp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_pyp_shd.g_api_dml := false;   -- Unset the api dml status
    per_pyp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_pyp_shd.g_api_dml := false;   -- Unset the api dml status
    per_pyp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_pyp_shd.g_api_dml := false;   -- Unset the api dml status
    per_pyp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_pyp_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy per_pyp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_pay_proposals_s.nextval from sys.dual;
--
--
  cursor c_sel2 is
    select null
      from per_pay_proposals
     where pay_proposal_id =
             per_pyp_ins.g_pay_proposal_id_i;
--
l_exists varchar2(1);
--
Begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  if (per_pyp_ins.g_pay_proposal_id_i is not null) then
    --
    -- verify registered primary key values not already in use
    --
    open c_sel2;
    fetch c_sel2 into l_exists;
    if c_sel2%found then
       close c_sel2;
       --
       -- the primary key values are already in use.
       --
       fnd_message.set_name('per','per_289391_key_already_used');
       fnd_message.set_token('table_name','per_pay_proposals');
       fnd_message.raise_error;
    end if;
    close c_sel2;
    --
    -- use registered key values and clear globals
    --
    p_rec.pay_proposal_id := per_pyp_ins.g_pay_proposal_id_i;
    --
    per_pyp_ins.g_pay_proposal_id_i := null;
  else
    --
    -- no registerd key values, so select the next sequence number
    --
    --
    -- select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.pay_proposal_id;
    Close C_Sel1;
  end if;
  --
  -- Added by ggnanagu
  -- To fix last_change_date being null issue
  --
  per_pyp_bus.gen_last_change_date(p_rec);
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec        in per_pyp_shd.g_rec_type,
   p_inv_next_sal_date_warning    in boolean,
   p_proposed_salary_warning  in boolean,
   p_approved_warning             in boolean,
   p_payroll_warning    in boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
  --
  l_old_rec   ben_pro_ler.g_pro_ler_rec ;
  l_new_rec   ben_pro_ler.g_pro_ler_rec ;
--
  -- extract change events
  l_ext_old_rec  ben_ext_chlg.g_per_pay_rec_type;
  l_ext_new_rec  ben_ext_chlg.g_per_pay_rec_type;
  l_event       varchar2(20) ;
  --

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call to user hook for post_insert.
  --
  begin
  --
     -- Bug 5203589 - Set old values of PER_PAY_PROPOSAL record
     --
     l_old_rec.BUSINESS_GROUP_ID     := per_pyp_shd.g_old_rec.BUSINESS_GROUP_ID;
     l_old_rec.PAY_PROPOSAL_ID       := per_pyp_shd.g_old_rec.PAY_PROPOSAL_ID;
     l_old_rec.ASSIGNMENT_ID         := per_pyp_shd.g_old_rec.ASSIGNMENT_ID;
     l_old_rec.EVENT_ID              := null; -- 9999 per_pyp_shd.g_old_rec.EVENT_ID;
     l_old_rec.CHANGE_DATE           := per_pyp_shd.g_old_rec.CHANGE_DATE;
     l_old_rec.LAST_CHANGE_DATE      := per_pyp_shd.g_old_rec.LAST_CHANGE_DATE;
     l_old_rec.NEXT_PERF_REVIEW_DATE := null; -- 9999 per_pyp_shd.g_old_rec.NEXT_PERF_REVIEW_DATE;
     l_old_rec.NEXT_SAL_REVIEW_DATE  := per_pyp_shd.g_old_rec.NEXT_SAL_REVIEW_DATE;
     l_old_rec.PERFORMANCE_RATING    := null; -- 9999 per_pyp_shd.g_old_rec.PERFORMANCE_RATING;
     l_old_rec.PROPOSAL_REASON       := per_pyp_shd.g_old_rec.PROPOSAL_REASON;
     l_old_rec.PROPOSED_SALARY_N     := per_pyp_shd.g_old_rec.PROPOSED_SALARY_N;
     l_old_rec.REVIEW_DATE           := null; -- 9999 per_pyp_shd.g_old_rec.REVIEW_DATE;
     l_old_rec.APPROVED              := per_pyp_shd.g_old_rec.APPROVED;
     l_old_rec.MULTIPLE_COMPONENTS   := per_pyp_shd.g_old_rec.MULTIPLE_COMPONENTS;
     l_old_rec.FORCED_RANKING        := per_pyp_shd.g_old_rec.FORCED_RANKING;
     l_old_rec.DATE_TO         := per_pyp_shd.g_old_rec.DATE_TO;
     l_old_rec.PERFORMANCE_REVIEW_ID := per_pyp_shd.g_old_rec.PERFORMANCE_REVIEW_ID;
     l_old_rec.ATTRIBUTE1            := per_pyp_shd.g_old_rec.ATTRIBUTE1;
     l_old_rec.ATTRIBUTE2            := per_pyp_shd.g_old_rec.ATTRIBUTE2;
     l_old_rec.ATTRIBUTE3            := per_pyp_shd.g_old_rec.ATTRIBUTE3;
     l_old_rec.ATTRIBUTE4            := per_pyp_shd.g_old_rec.ATTRIBUTE4;
     l_old_rec.ATTRIBUTE5            := per_pyp_shd.g_old_rec.ATTRIBUTE5;
     l_old_rec.ATTRIBUTE6            := per_pyp_shd.g_old_rec.ATTRIBUTE6;
     l_old_rec.ATTRIBUTE7            := per_pyp_shd.g_old_rec.ATTRIBUTE7;
     l_old_rec.ATTRIBUTE8            := per_pyp_shd.g_old_rec.ATTRIBUTE8;
     l_old_rec.ATTRIBUTE9            := per_pyp_shd.g_old_rec.ATTRIBUTE9;
     l_old_rec.ATTRIBUTE10           := per_pyp_shd.g_old_rec.ATTRIBUTE10;
     l_old_rec.ATTRIBUTE11           := per_pyp_shd.g_old_rec.ATTRIBUTE11;
     l_old_rec.ATTRIBUTE12           := per_pyp_shd.g_old_rec.ATTRIBUTE12;
     l_old_rec.ATTRIBUTE13           := per_pyp_shd.g_old_rec.ATTRIBUTE13;
     l_old_rec.ATTRIBUTE14           := per_pyp_shd.g_old_rec.ATTRIBUTE14;
     l_old_rec.ATTRIBUTE15           := per_pyp_shd.g_old_rec.ATTRIBUTE15;
     l_old_rec.ATTRIBUTE16           := per_pyp_shd.g_old_rec.ATTRIBUTE16;
     l_old_rec.ATTRIBUTE17           := per_pyp_shd.g_old_rec.ATTRIBUTE17;
     l_old_rec.ATTRIBUTE18           := per_pyp_shd.g_old_rec.ATTRIBUTE18;
     l_old_rec.ATTRIBUTE19           := per_pyp_shd.g_old_rec.ATTRIBUTE19;
     l_old_rec.ATTRIBUTE20           := per_pyp_shd.g_old_rec.ATTRIBUTE20;
     l_old_rec.PROPOSED_SALARY       := null; -- 9999 ben_pro_shd.g_old_rec.PROPOSED_SALARY;

     --
     -- OAB Bug 1863413 : Detect potential life events when salary
     -- information  changes
     --
     -- intialising variable for calling ler_check
     l_new_rec.BUSINESS_GROUP_ID     := p_rec.BUSINESS_GROUP_ID;
     l_new_rec.PAY_PROPOSAL_ID       := p_rec.PAY_PROPOSAL_ID;
     l_new_rec.ASSIGNMENT_ID         := p_rec.ASSIGNMENT_ID;
     l_new_rec.EVENT_ID              := null; -- 9999 p_rec.EVENT_ID;
     l_new_rec.CHANGE_DATE           := p_rec.CHANGE_DATE;
     l_new_rec.LAST_CHANGE_DATE      := p_rec.LAST_CHANGE_DATE;
     l_new_rec.NEXT_PERF_REVIEW_DATE := null; -- 9999 p_rec.NEXT_PERF_REVIEW_DATE;
     l_new_rec.NEXT_SAL_REVIEW_DATE  := null; -- 9999 p_rec.NEXT_SAL_REVIEW_DATE;
     l_new_rec.PERFORMANCE_RATING    := null; -- 9999 p_rec.PERFORMANCE_RATING;
     l_new_rec.PROPOSAL_REASON       := p_rec.PROPOSAL_REASON;
     l_new_rec.PROPOSED_SALARY_N     := p_rec.PROPOSED_SALARY_N;
     l_new_rec.REVIEW_DATE           := null; -- 9999 p_rec.REVIEW_DATE;
     l_new_rec.APPROVED              := p_rec.APPROVED;
     l_new_rec.MULTIPLE_COMPONENTS   := p_rec.MULTIPLE_COMPONENTS;
     l_new_rec.FORCED_RANKING        := p_rec.FORCED_RANKING;
     l_new_rec.DATE_TO         := p_rec.DATE_TO;
     l_new_rec.PERFORMANCE_REVIEW_ID := p_rec.PERFORMANCE_REVIEW_ID;
     l_new_rec.ATTRIBUTE1            := p_rec.ATTRIBUTE1;
     l_new_rec.ATTRIBUTE2            := p_rec.ATTRIBUTE2;
     l_new_rec.ATTRIBUTE3            := p_rec.ATTRIBUTE3;
     l_new_rec.ATTRIBUTE4            := p_rec.ATTRIBUTE4;
     l_new_rec.ATTRIBUTE5            := p_rec.ATTRIBUTE5;
     l_new_rec.ATTRIBUTE6            := p_rec.ATTRIBUTE6;
     l_new_rec.ATTRIBUTE7            := p_rec.ATTRIBUTE7;
     l_new_rec.ATTRIBUTE8            := p_rec.ATTRIBUTE8;
     l_new_rec.ATTRIBUTE9            := p_rec.ATTRIBUTE9;
     l_new_rec.ATTRIBUTE10           := p_rec.ATTRIBUTE10;
     l_new_rec.ATTRIBUTE11           := p_rec.ATTRIBUTE11;
     l_new_rec.ATTRIBUTE12           := p_rec.ATTRIBUTE12;
     l_new_rec.ATTRIBUTE13           := p_rec.ATTRIBUTE13;
     l_new_rec.ATTRIBUTE14           := p_rec.ATTRIBUTE14;
     l_new_rec.ATTRIBUTE15           := p_rec.ATTRIBUTE15;
     l_new_rec.ATTRIBUTE16           := p_rec.ATTRIBUTE16;
     l_new_rec.ATTRIBUTE17           := p_rec.ATTRIBUTE17;
     l_new_rec.ATTRIBUTE18           := p_rec.ATTRIBUTE18;
     l_new_rec.ATTRIBUTE19           := p_rec.ATTRIBUTE19;
     l_new_rec.ATTRIBUTE20           := p_rec.ATTRIBUTE20;
     l_new_rec.PROPOSED_SALARY       := null; -- 9999 p_rec.PROPOSED_SALARY;
     --
     -- extract change events
     l_ext_new_rec.BUSINESS_GROUP_ID     := p_rec.BUSINESS_GROUP_ID;
     l_ext_new_rec.PAY_PROPOSAL_ID       := p_rec.PAY_PROPOSAL_ID;
     l_ext_new_rec.ASSIGNMENT_ID         := p_rec.ASSIGNMENT_ID;
     --l_ext_new_rec.EVENT_ID              := p_rec.EVENT_ID;
     l_ext_new_rec.CHANGE_DATE           := p_rec.CHANGE_DATE;
     l_ext_new_rec.LAST_CHANGE_DATE      := p_rec.LAST_CHANGE_DATE;
     --l_ext_new_rec.NEXT_PERF_REVIEW_DATE := p_rec.NEXT_PERF_REVIEW_DATE;
     l_ext_new_rec.NEXT_SAL_REVIEW_DATE  := p_rec.NEXT_SAL_REVIEW_DATE;
     -- l_ext_new_rec.PERFORMANCE_RATING    := p_rec.PERFORMANCE_RATING;
     l_ext_new_rec.PROPOSAL_REASON       := p_rec.PROPOSAL_REASON;
     l_ext_new_rec.PROPOSED_SALARY_N     := p_rec.PROPOSED_SALARY_N;
     -- l_ext_new_rec.REVIEW_DATE           := p_rec.REVIEW_DATE;
     l_ext_new_rec.APPROVED              := p_rec.APPROVED;
     l_ext_new_rec.MULTIPLE_COMPONENTS   := p_rec.MULTIPLE_COMPONENTS;
     l_ext_new_rec.FORCED_RANKING        := p_rec.FORCED_RANKING;
     l_ext_new_rec.PERFORMANCE_REVIEW_ID := p_rec.PERFORMANCE_REVIEW_ID;
     l_ext_new_rec.ATTRIBUTE1            := p_rec.ATTRIBUTE1;
     l_ext_new_rec.ATTRIBUTE2            := p_rec.ATTRIBUTE2;
     l_ext_new_rec.ATTRIBUTE3            := p_rec.ATTRIBUTE3;
     l_ext_new_rec.ATTRIBUTE4            := p_rec.ATTRIBUTE4;
     l_ext_new_rec.ATTRIBUTE5            := p_rec.ATTRIBUTE5;
     l_ext_new_rec.ATTRIBUTE6            := p_rec.ATTRIBUTE6;
     l_ext_new_rec.ATTRIBUTE7            := p_rec.ATTRIBUTE7;
     l_ext_new_rec.ATTRIBUTE8            := p_rec.ATTRIBUTE8;
     l_ext_new_rec.ATTRIBUTE9            := p_rec.ATTRIBUTE9;
     l_ext_new_rec.ATTRIBUTE10           := p_rec.ATTRIBUTE10;
     l_ext_new_rec.ATTRIBUTE11           := p_rec.ATTRIBUTE11;
     l_ext_new_rec.ATTRIBUTE12           := p_rec.ATTRIBUTE12;
     l_ext_new_rec.ATTRIBUTE13           := p_rec.ATTRIBUTE13;
     l_ext_new_rec.ATTRIBUTE14           := p_rec.ATTRIBUTE14;
     l_ext_new_rec.ATTRIBUTE15           := p_rec.ATTRIBUTE15;
     l_ext_new_rec.ATTRIBUTE16           := p_rec.ATTRIBUTE16;
     l_ext_new_rec.ATTRIBUTE17           := p_rec.ATTRIBUTE17;
     l_ext_new_rec.ATTRIBUTE18           := p_rec.ATTRIBUTE18;
     l_ext_new_rec.ATTRIBUTE19           := p_rec.ATTRIBUTE19;
     l_ext_new_rec.ATTRIBUTE20           := p_rec.ATTRIBUTE20;
     --l_ext_new_rec.PROPOSED_SALARY       := p_rec.PROPOSED_SALARY;
     l_ext_new_rec.date_to               := p_rec.date_to;
     l_ext_new_rec.update_mode           := 'UPDATE';
     l_event                             := 'INSERT' ;

  per_pyp_rki.after_insert
    (
     p_pay_proposal_id              => p_rec.pay_proposal_id,
     p_assignment_id                => p_rec.assignment_id,
     p_business_group_id            => p_rec.business_group_id,
     p_change_date                  => p_rec.change_date,
     p_comments                     => p_rec.comments,
     p_next_sal_review_date         => p_rec.next_sal_review_date,
     p_proposal_reason              => p_rec.proposal_reason,
     p_proposed_salary_n            => p_rec.proposed_salary_n,
     p_forced_ranking               => p_rec.forced_ranking,
     p_date_to          => p_rec.date_to,
     p_performance_review_id        => p_rec.performance_review_id,
     p_attribute_category           => p_rec.attribute_category,
     p_attribute1                   => p_rec.attribute1,
     p_attribute2                   => p_rec.attribute2,
     p_attribute3                   => p_rec.attribute3,
     p_attribute4                   => p_rec.attribute4,
     p_attribute5                   => p_rec.attribute5,
     p_attribute6                   => p_rec.attribute6,
     p_attribute7                   => p_rec.attribute7,
     p_attribute8                   => p_rec.attribute8,
     p_attribute9                   => p_rec.attribute9,
     p_attribute10                  => p_rec.attribute10,
     p_attribute11                  => p_rec.attribute11,
     p_attribute12                  => p_rec.attribute12,
     p_attribute13                  => p_rec.attribute13,
     p_attribute14                  => p_rec.attribute14,
     p_attribute15                  => p_rec.attribute15,
     p_attribute16                  => p_rec.attribute16,
     p_attribute17                  => p_rec.attribute17,
     p_attribute18                  => p_rec.attribute18,
     p_attribute19                  => p_rec.attribute19,
     p_attribute20                  => p_rec.attribute20,
     p_object_version_number        => p_rec.object_version_number,
     p_multiple_components          => p_rec.multiple_components,
     p_approved                     => p_rec.approved,
     p_inv_next_sal_date_warning    => p_inv_next_sal_date_warning,
     p_proposed_salary_warning      => p_proposed_salary_warning,
     p_approved_warning             => p_approved_warning,
     p_payroll_warning              => p_payroll_warning
    );
    --
    hr_utility.set_location('DM Mode pro ' ||hr_general.g_data_migrator_mode ,379);
    --
    -- OAB Bug 1863413 : Detect potential life events when salary
    -- information  changes
    --
    if hr_general.g_data_migrator_mode not in ( 'Y','P') then
       ben_pro_ler.ler_chk(p_old  => l_old_rec
                     ,p_new =>  l_new_rec
                     ,p_effective_date => p_rec.change_date  );
    End if ;
    --
    -- extract change event log call
    if hr_general.g_data_migrator_mode <> 'Y' then
       hr_utility.set_location('Extract event logged called for pay proposal',99) ;
       ben_ext_chlg.log_per_pay_chg
         (p_event   => l_event
         ,p_old_rec => l_ext_old_rec
         ,p_new_rec => l_ext_new_rec
         );
       hr_utility.set_location('Extract event logged out ',99) ;
    end if ;


  exception
    when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name => 'PER_PAY_PROPOSALS'
         ,p_hook_type  => 'AI'
         );
  end;
  -- End of API User Hook for post_insert.
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec             in out nocopy per_pyp_shd.g_rec_type,
  p_validate        in     boolean ,
  p_inv_next_sal_date_warning    out nocopy boolean ,
  p_proposed_salary_warning    out nocopy boolean ,
  p_approved_warning       out nocopy boolean ,
  p_payroll_warning      out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
  l_inv_next_sal_date_warning  boolean;
  l_proposed_salary_warning      boolean;
  l_approved_warning             boolean;
  l_payroll_warning    boolean;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_per_pyp;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  per_pyp_bus.insert_validate
        (p_rec             => p_rec
        ,p_inv_next_sal_date_warning   => l_inv_next_sal_date_warning
        ,p_proposed_salary_warning     => l_proposed_salary_warning
        ,p_approved_warning            => l_approved_warning
        ,p_payroll_warning         => l_payroll_warning
        );
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec         => p_rec
       ,p_inv_next_sal_date_warning   => l_inv_next_sal_date_warning
             ,p_proposed_salary_warning     => l_proposed_salary_warning
             ,p_approved_warning            => l_approved_warning
             ,p_payroll_warning         => l_payroll_warning
       );
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  --  Set the out arguments
  --
  p_inv_next_sal_date_warning := l_inv_next_sal_date_warning;
  p_proposed_salary_warning := l_proposed_salary_warning;
  p_approved_warning    := l_approved_warning;
  p_payroll_warning   := l_payroll_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_per_pyp;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_pay_proposal_id              out nocopy number,
  p_assignment_id                in number,
  p_business_group_id            in number,
  p_change_date                  in date,
  p_comments                     in varchar2,
  p_next_sal_review_date         in date,
  p_proposal_reason              in varchar2,
  p_proposed_salary_n            in number,
  p_forced_ranking               in number,
  p_date_to      in date,
  p_performance_review_id        in number,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_object_version_number        out nocopy number,
  p_multiple_components          in varchar2,
  p_approved                     in varchar2,
  p_validate                     in boolean,
  p_inv_next_sal_date_warning  out nocopy boolean,
  p_proposed_salary_warning      out nocopy boolean,
  p_approved_warning             out nocopy boolean,
  p_payroll_warning    out nocopy boolean
  ) is
--
  l_rec   per_pyp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_pyp_shd.convert_args
  (
  null,
  p_assignment_id,
  p_business_group_id,
  p_change_date,
  p_comments,
  null,
  p_next_sal_review_date,
  p_proposal_reason,
  p_proposed_salary_n,
  p_forced_ranking,
  p_date_to,
  p_performance_review_id,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
  null,
  p_multiple_components,
  p_approved
  );
  --
  -- Having converted the arguments into the per_pyp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_rec       => l_rec
     ,p_validate      => p_validate
     ,p_inv_next_sal_date_warning => p_inv_next_sal_date_warning
     ,p_proposed_salary_warning   => p_proposed_salary_warning
     ,p_approved_warning    => p_approved_warning
     ,p_payroll_warning     => p_payroll_warning
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pay_proposal_id := l_rec.pay_proposal_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_pyp_ins;

/
