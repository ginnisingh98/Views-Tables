--------------------------------------------------------
--  DDL for Package Body PAY_LOADER_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_LOADER_UTILS_PKG" AS
/* $Header: pyldutil.pkb 120.4 2005/10/19 04:17 pgongada noship $ */

g_package  varchar2(33) := '  pay_loader_utils_pkg.';
--
g_rfm_old_rec  PAY_RFM_SHD.G_REC_TYPE;
g_rfm_effective_end_date date := hr_api.g_eot;
--
g_rfi_old_rec  PAY_RFI_SHD.G_REC_TYPE;
g_rfi_effective_end_date date := hr_api.g_eot;
--
g_ecu_old_rec  PAY_ECU_SHD.G_REC_TYPE;
g_ecu_effective_end_date date := hr_api.g_eot;

g_usage_id number := -1;
-- ----------------------------------------------------------------------------
-- |-------------------------< enable_startup_mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure is called prior to calling an API for a startup data entity,
-- and is used to set the mode which is to be used for the startup data entity.
--
-- ----------------------------------------------------------------------------
PROCEDURE enable_startup_mode
               ( p_business_group_id  in number
                ,p_legislation_code   in varchar2  ) IS
--
l_proc   varchar2(72) := g_package||'enable_startup_mode';
l_mode   varchar2(10);
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_business_group_id is not null and p_legislation_code is null then
         l_mode := 'USER';
  elsif p_business_group_id is null and p_legislation_code is not null then
         l_mode := 'STARTUP';
  elsif p_business_group_id is null and p_legislation_code is null then
         l_mode := 'GENERIC';
  end if;

  hr_startup_data_api_support.enable_startup_mode(l_mode);

  if l_mode <> 'USER' then
    hr_startup_data_api_support.delete_owner_definitions;
    hr_startup_data_api_support.create_owner_definition('PAY');
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
END enable_startup_mode;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< init_fndload >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure is called prior to calling an API to initialize the
-- global security context for a database session.
-- When an API is called the context will be used by the who triggers
-- to derive the who columns.
--
-- ----------------------------------------------------------------------------
PROCEDURE init_fndload
              ( p_owner  in varchar2 ) IS
--
l_proc   varchar2(72) := g_package||'init_fndload';
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_owner = 'SEED' then
      hr_general2.init_fndload
              (p_resp_appl_id => 801
              ,p_user_id      => 1
              );
  else
      hr_general2.init_fndload
              (p_resp_appl_id => 801
              ,p_user_id      => -1
              );
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
END init_fndload;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_business_group_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure derives the business group id from the business group name.
-- It returns null if the business group does not exist.
--
-- ----------------------------------------------------------------------------
FUNCTION get_business_group_id
               ( p_business_group_name  in varchar2 )
RETURN number IS
--
cursor csr_bg_id is
      select  business_group_id
        from  per_business_groups
       where  name = p_business_group_name;
--
l_proc     varchar2(72) := g_package||'get_business_group_id';
l_business_group_id   PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
--
BEGIN
--

  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_business_group_name is not null then

        open csr_bg_id;
        fetch csr_bg_id into l_business_group_id;
        close csr_bg_id;

  end if;

  hr_utility.set_location('Entering:'||l_proc, 5);

  return l_business_group_id;
--
END get_business_group_id;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_event_group_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure derives the event group id from the event group name.
-- It returns null if the event group name not exist.
--
-- ----------------------------------------------------------------------------
FUNCTION get_event_group_id
               ( p_event_group_name  in varchar2,
                 p_legislation_code  in varchar2,
                 p_business_group_id in number)
RETURN number IS
--
cursor csr_evg_grp_id is
      select  event_group_id
        from  pay_event_groups evg
       where  evg.event_group_name = p_event_group_name
       and    nvl(evg.legislation_code,hr_api.g_varchar2) = nvl(p_legislation_code,hr_api.g_varchar2)
       and    nvl(evg.business_group_id,hr_api.g_number) = nvl(p_business_group_id,hr_api.g_number);
--
l_proc     varchar2(72) := g_package||'get_event_group_id';
l_event_group_id pay_event_groups.event_group_id%type;
--
BEGIN
--

  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_event_group_name is not null then

        open csr_evg_grp_id;
        fetch csr_evg_grp_id into l_event_group_id;
        close csr_evg_grp_id;

  end if;

  hr_utility.set_location('Entering:'||l_proc, 5);

  return l_event_group_id;
--
END get_event_group_id;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_element_set_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure derives the element set id from the element_set_name.
-- It returns null if the element set name does not exist.
--
-- ----------------------------------------------------------------------------
FUNCTION get_element_set_id
               ( p_element_set_name  in varchar2,
                 p_legislation_code  in varchar2,
                 p_business_group_id in number)
RETURN number IS
--
cursor csr_eset_id is
      select  element_set_id
        from  pay_element_sets els
       where  els.element_set_name = p_element_set_name
       and    nvl(els.legislation_code,hr_api.g_varchar2) = nvl(p_legislation_code,hr_api.g_varchar2)
       and    nvl(els.business_group_id,hr_api.g_number) = nvl(p_business_group_id,hr_api.g_number);
--
l_proc     varchar2(72) := g_package||'get_element_set_id';
l_element_set_id pay_element_sets.element_set_id%type;
--
BEGIN
--

  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_element_set_name is not null then

        open csr_eset_id;
        fetch csr_eset_id into l_element_set_id;
        close csr_eset_id;

  end if;

  hr_utility.set_location('Entering:'||l_proc, 5);

  return l_element_set_id;
--
END get_element_set_id;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_user_entity_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure derives the user entity id  from its
-- true key -  user entity name , legislation code and business group.
-- It returns null if the user entity does not exist.
-- This procedure cannot be used to get the user_entity_id of  user entities
-- belonging to any business group.
--
-- ----------------------------------------------------------------------------
FUNCTION get_user_entity_id
               ( p_user_entity_name  in varchar2
                ,p_legislation_code  in varchar2 )
RETURN number IS
--
cursor csr_user_entity_id is
    select  user_entity_id
      from  ff_user_entities
     where  user_entity_name = p_user_entity_name
       and  nvl(legislation_code,hr_api.g_varchar2) = nvl(p_legislation_code,hr_api.g_varchar2)
       and  business_group_id is null;
--
l_proc     varchar2(72) := g_package||'get_user_entity_id';
l_user_entity_id   FF_USER_ENTITIES.USER_ENTITY_ID%TYPE;
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_user_entity_name is not null then
        open csr_user_entity_id;
        fetch csr_user_entity_id into l_user_entity_id;
        close csr_user_entity_id;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 30);

  return l_user_entity_id;
--
END get_user_entity_id;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_formula_id >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure derives the formula id  from its true key -
-- formula name, formula_type, legislation code and business group.
-- It returns null if the formula does not exist.
-- This procedure cannot be used to get the formula_id of formulas
-- belonging to any business group.
--
-- ----------------------------------------------------------------------------
FUNCTION get_formula_id
               ( p_formula_type_name  in varchar2
                ,p_formula_name       in varchar2
                ,p_legislation_code   in varchar2 )
RETURN number IS
--
cursor csr_formula_id is
    select  distinct ff.formula_id
      from  ff_formulas_f ff
           ,ff_formula_types ft
     where  ff.formula_name = p_formula_name
       and  nvl(ff.legislation_code,hr_api.g_varchar2) = nvl(p_legislation_code,hr_api.g_varchar2)
       and  ft.formula_type_name = p_formula_type_name
       and  ft.formula_type_id   = ff.formula_type_id
       and  ff.business_group_id is null;
--
l_formula_id   FF_FORMULAS_F.FORMULA_ID%TYPE;
l_proc         varchar2(72) := g_package||'get_formula_id';
--
BEGIN
--
       hr_utility.set_location('Entering:'||l_proc, 5);

       if p_formula_type_name is not null and p_formula_name is not null then

              open csr_formula_id;
              fetch csr_formula_id into l_formula_id;

              if csr_formula_id%ROWCOUNT > 1 then

                    close csr_formula_id;

                    fnd_message.set_name( 'PAY' , 'PAY_33255_INV_SKEY' );
                    fnd_message.set_token( 'SURROGATE_ID' , 'FORMULA_ID' );
                    fnd_message.set_token( 'ENTITY' , 'FORMULA' );
                    fnd_message.raise_error ;

              end if;
              close csr_formula_id;
       else
       l_formula_id := -9999;

       end if;

       hr_utility.set_location(' Leaving:'||l_proc, 30);

       return l_formula_id;
--
END get_formula_id;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< load_rfm_row >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure uploads a single row into pay_report_format_mappings_f
-- table. When the first row of a date tracked record is being uploaded
-- it checks if the record already exists in the table. If the record already
-- exists then all the rows of this record are deleted first and then the
-- first row is inserted. All the subsequent rows are uploaded by updating
-- the first row.
--
-- ----------------------------------------------------------------------------
PROCEDURE load_rfm_row
               ( p_report_type                in varchar2
                ,p_report_qualifier           in varchar2
                ,p_report_category            in varchar2
                ,p_effective_start_date       in date
                ,p_effective_end_date         in date
                ,p_legislation_code           in varchar2
                ,p_business_group_name        in varchar2
                ,p_range_code                 in varchar2
                ,p_assignment_action_code     in varchar2
                ,p_initialization_code        in varchar2
                ,p_archive_code               in varchar2
                ,p_magnetic_code              in varchar2
                ,p_report_format              in varchar2
                ,p_report_name                in varchar2
                ,p_sort_code                  in varchar2
                ,p_updatable_flag             in varchar2
                ,p_deinitialization_code      in varchar2
                ,p_temporary_action_flag      in varchar2
                ,p_display_name               in varchar2
                ,p_owner                      in varchar2
                ,p_eof                        in number   ) IS
--
l_proc     varchar2(72) := g_package||'load_rfm_row';
l_business_group_id  PAY_REPORT_FORMAT_MAPPINGS_F.BUSINESS_GROUP_ID%TYPE;
l_rec                PAY_RFM_SHD.G_REC_TYPE;
l_report_format_mapping_id PAY_REPORT_FORMAT_MAPPINGS_F.REPORT_FORMAT_MAPPING_ID%TYPE;
l_exists             varchar2 (1);
--
cursor csr_exists is
       select null
          from pay_report_format_mappings_f
          where report_type = p_report_type
          and   report_qualifier = p_report_qualifier
          and   report_category  = p_report_category;
--
        PROCEDURE set_end_date IS
        --
        cursor csr_rfi_exists is
          select min(rfi.effective_start_date), max(rfi.effective_end_date)
            from  pay_report_format_items_f rfi
            where rfi.report_type = g_rfm_old_rec.report_type
            and   rfi.report_qualifier = g_rfm_old_rec.report_qualifier
            and   rfi.report_category = g_rfm_old_rec.report_category;
        --
        cursor csr_rfi_ids (p_effective_date date) is
          select rfi.report_format_item_id, rfi.object_version_number
            from  pay_report_format_items_f rfi
            where rfi.report_type = g_rfm_old_rec.report_type
            and   rfi.report_qualifier = g_rfm_old_rec.report_qualifier
            and   rfi.report_category = g_rfm_old_rec.report_category
            and   p_effective_date between
                  rfi.effective_start_date and rfi.effective_end_date ;
        --
        l_proc                 varchar2(72) := g_package||'load_rfm_row.set_end_date';
        l_effective_start_date date;
        l_effective_end_date   date;
        l_rfi_esd              date;
        l_rfi_eed              date;
        --
        BEGIN
        --
              hr_utility.set_location('Entering:'||l_proc, 5);

              open csr_rfi_exists ;
              fetch csr_rfi_exists into l_rfi_esd, l_rfi_eed;

              if csr_rfi_exists%found then

                  if g_rfm_effective_end_date < l_rfi_eed then

                      FOR l_rfi_id in csr_rfi_ids(p_effective_date => g_rfm_effective_end_date) LOOP

                          pay_rfi_del.del
                                 ( p_effective_date          => g_rfm_effective_end_date
                                  ,p_datetrack_mode          => 'DELETE'
                                  ,p_report_format_item_id   => l_rfi_id.report_format_item_id
                                  ,p_object_version_number   => l_rfi_id.object_version_number
                                  ,p_effective_start_date    => l_effective_start_date
                                  ,p_effective_end_date      => l_effective_end_date  );

                      END LOOP;

                  end if;

              end if;

              close csr_rfi_exists;

              enable_startup_mode
                    ( p_business_group_id =>  g_rfm_old_rec.business_group_id
                     ,p_legislation_code  =>  g_rfm_old_rec.legislation_code );

              pay_rfm_del.del
                      ( p_effective_date            =>  g_rfm_effective_end_date
                       ,p_datetrack_mode            =>  'DELETE'
                       ,p_report_format_mapping_id  =>  g_rfm_old_rec.report_format_mapping_id
                       ,p_object_version_number     =>  g_rfm_old_rec.object_version_number
                       ,p_effective_start_date      =>  l_effective_start_date
                       ,p_effective_end_date        =>  l_effective_end_date
                      );

              hr_utility.set_location(' Leaving:'||l_proc, 10);
        --
        END set_end_date;
--
BEGIN
--
      hr_utility.set_location('Entering:'||l_proc, 5);

      -- Derive the Business Group Id from Name.

      l_business_group_id := get_business_group_id
                                 (p_business_group_name => p_business_group_name);

      l_rec := pay_rfm_shd.convert_args
                        ( p_report_type              =>  p_report_type
                         ,p_report_qualifier         =>  p_report_qualifier
                         ,p_report_format            =>  p_report_format
                         ,p_effective_start_date     =>  null
                         ,p_effective_end_date       =>  null
                         ,p_range_code               =>  p_range_code
                         ,p_assignment_action_code   =>  p_assignment_action_code
                         ,p_initialization_code      =>  p_initialization_code
                         ,p_archive_code             =>  p_archive_code
                         ,p_magnetic_code            =>  p_magnetic_code
                         ,p_report_category          =>  p_report_category
                         ,p_report_name              =>  p_report_name
                         ,p_sort_code                =>  p_sort_code
                         ,p_updatable_flag           =>  p_updatable_flag
                         ,p_deinitialization_code    =>  p_deinitialization_code
                         ,p_report_format_mapping_id =>  null
                         ,p_business_group_id        =>  l_business_group_id
                         ,p_legislation_code         =>  p_legislation_code
                         ,p_temporary_action_flag    =>  p_temporary_action_flag
                         ,p_object_version_number    =>  null
                        );

      enable_startup_mode
               ( p_business_group_id =>  l_business_group_id
                ,p_legislation_code  =>  p_legislation_code );

      init_fndload
               ( p_owner  => p_owner );

      if p_eof = 1 then

              if l_rec.report_type <> nvl(g_rfm_old_rec.report_type,hr_api.g_varchar2) or
                    l_rec.report_qualifier <> nvl(g_rfm_old_rec.report_qualifier,hr_api.g_varchar2) or
                       l_rec.report_category <> nvl(g_rfm_old_rec.report_category,hr_api.g_varchar2) then

                      -- A new record is being uploaded.

                      -- End Date the previous record if necessary.

                      if g_rfm_effective_end_date <> hr_api.g_eot then

                             set_end_date;

                      end if;

                      -- Reset the startup mode again in case the startup mode was changed by set_end_date

                      enable_startup_mode
                            ( p_business_group_id =>  l_business_group_id
                             ,p_legislation_code  =>  p_legislation_code );

                      g_rfm_effective_end_date := p_effective_end_date;

                      l_report_format_mapping_id :=
                               pay_rfm_shd.get_report_format_mapping_id
                                     ( p_report_type      => p_report_type
                                      ,p_report_qualifier => p_report_qualifier
                                      ,p_report_category  => p_report_category
                                     );

                      open csr_exists;
                      fetch csr_exists into l_exists;

                      if csr_exists%found then

                             -- Can't do an api delete as child rows may exist.

                             delete from pay_report_format_mappings_f
                             where  report_format_mapping_id = l_report_format_mapping_id;

                             delete from pay_report_format_mappings_tl rfmtl
                             where  rfmtl.report_format_mapping_id = l_report_format_mapping_id
                             and    exists
                                    ( select null
                                          from  fnd_languages l
                                          where l.installed_flag in ('I','B')
                                          and   l.language_code = rfmtl.language );

                             pay_rfm_ins.set_base_key_value
                                    ( p_report_format_mapping_id => l_report_format_mapping_id );

                             pay_rfm_ins.ins
                                    ( p_effective_date  => p_effective_start_date
                                     ,p_rec             => l_rec );

                             pay_rft_ins.ins_tl
                                    ( p_language_code             => userenv('LANG')
                                     ,p_report_format_mapping_id  => l_report_format_mapping_id
                                     ,p_display_name              => p_display_name );

                             g_rfm_old_rec := l_rec;
                      else

                             pay_rfm_ins.ins
                                    ( p_effective_date  => p_effective_start_date
                                     ,p_rec             => l_rec );

                             pay_rft_ins.ins_tl
                                    ( p_language_code             => userenv('LANG')
                                     ,p_report_format_mapping_id  => l_rec.report_format_mapping_id
                                     ,p_display_name              => p_display_name );

                             g_rfm_old_rec := l_rec;
                      end if;

                      close csr_exists;
              else

                      -- Update the row
                      g_rfm_effective_end_date := p_effective_end_date;

                      l_rec.report_format_mapping_id  :=  g_rfm_old_rec.report_format_mapping_id;
                      l_rec.object_version_number     :=  g_rfm_old_rec.object_version_number;

                      pay_rfm_upd.upd
                             ( p_effective_date  => p_effective_start_date
                              ,p_datetrack_mode  => 'UPDATE'
                              ,p_rec             => l_rec );

                      pay_rft_upd.upd_tl
                             ( p_language_code  => userenv('LANG')
                              ,p_report_format_mapping_id  => l_rec.report_format_mapping_id
                              ,p_display_name   => p_display_name );


                      g_rfm_old_rec := l_rec;

              end if;

      elsif p_eof = 2 then

              if g_rfm_effective_end_date <> hr_api.g_eot then

                      set_end_date;

              end if;

      end if;

      hr_utility.set_location(' Leaving:'||l_proc, 10);
--
END load_rfm_row;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< translate_rfm_row >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure updates the translation table pay_report_format_mappings_tl.
-- It only updates the translations in the TL table for the current language
-- (if present). This procedure does not insert or update the base table
-- nor updates any language other than the current one.
-- This procedure is usually called from the loader in 'NLS' mode to upload
-- translations.
--
-- ----------------------------------------------------------------------------
PROCEDURE  translate_rfm_row
               ( p_report_type                in varchar2
                ,p_report_qualifier           in varchar2
                ,p_report_category            in varchar2
                ,p_display_name               in varchar2 ) IS
--
l_proc     varchar2(72) := g_package||'translate_rfm_row';
l_report_format_mapping_id  PAY_REPORT_FORMAT_MAPPINGS_F.REPORT_FORMAT_MAPPING_ID%TYPE;
--
BEGIN
--
        hr_utility.set_location('Entering:'||l_proc, 5);

        l_report_format_mapping_id :=
                    pay_rfm_shd.get_report_format_mapping_id
                              ( p_report_type      => p_report_type
                               ,p_report_qualifier => p_report_qualifier
                               ,p_report_category  => p_report_category );

        pay_rft_upd.upd_tl
          ( p_language_code  => userenv('LANG')
           ,p_report_format_mapping_id  => l_report_format_mapping_id
           ,p_display_name   => p_display_name );

        hr_utility.set_location(' Leaving:'||l_proc, 30);
--
END translate_rfm_row;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< load_rfi_row >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure uploads a single row into pay_report_format_items_f
-- table. When the first row of a date tracked record is being uploaded
-- it checks if the record already exists in the table. If the record already
-- exists then all the rows of this record are deleted first and then the
-- first row is inserted. All the subsequent rows are uploaded by updating
-- the first row.
--
-- ----------------------------------------------------------------------------
PROCEDURE load_rfi_row
               ( p_report_type                in varchar2
                ,p_report_qualifier           in varchar2
                ,p_report_category            in varchar2
                ,p_user_entity_name           in varchar2
                ,p_legislation_code           in varchar2
                ,p_effective_start_date       in date
                ,p_effective_end_date         in date
                ,p_archive_type               in varchar2
                ,p_updatable_flag             in varchar2
                ,p_display_sequence           in number
                ,p_owner                      in varchar2
                ,p_eof                        in number   ) IS
--
l_proc               varchar2(72) := g_package||'load_rfi_row';
l_rec                PAY_RFI_SHD.G_REC_TYPE;
l_exists             varchar2 (1);
l_user_entity_id     PAY_REPORT_FORMAT_ITEMS_F.USER_ENTITY_ID%TYPE;
l_report_format_mapping_id  PAY_REPORT_FORMAT_MAPPINGS_F.REPORT_FORMAT_MAPPING_ID%TYPE;
l_report_format_item_id     PAY_REPORT_FORMAT_ITEMS_F.REPORT_FORMAT_ITEM_ID%TYPE;
--
cursor csr_exists is
       select null
          from pay_report_format_items_f
          where report_type = p_report_type
          and   report_qualifier = p_report_qualifier
          and   report_category  = p_report_category
          and   user_entity_id = l_user_entity_id;
--
        PROCEDURE set_end_date IS
        --
        l_proc                 varchar2(72) := g_package||'load_rfi_row.set_end_date';
        l_effective_start_date date;
        l_effective_end_date   date;
        --
        BEGIN
        --
              hr_utility.set_location('Entering:'||l_proc, 5);

              pay_rfi_del.del
                     ( p_effective_date            =>  g_rfi_effective_end_date
                      ,p_datetrack_mode            =>  'DELETE'
                      ,p_report_format_item_id     =>  g_rfi_old_rec.report_format_item_id
                      ,p_object_version_number     =>  g_rfi_old_rec.object_version_number
                      ,p_effective_start_date      =>  l_effective_start_date
                      ,p_effective_end_date        =>  l_effective_end_date
                     );

              hr_utility.set_location(' Leaving:'||l_proc, 30);
        --
        END set_end_date;
--
BEGIN
--
      hr_utility.set_location('Entering:'||l_proc, 5);

      l_user_entity_id :=  get_user_entity_id
                               ( p_user_entity_name => p_user_entity_name
                                ,p_legislation_code => p_legislation_code );

      l_report_format_mapping_id :=
                      pay_rfm_shd.get_report_format_mapping_id
                                      ( p_report_type      => p_report_type
                                       ,p_report_qualifier => p_report_qualifier
                                       ,p_report_category  => p_report_category );


      l_rec := pay_rfi_shd.convert_args
                        ( p_report_type              =>  p_report_type
                         ,p_report_qualifier         =>  p_report_qualifier
                         ,p_report_category          =>  p_report_category
                         ,p_user_entity_id           =>  l_user_entity_id
                         ,p_effective_start_date     =>  null
                         ,p_effective_end_date       =>  null
                         ,p_archive_type             =>  p_archive_type
                         ,p_updatable_flag           =>  p_updatable_flag
                         ,p_display_sequence         =>  p_display_sequence
                         ,p_object_version_number    =>  null
                         ,p_report_format_item_id    =>  null
                         ,p_report_format_mapping_id =>  l_report_format_mapping_id );

      init_fndload
               ( p_owner  => p_owner );

      if p_eof = 1 then

              if l_rec.report_type <> nvl(g_rfi_old_rec.report_type,hr_api.g_varchar2) or
                    l_rec.report_qualifier <> nvl(g_rfi_old_rec.report_qualifier,hr_api.g_varchar2) or
                       l_rec.report_category <> nvl(g_rfi_old_rec.report_category,hr_api.g_varchar2) or
                          l_rec.user_entity_id <> nvl(g_rfi_old_rec.user_entity_id,hr_api.g_number) then

                      -- It is a new record that is being uploaded.

                      -- End Date the previous record if necessary.

                      if g_rfi_effective_end_date <> g_rfi_old_rec.effective_end_date then

                             set_end_date;

                      end if;

                      g_rfi_effective_end_date := p_effective_end_date;

                      l_report_format_item_id :=
                               pay_rfi_shd.get_report_format_item_id
                                     ( p_report_type      => p_report_type
                                      ,p_report_qualifier => p_report_qualifier
                                      ,p_report_category  => p_report_category
                                      ,p_user_entity_id   => l_user_entity_id
                                     );


                      open csr_exists;
                      fetch csr_exists into l_exists;

                      if csr_exists%found then

                             -- Can't do an api delete as child rows may exist.

                             delete from pay_report_format_items_f
                             where  report_format_item_id = l_report_format_item_id;

                             pay_rfi_ins.set_base_key_value
                                    ( p_report_format_item_id  => l_report_format_item_id );

                             pay_rfi_ins.ins
                                    ( p_effective_date  => p_effective_start_date
                                     ,p_rec             => l_rec );

                             g_rfi_old_rec := l_rec;
                      else
                             pay_rfi_ins.ins
                                    ( p_effective_date  => p_effective_start_date
                                     ,p_rec             => l_rec );

                             g_rfi_old_rec := l_rec;
                      end if;

                      close csr_exists;
              else

                      -- Update the row
                      g_rfi_effective_end_date := p_effective_end_date;

                      l_rec.report_format_item_id  :=  g_rfi_old_rec.report_format_item_id;
                      l_rec.object_version_number  :=  g_rfi_old_rec.object_version_number;

                      pay_rfi_upd.upd
                             ( p_effective_date  => p_effective_start_date
                              ,p_datetrack_mode  => 'UPDATE'
                              ,p_rec             => l_rec );

                      g_rfi_old_rec := l_rec;

              end if;

      elsif p_eof = 2 then

              if g_rfi_effective_end_date <> g_rfi_old_rec.effective_end_date then

                      set_end_date;

              end if;

      end if;

      hr_utility.set_location(' Leaving:'||l_proc, 30);
--
END load_rfi_row;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< load_rfp_row >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure uploads a single row into pay_report_format_parameters
-- table. If the row being uploaded already exists in the table then the
-- row is only updated with the new values else the row is inserted.
--
-- ----------------------------------------------------------------------------
PROCEDURE load_rfp_row
               ( p_report_type                in varchar2
                ,p_report_qualifier           in varchar2
                ,p_report_category            in varchar2
                ,p_parameter_name             in varchar2
                ,p_parameter_value            in varchar2
                ,p_owner                      in varchar2 ) IS
--
l_proc                      varchar2(72) := g_package||'load_rfp_row';
l_rec                       PAY_RFP_SHD.G_REC_TYPE;
l_object_version_number     PAY_REPORT_FORMAT_PARAMETERS.OBJECT_VERSION_NUMBER%TYPE;
l_report_format_mapping_id  PAY_REPORT_FORMAT_PARAMETERS.REPORT_FORMAT_MAPPING_ID%TYPE;
--
cursor csr_exists is
       select object_version_number
          from pay_report_format_parameters
          where report_format_mapping_id = l_report_format_mapping_id
          and   parameter_name = p_parameter_name;
--
BEGIN
--

        hr_utility.set_location('Entering:'||l_proc, 5);

        l_report_format_mapping_id :=
                    pay_rfm_shd.get_report_format_mapping_id
                              ( p_report_type      => p_report_type
                               ,p_report_qualifier => p_report_qualifier
                               ,p_report_category  => p_report_category
                              );

        l_rec := pay_rfp_shd.convert_args
                          ( p_report_format_mapping_id   => l_report_format_mapping_id
                           ,p_parameter_name             => p_parameter_name
                           ,p_parameter_value            => p_parameter_value
                           ,p_object_version_number      => null
                          );

        init_fndload
               ( p_owner  => p_owner );

        open csr_exists;
        fetch csr_exists into l_object_version_number;

        if csr_exists%notfound then

                pay_rfp_ins.ins
                       ( p_rec   => l_rec );

        else

                l_rec.object_version_number := l_object_version_number;

                pay_rfp_upd.upd
                       ( p_rec   => l_rec );

        end if;

        close csr_exists;

        hr_utility.set_location(' Leaving:'||l_proc, 30);

--
END load_rfp_row;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< load_mgb_row >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure uploads a single row into pay_magnetic_blocks
-- table. If the row being uploaded already exists in the table then the
-- row is only updated with the new values else the row is inserted.
--
-- ----------------------------------------------------------------------------
PROCEDURE load_mgb_row
               ( p_block_name                 in varchar2
                ,p_report_format              in varchar2
                ,p_main_block_flag            in varchar2
                ,p_cursor_name                in varchar2
                ,p_no_column_returned         in number ) IS
--
l_proc                      varchar2(72) := g_package||'load_mgb_row';
l_rec                       PAY_MGB_SHD.G_REC_TYPE;
l_exists                    varchar2 (1);
l_magnetic_block_id         PAY_MAGNETIC_BLOCKS.MAGNETIC_BLOCK_ID%TYPE;
--
cursor csr_exists is
        select null
          from pay_magnetic_blocks
         where magnetic_block_id = l_magnetic_block_id;

--
BEGIN
--
        hr_utility.set_location('Entering:'||l_proc, 5);

        l_magnetic_block_id :=
                    pay_mgb_shd.get_magnetic_block_id
                              ( p_block_name       => p_block_name
                               ,p_report_format    => p_report_format
                              );

        l_rec := pay_mgb_shd.convert_args
                          ( p_magnetic_block_id    => null
                           ,p_block_name           => p_block_name
                           ,p_main_block_flag      => p_main_block_flag
                           ,p_report_format        => p_report_format
                           ,p_cursor_name          => p_cursor_name
                           ,p_no_column_returned   => p_no_column_returned
                          );

        open csr_exists;
        fetch csr_exists into l_exists;

        if csr_exists%notfound then

                pay_mgb_ins.ins
                       ( p_rec   => l_rec );

        else

                l_rec.magnetic_block_id := l_magnetic_block_id;

                pay_mgb_upd.upd
                       ( p_rec   => l_rec );

        end if;

        close csr_exists;

        hr_utility.set_location(' Leaving:'||l_proc, 30);

--
END load_mgb_row;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< load_mgr_row >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure uploads a single row into pay_magnetic_records
-- table. If the row being uploaded already exists in the table then the
-- row is only updated with the new values else the row is inserted.
--
-- ----------------------------------------------------------------------------
PROCEDURE load_mgr_row
               ( p_block_name                 in varchar2
                ,p_report_format              in varchar2
                ,p_sequence                   in number
                ,p_formula_type_name          in varchar2
                ,p_formula_name               in varchar2
                ,p_legislation_code           in varchar2
                ,p_next_block_name            in varchar2
                ,p_next_report_format         in varchar2
                ,p_overflow_mode              in varchar2
                ,p_frequency                  in number
                ,p_last_run_executed_mode     in varchar2
                ,p_action_level               in varchar2 default null
                ,p_block_label                in varchar2 default null
                ,p_block_row_label            in varchar2 default null
                ,p_xml_proc_name              in varchar2 default null ) IS
--
l_proc                      varchar2(72) := g_package||'load_mgr_row';
l_rec                       PAY_MGR_SHD.G_REC_TYPE;
l_exists                    varchar2 (1);
l_magnetic_block_id         PAY_MAGNETIC_RECORDS.MAGNETIC_BLOCK_ID%TYPE;
l_next_block_id             PAY_MAGNETIC_RECORDS.NEXT_BLOCK_ID%TYPE;
l_formula_id                PAY_MAGNETIC_RECORDS.FORMULA_ID%TYPE;
--
cursor csr_exists is
        select null
          from pay_magnetic_records
         where magnetic_block_id = l_magnetic_block_id
           and sequence = p_sequence;

--
BEGIN
--

        hr_utility.set_location('Entering:'||l_proc, 5);

        l_magnetic_block_id :=
                    pay_mgb_shd.get_magnetic_block_id
                              ( p_block_name       => p_block_name
                               ,p_report_format    => p_report_format
                              );

        l_next_block_id :=
                    pay_mgb_shd.get_magnetic_block_id
                              ( p_block_name       => p_next_block_name
                               ,p_report_format    => p_next_report_format
                              );

        l_formula_id := get_formula_id
                              ( p_formula_type_name => p_formula_type_name
                               ,p_formula_name      => p_formula_name
                               ,p_legislation_code  => p_legislation_code
                              );


        l_rec := pay_mgr_shd.convert_args
                          ( p_formula_id               =>  l_formula_id
                           ,p_magnetic_block_id        =>  l_magnetic_block_id
                           ,p_next_block_id            =>  l_next_block_id
                           ,p_last_run_executed_mode   =>  p_last_run_executed_mode
                           ,p_overflow_mode            =>  p_overflow_mode
                           ,p_sequence                 =>  p_sequence
                           ,p_frequency                =>  p_frequency
			   ,p_action_level             =>  p_action_level
			   ,p_block_label	       =>  p_block_label
			   ,p_block_row_label          =>  p_block_row_label
			   ,p_xml_proc_name	       =>  p_xml_proc_name
                          );

        open csr_exists;
        fetch csr_exists into l_exists;

        if csr_exists%notfound then

                pay_mgr_ins.ins
                       ( p_rec   => l_rec );

        else

                pay_mgr_upd.upd
                       ( p_rec   => l_rec );

        end if;

        close csr_exists;

        hr_utility.set_location(' Leaving:'||l_proc, 30);

--
END load_mgr_row;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< load_egu_row >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure uploads a single row into pay_event_group_usages
-- table if the row being uploaded is not already present in the table.
--
-- ----------------------------------------------------------------------------
PROCEDURE load_egu_row
            ( p_evg_name          in  varchar2
             ,p_evg_leg_code      in  varchar2
             ,p_evg_bus_grp_name  in  varchar2
             ,p_els_name          in  varchar2
             ,p_els_leg_code      in  varchar2
             ,p_els_bus_grp_name  in  varchar2
             ,p_egu_leg_code      in  varchar2
             ,p_egu_bus_grp_name  in  varchar2
             ,p_owner             in  varchar2 ) IS
--
l_proc                      varchar2(72) := g_package||'load_egu_row';
l_exists                    varchar2 (1);
l_event_group_id            pay_event_groups.event_group_id%type;
l_element_set_id            pay_element_sets.element_set_id%type;
l_business_group_id         pay_event_group_usages.business_group_id%type;
l_legislation_code          pay_event_group_usages.legislation_code%type;
l_evg_bus_group_id          pay_event_groups.business_group_id%type;
l_els_bus_group_id          pay_element_sets.business_group_id%type;
l_event_group_usage_id      pay_event_group_usages.event_group_usage_id%type;
l_ovn                       pay_event_group_usages.object_version_number%type;
--
cursor csr_exists is
select  null
from    pay_event_group_usages egu
where   egu.event_group_id = l_event_group_id
and     egu.element_set_id = l_element_set_id
and ( l_business_group_id is null
        or ( l_business_group_id is not null and l_business_group_id = egu.business_group_id )
        or ( l_business_group_id is not null and
                egu.legislation_code is null and egu.business_group_id is null )
        or ( l_business_group_id is not null and
                egu.legislation_code = hr_api.return_legislation_code(l_business_group_id )))
and ( l_legislation_code is null
        or ( l_legislation_code is not null and l_legislation_code = egu.legislation_code )
        or ( l_legislation_code is not null and
                egu.legislation_code is null and egu.business_group_id is null)
        or ( l_legislation_code is not null and
                l_legislation_code = hr_api.return_legislation_code(egu.business_group_id )));
--
BEGIN
--

        hr_utility.set_location('Entering:'||l_proc, 5);

        l_business_group_id := get_business_group_id
                                 (p_business_group_name => p_egu_bus_grp_name);

        l_legislation_code := p_egu_leg_code;

        l_evg_bus_group_id := get_business_group_id
                                 (p_business_group_name => p_evg_bus_grp_name);

        l_els_bus_group_id := get_business_group_id
                                 (p_business_group_name => p_els_bus_grp_name);


        l_element_set_id := get_element_set_id
                                 ( p_element_set_name  => p_els_name,
                                   p_legislation_code  => p_els_leg_code,
                                   p_business_group_id => l_els_bus_group_id);

        l_event_group_id := get_event_group_id
                                 ( p_event_group_name  => p_evg_name,
                                   p_legislation_code  => p_evg_leg_code,
                                   p_business_group_id => l_evg_bus_group_id);


        open csr_exists;
        fetch csr_exists into l_exists;

        if csr_exists%notfound then

            enable_startup_mode
                    ( p_business_group_id =>  l_business_group_id
                     ,p_legislation_code  =>  l_legislation_code );

            init_fndload
               ( p_owner  => p_owner );

            pay_egu_ins.ins
               (p_effective_date         =>  sysdate
               ,p_event_group_id         =>  l_event_group_id
               ,p_element_set_id         =>  l_element_set_id
               ,p_business_group_id      =>  l_business_group_id
               ,p_legislation_code       =>  l_legislation_code
               ,p_event_group_usage_id   =>  l_event_group_usage_id
               ,p_object_version_number  =>  l_ovn
               );

        end if;

        close csr_exists;

        hr_utility.set_location(' Leaving:'||l_proc, 30);

--
END load_egu_row;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< load_ecu_row >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure uploads a single row into pay_element_class_usages_f table.
--
-- ----------------------------------------------------------------------------
PROCEDURE load_ecu_row(
		p_usage_id			in	number,
		p_rt_name			in	varchar2,
		p_rt_effective_start_date	in	date,
		p_rt_effective_end_date		in	date,
		p_rt_business_group_name	in	varchar2,
		p_rt_legislation_code		in	varchar2,
		p_rt_shortname			in	varchar2,
		p_ec_classification_name	in	varchar2,
		p_ec_business_group_name	in	varchar2,
		p_ec_legislation_code		in	varchar2,
                p_effective_start_date		in	date,
                p_effective_end_date		in	date,
                p_business_group_name		in	varchar2,
                p_legislation_code		in	varchar2,
		p_owner				in	varchar2,
                p_eof_number			in	number
                ) is
--
l_proc     varchar2(72) := g_package||'load_ecu_row';
l_business_group_id  PAY_ELEMENT_CLASS_USAGES_F.BUSINESS_GROUP_ID%TYPE;
l_rec                PAY_ECU_SHD.G_REC_TYPE;
l_element_class_usage_id PAY_ELEMENT_CLASS_USAGES_F.ELEMENT_CLASS_USAGE_ID%TYPE;
l_run_type_id		PAY_ELEMENT_CLASS_USAGES_F.RUN_TYPE_ID%TYPE;
l_classification_id     PAY_ELEMENT_CLASS_USAGES_F.CLASSIFICATION_ID%TYPE;
l_object_version_number PAY_ELEMENT_CLASS_USAGES_F.OBJECT_VERSION_NUMBER%TYPE;
--
-- Cursor for fetching the run type id.
   Cursor csr_get_rt_id is
     select prt.run_type_id
     from   pay_run_types_f prt
     where  UPPER(prt.run_type_name) = UPPER(p_rt_name)
     and    p_effective_start_date between prt.effective_start_date
                                   and     prt.effective_end_date
     and    ((p_rt_business_group_name is not null
     and    prt.business_group_id = l_business_group_id)
     or     (p_rt_legislation_code is not null
     and    prt.legislation_code = p_rt_legislation_code)
     or     (p_rt_business_group_name is null
     and    p_rt_legislation_code is null
     and    prt.business_group_id is null
     and    prt.legislation_code is null));

   -- Cursor for fetching the classification id.
   Cursor csr_get_ec_id is
     select pec.classification_id
     from   pay_element_classifications pec
     where  UPPER(pec.classification_name) = UPPER(p_ec_classification_name)
     and    ((p_ec_business_group_name is not null
     and    pec.business_group_id = l_business_group_id)
     or     (p_ec_legislation_code is not null
     and    pec.legislation_code = p_ec_legislation_code)
     or     (p_ec_business_group_name is null
     and    p_ec_legislation_code is null
     and    pec.business_group_id is null
     and    pec.legislation_code is null));

   -- Cursor for cheking the rows exists or not.
   Cursor csr_exists is
     select element_class_usage_id, object_version_number
     from   pay_element_class_usages_f
     where  run_type_id	   = l_run_type_id
     and    classification_id  = l_classification_id
     and    NVL(business_group_id, hr_api.g_number)  = NVL(l_business_group_id, hr_api.g_number)
     and    NVL(legislation_code, hr_api.g_varchar2) = NVL(p_legislation_code, hr_api.g_varchar2)
     and    p_effective_start_date between effective_start_date and effective_end_date;
--
        PROCEDURE set_end_date IS
        --
        l_proc                 varchar2(72) := g_package||'load_ecu_row.set_end_date';
        l_effective_start_date date;
        l_effective_end_date   date;
        --
        BEGIN
        --
              hr_utility.set_location('Entering:'||l_proc, 5);

              enable_startup_mode
                    ( p_business_group_id =>  g_ecu_old_rec.business_group_id
                     ,p_legislation_code  =>  g_ecu_old_rec.legislation_code );

              PAY_ECU_DEL.DEL
			(p_effective_date         => g_ecu_effective_end_date
			,p_datetrack_mode         => 'DELETE'
			,p_element_class_usage_id => g_ecu_old_rec.element_class_usage_id
			,p_object_version_number  => g_ecu_old_rec.object_version_number
			,p_effective_start_date   => l_effective_start_date
			,p_effective_end_date     => l_effective_end_date);
	      hr_utility.set_location(' Leaving:'||l_proc, 10);
        --
        END set_end_date;
--
BEGIN
--
      hr_utility.set_location('Entering:'||l_proc, 5);

      -- Derive the Business Group Id from Name.

      l_business_group_id :=	NULL;
      if (p_business_group_name is not null) then
	l_business_group_id := get_business_group_id
                                 (p_business_group_name => p_business_group_name);
      end if;

      -- Get the run_type_id
      --
      open csr_get_rt_id;
      fetch csr_get_rt_id into l_run_type_id;
      close csr_get_rt_id;
      --
      -- Get the classification_id
      --
      open csr_get_ec_id;
      fetch csr_get_ec_id into l_classification_id;
      close csr_get_ec_id;

      l_rec := pay_ecu_shd.convert_args
                        (p_element_class_usage_id         => null
			,p_effective_start_date           => null
			,p_effective_end_date             => null
			,p_run_type_id                    => l_run_type_id
			,p_classification_id              => l_classification_id
			,p_business_group_id              => l_business_group_id
			,p_legislation_code               => p_legislation_code
			,p_object_version_number          => null);

      enable_startup_mode
               ( p_business_group_id =>  l_business_group_id
                ,p_legislation_code  =>  p_legislation_code );

      init_fndload
               ( p_owner  => p_owner );
      if p_eof_number = 1 then

              if (g_usage_id <> p_usage_id) then

                      -- A new record is being uploaded.

                      -- End Date the previous record if necessary.
		      if g_ecu_effective_end_date <> hr_api.g_eot then
		      --
                             set_end_date;
                      --
                      end if;
		      -- Reset the startup mode again in case the startup mode was changed by set_end_date
                      enable_startup_mode
                            ( p_business_group_id =>  l_business_group_id
                             ,p_legislation_code  =>  p_legislation_code );

                      g_ecu_effective_end_date := p_effective_end_date;

		      open csr_exists;
                      fetch csr_exists into l_element_class_usage_id, l_object_version_number;
		      if csr_exists%found then
		      --
			l_rec.element_class_usage_id := l_element_class_usage_id;
			l_rec.object_version_number  := l_object_version_number;

			PAY_ECU_DEL.DEL(
			 p_effective_date        => p_effective_start_date
			,p_datetrack_mode        => 'ZAP'
			,p_rec			 => l_rec);

			PAY_ECU_INS.INS(
			 p_effective_date          => p_effective_start_date
			,p_rec			 => l_rec);

			g_ecu_old_rec := l_rec;
                      --
		      else
		      --
                        PAY_ECU_INS.INS(
			 p_effective_date          => p_effective_start_date
			,p_rec			 => l_rec);

                        g_ecu_old_rec := l_rec;
		      --
                      end if;
                      close csr_exists;
              else

                      -- Update the row
                      g_ecu_effective_end_date := p_effective_end_date;

                      l_rec.element_class_usage_id  :=  g_ecu_old_rec.element_class_usage_id;
                      l_rec.object_version_number   :=  g_ecu_old_rec.object_version_number;

                      pay_ecu_upd.upd
                             ( p_effective_date  => p_effective_start_date
                              ,p_datetrack_mode  => 'UPDATE'
                              ,p_rec             => l_rec );

                      g_ecu_old_rec := l_rec;

              end if;
	      g_usage_id := p_usage_id;

      elsif p_eof_number = 2 then

              if g_ecu_effective_end_date <> hr_api.g_eot then
	      --
                      set_end_date;
              --
              end if;
	      g_usage_id := -1;
      end if;

      hr_utility.set_location(' Leaving:'||l_proc, 10);
--
END load_ecu_row;
--
END PAY_LOADER_UTILS_PKG;


/
