--------------------------------------------------------
--  DDL for Package MSC_ATP_24X7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_24X7" AUTHID CURRENT_USER AS
/* $Header: MSCTATPS.pls 120.1 2007/12/12 10:42:25 sbnaik ship $  */

-- Globals for Calculation of threshold
G_TF7_SO_THRESHOLD              NUMBER := 0;
G_TF7_TOTAL_RECORDS             NUMBER := 0;
G_TF7_TOTAL_TIME                NUMBER := 0;
G_TF7_DOWNTIME                  NUMBER := NVL (FND_PROFILE.value ('MSC_ATP_SYNC_DOWNTIME'), 0) * 60;
G_TF7_EXTEND_SYNC               NUMBER := 0;
G_TF7_MAX_EXTEND_SYNC           NUMBER := 600; -- Extend Sync for 10 minutes

-- Summary Flag Values
G_SF_SYNC_NOT_RUN               CONSTANT INTEGER := 4;
G_SF_SYNC_RUNNING               CONSTANT INTEGER := 5;
G_SF_SYNC_SUCCESS               CONSTANT INTEGER := 6;
G_SF_SYNC_ERROR                 CONSTANT INTEGER := 7;
G_SF_SYNC_DOWNTIME              CONSTANT  INTEGER := 8;

-- Wrap around for timer - decimal value of 0xFFFFFFFF
G_ATP_TIMER_MAX_VALUE           CONSTANT NUMBER := 4294967295;

-- Debug Flag
atp_debug_flag                  VARCHAR2(1) := ORDER_SCH_WB.MR_DEBUG;

---------------------------------------------------------------------
--  Procedure Definitions
--
---------------------------------------------------------------------

PROCEDURE Call_Synchronize (
        ERRBUF              OUT NOCOPY      VARCHAR2,
        RETCODE             OUT NOCOPY      NUMBER,
        p_old_plan_id       IN              NUMBER
);

PROCEDURE conc_log  (
        buf                 IN              VARCHAR2
);

PROCEDURE conc_debug (
        buf                 IN              VARCHAR2
);

PROCEDURE Parse_Sales_Order_Number (
        p_order_number_string   IN           varchar2,
        p_order_number          IN OUT NOCOPY      number
);

END MSC_ATP_24x7;

/
