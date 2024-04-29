--------------------------------------------------------
--  DDL for Package PO_R12_CAT_UPG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_R12_CAT_UPG_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_R12_CAT_UPG_GRP.pls 120.1 2006/01/30 23:17:13 pthapliy noship $ */

PROCEDURE upgrade_existing_docs
(
   p_api_version      IN NUMBER
,  p_commit           IN VARCHAR2 default FND_API.G_FALSE
,  p_init_msg_list    IN VARCHAR2 default FND_API.G_FALSE
,  p_validation_level IN NUMBER default FND_API.G_VALID_LEVEL_FULL
,  p_log_level        IN NUMBER default 1
,  p_batch_size       IN NUMBER default 2500
,  x_return_status    OUT NOCOPY VARCHAR2
,  x_msg_count        OUT NOCOPY NUMBER
,  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE migrate_catalog
(
   p_api_version        IN NUMBER
,  p_commit             IN VARCHAR2 default FND_API.G_FALSE
,  p_init_msg_list      IN VARCHAR2 default FND_API.G_FALSE
,  p_validation_level   IN NUMBER default FND_API.G_VALID_LEVEL_FULL
,  p_log_level          IN NUMBER default 1
,  p_batch_id           IN NUMBER
,  p_batch_size         IN NUMBER default 2500
,  p_validate_only_mode IN VARCHAR2 default FND_API.G_FALSE
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
);

END PO_R12_CAT_UPG_GRP;

 

/
