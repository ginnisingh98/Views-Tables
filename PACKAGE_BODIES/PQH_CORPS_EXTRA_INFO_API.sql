--------------------------------------------------------
--  DDL for Package Body PQH_CORPS_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CORPS_EXTRA_INFO_API" as
/* $Header: pqceiapi.pkb 115.8 2004/01/02 01:35:54 svorugan noship $ */
g_package varchar2(33) := 'pqh_corps_extra_info_api.';
------------------------------------------------------------------------------
-- |------------------------< validate_corps_org_info >------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE validate_corps_org_info(p_effective_date   IN DATE
                                   ,p_corps_definition_id IN NUMBER
                                   ,p_organization_id  IN VARCHAR2
                                   ,p_corps_extra_info_id IN NUMBER DEFAULT NULL) IS
   CURSOR csr_chk_valid_org IS
     SELECT 'Y'
     FROM   DUAL
     WHERE  EXISTS (SELECT 1
                    FROM   hr_all_organization_units
                    WHERE  organization_id = fnd_number.canonical_to_number(p_organization_id)
                    AND    p_effective_date BETWEEN date_from AND NVL(date_to,hr_general.end_of_time));
    l_valid_org varchar2(10) := 'N';
   CURSOR csr_dup_org_chk IS
     SELECT 'Y'
     FROM   DUAL
     WHERE EXISTS (SELECT 1
                   FROM   pqh_corps_extra_info
                   WHERE  corps_definition_id = p_corps_definition_id
                   AND    information_type = 'ORGANIZATION'
                   AND    information3 = p_organization_id
                   AND   (p_corps_extra_info_id IS NULL OR
                          corps_extra_info_id <> p_corps_extra_info_id) );
  l_dup_org  varchar2(10) := 'N';
  l_proc   varchar2(72) := g_package||'.validate_corps_org_info';
  BEGIN
    hr_utility.set_location('Entering '||l_proc,10);
    IF p_organization_id IS NOT NULL THEN
      OPEN csr_chk_valid_org;
      FETCH csr_chk_valid_org INTO l_valid_org;
      CLOSE csr_chk_valid_org;
      IF l_valid_org = 'N' THEN
        hr_utility.set_message(8302,'PQH_FR_INVALID_ORG_FOR_CORPS');
        hr_multi_message.add(p_associated_column1 => 'INFORMATION3');
      END IF;
      OPEN csr_dup_org_chk;
      FETCH csr_dup_org_chk INTO l_dup_org;
      CLOSE csr_dup_org_chk;
      IF l_dup_org = 'Y' THEN
        hr_utility.set_message(8302,'PQH_FR_DUP_ORG_FOR_CORPS');
        hr_multi_message.add(p_associated_column1 => 'INFORMATION3');
      END IF;
    END IF;
    hr_utility.set_location('Leaving '||l_proc,20);
  END validate_corps_org_info;
------------------------------------------------------------------------------
-- |------------------------<validate_corps_prof_field_info>------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE  validate_corps_prof_field_info(p_effective_date         IN DATE
                                           ,p_corps_definition_id    IN NUMBER
                                           ,p_field_of_prof_activity_id IN VARCHAR2
                                           ,p_corps_extra_info_id IN NUMBER DEFAULT NULL) IS
  CURSOR csr_chk_valid_prof_field IS
    SELECT 'Y'
    FROM    dual
    WHERE EXISTS (SELECT 1
                  FROM   per_shared_types
                  WHERE  shared_type_id = fnd_number.canonical_to_number(p_field_of_prof_activity_id));
  l_valid_prof_field  varchar2(10) := 'N';
  l_proc   varchar2(72) := g_package||'.validate_corps_prof_field_info';
  CURSOR csr_dup_prof_field_chk IS
    SELECT 'Y'
    FROM   dual
    WHERE  EXISTS (SELECT 1
                   FROM   pqh_corps_extra_info
                   WHERE  corps_definition_id = p_corps_definition_id
                   AND    information_type    = 'FILERE'
                   AND    information3        = p_field_of_prof_activity_id
                   AND    (p_corps_extra_info_id IS NULL OR corps_extra_info_id <> p_corps_extra_info_id));
    l_dup_prof_field  varchar2(10) := 'N';
  BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
   IF p_field_of_prof_activity_id IS NOT NULL THEN
    OPEN  csr_chk_valid_prof_field;
    FETCH csr_chk_valid_prof_field INTO l_valid_prof_field;
    CLOSE csr_chk_valid_prof_field;
    IF l_valid_prof_field = 'N' THEN
      hr_utility.set_message(8302,'PQH_FR_INVALID_FIELD_OF_PROF');
      hr_multi_message.add(p_associated_column1 => 'INFORMATION3');
    END IF;
    OPEN  csr_dup_prof_field_chk;
    FETCH csr_dup_prof_field_chk INTO l_dup_prof_field;
    CLOSE csr_dup_prof_field_chk;
    IF l_dup_prof_field = 'Y' THEN
      hr_utility.set_message(8302,'PQH_FR_DUP_FIELD_OF_PROF');
      hr_multi_message.add(p_associated_column1 => 'INFORMATION3');
    END IF;
   END IF;
   hr_utility.set_location('Leaving '||l_proc,20);
  END validate_corps_prof_field_info;
------------------------------------------------------------------------------
-- |------------------------<validate_corps_exam_info>------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE validate_corps_exam_info(p_effective_date        IN DATE
  	                            ,p_corps_definition_id   IN NUMBER
  	                            ,p_examination_type_cd   IN VARCHAR2
  	                            ,p_institution_id        IN VARCHAR2
  	                            ,p_joining_way_cd        IN VARCHAR2
  	                            ,p_mandatory_flag        IN VARCHAR2
                                    ,p_exam_name             IN VARCHAR2
  	                            ,p_corps_extra_info_id   IN NUMBER DEFAULT NULL) IS
  CURSOR csr_valid_institution IS
    SELECT 'Y'
    FROM   dual
    WHERE  EXISTS (SELECT 1
                   FROM   hr_all_organization_units
                   WHERE  organization_id = fnd_number.canonical_to_number(p_institution_id)
                   AND    p_effective_date BETWEEN date_from AND nvl(date_to,hr_general.end_of_time));
  l_valid_institution varchar2(10) :='N';
  CURSOR csr_chk_dup_exam IS
    SELECT 'Y'
    FROM   dual
    WHERE  EXISTS (SELECT 1
                   FROM   pqh_corps_extra_info
                   WHERE  information_type = 'EXAM'
                   AND    corps_definition_id = p_corps_definition_id
                   AND    nvl(information3,'#@') = nvl(p_examination_type_cd,'#@')
                   AND    nvl(information4,'#@') = nvl(p_institution_id,'#@')
                   AND    nvl(information5,'#@') = nvl(p_joining_way_cd,'#@')
                   AND    nvl(information7,'#@')  = nvl(p_exam_name,'#@')
                   AND    (p_corps_extra_info_id IS NULL OR corps_extra_info_id <> p_corps_extra_info_id));
   l_dup_exam varchar2(10) := 'N';
   l_proc   varchar2(72) := g_package||'.validate_corps_exam_info';
  BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
   IF p_examination_type_cd IS NOT NULL THEN
     IF hr_api.not_exists_in_hr_lookups(p_effective_date,'PQH_CORPS_EXAM_TYPE',p_examination_type_cd) THEN
       hr_utility.set_message(8302,'PQH_FR_INVALID_EXAM_TYPE');
       hr_multi_message.add(p_associated_column1 => 'INFORMATION3');
     END IF;
   END IF;
   IF p_institution_id IS NOT NULL THEN
     OPEN csr_valid_institution;
     FETCH csr_valid_institution INTO l_valid_institution;
     CLOSE csr_valid_institution;
     IF l_valid_institution = 'N' THEN
       hr_utility.set_message(8302,'PQH_FR_INVALID_INSTITUTION');
       hr_multi_message.add(p_associated_column1 => 'INFORMATION4');
     END IF;
   END IF;
   IF p_joining_way_cd IS NOT NULL THEN
    IF hr_api.not_exists_in_hr_lookups(p_effective_date,'PQH_CORPS_WAYS',p_joining_way_cd) THEN
       hr_utility.set_message(8302,'PQH_FR_INVALID_WAY_FOR_CORPS');
       hr_multi_message.add(p_associated_column1 => 'INFORMATION5');
    END IF;
   END IF;
   hr_multi_message.end_validation_set;
   OPEN csr_chk_dup_exam;
   FETCH csr_chk_dup_exam INTO l_dup_exam;
   CLOSE csr_chk_dup_exam;
   IF l_dup_exam = 'Y' THEN
     hr_utility.set_message(8302,'PQH_FR_DUP_EXAM_FOR_CORPS');
     hr_multi_message.add;
   END IF;
   hr_utility.set_location('Leaving '||l_proc,20);
  END validate_corps_exam_info;

------------------------------------------------------------------------------
-- |------------------------<validate_corps_training_info>------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE  validate_corps_training_info(p_effective_date   IN DATE
                               ,p_corps_definition_id         IN NUMBER
                               ,p_qualification_id            IN VARCHAR2
                               ,p_institution_id              IN VARCHAR2
                               ,p_training_duration           IN VARCHAR2
                               ,p_training_duration_uom       IN VARCHAR2
                               ,p_joining_way_cd              IN VARCHAR2
                               ,p_mandatory_flag              IN VARCHAR2
                               ,p_corps_extra_info_id   IN NUMBER DEFAULT NULL) IS
  CURSOR csr_valid_qualification IS
     SELECT 'Y'
     FROM   dual
     WHERE EXISTS (SELECT 1
                   FROM   per_qualification_types
                   WHERE  qualification_type_id = fnd_number.canonical_to_number(p_qualification_id) );
  l_valid_qualification varchar2(10) := 'N';
  CURSOR csr_valid_institution IS
    SELECT 'Y'
    FROM   dual
    WHERE  EXISTS (SELECT 1
                   FROM   hr_all_organization_units
                   WHERE  organization_id = fnd_number.canonical_to_number(p_institution_id)
                   AND    p_effective_date BETWEEN date_from AND nvl(date_to,hr_general.end_of_time));
  l_valid_institution varchar2(10) :='N';
  CURSOR csr_dup_train_dtls IS
    SELECT 'Y'
    FROM   dual
    WHERE  EXISTS (SELECT 1
                   FROM   pqh_corps_extra_info
                   WHERE  corps_definition_id = p_corps_definition_id
                   AND    information_type = 'TRAINING'
                   AND    nvl(information3,'#@') = nvl(p_qualification_id,'#@')
                   AND    nvl(information4,'#@') = nvl(p_institution_id,'#@')
                   AND    nvl(information5,'#@') = nvl(p_training_duration,'#@')
                   AND    nvl(information6,'#@') = nvl(p_training_duration_uom,'#@')
                   AND    nvl(information7,'#@') = nvl(p_joining_way_cd,'#@')
                   AND    (p_corps_extra_info_id IS NULL OR
                           corps_extra_info_id <> p_corps_extra_info_id) );
   l_dup_train_dtls varchar2(10) := 'N';
   l_proc   varchar2(72) := g_package||'.validate_corps_training_info';
  BEGIN
   hr_utility.set_location('Entering '||l_proc,10);
   IF p_qualification_id IS NOT NULL THEN
     OPEN csr_valid_qualification;
     FETCH csr_valid_qualification INTO l_valid_qualification;
     CLOSE csr_valid_qualification;
     IF l_valid_qualification = 'N' THEN
       hr_utility.set_message(8302,'PQH_FR_INVALID_QUALIFICATION');
       hr_multi_message.add(p_associated_column1 => 'INFORMATION3');
     END IF;
   END IF;
   IF p_institution_id IS NOT NULL THEN
     OPEN csr_valid_institution;
     FETCH csr_valid_institution INTO l_valid_institution;
     CLOSE csr_valid_institution;
     IF l_valid_institution = 'N' THEN
       hr_utility.set_message(8302,'PQH_FR_INVALID_INSTITUTION');
       hr_multi_message.add(p_associated_column1 => 'INFORMATION4');
     END IF;
   END IF;
   -- Added validation for training duration ( +ve value )
   IF p_training_duration IS NOT NULL THEN
   -- Added = for bug fix 3344339
   if (p_training_duration <= 0) then
   --
       hr_utility.set_message(8302,'PQH_FR_INVALID_DURATION');
       hr_multi_message.add(p_associated_column1 => 'INFORMATION5');
  --
   end if;
  --
  End if;

  IF p_training_duration_uom IS NOT NULL THEN
    IF hr_api.not_exists_in_hr_lookups(p_effective_date,'FREQUENCY',p_training_duration_uom) THEN
       hr_utility.set_message(8302,'PQH_FR_INVALID_DURATION_UNITS');
       hr_multi_message.add(p_associated_column1 => 'INFORMATION6');
    END IF;
   END IF;
   IF p_joining_way_cd IS NOT NULL THEN
    IF hr_api.not_exists_in_hr_lookups(p_effective_date,'PQH_CORPS_WAYS',p_joining_way_cd) THEN
       hr_utility.set_message(8302,'PQH_FR_INVALID_WAY_FOR_CORPS');
       hr_multi_message.add(p_associated_column1 => 'INFORMATION7');
    END IF;
   END IF;
   hr_multi_message.end_validation_set;
   OPEN csr_dup_train_dtls ;
   FETCH csr_dup_train_dtls  INTO l_dup_train_dtls ;
   CLOSE csr_dup_train_dtls ;
   IF l_dup_train_dtls  = 'Y' THEN
     hr_utility.set_message(8302,'PQH_FR_DUP_TRAINING_FOR_CORPS');
     hr_multi_message.add;
   END IF;
   hr_utility.set_location('Leaving '||l_proc,20);
  END validate_corps_training_info;


------------------------------------------------------------------------------
-- |------------------------<chk_prim_field_for_corps>------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE chk_prim_field_for_corps(p_corps_extra_info_id  IN NUMBER) IS
   CURSOR csr_prim_field_for_corps IS
     SELECT 'Y'
     FROM   dual
     WHERE  EXISTS (SELECT 1
                    FROM   pqh_corps_definitions cpd,
                           pqh_corps_extra_info cei
                    WHERE  cei.information_type = 'FILERE'
                    AND    cei.corps_definition_id = cpd.corps_definition_id
                    AND    fnd_number.canonical_to_number(nvl(cei.information4,'-1')) = nvl(primary_prof_field_id,-1)
                    AND    corps_extra_info_id  = p_corps_extra_info_id);
   l_primary_flag   varchar2(10) := 'N';
   l_proc   varchar2(72) := g_package||'.chk_prim_field_for_corps';
  BEGIN
    hr_utility.set_location('Entering '||l_proc,10);
    OPEN csr_prim_field_for_corps;
    FETCH csr_prim_field_for_corps INTO l_primary_flag;
    CLOSE csr_prim_field_for_corps;
    IF l_primary_flag = 'Y' THEN
       hr_utility.set_message(8302,'PQH_FR_CANNOT_DEL_PRIM_FIELD');
       hr_multi_message.add;
    END IF;
    hr_utility.set_location('Leaving '||l_proc,20);
  END chk_prim_field_for_corps;

--
-- ----------------------------------------------------------------------------
-- |------------------------< create_corps_extra_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
-- Name                           Reqd     Type     Description
-- p_validate                      YES     boolean  Commit or Rollback
-- p_effective_date                YES     date
-- p_corps_definition_id           NO      number
-- p_information_type              NO      varchar2
-- p_information1                  NO      varchar2
-- p_information2                  NO      varchar2
-- p_information3                  NO      varchar2
-- p_information4                  NO      varchar2
-- p_information5                  NO      varchar2
-- p_information6                  NO      varchar2
-- p_information7                  NO      varchar2
-- p_information8                  NO      varchar2
-- p_information9                  NO      varchar2
-- p_information10                 NO      varchar2
-- p_information11                 NO      varchar2
-- p_information12                 NO      varchar2
-- p_information13                 NO      varchar2
-- p_information14                 NO      varchar2
-- p_information15                 NO      varchar2
-- p_information16                 NO      varchar2
-- p_information17                 NO      varchar2
-- p_information18                 NO      varchar2
-- p_information19                 NO      varchar2
-- p_information20                 NO      varchar2
-- p_information21                 NO      varchar2
-- p_information22                 NO      varchar2
-- p_information23                 NO      varchar2
-- p_information24                 NO      varchar2
-- p_information25                 NO      varchar2
-- p_information26                 NO      varchar2
-- p_information27                 NO      varchar2
-- p_information28                 NO      varchar2
-- p_information29                 NO      varchar2
-- p_information30                 NO      varchar2
-- p_information_category          NO      varchar2
-- p_attribute1                    NO      varchar2
-- p_attribute2                    NO      varchar2
-- p_attribute3                    NO      varchar2
-- p_attribute4                    NO      varchar2
-- p_attribute5                    NO      varchar2
-- p_attribute6                    NO      varchar2
-- p_attribute7                    NO      varchar2
-- p_attribute8                    NO      varchar2
-- p_attribute9                    NO      varchar2
-- p_attribute10                   NO      varchar2
-- p_attribute11                   NO      varchar2
-- p_attribute12                   NO      varchar2
-- p_attribute13                   NO      varchar2
-- p_attribute14                   NO      varchar2
-- p_attribute15                   NO      varchar2
-- p_attribute16                   NO      varchar2
-- p_attribute17                   NO      varchar2
-- p_attribute18                   NO      varchar2
-- p_attribute19                   NO      varchar2
-- p_attribute20                   NO      varchar2
-- p_attribute21                   NO      varchar2
-- p_attribute22                   NO      varchar2
-- p_attribute23                   NO      varchar2
-- p_attribute24                   NO      varchar2
-- p_attribute25                   NO      varchar2
-- p_attribute26                   NO      varchar2
-- p_attribute27                   NO      varchar2
-- p_attribute28                   NO      varchar2
-- p_attribute29                   NO      varchar2
-- p_attribute30                   NO      varchar2
-- p_attribute_category            NO      varchar2

-- Post Success:
--
-- Out Parameters:
--   Name                          Reqd   Type      Description
--   p_object_version_number        Yes   number    OVN of record
--   p_corps_extra_info_id          Yes   number
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_corps_extra_info
(
  p_validate                      in     boolean   default false
  ,p_effective_date               in     date
  ,p_corps_extra_info_id          out nocopy    number
  ,p_corps_definition_id          in     number
  ,p_information_type             in    varchar2
  ,p_information1                 in    varchar2   default null
  ,p_information2                 in    varchar2   default null
  ,p_information3                 in    varchar2   default null
  ,p_information4                 in    varchar2   default null
  ,p_information5                 in    varchar2   default null
  ,p_information6                 in    varchar2   default null
  ,p_information7                 in    varchar2   default null
  ,p_information8                 in    varchar2   default null
  ,p_information9                 in    varchar2   default null
  ,p_information10                in    varchar2   default null
  ,p_information11                in    varchar2   default null
  ,p_information12                in    varchar2   default null
  ,p_information13                in    varchar2   default null
  ,p_information14                in    varchar2   default null
  ,p_information15                in    varchar2   default null
  ,p_information16                in    varchar2   default null
  ,p_information17                in    varchar2   default null
  ,p_information18                in    varchar2   default null
  ,p_information19                in    varchar2   default null
  ,p_information20                in    varchar2   default null
  ,p_information21                in    varchar2   default null
  ,p_information22                in    varchar2   default null
  ,p_information23                in    varchar2   default null
  ,p_information24                in    varchar2   default null
  ,p_information25                in    varchar2   default null
  ,p_information26                in    varchar2   default null
  ,p_information27                in    varchar2   default null
  ,p_information28                in    varchar2   default null
  ,p_information29                in    varchar2   default null
  ,p_information30                in    varchar2   default null
  ,p_information_category         in    varchar2   default null
  ,p_attribute1                   in    varchar2   default null
  ,p_attribute2                   in    varchar2   default null
  ,p_attribute3                   in    varchar2   default null
  ,p_attribute4                   in    varchar2   default null
  ,p_attribute5                   in    varchar2   default null
  ,p_attribute6                   in    varchar2   default null
  ,p_attribute7                   in    varchar2   default null
  ,p_attribute8                   in    varchar2   default null
  ,p_attribute9                   in    varchar2   default null
  ,p_attribute10                  in    varchar2   default null
  ,p_attribute11                  in    varchar2   default null
  ,p_attribute12                  in    varchar2   default null
  ,p_attribute13                  in    varchar2   default null
  ,p_attribute14                  in    varchar2   default null
  ,p_attribute15                  in    varchar2   default null
  ,p_attribute16                  in    varchar2   default null
  ,p_attribute17                  in    varchar2   default null
  ,p_attribute18                  in    varchar2   default null
  ,p_attribute19                  in    varchar2   default null
  ,p_attribute20                  in    varchar2   default null
  ,p_attribute21                  in    varchar2   default null
  ,p_attribute22                  in    varchar2   default null
  ,p_attribute23                  in    varchar2   default null
  ,p_attribute24                  in    varchar2   default null
  ,p_attribute25                  in    varchar2   default null
  ,p_attribute26                  in    varchar2   default null
  ,p_attribute27                  in    varchar2   default null
  ,p_attribute28                  in    varchar2   default null
  ,p_attribute29                  in    varchar2   default null
  ,p_attribute30                  in    varchar2   default null
  ,p_attribute_category           in    varchar2   default null
  ,p_object_version_number        out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_corps_extra_info_id pqh_corps_extra_info.corps_extra_info_id%TYPE;
  l_proc varchar2(72) := g_package||'create_corps_extra_info';
  l_object_version_number pqh_corps_extra_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_corps_extra_info;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_corps_extra_info
  pqh_corps_extra_info_bk1.create_corps_extra_info_b
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_definition_id          =>    p_corps_definition_id
  ,p_information_type             =>    p_information_type
  ,p_information1                 =>    p_information1
  ,p_information2                 =>    p_information2
  ,p_information3                 =>    p_information3
  ,p_information4                 =>    p_information4
  ,p_information5                 =>    p_information5
  ,p_information6                 =>    p_information6
  ,p_information7                 =>    p_information7
  ,p_information8                 =>    p_information8
  ,p_information9                 =>    p_information9
  ,p_information10                =>    p_information10
  ,p_information11                =>    p_information11
  ,p_information12                =>    p_information12
  ,p_information13                =>    p_information13
  ,p_information14                =>    p_information14
  ,p_information15                =>    p_information15
  ,p_information16                =>    p_information16
  ,p_information17                =>    p_information17
  ,p_information18                =>    p_information18
  ,p_information19                =>    p_information19
  ,p_information20                =>    p_information20
  ,p_information21                =>    p_information21
  ,p_information22                =>    p_information22
  ,p_information23                =>    p_information23
  ,p_information24                =>    p_information24
  ,p_information25                =>    p_information25
  ,p_information26                =>    p_information26
  ,p_information27                =>    p_information27
  ,p_information28                =>    p_information28
  ,p_information29                =>    p_information29
  ,p_information30                =>    p_information30
  ,p_information_category         =>    p_information_category
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_corps_extra_info'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_corps_extra_info
    --
  end;
  --
  -- Validation in addition to Row Handlers
  --
  IF p_information_type = 'ORGANIZATION' THEN
    validate_corps_org_info(p_effective_date  => p_effective_date
                           ,p_corps_definition_id => p_corps_definition_id
                           ,p_organization_id => p_information3);
  ELSIF p_information_type = 'FILERE' THEN
    validate_corps_prof_field_info(p_effective_date            => p_effective_date
                                  ,p_corps_definition_id       => p_corps_definition_id
                                  ,p_field_of_prof_activity_id => p_information3);
  ELSIF p_information_type = 'EXAM' THEN
    validate_corps_exam_info(p_effective_date      => p_effective_date
                            ,p_corps_definition_id => p_corps_definition_id
                            ,p_examination_type_cd => p_information3
                            ,p_institution_id      => p_information4
                            ,p_joining_way_cd      => p_information5
                            ,p_mandatory_flag      => p_information6
                            ,p_exam_name           => p_information7);
  ELSIF p_information_type = 'TRAINING' THEN
    validate_corps_training_info(p_effective_date      => p_effective_date
                                ,p_corps_definition_id => p_corps_definition_id
                                ,p_qualification_id    => p_information3
                                ,p_institution_id      => p_information4
                                ,p_training_duration   => p_information5
                                ,p_training_duration_uom => p_information6
                                ,p_joining_way_cd      => p_information7
                                ,p_mandatory_flag      => p_information8);
  END IF;
  hr_multi_message.end_validation_set;
  --
  --
  pqh_cei_ins.ins
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_extra_info_id          =>    l_corps_extra_info_id
  ,p_object_version_number        =>    l_object_version_number
  ,p_corps_definition_id          =>    p_corps_definition_id
  ,p_information_type             =>    p_information_type
  ,p_information1                 =>    p_information1
  ,p_information2                 =>    p_information2
  ,p_information3                 =>    p_information3
  ,p_information4                 =>    p_information4
  ,p_information5                 =>    p_information5
  ,p_information6                 =>    p_information6
  ,p_information7                 =>    p_information7
  ,p_information8                 =>    p_information8
  ,p_information9                 =>    p_information9
  ,p_information10                =>    p_information10
  ,p_information11                =>    p_information11
  ,p_information12                =>    p_information12
  ,p_information13                =>    p_information13
  ,p_information14                =>    p_information14
  ,p_information15                =>    p_information15
  ,p_information16                =>    p_information16
  ,p_information17                =>    p_information17
  ,p_information18                =>    p_information18
  ,p_information19                =>    p_information19
  ,p_information20                =>    p_information20
  ,p_information21                =>    p_information21
  ,p_information22                =>    p_information22
  ,p_information23                =>    p_information23
  ,p_information24                =>    p_information24
  ,p_information25                =>    p_information25
  ,p_information26                =>    p_information26
  ,p_information27                =>    p_information27
  ,p_information28                =>    p_information28
  ,p_information29                =>    p_information29
  ,p_information30                =>    p_information30
  ,p_information_category         =>    p_information_category
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
);

  begin
    --
    -- Start of API User Hook for the afetr hook of create_corps_extra_info
  pqh_corps_extra_info_bk1.create_corps_extra_info_a
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_definition_id          =>    p_corps_definition_id
  ,p_information_type             =>    p_information_type
  ,p_information1                 =>    p_information1
  ,p_information2                 =>    p_information2
  ,p_information3                 =>    p_information3
  ,p_information4                 =>    p_information4
  ,p_information5                 =>    p_information5
  ,p_information6                 =>    p_information6
  ,p_information7                 =>    p_information7
  ,p_information8                 =>    p_information8
  ,p_information9                 =>    p_information9
  ,p_information10                =>    p_information10
  ,p_information11                =>    p_information11
  ,p_information12                =>    p_information12
  ,p_information13                =>    p_information13
  ,p_information14                =>    p_information14
  ,p_information15                =>    p_information15
  ,p_information16                =>    p_information16
  ,p_information17                =>    p_information17
  ,p_information18                =>    p_information18
  ,p_information19                =>    p_information19
  ,p_information20                =>    p_information20
  ,p_information21                =>    p_information21
  ,p_information22                =>    p_information22
  ,p_information23                =>    p_information23
  ,p_information24                =>    p_information24
  ,p_information25                =>    p_information25
  ,p_information26                =>    p_information26
  ,p_information27                =>    p_information27
  ,p_information28                =>    p_information28
  ,p_information29                =>    p_information29
  ,p_information30                =>    p_information30
  ,p_information_category         =>    p_information_category
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_corps_extra_info'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_corps_extra_info
    --
  end;

  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_corps_extra_info_id := l_corps_extra_info_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_corps_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_corps_extra_info_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_corps_extra_info_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_corps_extra_info;
    raise;
    --
end create_corps_extra_info;

-- ----------------------------------------------------------------------------
-- |------------------------< update_corps_extra_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--
-- Name                           Reqd     Type     Description
-- p_validate                      YES     boolean  Commit or Rollback
-- p_corps_extra_info_id           YES     number   PK of record
-- p_effective_date                YES     date
-- p_corps_definition_id           NO      number
-- p_information_type              NO      varchar2
-- p_information1                  NO      varchar2
-- p_information2                  NO      varchar2
-- p_information3                  NO      varchar2
-- p_information4                  NO      varchar2
-- p_information5                  NO      varchar2
-- p_information6                  NO      varchar2
-- p_information7                  NO      varchar2
-- p_information8                  NO      varchar2
-- p_information9                  NO      varchar2
-- p_information10                 NO      varchar2
-- p_information11                 NO      varchar2
-- p_information12                 NO      varchar2
-- p_information13                 NO      varchar2
-- p_information14                 NO      varchar2
-- p_information15                 NO      varchar2
-- p_information16                 NO      varchar2
-- p_information17                 NO      varchar2
-- p_information18                 NO      varchar2
-- p_information19                 NO      varchar2
-- p_information20                 NO      varchar2
-- p_information21                 NO      varchar2
-- p_information22                 NO      varchar2
-- p_information23                 NO      varchar2
-- p_information24                 NO      varchar2
-- p_information25                 NO      varchar2
-- p_information26                 NO      varchar2
-- p_information27                 NO      varchar2
-- p_information28                 NO      varchar2
-- p_information29                 NO      varchar2
-- p_information30                 NO      varchar2
-- p_information_category          NO      varchar2
-- p_attribute1                    NO      varchar2
-- p_attribute2                    NO      varchar2
-- p_attribute3                    NO      varchar2
-- p_attribute4                    NO      varchar2
-- p_attribute5                    NO      varchar2
-- p_attribute6                    NO      varchar2
-- p_attribute7                    NO      varchar2
-- p_attribute8                    NO      varchar2
-- p_attribute9                    NO      varchar2
-- p_attribute10                   NO      varchar2
-- p_attribute11                   NO      varchar2
-- p_attribute12                   NO      varchar2
-- p_attribute13                   NO      varchar2
-- p_attribute14                   NO      varchar2
-- p_attribute15                   NO      varchar2
-- p_attribute16                   NO      varchar2
-- p_attribute17                   NO      varchar2
-- p_attribute18                   NO      varchar2
-- p_attribute19                   NO      varchar2
-- p_attribute20                   NO      varchar2
-- p_attribute21                   NO      varchar2
-- p_attribute22                   NO      varchar2
-- p_attribute23                   NO      varchar2
-- p_attribute24                   NO      varchar2
-- p_attribute25                   NO      varchar2
-- p_attribute26                   NO      varchar2
-- p_attribute27                   NO      varchar2
-- p_attribute28                   NO      varchar2
-- p_attribute29                   NO      varchar2
-- p_attribute30                   NO      varchar2
-- p_attribute_category            NO      varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_corps_extra_info
  (
  p_validate                      in    boolean    default false
  ,p_effective_date               in    date
  ,p_corps_extra_info_id          in    number
  ,p_corps_definition_id          in    number     default hr_api.g_number
  ,p_information_type             in    varchar2   default hr_api.g_varchar2
  ,p_information1                 in    varchar2   default hr_api.g_varchar2
  ,p_information2                 in    varchar2   default hr_api.g_varchar2
  ,p_information3                 in    varchar2   default hr_api.g_varchar2
  ,p_information4                 in    varchar2   default hr_api.g_varchar2
  ,p_information5                 in    varchar2   default hr_api.g_varchar2
  ,p_information6                 in    varchar2   default hr_api.g_varchar2
  ,p_information7                 in    varchar2   default hr_api.g_varchar2
  ,p_information8                 in    varchar2   default hr_api.g_varchar2
  ,p_information9                 in    varchar2   default hr_api.g_varchar2
  ,p_information10                in    varchar2   default hr_api.g_varchar2
  ,p_information11                in    varchar2   default hr_api.g_varchar2
  ,p_information12                in    varchar2   default hr_api.g_varchar2
  ,p_information13                in    varchar2   default hr_api.g_varchar2
  ,p_information14                in    varchar2   default hr_api.g_varchar2
  ,p_information15                in    varchar2   default hr_api.g_varchar2
  ,p_information16                in    varchar2   default hr_api.g_varchar2
  ,p_information17                in    varchar2   default hr_api.g_varchar2
  ,p_information18                in    varchar2   default hr_api.g_varchar2
  ,p_information19                in    varchar2   default hr_api.g_varchar2
  ,p_information20                in    varchar2   default hr_api.g_varchar2
  ,p_information21                in    varchar2   default hr_api.g_varchar2
  ,p_information22                in    varchar2   default hr_api.g_varchar2
  ,p_information23                in    varchar2   default hr_api.g_varchar2
  ,p_information24                in    varchar2   default hr_api.g_varchar2
  ,p_information25                in    varchar2   default hr_api.g_varchar2
  ,p_information26                in    varchar2   default hr_api.g_varchar2
  ,p_information27                in    varchar2   default hr_api.g_varchar2
  ,p_information28                in    varchar2   default hr_api.g_varchar2
  ,p_information29                in    varchar2   default hr_api.g_varchar2
  ,p_information30                in    varchar2   default hr_api.g_varchar2
  ,p_information_category         in    varchar2   default hr_api.g_varchar2
  ,p_attribute1                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute2                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute3                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute4                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute5                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute6                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute7                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute8                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute9                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute10                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute11                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute12                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute13                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute14                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute15                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute16                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute17                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute18                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute19                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute20                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute21                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute22                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute23                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute24                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute25                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute26                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute27                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute28                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute29                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute30                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute_category           in    varchar2   default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_corps_extra_info';
  l_object_version_number pqh_corps_extra_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_corps_extra_info;
  --
  hr_utility.set_location(l_proc, 20);
  l_object_version_number := p_object_version_number;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_corps_extra_info
  pqh_corps_extra_info_bk2.update_corps_extra_info_b
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_extra_info_id          =>    p_corps_extra_info_id
  ,p_corps_definition_id          =>    p_corps_definition_id
  ,p_object_version_number        =>    p_object_version_number
  ,p_information_type             =>    p_information_type
  ,p_information1                 =>    p_information1
  ,p_information2                 =>    p_information2
  ,p_information3                 =>    p_information3
  ,p_information4                 =>    p_information4
  ,p_information5                 =>    p_information5
  ,p_information6                 =>    p_information6
  ,p_information7                 =>    p_information7
  ,p_information8                 =>    p_information8
  ,p_information9                 =>    p_information9
  ,p_information10                =>    p_information10
  ,p_information11                =>    p_information11
  ,p_information12                =>    p_information12
  ,p_information13                =>    p_information13
  ,p_information14                =>    p_information14
  ,p_information15                =>    p_information15
  ,p_information16                =>    p_information16
  ,p_information17                =>    p_information17
  ,p_information18                =>    p_information18
  ,p_information19                =>    p_information19
  ,p_information20                =>    p_information20
  ,p_information21                =>    p_information21
  ,p_information22                =>    p_information22
  ,p_information23                =>    p_information23
  ,p_information24                =>    p_information24
  ,p_information25                =>    p_information25
  ,p_information26                =>    p_information26
  ,p_information27                =>    p_information27
  ,p_information28                =>    p_information28
  ,p_information29                =>    p_information29
  ,p_information30                =>    p_information30
  ,p_information_category         =>    p_information_category
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'update_corps_extra_info'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_corps_extra_info
    --
  end;
  --
  -- Validation in addition to Row Handlers
  --
  IF p_information_type = 'ORGANIZATION' THEN
    validate_corps_org_info(p_effective_date  => p_effective_date
                           ,p_corps_definition_id => p_corps_definition_id
                           ,p_organization_id => p_information3
                           ,p_corps_extra_info_id => p_corps_extra_info_id);
  ELSIF p_information_type = 'FILERE' THEN
    validate_corps_prof_field_info(p_effective_date            => p_effective_date
                                  ,p_corps_definition_id       => p_corps_definition_id
                                  ,p_field_of_prof_activity_id => p_information3
                                  ,p_corps_extra_info_id => p_corps_extra_info_id);
  ELSIF p_information_type = 'EXAM' THEN
    validate_corps_exam_info(p_effective_date      => p_effective_date
                            ,p_corps_definition_id => p_corps_definition_id
                            ,p_examination_type_cd => p_information3
                            ,p_institution_id      => p_information4
                            ,p_joining_way_cd      => p_information5
                            ,p_mandatory_flag      => p_information6
                            ,p_exam_name           => p_information7
                            ,p_corps_extra_info_id => p_corps_extra_info_id);
  ELSIF p_information_type = 'TRAINING' THEN
    validate_corps_training_info(p_effective_date      => p_effective_date
                                ,p_corps_definition_id => p_corps_definition_id
                                ,p_qualification_id    => p_information3
                                ,p_institution_id      => p_information4
                                ,p_training_duration   => p_information5
                                ,p_training_duration_uom => p_information6
                                ,p_joining_way_cd      => p_information7
                                ,p_mandatory_flag      => p_information8
                                ,p_corps_extra_info_id => p_corps_extra_info_id);
  END IF;
  hr_multi_message.end_validation_set;
  --
  --
  pqh_cei_upd.upd
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_extra_info_id          =>    p_corps_extra_info_id
  ,p_object_version_number        =>    l_object_version_number
  ,p_corps_definition_id          =>    p_corps_definition_id
  ,p_information_type             =>    p_information_type
  ,p_information1                 =>    p_information1
  ,p_information2                 =>    p_information2
  ,p_information3                 =>    p_information3
  ,p_information4                 =>    p_information4
  ,p_information5                 =>    p_information5
  ,p_information6                 =>    p_information6
  ,p_information7                 =>    p_information7
  ,p_information8                 =>    p_information8
  ,p_information9                 =>    p_information9
  ,p_information10                =>    p_information10
  ,p_information11                =>    p_information11
  ,p_information12                =>    p_information12
  ,p_information13                =>    p_information13
  ,p_information14                =>    p_information14
  ,p_information15                =>    p_information15
  ,p_information16                =>    p_information16
  ,p_information17                =>    p_information17
  ,p_information18                =>    p_information18
  ,p_information19                =>    p_information19
  ,p_information20                =>    p_information20
  ,p_information21                =>    p_information21
  ,p_information22                =>    p_information22
  ,p_information23                =>    p_information23
  ,p_information24                =>    p_information24
  ,p_information25                =>    p_information25
  ,p_information26                =>    p_information26
  ,p_information27                =>    p_information27
  ,p_information28                =>    p_information28
  ,p_information29                =>    p_information29
  ,p_information30                =>    p_information30
  ,p_information_category         =>    p_information_category
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
);

  begin
    --
    -- Start of API User Hook for the afetr hook of update_corps_extra_info
  pqh_corps_extra_info_bk2.update_corps_extra_info_a
 (
  p_effective_date                =>    trunc(p_effective_date)
  ,p_corps_extra_info_id          =>    p_corps_extra_info_id
  ,p_corps_definition_id          =>    p_corps_definition_id
  ,p_object_version_number        =>    l_object_version_number
  ,p_information_type             =>    p_information_type
  ,p_information1                 =>    p_information1
  ,p_information2                 =>    p_information2
  ,p_information3                 =>    p_information3
  ,p_information4                 =>    p_information4
  ,p_information5                 =>    p_information5
  ,p_information6                 =>    p_information6
  ,p_information7                 =>    p_information7
  ,p_information8                 =>    p_information8
  ,p_information9                 =>    p_information9
  ,p_information10                =>    p_information10
  ,p_information11                =>    p_information11
  ,p_information12                =>    p_information12
  ,p_information13                =>    p_information13
  ,p_information14                =>    p_information14
  ,p_information15                =>    p_information15
  ,p_information16                =>    p_information16
  ,p_information17                =>    p_information17
  ,p_information18                =>    p_information18
  ,p_information19                =>    p_information19
  ,p_information20                =>    p_information20
  ,p_information21                =>    p_information21
  ,p_information22                =>    p_information22
  ,p_information23                =>    p_information23
  ,p_information24                =>    p_information24
  ,p_information25                =>    p_information25
  ,p_information26                =>    p_information26
  ,p_information27                =>    p_information27
  ,p_information28                =>    p_information28
  ,p_information29                =>    p_information29
  ,p_information30                =>    p_information30
  ,p_information_category         =>    p_information_category
  ,p_attribute1                   =>    p_attribute1
  ,p_attribute2                   =>    p_attribute2
  ,p_attribute3                   =>    p_attribute3
  ,p_attribute4                   =>    p_attribute4
  ,p_attribute5                   =>    p_attribute5
  ,p_attribute6                   =>    p_attribute6
  ,p_attribute7                   =>    p_attribute7
  ,p_attribute8                   =>    p_attribute8
  ,p_attribute9                   =>    p_attribute9
  ,p_attribute10                  =>    p_attribute10
  ,p_attribute11                  =>    p_attribute11
  ,p_attribute12                  =>    p_attribute12
  ,p_attribute13                  =>    p_attribute13
  ,p_attribute14                  =>    p_attribute14
  ,p_attribute15                  =>    p_attribute15
  ,p_attribute16                  =>    p_attribute16
  ,p_attribute17                  =>    p_attribute17
  ,p_attribute18                  =>    p_attribute18
  ,p_attribute19                  =>    p_attribute19
  ,p_attribute20                  =>    p_attribute20
  ,p_attribute21                  =>    p_attribute21
  ,p_attribute22                  =>    p_attribute22
  ,p_attribute23                  =>    p_attribute23
  ,p_attribute24                  =>    p_attribute24
  ,p_attribute25                  =>    p_attribute25
  ,p_attribute26                  =>    p_attribute26
  ,p_attribute27                  =>    p_attribute27
  ,p_attribute28                  =>    p_attribute28
  ,p_attribute29                  =>    p_attribute29
  ,p_attribute30                  =>    p_attribute30
  ,p_attribute_category           =>    p_attribute_category
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'update_corps_extra_info'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_corps_extra_info
    --
  end;

  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_corps_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_corps_extra_info;
    raise;
    --
end;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_corps_extra_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_corps_extra_info_id          Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_object_version_number        Yes  number    OVN of record

-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_corps_extra_info
  (
  p_validate                        in boolean        default false
  ,p_corps_extra_info_id            in  number
  ,p_object_version_number          in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_corps_extra_info';
  l_object_version_number pqh_corps_extra_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_corps_extra_info;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_corps_extra_info
    --
    pqh_corps_extra_info_bk3.delete_corps_extra_info_b
      (
       p_corps_extra_info_id            =>  p_corps_extra_info_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_corps_extra_info'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_corps_extra_info
    --
  end;
  --
  --
  -- Validation in addition to Row Handlers
  --
  chk_prim_field_for_corps(p_corps_extra_info_id => p_corps_extra_info_id);
  hr_multi_message.end_validation_set;
  --
  PQH_CEI_del.del
    (
     p_corps_extra_info_id           => p_corps_extra_info_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_corps_extra_info
    --
    pqh_corps_extra_info_bk3.delete_corps_extra_info_a
      (
       p_corps_extra_info_id            =>  p_corps_extra_info_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_corps_extra_info'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_corps_extra_info
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_corps_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_corps_extra_info;
    raise;
    --
end delete_corps_extra_info;

--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_corps_extra_info_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  PQH_CEI_shd.lck
    (
      p_corps_extra_info_id        => p_corps_extra_info_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_corps_extra_info_api;

/
