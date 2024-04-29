--------------------------------------------------------
--  DDL for Package Body IMC_BOOKMARK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IMC_BOOKMARK_PUB" AS
/* $Header: imcbmab.pls 120.3 2005/07/07 22:09:54 aalatasi ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IMC_BOOKMARK_PUB';

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/

PROCEDURE create_per_person_party(p_per_person_id  IN    NUMBER,
                                  x_party_id       OUT NOCOPY NUMBER) ;

/* Private function to get party type of a party. Returns NULL if party
   ID does not exist */
FUNCTION Get_Category(
  p_bookmarked_party_id IN NUMBER
) RETURN VARCHAR2
AS
  l_category VARCHAR2(30);
BEGIN

  SELECT party_type
  INTO l_category
  FROM hz_parties
  WHERE party_id = p_bookmarked_party_id;

  IF l_category = 'ORGANIZATION' THEN
    RETURN G_CATEGORY_ORG;
  ELSIF l_category = 'PERSON' THEN
    RETURN G_CATEGORY_PERSON;
  ELSIF l_category = 'PARTY_RELATIONSHIP' THEN
    RETURN G_CATEGORY_REL;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN /* party ID of bookmark does not exist */
    RETURN NULL;

END Get_Category;

/*=======================================================================*/

PROCEDURE Add_Bookmark(
  p_party_id IN NUMBER,
  p_bookmarked_party_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
) AS

  l_return_status VARCHAR2(1);
  l_category varchar2(30);
  l_party_name HZ_PARTIES.PARTY_NAME%TYPE;
  l_bookmark_num NUMBER;
  l_bookmark_limit NUMBER;
  l_obj_version_no NUMBER;
BEGIN

  /* NEED TO CHECK IF BOOKMARK EXISTS BEFORE ADDING? */

  /* Get party name and category of user to be stored in HZ_PARTY_PREFERENCES */
  SELECT party_name, party_type
  INTO l_party_name, l_category
  FROM hz_parties
  WHERE party_id = p_bookmarked_party_id;

  IF l_category = 'ORGANIZATION' THEN
    l_category := G_CATEGORY_ORG;
    l_bookmark_limit := FND_PROFILE.value('IMC_MAX_ORG_BOOKMARKS');
  ELSIF l_category = 'PERSON' THEN
    l_category := G_CATEGORY_PERSON;
    l_bookmark_limit := FND_PROFILE.value('IMC_MAX_PEOPLE_BOOKMARKS');
  ELSIF l_category = 'PARTY_RELATIONSHIP' THEN
    l_category := G_CATEGORY_REL;
    l_bookmark_limit := FND_PROFILE.value('IMC_MAX_CONTACT_BOOKMARKS');
  END IF;

  /* Get current number of bookmarks and compare with the maximum allowed in
     user profile */
  SELECT count(*)
  INTO l_bookmark_num
  FROM HZ_PARTY_PREFERENCES
  WHERE   MODULE = G_MODLUE
  AND     CATEGORY = l_category
  AND     PREFERENCE_CODE = G_PREFERENCE_CODE
  AND     PARTY_ID = p_party_id;

  IF l_bookmark_num < l_bookmark_limit THEN
    HZ_PREFERENCE_PUB.Add(
      p_party_id,
      l_category,
      G_PREFERENCE_CODE,
      FND_API.G_MISS_CHAR,
      p_bookmarked_party_id,
      FND_API.G_MISS_DATE,
      SUBSTR(l_party_name,1,10),
      G_MODLUE,
      FND_API.G_MISS_CHAR,
      FND_API.G_MISS_CHAR,
      FND_API.G_MISS_CHAR,
      FND_API.G_MISS_CHAR,
      FND_API.G_MISS_CHAR,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_obj_version_no);

    x_return_status := l_return_status;
  ELSE
    x_return_status := G_MAX_REACHED_ERROR;
    FND_MESSAGE.SET_NAME('IMC', 'IMC_MAX_BOOKMARKS_REACHED');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);
  END IF;

EXCEPTION
  /* Exceptions may be raised from HZ_PREFERENCE_PUB */
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN NO_DATA_FOUND THEN
    /* party ID of user does not exist */
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('IMC', 'IMC_INVALID_BOOKMARK_ID');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

END Add_Bookmark;

/*=======================================================================*/

PROCEDURE Add_Bookmark(
  p_fnd_user_id IN NUMBER,
  p_bookmarked_party_id IN NUMBER,
  x_party_id OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
) AS

  l_return_status VARCHAR2(1);
  l_hz_return_status VARCHAR2(1);
  l_party_id NUMBER;
  l_user_name FND_USER.USER_NAME%TYPE;
  l_email_address FND_USER.EMAIL_ADDRESS%TYPE;
  l_person_id FND_USER.EMPLOYEE_ID%TYPE;
BEGIN

  SELECT user_name, email_address, customer_id, employee_id
  INTO l_user_name, l_email_address, l_party_id, l_person_id
  FROM fnd_user
  WHERE user_id = p_fnd_user_id;

  IF l_party_id is NULL THEN
      /* create new party using user name as both first and last names */
      HZ_USER_PARTY_UTILS.get_user_party_id(
      l_user_name,
      l_user_name,  /* first name */
      l_user_name,  /* last name */
      l_email_address,
      l_party_id,
      l_hz_return_status);

      IF l_hz_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /* problem creating party for FND user */
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IMC', 'HZ_API_OTHERS_EXCEP');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                      p_encoded => FND_API.G_FALSE,
                      p_count => x_msg_count,
                      p_data  => x_msg_data);
      END IF;

    /* hook up fnd_user.customer_id and hz_parties.party_id */
    fnd_user_pkg.updateuser(x_user_name=>l_user_name,
			    x_owner=>'SEED',
			    x_customer_id=>l_party_id);

    Add_Bookmark(
      l_party_id,
      p_bookmarked_party_id,
      l_return_status,
      x_msg_count,
      x_msg_data);
    x_return_status := l_return_status;

  ELSE
    Add_Bookmark(
      l_party_id,
      p_bookmarked_party_id,
      l_return_status,
      x_msg_count,
      x_msg_data);
    x_return_status := l_return_status;
  END IF;

EXCEPTION
  /* Exceptions may be raised from HZ_PREFERENCE_PUB */
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN NO_DATA_FOUND THEN
    /* FND user ID does not exist */
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('IMC', 'IMC_FND_USER_NOT_EXIST');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);
END Add_Bookmark;

/*=======================================================================*/

PROCEDURE Remove_Bookmark(
  p_party_id IN NUMBER,
  p_user_type IN VARCHAR2,
  p_bookmarked_party_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
) AS

  l_return_status VARCHAR2(1);
  l_category varchar2(30);
  l_user_id number;
BEGIN

  l_category := Get_Category(p_bookmarked_party_id);
  IF l_category IS NULL THEN
    /* bookmark ID is invalid */
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('IMC', 'IMC_INVALID_BOOKMARK_ID');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);
  ELSE
    IF p_user_type NOT IN (G_PARTY_USER_TYPE, G_FND_USER_TYPE) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('IMC', 'IMC_INVALID_USER_TYPE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);
    END IF;

    IF p_user_type = G_PARTY_USER_TYPE THEN
      l_user_id := p_party_id;
    ELSE
      /* find party id of FND user */
      select customer_id into l_user_id
      from fnd_user
      where user_id = p_party_id;
    END IF;


    HZ_PREFERENCE_PUB.Remove(
      l_user_id,
      l_category,
      G_PREFERENCE_CODE,
      FND_API.G_MISS_CHAR,
      p_bookmarked_party_id,
      FND_API.G_MISS_DATE,
      G_OBJECT_VERSION_NUMBER,
      l_return_status,
      x_msg_count,
      x_msg_data
    );

    x_return_status := l_return_status;

  END IF;

EXCEPTION
  /* Exceptions may be raised from HZ_PREFERENCE_PUB */
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('IMC', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

END Remove_Bookmark;

/*=======================================================================*/

PROCEDURE Get_Bookmarked_Parties(
  p_party_id IN NUMBER,
  p_bookmarked_party_type IN VARCHAR2,
  x_bookmarked_party_ids OUT NOCOPY ref_cursor_bookmarks,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
) AS
  l_return_status VARCHAR2(1);
  l_party_id NUMBER;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Check if party id is valid */
  SELECT party_id
  INTO l_party_id
  FROM hz_parties
  WHERE party_id = p_party_id;

  IF p_bookmarked_party_type IS NOT NULL THEN

    /* Check if bookmark type is valid */
    IF p_bookmarked_party_type IN (G_CATEGORY_ORG, G_CATEGORY_PERSON, G_CATEGORY_REL) THEN
      OPEN x_bookmarked_party_ids FOR
        SELECT  value_number
        FROM    HZ_PARTY_PREFERENCES
        WHERE   MODULE = G_MODLUE
        AND     CATEGORY = p_bookmarked_party_type
        AND     PREFERENCE_CODE = G_PREFERENCE_CODE
        AND     PARTY_ID = p_party_id;

    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      /* bookmark type is invalid */
      FND_MESSAGE.SET_NAME('IMC', 'IMC_INVALID_BOOKMARK_TYPE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);
    END IF;

  ELSE /* get all bookmarks for a user */

    OPEN x_bookmarked_party_ids FOR
      SELECT  value_number
      FROM    HZ_PARTY_PREFERENCES
      WHERE   MODULE = G_MODLUE
      AND     PREFERENCE_CODE = G_PREFERENCE_CODE
      AND     PARTY_ID = p_party_id;

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /* party id is invalid */
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('IMC', 'IMC_INVALID_PARTY_ID');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('IMC', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_msg_count,
                    p_data  => x_msg_data);

END Get_Bookmarked_Parties;

/*=======================================================================*/

FUNCTION Bookmark_Exists(
  p_party_id IN NUMBER,
  p_user_type IN VARCHAR2,
  p_bookmarked_party_id IN NUMBER
) RETURN VARCHAR2
AS
  l_category varchar2(30);
  l_user_id number;
  l_ret varchar2(1);
BEGIN

  l_category := Get_Category(p_bookmarked_party_id);
  IF l_category IS NULL THEN
    RETURN 'E';
  END IF;

  IF p_user_type NOT IN (G_PARTY_USER_TYPE, G_FND_USER_TYPE) THEN
    RETURN 'E';
  END IF;

  IF p_user_type = G_PARTY_USER_TYPE THEN
    l_user_id := p_party_id;
  ELSE
    /* find party id of FND user */
    select customer_id into l_user_id
    from fnd_user
    where user_id = p_party_id;
  END IF;

  l_ret := HZ_PREFERENCE_PUB.Contains_Value(
                l_user_id,
                l_category,
                G_PREFERENCE_CODE,
                p_bookmarked_party_id);

  RETURN l_ret;

EXCEPTION
  /* Exceptions may be raised from HZ_PREFERENCE_PUB */
  WHEN FND_API.G_EXC_ERROR THEN
    RETURN FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    RETURN 'E';

END Bookmark_Exists;

/*=======================================================================*/

FUNCTION Disable_Bookmark(
  p_party_id IN NUMBER
) RETURN VARCHAR2
AS
  l_count NUMBER;
BEGIN

  select count(*) into l_count
  from hz_relationships
  where party_id = p_party_id
  and subject_type = 'ORGANIZATION'
  and object_type = 'ORGANIZATION';

  if l_count > 0 then
    RETURN 'Y';
  else
    RETURN 'N';
  end if;
END Disable_Bookmark;


/*===================================================================+
 | PRIVATE  procedure Create_Per_Person_Party
 |
 | DESCRIPTION
 |    *** Copy from ARHUSRPB.pls ***
 |    Create a party for a per_all_people_f person if it has not
 |    already created.  The concept here is that we believe that
 |    HR person is more reliable resource than email_address for
 |    the fnd users that are already assigned a per_all_people.
 |
 |    We will use the first name and last name from the HR table,
 |    and use 'PER:' + person_id as orig system reference
 |    so we can use Party Merge to merge this party created from
 |    this API with the party created from TCA/HR merge later.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   p_per_person_id      Person Identifier for PER_ALL_PEOPLE_F
 |
 |
 | RETURNS
 |   x_party_id           Party Identifier
 |   pv_return_status     Return status
 *===================================================================*/
PROCEDURE create_per_person_party(p_per_person_id  IN    NUMBER,
                                  x_party_id       OUT NOCOPY NUMBER) IS

 /*-----------------------------------------------------+
  | Cursor for fetching a person record from            |
  | per_all_people_f for creating a person party.       |
  |                                                     |
  | Note: We don't try to do a full mapping here.       |
  | That will be done in TCA/HR merge.                  |
  | Only minimal information is populated here for UI   |
  | to display basic personal information about a user  |
  +-----------------------------------------------------*/
  CURSOR per_person_cur(l_per_person_id
                          per_all_people_f.person_id%TYPE) IS
    SELECT per.person_id,
           per.first_name,
           per.last_name,
           per.email_address
    FROM   per_all_people_f per
    WHERE  per.person_id = l_per_person_id
    AND    TRUNC(SYSDATE) BETWEEN effective_start_date
                          AND     effective_end_date;

  per_person_rec            per_person_cur%ROWTYPE;
  per_rec                   hz_party_v2pub.person_rec_type;
  par_rec                   hz_party_v2pub.party_rec_type;
  cpoint_rec                hz_contact_point_v2pub.contact_point_rec_type;
  email_rec                 hz_contact_point_v2pub.email_rec_type;

  l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_person_party_id         NUMBER;
  l_party_number            hz_parties.party_number%TYPE;
  l_person_profile_id       NUMBER;
  l_contact_point_id        NUMBER;
  l_generate_party_number   VARCHAR2(1);

BEGIN

    OPEN  per_person_cur(p_per_person_id);
    FETCH per_person_cur INTO per_person_rec;
    CLOSE per_person_cur;

    --
    -- Raise an exception if PER_ALL_PEOPLE_F not found.
    --

    --
    -- Create a Person Party
    --
    per_rec.party_rec.status        := 'A';
    per_rec.person_first_name              := per_person_rec.first_name;
    per_rec.person_last_name               := per_person_rec.last_name;

    l_generate_party_number := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');

    IF l_generate_party_number = 'N' then
      select hz_party_number_s.nextval into par_rec.party_number from dual;
    END IF;

    par_rec.orig_system_reference   :=
        'PER:'||per_person_rec.person_id;
    per_rec.party_rec    := par_rec;

    hz_party_v2pub.create_person(
--        p_api_version   => 1,
        p_init_msg_list => 'F',
--        p_commit        => 'F',
        p_person_rec    => per_rec,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data,
        x_party_id      => l_person_party_id,
        x_party_number  => l_party_number,
        x_profile_id    => l_person_profile_id);

    --
    -- Return the person party id to the caller
    --
    x_party_id := l_person_party_id;


    --
    -- Call TCA API to create email contact point for the person party.
    --
    IF (    l_return_status         = FND_API.G_RET_STS_SUCCESS
        AND l_person_party_id       IS NOT NULL
        AND per_person_rec.email_address
                                    IS NOT NULL) THEN

      cpoint_rec.contact_point_type     := 'EMAIL';
      cpoint_rec.status                 := 'A';
      cpoint_rec.owner_table_name       := 'HZ_PARTIES';
      cpoint_rec.owner_table_id         := l_person_party_id;
      cpoint_rec.primary_flag           := 'Y';
      email_rec.email_address           := per_person_rec.email_address;

      hz_contact_point_v2pub.create_contact_point(
--          P_API_VERSION          => 1,
          P_INIT_MSG_LIST        => 'F',
--          P_COMMIT               => 'F',
          P_CONTACT_POINT_REC   => cpoint_rec,
          P_EDI_REC              => null,
          P_EMAIL_REC            => email_rec,
          P_PHONE_REC            => null,
          P_TELEX_REC            => null,
          P_WEB_REC              => null,
          x_return_status        => l_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data,
          X_CONTACT_POINT_ID     => l_contact_point_id);

    END IF;

END create_per_person_party;

END IMC_BOOKMARK_PUB;

/
