--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_AGING_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_AGING_CONC_PUB" AUTHID CURRENT_USER AS
/* $Header: asxslacs.pls 115.2 2002/11/06 00:49:39 appldev ship $ */

PROCEDURE Run_Aging_Main(
     ERRBUF                  OUT VARCHAR2,
     RETCODE                 OUT VARCHAR2,
     p_trace_mode            IN  VARCHAR2,
     p_debug_mode            IN  VARCHAR2);


PROCEDURE Run_Aging_Workflow(
     ERRBUF                  OUT VARCHAR2,
     RETCODE                 OUT VARCHAR2,
     p_trace_mode            IN  VARCHAR2,
     p_debug_mode            IN  VARCHAR2,
     p_parent_request_id     IN NUMBER,
     p_sequence_number       IN NUMBER,
     p_sales_lead_id         IN NUMBER );

END AS_SALES_LEAD_AGING_CONC_PUB;


 

/
