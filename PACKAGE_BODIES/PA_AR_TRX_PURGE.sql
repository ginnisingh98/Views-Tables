--------------------------------------------------------
--  DDL for Package Body PA_AR_TRX_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AR_TRX_PURGE" AS
-- $Header: PAXARPGB.pls 115.3 2002/07/22 04:59:47 mumohan ship $

  FUNCTION transaction_flex_context RETURN VARCHAR2 IS
  flex_context CHAR(50);
  BEGIN
    SELECT r.name
    INTO   flex_context
    FROM   ra_batch_sources r,
           pa_implementations p
    WHERE  p.invoice_batch_source_id = r.batch_source_id;

    RETURN flex_context;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
             RETURN NULL;
        WHEN OTHERS THEN
             RETURN SQLERRM;
   END;


  FUNCTION client_purgeable(p_customer_trx_id IN NUMBER) RETURN BOOLEAN IS
   cursor c1 is
          select 'x'
          from dual
          where exists (
                        select 'x'
                        from  pa_draft_invoices di
                        where di.system_reference = p_customer_trx_id
                       );
   dummy varchar2(1);
   allow_purge BOOLEAN := FALSE;
  BEGIN

    -- Place your logic here. Set the value of allow_purge to TRUE if
    -- you want this invoice to be purged, or FALSE if you don't want it
    -- purged
    open c1;
    fetch c1 into dummy;

    if c1%found then
       allow_purge := FALSE;
    else
       allow_purge := TRUE;
    end if;

    close c1;

    RETURN allow_purge;

  END;


  FUNCTION purgeable(p_customer_trx_id IN NUMBER) RETURN BOOLEAN IS
   allow_purge BOOLEAN := FALSE;
  BEGIN
     allow_purge := client_purgeable(p_customer_trx_id);

     IF  (allow_purge = TRUE) THEN
         return TRUE;
     ELSE
         return FALSE;
     END IF;

  END;


END pa_ar_trx_purge;

/
