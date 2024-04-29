--------------------------------------------------------
--  DDL for Package BIM_ACQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_ACQ_PKG" AUTHID CURRENT_USER AS
/*$Header: bimacqus.pls 115.6 2001/04/10 18:19:54 pkm ship     $*/
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
         )  ;

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
         )  ;


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
         )  ;

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
         )  ;


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
         )  ;


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
         )  ;

END BIM_ACQ_PKG ;

 

/
