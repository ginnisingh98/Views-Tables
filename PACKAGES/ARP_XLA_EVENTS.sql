--------------------------------------------------------
--  DDL for Package ARP_XLA_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_XLA_EVENTS" AUTHID CURRENT_USER AS
/* $Header: ARXLAEVS.pls 120.9.12010000.4 2009/01/28 15:40:58 ankausha ship $ */

Test_flag             VARCHAR2(1) := 'N';

TYPE xla_events_type IS RECORD (
 xla_from_doc_id      NUMBER       , --document id from
 xla_to_doc_id        NUMBER       , --document id to
 xla_req_id           NUMBER       , --request id batch processing
 xla_dist_id          NUMBER       , --distribution id
 xla_doc_table        VARCHAR2(10) , --document table OLTP
 xla_doc_event        VARCHAR2(30) , --document business event OLTP
 xla_mode             VARCHAR2(1)  , --upgrade, Oltp, Batch mode
 xla_call             VARCHAR2(1)  , --call Create, Denormalize, Both
 xla_fetch_size       NUMBER         --bulk fetch size
);

TYPE ev_rec_type IS RECORD (
  trx_status             DBMS_SQL.VARCHAR2_TABLE               ,
  trx_number             DBMS_SQL.VARCHAR2_TABLE               ,
  trx_id                 DBMS_SQL.NUMBER_TABLE                 ,
  pstid                  DBMS_SQL.NUMBER_TABLE                 ,
  org_id                 DBMS_SQL.NUMBER_TABLE                 ,
  dist_id                DBMS_SQL.NUMBER_TABLE                 ,
  dist_row_id            DBMS_SQL.VARCHAR2_TABLE               ,
  dist_event_id          DBMS_SQL.NUMBER_TABLE                 ,
  dist_gl_date           DBMS_SQL.DATE_TABLE                   ,
  override_event         DBMS_SQL.VARCHAR2_TABLE               ,
  trx_type               DBMS_SQL.VARCHAR2_TABLE               ,
  posttogl               DBMS_SQL.VARCHAR2_TABLE               ,
  ev_match_event_id      DBMS_SQL.NUMBER_TABLE                 ,
  ev_match_temp_event_id DBMS_SQL.NUMBER_TABLE                 ,
  ev_match_gl_date       DBMS_SQL.DATE_TABLE                   ,
  ev_match_status        DBMS_SQL.VARCHAR2_TABLE               ,
  ev_match_type          DBMS_SQL.VARCHAR2_TABLE               ,
  ev_exist_id            DBMS_SQL.NUMBER_TABLE                 ,
  ev_exist_gl_date       DBMS_SQL.DATE_TABLE                   ,
  ev_exist_status        DBMS_SQL.VARCHAR2_TABLE               ,
  ev_exist_type          DBMS_SQL.VARCHAR2_TABLE               ,
  dist_dml_flag          DBMS_SQL.VARCHAR2_TABLE
  --{HYU Add transaction_date and legal_entity_id
  ,transaction_date      DBMS_SQL.DATE_TABLE
  ,legal_entity_id       DBMS_SQL.NUMBER_TABLE
  --}
  );

/*========================================================================
 | PUBLIC PROCEDURE Create_Events
 |
 | DESCRIPTION
 |      Main routine which forks processing based on input parameters
 |      and creates events for a given Document.
 |
 |      This procedure does the following calls the create events routine
 |      for :
 |      a) Transactions
 |      b) Bills Receivable
 |      c) Receipts
 |      d) Adjustments
 |      e) Receipt/CM applications
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_Transaction_event
 |      b) Create_Receipt_Event
 |      c) Create_Adjustment_Event
 |      d) Create_Application_Event
 |
 | PARAMETERS p_ev_rec which contains
 |      1) xla_doc_id    IN     NUMBER   --document id OLTP
 |      2) xla_req_id    IN     NUMBER   --request id batch processing
 |      3) xla_dist_id   IN     NUMBER   --distribution id
 |      3) xla_doc_table IN     VARCHAR2 --document table OLTP
 |      4) xla_doc_event IN     VARCHAR2 --document business event OLTP
 |      5) xla_mode      IN     VARCHAR2 --Upgrade, Oltp, Batch mode
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-JAN-2003           Herve Yu          Add delete_event
 *=======================================================================*/
PROCEDURE Create_Events(p_xla_ev_rec IN OUT NOCOPY xla_events_type );

PROCEDURE Create_Events_Req( p_request_id   IN NUMBER,
                             p_doc_table    IN VARCHAR2,
                             p_mode         IN VARCHAR2,
                             p_call         IN VARCHAR2);

PROCEDURE Create_Events_Doc( p_document_id  IN NUMBER,
                             p_doc_table    IN VARCHAR2,
                             p_mode         IN VARCHAR2,
                             p_call         IN VARCHAR2);

PROCEDURE delete_event( p_document_id  IN NUMBER,
                        p_doc_table    IN VARCHAR2);

--6870437
PROCEDURE delete_reverse_revrec_event( p_document_id  IN NUMBER,
                                       p_doc_table    IN VARCHAR2);

PROCEDURE ar_xla_period_close (p_application_id NUMBER DEFAULT 222,
                               p_ledger_id NUMBER,
                               p_period_name VARCHAR2,
                               p_cannot_close_period OUT NOCOPY BOOLEAN ,
                               p_incomplete_events OUT NOCOPY BOOLEAN );

END ARP_XLA_EVENTS;

/
