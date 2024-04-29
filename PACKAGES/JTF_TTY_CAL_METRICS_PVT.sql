--------------------------------------------------------
--  DDL for Package JTF_TTY_CAL_METRICS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_CAL_METRICS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvcams.pls 120.0 2005/06/02 18:22:06 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_CAL_METRICS_PVT
--    PURPOSE : This package calculates the territory alignment metrics for all
--              named accounts
--
--      Procedures:
--         (see below for specification)
--
--
--
--
--    NOTES
--
--
--
--
--    HISTORY
--      08/08/03    SP         CREATED
--
--
--    End of Comments
--
  Procedure calculate_acct_metrics
  ( ERRBUF          OUT NOCOPY  VARCHAR2
   ,RETCODE         OUT NOCOPY  VARCHAR2
   ,p_metric_code   IN          VARCHAR2
   ,p_debug_flag    IN          VARCHAR2
  );

END  JTF_TTY_CAL_METRICS_PVT;

 

/
