--------------------------------------------------------
--  DDL for Package BIL_DO_L1_OPPTY_SUMRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_DO_L1_OPPTY_SUMRY_PKG" AUTHID CURRENT_USER as
/* $Header: bilopl1s.pls 115.3 2002/01/29 13:56:10 pkm ship      $ */

PROCEDURE Refresh_Data( ERRBUF      OUT  VARCHAR2
                      ,RETCODE      OUT  VARCHAR2
                      ,p_degree      IN  NUMBER   DEFAULT 4
                      ,p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
                      ,p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
                        );

PROCEDURE Refresh_Data_Range(ERRBUF          OUT  VARCHAR2
                            ,RETCODE         OUT  VARCHAR2
                            ,p_start_date    IN VARCHAR2
                            ,p_end_date      IN VARCHAR2
                            ,p_degree        IN  NUMBER   DEFAULT 4
                            ,p_truncate_flag IN VARCHAR2 DEFAULT 'N'
                            ,p_debug_mode    IN  VARCHAR2 DEFAULT 'N'
                            ,p_trace_mode    IN  VARCHAR2 DEFAULT 'N'
                           );

END BIL_DO_L1_OPPTY_SUMRY_PKG;

 

/
