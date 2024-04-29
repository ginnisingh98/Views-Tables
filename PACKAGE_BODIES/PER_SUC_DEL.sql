--------------------------------------------------------
--  DDL for Package Body PER_SUC_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUC_DEL" 
AS
/* $Header: pesucrhi.pkb 120.1.12010000.9 2010/02/22 20:28:53 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
   g_package   VARCHAR2 (33) := '  per_suc_del.';                            -- Global package name

--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
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
   PROCEDURE delete_dml (p_rec IN per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'delete_dml';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      per_suc_shd.g_api_dml      := TRUE;                                 -- Set the api dml status

      --
      -- Delete the per_succession_planning row.
      --
      DELETE FROM per_succession_planning
            WHERE succession_plan_id = p_rec.succession_plan_id;

      --
      per_suc_shd.g_api_dml      := FALSE;                              -- Unset the api dml status
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
--
   EXCEPTION
      WHEN hr_api.child_integrity_violated
      THEN
         -- Child integrity has been violated
         per_suc_shd.g_api_dml      := FALSE;                           -- Unset the api dml status
         per_suc_shd.constraint_error (p_constraint_name      => hr_api.strip_constraint_name
                                                                                           (SQLERRM));
      WHEN OTHERS
      THEN
         per_suc_shd.g_api_dml      := FALSE;                           -- Unset the api dml status
         RAISE;
   END delete_dml;

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
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE pre_delete (p_rec IN per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'pre_delete';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END pre_delete;

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
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE post_delete (p_rec IN per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'post_delete';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);

      --
      -- Start of Row Handler User Hook for post_delete.
      --
      BEGIN
         per_suc_rkd.after_delete
                     (p_succession_plan_id             => p_rec.succession_plan_id,
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
                                                p_hook_type        => 'AD'
                                               );
      END;

      --
      -- End of Row Handler User Hook for post_delete.
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END post_delete;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE del (p_rec IN per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'del';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- We must lock the row which we need to delete.
      --
      per_suc_shd.lck (p_rec.succession_plan_id, p_rec.object_version_number);
      --
      -- Call the supporting delete validate operation
      --
      per_suc_bus.delete_validate (p_rec);
      --
      -- Call the supporting pre-delete operation
      --
      pre_delete (p_rec);
      --
      -- Delete the row.
      --
      delete_dml (p_rec);
      --
      -- Call the supporting post-delete operation
      --
      post_delete (p_rec);
   END del;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE del (p_succession_plan_id IN NUMBER, p_object_version_number IN NUMBER)
   IS
--
      l_rec    per_suc_shd.g_rec_type;
      l_proc   VARCHAR2 (72)          := g_package || 'del';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- As the delete procedure accepts a plsql record structure we do need to
      -- convert the  arguments into the record structure.
      -- We don't need to call the supplied conversion argument routine as we
      -- only need a few attributes.
      --
      l_rec.succession_plan_id   := p_succession_plan_id;
      l_rec.object_version_number := p_object_version_number;
      --
      -- Having converted the arguments into the per_suc_rec
      -- plsql record structure we must call the corresponding entity
      -- business process
      --
      del (l_rec);
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END del;
--
END per_suc_del;

/
