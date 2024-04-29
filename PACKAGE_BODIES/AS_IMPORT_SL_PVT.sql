--------------------------------------------------------
--  DDL for Package Body AS_IMPORT_SL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_IMPORT_SL_PVT" as
/* $Header: asxslimb.pls 120.10 2006/01/27 17:43:03 solin ship $ */

--impView  as_imp_sl_v%rowtype;
--subtype leadImpView is impView%Type;
cursor imptype is select * from as_import_interface;
subtype leadImpType is impType%rowtype;

cursor cptype is select * from as_imp_cnt_pnt_interface;
subtype cntPntType is cptype%rowtype;

G_LOCAL_ORG_CONTACT_ID number := null; -- This is to store org_contact_id
G_SL_LINE_COUNT number := 0; -- This is to count SL Lines

-- Added by Ajoy
G_SL_SALESFORCE_ID number; -- This is to identify salesforce_id of the logged in user

-- Bugfix# 2835357, Call user hook once
G_CALL_USER_HOOK boolean := JTF_USR_HKS.Ok_to_execute('AS_IMPORT_SL_PVT', 'IS_DUPLICATE_LEAD','B','C');

--------------------------------------------------------
-- name: write_log
-- scope: private
-- used to write to log or output
--------------------------------------------------------
procedure write_log(p_mode in Number,p_mesg in Varchar2) is
begin
    -- p_mode = 1 means write to output
    -- p_mode = 2 means write to log
    -- p_mode = 3 means debug mode

    if (p_mode in (2,3))  then          -- debugging
	if ((p_mode = 3) and (G_DEBUGFLAG = 'Y'))then
		fnd_file.put(log_fpt, substr(p_mesg,1,255));
		fnd_file.new_line(log_fpt,1);
	elsif (p_mode =2) then
		fnd_file.put(log_fpt, substr(p_mesg,1,255));
		fnd_file.new_line(log_fpt,1);
	else
		null;
	end if;
    else
       fnd_file.put(output_fpt, substr(p_mesg,1,255));
       fnd_file.new_line(output_fpt,1);
    end if;

--    dbms_output.put_line (substr(p_mesg,1,255));
end write_log;

--------------------------------------------------------
-- name: write_errors
-- scope: private
-- insert to error table
-- swkhanna April 23,2002, added an extra variable p_error_type
-- to take care of unexpected errors
--------------------------------------------------------
procedure write_errors(
  pI IN leadImpType,
  p_error_type IN varchar2,
  G_return_status OUT NOCOPY varchar2) Is
  l_msg_data VARCHAR2(2000) := Null;
  l_msg_index_out number;
Begin

  if p_error_type in ('EXP','UNEXP','OTHER') then
    G_MESG_COUNT := FND_MSG_PUB.Count_Msg;
    write_log(3, 'Message Count:'||G_MESG_COUNT);
    For i IN 1..G_MESG_COUNT Loop
        FND_MSG_PUB.Get(
            p_msg_index	 => i,
            p_encoded => FND_API.G_FALSE,
            p_data => l_msg_data,
            p_msg_index_out =>l_msg_index_out
        );

        -- ffang 042601, for bug 1751324, add 4 new columns
        insert into as_lead_import_errors(
            lead_import_error_id,
            last_updated_by,
            last_update_date ,
            creation_date,
            created_by,
            last_update_login,
            import_interface_id ,
            batch_id ,
            error_text ,
            request_id,
            program_application_id,
            program_id,
            program_update_date
        )
        values (
            as_lead_import_errors_s.nextval,
            nvl(FND_GLOBAL.User_id, -1),
            sysdate,
            sysdate,
            nvl(FND_GLOBAL.User_id, -1),
            nvl(FND_GLOBAL.Login_id, -1),
            pI.import_interface_id,
            nvl(pI.batch_id,-1),
            l_msg_data,
            pI.request_id,
            pI.program_application_id,
            pI.program_id,
            pI.program_update_date
        );
    End Loop;
  end if;
  --
  if p_error_type in ('UNEXP','OTHER') then
    l_msg_data := substr(SQLERRM,1,2000);
       -- insert sqlerrm
        insert into as_lead_import_errors(
            lead_import_error_id,
            last_updated_by,
            last_update_date ,
            creation_date,
            created_by,
            last_update_login,
            import_interface_id ,
            batch_id ,
            error_text ,
            request_id,
            program_application_id,
            program_id,
            program_update_date
        )
   values (
            as_lead_import_errors_s.nextval,
            nvl(FND_GLOBAL.User_id, -1),
            sysdate,
            sysdate,
            nvl(FND_GLOBAL.User_id, -1),
            nvl(FND_GLOBAL.Login_id, -1),
            pI.import_interface_id,
            nvl(pI.batch_id,-1),
            l_msg_data,
            pI.request_id,
            pI.program_application_id,
            pI.program_id,
            pI.program_update_date
        );
  end if;
--  dbms_output.put_line(l_msg_data);
    Exception
        when others then
            write_log(2, 'write_errors failed!');
            G_return_status := FND_API.G_RET_STS_ERROR;
END write_errors;

--------------------------------------------------------
-- name: writeBak
-- scope: private
-- Updates the as_import_interface table
--------------------------------------------------------
procedure writeBak(
              pI IN leadImpType,
              G_return_status OUT NOCOPY varchar2)
IS
BEGIN
    if (pI.load_status = G_LOAD_STATUS_SUCC) then
        update as_import_interface
        set load_status = G_LOAD_STATUS_SUCC,
            party_id = pI.party_id,
            party_site_id = pI.party_site_id,
            location_id = pI.location_id,
            sales_lead_id = pI.sales_lead_id,
            contact_party_id = pI.contact_party_id,
            rel_party_id = pI.rel_party_id,
            new_party_flag = pI.new_party_flag,
            new_loc_flag = pI.new_loc_flag,
            new_ps_flag = pI.new_ps_flag,
            new_rel_flag = pI.new_rel_flag,
            -- ffang 102301, bug 2071826, write new_con_flag back.
            new_con_flag = pI.new_con_flag,
            -- end 102301
            last_update_date = sysdate,
            last_updated_by = nvl(FND_GLOBAL.User_id, -1),
            last_update_login =  nvl(FND_GLOBAL.Login_id, -1),
            request_id =  nvl(FND_GLOBAL.conc_request_id, -1),
            program_application_id =  nvl(FND_GLOBAL.Prog_appl_id, -1),
            program_id = nvl(FND_GLOBAL.conc_program_id, -1),
            program_update_date = sysdate,
            -- ffang 101601, bug 2053591, populate promotion_id / promotion_code
            promotion_id = pI.promotion_id,
            -- swkhanna 05/28/02 2385197
            promotion_code = UPPER(pI.promotion_code),
           -- swkhanna 07/30/02 write bal assign_to_person_id
            assign_to_person_id = pI.assign_to_person_id
        where import_interface_id = pI.import_interface_id;
        --where rowid = pI.rowid;
    elsif (pI.load_status = G_LOAD_STATUS_ERR) then
        update as_import_interface
        set load_status = G_LOAD_STATUS_ERR,
            -- ffang 101001, bug 2044483, if error, don't update those ids/flags
            -- party_id = pI.party_id,
            -- party_site_id = pI.party_site_id,
            -- location_id = pI.location_id,
            -- sales_lead_id = pI.sales_lead_id,
            -- contact_party_id = pI.contact_party_id,
            -- rel_party_id = pI.rel_party_id,
            -- new_party_flag = pI.new_party_flag,
            -- new_loc_flag = pI.new_loc_flag,
            -- new_ps_flag = pI.new_ps_flag,
            -- new_rel_flag = pI.new_rel_flag,
            last_update_date = sysdate,
            last_updated_by = nvl(FND_GLOBAL.User_id, -1),
            last_update_login =  nvl(FND_GLOBAL.Login_id, -1),
            request_id =  nvl(FND_GLOBAL.conc_request_id, -1),
            program_application_id =  nvl(FND_GLOBAL.Prog_appl_id, -1),
            program_id = nvl(FND_GLOBAL.conc_program_id, -1),
            program_update_date = sysdate
        where import_interface_id = pI.import_interface_id;
        --where rowid = pI.rowid;
    elsif (pI.load_status = G_LOAD_STATUS_UNEXP_ERR) then
        update as_import_interface
        set load_status = G_LOAD_STATUS_UNEXP_ERR,
            -- ffang 101001, bug 2044483, if error, don't update those ids/flags
            -- party_id = pI.party_id,
            -- party_site_id = pI.party_site_id,
            -- location_id = pI.location_id,
            -- sales_lead_id = pI.sales_lead_id,
            -- contact_party_id = pI.contact_party_id,
            -- rel_party_id = pI.rel_party_id,
            -- new_party_flag = pI.new_party_flag,
            -- new_loc_flag = pI.new_loc_flag,
            -- new_ps_flag = pI.new_ps_flag,
            -- new_rel_flag = pI.new_rel_flag,
            last_update_date = sysdate,
            last_updated_by = nvl(FND_GLOBAL.User_id, -1),
            last_update_login =  nvl(FND_GLOBAL.Login_id, -1),
            request_id =  nvl(FND_GLOBAL.conc_request_id, -1),
            program_application_id =  nvl(FND_GLOBAL.Prog_appl_id, -1),
            program_id = nvl(FND_GLOBAL.conc_program_id, -1),
            program_update_date = sysdate
        where import_interface_id = pI.import_interface_id;
        --where rowid = pI.rowid;
    elsif (pI.load_status = 'DUPLICATE') then
        update as_import_interface
        set load_status = 'DUPLICATE', sales_lead_id = pI.sales_lead_id
        where import_interface_id = pI.import_interface_id;
    else
        G_return_status := FND_API.G_RET_STS_ERROR;
    End if;
Exception
    when others then
      write_log(2, 'writeBak failed!');
      G_return_status := FND_API.G_RET_STS_ERROR;
end writeBak;

--------------------------------------------------------
-- name: cont_pnt_dedupe
-- scope: private
-- used to check duplicate contact points
-------------------------------- ------------------------

procedure cont_pnt_dedupe(pI IN OUT NOCOPY leadImpType,
                          p_dup_phone OUT NOCOPY varchar2,
                          p_dup_email OUT NOCOPY varchar2,
                          p_dup_fax OUT NOCOPY varchar2,
                          p_dup_url OUT NOCOPY varchar2
                         ) is

cursor c_chk_cont_pnt (c_contact_point_type varchar2,
                       c_owner_table_id number,
                       c_email_address varchar2,
                       c_phone_area_code varchar2,
                       c_phone_number    varchar2,
                       c_phone_line_type varchar2,
                       c_url             varchar2) IS
select contact_point_id
from   hz_contact_points
where  owner_table_id = c_owner_table_id
and    owner_table_name = 'HZ_PARTIES'
and    nvl(email_address,'1') =   nvl(c_email_address,'1')
and    nvl(phone_area_code,'1') = nvl(c_phone_area_code,'1')
and    nvl(phone_number,'1')   = nvl(c_phone_number,'1')
and    nvl(phone_line_type,'1') = nvl(c_phone_line_type,'1')
and    nvl(url,'1')  = nvl(c_url,'1')
and    contact_point_type = c_contact_point_type
;

l_contact_point_id number;
BEGIN
--dbms_output.put_line('c_owner_table_id:'||pI.rel_party_id);
--dbms_output.put_line('c_email_address:'||pI.email_address);
--dbms_output.put_line('phone_area_code:'||pI.area_code);
--dbms_output.put_line('phone_number:'||pI.phone_number);
--dbms_output.put_line('phone_line_type:'||pI.phone_type);
--dbms_output.put_line('url:'||pI.url);

p_dup_phone := 'N';
p_dup_email := 'N';
p_dup_fax := 'N';
p_dup_url := 'N';

 If (pI.phone_number is not null)  then
    --
    open c_chk_cont_pnt ('PHONE',pI.rel_party_id,null,
                         pI.area_code,pI.phone_number,pI.phone_type,
                         null);

    fetch c_chk_cont_pnt into l_contact_point_id;
    if c_chk_cont_pnt%FOUND then
       p_dup_phone := 'Y';
    else
       p_dup_phone := 'N';
    end if;
    close c_chk_cont_pnt;
 end if;


 If (pI.email_address is not null)  then
    --
    open c_chk_cont_pnt ('EMAIL',pI.rel_party_id,pI.email_address,
                         null,null,null, null);

    fetch c_chk_cont_pnt into l_contact_point_id;
    if c_chk_cont_pnt%FOUND then
       p_dup_email := 'Y';
    else
       p_dup_email := 'N';
    end if;
    close c_chk_cont_pnt;
 end if;

  If (pI.fax_number is not null)  then
    --
    open c_chk_cont_pnt ('PHONE',pI.rel_party_id,null,
                         null,pI.fax_number,'FAX',
                         null);
    fetch c_chk_cont_pnt into l_contact_point_id;
    if c_chk_cont_pnt%FOUND then
       p_dup_fax := 'Y';
    else
       p_dup_fax := 'N';
    end if;
    close c_chk_cont_pnt;
 end if;

   If (pI.url is not null)  then
    --
    open c_chk_cont_pnt ('WEB',pI.rel_party_id,null,
                         null,null,null,
                         pI.url);

    fetch c_chk_cont_pnt into l_contact_point_id;
    if c_chk_cont_pnt%FOUND then
       p_dup_url := 'Y';
    else
       p_dup_url := 'N';
    end if;
    close c_chk_cont_pnt;
 end if;

 --   dbms_output.put_line('l_contact_point_id:'||l_contact_point_id);


END;


--------------------------------------------------------
-- name: deDupe_Check
-- scope: private
-- used to check duplicate leads
-------------------------------- ------------------------
procedure deDupe_Check(pI IN OUT NOCOPY leadImpType,
                       x_duplicate_lead OUT NOCOPY varchar2,
		       x_dup_sales_lead_id OUT NOCOPY number) is

x_return_status     varchar2(1);
x_msg_count         number;
x_msg_data          varchar2(2000);
l_contact_party_id  number;
total_amount        number;

dup_rec             AML_LEAD_DEDUPE_PVT.dedupe_rec_type;
int_rec             AML_LEAD_DEDUPE_PVT.category_id_type;
idx                 number;

CURSOR C_get_lines (c_import_interface_id number)
IS
  select category_id, sum(budget_amount) budget_amount
    from as_imp_lines_interface
   where import_interface_id = c_import_interface_id
     and category_id is not null
   group by category_id;

BEGIN

  write_log(3, 'Inside dedupe_check');
/*
  IF pI.party_type = 'PERSON' THEN -- for person dedupe check
     l_contact_party_id := pI.party_id;
  ELSE -- for org dedupe check
     l_contact_party_id := pI.contact_party_id;
  END IF;
*/
  --Populate inerest type tbl
  idx := 0;
  total_amount := 0;

  IF pI.category_id_1 IS NOT NULL THEN
     idx := idx + 1;
     int_rec(idx) := pI.category_id_1;
     total_amount := total_amount + nvl(pI.budget_amount_1,0);
  END IF;

  IF pI.category_id_2 IS NOT NULL THEN
     idx := idx + 1;
     int_rec(idx) := pI.category_id_2;
     total_amount := total_amount + nvl(pI.budget_amount_2,0);
  END IF;

  IF pI.category_id_3 IS NOT NULL THEN
     idx := idx + 1;
     int_rec(idx) := pI.category_id_3;
     total_amount := total_amount + nvl(pI.budget_amount_3,0);
  END IF;

  IF pI.category_id_4 IS NOT NULL THEN
     idx := idx + 1;
     int_rec(idx) := pI.category_id_4;
     total_amount := total_amount + nvl(pI.budget_amount_4,0);
  END IF;

  IF pI.category_id_5 IS NOT NULL THEN
     idx := idx + 1;
     int_rec(idx) := pI.category_id_5;
     total_amount := total_amount + nvl(pI.budget_amount_5,0);
  END IF;

  FOR line IN C_get_lines(pI.import_interface_id) LOOP
    idx := idx + 1;
    int_rec(idx) := line.category_id;
    total_amount := total_amount + nvl(line.budget_amount,0);
  END LOOP;

  dup_rec.party_id                := pI.party_id;
  dup_rec.party_site_id           := pI.party_site_id;
  dup_rec.contact_id              := pI.contact_party_id;
  dup_rec.vehicle_response_code   := pI.vehicle_response_code;
  dup_rec.source_code             := pI.promotion_code;
  dup_rec.lead_note               := pI.lead_note;
  dup_rec.note_type               := pI.note_type;
  dup_rec.budget_amount           := pI.budget_amount;
  dup_rec.purchase_amount         := total_amount;
  dup_rec.budget_status_code      := pI.budget_status_code;
  dup_rec.project_code            := pI.parent_project;
  dup_rec.purchase_timeframe_code := pI.decision_timeframe_code;
  dup_rec.category_id_tbl         := int_rec;


  --Call dedupe API
  AML_LEAd_DEDUPE_PVT.Main (
    'T', dup_rec, x_duplicate_lead,
    x_dup_sales_lead_id,
    x_return_status,
    x_msg_count,
    x_msg_data
  );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

End deDupe_Check;

--------------------------------------------------------
-- name:  validate_primary_cp
-- scope: private
-- used to validate the primary contact point for PHONE type.
-- After the contact_points are created, query the database to
-- see if there are at least one primary contact point for the
-- contact_type = 'PHONE'. If there are not, update 1 primary
-- contact as primary contact point. This will be done by a new
-- procedure validate_primary_cp.
--
-- Added by Ajoy, bugfix : 2098158
--------------------------------------------------------
procedure validate_primary_cp( pI IN OUT NOCOPY leadImpType,
                               G_return_status OUT NOCOPY varchar2) is

  l_no_of_primary_cps NUMBER;

begin
    SELECT  COUNT(*) NO_PRIMARY_CPS
    INTO    l_no_of_primary_cps
    FROM    HZ_CONTACT_POINTS
    WHERE   CONTACT_POINT_TYPE = 'PHONE' AND PRIMARY_FLAG = 'Y'
    AND     OWNER_TABLE_NAME = 'HZ_PARTIES' AND OWNER_TABLE_ID = pI.rel_party_id;

    write_log(3, 'AC : No. of primary contact points found ' || l_no_of_primary_cps || ' for part rel id : ' || pI.rel_party_id);

    -- Validation
    If l_no_of_primary_cps < 1 then
        UPDATE HZ_CONTACT_POINTS
        SET PRIMARY_FLAG = 'Y'
        WHERE owner_table_name = 'HZ_PARTIES'
        AND contact_point_type = 'PHONE'
        AND owner_table_id = pI.rel_party_id
        AND ROWNUM = 1; --to update 1 row

        write_log(3, 'Primary contact point is set from validate_primary_cp API');
  end if;
end validate_primary_cp;


--------------------------------------------------------
-- name: do_assign_flex
-- scope: private
-- assign the Recs with flex values
-- note: currently, the following entities are only supported
-- 1. HZ_PARTIES
-- 2. HZ_LOCATIONS
-- 3. HZ_CONTACT_POINTS
-- 4. HZ_PARTY_SITES
-- 5. HZ_ORG_CONTACTS
-- 6. AS_SALES_LEADS
-- 7. AS_SALES_LEAD_LINES
-- 8. AS_SALES_LEAD_CONTACTS
--------------------------------------------------------
procedure do_assign_flex (
              pHzpRec  in OUT NOCOPY hz_party_v2pub.party_rec_type,
              pHzlRec  in OUT NOCOPY hz_location_v2pub.location_rec_type,
              pHzcpRec in OUT NOCOPY hz_contact_point_v2pub.contact_point_rec_type,
              pHzpsRec in OUT NOCOPY hz_party_site_v2pub.party_site_rec_type,
              pHzocRec in OUT NOCOPY hz_party_contact_v2pub.org_contact_rec_type,
              -- pHocrRec in out hz_party_pub.org_contact_role_rec_type,
              pAsslRec in OUT NOCOPY as_sales_leads_pub.sales_lead_rec_type,
              pAssllTbl in OUT NOCOPY as_sales_leads_pub.sales_lead_line_tbl_type,
              pAsslcTbl in OUT NOCOPY as_sales_leads_pub.sales_lead_contact_tbl_type,
              pEntity  in varchar2,
              pIId     in Number,
              G_return_status OUT NOCOPY varchar2)
IS
    Cursor cGetFlex is
    Select attr_val_category, attr_val_1, attr_val_2,
           attr_val_3, attr_val_4, attr_val_5, attr_val_6,
           attr_val_7, attr_val_8, attr_val_9, attr_val_10,
           attr_val_11, attr_val_12, attr_val_13, attr_val_14,
           attr_val_15, attr_val_16, attr_val_17, attr_val_18,
           attr_val_19, attr_val_20, attr_val_21, attr_val_22,
           attr_val_23, attr_val_24-- , gattr_val_category,
           -- gattr_val_1, gattr_val_2, gattr_val_4, gattr_val_3,
           -- gattr_val_5, gattr_val_6, gattr_val_7, gattr_val_8,
           -- gattr_val_9, gattr_val_10, gattr_val_11, gattr_val_12,
           -- gattr_val_13, gattr_val_14, gattr_val_15, gattr_val_16,
           -- gattr_val_17, gattr_val_18, gattr_val_19, gattr_val_20
    From as_imp_sl_flex
    Where import_interface_id =   pIId
      and entity_name = pEntity;
    l_index NUMBER := 1;

BEGIN
    For I in cGetFlex Loop
        if (pEntity = 'HZ_PARTIES') then
            pHzpRec.attribute_category := I.attr_val_category;
            pHzpRec.attribute1 := I.attr_val_1;
            pHzpRec.attribute2 := I.attr_val_2;
            pHzpRec.attribute3 := I.attr_val_3;
            pHzpRec.attribute4 := I.attr_val_4;
            pHzpRec.attribute5 := I.attr_val_5;
            pHzpRec.attribute6 := I.attr_val_6;
            pHzpRec.attribute7 := I.attr_val_7;
            pHzpRec.attribute8 := I.attr_val_8;
            pHzpRec.attribute9 := I.attr_val_9;
            pHzpRec.attribute10 := I.attr_val_10;
            pHzpRec.attribute11 := I.attr_val_11;
            pHzpRec.attribute12 := I.attr_val_12;
            pHzpRec.attribute13 := I.attr_val_13;
            pHzpRec.attribute14 := I.attr_val_14;
            pHzpRec.attribute15 := I.attr_val_15;
            pHzpRec.attribute16 := I.attr_val_16;
            pHzpRec.attribute17 := I.attr_val_17;
            pHzpRec.attribute18 := I.attr_val_18;
            pHzpRec.attribute19 := I.attr_val_19;
            pHzpRec.attribute20 := I.attr_val_20;
            pHzpRec.attribute21 := I.attr_val_21;
            pHzpRec.attribute22 := I.attr_val_22;
            pHzpRec.attribute23 :=  I.attr_val_23;
            pHzpRec.attribute24 := I.attr_val_24;
            -- pHzpRec.global_attribute_category:= I.gattr_val_category;
            -- pHzpRec.global_attribute1 := I.gattr_val_1;
            -- pHzpRec.global_attribute2 := I.gattr_val_2;
            -- pHzpRec.global_attribute3 := I.gattr_val_3;
            -- pHzpRec.global_attribute4 := I.gattr_val_4;
            -- pHzpRec.global_attribute5 := I.gattr_val_5;
            -- pHzpRec.global_attribute6 := I.gattr_val_6;
            -- pHzpRec.global_attribute7 := I.gattr_val_7;
            -- pHzpRec.global_attribute8 := I.gattr_val_8;
            -- pHzpRec.global_attribute9 := I.gattr_val_9;
            -- pHzpRec.global_attribute10 := I.gattr_val_10;
            -- pHzpRec.global_attribute11 := I.gattr_val_11;
            -- pHzpRec.global_attribute12 := I.gattr_val_12;
            -- pHzpRec.global_attribute13 := I.gattr_val_13;
            -- pHzpRec.global_attribute14 := I.gattr_val_14;
            -- pHzpRec.global_attribute15 := I.gattr_val_15;
            -- pHzpRec.global_attribute16 := I.gattr_val_16;
            -- pHzpRec.global_attribute17 := I.gattr_val_17;
            -- pHzpRec.global_attribute18 := I.gattr_val_18;
            -- pHzpRec.global_attribute19 := I.gattr_val_19;
            -- pHzpRec.global_attribute20 := I.gattr_val_20;
        end if;
        if (pEntity = 'HZ_LOCATIONS') then
            pHzlRec.attribute_category := I.attr_val_category;
            pHzlRec.attribute1 := I.attr_val_1;
            pHzlRec.attribute2 := I.attr_val_2;
            pHzlRec.attribute3 := I.attr_val_3;
            pHzlRec.attribute4 := I.attr_val_4;
            pHzlRec.attribute5 := I.attr_val_5;
            pHzlRec.attribute6 := I.attr_val_6;
            pHzlRec.attribute7 := I.attr_val_7;
            pHzlRec.attribute8 := I.attr_val_8;
            pHzlRec.attribute9 := I.attr_val_9;
            pHzlRec.attribute10 := I.attr_val_10;
            pHzlRec.attribute11 := I.attr_val_11;
            pHzlRec.attribute12 := I.attr_val_12;
            pHzlRec.attribute13 := I.attr_val_13;
            pHzlRec.attribute14 := I.attr_val_14;
            pHzlRec.attribute15 := I.attr_val_15;
            pHzlRec.attribute16 := I.attr_val_16;
            pHzlRec.attribute17 := I.attr_val_17;
            pHzlRec.attribute18 := I.attr_val_18;
            pHzlRec.attribute19 := I.attr_val_19;
            pHzlRec.attribute20 := I.attr_val_20;
            -- pHzlRec.global_attribute_category:= I.gattr_val_category;
            -- pHzlRec.global_attribute1 := I.gattr_val_1;
            -- pHzlRec.global_attribute2 := I.gattr_val_2;
            -- pHzlRec.global_attribute3 := I.gattr_val_3;
            -- pHzlRec.global_attribute4 := I.gattr_val_4;
            -- pHzlRec.global_attribute5 := I.gattr_val_5;
            -- pHzlRec.global_attribute6 := I.gattr_val_6;
            -- pHzlRec.global_attribute7 := I.gattr_val_7;
            -- pHzlRec.global_attribute8 := I.gattr_val_8;
            -- pHzlRec.global_attribute9 := I.gattr_val_9;
            -- pHzlRec.global_attribute10 := I.gattr_val_10;
            -- pHzlRec.global_attribute11 := I.gattr_val_11;
            -- pHzlRec.global_attribute12 := I.gattr_val_12;
            -- pHzlRec.global_attribute13 := I.gattr_val_13;
            -- pHzlRec.global_attribute14 := I.gattr_val_14;
            -- pHzlRec.global_attribute15 := I.gattr_val_15;
            -- pHzlRec.global_attribute16 := I.gattr_val_16;
            -- pHzlRec.global_attribute17 := I.gattr_val_17;
            -- pHzlRec.global_attribute18 := I.gattr_val_18;
            -- pHzlRec.global_attribute19 := I.gattr_val_19;
            -- pHzlRec.global_attribute20 := I.gattr_val_20;
        end if;
        if (pEntity = 'HZ_CONTACT_POINTS') then
            pHzcpRec.attribute_category := I.attr_val_category;
            pHzcpRec.attribute1 := I.attr_val_1;
            pHzcpRec.attribute2 := I.attr_val_2;
            pHzcpRec.attribute3 := I.attr_val_3;
            pHzcpRec.attribute4 := I.attr_val_4;
            pHzcpRec.attribute5 := I.attr_val_5;
            pHzcpRec.attribute6 := I.attr_val_6;
            pHzcpRec.attribute7 := I.attr_val_7;
            pHzcpRec.attribute8 := I.attr_val_8;
            pHzcpRec.attribute9 := I.attr_val_9;
            pHzcpRec.attribute10 := I.attr_val_10;
            pHzcpRec.attribute11 := I.attr_val_11;
            pHzcpRec.attribute12 := I.attr_val_12;
            pHzcpRec.attribute13 := I.attr_val_13;
            pHzcpRec.attribute14 := I.attr_val_14;
            pHzcpRec.attribute15 := I.attr_val_15;
            pHzcpRec.attribute16 := I.attr_val_16;
            pHzcpRec.attribute17 := I.attr_val_17;
            pHzcpRec.attribute18 := I.attr_val_18;
            pHzcpRec.attribute19 := I.attr_val_19;
            pHzcpRec.attribute20 := I.attr_val_20;
            -- pHzcpRec.global_attribute_category:= I.gattr_val_category;
            -- pHzcpRec.global_attribute1 := I.gattr_val_1;
            -- pHzcpRec.global_attribute2 := I.gattr_val_2;
            -- pHzcpRec.global_attribute3 := I.gattr_val_3;
            -- pHzcpRec.global_attribute4 := I.gattr_val_4;
            -- pHzcpRec.global_attribute5 := I.gattr_val_5;
            -- pHzcpRec.global_attribute6 := I.gattr_val_6;
            -- pHzcpRec.global_attribute7 := I.gattr_val_7;
            -- pHzcpRec.global_attribute8 := I.gattr_val_8;
            -- pHzcpRec.global_attribute9 := I.gattr_val_9;
            -- pHzcpRec.global_attribute10 := I.gattr_val_10;
            -- pHzcpRec.global_attribute11 := I.gattr_val_11;
            -- pHzcpRec.global_attribute12 := I.gattr_val_12;
            -- pHzcpRec.global_attribute13 := I.gattr_val_13;
            -- pHzcpRec.global_attribute14 := I.gattr_val_14;
            -- pHzcpRec.global_attribute15 := I.gattr_val_15;
            -- pHzcpRec.global_attribute16 := I.gattr_val_16;
            -- pHzcpRec.global_attribute17 := I.gattr_val_17;
            -- pHzcpRec.global_attribute18 := I.gattr_val_18;
            -- pHzcpRec.global_attribute19 := I.gattr_val_19;
            -- pHzcpRec.global_attribute20 := I.gattr_val_20;
        end if;
        if (pEntity = 'HZ_PARTY_SITES') then
            pHzpsRec.attribute_category := I.attr_val_category;
            pHzpsRec.attribute1 := I.attr_val_1;
            pHzpsRec.attribute2 := I.attr_val_2;
            pHzpsRec.attribute3 := I.attr_val_3;
            pHzpsRec.attribute4 := I.attr_val_4;
            pHzpsRec.attribute5 := I.attr_val_5;
            pHzpsRec.attribute6 := I.attr_val_6;
            pHzpsRec.attribute7 := I.attr_val_7;
            pHzpsRec.attribute8 := I.attr_val_8;
            pHzpsRec.attribute9 := I.attr_val_9;
            pHzpsRec.attribute10 := I.attr_val_10;
            pHzpsRec.attribute11 := I.attr_val_11;
            pHzpsRec.attribute12 := I.attr_val_12;
            pHzpsRec.attribute13 := I.attr_val_13;
            pHzpsRec.attribute14 := I.attr_val_14;
            pHzpsRec.attribute15 := I.attr_val_15;
            pHzpsRec.attribute16 := I.attr_val_16;
            pHzpsRec.attribute17 := I.attr_val_17;
            pHzpsRec.attribute18 := I.attr_val_18;
            pHzpsRec.attribute19 := I.attr_val_19;
            pHzpsRec.attribute20 := I.attr_val_20;
            -- pHzpsRec.global_attribute_category:= I.gattr_val_category;
            -- pHzpsRec.global_attribute1 := I.gattr_val_1;
            -- pHzpsRec.global_attribute2 := I.gattr_val_2;
            -- pHzpsRec.global_attribute3 := I.gattr_val_3;
            -- pHzpsRec.global_attribute4 := I.gattr_val_4;
            -- pHzpsRec.global_attribute5 := I.gattr_val_5;
            -- pHzpsRec.global_attribute6 := I.gattr_val_6;
            -- pHzpsRec.global_attribute7 := I.gattr_val_7;
            -- pHzpsRec.global_attribute8 := I.gattr_val_8;
            -- pHzpsRec.global_attribute9 := I.gattr_val_9;
            -- pHzpsRec.global_attribute10 := I.gattr_val_10;
            -- pHzpsRec.global_attribute11 := I.gattr_val_11;
            -- pHzpsRec.global_attribute12 := I.gattr_val_12;
            -- -- pHzpsRec.global_attribute13 := I.gattr_val_13;
            -- pHzpsRec.global_attribute14 := I.gattr_val_14;
            -- pHzpsRec.global_attribute15 := I.gattr_val_15;
            -- pHzpsRec.global_attribute16 := I.gattr_val_16;
            -- pHzpsRec.global_attribute17 := I.gattr_val_17;
            -- pHzpsRec.global_attribute18 := I.gattr_val_18;
            -- pHzpsRec.global_attribute19 := I.gattr_val_19;
            -- pHzpsRec.global_attribute20 := I.gattr_val_20;
        end if;
        if (pEntity = 'HZ_ORG_CONTACTS') then
            pHzocRec.attribute_category := I.attr_val_category;
            pHzocRec.attribute1 := I.attr_val_1;
            pHzocRec.attribute2 := I.attr_val_2;
            pHzocRec.attribute3 := I.attr_val_3;
            pHzocRec.attribute4 := I.attr_val_4;
            pHzocRec.attribute5 := I.attr_val_5;
            pHzocRec.attribute6 := I.attr_val_6;
            pHzocRec.attribute7 := I.attr_val_7;
            pHzocRec.attribute8 := I.attr_val_8;
            pHzocRec.attribute9 := I.attr_val_9;
            pHzocRec.attribute10 := I.attr_val_10;
            pHzocRec.attribute11 := I.attr_val_11;
            pHzocRec.attribute12 := I.attr_val_12;
            pHzocRec.attribute13 := I.attr_val_13;
            pHzocRec.attribute14 := I.attr_val_14;
            pHzocRec.attribute15 := I.attr_val_15;
            pHzocRec.attribute16 := I.attr_val_16;
            pHzocRec.attribute17 := I.attr_val_17;
            pHzocRec.attribute18 := I.attr_val_18;
            pHzocRec.attribute19 := I.attr_val_19;
            pHzocRec.attribute20 := I.attr_val_20;
            pHzocRec.attribute21 := I.attr_val_21;
            pHzocRec.attribute22 := I.attr_val_22;
            pHzocRec.attribute23 :=  I.attr_val_23;
            pHzocRec.attribute24 := I.attr_val_24;
            -- pHzocRec.global_attribute_category:= I.gattr_val_category;
            -- pHzocRec.global_attribute1 := I.gattr_val_1;
            -- pHzocRec.global_attribute2 := I.gattr_val_2;
            -- pHzocRec.global_attribute3 := I.gattr_val_3;
            -- pHzocRec.global_attribute4 := I.gattr_val_4;
            -- pHzocRec.global_attribute5 := I.gattr_val_5;
            -- pHzocRec.global_attribute6 := I.gattr_val_6;
            -- pHzocRec.global_attribute7 := I.gattr_val_7;
            -- pHzocRec.global_attribute8 := I.gattr_val_8;
            -- pHzocRec.global_attribute9 := I.gattr_val_9;
            -- pHzocRec.global_attribute10 := I.gattr_val_10;
            -- pHzocRec.global_attribute11 := I.gattr_val_11;
            -- pHzocRec.global_attribute12 := I.gattr_val_12;
            -- pHzocRec.global_attribute13 := I.gattr_val_13;
            -- pHzocRec.global_attribute14 := I.gattr_val_14;
            -- pHzocRec.global_attribute15 := I.gattr_val_15;
            -- pHzocRec.global_attribute16 := I.gattr_val_16;
            -- pHzocRec.global_attribute17 := I.gattr_val_17;
            -- pHzocRec.global_attribute18 := I.gattr_val_18;
            -- pHzocRec.global_attribute19 := I.gattr_val_19;
            -- pHzocRec.global_attribute20 := I.gattr_val_20;
        end if;
        /* *** ffang 082001, HZ_ORG_CONTACT_ROLES' flexfileds are going to be
               obsolete by TCA
        if (pEntity = 'HZ_ORG_CONTACT_ROLES') then
            pHocrRec.attribute_category := I.attr_val_category;
            pHocrRec.attribute1 := I.attr_val_1;
            pHocrRec.attribute2 := I.attr_val_2;
            pHocrRec.attribute3 := I.attr_val_3;
            pHocrRec.attribute4 := I.attr_val_4;
            pHocrRec.attribute5 := I.attr_val_5;
            pHocrRec.attribute6 := I.attr_val_6;
            pHocrRec.attribute7 := I.attr_val_7;
            pHocrRec.attribute8 := I.attr_val_8;
            pHocrRec.attribute9 := I.attr_val_9;
            pHocrRec.attribute10 := I.attr_val_10;
            pHocrRec.attribute11 := I.attr_val_11;
            pHocrRec.attribute12 := I.attr_val_12;
            pHocrRec.attribute13 := I.attr_val_13;
            pHocrRec.attribute14 := I.attr_val_14;
            pHocrRec.attribute15 := I.attr_val_15;
        end if;
        *** */
        if (pEntity = 'AS_SALES_LEADS') then
            pAsslRec.attribute_category := I.attr_val_category;
            pAsslRec.attribute1 := I.attr_val_1;
            pAsslRec.attribute2 := I.attr_val_2;
            pAsslRec.attribute3 := I.attr_val_3;
            pAsslRec.attribute4 := I.attr_val_4;
            pAsslRec.attribute5 := I.attr_val_5;
            pAsslRec.attribute6 := I.attr_val_6;
            pAsslRec.attribute7 := I.attr_val_7;
            pAsslRec.attribute8 := I.attr_val_8;
            pAsslRec.attribute9 := I.attr_val_9;
            pAsslRec.attribute10 := I.attr_val_10;
            pAsslRec.attribute11 := I.attr_val_11;
            pAsslRec.attribute12 := I.attr_val_12;
            pAsslRec.attribute13 := I.attr_val_13;
            pAsslRec.attribute14 := I.attr_val_14;
            pAsslRec.attribute15 := I.attr_val_15;
        end if;
        if (pEntity = 'AS_SALES_LEAD_LINES') then
            pAssllTbl(l_index).attribute_category := I.attr_val_category;
            pAssllTbl(l_index).attribute1 := I.attr_val_1;
            pAssllTbl(l_index).attribute2 := I.attr_val_2;
            pAssllTbl(l_index).attribute3 := I.attr_val_3;
            pAssllTbl(l_index).attribute4 := I.attr_val_4;
            pAssllTbl(l_index).attribute5 := I.attr_val_5;
            pAssllTbl(l_index).attribute6 := I.attr_val_6;
            pAssllTbl(l_index).attribute7 := I.attr_val_7;
            pAssllTbl(l_index).attribute8 := I.attr_val_8;
            pAssllTbl(l_index).attribute9 := I.attr_val_9;
            pAssllTbl(l_index).attribute10 := I.attr_val_10;
            pAssllTbl(l_index).attribute11 := I.attr_val_11;
            pAssllTbl(l_index).attribute12 := I.attr_val_12;
            pAssllTbl(l_index).attribute13 := I.attr_val_13;
            pAssllTbl(l_index).attribute14 := I.attr_val_14;
            pAssllTbl(l_index).attribute15 := I.attr_val_15;
        end if;
        if (pEntity = 'AS_SALES_LEAD_CONTACTS') then
            pAsslcTbl(l_index).attribute_category := I.attr_val_category;
            pAsslcTbl(l_index).attribute1 := I.attr_val_1;
            pAsslcTbl(l_index).attribute2 := I.attr_val_2;
            pAsslcTbl(l_index).attribute3 := I.attr_val_3;
            pAsslcTbl(l_index).attribute4 := I.attr_val_4;
            pAsslcTbl(l_index).attribute5 := I.attr_val_5;
            pAsslcTbl(l_index).attribute6 := I.attr_val_6;
            pAsslcTbl(l_index).attribute7 := I.attr_val_7;
            pAsslcTbl(l_index).attribute8 := I.attr_val_8;
            pAsslcTbl(l_index).attribute9 := I.attr_val_9;
            pAsslcTbl(l_index).attribute10 := I.attr_val_10;
            pAsslcTbl(l_index).attribute11 := I.attr_val_11;
            pAsslcTbl(l_index).attribute12 := I.attr_val_12;
            pAsslcTbl(l_index).attribute13 := I.attr_val_13;
            pAsslcTbl(l_index).attribute14 := I.attr_val_14;
            pAsslcTbl(l_index).attribute15 := I.attr_val_15;
        end if;

        l_index := l_index + 1;
    End Loop;
    G_return_status :=  FND_API.G_RET_STS_SUCCESS ;

    Exception
        when NO_DATA_FOUND then
            G_return_status :=  FND_API.G_RET_STS_SUCCESS ;
        when others then
            G_return_status := FND_API.G_RET_STS_ERROR;
            write_log(2, sqlerrm);
End do_assign_flex;

--------------------------------------------------------
-- name: do_create_person
-- scope: private
-- calls the HZ.create_person API.
-- used to insert contact or consumer
--------------------------------------------------------
procedure  do_create_person(
            pI IN OUT NOCOPY leadImpType,
            pType IN varchar2,
            G_return_status OUT NOCOPY varchar2)
IS
    l_per_rec   HZ_PARTY_V2PUB.person_rec_type;
    l_profile number;
    l_partyNumber number;
    l_msg_data VARCHAR2(2000);

    -- aanjaria enh tcav2
    -- Dummy
    --l_dummy_rec1 hz_party_v2pub.party_rec_type;
    l_dummy_rec2 hz_location_v2pub.location_rec_type;
    l_dummy_rec3 hz_contact_point_v2pub.contact_point_rec_type;
    l_dummy_rec4 hz_party_site_v2pub.party_site_rec_type;
    l_dummy_rec5 hz_party_contact_v2pub.org_contact_rec_type;
    l_dummy_rec7 as_sales_leads_pub.sales_lead_rec_type;
    l_dummy_tbl8 as_sales_leads_pub.sales_lead_line_tbl_type;
    l_dummy_tbl9 as_sales_leads_pub.sales_lead_contact_tbl_type;

Begin
    -- Assigning HZ_PARTY_V2PUB.person_rec_type
    -- Srikanth March 13th 2001: Per Mrinal, OSO and OTS UI
    -- The current association is
    -- person_title -- person_pre_name_adjunct
    -- second title -- person_academic_title
    -- Though the above assignments is wrong, it is beging followed as to
    -- be consistent with OSO and OTS. The above associations must be changed
    -- to the following at a later date along with data migration script.
    -- l_per_rec.pre_name_adjunct := substr(pI.salutation,1,30);
    -- l_per_rec.title := pI.title;

    l_per_rec.known_as := pI.known_as;
    l_per_rec.known_as2 := pI.known_as2;
    l_per_rec.known_as3 := pI.known_as3;
    l_per_rec.known_as4 := pI.known_as4;
    l_per_rec.known_as5 := pI.known_as5;
--    l_per_rec.tax_name := pI.tax_name;
    -- l_per_rec.middle_name_phonetic :=
    l_per_rec.jgzz_fiscal_code := pI.jgzz_fiscal_code;
    l_per_rec.person_iden_type := pI.person_iden_type;
    l_per_rec.person_identifier := pI.person_identifier;
    l_per_rec.gender:= pI.sex_code; --! hz code does not store this in HP table!
    l_per_rec.party_rec.party_number := pI.party_number;
    l_per_rec.party_rec.validated_flag := pI.parties_validated_flag;
    -- orig_system_reference
    if (pI.orig_system_reference is not null) or
        (pI.orig_system_reference <> FND_API.G_MISS_CHAR) Then
        l_per_rec.party_rec.orig_system_reference := pI.orig_system_reference;
    else
        l_per_rec.party_rec.orig_system_reference := pI.import_interface_id;
    end if;
    l_per_rec.party_rec.status := 'A';
    l_per_rec.party_rec.category_code := pI.customer_category_code;
    l_per_rec.party_rec.salutation := pI.salutation;

    -- SOLIN, bug 4602573
    IF (pType = 'PERSON') THEN
      l_per_rec.person_pre_name_adjunct := substr(pI.title,1,30); --bmuthukr for bug 3737765 added substr to take the first 30 chars
    ELSIF (pType = 'CONTACT') THEN
      l_per_rec.person_pre_name_adjunct := substr(pI.org_cnt_title,1,30);
    END IF;
    -- SOLIN, end

    l_per_rec.person_first_name := pI.first_name;
    l_per_rec.person_middle_name:= pI.middle_initial;
    l_per_rec.person_last_name := pI.last_name;
    l_per_rec.person_name_suffix := pI.person_name_suffix;
    l_per_rec.person_title := pI.salutation;
    l_per_rec.person_academic_title := pI.salutation;
    l_per_rec.person_previous_last_name := pI.person_previous_last_name;
    l_per_rec.person_first_name_phonetic := pI.person_first_name_phonetic;
    l_per_rec.person_last_name_phonetic := pI.person_last_name_phonetic;
    l_per_rec.person_initials := pI.person_initials; --added for enh# 2221805 aanjaria
    l_per_rec.created_by_module := 'AML_LEAD_IMPORT';
    l_per_rec.application_id := 530;

    do_assign_flex (
        l_per_rec.party_rec,
        l_dummy_rec2,
        l_dummy_rec3,
        l_dummy_rec4,
        l_dummy_rec5 ,
        -- l_dummy_rec6 ,
        l_dummy_rec7 ,
        l_dummy_tbl8,
        l_dummy_tbl9,
        'HZ_PARTIES',
        pI.import_interface_id,
        G_return_status
    );
    if G_return_status = FND_API.G_RET_STS_SUCCESS Then
        If (pType = 'PERSON') then
--            l_per_rec.party_rec.customer_key := pI.customer_key;
            HZ_PARTY_V2PUB.create_person (
                p_init_msg_list	   => FND_API.G_FALSE,
                p_person_rec	   => l_per_rec,
                x_return_status	   => G_return_status,
                x_msg_count	   => G_MESG_COUNT,
                x_msg_data         => l_msg_data,
                x_party_id	   => pI.party_id,
                x_party_number     => l_partyNumber,
                x_profile_id       => l_profile
            );
        Elsif (pType = 'CONTACT') then
--            l_per_rec.party_rec.customer_key := pI.contact_key;
            HZ_PARTY_V2PUB.create_person (
                p_init_msg_list	   => FND_API.G_FALSE,
                p_person_rec	   => l_per_rec,
                x_return_status	   => G_return_status,
                x_msg_count	   => G_MESG_COUNT,
                x_msg_data         => l_msg_data,
                x_party_id	   => pI.contact_party_id,
                x_party_number     => l_partyNumber,
                x_profile_id       => l_profile
              );
        Else
            G_return_status := FND_API.G_RET_STS_ERROR;
        End if;
    End If;

    -- If error raise exception
    IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        write_log(3, 'Creating Person failed');
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        If (pType = 'PERSON') then
            write_log (3, 'Person created: '||pI.party_id);
        Elsif (pType = 'CONTACT') then
            write_log (3, 'Contact created: '||pI.contact_party_id);
        END IF;
    END IF;

End do_create_person;

--------------------------------------------------------
-- name: do_contact_preference
-- scope: private
-- calls HZ_CONTACT_POINT_V2PUB.create_contact_preference
-- inserts contact preference for pary and party site
----------------------------------------------------------
procedure do_contact_preference(
            pI IN OUT NOCOPY leadImpType,
            G_return_status OUT NOCOPY varchar2)
IS
    l_res_rec HZ_CONTACT_PREFERENCE_V2PUB.contact_preference_rec_type;
    l_res_id number;
    l_msg_data VARCHAR2(2000);
Begin

    l_res_rec.created_by_module := 'AML_LEAD_IMPORT';
    l_res_rec.application_id := 530;
    l_res_rec.requested_by := 'PARTY';
    l_res_rec.preference_code := 'DO_NOT';

    IF ((pI.addr_do_not_mail_flag is not Null)
        and (upper(pI.addr_do_not_mail_flag) = 'Y'))
    THEN
        Begin
            l_res_id := NULL;
            select contact_preference_id
            into l_res_id
            from hz_contact_preferences
            where contact_level_table_id = pI.party_site_id
              and contact_type = 'MAIL'
              and contact_level_table = 'HZ_PARTY_SITES';

            Exception
                when NO_DATA_FOUND then
                    l_res_rec.contact_type := 'MAIL';
                    l_res_rec.preference_start_date := sysdate;
                    l_res_rec.contact_level_table := 'HZ_PARTY_SITES';
                    l_res_rec.contact_level_table_id:= pI.party_site_id;

		    write_log (3, 'Creating CntPreference: AMAIL');
                    HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference (
                        p_init_msg_list           => FND_API.G_FALSE,
                        p_contact_preference_rec => l_res_rec,
                        x_return_status           => G_return_status,
                        x_msg_count               => G_MESG_COUNT,
                        x_msg_data                => l_msg_data,
                        x_contact_preference_id  => l_res_id
                    );
                    IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        write_log(3, 'Create CntPreference failed');
                    ELSE
                        write_log(3, 'CntPreference created: ' || l_res_id);
                    END IF;
                when others then
                    write_log(3, 'Select on Contact Preference Failed');
                    RAISE FND_API.G_EXC_ERROR;
        End;
    End if;

    IF (pI.cont_do_not_mail_flag is not Null)
       and (upper(pI.cont_do_not_mail_flag) = 'Y')
    THEN
        Begin
            l_res_id := NULL;
            select contact_preference_id
            into l_res_id
            from hz_contact_preferences
            where contact_level_table_id = pI.rel_party_id
              and contact_type = 'MAIL'
              and contact_level_table = 'HZ_PARTIES';

            Exception
                when NO_DATA_FOUND then
                    l_res_rec.contact_type := 'MAIL';
                    l_res_rec.preference_start_date := sysdate;
                    l_res_rec.contact_level_table := 'HZ_PARTIES';
                    -- l_res_rec.subject_id:= pI.contact_party_id;
                    l_res_rec.contact_level_table_id:= pI.rel_party_id;

                    write_log (3, 'Creating CntPreference: CMAIL');
                    HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference (
                        p_init_msg_list	=> FND_API.G_FALSE,
                        p_contact_preference_rec => l_res_rec,
                        x_return_status	=> G_return_status,
                        x_msg_count		    => G_MESG_COUNT,
                        x_msg_data          => l_msg_data,
                        x_contact_preference_id => l_res_id
                    );
                    IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        write_log(3, 'Create CntPreference failed');
                    ELSE
                        write_log(3, 'CntPreference created: ' || l_res_id);
                    END IF;
                when others then
                    RAISE FND_API.G_EXC_ERROR;
        End;
    End if;

    If (pI.do_not_phone_flag is not Null) and
       (upper(pI.do_not_phone_flag) = 'Y') and
       (pI.phone_number is not null)
    then
        Begin
            l_res_id := NULL;
            select contact_preference_id
            into l_res_id
            from hz_contact_preferences
            where contact_level_table_id = pI.rel_party_id
              and contact_type = 'CALL'
              and contact_level_table = 'HZ_PARTIES';

            Exception
                when NO_DATA_FOUND then
                    l_res_rec.contact_type := 'CALL';
                    l_res_rec.preference_start_date := sysdate;
                    l_res_rec.contact_level_table := 'HZ_PARTIES';
                    -- l_res_rec.subject_id:= pI.contact_party_id;
                    l_res_rec.contact_level_table_id:= pI.rel_party_id;

                    write_log (3, 'Creating CntPreference: PHONE');
                    HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference (
                        p_init_msg_list           => FND_API.G_FALSE,
                        p_contact_preference_rec => l_res_rec,
                        x_return_status           => G_return_status,
                        x_msg_count               => G_MESG_COUNT,
                        x_msg_data                => l_msg_data,
                        x_contact_preference_id  => l_res_id
                    );
                    IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        write_log(3, 'Create CntPreference failed');
                    ELSE
                        write_log(3, 'CntPreference created: ' || l_res_id);
                    END IF;
                when others then
                    RAISE FND_API.G_EXC_ERROR;
        End;
        -- SOLIN, bug 4637420
        Begin
            l_res_id := NULL;
            select contact_preference_id
            into l_res_id
            from hz_contact_preferences
            where contact_level_table_id = pI.phone_id
              and contact_type = 'CALL'
              and contact_level_table = 'HZ_CONTACT_POINTS';

            Exception
                when NO_DATA_FOUND then
                    l_res_rec.contact_type := 'CALL';
                    l_res_rec.preference_start_date := sysdate;
                    l_res_rec.contact_level_table := 'HZ_CONTACT_POINTS';
                    -- l_res_rec.subject_id:= pI.contact_party_id;
                    l_res_rec.contact_level_table_id:= pI.phone_id;

                    write_log (3, 'Creating CntPreference: PHONE');
                    HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference (
                        p_init_msg_list           => FND_API.G_FALSE,
                        p_contact_preference_rec  => l_res_rec,
                        x_return_status           => G_return_status,
                        x_msg_count               => G_MESG_COUNT,
                        x_msg_data                => l_msg_data,
                        x_contact_preference_id   => l_res_id
                    );
                    IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        write_log(3, 'Create CntPreference failed');
                    ELSE
                        write_log(3, 'CntPreference created: ' || l_res_id);
                    END IF;
                when others then
                    RAISE FND_API.G_EXC_ERROR;
        End;
        -- SOLIN, end bug 4637420
    End if;

    If (pI.do_not_fax_flag is not Null) and
        (upper(pI.do_not_fax_flag) = 'Y') then
        Begin
            l_res_id := NULL;
            select contact_preference_id
            into l_res_id
            from hz_contact_preferences
            where contact_level_table_id = pI.rel_party_id
              and contact_type = 'FAX'
              and contact_level_table = 'HZ_PARTIES';

            Exception
                when NO_DATA_FOUND then
                    l_res_rec.contact_type := 'FAX';
                    l_res_rec.preference_start_date := sysdate;
                    l_res_rec.contact_level_table := 'HZ_PARTIES';
                    -- l_res_rec.subject_id:= pI.contact_party_id;
                    l_res_rec.contact_level_table_id:= pI.rel_party_id;

                    write_log (3, 'Creating CntPreference: FAX');
                    HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference (
                        p_init_msg_list	=> FND_API.G_FALSE,
                        p_contact_preference_rec => l_res_rec,
                        x_return_status	=> G_return_status,
                        x_msg_count		    => G_MESG_COUNT,
                        x_msg_data          => l_msg_data,
                        x_contact_preference_id => l_res_id
                    );
                    IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        write_log(3, 'Create CntPreference failed');
                    ELSE
                        write_log(3, 'CntPreference created: ' || l_res_id);
                    END IF;
                when others then
                    RAISE FND_API.G_EXC_ERROR;
        End;
    End if;

    If (pI.do_not_email_flag is not Null) and
        (upper(pI.do_not_email_flag) = 'Y') then
        Begin
            l_res_id := NULL;
            select contact_preference_id
            into l_res_id
            from hz_contact_preferences
            where contact_level_table_id = pI.rel_party_id
              and contact_type = 'EMAIL'
              and contact_level_table = 'HZ_PARTIES';

            Exception
                when NO_DATA_FOUND then
                    l_res_rec.contact_type := 'EMAIL';
                    l_res_rec.preference_start_date := sysdate;
                    l_res_rec.contact_level_table := 'HZ_PARTIES';
                    -- l_res_rec.subject_id:= pI.contact_party_id;
                    l_res_rec.contact_level_table_id:= pI.rel_party_id;

                    write_log (3, 'Creating CntPreference: EMAIL');
                    HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference (
                        p_init_msg_list	=> FND_API.G_FALSE,
                        p_contact_preference_rec => l_res_rec,
                        x_return_status	=> G_return_status,
                        x_msg_count		    => G_MESG_COUNT,
                        x_msg_data          => l_msg_data,
                        x_contact_preference_id => l_res_id
                    );
                    IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        write_log(3, 'Create CntPreference failed');
                    ELSE
                        write_log(3, 'CntPreference created: ' || l_res_id);
                    END IF;
                when others then
                    RAISE FND_API.G_EXC_ERROR;
        End;
    End if;
End do_contact_preference;


--------------------------------------------------------
-- name: do_create_contact_points_old
-- scope: private
-- calls HZ_CONTACT_POINT_V2PUB.do_create_contact_points
-- inserts contact point (in as_import_interface) for pary and party site
----------------------------------------------------------
procedure do_create_contact_points_old(
            pI IN OUT NOCOPY leadImpType,
            l_dup_phone IN VARCHAR2,
            l_dup_fax IN VARCHAR2,
	    l_dup_email IN VARCHAR2,
	    l_dup_url IN VARCHAR2,
            G_return_status OUT NOCOPY varchar2)
IS
    l_cp_rec hz_contact_point_v2pub.contact_point_rec_type;
    l_email_rec hz_contact_point_v2pub.email_rec_type;
    l_ph_rec hz_contact_point_v2pub.phone_rec_type;
    l_web_rec hz_contact_point_v2pub.web_rec_type   ;
    l_msg_data VARCHAR2(2000);
    l_cpid number;

    -- Dummy
    l_dummy_rec1 hz_party_v2pub.party_rec_type;
    l_dummy_rec2 hz_location_v2pub.location_rec_type;
    l_dummy_rec3 hz_contact_point_v2pub.contact_point_rec_type;
    l_dummy_rec4 hz_party_site_v2pub.party_site_rec_type;
    l_dummy_rec5 hz_party_contact_v2pub.org_contact_rec_type;
    --l_dummy_rec6 hz_party_pub.org_contact_role_rec_type;
    l_dummy_rec7 as_sales_leads_pub.sales_lead_rec_type;
    l_dummy_tbl8 as_sales_leads_pub.sales_lead_line_tbl_type;
    l_dummy_tbl9 as_sales_leads_pub.sales_lead_contact_tbl_type;

Begin
    -- swkhanna 8/13 - check for duplicate contact_points
    -- cont_pnt_dedupe(pI,l_dup_phone,l_dup_email, l_dup_fax, l_dup_url ) ;
    --dbms_output.put_line('l_dup_phone:'||l_dup_phone);
    --dbms_output.put_line('l_dup_email:'||l_dup_email);
    --dbms_output.put_line('l_dup_fax:'||l_dup_fax);
    --dbms_output.put_line('l_dup_url:'||l_dup_url);

    l_cp_rec.created_by_module := 'AML_LEAD_IMPORT';
    l_cp_rec.application_id := 530;

    l_cp_rec.status := 'A';
    l_cp_rec.owner_table_name      := 'HZ_PARTIES';
    If(pI.party_type = 'ORGANIZATION') Then
        l_cp_rec.owner_table_id      := pI.rel_party_id;
    else
        l_cp_rec.owner_table_id      := pI.party_id;
    END IF;
    -- swkhanna 5/20/02 commented for Bug 2381261
    --l_cp_rec.primary_flag          := 'Y';
    l_cp_rec.orig_system_reference := pI.import_interface_id;
    IF (pI.cnt_pnt_content_source_type is not null and
        pI.cnt_pnt_content_source_type <> FND_API.G_MISS_CHAR)
    THEN
        l_cp_rec.content_source_type := pI.cnt_pnt_content_source_type;
    ELSE
        l_cp_rec.content_source_type := 'USER_ENTERED';
    END IF;

    do_assign_flex (
        l_dummy_rec1,
        l_dummy_rec2,
        l_cp_rec,
        l_dummy_rec4,
        l_dummy_rec5 ,
        -- l_dummy_rec6 ,
        l_dummy_rec7 ,
        l_dummy_tbl8 ,
        l_dummy_tbl9 ,
        'HZ_CONTACT_POINTS',
        pI.import_interface_id,
        G_return_status
    );

    If G_return_status = FND_API.G_RET_STS_SUCCESS Then
      If l_dup_phone = 'N' then
        If (pI.phone_number is not null) then
            l_cp_rec.contact_point_type := 'PHONE';
            -- swkhanna 5/20 for bug 2381261
            IF pI.phone_type = 'GEN' Then
            l_cp_rec.primary_flag          := 'Y';
            END IF;
            l_ph_rec.phone_country_code := pI.phone_country_code;
            l_ph_rec.phone_area_code := pI.area_code;
            l_ph_rec.phone_number := pI.phone_number;
            l_ph_rec.phone_extension := pI.extension;
            l_ph_rec.phone_line_type := pI.phone_type;
            l_ph_rec.phone_calling_calendar := pI.phone_calling_calendar;
--            l_ph_rec.time_zone := pI.cnt_pnt_time_zone;
            l_ph_rec.raw_phone_number := pI.raw_phone_number;

            write_log(3, 'Inserting the phone rec');

            HZ_CONTACT_POINT_V2PUB.create_contact_point (
                p_init_msg_list      => FND_API.G_FALSE,
                p_contact_point_rec => l_cp_rec,
                p_phone_rec          => l_ph_rec,
                x_return_status      => G_return_status,
                x_msg_count          => G_MESG_COUNT,
                x_msg_data           => l_msg_data,
                x_contact_point_id   => l_cpid
            );

            -- ffang 062001, put contact_point_id into phone_id
            IF G_return_status = FND_API.G_RET_STS_SUCCESS Then
                pI.phone_id := l_cpid;
                write_log(3, 'Contact Point created-PHONE: ' || l_cpid);
            ELSE
                write_log(3, 'Contact Point creation faild for PHONE');
                return;
            END IF;
        END IF;
      ELSE
        write_log(3, 'Duplicate PHONE');
      END IF;


       IF l_dup_fax = 'N' then
        If (pI.fax_number is not null) then
            -- swkhanna 5/20 for bug 2381261
            l_cp_rec.primary_flag          := 'N';
            l_cp_rec.contact_point_type := 'PHONE';
            l_ph_rec.phone_line_type := 'FAX';
            l_ph_rec.phone_country_code := pI.fax_country_code;
            l_ph_rec.phone_area_code := pI.fax_area_code;
            l_ph_rec.phone_number := pI.fax_number;
            l_ph_rec.phone_extension := pI.fax_extension;
            l_ph_rec.phone_calling_calendar := pI.phone_calling_calendar;
--            l_ph_rec.time_zone := pI.time_zone;
            l_ph_rec.raw_phone_number := NULL;

            write_log(3, 'Inserting the fax rec');
            HZ_CONTACT_POINT_V2PUB.create_contact_point (
                p_init_msg_list      => FND_API.G_FALSE,
                p_contact_point_rec => l_cp_rec,
                p_phone_rec          => l_ph_rec,
                x_return_status      => G_return_status,
                x_msg_count          => G_MESG_COUNT,
                x_msg_data           => l_msg_data,
                x_contact_point_id   => l_cpid
            );
            IF G_return_status = FND_API.G_RET_STS_SUCCESS Then
                write_log(3, 'Contact Point created-FAX: ' || l_cpid);
            ELSE
                write_log(3, 'Contact Point creation faild for FAX');
                return;
            END IF;
	END IF;
      ELSE
        write_log(3, 'Duplicate FAX');
      END IF;

      If l_dup_email = 'N' then
        If (pI.email_address is not null) then
            -- swkhanna 8/14/02
            l_cp_rec.primary_flag          := 'Y';
            l_cp_rec.contact_point_type    := 'EMAIL';
            l_email_rec.email_format := pI.email_format;
            l_email_rec.email_address := pI.email_address;
            write_log(3, 'Inserting an email rec');

            HZ_CONTACT_POINT_V2PUB.create_contact_point (
                p_init_msg_list      => FND_API.G_FALSE,
                p_contact_point_rec => l_cp_rec,
                p_email_rec          => l_email_rec,
                x_return_status      => G_return_status,
                x_msg_count          => G_MESG_COUNT,
                x_msg_data           => l_msg_data,
                x_contact_point_id   => l_cpid
            );
            IF G_return_status = FND_API.G_RET_STS_SUCCESS Then
                write_log(3, 'Contact Point created-EMAIL: ' || l_cpid);
            ELSE
                write_log(3, 'Contact Point creation faild for EMAIL');
                return;
            END IF;
        End If;
      ELSE
         write_log(3, 'Duplicate EMAIL');
      End If;

      If l_dup_url = 'N' then
        If (pI.url is not null) then
            -- swkhanna 8/14/02
            l_cp_rec.primary_flag          := 'Y';
            l_cp_rec.contact_point_type    := 'WEB';
            l_web_rec.web_type := 'http';
            l_web_rec.url := pI.url;
            write_log(3, 'Inserting an url rec');

            HZ_CONTACT_POINT_V2PUB.create_contact_point (
                p_init_msg_list      => FND_API.G_FALSE,
                p_contact_point_rec => l_cp_rec,
                p_web_rec            => l_web_rec,
                x_return_status      => G_return_status,
                x_msg_count          => G_MESG_COUNT,
                x_msg_data           => l_msg_data,
                x_contact_point_id   => l_cpid
            );
            IF G_return_status = FND_API.G_RET_STS_SUCCESS Then
                write_log(3, 'Contact Point created-URL: ' || l_cpid);
            ELSE
                write_log(3, 'Contact Point creation faild for WEB');
                return;
            END IF;
        End If;
      ELSE
        write_log(3, 'Duplicate URL');
      End If;
    End If;
End do_create_contact_points_old;


--------------------------------------------------------
-- name: do_create_contact_points
-- scope: private
-- calls HZ_CONTACT_POINT_V2PUB.do_create_contact_points
-- inserts contact point (in as_imp_cnt_pnt_interface) for pary and party site
----------------------------------------------------------
procedure do_create_contact_points(
            pI IN OUT NOCOPY leadImpType,
            pCP IN OUT NOCOPY cntPntType,
            owner_type IN varchar2,
            G_return_status OUT NOCOPY varchar2)
IS
    l_cp_rec hz_contact_point_v2pub.contact_point_rec_type;
    l_email_rec hz_contact_point_v2pub.email_rec_type;
    l_ph_rec hz_contact_point_v2pub.phone_rec_type;
    l_web_rec hz_contact_point_v2pub.web_rec_type   ;
    l_msg_data VARCHAR2(2000);
    l_cpid number;

    l_dup_phone varchar2(1):= 'N';
    l_dup_email varchar2(1):= 'N';
    l_dup_fax   varchar2(1):= 'N';
    l_dup_url   varchar2(1):= 'N';
Begin


    -- swkhanna 8/13 - check for duplicate contact_points
    cont_pnt_dedupe(pI,l_dup_phone,l_dup_email, l_dup_fax, l_dup_url ) ;

    --dbms_output.put_line('l_dup_phone:'||l_dup_phone);
    --dbms_output.put_line('l_dup_email:'||l_dup_email);
    --dbms_output.put_line('l_dup_fax:'||l_dup_fax);
    --dbms_output.put_line('l_dup_url:'||l_dup_url);

    -- fill up contact_point_rec_type

    l_cp_rec.created_by_module := 'AML_LEAD_IMPORT';
    l_cp_rec.application_id := 530;

    l_cp_rec.status := 'A';
    -- ffang 082101, is it OK to use interface table's owner_table_name and
    -- owner_table_id?
    IF (pCP.owner_table_name is not null and
        pCP.owner_table_name <> FND_API.G_MISS_CHAR)
    THEN
        l_cp_rec.owner_table_name      := pCP.owner_table_name;
    ELSE
        l_cp_rec.owner_table_name      := 'HZ_PARTIES';
    END IF;
    IF (pCP.owner_table_id is not null and
        pCP.owner_table_id <> FND_API.G_MISS_NUM)
    THEN
        l_cp_rec.owner_table_id        := pCP.owner_table_id;
    ELSE
        If(pI.party_type = 'ORGANIZATION') Then
            l_cp_rec.owner_table_id      := pI.rel_party_id;
        else
            l_cp_rec.owner_table_id      := pI.party_id;
        End if;
    END IF;
    IF (pCP.primary_flag is not null AND
        pCP.primary_flag <> FND_API.G_MISS_CHAR) THEN
        l_cp_rec.primary_flag      := pCP.primary_flag;
    ELSE
        l_cp_rec.primary_flag      := 'N';
    END IF;
    IF (pCP.orig_system_reference is not NULL AND
	   pCP.orig_system_reference <> FND_API.G_MISS_CHAR) THEN
        l_cp_rec.orig_system_reference := pCP.orig_system_reference;
    ELSE
        l_cp_rec.orig_system_reference := pI.import_interface_id;
    END IF;
    IF (pCP.content_source_type is not null and
        pCP.content_source_type <> FND_API.G_MISS_CHAR)
    THEN
        l_cp_rec.content_source_type := pCP.content_source_type;
    ELSE
        l_cp_rec.content_source_type := 'USER_ENTERED';
    END IF;
    l_cp_rec.contact_point_type:= pCP.contact_point_type; --'PHONE';

    -- ffang 091301, since do_create_contact_points_old has done do_assign_flex,
    -- we don't need this here
/*
    do_assign_flex (
        l_dummy_rec1,
        l_dummy_rec2,
        l_cp_rec,
        l_dummy_rec4,
        l_dummy_rec5 ,
        -- l_dummy_rec6 ,
        l_dummy_rec7 ,
        l_dummy_tbl8 ,
        l_dummy_tbl9 ,
        'HZ_CONTACT_POINTS',
        pI.import_interface_id,
        G_return_status
    );
*/

    write_log (3, pCP.contact_point_type ||'-'||pCP.phone_line_type||':'
                  ||G_return_status);
    -- ffang 082101, should use contact_point_type and phone_line_type to
    -- determine what's the type.
    -- If G_return_status = FND_API.G_RET_STS_SUCCESS Then
        -- If (pI.phone_number is not null) then
        IF pCP.contact_point_type = 'PHONE' THEN

            IF pCP.phone_line_type <> 'FAX' THEN    -- 'PHONE'
               --swkhanna 8/14/02
              IF l_dup_phone = 'N' THEN
                -- l_cp_rec.contact_point_type:= 'PHONE';
                -- l_cp_rec.status  := PI.phone_status;
                l_ph_rec.phone_country_code := pCP.phone_country_code;
                l_ph_rec.phone_area_code := pCP.phone_area_code; --pI.area_code;
                l_ph_rec.phone_number := pCP.phone_number;  --pI.phone_number;
                l_ph_rec.phone_extension := pCP.phone_extension; --pI.extension;
                l_ph_rec.phone_line_type:= pCP.phone_line_type; --pI.phone_type;
                l_ph_rec.phone_calling_calendar := pCP.phone_calling_calendar;
                -- l_ph_rec.timezone_id := pCP.timezone_id;
--                l_ph_rec.time_zone := pCP.time_zone;
                l_ph_rec.raw_phone_number := pCP.raw_phone_number;

                write_log(3, 'Inserting the phone rec');
                HZ_CONTACT_POINT_V2PUB.create_contact_point (
                    p_init_msg_list      => FND_API.G_FALSE,
                    p_contact_point_rec => l_cp_rec,
                    p_phone_rec          => l_ph_rec,
                    x_return_status      => G_return_status,
                    x_msg_count          => G_MESG_COUNT,
                    x_msg_data           => l_msg_data,
                    x_contact_point_id   => l_cpid
                );
                -- ffang 062001, put contact_point_id into phone_id
                IF G_return_status = FND_API.G_RET_STS_SUCCESS Then
                    pI.phone_id := l_cpid;
                    write_log(3, 'Contact Point created: ' || l_cpid);
                END IF;
              END IF; -- if l_dup_phone = N
            ELSIF pCP.phone_line_type = 'FAX' THEN    -- 'FAX'
                 --swkhanna 8/14/02
                 IF l_dup_fax = 'N' THEN
                -- If (pI.fax_number is not null) then
                -- ffang 071601, bug1810279, for fax number,
                -- contact_point_type should be 'PHONE' and
                -- phone_line_type should be 'FAX'
                -- l_ph_rec.phone_line_type := pI.phone_type;
                -- l_cp_rec.contact_point_type := 'FAX';
                -- l_cp_rec.contact_point_type:= 'PHONE';
                -- l_cp_rec.status  := PI.phone_status;
                l_ph_rec.phone_country_code := pCP.phone_country_code;
                l_ph_rec.phone_area_code := pCP.phone_area_code; --pI.area_code;
                l_ph_rec.phone_number := pCP.phone_number;  --pI.phone_number;
                l_ph_rec.phone_extension := pCP.phone_extension; --pI.extension;
                l_ph_rec.phone_line_type:= pCP.phone_line_type; --'FAX';
                l_ph_rec.phone_calling_calendar := pCP.phone_calling_calendar;
                --l_ph_rec.timezone_id := pCP.timezone_id;
--                l_ph_rec.time_zone := pCP.time_zone;
                l_ph_rec.raw_phone_number := pCP.raw_phone_number;

                write_log(3, 'Inserting the fax rec');
                HZ_CONTACT_POINT_V2PUB.create_contact_point (
                    p_init_msg_list      => FND_API.G_FALSE,
                    p_contact_point_rec => l_cp_rec,
                    p_phone_rec          => l_ph_rec,
                    x_return_status      => G_return_status,
                    x_msg_count          => G_MESG_COUNT,
                    x_msg_data           => l_msg_data,
                    x_contact_point_id   => l_cpid
                );
                IF G_return_status = FND_API.G_RET_STS_SUCCESS Then
                    write_log(3, 'Contact Point created: ' || l_cpid);
                END IF;
            End If;
            End If;
        ELSIF pCP.contact_point_type = 'EMAIL' THEN     -- 'EMAIL'
             IF l_dup_email = 'N' THEN
            -- If (pI.email_address is not null) then
            -- l_cp_rec.contact_point_type := 'EMAIL';
            l_email_rec.email_format := pCP.email_format;
            l_email_rec.email_address := pCP.email_address;  --pI.email_address;

            write_log(3, 'Inserting an email rec');
            HZ_CONTACT_POINT_V2PUB.create_contact_point (
                p_init_msg_list      => FND_API.G_FALSE,
                p_contact_point_rec => l_cp_rec,
                p_email_rec          => l_email_rec,
                x_return_status      => G_return_status,
                x_msg_count          => G_MESG_COUNT,
                x_msg_data           => l_msg_data,
                x_contact_point_id   => l_cpid
            );
            IF G_return_status = FND_API.G_RET_STS_SUCCESS Then
                write_log(3, 'Contact Point created: ' || l_cpid);
            END IF;
            END IF;
            -- End If;
        ELSIF pCP.contact_point_type = 'WEB' THEN      -- 'WEB'
            IF l_dup_url = 'N' THEN
            -- If (pI.url is not null) then
            -- l_cp_rec.contact_point_type    := 'WEB';
            l_web_rec.web_type := pCP.web_type;   -- 'http';
            l_web_rec.url := pCP.url;             -- pI.url;

            write_log(3, 'Inserting an url rec');
            HZ_CONTACT_POINT_V2PUB.create_contact_point (
                p_init_msg_list      => FND_API.G_FALSE,
                p_contact_point_rec => l_cp_rec,
                p_web_rec            => l_web_rec,
                x_return_status      => G_return_status,
                x_msg_count          => G_MESG_COUNT,
                x_msg_data           => l_msg_data,
                x_contact_point_id   => l_cpid
            );
            IF G_return_status = FND_API.G_RET_STS_SUCCESS Then
                write_log(3, 'Contact Point created: ' || l_cpid);
            END IF;
            -- End If;
        End If;
        End If;
    -- End If;
End do_create_contact_points;

----------------------------------------------------------
-- name:  do_create_location
-- scope: private
-- calls  HZ_LOCATION_V2PUB.create_location
-- inserts location details
----------------------------------------------------------
procedure do_create_location(
              pI IN OUT NOCOPY leadImpType,
              G_return_status OUT NOCOPY varchar2)
IS
--    aanjaria enh tcav2
    l_location_rec    hz_location_v2pub.location_rec_type;
    l_msg_data VARCHAR2(2000);

    -- Dummy
    l_dummy_rec1 hz_party_v2pub.party_rec_type;
    --l_dummy_rec2 hz_location_pub.location_rec_type;
    l_dummy_rec3 hz_contact_point_v2pub.contact_point_rec_type;
    l_dummy_rec4 hz_party_site_v2pub.party_site_rec_type;
    l_dummy_rec5 hz_party_contact_v2pub.org_contact_rec_type;
    l_dummy_rec6 hz_party_contact_v2pub.org_contact_role_rec_type;
    l_dummy_rec7 as_sales_leads_pub.sales_lead_rec_type;
    l_dummy_tbl8 as_sales_leads_pub.sales_lead_line_tbl_type;
    l_dummy_tbl9 as_sales_leads_pub.sales_lead_contact_tbl_type;

Begin

    -- Assigning the HZ_LOCATION_PUB.LOCATION_REC_TYPE
    l_location_rec.orig_system_reference := pI.import_interface_id;
    l_location_rec.country := pI.country;
    l_location_rec.address1 := pI.address1;
    l_location_rec.address2 := pI.address2;
    l_location_rec.address3 := pI.address3;
    l_location_rec.address4 := pI.address4;
    l_location_rec.city := pI.city;
    l_location_rec.postal_code := pI.postal_code;
    l_location_rec.state := pI.state;
    l_location_rec.province := pI.province;
    l_location_rec.county := pI.county;
    l_location_rec.address_style := pI.address_style;
    l_location_rec.validated_flag := pI.loc_validated_flag;
    l_location_rec.address_lines_phonetic := pI.address_lines_phonetic;
    -- SOLIN, bug 4602573
    --l_location_rec.po_box_number := pI.po_box_number;
    --l_location_rec.house_number := pI.house_number;
    --l_location_rec.street_suffix := pI.street_suffix;
    --l_location_rec.street := pI.street;
    --l_location_rec.street_number := pI.street_number;
    --l_location_rec.floor := pI.floor;
    --l_location_rec.suite := pI.suite;
    -- SOLIN, end
    l_location_rec.postal_plus4_code := pI.postal_plus4_code;
    l_location_rec.position := pI.position;
    l_location_rec.address_effective_date := pI.address_effective_date;
    l_location_rec.language := pI.language;
    l_location_rec.short_description := pI.short_description;
    l_location_rec.description := pI.loc_description;
    l_location_rec.loc_hierarchy_id := pI.loc_hierarchy_id;
    l_location_rec.sales_tax_geocode := pI.sales_tax_geocode;
    l_location_rec.sales_tax_inside_city_limits :=
                                         pI.sales_tax_inside_city_limits;
    l_location_rec.fa_location_id := pI.fa_location_id;

--    aanjaria enh tcav2
--    l_location_rec.time_zone := pI.time_zone;
--    l_location_rec.address_key := pI.address_key;
    l_location_rec.created_by_module := 'AML_LEAD_IMPORT';
    l_location_rec.application_id := 530;

    IF (pI.content_source_type is not NULL AND
        pI.content_source_type <> FND_API.G_MISS_CHAR)
    THEN
        l_location_rec.content_source_type := pI.content_source_type;
    ELSE
        l_location_rec.content_source_type := 'USER_ENTERED';
    END IF;

    do_assign_flex (
        l_dummy_rec1,
        l_location_rec,
        l_dummy_rec3,
        l_dummy_rec4,
        l_dummy_rec5 ,
        -- l_dummy_rec6 ,
        l_dummy_rec7 ,
        l_dummy_tbl8 ,
        l_dummy_tbl9 ,
        'HZ_LOCATIONS',
        pI.import_interface_id,
        G_return_status
    );

    If G_return_status = FND_API.G_RET_STS_SUCCESS Then
        HZ_LOCATION_V2PUB.create_location (
            p_init_msg_list    => FND_API.G_FALSE,
            p_location_rec     => l_location_rec,
            x_return_status    => G_return_status,
            x_msg_count        => G_MESG_COUNT,
            x_msg_data         => l_msg_data,
            x_location_id      => pI.location_id
        );
        If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
            write_log(3, 'Create location failed');
        ELSE
            write_log(3, 'Location created: ' || pI.location_id);
        END IF;
    End if;
End do_create_location;

----------------------------------------------------------
-- name:  do_create_organization
-- scope: private
-- calls  HZ_LOCATION_V2PUB.create_organization
-- inserts party with party type as ORGANIZATION
----------------------------------------------------------


procedure do_create_organization(
              pI IN OUT NOCOPY leadImpType,
              G_return_status OUT NOCOPY varchar2)
IS
    l_org_rec   HZ_PARTY_V2PUB.organization_rec_type;
    l_hz_partyNumber number;
    l_hz_profile number;
    l_msg_data VARCHAR2(2000);

--  aanjaria enh tcav2
    -- Dummy
    l_dummy_rec2 hz_location_v2pub.location_rec_type;
    l_dummy_rec3 hz_contact_point_v2pub.contact_point_rec_type;
    l_dummy_rec4 hz_party_site_v2pub.party_site_rec_type;
    l_dummy_rec5 hz_party_contact_v2pub.org_contact_rec_type;
    l_dummy_rec6 hz_party_contact_v2pub.org_contact_role_rec_type;
    l_dummy_rec7 as_sales_leads_pub.sales_lead_rec_type;
    l_dummy_tbl8 as_sales_leads_pub.sales_lead_line_tbl_type;
    l_dummy_tbl9 as_sales_leads_pub.sales_lead_contact_tbl_type;

Begin
    -- Assining HZ_PARTY_V2PUB.organization_rec_type
    l_org_rec.organization_name := pI.customer_name;
    l_org_rec.sic_code := pI.sic_code;
    l_org_rec.sic_code_type := pI.sic_code_type;
    l_org_rec.hq_branch_ind := pI.hq_branch_ind;
    l_org_rec.tax_reference := pI.tax_reference;
    l_org_rec.jgzz_fiscal_code := pI.jgzz_fiscal_code;
    l_org_rec.fiscal_yearend_month := pI.fiscal_yearend_month;
    l_org_rec.employees_total	:= pI.num_of_employees;
    l_org_rec.curr_fy_potential_revenue := pI.potential_revenue_curr_fy;
    l_org_rec.next_fy_potential_revenue := pI.potential_revenue_next_fy;
    l_org_rec.year_established := pI.year_established;
    l_org_rec.GSA_INDICATOR_FLAG := pI.GSA_INDICATOR_FLAG;
    l_org_rec.MISSION_STATEMENT := pI.MISSION_STATEMENT;
    l_org_rec.ORGANIZATION_NAME_PHONETIC := pI.ORGANIZATION_NAME_PHONETIC;
    l_org_rec.analysis_fy	:= pI.analysis_fy;
    -- ffang 103001, bug 2080069, populate pref_functional_currency
    l_org_rec.pref_functional_currency := pI.currency_code;
    l_org_rec.known_as := pI.known_as;
    l_org_rec.known_as2 := pI.known_as2;
    l_org_rec.known_as3 := pI.known_as3;
    l_org_rec.known_as4 := pI.known_as4;
    l_org_rec.known_as5 := pI.known_as5;

    l_org_rec.party_rec.party_number := pI.party_number;
    l_org_rec.party_rec.validated_flag := pI.parties_validated_flag;
    -- The expectation is pI.orig_system_reference will be concatenated with
    -- pI.orig_system_code.
    if (pI.orig_system_reference is not null) or
       (pI.orig_system_reference <> FND_API.G_MISS_CHAR) Then
        l_org_rec.party_rec.orig_system_reference := pI.orig_system_reference;
    else
        l_org_rec.party_rec.orig_system_reference := pI.import_interface_id;
    end if;
      l_org_rec.party_rec.status := 'A';
      l_org_rec.party_rec.category_code := pI.customer_category_code;

--    aanjaria enh tcav2
--    l_org_rec.duns_number := pI.duns_number;
--    l_org_rec.tax_name := pI.tax_name;
--    l_org_rec.party_rec.customer_key := pI.customer_key;
--    l_org_rec.party_rec.total_num_of_orders := pI.total_num_of_orders;  --0;
--    l_org_rec.party_rec.total_ordered_amount := pI.total_ordered_amount;
--    l_org_rec.party_rec.last_ordered_date := pI.last_ordered_date;
      l_org_rec.duns_number_c := pI.duns_number_c; --bug# 3170261
      l_org_rec.created_by_module := 'AML_LEAD_IMPORT';
      l_org_rec.application_id := 530;

    do_assign_flex (
        l_org_rec.party_rec,
        l_dummy_rec2,
        l_dummy_rec3,
        l_dummy_rec4,
        l_dummy_rec5 ,
        -- l_dummy_rec6 ,
        l_dummy_rec7 ,
        l_dummy_tbl8 ,
        l_dummy_tbl9 ,
        'HZ_PARTIES',
        pI.import_interface_id,
        G_return_status
    );

    if G_return_status = FND_API.G_RET_STS_SUCCESS Then
        HZ_PARTY_V2PUB.create_organization (
            p_init_msg_list     => FND_API.G_FALSE,
            p_organization_rec	=> l_org_rec,
            x_return_status     => G_return_status,
            x_msg_count	        => G_MESG_COUNT,
            x_msg_data          => l_msg_data,
            x_party_id          => pI.party_id,
            x_party_number      => l_hz_partyNumber,
            x_profile_id        => l_hz_profile
        );
        IF G_return_status = FND_API.G_RET_STS_SUCCESS Then
            write_log (3, 'Organization created: '||pI.party_id);
        END IF;
    End if ;

End do_create_organization;

----------------------------------------------------------
-- name:  do_create_ps_psu
-- scope: private
-- calls  HZ_LOCATION_V2PUB.create_organization
-- inserts party with party type as ORGANIZATION
----------------------------------------------------------
procedure do_create_ps_psu(
              pI IN OUT NOCOPY leadImpType,
              p_party_id  IN  NUMBER,
              p_type      IN  varchar2,
              G_return_status OUT NOCOPY varchar2)
IS
--    aanjaria enh tcav2
    l_ps_rec    hz_party_site_v2pub.party_site_rec_type;
    l_ps_use_rec HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;
    l_ps_use_id number;
    l_msg_data VARCHAR2(2000);
    l_hz_psNumber  VARCHAR2(30);
    l_hz_psid  NUMBER;

    -- Dummy
    l_dummy_rec1 hz_party_v2pub.party_rec_type;
    l_dummy_rec2 hz_location_v2pub.location_rec_type;
    l_dummy_rec3 hz_contact_point_v2pub.contact_point_rec_type;
    --l_dummy_rec4 hz_party_pub.party_site_rec_type;
    l_dummy_rec5 hz_party_contact_v2pub.org_contact_rec_type;
    l_dummy_rec6 hz_party_contact_v2pub.org_contact_role_rec_type;
    l_dummy_rec7 as_sales_leads_pub.sales_lead_rec_type;
    l_dummy_tbl8 as_sales_leads_pub.sales_lead_line_tbl_type;
    l_dummy_tbl9 as_sales_leads_pub.sales_lead_contact_tbl_type;

Begin
    -- l_ps_rec.party_id := pI.party_id;
    l_ps_rec.party_id := p_party_id;
    l_ps_rec.location_id := pI.location_id;
    l_ps_rec.orig_system_reference := pI.import_interface_id;
    l_ps_rec.party_site_number := pI.party_site_number;
    l_ps_rec.addressee := pI.addressee;
    l_ps_rec.mailstop := pI.mailstop;
    l_ps_rec.party_site_name := pI.party_site_name;
    -- ffang 071101, bug 1874947, always pass 'N', AR API will take care of it.
    l_ps_rec.identifying_address_flag := 'N';
    l_ps_rec.status := 'A';

    l_ps_rec.created_by_module := 'AML_LEAD_IMPORT';
    l_ps_rec.application_id := 530;

    write_log(3, 'Creating PartySite for '||l_ps_rec.party_id||':'||
                 l_ps_rec.location_id);

    -- swkhanna 6/12/02 Bug 2404796
    --IF p_type =  'ORG' THEN
    IF p_type in ( 'ORGANIZATION','PERSON') THEN
        do_assign_flex (
            l_dummy_rec1,
            l_dummy_rec2,
            l_dummy_rec3,
            l_ps_rec,
            l_dummy_rec5 ,
            -- l_dummy_rec6 ,
            l_dummy_rec7 ,
            l_dummy_tbl8 ,
            l_dummy_tbl9 ,
            'HZ_PARTY_SITES',
            pI.import_interface_id,
            G_return_status
        );
    ELSIF p_type = 'REL' THEN
        G_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    If G_return_status = FND_API.G_RET_STS_SUCCESS Then
    	   HZ_PARTY_SITE_V2PUB.create_party_site (
            p_init_msg_list    => FND_API.G_FALSE,
            p_party_site_rec   => l_ps_rec,
            x_return_status    => G_return_status,
            x_msg_count        => G_MESG_COUNT,
            x_msg_data         => l_msg_data,
            x_party_site_id    => l_hz_psid,   -- pI.hz_psid,
            x_party_site_number=> l_hz_psNumber
    	   );

        -- If error raise exception
        IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            write_log(3, 'Creating Party Site failed');
            write_log(3, 'insert error messages into as_imp_errors table');
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            write_log(3, p_type||' Party Site created: '||l_hz_psid);
		 -- IF p_type = 'ORG' THEN
		  IF p_type in  ('ORGANIZATION','PERSON') THEN
                pI.party_site_id := l_hz_psid;
            END IF;
        END IF;

        write_log(3, 'Creating Party Site Use');
        l_ps_use_rec.party_site_id := l_hz_psid;   -- pI.hz_psid;
--        l_ps_use_rec.begin_date := sysdate;
        -- ffang 100501, if site_use_type is not passed in, then default it
        -- to 'BILL_TO'
        IF (pI.site_use_type is null OR pI.site_use_type = FND_API.G_MISS_CHAR)
        THEN
            l_ps_use_rec.site_use_type := 'BILL_TO';
        ELSE
            l_ps_use_rec.site_use_type := pI.site_use_type;  -- 'BILL_TO';
        END IF;
        l_ps_use_rec.comments := pI.ps_uses_comments;
        l_ps_use_rec.PRIMARY_PER_TYPE := pI.PRIMARY_PER_TYPE;
        l_ps_use_rec.STATUS := 'A';

        l_ps_use_rec.created_by_module := 'AML_LEAD_IMPORT';
        l_ps_use_rec.application_id := 530;

        HZ_PARTY_SITE_V2PUB.create_party_site_use (
            p_init_msg_list      => FND_API.G_FALSE,
            p_party_site_use_rec => l_ps_use_rec,
            x_return_status      => G_return_status,
            x_msg_count          => G_MESG_COUNT,
            x_msg_data           => l_msg_data,
            x_party_site_use_id  => l_ps_use_id
    	   );
        IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            write_log(3, 'Creating Party Site Use failed');
        ELSE
            write_log(3, 'PS Use created: ' || l_ps_use_id);
        END IF;

    End If;
End do_create_ps_psu;

----------------------------------------------------------
-- name:  do_create_relationship
-- scope: private
-- calls  HZ_PARTY_CONTACT_V2PUB.create_org_contact
-- inserts party relationship and creates org_contact
----------------------------------------------------------
procedure do_create_relationship(
              pI IN OUT NOCOPY leadImpType,
              G_return_status OUT NOCOPY varchar2)
IS
    l_org_con_rec  hz_party_contact_v2pub.org_contact_rec_type;
    l_role_rec hz_party_contact_v2pub.org_contact_role_rec_type;
--    l_rel_rec      hz_party_pub.party_rel_rec_type;
    --l_org_contact_id NUMBER;
    l_party_rel_id NUMBER;
    l_party_id	NUMBER;
    l_role_id NUMBER;
    l_party_number VARCHAR2(30);
    l_msg_data VARCHAR2(2000);

    -- Dummy
    l_dummy_rec1 hz_party_v2pub.party_rec_type;
    l_dummy_rec2 hz_location_v2pub.location_rec_type;
    l_dummy_rec3 hz_contact_point_v2pub.contact_point_rec_type;
    l_dummy_rec4 hz_party_site_v2pub.party_site_rec_type;
    l_dummy_rec5 hz_party_contact_v2pub.org_contact_rec_type;
    l_dummy_rec6 hz_party_contact_v2pub.org_contact_role_rec_type;
    l_dummy_rec7 as_sales_leads_pub.sales_lead_rec_type;
    l_dummy_tbl8 as_sales_leads_pub.sales_lead_line_tbl_type;
    l_dummy_tbl9 as_sales_leads_pub.sales_lead_contact_tbl_type;

    cursor c_cnt_role (c_import_interface_id NUMBER) is
        select * from AS_IMP_CNT_ROL_INTERFACE
        where import_interface_id = c_import_interface_id;

Begin
    --check if the relationship is existing or not.
    -- if the relationship exists, then we can assume that the
    -- org contact rec exists.
    Begin
        Select party_id into pI.rel_party_id
        from hz_relationships
        where subject_id = pI.contact_party_id
          and object_id = pI.party_id
          and subject_table_name = 'HZ_PARTIES'
          and object_table_name = 'HZ_PARTIES'
          and relationship_code = 'CONTACT_OF';

/* *****
        -- ffang 073101, use hz_relationships instead of hz_party_relationships
        Select party_id into pI.rel_party_id
        from hz_party_relationships
        where subject_id = pI.contact_party_id
          and object_id = pI.party_id
          and party_relationship_type = 'CONTACT_OF';
***** */

        Exception
            When NO_DATA_FOUND Then
                write_log(3, 'Creating Relationship');

                write_log(3, 'subject_id '||to_char(pI.contact_party_id));
		write_log(3, 'object_id  '||to_char(pI.party_id));

                l_org_con_rec.comments := pI.org_cnt_comments;
                l_org_con_rec.contact_number:= pI.contact_number;
                l_org_con_rec.department_code := pI.department_code;
                l_org_con_rec.department := pI.department;
                --l_org_con_rec.title := pI.org_cnt_title; -- SOLIN, bug 4602573
                l_org_con_rec.job_title := pI.job_title;
                l_org_con_rec.job_title_code := pI.job_title_code;
                l_org_con_rec.decision_maker_flag := pI.decision_maker_flag;
                l_org_con_rec.reference_use_flag := pI.reference_use_flag;
                l_org_con_rec.rank := pI.rank;
                l_org_con_rec.party_site_id := pI.party_site_id;
                l_org_con_rec.orig_system_reference := pI.import_interface_id;
                l_org_con_rec.party_rel_rec.subject_id := pI.contact_party_id;
		l_org_con_rec.party_rel_rec.subject_type := 'PERSON';
                l_org_con_rec.party_rel_rec.subject_table_name := 'HZ_PARTIES';
                l_org_con_rec.party_rel_rec.object_id := pI.party_id;
		l_org_con_rec.party_rel_rec.object_type := 'ORGANIZATION';
                l_org_con_rec.party_rel_rec.object_table_name := 'HZ_PARTIES';
                l_org_con_rec.party_rel_rec.relationship_type := 'CONTACT';
                l_org_con_rec.party_rel_rec.start_date:= sysdate;
                l_org_con_rec.party_rel_rec.relationship_code := 'CONTACT_OF';

--              aanjaria enh tcav2
--                l_org_con_rec.mail_stop := pI.mail_stop;
--                l_org_con_rec.contact_key	:= substr(pI.contact_key,1,50);
                l_org_con_rec.created_by_module := 'AML_LEAD_IMPORT';
                l_org_con_rec.application_id := 530;

		do_assign_flex (
                    l_dummy_rec1,
                    l_dummy_rec2,
                    l_dummy_rec3,
                    l_dummy_rec4,
                    l_org_con_rec ,
                    -- l_dummy_rec6 ,
                    l_dummy_rec7 ,
                    l_dummy_tbl8 ,
                    l_dummy_tbl9 ,
                    'HZ_ORG_CONTACTS',
                    pI.import_interface_id,
                    G_return_status
                );
                If G_return_status = FND_API.G_RET_STS_SUCCESS Then
                    write_log(3, 'Creating OrgContact');
                    HZ_PARTY_CONTACT_V2PUB.create_org_contact (
                        p_init_msg_list	=> FND_API.G_FALSE,
                        p_org_contact_rec => l_org_con_rec,
                        x_return_status	=> G_return_status,
                        x_msg_count => G_MESG_COUNT,
                        x_msg_data => l_msg_data,
                        x_org_contact_id => G_LOCAL_ORG_CONTACT_ID,
                        x_party_rel_id => l_party_rel_id,
                        x_party_id =>  pI.rel_party_id,
                        x_party_number => l_party_number
                    );
                    If G_return_status = FND_API.G_RET_STS_SUCCESS Then
                        write_log (3, 'OrgContact created: '||
                                      G_LOCAL_ORG_CONTACT_ID);
                        write_log (3, 'Party Relationship created: '||
                                      l_party_rel_id||':'||pI.rel_party_id);
                        -- ffang 102401, for bug 2075424, if location is not
                        -- created, don't create party_site
                        IF (pI.location_id is not null and
                            pI.location_id <> FND_API.G_MISS_NUM)
                        THEN
                            write_log(3,'Creating party site for Relationship');
                            do_create_ps_psu(pI, pI.rel_party_id, 'REL',
                                             G_return_status);
                            -- If error raise exception
                            IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                write_log(3, 'Creating PS for Rel failed');
                            END IF;
                        END IF;

                        -- Creating OrgContact Role(in as_imp_cnt_rol_interface)
                        IF (pI.customer_rank is not NULL AND
                            pI.customer_rank <> FND_API.G_MISS_CHAR) THEN
                            l_role_rec.role_type := pI.customer_rank;
                            l_role_rec.primary_flag := 'N';   --'Y';
                            l_role_rec.org_contact_id := G_LOCAL_ORG_CONTACT_ID;
                            l_role_rec.orig_system_reference :=
                                                       pI.import_interface_id;
                            l_role_rec.role_level := pI.role_level;
                            l_role_rec.primary_contact_per_role_type :=
                                            pI.primary_contact_per_role_type;
                            l_role_rec.status := 'A';

			    l_role_rec.created_by_module := 'AML_LEAD_IMPORT';
                            l_role_rec.application_id := 530;

                            If (( l_role_rec.role_type is not null) OR
                                (l_role_rec.role_type <> FND_API.G_MISS_CHAR))
                            Then
                                If G_return_status = FND_API.G_RET_STS_SUCCESS
                                Then
                                    write_log(3, 'Creating OrgContactRole(1)');
                                    HZ_PARTY_CONTACT_V2PUB.create_org_contact_role (
                                        p_init_msg_list     => FND_API.G_FALSE,
                                        p_org_contact_role_rec => l_role_rec,
                                        x_return_status     => G_return_status,
                                        x_msg_count => G_MESG_COUNT,
                                        x_msg_data => l_msg_data,
                                        x_org_contact_role_id => l_role_id
                                    );
                                    If G_return_status <>
                                                   FND_API.G_RET_STS_SUCCESS
                                    Then
                                        write_log(3,
                                                 'Creating OrgCntRole failed');
                                    ELSE
                                        write_log(3, 'orgCntRole created: ' ||
                                                     l_role_id);
                                    END IF;
                                End if;
                            End if;
                        End if;

                        -- Creating OrgContact Role(in as_imp_cnt_rol_interface)
                        FOR OCR IN c_cnt_role(pI.import_interface_id) LOOP
                            l_role_rec.role_type := OCR.role_type;
                                                    -- pI.customer_rank;
                            IF (OCR.primary_flag is not NULL AND
                                OCR.primary_flag <> FND_API.G_MISS_CHAR) THEN
                                l_role_rec.primary_flag := OCR.primary_flag;
                            ELSE
                                l_role_rec.primary_flag := 'N';
                            END IF;
                            l_role_rec.org_contact_id := G_LOCAL_ORG_CONTACT_ID;
                            IF (OCR.orig_system_reference is not NULL AND
                                OCR.orig_system_reference<>FND_API.G_MISS_CHAR)
                            THEN
                                l_role_rec.orig_system_reference :=
                                                    OCR.orig_system_reference;
                            ELSE
                                l_role_rec.orig_system_reference :=
                                                       pI.import_interface_id;
                            END IF;
                            l_role_rec.role_level := OCR.role_level;
                            l_role_rec.primary_contact_per_role_type :=
                                            OCR.primary_contact_per_role_type;
                            l_role_rec.status := 'A';

			    l_role_rec.created_by_module := 'AML_LEAD_IMPORT';
                            l_role_rec.application_id := 530;

                            If (( l_role_rec.role_type is not null) OR
                                (l_role_rec.role_type <> FND_API.G_MISS_CHAR))
                            Then
                                -- ffang 082001, hz_org_contacts_roles'
                                -- flexfields are going to be obsolete.
                                -- No need to populate.
                                /* ***
                                do_assign_flex (
                                    l_dummy_rec1,
                                    l_dummy_rec2,
                                    l_dummy_rec3,
                                    l_dummy_rec4,
                                    l_dummy_rec5 ,
                                    -- l_role_rec ,
                                    l_dummy_rec7 ,
                                    l_dummy_tbl8 ,
                                    l_dummy_tbl9 ,
                                    'HZ_ORG_CONTACT_ROLES',
                                    pI.import_interface_id,
                                    G_return_status
                                );
                                *** */
                                If G_return_status = FND_API.G_RET_STS_SUCCESS
                                Then
                                    write_log(3, 'Creating OrgContactRole(2)');
                                    HZ_PARTY_CONTACT_V2PUB.create_org_contact_role (
                                        p_init_msg_list	=> FND_API.G_FALSE,
                                        p_org_contact_role_rec => l_role_rec,
                                        x_return_status	=> G_return_status,
                                        x_msg_count => G_MESG_COUNT,
                                        x_msg_data => l_msg_data,
                                        x_org_contact_role_id => l_role_id
                                    );
                                    If G_return_status <>
                                                     FND_API.G_RET_STS_SUCCESS
                                    Then
                                        write_log(3,
                                                 'Creating OrgContRole failed');
                                    ELSE
                                        -- ffang 082201, write back to role
                                        -- interface table
                                        update as_imp_cnt_rol_interface
                                        set org_contact_role_id = l_role_id,
                                            org_contact_id =
                                                       G_LOCAL_ORG_CONTACT_ID
                                        where imp_cnt_rol_interface_id =
                                                  OCR.imp_cnt_rol_interface_id;

                                        write_log(3, 'orgCntRole created: ' ||
                                                     l_role_id);
                                    END IF;
                                End if;
                            END IF;
                        End LOOP;
                    ELSE
                        write_log(3, 'Creating OrgContact failed');
                    End if;
                End if;
            When Others Then
                RAISE FND_API.G_EXC_ERROR;
    End;
END do_create_relationship;

----------------------------------------------------------
-- name:  do_create_saleslead
-- scope: private
-- calls  as_sales_leads_pub.create_sales_lead
-- inserts sales lead header and lines
----------------------------------------------------------
procedure do_create_saleslead( pI IN OUT NOCOPY leadImpType,
                               G_return_status OUT NOCOPY varchar2)
IS
    l_sales_lead_rec          as_sales_leads_pub.sales_lead_rec_type;
    l_sales_lead_line_rec     as_sales_leads_pub.sales_lead_line_rec_type;
    l_sales_lead_line_tbl     as_sales_leads_pub.sales_lead_line_tbl_type;
    l_sales_lead_contact_rec  as_sales_leads_pub.sales_lead_contact_rec_type;
    l_sales_lead_contact_tbl  as_sales_leads_pub.sales_lead_contact_tbl_type;
    l_sales_lead_line_out_tbl as_sales_leads_pub.sales_lead_line_out_tbl_type;
    l_sales_lead_cnt_out_tbl  as_sales_leads_pub.sales_lead_cnt_out_tbl_type;
    l_sales_lead_profile_tbl  as_utility_pub.profile_tbl_type;
    l_sales_lead_id           NUMBER;
    l_msg_data                VARCHAR2(2000) := NULL;
    l_api_message             VARCHAR2(2000);
    l_api_name                CONSTANT VARCHAR2(30) := 'create_sales_lead';
    l_temp_promotion_id	      NUMBER;
    -- ffang 101601, bug 2053591
    l_temp_promotion_code     VARCHAR2(50);
    l_contact_party_id        NUMBER;
    l_retcode                 VARCHAR2(1) := NULL; -- used by create_lead_note
    l_lead_note_id            NUMBER;

    -- primary contact point id of the primary contact
    l_contact_point_id        NUMBER;

    -- Dummy
    l_dummy_rec1 hz_party_v2pub.party_rec_type;
    l_dummy_rec2 hz_location_v2pub.location_rec_type;
    l_dummy_rec3 hz_contact_point_v2pub.contact_point_rec_type;
    l_dummy_rec4 hz_party_site_v2pub.party_site_rec_type;
    l_dummy_rec5 hz_party_contact_v2pub.org_contact_rec_type;
    l_dummy_rec6 hz_party_contact_v2pub.org_contact_role_rec_type;
    l_dummy_rec7 as_sales_leads_pub.sales_lead_rec_type;
    l_dummy_tbl8 as_sales_leads_pub.sales_lead_line_tbl_type;
    l_dummy_tbl9 as_sales_leads_pub.sales_lead_contact_tbl_type;

    CURSOR c_get_source_code (c_promotion_id number) IS
     SELECT source_code_id, source_code
     FROM ams_p_source_codes_v
     WHERE source_code_id = c_promotion_id
     AND source_type in ('CAMP','CSCH','EONE', 'EVEH','EVEO')
     AND status in ('ACTIVE','ONHOLD', 'COMPLETED');

    CURSOR c_get_promotion_id (c_promotion_code VARCHAR2) IS
     SELECT source_code_id
     -- SOLIN, bug 4927392, use view ams_p_source_codes_v
     FROM ams_p_source_codes_v
     WHERE upper(source_code) = upper(c_promotion_code)
     AND source_type in ('CAMP','CSCH','EONE', 'EVEH','EVEO')
     AND status in ('ACTIVE','ONHOLD', 'COMPLETED');

    -- ffang 082401, for supporting multiple lines
    CURSOR c_get_lines (c_import_interface_id number) IS
        select * from as_imp_lines_interface
        where import_interface_id = c_import_interface_id;

    l_index  NUMBER;
    -- end ffang 082401

    -- ajchatto, for retrieving primary contact point of primary contact
    CURSOR c_get_primary_cp (c_rel_party_id number) IS
        SELECT CONTACT_POINT_ID
        FROM   HZ_CONTACT_POINTS
        WHERE  OWNER_TABLE_NAME = 'HZ_PARTIES' AND CONTACT_POINT_TYPE = 'PHONE'
        AND    PRIMARY_FLAG = 'Y' AND OWNER_TABLE_ID = c_rel_party_id
        AND    ROWNUM = 1; --TO SELECT ONE ROW

   -- swkhanna 7/30/02 get assign_to_person_id if not being passed in table
  Cursor c_get_person_id (c_salesforce_id number) is
  select source_id
  from jtf_rs_resource_extns
  where resource_id = c_salesforce_id;

  l_assign_to_person_id number;
  l_validation_level    number;

BEGIN

    write_log(3, 'do_create_saleslead:Start');

    -- PROMOTION_ID/PROMOTION_CODE
    IF (pI.promotion_id is not null AND pI.promotion_id <> FND_API.G_MISS_NUM)
    THEN
        l_temp_promotion_id := NULL;
        l_temp_promotion_code := NULL;

        -- Validate promotion_id and get promotion_code
        OPEN c_get_source_code ( pI.PROMOTION_ID);
        FETCH c_get_source_code into l_temp_promotion_id, l_temp_promotion_code;
        IF c_get_source_code%NOTFOUND THEN
            write_log(3,'Invalid promotion id:'||pI.promotion_id);
            CLOSE c_get_source_code;

            -- ffang 052301, push error message into stack
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'PROMOTION ID',
                p_token2        => 'VALUE',
                p_token2_value  => pI.PROMOTION_ID );
            -- RAISE  NO_DATA_FOUND;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            -- l_sales_lead_rec.SOURCE_PROMOTION_ID := l_temp_promotion_id;
            pI.promotion_id := l_temp_promotion_id;
        END IF;
        CLOSE c_get_source_code;

        -- ffang 101601, bug 2053591, if promotion_code is not null, match them
        IF (pI.promotion_code is not null
            AND pI.promotion_code <> FND_API.G_MISS_CHAR)
        THEN
            IF UPPER(pI.promotion_code) <> UPPER(l_temp_promotion_code) THEN
                write_log(3,'promotion_id and promotion_code not match:');
                write_log(3,'promotion_id: '||pI.promotion_id);
                write_log(3,'promotion_code: '||pI.promotion_code);

                AS_UTILITY_PVT.Set_Message(
                    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name      => 'AS_NOT_MATCHING_ID_CODE',
                    p_token1        => 'VALUE1',
                    p_token1_value  => pI.promotion_id,
                    p_token2        => 'VALUE2',
                    p_token2_value  => pI.promotion_code );
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            -- promotion_code is not given, populate it in as_import_interface
             -- swkhanna 05/28/02
            pI.promotion_code := UPPER(l_temp_promotion_code);
        END IF;

    ELSE   -- promotion_id is not given

        IF (pI.promotion_code is not null AND
            pI.promotion_code <> FND_API.G_MISS_CHAR)
        THEN
            l_temp_promotion_id := NULL;

            -- Validate promotion_code and get promotion_id
            OPEN c_get_promotion_id (pI.PROMOTION_CODE);
            FETCH c_get_promotion_id into l_temp_promotion_id;
            IF c_get_promotion_id%NOTFOUND THEN
                write_log(3,'Invalid promotion code:'||pI.promotion_code);
                CLOSE c_get_promotion_id;

                -- ffang 052301, push error message into stack
                AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_ID',
                      p_token1        => 'COLUMN',
                      p_token1_value  => 'PROMOTION CODE',
                      p_token2        => 'VALUE',
                      p_token2_value  => pI.PROMOTION_CODE );
                -- RAISE  NO_DATA_FOUND;
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                -- l_sales_lead_rec.SOURCE_PROMOTION_ID := l_temp_promotion_id;
                pI.promotion_id := l_temp_promotion_id;
            END IF;
            CLOSE c_get_promotion_id;
        END IF;

    END IF;

    -- Sales lead header
    l_sales_lead_rec.LEAD_NUMBER         := nvl(pI.LEAD_NUMBER, '-1');
    l_sales_lead_rec.STATUS_CODE         := pI.STATUS_CODE ;
    l_sales_lead_rec.CUSTOMER_ID         := pI.party_id ;
    l_sales_lead_rec.ADDRESS_ID          := pI.party_site_id;
    l_sales_lead_rec.SOURCE_PROMOTION_ID := pI.promotion_id;
    l_sales_lead_rec.ORIG_SYSTEM_REFERENCE := pI.orig_system_reference;
    l_sales_lead_rec.CONTACT_ROLE_CODE   := pI.CONTACT_ROLE_CODE;
    l_sales_lead_rec.CHANNEL_CODE        := pI.CHANNEL_CODE     ;
    l_sales_lead_rec.BUDGET_AMOUNT       := pI.BUDGET_AMOUNT    ;
    l_sales_lead_rec.currency_code  :=  pI.currency_code;
    l_sales_lead_rec.DECISION_TIMEFRAME_CODE := pI.DECISION_TIMEFRAME_CODE ;
    l_sales_lead_rec.CLOSE_REASON        := pI.CLOSE_REASON;
    l_sales_lead_rec.LEAD_RANK_ID      := pI.LEAD_RANK_ID;
    l_sales_lead_rec.PARENT_PROJECT      := pI.PARENT_PROJECT;
    l_sales_lead_rec.DESCRIPTION         := pI.DESCRIPTION;

/*  -- Removed logic for lead_name
    IF (pI.DESCRIPTION is not NULL AND pI.DESCRIPTION <> FND_API.G_MISS_CHAR)
    THEN
        l_sales_lead_rec.DESCRIPTION         := pI.DESCRIPTION;
    ELSE
        IF (pI.last_name is not NULL AND pI.last_name <> FND_API.G_MISS_CHAR)
        THEN
            IF(pI.first_name is not NULL AND pI.first_name<>FND_API.G_MISS_CHAR)
            THEN
                l_sales_lead_rec.DESCRIPTION:=pI.last_name||', '||pI.first_name;
            ELSE
                l_sales_lead_rec.DESCRIPTION := pI.last_name;
            END IF;
        ELSE
            IF(pI.first_name is not NULL AND pI.first_name<>FND_API.G_MISS_CHAR)
            THEN
                l_sales_lead_rec.DESCRIPTION := pI.first_name;
            END IF;
        END IF;
    END IF;
*/

    -- 7/30/02 swkhanna - get assign_to_person if not passed in
    if  pI.ASSIGN_TO_PERSON_ID is null and  pI.ASSIGN_TO_SALESFORCE_ID is not null then
   	open c_get_person_id(pI.ASSIGN_TO_SALESFORCE_ID);
        fetch c_get_person_id into l_assign_to_person_id;
        close c_get_person_id;

         pI.ASSIGN_TO_PERSON_ID := l_assign_to_person_id;

    elsif  pI.ASSIGN_TO_PERSON_ID is not null then
        l_assign_to_person_id :=  pI.ASSIGN_TO_PERSON_ID;
    end if;

    --l_sales_lead_rec.ASSIGN_TO_PERSON_ID  := pI.ASSIGN_TO_PERSON_ID;
    l_sales_lead_rec.ASSIGN_TO_PERSON_ID  := l_assign_to_person_id;
    l_sales_lead_rec.ASSIGN_TO_SALESFORCE_ID  := pI.ASSIGN_TO_SALESFORCE_ID;
    l_sales_lead_rec.ASSIGN_SALES_GROUP_ID  := pI.ASSIGN_SALES_GROUP_ID;
    l_sales_lead_rec.ASSIGN_DATE  := pI.ASSIGN_DATE;
    l_sales_lead_rec.BUDGET_STATUS_CODE  := pI.BUDGET_STATUS_CODE;
    l_sales_lead_rec.ACCEPT_FLAG  := pI.ACCEPT_FLAG;
    l_sales_lead_rec.VEHICLE_RESPONSE_CODE := pI.VEHICLE_RESPONSE_CODE;
    l_sales_lead_rec.SCORECARD_ID := pI.SCORECARD_ID;
    l_sales_lead_rec.KEEP_FLAG  := pI.KEEP_FLAG;
    l_sales_lead_rec.URGENT_FLAG := pI.URGENT_FLAG;
    l_sales_lead_rec.IMPORT_FLAG  := NVL(pI.IMPORT_FLAG,'Y');
    l_sales_lead_rec.REJECT_REASON_CODE  := pI.REJECT_REASON_CODE;
    l_sales_lead_rec.DELETED_FLAG  := pI.DELETED_FLAG;
    l_sales_lead_rec.OFFER_ID  := pI.OFFER_ID;
    l_sales_lead_rec.INCUMBENT_PARTNER_PARTY_ID  :=
                             pI.INCUMBENT_PARTNER_PARTY_ID;
    l_sales_lead_rec.INCUMBENT_PARTNER_RESOURCE_ID  :=
                             pI.INCUMBENT_PARTNER_RESOURCE_ID;
    l_sales_lead_rec.PRM_EXEC_SPONSOR_FLAG  := pI.PRM_EXEC_SPONSOR_FLAG;
    l_sales_lead_rec.PRM_PRJ_LEAD_IN_PLACE_FLAG  :=
                             pI.PRM_PRJ_LEAD_IN_PLACE_FLAG;
    l_sales_lead_rec.PRM_SALES_LEAD_TYPE  := pI.PRM_SALES_LEAD_TYPE;
    l_sales_lead_rec.PRM_IND_CLASSIFICATION_CODE  :=
                             pI.PRM_IND_CLASSIFICATION_CODE;
    l_sales_lead_rec.QUALIFIED_FLAG  := upper(pI.QUALIFIED_FLAG);
    l_sales_lead_rec.ORIG_SYSTEM_CODE  := pI.ORIG_SYSTEM_CODE;
    l_sales_lead_rec.PRM_ASSIGNMENT_TYPE  := pI.PRM_ASSIGNMENT_TYPE;
    l_sales_lead_rec.AUTO_ASSIGNMENT_TYPE  := pI.AUTO_ASSIGNMENT_TYPE;
   --
   -- 5/24/02 swkhanna , Bug 2341515, Bug 2368075
    l_sales_lead_rec.LEAD_DATE     := pI.LEAD_DATE ;
    l_sales_lead_rec.SOURCE_SYSTEM := pI.SOURCE_SYSTEM;
    l_sales_lead_rec.COUNTRY       := pI.COUNTRY;

    --Purging changes --aanjaria
    l_sales_lead_rec.marketing_score     := pI.marketing_score;
    l_sales_lead_rec.interaction_score   := pI.interaction_score;
    l_sales_lead_rec.source_primary_reference := pI.source_primary_reference;
    l_sales_lead_rec.source_secondary_reference := pI.source_secondary_reference;
    l_sales_lead_rec.sales_methodology_id := pI.sales_methodology_id;

    -- Sales lead lines
    l_index := 0;
    FOR LL in c_get_lines(pI.import_interface_id) LOOP
        l_index := l_index + 1;

        l_sales_lead_line_tbl(l_index).status_code := null;
        l_sales_lead_line_tbl(l_index).budget_amount := LL.budget_amount;

        -- Single Product Hierarchy Uptake
        l_sales_lead_line_tbl(l_index).category_id := LL.category_id;

        l_sales_lead_line_tbl(l_index).inventory_item_id:= LL.inventory_item_id;
        l_sales_lead_line_tbl(l_index).organization_id := LL.organization_id;
        l_sales_lead_line_tbl(l_index).quantity := LL.quantity;
        l_sales_lead_line_tbl(l_index).uom_code := LL.uom_code;
        l_sales_lead_line_tbl(l_index).source_promotion_id :=
                                          LL.source_promotion_id;
        l_sales_lead_line_tbl(l_index).offer_id := LL.offer_id;
    END LOOP;

    -- ffang 091201, support not only the lines in as_imp_lines_interface
    -- but also in as_import_interface
    -- Sales lead line 1 in as_import_interface
        G_SL_LINE_COUNT := 0;
    IF pI.category_id_1 IS NOT NULL OR (pI.inventory_item_id_1 IS NOT NULL AND pI.organization_id_1 IS NOT NULL) THEN
        l_index := l_index + 1;

	-- l_sales_lead_line_tbl(l_index).status_code := pI.status_code_1;
        -- Single Product Hierarchy Uptake
        l_sales_lead_line_tbl(l_index).category_id := pI.category_id_1;

        l_sales_lead_line_tbl(l_index).inventory_item_id :=
                                         pI.inventory_item_id_1;
        l_sales_lead_line_tbl(l_index).organization_id := pI.organization_id_1;
        l_sales_lead_line_tbl(l_index).uom_code := pI.uom_code_1;
        l_sales_lead_line_tbl(l_index).budget_amount := pI.budget_amount_1;
        l_sales_lead_line_tbl(l_index).quantity    := pI.quantity_1;
        l_sales_lead_line_tbl(l_index).source_promotion_id :=
                                                    pI.source_promotion_id_1;
                                         --l_sales_lead_rec.SOURCE_PROMOTION_ID;
        l_sales_lead_line_tbl(l_index).offer_id:= pI.offer_id_1;
        G_SL_LINE_COUNT := 1;
    END IF;

    -- Sales lead line 2 in as_import_interface
    IF pI.category_id_2 IS NOT NULL OR (pI.inventory_item_id_2 IS NOT NULL AND pI.organization_id_2 IS NOT NULL) THEN
        l_index := l_index + 1;

        -- l_sales_lead_line_tbl(l_index).status_code := pI.status_code_2;
        -- Single Product Hierarchy Uptake
        l_sales_lead_line_tbl(l_index).category_id := pI.category_id_2;

        l_sales_lead_line_tbl(l_index).inventory_item_id :=
                                         pI.inventory_item_id_2;
        l_sales_lead_line_tbl(l_index).organization_id := pI.organization_id_2;
        l_sales_lead_line_tbl(l_index).uom_code := pI.uom_code_2;
        l_sales_lead_line_tbl(l_index).budget_amount := pI.budget_amount_2;
        l_sales_lead_line_tbl(l_index).quantity := pI.quantity_2;
        l_sales_lead_line_tbl(l_index).source_promotion_id :=
                                                    pI.source_promotion_id_2;
                                         --l_sales_lead_rec.SOURCE_PROMOTION_ID;
        l_sales_lead_line_tbl(l_index).offer_id := pI.offer_id_2;
        G_SL_LINE_COUNT := 2;
    END IF;

    -- Sales lead line 3 in as_import_interface
    IF pI.category_id_3 IS NOT NULL OR (pI.inventory_item_id_3 IS NOT NULL AND pI.organization_id_3 IS NOT NULL) THEN
        l_index := l_index + 1;

        -- l_sales_lead_line_tbl(l_index).status_code := pI.status_code_3;
        -- Single Product Hierarchy Uptake
        l_sales_lead_line_tbl(l_index).category_id := pI.category_id_3;

        l_sales_lead_line_tbl(l_index).inventory_item_id :=
                                         pI.inventory_item_id_3;
        l_sales_lead_line_tbl(l_index).organization_id := pI.organization_id_3;
        l_sales_lead_line_tbl(l_index).uom_code := pI.uom_code_3;
        l_sales_lead_line_tbl(l_index).budget_amount := pI.budget_amount_3;
        l_sales_lead_line_tbl(l_index).quantity := pI.quantity_3;
        l_sales_lead_line_tbl(l_index).source_promotion_id :=
                                                    pI.source_promotion_id_3;
                                        --l_sales_lead;_rec.SOURCE_PROMOTION_ID;
        l_sales_lead_line_tbl(l_index).offer_id := pI.offer_id_3;
        G_SL_LINE_COUNT := 3;
    END IF;

    -- Sales lead line 4 in as_import_interface
    IF pI.category_id_4 IS NOT NULL OR (pI.inventory_item_id_4 IS NOT NULL AND pI.organization_id_4 IS NOT NULL) THEN
        l_index := l_index + 1;

        -- l_sales_lead_line_tbl(l_index).status_code      := pI.status_code_4;
        -- Single Product Hierarchy Uptake
        l_sales_lead_line_tbl(l_index).category_id := pI.category_id_4;

        l_sales_lead_line_tbl(l_index).inventory_item_id:=
                                         pI.inventory_item_id_4;
        l_sales_lead_line_tbl(l_index).organization_id  := pI.organization_id_4;
        l_sales_lead_line_tbl(l_index).uom_code         := pI.uom_code_4;
        l_sales_lead_line_tbl(l_index).budget_amount    := pI.budget_amount_4;
        l_sales_lead_line_tbl(l_index).quantity         := pI.quantity_4;
        l_sales_lead_line_tbl(l_index).source_promotion_id :=
                                                    pI.source_promotion_id_4;
                                         --l_sales_lead_rec.SOURCE_PROMOTION_ID;
        l_sales_lead_line_tbl(l_index).offer_id         := pI.offer_id_4;
        G_SL_LINE_COUNT := 4;
    END IF;

    -- Sales lead line 5 in as_import_interface
    IF pI.category_id_5 IS NOT NULL OR (pI.inventory_item_id_5 IS NOT NULL AND pI.organization_id_5 IS NOT NULL) THEN
        l_index := l_index + 1;

        -- l_sales_lead_line_tbl(l_index).status_code      := pI.status_code_5;
        -- Single Product Hierarchy Uptake
        l_sales_lead_line_tbl(l_index).category_id := pI.category_id_5;

        l_sales_lead_line_tbl(l_index).inventory_item_id:=
                                         pI.inventory_item_id_5;
        l_sales_lead_line_tbl(l_index).organization_id  := pI.organization_id_5;
        l_sales_lead_line_tbl(l_index).uom_code         := pI.uom_code_5;
        l_sales_lead_line_tbl(l_index).budget_amount    := pI.budget_amount_5;
        l_sales_lead_line_tbl(l_index).quantity         := pI.quantity_5;
        l_sales_lead_line_tbl(l_index).source_promotion_id  :=
                                                    pI.source_promotion_id_5;
                                         --l_sales_lead_rec.SOURCE_PROMOTION_ID;
        l_sales_lead_line_tbl(l_index).offer_id         := pI.offer_id_5;
        G_SL_LINE_COUNT := 5;
    END IF;
    -- end ffang 091201

    write_log(3, 'Total Lead Lines: '||l_index);

    -- Sales lead contact
    -- ffang 100901,  for bug 2042181, if rel_party_id is null, then there is
    -- no lead contact
    IF (pI.rel_party_id is not null) THEN
        l_sales_lead_contact_tbl(1).contact_party_id := pI.rel_party_id  ;
        l_sales_lead_contact_tbl(1).enabled_flag := 'Y';
        l_sales_lead_contact_tbl(1).rank         := pI.CUSTOMER_RANK;
        l_sales_lead_contact_tbl(1).customer_id  := pI.party_id;
        l_sales_lead_contact_tbl(1).address_id   := pI.party_site_id;
        l_sales_lead_contact_tbl(1).contact_role_code := pI.contact_role_code;

    -- The primary contact point of the primary contact needs to be populated in the
    -- phone_id column.
    -- Since, there can be only one contact in the sales lead import interface table,
    -- always, set the contact as the primary contact.
    -- bugfix 2098158.
    /*
        l_sales_lead_contact_tbl(1).phone_id     := pI.phone_id;

        IF (pI.primary_contact_flag is not null and pI.primary_contact_flag <> FND_API.G_MISS_CHAR) THEN
            l_sales_lead_contact_tbl(1).primary_contact_flag := pI.primary_contact_flag;
        ELSE
            l_sales_lead_contact_tbl(1).primary_contact_flag := 'N';
        END IF;
    */
       -- swkhanna : 04/29/02 moved primary contact flag out of the loop
          l_sales_lead_contact_tbl(1).primary_contact_flag := 'Y';

     -- ajoy,
     -- Get the primary contact point id of the primary contact and use it in phone_id
     OPEN  c_get_primary_cp (pI.REL_PARTY_ID);
     FETCH c_get_primary_cp INTO l_contact_point_id;
     CLOSE c_get_primary_cp;

     if (l_contact_point_id is not null) then
         -- Always set it to Primary
         write_log(3, 'Primary contact point found for sales lead contact ' || l_contact_point_id);
        -- swkhanna 04/29/02 commented out to get rid out cannot insert null error
        --l_sales_lead_contact_tbl(1).primary_contact_flag := 'Y';
         l_sales_lead_contact_tbl(1).phone_id := l_contact_point_id;
     else
         write_log(3, 'Primary contact point not found for sales lead contact ');
     end if;


     -- Always set it to Primary
        l_sales_lead_contact_tbl(1).primary_contact_flag := 'Y';

/* swkhanna 7/16
-- commented out the following to fix bug 2462211

     -- Get the primary contact point id of the primary contact and use it in phone_id
        SELECT CONTACT_POINT_ID
        INTO   l_contact_point_id
        FROM   HZ_CONTACT_POINTS
        WHERE  OWNER_TABLE_NAME = 'HZ_PARTIES' AND CONTACT_POINT_TYPE = 'PHONE'
        AND    PRIMARY_FLAG = 'Y' AND OWNER_TABLE_ID = pI.REL_PARTY_ID
        AND    ROWNUM = 1; --TO SELECT ONE ROW

        l_sales_lead_contact_tbl(1).phone_id := l_contact_point_id;
        write_log(3, 'Primary contact point found for sales lead contact ' || l_contact_point_id);
*/

    ELSE
        write_log(3, 'no lead contact record');
    END IF;

    -- Flex fields
    do_assign_flex (
        l_dummy_rec1,
        l_dummy_rec2,
        l_dummy_rec3,
        l_dummy_rec4,
        l_dummy_rec5,
        -- l_dummy_rec6,
        l_sales_lead_rec,
        l_dummy_tbl8,
        l_dummy_tbl9,
        'AS_SALES_LEADS',
        pI.import_interface_id,
        G_return_status
    );
    do_assign_flex (
        l_dummy_rec1,
        l_dummy_rec2,
        l_dummy_rec3,
        l_dummy_rec4,
        l_dummy_rec5,
        -- l_dummy_rec6,
        l_dummy_rec7,
        l_sales_lead_line_tbl,
        l_dummy_tbl9,
        'AS_SALES_LEAD_LINES',
        pI.import_interface_id,
        G_return_status
    );
    do_assign_flex (
        l_dummy_rec1,
        l_dummy_rec2,
        l_dummy_rec3,
        l_dummy_rec4,
        l_dummy_rec5,
        -- l_dummy_rec6,
        l_dummy_rec7,
        l_dummy_tbl8,
        l_sales_lead_contact_tbl,
        'AS_SALES_LEAD_CONTACTS',
        pI.import_interface_id,
        G_return_status
    );

    If G_return_status = FND_API.G_RET_STS_SUCCESS Then
        write_log(3, 'create_sales_lead:Start');

        --Bug 3680824: non resource user can import the lead for sales campaign
        -- in which case, user validation needs to be bypassed
        IF pI.source_system = 'SALES_CAMPAIGN' THEN
           l_validation_level := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM;
        ELSE
           l_validation_level := FND_API.G_VALID_LEVEL_FULL;
        END IF;

        as_sales_leads_pvt.create_sales_lead(
            p_api_version_number         => 2.0,
            p_init_msg_list              => FND_API.G_FALSE,
            p_commit                     => FND_API.G_FALSE,
            p_validation_level           => l_validation_level,
            p_check_access_flag          => 'N',
            p_admin_flag                 => 'N',
            p_admin_group_id             => NULL,
            p_identity_salesforce_id     => G_SL_SALESFORCE_ID,
            p_Sales_Lead_Profile_Tbl     => l_Sales_Lead_Profile_Tbl,
            p_sales_lead_rec             => l_sales_lead_rec,
            p_sales_lead_line_tbl        => l_sales_lead_line_tbl,
            p_sales_lead_contact_tbl     => l_sales_lead_contact_tbl,
            x_sales_lead_id              => pI.sales_lead_id,
            x_return_status              => G_return_status,
            x_msg_count                  => G_MESG_COUNT,
            x_msg_data                   => l_msg_data,
            x_sales_lead_line_out_tbl    => l_sales_lead_line_out_tbl,
            x_sales_lead_cnt_out_tbl     => l_sales_lead_cnt_out_tbl);
    End if;

    If G_return_status = FND_API.G_RET_STS_SUCCESS Then
        write_log(3, 'Sales lead created: ' || pI.sales_lead_id);

        select last_update_date into l_sales_lead_rec.last_update_date
        from as_sales_leads where sales_lead_id=pI.sales_lead_id;
        write_log(3, 'last_update_date: '||l_sales_lead_rec.last_update_date);
    ELSE
        write_log(3, l_msg_data);
    End IF;

END do_create_saleslead;

----------------------------------------------------------
-- name:  do_create_interest
-- scope: private
-- calls  AS_INTEREST_PUB.Create_Interest
-- create an entry in as_interest_all table
----------------------------------------------------------
procedure do_create_interest(
              pI IN OUT NOCOPY leadImpType,
              G_return_status OUT NOCOPY varchar2)
Is
    l_classification_tbl    as_interest_pub.interest_tbl_type;
    l_interest_use_code     varchar2(30);
    l_interest_out_id       NUMBER;
    l_msg_data              VARCHAR2(2000) := NULL;

    CURSOR c_get_lines_1 (c_import_interface_id number) IS
        select * from as_imp_lines_interface
        where import_interface_id = c_import_interface_id;
    l_ll_index  NUMBER;

Begin
    write_log(3, 'do_create_interest:Start');

    -- For the lines in as_import_interface
    write_log(3, 'G_SL_LINE_COUNT: ' || G_SL_LINE_COUNT);
    For i IN 1..G_SL_LINE_COUNT Loop
        l_classification_tbl(i).customer_id := pI.party_id;
        l_classification_tbl(i).address_id  := pI.party_site_id;
        l_classification_tbl(i).contact_id  := G_LOCAL_ORG_CONTACT_ID;

        if (i = 1) then
            l_classification_tbl(i).interest_type_id := pI.interest_type_id_1;
            l_classification_tbl(i).primary_interest_code_id  :=
                                       pI.primary_interest_code_id_1;
            l_classification_tbl(i).secondary_interest_code_id  :=
                                       pI.secondary_interest_code_id_1;
        end if;

        if (i = 2) then
            l_classification_tbl(i).interest_type_id := pI.interest_type_id_2;
            l_classification_tbl(i).primary_interest_code_id  :=
                                       pI.primary_interest_code_id_2;
            l_classification_tbl(i).secondary_interest_code_id  :=
                                       pI.secondary_interest_code_id_2;
        end if;

        if (i = 3) then
            l_classification_tbl(i).interest_type_id := pI.interest_type_id_3;
            l_classification_tbl(i).primary_interest_code_id  :=
                                       pI.primary_interest_code_id_3;
            l_classification_tbl(i).secondary_interest_code_id  :=
                                       pI.secondary_interest_code_id_3;
        end if;

        if (i = 4) then
            l_classification_tbl(i).interest_type_id := pI.interest_type_id_4;
            l_classification_tbl(i).primary_interest_code_id  :=
                                       pI.primary_interest_code_id_4;
            l_classification_tbl(i).secondary_interest_code_id  :=
                                       pI.secondary_interest_code_id_4;
        end if;

        if (i = 5) then
            l_classification_tbl(i).interest_type_id := pI.interest_type_id_5;
            l_classification_tbl(i).primary_interest_code_id  :=
                                       pI.primary_interest_code_id_5;
            l_classification_tbl(i).secondary_interest_code_id  :=
                                       pI.secondary_interest_code_id_5;
        end if;


        if pI.party_type = 'PERSON' then
            l_interest_use_code := 'CONTACT_INTEREST';
        elsif pI.party_type = 'ORGANIZATION' then
            l_interest_use_code := 'COMPANY_CLASSIFICATION' ;
        end if;

        AS_INTEREST_PUB.Create_Interest(
            p_api_version_number     => 2.0 ,
            p_init_msg_list          => FND_API.G_FALSE,
            p_Commit                 => FND_API.G_FALSE,
            p_interest_rec           => l_classification_tbl(i),
            p_customer_id            => pI.party_id,
            p_address_id             => pI.party_site_id,
            p_contact_id             => G_local_org_contact_id,
            p_lead_id                => null,
            p_interest_use_code      => l_interest_use_code,
            p_check_access_flag      => 'N',
            p_admin_flag             => null,
            p_admin_group_id         => null,
            p_identity_salesforce_id => G_SL_SALESFORCE_ID,
            p_access_profile_rec     => null,
            p_return_status          => G_return_status,
            p_msg_count              => G_MESG_COUNT,
            p_msg_data               => l_msg_data,
            p_interest_out_id        => l_interest_out_id) ;
    End Loop;

    -- For the lines in as_imp_lines_interface
    l_ll_index := 0;
    FOR LL1 in c_get_lines_1(pI.import_interface_id) LOOP
        l_ll_index := l_ll_index + 1;

        l_classification_tbl(l_ll_index).customer_id := pI.party_id;
        l_classification_tbl(l_ll_index).address_id  := pI.party_site_id;
        l_classification_tbl(l_ll_index).contact_id  := G_LOCAL_ORG_CONTACT_ID;
        l_classification_tbl(l_ll_index).interest_type_id :=
                                      LL1.interest_type_id;
        l_classification_tbl(l_ll_index).primary_interest_code_id  :=
                                      LL1.primary_interest_code_id;
        l_classification_tbl(l_ll_index).secondary_interest_code_id  :=
                                      LL1.secondary_interest_code_id;

        if pI.party_type = 'PERSON' then
            l_interest_use_code := 'CONTACT_INTEREST';
        elsif pI.party_type = 'ORGANIZATION' then
            l_interest_use_code := 'COMPANY_CLASSIFICATION' ;
        end if;

        AS_INTEREST_PUB.Create_Interest(
            p_api_version_number     => 2.0 ,
            p_init_msg_list          => FND_API.G_FALSE,
            p_Commit                 => FND_API.G_FALSE,
            p_interest_rec           => l_classification_tbl(l_ll_index),
            p_customer_id            => pI.party_id,
            p_address_id             => pI.party_site_id,
            p_contact_id             => G_local_org_contact_id,
            p_lead_id                => null,
            p_interest_use_code      => l_interest_use_code,
            p_check_access_flag      => 'N',
            p_admin_flag             => null,
            p_admin_group_id         => null,
            p_identity_salesforce_id => G_SL_SALESFORCE_ID,
            p_access_profile_rec     => null,
            p_return_status          => G_return_status,
            p_msg_count              => G_MESG_COUNT,
            p_msg_data               => l_msg_data,
            p_interest_out_id        => l_interest_out_id) ;
    End Loop;
End do_create_interest;

----------------------------------------------------------
-- name:  do_create_LeadNoteAndContext
-- scope: private
-- calls
-- inserts sales lead Note , Note Contexts for SalesLead
-- and Party
----------------------------------------------------------
procedure do_create_LeadNoteAndContext(
            pI IN OUT NOCOPY leadImpType,
            G_return_status OUT NOCOPY varchar2) Is

	l_note_context_rec     jtf_notes_pub.jtf_note_contexts_rec_type;
	l_note_context_rec_tbl jtf_notes_pub.jtf_note_contexts_tbl_type;
	l_msg_data VARCHAR2(2000);
	l_jtf_note_id NUMBER;

    BEGIN

	--Assign values to context rec type

	l_note_context_rec.NOTE_CONTEXT_TYPE    := 'LEAD';
	l_note_context_rec.NOTE_CONTEXT_TYPE_ID := pI.sales_lead_id;
	l_note_context_rec.LAST_UPDATE_DATE     := SYSDATE;
	l_note_context_rec.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
	l_note_context_rec.CREATION_DATE        := SYSDATE;
	l_note_context_rec.CREATED_BY           := FND_GLOBAL.USER_ID;
	l_note_context_rec.LAST_UPDATE_LOGIN    := FND_GLOBAL.USER_ID;

	l_note_context_rec_tbl(1) := l_note_context_rec;

        -- SOLIN, bug 4227632, use 'PARTY' always
	--If pI.party_type = 'ORGANIZATION' then
	--  l_note_context_rec.NOTE_CONTEXT_TYPE    := 'PARTY_ORGANIZATION';
	--else
	  l_note_context_rec.NOTE_CONTEXT_TYPE    := 'PARTY';
	--end if;

	l_note_context_rec.NOTE_CONTEXT_TYPE_ID := pI.party_id;
	l_note_context_rec.LAST_UPDATE_DATE     := SYSDATE;
	l_note_context_rec.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
	l_note_context_rec.CREATION_DATE        := SYSDATE;
	l_note_context_rec.CREATED_BY           := FND_GLOBAL.USER_ID;
	l_note_context_rec.LAST_UPDATE_LOGIN    := FND_GLOBAL.USER_ID;

	l_note_context_rec_tbl(2) := l_note_context_rec;

	-- Call Jtf_notes_pub.create_note()

	JTF_NOTES_PUB.Create_Note (
	p_parent_note_id        => NULL
	, p_jtf_note_id         => NULL
	, p_api_version         => 1.0
	, p_init_msg_list       => 'T'
	, p_commit              => 'F'
	, p_validation_level    => 100
	, x_return_status       => G_return_status
	, x_msg_count           => G_mesg_count
	, x_msg_data            => l_msg_data
	, p_org_id              => NULL
	, p_source_object_id    => pI.sales_lead_id
	, p_source_object_code  => 'LEAD'
	, p_notes               => pI.lead_note
	, p_notes_detail        => NULL --EMPTY_CLOB()
	, p_note_status         => NULL
	, p_entered_by          => FND_GLOBAL.USER_ID
	, p_entered_date        => SYSDATE
	, x_jtf_note_id         => l_jtf_note_id
	, p_last_update_date    => SYSDATE
	, p_last_updated_by     => FND_GLOBAL.USER_ID
	, p_creation_date       => SYSDATE
	, p_created_by          => FND_GLOBAL.USER_ID
	, p_last_update_login   => FND_GLOBAL.USER_ID
	, p_attribute1          => NULL
	, p_attribute2          => NULL
	, p_attribute3          => NULL
	, p_attribute4          => NULL
	, p_attribute5          => NULL
	, p_attribute6          => NULL
	, p_attribute7          => NULL
	, p_attribute8          => NULL
	, p_attribute9          => NULL
	, p_attribute10         => NULL
	, p_attribute11         => NULL
	, p_attribute12         => NULL
	, p_attribute13         => NULL
	, p_attribute14         => NULL
	, p_attribute15         => NULL
	, p_context             => NULL
	, p_note_type           => NVL(pI.note_type,'AS_USER')
	, p_jtf_note_contexts_tab => l_note_context_rec_tbl
	);

        write_log(3, 'do_create_LeadNoteAndContext:End - Note_id - '||to_char(l_jtf_note_id));

End do_create_LeadNoteAndContext;

----------------------------------------------------------
-- name:  do_update_party
-- scope: private
-- calls
----------------------------------------------------------
procedure do_update_party(
              pI IN OUT NOCOPY leadImpType,
              G_return_status OUT NOCOPY varchar2)
IS
    l_org_rec   HZ_PARTY_V2PUB.organization_rec_type;
    l_hz_partyNumber number;
    l_hz_profile number;
    l_msg_data VARCHAR2(2000);
    l_per_rec   HZ_PARTY_V2PUB.person_rec_type;
    l_osysref varchar2(240) := Null;

Begin

    -- l_org_rec.party_rec.party_id := pI.hz_partyId;
    -- l_per_rec.party_rec.party_id := pI.hz_partyId;

    IF (pI.orig_system_reference is not null) or
       (pI.orig_system_reference <> FND_API.G_MISS_CHAR)
    THEN
        -- l_org_rec.party_rec.orig_system_reference:= pI.orig_system_reference;
        -- l_per_rec.party_rec.orig_system_reference:= pI.orig_system_reference;
        l_osysref := pI.orig_system_reference;
    else
        -- l_org_rec.party_rec.orig_system_reference := pI.import_interface_id;
        -- l_per_rec.party_rec.orig_system_reference := pI.import_interface_id;
        l_osysref := pI.import_interface_id;
    end if;

    -- The following lines were commented as this is erroring out
    -- and not supported by hz_party_pub ARHPTYSB.pls 115.72
    -- Rashmi Goyal sent an email stating that this is a non updatable column.
    -- Until that gets fixed, it was decided by Sr Management that we update
    -- the table directly.
    update hz_parties
    set orig_system_reference  = l_osysref
    where party_id = pI.party_id;

    /* ***
    If (pI.party_type = 'ORGANIZATION') then
        hz_party_pub.update_organization (
            p_api_version		=> G_api_version,
            p_init_msg_list	=> FND_API.G_FALSE,
            p_commit		    => FND_API.G_FALSE,
            p_organization_rec => l_org_rec,
            p_party_last_update_date => pI.last_update_date,
            x_return_status	=> G_return_status,
            x_msg_count		=> G_MESG_COUNT,
            x_msg_data        => l_msg_data,
            x_profile_id      => l_hz_profile,
            p_validation_level => FND_API.G_VALID_LEVEL_FULL
        );
    elsif (pI.party_type ='PERSON') then
        hz_party_pub.update_person (
            p_api_version		=> G_api_version,
            p_init_msg_list	=> FND_API.G_FALSE,
            p_commit		    => FND_API.G_FALSE,
            p_person_rec		=> l_per_rec,
            p_party_last_update_date => pI.last_update_date,
            x_profile_id      => l_hz_profile,
            x_return_status	=> G_return_status,
            x_msg_count		=> G_MESG_COUNT,
            x_msg_data        => l_msg_data,
            p_validation_level => FND_API.G_VALID_LEVEL_FULL
        );
    else
        null;
    end if;
    *** */
END do_update_party;

----------------------------------------------------------
-- Name: trans_custkey
-- Scope: Public
-- Select customer key from HZ_PARTIES when osysref matches
----------------------------------------------------------
function trans_custkey (p_osysref IN Varchar2) Return Varchar2
IS
    l_tmp hz_parties.customer_key%type;
BEGIN
    Select customer_key into l_tmp
    from hz_parties hzp
    where hzp.orig_system_reference = p_osysref
    and hzp.status = 'A'
    and rownum < 2;
    Return l_tmp;

    exception when others then
        Return Null;
END trans_custkey;


----------------------------------------------------------
-- Name: party_echeck
-- Scope: Public
-- Existence checking for parties in the same batch
----------------------------------------------------------
procedure party_echeck(p_imp_id IN Number,
                       p_party_id IN OUT NOCOPY Number,
                       p_plupd_date IN OUT NOCOPY Date,
                       p_psite_id IN OUT NOCOPY Number,
                       p_loc_id IN OUT NOCOPY Number)
IS
    Cursor exists_party (p_interface_id Number) IS
        select decode(p2.address_key,l.address_key,0,1)+
                decode(p2.country,l.country,0,2) match_rank,
               p2.party_id, p2.customer_key ,p2.address_key,
               p2.country, p2.identifying_address_flag,
               max(p2.party_id) mparty_id,
               max(p2.party_site_id) party_site_id,
               max(p2.location_id) location_id
        from (select s.customer_key, p.party_id,
                     p.last_update_date, s.address_key, s.country,
                     nvl(ps.identifying_address_flag, 'N')
                      identifying_address_flag,
                     ps.location_id, ps.party_site_id
              from as_import_interface s, hz_parties p, hz_party_sites ps
              where s.load_status = 'NEW'
                and s.import_interface_id = p_interface_id
                and p.customer_key (+) = s.customer_key
                and p.party_type (+) = s.party_type
                and p.status (+) = 'A'
                and ps.status (+) = 'A'
                and ps.party_id (+) = p.party_id) p2,
             hz_locations l
        where l.country (+) = p2.country
          and l.location_id (+) = p2.location_id
        group by decode(p2.address_key,l.address_key,0,1)+
                  decode(p2.country,l.country,0,2),
                 p2.party_id, p2.identifying_address_flag,
                 p2.customer_key, p2.address_key, p2.country
        order by match_rank asc, identifying_address_flag desc,
                 party_id desc;

    l_country hz_locations.country%Type;
    l_akey hz_locations.address_key%Type;
BEGIN
    p_plupd_date := Null;
    If (p_imp_id is Null) then
        return;
    End If;
    If not (p_party_id is not null and p_psite_id is not null
            and p_loc_id is not null)
    then
        For I in exists_party (p_imp_id) Loop
            If I.match_rank = 0 then
                if (p_party_id is null or (p_party_id is not null
                                           and p_party_id = I.mparty_id))
                then
                    p_psite_id := nvl(p_psite_id, I.party_site_id);
                    p_loc_id := nvl(p_loc_id, I.location_id);
                end if;
            End If;
            p_party_id := nvl(p_party_id, I.mparty_id);
            l_akey := I.address_key;
            l_country := I.country;
            Exit;
        End Loop;
        if (p_loc_id is null) then
            select max(location_id) into p_loc_id
            from hz_locations
            where address_key = l_akey and country = l_country;
        End if;
    End If;
    if (p_party_id is not null) then
        select last_update_date into p_plupd_date
        from hz_parties
        where party_id = p_party_id and rownum = 1;
    End If;

    exception when others then
        Null;
end party_echeck;

----------------------------------------------------------
-- Name: is_duplicate_lead
-- Scope: Public
-- Sales Lead existence checking
----------------------------------------------------------
FUNCTION is_duplicate_lead (pI IN leadImpType) RETURN BOOLEAN
IS
  l_call_user_hook      BOOLEAN;
  l_duplicate_flag      VARCHAR2(1);
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
BEGIN
    -- SOLIN, add customer user hook
    -- USER HOOK standard : customer pre-processing section - mandatory
    -- l_call_user_hook := JTF_USR_HKS.Ok_to_execute('AS_IMPORT_SL_PVT','IS_DUPLICATE_LEAD','B','C');

    IF G_CALL_USER_HOOK
    THEN
        write_log(3, 'Call user_hook is true');
        AS_IMPORT_SL_CUHK.Is_Duplicate_Lead_Pre(
            p_api_version_number    =>  2.0,
            p_init_msg_list         =>  FND_API.G_FALSE,
            p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
            p_commit                =>  FND_API.G_FALSE,
            p_import_interface_id   =>  pI.import_interface_id,
            x_duplicate_flag        =>  l_duplicate_flag,
            x_return_status         =>  l_return_status,
            x_msg_count             =>  l_msg_count,
            x_msg_data              =>  l_msg_data);

        write_log(3, 'x_duplicate_flag=' || l_duplicate_flag);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_duplicate_flag = 'Y' THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    ELSE
        write_log(3, 'Call user_hook is false');
    END IF;
    -- end SOLIN

    -- return FALSE for current implementation
    RETURN FALSE;
END is_duplicate_lead;


----------------------------------------------------------
-- Name: TCA_DQM_processing
-- Scope: Private
-- Using DQM check for existance of TCA entities
-- If they do not exist in TCA repository then create new
----------------------------------------------------------

procedure TCA_DQM_processing (I IN OUT NOCOPY leadImpType, l_create_party OUT NOCOPY VARCHAR2,  l_create_party_site OUT NOCOPY VARCHAR2,
                              l_create_contact OUT NOCOPY VARCHAR2, -- l_create_contact_point OUT NOCOPY VARCHAR2,
			      l_create_location OUT NOCOPY VARCHAR2, ld_phone OUT NOCOPY VARCHAR2,
			      ld_fax OUT NOCOPY VARCHAR2, ld_email OUT NOCOPY VARCHAR2, ld_url OUT NOCOPY VARCHAR2)
IS

    -- Declare Variables for passing search criteria

    -- Pass Party search criteria in this variable
    party_cond HZ_PARTY_SEARCH.PARTY_SEARCH_REC_TYPE;
    -- Pass Party Site search criteria in this variable
    party_site_cond HZ_PARTY_SEARCH.PARTY_SITE_LIST;
    -- Pass Contact search criteria in this variable
    contact_cond HZ_PARTY_SEARCH.CONTACT_LIST;
    -- Pass Contact Point search criteria in this variable
    contact_point_cond HZ_PARTY_SEARCH.CONTACT_POINT_LIST;

    -- The Match Rule to use for the dup identification.
    l_rule_id NUMBER;

    -- The Search Context ID returned by the API.
    l_search_context_id NUMBER;

    -- Other OUT parameters returned by the API.
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

    -- API also returns the number of matches.
    l_num_matches NUMBER;

    -- Local variables
    l_org_contact_id NUMBER(15);
    l_party_id NUMBER(15);
    l_party_site_id NUMBER(15);
    l_contact_point_id NUMBER(15);
    l_creation_date DATE;
    l_score NUMBER;

    l_dup_phone varchar2(1):= 'N';
    l_dup_email varchar2(1):= 'N';
    l_dup_fax   varchar2(1):= 'N';
    l_dup_url   varchar2(1):= 'N';
    l_contact_provided varchar2(1) := 'N';

    l_orig_sys_party_found VARCHAR2(1);
    l_identifying_addr_flag VARCHAR2(1);
    l_index NUMBER(2);

    -- SOLIN, BUG 3528579
    l_activate_flag         VARCHAR2(1);
    l_status                VARCHAR2(1);
    l_object_version_number NUMBER;
    l_profile_id            NUMBER;
    l_person_rec            HZ_PARTY_V2PUB.PERSON_REC_TYPE;
    l_organization_rec      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
    -- SOLIN, BUG 3528579 end

    --l_restrict_sql VARCHAR2(4000);

    -- Cursor for getting matched party_id from hz_matched_parties_gt
    CURSOR C_matched_party(p_party_type VARCHAR2)
    IS
      SELECT HZMP.party_id, score, hzp.creation_date
      FROM   HZ_MATCHED_PARTIES_GT hzmp, HZ_PARTIES hzp
      WHERE  search_context_id = l_search_context_id
      AND    hzp.party_id = hzmp.party_id
      AND    hzp.party_type = p_party_type
      AND    nvl(hzp.status,'A') = 'A' --bug# 3319259
      ORDER BY score desc, hzp.creation_date desc;

    -- SOLIN, Bug 3528579
    -- Cursor for getting matched party_id, ignore party status
    CURSOR C_matched_party2(p_party_type VARCHAR2)
    IS
      SELECT HZMP.party_id, score, hzp.creation_date, hzp.status
          , hzp.object_version_number
      FROM   HZ_MATCHED_PARTIES_GT hzmp, HZ_PARTIES hzp
      WHERE  search_context_id = l_search_context_id
      AND    hzp.party_id = hzmp.party_id
      AND    hzp.party_type = p_party_type
      ORDER BY score desc, hzp.creation_date desc;

    -- Cursor for getting matched party_site from hz_matched_party_sites_gt
    CURSOR C_matched_party_sites
    IS
      SELECT hzmps.party_id, hzmps.party_site_id, score , hzps.creation_date
      FROM hz_matched_party_sites_gt hzmps, hz_party_sites hzps
      WHERE search_context_id = l_search_context_id
      AND hzps.party_site_id = hzmps.party_site_id
      AND hzps.party_id = hzmps.party_id
      AND nvl(hzps.status,'A') = 'A' --bug# 3319259
      ORDER BY score desc, hzps.creation_date desc;

    -- Cursor for getting matched contacts from hz_matched_contacts_gt
    CURSOR C_matched_contacts
    IS
      SELECT hzmc.party_id, hzmc.org_contact_id, score , hzoc.creation_date
      FROM hz_matched_contacts_gt hzmc, hz_org_contacts hzoc
      WHERE search_context_id = l_search_context_id
      AND hzmc.org_contact_id = hzoc.org_contact_id
      AND nvl(hzoc.status,'A') = 'A' --bug# 3319259
      ORDER BY score desc, hzoc.creation_date desc;

    -- Cursor for getting matched contact_point from hz_matched_cpts_gt
    CURSOR C_matched_contact_points(cp_type VARCHAR2, p_plt VARCHAR2)
    IS
      SELECT hzmcp.party_id, hzmcp.contact_point_id, score , hzcp.creation_date
      FROM hz_matched_cpts_gt hzmcp, hz_contact_points hzcp
      WHERE search_context_id = l_search_context_id
      AND hzmcp.contact_point_id = hzcp.contact_point_id
      AND hzcp.contact_point_type = cp_type
      AND nvl(hzcp.phone_line_type,'xx') = nvl(p_plt,'xx')
      AND nvl(hzcp.status,'A') = 'A' --bug# 3319259
      ORDER BY score desc, hzcp.creation_date desc;

    -- Cursor for getting contact_party_id and rel_party_id
    CURSOR C_get_contact_info
    IS
      SELECT decode(subject_type,'PERSON',subject_id, object_id) contact_party_id, party_id
        FROM hz_org_contacts hzoc, hz_relationships hzr
       WHERE hzoc.org_contact_id = l_org_contact_id
         AND hzr.relationship_id = hzoc.party_relationship_id
         and hzr.relationship_code = 'CONTACT_OF';

    -- Cursor for Orig_system_reference dup check
    CURSOR c_check_orig_sys_ref(p_orig_system_ref varchar)
    IS
      SELECT party_id
        FROM hz_parties hzp
       WHERE hzp.orig_system_reference = p_orig_system_ref
         AND nvl(hzp.status,'A') = 'A';
--         AND rownum < 2;

    -- Cursor for getting party_site_id given the party_id
    CURSOR C_get_party_site_id(p_party_id number)
    IS
      SELECT party_site_id, nvl(identifying_address_flag,'N')
        FROM hz_party_sites
       WHERE party_id = p_party_id
         AND nvl(start_date_active,sysdate) <= sysdate
         AND nvl(end_date_active,sysdate) >= sysdate
       ORDER BY nvl(identifying_address_flag,'N') DESC;

    -- Cursor for getting rel_party_id
    CURSOR C_get_rel_party_id(p_contact_party_id number, p_party_id number)
    IS
    SELECT party_id
      FROM hz_relationships hzr
     WHERE hzr.relationship_code in ('CONTACT_OF','EMPLOYEE_OF')
       AND subject_id in (p_contact_party_id, p_party_id)
       AND object_id in (p_contact_party_id, p_party_id)
       AND hzr.status = 'A'
       AND nvl(hzr.start_date,sysdate) <= sysdate
       AND nvl(hzr.end_date,sysdate) >= sysdate;

BEGIN

    l_create_party := 'N';
--    l_create_contact_point := 'N';
    l_create_party_site := 'N';
    l_create_location := 'N';
    l_create_contact := 'N';

    l_dup_phone := 'N';
    l_dup_email := 'N';
    l_dup_fax   := 'N';
    l_dup_url   := 'N';


    -- Data Assignment to DQM datatypes

    -- 1. Pass Party search criteria in party_cond

    party_cond.party_type := I.party_type;
    IF I.party_type = 'ORGANIZATION' THEN
       party_cond.party_name := I.customer_name;
    ELSIF I.party_type = 'PERSON' THEN
       party_cond.party_name := I.first_name||' '||I.last_name;
    END IF;
    party_cond.party_all_names := party_cond.party_name;

    party_cond.party_number := I.party_number;
    party_cond.duns_number_c := I.duns_number_c;
    party_cond.tax_reference := I.tax_reference;
    party_cond.person_name := I.first_name||' '||I.last_name;
    party_cond.person_first_name := I.first_name;
    party_cond.person_last_name := I.last_name;
    party_cond.person_initials := I.person_initials;
    party_cond.person_name := I.first_name||' '||I.last_name;
    party_cond.sic_code := I.sic_code;
    party_cond.sic_code_type := I.sic_code_type;
    party_cond.category_code := I.customer_category_code;
    party_cond.year_established := I.year_established;
    party_cond.employees_total := I.num_of_employees;
    party_cond.curr_fy_potential_revenue := I.potential_revenue_curr_fy;
    party_cond.next_fy_potential_revenue := I.potential_revenue_next_fy;
    party_cond.tax_reference := I.tax_reference;
    party_cond.tax_name := I.tax_name;
    party_cond.salutation := I.salutation;
    party_cond.organization_name_phonetic := I.organization_name_phonetic;

    -- 2. Pass Party Site search criteria in party_site_cond
    party_site_cond(1).address1 := I.address1;
    party_site_cond(1).address2 := I.address2;
    party_site_cond(1).address3 := I.address3;
    party_site_cond(1).address4 := I.address4;
    party_site_cond(1).country := I.country;
    party_site_cond(1).city := I.city;
    party_site_cond(1).province := I.province;
    party_site_cond(1).postal_code := I.postal_code;
    -- SOLIN, bug 4633401
    -- add space between address?
    party_site_cond(1).address := I.address1 || ' ' || I.address2 || ' '
        || I.address3 || ' ' || I.address4;
    -- SOLIN, end
    party_site_cond(1).state := I.state;
    party_site_cond(1).county := I.county;
    party_site_cond(1).party_site_name := I.party_site_name;
    party_site_cond(1).party_site_number := I.party_site_number;
    --party_site_cond(1).floor := I.floor;
    --party_site_cond(1).house_number := I.house_number;
    --party_site_cond(1).po_box_number := I.po_box_number;
    party_site_cond(1).position := I.position;
    party_site_cond(1).postal_plus4_code := I.postal_plus4_code;
    --party_site_cond(1).street := I.street;
    --party_site_cond(1).street_suffix := I.street_suffix;
    --party_site_cond(1).street_number := I.street_number;
    --party_site_cond(1).suite := I.suite;
    party_site_cond(1).address_effective_date := I.address_effective_date;
    party_site_cond(1).mailstop := I.mailstop;
    party_site_cond(1).address_lines_phonetic := I.address_lines_phonetic;

    -- 3. Pass Contact search criteria in contact_cond
    contact_cond(1).contact_name := I.first_name||' '||I.last_name;
    contact_cond(1).contact_number := I.contact_number;
    contact_cond(1).person_name := I.first_name||' '||I.last_name;
    contact_cond(1).person_first_name := I.first_name;
    contact_cond(1).person_last_name  := I.last_name;
    contact_cond(1).person_initials := I.person_initials;
    contact_cond(1).job_title  := I.job_title;
    contact_cond(1).job_title_code  := I.job_title_code;
    contact_cond(1).mail_stop  := I.mail_stop;
    contact_cond(1).content_source_type  := I.content_source_type;
    contact_cond(1).person_first_name_phonetic  := I.person_first_name_phonetic;
    contact_cond(1).person_last_name_phonetic  := I.person_last_name_phonetic;
    contact_cond(1).person_name_suffix  := I.person_name_suffix;
    contact_cond(1).person_previous_last_name  := I.person_previous_last_name;

    -- 4. Pass Contact Point search criteria in contact_point_cond
    l_index := 1;
    IF I.email_address IS NOT NULL THEN
       contact_point_cond(l_index).CONTACT_POINT_TYPE := 'EMAIL';
       contact_point_cond(l_index).EMAIL_ADDRESS := I.email_address;
       contact_point_cond(l_index).EMAIL_FORMAT := I.email_format;
       l_index := l_index + 1;
    END IF;
    IF I.phone_number IS NOT NULL THEN
       contact_point_cond(l_index).CONTACT_POINT_TYPE := 'PHONE';
       contact_point_cond(l_index).PHONE_NUMBER := I.phone_number;
       contact_point_cond(l_index).PHONE_LINE_TYPE := nvl(I.phone_type,'GEN');
       contact_point_cond(l_index).PHONE_AREA_CODE := I.area_code;
       contact_point_cond(l_index).PHONE_EXTENSION := I.extension;
       contact_point_cond(l_index).PHONE_COUNTRY_CODE := I.phone_country_code;

       contact_point_cond(l_index).raw_phone_number:= I.phone_country_code||I.area_code||I.phone_number;
       contact_point_cond(l_index).flex_format_phone_number:= I.phone_country_code||I.area_code||I.phone_number;

       l_index := l_index + 1;
    END IF;
    IF I.fax_number IS NOT NULL THEN
       contact_point_cond(l_index).CONTACT_POINT_TYPE := 'PHONE';
       contact_point_cond(l_index).PHONE_LINE_TYPE := 'FAX';
       contact_point_cond(l_index).PHONE_NUMBER := I.fax_number;
       contact_point_cond(l_index).PHONE_AREA_CODE := I.fax_area_code;
       contact_point_cond(l_index).PHONE_EXTENSION := I.fax_extension;
       contact_point_cond(l_index).PHONE_COUNTRY_CODE := I.fax_country_code;

       --bmuthukr modified the following code to pass fax# details to fix bug 3748665
       --contact_point_cond(l_index).raw_phone_number:= I.phone_country_code||I.area_code||I.phone_number;
       --contact_point_cond(l_index).flex_format_phone_number:= I.phone_country_code||I.area_code||I.phone_number;
       contact_point_cond(l_index).raw_phone_number:= I.fax_country_code||I.fax_area_code||I.fax_number;
       contact_point_cond(l_index).flex_format_phone_number:= I.fax_country_code||I.fax_area_code||I.fax_number;
       --Ends changes..

       l_index := l_index + 1;
    END IF;
    IF I.url IS NOT NULL THEN
       contact_point_cond(l_index).CONTACT_POINT_TYPE := 'WEB';
       contact_point_cond(l_index).WEB_TYPE := 'http';
       contact_point_cond(l_index).URL := I.url;
    END IF;

    IF I.party_id IS NULL THEN --Skip party existance check if provided in import

      --Orig System Regerence check
      l_orig_sys_party_found := 'N';

      IF I.orig_system_reference IS NOT NULL THEN

        OPEN c_check_orig_sys_ref(I.orig_system_reference);
        FETCH c_check_orig_sys_ref INTO l_party_id;
        IF c_check_orig_sys_ref%NOTFOUND THEN
           l_orig_sys_party_found := 'N';
        ELSE
           l_orig_sys_party_found := 'Y';
        END IF;
        CLOSE c_check_orig_sys_ref;
	/*
	l_restrict_sql := null;
	FOR osr IN c_check_orig_sys_ref(I.orig_system_reference) LOOP
           l_restrict_sql := l_restrict_sql || to_char(osr.party_id) ||',';
	END LOOP;

	IF l_restrict_sql IS NULL THEN
           l_orig_sys_party_found := 'N';
	ELSE
           l_orig_sys_party_found := 'Y';
	   l_restrict_sql := ' party_id in ('|| l_restrict_sql ||'0) ';
	END IF;
	*/
      END IF;

      l_party_id := null;

      ----- Begin PARTY SEARCH -----
      -- Get rule_id from profile
      IF I.party_type = 'ORGANIZATION' THEN
         l_rule_id := to_number(FND_PROFILE.value('AS_USE_DQM_RULE_CODE_PARTY'));
      ELSIF I.party_type = 'PERSON' THEN
         l_rule_id := to_number(FND_PROFILE.value('AS_USE_DQM_RULE_CODE_PERSON'));
      ELSE
         --else bad party_type
         AS_UTILITY_PVT.Set_Message(
             p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
             p_msg_name      => 'AS_INVALID_PARTY_TYPE',
             p_token1        => 'VALUE',
             p_token1_value  => I.party_type);
             write_log (3, 'Party_type is invalid');
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      write_log(3,'#1 :: Calling FIND_PARTIES with OSR found = '||l_orig_sys_party_found);
      write_log(3,'rule_id '||to_char(l_rule_id));

      IF l_orig_sys_party_found = 'N' THEN
         -- Full search
         HZ_PARTY_SEARCH.find_parties ('T',l_rule_id, party_cond, party_site_cond, contact_cond , contact_point_cond, NULL,
                                      'N',l_search_context_id, l_num_matches, l_return_status, l_msg_count, l_msg_data);
      ELSE
--         l_restrict_sql := ' party_id in (select party_id from hz_parties where orig_system_reference = '''||I.orig_system_reference||''')';
         write_log(3,'In Restrict sql');

	 -- Restricted search by passing p_restrict_sql
         HZ_PARTY_SEARCH.find_parties ('T',l_rule_id, party_cond, party_site_cond, contact_cond , contact_point_cond,
                                      '/* SELECTIVE */ party_id in (select party_id from hz_parties where ORIG_SYSTEM_REFERENCE = '''||I.orig_system_reference||''') ',
				      'N',l_search_context_id, l_num_matches, l_return_status, l_msg_count, l_msg_data);

         IF l_num_matches = 0 THEN
            -- Full search
	    write_log(3,'performing full search');
            HZ_PARTY_SEARCH.find_parties ('T',l_rule_id, party_cond, party_site_cond, contact_cond , contact_point_cond, NULL,
                                         'N',l_search_context_id, l_num_matches, l_return_status, l_msg_count, l_msg_data);
         END IF;
      END IF;

      IF l_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.g_exc_error;
      END IF;

      write_log(3,'After find_parties matches '||to_char(l_num_matches));

      IF l_num_matches > 0 THEN
         -- A possible duplicate has been found.
         -- Get the party id the matched parties having highest score.
         -- SOLIN, Bug 3528579
         l_activate_flag := NVL(FND_PROFILE.value('AS_ACTIVATE_PARTIES_FROM_IMPORT'), 'N');
         IF l_activate_flag = 'N'
         THEN
             OPEN C_matched_party(I.party_type);
             FETCH C_matched_party INTO l_party_id, l_score, l_creation_date;
             CLOSE C_matched_party;
         ELSE
             OPEN C_matched_party2(I.party_type);
             FETCH C_matched_party2 INTO l_party_id, l_score, l_creation_date,
                 l_status, l_object_version_number;
             CLOSE C_matched_party2;

             -- activate the party if it's inactive
             IF l_status = 'I'
             THEN
                 write_log(3, 'Activating party ' || l_party_id);
                 IF I.party_type = 'ORGANIZATION'
                 THEN
                     l_organization_rec.party_rec.party_id := l_party_id;
                     l_organization_rec.party_rec.status := 'A';
                     HZ_PARTY_V2PUB.update_organization(
                       p_init_msg_list               => FND_API.G_FALSE,
                       p_organization_rec            => l_organization_rec,
                       p_party_object_version_number => l_object_version_number,
                       x_profile_id                  => l_profile_id,
                       x_return_status               => l_return_status,
                       x_msg_count                   => l_MSG_COUNT,
                       x_msg_data                    => l_msg_data
                     );
                 ELSIF I.party_type = 'PERSON'
                 THEN
                     l_person_rec.party_rec.party_id := l_party_id;
                     l_person_rec.party_rec.status := 'A';
                     HZ_PARTY_V2PUB.update_person(
                       p_init_msg_list               => FND_API.G_FALSE,
                       p_person_rec                  => l_person_rec,
                       p_party_object_version_number => l_object_version_number,
                       x_profile_id                  => l_profile_id,
                       x_return_status               => l_return_status,
                       x_msg_count                   => l_MSG_COUNT,
                       x_msg_data                    => l_msg_data
                     );
                 END IF;
                 write_log(3, 'l_return_status=' || l_return_status
                     || ',l_msg_data=' || l_msg_data);
             END IF; -- l_status = 'I'
         END IF; -- l_activate_flag = 'N'
         write_log(3, 'Matched party - '||to_char(l_party_id)||' score '
             ||to_char(l_score)||' created '||to_char(l_creation_date)
             || 'status=' || l_status || ' activate?' || l_activate_flag);
         -- SOLIN, Bug 3528579 end
         I.party_id := l_party_id;  --assign the matched party_id
	 IF I.party_id IS NOT NULL THEN
            l_create_party := 'N';
	 ELSE
	    l_create_party := 'Y';
	 END IF;
      ELSE
         write_log(3,'No party match found !');
         l_create_party := 'Y';
      END IF;

      ----- End PARTY SEARCH -----
    ELSE  -- party_id Provided
      l_create_party := 'N';
      write_log(3,'Skip party echeck - Party_id provided - '||to_char(I.party_id));
    END IF; --If party_id IS NULL

    ----- Begin PARTY SITE SEARCH -----

    IF I.party_id IS NOT NULL THEN -- do party_site search based on that party_id
      -- get party_site_id in case no address info is provided bug# 2760262
      IF I.party_site_id IS NULL AND I.address1 IS NULL THEN
        OPEN C_get_party_site_id(I.party_id);
	FETCH C_get_party_site_id INTO I.party_site_id, l_identifying_addr_flag;
        CLOSE C_get_party_site_id;
      END IF;

      IF  I.party_site_id IS NULL AND I.address1 IS NOT NULL THEN
      write_log(3,'#2 :: Calling GET_MATCHING_PARTY_SITES with party_id: '||to_char(I.party_id));

      -- SOLIN, Bug 4942209
      -- create a new rule profile for DQM party site match
      l_rule_id := to_number(FND_PROFILE.value('AS_USE_DQM_RULE_CODE_PARTY_SITE'));
      HZ_PARTY_SEARCH.get_matching_party_sites ('T',l_rule_id, I.party_id, party_site_cond,
                      contact_point_cond, l_search_context_id, l_return_status, l_msg_count, l_msg_data);

      IF l_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.g_exc_error;
      END IF;

      OPEN C_matched_party_sites;
      FETCH C_matched_party_sites INTO l_party_id, l_party_site_id, l_score, l_creation_date;
         IF C_matched_party_sites%FOUND THEN
           write_log(3,'Matched party_site - '||to_char(l_party_site_id)|| ' score '||to_char(l_score)||' created '||to_char(l_creation_date));
	   I.party_site_id := l_party_site_id;
	   SELECT location_id INTO I.location_ID
	     FROM hz_party_sites
	    WHERE party_site_id = I.party_site_id;
	    l_create_party_site := 'N';
	    l_create_location := 'N';
         ELSE
           write_log(3,'No party_site match found !');
	   l_create_party_site := 'Y';
           l_create_location := 'Y';
         END IF;
      CLOSE C_matched_party_sites;

      ELSE -- IF party_site_id is not null
        IF I.location_id IS NULL AND I.party_site_id IS NOT NULL THEN
	   SELECT location_id INTO I.location_ID
	     FROM hz_party_sites
	    WHERE party_site_id = I.party_site_id;
	END IF;
        l_create_party_site := 'N';
        l_create_location := 'N';
	write_log(3,'Skip party_site echeck - party_site_id provided- '||to_char(I.party_site_id));
      END IF;
    ELSE --if party_id is null then
       l_create_party_site := 'Y';
       l_create_location := 'Y';
    END IF;

    ----- End PARTY SITE SEARCH -----

    ----- Begin CONTACT SEARCH -----

    IF party_cond.party_type = 'ORGANIZATION' THEN --1
    IF I.contact_party_id IS NULL THEN --2
    IF I.first_name IS NOT NULL AND I.last_name IS NOT NULL THEN --3
      IF I.party_id IS NOT NULL THEN --4
        write_log(3,'#3 :: Calling GET_MATCHING_CONTACTS with party_id: '||to_char(I.party_id));

        l_rule_id := to_number(FND_PROFILE.value('AS_USE_DQM_RULE_CODE_CONTACT'));
        HZ_PARTY_SEARCH.get_matching_contacts('T',l_rule_id, I.party_id, contact_cond, contact_point_cond,
                        l_search_context_id, l_return_status, l_msg_count, l_msg_data);

        IF l_return_status <> FND_API.g_ret_sts_success THEN
          RAISE FND_API.g_exc_error;
        END IF;

        OPEN C_matched_contacts;
        FETCH C_matched_contacts INTO l_party_id, l_org_contact_id, l_score, l_creation_date;
          IF C_matched_contacts%FOUND THEN
	    OPEN C_get_contact_info;
	      FETCH C_get_contact_info INTO I.contact_party_id, I.rel_party_id;
	    CLOSE C_get_contact_info;
	    IF I.party_id is null THEN
              I.rel_party_id := null; --create new relationship as reusing contact
	    END IF;
            write_log(3,'Matched contact_party_id - '||to_char(I.contact_party_id)|| ' score '||to_char(l_score)||' created '||to_char(l_creation_date));
	    l_create_contact := 'N';
          ELSE
	    l_create_contact := 'Y';
	    write_log(3,'No contact match found !');
          END IF;
        CLOSE C_matched_contacts;
      END IF; --4 party_id is not null

      IF I.contact_party_id IS NULL THEN --4
      -- Blind search for matching person in TCA
        write_log(3, 'Contact blind search begin: using FIND_PARTIES (Person)');

        --Reset values for person search
	party_cond.party_type := 'PERSON';
        party_cond.party_name := I.first_name||' '||I.last_name;

        l_rule_id := to_number(FND_PROFILE.value('AS_USE_DQM_RULE_CODE_PERSON'));
        HZ_PARTY_SEARCH.find_parties ('T',l_rule_id, party_cond, party_site_cond, contact_cond , contact_point_cond, NULL,
                                      'N',l_search_context_id, l_num_matches, l_return_status, l_msg_count, l_msg_data);

        IF l_num_matches > 0 THEN --match found
	  OPEN C_matched_party('PERSON');
            FETCH C_matched_party INTO l_party_id, l_score, l_creation_date;
          CLOSE C_matched_party;
          write_log(3, 'Matched person - '||to_char(l_party_id)||' score '||to_char(l_score)||' created '||to_char(l_creation_date));
          I.contact_party_id := l_party_id;  --assign the matched party_id to contact_party_id
	  IF I.contact_party_id IS NOT NULL THEN
             l_create_contact := 'N';
	  ELSE
	     l_create_contact := 'Y';
	  END IF;
        ELSE
          write_log(3,'No person match found !');
          l_create_contact := 'Y';
        END IF;

      END IF; --if party_id is not null --4

    ELSE --First name, Last name not provided --3

      write_log(3, 'Contact Firstname, Lastname not provided');
      l_create_contact := 'N';
    END IF; --3

    ELSE -- if I.contact_party_id is not null --2
      IF I.rel_party_id IS NULL and I.party_id IS NOT NULL THEN
        OPEN C_get_rel_party_id(I.contact_party_id, I.party_id);
	FETCH C_get_rel_party_id INTO I.rel_party_id;
        CLOSE C_get_rel_party_id;
      END IF;
      l_create_contact := 'N';
      l_contact_provided := 'Y';
      write_log(3,'Skip contact echeck- provided contact_party_id- '||to_char(I.contact_party_id));
    END IF; --2
    END IF; --1

    ----- End CONTACT SEARCH -----

    ----- Begin CONTACT POINT SEARCH -----

    IF (I.party_type = 'ORGANIZATION' and I.rel_party_id  is not null) or
       (I.party_type <> 'ORGANIZATION' and I.party_id  is not null) THEN
    IF l_contact_provided = 'N' AND I.first_name IS NOT NULL AND I.last_name IS NOT NULL THEN
    IF I.email_address IS NOT NULL or I.phone_number IS NOT NULL THEN
       write_log(3,'#4 :: Calling GET_MATCHING_CONTACT_POINTS with party_id: '||to_char(I.party_id));
       l_rule_id := to_number(FND_PROFILE.value('AS_USE_DQM_RULE_CODE_CONTACT'));
       HZ_PARTY_SEARCH.get_matching_contact_points('T',l_rule_id, I.party_id, contact_point_cond, l_search_context_id, l_return_status, l_msg_count, l_msg_data);

       IF l_return_status <> FND_API.g_ret_sts_success THEN
         RAISE FND_API.g_exc_error;
       END IF;

       -- Check EMAIL
       IF I.email_address IS NOT NULL THEN
         OPEN C_matched_contact_points('EMAIL',null);
         FETCH C_matched_contact_points INTO l_party_id, l_contact_point_id, l_score, l_creation_date;
         IF C_matched_contact_points%FOUND THEN
            write_log(3,'EMAIL found - '||to_char(l_contact_point_id)|| ' score '||to_char(l_score)||' created '||to_char(l_creation_date)||to_char(l_search_context_id));
	    l_dup_email := 'Y';
         ELSE
	    l_dup_email := 'N';
            write_log(3,'EMAIL NOT match found !');
         END IF;
         CLOSE C_matched_contact_points;
       END IF; --EMAIL

       -- Check PHONE
       IF I.phone_number IS NOT NULL THEN
         OPEN C_matched_contact_points('PHONE','GEN');
         FETCH C_matched_contact_points INTO l_party_id, l_contact_point_id, l_score, l_creation_date;
         IF C_matched_contact_points%FOUND THEN
            write_log(3,'PHONE found - '||to_char(l_contact_point_id)|| ' score '||to_char(l_score)||' created '||to_char(l_creation_date)||to_char(l_search_context_id));
	    I.phone_id := l_contact_point_id;
            l_dup_phone := 'Y';
         ELSE
            write_log(3,'PHONE NOT match found !');
            l_dup_phone := 'N';
         END IF;
         CLOSE C_matched_contact_points;
       END IF; --PHONE

       -- Check FAX
       IF I.fax_number IS NOT NULL THEN
         OPEN C_matched_contact_points('PHONE','FAX');
         FETCH C_matched_contact_points INTO l_party_id, l_contact_point_id, l_score, l_creation_date;
         IF C_matched_contact_points%FOUND THEN
            write_log(3,'FAX found - '||to_char(l_contact_point_id)|| ' score '||to_char(l_score)||' created '||to_char(l_creation_date)||to_char(l_search_context_id));
            l_dup_fax := 'Y';
         ELSE
            write_log(3,'FAX NOT match found !');
            l_dup_fax := 'N';
         END IF;
         CLOSE C_matched_contact_points;
       END IF; --FAX

       -- Check URL
       IF I.url IS NOT NULL THEN
         OPEN C_matched_contact_points('WEB',null);
         FETCH C_matched_contact_points INTO l_party_id, l_contact_point_id, l_score, l_creation_date;
         IF C_matched_contact_points%FOUND THEN
            write_log(3,'URL found - '||to_char(l_contact_point_id)|| ' score '||to_char(l_score)||' created '||to_char(l_creation_date)||to_char(l_search_context_id));
            l_dup_url := 'Y';
	 ELSE
            write_log(3,'URL NOT match found !');
            l_dup_url := 'N';
         END IF;
         CLOSE C_matched_contact_points;
       END IF; --URL
    END IF;
    END IF;
    END IF;

    ld_phone := l_dup_phone;
    ld_email := l_dup_email;
    ld_fax := l_dup_fax;
    ld_url := l_dup_url;

    ----- End CONTACT POINT SEARCH -----

END TCA_DQM_processing;


----------------------------------------------------------
-- Name: do_lead_import
-- Scope: Public
-- Sales Lead Import logic implemented
-- Calls all other provate procedures and functions
----------------------------------------------------------
procedure do_lead_import(
--              errbuf varchar2,
--              errcode varchar2,
              p_source_system in varchar2,
              p_debug_msg_flag in varchar2 := 'N',
              p_parent_request_id in number,
              p_child_request_id in number,
              p_resource_id in number, -- SOLIN, bug 4702335
              p_group_id in number -- SOLIN, bug 4702335
)
IS
    l_hz_conpartyid number;
    l_batch_unexp number := 0;
    l_batch_err number := 0;
    l_batch_succ number := 0;
    l_batch_size number := 0;
    l_duplicate_lead varchar2(1):= 'U';
    l_source_system number := 0;
    l_party_id              number;
    l_orig_sys_party_found  varchar2(1) default NULL  ;
    l_return_status       VARCHAR2(1);
    x_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

    p_dup_phone varchar2(1):= 'N';
    p_dup_email varchar2(1):= 'N';
    p_dup_fax   varchar2(1):= 'N';
    p_dup_url   varchar2(1):= 'N';

    l_lead_engines_out_rec AS_SALES_LEADS_PUB.LEAD_ENGINES_OUT_Rec_Type;
    l_error_type varchar2(100);
    l_group_id number;

--  Bugfix for concurrency control
    cursor c_main (l_parent_request_id number, l_child_request_id number) is
        select * from as_import_interface   --as_imp_sl_v
          where	request_id = l_parent_request_id
	  and   child_request_id = l_child_request_id
          and   load_status = 'RUNNING'
          and   source_system = p_source_system;

      CURSOR C_Get_Lead_Info(C_Sales_Lead_Id NUMBER) IS
      SELECT SL.CUSTOMER_ID, SL.ADDRESS_ID, SL.ASSIGN_TO_SALESFORCE_ID,
             SL.ASSIGN_TO_PERSON_ID, SL.ASSIGN_SALES_GROUP_ID,
             SL.QUALIFIED_FLAG, SL.PARENT_PROJECT,
             SL.CHANNEL_CODE, SL.DECISION_TIMEFRAME_CODE, SL.BUDGET_AMOUNT,
             SL.BUDGET_STATUS_CODE, SL.SOURCE_PROMOTION_ID, SL.STATUS_CODE,
             SL.REJECT_REASON_CODE, SL.LEAD_RANK_ID,
             -- swkhanna 5/24/02
             SL.LEAD_DATE, SL.SOURCE_SYSTEM, SL.COUNTRY
      FROM AS_SALES_LEADS SL
      WHERE SL.SALES_LEAD_ID = C_Sales_Lead_Id;

    CURSOR C_Get_SLAESFORCE(C_User_Id NUMBER) IS
      SELECT JS.RESOURCE_ID
      FROM   JTF_RS_RESOURCE_EXTNS JS
      WHERE  JS.USER_ID = C_User_Id;

    -- Cursor to select currency_code is passed null
    CURSOR C_currency_code (C_Terr_Code VARCHAR2) IS
      SELECT  DECODE (derive_type,        --enh 3098798
                      NULL, currency_code,
                      derive_type, 'EUR'
                     ) currency_code
      FROM  fnd_currencies
      WHERE issuing_territory_code = C_Terr_Code
            and nvl(start_date_active, sysdate) <= sysdate
            and nvl(end_date_active, sysdate) >= sysdate
            and enabled_flag = 'Y';

    -- Cursor for fetching rows from as_imp_cnt_pnt_interface
    CURSOR c_cnt_pnt (c_owner_type  varchar2, c_import_interface_id number)
    IS
      SELECT *
        FROM AS_IMP_CNT_PNT_INTERFACE
       WHERE owner_type = c_owner_type
         AND import_interface_id = c_import_interface_id;

    -- Find the sales group of the person being added
    -- bugfix # 2772260
    CURSOR c_get_group_id (c_resource_id NUMBER, c_rs_group_member VARCHAR2,
                       c_sales VARCHAR2, c_telesales VARCHAR2,
                       c_fieldsales VARCHAR2, c_prm VARCHAR2, c_y VARCHAR2)
    IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = c_rs_group_member --'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code in (c_sales, c_telesales, c_fieldsales, c_prm) --'SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> c_y --'Y'
      AND rrel.delete_flag <> c_y --'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = c_resource_id
      AND mem.group_id = u.group_id
      AND u.usage = c_sales --'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

    l_currency_code            VARCHAR2(15);
    l_isQualified              VARCHAR2(1);
    l_sales_lead_rec           as_sales_leads_pub.sales_lead_rec_type;
    l_sales_lead_log_id        NUMBER;
    x_sales_team_flag          VARCHAR2(1);
    l_curr_time                VARCHAR2(15);

    l_create_party VARCHAR2(1) := 'N';
    l_create_party_site VARCHAR2(1) := 'N';
    l_create_location VARCHAR2(1) := 'N';
    l_create_contact VARCHAR2(1) := 'N';
    l_dup_sales_lead_id NUMBER;

    l_validation_level NUMBER;
    l_hz_execute_api_callouts  VARCHAR2(240);

BEGIN
    G_DEBUGFLAG := p_debug_msg_flag;

    write_log(3, 'Sales Lead Import Child #'||p_child_request_id||' started at '
                 ||to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS'));

    write_log(3, 'Getting the saleasforce_id for the user ...');

    -- SOLIN, bug 4702335
    IF p_resource_id IS NOT NULL
    THEN
        G_SL_SALESFORCE_ID := p_resource_id;
        l_group_id := p_group_id;
    ELSE
        OPEN  C_Get_SLAESFORCE(fnd_global.user_id);
        FETCH C_Get_SLAESFORCE INTO G_SL_SALESFORCE_ID;
        CLOSE C_Get_SLAESFORCE;

        If (G_SL_SALESFORCE_ID is null) then
            G_SL_SALESFORCE_ID := fnd_profile.value('AS_DEFAULT_RESOURCE_ID');
        end if;

        -- Find the sales group of the person being added
        -- bugfix # 2772260
        OPEN c_get_group_id (G_SL_SALESFORCE_ID, 'RS_GROUP_MEMBER', 'SALES',
                             'TELESALES', 'FIELDSALES', 'PRM', 'Y');
        FETCH c_get_group_id INTO l_group_id;
        CLOSE c_get_group_id;
    end if;
    -- SOLIN, end

    write_log(3, 'Salesforce_id for the logged in user is : ' || G_SL_SALESFORCE_ID);
    write_log(3, 'Slaes Group id : ' || l_group_id);

    -- ajchatto 050602, check for SOURCE_SYSTEM
    -- bug# 2351782
    -- Bugfix# 2835357, check if the source system is valid or not once.
    SELECT count(*)
    INTO   l_source_system
    FROM   as_lookups
    WHERE  lookup_type = 'SOURCE_SYSTEM'
    AND    lookup_code = p_source_system;

    -- SOLIN, bug 4494009
    l_hz_execute_api_callouts := fnd_profile.value('HZ_EXECUTE_API_CALLOUTS');
    write_log(3, 'Profile HZ_EXECUTE_API_CALLOUTS: '|| l_hz_execute_api_callouts);
    fnd_profile.put('HZ_EXECUTE_API_CALLOUTS', 'N');
    -- SOLIN, end

    -- For each lead
    For I in c_main(p_parent_request_id, p_child_request_id)
    Loop
        l_batch_size := l_batch_size +1;
        FND_MSG_PUB.Initialize;

    Begin

        IF I.party_type IS NULL THEN
	   I.party_type := 'ORGANIZATION';
	END IF;

        -- resetting flag bug# 2574165
        l_orig_sys_party_found := NULL;
        l_duplicate_lead := 'U';
	l_dup_sales_lead_id := NULL;
        write_log(3, 'Processing import_interface_id: '||to_char(I.import_interface_id));

       IF l_source_system < 1 THEN
           AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'SOURCE_SYSTEM',
              p_token2        => 'VALUE',
              p_token2_value  => I.SOURCE_SYSTEM );
           RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Begin enh: Support for Currency : aanjaria 100402
     IF I.currency_code IS NULL AND I.budget_amount IS NOT NULL THEN
        -- SOLIN, Bug 4956232
        -- throw exception, not get currency_code for not null budget_amount
        AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'API_INVALID_ID',
            p_token1        => 'COLUMN',
            p_token1_value  => 'CURRENCY_CODE',
            p_token2        => 'VALUE',
            p_token2_value  => 'NULL' );
        write_log(3, 'Please enter currency_code when your budget_amount is entered.');
        raise FND_API.G_EXC_ERROR;

        -- Get the currency of the customer country
        --OPEN C_currency_code(I.country);
        --FETCH C_currency_code INTO l_currency_code;
        --IF C_currency_code%NOTFOUND THEN
           -- Set default currency
        --   l_currency_code := fnd_profile.value('JTF_PROFILE_DEFAULT_CURRENCY');
        --END IF;
        --CLOSE C_currency_code;
        --I.currency_code := l_currency_code;
     END IF; --if currency_code is null
     write_log(3, 'Value of currency :'||I.currency_code);
     -- End enh: Support for Currency

     -- Check profile for executing custom hook
     IF (fnd_profile.value ('AS_LEAD_IMP_EXEC_CUSTOM_CODE')='Y') Then

        write_log(3, 'Before calling custom hook for party match');
        -- Call custom hook
        aml_find_party_match_pvt.main(I,               --IN OUT param
                                      x_return_status  --OUT param
                                     );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
          write_log(3, 'aml_find_party_match failed');
          raise FND_API.G_EXC_ERROR;
       END IF;

       write_log(3, 'Returned from custom hook with party_id: '||to_char(I.party_id));

     END IF;

     --End custom hook

     --Start DQM entities processing
     --aanjaria 11.29.2002
     write_log(3, 'Start DQM - TCA Processing');

     SELECT to_char(sysdate,'yyyymmddhhmiss')
       INTO l_curr_time
       FROM dual;
     write_log(3, 'Starting DQM - TCA time: '||l_curr_time);

     TCA_DQM_processing (I, l_create_party, l_create_party_site, l_create_contact, -- l_create_contact_point,
                         l_create_location, p_dup_phone, p_dup_fax, p_dup_email, p_dup_url );
     write_log(3, 'DQM returned: '||l_create_party||l_create_party_site||l_create_contact||l_create_location||'-'||p_dup_phone||p_dup_email||p_dup_fax||p_dup_url);

     -- Check for lead duplication before creating it !
     IF I.party_id IS NOT NULL AND I.source_system <> 'INTERACTION' THEN --bug 3601263 bypass dedupe for interaction
        deDupe_Check(pI => I, x_duplicate_lead => l_duplicate_lead, x_dup_sales_lead_id => l_dup_sales_lead_id );
        write_log(3,'back from dedupe checking'||l_duplicate_lead||'-'||to_char(l_dup_sales_lead_id));
     END IF;

     IF l_duplicate_lead = 'D' THEN
        I.sales_lead_id := l_dup_sales_lead_id;
        write_log(3, 'Duplicate lead');
        I.load_status := 'DUPLICATE';
        writeBak(I, G_return_status);
        commit;
        IF ((G_return_status <> FND_API.G_RET_STS_SUCCESS) AND (G_return_status <> 'W')) THEN
           write_log(3, 'writeBak failed');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

     IF l_duplicate_lead = 'U' THEN

       -- ffang 092601, for bug 2017445, lead existence checking should
       -- be check at the begining to prevent customer/address/contact creation.
       IF Is_duplicate_lead(I) THEN
          write_log(3, 'Duplicate lead');
          I.load_status := 'DUPLICATE';
          writeBak(I, G_return_status);
          IF ((G_return_status <> FND_API.G_RET_STS_SUCCESS) AND
             (G_return_status <> 'W'))
          THEN
             write_log(3, 'writeBak failed');
             RAISE FND_API.G_EXC_ERROR;
          END IF;

       ELSE
       -- Create TCA entities

       -- Create Location
       IF l_create_location = 'Y' or I.location_id IS NULL THEN
          -- ffang 100901, for bug 2042175, if address1 or country
          -- does not exist, skip create location
          IF (I.address1 IS NOT NULL AND I.country IS NOT NULL) THEN
             write_log(3, 'Creating location');
             do_create_location(I, G_return_status);
             -- If error raise exception
             IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                write_log(3, 'Creating location failed');
                RAISE FND_API.G_EXC_ERROR;
             END IF;
	     I.new_loc_flag := 1; -- new location flag set
	  ELSE
             write_log (3, 'No add1/country-skip creating location');
          END IF;
       ELSE
          write_log (3, 'dup location:' || I.location_id);
       END IF;

       -- Create Party
       IF l_create_party = 'Y' or I.party_id IS NULL THEN
          IF I.party_type = 'ORGANIZATION' THEN
             do_create_organization(I, G_return_status);
             -- If error raise exception
             IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                write_log(3, 'Creating Organization failed');
                RAISE FND_API.G_EXC_ERROR;
             END IF;
	     I.new_party_flag := 1; --new party flag set
          ELSIF I.party_type ='PERSON' THEN
             do_create_person(I, I.party_type, G_return_status);
             -- If error raise exception
             IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                write_log(3, 'do_create_Person failed');
                RAISE FND_API.G_EXC_ERROR;
             END IF;
	     I.new_party_flag := 1; --new party flag set
          ELSE
             -- ffang 101201, bug2050535, push error message
             AS_UTILITY_PVT.Set_Message(
               p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
               p_msg_name      => 'AS_INVALID_PARTY_TYPE',
               p_token1        => 'VALUE',
               p_token1_value  => I.party_type);
               write_log (3, 'Party_type is invalid');
             -- end ffang 101201
             RAISE FND_API.G_EXC_ERROR;
          END IF; -- party_type condition end
--2851215: orig_system_reference should not be updated
/*
       ELSIF l_create_party = 'N' and I.party_id IS NOT NULL THEN
          IF I.party_type IS NOT NULL THEN
             write_log (3, 'dup party:' || I.party_id || '-' || I.party_type);
             do_update_party(I, G_return_status);
             -- If error raise exception
             IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                write_log(3, 'do_update_party failed');
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
*/
       END IF; -- l_party_found condition end

       -- Create Party Site
       IF (l_create_party_site = 'Y' or I.party_site_id IS NULL) THEN
          -- ffang 100901, for bug 2042175, if location is not
          -- created, skip create party site and party site use
          IF (I.location_id IS NOT NULL) THEN
             -- write_log(3, 'Creating party site');
             write_log(3, 'Creating party site for Organization');
             -- swkhanna 6/12/02 Bug 2404796
             -- do_create_ps_psu(I, I.party_id, 'ORG', G_return_status);
             do_create_ps_psu(I, I.party_id, I.party_type, G_return_status);
             -- If error raise exception
             IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                write_log(3, 'Creating Party Site / Use failed');
                RAISE FND_API.G_EXC_ERROR;
             END IF;
	     I.new_ps_flag := 1; --new party flag set
          ELSE
             write_log(3,'no location created-skip create PS');
          END IF;
       END IF;

       -- Create contact points for 'PERSON'
       FOR cpp in c_cnt_pnt('PERSON', I.import_interface_id) LOOP
           write_log(3, 'Creating contact points for PERSON');
           do_create_contact_points(I, cpp, 'PERSON', G_return_status);
           IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              write_log(3, 'createContactPoints for person failed');
              RAISE FND_API.G_EXC_ERROR;
           END IF;
       END LOOP;

       -- Create contacts
       IF I.party_type = 'ORGANIZATION' THEN
       IF I.contact_party_id IS NULL or l_create_contact = 'Y' THEN
          -- ffang 100901, bug 2042181, if first name or last name
          -- does not exist, skip create contact
          IF (I.first_name IS NOT NULL and I.last_name IS NOT NULL) THEN
             write_log(3, 'Creating the Contact');
             do_create_person(I, 'CONTACT', G_return_status);
             -- If error raise exception
             IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                write_log(3, 'do_create_Person-contact failed');
                RAISE FND_API.G_EXC_ERROR;
             END IF;
             I.new_con_flag := 1; -- new contact flag set
	  ELSE
             write_log(3, 'no first/last name-skip create cnt');
          END IF;
       ELSE
          write_log(3, 'dup contact: ' || I.contact_party_id);
       END IF; --create_contact = 'Y'

          -- Check and createOrgContact, Relationship and OrgContactRoles
          -- ffang 100901, for bug 2042181, if contact is not created,
          -- then don't create relationship
          IF (I.rel_party_id is NULL and I.contact_party_id is not NULL) THEN
             do_create_relationship(I, G_return_status);
             IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                write_log(3, 'createRelationship failed');
                RAISE FND_API.G_EXC_ERROR;
             END IF;
	     I.new_rel_flag := 1; -- new relationship flag set
          END IF;
       END IF; --if party_type = 'ORGANIZATION'

       -- Create Contact Point
       IF (I.party_type = 'ORGANIZATION' and I.rel_party_id  is not null) or
          (I.party_type <> 'ORGANIZATION' and I.party_id  is not null) THEN
          write_log (3, 'Creating contact point (1)');

          do_create_contact_points_old (I, p_dup_phone, p_dup_fax, p_dup_email, p_dup_url, G_return_status);
          IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             write_log(3, 'createContactPoints for contact (1) failed');
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- SOLIN, bug 4637420
          -- create_contact_preferences should be called after
          -- contact point is created.
          do_contact_preference(I, G_return_status);
          IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             write_log(3, 'createContactPreference failed');
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          -- SOLIN, end bug 4637420
       ELSE
          write_log (3, ' Contact Point Not Created ');
       END IF;

       -- create contact points (in as_imp_cnt_pnt_interface) for 'CONTACT'
       FOR cpc in c_cnt_pnt('CONTACT', I.import_interface_id) LOOP
          write_log (3, 'Creating contact point (2)');
          do_create_contact_points(I, cpc, 'CONTACT',G_return_status);
          IF G_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             write_log(3, 'createContactPoints for contact failed');
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END LOOP;

       SELECT to_char(sysdate,'yyyymmddhhmiss')
         INTO l_curr_time
         FROM dual;
       write_log(3, 'End DQM - TCA time: '||l_curr_time);


                -- After all the contact points are created
                -- check if there are at least one contact point,
                -- If not, update one of the phone contact as primary
                -- Added by Ajoy
                -- Not currently used as HZ_CONTACT_POINT_PUB.create_contact_points
                -- takes care of setting the primary flag for PHONE, EMAIL, WEB etc.

                -- validate_primary_cp (I, G_return_status);


                -- new call goes here.

                -- createSalesLead
                -- ffang 080201, for bug 1852338, check if leads is a duplicate
                -- lead or not before creating lead.
                -- ffang 092601, for bug 2017445, lead existence checking should
                -- be check at the begining to prevent customer/address/contact
                -- creation.
                -- If not is_duplicate_lead(I) THEN

                SELECT to_char(sysdate,'yyyymmddhhmiss')
                  INTO l_curr_time
                  FROM dual;
                write_log(3, 'Start Create - Process Lead time: '||l_curr_time);


                    do_create_saleslead(I, G_return_status);

                    If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
                       write_log(3, 'do_create_saleslead failed');
                       RAISE FND_API.G_EXC_ERROR;
                    End If;

                    -- Added by Ajoy, 08/21, bugfix# 2521850
                    -- If the lead creation is successful, update the import record with sales_lead_id
                    -- so that the marketing_score (lead_score) attribute can be used in rule engine
                    If G_return_status = FND_API.G_RET_STS_SUCCESS Then
                       /* --redundent update..after purge project this update is not needed
		       UPDATE  as_import_interface
                       SET     sales_lead_id = I.sales_lead_id
                       WHERE   import_interface_id = I.import_interface_id;
                       */
		       UPDATE  aml_interaction_leads
                       SET     sales_lead_id = I.sales_lead_id
                       WHERE   import_interface_id = I.import_interface_id;
                    End if;

                -- End If;

                -- createInterest
                --do_create_Interest(I, G_return_status);
                If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
                   write_log(3, 'do_create_interest failed');
                   RAISE FND_API.G_EXC_ERROR;
                End If;

                -- do_create_LeadNoteAndContext
                If ((I.sales_lead_id is not null) AND (I.party_id is not null)
                    AND ((I.lead_note is not null) OR
                         (I.lead_note  <> FND_API.G_MISS_CHAR)))
                then
                    do_create_LeadNoteAndContext(I, G_return_status);
                    If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
                       write_log(3, 'do_create_LeadNoteAndContext failed');
                       RAISE FND_API.G_EXC_ERROR;
                    End If;
                End if;

                G_LOCAL_ORG_CONTACT_ID := Null;
                G_SL_LINE_COUNT := 0;

       --Bug 3680824: non resource user can import the lead for sales campaign
       -- in which case, user validation needs to be bypassed
       IF I.source_system = 'SALES_CAMPAIGN' THEN
          l_validation_level := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM;
       ELSE
          l_validation_level := FND_API.G_VALID_LEVEL_FULL;
       END IF;

       AS_SALES_LEAD_ENGINE_PVT.Lead_Process_After_Create (
          P_Api_Version_Number	=> 2.0,
          P_Init_Msg_List       => FND_API.G_FALSE,
          P_Commit              => FND_API.G_FALSE,
          P_Validation_Level    => l_validation_level,
          P_Check_Access_Flag   => FND_API.G_MISS_CHAR,
          P_Admin_Flag          => FND_API.G_MISS_CHAR,
          P_Admin_Group_Id      => FND_API.G_MISS_NUM,
          P_identity_salesforce_id => G_SL_SALESFORCE_ID,
          P_Salesgroup_id       => l_group_id,
          P_Sales_Lead_Id       => I.sales_lead_id,
          X_Return_Status       => l_return_status,
          X_Msg_Count           => l_msg_count,
          X_Msg_Data            => l_msg_data
       );

       -- bugfix#  2891236 , should check for l_return_status
       -- Bug 2893436, it shouldn't raise exception if return status is W
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           write_log(3, 'Lead_Process_After_Create errors');
           raise FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           write_log(3, 'Lead_Process_After_Create unexp errors');
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
           write_log(3, 'Lead_Process_After_Create ' || l_return_status);
       END IF;

       SELECT to_char(sysdate,'yyyymmddhhmiss')
         INTO l_curr_time
         FROM dual;
       write_log(3, 'End Create - Process Lead time: '||l_curr_time);

                --writing bak to as_import_interface
                I.load_status := G_LOAD_STATUS_SUCC;
                writeBak(I, G_return_status);
                IF ((G_return_status <> FND_API.G_RET_STS_SUCCESS) AND
                    (G_return_status <> 'W'))
                THEN
                   write_log(3, 'writeBak failed');
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
                l_batch_succ := l_batch_succ +1;

                -- ffang 071701, bug 1888388, temporary solution
                -- the sales teams created by assign_sales_lead
                -- (update_sales_lead) should set freeze_flag to 'N'.
                -- This fix should be removed after sales lead api changed.

                -- Bugfix# 2889261, Not to update the KEEP_FLAG
                --update as_accesses_all set freeze_flag='N'
                --where sales_lead_id = I.sales_lead_id;
         End if;

    End If; -- Duplicate Lead Check
    commit;

    Exception

                when FND_API.G_EXC_ERROR Then
                    rollback;
                    l_batch_err := l_batch_err +1;
                    l_error_type := 'EXP';
                    write_errors(I,l_error_type, G_return_status );
                    If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
                        write_log(3, 'write_errors failed');
                    else
                        I.load_status := G_LOAD_STATUS_ERR;
                        writeBak(I, G_return_status);
                        If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
                            write_log(3, 'writeBak failed');
                        End if;
                    End if;
                    commit;
                when FND_API.G_EXC_UNEXPECTED_ERROR Then
                    l_batch_unexp := l_batch_unexp +1;
                    rollback;
                    l_error_type := 'UNEXP';
                    write_errors(I,l_error_type,  G_return_status );
                    If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
                        write_log(3, 'write_errors failed');
                    else
                       I.load_status := G_LOAD_STATUS_UNEXP_ERR;
                       writeBak(I, G_return_status);
                       If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
                           write_log(3, 'writeBak failed');
                       End if;
                    End if;
                    commit;
                when others then
                    l_batch_unexp := l_batch_unexp +1;
                    rollback;
                    l_error_type := 'OTHER';
                    write_errors(I,l_error_type, G_return_status );
                    If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
                      write_log(3, 'write_errors failed');
                    else
                       I.load_status := G_LOAD_STATUS_UNEXP_ERR;
                       writeBak(I, G_return_status);
                       If G_return_status <> FND_API.G_RET_STS_SUCCESS Then
                           write_log(3, 'writeBak failed');
                           End if;
                    End if;
                    commit;
    End;
    End Loop;

    -- SOLIN, bug 4494009
    -- Set profile back to its original value
    fnd_profile.put('HZ_EXECUTE_API_CALLOUTS', l_hz_execute_api_callouts);
    -- SOLIN, end

    write_log(2, 'Batch Size:'|| l_batch_size);
    write_log(1, 'Batch Size:'|| l_batch_size);
    write_log(2, 'Number of Records Successfully Imported:'|| l_batch_succ);
    write_log(1, 'Number of Records Successfully Imported:'|| l_batch_succ);
    write_log(2, 'Number of Records with Errors:'|| l_batch_err);
    write_log(1, 'Number of Records with Errors:'|| l_batch_err);
    write_log(2, 'Number of Records with unexpected Errors:'|| l_batch_unexp);
    write_log(1, 'Number of Records with unexpected Errors:'|| l_batch_unexp);

    write_log(3, 'End Child Import Process time: '||to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS'));

    Commit;

    Exception
        when others then
           rollback;
           write_log(2, sqlerrm);
           write_log(1, sqlerrm);
           l_status := fnd_concurrent.set_completion_status('ERROR', sqlerrm);

end do_lead_import;


----------------------------------------------------------
-- Name: main
-- Scope: Public
-- Sales Lead Import parallel logic implemented
-- Main procedure called from Import Sales Lead conc prog
----------------------------------------------------------
procedure main(
    errbuf varchar2,
    errcode varchar2,
    p_source_system in varchar2,
    --p_creation_date in date, -- bugfix : 2044447
    p_debug_msg_flag in varchar2 := 'N',--bugfix : 2047689
    p_batch_id in number,
    p_purge_error_flag in varchar2 := 'N',
    p_parent_request_id in number := NULL,
    p_child_request_id in number := NULL,
    p_resource_id in number := NULL, -- SOLIN, bug 4702335
    p_group_id in number := NULL -- SOLIN, bug 4702335
    ) IS

    l_parameter_list wf_parameter_list_t;
    l_req_data               VARCHAR2(10);
    l_req_data_counter       NUMBER;
    l_batch_size             NUMBER;
    l_request_id             NUMBER;
    l_new_request_id         NUMBER;
    l_total_children         NUMBER;
    l_total_records          NUMBER;
    l_interaction_threshold  NUMBER;

    l_wait_status        BOOLEAN;
    x_phase              VARCHAR2(30);
    x_status             VARCHAR2(30);
    x_dev_phase          VARCHAR2(30);
    x_dev_status         VARCHAR2(30);
    x_message            VARCHAR2(240);

    TYPE request_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_request_id_tbl request_id_tbl;

    -- SOLIN, bug 4556394, SQL tuning
    CURSOR c_get_schema_name(c_table_name VARCHAR2) IS
        SELECT owner
        FROM sys.all_tables
        WHERE table_name = c_table_name;

    l_owner              VARCHAR2(30);
Begin

    G_DEBUGFLAG := p_debug_msg_flag;

    If p_child_request_id IS NOT NULL THEN
       write_log(3, 'Starting child process# '||p_child_request_id);
       do_lead_import(
              p_source_system,
              p_debug_msg_flag,
              p_parent_request_id,
              p_child_request_id,
              p_resource_id,
              p_group_id);

    Elsif p_child_request_id is NULL THEN

    write_log(3, 'Starting Main Lead Import Process time: '||to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS'));

    /* Create parameter list for LeadImport events */
    l_parameter_list := WF_PARAMETER_LIST_T();

    wf_event.AddParameterToList(p_name => 'P_SOURCE_SYSTEM',
                                p_value => p_source_system,
                                p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(p_name => 'P_BATCH_ID',
                                p_value => p_batch_id,
                                p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(p_name => 'P_DEBUG_MSG_FLAG',
                                p_value => p_debug_msg_flag,
                                p_parameterlist => l_parameter_list);

    wf_event.AddParameterToList(p_name => 'P_PURGE_ERROR_FLAG',
                                p_value => p_purge_error_flag,
                                p_parameterlist => l_parameter_list);

    /*** Raise LeadImport-PRE Event ***/
    write_log(1, 'Calling LeadImport-PRE Event');
    write_log(2, 'Calling LeadImport-PRE Event');
    write_log(3, 'Calling LeadImport-PRE Event');

       Wf_Event.Raise
        ( p_event_name   =>  'oracle.apps.ams.leads.LeadsImportEvent.Pre',
          p_event_key    =>  TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS'),
          p_parameters   =>  l_parameter_list,
          p_send_date    =>  sysdate
	 );
    /*** End Event Raise ***/


    -- ffang 082301, user use parameter p_purge_error_flag to decide if
    -- purge AS_LEAD_IMPORT_ERRORS
    IF p_purge_error_flag = 'Y' THEN
        OPEN c_get_schema_name('AS_LEAD_IMPORT_ERRORS');
        FETCH c_get_schema_name INTO l_owner;
        CLOSE c_get_schema_name;

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_owner
            || '.AS_LEAD_IMPORT_ERRORS';
        -- delete from AS_LEAD_IMPORT_ERRORS;
    END IF;

    --Get conc_request_id
    l_request_id := nvl(FND_GLOBAL.conc_request_id, -1);

    --Get the batch size for each thread from profile
    l_batch_size := nvl(to_number(FND_PROFILE.value('AS_MIN_REC_PARALLEL_FOR_IMPORT')),0);

    --Get interaction threshold
    l_interaction_threshold := nvl(FND_PROFILE.value('AS_INTERACTION_SCORE_THRESHOLD'),0);

    --If profile is set to -ve value
    If l_batch_size < 0 then
       l_batch_size := 0;
    End if;

    if p_batch_id > 0 then
      write_log(3, 'batch_id is found ');
      -- Update load_status to RUNNING
      UPDATE as_import_interface
         SET load_status = 'RUNNING', request_id = l_request_id,
	     child_request_id = ceil(ROWNUM/decode(l_batch_size,0,ROWNUM,l_batch_size))
       WHERE batch_id = p_batch_id
         AND source_system = p_source_system
         AND load_status = 'NEW'
	 AND decode(source_system,'INTERACTION',interaction_score,l_interaction_threshold) >= l_interaction_threshold;
    else
      write_log(3, 'batch_id is null ');
      UPDATE as_import_interface
         SET load_status = 'RUNNING', request_id = l_request_id,
	     child_request_id = ceil(ROWNUM/decode(l_batch_size,0,ROWNUM,l_batch_size))
       WHERE source_system = p_source_system
         AND load_status = 'NEW'
	 AND decode(source_system,'INTERACTION',interaction_score,l_interaction_threshold) >= l_interaction_threshold;
    end if;

    --total records in batch
    l_total_records := SQL%ROWCOUNT;
    write_log(1, 'Total batch size: '||l_total_records);
    write_log(2, 'Total batch size: '||l_total_records);
    write_log(3, 'Total batch size: '||l_total_records);

    COMMIT;
    write_log(3,'Updated load_status to RUNNING');

    --handle condition if batch size for parallel import is set to null or zero.
    If l_batch_size <= 0 then
       l_batch_size := l_total_records;
    End if;


    If l_total_records > 0 then
      --Calculate number of child processes required
      l_total_children := ceil(l_total_records/l_batch_size);


      l_req_data := fnd_conc_global.request_data;

      if (l_req_data is not null) then
        l_req_data_counter := to_number(l_req_data);
        l_req_data_counter := l_req_data_counter + 1;
      else
        l_req_data_counter := 1;
      end if;


      --Spawn child conc requests
      FOR child_idx IN 1..l_total_children LOOP

        l_new_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      application       => 'AS',
                      program           => 'ASXSLIMP',
		      description       => 'Import Sales Leads - Child #'||to_char(child_idx),
		    --sub_request       => TRUE,
                      argument1         => p_source_system,
                      argument2         => p_debug_msg_flag,
		      argument3         => p_batch_id,
		      argument4         => p_purge_error_flag,
		      argument5         => l_request_id,
		      argument6         => child_idx,
		      argument7         => p_resource_id,
		      argument8         => p_group_id
                   );

        IF l_new_request_id = 0 THEN
	   write_log(1, 'Error during submission of child request #'||child_idx);
	   write_log(2, 'Error during submission of child request #'||child_idx);
	   write_log(3, 'Error during submission of child request #'||child_idx);
	END IF;

        write_log(1, 'Spawned child# '||to_char(child_idx)||' request_id: '||to_char(l_new_request_id));
        write_log(2, 'Spawned child# '||to_char(child_idx)||' request_id: '||to_char(l_new_request_id));
        write_log(3, 'Spawned child# '||to_char(child_idx)||' request_id: '||to_char(l_new_request_id));
	l_request_id_tbl(child_idx) := l_new_request_id;
      END LOOP;

      --Wait for children to finish
      --Bug# 3523221 changed api call to wait for children

      commit;
      FOR child_idx IN 1 .. l_request_id_tbl.count LOOP

         write_log(3, 'Waiting for child#'||to_char(child_idx));

         l_wait_status := FND_CONCURRENT.WAIT_FOR_REQUEST (
                        request_id        => l_request_id_tbl(child_idx),
                        phase             => x_phase,
                        status            => x_status,
                        dev_phase         => x_dev_phase,
                        dev_status        => x_dev_status,
                        message           => x_message
                        );

      END LOOP;

    Else -- l_total_records = 0
      write_log(3, 'Batch size: 0');
      l_total_children := 0;
    End if;


    /*** Raise LeadImport-POST Event ***/
    write_log(1, 'Calling LeadImport-POST Event');
    write_log(2, 'Calling LeadImport-POST Event');
    write_log(3, 'Calling LeadImport-POST Event');

       Wf_Event.Raise
        ( p_event_name   =>  'oracle.apps.ams.leads.LeadsImportEvent.Post',
          p_event_key    =>  TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS'),
          p_parameters   =>  l_parameter_list,
          p_send_date    =>  sysdate
	 );
    /*** End Event Raise ***/

    l_parameter_list.DELETE;

    write_log(3, 'End Parent Import Process time: '||to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS'));
    write_log(3, 'Total '||l_total_records||' records processed.');

    End if;

    Commit;

    Exception
        when others then
           rollback;
           write_log(2, sqlerrm);
           write_log(1, sqlerrm);
           l_status := fnd_concurrent.set_completion_status('ERROR', sqlerrm);

end main;

end as_import_sl_pvt;

/
