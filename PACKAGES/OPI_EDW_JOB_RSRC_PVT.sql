--------------------------------------------------------
--  DDL for Package OPI_EDW_JOB_RSRC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_JOB_RSRC_PVT" AUTHID CURRENT_USER as
/* $Header: OPIMJRPS.pls 115.2 2002/05/04 00:15:43 rjin noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE

   FUNCTION GET_ACT_STRT_DATE(
		p_organization_id NUMBER,
		p_wip_entity_id NUMBER,
		p_repetitive_schedule_id NUMBER,
		p_operation_seq_num NUMBER
		) RETURN DATE;

   FUNCTION GET_ACT_CMPL_DATE(
		p_organization_id NUMBER,
		p_wip_entity_id NUMBER,
		p_repetitive_schedule_id NUMBER,
		p_operation_seq_num NUMBER
		) RETURN DATE;
end OPI_EDW_JOB_RSRC_PVT ;

 

/
