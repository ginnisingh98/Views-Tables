--------------------------------------------------------
--  DDL for Package ECE_SPSO_TRANS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_SPSO_TRANS2" AUTHID CURRENT_USER AS
-- $Header: ECSPSO2S.pls 120.2 2005/06/30 11:24:12 appldev ship $
/*  Bug 2064311
    The  parameter batch_id has been added to the
    procedure populate_supplier_sched_api2
    to improve performance
*/



 PROCEDURE POPULATE_SUPPLIER_SCHED_API2
	(
	p_communication_method	IN  VARCHAR2,	-- EDI
	p_transaction_type	IN  VARCHAR2,	-- plan SPSO, ship SSSO
	p_document_type		IN  VARCHAR2,	-- plan SPS, ship SSS
	p_run_id		IN  NUMBER,
	p_schedule_id		IN  INTEGER  default 0,
        p_batch_id              IN  NUMBER

/*
	p_communication_method	IN  VARCHAR2 := 'EDI',	-- EDI
	p_transaction_type	IN  VARCHAR2 := 'SPSO',	-- plan SPSO, ship SSSO
	p_document_type		IN  VARCHAR2 := 'SPS',	-- plan SPS, ship SSS
	p_run_id		IN  NUMBER   := 0,
	p_schedule_id		IN  INTEGER  := 0
*/
);


END ECE_SPSO_TRANS2;		-- end of package body

 

/
