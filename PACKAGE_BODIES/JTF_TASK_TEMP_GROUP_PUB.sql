--------------------------------------------------------
--  DDL for Package Body JTF_TASK_TEMP_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_TEMP_GROUP_PUB" AS
/* $Header: jtfptkgb.pls 115.28 2002/12/06 01:23:03 sachoudh ship $ */


procedure  val_task_temp_group_id (p_task_template_group_id  in number) is

  cursor val_temp_group_id is
    select null
      from jtf_task_temp_groups_vl
      where task_template_group_id = p_task_template_group_id;

  v_dummy   varchar2(1);

begin

  open val_temp_group_id;
  fetch val_temp_group_id into v_dummy;
  if (val_temp_group_id%notfound) then
    close val_temp_group_id;
    fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_TEMP_GRP');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  else
    close val_temp_group_id;
  end if;

end val_task_temp_group_id;


procedure val_task_temp_group_name (p_task_template_group_name in varchar2) is

  cursor val_name is
    select null
      from jtf_task_temp_groups_vl
      where template_group_name = p_task_template_group_name;

  v_dummy varchar2(1);

begin

  open val_name;
  fetch val_name into v_dummy;
  if (val_name%found) then
    close val_name;
    fnd_message.set_name ('JTF', 'JTF_TK_DUP_TEMPL_GRP_NAME');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  else
    close val_name;
  end if;

end val_task_temp_group_name;

procedure val_upd_task_temp_group_name
  (p_task_template_group_name in varchar2,
   p_task_template_group_id   in varchar2
  ) is

  cursor val_name_upd is
    select null
      from jtf_task_temp_groups_vl
      where template_group_name = p_task_template_group_name
        and task_template_group_id <> p_task_template_group_id;

  v_dummy varchar2(1);

begin

  open val_name_upd;
  fetch val_name_upd into v_dummy;
  if (val_name_upd%found) then
    close val_name_upd;
    fnd_message.set_name ('JTF', 'JTF_TK_DUP_TEMPL_GRP_NAME');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  else
    close val_name_upd;
  end if;

end val_upd_task_temp_group_name;

procedure   val_source_object_type_code (p_src_obj_typ in varchar2) is

  cursor val_src is
    select null
      from jtf_objects_vl
      where object_code = p_src_obj_typ
        and trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
                           and     trunc(nvl(end_date_active,  sysdate));

  v_dummy  varchar2(1);

begin

  open val_src;
  fetch val_src into v_dummy;
  if (val_src%notfound) then
    close val_src;
    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_CODE');
    fnd_message.set_token ('P_OBJECT_TYPE_CODE', 'Document Type:'||p_src_obj_typ);
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  else
    close val_src;
  end if;

end val_source_object_type_code;

procedure  val_dates (p_start in date, p_end in date) is

begin

  if (p_start is not null) and (p_end is not null) then

    if (p_end < p_start) then
      fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_DATES');
      fnd_message.set_token ('P_DATE_TAG', p_start);
      fnd_msg_pub.add ;
      raise fnd_api.g_exc_error;
    end if;

  end if;

end val_dates;



Procedure  CREATE_TASK_TEMPLATE_GROUP
  (
  P_API_VERSION             IN  NUMBER,
  P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
  P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
  P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
  P_TEMPLATE_GROUP_NAME     IN  VARCHAR2,
  P_SOURCE_OBJECT_TYPE_CODE IN  VARCHAR2,
  P_START_DATE_ACTIVE       IN  DATE,
  P_END_DATE_ACTIVE         IN  DATE,
  P_DESCRIPTION             IN  VARCHAR2,
  P_ATTRIBUTE1              IN  VARCHAR2,
  P_ATTRIBUTE2              IN  VARCHAR2,
  P_ATTRIBUTE3              IN  VARCHAR2,
  P_ATTRIBUTE4              IN  VARCHAR2,
  P_ATTRIBUTE5              IN  VARCHAR2,
  P_ATTRIBUTE6              IN  VARCHAR2,
  P_ATTRIBUTE7              IN  VARCHAR2,
  P_ATTRIBUTE8              IN  VARCHAR2,
  P_ATTRIBUTE9              IN  VARCHAR2,
  P_ATTRIBUTE10             IN  VARCHAR2,
  P_ATTRIBUTE11             IN  VARCHAR2,
  P_ATTRIBUTE12             IN  VARCHAR2,
  P_ATTRIBUTE13             IN  VARCHAR2,
  P_ATTRIBUTE14             IN  VARCHAR2,
  P_ATTRIBUTE15             IN  VARCHAR2,
  P_ATTRIBUTE_CATEGORY      IN  VARCHAR2,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
  X_MSG_COUNT               OUT NOCOPY NUMBER,
  X_MSG_DATA                OUT NOCOPY VARCHAR2,
  X_TASK_TEMPLATE_GROUP_ID  OUT NOCOPY NUMBER,
  p_APPLICATION_ID 	    IN NUMBER default null
  ) is

  l_api_version           constant number := 1.0;
  l_api_name              constant varchar2(30) := 'CREATE_TASK_TEMPLATE_GROUP'  ;
  l_return_status         varchar2(1)           := fnd_api.g_ret_sts_success ;
  l_msg_data              varchar2(2000) ;
  l_msg_count             number ;

  l_task_id               jtf_tasks_b.task_id%type ;
  l_DEPENDENT_ON_TASK_id  jtf_tasks_b.task_id%type ;


begin

  savepoint create_task_template_group;

  x_return_status := fnd_api.g_ret_sts_success;

  -- standard call to check for call compatibility
  if (not fnd_api.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name) )
  then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- initialize message list i p_init_msg_list is set to true
  if (fnd_api.to_boolean(p_init_msg_list)) then
    fnd_msg_pub.initialize;
  end if;

  --check for required parameters
  if (p_template_group_name is null) then
    fnd_message.set_name('JTF', 'JTF_TK_TMP_GRP_NAME_REQ');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  end if;

  if (p_source_object_type_code is null) then
    fnd_message.set_name('JTF', 'JTF_TASK_MISSING_OBJECT_CODE');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  end if;

  -- validate fields
  val_task_temp_group_name (p_template_group_name);

  val_source_object_type_code (p_source_object_type_code);

  val_dates (p_start_date_active, p_end_date_active);

  jtf_task_temp_group_pvt.create_task_template_group
    (
    P_COMMIT,
    P_TEMPLATE_GROUP_NAME,
    P_SOURCE_OBJECT_TYPE_CODE,
    P_START_DATE_ACTIVE,
    P_END_DATE_ACTIVE,
    P_DESCRIPTION,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15,
    P_ATTRIBUTE_CATEGORY,
    X_RETURN_STATUS,
    X_MSG_COUNT,
    X_MSG_DATA,
    X_TASK_TEMPLATE_GROUP_ID,
    P_APPLICATION_ID
    );



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_task_template_group;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_task_template_group;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
                 p_data => x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO create_task_template_group;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
                END IF;
                FND_MSG_PUB.Count_And_Get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

end create_task_template_group;

--Procedure to Upate Task Template Group
   PROCEDURE lock_TASK_TEMPLATE_GROUP (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      P_TASK_TEMPLATE_GROUP_ID   IN       NUMBER,
      p_object_version_number IN   NUMBER,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER
   ) is
        l_api_version    CONSTANT NUMBER                                 := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                           := 'LOCK_TASK_TEMP_GROUPS';

        Resource_Locked exception ;

        PRAGMA EXCEPTION_INIT ( Resource_Locked , - 54 ) ;

   begin
        SAVEPOINT lock_task_template_group;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        x_return_status := fnd_api.g_ret_sts_success;

        jtf_task_temp_groups_pkg.lock_row(
            x_task_template_group_id => p_task_template_group_id ,
            x_object_version_number => p_object_version_number  );


        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
       WHEN Resource_Locked then
            ROLLBACK TO lock_task_template_group;
            fnd_message.set_name ('JTF', 'JTF_TASK_RESOURCE_LOCKED');
            fnd_message.set_token ('P_LOCKED_RESOURCE', 'Contacts');
            fnd_msg_pub.add ;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO lock_task_template_group;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO lock_task_template_group;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add ;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;



Procedure  UPDATE_TASK_TEMPLATE_GROUP
  (
  P_API_VERSION             IN  NUMBER,
  P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
  P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
  P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
  P_TASK_TEMPLATE_GROUP_ID  IN  NUMBER,
  P_TEMPLATE_GROUP_NAME     IN  VARCHAR2,
  P_SOURCE_OBJECT_TYPE_CODE IN  VARCHAR2,
  P_START_DATE_ACTIVE       IN  DATE,
  P_END_DATE_ACTIVE         IN  DATE,
  P_DESCRIPTION             IN  VARCHAR2,
  P_ATTRIBUTE1              IN  VARCHAR2,
  P_ATTRIBUTE2              IN  VARCHAR2,
  P_ATTRIBUTE3              IN  VARCHAR2,
  P_ATTRIBUTE4              IN  VARCHAR2,
  P_ATTRIBUTE5              IN  VARCHAR2,
  P_ATTRIBUTE6              IN  VARCHAR2,
  P_ATTRIBUTE7              IN  VARCHAR2,
  P_ATTRIBUTE8              IN  VARCHAR2,
  P_ATTRIBUTE9              IN  VARCHAR2,
  P_ATTRIBUTE10             IN  VARCHAR2,
  P_ATTRIBUTE11             IN  VARCHAR2,
  P_ATTRIBUTE12             IN  VARCHAR2,
  P_ATTRIBUTE13             IN  VARCHAR2,
  P_ATTRIBUTE14             IN  VARCHAR2,
  P_ATTRIBUTE15             IN  VARCHAR2,
  P_ATTRIBUTE_CATEGORY      IN  VARCHAR2,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
  X_MSG_COUNT               OUT NOCOPY NUMBER,
  X_MSG_DATA                OUT NOCOPY VARCHAR2,
  X_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER,
  p_application_id 	    IN NUMBER default null
  ) is

  l_api_version           constant number := 1.0;
  l_api_name              constant varchar2(30) := 'UPDATE_TASK_TEMPLATE_GROUP'  ;
  l_return_status         varchar2(1)           := fnd_api.g_ret_sts_success ;
  l_msg_data              varchar2(2000) ;
  l_msg_count             number ;

begin

  savepoint update_task_template_group;

  x_return_status := fnd_api.g_ret_sts_success;

  -- standard call to check for call compatibility
  if (not fnd_api.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name) )
  then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- initialize message list i p_init_msg_list is set to true
  if (fnd_api.to_boolean(p_init_msg_list)) then
    fnd_msg_pub.initialize;
  end if;

  --check for required parameters
  if (p_task_template_group_id is null) then
    fnd_message.set_name('JTF', 'JTF_TASK_MISSING_TEMP_GRP');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  end if;

  if (p_template_group_name is null) then
    fnd_message.set_name('JTF', 'JTF_TK_TMP_GRP_NAME_REQ');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  end if;

  if (p_source_object_type_code is null) then
    fnd_message.set_name('JTF', 'JTF_TASK_MISSING_OBJECT_CODE');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  end if;


  -- validate fields
  val_task_temp_group_id (p_task_template_group_id);
  val_upd_task_temp_group_name (p_template_group_name, p_task_template_group_id);
  val_source_object_type_code (p_source_object_type_code);
  val_dates (p_start_date_active, p_end_date_active);

  jtf_task_temp_group_pvt.update_task_template_group
    (
    P_COMMIT,
    P_TASK_TEMPLATE_GROUP_ID,
    P_TEMPLATE_GROUP_NAME,
    P_SOURCE_OBJECT_TYPE_CODE,
    P_START_DATE_ACTIVE,
    P_END_DATE_ACTIVE,
    P_DESCRIPTION,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15,
    P_ATTRIBUTE_CATEGORY,
    X_RETURN_STATUS,
    X_MSG_COUNT,
    X_MSG_DATA,
    X_OBJECT_VERSION_NUMBER,
    P_APPLICATION_ID
    );



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_task_template_group;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_task_template_group;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
                 p_data => x_msg_data
                );
        WHEN OTHERS THEN

                ROLLBACK TO update_task_template_group;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
                END IF;
                FND_MSG_PUB.Count_And_Get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

  end UPDATE_TASK_TEMPLATE_GROUP;


--Procedure to Delete Task Template Group

Procedure  DELETE_TASK_TEMPLATE_GROUP
  (
  P_API_VERSION              IN  NUMBER,
  P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
  P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
  P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
  P_TASK_TEMPLATE_GROUP_ID   IN  NUMBER,
  X_RETURN_STATUS            OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                OUT NOCOPY NUMBER,
  X_MSG_DATA                 OUT NOCOPY VARCHAR2,
  X_OBJECT_VERSION_NUMBER    IN NUMBER
  ) is


  l_api_version           constant number := 1.0;
  l_api_name              constant varchar2(30) := 'DELETE_TASK_TEMPLATE_GROUP'  ;
  l_return_status         varchar2(1)           := fnd_api.g_ret_sts_success ;
  l_msg_data              varchar2(2000) ;
  l_msg_count             number ;

  l_task_id               jtf_tasks_b.task_id%type ;

begin



  --                      to_char(p_task_template_group_id)||
  --                      '  g_pkg_name:'||g_pkg_name);

  savepoint delete_task_template_group;

  x_return_status := fnd_api.g_ret_sts_success;

  -- standard call to check for call compatibility
  if (not fnd_api.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name) )
  then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- initialize message list i p_init_msg_list is set to true
  if (fnd_api.to_boolean(p_init_msg_list)) then
    fnd_msg_pub.initialize;
  end if;

  --check for required parameters
  if (p_task_template_group_id is null) then
    fnd_message.set_name('JTF', 'JTF_TASK_MISSING_TEMP_GRP');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  end if;

  -- validate parameters
  val_task_temp_group_id (p_task_template_group_id);

  jtf_task_temp_group_pvt.delete_task_template_group
    (
    P_COMMIT,
    P_TASK_TEMPLATE_GROUP_ID,
    X_RETURN_STATUS,
    X_MSG_COUNT,
    X_MSG_DATA
    );



EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

              ROLLBACK TO delete_task_template_group;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
                      (p_count => x_msg_count ,
                       p_data => x_msg_data
                      );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

              ROLLBACK TO delete_task_template_group;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data
              );
      WHEN OTHERS THEN

              ROLLBACK TO delete_task_template_group;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
              END IF;
              FND_MSG_PUB.Count_And_Get
                      (p_count => x_msg_count ,
                       p_data => x_msg_data
                      );

end delete_task_template_group;

Procedure  GET_TASK_TEMPLATE_GROUP
 (
 P_API_VERSION              IN  NUMBER,
 P_INIT_MSG_LIST            IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                   IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL           IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_TASK_TEMPLATE_GROUP_ID   IN  NUMBER,
 P_TEMPLATE_GROUP_NAME      IN  VARCHAR2,
 P_SOURCE_OBJECT_TYPE_CODE  IN  VARCHAR2,
 P_START_DATE_ACTIVE        IN  DATE,
 P_END_DATE_ACTIVE          IN  DATE,
 P_SORT_DATA                IN  SORT_DATA,
 P_QUERY_OR_NEXT_CODE       IN  VARCHAR2    default 'Q',
 P_START_POINTER            IN  NUMBER,
 P_REC_WANTED               IN  NUMBER,
 P_SHOW_ALL                 IN  VARCHAR2,
 X_RETURN_STATUS            OUT NOCOPY VARCHAR2,
 X_MSG_COUNT                OUT NOCOPY NUMBER,
 X_MSG_DATA                 OUT NOCOPY VARCHAR2,
 X_TASK_TEMPLATE_GROUP      OUT NOCOPY TASK_TEMP_GROUP_TBL,
 X_TOTAL_RETRIEVED          OUT NOCOPY NUMBER,
 X_TOTAL_RETURNED           OUT NOCOPY NUMBER,
 p_APPLICATION_ID 	    IN  NUMBER default null
 ) is


  l_api_version           constant number := 1.0;
  l_api_name              constant varchar2(30) := 'GET_TASK_TEMPLATE_GROUP';
  l_return_status         varchar2(1)           := fnd_api.g_ret_sts_success ;
  l_msg_data              varchar2(2000) ;
  l_msg_count             number ;

  l_task_id               jtf_tasks_b.task_id%type ;

begin




  --                      to_char(p_task_template_group_id)||
  --                      '  g_pkg_name:'||g_pkg_name);

  savepoint get_task_template_group;

  x_return_status := fnd_api.g_ret_sts_success;

  -- standard call to check for call compatibility
  if (not fnd_api.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name) )
  then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- initialize message list i p_init_msg_list is set to true
  if (fnd_api.to_boolean(p_init_msg_list)) then
    fnd_msg_pub.initialize;
  end if;

  -- required parameters to control records returned

  -- p_query_or_next_code should be Q or N
  if (p_query_or_next_code not in ('Q', 'N')) or (p_query_or_next_code is null) then
    fnd_message.set_name('JTF', 'JTF_TK_INV_QRY_NXT');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  end if;

 -- dbms_output.put_line('1');

  -- p_show_all should be Y or N
  if (p_show_all not in ('Y', 'N')) or (p_show_all is null) then
    fnd_message.set_name('JTF', 'JTF_TK_INV_SHOW_ALL');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error;
  end if;
 -- dbms_output.put_line('2');

  if (p_show_all = 'N') then

    if (p_start_pointer is null) then
  --  dbms_output.put_line('3');
      fnd_message.set_name('JTF', 'JTF_TK_NULL_STRT_PTR');
      fnd_msg_pub.add ;
        raise fnd_api.g_exc_error;
    end if;

    if (p_rec_wanted is null) then
 --   dbms_output.put_line('4');
      fnd_message.set_name('JTF', 'JTF_TK_NULL_REC_WANT');
      fnd_msg_pub.add ;
      raise fnd_api.g_exc_error;
    end if;

  end if;


  -- validate parameters
  -- if id is entered then check to see if its valid
  if (p_task_template_group_id is not null) then
    val_task_temp_group_id (p_task_template_group_id);
  end if;
--  dbms_output.put_line('callign pvt.');

  jtf_task_temp_group_pvt.GET_TASK_TEMPLATE_GROUP
     (
     P_COMMIT                   ,
     P_TASK_TEMPLATE_GROUP_ID   ,
     P_TEMPLATE_GROUP_NAME      ,
     P_SOURCE_OBJECT_TYPE_CODE  ,
     P_START_DATE_ACTIVE        ,
     P_END_DATE_ACTIVE          ,
     P_SORT_DATA                ,
     P_QUERY_OR_NEXT_CODE       ,
     P_START_POINTER            ,
     P_REC_WANTED               ,
     P_SHOW_ALL                 ,
     X_RETURN_STATUS            ,
     X_MSG_COUNT                ,
     X_MSG_DATA                 ,
     X_TASK_TEMPLATE_GROUP      ,
     X_TOTAL_RETRIEVED          ,
     X_TOTAL_RETURNED,
     P_APPLICATION_ID
     );


EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO get_task_template_group;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
                      (p_count => x_msg_count ,
                       p_data => x_msg_data
                      );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

              ROLLBACK TO get_task_template_group;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (p_count => x_msg_count ,
               p_data => x_msg_data
              );
      WHEN OTHERS THEN
              ROLLBACK TO get_task_template_group;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
              END IF;
              FND_MSG_PUB.Count_And_Get
                      (p_count => x_msg_count ,
                       p_data => x_msg_data
                      );

end get_task_template_group;

END;

/
