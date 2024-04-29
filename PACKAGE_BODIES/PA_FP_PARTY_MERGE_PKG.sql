--------------------------------------------------------
--  DDL for Package Body PA_FP_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_PARTY_MERGE_PKG" AS
/* $Header: PAFPPYMB.pls 120.0 2005/05/29 15:13:08 appldev noship $ */
procedure fp_merged_ctrl_party_merge(
                        p_entity_name in varchar2,
                        p_from_id in number,
                        p_to_id in out nocopy number,
                        p_from_fk_id in number,
                        p_to_fk_id in number,
                        p_parent_entity_name in varchar2,
                        p_batch_id in number,
                        p_batch_party_id in number,
                        p_return_status in out nocopy varchar2) is
begin
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  if (p_from_fk_id <> p_to_fk_id) then

    update pa_fp_merged_ctrl_items
    set included_by_person_id = p_to_fk_id,
                                last_update_date = hz_utility_pub.last_update_date,
      			 	last_updated_by = hz_utility_pub.user_id,
     			 	last_update_login = hz_utility_pub.last_update_login,
                                record_version_number=nvl(record_Version_number,0) +1
    where included_by_person_id = p_from_fk_id;


  end if;

end fp_merged_ctrl_party_merge;
END Pa_Fp_Party_Merge_Pkg;

/
