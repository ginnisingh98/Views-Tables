--------------------------------------------------------
--  DDL for Package Body FV_AP_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_AP_MATCH_PKG" AS
-- $Header: FVAPPOMB.pls 120.0 2006/01/04 19:49:09 ksriniva noship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_AP_MATCH_PKG.';

  procedure get_default_qty(p_line_location_id in number,
                            p_qty_ord          in number,
                            p_qty_received     in number,
                            p_qty_billed       in number,
                            p_qty_cancelled    in number,
                            p_qty_accepted     in number,
                            p_qty_outstanding  out nocopy number) is
  l_module_name VARCHAR2(200) := g_module_name || 'get_default_qty';
  l_errbuf      VARCHAR2(1024);
v_rec_flag     varchar2(1);
v_ins_flag     varchar2(1);

begin

     /* find out two_way , three_way ,four way matching */

     select receipt_required_flag,inspection_required_flag
     into v_rec_flag ,v_ins_flag
     from po_line_locations
     where line_location_id = p_line_location_id;


   if v_rec_flag = 'Y'  and v_ins_flag = 'Y' then
	/** four way matching */
     p_qty_outstanding := p_qty_accepted - p_qty_cancelled - p_qty_billed;
	/** three way matching */
   elsif v_rec_flag = 'Y' and v_ins_flag = 'N' then
     p_qty_outstanding := p_qty_received - p_qty_cancelled - p_qty_billed;
   else
	/** two way matching */
     p_qty_outstanding := p_qty_ord - p_qty_cancelled - p_qty_billed;
  End if;

  /* return 0 if qty is overbiled ,AP will handle this scenario */
   if p_qty_outstanding < 0 then
      p_qty_outstanding := 0;
  End if;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   p_qty_outstanding := NULL;
WHEN OTHERS THEN
  l_errbuf := SQLERRM;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
  RAISE;
End get_default_qty;
-------------------------------------------------------------------------------
--This procedure is used to check the tolerance of a purchase order amount
--when an invoice line amount is matched with the purchase order.
--The tolerance percentage is defined on the Define Federal Options form.
-------------------------------------------------------------------------------
PROCEDURE shipment_tolerance(p_diff_amount IN NUMBER,
                             p_po_shipment_amount IN NUMBER,
                             p_tolerance_check_status OUT NOCOPY VARCHAR2) IS


  l_module_name VARCHAR2(200) := g_module_name || 'shipment_tolerance';
  l_errbuf      VARCHAR2(1024);
   l_payables_tolerance_flag VARCHAR2(1);
   l_payables_tolerance      NUMBER;
   l_billed_amount         NUMBER;
   l_total_amount          NUMBER;
   l_remain_amount         NUMBER;

   BEGIN

       p_tolerance_check_status := 'Y';

       SELECT NVL(payables_tolerance_flag, 'N'), payables_tolerance
       INTO   l_payables_tolerance_flag, l_payables_tolerance
       FROM   fv_operating_units;

       IF l_payables_tolerance_flag = 'Y' THEN
          IF   p_diff_amount >
                ((p_po_shipment_amount * l_payables_tolerance) / 100)
              THEN
              p_tolerance_check_status := 'N';
          END IF;
       END IF;

     EXCEPTION

       WHEN NO_DATA_FOUND THEN
       -- No OPTION defined for this org so pass the check
       NULL;

       WHEN OTHERS THEN
       p_tolerance_check_status := 'N';
       l_errbuf := SQLERRM;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);

  END shipment_tolerance;
-----------------------------------------------------------------------
End fv_ap_match_pkg;

/
