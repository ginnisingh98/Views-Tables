--------------------------------------------------------
--  DDL for Package BIL_DO_L1_LD_OPPTY_DLY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_DO_L1_LD_OPPTY_DLY_PKG" AUTHID CURRENT_USER AS
/* $Header: billdl1s.pls 115.10 2002/01/29 13:56:06 pkm ship      $ */

PROCEDURE Refresh_Data (
       ERRBUF        OUT VARCHAR2
      ,RETCODE       OUT VARCHAR2
      ,p_degree      IN  VARCHAR2 DEFAULT '4'
      ,p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
      ,p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
    ) ;


PROCEDURE Initial_Load
    (       ERRBUF          OUT VARCHAR2
           ,RETCODE         OUT VARCHAR2
           ,p_start_date    IN  VARCHAR2
           ,p_end_date      IN  VARCHAR2
           ,p_degree        IN  VARCHAR2 DEFAULT '4'
           ,p_truncate_flag IN  VARCHAR2 DEFAULT 'N'
           ,p_debug_mode    IN  VARCHAR2 DEFAULT 'N'
           ,p_trace_mode    IN  VARCHAR2 DEFAULT 'N'
    );

END BIL_DO_L1_LD_OPPTY_DLY_PKG;

 

/
