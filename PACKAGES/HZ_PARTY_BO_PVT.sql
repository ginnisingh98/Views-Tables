--------------------------------------------------------
--  DDL for Package HZ_PARTY_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBPTVS.pls 120.9 2006/07/22 00:17:55 acng noship $ */

  G_CALL_UPDATE_CUST_BO       VARCHAR2(1) := NULL;

  -- PROCEDURE save_party_preferences
  --
  -- DESCRIPTION
  --     Create or update party preferences.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_pref_objs    List of party preference objects.
  --     p_party_id           Party Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_party_preferences(
    p_party_pref_objs            IN OUT NOCOPY HZ_PARTY_PREF_OBJ_TBL,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE create_relationships
  --
  -- DESCRIPTION
  --     Create relationships.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_rel_objs           List of relationship objects.
  --     p_subject_id         Subject Id.
  --     p_subject_type       Subject type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_relationships(
    p_rel_objs                   IN OUT NOCOPY HZ_RELATIONSHIP_OBJ_TBL,
    p_subject_id                 IN         NUMBER,
    p_subject_type               IN         VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  PROCEDURE create_relationship_obj(
    p_init_msg_list       IN         VARCHAR2 := fnd_api.g_false,
    p_rel_obj             IN OUT NOCOPY HZ_RELATIONSHIP_OBJ,
    p_created_by_module   IN         VARCHAR2,
    x_relationship_id     OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
  );

  PROCEDURE update_relationship_obj(
    p_init_msg_list       IN         VARCHAR2 := fnd_api.g_false,
    p_rel_obj             IN OUT NOCOPY HZ_RELATIONSHIP_OBJ,
    x_relationship_id     OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
  );

  PROCEDURE save_relationship_obj(
    p_init_msg_list       IN         VARCHAR2 := fnd_api.g_false,
    p_rel_obj             IN OUT NOCOPY HZ_RELATIONSHIP_OBJ,
    p_created_by_module   IN         VARCHAR2,
    x_relationship_id     OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_relationships
  --
  -- DESCRIPTION
  --     Create or update relationships.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_rel_objs           List of relationship objects.
  --     p_subject_id         Subject Id.
  --     p_subject_type       Subject type.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_relationships(
    p_rel_objs                   IN OUT NOCOPY HZ_RELATIONSHIP_OBJ_TBL,
    p_subject_id                 IN         NUMBER,
    p_subject_type               IN         VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE get_relationship_obj
  --
  -- DESCRIPTION
  --     Get relationship.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_relationship_id    Relationship Id.
  --   OUT:
  --     x_relationship_obj   Relationship object.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE get_relationship_obj(
    p_init_msg_list		 IN         VARCHAR2 := FND_API.G_FALSE,
    p_relationship_id            IN         NUMBER,
    x_relationship_obj           OUT NOCOPY HZ_RELATIONSHIP_OBJ,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE create_classifications
  --
  -- DESCRIPTION
  --     Create classifications.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_code_assign_objs   List of classification objects.
  --     p_owner_table_name   Owner table name.
  --     p_owner_table_id     Owner table Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_classifications(
    p_code_assign_objs           IN OUT NOCOPY HZ_CODE_ASSIGNMENT_OBJ_TBL,
    p_owner_table_name           IN         VARCHAR2,
    p_owner_table_id             IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_classifications
  --
  -- DESCRIPTION
  --     Create or update classifications.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_code_assign_objs   List of classification objects.
  --     p_owner_table_name   Owner table name.
  --     p_owner_table_id     Owner table Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_classifications(
    p_code_assign_objs           IN OUT NOCOPY HZ_CODE_ASSIGNMENT_OBJ_TBL,
    p_owner_table_name           IN         VARCHAR2,
    p_owner_table_id             IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE create_certifications
  --
  -- DESCRIPTION
  --     Create certifications.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cert_objs          List of certification objects.
  --     p_party_id           Party Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_certifications(
    p_cert_objs                  IN OUT NOCOPY hz_certification_obj_tbl,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_certifications
  --
  -- DESCRIPTION
  --     Create or update certifications.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cert_objs          List of certification objects.
  --     p_party_id           Party Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_certifications(
    p_cert_objs                  IN OUT NOCOPY hz_certification_obj_tbl,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE create_financial_profiles
  --
  -- DESCRIPTION
  --     Create financial profiles.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_fin_prof_objs      List of financial profile objects.
  --     p_party_id           Party Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_financial_profiles(
    p_fin_prof_objs              IN OUT NOCOPY hz_financial_prof_obj_tbl,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_financial_profiles
  --
  -- DESCRIPTION
  --     Create or update financial profiles.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_fin_prof_objs      List of financial profile objects.
  --     p_party_id           Party Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_financial_profiles(
    p_fin_prof_objs              IN OUT NOCOPY hz_financial_prof_obj_tbl,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );


  -- PROCEDURE create_party_usage_assgmnt
  --
  -- DESCRIPTION
  --     Create Party Usage Assignment.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_usg_objs       List of Party Usage objects.
  --     p_party_id           Party Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-Mar-2006   Hadi Alatasi           Created.
  --


   PROCEDURE create_party_usage_assgmnt(
    p_party_usg_objs             IN OUT NOCOPY HZ_PARTY_USAGE_OBJ_TBL,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2
  );

-- PROCEDURE Save_party_usage_assgmnt
  --
  -- DESCRIPTION
  --     Create or update Party Usage Assignment.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_usg_objs       List of Party Usage objects.
  --     p_party_id           Party Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-Mar-2006   Hadi Alatasi           Created.
  --

  PROCEDURE save_party_usage_assgmnt(
    p_party_usg_objs             IN OUT NOCOPY HZ_PARTY_USAGE_OBJ_TBL,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2
  );


  -- PROCEDURE call_bes
  --
  -- DESCRIPTION
  --     Call business event.  This procedure will be called from
  --     Organization, Organization Customer, Person, Person Customer
  --     BO API.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_id           Party Id.
  --     p_bo_code            Business Object Code.
  --     p_create_or_update   Create or Update Flag.
  --     p_event_id           Business event ID.
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-OCT-2005    Arnold Ng          Created.
  --   15-DEC-2005    Arnold Ng          Add p_event_id.
  --

  PROCEDURE call_bes(
    p_party_id          IN NUMBER,
    p_bo_code           IN VARCHAR2,
    p_create_or_update  IN VARCHAR2,
    p_obj_source        IN VARCHAR2,
    p_event_id          IN NUMBER
  );

  -- FUNCTION is_raising_create_event
  --
  -- DESCRIPTION
  --     Return true if raise BES event per object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_obj_complete_flag   Flag indicates if object is complete
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-OCT-2005    Arnold Ng          Created.
  --

  FUNCTION is_raising_create_event(
    p_obj_complete_flag       IN BOOLEAN
  ) RETURN BOOLEAN;

  -- PROCEDURE is_raising_update_event
  --
  -- DESCRIPTION
  --     Return true if BO_VERSION number for party record is same as
  --     HZ_BUS_OBJ_DEFINITIONS table for a particular business object
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_id           Party Id.
  --     p_bo_code            Business object code.
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-OCT-2005    Arnold Ng          Created.
  --

  FUNCTION is_raising_update_event(
    p_party_id       IN NUMBER,
    p_bo_code        IN VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION return_all_messages(
    x_return_status  IN VARCHAR2,
    x_msg_count      IN NUMBER,
    x_msg_data       IN VARCHAR2
  ) RETURN HZ_MESSAGE_OBJ_TBL;

END HZ_PARTY_BO_PVT;

 

/
