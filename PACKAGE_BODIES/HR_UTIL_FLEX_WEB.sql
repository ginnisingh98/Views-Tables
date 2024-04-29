--------------------------------------------------------
--  DDL for Package Body HR_UTIL_FLEX_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UTIL_FLEX_WEB" as
/* $Header: hrutlflw.pkb 115.0 99/07/17 18:18:07 porting ship $ */
--
-- ---------------------------------------------------------------------------
-- ------------------- <get_keyflex_mapped_column_name> ----------------------
-- ---------------------------------------------------------------------------
-- Usage: This procedure allows a user to enter two most important keyflex
--        segments for use in display for each keyflex code as profile options.
--
-- Input: p_business_group_id  - logged in user's business group id.
--        p_keyflex_code       - FND flex code for the 5 key flexfields in HRMS
--                             - Flex Code                    App Short Name
--                             - --------------------------   --------------
--                             - 'GRD'=Grade Key Flex         PER
--                             - 'GRP'=People Group Key Flex  PAY
--                             - 'JOB'=Job Key Flexfield      PER
--                             - 'POS'=POS Key Flex           PER
--                             - 'COST'=Costing Key Flex      PAY
Procedure get_keyflex_mapped_column_name
         (p_business_group_id      in number
         ,p_keyflex_code           in varchar2
         ,p_mapped_col_name1       out varchar2
         ,p_mapped_col_name2       out varchar2
         ,p_keyflex_id_flex_num    out number
         ,p_segment_separator      out varchar2
         ,p_warning                out varchar2) is

l_id_flex_num  number(15) := 0;

-- For 11.0 patch, only up to 2 segments can be specified by the user in the
-- profile option.
l_segment_name1 varchar2(30) default null;
l_segment_name2 varchar2(30) default null;
l_segment_name_valid   varchar2(1) default null;
l_tbl_col_name_used    varchar2(1) default null;
--
l_mapped_col_name1   varchar2(30) default null;
l_mapped_col_name2   varchar2(30) default null;
--
l_flexfield_rec    fnd_flex_key_api.flexfield_type;
l_structure_rec    fnd_flex_key_api.structure_type;
l_segment_rec1     fnd_flex_key_api.segment_type;
l_segment_rec2     fnd_flex_key_api.segment_type;
l_length           number;
l_index            binary_integer default 0;

--
l_per_short_name          varchar2(3) default 'PER';
l_pay_short_name          varchar2(3) default 'PAY';
l_grade_flex_code         varchar2(3) default 'GRD';
l_group_flex_code         varchar2(3) default 'GRP';
l_job_flex_code           varchar2(3) default 'JOB';
l_pos_flex_code           varchar2(3) default 'POS';
l_cost_flex_code          varchar2(4) default 'COST';


--
-- Grade Keyflex Id is stored in org_information4 in hr_organization_information
cursor csr_get_grade_flex_id is
       select org_information4
         from hr_organization_information
        where organization_id = p_business_group_id
          and org_information_context = 'Business Group Information';
--
-- People Group Keyflex Id is stored in org_information5 in
-- hr_organization_information.
cursor csr_get_people_group_flex_id is
       select org_information5
         from hr_organization_information
        where organization_id = p_business_group_id
          and org_information_context = 'Business Group Information';
--
-- Job Keyflex Id is stored in org_information6 in hr_organization_information
cursor csr_get_job_flex_id is
       select org_information6
         from hr_organization_information
        where organization_id = p_business_group_id
          and org_information_context = 'Business Group Information';
--
-- Costing Keyflex Id is stored in org_information7 in
-- hr_organization_information.
cursor csr_get_costing_flex_id is
       select org_information7
         from hr_organization_information
        where organization_id = p_business_group_id
          and org_information_context = 'Business Group Information';
--
-- Position Keyflex Id is stored in org_information8 in
-- hr_organization_information.
cursor csr_get_position_flex_id is
       select org_information8
         from hr_organization_information
        where organization_id = p_business_group_id
          and org_information_context = 'Business Group Information';
--
Begin

   l_structure_rec.segment_separator := ' ';
--
-- --------------------------------------------------------------------------
-- For each key flexfield type, do:
-- 1) Get the id flex num for the business group.
-- 2) Get segment name for the flexfield from the profile option.
--    We allow users to enter either "user segment name, such as: Job Code, Job
--    Title" or physical segment column name, such as SEGMENT1 ... SEGMENT30.
-- 3) Once segment name is returned, check whether the segment name starts with
--    'SEGMENT%'.  If it does, then we will validate the physical segment name
--    by comparing with the application_column_name in fnd_id_flex_segments
--    table for the structure and flex_code.  If the segment names are equal,
--    then the segment name entered is valid for the structure, stop here.
--    Otherwise, raise an error.
--
--    If the segment name does not begin with 'SEGMENT%', then the system will
--    assume that user segment name is used.  The system will progress to the
--    the next step to obtain the physical segment column name.
-- 4) Get the mapped table column name for the user segment name.
-- --------------------------------------------------------------------------
--
p_warning := null;

IF upper(p_keyflex_code) = l_grade_flex_code THEN
   open csr_get_grade_flex_id;
   fetch csr_get_grade_flex_id into l_id_flex_num;
   IF csr_get_grade_flex_id%NOTFOUND THEN
      close csr_get_grade_flex_id;
      raise g_flexfield_not_found;
   ELSE
      close csr_get_grade_flex_id;
      l_segment_name1 := fnd_profile.value('HR_GRADE_KEYFLEX_SEGMENT1');
      l_segment_name2 := fnd_profile.value('HR_GRADE_KEYFLEX_SEGMENT2');
      --
      --
      validate_seg_col_name(p_segment_name1        => l_segment_name1
                           ,p_segment_name2        => l_segment_name2
                           ,p_app_short_name       => l_per_short_name
                           ,p_flex_code            => l_grade_flex_code
                           ,p_id_flex_num          => l_id_flex_num
                           ,p_segment_name_valid   => l_segment_name_valid
                           ,p_tbl_col_name_used    => l_tbl_col_name_used
                           ,p_flexfield_rec        => l_flexfield_rec
                           ,p_structure_rec        => l_structure_rec);

      IF l_segment_name_valid = 'Y' and l_tbl_col_name_used = 'Y' THEN
         l_mapped_col_name1 := upper(l_segment_name1);
         l_mapped_col_name2 := upper(l_segment_name2);
      ELSE -- user segment names were entered
         IF l_segment_name_valid = 'Y' THEN
            get_keyflex_info (p_app_short_name    => l_per_short_name
                          ,p_flex_code            => l_grade_flex_code
                          ,p_id_flex_num          => l_id_flex_num
                          ,p_segment_name1        =>l_segment_name1
                          ,p_segment_name2        =>l_segment_name2
                          ,p_mapped_tbl_col_name1 => l_mapped_col_name1
                          ,p_mapped_tbl_col_name2 => l_mapped_col_name2
                          ,p_flexfield_rec        => l_flexfield_rec
                          ,p_structure_rec        => l_structure_rec);
         END IF;
      END IF;
   END IF;
--
ELSIF upper(p_keyflex_code) = l_job_flex_code THEN
   open csr_get_job_flex_id;
   fetch csr_get_job_flex_id into l_id_flex_num;
   IF csr_get_job_flex_id%NOTFOUND THEN
      close csr_get_job_flex_id;
      raise g_flexfield_not_found;
   ELSE
      close csr_get_job_flex_id;
      l_segment_name1 := fnd_profile.value('HR_JOB_KEYFLEX_SEGMENT1');
      l_segment_name2 := fnd_profile.value('HR_JOB_KEYFLEX_SEGMENT2');
      --
      --
      validate_seg_col_name(p_segment_name1        => l_segment_name1
                           ,p_segment_name2        => l_segment_name2
                           ,p_app_short_name       => l_per_short_name
                           ,p_flex_code            => l_job_flex_code
                           ,p_id_flex_num          => l_id_flex_num
                           ,p_segment_name_valid   => l_segment_name_valid
                           ,p_tbl_col_name_used    => l_tbl_col_name_used
                           ,p_flexfield_rec        => l_flexfield_rec
                           ,p_structure_rec        => l_structure_rec);

      IF l_segment_name_valid = 'Y' and l_tbl_col_name_used = 'Y' THEN
         l_mapped_col_name1 := upper(l_segment_name1);
         l_mapped_col_name2 := upper(l_segment_name2);
      ELSE -- user segment names were entered
         IF l_segment_name_valid = 'Y' THEN
            get_keyflex_info (p_app_short_name    => l_per_short_name
                          ,p_flex_code            => l_job_flex_code
                          ,p_id_flex_num          => l_id_flex_num
                          ,p_segment_name1        => l_segment_name1
                          ,p_segment_name2        => l_segment_name2
                          ,p_mapped_tbl_col_name1 => l_mapped_col_name1
                          ,p_mapped_tbl_col_name2 => l_mapped_col_name2
                          ,p_flexfield_rec        => l_flexfield_rec
                          ,p_structure_rec        => l_structure_rec);
         END IF;
      END IF;
   END IF;
--
ELSIF upper(p_keyflex_code) = l_pos_flex_code THEN
   open csr_get_position_flex_id;
   fetch csr_get_position_flex_id into l_id_flex_num;
   IF csr_get_position_flex_id%NOTFOUND THEN
      close csr_get_position_flex_id;
      raise g_flexfield_not_found;
   ELSE
     close csr_get_position_flex_id;
     l_segment_name1 := fnd_profile.value('HR_POS_KEYFLEX_SEGMENT1');
     l_segment_name2 := fnd_profile.value('HR_POS_KEYFLEX_SEGMENT2');
      --
      --
      validate_seg_col_name(p_segment_name1        => l_segment_name1
                           ,p_segment_name2        => l_segment_name2
                           ,p_app_short_name       => l_per_short_name
                           ,p_flex_code            => l_pos_flex_code
                           ,p_id_flex_num          => l_id_flex_num
                           ,p_segment_name_valid   => l_segment_name_valid
                           ,p_tbl_col_name_used    => l_tbl_col_name_used
                           ,p_flexfield_rec        => l_flexfield_rec
                           ,p_structure_rec        => l_structure_rec);

      IF l_segment_name_valid = 'Y' and l_tbl_col_name_used = 'Y' THEN
         l_mapped_col_name1 := upper(l_segment_name1);
         l_mapped_col_name2 := upper(l_segment_name2);
      ELSE -- user segment names were entered
         IF l_segment_name_valid = 'Y' THEN
            get_keyflex_info (p_app_short_name    => l_per_short_name
                          ,p_flex_code            => l_pos_flex_code
                          ,p_id_flex_num          => l_id_flex_num
                          ,p_segment_name1        => l_segment_name1
                          ,p_segment_name2        => l_segment_name2
                          ,p_mapped_tbl_col_name1 => l_mapped_col_name1
                          ,p_mapped_tbl_col_name2 => l_mapped_col_name2
                          ,p_flexfield_rec        => l_flexfield_rec
                          ,p_structure_rec        => l_structure_rec);
         END IF;
      END IF;
   END IF;
--
ELSIF upper(p_keyflex_code) = l_group_flex_code THEN
   open csr_get_people_group_flex_id;
   fetch csr_get_people_group_flex_id into l_id_flex_num;
   IF csr_get_people_group_flex_id%NOTFOUND THEN
      close csr_get_people_group_flex_id;
      raise g_flexfield_not_found;
   ELSE
     close csr_get_people_group_flex_id;
     l_segment_name1 := fnd_profile.value('HR_PEOPLE_GRP_KEYFLEX_SEGMENT1');
     l_segment_name2 := fnd_profile.value('HR_PEOPLE_GRP_KEYFLEX_SEGMENT2');
      --
      validate_seg_col_name(p_segment_name1        => l_segment_name1
                           ,p_segment_name2        => l_segment_name2
                           ,p_app_short_name       => l_pay_short_name
                           ,p_flex_code            => l_group_flex_code
                           ,p_id_flex_num          => l_id_flex_num
                           ,p_segment_name_valid   => l_segment_name_valid
                           ,p_tbl_col_name_used    => l_tbl_col_name_used
                           ,p_flexfield_rec        => l_flexfield_rec
                           ,p_structure_rec        => l_structure_rec);

      IF l_segment_name_valid = 'Y' and l_tbl_col_name_used = 'Y' THEN
         l_mapped_col_name1 := upper(l_segment_name1);
         l_mapped_col_name2 := upper(l_segment_name2);
      ELSE -- user segment names were entered
         IF l_segment_name_valid = 'Y' THEN
            get_keyflex_info (p_app_short_name    => l_per_short_name
                          ,p_flex_code            => l_group_flex_code
                          ,p_id_flex_num          => l_id_flex_num
                          ,p_segment_name1        => l_segment_name1
                          ,p_segment_name2        => l_segment_name2
                          ,p_mapped_tbl_col_name1 => l_mapped_col_name1
                          ,p_mapped_tbl_col_name2 => l_mapped_col_name2
                          ,p_flexfield_rec        => l_flexfield_rec
                          ,p_structure_rec        => l_structure_rec);
         END IF;
      END IF;
   END IF;
--
ELSIF upper(p_keyflex_code) = l_cost_flex_code THEN
   open csr_get_costing_flex_id;
   fetch csr_get_costing_flex_id into l_id_flex_num;
   IF csr_get_costing_flex_id%NOTFOUND THEN
      close csr_get_costing_flex_id;
      raise g_flexfield_not_found;
   ELSE
      close csr_get_costing_flex_id;
      l_segment_name1 := fnd_profile.value('HR_COSTING_KEYFLEX_SEGMENT1');
      l_segment_name2 := fnd_profile.value('HR_COSTING_KEYFLEX_SEGMENT2');
      --
      validate_seg_col_name(p_segment_name1        => l_segment_name1
                           ,p_segment_name2        => l_segment_name2
                           ,p_app_short_name       => l_pay_short_name
                           ,p_flex_code            => l_cost_flex_code
                           ,p_id_flex_num          => l_id_flex_num
                           ,p_segment_name_valid   => l_segment_name_valid
                           ,p_tbl_col_name_used    => l_tbl_col_name_used
                           ,p_flexfield_rec        => l_flexfield_rec
                           ,p_structure_rec        => l_structure_rec);

      IF l_segment_name_valid = 'Y' and l_tbl_col_name_used = 'Y' THEN
         l_mapped_col_name1 := upper(l_segment_name1);
         l_mapped_col_name2 := upper(l_segment_name2);
      ELSE -- user segment names were entered
         IF l_segment_name_valid = 'Y' THEN
            get_keyflex_info (p_app_short_name    => l_per_short_name
                          ,p_flex_code            => l_cost_flex_code
                          ,p_id_flex_num          => l_id_flex_num
                          ,p_segment_name1        => l_segment_name1
                          ,p_segment_name2        => l_segment_name2
                          ,p_mapped_tbl_col_name1 => l_mapped_col_name1
                          ,p_mapped_tbl_col_name2 => l_mapped_col_name2
                          ,p_flexfield_rec        => l_flexfield_rec
                          ,p_structure_rec        => l_structure_rec);
         END IF;
      END IF;
   END IF;
ELSE
   l_id_flex_num := null;
   l_mapped_col_name1 := null;
   l_mapped_col_name2 := null;
END IF;

--
p_mapped_col_name1 := l_mapped_col_name1;
p_mapped_col_name2 := l_mapped_col_name2;
p_keyflex_id_flex_num := l_id_flex_num;
p_segment_separator := l_structure_rec.segment_separator;
--
--
Exception
When g_flexfield_not_found or NO_DATA_FOUND THEN
     p_warning := 'HR_FLEXFIELD_NOT_FOUND';

When g_both_seg_name_invalid THEN
     p_warning := 'HR_SEG_NAME_INVALID';

When g_seg_name1_invalid THEN
     p_warning := 'HR_SEG_NAME_INVALID';

When g_seg_name2_invalid THEN
     p_warning := 'HR_SEG_NAME_INVALID';

End get_keyflex_mapped_column_name;


------------------------------------------------------------------------------
-- ------------------------< validate_seg_col_name > -------------------------
------------------------------------------------------------------------------
Procedure validate_seg_col_name(p_segment_name1  in varchar2 default null
                               ,p_segment_name2  in varchar2 default null
                               ,p_app_short_name in varchar2
                               ,p_flex_code      in varchar2
                               ,p_id_flex_num    in number
                               ,p_segment_name_valid  out varchar2
                               ,p_tbl_col_name_used   out varchar2
                               ,p_flexfield_rec       out
                                            fnd_flex_key_api.flexfield_type
                               ,p_structure_rec       out
                                            fnd_flex_key_api.structure_type) IS

l_flexfield_rec        fnd_flex_key_api.flexfield_type;
l_structure_rec        fnd_flex_key_api.structure_type;
l_segment_list         fnd_flex_key_api.segment_list;
l_index                binary_integer default 0;
l_num_of_segments      number default 0;
l_length               number default 0;
l_seg_name_tmp         varchar2(100) default null;
l_seg_col_name_ok      boolean default false;
l_seg_name1_valid      varchar2(1) default null;
l_seg_name2_valid      varchar2(1) default null;
l_app_col_name         varchar2(30);
l_app_id               number default null;

cursor csr_chk_flex_app_col_name is
select APPLICATION_COLUMN_NAME
from   fnd_id_flex_segments
where  APPLICATION_ID = l_app_id
and    ID_FLEX_CODE = p_flex_code
and    ID_FLEX_NUM = p_id_flex_num;
--
--
Begin
  l_app_id                   := null;
  l_app_col_name             := null;
  l_seg_col_name_ok          := false;
  p_segment_name_valid       := null;
  p_tbl_col_name_used            := null;
  --
  IF p_app_short_name = 'PER' THEN
     l_app_id := 800;
  ELSE
     l_app_id := 801;
  END IF;
  --
  l_length := length(p_segment_name1);
  IF l_length is not null and l_length >= 7 THEN
     l_seg_name_tmp := upper(p_segment_name1);
     IF instr(l_seg_name_tmp, 'SEGMENT', 1, 1) = 1 THEN
        l_seg_col_name_ok := true;
     END IF;
  END IF;
  --
  l_length := length(p_segment_name2);
  IF l_length is not null and l_length >= 7 THEN
     l_seg_name_tmp := upper(p_segment_name2);
     IF instr(l_seg_name_tmp, 'SEGMENT', 1, 1) = 1 THEN
        l_seg_col_name_ok := true;
     END IF;
  END IF;

  -- Validate the physical column name entered by the user
  IF l_seg_col_name_ok THEN
     p_tbl_col_name_used := 'Y';
     open csr_chk_flex_app_col_name;
     IF csr_chk_flex_app_col_name%NOTFOUND THEN
        close csr_chk_flex_app_col_name;
        raise g_flexfield_not_found;
     END IF;
     --
     l_seg_name1_valid := 'N';
     l_seg_name2_valid := 'N';
     --
     Loop
        fetch csr_chk_flex_app_col_name into l_app_col_name;
        exit when csr_chk_flex_app_col_name%NOTFOUND;
        IF p_segment_name1 is NOT NULL and l_seg_name1_valid = 'N' THEN
           IF l_app_col_name = upper(p_segment_name1) THEN
              l_seg_name1_valid := 'Y';
           END IF;
        END IF;
        --
        IF p_segment_name2 is NOT NULL and l_seg_name2_valid = 'N' THEN
           IF l_app_col_name = upper(p_segment_name2) THEN
              l_seg_name2_valid := 'Y';
           END IF;
        END IF;
        --
     END LOOP;
     --
     --
     close csr_chk_flex_app_col_name;
  --
  ELSE -- check user segment name entered by the user
     l_flexfield_rec := fnd_flex_key_api.find_flexfield
                        (p_app_short_name, p_flex_code);
  --
     l_structure_rec := fnd_flex_key_api.find_structure
                        (l_flexfield_rec, p_id_flex_num);
  --
     fnd_flex_key_api.get_segments(flexfield    => l_flexfield_rec
                                  ,structure    => l_structure_rec
                                  ,enabled_only => True
                                  ,nsegments    => l_num_of_segments
                                  ,segments     => l_segment_list);

     l_seg_name1_valid := 'N';
     l_seg_name2_valid := 'N';
  --
     IF l_num_of_segments > 0 THEN
        For l_index in 1..l_num_of_segments LOOP
            IF p_segment_name1 is NOT NULL and l_seg_name1_valid = 'N' THEN
               IF l_segment_list(l_index) = p_segment_name1 THEN
                  l_seg_name1_valid := 'Y';
               END IF;
            END IF;
     --
            IF p_segment_name2 is NOT NULL and l_seg_name2_valid = 'N' THEN
               IF l_segment_list(l_index) = p_segment_name2 THEN
                  l_seg_name2_valid := 'Y';
               END IF;
            END IF;
        END LOOP;
     END IF;
   END IF;
   --
   -- Now set the output parm p_segment_name_valid accordingly for either
   -- physical column name or user segment name.
   --
   IF (l_seg_name1_valid = 'Y' and l_seg_name2_valid = 'Y') OR
      (l_seg_name1_valid = 'Y' and l_seg_name2_valid = 'N' ) OR
      (l_seg_name1_valid = 'N' and l_seg_name2_valid = 'Y') THEN
      p_segment_name_valid := 'Y';
      p_flexfield_rec := l_flexfield_rec;
      p_structure_rec := l_structure_rec;
   ELSE
      IF l_seg_name1_valid = 'N' and l_seg_name2_valid = 'N' THEN
         p_segment_name_valid := 'N';
         raise g_both_seg_name_invalid;
      ELSE
         IF l_seg_name1_valid = 'N'   THEN
            p_segment_name_valid := 'N';
            raise g_seg_name1_invalid;
         ELSE
            IF l_seg_name2_valid = 'N' THEN
               p_segment_name_valid := 'N';
               raise g_seg_name2_invalid;
            END IF;
         END IF;
      END IF;
   END IF;

END validate_seg_col_name;
--
------------------------------------------------------------------------------
-- -------------------------< get_keyflex_info > -----------------------------
------------------------------------------------------------------------------
Procedure get_keyflex_info(p_app_short_name        in varchar2
                          ,p_flex_code             in varchar2
                          ,p_id_flex_num           in number
                          ,p_segment_name1    in varchar2 default null
                          ,p_segment_name2    in varchar2 default null
                          ,p_mapped_tbl_col_name1  out varchar2
                          ,p_mapped_tbl_col_name2  out varchar2
                          ,p_flexfield_rec    in
                                            fnd_flex_key_api.flexfield_type
                          ,p_structure_rec    in
                                            fnd_flex_key_api.structure_type) IS
--
-- ---------------------------------------------------------------------
-- Parameters values:
--  1) p_app_short_name - 'PER' or 'PAY'
--  2) p_flex_code - 'GRP' for People Group
--                 - 'GRD' for Grade
--                 - 'JOB' for Job
--                 - 'POS' for Position
--                 - 'COST' for Cost Allocation
-- ---------------------------------------------------------------------
l_mapped_col_name1   varchar2(30) default null;
l_mapped_col_name2   varchar2(30) default null;
--
l_flexfield_rec    fnd_flex_key_api.flexfield_type;
l_structure_rec    fnd_flex_key_api.structure_type;
l_segment_rec1     fnd_flex_key_api.segment_type;
l_segment_rec2     fnd_flex_key_api.segment_type;

--
Begin
  IF p_segment_name1 is not null THEN
     l_segment_rec1 := fnd_flex_key_api.find_segment
                      (p_flexfield_rec, p_structure_rec,
                       p_segment_name1);
     l_mapped_col_name1 := l_segment_rec1.column_name;
     p_mapped_tbl_col_name1 := l_mapped_col_name1;
  END IF;
  --
  IF p_segment_name2 is not null THEN
     l_segment_rec2  := fnd_flex_key_api.find_segment
                        (p_flexfield_rec, p_structure_rec,
                         p_segment_name2);
     l_mapped_col_name2 := l_segment_rec2.column_name;
     p_mapped_tbl_col_name2 := l_mapped_col_name2;
  END IF;
  --
END get_keyflex_info;

END hr_util_flex_web;

/
