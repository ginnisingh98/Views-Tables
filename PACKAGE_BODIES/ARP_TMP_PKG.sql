--------------------------------------------------------
--  DDL for Package Body ARP_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TMP_PKG" AS
/* $Header: ARTMPB.pls 120.0 2005/12/23 02:34:04 hyu noship $ */


PROCEDURE workaround_remit_loc_api
( p_location_id     IN NUMBER    DEFAULT NULL,
  p_country         IN VARCHAR2  DEFAULT NULL,
  p_ADDRESS1        IN VARCHAR2  DEFAULT NULL,
  p_CITY            IN VARCHAR2  DEFAULT NULL,
  p_POSTAL_CODE     IN VARCHAR2  DEFAULT NULL,
  p_STATE           IN VARCHAR2  DEFAULT NULL,
  p_PROVINCE        IN VARCHAR2  DEFAULT NULL,
  p_COUNTY          IN VARCHAR2  DEFAULT NULL,
  p_org_id          IN NUMBER,
  x_cust_acct_site_id OUT NOCOPY NUMBER,
  x_party_site_id     OUT NOCOPY NUMBER,
  x_return_status   OUT NOCOPY   VARCHAR2,
  x_msg_data        OUT NOCOPY   VARCHAR2,
  x_msg_count       OUT NOCOPY   NUMBER)
IS
  CURSOR c_loc_1 IS
  SELECT 'A'  FROM hz_locations WHERE location_id = p_location_id;

  CURSOR c_loc_2 IS
  SELECT location_id  FROM hz_locations
   WHERE country                  = p_country
     AND NVL(p_ADDRESS1,'XXX')    = NVL(address1,'XXX')
     AND NVL(p_CITY    ,'XXX')    = NVL(city,'XXX')
     AND NVL(p_POSTAL_CODE,'XXX') = NVL(postal_code,'XXX')
     AND NVL(p_STATE,'XXX')       = NVL(state,'XXX')
     AND NVL(p_PROVINCE,'XXX')    = NVL(province,'XXX')
     AND NVL(p_COUNTY,'XXX')      = NVL(county,'XXX');

  l_loc_id_tab    DBMS_SQL.NUMBER_TABLE;

  l_loc_id        NUMBER;

  psite_rec       hz_party_site_v2pub.party_site_rec_type;
  asite_rec       hz_cust_account_site_v2pub.cust_acct_site_rec_type;

--  x_party_site_id     NUMBER;
  x_party_site_number VARCHAR2(30);
  l_exist             VARCHAR2(10);
--  x_cust_acct_site_id NUMBER;
BEGIN
  x_return_status := fnd_api.G_RET_STS_SUCCESS;

  IF p_location_id IS NOT NULL THEN

    OPEN c_loc_1;
    FETCH c_loc_1 INTO l_exist;
    IF c_loc_1%NOTFOUND THEN
       x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_loc_1;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
       FND_MESSAGE.SET_NAME('AR', 'AR_CUST_API_ERROR');
       FND_MESSAGE.SET_TOKEN('TEXT','Location with the location_id:'||p_location_id||' does not exist');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_loc_id    := p_location_id;

  ELSIF p_country IS NULL THEN

    x_return_status := fnd_api.g_ret_sts_error;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
       FND_MESSAGE.SET_NAME('AR', 'AR_CUST_API_ERROR');
       FND_MESSAGE.SET_TOKEN('TEXT','Country is a mandatory field if you do not pass the location_id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF  (p_ADDRESS1    IS NULL   AND
          p_CITY        IS NULL   AND
          p_POSTAL_CODE IS NULL   AND
          p_STATE       IS NULL   AND
          p_PROVINCE    IS NULL   AND
          p_COUNTY      IS NULL     )
  THEN
    x_return_status := fnd_api.g_ret_sts_error;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      FND_MESSAGE.SET_NAME('AR', 'AR_CUST_API_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT',
   'Please enter either a p_location_id or address elements like address1 ...');
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSE
     OPEN  c_loc_2;
     FETCH c_loc_2 BULK COLLECT INTO l_loc_id_tab;
     CLOSE c_loc_2;

     IF l_loc_id_tab.COUNT = 0 THEN

       x_return_status := fnd_api.g_ret_sts_error;

       IF x_return_status = fnd_api.g_ret_sts_error THEN
          FND_MESSAGE.SET_NAME('AR', 'AR_CUST_API_ERROR');
          FND_MESSAGE.SET_TOKEN('TEXT',
         'The combination of address elements you have provided does not correspond to any location in the DB');
          FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(
           p_encoded                    => fnd_api.g_false,
           p_count                      => x_msg_count,
           p_data                       => x_msg_data);
          RAISE FND_API.G_EXC_ERROR;
       END IF;

     ELSIF l_loc_id_tab.COUNT > 1 THEN

       x_return_status := fnd_api.g_ret_sts_error;

       IF x_return_status = fnd_api.g_ret_sts_error THEN
          FND_MESSAGE.SET_NAME('AR', 'AR_CUST_API_ERROR');
          FND_MESSAGE.SET_TOKEN('TEXT',
         'The combination of address elements you have provided correspond to more than one location in the DB');
          FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get(
           p_encoded                    => fnd_api.g_false,
           p_count                      => x_msg_count,
           p_data                       => x_msg_data);
          RAISE FND_API.G_EXC_ERROR;
       END IF;

     ELSE
       l_loc_id := l_loc_id_tab(1);

     END IF;

  END IF;


   -- Create party_site
   psite_rec.party_id              := -1;
   psite_rec.location_id           := l_loc_id;
   psite_rec.created_by_module     := 'TCA_FORM_WRAPPER';


   HZ_PARTY_SITE_V2PUB.create_party_site (
        p_party_site_rec                   => psite_rec,
        x_party_site_id                    => x_party_site_id,
        x_party_site_number                => x_party_site_number,
        x_return_status                    => x_return_status,
        x_msg_count                        => x_msg_count,
        x_msg_data                         => x_msg_data );

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


  -- Create account site
   asite_rec.cust_account_id       := -1;
   asite_rec.party_site_id         := x_Party_site_id;
   asite_rec.status                := 'A';
   asite_rec.created_by_module     := 'TCA_FORM_WRAPPER';
   asite_rec.ORG_ID                := p_ORG_ID;


  HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site (
        p_cust_acct_site_rec                => asite_rec,
        x_cust_acct_site_id                 => x_cust_acct_site_id,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data  );

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := fnd_api.g_ret_sts_error;
  WHEN OTHERS THEN
    RAISE;

END;

END;

/
