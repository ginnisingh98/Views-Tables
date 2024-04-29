--------------------------------------------------------
--  DDL for Package AP_ACCOUNTING_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ACCOUNTING_EVENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: apevents.pls 120.5.12010000.3 2010/03/31 20:06:48 gagrawal ship $ */



PROCEDURE create_events
(
  p_event_type IN VARCHAR2,
  p_doc_type IN VARCHAR2, -- Bug3343314
  p_doc_id IN NUMBER DEFAULT NULL,
  p_accounting_date IN DATE,
  p_accounting_event_id OUT NOCOPY NUMBER,
  p_checkrun_name IN VARCHAR2,
  p_calling_sequence IN VARCHAR2 DEFAULT NULL
);

--procedure added in bug 8527163
PROCEDURE delete_invoice_event
(
  p_accounting_event_id IN NUMBER,
  p_Invoice_Id IN NUMBER,
  p_calling_sequence IN VARCHAR2 DEFAULT NULL
);

-- Bug3343314
PROCEDURE update_invoice_events_status
(
  p_invoice_id IN NUMBER,
  p_calling_sequence IN VARCHAR2
);
-- Bug3343314
PROCEDURE update_payment_events_status
(
  p_check_id IN NUMBER,
  p_calling_sequence IN VARCHAR2
);

-- Added for payment batch confirm for payment project

PROCEDURE update_pmt_batch_event_status
(
  p_checkrun_name              IN    VARCHAR2,
  p_completed_pmts_group_id    IN    NUMBER,
  p_org_id                     IN    NUMBER,
  p_calling_sequence           IN    VARCHAR2
);

PROCEDURE create_payment_batch_events(
  p_checkrun_name              IN    VARCHAR2,
  p_completed_pmts_group_id    IN    NUMBER,
  p_accounting_date            IN    DATE,
  p_org_id                     IN    NUMBER,
  p_set_of_books_id            IN    NUMBER,
  p_calling_sequence           IN    VARCHAR2
);

PROCEDURE update_awt_int_dists
(
  p_event_type IN VARCHAR2,
  p_check_id IN NUMBER,
  p_event_id IN NUMBER,
  p_calling_sequence IN VARCHAR2
);

PROCEDURE batch_update_payment_info
(
  p_checkrun_name              IN VARCHAR2,
  p_completed_pmts_group_id    IN NUMBER,
  p_org_id                     IN NUMBER,
  p_calling_sequence           IN VARCHAR2 DEFAULT NULL
);


-- Bug3343314
-- Sweeps accounting events from one accounting period to another.
-- called by:
--   APXTRSWP.rdf (UPDATE_ACCTG_DATES)
PROCEDURE multi_org_events_sweep
(
  p_ledger_id IN NUMBER,
  p_period_name IN VARCHAR2,
  p_from_date IN DATE,
  p_to_date IN DATE,
  p_sweep_to_date IN DATE,
  p_calling_sequence IN VARCHAR2
);


-- Bug3343314
-- Sweeps accounting events from one accounting period to another.
-- called by:
--   APXTRSWP.rdf (UPDATE_ACCTG_DATES)
PROCEDURE single_org_events_sweep
(
  p_period_name IN VARCHAR2,
  p_from_date IN DATE,
  p_to_date IN DATE,
  p_sweep_to_date IN DATE,
  p_calling_sequence IN VARCHAR2
);

-- bug9322013
PROCEDURE Set_Prepay_Event_Noaction
       (p_invoice_id            IN        NUMBER,
        p_calling_sequence      IN        VARCHAR2);


END AP_ACCOUNTING_EVENTS_PKG;

/
