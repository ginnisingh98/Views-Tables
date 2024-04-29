--------------------------------------------------------
--  DDL for Package Body PA_OBJECT_DIST_LISTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OBJECT_DIST_LISTS_PVT" AS
 /* $Header: PATODLVB.pls 120.1 2005/08/19 17:04:37 mwasowic noship $ */
procedure CREATE_OBJECT_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID 		in     NUMBER,
  P_OBJECT_TYPE 	in     VARCHAR2,
  P_OBJECT_ID 		in     VARCHAR2,
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
       SAVEPOINT CREATE_OBJECT_DIST_LIST;
    END IF;

    IF p_init_msg_list = FND_API.G_TRUE THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := 'S';
    x_msg_count := 0;

    -- Validate the Input Values
     If (p_list_id is null OR
        NOT PA_DISTRIBUTION_LIST_UTILS.Check_valid_dist_list_id(
                                            p_list_id =>p_list_id) )
     then
        l_error_msg_code := 'PA_DL_LIST_ID_INV';
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_error_msg_code);

            x_msg_data := l_error_msg_code;
	    x_msg_count := x_msg_count +1;
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
     END IF;
     -- Check valid Object Type

     -- Check Valid Object Id for the Object type

     -- Insert a row if no validation failure
     If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
        PA_OBJECT_DIST_LISTS_PKG.INSERT_ROW (
            P_LIST_ID 	=> P_LIST_ID,
            P_OBJECT_TYPE => P_OBJECT_TYPE,
            P_OBJECT_ID => P_OBJECT_ID,
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

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO CREATE_OBJECT_DIST_LIST;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO CREATE_OBJECT_DIST_LIST;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_OBJECT_DIST_LISTS_PVT',
                               p_procedure_name => 'CREATE_OBJECT_DIST_LIST',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

  End CREATE_OBJECT_DIST_LIST;

procedure UPDATE_OBJECT_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID             in NUMBER,
  P_OBJECT_TYPE         in VARCHAR2,
  P_OBJECT_ID           in VARCHAR2,
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
     from pa_object_dist_lists
     where list_id = p_list_id
     and object_type = p_object_type
     and object_id = p_object_id
     and record_version_number = p_record_version_number
     for update of list_id;

 l_error_msg_code varchar2(30);
 l_rowid rowid;

 Begin
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT UPDATE_OBJECT_DIST_LIST;
    END IF;

    IF p_init_msg_list = FND_API.G_TRUE THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;

    -- Validate the Input Values
     If (p_list_id is null OR
        NOT PA_DISTRIBUTION_LIST_UTILS.Check_valid_dist_list_id(
                                            p_list_id =>p_list_id) )
     then
        l_error_msg_code := 'PA_DL_LIST_ID_INV';
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => l_error_msg_code);

            x_msg_data := l_error_msg_code;
            x_msg_count := x_msg_count +1;
            x_return_status := 'E';
            RAISE  FND_API.G_EXC_ERROR;
     END IF;
     -- Check valid Object Type

     -- Check Valid Object Id for the Object type
   -- Lock the Row
    OPEN check_record_changed;
    FETCH check_record_changed INTO l_rowid;
    IF check_record_changed%NOTFOUND THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PR_RECORD_CHANGED');
	x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE check_record_changed;

        -- Update row
     If (x_return_status = FND_API.G_RET_STS_SUCCESS
        AND p_validate_only <> fnd_api.g_true) then
        PA_OBJECT_DIST_LISTS_PKG.UPDATE_ROW (
            P_LIST_ID   => P_LIST_ID,
            P_OBJECT_TYPE => P_OBJECT_TYPE,
            P_OBJECT_ID => P_OBJECT_ID,
            P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER + 1,
            P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
            P_LAST_UPDATE_DATE  => P_LAST_UPDATE_DATE,
            P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN  ) ;
     End if;
      -- Commit the changes if requested
     if (p_commit = FND_API.G_TRUE
         AND x_return_status = fnd_api.g_ret_sts_success) then
          commit;
     end if;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO UPDATE_OBJECT_DIST_LIST;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO UPDATE_OBJECT_DIST_LIST;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_OBJECT_DIST_LISTS_PVT',
                               p_procedure_name => 'UPDATE_OBJECT_DIST_LIST',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;


  End UPDATE_OBJECT_DIST_LIST;

procedure DELETE_OBJECT_DIST_LIST (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_LIST_ID             in NUMBER,
  P_OBJECT_TYPE         in VARCHAR2,
  P_OBJECT_ID           in VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  Begin

   IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT DELETE_OBJECT_DIST_LIST;
    END IF;

    IF p_init_msg_list = FND_API.G_TRUE THEN
      fnd_msg_pub.initialize;
    END IF;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;

        -- Delete row
     If (x_return_status = FND_API.G_RET_STS_SUCCESS
        AND p_validate_only <> fnd_api.g_true) then
        PA_OBJECT_DIST_LISTS_PKG.DELETE_ROW (
            P_LIST_ID   => P_LIST_ID
           ,P_OBJECT_TYPE => P_OBJECT_TYPE
           ,P_OBJECT_ID => P_OBJECT_ID ) ;
     End if;
     -- Commit the changes if requested
     if (p_commit = FND_API.G_TRUE
         AND x_return_status = fnd_api.g_ret_sts_success) then
          commit;
     end if;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO DELETE_OBJECT_DIST_LIST;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO DELETE_OBJECT_DIST_LIST;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_OBJECT_DIST_LISTS_PVT',
                               p_procedure_name => 'DELETE_OBJECT_DIST_LIST',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
  End DELETE_OBJECT_DIST_LIST;

procedure DELETE_ASSOC_DIST_LISTS (
  p_api_version         IN     NUMBER :=  1.0,
  p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
  p_commit              IN     VARCHAR2 := FND_API.g_false,
  p_validate_only       IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
  P_OBJECT_TYPE         in VARCHAR2,
  P_OBJECT_ID           in VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  CURSOR c_list_ids IS
  SELECT list_id list_id
  FROM pa_object_dist_lists
  WHERE object_type = p_object_type
    AND object_id = p_object_id;

  CURSOR c_list_other_usage(cp_list_id NUMBER) IS
  SELECT 'Y'
  FROM pa_object_dist_lists
  WHERE list_id = cp_list_id
    AND (object_type <> p_object_type
         OR object_id <> p_object_id)
    AND ROWNUM = 1;

  l_dummy VARCHAR2(1);
  Begin

   IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT DELETE_ASSOC_DIST_LISTS;
    END IF;

    IF p_init_msg_list = FND_API.G_TRUE THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS
    AND p_validate_only <> fnd_api.g_true) THEN
    FOR rec IN c_list_ids LOOP
      -- Delete row
      PA_OBJECT_DIST_LISTS_PKG.DELETE_ROW (
         P_LIST_ID   => rec.list_id
        ,P_OBJECT_TYPE => P_OBJECT_TYPE
        ,P_OBJECT_ID => P_OBJECT_ID );

      OPEN c_list_other_usage(rec.list_id);
      FETCH c_list_other_usage INTO l_dummy;
      IF c_list_other_usage%NOTFOUND THEN
        pa_distribution_lists_pvt.delete_dist_list (
          p_validate_only => fnd_api.g_false,
          p_list_id => rec.list_id,
          p_delete_list_item_flag => 'Y',
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data);
      END IF;
      CLOSE c_list_other_usage;
      EXIT WHEN x_return_status <> 'S';
    END LOOP;
  End if;
    -- Commit the changes if requested
    if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
         commit;
    end if;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO DELETE_ASSOC_DIST_LISTS;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO DELETE_ASSOC_DIST_LISTS;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_OBJECT_DIST_LISTS_PVT',
                               p_procedure_name => 'DELETE_ASSOC_DIST_LISTS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
  End DELETE_ASSOC_DIST_LISTS;

END  PA_OBJECT_DIST_LISTS_PVT;

/
