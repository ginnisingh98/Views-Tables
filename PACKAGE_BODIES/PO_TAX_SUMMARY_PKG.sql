--------------------------------------------------------
--  DDL for Package Body PO_TAX_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_TAX_SUMMARY_PKG" as
/* $Header: POXTAXDB.pls 115.9 2004/04/05 18:26:52 dreddy ship $ */
  FUNCTION get_recoverable_tax
	(X_header_id   number, x_line_id number, x_shipment_id number, object_type varchar2, object_location varchar2) return number is
    	 X_recoverable_tax     number;
  BEGIN
/* Bug#2459080 : In order to take in to account of the tax portion associated
with the non-cancelled quantity of the partially and fully cancelled shipments
modified the select statements for the object_type 'PO' and 'REL' for all the
object_location. Accordingly, changed the where condition of these select
statement to take in to consideration of only those shipments which are not
fully cancelled */
/* Bug# 2748176 : Added the condition
             AND  nvl(cancel_flag, 'N') <> 'Y'
             AND  nvl(closed_code, 'OPEN') <> 'FINALLY CLOSED'
   for Reqs to remove tax detail lines which have beed Cancelled.  */

-- SERVICES FPJ : Added decodes to handle amounts for service lines

    if (object_type = 'PO') then
       if (object_location = 'HEADER') then
           SELECT nvl(SUM(nvl(pod.recoverable_tax, 0) *
                  decode(pol.order_type_lookup_code, 'RATE',        -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   'FIXED PRICE',
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_recoverable_tax
           FROM   po_distributions pod,
                  po_lines pol,
                  po_line_locations pll
           WHERE  pod.po_header_id = X_header_id
            AND   pll.po_line_id = pol.po_line_id
            AND   pll.line_location_id = pod.line_location_id
            AND   pod.po_release_id is null    -- Bug 3532747
            AND   (nvl(pll.quantity,0)-nvl(pll.quantity_cancelled,0) <>  0 OR
                  nvl(pll.amount,0) - nvl(pll.amount_cancelled,0) <> 0)
            AND   nvl(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED';
       elsif (object_location = 'LINE') then
           SELECT nvl(SUM(nvl(pod.recoverable_tax, 0) *
                  decode(pol.order_type_lookup_code, 'RATE',    -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   'FIXED PRICE',
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_recoverable_tax
           FROM   po_distributions pod,
                  po_lines pol,
                  po_line_locations pll
           WHERE  pod.po_line_id = X_line_id
            AND   pll.po_line_id = pol.po_line_id
            AND   pll.line_location_id = pod.line_location_id
            AND   pod.po_release_id is null    -- Bug 3532747
            AND   (nvl(pll.quantity,0)-nvl(pll.quantity_cancelled,0) <>  0 OR
                  nvl(pll.amount,0) - nvl(pll.amount_cancelled,0) <> 0)
            AND   nvl(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED';
       elsif (object_location = 'SHIPMENT') then
           SELECT nvl(SUM(nvl(pod.recoverable_tax, 0) *
                  decode(pol.order_type_lookup_code, 'RATE',  -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   'FIXED PRICE',
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_recoverable_tax
           FROM   po_distributions pod,
                  po_lines pol
           WHERE  pod.line_location_id = X_shipment_id
            AND   pod.po_release_id is null    -- Bug 3532747
            AND   pod.po_line_id = pol.po_line_id;
       end if;
    elsif (object_type = 'REL') then
       if (object_location = 'HEADER') then
           SELECT nvl(SUM(nvl(pod.recoverable_tax, 0) *
                  decode(pol.order_type_lookup_code,
                   'FIXED PRICE',                         -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_recoverable_tax
           FROM   po_distributions  pod,
                  po_lines pol,
                  po_line_locations pll
           WHERE  pod.po_release_id = X_header_id
             AND  pll.line_location_id = pod.line_location_id
             AND   pll.po_line_id = pol.po_line_id
             AND  (nvl(pll.quantity,0)-nvl(pll.quantity_cancelled,0) <>  0 OR
                  nvl(pll.amount,0) - nvl(pll.amount_cancelled,0) <> 0)
             AND  nvl(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED';
       elsif (object_location = 'SHIPMENT') then
           SELECT nvl(SUM(nvl(pod.recoverable_tax, 0) *
                  decode(pol.order_type_lookup_code,
                   'FIXED PRICE',                         -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_recoverable_tax
           FROM   po_distributions pod,
                  po_lines pol
           WHERE  pod.line_location_id = X_shipment_id
            AND   pod.po_line_id = pol.po_line_id;
       end if;
    elsif (object_type = 'REQ') then
       if (object_location = 'HEADER') then
           SELECT nvl(SUM(prd.recoverable_tax), 0)
	      into X_recoverable_tax
           FROM   po_req_distributions prd,
	  	  po_requisition_lines prl
           WHERE  prd.requisition_line_id = prl.requisition_line_id
	     AND  prl.requisition_header_id = x_header_id
             AND  nvl(prl.cancel_flag, 'N') <> 'Y'
             AND  nvl(prl.closed_code, 'OPEN') <> 'FINALLY CLOSED';
       elsif (object_location = 'LINE') then
           SELECT nvl(SUM(recoverable_tax), 0)
	      into X_recoverable_tax
           FROM   po_req_distributions
           WHERE  requisition_line_id = X_line_id;
       end if;
    end if;
    RETURN (X_recoverable_tax);

  EXCEPTION
    WHEN OTHERS then
       x_recoverable_tax := 0;
  END get_recoverable_tax;

  FUNCTION get_nonrecoverable_tax
	(X_header_id   number, x_line_id number, x_shipment_id number, object_type varchar2, object_location varchar2) return number is
    	 X_nonrecoverable_tax     number;
  BEGIN
/* Bug#2459080 : In order to take in to account of the tax portion associated
with the non-cancelled quantity of the partially and fully cancelled shipments
modified the select statements for the object_type 'PO' and 'REL' for all the
object_location. Accordingly, changed the where condition of these select
statement to take in to consideration of only those shipments which are not
fully cancelled */
    if (object_type = 'PO') then
       if (object_location = 'HEADER') then
           SELECT nvl(SUM(nvl(pod.nonrecoverable_tax, 0) *
                  decode(pol.order_type_lookup_code, 'RATE',       -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   'FIXED PRICE',
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_nonrecoverable_tax
           FROM   po_distributions pod,
                  po_lines pol,
                  po_line_locations pll
           WHERE  pod.po_header_id = X_header_id
             AND   pll.po_line_id = pol.po_line_id
             AND  pll.line_location_id = pod.line_location_id
             AND   pod.po_release_id is null    -- Bug 3532747
             AND  (nvl(pll.quantity,0)-nvl(pll.quantity_cancelled,0) <>  0 OR
                  nvl(pll.amount,0) - nvl(pll.amount_cancelled,0) <> 0)
             AND  nvl(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED';
       elsif (object_location = 'LINE') then
           SELECT nvl(SUM(nvl(pod.nonrecoverable_tax, 0) *
                  decode(pol.order_type_lookup_code, 'RATE',          -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   'FIXED PRICE',
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_nonrecoverable_tax
           FROM   po_distributions pod,
                  po_lines pol,
                  po_line_locations pll
           WHERE  pod.po_line_id = X_line_id
             AND   pll.po_line_id = pol.po_line_id
             AND  pll.line_location_id = pod.line_location_id
             AND   pod.po_release_id is null    -- Bug 3532747
             AND  (nvl(pll.quantity,0)-nvl(pll.quantity_cancelled,0) <>  0 OR
                  nvl(pll.amount,0) - nvl(pll.amount_cancelled,0) <> 0)
             AND  nvl(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED';
       elsif (object_location = 'SHIPMENT') then
           SELECT nvl(SUM(nvl(pod.nonrecoverable_tax, 0) *
                  decode(pol.order_type_lookup_code, 'RATE',         -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   'FIXED PRICE',
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_nonrecoverable_tax
           FROM   po_distributions pod,
                  po_lines pol
           WHERE  pod.line_location_id = X_shipment_id
             AND   pod.po_release_id is null    -- Bug 3532747
             AND   pod.po_line_id = pol.po_line_id;
       end if;
    elsif (object_type = 'REL') then
       if (object_location = 'HEADER') then
           SELECT nvl(SUM(nvl(pod.nonrecoverable_tax, 0) *
                  decode(pol.order_type_lookup_code,
                   'FIXED PRICE',                       -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_nonrecoverable_tax
           FROM   po_distributions pod,
                  po_lines pol,
                  po_line_locations pll
           WHERE  pod.po_release_id = X_header_id
             AND   pll.po_line_id = pol.po_line_id
             AND  pll.line_location_id = pod.line_location_id
             AND  (nvl(pll.quantity,0)-nvl(pll.quantity_cancelled,0) <>  0 OR
                  nvl(pll.amount,0) - nvl(pll.amount_cancelled,0) <> 0)
             AND  nvl(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED';
       elsif (object_location = 'SHIPMENT') then
           SELECT nvl(SUM(nvl(pod.nonrecoverable_tax, 0) *
                  decode(pol.order_type_lookup_code,
                   'FIXED PRICE',                         -- SERVICES FPJ
                   ((nvl(pod.amount_ordered,0) - nvl(pod.amount_cancelled,0))/nvl(pod.amount_ordered,0)),
                   ((nvl(pod.quantity_ordered,0)-nvl(pod.quantity_cancelled,0))
                   / nvl(pod.quantity_ordered,0))  )),  0)
	      into X_nonrecoverable_tax
           FROM   po_distributions pod,
                  po_lines pol
           WHERE  pod.line_location_id = X_shipment_id
            AND   pod.po_line_id = pol.po_line_id;
       end if;
    elsif (object_type = 'REQ') then
       if (object_location = 'HEADER') then
           SELECT nvl(SUM(prd.nonrecoverable_tax), 0)
	      into X_nonrecoverable_tax
           FROM   po_req_distributions prd,
	  	  po_requisition_lines prl
           WHERE  prd.requisition_line_id = prl.requisition_line_id
	     AND  prl.requisition_header_id = x_header_id
             AND  nvl(prl.cancel_flag, 'N') <> 'Y'
             AND  nvl(prl.closed_code, 'OPEN') <> 'FINALLY CLOSED';
       elsif (object_location = 'LINE') then
           SELECT nvl(SUM(nonrecoverable_tax), 0)
	      into X_nonrecoverable_tax
           FROM   po_req_distributions
           WHERE  requisition_line_id = X_line_id;
       end if;
    end if;
    RETURN (X_nonrecoverable_tax);

  EXCEPTION
    WHEN OTHERS then
       x_nonrecoverable_tax := 0;
  END get_nonrecoverable_tax;

  FUNCTION get_header_amount
	(X_header_id   number,
         object_type varchar2,
         X_currency_code     varchar2) return number is

         X_header_amount     number;
         X_precision         number;   -- Bug#2767208
         X_ext_precision     number;   -- Bug#2767208
         X_min_acct_unit     number;   -- Bug#2767208

         l_is_local_blanket  BOOLEAN;  -- bug3426902

  BEGIN

/* Bug#2767208 : Added the following function call to get the document
   currency precision and minimum accountable unit */

        fnd_currency.get_info(X_currency_code,
                              X_precision,
                              X_ext_precision,
                              X_min_acct_unit);

    if (object_type = 'PO') then

      -- bug3426902 START
      -- For Local Blanket Release, we should show amount field with the
      -- total amount released for the blanket

      l_is_local_blanket := PO_GA_PVT.is_local_document
                            ( p_po_header_id => x_header_id,
                              p_type_lookup_code => 'BLANKET'
                            );

      IF (l_is_local_blanket) THEN

        IF (x_min_acct_unit IS NOT NULL) THEN

            --SQL WHAT: Calculate amount released for a blanket header.
            --          This amount is rounded based on mau
            --SQL WHY:  For local blanket, we return amount released as
            --          the amount of the blanket
            SELECT  NVL(
                      SUM(
                        ROUND(
                          DECODE(POL.order_type_lookup_code,
                                 'FIXED PRICE',
                                 PLL.amount - NVL(PLL.amount_cancelled, 0),
                                 (PLL.quantity -
                                  NVL(PLL.quantity_cancelled, 0)) *
                                   price_override
                                ) / x_min_acct_unit
                        ) * x_min_acct_unit
                      ), 0
                    )
            INTO    x_header_amount
            FROM    po_line_locations PLL,
                    po_lines POL
            WHERE   PLL.po_line_id = POL.po_line_id
            AND     POL.po_header_id = x_header_id
            AND     PLL.shipment_type = 'BLANKET';

        ELSE

            --SQL WHAT: Calculate amount released for a blanket header.
            --          This amount is rounded based on precision
            --SQL WHY:  For local blanket, we return amount released as
            --          the amount of the blanket
            SELECT  NVL(
                      SUM(
                        ROUND(
                          DECODE(POL.order_type_lookup_code,
                                 'FIXED PRICE',
                                 PLL.amount - NVL(PLL.amount_cancelled, 0),
                                 (PLL.quantity -
                                  NVL(PLL.quantity_cancelled, 0)) *
                                   price_override
                                ),
                          x_precision
                        )
                      ), 0
                    )
            INTO    x_header_amount
            FROM    po_line_locations PLL,
                    po_lines POL
            WHERE   PLL.po_line_id = POL.po_line_id
            AND     POL.po_header_id = x_header_id
            AND     PLL.shipment_type = 'BLANKET';

        END IF;

      ELSE  -- if document is not a local blanket

      -- bug3426902 END
      -- If document is not a local blanket, calculate the total amount
      -- of its own

/* Bug#2767208 : The line amount should be first rounded and then summed
   up to calculate the header amount. Hence added the following if-else
   condition which rounds the line amount to minmum accountable unit/
   precision and then sums up the rounded line amount */

        if(X_min_acct_unit is not null) then

            SELECT nvl(SUM(round(decode(order_type_lookup_code,'RATE',amount,'FIXED PRICE', amount,
                                        unit_price * quantity)/X_min_acct_unit)
                               *X_min_acct_unit), 0)
               into X_header_amount
            FROM   po_lines
            WHERE  po_header_id = X_header_id
              AND  nvl(cancel_flag, 'N') <> 'Y'
              AND  nvl(closed_code, 'OPEN') <> 'FINALLY CLOSED';

       else
            SELECT nvl(SUM(round(decode(order_type_lookup_code,'RATE',amount,'FIXED PRICE', amount,
                                 unit_price * quantity), X_precision)), 0)
               into X_header_amount
            FROM   po_lines
            WHERE  po_header_id = X_header_id
              AND  nvl(cancel_flag, 'N') <> 'Y'
              AND  nvl(closed_code, 'OPEN') <> 'FINALLY CLOSED';

        end if;

      END IF;

    elsif (object_type = 'REL') then

/* Bug#2767208 : The line amount should be first rounded and then summed
   up to calculate the header amount. Hence added the following if-else
   condition which rounds the line amount to minmum accountable unit/
   precision and then sums up the rounded line amount */

       if(X_min_acct_unit is not null) then

           SELECT nvl(SUM(round(decode(pol.order_type_lookup_code,'FIXED PRICE',pll.amount,
                                pll.price_override * pll.quantity)/X_min_acct_unit)
                              *X_min_acct_unit), 0)              -- SERVICES FPJ
	      into X_header_amount
           FROM   po_line_locations pll,
                  po_lines pol
           WHERE  pll.po_release_id = X_header_id
             AND  pol.po_line_id = pll.po_line_id
             AND  nvl(pll.cancel_flag, 'N') <> 'Y'
             AND  nvl(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

       else
           SELECT nvl(SUM(round(decode(pol.order_type_lookup_code,'FIXED PRICE',pll.amount,
                          pll.price_override * pll.quantity),X_precision)), 0)       -- SERVICES FPJ
              into X_header_amount
           FROM   po_line_locations pll,
                  po_lines pol
           WHERE  pll.po_release_id = X_header_id
             AND  pol.po_line_id = pll.po_line_id
             AND  nvl(pll.cancel_flag, 'N') <> 'Y'
             AND  nvl(pll.closed_code, 'OPEN') <> 'FINALLY CLOSED';

       end if;

    elsif (object_type = 'REQ') then

/* Bug#2767208 : The line amount should be first rounded and then summed
   up to calculate the header amount. Hence added the following if-else
   condition which rounds the line amount to minmum accountable unit/
   precision and then sums up the rounded line amount */

       if(X_min_acct_unit is not null) then

           SELECT nvl(SUM(round(decode(order_type_lookup_code,'RATE',amount,'FIXED PRICE', amount,
                         unit_price * quantity)/X_min_acct_unit)
                              *X_min_acct_unit), 0)             -- SERVICES FPJ
	      into X_header_amount
           FROM   po_requisition_lines
           WHERE  requisition_header_id = x_header_id
             AND  nvl(cancel_flag, 'N') <> 'Y'
             AND  nvl(closed_code, 'OPEN') <> 'FINALLY CLOSED';

       else
           SELECT nvl(SUM(round(decode(order_type_lookup_code,'RATE',amount,'FIXED PRICE', amount,
                            unit_price * quantity),X_precision)), 0)      -- SERVICES FPJ
              into X_header_amount
           FROM   po_requisition_lines
           WHERE  requisition_header_id = x_header_id;

       end if;

    end if;
    RETURN (X_header_amount);

  EXCEPTION
    WHEN OTHERS then
       x_header_amount := 0;
  END get_header_amount;


-- bug3426902 START

-----------------------------------------------------------------------
--Start of Comments
--Name: get_line_amount
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: For Standard and Planned PO, it returns the amount of
--          a PO line; for local blanket, it returns the amount released
--          of the blanket line.
--Parameters:
--IN:
--p_line_id
--  unique identifier of a line in PO_LINES_ALL
--p_currency_code
--  Currency of the document
--IN OUT:
--OUT:
--Returns: Amount of the line
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION get_line_amount (p_line_id IN VARCHAR2,
                          p_currency_code IN VARCHAR2)
RETURN NUMBER IS

l_precision     FND_CURRENCIES.precision%TYPE;
l_ext_precision FND_CURRENCIES.extended_precision%TYPE;
l_min_acct_unit FND_CURRENCIES.minimum_accountable_unit%TYPE;
l_line_amount   NUMBER;

BEGIN

    FND_CURRENCY.get_info(p_currency_code,
                          l_precision,
                          l_ext_precision,
                          l_min_acct_unit);

    IF (l_min_acct_unit IS NOT NULL) THEN

        --SQL WHAT: Calculate amount released for a PO/Blanket line.
        --          This amount is rounded based on currency mau
        --SQL WHY:  The result is what this function returns
        SELECT  NVL(
                  SUM(
                    ROUND(
                      DECODE(POL.order_type_lookup_code,
                             'FIXED PRICE',
                             PLL.amount - NVL(PLL.amount_cancelled, 0),
                             'RATE',
                             PLL.amount - NVL(PLL.amount_cancelled, 0),
                             (PLL.quantity - NVL(PLL.quantity_cancelled, 0)) *
                               price_override
                            ) / l_min_acct_unit
                    ) * l_min_acct_unit
                  ), 0
                )
        INTO    l_line_amount
        FROM    po_line_locations PLL,
                po_lines POL
        WHERE   PLL.po_line_id = POL.po_line_id
        AND     POL.po_line_id = p_line_id
        AND     PLL.shipment_type IN ('STANDARD', 'PLANNED', 'BLANKET');

    ELSE

        --SQL WHAT: Calculate amount released for a PO/Blanket line.
        --          This amount is rounded based on currency precision
        --SQL WHY:  The result is what this function returns
        SELECT  NVL(
                  SUM(
                    ROUND(
                      DECODE(POL.order_type_lookup_code,
                             'FIXED PRICE',
                             PLL.amount - NVL(PLL.amount_cancelled, 0),
                             'RATE',
                             PLL.amount - NVL(PLL.amount_cancelled, 0),
                             (PLL.quantity - NVL(PLL.quantity_cancelled, 0)) *
                               price_override
                            ),
                      l_precision
                    )
                  ), 0
                )
        INTO    l_line_amount
        FROM    po_line_locations PLL,
                po_lines POL
        WHERE   PLL.po_line_id = POL.po_line_id
        AND     POL.po_line_id = p_line_id
        AND     PLL.shipment_type IN ('STANDARD', 'PLANNED', 'BLANKET');

    END IF;

    RETURN l_line_amount;

END get_line_amount;

-- bug3426902 END

END PO_TAX_SUMMARY_PKG;

/
