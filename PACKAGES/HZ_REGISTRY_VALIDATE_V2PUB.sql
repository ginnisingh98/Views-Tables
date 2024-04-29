--------------------------------------------------------
--  DDL for Package HZ_REGISTRY_VALIDATE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_REGISTRY_VALIDATE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2RGVS.pls 120.9 2005/10/30 03:50:04 appldev noship $ */

  --------------------------------------
  -- declaration of public procedures and functions
  --------------------------------------

  --
  -- PROCEDURE validate_party
  --
  -- DESCRIPTION
  --     Validates party record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_party_rec              Party record.
  --     p_old_party_rec          Old party record.
  --     p_db_created_by_module   Current created by module
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_party(
      p_create_update_flag             IN     VARCHAR2,
      p_party_rec                      IN     HZ_PARTY_V2PUB.PARTY_REC_TYPE,
      p_old_party_rec                  IN     HZ_PARTY_V2PUB.PARTY_REC_TYPE,
      p_db_created_by_module           IN     VARCHAR2,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );

  --
  -- PROCEDURE validate_person
  --
  -- DESCRIPTION
  --     Validates person record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_person_rec         Person record.
  --     p_old_person_rec     Old person record.
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_person(
      p_create_update_flag             IN     VARCHAR2,
      p_person_rec                     IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
      p_old_person_rec                 IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );

  --
  -- PROCEDURE validate_group
  --
  -- DESCRIPTION
  --     Validates group record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_group_rec          Group record.
  --     p_old_group_rec      Old group record.
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_group(
      p_create_update_flag             IN     VARCHAR2,
      p_group_rec                      IN     HZ_PARTY_V2PUB.GROUP_REC_TYPE,
      p_old_group_rec                  IN     HZ_PARTY_V2PUB.GROUP_REC_TYPE,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );

  --
  -- PROCEDURE validate_organization
  --
  -- DESCRIPTION
  --     Validates organization record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_organization_rec       Organization record.
  --     p_old_organization_rec   Old organization record.
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_organization(
      p_create_update_flag      IN      VARCHAR2,
      p_organization_rec        IN      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
      p_old_organization_rec    IN      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
      x_return_status           IN OUT NOCOPY  VARCHAR2
  );

  --
  -- PROCEDURE validate_party_site
  --
  -- DESCRIPTION
  --     Validates party site record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_party_site_rec     Party site record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_party_site(
      p_create_update_flag              IN     VARCHAR2,
      p_party_site_rec                  IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
      p_rowid                           IN     ROWID,
      x_return_status                   IN OUT NOCOPY VARCHAR2,
      x_loc_actual_content_source       OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE validate_party_site_use
  --
  -- DESCRIPTION
  --     Validates party site use record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_party_site_use_rec Party site use record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_party_site_use(
    p_create_update_flag        IN  VARCHAR2,
    p_party_site_use_rec        IN  HZ_PARTY_SITE_V2PUB.party_site_use_rec_type,
    p_rowid                     IN  ROWID,
    x_return_status         IN OUT NOCOPY  VARCHAR2
  );

  --
  -- PROCEDURE validate_org_contact
  --
  -- DESCRIPTION
  --     Validates org contact record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_org_contact_rec    Org contact record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_org_contact(
    p_create_update_flag        IN  VARCHAR2,
    p_org_contact_rec           IN  HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type,
    p_rowid                     IN  ROWID,
    x_return_status         IN OUT NOCOPY  VARCHAR2
  );

  --
  -- PROCEDURE validate_org_contact_role
  --
  -- DESCRIPTION
  --     Validates org contact role record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag   Create update flag. 'C' = create. 'U' = update.
  --     p_org_contact_role_rec Org contact role record.
  --     p_rowid                Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status        Return status after the call. The status can
  --                            be FND_API.G_RET_STS_SUCCESS (success),
  --                            FND_API.G_RET_STS_ERROR (error),
  --                            FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_org_contact_role(
    p_create_update_flag        IN  VARCHAR2,
    p_org_contact_role_rec      IN  HZ_PARTY_CONTACT_V2PUB.org_contact_role_rec_type,
    p_rowid                     IN  ROWID,
    x_return_status         IN OUT NOCOPY  VARCHAR2
  );

  --
  -- PROCEDURE validate_person_language
  --
  -- DESCRIPTION
  --     Validates person language record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag  Create update flag. 'C' = create. 'U' = update.
  --     p_person_language_rec Person language record.
  --     p_rowid               Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status       Return status after the call. The status can
  --                           be FND_API.G_RET_STS_SUCCESS (success),
  --                           FND_API.G_RET_STS_ERROR (error),
  --                           FND_API.G_RET_STS_UNEXP_ERROR (unexpected error)
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_person_language(
    p_create_update_flag  IN     VARCHAR2,
    p_person_language_rec IN     hz_person_info_v2pub.person_language_rec_type,
    p_rowid               IN     ROWID DEFAULT NULL,
    x_return_status       IN OUT NOCOPY VARCHAR2
  );

  --
  -- PROCEDURE validate_location
  --
  -- DESCRIPTION
  --     Validates location record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_location_rec       Location record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_location(
    p_create_update_flag    IN      VARCHAR2,
    p_location_rec          IN      hz_location_v2pub.location_rec_type,
    p_rowid                 IN      ROWID DEFAULT NULL,
    x_return_status         IN OUT NOCOPY  VARCHAR2
  );

  --
  -- PROCEDURE validate_relationship_type
  --
  -- DESCRIPTION
  --     Validates relationship type record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag    Create update flag. 'C' = create. 'U' = update.
  --     p_relationship_type_rec relationship type record.
  --     p_rowid                 Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status         Return status after the call. The status can
  --                             be FND_API.G_RET_STS_SUCCESS (success),
  --                             FND_API.G_RET_STS_ERROR (error),
  --                             FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_relationship_type(
    p_create_update_flag    IN      VARCHAR2,
    p_relationship_type_rec IN      hz_relationship_type_v2pub.relationship_type_rec_type,
    p_rowid                 IN      ROWID DEFAULT NULL,
    x_return_status         IN OUT NOCOPY  VARCHAR2
  );

  --
  -- PROCEDURE validate_relationship
  --
  -- DESCRIPTION
  --     Validates relationship record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_relationship_rec   Relationship record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Indrajit Sen       o Created.
  --
  --

  PROCEDURE validate_relationship(
    p_create_update_flag IN     VARCHAR2,
    p_relationship_rec   IN     hz_relationship_v2pub.relationship_rec_type,
    p_rowid              IN     ROWID DEFAULT NULL,
    x_return_status      IN OUT NOCOPY VARCHAR2
  );

  --
  -- PROCEDURE validate_contact_point
  --
  -- DESCRIPTION
  --     Validates contact point record.  Kept for backward compatibility.
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_edi_rec            EDI record.
  --     p_email_rec          Email record.
  --     p_phone_rec          Phone record.
  --     p_telex_rec          Telex record.
  --     p_web_rec            Web record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --   20-NOV-2001   Joe del Callar      Bug 2116225: Modified to accept EFT
  --                                     records for bank consolidation.
  --                                     Bug 2117973: Modified to comply with
  --                                     PL/SQL coding standards.
  --

  PROCEDURE validate_contact_point (
    p_create_update_flag IN     VARCHAR2,
    p_contact_point_rec  IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec            IN     hz_contact_point_v2pub.edi_rec_type := hz_contact_point_v2pub.g_miss_edi_rec,
    p_email_rec          IN     hz_contact_point_v2pub.email_rec_type := hz_contact_point_v2pub.g_miss_email_rec,
    p_phone_rec          IN     hz_contact_point_v2pub.phone_rec_type := hz_contact_point_v2pub.g_miss_phone_rec,
    p_telex_rec          IN     hz_contact_point_v2pub.telex_rec_type := hz_contact_point_v2pub.g_miss_telex_rec,
    p_web_rec            IN     hz_contact_point_v2pub.web_rec_type := hz_contact_point_v2pub.g_miss_web_rec,
    p_rowid              IN     ROWID,
    x_return_status      IN OUT NOCOPY VARCHAR2
  );

  --
  -- DESCRIPTION
  --     Validates an EDI contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_edi_rec            EDI record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_edi_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec             IN     hz_contact_point_v2pub.edi_rec_type := hz_contact_point_v2pub.g_miss_edi_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  );

  --
  -- DESCRIPTION
  --     Validates an EFT contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_eft_rec            EFT record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_eft_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_eft_rec             IN     hz_contact_point_v2pub.eft_rec_type := hz_contact_point_v2pub.g_miss_eft_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  );

  --
  -- DESCRIPTION
  --     Validates an Web contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_web_rec            Web record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_web_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_web_rec             IN     hz_contact_point_v2pub.web_rec_type := hz_contact_point_v2pub.g_miss_web_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  );

  --
  -- DESCRIPTION
  --     Validates an Phone contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_phone_rec          Phone record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_phone_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_phone_rec           IN     hz_contact_point_v2pub.phone_rec_type := hz_contact_point_v2pub.g_miss_phone_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  );

  --
  -- DESCRIPTION
  --     Validates an Telex contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_telex_rec          Telex record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_telex_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_telex_rec           IN     hz_contact_point_v2pub.telex_rec_type := hz_contact_point_v2pub.g_miss_telex_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  );

  --
  -- DESCRIPTION
  --     Validates an Email contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_contact_point_rec  Contact point record.
  --     p_email_rec          Email record.
  --     p_rowid              Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --   05-DEC-2001   Joe del Callar      Bug 2136283: Created to improve
  --                                     backward compatibility.
  --
  PROCEDURE validate_email_contact_point (
    p_create_update_flag  IN     VARCHAR2,
    p_contact_point_rec   IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_email_rec           IN     hz_contact_point_v2pub.email_rec_type := hz_contact_point_v2pub.g_miss_email_rec,
    p_rowid               IN     ROWID,
    x_return_status       IN OUT NOCOPY VARCHAR2
  );

  --
  -- DESCRIPTION
  --     Validates  nonsupported columns in Organization Profile
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --     p_create_update_flag Create update flag. 'C' = create. 'U' = update.
  --     p_organization_rec   Organization record.
  --   IN/OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-25-2002    Kate Shan     o Created.

  PROCEDURE  validate_org_nonsupport_column (
    p_create_update_flag  IN     VARCHAR2,
    p_organization_rec    IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    x_return_status       IN OUT NOCOPY VARCHAR2
);


--Made tax_location_validation a public procedure as it needs to be called by the DNB code.

  PROCEDURE tax_location_validation(
      p_location_rec              IN      hz_location_v2pub.location_rec_type,
      p_create_update_flag        IN      VARCHAR2,
      x_return_status             IN OUT NOCOPY  VARCHAR2
 );

  PROCEDURE validate_financial_report(
      p_create_update_flag                    IN      VARCHAR2,
      p_financial_report_rec                  IN      HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE,
      p_rowid                                 IN      ROWID,
      x_return_status                         IN OUT  NOCOPY  VARCHAR2
 );

--bug 3942332:added out parameter x_actual_content_source
  PROCEDURE validate_financial_number(
      p_create_update_flag                    IN      VARCHAR2,
      p_financial_number_rec                  IN      HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE,
      p_rowid                                 IN      ROWID,
      x_return_status                         IN OUT  NOCOPY  VARCHAR2,
      x_actual_content_source                 OUT NOCOPY    VARCHAR2
 );

  PROCEDURE validate_credit_rating(
      p_create_update_flag                    IN      VARCHAR2,
      p_credit_rating_rec                     IN      HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE,
      p_rowid                                 IN      ROWID,
      x_return_status                         IN OUT NOCOPY  VARCHAR2
 );

 --
  -- PROCEDURE validate_citizenship
  --
  -- DESCRIPTION
  --     Validates citizenship record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_citizenship_rec        Citizenship record.
  --     p_rowid                  Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-Jan-2003    Porkodi C   o Created.
  --
  --

  PROCEDURE validate_citizenship(
      p_create_update_flag             IN     VARCHAR2,
      p_citizenship_rec                IN     HZ_PERSON_INFO_V2PUB.CITIZENSHIP_REC_TYPE,
      p_rowid                          IN     ROWID DEFAULT NULL,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );


  --
  -- PROCEDURE validate_education
  --
  -- DESCRIPTION
  --     Validates education record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_education_rec          Education record.
  --     p_rowid                  Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-Jan-2003    Porkodi C   o Created.
  --
  --

  PROCEDURE validate_education(
      p_create_update_flag             IN     VARCHAR2,
      p_education_rec                  IN     HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE,
      p_rowid                          IN     ROWID DEFAULT NULL,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );


  --
  -- PROCEDURE validate_employment_history
  --
  -- DESCRIPTION
  --     Validates employment history record. Checks for
  --         uniqueness
  --         lookup types
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_employment_history_rec Employment history record.
  --     p_rowid                  Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-Jan-2003    Porkodi C   o Created.
  --
  --

  PROCEDURE validate_employment_history(
      p_create_update_flag             IN     VARCHAR2,
      p_employment_history_rec         IN     HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE,
      p_rowid                          IN     ROWID DEFAULT NULL,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  );

    --
    -- PROCEDURE validate_work_class
    --
    -- DESCRIPTION
    --     Validates work class record. Checks for
    --         uniqueness
    --         mandatory columns
    --         non-updateable fields
    --
    -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
    --
    -- ARGUMENTS
    --   IN:
    --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
    --     p_work_class_rec         Work class record.
    --     p_rowid                  Rowid of the record (used only in update mode).
    --   IN/OUT:
    --     x_return_status          Return status after the call. The status can
    --                              be FND_API.G_RET_STS_SUCCESS (success),
    --                              FND_API.G_RET_STS_ERROR (error),
    --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
    --
    -- NOTES
    --
    -- MODIFICATION HISTORY
    --
    --   02-Feb-2003    Porkodi C   o Created.
    --
    --

    PROCEDURE validate_work_class(
        p_create_update_flag             IN     VARCHAR2,
        p_work_class_rec                 IN     HZ_PERSON_INFO_V2PUB.WORK_CLASS_REC_TYPE,
        p_rowid                          IN     ROWID DEFAULT NULL,
        x_return_status                  IN OUT NOCOPY VARCHAR2
  );


     --
     -- PROCEDURE validate_person_interest
     --
     -- DESCRIPTION
     --     Validates work class record. Checks for
     --         uniqueness
     --         mandatory columns
     --         non-updateable fields
     --
     -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
     --
     -- ARGUMENTS
     --   IN:
     --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
     --     p_person_interest_rec         Work class record.
     --     p_rowid                  Rowid of the record (used only in update mode).
     --   IN/OUT:
     --     x_return_status          Return status after the call. The status can
     --                              be FND_API.G_RET_STS_SUCCESS (success),
     --                              FND_API.G_RET_STS_ERROR (error),
     --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
     --
     -- NOTES
     --
     -- MODIFICATION HISTORY
     --
     --   02-Feb-2003    Porkodi C   o Created.
     --
     --

     PROCEDURE validate_person_interest(
         p_create_update_flag             IN     VARCHAR2,
         p_person_interest_rec            IN     HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE,
         p_rowid                          IN     ROWID DEFAULT NULL,
         x_return_status                  IN OUT NOCOPY VARCHAR2
   );



END hz_registry_validate_v2pub;

 

/
