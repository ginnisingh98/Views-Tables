--------------------------------------------------------
--  DDL for Package JG_RX_FAREG_MULTIREPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_RX_FAREG_MULTIREPTS" AUTHID CURRENT_USER AS
/* $Header: jgrxfrms.pls 115.6 2002/11/18 14:17:02 arimai ship $ */

   PROCEDURE get_format
            (errbuf    OUT NOCOPY VARCHAR2,
             retcode   OUT NOCOPY NUMBER,
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

END JG_RX_FAREG_MULTIREPTS;

 

/
