--------------------------------------------------------
--  DDL for Package CS_KB_SOLN_CATEGORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SOLN_CATEGORIES_PVT" AUTHID CURRENT_USER AS
/* $Header: csvcats.pls 120.0 2005/06/01 09:48:07 appldev noship $ */

INDEX_SYNC_FAILED       EXCEPTION;
CG_MEMBER_DEL_FAILED    EXCEPTION;

  -- this API is used by JTT, obsoleted
  procedure createCategory
  (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    p_parent_category_id in number,
    p_name               in varchar2,
    p_description        in varchar2,
    x_category_id        OUT NOCOPY number
  );

  -- this new API is called from OA, core should use this one instead
  procedure createCategory
  (
    p_category_id        in number,
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    p_parent_category_id in number,
    p_name               in varchar2,
    p_description        in varchar2,
    x_category_id        OUT NOCOPY number,
    p_visibility_id      in number
  );

  procedure removeCategory
  (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    p_category_id        in number
  );

  procedure removeCategoryCascade
  (
    p_api_version        in number,
    p_category_id        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2
  );

  -- this new API is called from OA, core should use this one instead
  procedure updateCategory
  (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    p_category_id        in number,
    p_parent_category_id in number,
    p_name               in varchar2,
    p_description        in varchar2,
    p_visibility_id      in number
  );

  -- this API is used by JTT, obsoleted
  procedure updateCategory
  (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    p_category_id        in number,
    p_parent_category_id in number,
    p_name               in varchar2,
    p_description        in varchar2
  );

  procedure addSolutionToCategory
  (
    p_api_version           in  number,
    p_init_msg_list         in  varchar2   := FND_API.G_FALSE,
    p_commit                in  varchar2   := FND_API.G_FALSE,
    p_validation_level      in  number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY varchar2,
    x_msg_count             OUT NOCOPY number,
    x_msg_data              OUT NOCOPY varchar2,
    p_solution_id           in  number,
    p_category_id           in  number,
    x_soln_category_link_id OUT NOCOPY number
  );

  procedure removeSolutionFromCategory
  (
    p_api_version        in number,
    p_init_msg_list      in varchar2   := FND_API.G_FALSE,
    p_commit             in varchar2   := FND_API.G_FALSE,
    p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY varchar2,
    x_msg_count          OUT NOCOPY number,
    x_msg_data           OUT NOCOPY varchar2,
    p_solution_id        in number,
    p_category_id        in number
  );

 function secure_cat_fullpath_names( category_id number, separator varchar2 ) return varchar2;
 function admin_cat_fullpath_names ( category_id number, separator varchar2 ) return varchar2;
 function admin_cat_fullpath_ids   ( category_id number ) return varchar2;
 function has_pub_wip_descendents  ( category_id number) return varchar2;

END CS_KB_SOLN_CATEGORIES_PVT;

 

/
