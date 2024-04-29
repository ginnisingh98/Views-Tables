--------------------------------------------------------
--  DDL for Package Body OPI_DBI_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_PARTY_MERGE_PKG" AS
/* $Header: OPIDEHZMGB.pls 115.0 2004/03/17 00:36:25 rjin noship $ */


PROCEDURE OPI_DBI_COGS_F_M (
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

	 update opi_dbi_cogs_f
	    set customer_id = p_to_fk_id
	  where	customer_id = p_from_fk_id;

   END IF;

   EXCEPTION
     WHEN others THEN
       x_return_status :=  FND_API.G_RET_STS_ERROR;

END OPI_DBI_COGS_F_M;


END  OPI_DBI_PARTY_MERGE_PKG;

/
