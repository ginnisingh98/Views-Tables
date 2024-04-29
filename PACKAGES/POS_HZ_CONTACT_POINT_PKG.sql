--------------------------------------------------------
--  DDL for Package POS_HZ_CONTACT_POINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_HZ_CONTACT_POINT_PKG" AUTHID CURRENT_USER AS
/*$Header: POSHZCPS.pls 120.1.12010000.2 2011/05/11 13:16:33 ramkandu ship $ */

-- update if exists, create otherwise
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
  );

-- update if exists, create otherwise
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
  );

-- update if exists, create otherwise
PROCEDURE update_party_email
  ( p_party_id          IN  NUMBER
  , p_email             IN  VARCHAR2
--Start Bug 6620664
  , p_email_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM
--End Bug 6620664
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

-- update if exists, create otherwise
PROCEDURE update_party_site_phone
  ( p_party_site_id     IN  NUMBER
  , p_country_code      IN  VARCHAR2
  , p_area_code         IN  VARCHAR2
  , p_number            IN  VARCHAR2
  , p_extension         IN  VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

-- update if exists, create otherwise
PROCEDURE update_party_site_fax
  ( p_party_site_id     IN  NUMBER
  , p_country_code      IN  VARCHAR2
  , p_area_code         IN  VARCHAR2
  , p_number            IN  VARCHAR2
  , p_extension         IN  VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

-- update if exists, create otherwise
PROCEDURE update_party_site_email
  ( p_party_site_id     IN  NUMBER
  , p_email             IN  VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

/*Added methods update_party_alt_phone, update_party_url
  for Bug 9316284*/
-- update if exists, create otherwise
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
  );

-- update if exists, create otherwise
PROCEDURE update_party_url
  ( p_party_id          IN  NUMBER
  , p_url               IN  VARCHAR2
  , p_url_object_version_number   IN  NUMBER DEFAULT fnd_api.G_NULL_NUM
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT nocopy VARCHAR2
  , x_msg_data          OUT NOCOPY VARCHAR2
  );
END pos_hz_contact_point_pkg;

/
