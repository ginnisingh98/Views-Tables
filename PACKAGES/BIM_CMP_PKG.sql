--------------------------------------------------------
--  DDL for Package BIM_CMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_CMP_PKG" AUTHID CURRENT_USER AS
/*$Header: bimcmpgs.pls 115.10 2001/01/23 14:40:27 pkm ship        $*/
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
         )  ;

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
         )  ;

PROCEDURE BIM_CMP_COST_SUM_POPULATE
         (
            p_all_value                   in varchar2 DEFAULT NULL,
            p_campaign_status_id          in number   DEFAULT NULL,
            p_campaign_type_id            in varchar2 DEFAULT NULL,
            p_media_id                    in number   DEFAULT NULL,
            p_channel_id                  in varchar2 DEFAULT NULL,
            p_view_by                     in varchar2 DEFAULT NULL
         )  ;

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
         )  ;

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
         )  ;

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
         ) ;

PROCEDURE BIM_CMP_REV_POPULATE
         (
            p_campaign_id                 in number     DEFAULT NULL,
            p_drill_down			      in  varchar2  DEFAULT 'Y'
         )  ;

 PROCEDURE BIM_CMP_REV_SUM_POPULATE
         (
            p_all_value                   in varchar    DEFAULT 'ALL',
            p_campaign_type_id            in varchar2   DEFAULT NULL,
            p_campaign_status_id          in number     DEFAULT NULL
         )  ;

END BIM_CMP_PKG;

 

/
