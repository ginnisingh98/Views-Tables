--------------------------------------------------------
--  DDL for Package Body IBU_HZ_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_HZ_PERSON" AS
/* $Header: ibuulngb.pls 120.1 2005/09/07 12:04:08 mkcyee noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBU_HZ_PERSON';
--G_CREATED_BY_MODULE VARCHAR2(30) := 'EMAIL SUBSCRIPTION';
G_APPLICATION_ID NUMBER := 672;


/*+====================================================================
| PROCEDURE NAME
|    Update_Person_Language
|
| DESCRIPTION
|  If the API finds a language preference for the given party then it updates
|  the primary indicator to 'N' then it sets the new language as the primary
|  language. If it does not find any language preference for the party then
|  it creates a new one and makes it primary
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -  HZ_PERSON_INFO_V2PUB.create_person_language if no row exists
|    -  HZ_PERSON_INFO_V2PUB.update_person_language if row exists
+======================================================================*/

PROCEDURE Update_Person_Language(
    p_party_id		     IN    NUMBER,
    p_language_name      IN    VARCHAR2,
    p_created_by_module  IN    VARCHAR2,
    x_debug_buf          OUT NOCOPY  VARCHAR2,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR c_party_type (p_party_id number) is
    SELECT PARTY_TYPE
    FROM HZ_PARTIES
    WHERE PARTY_ID = p_party_id;

    CURSOR c_person_party (p_party_id number) is
    SELECT SUBJECT_ID
    FROM HZ_RELATIONSHIPS
    WHERE PARTY_ID = p_party_id
    AND SUBJECT_TYPE = 'PERSON';

    l_per_language_rec   hz_person_info_v2pub.person_language_rec_type;
    l_id                 NUMBER;
    l_per_language_rec2   hz_person_info_v2pub.person_language_rec_type;
    l_language_use_reference_id number;
    l_object_version_number       NUMBER;
    l_party_type         VARCHAR2(100);
    l_person_party       NUMBER;
    l_party_id           NUMBER;

BEGIN

	x_debug_buf := x_debug_buf || 'enter ibu_hz_person.update_person_language';

	x_debug_buf := x_debug_buf || 'finding party type';
	OPEN c_party_type (p_party_id);
	FETCH c_party_type into l_party_type;
	IF c_party_type%NOTFOUND THEN
		x_debug_buf := x_debug_buf || 'party type not found';
	END IF;
	CLOSE c_party_type;

	IF (l_party_type = 'PARTY_RELATIONSHIP') THEN
		x_debug_buf := x_debug_buf || 'party type is relationship';
		OPEN c_person_party (p_party_id);
		FETCH c_person_party into l_person_party;
		IF c_person_party %NOTFOUND THEN
			x_debug_buf := x_debug_buf || 'person party not found';
          ELSE
               l_party_id := l_person_party;
		END IF;
		CLOSE c_person_party;
	ELSE
		x_debug_buf := x_debug_buf || 'person type is person';
		l_party_id := p_party_id;
	END IF;

      FND_MSG_PUB.initialize;

	 SAVEPOINT Update_Person_Language;

  --begin unset primary language indicator
  BEGIN
    SELECT language_use_reference_id, object_version_number
    INTO   l_id, l_object_version_number
    FROM   hz_person_language
    WHERE  party_id=l_party_id and primary_language_indicator='Y';

    l_per_language_rec.primary_language_indicator := 'N';
    l_per_language_rec.language_use_reference_id := l_id;

	x_debug_buf := x_debug_buf || 'Call HZ_PERSON_INFO_V2PUB.update_person_language API to unset primary';

    hz_person_info_v2pub.update_person_language(
            p_person_language_rec => l_per_language_rec,
            p_object_version_number => l_object_version_number,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);

	x_debug_buf := x_debug_buf || ' After Call HZ_PERSON_INFO_V2PUB.update_person_language APIto unset primary';
    EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
  END;
  --end unset primary language indicator

  --begin set primary language indicator
  BEGIN
      SELECT language_use_reference_id, object_version_number
      INTO   l_id, l_object_version_number
      FROM   hz_person_language
      WHERE  party_id=l_party_id
      AND    language_name=p_language_name
      AND    status = 'A';

      l_per_language_rec2.primary_language_indicator := 'Y';
      l_per_language_rec2.language_use_reference_id := l_id;


	x_debug_buf := x_debug_buf || 'Call HZ_PERSON_INFO_V2PUB.update_person_language API to set primary';
     hz_person_info_v2pub.update_person_language(
            p_person_language_rec => l_per_language_rec2,
            p_object_version_number => l_object_version_number,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);

	x_debug_buf := x_debug_buf || 'After Call HZ_PERSON_INFO_V2PUB.update_person_language API to set primary';
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_per_language_rec2.primary_language_indicator := 'Y';
        l_per_language_rec2.party_id := l_party_id;
        l_per_language_rec2.language_name := p_language_name;
        l_per_language_rec2.created_by_module := p_created_by_module;

	x_debug_buf := x_debug_buf || 'Call HZ_PERSON_INFO_V2PUB.create_person_language API to set primary';
        hz_person_info_v2pub.create_person_language(
             p_person_language_rec => l_per_language_rec2,
             x_language_use_reference_id => l_language_use_reference_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);
	x_debug_buf := x_debug_buf || 'Call HZ_PERSON_INFO_V2PUB.create_person_language API to set primary';

    END;
    --end set primary language indicator



    -- standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );

--standard exception catching for main body
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
	x_debug_buf := x_debug_buf || 'G_EXC_ERROR exception';
	x_debug_buf := x_debug_buf || 'x_msg_count ' || to_char(x_msg_count);
	x_debug_buf := x_debug_buf || 'x_msg_data ' || x_msg_data;
	x_debug_buf := x_debug_buf || 'error code : '|| to_char(SQLCODE);
	x_debug_buf := x_debug_buf || 'error text : '|| SQLERRM;

    ROLLBACK TO Update_Person_Language;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );

	x_debug_buf := x_debug_buf || 'G_EXC_UNEXPECTED_ERROR exception';
	x_debug_buf := x_debug_buf || 'x_msg_count ' || to_char(x_msg_count);
	x_debug_buf := x_debug_buf || 'x_msg_data ' || x_msg_data;
	x_debug_buf := x_debug_buf || 'error code : '|| to_char(SQLCODE);
	x_debug_buf := x_debug_buf || 'error text : '|| SQLERRM;

    ROLLBACK TO Update_Person_Language;

  WHEN OTHERS THEN



    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
	x_debug_buf := x_debug_buf || 'OTHER exception';
	x_debug_buf := x_debug_buf || 'x_msg_count ' || to_char(x_msg_count);
	x_debug_buf := x_debug_buf || 'x_msg_data ' || x_msg_data;
	x_debug_buf := x_debug_buf || 'error code : '|| to_char(SQLCODE);
	x_debug_buf := x_debug_buf || 'error text : '|| SQLERRM;

    ROLLBACK TO Update_Person_Language;

END update_person_language;

END IBU_HZ_PERSON;

/
