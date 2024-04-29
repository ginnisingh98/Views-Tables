--------------------------------------------------------
--  DDL for Package BIM_TSGMT_PERF_TEMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_TSGMT_PERF_TEMP_PVT" AUTHID CURRENT_USER AS
/* $Header: bimvtsps.pls 115.2 2000/03/03 20:36:31 pkm ship  $ */

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
            p_drill_down                  varchar2  default 'N'
         ) ;

END BIM_TSGMT_PERF_TEMP_PVT ;

 

/
