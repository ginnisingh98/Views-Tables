--------------------------------------------------------
--  DDL for Package XTR_CLEAR_JOURNAL_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_CLEAR_JOURNAL_PROCESS_P" AUTHID CURRENT_USER as
/* $Header: xtrcljns.pls 120.1 2005/06/29 06:01:43 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------

--  CONTEXT: CALL = XTR_CLEAR_JOURNAL_PROCESS_P.Clear_Journal_Process
--
--    Run-Time Parameters
--
G_company_code			XTR_PARTY_INFO.party_code%TYPE;
G_batch_id                      XTR_BATCHES.batch_id%TYPE;
G_start_date			XTR_JOURNALS.created_on%TYPE;
G_end_date			XTR_JOURNALS.created_on%TYPE;
--G_user				VARCHAR2(30);

PROCEDURE CLEAR_JOURNAL_PROCESS
		(errbuf			OUT NOCOPY VARCHAR2,
		 retcode		OUT NOCOPY NUMBER,
		 p_company_code		IN VARCHAR2,
                 p_batch_id_from        IN NUMBER,
		 p_batch_id_to		IN NUMBER);

PROCEDURE CLEAR_JOURNALS
		(in_company	IN VARCHAR2,
		 in_batch_id    IN NUMBER);

----------------------------------------------------------------------------------------------------------------
end XTR_CLEAR_JOURNAL_PROCESS_P;

 

/
