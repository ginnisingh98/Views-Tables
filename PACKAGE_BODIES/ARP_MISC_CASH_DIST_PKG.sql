--------------------------------------------------------
--  DDL for Package Body ARP_MISC_CASH_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_MISC_CASH_DIST_PKG" AS
/*$Header: ARRIMCDB.pls 120.7 2006/06/09 16:25:49 hyu ship $*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE insert_p( p_mcd_rec 	IN ar_misc_cash_distributions%ROWTYPE,
		    p_mcd_id 	OUT NOCOPY ar_misc_cash_distributions.misc_cash_distribution_id%TYPE  ) IS
l_mcd_id  ar_misc_cash_distributions.misc_cash_distribution_id%TYPE;

--5201086
CURSOR cu_crh(p_cr_id IN NUMBER) IS
SELECT cash_receipt_history_id
  FROM ar_cash_receipt_history
 WHERE cash_receipt_id = p_cr_id
   AND current_record_flag = 'Y';
l_crh_id     NUMBER;


BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug( 'arp_misc_cash_dist_pkg.insert_p()+' );
      END IF;

      SELECT ar_misc_cash_distributions_s.nextval
      INTO   l_mcd_id
      FROM   dual;

      --5201086
      IF p_mcd_rec.cash_receipt_history_id IS NULL AND
         p_mcd_rec.cash_receipt_id IS NOT NULL
      THEN
         OPEN cu_crh(p_mcd_rec.cash_receipt_id);
         FETCH cu_crh INTO l_crh_id;
         CLOSE cu_crh;
      ELSE
         l_crh_id := p_mcd_rec.cash_receipt_history_id;
      END IF;


      INSERT INTO  ar_misc_cash_distributions (
		   misc_cash_distribution_id,
 		   cash_receipt_id,
 		   code_combination_id,
 		   set_of_books_id,
 		   gl_date,
 		   percent,
 		   amount,
 		   comments,
 		   gl_posted_date,
 		   apply_date,
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
 		   attribute15,
 		   request_id,
 		   program_application_id,
 		   program_id,
 		   program_update_date,
 		   created_by,
 		   creation_date,
 		   last_updated_by,
 		   last_update_date,
 		   last_update_login,
 		   posting_control_id,
 		   acctd_amount,
 		   ussgl_transaction_code,
 		   ussgl_transaction_code_context,
 		   created_from,
 		   reversal_gl_date
                   ,org_id
           --5201086
           ,cash_receipt_history_id
 		 )
       VALUES (    l_mcd_id,
                   p_mcd_rec.cash_receipt_id,
                   p_mcd_rec.code_combination_id,
                   p_mcd_rec.set_of_books_id,
                   p_mcd_rec.gl_date,
                   p_mcd_rec.percent,
                   p_mcd_rec.amount,
                   p_mcd_rec.comments,
                   p_mcd_rec.gl_posted_date,
                   p_mcd_rec.apply_date,
                   p_mcd_rec.attribute_category,
                   p_mcd_rec.attribute1,
                   p_mcd_rec.attribute2,
                   p_mcd_rec.attribute3,
                   p_mcd_rec.attribute4,
                   p_mcd_rec.attribute5,
                   p_mcd_rec.attribute6,
                   p_mcd_rec.attribute7,
                   p_mcd_rec.attribute8,
                   p_mcd_rec.attribute9,
                   p_mcd_rec.attribute10,
                   p_mcd_rec.attribute11,
                   p_mcd_rec.attribute12,
                   p_mcd_rec.attribute13,
                   p_mcd_rec.attribute14,
                   p_mcd_rec.attribute15,
 		   NVL( arp_standard.profile.request_id, p_mcd_rec.request_id ),
 		   NVL( arp_standard.profile.program_application_id,
                        p_mcd_rec.program_application_id ),
 		   NVL( arp_standard.profile.program_id, p_mcd_rec.program_id ),
 		   DECODE( arp_standard.profile.program_id,
			   NULL, NULL, SYSDATE ),
 		   arp_standard.profile.user_id,
 		   SYSDATE,
 		   arp_standard.profile.user_id,
 		   SYSDATE,
		   NVL( arp_standard.profile.last_update_login,
		        p_mcd_rec.last_update_login ),
                   p_mcd_rec.posting_control_id,
                   p_mcd_rec.acctd_amount,
                   p_mcd_rec.ussgl_transaction_code,
                   p_mcd_rec.ussgl_transaction_code_context,
                   p_mcd_rec.created_from,
                   p_mcd_rec.reversal_gl_date
                  ,arp_standard.sysparm.org_id /* SSA changes anuj */
           --5201086
           ,l_crh_id
	       );

    p_mcd_id := l_mcd_id;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  'insert parameters.......');
       arp_standard.debug(  'misc cash dist id = ' || to_char(l_mcd_id));
       arp_standard.debug(  'cash_Receipt id = '|| to_char(p_mcd_rec.cash_receipt_id));
       arp_standard.debug(  'percent= ' || to_char(p_mcd_rec.percent));
       arp_standard.debug(  'amount= ' || to_char(p_mcd_rec.amount));
       arp_standard.debug(  'set_of_books id= ' || to_char(p_mcd_rec.set_of_books_id));
       arp_standard.debug(  'created_from' || p_mcd_rec.created_from);
       arp_standard.debug(  '');
       arp_standard.debug(  'after insert into ar_misc_cash_distributions');
    END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.insert_p()-' );
    END IF;
    EXCEPTION
	WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'EXCEPTION: arp_misc_cash_dist_pkg.insert_p' );
	    END IF;
	    RAISE;
END insert_p;
--
PROCEDURE update_p( p_mcd_rec 	IN ar_misc_cash_distributions%ROWTYPE ) IS
--5201086
CURSOR cu_crh(p_cr_id IN NUMBER) IS
SELECT cash_receipt_history_id
  FROM ar_cash_receipt_history
 WHERE cash_receipt_id = p_cr_id
   AND current_record_flag = 'Y';
l_crh_id     NUMBER;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.update_p()+' );
    END IF;

      --5201086
      IF p_mcd_rec.cash_receipt_history_id IS NULL AND
         p_mcd_rec.cash_receipt_id IS NOT NULL
      THEN
         OPEN cu_crh(p_mcd_rec.cash_receipt_id);
         FETCH cu_crh INTO l_crh_id;
         CLOSE cu_crh;
      ELSE
         l_crh_id := p_mcd_rec.cash_receipt_history_id;
      END IF;

    UPDATE ar_misc_cash_distributions SET
                   code_combination_id = p_mcd_rec.code_combination_id,
                   set_of_books_id = p_mcd_rec.set_of_books_id,
                   gl_date = p_mcd_rec.gl_date,
                   percent = p_mcd_rec.percent,
                   amount = p_mcd_rec.amount,
                   comments = p_mcd_rec.comments,
		   gl_posted_date = p_mcd_rec.gl_posted_date,
                   apply_date = p_mcd_rec.apply_date,
                   attribute_category = p_mcd_rec.attribute_category,
                   attribute1 = p_mcd_rec.attribute1,
                   attribute2 = p_mcd_rec.attribute2,
                   attribute3 = p_mcd_rec.attribute3,
                   attribute4 = p_mcd_rec.attribute4,
                   attribute5 = p_mcd_rec.attribute5,
                   attribute6 = p_mcd_rec.attribute6,
                   attribute7 = p_mcd_rec.attribute7,
		   attribute8 = p_mcd_rec.attribute8,
		   attribute9 = p_mcd_rec.attribute9,
		   attribute10 = p_mcd_rec.attribute10,
		   attribute11 = p_mcd_rec.attribute11,
                   attribute12 = p_mcd_rec.attribute12,
                   attribute13 = p_mcd_rec.attribute13,
                   attribute14 = p_mcd_rec.attribute14,
                   attribute15 = p_mcd_rec.attribute15,
 		   request_id = NVL( arp_standard.profile.request_id,
				     p_mcd_rec.request_id ),
 		   program_application_id =
			      NVL( arp_standard.profile.program_application_id,
 				   p_mcd_rec.program_application_id ),
 		   program_id = NVL( arp_standard.profile.program_id,
				     p_mcd_rec.program_id ),
 		   program_update_date =
				DECODE( arp_standard.profile.program_id,
					NULL, NULL,
					SYSDATE
			   	      ),
 		   last_updated_by = arp_standard.profile.user_id,
 		   last_update_date = SYSDATE,
 		   last_update_login =
			NVL( arp_standard.profile.last_update_login,
			     p_mcd_rec.last_update_login ),
                   posting_control_id = p_mcd_rec.posting_control_id,
                   acctd_amount = p_mcd_rec.acctd_amount,
                   ussgl_transaction_code = p_mcd_rec.ussgl_transaction_code,
                   ussgl_transaction_code_context =
				p_mcd_rec.ussgl_transaction_code_context,
                   created_from = p_mcd_rec.created_from,
                   reversal_gl_date = p_mcd_rec.reversal_gl_date
          --5201086
         ,cash_receipt_history_id = l_crh_id
    WHERE misc_cash_distribution_id = p_mcd_rec.misc_cash_distribution_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.update_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_misc_cash_dist_pkg.update_p' );
            END IF;
            RAISE;
END update_p;
--
PROCEDURE delete_p(
    p_mcd_id IN ar_misc_cash_distributions.misc_cash_distribution_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.delete_p()+' );
    END IF;
--
    DELETE FROM ar_misc_cash_distributions
    WHERE misc_cash_distribution_id = p_mcd_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.delete_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_misc_cash_dist_pkg.delete_p' );
            END IF;
            RAISE;
END delete_p;

PROCEDURE lock_p(
    p_mcd_id IN ar_misc_cash_distributions.misc_cash_distribution_id%TYPE ) IS
l_mcd_id	ar_misc_cash_distributions.misc_cash_distribution_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.lock_p()+' );
    END IF;
--
    SELECT misc_cash_distribution_id
    INTO   l_mcd_id
    FROM  ar_misc_cash_distributions
    WHERE misc_cash_distribution_id = p_mcd_id
    FOR UPDATE OF amount NOWAIT ;
--
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.lock_p()-' );
    END IF;
    EXCEPTION
        WHEN  OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'EXCEPTION: arp_misc_cash_dist_pkg.lock_p' );
            END IF;
            RAISE;
END lock_p;

PROCEDURE fetch_p(
	p_mcd_id IN ar_misc_cash_distributions.misc_cash_distribution_id%TYPE,
        p_mcd_rec OUT NOCOPY ar_misc_cash_distributions%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.fetch_p()+' );
    END IF;
--
    SELECT *
    INTO   p_mcd_rec
    FROM   ar_misc_cash_distributions
    WHERE  misc_cash_distribution_id = p_mcd_id;
--
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.fetch_p()-' );
    END IF;
    EXCEPTION
--
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug( 'EXCEPTION: arp_misc_cash_dist_pkg.fetch_p' );
              END IF;
              RAISE;
END fetch_p;

PROCEDURE nowaitlock_fetch_p(
	p_mcd_id IN ar_misc_cash_distributions.misc_cash_distribution_id%TYPE,
        p_mcd_rec OUT NOCOPY ar_misc_cash_distributions%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.nowaitlock_fetch_p()+' );
    END IF;
--
    SELECT *
    INTO   p_mcd_rec
    FROM   ar_misc_cash_distributions
    WHERE  misc_cash_distribution_id = p_mcd_id
    FOR UPDATE OF amount NOWAIT;
--
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_misc_cash_dist_pkg.nowaitlock_fetch_p()-' );
    END IF;
    EXCEPTION
--
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug( 'EXCEPTION: arp_misc_cash_dist_pkg.nowaitlock_fetch_p' );
              END IF;
              RAISE;
END nowaitlock_fetch_p;
--
END ARP_MISC_CASH_DIST_PKG;

/
