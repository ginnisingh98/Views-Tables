--------------------------------------------------------
--  DDL for Package FUN_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_SEQ" AUTHID CURRENT_USER AS
/* $Header: funsqgns.pls 120.22 2004/06/23 21:05:18 masada noship $ */

TYPE control_date_rec_type IS RECORD (
       date_type  VARCHAR2(30),  --- Update DLD
       date_value DATE);

TYPE control_date_tbl_type IS TABLE OF control_date_rec_type;-- INDEX BY BINARY_INTEGER;

TYPE control_attribute_rec_type IS RECORD (
       balance_type          fun_seq_assignments.balance_type%TYPE,
       journal_source        fun_seq_assignments.journal_source%TYPE,
       journal_category      fun_seq_assignments.journal_category%TYPE,
       document_category     fun_seq_assignments.document_category%TYPE,
       accounting_event_type fun_seq_assignments.accounting_event_type%TYPE,
       accounting_entry_type fun_seq_assignments.accounting_entry_type%TYPE);

TYPE context_info_rec_type IS RECORD (
       application_id   fun_seq_contexts.application_id%TYPE,
       table_name       fun_seq_contexts.table_name%TYPE,
       context_type     fun_seq_contexts.context_type%TYPE,
       context_value    fun_seq_contexts.context_value%TYPE,
       event_code       fun_seq_contexts.event_code%TYPE);

TYPE context_info_tbl_type IS TABLE OF context_info_rec_type
  INDEX BY BINARY_INTEGER;

TYPE context_ctrl_rec_type IS RECORD (
       seq_context_id        fun_seq_contexts.seq_context_id%TYPE,
       date_type             fun_seq_contexts.date_type%TYPE,
       req_assign_flag       fun_seq_contexts.require_assign_flag%TYPE,
       sort_option_code      fun_seq_contexts.sort_option%TYPE);

TYPE context_ctrl_tbl_type IS TABLE OF context_ctrl_rec_type
  INDEX BY BINARY_INTEGER;


TYPE assign_info_rec_type IS RECORD (
       seq_context_id         fun_seq_contexts.seq_context_id%TYPE,
       ctrl_attr_rec          control_attribute_rec_type,
       control_date           DATE);

TYPE assignment_info_tbl_type IS TABLE of assign_info_rec_type
  INDEX BY BINARY_INTEGER;

TYPE exp_info_rec_type IS RECORD (
       assignment_id          fun_seq_assignments.assignment_id%TYPE,
       ctrl_attr_rec          control_attribute_rec_type,
       control_date           DATE);

TYPE exp_info_tbl_type IS TABLE of exp_info_rec_type
  INDEX BY BINARY_INTEGER;

TYPE assign_seq_head_rec_type IS RECORD (
       assignment_id          fun_seq_assignments.assignment_id%TYPE,
       seq_header_id          fun_seq_headers.seq_header_id%TYPE,
       seq_type               fun_seq_headers.gapless_flag%TYPE);

TYPE assign_seq_head_tbl_type IS TABLE of assign_seq_head_rec_type
  INDEX BY BINARY_INTEGER;

-- Start of comments
-- API name   : Get_Sequence_Number
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Provide a wrapper for get_assigned_sequence_info
--              and generate_sequence_number
-- Parameters :
--
-- Version: Current version
--
-- End of comments
PROCEDURE Get_Sequence_Number(
            p_context_type          IN  VARCHAR2,
            p_context_value         IN  VARCHAR2,
            p_application_id        IN  NUMBER,
            p_table_name            IN  VARCHAR2,
            p_event_code            IN  VARCHAR2,
            p_control_attribute_rec IN  control_attribute_rec_type,
            p_control_date_tbl      IN  control_date_tbl_type,
            p_suppress_error        IN  VARCHAR2,
            x_seq_version_id        OUT NOCOPY NUMBER,
            x_sequence_number       OUT NOCOPY NUMBER,
            x_assignment_id         OUT NOCOPY NUMBER,
            x_error_code            OUT NOCOPY VARCHAR2);
-- Start of comments
-- API name   : Get_Assigned_Sequence_Info
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Retrieve Assigned Sequence Information
-- Parameters :
--
-- Version: Current version
--
-- End of comments
PROCEDURE Get_Assigned_Sequence_Info(
            p_context_type          IN  VARCHAR2,
            p_context_value         IN  VARCHAR2,
            p_application_id        IN  NUMBER,
            p_table_name            IN  VARCHAR2,
            p_event_code            IN  VARCHAR2,
            p_control_attribute_rec IN  control_attribute_rec_type,
            p_control_date_tbl      IN  control_date_tbl_type,
            p_request_id            IN  NUMBER,
            p_suppress_error        IN  VARCHAR2,
            x_sequence_type         OUT NOCOPY VARCHAR2,
            x_seq_version_id        OUT NOCOPY NUMBER,
            x_assignment_id         OUT NOCOPY NUMBER,
            x_control_date_value    OUT NOCOPY DATE,
            x_req_assign_flag       OUT NOCOPY VARCHAR2,
            x_sort_option_code      OUT NOCOPY VARCHAR2,
            x_error_code            OUT NOCOPY VARCHAR2);

-- Start of comments
-- API name   : Generate_Sequence_Number
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Generate Sequence Numbers
-- Parameters :
--
-- Version: Current version
--
-- End of comments
PROCEDURE Generate_Sequence_Number(
            p_assignment_id   IN  NUMBER,
            p_seq_version_id  IN  NUMBER,
            p_sequence_type   IN  VARCHAR2,
            p_request_id      IN  NUMBER,
            x_sequence_number OUT NOCOPY NUMBER,
            x_sequenced_date  OUT NOCOPY DATE,
            x_error_code      OUT NOCOPY VARCHAR2);

-- Start of comments
-- API name   : Reset
-- Type       : Group
-- Pre-reqs   : None
-- Function   : Reset Sequence Version Information for renumbering
--              Current Value is updated.
-- Parameters :
--   p_seq_version_id
--   p_sequence_number
-- Version: Current version
--
-- End of comments
PROCEDURE Reset(
            p_seq_version_id       IN  NUMBER,
            p_sequence_number      IN  NUMBER); -- Last Used Number

--
-- Supporting Programs
--
PROCEDURE get_assign_context_info (
            p_context_type       IN  VARCHAR2,
            p_context_value      IN  VARCHAR2,
            p_application_id     IN  NUMBER,
            p_table_name         IN  VARCHAR2,
            p_event_code         IN  VARCHAR2,
            p_request_id         IN  NUMBER,
            x_seq_context_id     OUT NOCOPY NUMBER,
            x_control_date_type  OUT NOCOPY VARCHAR2,
            x_req_assign_flag    OUT NOCOPY VARCHAR2,
            x_sort_option_code   OUT NOCOPY VARCHAR2);

--
-- Supporting Programs
--

--
-- Sequence Numbering (without Autonomous Commit)
--
PROCEDURE Get_Sequence_Number_No_Commit(
            p_context_type          IN  VARCHAR2,
            p_context_value         IN  VARCHAR2,
            p_application_id        IN  NUMBER,
            p_table_name            IN  VARCHAR2,
            p_event_code            IN  VARCHAR2,
            p_control_attribute_rec IN  control_attribute_rec_type,
            p_control_date_tbl      IN  control_date_tbl_type,
            p_suppress_error        IN  VARCHAR2,
            x_seq_version_id        OUT NOCOPY NUMBER,
            x_sequence_number       OUT NOCOPY NUMBER,
            x_assignment_id         OUT NOCOPY NUMBER,
            x_error_code            OUT NOCOPY VARCHAR2);

--
-- Sequence Numbering  (w/ Autonomous Commit)
--
PROCEDURE Get_Sequence_Number_Commit(
            p_context_type          IN  VARCHAR2,
            p_context_value         IN  VARCHAR2,
            p_application_id        IN  NUMBER,
            p_table_name            IN  VARCHAR2,
            p_event_code            IN  VARCHAR2,
            p_control_attribute_rec IN  control_attribute_rec_type,
            p_control_date_tbl      IN  control_date_tbl_type,
            p_suppress_error        IN  VARCHAR2,
            x_seq_version_id        OUT NOCOPY NUMBER,
            x_sequence_number       OUT NOCOPY NUMBER,
            x_assignment_id         OUT NOCOPY NUMBER,
            x_error_code            OUT NOCOPY VARCHAR2);

PROCEDURE get_cached_context_info (
            p_context_info_rec   IN  context_info_rec_type,
            x_context_ctrl_rec   OUT NOCOPY context_ctrl_rec_type);

--
-- Wrapper for get_assigned_seq_header and get_assigned_seq_version
--
PROCEDURE get_assigned_sequence_header (
            p_seq_context_id         IN  NUMBER,
            p_control_attribute_rec  IN  control_attribute_rec_type,
            p_control_date_value     IN  DATE,
            p_request_id             IN  NUMBER,
            x_assignment_id          OUT NOCOPY NUMBER,
            x_sequence_type          OUT NOCOPY VARCHAR2,
            x_seq_header_id          OUT NOCOPY NUMBER);

--
-- Retrieve Assignment Information of Intercompany Transactions
--
PROCEDURE get_ic_assigned_seq_header (
            p_seq_context_id         IN  NUMBER,
            p_control_date_value     IN  DATE,
            p_request_id             IN  NUMBER,
            x_assignment_id          OUT NOCOPY NUMBER,
            x_sequence_type          OUT NOCOPY VARCHAR2,
            x_seq_header_id          OUT NOCOPY NUMBER);

--
-- Get_Seq_Header_Assignment
--
PROCEDURE get_seq_header_assignment (
            p_seq_context_id         IN  NUMBER,
            p_control_attribute_rec  IN  control_attribute_rec_type,
            p_control_date_value     IN  DATE,
            p_request_id             IN  NUMBER,
            x_assignment_id          OUT NOCOPY NUMBER,
            x_sequence_type          OUT NOCOPY VARCHAR2,
            x_seq_header_id          OUT NOCOPY NUMBER);

--
-- Called from Get_Seq_Header_Assignment
-- Use Cache for Batch Programs
--
PROCEDURE get_cached_seq_header_assign (
            p_assign_info_rec      IN  assign_info_rec_type,
            x_assign_seq_head_rec  OUT NOCOPY assign_seq_head_rec_type);

--
-- Get_Seq_Header_Exception
--
PROCEDURE get_seq_header_exception (
            p_assignment_id          IN  NUMBER,
            p_control_attribute_rec  IN  control_attribute_rec_type,
            p_control_date_value     IN  DATE,
            p_request_id             IN  NUMBER,
            x_exp_assignment_id      OUT NOCOPY NUMBER,
            x_exp_sequence_type      OUT NOCOPY VARCHAR2,
            x_exp_seq_header_id      OUT NOCOPY NUMBER);

--
-- Get_Seq_Context_Name
-- (for debug)
FUNCTION get_seq_context_name (
           p_seq_context_id IN NUMBER) RETURN VARCHAR2;

--
-- Get_Seq_Header_Name
-- (for debug)
FUNCTION get_seq_header_name (
           p_seq_header_id IN NUMBER) RETURN VARCHAR2;

--
-- Get_Cached_Seq_Header_Exp
--
PROCEDURE get_cached_seq_header_exp (
            p_exp_info_rec      IN  exp_info_rec_type,
            x_exp_seq_head_rec  OUT NOCOPY assign_seq_head_rec_type);
--
--
--
PROCEDURE get_seq_version (
            p_sequence_type       IN  VARCHAR2,
            p_seq_header_id       IN  NUMBER,
            p_control_date_value  IN  DATE,
            p_request_id          IN  NUMBER,
            x_seq_version_id      OUT NOCOPY NUMBER);

--
--
--
FUNCTION get_control_date_value (
           p_control_date_type IN VARCHAR2,
           p_control_dates     IN control_date_tbl_type) RETURN VARCHAR2;
--
-- Update the Status of Assignments/Exceptions and Versions
-- ** For Gapless Sequences **
--
PROCEDURE update_gapless_status (
           p_assignment_id  IN NUMBER,
           p_seq_version_id IN NUMBER);

--
-- Update the Status of Assignments/Exceptions and Versions
-- ** For Database Sequences **
--
PROCEDURE update_db_status (
           p_assignment_id  IN NUMBER,
           p_seq_version_id IN NUMBER);
--
-- Update the Status of Assignments and Exceptions
--
PROCEDURE update_assign_status (
           p_assignment_id  IN NUMBER);

--
-- Update the Status of Versions
--
PROCEDURE update_seq_ver_status (
           p_seq_version_id  IN NUMBER);
--
-- Find a Sequencing Context in the Cache
--
FUNCTION find_seq_context_in_cache(
           p_context_info_rec IN context_info_rec_type)
  RETURN BINARY_INTEGER;

--
-- Find a Sequencing Context in the database
--
FUNCTION find_seq_context_in_db(
           p_context_info_rec IN context_info_rec_type)
  RETURN context_ctrl_rec_type;

--
-- Find an Assignment in the Cache
--
FUNCTION find_seq_head_assign_in_cache(
           p_assign_info_rec IN assign_info_rec_type)
  RETURN BINARY_INTEGER;
--
-- Find an Assignment in the database
--
FUNCTION find_seq_head_assign_in_db (
           p_assign_info_rec IN assign_info_rec_type)
  RETURN assign_seq_head_rec_type;

--
-- Find an Exception in the database
--
FUNCTION find_seq_head_exp_in_cache(
           p_exp_info_rec    IN exp_info_rec_type)
  RETURN BINARY_INTEGER;
--
-- Find an Exception in the database
--
FUNCTION find_seq_head_exp_in_db(
           p_exp_info_rec    IN exp_info_rec_type)
  RETURN assign_seq_head_rec_type;
--
-- Return the flag indicating whether to use cache
--
FUNCTION use_cache (
           p_request_id     IN NUMBER,
           p_application_id IN NUMBER,
           p_table_name     IN VARCHAR2,
           p_event_code     IN VARCHAR2)
  RETURN BOOLEAN;
END fun_seq;

 

/
