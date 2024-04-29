--------------------------------------------------------
--  DDL for Package Body PQH_FR_EMP_STAT_SIT_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_EMP_STAT_SIT_UTILITY" AS
/* $Header: pqfresut.pkb 120.0 2005/05/29 01:53:03 appldev noship $ */
  --
  --Package variables
  g_package  VARCHAR2(33) := 'PQH_FR_EMP_STAT_SIT_UTILITY.';
  --
  -- ---------------------------------------------------------------------------
  -- ----------------------< create_emp_stat_situation >------------------------
  -- ---------------------------------------------------------------------------
  PROCEDURE create_emp_stat_situation
  (p_validate                     IN     NUMBER    DEFAULT HR_API.g_false_num
  ,p_effective_date               IN     DATE
  ,p_statutory_situation_id       IN     NUMBER
  ,p_person_id                    IN     NUMBER
  ,p_provisional_start_date       IN     DATE
  ,p_provisional_end_date         IN     DATE
  ,p_actual_start_date            IN     DATE      DEFAULT NULL
  ,p_actual_end_date              IN     DATE      DEFAULT NULL
  ,p_approval_flag                IN     VARCHAR2  DEFAULT NULL
  ,p_comments                     IN     VARCHAR2  DEFAULT NULL
  ,p_contact_person_id            IN     NUMBER    DEFAULT NULL
  ,p_contact_relationship         IN     VARCHAR2  DEFAULT NULL
  ,p_external_organization_id     IN     NUMBER    DEFAULT NULL
  ,p_renewal_flag                 IN     VARCHAR2  DEFAULT NULL
  ,p_renew_stat_situation_id      IN     NUMBER    DEFAULT NULL
  ,p_seconded_career_id           IN     NUMBER    DEFAULT NULL
  ,p_attribute_category           IN     VARCHAR2  DEFAULT NULL
  ,p_attribute1                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute2                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute3                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute4                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute5                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute6                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute7                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute8                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute9                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute10                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute11                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute12                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute13                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute14                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute15                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute16                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute17                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute18                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute19                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute20                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute21                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute22                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute23                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute24                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute25                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute26                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute27                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute28                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute29                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute30                  IN     VARCHAR2  DEFAULT NULL
  ,p_emp_stat_situation_id    OUT nocopy NUMBER
  ,p_object_version_number    OUT nocopy NUMBER
  ,p_return_status            OUT nocopy VARCHAR2
  )
  IS
  --
  --Cursor for Overlapping In Activity Normal Default Situation
    CURSOR csr_get_inactivity(p_provisional_start     DATE,
                              p_provisional_end       DATE,
                              p_actual_start          DATE,
                              p_actual_end            DATE,
                              p_person_id             NUMBER) IS
    SELECT emp_stat_situation_id, statutory_situation_id, object_version_number,
           actual_start_date, provisional_start_date,
           actual_end_date, NVL(provisional_end_date,HR_GENERAL.end_of_time)
      FROM pqh_fr_emp_stat_situations
     WHERE person_id = p_person_id
       AND statutory_situation_id IN (SELECT statutory_situation_id
                                        FROM pqh_fr_stat_situations_v sit
                                            ,per_shared_types_vl      sh
                                       WHERE sh.shared_type_id     = type_of_ps
                                         AND sh.system_type_cd     = NVL(PQH_FR_UTILITY.get_bg_type_of_ps,sh.system_type_cd)
                                         AND sit.business_group_id = HR_GENERAL.get_business_group_id
                                         AND sit.default_flag      = 'Y'
                                         AND sit.situation_type    = 'IA'
                                         AND sit.sub_type          = 'IA_N'
                                         AND TRUNC(NVL(p_actual_start,p_provisional_start)) BETWEEN
                                             sit.date_from AND NVL(sit.date_to,HR_GENERAL.end_of_time))
       AND(TRUNC(NVL(actual_start_date,provisional_start_date)) <= TRUNC(NVL(p_actual_start,p_provisional_start))
       AND TRUNC(NVL(actual_end_date,NVL(provisional_end_date,HR_GENERAL.end_of_time)))
                                                                >= TRUNC(NVL(p_actual_end,p_provisional_end)));
  --
  --Cursor for Overlapping non In Activity Normal Default Situations
    CURSOR csr_overlaps(p_provisional_start     DATE,
                        p_provisional_end       DATE,
                        p_actual_start          DATE,
                        p_actual_end            DATE,
                        p_person_id             NUMBER,
                        p_emp_stat_situation_id NUMBER,
                        p_iand_stat_sit_id      NUMBER) IS
    SELECT 'x'
      FROM DUAL
     WHERE EXISTS(SELECT 'x'
                    FROM pqh_fr_emp_stat_situations
                   WHERE person_id               = p_person_id
--                     AND emp_stat_situation_id  <> NVL(p_emp_stat_situation_id,-1)
                     AND statutory_situation_id <> p_iand_stat_sit_id
                     AND(NVL(p_actual_start,p_provisional_start)
                                           BETWEEN NVL(actual_start_date,provisional_start_date)
                                               AND NVL(actual_end_date,NVL(provisional_end_date,HR_GENERAL.end_of_time))
                      OR NVL(p_actual_end,p_provisional_end)
                                           BETWEEN NVL(actual_start_date,provisional_start_date)
                                               AND NVL(actual_end_date,NVL(provisional_end_date,HR_GENERAL.end_of_time))));
  --
  --Variable Declaration
    l_iand_emp_stat_sit_id      PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_iand_stat_sit_id          PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_iand_ovn                  PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_iand_act_start_dt         PQH_FR_EMP_STAT_SITUATIONS.actual_start_date%TYPE;
    l_iand_prv_start_dt         PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_iand_act_end_dt           PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_iand_prv_end_dt           PQH_FR_EMP_STAT_SITUATIONS.provisional_end_date%TYPE;
    l_new_iand_emp_stat_sit_id  PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_new_sit_ovn               PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_max_iand_emp_stat_sit_id  PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_max_iand_stat_sit_id      PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_max_iand_ovn              PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_max_iand_act_start_dt     PQH_FR_EMP_STAT_SITUATIONS.actual_start_date%TYPE;
    l_actual_end_date           PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_approval_flag             PQH_FR_EMP_STAT_SITUATIONS.approval_flag%TYPE;
    l_valid                     VARCHAR2(01) := NULL;
    l_proc                      VARCHAR2(72) := g_package||'create_emp_stat_situation';
    l_validate                  BOOLEAN;
    l_rul_sit_return_st         varchar2(2) ;
  --
  BEGIN
  --
  --Log entry
    HR_UTILITY.set_location(' Entering: '||l_proc, 10);
  --
  --Issue savepoint
    SAVEPOINT pre_state;
  --
  --Initialise Multiple Message Detection
    HR_MULTI_MESSAGE.enable_message_list;
  --Convert constant values to their corresponding boolean value
    l_validate := HR_API.constant_to_boolean(p_constant_value => p_validate);
  --
  --Check whether In Activity Normal Default Situation exists during the timeframe.
    OPEN csr_get_inactivity(p_provisional_start_date,p_provisional_end_date,
                            p_actual_start_date,p_actual_end_date,p_person_id);
    FETCH csr_get_inactivity INTO l_iand_emp_stat_sit_id,l_iand_stat_sit_id,l_iand_ovn,
                                  l_iand_act_start_dt,l_iand_prv_start_dt,
                                  l_iand_act_end_dt,l_iand_prv_end_dt;
    IF csr_get_inactivity%NOTFOUND THEN
       CLOSE csr_get_inactivity;
       FND_MESSAGE.set_name('PQH','FR_PQH_STS_NO_IAND_SIT'); --In Activity Normal Default sitution does not exist for the specified duration. A Situation can only be created when an In Activity Normal Default situation exists in the duration.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    IF csr_get_inactivity%ISOPEN THEN
       CLOSE csr_get_inactivity;
    END IF;
  --
  --Check for Overlaps against Non In Activity Normal Default Situations.
    OPEN csr_overlaps(p_provisional_start_date,p_provisional_end_date,
                      p_actual_start_date,p_actual_end_date,
                      p_person_id,p_emp_stat_situation_id,l_iand_stat_sit_id);
    FETCH csr_overlaps INTO l_valid;
    IF csr_overlaps%FOUND THEN
       CLOSE csr_overlaps;
       FND_MESSAGE.set_name('PQH','FR_PQH_STAT_SIT_OVERLAP_DATES'); --The Start and/or End Date for this situation overlaps with other situation. Please enter non overlapping dates.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    IF csr_overlaps%ISOPEN THEN
       CLOSE csr_overlaps;
    END IF;
  --
  -- Checking whether user satisfies the eligibility criteria for going to a situation
        HR_UTILITY.set_location('Checking the eligibility criteria  ', 40);
       l_rul_sit_return_st := pqh_sit_engine.is_situation_valid(p_person_id,p_provisional_start_date,p_statutory_situation_id);
        HR_UTILITY.set_location('Return status for the eligibility criteria  '||l_rul_sit_return_st, 40);
       IF l_rul_sit_return_st = 'N' then
         IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
               RAISE HR_MULTI_MESSAGE.error_message_exist;
          END IF;
       END IF;

  --
  --End date IAND situation (IAND = In Activity Normal Default)
    pqh_fr_emp_stat_situation_api.update_emp_stat_situation
       (p_effective_date         => p_effective_date
       ,p_emp_stat_situation_id  => l_iand_emp_stat_sit_id --Update this IAND rec
       ,p_statutory_situation_id => l_iand_stat_sit_id
       ,p_provisional_end_date   => TRUNC(NVL(p_actual_start_date,p_provisional_start_date)-1)
       ,p_actual_end_date        => TRUNC(NVL(p_actual_start_date,p_provisional_start_date)-1)
       ,p_approval_flag          => 'Y'
       ,p_object_version_number  => l_iand_ovn);           --OVN for the IAND rec
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
    pqh_psu_ins.set_base_key_value(p_emp_stat_situation_id => p_emp_stat_situation_id);
    l_actual_end_date := p_actual_end_date;
  --
  --If Situation is Past Situation then set its actual end date to prov end date.
    IF NVL(p_actual_end_date,p_provisional_end_date) < TRUNC(SYSDATE) THEN
       IF p_actual_end_date IS NULL THEN
          l_actual_end_date := p_provisional_end_date;
       END IF;
    END IF;
  --
  --Create the new Situation
    pqh_fr_emp_stat_situation_api.create_emp_stat_situation
       (p_validate                 => l_validate
       ,p_effective_date           => p_effective_date
       ,p_statutory_situation_id   => p_statutory_situation_id
       ,p_person_id                => p_person_id
       ,p_provisional_start_date   => p_provisional_start_date
       ,p_provisional_end_date     => p_provisional_end_date
       ,p_actual_start_date        => p_actual_start_date
       ,p_actual_end_date          => l_actual_end_date
       ,p_approval_flag            => p_approval_flag
       ,p_comments                 => p_comments
       ,p_contact_person_id        => p_contact_person_id
       ,p_contact_relationship     => p_contact_relationship
       ,p_external_organization_id => p_external_organization_id
       ,p_renewal_flag             => p_renewal_flag
       ,p_renew_stat_situation_id  => p_renew_stat_situation_id
       ,p_seconded_career_id       => p_seconded_career_id
       ,p_attribute_category       => p_attribute_category
       ,p_attribute1               => p_attribute1
       ,p_attribute2               => p_attribute2
       ,p_attribute3               => p_attribute3
       ,p_attribute4               => p_attribute4
       ,p_attribute5               => p_attribute5
       ,p_attribute6               => p_attribute6
       ,p_attribute7               => p_attribute7
       ,p_attribute8               => p_attribute8
       ,p_attribute9               => p_attribute9
       ,p_attribute10              => p_attribute10
       ,p_attribute11              => p_attribute11
       ,p_attribute12              => p_attribute12
       ,p_attribute13              => p_attribute13
       ,p_attribute14              => p_attribute14
       ,p_attribute15              => p_attribute15
       ,p_attribute16              => p_attribute16
       ,p_attribute17              => p_attribute17
       ,p_attribute18              => p_attribute18
       ,p_attribute19              => p_attribute19
       ,p_attribute20              => p_attribute20
       ,p_attribute21              => p_attribute21
       ,p_attribute22              => p_attribute22
       ,p_attribute23              => p_attribute23
       ,p_attribute24              => p_attribute24
       ,p_attribute25              => p_attribute25
       ,p_attribute26              => p_attribute26
       ,p_attribute27              => p_attribute27
       ,p_attribute28              => p_attribute28
       ,p_attribute29              => p_attribute29
       ,p_attribute30              => p_attribute30
       ,p_emp_stat_situation_id    => p_emp_stat_situation_id
       ,p_object_version_number    => p_object_version_number);
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Create IAND with start date as (end date+1) of new Situation and end date as current IAND end date
    pqh_fr_emp_stat_situation_api.create_emp_stat_situation
       (p_effective_date         => p_effective_date
       ,p_emp_stat_situation_id  => l_new_iand_emp_stat_sit_id
       ,p_statutory_situation_id => l_iand_stat_sit_id
       ,p_person_id              => p_person_id
       ,p_provisional_start_date => TRUNC(NVL(p_actual_end_date,p_provisional_end_date)+1)
       ,p_provisional_end_date   => NVL(l_iand_prv_end_dt,hr_general.end_of_time)
       ,p_actual_start_date      => TRUNC(NVL(p_actual_end_date,p_provisional_end_date)+1)
       ,p_actual_end_date        => NVL(l_iand_act_end_dt,hr_general.end_of_time)
       ,p_approval_flag          => 'Y'
       ,p_comments               => p_comments
       ,p_object_version_number  => l_new_sit_ovn);
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Update Assignment to reflect the Create.
    updt_assign(p_person_id
               ,p_statutory_situation_id
               ,l_iand_stat_sit_id
               ,TRUNC(p_provisional_start_date)
               ,TRUNC(p_provisional_end_date));
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
    p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
    HR_UTILITY.set_location(' Leaving: '||l_proc, 20);
  --
  EXCEPTION
    WHEN HR_MULTI_MESSAGE.error_message_exist THEN
         --Catch Multiple Message List exception
         ROLLBACK TO pre_state;
         --Reset IN OUT parameters and set OUT parameters
         p_emp_stat_situation_id := NULL;
         p_object_version_number := NULL;
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving: '||l_proc, 30);
    WHEN others THEN
         --When Multiple Message Detection is enabled catch any Application specific or other unexpected exceptions.
         --Adding appropriate details to Multiple Message List. Otherwise re-raise the error.
         ROLLBACK TO pre_state;
         IF HR_MULTI_MESSAGE.unexpected_error_add(l_proc) THEN
            HR_UTILITY.set_location(' Leaving: '||l_proc, 40);
            RAISE;
         END IF;
         --Reset IN OUT and set OUT parameters
         p_emp_stat_situation_id := NULL;
         p_object_version_number := NULL;
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving: '||l_proc, 50);
  END create_emp_stat_situation;
  --
  -- ---------------------------------------------------------------------------
  -- ----------------------< update_emp_stat_situation >------------------------
  -- ---------------------------------------------------------------------------
  PROCEDURE update_emp_stat_situation
  (p_validate                     IN     NUMBER    DEFAULT HR_API.g_false_num
  ,p_effective_date               IN     DATE
  ,p_emp_stat_situation_id        IN     NUMBER
  ,p_statutory_situation_id       IN     NUMBER    DEFAULT HR_API.g_number
  ,p_person_id                    IN     NUMBER    DEFAULT HR_API.g_number
  ,p_provisional_start_date       IN     DATE      DEFAULT HR_API.g_date
  ,p_provisional_end_date         IN     DATE      DEFAULT HR_API.g_date
  ,p_actual_start_date            IN     DATE      DEFAULT HR_API.g_date
  ,p_actual_end_date              IN     DATE      DEFAULT HR_API.g_date
  ,p_approval_flag                IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_comments                     IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_contact_person_id            IN     NUMBER    DEFAULT HR_API.g_number
  ,p_contact_relationship         IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_external_organization_id     IN     NUMBER    DEFAULT HR_API.g_number
  ,p_renewal_flag                 IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_renew_stat_situation_id      IN     NUMBER    DEFAULT HR_API.g_number
  ,p_seconded_career_id           IN     NUMBER    DEFAULT HR_API.g_number
  ,p_attribute_category           IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute1                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute2                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute3                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute4                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute5                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute6                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute7                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute8                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute9                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute10                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute11                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute12                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute13                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute14                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute15                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute16                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute17                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute18                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute19                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute20                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute21                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute22                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute23                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute24                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute25                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute26                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute27                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute28                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute29                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute30                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_object_version_number IN OUT nocopy NUMBER
  ,p_return_status            OUT nocopy VARCHAR2
  )
  IS
  --
  --Cursor to get current Situation details
    CURSOR csr_current_situation_dtls(p_emp_stat_situation_id IN NUMBER) IS
    SELECT person_id, statutory_situation_id, actual_start_date, provisional_start_date, actual_end_date, provisional_end_date
      FROM pqh_fr_emp_stat_situations
     WHERE emp_stat_situation_id = p_emp_stat_situation_id;
  --
  --Cursor to fetch prior Situation falling before the Situation to be deleted
    CURSOR csr_get_prior_sit_dtls(p_person_id IN NUMBER,
                                  p_date      IN DATE) IS
    SELECT emp_stat_situation_id, statutory_situation_id, object_version_number,
           provisional_start_date, actual_start_date, provisional_end_date, actual_end_date
      FROM pqh_fr_emp_stat_situations
     WHERE person_id                                        = p_person_id
       AND TRUNC(NVL(actual_end_date,provisional_end_date)) = TRUNC(p_date-1);
  --
  --Cursor to fetch future Situation falling after the Situation to be deleted
    CURSOR csr_get_next_sit_dtls(p_person_id IN NUMBER,
                                 p_date      IN DATE) IS
    SELECT emp_stat_situation_id, statutory_situation_id, object_version_number,
           provisional_start_date, actual_start_date, provisional_end_date, actual_end_date
      FROM pqh_fr_emp_stat_situations
     WHERE person_id                                            = p_person_id
       AND TRUNC(NVL(actual_start_date,provisional_start_date)) = TRUNC(p_date+1);
  --
  --Cursor for Overlapping non In Activity Normal Default Situations
    CURSOR csr_overlaps(p_provisional_start     DATE,
                        p_provisional_end       DATE,
                        p_person_id             NUMBER,
                        p_emp_stat_situation_id NUMBER,
                        p_iand_stat_sit_id      NUMBER) IS
    SELECT 'x'
      FROM DUAL
     WHERE EXISTS(SELECT 'x'
                    FROM pqh_fr_emp_stat_situations
                   WHERE person_id                 = p_person_id
                     AND emp_stat_situation_id    <> NVL(p_emp_stat_situation_id,-1)
                     AND statutory_situation_id   <> p_iand_stat_sit_id
                     AND(p_provisional_start BETWEEN NVL(actual_start_date,provisional_start_date)
                                                 AND NVL(actual_end_date,NVL(provisional_end_date,HR_GENERAL.end_of_time))
                      OR p_provisional_end   BETWEEN NVL(actual_start_date,provisional_start_date)
                                                 AND NVL(actual_end_date,NVL(provisional_end_date,HR_GENERAL.end_of_time))));
  --
  --Variable Declaration
    l_proc                     VARCHAR2(72) := g_package||'update_emp_stat_situation';
    l_validate                 BOOLEAN;
    l_valid                    VARCHAR2(01) := NULL;
    l_person_id                PQH_FR_EMP_STAT_SITUATIONS.person_id%TYPE;
    l_sit_id                   PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_act_st_dt                PQH_FR_EMP_STAT_SITUATIONS.actual_start_date%TYPE;
    l_prov_st_dt               PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_act_end_dt               PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_prov_end_dt              PQH_FR_EMP_STAT_SITUATIONS.provisional_end_date%TYPE;
    l_prior_emp_stat_sit_id    PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_prior_sit_id             PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_prior_ovn                PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_prior_prov_st_date       PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_prior_act_st_date        PQH_FR_EMP_STAT_SITUATIONS.actual_start_date%TYPE;
    l_prior_prov_end_date      PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_prior_act_end_date       PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_iand_sit_id              PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_next_emp_stat_sit_id     PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_next_sit_id              PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_next_ovn                 PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_next_prov_st_date        PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_next_act_st_date         PQH_FR_EMP_STAT_SITUATIONS.actual_start_date%TYPE;
    l_next_prov_end_date       PQH_FR_EMP_STAT_SITUATIONS.provisional_end_date%TYPE;
    l_next_act_end_date        PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_new_iand_emp_stat_sit_id PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_new_iand_ovn             PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_object_version_number PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
  --
  BEGIN
  --
  --Log entry
    HR_UTILITY.set_location(' Entering: '||l_proc, 10);
  --
  --Issue savepoint
    SAVEPOINT pre_state;
  --
  --Initialise Multiple Message Detection
    HR_MULTI_MESSAGE.enable_message_list;
  --
  --Assign OVN for Update Record to IN OUT variable
    l_object_version_number := p_object_version_number;
  --
  --Convert constant values to their corresponding boolean value
    l_validate := HR_API.constant_to_boolean(p_constant_value => p_validate);
  --
  --Fetch details of Situation to be updated.
    OPEN csr_current_situation_dtls(p_emp_stat_situation_id);
    FETCH csr_current_situation_dtls INTO l_person_id,l_sit_id,l_act_st_dt,l_prov_st_dt,l_act_end_dt,l_prov_end_dt;
    IF csr_current_situation_dtls%NOTFOUND THEN
       CLOSE csr_current_situation_dtls;
       FND_MESSAGE.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_current_situation_dtls;
  --
  --Fetch details for prior Situation ending on current situations start date - 1
    OPEN csr_get_prior_sit_dtls(l_person_id,TRUNC(NVL(l_act_st_dt,l_prov_st_dt)));
    FETCH csr_get_prior_sit_dtls INTO l_prior_emp_stat_sit_id, l_prior_sit_id, l_prior_ovn,
                                      l_prior_prov_st_date, l_prior_act_st_date,
                                      l_prior_prov_end_date, l_prior_act_end_date;
    IF csr_get_prior_sit_dtls%NOTFOUND THEN
       CLOSE csr_get_prior_sit_dtls;
       FND_MESSAGE.set_name('PQH','FR_PQH_PRIOR_SIT_NOT_FND'); --Cannot Update/Delete because no situation exists prior to this situation.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_get_prior_sit_dtls;
  --
  --Fetch details of future Situation starting from current situations end date + 1
    OPEN csr_get_next_sit_dtls(l_person_id,TRUNC(NVL(l_act_end_dt,l_prov_end_dt)));
    FETCH csr_get_next_sit_dtls INTO l_next_emp_stat_sit_id, l_next_sit_id, l_next_ovn,
                                     l_next_act_st_date,l_next_prov_st_date,
                                     l_next_prov_end_date, l_next_act_end_date;
    IF csr_get_next_sit_dtls%NOTFOUND THEN
       CLOSE csr_get_next_sit_dtls;
       FND_MESSAGE.set_name('PQH','FR_PQH_NEXT_SIT_NOT_FND'); --Cannot Update/Delete because no situation exists after this situation.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_get_next_sit_dtls;
  --
  --Get In Activity Normal Default Situation Id
    l_iand_sit_id:= PQH_FR_STAT_SIT_UTIL.get_dflt_situation
                       (p_business_group_id => HR_GENERAL.get_business_group_id
                       ,p_effective_date    => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
                       ,p_situation_type    => 'IA'
                       ,p_sub_type          => 'IA_N');
    IF l_iand_sit_id = -1 THEN
       FND_MESSAGE.set_name('PQH','FR_PQH_STS_NO_DFLT_SIT'); --In Activity Normal Default Situation does not exist.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Check for Overlaps against Non In Activity Normal Default Situations.
    OPEN csr_overlaps(p_provisional_start_date,p_provisional_end_date,
                      p_person_id,p_emp_stat_situation_id,l_iand_sit_id);
    FETCH csr_overlaps INTO l_valid;
    IF csr_overlaps%FOUND THEN
       CLOSE csr_overlaps;
       FND_MESSAGE.set_name('PQH','FR_PQH_STAT_SIT_OVERLAP_DATES'); --The Start and/or End Date for this situation overlaps with other situation. Please enter non overlapping dates.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    IF csr_overlaps%ISOPEN THEN
       CLOSE csr_overlaps;
    END IF;
  --
  --If prior Sit is IAND and next Sit is IAND then
    IF l_prior_sit_id <> l_iand_sit_id OR l_next_sit_id <> l_iand_sit_id THEN
       FND_MESSAGE.set_name('PQH','FR_PQH_STAT_SIT_RENEW'); --Cannot update because this is a Renewal Situation.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
    IF TRUNC(p_provisional_start_date) <> TRUNC(NVL(l_act_st_dt,l_prov_st_dt)) THEN
     --Call API to update Prior IAND Situations End Date to current situations updated Start Date - 1.
       pqh_fr_emp_stat_situation_api.update_emp_stat_situation
          (p_effective_date         => TRUNC(NVL(l_prior_act_st_date,l_prior_prov_st_date))
          ,p_emp_stat_situation_id  => l_prior_emp_stat_sit_id --Update this IAND rec
          ,p_statutory_situation_id => l_prior_sit_id
          ,p_provisional_end_date   => TRUNC(p_provisional_start_date-1)
          ,p_actual_end_date        => TRUNC(p_provisional_start_date-1) --in case it is not approved.
          ,p_approval_flag          => 'Y'
          ,p_object_version_number  => l_prior_ovn);
       IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
    END IF;
  --
  --Call API to update current Situation
    pqh_fr_emp_stat_situation_api.update_emp_stat_situation
       (p_validate                 => l_validate
       ,p_effective_date           => p_effective_date
       ,p_emp_stat_situation_id    => p_emp_stat_situation_id
       ,p_statutory_situation_id   => p_statutory_situation_id
       ,p_person_id                => p_person_id
       ,p_provisional_start_date   => p_provisional_start_date
       ,p_provisional_end_date     => p_provisional_end_date
       ,p_approval_flag            => p_approval_flag
       ,p_comments                 => p_comments
       ,p_contact_person_id        => p_contact_person_id
       ,p_contact_relationship     => p_contact_relationship
       ,p_external_organization_id => p_external_organization_id
       ,p_renewal_flag             => p_renewal_flag
       ,p_renew_stat_situation_id  => p_renew_stat_situation_id
       ,p_seconded_career_id       => p_seconded_career_id
       ,p_attribute_category       => p_attribute_category
       ,p_attribute1               => p_attribute1
       ,p_attribute2               => p_attribute2
       ,p_attribute3               => p_attribute3
       ,p_attribute4               => p_attribute4
       ,p_attribute5               => p_attribute5
       ,p_attribute6               => p_attribute6
       ,p_attribute7               => p_attribute7
       ,p_attribute8               => p_attribute8
       ,p_attribute9               => p_attribute9
       ,p_attribute10              => p_attribute10
       ,p_attribute11              => p_attribute11
       ,p_attribute12              => p_attribute12
       ,p_attribute13              => p_attribute13
       ,p_attribute14              => p_attribute14
       ,p_attribute15              => p_attribute15
       ,p_attribute16              => p_attribute16
       ,p_attribute17              => p_attribute17
       ,p_attribute18              => p_attribute18
       ,p_attribute19              => p_attribute19
       ,p_attribute20              => p_attribute20
       ,p_attribute21              => p_attribute21
       ,p_attribute22              => p_attribute22
       ,p_attribute23              => p_attribute23
       ,p_attribute24              => p_attribute24
       ,p_attribute25              => p_attribute25
       ,p_attribute26              => p_attribute26
       ,p_attribute27              => p_attribute27
       ,p_attribute28              => p_attribute28
       ,p_attribute29              => p_attribute29
       ,p_attribute30              => p_attribute30
       ,p_object_version_number    => p_object_version_number);
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
    IF TRUNC(p_provisional_end_date) <> TRUNC(NVL(l_act_end_dt,NVL(l_prov_end_dt,HR_GENERAL.end_of_time))) THEN
     --Call API to update next IAND Situations Start Date to current situations updated End Date + 1.
       pqh_fr_emp_stat_situation_api.update_emp_stat_situation
          (p_effective_date         => TRUNC(NVL(l_next_act_st_date,l_next_prov_st_date))
          ,p_emp_stat_situation_id  => l_next_emp_stat_sit_id --Update this IAND rec
          ,p_statutory_situation_id => l_next_sit_id
          ,p_provisional_start_date => TRUNC(p_provisional_end_date+1)
          ,p_actual_start_date      => TRUNC(p_provisional_end_date+1)
          ,p_approval_flag          => 'Y'
          ,p_object_version_number  => l_next_ovn);
       IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
    END IF;
  --
  --Update Assignment to reflect the Update.
    updt_assign(l_person_id
               ,l_sit_id
               ,l_iand_sit_id
               ,TRUNC(p_provisional_start_date)
               ,TRUNC(p_provisional_end_date));
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
    IF TRUNC(p_provisional_start_date) > TRUNC(NVL(l_act_st_dt,l_prov_st_dt)) THEN
     --Update Assignment to from original start date till updated start date.
       updt_assign(l_person_id
                  ,l_iand_sit_id
                  ,l_iand_sit_id
                  ,TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
                  ,TRUNC(p_provisional_start_date-1));
       IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
    END IF;
  --
    IF TRUNC(p_provisional_end_date) < TRUNC(NVL(l_act_end_dt,NVL(l_prov_end_dt,HR_GENERAL.end_of_time))) THEN
     --Update Assignment to from updated end date till original end date.
       updt_assign(l_person_id
                  ,l_iand_sit_id
                  ,l_iand_sit_id
                  ,TRUNC(p_provisional_end_date+1)
                  ,TRUNC(NVL(l_act_end_dt,NVL(l_prov_end_dt,HR_GENERAL.end_of_time))));
       IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
    END IF;
  --
    p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
    HR_UTILITY.set_location(' Leaving: '||l_proc, 20);
  --
  EXCEPTION
    WHEN HR_MULTI_MESSAGE.error_message_exist THEN
         --Catch Multiple Message List exception
         ROLLBACK TO pre_state;
         --Reset IN OUT parameters and set OUT parameters
         p_object_version_number := l_object_version_number;
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving: '||l_proc, 30);
    WHEN others THEN
         --When Multiple Message Detection is enabled catch any Application specific or other unexpected exceptions.
         --Adding appropriate details to Multiple Message List. Otherwise re-raise the error.
         ROLLBACK TO pre_state;
         IF HR_MULTI_MESSAGE.unexpected_error_add(l_proc) THEN
            HR_UTILITY.set_location(' Leaving: '||l_proc, 40);
            RAISE;
         END IF;
         --Reset IN OUT and set OUT parameters
         p_object_version_number := l_object_version_number;
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving: '||l_proc, 50);
  END update_emp_stat_situation;
  --
  -- ---------------------------------------------------------------------------
  -- --------------------< reinstate_emp_stat_situation >-----------------------
  -- ---------------------------------------------------------------------------
  PROCEDURE reinstate_emp_stat_situation
  (p_validate                      IN     NUMBER   DEFAULT HR_API.g_false_num
  ,p_person_id                     IN     NUMBER
  ,p_emp_stat_situation_id         IN     NUMBER
  ,p_reinstate_date                IN     DATE
  ,p_comments                      IN     VARCHAR2
  ,p_new_emp_stat_situation_id OUT nocopy NUMBER
  ,p_return_status             OUT nocopy VARCHAR2
  )
  IS
  --
  --Cursor to fetch the current Situation Details.
    CURSOR csr_current_situation_dtls(p_emp_stat_situation_id IN NUMBER) IS
    SELECT *
      FROM pqh_fr_emp_stat_situations
     WHERE emp_stat_situation_id = p_emp_stat_situation_id;
  --
  --Cursor to fetch IAND record falling after the Situation to be reinstated
    CURSOR csr_get_iand_dtls(p_iand_stat_sit_id IN NUMBER,
                             p_start_date       IN DATE) IS
    SELECT emp_stat_situation_id, provisional_end_date, actual_end_date, object_version_number
      FROM pqh_fr_emp_stat_situations
     WHERE person_id              = p_person_id
       AND statutory_situation_id = p_iand_stat_sit_id
       AND TRUNC(NVL(actual_start_date,provisional_start_date)) = TRUNC(p_start_date+1);
  --
  --Variable Declaration
    l_proc                  VARCHAR2(72) := g_package||'reinstate_emp_stat_situation';
    l_validate              BOOLEAN;
    l_object_version_number PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    lr_currec               csr_current_situation_dtls%ROWTYPE;
    l_reinstate_sit_id      PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_upd_sit_ovn           PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_new_emp_sit_id        PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_new_sit_ovn           PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_iand_emp_stat_sit_id  PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_iand_prov_end_date    PQH_FR_EMP_STAT_SITUATIONS.provisional_end_date%TYPE;
    l_iand_act_end_date     PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_iand_ovn              PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
  --
  BEGIN
  --
  --Log entry
    HR_UTILITY.set_location(' Entering: '||l_proc, 10);
  --
  --Issue savepoint
    SAVEPOINT pre_state;
  --
  --Initialise Multiple Message Detection
    HR_MULTI_MESSAGE.enable_message_list;
  --
  --Convert constant values to their corresponding boolean value
    l_validate := HR_API.constant_to_boolean(p_constant_value => p_validate);
  --
  --Get In Activity Normal Default Situation Id
    l_reinstate_sit_id:= PQH_FR_STAT_SIT_UTIL.get_dflt_situation
                            (p_business_group_id => HR_GENERAL.get_business_group_id
                            ,p_effective_date    => p_reinstate_date
                            ,p_situation_type    => 'IA'
                            ,p_sub_type          => 'IA_N');
    IF l_reinstate_sit_id = -1 THEN
       FND_MESSAGE.set_name('PQH','FR_PQH_STS_NO_DFLT_SIT'); --In Activity Normal Default Situation does not exist.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Get details for the situation being reinstated.
    OPEN csr_current_situation_dtls(p_emp_stat_situation_id);
    FETCH csr_current_situation_dtls INTO lr_currec;
    IF csr_current_situation_dtls%NOTFOUND THEN
       CLOSE csr_current_situation_dtls;
       FND_MESSAGE.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_current_situation_dtls;
  --
  --Check Reinstate Date is valid.
    IF(TRUNC(p_reinstate_date) <= TRUNC(NVL(lr_currec.actual_start_date,lr_currec.provisional_start_date)) OR
       TRUNC(p_reinstate_date)  > TRUNC(NVL(lr_currec.actual_end_date,lr_currec.provisional_end_date)+1)) THEN
       FND_MESSAGE.set_name('PQH','FR_PQH_INVLD_REINSTATE_DT'); --Invalid Reinstate Date entered. It must be between Start Date and End Date.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Check if In Activity Normal Default situation exists.
    OPEN csr_get_iand_dtls(l_reinstate_sit_id,NVL(lr_currec.actual_end_date,lr_currec.provisional_end_date));
    FETCH csr_get_iand_dtls INTO l_iand_emp_stat_sit_id,l_iand_prov_end_date,l_iand_act_end_date,l_iand_ovn;
    IF csr_get_iand_dtls%NOTFOUND THEN
       CLOSE csr_get_iand_dtls;
       FND_MESSAGE.set_name('PQH','FR_PQH_IAND_NOT_FND'); --Cannot Renew/Reinstate because this Situation has already been Renewed or Reinstated.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_get_iand_dtls;
  --
  --Assign the current Situation OVN number. Required for update.
    l_upd_sit_ovn := lr_currec.object_version_number;
  --
  --Update current Situation to end on (Reinstate Date - 1)
    pqh_fr_emp_stat_situation_api.update_emp_stat_situation
       (p_emp_stat_situation_id => p_emp_stat_situation_id
       ,p_effective_date        => TRUNC(p_reinstate_date-1)
       ,p_object_version_number => l_upd_sit_ovn
       ,p_actual_end_date       => TRUNC(p_reinstate_date-1));
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
 --
  --Update Start Date of IAND situation (IAND = In Activity Normal Default)
    pqh_fr_emp_stat_situation_api.update_emp_stat_situation
       (p_effective_date         => TRUNC(p_reinstate_date)
       ,p_emp_stat_situation_id  => l_iand_emp_stat_sit_id --Update this IAND rec
       ,p_statutory_situation_id => l_reinstate_sit_id
       ,p_provisional_start_date => TRUNC(p_reinstate_date)
       ,p_actual_start_date      => TRUNC(p_reinstate_date)
       ,p_approval_flag          => 'Y'
       ,p_comments               => p_comments
       ,p_object_version_number  => l_iand_ovn);
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Update Assignment to reflect the REINSTATEMENT.
    updt_assign(lr_currec.person_id
               ,l_reinstate_sit_id
               ,l_reinstate_sit_id
               ,TRUNC(p_reinstate_date)
               ,TRUNC(NVL(l_iand_act_end_date,l_iand_prov_end_date)));
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
    p_new_emp_stat_situation_id := l_iand_emp_stat_sit_id;
    p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
    HR_UTILITY.set_location(' Leaving: '||l_proc, 20);
  --
  EXCEPTION
    WHEN HR_MULTI_MESSAGE.error_message_exist THEN
         --Catch Multiple Message List exception
         ROLLBACK TO pre_state;
         --Reset IN OUT parameters and set OUT parameters
         p_new_emp_stat_situation_id := NULL;
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving: '||l_proc, 30);
    WHEN others THEN
         --When Multiple Message Detection is enabled catch any Application specific or other unexpected exceptions.
         --Adding appropriate details to Multiple Message List. Otherwise re-raise the error.
         ROLLBACK TO pre_state;
         IF HR_MULTI_MESSAGE.unexpected_error_add(l_proc) THEN
            HR_UTILITY.set_location(' Leaving: '||l_proc, 40);
            RAISE;
         END IF;
         --Reset IN OUT and set OUT parameters
         p_new_emp_stat_situation_id := NULL;
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving: '||l_proc, 50);
  END reinstate_emp_stat_situation;
  --
  -- ---------------------------------------------------------------------------
  -- |-----------------------< renew_emp_stat_situation >-----------------------
  -- ---------------------------------------------------------------------------
  PROCEDURE renew_emp_stat_situation
  (p_validate                IN            NUMBER  DEFAULT HR_API.g_false_num
  ,p_emp_stat_situation_id   IN OUT nocopy NUMBER
  ,p_renew_stat_situation_id IN            NUMBER
  ,p_renewal_duration        IN            NUMBER
  ,p_duration_units          IN            VARCHAR2
  ,p_approval_flag           IN            VARCHAR2
  ,p_comments                IN            VARCHAR2
  ,p_object_version_number   IN OUT nocopy NUMBER
  ,p_return_status              OUT nocopy VARCHAR2
  )
  IS
  --
  --Cursor to get current Situation details
    CURSOR csr_current_situation_dtls(p_emp_stat_situation_id IN NUMBER) IS
    SELECT emp_stat_situation_id, person_id, statutory_situation_id,approval_flag,
           actual_start_date,provisional_start_date, actual_end_date, provisional_end_date,
           renewal_flag, renew_stat_situation_id, object_version_number
      FROM pqh_fr_emp_stat_situations
     WHERE emp_stat_situation_id = p_emp_stat_situation_id;
  --
  --Cursor to get most recent Renewal Situation details
    CURSOR csr_renew_situation_dtls(p_renew_emp_stat_sit_id IN NUMBER) IS
    SELECT emp_stat_situation_id, person_id, statutory_situation_id, approval_flag,
           actual_start_date, provisional_start_date,
           actual_end_date, provisional_end_date, object_version_number
      FROM pqh_fr_emp_stat_situations
     WHERE renew_stat_situation_id = p_renew_emp_stat_sit_id
       AND renewal_flag            = 'Y'
       AND NVL(actual_start_date,provisional_start_date)
                                   = (SELECT MAX(NVL(actual_start_date,provisional_start_date))
                                        FROM pqh_fr_emp_stat_situations
                                       WHERE renew_stat_situation_id = p_renew_emp_stat_sit_id
                                         AND renewal_flag = 'Y');
  --
  --Cursor for fetching In Activity Normal Default Situation existing after the Situation being renewed.
    CURSOR csr_get_iand_dtls(p_person_id NUMBER,
                             p_end_date  DATE) IS
    SELECT emp_stat_situation_id, statutory_situation_id, object_version_number,
           provisional_end_date, actual_end_date
      FROM pqh_fr_emp_stat_situations
     WHERE person_id = p_person_id
       AND statutory_situation_id IN(SELECT statutory_situation_id
                                       FROM pqh_fr_stat_situations_v sit
                                           ,per_shared_types_vl      sh
                                      WHERE sh.shared_type_id     = type_of_ps
                                        AND sh.system_type_cd     = NVL(PQH_FR_UTILITY.get_bg_type_of_ps,sh.system_type_cd)
                                        AND sit.business_group_id = HR_GENERAL.get_business_group_id
                                        AND sit.default_flag      = 'Y'
                                        AND sit.situation_type    = 'IA'
                                        AND sit.sub_type          = 'IA_N'
                                        AND TRUNC(p_end_date+1)   BETWEEN
                                            sit.date_from AND NVL(sit.date_to,HR_GENERAL.end_of_time))
       AND TRUNC(NVL(actual_start_date,provisional_start_date)) = TRUNC(p_end_date+1);
  --
  --Variable Declaration
    l_proc                  VARCHAR2(72) := g_package||'renew_emp_stat_situation';
    l_validate              BOOLEAN;
    l_emp_stat_situation_id PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_object_version_number PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_renew_start_date      PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_renew_end_date        PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_iand_emp_stat_sit_id  PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_iand_stat_sit_id      PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_iand_ovn              PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_iand_prov_end_date    PQH_FR_EMP_STAT_SITUATIONS.provisional_end_date%TYPE;
    l_iand_act_end_date     PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_new_emp_sit_id        PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_new_sit_ovn           PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_rn_emp_stat_sit_id    PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_rn_person_id          PQH_FR_EMP_STAT_SITUATIONS.person_id%TYPE;
    l_rn_stat_sit_id        PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_rn_approval_flag      PQH_FR_EMP_STAT_SITUATIONS.approval_flag%TYPE;
    l_rn_act_st_date        PQH_FR_EMP_STAT_SITUATIONS.actual_start_date%TYPE;
    l_rn_prov_st_date       PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_rn_act_end_date       PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_rn_prov_end_date      PQH_FR_EMP_STAT_SITUATIONS.provisional_end_date%TYPE;
    l_rn_renewal_flag       PQH_FR_EMP_STAT_SITUATIONS.renewal_flag%TYPE;
    l_rn_renew_stat_sit_id  PQH_FR_EMP_STAT_SITUATIONS.renew_stat_situation_id%TYPE;
    l_rn_ovn                PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
  --
  BEGIN
  --
  --Log entry
    HR_UTILITY.set_location(' Entering: '||l_proc, 10);
  --
  --Issue savepoint
    SAVEPOINT pre_state;
  --
  --Initialise Multiple Message Detection
    HR_MULTI_MESSAGE.enable_message_list;
  --
  --Convert constant values to their corresponding boolean value
    l_validate := HR_API.constant_to_boolean(p_constant_value => p_validate);
  --
  -- Remember IN OUT parameter IN values
    l_emp_stat_situation_id := p_emp_stat_situation_id;
    l_object_version_number := p_object_version_number;
  --
  --Get current situation details.
    OPEN csr_current_situation_dtls(p_emp_stat_situation_id);
    FETCH csr_current_situation_dtls INTO l_rn_emp_stat_sit_id,l_rn_person_id,
                                          l_rn_stat_sit_id,l_rn_approval_flag,
                                          l_rn_act_st_date,l_rn_prov_st_date,
                                          l_rn_act_end_date,l_rn_prov_end_date,
                                          l_rn_renewal_flag,l_rn_renew_stat_sit_id,l_rn_ovn;
    IF csr_current_situation_dtls%NOTFOUND THEN
       CLOSE csr_current_situation_dtls;
       FND_MESSAGE.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_current_situation_dtls;
  --
  --If Situation has been renewed earlier then get latest renewal record.
    IF l_rn_renewal_flag = 'Y' AND l_rn_renew_stat_sit_id IS NOT NULL THEN
       OPEN csr_renew_situation_dtls(l_rn_renew_stat_sit_id);
       FETCH csr_renew_situation_dtls INTO l_rn_emp_stat_sit_id,l_rn_person_id,l_rn_stat_sit_id,
                                           l_rn_approval_flag,l_rn_act_st_date,l_rn_prov_st_date,
                                           l_rn_act_end_date,l_rn_prov_end_date,l_rn_ovn;
       IF csr_renew_situation_dtls%NOTFOUND THEN
          CLOSE csr_renew_situation_dtls;
          FND_MESSAGE.set_name('PQH', 'FR_PQH_STS_RENEW_NOT_FND'); --Cannot find latest renewal for the Situation.
          HR_MULTI_MESSAGE.ADD;
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
       CLOSE csr_renew_situation_dtls;
    END IF;
  --
  --Calculate duration
    l_renew_start_date := NVL(l_rn_act_end_date,l_rn_prov_end_date);
    IF p_duration_units = 'D' THEN
       l_renew_end_date := l_renew_start_date + p_renewal_duration;
    ELSIF p_duration_units = 'W' THEN
       l_renew_end_date := l_renew_start_date + p_renewal_duration*7;
    ELSIF p_duration_units = 'M' THEN
       l_renew_end_date := ADD_MONTHS(l_renew_start_date,p_renewal_duration);
    ELSIF p_duration_units = 'Y' THEN
       l_renew_end_date := ADD_MONTHS(l_renew_start_date,p_renewal_duration*12);
    ELSE
       FND_MESSAGE.set_name('PQH','FR_PQH_STS_INVALID_UNITS');
       HR_MULTI_MESSAGE.add;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Check if In Activity Normal Default situation exists.
    OPEN csr_get_iand_dtls(l_rn_person_id,l_renew_start_date);
    FETCH csr_get_iand_dtls INTO l_iand_emp_stat_sit_id,l_iand_stat_sit_id,l_iand_ovn,
                                 l_iand_prov_end_date,l_iand_act_end_date;
    IF csr_get_iand_dtls%NOTFOUND THEN
       CLOSE csr_get_iand_dtls;
       FND_MESSAGE.set_name('PQH','FR_PQH_IAND_NOT_FND'); --Cannot Renew/Reinstate because this Situation has already been Renewed or Reinstated.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_get_iand_dtls;
  --
  --Check whether IAND exists for entire duration of the Renewal.
    IF l_renew_end_date > NVL(l_iand_act_end_date,NVL(l_iand_prov_end_date,HR_GENERAL.end_of_time)) THEN
       FND_MESSAGE.set_name('PQH','FR_PQH_IAND_NOT_FND'); --Cannot Renew/Reinstate because this Situation has already been Renewed or Reinstated.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Update Actual End Date of current/most recent renewal situation.
    pqh_fr_emp_stat_situation_api.update_emp_stat_situation
       (p_effective_date        => l_renew_start_date
       ,p_emp_stat_situation_id => l_rn_emp_stat_sit_id
       ,p_actual_end_date       => TRUNC(l_renew_start_date)
       ,p_object_version_number => l_rn_ovn);
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Create a new Renewal Situation record for the Renew duration.
    pqh_fr_emp_stat_situation_api.create_emp_stat_situation
       (p_effective_date          => TRUNC(l_renew_start_date+1)
       ,p_emp_stat_situation_id   => l_new_emp_sit_id
       ,p_statutory_situation_id  => l_rn_stat_sit_id
       ,p_person_id               => l_rn_person_id
       ,p_provisional_start_date  => TRUNC(l_renew_start_date+1)
       ,p_provisional_end_date    => TRUNC(l_renew_end_date)
       ,p_approval_flag           => p_approval_flag
       ,p_comments                => p_comments
       ,p_renewal_flag            => 'Y'
       ,p_renew_stat_situation_id => l_emp_stat_situation_id
       ,p_object_version_number   => l_new_sit_ovn);
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Update Start Date of IAND situation (IAND = In Activity Normal Default)
    pqh_fr_emp_stat_situation_api.update_emp_stat_situation
       (p_effective_date         => TRUNC(l_renew_end_date+1)
       ,p_emp_stat_situation_id  => l_iand_emp_stat_sit_id --Update this IAND rec
       ,p_statutory_situation_id => l_iand_stat_sit_id
       ,p_provisional_start_date => TRUNC(l_renew_end_date+1)
       ,p_actual_start_date      => TRUNC(l_renew_end_date+1)
       ,p_approval_flag          => 'Y'
       ,p_comments               => p_comments
       ,p_object_version_number  => l_iand_ovn);
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Update Assignment to reflect the Renewal.
    updt_assign(l_rn_person_id
               ,l_rn_stat_sit_id
               ,l_iand_stat_sit_id
               ,TRUNC(l_renew_start_date+1)
               ,TRUNC(l_renew_end_date));
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
/*
  --Update_assignment to reflect the Renewal.
    pqh_fr_emp_stat_situation_api.update_assignments
       (p_person_id              => l_rn_person_id
       ,p_statutory_situation_id => l_iand_stat_sit_id
       ,p_start_date             => TRUNC(l_renew_end_date+1)
       ,p_end_date               => TRUNC(NVL(l_iand_act_end_date,NVL(l_iand_prov_end_date,HR_GENERAL.end_of_time))));
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
*/
    p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
    HR_UTILITY.set_location(' Leaving: '||l_proc, 20);
  --
  EXCEPTION
    WHEN HR_MULTI_MESSAGE.error_message_exist THEN
         --Catch Multiple Message List exception
         ROLLBACK TO pre_state;
         --Reset IN OUT parameters and set OUT parameters
         p_emp_stat_situation_id := l_emp_stat_situation_id;
         p_object_version_number := l_object_version_number;
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving:' || l_proc, 30);
    WHEN others THEN
         --When Multiple Message Detection is enabled catch any Application specific or other unexpected exceptions.
         --Adding appropriate details to Multiple Message List. Otherwise re-raise the error.
         ROLLBACK TO pre_state;
         IF HR_MULTI_MESSAGE.unexpected_error_add(l_proc) THEN
            HR_UTILITY.set_location(' Leaving: '||l_proc, 40);
            RAISE;
         END IF;
         --Reset IN OUT and set OUT parameters
         p_emp_stat_situation_id := l_emp_stat_situation_id;
         p_object_version_number := l_object_version_number;
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving: '||l_proc, 50);
  END renew_emp_stat_situation;
  --
  -- ---------------------------------------------------------------------------
  -- |-----------------------< delete_emp_stat_situation >----------------------
  -- ---------------------------------------------------------------------------
  PROCEDURE delete_emp_stat_situation
  (p_validate              IN     NUMBER DEFAULT HR_API.g_false_num
  ,p_emp_stat_situation_id IN     NUMBER
  ,p_object_version_number IN     NUMBER
  ,p_return_status            OUT nocopy VARCHAR2
  )
  IS
  --
  --Cursor to get current Situation details
    CURSOR csr_current_situation_dtls(p_emp_stat_situation_id IN NUMBER) IS
    SELECT person_id, actual_start_date, provisional_start_date, actual_end_date, provisional_end_date
      FROM pqh_fr_emp_stat_situations
     WHERE emp_stat_situation_id = p_emp_stat_situation_id;
  --
  --Cursor to fetch prior Situation falling before the Situation to be deleted
    CURSOR csr_get_prior_sit_dtls(p_person_id IN NUMBER,
                                  p_date      IN DATE) IS
    SELECT emp_stat_situation_id, statutory_situation_id, object_version_number,
           provisional_start_date, actual_start_date, provisional_end_date, actual_end_date
      FROM pqh_fr_emp_stat_situations
     WHERE person_id                                        = p_person_id
       AND TRUNC(NVL(actual_end_date,provisional_end_date)) = TRUNC(p_date-1);
  --
  --Cursor to fetch future Situation falling after the Situation to be deleted
    CURSOR csr_get_next_sit_dtls(p_person_id IN NUMBER,
                                 p_date      IN DATE) IS
    SELECT emp_stat_situation_id, statutory_situation_id, object_version_number,
           provisional_end_date, actual_end_date
      FROM pqh_fr_emp_stat_situations
     WHERE person_id                                            = p_person_id
       AND TRUNC(NVL(actual_start_date,provisional_start_date)) = TRUNC(p_date+1);
  --
  -- Variable Declaration
    l_proc                  VARCHAR2(72) := g_package||'delete_emp_stat_situation';
    l_validate              BOOLEAN;
    l_person_id                PQH_FR_EMP_STAT_SITUATIONS.person_id%TYPE;
    l_act_st_dt                PQH_FR_EMP_STAT_SITUATIONS.actual_start_date%TYPE;
    l_prov_st_dt               PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_act_end_dt               PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_prov_end_dt              PQH_FR_EMP_STAT_SITUATIONS.provisional_end_date%TYPE;
    l_prior_emp_stat_sit_id    PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_prior_sit_id             PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_prior_ovn                PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_prior_prov_st_date       PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_prior_act_st_date        PQH_FR_EMP_STAT_SITUATIONS.actual_start_date%TYPE;
    l_prior_prov_end_date      PQH_FR_EMP_STAT_SITUATIONS.provisional_start_date%TYPE;
    l_prior_act_end_date       PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_next_emp_stat_sit_id     PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_next_sit_id              PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_next_ovn                 PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
    l_next_prov_end_date       PQH_FR_EMP_STAT_SITUATIONS.provisional_end_date%TYPE;
    l_next_act_end_date        PQH_FR_EMP_STAT_SITUATIONS.actual_end_date%TYPE;
    l_iand_sit_id              PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_new_iand_emp_stat_sit_id PQH_FR_EMP_STAT_SITUATIONS.emp_stat_situation_id%TYPE;
    l_new_iand_ovn             PQH_FR_EMP_STAT_SITUATIONS.object_version_number%TYPE;
  --
  BEGIN
  --
  --Log entry
    HR_UTILITY.set_location(' Entering: '||l_proc, 10);
  --
  --Issue savepoint
    SAVEPOINT pre_state;
  --
  --Initialise Multiple Message Detection
    HR_MULTI_MESSAGE.enable_message_list;
  --
  --Convert constant values to their corresponding boolean value
    l_validate := HR_API.constant_to_boolean(p_constant_value => p_validate);
  --
  --Fetch details of Situation to be deleted.
    OPEN csr_current_situation_dtls(p_emp_stat_situation_id);
    FETCH csr_current_situation_dtls INTO l_person_id, l_act_st_dt, l_prov_st_dt,
                                          l_act_end_dt, l_prov_end_dt;
    IF csr_current_situation_dtls%NOTFOUND THEN
       CLOSE csr_current_situation_dtls;
       FND_MESSAGE.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_current_situation_dtls;
  --
  --Fetch details for prior Situation ending on current situations start date - 1
    OPEN csr_get_prior_sit_dtls(l_person_id,TRUNC(NVL(l_act_st_dt,l_prov_st_dt)));
    FETCH csr_get_prior_sit_dtls INTO l_prior_emp_stat_sit_id, l_prior_sit_id, l_prior_ovn,
                                      l_prior_prov_st_date, l_prior_act_st_date,
                                      l_prior_prov_end_date, l_prior_act_end_date;
    IF csr_get_prior_sit_dtls%NOTFOUND THEN
       CLOSE csr_get_prior_sit_dtls;
       FND_MESSAGE.set_name('PQH','FR_PQH_PRIOR_SIT_NOT_FND'); --Cannot Update/Delete because no situation exists prior to this situation.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_get_prior_sit_dtls;
  --
  --Fetch details of future Situation starting from current situations end date + 1
    OPEN csr_get_next_sit_dtls(l_person_id,TRUNC(NVL(l_act_end_dt,l_prov_end_dt)));
    FETCH csr_get_next_sit_dtls INTO l_next_emp_stat_sit_id, l_next_sit_id, l_next_ovn,
                                      l_next_prov_end_date, l_next_act_end_date;
    IF csr_get_next_sit_dtls%NOTFOUND THEN
       CLOSE csr_get_next_sit_dtls;
       FND_MESSAGE.set_name('PQH','FR_PQH_NEXT_SIT_NOT_FND'); --Cannot Update/Delete because no situation exists after this situation.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
    CLOSE csr_get_next_sit_dtls;
  --
  --Get In Activity Normal Default Situation Id
    l_iand_sit_id:= PQH_FR_STAT_SIT_UTIL.get_dflt_situation
                       (p_business_group_id => HR_GENERAL.get_business_group_id
                       ,p_effective_date    => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
                       ,p_situation_type    => 'IA'
                       ,p_sub_type          => 'IA_N');
    IF l_iand_sit_id = -1 THEN
       FND_MESSAGE.set_name('PQH','FR_PQH_STS_NO_DFLT_SIT'); --In Activity Normal Default Situation does not exist.
       HR_MULTI_MESSAGE.ADD;
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Call API to delete the current Situation
    pqh_fr_emp_stat_situation_api.delete_emp_stat_situation
       (p_validate              => l_validate
       ,p_emp_stat_situation_id => p_emp_stat_situation_id
       ,p_object_version_number => p_object_version_number);
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --Update Assignment to reflect the delete.
    updt_assign(l_person_id
               ,l_iand_sit_id
               ,l_iand_sit_id
               ,TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
               ,TRUNC(NVL(l_act_end_dt,l_prov_end_dt)));
    IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
       RAISE HR_MULTI_MESSAGE.error_message_exist;
    END IF;
  --
  --If previous Situation is a IAND situation and future Situation is a IAND situation.
    IF l_prior_sit_id = l_iand_sit_id AND l_next_sit_id = l_iand_sit_id THEN
     --
     --Call API to delete the next IAND situation.
       pqh_fr_emp_stat_situation_api.delete_emp_stat_situation
          (p_validate              => l_validate
          ,p_emp_stat_situation_id => l_next_emp_stat_sit_id
          ,p_object_version_number => l_next_ovn);
       IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
     --
     --Update prior situations end date to next IAND's end date.
       pqh_fr_emp_stat_situation_api.update_emp_stat_situation
          (p_effective_date         => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
          ,p_emp_stat_situation_id  => l_prior_emp_stat_sit_id --Update this IAND rec
          ,p_statutory_situation_id => l_prior_sit_id
          ,p_provisional_end_date   => TRUNC(l_next_prov_end_date)
          ,p_actual_end_date        => TRUNC(l_next_act_end_date)
          ,p_approval_flag          => 'Y'
          ,p_object_version_number  => l_prior_ovn);
       IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
     --
  --Else if prior Situation is not a IAND Situation and future Situation is a IAND Situation.
    ELSIF l_prior_sit_id <> l_iand_sit_id AND l_next_sit_id = l_iand_sit_id THEN
     --
     --Update prior sits actual end date to end of time, if deleted sits actual end date is end of time.
       IF TRUNC(NVL(l_act_end_dt,HR_GENERAL.end_of_time)) = TRUNC(HR_GENERAL.end_of_time) THEN
          pqh_fr_emp_stat_situation_api.update_emp_stat_situation
             (p_effective_date         => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
             ,p_emp_stat_situation_id  => l_prior_emp_stat_sit_id --Update this IAND rec
             ,p_statutory_situation_id => l_prior_sit_id
             ,p_actual_end_date        => TRUNC(l_act_end_dt)
             ,p_approval_flag          => 'Y'
             ,p_object_version_number  => l_prior_ovn);
          IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
             RAISE HR_MULTI_MESSAGE.error_message_exist;
          END IF;
       END IF;
     --
     --Update the Next IAND Situation's start date to deleted Situations start date
       pqh_fr_emp_stat_situation_api.update_emp_stat_situation
          (p_effective_date         => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
          ,p_emp_stat_situation_id  => l_next_emp_stat_sit_id --Update this IAND rec
          ,p_statutory_situation_id => l_next_sit_id
          ,p_provisional_start_date => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
          ,p_actual_start_date      => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
          ,p_approval_flag          => 'Y'
          ,p_object_version_number  => l_next_ovn);
       IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
     --
  --Else if prior Situation is not a IAND Situation and future Situation is not a IAND Situation.
    ELSIF l_prior_sit_id <> l_iand_sit_id AND l_next_sit_id <> l_iand_sit_id THEN
     --
     --Create a IAND Situation for the duration of Delete Siutation.
       pqh_fr_emp_stat_situation_api.create_emp_stat_situation
          (p_effective_date         => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
          ,p_emp_stat_situation_id  => l_new_iand_emp_stat_sit_id
          ,p_statutory_situation_id => l_iand_sit_id
          ,p_person_id              => l_person_id
          ,p_provisional_start_date => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
          ,p_provisional_end_date   => TRUNC(NVL(l_act_end_dt,l_prov_end_dt))
          ,p_actual_start_date      => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
          ,p_actual_end_date        => TRUNC(l_act_end_dt)
          ,p_approval_flag          => 'Y'
          ,p_object_version_number  => l_new_iand_ovn);
       IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
     --
  --Else if prior Situation is a IAND Situation and future Situation is not a IAND Situation.
    ELSIF l_prior_sit_id = l_iand_sit_id AND l_next_sit_id <> l_iand_sit_id THEN
     --
     --Update the prior IAND Situation's end date to deleted Situations end date
       pqh_fr_emp_stat_situation_api.update_emp_stat_situation
          (p_effective_date         => TRUNC(NVL(l_act_st_dt,l_prov_st_dt))
          ,p_emp_stat_situation_id  => l_prior_emp_stat_sit_id --Update this IAND rec
          ,p_statutory_situation_id => l_prior_sit_id
          ,p_provisional_end_date   => TRUNC(NVL(l_act_end_dt,l_prov_end_dt))
          ,p_actual_end_date        => TRUNC(NVL(l_act_end_dt,l_prov_end_dt))
          ,p_approval_flag          => 'Y'
          ,p_object_version_number  => l_prior_ovn);
       IF HR_MULTI_MESSAGE.get_return_status = 'E' THEN
          RAISE HR_MULTI_MESSAGE.error_message_exist;
       END IF;
     --
    END IF;
  --
    p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
    HR_UTILITY.set_location(' Leaving: '||l_proc, 20);
  --
  EXCEPTION
    WHEN HR_MULTI_MESSAGE.error_message_exist THEN
         --Catch Multiple Message List exception
         ROLLBACK TO pre_state;
         --Reset IN OUT parameters and set OUT parameters
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving:' || l_proc, 30);
    WHEN others THEN
         --When Multiple Message Detection is enabled catch any Application specific or other unexpected exceptions.
         --Adding appropriate details to Multiple Message List. Otherwise re-raise the error.
         ROLLBACK TO pre_state;
         IF HR_MULTI_MESSAGE.unexpected_error_add(l_proc) THEN
            HR_UTILITY.set_location(' Leaving: '||l_proc, 40);
            RAISE;
         END IF;
         --Reset IN OUT and set OUT parameters
         p_return_status := HR_MULTI_MESSAGE.get_return_status_disable;
         HR_UTILITY.set_location(' Leaving: '||l_proc, 50);
  END delete_emp_stat_situation;
  --
  --
  -- ---------------------------------------------------------------------------
  -- |---------------------------< update_assignments >-------------------------
  -- ---------------------------------------------------------------------------
  PROCEDURE updt_assign(p_person_id              IN NUMBER
                       ,p_statutory_situation_id IN NUMBER
                       ,p_iand_stat_sit_id       IN NUMBER DEFAULT NULL
                       ,p_start_date             IN DATE
                       ,p_end_date               IN DATE)
  IS
  --
  --Cursor to get current Situation details
    CURSOR csr_asg_dtls IS
    SELECT asg.assignment_id, asg.effective_start_date, asg.effective_end_date, ast.per_system_status
      FROM per_all_assignments_f       asg,
           per_assignment_status_types ast
     WHERE asg.person_id                         = p_person_id
       AND(TRUNC(asg.effective_start_date) BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date)
        OR TRUNC(asg.effective_end_date)   BETWEEN TRUNC(p_start_date) AND TRUNC(p_end_date))
       AND asg.primary_flag                      = 'Y'
       AND asg.assignment_status_type_id         = ast.assignment_status_type_id
     ORDER BY asg.effective_start_date;
  --
  --Varialbe Declarations
    l_start_date DATE;
    l_end_date   DATE;
    l_count      NUMBER;
  --
  BEGIN
  --
  --Fetch Assignments that are affected.
    l_count := 0;
    FOR lr_asg IN csr_asg_dtls
    LOOP
      --
        l_count      := l_count+1;
        l_start_date := lr_asg.effective_start_date;
        l_end_date   := lr_asg.effective_end_date;
      --
/*
      --Check whether Assignment starts before the Situation.
        IF lr_asg.per_system_status <> 'ACTIVE_ASSIGN' AND TRUNC(p_start_date) > TRUNC(l_start_date) THEN
         --
         --Set prior Assignment to Active on its effective date date.
           pqh_fr_emp_stat_situation_api.update_assignments
              (p_person_id              => p_person_id
              ,p_statutory_situation_id => p_iand_stat_sit_id
              ,p_start_date             => TRUNC(l_start_date)
              ,p_end_date               => TRUNC(l_end_date));
         --
        END IF;
      --
*/
        IF l_count = 1 THEN
         --For first loop, we want to Update Assignment on Situations Start Date.
           l_start_date := p_start_date;
        END IF;
      --
      --Update all Assignments withing the Situation Duration to reflect Situation Status.
        pqh_fr_emp_stat_situation_api.update_assignments
           (p_person_id              => p_person_id
           ,p_statutory_situation_id => p_statutory_situation_id
           ,p_start_date             => TRUNC(l_start_date)
           ,p_end_date               => TRUNC(l_end_date));
      --
        IF TRUNC(p_end_date) < TRUNC(l_end_date) THEN
         --
           pqh_fr_emp_stat_situation_api.update_assignments
              (p_person_id              => p_person_id
              ,p_statutory_situation_id => p_iand_stat_sit_id
              ,p_start_date             => TRUNC(p_end_date+1)
              ,p_end_date               => TRUNC(l_end_date));
         --
        END IF;
      --
    END LOOP;
  --
  --If no Assignment are within Situation duration then Update Assignment just once for Situation.
    IF l_count = 0 THEN
       pqh_fr_emp_stat_situation_api.update_assignments
          (p_person_id              => p_person_id
          ,p_statutory_situation_id => p_statutory_situation_id
          ,p_start_date             => TRUNC(p_start_date)
          ,p_end_date               => TRUNC(p_end_date));
     --
       pqh_fr_emp_stat_situation_api.update_assignments
          (p_person_id              => p_person_id
          ,p_statutory_situation_id => p_iand_stat_sit_id
          ,p_start_date             => TRUNC(p_end_date+1));
    END IF;
  --
  END updt_assign;
  --
  --
  -- ---------------------------------------------------------------------------
  -- --------------------------< is_person_active >-----------------------------
  -- ---------------------------------------------------------------------------
  FUNCTION is_person_active
  (p_person_id      IN NUMBER,
   p_effective_date IN DATE) RETURN VARCHAR2
  IS
  --
  --Cursor to fetch Situation as on effective date.
    CURSOR csr_emp_sit_dtls IS
    SELECT statutory_situation_id
      FROM pqh_fr_emp_stat_situations
     WHERE person_id              = p_person_id
       AND p_effective_date BETWEEN NVL(actual_start_date,provisional_start_date)
                                AND NVL(actual_end_date,NVL(provisional_end_date,HR_GENERAL.end_of_time));
  --
  --Varialbe Declarations.
    l_default_sit_id PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_sit_id         PQH_FR_EMP_STAT_SITUATIONS.statutory_situation_id%TYPE;
    l_is_active      VARCHAR2(10) := NULL;
  --
  BEGIN
  --
  --Get Situation Id as on effective date.
    OPEN csr_emp_sit_dtls;
    FETCH csr_emp_sit_dtls INTO l_sit_id;
    IF csr_emp_sit_dtls%NOTFOUND THEN
       CLOSE csr_emp_sit_dtls;
       l_is_active := 'E';
       RETURN l_is_active;
    END IF;
    IF csr_emp_sit_dtls%ISOPEN THEN
       CLOSE csr_emp_sit_dtls;
    END IF;
  --
  --Get In Activity Normal Default Situation Id.
    l_default_sit_id:= PQH_FR_STAT_SIT_UTIL.get_dflt_situation
                          (p_business_group_id => HR_GENERAL.get_business_group_id
                          ,p_effective_date    => p_effective_date
                          ,p_situation_type    => 'IA'
                          ,p_sub_type          => 'IA_N');
  --If Default Situation does not exist then return error.
    IF l_default_sit_id = -1 THEN
       l_is_active := 'E';
    ELSE
     --If Person Situation is In Activity Default Normalthen return 'Y' else 'N'.
       IF l_sit_id = l_default_sit_id THEN
          l_is_active := 'Y';
       ELSE
          l_is_active := 'N';
       END IF;
    END IF;
  --
    RETURN l_is_active;
  --
  END is_person_active;
  --
END PQH_FR_EMP_STAT_SIT_UTILITY;

/
