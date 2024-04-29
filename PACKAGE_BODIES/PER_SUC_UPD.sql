--------------------------------------------------------
--  DDL for Package Body PER_SUC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUC_UPD" 
AS
/* $Header: pesucrhi.pkb 120.1.12010000.9 2010/02/22 20:28:53 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
   g_package   VARCHAR2 (33) := '  per_suc_upd.';                            -- Global package name

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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE update_dml (p_rec IN OUT NOCOPY per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'update_dml';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- Increment the object version
      --
      p_rec.object_version_number := p_rec.object_version_number + 1;
      --
      per_suc_shd.g_api_dml      := TRUE;                                 -- Set the api dml status

      --
      -- Update the per_succession_planning Row
      --
      UPDATE per_succession_planning
         SET succession_plan_id = p_rec.succession_plan_id,
             person_id = p_rec.person_id,
             position_id = p_rec.position_id,
             business_group_id = p_rec.business_group_id,
             start_date = p_rec.start_date,
             time_scale = p_rec.time_scale,
             end_date = p_rec.end_date,
             available_for_promotion = p_rec.available_for_promotion,
             manager_comments = p_rec.manager_comments,
             object_version_number = p_rec.object_version_number,
             attribute_category = p_rec.attribute_category,
             attribute1 = p_rec.attribute1,
             attribute2 = p_rec.attribute2,
             attribute3 = p_rec.attribute3,
             attribute4 = p_rec.attribute4,
             attribute5 = p_rec.attribute5,
             attribute6 = p_rec.attribute6,
             attribute7 = p_rec.attribute7,
             attribute8 = p_rec.attribute8,
             attribute9 = p_rec.attribute9,
             attribute10 = p_rec.attribute10,
             attribute11 = p_rec.attribute11,
             attribute12 = p_rec.attribute12,
             attribute13 = p_rec.attribute13,
             attribute14 = p_rec.attribute14,
             attribute15 = p_rec.attribute15,
             attribute16 = p_rec.attribute16,
             attribute17 = p_rec.attribute17,
             attribute18 = p_rec.attribute18,
             attribute19 = p_rec.attribute19,
             attribute20 = p_rec.attribute20,
             job_id = p_rec.job_id,
             successee_person_id = p_rec.successee_person_id,
             person_rank = p_rec.person_rank,
             PERFORMANCE = p_rec.PERFORMANCE,
             plan_status = p_rec.plan_status,
             readiness_percentage = p_rec.readiness_percentage
       WHERE succession_plan_id = p_rec.succession_plan_id;

      --
      per_suc_shd.g_api_dml      := FALSE;                               -- Unset the api dml status
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
--
   EXCEPTION
      WHEN hr_api.check_integrity_violated
      THEN
         -- A check constraint has been violated
         per_suc_shd.g_api_dml      := FALSE;                           -- Unset the api dml status
         per_suc_shd.constraint_error (p_constraint_name      => hr_api.strip_constraint_name
                                                                                           (SQLERRM));
      WHEN hr_api.parent_integrity_violated
      THEN
         -- Parent integrity has been violated
         per_suc_shd.g_api_dml      := FALSE;                           -- Unset the api dml status
         per_suc_shd.constraint_error (p_constraint_name      => hr_api.strip_constraint_name
                                                                                           (SQLERRM));
      WHEN hr_api.unique_integrity_violated
      THEN
         -- Unique integrity has been violated
         per_suc_shd.g_api_dml      := FALSE;                           -- Unset the api dml status
         per_suc_shd.constraint_error (p_constraint_name      => hr_api.strip_constraint_name
                                                                                           (SQLERRM));
      WHEN OTHERS
      THEN
         per_suc_shd.g_api_dml      := FALSE;                           -- Unset the api dml status
         RAISE;
   END update_dml;

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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE pre_update (p_rec IN per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'pre_update';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END pre_update;

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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE post_update (p_rec IN per_suc_shd.g_rec_type, p_effective_date IN DATE)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'post_update';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);

      --
      -- Start of Row Handler User Hook for post_update.
      --
      BEGIN
         per_suc_rku.after_update
                     (p_succession_plan_id             => p_rec.succession_plan_id,
                      p_person_id                      => p_rec.person_id,
                      p_position_id                    => p_rec.position_id,
                      p_business_group_id              => p_rec.business_group_id,
                      p_start_date                     => p_rec.start_date,
                      p_time_scale                     => p_rec.time_scale,
                      p_end_date                       => p_rec.end_date,
                      p_available_for_promotion        => p_rec.available_for_promotion,
                      p_manager_comments               => p_rec.manager_comments,
                      p_object_version_number          => p_rec.object_version_number,
                      p_attribute_category             => p_rec.attribute_category,
                      p_attribute1                     => p_rec.attribute1,
                      p_attribute2                     => p_rec.attribute2,
                      p_attribute3                     => p_rec.attribute3,
                      p_attribute4                     => p_rec.attribute4,
                      p_attribute5                     => p_rec.attribute5,
                      p_attribute6                     => p_rec.attribute6,
                      p_attribute7                     => p_rec.attribute7,
                      p_attribute8                     => p_rec.attribute8,
                      p_attribute9                     => p_rec.attribute9,
                      p_attribute10                    => p_rec.attribute10,
                      p_attribute11                    => p_rec.attribute11,
                      p_attribute12                    => p_rec.attribute12,
                      p_attribute13                    => p_rec.attribute13,
                      p_attribute14                    => p_rec.attribute14,
                      p_attribute15                    => p_rec.attribute15,
                      p_attribute16                    => p_rec.attribute16,
                      p_attribute17                    => p_rec.attribute17,
                      p_attribute18                    => p_rec.attribute18,
                      p_attribute19                    => p_rec.attribute19,
                      p_attribute20                    => p_rec.attribute20,
                      p_effective_date                 => p_effective_date,
                      p_job_id                         => p_rec.job_id,
                      p_successee_person_id            => p_rec.successee_person_id,
                      p_person_rank                    => p_rec.person_rank,
                      p_performance                    => p_rec.PERFORMANCE,
                      p_plan_status                    => p_rec.plan_status,
                      p_readiness_percentage           => p_rec.readiness_percentage,
                      p_person_id_o                    => per_suc_shd.g_old_rec.person_id,
                      p_position_id_o                  => per_suc_shd.g_old_rec.position_id,
                      p_business_group_id_o            => per_suc_shd.g_old_rec.business_group_id,
                      p_start_date_o                   => per_suc_shd.g_old_rec.start_date,
                      p_time_scale_o                   => per_suc_shd.g_old_rec.time_scale,
                      p_end_date_o                     => per_suc_shd.g_old_rec.end_date,
                      p_available_for_promotion_o      => per_suc_shd.g_old_rec.available_for_promotion,
                      p_manager_comments_o             => per_suc_shd.g_old_rec.manager_comments,
                      p_object_version_number_o        => per_suc_shd.g_old_rec.object_version_number,
                      p_attribute_category_o           => per_suc_shd.g_old_rec.attribute_category,
                      p_attribute1_o                   => per_suc_shd.g_old_rec.attribute1,
                      p_attribute2_o                   => per_suc_shd.g_old_rec.attribute2,
                      p_attribute3_o                   => per_suc_shd.g_old_rec.attribute3,
                      p_attribute4_o                   => per_suc_shd.g_old_rec.attribute4,
                      p_attribute5_o                   => per_suc_shd.g_old_rec.attribute5,
                      p_attribute6_o                   => per_suc_shd.g_old_rec.attribute6,
                      p_attribute7_o                   => per_suc_shd.g_old_rec.attribute7,
                      p_attribute8_o                   => per_suc_shd.g_old_rec.attribute8,
                      p_attribute9_o                   => per_suc_shd.g_old_rec.attribute9,
                      p_attribute10_o                  => per_suc_shd.g_old_rec.attribute10,
                      p_attribute11_o                  => per_suc_shd.g_old_rec.attribute11,
                      p_attribute12_o                  => per_suc_shd.g_old_rec.attribute12,
                      p_attribute13_o                  => per_suc_shd.g_old_rec.attribute13,
                      p_attribute14_o                  => per_suc_shd.g_old_rec.attribute14,
                      p_attribute15_o                  => per_suc_shd.g_old_rec.attribute15,
                      p_attribute16_o                  => per_suc_shd.g_old_rec.attribute16,
                      p_attribute17_o                  => per_suc_shd.g_old_rec.attribute17,
                      p_attribute18_o                  => per_suc_shd.g_old_rec.attribute18,
                      p_attribute19_o                  => per_suc_shd.g_old_rec.attribute19,
                      p_attribute20_o                  => per_suc_shd.g_old_rec.attribute20,
                      p_job_id_o                       => per_suc_shd.g_old_rec.job_id,
                      p_successee_person_id_o          => per_suc_shd.g_old_rec.successee_person_id,
                      p_person_rank_o                  => per_suc_shd.g_old_rec.person_rank,
                      p_performance_o                  => per_suc_shd.g_old_rec.PERFORMANCE,
                      p_plan_status_o                  => per_suc_shd.g_old_rec.plan_status,
                      p_readiness_percentage_o         => per_suc_shd.g_old_rec.readiness_percentage
                     );
      EXCEPTION
         WHEN hr_api.cannot_find_prog_unit
         THEN
            hr_api.cannot_find_prog_unit_error (p_module_name      => 'PER_SUCCESSION_PLANNING',
                                                p_hook_type        => 'AU'
                                               );
      END;

      --
      -- End of Row Handler User Hook for post_update.
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END post_update;

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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE convert_defs (p_rec IN OUT NOCOPY per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'convert_defs';
--
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);

      --
      -- We must now examine each argument value in the
      -- p_rec plsql record structure
      -- to see if a system default is being used. If a system default
      -- is being used then we must set to the 'current' argument value.
      --
      IF (p_rec.person_id = hr_api.g_number)
      THEN
         p_rec.person_id            := per_suc_shd.g_old_rec.person_id;
      END IF;

      IF (p_rec.position_id = hr_api.g_number)
      THEN
         p_rec.position_id          := per_suc_shd.g_old_rec.position_id;
      END IF;

      IF (p_rec.business_group_id = hr_api.g_number)
      THEN
         p_rec.business_group_id    := per_suc_shd.g_old_rec.business_group_id;
      END IF;

      IF (p_rec.start_date = hr_api.g_date)
      THEN
         p_rec.start_date           := per_suc_shd.g_old_rec.start_date;
      END IF;

      IF (p_rec.time_scale = hr_api.g_varchar2)
      THEN
         p_rec.time_scale           := per_suc_shd.g_old_rec.time_scale;
      END IF;

      IF (p_rec.end_date = hr_api.g_date)
      THEN
         p_rec.end_date             := per_suc_shd.g_old_rec.end_date;
      END IF;

      IF (p_rec.available_for_promotion = hr_api.g_varchar2)
      THEN
         p_rec.available_for_promotion := per_suc_shd.g_old_rec.available_for_promotion;
      END IF;

      IF (p_rec.manager_comments = hr_api.g_varchar2)
      THEN
         p_rec.manager_comments     := per_suc_shd.g_old_rec.manager_comments;
      END IF;

      IF (p_rec.attribute_category = hr_api.g_varchar2)
      THEN
         p_rec.attribute_category   := per_suc_shd.g_old_rec.attribute_category;
      END IF;

      IF (p_rec.attribute1 = hr_api.g_varchar2)
      THEN
         p_rec.attribute1           := per_suc_shd.g_old_rec.attribute1;
      END IF;

      IF (p_rec.attribute2 = hr_api.g_varchar2)
      THEN
         p_rec.attribute2           := per_suc_shd.g_old_rec.attribute2;
      END IF;

      IF (p_rec.attribute3 = hr_api.g_varchar2)
      THEN
         p_rec.attribute3           := per_suc_shd.g_old_rec.attribute3;
      END IF;

      IF (p_rec.attribute4 = hr_api.g_varchar2)
      THEN
         p_rec.attribute4           := per_suc_shd.g_old_rec.attribute4;
      END IF;

      IF (p_rec.attribute5 = hr_api.g_varchar2)
      THEN
         p_rec.attribute5           := per_suc_shd.g_old_rec.attribute5;
      END IF;

      IF (p_rec.attribute6 = hr_api.g_varchar2)
      THEN
         p_rec.attribute6           := per_suc_shd.g_old_rec.attribute6;
      END IF;

      IF (p_rec.attribute7 = hr_api.g_varchar2)
      THEN
         p_rec.attribute7           := per_suc_shd.g_old_rec.attribute7;
      END IF;

      IF (p_rec.attribute8 = hr_api.g_varchar2)
      THEN
         p_rec.attribute8           := per_suc_shd.g_old_rec.attribute8;
      END IF;

      IF (p_rec.attribute9 = hr_api.g_varchar2)
      THEN
         p_rec.attribute9           := per_suc_shd.g_old_rec.attribute9;
      END IF;

      IF (p_rec.attribute10 = hr_api.g_varchar2)
      THEN
         p_rec.attribute10          := per_suc_shd.g_old_rec.attribute10;
      END IF;

      IF (p_rec.attribute11 = hr_api.g_varchar2)
      THEN
         p_rec.attribute11          := per_suc_shd.g_old_rec.attribute11;
      END IF;

      IF (p_rec.attribute12 = hr_api.g_varchar2)
      THEN
         p_rec.attribute12          := per_suc_shd.g_old_rec.attribute12;
      END IF;

      IF (p_rec.attribute13 = hr_api.g_varchar2)
      THEN
         p_rec.attribute13          := per_suc_shd.g_old_rec.attribute13;
      END IF;

      IF (p_rec.attribute14 = hr_api.g_varchar2)
      THEN
         p_rec.attribute14          := per_suc_shd.g_old_rec.attribute14;
      END IF;

      IF (p_rec.attribute15 = hr_api.g_varchar2)
      THEN
         p_rec.attribute15          := per_suc_shd.g_old_rec.attribute15;
      END IF;

      IF (p_rec.attribute16 = hr_api.g_varchar2)
      THEN
         p_rec.attribute16          := per_suc_shd.g_old_rec.attribute16;
      END IF;

      IF (p_rec.attribute17 = hr_api.g_varchar2)
      THEN
         p_rec.attribute17          := per_suc_shd.g_old_rec.attribute17;
      END IF;

      IF (p_rec.attribute18 = hr_api.g_varchar2)
      THEN
         p_rec.attribute18          := per_suc_shd.g_old_rec.attribute18;
      END IF;

      IF (p_rec.attribute19 = hr_api.g_varchar2)
      THEN
         p_rec.attribute19          := per_suc_shd.g_old_rec.attribute19;
      END IF;

      IF (p_rec.attribute20 = hr_api.g_varchar2)
      THEN
         p_rec.attribute20          := per_suc_shd.g_old_rec.attribute20;
      END IF;

      IF (p_rec.job_id = hr_api.g_number)
      THEN
         p_rec.job_id               := per_suc_shd.g_old_rec.job_id;
      END IF;

      IF (p_rec.successee_person_id = hr_api.g_number)
      THEN
         p_rec.successee_person_id  := per_suc_shd.g_old_rec.successee_person_id;
      END IF;

      IF (p_rec.person_rank = hr_api.g_number)
      THEN
         p_rec.person_rank          := per_suc_shd.g_old_rec.person_rank;
      END IF;

      IF (p_rec.PERFORMANCE = hr_api.g_varchar2)
      THEN
         p_rec.PERFORMANCE          := per_suc_shd.g_old_rec.PERFORMANCE;
      END IF;

      IF (p_rec.plan_status = hr_api.g_varchar2)
      THEN
         p_rec.plan_status          := per_suc_shd.g_old_rec.plan_status;
      END IF;

      IF (p_rec.readiness_percentage = hr_api.g_number)
      THEN
         p_rec.readiness_percentage := per_suc_shd.g_old_rec.readiness_percentage;
      END IF;

      hr_utility.set_location (' Leaving:' || l_proc, 10);
--
   END convert_defs;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE upd (p_rec IN OUT NOCOPY per_suc_shd.g_rec_type, p_effective_date IN DATE)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'upd';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- We must lock the row which we need to update.
      --
      per_suc_shd.lck (p_rec.succession_plan_id, p_rec.object_version_number);
      --
      -- 1. During an update system defaults are used to determine if
      --    arguments have been defaulted or not. We must therefore
      --    derive the full record structure values to be updated.
      --
      -- 2. Call the supporting update validate operations.
      --
      convert_defs (p_rec);
      per_suc_bus.update_validate (p_rec, p_effective_date);
      --
      -- Call the supporting pre-update operation
      --
      pre_update (p_rec);
      --
      -- Update the row.
      --
      update_dml (p_rec);
      --
      -- Call the supporting post-update operation
      --
      post_update (p_rec, p_effective_date);
   END upd;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE upd (
      p_succession_plan_id        IN              NUMBER,
      p_person_id                 IN              NUMBER DEFAULT hr_api.g_number,
      p_position_id               IN              NUMBER DEFAULT hr_api.g_number,
      p_business_group_id         IN              NUMBER DEFAULT hr_api.g_number,
      p_start_date                IN              DATE DEFAULT hr_api.g_date,
      p_time_scale                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_end_date                  IN              DATE DEFAULT hr_api.g_date,
      p_available_for_promotion   IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_manager_comments          IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_object_version_number     IN OUT NOCOPY   NUMBER,
      p_attribute_category        IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute1                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute2                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute3                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute4                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute5                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute6                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute7                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute8                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute9                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute10               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute11               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute12               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute13               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute14               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute15               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute16               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute17               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute18               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute19               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute20               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_effective_date            IN              DATE DEFAULT hr_api.g_date,
      p_job_id                    IN              NUMBER DEFAULT hr_api.g_number,
      p_successee_person_id       IN              NUMBER DEFAULT hr_api.g_number,
      p_person_rank               IN              NUMBER DEFAULT hr_api.g_number,
      p_performance               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_plan_status               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_readiness_percentage      IN              NUMBER DEFAULT hr_api.g_number
   )
   IS
--
      l_rec    per_suc_shd.g_rec_type;
      l_proc   VARCHAR2 (72)          := g_package || 'upd';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- Call conversion function to turn arguments into the
      -- l_rec structure.
      --
      l_rec                      :=
         per_suc_shd.convert_args (p_succession_plan_id,
                                   p_person_id,
                                   p_position_id,
                                   p_business_group_id,
                                   p_start_date,
                                   p_time_scale,
                                   p_end_date,
                                   p_available_for_promotion,
                                   p_manager_comments,
                                   p_object_version_number,
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
                                   p_job_id,
                                   p_successee_person_id,
                                   p_person_rank,
                                   p_performance,
                                   p_plan_status,
                                   p_readiness_percentage
                                  );
      --
      -- Having converted the arguments into the
      -- plsql record structure we call the corresponding record
      -- business process.
      --
      upd (l_rec, p_effective_date);
      p_object_version_number    := l_rec.object_version_number;
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END upd;
--
END per_suc_upd;

/
