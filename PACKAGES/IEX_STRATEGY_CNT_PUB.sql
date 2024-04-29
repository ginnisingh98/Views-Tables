--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_CNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_CNT_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpstcs.pls 120.4.12010000.5 2009/07/16 14:17:07 gnramasa ship $ */
-- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
--PROCEDURE open_strategies (
--	ERRBUF      OUT NOCOPY     VARCHAR2,
--	RETCODE     OUT NOCOPY     VARCHAR2);
PROCEDURE open_strategies (
	ERRBUF      	OUT NOCOPY     VARCHAR2,
	RETCODE     	OUT NOCOPY     VARCHAR2,
	p_ignore_switch	IN 	       VARCHAR2,
	p_strategy_mode IN   VARCHAR2 DEFAULT 'FINAL');  -- added by gnramasa for bug 8630852 13-July-09
-- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records

PROCEDURE Close_strategies (
		ERRBUF      OUT NOCOPY     VARCHAR2,
		RETCODE     OUT NOCOPY     VARCHAR2,
		p_strategy_mode       IN   VARCHAR2 DEFAULT 'FINAL');  -- added by gnramasa for bug 8630852 13-July-09


--Begin Bug#7248296 28/07/2008 barathsr
PROCEDURE process_onhold_strategies(p_strategy_mode  IN   VARCHAR2 DEFAULT 'FINAL');  -- added by gnramasa for bug 8630852 13-July-09
--End Bug#7248296 28/07/2008 barathsr

PROCEDURE Close_All_stry (
		ERRBUF      OUT NOCOPY     VARCHAR2,
		RETCODE     OUT NOCOPY     VARCHAR2);

-- Begin - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records
--PROCEDURE MAIN (
--		ERRBUF      OUT NOCOPY     VARCHAR2,
--		RETCODE     OUT NOCOPY     VARCHAR2,
--                p_trace_mode          IN  VARCHAR2);
PROCEDURE MAIN (
		ERRBUF          OUT NOCOPY     VARCHAR2,
		RETCODE     	OUT NOCOPY     VARCHAR2,
                --p_trace_mode    IN  	       VARCHAR2,Bug5022607. Fix By LKKUMAR. Removed this parameter.
                p_org_id IN number,
		p_ignore_switch	IN             VARCHAR2,
		p_strategy_mode         IN   VARCHAR2 DEFAULT 'FINAL',               -- added by gnramasa for bug 8630852 13-July-09
		p_coll_bus_level_dummy  IN   VARCHAR2 DEFAULT NULL,                  -- added by gnramasa for bug 8630852 13-July-09
		p_customer_name_low     IN   VARCHAR2 DEFAULT NULL,                  -- added by gnramasa for bug 8630852 13-July-09
		p_customer_name_high    IN   VARCHAR2 DEFAULT NULL,                  -- added by gnramasa for bug 8630852 13-July-09
		p_account_number_low    IN   VARCHAR2 DEFAULT NULL,                  -- added by gnramasa for bug 8630852 13-July-09
		p_account_number_high   IN   VARCHAR2 DEFAULT NULL,                  -- added by gnramasa for bug 8630852 13-July-09
		p_billto_location_dummy IN   VARCHAR2 DEFAULT NULL,                  -- added by gnramasa for bug 8630852 13-July-09
		p_billto_location_low   IN   VARCHAR2 DEFAULT NULL,                  -- added by gnramasa for bug 8630852 13-July-09
		p_billto_location_high  IN   VARCHAR2 DEFAULT NULL		     -- added by gnramasa for bug 8630852 13-July-09
		 );
-- End - Andre Araujo -- 01/18/2005 - 4924879 - Improve performance by selecting less records

PROCEDURE GetStrategyTempID(
		p_stry_cnt_rec in	IEX_STRATEGY_TYPE_PUB.STRY_CNT_REC_TYPE,
		x_return_status out NOCOPY varchar2,
		x_strategy_template_id out NOCOPY number);

PROCEDURE write_log(mesg_level IN NUMBER, mesg IN VARCHAR2);

l_MsgLevel  NUMBER;
l_DefaultTempID NUMBER;
l_DefaultStrategyLevel NUMBER := 50;
-- Start for bug # 5487449 on 28/08/2006 by gnramasa
l_StrategyLevelName varchar2(255);
l_DefaultTempName varchar2(255);
l_EnabledFlag varchar2(15);
l_default_rs_id number;
l_UserName  varchar2(100);
l_SourceName  varchar2(360);
-- End for bug # 5487449 on 28/08/2006 by gnramasa

END IEX_STRATEGY_CNT_PUB;

/
