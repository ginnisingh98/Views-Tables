--------------------------------------------------------
--  DDL for Package ARP_XLA_EXTRACT_MAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_XLA_EXTRACT_MAIN_PKG" AUTHID CURRENT_USER AS
/* $Header: ARPXLEXS.pls 120.8.12010000.4 2009/02/23 22:45:25 ankausha ship $ */

  max_array_size       NUMBER := 999;

--{Get GL segment info
TYPE seg_qual_table IS TABLE OF VARCHAR2(200)  INDEX BY BINARY_INTEGER;

pg_bal_qual      seg_qual_table;
pg_nat_qual      seg_qual_table;

FUNCTION the_segment_value(p_coa_id     IN NUMBER,
                           p_qual_code  IN VARCHAR2,
                           p_ccid       IN NUMBER)
RETURN VARCHAR2;
--}

--{
pg_ed_trx      seg_qual_table;
pg_uned_trx    seg_qual_table;

FUNCTION ed_uned_trx(p_type IN VARCHAR2,
                     p_org_id IN NUMBER)
RETURN NUMBER;
--}
/*------------------------------------------------------+
 | Procedure name : Extract                             |
 +------------------------------------------------------+
 | Parameter : accounting mode                          |
 |              D for Draft                             |
 |              F for final                             |
 |                                                      |
 | Purpose : Extract the AR accounting lines based      |
 |           on xla events passed by XLA_EVENTS_GT      |
 |           This routine is launched by XLA accounting |
 |           program in extract phase                   |
 |                                                      |
 | Modification history                                 |
 +------------------------------------------------------*/
  --BUG#4387467
  PROCEDURE extract(p_application_id     IN NUMBER
                   ,p_accounting_mode    IN VARCHAR2);

  PROCEDURE extract(p_accounting_mode    IN VARCHAR2);


/*------------------------------------------------------+
 | Procedure name : Posting control id in postprocessing|
 +------------------------------------------------------+
 | Parameter : accounting mode                          |
 |              D for Draft                             |
 |              F for final                             |
 |                                                      |
 | Purpose : Stamping the posting control id in AR      |
 |           AR posting entities only for Final mode.   |
 |           This is used in the post acctg process     |
 |                                                      |
 | Modification history                                 |
 +------------------------------------------------------*/
  --BUG#4387467
  PROCEDURE postprocessing(p_application_id        IN NUMBER
                          ,p_accounting_mode       IN VARCHAR2);

  PROCEDURE flag_the_posting_id(p_accounting_mode IN VARCHAR2);

  /*-----------------------------------------------+
   | Stub of postaccounting for future enhancement |
   +-----------------------------------------------*/
  PROCEDURE postaccounting
  (p_application_id         IN  NUMBER,
   p_ledger_id              IN  NUMBER,
   p_process_category       IN  VARCHAR2,
   p_end_date               IN  DATE,
   p_accounting_mode        IN  VARCHAR2,
   p_valuation_method       IN  VARCHAR2,
   p_security_id_int_1      IN  NUMBER,
   p_security_id_int_2      IN  NUMBER,
   p_security_id_int_3      IN  NUMBER,
   p_security_id_char_1     IN  NUMBER,
   p_security_id_char_2     IN  NUMBER,
   p_security_id_char_3     IN  NUMBER,
   p_report_request_id      IN  NUMBER);



/*------------------------------------------------------+
 | Procedure name : Document locking in pre accounting  |
 +------------------------------------------------------+
 | Parameter : None                                     |
 |                                                      |
 | Purpose : Locking the records concerned in a         |
 |           particular accounting program process.     |
 |                                                      |
 | Modification history                                 |
 +------------------------------------------------------*/
  --BUG#4387467
  PROCEDURE preaccounting
   (p_application_id     IN NUMBER
   ,p_ledger_id          IN NUMBER
   ,p_process_category   IN VARCHAR2
   ,p_end_date           IN DATE
   ,p_accounting_mode    IN VARCHAR2
   ,p_valuation_method   IN VARCHAR2
   ,p_security_id_int_1  IN NUMBER
   ,p_security_id_int_2  IN NUMBER
   ,p_security_id_int_3  IN NUMBER
   ,p_security_id_char_1 IN VARCHAR2
   ,p_security_id_char_2 IN VARCHAR2
   ,p_security_id_char_3 IN VARCHAR2
   ,p_report_request_id  IN NUMBER);

  -- This is stub out, keep this in order not to break the current code
  PROCEDURE lock_documents_for_xla;


/*------------------------------------------------------+
 |  Workflow subscription                               |
 +------------------------------------------------------*/
 ----------------------------------------
 -- Procedure name : locking_status
 ----------------------------------------
 -- Parameter : Workflow rule function subscription
 --             standard parameters.
 -- Purpose : Allow the procedure extract
 --           to be called in Workflow 2.6
 -- History : Is replaced by preaccounting procedure
 ----------------------------------------
  FUNCTION locking_status
   (p_subscription_guid IN RAW,
    p_event             IN OUT NOCOPY wf_event_t)
  RETURN VARCHAR2;

 ----------------------------------
 -- Procedure name : extract_status
 ----------------------------------
 -- Parameter : Workflow rule function subscription
 --             standard parameters.
 -- Purpose : Allow the procedure extract
 --           to be called in Workflow 2.6
 -- Modification history:Is replaced by extract procedure
 ----------------------------------
  FUNCTION extract_status
   (p_subscription_guid IN RAW,
    p_event             IN OUT NOCOPY wf_event_t)
  RETURN VARCHAR2;

 --------------------------------------
 -- Procedure name : posting_ctl_status
 --------------------------------------
 -- Parameter : Workflow rule function subscription
 --             standard parameters.
 -- Purpose : Allow the procedure flag_the_posting_id
 --           to be called in Workflow 2.6
 -- Modification history: Is replaced by postprocessing
 ------------------------------------------------------
  FUNCTION posting_ctl_status
    (p_subscription_guid IN RAW,
     p_event             IN OUT NOCOPY wf_event_t)
  RETURN VARCHAR2;

------------------------
-- Extract procedures --
------------------------
  PROCEDURE load_header_data_ctlgd(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_header_data_adj(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_header_data_crh(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_header_data_th(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_ctlgd(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_adj(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_crh(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_th(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_crh_mf(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_app_to_trx(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_app_from_cr(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_app_from_cm(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_app_unid(p_application_id IN NUMBER DEFAULT 222);
  PROCEDURE load_line_data_mcd(p_application_id IN NUMBER DEFAULT 222);

-----------------------------
-- Function get_glr_ccid
-- bug 7694448
-----------------------------
-- Parameter : p_ra_id, p_gain_loss_identifier
-- Purpose   : fetch the ccid for exch_gain, exch_loss depending
--             on the input parameter gain_loss_identifier (possible
--             values EXCH_GAIN,EXCH_LOSS)
--             for a given receivable_application_id using caching
--             to overcome performance bottlenecks
-------------------------------------------------------------------
FUNCTION get_glr_ccid
( p_ra_id IN NUMBER, p_gain_loss_identifier in VARCHAR) RETURN NUMBER;

END;

/
