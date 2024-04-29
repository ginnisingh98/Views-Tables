--------------------------------------------------------
--  DDL for Package Body HZ_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PURGE" AS
/* $Header: ARHPURGB.pls 120.47 2006/06/28 22:50:46 awu noship $ */
PROCEDURE GENERATE_BODY
(p_init_msg_list           	             IN         	VARCHAR2 := FND_API.G_FALSE,
 x_return_status                         OUT NOCOPY    VARCHAR2,
 x_msg_count                             OUT NOCOPY    NUMBER,
 x_msg_data                              OUT NOCOPY    VARCHAR2)
 IS

CURSOR app_id IS select distinct(dict_application_id) from hz_merge_dictionary
where parent_entity_name='HZ_PARTIES'
and  nvl(validate_purge_flag,'Y') <> 'N'; --5125968
--and entity_name in (select table_name from fnd_tables);

cursor x1(app_id number) is  --4500011
select decode(entity_name,'HZ_PARTY_RELATIONSHIPS','HZ_RELATIONSHIPS',entity_name)  entity_name, fk_column_name, decode(entity_name,'HZ_PARTY_RELATIONSHIPS','RELATIONSHIP_ID',pk_column_name)  pk_column_name,
decode(entity_name,'HZ_PARTY_RELATIONSHIPS', join_clause || ' AND subject_table_name = ''HZ_PARTIES''  AND object_table_name = ''HZ_PARTIES''
AND directional_flag = ''F''', join_clause) join_clause, parent_entity_name,fk_data_type
from hz_merge_dictionary where parent_entity_name like 'HZ_%' and dict_application_id = app_id
and fk_column_name IS NOT NULL and entity_name not in ('AS_CHANGED_ACCOUNTS_ALL','POS_PARTIES_V','POS_PARTY_SITES_V','WSH_LOCATION_OWNERS','ZX_PARTY_TAX_PROFILE','CE_BANKS_MERGE_V','CE_BANK_BRANCHES_MERGE_V','WSH_SUPPLIER_SF_SITES_V')
and nvl(validate_purge_flag,'Y') <> 'N'; --5125968

cursor x4(app_id number) is  --4500011
select  decode(entity_name,'HZ_PARTY_RELATIONSHIPS','HZ_RELATIONSHIPS',entity_name) entity_name, fk_column_name,
decode(entity_name,'HZ_PARTY_RELATIONSHIPS','RELATIONSHIP_ID',pk_column_name) pk_column_name,
decode(entity_name,'HZ_PARTY_RELATIONSHIPS', join_clause || ' AND subject_table_name = ''HZ_PARTIES''  AND object_table_name = ''HZ_PARTIES''
AND directional_flag = ''F''', join_clause) join_clause,
parent_entity_name, fk_data_type
from hz_merge_dictionary where parent_entity_name like 'HZ_%' and dict_application_id = app_id
and entity_name in('HZ_CUST_ACCOUNTS','HZ_CUST_ACCT_SITES_ALL','HZ_CUSTOMER_PROFILES') OR
(entity_name ='HZ_PARTY_RELATIONSHIPS' and fk_column_name<>'PARTY_ID') OR
(entity_name ='HZ_ORGANIZATION_PROFILES' and fk_column_name ='DISPLAYED_DUNS_PARTY_ID');

stmt1 varchar2(31000):= 'delete from hz_purge_gt temp where ';
stmt2 varchar2(31000):= 'delete /*+ parallel(temp) */ from hz_purge_gt temp where ';
stmt3 varchar2(31000):= '';
stmt4 varchar2(31000):= '';
stmt5 varchar2(31000):= '';
appid number(15);
e1 varchar2(50);
fk1 varchar2(50);
pk1 varchar2(50);
j1 varchar2(1000);
pe1 varchar2(50);
fk_data_typ1 varchar2(100);
s1 varchar2(32000);
s2 varchar2(31000);
id number :=1;
partyid varchar2(100);
column_indexed boolean := true;
s3 varchar2(3000);
cnt number :=0;
xxx varchar2(10);
app_name VARCHAR2(100);

BEGIN

SAVEPOINT generate_body;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
/* Beginnig of the dynamic package generation*/
   HZ_GEN_PLSQL.new('HZ_PURGE_GEN', 'PACKAGE BODY');
   HZ_GEN_PLSQL.add_line('CREATE OR REPLACE PACKAGE BODY HZ_PURGE_GEN AS');
   HZ_GEN_PLSQL.add_line('PROCEDURE IDENTIFY_CANDIDATES(p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                         x_return_status  OUT NOCOPY  VARCHAR2,
                         x_msg_count OUT NOCOPY  NUMBER,
                         x_msg_data OUT NOCOPY   VARCHAR2,
                         check_flag boolean, con_prg boolean, regid_proc boolean) IS');
   HZ_GEN_PLSQL.add_line('appid number;');
   HZ_GEN_PLSQL.add_line('sql_count number;');
   HZ_GEN_PLSQL.add_line('total_parties number;');
   HZ_GEN_PLSQL.add_line('parties_count1 number;');
   HZ_GEN_PLSQL.add_line('parties_count2 number;');
   HZ_GEN_PLSQL.add_line('single_party number;');
   HZ_GEN_PLSQL.add_line(fnd_global.local_chr(10));
   HZ_GEN_PLSQL.ADD_LINE('cursor repopulate is');
   HZ_GEN_PLSQL.ADD_LINE('select party_id from hz_purge_gt;');
   HZ_GEN_PLSQL.add_line(fnd_global.local_chr(10));
   HZ_GEN_PLSQL.add_line('BEGIN');
    HZ_GEN_PLSQL.add_line(fnd_global.local_chr(10));
    HZ_GEN_PLSQL.add_line('SAVEPOINT identify_candidates;');

    -- initialize message list if p_init_msg_list is set to TRUE.
    HZ_GEN_PLSQL.add_line('IF FND_API.to_Boolean(p_init_msg_list) THEN');
        HZ_GEN_PLSQL.add_line('FND_MSG_PUB.initialize;');
    HZ_GEN_PLSQL.add_line('END IF;');

    -- initialize API return status to success.
    HZ_GEN_PLSQL.add_line('x_return_status := FND_API.G_RET_STS_SUCCESS;');
    HZ_GEN_PLSQL.add_line('delete from hz_application_trans_gt; ');
    HZ_GEN_PLSQL.add_line('open repopulate;');
    HZ_GEN_PLSQL.add_line('fetch repopulate into single_party;');
    HZ_GEN_PLSQL.add_line('close repopulate;');
    populate_fk_datatype;
   -- open cursor to get each application id
  OPEN app_id;
   LOOP
    FETCH app_id into appid;
    exit when app_id%NOTFOUND;
    cnt := 1;
    if appid =222 then
     app_name :=null;
     app_name := get_app_name(appid);
     if(app_name IS NOT NULL) then
  -- open cursor to get the tca tables, app_id=222 where check is needed
     OPEN x4(appid);
     loop
      FETCH x4 into e1,fk1,pk1,j1,pe1,fk_data_typ1;
     exit when x4%NOTFOUND;
      column_indexed := has_index(e1,fk1,app_name,j1);
      if(column_indexed = true) then
       delete_template(e1, fk1, pk1, j1, pe1, fk_data_typ1, 'TRUE', s2, cnt);
       if(s2 is not null) then
        s1 := s1||fnd_global.local_chr(10)||s2;
        cnt := cnt+1;
       end if;
      end if;
     end loop;
     close x4;
    end if;
   else
   app_name :=null;
   app_name := get_app_name(appid);
   if(app_name IS NOT NULL) then
   OPEN x1(appid);
    loop
     FETCH x1 into e1,fk1,pk1,j1,pe1,fk_data_typ1;
     exit when x1%NOTFOUND;
      column_indexed := has_index(e1,fk1,app_name,j1);
      if(column_indexed = true) then
       delete_template(e1, fk1, pk1, j1, pe1, fk_data_typ1,'TRUE', s2,cnt);
       if(s2 is not null) then
        s1 := s1||fnd_global.local_chr(10)||s2;
        cnt := cnt+1;
      end if;
      end if;
    end loop;
    close x1;
    end if;
   end if;

   if (s1 is not null) then
      stmt1:= stmt1||fnd_global.local_chr(10)||s1;
      HZ_GEN_PLSQL.ADD_LINE('--delete and insert records into hz_purge_gt for an application');
      HZ_GEN_PLSQL.ADD_LINE('appid:='||appid||';');
	  stmt3:= 'insert into hz_application_trans_gt(app_id,party_id) select '||appid||', temp.party_id from hz_purge_gt temp where ';
	  HZ_GEN_PLSQL.ADD_LINE(' if(regid_proc = true) then ');
	  HZ_GEN_PLSQL.ADD_LINE(stmt3||fnd_global.local_chr(10)||s1||';');
	  HZ_GEN_PLSQL.ADD_LINE(' else ');
      HZ_GEN_PLSQL.ADD_LINE(stmt1||';');
 	  HZ_GEN_PLSQL.ADD_LINE('end if;');

      --HZ_GEN_PLSQL.ADD_LINE('HZ_PURGE.post_app_logic(appid,single_party,check_flag);');
      HZ_GEN_PLSQL.ADD_LINE(fnd_global.local_chr(10));
    end if;
    id := 1;
    s1 := null;
    stmt1 := 'delete from hz_purge_gt temp where ';
	stmt3 := 'insert into hz_application_trans_gt(app_id,party_id) select '||appid||', temp.party_id from hz_purge_gt temp where ';
   END LOOP;
   CLOSE app_id;

  OPEN app_id;
   LOOP
   FETCH app_id into appid;
   exit when app_id%NOTFOUND;
   app_name:=null;
   app_name := get_app_name(appid);
   if(app_name IS NOT NULL) then
   OPEN x1(appid);
    loop
     FETCH x1 into e1,fk1,pk1,j1,pe1,fk_data_typ1;
     exit when x1%NOTFOUND;
      column_indexed := has_index(e1,fk1,app_name,j1);
      if(column_indexed = false) then
       --dbms_output.put_line('non indexed entity='||e1||',column='||fk1||'parent='||pe1);
       cnt :=1;
       delete_template(e1, fk1, pk1, j1, pe1, fk_data_typ1,'FALSE', s2,cnt);
       if(s2 is not NULL) then
        HZ_GEN_PLSQL.add_line('--'||e1||';'||fk1);
   	    stmt4 := 'insert into hz_application_trans_gt(app_id,party_id) select '||appid||', temp.party_id from hz_purge_gt temp ';
        stmt5 := ' where not exists(select ''Y'' from hz_application_trans_gt appl where appl.app_id = '||appid||' and appl.party_id=temp.party_id) and ';
        HZ_GEN_PLSQL.ADD_LINE('appid:='||appid||';');
        --HZ_GEN_PLSQL.ADD_LINE('HZ_PURGE.post_app_logic(appid,single_party,check_flag);');
        HZ_GEN_PLSQL.ADD_LINE(' if(regid_proc = true) then ');
	  	HZ_GEN_PLSQL.ADD_LINE(stmt4||stmt5||fnd_global.local_chr(10)||s2||';');
	  	HZ_GEN_PLSQL.ADD_LINE(' else ');
        HZ_GEN_PLSQL.add_line(stmt2||s2||';');
 	  	HZ_GEN_PLSQL.ADD_LINE('end if;');

       end if;
      end if;
    end loop;
    close x1;
   end if;
   END LOOP;
 CLOSE app_id;
        HZ_GEN_PLSQL.ADD_LINE(' if(regid_proc = true) then ');
        HZ_GEN_PLSQL.ADD_LINE('delete from hz_purge_gt temp where temp.party_id in (select appl.party_id from hz_application_trans_gt appl) ;');
        HZ_GEN_PLSQL.ADD_LINE('end if;');
        HZ_GEN_PLSQL.ADD_LINE(fnd_global.local_chr(10));
        HZ_GEN_PLSQL.add_line('EXCEPTION');
        HZ_GEN_PLSQL.add_line('WHEN OTHERS THEN');
        HZ_GEN_PLSQL.add_line('ROLLBACK to identify_candidates;');
        HZ_GEN_PLSQL.add_line('x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
        HZ_GEN_PLSQL.add_line('FND_MESSAGE.SET_NAME( ''AR'', ''HZ_API_OTHERS_EXCEP'' );');
        HZ_GEN_PLSQL.add_line('FND_MESSAGE.SET_TOKEN( ''ERROR'' ,SQLERRM );');
        HZ_GEN_PLSQL.add_line('FND_MSG_PUB.ADD;');

        HZ_GEN_PLSQL.add_line('FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );');
       HZ_GEN_PLSQL.add_line('RAISE FND_API.G_EXC_ERROR;');

       HZ_GEN_PLSQL.add_line('END IDENTIFY_CANDIDATES;');

       HZ_GEN_PLSQL.add_line('END HZ_PURGE_GEN;');
       HZ_GEN_PLSQL.compile_code;


  -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                                RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
            RAISE FND_API.G_EXC_ERROR;

END;


-- Procedure called by the concurrent program

PROCEDURE IDENTIFY_PURGE_PARTIES(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, batchid varchar2, con_prg VARCHAR2, regid_proc VARCHAR2 DEFAULT 'F') IS
x_return_status varchar2(5);
x_msg_count     number;
x_msg_data      varchar2(100);
request_id number;
where_clause varchar2(5000);
insert_stmt varchar2(5000):= 'insert into hz_purge_gt(party_id) select party_id from hz_parties where party_type<>''PARTY_RELATIONSHIP'' ';
delete_stmt varchar2(5000):= 'delete from hz_purge_gt ';
time_stamp date;
mergedict_update_date date;
phone_number varchar2(100);
candpartyid number;
num_parties number;
p_init_msg_list VARCHAR2(10);
conc_prg boolean;
partyid number;
partyname VARCHAR2(360);
regid_flag boolean;
attrib_flag VARCHAR2(10);
app_id number;
p_id number;
pid number;
x_sysdate date :=sysdate;
i number := 0;
/*l_bool BOOLEAN;
  l_status VARCHAR2(255);
  l_schema VARCHAR2(255);
  l_tmp    VARCHAR2(2000);*/

cursor printparties is
select h.party_id, p.party_name from hz_purge_gt h, hz_parties p where h.party_id=p.party_id;

cursor time_stmp is
select to_date(timestamp,'YYYY-MM-DD:HH24:MI:SS') from sys.user_objects
where object_type='PACKAGE BODY' and status='VALID'and object_name='HZ_PURGE_GEN';

cursor dict_update_date is
select max(last_update_date) from hz_merge_dictionary;

cursor b1 is
select subset_sql, attributes_flag from hz_purge_batches where batch_id = to_number(batchid);

cursor numparties is
select count(*) from hz_purge_gt;

cursor appl_trans is
select distinct(app_id), party_id from hz_application_trans_gt;

cursor purge_parties is
select distinct(party_id) from hz_purge_gt;

BEGIN
retcode:=0;

if con_prg is not null and con_prg='Y' then
  conc_prg := true;
else
 conc_prg := false;
end if;

log('NEWLINE',conc_prg);
log('--Program to identify the purge candidates',conc_prg);
--l_bool := fnd_installation.GET_APP_INFO('AR',l_status,l_tmp,l_schema);
open time_stmp;
 fetch time_stmp into time_stamp;
close time_stmp;

open dict_update_date;
 fetch dict_update_date into mergedict_update_date;
close dict_update_date;

/* Generate the body of the Package HZ_PURGE_GEN if last_update_date of hz_merge_dictionary
   is greater than the package generation date*/


 if (mergedict_update_date is null or time_stamp is null or mergedict_update_date>time_stamp)  then
  hz_purge.generate_body(p_init_msg_list, x_return_status, x_msg_count, x_msg_data);
 log('Start Time ='||sysdate,conc_prg);
 end if;

 open b1;
 fetch b1 into where_clause,attrib_flag;
close b1;

   if where_clause is not null then
   insert_stmt := insert_stmt||' and '||where_clause;
   end if;
   execute immediate delete_stmt;
   execute immediate insert_stmt;

  /* Procedure to identify the purge candidates with no transactions */
  if(attrib_flag IS NOT NULL) then
  	if(attrib_flag='Y') then
  		regid_flag := false;
  	else
    	regid_flag := true;
    end if;
  end if;

   hz_purge_gen.identify_candidates(p_init_msg_list, x_return_status, x_msg_count, x_msg_data, false, conc_prg, regid_flag);

   /* Insert into the hz_purge_candidates table */
 /*  insert into hz_purge_candidates(BATCH_ID,CANDIDATE_PARTY_ID,PARTY_NAME,PARTY_NUMBER,ADDRESSES,PHONE_NUMBERS,COUNTRY,STATUS,CREATION_DATE,
   LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATED_BY)
   select to_number(batchid), a.party_id, substr(a.party_name,1,250), a.party_number,
   a.address1||','||a.city||','||a.state||','||a.country||' '||a.postal_code,
   cp.PHONE_AREA_CODE||'-'||cp.PHONE_COUNTRY_CODE||'-'||cp.PHONE_NUMBER, a.country, 'IDENTIFIED',
   sysdate, fnd_global.login_id, sysdate, fnd_global.user_id, fnd_global.user_id
   from hz_parties a , hz_purge_gt temp, hz_contact_points cp where
   temp.party_id = a.party_id and
   cp.owner_table_id(+)=temp.party_id and
   cp.contact_point_type(+)='PHONE' and
   cp.owner_table_name(+)='HZ_PARTIES' and
   cp.primary_flag(+)='Y';

   num_parties:=SQL%ROWCOUNT;*/

   open purge_parties;
    loop
     FETCH purge_parties into pid;
     exit when purge_parties%NOTFOUND;
     i:=i+1;
     insert into hz_purge_candidates(BATCH_ID,CANDIDATE_PARTY_ID,PARTY_NAME,PARTY_NUMBER,ADDRESSES,PHONE_NUMBERS,COUNTRY,STATUS,CREATION_DATE,
     LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATED_BY)
     	 select to_number(batchid), pid, substr(a.party_name,1,250), a.party_number,
   		 a.address1||','||a.city||','||a.state||','||a.country||' '||a.postal_code,
  		 cp.PHONE_AREA_CODE||'-'||cp.PHONE_COUNTRY_CODE||'-'||cp.PHONE_NUMBER, a.country, 'IDENTIFIED',
  		 sysdate, fnd_global.login_id, sysdate, fnd_global.user_id, fnd_global.user_id
  		 from hz_parties a , hz_contact_points cp where
  		 a.party_id = pid and
  		 cp.owner_table_id(+)= a.party_id and
  		 cp.contact_point_type(+)='PHONE' and
  		 cp.owner_table_name(+)='HZ_PARTIES' and
   		 cp.primary_flag(+)='Y';
    end loop;
   close purge_parties;

   num_parties:= i;
   --dbms_output.put_line('num_parties='||num_parties);

   update hz_purge_batches set num_candidates=num_parties, num_marked=num_parties, status='IDENTIFICATION_COMPLETE' where batch_id=to_number(batchid);
   if(regid_flag=true) then
    open appl_trans;
     loop
     FETCH appl_trans into app_id, p_id;
     exit when appl_trans%NOTFOUND;
   	    x_sysdate :=x_sysdate+0.00001;
   	    --dbms_output.put_line('sysdate='||x_sysdate);
   		insert into hz_non_purge_candidates(BATCH_ID,CANDIDATE_PARTY_ID,APPL_ID,
   		PARTY_NAME,PARTY_NUMBER,ADDRESSES,PHONE_NUMBERS,COUNTRY,CREATION_DATE,
   		LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATED_BY)
   		select to_number(batchid), p_id, app_id, substr(a.party_name,1,250), a.party_number,
   		null, null, null,
   		x_sysdate, fnd_global.login_id, sysdate, fnd_global.user_id, fnd_global.user_id
   		from hz_parties a where
   		a.party_id = p_id;
   	  end loop;
   	 close appl_trans;
   end if;
log('The following Parties have been identified as purge candidates',conc_prg);
log('***************************************************************',conc_prg);
open printparties;
 loop
 fetch printparties into partyid,partyname;
 exit when printparties%NOTFOUND;
  log(partyname||'(party_id ='||partyid||')',conc_prg);
 end loop;
close printparties;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    retcode := 2;
    errbuf := errbuf || logerror||SQLERRM;
    FND_FILE.close;
    update hz_purge_batches set status='IDENTIFICATION_ERROR' where batch_id=to_number(batchid);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    retcode := 2;
    errbuf := errbuf || logerror||SQLERRM;
    FND_FILE.close;
    update hz_purge_batches set status='IDENTIFICATION_ERROR' where batch_id=to_number(batchid);
  WHEN OTHERS THEN
    retcode := 2;
    errbuf := errbuf || logerror||SQLERRM;
    FND_FILE.close;
    update hz_purge_batches set status='IDENTIFICATION_ERROR' where batch_id=to_number(batchid);
END;

/* To check if a single party has any transactions */

/*PROCEDURE check_single_party_trans
(p_init_msg_list           	             IN            VARCHAR2 := FND_API.G_FALSE,
 x_return_status                         OUT NOCOPY    VARCHAR2,
 x_msg_count                             OUT NOCOPY    NUMBER,
 x_msg_data                              OUT NOCOPY    VARCHAR2,
 partyid number,
 allow_purge OUT NOCOPY    VARCHAR2) IS

party_count number;
phone_number varchar2(75);

cursor party is
select count(*) from hz_application_trans_gt;

begin
null;
/*
SAVEPOINT check_single_party_trans;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

delete from hz_purge_gt;
insert into hz_purge_gt(party_id) select party_id from hz_parties where party_id=partyid;
hz_purge_gen.identify_candidates(p_init_msg_list, x_return_status, x_msg_count, x_msg_data, true, false);
open party;
 fetch party into party_count;
 if party_count>0 then
   allow_purge:='false';
 else
   allow_purge:='true';
 end if;
close party;

-- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO check_single_party_trans;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                                RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO check_single_party_trans;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
        ROLLBACK to check_single_party_trans;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
            RAISE FND_API.G_EXC_ERROR;

end;*/

/* Procedure to purge parties. This is called by the concurrent program */

PROCEDURE PURGE_PARTIES(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, batchid number, con_prg VARCHAR2) IS

candidate_id number;
conc_prg boolean;
partyid number;
partyname VARCHAR2(360);
l_bool BOOLEAN;
l_status VARCHAR2(255);
l_schema VARCHAR2(255);
l_tmp    VARCHAR2(2000);


cursor printparties(batchId number) is
select candidate_party_id, party_name from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED';

BEGIN
retcode:=0;

if con_prg is not null and con_prg='Y' then
  conc_prg := true;
else
 conc_prg := false;
end if;

log('NEWLINE',conc_prg);
log('The following Parties will be purged from the TCA tables',conc_prg);
log('***************************************************************',conc_prg);
open printparties(batchid);
 loop
 fetch printparties into partyid,partyname;
  IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED','BO_EVENTS_ENABLED')) THEN

  	HZ_BES_BO_UTIL_PKG.del_obj_hierarchy(partyid);

  END IF;
  exit when printparties%NOTFOUND;
  log(partyname||'(ID= '||partyid||')',conc_prg);
 end loop;
close printparties;

hz_common_pub.disable_cont_source_security;
--4307686
DELETE from HZ_PARTY_USG_ASSIGNMENTS where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_PARTY_USG_ASSIGNMENTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_ORGANIZATION_PROFILES where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_ORGANIZATION_PROFILES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

execute immediate 'DELETE from HZ_CONTACT_PREFERENCES where CONTACT_LEVEL_TABLE_ID in
( select CONTACT_POINT_ID FROM HZ_CONTACT_POINTS WHERE OWNER_TABLE_ID in
(SELECT PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED''))and OWNER_TABLE_NAME=''HZ_PARTY_SITES'')
and CONTACT_LEVEL_TABLE=''HZ_CONTACT_POINTS''' using batchid;
log(' HZ_CONTACT_PREFERENCES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
begin
execute immediate 'DELETE from HZ_STAGED_CONTACT_POINTS where CONTACT_POINT_ID in
( select CONTACT_POINT_ID FROM HZ_CONTACT_POINTS WHERE OWNER_TABLE_ID in
(SELECT PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED'')) and OWNER_TABLE_NAME=''HZ_PARTY_SITES'')' using batchid;
 log(' HZ_STAGED_CONTACT_POINTS : Deleted '||SQL%ROWCOUNT||' rows', conc_prg);
EXCEPTION
 WHEN OTHERS THEN
 null;
 END;

DELETE from HZ_CONTACT_POINTS where OWNER_TABLE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED')) and OWNER_TABLE_NAME='HZ_PARTY_SITES';
log(' HZ_CONTACT_POINTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_ORG_CONTACT_ROLES where ORG_CONTACT_ID in
( select ORG_CONTACT_ID FROM HZ_ORG_CONTACTS WHERE PARTY_SITE_ID in (
SELECT PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED')));
log(' HZ_ORG_CONTACT_ROLES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

begin
execute immediate 'DELETE from HZ_STAGED_CONTACTS where ORG_CONTACT_ID in
( select ORG_CONTACT_ID FROM HZ_ORG_CONTACTS WHERE PARTY_SITE_ID in
(SELECT PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED'')))' using batchid;
log(' HZ_STAGED_CONTACTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
exception
when others then
 null;
end;

DELETE from HZ_ORG_CONTACTS where PARTY_SITE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED'));
log(' HZ_ORG_CONTACTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_PARTY_SITE_USES where PARTY_SITE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED'));
log(' HZ_PARTY_SITE_USES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

execute immediate 'DELETE from HZ_CODE_ASSIGNMENTS where OWNER_TABLE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED''))
and OWNER_TABLE_NAME=''HZ_PARTY_SITES''' using batchid;
log(' HZ_CODE_ASSIGNMENTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

execute immediate 'DELETE from HZ_CONTACT_PREFERENCES where CONTACT_LEVEL_TABLE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED''))
and CONTACT_LEVEL_TABLE=''HZ_PARTY_SITES''' using batchid;
log(' HZ_CONTACT_PREFERENCES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

begin
execute immediate 'DELETE from HZ_STAGED_PARTY_SITES where PARTY_SITE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED''))' using batchid;
log(' HZ_STAGED_PARTY_SITES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
exception
when others then
 null;
end;

DELETE from HZ_PARTY_SITES where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_PARTY_SITES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

execute immediate 'DELETE from HZ_CONTACT_PREFERENCES where CONTACT_LEVEL_TABLE_ID in
( select CONTACT_POINT_ID FROM HZ_CONTACT_POINTS WHERE OWNER_TABLE_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED'')
and OWNER_TABLE_NAME=''HZ_PARTIES'') and CONTACT_LEVEL_TABLE=''HZ_CONTACT_POINTS''' using batchid;
log(' HZ_CONTACT_PREFERENCES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

begin
execute immediate 'DELETE from HZ_STAGED_CONTACT_POINTS where CONTACT_POINT_ID in
( select CONTACT_POINT_ID FROM HZ_CONTACT_POINTS WHERE OWNER_TABLE_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED'')
and OWNER_TABLE_NAME=''HZ_PARTIES'')' using batchid;
log(' HZ_STAGED_CONTACT_POINTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
exception
when others then
 null;
end;

DELETE from HZ_CONTACT_POINTS where OWNER_TABLE_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED')
and OWNER_TABLE_NAME='HZ_PARTIES';
log(' HZ_CONTACT_POINTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_PERSON_PROFILES where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_PERSON_PROFILES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_FINANCIAL_PROFILE where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_FINANCIAL_PROFILE : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_REFERENCES where REFERENCED_PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_REFERENCES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_CERTIFICATIONS where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_CERTIFICATIONS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
DELETE from HZ_CREDIT_RATINGS where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_CREDIT_RATINGS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
DELETE from HZ_SECURITY_ISSUED where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_SECURITY_ISSUED : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
DELETE from HZ_FINANCIAL_NUMBERS where FINANCIAL_REPORT_ID in
(select FINANCIAL_REPORT_ID FROM HZ_FINANCIAL_REPORTS WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED'));
 log(' HZ_FINANCIAL_NUMBERS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
DELETE from HZ_FINANCIAL_REPORTS where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_FINANCIAL_REPORTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
DELETE from HZ_ORGANIZATION_INDICATORS where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_FINANCIAL_REPORTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_PERSON_INTEREST where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_FINANCIAL_REPORTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_CITIZENSHIP where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_FINANCIAL_REPORTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

DELETE from HZ_WORK_CLASS where EMPLOYMENT_HISTORY_ID in
(select EMPLOYMENT_HISTORY_ID FROM HZ_EMPLOYMENT_HISTORY WHERE PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED'));
log(' HZ_WORK_CLASS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
DELETE from HZ_EMPLOYMENT_HISTORY where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_EMPLOYMENT_HISTORY : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
DELETE from HZ_PERSON_LANGUAGE where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_PERSON_LANGUAGE : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
DELETE from HZ_EDUCATION where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_EDUCATION : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
DELETE from HZ_INDUSTRIAL_REFERENCE where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_INDUSTRIAL_REFERENCE : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
execute immediate 'DELETE from HZ_CODE_ASSIGNMENTS where OWNER_TABLE_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED'')
and OWNER_TABLE_NAME=''HZ_PARTIES''' using batchid;
log(' HZ_CODE_ASSIGNMENTS : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
execute immediate 'DELETE from HZ_CONTACT_PREFERENCES where CONTACT_LEVEL_TABLE_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED'')
and CONTACT_LEVEL_TABLE=''HZ_PARTIES''' using batchid;
log(' HZ_CONTACT_PREFERENCES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
execute immediate 'DELETE from HZ_ORIG_SYS_REFERENCES where party_id in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED'') ' using batchid;
log(' HZ_ORIG_SYS_REFERENCES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);

begin
execute immediate 'DELETE from HZ_STAGED_PARTIES where PARTY_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=:1 and status=''IDENTIFIED'')' using batchid;
log(' HZ_STAGED_PARTIES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
exception
when others then
 null;
end;

DELETE from AS_CHANGED_ACCOUNTS_ALL where CUSTOMER_ID in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' AS_CHANGED_ACCOUNTS_ALL : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);


delete from wsh_location_owners wlo
where  wlo.owner_party_id in (select candidate_party_id
			  from hz_purge_candidates
		          where batch_id=batchid and status='IDENTIFIED')
and exists (
             select 'x'
	     from wsh_location_owners wlo1
	     where wlo1.wsh_location_id = wlo.wsh_location_id and wlo1.owner_party_id = -1);

update wsh_location_owners wlo
set       wlo.owner_party_id = -1
where  wlo.owner_party_id in (select candidate_party_id
			  from hz_purge_candidates
		          where batch_id=batchid and status='IDENTIFIED'
			  and rownum = 1 )-- if more than one party has same location, only update one.
and  not exists (
               select 'x'
	       from wsh_location_owners wlo1
               where wlo1.wsh_location_id = wlo.wsh_location_id and wlo1.owner_party_id = -1);

-- delete wsh again to catch the ones are not deletled from first delete and not updated from second update
-- make sure to keep the ones owner_party_id = -1

delete from wsh_location_owners wlo
where  wlo.owner_party_id in (select candidate_party_id
			  from hz_purge_candidates
		          where batch_id=batchid and status='IDENTIFIED')
and wlo.owner_party_id <> -1;

Delete from zx_party_tax_profile  PTP
where  ptp.party_type_code = 'THIRD_PARTY'
and    ptp.party_id in (select candidate_party_id
			from hz_purge_candidates
			where batch_id=batchid and status='IDENTIFIED')
and not exists (Select 'x'
                from   zx_registrations reg
                where  ptp.party_tax_profile_id = reg.party_tax_profile_id)
and not exists (Select 'x'
                from   zx_exemptions ex
                where  ptp.party_tax_profile_id = ex.party_tax_profile_id)
and not exists (Select 'x'
                from   ZX_REPORT_CODES_ASSOC assoc
                where  assoc.entity_code = 'ZX_PARTY_TAX_PROFILE'
                and    assoc.ENTITY_ID = ptp.party_tax_profile_id)
and not exists (Select 'x'
                from   hz_code_assignments HCA
                where  HCA.OWNER_TABLE_NAME = 'ZX_PARTY_TAX_PROFILE'
                AND    HCA.OWNER_TABLE_ID = PTP.PARTY_TAX_PROFILE_ID);

DELETE from HZ_PARTIES where party_id in
(select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='IDENTIFIED');
log(' HZ_PARTIES : Deleted '||SQL%ROWCOUNT||' rows',conc_prg);
fnd_file.close;

 --if the purged party is of type 'RELATIONSHIP' then set the corresponding value in the hz_relationships to null

  execute immediate 'update hz_relationships set party_id=null where party_id in
   (select pur_cand.candidate_party_id from hz_purge_candidates pur_cand, hz_parties parties where pur_cand.batch_id=:1 and
      pur_cand.candidate_party_id = parties.party_id and parties.party_type=''PARTY_RELATIONSHIP'' )' using batchid;

-- bug 4947069

   delete from hz_relationships where (subject_id  in (select candidate_party_id
			  from hz_purge_candidates
		          where batch_id=batchid and status='IDENTIFIED')
			  or object_id  in (select candidate_party_id
			  from hz_purge_candidates
		          where batch_id=batchid and status='IDENTIFIED'))
			  and status = 'M';



--update the status of purged parties in table 'HZ_PURGE_CANDIDATES to 'PURGED'
  update hz_purge_candidates set status='PURGED' where batch_id=batchid and status='IDENTIFIED';
  update hz_purge_candidates set status='PURGED' where candidate_party_id in (
    select candidate_party_id from hz_purge_candidates where batch_id=batchid and status='PURGED')
  and batch_id<>batchid;

  /* update the status of purged parties in table 'HZ_PURGE_BATCHES to 'PURGE_COMPLETED' */
  update hz_purge_batches set status='PURGE_COMPLETE',purge_date=sysdate where batch_id=batchid;

l_bool := fnd_installation.GET_APP_INFO('AR',l_status,l_tmp,l_schema);

begin
ad_ctx_ddl.sync_index(l_schema||'.hz_stage_parties_t1');
ad_ctx_ddl.sync_index(l_schema||'.hz_stage_party_sites_t1');
ad_ctx_ddl.sync_index(l_schema||'.hz_stage_contact_t1');
ad_ctx_ddl.sync_index(l_schema||'.hz_stage_cpt_t1');
exception
 when others then
  null;
end;

hz_common_pub.enable_cont_source_security;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    retcode := 2;
    errbuf := errbuf || logerror||SQLERRM;
    FND_FILE.close;
    update hz_purge_batches set status='PURGE_ERROR' where batch_id=batchid;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    retcode := 2;
    errbuf := errbuf || logerror||SQLERRM;
   FND_FILE.close;
   update hz_purge_batches set status='PURGE_ERROR' where batch_id=batchid;
  WHEN OTHERS THEN
    retcode := 2;
    errbuf := errbuf || logerror||SQLERRM;
    FND_FILE.close;
    update hz_purge_batches set status='PURGE_ERROR' where batch_id=batchid;

END;

/* Purge Single Party */

PROCEDURE PURGE_PARTY
(p_init_msg_list           	             IN            VARCHAR2 := FND_API.G_FALSE,
 x_return_status                         OUT NOCOPY    VARCHAR2,
 x_msg_count                             OUT NOCOPY    NUMBER,
 x_msg_data                              OUT NOCOPY    VARCHAR2,
 p_party_id NUMBER) IS

 insertrows number;
 cursor existing_id(p_id number) is
 select count(*) from hz_purge_candidates where candidate_party_id=p_id and status<>'PURGED';

BEGIN

SAVEPOINT PURGE_PARTY;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
---please enter the directory as the third parameter to which the file needs to be copied.
--fnd_file.put_names('delparty.log',null,'/sqlcom/outbound');

   insert into hz_purge_candidates(BATCH_ID,CANDIDATE_PARTY_ID,PARTY_NAME,PARTY_NUMBER,ADDRESSES,PHONE_NUMBERS,COUNTRY,STATUS,CREATION_DATE,
   LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATED_BY)
   select to_number('-1'), a.party_id, substr(a.party_name,1,250), a.party_number,
   a.address1||','||a.city||','||a.state||','||a.country||' '||a.postal_code,
   cp.PHONE_AREA_CODE||'-'||cp.PHONE_COUNTRY_CODE||'-'||cp.PHONE_NUMBER, a.country, 'IDENTIFIED',
   sysdate, fnd_global.login_id, sysdate, fnd_global.user_id, fnd_global.user_id
   from hz_parties a , hz_contact_points cp where a.party_id = p_party_id and
   cp.owner_table_id(+)=a.party_id and cp.contact_point_type(+)='PHONE' and cp.primary_flag(+)='Y' and
   cp.owner_table_name(+)='HZ_PARTIES';

hz_common_pub.disable_cont_source_security;

DELETE from HZ_ORGANIZATION_PROFILES where PARTY_ID = p_party_id;

execute immediate 'DELETE from HZ_CONTACT_PREFERENCES where CONTACT_LEVEL_TABLE_ID in
( select CONTACT_POINT_ID FROM HZ_CONTACT_POINTS WHERE OWNER_TABLE_ID in
(SELECT PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = :1)and OWNER_TABLE_NAME=''HZ_PARTY_SITES'')
and CONTACT_LEVEL_TABLE=''HZ_CONTACT_POINTS''' using p_party_id;

begin
execute immediate 'DELETE from HZ_STAGED_CONTACT_POINTS where CONTACT_POINT_ID in
( select CONTACT_POINT_ID FROM HZ_CONTACT_POINTS WHERE OWNER_TABLE_ID in
(SELECT PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = :1) and OWNER_TABLE_NAME=''HZ_PARTY_SITES'')' using p_party_id;
exception
when others then
 null;
end;

DELETE from HZ_CONTACT_POINTS where OWNER_TABLE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = p_party_id) and OWNER_TABLE_NAME='HZ_PARTY_SITES';

DELETE from HZ_ORG_CONTACT_ROLES where ORG_CONTACT_ID in
( select ORG_CONTACT_ID FROM HZ_ORG_CONTACTS WHERE PARTY_SITE_ID in (
SELECT PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = p_party_id));

begin
execute immediate 'DELETE from HZ_STAGED_CONTACTS where ORG_CONTACT_ID in
( select ORG_CONTACT_ID FROM HZ_ORG_CONTACTS WHERE PARTY_SITE_ID in
(SELECT PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = :1))' using p_party_id;
 exception
when others then
 null;
end;

DELETE from HZ_ORG_CONTACTS where PARTY_SITE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = p_party_id);

DELETE from HZ_PARTY_SITE_USES where PARTY_SITE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = p_party_id);

execute immediate 'DELETE from HZ_CODE_ASSIGNMENTS where OWNER_TABLE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = :1) and OWNER_TABLE_NAME=''HZ_PARTY_SITES''' using p_party_id;

execute immediate 'DELETE from HZ_CONTACT_PREFERENCES where CONTACT_LEVEL_TABLE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = :1) and CONTACT_LEVEL_TABLE=''HZ_PARTY_SITES''' using p_party_id;

begin
execute immediate 'DELETE from HZ_STAGED_PARTY_SITES where PARTY_SITE_ID in
( select PARTY_SITE_ID FROM HZ_PARTY_SITES WHERE PARTY_ID = :1)' using p_party_id;
exception
when others then
 null;
end;

DELETE from HZ_PARTY_SITES where PARTY_ID = p_party_id;

execute immediate 'DELETE from HZ_CONTACT_PREFERENCES where CONTACT_LEVEL_TABLE_ID in
( select CONTACT_POINT_ID FROM HZ_CONTACT_POINTS WHERE OWNER_TABLE_ID = :1 and OWNER_TABLE_NAME=''HZ_PARTIES'')
and CONTACT_LEVEL_TABLE=''HZ_CONTACT_POINTS''' using p_party_id;

begin
execute immediate 'DELETE from HZ_STAGED_CONTACT_POINTS where CONTACT_POINT_ID in
( select CONTACT_POINT_ID FROM HZ_CONTACT_POINTS WHERE OWNER_TABLE_ID = :1 and OWNER_TABLE_NAME=''HZ_PARTIES'')' using p_party_id;
exception
when others then
 null;
end;

DELETE from HZ_CONTACT_POINTS where OWNER_TABLE_ID = p_party_id and OWNER_TABLE_NAME='HZ_PARTIES';

DELETE from HZ_PERSON_PROFILES where PARTY_ID = p_party_id;

DELETE from HZ_FINANCIAL_PROFILE where PARTY_ID = p_party_id;

DELETE from HZ_REFERENCES where REFERENCED_PARTY_ID = p_party_id;

DELETE from HZ_CERTIFICATIONS where PARTY_ID = p_party_id;

DELETE from HZ_CREDIT_RATINGS where PARTY_ID = p_party_id;

DELETE from HZ_SECURITY_ISSUED where PARTY_ID = p_party_id;

DELETE from HZ_FINANCIAL_NUMBERS where FINANCIAL_REPORT_ID in
 ( select FINANCIAL_REPORT_ID FROM HZ_FINANCIAL_REPORTS WHERE PARTY_ID = p_party_id);

DELETE from HZ_FINANCIAL_REPORTS where PARTY_ID = p_party_id;

DELETE from HZ_ORGANIZATION_INDICATORS where PARTY_ID = p_party_id;

DELETE from HZ_PERSON_INTEREST where PARTY_ID = p_party_id;

DELETE from HZ_CITIZENSHIP where PARTY_ID = p_party_id;

DELETE from HZ_WORK_CLASS where EMPLOYMENT_HISTORY_ID in
(select EMPLOYMENT_HISTORY_ID FROM HZ_EMPLOYMENT_HISTORY WHERE PARTY_ID = p_party_id);

DELETE from HZ_EMPLOYMENT_HISTORY where PARTY_ID = p_party_id;

DELETE from HZ_PERSON_LANGUAGE where PARTY_ID = p_party_id;

DELETE from HZ_EDUCATION where PARTY_ID = p_party_id;

DELETE from HZ_INDUSTRIAL_REFERENCE where PARTY_ID = p_party_id;

execute immediate 'DELETE from HZ_CODE_ASSIGNMENTS where OWNER_TABLE_ID = :1 and OWNER_TABLE_NAME=''HZ_PARTIES''' using p_party_id;

execute immediate 'DELETE from HZ_CONTACT_PREFERENCES where CONTACT_LEVEL_TABLE_ID = :1 and CONTACT_LEVEL_TABLE=''HZ_PARTIES''' using p_party_id;

execute immediate 'DELETE from HZ_ORIG_SYS_REFERENCES where party_id = :1' using p_party_id;

begin
execute immediate 'DELETE from HZ_STAGED_PARTIES where PARTY_ID = :1' using p_party_id;
exception
when others then
 null;
end;
DELETE from AS_CHANGED_ACCOUNTS_ALL where CUSTOMER_ID = p_party_id;

delete from wsh_location_owners wlo
where  wlo.owner_party_id = p_party_id
and exists (
             select 'x'
	     from wsh_location_owners wlo1
	     where wlo1.wsh_location_id = wlo.wsh_location_id and wlo1.owner_party_id = -1);

update wsh_location_owners wlo
set       wlo.owner_party_id = -1
where  wlo.owner_party_id = p_party_id
and  not exists (
               select 'x'
	       from wsh_location_owners wlo1
               where wlo1.wsh_location_id = wlo.wsh_location_id and wlo1.owner_party_id = -1);

Delete from zx_party_tax_profile  PTP
where  ptp.party_type_code = 'THIRD_PARTY'
and    ptp.party_id = p_party_id
and not exists (Select 'x'
                from   zx_registrations reg
                where  ptp.party_tax_profile_id = reg.party_tax_profile_id)
and not exists (Select 'x'
                from   zx_exemptions ex
                where  ptp.party_tax_profile_id = ex.party_tax_profile_id)
and not exists (Select 'x'
                from   ZX_REPORT_CODES_ASSOC assoc
                where  assoc.entity_code = 'ZX_PARTY_TAX_PROFILE'
                and    assoc.ENTITY_ID = ptp.party_tax_profile_id)
and not exists (Select 'x'
                from   hz_code_assignments HCA
                where  HCA.OWNER_TABLE_NAME = 'ZX_PARTY_TAX_PROFILE'
                AND    HCA.OWNER_TABLE_ID = PTP.PARTY_TAX_PROFILE_ID);

DELETE from HZ_PARTIES where party_id = p_party_id;

 IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED','BO_EVENTS_ENABLED')) THEN

  	HZ_BES_BO_UTIL_PKG.del_obj_hierarchy(p_party_id);

  END IF;

/* if the purged party is of type 'RELATIONSHIP' then set the corresponding value in the hz_relationships to null */
   execute immediate 'update hz_relationships set party_id=null where party_id=:1 and party_id in
   (select party_id from hz_parties where party_type = ''PARTY_RELATIONSHIP'')' using p_party_id;

-- bug 4947069

   delete from hz_relationships where (subject_id = p_party_id or object_id = p_party_id) and status = 'M';

 /* update status to 'PURGED' in hz_purge_candidates for the purged parties */
 update hz_purge_candidates set status='PURGED' where candidate_party_id=p_party_id;

--fnd_file.close;
hz_common_pub.enable_cont_source_security;
-- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PURGE_PARTY;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                                RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PURGE_PARTY;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
        ROLLBACK to PURGE_PARTY;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
            RAISE FND_API.G_EXC_ERROR;

END purge_party;

PROCEDURE post_app_logic(appid NUMBER, single_party VARCHAR2, check_flag boolean) IS
parties_count1 NUMBER;
appid_cnt NUMBER;

cursor appid_count(appid NUMBER) IS
select count(*) from hz_application_trans_gt where app_id=appid;

BEGIN

OPEN appid_count(appid);
 FETCH appid_count into appid_cnt;
CLOSE appid_count;
   If(appid_cnt=0) then
      parties_count1:=SQL%ROWCOUNT;
      if parties_count1>0 then
       insert into hz_application_trans_gt(app_id) values(appid);
       if check_flag=true then
      --dbms_output.put_line('insert single party into table'||appid);
       insert into hz_purge_gt(party_id) values(single_party);
       end if;
      end if;
   end if;

END post_app_logic;

FUNCTION logerror RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || ' ' || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  log(l_msg_data,true);
  RETURN l_msg_data;
END logerror;

PROCEDURE log(
   message      IN      VARCHAR2,
   con_prg      IN      boolean,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
IF message = 'NEWLINE' THEN
  if con_prg is not null and con_prg=true then
    FND_FILE.NEW_LINE(FND_FILE.log, 1);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  end if;
ELSE
    FND_FILE.put_line(fnd_file.log,message);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, message);
END IF;
EXCEPTION
 WHEN OTHERS THEN
   NULL;
END log;

FUNCTION get_col_type(
	p_table		VARCHAR2,
	p_column	VARCHAR2,
    p_app_name  VARCHAR2)
  RETURN VARCHAR2 IS

CURSOR data_type(schema1 VARCHAR2) IS
   SELECT DATA_TYPE FROM sys.all_tab_columns
   WHERE table_name = p_table
   AND COLUMN_NAME = p_column
   AND owner = schema1;

l_data_type VARCHAR2(106);
ret_data_type VARCHAR2(106);
l_bool BOOLEAN;
  l_status VARCHAR2(255);
  l_schema VARCHAR2(255);
  l_tmp    VARCHAR2(2000);

BEGIN
/*l_bool := fnd_installation.GET_APP_INFO(p_app_name,l_status,l_tmp,l_schema);
  OPEN data_type(l_schema);
   FETCH data_type INTO l_data_type;
  CLOSE data_type;
  if (l_data_type is null) then
    ret_data_type := 'NONE';
  else
    ret_data_type := l_data_type;
  end if;

  RETURN ret_data_type;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;*/
    null;
END get_col_type;

FUNCTION has_context(proc VARCHAR2) RETURN BOOLEAN IS
  l_entity VARCHAR2(255);
  l_procedure VARCHAR2(255);
  l_attribute VARCHAR2(255);
  c NUMBER;
  n NUMBER;
  l_custom BOOLEAN;
BEGIN
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c,proc,2);
  dbms_sql.close_cursor(c);
  RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
    dbms_sql.close_cursor(c);
    RETURN FALSE;
END;

PROCEDURE populate_fk_datatype IS
cursor c_dict_no_fktype is
	 select entity_name, fk_column_name, merge_dict_id, dict_application_id
	 from hz_merge_dictionary
	 where fk_data_type is null;

 l_sub_entity_name VARCHAR2(150);
 l_sub_fk_column_name VARCHAR2(150);
 l_merge_dict_id NUMBER;
 l_app_id NUMBER;
 l_data_type VARCHAR2(100);
 l_app_name VARCHAR2(100);

BEGIN
open c_dict_no_fktype;
  loop
      	fetch c_dict_no_fktype into l_sub_entity_name, l_sub_fk_column_name,
                              l_merge_dict_id, l_app_id;
	  EXIT WHEN c_dict_no_fktype%NOTFOUND;
        l_app_name := get_app_name(l_app_id);
        l_data_type:=hz_party_merge.get_col_type(l_sub_entity_name,l_sub_fk_column_name,l_app_name);

        update hz_merge_dictionary
        set fk_data_type = l_data_type
        where merge_dict_id = l_merge_dict_id;

   end loop;
 close c_dict_no_fktype;

END;

FUNCTION get_app_name(appid NUMBER) RETURN VARCHAR2 IS
appname VARCHAR2(100);
cursor app_name(app_id NUMBER) IS
Select application_short_name from fnd_application where application_id=app_id;
BEGIN
  open app_name(appid);
   fetch app_name into appname;
  close app_name;
  return appname;
EXCEPTION
WHEN OTHERS THEN
    null;
END;


FUNCTION has_index(entity_name VARCHAR2, column_name VARCHAR2, app_name VARCHAR2, join_clause VARCHAR2) RETURN BOOLEAN IS
 l_bool BOOLEAN;
  l_status VARCHAR2(255);
  l_schema VARCHAR2(255);
  l_tmp    VARCHAR2(2000);
  col_pos NUMBER;
  col_name VARCHAR2(100);
  entity_occur  NUMBER;
  check_flag VARCHAR2(10);
  col_position NUMBER;
  indexname VARCHAR2(100);
  upper_join_clause VARCHAR2(2000);

cursor column_position(ent_name varchar2, ent_col_name varchar2, schema1 varchar2) is
   select min(column_position) from dba_ind_columns where table_name = ent_name
   and column_name = ent_col_name
   and index_owner = schema1 and table_owner = schema1;

cursor col_indexes(ent_name varchar2, colmn_name varchar2, schema1 varchar2) is
   select index_name, column_position from dba_ind_columns
   where table_name = ent_name and column_name = colmn_name
   and index_owner = schema1 and table_owner = schema1;

cursor preceeding_columns(ent_name varchar2, ind_name varchar2, col_position NUMBER, schema1 varchar2) is
   select column_name from dba_ind_columns where table_name = ent_name
   and index_name = ind_name
   and column_position<col_position
   and index_owner = schema1 and table_owner = schema1;

cursor indexed_views(ent_name varchar2, colmn_name varchar2) is
select 'Y' from dual where
(ent_name,colmn_name)
in (('AS_ACCESSES_ALL', 'CUSTOMER_ID'),('AS_ACCESSES_ALL', 'ADDRESS_ID'),('AS_ACCESSES_ALL', 'PARTNER_CUSTOMER_ID'),
('AS_ACCESSES_ALL', 'PARTNER_CONT_PARTY_ID'),('AS_ACCESSES_ALL', 'PARTNER_ADDRESS_ID'),('ASG_PARTY_ACC_V', 'PARTY_ID'),
('OKE_K_FUNDING_SOURCES_PM_HV', 'K_PARTY_ID'),('IGW_PROP_PERSONS_TCA_V', 'PERSON_PARTY_ID'),
('MIS_HZ_MERGE_VETO_PARTIES', 'PARTY_ID'),('MIS_HZ_MERGE_VETO_PARTY_SITES', 'PARTY_SITE_ID'),('JTF_PERZ_QUERY_PARAM','PARAMETER_VALUE'));

cursor string_column(join_clause varchar2, col_name varchar2) is
select instr(join_clause,col_name) from dual;
i NUMBER :=0;
cols NUMBER:=0;
isView VARCHAR2(1) := null;
BEGIN
open indexed_views(entity_name, column_name);
	fetch indexed_views into isView;
close indexed_views;
if(isView='Y') then
	check_flag := 'Y';
else
 l_bool := fnd_installation.GET_APP_INFO(app_name,l_status,l_tmp,l_schema);
  open column_position(entity_name, column_name, l_schema);
   fetch column_position into col_pos;
  close column_position;

 if (col_pos is not null AND col_pos=1) then
    check_flag :='Y';
    --dbms_output.put_line('col position is 1');
 elsif(col_pos is not null AND col_pos>1) then

  open col_indexes(entity_name, column_name, l_schema);
   loop
   fetch col_indexes into indexname, col_position;
    --dbms_output.put_line('index name ='||indexname||' and col_position ='||col_position);
    exit when col_indexes%NOTFOUND;
     if join_clause is not null then
     check_flag := 'Y';
      open preceeding_columns(entity_name, indexname, col_position, l_schema);
      loop
        fetch preceeding_columns into col_name;
         exit when preceeding_columns%NOTFOUND;
          --cols := preceeding_columns%ROWCOUNT;
          upper_join_clause := upper(join_clause);
          --dbms_output.put_line('nvl(instrb(upper_join_clause,col_name),0)'||nvl(instrb(upper_join_clause,col_name),0));
         IF nvl(instrb(upper_join_clause,col_name),0)<=0 then
           check_flag := 'N';
           exit;
         end if;
       end loop;
      close preceeding_columns;
     else
       check_flag := 'N';
     end if;
     if check_flag = 'Y' then
      --dbms_output.put_line('all columns exist in join clause=');
      exit;
     end if;
  end loop;
  close col_indexes;
 else
  check_flag:='N';
  --dbms_output.put_line('entity_occur=null');
 end if;
end if;

 if (check_flag='Y') then
  RETURN TRUE;
 else
  RETURN FALSE;
 end if;
EXCEPTION
WHEN OTHERS THEN
    RETURN FALSE;
END;


PROCEDURE delete_template
(e1 VARCHAR2, fk1 VARCHAR2,pk1 VARCHAR2,j1 VARCHAR2, pe1 VARCHAR2,  fk_data_typ1 VARCHAR2,
 first VARCHAR2, concat_string OUT NOCOPY VARCHAR2, cnt NUMBER) IS

e2 varchar2(50);
fk2 varchar2(50);
pk2 varchar2(50);
j2 varchar2(1000);
pe2 varchar2(50);
e3 varchar2(50);
fk3 varchar2(50);
pk3 varchar2(50);
j3 varchar2(1000);
pe3 varchar2(50);
fk_data_typ2 varchar2(100);
fk_data_typ3 varchar2(100);
s1 varchar2(31000);
s2 varchar2(300);
p1 varchar2(1000);
p2 varchar2(500);
p3 varchar2(500);
p4 varchar2(500);
p5 varchar2(500);
p6 varchar2(500);
p7 varchar2(500);
p8 varchar2(500);
p9 varchar2(500);
p10 varchar2(500);
p11 varchar2(500);
p12 varchar2(10);
fkcolumn_type varchar2(50);
pkcolumn_type varchar2(50);
column_type varchar2(50);
partyid varchar2(100);
valid_stmt boolean := true;
l_sql VARCHAR2(32000);
cnt2 NUMBER := 0;
cnt3 NUMBER := 0;

cursor x2(parent varchar2) is   --4500011
select decode(entity_name,'HZ_PARTY_RELATIONSHIPS','HZ_RELATIONSHIPS',entity_name) entity_name, fk_column_name,
decode(entity_name,'HZ_PARTY_RELATIONSHIPS','RELATIONSHIP_ID',pk_column_name) pk_column_name,
decode(entity_name,'HZ_PARTY_RELATIONSHIPS', join_clause || ' AND subject_table_name = ''HZ_PARTIES''  AND object_table_name = ''HZ_PARTIES''
AND directional_flag = ''F''', join_clause) join_clause, parent_entity_name,fk_data_type
from hz_merge_dictionary where entity_name = parent;

cursor x3(parent2 varchar2) is --4500011
select decode(entity_name,'HZ_PARTY_RELATIONSHIPS','HZ_RELATIONSHIPS',entity_name) entity_name, fk_column_name,
decode(entity_name,'HZ_PARTY_RELATIONSHIPS','RELATIONSHIP_ID',pk_column_name) pk_column_name,
decode(entity_name,'HZ_PARTY_RELATIONSHIPS', join_clause || ' AND subject_table_name = ''HZ_PARTIES''  AND object_table_name = ''HZ_PARTIES''
AND directional_flag = ''F''', join_clause) join_clause,
parent_entity_name,fk_data_type
from hz_merge_dictionary where entity_name = parent2;

BEGIN
    if pe1='HZ_PARTIES' then
       partyid :=' temp.party_id ';
       if (fk_data_typ1<>'NUMBER' AND fk_data_typ1 IS NOT NULL) then
        partyid := ' to_char(temp.party_id) ';
       end if;

       if j1 is not null then
        --select decode(instr(j1,'group'),0,' and '||j1,' and '||substr(j1,1,instr(j1,'group')-1)) into p3 from dual;
       	select decode(instr(j1,'group'),0,j1,substr(j1,1,instr(j1,'group')-1)) into p3 from dual;
       else
        p3:=' ';
       end if;

       if(first = 'TRUE' AND cnt=1) then
        l_sql := 'delete from hz_purge_gt temp where ';
        p1:= ' exists (select ''Y'' from '||e1;
        p2:= ' xx where xx.'||fk1||' = '||partyid;
        if j1 is not null then
         p3:= ' and '||'('||p3||')';
        end if;
       elsif (first = 'TRUE' AND cnt>1) then
        l_sql := 'delete from hz_purge_gt temp where 1<>1 ';
        p1:= ' or exists (select ''Y'' from '||e1;
        p2:= ' xx where xx.'||fk1||' = '||partyid;
        if j1 is not null then
         p3:= ' and '||'('||p3||')';
        end if;
       elsif(first = 'FALSE' AND cnt=1) then
        l_sql := 'delete from hz_purge_gt temp where ';
        p1:= partyid||' in (select /*+ parallel(xx)*/ xx.'||fk1||' from '||e1;
		p2:= ' xx ';
        if j1 is not null then
         p3:= ' where '||'('||p3||')';
        end if;
       end if;


       p4:= ')';

       s1:= s1||fnd_global.local_chr(10)||p1||
            p2||fnd_global.local_chr(10)||p3||p4;
       else
    -- open cursor to get the second level tables, which have/not have HZ_PARTIES as parent_entity
       open x2(pe1);
        loop
         fetch x2 into e2, fk2, pk2, j2, pe2,fk_data_typ2;
         exit when x2%NOTFOUND;
         cnt2:=cnt2+1;
         if pe2 = 'HZ_PARTIES' then
          partyid :=' temp.party_id ';
          if (fk_data_typ2<>'NUMBER' AND fk_data_typ2 IS NOT NULL) then
           partyid := ' to_char(temp.party_id) ';
          end if;

          if j2 is not null then
         	--select decode(instr(j2,'group'),0,' and '||j2,' and '||substr(j1,1,instr(j1,'group')-1)) into p3 from dual;
          	select decode(instr(j2,'group'),0,j2,substr(j1,1,instr(j1,'group')-1)) into p3 from dual;
          else
	         p3:=' ';
          end if;

       if(first = 'TRUE' AND cnt=1) then
        l_sql := 'delete from hz_purge_gt temp where ';
        if(cnt2=1) then
         p1:= ' exists (select ''Y'' from '||e2;
        else
         p1:= ' or exists (select ''Y'' from '||e2;
        end if;
		p2:= ' xx where xx.'||fk2||' = '||partyid;
		if j2 is not null then
			p3 := ' and '||'('||p3||')';
		end if;
         p4:= ' and exists' ;
       elsif (first = 'TRUE' AND cnt>1) then
        l_sql := 'delete from hz_purge_gt temp where 1<>1 ';
        p1:= ' or exists (select ''Y'' from '||e2;
		p2:= ' xx where xx.'||fk2||' = '||partyid;
		if j2 is not null then
			p3 := ' and '||'('||p3||')';
		end if;
         p4:= ' and exists' ;
       elsif(first = 'FALSE' AND cnt=1) then
        l_sql := 'delete from hz_purge_gt temp where ';
         if(cnt2=1) then
         p1:= partyid||' in (select /*+ parallel (xx)*/ xx.'||fk2||' from '||e2;
        else
         p1:= ' or '||partyid||' in (select /*+ parallel (xx)*/ xx.'||fk2||' from '||e2;
        end if;
        p2:= ' xx ';
		p4:= ' xx.'||pk2||' ';
		if(fk_data_typ1<>fk_data_typ2) then
          if fk_data_typ1='VARCHAR2' then
            p4:= ' to_char(xx.'||pk2||')';
          end if;
        end if;
		if j2 is not null then
			p3 := ' where '||'('||p3||')';
			p4 := ' and '||p4;
		else
		    p4 := ' where '||p4;
		end if;
       end if;

         if j1 is not null then
          	--select decode(instr(j1,'group'),0,' and '||j1,' and '||substr(j1,1,instr(j1,'group')-1)) into p7 from dual;
          	select decode(instr(j1,'group'),0,j1,substr(j1,1,instr(j1,'group')-1)) into p7 from dual;
         else
         	p7:='';
         end if;

         if(first='FALSE') then
           p5:= ' in (select /*+ parallel(yy)*/ yy.'||fk1||' from '||e1;
           p6:= ' yy ';
           if j1 is not null then
        	p7:= ' where '||p7;
           end if;
         else
          	p5 := '(select ''Y'' from '||e1;
        	p6:= ' yy where yy.'||fk1||'=xx.'||pk2||'';
         	if(fk_data_typ1<>fk_data_typ2) then
          		if fk_data_typ1='VARCHAR2' then
            		p6:= ' yy where yy.'||fk1||'=to_char(xx.'||pk2||')';
           		end if;
         	end if;
           if j1 is not null then
        	p7:= ' and '||p7;
           end if;
         end if;

         p8:= '))';
         s1:=s1||fnd_global.local_chr(10)||p1||fnd_global.local_chr(10)||p2||fnd_global.local_chr(10)||p3||fnd_global.local_chr(10)||p4||
              fnd_global.local_chr(10)||p5||fnd_global.local_chr(10)||p6||fnd_global.local_chr(10)||p7||p8;

         else

          if(cnt2>1) then
           cnt3:=1;
          else
           cnt3:=0;
          end if;

         -- open cursor to get the third level tables, which have HZ_PARTIES as parent_entity
          open x3(pe2);
          loop
          fetch x3 into e3, fk3, pk3, j3, pe3,fk_data_typ3;
          exit when x3%NOTFOUND;
           cnt3:=cnt3+1;
          if pe3 = 'HZ_PARTIES' then
           partyid :=' temp.party_id ';

         if (fk_data_typ3<>'NUMBER' AND fk_data_typ3 IS NOT NULL) then
           partyid := ' to_char(temp.party_id) ';
          end if;

          if j3 is not null then
           --select decode(instr(j3,'group'),0,' and '||j3,' and '||substr(j3,1,instr(j3,'group')-1)) into p3 from dual;
           	select decode(instr(j3,'group'),0,j3,substr(j3,1,instr(j3,'group')-1)) into p3 from dual;
          else
          	p3:='';
          end if;

          if(first = 'TRUE' AND cnt=1) then
           l_sql := 'delete from hz_purge_gt temp where ';
           if(cnt3=1) then
            p1:= ' exists (select ''Y'' from '||e3;
           else
            p1:= ' or exists (select ''Y'' from '||e3;
           end if;
           p2:= ' xx where xx.'||fk3||' = '||partyid ;
           if j3 is not null then
           	p3:=' and '||'('||p3||')';
           end if;
        	p4:= ' and exists ';
          elsif (first = 'TRUE' AND cnt>1) then
           l_sql := 'delete from hz_purge_gt temp where 1<>1 ';
           p1:= ' or exists (select ''Y'' from '||e3;
           p2:= ' xx where xx.'||fk3||' = '||partyid ;
           if j3 is not null then
           	p3:=' and '||'('||p3||')';
           end if;
           p4:= ' and exists ';
          elsif(first = 'FALSE' AND cnt=1) then
           if(cnt3=1) then
            l_sql := 'delete from hz_purge_gt temp where ';
            p1:= partyid||' in (select /*+ parallel(xx)*/ ''Y'' from '||e3;
           else
            p1:= ' or '||partyid||' in (select /*+ parallel(xx)*/ ''Y'' from '||e3;
           end if;
			p2:= ' xx ' ;
			if(fk_data_typ2<>fk_data_typ3) then
           		if fk_data_typ3='VARCHAR2' then
            		p4:= ' to_char(xx.'||pk3||')';
           		end if;
        	end if;
        	if j3 is not null then
           		p3:=' where '||'('||p3||')';
           		p4:= ' and '||p4||' ';
           	else
           		p4:= ' where '||p4||' ';
           	end if;
          end if;


          if j2 is not null then
          	--select decode(instr(j2,'group'),0,' and '||j2,' and '||substr(j2,1,instr(j2,'group')-1)) into p7 from dual;
           	select decode(instr(j2,'group'),0,j2,substr(j2,1,instr(j2,'group')-1)) into p7 from dual;
          else
          	p7:='';
          end if;

        if(first='FALSE') then
           p5:= ' in (select /*+ parallel(yy)*/ yy.'||fk2||' from '||e2;
           p6:= ' yy ';
		   if(fk_data_typ1<>fk_data_typ2) then
           		if fk_data_typ1='VARCHAR2' then
            		p8:= ' and to_char(yy.'||pk2||')';
           		end if;
           end if;
		   if j2 is not null then
			  p7:= ' where '||p7;
			  p8:= ' and '||p8||'';
		   else
		      p8:= ' where '||p8||'';
		   end if;
		else
           p5:= ' (select ''Y'' from '||e2;
           p6:= ' yy where yy.'||fk2||'=xx.'||pk3||' ';
         	if(fk_data_typ2<>fk_data_typ3) then
           		if fk_data_typ3='VARCHAR2' then
            		p6:= ' yy where yy.'||fk2||'=to_char(xx.'||pk3||')';
           		end if;
         	end if;
		 	if j2 is not null then
			  p7:= ' and '||p7;
			end if;
		   p8:= ' and exists ';
          end if;

          if j1 is not null then
           --select decode(instr(j1,'group'),0,' and '||j1,' and '||substr(j1,1,instr(j1,'group')-1)) into p11 from dual;
           	select decode(instr(j1,'group'),0,j1,substr(j1,1,instr(j1,'group')-1)) into p11 from dual;
          else
          	p11:=' ';
          end if;

          if (first='FALSE') then
           p9:= ' in (select /*+ parallel(zz)*/ yy.'||pk2||' from '||e1;
           p10:= ' zz ';
           if j1 is not null then
           	p11:= ' where '||p11;
           end if;
          else
           p9:= ' (select ''Y'' from '||e1;
           p10:= ' zz where zz.'||fk1||' = yy.'||pk2;
           	if(fk_data_typ1<>fk_data_typ2) then
           		if fk_data_typ1='VARCHAR2' then
            		p10:= ' zz where zz.'||fk1||'=to_char(yy.'||pk2||')';
           		end if;
         	end if;
			if j1 is not null then
           		p11:= ' and '||p11;
           	end if;
          end if;

          p12:= ')))';
          s1:=s1||fnd_global.local_chr(10)||p1||fnd_global.local_chr(10)||p2||fnd_global.local_chr(10)||p3||fnd_global.local_chr(10)||p4||fnd_global.local_chr(10)||p5||
              fnd_global.local_chr(10)||p6||fnd_global.local_chr(10)||p7||fnd_global.local_chr(10)||p8||fnd_global.local_chr(10)||p9||p10||
              p11||p12;
           end if;

          end loop;
          close x3;
        end if;

       end loop;
       close x2;

     end if;
     l_sql := l_sql||fnd_global.local_chr(10)||s1;
     valid_stmt:= has_context(l_sql);
     --valid_stmt:=true;
    if (valid_stmt=true) then
     --dbms_output.put_line('cnt='||cnt||',e1='||e1);
      concat_string := s1;
    else
      concat_string := null;
      --dbms_output.put_line('notvalid cnt='||l_sql);
    end if;

EXCEPTION
 WHEN OTHERS THEN
 null;
END;

END HZ_PURGE;

/
