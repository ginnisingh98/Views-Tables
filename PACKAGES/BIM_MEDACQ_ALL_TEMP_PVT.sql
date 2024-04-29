--------------------------------------------------------
--  DDL for Package BIM_MEDACQ_ALL_TEMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_MEDACQ_ALL_TEMP_PVT" AUTHID CURRENT_USER AS
/* $Header: bimvmqas.pls 115.2 2000/03/03 20:36:11 pkm ship  $ */

PROCEDURE populate_temp_table
         (
            p_campaign_id                 number    DEFAULT NULL,
            p_campaign_status_id          number    DEFAULT NULL,
            p_campaign_type               varchar2  DEFAULT NULL,
            p_period_type                 varchar2  DEFAULT NULL,
            p_start_date                  date      DEFAULT NULL,
            p_end_date                    date      DEFAULT NULL,
            p_media_type                  varchar2  DEFAULT NULL,
            p_channel_id                  varchar2  DEFAULT NULL,
            p_market_segment_id           number    DEFAULT NULL,
            p_sales_channel_code          varchar2  DEFAULT NULL,
            p_interest_type_id            number    DEFAULT NULL,
            p_primary_interest_code_id    number    DEFAULT NULL,
            p_secondary_interest_code_id  number    DEFAULT NULL,
            p_geography_code              varchar2  DEFAULT NULL,
            p_view_by                     varchar2  DEFAULT NULL
         ) ;

END BIM_MEDACQ_ALL_TEMP_PVT ;

 

/
