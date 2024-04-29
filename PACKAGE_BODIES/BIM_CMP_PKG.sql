--------------------------------------------------------
--  DDL for Package Body BIM_CMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_CMP_PKG" AS
/*$Header: bimcmpgb.pls 115.18 2001/08/13 16:09:51 pkm ship      $*/

PROCEDURE BIM_CMP_COST_PLEAD_POPULATE
         (
            p_start_date                  in date        DEFAULT NULL,
            p_end_date                    in date        DEFAULT NULL,
            p_campaign_id                 in number      DEFAULT NULL,
            p_drill_down                  in varchar2    DEFAULT NULL,
            p_campaign_status_id          in number      DEFAULT NULL,
            p_campaign_type_id            in varchar2    DEFAULT NULL,
            p_media_id                    in number      DEFAULT NULL,
            p_channel_id                  in varchar2    DEFAULT NULL,
            p_period_type                 in varchar2    DEFAULT NULL,
            p_view_by                     in varchar2    DEFAULT NULL
         )  IS

l_sql_insert_stm            varchar2(10000);
l_sql_from                  varchar2(10000);
l_sql_where                 varchar2(30000);
l_sql_group_by              varchar2(2000);
l_sql_order_by              varchar2(2000);
l_sql_outer_where           varchar2(2000);
l_view_by                   varchar2(2000);
l_subject_name              varchar2(2000);
l_jtf_bis_util              varchar2(2000);

begin
l_jtf_bis_util := 'jtf_bis_util.profileValue(''CRMBIS:PERIOD_SET_NAME'')';

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure2, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' Sum(bscc.num_of_leads),';

l_sql_insert_stm := l_sql_insert_stm
                 || ' decode(sum(BSCC.num_of_leads),0,0,( sum (BSCC.actual_cost) / sum (BSCC.num_of_leads) )),';

l_sql_from := ' FROM bim_cmpgn_revcost_summ BSCC, bim_campaigns_denorm denorm,bim_dimv_campaigns BDC';

--Build the where clause

l_sql_where := ' where BSCC.campaign_id = denorm.campaign_id and denorm.parent_campaign_id = BDC.campaign_id and BSCC.PERIOD_start_date >= :p_start_date and BSCC.PERIOD_end_date <= :p_end_date';

IF p_campaign_id IS NULL then
    l_sql_where := l_sql_where || ' and :p_campaign_id is null ';
ELSIF p_drill_down = 'Y' then
    l_sql_where := l_sql_where || ' and NVL(denorm.parent_campaign_id,-999) = :p_campaign_id';
ELSE l_sql_where := l_sql_where || ' and denorm.campaign_id =:p_campaign_id ';
END IF;

IF p_campaign_status_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and denorm.parent_campaign_status_id = :p_campaign_status_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_status_id IS NULL';
END IF;

IF p_campaign_type_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' And denorm.parent_campaign_type = :p_campaign_type_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_type_id IS NULL ';
END IF;

IF P_media_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and BSCC.Media_id = :P_media_id';
ELSE
    l_sql_where := l_sql_where || ' and :P_media_id IS NULL';
END IF;

IF p_channel_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and BSCC.channel_id = :p_channel_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_channel_id IS NULL';
END IF;

if p_view_by = 'PER' THEN
IF p_period_type IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' AND BDP.PERIOD_TYPE like :p_period_type';
ELSE
    l_sql_where := l_sql_where || ' and :p_period_type IS NULL';
END IF;
END IF;

if p_view_by = 'MCH'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' BDC.campaign_name,BDMC.Channel_name ';
   l_sql_from := l_sql_from || ' ,BIM_DIMV_MEDIA_CHANNELS BDMC, dual';
   l_sql_where := l_sql_where || ' AND BSCC.media_id = BDMC.media_id and BSCC.channel_id = BDMC.channel_id';
   l_sql_group_by := l_sql_group_by || ' GROUP BY BDC.campaign_name, BDMC.channel_name   ';
   l_sql_order_by := l_sql_order_by || ' Order by 3,2 desc';
ELSIF
   p_view_by = 'ACT'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' BDC.campaign_name,bdm.media_name ';
   l_sql_from := l_sql_from || ' ,bim_dimv_media bdm, dual';
   l_sql_where := l_sql_where || ' and bscc.media_id = BDM.media_id ';
   l_sql_group_by := l_sql_group_by || ' GROUP BY BDC.campaign_name,bdm.media_name ';
   l_sql_order_by := l_sql_order_by || ' Order by 3,2 desc';
ELSIF
   p_view_by = 'PER'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' BDC.Campaign_name,BSCC.period_name ';
   l_sql_from := l_sql_from || ' ,bim_dimv_periods bdp, dual';
   l_sql_where := l_sql_where || ' and bscc.period_start_date = bdp.start_date and bscc.period_end_date = bdp.end_date and BDP.period_set_name  =' || l_jtf_bis_util ;
   l_sql_group_by := l_sql_group_by || ' GROUP BY BDC.Campaign_name,BSCC.period_name, bdp.start_date ';
   l_sql_order_by := l_sql_order_by || ' Order by BDC.Campaign_name,bdp.start_date';
END IF;

-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
-- dbms_OUTPUT.PUT_LINE(l_sql_group_by);
-- dbms_OUTPUT.PUT_LINE(l_sql_order_by);

IF P_VIEW_BY = 'PER' THEN
EXECUTE IMMEDIATE l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by
Using
 p_start_date
,p_end_date
,p_campaign_id
,p_campaign_status_id
,p_campaign_type_id
,p_media_id
,p_channel_id
,P_PERIOD_TYPE;
ELSE
EXECUTE IMMEDIATE l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by
Using
 p_start_date
,p_end_date
,p_campaign_id
,p_campaign_status_id
,p_campaign_type_id
,p_media_id
,p_channel_id;
END IF;

end BIM_CMP_COST_PLEAD_POPULATE;


PROCEDURE BIM_CMP_COST_POPULATE
         (
            p_start_date                  in date      DEFAULT NULL,
            p_end_date                    in date      DEFAULT NULL,
            p_campaign_id                 in number    DEFAULT NULL,
            p_drill_down                  in varchar2  DEFAULT 'Y',
            p_campaign_status_id          in number    DEFAULT NULL,
            p_campaign_type_id            in varchar2  DEFAULT NULL,
            p_media_id                    in number    DEFAULT NULL,
            p_channel_id                  in varchar2  DEFAULT NULL,
            p_view_by                     in varchar2  DEFAULT NULL
         )  IS

l_sql_insert_stm            varchar2(10000);
l_sql_from                  varchar2(10000);
l_sql_where                 varchar2(30000);
l_sql_group_by              varchar2(2000);
l_sql_order_by              varchar2(2000);
l_sql_outer_where           varchar2(2000);
l_view_by                   varchar2(2000);
l_subject_name              varchar2(2000);

begin

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure2, measure3, measure4, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' decode(sum(ccost.actual_cost), 0, 0, ((sum(ccost.initiated_revenue)-sum(ccost.actual_cost))/sum(ccost.actual_cost))*100),';

l_sql_insert_stm := l_sql_insert_stm
                 || ' sum(ccost.forecasted_cost),';

l_sql_insert_stm := l_sql_insert_stm
                 || ' sum(ccost.actual_cost),';

l_sql_insert_stm := l_sql_insert_stm
                 || ' decode(sum(ccost.actual_cost), 0,0,((sum(ccost.forecasted_cost)-sum(ccost.actual_cost))/sum(ccost.actual_cost))*100),';

l_sql_from := ' From BIM_CMPGN_REVCOST_SUMM ccost, bim_campaigns_denorm denorm, bim_dimv_campaigns dimv, bim_dimv_media_channels bdmc, dual';

--Build the where clause

l_sql_where := ' WHERE ccost.campaign_id = denorm.campaign_id AND CCOST.media_id = BDMC.media_id and CCOST.channel_id
= BDMC.channel_id and denorm.parent_campaign_id = dimv.campaign_id and CCOST.PERIOD_start_date >= :p_start_date and CCOST.PERIOD_end_date <= :p_end_date';

IF p_campaign_id IS NULL then
    l_sql_where := l_sql_where || ' and :p_campaign_id is null ';
ELSIF p_drill_down = 'Y' then
    l_sql_where := l_sql_where || ' and NVL(denorm.parent_campaign_id,-999) = :p_campaign_id';
ELSE l_sql_where := l_sql_where || ' and denorm.campaign_id =:p_campaign_id ';
END IF;

IF p_campaign_status_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and denorm.parent_campaign_status_id = :p_campaign_status_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_status_id IS NULL';
END IF;

IF p_campaign_type_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' And denorm.parent_campaign_type = :p_campaign_type_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_type_id IS NULL ';
END IF;

IF P_media_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and BSCC.Media_id = :P_media_id';
ELSE
    l_sql_where := l_sql_where || ' and :P_media_id IS NULL';
END IF;

IF p_channel_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and BSCC.channel_id = :p_channel_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_channel_id IS NULL';
END IF;

l_sql_order_by := ' ORDER BY 1,3,6 DESC';

if p_view_by = 'MCH'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' dimv.campaign_name, BDMC.channel_name ';
   l_sql_group_by := l_sql_group_by || ' GROUP BY dimv.campaign_name, BDMC.channel_name   ';
ELSIF
   p_view_by = 'ACT'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' dimv.campaign_name, bdmc.media_name ';
   l_sql_group_by := l_sql_group_by || ' GROUP BY dimv.campaign_name, bdmc.media_name ';
END IF;

-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
-- dbms_OUTPUT.PUT_LINE(l_sql_group_by);
-- dbms_OUTPUT.PUT_LINE(l_sql_order_by);

EXECUTE IMMEDIATE l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by
Using
p_start_date
,p_end_date
,p_campaign_id
,p_campaign_status_id
,p_campaign_type_id
,p_media_id
,p_channel_id;

end BIM_CMP_COST_POPULATE;

PROCEDURE BIM_CMP_COST_SUM_POPULATE
         (
            p_all_value                   in varchar2 DEFAULT NULL,
            p_campaign_status_id          in number   DEFAULT NULL,
            p_campaign_type_id            in varchar2 DEFAULT NULL,
            p_media_id                    in number   DEFAULT NULL,
            p_channel_id                  in varchar2 DEFAULT NULL,
            p_view_by                     in varchar2 DEFAULT NULL
         )  IS

l_sql_insert_stm            varchar2(10000);
l_sql_from                  varchar2(10000);
l_sql_where                 varchar2(30000);
l_sql_group_by              varchar2(2000);
l_sql_order_by              varchar2(2000);
l_sql_outer_where           varchar2(2000);
l_view_by                   varchar2(2000);
l_subject_name              varchar2(2000);

begin

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure2, measure3, measure4, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' decode(sum(ccost.actual_cost), 0, 0, ((sum(ccost.initiated_revenue)-sum(ccost.actual_cost))/sum(ccost.actual_cost))*100),';

l_sql_insert_stm := l_sql_insert_stm
                 || ' sum(ccost.forecasted_cost),';

l_sql_insert_stm := l_sql_insert_stm
                 || ' sum(ccost.actual_cost),';

l_sql_insert_stm := l_sql_insert_stm
                 || ' decode(sum(ccost.actual_cost), 0,0,((sum(ccost.forecasted_cost)-sum(ccost.actual_cost))/sum(ccost.actual_cost))*100),';

l_sql_from := ' From BIM_CMPGN_REVCOST_SUMM ccost, bim_campaigns_denorm denorm, bim_dimv_campaigns dimv, bim_dimv_media_channels bdmc, dual';

--Build the where clause

l_sql_where := ' WHERE ccost.campaign_id = denorm.campaign_id AND CCOST.media_id = BDMC.media_id and CCOST.channel_id = BDMC.channel_id and denorm.parent_campaign_id = dimv.campaign_id and denorm.level_from_parent = 0';

IF p_campaign_status_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and denorm.parent_campaign_status_id = :p_campaign_status_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_status_id IS NULL';
END IF;

IF p_campaign_type_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' And denorm.parent_campaign_type = :p_campaign_type_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_type_id IS NULL ';
END IF;

IF P_media_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and BSCC.Media_id = :P_media_id';
ELSE
    l_sql_where := l_sql_where || ' and :P_media_id IS NULL';
END IF;

IF p_channel_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and BSCC.channel_id = :p_channel_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_channel_id IS NULL';
END IF;

l_sql_order_by := ' ORDER BY 1,3,6 DESC';

if p_view_by = 'MCH'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' :p_all_value, bdmc.channel_name ';
   l_sql_group_by := l_sql_group_by || ' GROUP BY bdmc.channel_name   ';
ELSIF
   p_view_by = 'ACT'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' :p_all_value, bdmc.media_name ';
   l_sql_group_by := l_sql_group_by || ' GROUP BY  bdmc.media_name ';
END IF;

-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
-- dbms_OUTPUT.PUT_LINE(l_sql_group_by);
-- dbms_OUTPUT.PUT_LINE(l_sql_order_by);

EXECUTE IMMEDIATE l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by
Using
p_all_value
,p_campaign_status_id
,p_campaign_type_id
,p_media_id
,p_channel_id;

end BIM_CMP_COST_SUM_POPULATE;


PROCEDURE    BIM_CMP_PERF_POPULATE
         (
            p_start_date                  in  date      DEFAULT NULL,
            p_end_date                    in  date      DEFAULT NULL,
            p_campaign_id                 in  number    DEFAULT NULL,
            p_campaign_type_id            in  varchar2  DEFAULT NULL,
            p_campaign_status_id          in  number    DEFAULT NULL,
            p_media_id                    in  number    DEFAULT NULL,
            p_channel_id                  in  varchar2  DEFAULT NULL,
		    p_drill_down			      in  varchar2  DEFAULT 'Y',
            p_sales_channel_code          in  varchar2  DEFAULT NULL,
            p_market_segment_id           in  number    DEFAULT NULL,
            p_interest_type_id            in  number    DEFAULT NULL,
            p_primary_interest_code_id    in  number    DEFAULT NULL,
            p_secondary_interest_code_id  in  number    DEFAULT NULL,
            p_geography_code              in  varchar2  DEFAULT NULL,
            p_period_type                 in  varchar2  DEFAULT NULL,
            p_view_by                     in  varchar2  DEFAULT NULL
         )  IS

v_num_rows_inserted  integer;
v_num_rows_updated   integer;

l_view_by            	varchar2(50);

l_sql_from		varchar2(5000);
l_sql_where	        varchar2(5000);
l_sql_group_by    	varchar2(5000);
l_sql_order_by		varchar2(5000);
l_sql_insert_stm 	varchar2(5000);
l_sql_stmt		varchar2(5000);
v_all_name           	varchar2(80);

BEGIN

/***************/

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure2, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' count(distinct(a.lead_id)), ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' round(decode(count(distinct(a.lead_id)),0,0,sum(a.initiated_revenue)/count(distinct(a.lead_id))),2), ';

/***************/

/* l_sql_from := ' from  bim_cmpgn_perf_summ a '; */

/***************/

l_sql_where:= l_sql_where ||' where a.period_start_date   >= :p_start_date and a.period_end_date <= :p_end_date';

/***************/

IF p_campaign_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and b.parent_campaign_id in (select campaign_id from bim_dimv_campaigns where parent_campaign_id is null  and :p_campaign_id is null ) ';
ELSE
	l_sql_where:= l_sql_where|| ' and b.parent_campaign_id in (select campaign_id from bim_dimv_campaigns where parent_campaign_id is null  and :p_campaign_id is null ) ';
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

/* l_sql_where:= l_sql_where|| ' and a.interest_type_id  = d.interest_type_id and a.primary_interest_code_id = d.primary_interest_code_id and a.secondary_interest_code_id = d.secondary_interest_code_id'; */

IF 	p_interest_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_interest_type_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.interest_type_id = :p_interest_type_id ';
END IF;

/***************/

IF 	p_primary_interest_code_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_primary_interest_code_id IS NULL ';
ELSE
	l_sql_where:= l_sql_where|| ' and a.primary_interest_code_id = :p_primary_interest_code_id ';
END IF;

/***************/

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

IF 	p_view_by = 'MCH' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' d.campaign_name, c.channel_name';
	l_sql_from	:= l_sql_from|| ' from bim_cmpgn_perf_summ a,bim_campaigns_denorm b,bim_dimv_campaigns d, bim_dimv_media_channels c, dual ' ;
	l_sql_where	:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and b.parent_campaign_id = d.campaign_id and a.media_id = c.media_id and a.channel_id = c.channel_id';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  d.campaign_name , c.channel_name ';
    l_sql_order_by := ' Order by 3,2 desc ';
ELSIF p_view_by = 'ACT' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' d.campaign_name, e.media_name ';
	l_sql_from	:= l_sql_from|| ' from 	bim_cmpgn_perf_summ a,bim_campaigns_denorm b,bim_dimv_campaigns d,bim_dimv_media e, dual ' ;
	l_sql_where	:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and b.parent_campaign_id = d.campaign_id and a.media_id = e.media_id ';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  d.campaign_name, e.media_name ';
    l_sql_order_by := ' Order by 3,2 desc ';
ELSIF p_view_by = 'MSG' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' d.campaign_name , e.market_segment_name ';
	l_sql_from:= l_sql_from|| ' from 	bim_cmpgn_perf_summ a,bim_campaigns_denorm b ,bim_dimv_campaigns d,bim_dimv_market_sgmts e,dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and b.parent_campaign_id = d.campaign_id and a.market_segment_id = e.market_segment_id ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY  d.campaign_name , e.market_segment_name ';
    l_sql_order_by := ' Order by 3,2 desc ';
ELSIF p_view_by = 'SCH' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' d.campaign_name , e.sales_channel_name ';
	l_sql_from:= l_sql_from|| ' from 	bim_cmpgn_perf_summ a,bim_campaigns_denorm b,bim_dimv_campaigns d,bim_dimv_sales_channels e, dual ' ;
	l_sql_where:=  l_sql_where||' and a.campaign_id = b.campaign_id and b.campaign_id = d.campaign_id and a.sales_channel_code= e.sales_channel_code ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY d.campaign_name, e.sales_channel_name ';
    l_sql_order_by := ' Order by 3,2 desc ';
ELSIF 	p_view_by = 'PER' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' d.campaign_name , e.period_name ';
	l_sql_from:= l_sql_from|| ' from 	bim_cmpgn_perf_summ a,bim_campaigns_denorm b,bim_dimv_campaigns d, bim_dimv_periods e, dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and b.campaign_id = d.campaign_id and a.period_start_date >= e.start_date
and  a.period_end_date <= e.end_date and e.period_set_name = jtf_bis_util.ProfileValue(''CRMBIS:PERIOD_SET_NAME'')';
    IF p_period_type IS NOT NULL
    THEN
        l_sql_where := l_sql_where || ' and e.PERIOD_TYPE like :p_period_type';
    ELSE
        l_sql_where := l_sql_where || ' and :p_period_type IS NULL';
    END IF;
    l_sql_group_by := l_sql_group_by || ' GROUP BY d.campaign_name , e.period_name, e.start_date';
    l_sql_order_by := ' Order by d.campaign_name, e.start_date ';
END IF;

/***************/

l_sql_stmt := l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by;
-- dbms_OUTPUT.PUT_LINE('COMING HERE ');


/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp.sql';
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

-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
-- dbms_OUTPUT.PUT_LINE(l_sql_group_by);
-- dbms_OUTPUT.PUT_LINE(l_sql_order_by);




/******************/

-- dbms_output.put_line('COMPLETED THE SQL STATEMENT ');

if (p_view_by = 'PER') THEN
EXECUTE IMMEDIATE l_sql_stmt
    USING
     p_start_date,
     p_end_date,
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
--    dbms_output.put_line ( 'Number of rows inserted in temp table IS : ' || v_num_rows_inserted );

END   BIM_CMP_PERF_POPULATE ;

PROCEDURE   BIM_CMP_PERF_SUM_POPULATE
         (
            p_period_type                 in  varchar2  DEFAULT NULL,
            p_all_value				      in  varchar2  DEFAULT 'ALL',
            p_start_date                  in  date      DEFAULT NULL,
            p_end_date                    in  date      DEFAULT NULL,
            p_campaign_type_id            in  varchar2  DEFAULT NULL,
            p_campaign_status_id          in  number    DEFAULT NULL,
            p_media_id                    in  number    DEFAULT NULL,
            p_channel_id                  in  varchar2  DEFAULT NULL,
            p_sales_channel_code          in  varchar2  DEFAULT NULL,
            p_market_segment_id           in  number    DEFAULT NULL,
            p_interest_type_id            in  number    DEFAULT NULL,
            p_primary_interest_code_id    in  number    DEFAULT NULL,
            p_secondary_interest_code_id  in  number    DEFAULT NULL,
            p_geography_code              in  varchar2  DEFAULT NULL,
            p_view_by                     in  varchar2  DEFAULT NULL
         )  IS

v_num_rows_inserted  	integer;
v_num_rows_updated   	integer;

l_view_by            	varchar2(50);
l_sql_from			varchar2(5000);
l_sql_where		      varchar2(5000);
l_sql_group_by    	varchar2(5000);
l_sql_order_by		varchar2(5000);
l_sql_insert_stm 		varchar2(5000);
l_sql_stmt			varchar2(5000);
v_all_name           	varchar2(80);

BEGIN

/***************/

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure2, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || ' count(distinct(a.lead_id)), ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' round(decode(count(distinct(a.lead_id)),0,0,sum(a.initiated_revenue)/count(distinct(a.lead_id))),2), :p_all_value ,';

l_sql_where:= l_sql_where||' where a.period_start_date   >= :p_start_date and a.period_end_date <= :p_end_date';
/***************/

/* l_sql_from := ' from  bim_cmpgn_perf_summ a,bim_dimv_prod_lov d '; */


/***************/

IF 	p_campaign_status_id IS NULL THEN
	l_sql_where:= l_sql_where||' and :p_campaign_status_id IS NULL' ;
ELSE
	l_sql_where:= l_sql_where|| ' and parent_campaign_status_id = :p_campaign_status_id';
END IF;

IF 	p_campaign_type_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and :p_campaign_type_id  IS NULL';
ELSE
	l_sql_where:= l_sql_where|| ' and parent_campaign_type = :p_campaign_type_id';
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

IF P_VIEW_BY = 'PER' THEN
    IF p_period_type IS NOT NULL
    THEN
     l_sql_where := l_sql_where || ' and d.PERIOD_TYPE like :p_period_type';
    ELSE
     l_sql_where := l_sql_where || ' and :p_period_type IS NULL';
    end if;
END IF;
/***************/

IF 	p_view_by = 'MCH' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' c.channel_name ';
	l_sql_from	:= l_sql_from|| ' from bim_cmpgn_perf_summ   a ,bim_campaigns_denorm  b ,bim_dimv_media_channels c, dual ' ;
	l_sql_where	:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and a.media_id = c.media_id and a.channel_id = c.channel_id and b.level_from_parent = 0 ';
	l_sql_group_by 	:= l_sql_group_by || ' GROUP BY  :p_all_value,c.channel_name ';
    l_sql_order_by := ' Order by 3,2 desc';
ELSIF 	p_view_by = 'ACT' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' d.media_name ';
	l_sql_from	:= l_sql_from|| ' from bim_cmpgn_perf_summ   a, bim_campaigns_denorm  b , bim_dimv_media d, dual  ' ;
	l_sql_where:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and a.media_id = d.media_id and b.level_from_parent = 0 ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY  :p_all_value , d.media_name ';
    l_sql_order_by := ' Order by 3,2 desc';
ELSIF 	p_view_by = 'MSG' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' d.market_segment_name ';
	l_sql_from:= l_sql_from|| ' from 	bim_cmpgn_perf_summ   a ,bim_campaigns_denorm  b, bim_dimv_market_sgmts d, dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and a.market_segment_id = d.market_segment_id and b.level_from_parent = 0 ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY  :p_all_value , d.market_segment_name ';
    l_sql_order_by := ' Order by 3,2 desc';
ELSIF 	p_view_by = 'SCH' THEN
	l_sql_insert_stm := l_sql_insert_stm || ' d.sales_channel_name ';
	l_sql_from:= l_sql_from|| ' from 	bim_cmpgn_perf_summ  a ,bim_campaigns_denorm  b, bim_dimv_sales_channels d, dual ' ;
	l_sql_where:=  l_sql_where||' and a.campaign_id = b.campaign_id and a.sales_channel_code = d.sales_channel_code and b.level_from_parent = 0 ';
	l_sql_group_by := l_sql_group_by || ' GROUP BY  :p_all_value , d.sales_channel_name ';
    l_sql_order_by := ' Order by 3,2 desc';
ELSIF p_view_by = 'PER' THEN
	l_sql_insert_stm := l_sql_insert_stm || '  d.period_name ';
	l_sql_from:= l_sql_from|| ' from bim_cmpgn_perf_summ  a, bim_campaigns_denorm b, bim_dimv_periods d, dual ' ;
	l_sql_where:=  l_sql_where|| ' and a.campaign_id = b.campaign_id and a.period_start_date >= d.start_date and  a.period_end_date <= d.end_date and d.period_set_name = jtf_bis_util.ProfileValue(''CRMBIS:PERIOD_SET_NAME'') ';
    l_sql_group_by := l_sql_group_by || ' GROUP BY :p_all_value , d.period_name, d.start_date ';
    l_sql_order_by := ' Order by d.start_date';
END IF;

/***************/

l_sql_stmt := l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by;

/**************/

/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp.sql';
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
delete bim_camp_acqu_summ_temp;

-- dbms_output.put_line('COMPLETED THE SQL STATEMENT ');

IF (p_view_by = 'PER') THEN
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
     p_all_value;
ELSE
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
--   -- dbms_output.put_line ( 'Number of rows inserted in temp table IS : ' || v_num_rows_inserted );

END  BIM_CMP_PERF_SUM_POPULATE ;


PROCEDURE BIM_CMP_RESP_POPULATE

         (
            p_start_date                  in date      default null,
            p_end_date                    in date      default null,
            p_drill_down                  in varchar2  default null,
            p_media_id                    in number    default null,
            p_channel_id                  in varchar2  default null,
            p_market_segment_id           in number    default null,
            p_geography_code              in varchar2  default null,
            p_campaign_id                 in number    default null,
            p_campaign_status_id          in number    default null,
            p_campaign_type_id            in varchar2  default null,
            p_period_type                 in varchar2  default null,
            p_view_by                     in varchar2  default null
         ) IS



l_sql_insert_stm            varchar2(10000);
l_sql_from                  varchar2(10000);
l_sql_where                 varchar2(30000);
l_sql_group_by              varchar2(2000);
l_sql_order_by              varchar2(2000);
l_jtf_bis_util              varchar2(2000);




begin

l_jtf_bis_util := 'jtf_bis_util.profileValue(''CRMBIS:PERIOD_SET_NAME'')';

l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure2, subject_name, view_by_name)';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;
l_sql_insert_stm := l_sql_insert_stm || ' Sum(nvl(BSCR.num_responded,0)),';
l_sql_insert_stm := l_sql_insert_stm || ' decode(sum(BSCR.NUM_TARGETED),0,0,( SUM(BSCR.NUM_RESPONDED) / SUM(BSCR.NUM_TARGETED) ) * 100), ';

l_sql_from := ' FROM BIM_CMPGN_RESP_SUMM BSCR,  bim_campaigns_denorm denorm, ';

l_sql_where := ' WHERE BSCR.PERIOD_start_date >= :p_start_date And BSCR.PERIOD_end_date <= :p_end_date';
l_sql_where := l_sql_where || ' AND BSCR.campaign_id = denorm.campaign_id and denorm.parent_campaign_id = BDC.campaign_id ';


IF p_campaign_id IS NULL then
    l_sql_where := l_sql_where || ' and :p_campaign_id is null ';
ELSIF p_drill_down = 'Y' then
    l_sql_where := l_sql_where || ' and NVL(DENORM.parent_campaign_id, -999) = :p_campaign_id';
ELSE l_sql_where := l_sql_where || ' and DENORM.campaign_id = :p_campaign_id ';
END IF;


IF p_campaign_status_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' And denorm.parent_campaign_status_id = :p_campaign_status_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_status_id IS NULL';
END IF;

IF p_campaign_type_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' And  denorm.Parent_Campaign_type = :p_campaign_type_id)';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_type_id IS NULL ';
END IF;

IF P_media_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and BSCR.Media_id = :p_media_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_media_id IS NULL';
END IF;

IF p_channel_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and BSCR.channel_id = :p_channel_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_channel_id IS NULL';
END IF;

IF p_market_segment_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and BSCR.market_segment_id = :p_market_segment_id';
ELSE
    l_sql_where := l_sql_where || ' and :p_market_segment_id IS NULL';
END IF;

IF p_geography_code IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' AND BSCR.geography_code like :p_geography_code';
ELSE
    l_sql_where := l_sql_where || ' and :p_geography_code IS NULL';
END IF;



IF p_view_by = 'MSG'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' BDC.campaign_name,BDMS.market_segment_name  ';
   l_sql_from := l_sql_from || '  bim_dimv_campaigns BDC, BIM_DIMV_MARKET_SGMTS BDMS, dual ';
   l_sql_where := l_sql_where || ' and BSCR.MARKET_SEGMENT_ID = BDMS.MARKET_SEGMENT_ID ';
   l_sql_group_by := ' GROUP BY BDC.campaign_name, BDMS.market_segment_name ';
   l_sql_order_by := ' Order by 3,2 desc';
ELSIF
   p_view_by = 'PER'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' BDC.campaign_name,bdp.period_name ';
   l_sql_from := l_sql_from || ' bim_dimv_periods bdp, bim_dimv_campaigns BDC,dual ';
   l_sql_where := l_sql_where || ' and BSCR.period_start_date >= BDP.start_date and  BSCR.period_end_date <= BDP.end_date and BDP.period_set_name = jtf_bis_util.ProfileValue(''CRMBIS:PERIOD_SET_NAME'')';

   IF p_period_type IS NOT NULL
   THEN
      l_sql_where := l_sql_where || ' AND bdp.PERIOD_TYPE like :p_period_type';
   ELSE
      l_sql_where := l_sql_where || ' and :p_period_type IS NULL';
   END IF;

   l_sql_group_by := ' GROUP BY BDC.campaign_name, bdp.period_name, bdp.start_date ';
   l_sql_order_by := ' order by bdc.campaign_name, bdp.start_date';

ELSIF
   p_view_by = 'ACT'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' BDC.campaign_name,BDMC.media_name ';
   l_sql_from := l_sql_from || ' bim_dimv_campaigns BDC, bim_dimv_media_channels bdmc, dual ';
   l_sql_where := l_sql_where || ' and BSCR.media_id = BDMC.media_id and BSCR.channel_id = BDMC.channel_id ';
   l_sql_group_by := ' group by BDC.campaign_name, BDMC.media_name ';
   l_sql_order_by := ' order by 3,2 desc ';
ELSIF
   p_view_by = 'MCH'
THEN
   l_sql_insert_stm := l_sql_insert_stm || ' BDC.Campaign_name,BMC.Channel_name ';
   l_sql_from := l_sql_from || ' bim_dimv_campaigns BDC, bim_dimv_media_channels BMC, dual ';
   l_sql_where := l_sql_where || ' and BSCR.media_id = BMC.media_id and BSCR.channel_id = BMC.channel_id ';
   l_sql_group_by := ' group by BDC.campaign_name,BMC.channel_name ';
   l_sql_order_by := ' order by 3,2 desc ';
END IF;






-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
-- dbms_OUTPUT.PUT_LINE(l_sql_group_by);
-- dbms_OUTPUT.PUT_LINE(l_sql_order_by);


/*
declare
fp  		utl_file.file_type;
location 	varchar2(100) := '/sqlcom/log/dom1151';
file_name	varchar2(50) := 'bpp.sql';
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


if p_view_by = 'PER' then
EXECUTE IMMEDIATE l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by
Using
p_start_date,
p_end_date,
p_campaign_id,
p_campaign_status_id,
p_campaign_type_id,
p_media_id,
p_channel_id,
p_market_segment_id,
p_geography_code,
p_period_type;


else
EXECUTE IMMEDIATE l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by || l_sql_order_by
Using
p_start_date,
p_end_date,
p_campaign_id,
p_campaign_status_id,
p_campaign_type_id,
p_media_id,
p_channel_id,
p_market_segment_id,
p_geography_code;

end if;


end BIM_CMP_RESP_POPULATE;


 PROCEDURE BIM_CMP_REV_POPULATE
         (
            p_campaign_id           in number     DEFAULT NULL,
            p_drill_down			in  varchar2  DEFAULT 'Y'
         )  IS

l_sql_insert_stm            varchar2(10000);
l_sql_from                  varchar2(10000);
l_sql_where                 varchar2(30000);
l_sql_group_by              varchar2(2000);
l_sql_order_by              varchar2(2000);
l_sql_outer_where           varchar2(2000);
l_view_by                   varchar2(2000);
l_subject_name              varchar2(2000);

begin
l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure2, measure3, subject_name )';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || '  sum(ccost.forecasted_revenue) , ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' sum(ccost.initiated_revenue) ,';


l_sql_insert_stm := l_sql_insert_stm
                 || ' decode(sum(ccost.initiated_revenue),0,0,((sum(ccost.initiated_revenue)-sum(ccost.forecasted_revenue))/sum(ccost.initiated_revenue))*100) ,';

l_sql_from := ' FROM BIM_CMPGN_REVCOST_SUMM CCOST, bim_campaigns_denorm denorm  , bim_dimv_campaigns dimv , dual';

--Build the where clause

l_sql_where := ' WHERE ccost.campaign_id = denorm.campaign_id and denorm.campaign_id = dimv.campaign_id ';



IF p_campaign_id IS NULL THEN
	l_sql_where:= l_sql_where|| ' and denorm .parent_campaign_id in (select campaign_id from bim_dimv_campaigns where parent_campaign_id is null  and :p_campaign_id is null ) ';
ELSE
	l_sql_where:= l_sql_where|| ' and denorm.parent_campaign_id in (select campaign_id from bim_dimv_campaigns where parent_campaign_id = :p_campaign_id ) ';
END IF;


l_sql_insert_stm := l_sql_insert_stm || ' dimv.campaign_name ';
l_sql_group_by := l_sql_group_by || ' GROUP BY dimv.campaign_name ';


-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 450, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 600, 150));
-- dbms_OUTPUT.PUT_LINE(l_sql_group_by);
-- dbms_OUTPUT.PUT_LINE(l_sql_order_by);

EXECUTE IMMEDIATE l_sql_insert_stm ||l_sql_from || l_sql_where || l_sql_group_by
Using  p_campaign_id ;

end  BIM_CMP_REV_POPULATE  ;


PROCEDURE BIM_CMP_REV_SUM_POPULATE
         (
            p_all_value                   in varchar    DEFAULT 'ALL',
            p_campaign_type_id            in varchar2   DEFAULT NULL,
            p_campaign_status_id          in number     DEFAULT NULL
         )  IS

l_sql_insert_stm            varchar2(10000);
l_sql_from                  varchar2(10000);
l_sql_where                 varchar2(30000);
l_sql_group_by              varchar2(2000);
l_sql_order_by              varchar2(2000);
l_sql_outer_where           varchar2(2000);
l_view_by                   varchar2(2000);
l_subject_name              varchar2(2000);

begin
l_sql_insert_stm := 'INSERT INTO bim_camp_acqu_summ_temp (measure1, measure2, measure3, subject_name )';

l_sql_insert_stm := l_sql_insert_stm
                 || ' SELECT ' ;

l_sql_insert_stm := l_sql_insert_stm
                 || '  sum(ccost.forecasted_revenue) , ';

l_sql_insert_stm := l_sql_insert_stm
                 || ' sum(ccost.initiated_revenue) ,';


l_sql_insert_stm := l_sql_insert_stm
                 || ' decode(sum(ccost.initiated_revenue),0,0,((sum(ccost.initiated_revenue)-sum(ccost.forecasted_revenue))/sum(ccost.initiated_revenue))*100), :p_all_value';

l_sql_from := ' FROM BIM_CMPGN_REVCOST_SUMM CCOST, bim_campaigns_denorm denorm , dual ';

--Build the where clause

l_sql_where := ' WHERE ccost.campaign_id = denorm.campaign_id AND  denorm.level_from_parent = 0 ';

IF p_campaign_type_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' And denorm.parent_campaign_type = :p_campaign_type_id ';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_type_id IS NULL ';
END IF;


IF p_campaign_status_id IS NOT NULL
THEN
    l_sql_where := l_sql_where || ' and denorm.parent_campaign_status_id = :p_campaign_status_id ';
ELSE
    l_sql_where := l_sql_where || ' and :p_campaign_status_id IS NULL ';
END IF;

l_sql_group_by := l_sql_group_by || ' GROUP BY :p_all_value ';
l_sql_order_by := l_sql_order_by || ' ORDER BY 3 DESC ' ;

-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_insert_stm, 450, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_from, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 1, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 151, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 300, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 451, 150));
-- dbms_OUTPUT.PUT_LINE(substr(l_sql_where, 600, 150));
-- dbms_OUTPUT.PUT_LINE(l_sql_group_by);
-- dbms_OUTPUT.PUT_LINE(l_sql_order_by);

EXECUTE IMMEDIATE l_sql_insert_stm ||l_sql_from || l_sql_where ||l_sql_group_by|| l_sql_order_by
Using
p_all_value
,p_campaign_type_id
,p_campaign_status_id
,p_all_value;

end  BIM_CMP_REV_SUM_POPULATE  ;


END BIM_CMP_PKG;

/
