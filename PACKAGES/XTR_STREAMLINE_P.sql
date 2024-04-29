--------------------------------------------------------
--  DDL for Package XTR_STREAMLINE_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_STREAMLINE_P" AUTHID CURRENT_USER as
/* $Header: xtrstrms.pls 120.4 2005/11/24 09:28:42 badiredd ship $ */
-------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-- Constants --
-----------------------------------------------------------------------------------
 C_AUTH_YES    constant VARCHAR2(1)   := 'Y';


 -- Event Codes  --------------------------------------------------------------
 C_RATES       constant VARCHAR2(10)  := 'RATES';
 C_REVAL       constant VARCHAR2(10)  := 'REVAL';
 C_RETROET     constant VARCHAR2(10)  := 'RETROET';      -- 3378028 FAS
 C_ACCRUAL     constant VARCHAR2(10)  := 'ACCRUAL';
 C_JOURNAL     constant VARCHAR2(10)  := 'JRNLGN';
 C_GENERATE    constant VARCHAR2(10)  := 'GENERATE';
 C_TRANSFER    constant VARCHAR2(10)  := 'TRANSFER';


 -- Company Parameters --------------------------------------------------------
 C_REVAL_PARAM constant VARCHAR2(15)  := 'ACCNT_BPSTP';
 C_RETRO_PARAM constant VARCHAR2(15)  := 'ACCNT_BTEST';  -- 3378028 FAS


 -- Process Options --------------------------------------------------------------
 -- 3378028 FAS - Obsolete Options
 -- C_PROCESS_REVAL       constant VARCHAR2(30)  := '1REVAL';
 -- C_PROCESS_ACCRUAL     constant VARCHAR2(30)  := '2ACCRUAL';
 -- C_PROCESS_JOURNAL     constant VARCHAR2(30)  := '3JRNLGEN';
 -- C_PROCESS_TRANSFER    constant VARCHAR2(30)  := '4JRNLXFER';
 -- 3378028 FAS - New Options
 C_PROCESS_REVAL        constant VARCHAR2(30)  := '10REVAL';
 C_PROCESS_RETROET      constant VARCHAR2(30)  := '20RETROET';
 C_PROCESS_ACCRUAL      constant VARCHAR2(30)  := '30ACCRUAL';
 C_PROCESS_JOURNAL      constant VARCHAR2(30)  := '40JRNLGEN';
 C_PROCESS_TRANSFER     constant VARCHAR2(30)  := '50JRNLXFER';


 -- Error Messages ---------------------------------------------------------------
 C_INCOMPLETE_REVAL     constant VARCHAR2(30)  := 'XTR_INCOMPLETE_REVAL';      -- 1
 C_NO_REVAL_DATA        constant VARCHAR2(30)  := 'XTR_NO_REVAL_DATA';         -- 2
 C_NO_ACCRUAL_DATA      constant VARCHAR2(30)  := 'XTR_NO_ACCRUAL_DATA';       -- 3
 C_NO_JOURNAL_DATA      constant VARCHAR2(30)  := 'XTR_NO_JOURNAL_DATA';       -- 4
 C_LOCKED_REVAL         constant VARCHAR2(30)  := 'XTR_LOCKED_REVAL';          -- 5
 C_LOCKED_ACCRUAL       constant VARCHAR2(30)  := 'XTR_LOCKED_ACCRUAL';        -- 6
 C_LOCKED_JOURNAL       constant VARCHAR2(30)  := 'XTR_LOCKED_JOURNAL';        -- 7
 C_LOCKED_BATCH         constant VARCHAR2(30)  := 'XTR_LOCKED_BATCH';          -- 8
 C_INAUGURAL_MISSING    constant VARCHAR2(30)  := 'XTR_INAUGURAL_MISSING';     -- 9
 C_INAUGURAL_TRANSFER   constant VARCHAR2(30)  := 'XTR_INAUGURAL_TRANSFER';    -- 10
 C_CUTOFF_DATE_ERROR    constant VARCHAR2(30)  := 'XTR_CUTOFF_DATE_ERROR';     -- 11
 C_COMPLETED_BATCH      constant VARCHAR2(30)  := 'XTR_COMPLETED_BATCH';       -- 12
 C_BATCH_ERROR          constant VARCHAR2(30)  := 'XTR_BATCH_ERROR';           -- 13
 C_NO_BATCH             constant VARCHAR2(30)  := 'XTR_NO_BATCH';              -- 14
 C_NEW_BATCH            constant VARCHAR2(30)  := 'XTR_NEW_BATCH';             -- 15
 C_SUBMIT_FAILURE       constant VARCHAR2(30)  := 'XTR_SUBMIT_FAILURE';        -- 16
 C_SUBMIT_REQUEST       constant VARCHAR2(30)  := 'XTR_SUBMIT_REQUEST';        -- 17
 C_SUBPROCESS_REVAL     constant VARCHAR2(30)  := 'XTR_SUBPROCESS_REVAL';      -- 18
 C_SUBPROCESS_ACCRUAL   constant VARCHAR2(30)  := 'XTR_SUBPROCESS_ACCRUAL';    -- 19
 C_SUBPROCESS_JOURNAL   constant VARCHAR2(30)  := 'XTR_SUBPROCESS_JOURNAL';    -- 20
 C_SUBPROCESS_TRANSFER  constant VARCHAR2(30)  := 'XTR_SUBPROCESS_TRANSFER';   -- 21
 C_GENERATED_RATES      constant VARCHAR2(30)  := 'XTR_GENERATED_RATES';       -- 22
 C_GENERATED_REVAL      constant VARCHAR2(30)  := 'XTR_GENERATED_REVAL';       -- 23
 C_GENERATED_ACCRUAL    constant VARCHAR2(30)  := 'XTR_GENERATED_ACCRUAL';     -- 24
 C_GENERATED_JOURNAL    constant VARCHAR2(30)  := 'XTR_GENERATED_JOURNAL';     -- 25
 C_AUTHORIZED_REVAL     constant VARCHAR2(30)  := 'XTR_AUTHORIZED_REVAL';      -- 26
 C_AUTHORIZED_ACCRUAL   constant VARCHAR2(30)  := 'XTR_AUTHORIZED_ACCRUAL';    -- 27
 C_TRANSFERRED_JOURNAL  constant VARCHAR2(30)  := 'XTR_TRANSFERRED_JOURNAL';   -- 28
 C_MISSING_REVAL        constant VARCHAR2(30)  := 'XTR_MISSING_REVAL';         -- 29
 C_MISSING_ACCRUAL      constant VARCHAR2(30)  := 'XTR_MISSING_ACCRUAL';       -- 30
 C_MISSING_JOURNAL      constant VARCHAR2(30)  := 'XTR_MISSING_JOURNAL';       -- 31
 C_TOTAL_SUBMIT         constant VARCHAR2(30)  := 'XTR_TOTAL_SUBMIT';          -- 32
 C_TOTAL_FAIL           constant VARCHAR2(30)  := 'XTR_TOTAL_FAIL';            -- 33
 C_TOTAL_COMPANY        constant VARCHAR2(30)  := 'XTR_TOTAL_COMPANY';         -- 34
 C_COMPANY_NO_REVAL     constant VARCHAR2(30)  := 'XTR_COMPANY_NO_REVAL';      -- 35
 -- 3378028 FAS
 C_INCOMPLETE_RETROET   constant VARCHAR2(30)  := 'XTR_INCOMPLETE_RETROET';    -- 36
 C_NO_RETROET_DATA      constant VARCHAR2(30)  := 'XTR_NO_RETROET_DATA';       -- 37
 C_LOCKED_RETROET       constant VARCHAR2(30)  := 'XTR_LOCKED_RETROET';        -- 38
 C_SUBPROCESS_RETROET   constant VARCHAR2(30)  := 'XTR_SUBPROCESS_RETROET';    -- 39
 C_GENERATED_RETROET    constant VARCHAR2(30)  := 'XTR_GENERATED_RETROET';     -- 40
 C_AUTHORIZED_RETROET   constant VARCHAR2(30)  := 'XTR_AUTHORIZED_RETROET';    -- 41
 C_MISSING_RETROET      constant VARCHAR2(30)  := 'XTR_MISSING_RETROET';       -- 42
 C_COMPANY_NO_RETROET   constant VARCHAR2(30)  := 'XTR_COMPANY_NO_RETROET';    -- 43
 C_COMPANY_SKIP_RETROET constant VARCHAR2(30)  := 'XTR_COMPANY_SKIP_RETROET';  -- 44
 C_INVALID_STRM_PROCESS constant VARCHAR2(30)  := 'XTR_INVALID_STRM_PROCESS';  -- 45

 G_MULTIPLE_ACCT     VARCHAR2(10) := 'ALLOW'; -- Bug 4639287

-----------------------------------------------------------------------------------
-- Exceptions --
-----------------------------------------------------------------------------------
 e_record_locked  EXCEPTION;
 PRAGMA EXCEPTION_INIT(e_record_locked, -54);


-----------------------------------------------------------------------------------
-- Functions --
-----------------------------------------------------------------------------------

 FUNCTION REVAL_DETAILS_INCOMPLETE (p_company     IN VARCHAR2,
                                    p_batch_start IN DATE,
                                    p_batch_end   IN DATE,
                                    p_batch_id    IN NUMBER) RETURN BOOLEAN;

 -- 3378028 FAS
 FUNCTION RETRO_DETAILS_INCOMPLETE (p_company     IN VARCHAR2,
                                    p_batch_start IN DATE,
                                    p_batch_end   IN DATE,
                                    p_batch_id    IN NUMBER) RETURN BOOLEAN;

 FUNCTION GET_EVENT_STATUS (p_company     IN VARCHAR2,
                            p_batch_id    IN NUMBER,
                            p_batch_BED   IN DATE,     -- Batch End Date
                            p_event       IN VARCHAR2,
                            p_authorize   IN VARCHAR2) RETURN BOOLEAN;

 FUNCTION EVENT_EXISTS (p_company   IN VARCHAR2,
                        p_batch_id  IN NUMBER,
                        p_batch_BED IN DATE,
                        p_event     IN VARCHAR2) RETURN BOOLEAN;

 FUNCTION EVENT_AUTHORIZED (p_company   IN VARCHAR2,
                            p_batch_id  IN NUMBER,
                            p_event     IN VARCHAR2) RETURN BOOLEAN;

 FUNCTION GET_PARTY_CREATED_ON (p_company   IN VARCHAR2) RETURN DATE;


 FUNCTION LOCK_BATCH (p_batch_id        IN NUMBER,
                      p_company         IN VARCHAR2,
                      p_no_data_error   IN VARCHAR2,
                      p_locking_error   IN VARCHAR2) RETURN NUMBER;

 FUNCTION LOCK_EVENT (p_batch_id        IN NUMBER,
                      p_event           IN VARCHAR2,
                      p_authorized      IN VARCHAR2,
                      p_no_data_error   IN VARCHAR2,
                      p_locking_error   IN VARCHAR2) RETURN NUMBER;

 FUNCTION CHK_ELIGIBLE_COMPANY (p_company       IN  VARCHAR2,
                                p_cutoff_date   IN  DATE,
                                p_do_reval      IN  VARCHAR2,
                                p_do_retro      IN  VARCHAR2,  -- 3378028 FAS
                                p_start_process IN  VARCHAR2,
                                p_end_process   IN  VARCHAR2) RETURN NUMBER;

-----------------------------------------------------------------------------------
-- Procedures --
-----------------------------------------------------------------------------------

 PROCEDURE GET_PREV_NORMAL_BATCH (p_company        IN  VARCHAR2,
                                  p_curr_BED       IN  DATE,
                                  p_prev_BID       OUT NOCOPY NUMBER,
                                  p_prev_BED       OUT NOCOPY DATE);

 PROCEDURE GET_LATEST_BATCH (p_company        IN  VARCHAR2,
                             p_batch_id       OUT NOCOPY NUMBER,
                             p_batch_start    OUT NOCOPY DATE,
                             p_batch_end      OUT NOCOPY DATE,
                             p_gl_group_id    OUT NOCOPY NUMBER,
                             p_upgrade_batch  OUT NOCOPY VARCHAR2);

 PROCEDURE GENERATE_REVAL_RATES (p_company          IN      VARCHAR2,
                                 p_batch_start      IN      DATE,
                                 p_batch_end        IN      DATE,
                                 p_prev_batch_id    IN      NUMBER,
                                 p_batch_id         IN  OUT NOCOPY NUMBER,
                                 p_retcode              OUT NOCOPY NUMBER);

 PROCEDURE GENERATE_REVAL_DETAILS (p_retcode       OUT NOCOPY NUMBER,
                                   p_company       IN  VARCHAR2,
                                   p_batch_start   IN  DATE,
                                   p_batch_end     IN  DATE,
                                   p_batch_id      IN  NUMBER,
                                   p_prev_batch_id IN  NUMBER);

 PROCEDURE AUTHORIZE_REVAL_EVENT (p_retcode       OUT NOCOPY NUMBER,
                                  p_company       IN  VARCHAR2,
                                  p_batch_id      IN  NUMBER,
                                  p_prev_batch_id IN  NUMBER);

 PROCEDURE GENERATE_RETRO_DETAILS (p_retcode       OUT NOCOPY NUMBER,
                                   p_company       IN  VARCHAR2,
                                   p_batch_start   IN  DATE,
                                   p_batch_end     IN  DATE,
                                   p_batch_id      IN  NUMBER,
                                   p_prev_batch_id IN  NUMBER);

 PROCEDURE AUTHORIZE_RETRO_EVENT (p_retcode       OUT NOCOPY NUMBER,
                                  p_company       IN  VARCHAR2,
                                  p_batch_id      IN  NUMBER,
                                  p_prev_batch_id IN  NUMBER);

 PROCEDURE GENERATE_ACCRUAL_DETAILS (p_retcode       OUT NOCOPY NUMBER,
                                     p_company       IN  VARCHAR2,
                                     p_do_reval      IN  VARCHAR2,
                                     p_do_retro      IN  VARCHAR2,    -- 3378028 FAS
                                     p_batch_start   IN  DATE,
                                     p_batch_end     IN  DATE,
                                     p_batch_id      IN OUT  NOCOPY NUMBER,  -- do not pass batch id for new batch
                                     p_prev_batch_id IN  NUMBER);

 PROCEDURE AUTHORIZE_ACCRUAL_EVENT (p_retcode       OUT NOCOPY NUMBER,
                                    p_company       IN  VARCHAR2,
                                    p_batch_id      IN  NUMBER,
                                    p_prev_batch_id IN  NUMBER);

 PROCEDURE GENERATE_JOURNAL_DETAILS (p_retcode        OUT NOCOPY NUMBER,
                                     p_company        IN  VARCHAR2,
                                     p_batch_id       IN  NUMBER,
                                     p_prev_batch_id  IN  NUMBER);

 PROCEDURE TRANSFER_JOURNALS (p_retcode        OUT NOCOPY NUMBER,
                              p_company        IN  VARCHAR2,
                              p_batch_id       IN  NUMBER,
                              p_prev_batch_id  IN  NUMBER,
                              p_closed_periods IN  VARCHAR2);

 PROCEDURE REVAL_SUBPROCESS (p_retcode       OUT NOCOPY NUMBER,
                             p_company       IN  VARCHAR2,
                             p_cutoff_date   IN  DATE);

 PROCEDURE CREATE_NEW_REVAL (p_retcode       OUT NOCOPY NUMBER,
                             p_company       IN  VARCHAR2,
                             p_incomplete    IN  VARCHAR2,
                             p_cutoff_date   IN  DATE);

 PROCEDURE RETRO_SUBPROCESS (p_retcode       OUT NOCOPY NUMBER,
                             p_company       IN  VARCHAR2,
                             p_cutoff_date   IN  DATE);

 PROCEDURE ACCRUAL_SUBPROCESS (p_retcode       OUT NOCOPY NUMBER,
                               p_company       IN  VARCHAR2,
                               p_do_reval      IN  VARCHAR2,
                               p_do_retro      IN  VARCHAR2,  -- 3378028 FAS
                               p_cutoff_date   IN  DATE);

 PROCEDURE CREATE_NEW_ACCRUAL (p_retcode       OUT NOCOPY NUMBER,
                               p_company       IN  VARCHAR2,
                               p_do_reval      IN  VARCHAR2,
                               p_incomplete    IN  VARCHAR2,
                               p_cutoff_date   IN  DATE);

 PROCEDURE JOURNAL_SUBPROCESS (p_retcode        OUT NOCOPY NUMBER,
                               p_company        IN  VARCHAR2,
                               p_cutoff_date    IN  DATE);

 PROCEDURE TRANSFER_SUBPROCESS (p_retcode         OUT NOCOPY NUMBER,
                                p_company         IN  VARCHAR2,
                                p_cutoff_date     IN  DATE,
                                p_closed_periods  IN  VARCHAR2);

 PROCEDURE PROCESS_COMPANY (p_errbuf          OUT NOCOPY VARCHAR2,
                            p_retcode         OUT NOCOPY NUMBER,
                            p_company         IN  VARCHAR2,
                            p_do_reval        IN  VARCHAR2,
                            p_do_retro        IN  VARCHAR2,
                            p_incomplete      IN  VARCHAR2,
                            p_cutoff_date     IN  VARCHAR2,
                            p_start_process   IN  VARCHAR2,
                            p_end_process     IN  VARCHAR2,
                            p_closed_periods  IN  VARCHAR2,
                            p_multiple_acct   IN  VARCHAR2); -- Added Bug 4639287

 PROCEDURE MAIN_PROCESS (p_errbuf          OUT NOCOPY VARCHAR2,
                         p_retcode         OUT NOCOPY NUMBER,
                         p_company         IN  VARCHAR2,
                         p_cutoff_date     IN  VARCHAR2,
                         p_dummy_date      IN  VARCHAR2,
                         p_start_process   IN  VARCHAR2,
                         p_end_process     IN  VARCHAR2,
                         p_dummy_process   IN  VARCHAR2,
                         p_closed_periods  IN  VARCHAR2,
                         p_multiple_acct   IN  VARCHAR2); -- Added Bug 4639287


end XTR_STREAMLINE_P;

 

/
