--------------------------------------------------------
--  DDL for Package Body IBE_LEAD_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_LEAD_IMPORT_PVT" AS
/* $Header: IBEVLIMB.pls 120.0 2005/05/30 02:28:42 appldev noship $ */

  G_Owner_Table_Name 	VARCHAR2(20) DEFAULT 'HZ_PARTIES';
  G_Contact_Point_Type  VARCHAR2(20) DEFAULT 'PHONE';
  G_Phone_Line_Type	VARCHAR2(20) DEFAULT 'GEN';
  G_Fax_Line_Type	VARCHAR2(20) DEFAULT 'FAX';
  G_Priority_Of_Use_Code_Day VARCHAR2(20) DEFAULT 'DAY';
  G_Priority_Of_Use_COde_Eve VARCHAR2(20) DEFAULT 'EVE';
  G_Priority_Of_Use_Code_Fax VARCHAR2(20) DEFAULT 'FAX';
  G_Debug_flag VARCHAR2(1) := 'Y';
  G_LAST_LOG_ID NUMBER;
  G_WRITE_DETAIL_LOG VARCHAR2(1) := 'Y';

  G_EMAIL_ADDRESS VARCHAR2(240);
  G_DEFAULT_SCORECARD VARCHAR2(240);
  G_DEFAULT_PROMO_CODE VARCHAR2(240);
  G_DEFAULT_RESPONSE_CODE VARCHAR2(240);

  procedure printDebug(
      p_message	     IN VARCHAR2,
      p_module	     IN VARCHAR2
  ) IS
  BEGIN
      if (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) then
         	IBE_Util.Debug(p_module || ': ' || p_message);
      end if;

      if( g_debug_flag = 'Y' ) then
		 --dbms_output.put_line(p_module || ': ' || p_message);
		 FND_FILE.PUT_LINE(FND_FILE.LOG, p_module || ': ' || p_message );
      end if;
  end printDebug;

  procedure write_log
  (
      p_status       IN NUMBER,
      p_lead_type    IN VARCHAR2,
      p_begin_date   IN DATE,
      p_end_date     IN DATE,
      p_import_mode  IN VARCHAR2,
      x_log_id	     OUT NOCOPY NUMBER
  ) IS
      l_log_id NUMBER;
      l_detail_id NUMBER;
      l_write_detail_profile VARCHAR2(255);
  Begin
     printDebug('Inside write_log', 'write_log');
     BEGIN
         select ibe_lead_import_log_s1.nextval
         into l_log_id
         From dual;
     Exception
	when NO_DATA_FOUND then
           printDebug('Failed to get nextval of ibe_lead_import_log_s', 'write_log');
           return;
     end;

     printDebug('Insert into ibe_lead_import_log', 'write_log');
     printDebug('lead_type = ' || p_lead_type, 'write_log');
     printDebug('p_begin_date = ' || p_begin_date, 'write_log');
     printDebug('p_end_date = ' || p_end_date, 'write_log');
     printDebug('p_status = ' || p_status, 'write_log');
     printDebug('p_import_mode = ' || p_import_mode, 'Write_log');

     Insert into IBE_LEAD_IMPORT_LOG
     (
	    Log_Id,
	    Begin_Date,
	    End_Date,
            Lead_Type,
	    status,
            import_mode,
            elapsed_time,
            num_imported,
            Num_failed,
            Num_success,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_updatE_login,
            security_group_id,
            object_version_number
     ) Values
     (
	    l_log_id,
	    p_begin_date,
	    p_end_date,
	    p_lead_type,
	    p_status,
            p_import_mode,
            0,
            0,
            0,
            0,
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID,
            0,
	    1
     );

     x_log_id := l_log_id;
  EXCEPTION
     when OTHERS then
         printDebug('error inserting to ibe_lead_import_details', 'write_log');
  End write_log;

  procedure update_log(
      p_status		IN NUMBER,
      p_log_id		IN NUMBER,
      p_num_success	IN NUMBER,
      p_num_Failed	IN NUMBER,
      p_num_total	IN NUMBER,
      p_elapsed_time    IN NUMBER
  ) IS
     l_log_id NUMBER := p_log_id;
  BEGIN
      update ibe_lead_import_log
      Set status = p_status,
	  num_success = p_num_success,
	  num_Failed = p_num_failed,
	  num_imported = p_num_total,
	  elapsed_time = p_elapsed_time
      Where log_id = p_log_id;
  EXCEPTION
      when No_DATA_FOUND then
     	  printDebug('Cannot update record with log_id ' || l_log_id, 'Update_log');
          printDebug('No Data Found ', 'Update_log');
          return;
      When Others then
          printDebug('Cannot update record with log_id ' || l_log_id, 'Update_Log');
          printDebug(sqlerrm, 'Update_Log');
  END Update_Log;

  procedure insert_log_details
  (
      p_message		IN VARCHAR2,
      p_header_rec	IN G_LEADS_REC,
      p_status_flag	IN VARCHAR2,
      p_purge_flag	IN VARCHAR2,
      p_log_id		IN NUMBER
  ) IS
     l_write_detail_log VARCHAR2(1) := G_WRITE_DETAIL_LOG;
     l_detail_id NUMBER;
     l_log_id NUMBER := p_log_id;
     l_last_log_id NUMBER;
     l_old_detail_id NUMBER;
  BEGIN
     printDebug('write to import detail log: ' || l_write_detail_log, 'write_log');
     printDebug('Detail_id: ' || l_detail_id || ' quote_header_id ' || p_headeR_rec.quote_header_id
		|| ' Status_Flag = ' || p_status_flag, 'write_log');



     if( p_status_flag <> FND_API.G_RET_STS_SUCCESS OR nvl(l_write_detail_log, 'Y') = 'Y' ) then
          BEGIN
              select ibe_lead_import_details_s1.nextval
              into l_detail_id
              From dual;
          Exception
             when NO_DATA_FOUND THEN
                 printDebug('Error in getting ibe_lead_import_details_s1.nextval ',  'write_log');
                 return;
          End;

	 -- this is for workaround of unique index on IBE_LEAD_IMPORT_DETAILS_U2 on column quote_header_id.
 	 -- we need to fix the index to be non unique, then this workaround can be removed.
         /*
           BEGIN
            select detail_id
	    into l_old_detail_id
            From ibe_lead_import_details
            where quote_header_id = p_header_rec.quote_header_id;

	    delete from ibe_lead_import_details
	    where quote_header_id = p_header_rec.quote_header_id;


         EXCEPTION
	    when no_data_found then
		null;
	END;

         */

         insert into IBE_LEAD_IMPORT_DETAILS
         (
             Detail_Id,
             Log_Id,
             Quote_Header_id,
             Order_Id,
             Customer_First_name,
             Customer_last_name,
             Phone_Number,
             Fax_Number,
             Email_Address,
             Notes,
             Customer_Name,
             Address1,
             Address2,
             Address3,
             City,
             State,
             Postal_Code,
             Country,
             status_Flag,
             Message,
             Creation_Date,
             Created_By,
             Last_update_date,
             Last_Updated_By,
             Last_Update_login,
             Security_Group_Id,
             Object_Version_number
         ) Values
         (
             l_detail_id,
             l_log_id,
             p_header_rec.Quote_Header_id,
             p_header_rec.Order_Id,
             ' ' ,
             ' ' ,
             ' ',
             ' ',
             ' ',
             p_header_rec.Notes,
             p_header_rec.party_name,
             null,
             null,
             null,
              null,
             null,
             null,
             null,
             p_status_flag,
             p_Message,
             sysdate,
             FND_GLOBAL.User_ID,
             sysdate,
             FND_GLOBAL.User_ID,
             FND_GLOBAL.User_ID,
             0,
             0
         );
     end if;
  EXCEPTION
     when OTHERS then
         printDebug('error inserting to ibe_lead_import_details', 'insert_log_details');
         printDebug(sqlerrm, 'insert_log_details');
  End insert_log_details;

 function formatInput (p_inString VARCHAR2 )
                      RETURN VARCHAR2 IS
  l_OutString VARCHAR2(3200);
  l_InString VARCHAR2(3200);
  begin
   l_inString := p_inString;
   while instr(l_inString,',') > 0
   loop
    l_OutString := l_OutString||trim(substr(l_inString,0,instr(l_inString,',')-1))||',';
    l_inString := substr(l_inString,instr(l_inString,',')+1);
   end loop;
   l_OutString := l_OutString||trim(l_inString);
   l_OutString := ''''||replace (l_OutString,',',''',''')||'''' ;
   return l_OutString;
 exception
  when OTHERS then
  printDebug('Err '||sqlerrm,'formatinput');
  raise;
 end;

 procedure parseInput (p_inString IN VARCHAR2,
                        p_Type     IN VARCHAR2,
                        p_keyString IN VARCHAR2,
                        p_number IN NUMBER,
                        x_QueryString OUT NOCOPY VARCHAR2)
  IS
  l_OutString VARCHAR2(3200);
  l_InString VARCHAR2(3200);

 begin

   printDebug('Starting.....','parseInput');
   l_InString := p_inString;

   delete from IBE_TEMP_TABLE where key =p_keyString;

 loop

    l_OutString := trim(substr(l_InString,1,instr(l_InString,',')-1));
    l_InString  := trim(substr(l_InString,instr(l_InString,',')+1));

   if l_OutString is not null then
     if p_Type = 'CHAR' then
      INSERT into IBE_TEMP_TABLE (KEY, CHAR_VAL) VALUES (p_keyString,l_OutString);
   elsif p_Type = 'NUM' then
      INSERT into IBE_TEMP_TABLE (KEY, NUM_VAL) VALUES (p_keyString,to_number(l_OutString));
    end if;
   end if;

  if (instr(l_InString,',') = 0 or l_InString is null ) then
       exit;
  end if;

 end loop;

  l_OutString  := l_InString;

  if l_OutString is not null then
    if p_Type = 'CHAR' then
      INSERT into IBE_TEMP_TABLE (KEY, CHAR_VAL) VALUES (p_keyString,l_OutString);
    elsif p_Type = 'NUM' then
      INSERT into IBE_TEMP_TABLE (KEY, NUM_VAL) VALUES (p_keyString,to_number(l_OutString));
   end if;
  end if;

 if p_Type = 'CHAR' then
     x_QueryString := 'SELECT CHAR_VAL FROM IBE_TEMP_TABLE WHERE KEY = :'||p_number||'';
 elsif p_Type = 'NUM' then
     x_QueryString := 'SELECT NUM_VAL FROM IBE_TEMP_TABLE WHERE KEY = :'||p_number||'';
 end if;

exception
 WHEN OTHERS then
  printDebug('Exception.....'||sqlerrm,'parseInput');
 Raise;
end;



  procedure get_Quotes_records
  (
      p_begin_date	IN DATE,
      p_end_date	IN DATE,
      p_party_number    IN VARCHAR2,
      p_promo_code      IN VARCHAR2,
      p_role_exclusion  IN VARCHAR2,
      x_quote_records OUT NOCOPY t_genref
   ) IS
      l_owner_table_name VARCHAR2(20) := 'HZ_PARTIES';
      l_contact_point_type VARCHAR2(20) := 'PHONE';
      l_phone_line_type VARCHAR2(10) := 'GEN';
      l_fax_line_type VARCHAR2(10) := 'FAX';
      l_priority_use_code_day VARCHAR2(10) := 'BUSINESS';
      l_priority_use_code_eve VARCHAR2(10) := 'EVE';
      x_order_records   t_genref;
      l_party_number_query VARCHAR2(3000) ;
      l_role_exclusion_query VARCHAR2(3000);
      l_myStmt VARCHAR2(32000);
      l_number NUMBER :=4;
      l_keyString_partynum VARCHAR2(40) := 'LEAD_QOT_PARTY_NUM';
      l_keyString_roleExcl VARCHAR2(40) := 'LEAD_QOT_ROLE_EXCLUSION';
  begin
      printDebug('inside get_Quotes_records' || p_begin_date || ' - ' || p_end_date, 'get_Quotes_records');

      parseInput (p_party_number,'CHAR',l_keyString_partynum,l_number,l_party_number_query);
      l_number:=l_number+1;
      parseInput (p_role_exclusion,'CHAR',l_keyString_roleExcl,l_number,l_role_exclusion_query);

      printDebug('p no query : '||l_party_number_query,'Get_Quotes_Records');
      printDebug('role query : '||l_role_exclusion_query,'Get_Quotes_Records');
      printDebug('Get_Quotes_Records','parse inputs over');

      l_MyStmt := ' select qh.quote_header_id, hzcp1.contact_point_id phone_id,'||
          ' hp.party_id, hp.party_name, hp.party_type, max(hps.party_site_id) party_site_id,'||
          ' hr.subject_id rel_party_id, ho.org_contact_id,'||
          ' decode(nvl(ho.decision_maker_flag, ''N''), ''Y'',''DECISION_MAKER'',''END_USER'') contact_role_code,'||
   	  ' fnd_message.get_string(''IBE'',''IBE_PRMT_STORE_CART_NUMBER'')  || qh.quote_number    Notes,'||
          ' qh.currency_code, qh.quote_header_id, qh.quote_number Order_Num,'||
   	  ' qh.creation_date Order_Creation_Date,:p_promo_code promo_code,'||
          ' qh.total_quote_price total_amount,'||
          ' fnd_message.get_string(''IBE'',''IBE_PRMT_STORE_CART_LEAD'')  lead_description, '||
          ' qh.quote_header_id SOURCE_PRIMARY_REFERENCE, qh.minisite_id SOURCE_SECONDARY_REFERENCE, '||
          ' qh.marketing_source_code_id SOURCE_PROMOTION_ID '||
          ' FROM aso_quote_headers_all qh,'||
          ' hz_cust_accounts hca, hz_parties hp,hz_parties hp2,'||
          ' hz_relationships hr,'||
          ' hz_contact_points hzcp1, '||
          ' hz_party_sites hps, hz_org_contacts ho , hz_party_site_uses hpsu'||
          ' where qh.cust_account_id = hca.cust_account_id'||
          ' and qh.order_id is null'||
          ' and hca.party_id = hp.party_id'||
          ' and qh.party_id =  hp2.party_id'||
          ' and hp.party_id = hps.party_id'||
          ' and hps.party_site_id = hpsu.party_site_id '||
          ' and hpsu.primary_per_type = ''Y'''||
          ' and hp.party_number not in ('||l_party_number_query||')'||
          ' and qh.party_id  = hr.party_id(+)'||
          ' and hr.relationship_id  = ho.party_relationship_id(+)'||
	  ' and nvl(hr.directional_flag,''F'') =''F'' '||
          ' and hp2.party_id = hzcp1.owner_table_id(+)'||
          ' and hzcp1.primary_flag (+)= ''Y'''||
          ' and hzcp1.owner_table_name (+)= '''||l_owner_table_name||''''||
          ' and hzcp1.contact_point_type (+)= '''||l_contact_point_type||''''||
          ' and hzcp1.phone_line_type (+)= '''||l_phone_line_type||''''||
          ' and hzcp1.contact_point_purpose (+)= '''||l_priority_use_code_day||''''||
          ' and qh.quote_source_code in (''IStore Account'',''IStore Oneclick'')'||
          ' and qh.resource_id is null'||
          ' and qh.QUOTE_EXPIRATION_DATE + 1  >= :p_begin_date and qh.QUOTE_EXPIRATION_DATE+ 1 <= :p_end_date'||
          ' and not exists ( SELECT hzp.party_id FROM '||
                          ' jtf_auth_principals_b p, '||
                          ' jtf_auth_principals_b p1, '||
                          ' JTF_AUTH_PRINCIPAL_MAPS c, '||
                          ' fnd_user u,  '||
                          ' hz_parties hzp '||
                          ' WHERE p1.principal_name in ('||l_role_exclusion_query||')' ||
                          ' AND p.principal_name=u.user_name '||
                          ' and u.customer_id = hzp.party_id '||
                          ' and hzp.party_id  = hp2.party_id'||
                          ' and p1.JTF_AUTH_PRINCIPAL_ID = c.JTF_AUTH_PARENT_PRINCIPAL_ID '||
                          ' and c.JTF_AUTH_PRINCIPAL_ID = p.JTF_AUTH_PRINCIPAL_ID)'||
          ' Group by '||
          ' qh.quote_header_id,'||
          ' hzcp1.contact_point_id,  hp.party_id,    hp.party_name, '||
          ' hp.party_type,  qh.invoice_to_party_site_id ,  '||
          ' hr.subject_id ,'||
          ' ho.org_contact_id,'||
          ' decode(nvl(ho.decision_maker_flag, ''N''), ''Y'', ''DECISION_MAKER'', ''END_USER''),'||
          ' qh.quote_number ,qh.total_quote_price ,'||
          ' qh.currency_code,'||
          ' qh.quote_header_id ,'||
          ' qh.quote_number ,'||
          ' qh.creation_date,'||
          ' qh.quote_header_id, qh.minisite_id,'||
          ' qh.marketing_source_code_id,'||
          ' qh.total_quote_price';

      printDebug(l_MyStmt,'Get Quote Records');

      open x_quote_records for l_myStmt using p_promo_code,l_keyString_partynum,p_begin_date, p_end_date,l_keyString_roleExcl;
  exception
   when OTHERS then
     printDebug('Err :'||sqlerrm, 'Get Quote Records');
     raise;

  End get_Quotes_Records;

  Procedure Get_Quote_Line_Records
  (
      p_quote_header_id IN NUMBER,
      x_quote_lines     OUT NOCOPY t_genref
  ) IS
  BEGIN
      printDebug('inside get_quote_line_records ' || p_quote_header_id, 'Get_Quote_Line_Records');
      open x_quote_lines for
            select ql.quote_header_id, ql.inventory_item_id, ql.organization_id,
	           ql.uom_code, sum(nvl(ql.quantity,0)) quantity,
                   msik.concatenated_segments part_no, msik.description product_description
                   ,ql.line_quote_price  line_price , ql.marketing_source_code_id promotion_id
	    From aso_quote_lines_all ql, mtl_system_items_kfv msik
            Where ql.quote_header_id = p_quote_header_id
            And ql.inventory_item_id = msik.inventory_item_id
            And ql.organization_id= msik.organization_id
	    Group by ql.quote_header_id, ql.inventory_item_id, ql.organization_id,
		ql.uom_code, msik.concatenated_segments, msik.description,
                ql.line_quote_price,ql.marketing_source_code_id
	    Order by QL.Line_Quote_price desc;
  End Get_Quote_line_Records;

  procedure get_Order_Records
  (
      p_begin_date	IN DATE,
      p_end_date	IN DATE,
      p_party_number    IN VARCHAR2,
      p_promo_code      IN VARCHAR2,
      p_role_exclusion  IN VARCHAR2,
      x_order_records   OUT NOCOPY t_genref
  ) IS
      --p_party_number    IN NUMBER,
      l_owner_table_name VARCHAR2(20) := 'HZ_PARTIES';
      l_contact_point_type VARCHAR2(20) := 'PHONE';
      l_phone_line_type VARCHAR2(10) := 'GEN';
      l_fax_line_type VARCHAR2(10) := 'FAX';
      l_priority_use_code_day VARCHAR2(10) := 'BUSINESS';
      l_priority_use_code_eve VARCHAR2(10) := 'EVE';
      l_party_number_query VARCHAR2(3000);
      l_role_exclusion_query VARCHAR2(3000);
      l_myStmt VARCHAR2(32000);
      l_number NUMBER :=4;
      l_keyString_partynum VARCHAR2(40) := 'LEAD_ORD_PARTY_NUM';
      l_keyString_roleExcl VARCHAR2(40) := 'LEAD_ORD_ROLE_EXCLUSION';
  BEGIN
      --null;
      printDebug('inside get_order_records ' || p_begin_date || ' - ' || p_end_date, 'Get_order_Records');

      parseInput (p_party_number,'CHAR',l_keyString_partynum, l_number, l_party_number_query );
      l_number:=l_number+1;
      parseInput (p_role_exclusion,'CHAR',l_keyString_roleExcl, l_number, l_role_exclusion_query);

      printDebug('p no query : '||l_party_number_query, 'Get_Order_Records');
      printDebug('role query : '||l_role_exclusion_query,'Get_Order_Records');

      l_myStmt := ' select qh.quote_header_id, hzcp1.contact_point_id phone_id,'||
         ' hp.party_id, hp.party_name, hp.party_type,'||
         ' max(hps.party_site_id) party_site_id, hr.subject_id rel_party_id,'||
         ' ho.org_contact_id,'||
         ' decode(nvl(ho.decision_maker_flag, ''N''), ''Y'',''DECISION_MAKER'' ,''END_USER'') contact_role_code,'||
   	 ' fnd_message.get_string(''IBE'',''IBE_PRMT_STORE_ORDER_NUMBER'') || oh.order_number'||
         ' || fnd_message.get_string(''IBE'',''IBE_PRMT_STORE_ORDER_REFERENCE'') || oh.orig_sys_document_ref Notes,'||
         ' qh.currency_code, qh.order_id, qh.quote_number Order_Num, qh.creation_date Order_Creation_Date,:p_promo_code promo_code,'||
         ' oe_totals_grp.Get_Order_Total(oh.header_id,null,''ALL'') total_amount,'||
         ' fnd_message.get_string(''IBE'',''IBE_PRMT_STORE_ORDER_LEAD'') lead_description, '||
         ' qh.quote_header_id SOURCE_PRIMARY_REFERENCE, qh.minisite_id SOURCE_SECONDARY_REFERENCE, '||
	 ' qh.marketing_source_code_id SOURCE_PROMOTION_ID '||
         ' FROM aso_quote_headers_all qh, oe_order_headers_all oh,'||
         ' hz_cust_accounts hca, hz_parties hp, hz_parties hp2,'||
         ' hz_relationships hr, '||
         ' hz_contact_points hzcp1, '||
         ' hz_party_sites hps, hz_org_contacts ho,hz_party_site_uses hpsu'||
         ' where qh.cust_account_id = hca.cust_account_id'||
         ' and hca.party_id = hp.party_id'||
         ' and qh.party_id  = hp2.party_id'||
         ' and hp.party_number not in ('||l_party_number_query||')'||
         ' and hp.party_id = hps.party_id'||
         ' and hps.party_site_id = hpsu.party_site_id '||
         ' and hpsu.primary_per_type = ''Y'''||
         ' and hp2.party_id  = hr.party_id(+)'||
         ' and hr.relationship_id  = ho.party_relationship_id(+)'||
         ' and hp2.party_id = hzcp1.owner_table_id(+)'||
	 ' and nvl(hr.directional_flag,''F'') = ''F'' '||
         ' and hzcp1.primary_flag (+)= ''Y'''||
         ' and hzcp1.owner_table_name (+)= '''||l_owner_table_name||''''||
         ' and hzcp1.contact_point_type (+)= '''||l_contact_point_type||''''||
         ' and hzcp1.phone_line_type (+)= '''||l_phone_line_type||''''||
         ' and hzcp1.contact_point_purpose (+)= '''||l_priority_use_code_day ||''''||
         ' and qh.quote_source_code in (''IStore Account'',''IStore Oneclick'')'||
         ' and qh.resource_id is null '||
         ' and qh.quote_header_id = oh.source_document_id '||
	    ' and qh.order_id = oh.header_id '||
         ' and not exists ( SELECT hzp.party_id'||
                          ' FROM '||
                          ' jtf_auth_principals_b p, '||
                          ' jtf_auth_principals_b p1, '||
                          ' JTF_AUTH_PRINCIPAL_MAPS c, '||
                          ' fnd_user u,  '||
                          ' hz_parties hzp '||
                          ' WHERE p1.principal_name in ('||l_role_exclusion_query||') '||
                          ' AND p.principal_name=u.user_name'||
                          ' and u.customer_id = hzp.party_id'||
                          ' and hzp.party_id  = hp2.party_id'||
                          ' and p1.JTF_AUTH_PRINCIPAL_ID = c.JTF_AUTH_PARENT_PRINCIPAL_ID '||
                          ' and c.JTF_AUTH_PRINCIPAL_ID = p.JTF_AUTH_PRINCIPAL_ID'||
                         ' )'||
         ' and oh.creation_date >= :p_begin_date and oh.creation_date < :p_end_date'||
         ' Group by  qh.quote_header_id,'||
            ' hzcp1.contact_point_id,'||
            ' hp.party_id,'||
   	    ' hp.party_name,'||
   	    ' hp.party_type,'||
            ' qh.invoice_to_party_site_id, '||
            ' hr.subject_id ,'||
            ' ho.org_contact_id,'||
            ' decode(nvl(ho.decision_maker_flag, ''N''), ''Y'', ''DECISION_MAKER'', ''END_USER'') , '||
            ' oh.order_number, oh.payment_amount, oh.payment_type_code,oh.orig_sys_document_ref  ,'||
            ' qh.currency_code,'||
            ' qh.order_id,'||
            ' qh.quote_number ,'||
            ' qh.creation_date ,'||
            ' qh.quote_header_id, qh.minisite_id,'||
            ' qh.marketing_source_code_id,'||
            ' oh.header_id';

    printDebug(l_MyStmt,'Get Order Records');

  open x_order_records for l_myStmt using p_promo_code,l_keyString_partynum,l_keyString_roleExcl,p_begin_date, p_end_date;


  Exception
   when others then
       printDebug('Err : '||sqlerrm,'Get Order Records');
       raise;

  End Get_Order_Records;

  Procedure Get_Order_Line_Records
  (
      p_order_header_id IN NUMBER,
      x_order_lines	OUT NOCOPY t_genref
  ) IS
    l_sqlStr VARCHAR2(6000);
  BEGIN
     --null;
      printDebug('inside get_order_line_records ' || p_order_header_id, 'Get_order_Line_Records');
      open x_order_lines for
	  select ql.quote_header_id, ql.inventory_item_id, ql.organization_id,
		 ql.uom_code, sum( nvl(ql.quantity, 0)) quantity,
	  	 msik.concatenated_segments part_no, msik.description product_description
                 ,ql.line_quote_price line_price ,ql.marketing_source_code_id promotion_id
          From ASO_QUOTE_LINES_ALL QL, MTL_SYSTEM_ITEMS_KFV MSIK
          Where ql.quote_header_id = p_order_header_id
          And ql.inventory_item_id = msik.inventory_item_id
	  And ql.organization_id = msik.organization_id
	  Group by ql.quote_header_id, ql.inventory_item_id, ql.organization_id,
		ql.uom_code, msik.concatenated_segments, msik.description,
                ql.line_quote_price,ql.marketing_source_code_id
          order by ql.line_quote_price desc;
  End GET_Order_Line_Records;

  procedure get_date_period
  (
      p_lead_type  IN VARCHAR2,
      p_begin_date IN  DATE,
      p_end_date   IN  DATE,
      x_import_mode OUT NOCOPY VARCHAR2,
      x_begin_Date OUT NOCOPY DATE,
      x_end_date   OUT NOCOPY DATE
  ) IS
      l_begin_date DATE;
      l_end_date   DATE;
      l_profile_values VARCHAR2(2000);
      l_interval   NUMBER;
      l_import_mode VARCHAR2(15);
  BEGIN
      printDebug('Inside get_Date_Period ' || p_lead_type, 'Get_Date_Period');
      if( p_lead_type = G_ORDER_LEAD ) then
	  l_profile_values := fnd_profile.value_specific('IBE_ORDER_LEAD_INTERVAL', null, null, null);
	  l_interval := to_number(NVL(trim(l_profile_values),'1'));
      elsif ( p_lead_type = G_QUOTE_LEAD ) then
          l_profile_values := fnd_profile.value_specific('IBE_QUOTE_LEAD_INTERVAL', null, null,null);
          l_interval := to_number(NVL(trim(l_profile_values),'1'));
      end if;

      printDebug('l_interval_profile = ' || nvl(l_profile_values, 'NULL') || ' l_interval = ' || l_interval,
	'Get_Date_Period');

      if( p_begin_date is null and p_end_date is null ) then
          BEGIN
            select max(end_date )
            into l_begin_date
	    From ibe_lead_import_log
            where status = 1
	    And lead_type = p_lead_type;
            l_import_mode := G_INCREMENTAL_IMPORT;
          EXCEPTION
	     when NO_DATA_FOUND then
		-- means this is the first time the lead import is done.
                select sysdate-1
                into l_begin_date
		from dual;
                l_import_mode := G_COMPLETE_IMPORT;
	  END;
          l_end_date := l_begin_date + l_interval;
      elsif( p_begin_date is not null and p_end_date is not null ) then
	  l_begin_date := p_begin_date;
          l_end_date := p_end_date;
          l_import_mode := G_COMPLETE_IMPORT;
      elsif( p_begin_date is null and p_end_date is not null ) then
          l_end_date := p_end_date;
          BEGIN
	      select max(end_date)
	      into l_begin_date
	      From ibe_lead_import_log
	      where status = 1
	      And lead_type = p_lead_type;
	  EXCEPTION
	      when NO_DATA_FOUND then
	         -- means this is the first time the lead import is done
	         select sysdate -1
	         into l_begin_date
		 From dual;
	  END;
          l_import_mode := G_INCREMENTAL_IMPORT;
      elsif( p_begin_date is not null and p_end_date is null ) then
	  l_begin_date := p_begin_date;
          l_end_date := l_begin_Date + l_interval;
          l_import_mode := G_INCREMENTAL_IMPORT;
      end if;

      x_begin_date := l_begin_Date;
      x_end_Date := l_end_Date;
      x_import_mode := l_import_mode;

      printDebug('x_begin_date' || x_begin_date,'get_date_period');
      printDebug('x_end_Date' || x_end_Date,'get_date_period');

  END GET_DATE_PERIOD;

  function CheckProfiles(p_lead_type IN VARCHAR2) return number IS
      l_null_profile_count NUMBER := 0;
  BEGIN

      G_EMAIL_ADDRESS := fnd_profile.value_specific('IBE_LEAD_EMAIL_ADDRESS', null, null, 671);
      if( G_EMAIL_ADDRESS is null ) then
	l_null_profile_count := l_null_profile_count + 1;
      end if;


      FND_MESSAGE.SET_NAME('IBE', 'IBE_ECR_PROFILE_TITLE');
      printOutput('*** '||FND_MESSAGE.GET || ' ****');
      if( p_lead_type = G_ORDER_LEAD ) then
          printOutput('IBE_ORDER_LEAD_INTERVAL: ' || nvl(fnd_profile.value_specific('IBE_ORDER_LEAD_INTERVAL', null, null, 671), 1));
      else
          printOutput('IBE_QUOTE_LEAD_INTERVAL: ' || nvl(fnd_profile.value_specific('IBE_QUOTE_LEAD_INTERVAL', null, null, 671), 1));
      end if;
      FND_MESSAGE.SET_NAME('IBE', 'IBE_ECR_PROFILE_VALUE');
      FND_MESSAGE.SET_NAME('NAME', 'IBE_LEAD_EMAIL_ADDRESS');
      return l_null_profile_count;
  end;


  procedure create_order_leads
  (
      p_retcode	   		OUT NOCOPY NUMBER,
      p_errmsg	   		OUT NOCOPY VARCHAR2,
      p_begin_date 		IN VARCHAR2,
      p_end_date   		IN VARCHAR2,
      p_debug_flag 		IN VARCHAR2,
      p_purge_flag 		IN VARCHAR2,
      p_write_detail_log 	IN VARCHAR2,
      p_party_number    	IN VARCHAR2,
      p_promo_code       	IN VARCHAR2,
      p_role_exclusion          IN VARCHAR2
  ) IS
      l_begin_date DATE;
      l_end_date DATE;
      l_order_csr t_genref;
      l_order_rec G_LEADS_REC;
      l_order_lines_csr t_genref;
      l_order_line_Rec G_LEAD_LINE_REC;
      l_order_line_tbl G_LEAD_LINE_TBL;
      l_return_status	VARCHAR2(1);
      l_msg_data VARCHAR2(2000);
      l_msg_count NUMBER;
      l_index NUMBER := 0;
      l_import_mode VARCHAR2(15);
      l_log_id 	NUMBER;
      l_num_success NUMBER := 0;
      l_num_failed NUMBER := 0;
      l_total NUMBER := 0;
      l_elapsed_time NUMBER := 0;
      l_start_time DATE;
      l_end_time DATE;
      l_error_msg VARCHAR2(2000);
      l_retcode 	NUMBER;
      l_status 		NUMBER := 1;
      l_profile_error NUMBER;
      --l_party_number  NUMBER;
      l_party_number  VARCHAR2(2000);
      l_role_exclusion varchar2(3000);
  BEGIN
      -- check if begin_date and end_date is null
      -- if both are null, then get the end_date of last lead import as the new begin_date
      -- and the end_date is calculated as begin_date + interval (from profile).
      -- if profile is null, default for interval is 1 day.
      -- if user only supply the begin_date, then the end_date is calculated as mentioned above.
      -- if user supplied both begin_date and end_date, use those dates.

      l_retcode := 0;

      g_debug_flag := p_debug_flag;

      If fnd_profile.value_specific('IBE_DEBUG',FND_GLOBAL.USER_ID,null,null) = 'Y' Then
        IBE_UTIL.G_DEBUGON := FND_API.G_TRUE;
      Else
	IBE_UTIL.G_DEBUGON := FND_API.G_FALSE;
      End If;

      printDebug('IBE_UTIL.G_DEBUGON=' || IBE_UTIL.G_DEBUGON, 'Create_Order_Leads');


      l_party_number := nvl(p_party_number, '-1');
      l_role_exclusion   := p_role_exclusion;


      G_WRITE_DETAIL_LOG := p_write_detail_log;
      printDebug('inside Create_Order_Leads', 'Create_Order_Leads');

      --l_profile_error := checkProfiles(G_ORDER_LEAD);

      Get_Date_Period(
	p_lead_type	=> G_ORDER_LEAD,
	p_begin_date	=> to_date(p_begin_date, 'YYYY/MM/DD HH24:MI:SS'),
	p_end_date	=> to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS'),
	x_begin_date	=> l_begin_date,
	x_end_date	=> l_end_date,
	x_import_mode	=> l_import_mode
      );

      printDebug('l_begin_date = ' || l_begin_date || ' l_end_date = ' || l_end_date, 'Create_Order_Leads');
      -- now get the header cursor and line cursor for the order to be imported as leads.
      -- loop through the cursor and call the sales lead api
      printDebug('Call GET_ORder_Records ', 'Create_Order_Leads');

      Get_Order_Records(
         p_begin_date	  => l_begin_date,
	 p_end_date    	  => l_end_date,
         p_party_number   => l_party_number,
         p_promo_code     => p_promo_code,
         p_role_exclusion => l_role_exclusion,
	 x_order_records  => l_order_csr
      );

      printDebug('Update the current log records to be inactive', 'Create_Order_lead');
      if( p_purge_flag = 'Y' ) then
          BEGIN
	    select max(log_id)
	    into G_LAST_LOG_ID
	    From ibe_lead_import_log
	    where lead_type = G_ORDER_LEAD;


	    delete From ibe_lead_import_details
	    where log_id < G_LAST_LOG_ID;



          EXCEPTION
	    when no_data_found then
	      G_LAST_LOG_ID := null;
	  END;
      end if;

      BEGIN
          update ibe_lead_import_log
          set status = 0
          where status = 1
          and lead_type = G_ORDER_LEAD;
      EXCEPTION
          when no_data_found then
	  	    printDebug('This is the first time the lead import is run', 'Create_Order_lead');
		    null;
      END;

      printDebug('Insert a new log record to IBE_LEAD_IMPORT_LOG', 'Create_Order_lead');

      write_log(
             p_status		=> l_status,
	     p_lead_type	=> G_ORDER_LEAD,
	     p_begin_Date	=> l_begin_Date,
	     p_end_Date		=> l_end_date,
	     p_import_mode	=> l_import_mode,
	     x_log_id		=> l_log_id
      );


      print_Parameter(
	p_begin_date	=> p_begin_date,
	p_end_date	=> p_end_date,
	p_debug_flag	=> p_debug_flag,
	p_purge_flag	=> p_purge_flag,
	p_write_detail_log	=> p_write_detail_log);

      select sysdate
      into l_start_time
      From dual;

      printDebug('Start Time: ' || to_char(l_start_time, 'DD-MON-YYYY HH24:MI:SS'), 'Create_Order_lead');

      LOOP
          fetch l_order_csr into l_order_rec;
          EXIT when l_order_csr%NOTFOUND;
          printDebug('----------Call Get_Order_Line_Records ' || l_order_rec.quote_header_id, 'Create_Order_Leads-------');

          --savepoint Import_Order_Lead;

          get_Order_Line_Records(
	     p_order_header_id	=> l_order_rec.quote_header_id,
	     x_order_lines	=> l_order_lines_csr
	  );

          l_index := 0;
	  LOOP
	      fetch l_order_lines_csr into l_order_line_rec;
	      EXIT when l_order_lines_csr%NOTFOUND;

              --printDebug('l_order_line_rec ' || l_index || ' inventory_item_id = ' || l_order_line_rec.inventory_item_id,
	      --  'Create_Order_Leads');
	      l_index := l_index + 1;

              --printDebug('l_order_line_rec.organization_id = ' || l_order_line_rec.organization_id, 'Create_Order_leads');
	      l_order_line_tbl(l_index) := l_order_line_rec;
	  END LOOP;
          CLOSE l_order_lines_csr;

         -- call create_sales_leads
          printDebug('********calling process_sales_lead_import', 'Create_Order_Leads**********');
          l_return_status := '';
          l_msg_data := '';
          l_msg_count := 0;

	  process_sales_lead_import(
		p_header_rec	=> l_order_rec,
		p_lines_rec_tbl => l_order_line_tbl,
		x_return_status	=> l_return_status,
		x_msg_data	=> l_msg_data,
		x_msg_count	=> l_msg_count
	  );

          l_order_line_tbl.delete;

          printDebug('after calling process_sales_lead_import ' || l_return_status || ' Num Error: ' || l_msg_count,
		'Create_Order_leads');

          l_total := l_total + 1;

          if( l_return_status = FND_API.G_RET_STS_SUCCESS ) then
              printDebug('Success process_sales_lead_import for quote ' || to_char(l_order_rec.quote_header_id),
		'Create_Order_leads');
              l_num_success := l_num_success + 1;
	  else
              printDebug('Failed process_sales_lead_import for quote ' || to_char(l_order_rec.quote_header_id),
		'Create_Order_Leads');
	      l_num_failed := l_num_failed + 1;

              if( l_msg_count > 0 ) then
                   l_msg_data := '';
		   FOR i in 1..l_msg_count LOOP
	   	      l_error_msg := l_error_msg || FND_MSG_PUB.GET(i, FND_API.G_FALSE);
                      l_error_msg := replace(l_error_msg, chr(0), ' ');
                      printDebug(l_error_msg, 'Create_order_lead');
		   END LOOP;
                   l_msg_data := FND_MSG_PUB.GET(l_msg_count, FND_API.G_FALSE);
	      end if;
              printDebug('Error Message ' || l_msg_data, 'Create_Order_leads');
          end if;

	  printDebug('Insert_Log Details ', 'Create_order_Leads');

          insert_log_details(
              p_message		=> l_error_msg,
	      p_header_Rec	=> l_order_rec,
	      p_status_flag	=> l_return_status,
              p_purge_flag	=> p_purge_flag,
	      p_log_id		=> l_log_id
	  );
      END LOOP;

      close l_order_csr;

      select sysdate
      into l_end_time
      From dual;

      printDebug('End Time: ' || to_char(l_end_date, 'DD-MON-RRRR HH24:MI:SS'), 'create_order_leads');
      l_elapsed_time := (l_end_time - l_start_time)*24*60*60;
      printDebug('Update Log with num_success ' || l_num_success || ' num_Failed ' || l_num_failed ||
	' Total ' || l_total || ' Elapsed Time: ' || l_elapsed_time, 'Create_order_leads');

      if( l_num_failed > 0 ) then
          if( l_num_failed = l_total ) then
	      l_status := -1;
          --else
	  --  l_status := 2;
          end if;
      else
	  l_status := 1;
      end if;
      update_log(
        p_status		=> l_status,
	p_log_id		=> l_log_id,
        p_num_success		=> l_num_success,
	p_num_failed		=> l_num_failed,
	p_num_total		=> l_total,
        p_elapsed_time 		=> l_elapsed_time
      );
      printDebug('Commiting', 'Create_order_leads');
      commit;

      p_retcode := 0;
      p_errmsg := 'SUCCESS';

      printDebug('Call SendEmail', 'Create_order_leads');
      sendEmail(
        p_lead_type      => G_ORDER_LEAD,
        p_status         => p_errmsg,
        p_log_id         => to_char(nvl(l_log_id, -1)),
        p_num_total      => l_total,
        p_num_failed     => l_num_failed,
        p_num_success    => l_num_success,
        p_begin_date     => l_begin_date,
        p_end_date       => l_end_date,
        p_elapsed_time   => l_elapsed_time,
        p_debug_flag     => p_debug_flag,
        p_purge_flag     => p_purge_flag,
        x_return_status  => l_return_status,
        x_msg_count      => l_msg_count,
        x_msg_data       => l_msg_data);

      if( l_return_status = FND_API.G_RET_STS_ERROR ) then
	  printDebug('Error from send_email', 'SendEmail');
	  raise FND_API.G_EXC_ERROR;
      elsif( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
	  printDebug('Error from send_email', 'SendEmail');
	   raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      printDebug('Return to main', 'Create_order_leads');
  EXCEPTION
       when others then
          p_retcode := -1;
	  FND_MESSAGE.SET_NAME('IBE', 'IBE_CREATE_ORDER_LEADS_FAILED');
          p_errmsg := FND_MESSAGE.GET;
          p_errmsg := p_errmsg || ' ' ||sqlerrm;
  End Create_Order_Leads;

  procedure create_Quote_Leads
  (
      p_retcode	   		OUT NOCOPY NUMBER,
      p_errmsg	   		OUT NOCOPY VARCHAR2,
      p_begin_date 		IN VARCHAR2,
      p_end_date   		IN VARCHAR2,
      p_debug_flag 		IN VARCHAR2,
      p_purge_flag 		IN VARCHAR2,
      p_write_detail_log 	IN VARCHAR2,
      p_party_number            IN VARCHAR2,
      p_promo_code              IN VARCHAR2,
      p_role_exclusion          IN VARCHAR2
  ) IS
      l_begin_date DATE;
      l_end_date DATE;
      l_quote_csr t_genref;
      l_quote_rec G_LEADS_REC;
      l_quote_lines_csr t_genref;
      l_quote_line_Rec G_LEAD_LINE_REC;
      l_quote_line_tbl G_LEAD_LINE_TBL;
      l_return_status	VARCHAR2(1);
      l_index 	NUMBER := 0;
      l_msg_data VARCHAR2(2000);
      l_msg_count NUMBER;
      l_num_Failed NUMBER := 0;
      l_num_success NUMBER := 0;
      l_total NUMBER := 0;
      l_log_ID NUMBER;
      l_import_mode VARCHAR2(15);
      l_elapsed_time NUMBER := 0;
      l_start_time DATE;
      l_end_time DATE;
      l_error_msg VARCHAR2(2000);
      l_status NUMBER;
      l_profile_error NUMBER;
      l_party_number VARCHAR2(3000);
      l_role_exclusion varchar2(3000);
  BEGIN
      -- check if begin_date and end_date is null
      -- if both are null, then get the end_date of last lead import as the new begin_date
      -- and the end_date is calculated as begin_date + interval (from profile).
      -- if profile is null, default for interval is 1 day.
      -- if user only supply the begin_date, then the end_date is calculated as mentioned above.
      -- if user supplied both begin_date and end_date, use those dates.

      g_debug_flag := p_debug_flag;

      If fnd_profile.value_specific('IBE_DEBUG',FND_GLOBAL.USER_ID,null,null) = 'Y' Then
        IBE_UTIL.G_DEBUGON := FND_API.G_TRUE;
      Else
	IBE_UTIL.G_DEBUGON := FND_API.G_FALSE;
      End If;

      printDebug('IBE_UTIL.G_DEBUGON=' || IBE_UTIL.G_DEBUGON, 'Create_Quote_Leads');


      printDebug('inside Create_QUOTE_Leads', 'Create_QUOTE_Leads');

      l_party_number     := nvl(p_party_number,'-1');
      l_role_exclusion   := p_role_exclusion;

      G_WRITE_DETAIL_LOG := p_write_detail_log;

      --l_profile_error := checkProfiles(G_ORDER_LEAD);

      Get_Date_Period(
	p_lead_type	=> G_QUOTE_LEAD,
	p_begin_date	=> to_date(p_begin_date, 'YYYY/MM/DD HH24:MI:SS'),
	p_end_date	=> to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS'),
	x_begin_date	=> l_begin_date,
	x_end_date	=> l_end_date,
	x_import_mode	=> l_import_mode
      );

      printDebug('l_begin_date = ' || l_begin_date || ' l_end_date = ' || l_end_date, 'Create_Quote_Leads');
      -- now get the header cursor and line cursor for the order to be imported as leads.
      -- loop through the cursor and call the sales lead api
      printDebug('Call GET_Quote_Records ', 'Create_Quote_Leads');

       Get_Quotes_Records(
         p_begin_date	  => l_begin_date,
	 p_end_date	  => l_end_date,
         p_party_number   => l_party_number,
         p_promo_code     => p_promo_code,
         p_role_exclusion => l_role_exclusion,
         x_quote_records=> l_Quote_csr
      );


      printDebug('Update the current log records to be inactive', 'Create_Quote_lead');
      if( p_purge_flag = 'Y' ) then
          BEGIN
	    select max(log_id)
	    into G_LAST_LOG_ID
	    From ibe_lead_import_log
	    where lead_type = G_QUOTE_LEAD;

            delete From ibe_lead_import_details
	    where log_id < G_LAST_LOG_ID;

          EXCEPTION
	    when no_data_found then
	      G_LAST_LOG_ID := null;
	  END;
      end if;

      BEGIN
          update ibe_lead_import_log
          set status = 0
          where status = 1
          and lead_type = G_QUOTE_LEAD;
      EXCEPTION
	  when no_data_found then
	     null;
      END;

      write_log(
             p_status		=> 1,
	     p_lead_type	=> G_QUOTE_LEAD,
	     p_begin_Date	=> l_begin_Date,
	     p_end_Date		=> l_end_date,
	     p_import_mode	=> l_import_mode,
	     x_log_id		=> l_log_id
      );

      print_Parameter(
	p_begin_date	=> p_begin_date,
	p_end_date	=> p_end_date,
	p_debug_flag	=> p_debug_flag,
	p_purge_flag	=> p_purge_flag,
	p_write_detail_log	=> p_write_detail_log);

      select sysdate
      into l_start_time
      From dual;

      printDebug('Start Time: ' || to_char(l_start_time, 'DD-MON-YYYY HH24:MI:SS'), 'Create_Quote_lead');
      LOOP
          fetch l_quote_csr into l_quote_rec;
          EXIT when l_quote_csr%NOTFOUND;
          printDebug('--------Call Get_Quote_Line_Records ' || l_Quote_rec.quote_header_id, 'Create_Quote_Leads-----');
          get_Quote_Line_Records(
	     p_quote_header_id	=> l_quote_rec.quote_header_id,
	     x_quote_lines	=> l_quote_lines_csr
	  );
          l_index := 1;
	  LOOP
	      fetch l_quote_lines_csr into l_quote_line_rec;
	      EXIT when l_quote_lines_csr%NOTFOUND;
              printDebug('l_Quote_line_rec ' || l_index || ' inventory_item_id = ' || l_Quote_line_rec.inventory_item_id,
	        'Create_Quote_Leads');
	      l_quote_line_tbl(l_index) := l_quote_line_rec;
	      l_index := l_index + 1;
              printDebug('l_Quote_line_rec.organization_id = ' || l_Quote_line_rec.organization_id, 'Create_Quote_leads');
	  END LOOP;
          close l_quote_lines_csr;

         -- call create_sales_leads
          l_return_status := '';
          l_msg_count := 0;
          l_msg_data := '';
          printDebug('****calling process_sales_lead_import', 'Create_Order_Leads*****');
	  process_sales_lead_import(
		p_header_rec	=> l_quote_rec,
		p_lines_rec_tbl => l_quote_line_tbl,
		x_return_status	=> l_return_status,
		x_msg_data	=> l_msg_data,
		x_msg_count	=> l_msg_count
	  );

           l_quote_line_tbl.delete;

          printDebug('after calling process_sales_lead_import ' || l_return_status || ' Num Error: ' || l_msg_count,
		'Create_Quote_leads');

          l_total := l_total + 1;
          if( l_return_status = FND_API.G_RET_STS_SUCCESS ) then
              printDebug('Success process_sales_lead_import for quote ' || to_char(l_Quote_rec.quote_header_id),
		'Create_Quote_leads');
              l_num_success := l_num_success + 1;
	  else
              printDebug('Failed process_sales_lead_import for quote ' || to_char(l_Quote_rec.quote_header_id),
		'Create_Quote_Leads');
	      l_num_failed := l_num_failed + 1;

              if( l_msg_count > 0 ) then
                   l_msg_data := '';
		   FOR i in 1..l_msg_count LOOP
	   	      --l_error_msg := FND_MSG_PUB.GET(i, FND_API.G_FALSE);
                      l_error_msg := l_error_msg || FND_MSG_PUB.GET(i, FND_API.G_FALSE);
                      l_error_msg := replace(l_error_msg, chr(0), ' ');
                      printDebug(l_error_msg, 'Create_Quote_leads');
		   END LOOP;
                   l_msg_data := FND_MSG_PUB.GET(l_msg_count, FND_API.G_FALSE);
	      end if;
              printDebug('Error Message ' || l_msg_data, 'Create_Quote_leads');
          end if;
	  printDebug('Insert_Log Details ', 'Create_Quote_Leads');
          insert_log_details(
              p_message		=> l_error_msg,
	      p_header_Rec	=> l_Quote_rec,
	      p_status_flag	=> l_return_status,
              p_purge_flag	=> p_purge_flag,
	      p_log_id		=> l_log_id
	  );
      END LOOP;

      close l_quote_csr;

      select sysdate
      into l_end_time
      From dual;

      printDebug('End Time: ' || to_char(l_end_date, 'DD-MON-RRRR HH24:MI:SS'), 'create_Quote_leads');
      l_elapsed_time := (l_end_time - l_start_time)*24*60*60;

      printDebug('Update Log with num_success ' || l_num_success || ' num_Failed ' || l_num_failed ||
	' Total ' || l_total || ' Elapsed Time: ' || l_elapsed_time, 'Create_Quote_leads');

      if( l_num_failed > 0 ) then
          if( l_num_failed = l_total ) then
	      l_status := -1;
          else
	    l_status := 2;
          end if;
      else
	  l_status := 1;
      end if;

      update_log(
        p_status		=> l_status,
	p_log_id		=> l_log_id,
        p_num_success		=> l_num_success,
	p_num_failed		=> l_num_failed,
	p_num_total		=> l_total,
        p_elapsed_time 		=> l_elapsed_time
      );
      printDebug('Commiting', 'Create_Quote_leads');
      commit;

      p_retcode := 0;
      p_errmsg := 'SUCCESS';
      printDebug('Return to main', 'Create_Quote_leads');
  EXCEPTION
       when others then
          p_retcode := -1;
	  FND_MESSAGE.SET_NAME('IBE', 'IBE_CREATE_QUOTE_LEADS_FAILED');
          p_errmsg := FND_MESSAGE.GET;
          p_errmsg := p_errmsg || ' ' ||sqlerrm;
  End Create_Quote_Leads;

  procedure process_sales_lead_import(
	p_header_rec		IN G_LEADS_REC,
	p_lines_rec_tbl		IN G_LEAD_LINE_TBL,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER
  ) IS
    l_return_Status VARCHAR2(1);
    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;
    l_header_rec G_LEADS_REC := p_header_rec;
    l_lines_rec_tbl G_LEAD_LINE_TBL := p_lines_rec_tbl;
    l_line_rec G_LEAD_LINE_REC;
    l_err_msg VARCHAR2(2000);
    p_import_interface_id NUMBER;
    p_interest_type_id    VARCHAR2(2000);
    p_primary_interest_code_id    VARCHAR2(2000);
    p_secondary_interest_code_id     VARCHAR2(2000);


  BEGIN
    printDebug('Inside Process_Sales_Lead_Import ', 'Process_Sales_Lead_Import (+)');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    printDebug('process_lead','p header rec.party_name  ...'||l_header_rec.PARTY_NAME);
    printDebug('process_lead','p header rec.party_id  ...'||	 l_header_rec.PARTY_ID);
    printDebug('process_lead','p header rec.party_type  ...'||	 l_header_rec.PARTY_TYPE);
    printDebug('process_lead','p header rec.party_site_id  ...'||l_header_rec.PARTY_SITE_ID);
    printDebug('process_lead','p header rec.rel_party_id  ...'||	 l_header_rec.REL_PARTY_ID);
    printDebug('process_lead','p header rec.phone_id  ...'||	 l_header_rec.PHONE_ID);
    printDebug('process_lead','p header rec.notes  ...'||	 l_header_rec.NOTES);
    printDebug('process_lead','p header rec.total_amount  ...'||	 l_header_rec.TOTAL_AMOUNT);
    printDebug('process_lead','l_header_rec.SOURCE_PRIMARY_REFERENCE  ...'||	 l_header_rec.SOURCE_PRIMARY_REFERENCE);
    printDebug('process_lead','l_header_rec.SOURCE_SECONDARY_REFERENCE  ...'||	 l_header_rec.SOURCE_SECONDARY_REFERENCE);
    printDebug('process_lead','l_header_rec.SOURCE_PROMOTION_ID  ...'||	 l_header_rec.SOURCE_PROMOTION_ID);

    printDebug('process_lead','p header rec.quote_header_id  ...'||	 l_header_rec.quote_header_id);

  select as_import_interface_s.nextval into p_import_interface_id from dual;

INSERT INTO AS_IMPORT_INTERFACE
	(
	IMPORT_INTERFACE_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	LOAD_TYPE,
	LOAD_DATE,
	LOAD_STATUS,
	CUSTOMER_NAME,
	PROMOTION_CODE,
	PARTY_ID,
	PARTY_TYPE,
	PARTY_SITE_ID,
	CONTACT_PARTY_ID,
	PHONE_ID,
	LEAD_NOTE,
	VEHICLE_RESPONSE_CODE,
	SOURCE_SYSTEM,
	CURRENCY_CODE,
	BUDGET_AMOUNT,
	ORIG_SYSTEM_REFERENCE,
	PRM_ASSIGNMENT_TYPE ,
	DESCRIPTION,
	SOURCE_PRIMARY_REFERENCE,
	SOURCE_SECONDARY_REFERENCE,
	SOURCE_PROMOTION_ID
	)
	VALUES
	(
	 p_import_interface_id,
	 sysdate,
	 FND_GLOBAL.user_id,
	 SYSDATE,
	 FND_GLOBAL.user_id,
	 FND_GLOBAL.login_id,
	 FND_GLOBAL.conc_request_id ,
	 FND_GLOBAL.prog_appl_id,
	 FND_GLOBAL.conc_program_id ,
	 SYSDATE,
	 'LEAD_LOAD',
	 SYSDATE,
	 'NEW',
	l_header_rec.PARTY_NAME,
	l_header_rec.promo_code,
	l_header_rec.PARTY_ID,
	l_header_rec.PARTY_TYPE,
	l_header_rec.PARTY_SITE_ID,
	l_header_rec.REL_PARTY_ID,
	l_header_rec.PHONE_ID,
	l_header_rec.NOTES,
	 nvl(fnd_profile.value_specific('AS_DEFAULT_LEAD_VEHICLE_RESPONSE_CODE', null, null, 671), 'EMAIL'),
	 'STORE',
	 nvl(l_header_rec.currency_code, fnd_profile.value('AS_CURRENCY_CODE')),
	l_header_rec.TOTAL_AMOUNT,
	 ' STORE ' ||l_header_rec.quote_header_id,
	 'SINGLE',
	 l_header_rec.lead_description,
	 l_header_rec.SOURCE_PRIMARY_REFERENCE,
         l_header_rec.SOURCE_SECONDARY_REFERENCE,
         l_header_rec.SOURCE_PROMOTION_ID
  );


   for  i IN 1..p_lines_rec_tbl.count
   LOOP
        printDebug('process_lead','---------------------------------------------------------------');
        printDebug('process_lead','p line rec.inventory item id  ...'||p_lines_rec_tbl(i).INVENTORY_ITEM_ID);
        printDebug('process_lead','p line rec. organization id  ...'||p_lines_rec_tbl(i).organization_id);
        printDebug('process_lead','p line rec.UOM code  ...'||p_lines_rec_tbl(i).UOM_CODE);
        printDebug('process_lead','p line rec.quantity  ...'||p_lines_rec_tbl(i).QUANTITY);
        printDebug('process_lead','p line rec.line price  ...'||p_lines_rec_tbl(i).LINE_PRICE);
        printDebug('process_lead','p line rec.promotion id  ...'||p_lines_rec_tbl(i).PROMOTION_ID);



    printDebug('Inside Process_Sales_Lead_Import ', 'Process_Sales_Lead_Import (-)');

       /** SELECT MAX(IT.INTEREST_TYPE_ID)
        into   p_interest_type_id
        from AS_INTEREST_TYPES_B IT,
        MTL_CATEGORIES_B MC,
        MTL_ITEM_CATEGORIES MIC,FND_ID_FLEX_STRUCTURES FIFS
        WHERE
        FIFS.ID_FLEX_CODE = 'MCAT' AND
        FIFS.APPLICATION_ID = 401 AND
        FIFS.ID_FLEX_STRUCTURE_CODE = 'SALES_CATEGORIES' AND
        MC.STRUCTURE_ID = FIFS.ID_FLEX_NUM AND
        MC.SEGMENT1 = TO_CHAR(IT.INTEREST_TYPE_ID) AND
        MIC.CATEGORY_ID = MC.CATEGORY_ID
        AND MIC.inventory_item_id = p_lines_rec_tbl(i).inventory_item_id
	and MIC.organization_id = p_lines_rec_tbl(i).organization_id;  **/


    -- if p_interest_type_id is not null then

        INSERT INTO AS_IMP_LINES_INTERFACE
        (
        IMP_LINES_INTERFACE_ID,
        IMPORT_INTERFACE_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        INTEREST_TYPE_ID,
        PRIMARY_INTEREST_CODE_ID,
        SECONDARY_INTEREST_CODE_ID,
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        UOM_CODE,
        QUANTITY,
        BUDGET_AMOUNT,
        SOURCE_PROMOTION_ID
        )
        VALUES
        (
         as_imp_lines_interface_s.nextval,
         p_import_interface_id,
         SYSDATE,
         FND_GLOBAL.user_id,
         SYSDATE,
         FND_GLOBAL.user_id,
         FND_GLOBAL.login_id,
         FND_GLOBAL.conc_request_id ,
         FND_GLOBAL.prog_appl_id,
         FND_GLOBAL.conc_program_id ,
         SYSDATE,
         null,
         null,
         null,
         p_lines_rec_tbl(i).inventory_item_id,
         p_lines_rec_tbl(i).organization_id,
	 p_lines_rec_tbl(i).UOM_CODE,
         p_lines_rec_tbl(i).QUANTITY,
         p_lines_rec_tbl(i).LINE_PRICE,
         p_lines_rec_tbl(i).PROMOTION_ID
        );

  -- end if;

  END LOOP;

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_Count => x_msg_count, p_data => x_msg_data);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_Count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
           FND_MESSAGE.Set_Token('ROUTINE', 'Process_Sales_lead_Import');
           FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
           FND_MESSAGE.Set_Token('REASON', SQLERRM);
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg('IBE_LEAD_IMPORT_PVT', 'Process_Sales_Lead_Import');
           END IF;
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data  => x_msg_data);
  end process_sales_lead_import;

  procedure create_sales_lead(
      p_header_rec		IN G_LEADS_REC,
      p_lines_rec_tbl		IN G_LEAD_LINE_TBL,
      x_return_status		OUT NOCOPY VARCHAR2,
      x_msg_data		OUT NOCOPY VARCHAR2,
      x_msg_count		OUT NOCOPY NUMBER,
      x_sales_lead_id		OUT NOCOPY NUMBER,
      x_sales_lead_line_out_tbl OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_TBL_TYPE,
      x_sales_lead_cnt_out_tbl  OUT NOCOPY AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_TBL_TYPE
  ) IS
    l_sales_lead_rec         as_sales_leads_pub.sales_lead_rec_type;
    l_sales_lead_line_rec    as_sales_leads_pub.sales_lead_line_rec_type;
    l_sales_lead_line_tbl    as_sales_leads_pub.sales_lead_line_tbl_type;
    l_sales_lead_contact_rec as_sales_leads_pub.sales_lead_contact_rec_type;
    l_sales_lead_contact_tbl as_sales_leads_pub.sales_lead_contact_tbl_type;
    l_sales_lead_line_out_tbl as_sales_leads_pub.sales_lead_line_out_tbl_type;
    l_sales_lead_cnt_out_tbl as_sales_leads_pub.sales_lead_cnt_out_tbl_type;
    l_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    l_sales_lead_id          NUMBER;
    l_msg_data               VARCHAR2(2000) := NULL;
    l_api_message            VARCHAR2(2000);
    l_api_name          CONSTANT VARCHAR2(30) := 'create_sales_lead';
    l_temp_promotion_id NUMBER;
    l_contact_party_id     NUMBER;
    l_retcode     VARCHAR2(1) := NULL; -- used by create_lead_note
    l_lead_note_id     NUMBER;
    l_index  NUMBER;
    l_promotion_code VARCHAR2(50) := '10000';

    CURSOR c_get_promotion_id (c_promotion_code VARCHAR2) IS
    SELECT source_code_id
    FROM ams_source_codes
    WHERE source_code = c_promotion_code
    AND active_flag = 'Y';

  BEGIN
     --null;
     -- first get the promotion_id
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := '';

--    l_promotion_code :=nvl(fnd_profile.value_specific('IBE_DEFAULT_LEAD_PROMO_CODE', null, null, 671),'10000');
    l_promotion_code := p_header_rec.PROMO_CODE;

    printDebug('Inside create_sales_lead','Create_sales_lead');
    OPEN c_get_promotion_id(l_promotion_code);
    FETCH c_get_promotion_id into l_temp_promotion_id;
    IF c_get_promotion_id%NOTFOUND THEN
	close c_get_promotion_id;
	FND_MESSAGE.SET_NAME('IBE', 'IBE_LI_INVALID_PROMOTION_CODE');
        x_msg_data := FND_MESSAGE.GET;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := x_msg_count + 1;
        printOutput(x_msg_data);
        raise FND_API.G_EXC_ERROR;
    else
	l_sales_lead_rec.source_promotion_id := l_temp_promotion_id;
    end if;

    close c_get_promotion_id;

    printDebug('l_temp_promotion_id is ' || l_temp_promotion_id, 'Create_Sales_Lead');
    l_sales_lead_rec.LEAD_NUMBER := -1;
    l_sales_lead_rec.STATUS_CODE := nvl(fnd_profile.value('AS_DEFAULT_LEAD_STATUS'),'NEW');
    l_sales_lead_rec.CUSTOMER_ID := p_header_rec.party_id;
    l_sales_lead_rec.ADDRESS_ID :=  p_header_rec.party_site_id;
    l_sales_lead_rec.ORIG_SYSTEM_REFERENCE := ' STORE ' || p_header_rec.quote_header_id;
    l_sales_lead_rec.currency_code := nvl(p_header_rec.currency_code, fnd_profile.value('AS_CURRENCY_CODE'));
    l_sales_lead_rec.prm_assignment_type := 'SINGLE';
    l_sales_lead_rec.vehicle_response_code := nvl(fnd_profile.value_specific('AS_DEFAULT_LEAD_VEHICLE_RESPONSE_CODE', null, null, 671), 'EMAIL');
    l_sales_lead_rec.budget_amount := p_header_rec.total_amount;
    l_sales_lead_rec.description   := p_header_rec.lead_description;

    l_index := 0;

    for i in 1..p_lines_rec_tbl.COUNT LOOP
        printDebug('process lines', 'Create_Sales_Lead');
        l_sales_lead_line_tbl(i).status_code := null;
        l_sales_lead_line_tbl(i).inventory_item_id := p_lines_rec_tbl(i).inventory_item_id;
	l_sales_lead_line_tbl(i).organization_id := p_lines_rec_tbl(i).organization_id;
        l_sales_lead_line_tbl(i).quantity := p_lines_rec_tbl(i).quantity;
        l_sales_lead_line_tbl(i).uom_code := p_lines_rec_tbl(i).uom_code;
        l_sales_lead_line_tbl(i).source_promotion_id := nvl(p_lines_rec_tbl(i).promotion_id,l_temp_promotion_id);
        l_sales_lead_line_tbl(i).budget_amount := p_lines_rec_tbl(i).line_price;
    END LOOP;
    printDebug('after process lines', 'Create_Sales_lead');
    -- Sales lead contact

    if( p_header_rec.rel_party_id is not null ) then
        l_sales_lead_contact_tbl(1).contact_party_id := p_header_rec.rel_party_id;
        l_sales_lead_contact_tbl(1).enabled_flag := 'Y';
        l_sales_lead_contact_tbl(1).customer_id  := p_header_rec.party_id;
       -- l_sales_lead_contact_tbl(1).address_id   := p_header_rec.party_site_id;
        l_sales_lead_contact_tbl(1).phone_id     := p_header_rec.phone_id;
        l_sales_lead_contact_tbl(1).contact_role_code     := p_header_rec.contact_role_code;
        l_sales_lead_contact_tbl(1).primary_contact_flag := 'Y';
        printDebug('contacT_party_id = ' || p_header_rec.rel_party_id || ' customer_id = ' || p_header_rec.party_id,
	    'Create_Sales_Lead');
    end if;

    printDebug('Calling as_sales_leads_pub.create_sales_lead', 'Create_Sales_Lead');
    as_sales_leads_pub.create_sales_lead(
	p_api_version_number		=> 2.0,
	p_init_msg_list			=> FND_API.G_FALSE,
	p_commit			=> FND_API.G_FALSE,
	p_validation_level		=> FND_API.G_VALID_LEVEL_FULL,
	p_check_access_flag		=> 'N',
	p_admin_flag			=> 'N',
	p_admin_group_id		=> null,
	p_identity_salesforce_id	=> null,
	p_sales_lead_profile_tbl	=> l_sales_lead_profile_tbl,
	p_sales_lead_rec		=> l_sales_lead_rec,
	p_sales_lead_line_tbl		=> l_sales_lead_line_tbl,
	p_sales_lead_contact_tbl	=> l_sales_lead_contact_tbl,
	x_sales_lead_id			=> x_sales_lead_id,
	x_return_status			=> x_return_status,
	x_msg_data			=> x_msg_data,
        x_msg_count			=> x_msg_count,
	x_sales_lead_line_out_tbl	=> x_sales_lead_line_out_tbl,
	x_sales_lead_cnt_out_tbl	=> x_sales_lead_cnt_out_tbl);


      if( x_return_status = FND_API.G_RET_STS_ERROR ) then
	  raise FND_API.G_EXC_ERROR;
      elsif( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
	   raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;


    printDebug('After calling as_sales_leads_pub.create_sales_lead ' || x_return_status, 'Create_Sales_lead');
    if( x_msg_count > 1 ) then
	For i in 1..x_msg_count LOOP
	   printDebug(FND_MSG_PUB.GET(i, FND_API.G_FALSE), 'Create_sales_lead');
        end LOOP;
    elsif( x_msg_count = 1 ) then
	printDebug(x_msg_data, 'Create_sales_lead');
    end if;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_Count => x_msg_count, p_data => x_msg_data);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_Count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
           FND_MESSAGE.Set_Token('ROUTINE', 'Process_Sales_lead_Import');
           FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
           FND_MESSAGE.Set_Token('REASON', SQLERRM);
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg('IBE_LEAD_IMPORT_PVT', 'Process_Sales_Lead_Import');
           END IF;
  End Create_Sales_Lead;

  procedure create_LeadAndNotes(
      p_sales_lead_id		IN NUMBER,
      p_lead_note		IN VARCHAR2,
      p_party_id		IN NUMBER,
      x_return_status		OUT NOCOPY VARCHAR2,
      x_msg_data		OUT NOCOPY VARCHAR2,
       x_msg_count		OUT NOCOPY NUMBER
  ) IS
  BEGIN
    null;
  END Create_LeadAndNotes;

  procedure rank_sales_lead(
      p_sales_lead_id		IN  NUMBER,
      x_return_Status		OUT NOCOPY VARCHAR2,
      x_msg_data		OUT NOCOPY VARCHAR2,
      x_msg_count		OUT NOCOPY NUMBER,
      x_rank_id			OUT NOCOPY NUMBER,
      x_score			OUT NOCOPY NUMBER
  ) IS
  BEGIN
   null;
  End Rank_Sales_Lead;


  procedure create_Interest(
	p_party_id	IN NUMBER,
	p_party_site_id IN NUMBER,
	p_lines_tbl	IN G_LEAD_LINE_TBL,
        p_contact_id	IN  NUMBER,
        p_party_type    IN  VARCHAR2,
        x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_data	OUT NOCOPY VARCHAR2,
	x_msg_count	OUT NOCOPY NUMBER
  ) IS
  BEGIN
    null;
  END Create_Interest;

  procedure Build_Sales_Team(
      p_sales_lead_id		IN  NUMBER,
      x_return_status		OUT NOCOPY VARCHAR2,
      x_msg_data		OUT NOCOPY VARCHAR2,
      x_msg_count		OUT NOCOPY NUMBER
  ) IS
  BEGIN
    null;
  End Build_Sales_Team;

  procedure Import_Quote_Lead(
      p_quote_header_id         IN NUMBER,
      x_return_status           OUT NOCOPY VARCHAR2,
      X_msg_data                OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER
  ) IS
  BEGIN
    null;
  END Import_Quote_Lead;

  procedure Import_Order_Lead(
      p_quote_header_id         IN NUMBER,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_data                OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER
  ) IS
  BEGIN
    null;
  End Import_Order_Lead;

  procedure sendEmail(
        p_lead_type             IN VARCHAR2,
        p_status                IN VARCHAR2,
        p_log_id                IN VARCHAR2,
	p_num_total		IN NUMBER,
	p_num_failed		IN NUMBER,
	p_num_success		IN NUMBER,
	p_begin_date		IN DATE,
	p_end_date		IN DATE,
	p_elapsed_time		IN NUMBER,
	p_debug_flag		IN VARCHAR2,
	p_purge_flag		IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2)
  IS
     l_email_list VARCHAR2(2000);
     l_subject VARCHAR2(2000);
     l_body VARCHAR2(2000);
     l_body2 VARCHAR2(2000);
     l_body3 VARCHAR2(2000);
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);

     cursor quote_csr is
       select log_id, num_imported, Num_failed, Num_success
       From ibe_lead_import_log
       where lead_type  = G_QUOTE_LEAD
       And status = 1 ;
     l_quote_total NUMBER := 0;
     l_quote_failed NUMBER := 0;
     l_quote_success NUMBER := 0;
     l_quote_log_id NUMBER := 0;
  BEGIN
     --null;

      l_email_list := FND_PROFILE.Value_specific('IBE_LEAD_EMAIL_ADDRESS', null, null, 671);


      if( l_email_list is null ) then
        printDebug('l_email_list is null ', 'sendEmail');
	FND_MESSAGE.set_Name('IBE', 'IBE_ECR_PROFILE_VALUE');
	FND_MESSAGE.set_Token('NAME', 'IBE_LEAD_EMAIL_ADDRESS');
	FND_MSG_PUB.Add;
	raise FND_API.G_EXC_ERROR;
      end if;

      open quote_csr;
      LOOP
	printDebug('getting the quote result', 'sendEmail');
	fetch quote_csr into l_quote_log_id, l_quote_total, l_quote_failed, l_quote_success;
        exit when quote_csr%NOTFOUND;
      end loop;
      close quote_csr;
      FND_MESSAGE.set_Name('IBE', 'IBE_LEAD_EMAIL_SUBJECT');
      --FND_MESSAGE.set_Token('STATUS', p_status);
      l_subject := FND_MESSAGE.GET;
      printDebug(l_subject, 'SendEmail');
      -- now construct the message body.
      FND_MESSAGE.SET_NAME('IBE', 'IBE_LEAD_EMAIL_DESCRIPTION1');
      --FND_MESSAGE.SET_TOKEN('STATUS', p_status);
      l_body := FND_MESSAGE.GET;
      l_body := l_body || '<p>';
      printDebug(l_body, 'SendEmail');

      l_body := l_body || '<table><tr><td>';
      FND_MESSAGE.SET_NAME('IBE', 'IBE_LEAD_TYPE');
      l_body := l_body || FND_MESSAGE.GET;
      l_body := l_body || '</td><td>';
      printDebug(l_body, 'SendEmail');

      FND_MESSAGE.SET_NAME('IBE', 'IBE_LEAD_NUM_IMPORTED');
      l_body := l_body || FND_MESSAGE.GET;
      l_body := l_body || '</td><td>';
      printDebug(l_body, 'SendEmail');

      FND_MESSAGE.SET_NAME('IBE', 'IBE_LEAD_NUM_SUECCESS');
      l_body := l_body || FND_MESSAGE.GET;
      l_body := l_body || '</td><td>';
      printDebug(l_body, 'SendEmail');

      FND_MESSAGE.SET_NAME('IBE', 'IBE_LEAD_NUM_FAILED');
      l_body := l_body || FND_MESSAGE.GET;
      l_body := l_body || '</td></tr><tr><td>';
      printDebug(l_body, 'SendEmail');

      l_body := l_body || fnd_message.get_string('IBE','IBE_PRMT_STORE_CART') || '</td><td>' || to_char(l_quote_total) ||
		'</td><td>' || to_char(l_quote_success) ||
		'</td><td>' || to_char(l_quote_failed) || '</td></tr><tr><td>';
      printDebug(l_body, 'SendEmail');
      l_body3 := l_body3 ||fnd_message.get_string('IBE','IBE_PRMT_STORE_ORDER') || '</td><td>' || to_char(p_num_total) ||
		'</td><td>' || to_char(p_num_success) ||
		'</td><td>' || to_char(p_num_failed) || '</td></tr></table><p>';
      printDebug(l_body3, 'SendEmail');

      FND_MESSAGE.SET_NAME('IBE', 'IBE_LEAD_EMAIL_DESCRIPTION3');
      FND_MESSAGE.SET_TOKEN('LOG_ID', to_char(l_quote_log_id) || ' & ' || p_log_id);
      l_body3 := l_body3 || FND_MESSAGE.GET;
      l_body3 := replace(l_body3, chr(0), ' ');
      l_body  := replace(l_body, chr(0), ' ');

      --dbms_output.put_line('length of l_body ' || length(l_body));
      --dbms_output.put_line('length of l_body2 ' || length(l_body2));
      --dbms_output.put_line('length of l_body3 ' || length(l_body3));
      --dbms_output.put_line('Email to : ' || l_email_list);
      --dbms_output.put_line('Subject: ' || l_subject);
      --dbms_output.put_line(l_body);
      --dbms_output.put_line(l_body3);

	IBE_WFNOTIFICATION_PVT.send_html_email(
	   p_api_version 	=> 1.0,
	   p_commit		=> FND_API.G_TRUE,
	   p_init_msg_list	=> FND_API.G_TRUE,
	   email_list		=> l_email_list,
	   subject		=> l_subject,
	   body			=> l_body||l_body3,
	   return_status	=> l_return_status,
	   x_msg_count		=> l_msg_count,
	   x_msg_data		=> l_msg_data);

      if( l_return_status = FND_API.G_RET_STS_ERROR ) then
	  printDebug('Error from send_email', 'SendEmail');
	  raise FND_API.G_EXC_ERROR;
      elsif( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
	  printDebug('Error from send_email', 'SendEmail');
	   raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      printDebug('l_email_list ' || l_email_list, 'Send_Email');
      printDebug('l_subject ' || l_subject, 'Send_Email');
      printDebug('l_body ' || l_body, 'Send_Email');
      printDebug('l_body3 ' || l_body3, 'Send_Email');

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_data := '';
      x_msg_count := 0;

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_Count => x_msg_count, p_data => x_msg_data);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE, p_Count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
           FND_MESSAGE.Set_Token('ROUTINE', 'SendEmail');
           FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
           FND_MESSAGE.Set_Token('REASON', SQLERRM);
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg('IBE_LEAD_IMPORT_PVT', 'SendEmail');
           END IF;
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data  => x_msg_data);
  End sendEmail;

  procedure print_Parameter(
        p_begin_date    IN VARCHAR2,
        p_end_date      IN VARCHAR2,
        p_debug_flag    IN VARCHAR2,
        p_purge_flag    IN VARCHAR2,
        p_write_detail_log      IN VARCHAR2)
  IS
  BEGIN
     FND_MESSAGE.SET_NAME('IBE', 'IBE_ECR_BEGIN_DATE');
     printOutput(FND_MESSAGE.GET || ': ' || p_begin_date);
     FND_MESSAGE.SET_NAME('IBE', 'IBE_ECR_END_DATE');
     printOutput(FND_MESSAGE.GET || ': ' || p_end_date);
     FND_MESSAGE.SET_NAME('IBE', 'IBE_LEAD_DEBUG_FLAG');
     FND_MESSAGE.SET_TOKEN('DEBUG_FLAG', p_debug_flag);
     printOutput(FND_MESSAGE.GET);
     FND_MESSAGE.SET_NAME('IBE', 'IBE_LEAD_PURGE_FLAG');
     FND_MESSAGE.SET_TOKEN('PURGE_FLAG', p_purge_flag);
     printOutput(FND_MESSAGE.GET);
  END print_Parameter;

  procedure printOutput( p_message VARCHAR2) IS
      l_printTimeStamp VARCHAR2(30);
  BEGIN
     IF Substr(p_Message,1,1) <> '+' Then
       l_printTimeStamp := to_char(sysdate,'RRRR/MM/DD HH:MI:SS')||' ';
     End If;

       If FND_GLOBAL.user_id > -1 Then
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_printTimeStamp||p_Message);
       End If;
  END printOutput;


end IBE_LEAD_IMPORT_PVT;

/
