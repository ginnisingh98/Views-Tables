--------------------------------------------------------
--  DDL for Package PSA_SLA_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_SLA_PROCESSING_PKG" AUTHID CURRENT_USER as
--$Header: psaxlacs.pls 120.0 2005/08/17 05:46:46 ckappaga noship $

/* $Header: psaxlacs.pls 120.0 2005/08/17 05:46:46 ckappaga noship $ */

/*------------------------------------------------------
 | Procedure name : Preaccounting
 +------------------------------------------------------
 |  DESCRIPTION
 |    This procedure is the PSA SLA pre-accounting procedure.
 |    This procedure  will be called by SLA through an API.
 |
 |  Purpose : Pre accouting requirements during accounting process.
 |            Currently for PSA not in use
 |
 |
 | Modification history
 +------------------------------------------------------*/
PROCEDURE preaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
);

/*------------------------------------------------------
 | Procedure name : Extract
 +------------------------------------------------------
 |  DESCRIPTION
 |    This procedure is the PSA SLA EXtarct procedure.
 |    This procedure  will be called by SLA through an API.
 |
 | Purpose : Extract will be processed based on each product.
 |           Required PSA sources for product wil be
 |           Popluated for accounting based on
 |           product extract objects and xla_events_GT
 |
 |
 |
 | Modification history
 +------------------------------------------------------*/

PROCEDURE extract
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
);

/*------------------------------------------------------
 | Procedure name : PostProcessing
 +------------------------------------------------------
 |  DESCRIPTION
 |    This procedure is the PSA SLA post-Processing procedure.
 |    This procedure  will be called by SLA through an API.
 |
 |  Purpose : Post processing requirements during accounting process.
 |            PSA currently does not use any post processing
 |
 |
 | Modification history
 +------------------------------------------------------*/

PROCEDURE postprocessing
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
);

/*------------------------------------------------------
 | Procedure name : Postaccounting
 +------------------------------------------------------
 |  DESCRIPTION
 |    This procedure is the PSA SLA post-accounting procedure.
 |    This procedure  will be called by SLA through an API.
 |
 |  Purpose : Post accouting requirements during accounting process.
 |
 |
 | Modification history
 +------------------------------------------------------*/

PROCEDURE postaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
);

END psa_sla_processing_pkg; -- Package spec


 

/
