--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_DESIGN_TXNS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_DESIGN_TXNS_API" as
/* $Header: becetapi.pkb 120.5.12010000.4 2016/09/27 10:12:43 pnagared ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  BEN_PLAN_DESIGN_TXN_APIS.';
g_debug    boolean      := hr_utility.debug_enabled;

--
-- Private procedure to update the cer with target details
--
procedure update_cer_with_target(p_copy_entity_txn_id number)
is
  l_counter number;
begin
  l_counter := nvl(ben_pd_copy_to_ben_one.g_pk_tbl.LAST, 0);
  if l_counter > 0 then
    for i in 1..l_counter loop
      update ben_copy_entity_results
      set information9     = ben_pd_copy_to_ben_one.g_pk_tbl(i).copy_reuse_type||'-'||ben_pd_copy_to_ben_one.g_pk_tbl(i).new_value
      where copy_entity_txn_id = p_copy_entity_txn_id
      and   table_route_id     = ben_pd_copy_to_ben_one.g_pk_tbl(i).table_route_id
      and   nvl(information1,-999) = nvl(ben_pd_copy_to_ben_one.g_pk_tbl(i).old_value,-999) ;
    end loop;
  end if;

  /* Using FORALL gives compilation error -
  ** Cannot reference fields of BULK In-BIND table of records
  */

  /*
  forall i in ben_pd_copy_to_ben_one.g_pk_tbl.FIRST..ben_pd_copy_to_ben_one.g_pk_tbl.LAST
    update ben_copy_entity_results
    set information9     = ben_pd_copy_to_ben_one.g_pk_tbl(i).copy_reuse_type||'-'||ben_pd_copy_to_ben_one.g_pk_tbl(i).new_value
    where copy_entity_txn_id = p_copy_entity_txn_id
    and   table_route_id     = ben_pd_copy_to_ben_one.g_pk_tbl(i).table_route_id
    and   information1       = ben_pd_copy_to_ben_one.g_pk_tbl(i).old_value ;
  */

end update_cer_with_target ;

--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PLAN_DESIGN_TXN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PLAN_DESIGN_TXN
  (
   p_validate                       in number     default 0 -- false
  ,p_copy_entity_txn_id             out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_txn_category_attribute_id      in  number    default null
  ,p_context_business_group_id      in  number    default null
  ,p_datetrack_mode                 in  varchar2    default null
  ,p_proc_typ_cd                    in  varchar2  default null -- Transaction category Short Name
  ,p_action_date                    in  date      default null
  ,p_src_effective_date             in  date      default null
  ,p_number_of_copies               in  number    default null
  ,p_process_name                   in  varchar2  default null
  ,p_replacement_type_cd            in  varchar2  default null
  ,p_sfl_step_name                  in  varchar2    default null
  ,p_increment_by                   in  number    default null
  ,p_status                         in  varchar2  default null
  ,p_cet_object_version_number      out nocopy number
  ,p_effective_date                 in  date
  ,p_copy_entity_attrib_id          out nocopy number
  ,p_row_type_cd                    in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_prefix_suffix_text             in  varchar2  default null
  ,p_export_file_name               in  varchar2  default null
  ,p_target_typ_cd                  in  varchar2  default null
  ,p_reuse_object_flag              in  varchar2  default null
  ,p_target_business_group_id       in  varchar2  default null
  ,p_search_by_cd1                  in  varchar2  default null
  ,p_search_value1                  in  varchar2  default null
  ,p_search_by_cd2                  in  varchar2  default null
  ,p_search_value2                  in  varchar2  default null
  ,p_search_by_cd3                  in  varchar2  default null
  ,p_search_value3                  in  varchar2  default null
  ,p_prefix_suffix_cd               in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_cea_object_version_number      out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_copy_entity_txn_id        pqh_copy_entity_txns.copy_entity_txn_id%TYPE;
  l_copy_entity_attrib_id     pqh_copy_entity_attribs.copy_entity_attrib_id%TYPE;
  l_proc varchar2(72) :=      g_package||'create_PLAN_DESIGN_TXN';
  l_object_version_number     pqh_copy_entity_txns.object_version_number%TYPE;
  l_cetobject_version_number  pqh_copy_entity_txns.object_version_number%TYPE;

  --
  cursor txn_cat_c is
   select transaction_category_id
   from pqh_transaction_categories
   where short_name = p_proc_typ_cd ;
  --
  l_transaction_category_id pqh_transaction_categories.transaction_category_id%type;
  --
  cursor c_db is
  --select name from v$database ;
  select sys_context('userenv','db_name') from dual;  --Bug 23759209 Changes
  --
  l_db_name         varchar2(30);
  --
  cursor c_bg(v_bg_id number) is
  select name from per_business_groups
  where business_group_id = v_bg_id ;
  --
  l_context_bg_name per_business_groups.name%type;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PLAN_DESIGN_TXN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  fnd_msg_pub.initialize;
  --

  -- Get the context Database Name
  begin
    open c_db ;
      fetch c_db into l_db_name ;
    close c_db ;
  exception when others then
    null ;
  end ;
  --
  begin
    --
    --l_context_bg_name := fnd_global.PER_BUSINESS_GROUP_ID ;
    open c_bg(p_context_business_group_id) ;
      fetch c_bg into l_context_bg_name ;
    close c_bg ;
    --
  exception when others then
    null ;
  end ;
  -- Need to create a row into pqh_transaction_category(tct) table
  --
  hr_utility.set_location('Before PQH_COPY_ENTITY_TXNS_APIS.create_COPY_ENTITY_TXN ', 60);

  --
  open txn_cat_c;
  fetch txn_cat_c into l_transaction_category_id;
  close txn_cat_c;
  --
  hr_utility.set_location('l_transaction_category_id '||l_transaction_category_id, 60);
  --
  PQH_COPY_ENTITY_TXNS_API.create_COPY_ENTITY_TXN
   (
     p_validate                       => false
    , p_copy_entity_txn_id            => l_copy_entity_txn_id
    ,p_transaction_category_id       => l_transaction_category_id
    ,p_txn_category_attribute_id     => p_txn_category_attribute_id -- 999 what are these values.
    ,p_context_business_group_id     => p_context_business_group_id
    -- ,p_datetrack_mode                => p_datetrack_mode
    ,p_context                       => 'BEN_PDWIZ'
    ,p_action_date                   => p_action_date
    ,p_src_effective_date            => p_src_effective_date
    ,p_number_of_copies              => p_number_of_copies
    ,p_display_name                  => p_process_name
    ,p_replacement_type_cd           => p_replacement_type_cd
    ,p_start_with                    => p_sfl_step_name
    ,p_increment_by                  => p_increment_by
    ,p_status                        => p_status
    ,p_object_version_number         => l_cetobject_version_number
    ,p_effective_date                => trunc(p_effective_date)
   );
  --
  hr_utility.set_location('After PQH_COPY_ENTITY_TXNS_APIS.create_COPY_ENTITY_TXN ', 60);


  --
  -- Set all output arguments
  --
  p_copy_entity_txn_id := l_copy_entity_txn_id;
  p_cet_object_version_number := l_cetobject_version_number;
  --
  pqh_copy_entity_attribs_api.create_copy_entity_attrib
  (
     p_validate                       => false
    ,p_copy_entity_attrib_id          => l_copy_entity_attrib_id
    ,p_copy_entity_txn_id             => p_copy_entity_txn_id
    ,p_row_type_cd                    => p_row_type_cd
    ,p_information_category           => p_information_category
    ,p_information1                   => p_prefix_suffix_text
    ,p_information2                   => p_export_file_name
    ,p_information3                   => p_target_typ_cd
    ,p_information4                   => p_reuse_object_flag
    ,p_information5                   => p_target_business_group_id
    ,p_information6                   => p_search_by_cd1
    ,p_information7                   => p_search_value1
    ,p_information8                   => p_search_by_cd2
    ,p_information9                   => p_search_value2
    ,p_information10                  => p_search_by_cd3
    ,p_information11                  => p_search_value3
    ,p_information12                  => p_prefix_suffix_cd
    ,p_information13                  => p_information13
    ,p_information14                  => p_information14
    ,p_information15                  => p_information15
    ,p_information16                  => p_information16
    ,p_information17                  => p_information17
    ,p_information18                  => p_information18
    ,p_information19                  => p_information19
    ,p_information20                  => p_information20
    ,p_information21                  => p_information21
    ,p_information22                  => p_information22
    ,p_information23                  => p_information23
    ,p_information24                  => p_information24
    ,p_information25                  => p_information25
    ,p_information26                  => p_information26
    ,p_information27                  => p_information27
    ,p_information28                  => p_information28
    ,p_information29                  => l_db_name         -- p_information29
    ,p_information30                  => l_context_bg_name -- p_information30
    ,p_object_version_number          => l_object_version_number
    ,p_effective_date                 => p_effective_date
   );

  --
  -- Set all output arguments
  --
  p_copy_entity_attrib_id := l_copy_entity_attrib_id;
  p_cea_object_version_number := l_object_version_number;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate  = 1 then
    raise hr_API.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_API.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_PLAN_DESIGN_TXN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_copy_entity_txn_id := null;
    p_cea_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    hr_utility.set_location(' hr_API.validate_enabled:'||l_proc, 80);
    --
  when app_exception.application_exception then
    p_copy_entity_txn_id := null;
    p_cea_object_version_number  := null;

    fnd_msg_pub.add;
    hr_utility.set_location(' app_exception.application_exception:'||l_proc, 80);

    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PLAN_DESIGN_TXN;
    p_copy_entity_txn_id := null;
    p_cea_object_version_number  := null;

    hr_utility.set_location(' when others:'||l_proc, 80);
    raise;
    --
end create_PLAN_DESIGN_TXN;

-- ----------------------------------------------------------------------------
-- |------------------------< update_PLAN_DESIGN_TXN >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PLAN_DESIGN_TXN
  (p_validate                       in  number    default 0 --boolean   default false
  ,p_copy_entity_txn_id             in  number
  ,p_transaction_category_id        in  number    default hr_API.g_number
  ,p_txn_category_attribute_id      in  number    default hr_API.g_number
  ,p_context_business_group_id      in  number    default hr_api.g_number
  ,p_datetrack_mode                 in  varchar2  default hr_api.g_varchar2
  ,p_proc_typ_cd                    in  varchar2  default hr_API.g_varchar2
  ,p_action_date                    in  date      default hr_API.g_date
  ,p_src_effective_date             in  date      default hr_API.g_date
  ,p_number_of_copies               in  number    default hr_API.g_number
  ,p_process_name                   in  varchar2  default hr_API.g_varchar2
  ,p_replacement_type_cd            in  varchar2  default hr_API.g_varchar2
  ,p_sfl_step_name                  in  varchar2  default hr_API.g_varchar2
  ,p_increment_by                   in  number    default hr_API.g_number
  ,p_status                         in  varchar2  default hr_API.g_varchar2
  ,p_cet_object_version_number      in  out nocopy number
  ,p_effective_date                 in  date
  ,p_copy_entity_attrib_id          in  number
  ,p_row_type_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_prefix_suffix_text             in  varchar2  default hr_api.g_varchar2
  ,p_export_file_name               in  varchar2  default hr_api.g_varchar2
  ,p_target_typ_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_reuse_object_flag              in  varchar2  default hr_api.g_varchar2
  ,p_target_business_group_id       in  varchar2  default hr_api.g_varchar2
  ,p_search_by_cd1                  in  varchar2  default hr_api.g_varchar2
  ,p_search_value1                  in  varchar2  default hr_api.g_varchar2
  ,p_search_by_cd2                  in  varchar2  default hr_api.g_varchar2
  ,p_search_value2                  in  varchar2  default hr_api.g_varchar2
  ,p_search_by_cd3                  in  varchar2  default hr_api.g_varchar2
  ,p_search_value3                  in  varchar2  default hr_api.g_varchar2
  ,p_prefix_suffix_cd               in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_upd_record_type                in  varchar2  default null
  ,p_cea_object_version_number      in  out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PLAN_DESIGN_TXN';
  l_object_version_number pqh_copy_entity_txns.object_version_number%TYPE;
  l_cet_object_version_number pqh_copy_entity_txns.object_version_number%TYPE;
  l_cea_object_version_number pqh_copy_entity_txns.object_version_number%TYPE;
  --
  cursor chk_trgt_bgid(p_copy_entity_txn_id number,
                       p_target_business_group_id varchar2,
                       p_copy_entity_attrib_id number) is
  select information5
  from pqh_copy_entity_attribs
  where copy_entity_attrib_id = p_copy_entity_attrib_id
    -- and information5 <> p_target_business_group_id
    and copy_entity_txn_id = p_copy_entity_txn_id ;
  --
  cursor c_unmapped_rows is
    select unique table_route_id
    from ben_copy_entity_results
    where copy_entity_txn_id = p_copy_entity_txn_id
    -- Only take unmapped rows.
    and (information176 is null or
         (information180 is not null and information176 is null));
  --
  cursor c_leg is
    select bg.legislation_code
    from   per_business_groups bg
    where  bg.business_group_id = p_target_business_group_id; -- 9999
  --
  l_legislation_code  varchar2(150);
  --
  cursor c_pln_tr is
  select table_route_id
  from pqh_table_route tr
  where tr.table_alias = 'PLN' and where_clause = 'BEN_PL_F' ;
  --
  l_table_route_id    number ;
  l_ret varchar2(1000);
  --
  l_ben_start_date                DATE;
  l_icx_date_format_mask          VARCHAR2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PLAN_DESIGN_TXN;
  --
  fnd_msg_pub.initialize;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Bug 3001617
  -- This is the benchmark date for Benefits object to start, particularly
  -- because all of BEN delivered lookups start from 01-Jan-1951
  --
  l_ben_start_date := to_date('01-01-1951', 'DD-MM-YYYY');
  --
  if p_action_date <> hr_api.g_date and
     p_action_date < l_ben_start_date
  then
    --
    fnd_profile.get( NAME => 'ICX_DATE_FORMAT_MASK'
                    ,VAL  => l_icx_date_format_mask );
    --
    fnd_message.set_name('BEN', 'BEN_94216_EFF_DATE_INCORRECT');
    fnd_message.set_token('DATE', to_char(l_ben_start_date, l_icx_date_format_mask));
    fnd_message.raise_error;
    --
  end if;
  --
  -- Bug 3001617
  --
  -- Process Logic
  --
  l_cet_object_version_number := p_cet_object_version_number;
  --
  if p_upd_record_type in  ('CET', 'CET_CEA')
  then
    --
    pqh_copy_entity_txns_api.update_COPY_ENTITY_TXN
    (
     p_copy_entity_txn_id            => p_copy_entity_txn_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_txn_category_attribute_id     => p_txn_category_attribute_id
    ,p_context_business_group_id     => p_context_business_group_id
    ,p_datetrack_mode                => p_datetrack_mode
    -- ,p_context                       => p_proc_typ_cd
    ,p_action_date                   => p_action_date
    ,p_src_effective_date            => p_src_effective_date
    ,p_number_of_copies              => p_number_of_copies
    ,p_display_name                  => p_process_name
    ,p_replacement_type_cd           => p_replacement_type_cd
    ,p_start_with                    => p_sfl_step_name
    ,p_increment_by                  => p_increment_by
    ,p_status                        => p_status
    ,p_object_version_number         => l_cet_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
    --
  end if;
  --
  hr_utility.set_location(l_proc, 60);
  --
  l_cea_object_version_number := p_cea_object_version_number;
  --
  if p_upd_record_type in  ('CEA', 'CET_CEA')
  then
    --
    open chk_trgt_bgid(p_copy_entity_txn_id,p_target_business_group_id,p_copy_entity_attrib_id);
    fetch  chk_trgt_bgid into  l_ret;
    --
    if ((chk_trgt_bgid%found  and
         l_ret <> p_target_business_group_id)
        or ( p_target_typ_cd = 'BEN_PDFILE')) then
       --
       open c_pln_tr ;
       fetch c_pln_tr into l_table_route_id ;
       close c_pln_tr ;
       --
       /* No need to update all the rows
       update ben_copy_entity_results
       set information175 = null,
           information176 = null,
           information179 = null,
           information180 = null
       where copy_entity_txn_id = p_copy_entity_txn_id
       and table_route_id <> l_table_route_id ; */
       --
       update ben_copy_entity_results
       set information175 = null,
           information176 = null,
           information179 = null,
           information180 = null
       where copy_entity_txn_id = p_copy_entity_txn_id
       and (information175 is not null
            or information176 is not null
            or information179 is not null
            or information180 is not null)
       and table_route_id <> l_table_route_id ;
    end if;
    --
    close chk_trgt_bgid;
    --

    pqh_copy_entity_attribs_api.update_copy_entity_attrib
    (p_copy_entity_attrib_id          => p_copy_entity_attrib_id
    ,p_copy_entity_txn_id             => p_copy_entity_txn_id
    ,p_row_type_cd                    => p_row_type_cd
    ,p_information_category           => p_information_category
    ,p_information1                   => p_prefix_suffix_text
    ,p_information2                   => p_export_file_name
    ,p_information3                   => p_target_typ_cd
    ,p_information4                   => p_reuse_object_flag
    ,p_information5                   => p_target_business_group_id
    ,p_information6                   => p_search_by_cd1
    ,p_information7                   => p_search_value1
    ,p_information8                   => p_search_by_cd2
    ,p_information9                   => p_search_value2
    ,p_information10                  => p_search_by_cd3
    ,p_information11                  => p_search_value3
    ,p_information12                  => p_prefix_suffix_cd
    ,p_information13                  => p_information13
    ,p_information14                  => p_information14
    ,p_information15                  => p_information15
    ,p_information16                  => p_information16
    ,p_information17                  => p_information17
    ,p_information18                  => p_information18
    ,p_information19                  => p_information19
    ,p_information20                  => p_information20
    ,p_information21                  => p_information21
    ,p_information22                  => p_information22
    ,p_information23                  => p_information23
    ,p_information24                  => p_information24
    ,p_information25                  => p_information25
    ,p_information26                  => p_information26
    ,p_information27                  => p_information27
    ,p_information28                  => p_information28
    ,p_information29                  => p_information29
    ,p_information30                  => p_information30
    ,p_object_version_number          => l_cea_object_version_number
    ,p_effective_date                 => p_effective_date
   );
    --
    -- Support automapping without user intervention
    -- as part of target details selection page
    --
    if   (( p_target_typ_cd in ('BEN_PDDFBG','BEN_PDIMPT')) and
         (p_sfl_step_name = 'BEN_PDC_TRGT_DTL_PAGE')
        )
    then
       --
       -- call automapping code
       --
       open c_leg;
         fetch c_leg into l_legislation_code;
       close c_leg;
       --
       for l_rec in c_unmapped_rows loop
           --
           auto_mapping(
             p_copy_entity_txn_id              => p_copy_entity_txn_id
             ,p_table_route_id                 => l_rec.table_route_id
             ,p_table_route_id2                => null
             ,p_legislation_code               => l_legislation_code
             ,p_target_business_group_id       => p_target_business_group_id
             ,p_effective_date                 => p_src_effective_date
             ,p_effective_date_to_copy         => p_action_date
           );
           --
       end loop;
    end if;
    --
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate  = 1 then  -- check what is 0
    raise hr_API.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_cet_object_version_number := l_cet_object_version_number;
  p_cea_object_version_number := l_cea_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_API.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_PLAN_DESIGN_TXN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when app_exception.application_exception then

    fnd_msg_pub.add;
    hr_utility.set_location(' app_exception.application_exception:'||l_proc, 80);

    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_PLAN_DESIGN_TXN;
    p_cea_object_version_number  := l_object_version_number ;
    raise;
    --
end update_PLAN_DESIGN_TXN;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PLAN_DESIGN_TXN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PLAN_DESIGN_TXN
  (p_validate                       in   number        default 0 --  default false
  ,p_copy_entity_txn_id             in  number
  ,p_cet_object_version_number      in  number
  ,p_effective_date                 in  date
  ,p_retain_log                         in varchar2 default 'N'         -- Bug No 4281567
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_PLAN_DESIGN_TXN';
  l_object_version_number pqh_copy_entity_txns.object_version_number%TYPE;
  --
  cursor c_copy_entity_attrib is
  select copy_entity_attrib_id,cea_object_version_number
  from ben_copy_entity_txns_vw
  where copy_entity_txn_id = p_copy_entity_txn_id;
  --
  cursor c_cer is
    select cer.*
    from ben_copy_entity_results cer
    where COPY_ENTITY_TXN_ID = p_COPY_ENTITY_TXN_ID;
  --
  l_copy_entity_attrib_id pqh_copy_entity_attribs.copy_entity_attrib_id%TYPE;
  l_cea_object_version_number pqh_copy_entity_attribs.object_version_number%TYPE;
  l_cer_object_version_number pqh_copy_entity_attribs.object_version_number%TYPE;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  pqh_cet_bus.chk_completed_target_err ( p_copy_entity_txn_id );
  --
  savepoint delete_PLAN_DESIGN_TXN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_cet_object_version_number;
  --
     BEN_PLAN_DESIGN_TXNS_API.delete_plan_design_result
    ( p_validate                    => p_validate
     ,p_copy_entity_txn_id          => p_copy_entity_txn_id
     ,p_effective_date              => p_effective_date
     );
   --
   -- Bug No 4281567 Check retain log, if 'Y', then retain the log, header and attribs record
   --
   if p_retain_log = 'N' then
     --
     open c_copy_entity_attrib;
     fetch c_copy_entity_attrib
     into l_copy_entity_attrib_id,l_cea_object_version_number;
     close c_copy_entity_attrib;
     --
     PQH_COPY_ENTITY_ATTRIBS_api.delete_COPY_ENTITY_ATTRIB
      (p_validate                      => false
       ,p_copy_entity_attrib_id         => l_copy_entity_attrib_id
       ,p_object_version_number         => l_cea_object_version_number
       ,p_effective_date                => p_effective_date
      );
   --
   -- Delete Log records
      delete from pqh_process_log
         where txn_id = p_copy_entity_txn_id
            and module_cd = 'PDC_CP';

       PQH_COPY_ENTITY_TXNS_api.delete_COPY_ENTITY_TXN
       (p_validate                      => false
       ,p_copy_entity_txn_id            => p_copy_entity_txn_id
       ,p_object_version_number         => l_object_version_number
       ,p_effective_date                => p_effective_date
       );
       hr_utility.set_location(l_proc, 40);
   --
   else
   --
   -- Update the records in PQH_COPY_ENTITY_TXNS table with status as 'Purged'
   --
       PQH_COPY_ENTITY_TXNS_api.update_COPY_ENTITY_TXN
       (p_validate                             => false
       ,p_datetrack_mode                => hr_api.g_correction
       ,p_copy_entity_txn_id           => p_copy_entity_txn_id
       ,p_start_with                         => null
       ,p_status                                => 'PURGED'
       ,p_object_version_number     => l_object_version_number
       ,p_effective_date                  => sysdate
       );
       hr_utility.set_location(l_proc, 50);
   end if;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate = 1 then
    raise hr_API.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_API.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_PLAN_DESIGN_TXN;
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
    ROLLBACK TO delete_PLAN_DESIGN_TXN;
    raise;
    --
end delete_PLAN_DESIGN_TXN;
--
procedure create_plan_design_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in date
  ,p_no_dup_rslt                    in varchar2   default null
  )
is
  l_proc varchar2(72) :=      g_package||'create_plan_design_result';
begin
  hr_utility.set_location(' Entering :'||l_proc, 10);

  if p_pgm_id is not null then
    -- Call the Program routine
    ben_plan_design_program_module.create_program_result
       ( p_validate                   => p_validate
        ,p_copy_entity_result_id      => p_copy_entity_result_id
        ,p_copy_entity_txn_id         => p_copy_entity_txn_id
        ,p_pgm_id                     => p_pgm_id
        ,p_business_group_id          => p_business_group_id
        ,p_number_of_copies           => p_number_of_copies
        ,p_object_version_number      => p_object_version_number
        ,p_effective_date             => p_effective_date
        ,p_no_dup_rslt                => p_no_dup_rslt
       ) ;
    --
  elsif p_pl_id is not null then
    -- Call the Plan routine
    ben_plan_design_plan_module.create_plan_result
       ( p_validate                  => p_validate
        ,p_copy_entity_result_id     => p_copy_entity_result_id
        ,p_copy_entity_txn_id        => p_copy_entity_txn_id
        ,p_pl_id                     => p_pl_id
        ,p_plip_id                   => null
        ,p_business_group_id         => p_business_group_id
        ,p_number_of_copies           => p_number_of_copies
        ,p_object_version_number     => p_object_version_number
        ,p_effective_date            => p_effective_date
        ,p_no_dup_rslt               => p_no_dup_rslt
       );
    --
  else
    -- don't do anything
   return;
    --
  end if;

  -- Create all Action Types for the Business Group
  if p_number_of_copies = 1 then

    ben_plan_design_program_module.create_actn_typ_result
    (
      p_validate                     => p_validate
     ,p_copy_entity_txn_id           => p_copy_entity_txn_id
     ,p_business_group_id            => p_business_group_id
     ,p_number_of_copies             => p_number_of_copies
     ,p_effective_date               => p_effective_date
    );
  end if;

  --
  --
  hr_utility.set_location(' Leaving :'||l_proc, 10);
end create_plan_design_result;
--
-- Overloaded create_plan_design_result for Plan Design Wizard
-- This has been overloaded to allow copying Plans to staging area
-- without setting information8 to PLNIP
--
procedure create_plan_design_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in date
  ,p_no_dup_rslt                    in varchar2   default null
  ,p_plan_in_program                in varchar2
  )
is
  l_proc varchar2(72) :=      g_package||'create_plan_design_result';
  l_copy_entity_result_id number;
  l_object_version_number number;
begin
  hr_utility.set_location(' Entering :'||l_proc, 10);
  --
  create_plan_design_result
  (
   p_validate                       => p_validate
  ,p_copy_entity_result_id          => l_copy_entity_result_id
  ,p_copy_entity_txn_id             => p_copy_entity_txn_id
  ,p_pl_id                          => p_pl_id
  ,p_pgm_id                         => p_pgm_id
  ,p_business_group_id              => p_business_group_id
  ,p_number_of_copies               => p_number_of_copies
  ,p_object_version_number          => l_object_version_number
  ,p_effective_date                 => p_effective_date
  ,p_no_dup_rslt                    => p_no_dup_rslt
  );
  --
  if p_pl_id is not null and p_plan_in_program = 'Y' then
    update ben_copy_entity_results
    set information8 = NULL
    where information1 = p_pl_id
    and copy_entity_txn_id = p_copy_entity_txn_id
    and table_alias = 'PLN';
  end if;

  -- Set out variables
  p_copy_entity_result_id := l_copy_entity_result_id;
  p_object_version_number := l_object_version_number;

  hr_utility.set_location(' Leaving :'||l_proc, 10);
end create_plan_design_result;
--

procedure update_child_object_selection(
                                p_mirror_entity_result_id  in number
                               ,p_copy_entity_txn_id       in number
                               ,p_number_of_copies         in number ) is

   cursor c_child_object is
   select  /*+ INDEX ( cer, ben_copy_entity_results_fk1) */
           cer.copy_entity_result_id
          ,cer.mirror_entity_result_id
   from   ben_copy_entity_results cer
   where  cer.mirror_src_entity_result_id = p_mirror_entity_result_id
   and    cer.copy_entity_txn_id = p_copy_entity_txn_id;

begin
   for l_child_object_rec in c_child_object
   loop

       update ben_copy_entity_results
       set number_of_copies = p_number_of_copies
       where copy_entity_result_id =  l_child_object_rec.copy_entity_result_id;

       update_child_object_selection(
           p_mirror_entity_result_id => l_child_object_rec.mirror_entity_result_id
          ,p_copy_entity_txn_id      => p_copy_entity_txn_id
          ,p_number_of_copies        => p_number_of_copies);

   end loop;
   --
end update_child_object_selection;
--

procedure update_hgrid_child_selection(
                                p_copy_entity_result_id    in number
                               ,p_mirror_entity_result_id  in number
                               ,p_copy_entity_txn_id       in number
                               ,p_number_of_copies         in number
                               ,p_table_route_id           in number) is

   cursor c_table_name is
   select where_clause
   from   pqh_table_route
   where  table_route_id = p_table_route_id;

   l_table_name pqh_table_route.where_clause%type;
begin

   open c_table_name;
   fetch c_table_name into l_table_name;
   close c_table_name;

   if  l_table_name = 'BEN_PLIP_F' then
     if p_number_of_copies in (0,2) then -- If Plip is de-selected update Plip and child records

       update ben_copy_entity_results
       set number_of_copies = p_number_of_copies
       where copy_entity_result_id =  p_copy_entity_result_id;

       update_child_object_selection(
         p_mirror_entity_result_id => p_mirror_entity_result_id
        ,p_copy_entity_txn_id      => p_copy_entity_txn_id
        ,p_number_of_copies        => p_number_of_copies);

     else  --Plip can be selected only if Program is selected
       null;
     end if;
   end if;

   if l_table_name <> 'BEN_PLIP_F' then

         update_child_object_selection(
           p_mirror_entity_result_id => p_mirror_entity_result_id
          ,p_copy_entity_txn_id      => p_copy_entity_txn_id
          ,p_number_of_copies        => p_number_of_copies);

   end if;
   --
end update_hgrid_child_selection;
--

procedure update_plan_design_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          in number
  ,p_copy_entity_txn_id             in number
  ,p_business_group_id              in number    default hr_api.g_number
  ,p_number_of_copies               in number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_information1                   in varchar2  default hr_api.g_varchar2
  ,p_information8                   in varchar2  default hr_api.g_varchar2
  ,p_information175                 in varchar2  default hr_api.g_varchar2
  ,p_information176                 in varchar2  default hr_api.g_varchar2
  ,p_information177                 in varchar2  default hr_api.g_varchar2
  ,p_information178                 in varchar2  default hr_api.g_varchar2
  ,p_information179                 in varchar2  default hr_api.g_varchar2
  ,p_information180                 in varchar2  default hr_api.g_varchar2
  ,p_called_from                    in varchar2  default hr_api.g_varchar2
  ,p_mirror_entity_result_id        in number    default hr_api.g_number
  ) is
  l_number_of_copies        number(15);
  l_proc varchar2(72) :=      g_package||'update_plan_design_result';
  l_copy_entity_result_id   number(15);
  l_object_version_number   number(15);
  l_pgm_id                  number(15) default null;
  l_pl_id                   number(15) default null;
  --
  cursor c_child_exists_for_pgm(c_pgm_id varchar2,c_copy_entity_txn_id number ) is
  select null
  from  ben_copy_entity_results cer,
         pqh_table_route trt
  where  cer.information1 = c_pgm_id
   and   cer.copy_entity_txn_id = c_copy_entity_txn_id
   and   cer.table_route_id = trt.table_route_id
   and   trt.where_clause = 'BEN_PGM_F'
   and   trt.from_clause  = 'OAB'
   and exists ( select /*+ INDEX ( cer1, ben_copy_entity_results_fk1) */ null
                from
                ben_copy_entity_results cer1
                where cer1.mirror_src_entity_result_id = cer.copy_entity_result_id
                and cer1.copy_entity_txn_id = cer.copy_entity_txn_id ) ;
   --
   cursor c_child_exists_for_pl(c_pl_id varchar2,c_copy_entity_txn_id number ) is
   select null
   from  ben_copy_entity_results cer,
         pqh_table_route trt
   where cer.information1 = c_pl_id
   and   cer.copy_entity_txn_id = c_copy_entity_txn_id
   and   cer.table_route_id = trt.table_route_id
   and   trt.where_clause = 'BEN_PL_F'
   and   trt.from_clause  = 'OAB'
   and exists ( select /*+ INDEX ( cer1, ben_copy_entity_results_fk1) */ null from
                ben_copy_entity_results cer1
                where cer1.mirror_src_entity_result_id = cer.copy_entity_result_id
                and cer1.copy_entity_txn_id = cer.copy_entity_txn_id ) ;

  l_dummy           varchar2(30) ;
  l_child_exists    boolean default false;

  cursor c_object_version_number(c_copy_entity_result_id in number) is
  select cer.object_version_number
  from ben_copy_entity_results cer
  where cer.copy_entity_result_id = c_copy_entity_result_id;

  l_cer_object_version_number number(15);

  cursor c_non_dsply_recs(c_information1 in varchar2,
                          c_table_name   in varchar2,
                          c_copy_entity_txn_id in number) is
  select cer.copy_entity_result_id,cer.object_version_number
  from ben_copy_entity_results cer,
       pqh_table_route trt
  where cer.information1 = c_information1
  and   trt.where_clause = c_table_name
  and   cer.copy_entity_txn_id = c_copy_entity_txn_id
  and   cer.table_route_id = trt.table_route_id
  and   cer.result_type_cd <> 'DISPLAY' ;

  l_table_name pqh_table_route.where_clause%type;

begin
  --
  hr_utility.set_location(' Entering :'||l_proc, 10);
  l_number_of_copies := p_number_of_copies ;
  --

  if p_called_from = 'HGRID' then
    open c_object_version_number(p_copy_entity_result_id);
    fetch c_object_version_number into l_cer_object_version_number;
    close c_object_version_number;
  else
    l_cer_object_version_number  := p_object_version_number;
  end if;

  ben_copy_entity_results_api.update_copy_entity_results
      ( p_validate                    => false
       ,p_copy_entity_result_id       => p_copy_entity_result_id
       ,p_copy_entity_txn_id          => p_copy_entity_txn_id
       ,p_number_of_copies            => l_number_of_copies
       ,p_object_version_number       => l_cer_object_version_number
       ,p_effective_date              => p_effective_date
       ,p_information323             => null
      );
  hr_utility.set_location(' Leaving :'||l_proc, 10);
  --

  -- Update number_of_copies for Non Displayed
  -- Top level (Program or Plan )records
    if p_information8 is not null then -- Top level record
      if p_information8 = 'PGM' then
        l_table_name := 'BEN_PGM_F';
      else
        l_table_name := 'BEN_PL_F';
      end if;

      for r_non_dsply_recs in c_non_dsply_recs
                              (p_information1,
                               l_table_name,
                               p_copy_entity_txn_id)
      loop
        ben_copy_entity_results_api.update_copy_entity_results
         ( p_validate                    => false
          ,p_copy_entity_result_id       => r_non_dsply_recs.copy_entity_result_id
          ,p_copy_entity_txn_id          => p_copy_entity_txn_id
          ,p_number_of_copies            => l_number_of_copies
          ,p_object_version_number       => r_non_dsply_recs.object_version_number
          ,p_effective_date              => p_effective_date
          ,p_information323              => null
         );
      end loop;
    end if;

    if p_called_from = 'SELECTION' then

      if l_number_of_copies = 1 then
      --
        if p_information8 = 'PGM' then
        --
          l_pgm_id := p_information1;
          open c_child_exists_for_pgm(p_information1,p_copy_entity_txn_id )   ;
          fetch c_child_exists_for_pgm into l_dummy ;
          if c_child_exists_for_pgm%found then
             l_child_exists := true;
          end if;
          close c_child_exists_for_pgm ;
        --
        else
        --
          l_pl_id  := p_information1;
          open c_child_exists_for_pl(p_information1,p_copy_entity_txn_id )   ;
          fetch c_child_exists_for_pl into l_dummy ;
          if c_child_exists_for_pl%found then
             l_child_exists := true;
          end if;
          close c_child_exists_for_pl;
        --
        end if;
        --
        if not l_child_exists then
          create_plan_design_result
          (
            p_validate                  => p_validate
           ,p_copy_entity_result_id     => l_copy_entity_result_id
           ,p_copy_entity_txn_id        => p_copy_entity_txn_id
           ,p_pl_id                     => l_pl_id
           ,p_pgm_id                    => l_pgm_id
           ,p_business_group_id         => p_business_group_id
           ,p_number_of_copies          => p_number_of_copies
           ,p_object_version_number     => l_object_version_number
           ,p_effective_date            => p_effective_date
          );
        else
          update_child_object_selection(
           p_mirror_entity_result_id => p_mirror_entity_result_id
          ,p_copy_entity_txn_id      => p_copy_entity_txn_id
          ,p_number_of_copies        => p_number_of_copies);
        end if;

      else     -- number_of_copies = 0

        update_child_object_selection(
           p_mirror_entity_result_id => p_mirror_entity_result_id
          ,p_copy_entity_txn_id      => p_copy_entity_txn_id
          ,p_number_of_copies        => p_number_of_copies);

      end if;
    end if;
    --
    --
    -- Set all output arguments
    --
    p_object_version_number := l_cer_object_version_number;
    --

end update_plan_design_result ;
--
procedure delete_plan_design_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_effective_date                 in date
  ) is
  l_proc varchar2(72) :=      g_package||'delete_plan_design_result';
  --
  cursor c_cpe(c_copy_entity_txn_id number) is
    select copy_entity_result_id,
           object_version_number
    from   ben_copy_entity_results cpe
    where  cpe.copy_entity_txn_id = c_copy_entity_txn_id;


  cursor c_cer(c_copy_entity_txn_id number) is
    select copy_entity_result_id,
           object_version_number
    from   pqh_copy_entity_results cer
    where  cer.copy_entity_txn_id = c_copy_entity_txn_id;
    --
    --
begin
  hr_utility.set_location(' Entering :'||l_proc, 10);
  --

  --
  -- delete from pqh_copy_entity_results
  --
  for l_cer in c_cer(p_copy_entity_txn_id) loop
    --
    pqh_copy_entity_results_api.delete_copy_entity_result
      (p_validate                  => false
      ,p_copy_entity_result_id     => l_cer.copy_entity_result_id
      ,p_object_version_number     => l_cer.object_version_number
      ,p_effective_date            => p_effective_date
      ) ;
    --
  end loop ;
  --

  --
  -- delete from ben_copy_entity_results
  --
  for l_cpe in c_cpe(p_copy_entity_txn_id) loop
    --
    ben_copy_entity_results_api.delete_copy_entity_results
      (p_validate                  => false
      ,p_copy_entity_result_id     => l_cpe.copy_entity_result_id
      ,p_object_version_number     => l_cpe.object_version_number
      ,p_effective_date            => p_effective_date
      ) ;
    --
  end loop ;

  hr_utility.set_location(' Leaving :'||l_proc, 10);
  --
end delete_plan_design_result;
--
procedure get_effective_dates(
   p_process_effective_date         in date
  ,p_start_date1                    in date default null
  ,p_start_date2                    in date default null
  ,p_effective_date_to_copy         in date default null
  ,p_effective_date1                out nocopy date
  ,p_effective_date2                out nocopy date
) is
  l_out_effective_date1 date;
  l_out_effective_date2 date;
begin

 -- Default Effective_Date to Process Effective Date
 l_out_effective_date1 := p_process_effective_date;
 l_out_effective_date2 := p_process_effective_date;

 -- If Object Start Dates in the source instance are available
 -- then Set Effective_Date = Object Start Date
 if p_start_date1 is not null then
   l_out_effective_date1 := p_start_date1;
 end if;

 if p_start_date2 is not null then
   l_out_effective_date2 := p_start_date2;
 end if;

 -- If  Effective Date to Copy is entered and is
 -- greater than the Object Start Dates, then
 -- set Effective_Date = Effective Date to Copy

 if p_effective_date_to_copy is not null then

   if p_effective_date_to_copy > l_out_effective_date1 then
     l_out_effective_date1 := p_effective_date_to_copy;
   end if;

   if p_effective_date_to_copy > l_out_effective_date2 then
     l_out_effective_date2 := p_effective_date_to_copy;
   end if;

 end if;

   -- Set out variables
   p_effective_date1 := l_out_effective_date1;
   p_effective_date2 := l_out_effective_date2;

end get_effective_dates;
--
procedure auto_mapping(
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_txn_id             in number
  ,p_table_route_id                 in number
  ,p_table_route_id2                in number
  ,p_legislation_code               in varchar2
  ,p_target_business_group_id       in number       default hr_api.g_number
  ,p_effective_date                 in date          default null
  ,p_effective_date_to_copy         in date          default null
) is
  l_proc varchar2(72) :=      g_package||'auto_mapping';
  --
    cursor c_source_data(p_table_route_id  number) is
    select information173,
       information174,
       information175,
       information176,
       information177,
       information178,
       information179,
       information180,
       information166,
       information306
    from ben_copy_entity_results
    where table_route_id = p_table_route_id
    and copy_entity_txn_id = p_copy_entity_txn_id
    -- Only take unmapped rows.
    and (information176 is null or
         (information180 is not null and information176 is null));
    --
    cursor c_table_name (p_table_route_id number)is
       select WHERE_CLAUSE
      from pqh_table_route
      where table_route_id = p_table_route_id;

    --
    cursor c_AssignmentSetIdNameLovVO(p_source_name1 varchar2) is
    select assignment_set_name name, assignment_set_id id
    from hr_assignment_sets
    where business_group_id = p_target_business_group_id
      and assignment_set_name = p_source_name1;
    --
    cursor c_AttendenceReasonNameLovVO(p_source_name1 varchar2,
                                       p_absence_attendance_type_id number,
                                       cv_effective_date date)  is
    select hl.meaning name,
           abr.abs_attendance_reason_id id
    from per_abs_attendance_reasons abr,
         hr_leg_lookups hl
    where abr.name = hl.lookup_code and
          hl.lookup_type = 'ABSENCE_REASON' and
          hl.enabled_flag = 'Y'
      and meaning = p_source_name1
      and absence_attendance_type_id = p_absence_attendance_type_id
      and trunc(cv_effective_date)
          between  Start_Date_Active and
                  nvl(End_Date_Active, trunc(cv_effective_date) )
     and business_group_id = p_target_business_group_id;
    --
    cursor c_AttendenceTypeNameLovVO(p_source_name1 varchar2,
                                     cv_effective_date date) is
    select abt.name Name,
            abt.absence_attendance_type_id id
    from per_absence_attendance_types abt
    where trunc(cv_effective_date)
          between  Date_Effective  and nvl(Date_end, trunc(cv_effective_date))
          and business_group_id = p_target_business_group_id
      and abt.name = p_source_name1;
    --
    cursor c_CompetenceIdNameLovVO(p_source_name1 varchar2,
                                   cv_effective_date date) is
    select name name
           ,competence_id id
    from   per_competences_vl
    where  trunc(cv_effective_date)
           between  Date_from  and nvl(Date_to, trunc(cv_effective_date) )
      and  nvl(business_group_id , p_target_business_group_id) = p_target_business_group_id
      and name = p_source_name1;
    --
    cursor c_DefinedBalanceIdLovVO(p_source_name1 varchar2) is
    select pbt.balance_name||' - '||pbd.dimension_name name ,
           pdb.defined_balance_id id
    from pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
    where pdb.balance_type_id = pbt.balance_type_id
      and pdb.balance_dimension_id = pbd.balance_dimension_id
      and nvl(pdb.business_group_id, p_target_business_group_id) = p_target_business_group_id
      and pbt.balance_name||' - '||pbd.dimension_name = p_source_name1;

    --
    cursor c_EmployeeStatusLovVO(p_source_name1 varchar2) is
    select nvl(atl.user_status, stl.user_status) name
            , s.assignment_status_type_id id
    from per_assignment_status_types s,
         per_ass_status_type_amends a,
         per_assignment_status_types_tl stl,
         per_ass_status_type_amends_tl atl
    where a.assignment_status_type_id (+) = s.assignment_status_type_id
     and a.business_group_id (+) = p_target_business_group_id
     and nvl(s.business_group_id, p_target_business_group_id) = p_target_business_group_id
     and nvl(s.legislation_code, p_legislation_code) = p_legislation_code
     and nvl(a.active_flag, s.active_flag) = 'Y'
     and atl.ass_status_type_amend_id (+) = a.ass_status_type_amend_id
     and atl.language (+) = userenv('LANG')
     and stl.assignment_status_type_id = s.assignment_status_type_id
     and stl.language  = userenv('LANG')
      and nvl(atl.user_status, stl.user_status) = p_source_name1;
    --
    cursor c_InputValueLovVO(p_source_name1 varchar2,
                             p_element_type_id number,
                             cv_effective_date date) is
    select  pivt.name name,
         pivt.input_value_id id
    from pay_input_values_f piv,
         pay_input_values_f_tl pivt
    where trunc(cv_effective_date)
          between piv.effective_start_date and piv.effective_end_date
      and ((piv.business_group_id is null and nvl(piv.legislation_code, p_legislation_code)
            = p_legislation_code)or piv.business_group_id = p_target_business_group_id )
      and piv.input_value_id = pivt.input_value_id
      and pivt.language = userenv('LANG')
      and pivt.name = p_source_name1
      and element_type_id = p_element_type_id;
    --
    cursor c_JobGroupIdLovVO(p_source_name1 varchar2) is
    select displayed_name name,
           job_group_id id
    from per_job_groups
    where business_group_id = p_target_business_group_id
      and displayed_name = p_source_name1;
    --
    cursor c_JobIdLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select jobtl.name name ,
           job.job_id id
    from per_jobs job
        ,per_jobs_tl jobtl
    where trunc(cv_effective_date)
          between  Date_from  and nvl(Date_to, trunc(cv_effective_date))
      and job.business_group_id + 0 = p_target_business_group_id
      and job.job_id = jobtl.job_id
      and jobtl.language = userenv('LANG')
      and jobtl.name = p_source_name1;

    --
    cursor c_LegalEntityNameLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select txu.name name,
           txu.tax_unit_id id
    from hr_tax_units_v txu
    where trunc(cv_effective_date)
          between  Date_from  and nvl(Date_to, trunc(cv_effective_date))
      and p_target_business_group_id = txu.business_group_id
      and txu.name = p_source_name1;
    --
    cursor c_LocationNameLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select loc.location_code name,
           loc.location_id id
    from hr_locations loc
    where trunc(cv_effective_date) <= nvl( loc.inactive_date, trunc(cv_effective_date))
     and nvl(business_group_id,p_target_business_group_id) = p_target_business_group_id
      and loc.location_code = p_source_name1;
    --
    cursor c_GroupOptionIdLovVO( cv_name  varchar2, cv_effective_date date) is
    select
    opt.name  Name ,
    Opt.opt_id
    from ben_opt_f  opt
    where   opt.opt_id = opt.group_opt_id
      and opt.name = cv_name
      and   trunc(cv_effective_date) between
        opt.effective_start_date and opt.effective_end_date;

    --
    cursor c_GroupPlanLovVO( cv_name  varchar2, cv_effective_date date) is
    select
    bp.name name,
    bp.pl_id id
    FROM
    ben_pl_f bp,
    ben_pl_typ_f bpt
    WHERE
        bp.pl_id = bp.group_pl_id
    and bp.name  = cv_name
    and bp.pl_typ_id = bpt.pl_typ_id
    and bpt.opt_typ_cd = 'CWB'
    and trunc(cv_effective_date) between bp.effective_start_date and bp.effective_end_date
    and trunc(cv_effective_date) between bpt.effective_start_date and bpt.effective_end_date
    and bp.business_group_id = bpt.business_group_id;

    --
    cursor c_OrganizationLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select orgtl.name name,
           org.organization_id id
       from hr_all_organization_units org,
            hr_all_organization_units_tl orgtl
       where org.business_group_id = p_target_business_group_id
       and orgtl.organization_id = org.organization_id
       and orgtl.language = userenv('LANG')
       and org.internal_external_flag = 'INT'
       and trunc(cv_effective_date)
           between nvl(org.date_from, trunc(cv_effective_date))
            and nvl(org.date_to, trunc(cv_effective_date))
      and orgtl.name = p_source_name1;

    --
    cursor c_PayBasisNameLovVO(p_source_name1 varchar2) is
    select name,
           pay_basis_id id
    from per_pay_bases
    where business_group_id = p_target_business_group_id
      and name = p_source_name1;
    --
    cursor c_PayrollNameLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select prl.payroll_name name /* cg$fk */ ,
           prl.payroll_id id
    from pay_all_payrolls_f prl
    where trunc(cv_effective_date)
          between prl.effective_start_date and prl.effective_end_date
      and prl.business_group_id + 0 = p_target_business_group_id
      and prl.payroll_name = p_source_name1;

    --
    cursor c_PersonTypeNameLovVO(p_source_name1 varchar2) is
    select ptl.user_person_type name,
           ppt.person_type_id id
    from per_person_types ppt,
        hr_leg_lookups hrlkup,
        per_person_types_tl ptl
    where active_flag = 'Y' and
     hrlkup.lookup_type = 'PERSON_TYPE'
    and hrlkup.lookup_code =  ppt.system_person_type
    and ppt.active_flag = 'Y'
    and business_group_id = p_target_business_group_id
    and ppt.person_type_id = ptl.person_type_id
    and ptl.language = userenv('LANG')
      and ptl.user_person_type = p_source_name1;

    --
    cursor c_PoplOrganizationLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select org.name name,
           org.organization_id id
    from hr_organization_units org
    where trunc(cv_effective_date)
          between  Date_from  and nvl(Date_to, trunc(cv_effective_date))
     and org.business_group_id +0 = p_target_business_group_id
      and org.name = p_source_name1;
    --
    cursor c_PositionNameLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select name,
           position_id id
     from per_positions
     where trunc(cv_effective_date) >=  date_effective
     and   business_group_id = p_target_business_group_id
      and name = p_source_name1;
    --
    cursor c_PositionStructureNameLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select pos.NAME name,
           POS_STRUCTURE_VERSION_ID id
    from PER_POSITION_STRUCTURES pos,
         PER_POS_STRUCTURE_VERSIONS pov
    where pos.POSITION_STRUCTURE_ID = pov.POSITION_STRUCTURE_ID
    and trunc(cv_effective_date)
          between POV.DATE_FROM and nvl(POV.DATE_TO, trunc(cv_effective_date))
    and pos.business_group_id = p_target_business_group_id
      and pos.NAME = p_source_name1;
    --
    cursor c_QualificationNmaeLovVO(p_source_name1 varchar2) is
    select name, qualification_type_id id
    from per_qualification_types_tl pqttl
    where pqttl.language = userenv('LANG')
      and name = p_source_name1;
    --
    cursor c_RatingLevelIdNameLovVO(p_source_name1 varchar2
                                   ,p_competence_id number) is
    select rtl.name,
           rtl.rating_level_id id
    from   per_rating_levels_vl rtl,   /* MLS Changes*/
           per_competences pct
     where  (rtl.competence_id = pct.competence_id
             or rtl.rating_scale_id = pct.rating_scale_id )
      and    pct.competence_id = p_competence_id
      and    nvl(rtl.business_group_id, p_target_business_group_id ) = p_target_business_group_id
      and rtl.name = p_source_name1;
    --
    cursor c_ElementTypeLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select pett.element_name name
           ,pett.element_type_id id
    from pay_element_types_f pet,
         pay_element_types_f_tl pett
    where trunc(cv_effective_date)
          between nvl(pet.effective_start_date,trunc(cv_effective_date)) and nvl
    (pet.effective_end_date,trunc(cv_effective_date ))
    and pet.element_type_id=pett.element_type_id
    and pett.language = userenv('LANG')
    and ( (pet.business_group_id is null and nvl(pet.legislation_code, p_legislation_code) = p_legislation_code)
           or pet.business_group_id = p_target_business_group_id)
      and pett.element_name = p_source_name1;
    --

    cursor c_GradeIdLovVO(p_source_name1 varchar2, cv_effective_date date) is
    select gra.name name
          ,gra.grade_id id
    from per_grades_vl gra  /*MLS Changes*/
    where trunc(cv_effective_date)
          between  Date_from  and nvl(Date_to, trunc(cv_effective_date) )
      and business_group_id + 0 = p_target_business_group_id
      and gra.name = p_source_name1;
    --
l_table_route_name pqh_table_route.WHERE_CLAUSE%type;
--
l_effective_date1 date;
l_effective_date2 date;
 begin
    --
   hr_utility.set_location(' Entering :'||l_proc, 10);
    --
    open c_table_name(p_table_route_id);
    fetch c_table_name into l_table_route_name;
    close c_table_name;
    --
    if (l_table_route_name = 'BEN_ACTY_BASE_RT_F') then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop
              --
              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              open c_ElementTypeLovVO(l_ret.information173, l_effective_date1);
              fetch c_ElementTypeLovVO into l_ret.information175,
                                            l_ret.information176;
              close c_ElementTypeLovVO;
              --
              open c_InputValueLovVO(l_ret.information177,l_ret.information176, l_effective_date2);
              fetch c_InputValueLovVO into l_ret.information179,
                                            l_ret.information180;
              close c_InputValueLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_COMP_LVL_FCTR'
                  or l_table_route_name = 'BEN_HRS_WKD_IN_PERD_FCTR'
                  or l_table_route_name = 'BEN_HRS_WKD_IN_PERD_RT_F'
                  or l_table_route_name = 'BEN_COMP_LVL_RT_F') then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop
              --
              open c_DefinedBalanceIdLovVO(l_ret.information173);
              fetch c_DefinedBalanceIdLovVO into l_ret.information175,l_ret.information176;
              close c_DefinedBalanceIdLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ASNT_SET_RT_F'
                or l_table_route_name = 'BEN_ELIG_ASNT_SET_PRTE_F') then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop
              --
              open c_AssignmentSetIdNameLovVO(l_ret.information173);
              fetch c_AssignmentSetIdNameLovVO into l_ret.information175,l_ret.information176;
              close c_AssignmentSetIdNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name =  'BEN_COMPTNCY_RT_F'
             or l_table_route_name = 'BEN_ELIG_COMPTNCY_PRTE_F')then
          --
      for l_ret in c_source_data (p_table_route_id)
      loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_CompetenceIdNameLovVO(l_ret.information173, l_effective_date1);
              fetch c_CompetenceIdNameLovVO into l_ret.information175,l_ret.information176;
              close c_CompetenceIdNameLovVO;
              --
              open c_RatingLevelIdNameLovVO(l_ret.information177,l_ret.information176);
              fetch c_RatingLevelIdNameLovVO into l_ret.information179,l_ret.information180;
              close c_RatingLevelIdNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_EE_STAT_RT_F'
                 or l_table_route_name = 'BEN_ELIG_EE_STAT_PRTE_F')then
          --
      for l_ret in c_source_data (p_table_route_id)
      loop
              --
              open c_EmployeeStatusLovVO(l_ret.information173);
              fetch c_EmployeeStatusLovVO into l_ret.information175,l_ret.information176;
              close c_EmployeeStatusLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif  (l_table_route_name = 'BEN_ELIG_GRD_PRTE_F'
                 or l_table_route_name = 'BEN_GRADE_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_GradeIdLovVO(l_ret.information173, l_effective_date1);
              fetch c_GradeIdLovVO into l_ret.information175,l_ret.information176;
              close c_GradeIdLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ELIG_JOB_PRTE_F'
                or l_table_route_name = 'BEN_JOB_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_JobIdLovVO(l_ret.information173, l_effective_date1);
              fetch c_JobIdLovVO into l_ret.information175,l_ret.information176;
              close c_JobIdLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ELIG_ORG_UNIT_PRTE_F'
                 or l_table_route_name = 'BEN_ORG_UNIT_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop
              --

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              open c_OrganizationLovVO(l_ret.information173, l_effective_date1);
              fetch c_OrganizationLovVO into l_ret.information175,l_ret.information176;
              close c_OrganizationLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ELIG_LOA_RSN_PRTE_F'
                 or l_table_route_name = 'BEN_LOA_RSN_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_AttendenceTypeNameLovVO(l_ret.information173, l_effective_date1);
              fetch c_AttendenceTypeNameLovVO into l_ret.information175,l_ret.information176;
              close c_AttendenceTypeNameLovVO;
              --
              open c_AttendenceReasonNameLovVO(l_ret.information177,l_ret.information176, l_effective_date2);
              fetch c_AttendenceReasonNameLovVO into l_ret.information179,l_ret.information180;
              close c_AttendenceReasonNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ELIG_PER_TYP_PRTE_F'
                 or l_table_route_name = 'BEN_PER_TYP_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop
              --
              open c_PersonTypeNameLovVO(l_ret.information173);
              fetch c_PersonTypeNameLovVO into l_ret.information175,l_ret.information176;
              close c_PersonTypeNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ELIG_PSTN_PRTE_F'
                 or l_table_route_name = 'BEN_PSTN_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_PositionNameLovVO(l_ret.information173, l_effective_date1);
              fetch c_PositionNameLovVO into l_ret.information175,l_ret.information176;
              close c_PositionNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ELIG_PYRL_PRTE_F'
                 or l_table_route_name = 'BEN_PYRL_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_PayrollNameLovVO(l_ret.information173, l_effective_date1);
              fetch c_PayrollNameLovVO into l_ret.information175,l_ret.information176;
              close c_PayrollNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ELIG_PY_BSS_PRTE_F'
                  or l_table_route_name = 'BEN_PY_BSS_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop
              --
              open c_PayBasisNameLovVO(l_ret.information173);
              fetch c_PayBasisNameLovVO into l_ret.information175,l_ret.information176;
              close c_PayBasisNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ELIG_QUAL_TITL_PRTE_F'
                  or l_table_route_name = 'BEN_QUAL_TITL_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop
              --
              open c_QualificationNmaeLovVO(l_ret.information173);
              fetch c_QualificationNmaeLovVO into l_ret.information175,l_ret.information176;
              close c_QualificationNmaeLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif l_table_route_name = 'BEN_ELIG_SUPPL_ROLE_PRTE_F'  then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_JobGroupIdLovVO(l_ret.information173);
              fetch c_JobGroupIdLovVO into l_ret.information175,l_ret.information176;
              close c_JobGroupIdLovVO;
              --
              open c_JobIdLovVO(l_ret.information177, l_effective_date2);
              fetch c_JobIdLovVO into l_ret.information179,l_ret.information180;
              close c_JobIdLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif  (l_table_route_name = 'BEN_PL_F') then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop
              --
              open c_GroupPlanLovVO (l_ret.information173, p_effective_date);
              fetch c_GroupPlanLovVO into l_ret.information175,l_ret.information176;
              close c_GroupPlanLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif  (l_table_route_name = 'BEN_OPT_F') then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop
              --
              open c_GroupOptionIdLovVO (l_ret.information173, p_effective_date);
              fetch c_GroupOptionIdLovVO into l_ret.information175,l_ret.information176;
              close c_GroupOptionIdLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif  (l_table_route_name = 'BEN_ELIG_WK_LOC_PRTE_F'
                 or l_table_route_name = 'BEN_WK_LOC_RT_F') then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_LocationNameLovVO(l_ret.information173, l_effective_date1);
              fetch c_LocationNameLovVO into l_ret.information175,l_ret.information176;
              close c_LocationNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_ENRT_PERD')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_PositionStructureNameLovVO(l_ret.information173, l_effective_date1);
              fetch c_PositionStructureNameLovVO into l_ret.information175,l_ret.information176;
              close c_PositionStructureNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name =  'BEN_ELIG_LGL_ENTY_PRTE_F'
                  or l_table_route_name = 'BEN_LGL_ENTY_RT_F')then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_LegalEntityNameLovVO(l_ret.information173, l_effective_date1);
              fetch c_LegalEntityNameLovVO into l_ret.information175,l_ret.information176;
              close c_LegalEntityNameLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    elsif (l_table_route_name = 'BEN_POPL_ORG_F') then
          --
          for l_ret in c_source_data (p_table_route_id)
          loop

              get_effective_dates(
                p_process_effective_date => p_effective_date
               ,p_start_date1            => l_ret.information166
               ,p_start_date2            => l_ret.information306
               ,p_effective_date_to_copy => p_effective_date_to_copy
               ,p_effective_date1        => l_effective_date1
               ,p_effective_date2        => l_effective_date2);

              --
              open c_PoplOrganizationLovVO(l_ret.information173, l_effective_date1);
              fetch c_PoplOrganizationLovVO into l_ret.information175,l_ret.information176;
              close c_PoplOrganizationLovVO;
              --
              update_mapping_target_data (
                  p_table_route_id               =>p_table_route_id
                , p_copy_entity_txn_id           =>p_copy_entity_txn_id
                , p_source_id1                   =>l_ret.information174
                , p_target_value1                =>l_ret.information175
                , p_target_id1                   =>l_ret.information176
                , p_source_id2                   =>l_ret.information178
                , p_target_value2                =>l_ret.information179
                , p_target_id2                   =>l_ret.information180
                 );
              --
          end loop;
    end if;
  --
  hr_utility.set_location(' Leaving :'||l_proc, 10);
  --
  end auto_mapping;
--

procedure update_mapping_target_data(
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_txn_id             in number
  ,p_table_route_id                 in number
  ,p_source_id1                      in number
  ,p_target_value1                   in varchar2
  ,p_target_id1                     in number
  ,p_source_id2                      in number
  ,p_target_value2                   in varchar2
  ,p_target_id2                      in number
  ,p_business_group_id              in number       default hr_api.g_number
  ,p_effective_date                 in date          default null
) is
  --
  cursor c_result_set(p_copy_entity_txn_id number, p_table_route_id number) is
  select COPY_ENTITY_RESULT_ID,object_version_number
  from ben_copy_entity_results
  where copy_entity_txn_id = p_copy_entity_txn_id
    and table_route_id = p_table_route_id;
  --
  l_object_version_number number;
begin
  --
/*
 for l_rec in c_result_set(p_copy_entity_txn_id,p_table_route_id) loop
  --
   update_plan_design_result(
                     p_validate                      => p_validate
                    ,p_copy_entity_result_id         => l_rec.copy_entity_result_id
                    ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                    ,p_business_group_id             => p_business_group_id
                    ,p_object_version_number         => l_rec.object_version_number
                    ,p_effective_date                => p_effective_date
                    ,p_information175                => p_target_value1
                    ,p_information176                => p_target_id1
                    ,p_information179                => p_target_value2
                    ,p_information180                => p_target_id2
                     );
  --
 end loop;
*/

  update ben_copy_entity_results
  set information175 = p_target_value1
     ,information176 = p_target_id1
     ,information179 = p_target_value2
     ,information180 = p_target_id2
  where copy_entity_txn_id = p_copy_entity_txn_id
    and table_route_id     = p_table_route_id
    and information174     = p_source_id1
    and nvl(information178,-1) = nvl(p_source_id2,-1);

  --
end update_mapping_target_data;
--

function get_mapping_info( p_mapping_info varchar2,
                           p_table_route_id number,
                           p_entity_txn_id number) return varchar2 is
    l_ret varchar2(1000) := 'No';
    --
    cursor is_maping_completed(p_entity_txn_id number,p_table_route_id number) is
          select cer.information175
          from ben_copy_entity_results cer,
               pqh_copy_entity_txns    cet
          where cer.copy_entity_txn_id = p_entity_txn_id
            and cer.copy_entity_txn_id = cet.copy_entity_txn_id
            and cer.information176 is null
            and cer.information174 is not null
            and cer.NUMBER_OF_COPIES =1
            and cer.table_route_id = p_table_route_id
            and ( (cet.action_date is null) or
                  (cer.information3 is null) or
                  (cet.action_date is not null and
                   information3 >= cet.action_date)
                );

    --
    cursor c_mapping_required_table(p_table_route_id number)is
       select table_route_id
       from pqh_table_route
       where table_route_id = p_table_route_id
         and where_clause in('BEN_HRS_WKD_IN_PERD_FCTR',
                             --'BEN_PL_F',
                             --'BEN_OPT_F',
                             --'BEN_POPL_ORG_F',
                             'BEN_COMP_LVL_FCTR',
			     'BEN_ENRT_PERD');       -- Bug No 4498668
    --
    cursor c_table_name (p_table_route_id number) is
    select display_name
    from pqh_table_route
    where table_route_id = p_table_route_id;

    l_table_name pqh_table_route.display_name%type;
begin
   if(p_mapping_info = 'CompletedInfo') then
   --
     open is_maping_completed(p_entity_txn_id ,p_table_route_id );
     fetch is_maping_completed into l_ret;
     --
     if is_maping_completed%found then
        l_ret :=  'NotCompleted';
     else
        l_ret :=  'Completed';
     end if;
     --
     close is_maping_completed;
   --
   elsif(p_mapping_info = 'RequiredInfo') then
      --
      open c_mapping_required_table(p_table_route_id);
      fetch c_mapping_required_table into l_ret;
      --
      if c_mapping_required_table%found then
         l_ret := 'Yes';
      end if;
      --
      close c_mapping_required_table;
      --
   elsif(p_mapping_info = 'TableNameInfo') then
      --
      open c_mapping_required_table(p_table_route_id);
      fetch c_mapping_required_table into l_ret;
      --
      close c_mapping_required_table;
      --
   end if;
   return l_ret;
   --
end get_mapping_info;

--

procedure get_user_business_group_ids(
  p_user_id in number,
  p_business_group_ids out nocopy varchar2
  ) is
  --
  /* Bug 3170928 Changes
  cursor c_get_sec_prf_bg_id(p_user_id number) is
  select distinct(business_group_id) business_group_id
    from per_sec_profile_assignments_v
   where user_id = p_user_id
     and trunc(sysdate) between START_DATE
         and nvl(END_DATE, trunc(sysdate));
   */
   cursor c_get_sec_prf_bg_id(p_user_id number) is
     select distinct(business_group_id) business_group_id
       from per_sec_profile_assignments_v
      where user_id = p_user_id
        and trunc(sysdate) between START_DATE
                               and nvl(END_DATE, trunc(sysdate))
        and business_group_id is not null ;
  /* Bug 3170928 Changes
  cursor c_get_user_resp_value(p_user_id number) is
  select optval.PROFILE_OPTION_VALUE
              from FND_PROFILE_OPTION_VALUES optval,
                   fnd_profile_options_vl opt,
                   FND_USER_RESP_GROUPS resp
               where opt.profile_option_id = optval.profile_option_id
               and optval.level_value = resp.RESPONSIBILITY_ID
               and resp.user_id = p_user_id
               and opt.profile_option_name like 'PER_BUSINESS_GROUP_ID'
               and trunc(sysdate) between resp.START_DATE
                          and nvl(resp.END_DATE, trunc(sysdate));
   */
   --
   cursor c_get_user_resp_value(p_user_id number) is
     select resp.user_id,
            resp.responsibility_id,
            resp.responsibility_application_id application_id
       from fnd_user_resp_groups resp
      where resp.user_id = p_user_id;
   --
   l_business_group_id varchar2(30) ;
   --
 begin
 --
   p_business_group_ids := '''-1''';
   --
   /* Bug 3170928 Changes
   for l_rec in c_get_user_resp_value(p_user_id) loop
       --
       p_business_group_ids := p_business_group_ids||','''||l_rec.PROFILE_OPTION_VALUE ||'''';
       --
   end loop;
   */
   --
   for l_rec in c_get_user_resp_value(p_user_id) loop
     --
     p_business_group_ids := p_business_group_ids||','''||FND_PROFILE.VALUE_SPECIFIC(
                                       NAME              => 'PER_BUSINESS_GROUP_ID'
                                      ,USER_ID           => l_rec.user_id
                                      ,RESPONSIBILITY_ID => l_rec.responsibility_id
                                      ,APPLICATION_ID    => l_rec.application_id
                                      )||'''';
     --
   end loop;
   --
   -- incase if the data base has set to access Multiple Security Group
   -- ( "one responsibility can attach to more than one business group")
   -- then the PER_BUSINESS_GROUP_ID will be null.
   --
   for l_rec in c_get_sec_prf_bg_id(p_user_id) loop
       --
       p_business_group_ids := p_business_group_ids||','''||l_rec.business_group_id ||'''';
       --
   end loop;
   --
 --
 end get_user_business_group_ids;

--
procedure create_process_log
  (p_module_cd                      in  varchar2
  ,p_txn_id                         in  number
  ,p_message_text                   in  varchar2
  ,p_message_type_cd                in  varchar2
  ) is
begin
  insert into pqh_process_log
  (	process_log_id,
	module_cd,
	txn_id,
	message_text,
	message_type_cd,
	object_version_number
  )
  Values
  (	pqh_process_log_s.nextval,
	p_module_cd,
	p_txn_id,
	p_message_text,
	p_message_type_cd,
	1
   );
end;
--

procedure create_log
 ( p_copy_entity_txn_id       in  number
 ) is

   cursor c_copy_entity_txn(c_copy_entity_txn_id in number) is
   select  cet.process_name
          ,cet.src_effective_date
          ,cet.context_business_group_id
          ,cet.target_business_group_id
          ,cet.prefix_suffix_text
          ,cet.prefix_suffix_cd
          ,cet.reuse_object_flag
          ,cet.target_typ_cd
          ,cet.information30 source_business_group_name
          ,cet.action_date
          ,tcg.short_name
   from    ben_copy_entity_txns_vw cet,
           pqh_transaction_categories tcg
   where   cet.copy_entity_txn_id = c_copy_entity_txn_id
   and     cet.transaction_category_id = tcg.transaction_category_id;

   cursor c_business_group_name(c_business_group_id in number) is
   select name
   from per_business_groups
   where business_group_id = c_business_group_id;

   cursor c_lookup (c_lookup_type  in varchar2
                    ,c_lookup_code in varchar2) is
   select meaning
   from    hr_lookups
   where   lookup_type     = c_lookup_type
   and     lookup_code     = c_lookup_code;

   l_icx_date_format_mask       varchar2(30);

   cursor c_run_details is
   select  to_char(trunc(sysdate), l_icx_date_format_mask) run_date
          ,to_char(sysdate,'HH24:MI:SS') run_time
   from   dual ;

   cursor c_run_by(c_user_id in number) is
   select  user_name
   from   fnd_user
   where user_id = c_user_id;

   l_copy_entity_txn            c_copy_entity_txn%rowtype;
   l_target_business_group_name per_business_groups.name%type;
   l_reuse_option               hr_lookups.meaning%type;
   l_prefix_suffix_option       hr_lookups.meaning%type;
   l_run_date                   varchar2(50);
   l_run_time                   varchar2(50);
   l_run_by                     fnd_user.user_name%type;

   cursor c_table_route is
   select table_alias
          ,display_name
   from    pqh_table_route_vl trt
   where   trt.table_alias in
   ('PGM', 'PLN', 'OPT', 'PTP', 'EAT'
   ,'BNB', 'CLF', 'HWF', 'AGF', 'LSF'
   ,'PFF', 'CLA', 'REG', 'BNR', 'BPP'
   ,'LER', 'ELP', 'DCE', 'GOS', 'BNG'
   ,'PDL', 'SVA', 'CPL', 'CBP', 'CPT'
   ,'FFF', 'ABR', 'APR', 'VPF', 'CCM'
   ,'ACP', 'PSL', 'EGL');

    cursor c_cer(c_copy_entity_txn_id in number
                ,c_information8       in varchar2) is
    select information5 name
    from ben_copy_entity_results cer
    where cer.copy_entity_txn_id = c_copy_entity_txn_id
    and   cer.number_of_copies = 1
    and   cer.result_type_cd = 'DISPLAY'
    and   cer.information8 = c_information8;

    cursor c_selection_count(c_copy_entity_txn_id in number) is
    select count(1) from (
    select   distinct information1,information2,information3,table_route_id
    from ben_copy_entity_results cer
    where copy_entity_txn_id = c_copy_entity_txn_id
    and number_of_copies = 1);

    cursor c_copied_reused_count(c_copy_entity_txn_id in number
                                ,c_copied_reused_type in varchar2) is
    select count(1) from (
    select   distinct information1,information2,information3,table_route_id
    from ben_copy_entity_results
    where copy_entity_txn_id = c_copy_entity_txn_id
    and number_of_copies = 1
    and information9 like c_copied_reused_type);

    cursor c_not_copied_count(c_copy_entity_txn_id in number) is
    select count(1) from (
    select   distinct information1,information2,information3,table_route_id
    from ben_copy_entity_results
    where copy_entity_txn_id = c_copy_entity_txn_id
    and number_of_copies = 1
    and information9 is null);

    cursor c_items_to_ignore_count(c_copy_entity_txn_id in number) is
    select count(1) from (
    select   distinct information1,information2,information3,cer.table_route_id
    from ben_copy_entity_results cer
--         pqh_table_route tre
    where copy_entity_txn_id = c_copy_entity_txn_id
    and   number_of_copies = 1
    and   cer.table_alias = 'EAT'
--    and cer.table_route_id = tre.table_route_id
	);

    l_selection_count number;
    l_copied_count number;
    l_reused_count number;
    l_not_copied_count number;
    l_items_to_ignore_count number;

    l_pgm_label  pqh_table_route_vl.display_name%type;
    l_pln_label  pqh_table_route_vl.display_name%type;
    l_opt_label  pqh_table_route_vl.display_name%type;
    l_ptp_label  pqh_table_route_vl.display_name%type;
    l_eat_label  pqh_table_route_vl.display_name%type;
    l_bnb_label  pqh_table_route_vl.display_name%type;
    l_clf_label  pqh_table_route_vl.display_name%type;
    l_hwf_label  pqh_table_route_vl.display_name%type;
    l_agf_label  pqh_table_route_vl.display_name%type;
    l_lsf_label  pqh_table_route_vl.display_name%type;
    l_pff_label  pqh_table_route_vl.display_name%type;
    l_cla_label  pqh_table_route_vl.display_name%type;
    l_reg_label  pqh_table_route_vl.display_name%type;
    l_bnr_label  pqh_table_route_vl.display_name%type;
    l_bpp_label  pqh_table_route_vl.display_name%type;
    l_ler_label  pqh_table_route_vl.display_name%type;
    l_psl_label  pqh_table_route_vl.display_name%type;
    l_elp_label  pqh_table_route_vl.display_name%type;
    l_dce_label  pqh_table_route_vl.display_name%type;
    l_gos_label  pqh_table_route_vl.display_name%type;
    l_bng_label  pqh_table_route_vl.display_name%type;
    l_pdl_label  pqh_table_route_vl.display_name%type;
    l_sva_label  pqh_table_route_vl.display_name%type;
    l_cpl_label  pqh_table_route_vl.display_name%type;
    l_cbp_label  pqh_table_route_vl.display_name%type;
    l_cpt_label  pqh_table_route_vl.display_name%type;
    l_fff_label  pqh_table_route_vl.display_name%type;
    l_abr_label  pqh_table_route_vl.display_name%type;
    l_apr_label  pqh_table_route_vl.display_name%type;
    l_vpf_label  pqh_table_route_vl.display_name%type;
    l_ccm_label  pqh_table_route_vl.display_name%type;
    l_acp_label  pqh_table_route_vl.display_name%type;
    l_egl_label  pqh_table_route_vl.display_name%type;   /* Bug 4169120 Rate By Criteria */

    l_selected_for_copy_lbl fnd_new_messages.message_text%type;
    l_created_objects_lbl   fnd_new_messages.message_text%type;
    l_reused_objects_lbl    fnd_new_messages.message_text%type;
    l_process_summary_lbl   fnd_new_messages.message_text%type;

    l_para_spacer varchar2(50) := '&nbsp;&nbsp;&nbsp;&nbsp;';
    l_single_spacer varchar2(10) := '&nbsp;';

    l_header_start_tag varchar2(50) := '<B><span class="OraAccessKeyChar">';
    l_header_end_tag varchar2(50) := '</span></B>';

    l_label_start_tag varchar2(50) := '<B><SMALL>';
    l_label_end_tag varchar2(50) := '</SMALL></B>';

    l_value_start_tag varchar2(50) := '<SMALL>';
    l_value_end_tag varchar2(50) := '</SMALL>';

    l_blank_line varchar2(50) := '<BR/>';
    l_table_start_tag varchar2(10) := '<TABLE>';
    l_table_end_tag varchar2(10) := '</TABLE>';

    l_row_start_tag varchar2(10) := '<TR>';
    l_row_end_tag varchar2(10) := '</TR>';

    l_cell_start_tag varchar2(10) := '<TD>';
    l_cell_end_tag varchar2(10) := '</TD>';

    l_label      varchar2(10) := 'LABEL';
    l_value      varchar2(10) := 'VALUE';
    l_spacer     varchar2(10) := 'SPACER';
    l_module_cd  varchar2(10) := 'PDC_CP';

    l_print_label boolean := true;
  begin

    -- Update target details to ben_copy_entity_results_table
    update_cer_with_target(p_copy_entity_txn_id);

    -- Bug 4317567
    fnd_profile.get( NAME => 'ICX_DATE_FORMAT_MASK',
                     VAL  => l_icx_date_format_mask );
    --
    l_icx_date_format_mask := nvl(l_icx_date_format_mask, 'DD/MM/YYYY');
    -- Bug 4317567

    -- Fetch Copy process details
    open c_copy_entity_txn(p_copy_entity_txn_id);
    fetch c_copy_entity_txn into l_copy_entity_txn;
    close c_copy_entity_txn;

    -- Fetch Target Business Group Name
    open c_business_group_name(l_copy_entity_txn.target_business_group_id);
    fetch c_business_group_name into l_target_business_group_name;
    close c_business_group_name;

    -- Fetch Reuse Option
    open c_lookup('BEN_PD_REUSE_OBJECTS',l_copy_entity_txn.reuse_object_flag);
    fetch c_lookup into l_reuse_option;
    close c_lookup;

    -- Fetch Prefix Suffx Option
    open c_lookup('BEN_PD_PREFIX_SUFFIX',l_copy_entity_txn.prefix_suffix_cd);
    fetch c_lookup into l_prefix_suffix_option;
    close c_lookup;

    -- Fetch Run Details
    open c_run_details;
    fetch c_run_details into l_run_date,l_run_time;
    close c_run_details;

    -- Fetch Run By
    -- Bug 4278495
    if ICX_SEC.G_USER_ID <> -1
    then
      -- This is the case if Log gets created through SS
      open c_run_by(ICX_SEC.G_USER_ID);
      fetch c_run_by into l_run_by;
      close c_run_by;
    else
      -- This is the case if Log gets created through Concurrent Program BEPDCPRC
      open c_run_by(FND_GLOBAL.USER_ID);
      fetch c_run_by into l_run_by;
      close c_run_by;
    end if;
    -- Fetch Rows Selected count
    open c_selection_count(p_copy_entity_txn_id);
    fetch c_selection_count into l_selection_count;
    close c_selection_count;

    -- Fetch Rows Copied count
    open c_copied_reused_count(p_copy_entity_txn_id,'COPIED%');
    fetch c_copied_reused_count into l_copied_count;
    close c_copied_reused_count;

    -- Fetch Rows Reused count
    open c_copied_reused_count(p_copy_entity_txn_id,'REUSED%');
    fetch c_copied_reused_count into l_reused_count;
    close c_copied_reused_count;

    -- Fetch Rows Not Copied count
    open c_not_copied_count(p_copy_entity_txn_id);
    fetch c_not_copied_count into l_not_copied_count;
    close c_not_copied_count;

    -- Fetch Items to Ignore count
    -- Currently Action Types (EAT) count needs to be reduced
    -- from the Selection and Reused Counts
    -- as we download all Action Types for the Business Group
    -- and mark them as Reused
    open c_items_to_ignore_count(p_copy_entity_txn_id);
    fetch c_items_to_ignore_count into l_items_to_ignore_count;
    close c_items_to_ignore_count;

    l_selection_count := l_selection_count - l_items_to_ignore_count ;
    l_reused_count := l_reused_count - l_items_to_ignore_count;


    for r_table_route in c_table_route
    loop
      if r_table_route.table_alias = 'PGM'  then
        l_pgm_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'PLN'  then
        l_pln_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'OPT'  then
        l_opt_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'PTP'  then
        l_ptp_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'EAT'  then
        l_eat_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'BNB'  then
        l_bnb_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'CLF'  then
        l_clf_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'HWF'  then
        l_hwf_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'AGF'  then
        l_agf_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'LSF'  then
        l_lsf_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'PFF'  then
        l_pff_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'CLA'  then
        l_cla_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'REG'  then
        l_reg_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'BNR'  then
        l_bnr_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'BPP'  then
        l_bpp_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'LER'  then
        l_ler_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'PSL'  then
        l_psl_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'ELP'  then
        l_elp_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'DCE'  then
        l_dce_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'GOS'  then
        l_gos_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'BNG'  then
        l_bng_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'PDL'  then
        l_pdl_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'SVA'  then
        l_sva_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'CPL'  then
        l_cpl_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'CBP'  then
        l_cbp_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'CPT'  then
        l_cpt_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'FFF'  then
        l_fff_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'ABR'  then
        l_abr_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'APR'  then
        l_apr_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'VPF'  then
        l_vpf_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'CCM'  then
        l_ccm_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'ACP'  then
        l_acp_label :=  r_table_route.display_name;
      elsif r_table_route.table_alias = 'EGL' then    /* Bug 4169120 : Rate By Criteria */
        l_egl_label := r_table_route.display_name;
      end if;
    end loop;

    -- Delete Old Log Data
    delete from pqh_process_log
    where txn_id = p_copy_entity_txn_id
    and module_cd = 'PDC_CP';

    -- Insert Summary information

       -- Insert Process Summary
       l_process_summary_lbl := l_header_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93269_PDC_PROCESS_SUMMARY')
                                 ||l_header_end_tag;

       create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_process_summary_lbl
         ,p_message_type_cd  =>  l_label
         );

       -- Create Spacer Line
       create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_blank_line
         ,p_message_type_cd  =>  l_spacer
         );

       create_process_log
       (p_module_cd        =>  l_module_cd
       ,p_txn_id           =>  p_copy_entity_txn_id
       ,p_message_text     =>  l_table_start_tag ||l_row_start_tag
                               ||l_cell_start_tag||l_value_start_tag
                               ||fnd_message.get_string('BEN','BEN_93270_PDC_PROCESS_NAME')
                               ||l_value_end_tag||l_cell_end_tag
                               ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                               ||l_cell_start_tag||l_value_start_tag||l_copy_entity_txn.process_name
                               ||l_value_end_tag||l_cell_end_tag
                               ||l_row_end_tag
       ,p_message_type_cd  =>  l_label
       );

       create_process_log
       (p_module_cd        =>  l_module_cd
       ,p_txn_id           =>  p_copy_entity_txn_id
       ,p_message_text     =>  l_row_start_tag
                               ||l_cell_start_tag||l_value_start_tag
                               ||fnd_message.get_string('BEN','BEN_93271_PDC_EFFECTIVE_DATE')
                               ||l_value_end_tag||l_cell_end_tag
                               ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                               ||l_cell_start_tag||l_value_start_tag||to_char(l_copy_entity_txn.src_effective_date, l_icx_date_format_mask)
                               ||l_value_end_tag||l_cell_end_tag
                               ||l_row_end_tag
       ,p_message_type_cd  =>  l_label
       );

       -- Hide for Plan Design Wizard
       IF l_copy_entity_txn.short_name <> 'BEN_PDCRWZ' THEN

         create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                               ||l_cell_start_tag||l_value_start_tag
                               ||fnd_message.get_string('BEN','BEN_93272_PDC_SRC_BUSINESS_GRP')
                               ||l_value_end_tag||l_cell_end_tag
                               ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                               ||l_cell_start_tag||l_value_start_tag||l_copy_entity_txn.source_business_group_name
                               ||l_value_end_tag||l_cell_end_tag
                               ||l_row_end_tag
         ,p_message_type_cd  =>  l_label
         );

         if l_copy_entity_txn.target_typ_cd = 'BEN_PDSMBG' then
           create_process_log
           (p_module_cd        =>  l_module_cd
           ,p_txn_id           =>  p_copy_entity_txn_id
           ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93273_PDC_TGT_BUSINESS_GRP')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag||l_copy_entity_txn.source_business_group_name
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
           ,p_message_type_cd  =>  l_label
           );
         else
           create_process_log
           (p_module_cd        =>  l_module_cd
           ,p_txn_id           =>  p_copy_entity_txn_id
           ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93273_PDC_TGT_BUSINESS_GRP')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag||l_target_business_group_name
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
           ,p_message_type_cd  =>  l_label
           );
         end if;

       ELSE
         -- For Plan Design Wizard

         create_process_log
           (p_module_cd        =>  l_module_cd
           ,p_txn_id           =>  p_copy_entity_txn_id
           ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93809_PDC_BUSINESS_GROUP')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag||l_target_business_group_name
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
           ,p_message_type_cd  =>  l_label
           );

       END IF;


       -- Hide for Plan Design Wizard
       IF l_copy_entity_txn.short_name <> 'BEN_PDCRWZ' THEN

         if l_copy_entity_txn.action_date is not null then
           create_process_log
           (p_module_cd        =>  l_module_cd
           ,p_txn_id           =>  p_copy_entity_txn_id
           ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93422_PDC_EFF_DATE_TO_COPY')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag|| to_char(l_copy_entity_txn.action_date, l_icx_date_format_mask)
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
           ,p_message_type_cd  =>  l_label
           );

         end if;

         create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93274_PDC_REUSE_OPTION')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||l_reuse_option
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
         ,p_message_type_cd  =>  l_label
         );

         create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93275_PDC_PREFIX_SUFFIX')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||l_copy_entity_txn.prefix_suffix_text
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
         ,p_message_type_cd  =>  l_label
         );

         create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93276_PDC_ROWS_SELECTED')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||l_selection_count
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
         ,p_message_type_cd  =>  l_label
         );

         create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93277_PDC_ROWS_CREATED')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||l_copied_count
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
         ,p_message_type_cd  =>  l_label
         );

         create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93278_PDC_ROWS_REUSED')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||l_reused_count
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
         ,p_message_type_cd  =>  l_label
         );

         create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93279_PDC_ROWS_NOT_COPIED')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||l_not_copied_count
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
         ,p_message_type_cd  =>  l_label
         );

       END IF;

        create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93280_PDC_RUN_DATE')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||l_run_date
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
         ,p_message_type_cd  =>  l_label
         );

        create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93281_PDC_RUN_TIME')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||l_run_time
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag
         ,p_message_type_cd  =>  l_label
         );

        create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_row_start_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93282_PDC_RUN_BY')
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_cell_start_tag||l_single_spacer||l_cell_end_tag
                                 ||l_cell_start_tag||l_value_start_tag
                                 ||l_run_by
                                 ||l_value_end_tag||l_cell_end_tag
                                 ||l_row_end_tag || l_table_end_tag
         ,p_message_type_cd  =>  l_label
         );

        -- Create Spacer Line
        create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_blank_line
         ,p_message_type_cd  =>  l_spacer
         );

      -- Hide for Plan Design Wizard
      IF l_copy_entity_txn.short_name <> 'BEN_PDCRWZ' THEN

        -- Insert Selected for Copy
        l_selected_for_copy_lbl := l_header_start_tag
                                   ||fnd_message.get_string('BEN','BEN_93283_PDC_SLCTD_FOR_COPY')
                                   ||l_header_end_tag;

        create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_selected_for_copy_lbl
         ,p_message_type_cd  =>  l_label
         );


        -- Create Spacer Line
        create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_blank_line||l_blank_line
         ,p_message_type_cd  =>  l_spacer
         );


        l_print_label := true;
        for r_cer in c_cer(p_copy_entity_txn_id,'PGM') loop
          if l_print_label = true then
            -- Programs
            create_process_log
              (p_module_cd        =>  l_module_cd
              ,p_txn_id           =>  p_copy_entity_txn_id
              ,p_message_text     =>  l_label_start_tag||l_pgm_label||l_label_end_tag||l_blank_line
              ,p_message_type_cd  =>  l_label
              );
              l_print_label := false;
            end if;

            create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer || r_cer.name ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
            );
        end loop;

        l_print_label := true;
        for r_cer in c_cer(p_copy_entity_txn_id,'PLNIP') loop
          if l_print_label = true then
            -- Plans
            create_process_log
              (p_module_cd        =>  l_module_cd
              ,p_txn_id           =>  p_copy_entity_txn_id
              ,p_message_text     =>  l_label_start_tag||l_pln_label||l_label_end_tag||l_blank_line
              ,p_message_type_cd  =>  l_label
              );
             l_print_label := false;
            end if;

            create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer || r_cer.name ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
            );
        end loop;

        -- Create Spacer Line
        create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_blank_line
         ,p_message_type_cd  =>  l_spacer
        );

      END IF;

        -- Insert Created the Following Objects
        l_created_objects_lbl := l_header_start_tag
                                 ||fnd_message.get_string('BEN','BEN_93284_PDC_CREATED_OBJECTS')
                                 ||l_header_end_tag;

        create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     =>  l_created_objects_lbl
         ,p_message_type_cd  =>  l_label
         );

        -- Create Spacer Line
        create_process_log
         (p_module_cd        =>  l_module_cd
         ,p_txn_id           =>  p_copy_entity_txn_id
         ,p_message_text     => l_blank_line||l_blank_line
         ,p_message_type_cd  =>  l_spacer
        );


        -- Programs
        if  ben_pd_copy_to_ben_one.g_pgm_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_pgm_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
             );

           for i in ben_pd_copy_to_ben_one.g_pgm_tbl_copied.first .. ben_pd_copy_to_ben_one.g_pgm_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_pgm_tbl_copied(i).new_name
                                     || l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Plan Types
         if  ben_pd_copy_to_ben_one.g_ptp_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_ptp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
             );

           for i in ben_pd_copy_to_ben_one.g_ptp_tbl_copied.first .. ben_pd_copy_to_ben_one.g_ptp_tbl_copied.last
           loop
             create_process_log
              (p_module_cd        =>  l_module_cd
              ,p_txn_id           =>  p_copy_entity_txn_id
              ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                      ||ben_pd_copy_to_ben_one.g_ptp_tbl_copied(i).new_name
                                      ||l_value_end_tag||l_blank_line
              ,p_message_type_cd  =>  l_value
              );
           end loop;
         end if;

         -- Plans
         if  ben_pd_copy_to_ben_one.g_pln_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_pln_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_pln_tbl_copied.first .. ben_pd_copy_to_ben_one.g_pln_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_pln_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Options
         if  ben_pd_copy_to_ben_one.g_opt_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_opt_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_opt_tbl_copied.first .. ben_pd_copy_to_ben_one.g_opt_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_opt_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Rates
         if  ben_pd_copy_to_ben_one.g_abr_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_abr_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );


           for i in ben_pd_copy_to_ben_one.g_abr_tbl_copied.first .. ben_pd_copy_to_ben_one.g_abr_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_abr_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;

	   --Added for Bug 6881417
	   if( nvl(length(ben_abr_bus.g_ssben_var),0) > 0) then
		   ben_abr_bus.g_ssben_var := substr(ben_abr_bus.g_ssben_var,0,length(ben_abr_bus.g_ssben_var)-1);
		   create_process_log
		     (p_module_cd        =>  l_module_cd
		     ,p_txn_id           =>  p_copy_entity_txn_id
		     ,p_message_text     =>  l_value_start_tag ||l_para_spacer
					     ||'Element and Input Value not copied for Rate Defintion(s) '||ben_abr_bus.g_ssben_var
					     ||l_value_end_tag||l_blank_line
		     ,p_message_type_cd  =>  l_value
		    );
           end if;
            --End of Code for Bug 6881417

         end if;

         -- Benefit Pools
         if  ben_pd_copy_to_ben_one.g_bpp_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_bpp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_bpp_tbl_copied.first .. ben_pd_copy_to_ben_one.g_bpp_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_bpp_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Actual Premiums
         if  ben_pd_copy_to_ben_one.g_apr_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_apr_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_apr_tbl_copied.first .. ben_pd_copy_to_ben_one.g_apr_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_apr_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Coverages
         if  ben_pd_copy_to_ben_one.g_ccm_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_ccm_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_ccm_tbl_copied.first .. ben_pd_copy_to_ben_one.g_ccm_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_ccm_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Coverage across Plan Types
         if  ben_pd_copy_to_ben_one.g_acp_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_acp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_acp_tbl_copied.first .. ben_pd_copy_to_ben_one.g_acp_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_acp_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;


         -- Life Events
         if  ben_pd_copy_to_ben_one.g_ler_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_ler_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_ler_tbl_copied.first .. ben_pd_copy_to_ben_one.g_ler_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_ler_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Life Events(Person Change)
         if  ben_pd_copy_to_ben_one.g_psl_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_psl_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_psl_tbl_copied.first .. ben_pd_copy_to_ben_one.g_psl_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_psl_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Eligibility profiles
         if  ben_pd_copy_to_ben_one.g_elp_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_elp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_elp_tbl_copied.first .. ben_pd_copy_to_ben_one.g_elp_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_elp_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Dependent Eligibility profiles
         if  ben_pd_copy_to_ben_one.g_dce_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_dce_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_dce_tbl_copied.first .. ben_pd_copy_to_ben_one.g_dce_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_dce_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Variable Rate Profiles
         if  ben_pd_copy_to_ben_one.g_vpf_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_vpf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_vpf_tbl_copied.first .. ben_pd_copy_to_ben_one.g_vpf_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_vpf_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;
         --
         -- Bug 4169120 : Rate By Criteria
         -- Eligibility Criteria
         --
         if  ben_pd_copy_to_ben_one.g_egl_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_egl_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_egl_tbl_copied.first .. ben_pd_copy_to_ben_one.g_egl_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_egl_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;
         --
         -- Benefit Balances
         if  ben_pd_copy_to_ben_one.g_bnb_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_bnb_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_bnb_tbl_copied.first .. ben_pd_copy_to_ben_one.g_bnb_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_bnb_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Comp Level Factor
         if  ben_pd_copy_to_ben_one.g_clf_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_clf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_clf_tbl_copied.first .. ben_pd_copy_to_ben_one.g_clf_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_clf_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Hours Worked Factor
         if  ben_pd_copy_to_ben_one.g_hwf_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_hwf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_hwf_tbl_copied.first .. ben_pd_copy_to_ben_one.g_hwf_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_hwf_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Age Factor
         if  ben_pd_copy_to_ben_one.g_agf_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_agf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_agf_tbl_copied.first .. ben_pd_copy_to_ben_one.g_agf_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_agf_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Length of Service Factor
         if  ben_pd_copy_to_ben_one.g_lsf_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_lsf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_lsf_tbl_copied.first .. ben_pd_copy_to_ben_one.g_lsf_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_lsf_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Percent Full Time factor
         if  ben_pd_copy_to_ben_one.g_pff_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_pff_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_pff_tbl_copied.first .. ben_pd_copy_to_ben_one.g_pff_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_pff_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Combined LOS and Age Factor
         if  ben_pd_copy_to_ben_one.g_cla_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_cla_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_cla_tbl_copied.first .. ben_pd_copy_to_ben_one.g_cla_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_cla_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Regulations
         if  ben_pd_copy_to_ben_one.g_reg_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_reg_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_reg_tbl_copied.first .. ben_pd_copy_to_ben_one.g_reg_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_reg_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Reporting Groups
         if  ben_pd_copy_to_ben_one.g_bnr_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_bnr_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_bnr_tbl_copied.first .. ben_pd_copy_to_ben_one.g_bnr_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_bnr_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Benefits Group
         if  ben_pd_copy_to_ben_one.g_bng_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_bng_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_bng_tbl_copied.first .. ben_pd_copy_to_ben_one.g_bng_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_bng_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Goods or services
         if  ben_pd_copy_to_ben_one.g_gos_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_gos_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_gos_tbl_copied.first .. ben_pd_copy_to_ben_one.g_gos_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_gos_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Period To Date Limits
         if  ben_pd_copy_to_ben_one.g_pdl_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_pdl_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_pdl_tbl_copied.first .. ben_pd_copy_to_ben_one.g_pdl_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_pdl_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Service Area
         if  ben_pd_copy_to_ben_one.g_sva_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_sva_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_sva_tbl_copied.first .. ben_pd_copy_to_ben_one.g_sva_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_sva_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;


         /*
         -- Action Types
         if  ben_pd_copy_to_ben_one.g_eat_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_eat_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_eat_tbl_copied.first .. ben_pd_copy_to_ben_one.g_eat_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_eat_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;
         */

         -- Combination PLIP
         if  ben_pd_copy_to_ben_one.g_cpl_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_cpl_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_cpl_tbl_copied.first .. ben_pd_copy_to_ben_one.g_cpl_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_cpl_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Combination PTIP
         if  ben_pd_copy_to_ben_one.g_cbp_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_cbp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_cbp_tbl_copied.first .. ben_pd_copy_to_ben_one.g_cbp_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_cbp_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Combination PTIP OPT
         if  ben_pd_copy_to_ben_one.g_cpt_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_cpt_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_cpt_tbl_copied.first .. ben_pd_copy_to_ben_one.g_cpt_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_cpt_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Fast Formulas
         if  ben_pd_copy_to_ben_one.g_fff_tbl_copied_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_fff_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_fff_tbl_copied.first .. ben_pd_copy_to_ben_one.g_fff_tbl_copied.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_fff_tbl_copied(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Create Spacer Line
         create_process_log
          (p_module_cd        =>  l_module_cd
          ,p_txn_id           =>  p_copy_entity_txn_id
          ,p_message_text     =>  l_blank_line
          ,p_message_type_cd  =>  l_spacer
         );

       -- Hide for Plan Design Wizard
       IF l_copy_entity_txn.short_name <> 'BEN_PDCRWZ' THEN

         -- Insert 'Reused the Following Objects'
         l_reused_objects_lbl := l_header_start_tag || fnd_message.get_string('BEN','BEN_93285_PDC_REUSED_OBJECTS')
                                 ||l_header_end_tag;

         create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_reused_objects_lbl
             ,p_message_type_cd  =>  l_label
             );

         -- Create Spacer Line
         create_process_log
          (p_module_cd        =>  l_module_cd
          ,p_txn_id           =>  p_copy_entity_txn_id
          ,p_message_text     =>  l_blank_line||l_blank_line
          ,p_message_type_cd  =>  l_spacer
          );

         -- Programs
         if  ben_pd_copy_to_ben_one.g_pgm_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_pgm_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_pgm_tbl_reused.first .. ben_pd_copy_to_ben_one.g_pgm_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_pgm_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Plan Types
         if  ben_pd_copy_to_ben_one.g_ptp_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_ptp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_ptp_tbl_reused.first .. ben_pd_copy_to_ben_one.g_ptp_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_ptp_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Plans
         if  ben_pd_copy_to_ben_one.g_pln_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_pln_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_pln_tbl_reused.first .. ben_pd_copy_to_ben_one.g_pln_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_pln_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Options
         if  ben_pd_copy_to_ben_one.g_opt_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_opt_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_opt_tbl_reused.first .. ben_pd_copy_to_ben_one.g_opt_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_opt_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Rates
         if  ben_pd_copy_to_ben_one.g_abr_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_abr_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_abr_tbl_reused.first .. ben_pd_copy_to_ben_one.g_abr_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_abr_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Benefit Pools
         if  ben_pd_copy_to_ben_one.g_bpp_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_bpp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_bpp_tbl_reused.first .. ben_pd_copy_to_ben_one.g_bpp_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_bpp_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Actual Premiums
         if  ben_pd_copy_to_ben_one.g_apr_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_apr_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_apr_tbl_reused.first .. ben_pd_copy_to_ben_one.g_apr_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_apr_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Coverages
         if  ben_pd_copy_to_ben_one.g_ccm_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_ccm_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_ccm_tbl_reused.first .. ben_pd_copy_to_ben_one.g_ccm_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_ccm_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Coverage across Plan Types
         if  ben_pd_copy_to_ben_one.g_acp_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_acp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_acp_tbl_reused.first .. ben_pd_copy_to_ben_one.g_acp_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_acp_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Life Events
         if  ben_pd_copy_to_ben_one.g_ler_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_ler_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_ler_tbl_reused.first .. ben_pd_copy_to_ben_one.g_ler_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_ler_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;


         -- Life Events(Person Changes)
         if  ben_pd_copy_to_ben_one.g_psl_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_psl_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_psl_tbl_reused.first .. ben_pd_copy_to_ben_one.g_psl_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_psl_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Eligibility profiles
         if  ben_pd_copy_to_ben_one.g_elp_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_elp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_elp_tbl_reused.first .. ben_pd_copy_to_ben_one.g_elp_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_elp_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Dependent Eligibility profiles
         if  ben_pd_copy_to_ben_one.g_dce_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_dce_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_dce_tbl_reused.first .. ben_pd_copy_to_ben_one.g_dce_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_dce_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Variable Rate Profiles
         if  ben_pd_copy_to_ben_one.g_vpf_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_vpf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_vpf_tbl_reused.first .. ben_pd_copy_to_ben_one.g_vpf_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_vpf_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;
         --
         -- Bug 4169120 : Rate By Criteria
         -- Eligibility Criteria
         --
         if  ben_pd_copy_to_ben_one.g_egl_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_egl_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_egl_tbl_reused.first .. ben_pd_copy_to_ben_one.g_egl_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_egl_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;
         --
         -- Benefit Balances
         if  ben_pd_copy_to_ben_one.g_bnb_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_bnb_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_bnb_tbl_reused.first .. ben_pd_copy_to_ben_one.g_bnb_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_bnb_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Comp Level Factor
         if  ben_pd_copy_to_ben_one.g_clf_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_clf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_clf_tbl_reused.first .. ben_pd_copy_to_ben_one.g_clf_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_clf_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Hours Worked Factor
         if  ben_pd_copy_to_ben_one.g_hwf_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_hwf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_hwf_tbl_reused.first .. ben_pd_copy_to_ben_one.g_hwf_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_hwf_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Age Factor
         if  ben_pd_copy_to_ben_one.g_agf_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_agf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_agf_tbl_reused.first .. ben_pd_copy_to_ben_one.g_agf_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_agf_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Length of Service Factor
         if  ben_pd_copy_to_ben_one.g_lsf_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_lsf_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_lsf_tbl_reused.first .. ben_pd_copy_to_ben_one.g_lsf_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_lsf_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Percent Full Time factor
         if  ben_pd_copy_to_ben_one.g_pff_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_pff_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_pff_tbl_reused.first .. ben_pd_copy_to_ben_one.g_pff_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_pff_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Combined LOS and Age Factor
         if  ben_pd_copy_to_ben_one.g_cla_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_cla_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_cla_tbl_reused.first .. ben_pd_copy_to_ben_one.g_cla_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_cla_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Regulations
         if  ben_pd_copy_to_ben_one.g_reg_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_reg_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_reg_tbl_reused.first .. ben_pd_copy_to_ben_one.g_reg_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_reg_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Reporting Groups
         if  ben_pd_copy_to_ben_one.g_bnr_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_bnr_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_bnr_tbl_reused.first .. ben_pd_copy_to_ben_one.g_bnr_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_bnr_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Benefits Group
         if  ben_pd_copy_to_ben_one.g_bng_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_bng_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_bng_tbl_reused.first .. ben_pd_copy_to_ben_one.g_bng_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_bng_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Goods or services
         if  ben_pd_copy_to_ben_one.g_gos_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_gos_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_gos_tbl_reused.first .. ben_pd_copy_to_ben_one.g_gos_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_gos_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Period To Date Limits
         if  ben_pd_copy_to_ben_one.g_pdl_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_pdl_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_pdl_tbl_reused.first .. ben_pd_copy_to_ben_one.g_pdl_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_pdl_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Service Area
         if  ben_pd_copy_to_ben_one.g_sva_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_sva_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_sva_tbl_reused.first .. ben_pd_copy_to_ben_one.g_sva_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_sva_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;


         /*
         -- Action Types
         if  ben_pd_copy_to_ben_one.g_eat_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_eat_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_eat_tbl_reused.first .. ben_pd_copy_to_ben_one.g_eat_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_eat_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;
         */

         -- Combination PLIP
         if  ben_pd_copy_to_ben_one.g_cpl_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_cpl_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_cpl_tbl_reused.first .. ben_pd_copy_to_ben_one.g_cpl_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_cpl_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Combination PTIP
         if  ben_pd_copy_to_ben_one.g_cbp_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_cbp_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_cbp_tbl_reused.first .. ben_pd_copy_to_ben_one.g_cbp_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_cbp_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Combination PTIP OPT
         if  ben_pd_copy_to_ben_one.g_cpt_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_cpt_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_cpt_tbl_reused.first .. ben_pd_copy_to_ben_one.g_cpt_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_cpt_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Fast Formulas
         if  ben_pd_copy_to_ben_one.g_fff_tbl_reused_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_label_start_tag||l_fff_label||l_label_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_label
            );

           for i in ben_pd_copy_to_ben_one.g_fff_tbl_reused.first .. ben_pd_copy_to_ben_one.g_fff_tbl_reused.last
           loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag ||l_para_spacer
                                     ||ben_pd_copy_to_ben_one.g_fff_tbl_reused(i).new_name
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Create Spacer Line
         create_process_log
          (p_module_cd        =>  l_module_cd
          ,p_txn_id           =>  p_copy_entity_txn_id
          ,p_message_text     =>  l_blank_line
          ,p_message_type_cd  =>  l_spacer
         );

         -- LOG NOMAPPING data

         if  ben_pd_copy_to_ben_three.g_not_copied_tbl_count > 0 then
           create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_header_start_tag
                                     ||fnd_message.get_string('BEN','BEN_93286_PDC_NOT_COPIED_OBJ')
                                     ||l_header_end_tag
             ,p_message_type_cd  =>  l_label
           );

         -- Create Spacer Line
         create_process_log
          (p_module_cd        =>  l_module_cd
          ,p_txn_id           =>  p_copy_entity_txn_id
          ,p_message_text     =>  l_blank_line||l_blank_line
          ,p_message_type_cd  =>  l_spacer
          );


          for i in ben_pd_copy_to_ben_three.g_not_copied_tbl.first .. ben_pd_copy_to_ben_three.g_not_copied_tbl.last
          loop
             create_process_log
             (p_module_cd        =>  l_module_cd
             ,p_txn_id           =>  p_copy_entity_txn_id
             ,p_message_text     =>  l_value_start_tag
                                     ||ben_pd_copy_to_ben_three.g_not_copied_tbl(i).text
                                     ||l_value_end_tag||l_blank_line
             ,p_message_type_cd  =>  l_value
             );
           end loop;
         end if;

         -- Create Spacer Line
         create_process_log
          (p_module_cd        =>  l_module_cd
          ,p_txn_id           =>  p_copy_entity_txn_id
          ,p_message_text     =>  l_blank_line
          ,p_message_type_cd  =>  l_spacer
         );

      END IF;

  end create_log;

    -- 5097567 Added the following procedure
    -- ----------------------------------------------------------------------------
    -- |--------------------< submit_pd_and_compile_ff >--------------------------|
    -- ----------------------------------------------------------------------------
    -- This procedure is called in PDW flow to submit the Request Set
    -- First Stage, submit 'Plan Copy Submit Process'.
    -- Second Stage, submit 'Fast Formula Compilation Process'.
    --
   PROCEDURE submit_pd_and_compile_ff (
      p_validate                   IN              NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN              NUMBER,
      p_effective_date             IN              VARCHAR2,
      p_prefix_suffix_text         IN              VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN              VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN              VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN              VARCHAR2 DEFAULT NULL,
      p_effective_date_to_copy     IN              VARCHAR2 DEFAULT NULL,
      p_request_id                 OUT NOCOPY      NUMBER
     )
   IS
    --
    l_success               boolean;
    l_submit_failed         exception;
    l_proc                  varchar2(80) := g_package ||'submit_pd_and_compile_ff';
    l_request_id            number;
    --
    BEGIN
    --
    g_debug := hr_utility.debug_enabled;
    if (g_debug) then
        hr_utility.set_location(' Entering ' ||l_proc,10);
        hr_utility.set_location(' submit req.set BENPDSBMTCMPFF',10);
    end if;
    l_request_id := p_request_id;
    --
    l_success := fnd_submit.set_request_set
                     (application => 'BEN',
                      request_set => 'BENPDSBMTCMPFF');
    --
    if l_success then
        --
        if (g_debug) then
            hr_utility.set_location(' submit pgm BEPDCPRC',10);
        end if;
        --
        l_success := fnd_submit.submit_program
                    (application => 'BEN'
                    ,program     => 'BEPDCPRC'
                    ,stage       => 'STAGE10'
                    ,argument1   => p_validate
                    ,argument2   => p_copy_entity_txn_id
                    ,argument3   => p_effective_date
                    ,argument4   => p_prefix_suffix_text
                    ,argument5   => p_reuse_object_flag
                    ,argument6   => p_target_business_group_id
                    ,argument7   => p_prefix_suffix_cd
                    ,argument8   => p_effective_date_to_copy
                    );
        --
        if not l_success then
            raise l_submit_failed;
        end if;
        --
        if (g_debug) then
            hr_utility.set_location(' submit pgm BEPDCCF',10);
        end if;
        --
        l_success := fnd_submit.submit_program
                    (application => 'BEN'
                    ,program     => 'BEPDCMFF'
                    ,stage       => 'STAGE20'
                    ,argument1   => p_copy_entity_txn_id
                    ,argument2   => p_effective_date
                    );
        --
        if not l_success then
            raise l_submit_failed;
        end if;
        --
        if (g_debug) then
            hr_utility.set_location(' submit set',10);
        end if;
        --
        l_request_id := fnd_submit.submit_set(null,FALSE);
        --
    end if;
    --
    p_request_id := l_request_id;
    --
    EXCEPTION
        WHEN l_submit_failed THEN
             fnd_message.set_name('BEN','BEN_94215_PDC_ERR_CONC_PROG');
             fnd_message.raise_error ;
        --
        WHEN others THEN
             fnd_message.set_name('PER','PER_IN_ORACLE_GENERIC_ERROR');
             fnd_message.set_token('FUNCTION',l_proc);
             fnd_message.set_token('SQLERRM',SQLERRM);
             fnd_message.raise_error ;
        --
   END submit_pd_and_compile_ff;
--
--
procedure submit_copy_request
 (
   p_validate                 in number        default 0 -- false
  ,p_copy_entity_txn_id       in  number
  ,p_request_id               out nocopy number
 ) is

   cursor c_copy_entity_txn is
   select  cet.process_name process_name
          ,to_char(cet.src_effective_date,'DD/MM/YYYY') src_effective_date
          ,cet.src_effective_date    effective_date
          ,cet.target_typ_cd     target_typ_cd
          ,cet.row_type_cd       row_type_cd              /* Bug 4278495 */
          ,cet.export_file_name
          ,cet.prefix_suffix_text
          ,cet.prefix_suffix_cd
          ,cet.reuse_object_flag
          ,cet.target_business_group_id
          ,cet.cet_object_version_number
          ,cet.action_date
          ,cet.sfl_step_name
          ,tcg.short_name
   from    ben_copy_entity_txns_vw cet,
           pqh_transaction_categories tcg
   where   cet.copy_entity_txn_id = p_copy_entity_txn_id
   and     cet.transaction_category_id = tcg.transaction_category_id;

   cursor c_chk_selection(c_copy_entity_txn_id in number
                         ,c_number_of_copies   in number)
   is
   select null
   from ben_copy_entity_results cer
   where copy_entity_txn_id = c_copy_entity_txn_id
   and information8 is not null
   and number_of_copies = c_number_of_copies
   and rownum = 1;
   --
   cursor c_fff is
    select null
    from ben_copy_entity_results cpe
    where cpe.copy_entity_txn_id = p_copy_entity_txn_id
    and cpe.table_alias = 'FFF'
    and cpe.number_of_copies = 1
    and cpe.dml_operation in ('INSERT','UPDATE')
    and (cpe.datetrack_mode IN ('INSERT','CORRECTION')
        or cpe.datetrack_mode like 'UPDATE%');

   --
    cursor c_cea is
    select copy_entity_attrib_id, object_version_number
      from pqh_copy_entity_attribs cea
     where copy_entity_txn_id = p_copy_entity_txn_id;
    --

   l_copy_entity_txn            c_copy_entity_txn%rowtype;
   l_process_name               ben_copy_entity_txns_vw.process_name%type;
   l_target_type_cd             ben_copy_entity_txns_vw.target_typ_cd%type;
   l_src_effective_date         varchar2(15);
   l_export_file_name           ben_copy_entity_txns_vw.export_file_name%type;

   l_request_id                 number := null;
   l_mode_param                 varchar2(50) := 'DOWNLOAD';
   l_loader_config_param        varchar2(50) := '@ben:/patch/115/import/bencer.lct';
   l_entity_param               varchar2(50) := 'PQH_COPY_ENTITY_TXNS';
   l_proc                       varchar2(72) := g_package||'submit_copy_request';
   l_display_name_param         varchar2(50) := 'DISPLAY_NAME=';
   l_src_effective_date_param   varchar2(50) := 'SRC_EFFECTIVE_DATE=';
   l_dummy                      varchar2(1);
   --
   l_encoded_message            varchar2(2000);
   l_app_short_name             varchar2(2000);
   l_message_name               varchar2(2000);
   -- REUSE
   l_reuse_object_flag          varchar2(30) := null;
   l_second_request_id          number ;
   --
   l_start_with                 pqh_copy_entity_txns.start_with%type;
   l_status                     varchar2(50) := null;

--TCS PDW Integration ENH
   l_errbuff                    varchar2(2000);
   l_return_cd		            number;
--TCS PDW Integration ENH
   l_cea                        c_cea%rowtype;
   l_compile_ff                 boolean := false;
   --
begin
  --
  fnd_msg_pub.initialize;
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint SUBMIT_COPY_REQUEST;
  --
  hr_utility.set_location(l_proc, 20);
  --

--Perform the following check only for PDW or PDC
 --TCS PDW Integration ENH
if l_copy_entity_txn.ROW_TYPE_CD in ('PDW','PDC') then
  open c_chk_selection(p_copy_entity_txn_id,1);
  fetch c_chk_selection into l_dummy;
  if c_chk_selection%notfound then
    close c_chk_selection;
    fnd_message.set_name('BEN','BEN_93211_PDC_SELECT_OBJECT_ER');
    fnd_message.raise_error;
  end if;
  close c_chk_selection;
end if;
--TCS PDW Integration ENH

  open c_copy_entity_txn;
  fetch c_copy_entity_txn into l_copy_entity_txn ;
  close c_copy_entity_txn;

  if l_copy_entity_txn.target_typ_cd = 'BEN_PDFILE' then -- Export to File
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    l_request_id := fnd_request.submit_request
                       (application => 'BEN'
                       ,program     => 'BENPDCDL'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => l_mode_param
                       ,argument2   => l_loader_config_param
                       ,argument3   => l_copy_entity_txn.export_file_name
                       ,argument4   => l_entity_param
                       ,argument5   => l_display_name_param||l_copy_entity_txn.process_name
                       ,argument6   => l_src_effective_date_param||l_copy_entity_txn.src_effective_date);
    --
    -- p_request_id := l_request_id;
    -- Update status call here
    l_second_request_id := fnd_request.submit_request
                       (application => 'BEN'
                       ,program     => 'BENPDDLS'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => l_request_id
                       ,argument2   => p_copy_entity_txn_id );
    --
  elsif  l_copy_entity_txn.target_typ_cd in ('BEN_PDDFBG','BEN_PDSMBG','BEN_PDIMPT') then

    --
    -- Copy to Same/Diff Business Group
    --
    --
    -- REUSE ENHANCEMENT
    l_reuse_object_flag := l_copy_entity_txn.reuse_object_flag;
    if l_copy_entity_txn.reuse_object_flag = 'YO' then
       --
       g_pgm_pl_prefix_suffix_text := l_copy_entity_txn.prefix_suffix_text;
       l_copy_entity_txn.prefix_suffix_text := null;
       --
       l_reuse_object_flag := 'Y';
    end if;
    --

    if l_copy_entity_txn.ROW_TYPE_CD in ('PDW','PDC') then

      --
      -- PDC:Change the status of transaction to "Copy In Progress" to prevent user from
      -- continuing / restarting the process before Conc Prog finishes which will set
      -- the status to COMPLETE / ERROR
      --
      -- PDW:Change the status of transaction to "Submit In Progress" to prevent user from
      -- continuing / restarting the process before Conc Prog finishes which will set
      -- the status to COMPLETE / ERROR
        l_compile_ff := false;

        if l_copy_entity_txn.ROW_TYPE_CD = 'PDC' then
            l_status := 'COPY_IN_PROGRESS';
        elsif l_copy_entity_txn.ROW_TYPE_CD = 'PDW' then
            --
            l_status := 'SUBMIT_IN_PROGRESS';
            -- 5097567 Check if FFF rows exist that need to be compiled
            open c_fff;
            fetch c_fff into l_dummy;
            if c_fff%found then
                l_compile_ff := true;
            end if;
       end if;
       --
        pqh_copy_entity_txns_api.update_COPY_ENTITY_TXN
            (p_copy_entity_txn_id            => p_copy_entity_txn_id
            ,p_datetrack_mode                => hr_api.g_correction
            ,p_status                        => l_status
            ,p_start_with                    => NULL   /* To disable Continue Icon */
            ,p_object_version_number         => l_copy_entity_txn.cet_object_version_number
            ,p_effective_date                => trunc(l_copy_entity_txn.effective_date)
            );
        --
        if (l_copy_entity_txn.ROW_TYPE_CD = 'PDC' OR NOT l_compile_ff) then
            --
            -- Submit Conc Prog "Copy Plan Design Process"
            --
            l_request_id := fnd_request.submit_request
                             (application => 'BEN'
                             ,program     => 'BEPDCPRC'
                             ,description => NULL
                             ,sub_request => FALSE
                             ,argument1   => p_validate
                             ,argument2   => p_copy_entity_txn_id
                             ,argument3   => to_char(l_copy_entity_txn.effective_date, 'DD-MM-YYYY')
                             ,argument4   => l_copy_entity_txn.prefix_suffix_text
                             ,argument5   => l_reuse_object_flag
                             ,argument6   => l_copy_entity_txn.target_business_group_id
                             ,argument7   => l_copy_entity_txn.prefix_suffix_cd
                             ,argument8   => to_char(l_copy_entity_txn.action_date, 'DD-MM-YYYY')
                             );
            --
        else
            -- 5097567 If FF Exists, compile the FF after succesful copying.
            --
            submit_pd_and_compile_ff
                (p_validate                   => p_validate
                ,p_copy_entity_txn_id         => p_copy_entity_txn_id
                ,p_effective_date             => to_char(l_copy_entity_txn.effective_date, 'DD-MM-YYYY')
                ,p_prefix_suffix_text         => l_copy_entity_txn.prefix_suffix_text
                ,p_reuse_object_flag          => l_reuse_object_flag
                ,p_target_business_group_id   => l_copy_entity_txn.target_business_group_id
                ,p_prefix_suffix_cd           => l_copy_entity_txn.prefix_suffix_cd
                ,p_effective_date_to_copy     => to_char(l_copy_entity_txn.action_date, 'DD-MM-YYYY')
                ,p_request_id                 => l_request_id
                );
            --
            -- 5097567 Changes End
            --
       end if;
      --
      if l_request_id = 0
      then
        --
        fnd_message.set_name('BEN', 'BEN_94215_PDC_ERR_CONC_PROG');
        fnd_message.raise_error;
	--
      end if;
      --
--TCS PDW Integration ENH
    elsif(l_copy_entity_txn.ROW_TYPE_CD = 'ELP') then

       BEN_PLAN_DESIGN_COPY_PROCESS.process (
          errbuf                       => l_errbuff,
          retcode                      => l_return_cd,
          p_copy_entity_txn_id         => p_copy_entity_txn_id,
          p_effective_date             => to_char(l_copy_entity_txn.effective_date, 'DD-MM-YYYY'),
          p_prefix_suffix_text         => l_copy_entity_txn.prefix_suffix_text,
          p_reuse_object_flag          => l_reuse_object_flag,
          p_target_business_group_id   => l_copy_entity_txn.target_business_group_id,
          p_prefix_suffix_cd           => l_copy_entity_txn.prefix_suffix_cd,
          p_effective_date_to_copy     => to_char(l_copy_entity_txn.action_date, 'DD-MM-YYYY')
       );
       --
        l_compile_ff := false;
        --
        open c_fff;
        fetch c_fff into l_dummy;
        if c_fff%found then
            l_compile_ff := true;
        end if;
        --
        if (l_compile_ff) then
            --
            l_request_id := fnd_request.submit_request
                               (application => 'BEN'
                               ,program     => 'BEPDCMFF'
                               ,description => NULL
                               ,sub_request => FALSE
                               ,argument1   => p_copy_entity_txn_id
                               ,argument2   => to_char(l_copy_entity_txn.effective_date, 'DD-MM-YYYY'));
            --

        end if;

--TCS PDW Integration ENH
    end if;
    --
    if (l_request_id <> 0) then
        --
        open c_cea;
        fetch c_cea into l_cea ;
        if c_cea%found then
            --
            hr_utility.set_location('l_cea.copy_entity_attrib_id ' || l_cea.copy_entity_attrib_id, 10);
            hr_utility.set_location('l_cea.ovn' || l_cea.object_version_number, 10);
            --
            -- Update Request Set Id into Information14 column of PQH_COPY_ENTITY_ATTRIBS table.
            pqh_copy_entity_attribs_api.update_copy_entity_attrib
                (p_copy_entity_attrib_id      => l_cea.copy_entity_attrib_id
                ,p_object_version_number      => l_cea.object_version_number
                ,p_effective_date             => trunc(l_copy_entity_txn.effective_date)
                ,p_information14              => TO_CHAR(l_request_id)
                );
        end if;
        close c_cea;
        commit;
        --
    end if;
    -- Bug 4278495
    --
    hr_utility.set_location('After call to CET Update',200);
    --
    g_pgm_pl_prefix_suffix_text := null;
    --
  end if;

  p_request_id := l_request_id;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate  = 1 then -- p_validate is true
    raise hr_API.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_API.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO SUBMIT_COPY_REQUEST;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_request_id := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when app_exception.application_exception then

    fnd_msg_pub.add;

    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO SUBMIT_COPY_REQUEST;
    raise;
    --
end submit_copy_request;
--

--
--
--Mapping Page
--
procedure get_required_mapping_completed(p_copy_entity_txn_id in number
                                        ,p_required_mapping out nocopy varchar2) is

required_mapping varchar2(10)  :='true';
cursor c_required_mapping_completed(p_copy_entity_txn_id number) is
 select table_route_id
 from ben_copy_entity_results
 where copy_entity_txn_id = p_copy_entity_txn_id
   and information174 is not null
   and table_route_id in (select table_route_id
                          from pqh_table_route
                          where where_clause in('BEN_HRS_WKD_IN_PERD_FCTR',
                                                 -- 'BEN_POPL_ORG_F',
                                                 'BEN_COMP_LVL_FCTR',
						 'BEN_ENRT_PERD'));   -- Bug No 4498668
--
 cursor c_table_name (p_table_route_id number) is
 select display_name
 from pqh_table_route
 where table_route_id = p_table_route_id;

 l_table_name pqh_table_route.display_name%type;
--
begin
     p_required_mapping := ' ';
     --
     for l_rec in c_required_mapping_completed(p_copy_entity_txn_id)
     --
     loop
        --
        if (ben_plan_design_txns_api.get_mapping_info
              ('CompletedInfo',
                l_rec.table_route_id,
                p_copy_entity_txn_id)='NotCompleted') then
           open c_table_name(l_rec.table_route_id);
           fetch c_table_name into l_table_name;
           close c_table_name;
           --
           if(instr( p_required_mapping,l_table_name)=0) then
              p_required_mapping := p_required_mapping || l_table_name || ', ';
           end if;
           --
        end if;
        --
     end loop;
     --
  p_required_mapping := substr(p_required_mapping,1,length(p_required_mapping)-2);
end get_required_mapping_completed;

--
procedure get_mapping_column_name(p_table_route_id in number
                                 ,p_mapping_colum_name1 out nocopy varchar2
                                 ,p_mapping_colum_name2 out nocopy varchar2
                                 ,p_copy_entity_txn_id in number)is
   --
   cursor c_column_name(p_table_route_id number)is
     select attribute_name,refresh_col_name  -- 3330990
     from pqh_attributes_vl att
     where  enable_flag = 'Y'
     and master_table_route_id = p_table_route_id;

   --
begin
   --
   --Set out variables
   --
   for l_rec in c_column_name (p_table_route_id) loop
     --
     if(l_rec.refresh_col_name ='N' or l_rec.refresh_col_name is null) then
     --if(l_rec.refresh_col_name ='N' ) then
        p_mapping_colum_name1 := l_rec.attribute_name;
     else
        p_mapping_colum_name2 := l_rec.attribute_name;
     end if;
     --
   end loop;
   --
end get_mapping_column_name;
--
  procedure update_download_status(
     errbuf                     out nocopy varchar2
    ,retcode                    out nocopy number
    ,p_request_id                in number
    ,p_copy_entity_txn_id        in number
  )
    is
    l_phase            varchar2(240);
    l_status           varchar2(240);
    l_dev_phase        varchar2(100);
    l_dev_status       varchar2(100);
    l_message          varchar2(2000);
    l_outcome          boolean ;
    l_txn_status       varchar2(100);
    l_ovn              number ;
    l_effective_date   date;
    cursor c_copy_entity_txn is
    select  cet.src_effective_date    effective_date
           ,cet.cet_object_version_number
           ,cet.sfl_step_name
    from    ben_copy_entity_txns_vw cet
    where   cet.copy_entity_txn_id = p_copy_entity_txn_id ;
    --
    l_start_with                pqh_copy_entity_txns.start_with%type;
  begin
    --
    l_outcome :=
    fnd_concurrent.wait_for_request(
       request_id        => p_request_id
      ,interval          => 5
      ,max_wait          => 36000   -- 10 Minutes
      ,phase             => l_phase
      ,status            => l_status
      ,dev_phase         => l_dev_phase
      ,dev_status        => l_dev_status
      ,message           => l_message
      );
    --
    hr_utility.set_location(' p_request_id '||p_request_id,99);
    hr_utility.set_location(' p_copy_entity_txn_id '||p_copy_entity_txn_id,99);
    hr_utility.set_location(' l_phase '||l_phase,99);
    hr_utility.set_location(' l_status '||l_status,99);
    hr_utility.set_location(' l_dev_status '||l_dev_status,99);
    hr_utility.set_location(' l_dev_phase  '||l_dev_phase ,99);
    hr_utility.set_location(' l_message '||l_message,99);
    --

    open c_copy_entity_txn ;
    fetch c_copy_entity_txn into l_effective_date,l_ovn,l_start_with;
    close c_copy_entity_txn ;

    if l_dev_status = 'ERROR' then
      --
      l_txn_status := l_dev_status ;
      --
    elsif l_dev_status = 'NORMAL' then
      --
      l_txn_status := 'COMPLETE' ;
      l_start_with := 'BEN_PDC_SLCT_TRGT_PAGE';
      --
    elsif l_dev_status in ( 'CANCELLED' , 'TERMINATED','DELETED' ) then
      --
      l_txn_status := 'INTERRUPTED' ;
      --
    else
      --
      l_txn_status := 'ERROR' ;
      --
    end if;
    --
    hr_utility.set_location(' l_txn_status '||l_txn_status,99);
    --
    --
    hr_utility.set_location('Before call to CET Update',100);
    --
      pqh_copy_entity_txns_api.update_COPY_ENTITY_TXN
      (
       p_copy_entity_txn_id            => p_copy_entity_txn_id
      ,p_datetrack_mode                => hr_api.g_correction
      ,p_status                        => l_txn_status
      ,p_start_with                    => l_start_with
      ,p_object_version_number         => l_ovn
      ,p_effective_date                => l_effective_date
      );
    --
    hr_utility.set_location('After call to CET Update',200);
    --
  end update_download_status ;
  --

  function get_log_display(p_copy_entity_txn_id in number
                          ,p_status             in varchar2
                          ,p_target_typ_cd      in varchar2)
    return varchar2 is

    cursor c_log_exists(c_copy_entity_txn_id number) is
      select null
      from pqh_process_log
      where txn_id = c_copy_entity_txn_id
      and module_cd = 'PDC_CP'
      and rownum = 1;

    l_dummy varchar2(1);
    l_return_val varchar2(100);
    --
  begin

    if p_status in ('COMPLETE', 'PURGED')  and p_target_typ_cd <> 'BEN_PDFILE' then
      /* Bug 4306331 Added PURGED */
      open c_log_exists(p_copy_entity_txn_id);
      fetch c_log_exists into l_dummy;
      if c_log_exists%notfound then
        l_return_val := 'LogDisabled';
      else
        l_return_val := 'LogEnabled';
      end if;

    else
      l_return_val := 'LogDisabled';
    end if;
    return l_return_val;
   --
  end get_log_display;

procedure write_txn_table_route(p_copy_entity_txn_id in number)
is
  pragma AUTONOMOUS_TRANSACTION;
 cursor tr is select table_route_id,display_name,table_alias
   from pqh_table_route
   where from_clause ='OAB'
   and table_alias in ( select distinct table_alias from ben_copy_entity_results
  where copy_entity_txn_id = p_copy_entity_txn_id
  and table_route_id is null);

begin
   for i in tr loop
      update ben_copy_entity_results
      set table_route_id = i.table_route_id
      where copy_entity_txn_id = p_copy_entity_txn_id
      and table_alias = i.table_alias;
   end loop;
   -- commit the autonomous transaction
   commit;
exception
  when others then
  rollback;
  raise;
end  write_txn_table_route;

procedure pdw_submit_copy_request(
  p_validate                 in  number     default 0 -- false
 ,p_copy_entity_txn_id       in  number
 ,p_request_id               out nocopy number
)
is
begin
-- write the table_route_id
write_txn_table_route(p_copy_entity_txn_id);

  submit_copy_request(
  p_validate => p_validate
 ,p_copy_entity_txn_id => p_copy_entity_txn_id
 ,p_request_id =>  p_request_id
);

end pdw_submit_copy_request;

--
-- Bug 4281567 Procedure to purge PDC processes from concurrent request
--
procedure purge_plan_design_process(
  errbuf                     out nocopy varchar2      --needed by concurrent manager.
 ,retcode                    out nocopy number        --needed by concurrent manager.
 ,p_process_id           in  number default null
 ,p_validate                in varchar2
 ,p_effective_date     in varchar2
 ,p_status                   in  varchar2  default null
 ,p_transaction_short_name  in  varchar2
 ,p_retain_log                       in varchar2
 ,p_business_group_id           in     number
)
is
cursor get_purge_processes (p_copy_entity_txn_id  number
                                            ,p_status varchar2
                                            ,p_transaction_short_name varchar2
                                            ,p_effective_date date
                     	     	            ,p_business_group_id number)
is
SELECT cet.copy_entity_txn_id, cet.process_name,
             cet.cet_object_version_number,
             cet.status, cet.src_effective_date,
	     cet.target_typ_cd,
             decode(ben_plan_design_txns_api.get_log_display
	                         (cet.copy_entity_txn_id
				 ,cet.status
				 ,cet.target_typ_cd),
				 'LogEnabled','Y',
				 'LogDisabled','N', 'N') log_status
       FROM ben_copy_entity_txns_vw cet
     WHERE cet.transaction_category_id =
                     (SELECT ptc.transaction_category_id
                          FROM PQH_TRANSACTION_CATEGORIES ptc
                               WHERE ptc.short_name = p_transaction_short_name)
	      AND cet.copy_entity_txn_id = NVL (p_copy_entity_txn_id, cet.copy_entity_txn_id)
	      AND cet.status = NVL (p_status, cet.status)
	      AND cet.src_effective_date <= p_effective_date
	      AND cet.context_business_group_id = p_business_group_id;

l_purge_processes                 get_purge_processes%rowtype;
l_copy_entity_txn_id             PQH_COPY_ENTITY_TXNS.copy_entity_txn_id%type;
l_effective_date                    date;
l_count                                   number;
l_retain_log                            varchar2(10);
--
begin
ben_batch_utils.write('Start of conc prog - PURGE PLAN DESIGN COPY PROCESS -');
--
l_effective_date := trunc(fnd_date.canonical_to_date(p_effective_date));
l_retain_log := p_retain_log;
--
ben_batch_utils.write(' ');
ben_batch_utils.write('Input Parameters are :-');
ben_batch_utils.write('Validate :'||hr_general.decode_lookup ('BEN_DB_UPD_MD',p_validate));
ben_batch_utils.write('Process Id :'||p_process_id);
ben_batch_utils.write('Effective Date :'||l_effective_date);
ben_batch_utils.write('Status :'||hr_general.decode_lookup ('BEN_PD_STATUS',p_status));
ben_batch_utils.write('Transaction short Name :'||p_transaction_short_name);
ben_batch_utils.write('Retain Log :'||p_retain_log);
ben_batch_utils.write('Business Group Id :'||p_business_group_id);
ben_batch_utils.write(' ');
--
l_count := 1;
--
open get_purge_processes(p_process_id
                                        ,p_status
                                        ,p_transaction_short_name
                                        ,l_effective_date
                                       	,p_business_group_id);
loop
--
fetch get_purge_processes into l_purge_processes;
exit when get_purge_processes%notfound;
--
-- Bug No 4349302 Log only processes with target_typ_cd <> 'BEN_PDVIEW'
--
if(nvl(l_purge_processes.target_typ_cd,'XXX') <> 'BEN_PDVIEW') then
    if (l_count = 1) then
        ben_batch_utils.write('============== List of Purged Processes =====================');
        ben_batch_utils.write(' ');
    end if;
    ben_batch_utils.write(l_count||') Process Name : '|| l_purge_processes.process_name
                                      || '(' || l_purge_processes.copy_entity_txn_id || ')');
    ben_batch_utils.write('   Status (Before Purge) : '||l_purge_processes.status);
    ben_batch_utils.write('   Effective Date : '|| l_purge_processes.src_effective_date);
    l_count := l_count + 1;
    ben_batch_utils.write(' ');
end if;
--
/* Only if validate mode is Commit ('N'), delete the txns,
    for mode = rollback ('Y'), no need of actually calling delete,
    just list the processes to be deleted */
if (p_validate = 'N') then

    /* Check if log is maintained for this copy_entity_txn_id, if not, then
         no point in retaining the log and header record */
      --
      if(l_purge_processes.log_status = 'N') then
         l_retain_log := 'N';
      end if;
      --
      delete_PLAN_DESIGN_TXN
          (p_copy_entity_txn_id          => l_purge_processes.copy_entity_txn_id
          ,p_cet_object_version_number  =>  l_purge_processes.cet_object_version_number
          ,p_effective_date           => l_effective_date
          ,p_retain_log                  => l_retain_log
          );
      --
end if;
--
end loop;
--
close get_purge_processes;
--
if (l_count = 1) then
   ben_batch_utils.write('No processes found which match the given criteria.');
   ben_batch_utils.write(' ');
end if;
ben_batch_utils.write('Completed - PURGE PLAN DESIGN COPY PROCESS -');
--
end purge_plan_design_process;

end BEN_PLAN_DESIGN_TXNS_API;

/
