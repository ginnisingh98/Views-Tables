--------------------------------------------------------
--  DDL for Package Body PER_SUC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUC_SHD" AS
/* $Header: pesucrhi.pkb 120.1.12010000.9 2010/02/22 20:28:53 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
   g_package   VARCHAR2 (33) := '  per_suc_shd.';                            -- Global package name

--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION return_api_dml_status
      RETURN BOOLEAN
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'return_api_dml_status';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      RETURN (NVL (g_api_dml, FALSE));
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END return_api_dml_status;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE constraint_error (p_constraint_name IN all_constraints.constraint_name%TYPE)
   IS
--
      l_proc   VARCHAR2 (72) := g_package || 'constraint_error';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);

      --
      IF (p_constraint_name = 'PER_SUCCESSION_PLANNING_FK1')
      THEN
         hr_utility.set_message (801, 'HR_52000_SUC_CHK_POS_EXISTS');
         hr_utility.raise_error;
      ELSIF (p_constraint_name = 'PER_SUCCESSION_PLANNING_FK2')
      THEN
         hr_utility.set_message (801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token ('PROCEDURE', l_proc);
         hr_utility.set_message_token ('STEP', '10');
         hr_utility.raise_error;
      ELSIF (p_constraint_name = 'PER_SUCCESSION_PLANNING_PK')
      THEN
         hr_utility.set_message (801, 'HR_52006_SUC_CHK_SUCC_PLAN_ID');
         hr_utility.raise_error;
      ELSIF (p_constraint_name = 'PER_SUCCESSION_PLANNING_UK')
      THEN
         hr_utility.set_message (800, 'HR_33468_SUC_SAME_SUCCESSOR');
         hr_utility.raise_error;
      ELSIF (p_constraint_name = 'PER_SUC_AVAIL_FOR_PROMOTION')
      THEN
         hr_utility.set_message (801, 'HR_52004_SUC_CHK_AVAILABLE');
         hr_utility.raise_error;
      ELSE
         hr_utility.set_message (801, 'HR_7877_API_INVALID_CONSTRAINT');
         hr_utility.set_message_token ('PROCEDURE', l_proc);
         hr_utility.set_message_token ('CONSTRAINT_NAME', p_constraint_name);
         hr_utility.raise_error;
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
   END constraint_error;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION api_updating (p_succession_plan_id IN NUMBER, p_object_version_number IN NUMBER)
      RETURN BOOLEAN
   IS
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
      CURSOR c_sel1
      IS
         SELECT succession_plan_id,
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
           FROM per_succession_planning
          WHERE succession_plan_id = p_succession_plan_id;

--
      l_proc      VARCHAR2 (72) := g_package || 'api_updating';
      l_fct_ret   BOOLEAN;
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);

      --
      IF (p_succession_plan_id IS NULL AND p_object_version_number IS NULL)
      THEN
         --
         -- One of the primary key arguments is null therefore we must
         -- set the returning function value to false
         --
         l_fct_ret                  := FALSE;
      ELSE
         IF (    p_succession_plan_id = g_old_rec.succession_plan_id
             AND p_object_version_number = g_old_rec.object_version_number
            )
         THEN
            hr_utility.set_location (l_proc, 10);
            --
            -- The g_old_rec is current therefore we must
            -- set the returning function to true
            --
            l_fct_ret                  := TRUE;
         ELSE
            --
            -- Select the current row into g_old_rec
            --
            OPEN c_sel1;

            FETCH c_sel1
             INTO g_old_rec;

            IF c_sel1%NOTFOUND
            THEN
               CLOSE c_sel1;

               --
               -- The primary key is invalid therefore we must error
               --
               hr_utility.set_message (801, 'HR_7220_INVALID_PRIMARY_KEY');
               hr_utility.raise_error;
            END IF;

            CLOSE c_sel1;

            IF (p_object_version_number <> g_old_rec.object_version_number)
            THEN
               hr_utility.set_message (801, 'HR_7155_OBJECT_INVALID');
               hr_utility.raise_error;
            END IF;

            hr_utility.set_location (l_proc, 15);
            l_fct_ret                  := TRUE;
         END IF;
      END IF;

      hr_utility.set_location (' Leaving:' || l_proc, 20);
      RETURN (l_fct_ret);
--
   END api_updating;

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE lck (p_succession_plan_id IN NUMBER, p_object_version_number IN NUMBER)
   IS
--
-- Cursor selects the 'current' row from the HR Schema
--
      CURSOR c_sel1
      IS
         SELECT     succession_plan_id,
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
               FROM per_succession_planning
              WHERE succession_plan_id = p_succession_plan_id
         FOR UPDATE NOWAIT;

--
      l_proc   VARCHAR2 (72) := g_package || 'lck';
--
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);

      --
      -- Add any mandatory argument checking here:
      -- Example:
      -- hr_api.mandatory_arg_error
      --   (p_api_name       => l_proc,
      --    p_argument       => 'object_version_number',
      --    p_argument_value => p_object_version_number);
      --
      OPEN c_sel1;

      FETCH c_sel1
       INTO g_old_rec;

      IF c_sel1%NOTFOUND
      THEN
         CLOSE c_sel1;

         --
         -- The primary key is invalid therefore we must error
         --
         hr_utility.set_message (801, 'HR_7220_INVALID_PRIMARY_KEY');
         hr_utility.raise_error;
      END IF;

      CLOSE c_sel1;

      IF (p_object_version_number <> g_old_rec.object_version_number)
      THEN
         hr_utility.set_message (801, 'HR_7155_OBJECT_INVALID');
         hr_utility.raise_error;
      END IF;

--
      hr_utility.set_location (' Leaving:' || l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
   EXCEPTION
      WHEN hr_api.object_locked
      THEN
         --
         -- The object is locked therefore we need to supply a meaningful
         -- error message.
         --
         hr_utility.set_message (801, 'HR_7165_OBJECT_LOCKED');
         hr_utility.set_message_token ('TABLE_NAME', 'per_succession_planning');
         hr_utility.raise_error;
   END lck;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION convert_args (
      p_succession_plan_id        IN   NUMBER,
      p_person_id                 IN   NUMBER,
      p_position_id               IN   NUMBER,
      p_business_group_id         IN   NUMBER,
      p_start_date                IN   DATE,
      p_time_scale                IN   VARCHAR2,
      p_end_date                  IN   DATE,
      p_available_for_promotion   IN   VARCHAR2,
      p_manager_comments          IN   VARCHAR2,
      p_object_version_number     IN   NUMBER,
      p_attribute_category        IN   VARCHAR2,
      p_attribute1                IN   VARCHAR2,
      p_attribute2                IN   VARCHAR2,
      p_attribute3                IN   VARCHAR2,
      p_attribute4                IN   VARCHAR2,
      p_attribute5                IN   VARCHAR2,
      p_attribute6                IN   VARCHAR2,
      p_attribute7                IN   VARCHAR2,
      p_attribute8                IN   VARCHAR2,
      p_attribute9                IN   VARCHAR2,
      p_attribute10               IN   VARCHAR2,
      p_attribute11               IN   VARCHAR2,
      p_attribute12               IN   VARCHAR2,
      p_attribute13               IN   VARCHAR2,
      p_attribute14               IN   VARCHAR2,
      p_attribute15               IN   VARCHAR2,
      p_attribute16               IN   VARCHAR2,
      p_attribute17               IN   VARCHAR2,
      p_attribute18               IN   VARCHAR2,
      p_attribute19               IN   VARCHAR2,
      p_attribute20               IN   VARCHAR2,
      p_job_id                    IN   NUMBER,
      p_successee_person_id       IN   NUMBER,
      p_person_rank               IN   NUMBER,
      p_performance               IN   VARCHAR2,
      p_plan_status               IN   VARCHAR2,
      p_readiness_percentage      IN   NUMBER
   )
      RETURN g_rec_type
   IS
--
      l_rec    g_rec_type;
      l_proc   VARCHAR2 (72) := g_package || 'convert_args';
--
   BEGIN
      --
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- Convert arguments into local l_rec structure.
      --
      l_rec.succession_plan_id   := p_succession_plan_id;
      l_rec.person_id            := p_person_id;
      l_rec.position_id          := p_position_id;
      l_rec.business_group_id    := p_business_group_id;
      l_rec.start_date           := p_start_date;
      l_rec.time_scale           := p_time_scale;
      l_rec.end_date             := p_end_date;
      l_rec.available_for_promotion := p_available_for_promotion;
      l_rec.manager_comments     := p_manager_comments;
      l_rec.object_version_number := p_object_version_number;
      l_rec.attribute_category   := p_attribute_category;
      l_rec.attribute1           := p_attribute1;
      l_rec.attribute2           := p_attribute2;
      l_rec.attribute3           := p_attribute3;
      l_rec.attribute4           := p_attribute4;
      l_rec.attribute5           := p_attribute5;
      l_rec.attribute6           := p_attribute6;
      l_rec.attribute7           := p_attribute7;
      l_rec.attribute8           := p_attribute8;
      l_rec.attribute9           := p_attribute9;
      l_rec.attribute10          := p_attribute10;
      l_rec.attribute11          := p_attribute11;
      l_rec.attribute12          := p_attribute12;
      l_rec.attribute13          := p_attribute13;
      l_rec.attribute14          := p_attribute14;
      l_rec.attribute15          := p_attribute15;
      l_rec.attribute16          := p_attribute16;
      l_rec.attribute17          := p_attribute17;
      l_rec.attribute18          := p_attribute18;
      l_rec.attribute19          := p_attribute19;
      l_rec.attribute20          := p_attribute20;
      l_rec.job_id               := p_job_id;
      l_rec.successee_person_id  := p_successee_person_id;
      l_rec.person_rank          := p_person_rank;
      l_rec.PERFORMANCE          := p_performance;
      l_rec.plan_status          := p_plan_status;
      l_rec.readiness_percentage := p_readiness_percentage;
      --
      -- Return the plsql record structure.
      --
      hr_utility.set_location (' Leaving:' || l_proc, 10);
      RETURN (l_rec);
--
   END convert_args;
--
END per_suc_shd;

/
