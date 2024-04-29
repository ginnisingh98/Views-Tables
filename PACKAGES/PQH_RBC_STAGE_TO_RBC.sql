--------------------------------------------------------
--  DDL for Package PQH_RBC_STAGE_TO_RBC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RBC_STAGE_TO_RBC" AUTHID CURRENT_USER as
/* $Header: pqrbcsrb.pkh 120.0 2005/09/14 15:38 srajakum noship $ */

procedure pre_push_data(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_Date_Track_Mode    in Varchar2,
                        p_status out nocopy varchar2);



procedure rbc_data_push(p_copy_entity_txn_id in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_datetrack_mode     in varchar2,
                        p_status out nocopy varchar2 ) ;

procedure rbc_stage_to_hr(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number,
                          p_datetrack_mode     in varchar2,
                          p_status             out nocopy varchar2
                          );

Procedure stage_to_rmn(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_plan_id   in number,
                         p_datetrack_mode in varchar2
                         );

Procedure stage_to_plan(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_datetrack_mode     in varchar2);

Procedure stage_to_rmn_values(p_copy_entity_txn_id in number,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_rmn_id in number );

Procedure stage_to_rmr(p_copy_entity_txn_id in number,
                   p_effective_date     in date,
                   p_business_group_id  in number,
                   p_datetrack_mode     in varchar2,
                   p_rmn_id in number);

end pqh_rbc_stage_to_rbc;

 

/
