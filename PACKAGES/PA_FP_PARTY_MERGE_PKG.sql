--------------------------------------------------------
--  DDL for Package PA_FP_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPPYMS.pls 120.0 2005/06/03 13:49:39 appldev noship $ */
procedure fp_merged_ctrl_party_merge(
                        p_entity_name in varchar2,
                        p_from_id in number,
                        p_to_id in out nocopy number,
                        p_from_fk_id in number,
                        p_to_fk_id in number,
                        p_parent_entity_name in varchar2,
                        p_batch_id in number,
                        p_batch_party_id in number,
                        p_return_status in out nocopy varchar2);
end Pa_Fp_Party_Merge_Pkg;

 

/
