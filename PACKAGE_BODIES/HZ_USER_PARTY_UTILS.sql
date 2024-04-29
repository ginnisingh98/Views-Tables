--------------------------------------------------------
--  DDL for Package Body HZ_USER_PARTY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_USER_PARTY_UTILS" AS
/* $Header: ARHUSRPB.pls 120.2.12010000.2 2009/05/25 10:28:22 rgokavar ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'HZ_USER_PARTY_UTILS';

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/

PROCEDURE create_per_person_party(p_per_person_id  IN    NUMBER,
                                  x_party_id       OUT   NOCOPY NUMBER) ;


/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/

/*========================================================================
 | PUBLIC procedure get_user_party_id
 |
 | DESCRIPTION
 |      Tries to find a party based on email-address. If party is found
 |      the party id is returned. If the party is NOT found a new party
 |      is created and party id returned.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |   pv_user_name          User Name
 |   pv_first_name         First Name
 |   pv_last_name          Last Name
 |   pv_party_email        Email address
 |
 | RETURNS
 |   pn_party_id      Party Identifier
 |   pv_return_status Return status
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 25-May-2001           J Rautiainen      Created
 *=======================================================================*/
PROCEDURE get_user_party_id(pv_user_name         IN  VARCHAR2,
                            pv_first_name        IN  VARCHAR2,
                            pv_last_name         IN  VARCHAR2,
                            pv_email_address     IN  VARCHAR2,
                            pn_party_id          OUT NOCOPY NUMBER,
                            pv_return_status     OUT NOCOPY VARCHAR2) IS

 /*--------------------------------------------------+
  | Cursor for fetching the user record based on     |
  | user name passed in as parameter. FND_USER       |
  | stores user names all capital letters.           |
  +--------------------------------------------------*/
  CURSOR user_cur(l_user_name fnd_user.user_name%TYPE) IS
    SELECT customer_id,
           employee_id
    FROM   fnd_user
    WHERE  user_name = UPPER(l_user_name);

 /*-----------------------------------------------------+
  | Cursor for finding a person party from person_id    |
  |Bug#8262607 Changed logic to get valid Party_id value|
  |from latest record in PER_ALL_PEOPLE_F table.        |
  |This is FP for 11i bug 7154782.                      |
  +-----------------------------------------------------*/
  CURSOR per_person_party_cur(l_per_person_id
                          per_all_people_f.person_id%TYPE) IS
 /*   SELECT pp.party_id
    FROM   hz_parties       pp
    ,      per_all_people_f per
    WHERE  pp.orig_system_reference = 'PER:'||per.person_id
    AND    per.person_id = l_per_person_id;
*/
     SELECT party_id
     FROM (
 	     SELECT party_id , '1-HR' ORDER_BY_SOURCE ,  effective_end_date EFFECTIVE_DATE
 	     FROM   per_all_people_f
 	     WHERE  person_id = l_per_person_id
 	     AND    party_id IS NOT NULL
 	     UNION ALL
 	     SELECT pp.party_id , '2-TCA' ORDER_BY_SOURCE ,  pp.last_update_date EFFECTIVE_DATE
 	     FROM   hz_parties pp,
 	            per_all_people_f per
 	     WHERE  pp.orig_system_reference = 'PER:'||per.person_id
 	     AND    per.person_id = l_per_person_id
 	     AND    per.party_id IS NULL
 	     ORDER BY ORDER_BY_SOURCE ASC, EFFECTIVE_DATE desc
     )
     WHERE ROWNUM = 1;

 /*-----------------------------------------------------+
  | Cursor for finding a person party with email        |
  | address given as parameter. HZ_CONTACT_POINTS table |
  | has function based index on upper(email_address)    |
  | so performance of the query is acceptable.          |
  +-----------------------------------------------------*/
  CURSOR person_cur(l_email_address
                      hz_contact_points.email_address%TYPE) IS
    SELECT party.party_id,
           party.party_type,
           party.status
    FROM   hz_contact_points cp,
           hz_parties party
    WHERE upper(cp.email_address) = UPPER(l_email_address)
    AND   cp.owner_table_name     = 'HZ_PARTIES'
    AND   party.party_id          = cp.owner_table_id
    AND   party.party_type        = 'PERSON'
    AND   party.status            NOT IN ('M','D','I');

 /*-----------------------------------------------------+
  | This cursor is used to find the person party        |
  | from an email assigned to a contact.                |
  +-----------------------------------------------------*/
  CURSOR contact_cur(l_email_address
                       hz_contact_points.email_address%TYPE) IS
    SELECT per.party_id,
           per.party_type,
           per.status
    FROM   hz_contact_points cp,
           hz_relationships rel,
           hz_parties per
    WHERE upper(cp.email_address) = UPPER(l_email_address)
    AND   rel.party_id            = cp.owner_table_id
    AND   cp.owner_table_name     = 'HZ_PARTIES'
    AND   rel.subject_id          = per.party_id
    AND   per.party_type          = 'PERSON'
    AND   rel.directional_flag    = 'F'
    AND   rel.subject_table_name  = 'HZ_PARTIES'
    AND   rel.object_table_name   = 'HZ_PARTIES'
    AND   rel.status              NOT IN ('M','D','I');

  user_rec                  user_cur%ROWTYPE;
  per_person_party_rec      per_person_party_cur%ROWTYPE;
  person_rec                person_cur%ROWTYPE;
  contact_rec               contact_cur%ROWTYPE;

  per_rec                   hz_party_v2pub.person_rec_type;
  par_rec                   hz_party_v2pub.party_rec_type;
  cpoint_rec                hz_contact_point_v2pub.contact_point_rec_type;
  email_rec                 hz_contact_point_v2pub.email_rec_type;

  lv_subject_party_number   hz_parties.party_number%TYPE;
  ln_subject_party_id       hz_parties.party_id%TYPE;
  ln_contact_point_id       hz_contact_points.contact_point_id%TYPE;

  ln_profile_id             NUMBER;
  ln_party_id               NUMBER;
  ln_per_person_id          NUMBER;

  lv_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  ln_msg_count              NUMBER;
  lv_msg_data               VARCHAR2(2000);
  l_generate_party_number   VARCHAR2(1);
  l_per_person_party_id     NUMBER;

BEGIN

 /*--------------------------------------------------+
  | 1) Find a party from FND_USER                    |
  |                                                  |
  | If username was passed in, fetch it and check    |
  | whether party id is already defined for the user |
  |                                                  |
  | It is possible that pv_user_name is not a valid  |
  | fnd user since the calling program may call this |
  | API to get a party before it creates a fnd user. |
  | We just ignore this case because the purpose of  |
  | this is returning a party_id which should be     |
  | stampled to fnd user.                            |
  +--------------------------------------------------*/
  IF pv_user_name IS NOT NULL THEN

    OPEN  user_cur(pv_user_name);
    FETCH user_cur INTO user_rec;
    CLOSE user_cur;

   /*-----------------------------------------------------+
    | Party id is already defined for the user, return it |
    +-----------------------------------------------------*/
    IF user_rec.customer_id IS NOT NULL THEN

      ln_party_id := user_rec.customer_id;

    ELSIF user_rec.employee_id IS NOT NULL THEN

      ln_per_person_id := user_rec.employee_id;

    END IF;


  END IF;

  /*-----------------------------------------------------+
   | 2) Find a party from the per person_id in FND_USER  |
   |                                                     |
   | A party may be already created for the person       |
   | since a per person is allowed to have multiple      |
   | fnd users.                                          |
   |                                                     |
   | For now we rely on the ORIG_SYSTEM_REFERENCE in     |
   | HZ_PARTIES to link to PER_ALL_PEOPLE_F              |
   |                                                     |
   | After HR Merge into TCA, we should use the PARTY_ID |
   | in PER_ALL_PEOPLE_F. Creating a Person Party        |
   | for a HR Person can be obsolete since a party will  |
   | be created when a HR person is created              |
   |                                                     |
   +-----------------------------------------------------*/
  IF     ln_party_id      IS NULL
     AND ln_per_person_id IS NOT NULL THEN

    OPEN  per_person_party_cur(ln_per_person_id);
    FETCH per_person_party_cur INTO per_person_party_rec;
    CLOSE per_person_party_cur;


    IF  per_person_party_rec.party_id is NOT NULL THEN

      --
      -- Found a party with orig system reference match
      -- person_id
      --
      ln_party_id := per_person_party_rec.party_id;

    ELSE

      --
      -- Create a Person Party for the person_id
      --
      create_per_person_party(ln_per_person_id,
                              l_per_person_party_id);

      ln_party_id := l_per_person_party_id;

    END IF;

  END IF;


 /*---------------------------------------------------+
  | 3) Find a person party from an email              |
  |                                                   |
  | If party was not defined on the user. Next we try |
  | to find it based on email address stored on the   |
  | contact point.                                    |
  +---------------------------------------------------*/
  IF     ln_party_id      IS NULL
     AND pv_email_address IS NOT NULL THEN

    OPEN  person_cur(pv_email_address);
    FETCH person_cur INTO person_rec;
    CLOSE person_cur;

   /*-----------------------------------------------------+
    | Party Id found with the email address can be        |
    | returned directly if the party type is 'PERSON'.    |
    +-----------------------------------------------------*/
    IF  person_rec.party_id   IS NOT NULL THEN

      ln_party_id := person_rec.party_id;

    END IF;

  END IF;

 /*--------------------------------------------------+
  | 4) Find a contact party from an email            |
  |                                                  |
  | If party was not defined on the user, and person |
  | party with the given email addresswas not found. |
  | Next we try to find the subject party if an      |
  | relationship party was found.                    |
  +--------------------------------------------------*/
  IF     ln_party_id      IS NULL
     AND pv_email_address IS NOT NULL THEN

    OPEN  contact_cur(pv_email_address);
    FETCH contact_cur INTO contact_rec;
    CLOSE contact_cur;

   /*-----------------------------------------------------+
    | Subject party Id found for the relationship party   |
    +-----------------------------------------------------*/
    IF  contact_rec.party_id IS NOT NULL THEN

      ln_party_id := contact_rec.party_id;

    END IF;

  END IF;



 /*------------------------------------------------------+
  | 5) Create a person party                             |
  |                                                      |
  | Party Id could not be found, we'll create it on fly. |
  | Person party needs at minimum first or last name     |
  +------------------------------------------------------*/
  IF     ln_party_id IS NULL
     AND (   pv_first_name IS NOT NULL
          OR pv_last_name  IS NOT NULL) THEN

    per_rec.party_rec.status        := 'A';
    per_rec.person_first_name              := pv_first_name;
    per_rec.person_last_name               := pv_last_name;

    l_generate_party_number := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');

    IF l_generate_party_number = 'N' then
      select hz_party_number_s.nextval into par_rec.party_number from dual;
    END IF;

    per_rec.party_rec    := par_rec;

   /*------------------------------------------+
    | Call TCA API to create the person party. |
    +------------------------------------------*/
   -- Commented call to V1 API
   /* hz_party_v2pub.create_person(1,null,null,
                               per_rec,
                               lv_return_status,
                               ln_msg_count,
                               lv_msg_data,
                               ln_subject_party_id,
                               lv_subject_party_number,
                               ln_profile_id);
    */

    -- Made call to V2 API
    HZ_PARTY_V2PUB.Create_Person(
      p_init_msg_list => FND_API.G_TRUE,
      p_person_rec    => per_rec,
      x_return_status => lv_return_status,
      x_msg_count     => ln_msg_count,
      x_msg_data      => lv_msg_data,
      x_party_id      => ln_subject_party_id,
      x_party_number  => lv_subject_party_number,
      x_profile_id    => ln_profile_id);

   /*----------------------------------------------+
    | Return the person party to the calling logic |
    +----------------------------------------------*/
    ln_party_id := ln_subject_party_id;

   /*------------------------------------------------------+
    | If the person party was succesfully created and a    |
    | email address was passed in, create a contact point  |
    | on the new person party.                             |
    +------------------------------------------------------*/
    IF (    lv_return_status    = FND_API.G_RET_STS_SUCCESS
        AND ln_subject_party_id IS NOT NULL
        AND pv_email_address    IS NOT NULL) THEN

      cpoint_rec.contact_point_type     := 'EMAIL';
      cpoint_rec.status                 := 'A';
      cpoint_rec.owner_table_name       := 'HZ_PARTIES';
      cpoint_rec.owner_table_id         := ln_subject_party_id;
      cpoint_rec.primary_flag           := 'Y';
      email_rec.email_address           := pv_email_address;

     /*------------------------------------------------------------------+
      | Call TCA API to create email contact point for the person party. |
      +------------------------------------------------------------------*/
      -- Commented call to V1 API
      /*
      hz_contact_point_v2pub.create_contact_point(1,null,null,
                                                 cpoint_rec,null,
                                                 email_rec,null,null,null,
                                                 lv_return_status,
                                                 ln_msg_count,
                                                 lv_msg_data,
                                                 ln_contact_point_id);
      */

      -- Made call to V2 API
      hz_contact_point_v2pub.create_contact_point (
         p_init_msg_list     => fnd_api.g_true,
         p_contact_point_rec => cpoint_rec,
         p_email_rec         => email_rec,
         x_contact_point_id  => ln_contact_point_id,
         x_return_status     => lv_return_status,
         x_msg_count         => ln_msg_count,
         x_msg_data          => lv_msg_data
         );
    END IF;

  END IF;


 /*------------------------------------------------------+
  | If the party was created, return status accordingly. |
  | Note this will disregard whether the email contact   |
  | point creation was succesful or not.                 |
  +------------------------------------------------------*/
  IF ln_party_id IS NOT NULL THEN

   /*------------------------------------------------------------+
    | If the person party was created, commit the transaction.   |
    | Note this procedure is an autonomous transaction so commit |
    | here will NOT affect the transaction on the calling logic. |
    +------------------------------------------------------------*/
    pv_return_status := FND_API.G_RET_STS_SUCCESS;
    pn_party_id      := ln_party_id;

  ELSE

    pv_return_status := FND_API.G_RET_STS_ERROR;
    pn_party_id      := to_number(null);

  END IF;

  EXCEPTION
    WHEN OTHERS THEN
     /*------------------------------------------------------------+
      | If exception was thrown, we do not want to propagate it to |
      | the calling logic, instead we pass error status upwards.   |
      +------------------------------------------------------------*/
      pv_return_status := FND_API.G_RET_STS_ERROR;
      pn_party_id      := to_number(null);

END get_user_party_id;


/*===================================================================+
 | PRIVATE  procedure Create_Per_Person_Party
 |
 | DESCRIPTION
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
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 5-Aug-2001            Dylan Wan         Created
 *===================================================================*/
PROCEDURE create_per_person_party(p_per_person_id  IN    NUMBER,
                                  x_party_id       OUT   NOCOPY NUMBER) IS

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

    -- Commented call to V1 API
    /*
    hz_party_v2pub.create_person(
        p_api_version   => 1,
        p_init_msg_list => 'F',
        p_commit        => 'F',
        p_person_rec    => per_rec,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data,
        x_party_id      => l_person_party_id,
        x_party_number  => l_party_number,
        x_profile_id    => l_person_profile_id);
    */

    -- Made call to V2 API
    HZ_PARTY_V2PUB.Create_Person(
       p_init_msg_list => FND_API.G_TRUE,
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

      -- Commented call to V1 API
      /*
      hz_contact_point_v2pub.create_contact_point(
          P_API_VERSION          => 1,
          P_INIT_MSG_LIST        => 'F',
          P_COMMIT               => 'F',
          P_CONTACT_POINTS_REC   => cpoint_rec,
          P_EDI_REC              => null,
          P_EMAIL_REC            => email_rec,
          P_PHONE_REC            => null,
          P_TELEX_REC            => null,
          P_WEB_REC              => null,
          x_return_status        => l_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data,
          X_CONTACT_POINT_ID     => l_contact_point_id);
       */

       -- Made call to V2 API
       hz_contact_point_v2pub.create_contact_point (
          p_init_msg_list     => fnd_api.g_true,
          p_contact_point_rec => cpoint_rec,
          p_email_rec         => email_rec,
          x_contact_point_id  => l_contact_point_id,
          x_return_status     => l_return_status,
          x_msg_count         => l_msg_count,
          x_msg_data          => l_msg_data
          );

    END IF;

END create_per_person_party;

END HZ_USER_PARTY_UTILS;

/
