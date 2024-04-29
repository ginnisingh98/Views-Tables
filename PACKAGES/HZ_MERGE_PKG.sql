--------------------------------------------------------
--  DDL for Package HZ_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHMPKGS.pls 120.6 2005/07/29 16:46:28 vsegu noship $ */
PROCEDURE party_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN	NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE party_reln_object_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE party_reln_subject_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE party_relationship_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE org_profile_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE per_profile_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE org_contact_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE cust_account_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE cust_account_role_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE cust_account_site_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE contact_point_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE financial_profile_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE references_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE certification_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE credit_ratings_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE party_site_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE org_contact_merge2(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE contact_point_merge2(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE party_site_use_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE contact_preference_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT NOCOPY          VARCHAR2
);
PROCEDURE contact_preference_merge2(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT NOCOPY          VARCHAR2
);
PROCEDURE contact_preference_merge3(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT NOCOPY          VARCHAR2
);
PROCEDURE security_issued_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE financial_reports_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE org_indicators_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE org_ind_reference_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE per_interest_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE citizenship_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE education_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);

PROCEDURE education_school_merge(
        p_entity_name   	IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       	IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         	IN  OUT NOCOPY	NUMBER,
        p_from_fk_id    	IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      	IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name 	IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id		IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id 	IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status 	OUT NOCOPY      VARCHAR2
);

PROCEDURE emp_history_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);

PROCEDURE emp_history_employed_merge(
        p_entity_name   	IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       	IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         	IN OUT NOCOPY	NUMBER,
        p_from_fk_id    	IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      	IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name 	IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id		IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id	IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status 	OUT    NOCOPY   VARCHAR2
);

PROCEDURE per_languages_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE code_assignment_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE code_assignment_merge2(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE org_contact_role_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE financial_number_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE work_class_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE displayed_duns_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id 	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);
PROCEDURE cust_account_selling_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT NOCOPY          VARCHAR2
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

PROCEDURE party_usage_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
);


m_same_duns VARCHAR2(1) := 'N';
m_to_is_branch VARCHAR2(1) := 'N';
m_to_has_no_dnb VARCHAR2(1) := 'N';
END HZ_MERGE_PKG;

 

/
