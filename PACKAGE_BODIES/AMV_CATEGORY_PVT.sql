--------------------------------------------------------
--  DDL for Package Body AMV_CATEGORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_CATEGORY_PVT" AS
/* $Header: amvvcatb.pls 120.1 2005/12/06 09:34:37 mkettle noship $ */
--
-- NAME
--   AMV_CATEGORY_PVT
--
-- HISTORY
--   07/19/1999        SLKRISHN        CREATED
--   12/20/2002         Kalyan          Modified pls refer bug#2626331,2720397
--
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMV_CATEGORY_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'amvvcatb.pls';

G_RESOURCE_ID   CONSTANT NUMBER := -1;
G_USER_ID               CONSTANT NUMBER := -1;
G_LOGIN_USER_ID CONSTANT NUMBER := -1;
--
----------------------------- Private Portion ---------------------------------
--------------------------------------------------------------------------------
-- We use the following private utility procedures
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Validate_CategoryStatus
(
     x_return_status     OUT NOCOPY VARCHAR2,
     p_category_id              IN  NUMBER   := FND_API.G_MISS_NUM,
     p_category_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_parent_category_id       IN  NUMBER   := FND_API.G_MISS_NUM,
     p_parent_category_name     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     x_exist_flag        OUT NOCOPY VARCHAR2,
     x_category_id       OUT NOCOPY NUMBER,
     x_error_msg         OUT NOCOPY VARCHAR2,
     x_error_token       OUT NOCOPY VARCHAR2
);
--
FUNCTION Get_CategoryId
(
     p_category_name            IN  VARCHAR2,
     p_parent_category_id       IN  NUMBER := FND_API.G_MISS_NUM
) RETURN NUMBER;
--
FUNCTION Get_CategoryName
(
     p_category_id              IN  NUMBER
) RETURN VARCHAR2;
--
PROCEDURE Get_CategoryHierarchy
(
    p_category_id               IN  NUMBER,
    p_category_level            IN  NUMBER,
    p_category_hierarchy        IN OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
);
--
PROCEDURE Get_CategoryParents
(
    p_category_id               IN  NUMBER,
    p_category_level            IN  NUMBER,
    p_category_hierarchy        IN OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
);
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Validate_CategoryStatus
--    Type       : Private
--    Pre-reqs   : None
--    Function   : check if category (p_category_id/p_category_name) exist
--                 return the category id if existing.
--    Parameters :
--                 p_category_id                      IN  NUMBER    Optional
--                   category id. Default = FND_API.G_MISS_NUM
--                 p_category_name                    IN  VARCHAR2  Optional
--                   category name. Default = FND_API.G_MISS_CHAR
--                   Either pass the category id (preferred) or category name
--                   to identify the category.
--                 p_parent_category_id               IN  NUMBER    Optional
--                   parent category id. Default = FND_API.G_MISS_NUM
--                 p_parent_category_name             IN  VARCHAR2  Optional
--                   parent category name. Default = FND_API.G_MISS_CHAR
--                   Pass parent category id or name along with category name
--                   to identify sub category
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_exist_flag                       OUT VARCHAR2
--                    category existent flag
--                 x_category_id                      OUT NUMBER
--                    category id which is valid if x_exist_flag is true.
--                 x_error_msg                        OUT VARCHAR2
--                    error message
--                 x_error_token                        OUT VARCHAR2
--                    error token
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Validate_CategoryStatus
(
     x_return_status     OUT NOCOPY VARCHAR2,
     p_category_id              IN  NUMBER   := FND_API.G_MISS_NUM,
     p_category_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_parent_category_id       IN  NUMBER   := FND_API.G_MISS_NUM,
     p_parent_category_name     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     x_exist_flag        OUT NOCOPY VARCHAR2,
     x_category_id       OUT NOCOPY NUMBER,
     x_error_msg         OUT NOCOPY VARCHAR2,
     x_error_token       OUT NOCOPY VARCHAR2) IS
--
l_category_id           number;
--
BEGIN
    IF (p_category_id IS NULL OR p_category_name IS NULL) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    IF p_category_id <> FND_API.G_MISS_NUM THEN
      IF p_category_name <> FND_API.G_MISS_CHAR THEN
                -- passed both id and name. id taken by default.
                x_error_msg:='AMV_CAT_ID_AND_NAME_PASSED';
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) THEN
                -- Category Id exists
        x_exist_flag := FND_API.G_TRUE;
                x_category_id := p_category_id;
                x_error_msg:='AMV_CAT_ID_EXISTS';
                x_error_token := p_category_id;
      ELSE
        -- Invalid category id
        x_exist_flag := FND_API.G_FALSE;
        x_category_id := FND_API.G_MISS_NUM;
                x_error_msg:='AMV_CAT_ID_NOT_EXIST';
                x_error_token := p_category_id;
      END IF;
    ELSE
      IF p_category_name <> FND_API.G_MISS_CHAR THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF p_parent_category_id = FND_API.G_MISS_NUM OR
           p_parent_category_id IS NULL
        THEN
                IF p_parent_category_name = FND_API.G_MISS_CHAR THEN
                        x_category_id :=Get_CategoryId(p_category_name);
                        IF x_category_id <> FND_API.G_MISS_NUM THEN
                                x_exist_flag := FND_API.G_TRUE;
                                     x_error_msg:='AMV_CAT_NAME_EXISTS';
                                        x_error_token := p_category_name;
                        ELSE
                               -- Invalid category name
                               x_exist_flag := FND_API.G_FALSE;
                                       x_error_msg:='AMV_CAT_NAME_NOT_EXIST';
                                       x_error_token := p_category_name;
                        END IF;
                ELSE
                        -- validation for sub category
                        l_category_id := Get_CategoryId(p_parent_category_name);
                        IF l_category_id <> FND_API.G_MISS_NUM THEN
                                x_category_id :=Get_CategoryId(p_category_name,
                                                                l_category_id);
                                IF x_category_id <> FND_API.G_MISS_NUM THEN
                                    x_exist_flag := FND_API.G_TRUE;
                                    x_error_msg :='AMV_CAT_NAME_EXISTS';
                                    x_error_token := p_category_name;
                                ELSE
                                    -- Invalid subcategory name
                                    x_exist_flag := FND_API.G_FALSE;
                                    x_error_msg:='AMV_CAT_NAME_NOT_EXIST';
                                    x_error_token := p_category_name;
                                END IF;
                        ELSE
                                 -- Invalid parent name for subcategory
                                 x_exist_flag := FND_API.G_FALSE;
                                 x_error_msg := 'AMV_CAT_NAME_NOT_EXIST';
                                 x_error_token := p_parent_category_name;
                        END IF;
                END IF;
        ELSE
               -- validation for sub category
               IF p_parent_category_name <> FND_API.G_MISS_CHAR THEN
                        -- passed both id and name. id taken by default.
                        x_error_msg := 'AMV_CAT_ID_AND_NAME_PASSED';
               END IF;
               -- check if parent category id is valid
         IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_parent_category_id) THEN
                        x_category_id :=Get_CategoryId( p_category_name,
                                                p_parent_category_id);
                        IF x_category_id <> FND_API.G_MISS_NUM THEN
                        x_exist_flag := FND_API.G_TRUE;
                                x_error_msg := 'AMV_CAT_NAME_EXISTS';
                                x_error_token := p_category_name;
                ELSE
                        -- Invalid subcategory name
                        x_exist_flag := FND_API.G_FALSE;
                                x_error_msg := 'AMV_CAT_NAME_NOT_EXIST';
                                x_error_token := p_category_name;
                END IF;
               ELSE
                -- Invalid parent category id
                x_exist_flag := FND_API.G_FALSE;
                        x_error_msg := 'AMV_CAT_ID_NOT_EXIST';
                        x_error_token := p_parent_category_id;
               END IF;
        END IF;
      ELSE
                -- 'Must pass either category id or category name to identify'
                RAISE  FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    --
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_exist_flag := FND_API.G_FALSE;
        x_category_id := FND_API.G_MISS_NUM;
        x_error_msg := 'AMV_CAT_ID_OR_NAME_NULL';
                x_error_token := null;
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_exist_flag := FND_API.G_FALSE;
        x_category_id := FND_API.G_MISS_NUM;
        x_error_msg := 'AMV_CAT_ID_AND_NAME_MISS';
                x_error_token := null;
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_exist_flag := FND_API.G_FALSE;
        x_category_id := FND_API.G_MISS_NUM;
        x_error_msg := 'AMV_CAT_VALIDATION_FAILED';
                x_error_token := substrb(sqlerrm, 1, 80);
END Validate_CategoryStatus;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_CategoryId
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns category id for a category or subcategory name.
--    Parameters :
--            IN : p_category_name              IN  VARCHAR2  Required
--                      (sub)category id
--                 p_parent_category_id         IN  NUMBER    Optional
--                      Default = FND_API.G_MISS_NUM
--                      parent category id
--           OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Get_CategoryId
(
     p_category_name            IN  VARCHAR2,
     p_parent_category_id       IN  NUMBER := FND_API.G_MISS_NUM
) RETURN NUMBER
IS
l_category_id           number;
--
CURSOR Get_CategoryId is
select b.channel_category_id
from   amv_c_categories_b b, amv_c_categories_tl tl
where  tl.channel_category_name = p_category_name
and    tl.language = userenv('lang')
and    tl.channel_category_id = b.channel_category_id
and    b.parent_channel_category_id is null;
--
CURSOR Get_SubCategoryId is
select b.channel_category_id
from   amv_c_categories_b b, amv_c_categories_tl tl
where  tl.channel_category_name = p_category_name
and    tl.language = userenv('lang')
and    tl.channel_category_id = b.channel_category_id
and    b.parent_channel_category_id = p_parent_category_id;
--
BEGIN
    IF p_category_name = FND_API.G_MISS_CHAR OR
       p_category_name IS NULL
    THEN
        l_category_id := FND_API.G_MISS_NUM;
        RETURN l_category_id;
    END IF;
    --
    IF p_parent_category_id = FND_API.G_MISS_NUM OR
       p_parent_category_id IS NULL THEN
         -- get category id
         OPEN Get_CategoryId;
         FETCH Get_CategoryId INTO l_category_id;
          IF Get_CategoryId%NOTFOUND THEN
                l_category_id := FND_API.G_MISS_NUM;
          END IF;
         CLOSE Get_CategoryId;
    ELSE
         -- get sub category id by catgeory id
         OPEN Get_SubCategoryId;
         FETCH Get_SubCategoryId INTO l_category_id;
          IF Get_SubCategoryId%NOTFOUND THEN
                l_category_id := FND_API.G_MISS_NUM;
          END IF;
         CLOSE Get_SubCategoryId;
    END IF;
    --
    RETURN l_category_id;
    --
END Get_CategoryId;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_CategoryName
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns category name for a category id.
--    Parameters :
--            IN : p_category_id                IN  NUMBER  Required
--                      (sub)category id
--           OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Get_CategoryName
(
        p_category_id           IN  NUMBER
)
RETURN VARCHAR2
IS
l_category_name         varchar2(80);
--
CURSOR Get_CategoryName IS
select  channel_category_name
from    amv_c_categories_tl
where   channel_category_id = p_category_id
and     language = userenv('lang');
BEGIN
    IF p_category_id = FND_API.G_MISS_NUM OR
       p_category_id IS NULL THEN
        l_category_name := FND_API.G_MISS_CHAR;
        RETURN l_category_name;
    END IF;
    --
    OPEN Get_CategoryName;
     FETCH Get_CategoryName INTO l_category_name;
          IF Get_CategoryName%NOTFOUND THEN
                l_category_name := FND_API.G_MISS_CHAR;
          END IF;
    CLOSE Get_CategoryName;
    --
    RETURN l_category_name;
    --
END Get_CategoryName;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_CategoryHierarchy
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns the sub category hierarchy for a category id.
--    Parameters :
--            IN : p_category_id                IN  NUMBER  Required
--                      (sub)category id
--                 p_category_level             IN  NUMBER  Required
--                      category hierarchy level
--                 p_category_hierarchy IN OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--                                                      Required,
--                      array of category id and level
--           OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_CategoryHierarchy
(
    p_category_id               IN  NUMBER,
    p_category_level            IN  NUMBER,
    p_category_hierarchy        IN OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
--
 l_cat_id       number := p_category_id;
 l_cat_hr       number := p_category_level;
 l_counter      number ;
 l_cat_name      varchar2(80);
 l_temp_cat_name varchar2(80);
--
cursor scat_id is
 select A.channel_category_id, channel_category_name
 from amv_c_categories_b A, amv_c_categories_tl  B
 where parent_channel_category_id = l_cat_id
 and A.channel_category_id = B.channel_category_id
 and B.language = USERENV('LANG')
 order by channel_category_name;
--
BEGIN

 l_counter := p_category_hierarchy.count + 1;
 l_cat_name := Get_CategoryName(l_cat_id);
 p_category_hierarchy.extend;
 p_category_hierarchy(l_counter).hierarchy_level := l_cat_hr;
 p_category_hierarchy(l_counter).id := l_cat_id;
 p_category_hierarchy(l_counter).name := l_cat_name;
 /*
 p_category_hierarchy(l_counter):=amv_cat_hierarchy_obj_type(l_cat_hr,
                                                                                                 l_cat_id,
                                                                                                 l_cat_name);
 */
 l_cat_hr := l_cat_hr + 1;

 if AMV_UTILITY_PVT.Is_CategoryIdValid(l_cat_id) then
 open scat_id;
    loop
        fetch scat_id into l_cat_id, l_temp_cat_name;
                exit when scat_id%notfound;
                Get_CategoryHierarchy(l_cat_id, l_cat_hr, p_category_hierarchy);
    end loop;
 close scat_id;
 end if;

END Get_CategoryHierarchy;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_CategoryParents
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns the sub category hierarchy for a category id.
--    Parameters :
--            IN : p_category_id                IN  NUMBER  Required
--                      (sub)category id
--                 p_category_level             IN  NUMBER  Required
--                      category hierarchy level
--                 p_category_hierarchy IN OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--                                                      Required,
--                      array of category id and level
--           OUT : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_CategoryParents
(
    p_category_id               IN  NUMBER,
    p_category_level            IN  NUMBER,
    p_category_hierarchy        IN OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
--
 l_cat_id       number := p_category_id;
 l_cat_hr       number := p_category_level;
 l_cat_name     varchar2(80);
--
cursor get_parent is
select parent_channel_category_id
from   amv_c_categories_b
where  channel_category_id = l_cat_id;
--
BEGIN

 l_cat_name := Get_CategoryName(l_cat_id);
 p_category_hierarchy.extend;
 p_category_hierarchy(l_cat_hr).hierarchy_level := l_cat_hr;
 p_category_hierarchy(l_cat_hr).id := l_cat_id;
 p_category_hierarchy(l_cat_hr).name := l_cat_name;
 /*
 p_category_hierarchy(l_cat_hr):=amv_cat_hierarchy_obj_type(l_cat_hr,
                                                                                                l_cat_id,
                                                                                                l_cat_name);
 */

 l_cat_hr := l_cat_hr + 1;

 if AMV_UTILITY_PVT.Is_CategoryIdValid(l_cat_id) then
 open get_parent;
  fetch get_parent into l_cat_id;
  if l_cat_id is not null then
        Get_CategoryParents(l_cat_id, l_cat_hr, p_category_hierarchy);
  end if;
 close get_parent;
 end if;

END Get_CategoryParents;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Add_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create channel (sub)category.
--    Parameters :
--    IN         : p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_application_id                   IN  NUMBER    Optional
--                        Default = AMV_UTILITY_PVT.G_AMV_APP_ID (520)
--                 p_category_name                    IN  VARCHAR2  Required
--                      the channel (sub)category name. Have to be unique.
--                 p_description                      IN  VARCHAR2  Optional
--                      the channel (sub)category description.
--                 p_parent_category_id               IN  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_parent_category_name             IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    parent id or name required for creating sub categories.
--                 p_order                            IN  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                      the order of this (sub)category among all the categories
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--                 x_chan_category_id                 OUT NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_Category
(
 p_api_version          IN  NUMBER,
 p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
 p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2,
 p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
 p_application_id       IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
 p_category_name        IN  VARCHAR2,
 p_description          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_parent_category_id   IN  NUMBER := FND_API.G_MISS_NUM,
 p_parent_category_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_order                IN  NUMBER := FND_API.G_MISS_NUM,
 x_category_id     OUT NOCOPY NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Add_Category';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number := 1;
--
l_row_id                varchar2(30);
l_category_id           number;
l_parent_category_id    number;
l_category_exist_flag   varchar2(1);
l_setup_result   varchar2(1);
l_order                 number;
--

CURSOR CategoryId_Seq IS
SELECT amv_c_categories_b_s.nextval
FROM   dual;

CURSOR Max_CategoryOrder IS
SELECT NVL(MAX(channel_category_order) + 1, 1)
FROM   amv_c_categories_b
WHERE  parent_channel_category_id is null
and       application_id = p_application_id;

CURSOR Max_SubCategoryOrder IS
SELECT NVL(MAX(channel_category_order) + 1, 1)
FROM   amv_c_categories_b
WHERE  parent_channel_category_id = l_parent_category_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_Category_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check if the parent category id and name are valid
    Validate_CategoryStatus(
        x_return_status => x_return_status,
        p_category_id   => p_parent_category_id,
        p_category_name => p_parent_category_name,
        x_exist_flag    => l_category_exist_flag,
        x_category_id   => l_parent_category_id,
        x_error_msg     => l_Error_Msg,
           x_error_token   => l_Error_Token
        );
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF (l_category_exist_flag = FND_API.G_FALSE) THEN
        -- parent id or name is not valid
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                FND_MESSAGE.Set_Token('TKN',l_Error_Token);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;
    ELSE
        -- parent id or name is valid
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    -- check users privilege to create category
    AMV_USER_PVT.Can_SetupCategory(
                p_api_version           => l_api_version,
                p_init_msg_list         => FND_API.G_FALSE,
                p_validation_level      => p_validation_level,
                x_return_status => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_check_login_user      => FND_API.G_FALSE,
                p_resource_id           => l_resource_id,
                p_include_group_flag => FND_API.G_TRUE,
                x_result_flag           => l_setup_result
                );

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF l_setup_result = FND_API.G_TRUE THEN
         -- check if the (sub)category name exists
         Validate_CategoryStatus (
        x_return_status => x_return_status,
        p_category_name => p_category_name,
           p_parent_category_id => l_parent_category_id,
        x_exist_flag    => l_category_exist_flag,
        x_category_id   => l_category_id,
        x_error_msg     => l_Error_Msg,
           x_error_token   => l_Error_Token
        );
         -- Add category if it does not exist
         IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF (l_category_exist_flag = FND_API.G_TRUE) THEN
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                        FND_MESSAGE.Set_Token('TKN',l_Error_Token);
                        FND_MSG_PUB.Add;
                        END IF;
                RAISE  FND_API.G_EXC_ERROR;
                ELSE
                        -- set the category order
                        IF p_order = FND_API.G_MISS_NUM THEN
                                IF l_parent_category_id = FND_API.G_MISS_NUM THEN
                                        OPEN Max_CategoryOrder;
                                                FETCH Max_CategoryOrder INTO l_order;
                                        CLOSE Max_CategoryOrder;
                                ELSE
                                        OPEN Max_SubCategoryOrder;
                                                FETCH Max_SubCategoryOrder INTO l_order;
                                        CLOSE Max_SubCategoryOrder;
                                END IF;
                        ELSE
                                l_order := p_order;
                        END IF;
                        -- Set parent id to null if none
                        IF l_parent_category_id = FND_API.G_MISS_NUM THEN
                                l_parent_category_id := null;
                        END IF;
                        -- Select the channel category sequence
                        OPEN CategoryId_Seq;
                                FETCH CategoryId_Seq INTO l_category_id;
                        CLOSE CategoryId_Seq;
                        --
                        -- Create a new channel category
                        BEGIN
                                AMV_C_CATEGORIES_PKG.INSERT_ROW(
                                        X_ROWID => l_row_id,
                                        X_CHANNEL_CATEGORY_ID => l_category_id ,
                                        X_APPLICATION_ID => p_application_id,
                                        X_OBJECT_VERSION_NUMBER => l_object_version_number,
                                        X_CHANNEL_CATEGORY_ORDER  => l_order,
                                        X_PARENT_CHANNEL_CATEGORY_ID => l_parent_category_id,
                                        X_CHANNEL_COUNT => 0,
                                        X_CHANNEL_CATEGORY_NAME => p_category_name,
                                        X_DESCRIPTION => p_description,
                                        X_CREATION_DATE  => sysdate,
                                        X_CREATED_BY => l_user_id,
                                        X_LAST_UPDATE_DATE => sysdate,
                                        X_LAST_UPDATED_BY => l_user_id,
                                        X_LAST_UPDATE_LOGIN => l_login_user_id
                                        );
                        EXCEPTION
                        WHEN OTHERS THEN
                        --will log the error
                                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                                THEN
                                        FND_MESSAGE.Set_Name('AMV', 'AMV_TABLE_HANDLER_ERROR');
                                        FND_MESSAGE.Set_Token('ACTION', 'Adding');
                                        FND_MESSAGE.Set_Token('TABLE', 'Categories');
                                FND_MSG_PUB.Add;
                                END IF;
                        RAISE  FND_API.G_EXC_ERROR;
                        END;
                        --
                        -- Pass the channel category id created
                        x_category_id := l_category_id;
        END IF;
         ELSE
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                FND_MESSAGE.Set_Token('TKN',l_Error_Token);
                FND_MSG_PUB.Add;
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
         END IF;
        ELSE
                -- user does not have privelege to create category
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
                        FND_MESSAGE.Set_Token('LEVEL','Category');
                        FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
        END IF;
    ELSE
                -- error while checking for user privilege
                -- error in Can_SetupCategory
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
                        FND_MESSAGE.Set_Token('LEVEL','Category');
                        FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_Category_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Add_Category;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Delete channel (sub)category given the
--                 p_category_id(preferred) or p_category_name.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                     IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                IN  NUMBER    Optional
--                      Default = FND_API.G_MISS_NUM
--                    channel (sub)category id.
--                 p_category_name              IN  VARCHAR2  Optional
--                      Default = FND_API.G_MISS_CHAR
--                    channel (sub)category name.
--                 p_parent_category_id         IN  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_parent_category_name       IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    Either pass the channel (sub)category id (preferred)
--                    or channel (sub)category name
--                    to identify the channel (sub)category.
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Delete_Category
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
         p_application_id       IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_id             IN  NUMBER := FND_API.G_MISS_NUM,
      p_category_name           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_parent_category_id      IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Category';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_category_id           number;
l_subcategory_id        number;
l_category_exist_flag   varchar2(1);
l_channel_id            number;
l_category_level        number := 1;
l_category_hr           amv_cat_hierarchy_varray_type;
l_setup_result   varchar2(1);
l_delete_category_flag  varchar2(1);
--

CURSOR Get_CategoryChannels IS
select channel_id
from   amv_c_channels_b
where  channel_category_id = l_category_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Delete_Category_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Check channel id and status for a given channel id or channel name
    Validate_CategoryStatus (
        x_return_status         => x_return_status,
        p_category_id           => p_category_id,
        p_category_name         => p_category_name,
           p_parent_category_id         => p_parent_category_id,
           p_parent_category_name       => p_parent_category_name,
        x_exist_flag            => l_category_exist_flag,
        x_category_id           => l_category_id,
        x_error_msg             => l_Error_Msg,
           x_error_token        => l_Error_Token
        );
    -- check if channel exists
    IF (l_category_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', 'l_Error_Msg');
                FND_MESSAGE.Set_Token('TKN',l_Error_Token);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    ELSE
     -- check if the user has privilege to delete category
     --
     AMV_USER_PVT.Can_SetupCategory (
                p_api_version => l_api_version,
                p_init_msg_list => FND_API.G_FALSE,
                p_validation_level => p_validation_level,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_check_login_user => FND_API.G_FALSE,
                p_resource_id => l_resource_id,
                p_include_group_flag => FND_API.G_TRUE,
                x_result_flag => l_setup_result
                );

     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         IF (l_setup_result = FND_API.G_TRUE) THEN
                l_delete_category_flag := FND_API.G_TRUE;
         ELSE
                IF (AMV_UTILITY_PVT.Get_DeleteCategoryStatus(
                                                                l_category_id,
                                                                l_resource_id,
                                                                AMV_UTILITY_PVT.G_USER) )
                THEN
                        l_delete_category_flag := FND_API.G_TRUE;
                ELSE
                        -- user does not have privilege to create category
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                        FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
                        FND_MESSAGE.Set_Token('LEVEL','Category');
                                FND_MSG_PUB.Add;
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
         END IF;
     ELSE
                -- error while user privilege check in Can_SetupCategory
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
                FND_MESSAGE.Set_Token('LEVEL','Category');
                        FND_MSG_PUB.Add;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    --

    --
    IF l_delete_category_flag = FND_API.G_TRUE THEN
                l_category_hr := amv_cat_hierarchy_varray_type();

                Get_CategoryHierarchy(l_category_id,l_category_level,l_category_hr);

                FOR i IN REVERSE 1..l_category_hr.count LOOP
                        OPEN Get_CategoryChannels;
                          LOOP
                                FETCH Get_CategoryChannels INTO l_channel_id;
                                EXIT WHEN Get_CategoryChannels%NOTFOUND;

                                -- Remove channel from mychannels
                                DELETE  FROM amv_u_my_channels
                                WHERE   subscribing_to_id = l_channel_id
                                AND             subscribing_to_type = AMV_UTILITY_PVT.G_CHANNEL;

                                -- Remove access given to this channel
                                DELETE  FROM amv_u_access
                                WHERE   access_to_table_code = AMV_UTILITY_PVT.G_CHANNEL
                                AND             access_to_table_record_id = l_channel_id;

                                -- Remove channel from authors
                                DELETE  FROM amv_c_authors
                                WHERE   channel_id = l_channel_id;
                                -- Remove channel from keywords
                                DELETE  FROM amv_c_keywords
                                WHERE   channel_id = l_channel_id;
                                -- Remove channel from content types
                                DELETE  FROM amv_c_content_types
                                WHERE   channel_id = l_channel_id;
                                -- Remove channel from perspectives
                                DELETE  FROM amv_c_chl_perspectives
                                WHERE   channel_id = l_channel_id;
                                -- Remove channel from item types
                                DELETE  FROM amv_c_item_types
                                WHERE   channel_id = l_channel_id;

                                -- Remove channels
                                AMV_C_CHANNELS_PKG.DELETE_ROW( l_channel_id);
                          END LOOP;
                        CLOSE Get_CategoryChannels;
                        -- Remove channel item matches
                        DELETE  FROM amv_c_chl_item_match
                        WHERE   channel_category_id = l_category_id;

                        -- Remove category from my channels
                        DELETE  FROM amv_u_my_channels
                        --WHERE subscribing_to_id = l_category_id pls refer the bug# 2626331,2720397
                        WHERE   subscribing_to_id = l_category_hr(i).id
                        AND             subscribing_to_type = AMV_UTILITY_PVT.G_CATEGORY;

                        -- Remove channel category
                        AMV_C_CATEGORIES_PKG.DELETE_ROW(l_category_hr(i).id);
                END LOOP;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_Category_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Delete_Category;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Sort_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : sort (sub)category list in ascending or descending order
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_sort_order                       IN  VARCHAR2  Optional
--                        Default = AMV_CATEGORY_PVT.G_ASC_ORDER
--                      Ascending(ASC) or Descending(DESC) Order.
--                 p_parent_category_id               IN  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                      parent id for sub categories
--                 p_parent_category_name             IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                      category name for sub categories
--                      category name or parent category id should be
--                      supplied for sorting sub categories
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Sort_Category
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
         p_application_id       IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_sort_order              IN  VARCHAR2 := AMV_CATEGORY_PVT.G_ASC_ORDER,
      p_parent_category_id      IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Sort_Category';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_category_id           number;
l_parent_category_id    number;
l_category_exist_flag   varchar2(1);
l_order                 number;
l_record_count          number := 1;
l_channel_count         number;
l_category_array        AMV_NUMBER_VARRAY_TYPE;

CURSOR Get_CategoryOrder IS
SELECT b.channel_category_id
FROM   amv_c_categories_b b, amv_c_categories_tl tl
WHERE  b.parent_channel_category_id is null
and       b.application_id = p_application_id
ORDER BY tl.channel_category_name;

CURSOR Get_SubCategoryOrder IS
SELECT b.channel_category_id
FROM   amv_c_categories_b b, amv_c_categories_tl tl
WHERE  b.parent_channel_category_id = l_parent_category_id
ORDER BY tl.channel_category_name;

CURSOR  Get_CatRec_csr IS
SELECT  application_id
,       channel_count
FROM    amv_c_categories_b
WHERE   channel_category_id = l_category_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Sort_Category_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    Validate_CategoryStatus (
        x_return_status => x_return_status,
        p_category_id   => p_parent_category_id,
        p_category_name => p_parent_category_name,
        x_exist_flag    => l_category_exist_flag,
        x_category_id   => l_parent_category_id,
        x_error_msg     => l_Error_Msg,
             x_error_token   => l_Error_Token
        );
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF (l_category_exist_flag = FND_API.G_FALSE) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                FND_MESSAGE.Set_Token('TKN',l_Error_Token);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;
    ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    IF l_parent_category_id = FND_API.G_MISS_NUM THEN
        OPEN Get_CategoryOrder;
          l_category_array := AMV_NUMBER_VARRAY_TYPE();
          LOOP
                FETCH Get_CategoryOrder INTO l_category_id;
                EXIT WHEN Get_CategoryOrder%NOTFOUND;
                        l_category_array.extend;
                        l_category_array(l_record_count) := l_category_id;
                        l_record_count := l_record_count + 1;
          END LOOP;
        CLOSE Get_CategoryOrder;
        l_parent_category_id := null;
    ELSE
        OPEN Get_SubCategoryOrder;
          l_category_array := AMV_NUMBER_VARRAY_TYPE();
          LOOP
                FETCH Get_SubCategoryOrder INTO l_category_id;
                EXIT WHEN Get_SubCategoryOrder%NOTFOUND;
                        l_category_array.extend;
                        l_category_array(l_record_count) := l_category_id;
                        l_record_count := l_record_count + 1;
          END LOOP;
        CLOSE Get_SubCategoryOrder;
    END IF;

    -- update (sub)category order
    FOR i IN 1..l_category_array.count LOOP
        l_category_id := l_category_array(i);
        -- fetch item count for category being updated
        OPEN Get_CatRec_csr;
         FETCH Get_CatRec_csr INTO l_application_id, l_channel_count;
        CLOSE Get_CatRec_csr;
        -- set the category order
        IF p_sort_order = G_ASC_ORDER THEN
                l_order := i;
        ELSE
                l_order := l_category_array.count - i + 1;
        END IF;

        BEGIN
          AMV_C_CATEGORIES_PKG.UPDATE_B_ROW(
                X_CHANNEL_CATEGORY_ID => l_category_id,
                X_APPLICATION_ID => l_application_id,
                X_OBJECT_VERSION_NUMBER => l_object_version_number,
                X_CHANNEL_CATEGORY_ORDER => l_order,
                X_PARENT_CHANNEL_CATEGORY_ID => l_parent_category_id,
                X_CHANNEL_COUNT => l_channel_count,
                X_LAST_UPDATE_DATE => sysdate,
                X_LAST_UPDATED_BY => l_user_id,
                X_LAST_UPDATE_LOGIN => l_login_user_id
                );
        EXCEPTION
          WHEN OTHERS THEN
                --will log the error
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.Set_Name('AMV', 'AMV_TABLE_HANDLER_ERROR');
                        FND_MESSAGE.Set_Token('ACTION', 'Sorting');
                        FND_MESSAGE.Set_Token('TABLE', 'Categories');
                        FND_MSG_PUB.Add;
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
        END;
    END LOOP;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Sort_Category_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Sort_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Sort_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Sort_Category;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Reorder_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Reorder channel (sub)category list
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id_array                IN  AMV_NUMBER_VARRAY_TYPE
--                                                                  Required
--                 p_category_new_order               IN  AMV_NUMBER_VARRAY_TYPE
--                                                                  Required
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Reorder_Category
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
         p_application_id       IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_id_array       IN  AMV_NUMBER_VARRAY_TYPE,
      p_category_new_order      IN  AMV_NUMBER_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Reorder_Category';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_category_id           number;
l_parent_category_id    number;
l_channel_count         number;

CURSOR Get_CatRec_csr IS
select  application_id,
        parent_channel_category_id,
        channel_count
from    amv_c_categories_b
where   channel_category_id = l_category_id;
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Reorder_Category_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Check if the number of categories and new order count are same
    IF p_category_id_array.count = p_category_new_order.count THEN
    FOR i in 1..p_category_id_array.count LOOP
        l_category_id := p_category_id_array(i);
        -- fetch the item count for category being updated
        OPEN Get_CatRec_csr;
         FETCH Get_CatRec_csr INTO      l_application_id,
                                        l_parent_category_id,
                                        l_channel_count;
        CLOSE Get_CatRec_csr;
        -- Change the category order
        BEGIN
          AMV_C_CATEGORIES_PKG.UPDATE_B_ROW(
                X_CHANNEL_CATEGORY_ID => l_category_id,
                X_APPLICATION_ID => l_application_id,
                X_OBJECT_VERSION_NUMBER => l_object_version_number,
                X_CHANNEL_CATEGORY_ORDER => p_category_new_order(i),
                X_PARENT_CHANNEL_CATEGORY_ID => l_parent_category_id,
                X_CHANNEL_COUNT => l_channel_count,
                X_LAST_UPDATE_DATE => sysdate,
                X_LAST_UPDATED_BY => l_user_id,
                X_LAST_UPDATE_LOGIN => l_login_user_id
                );
        EXCEPTION
          WHEN OTHERS THEN
                --will log the error
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.Set_Name('AMV', 'AMV_TABLE_HANDLER_ERROR');
                        FND_MESSAGE.Set_Token('ACTION', 'Reordering');
                        FND_MESSAGE.Set_Token('TABLE', 'Categories');
                        FND_MSG_PUB.Add;
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
        END;
    END LOOP;
    ELSE
        --Category count and new order count must be equal
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CATEGORY_REORDER_ERROR');
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Reorder_Category_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Reorder_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Reorder_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Reorder_Category;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_Category
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update channel (sub)category given (sub)category id or name
--    Parameters :
--    IN           p_api_version                      IN  NUMBER    Required
--                 p_init_msg_list                    IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_object_version_number            IN  NUMBER    Required
--                      object version number
--                 p_category_id                      IN  NUMBER    Optional
--                    channel category id.
--                 p_category_name                    IN  VARCHAR2  Optional
--                    channel category name.
--                      (sub)category id or name is required
--                 p_parent_category_id               IN  NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                    channel category id.
--                 p_parent_category_name             IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    channel category name.
--                    takes either parent id or name. id taken if both passed
--                 p_category_order                   IN  NUMBER  Optional
--                    new channel category order
--                 p_category_new_name                IN  VARCHAR2  Optional
--                    new channel category name. New name has to be unique
--                 p_description                      IN  VARCHAR2  Optional
--                        Default = FND_API.G_MISS_CHAR
--                    channel category description.
--    OUT        : x_return_status                    OUT VARCHAR2
--                 x_msg_count                        OUT NUMBER
--                 x_msg_data                         OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_Category
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
      p_object_version_number   IN  NUMBER,
         p_application_id       IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_id             IN  NUMBER := FND_API.G_MISS_NUM,
      p_category_name           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_parent_category_id      IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_category_order          IN  NUMBER := FND_API.G_MISS_NUM,
      p_category_new_name       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      p_description             IN  VARCHAR2 := FND_API.G_MISS_CHAR
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_Category';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_category_id           number;
l_parent_category_id    number;
l_channel_count         number;
l_category_order                number;
l_category_exist_flag   varchar2(1);
l_category_current_name varchar2(80);
l_new_category_id       number;
l_description   varchar2(2000);
l_setup_result   varchar2(1);
l_update_category_flag   varchar2(1);

CURSOR  Get_CatRec_csr IS
select  object_version_number,
        application_id,
        channel_category_order,
        parent_channel_category_id,
        channel_count
from    amv_c_categories_b
where   channel_category_id = l_category_id;

CURSOR  Get_CatDesc_csr IS
select  description
from            amv_c_categories_tl
where   channel_category_id = l_category_id
and             language = userenv('lang');

--
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Update_Category_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check if the (sub)category id/name are valid and get (sub)category id
    Validate_CategoryStatus(
        x_return_status         => x_return_status,
        p_category_id           => p_category_id,
        p_category_name         => p_category_name,
        p_parent_category_id    => p_parent_category_id,
        p_parent_category_name  => p_parent_category_name,
        x_exist_flag            => l_category_exist_flag,
        x_category_id           => l_category_id,
        x_error_msg             => l_Error_Msg,
           x_error_token        => l_Error_Token
        );
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF (l_category_exist_flag = FND_API.G_FALSE) THEN
                -- (sub)catgeory id or name is not valid
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                        FND_MESSAGE.Set_Token('TKN', l_Error_Token);
                        FND_MSG_PUB.Add;
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
    ELSE
                -- setting the flag to success for checking again
                -- NOTE check this flag setting again
                x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    -- get the current (sub)category name
    l_category_current_name := Get_CategoryName(l_category_id);

    IF p_category_new_name <> FND_API.G_MISS_CHAR THEN
        -- check new name if current and new (sub)category are not same
        IF UPPER(p_category_new_name) <> UPPER(l_category_current_name) THEN
                -- get parent category id if parent name is passed
                IF p_parent_category_id <> FND_API.G_MISS_NUM THEN
                          l_parent_category_id := p_parent_category_id;
                ELSE
                          l_parent_category_id := Get_CategoryId(p_parent_category_name);
                END IF;
                -- check if new (sub)category name exists
                Validate_CategoryStatus (
                                x_return_status         => x_return_status,
                                p_category_name         => p_category_new_name,
                                p_parent_category_id    => l_parent_category_id,
                                x_exist_flag            => l_category_exist_flag,
                                x_category_id           => l_new_category_id,
                                x_error_msg             => l_Error_Msg,
                                x_error_token           => l_Error_Token
                                );

                l_category_current_name := p_category_new_name;
        ELSE
                l_category_exist_flag := FND_API.G_FALSE;
        END IF;
    ELSE
                l_category_exist_flag := FND_API.G_FALSE;
    END IF;
    --

    -- update category if it does not exist
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF (l_category_exist_flag = FND_API.G_TRUE) THEN
                -- (sub)category with the new name already exists
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                        FND_MESSAGE.Set_Token('TKN', l_Error_Token);
                FND_MSG_PUB.Add;
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
        ELSE
      --
      -- check if the user has privilege to update category
      AMV_USER_PVT.Can_SetupCategory (
                p_api_version => l_api_version,
                p_init_msg_list => FND_API.G_FALSE,
                p_validation_level => p_validation_level,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_check_login_user => FND_API.G_FALSE,
                p_resource_id => l_resource_id,
                p_include_group_flag => FND_API.G_TRUE,
                x_result_flag => l_setup_result
                );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          IF (l_setup_result = FND_API.G_TRUE) THEN
                l_update_category_flag := FND_API.G_TRUE;
          ELSE
                IF (AMV_UTILITY_PVT.Get_UpdateCategoryStatus(
                                                                l_category_id,
                                                                l_resource_id,
                                                                AMV_UTILITY_PVT.G_USER) )
                THEN
                        l_update_category_flag := FND_API.G_TRUE;
                ELSE
                        -- user does not have privilege to create category
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                        FND_MESSAGE.Set_Name('AMV', 'AMV_NO_ACCESS_ERROR');
                        FND_MESSAGE.Set_Token('LEVEL','Category');
                                FND_MSG_PUB.Add;
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
          END IF;
      ELSE
                -- error while user privilege check in Can_SetupCategory
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_SETUP_CHECK_ERROR');
                FND_MESSAGE.Set_Token('LEVEL','Category');
                        FND_MSG_PUB.Add;
                END IF;
                RAISE FND_API.G_EXC_ERROR;
      END IF;
      --

         --
         IF l_update_category_flag = FND_API.G_TRUE THEN
        -- get the category record in database
        OPEN Get_CatRec_csr;
                        FETCH Get_CatRec_csr INTO       l_object_version_number,
                                                                        l_application_id,
                                                                        l_category_order,
                                                                l_parent_category_id,
                                                                        l_channel_count;
        CLOSE Get_CatRec_csr;

        OPEN Get_CatDesc_csr;
                        FETCH Get_CatDesc_csr INTO      l_description;
        CLOSE Get_CatDesc_csr;

                -- check category order
                IF p_category_order <> FND_API.G_MISS_NUM THEN
                        l_category_order := p_category_order;
                END IF;

                -- check category description
                IF p_description <> FND_API.G_MISS_CHAR THEN
                        l_description := p_description;
                END IF;

        -- update if the version is greater equal to one in db
        IF p_object_version_number = l_object_version_number THEN
                        BEGIN
                                AMV_C_CATEGORIES_PKG.UPDATE_ROW(
                                        X_CHANNEL_CATEGORY_ID => l_category_id,
                                        X_APPLICATION_ID => l_application_id,
                                        X_OBJECT_VERSION_NUMBER => p_object_version_number + 1,
                                        X_CHANNEL_CATEGORY_ORDER => l_category_order,
                                        X_PARENT_CHANNEL_CATEGORY_ID => l_parent_category_id,
                                        X_CHANNEL_COUNT => l_channel_count,
                                        X_CHANNEL_CATEGORY_NAME => l_category_current_name,
                                        X_DESCRIPTION => l_description,
                                        X_LAST_UPDATE_DATE => sysdate,
                                        X_LAST_UPDATED_BY => l_user_id,
                                        X_LAST_UPDATE_LOGIN => l_login_user_id
                                        );
                        EXCEPTION
                        WHEN OTHERS THEN
                        --will log the error
                                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                                THEN
                                        FND_MESSAGE.Set_Name('AMV', 'AMV_TABLE_HANDLER_ERROR');
                                        FND_MESSAGE.Set_Token('ACTION', 'Updating');
                                        FND_MESSAGE.Set_Token('TABLE', 'Categories');
                                FND_MSG_PUB.Add;
                                END IF;
                        RAISE  FND_API.G_EXC_ERROR;
                        END;
                ELSE
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.Set_Name('AMV', 'AMV_CAT_VERSION_CHANGE');
                        FND_MSG_PUB.Add;
                        END IF;
                        RAISE  FND_API.G_EXC_ERROR;
        END IF;
       END IF;
         END IF;
         --
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                FND_MESSAGE.Set_Token('TKN', l_Error_Token);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Update_Category_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_Category_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Update_Category;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Find_Categories
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Search and return channel (sub)categories
--    Parameters
--    IN           p_api_version        IN  NUMBER    Required
--                 p_init_msg_list      IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level   IN NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_application_id            IN  NUMBER    Optional
--                      Default = AMV_UTILITY_PVT.G_AMV_APP_ID (520)
--                      application creating the channel
--                 p_category_name      IN VARCHAR2  Optional
--                    Search criteria by name. Default = '%' (everything)
--                          p_parent_category_id IN NUMBER    Optional
--                                      Default = FND_API.G_MISS_NUM
--                              parent id for sub categories
--                       p_parent_category_name IN VARCHAR2 Optional
--                                      Default = FND_API.G_MISS_CHAR
--                              parent name for sub categories
--                         takes either parent id or name. id taken if both passed
--    OUT        : x_return_status      OUT VARCHAR2
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2
--                 x_chan_category_rec_array OUT AMV_CATEGORY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Find_Categories
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
      p_application_id          IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_name           IN  VARCHAR2 := '%',
      p_parent_category_id      IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
         p_ignore_hierarchy        IN  VARCHAR2 := FND_API.G_FALSE,
         p_request_obj                    IN  AMV_REQUEST_OBJ_TYPE,
         x_return_obj                     OUT NOCOPY AMV_RETURN_OBJ_TYPE,
      x_chan_category_rec_array OUT NOCOPY AMV_CATEGORY_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Find_Categories';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_category_id           number;
l_pcategory_id          number;
l_parent_category_id    number;
l_category_exist_flag   varchar2(1);
l_category_order        number;
l_channel_count         number;
l_record_count          NUMBER := 0;
l_counter                       NUMBER := 1;
l_category_name         varchar2(80);
l_description           varchar2(2000);
l_count         number := 0;
--

CURSOR Get_AllCategories IS
select channel_category_id,
        object_version_number,
        parent_channel_category_id,
        channel_category_order,
        nvl(channel_count,0),
        channel_category_name,
        description
from    amv_c_categories_vl
where channel_category_name like p_category_name
and      channel_category_name not in ('AMV_GROUP', 'AMV_PRIVATE')
and      application_id = p_application_id
order by channel_category_name;

CURSOR Get_Categories IS
select channel_category_id,
        object_version_number,
        parent_channel_category_id,
        channel_category_order,
        nvl(channel_count,0),
        channel_category_name,
        description
from    amv_c_categories_vl
where channel_category_name like p_category_name
and      channel_category_name not in ('AMV_GROUP', 'AMV_PRIVATE')
and     application_id = p_application_id
and     parent_channel_category_id is null
order by channel_category_order;

CURSOR Get_SubCategories IS
select channel_category_id,
        object_version_number,
        parent_channel_category_id,
        channel_category_order,
        nvl(channel_count,0),
        channel_category_name,
        description
from    amv_c_categories_vl
where channel_category_name like p_category_name
and      channel_category_name not in ('AMV_GROUP', 'AMV_PRIVATE')
and     application_id = p_application_id
and     parent_channel_category_id = l_parent_category_id
order by channel_category_order;

CURSOR Count_AllCategories_csr IS
select count(channel_category_id)
from      amv_c_categories_vl
where channel_category_name like p_category_name
and    channel_category_name not in ('AMV_GROUP', 'AMV_PRIVATE')
and    application_id = p_application_id;

CURSOR Count_ParentCategories_csr IS
select count(channel_category_id)
from      amv_c_categories_vl
where channel_category_name like p_category_name
and      channel_category_name not in ('AMV_GROUP', 'AMV_PRIVATE')
and     application_id = p_application_id
and     parent_channel_category_id is null;

CURSOR Count_SubCategories_csr IS
select count(channel_category_id)
from      amv_c_categories_vl
where   channel_category_name not in ('AMV_GROUP', 'AMV_PRIVATE')
and     application_id = p_application_id
and     parent_channel_category_id = l_category_id;

CURSOR Count_Channels_csr IS
select count(channel_id)
from      amv_c_channels_b
where  channel_category_id = l_category_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Find_Categories_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- check parent category name or id and get parent category id
    Validate_CategoryStatus (
        x_return_status => x_return_status,
        p_category_id   => p_parent_category_id,
        p_category_name => p_parent_category_name,
        x_exist_flag    => l_category_exist_flag,
        x_category_id   => l_parent_category_id,
        x_error_msg     => l_Error_Msg,
             x_error_token      => l_Error_Token
        );
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF (l_category_exist_flag = FND_API.G_FALSE) THEN
        -- parent id or name is not valid
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                FND_MESSAGE.Set_Token('TKN', l_Error_Token);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;
    ELSE
        -- parent id or name is valid
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    IF p_ignore_hierarchy = FND_API.G_TRUE THEN
         -- fetch all categories
         OPEN Get_AllCategories;
          x_chan_category_rec_array := AMV_CATEGORY_VARRAY_TYPE();
          LOOP
                FETCH Get_AllCategories INTO
                                l_category_id,
                                l_object_version_number,
                                l_pcategory_id,
                                l_category_order,
                                l_channel_count,
                                l_category_name,
                                l_description;
                EXIT WHEN Get_AllCategories%NOTFOUND;
                IF l_category_name not in ('AMV_GROUP','AMV_PRIVATE') THEN
                        OPEN Count_AllCategories_csr;
                                FETCH Count_AllCategories_csr INTO l_count;
                        CLOSE Count_AllCategories_csr;
                        OPEN Count_Channels_csr;
                                FETCH Count_Channels_csr INTO l_channel_count;
                        CLOSE Count_Channels_csr;
                        IF (l_counter >= p_request_obj.start_record_position) AND
                           (l_record_count <= p_request_obj.records_requested)
                        THEN
                          l_record_count := l_record_count + 1;
                          x_chan_category_rec_array.extend;
                          x_chan_category_rec_array(l_record_count).category_id :=
                                                      l_category_id;
                          x_chan_category_rec_array(l_record_count).object_version_number                                                                       := l_object_version_number;
                          x_chan_category_rec_array(l_record_count).parent_category_id :=
                                                      l_pcategory_id;
                          x_chan_category_rec_array(l_record_count).category_order :=
                                                      l_category_order;
                          x_chan_category_rec_array(l_record_count).channel_count :=
                                                                        l_channel_count;
                          x_chan_category_rec_array(l_record_count).category_name :=
                                                                        l_category_name;
                          x_chan_category_rec_array(l_record_count).description :=
                                                                        l_description;
                          x_chan_category_rec_array(l_record_count).count := l_count;
                          /*
                          x_chan_category_rec_array(l_record_count) :=
                                amv_category_obj_type(
                                        l_category_id,
                                        l_object_version_number,
                                        l_pcategory_id,
                                        l_category_order,
                                        l_channel_count,
                                        l_category_name,
                                        l_description,
                                        l_count);
                          */
                        END IF;
                        l_counter := l_counter + 1;
                        EXIT WHEN p_request_obj.records_requested = l_record_count;
                END IF;
          END LOOP;
         CLOSE Get_AllCategories;
    ELSE
     IF l_parent_category_id = FND_API.G_MISS_NUM OR
       l_parent_category_id IS NULL
     THEN
         -- fetch all root level categories
         OPEN Get_Categories;
          x_chan_category_rec_array := AMV_CATEGORY_VARRAY_TYPE();
          LOOP
                FETCH Get_Categories INTO
                                l_category_id,
                                l_object_version_number,
                                l_pcategory_id,
                                l_category_order,
                                l_channel_count,
                                l_category_name,
                                l_description;
                EXIT WHEN Get_Categories%NOTFOUND;
                IF l_category_name not in ('AMV_GROUP','AMV_PRIVATE') THEN
                        OPEN Count_ParentCategories_csr;
                                FETCH Count_ParentCategories_csr INTO l_count;
                        CLOSE Count_ParentCategories_csr;
                        OPEN Count_Channels_csr;
                                FETCH Count_Channels_csr INTO l_channel_count;
                        CLOSE Count_Channels_csr;
                        IF (l_counter >= p_request_obj.start_record_position) AND
                           (l_record_count <= p_request_obj.records_requested)
                        THEN
                          l_record_count := l_record_count + 1;
                          x_chan_category_rec_array.extend;
                          x_chan_category_rec_array(l_record_count).category_id :=
                              l_category_id;
                          x_chan_category_rec_array(l_record_count).object_version_number                                               := l_object_version_number;
                          x_chan_category_rec_array(l_record_count).parent_category_id :=
                              l_pcategory_id;
                          x_chan_category_rec_array(l_record_count).category_order :=
                              l_category_order;
                          x_chan_category_rec_array(l_record_count).channel_count :=
                                                l_channel_count;
                          x_chan_category_rec_array(l_record_count).category_name :=
                                                l_category_name;
                          x_chan_category_rec_array(l_record_count).description :=
                                                l_description;
                          x_chan_category_rec_array(l_record_count).count := l_count;
                          /*
                          x_chan_category_rec_array(l_record_count) :=
                                amv_category_obj_type(
                                        l_category_id,
                                        l_object_version_number,
                                        l_pcategory_id,
                                        l_category_order,
                                        l_channel_count,
                                        l_category_name,
                                        l_description,
                                        l_count);
                           */
                        END IF;
                        l_counter := l_counter + 1;
                        EXIT WHEN p_request_obj.records_requested = l_record_count;
                END IF;
          END LOOP;
         CLOSE Get_Categories;
     ELSE
         -- fetch all sub-categories for a category
         OPEN Get_SubCategories;
          x_chan_category_rec_array := AMV_CATEGORY_VARRAY_TYPE();
          LOOP
                FETCH Get_SubCategories INTO
                                l_category_id,
                                l_object_version_number,
                                l_pcategory_id,
                                l_category_order,
                                l_channel_count,
                                l_category_name,
                                l_description;
                EXIT WHEN Get_SubCategories%NOTFOUND;
                IF l_category_name not in ('AMV_GROUP','AMV_PRIVATE') THEN
                        OPEN Count_SubCategories_csr;
                                FETCH Count_SubCategories_csr INTO l_count;
                        CLOSE Count_SubCategories_csr;
                        OPEN Count_Channels_csr;
                                FETCH Count_Channels_csr INTO l_channel_count;
                        CLOSE Count_Channels_csr;
                        IF (l_counter >= p_request_obj.start_record_position) AND
                           (l_record_count <= p_request_obj.records_requested)
                        THEN
                          l_record_count := l_record_count + 1;
                          x_chan_category_rec_array.extend;
                          x_chan_category_rec_array(l_record_count).category_id :=
                              l_category_id;
                          x_chan_category_rec_array(l_record_count).object_version_number                                               := l_object_version_number;
                          x_chan_category_rec_array(l_record_count).parent_category_id :=
                              l_pcategory_id;
                          x_chan_category_rec_array(l_record_count).category_order :=
                              l_category_order;
                          x_chan_category_rec_array(l_record_count).channel_count :=
                                                l_channel_count;
                          x_chan_category_rec_array(l_record_count).category_name :=
                                                l_category_name;
                          x_chan_category_rec_array(l_record_count).description :=
                                                l_description;
                          x_chan_category_rec_array(l_record_count).count := l_count;

                          /*
                          x_chan_category_rec_array(l_record_count) :=
                                amv_category_obj_type(
                                        l_category_id,
                                        l_object_version_number,
                                        l_pcategory_id,
                                        l_category_order,
                                        l_channel_count,
                                        l_category_name,
                                        l_description,
                                        l_count);
                          */
                        END IF;
                        l_counter := l_counter + 1;
                        EXIT WHEN p_request_obj.records_requested = l_record_count;
                END IF;
          END LOOP;
         CLOSE Get_SubCategories;
     END IF;
    END IF;
    x_return_obj.returned_record_count := l_record_count;
    x_return_obj.next_record_position := l_counter;
    x_return_obj.total_record_count :=     l_count;
    /*
    x_return_obj := amv_return_obj_type( l_record_count,
                                                                 l_counter,
                                                                 l_count);
    */
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Find_Categories_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Find_Categories_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Find_Categories_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Find_Categories;
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelsPerCategory
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return all channels directly under
--                 a content channel (sub)category
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                 IN  NUMBER    Required
--                 p_include_subcats             IN  VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--    OUT        : x_return_status               OUT VARCHAR2
--                 x_msg_count                   OUT NUMBER
--                 x_msg_data                    OUT VARCHAR2
--                 x_content_chan_array      OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ChannelsPerCategory
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id             IN  NUMBER,
         p_include_subcats              IN  VARCHAR2 := FND_API.G_FALSE,
      x_content_chan_array  OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Get_ChannelsPerCategory';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_record_count          NUMBER := 1;
l_category_id           number;
l_category_level        number := 1;
l_category_hr           amv_cat_hierarchy_varray_type;
l_channel_id            number;
l_channel_name          varchar2(80);

CURSOR Get_CategoryChannels IS
select b.channel_id
,         b.channel_name
from   amv_c_channels_vl b
where  b.channel_category_id = l_category_id
and       b.effective_start_date <= sysdate
and       nvl(b.expiration_date, sysdate) >= sysdate
order by b.channel_name;
--order by b.creation_date desc;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ChansPerCategory_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) THEN
        x_content_chan_array := AMV_CAT_HIERARCHY_VARRAY_TYPE();
        IF p_include_subcats = FND_API.G_FALSE THEN
           l_category_id := p_category_id;
           OPEN Get_CategoryChannels;
             LOOP
                FETCH Get_CategoryChannels INTO l_channel_id, l_channel_name;
                EXIT WHEN Get_CategoryChannels%NOTFOUND;
                        x_content_chan_array.extend;
                        x_content_chan_array(l_record_count).hierarchy_level
                                                        := l_category_id;
                        x_content_chan_array(l_record_count).id := l_channel_id;
                        x_content_chan_array(l_record_count).name := l_channel_name;
                        /*
                        x_content_chan_array(l_record_count) :=
                                        amv_cat_hierarchy_obj_type( l_category_id,
                                                                                   l_channel_id,
                                                                                   l_channel_name);
                        */
                        l_record_count := l_record_count + 1;
             END LOOP;
           CLOSE Get_CategoryChannels;
     ELSE
          l_category_hr := amv_cat_hierarchy_varray_type();
          Get_CategoryHierarchy(p_category_id, l_category_level, l_category_hr);

          FOR i IN 1..l_category_hr.count LOOP
           l_category_id := l_category_hr(i).id;
           OPEN Get_CategoryChannels;
             LOOP
                FETCH Get_CategoryChannels INTO l_channel_id, l_channel_name;
                EXIT WHEN Get_CategoryChannels%NOTFOUND;
                        x_content_chan_array.extend;
                        x_content_chan_array(l_record_count).hierarchy_level
                                                                := l_category_id;
                        x_content_chan_array(l_record_count).id := l_channel_id;
                        x_content_chan_array(l_record_count).name := l_channel_name;
                        /*
                        x_content_chan_array(l_record_count) :=
                                        amv_cat_hierarchy_obj_type( l_category_id,
                                                                                   l_channel_id,
                                                                                   l_channel_name);
                        */
                        l_record_count := l_record_count + 1;
             END LOOP;
           CLOSE Get_CategoryChannels;
          END LOOP;
        END IF;
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CATEGORY_ID_INVALID');
                FND_MESSAGE.Set_Token('TKN',p_category_id);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_ChansPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ChansPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ChansPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ChannelsPerCategory;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ItemsPerCategory
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return all items directly under
--                 a content channel (sub)category
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                 IN  NUMBER    Required
--                 p_include_subcats             IN  VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--    OUT        : x_return_status               OUT VARCHAR2
--                 x_msg_count                   OUT NUMBER
--                 x_msg_data                    OUT VARCHAR2
--                 x_items_array                 OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemsPerCategory
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id             IN  NUMBER,
         p_include_subcats              IN  VARCHAR2 := FND_API.G_FALSE,
      x_items_array      OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Get_ItemsPerCategory';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_record_count          NUMBER := 1;
l_category_id           number;
l_category_level        number := 1;
l_category_hr           amv_cat_hierarchy_varray_type;
l_item_id                       number;
l_item_name             varchar2(240);

CURSOR Get_CategoryItems_csr IS
select ib.item_id
,         ib.item_name
from   amv_c_chl_item_match cim
,         jtf_amv_items_vl ib
where  cim.channel_category_id = l_category_id
and       cim.channel_id is null
and       cim.approval_status_type = AMV_UTILITY_PVT.G_APPROVED
and       cim.table_name_code = AMV_UTILITY_PVT.G_TABLE_NAME_CODE
and       cim.available_for_channel_date <= sysdate
and       cim.item_id = ib.item_id
and       nvl(ib.effective_start_date, sysdate) <= sysdate + 1
and       nvl(ib.expiration_date, sysdate) >= sysdate
order by ib.effective_start_date;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ItemsPerCategory_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) THEN
        x_items_array := AMV_CAT_HIERARCHY_VARRAY_TYPE();
        IF p_include_subcats = FND_API.G_FALSE THEN
           l_category_id := p_category_id;
           OPEN Get_CategoryItems_csr;
             LOOP
                FETCH Get_CategoryItems_csr INTO l_item_id, l_item_name;
                EXIT WHEN Get_CategoryItems_csr%NOTFOUND;
                        x_items_array.extend;
                        x_items_array(l_record_count).hierarchy_level := l_category_id;
                        x_items_array(l_record_count).id := l_item_id;
                        x_items_array(l_record_count).name := l_item_name;
                        /*
                        x_items_array(l_record_count) :=
                                        amv_cat_hierarchy_obj_type( l_category_id,
                                                                                   l_item_id,
                                                                                   l_item_name);
                     */
                        l_record_count := l_record_count + 1;
             END LOOP;
           CLOSE Get_CategoryItems_csr;
     ELSE
          l_category_hr := amv_cat_hierarchy_varray_type();
          Get_CategoryHierarchy(p_category_id, l_category_level, l_category_hr);

          FOR i IN 1..l_category_hr.count LOOP
           l_category_id := l_category_hr(i).id;
           OPEN Get_CategoryItems_csr;
             LOOP
                FETCH Get_CategoryItems_csr INTO l_item_id, l_item_name;
                EXIT WHEN Get_CategoryItems_csr%NOTFOUND;
                        x_items_array.extend;
                        x_items_array(l_record_count).hierarchy_level := l_category_id;
                        x_items_array(l_record_count).id := l_item_id;
                        x_items_array(l_record_count).name := l_item_name;
                        /*
                        x_items_array(l_record_count) :=
                                        amv_cat_hierarchy_obj_type( l_category_id,
                                                                                   l_item_id,
                                                                                   l_item_name);
                        */
                        l_record_count := l_record_count + 1;
             END LOOP;
           CLOSE Get_CategoryItems_csr;
          END LOOP;
        END IF;
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CATEGORY_ID_INVALID');
                FND_MESSAGE.Set_Token('TKN',p_category_id);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_ItemsPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ItemsPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ItemsPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ItemsPerCategory;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ItemsPerCategory
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return all items directly under
--                 a content channel (sub)category
--    Parameters :
--    IN           p_api_version                 IN  NUMBER    Required
--                 p_init_msg_list               IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level            IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                 IN  NUMBER    Required
--                 p_include_subcats             IN  VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--    OUT        : x_return_status               OUT VARCHAR2
--                 x_msg_count                   OUT NUMBER
--                 x_msg_data                    OUT VARCHAR2
--                 x_items_array                 OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ItemsPerCategory
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id             IN  NUMBER,
         p_include_subcats              IN  VARCHAR2 := FND_API.G_FALSE,
         p_request_obj                  IN  AMV_REQUEST_OBJ_TYPE,
      p_category_sort           IN  AMV_SORT_OBJ_TYPE,
         x_return_obj            OUT NOCOPY AMV_RETURN_OBJ_TYPE,
      x_items_array      OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Get_ItemsPerCategory';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_record_count          NUMBER := 0;
l_total_count           NUMBER := 0;
l_temp_total            NUMBER := 0;
l_counter               NUMBER := 1;
l_category_id           number;
l_category_level        number := 1;
l_category_hr           amv_cat_hierarchy_varray_type;
l_item_id                       number;
l_item_name             varchar2(240);
l_sort_dir              varchar2(10);
l_sort_col              varchar2(80);

CURSOR Get_CategoryItems_csr IS
select ib.item_id
,         ib.item_name
from   amv_c_chl_item_match cim
,         jtf_amv_items_vl ib
where  cim.channel_category_id = l_category_id
and       cim.channel_id is null
and       cim.approval_status_type = AMV_UTILITY_PVT.G_APPROVED
and    cim.table_name_code = AMV_UTILITY_PVT.G_TABLE_NAME_CODE
and       cim.available_for_channel_date <= sysdate
and       cim.item_id = ib.item_id
and    nvl(ib.effective_start_date, sysdate) <= sysdate + 1
and       nvl(ib.expiration_date, sysdate) >= sysdate
order by l_sort_col ||'  '||l_sort_dir;

CURSOR Get_ItemsTotal_csr IS
select count(cim.item_id)
from   amv_c_chl_item_match cim
,         jtf_amv_items_vl ib
where  cim.channel_category_id = l_category_id
and       cim.channel_id is null
and       cim.approval_status_type = AMV_UTILITY_PVT.G_APPROVED
and    cim.table_name_code = AMV_UTILITY_PVT.G_TABLE_NAME_CODE
and       cim.available_for_channel_date <= sysdate
and       cim.item_id = ib.item_id
and    nvl(ib.effective_start_date, sysdate) <= sysdate + 1
and       nvl(ib.expiration_date, sysdate) >= sysdate;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ItemsPerCategory_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) THEN
        x_items_array := AMV_CAT_HIERARCHY_VARRAY_TYPE();
        IF p_include_subcats = FND_API.G_FALSE THEN
           l_category_id := p_category_id;
           IF ( p_category_sort.sort_col = null ) THEN
              l_sort_col := 'ib.'||p_category_sort.sort_col;
           ELSE
              l_sort_col := 'ib.effective_start_date';
           END IF;

           l_sort_dir := nvl(p_category_sort.sort_dir, 'DESC');

           -- get the total number of items in category
           OPEN Get_ItemsTotal_csr;
                FETCH Get_ItemsTotal_csr INTO l_total_count;
           CLOSE Get_ItemsTotal_csr;

           OPEN Get_CategoryItems_csr;
             LOOP
                  FETCH Get_CategoryItems_csr INTO l_item_id, l_item_name;
                  EXIT WHEN Get_CategoryItems_csr%NOTFOUND;
                  IF (l_counter >= p_request_obj.start_record_position) AND
                        (l_record_count <= p_request_obj.records_requested)
                  THEN
                        l_record_count := l_record_count + 1;
                        x_items_array.extend;
                        x_items_array(l_record_count).hierarchy_level := l_category_id;
                        x_items_array(l_record_count).id := l_item_id;
                        x_items_array(l_record_count).name := l_item_name;
                        /*
                        x_items_array(l_record_count) :=
                                        amv_cat_hierarchy_obj_type( l_category_id,
                                                                                   l_item_id,
                                                                                   l_item_name);
                        */
                  END IF;
                  EXIT WHEN l_record_count = p_request_obj.records_requested;
                  l_counter := l_counter + 1;
             END LOOP;
           CLOSE Get_CategoryItems_csr;
     ELSE
          l_category_hr := amv_cat_hierarchy_varray_type();
          Get_CategoryHierarchy(p_category_id, l_category_level, l_category_hr);

          FOR i IN 1..l_category_hr.count LOOP
           l_category_id := l_category_hr(i).id;

           -- get the total number of items in category
           OPEN Get_ItemsTotal_csr;
                FETCH Get_ItemsTotal_csr INTO l_temp_total;
           CLOSE Get_ItemsTotal_csr;
           l_total_count := l_total_count + l_temp_total;

           OPEN Get_CategoryItems_csr;
             LOOP
                  FETCH Get_CategoryItems_csr INTO l_item_id, l_item_name;
                  EXIT WHEN Get_CategoryItems_csr%NOTFOUND;
                  IF (l_counter >= p_request_obj.start_record_position) AND
                        (l_record_count <= p_request_obj.records_requested)
                  THEN
                        l_record_count := l_record_count + 1;
                        x_items_array.extend;
                        x_items_array(l_record_count).hierarchy_level := l_category_id;
                        x_items_array(l_record_count).id := l_item_id;
                        x_items_array(l_record_count).name := l_item_name;
                        /*
                        x_items_array(l_record_count) :=
                                        amv_cat_hierarchy_obj_type( l_category_id,
                                                                                   l_item_id,
                                                                                   l_item_name);
                        */
                  END IF;
                  EXIT WHEN l_record_count = p_request_obj.records_requested;
                  IF p_request_obj.start_record_position > l_temp_total THEN
                        exit;
                  END IF;
                  l_counter := l_counter + 1;
             END LOOP;
           CLOSE Get_CategoryItems_csr;

          END LOOP;
        END IF;
        x_return_obj.returned_record_count := l_record_count;
        x_return_obj.next_record_position := l_counter + 1;
        x_return_obj.total_record_count := l_total_count;
        /*
        x_return_obj := amv_return_obj_type(    l_record_count,
                                                                        l_counter + 1,
                                                                        l_total_count);
        */
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CATEGORY_ID_INVALID');
                FND_MESSAGE.Set_Token('TKN',p_category_id);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_ItemsPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ItemsPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ItemsPerCategory_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ItemsPerCategory;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Fetch_CategoryId
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns category id for a category or subcategory name.
--
-- Start of comments
--    API name   : Fetch_CategoryId
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns category id for a category or subcategory name.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_name              IN  VARCHAR2  Required
--                      (sub)category id
--                 p_parent_category_id         IN  NUMBER    Optional
--                      Default = FND_API.G_MISS_NUM
--                      parent category id
--                 p_parent_category_name       IN  VARCHAR2  Optional
--                      Default = FND_API.G_MISS_CHAR
--                      parent category name
--                      parent id or name required for subcategory name
--    OUT        : x_return_status              OUT VARCHAR2
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2
--                 x_category_id                OUT NUMBER
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Fetch_CategoryId
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
         p_application_id       IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
      p_category_name           IN  VARCHAR2,
      p_parent_category_id      IN  NUMBER := FND_API.G_MISS_NUM,
      p_parent_category_name    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      x_category_id             OUT NOCOPY NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Fetch_CategoryId';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_category_id           number;
l_category_exist_flag   varchar2(1);
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Fetch_CategoryId_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    Validate_CategoryStatus(
        x_return_status         => x_return_status,
        p_category_name         => p_category_name,
        p_parent_category_id    => p_parent_category_id,
        p_parent_category_name  => p_parent_category_name,
        x_exist_flag            => l_category_exist_flag,
        x_category_id           => x_category_id,
           x_error_msg          => l_Error_Msg,
           x_error_token                => l_Error_Token
        );
    --
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', l_Error_Msg);
                FND_MESSAGE.Set_Token('TKN',l_Error_Token);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': END');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Fetch_CategoryId_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Fetch_CategoryId_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Fetch_CategoryId_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Fetch_CategoryId;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_CatParentsHierarchy
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return parents hierarchy of category name and ids
--                      for a category id.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                IN  NUMBER  Required
--                      (sub)category id
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--                 x_category_hierarchy     OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Get_CatParentsHierarchy
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id             IN  NUMBER,
      x_category_hierarchy      OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Get_CatParentsHierarchy';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_category_level        number := 1;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_CatParentsHrPVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) THEN

        x_category_hierarchy := amv_cat_hierarchy_varray_type();

           Get_CategoryParents(p_category_id,
                            l_category_level,
                            x_category_hierarchy);

    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CATEGORY_ID_INVALID');
                FND_MESSAGE.Set_Token('TKN',p_category_id);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': END');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_CatParentsHrPVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_CatParentsHrPVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_CatParentsHrPVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_CatParentsHierarchy;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_CatChildrenHierarchy
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return children hierarchy of category name and ids
--                      for a category id.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                IN  NUMBER  Required
--                      (sub)category id
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--                 x_category_hierarchy     OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Get_CatChildrenHierarchy
(     p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
      p_category_id             IN  NUMBER,
      x_category_hierarchy      OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Get_CatChildrenHierarchy';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_category_level        number := 1;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_CatChildrenHrPVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) THEN

        x_category_hierarchy := amv_cat_hierarchy_varray_type();

           Get_CategoryHierarchy(p_category_id,
                                                l_category_level,
                                                x_category_hierarchy);

    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CATEGORY_ID_INVALID');
                FND_MESSAGE.Set_Token('TKN',p_category_id);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': END');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_CatChildrenHrPVT;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_CatChildrenHrPVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_CatChildrenHrPVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_CatChildrenHierarchy;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_ChnCategoryHierarchy
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Return parents hierarchy of category name and ids
--             for a channel id.
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_channel_id                IN  NUMBER  Required
--                      channel id
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--                 x_channel_name           OUT VARCHAR2
--                 x_category_hierarchy     OUT AMV_CAT_HIERARCHY_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Get_ChnCategoryHierarchy
( p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
  p_channel_id          IN  NUMBER,
  x_channel_name      OUT NOCOPY VARCHAR2,
  x_category_hierarchy   OUT NOCOPY AMV_CAT_HIERARCHY_VARRAY_TYPE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Get_ChnCategoryHierarchy';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number;
l_application_id        number;
--
l_category_level        number := 1;
l_category_id        number;
--
CURSOR Get_ChannelData IS
select tl.channel_name
,         b.channel_category_id
from      amv_c_channels_b b
,         amv_c_channels_tl tl
where  b.channel_id = p_channel_id
and       b.channel_id = tl.channel_id
and       tl.language = userenv('lang');
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_ChnCategoryHierarchy;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF AMV_UTILITY_PVT.Is_ChannelIdValid(p_channel_id) THEN
           OPEN Get_ChannelData;
                FETCH Get_ChannelData INTO x_channel_name, l_category_id;
           CLOSE Get_ChannelData;

        x_category_hierarchy := amv_cat_hierarchy_varray_type();

           Get_CategoryParents(l_category_id,
                            l_category_level,
                            x_category_hierarchy);
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CHANNEL_ID_INVALID');
                FND_MESSAGE.Set_Token('TKN',p_channel_id);
                FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': END');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_ChnCategoryHierarchy;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_ChnCategoryHierarchy;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_ChnCategoryHierarchy;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_ChnCategoryHierarchy;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Add_CategoryParent
--    Type       : Private
--    Pre-reqs   : None
--    Function   : attaches a category to a parent category
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                IN  NUMBER  Required
--                      category id
--                 p_parent_category_id         IN  NUMBER Required
--                      parent category id
--                 p_replace_existing           IN VARCHAR2 Optional
--                       Default = FND_API.G_FALSE
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Add_CategoryParent
( p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
  p_object_version_number IN  NUMBER,
  p_category_id         IN  NUMBER,
  p_parent_category_id   IN  NUMBER,
  p_replace_existing    IN  VARCHAR2 := FND_API.G_FALSE
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Add_CategoryParent';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
--
l_category_level        number := 1;
l_category_hr           amv_cat_hierarchy_varray_type;
l_parent_category_id        number;
l_object_version_number number;
l_application_id        number;
l_order                 number;
l_channel_count number;
l_update_flag           varchar2(1) := FND_API.G_FALSE;
l_subcat_name           varchar2(80);
l_cat_name              varchar2(80);
--
CURSOR Get_ParentId IS
select parent_channel_category_id
,         channel_category_name
,         object_version_number
,         application_id
,         channel_category_order
,         channel_count
from      amv_c_categories_vl
where  channel_category_id = p_category_id;

CURSOR Get_SubCatName IS
select channel_category_name
from      amv_c_categories_vl
where  parent_channel_category_id = p_parent_category_id;

--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_CategoryParent;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) THEN
        IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_parent_category_id) THEN
          OPEN Get_ParentId;
                FETCH Get_ParentId INTO         l_parent_category_id,
                                                        l_cat_name,
                                                        l_object_version_number,
                                                        l_application_id,
                                                        l_order,
                                                        l_channel_count;
          CLOSE Get_ParentId;
          IF l_parent_category_id is null THEN
                l_update_flag := FND_API.G_TRUE;
          ELSE
                IF p_replace_existing = FND_API.G_TRUE THEN
                        l_update_flag := FND_API.G_TRUE;
                ELSE
                        l_update_flag := FND_API.G_FALSE;
                END IF;
          END IF;
        ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CATEGORY_ID_INVALID');
        FND_MESSAGE.Set_Token('TKN',p_parent_category_id);
        FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CATEGORY_ID_INVALID');
        FND_MESSAGE.Set_Token('TKN',p_category_id);
        FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;


    -- update parent
    IF l_update_flag = FND_API.G_TRUE THEN
        IF p_object_version_number = l_object_version_number THEN
                -- check to see if parent is not its child
                l_category_hr := amv_cat_hierarchy_varray_type();
                Get_CategoryHierarchy(p_category_id, l_category_level, l_category_hr);
                FOR i in 1..l_category_hr.count LOOP
                        IF l_category_hr(i).id = p_parent_category_id THEN
                                l_update_flag := FND_API.G_FALSE;
                        END IF;
                        EXIT WHEN l_category_hr(i).id = p_parent_category_id;
                END LOOP;
                IF l_update_flag = FND_API.G_FALSE THEN
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.Set_Name('AMV', 'AMV_CAT_PARENT_LOOPING');
                        FND_MESSAGE.Set_Token('TKN',p_parent_category_id);
                        FND_MSG_PUB.Add;
                END IF;
                        RAISE  FND_API.G_EXC_ERROR;
                END IF;

                -- check to see if no other category exist with same name under parent
                OPEN Get_SubCatName;
                  LOOP
                        FETCH Get_SubCatName INTO l_subcat_name;
                        EXIT WHEN Get_SubCatName%NOTFOUND;
                        IF UPPER(l_subcat_name) = UPPER(l_cat_name) THEN
                                l_update_flag := FND_API.G_FALSE;
                        END IF;
                        EXIT WHEN UPPER(l_subcat_name) = UPPER(l_cat_name);
                  END LOOP;
                CLOSE Get_SubCatName;
                IF l_update_flag = FND_API.G_FALSE THEN
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.Set_Name('AMV', 'AMV_CAT_NAME_EXISTS');
                        FND_MESSAGE.Set_Token('TKN',p_category_id);
                        FND_MSG_PUB.Add;
                END IF;
                        RAISE  FND_API.G_EXC_ERROR;
                END IF;

                BEGIN
                        AMV_C_CATEGORIES_PKG.UPDATE_B_ROW(
                                X_CHANNEL_CATEGORY_ID => p_category_id,
                                X_APPLICATION_ID => l_application_id,
                                X_OBJECT_VERSION_NUMBER => p_object_version_number + 1,
                                X_CHANNEL_CATEGORY_ORDER => l_order,
                                X_PARENT_CHANNEL_CATEGORY_ID => p_parent_category_id,
                                X_CHANNEL_COUNT => l_channel_count,
                                X_LAST_UPDATE_DATE => sysdate,
                                X_LAST_UPDATED_BY => l_user_id,
                                X_LAST_UPDATE_LOGIN => l_login_user_id
                                );
                EXCEPTION
                        WHEN OTHERS THEN
                        --will log the error
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.Set_Name('AMV', 'AMV_TABLE_HANDLER_ERROR');
                                FND_MESSAGE.Set_Token('ACTION', 'Updating');
                                FND_MESSAGE.Set_Token('TABLE', 'Categories');
                        FND_MSG_PUB.Add;
                END IF;
                        RAISE  FND_API.G_EXC_ERROR;
                END;
        ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CAT_VERSION_CHANGE');
        FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CAT_PARENT_EXISTS');
        FND_MESSAGE.Set_Token('TKN',l_parent_category_id);
        FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': END');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_CategoryParent;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_CategoryParent;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_CategoryParent;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Add_CategoryParent;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Remove_CategoryParent
--    Type       : Private
--    Pre-reqs   : None
--    Function   : removes a category to from a parent category
--    Parameters :
--    IN           p_api_version                IN  NUMBER    Required
--                 p_init_msg_list              IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_category_id                IN  NUMBER  Required
--                      category id
--    OUT        : x_return_status          OUT VARCHAR2
--                 x_msg_count              OUT NUMBER
--                 x_msg_data               OUT VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
--
PROCEDURE Remove_CategoryParent
( p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
  p_object_version_number IN  NUMBER,
  p_category_id         IN  NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Remove_CategoryParent';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id           number;
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
--
l_parent_category_id        number;
l_object_version_number number;
l_application_id        number;
l_order                 number;
l_channel_count number;
--
CURSOR Get_ParentId IS
select b.parent_channel_category_id
,         b.object_version_number
,         b.application_id
,         b.channel_category_order
,         b.channel_count
from      amv_c_categories_b b
where  b.channel_category_id = p_category_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Remove_CategoryParent;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
                        x_resource_id => l_resource_id,
                x_user_id     => l_user_id,
                x_login_id    => l_login_user_id,
                x_user_status => l_login_user_status
                );
    -- check login user
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This fix is for executing api in sqlplus mode
    IF (l_login_user_id = FND_API.G_MISS_NUM) THEN
           l_login_user_id := g_login_user_id;
           l_user_id  := g_user_id;
           l_resource_id := g_resource_id;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF AMV_UTILITY_PVT.Is_CategoryIdValid(p_category_id) THEN
        OPEN Get_ParentId;
                FETCH Get_ParentId INTO         l_parent_category_id,
                                                        l_object_version_number,
                                                        l_application_id,
                                                        l_order,
                                                        l_channel_count;
        CLOSE Get_ParentId;
        --
     IF p_object_version_number = l_object_version_number THEN
                l_parent_category_id := null;
                BEGIN
                        AMV_C_CATEGORIES_PKG.UPDATE_B_ROW(
                                X_CHANNEL_CATEGORY_ID => p_category_id,
                                X_APPLICATION_ID => l_application_id,
                                X_OBJECT_VERSION_NUMBER => p_object_version_number + 1,
                                X_CHANNEL_CATEGORY_ORDER => l_order,
                                X_PARENT_CHANNEL_CATEGORY_ID => l_parent_category_id,
                                X_CHANNEL_COUNT => l_channel_count,
                                X_LAST_UPDATE_DATE => sysdate,
                                X_LAST_UPDATED_BY => l_user_id,
                                X_LAST_UPDATE_LOGIN => l_login_user_id
                                );
                EXCEPTION
                        WHEN OTHERS THEN
                        --will log the error
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                FND_MESSAGE.Set_Name('AMV', 'AMV_TABLE_HANDLER_ERROR');
                                FND_MESSAGE.Set_Token('ACTION', 'Updating');
                                FND_MESSAGE.Set_Token('TABLE', 'Categories');
                        FND_MSG_PUB.Add;
                END IF;
                        RAISE  FND_API.G_EXC_ERROR;
                END;
     ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CAT_VERSION_CHANGE');
        FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
     END IF;
    ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                FND_MESSAGE.Set_Name('AMV', 'AMV_CATEGORY_ID_INVALID');
        FND_MESSAGE.Set_Token('TKN',p_category_id);
        FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': END');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Remove_CategoryParent;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Remove_CategoryParent;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Remove_CategoryParent;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Remove_CategoryParent;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_category_pvt;

/
