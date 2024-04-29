--------------------------------------------------------
--  DDL for Package FUN_SEQ_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_SEQ_BATCH" AUTHID CURRENT_USER AS
/* $Header: funsqbts.pls 120.20 2006/04/25 19:03:00 sryu noship $ */

TYPE num_tbl_type   IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
TYPE num15_tbl_type IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;
TYPE vc30_tbl_type  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE seq_info_rec_type IS RECORD (
        seq_version_id fun_seq_versions.seq_version_id%TYPE,
        assignment_id  fun_seq_assignments.assignment_id%TYPE);

TYPE seq_info_tbl_type IS TABLE OF seq_info_rec_type
  INDEX BY BINARY_INTEGER;

TYPE context_value_tbl_type IS TABLE OF
       fun_seq_contexts.context_value%TYPE INDEX BY BINARY_INTEGER;

--
-- Indexed by Source_ID, that is, either AE_HEADER_ID or or
--
TYPE seq_head_id_tbl_type IS TABLE OF fun_seq_headers.seq_header_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE seq_type_tbl_type IS TABLE OF fun_seq_headers.gapless_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE seq_ver_id_tbl_type IS TABLE OF fun_seq_versions.seq_version_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE assign_id_tbl_type IS TABLE OF fun_seq_assignments.assignment_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE seq_value_tbl_type IS TABLE OF fun_seq_versions.current_value%TYPE
  INDEX BY BINARY_INTEGER;

--
-- Called from Populate_Seq_Requests
--
TYPE ledger_id_tbl_type IS TABLE OF gl_je_headers.ledger_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE je_header_id_tbl_type IS TABLE OF gl_je_headers.je_header_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE actual_flag_tbl_type IS TABLE OF gl_je_headers.actual_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE je_source_tbl_type IS TABLE OF gl_je_headers.je_source%TYPE
  INDEX BY BINARY_INTEGER;

TYPE je_category_tbl_type IS TABLE OF gl_je_headers.je_category%TYPE
  INDEX BY BINARY_INTEGER;

TYPE date_tbl_type IS TABLE OF DATE
  INDEX BY BINARY_INTEGER;

TYPE req_assign_flag_tbl_type IS TABLE OF
  fun_seq_contexts.require_assign_flag%TYPE INDEX BY BINARY_INTEGER;

TYPE error_code_tbl_type IS TABLE OF VARCHAR2(30)
  INDEX BY BINARY_INTEGER;


--
-- Used in Populate_Acct_Seq_Info
--
TYPE ae_header_id_tbl_type IS TABLE OF xla_ae_headers.ae_header_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE balance_type_code_tbl_type IS TABLE OF
  xla_ae_headers.balance_type_code%TYPE INDEX BY BINARY_INTEGER;

TYPE je_source_name_tbl_type IS TABLE OF gl_je_headers.je_source%TYPE
  INDEX BY BINARY_INTEGER;

TYPE je_category_name_tbl_type IS TABLE OF xla_ae_headers.je_category_name%TYPE
  INDEX BY BINARY_INTEGER;

TYPE doc_category_code_tbl_type IS TABLE OF
  xla_ae_headers.doc_category_code%TYPE INDEX BY BINARY_INTEGER;

-- **** replace event_type_code with proper columns
TYPE acct_event_type_code_tbl_type IS TABLE OF VARCHAR2(50)
  INDEX BY BINARY_INTEGER;
--  xla_ae_headers.event_type_code%TYPE INDEX BY BINARY_INTEGER;

TYPE acct_entry_type_code_tbl_type IS TABLE OF
  xla_ae_headers.accounting_entry_type_code%TYPE INDEX BY BINARY_INTEGER;

-- **** Use date_tbl_type for date ****
-- TYPE date_tbl_type IS TABLE OF DATE
--  INDEX BY BINARY_INTEGER;


-- Start of comments
-- API name   : Batch_Init   *** For Accounting Program ***
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Locks the setup data by inserting new records into
--              fun_seq_requests
-- Parameters :
--
-- Version: Current version
--
-- End of comments
PROCEDURE Batch_Init(
            p_application_id        IN  NUMBER,
            p_table_name            IN  VARCHAR2,
            p_event_code            IN  VARCHAR2,
            p_context_type          IN  VARCHAR2,
            p_context_value_tbl     IN  context_value_tbl_type,
            p_request_id            IN  NUMBER,
            x_status                OUT NOCOPY  VARCHAR2,
            x_seq_context_id        OUT NOCOPY  NUMBER);

-- Start of comments
-- API name   : Batch_Init  *** For GL Posting Program ***
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Locks the setup data by inserting new records into
--              fun_seq_requests
-- Parameters :
--
-- Version: Current version
--
-- End of comments
PROCEDURE Batch_Init(
            p_request_id            IN  NUMBER,
            p_ledgers_tbl           IN  num15_tbl_type,
            x_ledgers_locked_tbl    OUT NOCOPY num15_tbl_type,
            x_ledgers_locked_cnt    OUT NOCOPY NUMBER);

-- Start of comments
-- API name   : Batch_Exit
--              *** For XLA Accounting Program and GL Posting Program
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Unlocks setup data by deleting records from fun_seq_requests
-- Parameters :
--
-- Version: Current version
--
-- End of comments
PROCEDURE Batch_Exit(
            p_request_id            IN  NUMBER,
            x_status                OUT NOCOPY  VARCHAR2);

-- Start of comments
-- API name   : Generate_Bulk_Numbers
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Returns sequence numbers for records with same sequence version
--              ID and sequence assignment ID. Also, current value for the
--              sequence version is updated
--
-- Parameters :
--
-- Version: Current version
--
-- End of comments
PROCEDURE Generate_Bulk_Numbers(
            p_request_id           IN  NUMBER,
            p_seq_ver_id_tbl       IN  seq_ver_id_tbl_type,
            p_assign_id_tbl        IN  assign_id_tbl_type,
            x_seq_value_tbl        OUT NOCOPY  seq_value_tbl_type,
            x_seq_date_tbl         OUT NOCOPY  date_tbl_type);

-- Start of comments
-- API name   : Populate_Acct_Seq_Info  *** For Accounting Program ***
-- Type       : Group
-- Pre-reqs   : None
-- Function   : This procedure retrieves Sequence information for each
--              Subledger journal entry header and update Assignment Id,
--              Sequence Version Id, and Sequence Number columns of XLA
--              updateable view.
-- Parameters :
--          p_calling_program
--          p_request_id Number
-- Version: Current version
--
-- End of comments
PROCEDURE Populate_Acct_Seq_Info(
            p_calling_program IN VARCHAR2,
            p_request_id      IN  NUMBER);

-- Start of comments
-- API name   : Populate_Sequence_Info  *** For GL Posting Program ***
-- Type       : Group
-- Pre-reqs   : None
-- Function   : This procedure processes each GL journal entry header found
--              in FUN_SEQ_BATCH_GT and stores the sequencing assignment
--              and version that will be used to sequence the header.
--              It also marks the headers for which the sequence numbering
--              setup is incorrect.
--
-- Parameters :
--          None
-- Version: Current version
--
-- End of comments
PROCEDURE Populate_Seq_Info;

-- Start of comments
-- API name   : Populate_Numbers  *** For GL Posting Program ***
-- Type       : Group
-- Pre-reqs   : None
-- Function   : This procedure obtains sequence numbers for the journal entry
--              headers found in the table FUN_SEQ_BATCH_GT.
-- Parameters :
--          None
-- Version: Current version
--
-- End of comments
FUNCTION Populate_Numbers RETURN DATE;

-- Start of comments
-- API name   : Release_Lock  *** For GL and XLA ***
-- Type       : Group
-- Pre-reqs   : None
-- Function   : This procedure is called from a Concurrent Program
--              to release locks imposed on the Sequencing setup.
-- Parameters :
--          none
-- Version: Current version
--
-- End of comments
PROCEDURE Release_Lock (
           errbuf         OUT NOCOPY VARCHAR2, -- Required by Conc. Manager
           retcode        OUT NOCOPY NUMBER,
           p_request_id   IN  NUMBER);   -- Required by Conc. Manager

-------------------------------------------------------------------------
--                         Supportive Procedures                       --
-------------------------------------------------------------------------
-- !!Warning!!
-- Do not call these procedures without consulting the SSMOA team
--
PROCEDURE Populate_Seq_Requests (
            p_request_id        IN NUMBER,
            p_seq_context_id    IN NUMBER);

PROCEDURE Populate_Seq_Context (
            p_request_id        IN NUMBER,
            p_seq_context_id    IN NUMBER);

PROCEDURE Populate_Seq_Headers (
  p_request_id        IN NUMBER,
  p_seq_context_id    IN NUMBER);

PROCEDURE Delete_Seq_Requests (
  p_request_id        IN NUMBER);

PROCEDURE Populate_Acct_Seq_Prog_View(
  p_request_id        IN NUMBER) ;

PROCEDURE Populate_Rep_Seq_Prog_Gt(
  p_request_id        IN NUMBER);

PROCEDURE Sort_Acct_Entries (
  p_calling_program      IN         VARCHAR2,
  p_application_id_tbl   IN         num_tbl_type,
  p_ae_header_id_tbl     IN         ae_header_id_tbl_type,
  p_assign_id_tbl        IN         assign_id_tbl_type,
  p_seq_ver_id_tbl       IN         seq_ver_id_tbl_type,
  p_sorting_key_tbl      IN         date_tbl_type,
  x_application_id_tbl   OUT NOCOPY num_tbl_type,
  x_ae_header_id_tbl     OUT NOCOPY ae_header_id_tbl_type,
  x_assign_id_tbl        OUT NOCOPY assign_id_tbl_type,
  x_seq_ver_id_tbl       OUT NOCOPY seq_ver_id_tbl_type);

END fun_seq_batch;

 

/
