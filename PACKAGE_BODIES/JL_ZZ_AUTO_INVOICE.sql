--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AUTO_INVOICE" as
/* $Header: jlzzraib.pls 120.10.12010000.6 2009/12/15 07:26:25 rsaini ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    validate_gdff                                                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |      p_request_id            Number   -- Concurrent Request_id             |
 |                                                                            |
 | RETURNS                                                                    |
 |      0                       Number   -- Validation Fails, if there is any |
 |                                          exceptional case which is handled |
 |                                          in WHEN OTHERS                    |
 |      1                       Number   -- Validation Succeeds               |
 |                                                                            |
 *----------------------------------------------------------------------------*/
  --PG_DEBUG varchar2(1) :=  NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  -- Bugfix# 3259701
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  FUNCTION validate_tax_attributes  (p_interface_line_id            IN NUMBER
        		           , p_line_type                    IN VARCHAR2
				   , p_memo_line_id                 IN NUMBER
			       	   , p_inventory_item_id            IN NUMBER
                                   , p_product_fiscal_class         IN VARCHAR2
                                   , p_product_category             IN VARCHAR2
                                   , p_trx_business_category        IN VARCHAR2
				   , p_line_attribute11             IN VARCHAR2
				   , p_line_attribute12             IN VARCHAR2
                                   , p_address_id                   IN NUMBER
                                   , p_warehouse_id                 IN NUMBER)
  RETURN BOOLEAN IS

  error_condition         EXCEPTION;
  l_dummy_code            VARCHAR2(15);
  l_delimiter             zx_fc_types_b.delimiter%type;
  l_trx_business_category VARCHAR2(30);
  l_contributor_class     VARCHAR2(30);
  l_use_site_prof         VARCHAR2(1);
  l_count                 NUMBER;

  BEGIN

    IF p_line_type = 'LINE'  THEN

       IF p_warehouse_id IS NULL AND
          p_inventory_item_id IS NOT NULL THEN
         IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
                                       ,'JL_ZZ_AR_TX_SHIP_FROM_ORG_REQ'
                                       ,p_interface_line_id                                                            , p_warehouse_id)  THEN
            RAISE  error_condition;
         END IF;
       ELSE
         l_dummy_code := NULL;
         BEGIN
           SELECT 'Success'
           INTO   l_dummy_code
           FROM   hr_organization_units hou,
                  hr_locations_all hl
           WHERE  hou.organization_id = p_warehouse_id
           AND    hl.location_id = hou.location_id
           AND    hl.global_attribute1 IS NOT NULL;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
                                       ,'JL_ZZ_AR_TX_ORG_CLASS_INVALID'
                                       ,p_interface_line_id                                                            ,p_warehouse_id)  THEN
                   RAISE  error_condition;
                END IF;
         END;
       END IF;

       l_contributor_class := NULL;
       l_use_site_prof := NULL;
       IF p_address_id IS NOT NULL THEN
         BEGIN
           SELECT global_attribute8, global_attribute9
           INTO   l_contributor_class, l_use_site_prof
           FROM   hz_cust_acct_sites
           WHERE  cust_acct_site_id = p_address_id;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_contributor_class := NULL;
         END;

         IF l_contributor_class IS NULL THEN
           IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
	                            ,'JL_ZZ_AR_TX_CONTRIB_CLASS_INV'
                                    ,p_interface_line_id
                                    ,p_address_id)  THEN
              RAISE  error_condition;
           END IF;
         ELSE
           l_count := 0;
           BEGIN
              IF NVL(l_use_site_prof,'N') = 'Y' THEN
                 SELECT  count(*)
                 INTO    l_count
                 FROM    JL_ZZ_AR_TX_CUS_CLS
                 WHERE   address_id = p_address_id
                 AND     tax_attr_class_code = l_contributor_class;
              ELSE
                 SELECT  count(*)
                 INTO    l_count
                 FROM    JL_ZZ_AR_TX_ATT_CLS
                 WHERE   tax_attr_class_type = 'CONTRIBUTOR_CLASS'
                 AND     tax_attribute_type  = 'CONTRIBUTOR_ATTRIBUTE'
                 AND     tax_attr_class_code = l_contributor_class;
              END IF;
           EXCEPTION
             WHEN OTHERS THEN
                  l_count := 0;
           END;
         END IF;

         IF l_count = 0 THEN
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
	                            ,'JL_ZZ_AR_TX_CUS_SITE_PROF_REQ'
                                    ,p_interface_line_id
                                    ,p_address_id)  THEN
               RAISE  error_condition;
            END IF;
         END IF;

       END IF;

/* commented for Bug 3761529. Fiscal Classification Code (GA2) is migrated to Item
   Category model as part of eBTax uptake. So, just validate the column to be a
   NOT NULL for LTE and the actual validation of Product Fiscal Classification
   needs to be done by Product or eBTax feature. */
/********* bug#8351227- ZX default_and_validate should have validated this
       IF p_product_fiscal_class IS NOT NULL THEN
          l_dummy_code := NULL;
          BEGIN
            SELECT 'Sucess'
            INTO   l_dummy_code
            FROM   fnd_lookups
            WHERE  lookup_code = p_product_fiscal_class
            AND    lookup_type = 'JLZZ_AR_TX_FISCAL_CLASS_CODE'
            AND    enabled_flag = 'Y'
            AND    sysdate between nvl(start_date_active,sysdate)
                               and nvl(end_date_active,sysdate);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
                                       ,'JL_ZZ_AR_TX_RAXTRX_FSC_CLS_INV'
                                       ,p_interface_line_id , p_product_fiscal_class)  THEN
                    RAISE  error_condition;
                 END IF;
            WHEN OTHERS THEN
                 RAISE  error_condition;
          END; -- p_product_fiscal_class
       ELSE
          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
	                          ,'JL_ZZ_AR_TX_RAXTRX_FSC_CLS_MND'
                                  ,p_interface_line_id
                                  ,p_product_fiscal_class)  THEN
             RAISE  error_condition;
          END IF;
       END IF; --  p_product_fiscal_class  IS NOT NULL
*/

 /*      IF p_product_fiscal_class IS NULL AND
          p_product_category IS NULL THEN
          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
	                          ,'JL_ZZ_AR_TX_RAXTRX_FSC_CLS_MND'
                                  ,p_interface_line_id
                                  ,p_product_fiscal_class)  THEN
             RAISE  error_condition;
          END IF;
       END IF;
*/
/* bug#8351227- ZX default_and_validate should have validated this
       IF p_trx_business_category IS NOT NULL THEN
          l_dummy_code := NULL;
          BEGIN

            -- Transaction Business Category for LTE is prefixed with
            -- Event Class Code and it has to be eliminated along with
            -- the delimiter to validate the transaction condition class value.
            SELECT delimiter
            INTO   l_delimiter
            FROM   zx_fc_types_b
            WHERE  classification_type_code ='TRX_BUSINESS_CATEGORY';

            -- For example, the value for Transaction Business Category of LTE
            -- will be something like 'INVOICE.INDUSTRIAL' and the assignment
            -- below would extract only 'INDUSTRIAL' and validates with
            -- Transaction Condition Class Code of LTE
            l_trx_business_category := substr(p_trx_business_category,
                                        instr(p_trx_business_category,l_delimiter,-1)+1);

            SELECT 'Sucess'
            INTO   l_dummy_code
            FROM   fnd_lookups
            WHERE  lookup_code = l_trx_business_category
            AND    lookup_type = 'TRANSACTION_CLASS'
            AND    enabled_flag = 'Y'
            AND    sysdate BETWEEN nvl(start_date_active,sysdate)
                               AND nvl(end_date_active,sysdate);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
  			               ,'JL_ZZ_AR_TX_RAXTRX_TRX_NAT_INV'
                                       ,p_interface_line_id
                                       ,p_trx_business_category) THEN
                    RAISE  error_condition;
                 END IF;
            WHEN OTHERS THEN
                 RAISE  error_condition;
          END; -- p_line_attribute3
       ELSE
          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
                                 ,'JL_ZZ_AR_TX_RAXTRX_TRX_NAT_MND'
                                 ,p_interface_line_id
                                 ,p_trx_business_category)  THEN
             RAISE  error_condition;
          END IF;
       END IF; --  p_trx_business_category  IS NOT NULL
*/

    ELSIF  p_line_type ='TAX' THEN
       IF p_line_attribute11 IS NOT NULL THEN
          l_dummy_code := NULL;
          BEGIN
            SELECT FND_NUMBER.canonical_to_number (p_line_attribute11)
            INTO   l_dummy_code
            FROM   sys.dual;
          EXCEPTION
            WHEN INVALID_NUMBER OR VALUE_ERROR THEN
                 IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
                                     ,'JL_ZZ_AR_TX_RAXTRX_BS_AMT_INV'
                                      ,p_interface_line_id
                                      ,p_line_attribute11)  THEN
                    RAISE  error_condition;
                 END IF;
            WHEN OTHERS THEN
                 RAISE  error_condition;
          END; --  p_attribute_11
       END IF; -- line_attribute11 IS NOT NULL

       IF p_line_attribute12 IS NOT NULL THEN
          l_dummy_code := NULL;
          BEGIN
            SELECT FND_NUMBER.canonical_to_number (p_line_attribute12)
            INTO   l_dummy_code
            FROM   sys.dual;
          EXCEPTION
            WHEN INVALID_NUMBER  OR  VALUE_ERROR THEN
                 IF NOT JG_ZZ_AUTO_INVOICE.put_error_message  ('JL'
                                     ,'JL_ZZ_AR_TX_RAXTRX_BS_RATE_INV'
                                      ,p_interface_line_id
                                      ,p_line_attribute12)  THEN
                    RAISE  error_condition;
                 END IF;
            WHEN OTHERS THEN
                 RAISE  error_condition;
          END;
       END IF; -- line_attribute12 IS NOT NULL

    END IF; -- line_type

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
         RETURN FALSE;

  END  validate_tax_attributes;

  FUNCTION validate_interest_attributes (p_interface_line_id IN NUMBER
                                    , p_line_type              IN VARCHAR2
                                    , p_header_attribute1      IN VARCHAR2
                                    , p_header_attribute2      IN VARCHAR2
                                    , p_header_attribute3      IN VARCHAR2
                                    , p_header_attribute4      IN VARCHAR2
                                    , p_header_attribute5      IN VARCHAR2
                                    , p_header_attribute6      IN VARCHAR2
                                    , p_header_attribute7      IN VARCHAR2)
      RETURN BOOLEAN IS

      dummy_code      VARCHAR2 (15);
      error_condition EXCEPTION;

    BEGIN

      ------------------------------------------------------------
      -- header_attribute1 is the interest type                 --
      -- Valid JLBR_INTEREST_PENALTY_TYPE.  Not Mandatory.      --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_header_attribute1 IS NOT NULL THEN

          BEGIN
            SELECT 'Success'
              INTO dummy_code
              FROM fnd_lookups
              WHERE lookup_code = p_header_attribute1
                AND lookup_type = 'JLBR_INTEREST_PENALTY_TYPE'
                AND enabled_flag = 'Y'
                AND nvl(start_date_active,sysdate) <= sysdate
                AND nvl(end_date_active,sysdate+1) >= sysdate;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                      , 'JL_BR_AR_RAXTRX_INT_TYPE_INV'
                                      , p_interface_line_id
                                      , p_header_attribute1) THEN
                RAISE error_condition;
              END IF;
            WHEN OTHERS THEN
                 RAISE  error_condition;
          END; -- p_header_attribute1

        END IF;

      END IF; -- p_line_type = 'LINE'

      ------------------------------------------------------------
      -- header_attribute2 is the interest rate o amount for the--
      -- invoice.                                               --
      -- If interest type = 'R' then interest rate between 0 and--
      -- 100.                                                   --
      -- If interest type = 'A' then interest amount >= 0.      --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_header_attribute1 = 'R' AND
           p_header_attribute2 NOT BETWEEN 0 AND 100 THEN

          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                  , 'JL_BR_AR_RAXTRX_INT_RATE_INV'
                                  , p_interface_line_id
                                  , p_header_attribute2) THEN
            RAISE error_condition;
          END IF;

        END IF;

        IF p_header_attribute1 = 'A' AND p_header_attribute2 < 0 THEN

          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                  , 'JL_BR_AR_RAXTRX_AMNT_INV'
                                  , p_interface_line_id
                                  , p_header_attribute2) THEN
            RAISE error_condition;
          END IF;

        END IF;

      END IF; -- p_line_type = 'LINE'

      ------------------------------------------------------------
      -- header_attribute3 is the interest period days.         --
      -- Must be > 0.  Mandatory                                --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_header_attribute1 IS NOT NULL THEN

          IF p_header_attribute3 IS NOT NULL THEN

            BEGIN
              SELECT 'Success'
                INTO dummy_code
                FROM dual
                WHERE to_number (p_header_attribute3) >= 0;

            EXCEPTION
              WHEN NO_DATA_FOUND OR INVALID_NUMBER OR VALUE_ERROR THEN
                IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                        , 'JL_BR_AR_RAXTRX_INT_DAY_INV'
                                        , p_interface_line_id
                                        , p_header_attribute3) THEN
                   RAISE error_condition;
                END IF;
              WHEN OTHERS THEN
                   RAISE  error_condition;
            END; -- p_header_attribute3

          ELSE
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                    , 'JL_BR_AR_RAXTRX_INT_DAY_INV'
                                    , p_interface_line_id
                                    , p_header_attribute3) THEN
              RAISE error_condition;
            END IF;

          END IF;

        END IF;

      END IF; -- p_line_type = 'LINE'

      ------------------------------------------------------------
      -- header_attribute4 is the interest formula.             --
      -- Valid JLBR_INTEREST_FORMULA.  Not Mandatory.           --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_header_attribute4 IS NOT NULL THEN

          BEGIN
            SELECT 'Success'
              INTO dummy_code
              FROM fnd_lookups
              WHERE lookup_code = p_header_attribute4
                AND lookup_type = 'JLBR_INTEREST_FORMULA'
                AND enabled_flag = 'Y'
                AND nvl(start_date_active,sysdate) <= sysdate
                AND nvl(end_date_active,sysdate+1) >= sysdate;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                      , 'JL_BR_AR_RAXTRX_INT_FORM_INV'
                                      , p_interface_line_id
                                      , p_header_attribute4) THEN
                 RAISE error_condition;
              END IF;
            WHEN OTHERS THEN
                 RAISE  error_condition;
          END; -- p_header_attribute4

        END IF;

      END IF; -- p_line_type = 'LINE'

      ------------------------------------------------------------
      -- header_attribute5 is the grace days for the invoice    --
      -- Must be >= 0.  Mandatory                               --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_header_attribute5 IS NOT NULL THEN

          BEGIN
            SELECT 'Success'
              INTO dummy_code
              FROM dual
              WHERE to_number (p_header_attribute5) >= 0;

          EXCEPTION
            WHEN NO_DATA_FOUND OR INVALID_NUMBER OR VALUE_ERROR THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                      , 'JL_BR_AR_RAXTRX_INT_GRACE_INV'
                                      , p_interface_line_id
                                      , p_header_attribute5) THEN
                 RAISE error_condition;
              END IF;
            WHEN OTHERS THEN
                 RAISE  error_condition;

          END; -- p_header_attribute5

        END IF;

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- header_attribute6 is the interest formula.             --
      -- Valid JLBR_INTEREST_PENALTY_TYPE.  Not Mandatory.      --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_header_attribute6 IS NOT NULL THEN

          BEGIN
            SELECT 'Success'
              INTO dummy_code
              FROM fnd_lookups
              WHERE lookup_code = p_header_attribute6
                AND lookup_type = 'JLBR_INTEREST_PENALTY_TYPE'
                AND enabled_flag = 'Y'
                AND nvl(start_date_active,sysdate) <= sysdate
                AND nvl(end_date_active,sysdate+1) >= sysdate;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                      , 'JL_BR_AR_RAXTRX_PEN_TYPE_INV'
                                      , p_interface_line_id
                                      , p_header_attribute6) THEN
                 RAISE error_condition;
              END IF;
            WHEN OTHERS THEN
                 RAISE  error_condition;

          END; -- p_header_attribute6

        END IF;

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- header_attribute7 is the interest rate o amount for the--
      -- invoice.                                               --
      -- If penalty type = 'R' then interest rate between 0 and --
      -- 100.                                                   --
      -- If penalty type = 'A' then interest amount >= 0.       --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_header_attribute6 = 'R' AND
           p_header_attribute7 NOT BETWEEN 0 AND 100 THEN
          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                  , 'JL_BR_AR_RAXTRX_PEN_RATE_INV'
                                  , p_interface_line_id
                                  , p_header_attribute7) THEN
            RAISE error_condition;
          END IF;

        END IF;

        IF p_header_attribute6 = 'A' AND p_header_attribute7 < 0 THEN
          IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                  , 'JL_BR_AR_RAXTRX_PEN_AMNT_INV'
                                  , p_interface_line_id
                                  , p_header_attribute7) THEN
            RAISE error_condition;
          END IF;

        END IF;

      END IF; -- p_line_type = 'LINE'

      RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;

    END validate_interest_attributes;

    FUNCTION validate_billing_attributes (p_interface_line_id IN NUMBER
                                    , p_line_type             IN VARCHAR2
                                    , p_memo_line_id          IN NUMBER
                                    , p_inventory_item_id     IN NUMBER
                                    , p_header_attribute9     IN VARCHAR2
                                    , p_header_attribute10    IN VARCHAR2
                                    , p_header_attribute11    IN VARCHAR2
                                    , p_header_attribute13    IN VARCHAR2
                                    , p_header_attribute15    IN VARCHAR2
                                    , p_header_attribute16    IN VARCHAR2
                                    , p_header_attribute17    IN VARCHAR2
                                    , p_line_attribute1       IN VARCHAR2
                                    , p_line_attribute4       IN VARCHAR2
                                    , p_line_attribute5       IN VARCHAR2
                                    , p_line_attribute6       IN VARCHAR2
                                    , p_line_attribute7       IN VARCHAR2)
      RETURN BOOLEAN IS

      dummy_code      VARCHAR2 (15);
      error_condition EXCEPTION;
      x_return_context VARCHAR2(30);

    BEGIN

      BEGIN
        SELECT return_context
        INTO   x_return_context
        FROM   oe_order_lines a, ra_interface_lines_gt b
        WHERE  a.line_id = b.interface_line_attribute6
        AND    b.interface_line_id = p_interface_line_id;

      EXCEPTION WHEN OTHERS THEN
        x_return_context := NULL;

      END;

      ------------------------------------------------------------
      -- header_attribute9 is the freight accesory expense      --
      -- Numeric .  No Mandatory                                --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        BEGIN
          -- Bug 9085547 Start
          SELECT FND_NUMBER.canonical_to_number(nvl (p_header_attribute9, 999))
          -- Bug 9085547 End
            INTO dummy_code
            FROM sys.dual;

        EXCEPTION
          WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                    , 'JL_BR_AR_RAXTRX_FRT_EXP_INV'
                                    , p_interface_line_id
                                    , p_header_attribute9) THEN
               RAISE error_condition;
            END IF;
          WHEN OTHERS THEN
               RAISE  error_condition;
        END; -- p_header_attribute9

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- header_attribute10 is the Insurance accesory expense   --
      -- Numeric .  No Mandatory                                --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        BEGIN
          -- Bug 9085547 Start
          SELECT FND_NUMBER.canonical_to_number(nvl (p_header_attribute10, 999))
          -- Bug 9085547 End
            INTO dummy_code
            FROM sys.dual;

        EXCEPTION
          WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                    , 'JL_BR_AR_RAXTRX_INS_EXP_INV'
                                    , p_interface_line_id
                                    , p_header_attribute10) THEN
               RAISE error_condition;
            END IF;
          WHEN OTHERS THEN
               RAISE  error_condition;

        END; -- p_header_attribute10

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- header_attribute11 is the Other accessory expense      --
      -- Numeric .  No Mandatory                                --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        BEGIN
          -- Bug 9085547 Start
          SELECT FND_NUMBER.canonical_to_number(nvl (p_header_attribute11, 999))
          -- Bug 9085547 End
            INTO dummy_code
            FROM sys.dual;

        EXCEPTION
          WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                    , 'JL_BR_AR_RAXTRX_OTH_EXP_INV'
                                    , p_interface_line_id
                                    , p_header_attribute11) THEN
               RAISE error_condition;
            END IF;
          WHEN OTHERS THEN
               RAISE  error_condition;

        END; --p_header_attribute11

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- header_attribute13 is the Volume Quantity              --
      -- Numeric .  No Mandatory                                --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        BEGIN
          -- Bug 9085547 Start
          SELECT FND_NUMBER.canonical_to_number(nvl (p_header_attribute13, 999))
          -- Bug 9085547 End
            INTO dummy_code
            FROM sys.dual;

        EXCEPTION
          WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                    , 'JL_BR_AR_RAXTRX_VOL_QTY_INV'
                                    , p_interface_line_id
                                    , p_header_attribute13) THEN
               RAISE error_condition;
            END IF;
          WHEN OTHERS THEN
               RAISE  error_condition;
        END; --p_header_attribute13

      END IF; -- p_line_type = 'LINE'

      ------------------------------------------------------------
      -- header_attribute16 is the Total gross Weight           --
      -- Numeric .  No Mandatory                                --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        BEGIN
          SELECT FND_NUMBER.canonical_to_number(nvl(p_header_attribute16, 999))
            INTO dummy_code
            FROM sys.dual;

        EXCEPTION
          WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                    , 'JL_BR_AR_RAXTRX_GRS_WGT_INV'
                                    , p_interface_line_id
                                    , p_header_attribute16) THEN
               RAISE error_condition;
            END IF;
          WHEN OTHERS THEN
               RAISE  error_condition;

        END; --p_header_attribute16

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- header_attribute17 is the Total Net Weight             --
      -- Numeric .  No Mandatory                                --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        BEGIN
          SELECT FND_NUMBER.canonical_to_number(nvl(p_header_attribute17, 999))
            INTO dummy_code
            FROM sys.dual;

        EXCEPTION
          WHEN INVALID_NUMBER OR VALUE_ERROR THEN
            IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                    , 'JL_BR_AR_RAXTRX_NET_WGT_INV'
                                    , p_interface_line_id
                                    , p_header_attribute17) THEN
               RAISE error_condition;
            END IF;
          WHEN OTHERS THEN
               RAISE  error_condition;

        END; --p_header_attribute17

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- line_attribute1 is the operation fiscal code (CFO)     --
      -- Valid JL_AR_AP_OPERATIONS.  Mandatory.                 --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_line_attribute1 IS NOT NULL THEN

          BEGIN
            SELECT 'Success'
              INTO dummy_code
              FROM jl_br_ap_operations
              WHERE cfo_code = p_line_attribute1;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                      , 'JL_BR_AR_RAXTRX_OP_FISC_INV'
                                      , p_interface_line_id
                                      , p_line_attribute1) THEN
                 RAISE error_condition;
              END IF;
            WHEN OTHERS THEN
                 RAISE  error_condition;
          END; -- p_line_attribute1
        ELSE
          IF x_return_context IS NULL THEN
             IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                  , 'JL_BR_AR_RAXTRX_OP_FISC_MND'
                                  , p_interface_line_id
                                  , p_line_attribute1) THEN
               RAISE error_condition;
             END IF;
          ELSE
            NULL;
          END IF;

        END IF;

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- line_attribute4 is the item origin                     --
      -- Mandatory if RA_INTERFACE_LINES.INVENTORY_ITEM_ID is   --
      -- not null or RA_INTERFACE_LINES.MEMO_LINE_ID is not null--
      --                                                        --
      -- Valid ITEM_ORIGIN                                      --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_memo_line_id IS NOT NULL OR
           p_inventory_item_id IS NOT NULL THEN

          IF p_line_attribute4 IS NOT NULL THEN

            BEGIN

/* Old Code Commented by Sierra on 03/29/99 for MLS */

--              SELECT 'Success'
--                INTO dummy_code
--                FROM jl_br_lookup_codes
--                WHERE lookup_code = p_line_attribute4
--                  AND lookup_type = 'ITEM_ORIGIN'
--                  AND nvl (inactive_date, sysdate + 1) > sysdate;

/* End of Old Code */

/* New Code for MLS by Sierra on 03/29/99 */
/* Lookup Type value modified by Sierra on 06/11/99 */

              SELECT 'Success'
                INTO dummy_code
                FROM fnd_lookups
                WHERE lookup_code = p_line_attribute4
                  AND lookup_type = 'JLBR_ITEM_ORIGIN'
                  AND nvl (end_date_active, sysdate + 1) > sysdate;

/* End of New Code */

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                         , 'JL_BR_AR_RAXTRX_IT_ORIG_INV'
                                         , p_interface_line_id
                                         , p_line_attribute4) THEN
                    RAISE error_condition;
                 END IF;
               WHEN OTHERS THEN
                    RAISE  error_condition;

             END; --p_line_attribute4
          ELSE
            IF x_return_context IS NULL THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                        , 'JL_BR_AR_RAXTRX_IT_ORIG_MND'
                                        , p_interface_line_id
                                        , p_line_attribute4) THEN
                RAISE error_condition;
              END IF;
            ELSE
              NULL;
            END IF;
          END IF;

        END IF;

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- line_attribute5 is the Fiscal Type.                    --
      -- Mandatory if RA_INTERFACE_LINES.INVENTORY_ITEM_ID is   --
      -- not null or RA_INTERFACE_LINES.MEMO_LINE_ID is not null--
      --                                                        --
      -- Valid ITEM_FISCAL_TYPE                                 --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_memo_line_id IS NOT NULL OR
           p_inventory_item_id IS NOT NULL THEN

          IF p_line_attribute5 IS NOT NULL THEN

            BEGIN

            /* Old Code Commented By Sierra on 03/29/99 for MLS */

     --         SELECT 'Success'
     --           INTO dummy_code
     --           FROM jl_br_lookup_codes
     --           WHERE lookup_code = p_line_attribute5
     --             AND lookup_type = 'ITEM_FISCAL_TYPE'
     --             AND nvl (inactive_date, sysdate + 1) > sysdate;

  	     /* End of Old Code */

  	     /* New Code for MLS by Sierra on 03/29/99 */

  	               SELECT 'Success'
                	 INTO  dummy_code
               		 FROM  fnd_lookups
                	 WHERE lookup_code = p_line_attribute5
                  	   AND lookup_type = 'JLBR_ITEM_FISCAL_TYPE'
                  	   AND nvl (end_date_active, sysdate + 1) > sysdate;

	      /* End of New Code */

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                        , 'JL_BR_AR_RAXTRX_IT_FISC_TP_INV'
                                        , p_interface_line_id
                                        , p_line_attribute5) THEN
                   RAISE error_condition;
                END IF;
              WHEN OTHERS THEN
                   RAISE  error_condition;

            END; -- p_line_attribute5
          ELSE
            IF x_return_context IS NULL THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                      , 'JL_BR_AR_RAXTRX_IT_FISC_TP_MND'
                                      , p_interface_line_id
                                      , p_line_attribute5) THEN
                RAISE error_condition;
              END IF;
            ELSE
              NULL;
            END IF;
          END IF;

        END IF;

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- line_attribute6 is the Federal Tributary Situation     --
      -- Mandatory if RA_INTERFACE_LINES.INVENTORY_ITEM_ID is   --
      -- not null or RA_INTERFACE_LINES.MEMO_LINE_ID is not null--
      --                                                        --
      -- Valid ITEM_FEDERAL_SITUATION                           --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_memo_line_id IS NOT NULL OR
           p_inventory_item_id IS NOT NULL THEN

          IF p_line_attribute6 IS NOT NULL THEN

            BEGIN

            /* Old Code Commented by Sierra for MLS on 03/29/99 */

   --           SELECT 'Success'
   --             INTO dummy_code
   --             FROM jl_br_lookup_codes
   --             WHERE lookup_code = p_line_attribute6
   --               AND lookup_type = 'ITEM_FEDERAL_SITUATION'
   --               AND nvl (inactive_date, sysdate + 1) > sysdate;

            /* End of Old Code */

            /* New Code for MLS by Sierra on 03/29/99 */

             SELECT 'Success'
                INTO dummy_code
                FROM fnd_lookups
                WHERE lookup_code = p_line_attribute6
                  AND lookup_type = 'JLBR_ITEM_FEDERAL_SITUATION'
                  AND nvl (end_date_active, sysdate + 1) > sysdate;

            /* End of New Code */

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                        , 'JL_BR_AR_RAXTRX_FED_TR_SIT_INV'
                                        , p_interface_line_id
                                        , p_line_attribute6) THEN
                   RAISE error_condition;
                END IF;
              WHEN OTHERS THEN
                   RAISE  error_condition;
            END; -- p_line_attribute6
          ELSE
            IF x_return_context IS NULL THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                      , 'JL_BR_AR_RAXTRX_FED_TR_SIT_MND'
                                      , p_interface_line_id
                                      , p_line_attribute5) THEN
                RAISE error_condition;
              END IF;
            ELSE
              NULL;
            END IF;

          END IF;

        END IF;

      END IF; -- p_line_type = 'LINE'


      ------------------------------------------------------------
      -- line_attribute7 is the State Tributary Situation       --
      -- Mandatory if RA_INTERFACE_LINES.INVENTORY_ITEM_ID is   --
      -- not null or RA_INTERFACE_LINES.MEMO_LINE_ID is not null--
      --                                                        --
      -- Valid ITEM_STATE_SITUATION                             --
      ------------------------------------------------------------
      IF p_line_type = 'LINE' THEN

        IF p_memo_line_id IS NOT NULL OR
           p_inventory_item_id IS NOT NULL THEN

          IF p_line_attribute7 IS NOT NULL THEN

            BEGIN

            /* Old Code Commented by Sierra for MLS on 03/29/99 */

      --        SELECT 'Success'
      --          INTO dummy_code
      --          FROM jl_br_lookup_codes
      --          WHERE lookup_code = p_line_attribute7
      --            AND lookup_type = 'ITEM_STATE_SITUATION'
      --            AND nvl (inactive_date, sysdate + 1) > sysdate;

             /* End of Old Code */

             /* New Code for MLS by Sierra on 03/29/99 */

             SELECT 'Success'
                INTO dummy_code
                FROM fnd_lookups
                WHERE lookup_code = p_line_attribute7
                  AND lookup_type = 'JLBR_ITEM_STATE_SITUATION'
                  AND nvl (end_date_active, sysdate + 1) > sysdate;

             /* End of New Code */

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                        , 'JL_BR_AR_RAXTRX_STA_TR_SIT_INV'
                                        , p_interface_line_id
                                        , p_line_attribute7) THEN
                   RAISE error_condition;
                END IF;
              WHEN OTHERS THEN
                   RAISE  error_condition;

            END; -- p_line_attribute7
          ELSE
            IF x_return_context IS NULL THEN
              IF NOT JG_ZZ_AUTO_INVOICE.put_error_message ('JL'
                                      , 'JL_BR_AR_RAXTRX_STA_TR_SIT_MND'
                                      , p_interface_line_id
                                      , p_line_attribute5) THEN
                RAISE error_condition;
              END IF;
            ELSE
              NULL;
            END IF;

          END IF; -- p_line_attribute7 is not null

        END IF;

      END IF; -- p_line_type = 'LINE'

      RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;

    END validate_billing_attributes;

   FUNCTION validate_gdff
     (p_request_id IN NUMBER,
      p_org_id     IN NUMBER DEFAULT                --Bugfix 2367111
                      to_number(fnd_profile.value('ORG_ID'))
     ) RETURN NUMBER IS

    return_code    NUMBER (1);
    l_tax_method   VARCHAR2(30);
    l_country_code VARCHAR2(2);
    l_org_id      NUMBER;

    CURSOR trx_lines_cursor (c_request_id NUMBER) IS
      SELECT interface_line_id
           , cust_trx_type_id  trx_type
           , trx_date
           , nvl(orig_system_ship_address_id , orig_system_bill_address_id)
                         orig_system_address_id
           , line_type
           , memo_line_id
           , inventory_item_id
           , header_gdf_attribute1
           , header_gdf_attribute2
           , header_gdf_attribute3
           , header_gdf_attribute4
           , header_gdf_attribute5
           , header_gdf_attribute6
           , header_gdf_attribute7
           , header_gdf_attribute8
           , header_gdf_attribute9
           , header_gdf_attribute10
           , header_gdf_attribute11
           , header_gdf_attribute12
           , header_gdf_attribute13
           , header_gdf_attribute14
           , header_gdf_attribute15
           , header_gdf_attribute16
           , header_gdf_attribute17
           , line_gdf_attribute1
           , line_gdf_attribute2
           , line_gdf_attribute3
         -- nipatel commented out because the columns below will not be added to ra_interface_lines
         --  , product_fisc_classification
         --  , product_category
         --  , trx_business_category
           , line_gdf_attribute4
           , line_gdf_attribute5
           , line_gdf_attribute6
           , line_gdf_attribute7
           , line_gdf_attribute8
           , line_gdf_attribute9
           , line_gdf_attribute10
           , line_gdf_attribute11
           , line_gdf_attribute12
           , warehouse_id
           , batch_source_name
           , trx_number
        FROM ra_interface_lines_gt
        WHERE request_id = c_request_id
        ORDER BY trx_date;

  ------------------------------------------------------------
  ----- Tax validation function.
  ----------------------------------------------------------


  ------------------------------------------------------------
  -- Interest validation function                           --
  ------------------------------------------------------------


  ------------------------------------------------------------
  -- Billing validation function                            --
  ------------------------------------------------------------

  ------------------------------------------------------------
  -- Main function body.                                    --
  ------------------------------------------------------------


  BEGIN

    ------------------------------------------------------------
    -- Let's assume everything is OK                          --
    ------------------------------------------------------------
    --arp_standard.debug('JL_ZZ_AUTO_INVOICE.validate_gdff()+');
    IF PG_DEBUG = 'Y' THEN
    	arp_util_tax.debug('JL_ZZ_AUTO_INVOICE.validate_gdff()+');
    END IF;

    return_code := 1;
    --Bug Fix 2367111
    --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');
    l_org_id := MO_GLOBAL.get_current_org_id;
    l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null);

    --arp_standard.debug('-- Country Code: '||l_country_code);
    --arp_standard.debug('-- Request Id: '||to_char(p_request_id));
    IF PG_DEBUG = 'Y' THEN
    	arp_util_tax.debug('validate_gdff: ' || '-- Country Code: '||l_country_code);
    	arp_util_tax.debug('validate_gdff: ' || '-- Request Id: '||to_char(p_request_id));
    END IF;

    ------------------------------------------------------------
    -- Validate all the rows for this concurrent request      --
    ------------------------------------------------------------
    FOR trx_line_record IN trx_lines_cursor (p_request_id)
    LOOP

      IF l_country_code IN ('BR','AR','CO') THEN

         l_tax_method := JL_ZZ_AR_TX_LIB_PKG.get_tax_method(l_org_id);

         --arp_standard.debug('-- Tax Method: '||l_tax_method);
         IF PG_DEBUG = 'Y' THEN
         	arp_util_tax.debug('validate_gdff: ' || '-- Tax Method: '||l_tax_method);
         END IF;

         IF l_tax_method = 'LTE' THEN



            IF NOT validate_tax_attributes (trx_line_record.interface_line_id
                                   , trx_line_record.line_type
                                   , trx_line_record.memo_line_id
                                   , trx_line_record.inventory_item_id
                                   , trx_line_record.line_gdf_attribute2
                                   , trx_line_record.line_gdf_attribute3
                                   , trx_line_record.line_gdf_attribute3
                                   , trx_line_record.line_gdf_attribute11
                                   , trx_line_record.line_gdf_attribute12
                                   , trx_line_record.orig_system_address_id
                                   , trx_line_record.warehouse_id) THEN

               --arp_standard.debug('-- validate_tax_attributes routine failed');
               IF PG_DEBUG = 'Y' THEN
               	arp_util_tax.debug('validate_gdff: ' || '-- validate_tax_attributes routine failed');
               END IF;
               return_code := 0;
            END IF; -- Validate tax
         END IF; -- l_tax_method check
      END IF; -- Tax method check

      IF l_country_code = 'BR' THEN
         IF NOT validate_interest_attributes
                                  (  trx_line_record.interface_line_id
                                   , trx_line_record.line_type
                                   , trx_line_record.header_gdf_attribute1
                                   , trx_line_record.header_gdf_attribute2
                                   , trx_line_record.header_gdf_attribute3
                                   , trx_line_record.header_gdf_attribute4
                                   , trx_line_record.header_gdf_attribute5
                                   , trx_line_record.header_gdf_attribute6
                                   , trx_line_record.header_gdf_attribute7) THEN

           --arp_standard.debug('-- validate_interest_attributes routine failed');
           IF PG_DEBUG = 'Y' THEN
           	arp_util_tax.debug('validate_gdff: ' || '-- validate_interest_attributes routine failed');
           END IF;

           return_code := 0;
         END IF;  -- Validate interest

         IF NOT validate_billing_attributes (trx_line_record.interface_line_id
                                   , trx_line_record.line_type
                                   , trx_line_record.memo_line_id
                                   , trx_line_record.inventory_item_id
                                   , trx_line_record.header_gdf_attribute9
                                   , trx_line_record.header_gdf_attribute10
                                   , trx_line_record.header_gdf_attribute11
                                   , trx_line_record.header_gdf_attribute13
                                   , trx_line_record.header_gdf_attribute15
                                   , trx_line_record.header_gdf_attribute16
                                   , trx_line_record.header_gdf_attribute17
                                   , trx_line_record.line_gdf_attribute1
                                   , trx_line_record.line_gdf_attribute4
                                   , trx_line_record.line_gdf_attribute5
                                   , trx_line_record.line_gdf_attribute6
                                   , trx_line_record.line_gdf_attribute7) THEN

            --arp_standard.debug('-- validate_billing_attributes routine failed');
            IF PG_DEBUG = 'Y' THEN
            	arp_util_tax.debug('validate_gdff: ' || '-- validate_billing_attributes routine failed');
            END IF;

            return_code := 0;
         END IF; -- Validate billing

      ELSIF l_country_code = 'AR' THEN
         ------------------------------------------------------------
         -- Validate all the rows for this concurrent request      --
         ------------------------------------------------------------
         IF NOT JL_AR_DOC_NUMBERING_PKG.validate_interface_lines
                                  (  p_request_id
                                   , trx_line_record.interface_line_id
                                   , trx_line_record.trx_type
                                   , trx_line_record.inventory_item_id
                                   , trx_line_record.memo_line_id
                                   , trx_line_record.trx_date
                                   , trx_line_record.orig_system_address_id
                                   , trx_line_record.warehouse_id
                                   ) THEN

            --arp_standard.debug('-- JL_AR_DOC_NUMBERING_PKG.'||'validate_interface_lines routine failed');
            IF PG_DEBUG = 'Y' THEN
            	arp_util_tax.debug('validate_gdff: ' || '-- JL_AR_DOC_NUMBERING_PKG.'||'validate_interface_lines routine failed');
            END IF;

            return_code := 0;
         END IF;  -- Validate interface lines
      END IF;

    END LOOP;

    --arp_standard.debug('-- Return Code: '||to_char(return_code));
    --arp_standard.debug('JL_ZZ_AUTO_INVOICE.validate_gdff()-');
    IF PG_DEBUG = 'Y' THEN
    	arp_util_tax.debug('validate_gdff: ' || '-- Return Code: '||to_char(return_code));
    	arp_util_tax.debug('JL_ZZ_AUTO_INVOICE.validate_gdff()-');
    END IF;

    RETURN return_code;

  EXCEPTION
    WHEN OTHERS THEN

      --arp_standard.debug('-- Return From Exception when others');
      --arp_standard.debug('-- Return Code: 0');
      --arp_standard.debug('JL_ZZ_AUTO_INVOICE.validate_gdff()-');
      IF PG_DEBUG = 'Y' THEN
      	arp_util_tax.debug('validate_gdff: ' || '-- Return From Exception when others');
      	arp_util_tax.debug('validate_gdff: ' || '-- Return Code: 0');
      	arp_util_tax.debug('JL_ZZ_AUTO_INVOICE.validate_gdff()-');
      END IF;

      RETURN 0;

  END validate_gdff;

  FUNCTION trx_num_upd
       (p_batch_source_id IN NUMBER,
        p_trx_number      IN VARCHAR2,
        p_org_id          IN NUMBER DEFAULT              --Bugfix 2367111
                           to_number(fnd_profile.value('ORG_ID'))
       ) RETURN VARCHAR2 IS

    l_trx_number              ra_customer_trx_all.trx_number%TYPE;
    l_country_code            VARCHAR2(2);
    l_org_id                  NUMBER;

  BEGIN
    --Bug Fix 2367111
    --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');
    l_org_id := mo_global.get_current_org_id;
    l_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY(l_org_id, null);

    IF l_country_code = 'AR' THEN
       l_trx_number := JL_AR_DOC_NUMBERING_PKG.trx_num_gen(p_batch_source_id,
                                                           p_trx_number);
    END IF;

    RETURN l_trx_number;

  EXCEPTION
  WHEN OTHERS THEN
      RAISE;
  END trx_num_upd;


  FUNCTION jl_br_cm_upd_inv_status (p_request_id IN number) RETURN NUMBER is         -- Added for bug 9183563
		l_status_code  number := 1;

  BEGIN

	update ra_customer_trx
        set status_trx ='VD'
        where customer_trx_id in (select  trx.previous_customer_trx_id
                                    from  ra_customer_trx trx,
                                          ra_cust_trx_types trx_type
                                    where  trx.cust_trx_type_id = trx_type.cust_trx_type_id
                                      and  trx.request_id = p_request_id
                                      and  trx_type.type = 'CM'
                                      and  trx_type.default_status = 'VD'
                                      and  trx.previous_customer_trx_id is not null);


       return l_status_code ;

  EXCEPTION
        WHEN OTHERS THEN
        l_status_code := 0;
        fnd_file.put_line(fnd_file.log,'IN jl_br_cm_upd_inv_status :'||SQLCODE||'-'||SQLERRM);
        return l_status_code;
  END jl_br_cm_upd_inv_status;


END JL_ZZ_AUTO_INVOICE;

/
