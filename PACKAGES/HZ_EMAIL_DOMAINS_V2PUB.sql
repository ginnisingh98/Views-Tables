--------------------------------------------------------
--  DDL for Package HZ_EMAIL_DOMAINS_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EMAIL_DOMAINS_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2EMDS.pls 115.5 2003/10/31 20:36:47 rrangan noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * FUNCTION transpose_domain
 *
 * DESCRIPTION
 *     This API will accept an input domain, and return it with the segments
 *     transposed (reversed). The return value should be all-uppercase.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_domain_name                 Input domain
 *
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   21-APR-2003  Sreedhar Mohan     o Created.
 *
 */

FUNCTION transpose_domain(
   p_domain_name IN VARCHAR2
) RETURN VARCHAR2;

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_email_domain
 *
 * DESCRIPTION
 *     This API will insert a row into the HZ_EMAIL_DOMAINS table. It should
 *     internally call the function defined above (transpose_domain), and
 *     insert the transposed value as well.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_party_id                     Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_domain_name                  Financial report record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   21-APR-2003  Sreedhar Mohan     o Created.
 *
 */

PROCEDURE create_email_domain(
     p_party_id IN NUMBER,
     p_domain_name IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data  OUT NOCOPY VARCHAR2);

FUNCTION check_email_domain_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT  NOCOPY NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT  NOCOPY VARCHAR2)
RETURN VARCHAR2;

PROCEDURE email_domains_merge(
        p_entity_name     IN     VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id         IN     NUMBER:=FND_API.G_MISS_NUM,
        x_to_id           IN OUT NOCOPY	NUMBER,
        p_from_fk_id      IN     NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id        IN     NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN     VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	  IN	 NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id  IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status      OUT NOCOPY          VARCHAR2

);

PROCEDURE check_params(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_id         IN      NUMBER:=FND_API.G_MISS_NUM,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_proc_name       IN    VARCHAR2,
        p_exp_ent_name  IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_exp_par_ent_name IN   VARCHAR2:=FND_API.G_MISS_CHAR,
        p_pk_column     IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_par_pk_column IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        x_return_status IN OUT NOCOPY          VARCHAR2
);

FUNCTION get_email_domains(
    p_party_id	IN	NUMBER,
	p_entity	IN	VARCHAR2,
	p_attribute	IN	VARCHAR2,
    p_context       IN      VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION CORE_DOMAIN(
        p_input_str             IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2;

FUNCTION FULL_DOMAIN(
        p_input_str             IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2;



END HZ_EMAIL_DOMAINS_V2PUB;



 

/
