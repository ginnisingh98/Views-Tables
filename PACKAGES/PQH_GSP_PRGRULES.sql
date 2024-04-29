--------------------------------------------------------
--  DDL for Package PQH_GSP_PRGRULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_PRGRULES" AUTHID CURRENT_USER As
/* $Header: pqgspelg.pkh 120.5.12000000.2 2007/06/11 10:17:43 sidsaxen noship $ */
Function Get_Ref_Level
(P_Parent_Cer_Id	IN Number,
 P_prfl_Id              IN Number)
Return Varchar2;

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
 P_Compute_Score_Flag		In Varchar2);

Procedure Delete_Eligibility
(P_Copy_Entity_txn_id    IN  Number
,P_Copy_Entity_result_id IN  NUmber);

procedure pull_elpro_to_stage
(
 p_copy_entity_txn_id in number,
 p_eligy_prfl_id in number,
 p_effective_date in date,
 p_business_group_id in number
 );
procedure update_crit_records_in_staging(p_copy_entity_txn_id in number);
--<-------- procedure prepare_elp_recs4pdw -------->
-- purpose - To prepare ELP record for pdw
-- accept  - cet_id
-- do      - nullifys all info1 columns of ELP and its child records
-- return  -
--<------------------------------------------------>
procedure prepare_elp_recs4pdw (
   p_copy_entity_txn_id number
  ,p_business_group_id number
   );

procedure nullify_elp_rec (
   p_copy_entity_result_id number
  ,p_copy_entity_txn_id number
   );

--<-------- function create_duplicate_elp_tree -------->
-- purpose - To create duplicate hierarchy of an existing ELPRO in staging area
-- accept  - a elig pro id
-- do      - will create a duplicate hierarchy for this elpro
--           it will copy paste this elpro and its child and grand children
-- return  - return cerid of the newly created duplicate elpro record
--<----------------------------------------------------->
function create_duplicate_elp_tree (
   p_copy_entity_txn_id number
  ,p_business_group_id  number
  ,p_eligy_prfl_id      number
   )
return number ;


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
   );

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
   );

procedure upd_alias_of_dup
    (p_copy_entity_txn_id in number,
     p_business_group_id in number
    );

procedure reset_alias_of_dup
    (p_copy_entity_txn_id in number,
     p_business_group_id in number
    );

procedure prepare_drv_fctr4pdw (
   p_copy_entity_txn_id number,
   p_business_group_id in number
   );

End Pqh_Gsp_PrgRules;

 

/
