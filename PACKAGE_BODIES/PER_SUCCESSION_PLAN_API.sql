--------------------------------------------------------
--  DDL for Package Body PER_SUCCESSION_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUCCESSION_PLAN_API" AS
/* $Header: pesucapi.pkb 120.1.12010000.3 2010/02/13 19:28:23 schowdhu ship $ */
--
-- Package Variables
--
   g_package   VARCHAR2 (33) := '  PER_SUCCESSION_PLAN_API.';

--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_succession_plan> >--------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE create_succession_plan (
      p_validate                  IN              BOOLEAN DEFAULT FALSE,
      p_person_id                 IN              NUMBER,
      p_position_id               IN              NUMBER DEFAULT NULL,
      p_business_group_id         IN              NUMBER,
      p_start_date                IN              DATE,
      p_time_scale                IN              VARCHAR2,
      p_end_date                  IN              DATE DEFAULT NULL,
      p_available_for_promotion   IN              VARCHAR2 DEFAULT NULL,
      p_manager_comments          IN              VARCHAR2 DEFAULT NULL,
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
      p_readiness_percentage      IN              NUMBER DEFAULT NULL,
      p_succession_plan_id        OUT NOCOPY      NUMBER,
      p_object_version_number     OUT NOCOPY      NUMBER
   )
   IS
      --
      -- Declare cursors and local variables
      --
      l_succession_plan_id      per_succession_planning.succession_plan_id%TYPE;
      l_object_version_number   per_succession_planning.object_version_number%TYPE;
      l_effective_date          DATE;
      l_start_date              DATE;
      l_end_date                DATE;
      l_proc                    VARCHAR2 (72)              := g_package || 'create_succession_plan';
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      --
      -- Issue a savepoint
      --
      SAVEPOINT create_succession_plan;
      --
      -- Truncate the time portion from all IN date parameters
      --
      l_effective_date           := TRUNC (p_effective_date);
      l_start_date               := TRUNC (p_start_date);
      l_end_date                 := TRUNC (p_end_date);

      --
      -- Call Before Process User Hook
      --
      BEGIN
         per_succession_plan_bk1.create_succession_plan_b
                                           (p_person_id                    => p_person_id,
                                            p_position_id                  => p_position_id,
                                            p_business_group_id            => p_business_group_id,
                                            p_start_date                   => l_start_date,
                                            p_time_scale                   => p_time_scale,
                                            p_end_date                     => l_end_date,
                                            p_available_for_promotion      => p_available_for_promotion,
                                            p_manager_comments             => p_manager_comments,
                                            p_attribute_category           => p_attribute_category,
                                            p_attribute1                   => p_attribute1,
                                            p_attribute2                   => p_attribute2,
                                            p_attribute3                   => p_attribute3,
                                            p_attribute4                   => p_attribute4,
                                            p_attribute5                   => p_attribute5,
                                            p_attribute6                   => p_attribute6,
                                            p_attribute7                   => p_attribute7,
                                            p_attribute8                   => p_attribute8,
                                            p_attribute9                   => p_attribute9,
                                            p_attribute10                  => p_attribute10,
                                            p_attribute11                  => p_attribute11,
                                            p_attribute12                  => p_attribute12,
                                            p_attribute13                  => p_attribute13,
                                            p_attribute14                  => p_attribute14,
                                            p_attribute15                  => p_attribute15,
                                            p_attribute16                  => p_attribute16,
                                            p_attribute17                  => p_attribute17,
                                            p_attribute18                  => p_attribute18,
                                            p_attribute19                  => p_attribute19,
                                            p_attribute20                  => p_attribute20,
                                            p_effective_date               => l_effective_date,
                                            p_job_id                       => p_job_id,
                                            p_successee_person_id          => p_successee_person_id,
                                            p_person_rank                  => p_person_rank,
                                            p_performance                  => p_performance,
                                            p_plan_status                  => p_plan_status,
                                            p_readiness_percentage         => p_readiness_percentage
                                           );
      EXCEPTION
         WHEN hr_api.cannot_find_prog_unit
         THEN
            hr_api.cannot_find_prog_unit_error (p_module_name      => 'create_succession_plan',
                                                p_hook_type        => 'BP'
                                               );
      END;

      --
      -- Validation in addition to Row Handlers
      --

      --
      -- Process Logic
      --
      hr_utility.set_location ('Entering:' || 'per_suc_ins.ins', 50);
      per_suc_ins.ins (p_succession_plan_id           => l_succession_plan_id,
                       p_person_id                    => p_person_id,
                       p_position_id                  => p_position_id,
                       p_business_group_id            => p_business_group_id,
                       p_start_date                   => l_start_date,
                       p_time_scale                   => p_time_scale,
                       p_end_date                     => l_end_date,
                       p_available_for_promotion      => p_available_for_promotion,
                       p_manager_comments             => p_manager_comments,
                       p_object_version_number        => l_object_version_number,
                       p_attribute_category           => p_attribute_category,
                       p_attribute1                   => p_attribute1,
                       p_attribute2                   => p_attribute2,
                       p_attribute3                   => p_attribute3,
                       p_attribute4                   => p_attribute4,
                       p_attribute5                   => p_attribute5,
                       p_attribute6                   => p_attribute6,
                       p_attribute7                   => p_attribute7,
                       p_attribute8                   => p_attribute8,
                       p_attribute9                   => p_attribute9,
                       p_attribute10                  => p_attribute10,
                       p_attribute11                  => p_attribute11,
                       p_attribute12                  => p_attribute12,
                       p_attribute13                  => p_attribute13,
                       p_attribute14                  => p_attribute14,
                       p_attribute15                  => p_attribute15,
                       p_attribute16                  => p_attribute16,
                       p_attribute17                  => p_attribute17,
                       p_attribute18                  => p_attribute18,
                       p_attribute19                  => p_attribute19,
                       p_attribute20                  => p_attribute20,
                       p_effective_date               => l_effective_date,
                       p_job_id                       => p_job_id,
                       p_successee_person_id          => p_successee_person_id,
                       p_person_rank                  => p_person_rank,
                       p_performance                  => p_performance,
                       p_plan_status                  => p_plan_status,
                       p_readiness_percentage         => p_readiness_percentage
                      );
      hr_utility.set_location ('Entering:' || 'PER_SUCCESSION_PLAN_BK1.create_succession_plan_a',
                               60);

      --
      -- Call After Process User Hook
      --
      BEGIN
         per_succession_plan_bk1.create_succession_plan_a
                                           (p_person_id                    => p_person_id,
                                            p_position_id                  => p_position_id,
                                            p_business_group_id            => p_business_group_id,
                                            p_start_date                   => l_start_date,
                                            p_time_scale                   => p_time_scale,
                                            p_end_date                     => l_end_date,
                                            p_available_for_promotion      => p_available_for_promotion,
                                            p_manager_comments             => p_manager_comments,
                                            p_attribute_category           => p_attribute_category,
                                            p_attribute1                   => p_attribute1,
                                            p_attribute2                   => p_attribute2,
                                            p_attribute3                   => p_attribute3,
                                            p_attribute4                   => p_attribute4,
                                            p_attribute5                   => p_attribute5,
                                            p_attribute6                   => p_attribute6,
                                            p_attribute7                   => p_attribute7,
                                            p_attribute8                   => p_attribute8,
                                            p_attribute9                   => p_attribute9,
                                            p_attribute10                  => p_attribute10,
                                            p_attribute11                  => p_attribute11,
                                            p_attribute12                  => p_attribute12,
                                            p_attribute13                  => p_attribute13,
                                            p_attribute14                  => p_attribute14,
                                            p_attribute15                  => p_attribute15,
                                            p_attribute16                  => p_attribute16,
                                            p_attribute17                  => p_attribute17,
                                            p_attribute18                  => p_attribute18,
                                            p_attribute19                  => p_attribute19,
                                            p_attribute20                  => p_attribute20,
                                            p_effective_date               => l_effective_date,
                                            p_job_id                       => p_job_id,
                                            p_successee_person_id          => p_successee_person_id,
                                            p_person_rank                  => p_person_rank,
                                            p_performance                  => p_performance,
                                            p_plan_status                  => p_plan_status,
                                            p_readiness_percentage         => p_readiness_percentage,
                                            p_succession_plan_id           => l_succession_plan_id,
                                            p_object_version_number        => l_object_version_number
                                           );
      EXCEPTION
         WHEN hr_api.cannot_find_prog_unit
         THEN
            hr_api.cannot_find_prog_unit_error (p_module_name      => 'create_succession_plan',
                                                p_hook_type        => 'AP'
                                               );
      END;

      --
      -- When in validation only mode raise the Validate_Enabled exception
      --
      IF p_validate
      THEN
         RAISE hr_api.validate_enabled;
      END IF;

      --
      -- Set all IN OUT and OUT parameters with out values
      --
      p_succession_plan_id       := l_succession_plan_id;
      p_object_version_number    := l_object_version_number;
      --
      hr_utility.set_location (' Leaving:' || l_proc, 70);
   EXCEPTION
      WHEN hr_api.validate_enabled
      THEN
         --
         -- As the Validate_Enabled exception has been raised
         -- we must rollback to the savepoint
         --
         ROLLBACK TO create_succession_plan;
         --
         -- Reset IN OUT parameters and set OUT parameters
         -- (Any key or derived arguments must be set to null
         -- when validation only mode is being used.)
         --
         p_succession_plan_id       := NULL;
         p_object_version_number    := NULL;
         hr_utility.set_location (' Leaving:' || l_proc, 80);
      WHEN OTHERS
      THEN
         --
         -- A validation or unexpected error has occured
         --
         ROLLBACK TO create_succession_plan;
         --
         -- Reset IN OUT parameters and set all
         -- OUT parameters, including warnings, to null
         --
         p_succession_plan_id       := NULL;
         p_object_version_number    := NULL;
         hr_utility.set_location (' Leaving:' || l_proc, 90);
         RAISE;
   END create_succession_plan;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< <update_succession_plan> >--------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE update_succession_plan (
      p_validate                  IN              BOOLEAN DEFAULT FALSE,
      p_succession_plan_id        IN              NUMBER,
      p_person_id                 IN              NUMBER DEFAULT hr_api.g_number,
      p_position_id               IN              NUMBER DEFAULT hr_api.g_number,
      p_business_group_id         IN              NUMBER DEFAULT hr_api.g_number,
      p_start_date                IN              DATE DEFAULT hr_api.g_date,
      p_time_scale                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_end_date                  IN              DATE DEFAULT hr_api.g_date,
      p_available_for_promotion   IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_manager_comments          IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
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
      p_effective_date            IN              DATE,
      p_job_id                    IN              NUMBER DEFAULT hr_api.g_number,
      p_successee_person_id       IN              NUMBER DEFAULT hr_api.g_number,
      p_person_rank               IN              NUMBER DEFAULT hr_api.g_number,
      p_performance               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_plan_status               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_readiness_percentage      IN              NUMBER  DEFAULT hr_api.g_number,
      p_object_version_number     IN OUT NOCOPY   NUMBER
   )
   IS
      --
      -- Declare cursors and local variables
      --
      l_succession_plan_id      per_succession_planning.succession_plan_id%TYPE;
      l_object_version_number   per_succession_planning.object_version_number%TYPE;
      l_ovn                     per_objectives.object_version_number%TYPE
                                                                         := p_object_version_number;
      l_effective_date          DATE;
      l_start_date              DATE;
      l_end_date                DATE;
      l_proc                    VARCHAR2 (72)              := g_package || 'update_succession_plan';
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      --
      -- Issue a savepoint
      --
      SAVEPOINT update_succession_plan;
      --
      -- Initialise local variables as appropriate
      --
      l_object_version_number    := p_object_version_number;
      --
      -- Truncate the time portion from all IN date parameters
      --
      l_effective_date           := TRUNC (p_effective_date);
      l_start_date               := TRUNC (p_start_date);
      l_end_date                 := TRUNC (p_end_date);

      --
      -- Call Before Process User Hook
      --
      BEGIN
         per_succession_plan_bk2.update_succession_plan_b
                                           (p_person_id                    => p_person_id,
                                            p_position_id                  => p_position_id,
                                            p_business_group_id            => p_business_group_id,
                                            p_start_date                   => l_start_date,
                                            p_time_scale                   => p_time_scale,
                                            p_end_date                     => l_end_date,
                                            p_available_for_promotion      => p_available_for_promotion,
                                            p_manager_comments             => p_manager_comments,
                                            p_attribute_category           => p_attribute_category,
                                            p_attribute1                   => p_attribute1,
                                            p_attribute2                   => p_attribute2,
                                            p_attribute3                   => p_attribute3,
                                            p_attribute4                   => p_attribute4,
                                            p_attribute5                   => p_attribute5,
                                            p_attribute6                   => p_attribute6,
                                            p_attribute7                   => p_attribute7,
                                            p_attribute8                   => p_attribute8,
                                            p_attribute9                   => p_attribute9,
                                            p_attribute10                  => p_attribute10,
                                            p_attribute11                  => p_attribute11,
                                            p_attribute12                  => p_attribute12,
                                            p_attribute13                  => p_attribute13,
                                            p_attribute14                  => p_attribute14,
                                            p_attribute15                  => p_attribute15,
                                            p_attribute16                  => p_attribute16,
                                            p_attribute17                  => p_attribute17,
                                            p_attribute18                  => p_attribute18,
                                            p_attribute19                  => p_attribute19,
                                            p_attribute20                  => p_attribute20,
                                            p_effective_date               => l_effective_date,
                                            p_job_id                       => p_job_id,
                                            p_successee_person_id          => p_successee_person_id,
                                            p_person_rank                  => p_person_rank,
                                            p_performance                  => p_performance,
                                            p_plan_status                  => p_plan_status,
                                            p_readiness_percentage         => p_readiness_percentage,
                                            p_succession_plan_id           => p_succession_plan_id,
                                            p_object_version_number        => p_object_version_number
                                           );
      EXCEPTION
         WHEN hr_api.cannot_find_prog_unit
         THEN
            hr_api.cannot_find_prog_unit_error (p_module_name      => 'update_succession_plan',
                                                p_hook_type        => 'BP'
                                               );
      END;

      --
      -- Validation in addition to Row Handlers
      --
      --
      -- Process Logic
      --
      hr_utility.set_location ('Entering:' || 'per_suc_upd.upd', 50);
      per_suc_upd.upd (p_succession_plan_id           => p_succession_plan_id,
                       p_person_id                    => p_person_id,
                       p_position_id                  => p_position_id,
                       p_business_group_id            => p_business_group_id,
                       p_start_date                   => l_start_date,
                       p_time_scale                   => p_time_scale,
                       p_end_date                     => l_end_date,
                       p_available_for_promotion      => p_available_for_promotion,
                       p_manager_comments             => p_manager_comments,
                       p_object_version_number        => l_object_version_number,
                       p_attribute_category           => p_attribute_category,
                       p_attribute1                   => p_attribute1,
                       p_attribute2                   => p_attribute2,
                       p_attribute3                   => p_attribute3,
                       p_attribute4                   => p_attribute4,
                       p_attribute5                   => p_attribute5,
                       p_attribute6                   => p_attribute6,
                       p_attribute7                   => p_attribute7,
                       p_attribute8                   => p_attribute8,
                       p_attribute9                   => p_attribute9,
                       p_attribute10                  => p_attribute10,
                       p_attribute11                  => p_attribute11,
                       p_attribute12                  => p_attribute12,
                       p_attribute13                  => p_attribute13,
                       p_attribute14                  => p_attribute14,
                       p_attribute15                  => p_attribute15,
                       p_attribute16                  => p_attribute16,
                       p_attribute17                  => p_attribute17,
                       p_attribute18                  => p_attribute18,
                       p_attribute19                  => p_attribute19,
                       p_attribute20                  => p_attribute20,
                       p_effective_date               => l_effective_date,
                       p_job_id                       => p_job_id,
                       p_successee_person_id          => p_successee_person_id,
                       p_person_rank                  => p_person_rank,
                       p_performance                  => p_performance,
                       p_plan_status                  => p_plan_status,
                       p_readiness_percentage         => p_readiness_percentage
                      );
      hr_utility.set_location ('Entering:' || 'PER_SUCCESSION_PLAN_BK1.update_succession_plan_a',
                               60);

      --
      -- Call After Process User Hook
      --
      BEGIN
         per_succession_plan_bk2.update_succession_plan_a
                                           (p_person_id                    => p_person_id,
                                            p_position_id                  => p_position_id,
                                            p_business_group_id            => p_business_group_id,
                                            p_start_date                   => l_start_date,
                                            p_time_scale                   => p_time_scale,
                                            p_end_date                     => l_end_date,
                                            p_available_for_promotion      => p_available_for_promotion,
                                            p_manager_comments             => p_manager_comments,
                                            p_attribute_category           => p_attribute_category,
                                            p_attribute1                   => p_attribute1,
                                            p_attribute2                   => p_attribute2,
                                            p_attribute3                   => p_attribute3,
                                            p_attribute4                   => p_attribute4,
                                            p_attribute5                   => p_attribute5,
                                            p_attribute6                   => p_attribute6,
                                            p_attribute7                   => p_attribute7,
                                            p_attribute8                   => p_attribute8,
                                            p_attribute9                   => p_attribute9,
                                            p_attribute10                  => p_attribute10,
                                            p_attribute11                  => p_attribute11,
                                            p_attribute12                  => p_attribute12,
                                            p_attribute13                  => p_attribute13,
                                            p_attribute14                  => p_attribute14,
                                            p_attribute15                  => p_attribute15,
                                            p_attribute16                  => p_attribute16,
                                            p_attribute17                  => p_attribute17,
                                            p_attribute18                  => p_attribute18,
                                            p_attribute19                  => p_attribute19,
                                            p_attribute20                  => p_attribute20,
                                            p_effective_date               => l_effective_date,
                                            p_job_id                       => p_job_id,
                                            p_successee_person_id          => p_successee_person_id,
                                            p_person_rank                  => p_person_rank,
                                            p_performance                  => p_performance,
                                            p_plan_status                  => p_plan_status,
                                            p_readiness_percentage         => p_readiness_percentage,
                                            p_succession_plan_id           => l_succession_plan_id,
                                            p_object_version_number        => l_object_version_number
                                           );
      EXCEPTION
         WHEN hr_api.cannot_find_prog_unit
         THEN
            hr_api.cannot_find_prog_unit_error (p_module_name      => 'update_succession_plan',
                                                p_hook_type        => 'AP'
                                               );
      END;

      --
      -- When in validation only mode raise the Validate_Enabled exception
      --
      IF p_validate
      THEN
         RAISE hr_api.validate_enabled;
      END IF;

      --
      -- Set all IN OUT and OUT parameters with out values
      --
      p_object_version_number    := l_object_version_number;
      --
      hr_utility.set_location (' Leaving:' || l_proc, 70);
   EXCEPTION
      WHEN hr_api.validate_enabled
      THEN
         --
         -- As the Validate_Enabled exception has been raised
         -- we must rollback to the savepoint
         --
         ROLLBACK TO update_succession_plan;
         --
         -- Reset IN OUT parameters and set OUT parameters
         -- (Any key or derived arguments must be set to null
         -- when validation only mode is being used.)
         --
         p_object_version_number    := l_ovn;
         hr_utility.set_location (' Leaving:' || l_proc, 80);
      WHEN OTHERS
      THEN
         --
         -- A validation or unexpected error has occured
         --
         ROLLBACK TO update_succession_plan;
         --
         -- Reset IN OUT parameters and set all
         -- OUT parameters, including warnings, to null
         --
         p_object_version_number    := l_ovn;
         hr_utility.set_location (' Leaving:' || l_proc, 90);
         RAISE;
   END update_succession_plan;

--
-- ---------------------------------------------------------------------------
-- |-------------------------< delete_succession_plan> ----------------------------|
-- ---------------------------------------------------------------------------
--
   PROCEDURE delete_succession_plan (
      p_validate                IN   BOOLEAN DEFAULT FALSE,
      p_succession_plan_id      IN   NUMBER,
      p_object_version_number   IN   NUMBER
   )
   IS
      --
      -- Declare cursors and local variables
      --

      --
      --
      l_proc   VARCHAR2 (72) := g_package || 'delete_succession_plan';
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 5);
      --
      -- Issue a savepoint
      --
      SAVEPOINT delete_succession_plan;

      --
      BEGIN
         --
         -- Start of API User Hook for the before hook delete_objective
         --
         per_succession_plan_bk3.delete_succession_plan_b
                                                (p_succession_plan_id         => p_succession_plan_id,
                                                 p_object_version_number      => p_object_version_number
                                                );
      EXCEPTION
         WHEN hr_api.cannot_find_prog_unit
         THEN
            hr_api.cannot_find_prog_unit_error (p_module_name      => 'delete_succession_plan',
                                                p_hook_type        => 'BP'
                                               );
      END;

      --
      -- End of API User Hook for the before hook of delete_objective
      --
      hr_utility.set_location (l_proc, 6);
      --
      -- Validation in addition to Table Handlers
      --
      hr_utility.set_location (l_proc, 7);
      --
      -- Process Logic
      --
      -- flemonni added cascade delete of obj performance rating
      --
      -- get an associated pr for the given obj id
      -- supply this to the pr api (p_validate = TRUE)
      -- delete it so that obj delete succeeds
      -- allow this rollback to undo the delete if necessary
      --

      --
      --  delete the succession plan
      --
      per_suc_del.del (p_succession_plan_id         => p_succession_plan_id,
                       p_object_version_number      => p_object_version_number
                      );
      --
      hr_utility.set_location (l_proc, 8);

      --
      BEGIN
         --
         -- Start of API User Hook for the after hook delete_objective
         --
         per_succession_plan_bk3.delete_succession_plan_a
                                                (p_succession_plan_id         => p_succession_plan_id,
                                                 p_object_version_number      => p_object_version_number
                                                );
      EXCEPTION
         WHEN hr_api.cannot_find_prog_unit
         THEN
            hr_api.cannot_find_prog_unit_error (p_module_name      => 'delete_succession_plan',
                                                p_hook_type        => 'AP'
                                               );
      END;

        --
        -- End of API User Hook for the after hook delete_objective
        --
      -- When in validation only mode raise the Validate_Enabled exception
      --
      IF p_validate
      THEN
         RAISE hr_api.validate_enabled;
      END IF;

      --
      hr_utility.set_location (' Leaving:' || l_proc, 11);
   EXCEPTION
      WHEN hr_api.validate_enabled
      THEN
         --
         -- As the Validate_Enabled exception has been raised
         -- we must rollback to the savepoint
         --
         ROLLBACK TO delete_succession_plan;
         --
         -- Only set output warning arguments
         -- (Any key or derived arguments must be set to null
         -- when validation only mode is being used.)
         --
         hr_utility.set_location (' Leaving:' || l_proc, 12);
      --
      WHEN OTHERS
      THEN
         --
         -- A validation or unexpected error has occured
         --
         ROLLBACK TO delete_succession_plan;
         --
         RAISE;
   --
   END delete_succession_plan;
--
--
END per_succession_plan_api;

/
