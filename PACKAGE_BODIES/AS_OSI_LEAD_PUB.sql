--------------------------------------------------------
--  DDL for Package Body AS_OSI_LEAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OSI_LEAD_PUB" as
/* $Header: custom_asxposib.pls 115.5.1157.2 2002/02/21 09:11:47 pkm ship      $ */

-- Start of Comments
--
-- NAME
--   AS_OSI_LEAD_PUB
--
-- PURPOSE
--   This package is a public API for inserting OSI enhanced oppy information into
--   OSM. It contains specification for pl/sql records and tables and the
--   Public fetch and update API.
--
--   Procedures:
--      osi_lead_fetch (see below for specification)
--      osi_lead_update (see below for specification)

--
-- NOTES
--   This package is publicly available for use
--
--
--
-- HISTORY
--   12/12/99   JHIBNER                Created
-- End of Comments


PROCEDURE osi_lead_fetch
(   p_api_version_number    IN     NUMBER,
    p_lead_id				in    VARCHAR2,
    p_osi_rec                       out    OSI_REC_TYPE   ,
    p_osi_ovd_tbl                       out    OSI_OVD_TBL_TYPE
) is
  cursor osi_cur (lead_id_in in varchar2) is
    select *
      from as_osi_leads_all
     where lead_id = lead_id_in;
  cursor ovd_cur (lead_id_in in varchar2) is
    select *
      from as_osi_lead_ovl_all
     where osi_lead_id = lead_id_in
     order by ovm_code;
  cursor osi2_cur (lead_id_in in varchar2) is
    select substr(addr.address1||' '||addr.city||','||addr.state,1,50) site_name,
           substr(cust.party_name,1,50) cust_name, substr(oppy.description,1,50) oppy_name
      from as_leads_all oppy
          ,hz_parties cust
          ,as_party_addresses_v addr
     where oppy.lead_id = lead_id_in
       and cust.party_id = oppy.customer_id
       and addr.address_id = oppy.address_id;
  l_osi_rec OSI_REC_TYPE := G_MISS_OSI_REC;
  l_osi_ovd_tbl OSI_OVD_TBL_TYPE;
  ndx binary_integer := 0;
begin
  for osi in osi_cur (p_lead_id) loop
    l_osi_rec.last_updated_by := to_char(osi.last_updated_by);
    l_osi_rec.created_by := to_char(osi.created_by);
    l_osi_rec.last_update_login := to_char(osi.last_update_login);
    l_osi_rec.OSI_LEAD_ID := osi.OSI_LEAD_ID;
    l_osi_rec.LEAD_ID := osi.LEAD_ID;
    l_osi_rec.CVEHICLE := to_char(osi.CVEHICLE);
    l_osi_rec.CNAME_ID := to_char(osi.CNAME_ID);
    l_osi_rec.CONTR_DRAFTING_REQ  := osi.CONTR_DRAFTING_REQ;
    l_osi_rec.PRIORITY := osi.PRIORITY;
    l_osi_rec.SENIOR_CONTR_PERSON_ID := to_char(osi.SENIOR_CONTR_PERSON_ID);
    l_osi_rec.CONTR_SPEC_PERSON_ID := to_char(osi.CONTR_SPEC_PERSON_ID);
    l_osi_rec.BOM_PERSON_ID := to_char(osi.BOM_PERSON_ID);
    l_osi_rec.LEGAL_PERSON_ID := to_char(osi.LEGAL_PERSON_ID);
    l_osi_rec.HIGHEST_APVL := osi.HIGHEST_APVL;
    l_osi_rec.CURRENT_APVL_STATUS := osi.CURRENT_APVL_STATUS;
    l_osi_rec.SUPPORT_APVL := osi.SUPPORT_APVL;
    l_osi_rec.INTERNATIONAL_APVL := osi.INTERNATIONAL_APVL;
    l_osi_rec.CREDIT_APVL := osi.CREDIT_APVL;
    l_osi_rec.FIN_ESCROW_REQ := osi.FIN_ESCROW_REQ;
    l_osi_rec.FIN_ESCROW_STATUS := osi.FIN_ESCROW_STATUS;
    l_osi_rec.CSI_ROLLIN := osi.CSI_ROLLIN;
    l_osi_rec.LICENCE_CREDIT_VER := osi.LICENCE_CREDIT_VER;
    l_osi_rec.SUPPORT_CREDIT_VER := osi.SUPPORT_CREDIT_VER;
    l_osi_rec.MD_DEAL_SUMMARY := osi.MD_DEAL_SUMMARY;
    l_osi_rec.PROD_AVAIL_VER := osi.PROD_AVAIL_VER;
    l_osi_rec.SHIP_LOCATION := osi.SHIP_LOCATION;
    l_osi_rec.TAX_EXEMPT_CERT := osi.TAX_EXEMPT_CERT;
    l_osi_rec.NL_REV_ALLOC_REQ := osi.NL_REV_ALLOC_REQ;
    l_osi_rec.CONSULTING_CC := osi.CONSULTING_CC;
    l_osi_rec.SENIOR_CONTR_NOTES := osi.SENIOR_CONTR_NOTES;
    l_osi_rec.LEGAL_NOTES := osi.LEGAL_NOTES;
    l_osi_rec.BOM_NOTES := osi.BOM_NOTES;
    l_osi_rec.CONTR_NOTES := osi.CONTR_NOTES;
    l_osi_rec.PO_FROM  := osi.PO_FROM;
    l_osi_rec.CONTR_TYPE := osi.CONTR_TYPE;
    l_osi_rec.CONTR_STATUS := osi.CONTR_STATUS;
    l_osi_rec.EXTRA_DOCS := to_char(osi.EXTRA_DOCS);
    exit;
  end loop;
  for ovd in ovd_cur (p_lead_id) loop
    ndx := ndx + 1;
    l_osi_ovd_tbl(ndx).ovd_code := ovd.ovm_code;
    l_osi_ovd_tbl(ndx).ovd_flag := null;
  end loop;
  for osi2 in osi2_cur (p_lead_id) loop
    l_osi_rec.OPPY_NAME := osi2.OPPY_NAME;
    l_osi_rec.CUST_NAME := osi2.CUST_NAME;
    l_osi_rec.SITE_NAME := osi2.SITE_NAME;
    exit;
  end loop;
  if l_osi_rec.lead_id = FND_API.G_MISS_NUM then
    l_osi_rec.last_updated_by := null;
    l_osi_rec.created_by := null;
    l_osi_rec.last_update_login := null;
    l_osi_rec.OSI_LEAD_ID := null;
    l_osi_rec.LEAD_ID := null;
    l_osi_rec.CVEHICLE := null;
    l_osi_rec.CNAME_ID := null;
    l_osi_rec.CONTR_DRAFTING_REQ  := null;
    l_osi_rec.PRIORITY := null;
    l_osi_rec.SENIOR_CONTR_PERSON_ID := null;
    l_osi_rec.CONTR_SPEC_PERSON_ID := null;
    l_osi_rec.BOM_PERSON_ID := null;
    l_osi_rec.LEGAL_PERSON_ID := null;
    l_osi_rec.HIGHEST_APVL := null;
    l_osi_rec.CURRENT_APVL_STATUS := null;
    l_osi_rec.SUPPORT_APVL := null;
    l_osi_rec.INTERNATIONAL_APVL := null;
    l_osi_rec.CREDIT_APVL := null;
    l_osi_rec.FIN_ESCROW_REQ := null;
    l_osi_rec.FIN_ESCROW_STATUS := null;
    l_osi_rec.CSI_ROLLIN := null;
    l_osi_rec.LICENCE_CREDIT_VER := null;
    l_osi_rec.SUPPORT_CREDIT_VER := null;
    l_osi_rec.MD_DEAL_SUMMARY := null;
    l_osi_rec.PROD_AVAIL_VER := null;
    l_osi_rec.SHIP_LOCATION := null;
    l_osi_rec.TAX_EXEMPT_CERT := null;
    l_osi_rec.NL_REV_ALLOC_REQ := null;
    l_osi_rec.CONSULTING_CC := null;
    l_osi_rec.SENIOR_CONTR_NOTES := null;
    l_osi_rec.LEGAL_NOTES := null;
    l_osi_rec.BOM_NOTES := null;
    l_osi_rec.CONTR_NOTES := null;
    l_osi_rec.PO_FROM  := null;
    l_osi_rec.CONTR_TYPE := null;
    l_osi_rec.CONTR_STATUS := null;
    l_osi_rec.EXTRA_DOCS := null;
  end if;
  p_osi_rec := l_osi_rec;
  p_osi_ovd_tbl := l_osi_ovd_tbl;
exception
  when others then
    l_osi_rec.legal_notes:= sqlerrm;
end osi_lead_fetch;
PROCEDURE osi_lead_update
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
    p_osi_rec               IN     OSI_REC_TYPE,
    p_osi_ovd_tbl           IN     OSI_OVD_TBL_TYPE,
    x_return_status         OUT    VARCHAR2,
    x_msg_count             OUT    VARCHAR2,
    x_msg_data              OUT    VARCHAR2
) is
  cursor ovd_cur (lead_id_in in varchar2) is
    select *
      from as_osi_lead_ovl_all
     where osi_lead_id = lead_id_in
     order by ovm_code;
  l_dummy number;
  l_osi_rec OSI_REC_TYPE;
  l_osi_ovd_tbl           OSI_OVD_TBL_TYPE;
  l_delete_flag boolean;
  procedure rgmissc(p_inout in out varchar2) is
  begin
    if p_inout = FND_API.G_MISS_CHAR then
      p_inout := null;
    end if;
  end rgmissc;
  procedure rgmissn(p_inout in out number) is
  begin
    if p_inout = FND_API.G_MISS_NUM then
      p_inout := null;
    end if;
  end rgmissn;
begin
  l_osi_rec := p_osi_rec;
  l_osi_ovd_tbl := p_osi_ovd_tbl;
  rgmissc(l_osi_rec.last_updated_by);
  rgmissc(l_osi_rec.created_by);
  rgmissc(l_osi_rec.CVEHICLE);
  rgmissc(l_osi_rec.CNAME_ID);
  rgmissc(l_osi_rec.PO_FROM);
  rgmissc(l_osi_rec.CONTR_TYPE);
  rgmissc(l_osi_rec.CONTR_DRAFTING_REQ);
  rgmissc(l_osi_rec.PRIORITY);
  rgmissc(l_osi_rec.SENIOR_CONTR_person_ID);
  rgmissc(l_osi_rec.CONTR_SPEC_person_ID);
  rgmissc(l_osi_rec.BOM_person_ID);
  rgmissc(l_osi_rec.LEGAL_person_ID);
  rgmissc(l_osi_rec.HIGHEST_APVL);
  rgmissc(l_osi_rec.CURRENT_APVL_STATUS);
  rgmissc(l_osi_rec.SUPPORT_APVL);
  rgmissc(l_osi_rec.INTERNATIONAL_APVL);
  rgmissc(l_osi_rec.CREDIT_APVL);
  rgmissc(l_osi_rec.FIN_ESCROW_REQ);
  rgmissc(l_osi_rec.FIN_ESCROW_STATUS);
  rgmissc(l_osi_rec.CSI_ROLLIN);
  rgmissc(l_osi_rec.LICENCE_CREDIT_VER);
  rgmissc(l_osi_rec.SUPPORT_CREDIT_VER);
  rgmissc(l_osi_rec.MD_DEAL_SUMMARY);
  rgmissc(l_osi_rec.PROD_AVAIL_VER);
  rgmissc(l_osi_rec.SHIP_LOCATION);
  rgmissc(l_osi_rec.TAX_EXEMPT_CERT);
  rgmissc(l_osi_rec.NL_REV_ALLOC_REQ);
  rgmissc(l_osi_rec.CONSULTING_CC);
  rgmissc(l_osi_rec.SENIOR_CONTR_NOTES);
  rgmissc(l_osi_rec.LEGAL_NOTES);
  rgmissc(l_osi_rec.BOM_NOTES);
  rgmissc(l_osi_rec.CONTR_NOTES);
  rgmissc(l_osi_rec.CONTR_STATUS);
  rgmissc(l_osi_rec.EXTRA_DOCS);
--      dbms_output.put_line('{{'||l_osi_ovd_tbl.count||'}}');
  if l_osi_ovd_tbl.count > 0 then
    for i in 1..l_osi_ovd_tbl.count loop
      rgmissc(l_osi_ovd_tbl(i).ovd_flag);
      rgmissc(l_osi_ovd_tbl(i).ovd_code);
--      l_osi_rec.CONTR_NOTES := l_osi_rec.CONTR_NOTES || '{'||i||','||l_osi_ovd_tbl(i).ovd_flag||','||l_osi_ovd_tbl(i).ovd_code||'}';
--      dbms_output.put_line('{'||i||'/'||l_osi_ovd_tbl.count||','||l_osi_ovd_tbl(i).ovd_flag||','||l_osi_ovd_tbl(i).ovd_code||'}');
      if nvl(upper(l_osi_ovd_tbl(i).ovd_flag),'Y') = 'Y' then
        l_osi_ovd_tbl(i).ovd_flag := 'Y';
      else
        l_osi_ovd_tbl(i).ovd_flag := 'N';
      end if;
    end loop;
  end if;
 begin
  select osi_lead_id
    into l_dummy
    from as_osi_leads_all
   where osi_lead_id = p_osi_rec.lead_id;
  update as_osi_leads_all
     set
     last_update_date = sysdate
    ,last_updated_by = nvl(to_number(l_osi_rec.last_updated_by),1)
    ,OSI_LEAD_ID = l_osi_rec.OSI_LEAD_ID
    ,LEAD_ID = l_osi_rec.LEAD_ID
    ,CVEHICLE = to_number(l_osi_rec.CVEHICLE)
    ,CNAME_ID = to_number(l_osi_rec.CNAME_ID)
    ,CONTR_DRAFTING_REQ  = l_osi_rec.CONTR_DRAFTING_REQ
    ,PRIORITY = l_osi_rec.PRIORITY
    ,SENIOR_CONTR_PERSON_ID = to_number(l_osi_rec.SENIOR_CONTR_PERSON_ID)
    ,CONTR_SPEC_PERSON_ID = to_number(l_osi_rec.CONTR_SPEC_PERSON_ID)
    ,BOM_PERSON_ID = to_number(l_osi_rec.BOM_PERSON_ID)
    ,LEGAL_PERSON_ID = to_number(l_osi_rec.LEGAL_PERSON_ID)
    ,HIGHEST_APVL = l_osi_rec.HIGHEST_APVL
    ,CURRENT_APVL_STATUS = l_osi_rec.CURRENT_APVL_STATUS
    ,SUPPORT_APVL = l_osi_rec.SUPPORT_APVL
    ,INTERNATIONAL_APVL = l_osi_rec.INTERNATIONAL_APVL
    ,CREDIT_APVL = l_osi_rec.CREDIT_APVL
    ,FIN_ESCROW_REQ = l_osi_rec.FIN_ESCROW_REQ
    ,FIN_ESCROW_STATUS = l_osi_rec.FIN_ESCROW_STATUS
    ,CSI_ROLLIN = l_osi_rec.CSI_ROLLIN
    ,LICENCE_CREDIT_VER = l_osi_rec.LICENCE_CREDIT_VER
    ,SUPPORT_CREDIT_VER = l_osi_rec.SUPPORT_CREDIT_VER
    ,MD_DEAL_SUMMARY = l_osi_rec.MD_DEAL_SUMMARY
    ,PROD_AVAIL_VER = l_osi_rec.PROD_AVAIL_VER
    ,SHIP_LOCATION = l_osi_rec.SHIP_LOCATION
    ,TAX_EXEMPT_CERT = l_osi_rec.TAX_EXEMPT_CERT
    ,NL_REV_ALLOC_REQ = l_osi_rec.NL_REV_ALLOC_REQ
    ,CONSULTING_CC = l_osi_rec.CONSULTING_CC
    ,SENIOR_CONTR_NOTES = l_osi_rec.SENIOR_CONTR_NOTES
    ,LEGAL_NOTES = l_osi_rec.LEGAL_NOTES
    ,BOM_NOTES = l_osi_rec.BOM_NOTES
    ,CONTR_NOTES = l_osi_rec.CONTR_NOTES
    ,PO_FROM = l_osi_rec.PO_FROM
    ,CONTR_TYPE = l_osi_rec.CONTR_TYPE
    ,CONTR_STATUS = l_osi_rec.CONTR_STATUS
    ,EXTRA_DOCS = to_number(l_osi_rec.EXTRA_DOCS)
   where osi_lead_id = l_osi_rec.osi_lead_id;
  exception
  when no_data_found then
  insert into as_osi_leads_all(
     creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,OSI_LEAD_ID
    ,LEAD_ID
    ,CVEHICLE
    ,CNAME_ID
    ,CONTR_DRAFTING_REQ
    ,PRIORITY
    ,SENIOR_CONTR_PERSON_ID
    ,CONTR_SPEC_PERSON_ID
    ,BOM_PERSON_ID
    ,LEGAL_PERSON_ID
    ,HIGHEST_APVL
    ,CURRENT_APVL_STATUS
    ,SUPPORT_APVL
    ,INTERNATIONAL_APVL
    ,CREDIT_APVL
    ,FIN_ESCROW_REQ
    ,FIN_ESCROW_STATUS
    ,CSI_ROLLIN
    ,LICENCE_CREDIT_VER
    ,SUPPORT_CREDIT_VER
    ,MD_DEAL_SUMMARY
    ,PROD_AVAIL_VER
    ,SHIP_LOCATION
    ,TAX_EXEMPT_CERT
    ,NL_REV_ALLOC_REQ
    ,CONSULTING_CC
    ,SENIOR_CONTR_NOTES
    ,LEGAL_NOTES
    ,BOM_NOTES
    ,CONTR_NOTES
    ,PO_FROM
    ,CONTR_TYPE
    ,CONTR_STATUS
    ,EXTRA_DOCS

   ) values (
     sysdate
    ,nvl(to_number(nvl(l_osi_rec.created_by,l_osi_rec.last_updated_by)),1)
    ,sysdate
    ,nvl(to_number(nvl(l_osi_rec.created_by,l_osi_rec.last_updated_by)),1)
    ,1
    ,l_osi_rec.OSI_LEAD_ID
    ,l_osi_rec.LEAD_ID
    ,to_number(l_osi_rec.CVEHICLE)
    ,to_number(l_osi_rec.CNAME_ID)
    ,l_osi_rec.CONTR_DRAFTING_REQ
    ,l_osi_rec.PRIORITY
    ,to_number(l_osi_rec.SENIOR_CONTR_PERSON_ID)
    ,to_number(l_osi_rec.CONTR_SPEC_PERSON_ID)
    ,to_number(l_osi_rec.BOM_PERSON_ID)
    ,to_number(l_osi_rec.LEGAL_PERSON_ID)
    ,l_osi_rec.HIGHEST_APVL
    ,l_osi_rec.CURRENT_APVL_STATUS
    ,l_osi_rec.SUPPORT_APVL
    ,l_osi_rec.INTERNATIONAL_APVL
    ,l_osi_rec.CREDIT_APVL
    ,l_osi_rec.FIN_ESCROW_REQ
    ,l_osi_rec.FIN_ESCROW_STATUS
    ,l_osi_rec.CSI_ROLLIN
    ,l_osi_rec.LICENCE_CREDIT_VER
    ,l_osi_rec.SUPPORT_CREDIT_VER
    ,l_osi_rec.MD_DEAL_SUMMARY
    ,l_osi_rec.PROD_AVAIL_VER
    ,l_osi_rec.SHIP_LOCATION
    ,l_osi_rec.TAX_EXEMPT_CERT
    ,l_osi_rec.NL_REV_ALLOC_REQ
    ,l_osi_rec.CONSULTING_CC
    ,l_osi_rec.SENIOR_CONTR_NOTES
    ,l_osi_rec.LEGAL_NOTES
    ,l_osi_rec.BOM_NOTES
    ,l_osi_rec.CONTR_NOTES
    ,l_osi_rec.PO_FROM
    ,l_osi_rec.CONTR_TYPE
    ,l_osi_rec.CONTR_STATUS
    ,to_number(l_osi_rec.EXTRA_DOCS)
   );
 end;
  if l_osi_ovd_tbl.count > 0 then
    for ovd in ovd_cur(l_osi_rec.osi_lead_id) loop
      l_delete_flag := TRUE;
      for i in 1..l_osi_ovd_tbl.count loop
        if l_osi_ovd_tbl(i).ovd_code = ovd.ovm_code then
          if l_osi_ovd_tbl(i).ovd_flag <> 'N' then
            l_osi_ovd_tbl(i).ovd_flag := 'X';
            l_delete_flag := FALSE;
          end if;
        end if;
      end loop;
      if l_delete_flag then
        delete from as_osi_lead_ovl_all
         where osi_lead_id = ovd.osi_lead_id
           and ovm_code = ovd.ovm_code;
      end if;
    end loop;
    for i in 1..l_osi_ovd_tbl.count loop
      if l_osi_ovd_tbl(i).ovd_flag = 'Y' and l_osi_ovd_tbl(i).ovd_code is not null then
        begin
        insert into as_osi_lead_ovl_all(
           creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,OSI_LEAD_ID
          ,OVM_CODE
         ) values (
           sysdate
          ,nvl(to_number(nvl(l_osi_rec.created_by,l_osi_rec.last_updated_by)),1)
          ,sysdate
          ,nvl(to_number(nvl(l_osi_rec.created_by,l_osi_rec.last_updated_by)),1)
          ,l_osi_rec.OSI_LEAD_ID
          ,l_osi_ovd_tbl(i).ovd_code);
        exception
        when others then
          null;
        end;
      end if;
    end loop;
  end if;
  commit;
end osi_lead_update;
PROCEDURE osi_cvb_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_cvb_tbl                       out    OSI_CVB_TBL_TYPE
) is
  cursor cvb_cur is
    select cvehicle, vehicle
      from as_osi_contr_vhcl_base
     where nvl(enabled_flag,'Y') = 'Y'
     order by 1;
  l_osi_cvb_tbl OSI_CVB_TBL_TYPE := G_MISS_OSI_CVB_TBL;
  ndx binary_integer := 0;
begin
  for cvb in cvb_cur loop
    ndx := ndx + 1;
    l_osi_cvb_tbl(ndx).cvehicle := to_char(cvb.cvehicle);
    l_osi_cvb_tbl(ndx).vehicle := cvb.vehicle;
  end loop;
  p_osi_cvb_tbl := l_osi_cvb_tbl;
end osi_cvb_fetch;
PROCEDURE osi_cnb_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_cnb_tbl                       out    OSI_CNB_TBL_TYPE
) is
  cursor cnb_cur is
    select  CNAME_ID, CONTR_NAME, CVEHICLE
      from as_osi_contr_names_base
     where nvl(enabled_flag,'Y') = 'Y'
     order by CVEHICLE, CONTR_NAME;
  l_osi_cnb_tbl OSI_CNB_TBL_TYPE := G_MISS_OSI_CNB_TBL;
  ndx binary_integer := 0;
begin
  for cnb in cnb_cur loop
    ndx := ndx + 1;
    l_osi_cnb_tbl(ndx).CNAME_ID := to_char(cnb.CNAME_ID);
    l_osi_cnb_tbl(ndx).CONTR_NAME := cnb.CONTR_NAME;
    l_osi_cnb_tbl(ndx).CVEHICLE := to_char(cnb.CVEHICLE);
  end loop;
  p_osi_cnb_tbl := l_osi_cnb_tbl;
end osi_cnb_fetch;
PROCEDURE osi_lkp_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_lkp_type          in     varchar2,
    p_osi_lkp_tbl                       out    OSI_LKP_TBL_TYPE
) is
  cursor lkp_cur (lkp_type_in in varchar2) is
    select lkp_type, lkp_code, lkp_value
      from as_osi_lookup
     where (lkp_type = upper(lkp_type_in)
        or lkp_type_in = 'ALL')
       and nvl(enabled_flag,'Y') = 'Y'
     order by 1,2;
  l_osi_lkp_tbl OSI_LKP_TBL_TYPE := G_MISS_OSI_LKP_TBL;
  CURSOR state_cur IS
    select distinct alv.location_segment_user_value lkp_code, alv.location_segment_description lkp_value
      from ar_location_values alv,
           ar_system_parameters asp
     where alv.location_structure_id = asp.location_structure_id
       and alv.parent_segment_id is null
     order by 1;
  ndx binary_integer := 0;
begin
  if p_osi_lkp_type <> 'SHIP_LOCATION' then
    for lkp in lkp_cur(p_osi_lkp_type) loop
      ndx := ndx + 1;
      l_osi_lkp_tbl(ndx).lkp_type := lkp.lkp_type;
      l_osi_lkp_tbl(ndx).lkp_code := lkp.lkp_code;
      l_osi_lkp_tbl(ndx).lkp_value := lkp.lkp_value;
    end loop;
  end if;
  if p_osi_lkp_type in ('SHIP_LOCATION','ALL') then
    for lkp in state_cur loop
      ndx := ndx + 1;
      l_osi_lkp_tbl(ndx).lkp_type := 'SHIP_LOCATION';
      l_osi_lkp_tbl(ndx).lkp_code := lkp.lkp_code;
      l_osi_lkp_tbl(ndx).lkp_value := lkp.lkp_value;
    end loop;
  end if;
  p_osi_lkp_tbl := l_osi_lkp_tbl;
end osi_lkp_fetch;
PROCEDURE osi_nam_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_nam_type          in     varchar2,
    p_osi_nam_tbl                       out    OSI_NAM_TBL_TYPE
) is
  l_osi_nam_tbl OSI_NAM_TBL_TYPE := G_MISS_OSI_NAM_TBL;
  l_nam_type varchar2(30) := null;
  l_nam_value varchar2(30);
  l_last_name varchar2(40);
  l_email_address varchar2(240);
  l_supervisor_id number;
  ndx binary_integer := 0;
  cursor nam_cur (supervisor_id_in in number, sales_group_id_in in number) is
    select ppf.person_id person_id, max(ppf.email_address) email_address, max(ppf.last_name)
      from per_people_f ppf,
           as_salesforce as1
     where as1.sales_group_id = sales_group_id_in
       and as1.employee_person_id is not null
       and as1.employee_person_id = ppf.person_id
       and sysdate between ppf.effective_start_date and ppf.effective_end_date
       and as1.status_code = 'A'
     group by ppf.person_id
    UNION
    select ppf.person_id person_id, max(ppf.email_address) email_address, max(ppf.last_name)
      from per_people_f ppf
     where ppf.person_id  = supervisor_id_in
       and sysdate between ppf.effective_start_date and ppf.effective_end_date
     group by ppf.person_id
    ORDER BY 3,2;
  cursor sg_cur (last_name_in in varchar2, email_address_in in varchar2) is
    select max(ppf.person_id) supervisor_id, max(asg.sales_group_id) sales_group_id
      from per_people_f ppf
          ,as_sales_groups asg
     where ppf.last_name = last_name_in
       and upper(ppf.email_address) = email_address_in
       and trunc(nvl(ppf.effective_start_date,sysdate)) <= trunc(sysdate)
       and trunc(nvl(ppf.effective_end_date,sysdate)) >= trunc(sysdate)
       and ppf.person_id = asg.manager_person_id;
begin
  for i in 1..4 loop
    if i = 1 then
      l_nam_type := 'LEGAL';
      l_last_name := 'Blumberg';
      l_email_address := 'JBLUMBER';
    elsif i = 2 then
      l_nam_type := 'BOM';
      l_last_name := 'Ferguson';
      l_email_address := 'LFERGUSO';
    elsif i = 3 then
      l_nam_type := 'SENIOR_CONTR';
      l_last_name := 'Zettler';
      l_email_address := 'JZETTLER';
    elsif i = 4 then
      l_nam_type := 'CONTR_SPEC';
      l_last_name := 'Rowzee';
      l_email_address := 'JROWZEE';
    end if;
    if p_osi_nam_type = 'ALL' or p_osi_nam_type = l_nam_type then
      begin
        for sg in sg_cur(l_last_name, l_email_address) loop
          for nam in nam_cur(sg.supervisor_id, sg.sales_group_id) loop
            ndx := ndx+1;
            l_osi_nam_tbl(ndx).nam_type := l_nam_type;
            l_osi_nam_tbl(ndx).nam_id := nam.person_id;
            l_osi_nam_tbl(ndx).nam_value := nam.email_address;
          end loop;
        end loop;
      exception
        when others then
          null;
      end;
    end if;
  end loop;
  p_osi_nam_tbl := l_osi_nam_tbl;
end osi_nam_fetch;
PROCEDURE osi_ccs_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_ccs_tbl                       out    OSI_CCS_TBL_TYPE
) is
  cursor ccs_cur is
    select cc, center_name
      from as_osi_cons_ccs_base
     where nvl(enabled_flag,'Y') = 'Y'
     order by 1;
  l_osi_ccs_tbl OSI_CCS_TBL_TYPE := G_MISS_OSI_CCS_TBL;
  ndx binary_integer := 0;
begin
  for ccs in ccs_cur loop
    ndx := ndx + 1;
    l_osi_ccs_tbl(ndx).cc := ccs.cc;
    l_osi_ccs_tbl(ndx).center_name := ccs.center_name;
  end loop;
  p_osi_ccs_tbl := l_osi_ccs_tbl;
end osi_ccs_fetch;
PROCEDURE osi_ovm_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_ovm_tbl                       out    OSI_OVM_TBL_TYPE
) is
  cursor ovm_cur is
    select ovm_code, ovm_value
      from as_osi_overlay_base
     where nvl(enabled_flag,'Y') = 'Y'
     order by 2;
  l_osi_ovm_tbl OSI_OVM_TBL_TYPE := G_MISS_OSI_OVM_TBL;
  ndx binary_integer := 0;
begin
  for ovm in ovm_cur loop
    ndx := ndx + 1;
    l_osi_ovm_tbl(ndx).ovm_code := ovm.ovm_code;
    l_osi_ovm_tbl(ndx).ovm_value := ovm.ovm_value;
  end loop;
  p_osi_ovm_tbl := l_osi_ovm_tbl;
end osi_ovm_fetch;
PROCEDURE osi_lead_fetch_all
(   p_api_version_number    IN     NUMBER,
    p_lead_id				in    VARCHAR2,
    p_osi_rec                       out    OSI_REC_TYPE     ,
    p_osi_cvb_tbl                       out    OSI_CVB_TBL_TYPE  ,
    p_osi_cnb_tbl                       out    OSI_CNB_TBL_TYPE     ,
    p_osi_lkp_tbl                       out    OSI_LKP_TBL_TYPE,
    p_osi_nam_tbl                       out    OSI_NAM_TBL_TYPE,
    p_osi_ccs_tbl                       out    OSI_CCS_TBL_TYPE,
    p_osi_ovd_tbl                       out    OSI_OVD_TBL_TYPE,
    p_osi_ovm_tbl                       out    OSI_OVM_TBL_TYPE
) is
  l_osi_nam_tbl OSI_NAM_TBL_TYPE := G_MISS_OSI_NAM_TBL;
  l_osi_cvb_tbl OSI_CVB_TBL_TYPE := G_MISS_OSI_CVB_TBL;
  l_osi_cnb_tbl OSI_CNB_TBL_TYPE := G_MISS_OSI_CNB_TBL;
  l_osi_lkp_tbl OSI_LKP_TBL_TYPE := G_MISS_OSI_LKP_TBL;
  l_osi_ccs_tbl OSI_CCS_TBL_TYPE := G_MISS_OSI_CCS_TBL;
  l_osi_ovm_tbl OSI_OVM_TBL_TYPE := G_MISS_OSI_OVM_TBL;
  l_osi_ovd_tbl OSI_OVD_TBL_TYPE := G_MISS_OSI_OVD_TBL;
  l_osi_rec OSI_REC_TYPE := G_MISS_OSI_REC;
begin
  osi_lead_fetch(p_api_version_number,p_lead_id,l_osi_rec,l_osi_ovd_tbl);
  osi_cvb_fetch(p_api_version_number,l_osi_cvb_tbl);
  osi_cnb_fetch(p_api_version_number,l_osi_cnb_tbl);
  osi_lkp_fetch(p_api_version_number,'ALL',l_osi_lkp_tbl);
  osi_nam_fetch(p_api_version_number,'ALL',l_osi_nam_tbl);
  osi_ccs_fetch(p_api_version_number,l_osi_ccs_tbl);
  osi_ovm_fetch(p_api_version_number,l_osi_ovm_tbl);
  p_osi_cvb_tbl := l_osi_cvb_tbl;
  p_osi_cnb_tbl := l_osi_cnb_tbl;
  p_osi_lkp_tbl := l_osi_lkp_tbl;
  p_osi_nam_tbl := l_osi_nam_tbl;
  p_osi_ccs_tbl := l_osi_ccs_tbl;
  p_osi_ovd_tbl := l_osi_ovd_tbl;
  p_osi_ovm_tbl := l_osi_ovm_tbl;
  p_osi_rec := l_osi_rec;
end osi_lead_fetch_all;
PROCEDURE osi_lookup_fetch_all
(   p_api_version_number    IN     NUMBER,
    p_osi_cvb_tbl                       out    OSI_CVB_TBL_TYPE  ,
    p_osi_cnb_tbl                       out    OSI_CNB_TBL_TYPE     ,
    p_osi_lkp_tbl                       out    OSI_LKP_TBL_TYPE,
    p_osi_nam_tbl                       out    OSI_NAM_TBL_TYPE,
    p_osi_ccs_tbl                       out    OSI_CCS_TBL_TYPE,
    p_osi_ovm_tbl                       out    OSI_OVM_TBL_TYPE
) is
  l_osi_nam_tbl OSI_NAM_TBL_TYPE := G_MISS_OSI_NAM_TBL;
  l_osi_cvb_tbl OSI_CVB_TBL_TYPE := G_MISS_OSI_CVB_TBL;
  l_osi_cnb_tbl OSI_CNB_TBL_TYPE := G_MISS_OSI_CNB_TBL;
  l_osi_lkp_tbl OSI_LKP_TBL_TYPE := G_MISS_OSI_LKP_TBL;
  l_osi_ccs_tbl OSI_CCS_TBL_TYPE := G_MISS_OSI_CCS_TBL;
  l_osi_ovm_tbl OSI_OVM_TBL_TYPE := G_MISS_OSI_OVM_TBL;
begin
  osi_cvb_fetch(p_api_version_number,l_osi_cvb_tbl);
  osi_cnb_fetch(p_api_version_number,l_osi_cnb_tbl);
  osi_lkp_fetch(p_api_version_number,'ALL',l_osi_lkp_tbl);
  osi_nam_fetch(p_api_version_number,'ALL',l_osi_nam_tbl);
  osi_ccs_fetch(p_api_version_number,l_osi_ccs_tbl);
  osi_ovm_fetch(p_api_version_number,l_osi_ovm_tbl);
  p_osi_cvb_tbl := l_osi_cvb_tbl;
  p_osi_cnb_tbl := l_osi_cnb_tbl;
  p_osi_lkp_tbl := l_osi_lkp_tbl;
  p_osi_nam_tbl := l_osi_nam_tbl;
  p_osi_ccs_tbl := l_osi_ccs_tbl;
  p_osi_ovm_tbl := l_osi_ovm_tbl;
end osi_lookup_fetch_all;
FUNCTION osi_get_button_html
(   p_api_version_number    IN     NUMBER
) return varchar2 is
 out_text varchar2(2000);
begin
 out_text :=
    '<input type="button" value="OSI Additions" onClick = "osiExt();">';
 return out_text;
end osi_get_button_html;
FUNCTION osi_get_js_html
(   p_api_version_number    IN     NUMBER
) return varchar2 is
 out_text varchar2(2000);
begin
  out_text :=
    'function osiExt() {'||
    'osi_ext_win = window.open('||
          '"asxosics.jsp?p_lead_id="+document.forms[0].p_lead_id.value,'||
          '"OSI",'||
          '"resizable=yes,menubar=yes,scrollbars=yes,width=780,height=450,screenX=200,screenY=150");'||
    'osi_ext_win.opener = self;}';
  return out_text;
end osi_get_js_html;
end AS_OSI_LEAD_PUB;

/
