--------------------------------------------------------
--  DDL for Package Body ARP_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DISTRIBUTIONS_PKG" AS
/* $Header: ARJIDSTB.pls 120.12.12010000.2 2010/07/23 03:01:01 nemani ship $*/
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE insert_p(
	p_dist_rec 	IN ar_distributions%ROWTYPE,
	p_line_id	OUT NOCOPY ar_distributions.line_id%TYPE ) IS
l_line_id	ar_distributions.line_id%TYPE;
exp_null_insert exception;
pragma exception_init(exp_null_insert, -1400);
BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug( 'arp_distributions_pkg.insert_p()+' );
      END IF;
      --
      SELECT ar_distributions_s.nextval
      INTO   l_line_id
      FROM   dual;
      --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  'LINE ID '|| l_line_id);
         arp_standard.debug(  'SOURCE_ID ' || p_dist_rec.SOURCE_ID);
         arp_standard.debug(  'SOURCE_TABLE ' || p_dist_rec.SOURCE_TABLE);
         arp_standard.debug(  'SOURCE_TYPE ' || p_dist_rec.SOURCE_TYPE);
         arp_standard.debug(  'SOURCE_TYPE_SECONDARY ' || p_dist_rec.SOURCE_TYPE_SECONDARY);
         arp_standard.debug(  'CODE_COMBINATION_ID '||p_dist_rec.CODE_COMBINATION_ID);
         arp_standard.debug(  'AMOUNT_DR ' || p_dist_rec.AMOUNT_DR);
         arp_standard.debug(  'AMOUNT_CR ' || p_dist_rec.AMOUNT_CR);
         arp_standard.debug(  'ACCTD_AMOUNT_DR ' || p_dist_rec.ACCTD_AMOUNT_DR);
         arp_standard.debug(  'ACCTD_AMOUNT_CR ' ||p_dist_rec.ACCTD_AMOUNT_CR);
         arp_standard.debug(  'SOURCE_TABLE_SECONDARY  ' || p_dist_rec.SOURCE_TABLE_SECONDARY);
         arp_standard.debug(  'SOURCE_ID_SECONDARY     ' || p_dist_rec.SOURCE_ID_SECONDARY);
         arp_standard.debug(  'CURRENCY_CODE           ' || p_dist_rec.CURRENCY_CODE);
         arp_standard.debug(  'CURRENCY_CONVERSION_RATE ' || p_dist_rec.CURRENCY_CONVERSION_RATE);
         arp_standard.debug(  'CURRENCY_CONVERSION_TYPE ' || p_dist_rec.CURRENCY_CONVERSION_TYPE);
         arp_standard.debug(  'CURRENCY_CONVERSION_DATE ' || p_dist_rec.CURRENCY_CONVERSION_DATE);
         arp_standard.debug(  'TAXABLE_ENTERED_DR    ' || p_dist_rec.TAXABLE_ENTERED_DR);
         arp_standard.debug(  'TAXABLE_ENTERED_CR    ' || p_dist_rec.TAXABLE_ENTERED_CR);
         arp_standard.debug(  'TAXABLE_ACCOUNTED_DR  ' || p_dist_rec.TAXABLE_ACCOUNTED_DR);
         arp_standard.debug(  'TAXABLE_ACCOUNTED_CR  ' || p_dist_rec.TAXABLE_ACCOUNTED_CR);
         arp_standard.debug(  'TAX_LINK_ID           ' || p_dist_rec.TAX_LINK_ID);
         arp_standard.debug(  'THIRD_PARTY_ID        ' || p_dist_rec.THIRD_PARTY_ID);
         arp_standard.debug(  'THIRD_PARTY_SUB_ID    ' || p_dist_rec.THIRD_PARTY_SUB_ID);
         arp_standard.debug(  'REVERSED_SOURCE_ID    ' || p_dist_rec.REVERSED_SOURCE_ID);
         arp_standard.debug(  'TAX_GROUP_CODE_ID     ' || p_dist_rec.TAX_GROUP_CODE_ID);
         arp_standard.debug(  'TAX_CODE_ID           ' || p_dist_rec.TAX_CODE_ID);
         arp_standard.debug(  'LOCATION_SEGMENT_ID   ' || p_dist_rec.LOCATION_SEGMENT_ID);
         --HYU--{
         arp_standard.debug(  'FROM_AMOUNT_DR       ' || p_dist_rec.FROM_AMOUNT_DR);
         arp_standard.debug(  'FROM_AMOUNT_CR       ' || p_dist_rec.FROM_AMOUNT_CR);
         arp_standard.debug(  'FROM_ACCTD_AMOUNT_DR ' || p_dist_rec.FROM_ACCTD_AMOUNT_DR);
         arp_standard.debug(  'FROMACCTD_AMOUNT_CR  ' || p_dist_rec.FROM_ACCTD_AMOUNT_CR);
         arp_standard.debug(  'ref_customer_trx_line_id     ' || p_dist_rec.ref_customer_trx_line_id);
         arp_standard.debug(  'ref_prev_cust_trx_line_id     ' || p_dist_rec.ref_prev_cust_trx_line_id);
         arp_standard.debug(  'ref_cust_trx_line_gl_dist_id ' || p_dist_rec.ref_cust_trx_line_gl_dist_id);
         arp_standard.debug(  'ref_account_class            ' || p_dist_rec.ref_account_class);
         arp_standard.debug(  'activity_bucket               ' || p_dist_rec.activity_bucket);
         arp_standard.debug(  'REF_DIST_CCID        ' || p_dist_rec.ref_dist_ccid);
         arp_standard.debug(  'REF_MF_DIST_FLAG     ' || p_dist_rec.ref_mf_dist_flag);
         --HYU--}
      END IF;

      INSERT INTO  ar_distributions (
		   line_id,
		   source_id,
 		   source_table,
 		   source_type,
 		   source_type_secondary,
 		   code_combination_id,
 		   amount_dr,
 		   amount_cr,
 		   acctd_amount_dr,
 		   acctd_amount_cr,
 		   created_by,
 		   creation_date,
 		   last_updated_by,
 		   last_update_date,
                   last_update_login,
                   source_id_secondary,
                   source_table_secondary,
                   currency_code        ,
                   currency_conversion_rate,
                   currency_conversion_type,
                   currency_conversion_date,
                   third_party_id,
                   third_party_sub_id,
                   tax_code_id,
                   location_segment_id,
                   taxable_entered_dr,
                   taxable_entered_cr,
                   taxable_accounted_dr,
                   taxable_accounted_cr,
                   tax_link_id,
                   reversed_source_id,
                   tax_group_code_id
                   ,org_id
                   --{BUG#2979254
                   ,ref_customer_trx_line_id
                   ,ref_prev_cust_trx_line_id
                   ,ref_cust_trx_line_gl_dist_id
                   ,ref_line_id
                   ,from_amount_dr
                   ,from_amount_cr
                   ,from_acctd_amount_dr
                   ,from_acctd_amount_cr
                   ,ref_account_class
                   ,activity_bucket
                   ,ref_dist_ccid
                   ,ref_mf_dist_flag
                   --}
 		 )
       VALUES (    l_line_id,
                   p_dist_rec.source_id,
                   p_dist_rec.source_table,
                   p_dist_rec.source_type,
                   p_dist_rec.source_type_secondary,
                   p_dist_rec.code_combination_id,
                   p_dist_rec.amount_dr,
                   p_dist_rec.amount_cr,
                   p_dist_rec.acctd_amount_dr,
                   p_dist_rec.acctd_amount_cr,
		   arp_standard.profile.user_id,
 		   SYSDATE,
		   arp_standard.profile.user_id,
 		   SYSDATE,
		   NVL( arp_standard.profile.last_update_login,
			p_dist_rec.last_update_login ),
                   p_dist_rec.source_id_secondary,
                   p_dist_rec.source_table_secondary,
                   p_dist_rec.currency_code        ,
                   p_dist_rec.currency_conversion_rate,
                   p_dist_rec.currency_conversion_type,
                   p_dist_rec.currency_conversion_date,
                   p_dist_rec.third_party_id,
                   p_dist_rec.third_party_sub_id,
                   p_dist_rec.tax_code_id,
                   p_dist_rec.location_segment_id,
                   p_dist_rec.taxable_entered_dr,
                   p_dist_rec.taxable_entered_cr,
                   p_dist_rec.taxable_accounted_dr,
                   p_dist_rec.taxable_accounted_cr,
                   p_dist_rec.tax_link_id,
                   p_dist_rec.reversed_source_id,
                   p_dist_rec.tax_group_code_id
                   ,arp_standard.sysparm.org_id /* SSA changes anuj */
                   --{BUG#2979254
                   ,p_dist_rec.ref_customer_trx_line_id
                   ,p_dist_rec.ref_prev_cust_trx_line_id
                   ,p_dist_rec.ref_cust_trx_line_gl_dist_id
                   ,p_dist_rec.ref_line_id
                   ,p_dist_rec.from_amount_dr
                   ,p_dist_rec.from_amount_cr
                   ,p_dist_rec.from_acctd_amount_dr
                   ,p_dist_rec.from_acctd_amount_cr
                   ,p_dist_rec.ref_account_class
                   ,p_dist_rec.activity_bucket
                   ,p_dist_rec.ref_dist_ccid
                   ,p_dist_rec.ref_mf_dist_flag
                   --}
	       );
    --
    p_line_id := l_line_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.insert_p()-' );
    END IF;
    EXCEPTION
	WHEN exp_null_insert THEN
        FND_MESSAGE.SET_NAME('AR','AR_INS_NULL_INTO_NOTNULL');
	APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'EXCEPTION: arp_distributions_pkg.insert_p' );
	    END IF;
	    RAISE;
END insert_p;
--
PROCEDURE update_p(
	p_dist_rec 	IN ar_distributions%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.update_p()+' );
    END IF;
    --
    UPDATE ar_distributions SET
	   source_id = p_dist_rec.source_id,
           source_table = p_dist_rec.source_table,
           source_type = p_dist_rec.source_type,
           source_type_secondary = p_dist_rec.source_type_secondary,
           code_combination_id = p_dist_rec.code_combination_id,
           amount_dr = p_dist_rec.amount_dr,
           amount_cr = p_dist_rec.amount_cr,
           acctd_amount_dr = p_dist_rec.acctd_amount_dr,
           acctd_amount_cr = p_dist_rec.acctd_amount_cr,
           last_updated_by = arp_standard.profile.user_id,
           last_update_date = SYSDATE,
           last_update_login = NVL( arp_standard.profile.last_update_login,
                        	    p_dist_rec.last_update_login ),
           source_id_secondary = p_dist_rec.source_id_secondary,
           source_table_secondary = p_dist_rec.source_table_secondary,
           currency_code = p_dist_rec.currency_code,
           currency_conversion_rate = p_dist_rec.currency_conversion_rate,
           currency_conversion_type = p_dist_rec.currency_conversion_type,
           currency_conversion_date = p_dist_rec.currency_conversion_date,
           third_party_id = p_dist_rec.third_party_id,
           third_party_sub_id = p_dist_rec.third_party_sub_id,
           tax_code_id = p_dist_rec.tax_code_id,
           location_segment_id = p_dist_rec.location_segment_id,
           taxable_entered_dr = p_dist_rec.taxable_entered_dr,
           taxable_entered_cr = p_dist_rec.taxable_entered_cr,
           taxable_accounted_dr = p_dist_rec.taxable_accounted_dr,
           taxable_accounted_cr = p_dist_rec.taxable_accounted_cr,
           tax_link_id = p_dist_rec.tax_link_id,
           reversed_source_id = p_dist_rec.reversed_source_id,
           tax_group_code_id = p_dist_rec.tax_group_code_id,
           --{BUG#2979254
           ref_customer_trx_line_id     = p_dist_rec.ref_customer_trx_line_id,
           ref_cust_trx_line_gl_dist_id = p_dist_rec.ref_cust_trx_line_gl_dist_id,
           ref_line_id                  = p_dist_rec.ref_line_id,
           from_amount_dr               = p_dist_rec.from_amount_dr,
           from_amount_cr               = p_dist_rec.from_amount_cr,
           from_acctd_amount_dr         = p_dist_rec.from_acctd_amount_dr,
           from_acctd_amount_cr         = p_dist_rec.from_acctd_amount_cr,
           ref_account_class                    = p_dist_rec.ref_account_class,
           activity_bucket                       = p_dist_rec.activity_bucket,
           ref_dist_ccid                = p_dist_rec.ref_dist_ccid,
           ref_mf_dist_flag             = p_dist_rec.ref_mf_dist_flag
           --}
    WHERE line_id = p_dist_rec.line_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.update_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_distributions_pkg.update_p' );
            END IF;
            RAISE;
END update_p;
--
PROCEDURE delete_p(
	p_line_id IN ar_distributions.line_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.delete_p()+' );
    END IF;
    --
    DELETE FROM ar_distributions
    WHERE line_id = p_line_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.delete_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_distributions_pkg.delete_p' );
            END IF;
            RAISE;
END delete_p;
--
PROCEDURE lock_p(
	p_line_id IN ar_distributions.line_id%TYPE ) IS
l_line_id ar_distributions.line_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.lock_p()+' );
    END IF;
    SELECT line_id
    INTO   l_line_id
    FROM  ar_distributions
    WHERE line_id = p_line_id
    FOR UPDATE OF line_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.lock_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_distributions_pkg.lock_p' );
            END IF;
            RAISE;
END lock_p;
--
PROCEDURE fetch_p(
	p_line_id IN ar_distributions.line_id%TYPE,
        p_dist_rec OUT NOCOPY ar_distributions%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.fetch_p()+' );
    END IF;
    SELECT *
    INTO   p_dist_rec
    FROM   ar_distributions
    WHERE  line_id = p_line_id;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.fetch_p()-' );
    END IF;
    --
    EXCEPTION
    --
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug( 'EXCEPTION: arp_distributions_pkg.fetch_p' );
              END IF;
              RAISE;
END fetch_p;
--
PROCEDURE fetch_pk(
	p_source_id 	IN ar_distributions.source_id%TYPE,
	p_source_table  IN ar_distributions.source_table%TYPE,
	p_source_type	IN ar_distributions.source_type%TYPE,
        p_dist_rec OUT NOCOPY ar_distributions%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.fetch_pk()+' );
    END IF;
    SELECT *
    INTO   p_dist_rec
    FROM   ar_distributions
    WHERE  source_id = p_source_id
      AND  source_table = p_source_table
      AND  source_type = p_source_type;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.fetch_pk()-' );
    END IF;
    --
    EXCEPTION
    --
         WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug( 'EXCEPTION: arp_distributions_pkg.fetch_pk' );
             END IF;
              RAISE;
END fetch_pk;
--
PROCEDURE lock_fetch_pk(
	p_source_id 	IN ar_distributions.source_id%TYPE,
	p_source_table  IN ar_distributions.source_table%TYPE,
	p_source_type	IN ar_distributions.source_type%TYPE,
        p_dist_rec OUT NOCOPY ar_distributions%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.lock_fetch_pk()+' );
    END IF;
    SELECT *
    INTO   p_dist_rec
    FROM   ar_distributions
    WHERE  source_id = p_source_id
      AND  source_table = p_source_table
      AND  source_type = p_source_type
    FOR UPDATE OF line_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.lock_fetch_pk()-' );
    END IF;
    --
    EXCEPTION
    --
         WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug( 'EXCEPTION: arp_distributions_pkg.lock_fetch_pk' );
             END IF;
              RAISE;
END lock_fetch_pk;
--
PROCEDURE nowaitlock_fetch_pk(
	p_source_id 	IN ar_distributions.source_id%TYPE,
	p_source_table  IN ar_distributions.source_table%TYPE,
	p_source_type	IN ar_distributions.source_type%TYPE,
        p_dist_rec OUT NOCOPY ar_distributions%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.nowaitlock_fetch_pk()+' );
    END IF;
    SELECT *
    INTO   p_dist_rec
    FROM   ar_distributions
    WHERE  source_id = p_source_id
      AND  source_table = p_source_table
      AND  source_type = p_source_type
    FOR UPDATE OF line_id NOWAIT;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_distributions_pkg.nowaitlock_fetch_pk()-' );
    END IF;
    --
    EXCEPTION
    --
         WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug( 'EXCEPTION: arp_distributions_pkg.nowaitlock_fetch_pk' );
             END IF;
              RAISE;
END nowaitlock_fetch_pk;
--
END ARP_DISTRIBUTIONS_PKG;

/
