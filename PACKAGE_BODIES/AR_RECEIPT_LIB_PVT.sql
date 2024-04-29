--------------------------------------------------------
--  DDL for Package Body AR_RECEIPT_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RECEIPT_LIB_PVT" AS
/* $Header: ARXPRELB.pls 120.78.12010000.12 2009/08/25 07:15:28 spdixit ship $           */

G_PKG_NAME   CONSTANT VARCHAR2(30)      := 'AR_RECEIPT_LIB_PVT';

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

G_SITE_USE_CACHE_SIZE            BINARY_INTEGER  := 1000;
G_CUST_NUM_CACHE_SIZE            BINARY_INTEGER  := 1000;
G_CUST_NAME_CACHE_SIZE           BINARY_INTEGER  := 1000;
G_METHOD_CACHE_SIZE              BINARY_INTEGER  := 1000;
G_CUST_BK_AC_NUM_CACHE_SIZE    BINARY_INTEGER  := 1000;
G_CUST_BK_AC_NAME_CACHE_SIZE   BINARY_INTEGER  := 1000;
G_REMIT_BK_AC_NUM_CACHE_SIZE   BINARY_INTEGER  := 1000;
G_REMIT_BK_AC_NAME_CACHE_SIZE  BINARY_INTEGER  := 1000;
G_CURRENCY_CACHE_SIZE            BINARY_INTEGER  := 1000;
G_RATE_TYPE_CACHE_SIZE           BINARY_INTEGER  := 1000;
G_METHOD_INFO_CACHE_SIZE         BINARY_INTEGER  := 1000;
G_EXCHANGE_RATE_CACHE_SIZE       BINARY_INTEGER  := 1000;
G_ACTIVITY_NAME_CACHE_SIZE       BINARY_INTEGER  := 1000; -- Bugfix 2853738
/* Bug fix 2982212 */
G_TAX_CODE_CACHE_SIZE            BINARY_INTEGER  := 1000;
G_REF_PAYMENT_CACHE_SIZE         BINARY_INTEGER  := 1000;
G_REF_PAYMENT_BATCH_CACHE_SIZE   BINARY_INTEGER  := 1000;
G_REF_RECEIPT_CACHE_SIZE         BINARY_INTEGER  := 1000;
G_REF_REMITTANCE_CACHE_SIZE      BINARY_INTEGER  := 1000;
G_LEGAL_ENTITY_CACHE_SIZE        BINARY_INTEGER  := 1000;

/* modified for tca uptake */
TYPE Site_Use_Cache_Rec_Type IS RECORD
                     (id               hz_cust_site_uses.site_use_id%TYPE,
                      customer_id      hz_cust_acct_sites.cust_account_id%TYPE,
                      site_use_code    hz_cust_site_uses.site_use_code%TYPE,
                      location         hz_cust_site_uses.location%TYPE,
                      primary_flag     VARCHAR2(1)
                      );
TYPE Exchange_Rate_Cache_Rec_Type IS RECORD
                   (exchange_rate    ar_cash_receipts.exchange_rate%TYPE,
                    currency         ar_cash_receipts.currency_code%TYPE,
                    exchange_rate_type ar_cash_receipts.exchange_rate_type%TYPE,
                    exchange_date    ar_cash_receipts.exchange_date%TYPE
                   );

TYPE Method_Info_Cache_Rec_Type IS RECORD
	    (receipt_method_id            ar_cash_receipts.receipt_method_id%TYPE,
	     remit_bank_acct_use_id       ar_cash_receipts.remit_bank_acct_use_id%TYPE,
	     currency_code                ar_cash_receipts.currency_code%TYPE,
             called_from                  VARCHAR2(200),
	     state                        ar_receipt_classes.creation_status%TYPE,
	     creation_method_code         ar_receipt_classes.creation_method_code%TYPE,
	     bau_end_date                 ce_bank_acct_uses.end_date%TYPE,
	     rm_start_date                ar_receipt_methods.start_date%TYPE,
	     rm_end_date                  ar_receipt_methods.end_date%TYPE,
	     rma_start_date               ar_receipt_method_accounts.start_date%TYPE,
	     rma_end_date                 ar_receipt_method_accounts.end_date%TYPE
	     );

TYPE Id_Cache_Rec_Type IS RECORD
                 ( id     VARCHAR2(100),
                   value  VARCHAR2(100)
                  );


TYPE Site_Use_Cache_Tbl_Type IS
     TABLE OF    Site_Use_Cache_Rec_Type
     INDEX BY    BINARY_INTEGER;


TYPE Exchange_Rate_Cache_Tbl_Type IS
     TABLE OF    Exchange_Rate_Cache_Rec_Type
     INDEX BY    BINARY_INTEGER;

TYPE Method_Info_Cache_Tbl_Type IS
     TABLE OF    Method_Info_Cache_Rec_Type
     INDEX BY    BINARY_INTEGER;

TYPE Id_Cache_Tbl_Type IS
     TABLE OF    Id_Cache_Rec_Type
     INDEX BY    BINARY_INTEGER;


G_Site_Use_Cache_Tbl             Site_Use_Cache_Tbl_Type;
G_Cust_Num_Cache_Tbl             Id_Cache_Tbl_Type;
G_Cust_Name_Cache_Tbl            Id_Cache_Tbl_Type;
G_Method_Cache_Tbl               Id_Cache_Tbl_Type;
G_Cust_Bank_Ac_Num_Cache_Tbl     Id_Cache_Tbl_Type;
G_Cust_Bank_Ac_Name_Cache_Tbl    Id_Cache_Tbl_Type;
G_Remit_Bank_Ac_Num_Cache_Tbl    Id_Cache_Tbl_Type;
G_Remit_Bank_Ac_Name_Cache_Tbl   Id_Cache_Tbl_Type;
G_Currency_Cache_Tbl             Id_Cache_Tbl_Type;
G_Rate_Type_Cache_Tbl            Id_Cache_Tbl_Type;
Method_Info_Cache_Tbl            Method_Info_Cache_Tbl_Type;
Exchange_Rate_Cache_Tbl          Exchange_Rate_Cache_Tbl_Type;
G_Activity_Name_Cache_Tbl        Id_Cache_Tbl_Type; -- Bugfix 2853738
/* Bug fix 2982212 */
G_Tax_Code_Cache_Tbl             Id_Cache_Tbl_Type;
G_Ref_Payment_Cache_Tbl          Id_Cache_Tbl_Type;
G_Ref_Payment_Batch_Cache_Tbl    Id_Cache_Tbl_Type;
G_Ref_Receipt_Cache_Tbl          Id_Cache_Tbl_Type;
G_Ref_Remittance_Cache_Tbl       Id_Cache_Tbl_Type;
G_Legal_Entity_Cache_Tbl         Id_Cache_Tbl_Type;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Configure_Library_Caches(
                p_site_use_cache     IN BINARY_INTEGER   DEFAULT 1000,
                p_cust_number_cache  IN BINARY_INTEGER   DEFAULT 1000,
                p_cust_name_cache    IN BINARY_INTEGER   DEFAULT 1000,
                p_receipt_method_cache IN BINARY_INTEGER  DEFAULT 1000,
                p_cust_bank_ac_num_cache  IN BINARY_INTEGER  DEFAULT 1000,
                p_cust_bank_ac_name_cache IN BINARY_INTEGER  DEFAULT 1000,
                p_remit_bank_ac_num_cache IN BINARY_INTEGER  DEFAULT 1000,
                p_remit_bank_ac_name_cache IN BINARY_INTEGER DEFAULT 1000,
                p_currency_cache          IN BINARY_INTEGER  DEFAULT 1000,
                p_rate_type_cache         IN BINARY_INTEGER  DEFAULT 1000,
                p_method_info_cache       IN BINARY_INTEGER  DEFAULT 1000,
                p_exchange_rate_cache     IN BINARY_INTEGER  DEFAULT 1000
                )  IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Configure_Library_Caches()+ ');
   END IF;

G_SITE_USE_CACHE_SIZE            := p_site_use_cache;
G_CUST_NUM_CACHE_SIZE            := p_cust_number_cache;
G_CUST_NAME_CACHE_SIZE           := p_cust_name_cache;
G_METHOD_CACHE_SIZE              := p_receipt_method_cache;
G_CUST_BK_AC_NUM_CACHE_SIZE    := p_cust_bank_ac_num_cache;
G_CUST_BK_AC_NAME_CACHE_SIZE   := p_cust_bank_ac_name_cache;
G_REMIT_BK_AC_NUM_CACHE_SIZE   := p_remit_bank_ac_num_cache;
G_REMIT_BK_AC_NAME_CACHE_SIZE  := p_remit_bank_ac_name_cache;
G_CURRENCY_CACHE_SIZE            := p_currency_cache;
G_RATE_TYPE_CACHE_SIZE           := p_rate_type_cache;
G_METHOD_INFO_CACHE_SIZE         := p_method_info_cache;
G_EXCHANGE_RATE_CACHE_SIZE       := p_exchange_rate_cache;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Configure_Library_Caches()- ');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('EXCEPTION: Configure_Library_Caches() ');
      END IF;
      RAISE;

END Configure_Library_Caches;
PROCEDURE Add_Value_To_Cache(p_cache_name  IN VARCHAR2,
                             p_value       IN VARCHAR2,
                             p_id          IN VARCHAR2,
                             p_index       IN BINARY_INTEGER
                            ) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Add_Value_To_Cache()+ ');
   END IF;

   IF        ( p_cache_name = 'CUSTOMER_NUMBER' )
    THEN
             IF   ( p_index <= G_CUST_NUM_CACHE_SIZE )
             THEN
                  G_Cust_Num_Cache_Tbl( p_index ).value := p_value;
                  G_Cust_Num_Cache_Tbl( p_index ).id    := p_id;
             END IF;

   ELSIF     ( p_cache_name = 'CUSTOMER_NAME' )
    THEN
             IF   ( p_index <= G_CUST_NAME_CACHE_SIZE )
             THEN
                  G_Cust_Name_Cache_Tbl( p_index ).value := p_value;
                  G_Cust_Name_Cache_Tbl( p_index ).id    := p_id;
             END IF;
   ELSIF     ( p_cache_name = 'RECEIPT_METHOD_NAME' )
    THEN
             IF   ( p_index <= G_METHOD_CACHE_SIZE )
             THEN
                  G_Method_Cache_Tbl( p_index ).value := p_value;
                  G_Method_Cache_Tbl( p_index ).id    := p_id;
             END IF;
   ELSIF     ( p_cache_name = 'CUST_BANK_ACCOUNT_NUMBER' )
    THEN
             IF   ( p_index <= G_CUST_BK_AC_NUM_CACHE_SIZE )
             THEN
                  G_Cust_Bank_Ac_Num_Cache_Tbl( p_index ).value := p_value;
                  G_Cust_Bank_Ac_Num_Cache_Tbl( p_index ).id    := p_id;
             END IF;
   ELSIF     ( p_cache_name = 'CUST_BANK_ACCOUNT_NAME' )
    THEN
             IF   ( p_index <= G_CUST_BK_AC_NAME_CACHE_SIZE )
             THEN
                  G_Cust_Bank_Ac_Name_Cache_Tbl( p_index ).value := p_value;
                  G_Cust_Bank_Ac_Name_Cache_Tbl( p_index ).id    := p_id;
             END IF;
   ELSIF     ( p_cache_name = 'REMIT_BANK_ACCOUNT_NUMBER' )
    THEN
             IF   ( p_index <= G_REMIT_BK_AC_NUM_CACHE_SIZE )
             THEN
                  G_Remit_Bank_Ac_Num_Cache_Tbl( p_index ).value := p_value;
                  G_Remit_Bank_Ac_Num_Cache_Tbl( p_index ).id    := p_id;
             END IF;
   ELSIF     ( p_cache_name = 'REMIT_BANK_ACCOUNT_NAME' )
    THEN
             IF   ( p_index <= G_REMIT_BK_AC_NAME_CACHE_SIZE )
             THEN
                  G_Remit_Bank_Ac_Name_Cache_Tbl( p_index ).value := p_value;
                  G_Remit_Bank_Ac_Name_Cache_Tbl( p_index ).id    := p_id;
             END IF;
   ELSIF     ( p_cache_name = 'CURRENCY_NAME' )
    THEN
             IF   ( p_index <= G_CURRENCY_CACHE_SIZE )
             THEN
                  G_Currency_Cache_Tbl( p_index ).value := p_value;
                  G_Currency_Cache_Tbl( p_index ).id    := p_id;
             END IF;
   ELSIF     ( p_cache_name = 'EXCHANGE_RATE_TYPE_NAME' )
    THEN
             IF   ( p_index <= G_RATE_TYPE_CACHE_SIZE )
             THEN
                  G_Rate_Type_Cache_Tbl( p_index ).value := p_value;
                  G_Rate_Type_Cache_Tbl( p_index ).id    := p_id;
             END IF;
               -- Bugfix 2853738
    ELSIF     ( p_cache_name = 'RECEIVABLES_ACTIVITY')
     THEN
              IF ( p_index <= G_ACTIVITY_NAME_CACHE_SIZE)
              THEN
                   G_Activity_Name_Cache_Tbl( p_index ).value := p_value;
                   G_Activity_Name_Cache_Tbl( p_index ).id    := p_id;
              END IF;
              /* Bug fix 2982212 */
    ELSIF     ( p_cache_name = 'TAX_CODE')
     THEN
              IF ( p_index <= G_TAX_CODE_CACHE_SIZE)
              THEN
                   G_Tax_Code_Cache_Tbl( p_index ).value := p_value;
                   G_Tax_Code_Cache_Tbl( p_index ).id    := p_id;
              END IF;
    ELSIF     ( p_cache_name = 'REF_PAYMENT')
     THEN
              IF ( p_index <= G_REF_PAYMENT_CACHE_SIZE)
              THEN
                   G_Ref_Payment_Cache_Tbl( p_index ).value := p_value;
                   G_Ref_Payment_Cache_Tbl( p_index ).id    := p_id;
              END IF;
    ELSIF     ( p_cache_name = 'REF_PAYMENT_BATCH')
     THEN
              IF ( p_index <= G_REF_PAYMENT_BATCH_CACHE_SIZE )
              THEN
                   G_Ref_Payment_Batch_Cache_Tbl( p_index ).value := p_value;
                   G_Ref_Payment_Batch_Cache_Tbl( p_index ).id    := p_id;
              END IF;
    ELSIF     ( p_cache_name = 'REF_RECEIPT')
     THEN
              IF ( p_index <= G_REF_RECEIPT_CACHE_SIZE)
              THEN
                   G_Ref_Receipt_Cache_Tbl( p_index ).value := p_value;
                   G_Ref_Receipt_Cache_Tbl( p_index ).id    := p_id;
              END IF;
    ELSIF     ( p_cache_name = 'REF_REMITTANCE')
     THEN
              IF ( p_index <= G_REF_REMITTANCE_CACHE_SIZE)
              THEN
                   G_Ref_Remittance_Cache_Tbl( p_index ).value := p_value;
                   G_Ref_Remittance_Cache_Tbl( p_index ).id    := p_id;
              END IF;
    ELSIF     ( p_cache_name = 'LEGAL_ENTITY')
     THEN
              IF ( p_index <= G_LEGAL_ENTITY_CACHE_SIZE)
              THEN
                   G_Legal_Entity_Cache_Tbl( p_index ).value := p_value;
                   G_Legal_Entity_Cache_Tbl( p_index ).id    := p_id;
              END IF;
    END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Add_Value_To_Cache()- ');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Add_Value_To_Cache. Cache: ' ||
                                                p_cache_name || ' ' ||
                                 '  Value: ' || p_value);
   END IF;
        RAISE;

END Add_Value_To_Cache;

FUNCTION Find_Value_In_Cache(
                     p_cache_name   IN VARCHAR2,
                     p_value        IN VARCHAR2,
                     p_index       OUT NOCOPY BINARY_INTEGER
                   ) RETURN VARCHAR2 IS

   l_index  BINARY_INTEGER;
   l_count  BINARY_INTEGER;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Find_Value_In_Cache()+ ');
   END IF;

   IF       (p_cache_name = 'CUSTOMER_NUMBER')
    THEN
     l_count := G_Cust_Num_Cache_Tbl.count;

   ELSIF    (p_cache_name = 'CUSTOMER_NAME')
    THEN
     l_count := G_Cust_Name_Cache_Tbl.count;

   ELSIF    (p_cache_name = 'RECEIPT_METHOD_NAME')
    THEN
     l_count := G_Method_Cache_Tbl.count;

   ELSIF    (p_cache_name = 'CUST_BANK_ACCOUNT_NUMBER')
    THEN
     l_count := G_Cust_Bank_Ac_Num_Cache_Tbl.count;

   ELSIF    (p_cache_name = 'CUST_BANK_ACCOUNT_NAME')
    THEN
     l_count := G_Cust_Bank_Ac_Name_Cache_Tbl.count;

   ELSIF    (p_cache_name = 'REMIT_BANK_ACCOUNT_NUMBER')
    THEN
     l_count := G_Remit_Bank_Ac_Num_Cache_Tbl.count;

   ELSIF    (p_cache_name = 'REMIT_BANK_ACCOUNT_NAME')
    THEN
     l_count := G_Remit_Bank_Ac_Name_Cache_Tbl.count;

   ELSIF    (p_cache_name = 'CURRENCY_NAME')
    THEN
     l_count := G_Currency_Cache_Tbl.count;

   ELSIF    (p_cache_name = 'EXCHANGE_RATE_TYPE_NAME')
    THEN
     l_count := G_Rate_Type_Cache_Tbl.count;

    -- Bugfix 2853738
    ELSIF    (p_cache_name = 'RECEIVABLES_ACTIVITY')
     THEN
      l_count := G_Activity_Name_Cache_Tbl.count ;

    /* Bugfix 2982212 */
    ELSIF    (p_cache_name = 'TAX_CODE')
     THEN
      l_count := G_Tax_Code_Cache_Tbl.count ;

    ELSIF    (p_cache_name = 'REF_PAYMENT')
     THEN
      l_count := G_Ref_Payment_Cache_Tbl.count ;

    ELSIF    (p_cache_name = 'REF_PAYMENT_BATCH')
     THEN
      l_count := G_Ref_Payment_Batch_Cache_Tbl.count ;

    ELSIF    (p_cache_name = 'REF_RECEIPT')
     THEN
      l_count := G_Ref_Receipt_Cache_Tbl.count ;

    ELSIF    (p_cache_name = 'REF_REMITTANCE')
     THEN
      l_count := G_Ref_Remittance_Cache_Tbl.count ;

    ELSIF    (p_cache_name = 'LEGAL_ENTITY')
     THEN
      l_count := G_Legal_Entity_Cache_Tbl.count ;
   END IF;


   FOR l_index IN 1..l_count LOOP

       p_index := l_index;

       IF    ( p_cache_name = 'CUSTOMER_NAME'
              AND G_Cust_Name_Cache_Tbl(l_index).value = p_value)
        THEN
         RETURN( G_Cust_Name_Cache_Tbl(l_index).id);

       ELSIF (p_cache_name = 'CUSTOMER_NUMBER' /* Bug 2982212*/
              AND G_Cust_Num_Cache_Tbl(l_index).value = p_value)
        THEN
         RETURN( G_Cust_Num_Cache_Tbl(l_index).id);

       ELSIF (p_cache_name = 'RECEIPT_METHOD_NAME' /* Bug 2982212*/
              AND G_Method_Cache_Tbl(l_index).value = p_value)
        THEN
         RETURN( G_Method_Cache_Tbl(l_index).id);

       ELSIF (p_cache_name = 'CUST_BANK_ACCOUNT_NUMBER'
              AND G_Cust_Bank_Ac_Num_Cache_Tbl(l_index).value = p_value)
        THEN
         RETURN(G_Cust_Bank_Ac_Num_Cache_Tbl(l_index).id);

       ELSIF (p_cache_name = 'CUST_BANK_ACCOUNT_NAME'
              AND G_Cust_Bank_Ac_Name_Cache_Tbl(l_index).value = p_value)
        THEN
         RETURN(G_Cust_Bank_Ac_Name_Cache_Tbl(l_index).id);

       ELSIF (p_cache_name = 'REMIT_BANK_ACCOUNT_NUMBER'
               AND G_Remit_Bank_Ac_Num_Cache_Tbl(l_index).value = p_value)
        THEN
         RETURN(G_Remit_Bank_Ac_Num_Cache_Tbl(l_index).id);

       ELSIF (p_cache_name = 'REMIT_BANK_ACCOUNT_NAME'
               AND G_Remit_Bank_Ac_Name_Cache_Tbl(l_index).value = p_value)
        THEN
         RETURN(G_Remit_Bank_Ac_Name_Cache_Tbl(l_index).id);

      -- bug2680657 : Added p_value condition for CURRENCY_NAME and
      -- EXCHANGE_RATE_TYPE_NAME
      ELSIF (p_cache_name = 'CURRENCY_NAME'
               AND G_Currency_Cache_Tbl(l_index).value = p_value)
       THEN
         RETURN(G_Currency_Cache_Tbl(l_index).id);

      ELSIF (p_cache_name = 'EXCHANGE_RATE_TYPE_NAME'
               AND G_Rate_Type_Cache_Tbl(l_index).value = p_value)
       THEN
        RETURN(G_Rate_Type_Cache_Tbl(l_index).id);

         -- Bugfix 2853738
      ELSIF (p_cache_name = 'RECEIVABLES_ACTIVITY'
               AND G_Activity_Name_Cache_Tbl(l_index).value = p_value)
       THEN
          RETURN( G_Activity_Name_Cache_Tbl(l_index).id);

         /* Bugfix 2982212 */
      ELSIF (p_cache_name = 'TAX_CODE'
               AND G_Tax_Code_Cache_Tbl(l_index).value = p_value)
       THEN
          RETURN( G_Tax_Code_Cache_Tbl(l_index).id);

      ELSIF (p_cache_name = 'REF_PAYMENT'
               AND G_Ref_Payment_Cache_Tbl(l_index).value = p_value)
       THEN
          RETURN( G_Ref_Payment_Cache_Tbl(l_index).id);

      ELSIF (p_cache_name = 'REF_PAYMENT_BATCH'
               AND G_Ref_Payment_Batch_Cache_Tbl(l_index).value = p_value)
       THEN
          RETURN( G_Ref_Payment_Batch_Cache_Tbl(l_index).id);

      ELSIF (p_cache_name = 'REF_RECEIPT'
               AND G_Ref_Receipt_Cache_Tbl(l_index).value = p_value)
       THEN
          RETURN( G_Ref_Receipt_Cache_Tbl(l_index).id);

      ELSIF (p_cache_name = 'REF_REMITTANCE'
               AND G_Ref_Remittance_Cache_Tbl(l_index).value = p_value)
       THEN
          RETURN( G_Ref_Remittance_Cache_Tbl(l_index).id);

      ELSIF (p_cache_name = 'LEGAL_ENTITY'
               AND G_Legal_Entity_Cache_Tbl(l_index).value = p_value)
       THEN
          RETURN( G_Legal_Entity_Cache_Tbl(l_index).id);
      END IF;

  END LOOP;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Find_Value_In_Cache()- ');
   END IF;

   RETURN(NULL);

EXCEPTION

   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Find_Value_In_Cache. Cache: ' ||
                                                p_cache_name || ' ' ||
                                 '  Value: ' || p_value);
        END IF;

        RAISE;

END Find_Value_In_Cache;



FUNCTION Get_Id(
                  p_entity    IN VARCHAR2,
                  p_value     IN VARCHAR2,
                  p_return_status OUT NOCOPY VARCHAR2,
                  p_date      IN DATE DEFAULT NULL
               ) RETURN VARCHAR2 IS

l_cached_id    VARCHAR2(100);
l_selected_id  VARCHAR2(100);
l_index        BINARY_INTEGER;
l_date         DATE;    -- ETAX: bug 4594101

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Get_Id()+ ');
      END IF;

      IF    ( p_value  IS NULL )
      THEN

           RETURN(NULL);

      ELSE
           l_cached_id := Find_Value_In_Cache( p_entity,
                                               p_value,
                                               l_index
                                             );

           IF ( l_cached_id  IS NOT NULL )
           THEN

                RETURN( l_cached_id );

           ELSE
                IF      ( p_entity = 'CUSTOMER_NUMBER' )
                THEN

                    /* modified for tca uptake */
                    /* fixed bug 1544201:  removed customer_prospect_code */
                    SELECT c.cust_account_id
                    INTO   l_selected_id
                    FROM   hz_cust_accounts c,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  c.cust_account_id = cp.cust_account_id (+) and
                           cp.site_use_id is null and
                           c.account_number = p_value
                      AND  c.party_id = party.party_id;

                ELSIF ( p_entity = 'CUSTOMER_NAME' )
                 THEN

                     /* modified for tca uptake */
                     /* fixed bug 1544201:  removed customer_prospect_code */
                    SELECT cust_acct.cust_account_id
                    INTO   l_selected_id
                    FROM   hz_cust_accounts cust_acct,
                           hz_customer_profiles cp,
                           hz_parties party
                    WHERE  cust_acct.cust_account_id = cp.cust_account_id (+)
                      and  cust_acct.party_id = party.party_id(+)
                      and  cp.site_use_id is null
                      and  party.party_name = p_value;

                ELSIF (p_entity = 'RECEIPT_METHOD_NAME' )

                 THEN

                    SELECT receipt_method_id
                    INTO   l_selected_id
                    FROM   ar_receipt_methods
                    WHERE  name = p_value;
/* PAYMENT UPTAKE  removed the following
     a) getting the bank_account_id from CUST_BANK_ACCOUNT_NUMBER.
     b) getting the bank_account_id from CUST_BANK_ACCOUNT_NAME.
*/

                ELSIF  (p_entity = 'REMIT_BANK_ACCOUNT_NUMBER')
                 THEN
                    SELECT bank_account_id
                    INTO   l_selected_id
                    FROM   ce_bank_accounts
                    WHERE  bank_account_num = p_value;

                ELSIF (p_entity = 'REMIT_BANK_ACCOUNT_NAME')
                  THEN
                    SELECT bank_account_id
                    INTO   l_selected_id
                    FROM   ce_bank_accounts
                    WHERE  bank_account_name = p_value;

                ELSIF (p_entity = 'CURRENCY_NAME')
                   THEN
                    SELECT currency_code
                    INTO   l_selected_id
                    FROM   fnd_currencies_vl
                    WHERE  name = p_value;
                ELSIF (p_entity = 'EXCHANGE_RATE_TYPE_NAME')
                   THEN
                    SELECT conversion_type
                    INTO   l_selected_id
                    FROM   gl_daily_conversion_types
                    WHERE  user_conversion_type = p_value ;

                ELSIF (p_entity = 'REF_PAYMENT' ) THEN
                    --get from ap_checks.
                    select check_id
                    into   l_selected_id
                    from   ap_checks
                    where  check_number = p_value;
                ELSIF (p_entity = 'REF_PAYMENT_BATCH' ) THEN
                    --
                    select isc.checkrun_id
                    into   l_selected_id
                    from   ap_invoice_selection_criteria isc
                    where  isc.checkrun_name = p_value;
                ELSIF (p_entity = 'REF_RECEIPT' ) THEN
                    --
                    select cash_receipt_id
                    into   l_selected_id
                    from   ar_cash_receipts
                    where  receipt_number = p_value;
                ELSIF (p_entity = 'REF_REMITTANCE' ) THEN
                    --
                    select batch_id
                    into   l_selected_id
                    from   ar_batches
                    where  name = p_value
                     and   type = 'REMITTANCE' ;
                ELSIF (p_entity = 'RECEIVABLES_ACTIVITY' ) THEN
                    --
                    select receivables_trx_id
                    into   l_selected_id
                    from   ar_receivables_trx
                    where  name = p_value;
                ELSIF (p_entity = 'TAX_CODE' ) THEN
                    --
                    -- ETAX replaced reference of obsoleted ar vat tax

                    if (p_date is NULL) THEN
                        l_date := SYSDATE;
                    end if;

                    SELECT tax_rate_id
                      INTO l_selected_id
                      from zx_sco_rates
                      WHERE tax_rate_code = p_value
		      AND nvl(active_flag, 'Y') = 'Y'	/* 4400063 */
                      AND  l_date between
                         nvl(effective_from, l_date)
                     and nvl(effective_to, l_date);

                ELSIF (p_entity = 'LEGAL_ENTITY' ) THEN
                    --
                    SELECT ba.account_owner_org_id
		    INTO   l_selected_id
		    FROM   ce_bank_accounts ba, ce_bank_acct_uses bau
                    WHERE  ba.bank_account_id = bau.bank_account_id
		    AND    bau.bank_acct_use_id = p_value;
                END IF;


                Add_Value_To_Cache(
                                    p_entity,
                                    p_value,
                                    l_selected_id,
                                    NVL( l_index, 0 ) + 1
                                  );

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Get_Id: ' || 'Value selected. Entity: '||
                                                    p_entity || ',' ||
                                     '  Value: ' || p_value  || ',' ||
                                     'ID: ' || l_selected_id);
                   arp_util.debug('Get_Id()- ');
                END IF;

                RETURN( l_selected_id );


           END IF;  -- end value not found in cache case

      END IF;  -- end p_value is not null case


      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Get_Id()- ');
      END IF;


EXCEPTION

   WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Get_Id: ' || 'Value not found. Entity: ' ||
                                   p_entity ||'  Value: ' || p_value);
        END IF;
        return(null);
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Get_Id()- ');
        END IF;

   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Get_Id: ' || 'Value not found. Entity: ' ||
                                   p_entity ||'  Value: ' || p_value);
        END IF;
        RAISE;

END Get_Id;


/* modified for tca uptake */
PROCEDURE Add_Site_Use_To_Cache(
                     p_customer_id   IN hz_cust_acct_sites.cust_account_id%TYPE,
                     p_location      IN hz_cust_site_uses.location%TYPE,
                     p_site_use_code IN hz_cust_site_uses.site_use_code%TYPE,
                     p_id            IN hz_cust_site_uses.site_use_id%TYPE,
                     p_index         IN BINARY_INTEGER
                     ) IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Add_Site_Use_To_Cache()+ ');
   END IF;
   IF   ( p_index <= G_SITE_USE_CACHE_SIZE )
   THEN
                  G_Site_Use_Cache_Tbl(p_index).customer_id :=
                                                        p_customer_id;
                  G_Site_Use_Cache_Tbl(p_index).location    :=
                                                        p_location;
                  G_Site_Use_Cache_Tbl(p_index).site_use_code :=
                                                        p_site_use_code;
                  G_Site_Use_Cache_Tbl(p_index).id       := p_id;
   END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Add_Site_Use_To_Cache()- ');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Add_Site_Use_To_Cache');
        END IF;
        RAISE;
END Add_Site_Use_To_Cache;

/* modified for tca uptake */
FUNCTION Find_Site_Use_In_Cache(
                     p_customer_id   IN hz_cust_accounts.cust_account_id%TYPE,
                     p_location      IN hz_cust_site_uses.site_use_id%TYPE,
                     p_site_use_code IN hz_cust_site_uses.site_use_code%TYPE,
                     p_index         OUT NOCOPY BINARY_INTEGER
                   ) RETURN hz_cust_site_uses.site_use_id%TYPE IS

   l_index  BINARY_INTEGER;
   l_count  BINARY_INTEGER;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Find_Site_Use_In_Cache()+ ');
   END IF;

   l_count := G_Site_Use_Cache_Tbl.count;

   FOR l_index IN 1..l_count LOOP

       p_index := l_index;
     IF p_location IS NOT NULL THEN

       IF  ( G_Site_Use_Cache_Tbl(l_index).customer_id = p_customer_id
          AND G_Site_Use_Cache_Tbl(l_index).location  = p_location
          AND G_Site_Use_Cache_Tbl(l_index).site_use_code = p_site_use_code)
          THEN
           RETURN( G_Site_Use_Cache_Tbl(l_index).id);

       END IF;
     ELSE
       IF ( G_Site_Use_Cache_Tbl(l_index).customer_id = p_customer_id
           AND G_Site_Use_Cache_Tbl(l_index).site_use_code = p_site_use_code
           AND G_Site_Use_Cache_Tbl(l_index).primary_flag = 'Y')
         THEN
           RETURN( G_Site_Use_Cache_Tbl(l_index).id);
       END IF;
     END IF;

   END LOOP;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Find_Site_Use_In_Cache()- ');
   END IF;

   RETURN(NULL);

EXCEPTION

   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Find_Site_Use_In_Cache');
        END IF;

        RAISE;

END Find_Site_Use_In_Cache;

/* modified for tca uptake */
FUNCTION Get_Site_Use_Id(
                 p_customer_id IN hz_cust_acct_sites.cust_account_id%TYPE,
                 p_location  IN hz_cust_site_uses.location%TYPE,
                 p_site_use_code1 IN hz_cust_site_uses.site_use_code%TYPE DEFAULT NULL,
                 p_site_use_code2 IN hz_cust_site_uses.site_use_code%TYPE DEFAULT  NULL)
     RETURN hz_cust_site_uses.site_use_id%type IS
l_cached_id    hz_cust_site_uses.site_use_id%type;
l_selected_id  hz_cust_site_uses.site_use_id%type;
l_index        BINARY_INTEGER;
BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Get_Site_Use_Id()+ ');
      END IF;

 /*     IF  (  p_customer_id  IS NULL ) THEN
           RETURN(NULL);
      ELSE
           l_cached_id := Find_Site_Use_In_Cache(
                                            p_customer_id,
                                            p_location,
                                            p_site_use_code,
                                            l_index
                                              );
           IF ( l_cached_id  IS NOT NULL ) THEN
              RETURN( l_cached_id );
           ELSE
   */
          IF p_customer_id IS NOT NULL THEN
            IF (p_location IS NOT NULL) THEN
              BEGIN
               /* modified for tca uptake */
               SELECT site_use.site_use_id
               INTO   l_selected_id
               FROM   hz_cust_site_uses site_use,
                      hz_cust_acct_sites acct_site
               WHERE  acct_site.cust_account_id   =  p_customer_id
                 AND  acct_site.status        = 'A'
                 AND  site_use.cust_acct_site_id = acct_site.cust_acct_site_id
                 AND  (site_use.site_use_code = nvl(p_site_use_code1,
                                                    site_use.site_use_code) OR
                       site_use.site_use_code = nvl(p_site_use_code1,
                                                    site_use.site_use_code))
                 AND  site_use.status        = 'A'
                 AND  site_use.location = p_location;
              EXCEPTION
               WHEN no_data_found THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('Get_Site_Use_Id: ' || 'No data found in the hz_cust_site_uses for the location :'||p_location);
                  END IF;
                  --the error message will be raised in the validation routine.
                  null;
              END;

            ELSE
             --the case when no location  is specified for the customer.
             --here we are defaulting the primary bill_to loaction.
              BEGIN
               /* modified for tca uptake */
               SELECT site_use.site_use_id
               INTO   l_selected_id
               FROM   hz_cust_site_uses site_use,
                      hz_cust_acct_sites acct_site
               WHERE  acct_site.cust_account_id   =  p_customer_id
                 AND  acct_site.status        = 'A'
                 AND  site_use.cust_acct_site_id  = acct_site.cust_acct_site_id
                 AND  (site_use.site_use_code = nvl(p_site_use_code1,
                                                    site_use.site_use_code) OR
                       site_use.site_use_code = nvl(p_site_use_code1,
                                                    site_use.site_use_code))
                 AND  site_use.status        = 'A'
                 AND  site_use.primary_flag  = 'Y';

              EXCEPTION
               WHEN no_data_found THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Get_Site_Use_Id: ' || 'No_data_found : Site use id could not be defaulted for customer_id '||to_char(p_customer_id));
                END IF;
                --This is the case where customer site use id is null
                --neither it was supplied by the user nor it could be defaulted
                --a WARNING message raised in the validation routine to indicate
                --that the customer site use id could not be defaulted.
                null;
              END;

           END IF;
        END IF;
/*           Add_Site_Use_To_Cache(
                                 p_customer_id,
                                 p_location,
                                 p_site_use_code,
                                 l_selected_id,
                                 NVL( l_index, 0 ) + 1
                                   );
                RETURN( l_selected_id );

      END IF;
 END IF;
 */
 RETURN( l_selected_id );
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Get_Site_Use_Id.');
  END IF;
  raise;

END Get_Site_Use_Id;

FUNCTION Get_Cross_Validated_Id( p_entity        IN VARCHAR2,
                                 p_number_value  IN VARCHAR2,
                                 p_name_value    IN VARCHAR2,
                                 p_return_status OUT NOCOPY VARCHAR2
                                ) RETURN VARCHAR2 IS
l_id_from_name  VARCHAR2(100);
l_id_from_num   VARCHAR2(100);
BEGIN

   IF (p_number_value IS NULL) OR
      (p_name_value IS NULL)
    THEN
    RETURN(NULL);
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   l_id_from_name := Get_Id(p_entity||'_NAME',
                            p_name_value,
                            p_return_status
                           );

   l_id_from_num  := Get_Id(p_entity||'_NUMBER',
                            p_number_value,
                            p_return_status
                           );

   IF l_id_from_name = l_id_from_num THEN
     RETURN(l_id_from_name);
   ELSE
     --p_return_status := FND_API.G_RET_STS_ERROR;
     --FND_MESSAGE.SET_NAME('AR', 'INVALID_VALUE_ERR');
     --FND_MESSAGE.SET_TOKEN('PARAMETER','Customer Number/Name');
     --FND_MSG_PUB.Add;
     RETURN(NULL);
   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Get_Cross_Validated_Id() '||p_entity);
  END IF;
  raise;
END Get_Cross_Validated_Id;

PROCEDURE Add_Method_Info_To_Cache( p_method_info_record  IN OUT NOCOPY  Method_Info_Cache_Rec_Type,
                                    p_index BINARY_INTEGER ) IS

l_index BINARY_INTEGER;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Add_Method_Info_To_Cache()+ ');
   END IF;
   IF p_index  IS NULL THEN
       l_index := nvl(Method_Info_Cache_Tbl.LAST,0) + 1;
   END IF;

   IF   ( l_index <= G_METHOD_INFO_CACHE_SIZE ) THEN

       Method_Info_Cache_Tbl(l_index) := p_method_info_record;

       IF PG_DEBUG in ('Y', 'C') THEN
	  arp_util.debug('Added the record at index '|| l_index);
       END IF;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Add_Method_Info_To_Cache()- ');
   END IF;

EXCEPTION

   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Add_Method_Info_To_Cache');
        END IF;
        RAISE;
END Add_Method_Info_To_Cache;


PROCEDURE Get_Method_Info_From_Cache(
                      p_method_info_record         IN OUT NOCOPY Method_Info_Cache_Rec_Type,
                      p_receipt_date               IN ar_cash_receipts.receipt_date%TYPE ) IS
l_count  BINARY_INTEGER;
l_index_curr  BINARY_INTEGER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Get_Method_Info_From_Cache ()+ ');
    END IF;

         l_count := Method_Info_Cache_Tbl.count;

    IF l_count IS NOT NULL THEN
	--If The Record Exists In Cache,Then Set The Values To Out Params And
	-- Return From The Procedure
	For L_index In 1..L_count Loop

	   If  ( Method_info_cache_tbl(L_index).Receipt_method_id = P_method_info_record.Receipt_method_id And
		 Method_info_cache_tbl(L_index).Currency_code = Nvl(P_method_info_record.Currency_code,'0') And
		 Method_info_cache_tbl(L_index).Called_from = P_method_info_record.Called_from  And
		 Nvl(Method_info_cache_tbl(L_index).Bau_end_date,P_receipt_date +1) > P_receipt_date And
		 ( P_receipt_date Between Method_info_cache_tbl(L_index).Rm_start_date And
		   Nvl( Method_info_cache_tbl(L_index).Rm_end_date, P_receipt_date)) And
		 ( P_receipt_date Between  Method_info_cache_tbl(L_index).Rma_start_date And
		   Nvl(Method_info_cache_tbl(L_index).Rma_end_date, P_receipt_date ) ) )  Then
	       P_method_info_record := Method_info_cache_tbl(L_index);

	       If Pg_debug In ('y', 'c') Then
		  Arp_util.Debug('found The Record In Cache ');
	       End If;
	       Exit;
	   End If;
	End Loop;
    END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Get_Method_Info_From_Cache ()- ');
     END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Get_Method_Info_From_Cache() ');
  END IF;
  raise;
END Get_Method_Info_From_Cache;


PROCEDURE Add_Exchange_Rate_To_Cache(
                     p_currency_code      IN ar_cash_receipts.currency_code%TYPE,
                     p_exchange_rate_date IN ar_cash_receipts.exchange_date%TYPE,
                     p_exchange_rate_type IN ar_cash_receipts.exchange_rate_type%TYPE,
                     p_exchange_rate      IN ar_cash_receipts.exchange_rate%TYPE,
                     p_index              IN BINARY_INTEGER
                     ) IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Add_Exchange_Rate_To_Cache()+ ');
   END IF;


   IF   ( p_index <= G_EXCHANGE_RATE_CACHE_SIZE )
   THEN
                  Exchange_Rate_Cache_Tbl(p_index).exchange_rate :=
                                                        p_exchange_rate;
                  Exchange_Rate_Cache_Tbl(p_index).currency    :=
                                                        p_currency_code;
                  Exchange_Rate_Cache_Tbl(p_index).exchange_rate_type :=
                                                        p_exchange_rate_type;
                  Exchange_Rate_Cache_Tbl(p_index).exchange_date :=
                                                        p_exchange_rate_date;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Add_Exchange_Rate_To_Cache()- ');
   END IF;

EXCEPTION

   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Add_Exchange_Rate_To_Cache');
        END IF;

        RAISE;

END Add_Exchange_Rate_To_Cache;

PROCEDURE Default_gl_date(p_entered_date IN  DATE,
                          p_gl_date      OUT NOCOPY DATE,
                          p_validation_date IN DATE, /* Bug fix 3547720 */
                          p_return_status OUT NOCOPY VARCHAR2) IS
l_error_message        VARCHAR2(128);
l_defaulting_rule_used VARCHAR2(100);
l_default_gl_date      DATE;
BEGIN
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_gl_date ()+');
  END IF;
    IF p_gl_date IS NULL THEN
     IF (arp_util.validate_and_default_gl_date(
                p_entered_date,
                NULL,
                p_validation_date, /* Bug fix 3547720 */
                NULL,
                NULL,
                p_entered_date,
                NULL,
                NULL,
                'N',
                NULL,
                arp_global.set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE)
     THEN
        p_gl_date := l_default_gl_date;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_gl_date: ' || 'Defaulted GL Date : '||to_char(p_gl_date,'DD-MON-YYYY'));
      END IF;
     ELSE
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_gl_date: ' || 'GL Date could not be defaulted ');
      END IF;
      -- Raise error message if failure in defaulting the gl_date
      FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_gl_date ()-');
  END IF;
END default_gl_date;


FUNCTION Find_Cached_Exchange_Rate(
                       p_currency_code  IN ar_cash_receipts.currency_code%TYPE,
                       p_exchange_rate_date IN ar_cash_receipts.exchange_date%TYPE,
                       p_exchange_rate_type IN ar_cash_receipts.exchange_rate_type%TYPE
                      ) RETURN NUMBER IS
l_count  BINARY_INTEGER;
l_index_curr  BINARY_INTEGER;
l_exchange_rate        NUMBER;
l_set_of_books_id      NUMBER := arp_global.set_of_books_id;
l_functional_currency  VARCHAR2(100) := arp_global.functional_currency;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Find_Cached_Exchange_Rate ()+');
 END IF;
   IF (p_currency_code IS NOT NULL) AND
      (p_currency_code <> l_functional_currency) AND
      (p_exchange_rate_date IS NOT NULL) AND
      (p_exchange_rate_type IS NOT NULL) AND
      (p_exchange_rate_type <>'User')
    THEN
--  This section of code is commented out NOCOPY as the implementation of the
--  of the caching mechanism has been deferred as of now
/*
      l_count := Exchange_Rate_Cache_Tbl.count;

      FOR l_index IN 1..l_count LOOP

       l_index_curr := l_index;

     IF (Exchange_Rate_Cache_Tbl(l_index).currency = p_currency_code AND
         Exchange_Rate_Cache_Tbl(l_index).exchange_rate_type = p_exchange_rate_type AND
         Exchange_Rate_Cache_Tbl(l_index).exchange_date = p_exchange_rate_date)
      THEN
         RETURN(Exchange_Rate_Cache_Tbl(l_index).exchange_rate);
     END IF;

     END LOOP;

     --the rate is not in the cache so get it from the database.
*/
     l_exchange_rate := gl_currency_api.get_rate(
                                           l_set_of_books_id,
                                           p_currency_code,
                                           p_exchange_rate_date,
                                           p_exchange_rate_type
                                           );
/*
          Add_Exchange_Rate_To_Cache(
                                    p_currency_code,
                                     p_exchange_rate_date,
                                     p_exchange_rate_type,
                                     l_exchange_rate,
                                     NVL( l_index_curr, 0 ) + 1
                                     );
*/
  END IF;
  RETURN( l_exchange_rate );
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Find_Cached_Exchange_Rate ()-');
 END IF;
EXCEPTION
 WHEN gl_currency_api.NO_RATE THEN
  --rate does not exist set appropriate message.
  --p_return_status := FND_API.G_RET_STS_ERROR ;
  return(null);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Find_Cached_Exchange_Rate: ' || 'Exception : gl_currency_api.NO_RATE ');
  END IF;
 WHEN gl_currency_api.INVALID_CURRENCY  THEN
  -- invalid currency set appropriate message.
  --p_return_status := FND_API.G_RET_STS_ERROR ;
  return(null);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Find_Cached_Exchange_Rate: ' || 'Exception: gl_currency_api.INVALID_CURRENCY ');
  END IF;
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Find_Cached_Exchange_Rate() ');
  END IF;
  raise;
END Find_Cached_Exchange_Rate;

PROCEDURE Default_Receipt_Method_Info(
           p_receipt_method_id          IN ar_cash_receipts.receipt_method_id%TYPE,
           p_currency_code              IN ar_cash_receipts.currency_code%TYPE,
           p_receipt_date               IN ar_cash_receipts.receipt_date%TYPE,
           p_remittance_bank_account_id IN OUT NOCOPY ar_receipt_method_accounts_all.remit_bank_acct_use_id%TYPE,
           p_state                      OUT NOCOPY ar_receipt_classes.creation_status%TYPE,
           p_creation_method_code       OUT NOCOPY ar_receipt_classes.creation_method_code%TYPE,
           p_called_from                IN VARCHAR2,
           p_return_status              OUT NOCOPY VARCHAR2
           ) IS
/*Bug 3518573 changing the logic to pick default remittance bank account */
  CURSOR get_remit_bank_acct_id(
    p_currency_code ar_cash_receipts.currency_code%TYPE,
    p_receipt_date ar_cash_receipts.receipt_date%TYPE,
    p_called_from VARCHAR2,
    p_receipt_method_id ar_cash_receipts.receipt_method_id%TYPE)  is
  SELECT   ba.bank_acct_use_id,
           rc.creation_status,
           rc.creation_method_code,
	   rma.start_date rma_start_date,
	   rma.end_date  rma_end_date,
	   rm.start_date rm_start_date,
	   rm.end_date rm_end_date,
	   ba.end_Date bau_end_date
    FROM   ar_receipt_methods rm,
           ce_bank_accounts   cba,
           ce_bank_acct_uses  ba,
           ar_receipt_method_accounts rma ,
           ar_receipt_classes rc
    WHERE  rm.receipt_method_id = p_receipt_method_id
      and  (p_receipt_date
                between
                rm.start_date and
                nvl(rm.end_date, p_receipt_date))
      and  ((rc.creation_method_code = DECODE(p_called_from,'BR_REMITTED','BR_REMIT',
                                              'BR_FACTORED_WITH_RECOURSE','BR_REMIT',
                                              'BR_FACTORED_WITHOUT_RECOURSE','BR_REMIT','@*%?&')) or
            (rc.creation_method_code = 'MANUAL') or
            (rc.creation_method_code = 'AUTOMATIC'
             --and rc.remit_flag = 'Y'
             -- OSTEINME 2/27/2001: removed remit_flag
             -- condition for iReceivables CC functionality.
             -- See bug 1659109.
             -- bichatte autorecapi.
            and   rc.confirm_flag = decode(p_called_from, 'AUTORECAPI',rc.confirm_flag,'N')))
      and  cba.account_classification = 'INTERNAL'
      and  nvl(ba.end_date, p_receipt_date +1) > p_receipt_date
      and  p_receipt_date
                 between
                 rma.start_date and
                 nvl(rma.end_date, p_receipt_date)
      and  cba.currency_code = decode(cba.receipt_multi_currency_flag, 'Y',
                                      cba.currency_code, p_currency_code)
      and  rc.receipt_class_id = rm.receipt_class_id
      and  rm.receipt_method_id = rma.receipt_method_id
      and  rma.remit_bank_acct_use_id = ba.bank_acct_use_id
      and  ba.bank_account_id = cba.bank_account_id
     --APANDIT: changes made for the misc receipt creation api.
      and  ((nvl(p_called_from,'*&#$') <> 'MISC')
               or
                 (rm.receipt_class_id not in (
                 select arc.receipt_class_id
                 from ar_receipt_classes arc
                 where arc.notes_receivable='Y'
                    or arc.bill_of_exchange_flag='Y')))
      order by
      decode(rma.primary_flag,'Y',1,'N',2,3),
      decode(cba.currency_code,p_currency_code,1,2),
      cba.bank_branch_id,
      cba.bank_account_name,
      ba.bank_acct_use_id;

      l_method_info_record Method_Info_Cache_Rec_Type;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_Receipt_Method_Info ()+');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_receipt_method_id IS NOT NULL THEN

	IF p_remittance_bank_account_id IS NULL  THEN

	    l_method_info_record.receipt_method_id  := p_receipt_method_id;
	    l_method_info_record.currency_code      := p_currency_code;
	    l_method_info_record.called_from        := nvl(p_called_from,'@*%?&');

	    --check if it exists in cache
	    Get_Method_Info_From_Cache( l_method_info_record,
					p_receipt_date );

	    IF  l_method_info_record.remit_bank_acct_use_id IS NULL THEN
		OPEN get_remit_bank_acct_id(p_currency_code,p_receipt_date,p_called_from,p_receipt_method_id);

		FETCH get_remit_bank_acct_id INTO
		    l_method_info_record.remit_bank_acct_use_id,
		    l_method_info_record.state,
		    l_method_info_record.creation_method_code,
		    l_method_info_record.rma_start_date,
		    l_method_info_record.rma_end_date,
		    l_method_info_record.rm_start_date,
		    l_method_info_record.rm_end_date,
		    l_method_info_record.bau_end_date;

		IF get_remit_bank_acct_id%NOTFOUND then
		    null;
		END IF;
		CLOSE get_remit_bank_acct_id;

		--add it to cache
	        Add_Method_Info_To_Cache( l_method_info_record,null);
            END IF;

	    p_remittance_bank_account_id := l_method_info_record.remit_bank_acct_use_id;
	    p_state                      := l_method_info_record.state;
	    p_creation_method_code       := l_method_info_record.creation_method_code;
	ELSE
	    --user has specified the remittance bank account id
	    --so get the creation_status only.

	    SELECT rc.creation_status,
		   rc.creation_method_code
	    INTO   p_state,
		p_creation_method_code
	    FROM   ar_receipt_classes rc,
		   ar_receipt_methods rm
	    WHERE  rc.receipt_class_id = rm.receipt_class_id
	    AND  rm.receipt_method_id = p_receipt_method_id;

	    --the invalid error message will be raised in the
	    --validation phase. We will check in the validation
	    --phase that if p_state is null and method_id is not
	    --null then method_id is invalid
	END IF;
    END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_Receipt_Method_Info ()-');
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  --In the validation phase we will raise the relevant error
  --if either the p_state or remittance_bank_id is null
  null;
 WHEN too_many_rows  THEN
  --This will happen only if the receipt method was specified
  --and we tried to default the remittance bank and the state
  p_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_ID_NULL');
  FND_MSG_PUB.Add;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_Receipt_Method_Info: ' || 'The remittance bank account could not be defaulted ');
  END IF;
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_Receipt_Method_info() ');
     arp_util.debug('Default_Receipt_Method_Info: ' || 'p_receipt_method_id  =  '
                      ||TO_CHAR(p_receipt_method_id));
  END IF;
  raise;

END Default_Receipt_Method_Info;

/* Bug3315058 */
PROCEDURE validate_cc_segments(
           p_code_combination_id        IN NUMBER,
           p_gl_date                    IN DATE,
           p_message                    IN VARCHAR2,
           p_return_status              OUT NOCOPY VARCHAR2
           ) IS
 l_concat_segs varchar2(2000);
 l_value boolean := FALSE;
 l_chart_of_accounts_id gl_sets_of_books.chart_of_accounts_id%type;
 l_validation_date date ;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('validate_cc_segments ()+');
    END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    l_validation_date := p_gl_date;
    l_chart_of_accounts_id := arp_global.chart_of_accounts_id;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('l_chart_of_accounts_id = '||to_char(l_chart_of_accounts_id));
    END IF;
    l_concat_segs := fnd_flex_ext.get_segs('SQLGL','GL#',
                                           l_chart_of_accounts_id,
                                           p_code_combination_id);
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('l_concat_segs = '||l_concat_segs);
    END IF;
    l_value := FND_FLEX_KEYVAL.validate_segs('CHECK_SEGMENTS','SQLGL','GL#',
                                              l_chart_of_accounts_id,
                                              l_concat_segs,
                                                  'V',l_validation_date);
    IF l_value THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Returning true');
       END IF;
    ELSE
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Returning False');
       END IF;
    END IF;
    IF (NOT l_value)  THEN
       FND_MESSAGE.SET_NAME('AR',p_message);
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
END validate_cc_segments;

/* Bug fix 3315058
   Procedure which checks the validity of the different accounts of a payment method */
PROCEDURE Validate_Receipt_Method_ccid(
               p_receipt_method_id            IN  ar_cash_receipts.receipt_method_id%TYPE ,
               p_remittance_bank_account_id   IN  ar_receipt_method_accounts_all.remit_bank_acct_use_id%TYPE,
               p_gl_date                      IN  DATE,
               p_return_status                OUT NOCOPY VARCHAR2
               )IS
   l_receipt_method_id ar_receipt_methods.receipt_method_id%type;
   l_remit_bank_account_id ar_receipt_method_accounts.remit_bank_acct_use_id%type;
   l_cash_ccid gl_code_combinations.code_combination_id%type;
   l_earned_ccid gl_code_combinations.code_combination_id%type;
   l_on_account_ccid gl_code_combinations.code_combination_id%type;
   l_unapplied_ccid gl_code_combinations.code_combination_id%type;
   l_unearned_ccid gl_code_combinations.code_combination_id%type;
   l_unidentified_ccid gl_code_combinations.code_combination_id%type;
   l_bank_charges_ccid gl_code_combinations.code_combination_id%type;
   l_factor_ccid gl_code_combinations.code_combination_id%type;
   l_remittance_ccid gl_code_combinations.code_combination_id%type;
   l_receipt_clearing_ccid gl_code_combinations.code_combination_id%type;
   l_short_term_debt_ccid gl_code_combinations.code_combination_id%type;
   l_message varchar2(100);
   l_gl_date DATE;
   l_cc_val_ret_status VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Validate_Receipt_Method_ccid ()+');
  END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;
     l_gl_date := p_gl_date;
     IF p_receipt_method_id IS NOT NULL
        AND p_remittance_bank_account_id IS NOT NULL THEN
        SELECT rma.cash_ccid,art1.code_combination_id,rma.on_account_ccid,
            rma.unapplied_ccid,art2.code_combination_id,rma.unidentified_ccid,
            rma.bank_charges_ccid,rma.factor_ccid,rma.remittance_ccid,
            rma.receipt_clearing_ccid, rma.short_term_debt_ccid
      	INTO  l_cash_ccid,l_earned_ccid,l_on_account_ccid,
            l_unapplied_ccid,l_unearned_ccid,l_unidentified_ccid,
            l_bank_charges_ccid,l_factor_ccid,l_remittance_ccid,
            l_receipt_clearing_ccid,l_short_term_debt_ccid
      	FROM  ar_receipt_method_accounts rma,
            ar_receivables_trx art1, ar_receivables_trx art2
        WHERE remit_bank_acct_use_id = p_remittance_bank_account_id
       AND  receipt_method_id = p_receipt_method_id
       AND  art1.receivables_trx_id = rma.edisc_receivables_trx_id
       AND  art2.receivables_trx_id = rma.unedisc_receivables_trx_id;
     END IF;

           IF l_cash_ccid IS NOT NULL THEN
              l_message := 'AR_CASH_ACC_ASSGN';
              validate_cc_segments(l_cash_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  RETURN;
              END IF;
           END IF;

           IF l_earned_ccid IS NOT NULL THEN
              l_message := 'AR_EARN_DISC_ACC_ASSGN';
              validate_cc_segments(l_earned_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              END IF;
           END IF;

           IF l_on_account_ccid IS NOT NULL THEN
              l_message := 'AR_ONACC_ACC_ASSGN';
              validate_cc_segments(l_on_account_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
              END IF;
           END IF;
           IF l_unapplied_ccid IS NOT NULL THEN
              l_message := 'AR_UNAPP_ACC_ASSGN';
              validate_cc_segments(l_unapplied_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              END IF;
           END IF;

           IF l_unearned_ccid IS NOT NULL THEN
              l_message := 'AR_UNEARN_DISC_ACC_ASSGN';
              validate_cc_segments(l_unearned_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              END IF;
           END IF;
           IF l_unidentified_ccid IS NOT NULL THEN
              l_message := 'AR_UNIDEN_ACC_ASSGN';
              validate_cc_segments(l_unidentified_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              END IF;
           END IF;
   	IF l_bank_charges_ccid IS NOT NULL THEN
              l_message := 'AR_BANK_CHRG_ACC_ASSGN';
              validate_cc_segments(l_bank_charges_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              END IF;
           END IF;

           IF l_factor_ccid IS NOT NULL THEN
              l_message := 'AR_FCTR_ACC_ASSGN';
              validate_cc_segments(l_factor_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              END IF;
           END IF;

           IF l_remittance_ccid IS NOT NULL THEN
              l_message := 'AR_REM_ACC_ASSGN';
              validate_cc_segments(l_remittance_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              END IF;
           END IF;
           IF l_receipt_clearing_ccid IS NOT NULL THEN
              l_message := 'AR_CLRNCE_ACC_ASSGN';
              validate_cc_segments(l_receipt_clearing_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              END IF;
  	   END IF;

           IF l_short_term_debt_ccid IS NOT NULL THEN
              l_message := 'AR_SHRT_TERM_DEBT_ACC_ASSGN';
              validate_cc_segments(l_short_term_debt_ccid,l_gl_date,
                 l_message,l_cc_val_ret_status);
              IF l_cc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 RETURN;
              END IF;
        END IF;
END Validate_Receipt_Method_ccid;
 /* End bug fix 3315058 */

FUNCTION Get_cross_rate (p_from_currency IN VARCHAR2,
                         p_to_currency  IN VARCHAR2,
                         p_exchange_rate_date IN DATE,
                         p_exchange_rate    IN NUMBER
                         ) RETURN NUMBER IS
l_euro_to_emu_rate  NUMBER;
l_fixed_rate  BOOLEAN;
l_relationship  VARCHAR2(50);
euro_code VARCHAR2(15);
l_cross_rate  NUMBER;
BEGIN

     gl_currency_api.get_relation(
                       p_from_currency,
                       p_to_currency,
                       trunc(p_exchange_rate_date),
                       l_fixed_rate,
                       l_relationship);
      euro_code := gl_currency_api.get_euro_code;

      IF (l_relationship = 'EMU-OTHER') THEN
                   l_euro_to_emu_rate :=
                                gl_currency_api.get_rate(
                                                   euro_code,
                                                   p_from_currency,
                                                   trunc(p_exchange_rate_date),
                                                   NULL);
      ELSIF (l_relationship = 'OTHER-EMU') THEN
                   l_euro_to_emu_rate :=
                                gl_currency_api.get_rate(
                                                   euro_code,
                                                   p_to_currency,
                                                   trunc(p_exchange_rate_date),
                                                   NULL);
      ELSE
          RAISE gl_euro_user_rate_api.INVALID_RELATION;
      END IF;
              l_cross_rate :=
                    gl_euro_user_rate_api.get_cross_rate(p_from_currency,
                                                p_to_currency,
                                                p_exchange_rate_date,
                                                p_exchange_rate,
                                                l_euro_to_emu_rate);
              return(l_cross_rate);
EXCEPTION
  WHEN gl_euro_user_rate_api.INVALID_RELATION  THEN
    null;
  WHEN gl_euro_user_rate_api.INVALID_CURRENCY  THEN
    null;
  WHEN others THEN
    raise;
END Get_cross_rate;

PROCEDURE Default_Currency_info(
                   p_currency_code  IN OUT NOCOPY ar_cash_receipts.currency_code%TYPE,
                   p_receipt_date   IN OUT NOCOPY ar_cash_receipts.receipt_date%TYPE,
                   p_exchange_rate_date  IN OUT NOCOPY ar_cash_receipts.exchange_date%TYPE,
                   p_exchange_rate_type  IN OUT NOCOPY ar_cash_receipts.exchange_rate_type%TYPE,
                   p_exchange_rate  IN OUT NOCOPY ar_cash_receipts.exchange_rate%TYPE,
                   p_return_status  OUT NOCOPY VARCHAR2
                   ) IS

l_euro_to_emu_rate      NUMBER;
l_euro_to_other_prompt  VARCHAR2(30);
l_euro_to_emu_prompt    VARCHAR2(30);
l_emu_to_other_prompt   VARCHAR2(30);
l_cross_rate            NUMBER;
l_conversion_rate       NUMBER;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_Currency_info ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_currency_code <> arp_global.functional_currency THEN

    --default exchange rate date if null
    IF (p_exchange_rate_date IS NULL) THEN
      p_exchange_rate_date := p_receipt_date;
    END IF;

    --default exchange rate type if null
    IF p_exchange_rate_type IS NULL THEN
       p_exchange_rate_type := pg_profile_def_x_rate_type;
    END IF;

  IF p_exchange_rate_type IS NOT NULL THEN

    IF p_exchange_rate_type <> 'User' THEN
        --for any exchange_rate type other than 'User',
        --default exchange rate if not entered.
         IF p_exchange_rate IS NULL THEN
            p_exchange_rate := Find_Cached_Exchange_Rate(
                                               p_currency_code,
                                               p_exchange_rate_date,
                                               p_exchange_rate_type
                                                );
         ELSE
           --if user has entered exchange rate for type <> User, raise error message
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_X_RATE_INVALID');
            FND_MSG_PUB.Add;
         END IF;
    ELSE
     --case where rate_type is 'User'

      --if the user entered exchange rate is greater than 0 then
      --check for the case of EMU currency
   IF p_exchange_rate >0 THEN

     --This is the case rate_type is User and exchange_rate exists

     -- Returns 'Y' if the current conversion type is User AND
     -- they are converting from EMU -> OTHER or OTHER -> EMU AND
     -- they are not allowed to enter EMU -> OTHER and
     -- OTHER -> EMU rates directly
     -- Returns 'N' Otherwise

     IF (gl_euro_user_rate_api.is_cross_rate(p_currency_code,
                                       arp_global.functional_currency,
                                       p_exchange_rate_date,
                                       p_exchange_rate_type) = 'Y')
       THEN

              gl_euro_user_rate_api.get_prompts_and_rate(
                                               p_currency_code,
                                               arp_global.functional_currency,
                                               p_exchange_rate_date,
                                               l_euro_to_other_prompt,
                                               l_euro_to_emu_prompt,
                                               l_emu_to_other_prompt,
                                               l_euro_to_emu_rate);

              l_cross_rate :=
               gl_euro_user_rate_api.get_cross_rate(
                                                  p_currency_code,
                                                  p_currency_code,
                                                  p_exchange_rate_date,
                                                  p_exchange_rate,
                                                  l_euro_to_emu_rate);

        p_exchange_rate :=  l_cross_rate;
     ELSE
      -- case where gl_euro_user_rate_api.is_cross_rate = 'N'
      -- here the exchange_rate is directly between the EMU and the non-EMU currency.

        p_exchange_rate := round(p_exchange_rate,38);

     END IF; --is_cross_rate

   END IF; -- exchange_rate >0

  END IF; --rate type <> 'User'
  END IF; --if echange rate type IS NOT NULL
 END IF;  --entered_currency <> functional currency

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_Currency_info ()+');
   END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_Currency_Info() ');
     arp_util.debug('Default_Currency_info: ' || 'p_currency_code  =  '||p_currency_code);
  END IF;
  raise;
END Default_Currency_Info;

/* modified for tca uptake */
PROCEDURE Default_cash_ids(
              p_usr_currency_code            IN     fnd_currencies_vl.name%TYPE,
              p_usr_exchange_rate_type       IN     gl_daily_conversion_types.user_conversion_type%TYPE,
              p_customer_name                IN     hz_parties.party_name%TYPE,
              p_customer_number              IN     hz_cust_accounts.account_number%TYPE,
              p_location                     IN     hz_cust_site_uses.location%type,
              p_receipt_method_name          IN OUT NOCOPY ar_receipt_methods.name%TYPE,
              /* 6612301 */
              p_customer_bank_account_name   IN     iby_ext_bank_accounts_v.bank_account_name%TYPE,
              p_customer_bank_account_num    IN     iby_ext_bank_accounts_v.bank_account_number%TYPE,
              p_remittance_bank_account_name IN     ce_bank_accounts.bank_account_name%TYPE,
              p_remittance_bank_account_num  IN     ce_bank_accounts.bank_account_num%TYPE,
              p_currency_code                IN OUT NOCOPY ar_cash_receipts.currency_code%TYPE,
              p_exchange_rate_type           IN OUT NOCOPY ar_cash_receipts.exchange_rate_type%TYPE,
              p_customer_id                  IN OUT NOCOPY ar_cash_receipts.pay_from_customer%TYPE,
              p_customer_site_use_id         IN OUT NOCOPY hz_cust_site_uses.site_use_id%TYPE,
              p_receipt_method_id            IN OUT NOCOPY ar_cash_receipts.receipt_method_id%TYPE,
              /* 6612301 */
              p_customer_bank_account_id     IN OUT NOCOPY ar_cash_receipts.customer_bank_account_id%TYPE,
	            p_customer_bank_branch_id     IN OUT NOCOPY  ar_cash_receipts.customer_bank_branch_id%TYPE,
              p_remittance_bank_account_id   IN OUT NOCOPY ar_cash_receipts.remit_bank_acct_use_id%TYPE,
              p_receipt_date                 IN     DATE,
              p_return_status                   OUT NOCOPY VARCHAR2,
              p_default_site_use             IN VARCHAR2 --4448307-4509459
                              )
IS
l_remittance_bank_account_id NUMBER;
l_receipt_method_id          NUMBER;
l_customer_id                NUMBER;
l_return_status              VARCHAR2(1);
l_get_id_return_status       VARCHAR2(1);
l_get_x_val_return_status    VARCHAR2(1);
l_boe_flag		     VARCHAR2(1);
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_cash_ids_from_values ()+');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;
-- Customer ID/Number/Name
-- If 0 has been entered in as the customer ID, consider it null
IF (NVL(p_customer_id,0) = 0)
  THEN
   IF(p_customer_name IS NOT NULL) and
     (p_customer_number IS NULL)
    THEN
     p_customer_id := Get_Id('CUSTOMER_NAME',
                              p_customer_name,
                              l_get_id_return_status);
     IF p_customer_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSIF(p_customer_name IS NULL) and
        (p_customer_number IS NOT NULL)
    THEN
     p_customer_id := Get_Id( 'CUSTOMER_NUMBER',
                              p_customer_number,
                              l_get_id_return_status);
     IF p_customer_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NUM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSIF(p_customer_name IS NOT NULL) and
        (p_customer_number IS NOT NULL)
    THEN
     p_customer_id := Get_Cross_Validated_Id( 'CUSTOMER',
                                              p_customer_number,
                                              p_customer_name,
                                              l_get_x_val_return_status);
   IF p_customer_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NAME_NUM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;

ELSE
--In case the ID has been entered by the user
   IF (p_customer_name IS NOT NULL) OR
      (p_customer_number IS NOT NULL) THEN
       --give a warning message to indicate that the customer_number and customer_name
       --entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_NAME_NUM_IGN');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;


END IF;

 --Customer site use id
/*
 IF p_customer_id IS NOT NULL  THEN
  IF p_customer_site_use_id IS NULL THEN

     p_customer_site_use_id := Get_Site_Use_Id(p_customer_id,
                                               p_location,
                                               'BILL_TO',
                                               'DRAWEE'  --added drawee for bug 1420529
                                                );
  ELSE
    IF p_location IS NOT NULL THEN
      --raise warning that
      null;
    END IF;
  END IF;
 END IF;
*/


/*bug4448307-4509459*/
IF p_customer_id IS NOT NULL  THEN
    IF arp_global.sysparam.site_required_flag = 'Y' THEN

      IF p_customer_site_use_id IS NULL THEN

     p_customer_site_use_id := Get_Site_Use_Id(p_customer_id,
                                               p_location,
                                               'BILL_TO',
                                               'DRAWEE'  --added drawee for bug 1420529
                                                );
     END IF;
   ELSE
    IF p_default_site_use = 'Y' THEN
        IF p_customer_site_use_id IS NULL THEN

     p_customer_site_use_id := Get_Site_Use_Id(p_customer_id,
                                               p_location,
                                               'BILL_TO',
                                               'DRAWEE'  --added drawee for bug 1420529
                                                );
     END IF;
   ELSE
     null;
    END IF;
  END IF;
END IF;
/*bug4448307-4509459*/


--Receipt method ID,Name
IF p_receipt_method_id IS NULL
  THEN
   IF p_receipt_method_name IS NOT NULL THEN
      p_receipt_method_id := Get_Id('RECEIPT_METHOD_NAME',
                                     p_receipt_method_name,
                                     l_get_id_return_status
                                    );
     IF p_receipt_method_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_MD_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
        l_boe_flag := arpt_sql_func_util.check_BOE_Paymeth(p_receipt_method_id);
        if l_boe_flag = 'Y' then
           FND_MESSAGE.SET_NAME('AR','AR_BOE_OBSOLETE');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
        end if;
     END IF;
   END IF;
 ELSE
    IF (p_receipt_method_name IS NOT NULL) THEN
       --give a warning message to indicate that the receipt_method_name
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_MD_NAME_IGN');
         FND_MSG_PUB.Add;
       END IF;
    ELSE
        BEGIN
         SELECT name
         INTO   p_receipt_method_name
         FROM   ar_receipt_methods
         WHERE  receipt_method_id = p_receipt_method_id;

         l_boe_flag := arpt_sql_func_util.check_BOE_Paymeth(p_receipt_method_id);
         if l_boe_flag = 'Y' then
            FND_MESSAGE.SET_NAME('AR','AR_BOE_OBSOLETE');
            FND_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;
         end if;

        EXCEPTION
         WHEN no_data_found THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Default_cash_ids: ' || 'Invalid receipt method id');
          END IF;
           null;
        END;

    END IF;

 END IF;

--Currency code
IF p_currency_code IS NULL THEN
   IF p_usr_currency_code IS NOT NULL
    THEN
      p_currency_code :=     Get_Id('CURRENCY_NAME',
                                     p_usr_currency_code,
                                     l_get_id_return_status
                                    );
      IF p_currency_code IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_CURR_CODE_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   ELSE

     p_currency_code := arp_global.functional_currency;
     --Raise a warning message saying that currency was defaulted
     IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_FUNC_CURR_DEFAULTED');
        FND_MSG_PUB.Add;
     END IF;

   END IF;

ELSE
   IF  (p_usr_currency_code IS NOT NULL) THEN

       --give a warning message to indicate that the usr_currency_code
       -- entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_CURR_CODE_IGN');
         FND_MSG_PUB.Add;
       END IF;

   END IF;
END IF;

/*  Revert changes done for customer bank ref under payment uptake */

--Customer bank account Number,Name,ID

IF p_customer_bank_account_id IS NULL
 THEN
  IF(p_customer_bank_account_name IS NOT NULL) and
     (p_customer_bank_account_num IS NULL)
   THEN
  /* p_customer_bank_account_id := Get_Id('CUST_BANK_ACCOUNT_NAME',
                                          p_customer_bank_account_name,
                                          l_get_id_return_status
                                        );
     IF p_customer_bank_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF; */

        begin
				select  distinct bb.branch_party_id "bank_branch_id",
					   bb.BANK_ACCOUNT_ID
				into p_customer_bank_branch_id
				     ,p_customer_bank_account_id
				from iby_fndcpt_payer_assgn_instr_v a,
				       iby_ext_bank_accounts_v bb
				where a.cust_account_id = p_customer_id
				and a.instrument_type = 'BANKACCOUNT'
				and ( a.acct_site_use_id =  p_customer_site_use_id or a.acct_site_use_id is null)
				and a.currency_code = p_currency_code
				and bb.ext_bank_account_id = a.instrument_id
				and bb.bank_account_name = p_customer_bank_account_name;
		     exception
		      when others then
		       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_NAME_INVALID');
		       FND_MSG_PUB.Add;
		       p_return_status := FND_API.G_RET_STS_ERROR;
		     end;

  ELSIF(p_customer_bank_account_name IS  NULL) and
       (p_customer_bank_account_num IS NOT NULL)
   THEN
    /* p_customer_bank_account_id := Get_Id('CUST_BANK_ACCOUNT_NUMBER',
                                          p_customer_bank_account_num,
                                          l_get_id_return_status
                                        );
     IF p_customer_bank_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_NUM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF; */

      begin
			select  distinct bb.branch_party_id "bank_branch_id",
				   bb.BANK_ACCOUNT_ID
			into p_customer_bank_branch_id,
			     p_customer_bank_account_id
			from iby_fndcpt_payer_assgn_instr_v a,
			       iby_ext_bank_accounts_v bb
			where a.cust_account_id = p_customer_id
			and a.instrument_type = 'BANKACCOUNT'
			and ( a.acct_site_use_id =  p_customer_site_use_id or a.acct_site_use_id is null)
			and a.currency_code = p_currency_code
			and bb.ext_bank_account_id = a.instrument_id
			and bb.bank_account_number = p_customer_bank_account_num;
	     exception
	      when others then
	       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_NUM_INVALID');
	       FND_MSG_PUB.Add;
	       p_return_status := FND_API.G_RET_STS_ERROR;
	     end;

  ELSIF(p_customer_bank_account_name IS NOT NULL) and
       (p_customer_bank_account_num IS NOT NULL)
   THEN
     /* p_customer_bank_account_id := Get_Cross_Validated_Id( 'CUST_BANK_ACCOUNT',
                                              p_customer_bank_account_num,
                                              p_customer_bank_account_name,
                                              l_get_id_return_status
                                             );
     IF p_customer_bank_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_2_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF; */

        begin
				select  distinct bb.branch_party_id "bank_branch_id",
					   bb.BANK_ACCOUNT_ID
				into p_customer_bank_branch_id
				    ,p_customer_bank_account_id
				from iby_fndcpt_payer_assgn_instr_v a,
				       iby_ext_bank_accounts_v bb
				where a.cust_account_id = p_customer_id
				and a.instrument_type = 'BANKACCOUNT'
				and ( a.acct_site_use_id =  p_customer_site_use_id or a.acct_site_use_id is null)
				and a.currency_code = p_currency_code
				and bb.ext_bank_account_id = a.instrument_id
				and bb.bank_account_name = p_customer_bank_account_name
				and bb.bank_account_number = p_customer_bank_account_num;
		     exception
		      when others then
		       FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_AC_2_INVALID');
		       FND_MSG_PUB.Add;
		       p_return_status := FND_API.G_RET_STS_ERROR;
		     end;

  END IF;

ELSE --In case the ID has been entered by the user
   IF (p_customer_bank_account_num IS NOT NULL) OR
      (p_customer_bank_account_name IS NOT NULL) THEN
       --give a warning message to indicate that the customer_bank_account_num and
       --p_customer_bank_account_name entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUS_BK_NAME_NUM_IGN');
         FND_MSG_PUB.Add;
       END IF;
    END IF;

END IF;


--Remittance bank account Number,Name,ID


 IF p_remittance_bank_account_id IS NULL
  THEN
  IF(p_remittance_bank_account_name IS NOT NULL) and
     (p_remittance_bank_account_num IS NULL)
    THEN
      p_remittance_bank_account_id := Get_Id('REMIT_BANK_ACCOUNT_NAME',
                                             p_remittance_bank_account_name,
                                             l_get_id_return_status
                                            );
     IF p_remittance_bank_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSIF(p_remittance_bank_account_name IS  NULL) and
        (p_remittance_bank_account_num IS NOT NULL)
    THEN
      p_remittance_bank_account_id := Get_Id('REMIT_BANK_ACCOUNT_NUMBER',
                                              p_remittance_bank_account_num,
                                              l_get_id_return_status
                                             );
     IF p_remittance_bank_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_NUM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSIF(p_remittance_bank_account_name IS NOT NULL) and
        (p_remittance_bank_account_num IS NOT NULL)
    THEN
      p_remittance_bank_account_id := Get_Cross_Validated_Id( 'REMIT_BANK_ACCOUNT',
                                               p_remittance_bank_account_num,
                                               p_remittance_bank_account_name,
                                               l_get_x_val_return_status
                                              );
     IF p_remittance_bank_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_2_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;

 ELSE

   IF (p_remittance_bank_account_name IS NOT NULL) OR
      (p_remittance_bank_account_num IS NOT NULL)
    THEN
       --give a warning message to indicate that the remittance_bank_account_num and
       --remittance_bank_account_name entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_NAME_NUM_IGN');
         FND_MSG_PUB.Add;
       END IF;
   END IF;

 END IF;

-- Exchange_rate_type
 IF p_exchange_rate_type IS NULL THEN
   IF p_usr_exchange_rate_type IS NOT NULL
    THEN
      p_exchange_rate_type := Get_Id('EXCHANGE_RATE_TYPE_NAME',/* Bug fix 2982212*/
                                     p_usr_exchange_rate_type,
                                     l_get_id_return_status
                                    );
      IF p_exchange_rate_type IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_X_RATE_TYP_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END IF;

 ELSE
   IF  (p_usr_exchange_rate_type IS NOT NULL) THEN
       --give a warning message to indicate that the usr_exchange_rate_type
       -- entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_X_RATE_TYPE_IGN');
         FND_MSG_PUB.Add;
       END IF;
   END IF;

 END IF;


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_cash_ids_from_values ()-');
   END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_cash_ids_from_values() ',
                            G_MSG_UERROR);
  END IF;
  raise;

END Default_cash_ids;

PROCEDURE Get_Cash_Defaults(
          p_currency_code               IN OUT NOCOPY ar_cash_receipts.currency_code%TYPE,
          p_exchange_rate_type          IN OUT NOCOPY ar_cash_receipts.exchange_rate_type%TYPE,
          p_exchange_rate               IN OUT NOCOPY ar_cash_receipts.exchange_rate%TYPE,
          p_exchange_rate_date          IN OUT NOCOPY ar_cash_receipts.exchange_date%TYPE,
          p_amount                      IN OUT NOCOPY ar_cash_receipts.amount%TYPE,
          p_factor_discount_amount      IN OUT NOCOPY ar_cash_receipts.factor_discount_amount%TYPE,
          p_receipt_date                IN OUT NOCOPY ar_cash_receipts.receipt_date%TYPE,
          p_gl_date                     IN OUT NOCOPY DATE,
          p_maturity_date               IN OUT NOCOPY DATE,
          p_customer_receipt_reference  IN OUT NOCOPY ar_cash_receipts.customer_receipt_reference%TYPE,
          p_override_remit_account_flag IN OUT NOCOPY ar_cash_receipts.override_remit_account_flag%TYPE,
          p_remittance_bank_account_id  IN OUT NOCOPY ar_cash_receipts.remit_bank_acct_use_id%TYPE,
          p_deposit_date                IN OUT NOCOPY ar_cash_receipts.deposit_date%TYPE,
          p_receipt_method_id           IN OUT NOCOPY ar_cash_receipts.receipt_method_id%TYPE,
          p_state                       OUT NOCOPY ar_receipt_classes.creation_status%TYPE,
          p_anticipated_clearing_date   IN OUT NOCOPY ar_cash_receipts.anticipated_clearing_date%TYPE,
          p_called_from                 IN  VARCHAR2,
          p_creation_method_code           OUT NOCOPY ar_receipt_classes.creation_method_code%TYPE,
          p_return_status               OUT NOCOPY VARCHAR2
           )
IS
 l_cr                       CONSTANT char(1)        := '';
 l_temp_id                  NUMBER(15);
 l_temp_char                VARCHAR2(80) ;
 l_temp_date                DATE ;
 l_def_curr_return_status   VARCHAR2(1);
 l_def_rm_return_status     VARCHAR2(1);
 l_def_gl_dt_return_status  VARCHAR2(1);
 /* Bug fix 3315058 */
 l_bank_acc_val_ret_status   VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Get_Cash_Defaults()+ ');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;
  -- default the receipt date if NULL
  IF (p_receipt_date IS NULL)
    THEN
    Select trunc(sysdate)
    into p_receipt_date
    from dual;
  END IF;

  -- default the gl_date
  IF p_gl_date IS NULL THEN
    Default_gl_date(p_receipt_date,
                    p_gl_date,
                    NULL,
                    l_def_gl_dt_return_status);
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Get_Cash_Defaults: ' || 'l_default_gl_date_return_status : '||l_def_gl_dt_return_status);
    END IF;
  END IF;

  IF (p_deposit_date IS NULL)
    THEN
    p_deposit_date := p_receipt_date;
  END IF;

  IF (p_maturity_date IS NULL) THEN
     p_maturity_date := p_deposit_date;
  END IF;

 -- Default the Currency parameters
    Default_Currency_info(p_currency_code,
                          p_receipt_date,
                          p_exchange_rate_date,
                          p_exchange_rate_type,
                          p_exchange_rate,
                          l_def_curr_return_status
                         );

--Set the precision of the receipt amount as per currency
  IF p_amount is NOT NULL THEN
   p_amount := arp_util.CurrRound( p_amount,
                                   p_currency_code
                                  );
  END IF;

 --Default the Receipt Method related parameters
   Default_Receipt_Method_info(p_receipt_method_id,
                               p_currency_code,
                               p_receipt_date,
                               p_remittance_bank_account_id,
                               p_state,
                               p_creation_method_code,
                               p_called_from,
                               l_def_rm_return_status
                                );

/* Bug fix 3315058 */
   Validate_Receipt_Method_ccid(p_receipt_method_id,
                                p_remittance_bank_account_id,
                                p_gl_date,
                                l_bank_acc_val_ret_status);

  --default the override_remit_bank_account_flag
  IF (p_override_remit_account_flag IS NULL) THEN
     p_override_remit_account_flag := 'Y';
  END IF;

  IF l_def_rm_return_status <> FND_API.G_RET_STS_SUCCESS OR
     l_def_gl_dt_return_status <> FND_API.G_RET_STS_SUCCESS OR
     l_def_curr_return_status <> FND_API.G_RET_STS_SUCCESS  OR
     l_bank_acc_val_ret_status <> FND_API.G_RET_STS_SUCCESS THEN /* Bug3315058 */
       p_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Get_Cash_Defaults: ' || '************Cash Defaults********************');
     arp_util.debug('Get_Cash_Defaults: ' || 'p_receipt_date               : '||to_char(p_receipt_date,'DD-MON-YYYY'));
     arp_util.debug('Get_Cash_Defaults: ' || 'p_gl_date                    : '||to_char(p_gl_date,'DD-MON-YYYY'));
     arp_util.debug('Get_Cash_Defaults: ' || 'p_deposit_date               : '||to_char(p_deposit_date,'DD-MON-YYYY'));
     arp_util.debug('Get_Cash_Defaults: ' || 'p_maturity_date              : '||to_char(p_maturity_date,'DD-MON-YYYY'));
     arp_util.debug('Get_Cash_Defaults: ' || 'p_currency_code              : '||p_currency_code);
     arp_util.debug('Get_Cash_Defaults: ' || 'p_exchange_rate_date         : '||to_char(p_exchange_rate_date,'DD-MON-YYYY'));
     arp_util.debug('Get_Cash_Defaults: ' || 'p_exchange_rate_type         : '||p_exchange_rate_type);
     arp_util.debug('Get_Cash_Defaults: ' || 'p_exchange_rate              : '||to_char(p_exchange_rate));
     arp_util.debug('Get_Cash_Defaults: ' || 'p_receipt_method_id          : '||to_char(p_receipt_method_id));
     arp_util.debug('Get_Cash_Defaults: ' || 'remit bank acct use id : '||to_char(p_remittance_bank_account_id));
     arp_util.debug('Get_Cash_Defaults: ' || 'p_state                      : '||p_state);
     arp_util.debug('Get_Cash_Defaults ()-');
  END IF;
END Get_Cash_Defaults;

FUNCTION Get_grace_days(
          p_customer_id   IN NUMBER,
          p_bill_to_site_use_id IN NUMBER) RETURN NUMBER IS

l_grace_days         NUMBER;
l_bill_to_site_use_id  NUMBER;

BEGIN

   l_bill_to_site_use_id := NVL(p_bill_to_site_use_id,-99999);
  IF p_customer_id IS NOT NULL  THEN

/* modified for tca uptake */
   SELECT NVL(NVL(site.discount_grace_days, cust.discount_grace_days),0)
    INTO  l_grace_days
    FROM
      hz_customer_profiles      cust,
      hz_customer_profiles      site,
      hz_cust_accounts          c
    WHERE
          c.cust_account_id     = p_customer_id
    AND   cust.cust_account_id  = c.cust_account_id
    AND   cust.site_use_id      IS NULL
    AND   site.cust_account_id (+)  = c.cust_account_id
    AND   site.site_use_id (+)  = l_bill_to_site_use_id;
  END IF;

  RETURN l_grace_days;

EXCEPTION
   WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: Get_grace_days()');
    END IF;
    raise;
END Get_grace_days;

PROCEDURE Default_trans_to_receipt_rate(p_trx_currency_code IN VARCHAR2,
                                    p_cr_currency_code      IN VARCHAR2,
                                    p_receipt_date          IN VARCHAR2,
                                    p_trans_to_receipt_rate IN OUT NOCOPY NUMBER,
                                    p_amount_applied        IN NUMBER,
                                    p_amount_applied_from   IN NUMBER,
                                    p_cr_date               IN DATE,
                                    p_return_status         OUT NOCOPY VARCHAR2
                                      ) IS
l_exchange_rate_type  VARCHAR2(30);
l_temp_rate NUMBER;
l_amount_applied  NUMBER;
l_amount_applied_from  NUMBER;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_trans_to_receipt_rate ()+');
 END IF;

 p_return_status := FND_API.G_RET_STS_SUCCESS;
--if the trx currency and the receipt currency are not same
IF p_cr_currency_code <> p_trx_currency_code THEN

   --do the rounding
   IF P_trans_to_receipt_rate IS NOT NULL THEN
     p_trans_to_receipt_rate := ROUND(p_trans_to_receipt_rate, 38);
   END IF;

  --get the default only if p_trans_to_receipt_rate has not been entered by
  --user
   IF p_trans_to_receipt_rate IS NULL AND
      (gl_currency_api.is_fixed_rate(
                                     p_cr_currency_code,
                                     p_trx_currency_code,
                                     p_cr_date
                                        ) <> 'Y')  THEN

     --try to first get the rate from gl if possible

      l_exchange_rate_type := pg_profile_cc_rate_type;

        IF (l_exchange_rate_type IS NOT NULL)
          THEN
          --relationship between the two currencies is not fixed
          --and the default CROSS_CURRENCY_RATE_TYPE exists
          --try to get the rate from gl

          BEGIN
               l_temp_rate := gl_currency_api.get_rate(
                                        p_trx_currency_code,
                                        p_cr_currency_code,
                                        p_cr_date,
                                        l_exchange_rate_type);
          EXCEPTION
           WHEN gl_currency_api.NO_RATE THEN
            --rate does not exist set appropriate message.
            --p_return_status := FND_API.G_RET_STS_ERROR ;
            l_temp_rate := NULL;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Default_trans_to_receipt_rate: ' || 'Exception : gl_currency_api.NO_RATE ');
            END IF;
           WHEN gl_currency_api.INVALID_CURRENCY  THEN
            -- invalid currency set appropriate message.
            --p_return_status := FND_API.G_RET_STS_ERROR ;
            l_temp_rate := NULL;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Default_trans_to_receipt_rate: ' || 'Exception: gl_currency_api.INVALID_CURRENCY ');
            END IF;
          END;
        END IF ;

   ELSIF gl_currency_api.is_fixed_rate(
                                        p_cr_currency_code,
                                        p_trx_currency_code,
                                        p_cr_date
                                           ) = 'Y'  THEN
        --In case of fixed relationship get the fixed rate and return it.

        BEGIN
           l_temp_rate := gl_currency_api.get_rate(
                                      p_trx_currency_code,
                                      p_cr_currency_code,
                                      p_cr_date,
                                      l_exchange_rate_type
                                      );
        EXCEPTION
         WHEN gl_currency_api.NO_RATE THEN
          --rate does not exist set appropriate message.
          --p_return_status := FND_API.G_RET_STS_ERROR ;
          l_temp_rate := NULL;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Default_trans_to_receipt_rate: ' || 'Exception : gl_currency_api.NO_RATE ');
          END IF;
         WHEN gl_currency_api.INVALID_CURRENCY  THEN
          -- invalid currency set appropriate message.
          --p_return_status := FND_API.G_RET_STS_ERROR ;
          l_temp_rate := NULL;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Default_trans_to_receipt_rate: ' || 'Exception: gl_currency_api.INVALID_CURRENCY ');
          END IF;
        END;

        IF p_trans_to_receipt_rate IS NOT  NULL THEN
          IF l_temp_rate <> p_trans_to_receipt_rate THEN
           --raise error as the user specified CC rate is not the same as the
           --fixed rate.
           p_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_CC_RATE_INVALID');
           FND_MSG_PUB.Add;
           return;
          END IF;
        END IF;

   END IF;

        --In the case where, neither the fixed rate relationship
        --exists between the two currencies nor rate_type is available
        --so user needs to enter the value here or the trans_to_receipt_rate
        --is to be derived from the amount applied and the amount applied from.

      IF l_temp_rate IS NOT NULL THEN
          p_trans_to_receipt_rate := l_temp_rate;

      ELSE

          --rate does not exist in the gl so try to get it from the
          --following formula for a CC application:
          --p_trans_to_receipt_rate =
          --              p_amount_applied_from/p_amount_applied

          IF p_amount_applied_from IS NOT NULL AND
             p_amount_applied IS NOT NULL
           THEN
             l_amount_applied_from := arp_util.CurrRound(
                                         p_amount_applied_from,
                                         p_cr_currency_code
                                          );
             /* Bugfix 2916389. Use p_trx_currency_code instead of
		p_cr_currency_code. */
             l_amount_applied := arp_util.CurrRound(
                                         p_amount_applied,
                                         p_trx_currency_code
                                          );
             p_trans_to_receipt_rate := ROUND(l_amount_applied_from/l_amount_applied, 38);

          END IF;
      END IF;

 END IF;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Default_trans_to_receipt_rate: ' || 'p_trans_to_receipt_rate :'||to_char(p_trans_to_receipt_rate));
   arp_util.debug('Default_trans_to_receipt_rate ()-');
END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_trans_to_receipt_rate()');
  END IF;
  raise;
END Default_trans_to_receipt_rate;

PROCEDURE Default_amount_applied_from(
                 p_amount_applied        IN NUMBER,
                 p_trx_currency_code     IN VARCHAR2,
                 p_trans_to_receipt_rate IN NUMBER,
                 p_cr_currency_code      IN VARCHAR2,
                 p_amount_applied_from   IN OUT NOCOPY NUMBER,
                 p_return_status         OUT NOCOPY VARCHAR2
                    )  IS

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_amount_applied_from ()+');
   END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_amount_applied_from IS NULL  THEN
      IF p_trx_currency_code <> p_cr_currency_code   THEN

        --this is the CC application case
        IF p_trans_to_receipt_rate IS NOT NULL AND
           p_amount_applied IS NOT NULL
         THEN

          p_amount_applied_from := arp_util.CurrRound(
                                      p_amount_applied * p_trans_to_receipt_rate,
                                      p_cr_currency_code
                                        );
        END IF;

      END IF;

  ELSE
   --if user has entered the amount_applied_from then round it.
    p_amount_applied_from := arp_util.CurrRound(
                                      p_amount_applied_from,
                                      p_cr_currency_code
                                        );
  END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_amount_applied_from ()+');
   END IF;

EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_amount_applied_from: ' || 'EXCEPTION: Default_applied_amount_from()');
  END IF;
  raise;

END Default_amount_applied_from;


PROCEDURE Default_val_llca_parameters (
	            p_llca_type		   IN VARCHAR2,
                    p_cash_receipt_id      IN	NUMBER,
                    p_customer_trx_id      IN	NUMBER,
    		    p_customer_trx_line_id IN NUMBER,
    		    p_amount_applied	   IN  OUT NOCOPY NUMBER,
		    p_line_amount	   IN  OUT NOCOPY NUMBER,
		    p_tax_amount           IN  OUT NOCOPY NUMBER,
		    p_freight_amount       IN  OUT NOCOPY NUMBER,
		    p_charges_amount       IN  OUT NOCOPY NUMBER,
		    p_line_discount        IN  OUT NOCOPY NUMBER,
		    p_tax_discount         IN  OUT NOCOPY NUMBER,
		    p_freight_discount     IN  NUMBER,
		    p_discount             IN  OUT NOCOPY NUMBER,
                    p_receipt_currency_code IN	VARCHAR2,
                    p_invoice_currency_code IN	VARCHAR2,
		    p_cr_date		    IN  DATE,
		    p_creation_sign 		IN VARCHAR2,
                    p_natural_app_only_flag 	IN VARCHAR2,
		    p_return_status        OUT NOCOPY VARCHAR2,
                    p_msg_count            OUT NOCOPY NUMBER,
                    p_msg_data             OUT NOCOPY VARCHAR2
		    )  IS

cursor gt_lines_cur (p_cust_trx_id in number) is
select * from ar_llca_trx_lines_gt
where customer_trx_id = p_cust_trx_id;

l_gt_count              NUMBER;
l_line_amount_remaining	NUMBER;
l_line_tax_remaining	NUMBER;
l_line_number		NUMBER;
l_calc_tot_amount_app   NUMBER;
l_calc_line_per		NUMBER;
l_calc_line_amount	NUMBER;
l_calc_tax_amount	NUMBER;
l_calc_freight_amount	NUMBER;
l_cum_amount_app    	NUMBER := 0;
l_cum_line_amount       NUMBER := 0;
l_cum_tax_amount        NUMBER := 0;
l_cum_line_discount     NUMBER := 0;
l_cum_tax_discount      NUMBER := 0;
l_count_err_gt          NUMBER;


-- Bug 6931978 Cross Currency App
l_def_rate_return_status VARCHAR2(1);
l_receipt_date    DATE;
l_trans_to_receipt_rate NUMBER;

l_payment_amount_cal    NUMBER;
l_payment_amount        NUMBER;
l_sign_value_of_ps       NUMBER := 0;
l_temp_amount            NUMBER := 0;
l_message_name           VARCHAR2(100);


BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_val_llca_parameters()+');
    END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Initialize the Sys Parameters /INV PS /REC PS / Copy Trx lines into GT
   arp_process_det_pkg.initialization (p_customer_trx_id,
 	                              p_cash_receipt_id,
	 	  	 	      p_return_status,
				      p_msg_data,
				      p_msg_count);

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_val_llca_parameters: Initialization Return Status : '||p_return_status);
    END IF;

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
         FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ARP_PROCESS_DET_PKG.INITIALIZTION '||SQLERRM);
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR ;

	 IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Apply_In_Detail: ' || 'Error(s) occurred in arp_process_det_pkg.Initialization ');
         END IF;
        Return;
    END IF;

    IF  p_llca_type = 'S'
    THEN
       IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_val_llca_parameters: Summary Level Application ');
       END IF;
       IF    p_line_amount IS NULL AND  p_tax_amount  IS NULL
        AND  p_freight_amount  IS NULL AND  p_charges_amount is NULL
       THEN
		FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_LTFC_AMT_NULL');
		FND_MSG_PUB.ADD;
		p_return_status := FND_API.G_RET_STS_ERROR ;
       END IF;
       IF    Nvl(p_amount_applied,0) <>
		( Nvl(p_line_amount,0) + Nvl(p_tax_amount,0)
		+ Nvl(p_freight_amount,0) + Nvl(p_charges_amount,0))
	THEN
	     p_amount_applied := Nvl(p_line_amount,0)
			+ Nvl(p_tax_amount,0) + Nvl(p_freight_amount,0)
			+ Nvl(p_charges_amount,0);

	     IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
	     THEN
		FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_AMT_DEFLT_IGN');
		FND_MSG_PUB.Add;
	     END IF;

	     IF PG_DEBUG in ('Y', 'C') THEN
		 arp_util.debug('Default_application_info: ' ||
		  'Amount applied has been defaulted to the sum of
			line/tax/freight/charges amount ');
             END IF;
	END IF;


   Elsif P_llca_type = 'L'
   Then
     IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_val_llca_parameters: Line Level Application ');
      END IF;
     	 IF ( Nvl(p_line_amount,0) <> 0
   	  and Nvl(p_tax_amount,0) <> 0
	  and nvl(p_charges_amount,0) <> 0
	    )
	 THEN
	     p_line_amount    := NULL;
	     p_tax_amount     := NULL;
	     p_charges_amount := NULL;
	     IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
	     THEN
	         FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_LTC_IGN');
	         FND_MSG_PUB.Add;
	     END IF;

	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('Default_val_llca_parameters: ' || 'Line, Tax,
		, Charges amount has been defaulted to Null');
             END IF;
	 END IF;

	select count(*) into l_gt_count
	from ar_llca_trx_lines_gt
	where customer_trx_id = p_customer_trx_id
	and rownum = 1;

        -- For All Lines, Amount due remaining / line remaining will be defaulted later.
       IF  nvl(l_gt_count,0) = 0
       THEN
           If  Nvl(p_amount_applied,0) <>  0
           THEN
             p_amount_applied := NULL;

	     IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
	     THEN
	         FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_AMT_DEFLT_IGN');
	         FND_MSG_PUB.Add;
	     END IF;

	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_util.debug('Default_val_llca_parameters: ' || 'Amount applied
		amount has been defaulted to Null');
             END IF;
           END IF;
       Else
        -- Specified Lines
       IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Specified one or more lines in PLSQL table... ');
       END IF;

       -- Calculate the line level amounts
       For sp_lines_row in gt_lines_cur(p_customer_trx_id)
       LOOP
        BEGIN

	-- Bug 6931978
	  IF p_invoice_currency_code = p_receipt_currency_code THEN
		     If sp_lines_row.line_amount IS NULL  AND
			sp_lines_row.tax_amount  IS NULL  AND
			sp_lines_row.amount_applied is NULL AND
			sp_lines_row.customer_trx_line_id is NOT NULL
		     THEN
			  ar_receipt_lib_pvt.populate_errors_gt (
			  p_customer_trx_id      => p_customer_trx_id,
			  p_customer_trx_line_id => sp_lines_row.customer_trx_line_id,
			  p_error_message =>
			   arp_standard.fnd_message('AR_RAPI_LTFC_AMT_NULL'),
			  p_invalid_value	 => NULL
			  );
			  p_return_status := FND_API.G_RET_STS_ERROR ;
			  EXIT;
		     END IF;
           END IF;
	-- Bug 6931978 END
        select  to_char(line.line_number) apply_to,
                nvl(line.amount_due_remaining,0),
                nvl(tax.amount_due_remaining,0)
        into
                l_line_number,
                l_line_amount_remaining,
                l_line_tax_remaining
        from ra_customer_trx_lines line,
             (select link_to_cust_trx_line_id,
                     line_type,
                     sum(nvl(amount_due_original,0)) amount_due_original,
                     sum(nvl(amount_due_remaining,0)) amount_due_remaining
              from ra_customer_trx_lines
              where customer_trx_id =  sp_lines_row.customer_trx_id  -- Bug 7241703 Added condition
	       and nvl(line_type,'TAX') =  'TAX'
              group by link_to_cust_trx_line_id,line_type
              ) tax
        where line.customer_Trx_id = sp_lines_row.customer_trx_id
        and   line.customer_trx_line_id = sp_lines_row.customer_trx_line_id
        and line.line_type = 'LINE'
        and line.customer_trx_line_id = tax.link_to_cust_trx_line_id (+);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('' || 'EXCEPTION: Default_val_llca_parameters()');
            END IF;
               p_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_TRX_LINE_ID_INVALID');
              FND_MSG_PUB.ADD;
              RAISE;
          WHEN others THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('' || 'EXCEPTION: Default_val_llca_parameters()');
            END IF;
            RAISE;
        END;
            IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Customer_trx_line_id =>'||to_char(sp_lines_row.customer_trx_line_id));
            END IF;
            Select decode ( ( Nvl(l_line_amount_remaining,0)
                                 / ( Nvl(l_line_amount_remaining,0)
                                   + Nvl(l_line_tax_remaining,0)
                                   )
                             ),0,1,
                             ( Nvl(l_line_amount_remaining,0)
                                 / ( Nvl(l_line_amount_remaining,0)
                                   + Nvl(l_line_tax_remaining,0)
                                   )
                             )
                           )
             into l_calc_line_per
             from dual;

	-- Bug 6931978 Cross Currency App
              IF p_invoice_currency_code <> p_receipt_currency_code THEN
		      IF Nvl(sp_lines_row.amount_applied_from,0) <> 0
			 Then

				Default_trans_to_receipt_rate(
				       p_invoice_currency_code ,
				       p_receipt_currency_code ,
				       l_receipt_date ,
				       l_trans_to_receipt_rate ,
				       sp_lines_row.amount_applied,
				       sp_lines_row.amount_applied_from,
				       p_cr_date,
				       l_def_rate_return_status
						);
					sp_lines_row.amount_applied :=  arp_util.CurrRound(
									sp_lines_row.amount_applied_from / l_trans_to_receipt_rate,
									p_invoice_currency_code);
					sp_lines_row.tax_amount  := NULL;
					sp_lines_row.line_amount := NULL;


			      IF PG_DEBUG in ('Y', 'C') THEN
				 arp_util.debug('Default_val_llca_parameters: ' || 'Default trans_to_receipt_rate status: '||l_def_rate_return_status);
				 arp_util.debug('Default_val_llca_parameters: ' || 'l_trans_to_receipt_rate: '||l_trans_to_receipt_rate);
				 arp_util.debug('Default_val_llca_parameters: ' || 'sp_lines_row.amount_applied: '||sp_lines_row.amount_applied);
			      END IF;

			END IF;
		END IF;

        -- Bug 6931978 End


            -- First Priority Line Amount
            If Nvl(sp_lines_row.line_amount,0) <> 0
            Then
               IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('First priority : Line Amount ');
                arp_util.debug('Line Amount has taken precedence over the amount applied ');
               END IF;
               l_calc_tot_amount_app := arp_util.CurrRound(
                                                ( nvl(sp_lines_row.line_amount,0)
                                                 / nvl(l_calc_line_per,1)
                                                )
                                                ,p_invoice_currency_code);
               l_calc_line_amount    := arp_util.CurrRound(sp_lines_row.line_amount
                                                ,p_invoice_currency_code);

            -- Calculate Line amount based on the Amount Applied.
            Elsif Nvl(sp_lines_row.amount_applied,0) <> 0
            Then
               IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Considered the Amount Applied value ');
               End If;

                l_calc_tot_amount_app   := arp_util.CurrRound(sp_lines_row.amount_applied
                                                ,p_invoice_currency_code);
                l_calc_line_amount      :=  arp_util.CurrRound((l_calc_tot_amount_app
                                          * l_calc_line_per),p_invoice_currency_code);
            End If;

            IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('l_calc_tot_amount_app -> '||to_char(l_calc_tot_amount_app));
                arp_util.debug('l_calc_line_amount    -> '||to_char(l_calc_line_amount));
            END IF;


            -- Tax amount has taken precedence over the Line / amount applied
            If NVL(sp_lines_row.tax_amount,0) <> 0
            THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Tax Amount has taken precedence over the amount applied ');
               End If;
                l_calc_tax_amount := arp_util.CurrRound(sp_lines_row.tax_amount
                                                ,p_invoice_currency_code);

                l_calc_tot_amount_app := l_calc_line_amount +
                                                l_calc_tax_amount;
            Else
               IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Amount Applied has taken precedence over the Tax Amount');
               End If;
              -- Amount applied has taken precedence over the tax amount
                l_calc_tax_amount :=  arp_util.CurrRound((Nvl(l_calc_tot_amount_app,0)
                                          - Nvl(l_calc_line_amount,0))
                                          ,p_invoice_currency_code);
            End If;


            If Nvl(sp_lines_row.amount_applied,0) <> Nvl(l_calc_tot_amount_app,0)
            Then
                  IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
                  THEN
                         FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_AMT_DEFLT_IGN');
                         FND_MSG_PUB.Add;
                  END IF;
            END If;


            IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('l_calc_tot_amount_app -> '||to_char(l_calc_tot_amount_app));
                arp_util.debug('l_calc_line_amount   -> '||to_char(l_calc_line_amount));
                arp_util.debug('l_calc_tax_amount    -> '||to_char(l_calc_tax_amount));
            END IF;

            -- Check for overapply
		    l_payment_amount_cal := (-1) * l_calc_tot_amount_app;
		    l_payment_amount     := NVL(l_line_amount_remaining,0) + NVL(l_line_tax_remaining,0);

		    IF ( NVL( l_payment_amount, 0 ) < 0 ) THEN
			l_sign_value_of_ps:= -1;
		    ELSIF ( NVL( l_payment_amount, 0 ) > 0 ) THEN
			l_sign_value_of_ps := 1;

		    ELSE
			-- check the creation_sign. The amount changed should only make the
			-- amount_due_remaining go to where the creation_sign allows
			--

			arp_non_db_pkg.check_creation_sign( p_creation_sign,
							    l_payment_amount_cal, 'WHEN-VALIDATE-ITEM',
							    l_message_name);
			IF l_message_name IS NOT NULL
			THEN
			 AR_RECEIPT_LIB_PVT.populate_errors_gt (
					      p_customer_trx_id  => sp_lines_row.customer_trx_id,
					      p_customer_trx_line_id => sp_lines_row.customer_trx_line_id,
					      p_error_message	  => arp_standard.fnd_message('AR_LL_NO_OVERAPPLY'),
					      p_invalid_value	 => NULL );
			END IF;
		    END IF;

		     -- Then check whether it violates overapplication flag and natural
		     -- application flag.
		     --
		     l_temp_amount := NVL( l_payment_amount, 0 ) + l_payment_amount_cal;
		     IF ( ( l_sign_value_of_ps * l_temp_amount ) < 0 ) THEN
			  AR_RECEIPT_LIB_PVT.populate_errors_gt (
					      p_customer_trx_id  => sp_lines_row.customer_trx_id,
					      p_customer_trx_line_id => sp_lines_row.customer_trx_line_id,
					      p_error_message	  => arp_standard.fnd_message('AR_LL_NO_OVERAPPLY'),
					      p_invalid_value	 => NULL );
		     END IF;
		     --
		     -- check natural application
		     --
		 /*
		   IF (p_natural_app_only_flag = 'Y') THEN
		     IF ( l_payment_amount_cal < 0 ) THEN
			     l_temp_amount := -1;
		     ELSIF ( l_payment_amount_cal > 0 ) THEN
			     l_temp_amount := 1;
		     ELSE
			     l_temp_amount := 0;
		     END IF;

		     IF (( l_sign_value_of_ps * l_temp_amount ) = 1) THEN
		       AR_RECEIPT_LIB_PVT.populate_errors_gt (
					      p_customer_trx_id  => sp_lines_row.customer_trx_id,
					      p_customer_trx_line_id => sp_lines_row.customer_trx_line_id,
					      p_error_message	  => arp_standard.fnd_message('AR_LL_NO_OVERAPPLY'),
					      p_invalid_value	 => NULL );
		     END IF;
		   END IF;
                 */
	    -- Check for overapply


	    -- Update the GT table with calculated values

               Update ar_llca_trx_lines_gt
	       set    amount_applied   = Nvl(l_calc_tot_amount_app,0),
                      line_amount      = Nvl(l_calc_line_amount,0),
                      tax_amount       = Nvl(l_calc_tax_amount,0)
	       where customer_trx_id = p_customer_trx_id
	       and   customer_trx_line_id = sp_lines_row.customer_trx_line_id;

             -- Running totals
                l_cum_amount_app      := Nvl(l_cum_amount_app,0) + Nvl(l_calc_tot_amount_app,0);
                l_cum_line_amount     := Nvl(l_cum_line_amount,0)+ Nvl(l_calc_line_amount,0);
                l_cum_tax_amount      := Nvl(l_cum_tax_amount,0) + Nvl(l_calc_tax_amount,0);
                l_cum_line_discount   := Nvl(l_cum_line_discount,0) + Nvl(sp_lines_row.line_discount,0);
                l_cum_tax_discount    := Nvl(l_cum_tax_discount,0) + Nvl(sp_lines_row.tax_discount,0);

            IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('l_cum_tot_amount_app -> '||to_char(l_cum_amount_app));
                arp_util.debug('l_cum_line_amount   -> '||to_char(l_cum_line_amount));
                arp_util.debug('l_cum_tax_amount    -> '||to_char(l_cum_tax_amount));
                arp_util.debug('l_cum_line_discount -> '||to_char(l_cum_line_discount));
                arp_util.debug('l_cum_tax_discount  -> '||to_char(l_cum_tax_discount));
	    END IF;
       End Loop;

		-- Check for overapply
		select count(1) into l_count_err_gt from ar_llca_trx_errors_gt
		where customer_trx_id = p_customer_trx_id;

		  IF l_count_err_gt <> 0 AND p_llca_type = 'L'
		  THEN
		          p_return_status := FND_API.G_RET_STS_ERROR;

			  IF PG_DEBUG in ('Y', 'C') THEN
			     arp_util.debug('Apply_In_Detail: ' || 'Error(s) occurred in Overapply check. ');
		          END IF;

		  END IF;
		  -- Check for overapply

                 p_amount_applied := nvl(l_cum_amount_app,0) + nvl(p_freight_amount,0);
                 p_line_amount    := nvl(l_cum_line_amount,0);
                 p_tax_amount     := nvl(l_cum_tax_amount,0);
                 p_line_discount  := nvl(l_cum_line_discount,0);
                 p_tax_discount   := nvl(l_cum_tax_discount,0);
                 p_discount       := nvl(p_line_discount,0) + nvl(p_tax_discount,0)
                                      + nvl(p_freight_discount,0);
            IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('p_amount_applied => '||to_char(p_amount_applied) );
                arp_util.debug('p_line_amount    => '||to_char(l_cum_line_amount));
                arp_util.debug('p_tax_amount     => '||to_char(l_cum_tax_amount));
                arp_util.debug('p_freight_amount => '||to_char(p_freight_amount));
                arp_util.debug('p_line_discount  => '||to_char(p_line_discount));
                arp_util.debug('p_tax_discount   => '||to_char(p_tax_discount));
                arp_util.debug('p_freight_discount => '||to_char(p_freight_discount));
                arp_util.debug('p_discount (Total) => '||to_char(p_discount));
	     END IF;

       END IF; /* GT COUNT END IF */
      END IF;   /* P_llca_type ENDIF */


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_val_llca_parameters()-');
    END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_val_llca_parameters: ()');
  END IF;
  raise;
END;

PROCEDURE Default_disc_and_amt_applied(
                                     p_customer_id                 IN NUMBER,
                                     p_bill_to_site_use_id         IN NUMBER,
                                     p_applied_payment_schedule_id IN NUMBER,
                                     p_amount_applied              IN  OUT NOCOPY NUMBER,
                                     p_discount                    IN OUT NOCOPY NUMBER,
                                     p_term_id                     IN NUMBER,
                                     p_installment                 IN NUMBER,
                                     p_trx_date                    IN DATE,
                                     p_cr_date                     IN DATE,
                                     p_cr_currency_code            IN VARCHAR2,
                                     p_trx_currency_code           IN VARCHAR2,
                                     p_cr_exchange_rate            IN NUMBER,
                                     p_trx_exchange_rate           IN NUMBER,--corresponds to app_folder.exchange_rate
                                     p_apply_date                  IN DATE,
                                     p_amount_due_original         IN NUMBER,
                                     p_amount_due_remaining        IN NUMBER,
                                     p_cr_unapp_amount             IN NUMBER,
                                     p_allow_overappln_flag        IN VARCHAR2,
                                     p_calc_discount_on_lines_flag IN VARCHAR2,
                                     p_partial_discount_flag       IN VARCHAR2,
                                     p_amount_line_items_original  IN NUMBER,
                                     p_discount_taken_unearned     IN NUMBER,
                                     p_discount_taken_earned       IN NUMBER,
                                     p_customer_trx_line_id        IN NUMBER,
                                     p_trx_line_amount             IN NUMBER,
     				     p_llca_type		   IN VARCHAR2,
                                     p_discount_max_allowed       OUT NOCOPY NUMBER,
                                     p_discount_earned_allowed    OUT NOCOPY NUMBER,
                                     p_discount_earned            OUT NOCOPY NUMBER,
                                     p_discount_unearned          OUT NOCOPY NUMBER,
                                     p_new_amount_due_remaining   OUT NOCOPY NUMBER,
                                     p_return_status              OUT NOCOPY VARCHAR2
                                      )
IS

l_grace_days                   NUMBER;
l_applied_in_amount            NUMBER;
l_earned_disc_pct              NUMBER;
l_best_disc_pct                NUMBER;
l_out_discount_date            DATE;
l_out_earned_discount          NUMBER;
l_out_unearned_discount        NUMBER;
l_out_amount_to_apply          NUMBER;
l_out_discount_to_take         NUMBER;
l_discount_date                DATE;
l_discount                     NUMBER;
l_discount_mode                VARCHAR2(1);
l_exchange_rate_type           VARCHAR2(30);
tmp_rate                       NUMBER;
l_default_amount_applied_flag  VARCHAR2(30);
l_convert_amount_inv           NUMBER;
l_convert_amount_cr	       NUMBER;
l_allow_discount               VARCHAR2(1) DEFAULT 'Y'; /* Bug fix 3450317 */

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_disc_and_amt_applied ()+');
    END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Default_disc_and_amt_applied: ' || 'p_discount = '||p_discount);
END IF;
  IF  p_amount_applied  IS NULL THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_disc_and_amt_applied: ' || 'The p_amount_applied is NULL ');
    END IF;
    IF p_trx_currency_code <> p_cr_currency_code  --The cross-currency case
      THEN
         l_exchange_rate_type := pg_profile_cc_rate_type;
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Default_disc_and_amt_applied: ' || 'default cross currency exchange rate type :'||l_exchange_rate_type);
         END IF;
       IF ( (gl_currency_api.is_fixed_rate(
                                        p_cr_currency_code,
                                        p_trx_currency_code,
                                        p_cr_date
                                           ) = 'Y' )  OR
            l_exchange_rate_type IS NOT NULL)
        THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Default_disc_and_amt_applied: ' || 'p_trx_currency_code    :'||p_trx_currency_code);
            arp_util.debug('Default_disc_and_amt_applied: ' || 'p_cr_currency_code     :'||p_cr_currency_code);
            arp_util.debug('Default_disc_and_amt_applied: ' || 'p_cr_date              :'||p_cr_date);
            arp_util.debug('Default_disc_and_amt_applied: ' || 'l_exchange_rate_type   :'||l_exchange_rate_type);
            arp_util.debug('Default_disc_and_amt_applied: ' || 'p_amount_due_remaining :'||to_char(p_amount_due_remaining));
            arp_util.debug('Default_disc_and_amt_applied: ' || 'p_cr_unapp_amount      :'||to_char(p_cr_unapp_amount));
         END IF;

         BEGIN

          /* bug 2174978 : cross currency applications are unable to do partial applications

             define converted amounts for
               a) transaction amount in receipt currency
               b) receipt amount in transaction currency
             and assign the appropriate converted amount to l_applied_in_amount below */

          -- invoice amount in receipt currency
          l_convert_amount_inv := gl_currency_api.convert_amount(
                                              p_trx_currency_code,
                                              p_cr_currency_code,
                                              p_cr_date,
                                              l_exchange_rate_type,
                                              p_amount_due_remaining);

          -- receipt amount in invoice currency
          l_convert_amount_cr := gl_currency_api.convert_amount(
                                              p_cr_currency_code,
                                              p_trx_currency_code,
                                              p_cr_date,
                                              l_exchange_rate_type,
                                              p_cr_unapp_amount);

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Default_disc_and_amt_applied: ' || 'l_convert_amount_inv:'||to_char(l_convert_amount_inv));
             arp_util.debug('Default_disc_and_amt_applied: ' || 'l_convert_amount_cr :'||to_char(l_convert_amount_cr));
          END IF;


         EXCEPTION
           WHEN gl_currency_api.NO_RATE  THEN
              l_convert_amount_inv := NULL;
              l_convert_amount_cr  := NULL;
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('Default_disc_and_amt_applied: ' || 'No rate exists in the GL for the cross currency conversion ');
              END IF;
           WHEN gl_currency_api.INVALID_CURRENCY  THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('Default_disc_and_amt_applied: ' || 'The Receipt/Invoice currency is Invalid ');
              END IF;
               raise;
         END;

         -- l_applied_in_amount is in terms of transaction currency
         -- because we need discounts in that currency

         IF (l_convert_amount_inv = p_cr_unapp_amount) THEN
            /* if invoice amount in receipt currency matches receipt's unapplied amount
               pass the invoice amount in invoice currency */

             l_applied_in_amount := p_amount_due_remaining;
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Default_disc_and_amt_applied: ' || 'l_convert_amount_inv = p_cr_unapp_amount, l_applied_in_amount = ' || to_char(l_applied_in_amount));
             END IF;
         ELSE
            /* bug 2174978 : if invoice amount in receipt currency <> receipt's unapplied amount
               pass the receipt amount in invoice currency */

             l_applied_in_amount := l_convert_amount_cr;
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Default_disc_and_amt_applied: ' || 'l_convert_amount_inv <> p_cr_unapp_amount, l_applied_in_amount :'||to_char(l_applied_in_amount));
             END IF;
         END IF;

          /* if exchange rate type was ok, but no rate in GL, the value returned is
             NULL so we have to set the value as though no fixed rate existed */
          IF (l_applied_in_amount IS NULL) THEN
              l_applied_in_amount := p_amount_due_remaining;
          END IF;

       ELSE
        -- No fixed rate exists then amount_due_remaining on the inv
        --is used as the amount for discount calculation

          l_applied_in_amount := p_amount_due_remaining;
       END IF;
    ELSE -- Same currency application
       /* Bug fix 3539657
          Set the l_applied_in_amount based on the value of ADR and the Unapplied amount */
        IF p_amount_due_remaining > p_cr_unapp_amount THEN
         l_applied_in_amount := p_cr_unapp_amount;
        ELSE
         l_applied_in_amount := p_amount_due_remaining;
        END IF;
    END IF;

    /* Bug fix 3539657
       If the p_customer_trx_line_id is specified, limit the amount applied to
       the line amount if the line amount is less than the defaulted amount applied */
    IF p_customer_trx_line_id IS NOT NULL
            AND p_llca_type is NULL
            AND p_trx_line_amount < l_applied_in_amount THEN
       l_applied_in_amount := p_trx_line_amount;
       --give a warning message here to let the user know that the
       --transaction line amount has been used as the default amount applied.
      IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS) THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_LINE_AMT_DEFLT');
         FND_MSG_PUB.Add;
      END IF;
    END IF;

    -- Defaulting mode for disount routine.
    l_discount_mode := '3';
    l_default_amount_applied_flag := pg_profile_amt_applied_def;
  ELSE --user has entered the amount applied.
     If p_llca_type is NOT NULL
     THEN
       l_applied_in_amount := Nvl(p_amount_applied,0);
       -- Direct mode for discount routine.
       l_discount_mode := '3';
       l_default_amount_applied_flag := pg_profile_amt_applied_def;
     Else
       l_applied_in_amount := p_amount_applied;
      -- Direct mode for discount routine.
      l_discount_mode := '2';
      l_default_amount_applied_flag := '';
     End IF;
  END IF;

     -- Get discount grace days.
    l_grace_days := Get_grace_days( p_customer_id,
                                    p_bill_to_site_use_id );

    /* Bug fix 3450317
       See if discounts are allowed for this customer */
    SELECT NVL(NVL(site.discount_terms, cust.discount_terms),'Y')
    INTO  l_allow_discount
    FROM
      hz_customer_profiles      cust
    , hz_customer_profiles      site
    WHERE
          cust.cust_account_id          = p_customer_id
    AND   cust.site_use_id              IS NULL
    AND   site.cust_account_id (+)      = cust.cust_account_id
    AND   site.site_use_id (+)          = p_bill_to_site_use_id;

  IF p_applied_payment_schedule_id > 0 AND
     l_grace_days IS NOT NULL THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_disc_and_amt_applied: ' || 'Before calling the discounts routine ..');
      END IF;

      arp_calculate_discount.discounts_cover(
      -- IN PARAMETERS
      p_mode                    => l_discount_mode,
      p_invoice_currency_code   => p_trx_currency_code,
      p_ps_id                   => p_applied_payment_schedule_id,
      p_term_id                 => p_term_id,
      p_terms_sequence_number   => p_installment,
      p_trx_date                => p_trx_date,
      p_apply_date              => p_apply_date,
      p_grace_days              => l_grace_days,
      p_default_amt_apply_flag  => l_default_amount_applied_flag,
      p_partial_discount_flag   => p_partial_discount_flag,
      p_calc_discount_on_lines_flag=> p_calc_discount_on_lines_flag,
      p_allow_overapp_flag      => p_allow_overappln_flag,
      p_close_invoice_flag      => 'N',
      p_input_amount            => NVL(l_applied_in_amount,0),
      p_amount_due_original     => p_amount_due_original,
      p_amount_due_remaining    => p_amount_due_remaining,
      p_discount_taken_earned   =>  NVL(p_discount_taken_earned,0),
      p_discount_taken_unearned => NVL(p_discount_taken_unearned,0),
      p_amount_line_items_original=> p_amount_line_items_original,
      p_module_name             => 'RECEIPTAPI',
      p_module_version          => '1.0',
      p_allow_discount          => l_allow_discount , /* Bug fix 3450317 */
      --*** OUT NOCOPY
      p_earned_disc_pct         => l_earned_disc_pct,
      p_best_disc_pct           => l_best_disc_pct,
      p_out_discount_date       => l_discount_date,
      p_out_earned_discount     => l_out_earned_discount,
      p_out_unearned_discount   => l_out_unearned_discount,
      p_out_amount_to_apply     => l_out_amount_to_apply,
      p_out_discount_to_take    => l_discount
        );
IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('Default_disc_and_amt_applied: ' || 'After calling the discounts routine ..');
   arp_util.debug('Default_disc_and_amt_applied: ' || 'l_out_earned_discount = '||l_out_earned_discount);
   arp_util.debug('Default_disc_and_amt_applied: ' || 'l_out_unearned_discount = '||l_out_unearned_discount);
   arp_util.debug('Default_disc_and_amt_applied: ' || 'l_discount = '||l_discount);
   arp_util.debug('Default_disc_and_amt_applied: ' || 'p_discount = '||p_discount);
END IF;
   l_earned_disc_pct :=  ROUND(l_earned_disc_pct,6);

  -- Store the maximum allowed discount, to be used later while validating
   p_discount_max_allowed :=arp_util.CurrRound( l_out_earned_discount+
                                                l_out_unearned_discount,
                                                p_trx_currency_code);
   p_discount_earned_allowed := l_out_earned_discount;

   IF p_discount IS NULL THEN
     p_discount := l_discount;
   END IF;

  --earned discounts
   -- Bug 3527600: Allow for negative discount
   IF (ABS(p_discount) > ABS(p_discount_earned_allowed))
    THEN
      p_discount_earned := p_discount_earned_allowed;
   ELSE
      p_discount_earned := p_discount;
   END IF;

    -- unearned discounts
    /* Bug 2535663 - p_discount, the discount passed in, should be used, not
    l_discount which is the discount_earned */
    -- Bug 3527600: Allow for negative discount
    IF (((p_discount > 0) AND ( p_discount - p_discount_earned_allowed > 0)) OR
        ((p_discount < 0) AND ( p_discount - p_discount_earned_allowed < 0)))
    THEN
      p_discount_unearned := p_discount - p_discount_earned_allowed;
    ELSE
      p_discount_unearned := 0;
    END IF;

  -- Populate Amount Applied if user has not entered any value for it.
  -- if the line number has not been entered by the user or is NULL then
  -- default the amount_applied to the l_out_amount_to_apply obtained
  -- from the discounts routine above else default it to the inv_line_amount

  IF p_amount_applied IS NULL  THEN
   /* Bug fix 3539657 */
   /* IF p_customer_trx_line_id IS NULL
     THEN
       p_amount_applied := l_out_amount_to_apply;
    ELSE

      IF p_trx_line_amount IS NOT NULL AND
         p_trx_line_amount < l_out_amount_to_apply
       THEN
        p_amount_applied := p_trx_line_amount;
        --give a warning message here to let the user know that the
        --transaction line amount has been used as the default amount applied.
        IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS) THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_LINE_AMT_DEFLT');
          FND_MSG_PUB.Add;
        END IF;
      END IF;

    END IF; */

    p_amount_applied := l_out_amount_to_apply;
  END IF;

  END IF;

  p_amount_applied := arp_util.CurrRound(p_amount_applied,
                                         p_trx_currency_code);
  p_discount := arp_util.CurrRound(p_discount,
                                 p_trx_currency_code);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_disc_and_amt_applied ()-');
  END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_disc_and_amt_applied: ' || 'EXCEPTION: Default_discount_and_amount_applied()');
  END IF;
  raise;
END Default_disc_and_amt_applied;

FUNCTION Get_trx_Line_amount(
                 p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE,
                 p_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE,
                 p_customer_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%TYPE,
                 p_return_status OUT NOCOPY VARCHAR2
                 ) RETURN NUMBER IS

l_trx_line_amount  NUMBER;
BEGIN
  IF p_customer_trx_id IS NOT NULL AND
     p_customer_trx_line_id IS NOT NULL
   THEN

    SELECT  ctl.extended_amount *
               nvl(tl.relative_amount,1)/ nvl(t.base_amount,1)
    INTO   l_trx_line_amount
    FROM  ra_customer_trx_lines ctl ,
          ra_terms t ,
          ra_terms_lines tl ,
          ar_payment_schedules ps
    WHERE ps.payment_schedule_id = p_payment_schedule_id and
          ctl.customer_trx_id = p_customer_trx_id and
          ctl.line_type = 'LINE' and
          tl.term_id(+) = ps.term_id and
          tl.sequence_num(+) = ps.terms_sequence_number and
          t.term_id(+) = tl.term_id and
          ctl.customer_trx_line_id = p_customer_trx_line_id;

         RETURN(l_trx_line_amount);
  END IF;

EXCEPTION
  WHEN no_data_found THEN
   p_return_status := FND_API.G_RET_STS_ERROR ;
   FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_TRX_LINE_ID_INVALID');
   FND_MSG_PUB.ADD;
   return(null);

  WHEN others THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Get_trx_Line_amount: ' || 'EXCEPTION: Default_Trx_Line_Amount()');
    END IF;
    raise;
END Get_trx_Line_amount;


PROCEDURE Default_Trx_Info(
              p_customer_trx_id              IN ra_customer_trx.customer_trx_id%TYPE,
              p_customer_trx_line_id         IN NUMBER,
              p_show_closed_invoices         IN VARCHAR2,
              p_cr_gl_date                   IN DATE,
              p_cr_customer_id               IN ar_cash_receipts.pay_from_customer%TYPE,
              p_cr_currency_code             IN VARCHAR2,
              p_cr_payment_schedule_id       IN NUMBER,
              p_cr_date                      IN DATE,
              p_called_from                  IN VARCHAR2,
              p_customer_id                  OUT NOCOPY NUMBER, --customer on transaction
              p_cust_trx_type_id             OUT NOCOPY ra_customer_trx.cust_trx_type_id%TYPE ,
              p_trx_due_date                 OUT NOCOPY DATE,
              p_trx_currency_code            OUT NOCOPY VARCHAR2,
              p_trx_exchange_rate            OUT NOCOPY NUMBER,
              p_trx_date                     OUT NOCOPY DATE,
              p_trx_gl_date                  OUT NOCOPY DATE,
              p_calc_discount_on_lines_flag  OUT NOCOPY VARCHAR2,
              p_partial_discount_flag        OUT NOCOPY VARCHAR2,
              p_allow_overappln_flag         OUT NOCOPY VARCHAR2,
              p_natural_appln_only_flag      OUT NOCOPY VARCHAR2,
              p_creation_sign                OUT NOCOPY VARCHAR2,
              p_applied_payment_schedule_id  IN OUT NOCOPY NUMBER,
              p_gl_date                      OUT NOCOPY DATE, --this is the application gl_date
              p_term_id                      OUT NOCOPY NUMBER,
              p_amount_due_original          OUT NOCOPY NUMBER,
              p_amount_line_items_original   OUT NOCOPY NUMBER,
              p_amount_due_remaining         OUT NOCOPY NUMBER,
              p_discount_taken_earned        OUT NOCOPY NUMBER,
              p_discount_taken_unearned      OUT NOCOPY NUMBER,
              p_trx_line_amount              OUT NOCOPY NUMBER,
              p_installment                  IN OUT NOCOPY NUMBER,
              p_bill_to_site_use_id          OUT NOCOPY NUMBER,
	      p_llca_type		     IN	 VARCHAR2,
	      p_line_items_original	     OUT NOCOPY NUMBER,
	      p_line_items_remaining	     OUT NOCOPY NUMBER,
	      p_tax_original		     OUT NOCOPY NUMBER,
	      p_tax_remaining		     OUT NOCOPY NUMBER,
	      p_freight_original	     OUT NOCOPY NUMBER,
	      p_freight_remaining	     OUT NOCOPY NUMBER,
	      p_rec_charges_charged	     OUT NOCOPY NUMBER,
	      p_rec_charges_remaining	     OUT NOCOPY NUMBER,
              p_return_status                OUT NOCOPY VARCHAR2
                          ) IS
l_location  VARCHAR2(50);
l_found     VARCHAR2(1);
l_applied_payment_schedule_id  NUMBER;
l_line_amt_return_status   VARCHAR2(1);

l_receipt_info_rec               AR_AUTOREC_API.receipt_info_rec;


/* modified for tca uptake */
CURSOR get_site_use_id IS
SELECT site_use_id
FROM   hz_cust_site_uses site_use,
       hz_cust_acct_sites acct_site
WHERE  acct_site.cust_acct_site_id = site_use.cust_acct_site_id
AND    acct_site.cust_account_id = p_customer_id
AND    site_use.location = l_location
AND    site_use.site_use_code IN ('BILL_TO','DRAWEE');

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_Trx_Info ()+');
 END IF;
 p_return_status := FND_API.G_RET_STS_SUCCESS;
--this is only for regular application, not for on-account


IF p_customer_trx_id IS NOT NULL AND
   p_installment IS NOT NULL THEN

  IF p_called_from IN ('BR_REMITTED',
                      'BR_FACTORED_WITH_RECOURSE',
                      'BR_FACTORED_WITHOUT_RECOURSE') THEN
    --called from the BR Remittance program

   -- To handle the case where the apply routine is called from the
   -- BR Remittance program, we refer to the underlying tables directly
   -- instead of accessing the view ar_open_trx_v. This is because
   -- as per the view definition of ar_open_trx_v  it will not return the
   -- 'reserved'(having reserved_type and reserved_value not null)
   -- transactions(Bill).

    IF arp_global.sysparam.pay_unrelated_invoices_flag = 'Y' THEN

        /* modified for tca uptake */
        SELECT
           ps.customer_id
         , ps.cust_trx_type_id
         , decode(ps.customer_id ,-1,NULL ,ps.due_date)
         , ps.invoice_currency_code
         , ps.exchange_rate
         , ct.trx_date
         , ps.gl_date
         , t.calc_discount_on_lines_flag
         , t.partial_discount_flag
         , ctt.allow_overapplication_flag
         , ctt.natural_application_only_flag
         , ctt.creation_sign
         , ps.payment_schedule_id
         , greatest(p_cr_gl_date,ps.gl_date,
                       decode(pg_profile_appln_gl_date_def,
                             'INV_REC_SYS_DT', sysdate, 'INV_REC_DT', ps.gl_date,
                               ps.gl_date)) gl_date
         , ps.term_id
         , ps.amount_due_original
         , ps.amount_line_items_original
         , arp_util.CurrRound(ps.amount_due_remaining,
                                 ps.invoice_currency_code)
         , ps.discount_taken_earned
         , ps.discount_taken_unearned
	 , ps.amount_line_items_original
	 , ps.amount_line_items_remaining
	 , ps.tax_original
 	 , ps.tax_remaining
         , ps.freight_original
         , ps.freight_remaining
         , ps.receivables_charges_charged
	 , ps.receivables_charges_remaining
         , su.location
        INTO
          p_customer_id ,
          p_cust_trx_type_id ,
          p_trx_due_date ,
          p_trx_currency_code,
          p_trx_exchange_rate,
          p_trx_date,
          p_trx_gl_date ,
          p_calc_discount_on_lines_flag ,
          p_partial_discount_flag ,
          p_allow_overappln_flag ,
          p_natural_appln_only_flag ,
          p_creation_sign ,
          l_applied_payment_schedule_id ,
          p_gl_date, --this is the application gl_date
          p_term_id ,
          p_amount_due_original,
          p_amount_line_items_original ,
          p_amount_due_remaining ,
          p_discount_taken_earned,
          p_discount_taken_unearned,
    	  p_line_items_original,
 	  p_line_items_remaining,
 	  p_tax_original,
	  p_tax_remaining,
          p_freight_original,
          p_freight_remaining,
          p_rec_charges_charged,
          p_rec_charges_remaining,
          l_location
       FROM
           ra_customer_trx  ct
         , ra_cust_trx_types  ctt
         , hz_cust_site_uses   su
         , ra_batch_sources bs
         , ar_lookups   lu
         , hz_cust_accounts cust
         , ra_terms   t
         , ar_payment_schedules  ps
         , ar_cons_inv           ci
      WHERE
           ps.class                    in ('CB','CM','DEP','DM','INV','BR')
       AND ps.selected_for_receipt_batch_id is null
       AND t.term_id(+)                = ps.term_id
       AND ct.customer_trx_id(+)       = ps.customer_trx_id
       AND bs.batch_source_id (+)      = ct.batch_source_id
       AND ctt.cust_trx_type_id(+)     = ps.cust_trx_type_id
       AND cust.cust_account_id(+)          = ps.customer_id
       AND su.site_use_id(+)           = ps.customer_site_use_id
       AND ps.class                    = lu.lookup_code
       AND ct.previous_customer_trx_id is null
       AND lu.lookup_type              = 'INV/CM'
       AND ci.cons_inv_id(+)           = ps.cons_inv_id
       AND ct.customer_trx_id =  p_customer_trx_id
       AND ps.invoice_currency_code =
                  decode(nvl(pg_profile_enable_cc,'N'),
                         'Y',ps.invoice_currency_code,p_cr_currency_code)
       AND ps.status=decode(p_show_closed_invoices,'Y',ps.status,'OP')
       AND ps.terms_sequence_number = p_installment
       ;
    ELSE --This is the case where pay_unrelated_invoices_flag is 'N'

        /* modified for tca uptake */
       SELECT
           ps.customer_id
         , ps.cust_trx_type_id
         , decode(ps.customer_id ,-1,NULL,ps.due_date)
         , ps.invoice_currency_code
         , ps.exchange_rate
         , ct.trx_date
         , ps.gl_date
         , t.calc_discount_on_lines_flag
         , t.partial_discount_flag
         , ctt.allow_overapplication_flag
         , ctt.natural_application_only_flag
         , ctt.creation_sign
         , ps.payment_schedule_id
         , greatest(p_cr_gl_date,ps.gl_date,
                       decode(pg_profile_appln_gl_date_def,
                             'INV_REC_SYS_DT', sysdate, 'INV_REC_DT', ps.gl_date,
                               ps.gl_date)) gl_date
         , ps.term_id
         , ps.amount_due_original
         , ps.amount_line_items_original
         , arp_util.CurrRound(ps.amount_due_remaining,
                                 ps.invoice_currency_code)
         , ps.discount_taken_earned
         , ps.discount_taken_unearned
	 , ps.amount_line_items_original
	 , ps.amount_line_items_remaining
	 , ps.tax_original
 	 , ps.tax_remaining
         , ps.freight_original
         , ps.freight_remaining
         , ps.receivables_charges_charged
	 , ps.receivables_charges_remaining
         , su.location
        INTO
          p_customer_id ,
          p_cust_trx_type_id ,
          p_trx_due_date ,
          p_trx_currency_code,
          p_trx_exchange_rate,
          p_trx_date,
          p_trx_gl_date ,
          p_calc_discount_on_lines_flag ,
          p_partial_discount_flag ,
          p_allow_overappln_flag ,
          p_natural_appln_only_flag ,
          p_creation_sign ,
          l_applied_payment_schedule_id ,
          p_gl_date, --this is the application gl_date
          p_term_id ,
          p_amount_due_original,
          p_amount_line_items_original ,
          p_amount_due_remaining ,
          p_discount_taken_earned,
          p_discount_taken_unearned,
    	  p_line_items_original,
 	  p_line_items_remaining,
 	  p_tax_original,
	  p_tax_remaining,
          p_freight_original,
          p_freight_remaining,
          p_rec_charges_charged,
          p_rec_charges_remaining,
          l_location
     FROM
           ra_customer_trx  ct
         , ra_cust_trx_types  ctt
         , hz_cust_site_uses   su
         , ra_batch_sources bs
         , ar_lookups   lu
         , hz_cust_accounts   cst
         , ra_terms   t
         , ar_payment_schedules  ps
         , ar_cons_inv           ci
     WHERE
           ps.class                    in ('CB','CM','DEP','DM','INV','BR')
       AND ps.selected_for_receipt_batch_id is null
       AND t.term_id(+)                = ps.term_id
       AND ct.customer_trx_id(+)       = ps.customer_trx_id
       AND bs.batch_source_id (+)      = ct.batch_source_id
       AND ctt.cust_trx_type_id(+)     = ps.cust_trx_type_id
       AND cst.cust_account_id(+)      = ps.customer_id
       AND su.site_use_id(+)           = ps.customer_site_use_id
       AND ps.class                    = lu.lookup_code
       AND ct.previous_customer_trx_id is null
       AND lu.lookup_type              = 'INV/CM'
       AND ci.cons_inv_id(+)           = ps.cons_inv_id
       AND ct.customer_trx_id =  p_customer_trx_id
       AND ps.invoice_currency_code =
                  decode(nvl(pg_profile_enable_cc,'N'),
                         'Y',ps.invoice_currency_code,p_cr_currency_code)
       AND ps.status=decode(p_show_closed_invoices,'Y',ps.status,'OP')
       AND ps.terms_sequence_number = p_installment
       AND ps.customer_id IN (
          SELECT rcr.related_cust_account_id
          FROM hz_cust_acct_relate rcr
          WHERE rcr.status='A' and
                rcr.cust_account_id= p_cr_customer_id
            and rcr.bill_to_flag = 'Y'
          UNION
          SELECT p_cr_customer_id
          FROM dual
          UNION
          SELECT rel.related_cust_account_id
          FROM ar_paying_relationships_v rel,
               hz_cust_accounts acc
          WHERE rel.party_id = acc.party_id
            AND acc.cust_account_id = p_cr_customer_id
            AND p_cr_date BETWEEN effective_start_date
                              AND effective_end_date
          );

    END IF;

  ELSE

     IF arp_global.sysparam.pay_unrelated_invoices_flag = 'Y' THEN
	IF nvl(p_called_from,'NONE') NOT IN ('AUTORECAPI2','AUTORECAPI') THEN
         /* modified for tca uptake */
        SELECT
          ot.customer_id ,
          ot.cust_trx_type_id ,
          ot.trx_due_date ,
          ot.invoice_currency_code,
          ot.trx_exchange_rate,
          ot.trx_date,
          ot.trx_gl_date ,
          ot.calc_discount_on_lines_flag ,
          ot.partial_discount_flag ,
          ot.allow_overapplication_flag ,
          ot.natural_application_only_flag ,
          ot.creation_sign ,
          ot.payment_schedule_id ,
          greatest(p_cr_gl_date,ot.trx_gl_date,
                   decode(pg_profile_appln_gl_date_def,
                          'INV_REC_SYS_DT', sysdate, 'INV_REC_DT', ot.trx_gl_date,
                           ot.trx_gl_date)) gl_date,
          ot.term_id ,
          ot.amount_due_original,
          ot.amount_line_items_original ,
          arp_util.CurrRound(ot.balance_due_curr_unformatted,
                             ot.invoice_currency_code) ,
          ot.discount_taken_earned,
          ot.discount_taken_unearned,
	  ot.amount_line_items_original,
	  ot.amount_line_items_remaining,
	  ot.tax_original,
 	  ot.tax_remaining,
          ot.freight_original,
          ot.freight_remaining,
          Null receivables_charges_charged,
	  ot.receivables_charges_remaining,
          ot.location
        INTO
          p_customer_id ,
          p_cust_trx_type_id ,
          p_trx_due_date ,
          p_trx_currency_code,
          p_trx_exchange_rate,
          p_trx_date,
          p_trx_gl_date ,
          p_calc_discount_on_lines_flag ,
          p_partial_discount_flag ,
          p_allow_overappln_flag ,
          p_natural_appln_only_flag ,
          p_creation_sign ,
          l_applied_payment_schedule_id ,
          p_gl_date, --this is the application gl_date
          p_term_id ,
          p_amount_due_original,
          p_amount_line_items_original ,
          p_amount_due_remaining ,
          p_discount_taken_earned,
          p_discount_taken_unearned,
      	  p_line_items_original,
 	  p_line_items_remaining,
 	  p_tax_original,
	  p_tax_remaining,
          p_freight_original,
          p_freight_remaining,
          p_rec_charges_charged,
          p_rec_charges_remaining,
          l_location
        FROM
          ar_open_trx_v ot
        WHERE
          ot.customer_trx_id =  p_customer_trx_id and
          ot.invoice_currency_code =
            DECODE(NVL(pg_profile_enable_cc,'N'),
                   'Y',ot.invoice_currency_code,p_cr_currency_code) and
          ot.status=decode(p_show_closed_invoices,'Y',ot.status,'OP') and
          ot.terms_sequence_number = p_installment;

     ELSE
	    ar_autorec_api.populate_cached_data( l_receipt_info_rec );

	    p_customer_id                 := l_receipt_info_rec.customer_id;
	    p_cust_trx_type_id            := l_receipt_info_rec.cust_trx_type_id;
	    p_trx_due_date                := l_receipt_info_rec.trx_due_date;
	    p_trx_currency_code           := l_receipt_info_rec.trx_currency_code;
	    p_trx_exchange_rate           := l_receipt_info_rec.trx_exchange_rate;
	    p_trx_date                    := l_receipt_info_rec.trx_date;
	    p_trx_gl_date                 := l_receipt_info_rec.trx_gl_date;
	    p_calc_discount_on_lines_flag := l_receipt_info_rec.calc_discount_on_lines_flag;
	    p_partial_discount_flag       := l_receipt_info_rec.partial_discount_flag;
	    p_allow_overappln_flag        := l_receipt_info_rec.allow_overappln_flag;
	    p_natural_appln_only_flag     := l_receipt_info_rec.natural_appln_only_flag;
	    p_creation_sign               := l_receipt_info_rec.creation_sign;
	    l_applied_payment_schedule_id := l_receipt_info_rec.applied_payment_schedule_id;
	    p_gl_date                     := l_receipt_info_rec.ot_gl_date;
	    p_term_id                     := l_receipt_info_rec.term_id;
	    p_amount_due_original         := l_receipt_info_rec.amount_due_original;
	    p_amount_line_items_original  := l_receipt_info_rec.amount_line_items_original;
	    p_amount_due_remaining        := l_receipt_info_rec.amount_due_remaining;
	    p_discount_taken_earned       := l_receipt_info_rec.discount_taken_earned;
	    p_discount_taken_unearned     := l_receipt_info_rec.discount_taken_unearned;
	    p_line_items_original         := l_receipt_info_rec.line_items_original;
	    p_line_items_remaining        := l_receipt_info_rec.line_items_remaining;
	    p_tax_original                := l_receipt_info_rec.tax_original;
	    p_tax_remaining               := l_receipt_info_rec.tax_remaining;
	    p_freight_original            := l_receipt_info_rec.freight_original;
	    p_freight_remaining           := l_receipt_info_rec.freight_remaining;
	    p_rec_charges_charged         := l_receipt_info_rec.rec_charges_charged;
	    p_rec_charges_remaining       := l_receipt_info_rec.rec_charges_remaining;
	    l_location                    := l_receipt_info_rec.location;
	END IF;
     ELSE
     --This is the case where pay_unrelated_invoices_flag is 'N'
         /* modified for tca uptake */
        SELECT
          ot.customer_id ,
          ot.cust_trx_type_id ,
          ot.trx_due_date ,
          ot.invoice_currency_code,
          ot.trx_exchange_rate,
          ot.trx_date,
          ot.trx_gl_date ,
          ot.calc_discount_on_lines_flag ,
          ot.partial_discount_flag ,
          ot.allow_overapplication_flag ,
          ot.natural_application_only_flag ,
          ot.creation_sign ,
          ot.payment_schedule_id ,
          greatest(p_cr_gl_date,ot.trx_gl_date,
                   decode(pg_profile_appln_gl_date_def,
                          'INV_REC_SYS_DT', sysdate, 'INV_REC_DT', ot.trx_gl_date,
                           ot.trx_gl_date)) gl_date,
          ot.term_id ,
          ot.amount_due_original,
          ot.amount_line_items_original ,
          arp_util.CurrRound(ot.balance_due_curr_unformatted,
                             ot.invoice_currency_code) ,
          ot.discount_taken_earned,
          ot.discount_taken_unearned,
  	  ot.amount_line_items_original,
	  ot.amount_line_items_remaining,
	  ot.tax_original,
 	  ot.tax_remaining,
          ot.freight_original,
          ot.freight_remaining,
          Null receivables_charges_charged,
	  ot.receivables_charges_remaining,
          ot.location
        INTO
          p_customer_id ,
          p_cust_trx_type_id ,
          p_trx_due_date ,
          p_trx_currency_code,
          p_trx_exchange_rate,
          p_trx_date,
          p_trx_gl_date ,
          p_calc_discount_on_lines_flag ,
          p_partial_discount_flag,
          p_allow_overappln_flag,
          p_natural_appln_only_flag,
          p_creation_sign,
          l_applied_payment_schedule_id,
          p_gl_date, --this is the defaulted application gl_date
          p_term_id,
          p_amount_due_original,
          p_amount_line_items_original,
          p_amount_due_remaining,
          p_discount_taken_earned,
          p_discount_taken_unearned,
      	  p_line_items_original,
 	  p_line_items_remaining,
 	  p_tax_original,
	  p_tax_remaining,
          p_freight_original,
          p_freight_remaining,
          p_rec_charges_charged,
          p_rec_charges_remaining,
          l_location
        FROM
          ar_open_trx_v ot
        WHERE
          ot.customer_trx_id =  p_customer_trx_id and
          ot.invoice_currency_code =
            DECODE(NVL(pg_profile_enable_cc,'N'),
                   'Y',ot.invoice_currency_code,p_cr_currency_code) and
          ot.status=decode(p_show_closed_invoices,'Y',ot.status,'OP') and
          ot.terms_sequence_number = p_installment and
          ot.customer_id IN (
          SELECT rcr.related_cust_account_id
          FROM hz_cust_acct_relate rcr
          WHERE rcr.status='A' and
                rcr.cust_account_id= p_cr_customer_id
            and rcr.bill_to_flag = 'Y'
          UNION
          SELECT p_cr_customer_id
          FROM dual
          UNION
          SELECT rel.related_cust_account_id
          FROM ar_paying_relationships_v rel,
               hz_cust_accounts acc
          WHERE rel.party_id = acc.party_id
            AND acc.cust_account_id = p_cr_customer_id
            AND p_cr_date BETWEEN effective_start_date
                              AND effective_end_date
          );

     END IF;

  END IF;

 --If the defaulted payment_schedule_id does not match the
 --applied_ps_id entered by the user, then raise error.
 IF p_applied_payment_schedule_id IS NOT NULL THEN
   IF l_applied_payment_schedule_id <>
                             p_applied_payment_schedule_id THEN
      FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_PS_ID_X_INVALID');
      FND_MSG_PUB.Add;
      p_return_status := FND_API.G_RET_STS_ERROR ;
   END IF;
 ELSE
      p_applied_payment_schedule_id := l_applied_payment_schedule_id;
 END IF;

  --Derive site_use_id from the Location
  --this could be a DRAWEE or BILL_TO site_use_id
    OPEN get_site_use_id;
    FETCH get_site_use_id INTO   p_bill_to_site_use_id;
    CLOSE get_site_use_id;


  --If line number has been specified and you have a customer_trx_id,(defaulted or entered)
  --then get the Line information
  --If the customer_trx_id enterd by the user was invalid then this section of the code
  --will not get executed as the control goes directly to the no_data_found exception

  --we check for the return status so that we are sure that the payment schedule id is valid
 IF p_return_status = FND_API.G_RET_STS_SUCCESS AND
    p_customer_trx_id IS NOT NULL AND
    p_llca_type	  IS NULL	  AND
    p_customer_trx_line_id IS NOT NULL THEN

    p_trx_line_amount :=
        Get_trx_Line_amount(p_customer_trx_id,
                            p_applied_payment_schedule_id,
                            p_customer_trx_line_id,
                            l_line_amt_return_status
                            );
     IF l_line_amt_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
    p_trx_line_amount := arp_util.CurrRound(p_trx_line_amount,
					    p_trx_currency_code);
 END IF;
     --bug 6660834 check is not required if called from autoreceipts
    IF NVL(p_called_from,'NONE')  NOT IN ('AUTORECAPI','AUTORECAPI2') THEN

 --Also check if the payment_schedule of the transaction has already been
 --applied once to the current_receipt, if yes then raise error
    BEGIN
      IF p_customer_trx_line_id IS NULL THEN
        select 'Y'
        into   l_found
        from   ar_receivable_applications rap
        where  rap.payment_schedule_id = p_cr_payment_schedule_id
        and    rap.applied_payment_schedule_id = p_applied_payment_schedule_id
        and    applied_customer_trx_line_id is NULL
	and    rap.display = 'Y'
        and    rap.status = 'APP';
      ELSE
        select 'Y'
        into   l_found
        from   ar_receivable_applications rap
        where  rap.payment_schedule_id = p_cr_payment_schedule_id
        and    rap.applied_payment_schedule_id = p_applied_payment_schedule_id
        and    rap.applied_customer_trx_line_id = p_customer_trx_line_id
        and    rap.display = 'Y'
        and    rap.status = 'APP';
      END IF;
      if l_found = 'Y' then
        raise too_many_rows;
      end if;

    EXCEPTION
      when no_data_found then
        null;
      when too_many_rows then
        FND_MESSAGE.SET_NAME('AR', 'AR_RW_PAID_INVOICE_TWICE' );
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR ;
    END;
    END IF;

ELSE --case when p_customer_trx_id is null
  --no further validation done in the validation routines for customer_trx_id
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_NULL');
  FND_MSG_PUB.Add;
  p_return_status := FND_API.G_RET_STS_ERROR ;

END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_Trx_Info: ' || 'p_applied_payment_schedule_id : '||to_char(p_applied_payment_schedule_id));
     arp_util.debug('Default_Trx_Info: ' || 'p_bill_to_site_use_id  : '||to_char(p_bill_to_site_use_id));
     arp_util.debug('Default_Trx_Info: ' || 'p_calc_discount_on_lines_flag  : '||p_calc_discount_on_lines_flag);
     arp_util.debug('Default_Trx_Info: ' || 'p_partial_discount_flag        : '||p_partial_discount_flag );
     arp_util.debug('Default_Trx_Info: ' || 'p_allow_overappln_flag         : '||p_allow_overappln_flag);
     arp_util.debug('Default_Trx_Info: ' || 'p_natural_appln_only_flag      : '||p_natural_appln_only_flag);
     arp_util.debug('Default_Trx_Info: ' || 'p_creation_sign                : '||p_creation_sign);
   arp_util.debug('Default_Trx_Info ()-');
END IF;
EXCEPTION
  WHEN no_data_found THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_Trx_Info : No data found ');
    END IF;
   IF ar_receipt_api_pub.Original_application_info.customer_trx_id IS NOT NULL THEN

    IF ar_receipt_api_pub.Original_application_info.installment IS NOT NULL THEN
     p_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_ID_INST_INVALID');
     FND_MSG_PUB.ADD;
    ELSE
     p_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
     FND_MSG_PUB.ADD;
    END IF;

   ELSIF ar_receipt_api_pub.Original_application_info.trx_number IS NOT NULL THEN

    IF ar_receipt_api_pub.Original_application_info.installment IS NOT NULL THEN
     p_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_INST_INVALID');
     FND_MSG_PUB.ADD;
    ELSE
     p_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_INVALID');
     FND_MSG_PUB.ADD;
    END IF;

   ELSIF ar_receipt_api_pub.Original_application_info.applied_payment_schedule_id IS NOT NULL THEN
     p_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
     FND_MSG_PUB.ADD;
   END IF;
 WHEN others THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: Default_Trx_Info()');
    END IF;
    raise;
END Default_Trx_Info;

PROCEDURE Default_Receipt_Info(
                 p_cash_receipt_id           IN ar_cash_receipts.cash_receipt_id%TYPE,
                 p_cr_gl_date                OUT NOCOPY DATE,
                 p_cr_customer_id            OUT NOCOPY ar_cash_receipts.pay_from_customer%TYPE,
                 p_cr_amount                 OUT NOCOPY ar_cash_receipts.amount%TYPE,
                 p_cr_currency_code          OUT NOCOPY VARCHAR2,
                 p_cr_exchange_rate          OUT NOCOPY NUMBER,
                 p_cr_cust_site_use_id       OUT NOCOPY ar_cash_receipts.customer_site_use_id%TYPE,
                 p_cr_date                   OUT NOCOPY ar_cash_receipts.receipt_date%TYPE,
                 p_cr_unapp_amount           OUT NOCOPY NUMBER,
                 p_cr_payment_schedule_id    OUT NOCOPY NUMBER,
                 p_remittance_bank_account_id OUT NOCOPY NUMBER,
                 p_receipt_method_id         OUT NOCOPY  NUMBER,
                 p_return_status             OUT NOCOPY VARCHAR2
                 )  IS

BEGIN
  p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_Receipt_Info ()+');
   END IF;
  IF p_cash_receipt_id IS NOT NULL THEN
   BEGIN
    SELECT cr.pay_from_customer,
           crh.gl_date,
           cr.amount,
           cr.customer_site_use_id,
           cr.receipt_date,
           cr.currency_code,
           cr.exchange_rate,
           ps.payment_schedule_id,
           ba.bank_acct_use_id,
           cr.receipt_method_id
    INTO   p_cr_customer_id,
           p_cr_gl_date,
           p_cr_amount,
           p_cr_cust_site_use_id,
           p_cr_date,
           p_cr_currency_code,
           p_cr_exchange_rate,
           p_cr_payment_schedule_id,
           p_remittance_bank_account_id,
           p_receipt_method_id
    FROM   ar_cash_receipts cr,
           ar_cash_receipt_history crh,
           ar_payment_schedules ps,
           ce_bank_acct_uses ba
    WHERE  cr.remit_bank_acct_use_id = ba.bank_acct_use_id and
           cr.cash_receipt_id = crh.cash_receipt_id and
           crh.first_posted_record_flag = 'Y'     and     /* bug 3333680  */
           cr.cash_receipt_id = p_cash_receipt_id and
           cr.cash_receipt_id = ps.cash_receipt_id and
           crh.status IN ('CONFIRMED','CLEARED', 'REMITTED','APPROVED',
               decode(crh.factor_flag,'Y','RISK_ELIMINATED')); /* Risk Eliminated condition added
                                                                         for bug 2215047*/
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      BEGIN
       SELECT cr.pay_from_customer,
           crh.gl_date,
           cr.amount,
           cr.customer_site_use_id,
           cr.receipt_date,
           cr.currency_code,
           cr.exchange_rate,
           ps.payment_schedule_id,
           ba.bank_acct_use_id,
           cr.receipt_method_id
      INTO   p_cr_customer_id,
           p_cr_gl_date,
           p_cr_amount,
           p_cr_cust_site_use_id,
           p_cr_date,
           p_cr_currency_code,
           p_cr_exchange_rate,
           p_cr_payment_schedule_id,
           p_remittance_bank_account_id,
           p_receipt_method_id
      FROM   ar_cash_receipts cr,
           ar_cash_receipt_history crh,
           ar_payment_schedules ps,
           ce_bank_acct_uses ba
       WHERE  cr.remit_bank_acct_use_id = ba.bank_acct_use_id and
           cr.cash_receipt_id = crh.cash_receipt_id and
           crh.first_posted_record_flag = 'N'       and
           cr.cash_receipt_id = p_cash_receipt_id   and
           cr.cash_receipt_id = ps.cash_receipt_id  and
           crh.status  = 'APPROVED';
      EXCEPTION
      WHEN no_data_found THEN
       IF ar_receipt_api_pub.Original_application_info.cash_receipt_id IS NOT NULL THEN
         p_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_CASH_RCPT_ID_INVALID');
         FND_MSG_PUB.ADD;
       ELSIF  ar_receipt_api_pub.Original_application_info.receipt_number IS NOT NULL THEN
         p_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_RCPT_NUM_INVALID');
         FND_MSG_PUB.ADD;
       END IF;
      WHEN others THEN
       IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('EXCEPTION: Default_Receipt_Info()');
       END IF;
       raise;
      END;
    WHEN others THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('EXCEPTION: Default_Receipt_Info()');
     END IF;
     raise;
    END;

    SELECT SUM(NVL(ra.amount_applied,0))
    INTO   p_cr_unapp_amount
    FROM   ar_receivable_applications ra
    WHERE  ra.status = 'UNAPP'
    AND    ra.cash_receipt_id = p_cash_receipt_id;

  ELSE
   --if the receipt number is also null raise error here
   --otherwise the error would have been raised while defaulting the cash receipt id from the
   --receipt number
   IF ar_receipt_api_pub.Original_application_info.receipt_number IS NULL THEN
    FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_CASH_RCPT_ID_NULL');
    FND_MSG_PUB.ADD;
    p_return_status := FND_API.G_RET_STS_ERROR ;
   END IF;

  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_Receipt_Info: ' || ' p_return_status :'||p_return_status);
     arp_util.debug('Default_Receipt_Info ()-');
  END IF;
EXCEPTION
  WHEN no_data_found THEN
  IF ar_receipt_api_pub.Original_application_info.cash_receipt_id IS NOT NULL THEN
    p_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_CASH_RCPT_ID_INVALID');
    FND_MSG_PUB.ADD;
  ELSIF  ar_receipt_api_pub.Original_application_info.receipt_number IS NOT NULL THEN
    p_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MESSAGE.SET_NAME( 'AR','AR_RAPI_RCPT_NUM_INVALID');
    FND_MSG_PUB.ADD;
  END IF;
  WHEN others THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: Default_Receipt_Info()');
    END IF;
    raise;

END Default_Receipt_Info;

PROCEDURE Default_apply_date(p_receipt_date     IN DATE,
                             p_trx_date         IN DATE,
                             p_apply_date       IN OUT NOCOPY DATE) IS
BEGIN

  --
  --The apply_date should be deafaulted to the greatest of the
  --sysdate,receipt_date and trx_date.

   /* 7693172 - trunc'd return value to insure that timestamp
      is not recorded in RA table.  This could cause problems
      with discount calculations */
   IF p_apply_date IS NULL THEN
      p_apply_date := TRUNC(GREATEST(sysdate,
                               GREATEST(NVL(p_receipt_date,sysdate),
                                        NVL(p_trx_date,sysdate))));
   END IF;


END Default_apply_date;

PROCEDURE Default_customer_trx_id(
                          p_customer_trx_id IN OUT NOCOPY NUMBER,
                          p_trx_number  IN VARCHAR,
                          p_return_status OUT NOCOPY VARCHAR2
                           ) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_customer_trx_id ()+');
  END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_customer_trx_id IS NULL THEN
     IF  p_trx_number IS NOT NULL THEN
       BEGIN
         SELECT customer_trx_id
         INTO   p_customer_trx_id
         FROM   ra_customer_trx
         WHERE   trx_number = p_trx_number;
       EXCEPTION
         WHEN no_data_found THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_INVALID');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR ;
       END;
     END IF;

   ELSE

      IF p_trx_number IS NOT NULL
      THEN
       --give a warning message to indicate that the trx number
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_IGN');
         FND_MSG_PUB.Add;
       END IF;
     END IF;
   END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_customer_trx_id ()-');
 END IF;
EXCEPTION
  WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Default_customer_trx_id()', G_MSG_UERROR);
   END IF;
END Default_customer_trx_id;
/* Bug 5284890 */
PROCEDURE Default_group_id( p_customer_trx_id IN NUMBER,
                            p_group_id        IN VARCHAR2,
                            p_llca_type       IN VARCHAR2,
                            p_return_status OUT NOCOPY VARCHAR2
                           ) IS
l_count         Number;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_group_id ()+');
  END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;

	select count(1)
	  into l_count
	from ra_customer_trx_lines line
	where line.customer_Trx_id = p_customer_trx_id
	and line.line_type = 'LINE'
	and line.source_data_key4 = p_group_id
	and rownum = 1;

             If nvl(l_count,0) = 0   AND
                nvl(p_llca_type,'S') = 'G'
	     THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_GROUP_ID_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
             END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_group_id ()+');
  END IF;
END ;
/* Bug fix 3435834
   New procedure created for defaulting customer_trx_line_id */
PROCEDURE Default_customer_trx_line_id(
                          p_customer_trx_id IN OUT NOCOPY NUMBER,
                          p_customer_trx_line_id IN OUT NOCOPY NUMBER,
                          p_line_number  IN NUMBER,
			  p_llca_type	 IN VARCHAR2,
                          p_return_status OUT NOCOPY VARCHAR2
                           ) IS
cursor c1 (p_cust_trx_id in number) is
select * from ar_llca_trx_lines_gt
where customer_trx_id = p_cust_trx_id;
l_cust_trx_line_id	Number;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_customer_trx_line_id ()+');
  END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_customer_trx_line_id IS NOT NULL AND
      p_line_number IS NOT NULL
   THEN
        --give a warning message to indicate that the line number
        --entered by the user has been ignored.
          IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
           THEN
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_LINE_NUM_IGN');
             FND_MSG_PUB.Add;
          END IF;
   END IF;

 If p_llca_type IS NULL THEN
   IF p_customer_trx_id IS NOT NULL THEN
     IF p_customer_trx_line_id IS NULL THEN
        IF  p_line_number IS NOT NULL THEN
           BEGIN
             SELECT customer_trx_line_id
             INTO   p_customer_trx_line_id
             FROM   ra_customer_trx_lines
             WHERE  customer_trx_id = p_customer_trx_id
               AND   line_number = p_line_number
               AND   line_type =   'LINE';
           EXCEPTION
             WHEN no_data_found THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_LINE_NO_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
           END;
        END IF;
    END IF;
   ELSE
    /* If the customer_trx_id is not provided and customer_trx_line_id is
       provided, derive the customer_trx_id */
     IF p_customer_trx_line_id IS NOT NULL THEN
        BEGIN
             SELECT customer_trx_id
             INTO   p_customer_trx_id
             FROM   ra_customer_trx_lines
             WHERE  customer_trx_line_id = p_customer_trx_line_id
               AND  line_type =   'LINE';
        EXCEPTION
             WHEN no_data_found THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_LINE_ID_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
        END;
     END IF;
   END IF;
 Else  --LLCA

  If p_llca_type not in ('S','L','G')
  Then
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_INVALID_LLCA_TYPE');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
  END IF;

  If p_llca_type = 'L'
  Then
	 For i in C1(p_customer_trx_id)
	 Loop
	  IF i.customer_trx_line_id IS NULL  Then
  	    If i.line_number  is not null
	    Then
	     BEGIN
	      SELECT customer_trx_line_id
	      INTO   l_cust_trx_line_id
	      FROM   ra_customer_trx_lines
	      WHERE  customer_trx_id = p_customer_trx_id
	       AND   line_number = i.line_number
	       AND   line_type =   'LINE';

	      Update ar_llca_trx_lines_gt
	       set    customer_trx_line_id = l_cust_trx_line_id
	       where customer_trx_id = p_customer_trx_id
	       and   line_number     = i.line_number;
              EXCEPTION
	        WHEN no_data_found THEN
	 	 ar_receipt_lib_pvt.populate_errors_gt (
		  p_customer_trx_id      => p_customer_trx_id,
		  p_customer_trx_line_id => i.customer_trx_line_id,
  	          p_error_message =>
		   arp_standard.fnd_message('AR_RAPI_TRX_LINE_NO_INVALID'),
		  p_invalid_value	 => i.line_number
		  );
		  p_return_status := FND_API.G_RET_STS_ERROR ;
	       END;
	      End If; /* LINE_NUMBER */
	    Else
		BEGIN
	          SELECT customer_trx_line_id
	          INTO   l_cust_trx_line_id
	          FROM   ra_customer_trx_lines
	          WHERE  customer_trx_id = p_customer_trx_id
	            AND  customer_trx_line_id = i.customer_trx_line_id
	            AND  line_type =   'LINE';
	        EXCEPTION
	         WHEN no_data_found THEN
	 	 ar_receipt_lib_pvt.populate_errors_gt (
		  p_customer_trx_id      => p_customer_trx_id,
		  p_customer_trx_line_id => i.customer_trx_line_id,
  	          p_error_message =>
		   arp_standard.fnd_message('AR_RAPI_TRX_LINE_ID_INVALID'),
 		  p_invalid_value	 =>i.customer_trx_line_id
		  );
                      p_return_status := FND_API.G_RET_STS_ERROR ;
		  END;
	     END IF;

	     If i.line_amount IS NULL  AND
	        i.tax_amount  IS NULL  AND
	        i.amount_applied is NULL AND
		i.amount_applied_from is NULL AND  -- Bug 6931978 - Cross Currency App
	        i.customer_trx_line_id is NOT NULL
	     THEN
	     	  ar_receipt_lib_pvt.populate_errors_gt (
		  p_customer_trx_id      => p_customer_trx_id,
		  p_customer_trx_line_id => i.customer_trx_line_id,
  	          p_error_message =>
		   arp_standard.fnd_message('AR_RAPI_LTFC_AMT_NULL'),
  		  p_invalid_value	 => NULL
		  );
                  p_return_status := FND_API.G_RET_STS_ERROR ;
	     END IF;
	End Loop;
END IF;
END If;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_customer_trx_line_id ()-');
 END IF;
EXCEPTION
  WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Default_customer_trx_line_id()', G_MSG_UERROR);
   END IF;
END Default_customer_trx_line_id;


PROCEDURE Default_cash_receipt_id(
                         p_cash_receipt_id IN OUT NOCOPY NUMBER,
                         p_receipt_number IN VARCHAR2,
                         p_return_status   OUT NOCOPY VARCHAR2
                         ) IS
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_cash_receipt_id ()+');
 END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;
     arp_util.debug('Default_appln_ids:CHECK 2' || 'p_receipt_number             :'||to_char(p_receipt_number));
   IF p_cash_receipt_id IS NULL
    THEN
      BEGIN
        SELECT cash_receipt_id
        INTO   p_cash_receipt_id
        FROM   ar_cash_receipts
        WHERE  receipt_number = p_receipt_number;
      EXCEPTION
        WHEN no_data_found THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_NUM_INVALID');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR ;
        WHEN too_many_rows THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_NUM_INVALID');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR ;
      END;

   ELSE
     IF p_receipt_number IS NOT NULL
      THEN
       --give a warning message to indicate that the receipt number
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_NUM_IGN');
         FND_MSG_PUB.Add;
       END IF;
     END IF;
   END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Default_cash_receipt_id ()-');
 END IF;
EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Default_cash_receipt_id()');
   END IF;
END Default_cash_receipt_id;

PROCEDURE Default_appln_ids(
                p_cash_receipt_id   IN OUT NOCOPY NUMBER,
                p_receipt_number    IN VARCHAR2,
                p_customer_trx_id   IN OUT NOCOPY NUMBER,
                p_trx_number        IN VARCHAR2,
                p_customer_trx_line_id  IN OUT NOCOPY NUMBER, /* Bug fix 3435834 */
                p_line_number       IN NUMBER,
                p_installment       IN OUT NOCOPY NUMBER,
                p_applied_payment_schedule_id   IN NUMBER,
	    	p_llca_type	    IN VARCHAR2,
	    	p_group_id          IN VARCHAR2,   /* Bug 5284890 */
                p_return_status     OUT NOCOPY VARCHAR2 ) IS
CURSOR payment_schedule IS
SELECT customer_trx_id,terms_sequence_number
FROM   ar_payment_schedules
WHERE  payment_schedule_id = p_applied_payment_schedule_id and
       payment_schedule_id >0 and
       class in ('INV','DM','DEP','CB','CM','BR');
 CURSOR install_number IS
 SELECT terms_sequence_number
 FROM   ar_payment_schedules
 WHERE  customer_trx_id = p_customer_trx_id;
l_customer_trx_id  NUMBER;
l_installment      NUMBER;
p_return_status_lines  VARCHAR2(100); /* Bug fix 3435834 */
p_return_status_group  VARCHAR2(100); /* Bug 5284890 */

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_appln_ids ()+ ');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

   -- First get a valid value for the customer_trx_id
  IF  p_trx_number  IS NOT NULL THEN
    Default_customer_trx_id(p_customer_trx_id ,
                            p_trx_number ,
                            p_return_status);
  END IF;

  /* Bug fix 3435834 */
  /* Default the customer_trx_line_id  and customer_trx_id*/
    Default_Customer_trx_line_id(p_customer_trx_id,
                                 p_customer_trx_line_id,
                                 p_line_number,
				 p_llca_type,
                                 p_return_status_lines);

  /* Group logic will be implement via bug 5440167
  IF  Nvl(p_llca_type,'S') = 'G'
  THEN
        Default_group_id (p_customer_trx_id,
                          p_group_id,
		          p_llca_type,
                          p_return_status_group);
  END If; */

--If the customer_trx_id id is null, use the entered aplied_payment_schedule_id
--for deriving the customer_trx_id and installment.
   IF p_applied_payment_schedule_id IS NOT NULL THEN
     OPEN payment_schedule;
     FETCH payment_schedule INTO l_customer_trx_id, l_installment;
      IF payment_schedule%NOTFOUND  THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR ;
      END IF;
     CLOSE payment_schedule;

    IF  p_return_status = FND_API.G_RET_STS_SUCCESS  THEN

      IF nvl(p_customer_trx_id,nvl(l_customer_trx_id,-99)) = nvl(l_customer_trx_id,-99) THEN
        p_customer_trx_id := l_customer_trx_id;
      END IF;

      IF nvl(p_installment,nvl(l_installment,-99))  =  nvl(l_installment,-99) THEN
         p_installment := l_installment;
      END IF;

    END IF;
   ELSE
     --default the installment from the customer_trx_id if not entered
     IF p_customer_trx_id IS NOT NULL THEN
       IF p_installment IS NULL THEN
         BEGIN
          SELECT terms_sequence_number
          INTO   p_installment
          FROM   ar_payment_schedules
          WHERE  customer_trx_id = p_customer_trx_id;
         EXCEPTION
          WHEN no_data_found THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
          WHEN too_many_rows THEN
	   If p_llca_type is Null
	   THEN
	           FND_MESSAGE.SET_NAME('AR','AR_RAPI_INSTALL_NULL');
	           FND_MSG_PUB.Add;
	   Else
   	           FND_MESSAGE.SET_NAME('AR','AR_LL_INSTALL_NOT_ALLOWED');
	           FND_MSG_PUB.Add;
	   End If;
		   p_return_status := FND_API.G_RET_STS_ERROR;
         END;
       END IF;
     END IF;
   END IF;

  -- You cannot apply a receipt to the installment transactions at line-level.
  If p_applied_payment_schedule_id IS NOT NULL and
     p_llca_type is NOT NULL
  Then
     Begin
      select terms_sequence_number into l_installment
      from ar_payment_schedules
      where customer_trx_id = p_customer_trx_id;
     Exception
          WHEN no_data_found THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
          WHEN too_many_rows THEN
           FND_MESSAGE.SET_NAME('AR','AR_LL_INSTALL_NOT_ALLOWED');
           FND_MSG_PUB.Add;
	   p_return_status := FND_API.G_RET_STS_ERROR;
     END;
   End If;

   --Derive cash_receipt_id from receipt_number
   Default_cash_receipt_id(
                       p_cash_receipt_id ,
                       p_receipt_number ,
                       p_return_status
                         );

  /* Bug fix 3435834 */
  IF p_return_status_lines = FND_API.G_RET_STS_ERROR OR
     p_return_status_group = FND_API.G_RET_STS_ERROR OR
     p_return_status = FND_API.G_RET_STS_ERROR THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_appln_ids: ' || '****Defaulted Value for the application ids****');
     arp_util.debug('Default_appln_ids: ' || 'p_cash_receipt_id             :'||to_char(p_cash_receipt_id));
     arp_util.debug('Default_appln_ids: ' || 'p_customer_trx_id             :'||to_char(p_customer_trx_id));
     arp_util.debug('Default_appln_ids: ' || 'p_installment                 :'||to_char(p_installment));
     arp_util.debug('Default_appln_ids: ' || 'p_applied_payment_schedule_id :'||to_char(p_applied_payment_schedule_id));
     arp_util.debug('Default_appln_ids ()- ');
  END IF;
EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Default_appln_ids()');
   END IF;
   raise;
END Default_appln_ids;

PROCEDURE Default_application_info(
              p_cash_receipt_id              IN ar_cash_receipts.cash_receipt_id%TYPE,
              p_cr_gl_date                   OUT NOCOPY DATE,
              p_cr_date                      OUT NOCOPY DATE,
              p_cr_amount                    OUT NOCOPY ar_cash_receipts.amount%TYPE,
              p_cr_unapp_amount              OUT NOCOPY NUMBER,
              p_cr_currency_code             OUT NOCOPY VARCHAR2,
              p_customer_trx_id              IN ra_customer_trx.customer_trx_id%TYPE,
              p_installment                  IN OUT NOCOPY NUMBER,
              p_show_closed_invoices         IN VARCHAR2,
              p_customer_trx_line_id         IN NUMBER,
              p_trx_due_date                 OUT NOCOPY DATE,
              p_trx_currency_code            OUT NOCOPY VARCHAR2,
              p_trx_date                     OUT NOCOPY DATE,
              p_trx_gl_date                   OUT NOCOPY DATE,
              p_apply_gl_date              IN OUT NOCOPY DATE,
              p_calc_discount_on_lines_flag   OUT NOCOPY VARCHAR2,
              p_partial_discount_flag         OUT NOCOPY VARCHAR2,
              p_allow_overappln_flag          OUT NOCOPY VARCHAR2,
              p_natural_appln_only_flag       OUT NOCOPY VARCHAR2,
              p_creation_sign                 OUT NOCOPY VARCHAR2,
              p_cr_payment_schedule_id        OUT NOCOPY NUMBER,
              p_applied_payment_schedule_id  IN OUT NOCOPY NUMBER,
              p_term_id                       OUT NOCOPY NUMBER,
              p_amount_due_original           OUT NOCOPY NUMBER,
              p_amount_due_remaining          OUT NOCOPY NUMBER,
              p_trx_line_amount               OUT NOCOPY NUMBER,
              p_discount                   IN OUT NOCOPY NUMBER,
              p_apply_date                 IN OUT NOCOPY DATE,
              p_discount_max_allowed          OUT NOCOPY NUMBER,
              p_discount_earned_allowed       OUT NOCOPY NUMBER,
              p_discount_earned               OUT NOCOPY NUMBER,
              p_discount_unearned             OUT NOCOPY NUMBER,
              p_new_amount_due_remaining      OUT NOCOPY NUMBER,
              p_remittance_bank_account_id    OUT NOCOPY NUMBER,
              p_receipt_method_id             OUT NOCOPY NUMBER,
              p_amount_applied             IN OUT NOCOPY NUMBER,
              p_amount_applied_from        IN OUT NOCOPY NUMBER,
              p_trans_to_receipt_rate      IN OUT NOCOPY NUMBER,
	      p_llca_type		      IN VARCHAR2,
	      p_line_amount		   IN OUT NOCOPY NUMBER,
	      p_tax_amount		   IN OUT NOCOPY NUMBER,
	      p_freight_amount		   IN OUT NOCOPY NUMBER,
	      p_charges_amount		   IN OUT NOCOPY NUMBER,
	      p_line_discount              IN OUT NOCOPY NUMBER,
	      p_tax_discount               IN OUT NOCOPY NUMBER,
	      p_freight_discount           IN OUT NOCOPY NUMBER,
	      p_line_items_original	      OUT NOCOPY NUMBER,
	      p_line_items_remaining	      OUT NOCOPY NUMBER,
	      p_tax_original		      OUT NOCOPY NUMBER,
	      p_tax_remaining		      OUT NOCOPY NUMBER,
	      p_freight_original	      OUT NOCOPY NUMBER,
	      p_freight_remaining	      OUT NOCOPY NUMBER,
	      p_rec_charges_charged	      OUT NOCOPY NUMBER,
	      p_rec_charges_remaining	      OUT NOCOPY NUMBER,
              p_called_from                IN  VARCHAR2,
              p_return_status              OUT NOCOPY VARCHAR2
               ) IS

l_cr_customer_id   NUMBER;
l_customer_id  NUMBER;
l_acct_amount_due_remaining  NUMBER;
l_trx_exchange_rate NUMBER;
l_cr_exchange_rate  NUMBER;
l_receipt_date    DATE;
l_trx_date        DATE;
l_discount_taken_earned NUMBER;
l_discount_taken_unearned  NUMBER;
l_amount_line_items_original  NUMBER;
l_bill_to_site_use_id  NUMBER;--this is to store the bill_to_site_use_id on trx.
l_cr_cust_site_use_id     NUMBER;--this is to store the site_use_id on the receipt
l_cust_trx_type_id      NUMBER;
l_def_cr_return_status  VARCHAR2(1);
l_def_trx_return_status VARCHAR2(1);
l_def_amt_return_status VARCHAR2(1);
l_def_rate_return_status VARCHAR2(1);
l_def_aaf_return_status VARCHAR2(1);
--local variables used for OUT NOCOPY parameters
l_calc_discount_on_lines_flag   VARCHAR2(1);
l_partial_discount_flag         VARCHAR2(1);
l_allow_overappln_flag          VARCHAR2(1);
l_natural_appln_only_flag       VARCHAR2(1);
l_creation_sign                 VARCHAR2(1);
l_amount_due_original           NUMBER;
l_amount_due_remaining          NUMBER;
l_term_id                       NUMBER;
l_trx_line_amount               NUMBER;
l_cr_unapp_amount               NUMBER;
l_cr_gl_date                    DATE;
l_trx_gl_date                   DATE;
l_applied_payment_schedule_id   NUMBER;
l_cr_date                       DATE;
l_cr_currency_code              VARCHAR2(15);
l_trx_currency_code             VARCHAR2(15);
l_gl_date                       DATE;
--bug 3172587
l_return  BOOLEAN;
l_default_gl_date  DATE;
l_defaulting_rule_used VARCHAR2(100);
l_error_message  VARCHAR2(200);

l_receipt_info_rec               AR_AUTOREC_API.receipt_info_rec;

--LLCA
l_line_items_original   NUMBER;
l_line_items_remaining  NUMBER;
l_tax_original		NUMBER;
l_tax_remaining		NUMBER;
l_freight_original	NUMBER;
l_freight_remaining	NUMBER;
l_rec_charges_charged	NUMBER;
l_rec_charges_remaining NUMBER;
l_val_llca_return_status        VARCHAR2(1);
l_val_llca_msg_data	        VARCHAR2(2000);
l_val_llca_msg_count		NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_application_info ()+');
       arp_util.debug('Default_application_info: ' || 'p_discount = '||p_discount );
    END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF NVL(p_called_from,'NONE') IN ('AUTORECAPI','AUTORECAPI2') THEN

    	ar_autorec_api.populate_cached_data( l_receipt_info_rec );

	l_cr_customer_id              := l_receipt_info_rec.customer_id;
	l_cr_gl_date 		      := l_receipt_info_rec.cr_gl_date;
	p_cr_amount		      := l_receipt_info_rec.cr_amount;
	l_cr_cust_site_use_id 	      := l_receipt_info_rec.cust_site_use_id;
	p_cr_date		      := l_receipt_info_rec.receipt_date;
	l_cr_currency_code            := l_receipt_info_rec.cr_currency_code;
	l_cr_exchange_rate            := l_receipt_info_rec.cr_exchange_rate;
	p_cr_payment_schedule_id      := l_receipt_info_rec.cr_payment_schedule_id;
	p_remittance_bank_account_id  := l_receipt_info_rec.remittance_bank_account_id;
	p_receipt_method_id           := l_receipt_info_rec.receipt_method_id;

        --when the call is from autoreceipts then UNAPP amount is same as
	--that of receipt amount
        l_cr_unapp_amount       := p_cr_amount;
	--set the status to true to continue further process
	l_def_cr_return_status  := FND_API.G_RET_STS_SUCCESS;

	IF PG_DEBUG in ('Y', 'C') THEN
	    arp_util.debug('Setting the values call from  AUTORECAPI ');
	    arp_util.debug('l_cr_gl_date '||l_cr_gl_date);
	    arp_util.debug('l_cr_customer_id '||l_cr_customer_id);
	    arp_util.debug('p_cr_amount '||p_cr_amount);
	    arp_util.debug('l_cr_cust_site_use_id '||l_cr_cust_site_use_id);
	    arp_util.debug('p_cr_date '||p_cr_date);
	    arp_util.debug('l_cr_currency_code '||l_cr_currency_code);
	    arp_util.debug('l_cr_exchange_rate '||l_cr_exchange_rate);
	    arp_util.debug('p_cr_payment_schedule_id '||p_cr_payment_schedule_id);
	    arp_util.debug('p_remittance_bank_account_id '||p_remittance_bank_account_id);
	    arp_util.debug('p_receipt_method_id '||p_receipt_method_id);
	END IF;
    ELSE
    Default_Receipt_Info(
                 p_cash_receipt_id ,
                 l_cr_gl_date ,
                 l_cr_customer_id ,
                 p_cr_amount ,
                 l_cr_currency_code,
                 l_cr_exchange_rate,
                 l_cr_cust_site_use_id ,
                 l_cr_date ,
                 l_cr_unapp_amount ,
                 p_cr_payment_schedule_id ,
                 p_remittance_bank_account_id,
                 p_receipt_method_id,
                 l_def_cr_return_status );
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_application_info: ' || 'Default_Receipt_Info return status = '||l_def_cr_return_status);
      END IF;

      /* Bug 4038708 */
      IF(l_cr_customer_id is NULL) THEN
      FND_MESSAGE.SET_NAME( 'AR','AR_RW_REC_NO_CT');
      FND_MSG_PUB.ADD;
      p_return_status := FND_API.G_RET_STS_ERROR ;
      END IF;
   END IF;

      --call the transaction defaulting routine only if the return status of the
      --cash defaulting routine was success
  IF l_def_cr_return_status = FND_API.G_RET_STS_SUCCESS  THEN
    Default_Trx_Info(
              p_customer_trx_id ,
              p_customer_trx_line_id ,
              p_show_closed_invoices ,
              l_cr_gl_date ,
              l_cr_customer_id ,
              l_cr_currency_code ,
              p_cr_payment_schedule_id,
              l_cr_date,
              p_called_from,
              l_customer_id ,
              l_cust_trx_type_id ,
              p_trx_due_date ,
              l_trx_currency_code ,
              l_trx_exchange_rate ,
              l_trx_date ,
              l_trx_gl_date ,
              l_calc_discount_on_lines_flag ,
              l_partial_discount_flag ,
              l_allow_overappln_flag ,
              l_natural_appln_only_flag ,
              l_creation_sign ,
              p_applied_payment_schedule_id ,
              l_gl_date , --this is the defaulted application gl_date
              l_term_id ,
              l_amount_due_original ,
              l_amount_line_items_original ,
              l_amount_due_remaining ,
              l_discount_taken_earned ,
              l_discount_taken_unearned ,
              l_trx_line_amount ,
              p_installment ,
              l_bill_to_site_use_id ,
	      p_llca_type,
      	      l_line_items_original,
	      l_line_items_remaining,
	      l_tax_original,
	      l_tax_remaining,
	      l_freight_original,
	      l_freight_remaining,
	      l_rec_charges_charged,
	      l_rec_charges_remaining,
	      l_def_trx_return_status );

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('Default_application_info: ' || 'Default trx info return status = '||l_def_trx_return_status);
              END IF;
   END IF;

          Default_apply_date(l_cr_date ,
                             l_trx_date,
                             p_apply_date);

          --If user has not entered the apply_gl_date default it
          --to gl_date defaulted by the Default_trx_info()
          IF p_apply_gl_date IS NULL THEN
           /*apandit : bug 3172587
             In case the apply_gl_date is defaulted we need to additionally validate this
              defaulted gl_date and in case it is incorrect, then we get the appropriate
              gl_date and use it as default.
            */
            l_return :=
              arp_util.validate_and_default_gl_date(
                  gl_date                => l_gl_date,
                  trx_date               => null,
                  validation_date1       => null,
                  validation_date2       => null,
                  validation_date3       => null,
                  default_date1          => l_gl_date,
                  default_date2          => null,
                  default_date3          => null,
                  p_allow_not_open_flag  => 'N',
                  p_invoicing_rule_id    => null,
                  p_set_of_books_id      => arp_global.set_of_books_id,
                  p_application_id       => 222,
                  default_gl_date        => l_default_gl_date ,
                  defaulting_rule_used   => l_defaulting_rule_used,
                  error_message          => l_error_message);

             IF l_return = TRUE  THEN
               p_apply_gl_date := l_default_gl_date;
             END IF;

          END IF;

       -- Default LLCA
       If P_llca_type is NOT NULL
       THEN

 	       Default_val_llca_parameters(
	            p_llca_type		  ,
                    p_cash_receipt_id     ,
                    p_customer_trx_id     ,
    		    p_customer_trx_line_id,
    		    p_amount_applied	  ,
		    p_line_amount	  ,
		    p_tax_amount          ,
		    p_freight_amount      ,
		    p_charges_amount      ,
		    p_line_discount       ,
		    p_tax_discount        ,
		    p_freight_discount    ,
                    p_discount            ,
                    l_cr_currency_code    ,
                    l_trx_currency_code   ,
		    l_cr_date,              -- Bug 6931978 Cross Currency App
		    l_creation_sign,
                    l_natural_appln_only_flag,
                    l_val_llca_return_status ,
                    l_val_llca_msg_data	,
                    l_val_llca_msg_count
			);

	END IF;

       --arp_util.debug('p_apply_gl_date '||p_apply_gl_date);
          Default_disc_and_amt_applied(
                             l_customer_id ,
                             l_bill_to_site_use_id ,
                             p_applied_payment_schedule_id ,
                             p_amount_applied  ,
                             p_discount ,
                             l_term_id  ,
                             p_installment ,
                             l_trx_date,
                             l_cr_date ,
                             l_cr_currency_code ,
                             l_trx_currency_code ,
                             l_cr_exchange_rate ,
                             l_trx_exchange_rate ,--corresponds to app_folder.exchange_rate
                             p_apply_date ,
                             l_amount_due_original ,
                             l_amount_due_remaining ,
                             l_cr_unapp_amount ,
                             l_allow_overappln_flag ,
                             l_calc_discount_on_lines_flag ,
                             l_partial_discount_flag ,
                             l_amount_line_items_original ,
                             l_discount_taken_unearned ,
                             l_discount_taken_earned ,
                             p_customer_trx_line_id ,
                             l_trx_line_amount ,
			     p_llca_type,
                             p_discount_max_allowed ,
                             p_discount_earned_allowed ,
                             p_discount_earned  ,
                             p_discount_unearned ,
                             p_new_amount_due_remaining ,
                             l_def_amt_return_status);


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_application_info: ' || 'l_calc_discount_on_lines_flag  : '||l_calc_discount_on_lines_flag);
     arp_util.debug('Default_application_info: ' || 'l_partial_discount_flag        : '||l_partial_discount_flag );
     arp_util.debug('Default_application_info: ' || 'l_allow_overappln_flag         : '||l_allow_overappln_flag);
     arp_util.debug('Default_application_info: ' || 'l_natural_appln_only_flag      : '||l_natural_appln_only_flag);
     arp_util.debug('Default_application_info: ' || 'l_creation_sign                : '||l_creation_sign);
                arp_util.debug('Default_application_info: ' || 'Default amount return status :'||l_def_amt_return_status );
             END IF;

              Default_trans_to_receipt_rate(
                             l_trx_currency_code ,
                             l_cr_currency_code ,
                             l_receipt_date ,
                             p_trans_to_receipt_rate ,
                             p_amount_applied,
                             p_amount_applied_from,
                             l_cr_date,
                             l_def_rate_return_status
                                      );
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Default_application_info: ' || 'Default trans_to_receipt_rate status :'||l_def_rate_return_status);
            END IF;
              Default_amount_applied_from(
                             p_amount_applied ,
                             l_trx_currency_code ,
                             p_trans_to_receipt_rate ,
                             l_cr_currency_code  ,
                             p_amount_applied_from ,
                             l_def_aaf_return_status
                              );
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Default_application_info: ' || 'Default amount applied from return status :'||l_def_aaf_return_status);
             END IF;


     --populate the parameters with the values in the local variables

        p_term_id := l_term_id;
        p_calc_discount_on_lines_flag   := l_calc_discount_on_lines_flag;
        p_partial_discount_flag         := l_partial_discount_flag;
        p_allow_overappln_flag          := l_allow_overappln_flag;
        p_natural_appln_only_flag       := l_natural_appln_only_flag;
        p_creation_sign                 := l_creation_sign;
        p_cr_unapp_amount               := l_cr_unapp_amount;
        p_amount_due_original           := l_amount_due_original;
        p_amount_due_remaining          := l_amount_due_remaining;
        p_trx_line_amount               := l_trx_line_amount;
        p_cr_currency_code              := l_cr_currency_code;
        p_trx_currency_code             := l_trx_currency_code;
        p_cr_gl_date                    := l_cr_gl_date;
        p_trx_gl_date                   := l_trx_gl_date;
        p_cr_date := l_cr_date;
        p_trx_date  := l_trx_date;

	-- llca
	p_line_items_original		:= l_line_items_original;
	p_line_items_remaining		:= l_line_items_remaining;
	p_tax_original			:= l_tax_original;
	p_tax_remaining			:= l_tax_remaining;
	p_freight_original		:= l_freight_original;
	p_freight_remaining		:= l_freight_remaining;
	p_rec_charges_charged		:= l_rec_charges_charged;
	p_rec_charges_remaining		:= l_rec_charges_remaining;

        IF l_def_cr_return_status =  FND_API.G_RET_STS_ERROR OR
           l_def_trx_return_status =  FND_API.G_RET_STS_ERROR OR
           l_def_rate_return_status = FND_API.G_RET_STS_ERROR OR
	   l_val_llca_return_status = FND_API.G_RET_STS_ERROR
         THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('Default_application_info: ' || '*****************Application Defaults***************');
              arp_util.debug('Default_application_info: ' || 'p_cash_receipt_id             : '||to_char(p_cash_receipt_id));
              arp_util.debug('Default_application_info: ' || 'p_cr_gl_date                  : '||to_char(p_cr_gl_date,'DD-MON-YYYY'));
              arp_util.debug('Default_application_info: ' || 'p_cr_date                     : '||to_char(p_cr_date,'DD-MON-YYYY'));
              arp_util.debug('Default_application_info: ' || 'p_cr_amount                   : '||to_char(p_cr_amount));
              arp_util.debug('Default_application_info: ' || 'p_cr_unapp_amount             : '||to_char(p_cr_unapp_amount));
              arp_util.debug('Default_application_info: ' || 'p_cr_currency_code            : '||p_cr_currency_code);
              arp_util.debug('Default_application_info: ' || 'p_customer_trx_id             : '||to_char(p_customer_trx_id));
              arp_util.debug('Default_application_info: ' || 'p_installment                 : '||to_char(p_installment));
              arp_util.debug('Default_application_info: ' || 'p_show_closed_invoices        : '||p_show_closed_invoices);
              arp_util.debug('Default_application_info: ' || 'p_customer_trx_line_id        : '||to_char(p_customer_trx_line_id));
              arp_util.debug('Default_application_info: ' || 'p_trx_due_date                : '||to_char(p_trx_due_date,'DD-MON-YYYY'));
              arp_util.debug('Default_application_info: ' || 'p_trx_currency_code           : '||p_trx_currency_code);
              arp_util.debug('Default_application_info: ' || 'p_trx_gl_date                 : '||to_char(p_trx_due_date,'DD-MON-YYYY'));
              arp_util.debug('Default_application_info: ' || 'p_apply_gl_date               : '||to_char(p_apply_gl_date,'DD-MON-YYYY'));
              arp_util.debug('Default_application_info: ' || 'p_calc_discount_on_lines_flag : '||p_calc_discount_on_lines_flag);
              arp_util.debug('Default_application_info: ' || 'p_partial_discount_flag       : '||p_partial_discount_flag);
              arp_util.debug('Default_application_info: ' || 'p_allow_overappln_flag        : '||p_allow_overappln_flag);
              arp_util.debug('Default_application_info: ' || 'p_natural_appln_only_flag     : '||p_natural_appln_only_flag);
              arp_util.debug('Default_application_info: ' || 'p_creation_sign               : '||p_creation_sign);
              arp_util.debug('Default_application_info: ' || 'p_cr_payment_schedule_id      : '||to_char(p_cr_payment_schedule_id));
              arp_util.debug('Default_application_info: ' || 'p_applied_payment_schedule_id : '||to_char(p_applied_payment_schedule_id));
              arp_util.debug('Default_application_info: ' || 'p_term_id                     : '||to_char(p_term_id));
              arp_util.debug('Default_application_info: ' || 'p_amount_due_original         : '||to_char(p_amount_due_original));
              arp_util.debug('Default_application_info: ' || 'p_amount_due_remaining        : '||to_char(p_amount_due_remaining));
              arp_util.debug('Default_application_info: ' || 'p_trx_line_amount             : '||to_char(p_trx_line_amount));
              arp_util.debug('Default_application_info: ' || 'p_discount                    : '||to_char(p_discount));
              arp_util.debug('Default_application_info: ' || 'p_apply_date                  : '||to_char(p_apply_date,'DD-MON-YYYY'));
              arp_util.debug('Default_application_info: ' || 'p_discount_max_allowed        : '||to_char(p_discount_max_allowed));
              arp_util.debug('Default_application_info: ' || 'p_discount_earned_allowed     : '||to_char(p_discount_earned_allowed));
              arp_util.debug('Default_application_info: ' || 'p_discount_earned             : '||to_char(p_discount_earned));
              arp_util.debug('Default_application_info: ' || 'p_discount_unearned           : '||to_char(p_discount_unearned));
              arp_util.debug('Default_application_info: ' || 'p_new_amount_due_remaining    : '||to_char(p_new_amount_due_remaining));
              arp_util.debug('Default_application_info: ' || 'p_amount_applied              : '||to_char(p_amount_applied));
              arp_util.debug('Default_application_info: ' || 'p_amount_applied_from         : '||to_char(p_amount_applied_from));
              arp_util.debug('Default_application_info: ' || 'p_trans_to_receipt_rate       : '||to_char(p_trans_to_receipt_rate));
              arp_util.debug('Default_application_info: ' || '**********************************************************');
       arp_util.debug('Default_application_info ()-');
    END IF;
END Default_application_info;

FUNCTION Get_trx_ps_id(p_customer_trx_id IN OUT NOCOPY NUMBER,
                       p_installment     IN NUMBER,
                       p_called_from     IN VARCHAR2,
                       p_return_status   OUT NOCOPY VARCHAR2
                       ) RETURN NUMBER IS
l_trx_ps_id  NUMBER;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Get_trx_ps_id ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_called_from IN ('BR_REMITTED',
                      'BR_FACTORED_WITH_RECOURSE',
                      'BR_FACTORED_WITHOUT_RECOURSE') THEN
  --called from the BR Remittance program
      IF p_installment IS NOT NULL THEN
        BEGIN
         SELECT ps.payment_schedule_id
         INTO   l_trx_ps_id
         FROM   ra_customer_trx ct,
                ar_payment_schedules ps
         WHERE  ct.customer_trx_id = p_customer_trx_id
           AND  ct.customer_trx_id = ps.customer_trx_id
           AND  ps.class  IN ('CB','CM','DEP','DM','INV','BR')
           AND  ps.terms_sequence_number = p_installment
             ;
         EXCEPTION
          WHEN no_data_found THEN

            IF ar_receipt_api_pub.Original_unapp_info.customer_trx_id IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_ID_INST_INVALID');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
            ELSIF ar_receipt_api_pub.Original_unapp_info.trx_number IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_INST_INVALID');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

         END;

      ELSE
    --if the user has not entered the installment then if the transaction
    --has only one installment, get the ps_id for that installment
         BEGIN
           SELECT ps.payment_schedule_id
           INTO   l_trx_ps_id
           FROM   ra_customer_trx ct,
                  ar_payment_schedules ps
           WHERE  ct.customer_trx_id = p_customer_trx_id
             AND  ct.customer_trx_id = ps.customer_trx_id
             AND  ps.class  IN ('CB','CM','DEP','DM','INV','BR')
                  ;
         EXCEPTION
           WHEN no_data_found THEN
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
             FND_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
           WHEN too_many_rows THEN
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_INSTALL_NULL');
             FND_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
         END;

      END IF;

  ELSE --not called from the BR Remittance program

      IF p_installment IS NOT NULL THEN
        BEGIN
         SELECT ps.payment_schedule_id
         INTO   l_trx_ps_id
         FROM   ra_customer_trx ct,
                ar_payment_schedules ps
         WHERE  ct.customer_trx_id = p_customer_trx_id
           AND  ct.customer_trx_id = ps.customer_trx_id
           AND  ps.class  IN ('CB','CM','DEP','DM','INV','BR')
           AND  ps.terms_sequence_number = p_installment
           --these two conditions are to ensure that the trx(bill) is not in remit process
           AND  ps.reserved_type IS NULL
           AND  ps.reserved_value IS NULL;
         EXCEPTION
          WHEN no_data_found THEN

            IF ar_receipt_api_pub.Original_unapp_info.customer_trx_id IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_ID_INST_INVALID');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
            ELSIF ar_receipt_api_pub.Original_unapp_info.trx_number IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_NUM_INST_INVALID');
              FND_MSG_PUB.Add;
              p_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
         END;

      ELSE
    --if the user has not entered the installment then if the transaction
    --has only one installment, get the ps_id for that installment
         BEGIN
           SELECT ps.payment_schedule_id
           INTO   l_trx_ps_id
           FROM   ra_customer_trx ct,
                  ar_payment_schedules ps
           WHERE  ct.customer_trx_id = p_customer_trx_id
             AND  ct.customer_trx_id = ps.customer_trx_id
             AND  ps.class  IN ('CB','CM','DEP','DM','INV','BR')
             --these two conditions are to ensure that the trx(bill) is not in remit process
             AND  ps.reserved_type IS NULL
             AND  ps.reserved_value IS NULL
                  ;
         EXCEPTION
           WHEN no_data_found THEN
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_CUST_TRX_ID_INVALID');
             FND_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
           WHEN too_many_rows THEN
             FND_MESSAGE.SET_NAME('AR','AR_RAPI_INSTALL_NULL');
             FND_MSG_PUB.Add;
             p_return_status := FND_API.G_RET_STS_ERROR;
         END;

      END IF;

  END IF;

   RETURN(l_trx_ps_id);
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('Get_trx_ps_id ()-');
 END IF;
EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: Get_trx_ps_id()');
   END IF;
   raise;
END Get_trx_ps_id;

PROCEDURE Derive_receivable_appln_id(
                           p_cash_receipt_id             IN NUMBER,
                           p_applied_payment_schedule_id IN NUMBER,
                           p_apply_gl_date               OUT NOCOPY DATE,
                           p_receivable_application_id   OUT NOCOPY NUMBER,
			   p_customer_trx_id		 OUT NOCOPY NUMBER,
                           p_return_status               OUT NOCOPY VARCHAR2
                           )  IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Derive_receivable_appln_id ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_cash_receipt_id IS NOT NULL AND
     p_applied_payment_schedule_id IS NOT NULL
   THEN
      SELECT receivable_application_id, gl_date
	     ,applied_customer_trx_id
      INTO   p_receivable_application_id, p_apply_gl_date
             ,p_customer_trx_id
      FROM   ar_receivable_applications ra
      WHERE  ra.cash_receipt_id = p_cash_receipt_id
        AND  ra.applied_payment_schedule_id = p_applied_payment_schedule_id
        AND  ra.display = 'Y'
        AND  ra.status = 'APP'
        AND  ra.application_type = 'CASH';

   END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Derive_receivable_appln_id ()+');
  END IF;
EXCEPTION
 WHEN no_data_found THEN
  FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_NOT_APP_TO_INV');
  FND_MSG_PUB.Add;
  p_return_status := FND_API.G_RET_STS_ERROR;
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_receivable_appln_id: ' || 'EXCEPTION: Get_receivable_application_id()');
   END IF;
   raise;
END Derive_receivable_appln_id;

PROCEDURE Get_payment_schedule_info(
                                 p_ps_id      IN NUMBER,
                                 p_customer_trx_id OUT NOCOPY VARCHAR2,
                                 p_installment     OUT NOCOPY NUMBER,
                                 p_called_from     IN VARCHAR2,
                                 p_return_status   OUT NOCOPY VARCHAR2 ) IS
CURSOR payment_schedule IS
 SELECT ps.customer_trx_id, ps.terms_sequence_number
 FROM   ar_payment_schedules ps
 WHERE  ps.payment_schedule_id =  p_ps_id
   AND  ps.class  IN ('CB','CM','DEP','DM','INV','BR')
   --these two conditions are to ensure that the trx(bill) is not in remit process
   AND  ps.reserved_type  is null
   AND  ps.reserved_value  is null;

CURSOR payment_schedule_br_remit IS
 SELECT ps.customer_trx_id, ps.terms_sequence_number
 FROM   ar_payment_schedules ps
 WHERE  ps.payment_schedule_id =  p_ps_id
   AND  ps.class  IN ('CB','CM','DEP','DM','INV','BR');

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Get_payment_schedule_info  ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_called_from IN ('BR_REMITTED',
                      'BR_FACTORED_WITH_RECOURSE',
                      'BR_FACTORED_WITHOUT_RECOURSE') THEN
  OPEN payment_schedule_br_remit;

  FETCH payment_schedule_br_remit INTO   p_customer_trx_id, p_installment;
   IF payment_schedule_br_remit%NOTFOUND THEN
     --raise error message
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
     FND_MSG_PUB.Add;
     p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
  CLOSE payment_schedule_br_remit;

 ELSE

  OPEN payment_schedule;
  FETCH payment_schedule INTO   p_customer_trx_id, p_installment;
   IF payment_schedule%NOTFOUND THEN
     --raise error message
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
     FND_MSG_PUB.Add;
     p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
  CLOSE payment_schedule;

 END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Get_payment_schedule_info  ()-');
  END IF;
END Get_payment_schedule_info;

PROCEDURE Get_receivable_appln_info(
                                   p_ra_id           IN NUMBER,
                                   p_ra_app_ps_id    OUT NOCOPY NUMBER,
                                   p_cash_receipt_id OUT NOCOPY NUMBER,
                                   p_apply_gl_date   OUT NOCOPY DATE, /* Bug fix 3451241 */
				   p_customer_trx_id OUT NOCOPY NUMBER,  /* LLCA */
                                   p_called_from     IN VARCHAR2,
                                   p_return_status   OUT NOCOPY VARCHAR2
                                       ) IS
CURSOR rec_apppln IS
SELECT ra.cash_receipt_id, ra.applied_payment_schedule_id, ra.gl_date /* Bug fix 3451241 */
       , ra.applied_customer_trx_id
FROM   ar_receivable_applications ra,
       ar_payment_schedules ps
WHERE  ra.applied_payment_schedule_id = ps.payment_schedule_id
  AND  ra.receivable_application_id = p_ra_id
  AND  ra.display = 'Y'
  AND  ra.status = 'APP'
  AND  ps.reserved_value IS NULL
  AND  ps.reserved_type IS NULL;

CURSOR rec_apppln_br_remit IS
SELECT ra.cash_receipt_id, ra.applied_payment_schedule_id, ra.gl_date /* Bug fix 3451241 */
      , ra.applied_customer_trx_id
FROM   ar_receivable_applications ra
WHERE  ra.receivable_application_id = p_ra_id
  AND  ra.display = 'Y'
  AND  ra.status = 'APP';

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Get_receivable_appln_info ()+');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_called_from IN ('BR_REMITTED',
                      'BR_FACTORED_WITH_RECOURSE',
                      'BR_FACTORED_WITHOUT_RECOURSE') THEN
     OPEN rec_apppln_br_remit;
     FETCH rec_apppln_br_remit INTO p_cash_receipt_id, p_ra_app_ps_id, p_apply_gl_date, p_customer_trx_id; /* Bug fix 3451241 */
       IF rec_apppln_br_remit%NOTFOUND  THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     CLOSE rec_apppln_br_remit;

  ELSE

     OPEN rec_apppln;
     FETCH rec_apppln INTO p_cash_receipt_id, p_ra_app_ps_id, p_apply_gl_date,p_customer_trx_id; /* Bug fix 3451241 */
       IF rec_apppln%NOTFOUND  THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     CLOSE rec_apppln;

   END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Get_receivable_appln_info ()-');
  END IF;
END Get_receivable_appln_info;

PROCEDURE Derive_unapp_ids(
                   p_trx_number                   IN VARCHAR2,
                   p_customer_trx_id              IN OUT NOCOPY NUMBER,
                   p_installment                  IN NUMBER,
                   p_applied_payment_schedule_id  IN OUT NOCOPY NUMBER,
                   p_receipt_number               IN VARCHAR2,
                   p_cash_receipt_id              IN OUT NOCOPY NUMBER,
                   p_receivable_application_id    IN OUT NOCOPY NUMBER,
                   p_called_from                  IN VARCHAR2,
                   p_apply_gl_date                OUT NOCOPY DATE,
                   p_return_status                OUT NOCOPY VARCHAR2
                   ) IS
l_customer_trx_id             NUMBER;
l_ra_customer_trx_id          NUMBER;
l_installment                 NUMBER(15);
l_ra_app_ps_id                NUMBER;
l_applied_payment_schedule_id NUMBER;
l_receivable_application_id   NUMBER;
l_return_status               VARCHAR2(1);
l_cash_receipt_id             NUMBER(15);
l_cust_trx_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_ps_id_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_ra_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_cr_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Derive_unapp_ids ()+');
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- First get a valid value for the customer_trx_id
  IF p_trx_number IS NOT NULL THEN
    Default_customer_trx_id(p_customer_trx_id ,
                            p_trx_number ,
                            l_cust_trx_return_status);
  END IF;

  --if error is raised in deriving the customer_trx_id from the trx_number,
  --do not process the applied_payment_schedule_id any further.
 IF l_cust_trx_return_status= FND_API.G_RET_STS_SUCCESS THEN

    IF p_applied_payment_schedule_id IS NOT NULL THEN
       Get_payment_schedule_info( p_applied_payment_schedule_id,
                                  l_customer_trx_id,
                                  l_installment,
                                  p_called_from,
                                  l_ps_id_return_status
                                  );
      IF l_cust_trx_return_status= FND_API.G_RET_STS_SUCCESS  AND
         l_ps_id_return_status = FND_API.G_RET_STS_SUCCESS
       THEN
       --Compare the two customer_trx_ids
       IF (nvl(p_customer_trx_id,l_customer_trx_id) <> l_customer_trx_id OR
          nvl(p_installment,l_installment)  <>  l_installment) THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_PS_ID_X_INVALID');
           FND_MSG_PUB.Add;
           p_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
           p_customer_trx_id := l_customer_trx_id;
       END IF;
      END IF;

    ELSE  --the user has not entered the applied_ps_id

     IF p_customer_trx_id IS NOT NULL THEN
        l_applied_payment_schedule_id :=
                      Get_trx_ps_id(p_customer_trx_id,
                                    p_installment,
                                    p_called_from,
                                    l_ps_id_return_status);
        p_applied_payment_schedule_id
                          :=l_applied_payment_schedule_id;
     END IF;

    END IF;
 END IF;

   --derive the cash_receipt_id from the receipt_number
   IF p_receipt_number IS NOT NULL THEN
     Default_cash_receipt_id(p_cash_receipt_id,
                             p_receipt_number,
                             l_cr_return_status);
   END IF;

   --If user has entered the receivable_application_id, get the related info
  IF p_receivable_application_id IS NOT NULL THEN
           Get_receivable_appln_info( p_receivable_application_id,
                                      l_ra_app_ps_id,
                                      l_cash_receipt_id,
                                      p_apply_gl_date, /* Bug fix 3451241 */
				      l_customer_trx_id, /* LLCA */
                                      p_called_from,
                                      l_ra_return_status
                                     );
      IF nvl( l_ra_app_ps_id,-99) <> nvl(p_applied_payment_schedule_id,
                                                    nvl( l_ra_app_ps_id,-99))
       THEN
        IF ar_receipt_api_pub.Original_unapp_info.customer_trx_id IS NOT NULL OR
           ar_receipt_api_pub.Original_unapp_info.trx_number IS NOT NULL THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_TRX_RA_ID_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF ar_receipt_api_pub.Original_unapp_info.applied_ps_id IS NOT NULL THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_RA_ID_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      ELSE
        p_applied_payment_schedule_id := l_ra_app_ps_id;
      END IF;

      IF nvl(l_cash_receipt_id,-99) <> nvl(p_cash_receipt_id,nvl(l_cash_receipt_id,-99)) THEN
        --Invalid receivable application identifier for the entered cash receipt
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_RA_ID_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
        p_cash_receipt_id := l_cash_receipt_id;
      END IF;

	/* LLCA */
      IF nvl(l_customer_trx_id,-99) <> nvl(p_customer_trx_id,nvl(l_customer_trx_id,-99)) THEN
        --Invalid receivable application identifier for the entered customer trx id receipt
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_RA_ID_X_INVALID');
         FND_MSG_PUB.Add;
         p_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
 	 p_customer_trx_id := l_customer_trx_id;
      END IF;


  ELSE --the user has not passed in the receivable application id
   --
   -- derive receivable_application_id
   --
   --If app_ps_id and the cash_receipt_id are not null then
   --get the default receivable_application_id which will be
   --used for defaulting or cross-validation
    IF p_cash_receipt_id IS NOT NULL AND
       p_applied_payment_schedule_id IS NOT NULL
     THEN
       --derive the receivable application id using the cash receipt id and
       --the applied payment schedule id
              Derive_receivable_appln_id(
                                  p_cash_receipt_id,
                                  p_applied_payment_schedule_id,
                                  p_apply_gl_date,
                                  l_receivable_application_id,
				  l_customer_trx_id,
                                  l_ra_return_status);
              p_receivable_application_id := l_receivable_application_id;
	      /* LLCA */
	      If p_customer_trx_id is NULL
	      THEN
	      	p_customer_trx_id    := l_customer_trx_id;
	      END IF;

    END IF; --in other cases we can't derive the receivable application id so it cannot be defaulted

  END IF;

  IF l_cust_trx_return_status <> FND_API.G_RET_STS_SUCCESS OR
     l_ps_id_return_status    <> FND_API.G_RET_STS_SUCCESS OR
     l_ra_return_status       <> FND_API.G_RET_STS_SUCCESS OR
     l_cr_return_status       <> FND_API.G_RET_STS_SUCCESS OR
     p_return_status          <> FND_API.G_RET_STS_SUCCESS
   THEN
     p_return_status  := FND_API.G_RET_STS_ERROR;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Derive_unapp_ids: ' || '****Defaulted Value for the unapplication ids****');
     arp_util.debug('Derive_unapp_ids: ' || 'p_cash_receipt_id             :'||to_char(p_cash_receipt_id));
     arp_util.debug('Derive_unapp_ids: ' || 'p_customer_trx_id             :'||to_char(p_customer_trx_id));
     arp_util.debug('Derive_unapp_ids: ' || 'p_installment                 :'||to_char(p_installment));
     arp_util.debug('Derive_unapp_ids: ' || 'p_applied_payment_schedule_id :'||to_char(p_applied_payment_schedule_id));
     arp_util.debug('Derive_unapp_ids: ' || 'p_receivable_application_id   :'||to_char(p_receivable_application_id));
     arp_util.debug('Derive_unapp_ids: ' || 'Return Status                 :'||p_return_status);
     arp_util.debug('Derive_unapp_ids ()-');
  END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Derive_unapp_ids()');
  END IF;
  raise;
END Derive_unapp_ids;

/* This is a routine to get the reversal_gl_date for the unapplication */
PROCEDURE Default_reversal_gl_date(
                        p_receivable_application_id IN NUMBER,
                        p_reversal_gl_date IN OUT NOCOPY DATE,
                        p_apply_gl_date IN OUT NOCOPY DATE,
                        p_cash_receipt_id IN OUT NOCOPY NUMBER
                                   ) IS
l_apply_gl_date     DATE;
l_default_gl_date   DATE;
l_defaulting_rule_used  VARCHAR2(100);
l_error_message  VARCHAR2(240);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_reversal_gl_date ()+');
  END IF;
    l_apply_gl_date := p_apply_gl_date;  /* Bug fix 3503167 */

    IF p_receivable_application_id IS NOT NULL THEN
     IF p_apply_gl_date  IS NULL THEN
      --get the gl_date for the application
      SELECT gl_date, cash_receipt_id
      INTO   l_apply_gl_date, p_cash_receipt_id
      FROM   ar_receivable_applications
      WHERE  receivable_application_id =
                p_receivable_application_id;
     END IF;
      /* Bug fix 3503167 : We need to pass the apply_gl_date as the candidate gl_date and
         as the validation date */
      IF p_reversal_gl_date is null THEN
         IF (arp_util.validate_and_default_gl_date(
                nvl(l_apply_gl_date,trunc(sysdate)),
                NULL,
                l_apply_gl_date,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                NULL,
                arp_global.set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE) THEN

           p_reversal_gl_date := l_default_gl_date;
         ELSE
         --we were not able to default the gl_date put the message
         --here on the stack, but the return status will be set
         --to FND_API.G_RET_STS_ERROR in the validation phase.
           FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
           FND_MSG_PUB.Add;
         END IF;
      END IF;
    END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_reversal_gl_date ()-');
  END IF;
EXCEPTION
 When others THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: Default_reversal_gl_date()');
    END IF;
    raise;
END Default_reversal_gl_date;

/*Added parameter p_cr_unapp_amount for bug 3119391 */
PROCEDURE Default_unapp_info(
                        p_receivable_application_id IN NUMBER,
                        p_apply_gl_date    IN  DATE,
                        p_cash_receipt_id  IN  NUMBER,
                        p_reversal_gl_date IN OUT NOCOPY DATE,
                        p_receipt_gl_date  OUT NOCOPY DATE,
			p_cr_unapp_amount OUT NOCOPY NUMBER
                          ) IS
l_cash_receipt_id  NUMBER(15);
l_apply_gl_date  DATE;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_unapp_info ()+');
  END IF;
  l_apply_gl_date := p_apply_gl_date;
  l_cash_receipt_id := p_cash_receipt_id;

   Default_reversal_gl_date(p_receivable_application_id,
                            p_reversal_gl_date,
                            l_apply_gl_date,
                            l_cash_receipt_id );
/* Default p_cr_unapp_amount for 3119391 */

   SELECT SUM(NVL(ra.amount_applied,0))
   INTO   p_cr_unapp_amount
   FROM   ar_receivable_applications ra
   WHERE  ra.status = 'UNAPP'
   AND    ra.cash_receipt_id = l_cash_receipt_id;

 --default the receipt gl date which is to be used later
 --in the validation of the reversal gl date.
    IF  p_receipt_gl_date IS NULL AND
        l_cash_receipt_id IS NOT NULL
      THEN
       BEGIN
         SELECT gl_date
         INTO   p_receipt_gl_date
         FROM   ar_cash_receipt_history crh
         WHERE  crh.cash_receipt_id = l_cash_receipt_id
             and crh.FIRST_POSTED_RECORD_FLAG = 'Y';
          -- Bug 3074658, Inconsistent bahaviour between UI/API
          -- AND  crh.current_record_flag = 'Y';
       EXCEPTION
         WHEN no_data_found THEN
          null;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Default_unapp_info: ' || 'Could not get the receipt_gl_date. ');
          END IF;
       END;
    END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_unapp_info ()-');
  END IF;
END Default_unapp_info;

PROCEDURE Default_rev_catg_code(p_reversal_category_code IN  OUT NOCOPY VARCHAR2,
                                p_reversal_category_name IN VARCHAR2,
                                p_return_status OUT NOCOPY VARCHAR2
                                ) IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_rev_catg_code ()+');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_reversal_category_code IS NULL THEN
  BEGIN
   SELECT lookup_code
   INTO   p_reversal_category_code
   FROM   ar_lookups
   WHERE  lookup_type = 'REVERSAL_CATEGORY_TYPE'
     AND  enabled_flag = 'Y'
     AND  meaning =  p_reversal_category_name;
  EXCEPTION
   WHEN no_data_found THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_CAT_NAME_INVALID');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR ;
     null;
  END;
 ELSE
   IF p_reversal_category_name IS NOT NULL THEN
       --give a warning message to indicate that the reversal category name
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_CAT_NAME_IGN');
         FND_MSG_PUB.Add;
       END IF;
    END IF;
 END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_rev_catg_code ()-');
  END IF;
EXCEPTION
 WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_rev_catg_code()');
  END IF;
  raise;
END Default_rev_catg_code;

PROCEDURE Default_rev_reason_code(
                         p_reversal_reason_code  IN OUT NOCOPY VARCHAR2,
                         p_reversal_reason_name  IN VARCHAR2,
                         p_return_status OUT NOCOPY VARCHAR2
                           ) IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_rev_reason_code ()+');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_reversal_reason_code IS NULL THEN
  BEGIN
   SELECT lookup_code
   INTO   p_reversal_reason_code
   FROM ar_lookups
   WHERE  lookup_type = 'CKAJST_REASON'
     AND  enabled_flag = 'Y'
     AND  meaning =  p_reversal_reason_name;
  EXCEPTION
   WHEN no_data_found THEN
          FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_REAS_NAME_INVALID');
          FND_MSG_PUB.Add;
          p_return_status := FND_API.G_RET_STS_ERROR ;
     null;
  END;
 ELSE
    IF p_reversal_reason_name IS NOT NULL THEN
       --give a warning message to indicate that the reversal category name
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       	THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_REV_REAS_NAME_IGN');
         FND_MSG_PUB.Add;
       END IF;
    END IF;
 END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_rev_reason_code ()-');
  END IF;
EXCEPTION
  WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_rev_reason_code()');
  END IF;
  raise;
END Default_rev_reason_code;

PROCEDURE Derive_reverse_ids(
                         p_receipt_number         IN     VARCHAR2,
                         p_cash_receipt_id        IN OUT NOCOPY NUMBER,
                         p_reversal_category_name IN     VARCHAR2,
                         p_reversal_category_code IN OUT NOCOPY VARCHAR2,
                         p_reversal_reason_name   IN     VARCHAR2,
                         p_reversal_reason_code   IN OUT NOCOPY VARCHAR2,
                         p_return_status             OUT NOCOPY VARCHAR2
                           )  IS
l_cr_def_return_status  VARCHAR2(1);
l_rev_cat_return_status  VARCHAR2(1);
l_rev_res_return_status  VARCHAR2(1);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Derive_reverse_ids ()+ ');
  END IF;
   p_return_status :=  FND_API.G_RET_STS_SUCCESS ;


  --cash_receipt_id
  Default_cash_receipt_id(p_cash_receipt_id ,
                          p_receipt_number ,
                          l_cr_def_return_status);
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_reverse_ids: ' || 'l_cr_def__return_status   :'||l_cr_def_return_status);
   END IF;

  --reversal category
  Default_rev_catg_code(p_reversal_category_code,
                        p_reversal_category_name,
                        l_rev_cat_return_status
                         );
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Derive_reverse_ids: ' || 'l_rev_cat_return_status  :'||l_rev_cat_return_status);
    END IF;

  --reversal reason code
  Default_rev_reason_code(p_reversal_reason_code,
                          p_reversal_reason_name,
                          l_rev_res_return_status
                           );

  IF l_rev_res_return_status <>  FND_API.G_RET_STS_SUCCESS OR
     l_rev_cat_return_status <>  FND_API.G_RET_STS_SUCCESS OR
     l_cr_def_return_status      <>  FND_API.G_RET_STS_SUCCESS
    THEN
      p_return_status := FND_API.G_RET_STS_ERROR ;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Derive_reverse_ids ()- ');
  END IF;
EXCEPTION
 When others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Derive_reverse_ids()');
  END IF;
END  Derive_reverse_ids;

PROCEDURE Default_reverse_info(p_cash_receipt_id  IN NUMBER,
                               p_reversal_gl_date IN OUT NOCOPY DATE,
                               p_reversal_date    IN OUT NOCOPY DATE,
                               p_receipt_state    OUT NOCOPY VARCHAR2,
                               p_receipt_gl_date  OUT NOCOPY DATE,
                               p_type             OUT NOCOPY VARCHAR2
                               ) IS
l_receipt_date  DATE;
l_return_status VARCHAR2(1);
l_apply_date	DATE;
l_gl_date	DATE;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_reverse_info ()+');
   END IF;
   /*Get the receipt date and the status */

    SELECT cr.receipt_date, crh.status, cr.type
    INTO   l_receipt_date, p_receipt_state, p_type
    FROM   ar_cash_receipts cr,
           ar_cash_receipt_history crh
    WHERE  cr.cash_receipt_id = crh.cash_receipt_id
       AND crh.current_record_flag = 'Y'
       AND cr.cash_receipt_id = p_cash_receipt_id;

   /* Bug fix 3547720
      p_receipt_gl_date should be populated as the max(gl_date) from CRH */

    SELECT max(crh.gl_date)
    INTO   p_receipt_gl_date
    FROM   ar_cash_receipt_history crh
    WHERE  crh.cash_receipt_id = p_cash_receipt_id;

   /* Bug 8668394 : Default Reversal Date and Reversal Gl Date correctly */
    BEGIN
	Select max(apply_date) , max(gl_date)
	into   l_apply_date    , l_gl_date
	from   ar_receivable_applications
	where  cash_receipt_id = p_cash_receipt_id;

    EXCEPTION WHEN OTHERS THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	    arp_util.debug('No application record exists for this receipt.');
	    arp_util.debug('Default to sysdate to avoid NULL issue in defaulting logic.');
	END IF;
	    l_apply_date  := trunc(sysdate);
	    l_gl_date	  := trunc(sysdate);
    END;

    /*Default reversal_date */
   IF p_reversal_date IS NULL THEN
    IF l_receipt_date > trunc(SYSDATE) THEN
       p_reversal_date := greatest(l_receipt_date, l_apply_date);
    ELSE
       p_reversal_date := greatest(trunc(SYSDATE), l_apply_date);
    END IF;
   END IF;

    /* default the reversal_gl_date */
   IF p_reversal_gl_date IS NULL THEN
    /* Bug fix 3547720 : Changed the call */
    /* Bug fix 3922062. Reversal_gl_date should be the maximum of (sysdate and the
      maximum of CRH gl_date) */

    Default_gl_date(greatest(p_receipt_gl_date, sysdate, l_gl_date),
                    p_reversal_gl_date,
                    p_receipt_gl_date,
                    l_return_status);
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Default_reverse_info: ' || '**************Defaulted Variables ************');
      arp_util.debug('Default_reverse_info: ' || 'p_reversal_gl_date      : '||to_char(p_reversal_gl_date,'DD-MON-YYYY'));
      arp_util.debug('Default_reverse_info: ' || 'p_reversal_date         : '||to_char(p_reversal_date,'DD-MON-YYYY'));
      arp_util.debug('Default_reverse_info: ' || 'p_receipt_state         : '||p_receipt_state);
      arp_util.debug('Default_reverse_info: ' || 'p_receipt_gl_date       : '||to_char(p_receipt_gl_date,'DD-MON-YYYY'));
      arp_util.debug('Default_reverse_info ()-');
   END IF;
EXCEPTION
WHEN no_data_found  THEN
  --this may happen because of the invalid cash_receipt_id
  --do not raise any message here, it shall be raised in the
  --validation phase.
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_reverse_info: ' || 'Could not default info :Cash Receipt Id is invalid');
  END IF;
WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_reverse_info() ');
  END IF;
  raise;
END Default_reverse_info;

PROCEDURE Default_on_ac_app_info(
                         p_cash_receipt_id  IN NUMBER,
                         p_cr_gl_date OUT NOCOPY DATE,
                         p_cr_unapp_amount OUT NOCOPY NUMBER,
                         p_receipt_date OUT NOCOPY DATE,
                         p_cr_payment_schedule_id OUT NOCOPY NUMBER,
                         p_amount_applied IN OUT NOCOPY NUMBER,
                         p_apply_gl_date IN OUT NOCOPY DATE,
                         p_apply_date    IN OUT NOCOPY DATE,
                         p_cr_currency_code OUT NOCOPY VARCHAR2,
                         p_return_status  OUT NOCOPY VARCHAR2
                              ) IS
l_cr_customer_id  NUMBER;
l_cr_currency_code  VARCHAR2(30);
l_cr_exchange_rate  NUMBER;
l_cr_cust_site_use_id  NUMBER;
l_return_status  VARCHAR2(1);
l_cr_amount   NUMBER;
l_receipt_return_status  VARCHAR2(1);
l_gl_date_return_status  VARCHAR2(1);
l_receipt_date   DATE;
l_cr_unapp_amount NUMBER;
l_remit_bank_acct_use_id  NUMBER;
l_receipt_method_id      NUMBER;
BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_on_ac_app_info ()+');
      END IF;
              p_return_status := FND_API.G_RET_STS_SUCCESS;

                Default_Receipt_Info(
                                 p_cash_receipt_id ,
                                 p_cr_gl_date,
                                 l_cr_customer_id,
                                 l_cr_amount,
                                 l_cr_currency_code,
                                 l_cr_exchange_rate,
                                 l_cr_cust_site_use_id,
                                 l_receipt_date,
                                 l_cr_unapp_amount,
                                 p_cr_payment_schedule_id,
                                 l_remit_bank_acct_use_id,
                                 l_receipt_method_id,
                                 l_receipt_return_status
                                  );
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_on_ac_app_info: ' || 'Receipt defaulting return status :'||l_receipt_return_status);
    END IF;
               Default_apply_date(l_receipt_date ,
                                  null,
                                  p_apply_date);

           IF p_apply_gl_date IS NULL THEN
               Default_gl_date(p_cr_gl_date,
                               p_apply_gl_date,
                               NULL,
                               l_gl_date_return_status);
           END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_on_ac_app_info: ' || 'Defaulting apply gl date return status :'|| l_gl_date_return_status);
    END IF;

              --default the amount applied
              IF p_amount_applied IS NULL THEN
                 p_amount_applied := l_cr_unapp_amount;
              END IF;
              --do the precision
              p_amount_applied :=  arp_util.CurrRound(
                                      p_amount_applied,
                                      l_cr_currency_code
                                        );

               p_receipt_date :=  l_receipt_date ;
               p_cr_unapp_amount := l_cr_unapp_amount;

              IF l_receipt_return_status <> FND_API.G_RET_STS_SUCCESS OR
                 l_receipt_return_status <> l_receipt_return_status  THEN

                 p_return_status := FND_API.G_RET_STS_ERROR ;
              END IF;

             p_cr_currency_code := l_cr_currency_code;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Default_on_ac_app_info: ' || '***************Default Values *****************');
         arp_util.debug('Default_on_ac_app_info: ' || 'p_cash_receipt_id       : '||to_char(p_cash_receipt_id));
         arp_util.debug('Default_on_ac_app_info: ' || 'p_cr_gl_date            : '||to_char(p_cr_gl_date,'DD-MON-YYYY'));
         arp_util.debug('Default_on_ac_app_info: ' || 'p_amount_applied        : '||to_char(p_amount_applied));
         arp_util.debug('Default_on_ac_app_info: ' || 'p_apply_gl_date         : '||to_char(p_apply_gl_date,'DD-MON-YYYY'));
         arp_util.debug('Default_on_ac_app_info: ' || 'p_apply_date            : '||to_char(p_apply_date,'DD-MON-YYYY'));
         arp_util.debug('Default_on_ac_app_info ()-');
      END IF;
EXCEPTION
WHEN others THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('EXCEPTION: Default_on_ac_app_info() ');
  END IF;
  raise;
END  Default_on_ac_app_info;

PROCEDURE Derive_unapp_on_ac_ids(
                         p_receipt_number    IN VARCHAR2,
                         p_cash_receipt_id   IN OUT NOCOPY NUMBER,
                         p_receivable_application_id   IN OUT NOCOPY NUMBER,
                         p_apply_gl_date     OUT NOCOPY DATE,
                         p_return_status  OUT NOCOPY VARCHAR2
                               ) IS
l_rec_appln_id  NUMBER ;
l_apply_gl_date  DATE;
l_cash_receipt_id   NUMBER;
BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_unapp_on_ac_ids ()+');
   END IF;
    --derive the cash_receipt_id from the receipt_number
    IF p_receipt_number IS NOT NULL THEN
        Default_cash_receipt_id(p_cash_receipt_id ,
                                p_receipt_number ,
                                p_return_status);
    END IF;

        --get the receivable application id for the on account application
        --on this cash receipt. If more than one on-account application exists
        --for the receipt, raise error.
      IF p_cash_receipt_id IS NOT NULL THEN

           BEGIN
              SELECT receivable_application_id, gl_date
              INTO   l_rec_appln_id , p_apply_gl_date
              FROM   ar_receivable_applications
              WHERE  cash_receipt_id = p_cash_receipt_id
                AND  display = 'Y'
                AND  status = 'ACC';
           EXCEPTION
             WHEN no_data_found THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
             WHEN too_many_rows THEN
              IF p_receivable_application_id IS NULL THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_MULTIPLE_ON_AC_APP');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
              END IF;

           END;

      END IF;

       IF p_receivable_application_id IS NOT NULL THEN

          BEGIN
           SELECT  cash_receipt_id, gl_date
           INTO    l_cash_receipt_id , p_apply_gl_date
           FROM    ar_receivable_applications
           WHERE   receivable_application_id = p_receivable_application_id
             and   display = 'Y'
             and   status = 'ACC';
          EXCEPTION
            WHEN no_data_found THEN
               FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR ;
          END;

         --Compare the two cash_receipt_ids
         IF p_cash_receipt_id IS NOT NULL THEN
            IF p_cash_receipt_id <> NVL(l_cash_receipt_id,p_cash_receipt_id) THEN
                --raise error X validation failed
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_RA_ID_X_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
         END IF;

       ELSE
        p_receivable_application_id := l_rec_appln_id ;
       END IF;

       IF p_cash_receipt_id IS NULL THEN
          p_cash_receipt_id := l_cash_receipt_id;
       END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_unapp_on_ac_ids ()+');
   END IF;
END Derive_unapp_on_ac_ids;

PROCEDURE Derive_otheraccount_ids(
                         p_receipt_number    IN VARCHAR2,
                         p_cash_receipt_id   IN OUT NOCOPY NUMBER,
                         p_applied_ps_id     IN NUMBER,
                         p_receivable_application_id   IN OUT NOCOPY NUMBER,
                         p_apply_gl_date     OUT NOCOPY DATE,
                         p_cr_unapp_amt     OUT NOCOPY NUMBER, /* Bug fix 3569640 */
                         p_return_status  OUT NOCOPY VARCHAR2
                               ) IS
l_rec_appln_id  NUMBER ;
l_apply_gl_date  DATE;
l_cash_receipt_id   NUMBER;
l_applied_ps_id     NUMBER;

BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_otheraccount_ids ()+');
   END IF;
    --derive the cash_receipt_id from the receipt_number
    IF p_receipt_number IS NOT NULL THEN
        Default_cash_receipt_id(p_cash_receipt_id ,
                                p_receipt_number ,
                                p_return_status);
    END IF;

        --get the receivable application id for the prepayment application
        --on this cash receipt. If more than one prepayment application exists
        --for the receipt, raise error.
      -- Bug 2751910 - restrict validation to prepayments
      IF (p_cash_receipt_id IS NOT NULL AND p_applied_ps_id = -7) THEN

           BEGIN
              SELECT receivable_application_id, gl_date
              INTO   l_rec_appln_id , p_apply_gl_date
              FROM   ar_receivable_applications
              WHERE  cash_receipt_id = p_cash_receipt_id
                AND  applied_payment_schedule_id = p_applied_ps_id
                AND  display = 'Y'
                AND  status = 'OTHER ACC';
           EXCEPTION
             WHEN no_data_found THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
             WHEN too_many_rows THEN
              IF p_receivable_application_id IS NULL THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_MULTIPLE_PREPAY');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
              END IF;

           END;

      END IF;

       IF p_receivable_application_id IS NOT NULL THEN

          BEGIN
           SELECT  cash_receipt_id, gl_date
           INTO    l_cash_receipt_id , p_apply_gl_date
           FROM    ar_receivable_applications
           WHERE   receivable_application_id = p_receivable_application_id
             and   display = 'Y'
             and   applied_payment_schedule_id = p_applied_ps_id
             and   status = 'OTHER ACC';
          EXCEPTION
            WHEN no_data_found THEN
               FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR ;
          END;

         --Compare the two cash_receipt_ids
         IF p_cash_receipt_id IS NOT NULL THEN
            IF p_cash_receipt_id <> NVL(l_cash_receipt_id,p_cash_receipt_id) THEN
                --raise error X validation failed
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_RA_ID_X_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
         END IF;

       ELSE
        p_receivable_application_id := l_rec_appln_id ;
       END IF;

       IF p_cash_receipt_id IS NULL THEN
          p_cash_receipt_id := l_cash_receipt_id;
       END IF;

       /* Bug fix 3569640 */
       IF p_cash_receipt_id IS NOT NULL THEN
         SELECT SUM(NVL(ra.amount_applied,0))
         INTO  p_cr_unapp_amt
         FROM  ar_receivable_applications ra
         WHERE  ra.cash_receipt_id = p_cash_receipt_id
          AND   ra.status = 'UNAPP'
          AND   nvl(ra.confirmed_flag,'Y') = 'Y';
       END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_otheraccount_ids: ' || 'Derive_unapp_on_ac_ids ()+');
   END IF;
END Derive_otheraccount_ids;

PROCEDURE Default_unapp_on_ac_act_info(
                         p_receivable_application_id IN NUMBER,
                         p_apply_gl_date             IN DATE,
                         p_cash_receipt_id           IN NUMBER,
                         p_reversal_gl_date          IN OUT NOCOPY DATE,
                         p_receipt_gl_date           OUT NOCOPY DATE
                          ) IS
l_apply_date DATE;
l_apply_gl_date DATE;
l_cash_receipt_id  NUMBER;
l_default_gl_date  DATE;
l_defaulting_rule_used  VARCHAR2(100);
l_error_message  VARCHAR2(240);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Default_unapp_on_ac_act_info: ' || 'Default_unapp_on_acc_act_info ()+');
  END IF;
  l_apply_gl_date := p_apply_gl_date;

      /* Bug fix 3503167 : We need to pass the apply_gl_date as the candidate gl_date and
         as the validation date */
      IF p_reversal_gl_date is null THEN
         IF (arp_util.validate_and_default_gl_date(
                nvl(l_apply_gl_date,trunc(sysdate)),
                NULL,
                l_apply_gl_date,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                NULL,
                arp_global.set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE) THEN

           p_reversal_gl_date := l_default_gl_date;
         ELSE
         --we were not able to default the gl_date put the message
         --here on the stack, but the return status will be set
         --to FND_API.G_RET_STS_ERROR in the validation phase.
           FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_error_message);
           FND_MSG_PUB.Add;
         END IF;
      END IF;

   --derive the receipt_gl_date which is to be used
   --in the validation of the reversal gl date.
   IF  p_receipt_gl_date IS NULL AND
        l_cash_receipt_id IS NOT NULL
      THEN
       BEGIN
         SELECT gl_date
         INTO   p_receipt_gl_date
         FROM   ar_cash_receipt_history crh
         WHERE  crh.cash_receipt_id = l_cash_receipt_id
           and  crh.current_record_flag = 'Y';
       EXCEPTION
         WHEN no_data_found THEN
          null;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Default_unapp_on_ac_act_info: ' || 'Could not get the receipt_gl_date. ');
          END IF;
       END;
   END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Default_unapp_on_ac_act_info: ' || '*****Defaulted Values *********');
       arp_util.debug('Default_unapp_on_ac_act_info: ' || 'p_cash_receipt_id            : '||to_char(p_cash_receipt_id));
       arp_util.debug('Default_unapp_on_ac_act_info: ' || 'p_receivable_application_id  : '||to_char(p_receivable_application_id));
       arp_util.debug('Default_unapp_on_ac_act_info: ' || 'p_apply_gl_date              : '||to_char(p_apply_gl_date,'DD-MON-YYYY'));
       arp_util.debug('Default_unapp_on_ac_act_info: ' || 'p_reversal_gl_date           : '||to_char(p_reversal_gl_date,'DD-MON-YYYY'));
       arp_util.debug('Default_unapp_on_ac_act_info: ' || 'Default_unapp_on_acc_act_info ()-');
    END IF;

END Default_unapp_on_ac_act_info;

PROCEDURE Derive_activity_unapp_ids(
                         p_receipt_number    IN VARCHAR2,
                         p_cash_receipt_id   IN OUT NOCOPY NUMBER,
                         p_receivable_application_id   IN OUT NOCOPY NUMBER,
                         p_called_from       IN VARCHAR2,
                         p_apply_gl_date     OUT NOCOPY DATE,
                         p_cr_unapp_amount   OUT NOCOPY NUMBER, /* Bug fix 3569640 */
                         p_return_status  OUT NOCOPY VARCHAR2
                               ) IS
l_rec_appln_id  NUMBER ;
l_apply_gl_date  DATE;
l_cash_receipt_id   NUMBER;
BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_activity_unapp_ids ()+');
   END IF;
    --derive the cash_receipt_id from the receipt_number
    IF p_receipt_number IS NOT NULL THEN
        Default_cash_receipt_id(p_cash_receipt_id ,
                                p_receipt_number ,
                                p_return_status);
    END IF;

        --get the receivable application id for the on account application
        --on this cash receipt. If more than one activity application exists
        --for the receipt, raise error.
      /* Bug fix 2512907
         If the receivable_application_id is also passed by the user, do not
         do a generic select. Also receipt write-off unapplication requires
         that applied_payment_schedule_id should be compared with -3 */
      /* Bug 3840287 - credit card refund included */
      IF p_cash_receipt_id IS NOT NULL
           AND p_receivable_application_id IS NULL THEN

           BEGIN
              SELECT receivable_application_id, gl_date
              INTO   l_rec_appln_id , p_apply_gl_date
              FROM   ar_receivable_applications
              WHERE  cash_receipt_id = p_cash_receipt_id
	      and  ((NVL(p_called_from,'RAPI') = 'BR_FACTORED_WITH_RECOURSE' AND
                     applied_payment_schedule_id = -2)
                 or applied_payment_schedule_id IN (-3,-6,-8)
                 or receivables_trx_id = -16)
              and    display = 'Y' and
                     status = 'ACTIVITY';
           EXCEPTION
             WHEN no_data_found THEN
              IF ar_receipt_api_pub.original_activity_unapp_info.cash_receipt_id IS NOT NULL THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
              ELSIF ar_receipt_api_pub.original_activity_unapp_info.receipt_number IS NOT NULL THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_NUM_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
              END IF;
             WHEN too_many_rows THEN
              IF p_receivable_application_id IS NULL THEN
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_MULTIPLE_ACTIVITY_APP');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
              END IF;

           END;

      END IF;

       IF p_receivable_application_id IS NOT NULL THEN

          /* bug fix 2512907
             When a receipt write-off application is unapplied, the applied_payment_schedue_id
             should be compared with -3 */
         /* Bug 2751910 - or its a netting application with receivable_trx_id
                          of -16 */
         /* Bug 3840287 - credit card refund included */
          BEGIN
           SELECT  cash_receipt_id, gl_date
           INTO    l_cash_receipt_id , p_apply_gl_date
           FROM    ar_receivable_applications
           WHERE   receivable_application_id = p_receivable_application_id
	      and  ((NVL(p_called_from,'RAPI') = 'BR_FACTORED_WITH_RECOURSE' AND
                     applied_payment_schedule_id = -2)
                 or applied_payment_schedule_id IN (-3,-6,-8)
                 or receivables_trx_id = -16)
             and   display = 'Y'
             and   status = 'ACTIVITY';
          EXCEPTION
            WHEN no_data_found THEN
               FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
               FND_MSG_PUB.Add;
               p_return_status := FND_API.G_RET_STS_ERROR ;
          END;

         --Compare the two cash_receipt_ids
         IF p_cash_receipt_id IS NOT NULL THEN
            IF p_cash_receipt_id <> NVL(l_cash_receipt_id,p_cash_receipt_id) THEN
                --raise error X validation failed
                FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_RA_ID_X_INVALID');
                FND_MSG_PUB.Add;
                p_return_status := FND_API.G_RET_STS_ERROR ;
            END IF;
         END IF;

       ELSE
        p_receivable_application_id := l_rec_appln_id ;
       END IF;

       IF p_cash_receipt_id IS NULL THEN
          p_cash_receipt_id := l_cash_receipt_id;
       END IF;

       /* Bug fix 3569640 */
       IF p_cash_receipt_id IS NOT NULL THEN
         SELECT SUM(NVL(ra.amount_applied,0))
         INTO  p_cr_unapp_amount
         FROM  ar_receivable_applications ra
         WHERE  ra.cash_receipt_id = p_cash_receipt_id
          AND   ra.status = 'UNAPP'
          AND   nvl(ra.confirmed_flag,'Y') = 'Y';
       END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Derive_activity_unapp_ids ()+');
   END IF;
END Derive_activity_unapp_ids;

PROCEDURE get_doc_seq(p_application_id IN NUMBER,
                      p_document_name  IN VARCHAR2,
                      p_sob_id         IN NUMBER,
                      p_met_code	   IN VARCHAR2,
                      p_trx_date       IN DATE,
                      p_doc_sequence_value IN OUT NOCOPY NUMBER,
                      p_doc_sequence_id    OUT NOCOPY NUMBER,
                      p_return_status      OUT NOCOPY VARCHAR2
                      ) AS
l_doc_seq_ret_stat   NUMBER;
l_doc_sequence_name  VARCHAR2(50);
l_doc_sequence_type  VARCHAR2(50);
l_doc_sequence_value NUMBER;
l_db_sequence_name  VARCHAR2(50);
l_seq_ass_id  NUMBER;
l_prd_tab_name  VARCHAR2(50);
l_aud_tab_name  VARCHAR2(50);
l_msg_flag      VARCHAR2(1);
BEGIN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('get_doc_seq ()+');
               arp_util.debug('get_doc_seq: ' || 'SEQ : '||NVL( pg_profile_doc_seq, 'N'));
               arp_util.debug('get_doc_seq: ' || 'p_document_name :'||p_document_name);
               arp_util.debug('get_doc_seq: ' || 'p_application_id :'||to_char(p_application_id));
               arp_util.debug('get_doc_seq: ' || 'p_sob_id  :'||to_char(p_sob_id));
            END IF;
            p_return_status := FND_API.G_RET_STS_SUCCESS;
	     IF   ( NVL( pg_profile_doc_seq, 'N') <> 'N' )
           THEN
             BEGIN
                      /*------------------------------+
                       |  Get the document sequence.  |
                       +------------------------------*/
              l_doc_seq_ret_stat:=
                   fnd_seqnum.get_seq_info (
		                                 p_application_id,
                                         p_document_name,
                                         p_sob_id,
                                         p_met_code,
                                         trunc(p_trx_date),
                                         p_doc_sequence_id,
                                         l_doc_sequence_type,
                                         l_doc_sequence_name,
                                         l_db_sequence_name,
                                         l_seq_ass_id,
                                         l_prd_tab_name,
                                         l_aud_tab_name,
                                         l_msg_flag,
                                         'Y',
                                         'Y');
             arp_util.debug('Doc sequence return status :'||to_char(nvl(l_doc_seq_ret_stat,-99)));
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('get_doc_seq: ' || 'l_doc_sequence_name :'||l_doc_sequence_name);
             END IF;
             arp_util.debug('l_doc_sequence_id :'||to_char(nvl(p_doc_sequence_id,-99)));

               IF l_doc_seq_ret_stat = -8 THEN
                --this is the case of Always Used
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('get_doc_seq: ' || 'The doc sequence does not exist for the current document');
                 END IF;
                 p_return_status := FND_API.G_RET_STS_ERROR;
                 --Error message
                 FND_MESSAGE.Set_Name( 'AR','AR_RAPI_DOC_SEQ_NOT_EXIST_A');
                 FND_MSG_PUB.Add;
               ELSIF l_doc_seq_ret_stat = -2  THEN
               --this is the case of Partially Used
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('get_doc_seq: ' || 'The doc sequence does not exist for the current document');
                END IF;
                 --Warning
                 IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
                  THEN
                     FND_MESSAGE.SET_NAME('AR','AR_RAPI_DOC_SEQ_NOT_EXIST_P');
                     FND_MSG_PUB.Add;
                 END IF;
               END IF;
               /* Added SUBSTRB(l_doc_sequence_type,1,1) = 'A' in IF
                  for Bug 2667348 */
               /* Bug 3038259:  Above fix did not consider gapless as
                  Automatic type */
                IF ( l_doc_sequence_name IS NOT NULL
                 AND p_doc_sequence_id   IS NOT NULL
                 AND SUBSTRB(l_doc_sequence_type,1,1) in ( 'A', 'G'))
                   THEN
                             /*------------------------------------+
                              |  Automatic Document Numbering case |
                              +------------------------------------*/
                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('get_doc_seq: ' || 'Automatic Document Numbering case ');
                     END IF;
                              l_doc_seq_ret_stat :=
                                  fnd_seqnum.get_seq_val (
		                                               p_application_id,
		                                               p_document_name,
		                                               p_sob_id,
                                                       p_met_code,
                                                       TRUNC(p_trx_date),
                                                       l_doc_sequence_value,
                                                       p_doc_sequence_id);
                      IF p_doc_sequence_value IS NOT NULL THEN
                      --raise an error message because the user is not supposed to pass
                      --in a value for the document sequence number in this case.
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         FND_MESSAGE.Set_Name('AR', 'AR_RAPI_DOC_SEQ_AUTOMATIC');
                         FND_MSG_PUB.Add;
                      END IF;
                        p_doc_sequence_value := l_doc_sequence_value;
                        arp_util.debug('l_doc_sequence_value :'||to_char(nvl(p_doc_sequence_value,-99)));
                   ELSIF (
                       p_doc_sequence_id    IS NOT NULL
                   AND p_doc_sequence_value IS NOT NULL
                       )
                        THEN
                                 /*-------------------------------------+
                                  |  Manual Document Numbering case     |
                                  |  with the document value specified. |
                                  |  Use the specified value.           |
                                  +-------------------------------------*/

                                  NULL;

                   ELSIF (
                         p_doc_sequence_id    IS NOT NULL
                     AND p_doc_sequence_value IS NULL
                      )
                       THEN
                                 /*-----------------------------------------+
                                  |  Manual Document Numbering case         |
                                  |  with the document value not specified. |
                                  |  Generate a document value mandatory    |
                                  |  error.                                 |
                                  +-----------------------------------------*/
                          IF NVL(pg_profile_doc_seq,'N') = 'A' THEN
                                p_return_status := FND_API.G_RET_STS_ERROR;
                                FND_MESSAGE.Set_Name('AR', 'AR_RAPI_DOC_SEQ_VALUE_NULL_A');
                                FND_MESSAGE.Set_Token('SEQUENCE', l_doc_sequence_name);
                                FND_MSG_PUB.Add;
                           ELSIF NVL(pg_profile_doc_seq,'N') = 'P'  THEN
                             --Warning
                             IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS) THEN
                                FND_MESSAGE.SET_NAME('AR','AR_RAPI_DOC_SEQ_VALUE_NULL_P');
                                FND_MSG_PUB.Add;
                             END IF;
                           END IF;


                   END IF;

                   EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                           /*------------------------------------------+
                            |  No document assignment was found.       |
                            |  Generate an error if document numbering |
                            |  is mandatory.                           |
                            +------------------------------------------*/
                         IF PG_DEBUG in ('Y', 'C') THEN
                            arp_util.debug('get_doc_seq: ' || 'no_data_found raised');
                         END IF;
                         IF   (pg_profile_doc_seq = 'A' ) THEN
                            p_return_status := FND_API.G_RET_STS_ERROR;
                            FND_MESSAGE.Set_Name( 'FND','UNIQUE-ALWAYS USED');
                            FND_MSG_PUB.Add;
                         ELSE
                           p_doc_sequence_id    := NULL;
                           p_doc_sequence_value := NULL;
                         END IF;

                   WHEN OTHERS THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('get_doc_seq: ' || 'Unhandled exception in doc sequence assignment');
                     END IF;
                     raise;

                   END;

             END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('get_doc_seq ()+');
  END IF;
END get_doc_seq;

/* modified for tca uptake */
PROCEDURE Derive_cust_info_from_trx(
                                p_customer_trx_id               IN ar_payment_schedules.customer_trx_id%TYPE,
                                p_trx_number                    IN ra_customer_trx.trx_number%TYPE,
                                p_installment                   IN ar_payment_schedules.terms_sequence_number%TYPE,
                                p_applied_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE,
                                p_currency_code               IN ar_cash_receipts.currency_code%TYPE,
                                p_customer_id                OUT NOCOPY ar_payment_schedules.customer_id%TYPE,
                                p_customer_site_use_id       OUT NOCOPY hz_cust_site_uses.site_use_id%TYPE,
                                p_return_status              OUT NOCOPY  VARCHAR2
                                 )IS
/* modified for tca uptake */
--  Variables addition for Bug 1907635
l_sel_stmt long;
trx_customer INTEGER;
l_rows_processed INTEGER;
-- End of variables addition for Bug 1907635
l_customer_trx_id  NUMBER;
BEGIN
    -- Bug 1907635
    -- Build the query dynamically based on the input parameters
    l_sel_stmt := '
              SELECT ps.customer_id,
                     ps.customer_site_use_id
              FROM   hz_cust_site_uses su,
                     hz_cust_accounts cust_acct,
                     ra_cust_trx_types ctt,
                     ar_payment_schedules ps
              WHERE  su.site_use_id = ps.customer_site_use_id
                 and cust_acct.cust_account_id = ps.customer_id
                 and ctt.cust_trx_type_id = ps.cust_trx_type_id
                 and ps.selected_for_receipt_batch_id is null
                 and ps.class in (''BR'',''CB'',''CM'',''DEP'',''DM'',''INV'')
                 and ps.invoice_currency_code = decode(nvl(:pg_profile_enable_cc, ''N''), ''Y'',
                     decode(ps.class, ''CM'', :p_currency_code, ps.invoice_currency_code), :p_currency_code)
                 and ps.status = ''OP'' ';

   IF p_applied_payment_schedule_id IS NOT NULL THEN
      l_sel_stmt := l_sel_stmt || ' and ps.payment_schedule_id = :applied_ps_id ';
   END IF;
   IF p_customer_trx_id IS NOT NULL THEN
      l_sel_stmt := l_sel_stmt || ' and ps.customer_trx_id =  :cust_trx_id ';
   END IF;
   IF p_installment IS NOT NULL THEN
      l_sel_stmt := l_sel_stmt || ' and ps.terms_sequence_number =  :inst ';
   END IF;

   trx_customer := dbms_sql.open_cursor;
   dbms_sql.parse(trx_customer, l_sel_stmt, dbms_sql.v7);
   /* Bugfix 2605347 */
   dbms_sql.bind_variable(trx_customer,':pg_profile_enable_cc', pg_profile_enable_cc);
   dbms_sql.bind_variable(trx_customer,':p_currency_code', p_currency_code);
   IF p_applied_payment_schedule_id IS NOT NULL THEN
     dbms_sql.bind_variable(trx_customer,':applied_ps_id',p_applied_payment_schedule_id);
   END IF;
   IF p_customer_trx_id IS NOT NULL THEN
     dbms_sql.bind_variable(trx_customer, ':cust_trx_id', p_customer_trx_id);
   END IF;
   IF p_installment IS NOT NULL THEN
     dbms_sql.bind_variable(trx_customer, ':inst', p_installment);
   END IF;
   dbms_sql.define_column(trx_customer,1,p_customer_id);
   dbms_sql.define_column(trx_customer,2,p_customer_site_use_id);
   -- End of bug 1907635

 p_return_status := FND_API.G_RET_STS_SUCCESS;
 l_customer_trx_id := p_customer_trx_id;
  IF  p_trx_number  IS NOT NULL THEN
    Default_customer_trx_id(l_customer_trx_id ,
                            p_trx_number ,
                            p_return_status);
  END IF;

 IF  p_return_status = FND_API.G_RET_STS_SUCCESS THEN
  IF    p_applied_payment_schedule_id IS NOT NULL AND
        l_customer_trx_id IS NULL AND
        p_installment IS NULL THEN
        -- Bug 1907635
          l_rows_processed := dbms_sql.execute(trx_customer);
          IF dbms_sql.fetch_rows(trx_customer) > 0 then
            dbms_sql.column_value(trx_customer, 1, p_customer_id);
            dbms_sql.column_value(trx_customer, 2, p_customer_site_use_id);
          ELSE
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name( 'AR','AR_RAPI_PSID_NOT_DEF_CUS');
            FND_MSG_PUB.Add;
          END IF;
          dbms_sql.close_cursor(trx_customer);
         -- End Bug 1907635
  ELSIF p_applied_payment_schedule_id IS NOT NULL AND
        l_customer_trx_id IS NOT NULL AND
        p_installment IS NOT NULL THEN
        -- Bug 1907635
          l_rows_processed := dbms_sql.execute(trx_customer);
          IF dbms_sql.fetch_rows(trx_customer) > 0 then
            dbms_sql.column_value(trx_customer, 1, p_customer_id);
            dbms_sql.column_value(trx_customer, 2, p_customer_site_use_id);
          ELSE
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name( 'AR','AR_RAPI_TRX_INS_PS_NOT_DEF_CUS');
            FND_MSG_PUB.Add;
          END IF;
          dbms_sql.close_cursor(trx_customer);
         -- End Bug 1907635
  ELSIF p_applied_payment_schedule_id IS NOT NULL AND
        l_customer_trx_id IS NOT NULL AND
        p_installment IS NULL THEN
        -- Bug 1907635
          l_rows_processed := dbms_sql.execute(trx_customer);
          IF dbms_sql.fetch_rows(trx_customer) > 0 then
            dbms_sql.column_value(trx_customer, 1, p_customer_id);
            dbms_sql.column_value(trx_customer, 2, p_customer_site_use_id);
          ELSE
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name( 'AR','AR_RAPI_TRX_PS_NOT_DEF_CUS');
            FND_MSG_PUB.Add;
          END IF;
          dbms_sql.close_cursor(trx_customer);
         -- End Bug 1907635
  ELSIF p_applied_payment_schedule_id IS NOT NULL AND
        l_customer_trx_id IS NULL AND
        p_installment IS NOT NULL THEN
        -- Bug 1907635
          l_rows_processed := dbms_sql.execute(trx_customer);
          IF dbms_sql.fetch_rows(trx_customer) > 0 then
            dbms_sql.column_value(trx_customer, 1, p_customer_id);
            dbms_sql.column_value(trx_customer, 2, p_customer_site_use_id);
          ELSE
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name( 'AR','AR_RAPI_INS_PS_NOT_DEF_CUS');
            FND_MSG_PUB.Add;
          END IF;
          dbms_sql.close_cursor(trx_customer);
         -- End Bug 1907635
  ELSIF p_applied_payment_schedule_id IS NULL AND
        l_customer_trx_id IS NOT NULL AND
        p_installment IS NOT NULL THEN
        -- Bug 1907635
          l_rows_processed := dbms_sql.execute(trx_customer);
          IF dbms_sql.fetch_rows(trx_customer) > 0 then
            dbms_sql.column_value(trx_customer, 1, p_customer_id);
            dbms_sql.column_value(trx_customer, 2, p_customer_site_use_id);
          ELSE
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name( 'AR','AR_RAPI_TRX_INS_NOT_DEF_CUS');
            FND_MSG_PUB.Add;
          END IF;
          dbms_sql.close_cursor(trx_customer);
         -- End Bug 1907635
  ELSIF p_applied_payment_schedule_id IS NULL AND
        l_customer_trx_id IS NOT NULL AND
        p_installment IS NULL THEN
        -- Bug 1907635
          l_rows_processed := dbms_sql.execute(trx_customer);
          IF dbms_sql.fetch_rows(trx_customer) > 0 then
            dbms_sql.column_value(trx_customer, 1, p_customer_id);
            dbms_sql.column_value(trx_customer, 2, p_customer_site_use_id);
          ELSE
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name( 'AR','AR_RAPI_PSID_NOT_DEF_CUS');
            FND_MSG_PUB.Add;
          END IF;
          dbms_sql.close_cursor(trx_customer);
         -- End Bug 1907635
  ELSE
         -- Bug 1907635
         dbms_sql.close_cursor(trx_customer);
         -- End Bug 1907635
        p_customer_id := NULL;
        p_customer_site_use_id := NULL;
  END IF;
 END IF;

     IF p_customer_id IS NULL THEN
        --raise error because application cant be done against an unidentified receipt
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name( 'AR','AR_RAPI_CUST_ID_NULL');
        FND_MSG_PUB.Add;
     END IF;

  pg_cust_derived_from := 'TRANSACTION';

END Derive_cust_info_from_trx;

PROCEDURE Default_misc_ids(
              p_usr_currency_code            IN      VARCHAR2,
              p_usr_exchange_rate_type       IN      VARCHAR2,
              p_activity                     IN      VARCHAR2,
              p_reference_type               IN      VARCHAR2,
              p_reference_num                IN      VARCHAR2,
              p_tax_code                     IN      VARCHAR2,
              p_receipt_method_name          IN OUT NOCOPY  VARCHAR2,
              p_remittance_bank_account_name IN      VARCHAR2,
              p_remittance_bank_account_num  IN      VARCHAR2,
              p_currency_code                IN OUT NOCOPY  VARCHAR2,
              p_exchange_rate_type           IN OUT NOCOPY  VARCHAR2,
              p_receivables_trx_id           IN OUT NOCOPY  NUMBER,
              p_reference_id                 IN OUT NOCOPY  NUMBER,
              p_vat_tax_id                   IN OUT NOCOPY  NUMBER,
              p_receipt_method_id            IN OUT NOCOPY  NUMBER,
              p_remittance_bank_account_id   IN OUT NOCOPY  NUMBER,
              p_return_status                   OUT NOCOPY  VARCHAR2,
              p_receipt_date                 IN DATE DEFAULT NULL
                       )
IS
l_remittance_bank_account_id NUMBER;
l_receipt_method_id          NUMBER;
l_return_status              VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_get_id_return_status       VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_get_x_val_return_status    VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
l_le_id                        NUMBER;
BEGIN
p_return_status := FND_API.G_RET_STS_SUCCESS;

--Receivable Activity Name /Id.
 IF p_receivables_trx_id IS NULL THEN
    IF p_activity IS NOT NULL THEN
      p_receivables_trx_id:= Get_Id('RECEIVABLES_ACTIVITY',
                                     p_activity,
                                     l_get_id_return_status
                                    );
     IF p_receivables_trx_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

    END IF;

 ELSE
    IF (p_activity IS NOT NULL) THEN
       --give a warning message to indicate that the activity name
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
        THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_ACTIVITY_IGN');
         FND_MSG_PUB.Add;
       END IF;
    END IF;

 END IF;

--Receipt method ID,Name
 IF p_receipt_method_id IS NULL
  THEN
   IF p_receipt_method_name IS NOT NULL THEN
      p_receipt_method_id := Get_Id('RECEIPT_METHOD_NAME',
                                     p_receipt_method_name,
                                     l_get_id_return_status
                                    );
     IF p_receipt_method_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_MD_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;

 ELSE
    IF (p_receipt_method_name IS NOT NULL) THEN
       --give a warning message to indicate that the receipt_method_name
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
        THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_MD_NAME_IGN');
         FND_MSG_PUB.Add;
       END IF;
    ELSE
        BEGIN
         SELECT name
         INTO   p_receipt_method_name
         FROM   ar_receipt_methods
         WHERE  receipt_method_id = p_receipt_method_id;
        EXCEPTION
         WHEN no_data_found THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Default_misc_ids: ' || 'Invalid receipt method id');
          END IF;
           null;
        END;

    END IF;
 END IF;

--Remittance bank account Number,Name,ID

 IF p_remittance_bank_account_id IS NULL
  THEN
  IF(p_remittance_bank_account_name IS NOT NULL) and
     (p_remittance_bank_account_num IS NULL)
    THEN
      p_remittance_bank_account_id := Get_Id('REMIT_BANK_ACCOUNT_NAME',
                                             p_remittance_bank_account_name,
                                             l_get_id_return_status
                                            );
     IF p_remittance_bank_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_NAME_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  ELSIF(p_remittance_bank_account_name IS  NULL) and
        (p_remittance_bank_account_num IS NOT NULL)
    THEN
      p_remittance_bank_account_id := Get_Id('REMIT_BANK_ACCOUNT_NUMBER',
                                              p_remittance_bank_account_num,
                                              l_get_id_return_status
                                             );
     IF p_remittance_bank_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_NUM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSIF(p_remittance_bank_account_name IS NOT NULL) and
        (p_remittance_bank_account_num IS NOT NULL)
    THEN
      p_remittance_bank_account_id := Get_Cross_Validated_Id( 'REMIT_BANK_ACCOUNT',
                                               p_remittance_bank_account_num,
                                               p_remittance_bank_account_name,
                                               l_get_x_val_return_status
                                              );
     IF p_remittance_bank_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_2_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;

 ELSE

   IF (p_remittance_bank_account_name IS NOT NULL) OR
      (p_remittance_bank_account_num IS NOT NULL)
    THEN
       --give a warning message to indicate that the remittance_bank_account_num and
       --remittance_bank_account_name entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
        THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_REM_BK_AC_NAME_NUM_IGN');
         FND_MSG_PUB.Add;
       END IF;
   END IF;

 END IF;

 /* Initialize ZX */
   l_le_id :=
         ar_receipt_lib_pvt.get_legal_entity(p_remittance_bank_account_id);

-- Exchange_rate_type
 IF p_exchange_rate_type IS NULL THEN
   IF p_usr_exchange_rate_type IS NOT NULL
    THEN
      p_exchange_rate_type := Get_Id('EXCHANGE_RATE_TYPE_NAME', /* Bug fix 2982212*/
                                     p_usr_exchange_rate_type,
                                     l_get_id_return_status
                                    );
      IF p_exchange_rate_type IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_X_RATE_TYP_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END IF;

 ELSE
   IF  (p_usr_exchange_rate_type IS NOT NULL) THEN
       --give a warning message to indicate that the usr_exchange_rate_type
       -- entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
        THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_X_RATE_TYPE_IGN');
         FND_MSG_PUB.Add;
       END IF;
   END IF;

 END IF;

--Currency code
 IF p_currency_code IS NULL THEN
   IF p_usr_currency_code IS NOT NULL
    THEN
      p_currency_code :=     Get_Id('CURRENCY_NAME',
                                     p_usr_currency_code,
                                     l_get_id_return_status
                                    );
      IF p_currency_code IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_CURR_CODE_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   ELSE

     p_currency_code := arp_global.functional_currency;
     --Raise a warning message saying that currency was defaulted
     IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
       THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_FUNC_CURR_DEFAULTED');
        FND_MSG_PUB.Add;
     END IF;

   END IF;

 ELSE
   IF  (p_usr_currency_code IS NOT NULL) THEN

       --give a warning message to indicate that the usr_currency_code
       -- entered by the user have been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
        THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_USR_CURR_CODE_IGN');
         FND_MSG_PUB.Add;
       END IF;

   END IF;
 END IF;

--Reference Number, ID
--Based on the reference type, the corresponding reference id
--will be derived from the reference number.
 IF p_reference_id IS NULL THEN
  IF p_reference_num IS NOT NULL THEN

   IF p_reference_type = 'PAYMENT' THEN
       p_reference_id :=    to_number(Get_Id('REF_PAYMENT',
                                     p_reference_num,
                                     l_get_id_return_status)
                                    );
   ELSIF p_reference_type = 'PAYMENT_BATCH'  THEN
      --
      p_reference_id :=     to_number(Get_Id('REF_PAYMENT_BATCH',
                                    p_reference_num,
                                    l_get_id_return_status)
                                    );
   ELSIF p_reference_type = 'RECEIPT'  THEN
      --
      p_reference_id :=    to_number(Get_Id('REF_RECEIPT',
                                    p_reference_num,
                                    l_get_id_return_status
                                    ));
   ELSIF p_reference_type = 'REMITTANCE' THEN
      --
      p_reference_id :=     to_number(Get_Id('REF_REMITTANCE',
                                    p_reference_num,
                                    l_get_id_return_status
                                    ));
   END IF;

   IF p_reference_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_REF_NUM_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

  END IF;

 ELSE
   IF  (p_reference_num IS NOT NULL) THEN

       --give a warning message to indicate that the reference number
       -- entered by the user have been ignored.
 --    This warning message is coming as an error in the form. So commenting out NOCOPY

/*    IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
        THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_REF_NUM_IGN');
         FND_MSG_PUB.Add;
       END IF;
*/
       null;

   END IF;
 END IF;


END Default_misc_ids;

PROCEDURE Get_misc_defaults(
              p_currency_code                IN OUT NOCOPY  VARCHAR2,
              p_exchange_rate_type           IN OUT NOCOPY  VARCHAR2,
              p_exchange_rate                IN OUT NOCOPY  NUMBER,
              p_exchange_date                IN OUT NOCOPY  DATE,
              p_amount                       IN OUT NOCOPY  NUMBER,
              p_receipt_date                 IN OUT NOCOPY  DATE,
              p_gl_date                      IN OUT NOCOPY  DATE,
              p_remittance_bank_account_id   IN OUT NOCOPY  NUMBER,
              p_deposit_date                 IN OUT NOCOPY  DATE,
              p_state                        IN OUT NOCOPY  VARCHAR2,
              p_distribution_set_id          IN OUT NOCOPY  NUMBER,
              p_vat_tax_id                   IN OUT NOCOPY  NUMBER,
              p_tax_rate                     IN OUT NOCOPY  NUMBER,
              p_receipt_method_id            IN      NUMBER,
              p_receivables_trx_id           IN      NUMBER,
              p_tax_code                     IN      VARCHAR2,
              p_tax_amount                   IN      NUMBER,
              p_creation_method_code            OUT NOCOPY  VARCHAR2,
              p_return_status                   OUT NOCOPY  VARCHAR2
                        )
IS
 l_def_curr_return_status   VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
 l_def_rm_return_status     VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
 l_def_gl_dt_return_status  VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
 l_tax_rt_amt_x_ret_status  VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
 l_tax_amount               NUMBER;
 /* Bug fix 3315058 */
 l_bank_acc_val_ret_status   VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
 l_misc_activity_status      VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
 l_misc_tax_status           VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
 l_code_combination_id	     NUMBER;
 l_message		     VARCHAR2(100);
 l_le_id                     NUMBER;  /* bug 4594101 */
 l_get_id_return_status       VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
 l_zx_msg_count                 NUMBER;
 l_zx_msg_data                  VARCHAR2(1024);
 l_zx_effective_date            DATE;
 l_zx_return_status             VARCHAR2(10);

 /*Bug 5598297 */
 l_source_code ar_receivables_trx.gl_account_source%type;
 l_dist_set_id ar_receivables_trx.default_acctg_distribution_set%type;

     CURSOR get_dist_ccid(p_dist_id NUMBER) IS
     SELECT dist_code_combination_id
     FROM ar_distribution_set_lines
     WHERE distribution_set_id  = p_distribution_set_id;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Get_misc_Defaults()+ ');
   END IF;
   p_return_status := FND_API.G_RET_STS_SUCCESS;
  -- default the receipt date if NULL
  IF (p_receipt_date IS NULL)
    THEN
    Select trunc(sysdate)
    into p_receipt_date
    from dual;
  END IF;

  -- default the gl_date
  IF p_gl_date IS NULL THEN
    Default_gl_date(p_receipt_date,
                    p_gl_date,
                    NULL,
                    l_def_gl_dt_return_status);
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Get_misc_defaults: ' || 'l_default_gl_date_return_status : '||l_def_gl_dt_return_status);
    END IF;
  END IF;

  IF (p_deposit_date IS NULL)
    THEN
    p_deposit_date := p_receipt_date;
  END IF;


 -- Default the Currency parameters
    Default_Currency_info(p_currency_code,
                          p_receipt_date,
                          p_exchange_date,
                          p_exchange_rate_type,
                          p_exchange_rate,
                          l_def_curr_return_status
                         );

 --Set the precision of the receipt amount as per currency
  IF p_amount is NOT NULL THEN
   p_amount := arp_util.CurrRound( p_amount,
                                   p_currency_code
                                  );
  END IF;

 --Default the Receipt Method related parameters
   Default_Receipt_Method_info(p_receipt_method_id,
                               p_currency_code,
                               p_receipt_date,
                               p_remittance_bank_account_id,
                               p_state,
                               p_creation_method_code,
                               'MISC',
                               l_def_rm_return_status
                                );

  /* Bug fix 3315058 */
   Validate_Receipt_Method_ccid(p_receipt_method_id,
                                p_remittance_bank_account_id,
                                p_gl_date,
                                l_bank_acc_val_ret_status);

  /*------------------------------------------+
   |  Get legal_entity_id                     |
   +------------------------------------------*/
   l_le_id :=
         ar_receipt_lib_pvt.get_legal_entity(p_remittance_bank_account_id);

   /* 5955921 Remittance_bank_account info is not passed by the user then the system will not default
   the vat_tax_id based on the user tax_code. Hence moving the below set_tax_security_context
   from Default_misc_ids to Get_misc_defaults procedure.  */
   zx_api_pub.set_tax_security_context(
           p_api_version      => 1.0,
           p_init_msg_list    => 'T',
           p_commit           => 'F',
           p_validation_level => NULL,
           x_return_status    => l_zx_return_status,
           x_msg_count        => l_zx_msg_count,
           x_msg_data         => l_zx_msg_data,
           p_internal_org_id  => arp_standard.sysparm.org_id,
           p_legal_entity_id  => l_le_id,
           p_transaction_date => p_receipt_date,
           p_related_doc_date => NULL,
           p_adjusted_doc_date=> NULL,
           x_effective_date   => l_zx_effective_date);
 /* End - init */

-- Moved tax default below remittance bank account
-- so we could have LE and init ZX beforehand
-- ETAX: Bug 4594101:  Added p_receipt_date to call.
--Vat Tax Id, Tax code
 IF p_vat_tax_id IS NULL THEN
   IF p_tax_code IS NOT NULL THEN
     p_vat_tax_id := Get_Id('TAX_CODE',
                             p_tax_code,
                             l_get_id_return_status,
                             p_receipt_date
                              );
     IF p_vat_tax_id IS NULL THEN
       FND_MESSAGE.SET_NAME('AR','AR_RAPI_TAX_CODE_INVALID');
       FND_MSG_PUB.Add;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
 ELSE
    IF (p_tax_code IS NOT NULL) THEN
       --give a warning message to indicate that the tax_code
       --entered by the user has been ignored.
       IF FND_MSG_PUB.Check_Msg_Level(G_MSG_SUCCESS)
        THEN
         FND_MESSAGE.SET_NAME('AR','AR_RAPI_TAX_CODE_IGN');
         FND_MSG_PUB.Add;
       END IF;
    END IF;

 END IF;

 --Default the vat_tax_id from the receivable_trx_id.

  IF ( p_receivables_trx_id IS NOT NULL AND p_vat_tax_id IS NULL  AND
     p_tax_code IS NULL)  THEN --the second condition reflects that the
                               --user had not entered any tax code

    IF (arp_legal_entity_util.Is_LE_Subscriber) THEN
       BEGIN
         /* 5236782 - made details not required for misc receipts */
         SELECT vat.tax_rate_id
           INTO   p_vat_tax_id
           FROM   ar_receivables_trx rt,
                  ar_rec_trx_le_details details,
                  zx_sco_rates vat
           WHERE  rt.receivables_trx_id = p_receivables_trx_id
             AND  rt.receivables_trx_id = details.receivables_trx_id (+)
             AND  details.legal_entity_id (+) = l_le_id
             AND  rt.type in ('MISCCASH', 'BANK_ERROR')
             AND  nvl(rt.status, 'A') = 'A'
             AND  vat.tax_rate_code = decode(sign(p_amount),
                                         1, nvl(details.asset_tax_code,
                                                rt.asset_tax_code),
                                         0, nvl(details.asset_tax_code,
                                                rt.asset_tax_code),
                                        -1, nvl(details.liability_tax_code,
                                                rt.liability_tax_code))
	     AND  nvl(vat.active_flag, 'Y') = 'Y'		/* 4400063 */
             AND  p_receipt_date between
                         nvl(vat.effective_from, p_receipt_date)
                     and nvl(vat.effective_to, p_receipt_date);

       EXCEPTION
         WHEN no_data_found THEN
          null;
         WHEN others THEN
          raise;
       END;
    ELSE
       BEGIN
         SELECT vat.tax_rate_id
           INTO   p_vat_tax_id
           FROM   ar_receivables_trx rt,
                  zx_sco_rates vat
           WHERE  rt.receivables_trx_id = p_receivables_trx_id
             AND  rt.type in ('MISCCASH', 'BANK_ERROR')
             AND  nvl(rt.status, 'A') = 'A'
             AND  vat.tax_rate_code(+) = decode(sign(p_amount),
                                                1, rt.asset_tax_code,
                                                0, rt.asset_tax_code,
                                               -1, rt.liability_tax_code)
             AND  p_receipt_date between
                         nvl(vat.effective_from, p_receipt_date)
                     and nvl(vat.effective_to, p_receipt_date);

       EXCEPTION
         WHEN no_data_found THEN
          null;
         WHEN others THEN
          raise;
       END;
    END IF;

  END IF;

/*Bug3315058 After getting vat tax id and receivables trx id */

   /*Bug 5598297 distribution set id was never initialized */
   IF p_distribution_set_id is NULL THEN
     Begin
         select gl_account_source,default_acctg_distribution_set into
                l_source_code, l_dist_set_id
         from ar_receivables_trx
         where  receivables_trx_id = nvl(p_receivables_trx_id,-99);
         IF l_source_code = 'DISTRIBUTION_SET' THEN
            p_distribution_set_id := l_dist_set_id;
         ELSE
            p_distribution_set_id := NULL;
         END IF;
     Exception
     when others then
       null;
     END;
   END IF;
   IF p_receivables_trx_id IS NOT NULL THEN
      IF p_distribution_set_id IS NULL THEN
	  BEGIN
	      select code_combination_id
                into l_code_combination_id
 	        from ar_receivables_trx
               where receivables_trx_id=p_receivables_trx_id;

              l_message := 'AR_ACT_GL_ACC_ASSGN';
              validate_cc_segments(l_code_combination_id,
                                   p_gl_date,
                                   l_message,
                                   l_misc_activity_status);
	   EXCEPTION
	      WHEN OTHERS THEN
		l_code_combination_id:=NULL;
		l_misc_activity_status:=FND_API.G_RET_STS_ERROR;
	   END;
      ELSE
          l_message := 'AR_GL_ACC_ASSGN_DISB_SET';
          OPEN get_dist_ccid(p_distribution_set_id);
	  IF get_dist_ccid%NOTFOUND THEN
	     l_misc_activity_status:=FND_API.G_RET_STS_ERROR;
	     l_code_combination_id:=NULL;
	  ELSE
             LOOP
                FETCH  get_dist_ccid INTO l_code_combination_id;
                EXIT WHEN get_dist_ccid%NOTFOUND;
                validate_cc_segments(l_code_combination_id,
                                     p_gl_date,
                                     l_message,
                                     l_misc_activity_status);
		IF l_misc_activity_status <> FND_API.G_RET_STS_SUCCESS THEN
	     	    l_misc_activity_status:=FND_API.G_RET_STS_ERROR;
		    EXIT;
		END IF;
             END LOOP;
	  END IF;
          CLOSE get_dist_ccid;
      END IF;
      IF p_vat_tax_id IS NOT NULL THEN
         BEGIN

            l_code_combination_id := arp_etax_util.get_tax_account(
                            p_subject_id      => p_vat_tax_id,
                            p_gl_date         => p_gl_date,
                            p_desired_account => 'TAX',
                            p_subject_table   => 'TAX_RATE');

   	    l_message := 'AR_TAX_ACC_ASSGN';
   	    validate_cc_segments(l_code_combination_id,
                                 p_gl_date,
                                 l_message,
                                 l_misc_tax_status);
        EXCEPTION
	WHEN OTHERS THEN
           l_code_combination_id := NULL;
	   l_misc_tax_status:=FND_API.G_RET_STS_ERROR;
        END;
      END IF;
  END IF;
  /* End of Bug3315058*/
   IF p_tax_amount IS NOT NULL THEN

      l_tax_amount := arp_util.CurrRound( p_tax_amount,
                                        p_currency_code
                                      );
   END IF;

  --Derive the tax rate from the tax_amount and the total receipt amount
  --also do the cross validation between the tax_amount,tax_rate and amount.

   IF p_tax_rate   IS NULL and
      l_tax_amount IS NOT NULL and
      p_amount     IS NOT NULL THEN

      p_tax_rate := Round(
                      (100 * (l_tax_amount/p_amount)) / ( 1 - (l_tax_amount/p_amount)),
                        3);
   ELSIF p_tax_rate   IS NOT NULL and
         l_tax_amount IS NOT NULL and
         p_amount     IS NOT NULL THEN

         IF round(p_tax_rate*p_amount,3) <> p_tax_amount THEN
            l_tax_rt_amt_x_ret_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_TAX_RATE_AMT_X_INVALID');
            FND_MSG_PUB.Add;
         END IF;
   END IF;


  IF l_def_rm_return_status <> FND_API.G_RET_STS_SUCCESS OR
     l_def_gl_dt_return_status <> FND_API.G_RET_STS_SUCCESS OR
     l_def_curr_return_status <> FND_API.G_RET_STS_SUCCESS  OR
     l_tax_rt_amt_x_ret_status <> FND_API.G_RET_STS_SUCCESS OR
     l_misc_activity_status <> FND_API.G_RET_STS_SUCCESS OR      /* Bug fix 3315058 */
     l_misc_tax_status <> FND_API.G_RET_STS_SUCCESS OR
     l_bank_acc_val_ret_status <>  FND_API.G_RET_STS_SUCCESS THEN /* Bug fix 3315058 */
       p_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Get_misc_defaults: ' || '************Cash Defaults********************');
     arp_util.debug('Get_misc_defaults: ' || 'p_receipt_date               : '||to_char(p_receipt_date,'DD-MON-YYYY'));
     arp_util.debug('Get_misc_defaults: ' || 'p_gl_date                    : '||to_char(p_gl_date,'DD-MON-YYYY'));
     arp_util.debug('Get_misc_defaults: ' || 'p_deposit_date               : '||to_char(p_deposit_date,'DD-MON-YYYY'));
     arp_util.debug('Get_misc_defaults: ' || 'p_currency_code              : '||p_currency_code);
     arp_util.debug('Get_misc_defaults: ' || 'p_exchange_rate_date         : '||to_char(p_exchange_date,'DD-MON-YYYY'));
     arp_util.debug('Get_misc_defaults: ' || 'p_exchange_rate_type         : '||p_exchange_rate_type);
     arp_util.debug('Get_misc_defaults: ' || 'p_exchange_rate              : '||to_char(p_exchange_rate));
     arp_util.debug('Get_misc_defaults: ' || 'p_receipt_method_id          : '||to_char(p_receipt_method_id));
     arp_util.debug('Get_misc_defaults: ' || 'p_remittance_bank_account_id : '||to_char(p_remittance_bank_account_id));
     arp_util.debug('Get_misc_defaults: ' || 'p_state                      : '||p_state);
     arp_util.debug('Get_misc_Defaults ()-');
  END IF;

END Get_misc_defaults;

PROCEDURE Validate_Desc_Flexfield(
                          p_desc_flex_rec       IN OUT NOCOPY  ar_receipt_api_pub.attribute_rec_type,
                          p_desc_flex_name      IN VARCHAR2,
                          p_return_status       IN OUT NOCOPY  varchar2
                         ) IS

l_flex_name     fnd_descriptive_flexs.descriptive_flexfield_name%type;
l_count         NUMBER;
l_col_name     VARCHAR2(50);
l_flex_exists  VARCHAR2(1);
CURSOR desc_flex_exists IS
  SELECT 'Y'
  FROM fnd_descriptive_flexs
  WHERE application_id = 222
    and descriptive_flexfield_name = p_desc_flex_name;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_Desc_Flexfield ()+');
    END IF;
      p_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN desc_flex_exists;
      FETCH desc_flex_exists INTO l_flex_exists;
      IF desc_flex_exists%NOTFOUND THEN
       CLOSE desc_flex_exists;
        FND_MESSAGE.SET_NAME('AR', 'AR_RAPI_DESC_FLEX_INVALID');
        FND_MESSAGE.SET_TOKEN('DFF_NAME',p_desc_flex_name);
        FND_MSG_PUB.ADD ;
        p_return_status :=  FND_API.G_RET_STS_ERROR;
       return;
      END IF;
      CLOSE desc_flex_exists;


     fnd_flex_descval.set_context_value(p_desc_flex_rec.attribute_category);

     fnd_flex_descval.set_column_value('ATTRIBUTE1', p_desc_flex_rec.attribute1);
     fnd_flex_descval.set_column_value('ATTRIBUTE2', p_desc_flex_rec.attribute2);
     fnd_flex_descval.set_column_value('ATTRIBUTE3', p_desc_flex_rec.attribute3);
     fnd_flex_descval.set_column_value('ATTRIBUTE4', p_desc_flex_rec.attribute4);
     fnd_flex_descval.set_column_value('ATTRIBUTE5', p_desc_flex_rec.attribute5);
     fnd_flex_descval.set_column_value('ATTRIBUTE6', p_desc_flex_rec.attribute6);
     fnd_flex_descval.set_column_value('ATTRIBUTE7', p_desc_flex_rec.attribute7);
     fnd_flex_descval.set_column_value('ATTRIBUTE8', p_desc_flex_rec.attribute8);
     fnd_flex_descval.set_column_value('ATTRIBUTE9', p_desc_flex_rec.attribute9);
     fnd_flex_descval.set_column_value('ATTRIBUTE10', p_desc_flex_rec.attribute10);
     fnd_flex_descval.set_column_value('ATTRIBUTE11',p_desc_flex_rec.attribute11);
     fnd_flex_descval.set_column_value('ATTRIBUTE12', p_desc_flex_rec.attribute12);
     fnd_flex_descval.set_column_value('ATTRIBUTE13', p_desc_flex_rec.attribute13);
     fnd_flex_descval.set_column_value('ATTRIBUTE14', p_desc_flex_rec.attribute14);
     fnd_flex_descval.set_column_value('ATTRIBUTE15', p_desc_flex_rec.attribute15);
    /* Bugfix 2531340 */
    IF ( NOT fnd_flex_descval.validate_desccols('AR',p_desc_flex_name,'I') )
     THEN

       FND_MESSAGE.SET_NAME('AR', 'AR_RAPI_DESC_FLEX_INVALID');
       FND_MESSAGE.SET_TOKEN('DFF_NAME',p_desc_flex_name);
       FND_MSG_PUB.ADD ;
       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

      l_count := fnd_flex_descval.segment_count;

      FOR i in 1..l_count LOOP
        l_col_name := fnd_flex_descval.segment_column_name(i);

        /* Bug fix 3184559
           The calls to fnd_flex_descval.segment_value(i) are replaced with
           fnd_flex_descval.segment_id(i)*/
        IF l_col_name = 'ATTRIBUTE1' THEN
          p_desc_flex_rec.attribute1 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE_CATEGORY'  THEN
          /* Bugfix 2531340 */
          p_desc_flex_rec.attribute_category := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE2' THEN
          p_desc_flex_rec.attribute2 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE3' THEN
          p_desc_flex_rec.attribute3 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE4' THEN
          p_desc_flex_rec.attribute4 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE5' THEN
          p_desc_flex_rec.attribute5 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE6' THEN
          p_desc_flex_rec.attribute6 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE7' THEN
          p_desc_flex_rec.attribute7 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE8' THEN
          p_desc_flex_rec.attribute8 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE9' THEN
          p_desc_flex_rec.attribute9 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE10' THEN
          p_desc_flex_rec.attribute10 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE11' THEN
          p_desc_flex_rec.attribute11 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE12' THEN
          p_desc_flex_rec.attribute12 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE13' THEN
          p_desc_flex_rec.attribute13 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE14' THEN
          p_desc_flex_rec.attribute14 := fnd_flex_descval.segment_id(i);
        ELSIF l_col_name = 'ATTRIBUTE15' THEN
          p_desc_flex_rec.attribute15 := fnd_flex_descval.segment_id(i);
        END IF;

        IF i > l_count  THEN
          EXIT;
        END IF;
       END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute_category  : '||p_desc_flex_rec.attribute_category);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute1          : '||p_desc_flex_rec.attribute1);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute2          : '||p_desc_flex_rec.attribute2);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute3          : '||p_desc_flex_rec.attribute3);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute4          : '||p_desc_flex_rec.attribute4);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute5          : '||p_desc_flex_rec.attribute5);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute6          : '||p_desc_flex_rec.attribute6);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute7          : '||p_desc_flex_rec.attribute7);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute8          : '||p_desc_flex_rec.attribute8);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute9          : '||p_desc_flex_rec.attribute9);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute10         : '||p_desc_flex_rec.attribute10);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute11         : '||p_desc_flex_rec.attribute11);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute12         : '||p_desc_flex_rec.attribute12);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute13         : '||p_desc_flex_rec.attribute13);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute14         : '||p_desc_flex_rec.attribute14);
           arp_util.debug('Validate_Desc_Flexfield: ' || 'attribute15         : '||p_desc_flex_rec.attribute15);
      arp_util.debug('Validate_Desc_Flexfield ()-');
   END IF;
END Validate_Desc_Flexfield;

/* Bug fix 3539008 */
PROCEDURE Default_Desc_Flexfield(
              p_desc_flex_rec                OUT NOCOPY  ar_receipt_api_pub.attribute_rec_type,
              p_cash_receipt_id              IN      NUMBER,
              p_return_status                IN OUT NOCOPY  VARCHAR2
                       ) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_lib_pvt.Default_Desc_Flexfield(+)');
   END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_cash_receipt_id IS NOT NULL THEN
        SELECT attribute_category,
               attribute1, attribute2,
               attribute3, attribute4,
               attribute5, attribute6,
               attribute7, attribute8,
               attribute9, attribute10,
               attribute11, attribute12,
               attribute13, attribute14,
               attribute15
        INTO   p_desc_flex_rec.attribute_category,
               p_desc_flex_rec.attribute1, p_desc_flex_rec.attribute2,
               p_desc_flex_rec.attribute3, p_desc_flex_rec.attribute4,
               p_desc_flex_rec.attribute5, p_desc_flex_rec.attribute6,
               p_desc_flex_rec.attribute7, p_desc_flex_rec.attribute8,
               p_desc_flex_rec.attribute9, p_desc_flex_rec.attribute10,
               p_desc_flex_rec.attribute11, p_desc_flex_rec.attribute12,
               p_desc_flex_rec.attribute13, p_desc_flex_rec.attribute14,
               p_desc_flex_rec.attribute15
       FROM   ar_cash_receipts
       WHERE  cash_receipt_id = p_cash_receipt_id;
   END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_lib_pvt.Default_Desc_Flexfield(-)');
   END IF;

EXCEPTION WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR','AR_RAPI_CASH_RCPT_ID_INVALID');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
End Default_Desc_Flexfield;
/* End bug fix 3539008 */

PROCEDURE Default_prepay_cc_activity(
              p_appl_type                    IN      VARCHAR2,
              p_receivable_trx_id            IN OUT NOCOPY  NUMBER,
              p_return_status                OUT NOCOPY     VARCHAR2
            ) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('ar_receipt_lib_pvt.Default_prepay_cc_activity(+)');
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_receivable_trx_id is null THEN

    BEGIN
      SELECT rt.receivables_trx_id
      INTO   p_receivable_trx_id
      FROM   ar_receivables_trx rt
      WHERE   nvl(rt.status,'A') = 'A'
      AND trunc(sysdate) between nvl(rt.start_date_active,trunc(sysdate))
      and nvl(rt.end_date_active,trunc(sysdate))
      AND rt.type = p_appl_type
      AND ROWNUM = 1;

    EXCEPTION
      WHEN others THEN
           fnd_message.set_name('AR', 'AR_NO_ACTIVITY_FOUND');
           p_return_status := FND_API.G_RET_STS_ERROR;
    END;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_lib_pvt.Default_prepay_cc_activity(+)');
  END IF;

END Default_prepay_cc_activity;

PROCEDURE default_open_receipt(
              p_cash_receipt_id          IN OUT NOCOPY NUMBER
            , p_receipt_number           IN OUT NOCOPY VARCHAR2
            , p_applied_ps_id            IN OUT NOCOPY NUMBER
            , p_open_cash_receipt_id     IN OUT NOCOPY NUMBER
            , p_open_receipt_number      IN OUT NOCOPY VARCHAR2
            , p_apply_gl_date            IN OUT NOCOPY DATE
            , p_open_rec_app_id          IN NUMBER
            , x_cr_payment_schedule_id   OUT NOCOPY NUMBER
            , x_last_receipt_date        OUT NOCOPY DATE
            , x_open_applied_ps_id       OUT NOCOPY NUMBER
            , x_unapplied_cash           OUT NOCOPY NUMBER
            , x_open_amount_applied      OUT NOCOPY NUMBER
            , x_claim_rec_trx_id         OUT NOCOPY NUMBER
            , x_application_ref_num      OUT NOCOPY VARCHAR2
            , x_secondary_app_ref_id     OUT NOCOPY NUMBER
            , x_application_ref_reason   OUT NOCOPY VARCHAR2
            , x_customer_reference       OUT NOCOPY VARCHAR2
            , x_customer_reason          OUT NOCOPY VARCHAR2
            , x_cr_gl_date               OUT NOCOPY DATE
            , x_open_cr_gl_date          OUT NOCOPY DATE
            , x_receipt_currency         OUT NOCOPY VARCHAR2
            , x_open_receipt_currency    OUT NOCOPY VARCHAR2
            , x_cr_customer_id           OUT NOCOPY NUMBER
            , x_open_cr_customer_id      OUT NOCOPY NUMBER
            , x_return_status            OUT NOCOPY VARCHAR2
) IS

  l_open_cash_receipt_id        NUMBER;
  l_receipt_date                DATE;
  l_open_receipt_date           DATE;
  l_app_gl_date_prof            VARCHAR2(240);

  l_cr_amount                   NUMBER;
  l_cr_exchange_rate            NUMBER;
  l_cr_cust_site_use_id         NUMBER;
  l_cr_unapp_amount             NUMBER;
  l_cr_payment_schedule_id      NUMBER;
  l_remit_bank_acct_use_id      NUMBER;
  l_receipt_method_id           NUMBER;
  l_status                      ar_receivable_applications.status%TYPE;
  l_display			ar_receivable_applications.display%TYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_lib_pvt.Default_open_receipt(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  x_open_applied_ps_id := NULL;
  x_application_ref_num := NULL;
  x_secondary_app_ref_id := NULL;

  default_cash_receipt_id
        (p_cash_receipt_id,
         p_receipt_number,
         x_return_status);

  IF p_applied_ps_id IS NOT NULL
  THEN
   BEGIN
    SELECT cash_receipt_id INTO p_open_cash_receipt_id
    FROM   ar_payment_schedules
    WHERE  payment_schedule_id = p_applied_ps_id;
   EXCEPTION when others then
     --raise error message
     FND_MESSAGE.SET_NAME('AR','AR_RAPI_APP_PS_ID_INVALID');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR;
   END;
  END IF;

  IF p_open_rec_app_id IS NOT NULL THEN

     BEGIN
       SELECT  applied_payment_schedule_id,
               amount_applied,
               cash_receipt_id,
               receivables_trx_id,
               secondary_application_ref_id,
               application_ref_num,
               application_ref_reason,
               customer_reference,
               customer_reason,
	       status,
	       NVL(display,'N')
       INTO    x_open_applied_ps_id,
               x_open_amount_applied,
               p_open_cash_receipt_id ,
               x_claim_rec_trx_id,
               x_secondary_app_ref_id,
               x_application_ref_num,
               x_application_ref_reason,
               x_customer_reference,
               x_customer_reason,
	       l_status,
	       l_display
       FROM    ar_receivable_applications
       WHERE   receivable_application_id = p_open_rec_app_id ;
     EXCEPTION
        WHEN no_data_found THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
     END;

  default_cash_receipt_id
        (p_open_cash_receipt_id,
         p_open_receipt_number,
         x_return_status);

     /* Bug 3018366 - check for current open receipt separated from logic above */
     IF (l_display <> 'Y' OR l_status NOT IN ('OTHER ACC','ACC')) THEN
           FND_MESSAGE.SET_NAME('AR','AR_RW_NET_OPEN_RCT_ONLY');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
     END IF;

     --Compare the two cash_receipt_ids
     IF p_open_cash_receipt_id IS NOT NULL THEN
        IF p_open_cash_receipt_id <> l_open_cash_receipt_id THEN
            --raise error X validation failed
            FND_MESSAGE.SET_NAME('AR','AR_RAPI_RCPT_RA_ID_X_INVALID');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
        END IF;
     END IF;
  END IF;

  IF x_return_status <> FND_API.G_RET_STS_ERROR THEN
     default_cash_receipt_id
        (p_open_cash_receipt_id,
         p_open_receipt_number,
         x_return_status);
  END IF;

  SELECT SUM(amount_applied)
  INTO   x_unapplied_cash
  FROM   ar_receivable_applications
  WHERE  cash_receipt_id = p_cash_receipt_id
  AND    status = 'UNAPP';

  IF p_open_rec_app_id IS NULL
  THEN
    SELECT SUM(amount_applied)
    INTO   x_open_amount_applied
    FROM   ar_receivable_applications
    WHERE  cash_receipt_id = p_open_cash_receipt_id
    AND    status = 'UNAPP';
  END IF;

  --
  -- Default receipt info
  --
  Default_Receipt_Info(
                                 p_cash_receipt_id ,
                                 x_cr_gl_date,
                                 x_cr_customer_id,
                                 l_cr_amount,
                                 x_receipt_currency,
                                 l_cr_exchange_rate,
                                 l_cr_cust_site_use_id,
                                 l_receipt_date,
                                 l_cr_unapp_amount,
                                 x_cr_payment_schedule_id,
                                 l_remit_bank_acct_use_id,
                                 l_receipt_method_id,
                                 x_return_status
                                  );

  Default_Receipt_Info(
                                 p_open_cash_receipt_id ,
                                 x_open_cr_gl_date,
                                 x_open_cr_customer_id,
                                 l_cr_amount,
                                 x_open_receipt_currency,
                                 l_cr_exchange_rate,
                                 l_cr_cust_site_use_id,
                                 l_open_receipt_date, /* Bug fix 3286069 */
                                 l_cr_unapp_amount,
                                 p_applied_ps_id,
                                 l_remit_bank_acct_use_id,
                                 l_receipt_method_id,
                                 x_return_status
                                  );


  IF p_apply_gl_date IS NULL
  THEN
    p_apply_gl_date := (GREATEST(x_cr_gl_date,x_open_cr_gl_date));
    l_app_gl_date_prof :=
          NVL(ar_receipt_lib_pvt.pg_profile_appln_gl_date_def,'INV_REC_DT');
    IF (l_app_gl_date_prof    = 'INV_REC_DT') THEN
      NULL;
    ELSIF (l_app_gl_date_prof = 'INV_REC_SYS_DT') THEN
      IF p_apply_gl_date > SYSDATE THEN
        NULL;
      ELSE
        p_apply_gl_date := SYSDATE;
      END IF;
    ELSE
      p_apply_gl_date := SYSDATE;
    END IF;
  END IF;

  x_last_receipt_date := GREATEST(l_receipt_date,l_open_receipt_date);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_lib_pvt.Default_open_receipt(-)');
  END IF;
END default_open_receipt;

PROCEDURE default_unapp_open_receipt(
              p_receivable_application_id  IN  NUMBER
            , x_applied_cash_receipt_id    OUT NOCOPY NUMBER
            , x_applied_rec_app_id         OUT NOCOPY NUMBER
            , x_amount_applied             OUT NOCOPY NUMBER
            , x_return_status              OUT NOCOPY VARCHAR2
) IS

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_lib_pvt.Default_unapp_open_receipt(+)');
  END IF;

  SELECT app.applied_rec_app_id,
         applied_app.cash_receipt_id,
         app.amount_applied
  INTO   x_applied_rec_app_id,
         x_applied_cash_receipt_id,
         x_amount_applied
  FROM   ar_receivable_applications app,
         ar_receivable_applications applied_app
  WHERE  app.applied_rec_app_id = applied_app.receivable_application_id
  AND    app.receivable_application_id = p_receivable_application_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_lib_pvt.Default_unapp_open_receipt(-)');
  END IF;

EXCEPTION
        WHEN no_data_found THEN
           FND_MESSAGE.SET_NAME('AR','AR_RAPI_REC_APP_ID_INVALID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
END default_unapp_open_receipt;

FUNCTION get_legal_entity (p_remit_bank_acct_use_id IN NUMBER)
RETURN NUMBER
IS
  l_legal_entity_id		NUMBER;
  l_return_status		VARCHAR2(1);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_lib_pvt.get_legal_entity(+)');
  END IF;

  l_legal_entity_id := TO_NUMBER(Get_Id('LEGAL_ENTITY',
                                 p_remit_bank_acct_use_id,
                                 l_return_status
                                 ));
  RETURN l_legal_entity_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_lib_pvt.get_legal_entity(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
END get_legal_entity;

PROCEDURE default_refund_attributes (
	 p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE
	,p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE
	,p_currency_code IN fnd_currencies.currency_code%TYPE
	,p_amount IN NUMBER
	,p_party_id IN OUT NOCOPY hz_parties.party_id%TYPE
	,p_party_site_id IN OUT NOCOPY hz_party_sites.party_site_id%TYPE
	,x_party_name OUT NOCOPY hz_parties.party_name%TYPE
	,x_party_number OUT NOCOPY hz_parties.party_number%TYPE
	,x_party_address OUT NOCOPY VARCHAR2
	,x_exchange_rate OUT NOCOPY ar_cash_receipts.exchange_rate%TYPE
	,x_exchange_rate_type OUT NOCOPY ar_cash_receipts.exchange_rate_type%TYPE
	,x_exchange_date OUT NOCOPY ar_cash_receipts.exchange_date%TYPE
	,x_legal_entity_id OUT NOCOPY ar_cash_receipts.legal_entity_id%TYPE
    	,x_payment_method_code OUT NOCOPY ap_invoices.payment_method_code%TYPE
    	,x_payment_method_name OUT NOCOPY VARCHAR2
    	,x_bank_account_id OUT NOCOPY ar_cash_receipts.customer_bank_account_id%TYPE

    	,x_bank_account_num OUT NOCOPY VARCHAR2
    	,x_payment_reason_code OUT NOCOPY ap_invoices.payment_reason_code%TYPE
    	,x_payment_reason_name OUT NOCOPY VARCHAR2
    	,x_delivery_channel_code OUT NOCOPY ap_invoices.delivery_channel_code%TYPE
    	,x_delivery_channel_name OUT NOCOPY VARCHAR2
    	,x_pay_alone_flag OUT NOCOPY VARCHAR2
	,x_return_status OUT NOCOPY VARCHAR2
	,x_msg_count OUT NOCOPY NUMBER
	,x_msg_data OUT NOCOPY VARCHAR2
	)
IS
  l_trxn_attributes_rec		iby_disbursement_comp_pub.trxn_attributes_rec_type;
  l_legal_entity_id		ar_cash_receipts.legal_entity_id%TYPE;
  l_org_id			ar_cash_receipts.org_id%TYPE;
  l_cust_acct_id		hz_cust_accounts.cust_account_id%TYPE;
  l_site_use_id			hz_cust_site_uses.site_use_id%TYPE;
  l_party_id			hz_parties.party_id%TYPE;
  l_party_site_id		hz_parties.party_id%TYPE;
  l_pmt_attr_rec		iby_disbursement_comp_pub.default_pmt_attrs_rec_type;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_lib_pvt.default_refund_attributes(+)');
  END IF;
    l_trxn_attributes_rec.application_id := 222;

    IF p_cash_receipt_id IS NOT NULL THEN
      begin
	SELECT  legal_entity_id,
		exchange_rate,
		exchange_rate_type,
		exchange_date,
		org_id,
		pay_from_customer,
		customer_site_use_id
        INTO    x_legal_entity_id,
		x_exchange_rate,
		x_exchange_rate_type,
		x_exchange_date,
		l_org_id,
		l_cust_acct_id,
		l_site_use_id
        FROM 	ar_cash_receipts_all
	WHERE	cash_receipt_id = p_cash_receipt_id;
      exception when others then null;
      end;
    ELSE
	SELECT  legal_entity_id,
		exchange_rate,
		exchange_rate_type,
		exchange_date,
		org_id,
		bill_to_customer_id,
		bill_to_site_use_id
        INTO    x_legal_entity_id,
		x_exchange_rate,
		x_exchange_rate_type,
		x_exchange_date,
		l_org_id,
		l_cust_acct_id,
		l_site_use_id
        FROM 	ra_customer_trx
	WHERE	customer_trx_id = p_customer_trx_id;
    END IF;
    IF p_party_id IS NULL THEN
       BEGIN
        SELECT p.party_id
	      ,p.party_name
	      ,p.party_number
 	INTO   p_party_id
	      ,x_party_name
	      ,x_party_number
	FROM   hz_cust_accounts ca
              ,hz_parties p
	WHERE  p.party_id = ca.party_id
	AND    ca.cust_account_id = l_cust_acct_id;
      EXCEPTION
	WHEN OTHERS THEN
	   p_party_id := NULL;
	   x_party_name := NULL;
	   x_party_number := NULL;
      END;
    END IF;
    IF p_party_site_id IS NULL and p_party_id IS NOT NULL THEN
      begin
	SELECT cas.party_site_id
	 /*    , arh_addr_pkg.format_address(loc.address_style,loc.address1,
                                  	   loc.address2, loc.address3,
                            	           loc.address4, loc.city,
                                   	   loc.county, loc.state,
                                   	   loc.province, loc.postal_code,
                                   	   null)*/
               , loc.address1
	INTO   p_party_site_id
              ,x_party_address
	FROM   hz_cust_acct_sites_all cas,
	       hz_cust_site_uses_all csu,
	       hz_party_sites ps,
	       hz_locations loc
	WHERE  cas.cust_acct_site_id = csu.cust_acct_site_id
	AND    csu.site_use_id = l_site_use_id
	AND    cas.party_site_id = ps.party_site_id
	AND    ps.location_id = loc.location_id;
     exception when others then null;
     end;
    END IF;
    IF p_party_id IS NULL THEN
	RETURN;
    END IF;
    l_trxn_attributes_rec.payer_legal_entity_id := x_legal_entity_id;
    l_trxn_attributes_rec.payer_org_type := 'OPERATING_UNIT';
    l_trxn_attributes_rec.payer_org_id := l_org_id;
    l_trxn_attributes_rec.payee_party_id := p_party_id;
    l_trxn_attributes_rec.payee_party_site_id := p_party_site_id;
    l_trxn_attributes_rec.pay_proc_trxn_type_code := 'AR_CUSTOMER_REFUND';
    l_trxn_attributes_rec.payment_currency := p_currency_code;
    l_trxn_attributes_rec.payment_amount := p_amount;
    l_trxn_attributes_rec.payment_function := 'AR_CUSTOMER_REFUNDS';

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Calling get_default_payment_attributes .......: ');
    END IF;

   /* Bug 5056865 p_ignore_payee_pref should be passed as 'Y' as discussed in
      Related Bug 5115632 */
   begin
    iby_disbursement_comp_pub.get_default_payment_attributes(
	 p_api_version		=> 1.0
	,p_init_msg_list	=> FND_API.G_FALSE
	,p_ignore_payee_pref    => 'Y'
	,p_trxn_attributes_rec	=> l_trxn_attributes_rec
	,x_return_status	=> x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		=> x_msg_data
	,x_default_pmt_attrs_rec=> l_pmt_attr_rec);
     exception when others then null;
     end;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_default_payment_attributes return status: '||x_return_status);
    END IF;

    x_payment_method_code := l_pmt_attr_rec.payment_method.payment_method_code;
    x_payment_method_name := l_pmt_attr_rec.payment_method.payment_method_name;
    x_bank_account_id := l_pmt_attr_rec.payee_bankaccount.payee_bankaccount_id;
    x_bank_account_num := l_pmt_attr_rec.payee_bankaccount.payee_bankaccount_num;
    x_payment_reason_code := l_pmt_attr_rec.payment_reason.code;
    x_payment_reason_name := l_pmt_attr_rec.payment_reason.meaning;
    x_delivery_channel_code := l_pmt_attr_rec.delivery_channel.code;
    x_delivery_channel_name := l_pmt_attr_rec.delivery_channel.meaning;
    x_pay_alone_flag := l_pmt_attr_rec.pay_alone;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ar_receipt_lib_pvt.default_refund_attributes(-)');
  END IF;
END default_refund_attributes;


PROCEDURE populate_llca_gt (
	     p_customer_trx_id        IN NUMBER,
  	     p_llca_type              IN VARCHAR2,
             p_llca_trx_lines_tbl     IN ar_receipt_api_pub.llca_trx_lines_tbl_type,
	     p_line_amount	      IN NUMBER,
	     p_tax_amount	      IN NUMBER,
  	     p_freight_amount	      IN NUMBER,
	     p_charges_amount	      IN NUMBER,
	     p_line_discount	      IN NUMBER,
	     p_tax_discount	      IN NUMBER,
	     p_freight_discount	      IN NUMBER,
	     p_amount_applied	      IN NUMBER,
	     p_amount_applied_from    IN NUMBER,
             p_return_status          OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Populate_llca_gt ()+ ');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Clean the GT Table first.
  delete from ar_llca_trx_lines_gt
  where customer_trx_id = p_customer_trx_id;

  delete from ar_llca_trx_errors_gt
  where customer_trx_id = p_customer_trx_id;

  If  p_llca_type = 'S'
  Then
     If p_llca_trx_lines_tbl.count <> 0 Then
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Apply_In_Detail: ' || 'Table must be empty for
            Summary Level application ');
         END IF;
     End If;
  END IF;

  If  p_llca_type = 'L'
  Then
	If p_llca_trx_lines_tbl.count = 0 Then
	  IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('=======================================================');
           arp_util.debug('   PL SQL TABLE     (    INPUT PARAMETERS ........)+    ');
           arp_util.debug('=======================================================');
           arp_util.debug('Apply_In_Detail: ' || 'Pl Sql Table is empty ..
                  All Lines  ');
           END IF;
	Else
	  IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('No of records in PLSQL Table
                  =>'||to_char(p_llca_trx_lines_tbl.count));
          END IF;

--bug7311231, Populating the GT table with flexfield information of each line.
	     For i in p_llca_trx_lines_tbl.FIRST..p_llca_trx_lines_tbl.LAST
	     Loop
		 Insert into ar_llca_trx_lines_gt
		 (  customer_trx_id,
		    customer_trx_line_id,
		    line_number,
		    line_amount,
		    tax_amount,
		    freight_amount,
		    charges_amount,
		    amount_applied,
		    amount_applied_from,
		    line_discount,
		    tax_discount,
		    freight_discount,
		    attribute_category,
		    attribute1,
		    attribute2,
		    attribute3,
		    attribute4,
		    attribute5,
		    attribute6,
		    attribute7,
		    attribute8,
		    attribute9,
		    attribute10,
		    attribute11,
		    attribute12,
		    attribute13,
		    attribute14,
		    attribute15
		 )
		 values
		 (
		    p_customer_trx_id,
		    p_llca_trx_lines_tbl(i).customer_trx_line_id,
		    p_llca_trx_lines_tbl(i).line_number,
		    p_llca_trx_lines_tbl(i).line_amount,
		    p_llca_trx_lines_tbl(i).tax_amount,
		    Null,
		    Null,
		    p_llca_trx_lines_tbl(i).amount_applied,
		    p_llca_trx_lines_tbl(i).amount_applied_from,
		    p_llca_trx_lines_tbl(i).line_discount,
		    p_llca_trx_lines_tbl(i).tax_discount,
		    Null,
		    p_llca_trx_lines_tbl(i).attribute_category,
		    p_llca_trx_lines_tbl(i).attribute1,
		    p_llca_trx_lines_tbl(i).attribute2,
		    p_llca_trx_lines_tbl(i).attribute3,
		    p_llca_trx_lines_tbl(i).attribute4,
		    p_llca_trx_lines_tbl(i).attribute5,
		    p_llca_trx_lines_tbl(i).attribute6,
		    p_llca_trx_lines_tbl(i).attribute7,
		    p_llca_trx_lines_tbl(i).attribute8,
		    p_llca_trx_lines_tbl(i).attribute9,
		    p_llca_trx_lines_tbl(i).attribute10,
		    p_llca_trx_lines_tbl(i).attribute11,
		    p_llca_trx_lines_tbl(i).attribute12,
		    p_llca_trx_lines_tbl(i).attribute13,
		    p_llca_trx_lines_tbl(i).attribute14,
		    p_llca_trx_lines_tbl(i).attribute15
		 );

	  IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('=======================================================');
           arp_util.debug(' Line .............=>'||to_char(i));
           arp_util.debug('p_customer_trx_id      =>'||to_char(p_customer_trx_id));
           arp_util.debug('p_customer_trx_line_id =>'||to_char(p_llca_trx_lines_tbl(i).customer_trx_line_id));
           arp_util.debug('p_line_number          =>'||to_char(p_llca_trx_lines_tbl(i).line_number));
           arp_util.debug('p_line_amount          =>'||to_char(p_llca_trx_lines_tbl(i).line_amount));
           arp_util.debug('p_tax_amount           =>'||to_char(p_llca_trx_lines_tbl(i).tax_amount));
--         arp_util.debug('p_freight_amount       =>'||to_char(p_llca_trx_lines_tbl(i).freight_amount));
--         arp_util.debug('p_charges_amount       =>'||to_char(p_llca_trx_lines_tbl(i).charges_amount));
           arp_util.debug('p_amount_applied       =>'||to_char(p_llca_trx_lines_tbl(i).amount_applied));
           arp_util.debug('p_amount_applied_from  =>'||to_char(p_llca_trx_lines_tbl(i).amount_applied_from));
           arp_util.debug('p_line_discount        =>'||to_char(p_llca_trx_lines_tbl(i).line_discount));
           arp_util.debug('p_tax_discount         =>'||to_char(p_llca_trx_lines_tbl(i).tax_discount));
--         arp_util.debug('p_freight_discount     =>'||to_char(p_llca_trx_lines_tbl(i).freight_amount));
           arp_util.debug('=======================================================');
          END IF;
	      End Loop;
	  End If;
     End If;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Populate_llca_gt ()- ');
  END IF;

EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: (pouplate_llca_gt)');
   END IF;
   p_return_status := FND_API.G_RET_STS_ERROR;
   raise;
End populate_llca_gt;

PROCEDURE populate_errors_gt (
	     p_customer_trx_id        IN NUMBER,
	     p_customer_trx_line_id   IN NUMBER,
	     p_error_message	      IN VARCHAR2,
	     p_invalid_value	      IN VARCHAR2
	     ) IS
Begin
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Populate_errors_gt ()+ ');
  END IF;

  Insert into  ar_llca_trx_errors_gt
  ( customer_trx_id,
    customer_trx_line_id,
    error_message,
    invalid_value
  )
  values
  ( p_customer_trx_id,
    p_customer_trx_line_id,
    p_error_message,
    p_invalid_value
  );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Populate_errors_gt ()- ');
  END IF;

EXCEPTION
 WHEN others THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION: (pouplate_errors_gt)');
   END IF;
   raise;
End populate_errors_gt;

END ar_receipt_lib_pvt;

/
