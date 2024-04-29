--------------------------------------------------------
--  DDL for Package Body JG_AR_CASH_RECEIPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_AR_CASH_RECEIPTS" AS
/* $Header: jgzzrcrb.pls 120.6 2005/08/25 23:28:21 cleyvaol ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

  PG_DEBUG varchar2(1) ;

PROCEDURE Validate_gbl(
                  p_global_attribute_category   IN OUT NOCOPY VARCHAR2 ,
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
    l_gac_valid      BOOLEAN;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jg_ar_cash_receipts.Validate_gbl()+');
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
    ELSE

      p_return_status := FND_API.G_RET_STS_SUCCESS;

      IF l_country_code = 'AR' OR
           l_country_code = 'TW' OR
           l_country_code = 'GR' OR
           l_country_code = 'PT' THEN

        BEGIN

          SELECT descriptive_flex_context_code
          INTO p_global_attribute_category
          FROM  fnd_descr_flex_contexts
          WHERE application_id = 7003
          AND descriptive_flexfield_name = 'JG_AR_CASH_RECEIPTS'
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
                       'JG_AR_CASH_RECEIPTS',
                       p_return_status);

        END IF;

 -- BUG 3086341

   /*
        IF l_country_code = 'AR' OR
           l_country_code = 'TW' OR
           l_country_code = 'GR' OR
           l_country_code = 'PT'
        THEN
          jg_zz_global_flex_vald_pkg.validate_global_attb_cat(
                   p_global_attribute_category,
                   l_product_code,
                   l_country_code,
                   'ARXRWMAI',
                   l_gac_valid);

          IF l_gac_valid THEN
            p_return_status := FND_API.G_RET_STS_SUCCESS;
          ELSE
            FND_MESSAGE.SET_NAME('JG','JG_ZZ_INVALID_GLOBAL_ATTB_CAT');
            FND_MSG_PUB.Add;
            p_return_status := FND_API.G_RET_STS_ERROR;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Validate_gbl: ' || 'Invalid global attribute category');
            END IF;
          END IF;
      END IF;

    */

    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jg_ar_cash_receipts.Validate_gbl()-');
    END IF;

  END Validate_gbl;

  PROCEDURE Reverse(
                  p_cash_receipt_id             IN     NUMBER,
                  p_return_status               OUT NOCOPY    VARCHAR2) IS

    l_product_code   VARCHAR2(2);
    l_gac_valid      BOOLEAN;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jg_ar_cash_receipts.Reverse()+');
    END IF;

    l_product_code := FND_PROFILE.VALUE('JGZZ_PRODUCT_CODE');

    IF l_product_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSIF  (l_product_code = 'JL') THEN
      jl_ar_receivable_applications.Reverse(p_cash_receipt_id,
                                            p_return_status);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jg_ar_cash_receipts.Reverse()-');
    END IF;


  END Reverse;

BEGIN


  PG_DEBUG := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');

END jg_ar_cash_receipts;

/
