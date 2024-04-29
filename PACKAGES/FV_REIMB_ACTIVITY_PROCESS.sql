--------------------------------------------------------
--  DDL for Package FV_REIMB_ACTIVITY_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_REIMB_ACTIVITY_PROCESS" AUTHID CURRENT_USER as
-- $Header: FVREACRS.pls 120.0.12010000.3 2009/07/28 18:47:42 schakkin noship $


PROCEDURE main
( p_errbuf    OUT NOCOPY VARCHAR2,
 p_retcode   OUT NOCOPY NUMBER,
 p_ledger_id IN NUMBER,
 P_COA_ID IN NUMBER,
 p_period_name IN VARCHAR2,
 p_flex_low    IN VARCHAR2,
 p_flex_high   IN VARCHAR2,
 p_report_id IN VARCHAR2,
 p_attribute_set IN VARCHAR2,
 p_output_format  IN VARCHAR2
);




END   fv_reimb_activity_process;

/
