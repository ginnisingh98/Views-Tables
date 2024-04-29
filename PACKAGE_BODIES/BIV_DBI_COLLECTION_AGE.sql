--------------------------------------------------------
--  DDL for Package Body BIV_DBI_COLLECTION_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_COLLECTION_AGE" as
/* $Header: bivsrvcageb.pls 120.0 2005/05/25 10:50:34 appldev noship $ */

  g_bis_setup_exception exception;
  g_user_id number := fnd_global.user_id;
  g_login_id number := fnd_global.login_id;

procedure load_backlog_aging
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2)
is

  l_exception exception;
  l_error_message varchar2(4000);

  l_log_rowid rowid;
  l_process_type varchar2(30);
  l_collect_from_date date;
  l_collect_to_date date;
  l_success_flag varchar2(1);
  l_staging_flag varchar2(1);
  l_activity_flag varchar2(1);
  l_closed_flag varchar2(1);
  l_backlog_flag varchar2(1);
  l_resolution_flag varchar2(1);

  l_biv_schema varchar2(100);

  l_rowcount number;

  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_return_status varchar2(3);
  l_error_tbl bis_utilities_pub.error_tbl_type;

begin

  if not bis_collection_utilities.setup( 'BIV_BAC_AGE_SUM_F' ) then
    raise g_bis_setup_exception;
  end if;

  biv_dbi_collection_util.get_last_log( l_log_rowid
                                      , l_process_type
                                      , l_collect_from_date
                                      , l_collect_to_date
                                      , l_success_flag
                                      , l_staging_flag
                                      , l_activity_flag
                                      , l_closed_flag
                                      , l_backlog_flag
                                      , l_resolution_flag
                                      );

  if nvl(l_success_flag,'X') <> 'Y' then
    l_error_message := 'Backlog Age process called for after an incompleted initial/incremental load';
    raise l_exception;
  end if;

  bis_bucket_pub.retrieve_bis_bucket
  ( p_short_name     => 'BIV_DBI_BACKLOG_AGING'
  , x_bis_bucket_rec => l_bucket_rec
  , x_return_status  => l_return_status
  , x_error_tbl      => l_error_tbl
  );

  if l_return_status <> 'S' then
    if l_error_tbl is not null then
      l_error_message := l_error_tbl(1).error_description;
    else
      l_error_message := 'Unable to retrieve aging bucket definition';
    end if;
    raise l_exception;
  end if;

  bis_collection_utilities.log('Starting Backlog Aging Load, aging As At ' ||
                                fnd_date.date_to_displaydt(l_collect_to_date));

  if biv_dbi_collection_util.get_schema_name
     ( l_biv_schema
     , l_error_message ) <> 0 then
    raise l_exception;
  end if;

  bis_collection_utilities.log('truncating dates table',1);

  if biv_dbi_collection_util.truncate_table
     ( l_biv_schema
     , 'BIV_DBI_BACKLOG_AGE_DATES'
     , l_error_message ) <> 0 then
    raise l_exception;
  end if;

  bis_collection_utilities.log('loading dates table',1);

  insert
  into biv_dbi_backlog_age_dates
  ( report_date
  , record_type_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  )
  select
    report_date
  , record_type_id
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  from
  (
  /* Dates for RLX model */
  select
    least(add_months(trunc(l_collect_to_date),case when m.id >8 then -12 else 0 end)
          + t.offset * case
                         when m.id in (1,5,9) then 7
                         when m.id in (2,6,10) then 30
                         when m.id in (3,7,11) then 90
                         when m.id in (4,8,12) then 365
                         else 1
                       end
                     + case
                         when m.id = 5 then -7
                         when m.id = 6 then -30
                         when m.id = 7 then -90
                         when m.id = 8 then -365
                         else 0
                       end
          + 86399/86400,l_collect_to_date) report_date
  , sum( power(2,m.id) ) record_type_id
  from
    biv_trend_rpt t
  , oki_dbi_multiplexer_b m
  where t.current_ind = 1
  and m.id <= 12
  and t.offset > case
                   when m.id in (1,5,9) then -13
                   when m.id in (2,6,10) then -12
                   when m.id in (3,7,11) then -8
                   when m.id in (4,8,12) then -4
                   else 1
                 end
  group by
    least(add_months(trunc(l_collect_to_date),case when m.id >8 then -12 else 0 end)
          + t.offset * case
                         when m.id in (1,5,9) then 7
                         when m.id in (2,6,10) then 30
                         when m.id in (3,7,11) then 90
                         when m.id in (4,8,12) then 365
                         else 1
                       end
                     + case
                         when m.id = 5 then -7
                         when m.id = 6 then -30
                         when m.id = 7 then -90
                         when m.id = 8 then -365
                         else 0
                       end
          + 86399/86400,l_collect_to_date)
   UNION ALL
   /* Dates for XTD Model */
  select
  least(end_date + 86399/86400, l_collect_to_date)  report_date
  ,sum( power(2,id+12) ) record_type_id
  from
  (select -- DAY
      id
    , end_date
    from
     ( select m.id
       , least(fii.end_date, m.the_date) end_date
       , rank() over (partition by m.id  order by fii.start_date desc ) rnk
       from fii_time_day fii
       , (select
            id
          , case
              when id = 11 then  FII_TIME_API.ent_sd_lyr_end(l_collect_to_date)
              when id = 6 then (trunc(l_collect_to_date))
              else l_collect_to_date
            end the_date
          from oki_dbi_multiplexer_b
          where id in (1,6,11)
         ) m
       where fii.start_date < m.the_date
    )
    where rnk <= 7
    --
    union all
    --
    select -- WTD
      id
    , end_date
    from
     ( select m.id
       , least(fii.end_date, m.the_date) end_date
       , rank() over (partition by m.id  order by fii.start_date desc ) rnk
       from fii_time_week fii
       , (select
            id
          , case
              when id = 12 then FII_TIME_API.sd_lyswk(l_collect_to_date)
              when id = 7 then FII_TIME_API.sd_pwk(l_collect_to_date)
              else l_collect_to_date
            end the_date
          from oki_dbi_multiplexer_b
          where id in (2,7,12)
         ) m
       where fii.start_date < m.the_date
    )
    where rnk <= 13
    --
    union all
    --
    select -- MTD
      id
    , end_date
    from
     ( select m.id
       , least(fii.end_date, m.the_date) end_date
       , rank() over (partition by m.id  order by fii.start_date desc ) rnk
       from fii_time_ent_period fii
       , (select
            id
          , case
              when id = 13 then FII_TIME_API.ent_sd_lysper_end(l_collect_to_date)
              when id = 8 then FII_TIME_API.ent_sd_pper_end(l_collect_to_date)
              else l_collect_to_date
            end the_date
          from oki_dbi_multiplexer_b
          where id in (3,8,13)
         ) m
       where fii.start_date < m.the_date
    )
    where rnk <= 12
    --
    union all
    --
    select -- QTD
      id
    , end_date
    from
     ( select m.id
       , least(fii.end_date, m.the_date) end_date
       , rank() over (partition by m.id  order by fii.start_date desc ) rnk
       from fii_time_ent_qtr fii
       , (select
            id
          , case
              when id = 14 then FII_TIME_API.ent_sd_lysqtr_end(l_collect_to_date)
              when id = 9 then FII_TIME_API.ent_sd_pqtr_end (l_collect_to_date)
              else l_collect_to_date
            end the_date
          from oki_dbi_multiplexer_b
          where id in (4,9,14)
         ) m
       where fii.start_date < m.the_date
    )
    where (id in (4,9) and rnk <=8) or (id = 14 and rnk <= 4)
    --
    union all
    --
    select -- YTD
      id
    , end_date
    from
     ( select m.id
       , least(fii.end_date, m.the_date) end_date
       , rank() over (partition by m.id  order by fii.start_date desc ) rnk
       from fii_time_ent_year fii
       , (select
            id
          , case
              when id = 15 then FII_TIME_API.ent_sd_lyr_end(l_collect_to_date)
              when id = 10 then FII_TIME_API.ent_sd_lyr_end(l_collect_to_date)
              else l_collect_to_date
            end the_date
          from oki_dbi_multiplexer_b
          where id in (5,10,15)
         ) m
       where fii.start_date < m.the_date
    )
    where rnk <= 4
  )
  group by end_date
  );

  l_rowcount := sql%rowcount;

  bis_collection_utilities.log(l_rowcount || ' rows inserted',2);

  bis_collection_utilities.log('gathering stats on dates table',1);

  if biv_dbi_collection_util.gather_statistics
     ( l_biv_schema
     , 'BIV_DBI_BACKLOG_AGE_DATES'
     , l_error_message ) <> 0 then
    raise l_exception;
  end if;

  bis_collection_utilities.log('truncating Backlog Aging table',1);

  if biv_dbi_collection_util.truncate_table
     ( l_biv_schema
     , 'BIV_BAC_AGE_SUM_F'
     , l_error_message ) <> 0 then
    raise l_exception;
  end if;

  bis_collection_utilities.log('inserting Backlog Aging rows',1);

  insert /*+ APPEND parallel(f) */
  into biv_bac_age_sum_f f
  ( report_date
  , grp_id
  , incident_type_id
  , incident_severity_id
  , customer_id
  , owner_group_id
  , incident_status_id
  , vbh_category_id
  , product_id
  , backlog_count
  , total_backlog_age
  , backlog_age_b1
  , backlog_age_b2
  , backlog_age_b3
  , backlog_age_b4
  , backlog_age_b5
  , backlog_age_b6
  , backlog_age_b7
  , backlog_age_b8
  , backlog_age_b9
  , backlog_age_b10
  , escalated_count
  , total_escalated_age
  , escalated_age_b1
  , escalated_age_b2
  , escalated_age_b3
  , escalated_age_b4
  , escalated_age_b5
  , escalated_age_b6
  , escalated_age_b7
  , escalated_age_b8
  , escalated_age_b9
  , escalated_age_b10
  , unowned_count
  , total_unowned_age
  , unowned_age_b1
  , unowned_age_b2
  , unowned_age_b3
  , unowned_age_b4
  , unowned_age_b5
  , unowned_age_b6
  , unowned_age_b7
  , unowned_age_b8
  , unowned_age_b9
  , unowned_age_b10
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , resolved_flag
  , incident_urgency_id
  , incident_owner_id
  , escalated_flag
  )
  select /*+ parallel(f) parallel(c) parallel(pc) ordered use_merge(F) */
    trunc(c.report_date) report_date
  , 0 grp_id
  , f.incident_type_id
  , f.incident_severity_id
  , f.customer_id
  , f.owner_group_id
  , f.incident_status_id
  , pc.vbh_category_id
  , nvl(pc.master_id,pc.id)
  , count(*) backlog_count
  , sum(c.report_date-f.incident_date)
      total_backlog_age
  , sum(case
          when (l_bucket_rec.range1_low is null or
                c.report_date-f.incident_date >= l_bucket_rec.range1_low) and
               (l_bucket_rec.range1_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range1_high) then
            1 else 0
        end) backlog_age_b1
  , sum(case
          when c.report_date-f.incident_date >= l_bucket_rec.range2_low and
               (l_bucket_rec.range2_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range2_high) then
            1 else 0
        end) backlog_age_b2
  , sum(case
          when c.report_date-f.incident_date >= l_bucket_rec.range3_low and
               (l_bucket_rec.range3_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range3_high) then
            1 else 0
        end) backlog_age_b3
  , sum(case
          when c.report_date-f.incident_date >= l_bucket_rec.range4_low and
               (l_bucket_rec.range4_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range4_high) then
            1 else 0
        end) backlog_age_b4
  , sum(case
          when c.report_date-f.incident_date >= l_bucket_rec.range5_low and
               (l_bucket_rec.range5_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range5_high) then
            1 else 0
        end) backlog_age_b5
  , sum(case
          when c.report_date-f.incident_date >= l_bucket_rec.range6_low and
               (l_bucket_rec.range6_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range6_high) then
            1 else 0
        end) backlog_age_b6
  , sum(case
          when c.report_date-f.incident_date >= l_bucket_rec.range7_low and
               (l_bucket_rec.range7_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range7_high) then
            1 else 0
        end) backlog_age_b7
  , sum(case
          when c.report_date-f.incident_date >= l_bucket_rec.range8_low and
               (l_bucket_rec.range8_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range8_high) then
            1 else 0
        end) backlog_age_b8
  , sum(case
          when c.report_date-f.incident_date >= l_bucket_rec.range9_low and
               (l_bucket_rec.range9_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range9_high) then
            1 else 0
        end) backlog_age_b9
  , sum(case
          when c.report_date-f.incident_date >= l_bucket_rec.range10_low and
               (l_bucket_rec.range10_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range10_high) then
            1 else 0
        end) backlog_age_b10
  , sum(decode(f.escalated_date,null,null,1)) escalated_count
  , sum(decode(f.escalated_date,null,null, c.report_date-f.incident_date))
    total_escalated_age
  , sum(decode(f.escalated_date,null,null
       ,case
          when (l_bucket_rec.range1_low is null or
                c.report_date-f.incident_date >= l_bucket_rec.range1_low) and
               (l_bucket_rec.range1_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range1_high) then
            1 else 0
        end)) escalated_age_b1
  , sum(decode(f.escalated_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range2_low and
               (l_bucket_rec.range2_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range2_high) then
            1 else 0
        end)) escalated_age_b2
  , sum(decode(f.escalated_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range3_low and
               (l_bucket_rec.range3_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range3_high) then
            1 else 0
        end)) escalated_age_b3
  , sum(decode(f.escalated_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range4_low and
               (l_bucket_rec.range4_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range4_high) then
            1 else 0
        end)) escalated_age_b4
  , sum(decode(f.escalated_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range5_low and
               (l_bucket_rec.range5_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range5_high) then
            1 else 0
        end)) escalated_age_b5
  , sum(decode(f.escalated_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range6_low and
               (l_bucket_rec.range6_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range6_high) then
            1 else 0
        end)) escalated_age_b6
  , sum(decode(f.escalated_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range7_low and
               (l_bucket_rec.range7_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range7_high) then
            1 else 0
        end)) escalated_age_b7
  , sum(decode(f.escalated_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range8_low and
               (l_bucket_rec.range8_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range8_high) then
            1 else 0
        end)) escalated_age_b8
  , sum(decode(f.escalated_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range9_low and
               (l_bucket_rec.range9_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range9_high) then
            1 else 0
        end)) escalated_age_b9
  , sum(decode(f.escalated_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range10_low and
               (l_bucket_rec.range10_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range10_high) then
            1 else 0
        end)) escalated_age_b10
  , sum(decode(f.unowned_date,null,null,1)) unowned_count
  , sum(decode(f.unowned_date,null,null, c.report_date-f.incident_date))
    total_unowned_age
  , sum(decode(f.unowned_date,null,null
       ,case
          when (l_bucket_rec.range1_low is null or
                c.report_date-f.incident_date >= l_bucket_rec.range1_low) and
               (l_bucket_rec.range1_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range1_high) then
            1 else 0
        end)) unowned_age_b1
  , sum(decode(f.unowned_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range2_low and
               (l_bucket_rec.range2_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range2_high) then
            1 else 0
        end)) unowned_age_b2
  , sum(decode(f.unowned_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range3_low and
               (l_bucket_rec.range3_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range3_high) then
            1 else 0
        end)) unowned_age_b3
  , sum(decode(f.unowned_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range4_low and
               (l_bucket_rec.range4_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range4_high) then
            1 else 0
        end)) unowned_age_b4
  , sum(decode(f.unowned_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range5_low and
               (l_bucket_rec.range5_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range5_high) then
            1 else 0
        end)) unowned_age_b5
  , sum(decode(f.unowned_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range6_low and
               (l_bucket_rec.range6_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range6_high) then
            1 else 0
        end)) unowned_age_b6
  , sum(decode(f.unowned_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range7_low and
               (l_bucket_rec.range7_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range7_high) then
            1 else 0
        end)) unowned_age_b7
  , sum(decode(f.unowned_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range8_low and
               (l_bucket_rec.range8_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range8_high) then
            1 else 0
        end)) unowned_age_b8
  , sum(decode(f.unowned_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range9_low and
               (l_bucket_rec.range9_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range9_high) then
            1 else 0
        end)) unowned_age_b9
  , sum(decode(f.unowned_date,null,null
       ,case
          when c.report_date-f.incident_date >= l_bucket_rec.range10_low and
               (l_bucket_rec.range10_high is null or
               c.report_date-f.incident_date < l_bucket_rec.range10_high) then
            1 else 0
        end)) unowned_age_b10
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  , f.resolved_flag
  , f.incident_urgency_id
  , f.incident_owner_id
  , f.escalated_flag
  from
    (select /*+ parallel(a) */ distinct(report_date) report_date from biv_dbi_backlog_age_dates a) c
  ,  biv_dbi_backlog_sum_f f
  , eni_oltp_item_star pc
  where
      c.report_date between greatest(f.backlog_date_from, f.incident_date)
                        and f.backlog_date_to+0.99999
  and c.report_date > f.incident_date
  and f.inventory_item_id = pc.inventory_item_id
  and f.inv_organization_id = pc.organization_id
  group by
    c.report_date
  , f.incident_type_id
  , f.incident_severity_id
  , f.customer_id
  , f.owner_group_id
  , f.incident_status_id
  , pc.vbh_category_id
  , nvl(pc.master_id,pc.id)
  , resolved_flag
  , incident_urgency_id
  , incident_owner_id
  , escalated_flag
  ;

  l_rowcount := sql%rowcount;

  bis_collection_utilities.log(l_rowcount || ' rows inserted',2);
  commit;

--
  bis_collection_utilities.log('gathering stats on Backlog Aging table',2);
  if biv_dbi_collection_util.gather_statistics
     ( l_biv_schema
     , 'BIV_BAC_AGE_SUM_F'
     , l_error_message ) <> 0 then
    raise l_exception;
  end if;
--

  bis_collection_utilities.log('inserting group set rows into Backlog Aging table',2);

  insert /*+ APPEND parallel(f) */
  into biv_bac_age_sum_f f
  ( report_date
  , grp_id
  , incident_type_id
  , incident_severity_id
  , vbh_category_id
  , product_id
  , customer_id
  , owner_group_id
  , incident_status_id
  , backlog_count
  , total_backlog_age
  , backlog_age_b1
  , backlog_age_b2
  , backlog_age_b3
  , backlog_age_b4
  , backlog_age_b5
  , backlog_age_b6
  , backlog_age_b7
  , backlog_age_b8
  , backlog_age_b9
  , backlog_age_b10
  , escalated_count
  , total_escalated_age
  , escalated_age_b1
  , escalated_age_b2
  , escalated_age_b3
  , escalated_age_b4
  , escalated_age_b5
  , escalated_age_b6
  , escalated_age_b7
  , escalated_age_b8
  , escalated_age_b9
  , escalated_age_b10
  , unowned_count
  , total_unowned_age
  , unowned_age_b1
  , unowned_age_b2
  , unowned_age_b3
  , unowned_age_b4
  , unowned_age_b5
  , unowned_age_b6
  , unowned_age_b7
  , unowned_age_b8
  , unowned_age_b9
  , unowned_age_b10
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , resolved_flag
  , incident_urgency_id
  , incident_owner_id
  , escalated_flag
  )
  select /*+ parallel(f) */
    report_date
  , decode( grouping_id( product_id
                       , customer_id
                       , owner_group_id
                       , incident_status_id ) , 14, 4 -- Status
                                                , 13, 3 -- Assignment Group
                                                , 11, 2 -- Customer
                                                , 7, 1 -- Prod/Cat
                                                , 0 ) grp_id
  , incident_type_id
  , incident_severity_id
  , vbh_category_id
  , product_id
  , customer_id
  , owner_group_id
  , incident_status_id
  , sum(backlog_count)
  , sum(total_backlog_age)
  , sum(backlog_age_b1)
  , sum(backlog_age_b2)
  , sum(backlog_age_b3)
  , sum(backlog_age_b4)
  , sum(backlog_age_b5)
  , sum(backlog_age_b6)
  , sum(backlog_age_b7)
  , sum(backlog_age_b8)
  , sum(backlog_age_b9)
  , sum(backlog_age_b10)
  , sum(escalated_count)
  , sum(total_escalated_age)
  , sum(escalated_age_b1)
  , sum(escalated_age_b2)
  , sum(escalated_age_b3)
  , sum(escalated_age_b4)
  , sum(escalated_age_b5)
  , sum(escalated_age_b6)
  , sum(escalated_age_b7)
  , sum(escalated_age_b8)
  , sum(escalated_age_b9)
  , sum(escalated_age_b10)
  , sum(unowned_count)
  , sum(total_unowned_age)
  , sum(unowned_age_b1)
  , sum(unowned_age_b2)
  , sum(unowned_age_b3)
  , sum(unowned_age_b4)
  , sum(unowned_age_b5)
  , sum(unowned_age_b6)
  , sum(unowned_age_b7)
  , sum(unowned_age_b8)
  , sum(unowned_age_b9)
  , sum(unowned_age_b10)
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  , resolved_flag
  , incident_urgency_id
  , incident_owner_id
  , escalated_flag
  from
    biv_bac_age_sum_f f
  group by
    report_date
  , incident_type_id
  , incident_severity_id
  , vbh_category_id
  , resolved_flag
  , incident_urgency_id
  , incident_owner_id
  , escalated_flag
  , grouping sets ( (product_id)
                  , (customer_id)
                  , (owner_group_id)
                  , (incident_status_id)
  );
--
  l_rowcount := sql%rowcount;
--
  bis_collection_utilities.log(l_rowcount || ' rows inserted for grouping sets',2);
  commit;
--

  bis_collection_utilities.log('Backlog Age Load Complete');

  commit;

  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_to_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    retcode := '2';

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_to_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := '2';

end load_backlog_aging;

end biv_dbi_collection_age;

/
