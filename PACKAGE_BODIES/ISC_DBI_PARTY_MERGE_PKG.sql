--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PARTY_MERGE_PKG" AS
/* $Header: ISCHZMGB.pls 115.1 2004/02/24 18:44:27 scheung noship $ */


PROCEDURE ISC_BOOK_SUM2_F_M (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT merge_reason_code
     INTO   l_merge_reason_code
     FROM   hz_merge_batch
    WHERE  batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
      NULL;
   ELSE
      NULL;
   END IF;

   IF p_from_fk_id = p_to_fk_id THEN
      x_to_id := p_from_id;
      RETURN;
   END IF;

   IF p_from_fk_id <> p_to_fk_id THEN

	 update isc_book_sum2_f
	    set customer_id = p_to_fk_id
	  where	customer_id = p_from_fk_id;

	 update isc_book_sum2_f
	    set ship_to_party_id = p_to_fk_id
	  where	ship_to_party_id = p_from_fk_id;

   END IF;

   EXCEPTION
     WHEN others THEN
       x_return_status :=  FND_API.G_RET_STS_ERROR;

END ISC_BOOK_SUM2_F_M;

PROCEDURE ISC_BOOK_SUM2_PDUE_F_M (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT merge_reason_code
     INTO   l_merge_reason_code
     FROM   hz_merge_batch
    WHERE  batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
      NULL;
   ELSE
      NULL;
   END IF;

   IF p_from_fk_id = p_to_fk_id THEN
      x_to_id := p_from_id;
      RETURN;
   END IF;

   IF p_from_fk_id <> p_to_fk_id THEN

	 update isc_book_sum2_pdue_f
	    set customer_id = p_to_fk_id
	  where	customer_id = p_from_fk_id;

   END IF;

   EXCEPTION
     WHEN others THEN
       x_return_status :=  FND_API.G_RET_STS_ERROR;

END ISC_BOOK_SUM2_PDUE_F_M;

PROCEDURE ISC_BOOK_SUM2_PDUE2_F_M (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT merge_reason_code
     INTO   l_merge_reason_code
     FROM   hz_merge_batch
    WHERE  batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
      NULL;
   ELSE
      NULL;
   END IF;

   IF p_from_fk_id = p_to_fk_id THEN
      x_to_id := p_from_id;
      RETURN;
   END IF;

   IF p_from_fk_id <> p_to_fk_id THEN

	 update isc_book_sum2_pdue2_f
	    set customer_id = p_to_fk_id
	  where	customer_id = p_from_fk_id;

   END IF;

   EXCEPTION
     WHEN others THEN
       x_return_status :=  FND_API.G_RET_STS_ERROR;

END ISC_BOOK_SUM2_PDUE2_F_M;

PROCEDURE ISC_BOOK_SUM2_BKORD_F_M (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   SELECT merge_reason_code
     INTO   l_merge_reason_code
     FROM   hz_merge_batch
    WHERE  batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
      NULL;
   ELSE
      NULL;
   END IF;

   IF p_from_fk_id = p_to_fk_id THEN
      x_to_id := p_from_id;
      RETURN;
   END IF;

   IF p_from_fk_id <> p_to_fk_id THEN

	 update isc_book_sum2_bkord_f
	    set customer_id = p_to_fk_id
	  where	customer_id = p_from_fk_id;

   END IF;

   EXCEPTION
     WHEN others THEN
       x_return_status :=  FND_API.G_RET_STS_ERROR;

END ISC_BOOK_SUM2_BKORD_F_M;


END  ISC_DBI_PARTY_MERGE_PKG;

/
