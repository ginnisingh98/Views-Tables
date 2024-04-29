--------------------------------------------------------
--  DDL for Package ZX_GL_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_GL_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxrigextractpvts.pls 120.1 2006/05/25 21:16:01 skorrapa ship $ */
--
-----------------------------------------
--Public Variable Declarations
-----------------------------------------
--
-----------------------------------------
--Public Methods Declarations
-----------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INSERT_TAX_DATA                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   18-Feb-2005 Srinivasa Rao Korrapati                                     |
 |                                                                           |
 +===========================================================================*/


PROCEDURE INSERT_TAX_DATA (
          P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
          );
PROCEDURE UPDATE_ADDITIONAL_INFO (P_TRL_GLOBAL_VARIABLES_REC IN OUT
                                  ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
);

function prorated_tax(
  p_trx_id in                   number,
  p_ledger_id in          number,
  p_doc_seq_id in               number,
  p_tax_code_id in              number,
  p_code_comb_id in             number,
  p_tax_doc_date in             date,
  p_tax_class in                varchar2,
  p_tax_doc_identifier in       varchar2,
  p_tax_cust_name in            varchar2,
  p_tax_cust_reference in       varchar2,
  p_tax_reg_number in           varchar2,
  p_seq_name in                 varchar2,
  p_column_name in              varchar2) return number;

END ZX_GL_EXTRACT_PKG;

 

/
