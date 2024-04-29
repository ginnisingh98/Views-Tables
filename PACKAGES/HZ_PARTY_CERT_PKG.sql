--------------------------------------------------------
--  DDL for Package HZ_PARTY_CERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_CERT_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHCERTS.pls 120.5 2005/10/30 04:17:46 appldev noship $ */

-- AUTHOR : CVIJAYAN ("VJN")

--------------------------------------
--------------------------------------
-- declaration of procedures
--------------------------------------
--------------------------------------


-------------------------------------
-- SET_CERTIFICATION_STATUS - Signature
-------------------------------------
PROCEDURE set_certification_level (
-- input parameters
  p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_party_id         	IN  number,
  p_cert_level         IN  VARCHAR2,
  p_cert_reason_code         IN  VARCHAR2,
-- in/out parameters
  x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
);

PROCEDURE set_party_attributes (
-- input parameters
  p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_party_id         	IN  number,
  p_status         IN  VARCHAR2,
  p_internal_flag       IN  VARCHAR2,
-- in/out parameters
  x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
);



END HZ_PARTY_CERT_PKG ;



 

/
