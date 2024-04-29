--------------------------------------------------------
--  DDL for Package Body POS_HZ_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_HZ_UTIL_PKG" AS
/*$Header: POSHZUTB.pls 120.3 2005/10/11 13:38:16 bitang noship $ */

procedure pos_create_hz_location
  (p_country_code  in  VARCHAR2,
   p_address1      in  VARCHAR2,
   p_address2      in  VARCHAR2,
   p_address3      in  VARCHAR2,
   p_address4      in  VARCHAR2,
   p_city          in  VARCHAR2,
   p_postal_code   in  VARCHAR2,
   p_county        IN  VARCHAR2,
   p_state         in  VARCHAR2,
   p_province      in  VARCHAR2,
   x_location_id   out nocopy NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS
     l_location_rec       hz_location_v2pub.location_rec_type;
BEGIN

   l_location_rec.country            := p_country_code;
   l_location_rec.address1           := p_address1;
   l_location_rec.address2           := p_address2;
   l_location_rec.address3           := p_address3;
   l_location_rec.address4           := p_address4;
   l_location_rec.city               := p_city;
   l_location_rec.postal_code        := p_postal_code;
   l_location_rec.state              := p_state;
   l_location_rec.province           := p_province;
   l_location_rec.created_by_module  := 'POS_SUPPLIER_MGMT';
   l_location_rec.application_id     := 177;
   l_location_rec.county             := p_county;

   hz_location_v2pub.create_location
     ( p_init_msg_list => fnd_api.g_true,
       p_location_rec  => l_location_rec,
       x_location_id   => x_location_id,
       x_return_status => x_return_status,
       x_msg_count     => x_msg_count,
       x_msg_data      => x_msg_data
       );

END pos_create_hz_location;

procedure pos_create_party_site
  (p_party_id          in  NUMBER,
   p_location_id       in  NUMBER,
   p_party_site_name   IN  VARCHAR2,
   x_party_site_id     out nocopy NUMBER,
   x_party_site_number out nocopy NUMBER,
   x_return_status     OUT nocopy VARCHAR2,
   x_msg_count         OUT nocopy NUMBER,
   x_msg_data          OUT nocopy VARCHAR2
   )
  IS
     l_party_site_rec hz_party_site_v2pub.party_site_rec_type ;

BEGIN

   l_party_site_rec.party_id          := p_party_id;
   l_party_site_rec.location_id       := p_location_id;
   l_party_site_rec.created_by_module :='POS_SUPPLIER_MGMT';
   l_party_site_rec.application_id    := 177;
   l_party_site_rec.party_site_name   := p_party_site_name;

   hz_party_site_v2pub.create_party_site
     ( p_init_msg_list       => FND_API.G_TRUE,
       p_party_site_rec      => l_party_site_rec,
       x_party_site_id       => x_party_site_id,
       x_party_site_number   => x_party_site_number,
       x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data
       );

END pos_create_party_site;

-- to be obsolete
procedure pos_create_hz_location
  (p_country_code  in  VARCHAR2,
   p_address1      in  VARCHAR2,
   p_address2      in  VARCHAR2,
   p_address3      in  VARCHAR2,
   p_address4      in  VARCHAR2,
   p_city          in  VARCHAR2,
   p_postal_code   in  VARCHAR2,
   p_county        IN  VARCHAR2,
   p_state         in  VARCHAR2,
   p_province      in  VARCHAR2,
   x_location_id   out nocopy NUMBER
   )
  IS
     l_return_status VARCHAR2(1);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);
BEGIN
   pos_create_hz_location
     (p_country_code  => p_country_code,
      p_address1      => p_address1    ,
      p_address2      => p_address2    ,
      p_address3      => p_address3    ,
      p_address4      => p_address4    ,
      p_city          => p_city        ,
      p_postal_code   => p_postal_code ,
      p_county        => p_county      ,
      p_state         => p_state       ,
      p_province      => p_province    ,
      x_location_id   => x_location_id ,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data
      );
   IF l_return_status IS NULL
     OR l_return_status <> fnd_api.g_ret_sts_success THEN
      raise_application_error(-20001, l_msg_data, TRUE);
   END IF;
END pos_create_hz_location;

-- to be obsolete
procedure pos_create_party_site
  (p_party_id          in  NUMBER,
   p_location_id       in  NUMBER,
   p_party_site_name   IN  VARCHAR2,
   x_party_site_id     out nocopy NUMBER,
   x_party_site_number out nocopy NUMBER
   )
  IS
     l_return_status VARCHAR2(1);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(2000);
BEGIN
   pos_create_party_site
     (p_party_id          => p_party_id,
      p_location_id       => p_location_id,
      p_party_site_name   => p_party_site_name,
      x_party_site_id     => x_party_site_id,
      x_party_site_number => x_party_site_number,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
      );
   IF l_return_status IS NULL
     OR l_return_status <> fnd_api.g_ret_sts_success THEN
      raise_application_error(-20001, l_msg_data, TRUE);
   END IF;
END pos_create_party_site;

END POS_HZ_UTIL_PKG;

/
