--------------------------------------------------------
--  DDL for Package Body HR_FORM_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_TEMPLATES_API" as
/* $Header: hrtmpapi.pkb 115.8 2003/10/31 06:54:25 bsubrama noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_form_templates_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< session_mode procedures>----------------------|
-- ----------------------------------------------------------------------------
--
procedure set_seed_data_session_mode is
begin
  hr_form_templates_api.g_session_mode := 'SEED_DATA';
end set_seed_data_session_mode;
--
procedure set_customer_data_session_mode is
begin
  hr_form_templates_api.g_session_mode := 'CUSTOMER_DATA';
end set_customer_data_session_mode;
--
function seed_data_session_mode return boolean
is
begin
 IF hr_form_templates_api.g_session_mode = 'SEED_DATA' THEN
    return true;
 END IF;
 return false;
end seed_data_session_mode;
--
procedure assert_seed_data_session_mode is
begin
 IF hr_form_templates_api.g_session_mode = 'SEED_DATA' THEN
-- error message
   fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
   fnd_message.raise_error;
 END IF;
end assert_seed_data_session_mode;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_form_template_id_from        in number
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  --,p_template_name                in varchar2 default hr_api.g_varchar2
  ,p_template_name                in varchar2
  ,p_user_template_name           in varchar2 default hr_api.g_varchar2
  ,p_description                  in varchar2 default hr_api.g_varchar2
  ,p_enabled_flag                 in varchar2 default hr_api.g_varchar2
  ,p_legislation_code             in varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in varchar2 default hr_api.g_varchar2
  ,p_form_template_id_to            out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  Type l_rec_type Is Record
  (application_id hr_form_templates_b.application_id%TYPE
  ,form_id hr_form_templates_b.form_id%TYPE
  ,template_name hr_form_templates_b.template_name%TYPE
  ,enabled_flag hr_form_templates_b.enabled_flag%TYPE
  ,legislation_code hr_form_templates_b.legislation_code%TYPE
  ,attribute_category hr_form_templates_b.attribute_category%TYPE
  ,attribute1 hr_form_templates_b.attribute1%TYPE
  ,attribute2 hr_form_templates_b.attribute2%TYPE
  ,attribute3 hr_form_templates_b.attribute3%TYPE
  ,attribute4 hr_form_templates_b.attribute4%TYPE
  ,attribute5 hr_form_templates_b.attribute5%TYPE
  ,attribute6 hr_form_templates_b.attribute6%TYPE
  ,attribute7 hr_form_templates_b.attribute7%TYPE
  ,attribute8 hr_form_templates_b.attribute8%TYPE
  ,attribute9 hr_form_templates_b.attribute9%TYPE
  ,attribute10 hr_form_templates_b.attribute10%TYPE
  ,attribute11 hr_form_templates_b.attribute11%TYPE
  ,attribute12 hr_form_templates_b.attribute12%TYPE
  ,attribute13 hr_form_templates_b.attribute13%TYPE
  ,attribute14 hr_form_templates_b.attribute14%TYPE
  ,attribute15 hr_form_templates_b.attribute15%TYPE
  ,attribute16 hr_form_templates_b.attribute16%TYPE
  ,attribute17 hr_form_templates_b.attribute17%TYPE
  ,attribute18 hr_form_templates_b.attribute18%TYPE
  ,attribute19 hr_form_templates_b.attribute19%TYPE
  ,attribute20 hr_form_templates_b.attribute20%TYPE
  ,attribute21 hr_form_templates_b.attribute21%TYPE
  ,attribute22 hr_form_templates_b.attribute22%TYPE
  ,attribute23 hr_form_templates_b.attribute23%TYPE
  ,attribute24 hr_form_templates_b.attribute24%TYPE
  ,attribute25 hr_form_templates_b.attribute25%TYPE
  ,attribute26 hr_form_templates_b.attribute26%TYPE
  ,attribute27 hr_form_templates_b.attribute27%TYPE
  ,attribute28 hr_form_templates_b.attribute28%TYPE
  ,attribute29 hr_form_templates_b.attribute29%TYPE
  ,attribute30 hr_form_templates_b.attribute30%TYPE);

  l_rec l_rec_type;

  CURSOR cur_tmplt_rec
  IS
  SELECT tmp.application_id
  ,tmp.form_id
  ,DECODE(p_template_name,hr_api.g_varchar2,tmp.template_name,p_template_name)
  ,DECODE(p_enabled_flag,hr_api.g_varchar2,tmp.enabled_flag,p_enabled_flag)
  ,DECODE(p_legislation_code,hr_api.g_varchar2,tmp.legislation_code,p_legislation_code)
  ,DECODE(p_attribute_category,hr_api.g_varchar2,tmp.attribute_category,p_attribute_category)
  ,DECODE(p_attribute1,hr_api.g_varchar2,tmp.attribute1,p_attribute1)
  ,DECODE(p_attribute2,hr_api.g_varchar2,tmp.attribute2,p_attribute2)
  ,DECODE(p_attribute3,hr_api.g_varchar2,tmp.attribute3,p_attribute3)
  ,DECODE(p_attribute4,hr_api.g_varchar2,tmp.attribute4,p_attribute4)
  ,DECODE(p_attribute5,hr_api.g_varchar2,tmp.attribute5,p_attribute5)
  ,DECODE(p_attribute6,hr_api.g_varchar2,tmp.attribute6,p_attribute6)
  ,DECODE(p_attribute7,hr_api.g_varchar2,tmp.attribute7,p_attribute7)
  ,DECODE(p_attribute8,hr_api.g_varchar2,tmp.attribute8,p_attribute8)
  ,DECODE(p_attribute9,hr_api.g_varchar2,tmp.attribute9,p_attribute9)
  ,DECODE(p_attribute10,hr_api.g_varchar2,tmp.attribute10,p_attribute10)
  ,DECODE(p_attribute11,hr_api.g_varchar2,tmp.attribute11,p_attribute11)
  ,DECODE(p_attribute12,hr_api.g_varchar2,tmp.attribute12,p_attribute12)
  ,DECODE(p_attribute13,hr_api.g_varchar2,tmp.attribute13,p_attribute13)
  ,DECODE(p_attribute14,hr_api.g_varchar2,tmp.attribute14,p_attribute14)
  ,DECODE(p_attribute15,hr_api.g_varchar2,tmp.attribute15,p_attribute15)
  ,DECODE(p_attribute16,hr_api.g_varchar2,tmp.attribute16,p_attribute16)
  ,DECODE(p_attribute17,hr_api.g_varchar2,tmp.attribute17,p_attribute17)
  ,DECODE(p_attribute18,hr_api.g_varchar2,tmp.attribute18,p_attribute18)
  ,DECODE(p_attribute19,hr_api.g_varchar2,tmp.attribute19,p_attribute19)
  ,DECODE(p_attribute20,hr_api.g_varchar2,tmp.attribute20,p_attribute20)
  ,DECODE(p_attribute21,hr_api.g_varchar2,tmp.attribute21,p_attribute21)
  ,DECODE(p_attribute22,hr_api.g_varchar2,tmp.attribute22,p_attribute22)
  ,DECODE(p_attribute23,hr_api.g_varchar2,tmp.attribute23,p_attribute23)
  ,DECODE(p_attribute24,hr_api.g_varchar2,tmp.attribute24,p_attribute24)
  ,DECODE(p_attribute25,hr_api.g_varchar2,tmp.attribute25,p_attribute25)
  ,DECODE(p_attribute26,hr_api.g_varchar2,tmp.attribute26,p_attribute26)
  ,DECODE(p_attribute27,hr_api.g_varchar2,tmp.attribute27,p_attribute27)
  ,DECODE(p_attribute28,hr_api.g_varchar2,tmp.attribute28,p_attribute28)
  ,DECODE(p_attribute29,hr_api.g_varchar2,tmp.attribute29,p_attribute29)
  ,DECODE(p_attribute30,hr_api.g_varchar2,tmp.attribute30,p_attribute30)
  FROM hr_form_templates_b tmp
  WHERE tmp.form_template_id = p_form_template_id_from;

  CURSOR cur_tmplt_tl
  IS
  SELECT COUNT(0)
  ,tmptl.source_lang
  ,DECODE(p_user_template_name,hr_api.g_varchar2,tmptl.user_template_name,p_user_template_name) user_template_name
  ,DECODE(p_description,hr_api.g_varchar2,tmptl.description,p_description) description
  FROM hr_form_templates_tl tmptl
  WHERE tmptl.form_template_id = p_form_template_id_from
  GROUP BY tmptl.source_lang
  ,DECODE(p_user_template_name,hr_api.g_varchar2,tmptl.user_template_name,p_user_template_name)
  ,DECODE(p_description,hr_api.g_varchar2,tmptl.description,p_description)
  ORDER BY 1;

  CURSOR cur_tmplt_win
  IS
  SELECT twn.template_window_id
  FROM hr_template_windows twn
  WHERE twn.form_template_id = p_form_template_id_from;

  CURSOR cur_tmplt_item
  IS
  SELECT tit.template_item_id
  FROM hr_template_items tit
  WHERE tit.form_template_id = p_form_template_id_from;

  CURSOR cur_tmplt_data_group
  IS
  SELECT tdg.template_data_group_id
  FROM hr_template_data_groups tdg
  WHERE tdg.form_template_id = p_form_template_id_from;

  CURSOR csr_source_form_templates
    (p_form_template_id IN NUMBER
    )
  IS
    SELECT sft.form_template_id_from
      FROM hr_source_form_templates sft
     WHERE sft.form_template_id_to = p_form_template_id;
  l_source_form_template csr_source_form_templates%ROWTYPE;

  l_proc                varchar2(72) := g_package||'copy_template';
  l_object_version_number number;
  l_form_template_id_to number;
-- Local Vars not used
  l_form_property_id number;
  l_source_form_template_id number;
  l_template_window_id_to number;
  l_ovn_tmplt_win number;
  l_template_item_id_to number;
  l_ovn_tmplt_item number;
  l_template_data_group_id_to number;
  l_ovn_tmplt_data_group number;
  l_language_code fnd_languages.language_code%TYPE;
  l_form_template_id_from number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_template;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_templates_api_bk1.copy_template_b
      (p_effective_date               => TRUNC(p_effective_date)
      ,p_form_template_id_from       => p_form_template_id_from
      ,p_language_code               => l_language_code
      ,p_template_name               => p_template_name
      ,p_user_template_name          => p_user_template_name
      ,p_description                 => p_description
      ,p_enabled_flag                => p_enabled_flag
      ,p_legislation_code            => p_legislation_code
      ,p_attribute_category          => p_attribute_category
      ,p_attribute1                  => p_attribute1
      ,p_attribute2                  => p_attribute2
      ,p_attribute3                  => p_attribute3
      ,p_attribute4                  => p_attribute4
      ,p_attribute5                  => p_attribute5
      ,p_attribute6                  => p_attribute6
      ,p_attribute7                  => p_attribute7
      ,p_attribute8                  => p_attribute8
      ,p_attribute9                  => p_attribute9
      ,p_attribute10                 => p_attribute10
      ,p_attribute11                 => p_attribute11
      ,p_attribute12                 => p_attribute12
      ,p_attribute13                 => p_attribute13
      ,p_attribute14                 => p_attribute14
      ,p_attribute15                 => p_attribute15
      ,p_attribute16                 => p_attribute16
      ,p_attribute17                 => p_attribute17
      ,p_attribute18                 => p_attribute18
      ,p_attribute19                 => p_attribute19
      ,p_attribute20                 => p_attribute20
      ,p_attribute21                 => p_attribute21
      ,p_attribute22                 => p_attribute22
      ,p_attribute23                 => p_attribute23
      ,p_attribute24                 => p_attribute24
      ,p_attribute25                 => p_attribute25
      ,p_attribute26                 => p_attribute26
      ,p_attribute27                 => p_attribute27
      ,p_attribute28                 => p_attribute28
      ,p_attribute29                 => p_attribute29
      ,p_attribute30                 => p_attribute30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 20);

  OPEN cur_tmplt_rec;
  FETCH cur_tmplt_rec INTO l_rec;
-- ask john not in lld
  IF cur_tmplt_rec%NOTFOUND THEN
   CLOSE cur_tmplt_rec;
-- error message
   fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
   fnd_message.set_token('PROCEDURE', l_proc);
   fnd_message.set_token('STEP','10');
   fnd_message.raise_error;
  END IF;
  CLOSE cur_tmplt_rec;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_tmp_ins.ins(p_effective_date               => TRUNC(p_effective_date)
                ,p_application_id               => l_rec.application_id
                ,p_form_id                      => l_rec.form_id
                ,p_template_name                => l_rec.template_name
                ,p_enabled_flag                 => l_rec.enabled_flag
                ,p_legislation_code             => l_rec.legislation_code
                ,p_attribute_category           => l_rec.attribute_category
                ,p_attribute1                   => l_rec.attribute1
                ,p_attribute2                   => l_rec.attribute2
                ,p_attribute3                   => l_rec.attribute3
                ,p_attribute4                   => l_rec.attribute4
                ,p_attribute5                   => l_rec.attribute5
                ,p_attribute6                   => l_rec.attribute6
                ,p_attribute7                   => l_rec.attribute7
                ,p_attribute8                   => l_rec.attribute8
                ,p_attribute9                   => l_rec.attribute9
                ,p_attribute10                  => l_rec.attribute10
                ,p_attribute11                  => l_rec.attribute11
                ,p_attribute12                  => l_rec.attribute12
                ,p_attribute13                  => l_rec.attribute13
                ,p_attribute14                  => l_rec.attribute14
                ,p_attribute15                  => l_rec.attribute15
                ,p_attribute16                  => l_rec.attribute16
                ,p_attribute17                  => l_rec.attribute17
                ,p_attribute18                  => l_rec.attribute18
                ,p_attribute19                  => l_rec.attribute19
                ,p_attribute20                  => l_rec.attribute20
                ,p_attribute21                  => l_rec.attribute21
                ,p_attribute22                  => l_rec.attribute22
                ,p_attribute23                  => l_rec.attribute23
                ,p_attribute24                  => l_rec.attribute24
                ,p_attribute25                  => l_rec.attribute25
                ,p_attribute26                  => l_rec.attribute26
                ,p_attribute27                  => l_rec.attribute27
                ,p_attribute28                  => l_rec.attribute28
                ,p_attribute29                  => l_rec.attribute29
                ,p_attribute30                  => l_rec.attribute30
                ,p_form_template_id             => l_form_template_id_to
                ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 40);

   IF (p_user_template_name <> hr_api.g_varchar2
            AND p_description <> hr_api.g_varchar2) THEN

    hr_utility.set_location('At:'|| l_proc, 41);

     hr_tmt_ins.ins_tl( p_language_code                => l_language_code
                       ,p_form_template_id             => l_form_template_id_to
                       ,p_user_template_name           => p_user_template_name
                       ,p_description                  => p_description);
  ELSE

    hr_utility.set_location('At:'|| l_proc, 42);

    FOR cur_rec IN cur_tmplt_tl LOOP
       hr_utility.set_location('At:'|| l_proc, 43);

       IF cur_tmplt_tl%ROWCOUNT = 1 THEN
          hr_utility.set_location('At:'|| l_proc, 44);
          hr_tmt_ins.ins_tl(
                  p_language_code                => cur_rec.source_lang
                  ,p_form_template_id             => l_form_template_id_to
                  ,p_user_template_name           => cur_rec.user_template_name
                  ,p_description                  => cur_rec.description);
       ELSE
         hr_utility.set_location('At:'|| l_proc, 45);
         hr_tmt_upd.upd_tl(
                  p_language_code                => cur_rec.source_lang
                  ,p_form_template_id             => l_form_template_id_to
                  ,p_user_template_name           => cur_rec.user_template_name
                  ,p_description                  => cur_rec.description);
       END IF;
    END LOOP;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 50);

  l_object_version_number := p_object_version_number; -- Bug 3211362

  hr_form_properties_bsi.copy_form_property(
            p_effective_date               => TRUNC(p_effective_date)
            ,p_form_template_id_from        => p_form_template_id_from
            ,p_form_template_id_to          => l_form_template_id_to
            ,p_form_property_id             => l_form_property_id
            ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 55);

/*  commented for bug 1692567 and replaced by text immediately below

  l_form_template_id_from := p_form_template_id_from;
  LOOP
    OPEN csr_source_form_templates(l_form_template_id_from);
    FETCH csr_source_form_templates INTO l_source_form_template;
    CLOSE csr_source_form_templates;
    IF (l_source_form_template.form_template_id_from IS NOT NULL)
    THEN
      l_form_template_id_from := l_source_form_template.form_template_id_from;
    ELSE
      EXIT;
    END IF;
  END LOOP;

*/
  l_form_template_id_from := p_form_template_id_from;
  LOOP
    OPEN csr_source_form_templates(l_form_template_id_from);
    FETCH csr_source_form_templates INTO l_source_form_template;
    IF csr_source_form_templates%notfound then
      CLOSE csr_source_form_templates;
      EXIT;
    ELSE
      CLOSE csr_source_form_templates;
    END IF;
    IF (l_source_form_template.form_template_id_from IS NOT NULL)
    THEN
      l_form_template_id_from := l_source_form_template.form_template_id_from;
    ELSE
      EXIT;
    END IF;
  END LOOP;

  hr_source_form_templates_bsi.create_source_form_template(
            p_effective_date                => TRUNC(p_effective_date)
            ,p_form_template_id_to          => l_form_template_id_to
            ,p_form_template_id_from        => l_form_template_id_from
            ,p_source_form_template_id      => l_source_form_template_id
            ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 60);

  FOR cur_rec in cur_tmplt_win LOOP
    hr_template_windows_api.copy_template_window(
               p_effective_date                => TRUNC(p_effective_date)
               ,p_language_code                 => l_language_code
               ,p_template_window_id_from      => cur_rec.template_window_id
               ,p_form_template_id             => l_form_template_id_to
               ,p_template_window_id_to        => l_template_window_id_to
               ,p_object_version_number        => l_ovn_tmplt_win);
  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 65);

  FOR cur_rec in cur_tmplt_item LOOP
    hr_template_items_api.copy_template_item(
               p_effective_date                => TRUNC(p_effective_date)
               ,p_language_code                => l_language_code
               ,p_template_item_id_from        => cur_rec.template_item_id
               ,p_form_template_id             => l_form_template_id_to
               ,p_template_item_id_to          => l_template_item_id_to
               ,p_object_version_number        => l_ovn_tmplt_item);
  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 70);

  FOR cur_rec in cur_tmplt_data_group LOOP
    hr_template_data_groups_api.copy_template_data_group(
               p_effective_date                => TRUNC(p_effective_date)
               ,p_language_code                => l_language_code
               ,p_template_data_group_id_from  => cur_rec.template_data_group_id
               ,p_form_template_id             => l_form_template_id_to
               ,p_template_data_group_id_to    => l_template_data_group_id_to
               ,p_object_version_number        => l_ovn_tmplt_data_group);
  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 75);
  --
  -- Call After Process User Hook
  --
  begin
    hr_form_templates_api_bk1.copy_template_a
      (p_effective_date               => TRUNC(p_effective_date)
      ,p_form_template_id_from       => p_form_template_id_from
      ,p_language_code               => l_language_code
      ,p_template_name               => p_template_name
      ,p_user_template_name          => p_user_template_name
      ,p_description                 => p_description
      ,p_enabled_flag                => p_enabled_flag
      ,p_legislation_code            => p_legislation_code
      ,p_attribute_category          => p_attribute_category
      ,p_attribute1                  => p_attribute1
      ,p_attribute2                  => p_attribute2
      ,p_attribute3                  => p_attribute3
      ,p_attribute4                  => p_attribute4
      ,p_attribute5                  => p_attribute5
      ,p_attribute6                  => p_attribute6
      ,p_attribute7                  => p_attribute7
      ,p_attribute8                  => p_attribute8
      ,p_attribute9                  => p_attribute9
      ,p_attribute10                 => p_attribute10
      ,p_attribute11                 => p_attribute11
      ,p_attribute12                 => p_attribute12
      ,p_attribute13                 => p_attribute13
      ,p_attribute14                 => p_attribute14
      ,p_attribute15                 => p_attribute15
      ,p_attribute16                 => p_attribute16
      ,p_attribute17                 => p_attribute17
      ,p_attribute18                 => p_attribute18
      ,p_attribute19                 => p_attribute19
      ,p_attribute20                 => p_attribute20
      ,p_attribute21                 => p_attribute21
      ,p_attribute22                 => p_attribute22
      ,p_attribute23                 => p_attribute23
      ,p_attribute24                 => p_attribute24
      ,p_attribute25                 => p_attribute25
      ,p_attribute26                 => p_attribute26
      ,p_attribute27                 => p_attribute27
      ,p_attribute28                 => p_attribute28
      ,p_attribute29                 => p_attribute29
      ,p_attribute30                 => p_attribute30
      ,p_form_template_id_to           => l_form_template_id_to
      ,p_object_version_number        => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 80);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_form_template_id_to             := l_form_template_id_to;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 85);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_template_id_to          := null;
    p_object_version_number        := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_form_template_id_to          := null;
    p_object_version_number        := null;

    rollback to copy_template;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_template;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  ,p_application_id               in number
  ,p_form_id                      in number
  ,p_template_name                in varchar2
  ,p_enabled_flag                 in varchar2
  ,p_user_template_name           in varchar2
  ,p_description                  in varchar2 default null
  ,p_legislation_code             in varchar2 default null
  ,p_attribute_category           in varchar2 default null
  ,p_attribute1                   in varchar2 default null
  ,p_attribute2                   in varchar2 default null
  ,p_attribute3                   in varchar2 default null
  ,p_attribute4                   in varchar2 default null
  ,p_attribute5                   in varchar2 default null
  ,p_attribute6                   in varchar2 default null
  ,p_attribute7                   in varchar2 default null
  ,p_attribute8                   in varchar2 default null
  ,p_attribute9                   in varchar2 default null
  ,p_attribute10                  in varchar2 default null
  ,p_attribute11                  in varchar2 default null
  ,p_attribute12                  in varchar2 default null
  ,p_attribute13                  in varchar2 default null
  ,p_attribute14                  in varchar2 default null
  ,p_attribute15                  in varchar2 default null
  ,p_attribute16                  in varchar2 default null
  ,p_attribute17                  in varchar2 default null
  ,p_attribute18                  in varchar2 default null
  ,p_attribute19                  in varchar2 default null
  ,p_attribute20                  in varchar2 default null
  ,p_attribute21                  in varchar2 default null
  ,p_attribute22                  in varchar2 default null
  ,p_attribute23                  in varchar2 default null
  ,p_attribute24                  in varchar2 default null
  ,p_attribute25                  in varchar2 default null
  ,p_attribute26                  in varchar2 default null
  ,p_attribute27                  in varchar2 default null
  ,p_attribute28                  in varchar2 default null
  ,p_attribute29                  in varchar2 default null
  ,p_attribute30                  in varchar2 default null
  ,p_help_target                  in varchar2 default hr_api.g_varchar2
  ,p_information_category         in varchar2 default hr_api.g_varchar2
  ,p_information1                 in varchar2 default hr_api.g_varchar2
  ,p_information2                 in varchar2 default hr_api.g_varchar2
  ,p_information3                 in varchar2 default hr_api.g_varchar2
  ,p_information4                 in varchar2 default hr_api.g_varchar2
  ,p_information5                 in varchar2 default hr_api.g_varchar2
  ,p_information6                 in varchar2 default hr_api.g_varchar2
  ,p_information7                 in varchar2 default hr_api.g_varchar2
  ,p_information8                 in varchar2 default hr_api.g_varchar2
  ,p_information9                 in varchar2 default hr_api.g_varchar2
  ,p_information10                in varchar2 default hr_api.g_varchar2
  ,p_information11                in varchar2 default hr_api.g_varchar2
  ,p_information12                in varchar2 default hr_api.g_varchar2
  ,p_information13                in varchar2 default hr_api.g_varchar2
  ,p_information14                in varchar2 default hr_api.g_varchar2
  ,p_information15                in varchar2 default hr_api.g_varchar2
  ,p_information16                in varchar2 default hr_api.g_varchar2
  ,p_information17                in varchar2 default hr_api.g_varchar2
  ,p_information18                in varchar2 default hr_api.g_varchar2
  ,p_information19                in varchar2 default hr_api.g_varchar2
  ,p_information20                in varchar2 default hr_api.g_varchar2
  ,p_information21                in varchar2 default hr_api.g_varchar2
  ,p_information22                in varchar2 default hr_api.g_varchar2
  ,p_information23                in varchar2 default hr_api.g_varchar2
  ,p_information24                in varchar2 default hr_api.g_varchar2
  ,p_information25                in varchar2 default hr_api.g_varchar2
  ,p_information26                in varchar2 default hr_api.g_varchar2
  ,p_information27                in varchar2 default hr_api.g_varchar2
  ,p_information28                in varchar2 default hr_api.g_varchar2
  ,p_information29                in varchar2 default hr_api.g_varchar2
  ,p_information30                in varchar2 default hr_api.g_varchar2
  ,p_form_template_id                out nocopy number
  ,p_object_version_number           out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_template';
  l_form_template_id number;
  l_object_version_number number;
-- local vars
  l_form_property_id number;
  l_source_form_template_id number;
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_template;
  --
  -- Truncate the time portion from all IN date parameters
  --
    -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_templates_api_bk2.create_template_b
      (p_effective_date              => TRUNC(p_effective_date)
      ,p_language_code               => l_language_code
      ,p_application_id              => p_application_id
      ,p_form_id                     => p_form_id
      ,p_template_name               => p_template_name
      ,p_enabled_flag                => p_enabled_flag
      ,p_user_template_name          => p_user_template_name
      ,p_description                 => p_description
      ,p_legislation_code            => p_legislation_code
      ,p_attribute_category          => p_attribute_category
      ,p_attribute1                  => p_attribute1
      ,p_attribute2                  => p_attribute2
      ,p_attribute3                  => p_attribute3
      ,p_attribute4                  => p_attribute4
      ,p_attribute5                  => p_attribute5
      ,p_attribute6                  => p_attribute6
      ,p_attribute7                  => p_attribute7
      ,p_attribute8                  => p_attribute8
      ,p_attribute9                  => p_attribute9
      ,p_attribute10                 => p_attribute10
      ,p_attribute11                 => p_attribute11
      ,p_attribute12                 => p_attribute12
      ,p_attribute13                 => p_attribute13
      ,p_attribute14                 => p_attribute14
      ,p_attribute15                 => p_attribute15
      ,p_attribute16                 => p_attribute16
      ,p_attribute17                 => p_attribute17
      ,p_attribute18                 => p_attribute18
      ,p_attribute19                 => p_attribute19
      ,p_attribute20                 => p_attribute20
      ,p_attribute21                 => p_attribute21
      ,p_attribute22                 => p_attribute22
      ,p_attribute23                 => p_attribute23
      ,p_attribute24                 => p_attribute24
      ,p_attribute25                 => p_attribute25
      ,p_attribute26                 => p_attribute26
      ,p_attribute27                 => p_attribute27
      ,p_attribute28                 => p_attribute28
      ,p_attribute29                 => p_attribute29
      ,p_attribute30                 => p_attribute30
      ,p_help_target                 => p_help_target
      ,p_information_category        => p_information_category
      ,p_information1                => p_information1
      ,p_information2                => p_information2
      ,p_information3                => p_information3
      ,p_information4                => p_information4
      ,p_information5                => p_information5
      ,p_information6                => p_information6
      ,p_information7                => p_information7
      ,p_information8                => p_information8
      ,p_information9                => p_information9
      ,p_information10               => p_information10
      ,p_information11               => p_information11
      ,p_information12               => p_information12
      ,p_information13               => p_information13
      ,p_information14               => p_information14
      ,p_information15               => p_information15
      ,p_information16               => p_information16
      ,p_information17               => p_information17
      ,p_information18               => p_information18
      ,p_information19               => p_information19
      ,p_information20               => p_information20
      ,p_information21               => p_information21
      ,p_information22               => p_information22
      ,p_information23               => p_information23
      ,p_information24               => p_information24
      ,p_information25               => p_information25
      ,p_information26               => p_information26
      ,p_information27               => p_information27
      ,p_information28               => p_information28
      ,p_information29               => p_information29
      ,p_information30               => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_utility.set_location(' At:'||l_proc, 20);

  hr_tmp_ins.ins( p_effective_date           => TRUNC(p_effective_date)
             ,p_application_id               => p_application_id
             ,p_form_id                      => p_form_id
             ,p_template_name                => p_template_name
             ,p_enabled_flag                 => p_enabled_flag
             ,p_legislation_code             => p_legislation_code
             ,p_attribute_category           => p_attribute_category
             ,p_attribute1                   => p_attribute1
             ,p_attribute2                   => p_attribute2
             ,p_attribute3                   => p_attribute3
             ,p_attribute4                   => p_attribute4
             ,p_attribute5                   => p_attribute5
             ,p_attribute6                   => p_attribute6
             ,p_attribute7                   => p_attribute7
             ,p_attribute8                   => p_attribute8
             ,p_attribute9                   => p_attribute9
             ,p_attribute10                  => p_attribute10
             ,p_attribute11                  => p_attribute11
             ,p_attribute12                  => p_attribute12
             ,p_attribute13                  => p_attribute13
             ,p_attribute14                  => p_attribute14
             ,p_attribute15                  => p_attribute15
             ,p_attribute16                  => p_attribute16
             ,p_attribute17                  => p_attribute17
             ,p_attribute18                  => p_attribute18
             ,p_attribute19                  => p_attribute19
             ,p_attribute20                  => p_attribute20
             ,p_attribute21                  => p_attribute21
             ,p_attribute22                  => p_attribute22
             ,p_attribute23                  => p_attribute23
             ,p_attribute24                  => p_attribute24
             ,p_attribute25                  => p_attribute25
             ,p_attribute26                  => p_attribute26
             ,p_attribute27                  => p_attribute27
             ,p_attribute28                  => p_attribute28
             ,p_attribute29                  => p_attribute29
             ,p_attribute30                  => p_attribute30
             ,p_form_template_id             => l_form_template_id
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location(' At:'||l_proc, 25);

  hr_tmt_ins.ins_tl( p_language_code                => l_language_code
             ,p_form_template_id             => l_form_template_id
             ,p_user_template_name           => p_user_template_name
             ,p_description                  => p_description);

  hr_utility.set_location(' At:'||l_proc, 30);

  hr_form_properties_bsi.copy_form_property(
             p_effective_date                => TRUNC(p_effective_date)
             ,p_application_id               => p_application_id
             ,p_form_id                      => p_form_id
             ,p_form_template_id             => l_form_template_id
             ,p_help_target                  => p_help_target
             ,p_information_category         => p_information_category
             ,p_information1                 => p_information1
             ,p_information2                 => p_information2
             ,p_information3                 => p_information3
             ,p_information4                 => p_information4
             ,p_information5                 => p_information5
             ,p_information6                 => p_information6
             ,p_information7                 => p_information7
             ,p_information8                 => p_information8
             ,p_information9                 => p_information9
             ,p_information10                => p_information10
             ,p_information11                => p_information11
             ,p_information12                => p_information12
             ,p_information13                => p_information13
             ,p_information14                => p_information14
             ,p_information15                => p_information15
             ,p_information16                => p_information16
             ,p_information17                => p_information17
             ,p_information18                => p_information18
             ,p_information19                => p_information19
             ,p_information20                => p_information20
             ,p_information21                => p_information21
             ,p_information22                => p_information22
             ,p_information23                => p_information23
             ,p_information24                => p_information24
             ,p_information25                => p_information25
             ,p_information26                => p_information26
             ,p_information27                => p_information27
             ,p_information28                => p_information28
             ,p_information29                => p_information29
             ,p_information30                => p_information30
             ,p_form_property_id             => l_form_property_id
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location(' At:'||l_proc, 30);

   IF g_session_mode <> 'SEED_DATA' THEN

     hr_source_form_templates_bsi.create_source_form_template(
                p_effective_date                => TRUNC(p_effective_date)
                ,p_form_template_id_to          => l_form_template_id
                ,p_form_template_id_from        => NULL
                ,p_source_form_template_id      => l_source_form_template_id
                ,p_object_version_number        => l_object_version_number);
   END IF;

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_templates_api_bk2.create_template_a
      (p_effective_date              => TRUNC(p_effective_date)
      ,p_language_code               => l_language_code
      ,p_application_id              => p_application_id
      ,p_form_id                     => p_form_id
      ,p_template_name               => p_template_name
      ,p_enabled_flag                => p_enabled_flag
      ,p_user_template_name          => p_user_template_name
      ,p_description                 => p_description
      ,p_legislation_code            => p_legislation_code
      ,p_attribute_category          => p_attribute_category
      ,p_attribute1                  => p_attribute1
      ,p_attribute2                  => p_attribute2
      ,p_attribute3                  => p_attribute3
      ,p_attribute4                  => p_attribute4
      ,p_attribute5                  => p_attribute5
      ,p_attribute6                  => p_attribute6
      ,p_attribute7                  => p_attribute7
      ,p_attribute8                  => p_attribute8
      ,p_attribute9                  => p_attribute9
      ,p_attribute10                 => p_attribute10
      ,p_attribute11                 => p_attribute11
      ,p_attribute12                 => p_attribute12
      ,p_attribute13                 => p_attribute13
      ,p_attribute14                 => p_attribute14
      ,p_attribute15                 => p_attribute15
      ,p_attribute16                 => p_attribute16
      ,p_attribute17                 => p_attribute17
      ,p_attribute18                 => p_attribute18
      ,p_attribute19                 => p_attribute19
      ,p_attribute20                 => p_attribute20
      ,p_attribute21                 => p_attribute21
      ,p_attribute22                 => p_attribute22
      ,p_attribute23                 => p_attribute23
      ,p_attribute24                 => p_attribute24
      ,p_attribute25                 => p_attribute25
      ,p_attribute26                 => p_attribute26
      ,p_attribute27                 => p_attribute27
      ,p_attribute28                 => p_attribute28
      ,p_attribute29                 => p_attribute29
      ,p_attribute30                 => p_attribute30
      ,p_help_target                 => p_help_target
      ,p_information_category        => p_information_category
      ,p_information1                => p_information1
      ,p_information2                => p_information2
      ,p_information3                => p_information3
      ,p_information4                => p_information4
      ,p_information5                => p_information5
      ,p_information6                => p_information6
      ,p_information7                => p_information7
      ,p_information8                => p_information8
      ,p_information9                => p_information9
      ,p_information10               => p_information10
      ,p_information11               => p_information11
      ,p_information12               => p_information12
      ,p_information13               => p_information13
      ,p_information14               => p_information14
      ,p_information15               => p_information15
      ,p_information16               => p_information16
      ,p_information17               => p_information17
      ,p_information18               => p_information18
      ,p_information19               => p_information19
      ,p_information20               => p_information20
      ,p_information21               => p_information21
      ,p_information22               => p_information22
      ,p_information23               => p_information23
      ,p_information24               => p_information24
      ,p_information25               => p_information25
      ,p_information26               => p_information26
      ,p_information27               => p_information27
      ,p_information28               => p_information28
      ,p_information29               => p_information29
      ,p_information30               => p_information30
      ,p_form_template_id            => l_form_template_id
      ,p_object_version_number       => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_form_template_id            := l_form_template_id;
  p_object_version_number       := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_template_id       := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
     p_form_template_id       := null;
    p_object_version_number  := null;

    rollback to create_template;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_template;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template
  (p_validate                      in boolean  default false
  ,p_form_template_id              in number
  ,p_object_version_number         in number
  ,p_delete_children_flag          in varchar2 default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_del_item
  IS
  SELECT template_item_id
  ,object_version_number
  FROM hr_template_items
  WHERE form_template_id = p_form_template_id;

  CURSOR cur_del_win
  IS
  SELECT template_window_id
  ,object_version_number
  FROM hr_template_windows
  WHERE form_template_id = p_form_template_id;

  CURSOR cur_del_data_group
  IS
  SELECT template_data_group_id
  ,object_version_number
  FROM hr_template_data_groups
  WHERE form_template_id = p_form_template_id;

  CURSOR cur_del_form_tmplt
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates
  WHERE form_template_id_to = p_form_template_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
  WHERE hsf.form_template_id_to = p_form_template_id;

  l_proc                varchar2(72) := g_package||'delete_template';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_templates_api_bk3.delete_template_b
      (p_form_template_id       => p_form_template_id
       ,p_object_version_number => p_object_version_number
       ,p_delete_children_flag  => p_delete_children_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- extra validation
  hr_utility.set_location('At:'|| l_proc, 20);
     OPEN cur_api_val;
     FETCH cur_api_val INTO l_temp;
     IF (cur_api_val%NOTFOUND AND
         hr_form_templates_api.g_session_mode <> 'SEED_DATA') THEN
         CLOSE cur_api_val;
       -- error message
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE', l_proc);
       fnd_message.set_token('STEP','10');
       fnd_message.raise_error;
     END IF;
     CLOSE cur_api_val;
  --
  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 30);

  hr_tmp_shd.lck( p_form_template_id             => p_form_template_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 40);
  IF p_delete_children_flag = 'Y' THEN
    hr_utility.set_location('At:'|| l_proc, 50);

    FOR cur_rec in cur_del_item LOOP
      hr_template_items_api.delete_template_item(
                 p_template_item_id             => cur_rec.template_item_id
                ,p_object_version_number        => cur_rec.object_version_number
                ,p_delete_children_flag         => p_delete_children_flag);
    END LOOP;

    hr_utility.set_location('At:'|| l_proc, 60);

    FOR cur_rec in cur_del_win LOOP
      hr_template_windows_api.delete_template_window(
                p_template_window_id           => cur_rec.template_window_id
                ,p_object_version_number        => cur_rec.object_version_number
                ,p_delete_children_flag         => p_delete_children_flag);
    END LOOP;

    hr_utility.set_location('At:'|| l_proc, 70);

    FOR cur_rec in cur_del_data_group LOOP
      hr_template_data_groups_api.delete_template_data_group(
               p_template_data_group_id       => cur_rec.template_data_group_id
               ,p_object_version_number        => cur_rec.object_version_number);
    END LOOP;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 80);

  FOR cur_rec in cur_del_form_tmplt LOOP
    hr_source_form_templates_bsi.delete_source_form_template
           (p_source_form_template_id      => cur_rec.source_form_template_id
           ,p_object_version_number        => p_object_version_number);
  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 81);

  hr_form_properties_bsi.delete_form_property
             (p_form_template_id             => p_form_template_id
             ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 82);

  hr_tmt_del.del_tl(p_form_template_id             => p_form_template_id);

  hr_utility.set_location('At:'|| l_proc, 83);

  hr_tmp_del.del( p_form_template_id             => p_form_template_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 84);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_templates_api_bk3.delete_template_a
      (p_form_template_id       => p_form_template_id
       ,p_object_version_number => p_object_version_number
       ,p_delete_children_flag  => p_delete_children_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 85);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 91);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_template;
    hr_utility.set_location(' Leaving:'||l_proc, 92);
    raise;
end delete_template;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_template
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_form_template_id             in number
  ,p_object_version_number        in out nocopy number
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  ,p_template_name                in varchar2 default hr_api.g_varchar2
  ,p_enabled_flag                 in varchar2 default hr_api.g_varchar2
  ,p_user_template_name           in varchar2 default hr_api.g_varchar2
  ,p_description                  in varchar2 default hr_api.g_varchar2
  ,p_legislation_code             in varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in varchar2 default hr_api.g_varchar2
  ,p_help_target                  in varchar2 default hr_api.g_varchar2
  ,p_information_category         in varchar2 default hr_api.g_varchar2
  ,p_information1                 in varchar2 default hr_api.g_varchar2
  ,p_information2                 in varchar2 default hr_api.g_varchar2
  ,p_information3                 in varchar2 default hr_api.g_varchar2
  ,p_information4                 in varchar2 default hr_api.g_varchar2
  ,p_information5                 in varchar2 default hr_api.g_varchar2
  ,p_information6                 in varchar2 default hr_api.g_varchar2
  ,p_information7                 in varchar2 default hr_api.g_varchar2
  ,p_information8                 in varchar2 default hr_api.g_varchar2
  ,p_information9                 in varchar2 default hr_api.g_varchar2
  ,p_information10                in varchar2 default hr_api.g_varchar2
  ,p_information11                in varchar2 default hr_api.g_varchar2
  ,p_information12                in varchar2 default hr_api.g_varchar2
  ,p_information13                in varchar2 default hr_api.g_varchar2
  ,p_information14                in varchar2 default hr_api.g_varchar2
  ,p_information15                in varchar2 default hr_api.g_varchar2
  ,p_information16                in varchar2 default hr_api.g_varchar2
  ,p_information17                in varchar2 default hr_api.g_varchar2
  ,p_information18                in varchar2 default hr_api.g_varchar2
  ,p_information19                in varchar2 default hr_api.g_varchar2
  ,p_information20                in varchar2 default hr_api.g_varchar2
  ,p_information21                in varchar2 default hr_api.g_varchar2
  ,p_information22                in varchar2 default hr_api.g_varchar2
  ,p_information23                in varchar2 default hr_api.g_varchar2
  ,p_information24                in varchar2 default hr_api.g_varchar2
  ,p_information25                in varchar2 default hr_api.g_varchar2
  ,p_information26                in varchar2 default hr_api.g_varchar2
  ,p_information27                in varchar2 default hr_api.g_varchar2
  ,p_information28                in varchar2 default hr_api.g_varchar2
  ,p_information29                in varchar2 default hr_api.g_varchar2
  ,p_information30                in varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_temp number;
  l_language_code fnd_languages.language_code%TYPE;


  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
  WHERE hsf.form_template_id_to = p_form_template_id;

  l_proc                varchar2(72) := g_package||'update_template';
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_template;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
     l_object_version_number := p_object_version_number;
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_templates_api_bk4.update_template_b
      (p_effective_date              => TRUNC(p_effective_date)
      ,p_form_template_id            => p_form_template_id
      ,p_object_version_number       => l_object_version_number
      ,p_language_code               => l_language_code
      ,p_template_name               => p_template_name
      ,p_enabled_flag                => p_enabled_flag
      ,p_user_template_name          => p_user_template_name
      ,p_description                 => p_description
      ,p_legislation_code            => p_legislation_code
      ,p_attribute_category          => p_attribute_category
      ,p_attribute1                  => p_attribute1
      ,p_attribute2                  => p_attribute2
      ,p_attribute3                  => p_attribute3
      ,p_attribute4                  => p_attribute4
      ,p_attribute5                  => p_attribute5
      ,p_attribute6                  => p_attribute6
      ,p_attribute7                  => p_attribute7
      ,p_attribute8                  => p_attribute8
      ,p_attribute9                  => p_attribute9
      ,p_attribute10                 => p_attribute10
      ,p_attribute11                 => p_attribute11
      ,p_attribute12                 => p_attribute12
      ,p_attribute13                 => p_attribute13
      ,p_attribute14                 => p_attribute14
      ,p_attribute15                 => p_attribute15
      ,p_attribute16                 => p_attribute16
      ,p_attribute17                 => p_attribute17
      ,p_attribute18                 => p_attribute18
      ,p_attribute19                 => p_attribute19
      ,p_attribute20                 => p_attribute20
      ,p_attribute21                 => p_attribute21
      ,p_attribute22                 => p_attribute22
      ,p_attribute23                 => p_attribute23
      ,p_attribute24                 => p_attribute24
      ,p_attribute25                 => p_attribute25
      ,p_attribute26                 => p_attribute26
      ,p_attribute27                 => p_attribute27
      ,p_attribute28                 => p_attribute28
      ,p_attribute29                 => p_attribute29
      ,p_attribute30                 => p_attribute30
      ,p_help_target                 => p_help_target
      ,p_information_category        => p_information_category
      ,p_information1                => p_information1
      ,p_information2                => p_information2
      ,p_information3                => p_information3
      ,p_information4                => p_information4
      ,p_information5                => p_information5
      ,p_information6                => p_information6
      ,p_information7                => p_information7
      ,p_information8                => p_information8
      ,p_information9                => p_information9
      ,p_information10               => p_information10
      ,p_information11               => p_information11
      ,p_information12               => p_information12
      ,p_information13               => p_information13
      ,p_information14               => p_information14
      ,p_information15               => p_information15
      ,p_information16               => p_information16
      ,p_information17               => p_information17
      ,p_information18               => p_information18
      ,p_information19               => p_information19
      ,p_information20               => p_information20
      ,p_information21               => p_information21
      ,p_information22               => p_information22
      ,p_information23               => p_information23
      ,p_information24               => p_information24
      ,p_information25               => p_information25
      ,p_information26               => p_information26
      ,p_information27               => p_information27
      ,p_information28               => p_information28
      ,p_information29               => p_information29
      ,p_information30               => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template'
        ,p_hook_type   => 'BP'
        );
  end;
  -- Extra Validation
  hr_utility.set_location('At:'|| l_proc, 20);

     OPEN cur_api_val;
     FETCH cur_api_val INTO l_temp;
     IF (cur_api_val%NOTFOUND AND
         hr_form_templates_api.g_session_mode <> 'SEED_DATA') THEN
         CLOSE cur_api_val;
       -- error message
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE', l_proc);
       fnd_message.set_token('STEP','10');
       fnd_message.raise_error;
     END IF;
     CLOSE cur_api_val;
  --
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_tmp_upd.upd( p_effective_date           => TRUNC(p_effective_date)
             ,p_form_template_id             => p_form_template_id
             ,p_template_name                => p_template_name
             ,p_enabled_flag                 => p_enabled_flag
             ,p_legislation_code             => p_legislation_code
             ,p_attribute_category           => p_attribute_category
             ,p_attribute1                   => p_attribute1
             ,p_attribute2                   => p_attribute2
             ,p_attribute3                   => p_attribute3
             ,p_attribute4                   => p_attribute4
             ,p_attribute5                   => p_attribute5
             ,p_attribute6                   => p_attribute6
             ,p_attribute7                   => p_attribute7
             ,p_attribute8                   => p_attribute8
             ,p_attribute9                   => p_attribute9
             ,p_attribute10                  => p_attribute10
             ,p_attribute11                  => p_attribute11
             ,p_attribute12                  => p_attribute12
             ,p_attribute13                  => p_attribute13
             ,p_attribute14                  => p_attribute14
             ,p_attribute15                  => p_attribute15
             ,p_attribute16                  => p_attribute16
             ,p_attribute17                  => p_attribute17
             ,p_attribute18                  => p_attribute18
             ,p_attribute19                  => p_attribute19
             ,p_attribute20                  => p_attribute20
             ,p_attribute21                  => p_attribute21
             ,p_attribute22                  => p_attribute22
             ,p_attribute23                  => p_attribute23
             ,p_attribute24                  => p_attribute24
             ,p_attribute25                  => p_attribute25
             ,p_attribute26                  => p_attribute26
             ,p_attribute27                  => p_attribute27
             ,p_attribute28                  => p_attribute28
             ,p_attribute29                  => p_attribute29
             ,p_attribute30                  => p_attribute30
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 35);

  hr_tmt_upd.upd_tl( p_language_code                => l_language_code
             ,p_form_template_id             => p_form_template_id
             ,p_user_template_name           => p_user_template_name
             ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 40);

  l_object_version_number := p_object_version_number; --3211362

  hr_form_properties_bsi.update_form_property(
             p_effective_date                => TRUNC(p_effective_date)
             ,p_object_version_number        => l_object_version_number
             ,p_form_template_id             => p_form_template_id
             ,p_help_target                  => p_help_target
             ,p_information_category         => p_information_category
             ,p_information1                 => p_information1
             ,p_information2                 => p_information2
             ,p_information3                 => p_information3
             ,p_information4                 => p_information4
             ,p_information5                 => p_information5
             ,p_information6                 => p_information6
             ,p_information7                 => p_information7
             ,p_information8                 => p_information8
             ,p_information9                 => p_information9
             ,p_information10                => p_information10
             ,p_information11                => p_information11
             ,p_information12                => p_information12
             ,p_information13                => p_information13
             ,p_information14                => p_information14
             ,p_information15                => p_information15
             ,p_information16                => p_information16
             ,p_information17                => p_information17
             ,p_information18                => p_information18
             ,p_information19                => p_information19
             ,p_information20                => p_information20
             ,p_information21                => p_information21
             ,p_information22                => p_information22
             ,p_information23                => p_information23
             ,p_information24                => p_information24
             ,p_information25                => p_information25
             ,p_information26                => p_information26
             ,p_information27                => p_information27
             ,p_information28                => p_information28
             ,p_information29                => p_information29
             ,p_information30                => p_information30);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_templates_api_bk4.update_template_a
      (p_effective_date              => TRUNC(p_effective_date)
      ,p_form_template_id            => p_form_template_id
      ,p_object_version_number       => l_object_version_number
      ,p_language_code               => l_language_code
      ,p_template_name               => p_template_name
      ,p_enabled_flag                => p_enabled_flag
      ,p_user_template_name          => p_user_template_name
      ,p_description                 => p_description
      ,p_legislation_code            => p_legislation_code
      ,p_attribute_category          => p_attribute_category
      ,p_attribute1                  => p_attribute1
      ,p_attribute2                  => p_attribute2
      ,p_attribute3                  => p_attribute3
      ,p_attribute4                  => p_attribute4
      ,p_attribute5                  => p_attribute5
      ,p_attribute6                  => p_attribute6
      ,p_attribute7                  => p_attribute7
      ,p_attribute8                  => p_attribute8
      ,p_attribute9                  => p_attribute9
      ,p_attribute10                 => p_attribute10
      ,p_attribute11                 => p_attribute11
      ,p_attribute12                 => p_attribute12
      ,p_attribute13                 => p_attribute13
      ,p_attribute14                 => p_attribute14
      ,p_attribute15                 => p_attribute15
      ,p_attribute16                 => p_attribute16
      ,p_attribute17                 => p_attribute17
      ,p_attribute18                 => p_attribute18
      ,p_attribute19                 => p_attribute19
      ,p_attribute20                 => p_attribute20
      ,p_attribute21                 => p_attribute21
      ,p_attribute22                 => p_attribute22
      ,p_attribute23                 => p_attribute23
      ,p_attribute24                 => p_attribute24
      ,p_attribute25                 => p_attribute25
      ,p_attribute26                 => p_attribute26
      ,p_attribute27                 => p_attribute27
      ,p_attribute28                 => p_attribute28
      ,p_attribute29                 => p_attribute29
      ,p_attribute30                 => p_attribute30
      ,p_help_target                 => p_help_target
      ,p_information_category        => p_information_category
      ,p_information1                => p_information1
      ,p_information2                => p_information2
      ,p_information3                => p_information3
      ,p_information4                => p_information4
      ,p_information5                => p_information5
      ,p_information6                => p_information6
      ,p_information7                => p_information7
      ,p_information8                => p_information8
      ,p_information9                => p_information9
      ,p_information10               => p_information10
      ,p_information11               => p_information11
      ,p_information12               => p_information12
      ,p_information13               => p_information13
      ,p_information14               => p_information14
      ,p_information15               => p_information15
      ,p_information16               => p_information16
      ,p_information17               => p_information17
      ,p_information18               => p_information18
      ,p_information19               => p_information19
      ,p_information20               => p_information20
      ,p_information21               => p_information21
      ,p_information22               => p_information22
      ,p_information23               => p_information23
      ,p_information24               => p_information24
      ,p_information25               => p_information25
      ,p_information26               => p_information26
      ,p_information27               => p_information27
      ,p_information28               => p_information28
      ,p_information29               => p_information29
      ,p_information30               => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_template;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_template;
--
end hr_form_templates_api;

/
