--------------------------------------------------------
--  DDL for Package Body CS_KB_SOLN_CATEGORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SOLN_CATEGORIES_PVT" AS
/* $Header: csvcatb.pls 120.1 2005/09/13 14:11:10 alawang noship $ */

  soln_category_link_obj_code varchar2(30) := 'CS_KB_SOLN_CATEGORY_LINK';

  procedure getStdParams
  (
    x_current_date      OUT NOCOPY date,
    x_current_user_id   OUT NOCOPY number,
    x_current_login_id  OUT NOCOPY number
  )
  is
  begin
    x_current_date := sysdate;
    x_current_user_id := fnd_global.user_id;
    x_current_login_id := fnd_global.login_id;
  end getStdParams;

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
  )
  is
  begin
    createCategory( null                ,
                    p_api_version       ,
                    p_init_msg_list     ,
                    p_commit            ,
                    p_validation_level  ,
                    x_return_status     ,
                    x_msg_count         ,
                    x_msg_data          ,
                    p_parent_category_id,
                    p_name              ,
                    p_description       ,
                    x_category_id,
                    3 );  -- default to external visibility, if called from JTT

  end;

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
  )
  is
    l_current_date        date;
    l_current_user_id     number;
    l_current_login_id    number;
    l_rowid               varchar2(50);
    l_category_id         number;
    l_property_id         number;
  begin
    getStdParams(l_current_date, l_current_user_id, l_current_login_id);
    l_category_id := p_category_id;

    /* Validations */

    /* Insert the category */
    cs_kb_soln_categories_pkg.insert_row
    (
      X_ROWID               =>    l_rowid,
      X_CATEGORY_ID         =>    l_category_id,
      X_PARENT_CATEGORY_ID  =>    p_parent_category_id,
      X_NAME                =>    p_name,
      X_DESCRIPTION         =>    p_description,
      X_CREATION_DATE       =>    l_current_date,
      X_CREATED_BY          =>    l_current_user_id,
      X_LAST_UPDATE_DATE    =>    l_current_date,
      X_LAST_UPDATED_BY     =>    l_current_user_id,
      X_LAST_UPDATE_LOGIN   =>    l_current_login_id,
      X_VISIBILITY_ID       =>    p_visibility_id
    );
    x_category_id := l_category_id;

    cs_kb_security_pvt.ADD_CATEGORY_TO_DENORM (
      P_CATEGORY_ID         => x_category_id,
      P_PARENT_CATEGORY_ID  => p_parent_category_id,
      P_VISIBILITY_ID       => p_visibility_id,
      X_RETURN_STATUS       => x_return_status,
      X_MSG_DATA            => x_msg_data,
      X_MSG_COUNT           => x_msg_count
    );

    if fnd_api.to_boolean( p_commit ) then
	    commit;
    end if;
  end createCategory;

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
  )
  is
    n_child_solutions number;
    n_subcatgories    number;
    l_delete_status   number;

/*    cursor removeLinksCsr
      ( category_id number, link_obj_code varchar2 )
    is
    select link_id
    from cs_kb_set_links
    where object_code = link_obj_code
      and other_id = category_id;
*/
begin

  select /*+ index(sl) */ count( * ) into n_child_solutions
  from cs_kb_set_categories sl, cs_kb_sets_b b
  where sl.category_id = p_category_id
    and b.set_id = sl.set_id
    --and b.status = 'PUB';
    and (b.status = 'PUB' or (b.status <> 'OBS' and b.latest_version_flag = 'Y'));

  select count( * ) into n_subcatgories
  from cs_kb_soln_categories_b
  where parent_category_id = p_category_id;

  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  -- check if the category is deletable
  -- i.e. it does not contain sub-categories nor PUBlished child solutions
  if( n_child_solutions <> 0 OR n_subcatgories <> 0 ) then
     FND_MSG_PUB.initialize;
     FND_MESSAGE.set_name('CS', 'CS_KB_C_CAT_DELETE_FAILED');
     FND_MSG_PUB.ADD;
     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                               p_count   => X_MSG_COUNT,
                               p_data    => X_MSG_DATA);

  ELSE
    -- Delete all set category links (which should not be PUBlished versions)
    delete /*+ index(sl) */  from cs_kb_set_categories sl
    where sl.category_id = p_category_id;
/*    for linkIdRec in removeLinksCsr
      ( p_category_id, soln_category_link_obj_code )
    loop
      l_delete_status :=
        cs_kb_set_links_pkg.delete_set_link
        (
          p_link_id => linkIdRec.link_id
        );
    end loop;
*/
    -- Delete this leaf category
    cs_kb_soln_categories_pkg.delete_row( p_category_id );

    cs_kb_security_pvt.REMOVE_CATEGORY_FROM_CAT_GROUP(
      P_CATEGORY_ID         => p_category_id,
      X_RETURN_STATUS       => x_return_status,
      X_MSG_DATA            => x_msg_data,
      X_MSG_COUNT           => x_msg_count
    );
    if fnd_api.to_boolean( p_commit ) then
      commit;
    end if;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  end if;

end removeCategory;

-- Start of comments
--	API name 	: removeCategoryCascade
--	Type		: Private
--	Function	: This removes a category and its descendents recursively, once
--                all of them contain no solutions.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_ID         NUMBER  Required
--
--	OUT		: X_RETURN_STATUS       VARCHAR2
--            X_MSG_DATA            VARCHAR2
--            X_MSG_COUNT           NUMBER
--
--	History:
--	10-Aug-04 alawang created.
--
--
--
--	Notes		:
--  1) This method will query all decedents of a given category and delete them
--     one by one by calling removeCategory from bottom up. It relies on
--     removeCategory to check the emptiness.
--
-- End of comments
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
)
is
  l_category_id number;
  l_category_fullpath_name varchar2(1000);
  cursor Get_Descendent_Categories
    ( cp_category_id number)
  is
    SELECT SolnCategoryEO.CATEGORY_ID
    FROM cs_kb_soln_categories_b SolnCategoryEO
    start with SolnCategoryEO.CATEGORY_ID = cp_category_id
    connect by prior CATEGORY_ID = PARENT_CATEGORY_ID
    order by level desc;
  cursor Get_Category_Fullpath_Name
    ( cp_category_id number)
  is
    SELECT cs_kb_soln_categories_pvt.admin_cat_fullpath_names( cp_category_id, ' > ' )
    FROM dual;
begin
  savepoint removeCategoryCascade_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  -- Loop through descendent categories and delete them one by one.
  -- The query return descendent categories from bottome up.
  OPEN  Get_Descendent_Categories(p_category_id);
  LOOP
    FETCH Get_Descendent_Categories INTO l_category_id;
    EXIT WHEN Get_Descendent_Categories%NOTFOUND;
    removeCategory(p_api_version =>   1.0,
                   p_category_id =>   l_category_id,
                   x_return_status => x_return_status,
                   x_msg_data  =>     x_msg_data,
                   x_msg_count =>     x_msg_count);
    -- If any of these descendent categories failed to be deleted. Rollback
    -- and return.
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      ROLLBACK TO	removeCategoryCascade_PVT;
      --Prepare error message
      OPEN  Get_Category_Fullpath_Name(p_category_id);
      FETCH Get_Category_Fullpath_Name INTO l_category_fullpath_name;
      CLOSE Get_Category_Fullpath_Name;

      FND_MSG_PUB.initialize;
      FND_MESSAGE.set_name('CS', 'CS_KB_C_CAT_DELETE_CAS_FAILED');
      FND_MESSAGE.SET_TOKEN(TOKEN => 'CATEGORY_FULLPATH_NAME',
                            VALUE => l_category_fullpath_name,
                            TRANSLATE => true);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                p_count   => X_MSG_COUNT,
                                p_data    => X_MSG_DATA);
      EXIT;
    END IF;
  END LOOP;
  CLOSE Get_Descendent_Categories;

  -- If everything is okay and specified to commit, then commit the transaction.
  IF X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS AND
     fnd_api.to_boolean( p_commit ) THEN
     COMMIT;
  END IF;
end removeCategoryCascade;

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
  )
  is
  begin
    updateCategory( p_api_version       ,
                    p_init_msg_list     ,
                    p_commit            ,
                    p_validation_level  ,
                    x_return_status     ,
                    x_msg_count         ,
                    x_msg_data          ,
                    p_category_id       ,
                    p_parent_category_id,
                    p_name              ,
                    p_description       ,
                    3 );  -- default to external visibility, if called from JTT
  end;

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
  )
  is
    l_current_date        date;
    l_current_user_id     number;
    l_current_login_id    number;

    l_original_visibility_id NUMBER;
    l_original_parent_category_id NUMBER;
    l_request_id     NUMBER;
    l_return_status  VARCHAR2(1);
    l_found_cat_group_diff VARCHAR2(1);
    l_cat_group_id number;
    l_category_id number;

    CURSOR GET_ORIGINAL_CAT_VISIBILITY IS
     SELECT Visibility_Id
     FROM CS_KB_SOLN_CATEGORIES_B
     WHERE Category_Id = p_category_id;

    CURSOR GET_ORIGINAL_PARENT_CAT IS
     SELECT parent_category_Id
     FROM CS_KB_SOLN_CATEGORIES_B
     WHERE Category_Id = p_category_id;

    CURSOR Get_Moved_Categories IS
    SELECT c.category_id
    FROM CS_KB_SOLN_CATEGORIES_B c
    START WITH  c.category_id = P_CATEGORY_ID
    CONNECT BY PRIOR c.category_id = c.parent_category_id
    ORDER BY level asc;

    CURSOR GET_DUP_CG_MEMBERSHIP(cp_category_id number) IS
        SELECT Distinct Category_Group_Id
        FROM CS_KB_CAT_GROUP_DENORM
        WHERE CHILD_CATEGORY_ID = P_PARENT_CATEGORY_ID
        intersect
        select distinct m.category_group_id
        FROM CS_KB_CAT_GROUP_MEMBERS m
        WHERE Category_Id = cp_category_id;


  begin
    savepoint updateCategory_PVT;

    OPEN  GET_ORIGINAL_CAT_VISIBILITY;
    FETCH GET_ORIGINAL_CAT_VISIBILITY INTO l_original_visibility_id;
    CLOSE GET_ORIGINAL_CAT_VISIBILITY;

    OPEN GET_ORIGINAL_PARENT_CAT;
    FETCH GET_ORIGINAL_PARENT_CAT INTO l_original_parent_category_id;
    CLOSE GET_ORIGINAL_PARENT_CAT;

    getStdParams(l_current_date, l_current_user_id, l_current_login_id);

    /* Validations */

    /* Update the category */
    cs_kb_soln_categories_pkg.update_row
    (
      X_CATEGORY_ID         => p_category_id,
      X_PARENT_CATEGORY_ID  => p_parent_category_id,
      X_NAME                => p_name,
      X_DESCRIPTION         => p_description,
      X_LAST_UPDATE_DATE    => l_current_date,
      X_LAST_UPDATED_BY     => l_current_user_id,
      X_LAST_UPDATE_LOGIN   => l_current_login_id,
      X_VISIBILITY_ID       => p_visibility_id
    );

    cs_kb_security_pvt.UPDATE_CATEGORY_TO_DENORM (
      P_CATEGORY_ID         => p_category_id,
      P_VISIBILITY_ID       => p_visibility_id,
      X_RETURN_STATUS       => x_return_status,
      X_MSG_DATA            => x_msg_data,
      X_MSG_COUNT           => x_msg_count
    );

    IF l_original_visibility_id  <> p_visibility_id THEN

      CS_KB_SYNC_INDEX_PKG.request_mark_idx_on_sec_change
                                ( 'CHANGE_CAT_VIS',
                                  p_category_id,
                                  l_original_visibility_id,
                                  l_request_id,
                                  l_return_status );

           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
           ELSE
             RAISE INDEX_SYNC_FAILED;
           END IF;

    END IF;

    IF l_original_parent_category_id <> p_parent_category_id THEN
          for x in  Get_Moved_Categories loop
            for y in GET_DUP_CG_MEMBERSHIP(x.category_id) loop
                CS_KB_SECURITY_PVT.delete_category_group_member(
                  p_category_group_id  => y.category_group_id,
                  p_category_id        => x.category_id,
                  X_RETURN_STATUS      => x_return_status,
                  X_MSG_DATA           => x_msg_data,
                  X_MSG_COUNT          => x_msg_count
                  );
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE CG_MEMBER_DEL_FAILED;
                END IF;
            end loop;
          end loop;


          -- Update denorm table.
          cs_kb_security_pvt.MOVE_CATEGORY_IN_DENORM (
            P_CATEGORY_ID        => p_category_id,
            X_RETURN_STATUS      => x_return_status,
            X_MSG_DATA           => x_msg_data,
            X_MSG_COUNT          => x_msg_count
          );
          -- Update index.
          CS_KB_SYNC_INDEX_PKG.request_mark_idx_on_sec_change
                                    ( 'CHANGE_PARENT_CAT',
                                      p_category_id,
                                      l_original_parent_category_id,
                                      l_request_id,
                                      l_return_status );

               IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
               ELSE
                 RAISE INDEX_SYNC_FAILED;
               END IF;

    END IF;

    if fnd_api.to_boolean( p_commit ) then
      commit;
    end if;

  EXCEPTION
   WHEN CG_MEMBER_DEL_FAILED THEN
    ROLLBACK TO	updateCategory_PVT;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_DELETE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
   WHEN INDEX_SYNC_FAILED THEN
    ROLLBACK TO	updateCategory_PVT;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_SYNC_REQ_FAILED');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

  end updateCategory;

  -- 11510 - This procedure has been changed to use cs_kb_set_categories
  --   The x_soln_category_link_id out parameter is no longer
  --   used, so it will always return 0.
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
  )
  is
    l_date           date := sysdate;
    l_login          number := fnd_global.login_id;
    l_user           number := fnd_global.user_id;
  begin
    x_soln_category_link_id := 0;

    -- Validation is done here

    SAVEPOINT linkSolutionToCategoryTran;

    -- There is no PL/SQL table handler for the cs_kb_set_categories
    -- linking table yet. This code will directly perform insert.
    insert into CS_KB_SET_CATEGORIES (
      SET_ID,
      CATEGORY_ID,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
   ) values (
     p_solution_id,
     p_category_id,
     l_date,
     l_user,
     l_date,
     l_user,
     l_login,
     null,
     null,
     null,
     null,
     null,
     null,
     null,
     null,
     null,
     null,
     null,
     null,
     null,
     null,
     null,
     null
   );

    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    x_msg_data := null;

    if fnd_api.to_boolean( p_commit ) then
      commit;
    end if;
  exception
    when DUP_VAL_ON_INDEX then
      rollback to linkSolutionToCategoryTran; -- undo changes
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_count := 0;
      x_msg_data := null;
      if fnd_api.to_boolean( p_commit ) then
        commit;
      end if;
    when others then
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 0;
      x_msg_data := null;
  end addSolutionToCategory;

  -- 11.5.10 dev - This procedure has been changed to use cs_kb_set_categories.
  --   Need to handle error better.
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
  )
  is
  begin
    -- Validation here

    -- Remove the links
    delete from cs_kb_set_categories
    where set_id = p_solution_id
      and category_id = p_category_id;

    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    x_msg_data := null;

    if fnd_api.to_boolean( p_commit ) then
      commit;
    end if;

  exception
    when others then
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 0;
      x_msg_data := null;
  end removeSolutionFromCategory;

 function secure_cat_fullpath_names( category_id number, separator varchar2 )
 return varchar2 is
   cursor c_fullpath_names( p_cat_id number,
                            p_category_group_id number,
                            p_soln_visibility_position number) is
   select tl.name--, b.category_id, b.lev
   from (    SELECT category_id, level lev
          FROM cs_kb_soln_categories_b
          START WITH category_id = p_cat_id
          CONNECT BY prior parent_category_id = category_id
   ) b, cs_kb_soln_categories_tl tl, cs_kb_cat_group_denorm mv
   where
    b.category_id = tl.category_id
   and tl.language = userenv( 'LANG' )
   and tl.category_id = mv.child_category_id
   and mv.category_group_id = p_category_group_id -- 2
   and mv.visibility_position >= p_soln_visibility_position -- 1000
   order by b.lev desc;

   i number (15);
   l_category_group_id number;
   l_soln_visibility_position number;
   type t_varchar_arr is table of varchar2( 80 );
   l_catnames_arr t_varchar_arr;
   fullpath_name VARCHAR2( 2000 );
 begin
   l_category_group_id := cs_kb_security_pvt.Get_Category_Group_Id;
   l_soln_visibility_position := cs_kb_security_pvt.Get_Soln_Visibility_Position;

   open c_fullpath_names( category_id,
                          l_category_group_id,
                          l_soln_visibility_position );
   fetch c_fullpath_names bulk collect into l_catnames_arr;
   close c_fullpath_names;

   if( l_catnames_arr.count >= 1 ) then
     fullpath_name := fnd_message.GET_STRING('CS','CS_KB_BROWSE_ROOT_LABEL');

     for i in 1..l_catnames_arr.count loop
       fullpath_name := fullpath_name || separator || l_catnames_arr(i);
     end loop;
   end if;
   return fullpath_name;
 end;

 function admin_cat_fullpath_names( category_id number, separator varchar2 )
 return varchar2 is
   cursor c_fullpath_names( cat_id number ) is
   select tl.name--, b.category_id, b.lev
   from (    SELECT category_id, level lev
          FROM cs_kb_soln_categories_b
          START WITH category_id = cat_id
          CONNECT BY prior parent_category_id = category_id
   ) b, cs_kb_soln_categories_tl tl
   where
    b.category_id = tl.category_id
   and tl.language = userenv( 'LANG' )
   order by b.lev desc;

   i number (15);
   type t_varchar_arr is table of varchar2( 80 );
   l_catnames_arr t_varchar_arr;

   fullpath_name VARCHAR2( 2000 );
 begin
   open c_fullpath_names( category_id );
   fetch c_fullpath_names bulk collect into l_catnames_arr;
   close c_fullpath_names;

   if( l_catnames_arr.count >= 1 ) then
     fullpath_name := l_catnames_arr(1);
     for i in 2..l_catnames_arr.count loop
       fullpath_name := fullpath_name || separator || l_catnames_arr(i);
     end loop;
   end if;
   return fullpath_name;
 end;

 function admin_cat_fullpath_ids( category_id number )
 return varchar2 is
   cursor c_fullpath_ids( cat_id number ) is
     SELECT category_id
     FROM cs_kb_soln_categories_b
       START WITH category_id = cat_id
       CONNECT BY prior parent_category_id = category_id
     order by level desc;

   i number (15);
   type t_varchar_arr is table of varchar2( 80 );
   l_catids_arr t_varchar_arr;
   separator VARCHAR2( 1 ) := ':';

   fullpath_ids VARCHAR2( 2000 );
 begin
   open c_fullpath_ids( category_id );
   fetch c_fullpath_ids bulk collect into l_catids_arr;
   close c_fullpath_ids;

   if( l_catids_arr.count >= 1 ) then
     fullpath_ids := l_catids_arr(1);
     for i in 2..l_catids_arr.count loop
       fullpath_ids := fullpath_ids || separator || l_catids_arr(i);
     end loop;
   end if;
   return fullpath_ids;
 end;

 function has_pub_wip_descendents( category_id number )
 return varchar2 is
 cursor get_descendents(cp_category_id number)
 is
    SELECT CATEGORY_ID
    FROM cs_kb_soln_categories_b
    start with CATEGORY_ID = cp_category_id
    connect by prior CATEGORY_ID = PARENT_CATEGORY_ID;

 cursor get_pub_inprog(cp_category_id number)
 is
 select /*+ index(sl) */ b.set_id
 from cs_kb_set_categories sl, cs_kb_sets_b b
 where sl.category_id = cp_category_id
 and b.set_id = sl.set_id
 and (b.status = 'PUB' or (b.status <> 'OBS' and b.latest_version_flag = 'Y'));

 l_found varchar2(1) := 'N';

 begin

    <<descendent_loop>>
    for x in get_descendents(category_id) loop
        for y in get_pub_inprog(x.category_id) loop
            l_found := 'Y';
            exit descendent_loop;
        end loop;
    end loop;
    return l_found;
 end;

END CS_KB_SOLN_CATEGORIES_PVT;

/
