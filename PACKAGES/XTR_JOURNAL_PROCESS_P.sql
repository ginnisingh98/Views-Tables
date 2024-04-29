--------------------------------------------------------
--  DDL for Package XTR_JOURNAL_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_JOURNAL_PROCESS_P" AUTHID CURRENT_USER as
/* $Header: xtrjrnls.pls 120.7 2006/07/14 06:35:44 eaggarwa ship $ */
----------------------------------------------------------------------------------------------------------------

--
-- GLOBAL VARIABLES
--

-- CONTEXT: XTR_JOURNAL_PROCESS_P.Do_Journal_Process
--    Run-Time Parameters
--
G_company_code			XTR_PARTY_INFO.party_code%TYPE;
--G_cutoff_date			XTR_DEAL_DATE_AMOUNTS.amount_date%TYPE;
G_batch_id			XTR_BATCHES.batch_id%TYPE;
G_period_end			XTR_DEAL_DATE_AMOUNTS.amount_date%TYPE;
G_set_of_books_id		GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
G_suspense_ccid			XTR_GL_REFERENCES.code_combination_id%TYPE;

-- CONTEXT: XTR_JOUNRAL_PROCESS_P.Update_Journals

G_user				VARCHAR2(30);

FUNCTION GET_CLOSED_PERIOD_PARAM
		(in_company		IN VARCHAR2) RETURN VARCHAR2;


PROCEDURE DO_JOURNAL_PROCESS
		(errbuf			OUT NOCOPY VARCHAR2,
		 retcode		OUT NOCOPY NUMBER,
		 p_source_option	IN  VARCHAR2,
		 p_company_code		IN  VARCHAR2,
		 p_batch_id_from     	IN  NUMBER,
		 p_batch_id_to		IN  NUMBER,
		 p_cutoff_date		IN  DATE);

FUNCTION GEN_JOURNALS
		(in_source_option	IN VARCHAR2,
		 in_company		IN VARCHAR2,
		 in_batch_id		IN NUMBER,
		 in_period_end		IN DATE,
                 in_upgrade_batch       IN VARCHAR2) RETURN NUMBER;	-- 1336492. Chg ret type to accomodate warnings.

PROCEDURE UPDATE_JOURNALS(l_deal_nos  IN NUMBER,
                          l_trans_nos IN NUMBER,
                          l_deal_type IN VARCHAR2);

-- Procedure journals was added for bug 2404342 - Flex Journals.

PROCEDURE JOURNALS
		(errbuf			OUT NOCOPY VARCHAR2,
		 retcode		OUT NOCOPY NUMBER,
		 p_source_option	IN  VARCHAR2,
		 p_company_code		IN  VARCHAR2,
		 p_batch_id_from	IN  NUMBER,
		 p_batch_id_to		IN  NUMBER,
		 p_cutoff_date		IN  VARCHAR2,
		 p_dummy_date		IN  VARCHAR2,
		 p_processing_option	IN  VARCHAR2,
		 p_dummy_proc_opt	IN  VARCHAR2,
		 p_closed_periods	IN  VARCHAR2,
		 p_incl_transferred	IN  VARCHAR2);

-- Bug 4504734  Removed procedure get_next_open_start_date
-- Added the new override procedure for Bug 4639287
PROCEDURE JOURNALS
		(errbuf			OUT NOCOPY VARCHAR2,
		 retcode		OUT NOCOPY NUMBER,
		 p_source_option	IN  VARCHAR2,
		 p_company_code		IN  VARCHAR2,
		 p_batch_id_from	IN  NUMBER,
		 p_batch_id_to		IN  NUMBER,
		 p_cutoff_date		IN  VARCHAR2,
		 p_dummy_date		IN  VARCHAR2,
		 p_processing_option	IN  VARCHAR2,
		 p_dummy_proc_opt	IN  VARCHAR2,
		 p_closed_periods	IN  VARCHAR2,
                 p_incl_transferred     IN  VARCHAR2,
                 p_multiple_acct        IN VARCHAR2 );  -- Added this parameter Bug 4639287

G_gen_journal_retcode NUMBER := 0; --bug 2804548
----------------------------------------------------------------------------------------------------------------
end XTR_JOURNAL_PROCESS_P;

 

/
