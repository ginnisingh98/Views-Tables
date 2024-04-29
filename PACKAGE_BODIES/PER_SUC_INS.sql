--------------------------------------------------------
--  DDL for Package Body PER_SUC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUC_INS" 
AS
/* $Header: pesucrhi.pkb 120.1.12010000.9 2010/02/22 20:28:53 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
   g_package              VARCHAR2 (33) := '  per_suc_ins.';                 -- Global package name
   g_succession_plan_id   NUMBER;    -------- global value set by swi by calling set base key value

--
-- ----------------------------------------------------------------------------
-- |------------------------------< set_base_key_value >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure copies the succesion plan id (primary key) into
--   g_succession_plan_id - a global value
-- Prerequisites:
--   This is an internal private procedure which must be called from the swi
--   to set the primary key
--
-- In Parameters:
--   Succession_plan_id - primary key
--

   --
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE set_base_key_value (p_succession_plan_id NUMBER)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'set_base_key_value';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      g_succession_plan_id       := p_succession_plan_id;
   END;

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
   PROCEDURE insert_dml (p_rec IN OUT NOCOPY per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'insert_dml';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      p_rec.object_version_number := 1;                            -- Initialise the object version
      --
      per_suc_shd.g_api_dml      := TRUE;                                 -- Set the api dml status

      --
      -- Insert the row into: per_succession_planning
      --
      INSERT INTO per_succession_planning
                  (succession_plan_id,
                   person_id,
                   position_id,
                   business_group_id,
                   start_date,
                   time_scale,
                   end_date,
                   available_for_promotion,
                   manager_comments,
                   object_version_number,
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
                   job_id,
                   successee_person_id,
                   person_rank,
                   PERFORMANCE,
                   plan_status,
                   readiness_percentage
                  )
           VALUES (p_rec.succession_plan_id,
                   p_rec.person_id,
                   p_rec.position_id,
                   p_rec.business_group_id,
                   p_rec.start_date,
                   p_rec.time_scale,
                   p_rec.end_date,
                   p_rec.available_for_promotion,
                   p_rec.manager_comments,
                   p_rec.object_version_number,
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
                   p_rec.job_id,
                   p_rec.successee_person_id,
                   p_rec.person_rank,
                   p_rec.PERFORMANCE,
                   p_rec.plan_status,
                   p_rec.readiness_percentage
                  );

      --
      per_suc_shd.g_api_dml      := FALSE;                               -- Unset the api dml status
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
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
   END insert_dml;

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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE pre_insert (p_rec IN OUT NOCOPY per_suc_shd.g_rec_type)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'pre_insert';

--
      CURSOR c_sel1
      IS
         SELECT per_succession_planning_s.NEXTVAL
           FROM SYS.DUAL;
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);

      --
      IF (g_succession_plan_id IS NULL)
      THEN
         --
         -- Select the next sequence number
         --
         OPEN c_sel1;

         FETCH c_sel1
          INTO p_rec.succession_plan_id;

         CLOSE c_sel1;
      ELSE
         p_rec.succession_plan_id   := g_succession_plan_id;
         g_succession_plan_id       := NULL;
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END pre_insert;

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
   PROCEDURE post_insert (p_rec IN per_suc_shd.g_rec_type, p_effective_date IN DATE)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'post_insert';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);

      --
      -- Start of Row Handler User Hook for post_insert.
      --
      BEGIN
         per_suc_rki.after_insert (p_succession_plan_id           => p_rec.succession_plan_id,
                                   p_person_id                    => p_rec.person_id,
                                   p_position_id                  => p_rec.position_id,
                                   p_business_group_id            => p_rec.business_group_id,
                                   p_start_date                   => p_rec.start_date,
                                   p_time_scale                   => p_rec.time_scale,
                                   p_end_date                     => p_rec.end_date,
                                   p_available_for_promotion      => p_rec.available_for_promotion,
                                   p_manager_comments             => p_rec.manager_comments,
                                   p_object_version_number        => p_rec.object_version_number,
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
                                   p_effective_date               => p_effective_date,
                                   p_job_id                       => p_rec.job_id,
                                   p_successee_person_id          => p_rec.successee_person_id,
                                   p_person_rank                  => p_rec.person_rank,
                                   p_performance                  => p_rec.PERFORMANCE,
                                   p_plan_status                  => p_rec.plan_status,
                                   p_readiness_percentage         => p_rec.readiness_percentage
                                  );
      EXCEPTION
         WHEN hr_api.cannot_find_prog_unit
         THEN
            hr_api.cannot_find_prog_unit_error (p_module_name      => 'PER_SUCCESSION_PLANNING',
                                                p_hook_type        => 'AI'
                                               );
      END;

      --
      -- End of Row Handler User Hook for post_insert.
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END post_insert;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE ins (p_rec IN OUT NOCOPY per_suc_shd.g_rec_type, p_effective_date IN DATE)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'ins';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- Call the supporting insert validate operations
      --
      per_suc_bus.insert_validate (p_rec, p_effective_date);
      --
      -- Call the supporting pre-insert operation
      --
      pre_insert (p_rec);
      --
      -- Insert the row
      --
      insert_dml (p_rec);
      --
      -- Call the supporting post-insert operation
      --
      post_insert (p_rec, p_effective_date);
   END ins;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE ins (
      p_succession_plan_id        OUT NOCOPY      NUMBER,
      p_person_id                 IN              NUMBER,
      p_position_id               IN              NUMBER DEFAULT NULL,
      p_business_group_id         IN              NUMBER,
      p_start_date                IN              DATE,
      p_time_scale                IN              VARCHAR2,
      p_end_date                  IN              DATE DEFAULT NULL,
      p_available_for_promotion   IN              VARCHAR2 DEFAULT NULL,
      p_manager_comments          IN              VARCHAR2 DEFAULT NULL,
      p_object_version_number     OUT NOCOPY      NUMBER,
      p_attribute_category        IN              VARCHAR2 DEFAULT NULL,
      p_attribute1                IN              VARCHAR2 DEFAULT NULL,
      p_attribute2                IN              VARCHAR2 DEFAULT NULL,
      p_attribute3                IN              VARCHAR2 DEFAULT NULL,
      p_attribute4                IN              VARCHAR2 DEFAULT NULL,
      p_attribute5                IN              VARCHAR2 DEFAULT NULL,
      p_attribute6                IN              VARCHAR2 DEFAULT NULL,
      p_attribute7                IN              VARCHAR2 DEFAULT NULL,
      p_attribute8                IN              VARCHAR2 DEFAULT NULL,
      p_attribute9                IN              VARCHAR2 DEFAULT NULL,
      p_attribute10               IN              VARCHAR2 DEFAULT NULL,
      p_attribute11               IN              VARCHAR2 DEFAULT NULL,
      p_attribute12               IN              VARCHAR2 DEFAULT NULL,
      p_attribute13               IN              VARCHAR2 DEFAULT NULL,
      p_attribute14               IN              VARCHAR2 DEFAULT NULL,
      p_attribute15               IN              VARCHAR2 DEFAULT NULL,
      p_attribute16               IN              VARCHAR2 DEFAULT NULL,
      p_attribute17               IN              VARCHAR2 DEFAULT NULL,
      p_attribute18               IN              VARCHAR2 DEFAULT NULL,
      p_attribute19               IN              VARCHAR2 DEFAULT NULL,
      p_attribute20               IN              VARCHAR2 DEFAULT NULL,
      p_effective_date            IN              DATE,
      p_job_id                    IN              NUMBER DEFAULT NULL,
      p_successee_person_id       IN              NUMBER DEFAULT NULL,
      p_person_rank               IN              NUMBER DEFAULT NULL,
      p_performance               IN              VARCHAR2 DEFAULT NULL,
      p_plan_status               IN              VARCHAR2 DEFAULT NULL,
      p_readiness_percentage      IN              NUMBER DEFAULT NULL
   )
   IS
--
      l_rec    per_suc_shd.g_rec_type;
      l_proc   VARCHAR2 (72)          := g_package || 'ins';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- Call conversion function to turn arguments into the
      -- p_rec structure.
      --
      l_rec                      :=
         per_suc_shd.convert_args (NULL,
                                   p_person_id,
                                   p_position_id,
                                   p_business_group_id,
                                   p_start_date,
                                   p_time_scale,
                                   p_end_date,
                                   p_available_for_promotion,
                                   p_manager_comments,
                                   NULL,
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
      -- Having converted the arguments into the per_suc_rec
      -- plsql record structure we call the corresponding record business process.
      --
      ins (l_rec, p_effective_date);
      --
      -- As the primary key argument(s)
      -- are specified as an OUT's we must set these values.
      --
      p_succession_plan_id       := l_rec.succession_plan_id;
      p_object_version_number    := l_rec.object_version_number;
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END ins;
--
END per_suc_ins;

/
