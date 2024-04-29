--------------------------------------------------------
--  DDL for Package Body ECX_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_VENDORMERGE_GRP" as
/* $Header: ECXPVMRB.pls 120.2 2006/09/25 23:11:50 sbastida noship $ */

procedure merge_vendor (
    p_api_version		 IN	       NUMBER,
    p_init_msg_list 	 IN	       VARCHAR2 default FND_API.G_FALSE,
    p_commit		 IN	       VARCHAR2 default FND_API.G_FALSE,
    p_validation_level	 IN	       NUMBER	default FND_API.G_VALID_LEVEL_FULL,
    p_return_status 	 OUT  NOCOPY   VARCHAR2,
    p_msg_count		 OUT  NOCOPY   NUMBER,
    p_msg_data		 OUT  NOCOPY   VARCHAR2,
    p_vendor_id		 IN	       NUMBER,
    p_dup_vendor_id 	 IN	       NUMBER,
    p_vendor_site_id	 IN	       NUMBER,
    p_dup_vendor_site_id	 IN	       NUMBER,
    p_party_id		 IN	       NUMBER,
    P_dup_party_id		 IN	       NUMBER,
    p_party_site_id 	 IN	       NUMBER,
    p_dup_party_site_id	 IN	       NUMBER
) is
begin

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check if parent didn't change
    if (p_dup_party_id = p_party_id and p_dup_party_site_id = p_party_site_id) then
       return;
    end if;

    -- update ECX_TP_HEADERS for the merge

    UPDATE ECX_TP_HEADERS
    set party_id = p_party_id,
        party_site_id = p_party_site_id,
        last_updated_by = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login
    where party_id = p_dup_party_id
      and party_site_id = p_dup_party_site_id;

    -- update ECX_DOCLOGS for the merge

    UPDATE ECX_DOCLOGS
    set partyid = to_char(p_party_id),
        party_site_id = to_char(p_party_site_id)
    where partyid = to_char(p_dup_party_id)
      and party_site_id = to_char(p_dup_party_site_id);

    -- update ECX_OUTBOUND_LOGS for the merge

    UPDATE ECX_OUTBOUND_LOGS
    set party_id = to_char(p_party_id),
        party_site_id = to_char(p_party_site_id)
    where party_id = to_char(p_dup_party_id)
      and party_site_id = to_char(p_dup_party_site_id);

    -- update ECX_OUTTRIG_LOGS for the merge

/*  BUG:5553250
    UPDATE ECX_OUTTRIG_LOGS
    set party_id = to_char(p_party_id),
        party_site_id = to_char(p_party_site_id)
    where party_id = to_char(p_dup_party_id)
      and party_site_id = to_char(p_dup_party_site_id);*/

exception
   when others then
     p_msg_count := nvl(p_msg_count,0) + 1;
     p_msg_data :=  'SQLCODE: '|| SQLCODE ||' SQLERRM: '|| SQLERRM ||'*';
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

end merge_vendor;

end;

/
