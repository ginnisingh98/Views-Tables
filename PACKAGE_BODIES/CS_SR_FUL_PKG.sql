--------------------------------------------------------
--  DDL for Package Body CS_SR_FUL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_FUL_PKG" AS
/* $Header: csvsrflb.pls 120.3.12000000.2 2007/07/16 10:09:50 vpremach ship $ */
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CS_SR_FUL_PKG';

PROCEDURE SR_SINGLE_REQUEST(P_API_VERSION  in NUMBER,
					P_INCIDENT_ID in NUMBER,
					P_INCIDENT_NUMBER in VARCHAR2 ,
					P_USER_ID in NUMBER,
					P_EMAIL in VARCHAR2,
					P_SUBJECT in VARCHAR2,		--bug 4527968 prayadur
					P_FAX in VARCHAR2,
					X_RETURN_STATUS out NOCOPY VARCHAR2,
					X_MSG_COUNT out NOCOPY number,
					X_MSG_DATA  out NOCOPY varchar2)  IS

l_api_version				   NUMBER := 1.0;
l_api_name			        CONSTANT VARCHAR2(30) := 'SR_SINGLE_REQUEST';
l_commit					   VARCHAR2(5) := FND_API.G_TRUE;
--

l_content_id				   VARCHAR2(30);
fulfillment_user_note		   VARCHAR2(2000);
l_bind_var 				   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
l_bind_var_type 			   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
l_bind_val 				   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ;
--
l_template_id 				   NUMBER;
l_party_id				   NUMBER;
l_party_name				   VARCHAR2(100);
l_party_name_tag			   VARCHAR2(100);
l_user_id					   NUMBER;
l_server_id				   NUMBER;
l_request_id				   NUMBER;
l_subject					   VARCHAR2(100);
--
l_msg_count 				   NUMBER;
l_msg_data 				   VARCHAR2(5000);
l_return_status 			   VARCHAR2(1000);
--l_content_xml 				   VARCHAR(30000);
-- To conform w/ out parameter of Get_content_XML()
-- Fix for bug 3251623.  prayadur 02/25/04.
l_content_xml 				   VARCHAR(32767);
l_content_nm				   VARCHAR2(100);
l_email					   VARCHAR2(200);
l_printer					   VARCHAR2(100);
l_fax					   VARCHAR2(100);

-- Fix for bug 3251623.  prayadur 02/25/04.
l_media_type				   VARCHAR2(100);
l_request_type				   VARCHAR2(50);
l_document_type				   VARCHAR2(50);

--- SR fields --

l_incident_id				   NUMBER(15);
l_mfg_org_id				   number;
l_doc_type				   varchar2(30) := 'SR';

l_status_code				   varchar2(30);
l_incident_type	             varchar2(30);
l_severity				   varchar2(30);
l_urgency					   varchar2(30);
l_owner					   varchar2(240);
l_company_name				   varchar2(255);
l_account_number			   varchar2(30);

--l_customer_ticket_number		   number;
-- To solve bug no. 2189108. l_customer_ticket_number changed from
-- number to varchar2. Added by pnkalari on 01/18/02.
l_customer_ticket_number                   varchar2(50);

l_person_first_name			   varchar2(150);
l_person_last_name			   varchar2(150);
l_date_opened				   varchar2(15);
l_date_closed				   varchar2(15);
l_product_name				   varchar2(40);
l_product_description		   varchar2(240);
l_summary					   varchar2(240);
l_system_name				   varchar2(50);

l_customer_id			        number(15);
l_serial_number			   varchar2(30);
l_platform_name		        varchar2(30) := null;
l_platform_id				   number;
l_platform_version			   varchar2(30) := null;
l_platform_version_id		   number;

l_component_id				   number;
l_component_name			   varchar2(40);
l_component_description	        varchar2(240);
l_component_version			   varchar2(15);
l_subcomponent_id			   number;
l_subcomponent_name		  	   varchar2(40);
l_subcomponent_description       varchar2(240);
l_subcomponent_version		   varchar2(15);

l_problem_code				   varchar2(50);
l_resolution_code		        varchar2(50);
l_problem_meaning			   varchar2(80);
l_resolution_meaning		   varchar2(80);

l_inv_component_id      		   number;
l_inv_component_version		   varchar2(3);
l_inv_subcomponent_id		   number;
l_inv_subcomponent_version	   varchar2(3);

l_customer_product_id		   number(15);
l_inventory_item_id			   number(15);
l_current_serial_number		   varchar2(30);

l_note_type			   varchar2(30);

-- Installed Base 11.5.6 Upgrade enhancement# 1875922. 08/07/01 rmanabat
ib_version VARCHAR2(25) := csi_utility_grp.ib_version ;

--declare cursors here

CURSOR inc_v_csr is
select problem_code,resolution_code,customer_product_id,inv_organization_id,
cp_component_id,cp_subcomponent_id,inventory_item_id,inv_component_id,
inv_component_version,inv_subcomponent_id,inv_subcomponent_version,
current_serial_number_nv,platform_id,platform_version_id,
status_code,incident_type,severity,urgency,owner,
company_name,account,customer_id,
customer_ticket_number,person_first_name, person_last_name,
incident_date,date_closed,
product_name,product_description,summary
from cs_incidents_v
where incident_id = l_incident_id;

-- Enhancement 2188129. Replacing view cs_new_incidents_v with cs_sr_incidents_v
-- Added by pnkalari on 02/07/2002.
-- Added cursors cs_owner_csr,cs_account_csr,cs_person_name_csr,cs_product_csr.
-- ===============================================================================================

CURSOR inc_v_csr_1156 is
SELECT	problem_code,
	resolution_code,
	customer_product_id,
	inv_organization_id,
	cp_component_id,
	cp_subcomponent_id,
	inventory_item_id,
	inv_component_id,
	inv_component_version,
	inv_subcomponent_id,
	inv_subcomponent_version,
	current_serial_number_nv,
	platform_id,
	platform_version_id,
	status_code,
	incident_type,
	severity,
	urgency,
	customer_id,
	customer_ticket_number,
	incident_date,
	date_closed,
	SUMMARY
FROM
	CS_SR_INCIDENTS_V
WHERE
	incident_id = l_incident_id;

CURSOR cs_owner_csr is
SELECT a.resource_name from cs_sr_owners_v a, cs_sr_incidents_v b
       where a.resource_id = b.incident_owner_id
       and b.incident_id = l_incident_id;

CURSOR cs_account_csr is
SELECT a.account_number from jtf_cust_accounts_all_v a, cs_sr_incidents_v b
       where b.account_id = a.cust_account_id
       and b.incident_id = l_incident_id;

CURSOR cs_person_name_csr is
SELECT a.sub_first_name, a.sub_last_name from csc_hz_parties_self_v a, cs_hz_sr_contact_points b,
       cs_sr_incidents_v c
       where b.incident_id = c.incident_id
       and b.party_id = a.party_id
       and b.primary_flag = 'Y'
       and c.incident_id = l_incident_id ;

CURSOR cs_product_csr is
SELECT a.concatenated_segments, a.description from mtl_system_items_kfv a, cs_sr_incidents_v b
       where a.inventory_item_id = b.inventory_item_id
       and a.organization_id = CS_STD.Get_Item_Valdn_Orgzn_Id
       and b.incident_id = l_incident_id;

-- ===============================================================================================


/*
CURSOR inc_v_csr_1156 is
SELECT	problem_code,
	resolution_code,
	customer_product_id,
	inv_organization_id,
	cp_component_id,
	cp_subcomponent_id,
	inventory_item_id,
	inv_component_id,
	inv_component_version,
	inv_subcomponent_id,
	inv_subcomponent_version,
	current_serial_number_nv,
	platform_id,
	platform_version_id,
	status_code,
	incident_type,
	severity,
	urgency,
	owner,
	company_name,
	account,
	customer_id,
	customer_ticket_number,
	person_first_name,
	person_last_name,
	incident_date,
	date_closed,
	PRODUCT_NAME,
	PRODUCT_DESCRIPTION,
	SUMMARY
FROM
	CS_NEW_INCIDENTS_V
WHERE
	incident_id = l_incident_id;
*/


CURSOR jtf_party_csr is
   select party_name
   from jtf_parties_all_v
   where party_id = l_customer_id;


CURSOR cs_lookup_prob_csr is
	select meaning
	from cs_lookups
	where lookup_type = 'REQUEST_PROBLEM_CODE'
	and lookup_code = l_problem_code;

CURSOR cs_lookup_res_csr is
	select meaning
	from cs_lookups
	where lookup_type = 'REQUEST_RESOLUTION_CODE'
	and lookup_code = l_resolution_code;

CURSOR cs_acc_ser_csr is
  select current_serial_number, system_name, platform,version
   from cs_acc_cp_rg_v
   where customer_product_id = l_customer_product_id;

-- Installed Base 11.5.6 Upgrade enhancement# 1875922. 08/07/01 rmanabat.
CURSOR cs_acc_ser_csr_1156 is
  select serial_number, system_name, platform,version
   from cs_sr_new_acc_cp_rg_v
   where instance_id = l_customer_product_id;

CURSOR cs_acc_prod_csr is
    select product_name,substr(product_description,1,15),revision
    from cs_acc_cp_rg_v
    where config_parent_id = l_customer_product_id and
		customer_product_id = l_component_id;

-- Installed Base 11.5.6 Upgrade enhancement# 1875922. 08/07/01 rmanabat.
CURSOR cs_acc_prod_csr_1156 is
    select product_name,substr(product_description,1,15),inventory_revision
    from cs_sr_new_acc_cp_rg_v
    where object_id = l_customer_product_id and
		instance_id = l_component_id;

CURSOR cs_acc_sub_csr is
    select product_name,product_description,revision
    from cs_acc_cp_rg_v
    where config_parent_id = l_component_id and
		customer_product_id = l_subcomponent_id;

-- Installed Base 11.5.6 Upgrade enhancement# 1875922. 08/07/01 rmanabat.
CURSOR cs_acc_sub_csr_1156 is
    select product_name,product_description,inventory_revision
    from cs_sr_new_acc_cp_rg_v
    where object_id = l_component_id and
		instance_id = l_subcomponent_id;

--  nov/06/2000 commented out temporarily as defects is not ready as yet
--platform name and version will be null until defects is ready
-- uncomment all css reference when required
/*
CURSOR css_plat_csr is
     select name
     from css_def_platforms
     where platform_id = l_platform_id;

CURSOR css_vers_csr is
		select version
   		from css_def_plat_versions
   		where platform_version_id = l_platform_version_id;
*/

-- Modification of below cursor to include version for Bug 3592225.Prayadur.
CURSOR cs_inv_comp_csr is
	   select concatenated_segments, sr_comp.description,revision
	   from cs_sr_inv_components_v sr_comp, mtl_item_revisions rev
	   where
		sr_comp.component_id = rev.inventory_item_id         and
		sr_comp.organization_id = rev.organization_id        and
                sr_comp.inventory_item_id = l_inventory_item_id      and
		sr_comp.organization_id = l_mfg_org_id               and
		sr_comp.component_id = l_inv_component_id;

-- Modification of below cursor to include version for Bug 3592225.Prayadur.
CURSOR cs_inv_subcomp_csr is
	   select concatenated_segments, sr_sub.description,revision
	   from cs_sr_inv_subcomponents_v sr_sub, mtl_item_revisions rev
	   where
		sr_sub.component_id = rev.inventory_item_id          and
		sr_sub.organization_id = rev.organization_id         and
	        sr_sub.component_id = l_inv_component_id             and
		sr_sub.organization_id = l_mfg_org_id                and
		sr_sub.subcomponent_id = l_inv_subcomponent_id;


-- commented inc_log_csr cursor and added inc_notes_cursor for Enhancement 2248691.
-- Will pass notes instead of log for agents comments.
/*CURSOR inc_log_csr is
select substr(cs_sr_log_pkg.sr_log(p_incident_id),1,27000) log from dual; */

CURSOR inc_notes_csr is
       select notes from jtf_notes_vl
       where source_object_id = p_incident_id and
       note_type = l_note_type and
       jtf_note_id = (select max(jtf_note_id) from jtf_notes_vl
                     where source_object_id = p_incident_id
                     and note_type = l_note_type);

-- Bug fix for 2428307. Added cursor by pnkalari on 07/01/2002.

CURSOR cs_platform_csr is
       select incident.platform_version,item.concatenated_segments platform
       from mtl_system_items_vl item,
            mtl_item_categories ic,
            cs_sr_incidents_v incident
       where item.organization_id = fnd_profile.value('CS_INV_VALIDATION_ORG')
         and item.serv_req_enabled_code = 'E'
         and item.organization_id = ic.organization_id
         and item.inventory_item_id = ic.inventory_item_id
         and ic.category_set_id = fnd_profile.value('CS_SR_PLATFORM_CATEGORY_SET')
         and item.inventory_item_id = incident.platform_id
         and item.inventory_item_id = l_platform_id
         and incident.incident_id = l_incident_id ;

BEGIN
fnd_msg_pub.initialize;

/* get all fields for SR */

l_incident_id := p_incident_id;

/*
IF (ib_version = '1150') THEN
  OPEN inc_v_csr;
  FETCH inc_v_csr into
  l_problem_code,l_resolution_code,l_customer_product_id,l_mfg_org_id,
  l_component_id,l_subcomponent_id,l_inventory_item_id,l_inv_component_id,
  l_inv_component_version,l_inv_subcomponent_id,l_inv_subcomponent_version,
  l_current_serial_number,l_platform_id,l_platform_version_id,
  l_status_code,l_incident_type,l_severity,l_urgency,l_owner,
  l_company_name,l_account_number,l_customer_id,
  l_customer_ticket_number,l_person_first_name,l_person_last_name,
  l_date_opened,l_date_closed,
  l_product_name,l_product_description,l_summary;

  if (inc_v_csr%notfound) then
     null;
  end if;
  CLOSE inc_v_csr;
ELSE
  OPEN inc_v_csr_1156;
  FETCH inc_v_csr_1156 into
  l_problem_code,l_resolution_code,l_customer_product_id,l_mfg_org_id,
  l_component_id,l_subcomponent_id,l_inventory_item_id,l_inv_component_id,
  l_inv_component_version,l_inv_subcomponent_id,l_inv_subcomponent_version,
  l_current_serial_number,l_platform_id,l_platform_version_id,
  l_status_code,l_incident_type,l_severity,l_urgency,l_owner,
  l_company_name,l_account_number,l_customer_id,
  l_customer_ticket_number,l_person_first_name,l_person_last_name,
  l_date_opened,l_date_closed,
  l_product_name,l_product_description,l_summary;

  if (inc_v_csr_1156%notfound) then
     null;
  end if;
  CLOSE inc_v_csr_1156;
END IF;
*/

  OPEN inc_v_csr_1156;
  FETCH inc_v_csr_1156 into
  l_problem_code,l_resolution_code,l_customer_product_id,l_mfg_org_id,
  l_component_id,l_subcomponent_id,l_inventory_item_id,l_inv_component_id,
  l_inv_component_version,l_inv_subcomponent_id,l_inv_subcomponent_version,
  l_current_serial_number,l_platform_id,l_platform_version_id,
  l_status_code,l_incident_type,l_severity,l_urgency,
  l_customer_id,
  l_customer_ticket_number,
  l_date_opened,l_date_closed,
  l_summary;

  if (inc_v_csr_1156%notfound) then
     null;
  end if;
  CLOSE inc_v_csr_1156;

-- Bug fix for 2208493. Added by pnkalari. Put fetch cursor in begin end block to trap value_error exception.
-- Added on 01/31/02

BEGIN
-- replace inc_log_csr cursor with inc_notes_csr for Enhancement 2248691.
/*OPEN inc_log_csr ;
FETCH inc_log_csr into fulfillment_user_note;
if (inc_log_csr%notfound) then
   null;
end if;
CLOSE inc_log_csr; */

FND_PROFILE.GET('CS_SR_DEFAULT_AGENT_COMMENTS',l_note_type);
if (l_note_type is not null) then
  OPEN inc_notes_csr ;
  FETCH inc_notes_csr into fulfillment_user_note ;
   if(inc_notes_csr%notfound) then
     fulfillment_user_note := null ;
   end if ;
else
   fulfillment_user_note := null ;
end if;

EXCEPTION
 WHEN VALUE_ERROR THEN
   fulfillment_user_note := substr(fulfillment_user_note,1,2000);

END;
-- select party id and party name

l_party_id := l_customer_id;

-- ============================================================================

  OPEN cs_owner_csr ;
  FETCH cs_owner_csr into l_owner ;
  if(cs_owner_csr%notfound) then
    null ;
  end if ;
  CLOSE cs_owner_csr;

  OPEN cs_account_csr;
  FETCH cs_account_csr into l_account_number ;
  if(cs_account_csr%notfound) then
   null ;
  end if ;
  CLOSE cs_account_csr;

  OPEN cs_person_name_csr ;
  FETCH cs_person_name_csr into l_person_first_name,l_person_last_name ;
  if(cs_person_name_csr%notfound) then
   null ;
  end if ;
  CLOSE cs_person_name_csr;

  OPEN cs_product_csr ;
  FETCH cs_product_csr into l_product_name, l_product_description ;
  if(cs_product_csr%notfound) then
   null ;
  end if ;
  CLOSE cs_product_csr;

if l_customer_id is not null then
   OPEN jtf_party_csr;
   FETCH jtf_party_csr into l_company_name ;
   if(jtf_party_csr%notfound) then
    null;
   end if;
   CLOSE jtf_party_csr ;
end if ;

-- ============================================================================
if l_customer_id is not null then
    OPEN jtf_party_csr;
    FETCH jtf_party_csr into l_party_name;
    if (jtf_party_csr%notfound) then
        null;
    end if;

    CLOSE jtf_party_csr;
end if;


if l_problem_code is not null then
    OPEN cs_lookup_prob_csr;
    FETCH cs_lookup_prob_csr into
	     l_problem_meaning;
    if (cs_lookup_prob_csr%notfound) then
        null;
    end if;
    CLOSE cs_lookup_prob_csr;

end if;

if l_resolution_code is not null then
    OPEN cs_lookup_res_csr;
    FETCH cs_lookup_res_csr into
	     l_resolution_meaning;
    if (cs_lookup_res_csr%notfound) then
        null;
    end if;
    CLOSE cs_lookup_res_csr;
end if;


if l_customer_product_id is not null then
-- item is an installed base item
-- get items from installed base view

/*    IF (ib_version = '1150') THEN
      OPEN cs_acc_ser_csr;
      FETCH cs_acc_ser_csr into
         l_current_serial_number,l_system_name,l_platform_name,l_platform_version;
        if (cs_acc_ser_csr%notfound) then
          null;
        end if;
      CLOSE cs_acc_ser_csr;
    ELSE */

      OPEN cs_acc_ser_csr_1156;
      FETCH cs_acc_ser_csr_1156 into
         l_current_serial_number,l_system_name,l_platform_name,l_platform_version;
        if (cs_acc_ser_csr_1156%notfound) then
          null;
        end if;
      CLOSE cs_acc_ser_csr_1156;
--     END IF;

   if l_component_id is not null then

/*    IF (ib_version = '1150') THEN
      OPEN cs_acc_prod_csr;
      FETCH cs_acc_prod_csr into
  	       l_component_name,l_component_description,l_component_version;
        if (cs_acc_prod_csr%notfound) then
          null;
        end if;
      CLOSE cs_acc_prod_csr;
    ELSE */
      OPEN cs_acc_prod_csr_1156;
      FETCH cs_acc_prod_csr_1156 into
  	       l_component_name,l_component_description,l_component_version;
        if (cs_acc_prod_csr_1156%notfound) then
          null;
        end if;
      CLOSE cs_acc_prod_csr_1156;
--    END IF;

   end if;

   if l_subcomponent_id is not null then

 /*   IF (ib_version = '1150') THEN
      OPEN cs_acc_sub_csr;
      FETCH cs_acc_sub_csr into
	  l_subcomponent_name,l_subcomponent_description,l_subcomponent_version ;
        if (cs_acc_sub_csr%notfound) then
          null;
        end if;
      CLOSE cs_acc_sub_csr;
    ELSE */
      OPEN cs_acc_sub_csr_1156;
      FETCH cs_acc_sub_csr_1156 into
	  l_subcomponent_name,l_subcomponent_description,l_subcomponent_version ;
        if (cs_acc_sub_csr_1156%notfound) then
          null;
        end if;
      CLOSE cs_acc_sub_csr_1156;
--    END IF;

   end if;

else

-- item is not an installed base item
-- get items from inventory and platform details from defect tables

-- Nov/6/2000 defects not ready therefore comment out all reference
--to css tables temporarily

/*     if l_platform_id is not null then
    	  OPEN css_plat_csr;
       FETCH css_plat_csr into
   		 l_platform_name;
        if (css_plat_csr%notfound) then
          null;
        end if;
       CLOSE css_plat_csr;
     end if;

	if l_platform_version_id is not null then
    	  OPEN css_vers_csr;
       FETCH css_vers_csr into
		  l_platform_version;
        if (css_vers_csr%notfound) then
          null;
        end if;
       CLOSE css_vers_csr;
	end if;
*/

-- Added l_component_version in fetch caluse for Bug 3592225.Prayadur.
	if l_inv_component_id is not null then
    	  OPEN cs_inv_comp_csr;
       FETCH cs_inv_comp_csr into
      	   l_component_name,l_component_description,l_component_version;
        if (cs_inv_comp_csr%notfound) then
          null;
        end if;
       CLOSE cs_inv_comp_csr;
	end if;

-- Added l_subcomponent_version in fetch caluse for Bug 3592225.Prayadur.
	if l_inv_subcomponent_id is not null then
    	  OPEN cs_inv_subcomp_csr;
       FETCH cs_inv_subcomp_csr into
      	   l_subcomponent_name,l_subcomponent_description,l_subcomponent_version;
        if (cs_inv_subcomp_csr%notfound) then
          null;
        end if;
       CLOSE cs_inv_subcomp_csr;

     end if;

end if;
-----
OPEN cs_platform_csr ;
 FETCH cs_platform_csr into
       l_platform_version,l_platform_name ;
  if(cs_platform_csr%notfound) then
     null ;
  end if;
 CLOSE cs_platform_csr ;

--initialize return status to success before call to
x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Start the fulfillment request. The output request_id must be passed
	-- to all subsequent calls made for this request.
	JTF_FM_REQUEST_GRP.STart_Request
	(
 					p_api_version => l_api_version,
					x_return_status => l_return_status,
					x_msg_count => l_msg_count,
					x_msg_data => l_msg_data,
					x_request_id => l_request_id
	);

-- test for failure

    --if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    -- 11/10/03. rmanabat . Should check for l_return_status, not x_return_status.
    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      --DBMS_OUTPUT.PUT_LINE('fail');
      raise FND_API.G_EXC_UNEXPECTED_ERROR  ;
    end if;

--DBMS_OUTPUT.PUT_LINE('Request_ID: '||to_char(l_request_id));

	-- store the destination addresses into local variables
     l_email := P_EMAIL;
     l_fax   := P_FAX;

-- Fix for bug 3251623.  prayadur 02/25/04
     --l_media_type := 'EMAIL,FAX';
     --Setting dynamically
     IF (P_EMAIL is not null) THEN
       l_media_type := 'EMAIL';
     ELSIF (P_FAX is not null) THEN
       l_media_type := 'FAX';
     END IF;

--	test content id l_content_id := '13065';

-- content_id is hardcoded to 1000 , which is the seed value for item_id
--The content_id  is seeded in seed115 ( file has to be uploaded into FND_LOBS
-- and seeded into jtf_amv_attachments and jtf_amv_items.This is done thru
-- ldt scripts owned by marketing; item_id = content_id = 1000 )

l_content_id := 1000;

	-- assign bind varibles
	-- The replace_tag function is used b'cos certain characters
	-- are not accepted by fulfillment eg. &, <,> and '

	l_bind_var(1) := 'REQUEST_NUMBER';
	l_bind_var_type(1) := 'VARCHAR2';
	l_bind_val(1) := jtf_fm_request_grp.replace_tag(p_incident_number);

	l_bind_var(2) := 'STATUS';
	l_bind_var_type(2) := 'VARCHAR2';
	l_bind_val(2) := jtf_fm_request_grp.replace_tag(l_status_code);

	l_bind_var(3) := 'REQUEST_TYPE';
	l_bind_var_type(3) := 'VARCHAR2';
	l_bind_val(3) := jtf_fm_request_grp.replace_tag(l_incident_type);

	l_bind_var(4) := 'SEVERITY';
	l_bind_var_type(4) := 'VARCHAR2';
	l_bind_val(4) := jtf_fm_request_grp.replace_tag(l_severity);

	l_bind_var(5) := 'URGENCY';
	l_bind_var_type(5) := 'VARCHAR2';
	l_bind_val(5) := jtf_fm_request_grp.replace_tag(l_urgency);

	l_bind_var(6) := 'OWNER';
	l_bind_var_type(6) := 'VARCHAR2';
	l_bind_val(6) := jtf_fm_request_grp.replace_tag(l_owner);

	l_bind_var(7) := 'COMPANY';
	l_bind_var_type(7) := 'VARCHAR2';
	l_bind_val(7) := jtf_fm_request_grp.replace_tag(l_company_name);

	l_bind_var(8) := 'ACCOUNT';
	l_bind_var_type(8) := 'VARCHAR2';
     l_bind_val(8) := jtf_fm_request_grp.replace_tag(l_account_number);

	l_bind_var(9) := 'HELPDESK_NUMBER';
	l_bind_var_type(9) := 'VARCHAR2';
	l_bind_val(9) := jtf_fm_request_grp.replace_tag(l_customer_ticket_number);

	l_bind_var(10) := 'FIRST_NAME';
	l_bind_var_type(10) := 'VARCHAR2';
	l_bind_val(10) := jtf_fm_request_grp.replace_tag(l_person_first_name);

	l_bind_var(11) := 'LAST_NAME';
	l_bind_var_type(11) := 'VARCHAR2';
	l_bind_val(11) := jtf_fm_request_grp.replace_tag(l_person_last_name);

	l_bind_var(12) := 'DATE_OPENED';
	l_bind_var_type(12) := 'VARCHAR2';
	l_bind_val(12) := jtf_fm_request_grp.replace_tag(l_date_opened);

	l_bind_var(13) := 'DATE_CLOSED';
	l_bind_var_type(13) := 'VARCHAR2';
	l_bind_val(13) := jtf_fm_request_grp.replace_tag(l_date_closed);

	l_bind_var(14) := 'PRODUCT_NAME';
	l_bind_var_type(14) := 'VARCHAR2';
	l_bind_val(14) := jtf_fm_request_grp.replace_tag(l_product_name);

	l_bind_var(15) := 'PRODUCT_DESCRIPTION';
	l_bind_var_type(15) := 'VARCHAR2';
	l_bind_val(15) := jtf_fm_request_grp.replace_tag(l_product_description);

	l_bind_var(16) := 'REQUEST_SUMMARY';
	l_bind_var_type(16) := 'VARCHAR2';
	l_bind_val(16) := jtf_fm_request_grp.replace_tag(l_summary);

	l_bind_var(17) := 'PROBLEM_MEANING';
	l_bind_var_type(17) := 'VARCHAR2';
	l_bind_val(17) := jtf_fm_request_grp.replace_tag(l_problem_meaning);

	l_bind_var(18) := 'RESOLUTION_MEANING';
	l_bind_var_type(18) := 'VARCHAR2';
     l_bind_val(18) := jtf_fm_request_grp.replace_tag(l_resolution_meaning);

	l_bind_var(19) := 'SYSTEM_NAME';
	l_bind_var_type(19) := 'VARCHAR2';
	l_bind_val(19) := jtf_fm_request_grp.replace_tag(l_system_name);

	l_bind_var(20) := 'SERIAL_NUMBER';
	l_bind_var_type(20) := 'VARCHAR2';
	l_bind_val(20) := jtf_fm_request_grp.replace_tag(l_current_serial_number);

	l_bind_var(21) := 'PLATFORM_NAME';
	l_bind_var_type(21) := 'VARCHAR2';
	l_bind_val(21) := jtf_fm_request_grp.replace_tag(l_platform_name);

	l_bind_var(22) := 'PLATFORM_VERSION';
	l_bind_var_type(22) := 'VARCHAR2';
	l_bind_val(22) := jtf_fm_request_grp.replace_tag(l_platform_version);

	l_bind_var(23) := 'COMPONENT_NAME';
	l_bind_var_type(23) := 'VARCHAR2';
	l_bind_val(23) := jtf_fm_request_grp.replace_tag(l_component_name);

	l_bind_var(24) := 'COMPONENT_DESCRIPTION';
	l_bind_var_type(24) := 'VARCHAR2';
	l_bind_val(24) := jtf_fm_request_grp.replace_tag(l_component_description);

	l_bind_var(25) := 'COMPONENT_VERSION';
	l_bind_var_type(25) := 'VARCHAR2';
	l_bind_val(25) := jtf_fm_request_grp.replace_tag(l_component_version);

	l_bind_var(26) := 'SUBCOMPONENT_NAME';
	l_bind_var_type(26) := 'VARCHAR2';
	l_bind_val(26) := jtf_fm_request_grp.replace_tag(l_subcomponent_name);

	l_bind_var(27) := 'SUBCOMPONENT_DESCRIPTION';
	l_bind_var_type(27) := 'VARCHAR2';
	l_bind_val(27) := jtf_fm_request_grp.replace_tag(l_subcomponent_description);

	l_bind_var(28) := 'SUBCOMPONENT_VERSION';
	l_bind_var_type(28) := 'VARCHAR2';
	l_bind_val(28) := jtf_fm_request_grp.replace_tag(l_subcomponent_version);

	-- Fix for bug 3251623 . prayadur . 02/25/04
    -- Commented out. XML content should not be manually built
    /***********************************************************************

	-- The XML request for the content is being formed in the code below
    l_content_xml :=    '<item> ';
    l_content_xml := l_content_xml || '<item_destination>';
    l_content_xml := l_content_xml || '<media_type>';

 if p_email is not null then
--  deliver content by email
    l_content_xml := l_content_xml || '<email>'||l_email||'</email>';
 elsif p_fax is not null then
--  deliver content by fax
    l_content_xml := l_content_xml || '<fax>'||l_fax||'</fax>';
 end if;

    l_content_xml := l_content_xml || '</media_type>';
    l_content_xml := l_content_xml || '</item_destination>';
    l_content_xml := l_content_xml || '<item_content content_id="'||l_content_id||'" quantity="1" user_note="'||JTF_FM_REQUEST_GRP.REPLACE_TAG(fulfillment_user_note)||'">';
    l_content_xml := l_content_xml || '<data>';
    l_content_xml := l_content_xml || '<record>';



	FOR i IN 1..l_bind_var.count LOOP
	   l_content_xml := l_content_xml || '<bind_var bind_type="'||l_bind_var_type(i)||'" bind_object="'||l_bind_var(i)||'">'||l_bind_val(i)||'</bind_var>';

	END LOOP;

    l_content_xml := l_content_xml || '</record>';
    l_content_xml := l_content_xml || '</data>';
    l_content_xml := l_content_xml || '</item_content>';
    l_content_xml := l_content_xml || '</item>';

 ***********************************************************************/

	-- Initialize Parameters for submitting the fulfillment request
     l_user_id := p_user_id;

--  default user value (for vision) for testing
--	l_user_id := 1001;

	--l_subject := 'Service Request Details'; --commented this for bug 4527968 prayadur.
	l_subject := P_SUBJECT ;     --Added this for bug 4527968 prayadur.

--initialize return status to success before call to
x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Start of Fix for bug 3251623 . prayadur . 02/25/04
    -- Removed the XML getting created and instead calling GET_CONTENT_XML
    l_request_type := 'DATA' ; -- 'Query' if Query is attached to your document, else DATA
    l_document_type := 'html';  -- Master Documents are usually htm or html files

    JTF_FM_REQUEST_GRP.Get_Content_XML
		(
		 p_api_version => l_api_version,
		 x_return_status => l_return_status,
		 x_msg_count => l_msg_count,
		 x_msg_data => l_msg_data,
		 p_content_id => 1000,
		 --p_content_nm => l_content_nm,
		 p_content_nm => FND_API.G_MISS_CHAR, -- using default value.
		 p_document_type => l_document_type,
		 /**** source code says this is deprecated, but using html as stated in bug.
		 p_document_type => FND_API.G_MISS_CHAR,
		 *****/
		 p_media_type => l_media_type,
		 p_printer => null,
		 p_email => l_email,
		 p_file_path => null,
		 p_fax => l_fax,
		 p_user_note => fulfillment_user_note,
		 p_content_type => l_request_type,
		 p_bind_var => l_bind_var,
		 p_bind_val => l_bind_val,
		 p_bind_var_type => l_bind_var_type,
		 p_request_id => l_request_id,
		 x_content_xml => l_content_xml);

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      --DBMS_OUTPUT.PUT_LINE('fail');
      raise FND_API.G_EXC_UNEXPECTED_ERROR  ;
    end if;

    -- End of fix for bug 3251623.

	-- Submit the fulfillment request
    JTF_FM_REQUEST_GRP.Submit_Request
    ( 	  			p_api_version => l_api_version,
					p_commit => l_commit,
					x_return_status => l_return_status,
					x_msg_count => l_msg_count,
					x_msg_data => l_msg_data,
					p_subject => l_subject,
					p_party_id => l_party_id,
					p_party_name => l_party_name,
					p_doc_id  => l_incident_id,
					p_doc_ref => l_doc_type,
					p_user_id => l_user_id,
	  				p_content_xml => l_content_xml,
	  				p_request_id => l_request_id
    );


    --DBMS_OUTPUT.PUT_LINE('Return Status: '||l_return_status);
    --DBMS_OUTPUT.PUT_LINE('Message_Count: '||l_msg_count);
    --DBMS_OUTPUT.PUT_LINE('Message Data: '||l_msg_data);

-- this is for testing failure
-- x_return_status := 'F';

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
	  raise FND_API.G_EXC_UNEXPECTED_ERROR  ;
    else
    -- if successful then display request id to user
	FND_MESSAGE.Set_Name('CS','CS_SR_FULFIL_REQUEST');
	FND_MESSAGE.Set_Token('REQUEST_ID',l_request_id);
	FND_MSG_PUB.Add;
    end if;

	FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END SR_SINGLE_REQUEST;

PROCEDURE SR_RESUBMIT_REQUEST(P_API_VERSION  in NUMBER,
					P_REQUEST_ID in NUMBER,
					X_RETURN_STATUS out NOCOPY VARCHAR2,
					X_MSG_COUNT out NOCOPY number,
					X_MSG_DATA  out NOCOPY varchar2) IS
--
-- Resubmit does not add any additional value so not being called in 11i.1
-- Button on form has been disabled

-- This procedure resubmits an already submitted request and should
-- not be used to resubmit a error free request
-- If the original request had errored then it will error again
-- User should correct error and submit new request instead
-- of resubmitting
--

l_api_version				   NUMBER := 1.0;
l_api_name			        CONSTANT VARCHAR2(30) := 'SR_RESUBMIT_REQUEST';
l_commit					   VARCHAR2(5) := FND_API.G_TRUE;
l_msg_count 				   NUMBER;
l_msg_data 				   VARCHAR2(5000);
l_return_status 			   VARCHAR2(1000);
l_request_id				   NUMBER;

--initialize return status to success before call
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Resubmit the fulfillment request

    JTF_FM_REQUEST_GRP.Resubmit_Request( p_api_version => l_api_version,
					p_commit => l_commit,
					x_return_status => l_return_status,
					x_msg_count => l_msg_count,
					x_msg_data => l_msg_data,
	  				p_request_id => l_request_id
    );

    if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
	  raise FND_API.G_EXC_UNEXPECTED_ERROR  ;
    else
     --if successful then display request id to user
	FND_MESSAGE.Set_Name('CS','CS_SR_FULFIL_REQUEST');
	FND_MESSAGE.Set_Token('REQUEST_ID',l_request_id);
	FND_MSG_PUB.Add;
    end if;

  FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

 EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END SR_RESUBMIT_REQUEST;
END CS_SR_FUL_PKG;

/
