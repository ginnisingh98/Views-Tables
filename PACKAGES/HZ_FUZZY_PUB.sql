--------------------------------------------------------
--  DDL for Package HZ_FUZZY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_FUZZY_PUB" AUTHID CURRENT_USER as
/*$Header: ARHFUZYS.pls 120.1 2005/06/16 21:11:56 jhuang ship $ */
--
--

  -- this record structure contains only fields which are used for
  -- generating the key in the parties table
  TYPE party_rec_type IS RECORD(
                                party_id             NUMBER := FND_API.G_MISS_NUM,
                                party_name           VARCHAR2(360) := FND_API.G_MISS_CHAR,
                                party_type           VARCHAR2(30) := FND_API.G_MISS_CHAR,
                                first_name           VARCHAR2(150):= FND_API.G_MISS_CHAR,
                                last_name            VARCHAR2(150):=FND_API.G_MISS_CHAR
                               );

  -- this record structure contains only fields which are used for
  -- generating the key in the locations table
  TYPE location_rec_type IS RECORD(
                                   location_id        NUMBER := FND_API.G_MISS_NUM,
                                   address1           VARCHAR2(240) := FND_API.G_MISS_CHAR,
                                   address2           VARCHAR2(240) := FND_API.G_MISS_CHAR,
                                   address3           VARCHAR2(240):= FND_API.G_MISS_CHAR,
                                   address4           VARCHAR2(240):= FND_API.G_MISS_CHAR,
                                   postal_code        VARCHAR2(60):=FND_API.G_MISS_CHAR
                                  );

  TYPE location_tbl_type is TABLE of hz_locations.location_id%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE party_tbl_type is TABLE of hz_parties.party_id%TYPE
    INDEX BY BINARY_INTEGER;


/*===========================================================================+
 | FUNCTION                                                                  |
 |     Generate_Key                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Function to generate a party (organization/perosn/group) key,         |
 |     address key for use in fuzzy find by TCA.                             |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_key_type                                          |
 |                       p_party_name                                        |
 |                       p_address1                                          |
 |                       p_address2                                          |
 |                       p_address3                                          |
 |                       p_address4                                          |
 |                       p_postal_code                                       |
 |                       p_first_name                                        |
 |                       p_last_name                                         |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : l_key                                                        |
 |                                                                           |
 | NOTES      :                                                              |
 |     p_key_type must be 'ORGANIZATION', 'PERSON', 'GROUP', 'ADDRESS'.      |
 |     For key_type 'ORGANIZATION', 'GROUP' party name is needed             |
 |     For key_type 'ADDRESS', address1/address2/address3/address4 and       |
 |      postal_code are required                                             |
 |     For key_type 'PERSON' first_name and last_name should be passed in    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  FUNCTION Generate_Key (
                         p_key_type      VARCHAR2,
                         p_party_name    VARCHAR2 DEFAULT NULL,
                         p_address1      VARCHAR2 DEFAULT NULL,
                         p_address2      VARCHAR2 DEFAULT NULL,
                         p_address3      VARCHAR2 DEFAULT NULL,
                         p_address4      VARCHAR2 DEFAULT NULL,
                         p_postal_code   VARCHAR2 DEFAULT NULL,
                         p_first_name    VARCHAR2 DEFAULT NULL,
                         p_last_name     VARCHAR2 DEFAULT NULL
                        ) RETURN VARCHAR2;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Generate_Full_Table_Key                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Procedure to generate full table key for a particular type of key     |
 |     This program is designed to be run as concurrent program              |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       Errbuf                                              |
 |                       Retcode                                             |
 |                       p_key_type                                          |
 |                       p_new_rows                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : l_location_rec                                               |
 |                                                                           |
 | NOTES      : p_key_type can be PARTY, ADDRESS                             |
 |              p_new_rows can be 'Y', 'N'                                   |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  PROCEDURE Generate_Full_Table_Key (
                                     Errbuf          OUT     NOCOPY VARCHAR2,
                                     Retcode         OUT     NOCOPY VARCHAR2,
                                     p_key_type      IN      VARCHAR2 DEFAULT NULL,
                                     p_new_rows      IN      VARCHAR2 DEFAULT 'Y'
                                    );


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Is_Duplicate_Party                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Public procedure for checking if the passed party information         |
 |     is a duplicate of an existing party. If program finds that it is a    |
 |     duplicate record, it sets p_duplicate to fnd_api.g_true. Also a       |
 |     message is set and one matching party_id is returned.                 |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                               p_party_type                                |
 |                               p_person_first_name                         |
 |                               p_person_last_name                          |
 |                               p_party_name                                |
 |                               p_key_search_flag                           |
 |              OUT:                                                         |
 |                               p_duplicate                                 |
 |                               p_msg_count                                 |
 |                               p_msg_data                                  |
 |                               p_party_id                                  |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : None                                                         |
 |                                                                           |
 | NOTES      : It does not return all the matching parties.                 |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  PROCEDURE Is_Duplicate_Party (
            p_party_type            IN      VARCHAR2,
            p_person_first_name     IN      VARCHAR2 DEFAULT NULL,
            p_person_last_name      IN      VARCHAR2 DEFAULT NULL,
            p_party_name            IN      VARCHAR2 DEFAULT NULL,
            p_key_search_flag       IN      VARCHAR2 DEFAULT FND_API.G_TRUE,  --'T' for search on key, 'F' othewise
            p_duplicate             OUT     NOCOPY VARCHAR2,
            p_msg_count             OUT     NOCOPY NUMBER,
            p_msg_data              OUT     NOCOPY VARCHAR2,
            p_party_id              OUT     NOCOPY NUMBER
           );


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Is_Duplicate_Location                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Public procedure for checking if the passed location information      |
 |     is a duplicate of an existing location.If a duplicate location is     |
 |     found, p_duplicate is set to fnd_api.g_true and a message is also set |
 |     stating that. p_key_search_flag determines whether to do a key match  |
 |     or exact match.                                                       |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                               p_address1                                  |
 |                               p_address2                                  |
 |                               p_address3                                  |
 |                               p_address4                                  |
 |                               p_postal_code                               |
 |                               p_state                                     |
 |                               p_city                                      |
 |                               p_country                                   |
 |                               p_key_search_flag                           |
 |              OUT:                                                         |
 |                               p_duplicate                                 |
 |                               p_msg_count                                 |
 |                               p_msg_data                                  |
 |                               p_location_id                               |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : None                                                         |
 |                                                                           |
 | NOTES      : It does not return all the matching locations.               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  PROCEDURE Is_Duplicate_Location (
               p_address1            IN  VARCHAR2 DEFAULT NULL,
               p_address2            IN  VARCHAR2 DEFAULT NULL,
               p_address3            IN  VARCHAR2 DEFAULT NULL,
               p_address4            IN  VARCHAR2 DEFAULT NULL,
               p_postal_code         IN  VARCHAR2 DEFAULT NULL,
               p_state               IN  VARCHAR2 DEFAULT NULL,
               p_city                IN  VARCHAR2 DEFAULT NULL,
               p_country             IN  VARCHAR2 DEFAULT NULL,
               p_key_search_flag     IN  VARCHAR2 DEFAULT FND_API.G_TRUE, --'T' for search on key, 'F' othewise
               p_duplicate           OUT NOCOPY VARCHAR2,
               p_msg_count           OUT NOCOPY NUMBER,
               p_msg_data            OUT NOCOPY VARCHAR2,
               p_location_id         OUT NOCOPY NUMBER
              );



/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Fuzzy_Search_Address                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Public procedure for doing fuzzy search for address. Pass the address |
 |     lines and the postal code. The number of duplicate records found      |
 |     is returned in p_count and list of location ids is returned in        |
 |     p_location_tbl.                                                       |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                               p_address1                                  |
 |                               p_address2                                  |
 |                               p_address3                                  |
 |                               p_address4                                  |
 |                               p_postal_code                               |
 |              OUT:                                                         |
 |                               p_location_tbl                              |
 |                               p_count                                     |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : None                                                         |
 |                                                                           |
 | NOTES      : This does fuzzy search based on the generated key only.      |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  PROCEDURE Fuzzy_Search_Address(
                                 p_address1            IN  HZ_LOCATIONS.ADDRESS1%TYPE DEFAULT NULL,
                                 p_address2            IN  HZ_LOCATIONS.ADDRESS2%TYPE DEFAULT NULL,
                                 p_address3            IN  HZ_LOCATIONS.ADDRESS3%TYPE DEFAULT NULL,
                                 p_address4            IN  HZ_LOCATIONS.ADDRESS4%TYPE DEFAULT NULL,
                                 p_postal_code         IN  HZ_LOCATIONS.POSTAL_CODE%TYPE DEFAULT NULL,
                                 p_location_tbl        OUT NOCOPY LOCATION_TBL_TYPE,
                                 p_count               OUT NOCOPY NUMBER
                                );


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     Fuzzy_Search_Party                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Public procedure for doing fuzzy search for party. In case of an      |
 |     organization search, pass party_name and in case of person search     |
 |     pass forst_name and last_name. The number of duplicate records found  |
 |     is returned in p_count and list of party ids is returned in           |
 |     p_party_tbl.                                                          |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                               p_party_type                                |
 |                               p_party_name                                |
 |                               p_first_name                                |
 |                               p_last_name                                 |
 |              OUT:                                                         |
 |                               p_party_tbl                                 |
 |                               p_count                                     |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : None                                                         |
 |                                                                           |
 | NOTES      : This does fuzzy search based on the generated key only.      |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   22-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

  PROCEDURE Fuzzy_Search_Party(
                               p_party_type          IN  HZ_PARTIES.PARTY_TYPE%TYPE,
                               p_party_name          IN  HZ_PARTIES.PARTY_NAME%TYPE DEFAULT NULL,
                               p_first_name          IN  HZ_PARTIES.PERSON_FIRST_NAME%TYPE DEFAULT NULL,
                               p_last_name           IN  HZ_PARTIES.PERSON_LAST_NAME%TYPE DEFAULT NULL,
                               p_party_tbl           OUT NOCOPY PARTY_TBL_TYPE,
                               p_count               OUT NOCOPY NUMBER
                              );

END;

 

/
