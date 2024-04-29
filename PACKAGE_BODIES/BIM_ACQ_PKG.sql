--------------------------------------------------------
--  DDL for Package Body BIM_ACQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_ACQ_PKG" AS
/*$Header: bimacqub.pls 115.18 2001/08/13 16:09:47 pkm ship        $*/

PROCEDURE BIM_CMP_ACQ_POPULATE
         (
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_type_id            varchar2  DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_id                    number    DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL,
            p_drill_down                  varchar2  DEFAULT 'Y'
         )  IS


v_num_rows_inserted  integer;
v_num_rows_updated   integer;
v_view_by            varchar2(50);
from_clause          varchar2(100);
where_clause         varchar2(250);

l_sql_from		varchar2(5000);
l_sql_where	      varchar2(5000);
l_sql_group_by    varchar2(5000);
l_sql_order_by	varchar2(5000);
l_sql_insert_stm 	varchar2(5000);
l_sql_stmt		varchar2(5000);
v_all_name        varchar2(80);

l_sql_update_stm 	varchar2(5000);
l_sql_upd_stmt	varchar2(5000);

BEGIN

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure3, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' count(distinct a.cust_account_id) , ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' nvl(sum(a.initiated_revenue), 0 ) , ';

/***************/

l_sql_where  :=  l_sql_where || ' where a.period_start_date  >=  :p_start_date and a.period_end_date <= :p_end_date ' ;

/***************/

IF 	p_campaign_status_id IS NULL THEN
	l_sql_where:= l_sql_where ||' and :p_campaign_status_id IS NULL ' ;
ELSE
	l_sql_where:= l_sql_where || ' and parent_campaign_status_id = :p_campaign_status_id ';
END IF;

IF 	p_campaign_type_id IS NULL THEN
	l_sql_where:= l_sql_where || ' and :p_campaign_type_id  IS NULL ';
ELSE
	l_sql_where:= l_sql_where || ' and parent_campaign_type = :p_campaign_type_id ';
END IF;

IF p_campaign_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and b.parent_campaign_id in (select campaign_id from bim_dimv_campaigns where parent_campaign_id is null  and :p_campaign_id is null ) ';
ELSE
	l_sql_where:= l_sql_where|| ' and b.parent_campaign_id in (select campaign_id from bim_dimv_campaigns where parent_campaign_id = :p_campaign_id ) ';
END IF;


/***************/

IF 	p_media_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_media_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.media_id = :p_media_id';
END IF;

/***************/

IF 	p_channel_id IS  NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_channel_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and  a.channel_id = :p_channel_id';
END IF;

/***************/

IF 	p_sales_channel_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_sales_channel_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.sales_channel_code = :p_sales_channel_code';
END IF;

/***************/

IF 	p_market_segment_id IS NULL
THEN
	l_sql_where:= l_sql_where|| ' and :p_market_segment_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.market_segment_id   = :p_market_segment_id';
END IF;

/***************/

IF 	p_interest_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_interest_type_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.interest_type_id = :p_interest_type_id ';
END IF;

IF 	p_primary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_primary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.primary_interest_code_id = :p_primary_interest_code_id ';
END IF;

IF 	p_secondary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_secondary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where||' and a.secondary_interest_code_id = :p_secondary_interest_code_id ';
END IF;

/***************/

IF 	p_geography_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_geography_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and bill_to_geography_code like :p_geography_code';
END IF;

/***************/

IF 	p_view_by = 'ACT'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' d.campaign_name , med.media_name ';
	l_sql_from	 	:= l_sql_from || ' from bim_cmpgn_perf_summ a ,bim_campaigns_denorm b ,bim_dimv_campaigns d ,bim_dimv_media med ' ;
	l_sql_where 	:= l_sql_where || '  and a.campaign_id = b.campaign_id and b.parent_campaign_id =d.campaign_id and a.media_id = med.media_id ';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  d.campaign_name , med.media_name ';
	l_sql_order_by := ' Order by 1,3 desc';
      v_view_by 		:= ' med.media_name ' ;
	from_clause 	:= ' ,bim_dimv_media med ' ;
ELSIF p_view_by = 'MCH'
THEN
	l_sql_insert_stm  := l_sql_insert_stm || ' d.campaign_name , chn.channel_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a, bim_campaigns_denorm b,bim_dimv_campaigns d,bim_dimv_channels chn ' ;
	l_sql_where 	:= l_sql_where || ' and a.campaign_id = b.campaign_id and b.parent_campaign_id =d.campaign_id and a.channel_id = chn.channel_id ';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  d.campaign_name , chn.channel_name ';
	l_sql_order_by := ' Order by 1,3 desc';
      v_view_by 		:= ' chn.channel_name' ;
	from_clause 	:= ' ,bim_dimv_channels chn ' ;
ELSIF p_view_by = 'SCH'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' d.campaign_name , sch.sales_channel_name ';
	l_sql_from	 	:= l_sql_from || 	' from bim_cmpgn_perf_summ a,bim_campaigns_denorm b,bim_dimv_campaigns d,bim_dimv_sales_channels sch ' ;
	l_sql_where 	:= l_sql_where || ' and a.campaign_id = b.campaign_id and b.parent_campaign_id =d.campaign_id and a.sales_channel_code = sch.sales_channel_code ';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY   d.campaign_name , sch.sales_channel_name ';
	l_sql_order_by := ' Order by 1,3 desc';
      v_view_by 		:= ' sch.sales_channel_name' ;
	from_clause 	:= ' ,bim_dimv_sales_channels sch ' ;
ELSIF p_view_by = 'MSG'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' d.campaign_name , mkt.market_segment_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a,bim_campaigns_denorm b,bim_dimv_campaigns d,bim_dimv_market_sgmts mkt ' ;
	l_sql_where 	:= l_sql_where || ' and a.campaign_id = b.campaign_id and b.parent_campaign_id =d.campaign_id and a.market_segment_id = mkt.market_segment_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  d.campaign_name , mkt.market_segment_name ';
	l_sql_order_by := ' Order by 1,3 desc';
      v_view_by 		:= ' mkt.market_segment_name' ;
	from_clause 	:= ' ,bim_dimv_market_sgmts mkt ' ;
ELSIF p_view_by = 'PER' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' d.campaign_name, per.period_name ';
	l_sql_from:= l_sql_from|| ' from  bim_cmpgn_perf_summ a, bim_campaigns_denorm b,bim_dimv_campaigns d ,bim_dimv_periods per,dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and b.parent_campaign_id =d.campaign_id and a.period_start_date >= per.start_date
and  a.period_end_date <= per.end_date and per.period_set_name = jtf_bis_util.ProfileValue(''CRMBIS:PERIOD_SET_NAME'') and  per.period_type = :p_period_type ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY d.campaign_name, per.period_name , per.start_date ';
	l_sql_order_by := ' Order by d.campaign_name,per.start_date ';
      v_view_by 		:= ' per.period_name' ;
	from_clause 	:= ' ,bim_dimv_periods per ' ;
END IF;

-- dbms_output.put_line(p_period_type);

/***************/

l_sql_stmt := l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by;

/*
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 600, 150));
*/

/*

declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp1.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_insert_stm);
		utl_file.put_line(fp,l_sql_from);
		utl_file.put_line(fp,l_sql_where);
		utl_file.put_line(fp,l_sql_group_by);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;

*/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code;

END IF;

   v_num_rows_inserted := SQL%ROWCOUNT;
     -- dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );

/************************************************************************************************************/

l_sql_update_stm := 'UPDATE bim_camp_acqu_summ_temp tmp
set tmp.measure4 = (select nvl(sum(a.initiated_revenue),0)
from bim_customer_rev_summ a, bim_campaigns_denorm b, bim_dimv_campaigns d ' ;

l_sql_where := l_sql_where || ' and a.first_order_date >= :p_start_date and a.first_order_date <= :p_end_date ';

l_sql_where := l_sql_where || ' and tmp.subject_name = d.campaign_name and tmp.view_by_name = ' || v_view_by || ' ) ' ;

l_sql_upd_stmt := l_sql_update_stm || from_clause || l_sql_where ;

/*
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 301, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 601, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 751, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_group_by, 1, 150));
*/

/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp21.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_upd_stmt);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;
*/

/******************/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type,
     p_start_date,
     p_end_date;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,

     p_geography_code,
     p_start_date,
     p_end_date;
END IF;

/******************/

  UPDATE bim_camp_acqu_summ_temp SET measure2 = measure4*100/measure3;

  v_num_rows_updated := SQL%ROWCOUNT;
    -- dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );

END BIM_CMP_ACQ_POPULATE ;

/*****************************************************************************************************/

PROCEDURE BIM_CMP_ACQ_SUM_POPULATE
         (
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_type_id            varchar2  DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_id                    number    DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL,
            p_drill_down                  varchar2  DEFAULT 'Y',
		p_all_value				varchar2  DEFAULT 'ALL'
         )  IS


v_num_rows_inserted  integer;
v_num_rows_updated   integer;
v_view_by            varchar2(50);
from_clause          varchar2(100);
where_clause         varchar2(250);

l_sql_from		varchar2(5000);
l_sql_where	      varchar2(5000);
l_sql_group_by    varchar2(5000);
l_sql_order_by	varchar2(5000);
l_sql_insert_stm 	varchar2(5000);
l_sql_stmt		varchar2(5000);
v_all_name        varchar2(80);

l_sql_update_stm 	varchar2(5000);
l_sql_upd_stmt	varchar2(5000);

BEGIN

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure3, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' count(distinct a.cust_account_id) , ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' nvl(sum(a.initiated_revenue), 0 ) , ';

/***************/

l_sql_where  :=  l_sql_where || ' where  a.period_start_date  >=  :p_start_date and a.period_end_date <= :p_end_date ' ;

/***************/

IF 	p_campaign_status_id IS NULL THEN
	l_sql_where:= l_sql_where ||' and :p_campaign_status_id IS NULL ' ;
ELSE
	l_sql_where:= l_sql_where || ' and parent_campaign_status_id = :p_campaign_status_id ';
END IF;

IF 	p_campaign_type_id IS NULL THEN
	l_sql_where:= l_sql_where || ' and :p_campaign_type_id  IS NULL ';
ELSE
	l_sql_where:= l_sql_where || ' and parent_campaign_type = :p_campaign_type_id ';
END IF;

/***************/

IF 	p_media_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_media_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.media_id = :p_media_id';
END IF;

/***************/

IF 	p_channel_id IS  NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_channel_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and  a.channel_id = :p_channel_id';
END IF;

/***************/

IF 	p_sales_channel_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_sales_channel_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.sales_channel_code = :p_sales_channel_code';
END IF;

/***************/

IF 	p_market_segment_id IS NULL
THEN
	l_sql_where:= l_sql_where|| ' and :p_market_segment_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.market_segment_id   = :p_market_segment_id';
END IF;

/***************/

IF 	p_interest_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_interest_type_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.interest_type_id = :p_interest_type_id ';
END IF;

IF 	p_primary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_primary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.primary_interest_code_id = :p_primary_interest_code_id ';
END IF;

IF 	p_secondary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_secondary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where||' and a.secondary_interest_code_id = :p_secondary_interest_code_id ';
END IF;

/***************/

IF 	p_geography_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_geography_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and bill_to_geography_code like :p_geography_code';
END IF;

/***************/

IF 	p_view_by = 'ACT'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' :p_all_value , med.media_name ';
	l_sql_from	 	:= l_sql_from ||   ' from bim_cmpgn_perf_summ a ,bim_campaigns_denorm b ,bim_dimv_media med ' ;
	l_sql_where 	:= l_sql_where ||  ' and a.campaign_id = b.campaign_id and b.level_from_parent = 0 and a.media_id = med.media_id ';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value , med.media_name ';
	l_sql_order_by := ' Order by 1,3 desc';
      v_view_by 		:= ' med.media_name ' ;
	from_clause 	:= ' ,bim_dimv_media med ' ;
ELSIF p_view_by = 'MCH'
THEN
	l_sql_insert_stm  := l_sql_insert_stm || ' :p_all_value , chn.channel_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a, bim_campaigns_denorm b, bim_dimv_channels chn ' ;
	l_sql_where 	:= l_sql_where || ' and a.campaign_id = b.campaign_id and b.level_from_parent = 0 and a.channel_id = chn.channel_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value , chn.channel_name ';
	l_sql_order_by := ' Order by 1,3 desc';
      v_view_by 		:= ' chn.channel_name' ;
	from_clause 	:= ' ,bim_dimv_channels chn ' ;
ELSIF p_view_by = 'SCH'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' :p_all_value , sch.sales_channel_name ';
	l_sql_from	 	:= l_sql_from || 	' from bim_cmpgn_perf_summ a,bim_campaigns_denorm b ,bim_dimv_sales_channels sch ' ;
	l_sql_where 	:= l_sql_where || ' and a.campaign_id = b.campaign_id and b.level_from_parent = 0 and a.sales_channel_code = sch.sales_channel_code';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY   :p_all_value , sch.sales_channel_name ';
	l_sql_order_by := ' Order by 1,3 desc';
      v_view_by 		:= ' sch.sales_channel_name' ;
	from_clause 	:= ' ,bim_dimv_sales_channels sch ' ;
ELSIF p_view_by = 'MSG'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' :p_all_value , mkt.market_segment_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a,bim_campaigns_denorm b ,bim_dimv_market_sgmts mkt ' ;
	l_sql_where 	:= l_sql_where || ' and a.campaign_id = b.campaign_id and b.level_from_parent = 0 and a.market_segment_id = mkt.market_segment_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value , mkt.market_segment_name ';
	l_sql_order_by := ' Order by 1,3 desc';
      v_view_by 		:= ' mkt.market_segment_name' ;
	from_clause 	:= ' ,bim_dimv_market_sgmts mkt ' ;
ELSIF p_view_by = 'PER' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' :p_all_value , per.period_name ';
	l_sql_from:= l_sql_from|| ' from  bim_cmpgn_perf_summ a, bim_campaigns_denorm b,bim_dimv_periods per,dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and b.level_from_parent = 0 and a.period_start_date >= per.start_date and
a.period_end_date <= per.end_date and per.period_set_name = jtf_bis_util.ProfileValue(''CRMBIS:PERIOD_SET_NAME'') and  per.period_type = :p_period_type  ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY :p_all_value , per.period_name , per.start_date ';
	l_sql_order_by := ' Order by :p_all_value, per.start_date ';
      v_view_by 		:= ' per.period_name' ;
	from_clause 	:= ' ,bim_dimv_periods per ' ;
END IF;


-- dbms_output.put_line(p_period_type);

/***************/

l_sql_stmt := l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by;

/**************/
/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp1.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_insert_stm);
		utl_file.put_line(fp,l_sql_from);
		utl_file.put_line(fp,l_sql_where);
		utl_file.put_line(fp,l_sql_group_by);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;
*/

/******************/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_all_value,
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type,
     p_all_value,
     p_all_value;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_all_value,
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_all_value;

END IF;

   v_num_rows_inserted := SQL%ROWCOUNT;
     -- dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );

/************************************************************************************************************/

l_sql_update_stm := 'UPDATE bim_camp_acqu_summ_temp tmp set tmp.measure4 = (select nvl(sum(a.initiated_revenue),0) from bim_customer_rev_summ a, bim_campaigns_denorm b ' ;

l_sql_where := l_sql_where || ' and a.first_order_date >= :p_start_date and a.first_order_date <= :p_end_date ';

l_sql_where := l_sql_where || ' and tmp.view_by_name = ' || v_view_by || ' ) ' ;

l_sql_upd_stmt := l_sql_update_stm || from_clause || l_sql_where ;


-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));

/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp2.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_upd_stmt);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;

*/

/******************/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type,
     p_start_date,
     p_end_date;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_start_date,
     p_end_date;
END IF;

/******************/

UPDATE bim_camp_acqu_summ_temp SET measure2 = measure4*100/measure3;


  v_num_rows_updated := SQL%ROWCOUNT;
    -- dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );

END BIM_CMP_ACQ_SUM_POPULATE ;

/**************************************************************************************************/

 PROCEDURE BIM_ACT_ACQ_SUM_POPULATE
         (
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_type_id            varchar2  DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_id                    number    DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL,
            p_drill_down                  varchar2  DEFAULT 'Y',
		p_all_value				varchar2  DEFAULT 'ALL'
         )  IS


v_num_rows_inserted  integer;
v_num_rows_updated   integer;
v_view_by            varchar2(50);
from_clause          varchar2(100);
where_clause         varchar2(250);

l_sql_from		varchar2(5000);
l_sql_where	      varchar2(5000);
l_sql_group_by    varchar2(5000);
l_sql_order_by	varchar2(5000);
l_sql_insert_stm 	varchar2(5000);
l_sql_stmt		varchar2(5000);
v_all_name        varchar2(80);

l_sql_update_stm 	varchar2(5000);
l_sql_upd_stmt	varchar2(5000);

BEGIN

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure3, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' count(distinct a.cust_account_id) , ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' nvl(sum(a.initiated_revenue), 0 ) , ';

/***************/

l_sql_where  :=  l_sql_where || ' where  a.period_start_date  >=  :p_start_date and a.period_end_date <= :p_end_date ' ;

/***************/

IF 	p_campaign_status_id IS NULL THEN
	l_sql_where:= l_sql_where ||' and :p_campaign_status_id IS NULL ' ;
ELSE
	l_sql_where:= l_sql_where || ' and parent_campaign_status_id = :p_campaign_status_id ';
END IF;

IF 	p_campaign_type_id IS NULL THEN
	l_sql_where:= l_sql_where || ' and :p_campaign_type_id  IS NULL ';
ELSE
	l_sql_where:= l_sql_where || ' and parent_campaign_type_id = :p_campaign_type_id ';
END IF;

/***************/

IF 	p_channel_id IS  NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_channel_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and  a.channel_id = :p_channel_id';
END IF;

/***************/

IF 	p_sales_channel_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_sales_channel_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.sales_channel_code = :p_sales_channel_code';
END IF;

/***************/

IF 	p_market_segment_id IS NULL
THEN
	l_sql_where:= l_sql_where|| ' and :p_market_segment_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.market_segment_id   = :p_market_segment_id';
END IF;

/***************/

IF 	p_interest_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_interest_type_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.interest_type_id = :p_interest_type_id ';
END IF;

IF 	p_primary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_primary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.primary_interest_code_id = :p_primary_interest_code_id ';
END IF;

IF 	p_secondary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_secondary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where||' and a.secondary_interest_code_id = :p_secondary_interest_code_id ';
END IF;

/***************/

IF 	p_geography_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_geography_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and bill_to_geography_code like :p_geography_code';
END IF;

/***************/

IF 	p_view_by = 'CMP'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' :p_all_value , cmp.campaign_name ';
	l_sql_from	 	:= l_sql_from ||   ' from bim_cmpgn_perf_summ a , bim_dimv_campaigns cmp ' ;
	l_sql_where 	:= l_sql_where ||  ' and a.campaign_id = cmp.campaign_id  ';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value , cmp.campaign_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= 'cmp.campaign_name ' ;
	from_clause 	:= ' ,bim_dimv_campaigns cmp ' ;
ELSIF p_view_by = 'MCH'
THEN
	l_sql_insert_stm  := l_sql_insert_stm || ' :p_all_value , chn.channel_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a, bim_dimv_channels chn ' ;
	l_sql_where 	:= l_sql_where || ' and a.channel_id = chn.channel_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value , chn.channel_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' chn.channel_name' ;
	from_clause 	:= ' ,bim_dimv_channels chn ' ;
ELSIF p_view_by = 'SCH'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' :p_all_value , sch.sales_channel_name ';
	l_sql_from	 	:= l_sql_from || 	' from bim_cmpgn_perf_summ a ,bim_dimv_sales_channels sch ' ;
	l_sql_where 	:= l_sql_where || ' and a.sales_channel_code = sch.sales_channel_code';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY   :p_all_value , sch.sales_channel_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' sch.sales_channel_name' ;
	from_clause 	:= ' ,bim_dimv_sales_channels sch ' ;
ELSIF p_view_by = 'MSG'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' :p_all_value , mkt.market_segment_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a  ,bim_dimv_market_sgmts mkt ' ;
	l_sql_where 	:= l_sql_where || ' and a.market_segment_id = mkt.market_segment_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value , mkt.market_segment_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' mkt.market_segment_name' ;
	from_clause 	:= ' ,bim_dimv_market_sgmts mkt ' ;
ELSIF p_view_by = 'PER' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' :p_all_value , per.period_name ';
	l_sql_from:= l_sql_from|| ' from  bim_cmpgn_perf_summ a ,bim_dimv_periods per,dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.period_start_date >= per.start_date and  a.period_end_date <= per.end_date and per.period_set_name = jtf_bis_util.ProfileValue(''CRMBIS:PERIOD_SET_NAME'') and  per.period_type = :p_period_type  ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY :p_all_value , per.period_name , per.start_date ';
	l_sql_order_by 	:= ' Order by :p_all_value, per.start_date ';
      v_view_by 		:= ' per.period_name' ;
	from_clause 	:= ' ,bim_dimv_periods per ' ;
END IF;


-- dbms_output.put_line(p_period_type);

/***************/

l_sql_stmt := l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by;

/**************/

/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log';
file_name	varchar2(50) := 'bpp1.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_insert_stm);
		utl_file.put_line(fp,l_sql_from);
		utl_file.put_line(fp,l_sql_where);
		utl_file.put_line(fp,l_sql_group_by);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;

*/

/******************/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_all_value,
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type,
     p_all_value,
     p_all_value;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_all_value,
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_all_value;

END IF;

   v_num_rows_inserted := SQL%ROWCOUNT;
     -- dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );

/*****************************************************************************************/

l_sql_update_stm := 'UPDATE bim_camp_acqu_summ_temp tmp set tmp.measure4 = (select nvl(sum(a.initiated_revenue),0) from bim_customer_rev_summ a ' ;

l_sql_where := l_sql_where || ' and a.first_order_date >= :p_start_date and a.first_order_date <= :p_end_date ';

l_sql_where := l_sql_where || 'and tmp.view_by_name = ' || v_view_by || ' ) ' ;

l_sql_upd_stmt := l_sql_update_stm || from_clause || l_sql_where ;


-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));

/*

declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp2.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_upd_stmt);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;

*/

/******************/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type,
     p_start_date,
     p_end_date;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_start_date,
     p_end_date;
END IF;

/******************/
UPDATE bim_camp_acqu_summ_temp SET measure2 = measure4*100/measure3;

  v_num_rows_updated := SQL%ROWCOUNT;
    -- dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );

END BIM_ACT_ACQ_SUM_POPULATE ;

/****************************************************************************************************/

PROCEDURE BIM_ACT_ACQ_POPULATE
         (
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_type_id            varchar2  DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_id                    number    DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL,
            p_drill_down                  varchar2  DEFAULT 'Y'
         )  IS

v_num_rows_inserted  integer;
v_num_rows_updated   integer;
v_view_by            varchar2(50);
from_clause          varchar2(100);
where_clause         varchar2(250);

l_sql_from		varchar2(5000);
l_sql_where	      varchar2(5000);
l_sql_group_by    varchar2(5000);
l_sql_order_by	varchar2(5000);
l_sql_insert_stm 	varchar2(5000);
l_sql_stmt		varchar2(5000);
v_all_name        varchar2(80);

l_sql_update_stm 	varchar2(5000);
l_sql_upd_stmt	varchar2(5000);


BEGIN


l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure3, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' count(distinct a.cust_account_id) , ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' nvl(sum(a.initiated_revenue), 0 ) , ';

/***************/

l_sql_where:= ' where  a.period_start_date   >= :p_start_date and a.period_end_date <= :p_end_date';

/***************/

l_sql_where:= l_sql_where|| ' and a.campaign_id in (select parent_campaign_id from bim_campaigns_denorm';

IF 	p_campaign_status_id IS NULL THEN
	l_sql_where:= l_sql_where||' where :p_campaign_status_id IS NULL' ;
ELSE
	l_sql_where:= l_sql_where|| ' where parent_campaign_status_id = :p_campaign_status_id';
END IF;

IF 	p_campaign_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_campaign_type_id  IS NULL';
ELSE
	l_sql_where:= l_sql_where|| ' and parent_campaign_type = :p_campaign_type_id';
END IF;

IF 	p_campaign_id  IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_campaign_id   IS NULL ) ';
ELSE
	l_sql_where:= l_sql_where|| ' and parent_campaign_id = :p_campaign_id ) ';
END IF;


/***************/

IF 	p_media_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_media_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.media_id = :p_media_id';
END IF;

/***************/

IF 	p_channel_id IS  NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_channel_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and  a.channel_id = :p_channel_id';
END IF;

/***************/

IF 	p_sales_channel_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_sales_channel_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.sales_channel_code = :p_sales_channel_code';
END IF;

/***************/

IF 	p_market_segment_id IS NULL
THEN
	l_sql_where:= l_sql_where|| ' and :p_market_segment_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.market_segment_id   = :p_market_segment_id';
END IF;

/***************/

IF 	p_interest_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_interest_type_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.interest_type_id = :p_interest_type_id ';
END IF;

IF 	p_primary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_primary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.primary_interest_code_id = :p_primary_interest_code_id ';
END IF;

IF 	p_secondary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_secondary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where||' and a.secondary_interest_code_id = :p_secondary_interest_code_id ';
END IF;

/***************/

IF 	p_geography_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_geography_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and bill_to_geography_code like :p_geography_code';
END IF;


/***************/

IF 	p_view_by = 'CMP'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' med.media_name , cmp.campaign_name ';
	l_sql_from	 	:= l_sql_from ||   ' from bim_cmpgn_perf_summ a , bim_dimv_media med ,bim_dimv_campaigns cmp' ;
	l_sql_where 	:= l_sql_where ||  ' and a.media_id = med.media_id and a.campaign_id = cmp.campaign_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  med.media_name , cmp.campaign_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' cmp.campaign_name ' ;
	from_clause 	:= ' ,bim_dimv_campaigns cmp ' ;
ELSIF p_view_by = 'MCH'
THEN
	l_sql_insert_stm  := l_sql_insert_stm || ' med.media_name , chn.channel_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a,  bim_dimv_channels chn ,bim_dimv_media med ' ;
	l_sql_where 	:= l_sql_where || ' and a.channel_id = chn.channel_id and a.media_id = med.media_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  med.media_name , chn.channel_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' chn.channel_name' ;
	from_clause 	:= ' ,bim_dimv_channels chn ' ;
ELSIF p_view_by = 'SCH'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' med.media_name , sch.sales_channel_name ';
	l_sql_from	 	:= l_sql_from || 	' from bim_cmpgn_perf_summ a,  bim_dimv_sales_channels sch ,bim_dimv_media med ' ;
	l_sql_where 	:= l_sql_where || ' and a.sales_channel_code = sch.sales_channel_code and a.media_id = med.media_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY   med.media_name , sch.sales_channel_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' sch.sales_channel_name' ;
	from_clause 	:= ' ,bim_dimv_sales_channels sch ' ;
ELSIF p_view_by = 'MSG'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' med.media_name , mkt.market_segment_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a, bim_dimv_market_sgmts mkt ,bim_dimv_media med ' ;
	l_sql_where 	:= l_sql_where || ' and a.market_segment_id = mkt.market_segment_id and a.media_id = med.media_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  med.media_name , mkt.market_segment_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' mkt.market_segment_name' ;
	from_clause 	:= ' ,bim_dimv_market_sgmts mkt ' ;
ELSIF p_view_by = 'PER' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' med.media_name , per.period_name ';
	l_sql_from:= l_sql_from|| ' from  bim_cmpgn_perf_summ a, bim_dimv_media med, bim_dimv_periods per,dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.media_id = med.media_id and a.period_start_date >= per.start_date and  a.period_end_date <= per.end_date
and per.period_set_name = jtf_bis_util.ProfileValue(''CRMBIS:PERIOD_SET_NAME'') and  per.period_type = :p_period_type  ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY med.media_name , per.period_name , per.start_date ';
	l_sql_order_by 	:= ' Order by med.media_name, per.start_date ';
      v_view_by 		:= ' per.period_name' ;
	from_clause 	:= ' ,bim_dimv_periods per ' ;
END IF;

/***************/

l_sql_stmt := l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by;

/**************/

/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp1.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_insert_stm);
		utl_file.put_line(fp,l_sql_from);
		utl_file.put_line(fp,l_sql_where);
		utl_file.put_line(fp,l_sql_group_by);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;
*/

/******************/

IF (p_view_by = 'PER') THEN

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type;
ELSE
EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code;

END IF;

   v_num_rows_inserted := SQL%ROWCOUNT;
     -- dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );

/************************************************************************************************************/

l_sql_update_stm := 'UPDATE bim_camp_acqu_summ_temp tmp set tmp.measure4 = (select nvl(sum(a.initiated_revenue),0) from bim_customer_rev_summ a, bim_dimv_media med ' ;

l_sql_where := l_sql_where || ' and a.first_order_date >= :p_start_date and a.first_order_date <= :p_end_date ';

l_sql_where := l_sql_where || ' and tmp.subject_name = med.media_name and tmp.view_by_name = ' || v_view_by || ' ) ' ;

l_sql_upd_stmt := l_sql_update_stm || from_clause || l_sql_where ;

/*
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
*/

/******************/

/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp21.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_upd_stmt);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;
*/


/******************/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type,
     p_start_date,
     p_end_date;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_start_date,
     p_end_date;
END IF;


/******************/

UPDATE bim_camp_acqu_summ_temp SET measure2 = measure4*100/measure3;

v_num_rows_updated := SQL%ROWCOUNT;
    -- dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );


END BIM_ACT_ACQ_POPULATE  ;


/***********************************************************************************************/


 PROCEDURE BIM_MCH_ACQ_SUM_POPULATE
         (
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_campaign_type_id            varchar2  DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_id                    number    DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL,
            p_drill_down                  varchar2  DEFAULT 'Y',
		p_all_value				varchar2  DEFAULT 'ALL'
         )  IS


v_num_rows_inserted  integer;
v_num_rows_updated   integer;
v_view_by            varchar2(50);
from_clause          varchar2(100);
where_clause         varchar2(250);

l_sql_from		varchar2(5000);
l_sql_where	      varchar2(5000);
l_sql_group_by    varchar2(5000);
l_sql_order_by	varchar2(5000);
l_sql_insert_stm 	varchar2(5000);
l_sql_stmt		varchar2(5000);
v_all_name        varchar2(80);

l_sql_update_stm 	varchar2(5000);
l_sql_upd_stmt	varchar2(5000);

BEGIN

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure3, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' count(distinct a.cust_account_id) , ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' nvl(sum(a.initiated_revenue), 0 ) , ';

/***************/

l_sql_where  :=  l_sql_where || ' where  a.period_start_date  >=  :p_start_date and a.period_end_date <= :p_end_date ' ;

/***************/

IF 	p_campaign_status_id IS NULL THEN
	l_sql_where:= l_sql_where ||' and :p_campaign_status_id IS NULL ' ;
ELSE
	l_sql_where:= l_sql_where || ' and parent_campaign_status_id = :p_campaign_status_id ';
END IF;

IF 	p_campaign_type_id IS NULL THEN
	l_sql_where:= l_sql_where || ' and :p_campaign_type_id  IS NULL ';
ELSE
	l_sql_where:= l_sql_where || ' and parent_campaign_type = :p_campaign_type_id ';
END IF;

/***************/

IF 	p_media_id IS  NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_media_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and  a.media_id = :p_media_id';
END IF;

/***************/

IF 	p_sales_channel_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_sales_channel_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.sales_channel_code = :p_sales_channel_code';
END IF;

/***************/

IF 	p_market_segment_id IS NULL
THEN
	l_sql_where:= l_sql_where|| ' and :p_market_segment_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.market_segment_id   = :p_market_segment_id';
END IF;

/***************/

IF 	p_interest_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_interest_type_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.interest_type_id = :p_interest_type_id ';
END IF;

IF 	p_primary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_primary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.primary_interest_code_id = :p_primary_interest_code_id ';
END IF;

IF 	p_secondary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_secondary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where||' and a.secondary_interest_code_id = :p_secondary_interest_code_id ';
END IF;

/***************/

IF 	p_geography_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_geography_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and bill_to_geography_code like :p_geography_code';
END IF;

/***************/

IF 	p_view_by = 'CMP'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' :p_all_value , cmp.campaign_name ';
	l_sql_from	 	:= l_sql_from ||   ' from bim_cmpgn_perf_summ a , bim_dimv_campaigns cmp ' ;
	l_sql_where 	:= l_sql_where ||  ' and a.campaign_id = cmp.campaign_id  ';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value , cmp.campaign_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= 'cmp.campaign_name ' ;
	from_clause 	:= ' ,bim_dimv_campaigns cmp ' ;
ELSIF p_view_by = 'ACT'
THEN
	l_sql_insert_stm  := l_sql_insert_stm || ' :p_all_value ,med.media_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a, bim_dimv_media med ' ;
	l_sql_where 	:= l_sql_where || ' and a.media_id = med.media_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value , med.media_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' med.media_name ' ;
	from_clause 	:= ' ,bim_dimv_media med ' ;
ELSIF p_view_by = 'SCH'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' :p_all_value , sch.sales_channel_name ';
	l_sql_from	 	:= l_sql_from || 	' from bim_cmpgn_perf_summ a ,bim_dimv_sales_channels sch ' ;
	l_sql_where 	:= l_sql_where || ' and a.sales_channel_code = sch.sales_channel_code';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY   :p_all_value , sch.sales_channel_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' sch.sales_channel_name' ;
	from_clause 	:= ' ,bim_dimv_sales_channels sch ' ;
ELSIF p_view_by = 'MSG'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' :p_all_value , mkt.market_segment_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a  ,bim_dimv_market_sgmts mkt ' ;
	l_sql_where 	:= l_sql_where || ' and a.market_segment_id = mkt.market_segment_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value , mkt.market_segment_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' mkt.market_segment_name' ;
	from_clause 	:= ' ,bim_dimv_market_sgmts mkt ' ;
ELSIF p_view_by = 'PER' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' :p_all_value , per.period_name ';
	l_sql_from:= l_sql_from|| ' from  bim_cmpgn_perf_summ a ,bim_dimv_periods per,dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.period_start_date >= per.start_date and  a.period_end_date <= per.end_date and per.period_set_name = jtf_bis_util.ProfileValue(''CRMBIS:PERIOD_SET_NAME'') and  per.period_type = :p_period_type  ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY :p_all_value , per.period_name , per.start_date ';
	l_sql_order_by 	:= ' Order by :p_all_value, per.start_date ';
      v_view_by 		:= ' per.period_name' ;
	from_clause 	:= ' ,bim_dimv_periods per ' ;
END IF;


-- dbms_output.put_line(p_period_type);

/***************/

l_sql_stmt := l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by;

/**************/

/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp1.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_insert_stm);
		utl_file.put_line(fp,l_sql_from);
		utl_file.put_line(fp,l_sql_where);
		utl_file.put_line(fp,l_sql_group_by);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;
*/

/******************/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_all_value,
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_media_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type,
     p_all_value,
     p_all_value;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_all_value,
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_media_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_all_value;

END IF;

   v_num_rows_inserted := SQL%ROWCOUNT;
     -- dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );

/************************************************************************************************************/

l_sql_update_stm := 'UPDATE bim_camp_acqu_summ_temp tmp set tmp.measure4 = (select nvl(sum(a.initiated_revenue),0) from bim_customer_rev_summ a ' ;

l_sql_where := l_sql_where || ' and a.first_order_date >= :p_start_date and a.first_order_date <= :p_end_date ';

l_sql_where := l_sql_where || ' and tmp.view_by_name = ' || v_view_by || ' ) ' ;

l_sql_upd_stmt := l_sql_update_stm || from_clause || l_sql_where ;

/*
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));


declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp2.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_upd_stmt);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;

*/

/******************/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_media_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type,
     p_start_date,
     p_end_date;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_media_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_start_date,
     p_end_date;
END IF;

/******************/
UPDATE bim_camp_acqu_summ_temp SET measure2 = measure4*100/measure3;

v_num_rows_updated := SQL%ROWCOUNT;
    -- dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );

END BIM_MCH_ACQ_SUM_POPULATE ;

/**********************************************************************************************/

 PROCEDURE BIM_MCH_ACQ_POPULATE
         (
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_campaign_type_id            varchar2  DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_id                    number    DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL,
            p_drill_down                  varchar2  DEFAULT 'Y'
         )  IS

v_num_rows_inserted  integer;
v_num_rows_updated   integer;
v_view_by            varchar2(50);
from_clause          varchar2(100);
where_clause         varchar2(250);

l_sql_from		varchar2(5000);
l_sql_where	      varchar2(5000);
l_sql_group_by    varchar2(5000);
l_sql_order_by	varchar2(5000);
l_sql_insert_stm 	varchar2(5000);
l_sql_stmt		varchar2(5000);
v_all_name        varchar2(80);

l_sql_update_stm 	varchar2(5000);
l_sql_upd_stmt	varchar2(5000);


BEGIN


l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure3, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' count(distinct a.cust_account_id) , ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' nvl(sum(a.initiated_revenue), 0 ) , ';

/***************/

l_sql_where:= ' where  a.period_start_date   >= :p_start_date and a.period_end_date <= :p_end_date';

/***************/

l_sql_where:= l_sql_where|| ' and a.campaign_id in (select parent_campaign_id from bim_campaigns_denorm';

IF 	p_campaign_status_id IS NULL THEN
	l_sql_where:= l_sql_where||' where :p_campaign_status_id IS NULL' ;
ELSE
	l_sql_where:= l_sql_where|| ' where parent_campaign_status_id = :p_campaign_status_id';
END IF;

IF 	p_campaign_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_campaign_type_id  IS NULL';
ELSE
	l_sql_where:= l_sql_where|| ' and parent_campaign_type = :p_campaign_type_id';
END IF;

IF 	p_campaign_id  IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_campaign_id   IS NULL ) ';
ELSE
	l_sql_where:= l_sql_where|| ' and parent_campaign_id = :p_campaign_id ) ';
END IF;


/***************/

IF 	p_media_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_media_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.media_id = :p_media_id';
END IF;

/***************/

IF 	p_channel_id IS  NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_channel_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and  a.channel_id = :p_channel_id';
END IF;

/***************/

IF 	p_sales_channel_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_sales_channel_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.sales_channel_code = :p_sales_channel_code';
END IF;

/***************/

IF 	p_market_segment_id IS NULL
THEN
	l_sql_where:= l_sql_where|| ' and :p_market_segment_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.market_segment_id   = :p_market_segment_id';
END IF;

/***************/

IF 	p_interest_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_interest_type_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.interest_type_id = :p_interest_type_id ';
END IF;

IF 	p_primary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_primary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.primary_interest_code_id = :p_primary_interest_code_id ';
END IF;

IF 	p_secondary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_secondary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where||' and a.secondary_interest_code_id = :p_secondary_interest_code_id ';
END IF;

/***************/

IF 	p_geography_code IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_geography_code IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and bill_to_geography_code like :p_geography_code';
END IF;


/***************/

IF 	p_view_by = 'CMP'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' chn.channel_name , cmp.campaign_name ';
	l_sql_from	 	:= l_sql_from ||   ' from bim_cmpgn_perf_summ a , bim_dimv_channels chn ,bim_dimv_campaigns cmp' ;
	l_sql_where 	:= l_sql_where ||  ' and a.channel_id = chn.channel_id and a.campaign_id = cmp.campaign_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  chn.channel_name , cmp.campaign_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' cmp.campaign_name' ;
	from_clause 	:= ' ,bim_dimv_campaigns cmp ' ;
ELSIF p_view_by = 'ACT'
THEN
	l_sql_insert_stm  := l_sql_insert_stm || ' chn.channel_name , med.media_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a,  bim_dimv_channels chn ,bim_dimv_media med ' ;
	l_sql_where 	:= l_sql_where || ' and a.channel_id = chn.channel_id and a.media_id = med.media_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  chn.channel_name, med.media_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' med.media_name' ;
	from_clause 	:= ' ,bim_dimv_media med ' ;
ELSIF p_view_by = 'SCH'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' chn.channel_name, sch.sales_channel_name ';
	l_sql_from	 	:= l_sql_from || 	' from bim_cmpgn_perf_summ a,  bim_dimv_sales_channels sch ,bim_dimv_channels chn ' ;
	l_sql_where 	:= l_sql_where || ' and a.sales_channel_code = sch.sales_channel_code and a.channel_id = chn.channel_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY   chn.channel_name, sch.sales_channel_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' sch.sales_channel_name' ;
	from_clause 	:= ' ,bim_dimv_sales_channels sch ' ;
ELSIF p_view_by = 'MSG'
THEN
	l_sql_insert_stm 	:= l_sql_insert_stm || ' chn.channel_name , mkt.market_segment_name ';
	l_sql_from	 	:= l_sql_from ||  ' from bim_cmpgn_perf_summ a, bim_dimv_market_sgmts mkt ,bim_dimv_channels chn' ;
	l_sql_where 	:= l_sql_where || ' and a.market_segment_id = mkt.market_segment_id and a.channel_id = chn.channel_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  chn.channel_name , mkt.market_segment_name ';
	l_sql_order_by 	:= ' Order by 1,3 desc';
      v_view_by 		:= ' mkt.market_segment_name' ;
	from_clause 	:= ' ,bim_dimv_market_sgmts mkt ' ;
ELSIF p_view_by = 'PER' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' chn.channel_name, per.period_name ';
	l_sql_from:= l_sql_from|| ' from  bim_cmpgn_perf_summ a, bim_dimv_channels chn, bim_dimv_periods per,dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.channel_id = chn.channel_id and a.period_start_date >= per.start_date and  a.period_end_date <= per.end_date
and per.period_set_name = jtf_bis_util.ProfileValue(''CRMBIS:PERIOD_SET_NAME'') and  per.period_type = :p_period_type  ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY chn.channel_name, per.period_name , per.start_date ';
	l_sql_order_by 	:= ' Order by chn.channel_name, per.start_date ';
      v_view_by 		:= ' per.period_name' ;
	from_clause 	:= ' ,bim_dimv_periods per ' ;
END IF;

/***************/

l_sql_stmt := l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by;


/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'mm1.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_insert_stm);
		utl_file.put_line(fp,l_sql_from);
		utl_file.put_line(fp,l_sql_where);
		utl_file.put_line(fp,l_sql_group_by);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;
*/


/******************/

IF (p_view_by = 'PER') THEN

EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type;
ELSE
EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code;

END IF;

   v_num_rows_inserted := SQL%ROWCOUNT;
     -- dbms_output.put_line ( 'Number of rows inserted in temp table is : ' || v_num_rows_inserted );

/************************************************************************************************************/

l_sql_update_stm := 'UPDATE bim_camp_acqu_summ_temp tmp set tmp.measure4 = (select nvl(sum(a.initiated_revenue),0) from bim_customer_rev_summ a, bim_dimv_channels chn ' ;

l_sql_where := l_sql_where || ' and a.first_order_date >= :p_start_date and a.first_order_date <= :p_end_date ';

l_sql_where := l_sql_where || ' and tmp.subject_name = chn.channel_name and tmp.view_by_name = ' || v_view_by || ' ) ' ;

l_sql_upd_stmt := l_sql_update_stm || from_clause || l_sql_where ;

-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_update_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));

/******************/

/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp21.sql';
begin
		-- dbms_output.put_line('ENTERED THE SQL BLOCK ');
		fp := 	utl_file.fopen(location,file_name,'w');
		utl_file.put_line(fp,l_sql_upd_stmt);
		utl_file.fclose(fp);
exception
when 	UTL_FILE.INVALID_MODE then
	 	-- dbms_output.put_line('INVALID MODE EXCEPTION');
when 	UTL_FILE.INVALID_PATH then
		-- dbms_output.put_line('INVALID PATH EXCEPTION');
end;
*/

/******************/

IF (p_view_by = 'PER') THEN

-- dbms_OUTPUT.PUT_LINE(' VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_period_type,
     p_start_date,
     p_end_date;
ELSE

-- dbms_OUTPUT.PUT_LINE(' NOT VIEW BY PERIOD ');

EXECUTE IMMEDIATE l_sql_upd_stmt
USING
     p_start_date,
     p_end_date,
     p_campaign_status_id,
     p_campaign_type_id,
     p_campaign_id,
     p_media_id,
     p_channel_id,
     p_sales_channel_code,
     p_market_segment_id,
     p_interest_type_id,
     p_primary_interest_code_id,
     p_secondary_interest_code_id,
     p_geography_code,
     p_start_date,
     p_end_date;
END IF;


/******************/



UPDATE bim_camp_acqu_summ_temp SET measure2 = measure4*100/measure3;

v_num_rows_updated := SQL%ROWCOUNT;
    -- dbms_output.put_line ( 'Number of rows updated in temp table is : ' || v_num_rows_updated );


END BIM_MCH_ACQ_POPULATE  ;

END BIM_ACQ_PKG;

/
