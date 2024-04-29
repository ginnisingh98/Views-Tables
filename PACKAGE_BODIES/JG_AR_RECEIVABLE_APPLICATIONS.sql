--------------------------------------------------------
--  DDL for Package Body JG_AR_RECEIVABLE_APPLICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_AR_RECEIVABLE_APPLICATIONS" AS
/* $Header: jgzzrrab.pls 120.10 2005/08/25 23:34:18 cleyvaol ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

  PG_DEBUG varchar2(1);

PROCEDURE Apply(p_apply_before_after          IN     VARCHAR2 ,
                  p_global_attribute_category   IN OUT NOCOPY VARCHAR2 ,
                  p_set_of_books_id             IN     NUMBER   ,
                  p_cash_receipt_id             IN     VARCHAR2 ,
                  p_receipt_date                IN     DATE     ,
                  p_applied_payment_schedule_id IN     NUMBER   ,
                  p_amount_applied              IN     NUMBER   ,
                  p_unapplied_amount            IN     NUMBER   ,
                  p_due_date                    IN     DATE     ,
                  p_receipt_method_id           IN     NUMBER   ,
                  p_remittance_bank_account_id  IN     NUMBER   ,
                  p_global_attribute1           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute2           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute3           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute4           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute5           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute6           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute7           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute8           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute9           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute10          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute11          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute12          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute13          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute14          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute15          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute16          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute17          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute18          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute19          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute20          IN OUT NOCOPY VARCHAR2 ,
                  p_return_status               OUT NOCOPY    VARCHAR2) IS


    l_product_code   VARCHAR2(2);
    l_country_code   VARCHAR2(2);

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jg_ar_receivable_applications.Apply()+');
    END IF;

    l_product_code := FND_PROFILE.VALUE('JGZZ_PRODUCT_CODE');
    l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');

    IF l_product_code IS NULL THEN
      IF (p_global_attribute_category IS NULL) AND
         (p_global_attribute1  IS NULL) AND
         (p_global_attribute2  IS NULL) AND
         (p_global_attribute3  IS NULL) AND
         (p_global_attribute4  IS NULL) AND
         (p_global_attribute5  IS NULL) AND
         (p_global_attribute6  IS NULL) AND
         (p_global_attribute7  IS NULL) AND
         (p_global_attribute8  IS NULL) AND
         (p_global_attribute9  IS NULL) AND
         (p_global_attribute10 IS NULL) AND
         (p_global_attribute11 IS NULL) AND
         (p_global_attribute12 IS NULL) AND
         (p_global_attribute13 IS NULL) AND
         (p_global_attribute14 IS NULL) AND
         (p_global_attribute15 IS NULL) AND
         (p_global_attribute16 IS NULL) AND
         (p_global_attribute17 IS NULL) AND
         (p_global_attribute18 IS NULL) AND
         (p_global_attribute19 IS NULL) AND
         (p_global_attribute20 IS NULL) THEN
        p_return_status := FND_API.G_RET_STS_SUCCESS;
      ELSE
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    ELSIF  l_product_code = 'JL' AND l_country_code = 'BR' THEN

-- BUG 3086341

      BEGIN
        SELECT descriptive_flex_context_code
        INTO p_global_attribute_category
        FROM  fnd_descr_flex_contexts
        WHERE application_id = 7003
        AND descriptive_flexfield_name = 'JG_AR_RECEIVABLE_APPLICATIONS'
        AND substr(descriptive_flex_context_code,4,2) = l_country_code
        AND substr(descriptive_flex_context_code,7,8) = 'ARXRWMAI'
        AND enabled_flag = 'Y';

      EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('JG','JG_ZZ_INVALID_GLOBAL_ATTB_CAT');
            FND_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Validate_gbl: ' || 'Invalid global attribute category');
            END IF;
            Return;
      END;

      jg_zz_global_flex_vald_pkg.Validate_Global_Flexfield(
                       p_global_attribute_category,
                       p_global_attribute1,
                       p_global_attribute2,
                       p_global_attribute3,
                       p_global_attribute4,
                       p_global_attribute5,
                       p_global_attribute6,
                       p_global_attribute7,
                       p_global_attribute8,
                       p_global_attribute9,
                       p_global_attribute10,
                       p_global_attribute11,
                       p_global_attribute12,
                       p_global_attribute13,
                       p_global_attribute14,
                       p_global_attribute15,
                       p_global_attribute16,
                       p_global_attribute17,
                       p_global_attribute18,
                       p_global_attribute19,
                       p_global_attribute20,
                       'JG_AR_RECEIVABLE_APPLICATIONS',
                       p_return_status);

      IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
        jl_ar_receivable_applications.Apply(p_apply_before_after,
                                            p_global_attribute_category,
                                            p_set_of_books_id,
                                            p_cash_receipt_id,
                                            p_receipt_date,
                                            p_applied_payment_schedule_id,
                                            p_amount_applied,
                                            p_unapplied_amount,
                                            p_due_date,
                                            p_receipt_method_id,
                                            p_remittance_bank_account_id,
                                            p_global_attribute1,
                                            p_global_attribute2,
                                            p_global_attribute3,
                                            p_global_attribute4,
                                            p_global_attribute5,
                                            p_global_attribute6,
                                            p_global_attribute7,
                                            p_global_attribute8,
                                            p_global_attribute9,
                                            p_global_attribute10,
                                            p_global_attribute11,
                                            p_global_attribute12,
                                            p_global_attribute13,
                                            p_global_attribute14,
                                            p_global_attribute15,
                                            p_global_attribute16,
                                            p_global_attribute17,
                                            p_global_attribute18,
                                            p_global_attribute19,
                                            p_global_attribute20,
                                            p_return_status);
      ELSE
        NULL;
      END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jg_ar_receivable_applications.Apply()-');
    END IF;


  END Apply;

PROCEDURE Unapply(
                  p_cash_receipt_id             IN     VARCHAR2 ,
                  p_applied_payment_schedule_id IN     NUMBER   ,
                  p_return_status               OUT NOCOPY    VARCHAR2) IS

    l_product_code   VARCHAR2(2);

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jg_ar_receivable_applications.Unapply()+');
    END IF;

    l_product_code := FND_PROFILE.VALUE('JGZZ_PRODUCT_CODE');

    IF l_product_code IS NULL THEN
       p_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSIF  l_product_code = 'JL' THEN
      jl_ar_receivable_applications.Unapply(
                                            p_cash_receipt_id,
                                            p_applied_payment_schedule_id,
                                            p_return_status);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jg_ar_receivable_applications.Unapply()-');
    END IF;


  END Unapply;

PROCEDURE create_interest_adjustment(
                   p_post_quickcash_req_id IN NUMBER,
                   x_return_status OUT NOCOPY VARCHAR2)
IS
l_product_code VARCHAR2(2);
BEGIN

  fnd_file.put_line(fnd_file.log,'jg_ar_receivable_applications.create_interest_adj()-');

  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  l_product_code := FND_PROFILE.VALUE('JGZZ_PRODUCT_CODE');

  IF nvl(l_product_code,'$') = 'JL' THEN

   JL_AR_RECEIVABLE_APPLICATIONS.create_interest_adjustment
                                   (p_post_quickcash_req_id,
                                         x_return_status);
  fnd_file.put_line(fnd_file.log,'After jg_ar_receivable_applications.create_interest_adj()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status  := FND_API.G_RET_STS_ERROR;

END Create_interest_adjustment;

PROCEDURE delete_interest_adjustment(
                   p_cash_receipt_id IN NUMBER,
                   x_return_status OUT NOCOPY VARCHAR2)
IS
l_product_code VARCHAR2(2);
BEGIN

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  l_product_code := FND_PROFILE.VALUE('JGZZ_PRODUCT_CODE');

  IF nvl(l_product_code,'$') = 'JL' THEN

   JL_AR_RECEIVABLE_APPLICATIONS.delete_interest_adjustment
                                   (p_cash_receipt_id ,
                                    x_return_status );
  END IF;


END delete_interest_adjustment;

BEGIN

  PG_DEBUG := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');

END jg_ar_receivable_applications;

/
