--------------------------------------------------------
--  DDL for Package Body RRS_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_PARTY_MERGE_PKG" as
/* $Header: RRSPMRGB.pls 120.3 2005/12/15 06:39 pfarkade noship $ */
--========================================================================
  -- PROCEDURE :merge_site_party
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id			Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	        Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			Returns the staus of call
 --
 -- COMMENT   : Merge of Real Estate party with another Real Estate or Non-Real Estate party is not allowed.
 --             When an External Party is getting merged update the records in RRS_SITES_B.
 --========================================================================
PROCEDURE MERGE_SITE_PARTY(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN             NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY VARCHAR2) IS


Cursor c_sites(c_party_id NUMBER,c_site_type VARCHAR2) IS
SELECT 1 FROM dual
WHERE EXISTS(
SELECT site_party_id
FROM rrs_sites_b
WHERE site_type_code = c_site_type
AND site_party_id = c_party_id);
l_from_sites      NUMBER;
l_to_sites        NUMBER;
l_sites_external  NUMBER;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (p_from_fk_id <> p_to_fk_id) THEN
    IF (p_parent_entity_name = 'HZ_PARTIES') THEN

              OPEN c_sites(p_from_fk_id,'I');
	      FETCH c_sites into l_from_sites;
	        IF ( c_sites%FOUND ) THEN
	        x_return_status := FND_API.G_RET_STS_ERROR;
	        FND_MESSAGE.SET_NAME('RRS','RRS_SITE_NO_FROM_MERGE');
	        FND_MSG_PUB.ADD;
		END IF;
	      CLOSE c_sites;

/*Commented the code as our merge API will be called only when p_from_fk_id is SITE_PARTY_ID.
In this case p_from_fk_id is created from any other system and this check will be effective only when
it is done in the merge API registered by that particular product.*/
	      /*OPEN c_sites(p_to_fk_id,'I');
	        FETCH c_sites into l_to_sites;
		IF ( c_sites%FOUND)  THEN
	        x_return_status := FND_API.G_RET_STS_ERROR;
	        FND_MESSAGE.SET_NAME('RRS','RRS_SITE_NO_TO_MERGE');
	        FND_MSG_PUB.ADD;
	        END IF;
	      CLOSE c_sites;*/

	     OPEN c_sites(p_from_fk_id,'E');
	        FETCH c_sites into l_sites_external;
	        IF (c_sites%FOUND)  THEN
	        UPDATE  rrs_sites_b
		SET	site_party_id =  p_to_fk_id,
		        last_update_date = SYSDATE,
			last_updated_by	= FND_GLOBAL.user_id,
			last_update_login = FND_GLOBAL.user_id
		WHERE   site_party_id =  p_from_fk_id;
                END IF;
               CLOSE c_sites;

    END IF;
  END IF;

EXCEPTION WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
  FND_MSG_PUB.ADD;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END MERGE_SITE_PARTY;
 --========================================================================
  -- PROCEDURE :merge_le_party
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id			Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	        Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			Returns the staus of call
 --
 -- COMMENT   : When an Legal Entity Party is getting merged update the records in RRS_SITES_B.
 --========================================================================

PROCEDURE  MERGE_LE_PARTY(
p_entity_name			IN	VARCHAR2,
p_from_id			IN	NUMBER,
p_to_id				IN	NUMBER,
p_from_fk_id			IN	NUMBER,
p_to_fk_id			IN	NUMBER,
p_parent_entity_name	        IN	VARCHAR2,
p_batch_id			IN	NUMBER,
p_batch_party_id		IN	NUMBER,
x_return_status			OUT NOCOPY   VARCHAR2) IS

Cursor get_sites_for_update(c_party_id IN NUMBER) IS
SELECT 1 FROM DUAL
WHERE EXISTS(
SELECT le_party_id
FROM rrs_sites_b
WHERE le_party_id = c_party_id);

l_from_site_num NUMBER;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (p_from_fk_id <> p_to_fk_id) THEN
    IF (p_parent_entity_name = 'HZ_PARTIES') THEN

       OPEN get_sites_for_update(p_from_fk_id);
       FETCH get_sites_for_update INTO l_from_site_num;
       IF ( get_sites_for_update%FOUND )  THEN
	UPDATE  rrs_sites_b
	SET	le_party_id =  p_to_fk_id,
	        last_update_date = SYSDATE,
		last_updated_by	=  FND_GLOBAL.user_id,
		last_update_login = FND_GLOBAL.user_id
        WHERE   le_party_id =  p_from_fk_id;
        END IF;
       CLOSE get_sites_for_update;
    END IF;
END IF;
EXCEPTION
WHEN others THEN
	FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
	FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END MERGE_LE_PARTY;

END RRS_PARTY_MERGE_PKG;

/
