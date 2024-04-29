--------------------------------------------------------
--  DDL for Package Body PN_XLA_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_XLA_EVENT_PKG" AS
/* $Header: PNXLAEVB.pls 120.3.12010000.2 2009/03/16 12:08:47 rkartha ship $ */

------------------------------ DECLARATIONS ----------------------------------+

bad_input_exception EXCEPTION;


------------------------------------------------------------------------------+
-- PROCEDURE   : create_xla_event
-- DESCRIPTION : given a schedule_id, create SLA events for all normalized
--               items under that schedule
-- HISTORY     :
-- 08-JUN-05 ftanudja o Created.
-- 16-AUG-05 ftanudja o Added exception catching as a workaround to bug
--                      # 4529563. Reference event id in payment items table.
--                    o Stamp payment items table with event id.
-- 31-MAY-06 sdmahesh o Bug # 5219481
--                      Added OUT parameter p_event_id to create_xla_event
--                      Removed stamping of event id in pn_payment_items_all
--                      Now we do this in PN_CREATE_ACC
------------------------------------------------------------------------------+

PROCEDURE create_xla_event(
            p_payment_item_id pn_payment_items.payment_item_id%TYPE
           ,p_due_date        pn_payment_items.due_date%TYPE -- Added for Bug#8303091
           ,p_legal_entity_id pn_payment_terms.legal_entity_id%TYPE
           ,p_ledger_id       pn_payment_terms.set_of_books_id%TYPE
           ,p_org_id          pn_payment_terms.org_id%TYPE
           ,p_bill_or_pay     VARCHAR2
           ,p_event_id        OUT NOCOPY xla_events.event_id%TYPE
         )
IS
  l_source_info        xla_events_pub_pkg.t_event_source_info;
  l_chk_source_info    xla_events_pub_pkg.t_event_source_info;
  l_chk_return_info    xla_events_pub_pkg.t_array_event_info;
  l_security_info      xla_events_pub_pkg.t_security;
  l_reference_info     xla_events_pub_pkg.t_event_reference_info;

  l_event_type         VARCHAR2(30);
  l_info               VARCHAR2(100);
  l_desc               VARCHAR2(100) := 'pn_xla_event_pkg.create_xla_event';
  l_not_found          BOOLEAN;
  l_event_id           xla_events.event_id%TYPE := NULL;

  l_due_date        pn_payment_items.due_date%TYPE; -- Added for Bug#8303091

BEGIN

  pnp_debug_pkg.log(l_desc ||' (+)');
  pnp_debug_pkg.log('INPUT PARAMETERS');
  pnp_debug_pkg.log('p_payment_item_id : '||TO_CHAR(p_payment_item_id));
  pnp_debug_pkg.log('p_legal_entity_id : '||TO_CHAR(p_legal_entity_id));
  pnp_debug_pkg.log('p_ledger_id       : '||TO_CHAR(p_ledger_id));
  pnp_debug_pkg.log('p_org_id          : '||TO_CHAR(p_org_id));
  pnp_debug_pkg.log('p_bill_or_pay     : '||p_bill_or_pay);

  IF p_bill_or_pay = 'PAY' THEN
    l_event_type := 'LEASE_EXPENSE_TRANSFER';
  ELSIF p_bill_or_pay = 'BILL' THEN
    l_event_type := 'LEASE_REVENUE_TRANSFER';
  ELSE
    raise bad_input_exception;
  END IF;

  l_info := 'initializing parameters for xla API ';
  pnp_debug_pkg.log(l_info);

  l_not_found       := FALSE;
  l_source_info     := null;
  l_chk_source_info := null;
  l_security_info   := null;
  l_chk_return_info.delete;

  l_security_info.security_id_int_1 := p_org_id;

  l_source_info.application_id      := 240;
  l_source_info.entity_type_code    := 'TRANSACTION';
  l_source_info.legal_entity_id     := p_legal_entity_id;
  l_source_info.ledger_id           := p_ledger_id;
  l_source_info.source_id_int_1     := p_payment_item_id;

  l_chk_source_info := l_source_info;

  l_due_date := p_due_date; -- Added for Bug#8303091

  l_info := 'checking existence of xla event for payment item ID: '||p_payment_item_id;
  pnp_debug_pkg.log(l_info);

  -- NOTE: this 'BEGIN' and 'END' should ideally not be there.
  -- The SLA function throws a nasty error when no data is found
  -- We need to gracefully handle the exception thrown
  -- Once bug 4529563 is resolved, we can remove this

  BEGIN

    l_chk_return_info :=
     xla_events_pub_pkg.get_array_event_info(
      p_event_source_info  => l_chk_source_info
     ,p_valuation_method   => null
     ,p_security_context   => l_security_info
     );

  EXCEPTION
    WHEN OTHERS THEN
       l_not_found := TRUE;
  END;

  l_info := 'creating xla event for payment item ID: '||p_payment_item_id;
  pnp_debug_pkg.log(l_info);

  IF l_chk_return_info.COUNT = 0 OR l_not_found THEN

     l_event_id :=
       xla_events_pub_pkg.create_event(
         p_event_source_info  => l_source_info
        ,p_event_type_code    => l_event_type
   --   ,p_event_date         => SYSDATE  -- Commented for Bug#8303091
        ,p_event_date         => l_due_date  -- Added for Bug#8303091
        ,p_event_status_code  => xla_events_pub_pkg.C_EVENT_UNPROCESSED
        ,p_event_number       => null
        ,p_reference_info     => null
        ,p_valuation_method   => null
        ,p_transaction_date   => null
        ,p_security_context   => l_security_info
      );

     p_event_id := NULL;

     IF l_event_id IS NULL THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSE
        p_event_id := l_event_id;
     END IF;

  END IF;

  pnp_debug_pkg.log(l_desc ||' (-)');

EXCEPTION
  WHEN OTHERS THEN
     pnp_debug_pkg.log(l_desc || ': Error while ' || l_info);
     raise;

END create_xla_event;

END pn_xla_event_pkg;

/
