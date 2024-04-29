--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_TREND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_TREND_PVT" AS
/* $Header: pvptrndb.pls 120.3 2006/02/24 16:50:13 dhii noship $ */

PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_type);
   FND_MESSAGE.Set_Token('TEXT', p_msg_string);

   IF (g_log_to_file = 'N') THEN
      FND_MSG_PUB.Add;

   ELSIF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
   END IF;
END Debug;



FUNCTION kpi_oppty_cnt_offset(p_salesforce_id number) return number as

cursor c1 (pc_id number) is
select sum(offset_cnt) from
 (select a.lead_id,count(*)-1 offset_cnt from
  pv_lead_workflows a, pv_lead_assignments b, as_leads_all c, as_statuses_b d
  where a.wf_item_type = b.wf_item_type
  and a.wf_item_key = b.wf_item_key
  and a.latest_routing_flag = 'Y'
  and a.routing_status = 'ACTIVE'
  and b.status in ('PT_APPROVED', 'CM_APP_FOR_PT')
  and a.routing_type = 'JOINT'
  and a.lead_id = c.lead_id
  and c.status = d.status_code
  and d.opp_open_status_flag = 'Y'
  and exists
   (select 1
    from pv_partner_accesses aa, jtf_rs_rep_managers bb,
    jtf_rs_group_usages cc where bb.parent_resource_id = pc_id
    and nvl(bb.end_date_active, sysdate) >= sysdate
    and bb.group_id = cc.group_id and cc.usage = 'PRM'
    and bb.resource_id = aa.resource_id
    and aa.partner_id = b.partner_id
  )
  group by a.lead_id);

l_count number;

begin

open c1(pc_id => p_salesforce_id);
fetch c1 into l_count;
return nvl(l_count,0);

EXCEPTION
WHEN OTHERS THEN
 RETURN 0;
end;


FUNCTION kpi_oppty_amt_offset(p_salesforce_id number, p_currency_code varchar2) return number as

cursor c1 (pc_id number, pc_currency varchar2) is
select sum(offset_AMT) from
 (SELECT A.LEAD_ID,SUM(pv_check_match_pub.currency_conversion(c.total_amount,
  c.currency_code,sysdate, pc_currency)) /count(*) * (count(*)-1) offset_amt
  FROM PV_LEAD_WORKFLOWS A, PV_LEAD_ASSIGNMENTS B, AS_LEADS_ALL C, AS_STATUSES_B D
  WHERE A.WF_ITEM_TYPE = B.WF_ITEM_TYPE
  AND A.WF_ITEM_KEY = B.WF_ITEM_KEY
  AND A.LATEST_ROUTING_FLAG = 'Y'
  AND A.ROUTING_STATUS = 'ACTIVE'
  and b.status IN ('PT_APPROVED', 'CM_APP_FOR_PT')
  AND A.ROUTING_TYPE = 'JOINT'
  AND A.LEAD_ID = C.LEAD_ID
  AND C.TOTAL_AMOUNT IS NOT NULL
  and c.status = d.status_code
  and d.opp_open_status_flag = 'Y'
  and exists
   (select 1
    from pv_partner_accesses aa, jtf_rs_rep_managers bb,
    jtf_rs_group_usages cc where bb.parent_resource_id = pc_id
    and nvl(bb.end_date_active, sysdate) >= sysdate
    and bb.group_id = cc.group_id and cc.usage = 'PRM'
    and bb.resource_id = aa.resource_id
    and aa.partner_id = b.partner_id
  )
  GROUP BY A.LEAD_ID);

l_amount number;

begin

open c1(pc_id => p_salesforce_id, pc_currency => p_currency_code);
fetch c1 into l_amount;
return nvl(l_amount,0);

EXCEPTION
WHEN OTHERS THEN
 RETURN 0;
end;



PROCEDURE refresh_partner_trend ( ERRBUF              OUT  NOCOPY VARCHAR2,
                                  RETCODE             OUT  NOCOPY VARCHAR2,
                                  p_from_date         IN VARCHAR2,
                                  p_to_date           IN VARCHAR2,
                                  p_new_partners_flag IN VARCHAR2 := 'N',
                                  p_ignore_refresh_interval IN VARCHAR2 DEFAULT 'N',
                                  p_partner_id        IN NUMBER DEFAULT NULL,
                                  p_log_to_file       IN VARCHAR2)
IS
    l_warning_count pls_integer := 0;
    l_message varchar2(500);
    l_run_date date := sysdate;
    l_to_date  date := last_day(nvl(TO_DATE(p_to_date, 'yyyy/mm/dd hh24:mi:ss'), sysdate));
    l_from_date  date := trunc(nvl(TO_DATE(p_from_date, 'yyyy/mm/dd hh24:mi:ss'), sysdate), 'MM');
    l_run_date_str varchar2(30) := TO_CHAR(l_run_date, 'MM-DD-YYYY HH24:MI:SS');
    l_next_trend_id number;
    l_attr_has_data boolean;

    cursor lc_get_attrs is
        select a.attribute_id, c.name, b.return_type, b.attribute_type, nvl(b.additive_flag, 'N') additive_flag,
        a.sql_text, a.batch_sql_text, a.refresh_frequency, a.refresh_frequency_uom, a.last_refresh_date,
        nvl(decode(a.refresh_frequency_uom, 'HOUR',   a.refresh_frequency * 1/24,
                                         'DAY',   a.refresh_frequency * 1,
                                         'WEEK',  (trunc(nvl(a.last_refresh_date,SYSDATE), 'IW') + a.refresh_frequency * 7)
                                                  -nvl(a.last_refresh_date,sysdate),
                                         'MONTH', add_months(trunc(NVL(a.last_refresh_date,SYSDATE), 'MM'), a.refresh_frequency)
                                                  -nvl(a.last_refresh_date,sysdate)
        ),0) refresh_interval_days
        from pv_entity_attrs a, pv_attributes_b b, pv_attributes_tl c
        where a.entity = 'PARTNER_TREND'
        and a.attribute_id = b.attribute_id
        and a.enabled_flag = 'Y' and b.performance_flag = 'Y'
        and b.enabled_flag = 'Y'
        and b.attribute_id = c.attribute_id
        and c.LANGUAGE = userenv('LANG');

    -- ---------------------------------------------------------------------------------
    -- Obsolete sales_partner_flag from the SQL. Added "partner_resource_id IS NOT NULL"
    -- predicate.
    -- ---------------------------------------------------------------------------------
    cursor lc_get_new_pt (pc_creation_date date, pc_partner_id number) is
        SELECT partner_id
        FROM   pv_partner_profiles pvpp
        WHERE  pvpp.status = 'A' AND
               pvpp.partner_resource_id IS NOT NULL AND
               pvpp.creation_date >= pc_creation_date
        union all
        select partner_id from pv_partner_profiles pvpp
        where  status = 'A' AND
               pvpp.partner_resource_id IS NOT NULL AND
               partner_id = pc_partner_id;

    type l_gen_cur_type is ref cursor;
    l_gen_cur l_gen_cur_type;

    l_partner_id number;
    l_result number;
    l_month varchar2(20);
    l_counter number;
    l_currency_code varchar2(15);
    l_currency_date date;
    l_ret_val          BOOLEAN := FALSE;

    l_last_incr_refresh_str  VARCHAR2(100);
    l_last_incr_refresh_date DATE;

    l_attr_trend_id_tbl jtf_number_table;
    l_partner_id_tbl    jtf_number_table;
    l_attribute_id_tbl  jtf_number_table;
    l_result_tbl        jtf_number_table;
    l_month_tbl         jtf_varchar2_table_4000;
    l_result_tmp_tbl    jtf_number_table;
    l_month_tmp_tbl     jtf_varchar2_table_4000;
    l_currency_code_tbl jtf_varchar2_table_4000;
    l_currency_date_tbl jtf_date_table;


BEGIN

   IF (p_log_to_file <> 'Y') THEN
      g_log_to_file := 'N';
   ELSE
      g_log_to_file := 'Y';
   END IF;

   g_module_name := 'Refresh Partner Trends Program. New Partner only: ' || p_new_partners_flag;

   -- -----------------------------------------------------------------------
   -- Exit the program if there is already a session running.
   -- -----------------------------------------------------------------------
   FOR x IN (SELECT COUNT(*) count FROM v$session
             WHERE  module LIKE 'Refresh Partner Trends Program%')
   LOOP
      IF (x.count > 0) THEN
         Debug('There is already a Refresh Partner Trends CC session running.');
         Debug('The program will now exit.');
         RETURN;
      END IF;
   END LOOP;

   dbms_application_info.set_module( module_name => g_module_name, action_name => 'EXECUTING');

   -- -----------------------------------------------------------------------
   -- Start time message...
   -- -----------------------------------------------------------------------
   FND_MESSAGE.SET_NAME(application => 'PV',
                        name        => 'PV_CREATE_CONTEXT_START_TIME');
   FND_MESSAGE.SET_TOKEN(token   => 'P_DATE_TIME',
                         value  =>  TO_CHAR(l_run_date, 'DD-MON-YYYY HH24:MI:SS') );

    IF (g_log_to_file = 'Y') THEN
       FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
       FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );
    ELSE
        FND_MSG_PUB.Add;
    END IF;

    g_common_currency := NVL(FND_PROFILE.Value('PV_COMMON_CURRENCY'), 'USD');
    Debug('The common currency is: ' || g_common_currency);

    g_period_set_name := FND_PROFILE.Value('AS_FORECAST_CALENDAR');
    Debug('The Period Set Name is: ' || g_period_set_name);

    select nvl(max(attribute_trend_id),0) + 1 into l_next_trend_id from pv_entity_attr_trends;
    Debug('Next available attribute_trend_id: ' || l_next_trend_id);

    l_last_incr_refresh_str  := FND_PROFILE.VALUE('PV_PT_TREND_LAST_UPDATE');

    IF (p_new_partners_flag = 'Y' and l_last_incr_refresh_str is not null ) OR p_partner_id is not null THEN

        if p_partner_id is null then
            l_last_incr_refresh_date := TO_DATE(l_last_incr_refresh_str,'MM-DD-YYYY HH24:MI:SS');
            Debug('Type of Refresh: INCREMENTAL');
            Debug('Initiating incremental refresh...only new partners added to the ');
            Debug('system since the refresh date will be retrieved and updated.');
            Debug('Last refresh date: ' || l_last_incr_refresh_str);
        else
            Debug('Refreshing for only 1 partner');
        end if;

        -- if refreshing for 1 partner only l_last_incr_refresh_date will be null
        -- else partner_id will be null
        FOR L_NEW_PT_REC IN LC_GET_NEW_PT(pc_creation_date => l_last_incr_refresh_date, pc_partner_id => p_partner_id) loop

            Debug('Refreshing partner trends for partner_id: ' || l_new_pt_rec.partner_id);
            l_partner_id_tbl := jtf_number_table();
            l_result_tbl := jtf_number_table();
            l_month_tbl := jtf_varchar2_table_4000();
            l_attribute_id_tbl := jtf_number_table();
            l_currency_code_tbl := jtf_varchar2_table_4000();
            l_currency_date_tbl := jtf_date_table();
            l_counter := 0;

            FOR LC_ATTR_REC IN LC_GET_ATTRS LOOP

                if lc_attr_rec.sql_text is null then
                    Debug('Unable to process attribute: ' || lc_attr_rec.name || '.  No sql text');
                else
                    Debug('Processing attribute: ' || lc_attr_rec.name);
                    if lc_attr_rec.return_type = 'CURRENCY' then
                        l_currency_code := g_common_currency;
                        l_currency_date := trunc(sysdate);
                    else
                        l_currency_code := null;
                        l_currency_date := null;
                    end if;

                    begin
                        if lc_attr_rec.additive_flag = 'Y' AND lc_attr_rec.return_type <> 'CURRENCY' then
                            open l_gen_cur for lc_attr_rec.sql_text using
                            l_new_pt_rec.partner_id, l_from_date, l_to_date;
                        elsif lc_attr_rec.additive_flag = 'Y' and lc_attr_rec.return_type = 'CURRENCY' then
                            open l_gen_cur for  lc_attr_rec.sql_text using
                            g_common_currency, g_period_set_name, l_new_pt_rec.partner_id, l_from_date, l_to_date;
                        else
                            if lc_attr_rec.return_type = 'CURRENCY' then
                                open l_gen_cur for lc_attr_rec.sql_text using g_common_currency, g_period_set_name, l_new_pt_rec.partner_id;
                            else
                                open l_gen_cur for lc_attr_rec.sql_text using l_new_pt_rec.partner_id;
                            end if;
                        end if;
                        loop
                            fetch l_gen_cur into l_month, l_result;
                            exit when l_gen_cur%notfound;
                            l_counter := l_counter + 1;
                            l_partner_id_tbl.extend;
                            l_result_tbl.extend;
                            l_month_tbl.extend;
                            l_currency_code_tbl.extend;
                            l_currency_date_tbl.extend;
                            l_attribute_id_tbl.extend;
                            l_attribute_id_tbl(l_counter) := lc_attr_rec.attribute_id;
                            l_partner_id_tbl(l_counter) := l_new_pt_rec.partner_id;
                            l_month_tbl(l_counter) := l_month;
                            l_result_tbl(l_counter) := l_result;
                            l_currency_code_tbl(l_counter) := l_currency_code;
                            l_currency_date_tbl(l_counter) := l_currency_date;
                        end loop;
                        close l_gen_cur;
                    exception
                    when others then
                        Debug('Error encountered executing sql_text for attribute: ' || lc_attr_rec.name);

								l_warning_count := l_warning_count + 1;
								l_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);

								while (l_message is not null) loop
									debug(substr(l_message,1,200));
									l_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);
								end loop;

                        Debug('Error code: ' || sqlcode);
                        Debug('Error msg: ' || sqlerrm);
                    end;
                end if;
            end loop;

            if l_partner_id_tbl.count > 0 then

                Debug('Adding to partner trend table for partner_id: ' || l_new_pt_rec.partner_id);

                begin
                    savepoint current_partner;
                    delete from pv_entity_attr_trends where entity = 'PARTNER' and time_uom = 'MONTH'
                    and entity_id = l_new_pt_rec.partner_id
                    and attribute_id in ( select b.attribute_id from  pv_entity_attrs a, pv_attributes_b b
                                      where a.entity = 'PARTNER_TREND' and a.attribute_id = b.attribute_id
                                      and b.performance_flag = 'Y' and b.additive_flag = 'Y')
                    and trend_timeline between l_from_date and l_to_date;

                    delete from pv_entity_attr_trends where entity = 'PARTNER' and time_uom = 'MONTH'
                    and attribute_id in ( select b.attribute_id from  pv_entity_attrs a, pv_attributes_b b
                                      where a.entity = 'PARTNER_TREND' and a.attribute_id = b.attribute_id
                                      and b.performance_flag = 'Y' and b.additive_flag = 'N')
                    and entity_id = l_new_pt_rec.partner_id and trend_timeline = trunc(l_run_date, 'MM');

                    l_attr_trend_id_tbl := jtf_number_table();
                    l_attr_trend_id_tbl.extend(l_partner_id_tbl.count);

                    for i in 1..l_partner_id_tbl.count loop
                        l_attr_trend_id_tbl(i) := l_next_trend_id;
                        l_next_trend_id := l_next_trend_id + 1;
                    end loop;

                    forall i in l_partner_id_tbl.first .. l_partner_id_tbl.last
                        insert into pv_entity_attr_trends
                        (ATTRIBUTE_TREND_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,
                         LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER,ENTITY,ENTITY_ID,ATTRIBUTE_ID,ATTR_VALUE,
                         CURRENCY_CODE,CURRENCY_DATE,TREND_TIMELINE,TIME_UOM) values
                        (l_attr_trend_id_tbl(i), sysdate, 1, sysdate, 1, 1, 1, 'PARTNER',
                         l_partner_id_tbl(i), l_attribute_id_tbl(i), l_result_tbl(i),
                         l_currency_code_tbl(i), l_currency_date_tbl(i), l_month_tbl(i), 'MONTH');
                    commit;
                exception
                when others then
                    Debug('Error encountered adding to partner trend table for partner_id: ' || l_new_pt_rec.partner_id);
							l_warning_count := l_warning_count + 1;
							l_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);

							while (l_message is not null) loop
								debug(substr(l_message,1,200));
								l_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);
							end loop;

                    Debug('Error code: ' || sqlcode);
                    Debug('Error msg: ' || sqlerrm);
                    rollback to current_partner;
                end;
            else
                Debug('No Trend information found for partner_id: ' || l_new_pt_rec.partner_id);
            end if;

        end loop;

    ELSE
        if p_new_partners_flag = 'Y' THEN
            Debug('Defaulting to Full refresh even though incremental refresh was specified');
            Debug('Because Last refresh date profile is null');
        else
            Debug('Type of Refresh: FULL');
        end if;

        FOR LC_ATTR_REC IN LC_GET_ATTRS LOOP
            if (lc_attr_rec.last_refresh_date + lc_attr_rec.refresh_interval_days < l_run_date)
            or lc_attr_rec.last_refresh_date is null or p_ignore_refresh_interval = 'Y' then

                if lc_attr_rec.attribute_type = 'FUNCTION' then
                    -- because process memory is limited, do not exceed 1000 rows in table types
                    Debug('Cannot support FUNCTION attribute_type for batch_sql_text for FULL refresh');

                elsif lc_attr_rec.batch_sql_text is null then
                    Debug('Unable to refresh attribute: ' || lc_attr_rec.name || '.  No batch sql text');
                else
                    Debug('Refreshing attribute: ' || lc_attr_rec.name ||
                    '.  Last refresh date: ' || nvl(to_char(lc_attr_rec.last_refresh_date, 'YYYY/MM/DD HH24:MI:SS'), 'None'));

                    l_partner_id_tbl := jtf_number_table();
                    l_result_tbl     := jtf_number_table();
                    l_month_tbl      := jtf_varchar2_table_4000();

                    if lc_attr_rec.return_type = 'CURRENCY' then
                        l_currency_code := g_common_currency;
                        l_currency_date := trunc(sysdate);
                    else
                        l_currency_code := null;
                        l_currency_date := null;
                    end if;

                    begin
                        savepoint current_attribute;
                        l_attr_has_data := false;
                        if lc_attr_rec.additive_flag = 'Y' then
                            if lc_attr_rec.return_type = 'CURRENCY' then
                                open l_gen_cur for lc_attr_rec.batch_sql_text
                                using g_common_currency, g_period_set_name, l_from_date, l_to_date;
                            else
                                open l_gen_cur for lc_attr_rec.batch_sql_text using l_from_date, l_to_date;
                            end if;
                        else
                            if lc_attr_rec.return_type = 'CURRENCY' then
                                open l_gen_cur for lc_attr_rec.batch_sql_text using g_common_currency, g_period_set_name;
                            else
                                open l_gen_cur for lc_attr_rec.batch_sql_text;
                            end if;
                        end if;

                        l_counter := 0;
                        loop
                            fetch l_gen_cur into l_partner_id, l_month, l_result;
                            exit when l_gen_cur%notfound;
                            l_counter := l_counter + 1;
                            l_partner_id_tbl.extend;
                            l_result_tbl.extend;
                            l_month_tbl.extend;
                            l_partner_id_tbl(l_counter) := l_partner_id;
                            l_month_tbl(l_counter) := l_month;
                            l_result_tbl(l_counter) := l_result;

                            if l_counter = 1000 then

                                l_attr_trend_id_tbl := jtf_number_table();
                                l_attr_trend_id_tbl.extend(l_partner_id_tbl.count);

                                for i in 1..l_partner_id_tbl.count loop
                                    l_attr_trend_id_tbl(i) := l_next_trend_id;
                                    l_next_trend_id := l_next_trend_id + 1;
                                end loop;

                                if not l_attr_has_data then
                                    Debug('Deleting from pv_entity_attr_trends for attribute: ' || lc_attr_rec.name);

                                    if lc_attr_rec.additive_flag = 'Y' then
                                        delete from pv_entity_attr_trends where entity = 'PARTNER' and time_uom = 'MONTH'
                                        and attribute_id = lc_attr_rec.attribute_id
                                        and trend_timeline between l_from_date and l_to_date;
                                    ELSE
                                        delete from pv_entity_attr_trends where entity = 'PARTNER' and time_uom = 'MONTH'
                                        and attribute_id = lc_attr_rec.attribute_id and trend_timeline = trunc(l_run_date, 'MM');
                                    END IF;
                                    l_attr_has_data := true;
                                end if;

                                Debug('Adding to partner trend table for attribute: ' || lc_attr_rec.name);

                                forall i in l_partner_id_tbl.first .. l_partner_id_tbl.last
                                    insert into pv_entity_attr_trends
                                    (ATTRIBUTE_TREND_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,
                                     LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER,ENTITY,ENTITY_ID,ATTRIBUTE_ID,ATTR_VALUE,
                                     CURRENCY_CODE,CURRENCY_DATE,TREND_TIMELINE,TIME_UOM) values
                                    (l_attr_trend_id_tbl(i), sysdate, 1, sysdate, 1, 1, 1, 'PARTNER', l_partner_id_tbl(i),
                                     lc_attr_rec.attribute_id, l_result_tbl(i), l_currency_code, l_currency_date, l_month_tbl(i), 'MONTH');

                                l_partner_id_tbl := jtf_number_table();
                                l_result_tbl     := jtf_number_table();
                                l_month_tbl      := jtf_varchar2_table_4000();
                                l_counter := 0;
                            end if;

                        end loop;
                        close l_gen_cur;

                        if l_partner_id_tbl.count > 0 then

                            l_attr_trend_id_tbl := jtf_number_table();
                            l_attr_trend_id_tbl.extend(l_partner_id_tbl.count);

                            for i in 1..l_partner_id_tbl.count loop
                                l_attr_trend_id_tbl(i) := l_next_trend_id;
                                l_next_trend_id := l_next_trend_id + 1;
                            end loop;

                            if not l_attr_has_data then
                                Debug('Deleting from pv_entity_attr_trends for attribute: ' || lc_attr_rec.name);
                                if lc_attr_rec.additive_flag = 'Y' then
                                    delete from pv_entity_attr_trends where entity = 'PARTNER' and time_uom = 'MONTH'
                                    and attribute_id = lc_attr_rec.attribute_id
                                    and trend_timeline between l_from_date and l_to_date;
                                ELSE
                                    delete from pv_entity_attr_trends where entity = 'PARTNER' and time_uom = 'MONTH'
                                    and attribute_id = lc_attr_rec.attribute_id and trend_timeline = trunc(l_run_date, 'MM');
                                END IF;
                                l_attr_has_data := true;
                            END IF;

                            Debug('Adding to partner trend table for attribute: ' || lc_attr_rec.name);
                            forall i in l_partner_id_tbl.first .. l_partner_id_tbl.last
                                insert into pv_entity_attr_trends
                                (ATTRIBUTE_TREND_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,
                                 LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER,ENTITY,ENTITY_ID,ATTRIBUTE_ID,ATTR_VALUE,
                                 CURRENCY_CODE,CURRENCY_DATE,TREND_TIMELINE,TIME_UOM) values
                                (l_attr_trend_id_tbl(i), sysdate, 1, sysdate, 1, 1, 1, 'PARTNER', l_partner_id_tbl(i),
                                 lc_attr_rec.attribute_id, l_result_tbl(i), l_currency_code, l_currency_date, l_month_tbl(i), 'MONTH');
                        end if;

                        if l_attr_has_data then
                            update pv_entity_attrs set last_refresh_date = l_run_date where attribute_id = lc_attr_rec.attribute_id
                            and entity = 'PARTNER_TREND';
                        else
                            Debug('Attribute: ' || lc_attr_rec.name || ' has no data for any partner for time period specified');
                        end if;
                        commit;
                    exception
                    when others then
                        Debug('Error encountered executing batch_sql_text for attribute: ' || lc_attr_rec.name);

								l_warning_count := l_warning_count + 1;
								l_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);

								while (l_message is not null) loop
									debug(substr(l_message,1,200));
									l_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);
								end loop;

                        Debug('Error code: ' || sqlcode);
                        Debug('Error msg: ' || sqlerrm);
                        rollback to current_attribute;
                    end;
                end if;

            else
                Debug('Bypass refresh of attribute: ' || lc_attr_rec.name ||
               '.  Last refresh date: ' || nvl(to_char(lc_attr_rec.last_refresh_date, 'YYYY/MM/DD HH24:MI:SS'), 'None'));
               Debug('Refresh interval is ' || lc_attr_rec.refresh_frequency || ' ' || lc_attr_rec.refresh_frequency_uom);

            end if;
        END LOOP;

    end if;

    FND_MESSAGE.SET_NAME( application => 'PV' ,name => 'PV_CREATE_CONTEXT_END_TIME');
    FND_MESSAGE.SET_TOKEN( token   => 'P_DATE_TIME'
                          ,value  =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );

    IF (g_log_to_file = 'Y') THEN
        FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );
        FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
    ELSE
        FND_MSG_PUB.Add;
    END IF;

   -- ------------------------------------------------------------------
   -- update the profile value so the
   -- next incremental refresh will be based on this timestamp.
   --
   -- FND_PROFILE.PUT changes the profile value in the session.
   -- FND_PROFILE.SAVE saves the profile value to the database.
   -- ------------------------------------------------------------------

    if p_partner_id is null then
       FND_PROFILE.PUT('PV_PT_TREND_LAST_UPDATE', l_run_date_str);
       l_ret_val := FND_PROFILE.SAVE('PV_PT_TREND_LAST_UPDATE', l_run_date_str,'SITE');
       Debug('The next incremental refresh will start from ' || l_run_date_str);
    end if;

   if l_warning_count > 10 then
      retcode := '2';  -- indicate error
   elsif l_warning_count > 0 then
      retcode := '1';  -- indicate warning
   else
      retcode := '0';
   end if;

EXCEPTION
WHEN OTHERS THEN
   RETCODE := sqlcode;
   ERRBUF := sqlerrm;

END;
END;

/
