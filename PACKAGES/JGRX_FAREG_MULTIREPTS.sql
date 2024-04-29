--------------------------------------------------------
--  DDL for Package JGRX_FAREG_MULTIREPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JGRX_FAREG_MULTIREPTS" AUTHID CURRENT_USER AS
/* $Header: jgrxfrms.pls 115.0 2000/08/25 16:05:02 pkm ship   $ */

   PROCEDURE get_format
            (errbuf    OUT VARCHAR2,
             retcode   OUT NUMBER,
             p_asset_concurr_name  VARCHAR2,
             p_asset_report_id     NUMBER,
             p_asset_attribute_set VARCHAR2,
             p_rtmnt_concurr_name  VARCHAR2,
             p_rtmnt_report_id     NUMBER,
             p_rtmnt_attribute_set VARCHAR2,
             p_book                VARCHAR2,
             p_from_period         VARCHAR2,
             p_to_period           VARCHAR2,
             p_dummy               NUMBER,
             p_major_category      VARCHAR2,
             p_minor_category      VARCHAR2,
             p_debug_flag          VARCHAR2,
             p_sql_trace           VARCHAR2);

END JGRX_FAREG_MULTIREPTS;

 

/
