--------------------------------------------------------
--  DDL for Package CN_COMPGROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMPGROUPS_PVT" AUTHID CURRENT_USER AS
  --$Header: cnvmcgs.pls 115.1 2001/10/29 17:20:30 pkm ship    $

  TYPE comp_group_rec_type IS RECORD
     (parent_comp_group_id    cn_comp_groups.comp_group_id%TYPE
                                        := fnd_api.g_miss_char,
      comp_group_id           cn_comp_groups.comp_group_id%TYPE,
      comp_group_start_date   cn_comp_group_hier.start_date_active%TYPE,
      comp_group_end_date     cn_comp_group_hier.end_date_active%TYPE
                                        := fnd_api.g_miss_date);

-- Start of comments
--    API name        : Move_Group
--    Type            : Private.
--    Function        : Move a compensation group; this may involve
--                      terminating the group under a particular parent and
--                      moving it to another parent effective the date of move
--                      Also update all the entries of admins adn salesreps
--    Pre-reqs        : The parent for this comp group should exist unless the
--                      the group is a toplevel group; Also this group itself
--                      should exist
--    Parameters      :
--    IN              :       p_api_version           IN NUMBER       Required
--                            Description: Standard API parameter which states
--                                         the api version; used to check
--                                         compatibility of calling code
--                            p_init_msg_list         IN VARCHAR2     Optional
--                                    Default = FND_API.G_FALSE
--                            Description: Standard API parameter which
--                                         specifies whether message stack
--                                         should be re-initialized
--                            p_commit                IN VARCHAR2     Optional
--                                    Default = FND_API.G_FALSE
--                            Description: Standard API parameter; specifies
--                                         whether a commit should be issued
--                                         on successful completion of
--                                         transaction
--                            p_validation_level      IN NUMBER       Optional
--                                    Default = FND_API.G_VALID_LEVEL_FULL
--                            Description: Standard API parameter; specifies
--                                         validation level
--                                         IMPORTANT: USE DEFAULT
--                            p_comp_group_rec        IN comp_group_rec_type Required
--                            Description: The record containing the
--                                         comp group to be moved
--                            p_effective_move_date       IN DATE     Required
--                            Description: The date on which the move is to
--                                         be made
--    OUT             :       x_return_status         OUT     VARCHAR2(1)
--                            Description: Contains the status of the call
--                                         FND_API.G_RE_STS_SUCCESS
--                                             - SUCCESS
--                                         FND_API.G_RE_STS_UNEXP_ERROR
--                                             - UNEXPECTED ERROR
--                                         FND_API.G_RE_STS_ERROR
--                                             - EXPECTED ERROR
--                            x_msg_count             OUT     NUMBER
--                            Description: The number of messages in the
--                                         message stack
--                            x_msg_data              OUT     VARCHAR2(2000)
--                            Description: Contains the message data if the
--                                         message count is 1
--    Version         : Current version       4.x?
--                            Changed: see timestamp
--                      Initial version       4.0?
--                            Created: 31-JAN-00  Ram Kalyanasundaram
--
--    Notes           : Note text
--
-- End of comments

PROCEDURE Move_Group
  (p_api_version                 IN      NUMBER                              ,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE         ,
  p_commit                       IN      VARCHAR2 := FND_API.G_FALSE         ,
  p_validation_level             IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_comp_group_rec               IN      comp_group_rec_type                 ,
  p_effective_move_date          IN      date                                ,
  p_new_parent_group_id          IN      cn_comp_groups.comp_group_id%TYPE   ,
  x_return_status                OUT     VARCHAR2                            ,
  x_msg_count                    OUT     NUMBER                              ,
  x_msg_data                     OUT     VARCHAR2                            );

END CN_CompGroups_PVT;

 

/
