--------------------------------------------------------
--  DDL for Package Body PQH_GSP_PRGRULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_PRGRULES" As
/* $Header: pqgspelg.pkb 120.15.12000000.2 2007/06/11 09:27:10 sidsaxen noship $ */

type TabCerType is table of number ;

function create_bcer_rec (
    p_bcer_rec   ben_copy_entity_results%rowtype
    )
return number ;



procedure update_child(p_child_cer_id in number,p_master_cer_id in number)
is
begin
 update ben_copy_entity_results
    set gs_parent_entity_result_id = p_master_cer_id
       ,parent_entity_result_id = p_master_cer_id
  where copy_entity_result_id = p_child_cer_id;
end update_child;


--<-------- procedure upd_info1 -------->
-- purpose -
-- accept  -
-- do      - create a forall version of upd
-- return  -
--<------------------------- ----------->
procedure upd_info1(p_cerTab in TabCerType)
is
begin
-- nullify info1 of duplicate records.
    forall i in 1..p_cerTab.COUNT
    update ben_copy_entity_results
       set information101 = information1
          ,information1   = null
          ,information263 = null
     where copy_entity_result_id = p_cerTab(i);
end upd_info1;

procedure upd_info1(p_cer_id in number)
is
begin
-- nullify info1 of duplicate records.
    update ben_copy_entity_results
       set information101 = information1
          ,information1   = null
          ,information263 = null
     where copy_entity_result_id = p_cer_id;

end upd_info1;



--<-------- procedure nullify_elp_rec -------->
-- purpose -
-- accept  - cer_id
-- do      - nullifys all info1 columns of ELP and its child records
-- return  -
--<------------------------------------------------>
procedure nullify_elp_rec (
   p_copy_entity_result_id number
  ,p_copy_entity_txn_id number
  )
is
-- get the elp record
cursor cur_elp is
select copy_entity_result_id
  from ben_copy_entity_results
 where copy_entity_result_id  = p_copy_entity_result_id;

-- get the elp child records to be info1 nulled
cursor cur_elp_child(p_parent_cer_id number) is
select copy_entity_result_id
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id;

-- get one more level down for EAP-AGF,ECP-CLA,ECL-CLF
-- ,EHW-HWF,ELS-LSF,EPF-PFF
cursor cur_drv_fct (p_parent_cer_id number) is
select copy_entity_result_id
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id;

begin

for rec_elp in cur_elp
loop
    upd_info1(rec_elp.copy_entity_result_id);
    for rec_elp_child in cur_elp_child(rec_elp.copy_entity_result_id)
    loop
        upd_info1(rec_elp_child.copy_entity_result_id);
        for rec_drv_fct in cur_drv_fct(rec_elp_child.copy_entity_result_id )
        loop
            upd_info1(rec_drv_fct.copy_entity_result_id);
        end loop ;
    end loop;
end loop;

end ;


--<-------- procedure prepare_elp_recs4pdw -------->
-- purpose - To prepare ELP record for pdw
-- accept  - cet_id
-- do      - nullifys all info1 columns of ELP and its child records
-- return  -
--<------------------------------------------------>
procedure prepare_elp_recs4pdw (
   p_copy_entity_txn_id number
  ,p_business_group_id number
   )
is
-- Keep only one record of ELP for one information1
-- Nullify the other's information1 and copy it to inforamtion101
-- Also do the same for all child records of this elp

-- get all elp records
cursor cur_elp is
select information1, copy_entity_result_id
  from ben_copy_entity_results
 where table_alias = 'ELP'
   and copy_entity_txn_id  = p_copy_entity_txn_id
   and information1 is not null
order by information1 ;


-- get the elp child records to be info1 nulled
cursor cur_elp_child(p_parent_cer_id number) is
select *
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id;

-- get one more level down for EAP-AGF,ECP-CLA,ECL-CLF
-- ,EHW-HWF,ELS-LSF,EPF-PFF
cursor cur_drv_fct (p_parent_cer_id number) is
select *
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id;

prev_info1 number ;

begin

prev_info1 := -1 ;

-- for all "non null info1" elp records
for rec_elp in cur_elp
loop
    -- update all but one
    if (rec_elp.information1 = prev_info1)
    then
        upd_info1(rec_elp.copy_entity_result_id);
        for rec_elp_child in cur_elp_child(rec_elp.copy_entity_result_id)
        loop
            upd_info1(rec_elp_child.copy_entity_result_id);
            for rec_drv_fct in cur_drv_fct(rec_elp_child.copy_entity_result_id )
            loop
                upd_info1(rec_drv_fct.copy_entity_result_id);
            end loop ;
        end loop;
    end if;
    prev_info1 := rec_elp.information1 ;
end loop;
end prepare_elp_recs4pdw ;
procedure create_dup_elp_tree (
   p_copy_entity_txn_id number
  ,p_business_group_id  number
  ,p_eligy_prfl_id      number
  ,p_gs_per_id          number
  ,p_per_id             number
  ,p_gm_ser_id          number
   )
is
-- This function accepts eligy_prfl_id and copy_entity_txn_id
-- creates duplicate entry for this ELP (all date track rows)
-- and all its child records(EGN etc)

l_elp_cerid number;
l_child_cerid number;
l_gchild_cerid number;

-- get the elp record to be duplicated
cursor cur_elp is
select *
  from ben_copy_entity_results
 where table_alias = 'ELP'
   and copy_entity_txn_id = p_copy_entity_txn_id
   and information1 = p_eligy_prfl_id;

-- get the elp child records to be duplicated
cursor cur_elp_child(p_parent_cer_id number) is
select *
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id;

-- get one more level down for EAP-AGF,ECP-CLA,ECL-CLF
-- ,EHW-HWF,ELS-LSF,EPF-PFF
cursor cur_drv_fct (p_parent_cer_id number) is
select *
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id;

begin
    hr_utility.set_location('Inside create_dup_elp_tree', 10);
    hr_utility.set_location('p_copy_entity_txn_id'||p_copy_entity_txn_id, 20);
    hr_utility.set_location('p_business_group_id'||p_business_group_id, 30);
    hr_utility.set_location('p_eligy_prfl_id'||p_eligy_prfl_id, 40);
    for rec_elp in cur_elp
    loop
        -- create duplicate ELP record
        l_elp_cerid := create_bcer_rec(rec_elp);
        upd_info1(l_elp_cerid);

        update ben_copy_entity_results
          set gs_parent_entity_result_id = p_gs_per_id
             ,parent_entity_result_id    = p_per_id
             ,Gs_Mirror_Src_Entity_Result_id = p_gm_ser_id
        where copy_entity_result_id      = l_elp_cerid;

        for rec_elp_child in cur_elp_child(rec_elp.copy_entity_result_id)
        loop
            -- create duplicate child record
            l_child_cerid:= create_bcer_rec(rec_elp_child);
            upd_info1(l_child_cerid);
            update_child(l_child_cerid,l_elp_cerid);

            for rec_drv_fct in cur_drv_fct(rec_elp_child.copy_entity_result_id )
            loop
                l_gchild_cerid:= create_bcer_rec(rec_drv_fct);
                upd_info1(l_gchild_cerid);
                update_child(l_gchild_cerid,l_child_cerid);
            end loop ;
        end loop;
    end loop ;
hr_utility.set_location('Leaving create_dup_elp_tree', 10);
end create_dup_elp_tree ;

procedure purge_dup_elp_tree (
   p_copy_entity_txn_id number
  ,p_eligy_prfl_id      number
  ,p_copy_entity_result_id number
   ) is
cursor cur_elp is
select copy_entity_result_id
  from ben_copy_entity_results
  where copy_entity_result_id = p_copy_entity_result_id ;

-- get the elp child records to be deleted
cursor cur_elp_child(p_parent_cer_id number) is
select copy_entity_result_id
  from ben_copy_entity_results
 where gs_parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id
   and information1 is null;

-- get one more level down to delete EAP-AGF,ECP-CLA,ECL-CLF
-- ,EHW-HWF,ELS-LSF,EPF-PFF
cursor cur_drv_fct (p_parent_cer_id number) is
select copy_entity_result_id
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id
   and information1 is null;

tab_cer TabCerType := TabCerType();

begin
    for rec_elp in cur_elp
    loop
        -- duplicate ELP record
        tab_cer.extend;
        tab_cer(tab_cer.count) := rec_elp.copy_entity_result_id;
        for rec_elp_child in cur_elp_child(rec_elp.copy_entity_result_id)
        loop
            -- duplicate child record
            tab_cer.extend;
            tab_cer(tab_cer.count) := rec_elp_child.copy_entity_result_id;
            for rec_drv_fct in cur_drv_fct(rec_elp_child.copy_entity_result_id )
            loop
                tab_cer.extend;
                tab_cer(tab_cer.count) := rec_drv_fct.copy_entity_result_id;
            end loop ;
        end loop;
    end loop ;

    forall i in 1..tab_cer.COUNT
    delete from ben_copy_entity_results
    where  copy_entity_result_id = tab_cer(i);

end purge_dup_elp_tree;

--<-------- procedure sync_elp_records -------->
-- purpose -
-- accept  -
-- do      -
-- return  -
--<-------------------------------------------->
procedure sync_elp_records (
   p_copy_entity_txn_id number
  ,p_business_group_id  number
  ,p_eligy_prfl_id      number
   ) is
cursor cur_dup_elp is
select *
  from ben_copy_entity_results
 where table_alias = 'ELP'
   and copy_entity_txn_id  = p_copy_entity_txn_id
   and information1 is null
   and information101 = p_eligy_prfl_id;

cursor cur_org_elp is
select 'Y'
  from ben_copy_entity_results
 where table_alias = 'ELP'
   and copy_entity_txn_id  = p_copy_entity_txn_id
   and information1 = p_eligy_prfl_id;

l_gs_per_id number;
l_per_id number;
l_cer_id number;
l_org_elp_exist varchar2(1);
l_gm_ser_id number;

begin
-- 1. for updated elp get all the other dup elp's
-- 2. save the GS_PARENT_ENTITY_RESULT_ID PARENT_ENTITY_RESULT_ID of this
-- 3. delete the whole dup hierarchy using cer_id of this dup elp
-- 4. recreate the whole hierarchy
-- 5. update the ELP record with variables saved in step 2
hr_utility.set_location('hm Inside sync_elp_rec',123) ;

open cur_org_elp;
fetch cur_org_elp into l_org_elp_exist ;
close cur_org_elp ;

if (l_org_elp_exist = 'Y')
then

for rec_dup_elp in cur_dup_elp
loop
l_gs_per_id := rec_dup_elp.gs_parent_entity_result_id ;
l_per_id    := rec_dup_elp.parent_entity_result_id ;
l_gm_ser_id := rec_dup_elp.Gs_Mirror_Src_Entity_Result_id;

hr_utility.set_location('hm Inside for loop',123) ;
hr_utility.set_location('hm cerid-'||rec_dup_elp.copy_entity_result_id,123) ;

purge_dup_elp_tree
    (p_copy_entity_txn_id => p_copy_entity_txn_id
    ,p_eligy_prfl_id => rec_dup_elp.information101
    ,p_copy_entity_result_id => rec_dup_elp.copy_entity_result_id
    );

end loop;

create_dup_elp_tree
    (p_copy_entity_txn_id => p_copy_entity_txn_id
    ,p_business_group_id  => p_business_group_id
    ,p_eligy_prfl_id      => p_eligy_prfl_id
    ,p_gs_per_id          => l_gs_per_id
    ,p_per_id             => l_per_id
    ,p_gm_ser_id          => l_gm_ser_id
    );

end if;
hr_utility.set_location('leaving sync_elp_rec',123) ;
end sync_elp_records;

--<-------- function create_duplicate_elp_tree -------->
-- purpose - To create a duplicate hierarchy of an existing ELPRO in staging area
-- accept  - a elig pro id
-- do      - will create a duplicate hierarchy for this elpro
--           it will copy paste this elpro and its child and grand children
-- return  - return cerid of the newly created duplicate elpro record
--<---------------------------------------------------->

function create_duplicate_elp_tree (
   p_copy_entity_txn_id number
  ,p_business_group_id  number
  ,p_eligy_prfl_id      number
   )
return number
is

-- This function accepts eligy_prfl_id and copy_entity_txn_id
-- creates duplicate entry for this ELP and all its child records(EGN etc)
-- returns copy_entity_result_id of the duplicate ELP record created

l_elp_cerid number;
l_child_cerid number;
l_gchild_cerid number;

-- get the elp record to be duplicated
cursor cur_elp is
select *
  from ben_copy_entity_results
 where table_alias = 'ELP'
   and copy_entity_txn_id = p_copy_entity_txn_id
   and information1 = p_eligy_prfl_id;

-- get the elp child records to be duplicated
cursor cur_elp_child(p_parent_cer_id number) is
select *
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id;

-- get one more level down for EAP-AGF,ECP-CLA,ECL-CLF
-- ,EHW-HWF,ELS-LSF,EPF-PFF
cursor cur_drv_fct (p_parent_cer_id number) is
select *
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id;

begin
    hr_utility.set_location('Inside duplicate_elp_tree', 10);
    hr_utility.set_location('p_copy_entity_txn_id'||p_copy_entity_txn_id, 20);
    hr_utility.set_location('p_business_group_id'||p_business_group_id, 30);
    hr_utility.set_location('p_eligy_prfl_id'||p_eligy_prfl_id, 40);
    for rec_elp in cur_elp
    loop
        -- create duplicate ELP record
        l_elp_cerid := create_bcer_rec(rec_elp);
        upd_info1(l_elp_cerid);
--        update_child(rec_elp.copy_entity_result_id
--                    ,nvl(rec_elp.GS_PARENT_ENTITY_RESULT_ID,
--                         rec_elp.PARENT_ENTITY_RESULT_IDg));
        for rec_elp_child in cur_elp_child(rec_elp.copy_entity_result_id)
        loop
            -- create duplicate child record
            l_child_cerid:= create_bcer_rec(rec_elp_child);
            upd_info1(l_child_cerid);
            update_child(l_child_cerid,l_elp_cerid);

            for rec_drv_fct in cur_drv_fct(rec_elp_child.copy_entity_result_id )
            loop
                l_gchild_cerid:= create_bcer_rec(rec_drv_fct);
                upd_info1(l_gchild_cerid);
                update_child(l_gchild_cerid,l_child_cerid);
            end loop ;
        end loop;
    end loop ;

hr_utility.set_location('Leaving duplicate_elp_tree', 10);
return l_elp_cerid;

end create_duplicate_elp_tree ;

--<-------- procedure purge_elp_tree -------->
-- purpose - To purge all duplicate records in the ELP tree created for pdw
-- accept  - cet_id
-- do
   -- if p_eligy_prfl_id and p_copy_entity_results_id is null then
   -- this will delete all duplicate elp hierarchy records of all ELPs

   -- if elpro is not null and cer id is null then
   -- it will delete all duplicate elp hierarchy records of this ELP

   -- if cer id is not null then
   -- it will delete the hierarchy records of this single duplicate ELP
--<------------------------------------------>
procedure purge_duplicate_elp_tree (
   p_copy_entity_txn_id number
  ,p_eligy_prfl_id      number default null
  ,p_copy_entity_result_id number default null
   ) is
-- There will be single ELP and its child records with info1 as not null
-- Duplicate ELP and its child will have info1 as null and not null info101

--cursor cur_elp is
--select copy_entity_result_id
--  from ben_copy_entity_results
--  where copy_entity_result_id = p_copy_entity_result_id ;

cursor cur_elp is
select copy_entity_result_id
  from ben_copy_entity_results
 where table_alias = 'ELP'
   and copy_entity_txn_id = p_copy_entity_txn_id
   and information1 is null
   and nvl(p_eligy_prfl_id,information101) = information101
   and nvl(p_copy_entity_result_id,copy_entity_result_id) = copy_entity_result_id ;

-- get the elp child records to be deleted
cursor cur_elp_child(p_parent_cer_id number) is
select copy_entity_result_id
  from ben_copy_entity_results
 where gs_parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id
   and information1 is null;

-- get one more level down to delete EAP-AGF,ECP-CLA,ECL-CLF
-- ,EHW-HWF,ELS-LSF,EPF-PFF
cursor cur_drv_fct (p_parent_cer_id number) is
select copy_entity_result_id
  from ben_copy_entity_results
 where parent_entity_result_id = p_parent_cer_id
   and copy_entity_txn_id  = p_copy_entity_txn_id
   and information1 is null;

tab_cer TabCerType := TabCerType();

begin
    for rec_elp in cur_elp
    loop
        -- duplicate ELP record
        tab_cer.extend;
        tab_cer(tab_cer.count) := rec_elp.copy_entity_result_id;
        for rec_elp_child in cur_elp_child(rec_elp.copy_entity_result_id)
        loop
            -- duplicate child record
            tab_cer.extend;
            tab_cer(tab_cer.count) := rec_elp_child.copy_entity_result_id;
            for rec_drv_fct in cur_drv_fct(rec_elp_child.copy_entity_result_id )
            loop
                tab_cer.extend;
                tab_cer(tab_cer.count) := rec_drv_fct.copy_entity_result_id;
            end loop ;
        end loop;
    end loop ;

    forall i in 1..tab_cer.COUNT
    delete from ben_copy_entity_results
    where  copy_entity_result_id = tab_cer(i);

end purge_duplicate_elp_tree;

--<-------- function create_bcer_rec -------->
-- purpose - To insert ELP and its child records in bcer
-- accept  - bcer%rowtype
-- do      - will insert this record in bcer
-- return  - return cerid of the newly created bcer record
--<------------------------------------------>

function create_bcer_rec (
    p_bcer_rec   ben_copy_entity_results%rowtype
    )
return number
is
l_grr_cer_id number;
l_grr_cer_ovn number;
l_effective_date date; -- ask GANESH
bcer_rec ben_copy_entity_results%rowtype ;
begin
hr_utility.set_location('Entering creating bcer rec', 10);
    bcer_rec := p_bcer_rec ;
        ben_copy_entity_results_api.create_copy_entity_results(
         p_effective_date              =>     l_effective_date
        ,p_copy_entity_txn_id          =>     bcer_rec.copy_entity_txn_id
        ,p_result_type_cd              =>     bcer_rec.result_type_cd
        ,p_src_copy_entity_result_id   =>     bcer_rec.src_copy_entity_result_id
        ,p_number_of_copies            =>     bcer_rec.number_of_copies
        ,p_mirror_entity_result_id     =>     bcer_rec.mirror_entity_result_id
        ,p_mirror_src_entity_result_id =>     bcer_rec.mirror_src_entity_result_id
        ,p_parent_entity_result_id     =>     bcer_rec.parent_entity_result_id
--        ,p_pd_mr_src_entity_result_id  =>     bcer_rec.pd_mr_src_entity_result_id
        ,p_pd_parent_entity_result_id  =>     bcer_rec.pd_parent_entity_result_id
--        ,p_gs_mr_src_entity_result_id  =>     bcer_rec.gs_mr_src_entity_result_id
        ,p_gs_parent_entity_result_id  =>     bcer_rec.gs_parent_entity_result_id
        ,p_table_name                  =>     bcer_rec.table_name
        ,p_table_alias                 =>     bcer_rec.table_alias
        ,p_table_route_id              =>     bcer_rec.table_route_id
        ,p_status                      =>     bcer_rec.status
        ,p_dml_operation               =>     bcer_rec.dml_operation
        ,p_information_category        =>     bcer_rec.information_category
        ,p_information1     =>     bcer_rec.information1
        ,p_information2     =>     bcer_rec.information2
        ,p_information3     =>     bcer_rec.information3
        ,p_information4     =>     bcer_rec.information4
        ,p_information5     =>     bcer_rec.information5
        ,p_information6     =>     bcer_rec.information6
        ,p_information7     =>     bcer_rec.information7
        ,p_information8     =>     bcer_rec.information8
        ,p_information9     =>     bcer_rec.information9
        ,p_information10     =>     bcer_rec.information10
        ,p_information11     =>     bcer_rec.information11
        ,p_information12     =>     bcer_rec.information12
        ,p_information13     =>     bcer_rec.information13
        ,p_information14     =>     bcer_rec.information14
        ,p_information15     =>     bcer_rec.information15
        ,p_information16     =>     bcer_rec.information16
        ,p_information17     =>     bcer_rec.information17
        ,p_information18     =>     bcer_rec.information18
        ,p_information19     =>     bcer_rec.information19
        ,p_information20     =>     bcer_rec.information20
        ,p_information21     =>     bcer_rec.information21
        ,p_information22     =>     bcer_rec.information22
        ,p_information23     =>     bcer_rec.information23
        ,p_information24     =>     bcer_rec.information24
        ,p_information25     =>     bcer_rec.information25
        ,p_information26     =>     bcer_rec.information26
        ,p_information27     =>     bcer_rec.information27
        ,p_information28     =>     bcer_rec.information28
        ,p_information29     =>     bcer_rec.information29
        ,p_information30     =>     bcer_rec.information30
        ,p_information31     =>     bcer_rec.information31
        ,p_information32     =>     bcer_rec.information32
        ,p_information33     =>     bcer_rec.information33
        ,p_information34     =>     bcer_rec.information34
        ,p_information35     =>     bcer_rec.information35
        ,p_information36     =>     bcer_rec.information36
        ,p_information37     =>     bcer_rec.information37
        ,p_information38     =>     bcer_rec.information38
        ,p_information39     =>     bcer_rec.information39
        ,p_information40     =>     bcer_rec.information40
        ,p_information41     =>     bcer_rec.information41
        ,p_information42     =>     bcer_rec.information42
        ,p_information43     =>     bcer_rec.information43
        ,p_information44     =>     bcer_rec.information44
        ,p_information45     =>     bcer_rec.information45
        ,p_information46     =>     bcer_rec.information46
        ,p_information47     =>     bcer_rec.information47
        ,p_information48     =>     bcer_rec.information48
        ,p_information49     =>     bcer_rec.information49
        ,p_information50     =>     bcer_rec.information50
        ,p_information51     =>     bcer_rec.information51
        ,p_information52     =>     bcer_rec.information52
        ,p_information53     =>     bcer_rec.information53
        ,p_information54     =>     bcer_rec.information54
        ,p_information55     =>     bcer_rec.information55
        ,p_information56     =>     bcer_rec.information56
        ,p_information57     =>     bcer_rec.information57
        ,p_information58     =>     bcer_rec.information58
        ,p_information59     =>     bcer_rec.information59
        ,p_information60     =>     bcer_rec.information60
        ,p_information61     =>     bcer_rec.information61
        ,p_information62     =>     bcer_rec.information62
        ,p_information63     =>     bcer_rec.information63
        ,p_information64     =>     bcer_rec.information64
        ,p_information65     =>     bcer_rec.information65
        ,p_information66     =>     bcer_rec.information66
        ,p_information67     =>     bcer_rec.information67
        ,p_information68     =>     bcer_rec.information68
        ,p_information69     =>     bcer_rec.information69
        ,p_information70     =>     bcer_rec.information70
        ,p_information71     =>     bcer_rec.information71
        ,p_information72     =>     bcer_rec.information72
        ,p_information73     =>     bcer_rec.information73
        ,p_information74     =>     bcer_rec.information74
        ,p_information75     =>     bcer_rec.information75
        ,p_information76     =>     bcer_rec.information76
        ,p_information77     =>     bcer_rec.information77
        ,p_information78     =>     bcer_rec.information78
        ,p_information79     =>     bcer_rec.information79
        ,p_information80     =>     bcer_rec.information80
        ,p_information81     =>     bcer_rec.information81
        ,p_information82     =>     bcer_rec.information82
        ,p_information83     =>     bcer_rec.information83
        ,p_information84     =>     bcer_rec.information84
        ,p_information85     =>     bcer_rec.information85
        ,p_information86     =>     bcer_rec.information86
        ,p_information87     =>     bcer_rec.information87
        ,p_information88     =>     bcer_rec.information88
        ,p_information89     =>     bcer_rec.information89
        ,p_information90     =>     bcer_rec.information90
        ,p_information91     =>     bcer_rec.information91
        ,p_information92     =>     bcer_rec.information92
        ,p_information93     =>     bcer_rec.information93
        ,p_information94     =>     bcer_rec.information94
        ,p_information95     =>     bcer_rec.information95
        ,p_information96     =>     bcer_rec.information96
        ,p_information97     =>     bcer_rec.information97
        ,p_information98     =>     bcer_rec.information98
        ,p_information99     =>     bcer_rec.information99
        ,p_information100     =>     bcer_rec.information100
        ,p_information101     =>     bcer_rec.information101
        ,p_information102     =>     bcer_rec.information102
        ,p_information103     =>     bcer_rec.information103
        ,p_information104     =>     bcer_rec.information104
        ,p_information105     =>     bcer_rec.information105
        ,p_information106     =>     bcer_rec.information106
        ,p_information107     =>     bcer_rec.information107
        ,p_information108     =>     bcer_rec.information108
        ,p_information109     =>     bcer_rec.information109
        ,p_information110     =>     bcer_rec.information110
        ,p_information111     =>     bcer_rec.information111
        ,p_information112     =>     bcer_rec.information112
        ,p_information113     =>     bcer_rec.information113
        ,p_information114     =>     bcer_rec.information114
        ,p_information115     =>     bcer_rec.information115
        ,p_information116     =>     bcer_rec.information116
        ,p_information117     =>     bcer_rec.information117
        ,p_information118     =>     bcer_rec.information118
        ,p_information119     =>     bcer_rec.information119
        ,p_information120     =>     bcer_rec.information120
        ,p_information121     =>     bcer_rec.information121
        ,p_information122     =>     bcer_rec.information122
        ,p_information123     =>     bcer_rec.information123
        ,p_information124     =>     bcer_rec.information124
        ,p_information125     =>     bcer_rec.information125
        ,p_information126     =>     bcer_rec.information126
        ,p_information127     =>     bcer_rec.information127
        ,p_information128     =>     bcer_rec.information128
        ,p_information129     =>     bcer_rec.information129
        ,p_information130     =>     bcer_rec.information130
        ,p_information131     =>     bcer_rec.information131
        ,p_information132     =>     bcer_rec.information132
        ,p_information133     =>     bcer_rec.information133
        ,p_information134     =>     bcer_rec.information134
        ,p_information135     =>     bcer_rec.information135
        ,p_information136     =>     bcer_rec.information136
        ,p_information137     =>     bcer_rec.information137
        ,p_information138     =>     bcer_rec.information138
        ,p_information139     =>     bcer_rec.information139
        ,p_information140     =>     bcer_rec.information140
        ,p_information141     =>     bcer_rec.information141
        ,p_information142     =>     bcer_rec.information142

        /* Extra Reserved Columns
        ,p_information143     =>     bcer_rec.information143
        ,p_information144     =>     bcer_rec.information144
        ,p_information145     =>     bcer_rec.information145
        ,p_information146     =>     bcer_rec.information146
        ,p_information147     =>     bcer_rec.information147
        ,p_information148     =>     bcer_rec.information148
        ,p_information149     =>     bcer_rec.information149
        ,p_information150     =>     bcer_rec.information150
        */
        ,p_information151     =>     bcer_rec.information151
        ,p_information152     =>     bcer_rec.information152
        ,p_information153     =>     bcer_rec.information153

        /* Extra Reserved Columns
        ,p_information154     =>     bcer_rec.information154
        ,p_information155     =>     bcer_rec.information155
        ,p_information156     =>     bcer_rec.information156
        ,p_information157     =>     bcer_rec.information157
        ,p_information158     =>     bcer_rec.information158
        ,p_information159     =>     bcer_rec.information159
        */
        ,p_information160     =>     bcer_rec.information160
        ,p_information161     =>     bcer_rec.information161
        ,p_information162     =>     bcer_rec.information162

        /* Extra Reserved Columns
        ,p_information163     =>     bcer_rec.information163
        ,p_information164     =>     bcer_rec.information164
        ,p_information165     =>     bcer_rec.information165
        */
        ,p_information166     =>     bcer_rec.information166
        ,p_information167     =>     bcer_rec.information167
        ,p_information168     =>     bcer_rec.information168
        ,p_information169     =>     bcer_rec.information169
        ,p_information170     =>     bcer_rec.information170

        /* Extra Reserved Columns
        ,p_information171     =>     bcer_rec.information171
        ,p_information172     =>     bcer_rec.information172
        */
        ,p_information173     =>     bcer_rec.information173
        ,p_information174     =>     bcer_rec.information174
        ,p_information175     =>     bcer_rec.information175
        ,p_information176     =>     bcer_rec.information176
        ,p_information177     =>     bcer_rec.information177
        ,p_information178     =>     bcer_rec.information178
        ,p_information179     =>     bcer_rec.information179
        ,p_information180     =>     bcer_rec.information180
        ,p_information181     =>     bcer_rec.information181
        ,p_information182     =>     bcer_rec.information182

        /* Extra Reserved Columns
        ,p_information183     =>     bcer_rec.information183
        ,p_information184     =>     bcer_rec.information184
        */
        ,p_information185     =>     bcer_rec.information185
        ,p_information186     =>     bcer_rec.information186
        ,p_information187     =>     bcer_rec.information187
        ,p_information188     =>     bcer_rec.information188

        /* Extra Reserved Columns
        ,p_information189     =>     bcer_rec.information189
        */
        ,p_information190     =>     bcer_rec.information190
        ,p_information191     =>     bcer_rec.information191
        ,p_information192     =>     bcer_rec.information192
        ,p_information193     =>     bcer_rec.information193
        ,p_information194     =>     bcer_rec.information194
        ,p_information195     =>     bcer_rec.information195
        ,p_information196     =>     bcer_rec.information196
        ,p_information197     =>     bcer_rec.information197
        ,p_information198     =>     bcer_rec.information198
        ,p_information199     =>     bcer_rec.information199

        /* Extra Reserved Columns
        ,p_information200     =>     bcer_rec.information200
        ,p_information201     =>     bcer_rec.information201
        ,p_information202     =>     bcer_rec.information202
        ,p_information203     =>     bcer_rec.information203
        ,p_information204     =>     bcer_rec.information204
        ,p_information205     =>     bcer_rec.information205
        ,p_information206     =>     bcer_rec.information206
        ,p_information207     =>     bcer_rec.information207
        ,p_information208     =>     bcer_rec.information208
        ,p_information209     =>     bcer_rec.information209
        ,p_information210     =>     bcer_rec.information210
        ,p_information211     =>     bcer_rec.information211
        ,p_information212     =>     bcer_rec.information212
        ,p_information213     =>     bcer_rec.information213
        ,p_information214     =>     bcer_rec.information214
        ,p_information215     =>     bcer_rec.information215
        */
        ,p_information216     =>     bcer_rec.information216
        ,p_information217     =>     bcer_rec.information217
        ,p_information218     =>     bcer_rec.information218
        ,p_information219     =>     bcer_rec.information219
        ,p_information220     =>     bcer_rec.information220
        ,p_information221     =>     bcer_rec.information221
        ,p_information222     =>     bcer_rec.information222
        ,p_information223     =>     bcer_rec.information223
        ,p_information224     =>     bcer_rec.information224
        ,p_information225     =>     bcer_rec.information225
        ,p_information226     =>     bcer_rec.information226
        ,p_information227     =>     bcer_rec.information227
        ,p_information228     =>     bcer_rec.information228
        ,p_information229     =>     bcer_rec.information229
        ,p_information230     =>     bcer_rec.information230
        ,p_information231     =>     bcer_rec.information231
        ,p_information232     =>     bcer_rec.information232
        ,p_information233     =>     bcer_rec.information233
        ,p_information234     =>     bcer_rec.information234
        ,p_information235     =>     bcer_rec.information235
        ,p_information236     =>     bcer_rec.information236
        ,p_information237     =>     bcer_rec.information237
        ,p_information238     =>     bcer_rec.information238
        ,p_information239     =>     bcer_rec.information239
        ,p_information240     =>     bcer_rec.information240
        ,p_information241     =>     bcer_rec.information241
        ,p_information242     =>     bcer_rec.information242
        ,p_information243     =>     bcer_rec.information243
        ,p_information244     =>     bcer_rec.information244
        ,p_information245     =>     bcer_rec.information245
        ,p_information246     =>     bcer_rec.information246
        ,p_information247     =>     bcer_rec.information247
        ,p_information248     =>     bcer_rec.information248
        ,p_information249     =>     bcer_rec.information249
        ,p_information250     =>     bcer_rec.information250
        ,p_information251     =>     bcer_rec.information251
        ,p_information252     =>     bcer_rec.information252
        ,p_information253     =>     bcer_rec.information253
        ,p_information254     =>     bcer_rec.information254
        ,p_information255     =>     bcer_rec.information255
        ,p_information256     =>     bcer_rec.information256
        ,p_information257     =>     bcer_rec.information257
        ,p_information258     =>     bcer_rec.information258
        ,p_information259     =>     bcer_rec.information259
        ,p_information260     =>     bcer_rec.information260
        ,p_information261     =>     bcer_rec.information261
        ,p_information262     =>     bcer_rec.information262
        ,p_information263     =>     bcer_rec.information263
        ,p_information264     =>     bcer_rec.information264
        ,p_information265     =>     bcer_rec.information265
        ,p_information266     =>     bcer_rec.information266
        ,p_information267     =>     bcer_rec.information267
        ,p_information268     =>     bcer_rec.information268
        ,p_information269     =>     bcer_rec.information269
        ,p_information270     =>     bcer_rec.information270
        ,p_information271     =>     bcer_rec.information271
        ,p_information272     =>     bcer_rec.information272
        ,p_information273     =>     bcer_rec.information273
        ,p_information274     =>     bcer_rec.information274
        ,p_information275     =>     bcer_rec.information275
        ,p_information276     =>     bcer_rec.information276
        ,p_information277     =>     bcer_rec.information277
        ,p_information278     =>     bcer_rec.information278
        ,p_information279     =>     bcer_rec.information279
        ,p_information280     =>     bcer_rec.information280
        ,p_information281     =>     bcer_rec.information281
        ,p_information282     =>     bcer_rec.information282
        ,p_information283     =>     bcer_rec.information283
        ,p_information284     =>     bcer_rec.information284
        ,p_information285     =>     bcer_rec.information285
        ,p_information286     =>     bcer_rec.information286
        ,p_information287     =>     bcer_rec.information287
        ,p_information288     =>     bcer_rec.information288
        ,p_information289     =>     bcer_rec.information289
        ,p_information290     =>     bcer_rec.information290
        ,p_information291     =>     bcer_rec.information291
        ,p_information292     =>     bcer_rec.information292
        ,p_information293     =>     bcer_rec.information293
        ,p_information294     =>     bcer_rec.information294
        ,p_information295     =>     bcer_rec.information295
        ,p_information296     =>     bcer_rec.information296
        ,p_information297     =>     bcer_rec.information297
        ,p_information298     =>     bcer_rec.information298
        ,p_information299     =>     bcer_rec.information299
        ,p_information300     =>     bcer_rec.information300
        ,p_information301     =>     bcer_rec.information301
        ,p_information302     =>     bcer_rec.information302
        ,p_information303     =>     bcer_rec.information303
        ,p_information304     =>     bcer_rec.information304

        /* Extra Reserved Columns
        ,p_information305     =>     bcer_rec.information305
        */
        ,p_information306     =>     bcer_rec.information306
        ,p_information307     =>     bcer_rec.information307
        ,p_information308     =>     bcer_rec.information308
        ,p_information309     =>     bcer_rec.information309
        ,p_information310     =>     bcer_rec.information310
        ,p_information311     =>     bcer_rec.information311
        ,p_information312     =>     bcer_rec.information312
        ,p_information313     =>     bcer_rec.information313
        ,p_information314     =>     bcer_rec.information314
        ,p_information315     =>     bcer_rec.information315
        ,p_information316     =>     bcer_rec.information316
        ,p_information317     =>     bcer_rec.information317
        ,p_information318     =>     bcer_rec.information318
        ,p_information319     =>     bcer_rec.information319
        ,p_information320     =>     bcer_rec.information320
        /* Extra Reserved Columns
        ,p_information321     =>     bcer_rec.information321
        ,p_information322     =>     bcer_rec.information322
        */
        ,p_information323          =>     bcer_rec.information323
        ,p_datetrack_mode          =>     bcer_rec.datetrack_mode

        ,p_copy_entity_result_id   =>     l_grr_cer_id
        ,p_object_version_number   =>     l_grr_cer_ovn);
hr_utility.set_location('Leaving creating bcer rec', 10);
return l_grr_cer_id;
end create_bcer_rec ;


Function Get_Ref_Level
(P_Parent_Cer_Id	IN Number,
 P_prfl_Id              IN Number)
 Return Varchar2 Is

Cursor Ref_level is
Select Table_Alias
From ben_Copy_Entity_Results
Where Copy_Entity_Result_id in
(Select EPA.Gs_Mirror_Src_Entity_Result_id
  From Ben_Copy_Entity_Results Elp,
       Ben_Copy_Entity_Results Cep,
       Ben_Copy_Entity_Results EPA
 Where Elp.Gs_Parent_Entity_Result_id = P_Parent_Cer_Id
   and Elp.Table_Alias = 'ELP'
   and Cep.Copy_Entity_Result_id = Elp.Gs_Mirror_Src_Entity_Result_id
   and Cep.Table_Alias = 'CEP'
   and Cep.Information263 = P_Prfl_Id
   and Epa.Copy_Entity_Result_id = Cep.Gs_Mirror_Src_Entity_Result_Id);

L_ref_Level  Varchar2(5) := NULL;
Begin

Open Ref_level;
Fetch Ref_Level into L_Ref_Level;
Close Ref_Level;

If L_Ref_Level = 'CPP' Then
   L_Ref_Level := 'PLIP';
ElsIf L_Ref_Level = 'PLN' Then
   l_Ref_Level := 'PL';
End If;

Return L_Ref_Level;
End Get_Ref_Level;

Function Get_Dml_Operation
(P_Copy_Entity_Result_Id  In Number
,P_Opr_type               IN Varchar2)
 Return Varchar2 Is

Cursor Exist_Rec is
Select Information1
From ben_Copy_Entity_Results
Where Copy_Entity_Result_id = P_Copy_Entity_Result_Id;

L_Information1  Ben_Copy_Entity_Results.Information1%TYPE;
L_Dml_operation	Varchar2(15);

Begin

Open Exist_Rec;
Fetch Exist_Rec into L_Information1;
Close Exist_Rec;

If P_Opr_type = 'U' Then
   If L_Information1 is NULL  Then
      L_Dml_operation := 'INSERT';
   Else
      L_Dml_operation := 'UPDATE';
   End If;
Elsif P_Opr_type = 'D' Then
   If L_Information1 is NULL  Then
      L_Dml_operation := 'PURGE';
   Else
      L_Dml_operation := 'DELETE';
   End If;
End If;

Return L_Dml_operation;
End Get_Dml_Operation;

function is_elpro_in_stage (p_eligy_prfl_id in number,p_copy_entity_txn_id in number)
return boolean
is
Cursor csr_elpro_in_stage
is
select null
from ben_copy_entity_results
where table_alias = 'ELP'
and copy_entity_txn_id = p_copy_entity_txn_id
and information1 = p_eligy_prfl_id;
l_dummy varchar2(1);
begin
 OPEN csr_elpro_in_stage;
 FETCH csr_elpro_in_stage into l_dummy;
 if csr_elpro_in_stage%FOUND then
  return true;
 else
 return false;
 end if;
 CLOSE csr_elpro_in_stage;

end is_elpro_in_stage;

Function is_elpro_created_in_stage(p_eligy_prfl_id in number,
                                p_copy_entity_txn_id in number)
return number
is
Cursor csr_eligy_prfl_in_txn
is
select copy_entity_result_id
from ben_copy_entity_results
where copy_entity_txn_id =p_copy_entity_txn_id
and table_alias = 'ELP'
and information1 = p_eligy_prfl_id
and dml_operation <> 'REUSE';
l_eligy_prfl_cer_id number;
begin
OPEN csr_eligy_prfl_in_txn;
FETCH csr_eligy_prfl_in_txn into l_eligy_prfl_cer_id;
if csr_eligy_prfl_in_txn%NOTFOUND  then
l_eligy_prfl_cer_id := -1;
end if;

CLOSE csr_eligy_prfl_in_txn;
return l_eligy_prfl_cer_id;
end is_elpro_created_in_stage;

procedure update_crit_records_in_staging(p_copy_entity_txn_id in number)
is

begin

 null;

end update_crit_records_in_staging;
/*
procedure update_crit_records_in_staging(p_copy_entity_txn_id in number)
is
Cursor csr_eligy_prfl_cer
is
select copy_entity_result_id eligy_prfl_cer_id
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and table_alias = 'ELP'
and information1 is not null;
Cursor csr_criteria(p_eligy_prfl_cer_id in number)
is
select copy_entity_result_id crit_cer_id
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and parent_entity_result_id =p_eligy_prfl_cer_id
and gs_parent_entity_result_id is null;

begin

for i in csr_eligy_prfl_cer loop

 for j in csr_criteria(i.eligy_prfl_cer_id) loop
 update ben_copy_entity_results
 set gs_parent_entity_result_id = i.eligy_prfl_cer_id,
 GS_MIRROR_SRC_ENTITY_RESULT_ID = i.eligy_prfl_cer_id
 where copy_entity_result_id = j.crit_cer_id;

 end loop;
end loop;

end update_crit_records_in_staging;
*/

Procedure Create_Eligibility_Profile
(p_Copy_Entity_txn_Id 		In Number,
 P_gs_Parent_Entity_Result_Id   In Number,
 P_Effective_Date		In Date,
 P_Prfl_Id			In Number,
 P_Name			        In Varchar2,
 P_Txn_Type			In Varchar2,
 p_Txn_Mode                     In Varchar2,
 P_Business_Group_Id            In Number,
 P_Req_opt                      In Varchar2,
 P_Ref_level		        In Varchar2,
 P_Compute_Score_Flag		In Varchar2) Is

 L_PRTN_COPY_ENTITY_RSLT_ID     BEN_COPY_ENTITY_RESULTS.Copy_Entity_Result_Id%TYPE;
 L_DELPRTN_COPY_ENTITY_RSLT_ID  BEN_COPY_ENTITY_RESULTS.Copy_Entity_Result_Id%TYPE;
 l_Copy_Entity_Rslt_Id		BEN_COPY_ENTITY_RESULTS.Copy_Entity_Result_Id%TYPE;
 l_PrtnPrfl_Copy_Entity_Rslt_Id BEN_COPY_ENTITY_RESULTS.Copy_Entity_Result_Id%TYPE;
 l_Object_version_number        BEN_COPY_ENTITY_RESULTS.Object_version_number%TYPE;
 l_Prtn_Elig_Ovn	        BEN_COPY_ENTITY_RESULTS.Object_version_number%TYPE;
 l_Prtn_Elig_Prfl_Ovn	        BEN_COPY_ENTITY_RESULTS.Object_version_number%TYPE;
 L_PRTN_ELIG_PRFL_ID 		Ben_Prtn_Elig_Prfl_f.Prtn_Elig_Prfl_Id%TYPE;
 l_Table_Route_Id               BEN_COPY_ENTITY_RESULTS.Table_Route_Id%TYPE;
 L_Table_Name 		        Pqh_Table_Route.Display_Name%TYPE;
 l_Prtn_Elig_id		        Pqh_Copy_Entity_Results.Copy_Entity_Result_Id%TYPE;
 l_DelPrtn_Elig_id		Pqh_Copy_Entity_Results.Copy_Entity_Result_Id%TYPE;
 l_InsYN                        Varchar2(1) := 'N';
 l_DelYN                        Varchar2(1) := 'N';

 L_PLIP_ID		        Ben_PLIP_F.Plip_Id%TYPE;
 L_OIPL_ID		        Ben_OIPL_F.Oipl_Id%TYPE;
 L_PGM_ID		        Ben_Pgm_F.Pgm_Id%TYPE;
 L_PL_ID		        Ben_Pl_F.Pl_Id%TYPE;
 l_Ovn                          Ben_Copy_Entity_Results.Object_Version_Number%TYPE;
 l_Prtn_ovn                     Ben_Copy_Entity_Results.Object_Version_Number%TYPE;
 l_DelPrtn_ovn                  Ben_Copy_Entity_Results.Object_Version_Number%TYPE;
 L_Prtn_Mirror_result_Id	BEN_COPY_ENTITY_RESULTS.Copy_Entity_Result_Id%TYPE;
 l_Pl_Cer_Id			BEN_COPY_ENTITY_RESULTS.Copy_Entity_Result_Id%TYPE;
 l_Ref_Level			Varchar2(5);
 l_Count                        Number;
 L_Del_Parent_Entity_Result_Id  BEN_COPY_ENTITY_RESULTS.Parent_Entity_Result_Id%TYPE;
 L_Del_Cer_Id                   BEN_COPY_ENTITY_RESULTS.Copy_Entity_Result_Id%TYPE;
 l_Dml_Opr                      Varchar2(30);
 L_DML_OPERATION                BEN_COPY_ENTITY_RESULTS.DML_OPERATION%TYPE;
  L_DML                BEN_COPY_ENTITY_RESULTS.DML_OPERATION%TYPE;
 l_Elp_Cer_id                   BEN_COPY_ENTITY_RESULTS.Copy_Entity_Result_Id%TYPE;
  l_Cer_id                   BEN_COPY_ENTITY_RESULTS.Copy_Entity_Result_Id%TYPE;
 l_Elp_ovn                      Ben_Copy_Entity_Results.Object_Version_Number%TYPE;
 L_Business_Area                Varchar2(255) := 'PQH_GSP_TASK_LIST';
 l_elp_count number ;

 Cursor BusArea is
 Select Nvl(Information9,'PQH_GSP_TASK_LIST')
   from Pqh_Copy_Entity_Attribs
  where Copy_Entity_Txn_Id =  p_Copy_Entity_txn_Id;

  Cursor TablRoute (p_table_alias IN Varchar2) is
 Select Table_Route_id, Substr(Display_name,1,30)
   -- from Pqh_Table_Route bug5763511
   from Pqh_Table_Route_vl
  Where table_alias = p_table_alias;

 Cursor Ovn is
 Select object_version_Number
   from Ben_Copy_Entity_Results
  where Copy_Entity_Result_id = l_Copy_Entity_Rslt_Id;

 Cursor Csr_Dml_Operation(p_elp_id In number) is
 Select DML_OPERATION,copy_entity_result_id
   from Ben_Copy_Entity_Results
  where Information1 = p_elp_id
  and table_alias = 'ELP'
  and copy_entity_txn_id = p_copy_entity_txn_id;

 Cursor Prtn(P_Mirror_result_Id In Number) Is
 Select Information1, Copy_Entity_Result_Id, Object_version_NUmber, DML_OPERATION
   from Ben_Copy_Entity_Results
  where Copy_Entity_Txn_Id = p_Copy_Entity_txn_Id
    and GS_MIRROR_SRC_ENTITY_RESULT_ID     = P_Mirror_result_Id
    and Table_alias        = 'EPA'
    and Nvl(Dml_operation,'XX') <> 'DELETE';

 Cursor PrtnElig Is
 Select Cep.Copy_Entity_Result_id, Cep.Object_version_Number,
        Elp.Copy_Entity_Result_id, Elp.Object_Version_Number
   From BEN_Copy_Entity_Results CEP,
        Ben_Copy_Entity_Results ELP
  Where Elp.Copy_Entity_Txn_Id = p_Copy_Entity_txn_Id
    and elp.Table_alias = 'ELP'
    and elp.Gs_Parent_Entity_Result_Id = P_gs_Parent_Entity_Result_Id
    and Elp.Gs_Mirror_Src_Entity_Result_id = Cep.Copy_Entity_Result_id
    and Cep.Information263 = P_Prfl_Id
    and Nvl(Cep.Dml_Operation,'XX') <> 'DELETE';

  Cursor Plip_Dtls is
  Select Plan.Copy_Entity_Result_Id
    From Ben_Copy_Entity_Results Plan
   where PLan.Gs_Mirror_Src_Entity_Result_id = P_Gs_Parent_Entity_Result_Id
     and Plan.table_Alias = 'PLN'
     and plan.copy_entity_txn_id = p_copy_entity_txn_id;

 Cursor PrflCnt(P_Parent_Entity_Result_Id In Number) is
 Select Count(*)
   from Ben_Copy_Entity_Results Prtn,
        Ben_Copy_Entity_Results PrtnElig
  where Prtn.Copy_Entity_Txn_Id                  =  p_Copy_Entity_txn_Id
    and Prtn.GS_Mirror_Src_ENTITY_RESULT_ID      =  P_Parent_Entity_Result_Id
    and Prtn.Table_alias                         =  'EPA'
    and PrtnElig.Copy_Entity_Txn_Id              =  Prtn.Copy_Entity_Txn_Id
    and Prtnelig.Gs_Mirror_Src_Entity_Result_id  =  Prtn.Copy_Entity_Result_Id
    and PrtnElig.INFORMATION263                  <> P_Prfl_Id;

 Cursor Csr_is_elp_present(p_elp_id In number) is
 Select Count(*)
   from Ben_Copy_Entity_Results
  where Information1 = p_elp_id
   and table_alias = 'ELP'
   and copy_entity_txn_id = p_copy_entity_txn_id;

Begin
/* The Following Condition is used to Delete Ben_prtn_Elig_F
   if the Reference type is changed */

/* L_Ref_Level refers to the Old reference level ..
   P_ref_Level Implies the reference level the user tries to Change.
   As such reference level is applicable on ly Plan and Plan In program */

/* Initialize Multi Message Detection */

--hr_utility.trace_on(NULL,'GUN');

hr_multi_message.enable_message_list;

hr_utility.set_location('Inside Create Progression Rules ',10);
hr_utility.set_location('p_Copy_Entity_txn_Id '||p_Copy_Entity_txn_Id,10);
hr_utility.set_location('P_gs_Parent_Entity_Result_Id'||P_gs_Parent_Entity_Result_Id,10);
hr_utility.set_location('P_Effective_Date'||P_Effective_Date,10);
hr_utility.set_location('P_Prfl_Id'||P_Prfl_Id,10);
hr_utility.set_location('P_Name '||P_Name,10);
hr_utility.set_location('P_Txn_Type'||P_Txn_Type,10);
hr_utility.set_location('p_Txn_Mode'||p_Txn_Mode,10);
hr_utility.set_location(' P_Business_Group_Id'||P_Business_Group_Id,10);
hr_utility.set_location('P_Req_opt'||P_Req_opt,19);
hr_utility.set_location('P_Ref_level'||P_Ref_level,19);
hr_utility.set_location('P_Compute_Score_Flag'||P_Compute_Score_Flag,19);



 Open BusArea;
Fetch BusArea into l_Business_Area;
Close BusArea;

If P_Txn_Type <> 'GRD' Then

   hr_utility.set_location('P_Txn_Type = ' || P_Txn_Type ,20);

   Open Prtn(P_Gs_Parent_Entity_Result_Id);
   Fetch Prtn into l_Prtn_Elig_id, l_Prtn_Copy_Entity_Rslt_Id,  l_Prtn_ovn, L_DML_OPERATION;
   If Prtn%FOUND Then
      l_InsYN := 'N';
   Else
     l_InsYN := 'Y';
   End If;
   Close Prtn;
   L_Prtn_Mirror_result_Id := P_Gs_Parent_Entity_Result_Id;

   hr_utility.set_location('Insert EPA '  || l_InsYN ,30);

ElsIf P_Txn_Type = 'GRD' Then

   If p_Txn_Mode = 'U' Then
      l_Ref_Level := Get_Ref_Level(P_gs_Parent_Entity_Result_Id,P_Prfl_Id);
   End If;

   If Nvl(l_Ref_Level,'YY') = 'PL' or P_Ref_Level  = 'PL' Then
      Open Plip_Dtls;
      Fetch Plip_Dtls into l_Pl_Cer_Id;
      Close Plip_Dtls;
   End If;

   hr_utility.set_location('l_Ref_Level '  || l_Ref_Level ,40);
   hr_utility.set_location('p_Ref_Level '  || p_Ref_Level ,50);

   If P_Txn_Mode = 'U' Then
      If l_Ref_Level <> P_Ref_Level Then
         If l_Ref_Level = 'PLIP' Then
            L_Del_Parent_Entity_Result_Id := P_Gs_Parent_Entity_Result_Id;
         ElsIf l_Ref_Level = 'PL' Then
            L_Del_Parent_Entity_Result_Id := l_Pl_Cer_Id;
         End If;

         Open  PrflCnt(L_Del_Parent_Entity_Result_Id);
         Fetch PrflCnt into l_Count;
         Close PrflCnt;

         If l_Count = 0  Then
            L_DelYN := 'Y';

            Open Prtn(L_Del_Parent_Entity_Result_Id);
            Fetch Prtn into l_DelPrtn_Elig_id, l_DelPrtn_Copy_Entity_Rslt_Id,  l_DelPrtn_ovn, L_DML_OPERATION;
            Close Prtn;
         End If;
      End If;
   End If;

   hr_utility.set_location('Delete Epa  '  || L_DelYN ,60);

   If p_Txn_Mode = 'U' and L_DelYN = 'Y' Then

      -- Delete CEP Row ---
      Open  PrtnElig;
      Fetch PrtnElig into l_PrtnPrfl_Copy_Entity_Rslt_Id, l_Prtn_Elig_Prfl_Ovn, L_Elp_Cer_Id, l_Elp_ovn;
      If PrtnElig%Found Then
         l_Dml_Opr := NULL;
         L_Dml_Opr := Get_Dml_Operation(l_PrtnPrfl_Copy_Entity_Rslt_Id, 'D');

         if L_Dml_Opr = 'PURGE' then
            Ben_Copy_Entity_Results_Api.DELETE_COPY_ENTITY_RESULTS
           (P_COPY_ENTITY_RESULT_ID        => l_PrtnPrfl_Copy_Entity_Rslt_Id,
            P_OBJECT_VERSION_NUMBER        => l_Prtn_Elig_Prfl_ovn,
            P_EFFECTIVE_DATE               => P_Effective_Date);
         Else
            Ben_Copy_Entity_Results_Api.UPDATE_COPY_ENTITY_RESULTS
           (P_EFFECTIVE_DATE                 => P_Effective_Date,
            P_COPY_ENTITY_TXN_ID             => p_Copy_Entity_txn_Id,
            P_DML_OPERATION                  => 'DELETE',
            P_INFORMATION323 	    	     => NULL,
            P_COPY_ENTITY_RESULT_ID          => l_PrtnPrfl_Copy_Entity_Rslt_Id,
            P_OBJECT_VERSION_NUMBER          => l_Prtn_Elig_Prfl_ovn);
         End If;
      End If;
      Close PrtnElig;

      hr_utility.set_location('Deleting Epa .. Cer_id is '  || l_DelPrtn_Copy_Entity_Rslt_Id ,70);
      l_Dml_Opr := NULL;
      L_Dml_Opr := Get_Dml_Operation(l_DelPrtn_Copy_Entity_Rslt_Id, 'D');

      If L_Dml_Opr = 'PURGE' then
         Ben_Copy_Entity_Results_Api.DELETE_COPY_ENTITY_RESULTS
        (P_COPY_ENTITY_RESULT_ID        => l_DelPrtn_Copy_Entity_Rslt_Id,
         P_OBJECT_VERSION_NUMBER        => l_DelPrtn_ovn,
         P_EFFECTIVE_DATE               => P_Effective_Date);
      Else
        Ben_Copy_Entity_Results_Api.UPDATE_COPY_ENTITY_RESULTS
       (P_EFFECTIVE_DATE                 => P_Effective_Date,
        P_COPY_ENTITY_TXN_ID             => p_Copy_Entity_txn_Id,
        P_DML_OPERATION                  => 'DELETE',
        P_INFORMATION323 		 => NULL,
        P_COPY_ENTITY_RESULT_ID          => l_DelPrtn_Copy_Entity_Rslt_Id,
        P_OBJECT_VERSION_NUMBER          => l_DelPrtn_ovn);
      End If;

   End if;

   If P_Ref_Level = 'PL' Then
      l_Prtn_Mirror_result_Id := l_Pl_Cer_Id;
      Open Prtn(l_Pl_Cer_Id);
   ElsIf P_Ref_Level = 'PLIP' Then
      L_Prtn_Mirror_result_Id := P_Gs_Parent_Entity_Result_Id;
      Open Prtn(P_Gs_Parent_Entity_Result_Id);
   End If;

   Fetch Prtn into l_Prtn_Elig_id, l_Prtn_Copy_Entity_Rslt_Id, l_Prtn_ovn, L_DML_OPERATION;
   If Prtn%FOUND Then
      l_InsYN := 'N';
      If L_DML_OPERATION = 'DELETE' Then
         Ben_Copy_Entity_Results_Api.UPDATE_COPY_ENTITY_RESULTS
        (P_EFFECTIVE_DATE              => P_Effective_Date,
         P_COPY_ENTITY_TXN_ID          => p_Copy_Entity_txn_Id,
         P_COPY_ENTITY_RESULT_ID       => l_Prtn_Copy_Entity_Rslt_Id,
         P_DML_OPeration               => 'UPDATE',
         P_INFORMATION323              => NULL,
         P_OBJECT_VERSION_NUMBER       => l_Prtn_ovn);
      End If;
   Else
      l_InsYN := 'Y';
   End If;
   Close Prtn;

End If;

/* Populating Eligibility profiles and the associated criterias */

If ( p_Txn_Mode = 'I' ) Then
--OPEN Csr_Dml_Operation(P_Prfl_Id);
--FETCH Csr_Dml_Operation into l_dml,l_cer_id;
--close Csr_Dml_Operation;

OPEN Csr_is_elp_present(P_Prfl_Id);
FETCH Csr_is_elp_present into l_elp_count;
close Csr_is_elp_present;

if l_elp_count > 0 then
    hr_utility.set_location('DML Operation is INSERT so this ELP is created now', 79);

l_Copy_Entity_Rslt_Id :=  create_duplicate_elp_tree (
   p_copy_entity_txn_id => p_Copy_Entity_txn_Id
  ,p_business_group_id  => P_Business_Group_Id
  ,p_eligy_prfl_id      => P_Prfl_Id
   );
   update ben_copy_entity_results
   set gs_parent_entity_result_id = P_gs_Parent_Entity_Result_Id
      ,parent_entity_result_id = P_gs_Parent_Entity_Result_Id
   where copy_entity_result_id = l_Copy_Entity_Rslt_Id;
else
    hr_utility.set_location('DML Operation is not INSERT so this ELP is from PUI', 79);

   Pqh_Gsp_Hr_To_Stage.Populate_Ep_Hierarchy
   (p_copy_entity_txn_id 	=> p_Copy_Entity_txn_Id
   ,p_effective_date 		=> P_Effective_Date
   ,p_business_group_id         => P_BUSINESS_GROUP_ID
   ,p_ep_id 			=> P_Prfl_Id
   ,P_BUSINESS_AREA             => Nvl(l_Business_Area,'PQH_GSP_TASK_LIST')
   ,p_ep_cer_id                 => l_Copy_Entity_Rslt_Id);

End If;
    hr_utility.set_location('Cer Id of ELP is:'||l_Copy_Entity_Rslt_Id, 79);
End If;


Open TablRoute('EPA');
fetch TablRoute into l_table_Route_Id, L_Table_Name;
Close TablRoute;

If  l_InsYN = 'Y' Then

/* This Insert Links the Ben Object with the Eligibility Profiles (CEP) */
    hr_utility.set_location('Inserting EPA .. L_Prtn_Mirror_result_Id ' || L_Prtn_Mirror_result_Id , 80);

    Ben_Copy_Entity_Results_Api.CREATE_COPY_ENTITY_RESULTS
   (P_EFFECTIVE_DATE              => P_Effective_Date,
    P_COPY_ENTITY_TXN_ID          => p_Copy_Entity_txn_Id,
    P_RESULT_TYPE_CD              => 'DISPLAY',
    P_NUMBER_OF_COPIES            => 1,
    P_TABLE_NAME                  => l_Table_name,
    P_TABLE_ALIAS                 => 'EPA',
    P_TABLE_ROUTE_ID              => l_table_Route_Id,
    P_STATUS                      => 'VALID',
    P_DML_OPERATION               => 'INSERT',
    P_INFORMATION_CATEGORY        => 'GSP',
    p_INFORMATION1		  => l_Prtn_Elig_Id,
    P_INFORMATION2		  => P_Effective_Date,
    P_INFORMATION4                => P_BUSINESS_GROUP_ID,
    p_Information5		  => P_Name,
    P_INFORMATION256              => L_PLIP_ID,
    P_INFORMATION258              => L_OIPL_ID,
    P_INFORMATION260              => L_PGM_ID,
    P_INFORMATION261              => L_PL_ID,
--  P_INFORMATION265              => 1,
    P_GS_MR_SRC_ENTITY_RESULT_ID  => L_Prtn_Mirror_result_Id,
    P_COPY_ENTITY_RESULT_ID       => l_Prtn_Copy_Entity_Rslt_Id,
    P_OBJECT_VERSION_NUMBER       => l_Prtn_Elig_Ovn);

End If;

open TablRoute('CEP');
fetch TablRoute into l_table_Route_Id, L_Table_Name;
Close TablRoute;

Open  PrtnElig;
Fetch PrtnElig into l_PrtnPrfl_Copy_Entity_Rslt_Id, l_Prtn_Elig_Prfl_Ovn, l_Elp_Cer_id, l_Elp_Ovn;

If PrtnElig%FOUND Then
    hr_utility.set_location('Inserting CEP ..l_Prtn_Copy_Entity_Rslt_Id ' || l_Prtn_Copy_Entity_Rslt_Id , 90);

   Ben_Copy_Entity_Results_Api.UPDATE_COPY_ENTITY_RESULTS
  (P_EFFECTIVE_DATE                 => P_Effective_Date,
   P_COPY_ENTITY_TXN_ID             => p_Copy_Entity_txn_Id,
   P_RESULT_TYPE_CD                 => 'DISPLAY',
   P_NUMBER_OF_COPIES               => 1,
   P_TABLE_NAME                     => l_Table_name,
   P_TABLE_ALIAS                    => 'CEP',
   P_TABLE_ROUTE_ID                 => l_table_Route_Id,
   P_STATUS                         => 'VALID',
   P_DML_OPERATION                  => Get_Dml_Operation(l_PrtnPrfl_Copy_Entity_Rslt_Id,'U'),
   P_INFORMATION_CATEGORY           => 'GSP',
   P_INFORMATION2                   => P_EFFECTIVE_DATE,
   P_INFORMATION4                   => P_BUSINESS_GROUP_ID,
   p_Information5		    => P_Name,
   p_Information13                  => P_Compute_Score_Flag,    -- Added for Rank Support
   P_Information12		    => P_Req_opt,
   P_Information15                  => P_Ref_level,
   P_INFORMATION229                 => l_PRTN_ELIG_ID,
   P_INFORMATION263                 => p_Prfl_Id,
-- P_INFORMATION265                 => 1,
   P_INFORMATION323 		    => NULL,
   P_COPY_ENTITY_RESULT_ID          => l_PrtnPrfl_Copy_Entity_Rslt_Id,
   P_GS_MR_SRC_ENTITY_RESULT_ID     => l_Prtn_Copy_Entity_Rslt_Id,
   P_OBJECT_VERSION_NUMBER          => l_Prtn_Elig_Prfl_Ovn);

Else

  hr_utility.set_location('Updating CEP ..l_Prtn_Copy_Entity_Rslt_Id ' || l_Prtn_Copy_Entity_Rslt_Id , 90);

  Ben_Copy_Entity_Results_Api.CREATE_COPY_ENTITY_RESULTS
 (P_EFFECTIVE_DATE                 => P_Effective_Date,
  P_COPY_ENTITY_TXN_ID             => p_Copy_Entity_txn_Id,
  P_RESULT_TYPE_CD                 => 'DISPLAY',
  P_NUMBER_OF_COPIES               => 1,
  P_TABLE_NAME                     => l_Table_name,
  P_TABLE_ALIAS                    => 'CEP',
  P_TABLE_ROUTE_ID                 => l_table_Route_Id,
  P_STATUS                         => 'VALID',
  P_DML_OPERATION                  => 'INSERT',
  P_INFORMATION_CATEGORY           => 'GSP',
  P_INFORMATION1                   => l_PRTN_ELIG_PRFL_ID,
  P_INFORMATION2                   => P_EFFECTIVE_DATE,
  P_INFORMATION4                   => P_BUSINESS_GROUP_ID,
  p_Information5		   => P_Name,
  p_Information13                  => P_Compute_Score_Flag,    -- Added for Rank Support
  P_Information12		   => P_Req_opt,
  P_Information15                  => P_Ref_level,
  P_INFORMATION229                 => l_PRTN_ELIG_ID,
  P_INFORMATION263                 => p_Prfl_Id,
--P_INFORMATION265                 => 1,
  P_COPY_ENTITY_RESULT_ID          => l_PrtnPrfl_Copy_Entity_Rslt_Id,
  P_GS_MR_SRC_ENTITY_RESULT_ID     => l_Prtn_Copy_Entity_Rslt_Id,
  P_OBJECT_VERSION_NUMBER          => l_Prtn_Elig_Prfl_Ovn);

  If p_Txn_Mode <> 'I' Then
     Ben_Copy_Entity_Results_Api.UPDATE_COPY_ENTITY_RESULTS
    (P_EFFECTIVE_DATE              => P_Effective_Date,
     P_COPY_ENTITY_TXN_ID          => p_Copy_Entity_txn_Id,
     P_Gs_Parent_Entity_Result_Id  => P_Gs_Parent_Entity_Result_Id,
     P_GS_MR_SRC_ENTITY_RESULT_ID  => l_PrtnPrfl_Copy_Entity_Rslt_Id,
     P_COPY_ENTITY_RESULT_ID       => l_Elp_Cer_Id,
     P_INFORMATION323              => NULL,
     P_OBJECT_VERSION_NUMBER       => l_Elp_ovn);
  End If;

End If;
Close PrtnElig;

If p_Txn_Mode = 'I' Then

hr_utility.set_location('Txn Mode is I so going for update', 100);

/* this update is used to Link the ELP with the BEN Object */
   Open ovn;
   Fetch ovn into l_ovn;
   Close ovn;

   Ben_Copy_Entity_Results_Api.UPDATE_COPY_ENTITY_RESULTS
  (P_EFFECTIVE_DATE             => P_Effective_Date,
   P_COPY_ENTITY_TXN_ID          => p_Copy_Entity_txn_Id,
   P_Gs_Parent_Entity_Result_Id  => P_Gs_Parent_Entity_Result_Id,
   P_GS_MR_SRC_ENTITY_RESULT_ID  => l_PrtnPrfl_Copy_Entity_Rslt_Id,
   P_COPY_ENTITY_RESULT_ID       => l_Copy_Entity_Rslt_Id,
   P_INFORMATION323              => NULL,
   P_OBJECT_VERSION_NUMBER       => l_ovn);

hr_utility.set_location('Updated gs_paernt successfully', 100);

pull_elpro_to_stage(p_copy_entity_txn_id => p_copy_entity_txn_id,
 p_eligy_prfl_id => p_Prfl_Id,
 p_effective_date => p_effective_date,
 p_business_group_id => p_business_group_id
);

End If;
--hr_utility.trace_off;
/*
Exception
when hr_multi_message.error_message_exist then

hr_utility.set_location('Exception handled ', 100);
--hr_utility.trace_off;
rollback;

When others then

hr_utility.set_location('Unhandled Exception ', 110);
--hr_utility.trace_off;
Raise;
*/
End Create_Eligibility_Profile;

Procedure Delete_Eligibility
(P_Copy_Entity_txn_id    IN  Number
,P_Copy_Entity_result_id IN  NUmber) Is

L_Cep_Cer_Id  Ben_Copy_Entity_Results.Copy_Entity_Result_Id%TYPE;
L_Cep_Ovn     Ben_Copy_Entity_Results.Object_Version_Number%TYPE;
L_Epa_Cer_Id  Ben_Copy_Entity_Results.Copy_Entity_Result_Id%TYPE;
L_Epa_Ovn     Ben_Copy_Entity_Results.Object_Version_Number%TYPE;
L_Dml_Opr     Varchar2(30);
L_EligPrfl_ID Ben_Eligy_Prfl_f.Eligy_Prfl_Id%TYPE;
L_Cnt         Number(15);

Cursor Del_Elp is
Select Copy_Entity_Result_Id, Object_Version_Number
  from Ben_Copy_Entity_Results
 where Copy_Entity_txn_Id    = P_Copy_Entity_Txn_Id
 Start With  Copy_Entity_Result_Id = P_Copy_Entity_Result_Id
Connect By Gs_Parent_Entity_Result_Id = Prior Copy_Entity_Result_Id;

 Cursor Cep_id is
 Select Gs_Mirror_Src_Entity_Result_id, INFORMATION1
   From Ben_Copy_Entity_results
  Where Copy_Entity_Result_Id = P_Copy_Entity_result_id;

 Cursor EPA_Id is
 Select Gs_Mirror_Src_Entity_Result_id
   from Ben_Copy_Entity_Results
  Where Copy_Entity_Result_Id = L_Cep_Cer_Id;

 Cursor Ovn_Dtls (P_Cer_id IN Number) Is
 Select Object_Version_Number
   From Ben_Copy_Entity_Results
  Where Copy_Entity_Result_Id = P_Cer_id;

Begin

 Open Cep_id;
Fetch Cep_id into L_Cep_Cer_Id, L_EligPrfl_ID;
Close Cep_id;

 Open Ovn_Dtls(L_Cep_Cer_Id);
Fetch Ovn_Dtls into L_Cep_Ovn;
Close Ovn_Dtls;

 Open Epa_Id;
Fetch Epa_Id Into L_Epa_Cer_Id;
Close Epa_Id;

 Open Ovn_Dtls(L_Epa_Cer_Id);
Fetch Ovn_Dtls into L_Epa_Ovn;
Close Ovn_Dtls;

 Select Count(*) into L_Cnt
   from Ben_Copy_Entity_Results Prtn,
        Ben_Copy_Entity_Results PrtnElig
  where Prtn.Copy_Entity_Txn_Id                  =  p_Copy_Entity_txn_Id
    and Prtn.Copy_ENTITY_RESULT_ID               =  L_Epa_Cer_Id
    and Prtn.Table_alias                         =  'EPA'
    and PrtnElig.Copy_Entity_Txn_Id              =  Prtn.Copy_Entity_Txn_Id
    and Prtnelig.Gs_Mirror_Src_Entity_Result_id  =  Prtn.Copy_Entity_Result_Id
    and PrtnElig.INFORMATION263                  <> L_EligPrfl_ID
    and PrtnElig.Dml_Operation                   <> 'DELETE';

If L_Cnt = 0 then
   L_Dml_Opr := Get_Dml_Operation(L_Epa_Cer_Id, 'D');

   If L_Dml_Opr = 'PURGE' then
      Ben_Copy_Entity_Results_Api.DELETE_COPY_ENTITY_RESULTS
      (P_COPY_ENTITY_RESULT_ID        => L_Epa_Cer_Id,
       P_OBJECT_VERSION_NUMBER        => L_Epa_Ovn,
       P_EFFECTIVE_DATE               => Trunc(Sysdate));
   Else
     Ben_Copy_Entity_Results_Api.UPDATE_COPY_ENTITY_RESULTS
     (P_EFFECTIVE_DATE                 => Trunc(Sysdate),
      P_COPY_ENTITY_TXN_ID             => p_Copy_Entity_txn_Id,
      P_DML_OPERATION                  => 'DELETE',
      P_INFORMATION323 		       => NULL,
      P_COPY_ENTITY_RESULT_ID          => L_Epa_Cer_Id,
      P_OBJECT_VERSION_NUMBER          => L_Epa_Ovn);
   End If;
End IF;

l_Dml_opr := NULL;
L_Dml_Opr := Get_Dml_Operation(L_Cep_Cer_Id, 'D');

If L_Dml_Opr = 'PURGE' then
   Ben_Copy_Entity_Results_Api.DELETE_COPY_ENTITY_RESULTS
   (P_COPY_ENTITY_RESULT_ID        => L_Cep_Cer_Id,
    P_OBJECT_VERSION_NUMBER        => L_Cep_Ovn,
    P_EFFECTIVE_DATE               => Trunc(Sysdate));
Else
 Ben_Copy_Entity_Results_Api.UPDATE_COPY_ENTITY_RESULTS
  (P_EFFECTIVE_DATE                 => Trunc(Sysdate),
   P_COPY_ENTITY_TXN_ID             => p_Copy_Entity_txn_Id,
   P_DML_OPERATION                  => 'DELETE',
   P_INFORMATION323 		    => NULL,
   P_COPY_ENTITY_RESULT_ID          => L_Cep_Cer_Id,
   P_OBJECT_VERSION_NUMBER          => L_Cep_Ovn);
End If;

For Del_Elp_rec in Del_Elp
Loop
   Ben_Copy_Entity_Results_Api.DELETE_COPY_ENTITY_RESULTS
   (P_COPY_ENTITY_RESULT_ID        => Del_Elp_rec.Copy_Entity_result_id,
    P_OBJECT_VERSION_NUMBER        => Del_Elp_rec.Object_version_number,
    P_EFFECTIVE_DATE               => Trunc(Sysdate));
End Loop;
End;
procedure pull_elpro_to_stage(p_copy_entity_txn_id in number,
 p_eligy_prfl_id in number,
 p_effective_date in date,
 p_business_group_id in number
)
is

l_proc varchar2(30) := 'pull_elpro_to_stage';
l_parent_cer_id number;
l_cer_ovn number;
l_elp_orignal_in_stage varchar2(1);
l_pull_elpro boolean:=true;

Cursor csr_elp_orignal_in_stage
is
select null
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and table_alias = 'ELP'
and information1 = p_eligy_prfl_id;

begin
      hr_utility.set_location('Entering '||l_proc,10);
hr_utility.set_location('p_Copy_Entity_txn_Id '||p_Copy_Entity_txn_Id,10);
hr_utility.set_location('P_Effective_Date'||P_Effective_Date,10);
hr_utility.set_location('p_eligy_prfl_id'||p_eligy_prfl_id,10);
hr_utility.set_location(' P_Business_Group_Id'||P_Business_Group_Id,10);

OPEN csr_elp_orignal_in_stage;
Fetch csr_elp_orignal_in_stage into l_elp_orignal_in_stage;

if csr_elp_orignal_in_stage%FOUND then
    l_pull_elpro := false;
else
    l_pull_elpro := true;
end if;

close csr_elp_orignal_in_stage;
if l_pull_elpro then
    hr_utility.set_location('copying ep hier',20);

 ben_plan_design_elpro_module.create_elig_prfl_results
       (p_copy_entity_txn_id          => p_copy_entity_txn_id
       ,p_mirror_src_entity_result_id => l_parent_cer_id
       ,p_parent_entity_result_id     => l_parent_cer_id
       ,p_mndtry_flag                 => ''
       ,p_eligy_prfl_id               =>  p_eligy_prfl_id
       ,p_business_group_id           => p_business_group_id
       ,p_number_of_copies            => 1
       ,p_object_version_number       => l_cer_ovn
       ,p_effective_date              => p_effective_date
      );
      hr_utility.set_location('copied ep hier',20);

      BEN_PDW_COPY_BEN_TO_STG.populate_extra_mapping_ELP(
                        p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_effective_date => p_effective_date,
                        p_elig_prfl_id =>p_eligy_prfl_id
                        );

      hr_utility.set_location('Done with the mapping',25);
end if;

-- For elp/child_records which have future records , pdw needs the
-- attribute FUTURE_DATA_EXISTS properly set so that they can properly
-- set the datetrack_mode and dml_operation
-- The following code is copied from BEN_PDW_COPY_BEN_TO_STG.mark_future_data_exists

    update ben_copy_entity_results a
            set future_data_exists ='Y'
            where a.copy_entity_txn_id = p_copy_entity_txn_id
            and a.future_data_exists is null
            and a.information3 < to_date('4712/12/31','YYYY/MM/DD')
            and exists
            ( select 'Y' from ben_copy_entity_results b
              where b.copy_entity_txn_id = a.copy_entity_txn_id
              and b.table_alias = a.table_alias
              and b.information1 = a.information1
              and b.information2 = a.information3+1);
    hr_utility.set_location('Updated bcer records for future_data_exists flag',25);

      hr_utility.set_location('Leaving '||l_proc,10);
end pull_elpro_to_stage;

procedure upd_alias_of_dup
    (p_copy_entity_txn_id in number,
     p_business_group_id in number
    )
is
l_rows number;
begin
hr_utility.set_location('Inside upd_alias_of_dup',10);
 update ben_copy_entity_results
    set table_alias = table_alias||'-DUP'
  where copy_entity_txn_id = p_copy_entity_txn_id
    and information1 is null
    and table_alias in ('ELP'
,'CGP','EAI','EAN','EAP','EBN','EBU','ECL','ECP','ECQ','ECY'
,'EDB','EDG','EDI','EDP','EDT','EEG','EEI','EEP','EES','EET'
,'EFP','EGN','EGR','EHC','EHS','EHW','EJP','ELN','ELR','ELS'
,'ELU','ELV','ENO','EOM','EOP','EOU','EOY','EPB','EPF','EPG'
,'EPP','EPS','EPT','EPY','EPZ','EQG','EQT','ERG','ESA','ESH'
,'ETC','ETD','ETP','ETU','EWL'
,'ECV'
,'AGF','CLA','CLF','HWF','LSF','PFF','SVA','RZR','BNG','EGL' );

l_rows:= sql%rowcount ;
hr_utility.set_location('Total-'||l_rows||'-table aliases updated',10);
end upd_alias_of_dup;

procedure reset_alias_of_dup
    (p_copy_entity_txn_id in number,
     p_business_group_id in number
    )
is
l_rows number;
begin
hr_utility.set_location('Inside reset_alias_of_dup',10);
 update ben_copy_entity_results
    set table_alias = replace(table_alias,'-DUP',null)
  where copy_entity_txn_id = p_copy_entity_txn_id
    and information1 is null;

l_rows:= sql%rowcount ;
hr_utility.set_location('Total-'||l_rows||'-table aliases updated',10);
end reset_alias_of_dup;

procedure prepare_drv_fctr4pdw (
   p_copy_entity_txn_id number,
   p_business_group_id in number
   )
is
-- Keep only one record of Derieved factor with information1

-- get all Derieved factor records
cursor cur_drv_fctr is
select information101, copy_entity_result_id
  from ben_copy_entity_results
 where table_alias in ('AGF','CLA','CLF','HWF','LSF','PFF','SVA','RZR','BNG','EGL' )
   and copy_entity_txn_id  = p_copy_entity_txn_id
   and (information1 is null or information1 = information101)
   and information101 is not null
order by information101,information1 ;

prev_info101 number ;

begin

prev_info101 := -1 ;

-- for all "non null info101" Derieved factor records
for rec_drv_fctr in cur_drv_fctr
loop
    -- update all but one
    if (rec_drv_fctr.information101 <> prev_info101)
    then

    update ben_copy_entity_results
       set information1 = information101
     where copy_entity_result_id = rec_drv_fctr.copy_entity_result_id;

    end if;
    prev_info101 := rec_drv_fctr.information101 ;
end loop;

upd_alias_of_dup(p_copy_entity_txn_id, p_business_group_id);

end prepare_drv_fctr4pdw ;

End Pqh_Gsp_PrgRules;

/
