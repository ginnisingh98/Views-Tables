--------------------------------------------------------
--  DDL for Package Body BIM_MEDACQ_IND_TEMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_MEDACQ_IND_TEMP_PVT" AS
/* $Header: bimvmqib.pls 115.3 2000/12/13 20:12:08 pkm ship      $ */

PROCEDURE populate_temp
         (
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
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL
         )  IS

v_num_rows_inserted  integer;
v_num_rows_updated   integer;
v_view_by            varchar2(50);
from_clause          varchar2(100);
where_clause         varchar2(250);


BEGIN

      IF p_campaign_id is not null
      THEN
          from_clause :=  from_clause || ',bim_campaigns_denorm dnm' ;
          where_clause := where_clause || ' and cperf.campaign_id = dnm.campaign_id ' ||
                                          ' and dnm.parent_campaign_id = cmp.campaign_id ' ||
                                          ' and cmp.campaign_id = :p_campaign_id ' ;
      ELSE
          where_clause := where_clause || ' and cperf.campaign_id = cmp.campaign_id '  ||
                                          ' and cmp.campaign_id = nvl(:p_campaign_id, cmp.campaign_id ) ';
      END IF;

      IF p_view_by = 'CMP'
      THEN
            v_view_by := 'cmp.campaign_name' ;
      ELSIF p_view_by = 'MCH'
      THEN
            from_clause := from_clause || ',bim_dimv_channels chn' ;
            v_view_by := 'chn.channel_name' ;
            where_clause :=  where_clause || ' and cperf.channel_id = chn.channel_id';
      ELSIF p_view_by = 'SCH'
      THEN
            v_view_by := 'sch.sales_channel_name' ;
            from_clause := from_clause || ',bim_dimv_sales_channels sch' ;
            where_clause :=  where_clause || ' and cperf.sales_channel_code = sch.sales_channel_code';
      ELSIF p_view_by = 'MKT'
      THEN
            v_view_by := 'mkt.market_segment_name' ;
            from_clause := from_clause || ',bim_dimv_market_sgmts mkt' ;
            where_clause :=  where_clause || ' and cperf.market_segment_id = mkt.market_segment_id';
      END IF;

   EXECUTE IMMEDIATE ' INSERT INTO bim_camp_acqu_summ_temp
       ( subject_name,
         view_by_name,
         rank_by,
         measure1,
         measure3  )
       select med.media_name,' ||
              v_view_by ||
              ', count( distinct cperf.cust_account_id ),
               count( distinct cperf.cust_account_id ),
               nvl(sum(cperf.initiated_revenue), 0 )
         from bim_cmpgn_perf_summ cperf,
              bim_dimv_campaigns cmp,
              bim_dimv_media med ' || from_clause ||
      ' where cperf.media_id = med.media_id' ||  where_clause  ||
       ' and cperf.period_start_date  >=  :p_start_date
         and cperf.period_end_date <= :p_end_date
         and cmp.user_status_id = nvl(:p_campaign_status_id, cmp.user_status_id )
         and cmp.campaign_type = nvl(:p_campaign_type, cmp.campaign_type)
         and med.media_type_code = nvl(:p_media_type, med.media_type_code )
         and cperf.media_id = nvl(:p_media_id, cperf.media_id )
         and cperf.channel_id = nvl(:p_channel_id, cperf.channel_id)
         and cperf.sales_channel_code = nvl(:p_sales_channel_code, cperf.sales_channel_code)
         and cperf.market_segment_id =  nvl(:p_market_segment_id, cperf.market_segment_id)
         and cperf.interest_type_id = nvl(:p_interest_type_id, cperf.interest_type_id )
         and cperf.primary_interest_code_id = nvl(:p_primary_interest_code_id, cperf.primary_interest_code_id)
         and cperf.secondary_interest_code_id = nvl(:p_secondary_interest_code_id, secondary_interest_code_id)
         and cperf.bill_to_geography_code = nvl(:p_geography_code, cperf.bill_to_geography_code )
       group by med.media_name, '  || v_view_by
    USING
     p_campaign_id,
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type,
     p_media_type,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code;

   v_num_rows_inserted := SQL%ROWCOUNT;
   --  dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );


    EXECUTE IMMEDIATE 'UPDATE bim_camp_acqu_summ_temp tmp
        set tmp.measure2 =
        ( select nvl(sum(cperf.initiated_revenue),0)
         from bim_customer_rev_summ cperf,
              bim_dimv_campaigns cmp,
              bim_dimv_media med ' || from_clause ||
      ' where cperf.media_id = med.media_id' ||  where_clause  ||
       ' and med.media_name = tmp.subject_name
         and cperf.period_start_date  >=  :p_start_date
         and cperf.period_end_date <= :p_end_date
         and cperf.first_order_date >= :p_start_date
         and cperf.first_order_date <= :p_end_date
         and cmp.user_status_id = nvl(:p_campaign_status_id, cmp.user_status_id )
         and cmp.campaign_type = nvl(:p_campaign_type, cmp.campaign_type)
         and med.media_type_code = nvl(:p_media_type, med.media_type_code )
         and cperf.media_id = nvl(:p_media_id, cperf.media_id )
         and cperf.channel_id = nvl(:p_channel_id, cperf.channel_id)
         and cperf.sales_channel_code = nvl(:p_sales_channel_code, cperf.sales_channel_code)
         and cperf.market_segment_id =  nvl(:p_market_segment_id, cperf.market_segment_id)
         and cperf.interest_type_id = nvl(:p_interest_type_id, cperf.interest_type_id )
         and cperf.primary_interest_code_id = nvl(:p_primary_interest_code_id, cperf.primary_interest_code_id)
         and cperf.secondary_interest_code_id = nvl(:p_secondary_interest_code_id, secondary_interest_code_id)
         and cperf.bill_to_geography_code = nvl(:p_geography_code, cperf.bill_to_geography_code )
         and tmp.view_by_name = ' || v_view_by || ' ) '
    USING
     p_campaign_id,
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
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code;


  v_num_rows_updated := SQL%ROWCOUNT;
  --  dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );


UPDATE bim_camp_acqu_summ_temp SET measure2 = measure2*100/measure3;

END POPULATE_TEMP;


PROCEDURE populate_temp_by_period
         (
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
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL
         )  IS

v_num_rows_inserted  integer;
v_num_rows_updated   integer;
from_clause          varchar2(100);
where_clause         varchar2(250);

BEGIN

      IF p_campaign_id is not null
      THEN
          from_clause :=  from_clause || ',bim_campaigns_denorm dnm' ;
          where_clause := where_clause || ' and cperf.campaign_id = dnm.campaign_id ' ||
                                          ' and dnm.parent_campaign_id = cmp.campaign_id ' ||
                                          ' and cmp.campaign_id = :p_campaign_id ' ;
      ELSE
          where_clause := where_clause || ' and cperf.campaign_id = cmp.campaign_id '  ||
                                          ' and cmp.campaign_id = nvl(:p_campaign_id, cmp.campaign_id ) ';
      END IF;

      EXECUTE IMMEDIATE ' INSERT INTO bim_camp_acqu_summ_temp
       ( subject_name,
         view_by_name,
         rank_by,
         measure1,
         measure3  )
       select med.media_name,
              per.period_name,
              to_number( to_char(per.start_date, ''J'')),
              count( distinct cperf.cust_account_id ),
              nvl(sum(cperf.initiated_revenue), 0 )
         from bim_cmpgn_perf_summ cperf,
              bim_dimv_campaigns cmp,
              bim_dimv_media med,
              bim_dimv_periods per ' || from_clause ||
      ' where cperf.media_id = med.media_id' ||  where_clause  ||
       ' and cperf.period_start_date >= per.start_date
         and cperf.period_end_date <= per.end_date
         and per.period_type = :p_period_type
         and per.period_set_name = jtf_bis_util.profileValue(''CRMBIS:PERIOD_SET_NAME'')
         and per.start_date >= :p_start_date
         and per.end_date <= :p_end_date
         and cmp.user_status_id = nvl(:p_campaign_status_id, cmp.user_status_id )
         and cmp.campaign_type = nvl(:p_campaign_type, cmp.campaign_type)
         and med.media_type_code = nvl(:p_media_type, med.media_type_code )
         and cperf.media_id = nvl(:p_media_id, cperf.media_id )
         and cperf.channel_id = nvl(:p_channel_id, cperf.channel_id)
         and cperf.sales_channel_code = nvl(:p_sales_channel_code, cperf.sales_channel_code)
         and cperf.market_segment_id =  nvl(:p_market_segment_id, cperf.market_segment_id)
         and cperf.interest_type_id = nvl(:p_interest_type_id, cperf.interest_type_id )
         and cperf.primary_interest_code_id = nvl(:p_primary_interest_code_id, cperf.primary_interest_code_id)
         and cperf.secondary_interest_code_id = nvl(:p_secondary_interest_code_id, secondary_interest_code_id)
         and cperf.bill_to_geography_code = nvl(:p_geography_code, cperf.bill_to_geography_code )
       group by med.media_name, per.period_name, per.start_date'
     USING
      p_campaign_id,
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
      p_interest_type_id,
      p_primary_interest_code_id,
      p_secondary_interest_code_id,
      p_geography_code;

   v_num_rows_inserted := SQL%ROWCOUNT;
   --  dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );


     EXECUTE IMMEDIATE 'UPDATE bim_camp_acqu_summ_temp tmp
        set tmp.measure2 =
        ( select nvl(sum(cperf.initiated_revenue),0)
          from bim_customer_rev_summ cperf,
             bim_dimv_campaigns cmp,
             bim_dimv_media med,
             bim_dimv_periods per ' || from_clause ||
      ' where cperf.media_id = med.media_id' ||  where_clause  ||
       ' and med.media_name = tmp.subject_name
         and cperf.period_start_date >= per.start_date
         and cperf.period_end_date <= per.end_date
         and cperf.first_order_date >= per.start_date
         and cperf.first_order_date <= per.end_date
         and per.period_type = :p_period_type
         and per.period_set_name = jtf_bis_util.profileValue(''CRMBIS:PERIOD_SET_NAME'')
         and per.start_date >= :p_start_date
         and per.end_date <= :p_end_date
         and cmp.user_status_id = nvl(:p_campaign_status_id, cmp.user_status_id )
         and cmp.campaign_type = nvl(:p_campaign_type, cmp.campaign_type)
         and med.media_type_code = nvl(:p_media_type, med.media_type_code )
         and cperf.media_id = nvl(:p_media_id, cperf.media_id )
         and cperf.channel_id = nvl(:p_channel_id, cperf.channel_id)
         and cperf.sales_channel_code = nvl(:p_sales_channel_code, cperf.sales_channel_code)
         and cperf.market_segment_id =  nvl(:p_market_segment_id, cperf.market_segment_id)
         and cperf.interest_type_id = nvl(:p_interest_type_id, cperf.interest_type_id )
         and cperf.primary_interest_code_id = nvl(:p_primary_interest_code_id, cperf.primary_interest_code_id)
         and cperf.secondary_interest_code_id = nvl(:p_secondary_interest_code_id, secondary_interest_code_id)
         and cperf.bill_to_geography_code = nvl(:p_geography_code, cperf.bill_to_geography_code )
         and tmp.view_by_name = per.period_name )'
    USING
      p_campaign_id,
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
      p_interest_type_id,
      p_primary_interest_code_id,
      p_secondary_interest_code_id,
      p_geography_code ;


  v_num_rows_updated := SQL%ROWCOUNT;
  --  dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );


END POPULATE_TEMP_BY_PERIOD;


PROCEDURE populate_temp_table
         (
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
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL
         )  IS

BEGIN


      IF p_view_by = 'PER'
      THEN
          populate_temp_by_period (
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
            p_interest_type_id,
            p_primary_interest_code_id,
            p_secondary_interest_code_id,
            p_geography_code  );
      ELSE
          populate_temp  (
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
            p_interest_type_id,
            p_primary_interest_code_id,
            p_secondary_interest_code_id,
            p_geography_code,
            p_view_by );
      END IF;

EXCEPTION
      when others then
           rollback;
           --  dbms_output.put_line ( 'Exception raised ' || sqlcode || ':' || sqlerrm );
           raise;
END populate_temp_table;

END BIM_MEDACQ_IND_TEMP_PVT;

/
