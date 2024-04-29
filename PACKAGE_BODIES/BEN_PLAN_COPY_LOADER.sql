--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_COPY_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_COPY_LOADER" as
/* $Header: becetupd.pkb 120.0 2005/05/28 01:01:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-----------------------------< load_row >---------------------------------|
-- ----------------------------------------------------------------------------
--
  l_proc        varchar2(200) := 'Ben_plan_copy_loader.';
  l_found       boolean;

--
-- BUG: 4354708: Added the following procedure
procedure delete_PLAN_DESIGN_TXN
  (p_validate                       in   number        default 0 --  default false
  ,p_copy_entity_txn_id             in  number
  ,p_cet_object_version_number      in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := 'delete_PLAN_DESIGN_TXN';
  l_object_version_number pqh_copy_entity_txns.object_version_number%TYPE;
   --
  cursor c_copy_entity_txn is
  select object_version_number
  from pqh_copy_entity_txns
  where copy_entity_txn_id = p_copy_entity_txn_id;
  --
/*  cursor c_copy_entity_attrib is
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
  l_cer_object_version_number pqh_copy_entity_attribs.object_version_number%TYPE; */

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

    -- BUG: 4354708 : Removed all references to API calls.
    -- Directly calling DELETE STATEMENTS.
  --
  /*
     BEN_PLAN_DESIGN_TXNS_API.delete_plan_design_result
    ( p_validate                    => p_validate
     ,p_copy_entity_txn_id          => p_copy_entity_txn_id
     ,p_effective_date              => p_effective_date
     );
*/
    OPEN c_copy_entity_txn;
    FETCH c_copy_entity_txn into l_object_version_number;
    CLOSE c_copy_entity_txn;
    --
    IF (l_object_version_number = p_cet_object_version_number) THEN
        --
        DELETE FROM PQH_COPY_ENTITY_RESULTS
         WHERE COPY_ENTITY_TXN_ID = p_copy_entity_txn_id;
        --
        DELETE FROM BEN_COPY_ENTITY_RESULTS
         WHERE COPY_ENTITY_TXN_ID = p_copy_entity_txn_id;
        --
        DELETE FROM PQH_COPY_ENTITY_ATTRIBS
         WHERE COPY_ENTITY_TXN_ID = p_copy_entity_txn_id;
        --
        DELETE FROM PQH_COPY_ENTITY_TXNS
         WHERE COPY_ENTITY_TXN_ID = p_copy_entity_txn_id;
        --
    END IF;

/*
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
*/
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate = 1 then
    raise hr_API.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
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

Procedure load_cet_row
 (
       p_DISPLAY_NAME               VARCHAR2
      ,p_SRC_EFFECTIVE_DATE         VARCHAR2
      ,p_OWNER                      VARCHAR2
      ,p_CONTEXT                    VARCHAR2
      ,p_TRANS_CATEGORY_NAME        VARCHAR2
      ,p_ACTION_DATE                VARCHAR2
      ,p_REPLACEMENT_TYPE_CD        VARCHAR2
      ,p_START_WITH                 VARCHAR2
      ,p_INCREMENT_BY               VARCHAR2
      ,p_NUMBER_OF_COPIES           VARCHAR2
      ,p_STATUS                     VARCHAR2
      ,p_CONTEXT_BUSINESS_GROUP     VARCHAR2
 ) is

    -- Bug : 4354708
    l_last_update_date            date;
    l_last_updated_by             number(15);
    l_last_update_login           number(15);
    l_created_by                  number(15);
    l_creation_date               date;
    l_schema                      varchar2(100);
    l_industry                    varchar2(100);
    l_install_status                      varchar2(100);
    -- Bug : 4354708

    cursor c1(v_context_business_group_id number, v_transaction_category_id number) is
      select copy_entity_txn_id ,object_version_number
      from pqh_copy_entity_txns cet
      where cet.display_name = p_display_name
        and   cet.context_business_group_id = v_context_business_group_id
        and   cet.transaction_category_id = v_transaction_category_id ;
    -- and   to_char(cet.src_effective_date,'DD/MM/YYYY') = p_src_effective_date ;
    --
    cursor c2 is
      select transaction_category_id
      from pqh_transaction_categories tc
      where tc.short_name = p_TRANS_CATEGORY_NAME ;
    --
   cursor c3 is
     select business_group_id
     from per_business_groups bg
     where bg.short_name = p_CONTEXT_BUSINESS_GROUP ;

     -- Bug : 4354708
   cursor c_trig_cet is
    select null
    from all_triggers
    where table_name = 'PQH_COPY_ENTITY_TXNS'
      and trigger_name = 'PQH_COPY_ENTITY_TXNS_WHO'
      and table_owner = l_schema
      and status = 'ENABLED';
    --Bug : 4354708

    --
    l_dummy                       varchar2(30) ;
    l_copy_entity_txn_id          number(15);
    l_object_version_number       number(7) := 1 ;
    l_transaction_category_id     number(15);
    l_table_route_id              number(15);
    l_business_group_id           number(15);
    --
    l_start_with                  pqh_copy_entity_txns.start_with%type := 'BEN_PDC_TRGT_DTL_PAGE';
    l_status                      pqh_copy_entity_txns.status%type := 'IMPORTED';
    l_old_copy_entity_txn_id      number ;
    l_ovn                         number ;
    l_datestamp                   varchar2(30) := to_char(sysdate,'DD-MON-YYYY HH:MI:SS') ;
    --

  begin
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    /* For seeded FHR copy process, set context_business_group_id to 0 */
    if p_DISPLAY_NAME = 'GHR_FEHB_SEED_PROGRAM_DESIGN'
       or p_DISPLAY_NAME = 'GHR_TSP_SEED_PROGRAM_DESIGN'
       or p_DISPLAY_NAME = 'GHR_TSP_CATCHUP_SEED_PROGRAM_DESIGN'
    then
      l_business_group_id := 0;
    else
      l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
    end if;
    --
    open c2 ;
    hr_utility.set_location(' Step 30 ',30);
    fetch c2 into l_transaction_category_id ;
    if c2%notfound then
        -- Throw error
        close c2 ;
        return ;
        else
        g_perf_transaction_category_id := l_transaction_category_id;
    end if ;
    close c2;
    --
    open c1(l_business_group_id , l_transaction_category_id) ;
    --
    hr_utility.set_location(' Step 10 ',10);
    fetch c1 into l_old_copy_entity_txn_id,l_ovn ;
    --
    if c1%found then
        -- close c1 ;
        -- Now Update the displayName of the old transaction with timestamp appended.
        --
        update pqh_copy_entity_txns
        set display_name = display_name||l_datestamp
        where copy_entity_txn_id = l_old_copy_entity_txn_id ;
        --
        -- Raise exception through error
        --return ;
        --else
    end if ;
    close c1 ;
    ---
    -- Bug : 4354708:
    --
    l_found := fnd_installation.get_app_info ('PER', l_install_status, l_industry, l_schema);
    --
    open c_trig_cet;
    fetch c_trig_cet into l_dummy;
    if c_trig_cet%notfound then
        --
        -- WHO Trigger is not defined on the table PQH_COPY_ENTITY_TXNS
        -- Set WHO columns
        l_last_update_date    := sysdate;
        l_last_updated_by     := fnd_global.user_id;
        l_last_update_login   := fnd_global.login_id;
        l_created_by          := fnd_global.user_id;
        l_creation_date       := sysdate;
        --
    else
        --
        l_last_update_date    := null;
        l_last_updated_by     := null;
        l_last_update_login   := null;
        l_created_by          := null;
        l_creation_date       := null;
        --
    end if;
    --
    close c_trig_cet;
    --
    --Bug : 4354708:
    --
      -- Insert a record
      Begin
          hr_utility.set_location('Entering C2 :'||l_proc, 5);
          --
          /*
          open c2 ;
            hr_utility.set_location(' Step 30 ',30);
            fetch c2 into l_transaction_category_id ;
            if c2%notfound then
              -- Throw error
              close c2 ;
              return ;
            end if ;
          close c2;
          */
          --
          /*
          open c3 ;
             hr_utility.set_location(' Step 40 ',40);
            fetch c3 into l_business_group_id ;
          close c3;
          */
          --
          select pqh_copy_entity_txns_s.nextval into l_copy_entity_txn_id
          from dual ;
          hr_utility.set_location(' Step 50 ',50);
          --
          -- Insert the row into: pqh_copy_entity_txns
          --
          insert into pqh_copy_entity_txns
          (	copy_entity_txn_id,
        	transaction_category_id,
        	txn_category_attribute_id,
        	context_business_group_id,
        	datetrack_mode,
        	context ,
                action_date ,
                src_effective_date,
        	number_of_copies ,
        	display_name,
        	replacement_type_cd,
        	start_with,
        	increment_by,
        	status,
        	object_version_number,
            last_update_date,        --Bug : 4354708
            last_updated_by,
            last_update_login,
            created_by,
            creation_date           --Bug : 4354708
          )
          Values
          (	l_copy_entity_txn_id,
	        l_transaction_category_id,
	        null,
        	nvl(l_business_group_id,0),
        	null,
        	p_context ,
                to_date(p_action_date ,'DD/MM/YYYY'),
                to_date(p_src_effective_date,'DD/MM/YYYY'),
        	to_number(p_number_of_copies) ,
        	p_display_name,
        	p_replacement_type_cd,
        	l_start_with,
        	to_number(p_increment_by) ,
        	l_status,
        	l_object_version_number,
            l_last_update_date,        --Bug : 4354708
            l_last_updated_by,
            l_last_update_login,
            l_created_by,
            l_creation_date           --Bug : 4354708
          );
          --
          g_perf_copy_entity_txn_id := l_copy_entity_txn_id;
          if l_old_copy_entity_txn_id is not null then
            --
            -- 4354708 Remove API calls and directly call delete statements.
            -- SEED115 has API dependencies. Hence removed all calls to APIs.
            --BEN_PLAN_DESIGN_TXNS_API.delete_PLAN_DESIGN_TXN
            delete_PLAN_DESIGN_TXN
              (p_copy_entity_txn_id          =>l_old_copy_entity_txn_id
              ,p_cet_object_version_number   =>l_ovn
              ,p_effective_date              =>to_date(p_src_effective_date,'DD/MM/YYYY')
               );
            --
          end if;
          --
          hr_utility.set_location(' Leaving:'||l_proc, 10);
        Exception
          When hr_api.check_integrity_violated Then
            -- A check constraint has been violated
            pqh_cet_shd.constraint_error
              (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When hr_api.parent_integrity_violated Then
            -- Parent integrity has been violated
            pqh_cet_shd.constraint_error
              (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When hr_api.unique_integrity_violated Then
            -- Unique integrity has been violated
            pqh_cet_shd.constraint_error
              (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When Others Then
            Raise;
        End ;
  end ;
Procedure load_cea_row
 (
         p_DISPLAY_NAME               VARCHAR2
        ,p_SRC_EFFECTIVE_DATE         VARCHAR2
        ,p_OWNER                      VARCHAR2
        ,p_TRANS_CATEGORY_NAME        VARCHAR2
        ,p_row_type_cd                VARCHAR2
        ,p_information_category       VARCHAR2
        ,p_information1               VARCHAR2
        ,p_information2               VARCHAR2
        ,p_information3               VARCHAR2
        ,p_information4               VARCHAR2
        ,p_information5               VARCHAR2
        ,p_information6               VARCHAR2
        ,p_information7               VARCHAR2
        ,p_information8               VARCHAR2
        ,p_information9               VARCHAR2
        ,p_information10              VARCHAR2
        ,p_information11              VARCHAR2
        ,p_information12              VARCHAR2
        ,p_information13              VARCHAR2
        ,p_information14              VARCHAR2
        ,p_information15              VARCHAR2
        ,p_information16              VARCHAR2
        ,p_information17              VARCHAR2
        ,p_information18              VARCHAR2
        ,p_information19              VARCHAR2
        ,p_information20              VARCHAR2
        ,p_information21              VARCHAR2
        ,p_information22              VARCHAR2
        ,p_information23              VARCHAR2
        ,p_information24              VARCHAR2
        ,p_information25              VARCHAR2
        ,p_information26              VARCHAR2
        ,p_information27              VARCHAR2
        ,p_information28              VARCHAR2
        ,p_information29              VARCHAR2
        ,p_information30              VARCHAR2
 ) is
    -- Bug : 4354708
    l_last_update_date            date;
    l_last_updated_by             number(15);
    l_last_update_login           number(15);
    l_created_by                  number(15);
    l_creation_date               date;
    l_schema                      varchar2(100);
    l_industry                    varchar2(100);
    l_install_status              varchar2(100);
    -- Bug : 4354708
    --
    cursor c2 is
      select transaction_category_id
      from pqh_transaction_categories tc
      where tc.short_name = p_TRANS_CATEGORY_NAME ;
    --
    cursor c1(v_context_business_group_id number, v_transaction_category_id number) is
      select null
      from pqh_copy_entity_txns cet,
           pqh_copy_entity_attribs cea
      where cet.display_name                = p_display_name
        and   cet.context_business_group_id = v_context_business_group_id
        and   cet.transaction_category_id   = v_transaction_category_id
        -- and to_char(cet.src_effective_date,'DD/MM/YYYY') = p_src_effective_date
        and cet.copy_entity_txn_id = cea.copy_entity_txn_id ;
    --
    cursor c3(v_context_business_group_id number, v_transaction_category_id number) is
      select copy_entity_txn_id
      from pqh_copy_entity_txns cet
      where cet.display_name = p_display_name
        and   cet.context_business_group_id = v_context_business_group_id
        and   cet.transaction_category_id   = v_transaction_category_id ;
        -- and to_char(cet.src_effective_date,'DD/MM/YYYY') = p_src_effective_date ;

    --Bug : 4354708
    cursor c_trig_cea is
      select null
      from all_triggers
      where table_name = 'PQH_COPY_ENTITY_ATTRIBS'
      and trigger_name = 'PQH_COPY_ENTITY_ATTRIBS_WHO'
      and table_owner = l_schema
      and status = 'ENABLED';
    --Bug : 4354708

    --
    l_dummy                       varchar2(30) ;
    l_copy_entity_txn_id          number(15);
    l_object_version_number       number(7) := 1 ;
    l_copy_entity_attrib_id       number(15);
    l_business_group_id           number ;
    l_transaction_category_id     number ;
    --
    l_target_typ_cd               pqh_copy_entity_attribs.information3%type := 'BEN_PDIMPT';
  begin
    --
    /* For seeded FHR copy process, set context_business_group_id to 0 */
    if p_DISPLAY_NAME = 'GHR_FEHB_SEED_PROGRAM_DESIGN' then
      l_business_group_id := 0;
    else
      l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
    end if;
    --
    if g_perf_transaction_category_id is null then
      open c2 ;
      hr_utility.set_location(' Step 30 ',30);
      fetch c2 into l_transaction_category_id ;
      g_perf_transaction_category_id := l_transaction_category_id;
      if c2%notfound then
        -- Throw error
        close c2 ;
        return ;
      end if ;
      close c2;
    else
      l_transaction_category_id := g_perf_transaction_category_id;
    end if;
    --
    -- Bug : 4354708
    --
    l_found := fnd_installation.get_app_info ('PER', l_install_status, l_industry, l_schema);
    --
    open c_trig_cea;
    fetch c_trig_cea into l_dummy;
    if c_trig_cea%notfound then
      --
      -- WHO Trigger is not defined on the table PQH_COPY_ENTITY_ATTRIBS
      -- Set WHO columns
      l_last_update_date    := sysdate;
      l_last_updated_by     := fnd_global.user_id;
      l_last_update_login   := fnd_global.login_id;
      l_created_by          := fnd_global.user_id;
      l_creation_date       := sysdate;
      --
    else
      --
      l_last_update_date    := null;
      l_last_updated_by     := null;
      l_last_update_login   := null;
      l_created_by          := null;
      l_creation_date       := null;
      --
    end if;
    --
    close c_trig_cea;
    --
    --Bug : 4354708
    --
    --
    open c1(l_business_group_id , l_transaction_category_id) ;
      fetch c1 into l_dummy ;
      if c1%found then
        -- Raise exception through error
        close c1 ;
        return ;
      else
        close c1 ;
        -- Insert a record
        Begin
          if g_perf_copy_entity_txn_id is null then
             open c3 (l_business_group_id , l_transaction_category_id);
               fetch c3 into l_copy_entity_txn_id ;
               g_perf_copy_entity_txn_id := l_copy_entity_txn_id;
             close c3;
          else
            l_copy_entity_txn_id := g_perf_copy_entity_txn_id;
          end if;
          select pqh_copy_entity_attribs_s.nextval into l_copy_entity_attrib_id
          from dual ;
          --
          -- Insert the row into: pqh_copy_entity_attribs
          --
          hr_utility.set_location('Entering:'||l_proc, 5);
          insert into pqh_copy_entity_attribs
          (	copy_entity_attrib_id,
        	copy_entity_txn_id,
        	row_type_cd,
        	information_category,
        	information1,
        	information2,
        	information3,
        	information4,
        	information5,
        	information6,
        	information7,
        	information8,
        	information9,
        	information10,
        	information11,
        	information12,
        	information13,
        	information14,
        	information15,
        	information16,
        	information17,
        	information18,
        	information19,
        	information20,
        	information21,
        	information22,
        	information23,
        	information24,
        	information25,
        	information26,
        	information27,
        	information28,
        	information29,
        	information30,
        	object_version_number,
            last_update_date,        --Bug : 4354708
            last_updated_by,
            last_update_login,
            created_by,
            creation_date           --Bug : 4354708
          )
          Values
          (	l_copy_entity_attrib_id,
        	l_copy_entity_txn_id,
        	p_row_type_cd,
        	p_information_category,
        	p_information1,
        	p_information2,
        	l_target_typ_cd,
        	p_information4,
        	p_information5,
        	p_information6,
        	p_information7,
        	p_information8,
        	p_information9,
        	p_information10,
        	p_information11,
        	p_information12,
        	p_information13,
        	p_information14,
        	p_information15,
        	p_information16,
        	p_information17,
        	p_information18,
        	p_information19,
        	p_information20,
        	p_information21,
        	p_information22,
        	p_information23,
        	p_information24,
        	p_information25,
        	p_information26,
        	p_information27,
        	p_information28,
        	p_information29,
        	p_information30,
        	l_object_version_number,
            l_last_update_date,        --Bug : 4354708
            l_last_updated_by,
            l_last_update_login,
            l_created_by,
            l_creation_date           --Bug : 4354708
          );
          --
          hr_utility.set_location(' Leaving:'||l_proc, 10);
        Exception
          When hr_api.check_integrity_violated Then
            -- A check constraint has been violated
            pqh_cea_shd.constraint_error
              (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When hr_api.parent_integrity_violated Then
            -- Parent integrity has been violated
            pqh_cea_shd.constraint_error
              (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When hr_api.unique_integrity_violated Then
            -- Unique integrity has been violated
            pqh_cea_shd.constraint_error
              (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When Others Then
            Raise;
        End ;
      end if ;
    null;
  end ;
--
Procedure load_cer_row
  (
         p_DISPLAY_NAME                VARCHAR2
         ,p_SRC_EFFECTIVE_DATE         VARCHAR2
         ,p_OWNER                      VARCHAR2
         ,p_TRANS_CATEGORY_NAME        VARCHAR2
         ,p_RESULT_TYPE_CD             VARCHAR2
         ,p_NUMBER_OF_COPIES           VARCHAR2
         ,p_STATUS                     VARCHAR2
         ,p_information_category       VARCHAR2
         ,p_information1               VARCHAR2
         ,p_information2               VARCHAR2
         ,p_information3               VARCHAR2
         ,p_information4               VARCHAR2
         ,p_information5               VARCHAR2
         ,p_information6               VARCHAR2
         ,p_information7               VARCHAR2
         ,p_information8               VARCHAR2
         ,p_information9               VARCHAR2
         ,p_information10              VARCHAR2
         ,p_information11              VARCHAR2
         ,p_information12              VARCHAR2
         ,p_information13              VARCHAR2
         ,p_information14              VARCHAR2
         ,p_information15              VARCHAR2
         ,p_information16              VARCHAR2
         ,p_information17              VARCHAR2
         ,p_information18              VARCHAR2
         ,p_information19              VARCHAR2
         ,p_information20              VARCHAR2
         ,p_information21              VARCHAR2
         ,p_information22              VARCHAR2
         ,p_information23              VARCHAR2
         ,p_information24              VARCHAR2
         ,p_information25              VARCHAR2
         ,p_information26              VARCHAR2
         ,p_information27              VARCHAR2
         ,p_information28              VARCHAR2
         ,p_information29              VARCHAR2
         ,p_information30              VARCHAR2
         ,p_information31              VARCHAR2
         ,p_information32              VARCHAR2
         ,p_information33              VARCHAR2
         ,p_information34              VARCHAR2
         ,p_information35              VARCHAR2
         ,p_information36              VARCHAR2
         ,p_information37              VARCHAR2
         ,p_information38              VARCHAR2
         ,p_information39              VARCHAR2
         ,p_information40              VARCHAR2
         ,p_information41              VARCHAR2
         ,p_information42              VARCHAR2
         ,p_information43              VARCHAR2
         ,p_information44              VARCHAR2
         ,p_information45              VARCHAR2
         ,p_information46              VARCHAR2
         ,p_information47              VARCHAR2
         ,p_information48              VARCHAR2
         ,p_information49              VARCHAR2
         ,p_information50              VARCHAR2
         ,p_information51              VARCHAR2
         ,p_information52              VARCHAR2
         ,p_information53              VARCHAR2
         ,p_information54              VARCHAR2
         ,p_information55              VARCHAR2
         ,p_information56              VARCHAR2
         ,p_information57              VARCHAR2
         ,p_information58              VARCHAR2
         ,p_information59              VARCHAR2
         ,p_information60              VARCHAR2
         ,p_information61              VARCHAR2
         ,p_information62              VARCHAR2
         ,p_information63              VARCHAR2
         ,p_information64              VARCHAR2
         ,p_information65              VARCHAR2
         ,p_information66              VARCHAR2
         ,p_information67              VARCHAR2
         ,p_information68              VARCHAR2
         ,p_information69              VARCHAR2
         ,p_information70              VARCHAR2
         ,p_information71              VARCHAR2
         ,p_information72              VARCHAR2
         ,p_information73              VARCHAR2
         ,p_information74              VARCHAR2
         ,p_information75              VARCHAR2
         ,p_information76              VARCHAR2
         ,p_information77              VARCHAR2
         ,p_information78              VARCHAR2
         ,p_information79              VARCHAR2
         ,p_information80              VARCHAR2
         ,p_information81              VARCHAR2
         ,p_information82              VARCHAR2
         ,p_information83              VARCHAR2
         ,p_information84              VARCHAR2
         ,p_information85              VARCHAR2
         ,p_information86              VARCHAR2
         ,p_information87              VARCHAR2
         ,p_information88              VARCHAR2
         ,p_information89              VARCHAR2
         ,p_information90              VARCHAR2
         ,p_information91              VARCHAR2
         ,p_information92              VARCHAR2
         ,p_information93              VARCHAR2
         ,p_information94              VARCHAR2
         ,p_information95              VARCHAR2
         ,p_information96              VARCHAR2
         ,p_information97              VARCHAR2
         ,p_information98              VARCHAR2
         ,p_information99              VARCHAR2
         ,p_information100             VARCHAR2
         ,p_information101             VARCHAR2
         ,p_information102             VARCHAR2
         ,p_information103             VARCHAR2
         ,p_information104             VARCHAR2
         ,p_information105             VARCHAR2
         ,p_information106             VARCHAR2
         ,p_information107             VARCHAR2
         ,p_information108             VARCHAR2
         ,p_information109             VARCHAR2
         ,p_information110             VARCHAR2
         ,p_information111             VARCHAR2
         ,p_information112             VARCHAR2
         ,p_information113             VARCHAR2
         ,p_information114             VARCHAR2
         ,p_information115             VARCHAR2
         ,p_information116             VARCHAR2
         ,p_information117             VARCHAR2
         ,p_information118             VARCHAR2
         ,p_information119             VARCHAR2
         ,p_information120             VARCHAR2
         ,p_information121             VARCHAR2
         ,p_information122             VARCHAR2
         ,p_information123             VARCHAR2
         ,p_information124             VARCHAR2
         ,p_information125             VARCHAR2
         ,p_information126             VARCHAR2
         ,p_information127             VARCHAR2
         ,p_information128             VARCHAR2
         ,p_information129             VARCHAR2
         ,p_information130             VARCHAR2
         ,p_information131             VARCHAR2
         ,p_information132             VARCHAR2
         ,p_information133             VARCHAR2
         ,p_information134             VARCHAR2
         ,p_information135             VARCHAR2
         ,p_information136             VARCHAR2
         ,p_information137             VARCHAR2
         ,p_information138             VARCHAR2
         ,p_information139             VARCHAR2
         ,p_information140             VARCHAR2
         ,p_information141             VARCHAR2
         ,p_information142             VARCHAR2
         ,p_information143             VARCHAR2
         ,p_information144             VARCHAR2
         ,p_information145             VARCHAR2
         ,p_information146             VARCHAR2
         ,p_information147             VARCHAR2
         ,p_information148             VARCHAR2
         ,p_information149             VARCHAR2
         ,p_information150             VARCHAR2
         ,p_information151             VARCHAR2
         ,p_information152             VARCHAR2
         ,p_information153             VARCHAR2
         ,p_information154             VARCHAR2
         ,p_information155             VARCHAR2
         ,p_information156             VARCHAR2
         ,p_information157             VARCHAR2
         ,p_information158             VARCHAR2
         ,p_information159             VARCHAR2
         ,p_information160             VARCHAR2
         ,p_information161             VARCHAR2
         ,p_information162             VARCHAR2
         ,p_information163             VARCHAR2
         ,p_information164             VARCHAR2
         ,p_information165             VARCHAR2
         ,p_information166             VARCHAR2
         ,p_information167             VARCHAR2
         ,p_information168             VARCHAR2
         ,p_information169             VARCHAR2
         ,p_information170             VARCHAR2
         ,p_information171             VARCHAR2
         ,p_information172             VARCHAR2
         ,p_information173             VARCHAR2
         ,p_information174             VARCHAR2
         ,p_information175             VARCHAR2
         ,p_information176             VARCHAR2
         ,p_information177             VARCHAR2
         ,p_information178             VARCHAR2
         ,p_information179             VARCHAR2
         ,p_information180             VARCHAR2
         ,p_information181             VARCHAR2
         ,p_information182             VARCHAR2
         ,p_information183             VARCHAR2
         ,p_information184             VARCHAR2
         ,p_information185             VARCHAR2
         ,p_information186             VARCHAR2
         ,p_information187             VARCHAR2
         ,p_information188             VARCHAR2
         ,p_information189             VARCHAR2
         ,p_information190             VARCHAR2
         ,p_table_alias                VARCHAR2
         ,p_mirror_entity_result_id    VARCHAR2
         ,p_mirror_src_entity_result_id VARCHAR2
         ,p_parent_entity_result_id    VARCHAR2
         ,p_long_attribute1            VARCHAR2
   ) is
       -- Bug : 4354708
    l_last_update_date            date;
    l_last_updated_by             number(15);
    l_last_update_login           number(15);
    l_created_by                  number(15);
    l_creation_date               date;
    l_schema                      varchar2(100);
    l_industry                    varchar2(100);
    l_install_status              varchar2(100);
    -- Bug : 4354708
    cursor c2 is
      select transaction_category_id
      from pqh_transaction_categories tc
      where tc.short_name = p_TRANS_CATEGORY_NAME ;
    --
    cursor c1(v_context_business_group_id number, v_transaction_category_id number) is
      select null
      from pqh_copy_entity_txns cet,
           pqh_copy_entity_results cer
      where cet.display_name = p_display_name
        and   cet.context_business_group_id = v_context_business_group_id
        and   cet.transaction_category_id = v_transaction_category_id
        -- and to_char(cet.src_effective_date,'DD/MM/YYYY') = p_src_effective_date
        and cet.copy_entity_txn_id = cer.copy_entity_txn_id
        and ( p_mirror_entity_result_id is null or
              cer.mirror_entity_result_id = to_number(p_mirror_entity_result_id) )
        and ( p_mirror_src_entity_result_id is null or
              cer.mirror_src_entity_result_id = to_number(p_mirror_src_entity_result_id)) ;
    --
    cursor c3(v_context_business_group_id number, v_transaction_category_id number) is
      select copy_entity_txn_id
      from pqh_copy_entity_txns cet
      where cet.display_name = p_display_name
        and   cet.context_business_group_id = v_context_business_group_id
        and   cet.transaction_category_id = v_transaction_category_id ;
        -- and to_char(cet.src_effective_date,'DD/MM/YYYY') = p_src_effective_date ;
    --
    cursor c4 is
      select table_route_id
      from pqh_table_route tr
      where table_alias = p_table_alias
        and tr.from_clause = 'OAB' ;
    --
    --Bug : 4354708
    cursor c_trig_cer is
    select null
    from all_triggers
    where table_name = 'PQH_COPY_ENTITY_RESULTS'
      and trigger_name = 'PQH_COPY_ENTITY_RESULTS_WHO'
      and table_owner = l_schema
      and status = 'ENABLED';
    --Bug : 4354708

    l_dummy                       varchar2(30) ;
    l_copy_entity_txn_id          number(15);
    l_object_version_number       number(7) := 1 ;
    l_copy_entity_attrib_id       number(15);
    l_table_route_id              number(15);
    l_copy_entity_result_id       number(15);
    l_business_group_id           number ;
    l_transaction_category_id     number ;
    --
  begin
    --
    /* For seeded FHR copy process, set context_business_group_id to 0 */
    if p_DISPLAY_NAME = 'GHR_FEHB_SEED_PROGRAM_DESIGN' then
      l_business_group_id := 0;
    else
      l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
    end if;
    --
    if g_perf_transaction_category_id is null then
      open c2 ;
      hr_utility.set_location(' Step 30 ',30);
      fetch c2 into l_transaction_category_id ;
      g_perf_transaction_category_id := l_transaction_category_id;
      if c2%notfound then
        -- Throw error
        close c2 ;
        return ;
      end if ;
      close c2;
    else
      l_transaction_category_id := g_perf_transaction_category_id;
    end if;
    --
/*
    open c1(l_business_group_id , l_transaction_category_id) ;
      fetch c1 into l_dummy ;
      if c1%found then
        -- Raise exception through error
        close c1;
        return ;
      else
        close c1;
        -- Insert a record
*/

	--
	-- Bug : 4354708
    --
    l_found := fnd_installation.get_app_info ('PER', l_install_status, l_industry, l_schema);
    --
	open c_trig_cer;
	fetch c_trig_cer into l_dummy;
	if c_trig_cer%notfound then
	  --
	  -- WHO Trigger is not defined on the table PQH_COPY_ENTITY_RESULTS
	  -- Set WHO columns
	  l_last_update_date    := sysdate;
	  l_last_updated_by     := fnd_global.user_id;
	  l_last_update_login   := fnd_global.login_id;
	  l_created_by          := fnd_global.user_id;
	  l_creation_date       := sysdate;
	  --
	else
	  --
	  l_last_update_date    := null;
	  l_last_updated_by     := null;
	  l_last_update_login   := null;
	  l_created_by          := null;
	  l_creation_date       := null;
	  --
	end if;
	--
	close c_trig_cer;
	--
	--Bug : 4354708
	--

        Begin
          if g_perf_copy_entity_txn_id is null then
             open c3(l_business_group_id , l_transaction_category_id) ;
               fetch c3 into l_copy_entity_txn_id ;
               g_perf_copy_entity_txn_id := l_copy_entity_txn_id;
             close c3;
          else
            l_copy_entity_txn_id := g_perf_copy_entity_txn_id;
          end if;
          --
          open c4 ;
            fetch c4 into l_table_route_id ;
          close c4;
          --
          /*
          select pqh_copy_entity_results_s.nextval into l_copy_entity_result_id
          from dual ;
          */
          --
          insert into pqh_copy_entity_results
            (	copy_entity_result_id,
              	copy_entity_txn_id,
              	result_type_cd,
              	number_of_copies,
              	status,
              	src_copy_entity_result_id,
              	information_category,
              	information1,
              	information2,
              	information3,
              	information4,
              	information5,
              	information6,
              	information7,
              	information8,
              	information9,
              	information10,
              	information11,
              	information12,
              	information13,
              	information14,
              	information15,
              	information16,
              	information17,
              	information18,
              	information19,
              	information20,
              	information21,
              	information22,
              	information23,
              	information24,
              	information25,
              	information26,
              	information27,
              	information28,
              	information29,
              	information30,
              	information31,
              	information32,
              	information33,
              	information34,
              	information35,
              	information36,
              	information37,
              	information38,
              	information39,
              	information40,
              	information41,
              	information42,
              	information43,
              	information44,
              	information45,
              	information46,
              	information47,
              	information48,
              	information49,
              	information50,
              	information51,
              	information52,
              	information53,
              	information54,
              	information55,
              	information56,
              	information57,
              	information58,
              	information59,
              	information60,
              	information61,
              	information62,
              	information63,
              	information64,
              	information65,
              	information66,
              	information67,
              	information68,
              	information69,
              	information70,
              	information71,
              	information72,
              	information73,
              	information74,
              	information75,
              	information76,
              	information77,
              	information78,
              	information79,
              	information80,
              	information81,
              	information82,
              	information83,
              	information84,
              	information85,
              	information86,
              	information87,
              	information88,
              	information89,
              	information90,
                information91   ,
                information92   ,
                information93   ,
                information94   ,
                information95   ,
                information96   ,
                information97   ,
                information98   ,
                information99   ,
                information100  ,
                information101  ,
                information102  ,
                information103  ,
                information104  ,
                information105  ,
                information106  ,
                information107  ,
                information108  ,
                information109  ,
                information110  ,
                information111  ,
                information112  ,
                information113  ,
                information114  ,
                information115  ,
                information116  ,
                information117  ,
                information118  ,
                information119  ,
                information120  ,
                information121  ,
                information122  ,
                information123  ,
                information124  ,
                information125  ,
                information126  ,
                information127  ,
                information128  ,
                information129  ,
                information130  ,
                information131  ,
                information132  ,
                information133  ,
                information134  ,
                information135  ,
                information136  ,
                information137  ,
                information138  ,
                information139  ,
                information140  ,
                information141  ,
                information142  ,
                information143  ,
                information144  ,
                information145  ,
                information146  ,
                information147  ,
                information148  ,
                information149  ,
                information150  ,
                information151  ,
                information152  ,
                information153  ,
                information154  ,
                information155  ,
                information156  ,
                information157  ,
                information158  ,
                information159  ,
                information160  ,
                information161  ,
                information162  ,
                information163  ,
                information164  ,
                information165  ,
                information166  ,
                information167  ,
                information168  ,
                information169  ,
                information170  ,
                information171  ,
                information172  ,
                information173  ,
                information174  ,
                information175  ,
                information176  ,
                information177  ,
                information178  ,
                information179  ,
                information180  ,
                information181  ,
                information182  ,
                information183  ,
                information184  ,
                information185  ,
                information186  ,
                information187  ,
                information188  ,
                information189  ,
                information190  ,
              	object_version_number ,
                table_route_id ,
                mirror_entity_result_id,
                mirror_src_entity_result_id,
                parent_entity_result_id,
                long_attribute1,
                last_update_date,        --Bug : 4354708
                last_updated_by,
                last_update_login,
                created_by,
                creation_date           --Bug : 4354708
             )
             Values
             (	pqh_copy_entity_results_s.nextval, -- l_copy_entity_result_id,
              	l_copy_entity_txn_id,
              	p_result_type_cd,
              	to_number(p_number_of_copies),
              	p_status,
                null, -- 	p_src_copy_entity_result_id,
              	p_information_category,
              	p_information1,
              	p_information2,
              	p_information3,
              	p_information4,
              	p_information5,
              	p_information6,
              	p_information7,
              	p_information8,
              	p_information9,
              	p_information10,
              	p_information11,
              	p_information12,
              	p_information13,
              	p_information14,
              	p_information15,
              	p_information16,
              	p_information17,
              	p_information18,
              	p_information19,
              	p_information20,
              	p_information21,
              	p_information22,
              	p_information23,
              	p_information24,
              	p_information25,
              	p_information26,
              	p_information27,
              	p_information28,
              	p_information29,
              	p_information30,
              	p_information31,
              	p_information32,
              	p_information33,
              	p_information34,
              	p_information35,
              	p_information36,
              	p_information37,
              	p_information38,
              	p_information39,
              	p_information40,
              	p_information41,
              	p_information42,
              	p_information43,
              	p_information44,
              	p_information45,
              	p_information46,
              	p_information47,
              	p_information48,
              	p_information49,
              	p_information50,
              	p_information51,
              	p_information52,
              	p_information53,
              	p_information54,
              	p_information55,
              	p_information56,
              	p_information57,
              	p_information58,
              	p_information59,
              	p_information60,
              	p_information61,
              	p_information62,
              	p_information63,
              	p_information64,
              	p_information65,
              	p_information66,
              	p_information67,
              	p_information68,
              	p_information69,
              	p_information70,
              	p_information71,
              	p_information72,
              	p_information73,
              	p_information74,
              	p_information75,
              	p_information76,
              	p_information77,
              	p_information78,
              	p_information79,
              	p_information80,
              	p_information81,
              	p_information82,
              	p_information83,
              	p_information84,
              	p_information85,
              	p_information86,
              	p_information87,
              	p_information88,
              	p_information89,
              	p_information90,
                p_information91   ,
                p_information92   ,
                p_information93   ,
                p_information94   ,
                p_information95   ,
                p_information96   ,
                p_information97   ,
                p_information98   ,
                p_information99   ,
                p_information100  ,
                p_information101  ,
                p_information102  ,
                p_information103  ,
                p_information104  ,
                p_information105  ,
                p_information106  ,
                p_information107  ,
                p_information108  ,
                p_information109  ,
                p_information110  ,
                p_information111  ,
                p_information112  ,
                p_information113  ,
                p_information114  ,
                p_information115  ,
                p_information116  ,
                p_information117  ,
                p_information118  ,
                p_information119  ,
                p_information120  ,
                p_information121  ,
                p_information122  ,
                p_information123  ,
                p_information124  ,
                p_information125  ,
                p_information126  ,
                p_information127  ,
                p_information128  ,
                p_information129  ,
                p_information130  ,
                p_information131  ,
                p_information132  ,
                p_information133  ,
                p_information134  ,
                p_information135  ,
                p_information136  ,
                p_information137  ,
                p_information138  ,
                p_information139  ,
                p_information140  ,
                p_information141  ,
                p_information142  ,
                p_information143  ,
                p_information144  ,
                p_information145  ,
                p_information146  ,
                p_information147  ,
                p_information148  ,
                p_information149  ,
                p_information150  ,
                p_information151  ,
                p_information152  ,
                p_information153  ,
                p_information154  ,
                p_information155  ,
                p_information156  ,
                p_information157  ,
                p_information158  ,
                p_information159  ,
                p_information160  ,
                p_information161  ,
                p_information162  ,
                p_information163  ,
                p_information164  ,
                p_information165  ,
                p_information166  ,
                p_information167  ,
                p_information168  ,
                p_information169  ,
                p_information170  ,
                p_information171  ,
                p_information172  ,
                p_information173  ,
                p_information174  ,
                p_information175  ,
                p_information176  ,
                p_information177  ,
                p_information178  ,
                p_information179  ,
                p_information180  ,
                p_information181  ,
                p_information182  ,
                p_information183  ,
                p_information184  ,
                p_information185  ,
                p_information186  ,
                p_information187  ,
                p_information188  ,
                p_information189  ,
                p_information190  ,
              	l_object_version_number ,
                l_table_route_id ,
                to_number(p_mirror_entity_result_id) ,
                to_number(p_mirror_src_entity_result_id),
                to_number(p_parent_entity_result_id),
                p_long_attribute1 ,
                l_last_update_date,        --Bug : 4354708
                l_last_updated_by,
                l_last_update_login,
                l_created_by,
                l_creation_date           --Bug : 4354708
                );
                --
                hr_utility.set_location(' Leaving:'||l_proc, 10);
        Exception
          When hr_api.check_integrity_violated Then
            -- A check constraint has been violated
            pqh_cer_shd.constraint_error
                 (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When hr_api.parent_integrity_violated Then
            -- Parent integrity has been violated
            pqh_cer_shd.constraint_error
                 (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When hr_api.unique_integrity_violated Then
            -- Unique integrity has been violated
            pqh_cer_shd.constraint_error
                 (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When Others Then
            Raise;
        End ;
    -- end if ;
  end;
--
Procedure load_cpe_row
  (
         p_DISPLAY_NAME                  VARCHAR2
         ,p_SRC_EFFECTIVE_DATE           VARCHAR2
         ,p_OWNER                        VARCHAR2
         ,p_MIRROR_ENTITY_RESULT_ID      VARCHAR2
         ,p_MODE                         VARCHAR2
         ,p_TRANS_CATEGORY_NAME          VARCHAR2 DEFAULT NULL
         ,p_RESULT_TYPE_CD               VARCHAR2 DEFAULT NULL
         ,p_NUMBER_OF_COPIES             VARCHAR2 DEFAULT NULL
         ,p_STATUS                       VARCHAR2 DEFAULT NULL
         ,p_mirror_src_entity_result_id  VARCHAR2 DEFAULT NULL
         ,p_parent_entity_result_id      VARCHAR2 DEFAULT NULL
         ,p_pd_mr_src_entity_result_id   VARCHAR2 DEFAULT NULL
         ,p_pd_parent_entity_result_id   VARCHAR2 DEFAULT NULL
         ,p_gs_mr_src_entity_result_id   VARCHAR2 DEFAULT NULL
         ,p_gs_parent_entity_result_id   VARCHAR2 DEFAULT NULL
         ,p_table_name                   VARCHAR2 DEFAULT NULL
         ,p_dml_operation                VARCHAR2 DEFAULT NULL
         ,p_information_category         VARCHAR2 DEFAULT NULL
         ,p_information1                 VARCHAR2 DEFAULT NULL
         ,p_information2                 VARCHAR2 DEFAULT NULL
         ,p_information3                 VARCHAR2 DEFAULT NULL
         ,p_information4                 VARCHAR2 DEFAULT NULL
         ,p_information5                 VARCHAR2 DEFAULT NULL
         ,p_information6                 VARCHAR2 DEFAULT NULL
         ,p_information7                 VARCHAR2 DEFAULT NULL
         ,p_information8                 VARCHAR2 DEFAULT NULL
         ,p_information9                 VARCHAR2 DEFAULT NULL
         ,p_information10                VARCHAR2 DEFAULT NULL
         ,p_information11                VARCHAR2 DEFAULT NULL
         ,p_information12                VARCHAR2 DEFAULT NULL
         ,p_information13                VARCHAR2 DEFAULT NULL
         ,p_information14                VARCHAR2 DEFAULT NULL
         ,p_information15                VARCHAR2 DEFAULT NULL
         ,p_information16                VARCHAR2 DEFAULT NULL
         ,p_information17                VARCHAR2 DEFAULT NULL
         ,p_information18                VARCHAR2 DEFAULT NULL
         ,p_information19                VARCHAR2 DEFAULT NULL
         ,p_information20                VARCHAR2 DEFAULT NULL
         ,p_information21                VARCHAR2 DEFAULT NULL
         ,p_information22                VARCHAR2 DEFAULT NULL
         ,p_information23                VARCHAR2 DEFAULT NULL
         ,p_information24                VARCHAR2 DEFAULT NULL
         ,p_information25                VARCHAR2 DEFAULT NULL
         ,p_information26                VARCHAR2 DEFAULT NULL
         ,p_information27                VARCHAR2 DEFAULT NULL
         ,p_information28                VARCHAR2 DEFAULT NULL
         ,p_information29                VARCHAR2 DEFAULT NULL
         ,p_information30                VARCHAR2 DEFAULT NULL
         ,p_information31                VARCHAR2 DEFAULT NULL
         ,p_information32                VARCHAR2 DEFAULT NULL
         ,p_information33                VARCHAR2 DEFAULT NULL
         ,p_information34                VARCHAR2 DEFAULT NULL
         ,p_information35                VARCHAR2 DEFAULT NULL
         ,p_information36                VARCHAR2 DEFAULT NULL
         ,p_information37                VARCHAR2 DEFAULT NULL
         ,p_information38                VARCHAR2 DEFAULT NULL
         ,p_information39                VARCHAR2 DEFAULT NULL
         ,p_information40                VARCHAR2 DEFAULT NULL
         ,p_information41                VARCHAR2 DEFAULT NULL
         ,p_information42                VARCHAR2 DEFAULT NULL
         ,p_information43                VARCHAR2 DEFAULT NULL
         ,p_information44                VARCHAR2 DEFAULT NULL
         ,p_information45                VARCHAR2 DEFAULT NULL
         ,p_information46                VARCHAR2 DEFAULT NULL
         ,p_information47                VARCHAR2 DEFAULT NULL
         ,p_information48                VARCHAR2 DEFAULT NULL
         ,p_information49                VARCHAR2 DEFAULT NULL
         ,p_information50                VARCHAR2 DEFAULT NULL
         ,p_information51                VARCHAR2 DEFAULT NULL
         ,p_information52                VARCHAR2 DEFAULT NULL
         ,p_information53                VARCHAR2 DEFAULT NULL
         ,p_information54                VARCHAR2 DEFAULT NULL
         ,p_information55                VARCHAR2 DEFAULT NULL
         ,p_information56                VARCHAR2 DEFAULT NULL
         ,p_information57                VARCHAR2 DEFAULT NULL
         ,p_information58                VARCHAR2 DEFAULT NULL
         ,p_information59                VARCHAR2 DEFAULT NULL
         ,p_information60                VARCHAR2 DEFAULT NULL
         ,p_information61                VARCHAR2 DEFAULT NULL
         ,p_information62                VARCHAR2 DEFAULT NULL
         ,p_information63                VARCHAR2 DEFAULT NULL
         ,p_information64                VARCHAR2 DEFAULT NULL
         ,p_information65                VARCHAR2 DEFAULT NULL
         ,p_information66                VARCHAR2 DEFAULT NULL
         ,p_information67                VARCHAR2 DEFAULT NULL
         ,p_information68                VARCHAR2 DEFAULT NULL
         ,p_information69                VARCHAR2 DEFAULT NULL
         ,p_information70                VARCHAR2 DEFAULT NULL
         ,p_information71                VARCHAR2 DEFAULT NULL
         ,p_information72                VARCHAR2 DEFAULT NULL
         ,p_information73                VARCHAR2 DEFAULT NULL
         ,p_information74                VARCHAR2 DEFAULT NULL
         ,p_information75                VARCHAR2 DEFAULT NULL
         ,p_information76                VARCHAR2 DEFAULT NULL
         ,p_information77                VARCHAR2 DEFAULT NULL
         ,p_information78                VARCHAR2 DEFAULT NULL
         ,p_information79                VARCHAR2 DEFAULT NULL
         ,p_information80                VARCHAR2 DEFAULT NULL
         ,p_information81                VARCHAR2 DEFAULT NULL
         ,p_information82                VARCHAR2 DEFAULT NULL
         ,p_information83                VARCHAR2 DEFAULT NULL
         ,p_information84                VARCHAR2 DEFAULT NULL
         ,p_information85                VARCHAR2 DEFAULT NULL
         ,p_information86                VARCHAR2 DEFAULT NULL
         ,p_information87                VARCHAR2 DEFAULT NULL
         ,p_information88                VARCHAR2 DEFAULT NULL
         ,p_information89                VARCHAR2 DEFAULT NULL
         ,p_information90                VARCHAR2 DEFAULT NULL
         ,p_information91                VARCHAR2 DEFAULT NULL
         ,p_information92                VARCHAR2 DEFAULT NULL
         ,p_information93                VARCHAR2 DEFAULT NULL
         ,p_information94                VARCHAR2 DEFAULT NULL
         ,p_information95                VARCHAR2 DEFAULT NULL
         ,p_information96                VARCHAR2 DEFAULT NULL
         ,p_information97                VARCHAR2 DEFAULT NULL
         ,p_information98                VARCHAR2 DEFAULT NULL
         ,p_information99                VARCHAR2 DEFAULT NULL
         ,p_information100               VARCHAR2 DEFAULT NULL
         ,p_information101               VARCHAR2 DEFAULT NULL
         ,p_information102               VARCHAR2 DEFAULT NULL
         ,p_information103               VARCHAR2 DEFAULT NULL
         ,p_information104               VARCHAR2 DEFAULT NULL
         ,p_information105               VARCHAR2 DEFAULT NULL
         ,p_information106               VARCHAR2 DEFAULT NULL
         ,p_information107               VARCHAR2 DEFAULT NULL
         ,p_information108               VARCHAR2 DEFAULT NULL
         ,p_information109               VARCHAR2 DEFAULT NULL
         ,p_information110               VARCHAR2 DEFAULT NULL
         ,p_information111               VARCHAR2 DEFAULT NULL
         ,p_information112               VARCHAR2 DEFAULT NULL
         ,p_information113               VARCHAR2 DEFAULT NULL
         ,p_information114               VARCHAR2 DEFAULT NULL
         ,p_information115               VARCHAR2 DEFAULT NULL
         ,p_information116               VARCHAR2 DEFAULT NULL
         ,p_information117               VARCHAR2 DEFAULT NULL
         ,p_information118               VARCHAR2 DEFAULT NULL
         ,p_information119               VARCHAR2 DEFAULT NULL
         ,p_information120               VARCHAR2 DEFAULT NULL
         ,p_information121               VARCHAR2 DEFAULT NULL
         ,p_information122               VARCHAR2 DEFAULT NULL
         ,p_information123               VARCHAR2 DEFAULT NULL
         ,p_information124               VARCHAR2 DEFAULT NULL
         ,p_information125               VARCHAR2 DEFAULT NULL
         ,p_information126               VARCHAR2 DEFAULT NULL
         ,p_information127               VARCHAR2 DEFAULT NULL
         ,p_information128               VARCHAR2 DEFAULT NULL
         ,p_information129               VARCHAR2 DEFAULT NULL
         ,p_information130               VARCHAR2 DEFAULT NULL
         ,p_information131               VARCHAR2 DEFAULT NULL
         ,p_information132               VARCHAR2 DEFAULT NULL
         ,p_information133               VARCHAR2 DEFAULT NULL
         ,p_information134               VARCHAR2 DEFAULT NULL
         ,p_information135               VARCHAR2 DEFAULT NULL
         ,p_information136               VARCHAR2 DEFAULT NULL
         ,p_information137               VARCHAR2 DEFAULT NULL
         ,p_information138               VARCHAR2 DEFAULT NULL
         ,p_information139               VARCHAR2 DEFAULT NULL
         ,p_information140               VARCHAR2 DEFAULT NULL
         ,p_information141               VARCHAR2 DEFAULT NULL
         ,p_information142               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information143               VARCHAR2 DEFAULT NULL
         ,p_information144               VARCHAR2 DEFAULT NULL
         ,p_information145               VARCHAR2 DEFAULT NULL
         ,p_information146               VARCHAR2 DEFAULT NULL
         ,p_information147               VARCHAR2 DEFAULT NULL
         ,p_information148               VARCHAR2 DEFAULT NULL
         ,p_information149               VARCHAR2 DEFAULT NULL
         ,p_information150               VARCHAR2 DEFAULT NULL
         */
         ,p_information151               VARCHAR2 DEFAULT NULL
         ,p_information152               VARCHAR2 DEFAULT NULL
         ,p_information153               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information154               VARCHAR2 DEFAULT NULL
         ,p_information155               VARCHAR2 DEFAULT NULL
         ,p_information156               VARCHAR2 DEFAULT NULL
         ,p_information157               VARCHAR2 DEFAULT NULL
         ,p_information158               VARCHAR2 DEFAULT NULL
         ,p_information159               VARCHAR2 DEFAULT NULL
         */
         ,p_information160               VARCHAR2 DEFAULT NULL
         ,p_information161               VARCHAR2 DEFAULT NULL
         ,p_information162               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information163               VARCHAR2 DEFAULT NULL
         ,p_information164               VARCHAR2 DEFAULT NULL
         ,p_information165               VARCHAR2 DEFAULT NULL
         */
         ,p_information166               VARCHAR2 DEFAULT NULL
         ,p_information167               VARCHAR2 DEFAULT NULL
         ,p_information168               VARCHAR2 DEFAULT NULL
         ,p_information169               VARCHAR2 DEFAULT NULL
         ,p_information170               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information171               VARCHAR2 DEFAULT NULL
         ,p_information172               VARCHAR2 DEFAULT NULL
         */
         ,p_information173               VARCHAR2 DEFAULT NULL
         ,p_information174               VARCHAR2 DEFAULT NULL
         ,p_information175               VARCHAR2 DEFAULT NULL
         ,p_information176               VARCHAR2 DEFAULT NULL
         ,p_information177               VARCHAR2 DEFAULT NULL
         ,p_information178               VARCHAR2 DEFAULT NULL
         ,p_information179               VARCHAR2 DEFAULT NULL
         ,p_information180               VARCHAR2 DEFAULT NULL
         ,p_information181               VARCHAR2 DEFAULT NULL
         ,p_information182               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information183               VARCHAR2 DEFAULT NULL
         ,p_information184               VARCHAR2 DEFAULT NULL
         */
         ,p_information185               VARCHAR2 DEFAULT NULL
         ,p_information186               VARCHAR2 DEFAULT NULL
         ,p_information187               VARCHAR2 DEFAULT NULL
         ,p_information188               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information189               VARCHAR2 DEFAULT NULL
         */
         ,p_information190               VARCHAR2 DEFAULT NULL
         ,p_information191               VARCHAR2 DEFAULT NULL
         ,p_information192               VARCHAR2 DEFAULT NULL
         ,p_information193               VARCHAR2 DEFAULT NULL
         ,p_information194               VARCHAR2 DEFAULT NULL
         ,p_information195               VARCHAR2 DEFAULT NULL
         ,p_information196               VARCHAR2 DEFAULT NULL
         ,p_information197               VARCHAR2 DEFAULT NULL
         ,p_information198               VARCHAR2 DEFAULT NULL
         ,p_information199               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information200               VARCHAR2 DEFAULT NULL
         ,p_information201               VARCHAR2 DEFAULT NULL
         ,p_information202               VARCHAR2 DEFAULT NULL
         ,p_information203               VARCHAR2 DEFAULT NULL
         ,p_information204               VARCHAR2 DEFAULT NULL
         ,p_information205               VARCHAR2 DEFAULT NULL
         ,p_information206               VARCHAR2 DEFAULT NULL
         ,p_information207               VARCHAR2 DEFAULT NULL
         ,p_information208               VARCHAR2 DEFAULT NULL
         ,p_information209               VARCHAR2 DEFAULT NULL
         ,p_information210               VARCHAR2 DEFAULT NULL
         ,p_information211               VARCHAR2 DEFAULT NULL
         ,p_information212               VARCHAR2 DEFAULT NULL
         ,p_information213               VARCHAR2 DEFAULT NULL
         ,p_information214               VARCHAR2 DEFAULT NULL
         ,p_information215               VARCHAR2 DEFAULT NULL
         */
         ,p_information216               VARCHAR2 DEFAULT NULL
         ,p_information217               VARCHAR2 DEFAULT NULL
         ,p_information218               VARCHAR2 DEFAULT NULL
         ,p_information219               VARCHAR2 DEFAULT NULL
         ,p_information220               VARCHAR2 DEFAULT NULL
         ,p_information221               VARCHAR2 DEFAULT NULL
         ,p_information222               VARCHAR2 DEFAULT NULL
         ,p_information223               VARCHAR2 DEFAULT NULL
         ,p_information224               VARCHAR2 DEFAULT NULL
         ,p_information225               VARCHAR2 DEFAULT NULL
         ,p_information226               VARCHAR2 DEFAULT NULL
         ,p_information227               VARCHAR2 DEFAULT NULL
         ,p_information228               VARCHAR2 DEFAULT NULL
         ,p_information229               VARCHAR2 DEFAULT NULL
         ,p_information230               VARCHAR2 DEFAULT NULL
         ,p_information231               VARCHAR2 DEFAULT NULL
         ,p_information232               VARCHAR2 DEFAULT NULL
         ,p_information233               VARCHAR2 DEFAULT NULL
         ,p_information234               VARCHAR2 DEFAULT NULL
         ,p_information235               VARCHAR2 DEFAULT NULL
         ,p_information236               VARCHAR2 DEFAULT NULL
         ,p_information237               VARCHAR2 DEFAULT NULL
         ,p_information238               VARCHAR2 DEFAULT NULL
         ,p_information239               VARCHAR2 DEFAULT NULL
         ,p_information240               VARCHAR2 DEFAULT NULL
         ,p_information241               VARCHAR2 DEFAULT NULL
         ,p_information242               VARCHAR2 DEFAULT NULL
         ,p_information243               VARCHAR2 DEFAULT NULL
         ,p_information244               VARCHAR2 DEFAULT NULL
         ,p_information245               VARCHAR2 DEFAULT NULL
         ,p_information246               VARCHAR2 DEFAULT NULL
         ,p_information247               VARCHAR2 DEFAULT NULL
         ,p_information248               VARCHAR2 DEFAULT NULL
         ,p_information249               VARCHAR2 DEFAULT NULL
         ,p_information250               VARCHAR2 DEFAULT NULL
         ,p_information251               VARCHAR2 DEFAULT NULL
         ,p_information252               VARCHAR2 DEFAULT NULL
         ,p_information253               VARCHAR2 DEFAULT NULL
         ,p_information254               VARCHAR2 DEFAULT NULL
         ,p_information255               VARCHAR2 DEFAULT NULL
         ,p_information256               VARCHAR2 DEFAULT NULL
         ,p_information257               VARCHAR2 DEFAULT NULL
         ,p_information258               VARCHAR2 DEFAULT NULL
         ,p_information259               VARCHAR2 DEFAULT NULL
         ,p_information260               VARCHAR2 DEFAULT NULL
         ,p_information261               VARCHAR2 DEFAULT NULL
         ,p_information262               VARCHAR2 DEFAULT NULL
         ,p_information263               VARCHAR2 DEFAULT NULL
         ,p_information264               VARCHAR2 DEFAULT NULL
         ,p_information265               VARCHAR2 DEFAULT NULL
         ,p_information266               VARCHAR2 DEFAULT NULL
         ,p_information267               VARCHAR2 DEFAULT NULL
         ,p_information268               VARCHAR2 DEFAULT NULL
         ,p_information269               VARCHAR2 DEFAULT NULL
         ,p_information270               VARCHAR2 DEFAULT NULL
         ,p_information271               VARCHAR2 DEFAULT NULL
         ,p_information272               VARCHAR2 DEFAULT NULL
         ,p_information273               VARCHAR2 DEFAULT NULL
         ,p_information274               VARCHAR2 DEFAULT NULL
         ,p_information275               VARCHAR2 DEFAULT NULL
         ,p_information276               VARCHAR2 DEFAULT NULL
         ,p_information277               VARCHAR2 DEFAULT NULL
         ,p_information278               VARCHAR2 DEFAULT NULL
         ,p_information279               VARCHAR2 DEFAULT NULL
         ,p_information280               VARCHAR2 DEFAULT NULL
         ,p_information281               VARCHAR2 DEFAULT NULL
         ,p_information282               VARCHAR2 DEFAULT NULL
         ,p_information283               VARCHAR2 DEFAULT NULL
         ,p_information284               VARCHAR2 DEFAULT NULL
         ,p_information285               VARCHAR2 DEFAULT NULL
         ,p_information286               VARCHAR2 DEFAULT NULL
         ,p_information287               VARCHAR2 DEFAULT NULL
         ,p_information288               VARCHAR2 DEFAULT NULL
         ,p_information289               VARCHAR2 DEFAULT NULL
         ,p_information290               VARCHAR2 DEFAULT NULL
         ,p_information291               VARCHAR2 DEFAULT NULL
         ,p_information292               VARCHAR2 DEFAULT NULL
         ,p_information293               VARCHAR2 DEFAULT NULL
         ,p_information294               VARCHAR2 DEFAULT NULL
         ,p_information295               VARCHAR2 DEFAULT NULL
         ,p_information296               VARCHAR2 DEFAULT NULL
         ,p_information297               VARCHAR2 DEFAULT NULL
         ,p_information298               VARCHAR2 DEFAULT NULL
         ,p_information299               VARCHAR2 DEFAULT NULL
         ,p_information300               VARCHAR2 DEFAULT NULL
         ,p_information301               VARCHAR2 DEFAULT NULL
         ,p_information302               VARCHAR2 DEFAULT NULL
         ,p_information303               VARCHAR2 DEFAULT NULL
         ,p_information304               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information305               VARCHAR2 DEFAULT NULL
         */
         ,p_information306               VARCHAR2 DEFAULT NULL
         ,p_information307               VARCHAR2 DEFAULT NULL
         ,p_information308               VARCHAR2 DEFAULT NULL
         ,p_information309               VARCHAR2 DEFAULT NULL
         ,p_information310               VARCHAR2 DEFAULT NULL
         ,p_information311               VARCHAR2 DEFAULT NULL
         ,p_information312               VARCHAR2 DEFAULT NULL
         ,p_information313               VARCHAR2 DEFAULT NULL
         ,p_information314               VARCHAR2 DEFAULT NULL
         ,p_information315               VARCHAR2 DEFAULT NULL
         ,p_information316               VARCHAR2 DEFAULT NULL
         ,p_information317               VARCHAR2 DEFAULT NULL
         ,p_information318               VARCHAR2 DEFAULT NULL
         ,p_information319               VARCHAR2 DEFAULT NULL
         ,p_information320               VARCHAR2 DEFAULT NULL

         /* Extra Reserved Columns
         ,p_information321               VARCHAR2 DEFAULT NULL
         ,p_information322               VARCHAR2 DEFAULT NULL
         */
         ,p_information323               VARCHAR2 DEFAULT NULL
         ,p_datetrack_mode               VARCHAR2 DEFAULT NULL
         ,p_table_alias                  VARCHAR2 DEFAULT NULL
   ) is
       -- Bug : 4354708
    l_last_update_date            date;
    l_last_updated_by             number(15);
    l_last_update_login           number(15);
    l_created_by                  number(15);
    l_creation_date               date;
    l_schema                      varchar2(100);
    l_industry                    varchar2(100);
    l_install_status              varchar2(100);
    -- Bug : 4354708
    cursor c2 is
      select transaction_category_id
      from pqh_transaction_categories tc
      where tc.short_name = g_TRANS_CATEGORY_NAME ;
    --
    cursor c3(v_context_business_group_id number, v_transaction_category_id number) is
      select copy_entity_txn_id
      from pqh_copy_entity_txns cet
      where cet.display_name = p_display_name
        and   cet.context_business_group_id = v_context_business_group_id
        and   cet.transaction_category_id = v_transaction_category_id;
    --
    cursor c4 is
      select table_route_id
      from pqh_table_route tr
      where table_alias = p_table_alias
        and tr.from_clause = 'OAB' ;

    --Bug : 4354708
    cursor c_trig_cpe is
      select null
      from all_triggers
      where table_name = 'BEN_COPY_ENTITY_RESULTS'
        and trigger_name = 'BEN_COPY_ENTITY_RESULTS_WHO'
        and table_owner = l_schema
	    and status = 'ENABLED';
    --Bug : 4354708
    --
    l_dummy                       varchar2(30) ;
    l_copy_entity_txn_id          number(15);
    l_object_version_number       number(7) := 1 ;
    l_copy_entity_attrib_id       number(15);
    l_table_route_id              number(15);
    l_copy_entity_result_id       number(15);
    l_business_group_id           number ;
    l_transaction_category_id     number ;
    --
  begin
    --
    /* For seeded FHR copy process, set context_business_group_id to 0 */
    if p_DISPLAY_NAME = 'GHR_FEHB_SEED_PROGRAM_DESIGN' then
      l_business_group_id := 0;
    else
      l_business_group_id := fnd_global.PER_BUSINESS_GROUP_ID ;
    end if;
    --
    if p_mode = 'BEGIN' then

      g_DISPLAY_NAME                 := p_DISPLAY_NAME;
      g_SRC_EFFECTIVE_DATE           := p_SRC_EFFECTIVE_DATE;
      g_MIRROR_ENTITY_RESULT_ID      := p_MIRROR_ENTITY_RESULT_ID;
      g_OWNER                        := p_OWNER;
      g_TRANS_CATEGORY_NAME          := p_TRANS_CATEGORY_NAME;
      g_RESULT_TYPE_CD               := p_RESULT_TYPE_CD;
      g_NUMBER_OF_COPIES             := p_NUMBER_OF_COPIES;
      g_STATUS                       := p_STATUS;
      g_mirror_src_entity_result_id  := p_mirror_src_entity_result_id;
      g_parent_entity_result_id      := p_parent_entity_result_id;
      g_pd_mr_src_entity_result_id   := p_pd_mr_src_entity_result_id;
      g_pd_parent_entity_result_id   := p_pd_parent_entity_result_id;
      g_gs_mr_src_entity_result_id   := p_gs_mr_src_entity_result_id;
      g_gs_parent_entity_result_id   := p_gs_parent_entity_result_id;
      g_table_name                   := p_table_name;
      g_dml_operation                := p_dml_operation;
      g_information_category         := p_information_category;
      g_information1                 := p_information1;
      g_information2                 := p_information2;
      g_information3                 := p_information3;
      g_information4                 := p_information4;
      g_information5                 := p_information5;
      g_information6                 := p_information6;
      g_information7                 := p_information7;
      g_information8                 := p_information8;
      g_information9                 := p_information9;
      g_information10                := p_information10;
      g_information11                := p_information11;
      g_information12                := p_information12;
      g_information13                := p_information13;
      g_information14                := p_information14;
      g_information15                := p_information15;
      g_information16                := p_information16;
      g_information17                := p_information17;
      g_information18                := p_information18;
      g_information19                := p_information19;
      g_information20                := p_information20;
      g_information21                := p_information21;
      g_information22                := p_information22;
      g_information23                := p_information23;
      g_information24                := p_information24;
      g_information25                := p_information25;
      g_information26                := p_information26;
      g_information27                := p_information27;
      g_information28                := p_information28;
      g_information29                := p_information29;
      g_information30                := p_information30;
      g_information31                := p_information31;
      g_information32                := p_information32;
      g_information33                := p_information33;
      g_information34                := p_information34;
      g_information35                := p_information35;
      g_information36                := p_information36;
      g_information37                := p_information37;
      g_information38                := p_information38;
      g_information39                := p_information39;
      g_information40                := p_information40;
      g_information41                := p_information41;
      g_information42                := p_information42;
      g_information43                := p_information43;
      g_information44                := p_information44;
      g_information45                := p_information45;
      g_information46                := p_information46;
      g_information47                := p_information47;
      g_information48                := p_information48;
      g_information49                := p_information49;
      g_information50                := p_information50;
      g_information51                := p_information51;
      g_information52                := p_information52;
      g_information53                := p_information53;
      g_information54                := p_information54;
      g_information55                := p_information55;
      g_information56                := p_information56;
      g_information57                := p_information57;
      g_information58                := p_information58;
      g_information59                := p_information59;
      g_information60                := p_information60;
      g_information61                := p_information61;
      g_information62                := p_information62;
      g_information63                := p_information63;
      g_information64                := p_information64;
      g_information65                := p_information65;
      g_information66                := p_information66;
      g_information67                := p_information67;
      g_information68                := p_information68;
      g_information69                := p_information69;
      g_information70                := p_information70;
      g_information71                := p_information71;
      g_information72                := p_information72;
      g_information73                := p_information73;
      g_information74                := p_information74;
      g_information75                := p_information75;
      g_information76                := p_information76;
      g_information77                := p_information77;
      g_information78                := p_information78;
      g_information79                := p_information79;
      g_information80                := p_information80;
      g_information81                := p_information81;
      g_information82                := p_information82;
      g_information83                := p_information83;
      g_information84                := p_information84;
      g_information85                := p_information85;
      g_information86                := p_information86;
      g_information87                := p_information87;
      g_information88                := p_information88;
      g_information89                := p_information89;
      g_information90                := p_information90;

    elsif p_mode = 'END' then

      if (g_DISPLAY_NAME is not null and p_DISPLAY_NAME = g_DISPLAY_NAME)
        and (g_SRC_EFFECTIVE_DATE is not null and p_SRC_EFFECTIVE_DATE = g_SRC_EFFECTIVE_DATE)
        and (g_MIRROR_ENTITY_RESULT_ID is not null and p_MIRROR_ENTITY_RESULT_ID = g_MIRROR_ENTITY_RESULT_ID)
      then

        if g_perf_transaction_category_id is null then
          open c2 ;
          hr_utility.set_location(' Step 30 ',30);
          fetch c2 into l_transaction_category_id ;
          g_perf_transaction_category_id := l_transaction_category_id;
          if c2%notfound then
            -- Throw error
            close c2 ;
            return ;
          end if ;
          close c2;
        else
          l_transaction_category_id := g_perf_transaction_category_id;
        end if;
        --
        --
        -- Bug : 4354708
        --
        l_found := fnd_installation.get_app_info ('BEN', l_install_status, l_industry, l_schema);
        --
        open c_trig_cpe;
        fetch c_trig_cpe into l_dummy;
        if c_trig_cpe%notfound then
              --
          -- WHO Trigger is not defined on the table BEN_COPY_ENTITY_RESULTS
          -- Set WHO columns
              l_last_update_date    := sysdate;
          l_last_updated_by     := fnd_global.user_id;
          l_last_update_login   := fnd_global.login_id;
          l_created_by          := fnd_global.user_id;
          l_creation_date       := sysdate;
          --
        else
          --
              l_last_update_date    := null;
          l_last_updated_by     := null;
          l_last_update_login   := null;
          l_created_by          := null;
          l_creation_date       := null;
          --
        end if;
        --
        close c_trig_cpe;
        --
        --Bug : 4354708
        --
        Begin

          if g_perf_copy_entity_txn_id is null then
            open c3(l_business_group_id , l_transaction_category_id) ;
            fetch c3 into l_copy_entity_txn_id ;
            g_perf_copy_entity_txn_id := l_copy_entity_txn_id;
            close c3;
          else
            l_copy_entity_txn_id := g_perf_copy_entity_txn_id;
          end if;
          --
          open c4 ;
          fetch c4 into l_table_route_id ;
          close c4;
          --

          insert into ben_copy_entity_results
          (      copy_entity_result_id
       		,copy_entity_txn_id
        	,src_copy_entity_result_id
      		,result_type_cd
      		,number_of_copies
      		,mirror_entity_result_id
      		,mirror_src_entity_result_id
      		,parent_entity_result_id
      		,pd_mirror_src_entity_result_id
      		,pd_parent_entity_result_id
      		,gs_mirror_src_entity_result_id
      		,gs_parent_entity_result_id
      		,table_name
      		,table_route_id
      		,status
      		,dml_operation
      		,information_category
      		,information1
      		,information2
      		,information3
      		,information4
      		,information5
      		,information6
      		,information7
      		,information8
      		,information9
      		,information10
      		,information11
      		,information12
      		,information13
      		,information14
      		,information15
      		,information16
      		,information17
      		,information18
      		,information19
      		,information20
      		,information21
      		,information22
      		,information23
      		,information24
        	,information25
      		,information26
        	,information27
      		,information28
      		,information29
      		,information30
      		,information31
      		,information32
      		,information33
      		,information34
      		,information35
      		,information36
      		,information37
        	,information38
      		,information39
      		,information40
      		,information41
      		,information42
      		,information43
      		,information44
        	,information45
      		,information46
      		,information47
      		,information48
      		,information49
      		,information50
      		,information51
      		,information52
      		,information53
      		,information54
      		,information55
      		,information56
      		,information57
      		,information58
      		,information59
      		,information60
      		,information61
        	,information62
      		,information63
      		,information64
      		,information65
      		,information66
      		,information67
      		,information68
      		,information69
      		,information70
        	,information71
      		,information72
      		,information73
      		,information74
      		,information75
      		,information76
      		,information77
      		,information78
      		,information79
      		,information80
      		,information81
      		,information82
      		,information83
      		,information84
      		,information85
        	,information86
      		,information87
      		,information88
      		,information89
      		,information90
      		,information91
      		,information92
      		,information93
      		,information94
      		,information95
      		,information96
      		,information97
      		,information98
      		,information99
      		,information100
      		,information101
      		,information102
      		,information103
      		,information104
      		,information105
      		,information106
      		,information107
        	,information108
      		,information109
      		,information110
      		,information111
      		,information112
      		,information113
      		,information114
      		,information115
      		,information116
      		,information117
      		,information118
      		,information119
      		,information120
      		,information121
      		,information122
      		,information123
      		,information124
      		,information125
      		,information126
      		,information127
      		,information128
      		,information129
      		,information130
      		,information131
      		,information132
      		,information133
      		,information134
      		,information135
      		,information136
        	,information137
      		,information138
      		,information139
      		,information140
      		,information141
      		,information142

                  /* Extra Reserved Columns
      		,information143
      		,information144
      		,information145
      		,information146
      		,information147
      		,information148
      		,information149
      		,information150
                  */
      		,information151
      		,information152
      		,information153

                  /* Extra Reserved Columns
      		,information154
      		,information155
      		,information156
      		,information157
      		,information158
      		,information159
                  */
      		,information160
      		,information161
      		,information162

                  /* Extra Reserved Columns
      		,information163
      		,information164
      		,information165
                  */
      		,information166
      		,information167
      		,information168
      		,information169
      		,information170

                  /* Extra Reserved Columns
      		,information171
      		,information172
                  */
      		,information173
      		,information174
      		,information175
      		,information176
      		,information177
      		,information178
        	,information179
      		,information180
      		,information181
      		,information182

                  /* Extra Reserved Columns
      		,information183
      		,information184
                  */
         	,information185
      		,information186
      		,information187
      		,information188

                  /* Extra Reserved Columns
      		,information189
                  */
      		,information190
      		,information191
      		,information192
      		,information193
      		,information194
      		,information195
      		,information196
      		,information197
      		,information198
      		,information199

                  /* Extra Reserved Columns
      		,information200
      		,information201
      		,information202
      		,information203
      		,information204
      		,information205
      		,information206
      		,information207
      		,information208
      		,information209
      		,information210
      		,information211
      		,information212
      		,information213
      		,information214
      		,information215
                  */
      		,information216
      		,information217
      		,information218
      		,information219
      		,information220
      		,information221
      		,information222
      		,information223
        	,information224
      		,information225
      		,information226
      		,information227
      		,information228
      		,information229
      		,information230
      		,information231
      		,information232
      		,information233
      		,information234
      		,information235
      		,information236
      		,information237
      		,information238
      		,information239
      		,information240
      		,information241
      		,information242
      		,information243
        	,information244
      		,information245
      		,information246
      		,information247
      		,information248
      		,information249
      		,information250
      		,information251
      		,information252
      		,information253
      		,information254
      		,information255
      		,information256
      		,information257
      		,information258
      		,information259
      		,information260
      		,information261
      		,information262
      		,information263
      		,information264
      		,information265
      		,information266
      		,information267
      		,information268
      		,information269
      		,information270
      		,information271
      		,information272
        	,information273
      		,information274
      		,information275
      		,information276
      		,information277
      		,information278
      		,information279
      		,information280
      		,information281
      		,information282
      		,information283
      		,information284
      		,information285
      		,information286
      		,information287
      		,information288
      		,information289
      		,information290
      		,information291
      		,information292
      		,information293
      		,information294
      		,information295
      		,information296
      		,information297
      		,information298
      		,information299
      		,information300
      		,information301
      		,information302
      		,information303
      		,information304

                  /* Extra Reserved Columns
      		,information305
                  */
      		,information306
      		,information307
      		,information308
      		,information309
      		,information310
      		,information311
      		,information312
      		,information313
      		,information314
      		,information315
      		,information316
      		,information317
      		,information318
      		,information319
      		,information320

                  /* Extra Reserved Columns
      		,information321
      		,information322
                  */
      		,information323
      		,datetrack_mode
      		,table_alias
      		,object_version_number
            ,last_update_date        --Bug : 4354708
            ,last_updated_by
            ,last_update_login
            ,created_by
            ,creation_date           --Bug : 4354708
         	 )
  	    Values
    	    (  ben_copy_entity_results_s.nextval
              ,l_copy_entity_txn_id
              ,NULL    -- g_src_copy_entity_result_id -- Start  global variables
              ,g_result_type_cd
    	      ,to_number(g_number_of_copies)
    	      ,to_number(g_mirror_entity_result_id)
    	      ,to_number(g_mirror_src_entity_result_id)
    	      ,to_number(g_parent_entity_result_id)
    	      ,to_number(g_pd_mr_src_entity_result_id)
    	      ,to_number(g_pd_parent_entity_result_id)
    	      ,to_number(g_gs_mr_src_entity_result_id)
    	      ,to_number(g_gs_parent_entity_result_id)
    	      ,g_table_name
    	      ,l_table_route_id
    	      ,g_status
    	      ,g_dml_operation
    	      ,g_information_category
    	      ,to_number(g_information1)
    	      ,to_date(g_information2,'DD/MM/YYYY')
    	      ,to_date(g_information3,'DD/MM/YYYY')
    	      ,to_number(g_information4)
    	      ,g_information5
    	      ,g_information6
    	      ,g_information7
    	      ,g_information8
              ,g_information9
    	      ,to_date(g_information10,'DD/MM/YYYY')
   	      ,g_information11
    	      ,g_information12
    	      ,g_information13
    	      ,g_information14
    	      ,g_information15
    	      ,g_information16
    	      ,g_information17
    	      ,g_information18
    	      ,g_information19
    	      ,g_information20
    	      ,g_information21
    	      ,g_information22
    	      ,g_information23
    	      ,g_information24
    	      ,g_information25
    	      ,g_information26
    	      ,g_information27
    	      ,g_information28
    	      ,g_information29
    	      ,g_information30
    	      ,g_information31
    	      ,g_information32
    	      ,g_information33
    	      ,g_information34
    	      ,g_information35
    	      ,g_information36
    	      ,g_information37
    	      ,g_information38
    	      ,g_information39
    	      ,g_information40
    	      ,g_information41
    	      ,g_information42
    	      ,g_information43
    	      ,g_information44
    	      ,g_information45
    	      ,g_information46
    	      ,g_information47
    	      ,g_information48
    	      ,g_information49
    	      ,g_information50
    	      ,g_information51
    	      ,g_information52
    	      ,g_information53
    	      ,g_information54
    	      ,g_information55
    	      ,g_information56
    	      ,g_information57
    	      ,g_information58
    	      ,g_information59
    	      ,g_information60
    	      ,g_information61
   	      ,g_information62
    	      ,g_information63
    	      ,g_information64
    	      ,g_information65
    	      ,g_information66
    	      ,g_information67
    	      ,g_information68
    	      ,g_information69
    	      ,g_information70
    	      ,g_information71
   	      ,g_information72
    	      ,g_information73
    	      ,g_information74
    	      ,g_information75
    	      ,g_information76
    	      ,g_information77
    	      ,g_information78
    	      ,g_information79
    	      ,g_information80
    	      ,g_information81
    	      ,g_information82
    	      ,g_information83
    	      ,g_information84
    	      ,g_information85
    	      ,g_information86
    	      ,g_information87
    	      ,g_information88
    	      ,g_information89
    	      ,g_information90 -- End  global variables
    	      ,p_information91
    	      ,p_information92
   	      ,p_information93
    	      ,p_information94
    	      ,p_information95
    	      ,p_information96
    	      ,p_information97
    	      ,p_information98
   	      ,p_information99
    	      ,p_information100
    	      ,p_information101
    	      ,p_information102
    	      ,p_information103
    	      ,p_information104
    	      ,p_information105
    	      ,p_information106
    	      ,p_information107
    	      ,p_information108
    	      ,p_information109
    	      ,p_information110
    	      ,p_information111
    	      ,p_information112
    	      ,p_information113
    	      ,p_information114
    	      ,p_information115
    	      ,p_information116
    	      ,p_information117
    	      ,p_information118
    	      ,p_information119
    	      ,p_information120
    	      ,p_information121
    	      ,p_information122
    	      ,p_information123
    	      ,p_information124
    	      ,p_information125
   	      ,p_information126
    	      ,p_information127
    	      ,p_information128
    	      ,p_information129
    	      ,p_information130
    	      ,p_information131
    	      ,p_information132
    	      ,p_information133
    	      ,p_information134
    	      ,p_information135
	      ,p_information136
    	      ,p_information137
    	      ,p_information138
    	      ,p_information139
    	      ,p_information140
    	      ,p_information141
    	      ,p_information142

            /* Extra Reserved Columns
    	      ,p_information143
    	      ,p_information144
    	      ,p_information145
    	      ,p_information146
    	      ,p_information147
    	      ,p_information148
    	      ,p_information149
    	      ,p_information150
            */
    	      ,p_information151
    	      ,p_information152
    	      ,p_information153

            /* Extra Reserved Columns
    	      ,p_information154
    	      ,p_information155
    	      ,p_information156
    	      ,p_information157
    	      ,p_information158
    	      ,p_information159
            */
    	      ,to_number(p_information160)
   	      ,to_number(p_information161)
    	      ,to_number(p_information162)

            /* Extra Reserved Columns
    	      ,to_number(p_information163)
    	      ,to_number(p_information164)
    	      ,to_number(p_information165)
            */

   	      ,to_date(p_information166,'DD/MM/YYYY')
    	      ,to_date(p_information167,'DD/MM/YYYY')
    	      ,to_date(p_information168,'DD/MM/YYYY')
    	      ,to_number(p_information169)
    	      ,p_information170

            /* Extra Reserved Columns
    	      ,p_information171
   	      ,p_information172
            */
    	      ,p_information173
    	      ,to_number(p_information174)
    	      ,p_information175
    	      ,to_number(p_information176)
    	      ,p_information177
              ,to_number(p_information178)
    	      ,p_information179
    	      ,to_number(p_information180)
    	      ,p_information181
    	      ,p_information182

            /* Extra Reserved Columns
    	      ,p_information183
    	      ,p_information184
            */
    	      ,p_information185
   	      ,p_information186
    	      ,p_information187
    	      ,p_information188

            /* Extra Reserved Columns
    	      ,p_information189
            */
    	      ,p_information190
    	      ,p_information191
    	      ,p_information192
    	      ,p_information193
    	      ,p_information194
    	      ,p_information195
    	      ,p_information196
    	      ,p_information197
    	      ,p_information198
   	      ,p_information199

            /* Extra Reserved Columns
    	      ,p_information200
    	      ,p_information201
    	      ,p_information202
    	      ,p_information203
    	      ,p_information204
    	      ,p_information205
    	      ,p_information206
    	      ,p_information207
    	      ,p_information208
    	      ,p_information209
    	      ,p_information210
    	      ,p_information211
    	      ,p_information212
    	      ,p_information213
    	      ,p_information214
    	      ,p_information215
            */
    	      ,p_information216
    	      ,p_information217
    	      ,p_information218
    	      ,p_information219
    	      ,p_information220
    	      ,to_number(p_information221)
    	      ,to_number(p_information222)
    	      ,to_number(p_information223)
    	      ,to_number(p_information224)
              ,to_number(p_information225)
    	      ,to_number(p_information226)
    	      ,to_number(p_information227)
    	      ,to_number(p_information228)
    	      ,to_number(p_information229)
    	      ,to_number(p_information230)
    	      ,to_number(p_information231)
    	      ,to_number(p_information232)
    	      ,to_number(p_information233)
    	      ,to_number(p_information234)
    	      ,to_number(p_information235)
    	      ,to_number(p_information236)
    	      ,to_number(p_information237)
    	      ,to_number(p_information238)
    	      ,to_number(p_information239)
    	      ,to_number(p_information240)
    	      ,to_number(p_information241)
    	      ,to_number(p_information242)
    	      ,to_number(p_information243)
    	      ,to_number(p_information244)
    	      ,to_number(p_information245)
    	      ,to_number(p_information246)
    	      ,to_number(p_information247)
    	      ,to_number(p_information248)
    	      ,to_number(p_information249)
   	      ,to_number(p_information250)
    	      ,to_number(p_information251)
    	      ,to_number(p_information252)
    	      ,to_number(p_information253)
    	      ,to_number(p_information254)
    	      ,to_number(p_information255)
    	      ,to_number(p_information256)
    	      ,to_number(p_information257)
    	      ,to_number(p_information258)
   	      ,to_number(p_information259)
    	      ,to_number(p_information260)
    	      ,to_number(p_information261)
    	      ,to_number(p_information262)
    	      ,to_number(p_information263)
    	      ,to_number(p_information264)
    	      ,to_number(p_information265)
    	      ,to_number(p_information266)
    	      ,to_number(p_information267)
    	      ,to_number(p_information268)
    	      ,to_number(p_information269)
    	      ,to_number(p_information270)
    	      ,to_number(p_information271)
    	      ,to_number(p_information272)
    	      ,to_number(p_information273)
    	      ,to_number(p_information274)
    	      ,to_number(p_information275)
    	      ,to_number(p_information276)
    	      ,to_number(p_information277)
    	      ,to_number(p_information278)
    	      ,to_number(p_information279)
    	      ,to_number(p_information280)
    	      ,to_number(p_information281)
    	      ,to_number(p_information282)
    	      ,to_number(p_information283)
    	      ,to_number(p_information284)
    	      ,to_number(p_information285)
    	      ,to_number(p_information286)
    	      ,to_number(p_information287)
    	      ,to_number(p_information288)
    	      ,to_number(p_information289)
    	      ,to_number(p_information290)
    	      ,to_number(p_information291)
    	      ,to_number(p_information292)
    	      ,to_number(p_information293)
    	      ,to_number(p_information294)
    	      ,to_number(p_information295)
    	      ,to_number(p_information296)
   	      ,to_number(p_information297)
    	      ,to_number(p_information298)
    	      ,to_number(p_information299)
    	      ,to_number(p_information300)
    	      ,to_number(p_information301)
   	      ,to_number(p_information302)
    	      ,to_number(p_information303)
    	      ,to_number(p_information304)

            /* Extra Reserved Columns
   	      ,to_number(p_information305)
            */
    	      ,to_date(p_information306,'DD/MM/YYYY')
    	      ,to_date(p_information307,'DD/MM/YYYY')
    	      ,to_date(p_information308,'DD/MM/YYYY')
    	      ,to_date(p_information309,'DD/MM/YYYY')
    	      ,to_date(p_information310,'DD/MM/YYYY')
    	      ,to_date(p_information311,'DD/MM/YYYY')
    	      ,to_date(p_information312,'DD/MM/YYYY')
   	      ,to_date(p_information313,'DD/MM/YYYY')
    	      ,to_date(p_information314,'DD/MM/YYYY')
    	      ,to_date(p_information315,'DD/MM/YYYY')
              ,to_date(p_information316,'DD/MM/YYYY')
    	      ,to_date(p_information317,'DD/MM/YYYY')
    	      ,to_date(p_information318,'DD/MM/YYYY')
    	      ,to_date(p_information319,'DD/MM/YYYY')
    	      ,to_date(p_information320,'DD/MM/YYYY')

            /* Extra Reserved Columns
    	      ,to_date(p_information321,'DD/MM/YYYY')
    	      ,to_date(p_information322,'DD/MM/YYYY')
            */
    	      ,p_information323
    	      ,p_datetrack_mode
    	      ,p_table_alias
    	      ,l_object_version_number
              ,l_last_update_date        --Bug : 4354708
              ,l_last_updated_by
              ,l_last_update_login
              ,l_created_by
              ,l_creation_date           --Bug : 4354708
    	    );

          --
          hr_utility.set_location(' Leaving:'||l_proc, 10);
        Exception
          When hr_api.check_integrity_violated Then
            -- A check constraint has been violated
            pqh_cer_shd.constraint_error
                 (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When hr_api.parent_integrity_violated Then
            -- Parent integrity has been violated
            pqh_cer_shd.constraint_error
                 (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When hr_api.unique_integrity_violated Then
            -- Unique integrity has been violated
            pqh_cer_shd.constraint_error
                 (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
          When Others Then
            Raise;
        End ;
     end if;
    end if; -- p_mode
  end;

end ben_plan_copy_loader;

/
