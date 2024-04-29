--------------------------------------------------------
--  DDL for Package Body POGOT_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POGOT_S" AS
/* $Header: POGOTB.pls 115.7 2002/11/25 19:51:48 sbull ship $*/
/*===========================================================================
  PROCEDURE NAME: GET_CURRENCY_INFO
===========================================================================*/
PROCEDURE GET_CURRENCY_INFO (x_currency_code IN VARCHAR2,
                             x_precision    OUT NOCOPY NUMBER,
                             x_min_unit     OUT NOCOPY NUMBER ) is
  x_ext_precision NUMBER;
  x_progress      VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;
  fnd_currency.get_info(x_currency_code,
                        x_precision,
                        x_ext_precision,
                        x_min_unit );
  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_currency_info', x_progress, sqlcode);
    RAISE;
END GET_CURRENCY_INFO;
/*===========================================================================
  PROCEDURE NAME: GET_PO_CURRENCY
===========================================================================*/
PROCEDURE GET_PO_CURRENCY (x_object_id      IN NUMBER,
                           x_base_currency OUT NOCOPY VARCHAR2,
                           x_po_currency   OUT NOCOPY VARCHAR2) is
  x_progress      VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;

  SELECT GSB.currency_code,
         POH.currency_code
  INTO   x_base_currency,
         x_po_currency
  FROM   PO_HEADERS POH,
         FINANCIALS_SYSTEM_PARAMETERS FSP,
         GL_SETS_OF_BOOKS GSB
  WHERE  POH.po_header_id    = x_object_id
  AND    FSP.set_of_books_id = GSB.set_of_books_id;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_po_currency', x_progress, sqlcode);
    RAISE;
END GET_PO_CURRENCY;
/*===========================================================================
  PROCEDURE NAME: GET_REQ_CURRENCY
===========================================================================*/
PROCEDURE GET_REQ_CURRENCY (x_object_id       IN NUMBER,
                            x_base_currency  OUT NOCOPY VARCHAR2 ) is
  x_progress      VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;

  SELECT GSB.currency_code
  INTO   x_base_currency
  FROM   FINANCIALS_SYSTEM_PARAMETERS FSP,
         GL_SETS_OF_BOOKS GSB
  WHERE  FSP.set_of_books_id = GSB.set_of_books_id;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_req_currency', x_progress, sqlcode);
    RAISE;
END GET_REQ_CURRENCY;

/*===========================================================================
  FUNCTION NAME:	get_total

===========================================================================*/
FUNCTION  get_total (x_object_type     IN VARCHAR2,
                     x_object_id       IN NUMBER,
                     x_base_cur_result IN BOOLEAN) RETURN NUMBER IS
  x_progress       VARCHAR2(3) := NULL;
  x_base_currency  VARCHAR2(16);
  x_po_currency    VARCHAR2(16);
  x_min_unit       NUMBER;
  x_base_min_unit  NUMBER;
  x_precision      INTEGER;
  x_base_precision INTEGER;
  x_result_fld     NUMBER;
BEGIN

  if (x_object_type in ('H','B') ) then

    if x_base_cur_result then
      /* Result should be returned in base currency. Get the currency code
         of the PO and the base currency code
      */
      x_progress := 10;
      get_po_currency (x_object_id,
                       x_base_currency,
                       x_po_currency );

      /* Chk if base_currency = po_currency */
      if x_base_currency <> x_po_currency then
        /* Get precision and minimum accountable unit of the PO CURRENCY */
        x_progress := 20;
        get_currency_info (x_po_currency,
                           x_precision,
                           x_min_unit );

        /* Get precision and minimum accountable unit of the base CURRENCY */
        x_progress := 30;
        get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );


        x_progress := 40;
        SELECT
        nvl(sum
        (decode (x_base_min_unit, NULL,
                 round (decode (x_min_unit, NULL,
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0), x_precision),
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0) / x_min_unit) * x_min_unit)
                         * POD.rate, x_base_precision),
                 round (decode (x_min_unit, NULL,
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0), x_precision),
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0) / x_min_unit) *
                         x_min_unit) * POD.rate / x_base_min_unit) *
                         x_base_min_unit)), 0)
        INTO   x_result_fld
        FROM   PO_DISTRIBUTIONS POD, PO_LINE_LOCATIONS PLL
        WHERE  PLL.po_header_id     = x_object_id
        AND    PLL.shipment_type   in ('STANDARD','PLANNED', 'BLANKET')
        AND    PLL.line_location_id = POD.line_location_id;

      end if;  /* x_base_currency <> x_po_currency */

    else

      /* if we donot want result converted to base currency or if
         the currencies are the same then do the check without
         rate conversion */
      x_progress := 50;
      SELECT
      sum( decode (C.minimum_accountable_unit, NULL,
                   round ((PLL.quantity -
                           nvl(PLL.quantity_cancelled, 0)
                           ) * nvl(PLL.price_override, 0), C.precision),
                   round ((PLL.quantity -
                           nvl(PLL.quantity_cancelled, 0)
                           ) * nvl(PLL.price_override, 0) /
                           C.minimum_accountable_unit
                          ) * C.minimum_accountable_unit))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS PLL,
             PO_HEADERS PH,
             FND_CURRENCIES C
      WHERE  PLL.po_header_id   = x_object_id
      AND    PH.po_header_id    = PLL.po_header_id
      AND    PH.currency_code   = C.currency_code
      AND    PLL.shipment_type in ('STANDARD','PLANNED','BLANKET');

    end if;

  elsif (x_object_type = 'P') then /* For PO Planned */

    if x_base_cur_result then

      /* Result should be returned in base currency. Get the currency code
         of the PO and the base currency code */

      x_progress := 60;
      get_po_currency (x_object_id,
                       x_base_currency,
                       x_po_currency );

      /* Chk if base_currency = po_currency */
      if x_base_currency <> x_po_currency then
        /* Get precision and minimum accountable unit of the PO CURRENCY */
        x_progress := 70;
        get_currency_info (x_po_currency,
                           x_precision,
                           x_min_unit );

        /* Get precision and minimum accountable unit of the base CURRENCY */
        x_progress := 80;
        get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );


        x_progress := 90;
        SELECT
        nvl(sum
        (decode (x_base_min_unit, NULL,
                 round (decode (x_min_unit, NULL,
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0), x_precision),
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0) / x_min_unit) * x_min_unit)
                         * POD.rate, x_base_precision),
                 round (decode (x_min_unit, NULL,
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0), x_precision),
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0) / x_min_unit) *
                         x_min_unit) * POD.rate / x_base_min_unit) *
                         x_base_min_unit)), 0)
        INTO   x_result_fld
        FROM   PO_DISTRIBUTIONS POD, PO_LINE_LOCATIONS PLL
        WHERE  PLL.po_header_id     = x_object_id
        AND    PLL.shipment_type    = 'SCHEDULED'
        AND    PLL.line_location_id = POD.line_location_id;

      end if;  /* x_base_currency <> x_po_currency */

    else

      /* if we donot want result converted to base currency or if
         the currencies are the same then do the check without
         rate conversion */
      x_progress := 100;
      SELECT
      sum( decode (C.minimum_accountable_unit, NULL,
                   round ((PLL.quantity -
                           nvl(PLL.quantity_cancelled, 0)
                           ) * nvl(PLL.price_override, 0), C.precision),
                   round ((PLL.quantity -
                           nvl(PLL.quantity_cancelled, 0)
                           ) * nvl(PLL.price_override, 0) /
                           C.minimum_accountable_unit
                          ) * C.minimum_accountable_unit))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS PLL,
             PO_HEADERS PH,
             FND_CURRENCIES C
      WHERE  PLL.po_header_id   = x_object_id
      AND    PH.po_header_id    = PLL.po_header_id
      AND    PH.currency_code   = C.currency_code
      AND    PLL.shipment_type  = 'SCHEDULED';

    end if;

  elsif (x_object_type = 'E' ) then /* Requisition Header */
    x_progress := 110;
    get_req_currency (x_object_id,
                      x_base_currency );

    x_progress := 120;
    get_currency_info (x_base_currency,
                       x_base_precision,
                       x_base_min_unit );

    x_progress := 130;
    SELECT
    sum( decode
       ( x_base_min_unit, NULL,
         round( nvl(quantity, 0) * nvl(unit_price, 0), x_base_precision),
         round( nvl(quantity, 0) * nvl(unit_price, 0) / x_base_min_unit)
              * x_base_min_unit))
    INTO   x_result_fld
    FROM   PO_REQUISITION_LINES
    WHERE  requisition_header_id            = x_object_id
    AND    nvl(cancel_flag, 'N')            = 'N'
    AND    nvl(modified_by_agent_flag, 'N') = 'N';

  elsif (x_object_type = 'I' ) then /* Requisition Line */

    x_progress := 140;
    get_req_currency (x_object_id,
                      x_base_currency );

    x_progress := 150;
    get_currency_info (x_base_currency,
                       x_base_precision,
                       x_base_min_unit );

    x_progress := 160;
    SELECT
    sum( decode
       ( x_base_min_unit, NULL,
         round( nvl(quantity, 0) * nvl(unit_price, 0), x_base_precision),
         round( nvl(quantity, 0) * nvl(unit_price, 0) / x_base_min_unit)
              * x_base_min_unit))
    INTO   x_result_fld
    FROM   PO_REQUISITION_LINES
    WHERE  requisition_line_id              = x_object_id
    AND    nvl(cancel_flag, 'N')            = 'N'
    AND    nvl(modified_by_agent_flag, 'N') = 'N';

  elsif (x_object_type = 'C' ) then /* Contract */

    x_progress := 170;
    SELECT
    nvl( sum
         (decode (C.minimum_accountable_unit, NULL,
                 round ((nvl(PLL.quantity,0) -
                         nvl(PLL.quantity_cancelled, 0) -
                         sum (nvl(PLL2.quantity, 0) -
                              nvl(PLL2.quantity_cancelled,0)))
                         * nvl(PLL.price_override,0), C.precision),
                 round ((nvl(PLL.quantity,0) -
                         nvl(PLL.quantity_cancelled, 0) -
                         sum (nvl(PLL2.quantity, 0) -
                              nvl(PLL2.quantity_cancelled,0)))
                         * nvl(PLL.price_override,0) /
                           C.minimum_accountable_unit) *
                         C.minimum_accountable_unit)), 0)
    INTO   x_result_fld
    FROM   PO_LINE_LOCATIONS PLL,
           PO_LINE_LOCATIONS PLL2,
           PO_LINES PL,
           PO_HEADERS PH,
           FND_CURRENCIES C
    WHERE  PH.po_header_id      = x_object_id
    AND    PH.segment1          = PL.contract_num
    AND    PH.currency_code     = C.currency_code
    AND    PL.po_line_id        = PLL.po_line_id
    AND    PLL.shipment_type in ('STANDARD','PLANNED','BLANKET','SCHEDULED')
    AND    PLL.line_location_id = PLL2.source_shipment_id (+)
    GROUP BY C.minimum_accountable_unit, C.precision,
             PLL.quantity, PLL.quantity_cancelled,
             PLL.price_override, PLL.line_location_id;

  elsif (x_object_type = 'R' ) then /* Release */

    if x_base_cur_result then
      x_progress := 180;
      SELECT GSB.currency_code,
             POH.currency_code
      INTO   x_base_currency,
             x_po_currency
      FROM   PO_HEADERS POH,
             FINANCIALS_SYSTEM_PARAMETERS FSP,
             GL_SETS_OF_BOOKS GSB,
             PO_RELEASES POR
      WHERE  POH.po_header_id    = POR.po_header_id
      AND    POR.po_release_id   = x_object_id
      AND    FSP.set_of_books_id = GSB.set_of_books_id;

      if (x_base_currency <> x_po_currency) then
        /* Get precision and minimum accountable unit of the PO CURRENCY */
        x_progress := 190;
        get_currency_info (x_po_currency,
                           x_precision,
                           x_min_unit );

        /* Get precision and minimum accountable unit of the base CURRENCY */
        x_progress := 200;
        get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );


        x_progress := 210;
        SELECT
        nvl(sum (decode (x_base_min_unit, NULL,
                 round ( ( decode (x_min_unit, NULL,
                           round ((nvl(POD.quantity_ordered, 0) *
                                   nvl(PLL.price_override, 0)), x_precision),
                           round ((nvl(POD.quantity_ordered, 0) *
                                   nvl(PLL.price_override, 0) / x_min_unit))
                                   * x_min_unit) * POD.rate), x_base_precision),
                           round ( ( decode (x_min_unit, NULL,
                           round ((nvl(POD.quantity_ordered, 0) *
                                   nvl(PLL.price_override, 0)), x_precision),
                           round ((nvl(POD.quantity_ordered, 0) *
                                   nvl(PLL.price_override, 0) / x_min_unit)
                                   ) * x_min_unit) * POD.rate) / x_base_min_unit
                                   ) * x_base_min_unit)), 0)
         INTO x_result_fld
         FROM PO_DISTRIBUTIONS POD, PO_LINE_LOCATIONS PLL
         WHERE PLL.po_release_id    = x_object_id
         AND   PLL.line_location_id = POD.line_location_id
         AND   PLL.shipment_type in ('SCHEDULED','BLANKET');

      end if;
    else
      x_progress := 220;
      SELECT
      sum( decode (C.minimum_accountable_unit, NULL,
            round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                     * nvl(POL.price_override, 0), C.precision),
            round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                    * nvl(POL.price_override, 0) /
                    C.minimum_accountable_unit) * C.minimum_accountable_unit))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS POL, PO_HEADERS POH,
             FND_CURRENCIES C
      WHERE  POL.po_release_id = x_object_id
      AND    POH.po_header_id  = POL.po_header_id
      AND    POH.currency_code = C.currency_code
      AND    POL.shipment_type in ('SCHEDULED','BLANKET');

    end if;

  elsif (x_object_type = 'L' ) then /* Po Line */
    x_progress := 230;
    SELECT
    sum( decode (C.minimum_accountable_unit, NULL,
                 round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                         * nvl(POL.price_override, 0), C.precision),
                 round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                         * nvl(POL.price_override, 0) /
                         C.minimum_accountable_unit)
                         * C.minimum_accountable_unit))
    INTO   x_result_fld
    FROM   PO_LINE_LOCATIONS POL, PO_HEADERS POH,
           FND_CURRENCIES C
    WHERE  POL.po_line_id    = x_object_id
    AND    POH.po_header_id  = POL.po_header_id
    AND    POH.currency_code = C.currency_code
    AND    POL.shipment_type in ('STANDARD','PLANNED','BLANKET');

  elsif (x_object_type = 'S' ) then /* PO Shipment */
    x_progress := 240;
    SELECT
    sum( decode (C.minimum_accountable_unit, NULL,
                 round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                         * nvl(POL.price_override, 0), C.precision),
                 round ((POL.quantity - nvl(POL.quantity_cancelled , 0))
                         * nvl(POL.price_override, 0) /
                         C.minimum_accountable_unit)
                         * C.minimum_accountable_unit))
    INTO   x_result_fld
    FROM   PO_LINE_LOCATIONS POL, PO_HEADERS POH,
           FND_CURRENCIES C
    WHERE  line_location_id  = x_object_id
    AND    POH.po_header_id  = POL.po_header_id
    AND    POH.currency_code = C.currency_code;

  end if; /* x_object_type */

  RETURN(x_result_fld);

  EXCEPTION
  WHEN OTHERS THEN
    RETURN(0);
    po_message_s.sql_error('get_total', x_progress, sqlcode);
    RAISE;

END get_total;
/*===========================================================================
  PROCEDURE NAME: ECX_GET_PO_CURRENCY
===========================================================================*/
PROCEDURE ECX_GET_PO_CURRENCY (x_object_id      IN NUMBER,
                           x_base_currency OUT NOCOPY VARCHAR2,
                           x_po_currency   OUT NOCOPY VARCHAR2) is
  x_progress      VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;

  SELECT GSB.currency_code,
         POH.currency_code
  INTO   x_base_currency,
         x_po_currency
  FROM   PO_HEADERS_ALL POH,
         FINANCIALS_SYSTEM_PARAMETERS FSP,
         GL_SETS_OF_BOOKS GSB
  WHERE  POH.po_header_id    = x_object_id
  AND    FSP.set_of_books_id = GSB.set_of_books_id;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_po_currency', x_progress, sqlcode);
    RAISE;
END ECX_GET_PO_CURRENCY;

/*===========================================================================
  FUNCTION NAME:	ecx_get_total

===========================================================================*/
FUNCTION  ecx_get_total (x_object_type     IN VARCHAR2,
                     x_object_id       IN NUMBER,
                     x_po_currency IN VARCHAR2) RETURN NUMBER IS
  x_progress       VARCHAR2(3) := NULL;
  x_base_currency  VARCHAR2(16);
  x_po_currency_1    VARCHAR2(16);
  x_min_unit       NUMBER;
  x_base_min_unit  NUMBER;
  x_precision      INTEGER;
  x_base_precision INTEGER;
  x_result_fld     NUMBER;
  x_base_cur_result BOOLEAN;
BEGIN

   x_base_cur_result:=FALSE;

  if (x_object_type in ('H','B') ) then

    if x_base_cur_result then
      /* Result should be returned in base currency. Get the currency code
         of the PO and the base currency code
      */
      x_progress := 10;
      ecx_get_po_currency (x_object_id,
                       x_base_currency,
                       x_po_currency_1 );

      /* Chk if base_currency = po_currency */
      if x_base_currency <> x_po_currency_1 then
        /* Get precision and minimum accountable unit of the PO CURRENCY */
        x_progress := 20;
        get_currency_info (x_po_currency,
                           x_precision,
                           x_min_unit );

        /* Get precision and minimum accountable unit of the base CURRENCY */
        x_progress := 30;
        get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );


        x_progress := 40;
        SELECT
        nvl(sum
        (decode (x_base_min_unit, NULL,
                 round (decode (x_min_unit, NULL,
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0), x_precision),
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0) / x_min_unit) * x_min_unit)
                         * POD.rate, x_base_precision),
                 round (decode (x_min_unit, NULL,
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0), x_precision),
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0) / x_min_unit) *
                         x_min_unit) * POD.rate / x_base_min_unit) *
                         x_base_min_unit)), 0)
        INTO   x_result_fld
        FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
        WHERE  PLL.po_header_id     = x_object_id
        AND    PLL.shipment_type   in ('STANDARD','PLANNED', 'BLANKET')
        AND    PLL.line_location_id = POD.line_location_id;

      end if;  /* x_base_currency <> x_po_currency_1 */

    else

      /* if we donot want result converted to base currency or if
         the currencies are the same then do the check without
         rate conversion */
      x_progress := 50;
      SELECT
      sum( decode (C.minimum_accountable_unit, NULL,
                   round ((PLL.quantity -
                           nvl(PLL.quantity_cancelled, 0)
                           ) * nvl(PLL.price_override, 0), C.precision),
                   round ((PLL.quantity -
                           nvl(PLL.quantity_cancelled, 0)
                           ) * nvl(PLL.price_override, 0) /
                           C.minimum_accountable_unit
                          ) * C.minimum_accountable_unit))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS_ALL PLL,
             PO_HEADERS_ALL PH,
             FND_CURRENCIES C
      WHERE  PLL.po_header_id   = x_object_id
      AND    PH.po_header_id    = PLL.po_header_id
      AND    PH.currency_code   = C.currency_code
      AND    PLL.shipment_type in ('STANDARD','PLANNED','BLANKET');

    end if;

  elsif (x_object_type = 'P') then /* For PO Planned */

    if x_base_cur_result then

      /* Result should be returned in base currency. Get the currency code
         of the PO and the base currency code */

      x_progress := 60;
      ecx_get_po_currency (x_object_id,
                       x_base_currency,
                       x_po_currency_1 );

      /* Chk if base_currency = po_currency */
      if x_base_currency <> x_po_currency_1 then
        /* Get precision and minimum accountable unit of the PO CURRENCY */
        x_progress := 70;
        get_currency_info (x_po_currency_1,
                           x_precision,
                           x_min_unit );

        /* Get precision and minimum accountable unit of the base CURRENCY */
        x_progress := 80;
        get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );


        x_progress := 90;
        SELECT
        nvl(sum
        (decode (x_base_min_unit, NULL,
                 round (decode (x_min_unit, NULL,
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0), x_precision),
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0) / x_min_unit) * x_min_unit)
                         * POD.rate, x_base_precision),
                 round (decode (x_min_unit, NULL,
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0), x_precision),
                 round ((nvl(POD.quantity_ordered, 0) -
                         nvl(POD.quantity_cancelled, 0)) *
                         nvl(PLL.price_override, 0) / x_min_unit) *
                         x_min_unit) * POD.rate / x_base_min_unit) *
                         x_base_min_unit)), 0)
        INTO   x_result_fld
        FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
        WHERE  PLL.po_header_id     = x_object_id
        AND    PLL.shipment_type    = 'SCHEDULED'
        AND    PLL.line_location_id = POD.line_location_id;

      end if;  /* x_base_currency <> x_po_currency_1 */

    else

      /* if we donot want result converted to base currency or if
         the currencies are the same then do the check without
         rate conversion */
      x_progress := 100;
      SELECT
      sum( decode (C.minimum_accountable_unit, NULL,
                   round ((PLL.quantity -
                           nvl(PLL.quantity_cancelled, 0)
                           ) * nvl(PLL.price_override, 0), C.precision),
                   round ((PLL.quantity -
                           nvl(PLL.quantity_cancelled, 0)
                           ) * nvl(PLL.price_override, 0) /
                           C.minimum_accountable_unit
                          ) * C.minimum_accountable_unit))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS_ALL PLL,
             PO_HEADERS_ALL PH,
             FND_CURRENCIES C
      WHERE  PLL.po_header_id   = x_object_id
      AND    PH.po_header_id    = PLL.po_header_id
      AND    PH.currency_code   = C.currency_code
      AND    PLL.shipment_type  = 'SCHEDULED';

    end if;

  elsif (x_object_type = 'E' ) then /* Requisition Header */
    x_progress := 110;
    get_req_currency (x_object_id,
                      x_base_currency );

    x_progress := 120;
    get_currency_info (x_base_currency,
                       x_base_precision,
                       x_base_min_unit );

    x_progress := 130;
    SELECT
    sum( decode
       ( x_base_min_unit, NULL,
         round( nvl(quantity, 0) * nvl(unit_price, 0), x_base_precision),
         round( nvl(quantity, 0) * nvl(unit_price, 0) / x_base_min_unit)
              * x_base_min_unit))
    INTO   x_result_fld
    FROM   PO_REQUISITION_LINES_ALL
    WHERE  requisition_header_id            = x_object_id
    AND    nvl(cancel_flag, 'N')            = 'N'
    AND    nvl(modified_by_agent_flag, 'N') = 'N';

  elsif (x_object_type = 'I' ) then /* Requisition Line */

    x_progress := 140;
    get_req_currency (x_object_id,
                      x_base_currency );

    x_progress := 150;
    get_currency_info (x_base_currency,
                       x_base_precision,
                       x_base_min_unit );

    x_progress := 160;
    SELECT
    sum( decode
       ( x_base_min_unit, NULL,
         round( nvl(quantity, 0) * nvl(unit_price, 0), x_base_precision),
         round( nvl(quantity, 0) * nvl(unit_price, 0) / x_base_min_unit)
              * x_base_min_unit))
    INTO   x_result_fld
    FROM   PO_REQUISITION_LINES_ALL
    WHERE  requisition_line_id              = x_object_id
    AND    nvl(cancel_flag, 'N')            = 'N'
    AND    nvl(modified_by_agent_flag, 'N') = 'N';

  elsif (x_object_type = 'C' ) then /* Contract */

    x_progress := 170;
    SELECT
    nvl( sum
         (decode (C.minimum_accountable_unit, NULL,
                 round ((nvl(PLL.quantity,0) -
                         nvl(PLL.quantity_cancelled, 0) -
                         sum (nvl(PLL2.quantity, 0) -
                              nvl(PLL2.quantity_cancelled,0)))
                         * nvl(PLL.price_override,0), C.precision),
                 round ((nvl(PLL.quantity,0) -
                         nvl(PLL.quantity_cancelled, 0) -
                         sum (nvl(PLL2.quantity, 0) -
                              nvl(PLL2.quantity_cancelled,0)))
                         * nvl(PLL.price_override,0) /
                           C.minimum_accountable_unit) *
                         C.minimum_accountable_unit)), 0)
    INTO   x_result_fld
    FROM   PO_LINE_LOCATIONS_ALL PLL,
           PO_LINE_LOCATIONS_ALL PLL2,
           PO_LINES_ALL PL,
           PO_HEADERS_ALL PH,
           FND_CURRENCIES C
    WHERE  PH.po_header_id      = x_object_id
    AND    PH.segment1          = PL.contract_num
    AND    PH.currency_code     = C.currency_code
    AND    PL.po_line_id        = PLL.po_line_id
    AND    PLL.shipment_type in ('STANDARD','PLANNED','BLANKET','SCHEDULED')
    AND    PLL.line_location_id = PLL2.source_shipment_id (+)
    GROUP BY C.minimum_accountable_unit, C.precision,
             PLL.quantity, PLL.quantity_cancelled,
             PLL.price_override, PLL.line_location_id;

  elsif (x_object_type = 'R' ) then /* Release */

    if x_base_cur_result then
      x_progress := 180;
      SELECT GSB.currency_code,
             POH.currency_code
      INTO   x_base_currency,
             x_po_currency_1
      FROM   PO_HEADERS_ALL POH,
             FINANCIALS_SYSTEM_PARAMETERS FSP,
             GL_SETS_OF_BOOKS GSB,
             PO_RELEASES_ALL POR
      WHERE  POH.po_header_id    = POR.po_header_id
      AND    POR.po_release_id   = x_object_id
      AND    FSP.set_of_books_id = GSB.set_of_books_id;

      if (x_base_currency <> x_po_currency_1) then
        /* Get precision and minimum accountable unit of the PO CURRENCY */
        x_progress := 190;
        get_currency_info (x_po_currency_1,
                           x_precision,
                           x_min_unit );

        /* Get precision and minimum accountable unit of the base CURRENCY */
        x_progress := 200;
        get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );


        x_progress := 210;
        SELECT
        nvl(sum (decode (x_base_min_unit, NULL,
                 round ( ( decode (x_min_unit, NULL,
                           round ((nvl(POD.quantity_ordered, 0) *
                                   nvl(PLL.price_override, 0)), x_precision),
                           round ((nvl(POD.quantity_ordered, 0) *
                                   nvl(PLL.price_override, 0) / x_min_unit))
                                   * x_min_unit) * POD.rate), x_base_precision),
                           round ( ( decode (x_min_unit, NULL,
                           round ((nvl(POD.quantity_ordered, 0) *
                                   nvl(PLL.price_override, 0)), x_precision),
                           round ((nvl(POD.quantity_ordered, 0) *
                                   nvl(PLL.price_override, 0) / x_min_unit)
                                   ) * x_min_unit) * POD.rate) / x_base_min_unit
                                   ) * x_base_min_unit)), 0)
         INTO x_result_fld
         FROM PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
         WHERE PLL.po_release_id    = x_object_id
         AND   PLL.line_location_id = POD.line_location_id
         AND   PLL.shipment_type in ('SCHEDULED','BLANKET');

      end if;
    else
      x_progress := 220;
      SELECT
      sum( decode (C.minimum_accountable_unit, NULL,
            round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                     * nvl(POL.price_override, 0), C.precision),
            round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                    * nvl(POL.price_override, 0) /
                    C.minimum_accountable_unit) * C.minimum_accountable_unit))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS_ALL POL, PO_HEADERS_ALL POH,
             FND_CURRENCIES C
      WHERE  POL.po_release_id = x_object_id
      AND    POH.po_header_id  = POL.po_header_id
      AND    POH.currency_code = C.currency_code
      AND    POL.shipment_type in ('SCHEDULED','BLANKET');

    end if;

  elsif (x_object_type = 'L' ) then /* Po Line */
    x_progress := 230;
    SELECT
    sum( decode (C.minimum_accountable_unit, NULL,
                 round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                         * nvl(POL.price_override, 0), C.precision),
                 round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                         * nvl(POL.price_override, 0) /
                         C.minimum_accountable_unit)
                         * C.minimum_accountable_unit))
    INTO   x_result_fld
    FROM   PO_LINE_LOCATIONS_ALL POL, PO_HEADERS_ALL POH,
           FND_CURRENCIES C
    WHERE  POL.po_line_id    = x_object_id
    AND    POH.po_header_id  = POL.po_header_id
    AND    POH.currency_code = C.currency_code
    AND    POL.shipment_type in ('STANDARD','PLANNED','BLANKET');

  elsif (x_object_type = 'S' ) then /* PO Shipment */
    x_progress := 240;
    SELECT
    sum( decode (C.minimum_accountable_unit, NULL,
                 round ((POL.quantity - nvl(POL.quantity_cancelled, 0))
                         * nvl(POL.price_override, 0), C.precision),
                 round ((POL.quantity - nvl(POL.quantity_cancelled , 0))
                         * nvl(POL.price_override, 0) /
                         C.minimum_accountable_unit)
                         * C.minimum_accountable_unit))
    INTO   x_result_fld
    FROM   PO_LINE_LOCATIONS_ALL POL, PO_HEADERS_ALL POH,
           FND_CURRENCIES C
    WHERE  line_location_id  = x_object_id
    AND    POH.po_header_id  = POL.po_header_id
    AND    POH.currency_code = C.currency_code;

  end if; /* x_object_type */

  RETURN(x_result_fld);

  EXCEPTION
  WHEN OTHERS THEN
    RETURN(0);
    po_message_s.sql_error('get_total', x_progress, sqlcode);
    RAISE;

END ecx_get_total;

END POGOT_S;

/
