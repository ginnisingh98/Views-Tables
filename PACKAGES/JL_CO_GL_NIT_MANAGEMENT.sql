--------------------------------------------------------
--  DDL for Package JL_CO_GL_NIT_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_GL_NIT_MANAGEMENT" AUTHID CURRENT_USER AS
/*  $Header: jlcoglbs.pls 120.4.12010000.2 2010/03/03 10:56:05 mbarrett ship $  */

  TYPE reverse_rec_type IS RECORD (
       code_combination_id    jl_co_gl_trx.code_combination_id%type,
       account_code           jl_co_gl_trx.account_code%type,
       period_name            jl_co_gl_trx.period_name%type,
       je_batch_id            jl_co_gl_trx.je_batch_id%type,
       je_header_id           jl_co_gl_trx.je_header_id%type,
       category               jl_co_gl_trx.category%type,
       subl_doc_num           jl_co_gl_trx.subledger_doc_number%type,
       je_line_num            jl_co_gl_trx.je_line_num%type,
       accounting_date        jl_co_gl_trx.accounting_date%type,
       currency               jl_co_gl_trx.currency_code%type,
       reversed_je_header_id  jl_co_gl_trx.je_header_id%type,
       -- Bug 9441034 Start
       entered_dr             jl_co_gl_trx.entered_dr%type,
       entered_cr             jl_co_gl_trx.entered_cr%type,
       accounted_dr           jl_co_gl_trx.accounted_dr%type,
       accounted_cr           jl_co_gl_trx.accounted_cr%type);
       -- Bug 9441034 End

  TYPE reverse_rec_tbl_type IS TABLE of reverse_rec_type
          index by binary_integer;

  reverse_rec_tbl reverse_rec_tbl_type;

  PROCEDURE create_trx_balance(errbuf         OUT NOCOPY VARCHAR2,
                               retcode        OUT NOCOPY NUMBER,
	                       p_proc_type IN            VARCHAR2,
                               p_sobid     IN            NUMBER,
                               p_period    IN            VARCHAR2,
	                       p_rcid      IN            NUMBER,
                               p_batchid   IN            NUMBER );

  PROCEDURE calculate_balance(p_cid    IN NUMBER,
                              p_sobid  IN NUMBER,
	                      p_userid IN NUMBER);

  PROCEDURE reverse_balance(p_rcid    IN NUMBER,
                            p_cid     IN NUMBER,
                            p_sobid   IN NUMBER,
	                    p_userid  IN NUMBER);

END jl_co_gl_nit_management;

/
