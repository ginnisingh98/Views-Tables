--------------------------------------------------------
--  DDL for Package PV_PARTNER_TREND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_TREND_PVT" AUTHID CURRENT_USER AS
/* $Header: pvptrnds.pls 120.1 2005/09/01 10:46:40 appldev ship $ */

g_RETCODE            VARCHAR2(10) := '0';
g_common_currency    VARCHAR2(15);
g_period_set_name    VARCHAR2(15);
g_log_to_file        VARCHAR2(5)  := 'Y';
g_module_name        VARCHAR2(60);

PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
);

PROCEDURE refresh_partner_trend ( ERRBUF              OUT  NOCOPY VARCHAR2,
                                  RETCODE             OUT  NOCOPY VARCHAR2,
                                  p_from_date         IN VARCHAR2,
                                  p_to_date           IN VARCHAR2,
                                  p_new_partners_flag IN VARCHAR2 := 'N',
                                  p_ignore_refresh_interval IN VARCHAR2 DEFAULT 'N',
                                  p_partner_id        IN NUMBER DEFAULT NULL,
                                  p_log_to_file       IN VARCHAR2 := 'Y');

FUNCTION kpi_oppty_cnt_offset(p_salesforce_id number) return number;

FUNCTION kpi_oppty_amt_offset(p_salesforce_id number, p_currency_code varchar2) return number;

END;

 

/
