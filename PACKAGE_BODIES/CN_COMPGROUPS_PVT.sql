--------------------------------------------------------
--  DDL for Package Body CN_COMPGROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMPGROUPS_PVT" AS
  --$Header: cnvmcgb.pls 115.1 2001/10/29 17:20:29 pkm ship    $

G_PKG_NAME         CONSTANT VARCHAR2(30):='CN_CompGroups_PVT';
G_LAST_UPDATE_DATE          DATE := Sysdate;
G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
G_CREATION_DATE             DATE := Sysdate;
G_CREATED_BY                NUMBER := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

-------------------------------------------------------------------------------
-- Procedure Name : Assign_ErrorMessage                                      --
-- Purpose        : Assign the proper error message based on the error code  --
-- Parameters     :                                                          --
-- IN             : p_err_mesg           IN  NUMBER           Required       --
-- History                                                                   --
--   04-MAY-99  Ram Kalyanasundaram      Created                             --
-------------------------------------------------------------------------------
PROCEDURE Assign_ErrorMessage(p_err_mesg    IN VARCHAR2)
IS
BEGIN
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME ('CN' , p_err_mesg);
      FND_MSG_PUB.Add;
   END IF;
END Assign_ErrorMessage;

-- Start of comments
--    API name        : Move_Comp_Group
--    Type            : Public.
--    Function        : Move a compensation group; this may involve
--                      terminating the group under a particular parent and
--                      moving it to another parent effective the date of move
--                      Also update all the entries of admins adn salesreps
--    Pre-reqs        : The parent for this comp group should exist unless the
--                      the group is a toplevel group; Also this group itself
--                      should exist
--    Parameters      :
--    IN              :       p_api_version           IN NUMBER       Required
--                            Description  Standard API parameter which states
--                                         the api version; used to check
--                                         compatibility of calling code
--                            p_init_msg_list         IN VARCHAR2     Optional
--                                    Default = FND_API.G_FALSE
--                            Description  Standard API parameter which
--                                         specifies whether message stack
--                                         should be re-initialized
--                            p_commit                IN VARCHAR2     Optional
--                                    Default = FND_API.G_FALSE
--                            Description  Standard API parameter; specifies
--                                         whether a commit should be issued
--                                         on successful completion of
--                                         transaction
--                            p_validation_level      IN NUMBER       Optional
--                                    Default = FND_API.G_VALID_LEVEL_FULL
--                            Description  Standard API parameter; specifies
--                                         validation level
--                                         IMPORTANT: USE DEFAULT
--                            p_comp_group_rec        IN comp_group_rec_type Required
--                            Description  The record containing the
--                                         comp group to be moved
--                            p_effective_move_date       IN DATE     Required
--                            Description  The date on which the move is to
--                                         be made
--    OUT             :       x_return_status         OUT     VARCHAR2(1)
--                            Description  Contains the status of the call
--                                         FND_API.G_RE_STS_SUCCESS
--                                             - SUCCESS
--                                         FND_API.G_RE_STS_UNEXP_ERROR
--                                             - UNEXPECTED ERROR
--                                         FND_API.G_RE_STS_ERROR
--                                             - EXPECTED ERROR
--                            x_msg_count             OUT     NUMBER
--                            Description  The number of messages in the
--                                         message stack
--                            x_msg_data              OUT     VARCHAR2(2000)
--                            Description  Contains the message data if the
--                                         message count is 1
--    Version         : Current version       4.x?
--                            Changed  see timestamp
--                      Initial version       4.0?
--                            Created  29-APR-99  Ram Kalyanasundaram
--
--    Notes           : Note text
--  1, Check for existence of parent comp group.
--  2, Check for existence of the comp group.
--  3, Get all the groups underneath this group.
--  4, Check if the move date lies between the start and end dates of the
--     comp group.
--  5, Check if the new parent is a valid comp group and that its start date
--     and end date are atleast partially overlapping  the current comp group's
--     dates.
--  6, Insert the new comp group with an effective start date of move
--     date +1 and the old end_dates.
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
  x_msg_data                     OUT     VARCHAR2                            ) IS

   l_api_name                      CONSTANT VARCHAR2(30) := 'Move_Group';
   l_api_version                   CONSTANT NUMBER := 1.0;
   l_group_relate_id               number := 0;
   l_relation_type                 varchar2 (30) := 'PARENT_GROUP';
   l_object_version_number
     jtf_rs_grp_relations.object_version_number%TYPE;
   l_group_number                  jtf_rs_groups_b.group_number%TYPE;
   l_parent_group_number           jtf_rs_groups_b.group_number%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Move_Group_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
     l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body
   SELECT group_relate_id, object_version_number
     INTO l_group_relate_id, l_object_version_number
     FROM jtf_rs_grp_relations
     WHERE group_id = p_comp_group_rec.comp_group_id
     AND related_group_id = p_comp_group_rec.parent_comp_group_id
     AND start_date_active = p_comp_group_rec.comp_group_start_date
     AND end_date_active = p_comp_group_rec.comp_group_end_date
     AND relation_type = l_relation_type;

   SELECT group_number
     INTO l_group_number
     FROM jtf_rs_groups_b
     WHERE group_id = p_comp_group_rec.comp_group_id;

   SELECT group_number
     INTO l_parent_group_number
     FROM jtf_rs_groups_b
     WHERE group_id = p_comp_group_rec.parent_comp_group_id;

   jtf_rs_group_relate_pub.update_resource_group_relate
     (p_api_version       => p_api_version,
     p_init_msg_list      => p_init_msg_list,
     p_commit             => p_commit,
     p_group_relate_id    => l_group_relate_id,
     p_start_date_active  => p_comp_group_rec.comp_group_start_date,
     p_end_date_active    => p_effective_move_date,
     p_object_version_num => l_object_version_number,
     x_return_status      => x_return_status,
     x_msg_count          => x_msg_count,
     x_msg_data           => x_msg_data);

   jtf_rs_group_relate_pub.create_resource_group_relate
     (p_api_version         => p_api_version,
     p_init_msg_list      => p_init_msg_list,
     p_commit             => p_commit,
     p_group_id           => p_comp_group_rec.comp_group_id,
     p_group_number       => l_group_number,
     p_related_group_id   => p_comp_group_rec.parent_comp_group_id,
     p_related_group_number => l_parent_group_number,
     p_relation_type      => l_relation_type,
     p_start_date_active  => p_effective_move_date+1,
     p_end_date_active    => p_comp_group_rec.comp_group_end_date,
     x_return_status      => x_return_status,
     x_msg_count          => x_msg_count,
     x_msg_data           => x_msg_data,
     x_group_relate_id    => l_group_relate_id);

   --return success
   assign_errormessage('CN_MOVED');
   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_get(
     p_count     =>      x_msg_count             ,
     p_data       =>      x_msg_data             );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Move_Group_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(
       p_count                 =>      x_msg_count             ,
       p_data                  =>      x_msg_data              );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Move_Group_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(
       p_count                 =>      x_msg_count             ,
       p_data                  =>      x_msg_data              );
   WHEN OTHERS THEN
     ROLLBACK TO Move_Group_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME          ,
          l_api_name          );
     END IF;
     FND_MSG_PUB.Count_And_Get(
       p_count                 =>      x_msg_count             ,
       p_data                  =>      x_msg_data              );
END Move_Group;

END CN_CompGroups_PVT;

/
