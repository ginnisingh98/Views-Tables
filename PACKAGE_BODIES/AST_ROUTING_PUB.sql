--------------------------------------------------------
--  DDL for Package Body AST_ROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_ROUTING_PUB" AS
/* $Header: asttmrtb.pls 120.2 2006/03/25 05:53:03 savadhan noship $ */

PROCEDURE getResourcesForParty (
	p_party_id 	IN 	NUMBER,
     p_resources 	OUT 	NOCOPY resource_access_tbl_type) is

  cursor get_resources_for_party (p_cust_id NUMBER) is
	select distinct salesforce_id
	from as_accesses_all
	where lead_id is null
	and sales_lead_id is null
	and team_leader_flag = 'Y'
	and customer_id = p_cust_id;

  cursor get_partytype (p_cust_id NUMBER) is
	select party_type
	from hz_parties
	where party_id = p_cust_id;

  cursor get_subject_object (p_rel_party_id NUMBER) is
	select subject_id, object_id
	from hz_relationships
	where party_id = p_rel_party_id;

  cursor get_resources_for_rel (p_subject_id NUMBER, p_object_id NUMBER) is
	select distinct salesforce_id
	from as_accesses_all
	where lead_id is null
	and sales_lead_id is null
	and team_leader_flag = 'Y'
	and customer_id in (p_subject_id, p_object_id);

  l_party_type 	VARCHAR2(30);
  l_subject_id 	NUMBER;
  l_object_id		NUMBER;

  l_index			BINARY_INTEGER := 0;
  l_resource_rec	resource_access_rec_type;

begin
  open get_partytype(p_party_id);
  fetch get_partytype into l_party_type;
  close get_partytype;

  if l_party_type = 'PARTY_RELATIONSHIP' then
    	open get_subject_object(p_party_id);
    	fetch get_subject_object into l_subject_id, l_object_id;
    	close get_subject_object;

	-- all resources with update access on the sales team of either
	-- the subject or the object of the relationship
    	for res_rec in get_resources_for_rel(l_subject_id,l_object_id) loop
		l_index := l_index + 1;
		l_resource_rec.resource_id := res_rec.salesforce_id;
		p_resources(l_index) := l_resource_rec;
    	end loop;
  else
	-- all resources with update access on the sales team of the party
    	for res_rec in get_resources_for_party(p_party_id) loop
		l_index := l_index + 1;
		l_resource_rec.resource_id := res_rec.salesforce_id;
		p_resources(l_index) := l_resource_rec;
    	end loop;
  end if;

exception
  when others then
	return;
end getResourcesForParty;

PROCEDURE getResourcesForSourceCode (
	p_source_code 	IN 	VARCHAR2,
     p_resources 	OUT NOCOPY 	resource_access_tbl_type) is

  cursor get_resources_for_source_code (p_source_code VARCHAR2) is
	select distinct arc.resource_id
	from ast_rs_campaigns arc, ams_campaign_schedules_b cs
	where arc.campaign_id = cs.schedule_id
	and cs.source_code = p_source_code
	and arc.status = 'A'
	and arc.enabled_flag = 'Y'
  union
	select distinct gm.resource_id
	from ast_grp_campaigns agc, ams_campaign_schedules_b cs, jtf_rs_group_members gm, jtf_rs_groups_denorm gd
	where agc.campaign_id = cs.schedule_id
	and cs.source_code = p_source_code
	and agc.enabled_flag = 'Y'
	and agc.group_id = gd.parent_group_id
	and gd.group_id = gm.group_id;

  l_index			BINARY_INTEGER := 0;
  l_resource_rec	resource_access_rec_type;

begin

  for res_rec in get_resources_for_source_code(p_source_code) loop
	l_index := l_index + 1;
	l_resource_rec.resource_id := res_rec.resource_id;
	p_resources(l_index) := l_resource_rec;
  end loop;

exception
  when others then
	return;
end getResourcesForSourceCode;

FUNCTION getPartyfromANI(p_object_value IN VARCHAR2) return NUMBER is
  l_filtered_ANI 	VARCHAR2(60);
  l_transposed_ANI 	VARCHAR2(60);
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromANI (p_ANI VARCHAR2) is
  	select owner_table_id
  	from hz_contact_points
  	where transposed_phone_number like p_ANI
  	and owner_table_name = 'HZ_PARTIES'
  	and status = 'A';

begin
  l_filtered_ANI := translate(p_object_value,
				'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()- .+''~`\/@#$^&*_,|}{[]?<>=";:%',
				'0123456789');
  if l_filtered_ANI is null or l_filtered_ANI = '' then
	return G_NO_PARTY;
  end if;

  l_transposed_ANI := null;
  for c in reverse 1..length(l_filtered_ANI) loop
	l_transposed_ANI := l_transposed_ANI || substr(l_filtered_ANI, c, 1);
  end loop;
  l_transposed_ANI := RTRIM(l_transposed_ANI, 0) || '%'; -- Added for bug#4043234

  open getPartyIDfromANI(l_transposed_ANI);
  fetch getPartyIDfromANI into l_partyID;
  if getPartyIDfromANI%FOUND then
	fetch getPartyIDfromANI into l_more_partyID;
	if getPartyIDfromANI%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromANI;

  return l_partyID;
end getPartyfromANI;

FUNCTION getPartyfromPartyID(p_object_value IN VARCHAR2) return NUMBER is
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;
  l_object_value	NUMBER;

  cursor getPartyIDfromPartyID (p_PartyID NUMBER) is
  	select party_id
  	from hz_parties
  	where party_id = p_PartyID;

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  begin
  	l_object_value := to_number(p_object_value);
  exception
	when OTHERS then
		return G_NO_PARTY;
  end;

  open getPartyIDfromPartyID(l_object_value);
  fetch getPartyIDfromPartyID into l_partyID;
  if getPartyIDfromPartyID%FOUND then
	fetch getPartyIDfromPartyID into l_more_partyID;
	if getPartyIDfromPartyID%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromPartyID;

  return l_partyID;
end getPartyfromPartyID;

FUNCTION getPartyfromPartyNum(p_object_value IN VARCHAR2) return NUMBER is
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromPartyNum (p_PartyNum VARCHAR2) is
  	select party_id
  	from hz_parties
  	where party_number = p_PartyNum;

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  open getPartyIDfromPartyNum(p_object_value);
  fetch getPartyIDfromPartyNum into l_partyID;
  if getPartyIDfromPartyNum%FOUND then
	fetch getPartyIDfromPartyNum into l_more_partyID;
	if getPartyIDfromPartyNum%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromPartyNum;

  return l_partyID;
end getPartyfromPartyNum;

FUNCTION getPartyfromQuoteNum(p_object_value IN VARCHAR2) return NUMBER is
  l_quote_number	NUMBER;
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromQuoteNum (p_QuoteNum NUMBER) is
  	select party_id
  	from aso_quote_headers_all
  	where quote_number = p_QuoteNum
	;
	-- commented out as this column is introduced only in ASO.J
	--and max_version_flag = 'Y';

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  begin
  	l_quote_number := to_number(p_object_value);
  exception
	when OTHERS then
		return G_NO_PARTY;
  end;

  open getPartyIDfromQuoteNum(l_quote_number);
  fetch getPartyIDfromQuoteNum into l_partyID;
  if getPartyIDfromQuoteNum%FOUND then
	fetch getPartyIDfromQuoteNum into l_more_partyID;
	if getPartyIDfromQuoteNum%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromQuoteNum;

  return l_partyID;
end getPartyfromQuoteNum;

FUNCTION getPartyfromOrderNum(p_object_value IN VARCHAR2) return NUMBER is
  l_order_number	NUMBER;
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromOrderNum (p_OrderNum NUMBER) is
  	select a.party_id
  	from oe_order_headers_all o, hz_cust_accounts a
  	where o.order_number = p_OrderNum
	and a.cust_account_id = o.sold_to_org_id;

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  begin
  	l_order_number := to_number(p_object_value);
  exception
	when OTHERS then
		return G_NO_PARTY;
  end;

  open getPartyIDfromOrderNum(l_order_number);
  fetch getPartyIDfromOrderNum into l_partyID;
  if getPartyIDfromOrderNum%FOUND then
	fetch getPartyIDfromOrderNum into l_more_partyID;
	if getPartyIDfromOrderNum%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromOrderNum;

  return l_partyID;
end getPartyfromOrderNum;

FUNCTION getPartyfromCollRequest(p_object_value IN VARCHAR2) return NUMBER is
  l_coll_req		NUMBER;
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromCollRequest (p_CollRequest NUMBER) is
  	select nvl(car.party_id, ca.party_id)
--  	from ams_request_history
--  	where order_id = p_CollRequest;
-- commented out lines above as table not available yet
--	from aso_quote_headers_all
--	where quote_number = p_CollRequest;
--   01/13/2003 - not using AMS or ASO tables, going straight to OE tables
	from oe_order_headers_all o, hz_cust_account_roles car, hz_cust_accounts ca
	where o.order_number = p_CollRequest
	and o.sold_to_contact_id = car.cust_account_role_id(+)
	and o.sold_to_org_id = ca.cust_account_id;

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  begin
  	l_coll_req := to_number(p_object_value);
  exception
	when OTHERS then
		return G_NO_PARTY;
  end;

  open getPartyIDfromCollRequest(l_coll_req);
  fetch getPartyIDfromCollRequest into l_partyID;
  if getPartyIDfromCollRequest%FOUND then
	fetch getPartyIDfromCollRequest into l_more_partyID;
	if getPartyIDfromCollRequest%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromCollRequest;

  return l_partyID;
end getPartyfromCollRequest;

FUNCTION getPartyfromAccountNum(p_object_value IN VARCHAR2) return NUMBER is
  l_partyID		NUMBER;
  l_custAccountID	NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromAccountNum (p_AccountNum VARCHAR2) is
  	select party_id, cust_account_id
  	from hz_cust_accounts
  	where account_number = p_AccountNum;

  -- kmahajan 03/26/03 - changed cursor to fix bug 2872318
  cursor getAccountRoles (p_AccountID NUMBER) is
  	select cust_account_id
  	from hz_cust_account_roles
  	where cust_account_id = p_AccountID;

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  open getPartyIDfromAccountNum(p_object_value);
  fetch getPartyIDfromAccountNum into l_partyID, l_custAccountID;
  if getPartyIDfromAccountNum%FOUND then
	fetch getPartyIDfromAccountNum into l_more_partyID, l_custAccountID;
	if getPartyIDfromAccountNum%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
		l_custAccountID := null;
	end if;
  else
	l_partyID := G_NO_PARTY;
	l_custAccountID := null;
  end if;
  close getPartyIDfromAccountNum;

  if l_custAccountID is not null then
	open getAccountRoles(l_custAccountID);
	fetch getAccountRoles into l_custAccountID;
	if getAccountRoles%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  end if;

  return l_partyID;
end getPartyfromAccountNum;

FUNCTION getPartyfromEvRegCode(p_object_value IN VARCHAR2) return NUMBER is
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromEvRegCode (p_EvRegCode VARCHAR2) is
  	select registrant_party_id
  	from ams_event_registrations
  	where confirmation_code = p_EvRegCode;

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  open getPartyIDfromEvRegCode(p_object_value);
  fetch getPartyIDfromEvRegCode into l_partyID;
  if getPartyIDfromEvRegCode%FOUND then
	fetch getPartyIDfromEvRegCode into l_more_partyID;
	if getPartyIDfromEvRegCode%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromEvRegCode;

  return l_partyID;
end getPartyfromEvRegCode;

FUNCTION getPartyfromMPin(p_object_value IN VARCHAR2) return NUMBER is
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromMPin (p_MPin VARCHAR2) is
  	select party_id
  	from ams_list_entries
  	where pin_code = p_MPin;

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  open getPartyIDfromMPin(p_object_value);
  fetch getPartyIDfromMPin into l_partyID;
  if getPartyIDfromMPin%FOUND then
	fetch getPartyIDfromMPin into l_more_partyID;
	if getPartyIDfromMPin%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromMPin;

  return l_partyID;
end getPartyfromMPin;

FUNCTION getPartyfromContractNum(p_object_value IN VARCHAR2, p_object2_value IN VARCHAR2 default null) return NUMBER is
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromContractNum (p_ContractNum VARCHAR2, p_ContractNumMod VARCHAR2 default null) is
  	select to_number(p.object1_id1)
  	from okc_k_party_roles_b p , okc_k_headers_b k
  	where k.contract_number = p_ContractNum
	and k.contract_number_modifier = nvl(p_ContractNumMod, k.contract_number_modifier)
	and k.id = p.dnz_chr_id
	and p.primary_yn = 'Y'
	and p.jtot_object1_code = 'OKX_PARTY';
	--and p.object1_id2 = '#';

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  open getPartyIDfromContractNum(p_object_value, p_object2_value);
  fetch getPartyIDfromContractNum into l_partyID;
  if getPartyIDfromContractNum%FOUND then
	fetch getPartyIDfromContractNum into l_more_partyID;
	if getPartyIDfromContractNum%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromContractNum;

  return l_partyID;
end getPartyfromContractNum;

FUNCTION getPartyfromServiceKey(p_object_value IN VARCHAR2) return NUMBER is
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromServiceKey (p_ServiceKey VARCHAR2) is
  	select owner_party_id
  	from csi_item_instances
  	where instance_number = p_ServiceKey
	and owner_party_source_table = 'HZ_PARTIES';

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  open getPartyIDfromServiceKey(p_object_value);
  fetch getPartyIDfromServiceKey into l_partyID;
  if getPartyIDfromServiceKey%FOUND then
	fetch getPartyIDfromServiceKey into l_more_partyID;
	if getPartyIDfromServiceKey%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromServiceKey;

  return l_partyID;
end getPartyfromServiceKey;

FUNCTION getPartyfromSRNum(p_object_value IN VARCHAR2) return NUMBER is
  l_partyID		NUMBER;
  l_more_partyID	NUMBER;

  cursor getPartyIDfromSRNum (p_SRNum VARCHAR2) is
  	select customer_id
  	from cs_incidents_all_b
  	where incident_number = p_SRNum;

begin
  if p_object_value is null or p_object_value = '' then
	return G_NO_PARTY;
  end if;

  open getPartyIDfromSRNum(p_object_value);
  fetch getPartyIDfromSRNum into l_partyID;
  if getPartyIDfromSRNum%FOUND then
	fetch getPartyIDfromSRNum into l_more_partyID;
	if getPartyIDfromSRNum%FOUND then
		l_partyID := G_MULTIPLE_PARTY;
	end if;
  else
	l_partyID := G_NO_PARTY;
  end if;
  close getPartyIDfromSRNum;

  return l_partyID;
end getPartyfromSRNum;

PROCEDURE getPartyForObject (
	p_object_type 	IN 	VARCHAR2,
	p_object_value	IN 	VARCHAR2,
	p_party_name 	OUT NOCOPY 	VARCHAR2,
	p_party_id 	OUT NOCOPY 	NUMBER) is

  l_object_type VARCHAR2(100) := null;
  l_object_value VARCHAR2(100) := null;
begin
  getPartyForObject(p_object_type, p_object_value, l_object_type, l_object_value, p_party_name, p_party_id);
end getPartyForObject;

PROCEDURE getPartyForObject (
	p_object_type 	IN 	VARCHAR2,
	p_object_value	IN 	VARCHAR2,
	p_object2_type 	IN OUT NOCOPY 	VARCHAR2,
	p_object2_value	IN OUT NOCOPY 	VARCHAR2,
	p_party_name 	OUT NOCOPY 	VARCHAR2,
	p_party_id 	OUT NOCOPY 	NUMBER) is

  cursor getPartyName (p_PartyID NUMBER) is
  	select party_name
  	from hz_parties
  	where party_id = p_PartyID;

begin
  p_party_id := G_NO_PARTY;
  p_party_name := null;

  if p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_ANI then
	p_party_id := getPartyfromANI(p_object_value);
  --elsif p_object_type = 'DNIS' then
	--p_party_id := getPartyfromDNIS(p_object_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_PARTY_NUMBER then
	p_party_id := getPartyfromPartyNum(p_object_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_QUOTE_NUMBER then
	p_party_id := getPartyfromQuoteNum(p_object_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_ORDER_NUMBER then
	p_party_id := getPartyfromOrderNum(p_object_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_COLLATERAL_REQUEST_NUMBER then
	p_party_id := getPartyfromCollRequest(p_object_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_ACCOUNT_NUMBER then
	p_party_id := getPartyfromAccountNum(p_object_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_EVENT_REGISTRATION_CODE then
	p_party_id := getPartyfromEvRegCode(p_object_value);
  --elsif p_object_type = 'SOURCE_CODE' then
	--p_party_id := getPartyfromSourceCode(p_object_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_MARKETING_PIN then
	p_party_id := getPartyfromMPin(p_object_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_CONTRACT_NUMBER then
	p_party_id := getPartyfromContractNum(p_object_value, p_object2_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_KEY then
	p_party_id := getPartyfromServiceKey(p_object_value);
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_REQUEST_NUMBER then
	p_party_id := getPartyfromSRNum(p_object_value);
  -- kmahajan - 08/29/2002 - added for update in bug 2540033
  elsif p_object_type = CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID then
	p_party_id := getPartyfromPartyID(p_object_value);
  else
	null;
  end if;

  if p_party_id in (G_NO_PARTY, G_MULTIPLE_PARTY) then
	p_party_name := null;
  else
  	open getPartyName(p_party_id);
  	fetch getPartyName into p_party_name;
  	close getPartyName;
  end if;

end getPartyForObject;

END AST_ROUTING_PUB;

/
