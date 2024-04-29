--------------------------------------------------------
--  DDL for Package Body FTE_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_PARTY_MERGE" as
/* $Header: FTEPAMRB.pls 115.1 2004/05/12 23:56:38 arguha noship $ */

PROCEDURE merge_facility_contacts(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       IN  OUT NOCOPY VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'merge_facility_contacts';
   l_count                      NUMBER(10)   := 0;
   l_facility_id                NUMBER       := 0;
   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT merge_reason_code
  INTO   l_merge_reason_code
  FROM   hz_merge_batch
  WHERE  batch_id  = p_batch_id;

  IF l_merge_reason_code = 'DUPLICATE' THEN
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
  ELSE
	 -- if there are any validations to be done, include it in this section
	 null;
  END IF;

   -- If the parent has NOT changed (ie.Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

  IF p_from_fk_id = p_to_fk_id THEN
	 p_to_id := p_from_id;
      RETURN;
  END IF;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- Before transferring check if a similar
   -- dependent record exists on the new parent.

   -- Similar facility is equivalent to same facility
   -- No Duplicate check as one facility can never have more than one
   -- facility contact id

  IF p_from_fk_id <> p_to_fk_id THEN
	    -- obtain lock on records to be updated.
    SELECT facility_id
    INTO   l_facility_id
    FROM   fte_location_parameters
    WHERE  facility_contact_id = p_from_fk_id
    FOR UPDATE NOWAIT;
    IF (p_parent_entity_name = 'HZ_PARTIES') THEN

      UPDATE fte_location_parameters
      SET    facility_contact_id = p_to_fk_id,
             last_update_date = hz_utility_v2pub.last_update_date,
             last_updated_by = hz_utility_v2pub.user_id,
             last_update_login = hz_utility_v2pub.last_update_login,
             request_id =  hz_utility_v2pub.request_id,
             program_application_id = hz_utility_v2pub.program_application_id,
             program_id = hz_utility_v2pub.program_id,
             program_update_date = sysdate
      WHERE  facility_contact_id = p_from_fk_id;

    END IF;

    l_count := sql%rowcount;

  END IF;

EXCEPTION
 WHEN RESOURCE_BUSY THEN
  FND_MESSAGE.SET_NAME('FTE','FTE_FACILITY_LOCK');
  FND_MSG_PUB.ADD;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
 WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
  FND_MSG_PUB.ADD;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_facility_contacts;

END FTE_PARTY_MERGE;

/
