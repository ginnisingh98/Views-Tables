--------------------------------------------------------
--  DDL for Package HZ_BANK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BANK_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBKASS.pls 120.3 2006/02/15 00:07:27 jhuang noship $ */
  TYPE bank_rec_type IS RECORD (
    bank_or_branch_number       VARCHAR2(60),
    bank_code                   VARCHAR2(30),
    branch_code                 VARCHAR2(30),
    institution_type            VARCHAR2(30),
    branch_type                 VARCHAR2(30),
    country                     VARCHAR2(30),
    rfc_code                    VARCHAR2(30),
    inactive_date               DATE,
    organization_rec            hz_party_v2pub.organization_rec_type :=
                                  hz_party_v2pub.g_miss_organization_rec
  );

  g_miss_bank_rec               bank_rec_type;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_bank                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a code assignment for the bank organization.                 |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_organization                                  |
   |   hz_organization_profiles_pkg.update_row                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_bank_rec           Bank record.                                 |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_party_id           Party ID for the bank.                       |
   |     x_party_number       Party number for the bank.                   |
   |     x_profile_id         Organization profile ID for the bank.        |
   |     x_code_assignment_id The code assignment ID for the bank          |
   |                          classification.                              |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/
  PROCEDURE create_bank (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_bank_rec                  IN      bank_rec_type,
    x_party_id                  OUT     NOCOPY NUMBER,
    x_party_number              OUT     NOCOPY VARCHAR2,
    x_profile_id                OUT     NOCOPY NUMBER,
    x_code_assignment_id        OUT     NOCOPY NUMBER,
    x_return_status             OUT     NOCOPY VARCHAR2,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_bank                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a bank organization and update its type if the type was      |
   |   specified.                                                          |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_organization                                  |
   |   hz_organization_profiles_pkg.update_row                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list                Initialize message stack if it is  |
   |                                    set to FND_API.G_TRUE. Default is  |
   |                                    fnd_api.g_false.                   |
   |     p_bank_rec                     Bank record.                       |
   |   IN/OUT:                                                             |
   |     x_pobject_version_number       New version number for the bank.   |
   |     x_bitobject_version_number     New version number for the code    |
   |                                    assignment for the bank type.      |
   |   OUT:                                                                |
   |     x_profile_id                   New organization profile ID for    |
   |                                    the updated bank.                  |
   |     x_return_status                Return status after the call. The  |
   |                                    status can be                      |
   |                                    FND_API.G_RET_STS_SUCCESS          |
   |                                    (success), fnd_api.g_ret_sts_error |
   |                                    (error),                           |
   |                                    fnd_api.g_ret_sts_unexp_error      |
   |                                    (unexpected error).                |
   |     x_msg_count                    Number of messages in message      |
   |                                    stack.                             |
   |     x_msg_data                     Message text if x_msg_count is 1.  |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE update_bank (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_bank_rec                  IN      bank_rec_type,
    p_pobject_version_number    IN OUT  NOCOPY NUMBER,
    p_bitobject_version_number  IN OUT  NOCOPY NUMBER,
    x_profile_id                OUT     NOCOPY NUMBER,
    x_return_status             OUT     NOCOPY VARCHAR2,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_branch                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a bank branch organization.                                  |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_organization                                  |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_bank_rec           Bank record.                                 |
   |     p_bank_party_id      Party ID of the parent bank.  NULL if the    |
   |                          parent bank is not going to be reassigned.   |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_party_id           Party ID for the bank branch.                |
   |     x_party_number       Party number for the bank branch.            |
   |     x_profile_id         Organization profile ID for the bank branch. |
   |     x_relationship_id    ID for the relationship between the branch   |
   |                          and its parent bank.                         |
   |     x_rel_party_id       ID for party relationship created.           |
   |     x_rel_party_number   Number for the party relationship created.   |
   |     x_bitcode_assignment_id The code assignment ID for the bank org   |
   |                          classification as a BRANCH.                  |
   |     x_bbtcode_assignment_id The code assignment ID for the type of    |
   |                          bank branch.                                 |
   |     x_rfccode_assignment_id The code assignment ID for the Regional   |
   |                          Finance Center used by the bank branch.      |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   |   06-MAY-2002    J. del Callar     Added support for RFCs.            |
   +=======================================================================*/
  PROCEDURE create_bank_branch (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_bank_rec                  IN      bank_rec_type,
    p_bank_party_id             IN      NUMBER,
    x_party_id                  OUT     NOCOPY NUMBER,
    x_party_number              OUT     NOCOPY VARCHAR2,
    x_profile_id                OUT     NOCOPY NUMBER,
    x_relationship_id           OUT     NOCOPY NUMBER,
    x_rel_party_id              OUT     NOCOPY NUMBER,
    x_rel_party_number          OUT     NOCOPY NUMBER,
    x_bitcode_assignment_id     OUT     NOCOPY NUMBER,
    x_bbtcode_assignment_id     OUT     NOCOPY NUMBER,
    x_rfccode_assignment_id     OUT     NOCOPY NUMBER,
    x_return_status             OUT     NOCOPY VARCHAR2,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_branch                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a bank branch organization.                                  |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_organization                                  |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_bank_rec           Bank record.                                 |
   |     p_relationship_id    ID for relationship between bank branch and  |
   |                          its parent bank.  NULL if the parent bank is |
   |                          not going to be reassigned.                  |
   |     p_bank_party_id      Party ID of the parent bank.  NULL if the    |
   |                          parent bank is not going to be reassigned.   |
   |   IN/OUT:                                                             |
   |     p_pobject_version_number       New version number for the bank    |
   |                                    branch party.                      |
   |     p_bbtobject_version_number     New version number for the bank    |
   |                                    branch type code assignment.       |
   |     p_rfcobject_version_number     New version number for the Regional|
   |                                    Finance Center code assignment.    |
   |   OUT:                                                                |
   |     x_profile_id         Organization profile ID for the bank branch. |
   |     x_rel_party_id       ID for party relationship created.           |
   |     x_rel_party_number   Number for the party relationship created.   |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   |   06-MAY-2002    J. del Callar     Added support for RFCs.            |
   +=======================================================================*/
  PROCEDURE update_bank_branch (
    p_init_msg_list             IN      VARCHAR2        := fnd_api.g_false,
    p_bank_rec                  IN      bank_rec_type,
    p_bank_party_id             IN      NUMBER          := NULL,
    p_relationship_id           IN OUT  NOCOPY NUMBER,
    p_pobject_version_number    IN OUT  NOCOPY NUMBER,
    p_bbtobject_version_number  IN OUT  NOCOPY NUMBER,
    p_rfcobject_version_number  IN OUT  NOCOPY NUMBER,
    x_profile_id                OUT     NOCOPY NUMBER,
    x_rel_party_id              OUT     NOCOPY NUMBER,
    x_rel_party_number          OUT     NOCOPY NUMBER,
    x_return_status             OUT     NOCOPY VARCHAR2,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_banking_group                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a banking group.                                             |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_group_rec          Group record for the banking group.          |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_party_id           Party ID for the banking group created.      |
   |     x_party_number       Party number for banking group created.      |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE create_banking_group (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_group_rec                 IN      hz_party_v2pub.group_rec_type,
    x_party_id                  OUT     NOCOPY NUMBER,
    x_party_number              OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_banking_group                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a banking group.                                             |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_group_rec          Group record for the banking group.          |
   |   IN/OUT:                                                             |
   |     p_pobject_version_number Version number for the banking group     |
   |                          party that was created.                      |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE update_banking_group (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_group_rec                 IN      hz_party_v2pub.group_rec_type,
    p_pobject_version_number    IN OUT  NOCOPY NUMBER,
    x_return_status             OUT     NOCOPY VARCHAR2,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_group_member                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a member relationship for a bank organization to a banking   |
   |   group.                                                              |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_relationship_rec   Relationship record for the banking group    |
   |                          membership.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_relationship_id    ID for the relationship record created.      |
   |     x_party_id           ID for the party created for the             |
   |                          relationship.                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE create_bank_group_member (
    p_init_msg_list     IN      VARCHAR2:= fnd_api.g_false,
    p_relationship_rec  IN      hz_relationship_v2pub.relationship_rec_type,
    x_relationship_id   OUT     NOCOPY NUMBER,
    x_party_id          OUT     NOCOPY NUMBER,
    x_party_number      OUT     NOCOPY NUMBER,
    x_return_status     OUT     NOCOPY VARCHAR2,
    x_msg_count         OUT     NOCOPY NUMBER,
    x_msg_data          OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_group_member                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a member relationship for a bank organization to a banking   |
   |   group.                                                              |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_relationship_rec   Relationship record for the banking group    |
   |                          membership.                                  |
   |   IN/OUT:                                                             |
   |     p_robject_version_number       New version number for the banking |
   |                                    group membership relationship.     |
   |     p_pobject_version_number       New version number for the banking |
   |                                    group membership rel party.        |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Updated.                           |
   +=======================================================================*/
  PROCEDURE update_bank_group_member (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_relationship_rec          IN hz_relationship_v2pub.relationship_rec_type,
    p_robject_version_number    IN OUT  NOCOPY NUMBER,
    p_pobject_version_number    IN OUT  NOCOPY NUMBER,
    x_return_status             OUT     NOCOPY VARCHAR2,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_clearinghouse_assign                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Assign a bank to a clearinghouse by creating a relationship.        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_relationship_rec   Relationship record for the clearinghouse    |
   |                          assignment.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_relationship_id    ID for the relationship record created.      |
   |     x_party_id           ID for the party created for the             |
   |                          relationship.                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE create_clearinghouse_assign (
    p_init_msg_list     IN      VARCHAR2:= fnd_api.g_false,
    p_relationship_rec  IN      hz_relationship_v2pub.relationship_rec_type,
    x_relationship_id   OUT     NOCOPY NUMBER,
    x_party_id          OUT     NOCOPY NUMBER,
    x_party_number      OUT     NOCOPY NUMBER,
    x_return_status     OUT     NOCOPY VARCHAR2,
    x_msg_count         OUT     NOCOPY NUMBER,
    x_msg_data          OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_clearinghouse_assign                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a relationship that assigns a bank to a clearinghouse.       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_relationship_rec   Relationship record for the clearinghouse    |
   |                          assignment.                                  |
   |   IN/OUT:                                                             |
   |     p_robject_version_number       New version number for the banking |
   |                                    group membership relationship.     |
   |     p_pobject_version_number       New version number for the banking |
   |                                    group membership rel party.        |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Updated.                           |
   +=======================================================================*/
  PROCEDURE update_clearinghouse_assign (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_relationship_rec          IN hz_relationship_v2pub.relationship_rec_type,
    p_robject_version_number    IN OUT  NOCOPY NUMBER,
    p_pobject_version_number    IN OUT  NOCOPY NUMBER,
    x_return_status             OUT     NOCOPY VARCHAR2,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_site                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a party site for a bank-type organization.                   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_party_site_rec     Party site record for the bank organization. |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_party_site_id      ID for the party site created.               |
   |     x_party_site_number  Party site number for the bank site          |
   |                          created.                                     |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE create_bank_site (
    p_init_msg_list     IN      VARCHAR2:= fnd_api.g_false,
    p_party_site_rec    IN      hz_party_site_v2pub.party_site_rec_type,
    x_party_site_id     OUT     NOCOPY NUMBER,
    x_party_site_number OUT     NOCOPY NUMBER,
    x_return_status     OUT     NOCOPY VARCHAR2,
    x_msg_count         OUT     NOCOPY NUMBER,
    x_msg_data          OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_site                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a party site for a bank-type organization.                   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_party_site_rec     Party site record for the bank organization. |
   |   IN/OUT:                                                             |
   |     x_psobject_version_number  Party site version number for the      |
   |                          updated bank site.                           |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Updated.                           |
   +=======================================================================*/
  PROCEDURE update_bank_site (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_party_site_rec            IN hz_party_site_v2pub.party_site_rec_type,
    p_psobject_version_number   IN OUT  NOCOPY NUMBER,
    x_return_status             OUT     NOCOPY VARCHAR2,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_edi_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates an EDI contact point.                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_edi_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_edi_rec            EDI record.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_edi_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec           IN      hz_contact_point_v2pub.edi_rec_type
                                  := hz_contact_point_v2pub.g_miss_edi_rec,
    x_contact_point_id  OUT     NOCOPY NUMBER,
    x_return_status     OUT     NOCOPY VARCHAR2,
    x_msg_count         OUT     NOCOPY NUMBER,
    x_msg_data          OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_edi_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates an EDI contact point.                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_edi_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_edi_rec            EDI record.                                  |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_edi_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec               IN  hz_contact_point_v2pub.edi_rec_type
                                  := hz_contact_point_v2pub.g_miss_edi_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_eft_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates an EFT contact point.                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_eft_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_eft_rec            EFT record.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_eft_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_eft_rec           IN      hz_contact_point_v2pub.eft_rec_type
                                  := hz_contact_point_v2pub.g_miss_eft_rec,
    x_contact_point_id  OUT     NOCOPY NUMBER,
    x_return_status     OUT     NOCOPY VARCHAR2,
    x_msg_count         OUT     NOCOPY NUMBER,
    x_msg_data          OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_eft_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates an EFT contact point.                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_eft_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_eft_rec            EFT record.                                  |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_eft_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_eft_rec               IN  hz_contact_point_v2pub.eft_rec_type
                                  := hz_contact_point_v2pub.g_miss_eft_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_web_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates a Web contact point.                                        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_web_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_web_rec            WEB record.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_web_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_web_rec           IN      hz_contact_point_v2pub.web_rec_type
                                  := hz_contact_point_v2pub.g_miss_web_rec,
    x_contact_point_id  OUT     NOCOPY NUMBER,
    x_return_status     OUT     NOCOPY VARCHAR2,
    x_msg_count         OUT     NOCOPY NUMBER,
    x_msg_data          OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_web_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates a Web contact point.                                        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_web_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_web_rec            WEB record.                                  |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_web_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_web_rec               IN  hz_contact_point_v2pub.web_rec_type
                                  := hz_contact_point_v2pub.g_miss_web_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_phone_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates a Phone contact point.                                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_phone_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_phone_rec          PHONE record.                                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_phone_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_phone_rec         IN      hz_contact_point_v2pub.phone_rec_type
                                  := hz_contact_point_v2pub.g_miss_phone_rec,
    x_contact_point_id  OUT     NOCOPY NUMBER,
    x_return_status     OUT     NOCOPY VARCHAR2,
    x_msg_count         OUT     NOCOPY NUMBER,
    x_msg_data          OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_phone_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates a Phone contact point.                                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_phone_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_phone_rec          PHONE record.                                |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_phone_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_phone_rec             IN  hz_contact_point_v2pub.phone_rec_type
                                  := hz_contact_point_v2pub.g_miss_phone_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_email_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates an Email contact point.                                     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_email_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_email_rec          EMAIL record.                                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_email_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_email_rec         IN      hz_contact_point_v2pub.email_rec_type
                                  := hz_contact_point_v2pub.g_miss_email_rec,
    x_contact_point_id  OUT     NOCOPY NUMBER,
    x_return_status     OUT     NOCOPY VARCHAR2,
    x_msg_count         OUT     NOCOPY NUMBER,
    x_msg_data          OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_email_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates an EMAIL contact point.                                     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_email_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_email_rec          EMAIL record.                                |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_email_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_email_rec             IN  hz_contact_point_v2pub.email_rec_type
                                  := hz_contact_point_v2pub.g_miss_email_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE create_telex_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates a Telex contact point.                                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_telex_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_telex_rec          TELEX record.                                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_telex_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_telex_rec         IN      hz_contact_point_v2pub.telex_rec_type
                                  := hz_contact_point_v2pub.g_miss_telex_rec,
    x_contact_point_id  OUT     NOCOPY NUMBER,
    x_return_status     OUT     NOCOPY VARCHAR2,
    x_msg_count         OUT     NOCOPY NUMBER,
    x_msg_data          OUT     NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE update_telex_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates a Telex contact point.                                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_telex_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_telex_rec          TELEX record.                                |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_telex_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_telex_rec             IN  hz_contact_point_v2pub.telex_rec_type
                                  := hz_contact_point_v2pub.g_miss_telex_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_bank                                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate bank record                                                |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_bank_rec           bank record                                  |
   |     p_mode               'I' for insert mode.                         |
   |                          'U' for update mode.                         |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   14-FEB-2006    Jianying      o Bug 4728668: Created.                |
   +=======================================================================*/

  PROCEDURE validate_bank (
    p_init_msg_list         IN     VARCHAR2 DEFAULT NULL,
    p_bank_rec              IN     bank_rec_type,
    p_mode                  IN     VARCHAR2,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_bank_branch                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate bank branch record                                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_bank_party_id      bank party id.                               |
   |     p_bank_branch_rec    bank branch record                           |
   |     p_mode               'I' for insert mode.                         |
   |                          'U' for update mode.                         |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   14-FEB-2006    Jianying      o Bug 4728668: Created.                |
   +=======================================================================*/

  PROCEDURE validate_bank_branch (
    p_init_msg_list         IN     VARCHAR2 DEFAULT NULL,
    p_bank_party_id         IN     NUMBER,
    p_bank_branch_rec       IN     bank_rec_type,
    p_mode                  IN     VARCHAR2,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2
  );

END hz_bank_pub;

 

/
