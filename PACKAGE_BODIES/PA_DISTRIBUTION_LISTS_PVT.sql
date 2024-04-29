--------------------------------------------------------
--  DDL for Package Body PA_DISTRIBUTION_LISTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DISTRIBUTION_LISTS_PVT" AS
 /* $Header: PATDSLVB.pls 120.1 2005/08/19 17:03:55 mwasowic noship $ */
procedure CREATE_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID 		in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  P_NAME 		in     VARCHAR2,
  P_DESCRIPTION 	in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER := 1,
  P_CREATED_BY 		in NUMBER default fnd_global.user_id,
  P_CREATION_DATE 	in DATE default sysdate,
  P_LAST_UPDATED_BY 	in NUMBER default fnd_global.user_id,
  P_LAST_UPDATE_DATE 	in DATE default sysdate,
  P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
 IS
 l_error_msg_code varchar2(30);
 BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT CREATE_DIST_LIST;
    END IF;

    x_return_status := 'S';

    -- Validate the Input Values
     If (PA_DISTRIBUTION_LIST_UTILS.Check_dist_list_name_exists(
                                            p_list_name =>p_name) )
     then
        l_error_msg_code := 'PA_DL_NAME_NOT_UNIQUE';
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_error_msg_code);

            x_msg_data := l_error_msg_code;
	    x_msg_count := x_msg_count +1;
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Insert a row if no validation failure
     If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
        PA_DISTRIBUTION_LISTS_PKG.INSERT_ROW (
            P_LIST_ID 	=> P_LIST_ID,
            P_NAME 	=> P_NAME,
            P_DESCRIPTION => P_DESCRIPTION,
            P_RECORD_VERSION_NUMBER => 1,
            P_CREATED_BY => P_CREATED_BY,
            P_CREATION_DATE => P_CREATION_DATE,
            P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
            P_LAST_UPDATE_DATE 	=> P_LAST_UPDATE_DATE,
            P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN	) ;
     End if;
     -- Commit the changes if requested
     if (p_commit = FND_API.G_TRUE
         AND x_return_status = fnd_api.g_ret_sts_success) then
          commit;
     end if;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO CREATE_DIST_LIST;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO CREATE_DIST_LIST;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_DISTRIBUTION_LISTS_PVT',
                               p_procedure_name => 'CREATE_DIST_LIST',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

 END CREATE_DIST_LIST;

procedure UPDATE_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID             in NUMBER,
  P_NAME                in VARCHAR2,
  P_DESCRIPTION         in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER default fnd_global.user_id,
  P_LAST_UPDATE_DATE    in DATE default sysdate,
  P_LAST_UPDATE_LOGIN   in NUMBER default fnd_global.user_id,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
 IS
 Cursor check_record_changed IS
 select rowid
 from pa_distribution_lists
 where list_id = p_list_id
 and record_version_number = p_record_version_number
 for update of list_id;

 l_error_msg_code varchar2(30);
 l_rowid rowid;

 Begin
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT UPDATE_DIST_LIST;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- Validate the Input Values
     If (PA_DISTRIBUTION_LIST_UTILS.Check_dist_list_name_exists(
                                   p_list_id   =>p_list_id
                                  ,p_list_name =>p_name) )
     then
        l_error_msg_code := 'PA_DL_NAME_NOT_UNIQUE';
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_error_msg_code);

            x_msg_data := l_error_msg_code;
            x_msg_count := x_msg_count +1;
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
     END IF;

    -- Lock the Row
    OPEN check_record_changed;
    FETCH check_record_changed INTO l_rowid;
    IF check_record_changed%NOTFOUND THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PR_RECORD_CHANGED');
	x_return_status := FND_API.G_RET_STS_ERROR;
        CLOSE check_record_changed;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    if (check_record_changed%ISOPEN) then
        CLOSE check_record_changed;
    end if;
        -- Update row
     If (x_return_status = FND_API.G_RET_STS_SUCCESS
        AND p_validate_only <> fnd_api.g_true) then
        PA_DISTRIBUTION_LISTS_PKG.UPDATE_ROW (
            P_LIST_ID   => P_LIST_ID,
            P_NAME      => P_NAME,
            P_DESCRIPTION => P_DESCRIPTION,
            P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
            P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
            P_LAST_UPDATE_DATE  => P_LAST_UPDATE_DATE,
            P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN  ) ;
     End if;
      -- Commit the changes if requested
     if (p_commit = FND_API.G_TRUE
         AND x_return_status = fnd_api.g_ret_sts_success) then
          commit;
     end if;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO UPDATE_DIST_LIST;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO UPDATE_DIST_LIST;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_DISTRIBUTION_LISTS_PVT',
                               p_procedure_name => 'UPDATE_DIST_LIST',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

 END UPDATE_DIST_LIST;


procedure DELETE_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID             in NUMBER,
  P_DELETE_LIST_ITEM_FLAG in VARCHAR2 default 'N',
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
 IS
Begin
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT DELETE_DIST_LIST;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
        -- Update row
     If (x_return_status = FND_API.G_RET_STS_SUCCESS
        AND p_validate_only <> fnd_api.g_true) then
        PA_DISTRIBUTION_LISTS_PKG.DELETE_ROW (
            P_LIST_ID   => P_LIST_ID) ;
          IF (P_DELETE_LIST_ITEM_FLAG = 'Y') then
             Delete from PA_DIST_LIST_ITEMS
             where list_id = p_list_id;
          End if;
     End if;
     -- Commit the changes if requested
     if (p_commit = FND_API.G_TRUE
         AND x_return_status = fnd_api.g_ret_sts_success) then
          commit;
     end if;
 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO DELETE_DIST_LIST;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO DELETE_DIST_LIST;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_DISTRIBUTION_LISTS_PVT',
                               p_procedure_name => 'DELETE_DIST_LIST',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

  End DELETE_DIST_LIST;

procedure CREATE_DIST_LIST_ITEM (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ITEM_ID        in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  P_LIST_ID             in NUMBER := null,
  P_RECIPIENT_TYPE      in VARCHAR2:= null,
  P_RECIPIENT_ID        in VARCHAR2:= null,
  P_ACCESS_LEVEL        in NUMBER:= null,
  P_MENU_ID             in NUMBER:= null,
  P_EMAIL               in VARCHAR2:= null,
  P_RECORD_VERSION_NUMBER in NUMBER := 1,
  P_CREATED_BY          in NUMBER default fnd_global.user_id,
  P_CREATION_DATE       in DATE default sysdate,
  P_LAST_UPDATED_BY     in NUMBER default fnd_global.user_id,
  P_LAST_UPDATE_DATE    in DATE default sysdate,
  P_LAST_UPDATE_LOGIN   in NUMBER default fnd_global.user_id,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
 IS
 l_error_msg_code varchar2(30);
 BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT CREATE_DIST_LIST_ITEM;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    -- Validate the Input Values
     -- Validate list_id
    IF (p_list_id IS NULL OR
        NOT pa_distribution_list_utils.Check_valid_dist_list_id(p_list_id)
       ) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_DL_LIST_ID_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
     -- Validate recipient type
    IF (p_recipient_type IS NULL OR
        NOT pa_distribution_list_utils.check_valid_recipient_type( p_recipient_type )
       ) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_DL_RECIPIENT_TYPE_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

     -- Validate Recipient Id
    IF (p_recipient_id IS NULL OR
        NOT pa_distribution_list_utils.check_valid_recipient_id
                                ( p_recipient_type,
                                  p_recipient_id )
       ) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_DL_RECIPIENT_ID_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

     -- Validate Access Level

     -- Validate Menu Id
    IF (p_menu_id IS NOT NULL AND
        NOT pa_distribution_list_utils.Check_valid_menu_id(p_menu_id)
       ) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_DL_MENU_ID_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Validate Email
    IF (p_email IS NOT NULL AND (p_email <> 'Y' AND p_email <> 'N')) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_EMAIL_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

     If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
            PA_DIST_LIST_ITEMS_PKG.INSERT_ROW (
 		    P_LIST_ITEM_ID 	=> P_LIST_ITEM_ID,
  		    P_LIST_ID 	=> P_LIST_ID	,
  		    P_RECIPIENT_TYPE => P_RECIPIENT_TYPE	,
  		    P_RECIPIENT_ID 	=> P_RECIPIENT_ID,
  		    P_ACCESS_LEVEL 	=> P_ACCESS_LEVEL,
  		    P_MENU_ID 	=> P_MENU_ID	,
            P_EMAIL     => P_EMAIL      ,
 		    P_RECORD_VERSION_NUMBER => 1,
  		    P_CREATED_BY 		=> P_CREATED_BY,
  		    P_CREATION_DATE 	=> P_CREATION_DATE,
  		    P_LAST_UPDATED_BY 	=> P_LAST_UPDATED_BY,
  		    P_LAST_UPDATE_DATE 	=> P_LAST_UPDATE_DATE,
  		    P_LAST_UPDATE_LOGIN 	=> P_LAST_UPDATE_LOGIN ) ;
     End If;
     -- Commit the changes if requested
     if (p_commit = FND_API.G_TRUE
         AND x_return_status = fnd_api.g_ret_sts_success) then
          commit;
     end if;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO CREATE_DIST_LIST_ITEM;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO CREATE_DIST_LIST_ITEM;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_DISTRIBUTION_LISTS_PVT',
                               p_procedure_name => 'CREATE_DIST_LIST_ITEM',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

  End CREATE_DIST_LIST_ITEM;

procedure UPDATE_DIST_LIST_ITEM (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ITEM_ID        in NUMBER := null,
  P_LIST_ID             in NUMBER := null,
  P_RECIPIENT_TYPE      in VARCHAR2 := null,
  P_RECIPIENT_ID        in VARCHAR2 := null,
  P_ACCESS_LEVEL        in NUMBER := null,
  P_MENU_ID             in NUMBER := null,
  P_EMAIL               in VARCHAR2 := null,
  P_RECORD_VERSION_NUMBER in NUMBER := 1,
  P_LAST_UPDATED_BY     in NUMBER := fnd_global.user_id,
  P_LAST_UPDATE_DATE    in DATE := sysdate,
  P_LAST_UPDATE_LOGIN   in NUMBER := fnd_global.user_id,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
 l_error_msg_code varchar2(30);
Cursor check_record_changed IS
 select rowid
 from pa_dist_list_items
 where list_item_id = p_list_item_id
 and record_version_number = p_record_version_number
 for update ;

 l_rowid rowid;
 BEGIN
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT UPDATE_DIST_LIST_ITEM;
    END IF;
    x_return_status := fnd_api.g_ret_sts_success;

    -- Validate the Input Values
     -- Validate list_id
    IF (p_list_id IS NULL OR
        NOT pa_distribution_list_utils.Check_valid_dist_list_id(p_list_id)
       ) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_DL_LIST_ID_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
     -- Validate recipient type
    IF (p_recipient_type IS NULL OR
        NOT pa_distribution_list_utils.check_valid_recipient_type( p_recipient_type )
       ) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_DL_RECIPIENT_TYPE_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    -- Validate Email
    IF (p_email IS NOT NULL AND (p_email <> 'Y' AND p_email <> 'N')) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_EMAIL_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
     -- Validate Recipient Id
    IF (p_recipient_id IS NULL OR
        NOT pa_distribution_list_utils.check_valid_recipient_id
                                ( p_recipient_type,
                                  p_recipient_id )
       ) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_DL_RECIPIENT_ID_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
     -- Validate Access Level

     -- Validate Menu Id
    IF (p_menu_id IS NOT NULL AND
        NOT pa_distribution_list_utils.Check_valid_menu_id(p_menu_id)
       ) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_DL_MENU_ID_INV');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  -- Lock the Row
    OPEN check_record_changed;
    FETCH check_record_changed INTO l_rowid;
    IF check_record_changed%NOTFOUND THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PR_RECORD_CHANGED');
	x_return_status := FND_API.G_RET_STS_ERROR;
        CLOSE check_record_changed;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    if (check_record_changed%ISOPEN) then
       CLOSE check_record_changed;
    end if;
     If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
        PA_DIST_LIST_ITEMS_PKG.UPDATE_ROW (
 		P_LIST_ITEM_ID 	=> P_LIST_ITEM_ID,
  		P_LIST_ID 	=> P_LIST_ID	,
  		P_RECIPIENT_TYPE => P_RECIPIENT_TYPE	,
  		P_RECIPIENT_ID 	=> P_RECIPIENT_ID,
  		P_ACCESS_LEVEL 	=> P_ACCESS_LEVEL,
        P_EMAIL     => P_EMAIL,
  		P_MENU_ID 	=> P_MENU_ID	,
 		P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER + 1,
  		P_LAST_UPDATED_BY 	=> P_LAST_UPDATED_BY,
  		P_LAST_UPDATE_DATE 	=> P_LAST_UPDATE_DATE,
  		P_LAST_UPDATE_LOGIN 	=> P_LAST_UPDATE_LOGIN ) ;
     End if;
     -- Commit the changes if requested
     if (p_commit = FND_API.G_TRUE
         AND x_return_status = fnd_api.g_ret_sts_success) then
          commit;
     end if;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO UPDATE_DIST_LIST_ITEM;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO UPDATE_DIST_LIST_ITEM;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_DISTRIBUTION_LISTS_PVT',
                               p_procedure_name => 'UPDATE_DIST_LIST_ITEM',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

  End UPDATE_DIST_LIST_ITEM;

procedure DELETE_DIST_LIST_ITEM (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ITEM_ID in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER := 1,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
 IS
 Cursor check_record_changed IS
 select rowid
 from pa_dist_list_items
 where list_item_id = p_list_item_id
 and record_version_number = p_record_version_number
 for update ;

 l_error_msg_code varchar2(30);
 l_rowid rowid;

 Begin
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT DELETE_DIST_LIST_ITEM;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

  -- Lock the Row
    OPEN check_record_changed;
    FETCH check_record_changed INTO l_rowid;
    IF check_record_changed%NOTFOUND THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PR_RECORD_CHANGED');
	x_return_status := FND_API.G_RET_STS_ERROR;
        CLOSE check_record_changed;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    if (check_record_changed%ISOPEN) then
       CLOSE check_record_changed;
    end if;

        -- Delete row
     If (x_return_status = FND_API.G_RET_STS_SUCCESS
        AND p_validate_only <> fnd_api.g_true
        AND pa_distribution_list_utils.Check_valid_dist_list_item_id(p_list_item_id) = 'T') then
        PA_DIST_LIST_ITEMS_PKG.DELETE_ROW (
            P_LIST_ITEM_ID   => P_LIST_ITEM_ID) ;
     End if;
     -- Commit the changes if requested
     if (p_commit = FND_API.G_TRUE
         AND x_return_status = fnd_api.g_ret_sts_success) then
          commit;
     end if;
 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO DELETE_DIST_LIST_ITEM;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO DELETE_DIST_LIST_ITEM;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_DISTRIBUTION_LISTS_PVT',
                               p_procedure_name => 'DELETE_DIST_LIST_ITEM',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
  End DELETE_DIST_LIST_ITEM;

END  PA_DISTRIBUTION_LISTS_PVT;

/
