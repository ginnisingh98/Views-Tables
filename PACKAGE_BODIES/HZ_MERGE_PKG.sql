--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_PKG" AS
/*$Header: ARHMPKGB.pls 120.61.12010000.2 2008/10/27 06:45:18 vsegu ship $ */
--4307667
PROCEDURE do_party_usage_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2

);

PROCEDURE do_party_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN	NUMBER,
        x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_party_site_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id    	IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY  	VARCHAR2
);

PROCEDURE do_cust_account_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_cust_account_role_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_cust_account_site_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_fin_profile_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_contact_point_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_contact_point_transfer2(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_contact_pref_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_references_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_certification_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_credit_ratings_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_security_issued_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_financial_reports_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_org_indicators_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_ind_reference_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_per_interest_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_citizenship_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_education_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_education_school_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_emp_history_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_employed_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_work_class_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_financial_number_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_org_contact_role_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_code_assignment_transfer2(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_code_assignment_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_per_languages_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_party_site_use_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_org_contact_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_org_contact_transfer2(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_party_reln_subj_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2

);

PROCEDURE do_party_reln_obj_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2

);

PROCEDURE do_party_relationship_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
);
PROCEDURE do_hierarchy_nodes_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2,
	p_action	IN	VARCHAR2,
	p_sub_obj_merge IN	VARCHAR2:=FND_API.G_MISS_CHAR
);

PROCEDURE do_org_profile_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_per_profile_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
);

PROCEDURE do_displayed_duns_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
);
/*
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
*/

PROCEDURE insert_request_log(
        p_source_party_id       IN      NUMBER,
        p_destination_party_id  IN      NUMBER
);

----BugNo:1695595.Added private procedure to update denormalized columns in hz_parties.

PROCEDURE do_denormalize_contact_point (
    p_party_id                         IN     NUMBER,
    p_contact_point_type               IN     VARCHAR2,
    p_url                              IN     VARCHAR2,
    p_email_address		       IN     VARCHAR2,
    p_phone_contact_pt_id	       IN     NUMBER,
    p_phone_purpose		       IN     VARCHAR2,
    p_phone_line_type		       IN     VARCHAR2,
    p_phone_country_code	       IN     VARCHAR2,
    p_phone_area_code		       IN     VARCHAR2,
    p_phone_number		       IN     VARCHAR2,
    p_phone_extension		       IN     VARCHAR2
);




/*===========================================================================+
 | PROCEDURE                                                                 |
 |              party_merge                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Merges the parties with party_ids p_from_id to the party x_to_id        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		  p_entity_name                                              |
 |		  p_from_id                                                  |
 |		  p_from_fk_id                                               |
 |		  p_to_fk_id                                                 |
 |		  p_merge_operation                                          |
 |		  p_par_entity_name                                          |
 |              OUT:                                                         |
 |		  x_return_status                                            |
 |          IN/ OUT:                                                         |
 |		  x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Srinivasa Rangan   21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE party_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN	NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS

l_to_id 	NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.party_merge',
                'HZ_PARTIES',NULL,
                'PARTY_ID',NULL,x_return_status);

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
      do_party_merge(p_from_id, l_to_id,p_from_fk_id, p_to_fk_id,
           p_batch_party_id, x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END party_merge;

PROCEDURE org_profile_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS

l_to_id 	NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.org_profile_merge',
                'HZ_ORGANIZATION_PROFILES','HZ_PARTIES',
                'ORGANIZATION_PROFILE_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
      do_org_profile_merge(p_from_id, l_to_id,p_from_fk_id, p_to_fk_id,
                           x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END org_profile_merge;

PROCEDURE party_relationship_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS

l_to_id 	NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.party_relationship_merge',
                'HZ_PARTY_RELATIONSHIPS','HZ_PARTIES',
                'PARTY_RELATIONSHIP_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
      do_party_relationship_merge(p_from_id, l_to_id,p_from_fk_id,p_to_fk_id,
                                  x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END party_relationship_merge;

PROCEDURE per_profile_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS

l_to_id 	NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.per_profile_merge',
                'HZ_PERSON_PROFILES','HZ_PARTIES',
                'PERSON_PROFILE_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
      do_per_profile_merge(p_from_id, l_to_id,p_from_fk_id,p_to_fk_id,
                           x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END per_profile_merge;

--4307667
PROCEDURE party_usage_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id         NUMBER;
l_dummy_id NUMBER;

BEGIN

   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.party_usage_merge',
                'HZ_PARTY_USG_ASSIGNMENTS','HZ_PARTIES',
                'PARTY_USG_ASSIGNMENT_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
     do_party_usage_merge(p_from_id,l_to_id, p_from_fk_id,
                  p_to_fk_id, x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN  OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END party_usage_merge;


PROCEDURE party_reln_subject_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id         NUMBER;
l_dummy_id NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.party_reln_subject_merge',
                'HZ_PARTY_RELATIONSHIPS','HZ_PARTIES',
                'PARTY_RELATIONSHIP_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
     do_party_reln_subj_merge(p_from_id,l_to_id, p_from_fk_id,
                  p_to_fk_id, x_return_status);
   END IF;

   IF (l_to_id IS NULL OR l_to_id = FND_API.G_MISS_NUM OR
           l_to_id = p_from_id) THEN
     FOR ORG_CT IN (
       SELECT oc.ORG_CONTACT_ID
       FROM HZ_ORG_CONTACTS oc, HZ_STAGED_CONTACTS soc
       WHERE oc.PARTY_RELATIONSHIP_ID = p_from_id
       AND SOC.ORG_CONTACT_ID=oc.ORG_CONTACT_ID) LOOP
      HZ_DQM_SYNC.stage_contact_merge(
        'HZ_STAGED_CONTACTS',
        ORG_CT.ORG_CONTACT_ID,l_dummy_id,
        ORG_CT.ORG_CONTACT_ID,ORG_CT.ORG_CONTACT_ID,
        'HZ_ORG_CONTACTS',
        p_batch_id,p_batch_party_id,x_return_status);
     END LOOP;
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END party_reln_subject_merge;

PROCEDURE party_reln_object_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS

l_to_id         NUMBER;
l_dummy_id NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.party_reln_object_merge',
                'HZ_PARTY_RELATIONSHIPS','HZ_PARTIES',
                'PARTY_RELATIONSHIP_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
     do_party_reln_obj_merge(p_from_id,l_to_id, p_from_fk_id,
                  p_to_fk_id, x_return_status);
   END IF;

   IF (l_to_id IS NULL OR l_to_id = FND_API.G_MISS_NUM OR
           l_to_id = p_from_id) THEN
     FOR ORG_CT IN (
       SELECT oc.ORG_CONTACT_ID
       FROM HZ_ORG_CONTACTS oc, HZ_STAGED_CONTACTS soc
       WHERE oc.PARTY_RELATIONSHIP_ID = p_from_id
       AND SOC.ORG_CONTACT_ID=oc.ORG_CONTACT_ID) LOOP
      HZ_DQM_SYNC.stage_contact_merge(
        'HZ_STAGED_CONTACTS',
        ORG_CT.ORG_CONTACT_ID,l_dummy_id,
        ORG_CT.ORG_CONTACT_ID,ORG_CT.ORG_CONTACT_ID,
        'HZ_ORG_CONTACTS',
        p_batch_id,p_batch_party_id,x_return_status);
     END LOOP;
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END party_reln_object_merge;

PROCEDURE org_contact_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.org_contact_merge',
                'HZ_ORG_CONTACTS','HZ_PARTY_SITES',
                'ORG_CONTACT_ID', 'PARTY_SITE_ID',x_return_status);

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
     do_org_contact_transfer(p_from_id,l_to_id, p_from_fk_id,
                  p_to_fk_id, x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END org_contact_merge;

PROCEDURE org_contact_merge2(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id NUMBER;
l_dummy_id NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.org_contact_merge2',
                'HZ_ORG_CONTACTS','HZ_PARTY_RELATIONSHIPS',
                'ORG_CONTACT_ID', 'PARTY_RELATIONSHIP_ID',x_return_status);

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
     do_org_contact_transfer2(p_from_id,l_to_id, p_from_fk_id,
                  p_to_fk_id, x_return_status);
   END IF;

   IF (l_to_id IS NULL OR l_to_id = FND_API.G_MISS_NUM OR
           l_to_id = p_from_id) THEN
     FOR ORG_CT IN (
       SELECT soc.ORG_CONTACT_ID
       FROM HZ_STAGED_CONTACTS soc
       WHERE SOC.ORG_CONTACT_ID= p_from_id) LOOP
      HZ_DQM_SYNC.stage_contact_merge(
        'HZ_STAGED_CONTACTS',
        ORG_CT.ORG_CONTACT_ID,l_dummy_id,
        ORG_CT.ORG_CONTACT_ID,ORG_CT.ORG_CONTACT_ID,
        'HZ_ORG_CONTACTS',
        p_batch_id,p_batch_party_id,x_return_status);
     END LOOP;
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END org_contact_merge2;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              party_site_merge                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Merges the party_sites with party_site_ids p_from_id to the party site  |
 |   x_to_id                                                                 |
 |                                                                           |
 |   The merge operations allowed are MERGE and COPY                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		  p_entity_name                                              |
 |		  p_from_id                                                  |
 |		  p_from_fk_id                                               |
 |		  p_to_fk_id                                                 |
 |		  p_merge_operation                                          |
 |		  p_par_entity_name                                          |
 |              OUT:                                                         |
 |		  x_return_status                                            |
 |          IN/ OUT:                                                         |
 |		  x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Srinivasa Rangan   21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE party_site_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_from_fk_id <> FND_API.G_MISS_NUM THEN
     check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.party_site_merge',
                'HZ_PARTY_SITES','HZ_PARTIES',
                'PARTY_SITE_ID', 'PARTY_ID',x_return_status);
   ELSE
     check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.party_site_merge',
                'HZ_PARTY_SITES',NULL, 'PARTY_SITE_ID',
                NULL,x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
     do_party_site_merge(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         p_batch_id,x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END party_site_merge;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              cust_account_merge                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		  p_entity_name                                              |
 |		  p_from_id                                                  |
 |		  p_from_fk_id                                               |
 |		  p_to_fk_id                                                 |
 |		  p_merge_operation                                          |
 |		  p_par_entity_name                                          |
 |              OUT:                                                         |
 |		  x_return_status                                            |
 |          IN/ OUT:                                                         |
 |		  x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Srinivasa Rangan   21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE cust_account_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.cust_account_merge',
                'HZ_CUST_ACCOUNTS','HZ_PARTIES',
                'CUST_ACCOUNT_ID', 'PARTY_ID',x_return_status);
   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_cust_account_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
     do_cust_account_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                       x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END cust_account_merge;

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
) IS
l_to_id         NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.cust_account_merge',
                'HZ_CUST_ACCOUNTS','HZ_PARTIES',
                'CUST_ACCOUNT_ID', 'SELLING_PARTY_ID',x_return_status);

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
      UPDATE HZ_CUST_ACCOUNTS
      SET
        selling_party_id = p_to_fk_id,
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        request_id =  hz_utility_pub.request_id,
        program_application_id = hz_utility_pub.program_application_id,
        program_id = hz_utility_pub.program_id,
        program_update_date = sysdate
      WHERE cust_account_id = p_from_id;
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END cust_account_selling_merge;

PROCEDURE cust_account_role_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.cust_account_role_merge',
                'HZ_CUST_ACCOUNT_ROLES','HZ_PARTIES',
                'CUST_ACCOUNT_ROLE_ID', 'PARTY_ID',x_return_status);
   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_cust_account_role_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;
   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
     do_cust_account_role_transfer(p_from_id, l_to_id, p_from_fk_id,
                         p_to_fk_id, x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END cust_account_role_merge;

PROCEDURE cust_account_site_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.cust_account_site_merge',
                'HZ_CUST_ACCT_SITES_ALL','HZ_PARTY_SITES',
                'CUST_ACCT_SITE_ID', 'PARTY_SITE_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_cust_account_site_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
       do_cust_account_site_transfer(p_from_id,l_to_id, p_from_fk_id,
                         p_to_fk_id, x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END cust_account_site_merge;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              financial_profile_merge                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		  p_entity_name                                              |
 |		  p_from_id                                                  |
 |		  p_from_fk_id                                               |
 |		  p_to_fk_id                                                 |
 |		  p_merge_operation                                          |
 |		  p_par_entity_name                                          |
 |              OUT:                                                         |
 |		  x_return_status                                            |
 |          IN/ OUT:                                                         |
 |		  x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Srinivasa Rangan   21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE financial_profile_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.financial_profile_merge',
                'HZ_FINANCIAL_PROFILE','HZ_PARTIES',
                'FINANCIAL_PROFILE_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_financial_profile_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_fin_profile_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END financial_profile_merge;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              contact_point_merge                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		  p_entity_name                                              |
 |		  p_from_id                                                  |
 |		  p_from_fk_id                                               |
 |		  p_to_fk_id                                                 |
 |		  p_merge_operation                                          |
 |		  p_par_entity_name                                          |
 |              OUT:                                                         |
 |		  x_return_status                                            |
 |          IN/ OUT:                                                         |
 |		  x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Srinivasa Rangan   21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE contact_point_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);
l_dummy_id NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.contact_point_merge',
                'HZ_CONTACT_POINTS','HZ_PARTIES',
                'CONTACT_POINT_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_contact_point_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        'HZ_PARTIES',x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_contact_point_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   IF (l_to_id IS NULL OR l_to_id = FND_API.G_MISS_NUM OR
           l_to_id = p_from_id) THEN
     FOR CPT IN (
      SELECT CONTACT_POINT_ID FROM HZ_STAGED_CONTACT_POINTS
      WHERE CONTACT_POINT_ID=p_from_id) LOOP

        HZ_DQM_SYNC.stage_contact_point_merge(
          'HZ_STAGED_CONTACT_POINTS',
          p_from_id,l_dummy_id,p_from_id,p_from_id,
          'HZ_CONTACT_POINTS',
          p_batch_id,p_batch_party_id,x_return_status);
     END LOOP;
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END contact_point_merge;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              references_merge                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Merges the parties with party_ids p_from_id to the party x_to_id        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		  p_entity_name                                              |
 |		  p_from_id                                                  |
 |		  p_from_fk_id                                               |
 |		  p_to_fk_id                                                 |
 |		  p_merge_operation                                          |
 |		  p_par_entity_name                                          |
 |              OUT:                                                         |
 |		  x_return_status                                            |
 |          IN/ OUT:                                                         |
 |		  x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Srinivasa Rangan   21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE references_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.references_merge',
                'HZ_REFERENCES','HZ_PARTIES',
                'REFERENCE_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_references_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_references_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END references_merge;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              certification_merge                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Merges the parties with party_ids p_from_id to the party x_to_id        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		  p_entity_name                                              |
 |		  p_from_id                                                  |
 |		  p_from_fk_id                                               |
 |		  p_to_fk_id                                                 |
 |		  p_merge_operation                                          |
 |		  p_par_entity_name                                          |
 |              OUT:                                                         |
 |		  x_return_status                                            |
 |          IN/ OUT:                                                         |
 |		  x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Srinivasa Rangan   21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE certification_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.certification_merge',
                'HZ_CERTIFICATIONS','HZ_PARTIES',
                'CERTIFICATION_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_certification_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_certification_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END certification_merge;

PROCEDURE credit_ratings_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.credit_ratings_merge',
                'HZ_CREDIT_RATINGS','HZ_PARTIES',
                'CREDIT_RATING_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_credit_ratings_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_credit_ratings_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END credit_ratings_merge;


PROCEDURE security_issued_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.security_issued_merge',
                'HZ_SECURITY_ISSUED','HZ_PARTIES',
                'SECURITY_ISSUED_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN

     l_dup_exists := HZ_MERGE_DUP_CHECK.check_security_issued_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_security_issued_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END security_issued_merge;

PROCEDURE financial_reports_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.financial_reports_merge',
                'HZ_FINANCIAL_REPORTS','HZ_PARTIES',
                'FINANCIAL_REPORT_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_financial_reports_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_financial_reports_transfer(p_from_id, l_to_id, p_from_fk_id,
                         p_to_fk_id,x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END financial_reports_merge;


PROCEDURE org_indicators_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.org_indicators_merge',
                'HZ_ORGANIZATION_INDICATORS','HZ_PARTIES',
                'ORGANIZATION_INDICATOR_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_org_indicators_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_org_indicators_transfer(p_from_id, l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END org_indicators_merge;

PROCEDURE org_ind_reference_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.org_ind_reference_merge',
                'HZ_INDUSTRIAL_REFERENCE','HZ_PARTIES',
                'INDUSTRY_REFERENCE_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_ind_reference_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_ind_reference_transfer(p_from_id, l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END org_ind_reference_merge;


PROCEDURE per_interest_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.per_interest_merge',
                'HZ_PERSON_INTEREST','HZ_PARTIES',
                'PERSON_INTEREST_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_per_interest_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_per_interest_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END per_interest_merge;

PROCEDURE citizenship_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.citizenship_merge',
                'HZ_CITIZENSHIP','HZ_PARTIES',
                'CITIZENSHIP_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_citizenship_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_citizenship_transfer(p_from_id,l_to_id,p_from_fk_id, p_to_fk_id,
                           x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END citizenship_merge;

PROCEDURE education_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.education_merge',
                'HZ_EDUCATION','HZ_PARTIES',
                'EDUCATION_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_education_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
       do_education_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END education_merge;

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
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.education_school_merge',
                'HZ_EDUCATION','HZ_PARTIES',
                'EDUCATION_ID', 'SCHOOL_PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_education_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_education_school_transfer(p_from_id,l_to_id,p_from_fk_id, p_to_fk_id,
                           x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END education_school_merge;

PROCEDURE emp_history_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.emp_history_merge',
                'HZ_EMPLOYMENT_HISTORY','HZ_PARTIES',
                'EMPLOYMENT_HISTORY_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_emp_history_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_emp_history_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END emp_history_merge;

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
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.emp_history_employed_merge',
                'HZ_EMPLOYMENT_HISTORY','HZ_PARTIES',
                'EMPLOYMENT_HISTORY_ID','EMPLOYED_BY_PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_emp_history_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_employed_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END emp_history_employed_merge;

PROCEDURE work_class_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.work_class_merge',
                'HZ_WORK_CLASS', 'HZ_EMPLOYMENT_HISTORY',
                'WORK_CLASS_ID', 'EMPLOYMENT_HISTORY_ID', x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_work_class_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_work_class_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END work_class_merge;

PROCEDURE code_assignment_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id         NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.code_assignment_merge',
                'HZ_CODE_ASSIGNMENTS','HZ_PARTIES',
                'CODE_ASSIGNMENT_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_code_assignment_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        'HZ_PARTIES', x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_code_assignment_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END code_assignment_merge;

PROCEDURE code_assignment_merge2(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id         NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.code_assignment_merge',
                'HZ_CODE_ASSIGNMENTS','HZ_PARTY_SITES',
                'CODE_ASSIGNMENT_ID', 'PARTY_SITE_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_code_assignment_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        'HZ_PARTY_SITES', x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_code_assignment_transfer2(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END code_assignment_merge2;

PROCEDURE org_contact_role_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.org_contact_role_merge',
                'HZ_ORG_CONTACT_ROLES','HZ_ORG_CONTACTS',
                'ORG_CONTACT_ROLE_ID', 'ORG_CONTACT_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_org_contact_role_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_org_contact_role_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END org_contact_role_merge;

PROCEDURE financial_number_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id         NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.financial_number_merge',
                'HZ_FINANCIAL_NUMBERS','HZ_FINANCIAL_REPORTS',
                'FINANCIAL_NUMBER_ID', 'FINANCIAL_REPORT_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_financial_number_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_financial_number_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END financial_number_merge;

PROCEDURE per_languages_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.per_languages_merge',
                'HZ_PERSON_LANGUAGE','HZ_PARTIES',
                'LANGUAGE_USE_REFERENCE_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_languages_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_per_languages_transfer(p_from_id, l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END per_languages_merge;

PROCEDURE party_site_use_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.party_site_use_merge',
                'HZ_PARTY_SITE_USES','HZ_PARTY_SITES',
                'PARTY_SITE_USE_ID', 'PARTY_SITE_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_party_site_use_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_party_site_use_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END party_site_use_merge;

PROCEDURE contact_point_merge2(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT NOCOPY          VARCHAR2
) IS
l_to_id 	NUMBER;
l_dup_exists    VARCHAR2(20);
l_dummy_id NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.contact_point_merge2',
                'HZ_CONTACT_POINTS','HZ_PARTY_SITES',
                'CONTACT_POINT_ID', 'PARTY_SITE_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_contact_point_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        'HZ_PARTY_SITES', x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
        do_contact_point_transfer2(p_from_id, l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   IF (l_to_id IS NULL OR l_to_id = FND_API.G_MISS_NUM OR
           l_to_id = p_from_id) THEN
     FOR CPT IN (
      SELECT CONTACT_POINT_ID FROM HZ_STAGED_CONTACT_POINTS
      WHERE CONTACT_POINT_ID=p_from_id) LOOP

        HZ_DQM_SYNC.stage_contact_point_merge(
          'HZ_STAGED_CONTACT_POINTS',
          p_from_id,l_dummy_id,p_from_id,p_from_id,
          'HZ_CONTACT_POINTS',
          p_batch_id,p_batch_party_id,x_return_status);
     END LOOP;
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END contact_point_merge2;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              contact_preference_merge                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_entity_name                                              |
 |                p_from_id                                                  |
 |                p_from_fk_id                                               |
 |                p_to_fk_id                                                 |
 |                p_merge_operation                                          |
 |                p_par_entity_name                                          |
 |              OUT:                                                         |
 |                x_return_status                                            |
 |          IN/ OUT:                                                         |
 |                x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Kate Shan          21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
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
) IS
l_to_id         NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.contact_preference_merge',
                'HZ_CONTACT_PREFERENCES','HZ_PARTIES',
                'CONTACT_PREFERENCE_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_contact_preference_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        'HZ_PARTIES',x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
       do_contact_pref_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END contact_preference_merge;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              contact_preference_merge2                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_entity_name                                              |
 |                p_from_id                                                  |
 |                p_from_fk_id                                               |
 |                p_to_fk_id                                                 |
 |                p_merge_operation                                          |
 |                p_par_entity_name                                          |
 |              OUT:                                                         |
 |                x_return_status                                            |
 |          IN/ OUT:                                                         |
 |                x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Kate               21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
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
) IS
l_to_id         NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.contact_preference_merge2',
                'HZ_CONTACT_PREFERENCES','HZ_PARTY_SITES',
                'CONTACT_PREFERENCE_ID', 'PARTY_SITE_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_contact_preference_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        'HZ_PARTY_SITES',x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
       do_contact_pref_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END contact_preference_merge2;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              contact_preference_merge3                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_entity_name                                              |
 |                p_from_id                                                  |
 |                p_from_fk_id                                               |
 |                p_to_fk_id                                                 |
 |                p_merge_operation                                          |
 |                p_par_entity_name                                          |
 |              OUT:                                                         |
 |                x_return_status                                            |
 |          IN/ OUT:                                                         |
 |                x_to_id                                                    |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Kate Shan          21-Aug-00  Created                                  |
 |                                                                           |
 +===========================================================================*/
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
) IS
l_to_id         NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.contact_preference_merge3',
                'HZ_CONTACT_PREFERENCES','HZ_CONTACT_POINTS',
                'CONTACT_PREFERENCE_ID', 'CONTACT_POINT_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_MERGE_DUP_CHECK.check_contact_preference_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        'HZ_CONTACT_POINTS',x_return_status);
   END IF;

   IF (x_return_status =FND_API.G_RET_STS_SUCCESS) THEN
       do_contact_pref_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   END IF;

   x_to_id := l_to_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END contact_preference_merge3;


PROCEDURE displayed_duns_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
        x_return_status   OUT NOCOPY  VARCHAR2
) IS

l_to_id         NUMBER;

BEGIN
   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, p_from_fk_id,
                p_to_fk_id, p_par_entity_name,
                'HZ_MERGE_PKG.displayed_duns_merge',
                'HZ_ORGANIZATION_PROFILES','HZ_PARTIES',
                'ORGANIZATION_PROFILE_ID', 'PARTY_ID',x_return_status);

   do_displayed_duns_merge(p_from_id, l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END displayed_duns_merge;


PROCEDURE check_params(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_id         IN	NUMBER:=FND_API.G_MISS_NUM,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
	p_proc_name	  IN	VARCHAR2,
	p_exp_ent_name	IN	VARCHAR2:=FND_API.G_MISS_CHAR,
        p_exp_par_ent_name IN   VARCHAR2:=FND_API.G_MISS_CHAR,
        p_pk_column	IN	VARCHAR2:=FND_API.G_MISS_CHAR,
	p_par_pk_column	IN	VARCHAR2:=FND_API.G_MISS_CHAR,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN
   IF (p_entity_name <> p_exp_ent_name OR
       p_par_entity_name <> p_exp_par_ent_name) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_ENTITIES');
     FND_MESSAGE.SET_TOKEN('ENTITY' ,p_entity_name);
     FND_MESSAGE.SET_TOKEN('PENTITY' ,p_par_entity_name);
     FND_MESSAGE.SET_TOKEN('MPROC' ,p_proc_name);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF (p_from_id = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_FROM_REC');
     FND_MESSAGE.SET_TOKEN('MPROC' ,p_proc_name);
     FND_MESSAGE.SET_TOKEN('ENTITY',p_entity_name);
     FND_MESSAGE.SET_TOKEN('PKCOL',p_pk_column);
     FND_MESSAGE.SET_TOKEN('PKVALUE',p_to_id);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF (p_exp_par_ent_name <> FND_API.G_MISS_CHAR AND
       p_to_fk_id = FND_API.G_MISS_NUM ) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_FROM_PAR_REC');
     FND_MESSAGE.SET_TOKEN('MPROC' ,p_proc_name);
     FND_MESSAGE.SET_TOKEN('ENTITY',p_par_entity_name);
     FND_MESSAGE.SET_TOKEN('PKCOL',p_pk_column);
     FND_MESSAGE.SET_TOKEN('PKVALUE',p_to_id);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_params;

/***** Private Procedure *****/

PROCEDURE do_cust_account_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS
l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;
BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_CUST_ACCOUNTS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE cust_account_id = p_from_id;
       HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_CUST_ACCOUNTS',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CUST_ACCOUNTS
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE cust_account_id = p_from_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_cust_account_transfer;

PROCEDURE do_cust_account_role_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
	x_to_id		IN OUT NOCOPY	NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;

--Start of Bug No : 3373079
l_g_miss_num NUMBER;
CURSOR c_from_acct_role_det IS
SELECT cust_account_id,cust_acct_site_id
FROM   HZ_CUST_ACCOUNT_ROLES
WHERE  cust_account_role_id = p_from_id
--AND    party_id = p_from_fk_id
AND    NVL(STATUS,'A') = 'A';

CURSOR c_to_acct_role_det(p_acct_id NUMBER,p_acct_site_id NUMBER) IS
SELECT count(1)
FROM   HZ_CUST_ACCOUNT_ROLES
WHERE  party_id = p_to_fk_id
AND    cust_account_id = p_acct_id
AND    NVL(cust_acct_site_id,l_g_miss_num) = NVL(p_acct_site_id,l_g_miss_num)
AND    NVL(STATUS,'A') = 'A';

l_cust_account_id    NUMBER(15);
l_cust_acct_site_id  NUMBER(15);
l_status             VARCHAR2(1);
l_count              NUMBER;
--End of Bug No : 3373079
BEGIN
  l_g_miss_num := FND_API.G_MISS_NUM;

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_CUST_ACCOUNT_ROLES
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE cust_account_role_id = p_from_id;

      HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_CUST_ACCOUNT_ROLES',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
     IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
     END IF;
  ELSE
   --Start of Bug No : 3373079. Duplicate account roles should not be created through the party merge.
   --If the account roles are duplicate, inactivate the duplicate account role.
    l_status := 'A';
    IF(p_from_fk_id <> p_to_fk_id) THEN
     --Get the from role account id and site id
      OPEN  c_from_acct_role_det;
      FETCH c_from_acct_role_det INTO l_cust_account_id,l_cust_acct_site_id;
      CLOSE c_from_acct_role_det;
      IF(l_cust_account_id IS NOT NULL) THEN
       --Set the status of duplicate account role to 'I'
       OPEN c_to_acct_role_det(l_cust_account_id,l_cust_acct_site_id);
       FETCH c_to_acct_role_det INTO l_count;
       CLOSE c_to_acct_role_det;
       IF(l_count >0)THEN
         l_status :='I';
       END IF;
      END IF;
    END IF;
   --End of Bug No : 3373079
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CUST_ACCOUNT_ROLES
    SET
      party_id = p_to_fk_id,
      status   = l_status,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE cust_account_role_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_cust_account_role_transfer;

PROCEDURE do_fin_profile_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_FINANCIAL_PROFILE
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE financial_profile_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_FINANCIAL_PROFILE
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE financial_profile_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_fin_profile_transfer;

PROCEDURE do_contact_point_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

l_exists VARCHAR2(10);
l_primary_flag VARCHAR2(1):='N';
l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;

---BugNo:1695595.Added local variables and cursors----

l_contact_point_type	 VARCHAR2(30);
l_fp_primary_flag	 VARCHAR2(1);
l_pri_purpose_flag       VARCHAR2(1) := 'N';
l_fp_pri_pur_flag        VARCHAR2(1);
l_url			 VARCHAR2(2000);
l_email_address		 VARCHAR2(2000);
l_contact_point_purpose	 VARCHAR2(30);
l_phone_line_type	 VARCHAR2(30);
l_phone_country_code	 VARCHAR2(10);
l_phone_area_code	 VARCHAR2(10);
l_phone_number		 VARCHAR2(40);
l_phone_extension	 VARCHAR2(20);



CURSOR c_fp_cpt_details IS
SELECT contact_point_type,primary_flag, url, email_address,
       contact_point_purpose,phone_line_type, phone_country_code,
       phone_area_code,phone_number,phone_extension ,primary_by_purpose
FROM HZ_CONTACT_POINTS
WHERE owner_table_name = 'HZ_PARTIES'
      AND contact_point_id = p_from_id
      AND rownum=1;

----------------
BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_CONTACT_POINTS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE contact_point_id = p_from_id;

    DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE STAGED_FLAG='N'
    AND RECORD_ID=p_from_id AND ENTITY='CONTACT_POINTS';

           HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_CONTACT_POINTS',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;

  ELSE
      --- Transfer ---

    /* BugNo:1695595. Added the condition CONTACT_POINT_TYPE=l_contact_point_type
       to get the primary flag associated to from party contact point type.
    */
    OPEN c_fp_cpt_details;
    FETCH c_fp_cpt_details into l_contact_point_type,l_fp_primary_flag,
                                l_url,l_email_address,l_contact_point_purpose,
                                l_phone_line_type,l_phone_country_code,
                                l_phone_area_code,l_phone_number,l_phone_extension,
                                l_fp_pri_pur_flag ;
    CLOSE c_fp_cpt_details;

    IF l_fp_pri_pur_flag   = 'Y' THEN
    BEGIN
        SELECT 'Exists'
        INTO    l_exists
        FROM    HZ_CONTACT_POINTS
        WHERE   PRIMARY_BY_PURPOSE    = 'Y'
        AND     CONTACT_POINT_PURPOSE = l_contact_point_purpose
        AND     OWNER_TABLE_NAME      = 'HZ_PARTIES'
        AND     CONTACT_POINT_TYPE    = l_contact_point_type
        AND     OWNER_TABLE_ID        = p_to_fk_id
        AND     ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_pri_purpose_flag := 'Y';
    END;
    END IF;

    IF l_fp_primary_flag  = 'Y' THEN
    BEGIN
        SELECT 'Exists'
        INTO    l_exists
        FROM    HZ_CONTACT_POINTS
        WHERE   primary_flag      = 'Y'
        AND     OWNER_TABLE_NAME  = 'HZ_PARTIES'
        AND     CONTACT_POINT_TYPE= l_contact_point_type
        AND     OWNER_TABLE_ID    = p_to_fk_id
        AND     ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --BugNo:1695595.Changed l_primary_flag value from 'Y' to from contact point
      --primary flag value.
       l_primary_flag   :=l_fp_primary_flag;
   END;
   END IF;


    --BugNo:1695595.Added code to update denormalized columns.------
    IF (l_primary_flag='Y' AND l_contact_point_type IN ('WEB','EMAIL','PHONE')) THEN
     do_denormalize_contact_point(p_to_fk_id,
				  l_contact_point_type,
				  l_url,
				  l_email_address,
				  p_from_id,
				  l_contact_point_purpose,
				  l_phone_line_type,
				  l_phone_country_code,
				  l_phone_area_code,
				  l_phone_number,
				  l_phone_extension);
    END IF;

    -----------------------
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CONTACT_POINTS
    SET
      owner_table_id = p_to_fk_id,
      primary_flag = l_primary_flag,
      primary_by_purpose = l_pri_purpose_flag,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE contact_point_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_contact_point_transfer;

PROCEDURE do_contact_point_transfer2(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;
l_exists VARCHAR2(10);
l_fp_primary_flag VARCHAR2(1);
l_fp_pri_purpose_flag VARCHAR2(1);
l_primary_flag VARCHAR2(1):='N';
l_pri_purpose_flag VARCHAR2(1):='N';
l_contact_point_type     VARCHAR2(30);
l_contact_point_purpose  HZ_CONTACT_POINTS.CONTACT_POINT_PURPOSE%TYPE;

CURSOR c_fp_cpt_details IS
SELECT contact_point_type, contact_point_purpose,primary_flag,primary_by_purpose
FROM HZ_CONTACT_POINTS
WHERE owner_table_name = 'HZ_PARTY_SITES'
      AND contact_point_id = p_from_id
      AND rownum=1;


BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    -- Update  and set status to merged
    UPDATE HZ_CONTACT_POINTS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE contact_point_id = p_from_id;

    DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE STAGED_FLAG='N'
    AND RECORD_ID=p_from_id AND ENTITY='CONTACT_POINTS';

     HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_CONTACT_POINTS',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;
  ELSE
    --- Transfer ---
    OPEN c_fp_cpt_details;
    FETCH c_fp_cpt_details into l_contact_point_type, l_contact_point_purpose,
                                l_fp_primary_flag, l_fp_pri_purpose_flag;
    CLOSE c_fp_cpt_details;

    IF l_fp_pri_purpose_flag = 'Y' THEN
    BEGIN
        SELECT 'Exists'
        INTO l_exists
        FROM HZ_CONTACT_POINTS
        WHERE PRIMARY_BY_PURPOSE    = 'Y'
        AND   CONTACT_POINT_PURPOSE = l_contact_point_purpose
        AND   OWNER_TABLE_NAME      = 'HZ_PARTY_SITES'
        AND   CONTACT_POINT_TYPE    = l_contact_point_type
        AND   OWNER_TABLE_ID        = p_to_fk_id
        AND   ROWNUM = 1;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_pri_purpose_flag := 'Y';
    END;
    END IF;

    IF l_fp_primary_flag  = 'Y' THEN
    BEGIN
        SELECT 'Exists'
          INTO l_exists
          FROM HZ_CONTACT_POINTS
         WHERE PRIMARY_FLAG        = 'Y'
           AND OWNER_TABLE_NAME    = 'HZ_PARTY_SITES'
           AND OWNER_TABLE_ID      = p_to_fk_id
           AND CONTACT_POINT_TYPE  = l_contact_point_type
           AND ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_primary_flag := 'Y';
    END;
    END IF;

    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CONTACT_POINTS
    SET
      owner_table_id = p_to_fk_id,
      primary_flag = l_primary_flag,
      primary_by_purpose = l_pri_purpose_flag,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE contact_point_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_contact_point_transfer2;

PROCEDURE do_contact_pref_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN
  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_CONTACT_PREFERENCES
    SET
      status = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE contact_preference_id = p_from_id;
  ELSE
    -- Update and set contact_level_table_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CONTACT_PREFERENCES
    SET
      contact_level_table_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE contact_preference_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_contact_pref_transfer;

PROCEDURE do_references_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_REFERENCES
    SET
      status = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE reference_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_REFERENCES
    SET
      referenced_party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE reference_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_references_transfer;

PROCEDURE do_certification_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_CERTIFICATIONS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE certification_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CERTIFICATIONS
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE certification_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_certification_transfer;

PROCEDURE do_credit_ratings_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_CREDIT_RATINGS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE credit_rating_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CREDIT_RATINGS
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE credit_rating_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_credit_ratings_transfer;

PROCEDURE do_security_issued_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_SECURITY_ISSUED
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE security_issued_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_SECURITY_ISSUED
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE security_issued_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_security_issued_transfer;

PROCEDURE do_financial_reports_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_FINANCIAL_REPORTS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE financial_report_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_FINANCIAL_REPORTS
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE financial_report_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_financial_reports_transfer;

PROCEDURE do_org_indicators_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_ORGANIZATION_INDICATORS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE organization_indicator_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_ORGANIZATION_INDICATORS
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE organization_indicator_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_org_indicators_transfer;

PROCEDURE do_ind_reference_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_INDUSTRIAL_REFERENCE
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE industry_reference_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_INDUSTRIAL_REFERENCE
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE industry_reference_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_ind_reference_transfer;

PROCEDURE do_per_interest_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_PERSON_INTEREST
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE person_interest_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_PERSON_INTEREST
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE person_interest_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_per_interest_transfer;

PROCEDURE do_citizenship_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_CITIZENSHIP
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE citizenship_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CITIZENSHIP
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE citizenship_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_citizenship_transfer;

PROCEDURE do_education_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_EDUCATION
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE education_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_EDUCATION
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE education_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_education_transfer;

PROCEDURE do_education_school_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_EDUCATION
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE education_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_EDUCATION
    SET
      school_party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE education_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_education_school_transfer;


PROCEDURE do_emp_history_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_EMPLOYMENT_HISTORY
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE employment_history_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_EMPLOYMENT_HISTORY
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE employment_history_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_emp_history_transfer;

PROCEDURE do_employed_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_EMPLOYMENT_HISTORY
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE employment_history_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_EMPLOYMENT_HISTORY
    SET
      employed_by_party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE employment_history_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_employed_transfer;


PROCEDURE do_work_class_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_WORK_CLASS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE work_class_id = p_from_id;
  ELSE
    -- Update and set employment_history_id = p_to_fk_id where pk = from_id
    UPDATE HZ_WORK_CLASS
    SET
      employment_history_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE work_class_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_work_class_transfer;

PROCEDURE do_org_contact_role_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS
l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;
l_primary_flag                 VARCHAR2(1) := 'N';
l_fp_primary_flag              VARCHAR2(1) ;
l_fp_primary_role_flag         VARCHAR2(1) ;
l_primary_role_flag            VARCHAR2(1) := 'N';
l_role_type                    HZ_ORG_CONTACT_ROLES.ROLE_TYPE%TYPE;
l_exists                       VARCHAR2(10);
CURSOR from_contact_role IS
     SELECT role_type,primary_flag,primary_contact_per_role_type
       FROM HZ_ORG_CONTACT_ROLES
      WHERE ORG_CONTACT_ROLE_ID = p_from_id;
BEGIN

    IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_ORG_CONTACT_ROLES
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE org_contact_role_id = p_from_id;

       HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
                    p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_ORG_CONTACT_ROLES',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

   ELSE
     --- Transfer ---

     OPEN  from_contact_role;
     FETCH from_contact_role into l_role_type,l_fp_primary_flag,l_fp_primary_role_flag;
     CLOSE from_contact_role;

     IF l_fp_primary_flag = 'Y' THEN
     BEGIN
        SELECT 'Exists'
        INTO l_exists
        FROM HZ_ORG_CONTACT_ROLES
        WHERE PRIMARY_FLAG    = 'Y'
        AND   ORG_CONTACT_ID  = p_to_fk_id
        AND   ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_primary_flag := 'Y';
    END;
    END IF;

    IF l_fp_primary_role_flag = 'Y' THEN
    BEGIN
        SELECT 'Exists'
        INTO    l_exists
        FROM         HZ_RELATIONSHIPS PR,
                     HZ_ORG_CONTACTS OC,
                     HZ_ORG_CONTACT_ROLES OCR,
                     HZ_RELATIONSHIPS PR2,
                     HZ_ORG_CONTACTS OC2
              WHERE  OCR.PRIMARY_CONTACT_PER_ROLE_TYPE = 'Y'
              AND    OCR.ROLE_TYPE            = l_role_type
              AND    OCR.ORG_CONTACT_ID       = OC.ORG_CONTACT_ID
              AND    OC.PARTY_RELATIONSHIP_ID = PR.RELATIONSHIP_ID
              AND    PR.OBJECT_ID             = PR2.OBJECT_ID
              AND    PR2.RELATIONSHIP_ID      = OC2.PARTY_RELATIONSHIP_ID
              AND    OC2.ORG_CONTACT_ID       = p_to_fk_id
              AND    PR.SUBJECT_TABLE_NAME    = 'HZ_PARTIES'
              AND    PR.OBJECT_TABLE_NAME     = 'HZ_PARTIES'
              AND    PR.DIRECTIONAL_FLAG      = 'F'
              AND    PR2.SUBJECT_TABLE_NAME   = 'HZ_PARTIES'
              AND    PR2.OBJECT_TABLE_NAME    = 'HZ_PARTIES'
              AND    PR2.DIRECTIONAL_FLAG     = 'F'
              AND    ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_primary_role_flag := 'Y';
    END;
    END IF;

    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_ORG_CONTACT_ROLES
    SET
      org_contact_id = p_to_fk_id,
      primary_flag   = l_primary_flag,
      primary_contact_per_role_type  = l_primary_role_flag,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE org_contact_role_id = p_from_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_org_contact_role_transfer;

PROCEDURE do_financial_number_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_FINANCIAL_NUMBERS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE financial_number_id = p_from_id;
  ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_FINANCIAL_NUMBERS
    SET
      financial_report_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE financial_number_id = p_from_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_financial_number_transfer;

PROCEDURE do_code_assignment_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

l_exists VARCHAR2(10);
l_cont_src VARCHAR2(255);
l_primary_flag VARCHAR2(1):='N';
l_fp_primary_flag VARCHAR2(1);
l_class_category HZ_CODE_ASSIGNMENTS.CLASS_CATEGORY%TYPE;
l_code_exists VARCHAR2(1);
l_class_code HZ_CODE_ASSIGNMENTS.CLASS_CODE%TYPE; --bug 4582789

CURSOR c_cont_source IS
  SELECT CONTENT_SOURCE_TYPE,CLASS_CATEGORY,PRIMARY_FLAG,CLASS_CODE
  FROM HZ_CODE_ASSIGNMENTS
  WHERE code_assignment_id = p_from_id;

CURSOR check_multiple_assignments IS
SELECT 'Y'
FROM hz_class_categories cc, hz_code_assignments ca
WHERE ca.owner_table_id = p_to_fk_id
AND cc.class_category = ca.class_category
AND cc.allow_multi_assign_flag = 'N'
AND ca.class_category = l_class_category;

BEGIN
--bug4086873
OPEN c_cont_source;
FETCH c_cont_source INTO l_cont_src,l_class_category,l_fp_primary_flag,l_class_code;
CLOSE c_cont_source;


OPEN check_multiple_assignments;
FETCH check_multiple_assignments INTO l_code_exists;
CLOSE check_multiple_assignments;


  IF (x_to_id <> FND_API.G_MISS_NUM AND  x_to_id <> p_from_id)
     OR (NVL(l_code_exists,'N') = 'Y') THEN
    UPDATE HZ_CODE_ASSIGNMENTS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login
--      request_id =  hz_utility_pub.request_id,
--      program_application_id = hz_utility_pub.program_application_id,
--      program_id = hz_utility_pub.program_id,
--      program_update_date = sysdate
    WHERE code_assignment_id = p_from_id;

  ELSE
   --- Transfer ---
/*    OPEN c_cont_source;
    FETCH c_cont_source INTO l_cont_src,l_class_category,l_fp_primary_flag;
    CLOSE c_cont_source;*/

    IF l_fp_primary_flag = 'Y' THEN
    BEGIN
        SELECT 'Exists'
          INTO l_exists
          FROM HZ_CODE_ASSIGNMENTS
         WHERE primary_flag         = 'Y'
           AND OWNER_TABLE_NAME     = 'HZ_PARTIES'
           AND OWNER_TABLE_ID       = p_to_fk_id
           AND CLASS_CATEGORY       = l_class_category
           AND CONTENT_SOURCE_TYPE  = l_cont_src
           AND ROWNUM = 1;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            l_primary_flag := 'Y';
    END;
    END IF;

    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CODE_ASSIGNMENTS
    SET
      owner_table_id = p_to_fk_id,
      primary_flag =   l_primary_flag,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login
--      request_id =  hz_utility_pub.request_id,
--      program_application_id = hz_utility_pub.program_application_id,
--      program_id = hz_utility_pub.program_id,
--      program_update_date = sysdate
    WHERE code_assignment_id = p_from_id;

--bug 4582789

   IF l_primary_flag = 'Y' AND l_class_category = 'CUSTOMER_CATEGORY' THEN
	UPDATE hz_parties
	SET category_code = l_class_code,
	    last_update_date = hz_utility_pub.last_update_date,
            last_updated_by = hz_utility_pub.user_id,
            last_update_login = hz_utility_pub.last_update_login
        WHERE party_id = p_to_fk_id;
   END IF;
---bug 4582789
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_code_assignment_transfer;

PROCEDURE do_code_assignment_transfer2(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

l_exists VARCHAR2(10);
l_primary_flag VARCHAR2(1):='N';
l_fp_primary_flag VARCHAR2(1);
l_cont_src VARCHAR2(255);
l_class_category HZ_CODE_ASSIGNMENTS.CLASS_CATEGORY%TYPE;
l_code_exists VARCHAR2(1);

CURSOR c_cont_source IS
  SELECT CONTENT_SOURCE_TYPE,CLASS_CATEGORY,PRIMARY_FLAG
  FROM HZ_CODE_ASSIGNMENTS
  WHERE code_assignment_id = p_from_id;

CURSOR check_multiple_assignments IS
SELECT 'Y'
FROM hz_class_categories cc, hz_code_assignments ca
WHERE ca.owner_table_id = p_to_fk_id
AND cc.class_category = ca.class_category
AND cc.allow_multi_assign_flag = 'N'
AND ca.class_category = l_class_category;

BEGIN
--bug4086873
OPEN c_cont_source;
FETCH c_cont_source INTO l_cont_src,l_class_category,l_fp_primary_flag;
CLOSE c_cont_source;


OPEN check_multiple_assignments;
FETCH check_multiple_assignments INTO l_code_exists;
CLOSE check_multiple_assignments;

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) OR (NVL(l_code_exists,'N') = 'Y') THEN
    UPDATE HZ_CODE_ASSIGNMENTS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login
--      request_id =  hz_utility_pub.request_id,
--      program_application_id = hz_utility_pub.program_application_id,
--      program_id = hz_utility_pub.program_id,
--      program_update_date = sysdate
    WHERE code_assignment_id = p_from_id;
  ELSE
    --- Transfer ---
/*    OPEN c_cont_source;
    FETCH c_cont_source INTO l_cont_src,l_class_category,l_fp_primary_flag;
    CLOSE c_cont_source; */
   IF l_fp_primary_flag = 'Y' THEN
   BEGIN
    SELECT 'Exists'
    INTO l_exists
    FROM HZ_CODE_ASSIGNMENTS
    WHERE PRIMARY_FLAG       = 'Y'
    AND OWNER_TABLE_NAME     = 'HZ_PARTY_SITES'
    AND OWNER_TABLE_ID       = p_to_fk_id
    AND CLASS_CATEGORY       = l_class_category
    AND CONTENT_SOURCE_TYPE  = l_cont_src
    AND ROWNUM = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_primary_flag := 'Y';
  END;
  END IF;

    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_CODE_ASSIGNMENTS
    SET
      owner_table_id = p_to_fk_id,
      primary_flag = l_primary_flag,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login
--      request_id =  hz_utility_pub.request_id,
--      program_application_id = hz_utility_pub.program_application_id,
--      program_id = hz_utility_pub.program_id,
--      program_update_date = sysdate
    WHERE code_assignment_id = p_from_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_code_assignment_transfer2;

PROCEDURE do_per_languages_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS
l_count   NUMBER;
l_primary_nav_flag  VARCHAR2(1):= 'N';
l_primary_lang_flag VARCHAR2(1):= 'N';
l_exists  VARCHAR2(10);
l_fp_pri_ind_flag VARCHAR2(1);
l_fp_nav_flag VARCHAR2(1);

Cursor C_From_Lang IS
   SELECT   primary_language_indicator,native_language
     FROM   HZ_PERSON_LANGUAGE
    WHERE   LANGUAGE_USE_REFERENCE_ID  = p_from_id;

BEGIN
  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_PERSON_LANGUAGE
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE language_use_reference_id = p_from_id;
  ELSE
    --- Transfer ---
  OPEN C_From_Lang;
  FETCH C_From_Lang INTO l_fp_pri_ind_flag,l_fp_nav_flag;
  CLOSE C_From_Lang;
  IF l_fp_pri_ind_flag = 'Y' THEN
  BEGIN
    SELECT 'Exists'
    INTO    l_exists
    FROM    HZ_PERSON_LANGUAGE
    WHERE   PRIMARY_LANGUAGE_INDICATOR = 'Y'
    AND     PARTY_ID = p_to_fk_id
    AND     ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_primary_lang_flag := 'Y';
  END;
  END IF;

  IF l_fp_nav_flag = 'Y' THEN
  BEGIN
    SELECT 'Exists'
    INTO    l_exists
    FROM    HZ_PERSON_LANGUAGE
    WHERE   NATIVE_LANGUAGE = 'Y'
    AND     PARTY_ID = p_to_fk_id
    AND     ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_primary_nav_flag := 'Y';
  END;
  END IF;

/*
  OPEN C_Lang1;
  FETCH C_Lang1 INTO l_count;
  IF C_Lang1%FOUND THEN
     OPEN C_Lang2;
     FETCH C_Lang2 INTO l_count;
     IF C_Lang2%NOTFOUND THEN
        -- Update
        l_native_language := 'Y';
     END IF;
     CLOSE C_Lang2;
  END IF;
  CLOSE C_Lang1;

*/
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_PERSON_LANGUAGE
    SET
      party_id = p_to_fk_id,
      primary_language_indicator = l_primary_lang_flag,
      native_language  = l_primary_nav_flag,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE language_use_reference_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_per_languages_transfer;

PROCEDURE do_party_site_use_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

party_site_use_rec                 HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;

----Start of Bug No: 3560167-------------------
CURSOR c_party_id(p_party_site_id NUMBER) IS
                SELECT PARTY_ID FROM HZ_PARTY_SITES
		WHERE  PARTY_SITE_ID = p_party_site_id
		AND ROWNUM =1;

CURSOR c_prim_site_uses(p_party_id NUMBER,p_party_site_id NUMBER,p_site_use_type VARCHAR2,p_request_id NUMBER)
                       IS SELECT 1 FROM HZ_PARTY_SITE_USES SU
			   WHERE  SU.PARTY_SITE_ID IN (
			      SELECT PS.PARTY_SITE_ID
			      FROM   HZ_PARTY_SITES PS
			      WHERE  PARTY_ID = p_party_id )
			   AND    SU.PARTY_SITE_ID <> p_party_site_id
			   AND    SU.SITE_USE_TYPE = p_site_use_type
			   AND    SU.PRIMARY_PER_TYPE = 'Y'
			   AND    SU.REQUEST_ID =p_request_id
			   AND    ROWNUM = 1;
l_prim_use_exists NUMBER := 0;
l_party_id        NUMBER;

----End of Bug No: 3560167-------------------

BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_PARTY_SITE_USES
    SET
      ----Bug: 2619948 added setting status to 'M' here too
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE party_site_use_id = p_from_id;
  ELSE

    hz_cust_account_merge_v2pvt.get_party_site_use_rec (
         p_init_msg_list => 'T',
         p_party_site_use_id => p_from_id,
         x_party_site_use_rec => party_site_use_rec,
         x_return_status => x_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data );

    IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR','Cannot get party site use ID : ' || p_from_id);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

      RETURN;
    END IF;

    party_site_use_rec.party_site_use_id := FND_API.G_MISS_NUM;
    party_site_use_rec.party_site_id := p_to_fk_id;

    ----Start of Bug No: 3560167-------------------
    IF party_site_use_rec.primary_per_type  = 'Y' THEN
      OPEN c_party_id(p_to_fk_id);
      FETCH c_party_id INTO l_party_id;
      CLOSE c_party_id;

      OPEN  c_prim_site_uses(l_party_id,p_to_fk_id,party_site_use_rec.site_use_type,hz_utility_pub.request_id);
      FETCH c_prim_site_uses INTO l_prim_use_exists;
      CLOSE c_prim_site_uses;
      IF l_prim_use_exists <> 1 THEN
         party_site_use_rec.primary_per_type := 'N';
      END IF;
    END IF;
    ----End of Bug No: 3560167-------------------

    --Create new party site.
    hz_cust_account_merge_v2pvt.create_party_site_use(
         p_init_msg_list => 'T',
         p_party_site_use_rec => party_site_use_rec,
         x_party_site_use_id => x_to_id,
         x_return_status => x_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data );

    IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR','Cannot copy party site use for ID : ' || p_from_id);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_PARTY_SITE_USES
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE party_site_use_id = p_from_id;

    x_return_status := 'N';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_party_site_use_transfer;

PROCEDURE do_cust_account_site_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS
l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;
BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_CUST_ACCT_SITES_ALL
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE cust_acct_site_id = p_from_id;

       HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_CUST_ACCT_SITES_ALL',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;

  ELSE
    UPDATE HZ_CUST_ACCT_SITES_ALL
    SET
      party_site_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE cust_acct_site_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_cust_account_site_transfer;

PROCEDURE do_org_contact_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS
l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;
BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN
    UPDATE HZ_ORG_CONTACTS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE org_contact_id = p_from_id;

    DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE STAGED_FLAG='N' AND ENTITY='CONTACTS'
    AND RECORD_ID=p_from_id;

     HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_ORG_CONTACTS',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;

  ELSE
    UPDATE HZ_ORG_CONTACTS
    SET
      party_site_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE org_contact_id = p_from_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_org_contact_transfer;

PROCEDURE do_org_contact_transfer2(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

CURSOR c_merge_to_org_contact IS
  SELECT org_contact_id
  FROM HZ_ORG_CONTACTS
  WHERE party_relationship_id = p_to_fk_id;

CURSOR c_org_cont_attributes(cp_org_cnt_id number) is
	select
	   DEPARTMENT_CODE
	, DEPARTMENT
	, TITLE
	, JOB_TITLE
	, MAIL_STOP
	, CONTACT_KEY
	, DECISION_MAKER_FLAG
	, JOB_TITLE_CODE
	, MANAGED_BY
	, REFERENCE_USE_FLAG
	, RANK
	, NATIVE_LANGUAGE
	, OTHER_LANGUAGE_1
	, OTHER_LANGUAGE_2
	from hz_org_contacts
	where org_contact_id = cp_org_cnt_id;

l_to_orgcontact_id NUMBER;
l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;

L_FROM_DEPARTMENT_CODE  HZ_ORG_CONTACTS.DEPARTMENT_CODE%TYPE;
L_FROM_DEPARTMENT  HZ_ORG_CONTACTS.DEPARTMENT%TYPE;
L_FROM_TITLE    HZ_ORG_CONTACTS.TITLE%TYPE;
L_FROM_JOB_TITLE   HZ_ORG_CONTACTS.JOB_TITLE%TYPE;
L_FROM_MAIL_STOP  HZ_ORG_CONTACTS.MAIL_STOP%TYPE;
L_FROM_CONTACT_KEY  HZ_ORG_CONTACTS.CONTACT_KEY%TYPE;
L_FROM_DECISION_MAKER_FLAG HZ_ORG_CONTACTS.DECISION_MAKER_FLAG%TYPE;
L_FROM_JOB_TITLE_CODE  HZ_ORG_CONTACTS.JOB_TITLE_CODE%TYPE;
L_FROM_MANAGED_BY     HZ_ORG_CONTACTS.MANAGED_BY%TYPE;
L_FROM_REFERENCE_USE_FLAG   HZ_ORG_CONTACTS.REFERENCE_USE_FLAG%TYPE;
L_FROM_RANK   HZ_ORG_CONTACTS.RANK%TYPE;
L_FROM_NATIVE_LANGUAGE  HZ_ORG_CONTACTS.NATIVE_LANGUAGE%TYPE;
L_FROM_OTHER_LANGUAGE_1 HZ_ORG_CONTACTS.OTHER_LANGUAGE_1%TYPE;
L_FROM_OTHER_LANGUAGE_2 HZ_ORG_CONTACTS.OTHER_LANGUAGE_2%TYPE;

BEGIN

  IF (p_from_fk_id = p_to_fk_id) THEN
    RETURN;
  END IF;

  OPEN c_merge_to_org_contact;
  FETCH c_merge_to_org_contact INTO l_to_orgcontact_id;
  IF c_merge_to_org_contact%NOTFOUND THEN
    CLOSE c_merge_to_org_contact;
    UPDATE HZ_ORG_CONTACTS
    SET
      party_relationship_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE org_contact_id = p_from_id;
  ELSE
    CLOSE c_merge_to_org_contact;

-- bug 5100644: carry over not null org contact attributes

   open c_org_cont_attributes(p_from_id);
    fetch c_org_cont_attributes into
		L_FROM_DEPARTMENT_CODE,
		L_FROM_DEPARTMENT,
		L_FROM_TITLE,
		L_FROM_JOB_TITLE,
		L_FROM_MAIL_STOP,
		L_FROM_CONTACT_KEY,
		L_FROM_DECISION_MAKER_FLAG,
		L_FROM_JOB_TITLE_CODE,
		L_FROM_MANAGED_BY,
		L_FROM_REFERENCE_USE_FLAG,
		L_FROM_RANK,
		L_FROM_NATIVE_LANGUAGE,
		L_FROM_OTHER_LANGUAGE_1,
		L_FROM_OTHER_LANGUAGE_2;
    close c_org_cont_attributes;

    UPDATE HZ_ORG_CONTACTS
    SET
	DEPARTMENT_CODE = DECODE(DEPARTMENT_CODE, NULL, L_FROM_DEPARTMENT_CODE,DEPARTMENT_CODE),
	DEPARTMENT = DECODE(DEPARTMENT, NULL, L_FROM_DEPARTMENT,DEPARTMENT ),
	TITLE = DECODE(TITLE, NULL, L_FROM_TITLE,TITLE),
	JOB_TITLE = DECODE(JOB_TITLE, NULL, L_FROM_JOB_TITLE,JOB_TITLE),
	MAIL_STOP = DECODE(MAIL_STOP, NULL, L_FROM_MAIL_STOP,MAIL_STOP),
	CONTACT_KEY = DECODE(CONTACT_KEY, NULL, L_FROM_CONTACT_KEY,CONTACT_KEY),
	DECISION_MAKER_FLAG = DECODE(DECISION_MAKER_FLAG, NULL, L_FROM_DECISION_MAKER_FLAG,DECISION_MAKER_FLAG),
	JOB_TITLE_CODE = DECODE(JOB_TITLE_CODE, NULL, L_FROM_JOB_TITLE_CODE,JOB_TITLE_CODE),
	MANAGED_BY = DECODE(MANAGED_BY, NULL, L_FROM_MANAGED_BY,MANAGED_BY),
	REFERENCE_USE_FLAG = DECODE(REFERENCE_USE_FLAG, NULL, L_FROM_REFERENCE_USE_FLAG,REFERENCE_USE_FLAG),
	RANK = DECODE(RANK, NULL, L_FROM_RANK,RANK),
	NATIVE_LANGUAGE = DECODE(NATIVE_LANGUAGE, NULL, L_FROM_NATIVE_LANGUAGE,NATIVE_LANGUAGE),
	OTHER_LANGUAGE_1 = DECODE(OTHER_LANGUAGE_1, NULL, L_FROM_OTHER_LANGUAGE_1,OTHER_LANGUAGE_1),
	OTHER_LANGUAGE_2 = DECODE(OTHER_LANGUAGE_2, NULL, L_FROM_OTHER_LANGUAGE_2,OTHER_LANGUAGE_2)

    WHERE ORG_CONTACT_ID = l_to_orgcontact_id;


    UPDATE HZ_ORG_CONTACTS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE org_contact_id = p_from_id;

    DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE STAGED_FLAG='N' AND ENTITY='CONTACTS'
    AND RECORD_ID=p_from_id;

    HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => l_to_orgcontact_id,
                    p_owner_table_name  =>'HZ_ORG_CONTACTS',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;

    ---for NOCOPY fix
    x_to_id := l_to_orgcontact_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_org_contact_transfer2;



--4307667
PROCEDURE do_party_usage_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2

) IS
x_msg_count VARCHAR2(2000);
x_msg_data  VARCHAR2(4000);
p_init_msg_list VARCHAR2(32767);
l_from_usage_code VARCHAR2(32767);
p_party_usg_assignment_rec    APPS.HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
BEGIN
p_init_msg_list := 'T';

  begin
	SELECT PARTY_USAGE_CODE INTO l_from_usage_code
	FROM hz_party_usg_assignments
	where party_usg_assignment_id = p_from_id;
  EXCEPTION
          WHEN NO_DATA_FOUND THEN RETURN;
  end;
/*
IF l_from_usage_code = 'DEFAULT' THEN
        UPDATE hz_party_usg_assignments
        SET status_flag = 'M',
        effective_end_date = TRUNC(sysdate)
        WHERE party_usg_assignment_id = p_from_id;
ELSE
*/ -- bug 5007937
--check for duplicate usage
        HZ_PARTY_USG_ASSIGNMENT_PVT.find_duplicates(p_from_id,p_to_fk_id,x_to_id);
        IF x_to_id IS NOT NULL THEN
        --duplicate usage exists
                UPDATE hz_party_usg_assignments
                SET status_flag = 'M',
                effective_end_date = sysdate
                WHERE party_usg_assignment_id = p_from_id;

        ELSE
        --usage doesnot exist create a new usage for merge-to party
        --to handle transition rule new usage is created using API with 0 validation level, instead of updating merge-from party assignment
                p_party_usg_assignment_rec.party_id := p_to_fk_id;

                SELECT
                 party_usage_code,
                 effective_start_date,
                 effective_end_date,
                 comments,
                 owner_table_name,
                 owner_table_id,
                 created_by_module,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20
                INTO
                 p_party_usg_assignment_rec.party_usage_code,
                 p_party_usg_assignment_rec.effective_start_date,
                 p_party_usg_assignment_rec.effective_end_date,
                 p_party_usg_assignment_rec.comments,
                 p_party_usg_assignment_rec.owner_table_name,
                 p_party_usg_assignment_rec.owner_table_id,
                 p_party_usg_assignment_rec.created_by_module,
                 p_party_usg_assignment_rec.attribute_category,
                 p_party_usg_assignment_rec.attribute1,
                 p_party_usg_assignment_rec.attribute2,
                 p_party_usg_assignment_rec.attribute3,
                 p_party_usg_assignment_rec.attribute4,
                 p_party_usg_assignment_rec.attribute5,
                 p_party_usg_assignment_rec.attribute6,
                 p_party_usg_assignment_rec.attribute7,
                 p_party_usg_assignment_rec.attribute8,
                 p_party_usg_assignment_rec.attribute9,
                 p_party_usg_assignment_rec.attribute10,
                 p_party_usg_assignment_rec.attribute11,
                 p_party_usg_assignment_rec.attribute12,
                 p_party_usg_assignment_rec.attribute13,
                 p_party_usg_assignment_rec.attribute14,
                 p_party_usg_assignment_rec.attribute15,
                 p_party_usg_assignment_rec.attribute16,
                 p_party_usg_assignment_rec.attribute17,
                 p_party_usg_assignment_rec.attribute18,
                 p_party_usg_assignment_rec.attribute19,
                 p_party_usg_assignment_rec.attribute20
             FROM hz_party_usg_assignments
             WHERE party_usg_assignment_id = p_from_id;

             HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage
             (p_init_msg_list,0,p_party_usg_assignment_rec,x_return_status,x_msg_count,x_msg_data);

             IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

                 DELETE FROM hz_party_usg_assignments
                 WHERE party_usg_assignment_id = p_from_id;

              /* bug 5007937
		 DELETE FROM hz_party_usg_assignments
                 WHERE party_id = p_to_fk_id
                 AND   party_usage_code = 'DEFAULT';
	      */

             END IF;

        END IF; --x_to_assignment_id
-- END IF; --l_from_usage_code

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_party_usage_merge;


PROCEDURE do_party_reln_obj_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2

) IS

CURSOR c_party(cp_party_reln_id NUMBER) IS
  SELECT party_id
  FROM HZ_RELATIONSHIPS
  WHERE  relationship_id = cp_party_reln_id
  AND DIRECTIONAL_FLAG = 'F'
  and status in ('A','I'); -- bug 5094383

CURSOR c_to_party_reln IS
  SELECT relationship_id
  FROM   HZ_RELATIONSHIPS
  WHERE  relationship_id = x_to_id
  FOR UPDATE NOWAIT;

cursor c_start_end_date is
 SELECT start_date, nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')), actual_content_source --5404244
         FROM   HZ_RELATIONSHIPS
         WHERE  relationship_id = p_from_id
         AND DIRECTIONAL_FLAG='F';

CURSOR c_check_valid_merge(from_start_date date, from_end_date date, from_cont_source_type VARCHAR2, from_cont_source VARCHAR2) IS
  SELECT relationship_id, nvl(request_id,-1)
  FROM   HZ_RELATIONSHIPS
  WHERE  object_id = p_to_fk_id
  AND actual_content_source = DECODE(from_cont_source_type, 'PURCHASED', from_cont_source, actual_content_source) --5404244
  AND subject_id = (
         SELECT SUBJECT_ID
         FROM   HZ_RELATIONSHIPS
         WHERE  relationship_id = p_from_id
         AND DIRECTIONAL_FLAG='F')
  AND subject_id NOT IN
  ((SELECT from_party_id FROM hz_merge_parties WHERE to_party_id = p_to_fk_id AND merge_status='PENDING' )) --bug 4867151
  AND subject_id NOT IN
  ((SELECT to_party_id FROM hz_merge_parties WHERE to_party_id = p_to_fk_id AND merge_status='PENDING' )) --bug 4867151
  AND relationship_code = (
         SELECT relationship_code -- Bug No: 4571969
         FROM   HZ_RELATIONSHIPS
         WHERE  relationship_id = p_from_id
         AND DIRECTIONAL_FLAG='F')
  AND DIRECTIONAL_FLAG = 'F'
  AND ((start_date between from_start_date and from_end_date)
          or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
          or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date))
  AND status IN ('A','I'); --bug 5260367

l_party_rel_id NUMBER;
l_from_party_id	NUMBER;
l_to_party_id	NUMBER;
l_dup_reln_id   NUMBER;
l_request_id    NUMBER;
l_from_last_upd_date DATE;
l_to_last_upd_date DATE;
l_from_party_reln_type VARCHAR2(255);
l_merge_to_id NUMBER;
l_temp NUMBER;
from_start_date date;
from_end_date date;

--Bug 2619913 Do not allow self relationships creation unless
--defined in the relationship type table

l_subject_id NUMBER;
l_rel_type HZ_RELATIONSHIPS.RELATIONSHIP_TYPE%TYPE;
l_rel_code HZ_RELATIONSHIPS.RELATIONSHIP_CODE%TYPE;
l_subject_type HZ_RELATIONSHIPS.SUBJECT_TYPE%TYPE;
l_object_type HZ_RELATIONSHIPS.OBJECT_TYPE%TYPE;
l_self_rel_flag VARCHAR2(1);

l_rel_party_id        HZ_RELATIONSHIPS.PARTY_ID%TYPE;
l_new_obj_party_name HZ_PARTIES.PARTY_NAME%TYPE;
l_subject_name         HZ_PARTIES.PARTY_NAME%TYPE;
l_rel_party_number    HZ_PARTIES.PARTY_NUMBER%TYPE;
from_cont_source    HZ_RELATIONSHIPS.ACTUAL_CONTENT_SOURCE%TYPE; --5404244
from_cont_source_type HZ_ORIG_SYSTEMS_B.ORIG_SYSTEM_TYPE%TYPE;

--6696774 Start
l_par_exists VARCHAR2(1);
l_direction_code HZ_RELATIONSHIPS.DIRECTION_CODE%TYPE;
--6696774 end
BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND x_to_id <> p_from_id) THEN
    OPEN c_party(p_from_id);
    FETCH c_party INTO l_from_party_id;
    IF c_party%NOTFOUND THEN
      l_from_party_id := NULL;
    END IF;
    CLOSE c_party;

    OPEN c_party(x_to_id);
    FETCH c_party INTO l_to_party_id;
    IF c_party%NOTFOUND THEN
      l_to_party_id := NULL;
    END IF;
    CLOSE c_party;

    IF l_to_party_id IS NOT NULL AND l_from_party_id IS NOT NULL
       AND l_from_party_id <> l_to_party_id THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_RELN_MERGE_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('FROMID',p_from_id);
      FND_MESSAGE.SET_TOKEN('TOID',x_to_id);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    IF l_from_party_id IS NOT NULL THEN
      OPEN c_to_party_reln;
      UPDATE HZ_RELATIONSHIPS
      SET
        party_id = l_from_party_id,
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        request_id =  hz_utility_pub.request_id,
        program_application_id = hz_utility_pub.program_application_id,
        program_id = hz_utility_pub.program_id,
        program_update_date = sysdate
      WHERE relationship_id = x_to_id;
      CLOSE c_to_party_reln;
    END IF;

    UPDATE HZ_RELATIONSHIPS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE relationship_id = p_from_id;

--4307667 merge usages with owner_table_name 'HZ_RELATIONSHIPS'
    UPDATE hz_party_usg_assignments
    SET status_flag = 'M',
        effective_end_date = trunc(sysdate)
    WHERE owner_table_id = p_from_id
    AND   owner_table_name = 'HZ_RELATIONSHIPS'
    AND   party_id = p_from_fk_id;

    ----Start of DlProject Phase2--------------------
     do_hierarchy_nodes_merge(p_from_id => p_from_id,
			      p_from_fk_id => p_from_fk_id,
			      p_to_fk_id => p_to_fk_id,
			      x_return_status =>x_return_status,
			      p_action => 'M',
			      p_sub_obj_merge =>'OBJ'
			      );
    ----End of DlProject Phase2--------------------
  ELSE

    open c_start_end_date;
     fetch c_start_end_date into from_start_date,from_end_date,from_cont_source;
    close c_start_end_date;

    SELECT orig_system_type INTO from_cont_source_type --5404244
    FROM HZ_ORIG_SYSTEMS_B
    WHERE orig_system = from_cont_source;
    OPEN c_check_valid_merge(from_start_date, from_end_date, from_cont_source_type,from_cont_source);
    FETCH c_check_valid_merge INTO l_dup_reln_id, l_request_id;
    IF c_check_valid_merge%FOUND AND
       l_request_id <> hz_utility_pub.request_id THEN
      CLOSE c_check_valid_merge;
     FND_MESSAGE.SET_NAME('AR', 'HZ_RELN_TRANSFER_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('FROMID',p_from_id);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
    CLOSE c_check_valid_merge;

    --6696774 Start
    SELECT subject_id, relationship_type, relationship_code,subject_type,object_type,direction_code into l_subject_id, l_rel_type, l_rel_code,
           l_subject_type, l_object_type, l_direction_code
    FROM HZ_RELATIONSHIPS
    WHERE relationship_id = p_from_id
    AND   directional_flag = 'F';

    SELECT allow_relate_to_self_flag
    INTO   l_self_rel_flag
    FROM   HZ_RELATIONSHIP_TYPES
    WHERE RELATIONSHIP_TYPE = l_rel_type
    AND FORWARD_REL_CODE = l_rel_code
    AND SUBJECT_TYPE = l_subject_type
    AND OBJECT_TYPE =  l_object_type;

    l_par_exists := 'N';

    BEGIN

        SELECT 'Y' into l_par_exists
        FROM hz_hierarchy_nodes
        WHERE child_id = l_subject_id
        AND   parent_id = p_to_fk_id
        AND   l_direction_code = 'P'
        AND rownum = 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           null;
    END;

    IF (l_subject_id <> p_to_fk_id OR l_self_rel_flag = 'Y') AND l_par_exists = 'N' THEN
--6696774 END;

     ----Start of DlProject Phase2--------------------
     do_hierarchy_nodes_merge(p_from_id => p_from_id,
			      p_from_fk_id => p_from_fk_id,
			      p_to_fk_id => p_to_fk_id,
			      x_return_status =>x_return_status,
			      p_action => 'T',
			      p_sub_obj_merge =>'OBJ'
			      );
    ----End of DlProject Phase2--------------------
    UPDATE HZ_RELATIONSHIPS
    SET
      object_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE relationship_id = p_from_id
    AND DIRECTIONAL_FLAG = 'F'
    RETURNING  subject_id, relationship_type, relationship_code,
               subject_type, object_type, party_id
    into l_subject_id, l_rel_type, l_rel_code,
         l_subject_type , l_object_type , l_rel_party_id;

    UPDATE HZ_RELATIONSHIPS
    SET
      subject_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE relationship_id = p_from_id
    AND DIRECTIONAL_FLAG = 'B';

      ---Bug# 2688231 After transferring the reln,the name
      --- of the relationship party should also be changed

   if l_rel_party_id is not null then

      select sub.party_name , obj.party_name , rel.party_number
      into l_subject_name , l_new_obj_party_name , l_rel_party_number
      from hz_parties sub , hz_parties obj , hz_parties rel
      where sub.party_id = l_subject_id
      and   obj.party_id = p_to_fk_id
      and   rel.party_id = l_rel_party_id;

      UPDATE HZ_PARTIES
      SET PARTY_NAME = 	SUBSTRB(l_subject_name || '-' ||
                                l_new_obj_party_name  || '-' ||
                                l_rel_party_number, 1, 360)
      WHERE party_id = l_rel_party_id;

   end if;

    --Check if the object_id and subject_id are same and the
    ELSIF (l_subject_id = p_to_fk_id AND l_self_rel_flag = 'N') OR l_par_exists = 'Y' THEN --bug 6696774
     --IF l_subject_id = p_to_fk_id THEN

       BEGIN
         --self relationship is not allowed then, Inactivate it
         SELECT allow_relate_to_self_flag
         INTO   l_self_rel_flag
         FROM   HZ_RELATIONSHIP_TYPES
         WHERE RELATIONSHIP_TYPE = l_rel_type
         AND FORWARD_REL_CODE = l_rel_code
         AND SUBJECT_TYPE = l_subject_type
         AND OBJECT_TYPE =  l_object_type;

       IF  l_self_rel_flag = 'N' THEN
         --Inactivate the relationships BOTH FORWARD AND BACKWARD
         UPDATE HZ_RELATIONSHIPS
         SET
         STATUS = 'I',
         END_DATE = sysdate,
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login,
         request_id =  hz_utility_pub.request_id,
         program_application_id = hz_utility_pub.program_application_id,
         program_id = hz_utility_pub.program_id,
         program_update_date = sysdate
         WHERE relationship_id = p_from_id;
	  ---Start of Bug:3880218----
	 IF l_rel_party_id is not null THEN
		 UPDATE HZ_PARTIES
		 SET STATUS = 'I',
		     last_update_date = hz_utility_pub.last_update_date,
		     last_updated_by = hz_utility_pub.user_id,
		     last_update_login = hz_utility_pub.last_update_login,
		     request_id =  hz_utility_pub.request_id,
		     program_application_id = hz_utility_pub.program_application_id,
		     program_id = hz_utility_pub.program_id,
		     program_update_date = sysdate
		 WHERE PARTY_ID = l_rel_party_id;
	 END IF;
	 ----End of Bug:3880218----
	 ----Start of DlProject Phase2--------------------
         do_hierarchy_nodes_merge(p_from_id => p_from_id,
			      p_from_fk_id => p_from_fk_id,
			      p_to_fk_id => p_to_fk_id,
			      x_return_status =>x_return_status,
			      p_action => 'I'
			      );
         ----End of DlProject Phase2--------------------
       ELSE
--bug 4867151--start
	      IF l_rel_party_id is not null THEN
		      UPDATE HZ_PARTIES
		      SET STATUS = 'M',
		          last_update_date = hz_utility_pub.last_update_date,
		          last_updated_by = hz_utility_pub.user_id,
		          last_update_login = hz_utility_pub.last_update_login,
		          request_id =  hz_utility_pub.request_id,
		          program_application_id = hz_utility_pub.program_application_id,
		          program_id = hz_utility_pub.program_id,
		          program_update_date = sysdate
		      WHERE PARTY_ID in (select party_id from hz_relationships where subject_id=p_to_fk_id
	      and object_id=p_to_fk_id and relationship_id <>p_from_id and status='A'
        AND ((start_date between from_start_date and from_end_date)
        or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
        or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date)));
	      END IF;

      	 UPDATE HZ_RELATIONSHIPS
         SET
         STATUS = 'M',
         END_DATE = sysdate,
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login,
         request_id =  hz_utility_pub.request_id,
         program_application_id = hz_utility_pub.program_application_id,
         program_id = hz_utility_pub.program_id,
         program_update_date = sysdate
         WHERE relationship_id in (select relationship_id from hz_relationships where subject_id=p_to_fk_id
	      and object_id=p_to_fk_id and relationship_id <>p_from_id and status='A'
        AND ((start_date between from_start_date and from_end_date)
        or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
        or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date)));


         do_hierarchy_nodes_merge(p_from_id => p_from_id,
			      p_from_fk_id => p_from_fk_id,
			      p_to_fk_id => p_to_fk_id,
			      x_return_status =>x_return_status,
			      p_action => 'M'
			      );

--bug 4867151--end
      END IF;  --l_self_rel_flag

      EXCEPTION
      WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      END;
    END IF;    --l_subject_id = p_to_fk_id



  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_party_reln_obj_merge;

PROCEDURE do_party_reln_subj_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2

) IS

CURSOR c_party(cp_party_reln_id NUMBER) IS
  SELECT party_id
  FROM HZ_RELATIONSHIPS
  WHERE  relationship_id = cp_party_reln_id
  AND DIRECTIONAL_FLAG = 'F'
  and status in ('A','I'); -- bug 5094383

CURSOR c_to_party_reln IS
  SELECT relationship_id
  FROM   HZ_RELATIONSHIPS
  WHERE  relationship_id = x_to_id
  FOR UPDATE NOWAIT;

cursor c_start_end_date is
 SELECT start_date, nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')), actual_content_source --5404244
         FROM   HZ_RELATIONSHIPS
         WHERE  relationship_id = p_from_id
         AND DIRECTIONAL_FLAG='F';

CURSOR c_check_valid_merge(from_start_date date, from_end_date date, from_cont_source_type VARCHAR2, from_cont_source VARCHAR2) IS
  SELECT relationship_id, nvl(request_id,-1)
  FROM   HZ_RELATIONSHIPS
  WHERE  subject_id = p_to_fk_id
  AND actual_content_source = DECODE(from_cont_source_type, 'PURCHASED', from_cont_source, actual_content_source) --5404244
  AND object_id = (
         SELECT OBJECT_ID
         FROM   HZ_RELATIONSHIPS
         WHERE  relationship_id = p_from_id
         AND DIRECTIONAL_FLAG='F')
  AND  object_id NOT IN
  ((SELECT from_party_id FROM hz_merge_parties WHERE to_party_id = p_to_fk_id AND merge_status='PENDING' )) --bug 4867151
  AND object_id NOT IN
  ((SELECT to_party_id FROM hz_merge_parties WHERE to_party_id = p_to_fk_id AND merge_status='PENDING' )) --bug 4867151
  AND relationship_code = (
         SELECT relationship_code -- Bug No: 4571969
         FROM   HZ_RELATIONSHIPS
         WHERE  relationship_id = p_from_id
         AND DIRECTIONAL_FLAG='F')
  AND DIRECTIONAL_FLAG = 'F'
  AND ((start_date between from_start_date and from_end_date)
          or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
          or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date))
  AND status IN ('A','I'); --bug 5260367

l_party_rel_id NUMBER;
l_from_party_id NUMBER;
l_to_party_id   NUMBER;
l_dup_reln_id   NUMBER;
l_request_id    NUMBER;
l_from_last_upd_date DATE;
l_to_last_upd_date DATE;
l_from_party_reln_type VARCHAR2(255);
l_merge_to_id NUMBER;
l_temp NUMBER;
from_start_date date;
from_end_date date;
--Bug 2619913 Do not allow self relationships creation unless
--defined in the relationship type table

l_object_id NUMBER;
l_rel_type HZ_RELATIONSHIPS.RELATIONSHIP_TYPE%TYPE;
l_rel_code HZ_RELATIONSHIPS.RELATIONSHIP_CODE%TYPE;
l_subject_type HZ_RELATIONSHIPS.SUBJECT_TYPE%TYPE;
l_object_type HZ_RELATIONSHIPS.OBJECT_TYPE%TYPE;
l_self_rel_flag VARCHAR2(1);

l_rel_party_id        HZ_RELATIONSHIPS.PARTY_ID%TYPE;
l_new_subj_party_name HZ_PARTIES.PARTY_NAME%TYPE;
l_object_name         HZ_PARTIES.PARTY_NAME%TYPE;
l_rel_party_number    HZ_PARTIES.PARTY_NUMBER%TYPE;
from_cont_source    HZ_RELATIONSHIPS.ACTUAL_CONTENT_SOURCE%TYPE; --5404244
from_cont_source_type HZ_ORIG_SYSTEMS_B.ORIG_SYSTEM_TYPE%TYPE;

--6696774 start
l_par_exists          VARCHAR2(1);
l_direction_code      HZ_RELATIONSHIPS.DIRECTION_CODE%TYPE;
--6696774 start END
BEGIN

  IF (x_to_id <> FND_API.G_MISS_NUM AND x_to_id <> p_from_id) THEN

    OPEN c_party(p_from_id);
    FETCH c_party INTO l_from_party_id;
    IF c_party%NOTFOUND THEN
      l_from_party_id := NULL;
    END IF;
    CLOSE c_party;

    OPEN c_party(x_to_id);
    FETCH c_party INTO l_from_party_id;
    IF c_party%NOTFOUND THEN
      l_to_party_id := NULL;
    END IF;
    CLOSE c_party;


    IF l_to_party_id IS NOT NULL AND l_from_party_id IS NOT NULL
       AND l_from_party_id <> l_to_party_id THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_RELN_MERGE_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('FROMID',p_from_id);
      FND_MESSAGE.SET_TOKEN('TOID',x_to_id);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    IF l_from_party_id IS NOT NULL THEN
      OPEN c_to_party_reln;
      UPDATE HZ_RELATIONSHIPS
      SET
        party_id = l_from_party_id,
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        request_id =  hz_utility_pub.request_id,
        program_application_id = hz_utility_pub.program_application_id,
        program_id = hz_utility_pub.program_id,
        program_update_date = sysdate
      WHERE relationship_id = x_to_id;
      CLOSE c_to_party_reln;
    END IF;

    UPDATE HZ_RELATIONSHIPS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE relationship_id = p_from_id;


--4307667 merge usages with owner_table_name 'HZ_RELATIONSHIPS'
    UPDATE hz_party_usg_assignments
    SET status_flag = 'M',
        effective_end_date = trunc(sysdate)
    WHERE owner_table_id = p_from_id
    AND   owner_table_name = 'HZ_RELATIONSHIPS'
    AND   party_id = p_from_fk_id;

    ----Start of DlProject Phase2--------------------
     do_hierarchy_nodes_merge(p_from_id => p_from_id,
			      p_from_fk_id => p_from_fk_id,
			      p_to_fk_id => p_to_fk_id,
			      x_return_status =>x_return_status,
			      p_action => 'M',
			      p_sub_obj_merge =>'SUB'
			      );
    ----End of DlProject Phase2--------------------

  ELSE
    open c_start_end_date;
     fetch c_start_end_date into from_start_date,from_end_date,from_cont_source;
    close c_start_end_date;

    SELECT orig_system_type INTO from_cont_source_type --5404244
    FROM HZ_ORIG_SYSTEMS_B
    WHERE orig_system = from_cont_source;


    OPEN c_check_valid_merge(from_start_date,from_end_date,from_cont_source_type,from_cont_source);

    FETCH c_check_valid_merge INTO l_dup_reln_id, l_request_id;
    IF c_check_valid_merge%FOUND AND
       l_request_id <> hz_utility_pub.request_id THEN
      CLOSE c_check_valid_merge;

      FND_MESSAGE.SET_NAME('AR', 'HZ_RELN_TRANSFER_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('FROMID',p_from_id);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    CLOSE c_check_valid_merge;
--6696774 Start
    SELECT object_id, relationship_type, relationship_code,subject_type,object_type,direction_code into l_object_id, l_rel_type, l_rel_code,
          l_subject_type, l_object_type, l_direction_code
    FROM HZ_RELATIONSHIPS
    WHERE relationship_id = p_from_id
    AND   directional_flag = 'F';

    l_par_exists := 'N';

    BEGIN
          SELECT 'Y' into l_par_exists
          FROM hz_hierarchy_nodes
          WHERE child_id = l_object_id
          AND   parent_id = p_to_fk_id
          AND   l_direction_code = 'C'
          AND rownum = 1;
    EXCEPTION
          WHEN NO_DATA_FOUND THEN
              null;
    END;

    SELECT allow_relate_to_self_flag
    INTO   l_self_rel_flag
    FROM   HZ_RELATIONSHIP_TYPES
    WHERE RELATIONSHIP_TYPE = l_rel_type
    AND FORWARD_REL_CODE = l_rel_code
    AND SUBJECT_TYPE = l_subject_type
    AND OBJECT_TYPE =  l_object_type;

IF (l_object_id <> p_to_fk_id OR l_self_rel_flag = 'Y') AND l_par_exists = 'N' THEN
--6696774 End
    ----Start of DlProject Phase2--------------------
     do_hierarchy_nodes_merge(p_from_id => p_from_id,
			      p_from_fk_id => p_from_fk_id,
			      p_to_fk_id => p_to_fk_id,
			      x_return_status =>x_return_status,
			      p_action => 'T',
			      p_sub_obj_merge =>'SUB'
			      );
    ----End of DlProject Phase2--------------------

    UPDATE HZ_RELATIONSHIPS
    SET
      subject_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE relationship_id = p_from_id
    AND DIRECTIONAL_FLAG = 'F'
    RETURNING  object_id, relationship_type, relationship_code ,
               subject_type, object_type, party_id
    into l_object_id, l_rel_type, l_rel_code,
         l_subject_type , l_object_type, l_rel_party_id;

    UPDATE HZ_RELATIONSHIPS
    SET
      object_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE relationship_id = p_from_id
    AND DIRECTIONAL_FLAG = 'B';

      ---Bug# 2688231 After transferring the reln,the name
      --- of the relationship party should also be changed

     if l_rel_party_id is not null then

      select sub.party_name , obj.party_name , rel.party_number
      into l_new_subj_party_name , l_object_name , l_rel_party_number
      from hz_parties sub , hz_parties obj , hz_parties rel
      where sub.party_id = p_to_fk_id
      and   obj.party_id = l_object_id
      and   rel.party_id = l_rel_party_id;

      UPDATE HZ_PARTIES
      SET PARTY_NAME = 	SUBSTRB(l_new_subj_party_name || '-' ||
                                l_object_name  || '-' ||
                                l_rel_party_number, 1, 360)
      WHERE party_id = l_rel_party_id;

    end if;
     --Check if the object_id and subject_id are same and the
    --6696774 start
     ELSIF (l_object_id = p_to_fk_id AND l_self_rel_flag = 'N') OR l_par_exists = 'Y' THEN  --5591581
     --IF l_object_id = p_to_fk_id THEN
    --6696774 End

       BEGIN

         --check self relationship flag
         SELECT allow_relate_to_self_flag
         INTO   l_self_rel_flag
         FROM   HZ_RELATIONSHIP_TYPES
         WHERE RELATIONSHIP_TYPE = l_rel_type
         AND FORWARD_REL_CODE = l_rel_code
         AND SUBJECT_TYPE = l_subject_type
         AND OBJECT_TYPE =  l_object_type;

       IF    l_self_rel_flag = 'N' THEN
         --Inactivate the relationships both forward and backward
         UPDATE HZ_RELATIONSHIPS
         SET
         STATUS = 'I',
         END_DATE = sysdate,
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login,
         request_id =  hz_utility_pub.request_id,
         program_application_id = hz_utility_pub.program_application_id,
         program_id = hz_utility_pub.program_id,
         program_update_date = sysdate
         WHERE relationship_id = p_from_id;

	      ---Start of Bug:3880218----
	      IF l_rel_party_id is not null THEN
		      UPDATE HZ_PARTIES
		      SET STATUS = 'I',
		          last_update_date = hz_utility_pub.last_update_date,
		          last_updated_by = hz_utility_pub.user_id,
		          last_update_login = hz_utility_pub.last_update_login,
		          request_id =  hz_utility_pub.request_id,
		          program_application_id = hz_utility_pub.program_application_id,
		          program_id = hz_utility_pub.program_id,
		          program_update_date = sysdate
		      WHERE PARTY_ID = l_rel_party_id;
	      END IF;
	      ----End of Bug:3880218----
	 ----Start of DlProject Phase2--------------------
         do_hierarchy_nodes_merge(p_from_id => p_from_id,
			      p_from_fk_id => p_from_fk_id,
			      p_to_fk_id => p_to_fk_id,
			      x_return_status =>x_return_status,
			      p_action => 'I'
			      );
         ----End of DlProject Phase2--------------------
---bug 4867151 start
       ELSE
	        IF l_rel_party_id is not null THEN
		        UPDATE HZ_PARTIES
		        SET STATUS = 'M',
		            last_update_date = hz_utility_pub.last_update_date,
		            last_updated_by = hz_utility_pub.user_id,
		            last_update_login = hz_utility_pub.last_update_login,
		            request_id =  hz_utility_pub.request_id,
		            program_application_id = hz_utility_pub.program_application_id,
		            program_id = hz_utility_pub.program_id,
		            program_update_date = sysdate
		        WHERE PARTY_ID IN (select party_id from hz_relationships where subject_id=p_to_fk_id
	              and object_id=p_to_fk_id and relationship_id <>p_from_id and status='A'
                AND ((start_date between from_start_date and from_end_date)
          or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
          or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date)));

	        UPDATE HZ_RELATIONSHIPS
                SET
                STATUS = 'M',
                END_DATE = sysdate,
                last_update_date = hz_utility_pub.last_update_date,
                last_updated_by = hz_utility_pub.user_id,
                last_update_login = hz_utility_pub.last_update_login,
                request_id =  hz_utility_pub.request_id,
                program_application_id = hz_utility_pub.program_application_id,
                program_id = hz_utility_pub.program_id,
                program_update_date = sysdate
                WHERE relationship_id in (select relationship_id from hz_relationships where subject_id=p_to_fk_id
	              and object_id=p_to_fk_id and relationship_id <>p_from_id and status='A'
                AND ((start_date between from_start_date and from_end_date)
                or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
                or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date)));

	        END IF;
          do_hierarchy_nodes_merge(p_from_id => p_from_id,
			      p_from_fk_id => p_from_fk_id,
			      p_to_fk_id => p_to_fk_id,
			      x_return_status =>x_return_status,
			      p_action => 'M'
			      );
---bug 4867151 end
      END IF;  --l_self_rel_flag

      EXCEPTION
      WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      END;
    END IF;    --l_object_id = p_to_fk_id




  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_party_reln_subj_merge;

PROCEDURE do_party_relationship_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

CURSOR c_merge_to_party_reln IS
  SELECT relationship_id
  FROM HZ_RELATIONSHIPS --4500011
  WHERE party_id = p_to_fk_id
  AND subject_table_name = 'HZ_PARTIES'
  AND object_table_name = 'HZ_PARTIES'
  AND directional_flag = 'F';

l_to_preln_id NUMBER;


BEGIN

  OPEN c_merge_to_party_reln;
  FETCH c_merge_to_party_reln INTO l_to_preln_id;
  IF c_merge_to_party_reln%NOTFOUND THEN
    CLOSE c_merge_to_party_reln;
    FND_MESSAGE.SET_NAME('AR', 'HZ_NO_MERGE_TO_PRELN');
    FND_MESSAGE.SET_TOKEN('TOPARTYID',p_to_fk_id);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    CLOSE c_merge_to_party_reln;

    UPDATE HZ_RELATIONSHIPS
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE relationship_id = p_from_id;
    ----Start of DlProject Phase2--------------------
     do_hierarchy_nodes_merge(p_from_id => p_from_id,
			      p_from_fk_id => p_from_fk_id,
			      p_to_fk_id => p_to_fk_id,
			      x_return_status =>x_return_status,
			      p_action => 'M'
			      );
    ----End of DlProject Phase2--------------------


    --For NOCOPY fix
    x_to_id := l_to_preln_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_party_relationship_merge;

PROCEDURE do_org_profile_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

CURSOR c_merge_to_org_prof(cp_cont_source VARCHAR2) IS
  SELECT organization_profile_id, last_update_date, duns_number_c
  FROM HZ_ORGANIZATION_PROFILES
  WHERE party_id = p_to_fk_id
  AND effective_end_date is null
  AND ACTUAL_CONTENT_SOURCE = cp_cont_source;

CURSOR c_cont_source IS
  SELECT ACTUAL_CONTENT_SOURCE, last_update_date, duns_number_c
  FROM HZ_ORGANIZATION_PROFILES
  WHERE organization_profile_id = p_from_id;

l_cont_source VARCHAR2(50);
l_to_orgpro_id NUMBER;
l_merge_to_id NUMBER := FND_API.G_MISS_NUM;
l_from_last_upd_date DATE;
l_to_last_upd_date DATE;
l_from_duns_number VARCHAR2(255);
l_to_duns_number VARCHAR2(255);
l_from_branch_flag VARCHAR2(1);
l_to_branch_flag VARCHAR2(1);
l_temp NUMBER;

l_msg_data VARCHAR2(2000);
l_msg_count NUMBER;
l_return_status VARCHAR2(255);


l_temp_party_id NUMBER;
l_temp_party_number VARCHAR2(255);

l_organization_rec HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
BEGIN

  OPEN c_cont_source;
  FETCH c_cont_source INTO l_cont_source, l_from_last_upd_date, l_from_duns_number;
  CLOSE c_cont_source;

  IF l_cont_source = 'USER_ENTERED' THEN
    open c_merge_to_org_prof('USER_ENTERED');
    FETCH c_merge_to_org_prof INTO x_to_id, l_to_last_upd_date, l_to_duns_number;
    IF c_merge_to_org_prof%NOTFOUND THEN
      CLOSE c_merge_to_org_prof;
      OPEN c_merge_to_org_prof('SST');
      FETCH c_merge_to_org_prof INTO x_to_id, l_to_last_upd_date, l_to_duns_number;
      IF c_merge_to_org_prof%NOTFOUND THEN
        CLOSE c_merge_to_org_prof;
        FND_MESSAGE.SET_NAME('AR', 'HZ_NO_MERGE_TO_ORGPRO');
        FND_MESSAGE.SET_TOKEN('ToId',p_to_fk_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
      CLOSE c_merge_to_org_prof;
    ELSE
      CLOSE c_merge_to_org_prof;
    END IF;

  ELSIF l_cont_source = 'SST' THEN
    open c_merge_to_org_prof('SST');
    FETCH c_merge_to_org_prof INTO x_to_id, l_to_last_upd_date, l_to_duns_number;
    IF c_merge_to_org_prof%NOTFOUND THEN
      CLOSE c_merge_to_org_prof;
      OPEN c_merge_to_org_prof('USER_ENTERED');
      FETCH c_merge_to_org_prof INTO x_to_id, l_to_last_upd_date, l_to_duns_number;
      IF c_merge_to_org_prof%NOTFOUND THEN
        CLOSE c_merge_to_org_prof;
        FND_MESSAGE.SET_NAME('AR', 'HZ_NO_MERGE_TO_ORGPRO');
        FND_MESSAGE.SET_TOKEN('ToId',p_to_fk_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
      CLOSE c_merge_to_org_prof;
    ELSE
      CLOSE c_merge_to_org_prof;
    END IF;

  ELSIF l_cont_source NOT IN ('SST','USER_ENTERED')AND l_cont_source IS NOT NULL THEN --Bug No:4114254
    IF x_to_id IS NULL OR x_to_id = FND_API.G_MISS_NUM THEN
      HZ_PARTY_V2PUB.get_organization_rec(
        FND_API.G_FALSE,
        p_from_fk_id,
        l_cont_source,
        l_organization_rec,
        l_return_status,
        l_msg_count,
        l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;

      l_organization_rec.party_rec.party_id := p_to_fk_id;
      HZ_PARTY_V2PUB.create_organization(
        FND_API.G_FALSE,
        l_organization_rec,
        l_return_status,
        l_msg_count,
        l_msg_data,
        l_temp_party_id,
        l_temp_party_number,
        x_to_id);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  UPDATE HZ_ORGANIZATION_PROFILES
  SET
      STATUS = 'M',
      effective_end_date = trunc(SYSDATE-1),
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
  WHERE organization_profile_id = p_from_id;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_org_profile_merge;

PROCEDURE do_per_profile_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

CURSOR c_merge_to_per_prof(cp_cont_source VARCHAR2) IS
  SELECT person_profile_id
  FROM HZ_PERSON_PROFILES
  WHERE party_id = p_to_fk_id
  AND effective_end_date is null
  AND content_source_type = cp_cont_source;

CURSOR c_cont_source IS
  SELECT CONTENT_SOURCE_TYPE
  FROM HZ_PERSON_PROFILES
  WHERE person_profile_id = p_from_id;

l_cont_source VARCHAR2(50);
l_to_perpro_id NUMBER;

BEGIN

  OPEN c_cont_source;
  FETCH c_cont_source INTO l_cont_source;
  CLOSE c_cont_source;

  OPEN c_merge_to_per_prof(l_cont_source);
  FETCH c_merge_to_per_prof INTO l_to_perpro_id;
  IF c_merge_to_per_prof%NOTFOUND THEN
    CLOSE c_merge_to_per_prof;
    IF l_cont_source = 'USER_ENTERED' THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_NO_MERGE_TO_PERPRO');
      FND_MESSAGE.SET_TOKEN('ToId',p_to_fk_id);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      UPDATE HZ_PERSON_PROFILES
      SET
        party_id  = p_to_fk_id,
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        request_id =  hz_utility_pub.request_id,
        program_application_id = hz_utility_pub.program_application_id,
        program_id = hz_utility_pub.program_id,
        program_update_date = sysdate
      WHERE person_profile_id = p_from_id;
    END IF;
  ELSE
    CLOSE c_merge_to_per_prof;

    UPDATE HZ_PERSON_PROFILES
    SET
      STATUS = 'M',
      effective_end_date = trunc(SYSDATE-1),
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE person_profile_id = p_from_id;

    --For NOCOPY fix
    x_to_id := l_to_perpro_id;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_per_profile_merge;

PROCEDURE do_party_site_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

CURSOR c_cont_source IS
  SELECT l.CONTENT_SOURCE_TYPE, l.last_update_date, ps.party_id,
         ps.identifying_address_flag, ps.party_site_number
  FROM HZ_LOCATIONS l, HZ_PARTY_SITES ps
  WHERE ps.party_site_id = p_from_id
  AND ps.location_id = l.location_id;

CURSOR c_merge_to IS
  SELECT ps.party_id, loc.content_source_type,loc.country,
         loc.address1, loc.address2, loc.address3, loc.address4,
	 loc.city, loc.postal_code, loc.state, loc.province,
	 loc.county,loc.location_id
  FROM HZ_LOCATIONS loc, HZ_PARTY_SITES ps
  WHERE ps.party_site_id = x_to_id
  AND   ps.location_id   = loc.location_id;
--bug 4569674
/*CURSOR c_loc_assignments IS
   SELECT la.loc_id, la.org_id
   FROM   HZ_LOC_ASSIGNMENTS la, HZ_PARTY_SITES ps
   WHERE  ps.party_site_id = p_from_id
   AND  la.location_id = ps.location_id
   AND  la.org_id NOT IN ( SELECT DISTINCT la1.org_id
                           FROM  HZ_LOC_ASSIGNMENTS la1, HZ_PARTY_SITES ps1
                           WHERE ps1.party_site_id = x_to_id
                           AND la1.location_id = ps1.location_id
                         );
*/
CURSOR c_locations(x_party_site_id NUMBER) IS
 SELECT loc.location_id
   FROM HZ_PARTY_SITES ps,
        HZ_LOCATIONS   loc
  WHERE ps.location_id   = loc.location_id
   AND  ps.party_site_id = x_party_site_id;

CURSOR c_from_party_type IS
 SELECT party_type
  FROM  HZ_PARTY_SITES ps,
        HZ_PARTIES  p
  WHERE ps.party_id      = p.party_id
   AND  ps.party_site_id = p_from_id;

l_from_last_upd_date DATE;
l_to_last_upd_date DATE;
l_cont_source HZ_LOCATIONS.CONTENT_SOURCE_TYPE%TYPE;
l_cont_source_to HZ_LOCATIONS.CONTENT_SOURCE_TYPE%TYPE;
l_location_id HZ_LOCATIONS.LOCATION_ID%TYPE;
l_address1 HZ_LOCATIONS.ADDRESS1%TYPE;
l_address2 HZ_LOCATIONS.ADDRESS2%TYPE;
l_address3 HZ_LOCATIONS.ADDRESS3%TYPE;
l_address4 HZ_LOCATIONS.ADDRESS4%TYPE;
l_country  HZ_LOCATIONS.COUNTRY%TYPE;
l_city     HZ_LOCATIONS.CITY%TYPE;
l_state    HZ_LOCATIONS.STATE%TYPE;
l_county   HZ_LOCATIONS.COUNTY%TYPE;
l_province HZ_LOCATIONS.PROVINCE%TYPE;
l_postal   HZ_LOCATIONS.POSTAL_CODE%TYPE;
l_from_party_id HZ_PARTY_SITES.PARTY_ID%TYPE;
l_to_party_id   HZ_PARTY_SITES.PARTY_ID%TYPE;
l_ident_flag    HZ_PARTY_SITES.IDENTIFYING_ADDRESS_FLAG%TYPE;
l_merge_to_id NUMBER;
l_merge_to_loc_id NUMBER;
l_temp NUMBER;
l_temp1 NUMBER;

l_dup_exists    VARCHAR2(20);
l_to_id 	NUMBER;

l_discard VARCHAR2(1) := 'N';

party_site_rec                 HZ_PARTY_SITE_V2PUB.party_site_rec_type;
l_party_site_number            VARCHAR2(30);
l_msg_data                     VARCHAR2(2000);
l_msg_count                    NUMBER := 0;
l_profile_option               VARCHAR2(1) := 'Y';

l_ps_number HZ_PARTY_SITES.PARTY_SITE_NUMBER%TYPE;
l_actual_cont_source VARCHAR2(30);
--l_loc_id HZ_LOC_ASSIGNMENTS.LOC_ID%TYPE;   bug 4569674
--l_org_id HZ_LOC_ASSIGNMENTS.ORG_ID%TYPE;
l_from_location_id HZ_LOCATIONS.LOCATION_ID%TYPE;
l_to_location_id   HZ_LOCATIONS.LOCATION_ID%TYPE;
l_from_party_type  HZ_PARTIES.PARTY_TYPE%TYPE;
to_party_loc_id    HZ_LOCATIONS.LOCATION_ID%TYPE;
map_ps_id          HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;
BEGIN


  OPEN c_cont_source;
  FETCH c_cont_source INTO l_cont_source, l_from_last_upd_date, l_from_party_id,
                           l_ident_flag, l_ps_number;
  CLOSE c_cont_source;

  /* From Location_Id */
  OPEN  c_locations(p_from_id);
  FETCH c_locations INTO l_from_location_id;
  CLOSE c_locations;

  /* From Party_Type */
  OPEN  c_from_party_type;
  FETCH c_from_party_type INTO l_from_party_type;
  CLOSE c_from_party_type;

  IF l_from_party_type = 'PARTY_RELATIONSHIP' AND
     (x_to_id = FND_API.G_MISS_NUM OR x_to_id IS NULL OR p_from_id = x_to_id)
  THEN
   BEGIN

       /* Check if there is a ps in the merge batch that has the same loc */
       SELECT ps2.location_id INTO to_party_loc_id
        FROM  HZ_MERGE_PARTY_DETAILS mpd,
              HZ_PARTY_SITES         ps1,
              HZ_PARTY_SITES         ps2
       WHERE  ps1.party_site_id         =  mpd.merge_from_entity_id
         AND  ps2.party_site_id         =  mpd.merge_to_entity_id
         AND  mpd.merge_from_entity_id  <> nvl(mpd.merge_to_entity_id, -1)
         AND  ps1.location_id           =  l_from_location_id
         AND  merge_from_entity_id      <> p_from_id
         AND  mpd.batch_party_id        IN ( SELECT  batch_party_id
                                               FROM  hz_merge_parties mp,
                                                     hz_relationships r
                                               WHERE r.party_id       = p_from_fk_id
                                                AND  mp.from_party_id = r.object_id
                                                AND  mp.batch_id      = p_batch_id)
         AND  rownum                    =  1;

      BEGIN
          /* Check if to_party already has a ps which has the same loc */
          SELECT  party_site_id INTO map_ps_id
            FROM  HZ_PARTY_SITES
           WHERE  party_id    = p_to_fk_id
             AND  location_id = to_party_loc_id
             AND  rownum      = 1;

          /* Merge */
          x_to_id  := map_ps_id;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
               /* Transfer */
               UPDATE HZ_PARTY_SITES
                  SET LOCATION_ID   = to_party_loc_id
                WHERE PARTY_SITE_ID = p_from_id ;
      END;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --NULL;
         -- Start changes for Bug 4577535

         l_dup_exists := HZ_MERGE_DUP_CHECK.check_address_dup(
	 	 	 l_from_location_id,l_to_id, p_from_fk_id, p_to_fk_id,
	 	         x_return_status);
	 /* Merge */
	 IF l_dup_exists = FND_API.G_TRUE THEN
	    x_to_id  := l_to_id;
	 END IF;

	 WHEN OTHERS THEN
	      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
	      FND_MSG_PUB.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	 -- End changes for Bug 4577535
   END;
  END IF;

 IF x_to_id <> FND_API.G_MISS_NUM AND x_to_id IS NOT NULL
 THEN

    IF l_from_party_type <> 'PARTY_RELATIONSHIP' THEN
       /* To Location_Id */
       OPEN  c_locations(x_to_id);
       FETCH c_locations INTO l_to_location_id;
       CLOSE c_locations;

       UPDATE HZ_PARTY_SITES
         SET  location_id = l_to_location_id
        WHERE party_site_id IN (
              SELECT psr.party_site_id
                FROM hz_parties       p,
                     hz_party_sites   psr,
                     hz_party_sites   pso,
                     hz_relationships r
              WHERE  pso.party_site_id = p_from_id
                AND  r.object_id       = pso.party_id
                AND  r.party_id        = p.party_id
                AND  p.party_id        = psr.party_id
                AND  psr.location_id   = l_from_location_id);
   END IF;


/* Bug 2295088: Unset identifying_address_flag of the from site
   if 2 sites of the same party are being merged. */

  OPEN c_merge_to;
  FETCH c_merge_to INTO l_to_party_id, l_cont_source_to, l_country, l_address1,
        l_address2, l_address3, l_address4, l_city, l_postal, l_state,
        l_province, l_county,l_location_id;
  CLOSE c_merge_to;

  IF (l_from_party_id = l_to_party_id )THEN
      IF(l_ident_flag = 'Y') THEN
        IF l_cont_source_to = 'USER_ENTERED' THEN
           UPDATE hz_parties
           SET    country     = l_country,
                  address1    = l_address1,
                  address2    = l_address2,
                  address3    = l_address3,
                  address4    = l_address4,
                  city        = l_city,
                  postal_code = l_postal,
                  state       = l_state,
                  province    = l_province,
                  county      = l_county
           WHERE party_id     = l_to_party_id;

        END IF;

		UPDATE HZ_PARTY_SITES
		SET
	   	identifying_address_flag = 'Y'
		WHERE party_site_id = x_to_id;

		UPDATE HZ_PARTY_SITES
		SET
	   	identifying_address_flag = 'N'
		WHERE party_site_id = p_from_id;

   	END IF;
        UPDATE hz_parties
           SET    country     = l_country,
                  address1    = l_address1,
                  address2    = l_address2,
                  address3    = l_address3,
                  address4    = l_address4,
                  city        = l_city,
                  postal_code = l_postal,
                  state       = l_state,
                  province    = l_province,
                  county      = l_county
           WHERE party_id in
		   			   (select ps.party_id from hz_party_sites ps,hz_relationships pr
                        where ps.location_id = l_to_location_id
						and ps.identifying_address_flag(+)='Y'
						and ps.party_id = pr.party_id
                        and pr.object_id=l_to_party_id);
  END IF;
--bug 4569674 commenting code that creates missing Loc Assignments
  /* Bug Fix : 2506620. Create Missing Loc Assignments */
/*  Open c_loc_assignments;
  Loop
  fetch c_loc_assignments into l_loc_id,l_org_id ;
  IF c_loc_assignments%NOTFOUND THEN
     EXIT;
  END IF;
  HZ_LOC_ASSIGNMENTS_PKG.Insert_Row (
                X_LOCATION_ID                           => l_location_id,
                X_LOC_ID                                => l_loc_id,
                X_ORG_ID                                => l_org_id,
                X_OBJECT_VERSION_NUMBER                 => 1,
                X_CREATED_BY_MODULE                     => 'PARTY_MERGE',
                X_APPLICATION_ID                        => 222
            );

   end loop;
   Close c_loc_assignments; */
   END IF; /*  x_to_id  */

   IF ((x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) OR l_discard = 'Y') THEN

    UPDATE HZ_PARTY_SITES
    SET
      STATUS = 'M',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login,
      request_id =  hz_utility_pub.request_id,
      program_application_id = hz_utility_pub.program_application_id,
      program_id = hz_utility_pub.program_id,
      program_update_date = sysdate
    WHERE party_site_id = p_from_id;
    /* Bug 3892399
    UPDATE HZ_ORIG_SYS_REFERENCES
    SET
      STATUS = 'I',
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login
    WHERE owner_table_id = p_from_id and owner_table_name='HZ_PARTY_SITES';
    */
      HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_PARTY_SITES',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;


   --For NOCOPY fix
   IF l_discard = 'Y' THEN
      x_to_id := 0;
   END IF;


  ELSE

    hz_cust_account_merge_v2pvt.get_party_site_rec (
         p_init_msg_list => 'T',
         p_party_site_id => p_from_id,
         x_party_site_rec => party_site_rec,
         x_actual_cont_source => l_actual_cont_source,
         x_return_status => x_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data );

    IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR','Cannot get party site ID : ' || p_from_id);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;

      RETURN;
    END IF;
--bug 4603928
--    l_party_site_number := l_ps_number||'-MERGED';
    IF length(l_ps_number) >= 29 THEN
    l_party_site_number := substr(l_ps_number,1,28)||'-M';
    ELSE
    l_party_site_number := l_ps_number||'-M';
    END IF;
--bug 4603928

    FOR I IN 1..100 LOOP
      BEGIN
        -- Update and set party_id = p_to_fk_id where pk = from_id
        UPDATE HZ_PARTY_SITES
        SET
          STATUS = 'M',
          party_site_number = l_party_site_number,
          last_update_date = hz_utility_pub.last_update_date,
          last_updated_by = hz_utility_pub.user_id,
          last_update_login = hz_utility_pub.last_update_login,
          request_id =  hz_utility_pub.request_id,
          program_application_id = hz_utility_pub.program_application_id,
          program_id = hz_utility_pub.program_id,
          program_update_date = sysdate
        WHERE party_site_id = p_from_id;
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
--bug 4603928
--          l_party_site_number := l_party_site_number || I;
	IF (length(l_party_site_number)+length(I) > 30 ) THEN
	   l_party_site_number := substr(l_party_site_number,1,length(l_party_site_number)-length(I))|| I;
	ELSE
	   l_party_site_number := l_party_site_number || I;
	END IF;
--bug 4603928
      END;
    END LOOP;
    /*HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_PARTY_SITES',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;*/

    l_party_site_number := null;
    party_site_rec.party_site_id := FND_API.G_MISS_NUM;
    party_site_rec.party_id := p_to_fk_id;
    party_site_rec.party_site_number := l_ps_number;

    --We should not set primary flag in customer merge context
    party_site_rec.identifying_address_flag := FND_API.G_MISS_CHAR;

    --Create new party site.
    hz_cust_account_merge_v2pvt.create_party_site(
           p_init_msg_list => 'T',
           p_party_site_rec => party_site_rec,
           p_actual_cont_source => l_actual_cont_source,
           x_party_site_id => x_to_id,
           x_party_site_number => l_party_site_number,
           x_return_status => x_return_status,
           x_msg_count => l_msg_count,
           x_msg_data => l_msg_data );


    IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR','Cannot copy party site for ID : ' || p_from_id);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;

    HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	                p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_PARTY_SITES',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;

    UPDATE hz_merge_party_details
    SET merge_to_entity_id = x_to_id
    WHERE batch_party_id IN (select batch_party_id from hz_merge_parties
                             where batch_id = p_batch_id)
    AND merge_to_entity_id = p_from_id
    AND entity_name = 'HZ_PARTY_SITES';

    SAVEPOINT party_site_sync;
    BEGIN
      HZ_STAGE_MAP_TRANSFORM.sync_single_party_site(x_to_id,'C');
      DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE
      RECORD_ID=x_to_id and entity='PARTY_SITES' AND STAGED_FLAG='N';
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO party_site_sync;
    END;

    x_return_status := 'N';

  END IF;

  DELETE FROM HZ_DQM_SYNC_INTERFACE WHERE record_id = p_from_id
  AND ENTITY = 'PARTY_SITES' AND STAGED_FLAG='N';

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_party_site_merge;


PROCEDURE do_party_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id    	IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN	NUMBER,
        x_return_status IN OUT NOCOPY  	VARCHAR2
) IS

CURSOR c_party_type(cp_party_id NUMBER) IS
  SELECT party_type
  FROM HZ_PARTIES
  WHERE party_id = cp_party_id;

CURSOR c_duns IS
  SELECT duns_number_c, last_update_date, organization_profile_id
  FROM HZ_ORGANIZATION_PROFILES
  WHERE party_id = p_from_id
  AND   EFFECTIVE_END_DATE IS NULL
  AND   actual_content_source = 'DNB'
  AND   nvl(status, 'A') = 'A';

CURSOR c_duns1 IS
  SELECT duns_number_c , last_update_date, organization_profile_id
  FROM HZ_ORGANIZATION_PROFILES
  WHERE party_id = x_to_id
  AND   EFFECTIVE_END_DATE IS NULL
  AND   actual_content_source = 'DNB'
  AND   nvl(status, 'A') = 'A';

CURSOR c_branch IS
   SELECT 1
   FROM HZ_RELATIONSHIPS   --4500011
   WHERE content_source_type = 'DNB'
   AND subject_id = p_from_id
   AND object_id = x_to_id
   AND RELATIONSHIP_CODE = 'HEADQUARTERS_OF'
   AND subject_table_name = 'HZ_PARTIES'
   AND object_table_name = 'HZ_PARTIES'
   AND directional_flag = 'F';

l_from_party_type HZ_PARTIES.PARTY_TYPE%TYPE;
l_to_party_type HZ_PARTIES.PARTY_TYPE%TYPE;
l_from_duns_number VARCHAR2(255);
l_to_duns_number VARCHAR2(255);
l_temp NUMBER;

l_to_is_branch VARCHAR2(1) := 'N';

case1 BOOLEAN := FALSE;
case2 BOOLEAN := FALSE;
case3 BOOLEAN := FALSE;

l_from NUMBER;
l_to NUMBER;
l_to_loc_id NUMBER;
l_to_subj_id NUMBER;

l_to_profile_id NUMBER;
l_from_profile_id NUMBER;
l_from_last_upd_date DATE;
l_to_last_upd_date DATE;

l_msg_data VARCHAR2(2000);
l_msg_count NUMBER;
l_return_status VARCHAR2(255);
l_obj_version_number NUMBER;

l_organization_rec HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;

BEGIN

  -- Select record for update
  OPEN c_party_type(p_from_id);
  FETCH c_party_type INTO l_from_party_type;
  CLOSE c_party_type;

  OPEN c_party_type(x_to_id);
  FETCH c_party_type INTO l_to_party_type;
  CLOSE c_party_type;

  IF l_from_party_type IS NULL OR l_to_party_type IS NULL OR
     l_to_party_type <> l_from_party_type THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_PARTIES');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Update  and set status to merged
  UPDATE HZ_PARTIES
  SET
    STATUS = 'M',
    last_update_date = hz_utility_pub.last_update_date,
    last_updated_by = hz_utility_pub.user_id,
    last_update_login = hz_utility_pub.last_update_login,
    request_id =  hz_utility_pub.request_id,
    program_application_id = hz_utility_pub.program_application_id,
    program_id = hz_utility_pub.program_id,
    program_update_date = sysdate
  WHERE party_id = p_from_id;

  UPDATE HZ_DQM_SYNC_INTERFACE
  SET party_id = x_to_id WHERE STAGED_FLAG='N'
  AND PARTY_ID = p_from_id AND ENTITY<>'PARTY';

   HZ_ORIG_SYSTEM_REF_PVT.remap_internal_identifier(
                    p_init_msg_list => FND_API.G_FALSE,
                    p_validation_level     => FND_API.G_VALID_LEVEL_NONE,
                    p_old_owner_table_id   => p_from_id,
	            p_new_owner_table_id   => x_to_id,
                    p_owner_table_name  =>'HZ_PARTIES',
                    p_orig_system => null,
                    p_orig_system_reference => null,
                    p_reason_code => 'MERGED',
                    x_return_status => x_return_status,
                    x_msg_count =>l_msg_count,
                    x_msg_data  =>l_msg_data);
      IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
	FND_MESSAGE.SET_TOKEN('ERROR','MOSR: cannot remap internal ID');
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
      END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END do_party_merge;

PROCEDURE do_displayed_duns_merge(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  UPDATE HZ_ORGANIZATION_PROFILES
  SET
    displayed_duns_party_id = p_to_fk_id,
    last_update_date = hz_utility_pub.last_update_date,
    last_updated_by = hz_utility_pub.user_id,
    last_update_login = hz_utility_pub.last_update_login,
    request_id =  hz_utility_pub.request_id,
    program_application_id = hz_utility_pub.program_application_id,
    program_id = hz_utility_pub.program_id,
    program_update_date = sysdate
  WHERE organization_profile_id = p_from_id;


EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_displayed_duns_merge;


PROCEDURE insert_request_log(
        p_source_party_id       IN      NUMBER,
        p_destination_party_id  IN      NUMBER
) IS

        l_requested_product     VARCHAR2(100);
        l_duns_number           NUMBER;

BEGIN

--Insert a row in HZ_DNB_REQUEST_LOG table.
    SELECT requested_product, duns_number
    INTO   l_requested_product, l_duns_number
    FROM   hz_dnb_request_log
    WHERE  party_id = p_source_party_id
    AND    request_id = (
               SELECT MAX(request_id)
               FROM   hz_dnb_request_log
               WHERE  party_id = p_source_party_id
               AND    status = 'S' );

    INSERT INTO hz_dnb_request_log(
       REQUEST_ID,
       PARTY_ID,
       REQUESTED_PRODUCT,
       DUNS_NUMBER,
       STATUS,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       COPIED_FROM_PARTY_ID )
    VALUES(
       HZ_DNB_REQUEST_LOG_S.nextval,
       p_destination_party_id,
       l_requested_product,
       l_duns_number,
       'S',
       hz_utility_pub.CREATED_BY,
       hz_utility_pub.CREATION_DATE,
       hz_utility_pub.LAST_UPDATED_BY,
       hz_utility_pub.LAST_UPDATE_DATE,
       hz_utility_pub.LAST_UPDATE_LOGIN,
       p_source_party_id );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
END insert_request_log;

 --
  -- PRIVATE PROCEDURE do_denormalize_contact_point
  --
  -- DESCRIPTION
  --   Private procedure to denormalize some type of contact point to hz_parties.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_id                     Party ID.
  --     p_contact_point_type           Contact point type.
  --     p_url                          URL.
  --     p_email_address                Email address.
  --     p_phone_contact_pt_id		Contact point id.
  --     p_phone_purpose		Contact Point Purpose.
  --     p_phone_line_type		Phone line type.
  --     p_phone_country_code		Phone country code.
  --     p_phone_area_code		Phone area code.
  --     p_phone_number			Phone Number.
  --     p_phone_extension		Phone extension.
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   08-19-2003    Ramesh.Ch           o Created.
  --
  --

  PROCEDURE do_denormalize_contact_point (
    p_party_id				    IN     NUMBER,
    p_contact_point_type		    IN     VARCHAR2,
    p_url				    IN     VARCHAR2,
    p_email_address			    IN     VARCHAR2,
    p_phone_contact_pt_id		    IN     NUMBER,
    p_phone_purpose			    IN     VARCHAR2,
    p_phone_line_type			    IN     VARCHAR2,
    p_phone_country_code		    IN     VARCHAR2,
    p_phone_area_code			    IN     VARCHAR2,
    p_phone_number			    IN     VARCHAR2,
    p_phone_extension			    IN     VARCHAR2
  ) IS
  BEGIN

    IF p_contact_point_type = 'WEB' THEN
      UPDATE hz_parties
      SET    url		       = p_url,
             last_update_date          = hz_utility_v2pub.last_update_date,
	     last_updated_by           = hz_utility_v2pub.last_updated_by,
	     last_update_login         = hz_utility_v2pub.last_update_login,
	     request_id                = hz_utility_v2pub.request_id,
	     program_application_id    = hz_utility_v2pub.program_application_id,
	     program_id                = hz_utility_v2pub.program_id,
	     program_update_date       = sysdate
      WHERE  party_id = p_party_id;
    ELSIF p_contact_point_type = 'EMAIL' THEN
      UPDATE hz_parties
      SET    email_address	       = p_email_address,
             last_update_date          = hz_utility_v2pub.last_update_date,
	     last_updated_by           = hz_utility_v2pub.last_updated_by,
	     last_update_login         = hz_utility_v2pub.last_update_login,
	     request_id                = hz_utility_v2pub.request_id,
	     program_application_id    = hz_utility_v2pub.program_application_id,
	     program_id                = hz_utility_v2pub.program_id,
	     program_update_date       = sysdate
      WHERE  party_id = p_party_id;
    ELSIF p_contact_point_type = 'PHONE' THEN
      UPDATE hz_parties
      SET    primary_phone_contact_pt_id       = p_phone_contact_pt_id,
             primary_phone_purpose             = p_phone_purpose,
	     primary_phone_line_type           = p_phone_line_type,
	     primary_phone_country_code        = p_phone_country_code,
	     primary_phone_area_code           = p_phone_area_code,
	     primary_phone_number              = p_phone_number,
	     primary_phone_extension           = p_phone_extension,
             last_update_date          = hz_utility_v2pub.last_update_date,
	     last_updated_by           = hz_utility_v2pub.last_updated_by,
	     last_update_login         = hz_utility_v2pub.last_update_login,
	     request_id                = hz_utility_v2pub.request_id,
	     program_application_id    = hz_utility_v2pub.program_application_id,
	     program_id                = hz_utility_v2pub.program_id,
	     program_update_date       = sysdate
      WHERE  party_id = p_party_id;
    END IF;


  END do_denormalize_contact_point;

  PROCEDURE do_hierarchy_nodes_merge(p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
				     p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
				     p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
				     x_return_status IN  OUT NOCOPY          VARCHAR2,
				     p_action	     IN	     VARCHAR2,
				     p_sub_obj_merge IN	     VARCHAR2 :=FND_API.G_MISS_CHAR
				    )
  IS
CURSOR c_hier_flag(cp_rel_type VARCHAR2) IS
  SELECT HIERARCHICAL_FLAG, MULTIPLE_PARENT_ALLOWED --5547536
  FROM   HZ_RELATIONSHIP_TYPES
  WHERE  RELATIONSHIP_TYPE = cp_rel_type
  AND    ROWNUM = 1;

CURSOR c_relship_det(cp_relship_id NUMBER) IS
  SELECT relationship_type,subject_id,subject_table_name,subject_type,
         object_id,object_table_name,object_type,start_date,
	 direction_code,status,end_date
  FROM HZ_RELATIONSHIPS
  WHERE  relationship_id = cp_relship_id
  AND DIRECTIONAL_FLAG = 'F';

--5547536

CURSOR check_parent_exists(cp_rel_type VARCHAR2, cp_child_id NUMBER, cp_table_name VARCHAR2, cp_object_type VARCHAR2) IS
   SELECT parent_id
   FROM hz_hierarchy_nodes
   WHERE child_id = cp_child_id
   AND   child_table_name = cp_table_name
   AND   child_object_type = cp_object_type
   AND   hierarchy_type = cp_rel_type
   AND   effective_end_date > sysdate --bug 6696774
   AND level_number = 1;

l_hierarchical_flag       VARCHAR2(1);
l_hierarchy_rec           HZ_HIERARCHY_PUB.HIERARCHY_NODE_REC_TYPE;
l_subject_id		  NUMBER;
l_object_id              NUMBER;
l_subject_table_name      VARCHAR2(30);
l_object_table_name       VARCHAR2(30);
l_start_date              DATE;
l_direction_code          VARCHAR2(30);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);
l_return_status		  VARCHAR2(10);
l_status		  VARCHAR2(1);
l_rel_type		 HZ_RELATIONSHIPS.RELATIONSHIP_TYPE%TYPE;
l_rel_code		 HZ_RELATIONSHIPS.RELATIONSHIP_CODE%TYPE;
l_subject_type		 HZ_RELATIONSHIPS.SUBJECT_TYPE%TYPE;
l_object_type		 HZ_RELATIONSHIPS.OBJECT_TYPE%TYPE;
from_end_date		date;
--5547536
l_multiple_parent_flag  VARCHAR2(1);
l_from_par_id           NUMBER;
l_to_par_id             NUMBER;

  BEGIN

    OPEN  c_relship_det(p_from_id);
    FETCH c_relship_det INTO l_rel_type,l_subject_id,l_subject_table_name,l_subject_type,
			     l_object_id,l_object_table_name,l_object_type,l_start_date,
			     l_direction_code,l_status,from_end_date;
    CLOSE c_relship_det;
    OPEN  c_hier_flag(l_rel_type);
    FETCH c_hier_flag INTO l_hierarchical_flag, l_multiple_parent_flag;
    CLOSE c_hier_flag;

--5547536
    IF l_hierarchical_flag = 'Y' AND NVL(l_multiple_parent_flag, 'N')='N' AND p_action = 'T' THEN
        IF p_sub_obj_merge = 'OBJ' THEN

          OPEN check_parent_exists(l_rel_type,p_from_fk_id,l_object_table_name,l_object_type);
          FETCH check_parent_exists INTO l_from_par_id;
          CLOSE check_parent_exists;

	  OPEN check_parent_exists(l_rel_type,p_to_fk_id,l_object_table_name,l_object_type);
          FETCH check_parent_exists INTO l_to_par_id;
          CLOSE check_parent_exists;

          IF l_from_par_id IS NOT NULL AND l_to_par_id IS NOT NULL AND l_from_par_id <> l_to_par_id THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_HIER_MERGE_ERROR');
              FND_MESSAGE.SET_TOKEN('PARTIES',p_from_fk_id||', '||p_to_fk_id);
	      FND_MSG_PUB.ADD;
      	      x_return_status := FND_API.G_RET_STS_ERROR;
	      return;
         END IF;

       ELSIF p_sub_obj_merge = 'SUB' THEN

	  OPEN check_parent_exists(l_rel_type,p_from_fk_id,l_subject_table_name,l_subject_type);
          FETCH check_parent_exists INTO l_from_par_id;
          CLOSE check_parent_exists;

          OPEN check_parent_exists(l_rel_type,p_to_fk_id,l_subject_table_name,l_subject_type);
          FETCH check_parent_exists INTO l_to_par_id;
          CLOSE check_parent_exists;

          IF l_from_par_id IS NOT NULL AND l_to_par_id IS NOT NULL AND l_from_par_id <> l_to_par_id THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_HIER_MERGE_ERROR');
              FND_MESSAGE.SET_TOKEN('PARTIES',p_from_fk_id||', '||p_to_fk_id);
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
              return;
         END IF;

       END IF;

    END IF;
--end 5547536

    IF l_hierarchical_flag = 'Y'  THEN
        l_hierarchy_rec.hierarchy_type := l_rel_type;
        l_hierarchy_rec.effective_end_date :=sysdate;
        l_hierarchy_rec.relationship_id := p_from_id;
	IF(p_action = 'M') THEN
          l_hierarchy_rec.status := 'M';
        ELSE
	  l_hierarchy_rec.status := 'I';
	END IF;
	-- check if relationship type is parent one
        IF l_direction_code = 'P' THEN
              -- assign the subject to parent for hierarchy
              l_hierarchy_rec.parent_id := l_subject_id;
              l_hierarchy_rec.parent_table_name := l_subject_table_name;
              l_hierarchy_rec.parent_object_type := l_subject_type;
              l_hierarchy_rec.child_id := l_object_id;
              l_hierarchy_rec.child_table_name := l_object_table_name;
              l_hierarchy_rec.child_object_type := l_object_type;
        ELSIF l_direction_code = 'C' THEN
              -- assign the object to parent
              l_hierarchy_rec.parent_id := l_object_id;
              l_hierarchy_rec.parent_table_name := l_object_table_name;
              l_hierarchy_rec.parent_object_type := l_object_type;
              l_hierarchy_rec.child_id := l_subject_id;
              l_hierarchy_rec.child_table_name := l_subject_table_name;
              l_hierarchy_rec.child_object_type := l_subject_type;

        END IF;
	HZ_HIERARCHY_PUB.update_link(
		    p_init_msg_list           => FND_API.G_FALSE,
		    p_hierarchy_node_rec      => l_hierarchy_rec,
		    x_return_status           => x_return_status,
		    x_msg_count               => l_msg_count,
		    x_msg_data                => l_msg_data
		   );
        IF (p_action = 'T') THEN

	  l_hierarchy_rec.hierarchy_type         := l_rel_type;
          l_hierarchy_rec.effective_start_date   := sysdate;
	  l_hierarchy_rec.effective_end_date     := from_end_date;
	  l_hierarchy_rec.status	         := 'A';
	  l_hierarchy_rec.relationship_id        := p_from_id;
          IF l_direction_code = 'P' THEN
              l_hierarchy_rec.parent_table_name  := l_subject_table_name;
              l_hierarchy_rec.parent_object_type := l_subject_type;
              l_hierarchy_rec.child_table_name   := l_object_table_name;
              l_hierarchy_rec.child_object_type  := l_object_type;
          ELSIF l_direction_code = 'C' THEN
	      l_hierarchy_rec.parent_table_name  := l_object_table_name;
              l_hierarchy_rec.parent_object_type := l_object_type ;
              l_hierarchy_rec.child_table_name   := l_subject_table_name;
              l_hierarchy_rec.child_object_type  := l_subject_type;
	  END IF;

	  IF(p_sub_obj_merge = 'SUB') THEN
	    IF l_direction_code = 'P' THEN
	      l_hierarchy_rec.parent_id := p_to_fk_id;
	      l_hierarchy_rec.child_id  := l_object_id;
	    ELSIF l_direction_code = 'C' THEN
	      l_hierarchy_rec.parent_id := l_object_id;
	      l_hierarchy_rec.child_id  := p_to_fk_id;
	    END IF;
	  ELSIF(p_sub_obj_merge = 'OBJ') THEN
	    IF l_direction_code = 'P' THEN
	      l_hierarchy_rec.parent_id := l_subject_id;
	      l_hierarchy_rec.child_id  := p_to_fk_id;
	    ELSIF l_direction_code = 'C' THEN
	      l_hierarchy_rec.parent_id := p_to_fk_id;
	      l_hierarchy_rec.child_id  := l_subject_id;
	    END IF;
	  END IF;
	  HZ_HIERARCHY_PUB.create_link(
		    p_init_msg_list           => FND_API.G_FALSE,
		    p_hierarchy_node_rec      => l_hierarchy_rec,
		    x_return_status           => l_return_status,
		    x_msg_count               => l_msg_count,
		    x_msg_data                => l_msg_data
	   );

        END IF;

    END IF;

  END;

END HZ_MERGE_PKG;

/
