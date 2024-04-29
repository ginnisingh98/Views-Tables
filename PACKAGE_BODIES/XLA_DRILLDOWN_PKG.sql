--------------------------------------------------------
--  DDL for Package Body XLA_DRILLDOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_DRILLDOWN_PKG" AS
/* $Header: xlaiqdrl.pkb 120.16.12010000.2 2009/01/29 09:07:30 karamakr ship $ */
/*==========================================================================+
|             Copyright (c) 2000-2001 Oracle Corporation                    |
|                       Redwood Shores, CA, USA                             |
|                         All rights reserved.                              |
+===========================================================================+
| PACKAGE NAME                                                              |
|    xla_drilldown_pkg                                                      |
|                                                                           |
| DESCRIPTION                                                               |
|            This Package is a PL/SQL wrapper to the GL Team  for Drilldown |
| specific Procedures.                                                      |
| HISTORY                                                                   |
|    14-MAR-05  Kprattip          Created                                   |
|                                                                           |
|    31-JUL-05  V. Swapna         Bug 4494345: Modified open_drilldown to   |
|                                 use je_from_sla flag to determine if an   |
|                                 entry originated from SLA.                |
|                                                                           |
|    08-FEB-06  V. Swapna         Bug 5009082: Modification to procedures   |
|                                 check_drilldown and open_drilldown to     |
|                                 handle the values 'U' and 'N', for        |
|                                 je_from_sla_flag.                         |
+==========================================================================*/


/*==========================================================================+
|                                                                           |
| Private Function                                                          |
|                                                                           |
| is_FA_drilldown                                                           |
|                                                                           |
+==========================================================================*/



FUNCTION is_FA_drilldown (
   p_je_header_id    NUMBER
  ,p_je_source            VARCHAR2
  ,p_je_category     VARCHAR2 ) RETURN BOOLEAN

IS


  CURSOR fab_c ( c_jeh_id     NUMBER,
            c_je_source         VARCHAR2,
            c_je_category          VARCHAR2) IS

     SELECT gl_je_source
       FROM fa_book_controls bc,
       gl_je_headers jeh
      WHERE jeh.je_header_id = c_jeh_id
   AND bc.set_of_books_id = jeh.ledger_id
         AND bc.gl_je_source = c_je_source
         AND c_je_category IN (
          bc.JE_RETIREMENT_CATEGORY
         ,bc.JE_RECLASS_CATEGORY
         ,bc.JE_ADDITION_CATEGORY
         ,bc.JE_ADJUSTMENT_CATEGORY
         ,bc.JE_REVAL_CATEGORY
         ,bc.JE_TRANSFER_CATEGORY
         ,bc.JE_CIP_ADJUSTMENT_CATEGORY
         ,bc.JE_CIP_ADDITION_CATEGORY
         ,bc.JE_CIP_RECLASS_CATEGORY
         ,bc.JE_CIP_RETIREMENT_CATEGORY
         ,bc.JE_CIP_REVAL_CATEGORY
         ,bc.JE_CIP_TRANSFER_CATEGORY  )
   AND ROWNUM = 1;

  l_FA_drilldown_flag   BOOLEAN := FALSE;
  l_dummy           VARCHAR2(30);

BEGIN

  OPEN fab_c ( p_je_header_id, p_je_source, p_je_category);
  FETCH fab_c INTO l_dummy;

  IF fab_c%FOUND THEN
     l_FA_drilldown_flag := TRUE;
  ELSE
     l_FA_drilldown_flag := jg_zz_fa_drill_down_pkg.is_jg_fa_drilldown
                                                         (p_je_header_id,
                                                          p_je_source,
                                                          p_je_category);
  END IF;

  CLOSE fab_c;

  RETURN ( l_FA_drilldown_flag );

END is_FA_drilldown;



/*==========================================================================+
|                                                                           |
| Public Procedure                                                          |
|                                                                           |
| check_drilldown                                                           |
|                                                                           |
+==========================================================================*/

PROCEDURE check_drilldown (
   p_je_source           VARCHAR2
  ,p_je_category         VARCHAR2
  ,p_je_header_id        NUMBER
  ,p_je_line_num         NUMBER
  ,p_drilldown_flag OUT NOCOPY VARCHAR2
  ,p_application_id OUT NOCOPY NUMBER )

IS

  AR_APPL               CONSTANT NUMBER(3) := 222;
  FA_APPL               CONSTANT NUMBER(3) := 140;
  PA_APPL               CONSTANT NUMBER(3) := 275;
  INV_APPL              CONSTANT NUMBER(3) := 401;
  WIP_APPL              CONSTANT NUMBER(3) := 706;
  PO_APPL               CONSTANT NUMBER(3) := 201;
  OZF_APPL              CONSTANT NUMBER(4) := 682;
  FED_APPL              CONSTANT NUMBER(4) := 8901;
  OKL_APPL              CONSTANT NUMBER(3) := 540;
  AP_APPL               CONSTANT NUMBER(3) := 200;

  l_drilldown_flag   VARCHAR2(1):= 'N';
  l_appl_id    NUMBER(15) := NULL;
  l_actual_flag         VARCHAR2(1);
  l_je_source_name      VARCHAR2(30);
  l_je_from_sla_flag    VARCHAR2(1);

--
-- Cursor declaration
--
  CURSOR c_xla_subledgers
  IS
  SELECT application_id, je_source_name
    FROM xla_subledgers
   WHERE je_source_name = p_je_source;

  CURSOR c_je_from_sla_flag
  IS
  SELECT je_from_sla_flag
    FROM gl_je_headers
   WHERE je_header_id = p_je_header_id;

BEGIN
  OPEN c_xla_subledgers;
  FETCH c_xla_subledgers INTO l_appl_id, l_je_source_name;
  CLOSE c_xla_subledgers;

  OPEN c_je_from_sla_flag;
  FETCH c_je_from_sla_flag INTO l_je_from_sla_flag;
  CLOSE c_je_from_sla_flag;

  IF l_je_from_sla_flag IN ('Y','U') THEN
     l_drilldown_flag := 'Y';
  ELSIF l_je_from_sla_flag  = 'N' THEN     -- Bug 5009082
     l_drilldown_flag := 'N';
  ELSE
    IF ( p_je_source = 'Receivables') THEN
        IF ( p_je_category IN ('Sales Invoices', 'Credit Memos',
                               'Credit Memo Applications',
                               'Debit Memos', 'Chargebacks',
                'Misc Receipts', 'Trade Receipts',
                'Rate Adjustments', 'Cross Currency',
                'Adjustment', 'Bills Receivable' )  ) THEN

           l_drilldown_flag := 'Y';
           l_appl_id := AR_APPL;
        END IF;

     ELSIF ( p_je_Source = 'Lease' ) AND
           ( p_je_category IN ( 'Termination', 'Asset Disposition',
                                'Booking', 'Rebook', 'Renewal',
                                'Release', 'Reverse',
                                'Syndication', 'Loss Provision',
                                'Adjustment', 'Accrual',
                                'Miscellaneous', 'Accrual',
                                'Adjustment', 'Asset Disposition',
                                'Booking', 'Loss Provision',
                                'Miscellaneous', 'Rebook',
                                'Release', 'Renewal',
                                'Reverse', 'Syndication and Termination')) THEN
            l_drilldown_flag := 'Y';
            l_appl_id := OKL_APPL;

     ELSIF ( p_je_source = 'Project Accounting' AND
           ( p_je_category IN ( 'Labor Cost',  'Miscellaneous Transaction',
                                'Revenue', 'Total Burdened Cost',
                                'Usage Cost','BORROWED_AND_LENT',
                                'PROVIDER_COST_RECLASS' ) ) ) THEN
           l_drilldown_flag := 'Y';
           l_appl_id := PA_APPL;

     ELSIF ( p_je_source = 'Inventory' ) THEN

        -- Both INV and WIP Transactions have the same GL_JE_SOURCE of Inventory

           IF   ( p_je_category IN ( 'MTL' ) ) THEN

           l_drilldown_flag := 'Y';
                l_appl_id := INV_APPL;

           ELSIF ( p_je_category IN ( 'WIP' ) ) THEN
            l_drilldown_flag := 'Y';
                 l_appl_id := WIP_APPL;
           END IF;

     ELSIF ( p_je_source = 'Purchasing' AND
             ( p_je_category IN ( 'Receiving', 'Requisitions', 'Purchases'))) THEN
             l_drilldown_flag := 'Y';
             l_appl_id := PO_APPL;

     ELSIF ( p_je_source = 'Periodic Inventory' ) THEN

            -- Purchasing, INV and WIP Transactions for PAC have the same
            -- GL_JE_SOURCE of Periodic Inventory
           IF ( p_je_category IN ( 'MTL' ) ) THEN
              l_drilldown_flag := 'Y';
              l_appl_id := INV_APPL;
           ELSIF ( p_je_category IN ( 'WIP' ) ) THEN
                 l_drilldown_flag := 'Y';
                 l_appl_id := WIP_APPL;
           ELSIF ( p_je_category IN ( 'Receiving', 'Accrual' ) ) THEN
                 l_drilldown_flag := 'Y';
                 l_appl_id := PO_APPL;
           END IF;

     ELSIF ( p_je_source = 'Budgetary Transaction' ) THEN
             l_drilldown_flag := 'Y';
             l_appl_id := FED_APPL;

     ELSIF ( p_je_source = 'PYA Transactions' AND
           ( p_je_category IN ( 'Upward Adjustments',
                                'Downward Adjustments'))) THEN
             l_drilldown_flag := 'Y';
             l_appl_id := FED_APPL;

     ELSIF ( p_je_source = 'Marketing' ) THEN

            IF ( p_je_category IN ('Settlement', 'Claims', 'Deductions',
                                   'Fixed Budgets', 'Accrual Budgets'   ) ) THEN
          l_drilldown_flag := 'Y';
               l_appl_id := OZF_APPL;
          END IF;

     ELSIF is_FA_drilldown(p_je_header_id, p_je_source, p_je_category) THEN

            l_drilldown_flag := 'Y';

            l_appl_id := FA_APPL;


     END IF;
  END IF;

  -- Return drilldown_flag and application id.
  p_drilldown_flag := l_drilldown_flag;
  p_application_id := l_appl_id;

END check_drilldown;


/*==========================================================================+
|                                                                           |
| Public Procedure                                                          |
|                                                                           |
| open_drilldown                                                            |
|                                                                           |
+==========================================================================*/


PROCEDURE open_drilldown (
   p_je_source                  VARCHAR2
  ,p_je_header_id               NUMBER
  ,p_je_from_sla_flag           VARCHAR2 DEFAULT NULL
  ,p_form_function              IN OUT NOCOPY    VARCHAR2
  ,p_je_line_num                IN OUT NOCOPY    NUMBER
  )

IS

  l_dummy      VARCHAR2(1);
  CURSOR c_reference_6(c_je_header_id in number, c_je_line_num in number)
      IS
  SELECT reference_6, reference_10 from gl_je_lines
   WHERE je_header_id = c_je_header_id
     AND je_line_num  = c_je_line_num;

  l_reference_6  c_reference_6%rowtype;
  l_je_line_num  NUMBER(15);

  CURSOR c_xla IS
  SELECT application_id
    FROM xla_subledgers
   WHERE je_source_name = p_je_source;




  l_appl_id             INTEGER;
  l_je_from_sla_flag    VARCHAR2(1);
  l_count               NUMBER := 0 ;
  l_link_id             NUMBER;
  l_link_table          VARCHAR2(20);

BEGIN
   OPEN c_xla;
  FETCH c_xla INTO l_appl_id;
  CLOSE c_xla;


    l_je_from_sla_flag := p_je_from_sla_flag;
    l_je_line_num      := p_je_line_num;

   --7674572 Get the count only if the je_source is payables.
   IF(p_je_source = 'Payables') THEN

   SELECT count(*) into l_count FROM dual
   where exists (select 1 from xla_ae_lines ael,gl_import_references gir
                 where ael.gl_sl_link_id = gir.gl_sl_link_id
		 and   ael.gl_sl_link_table = gir.gl_sl_link_table
		 and   gir.je_header_id = p_je_header_id
		 and   gir.je_line_num = p_je_line_num); --included je_line_num join condition to imporve the performance

   END IF;

   IF (l_je_from_sla_flag is NULL)  THEN

      SELECT je_from_sla_flag INTO l_je_from_sla_flag FROM gl_je_headers
      WHERE je_header_id = p_je_header_id;

   END IF;

   IF (l_je_from_sla_flag is NULL AND  p_je_source = 'Receivables') THEN

        OPEN c_reference_6 (p_je_header_id, p_je_line_num);
       FETCH c_reference_6 INTO l_reference_6;
       CLOSE c_reference_6;

       IF l_reference_6.reference_10 like 'glxfje%' THEN
          l_je_line_num := to_number(l_reference_6.reference_6);
       END IF;

   END IF;

   IF (l_appl_id IS NOT NULL AND NVL(l_je_from_sla_flag,'X') IN ('Y','U')) THEN
      IF (p_je_source <> 'Payables') THEN   -- Bug 6658576
       p_form_function := 'XLA_LINESINQ_GL_DRILLDOWN';
      ELSE
       IF (l_count = 1) THEN
       p_form_function := 'XLA_LINESINQ_GL_DRILLDOWN';
       END IF;
      END IF;

   END IF;

  p_je_line_num := l_je_line_num;

END open_drilldown;

END xla_drilldown_pkg;

/
