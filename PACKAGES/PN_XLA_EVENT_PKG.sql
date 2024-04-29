--------------------------------------------------------
--  DDL for Package PN_XLA_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_XLA_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: PNXLAEVS.pls 120.2.12010000.2 2009/03/16 12:08:08 rkartha ship $ */

------------------------------ DECLARATIONS ----------------------------------+


--------------------------- PUBLIC PROCEDURES --------------------------------+

PROCEDURE create_xla_event(
            p_payment_item_id pn_payment_items.payment_item_id%TYPE
           ,p_due_date        pn_payment_items.due_date%TYPE        -- Added for Bug#8303091
           ,p_legal_entity_id pn_payment_terms.legal_entity_id%TYPE
           ,p_ledger_id       pn_payment_terms.set_of_books_id%TYPE
           ,p_org_id          pn_payment_terms.org_id%TYPE
           ,p_bill_or_pay     VARCHAR2
           ,p_event_id        OUT NOCOPY xla_events.event_id%TYPE
         );

END pn_xla_event_pkg;

/
