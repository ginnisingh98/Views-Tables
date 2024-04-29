--------------------------------------------------------
--  DDL for Package Body PA_AP_TRX_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AP_TRX_PURGE" AS
-- $Header: PAXAPPGB.pls 120.3 2005/07/20 11:49:01 aaggarwa noship $

  FUNCTION invoice_purgeable(x_invoice_id IN NUMBER) RETURN BOOLEAN IS
   allow_purge BOOLEAN := FALSE;

    cursor DoesInvExist is
       select 'X'
         from dual
        where exists ( select 'X'
                         from pa_expenditure_items_all ei
                        where ei.document_header_id = x_invoice_id ) ;
                        /*  commented for R12 --from pa_cost_distribution_lines_all cdl
                        where cdl.system_reference2 = to_char(x_invoice_id) ) ; */

           dummy  VARCHAR2(1) ;
  BEGIN

       open DoesInvExist ;
       fetch DoesInvExist into dummy ;
       if DoesInvExist%found then
          allow_purge := FALSE ;
       else
          allow_purge := TRUE ;

       end if ;

       close DoesInvExist ;

       RETURN (allow_purge);

  END;

END pa_ap_trx_purge;

/
