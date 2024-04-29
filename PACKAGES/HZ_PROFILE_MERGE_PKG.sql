--------------------------------------------------------
--  DDL for Package HZ_PROFILE_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PROFILE_MERGE_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHMPROS.pls 120.1 2005/06/16 21:12:41 jhuang noship $ */

   PROCEDURE profile_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT	NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT     NOCOPY VARCHAR2);

END;

 

/
