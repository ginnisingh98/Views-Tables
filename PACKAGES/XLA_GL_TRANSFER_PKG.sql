--------------------------------------------------------
--  DDL for Package XLA_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_GL_TRANSFER_PKG" AUTHID CURRENT_USER AS
/* $Header: XLACGLXS.pls 120.1 2005/06/03 00:12:32 masada ship $ */

 -- Cursor to get table, sequence names
 CURSOR c_get_program_info(P_program_name VARCHAR2) IS
     SELECT acct_events_table_name, ae_headers_table_name,
            ae_lines_table_name,
            ae_encumbrance_table_name,
            ae_lines_linkid_seq_name,
            ae_enc_lines_linkid_seq_name,
            ae_lines_table_alias,
            ae_enc_table_alias
      FROM  xla_gl_transfer_program_lines gtl
     WHERE  gtl.program_name = P_program_name;

 -- Set of books info.
 TYPE r_sob_info IS RECORD ( sob_id                NUMBER(15),
			     sob_name              VARCHAR2(30),
			     sob_curr_code         VARCHAR2(15),
			     encum_flag            VARCHAR2(1),
			     average_balances_flag VARCHAR2(1),
			     legal_entity_id       NUMBER,
			     cost_group_id         NUMBER,
			     cost_type_id          NUMBER
			     );
 TYPE t_sob_list IS TABLE OF r_sob_info;

 -- Stores Journal Category
 TYPE t_ae_category IS TABLE OF VARCHAR2(30)
   INDEX BY BINARY_INTEGER ;

 -- Stores the control information for the transfer
 TYPE r_control_info IS RECORD ( sob_id              NUMBER(15),
				 period_name         VARCHAR2(30),
				 rec_transferred     NUMBER,
				 cnt_transfer_errors NUMBER,
				 cnt_acct_errors     NUMBER
				 );

TYPE t_control_info  IS TABLE OF r_control_info
  INDEX BY BINARY_INTEGER;

g_control_info  t_control_info;

-- Returns the summary information for the transfer.
FUNCTION get_control_info( p_sob_id         NUMBER,
			   p_period_name    VARCHAR2,
			   p_error_type     VARCHAR2
			  ) RETURN NUMBER;
--pragma restrict_references(get_control_info, WNDS, WNPS);
PROCEDURE xla_gl_transfer( p_application_id           NUMBER,
                           p_user_id                  NUMBER,
			   p_org_id                   NUMBER,
                           p_request_id               NUMBER,
			   p_program_name             VARCHAR2,
                           p_selection_type           NUMBER     DEFAULT 1,
                           p_sob_list                 t_sob_list,
                           p_batch_name               VARCHAR2   DEFAULT NULL,
                           p_source_doc_id            NUMBER     DEFAULT NULL,
                           p_source_document_table    VARCHAR2   DEFAULT NULL,
                           p_start_date               DATE,
                           p_end_date                 DATE,
                           p_journal_category         t_ae_category,
			   p_validate_account         VARCHAR2   DEFAULT NULL,
                           p_gl_transfer_mode         VARCHAR2,
                           p_submit_journal_import    VARCHAR2   DEFAULT 'Y',
                           p_summary_journal_entry    VARCHAR2   DEFAULT 'N',
			   p_process_days             NUMBER,
			   p_batch_desc               VARCHAR2   DEFAULT NULL,
			   p_je_desc                  VARCHAR2   DEFAULT NULL,
			   p_je_line_desc             VARCHAR2   DEFAULT NULL,
			   p_fc_force_flag            BOOLEAN    DEFAULT TRUE,
                           p_debug_flag               VARCHAR2   DEFAULT 'N'
  );


FUNCTION get_linkid( p_program_name VARCHAR2 ) RETURN NUMBER;
END xla_gl_transfer_pkg;

 

/
