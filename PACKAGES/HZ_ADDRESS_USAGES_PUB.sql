--------------------------------------------------------
--  DDL for Package HZ_ADDRESS_USAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ADDRESS_USAGES_PUB" AUTHID CURRENT_USER AS
/* $Header: ARHGNRSS.pls 120.1 2005/08/25 00:15:06 baianand noship $ */

TYPE address_usages_rec_type IS RECORD (
    map_id                                  NUMBER,
    usage_code                              VARCHAR2(30),
    status_flag                             VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE address_usage_dtls_rec_type IS RECORD (
    geography_type                          VARCHAR2(30),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE address_usage_dtls_tbl_type IS TABLE of address_usage_dtls_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE create_address_usages
  (p_address_usages_rec      IN              address_usages_rec_type,
   p_address_usage_dtls_tbl  IN              address_usage_dtls_tbl_type,
   p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
   x_usage_id                OUT    NOCOPY   NUMBER,
   x_return_status           OUT    NOCOPY   VARCHAR2,
   x_msg_count               OUT    NOCOPY   NUMBER,
   x_msg_data                OUT    NOCOPY   VARCHAR2
  );
PROCEDURE update_address_usages
  (p_usage_id              IN             NUMBER,
   p_map_id                IN             NUMBER,
   p_usage_code            IN             VARCHAR2,
   p_status_flag           IN             VARCHAR2,
   p_init_msg_list         IN             VARCHAR2 := FND_API.G_FALSE,
   x_object_version_number IN OUT NOCOPY  NUMBER,
   x_return_status         OUT    NOCOPY  VARCHAR2,
   x_msg_count             OUT    NOCOPY  NUMBER,
   x_msg_data              OUT    NOCOPY  VARCHAR2
  );
PROCEDURE create_address_usage_dtls
  (p_usage_id                IN              NUMBER,
   p_address_usage_dtls_tbl  IN              address_usage_dtls_tbl_type,
   x_usage_dtl_id            OUT  NOCOPY     NUMBER,
   p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
   x_return_status           OUT    NOCOPY   VARCHAR2,
   x_msg_count               OUT    NOCOPY   NUMBER,
   x_msg_data                OUT    NOCOPY   VARCHAR2
  );
PROCEDURE delete_address_usages(
    p_usage_id               IN              NUMBER,
    p_address_usage_dtls_tbl IN              address_usage_dtls_tbl_type,
    p_init_msg_list          IN              VARCHAR2 := FND_API.G_FALSE,
    x_return_status          OUT    NOCOPY   VARCHAR2,
    x_msg_count              OUT    NOCOPY   NUMBER,
    x_msg_data               OUT    NOCOPY   VARCHAR2);

END HZ_ADDRESS_USAGES_PUB;

 

/
