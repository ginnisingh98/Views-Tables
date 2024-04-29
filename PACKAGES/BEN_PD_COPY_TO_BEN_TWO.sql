--------------------------------------------------------
--  DDL for Package BEN_PD_COPY_TO_BEN_TWO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PD_COPY_TO_BEN_TWO" AUTHID CURRENT_USER as
/* $Header: bepdccp2.pkh 120.1.12000000.1 2007/01/19 20:44:56 appldev noship $ */
--
--TCS PDW Integration ENH

--cursor g_copy_entity_txn is used by the body of BEN_PD_COPY_TO_BEN_TWO in
--create_pgm_intersect_rows, this cursor along with the globals defined
--are used to avoid unnecessary queries to DB if the copy_entity_txn_id
--remains unchanged.

-- It would be a good idea NOT to use the cursor in any other file other
-- than BEN_PD_COPY_TO_BEN_TWO body , this would improve modularity and.

     cursor g_copy_entity_txn(c_copy_entity_txn_id number) is
	select cet.row_type_cd row_type_cd
	from ben_copy_entity_txns_vw cet,
	     PQH_TRANSACTION_CATEGORIES ptc
	where cet.COPY_ENTITY_TXN_ID= c_copy_entity_txn_id
	and ptc.TRANSACTION_CATEGORY_ID = cet.TRANSACTION_CATEGORY_ID;

g_copy_entity_txn_id PQH_COPY_ENTITY_TXNS.COPY_ENTITY_TXN_ID%type := -999999;
g_row_type_cd     ben_copy_entity_txns_vw.row_type_cd%type := null;
--TCS PDW Integration ENH

procedure set_mapping(p_copy_entity_txn_id number) ;
--
procedure create_final_intersect_rows
(
         p_validate                       in  number     default 0
        ,p_copy_entity_txn_id             in  number
        ,p_effective_date                 in  date
        ,p_prefix_suffix_text             in  varchar2  default null
        ,p_reuse_object_flag              in  varchar2  default null
        ,p_target_business_group_id       in  varchar2  default null
        ,p_prefix_suffix_cd               in  varchar2  default null
);
procedure create_pgm_intersect_rows(
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_effective_date                 in  date
  ,p_prefix_suffix_text             in  varchar2  default null
  ,p_reuse_object_flag              in  varchar2  default null
  ,p_target_business_group_id       in  varchar2  default null
  ,p_prefix_suffix_cd               in  varchar2  default null
 );
procedure create_stg_to_ben_rows
(
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_effective_date                 in  date
  ,p_prefix_suffix_text             in  varchar2  default null
  ,p_reuse_object_flag              in  varchar2  default null
  ,p_target_business_group_id       in  varchar2  default null
  ,p_prefix_suffix_cd               in  varchar2  default null
  ,p_effective_date_to_copy         in  date      default null
 ) ;
-- ----------------------------------------------------------------------------
end BEN_PD_COPY_TO_BEN_TWO;

 

/
