--------------------------------------------------------
--  DDL for Package Body AR_IDEP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_IDEP_UTILS" AS
/* $Header: ARDEPUTB.pls 120.2 2005/08/12 13:01:05 rsinthre noship $ */


/*========================================================================
 | PUBLIC function get_course_description
 |
 | DESCRIPTION
 |      function which returns the description of a course which is an item in
 |      an invoice against a deposit.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_line_id      the line number of the invoice
 |   p_uom          the unit of measure for the line item
 |
 | RETURNS
 |   Description of the line item
 |   Output string will contain activity name, student name, event start date,
 |   event end date and event title saperated by comma (",") for UOM=ENR.
 |   The string will not contain student name if student name is NULL for UOM=ENR.
 |
 |   Output string will contain activity name, max attendee, event start date,
 |   event end date, event title saperated by comma (",") for UOM=EVT.
 |   The string will not contain student name for UOM=EVT.
 |
 |   Output string x_description will not contain contact name for ENR and EVT.
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author                 Description of Changes
 | 20-Jun-2001           Krishnakumar Menon      Created
 *=======================================================================*/

FUNCTION get_course_description(pn_line_id   IN  Number,
                                pv_uom       IN  Varchar2) RETURN VARCHAR2 IS

    l_description           VARCHAR2(360);
    l_course_end_date       DATE;
    l_return_status         VARCHAR2(240);
BEGIN

    OTA_UTILITY.GET_DESCRIPTION (p_line_id => pn_line_id,
                                 p_uom => pv_uom,
                                 x_description => l_description,
                                 x_course_end_date => l_course_end_date,
                                 x_return_status => l_return_status);
    RETURN l_description;
END;

/*========================================================================
 | PUBLIC function get_reserved_commitment_amt
 |
 | DESCRIPTION
 |      function which returns the reserved amount for a given commitment/deposit.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_customer_trx_id      The deposit identifier
 |
 | RETURNS
 |   The reserved amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author       Description of Changes
 | 13-Dec-2001           krmenon      Created
 | 02-May-2002           krmenon      Replaces SQL with call to OM api
 *=======================================================================*/
FUNCTION get_reserved_commitment_amt (p_customer_trx_id in NUMBER) RETURN NUMBER IS
    l_reserved_amount      NUMBER := 0;
BEGIN

    l_reserved_amount := OE_PAYMENTS_UTIL.get_uninvoiced_commitment_bal(p_customer_trx_id);

    RETURN nvl(l_reserved_amount,0);
END;


/*========================================================================
 | PUBLIC function get_applied_commitment_amt
 |
 | DESCRIPTION
 |      function which returns the applied amount for a given commitment/deposit.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_customer_trx_id      The deposit identifier
 |
 | RETURNS
 |   The applied amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author       Description of Changes
 | 02-May-2002           krmenon      Created
 *=======================================================================*/
FUNCTION get_applied_commitment_amt (p_customer_trx_id in NUMBER) RETURN NUMBER IS

    l_commitment_class    ra_cust_trx_types.type%type;
    l_currency_code       ra_customer_trx_all.invoice_currency_code%type;
    l_applied_amount      NUMBER := 0;
    l_invoiced_amount     NUMBER := 0;
    l_credit_memo_amount  NUMBER := 0;

BEGIN

    --
    -- Determine the type of transaction
    --
    SELECT type.type,
           trx.invoice_currency_code
    INTO   l_commitment_class,
           l_currency_code
    FROM   ra_customer_trx_all       trx,
           ra_cust_trx_types_all     type
    WHERE  trx.customer_trx_id      = p_customer_trx_id
    AND    trx.cust_trx_type_id     = type.cust_trx_type_id
    AND    trx.org_id               = type.org_id
    AND    type.type                IN ('DEP','GUAR');



    /*-------------------------------------------+
     |  If the commitment type is for a DEPOSIT, |
     |  then add in commitment adjustments       |
     +-------------------------------------------*/

    IF    ( l_commitment_class = 'DEP' ) THEN

        --
        -- Get the Adjustments
        --
        SELECT ( NVL(SUM( ADJ.AMOUNT),0) * -1)
        INTO   l_invoiced_amount
        FROM   ra_customer_trx_all      trx,
               ra_cust_trx_types_all    type,
               ar_adjustments_all       adj
        WHERE  trx.cust_trx_type_id         = type.cust_trx_type_id
        AND    trx.org_id                   = type.org_id
        AND    trx.initial_customer_trx_id  = p_customer_trx_id
        AND    trx.complete_flag            = 'Y'
        AND    adj.adjustment_type          = 'C'
        AND    type.type                    IN ('INV', 'CM')
        AND    adj.org_id                   = trx.org_id
        AND    adj.customer_trx_id = DECODE(type.type,
                                            'INV', trx.customer_trx_id,
                                            'CM', trx.previous_customer_trx_id)
        AND NVL( adj.subsequent_trx_id, -111) = DECODE(type.type,
                                                'INV', -111,
                                                'CM', trx.customer_trx_id) ;

        --
        -- Get the Credit Memos against the Commitment
        --
        SELECT NVL(SUM(-1 * line.extended_amount),0)
        INTO   l_credit_memo_amount
        FROM   ra_customer_trx_all        trx,
               ra_customer_trx_lines_all  line
        WHERE  trx.customer_trx_id           = line.customer_trx_id
        AND    trx.org_id                    = line.org_id
        AND    trx.previous_customer_trx_id  = p_customer_trx_id
        AND    trx.complete_flag             = 'Y';


    ELSE    -- Guarantee case

        SELECT ( NVL( SUM(amount_line_items_original), 0)
                -
                NVL( SUM(amount_due_remaining), 0))
        INTO   l_invoiced_amount
        FROM   ar_payment_schedules_all
        WHERE  customer_trx_id = p_customer_trx_id;


       /*------------------------------------------------------------+
        |  We do not want to adjust the commitment balance by the    |
        |  amount of any manual adjustments against the commitment.  |
        |  The following statement backs out these manual            |
        |  adjustments from the commitment balance.                  |
        +------------------------------------------------------------*/

        SELECT NVL( SUM( amount ), 0)
        INTO   l_credit_memo_amount
        FROM   ar_adjustments_all
        WHERE  customer_trx_id  =  p_customer_trx_id
        AND    adjustment_type <> 'C';

    END IF;    -- end Guarantee case


    l_applied_amount := l_invoiced_amount + l_credit_memo_amount;

    RETURN nvl(l_applied_amount,0);

END;


END AR_IDEP_UTILS;

/
