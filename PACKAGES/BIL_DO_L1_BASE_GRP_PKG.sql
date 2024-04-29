--------------------------------------------------------
--  DDL for Package BIL_DO_L1_BASE_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_DO_L1_BASE_GRP_PKG" AUTHID CURRENT_USER as
/* $Header: bilgrl1s.pls 115.2 2002/01/29 13:55:59 pkm ship      $ */

PROCEDURE Collect_Temp_Data( ERRBUF        OUT VARCHAR2
                           , RETCODE       OUT VARCHAR2
                           , p_degree      IN  NUMBER   DEFAULT 4
                           , p_debug_mode  IN  VARCHAR2 DEFAULT 'N'
                           , p_trace_mode  IN  VARCHAR2 DEFAULT 'N'
                           );

END BIL_DO_L1_BASE_GRP_PKG;

 

/
