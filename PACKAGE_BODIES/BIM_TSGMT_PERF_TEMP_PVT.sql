--------------------------------------------------------
--  DDL for Package Body BIM_TSGMT_PERF_TEMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_TSGMT_PERF_TEMP_PVT" AS
/* $Header: bimvtspb.pls 115.6 2000/08/15 13:01:33 pkm ship      $ */

PROCEDURE populate_temp
         (  p_trgt_sgmt_id                number    DEFAULT NULL,
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_campaign_type               varchar2  DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_type                  varchar2  DEFAULT NULL,
            p_media_id                    number    DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL,
            p_drill_down                  varchar2 default 'N'
         )  IS

v_num_rows_inserted  integer;
v_num_rows_updated   integer;
v_view_by            varchar2(50);
from_clause          varchar2(100);
where_clause         varchar2(250);

type p_measure is table of number
index by binary_integer;


BEGIN


      IF p_campaign_id is not null
      THEN
          from_clause :=  from_clause || ',bim_campaigns_denorm dnm' ;
          where_clause := where_clause || ' and tperf.campaign_id = dnm.campaign_id ' ||
                                          ' and dnm.parent_campaign_id = cmp.campaign_id ' ||
                                          ' and cmp.campaign_id = :p_campaign_id ' ;
      ELSE
          where_clause := where_clause || ' and tperf.campaign_id = cmp.campaign_id '  ||
                                          ' and cmp.campaign_id = nvl(:p_campaign_id, cmp.campaign_id ) ';
      END IF;

      IF p_drill_down = 'Y'
      THEN
          where_clause := where_clause || ' and tgt.parent_target_segment_id = :p_trgt_sgmt_id ' ;
      ELSIF p_trgt_sgmt_id IS NULL
      THEN
          where_clause := where_clause || ' and nvl(tgt.parent_target_segment_id,-999) = nvl(:p_trgt_sgmt_id, -999) ' ;
      ELSE
          where_clause := where_clause || ' and tgt.target_segment_id = :p_trgt_sgmt_id ' ;
      END IF;

      IF p_view_by = 'CMP'
      THEN
            v_view_by := 'cmp.campaign_name' ;
      ELSIF p_view_by = 'MED'
      THEN
            v_view_by := 'med.media_name' ;
      ELSIF p_view_by = 'MCH'
      THEN
            from_clause := from_clause || ',bim_dimv_channels chn' ;
            v_view_by := 'chn.channel_name' ;
            where_clause :=  where_clause || ' and tperf.channel_id = chn.channel_id';
      ELSIF p_view_by = 'SCH'
      THEN
            v_view_by := 'sch.sales_channel_name' ;
            from_clause := from_clause || ',bim_dimv_sales_channels sch' ;
            where_clause :=  where_clause || ' and tperf.sales_channel_code = sch.sales_channel_code';
      ELSIF p_view_by = 'MKT'
      THEN
            v_view_by := 'mkt.market_segment_name' ;
            from_clause := from_clause || ',bim_dimv_market_sgmts mkt' ;
            where_clause :=  where_clause || ' and tperf.market_segment_id = mkt.market_segment_id';
      END IF;

   EXECUTE IMMEDIATE ' INSERT INTO bim_camp_acqu_summ_temp
       ( subject_name,
         view_by_name,
         rank_by,
         measure1,
         measure3,
         measure4  )
       select tgt.target_segment_name,' ||
              v_view_by ||
             ',nvl(sum(tperf.num_of_leads), 0),
               nvl(sum(tperf.num_of_leads), 0),
               nvl(sum(initiated_revenue), 0),
               nvl(sum(num_of_new_accts), 0)
         from bim_trgt_sgmt_perf_summ tperf,
              bim_target_segments_denorm tdnm,
              bim_dimv_target_sgmts  tgt,
              bim_dimv_campaigns cmp,
              bim_dimv_media med ' || from_clause ||
      ' where tperf.target_segment_id = tdnm.target_segment_id
         and tdnm.parent_target_segment_id = tgt.target_segment_id
         and tperf.media_id = med.media_id' ||  where_clause  ||
       ' and tperf.period_start_date  >=  :p_start_date
         and tperf.period_end_date <= :p_end_date
         and cmp.user_status_id = nvl(:p_campaign_status_id, cmp.user_status_id )
         and cmp.campaign_type = nvl(:p_campaign_type, cmp.campaign_type)
         and med.media_type_code = nvl(:p_media_type, med.media_type_code )
         and tperf.media_id = nvl(:p_media_id, tperf.media_id )
         and tperf.channel_id = nvl(:p_channel_id, tperf.channel_id)
         and tperf.sales_channel_code = nvl(:p_sales_channel_code, tperf.sales_channel_code)
         and tperf.market_segment_id =  nvl(:p_market_segment_id, tperf.market_segment_id)
         and tperf.bill_to_geography_code = nvl(:p_geography_code, tperf.bill_to_geography_code )
       group by tgt.target_segment_name, '  || v_view_by
    USING
     p_campaign_id,
     p_trgt_sgmt_id,
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type,
     p_media_type,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_geography_code ;

   v_num_rows_inserted := SQL%ROWCOUNT;
   --  dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );


    EXECUTE IMMEDIATE 'UPDATE bim_camp_acqu_summ_temp tmp
        set tmp.measure2 =
        ( select nvl(sum(tperf.initiated_revenue), 0)
         from bim_customer_rev_summ tperf,
              bim_target_segments_denorm tdnm,
              bim_dimv_target_sgmts  tgt,
              bim_dimv_campaigns cmp,
              bim_dimv_media med ' || from_clause ||
      ' where tperf.target_segment_id = tdnm.target_segment_id
         and tdnm.parent_target_segment_id = tgt.target_segment_id
         and tperf.media_id = med.media_id' ||  where_clause  ||
       ' and tmp.subject_name = tgt.target_segment_name
         and tperf.period_start_date  >=  :p_start_date
         and tperf.period_end_date <= :p_end_date
         and tperf.first_order_date >= :p_start_date
         and tperf.first_order_date <= :p_end_date
         and cmp.user_status_id = nvl(:p_campaign_status_id, cmp.user_status_id )
         and cmp.campaign_type = nvl(:p_campaign_type, cmp.campaign_type)
         and med.media_type_code = nvl(:p_media_type, med.media_type_code )
         and tperf.media_id = nvl(:p_media_id, tperf.media_id )
         and tperf.channel_id = nvl(:p_channel_id, tperf.channel_id)
         and tperf.sales_channel_code = nvl(:p_sales_channel_code, tperf.sales_channel_code)
         and tperf.market_segment_id =  nvl(:p_market_segment_id, tperf.market_segment_id)
         and tperf.bill_to_geography_code = nvl(:p_geography_code, tperf.bill_to_geography_code )
         and tmp.view_by_name = ' || v_view_by || ' ) '
    USING
     p_campaign_id,
     p_trgt_sgmt_id,
     p_start_date,
     p_end_date,
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type,
     p_media_type,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_geography_code ;

  -- changed on 8/14 to fix bug: 1361701
  -- measure4 => % of sales from new customers
  -- measure3 => No of New Accounts
  -- measure2 => Revenue Per Lead
  -- measure1 => No of Leads

  UPDATE bim_camp_acqu_summ_temp SET measure2 = measure2*100/measure3;

  UPDATE bim_camp_acqu_summ_temp SET measure3 = measure3/measure1;


  v_num_rows_updated := SQL%ROWCOUNT;
  --  dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );


END POPULATE_TEMP;


PROCEDURE populate_temp_by_period
         (  p_trgt_sgmt_id                number    DEFAULT NULL,
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_campaign_type               varchar2  DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_type                  varchar2  DEFAULT NULL,
            p_media_id                    number    DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_drill_down                  varchar2 default 'N'
         )  IS

v_num_rows_inserted  integer;
v_num_rows_updated   integer;
from_clause          varchar2(100);
where_clause         varchar2(250);

BEGIN

      IF p_campaign_id is not null
      THEN
          from_clause :=  from_clause || ',bim_campaigns_denorm dnm' ;
          where_clause := where_clause || ' and tperf.campaign_id = dnm.campaign_id ' ||
                                          ' and dnm.parent_campaign_id = cmp.campaign_id ' ||
                                          ' and cmp.campaign_id = :p_campaign_id ' ;
      ELSE
          where_clause := where_clause || ' and tperf.campaign_id = cmp.campaign_id '  ||
                                          ' and cmp.campaign_id = nvl(:p_campaign_id, cmp.campaign_id ) ';
      END IF;

      IF p_drill_down = 'Y'
      THEN
          where_clause := where_clause || ' and tgt.parent_target_segment_id = :p_trgt_sgmt_id ' ;
      ELSIF p_trgt_sgmt_id IS NULL
      THEN
          where_clause := where_clause || ' and nvl(tgt.parent_target_segment_id,-999) = nvl(:p_trgt_sgmt_id, -999) ' ;
      ELSE
          where_clause := where_clause || ' and tgt.target_segment_id = :p_trgt_sgmt_id ' ;
      END IF;

      EXECUTE IMMEDIATE ' INSERT INTO bim_camp_acqu_summ_temp
       ( subject_name,
         view_by_name,
         rank_by,
         measure1,
         measure2,
         measure3  )
       select tgt.target_segment_name,
              per.period_name,
              to_number( to_char(per.start_date, ''J'')),
              nvl(sum(tperf.num_of_leads), 0),
              nvl(sum(initiated_revenue), 0),
              nvl(sum(num_of_new_accts), 0)
          from bim_trgt_sgmt_perf_summ tperf,
              bim_target_segments_denorm tdnm,
              bim_dimv_target_sgmts  tgt,
              bim_dimv_campaigns cmp,
              bim_dimv_media med,
              bim_dimv_periods per ' || from_clause ||
      ' where tperf.target_segment_id = tdnm.target_segment_id
         and tdnm.parent_target_segment_id = tgt.target_segment_id
         and tperf.media_id = med.media_id' ||  where_clause  ||
       ' and tperf.period_start_date >= per.start_date
         and tperf.period_end_date <= per.end_date
         and per.period_type = :p_period_type
         and per.period_set_name = jtf_bis_util.profileValue(''CRMBIS:PERIOD_SET_NAME'')
         and per.start_date >= :p_start_date
         and per.end_date <= :p_end_date
         and cmp.user_status_id = nvl(:p_campaign_status_id, cmp.user_status_id )
         and cmp.campaign_type = nvl(:p_campaign_type, cmp.campaign_type)
         and med.media_type_code = nvl(:p_media_type, med.media_type_code )
         and tperf.media_id = nvl(:p_media_id, tperf.media_id )
         and tperf.channel_id = nvl(:p_channel_id, tperf.channel_id)
         and tperf.sales_channel_code = nvl(:p_sales_channel_code, tperf.sales_channel_code)
         and tperf.market_segment_id =  nvl(:p_market_segment_id, tperf.market_segment_id)
         and tperf.bill_to_geography_code = nvl(:p_geography_code, tperf.bill_to_geography_code )
       group by tgt.target_segment_name, per.period_name, per.start_date'
     USING
      p_campaign_id,
      p_trgt_sgmt_id,
      p_period_type,
      p_start_date,
      p_end_date,
      p_campaign_status_id,
      p_campaign_type,
      p_media_type,
      p_media_id,
      p_channel_id,
      p_sales_channel_code,
      p_market_segment_id,
      p_geography_code;

   v_num_rows_inserted := SQL%ROWCOUNT;
   --  dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );


     EXECUTE IMMEDIATE 'UPDATE bim_camp_acqu_summ_temp tmp
        set tmp.measure4 =
        ( select nvl(sum(tperf.initiated_revenue), 0)
          from bim_customer_rev_summ tperf,
              bim_target_segments_denorm tdnm,
              bim_dimv_target_sgmts  tgt,
              bim_dimv_campaigns cmp,
              bim_dimv_media med,
              bim_dimv_periods per ' || from_clause ||
      ' where tperf.target_segment_id = tdnm.target_segment_id
         and tdnm.parent_target_segment_id = tgt.target_segment_id
         and tperf.media_id = med.media_id' ||  where_clause  ||
       ' and tgt.target_segment_name = tmp.subject_name
         and tperf.period_start_date >= per.start_date
         and tperf.period_end_date <= per.end_date
         and tperf.first_order_date >= per.start_date
         and tperf.first_order_date <= per.end_date
         and per.period_type = :p_period_type
         and per.period_set_name = jtf_bis_util.profileValue(''CRMBIS:PERIOD_SET_NAME'')
         and per.start_date >= :p_start_date
         and per.end_date <= :p_end_date
         and cmp.user_status_id = nvl(:p_campaign_status_id, cmp.user_status_id )
         and cmp.campaign_type = nvl(:p_campaign_type, cmp.campaign_type)
         and med.media_type_code = nvl(:p_media_type, med.media_type_code )
         and tperf.media_id = nvl(:p_media_id, tperf.media_id )
         and tperf.channel_id = nvl(:p_channel_id, tperf.channel_id)
         and tperf.sales_channel_code = nvl(:p_sales_channel_code, tperf.sales_channel_code)
         and tperf.market_segment_id =  nvl(:p_market_segment_id, tperf.market_segment_id)
         and tperf.bill_to_geography_code = nvl(:p_geography_code, tperf.bill_to_geography_code )
         and tmp.view_by_name = per.period_name )'
    USING
      p_campaign_id,
      p_trgt_sgmt_id,
      p_period_type,
      p_start_date,
      p_end_date,
      p_campaign_status_id,
      p_campaign_type,
      p_media_type,
      p_media_id,
      p_channel_id,
      p_sales_channel_code,
      p_market_segment_id,
      p_geography_code;


  v_num_rows_updated := SQL%ROWCOUNT;
  --  dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );


END POPULATE_TEMP_BY_PERIOD;


PROCEDURE populate_temp_table
         (  p_trgt_sgmt_id                number    DEFAULT NULL,
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_campaign_type               varchar2  DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_type                  varchar2  DEFAULT NULL,
            p_media_id                    number    DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL,
            p_drill_down                  varchar2 default 'N'
         )  IS

BEGIN


      IF p_view_by = 'PER'
      THEN
          populate_temp_by_period (
            p_trgt_sgmt_id,
            p_campaign_id,
            p_campaign_status_id,
            p_campaign_type,
            p_period_type,
            p_start_date,
            p_end_date,
            p_media_type,
            p_media_id,
            p_channel_id,
            p_market_segment_id,
            p_sales_channel_code,
            p_geography_code,
            p_drill_down  );
      ELSE
          populate_temp  (
            p_trgt_sgmt_id,
            p_campaign_id,
            p_campaign_status_id,
            p_campaign_type,
            p_period_type,
            p_start_date,
            p_end_date,
            p_media_type,
            p_media_id,
            p_channel_id,
            p_market_segment_id,
            p_sales_channel_code,
            p_geography_code,
            p_view_by,
            p_drill_down );
      END IF;

EXCEPTION
      when others then
           rollback;
           --  dbms_output.put_line ( 'Exception raised ' || sqlcode || ':' || sqlerrm );
           raise;
END populate_temp_table;

END BIM_TSGMT_PERF_TEMP_PVT;

/
