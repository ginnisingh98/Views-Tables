--------------------------------------------------------
--  DDL for Package Body JG_ZZ_GLOBAL_FLEX_VALD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_GLOBAL_FLEX_VALD_PKG" AS
/* $Header: jgzzrfvb.pls 120.7 2005/08/25 23:30:55 cleyvaol ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/


PG_DEBUG varchar2(1) ;

PROCEDURE Validate_Global_Flexfield(
                          p_global_attribute_category  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute1  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute2  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute3  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute4  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute5  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute6  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute7  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute8  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute9  IN OUT NOCOPY VARCHAR2,
                          p_global_attribute10 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute11 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute12 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute13 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute14 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute15 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute16 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute17 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute18 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute19 IN OUT NOCOPY VARCHAR2,
                          p_global_attribute20 IN OUT NOCOPY VARCHAR2,
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
  WHERE application_id = 7003
    and descriptive_flexfield_name = p_desc_flex_name;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_Global_Flexfield ()+');
    END IF;
      p_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN desc_flex_exists;
      FETCH desc_flex_exists INTO l_flex_exists;
      IF desc_flex_exists%NOTFOUND THEN
       CLOSE desc_flex_exists;
       p_return_status :=  FND_API.G_RET_STS_ERROR;
       return;
      END IF;
      CLOSE desc_flex_exists;


     fnd_flex_descval.set_context_value(p_global_attribute_category);

     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE1', p_global_attribute1);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE2', p_global_attribute2);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE3', p_global_attribute3);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE4', p_global_attribute4);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE5', p_global_attribute5);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE6', p_global_attribute6);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE7', p_global_attribute7);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE8', p_global_attribute8);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE9', p_global_attribute9);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE10', p_global_attribute10);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE11', p_global_attribute11);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE12', p_global_attribute12);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE13', p_global_attribute13);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE14', p_global_attribute14);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE15', p_global_attribute15);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE16', p_global_attribute16);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE17', p_global_attribute17);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE18', p_global_attribute18);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE19', p_global_attribute19);
     fnd_flex_descval.set_column_value('GLOBAL_ATTRIBUTE20', p_global_attribute20);

 --   IF ( NOT fnd_flex_descval.validate_desccols('JG',p_desc_flex_name,'V') ) -- Bug 3414555
     IF ( NOT fnd_flex_descval.validate_desccols('JG',p_desc_flex_name,'I') )
     THEN

       FND_MESSAGE.SET_NAME('AR', 'AR_RAPI_DESC_FLEX_INVALID');
       FND_MESSAGE.SET_TOKEN('DFF_NAME',p_desc_flex_name);
       FND_MSG_PUB.ADD ;
       p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

      l_count := fnd_flex_descval.segment_count;

      FOR i in 1..l_count LOOP
        l_col_name := fnd_flex_descval.segment_column_name(i);

    /*    IF l_col_name = 'GLOBAL_ATTRIBUTE_CATEGORY'  THEN
          p_global_attribute_category := fnd_flex_descval.segment_value(i); */ -- Bug 3414555
        IF l_col_name = 'GLOBAL_ATTRIBUTE1' THEN
          p_global_attribute1 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE2' THEN
          p_global_attribute2 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE3' THEN
          p_global_attribute3 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE4' THEN
          p_global_attribute4 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE5' THEN
          p_global_attribute5 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE6' THEN
          p_global_attribute6 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE7' THEN
          p_global_attribute7 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE8' THEN
          p_global_attribute8 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE9' THEN
          p_global_attribute9 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE10' THEN
          p_global_attribute10 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE11' THEN
          p_global_attribute11 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE12' THEN
          p_global_attribute12 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE13' THEN
          p_global_attribute13 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE14' THEN
          p_global_attribute14 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE15' THEN
          p_global_attribute15 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE16' THEN
          p_global_attribute16 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE17' THEN
          p_global_attribute17 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE18' THEN
          p_global_attribute18 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE19' THEN
          p_global_attribute19 := fnd_flex_descval.segment_value(i);
        ELSIF l_col_name = 'GLOBAL_ATTRIBUTE20' THEN
          p_global_attribute20 := fnd_flex_descval.segment_value(i);
        END IF;

        IF i > l_count  THEN
          EXIT;
        END IF;
       END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute_category  : '||p_global_attribute_category);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute1          : '||p_global_attribute1);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute2          : '||p_global_attribute2);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute3          : '||p_global_attribute3);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute4          : '||p_global_attribute4);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute5          : '||p_global_attribute5);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute6          : '||p_global_attribute6);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute7          : '||p_global_attribute7);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute8          : '||p_global_attribute8);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute9          : '||p_global_attribute9);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute10         : '||p_global_attribute10);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute11         : '||p_global_attribute11);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute12         : '||p_global_attribute12);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute13         : '||p_global_attribute13);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute14         : '||p_global_attribute14);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute15         : '||p_global_attribute15);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute16         : '||p_global_attribute16);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute17         : '||p_global_attribute17);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute18         : '||p_global_attribute18);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute19         : '||p_global_attribute19);
           arp_util.debug('Validate_Global_Flexfield: ' || 'global_attribute20         : '||p_global_attribute20);
      arp_util.debug('Validate_Global_Flexfield ()-');
   END IF;
END Validate_Global_Flexfield;

PROCEDURE Validate_Global_Attb_Cat(
                                 p_global_attribute_category IN  VARCHAR2,
                                 p_product_code              IN  VARCHAR2,
                                 p_country_code              IN  VARCHAR2,
                                 p_form_name                 IN  VARCHAR2,
                                 p_return_status             OUT NOCOPY BOOLEAN) IS
x_gac_product  VARCHAR2(2);
x_gac_country  VARCHAR2(2);
x_gac_form     VARCHAR2(8);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_Global_Attb_Cat()+');
   END IF;

   x_gac_product := substr(p_global_attribute_category,1,2);
   x_gac_country := substr(p_global_attribute_category,4,2);
   x_gac_form := substr(p_global_attribute_category,7,8);

   IF  (x_gac_product = p_product_code) AND (x_gac_country = p_country_code)
   AND (x_gac_form = p_form_name) THEN
     p_return_status := TRUE;
   ELSE
     p_return_status := FALSE;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('Validate_Global_Attb_Cat()-');
   END IF;

END Validate_Global_Attb_Cat;

BEGIN


PG_DEBUG := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');

END jg_zz_global_flex_vald_pkg;

/
