--------------------------------------------------------
--  DDL for Package Body AP_CARD_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CARD_INVOICE_PKG" AS
/* $Header: apwcintb.pls 120.5.12010000.3 2009/08/14 10:41:13 syeluri ship $ */

---------------------------------------------------------------------------
--
-- Procedure CREATE_INVOICE
--
-- Inserts records into AP_INVOICE_LINES_INTERFACE and
-- AP_INVOICES_INTERFACE to create invoice for credit card issuer
-- for payment of records in AP_EXPENSE_FEED_DISTS.
--
-- Records inserted into AP_INVOICE_LINES_INTERFACE from
-- AP_EXPENSE_FEED_DISTS where
--  o AP_EXPENSE_FEED_LINES.CARD_PROGRAM_ID = P_CARD_PROGRAM_ID
--  o AP_EXPENSE_FEED_DISTS.TRANSACTION_DATE between
--    P_START_DATE and P_END_DATE.
--  o AP_EXPENSE_FEED_DISTS.STATUS = 'APPROVED' or status is
--    not excepted from payment as defined at the card program
--
-- These records are summarized (rolled up) by
-- AP_EXPENSE_FEED_DISTS.DIST_CODE_COMBINATION_ID, TAX_CODE, and
-- AMOUNT_INCLUDES_TAX_FLAG when P_ROLLUP_FLAG = 'Y'
--
-- Single record inserted into AP_INVOICES_INTERFACE which serves as header
-- to those records inserted into AP_INVOICE_LINES_INTERFACE.
--
-- Records in AP_EXPENSE_FEED_DISTS updated to reflect invoice interface
-- insertions.
--  o AP_EXPENSE_FEED_DISTS.INVOICED_FLAG = 'Y'
--  o AP_EXPENSE_FEED_DISTS.INVOICE_ID = <sequence-generated ID>
--  o AP_EXPENSE_FEED_DISTS.INVOICE_LINE_ID = <sequence-generated ID>
--
---------------------------------------------------------------------------
PROCEDURE CREATE_INVOICE(
      P_CARD_PROGRAM_ID IN NUMBER,
      P_INVOICE_ID      IN OUT NOCOPY NUMBER,
      P_START_DATE      IN DATE DEFAULT NULL,
      P_END_DATE        IN DATE DEFAULT NULL,
      P_ROLLUP_FLAG     IN VARCHAR2 DEFAULT 'Y') IS

  --
  -- Define cursor for lines
  --
  -- If P_ROLLUP_FLAG = Y then rollup transactions by CCID
  --
/*Bug 4997769*/
/*Replaced the transaction date by posted date*/
  cursor lines_cursor is
  select sum(nvl(efd.amount,0)),
         efd.dist_code_combination_id,
         efd.tax_code,
         efd.amount_includes_tax_flag,
         decode(P_ROLLUP_FLAG,
                  'N',efd.feed_distribution_id),
         decode(P_ROLLUP_FLAG,
                  'N',efl.transaction_date,
                      nvl(P_START_DATE,nvl(P_END_DATE,sysdate))),
         decode(P_ROLLUP_FLAG,
                  'N',efd.description),
	 efd.org_id, -- Bug 5592139
	 efl.merchant_name,
	 efl.merchant_number --bug8299023
  from   ap_expense_feed_lines efl,
         ap_expense_feed_dists efd,
         ap_card_programs cp
  where  efl.feed_line_id = efd.feed_line_id
  and    efl.card_program_id = P_CARD_PROGRAM_ID
  and    efl.card_program_id = cp.card_program_id
  and    nvl(efd.invoiced_flag,'N') = 'N'
  and    ((nvl(efd.status_lookup_code,'VALIDATED') = 'APPROVED')
          OR
          (nvl(cp.exclude_unverified_flag,'N') = 'N' AND
           nvl(efd.status_lookup_code,'VALIDATED') = 'VALIDATED')
          OR
          (nvl(cp.exclude_rejected_flag,'N') = 'N' AND
           nvl(efd.status_lookup_code,'VALIDATED') in ('REJECTED','VERIFIED'))
          OR
          (nvl(cp.exclude_personal_flag,'N') = 'N' AND
           nvl(efd.status_lookup_code,'VALIDATED') = 'PERSONAL')
          OR
          (nvl(cp.exclude_disputed_flag,'N') = 'N' AND
           nvl(efd.status_lookup_code,'VALIDATED') = 'DISPUTED')
          OR
          (nvl(cp.exclude_held_flag,'N') = 'N' AND
           nvl(efd.status_lookup_code,'VALIDATED') = 'HOLD'))
  and    (efl.posted_date is null OR
          (efl.posted_date between
                  nvl(P_START_DATE,efl.posted_date-1) and
                  nvl(P_END_DATE,efl.posted_date+1)))
  group by efd.dist_code_combination_id,
         efd.tax_code,
         efd.amount_includes_tax_flag,
         decode(P_ROLLUP_FLAG,
                  'N',efd.feed_distribution_id),
         decode(P_ROLLUP_FLAG,
                  'N',efl.transaction_date,
                      nvl(P_START_DATE,nvl(P_END_DATE,sysdate))),
         decode(P_ROLLUP_FLAG,
                  'N',efd.description),
	 efd.org_id,                                  -- Bug 5620010
	 efl.merchant_name,
	 efl.merchant_number;                            --bug8299023

  l_amount                   number;
  l_ccid                     number;
  l_tax_code                 AP_EXPENSE_FEED_DISTS.tax_code%TYPE;
  l_amount_includes_tax_flag
                  AP_EXPENSE_FEED_DISTS.amount_includes_tax_flag%TYPE;
  l_transaction_date         date;
  l_description              AP_EXPENSE_FEED_DISTS.description%TYPE := '';
  l_invoice_currency_code
                  AP_CARD_PROGRAMS.card_program_currency_code%TYPE := '';
  l_count                    number := 0;
  l_sum                      number := 0;
  l_invoice_id               number;
  l_invoice_line_id          number;
  l_feed_distribution_id     number;
  l_vendor_id                number;
  l_vendor_site_id           number;
  l_org_id		     number; -- Bug 5592139
  l_debug_info               VARCHAR2(100);
  l_merchant_name            AP_EXPENSE_FEED_LINES.merchant_name%TYPE;
  l_merchant_number            AP_EXPENSE_FEED_LINES.merchant_number%TYPE;           --bug8299023

BEGIN

  -----------------------------------------------------------------------
  l_debug_info := 'Open lines cursor';
  -----------------------------------------------------------------------
  open lines_cursor;

  loop

    -----------------------------------------------------------------------
    l_debug_info := 'Fetch lines cursor';
    -----------------------------------------------------------------------
    fetch lines_cursor into
      l_amount,
      l_ccid,
      l_tax_code,
      l_amount_includes_tax_flag,
      l_feed_distribution_id,
      l_transaction_date,
      l_description,
      l_org_id,
      l_merchant_name,
      l_merchant_number;                      --bug8299023

    exit when lines_cursor%NOTFOUND;

    l_count := l_count + 1;
    l_sum   := l_sum + l_amount;

    --
    -- Get sequence-generated invoice_id if this is the first line
    --
    if (l_count = 1) then
      -----------------------------------------------------------------------
      l_debug_info := 'Getting next sequence from ap_invoices_interface_s';
      -----------------------------------------------------------------------
      select ap_invoices_interface_s.nextval
      into   l_invoice_id
      from   dual;

      P_INVOICE_ID := l_invoice_id;

    end if;

    --
    -- Get sequence-generated invoice_line_id
    --
    -----------------------------------------------------------------------
    l_debug_info := 'Getting next sequence from ap_invoice_lines_interface_s';
    -----------------------------------------------------------------------
    select ap_invoice_lines_interface_s.nextval
    into   l_invoice_line_id
    from   dual;

    -----------------------------------------------------------------------
    l_debug_info := 'inserting into ap_invoice_lines_interface';
    -----------------------------------------------------------------------
    insert into ap_invoice_lines_interface
      (INVOICE_ID,
       INVOICE_LINE_ID,
       LINE_NUMBER,
       LINE_TYPE_LOOKUP_CODE,
       AMOUNT,
       ACCOUNTING_DATE,
       DESCRIPTION,
       TAX_CODE,
       AMOUNT_INCLUDES_TAX_FLAG,
       DIST_CODE_COMBINATION_ID,
       ORG_ID,                   -- Bug 5592139
       MERCHANT_NAME,
       MERCHANT_REFERENCE) VALUES            --bug8299023
      (l_invoice_id,
       l_invoice_line_id,
       l_count,
       'ITEM',
       l_amount,
       l_transaction_date,
       l_description,
       l_tax_code,
       l_amount_includes_tax_flag,
       l_ccid,
       l_org_id,               -- Bug 5592139
       l_merchant_name,
       l_merchant_number);            --bug8299023

    if (l_feed_distribution_id is not null) then
      --
      -- Insertion is detail-level, therefore one-to-one correspondence
      -- between AP_EXPENSE_FEED_DISTS and AP_INVOICE_LINES_INTERFACE.
      --
      -- Update the record AP_EXPENSE_FEED_DISTS with the ID of the
      -- newly created line in AP_INVOICE_LINES_INTERFACE.
      --
      -----------------------------------------------------------------------
      l_debug_info := 'Updating AP_EXPENSE_FEED_DISTS with DIST ID';
      -----------------------------------------------------------------------
      update AP_EXPENSE_FEED_DISTS
      set    invoiced_flag = 'Y',
             INVOICE_ID = l_invoice_id,
             INVOICE_LINE_ID = l_invoice_line_id
      where  feed_distribution_id = l_feed_distribution_id;

    else
      --
      -- Insertion is summary-level, therefore many-to-one correspondence
      -- between AP_EXPENSE_FEED_DISTS and AP_INVOICE_LINES_INTERFACE.
      --
      -- Update the records AP_EXPENSE_FEED_DISTS matching the group
      -- criteria of the lines_cursor with the ID of the newly created
      -- line in AP_INVOICE_LINES_INTERFACE.
      --
      -----------------------------------------------------------------------
      l_debug_info := 'Updating AP_EXPENSE_FEED_DISTS';
      -----------------------------------------------------------------------
/*Bug 4997769*/
/*Replaced the transaction date by posted date*/
      update AP_EXPENSE_FEED_DISTS EFD
      set    invoiced_flag = 'Y',
             INVOICE_ID = l_invoice_id,
             INVOICE_LINE_ID = l_invoice_line_id
      where  nvl(invoiced_flag,'N') = 'N'
      and    dist_code_combination_id = l_ccid
      and    exists
             (select 'Parent record meets group criteria from lines_cursor'
              from   AP_EXPENSE_FEED_LINES EFL,
                     AP_CARD_PROGRAMS CP
              where  EFL.feed_line_id = EFD.feed_line_id
              and    EFL.card_program_id = P_CARD_PROGRAM_ID
              and    EFL.card_program_id = CP.card_program_id
              and    ((nvl(efd.status_lookup_code,'VALIDATED') = 'APPROVED')
                      OR
                      (nvl(cp.exclude_unverified_flag,'N') = 'N' AND
                       nvl(efd.status_lookup_code,'VALIDATED') = 'VALIDATED')
                      OR
                      (nvl(cp.exclude_rejected_flag,'N') = 'N' AND
                       nvl(efd.status_lookup_code,'VALIDATED') = 'REJECTED')
                      OR
                      (nvl(cp.exclude_personal_flag,'N') = 'N' AND
                       nvl(efd.status_lookup_code,'VALIDATED') = 'PERSONAL')
                      OR
                      (nvl(cp.exclude_disputed_flag,'N') = 'N' AND
                       nvl(efd.status_lookup_code,'VALIDATED') = 'DISPUTED')
                      OR
                      (nvl(cp.exclude_held_flag,'N') = 'N' AND
                       nvl(efd.status_lookup_code,'VALIDATED') = 'HOLD')
                      OR
                      (nvl(cp.exclude_unreconciled_flag,'N') = 'N' AND
                       nvl(efd.status_lookup_code,'VALIDATED') = 'VERIFIED'))
              and    (efl.posted_date is null OR
                      (efl.posted_date between
                              nvl(P_START_DATE,efl.posted_date-1) and
                              nvl(P_END_DATE,efl.posted_date+1))));
    end if;

  end loop;

  close lines_cursor;

  --
  -- If any records were inserted into AP_INVOICE_LINES_INTERFACE
  -- then insert a single header record into AP_INVOICES_INTERFACE.
  --
  if (l_count > 0) then
    --
    -- Need vendor (payee) information from AP_CARD_PROGRAMS
    --
    -----------------------------------------------------------------------
    l_debug_info := 'Retrieving vendor info from card program';
    -----------------------------------------------------------------------
    select vendor_id,
           vendor_site_id,
           card_program_currency_code
    into   l_vendor_id,
           l_vendor_site_id,
           l_invoice_currency_code
    from   ap_card_programs
    where  card_program_id = P_CARD_PROGRAM_ID;

    -----------------------------------------------------------------------
    l_debug_info := 'Inserting into AP_INVOICES_INTERFACE';
    -----------------------------------------------------------------------
    insert into AP_INVOICES_INTERFACE
    (INVOICE_ID,
     INVOICE_NUM,
     VENDOR_ID,
     VENDOR_SITE_ID,
     INVOICE_AMOUNT,
     INVOICE_CURRENCY_CODE,
     SOURCE,
     ORG_ID
     ) VALUES
    (l_invoice_id,
     substrb(to_char(l_invoice_id)||'-'||to_char(sysdate),1,50),
     l_vendor_id,
     l_vendor_site_id,
     l_sum,
     l_invoice_currency_code,
     'PCARD',
     l_org_id  -- Bug 5592139
     );

  end if;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'CREATE_INTERFACE_RECORDS');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END;

END AP_CARD_INVOICE_PKG;

/
