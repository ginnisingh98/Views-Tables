--------------------------------------------------------
--  DDL for Package Body IEX_ASSIGN_COLL_LEVEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_ASSIGN_COLL_LEVEL_PVT" AS
/* $Header: iexvaclb.pls 120.0.12010000.8 2010/02/16 07:57:30 barathsr ship $ */

G_PKG_NAME   CONSTANT VARCHAR2(30):= 'IEX_ASSIGN_COLL_LEVEL_PVT';
G_FILE_NAME  CONSTANT VARCHAR2(12) := 'iexvaclb.pls';
G_USER_ID    NUMBER := FND_GLOBAL.User_Id;

G_Batch_Size NUMBER := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));
G_insert_count  NUMBER:= 0;
G_update_count  NUMBER:= 0;

l_api_version_number    CONSTANT NUMBER   := 1.0;
PG_DEBUG NUMBER ;


PROCEDURE MAIN_PROCESS(ERRBUF       OUT NOCOPY Varchar2,
                       RETCODE      OUT NOCOPY Varchar2,
                       p_request_id IN  Number)   is

Cursor C_get_CodeIds(p_code varchar2,p_id number) is
         select distinct ish.score_object_code,ish.score_object_id from iex_score_histories ish, iex_scores sc
              where ish.score_id = sc.score_id
                and sc.concurrent_prog_name = 'IEXACLSB'
                and ish.request_id = p_id
                         --(select max(sh.request_id) from iex_score_histories sh where score_object_code <> 'IEX_INVOICES')
                and ish.score_object_code = p_code; --<> 'IEX_INVOICES';


Cursor C_get_PartyId_Account(id number) is
           select party_id from hz_cust_accounts
                where cust_account_id = id;


Cursor C_get_PartyId_BillTo(id number) is
           select party_id from hz_cust_accounts  where cust_account_id =
                     (select cust_account_id from hz_cust_acct_sites_all where cust_acct_site_id =
                        (select cust_acct_site_id from hz_cust_site_uses_all where site_use_code = 'BILL_TO' and site_use_id = id));

Cursor C_get_PartyId_Del(id number) is
           select party_cust_id from iex_delinquencies
                where delinquency_id = id;

Cursor C_get_objCode(p_id number) is
       select shs.score_object_code from iex_score_histories shs where shs.score_history_id = (select max(score_history_id)
              from iex_score_histories ish, iex_scores sc
              where ish.score_id = sc.score_id
                and sc.concurrent_prog_name = 'IEXACLSB'
                and ish.request_id = p_id
                and ish.score_object_code <> 'IEX_INVOICES');

		 cursor c_level is
			 select Meaning
			  --  into t_level
			    from iex_lookups_v
			    where lookup_type='IEX_RUNNING_LEVEL'
			    and iex_utilities.validate_running_level(lookup_code)='Y';


l_cnt           NUMBER:= 0;
l_party_id      NUMBER;
l_insert_count  NUMBER:= 0;
l_update_count  NUMBER:= 0;
l_return_status VARCHAR2(10);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
ncnt            NUMBER:= 0;

subtype l_rec is IEX_PARTY_PREF_PUB.level_rec_type;
subtype l_tbl is IEX_PARTY_PREF_PUB.level_tbl_type;

t_level_tbl   l_tbl;

type t_ids   is table of number        index by binary_integer;
type t_codes is table of varchar2(25)  index by binary_integer;
type t_vrs   is table of number        index by binary_integer;

v_score_object_code   t_codes;
v_score_object_id     t_ids;
ti_score_object_code  t_codes;
ti_party_id           t_ids;
tu_score_object_code  t_codes;
tu_party_id           t_ids;
tu_obj_verseion       t_vrs;
t_level t_codes;--Added for Bug 8839374 16-Feb-2010 barathsr

l_req_id  number;
l_objCode varchar2(25);
--Begin Bug 8839374 16-Feb-2010 barathsr
l_party_level varchar2(1);
l_using_del_level varchar2(1);
l_using_billto_level varchar2(1);
l_using_acc_level varchar2(1);
l_using_cust_level varchar2(1);
l_return  boolean;
--End Bug 8839374 16-Feb-2010 barathsr

BEGIN

       -- Standard Start of API savepoint
       RETCODE := 0;
       ERRBUF := null;
       SAVEPOINT MAIN_PROCESS_PVT;

       select define_party_running_level,using_delinquency_level,using_billto_level,using_account_level,using_customer_level
       into l_party_level,l_using_del_level,l_using_billto_level,l_using_acc_level,l_using_cust_level
       from iex_questionnaire_items;

       iex_debug_pub.logmessage (' ASSIGN COLLECTION LEVEL - Starting MAIN PROCESS .....');
       select max(request_id) into l_req_id from iex_score_histories where score_object_code <> 'IEX_INVOICES';

       --Begin Bug 8839374 16-Feb-2010 barathsr
       if l_party_level <> 'Y' then
         if FND_GLOBAL.Conc_Request_Id is not null then
			       l_return := fnd_concurrent.set_completion_status (status  => 'WARNING',
							      message => 'Cannot continue as the Override Collections at party level is set to No');
	 end if;
	 fnd_file.put_line(FND_FILE.LOG,'Cannot continue as the Override Collections at party level is set to No....Value->'||l_party_level);
	 return;
       end if;
       --End Bug 8839374 16-Feb-2010 barathsr


       open C_get_objCode(l_req_id);
       fetch C_get_objCode into l_objCode;
       close C_get_objCode;

       OPEN C_get_CodeIds(l_objCode,l_req_id);

       LOOP
                 FETCH  C_get_CodeIds
                        BULK COLLECT INTO v_score_object_code, v_score_object_id  LIMIT G_Batch_Size;

                 ncnt := v_score_object_id.count;

                 FOR i  In 1..ncnt
                    Loop

                         IF v_score_object_code(i) = 'PARTY' and l_using_cust_level='Y' then

                            t_level_tbl(i).ObjectCode := 'CUSTOMER';
                            t_level_tbl(i).party_id := v_score_object_id(i);

                          ELSIF v_score_object_code(i) = 'IEX_ACCOUNT' and l_using_acc_level='Y'  then

                                begin
                                     Open C_get_PartyId_Account(v_score_object_id(i) );
                                     Fetch C_get_PartyId_Account into l_party_id;

                                     if C_get_PartyId_Account%NOTFOUND then
                                        l_party_id := 0;
                                     end if;
                                     Close C_get_PartyId_Account;

                                    exception
                                       when others then
                                            iex_debug_pub.logmessage('ASSIGN COLLECTION LEVEL-C_get_PartyId_Account- Exception = ' ||SQLERRM);
                                            iex_debug_pub.logmessage('ASSIGN COLLECTION LEVEL-C_get_PartyId_Account- ObjCode = ' ||'ACCOUNT');
                                            iex_debug_pub.logmessage('ASSIGN COLLECTION LEVEL-C_get_PartyId_Account- ObjId = ' ||v_score_object_id(i));
                                            l_party_id := 0;
                                  end;

                                  if (l_party_id > 0) then

                                      t_level_tbl(i).ObjectCode := 'ACCOUNT';
                                      t_level_tbl(i).party_id := l_party_id;

                                  else
                                      iex_debug_pub.logmessage('ASSIGN LEVEL Account Party Does Not Exist for Account = '||v_score_object_id(i));
                                  end if;

                          ELSIF v_score_object_code(i) = 'IEX_DELINQUENCY' and l_using_del_level='Y' then

                                begin
                                     Open C_get_PartyId_Del(v_score_object_id(i) );
                                     Fetch C_get_PartyId_Del into l_party_id;

                                     if C_get_PartyId_Del%NOTFOUND then
                                        l_party_id := 0;
                                     end if;
                                     Close C_get_PartyId_Del;

                                    exception
                                       when others then
                                            iex_debug_pub.logmessage('ASSIGN COLLECTION LEVEL-C_get_PartyId_Del- Exception = ' ||SQLERRM);
                                            iex_debug_pub.logmessage('ASSIGN COLLECTION LEVEL-C_get_PartyId_Del- ObjCode = ' ||'DELINQUENCY');
                                            iex_debug_pub.logmessage('ASSIGN COLLECTION LEVEL-C_get_PartyId_Del- ObjId = ' ||v_score_object_id(i));
                                            l_party_id := 0;
                                  end;

                                  if (l_party_id > 0) then

                                      t_level_tbl(i).ObjectCode := 'DELINQUENCY';
                                      t_level_tbl(i).party_id := l_party_id;

                                  else
                                      iex_debug_pub.logmessage('ASSIGN LEVEL Delinquency Party Does Not Exist for Deliquency = '||v_score_object_id(i));
                                  end if;

                         ELSIF  v_score_object_code(i) = 'IEX_BILLTO' and l_using_billto_level='Y' then

                                 begin
                                     Open C_get_PartyId_BillTo(v_score_object_id(i) );
                                     Fetch C_get_PartyId_BillTo into l_party_id;

                                    if C_get_PartyId_BillTo%NOTFOUND then
                                        l_party_id := 0;
                                    end if;
                                    Close C_get_PartyId_BillTo;

                                    exception
                                       when others then
                                            iex_debug_pub.logmessage('ASSIGN COLLECTION LEVEL-C_get_PartyId_BillTo-Exception = ' ||SQLERRM);
                                            iex_debug_pub.logmessage('ASSIGN COLLECTION LEVEL-C_get_PartyId_BillTo-ObjCode = ' ||'BILLTO');
                                            iex_debug_pub.logmessage('ASSIGN COLLECTION LEVEL-C_get_PartyId_BillTo-ObjId = ' ||v_score_object_id(i));
                                            l_party_id := 0;
                                  end;

                                  if (l_party_id > 0) then

                                      t_level_tbl(i).ObjectCode := 'BILL_TO';
                                      t_level_tbl(i).party_id := l_party_id;

                                   else
                                      iex_debug_pub.logmessage('ASSIGN LEVEL BILLTO Party Does Not Exist for Site Use ID  = '||v_score_object_id(i));
                                   end if;
			 --Begin Bug 8839374 16-Feb-2010 barathsr
	                ELSE
			    if FND_GLOBAL.Conc_Request_Id is not null then
			       l_return := fnd_concurrent.set_completion_status (status  => 'WARNING',
							      message => 'Cannot assign at this level as it is not enabled');
			   end if;
			    fnd_file.put_line(FND_FILE.LOG,'Cannot assign at this level as it is not enabled');


			    open c_level;
			    fetch c_level bulk collect into t_level;
                               fnd_file.put_line(FND_FILE.LOG,'Enabled levels');
			    if t_level.count>0 then
			    for j in 1..t_level.count loop
			      fnd_file.put_line(FND_FILE.LOG,'Enabled level- '||j||'-'||t_level(j));
			    end loop;
			    end if;
	                return;
                         --End Bug 8839374 16-Feb-2010 barathsr

                        END IF;

                    End Loop;





                    if t_level_tbl.count > 0 then

                           IEX_PARTY_PREF_PUB.assign_collection_level(
                                                            P_Api_Version_Number        => 1.0,
                                                            P_Init_Msg_List             => FND_API.G_TRUE,
                                                            P_Commit                    => FND_API.G_FALSE,
                                                            X_Return_Status             => l_return_status,
                                                            X_Msg_Count                 => l_msg_count,
                                                            X_Msg_Data                  => l_msg_data,
                                                            x_Insert_Count              => l_insert_count,
                                                            x_Update_Count              => l_update_count,
                                                            p_level_tbl                 => t_level_tbl);
                    end if;

                    if (l_insert_count > 0) or (l_update_count > 0) then
                       COMMIT;
                       G_insert_count := G_insert_count + l_insert_count;
                       G_update_count := G_update_count + l_update_count;
                    end if;

                    EXIT WHEN  C_get_CodeIds%NOTFOUND;
      END LOOP;

      CLOSE C_get_CodeIds;

      iex_debug_pub.logmessage (' ASSIGN COLLECTION LEVEL - Insert Party Count  =  '||G_insert_count);
      iex_debug_pub.logmessage (' ASSIGN COLLECTION LEVEL - Update Party Count =   '||G_update_count);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number Of Parties Assigned Collection Level Created..>> '|| G_insert_count);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number Of Parties Assigned Collection Level Updated..>> '|| G_update_count);

      if l_return_status <> 'S' then
         iex_debug_pub.logmessage('Error from IEX_PARTY_PREF_PUB ..>> '||l_msg_data);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error from IEX_PARTY_PREF_PUB ..>> '||l_msg_data);
         ERRBUF := ' ASSIGN COLLECTION LEVEL -  - Exception = ' ||SQLERRM;
         RETCODE := -1;
      end if;

    EXCEPTION
       when others then
            iex_debug_pub.logmessage (' ASSIGN COLLECTION LEVEL -  - Exception = ' ||SQLERRM);
            ERRBUF := ' ASSIGN COLLECTION LEVEL -  - Exception = ' ||SQLERRM;
            RETCODE := -1;

END;



END IEX_ASSIGN_COLL_LEVEL_PVT;

/
