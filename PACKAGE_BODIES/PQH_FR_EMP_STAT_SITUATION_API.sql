--------------------------------------------------------
--  DDL for Package Body PQH_FR_EMP_STAT_SITUATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_EMP_STAT_SITUATION_API" as
/* $Header: pqpsuapi.pkb 120.0 2005/05/29 02:19:33 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_FR_EMP_STAT_SITUATION_API.';
--
--
--
  PROCEDURE update_assignments(p_person_id              IN NUMBER
                              ,p_emp_stat_situation_id  IN NUMBER DEFAULT NULL
                              ,p_statutory_situation_id IN NUMBER
                              ,p_start_date             IN DATE
                              ,p_end_date               IN DATE   DEFAULT NULL)
  IS
  --
  --Cursor Declaration
  --Cursor to fetch Statutory Situation Details.
    CURSOR csr_situation_details(p_statutory_situation_id IN NUMBER) IS
    SELECT situation_type,
           sub_type,
           NVL(reserve_position,'N')             reserve_position,
           NVL(remuneration_paid,'N')            remuneration_paid,
           NVL(renewable_allowed,'N')            renewable_allowed,
           NVL(default_flag,'N')                 default_flag,
           NVL(allow_progression_flag,'N')       allow_progression_flag,
           NVL(extend_probation_period_flag,'N') extend_probation_period_flag,
           NVL(remunerate_assign_status_id,-1)   remunerate_assign_status_id
      FROM pqh_fr_stat_situations
     WHERE statutory_situation_id = p_statutory_situation_id;
  --
  --Cursor to fetch Assignment Details.
    CURSOR csr_career_dtls(p_person_id IN NUMBER,p_eff_date IN DATE) IS
    SELECT asg.assignment_id,
           asg.assignment_type,
           asg.effective_start_date,
           asg.effective_end_date,
           asg.assignment_status_type_id,
           ast.per_system_status,
           ast.pay_system_status,
           asg.object_version_number
      FROM per_all_assignments_f       asg,
           per_assignment_status_types ast
     WHERE asg.person_id                 = p_person_id
       AND p_eff_date              BETWEEN asg.effective_start_date AND asg.effective_end_date
       AND asg.primary_flag              = 'Y'
       AND asg.assignment_status_type_id = ast.assignment_status_type_id;
  --
  --Cursor to fetch Affectation details.
    CURSOR csr_affectations(p_career_id IN NUMBER,p_per_status IN VARCHAR2,p_aff_st_date IN DATE,p_aff_end_date IN DATE) IS
    SELECT assignment_id,
           effective_start_date,
           effective_end_date,
           assignment_type,
           asg.object_version_number
      FROM per_all_assignments_f       asg,
           hr_soft_coding_keyflex      scl,
           per_assignment_status_types ast
     WHERE asg.soft_coding_keyflex_id     = scl.soft_coding_keyflex_id
       AND scl.segment26                  = p_career_id
       AND asg.assignment_status_type_id  = ast.assignment_status_type_id
       AND ast.per_system_status          = p_per_status
       AND(p_aff_st_date            BETWEEN asg.effective_start_date AND asg.effective_end_date
        OR asg.effective_start_date BETWEEN p_aff_st_date AND NVL(p_aff_end_date,p_aff_st_date))
     ORDER BY effective_start_date;
  --
  --Cursor to check if Affectation Assignment is Terminated in Future.
    CURSOR csr_invalid_term_assign(p_affect_asg_id IN NUMBER,
                                   p_term_st_dt    IN DATE) IS
    SELECT 'Y'
      FROM per_all_assignments_f       asg,
           per_assignment_status_types ast
     where asg.assignment_id             =  p_affect_asg_id
       and asg.effective_end_date        >= p_term_st_dt
       and ast.assignment_status_type_id =  asg.assignment_status_type_id
       and ast.per_system_status         =  'TERM_ASSIGN';
  --
  --Variable Declarations
    lr_career_rec          csr_career_dtls%ROWTYPE;
    lr_sit_dtls            csr_situation_details%ROWTYPE;
    l_dt_mode              VARCHAR2(100);
    l_career_ovn           NUMBER(9);
    l_career_esd           DATE;
    l_career_eed           DATE;
    l_affect_ovn           NUMBER(9);
    l_affect_asg_id        NUMBER(15);
    l_affect_esd           DATE;
    l_affect_eed           DATE;
    l_warn_future_changes  BOOLEAN;
    l_warn_entries_changed VARCHAR2(1000);
    l_warn_pay_proposal    BOOLEAN;
    l_eff_dt               DATE;
    l_term_exists          VARCHAR2(1);
    l_proc                 VARCHAR2(72) := g_package||'update_assignments';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'|| l_proc, 10);
    OPEN csr_situation_details(p_statutory_situation_id);
    FETCH csr_situation_details INTO lr_sit_dtls.situation_type,
                                     lr_sit_dtls.sub_type,
                                     lr_sit_dtls.reserve_position,
                                     lr_sit_dtls.remuneration_paid,
                                     lr_sit_dtls.renewable_allowed,
                                     lr_sit_dtls.default_flag,
                                     lr_sit_dtls.allow_progression_flag,
                                     lr_sit_dtls.extend_probation_period_flag,
                                     lr_sit_dtls.remunerate_assign_status_id;
    IF csr_situation_details%NOTFOUND THEN
       CLOSE csr_situation_details;
       FND_MESSAGE.set_name('PQH','FR_PQH_STAT_SIT_INVALID_SIT');
       FND_MESSAGE.raise_error;
    END IF;
    CLOSE csr_situation_details;
  --
    OPEN csr_career_dtls(p_person_id,p_start_date);
    FETCH csr_career_dtls INTO lr_career_rec.assignment_id,
                               lr_career_rec.assignment_type,
                               lr_career_rec.effective_start_date,
                               lr_career_rec.effective_end_date,
                               lr_career_rec.assignment_status_type_id,
                               lr_career_rec.per_system_status,
                               lr_career_rec.pay_system_status,
                               lr_career_rec.object_version_number;
    CLOSE csr_career_dtls;
  --
    l_career_ovn  := lr_career_rec.object_version_number;
  --
  --Check if Situation is a Reinstate situation.
    IF lr_sit_dtls.situation_type = 'IA' AND lr_sit_dtls.sub_type = 'IA_N' THEN
     --
     --Activate all affectations that were suspended by earlier situation.
       FOR lr_affectations IN csr_affectations(lr_career_rec.assignment_id,'SUSP_ASSIGN',p_start_date,p_end_date)
       LOOP
         --
           IF lr_affectations.effective_start_date > p_start_date THEN
              l_eff_dt := lr_affectations.effective_start_date;
           ELSE
              l_eff_dt := p_start_date;
           END IF;
           l_affect_asg_id := lr_affectations.assignment_id;
           l_affect_ovn    := lr_affectations.object_version_number;
           l_dt_mode := pqh_fr_utility.get_datetrack_mode(p_effective_date  => l_eff_dt
                                                         ,p_base_table_name => 'PER_ALL_ASSIGNMENTS_F'
                                                         ,p_base_key_column => 'ASSIGNMENT_ID'
                                                         ,p_base_key_value  => l_affect_asg_id);
         --
           IF lr_affectations.assignment_type = 'E' THEN
            --
              hr_assignment_api.activate_emp_asg(p_effective_date        => l_eff_dt
                                                ,p_datetrack_update_mode => l_dt_mode
                                                ,p_assignment_id         => l_affect_asg_id
                                                ,p_object_version_number => l_affect_ovn
                                                ,p_effective_start_date  => l_affect_esd
                                                ,p_effective_end_date    => l_affect_eed);
            --
           ELSIF lr_affectations.assignment_type = 'C' THEN
            --
              hr_assignment_api.activate_cwk_asg(p_effective_date        => l_eff_dt
                                                ,p_datetrack_update_mode => l_dt_mode
                                                ,p_assignment_id         => l_affect_asg_id
                                                ,p_object_version_number => l_affect_ovn
                                                ,p_effective_start_date  => l_affect_esd
                                                ,p_effective_end_date    => l_affect_eed);
            --
           END IF;
         --
       END LOOP;
     --
       l_dt_mode := pqh_fr_utility.get_datetrack_mode(p_effective_date  => p_start_date
                                                     ,p_base_table_name => 'PER_ALL_ASSIGNMENTS_F'
                                                     ,p_base_key_column => 'ASSIGNMENT_ID'
                                                     ,p_base_key_value  => lr_career_rec.assignment_id);
     --
       IF lr_career_rec.assignment_type = 'C' THEN
        --
          hr_assignment_api.activate_cwk_asg(p_effective_date        => p_start_date
                                            ,p_datetrack_update_mode => l_dt_mode
                                            ,p_assignment_id         => lr_career_rec.assignment_id
                                            ,p_object_version_number => l_career_ovn
                                            ,p_effective_start_date  => l_career_esd
                                            ,p_effective_end_date    => l_career_eed);
        --
       ELSIF lr_career_rec.assignment_type = 'E' THEN
        --
          hr_assignment_api.activate_emp_asg(p_effective_date        => p_start_date
                                            ,p_datetrack_update_mode => l_dt_mode
                                            ,p_assignment_id         => lr_career_rec.assignment_id
                                            ,p_object_version_number => l_career_ovn
                                            ,p_effective_start_date  => l_career_esd
                                            ,p_effective_end_date    => l_career_eed);
        --
       END IF;
     --
    ELSE --Terminate or Suspend assignment if Situation is not In Activity Normal.
     --
       FOR lr_affectations IN csr_affectations(lr_career_rec.assignment_id,'ACTIVE_ASSIGN',p_start_date,p_end_date)
       LOOP
       --
       --Added below condition because assignment status cannot be changed if it is effective for one day only.
         IF TRUNC(lr_affectations.effective_start_date) <> TRUNC(lr_affectations.effective_end_date) THEN
         --Added below condition because if Affectation starts after the Primary Assignment Start Dt
         --then we want to Terminate or Suspend Assignment from its Effective Start Date.
           IF lr_affectations.effective_start_date > p_start_date THEN
              l_eff_dt := lr_affectations.effective_start_date;
           ELSE
              l_eff_dt := p_start_date;
           END IF;
           l_affect_asg_id := lr_affectations.assignment_id;
           l_affect_ovn    := lr_affectations.object_version_number;
           l_dt_mode := pqh_fr_utility.get_datetrack_mode(p_effective_date  => l_eff_dt
                                                         ,p_base_table_name => 'PER_ALL_ASSIGNMENTS_F'
                                                         ,p_base_key_column => 'ASSIGNMENT_ID'
                                                         ,p_base_key_value  => lr_affectations.assignment_id);
         --
           IF lr_affectations.assignment_type = 'E' THEN
            --
              IF lr_sit_dtls.reserve_position = 'Y' THEN
               --
                 hr_assignment_api.suspend_emp_asg(p_effective_date        => l_eff_dt
                                                  ,p_datetrack_update_mode => l_dt_mode
                                                  ,p_assignment_id         => l_affect_asg_id
                                                  ,p_object_version_number => l_affect_ovn
                                                  ,p_effective_start_date  => l_affect_esd
                                                  ,p_effective_end_date    => l_affect_eed);
               --
              ELSIF lr_sit_dtls.reserve_position = 'N' THEN
               --
               --Added below condition because API terminates Assignment one day after requested effective date.
                 IF l_eff_dt = p_start_date THEN
                    l_eff_dt := TRUNC(p_start_date-1);
                 END IF;
               --
               --Check whether the Affectation being terminated is not already terminated in future.
                 OPEN csr_invalid_term_assign(l_affect_asg_id,l_eff_dt);
                 FETCH csr_invalid_term_assign into l_term_exists;
                 IF csr_invalid_term_assign%FOUND THEN
                    CLOSE csr_invalid_term_assign;
                    FND_MESSAGE.set_name('PQH','FR_PQH_AFFECT_TERM_IN_FUTURE');
                    FND_MESSAGE.raise_error;
                 ELSE
                    CLOSE csr_invalid_term_assign;
                 END IF;
               --
                 hr_assignment_api.actual_termination_emp_asg
                                  (p_assignment_id              => l_affect_asg_id
                                  ,p_object_version_number      => l_affect_ovn
                                  ,p_actual_termination_date    => TRUNC(l_eff_dt)
                                  ,p_effective_start_date       => l_affect_esd
                                  ,p_effective_end_date         => l_affect_eed
                                  ,p_asg_future_changes_warning => l_warn_future_changes
                                  ,p_entries_changed_warning    => l_warn_entries_changed
                                  ,p_pay_proposal_warning       => l_warn_pay_proposal);
               --
              END IF;
            --
           ELSIF lr_affectations.assignment_type = 'C' THEN
            --
              IF lr_sit_dtls.reserve_position = 'Y' THEN
               --
                 hr_assignment_api.suspend_cwk_asg(p_effective_date        => l_eff_dt
                                                  ,p_datetrack_update_mode => l_dt_mode
                                                  ,p_assignment_id         => l_affect_asg_id
                                                  ,p_object_version_number => l_affect_ovn
                                                  ,p_effective_start_date  => l_affect_esd
                                                  ,p_effective_end_date    => l_affect_eed);
               --
              ELSIF lr_sit_dtls.reserve_position = 'N' THEN
               --
               --Added below condition because API terminates Assignment one day after requested effective date.
                 IF l_eff_dt = p_start_date THEN
                    l_eff_dt := TRUNC(p_start_date-1);
                 END IF;
                 hr_assignment_api.actual_termination_emp_asg(p_assignment_id              => l_affect_asg_id
                                                             ,p_object_version_number      => l_affect_ovn
                                                             ,p_actual_termination_date    => TRUNC(l_eff_dt)
                                                             ,p_effective_start_date       => l_affect_esd
                                                             ,p_effective_end_date         => l_affect_eed
                                                             ,p_asg_future_changes_warning => l_warn_future_changes
                                                             ,p_entries_changed_warning    => l_warn_entries_changed
                                                             ,p_pay_proposal_warning       => l_warn_pay_proposal);
               --
              END IF;
            --
           END IF;
         --
         END IF;
         --
       END LOOP;
     --
       l_dt_mode := pqh_fr_utility.get_datetrack_mode(p_effective_date  => p_start_date
                                                     ,p_base_table_name => 'PER_ALL_ASSIGNMENTS_F'
                                                     ,p_base_key_column => 'ASSIGNMENT_ID'
                                                     ,p_base_key_value  => lr_career_rec.assignment_id);
     --
       IF lr_sit_dtls.remuneration_paid = 'Y' AND lr_sit_dtls.remunerate_assign_status_id = -1 THEN
          FND_MESSAGE.set_name('PQH','FR_PQH_NO_REMU_ASG_STAT');
          FND_MESSAGE.raise_error;
       ELSIF lr_sit_dtls.remuneration_paid = 'Y' AND lr_sit_dtls.remunerate_assign_status_id <> -1 THEN
        --
          IF lr_career_rec.assignment_type = 'C' THEN
           --
             hr_assignment_api.suspend_cwk_asg
                              (p_effective_date            => p_start_date
                              ,p_datetrack_update_mode     => l_dt_mode
                              ,p_assignment_id             => lr_career_rec.assignment_id
                              ,p_object_version_number     => l_career_ovn
                              ,p_assignment_status_type_id => lr_sit_dtls.remunerate_assign_status_id
                              ,p_effective_start_date      => l_career_esd
                              ,p_effective_end_date        => l_career_eed);
           --
          ELSIF lr_career_rec.assignment_type = 'E' THEN
           --
             hr_assignment_api.suspend_emp_asg
                              (p_effective_date            => p_start_date
                              ,p_datetrack_update_mode     => l_dt_mode
                              ,p_assignment_id             => lr_career_rec.assignment_id
                              ,p_object_version_number     => l_career_ovn
                              ,p_assignment_status_type_id => lr_sit_dtls.remunerate_assign_status_id
                              ,p_effective_start_date      => l_career_esd
                              ,p_effective_end_date        => l_career_eed);
           --
          END IF;
        --
       ELSE
        --
          IF lr_career_rec.assignment_type = 'C' THEN
           --
             hr_assignment_api.suspend_cwk_asg
                              (p_effective_date            => p_start_date
                              ,p_datetrack_update_mode     => l_dt_mode
                              ,p_assignment_id             => lr_career_rec.assignment_id
                              ,p_object_version_number     => l_career_ovn
                              ,p_effective_start_date      => l_career_esd
                              ,p_effective_end_date        => l_career_eed);
           --
          ELSIF lr_career_rec.assignment_type = 'E' THEN
           --
             hr_assignment_api.suspend_emp_asg
                              (p_effective_date            => p_start_date
                              ,p_datetrack_update_mode     => l_dt_mode
                              ,p_assignment_id             => lr_career_rec.assignment_id
                              ,p_object_version_number     => l_career_ovn
                              ,p_effective_start_date      => l_career_esd
                              ,p_effective_end_date        => l_career_eed);
           --
          END IF;
        --
       END IF;
     --
    END IF;
  --
  END update_assignments;
  --
--
-- ----------------------------------------------------------------------------
-- |------------------------< CREATE_EMP_STAT_SITUATION >----------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_EMP_STAT_SITUATION
  (p_validate                      IN     boolean  default false
  ,p_effective_date                IN     date
  ,P_STATUTORY_SITUATION_ID        IN     NUMBER
  ,P_PERSON_ID                     IN     NUMBER
  ,P_PROVISIONAL_START_DATE        IN     DATE
  ,P_PROVISIONAL_END_DATE          IN     DATE
  ,P_ACTUAL_START_DATE             IN     DATE     default null
  ,P_ACTUAL_END_DATE               IN     DATE     default null
  ,P_APPROVAL_FLAG                 IN     VARCHAR2 default null
  ,P_COMMENTS                      IN     VARCHAR2 default null
  ,P_CONTACT_PERSON_ID             IN     NUMBER   default null
  ,P_CONTACT_RELATIONSHIP          IN     VARCHAR2 default null
  ,P_EXTERNAL_ORGANIZATION_ID      IN     NUMBER   default null
  ,P_RENEWAL_FLAG                  IN     VARCHAR2 default null
  ,P_RENEW_STAT_SITUATION_ID       IN     NUMBER   default null
  ,P_SECONDED_CAREER_ID            IN     NUMBER   default null
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2 default null
  ,P_ATTRIBUTE1                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE2                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE3                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE4                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE5                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE6                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE7                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE8                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE9                    IN     VARCHAR2 default null
  ,P_ATTRIBUTE10                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE11                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE12                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE13                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE14                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE15                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE16                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE17                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE18                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE19                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE20                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE21                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE22                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE23                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE24                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE25                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE26                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE27                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE28                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE29                   IN     VARCHAR2 default null
  ,P_ATTRIBUTE30                   IN     VARCHAR2 default null
  ,P_EMP_STAT_SITUATION_ID         OUT NOCOPY     NUMBER
  ,P_OBJECT_VERSION_NUMBER         OUT NOCOPY     NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_emp_stat_situation_id  NUMBER(15);
  l_object_version_number  NUMBER(9);
  l_actual_start_date      DATE;
  l_proc                varchar2(72) := g_package||'create_emp_stat_situation';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  savepoint create_emp_stat_situation;
  --
  -- Validation in addition to Row Handlers
  --
    If (P_APPROVAL_FLAG = 'Y') Then
    l_actual_start_date := p_provisional_start_date;
  Else
    l_actual_start_date := P_ACTUAL_START_DATE;
  End if;
  pqh_psu_ins.ins(
   P_EFFECTIVE_DATE                             => p_effective_date
  ,P_STATUTORY_SITUATION_ID     	        => p_statutory_situation_id
  ,P_PERSON_ID                  	        => p_person_id
  ,P_PROVISIONAL_START_DATE     	        => p_provisional_start_date
  ,P_PROVISIONAL_END_DATE       	        => p_provisional_end_date
  ,P_ACTUAL_START_DATE          	        => l_actual_start_date
  ,P_ACTUAL_END_DATE            	        => p_actual_end_date
  ,P_APPROVAL_FLAG              	        => p_approval_flag
  ,P_COMMENTS                   	        => p_comments
  ,P_CONTACT_PERSON_ID          	        => p_contact_person_id
  ,P_CONTACT_RELATIONSHIP       	        => p_contact_relationship
  ,P_EXTERNAL_ORGANIZATION_ID   	        => p_external_organization_id
  ,P_RENEWAL_FLAG               	        => p_renewal_flag
  ,P_RENEW_STAT_SITUATION_ID    	        => p_renew_stat_situation_id
  ,P_SECONDED_CAREER_ID         	        => p_seconded_career_id
  ,P_ATTRIBUTE_CATEGORY         	        => p_attribute_category
  ,P_ATTRIBUTE1                 	        => p_attribute1
  ,P_ATTRIBUTE2                 	        => p_attribute2
  ,P_ATTRIBUTE3                 	        => p_attribute3
  ,P_ATTRIBUTE4                 	        => p_attribute4
  ,P_ATTRIBUTE5                 	        => p_attribute5
  ,P_ATTRIBUTE6                 	        => p_attribute6
  ,P_ATTRIBUTE7                 	        => p_attribute7
  ,P_ATTRIBUTE8                 	        => p_attribute8
  ,P_ATTRIBUTE9                 	        => p_attribute9
  ,P_ATTRIBUTE10                	        => p_attribute10
  ,P_ATTRIBUTE11                	        => p_attribute11
  ,P_ATTRIBUTE12                	        => p_attribute12
  ,P_ATTRIBUTE13                	        => p_attribute13
  ,P_ATTRIBUTE14                	        => p_attribute14
  ,P_ATTRIBUTE15                	        => p_attribute15
  ,P_ATTRIBUTE16                	        => p_attribute16
  ,P_ATTRIBUTE17                	        => p_attribute17
  ,P_ATTRIBUTE18                	        => p_attribute18
  ,P_ATTRIBUTE19                	        => p_attribute19
  ,P_ATTRIBUTE20                	        => p_attribute20
  ,P_ATTRIBUTE21                	        => p_attribute21
  ,P_ATTRIBUTE22                	        => p_attribute22
  ,P_ATTRIBUTE23                	        => p_attribute23
  ,P_ATTRIBUTE24                	        => p_attribute24
  ,P_ATTRIBUTE25                	        => p_attribute25
  ,P_ATTRIBUTE26                	        => p_attribute26
  ,P_ATTRIBUTE27                	        => p_attribute27
  ,P_ATTRIBUTE28                	        => p_attribute28
  ,P_ATTRIBUTE29                	        => p_attribute29
  ,P_ATTRIBUTE30                	        => p_attribute30
  ,P_EMP_STAT_SITUATION_ID      	        => l_emp_stat_situation_id
  ,P_OBJECT_VERSION_NUMBER                      => l_object_version_number );
  --
  --
  -- Processing Logic
/* Commented by deenath.
  IF p_approval_flag  = 'Y'  THEN
     update_assignments(p_person_id => p_person_id
                       ,p_statutory_situation_id => p_statutory_situation_id
                       ,p_start_date => NVL(p_actual_start_date,p_provisional_start_date)
                       ,p_end_date => NVL(p_actual_end_date,p_provisional_end_date) );
  END IF;
*/
  --
  -- Set all output arguments
  --
  IF p_validate = TRUE THEN
        raise hr_api.validate_enabled;
  END IF;
  p_emp_stat_situation_id  := l_emp_stat_situation_id;
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
EXCEPTION
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO create_emp_stat_situation;
     p_emp_stat_situation_id  := null;
     p_object_version_number  := null;
     hr_utility.set_location(' Leaving:'||l_proc, 41);
   When Others THEN
      Rollback to create_emp_stat_situation;
      hr_utility.set_location(' Leaving:'||l_proc, 42);
      fnd_message.raise_error;
end CREATE_EMP_STAT_SITUATION;
procedure UPDATE_EMP_STAT_SITUATION
  (p_validate                      IN     boolean  default false
  ,p_effective_date                IN     date
  ,P_EMP_STAT_SITUATION_ID         IN     NUMBER
  ,P_STATUTORY_SITUATION_ID        IN     NUMBER   default hr_api.g_number
  ,P_PERSON_ID                     IN     NUMBER   default hr_api.g_number
  ,P_PROVISIONAL_START_DATE        IN     DATE     default hr_api.g_date
  ,P_PROVISIONAL_END_DATE          IN     DATE     default hr_api.g_date
  ,P_ACTUAL_START_DATE             IN     DATE     default hr_api.g_date
  ,P_ACTUAL_END_DATE               IN     DATE     default hr_api.g_date
  ,P_APPROVAL_FLAG                 IN     VARCHAR2 default hr_api.g_varchar2
  ,P_COMMENTS                      IN     VARCHAR2 default hr_api.g_varchar2
  ,P_CONTACT_PERSON_ID             IN     NUMBER   default hr_api.g_number
  ,P_CONTACT_RELATIONSHIP          IN     VARCHAR2 default hr_api.g_varchar2
  ,P_EXTERNAL_ORGANIZATION_ID      IN     NUMBER   default hr_api.g_number
  ,P_RENEWAL_FLAG                  IN     VARCHAR2 default hr_api.g_varchar2
  ,P_RENEW_STAT_SITUATION_ID       IN     NUMBER   default hr_api.g_number
  ,P_SECONDED_CAREER_ID            IN     NUMBER   default hr_api.g_number
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE1                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE2                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE3                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE4                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE5                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE6                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE7                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE8                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE9                    IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE10                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE11                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE12                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE13                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE14                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE15                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE16                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE17                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE18                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE19                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE20                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE21                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE22                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE23                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE24                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE25                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE26                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE27                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE28                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE29                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_ATTRIBUTE30                   IN     VARCHAR2 default hr_api.g_varchar2
  ,P_OBJECT_VERSION_NUMBER         IN OUT NOCOPY NUMBER
  ) IS
  l_emp_stat_situation_id  NUMBER(15);
  l_object_version_number  NUMBER(9);
  l_orig_object_version_number  NUMBER(9);
  CURSOR csr_situation_approved(p_emp_stat_situation_id IN NUMBER) IS
    SELECT NVL(approval_flag, 'N')
    FROM   pqh_fr_emp_stat_situations
    WHERE  emp_stat_situation_id = p_emp_stat_situation_id;
    l_sit_approval  varchar2(10) ;
  l_proc                varchar2(72) := g_package||'update_emp_stat_situation';
   l_actual_start_date    DATE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_emp_stat_situation_id := p_emp_stat_situation_id;
  l_object_version_number := p_object_version_number;
  l_orig_object_version_number := p_object_version_number;
  savepoint update_emp_stat_situation;
  --
  -- Validation in addition to Row Handlers
  --
  If (P_APPROVAL_FLAG = 'Y') Then
    l_actual_start_date := p_provisional_start_date;
  Else
    l_actual_start_date := P_ACTUAL_START_DATE;
  End if;
   -- Processing Logic
  OPEN csr_situation_approved(p_emp_stat_situation_id);
  FETCH csr_situation_approved INTO  l_sit_approval;
  CLOSE csr_situation_approved;
  pqh_psu_upd.upd(
   P_EFFECTIVE_DATE                             => p_effective_date
  ,P_STATUTORY_SITUATION_ID     	        => p_statutory_situation_id
  ,P_PERSON_ID                  	        => p_person_id
  ,P_PROVISIONAL_START_DATE     	        => p_provisional_start_date
  ,P_PROVISIONAL_END_DATE       	        => p_provisional_end_date
  ,P_ACTUAL_START_DATE          	        => l_actual_start_date
  ,P_ACTUAL_END_DATE            	        => p_actual_end_date
  ,P_APPROVAL_FLAG              	        => p_approval_flag
  ,P_COMMENTS                   	        => p_comments
  ,P_CONTACT_PERSON_ID          	        => p_contact_person_id
  ,P_CONTACT_RELATIONSHIP       	        => p_contact_relationship
  ,P_EXTERNAL_ORGANIZATION_ID   	        => p_external_organization_id
  ,P_RENEWAL_FLAG               	        => p_renewal_flag
  ,P_RENEW_STAT_SITUATION_ID    	        => p_renew_stat_situation_id
  ,P_SECONDED_CAREER_ID         	        => p_seconded_career_id
  ,P_ATTRIBUTE_CATEGORY         	        => p_attribute_category
  ,P_ATTRIBUTE1                 	        => p_attribute1
  ,P_ATTRIBUTE2                 	        => p_attribute2
  ,P_ATTRIBUTE3                 	        => p_attribute3
  ,P_ATTRIBUTE4                 	        => p_attribute4
  ,P_ATTRIBUTE5                 	        => p_attribute5
  ,P_ATTRIBUTE6                 	        => p_attribute6
  ,P_ATTRIBUTE7                 	        => p_attribute7
  ,P_ATTRIBUTE8                 	        => p_attribute8
  ,P_ATTRIBUTE9                 	        => p_attribute9
  ,P_ATTRIBUTE10                	        => p_attribute10
  ,P_ATTRIBUTE11                	        => p_attribute11
  ,P_ATTRIBUTE12                	        => p_attribute12
  ,P_ATTRIBUTE13                	        => p_attribute13
  ,P_ATTRIBUTE14                	        => p_attribute14
  ,P_ATTRIBUTE15                	        => p_attribute15
  ,P_ATTRIBUTE16                	        => p_attribute16
  ,P_ATTRIBUTE17                	        => p_attribute17
  ,P_ATTRIBUTE18                	        => p_attribute18
  ,P_ATTRIBUTE19                	        => p_attribute19
  ,P_ATTRIBUTE20                	        => p_attribute20
  ,P_ATTRIBUTE21                	        => p_attribute21
  ,P_ATTRIBUTE22                	        => p_attribute22
  ,P_ATTRIBUTE23                	        => p_attribute23
  ,P_ATTRIBUTE24                	        => p_attribute24
  ,P_ATTRIBUTE25                	        => p_attribute25
  ,P_ATTRIBUTE26                	        => p_attribute26
  ,P_ATTRIBUTE27                	        => p_attribute27
  ,P_ATTRIBUTE28                	        => p_attribute28
  ,P_ATTRIBUTE29                	        => p_attribute29
  ,P_ATTRIBUTE30                	        => p_attribute30
  ,P_EMP_STAT_SITUATION_ID      	        => l_emp_stat_situation_id
  ,P_OBJECT_VERSION_NUMBER                      => l_object_version_number );
  --
  --
/* commented by deenath
  IF p_approval_flag  = 'Y' and NVL(l_sit_approval,'N') = 'N' THEN
     update_assignments(p_person_id => p_person_id
                       ,p_statutory_situation_id => p_statutory_situation_id
                       ,p_start_date => NVL(p_actual_start_date,p_provisional_start_date)
                       ,p_end_date => NVL(p_actual_end_date,p_provisional_end_date) );
  END IF;
*/
  --
  -- Set all output arguments
  --
  IF p_validate = TRUE THEN
        raise hr_api.validate_enabled;
  END IF;
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
EXCEPTION
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     hr_utility.set_location(' Leaving:'||l_proc, 41);
     ROLLBACK TO update_emp_stat_situation;
     p_object_version_number  := l_orig_object_version_number;
   When Others THEN
     Rollback to update_emp_stat_situation;
     p_object_version_number  := l_orig_object_version_number;
     hr_utility.set_location(' Leaving:'||l_proc, 42 );
     fnd_message.raise_error;
 END UPDATE_EMP_STAT_SITUATION;
Procedure DELETE_EMP_STAT_SITUATION
( P_VALIDATE   IN BOOLEAN DEFAULT FALSE
 ,P_EMP_STAT_SITUATION_ID IN NUMBER
 ,P_OBJECT_VERSION_NUMBER IN NUMBER) IS
  l_proc                varchar2(72) := g_package||'delete_emp_stat_situation';
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  savepoint delete_emp_stat_situation;
  pqh_psu_del.del(p_emp_stat_situation_id => p_emp_stat_situation_id,
                  p_object_version_number => p_object_version_number);
  IF p_validate = TRUE THEN
        raise hr_api.validate_enabled;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
EXCEPTION
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     hr_utility.set_location(' Leaving:'||l_proc, 41);
     ROLLBACK TO delete_emp_stat_situation;
   When Others THEN
      Rollback to delete_emp_stat_situation;
      hr_utility.set_location(' Leaving:'||l_proc, 42);
      fnd_message.raise_error;
 END DELETE_EMP_STAT_SITUATION;
--
--
procedure renew_emp_stat_situation
( P_VALIDATE   IN BOOLEAN DEFAULT FALSE
 ,P_EMP_STAT_SITUATION_ID IN OUT NOCOPY NUMBER
 ,P_RENEW_STAT_SITUATION_ID IN NUMBER
 ,P_RENEWAL_DURATION  IN NUMBER
 ,P_DURATION_UNITS    IN VARCHAR2
 ,P_APPROVAL_FLAG     IN VARCHAR2
 ,P_COMMENTS        IN VARCHAR2
 ,P_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER) IS
  l_proc                varchar2(72) := g_package||'renew_emp_stat_situation';
  CURSOR Csr_current_situation_dtls (p_emp_stat_situation_id IN NUMBER) IS
    SELECT *
    FROM   pqh_fr_emp_stat_situations
    WHERE  emp_stat_situation_id = p_emp_stat_situation_id;
  lr_currec csr_current_situation_dtls%ROWTYPE;
  l_new_prov_end_date DATE;
  l_upd_sit_ovn NUMBER(9);
  l_new_sit_id NUMBER(15);
  l_new_sit_ovn NUMBER(9);
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  savepoint renew_emp_stat_situation;
  OPEN csr_current_situation_dtls(p_emp_stat_situation_id);
  FETCH csr_current_situation_dtls INTO lr_currec;
  CLOSE csr_current_situation_dtls;
  IF p_duration_units = 'D' THEN
    l_new_prov_end_date := lr_currec.provisional_end_date+p_renewal_duration;
  ELSIF p_duration_units = 'W' THEN
    l_new_prov_end_date := lr_currec.provisional_end_date+p_renewal_duration*7;
  ELSIF p_duration_units = 'M' THEN
    l_new_prov_end_date := add_months(lr_currec.provisional_end_date,p_renewal_duration);
  ELSIF p_duration_units = 'Y' THEN
    l_new_prov_end_date := add_months(lr_currec.provisional_end_date,p_renewal_duration*12);
  ELSE
    fnd_message.set_name('PQH','FR_PQH_STS_INVALID_UNITS');
    hr_multi_message.add(p_associated_column1=> 'P_DURATION_UNITS');
  END IF;
  l_upd_sit_ovn := lr_currec.object_version_number;
--Extend the civil servant situation by the said duration and create a new renewal situation  record
  pqh_fr_emp_stat_situation_api.update_emp_stat_situation(p_emp_stat_situation_id => p_emp_stat_situation_id
                                                         ,p_effective_date        => lr_currec.provisional_end_date
                                                         ,p_object_version_number => l_upd_sit_ovn
                                                         ,p_provisional_end_date  => l_new_prov_end_date);
  pqh_fr_emp_stat_situation_api.create_emp_stat_situation( p_effective_date         => trunc(lr_currec.provisional_end_date+1)
  							  ,p_emp_stat_situation_id  => l_new_sit_id
  							  ,p_statutory_situation_id => lr_currec.statutory_situation_id
  							  ,p_person_id              => lr_currec.person_id
  							  ,p_provisional_start_date => trunc(lr_currec.provisional_end_date+1)
  							  ,p_provisional_end_date   => l_new_prov_end_date
  							  ,p_approval_flag          => p_approval_flag
							  ,p_comments               => p_comments
  							  ,p_renewal_flag           => 'Y'
  							  ,p_renew_stat_situation_id => lr_currec.emp_stat_situation_id
  							  ,p_object_version_number  => l_new_sit_ovn);
  IF p_validate = TRUE THEN
     raise hr_api.validate_enabled;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
EXCEPTION
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     hr_utility.set_location(' Leaving:'||l_proc, 41);
     ROLLBACK TO renew_emp_stat_situation;
   When Others THEN
      Rollback to renew_emp_stat_situation;
      hr_utility.set_location(' Leaving:'||l_proc, 42);
      fnd_message.raise_error;
end renew_emp_stat_situation;
procedure reinstate_emp_stat_situation
( P_VALIDATE   IN BOOLEAN DEFAULT FALSE
 ,P_PERSON_ID  IN NUMBER
 ,P_EMP_STAT_SITUATION_ID IN NUMBER
 ,P_REINSTATE_DATE   IN DATE
 ,P_COMMENTS        IN VARCHAR2
 ,P_NEW_EMP_STAT_SITUATION_ID OUT NOCOPY NUMBER) IS
 l_proc                varchar2(72) := g_package||'reinstate_emp_stat_situation';
 l_reinstate_sit_id    NUMBER(15);
 l_new_sit_id          NUMBER(15);
 l_new_sit_ovn         NUMBER(9);
 l_upd_sit_ovn         NUMBER(9);
 CURSOR Csr_current_situation_dtls (p_emp_stat_situation_id IN NUMBER) IS
   SELECT *
   FROM   pqh_fr_emp_stat_situations
   WHERE  emp_stat_situation_id = p_emp_stat_situation_id;
 lr_currec csr_current_situation_dtls%ROWTYPE;
CURSOR Csr_prov_end_date (p_emp_stat_situation_id IN NUMBER, p_person_id IN NUMBER, p_eff_date IN DATE) IS
   SELECT max(NVL(actual_start_date,provisional_start_date))
   FROM   pqh_fr_emp_stat_situations
   WHERE  emp_stat_situation_id <> p_emp_stat_situation_id
   AND    person_Id  = p_person_id
   AND    p_eff_date BETWEEN provisional_start_date and provisional_end_date;
 l_next_sit_end_dt   DATE;
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  savepoint reinstate_emp_stat_situation;
  --Modified by deenath. Changed parameters 'IN' and 'IN_N' to 'IA' and 'IA_N' resp.
  l_reinstate_sit_id:= pqh_fr_stat_sit_util.get_dflt_situation(p_business_group_id => hr_general.get_business_group_id,
                                                                       p_effective_date => p_reinstate_date,
                                                                       p_situation_type => 'IA',
                                                                       p_sub_type => 'IA_N');
  IF l_reinstate_sit_id = -1 THEN
      fnd_message.set_name('PQH','FR_PQH_STS_NO_DFLT_SIT');
      fnd_message.raise_error;
  END IF;
  OPEN csr_current_situation_dtls(p_emp_stat_situation_id);
  FETCH csr_current_situation_dtls INTO lr_currec;
  IF csr_current_situation_dtls%NOTFOUND THEN
      CLOSE csr_current_situation_dtls;
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
  END IF;
  CLOSE csr_current_situation_dtls;
  l_upd_sit_ovn := lr_currec.object_version_number;
--End Date the current situation and create a new situation with default situation for the employee.
  pqh_fr_emp_stat_situation_api.update_emp_stat_situation(p_emp_stat_situation_id => p_emp_stat_situation_id
                                                         ,p_effective_date        => trunc(p_reinstate_date)-1
                                                         ,p_object_version_number => l_upd_sit_ovn
                                                         ,p_actual_end_date       => trunc(p_reinstate_date)-1);
  OPEN csr_prov_end_date(p_emp_stat_situation_id,p_person_id,p_reinstate_date);
  FETCH csr_prov_end_date INTO l_next_sit_end_dt;
  CLOSE csr_prov_end_date;
  pqh_fr_emp_stat_situation_api.create_emp_stat_situation( p_effective_date         => trunc(p_reinstate_date)
  							  ,p_emp_stat_situation_id  => l_new_sit_id
  							  ,p_statutory_situation_id => l_reinstate_sit_id
  							  ,p_person_id              => lr_currec.person_id
  							  ,p_provisional_start_date => trunc(p_reinstate_date)
  							  ,p_provisional_end_date   => NVL(l_next_sit_end_dt,hr_general.end_of_time)
  							  ,p_actual_start_date      => trunc(p_reinstate_date)
  							  ,p_approval_flag          => 'Y'
							  ,p_comments               => p_comments
  							  ,p_object_version_number  => l_new_sit_ovn);
  IF p_validate = TRUE THEN
      raise hr_api.validate_enabled;
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
EXCEPTION
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     hr_utility.set_location(' Leaving:'||l_proc, 41);
     ROLLBACK TO reinstate_emp_stat_situation;
   When Others THEN
      Rollback to reinstate_emp_stat_situation;
      hr_utility.set_location(' Leaving:'||l_proc, 42);
      fnd_message.raise_error;
END REINSTATE_EMP_STAT_SITUATION;
--
end PQH_FR_EMP_STAT_SITUATION_API;

/
