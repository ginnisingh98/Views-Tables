--------------------------------------------------------
--  DDL for Package POS_HZ_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_HZ_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: POSHZUTS.pls 120.2 2005/07/20 16:25:24 bitang noship $ */

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
   );

procedure pos_create_party_site
  (p_party_id          in  NUMBER,
   p_location_id       in  NUMBER,
   p_party_site_name   IN  VARCHAR2,
   x_party_site_id     out nocopy NUMBER,
   x_party_site_number out nocopy NUMBER,
   x_return_status     OUT nocopy VARCHAR2,
   x_msg_count         OUT nocopy NUMBER,
   x_msg_data          OUT nocopy VARCHAR2
   );

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
   );

-- to be obsolete
procedure pos_create_party_site
  (p_party_id          in  NUMBER,
   p_location_id       in  NUMBER,
   p_party_site_name   IN  VARCHAR2,
   x_party_site_id     out nocopy NUMBER,
   x_party_site_number out nocopy NUMBER
   );
END POS_HZ_UTIL_PKG;

 

/
