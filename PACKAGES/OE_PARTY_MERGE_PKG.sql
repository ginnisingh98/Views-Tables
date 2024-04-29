--------------------------------------------------------
--  DDL for Package OE_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/*$Header: OEXPMRGS.pls 120.0 2005/05/31 23:36:05 appldev noship $ */
PROCEDURE MERGE_ADJ_ATTRIBS_PARTY(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_parent_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN	NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT  NOCOPY VARCHAR2
);

PROCEDURE MERGE_ADJ_ATTRIBS_PARTY_SITE(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         OUT  NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_parent_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN	NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT  NOCOPY VARCHAR2
);

END OE_PARTY_MERGE_PKG;

 

/
