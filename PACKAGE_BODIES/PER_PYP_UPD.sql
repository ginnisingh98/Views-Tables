--------------------------------------------------------
--  DDL for Package Body PER_PYP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PYP_UPD" as
/* $Header: pepyprhi.pkb 120.17.12010000.7 2009/06/11 05:33:59 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pyp_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy per_pyp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  per_pyp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_pay_proposals Row
  --
  update per_pay_proposals
  set
  pay_proposal_id                   = p_rec.pay_proposal_id,
  event_id                          = null,
  change_date                       = p_rec.change_date,
  comments                          = p_rec.comments,
  next_perf_review_date             = null,
  next_sal_review_date              = p_rec.next_sal_review_date,
  performance_rating                = null,
  proposal_reason                   = p_rec.proposal_reason,
  proposed_salary_n                 = p_rec.proposed_salary_n,
  review_date                       = null,
  forced_ranking                    = p_rec.forced_ranking,
  date_to         = p_rec.date_to,
  performance_review_id             = p_rec.performance_review_id,
  attribute_category                = p_rec.attribute_category,
  attribute1                        = p_rec.attribute1,
  attribute2                        = p_rec.attribute2,
  attribute3                        = p_rec.attribute3,
  attribute4                        = p_rec.attribute4,
  attribute5                        = p_rec.attribute5,
  attribute6                        = p_rec.attribute6,
  attribute7                        = p_rec.attribute7,
  attribute8                        = p_rec.attribute8,
  attribute9                        = p_rec.attribute9,
  attribute10                       = p_rec.attribute10,
  attribute11                       = p_rec.attribute11,
  attribute12                       = p_rec.attribute12,
  attribute13                       = p_rec.attribute13,
  attribute14                       = p_rec.attribute14,
  attribute15                       = p_rec.attribute15,
  attribute16                       = p_rec.attribute16,
  attribute17                       = p_rec.attribute17,
  attribute18                       = p_rec.attribute18,
  attribute19                       = p_rec.attribute19,
  attribute20                       = p_rec.attribute20,
  object_version_number             = p_rec.object_version_number,
  multiple_components               = p_rec.multiple_components,
  approved                          = p_rec.approved
  where pay_proposal_id = p_rec.pay_proposal_id;
  --
  per_pyp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
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
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in per_pyp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec        in per_pyp_shd.g_rec_type
        ,p_inv_next_sal_date_warning    in  boolean
        ,p_proposed_salary_warning      in  boolean
        ,p_approved_warning             in  boolean
        ,p_payroll_warning              in  boolean
) is
--
  l_proc  varchar2(72) := g_package||'post_update';
  l_old_rec   ben_pro_ler.g_pro_ler_rec ;
  l_new_rec   ben_pro_ler.g_pro_ler_rec ;
  --
  -- extract change events
  l_ext_old_rec  ben_ext_chlg.g_per_pay_rec_type;
  l_ext_new_rec  ben_ext_chlg.g_per_pay_rec_type;
  l_event       varchar2(20) ;
   --vkodedal 6785012 EXTRACT BUG -old salary needs to be retrieved when proposal is approved
  l_old_salary  number;
  --

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call to user hook for post_update.
  --
     --
     -- OAB Bug 1863413 : Detect potential life events when salary
     -- information  changes
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
     l_old_rec.DATE_TO               := per_pyp_shd.g_old_rec.DATE_TO;
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
     l_new_rec.BUSINESS_GROUP_ID     := p_rec.BUSINESS_GROUP_ID;
     l_new_rec.PAY_PROPOSAL_ID       := p_rec.PAY_PROPOSAL_ID;
     l_new_rec.ASSIGNMENT_ID         := p_rec.ASSIGNMENT_ID;
     l_new_rec.EVENT_ID              := null; -- 9999 p_rec.EVENT_ID;
     l_new_rec.CHANGE_DATE           := p_rec.CHANGE_DATE;
     l_new_rec.LAST_CHANGE_DATE      := p_rec.LAST_CHANGE_DATE;
     l_new_rec.NEXT_PERF_REVIEW_DATE := null; -- 9999 p_rec.NEXT_PERF_REVIEW_DATE;
     l_new_rec.NEXT_SAL_REVIEW_DATE  := p_rec.NEXT_SAL_REVIEW_DATE;
     l_new_rec.PERFORMANCE_RATING    := null; -- 9999 p_rec.PERFORMANCE_RATING;
     l_new_rec.PROPOSAL_REASON       := p_rec.PROPOSAL_REASON;
     l_new_rec.PROPOSED_SALARY_N     := p_rec.PROPOSED_SALARY_N;
     l_new_rec.REVIEW_DATE           := null; -- 9999 p_rec.REVIEW_DATE;
     l_new_rec.APPROVED              := p_rec.APPROVED;
     l_new_rec.MULTIPLE_COMPONENTS   := p_rec.MULTIPLE_COMPONENTS;
     l_new_rec.FORCED_RANKING        := p_rec.FORCED_RANKING;
     l_new_rec.DATE_TO               := p_rec.DATE_TO;
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
     l_ext_old_rec.BUSINESS_GROUP_ID     := per_pyp_shd.g_old_rec.BUSINESS_GROUP_ID;
     l_ext_old_rec.PAY_PROPOSAL_ID       := per_pyp_shd.g_old_rec.PAY_PROPOSAL_ID;
     l_ext_old_rec.ASSIGNMENT_ID         := per_pyp_shd.g_old_rec.ASSIGNMENT_ID;
     --l_ext_old_rec.EVENT_ID            := per_pyp_shd.g_old_rec.EVENT_ID;
     l_ext_old_rec.CHANGE_DATE           := per_pyp_shd.g_old_rec.CHANGE_DATE;
     l_ext_old_rec.LAST_CHANGE_DATE      := per_pyp_shd.g_old_rec.LAST_CHANGE_DATE;
     --l_ext_old_rec.NEXT_PERF_REVIEW_DATE := per_pyp_shd.g_old_rec.NEXT_PERF_REVIEW_DATE;
     l_ext_old_rec.NEXT_SAL_REVIEW_DATE  := per_pyp_shd.g_old_rec.NEXT_SAL_REVIEW_DATE;
     --l_ext_old_rec.PERFORMANCE_RATING  := per_pyp_shd.g_old_rec.PERFORMANCE_RATING;
     l_ext_old_rec.PROPOSAL_REASON       := per_pyp_shd.g_old_rec.PROPOSAL_REASON;

     --vkodedal 6785012 EXTRACT BUG -old salary needs to be retrieved when proposal is approved
    if(l_old_rec.proposed_salary_n = p_rec.proposed_salary_n and
       l_old_rec.approved = 'N' and p_rec.approved = 'Y' and
       l_old_rec.change_date = p_rec.change_date)
    then
      begin
          select proposed_salary_n into l_old_salary from per_pay_proposals
          where assignment_id = p_rec.ASSIGNMENT_ID and
              change_date   = (select max(change_date) from per_pay_proposals where
          change_date < p_rec.change_date and assignment_id = p_rec.ASSIGNMENT_ID );
          l_ext_old_rec.PROPOSED_SALARY_N := l_old_salary;
      exception
		when no_data_found
		then
		l_ext_old_rec.PROPOSED_SALARY_N :=null;
		end;
    else
       l_ext_old_rec.PROPOSED_SALARY_N   := per_pyp_shd.g_old_rec.PROPOSED_SALARY_N;
    end if;

     --l_ext_old_rec.REVIEW_DATE         := per_pyp_shd.g_old_rec.REVIEW_DATE;
     l_ext_old_rec.APPROVED              := per_pyp_shd.g_old_rec.APPROVED;
     l_ext_old_rec.MULTIPLE_COMPONENTS   := per_pyp_shd.g_old_rec.MULTIPLE_COMPONENTS;
     l_ext_old_rec.FORCED_RANKING        := per_pyp_shd.g_old_rec.FORCED_RANKING;
     l_ext_old_rec.DATE_TO               := per_pyp_shd.g_old_rec.DATE_TO;
     l_ext_old_rec.PERFORMANCE_REVIEW_ID := per_pyp_shd.g_old_rec.PERFORMANCE_REVIEW_ID;
     l_ext_old_rec.ATTRIBUTE1            := per_pyp_shd.g_old_rec.ATTRIBUTE1;
     l_ext_old_rec.ATTRIBUTE2            := per_pyp_shd.g_old_rec.ATTRIBUTE2;
     l_ext_old_rec.ATTRIBUTE3            := per_pyp_shd.g_old_rec.ATTRIBUTE3;
     l_ext_old_rec.ATTRIBUTE4            := per_pyp_shd.g_old_rec.ATTRIBUTE4;
     l_ext_old_rec.ATTRIBUTE5            := per_pyp_shd.g_old_rec.ATTRIBUTE5;
     l_ext_old_rec.ATTRIBUTE6            := per_pyp_shd.g_old_rec.ATTRIBUTE6;
     l_ext_old_rec.ATTRIBUTE7            := per_pyp_shd.g_old_rec.ATTRIBUTE7;
     l_ext_old_rec.ATTRIBUTE8            := per_pyp_shd.g_old_rec.ATTRIBUTE8;
     l_ext_old_rec.ATTRIBUTE9            := per_pyp_shd.g_old_rec.ATTRIBUTE9;
     l_ext_old_rec.ATTRIBUTE10           := per_pyp_shd.g_old_rec.ATTRIBUTE10;
     l_ext_old_rec.ATTRIBUTE11           := per_pyp_shd.g_old_rec.ATTRIBUTE11;
     l_ext_old_rec.ATTRIBUTE12           := per_pyp_shd.g_old_rec.ATTRIBUTE12;
     l_ext_old_rec.ATTRIBUTE13           := per_pyp_shd.g_old_rec.ATTRIBUTE13;
     l_ext_old_rec.ATTRIBUTE14           := per_pyp_shd.g_old_rec.ATTRIBUTE14;
     l_ext_old_rec.ATTRIBUTE15           := per_pyp_shd.g_old_rec.ATTRIBUTE15;
     l_ext_old_rec.ATTRIBUTE16           := per_pyp_shd.g_old_rec.ATTRIBUTE16;
     l_ext_old_rec.ATTRIBUTE17           := per_pyp_shd.g_old_rec.ATTRIBUTE17;
     l_ext_old_rec.ATTRIBUTE18           := per_pyp_shd.g_old_rec.ATTRIBUTE18;
     l_ext_old_rec.ATTRIBUTE19           := per_pyp_shd.g_old_rec.ATTRIBUTE19;
     l_ext_old_rec.ATTRIBUTE20           := per_pyp_shd.g_old_rec.ATTRIBUTE20;
     --l_ext_old_rec.PROPOSED_SALARY     := per_pro_shd.g_old_rec.PROPOSED_SALARY;

     l_ext_new_rec.BUSINESS_GROUP_ID     := p_rec.BUSINESS_GROUP_ID;
     l_ext_new_rec.PAY_PROPOSAL_ID       := p_rec.PAY_PROPOSAL_ID;
     l_ext_new_rec.ASSIGNMENT_ID         := p_rec.ASSIGNMENT_ID;
     --l_ext_new_rec.EVENT_ID              := p_rec.EVENT_ID;
     l_ext_new_rec.CHANGE_DATE           := p_rec.CHANGE_DATE;
     l_ext_new_rec.LAST_CHANGE_DATE      := p_rec.LAST_CHANGE_DATE;
     -- l_ext_new_rec.NEXT_PERF_REVIEW_DATE := p_rec.NEXT_PERF_REVIEW_DATE;
     l_ext_new_rec.NEXT_SAL_REVIEW_DATE  := p_rec.NEXT_SAL_REVIEW_DATE;
     -- l_ext_new_rec.PERFORMANCE_RATING    := p_rec.PERFORMANCE_RATING;
     l_ext_new_rec.PROPOSAL_REASON       := p_rec.PROPOSAL_REASON;
     l_ext_new_rec.PROPOSED_SALARY_N     := p_rec.PROPOSED_SALARY_N;
     --l_ext_new_rec.REVIEW_DATE           := p_rec.REVIEW_DATE;
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
     -- l_ext_new_rec.PROPOSED_SALARY       := p_rec.PROPOSED_SALARY;
     l_ext_new_rec.date_to               := p_rec.date_to;
     l_event                             := 'UPDATE' ;
     if l_ext_new_rec.last_change_date = l_ext_old_rec.last_change_date  then
        l_ext_new_rec.update_mode := 'CORRECTION';
        l_ext_old_rec.update_mode := 'CORRECTION';
     else
        l_ext_new_rec.update_mode := 'UPDATE';
        l_ext_old_rec.update_mode := 'UPDATE';
     end if;

  begin
--
  per_pyp_rku.after_update
    (
     p_pay_proposal_id              => p_rec.pay_proposal_id,
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
     p_payroll_warning              => p_payroll_warning,
     p_assignment_id_o              => per_pyp_shd.g_old_rec.assignment_id,
     p_business_group_id_o          => per_pyp_shd.g_old_rec.business_group_id,
     p_change_date_o                => per_pyp_shd.g_old_rec.change_date,
     p_comments_o                   => per_pyp_shd.g_old_rec.comments,
     p_next_sal_review_date_o       => per_pyp_shd.g_old_rec.next_sal_review_date,
     p_proposal_reason_o            => per_pyp_shd.g_old_rec.proposal_reason,
     p_proposed_salary_n_o          => per_pyp_shd.g_old_rec.proposed_salary_n,
     p_forced_ranking_o             => per_pyp_shd.g_old_rec.forced_ranking,
     p_date_to_o        => per_pyp_shd.g_old_rec.date_to,
     p_performance_review_id_o      => per_pyp_shd.g_old_rec.performance_review_id,
     p_attribute_category_o         => per_pyp_shd.g_old_rec.attribute_category,
     p_attribute1_o                 => per_pyp_shd.g_old_rec.attribute1,
     p_attribute2_o                 => per_pyp_shd.g_old_rec.attribute2,
     p_attribute3_o                 => per_pyp_shd.g_old_rec.attribute3,
     p_attribute4_o                 => per_pyp_shd.g_old_rec.attribute4,
     p_attribute5_o                 => per_pyp_shd.g_old_rec.attribute5,
     p_attribute6_o                 => per_pyp_shd.g_old_rec.attribute6,
     p_attribute7_o                 => per_pyp_shd.g_old_rec.attribute7,
     p_attribute8_o                 => per_pyp_shd.g_old_rec.attribute8,
     p_attribute9_o                 => per_pyp_shd.g_old_rec.attribute9,
     p_attribute10_o                => per_pyp_shd.g_old_rec.attribute10,
     p_attribute11_o                => per_pyp_shd.g_old_rec.attribute11,
     p_attribute12_o                => per_pyp_shd.g_old_rec.attribute12,
     p_attribute13_o                => per_pyp_shd.g_old_rec.attribute13,
     p_attribute14_o                => per_pyp_shd.g_old_rec.attribute14,
     p_attribute15_o                => per_pyp_shd.g_old_rec.attribute15,
     p_attribute16_o                => per_pyp_shd.g_old_rec.attribute16,
     p_attribute17_o                => per_pyp_shd.g_old_rec.attribute17,
     p_attribute18_o                => per_pyp_shd.g_old_rec.attribute18,
     p_attribute19_o                => per_pyp_shd.g_old_rec.attribute19,
     p_attribute20_o                => per_pyp_shd.g_old_rec.attribute20,
     p_object_version_number_o      => per_pyp_shd.g_old_rec.object_version_number,
     p_multiple_components_o        => per_pyp_shd.g_old_rec.multiple_components,
     p_approved_o                   => per_pyp_shd.g_old_rec.approved
    );
  --
  hr_utility.set_location('DM Mode pro ' ||hr_general.g_data_migrator_mode ,379);
  --
  -- OAB Bug 1863413 : Detect potential life events when salary
  -- information  changes
  --
  if hr_general.g_data_migrator_mode not in ( 'Y','P') then
     ben_pro_ler.ler_chk(p_old => l_old_rec
                     ,p_new => l_new_rec
                     ,p_effective_date => p_rec.change_date  );
  end if ;

   -- extract change event log call
  if hr_general.g_data_migrator_mode <> 'Y' then

     hr_utility.set_location('Extract event logged called for pay proposal',99) ;
     ben_ext_chlg.log_per_pay_chg
         (p_event   => l_event
         ,p_old_rec => l_ext_old_rec
         ,p_new_rec => l_ext_new_rec
         );
     hr_utility.set_location('Extract event logged out',99) ;
   end if ;


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PAY_PROPOSALS'
        ,p_hook_type  => 'AU'
        );
  end;
  -- End of API User Hook for post_update.
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy per_pyp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    per_pyp_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_pyp_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.change_date = hr_api.g_date) then
    p_rec.change_date :=
    per_pyp_shd.g_old_rec.change_date;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_pyp_shd.g_old_rec.comments;
  End If;
  If (p_rec.last_change_date = hr_api.g_date) then
    p_rec.last_change_date :=
    per_pyp_shd.g_old_rec.last_change_date;
  End If;
  If (p_rec.next_sal_review_date = hr_api.g_date) then
    p_rec.next_sal_review_date :=
    per_pyp_shd.g_old_rec.next_sal_review_date;
  End If;
  If (p_rec.proposal_reason = hr_api.g_varchar2) then
    p_rec.proposal_reason :=
    per_pyp_shd.g_old_rec.proposal_reason;
  End If;
  If (p_rec.proposed_salary_n = hr_api.g_number) then
    p_rec.proposed_salary_n :=
    per_pyp_shd.g_old_rec.proposed_salary_n;
  End If;
  If (p_rec.forced_ranking = hr_api.g_number) then
    p_rec.forced_ranking :=
    per_pyp_shd.g_old_rec.forced_ranking;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    per_pyp_shd.g_old_rec.date_to;
  End If;
  If (p_rec.performance_review_id = hr_api.g_number) then
    p_rec.performance_review_id :=
    per_pyp_shd.g_old_rec.performance_review_id;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_pyp_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_pyp_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_pyp_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_pyp_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_pyp_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_pyp_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_pyp_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_pyp_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_pyp_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_pyp_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_pyp_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_pyp_shd.g_old_rec.attribute11;
  eND iF;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_pyp_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_pyp_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_pyp_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_pyp_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_pyp_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_pyp_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_pyp_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_pyp_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_pyp_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.multiple_components = hr_api.g_varchar2) then
    p_rec.multiple_components :=
    per_pyp_shd.g_old_rec.multiple_components;
  End If;
  If (p_rec.approved = hr_api.g_varchar2) then
    p_rec.approved :=
    per_pyp_shd.g_old_rec.approved;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec                                 in out nocopy per_pyp_shd.g_rec_type,
  p_validate                            in     boolean ,
  p_inv_next_sal_date_warning              out nocopy boolean ,
  p_proposed_salary_warning                out nocopy boolean ,
  p_approved_warning                       out nocopy boolean ,
  p_payroll_warning                        out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
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
    SAVEPOINT upd_per_pyp;
  End If;
  --
  -- We must lock the row which we need to update.
  --
 per_pyp_shd.lck
  (
  p_rec.pay_proposal_id,
  p_rec.object_version_number
  );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
per_pyp_bus.update_validate
        (p_rec                         => p_rec
        ,p_inv_next_sal_date_warning   => l_inv_next_sal_date_warning
        ,p_proposed_salary_warning     => l_proposed_salary_warning
        ,p_approved_warning            => l_approved_warning
        ,p_payroll_warning             => l_payroll_warning
        );
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec         => p_rec
       ,p_inv_next_sal_date_warning   => l_inv_next_sal_date_warning
             ,p_proposed_salary_warning     => l_proposed_salary_warning
             ,p_approved_warning            => l_approved_warning
             ,p_payroll_warning             => l_payroll_warning
           );

  p_inv_next_sal_date_warning := l_inv_next_sal_date_warning;
  p_proposed_salary_warning := l_proposed_salary_warning;
  p_approved_warning := l_approved_warning;
  p_payroll_warning := l_payroll_warning;

  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_per_pyp;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_pay_proposal_id              in number,
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
  p_object_version_number        in out nocopy number,
  p_multiple_components          in varchar2,
  p_approved                     in varchar2,
  p_validate                     in boolean,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning      out nocopy boolean,
  p_approved_warning             out nocopy boolean,
  p_payroll_warning              out nocopy boolean

  ) is
--
  l_rec   per_pyp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('ovn= '||to_char(p_object_version_number)||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pyp_shd.convert_args
  (
  p_pay_proposal_id,
  hr_api.g_number,
  hr_api.g_number,
  p_change_date,
  p_comments,
  hr_api.g_date,
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
  p_object_version_number,
  p_multiple_components,
  p_approved
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(p_rec                             => l_rec
     ,p_validate                        => p_validate
     ,p_inv_next_sal_date_warning       => p_inv_next_sal_date_warning
     ,p_proposed_salary_warning         => p_proposed_salary_warning
     ,p_approved_warning                => p_approved_warning
     ,p_payroll_warning                 => p_payroll_warning
     );
  --
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_pyp_upd;

/
