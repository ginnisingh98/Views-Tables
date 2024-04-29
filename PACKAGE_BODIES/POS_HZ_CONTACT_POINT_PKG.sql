--------------------------------------------------------
--  DDL for Package Body POS_HZ_CONTACT_POINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_HZ_CONTACT_POINT_PKG" AS
/*$Header: POSHZCPB.pls 120.5.12010000.5 2011/09/23 10:49:29 ashgup ship $ */

-- update if exists, create otherwise
PROCEDURE create_or_update_tca_phone
  ( p_owner_table_id     IN  NUMBER   ,
    p_owner_table_name   IN  VARCHAR2 ,
    p_country_code       IN  VARCHAR2 ,
    p_area_code          IN  VARCHAR2 ,
    p_number             IN  VARCHAR2 ,
    p_extension          IN  VARCHAR2 ,
--Start Bug 6620664
    p_phone_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM,
--End Bug 6620664
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER  ,
    x_msg_data           OUT NOCOPY VARCHAR2
    )
IS
   CURSOR l_cur IS
      SELECT contact_point_id, object_version_number,
             phone_number, phone_area_code, phone_extension
        FROM hz_contact_points
       WHERE owner_table_name = p_owner_table_name
         AND owner_table_id = p_owner_table_id
         AND contact_point_type = 'PHONE'
         AND phone_line_type = 'GEN'
         AND primary_flag = 'Y'
         AND status = 'A' ;

   l_rec   l_cur%ROWTYPE;
   l_found BOOLEAN;

   l_contact_point_id    NUMBER;
   l_contact_points_rec  hz_contact_point_v2pub.contact_point_rec_type;
   l_phone_rec           hz_contact_point_v2pub.phone_rec_type;

BEGIN

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   l_found := l_cur%found;
   CLOSE l_cur;

   IF l_found THEN

      IF p_number is NULL OR trim(p_number) IS NULL THEN

         l_contact_points_rec.status := 'I';

         -- keep the old number when inactivating
         l_phone_rec.phone_number    := l_rec.phone_number;

       ELSE
         IF (l_rec.phone_area_code IS NULL     AND p_area_code IS NULL OR
             l_rec.phone_area_code IS NOT NULL AND p_area_code IS NOT NULL AND
             l_rec.phone_area_code             =   p_area_code
             ) AND
            (l_rec.phone_number    IS NULL     AND p_number    IS NULL OR
             l_rec.phone_number    IS NOT NULL AND p_number    IS NOT NULL AND
             l_rec.phone_number                =   p_number
             ) AND
            (l_rec.phone_extension    IS NULL     AND p_extension    IS NULL OR
             l_rec.phone_extension    IS NOT NULL AND p_extension    IS NOT NULL AND
             l_rec.phone_extension                =   p_extension
             ) THEN
            -- the current data is the same as the new data so no change needed
	    x_return_status := fnd_api.g_ret_sts_success;
            RETURN;
         END IF;

         l_contact_points_rec.status := 'A';
         l_phone_rec.phone_number    := p_number;

      END IF;

--Start for Bug 12928774
      IF (l_rec.phone_area_code IS NOT NULL  AND p_area_code IS NULL) THEN
        l_phone_rec.phone_area_code    := fnd_api.g_miss_char;
      ELSE
        l_phone_rec.phone_area_code    := p_area_code;
      END IF;
      IF (l_rec.phone_extension IS NOT NULL  AND p_extension IS NULL) THEN
        l_phone_rec.phone_extension    := fnd_api.g_miss_char;
      ELSE
        l_phone_rec.phone_extension    := p_extension;
      END IF;
--End for Bug 12928774

      l_contact_points_rec.contact_point_id := l_rec.contact_point_id;
      l_phone_rec.phone_country_code := p_country_code;
      l_phone_rec.phone_line_type    := 'GEN';

--Start for Bug 6620664
      IF p_phone_object_version_number <> fnd_api.G_NULL_NUM THEN

          l_rec.object_version_number := p_phone_object_version_number;
      END IF;
--End for Bug 6620664

      hz_contact_point_v2pub.update_contact_point
        (p_init_msg_list          => fnd_api.g_false,
         p_contact_point_rec      => l_contact_points_rec,
         p_phone_rec              => l_phone_rec,
         p_object_version_number  => l_rec.object_version_number,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data
         );

    pos_log.log_call_result
      (p_module        => 'POSADMB',
       p_prefix        => 'call hz_contact_point_v2pub.update_contact_point',
       p_return_status => x_return_status,
       p_msg_count     => x_msg_count,
       p_msg_data      => x_msg_data
       );

    ELSIF p_number IS NOT NULL THEN
       l_phone_rec.phone_country_code := p_country_code;
       l_phone_rec.phone_area_code    := p_area_code;
       l_phone_rec.phone_number       := p_number;
       l_phone_rec.phone_extension    := p_extension;
       l_phone_rec.phone_line_type    := 'GEN';

       l_contact_points_rec.contact_point_type := 'PHONE';
       l_contact_points_rec.status             := 'A';
       l_contact_points_rec.owner_table_name   := p_owner_table_name;
       l_contact_points_rec.owner_table_id     := p_owner_table_id;
       l_contact_points_rec.created_by_module  := 'POS_SUPPLIER_MGMT';
       l_contact_points_rec.application_id     := 177;
       l_contact_points_rec.primary_flag       := 'Y';

       hz_contact_point_v2pub.create_contact_point
         ( p_init_msg_list     => fnd_api.g_false,
           p_contact_point_rec => l_contact_points_rec,
           p_phone_rec         => l_phone_rec,
           x_contact_point_id  => l_contact_point_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data
           );

       pos_log.log_call_result
	 (p_module        => 'POSADMB',
	  p_prefix        => 'call hz_contact_point_v2pub.create_contact_point',
	  p_return_status => x_return_status,
	  p_msg_count     => x_msg_count,
	  p_msg_data      => x_msg_data
       );
    ELSE
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;

END create_or_update_tca_phone;

-- update if exists, create otherwise
PROCEDURE create_or_update_tca_fax
  ( p_owner_table_id     IN  NUMBER   ,
    p_owner_table_name   IN  VARCHAR2 ,
    p_country_code       IN  VARCHAR2 ,
    p_area_code          IN  VARCHAR2 ,
    p_number             IN  VARCHAR2 ,
    p_extension          IN  VARCHAR2 ,
--Start Bug 6620664
    p_fax_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM,
--End Bug 6620664
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER  ,
    x_msg_data           OUT NOCOPY VARCHAR2
    )
IS
   CURSOR l_cur IS
      SELECT contact_point_id, object_version_number, phone_number,
             phone_area_code, phone_extension
        FROM hz_contact_points
       WHERE owner_table_name = p_owner_table_name
         AND owner_table_id = p_owner_table_id
         AND contact_point_type = 'PHONE'
         AND phone_line_type = 'FAX'
         AND status = 'A' ;

   l_rec   l_cur%ROWTYPE;
   l_found BOOLEAN;

   l_contact_point_id    NUMBER;
   l_contact_points_rec  hz_contact_point_v2pub.contact_point_rec_type;
   l_phone_rec           hz_contact_point_v2pub.phone_rec_type;

BEGIN

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   l_found := l_cur%found;
   CLOSE l_cur;

   IF l_found THEN

      IF p_number is NULL OR trim(p_number) IS NULL THEN

         l_contact_points_rec.status := 'I';

         -- keep the old number when inactivating
         l_phone_rec.phone_number    := l_rec.phone_number;
       ELSE
         IF (l_rec.phone_area_code IS NULL     AND p_area_code IS NULL OR
             l_rec.phone_area_code IS NOT NULL AND p_area_code IS NOT NULL AND
             l_rec.phone_area_code             =   p_area_code
             ) AND
            (l_rec.phone_number    IS NULL     AND p_number    IS NULL OR
             l_rec.phone_number    IS NOT NULL AND p_number    IS NOT NULL AND
             l_rec.phone_number                =   p_number
             ) AND
	    (l_rec.phone_extension    IS NULL     AND p_extension    IS NULL OR
             l_rec.phone_extension    IS NOT NULL AND p_extension    IS NOT NULL AND
             l_rec.phone_extension                =   p_extension
             ) THEN
            -- the current data is the same as the new data so no change needed
	    x_return_status := fnd_api.g_ret_sts_success;
            RETURN;
         END IF;
         l_contact_points_rec.status := 'A';
         l_phone_rec.phone_number    := p_number;
      END IF;

--Start for Bug 12928774
      IF (l_rec.phone_area_code IS NOT NULL  AND p_area_code IS NULL) THEN
        l_phone_rec.phone_area_code    := fnd_api.g_miss_char;
      ELSE
        l_phone_rec.phone_area_code    := p_area_code;
      END IF;
      IF (l_rec.phone_extension IS NOT NULL  AND p_extension IS NULL) THEN
        l_phone_rec.phone_extension    := fnd_api.g_miss_char;
      ELSE
        l_phone_rec.phone_extension    := p_extension;
      END IF;
--End for Bug 12928774

	  l_contact_points_rec.contact_point_id := l_rec.contact_point_id;
      l_phone_rec.phone_country_code := p_country_code;
      l_phone_rec.phone_line_type    := 'FAX';

--Start for Bug 6620664
      IF p_fax_object_version_number <> fnd_api.G_NULL_NUM THEN

          l_rec.object_version_number := p_fax_object_version_number;
      END IF;
--End for Bug 6620664

      hz_contact_point_v2pub.update_contact_point
        (p_init_msg_list          => fnd_api.g_false,
         p_contact_point_rec      => l_contact_points_rec,
         p_phone_rec              => l_phone_rec,
         p_object_version_number  => l_rec.object_version_number,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data
         );

    ELSIF p_number IS NOT NULL THEN
       l_phone_rec.phone_country_code := p_country_code;
       l_phone_rec.phone_area_code    := p_area_code;
       l_phone_rec.phone_number       := p_number;
       l_phone_rec.phone_extension    := p_extension;
       l_phone_rec.phone_line_type    := 'FAX';

       l_contact_points_rec.contact_point_type := 'PHONE';
       l_contact_points_rec.status             := 'A';
       l_contact_points_rec.owner_table_name   := p_owner_table_name;
       l_contact_points_rec.owner_table_id     := p_owner_table_id;
       l_contact_points_rec.created_by_module  := 'POS_SUPPLIER_MGMT';
       l_contact_points_rec.application_id     := 177;

       hz_contact_point_v2pub.create_contact_point
         ( p_init_msg_list     => fnd_api.g_false,
           p_contact_point_rec => l_contact_points_rec,
           p_phone_rec         => l_phone_rec,
           x_contact_point_id  => l_contact_point_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data
           );
    ELSE
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;

END create_or_update_tca_fax;

-- update if exists, create otherwise
PROCEDURE create_or_update_tca_email
  ( p_owner_table_id   IN  NUMBER,
    p_owner_table_name IN  VARCHAR2,
    p_email_address    IN  VARCHAR2,
--Start Bug 6620664
    p_email_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM,
--End Bug 6620664
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
    )
  IS
     CURSOR l_cur IS
        SELECT contact_point_id, object_version_number, email_address
          FROM hz_contact_points
         WHERE owner_table_name = p_owner_table_name
           AND owner_table_id = p_owner_table_id
           AND contact_point_type = 'EMAIL'
           AND primary_flag = 'Y'
           AND status = 'A';

     l_rec    l_cur%ROWTYPE;
     l_found  BOOLEAN;

     l_contact_point_id    NUMBER;
     l_contact_points_rec  hz_contact_point_v2pub.contact_point_rec_type;
     l_email_rec           hz_contact_point_v2pub.email_rec_type;

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   l_found := l_cur%found;
   CLOSE l_cur;

   IF l_found THEN
      IF p_email_address is NULL or trim(p_email_address) IS NULL THEN

         l_contact_points_rec.status := 'I';

         -- keep the old value when inactivating
         l_email_rec.email_address   := l_rec.email_address;
       ELSE
         IF (l_rec.email_address IS NULL     AND p_email_address IS NULL OR
             l_rec.email_address IS NOT NULL AND p_email_address IS NOT NULL AND
             l_rec.email_address             =   p_email_address
             ) THEN
            -- the current data is the same as the new data so no change needed
	    x_return_status := fnd_api.g_ret_sts_success;
            RETURN;
         END IF;

         l_contact_points_rec.status := 'A';
         l_email_rec.email_address   := p_email_address;
      END IF;

      l_contact_points_rec.contact_point_id := l_rec.contact_point_id;

      l_email_rec.email_format := 'MAILTEXT';

--Start for Bug 6620664
      IF p_email_object_version_number <> fnd_api.G_NULL_NUM THEN

          l_rec.object_version_number := p_email_object_version_number;
      END IF;
--End for Bug 6620664

      hz_contact_point_v2pub.update_contact_point
        (p_init_msg_list          => fnd_api.g_false,
         p_contact_point_rec      => l_contact_points_rec,
         p_email_rec              => l_email_rec,
         p_object_version_number  => l_rec.object_version_number,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data
         );

    ELSIF p_email_address is NOT NULL THEN
      l_email_rec.email_format   := 'MAILTEXT';
      l_email_rec.email_address  := p_email_address;

      l_contact_points_rec.contact_point_type := 'EMAIL';
      l_contact_points_rec.status             := 'A';
      l_contact_points_rec.owner_table_name   := p_owner_table_name;
      l_contact_points_rec.owner_table_id     := p_owner_table_id;
      l_contact_points_rec.created_by_module  := 'POS_SUPPLIER_MGMT';
      l_contact_points_rec.application_id     := 177;

      hz_contact_point_v2pub.create_contact_point
        ( p_init_msg_list     => fnd_api.g_false,
          p_contact_point_rec => l_contact_points_rec,
          p_email_rec         => l_email_rec,
          x_contact_point_id  => l_contact_point_id,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data
          );
    ELSE
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;

END create_or_update_tca_email;

-- update if exists, create otherwise
PROCEDURE create_or_update_tca_alt_phone
  ( p_owner_table_id     IN  NUMBER   ,
    p_owner_table_name   IN  VARCHAR2 ,
    p_country_code       IN  VARCHAR2 ,
    p_area_code          IN  VARCHAR2 ,
    p_number             IN  VARCHAR2 ,
    p_extension          IN  VARCHAR2 ,
    p_phone_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER  ,
    x_msg_data           OUT NOCOPY VARCHAR2
    )
IS
   CURSOR l_cur IS
      SELECT contact_point_id, object_version_number,
             phone_number, phone_area_code, phone_extension
        FROM hz_contact_points
       WHERE owner_table_name = p_owner_table_name
         AND owner_table_id = p_owner_table_id
         AND contact_point_type = 'PHONE'
         AND phone_line_type = 'GEN'
         AND primary_flag = 'N'
         AND status = 'A' ;

   l_rec   l_cur%ROWTYPE;
   l_found BOOLEAN;

   l_contact_point_id    NUMBER;
   l_contact_points_rec  hz_contact_point_v2pub.contact_point_rec_type;
   l_phone_rec           hz_contact_point_v2pub.phone_rec_type;

BEGIN

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   l_found := l_cur%found;
   CLOSE l_cur;

   IF l_found THEN

      IF p_number is NULL OR trim(p_number) IS NULL THEN

         l_contact_points_rec.status := 'I';

         -- keep the old number when inactivating
         l_phone_rec.phone_number    := l_rec.phone_number;

       ELSE
         IF (l_rec.phone_area_code IS NULL     AND p_area_code IS NULL OR
             l_rec.phone_area_code IS NOT NULL AND p_area_code IS NOT NULL AND
             l_rec.phone_area_code             =   p_area_code
             ) AND
            (l_rec.phone_number    IS NULL     AND p_number    IS NULL OR
             l_rec.phone_number    IS NOT NULL AND p_number    IS NOT NULL AND
             l_rec.phone_number                =   p_number
             ) AND
            (l_rec.phone_extension    IS NULL     AND p_extension    IS NULL OR
             l_rec.phone_extension    IS NOT NULL AND p_extension    IS NOT NULL AND
             l_rec.phone_extension                =   p_extension
             ) THEN
            -- the current data is the same as the new data so no change needed
	    x_return_status := fnd_api.g_ret_sts_success;
            RETURN;
         END IF;

         l_contact_points_rec.status := 'A';
         l_phone_rec.phone_number    := p_number;

      END IF;

--Start for Bug 12928774
      IF (l_rec.phone_area_code IS NOT NULL  AND p_area_code IS NULL) THEN
        l_phone_rec.phone_area_code    := fnd_api.g_miss_char;
      ELSE
        l_phone_rec.phone_area_code    := p_area_code;
      END IF;
      IF (l_rec.phone_extension IS NOT NULL  AND p_extension IS NULL) THEN
        l_phone_rec.phone_extension    := fnd_api.g_miss_char;
      ELSE
        l_phone_rec.phone_extension    := p_extension;
      END IF;
--End for Bug 12928774

      l_contact_points_rec.contact_point_id := l_rec.contact_point_id;
      l_phone_rec.phone_country_code := p_country_code;
      l_phone_rec.phone_line_type    := 'GEN';

      IF p_phone_object_version_number <> fnd_api.G_NULL_NUM THEN
          l_rec.object_version_number := p_phone_object_version_number;
      END IF;

      hz_contact_point_v2pub.update_contact_point
        (p_init_msg_list          => fnd_api.g_false,
         p_contact_point_rec      => l_contact_points_rec,
         p_phone_rec              => l_phone_rec,
         p_object_version_number  => l_rec.object_version_number,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data
         );

    pos_log.log_call_result
      (p_module        => 'POSADMB',
       p_prefix        => 'call hz_contact_point_v2pub.update_contact_point',
       p_return_status => x_return_status,
       p_msg_count     => x_msg_count,
       p_msg_data      => x_msg_data
       );

    ELSIF p_number IS NOT NULL THEN
       l_phone_rec.phone_country_code := p_country_code;
       l_phone_rec.phone_area_code    := p_area_code;
       l_phone_rec.phone_number       := p_number;
       l_phone_rec.phone_extension    := p_extension;
       l_phone_rec.phone_line_type    := 'GEN';

       l_contact_points_rec.contact_point_type := 'PHONE';
       l_contact_points_rec.status             := 'A';
       l_contact_points_rec.owner_table_name   := p_owner_table_name;
       l_contact_points_rec.owner_table_id     := p_owner_table_id;
       l_contact_points_rec.created_by_module  := 'POS_SUPPLIER_MGMT';
       l_contact_points_rec.application_id     := 177;
       l_contact_points_rec.primary_flag       := 'N';

       hz_contact_point_v2pub.create_contact_point
         ( p_init_msg_list     => fnd_api.g_false,
           p_contact_point_rec => l_contact_points_rec,
           p_phone_rec         => l_phone_rec,
           x_contact_point_id  => l_contact_point_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data
           );

       pos_log.log_call_result
	 (p_module        => 'POSADMB',
	  p_prefix        => 'call hz_contact_point_v2pub.create_contact_point',
	  p_return_status => x_return_status,
	  p_msg_count     => x_msg_count,
	  p_msg_data      => x_msg_data
       );
    ELSE
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;

END create_or_update_tca_alt_phone;

-- update if exists, create otherwise
PROCEDURE create_or_update_tca_url
  ( p_owner_table_id   IN  NUMBER,
    p_owner_table_name IN  VARCHAR2,
    p_url    IN  VARCHAR2,
    p_url_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
    )
  IS
     CURSOR l_cur IS
        SELECT contact_point_id, object_version_number, url
          FROM hz_contact_points
         WHERE owner_table_name = p_owner_table_name
           AND owner_table_id = p_owner_table_id
           AND contact_point_type = 'WEB'
           AND status = 'A';

     l_rec    l_cur%ROWTYPE;
     l_found  BOOLEAN;

     l_contact_point_id    NUMBER;
     l_contact_points_rec  hz_contact_point_v2pub.contact_point_rec_type;
     l_url_rec             hz_contact_point_v2pub.web_rec_type;

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   l_found := l_cur%found;
   CLOSE l_cur;

   IF l_found THEN
      IF p_url is NULL or trim(p_url) IS NULL THEN

         l_contact_points_rec.status := 'I';

         -- keep the old value when inactivating
         l_url_rec.url   := l_rec.url;
         l_url_rec.web_type := 'HTTP';
       ELSE
         IF (l_rec.url IS NULL     AND p_url IS NULL OR
             l_rec.url IS NOT NULL AND p_url IS NOT NULL AND
             l_rec.url             =   p_url
             ) THEN
            -- the current data is the same as the new data so no change needed
	    x_return_status := fnd_api.g_ret_sts_success;
            RETURN;
         END IF;

         l_contact_points_rec.status := 'A';
         l_url_rec.web_type := 'HTTP';
         l_url_rec.url   := p_url;
      END IF;

      l_contact_points_rec.contact_point_id := l_rec.contact_point_id;

      IF p_url_object_version_number <> fnd_api.G_NULL_NUM THEN
          l_rec.object_version_number := p_url_object_version_number;
      END IF;

      hz_contact_point_v2pub.update_contact_point
        (p_init_msg_list          => fnd_api.g_false,
         p_contact_point_rec      => l_contact_points_rec,
         p_web_rec                => l_url_rec,
         p_object_version_number  => l_rec.object_version_number,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data
         );

    ELSIF p_url is NOT NULL THEN
      l_url_rec.url  := p_url;
      l_url_rec.web_type := 'HTTP';
      l_contact_points_rec.contact_point_type := 'WEB';
      l_contact_points_rec.status             := 'A';
      l_contact_points_rec.owner_table_name   := p_owner_table_name;
      l_contact_points_rec.owner_table_id     := p_owner_table_id;
      l_contact_points_rec.created_by_module  := 'POS_SUPPLIER_MGMT';
      l_contact_points_rec.application_id     := 177;

      hz_contact_point_v2pub.create_contact_point
        ( p_init_msg_list     => fnd_api.g_false,
          p_contact_point_rec => l_contact_points_rec,
          p_web_rec           => l_url_rec,
          x_contact_point_id  => l_contact_point_id,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data
          );
    ELSE
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;

END create_or_update_tca_url;

PROCEDURE update_party_phone
  ( p_party_id          IN  NUMBER
  , p_country_code      IN  VARCHAR2
  , p_area_code         IN  VARCHAR2
  , p_number            IN  VARCHAR2
  , p_extension         IN  VARCHAR2
--Start Bug 6620664
  , p_phone_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM
--End Bug 6620664
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
    )
  IS
BEGIN
   create_or_update_tca_phone
     (p_owner_table_id   =>  p_party_id,
      p_owner_table_name =>  'HZ_PARTIES',
      p_country_code     =>  p_country_code,
      p_area_code        =>  p_area_code,
      p_number           =>  p_number,
      p_extension        =>  p_extension,
--Start Bug 6620664
      p_phone_object_version_number => p_phone_object_version_number,
--End Bug 6620664
      x_return_status    =>  x_return_status,
      x_msg_count        =>  x_msg_count,
      x_msg_data         =>  x_msg_data
      );
END update_party_phone;

PROCEDURE update_party_fax
  ( p_party_id          IN  NUMBER
  , p_country_code      IN  VARCHAR2
  , p_area_code         IN  VARCHAR2
  , p_number            IN  VARCHAR2
  , p_extension         IN  VARCHAR2
--Start Bug 6620664
  , p_fax_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM
--End Bug 6620664
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  )
  IS
BEGIN
   create_or_update_tca_fax
     (p_owner_table_id   =>  p_party_id,
      p_owner_table_name =>  'HZ_PARTIES',
      p_country_code     =>  p_country_code,
      p_area_code        =>  p_area_code,
      p_number           =>  p_number,
      p_extension        =>  p_extension,
--Start Bug 6620664
      p_fax_object_version_number => p_fax_object_version_number,
--End Bug 6620664
      x_return_status    =>  x_return_status,
      x_msg_count        =>  x_msg_count,
      x_msg_data         =>  x_msg_data
      );
END update_party_fax;

PROCEDURE update_party_email
  ( p_party_id          IN  NUMBER
  , p_email             IN  VARCHAR2
--Start Bug 6620664
  , p_email_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM
--End Bug 6620664
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  )
IS
BEGIN
   create_or_update_tca_email
     (p_owner_table_id   =>  p_party_id,
      p_owner_table_name =>  'HZ_PARTIES',
      p_email_address    =>  p_email,
--Start Bug 6620664
      p_email_object_version_number => p_email_object_version_number,
--End Bug 6620664
      x_return_status    =>  x_return_status,
      x_msg_count        =>  x_msg_count,
      x_msg_data         =>  x_msg_data
      );
END update_party_email;

PROCEDURE update_party_alt_phone
  ( p_party_id          IN  NUMBER
  , p_country_code      IN  VARCHAR2
  , p_area_code         IN  VARCHAR2
  , p_number            IN  VARCHAR2
  , p_extension         IN  VARCHAR2
  , p_phone_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  )
  IS
BEGIN
   create_or_update_tca_alt_phone
     (p_owner_table_id   =>  p_party_id,
      p_owner_table_name =>  'HZ_PARTIES',
      p_country_code     =>  p_country_code,
      p_area_code        =>  p_area_code,
      p_number           =>  p_number,
      p_extension        =>  p_extension,
      p_phone_object_version_number => p_phone_object_version_number,
      x_return_status    =>  x_return_status,
      x_msg_count        =>  x_msg_count,
      x_msg_data         =>  x_msg_data
      );
END update_party_alt_phone;

PROCEDURE update_party_url
  ( p_party_id          IN  NUMBER
  , p_url               IN  VARCHAR2
  , p_url_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  )
IS
BEGIN
   create_or_update_tca_url
     (p_owner_table_id   =>  p_party_id,
      p_owner_table_name =>  'HZ_PARTIES',
      p_url              =>  p_url,
      p_url_object_version_number => p_url_object_version_number,
      x_return_status    =>  x_return_status,
      x_msg_count        =>  x_msg_count,
      x_msg_data         =>  x_msg_data
      );
END update_party_url;

PROCEDURE update_party_site_phone
  ( p_party_site_id     IN  NUMBER
  , p_country_code      IN  VARCHAR2
  , p_area_code         IN  VARCHAR2
  , p_number            IN  VARCHAR2
  , p_extension         IN  VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  ) IS
BEGIN
   create_or_update_tca_phone
     (p_owner_table_id   =>  p_party_site_id,
      p_owner_table_name =>  'HZ_PARTY_SITES',
      p_country_code     =>  p_country_code,
      p_area_code        =>  p_area_code,
      p_number           =>  p_number,
      p_extension        =>  p_extension,
      x_return_status    =>  x_return_status,
      x_msg_count        =>  x_msg_count,
      x_msg_data         =>  x_msg_data
      );
END update_party_site_phone;

PROCEDURE update_party_site_fax
  ( p_party_site_id     IN  NUMBER
  , p_country_code      IN  VARCHAR2
  , p_area_code         IN  VARCHAR2
  , p_number            IN  VARCHAR2
  , p_extension         IN  VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  ) IS
BEGIN
   create_or_update_tca_fax
     (p_owner_table_id   =>  p_party_site_id,
      p_owner_table_name =>  'HZ_PARTY_SITES',
      p_country_code     =>  p_country_code,
      p_area_code        =>  p_area_code,
      p_number           =>  p_number,
      p_extension        =>  p_extension,
      x_return_status    =>  x_return_status,
      x_msg_count        =>  x_msg_count,
      x_msg_data         =>  x_msg_data
      );
END update_party_site_fax;

PROCEDURE update_party_site_email
  ( p_party_site_id     IN  NUMBER
  , p_email             IN  VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  ) IS
BEGIN
   create_or_update_tca_email
     (p_owner_table_id   =>  p_party_site_id,
      p_owner_table_name =>  'HZ_PARTY_SITES',
      p_email_address    =>  p_email,
      x_return_status    =>  x_return_status,
      x_msg_count        =>  x_msg_count,
      x_msg_data         =>  x_msg_data
      );
END update_party_site_email;

END pos_hz_contact_point_pkg;

/
