--------------------------------------------------------
--  DDL for Package Body IEU_WR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WR_PUB" AS
/* $Header: IEUPUWRB.pls 120.31 2006/08/18 05:10:53 msathyan noship $ */

-- *******
--
-- Status_id : 0 - open ,  3 - Closed,  4 - Delete, 5- Sleep
-- Distribution Status: 0 - Onhold/UnAvailable, 1 - Distributable, 2 - Distributing, 3 - Distributed
--
-- *******
l_audit_log_val VARCHAR2(100);
--l_dist_resource_id   NUMBER;
--l_dist_resource_type VARCHAR2(100);
l_not_valid_flag VARCHAR2(1);
l_active_flag VARCHAR2(1);
l_workitem_obj_code_1  VARCHAR2(30);
/********* original proc without audit log ****************/

PROCEDURE CREATE_WR_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_work_item_number          IN VARCHAR2 DEFAULT NULL,
  p_title                     IN VARCHAR2 DEFAULT NULL,
  p_party_id                  IN NUMBER,
  p_priority_code             IN VARCHAR2 DEFAULT NULL,
  p_due_date                  IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type                IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER   DEFAULT NULL,
  p_ieu_enum_type_uuid        IN VARCHAR2 DEFAULT NULL,
  p_work_item_status          IN VARCHAR2 DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  x_work_item_id              OUT NOCOPY NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'CREATE_WR_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_token_str2          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code  VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_source_object_type_code VARCHAR2(30);
  l_source_object_id   NUMBER;

  l_owner_id           NUMBER;
  l_assignee_id        NUMBER;
  l_owner_type         VARCHAR2(25);
  l_assignee_type      VARCHAR2(25);

  l_owner_type_actual  VARCHAR2(30);
  l_assignee_type_actual VARCHAR2(30);

  l_priority_id        NUMBER;
  l_priority_level     NUMBER;
  l_status_id          NUMBER := 0;
  l_title_len          NUMBER := 1990;
  l_work_item_status_valid_flag VARCHAR2(10);

--  l_status_update_user_id  NUMBER;
  l_work_item_status_id  NUMBER;

  l_msg_data          VARCHAR2(4000);

  l_ws_id1            NUMBER;
  l_ws_id2            NUMBER := null;
  l_association_ws_id NUMBER;
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_curr_ws_id        NUMBER;

  l_dist_st_based_on_parent IEU_UWQM_WS_ASSCT_PROPS.DIST_ST_BASED_ON_PARENT_FLAG%TYPE;
  l_distribution_status_id NUMBER;
  l_parent_dist_status  NUMBER;
  l_set_dist_id_flag VARCHAR2(5);
  l_parent_status_id  NUMBER;
  l_ws_id NUMBER;
  l_ctr NUMBER;
  l_msg_count  NUMBER;
  l_wr_item_list  IEU_WR_PUB.IEU_WR_ITEM_LIST;

  cursor c1(p_source_object_id IN NUMBER, p_source_object_type_code IN VARCHAR2) is
   select work_item_id, workitem_pk_id, workitem_obj_code
   from   ieu_uwqm_items
   where  source_object_id = p_source_object_id
   and    source_object_type_code = p_source_object_type_code
   and ( distribution_status_id = 0 or distribution_status_id = 1);


BEGIN

      l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
      l_token_str := '';
      SAVEPOINT insert_wr_items_sp;

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      -- Check for NOT NULL columns

      IF ((p_workitem_obj_code = FND_API.G_MISS_CHAR)  or
        (p_workitem_obj_code is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || ' WORKITEM_OBJECT_CODE  ';
      END IF;
      IF ((p_workitem_pk_id = FND_API.G_MISS_NUM) or
         (p_workitem_pk_id is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORKITEM_PK_ID  ';
      END IF;
      IF ((p_work_item_number = FND_API.G_MISS_CHAR) or
         (p_work_item_number is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORK_ITEM_NUMBER  ';
      END IF;
      IF ((p_title = FND_API.G_MISS_CHAR) or
         (p_title is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  TITLE ';
      END IF;
      IF ((p_priority_code = FND_API.G_MISS_CHAR) or
         (p_priority_code is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  PRIORITY_CODE  ';
      END IF;
      IF ((p_work_item_status = FND_API.G_MISS_CHAR) or
         (p_work_item_status is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORK_ITEM_STATUS  ';
      END IF;
      IF ((p_ieu_enum_type_uuid = FND_API.G_MISS_CHAR) or
         (p_ieu_enum_type_uuid is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  ENUM_TYPE_UUID  ';
      END IF;
      IF ((p_application_id = FND_API.G_MISS_NUM) or
         (p_application_id is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  APPLICATION_ID ';
      END IF;
      IF ((p_user_id = FND_API.G_MISS_NUM) or
         (p_user_id is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  USER_ID ';
      END IF;

      If (l_miss_param_flag = 1)
      THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;

      -- Validate object Code, owner_id, owner_type, assignee_id, assignee_type

      IF (p_workitem_obj_code is not null)
      THEN

         l_token_str := '';

         BEGIN
          SELECT object_code, object_function
          INTO   l_workitem_obj_code, l_object_function
          FROM   jtf_objects_b
          WHERE  object_code = p_workitem_obj_code;
         EXCEPTION
         WHEN no_data_found THEN
          null;
         END;

         IF (l_workitem_obj_code is null)
         THEN

           l_param_valid_flag := 1;
           l_token_str := ' WORKITEM_OBJ_CODE : '||p_workitem_obj_code;

         END IF;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      IF (p_priority_code is not null)
      THEN

         l_token_str := '';

         BEGIN

             SELECT priority_id, priority_level
             INTO   l_priority_id, l_priority_level
             FROM   ieu_uwqm_priorities_b
             WHERE  priority_code = p_priority_code;

         EXCEPTION
         WHEN no_data_found THEN

             l_param_valid_flag := 1;
             l_token_str := 'PRIORITY_CODE : '||p_priority_code ;

         END;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      -- Validate Work Item Status

      IF (p_work_item_status = 'OPEN') OR
         (p_work_item_status = 'CLOSE') OR
         (p_work_item_status = 'DELETE') OR
            (p_work_item_status = 'SLEEP')
      THEN
            l_work_item_status_valid_flag := 'T';
      ELSE
            l_work_item_status_valid_flag := 'F';
            l_token_str := ' WORK_ITEM_STATUS : '||p_work_item_status;
      END IF;

      IF (l_work_item_status_valid_flag = 'F')
      THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

      END IF;


      IF (length(p_title) > l_title_len)
      THEN


            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_PARAM_EXCEED_MAX');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('IEU_UWQ_PARAM_MAX',' TITLE ');
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

      END IF;

      -- If OWNER_TYPE or ASSIGNEE_TYPE is not RS_GROUP then set it to RS_INDIVIDUAL

      IF ( (p_owner_type <> 'RS_GROUP')
           AND (p_owner_type <> 'RS_TEAM') )
      THEN

         l_owner_type:= 'RS_INDIVIDUAL';
         l_owner_type_actual := p_owner_type;

      else

         l_owner_type := p_owner_type;
         l_owner_type_actual := p_owner_type;

      END IF;

      IF ( (p_assignee_type <> 'RS_GROUP')
           AND (p_assignee_type <> 'RS_TEAM') )
      THEN

         l_assignee_type := 'RS_INDIVIDUAL';
         l_assignee_type_actual := p_assignee_type;

      else

         l_assignee_type := p_assignee_type;
         l_assignee_type_actual := p_assignee_type;

      END IF;

      if ( (p_owner_type is not null) and (p_owner_id is null)) OR
         ( (p_assignee_type is not null) and (p_assignee_id is null) )
      then
	  l_token_str := '';
	  l_token_str2 := '';
	  FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_OWN_OR_ASG_ID_NULL');
	  FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
          if ( (p_owner_id is null) and (p_owner_type is not null) OR
	       (p_owner_id is not null) and (p_owner_type is null) )
	  then
	    l_token_str := ' OWNER_ID';
	    l_token_str2 := 'OWNER_TYPE - '||p_owner_type;
          end if;
          if ( (p_assignee_id is null) and (p_assignee_type is not null) OR
	       (p_assignee_id is not null) and (p_assignee_type is null) )
	  then
	    if (l_token_str is not null)
	    then
	        l_token_str := l_token_str ||', ASSIGNEE_ID';
	    else
	        l_token_str := ' ASSIGNEE_ID';
	    end if;
	    if (l_token_str2 is not null)
	    then
	        l_token_str2 := l_token_str2 ||  ', ASSINGEE_TYPE - '||p_assignee_type;
	    else
	        l_token_str2 :=  ' ASSINGEE_TYPE - '||p_assignee_type;
	    end if;
          end if;
	  FND_MESSAGE.SET_TOKEN('ID_PARAM',l_token_str);
	  FND_MESSAGE.SET_TOKEN('TYPE_PARAM',l_token_str2);
	  fnd_msg_pub.ADD;
	  fnd_msg_pub.Count_and_Get
	    (
	       p_count   =>   x_msg_count,
	       p_data    =>   x_msg_data
	    );

	  RAISE fnd_api.g_exc_error;
       end if;

      -- Check Source_Object_type_code, Source_Object_id
/*
      IF (p_source_object_type_code is null)
      THEN
          l_source_object_type_code := p_workitem_obj_code;
      ELSE
          l_source_object_type_code := p_source_object_type_code;
      END IF;

      IF (p_source_object_id is null)
      THEN
         l_source_object_id := p_workitem_pk_id;
      ELSE
         l_source_object_id := p_source_object_id;
      END IF;
*/

      -- Set Work Item Status Id

      IF (p_work_item_status is not null)
      THEN
         IF (p_work_item_status = 'OPEN')
         THEN
             l_work_item_status_id := 0;
         ELSIF (p_work_item_status = 'CLOSE')
         THEN
             l_work_item_status_id := 3;
         ELSIF (p_work_item_status = 'DELETE')
         THEN
             l_work_item_status_id := 4;
         ELSIF (p_work_item_status = 'SLEEP')
         THEN
            l_work_item_status_id := 5;
         END IF;
      END IF;


     -- Set the Distribution states based on Business Rules

     -- Get the Work_source_id

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_id
       into   l_ws_id1
       from   ieu_uwqm_work_sources_b
       where  object_code = p_workitem_obj_code
--       and    nvl(not_valid_flag,'N') = 'N';
       and    nvl(not_valid_flag,'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'OBJECT_CODE: '||p_workitem_obj_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;

     if (p_source_object_type_code is not null)
     then

       BEGIN
         l_not_valid_flag := 'N';
         Select ws_id
         into   l_ws_id2
         from   ieu_uwqm_work_sources_b
         where  object_code = p_source_object_type_code
--         and    nvl(not_valid_flag,'N') = 'N';
         and    nvl(not_valid_flag,'N') = l_not_valid_flag;

       EXCEPTION
        WHEN OTHERS THEN

         l_ws_id2 := null;
       END;

     end if;

     if (l_ws_id2 is not null)
     then

        -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
        BEGIN
                   l_not_valid_flag := 'N';
                   SELECT a.ws_id
                   INTO   l_association_ws_id
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
                   AND    a.ws_id = b.ws_id
--                   AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_association_ws_id := null;
        END;

      else
            l_association_ws_id := null;

      end if;

      -- Get the Distribute_from, Distribute_to

      if (l_association_ws_id is not null)
      then

         l_curr_ws_id := l_association_ws_id;

         BEGIN
           l_not_valid_flag := 'N';
           SELECT  ws_a_props.dist_st_based_on_parent_flag
           INTO   l_dist_st_based_on_parent
           FROM   ieu_uwqm_work_sources_b ws_b, IEU_UWQM_WS_ASSCT_PROPS ws_a_props
           WHERE  ws_b.ws_id = l_association_ws_id
           AND    ws_b.ws_id = ws_a_props.ws_id
--           AND    nvl(ws_b.not_valid_flag,'N') = 'N';
           AND    nvl(ws_b.not_valid_flag,'N') = l_not_valid_flag;

         EXCEPTION
           WHEN OTHERS THEN
            -- Work Source Details does not exist for this Object Code
            l_token_str := '';
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
         END;
         l_dist_from := 'GROUP_OWNED';
         l_dist_to := 'INDIVIDUAL_ASSIGNED';

      else
         l_dist_from := 'GROUP_OWNED';
         l_dist_to := 'INDIVIDUAL_ASSIGNED';

         l_curr_ws_id := l_ws_id1;
/*
         BEGIN

           SELECT distribute_from, distribute_to
           INTO   l_dist_from, l_dist_to
           FROM   ieu_uwqm_work_sources_b
           WHERE  ws_id = l_ws_id1;

         EXCEPTION
           WHEN OTHERS THEN
            -- Work Source Details does not exist for this Object Code
            l_token_str := '';
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
         END;
*/
      end if;

      -- Set Distribution Status based on these rules

      -- If the Distribution State is based on the Parent, then check if the parent is distributed.

      if (l_dist_st_based_on_parent = 'Y')
      then
          BEGIN
              SELECT distribution_status_id, status_id
              INTO   l_parent_dist_status, l_parent_status_id
              FROM   ieu_uwqm_items
              WHERE  workitem_pk_id = p_source_object_id
              AND    workitem_obj_code = p_source_object_type_code;
          EXCEPTION
           WHEN OTHERS THEN
              l_parent_dist_status := null;
          END;
      end if;

      -- If the parent is not distributed, then this item will be in "On-Hold/Unavailable" status
      -- else set the status based on distribute_from and distribute_to

     if (l_parent_status_id = 3)
     then

            l_set_dist_id_flag  :=    'T';

     else

          if   (l_parent_dist_status  <> 3)
          then

                l_distribution_status_id := 0;

           else

                l_set_dist_id_flag := 'T';

           end if; /* parent_dist_status */

     end if; /* l_parent_status_id */

     if (l_set_dist_id_flag = 'T')
     then

            if (l_parent_dist_status <> 3)
            then

                    l_distribution_status_id := 0;

            else
                  if (l_dist_from = 'GROUP_OWNED') and
                          (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                    then

                          if (l_owner_type  = 'RS_GROUP') and
                             ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;
                   end if;
 /*
                     if (l_dist_from = 'GROUP_OWNED') and
                        (l_dist_to = 'INDIVIDUAL_OWNED')
                     then

                           if (l_owner_type  = 'RS_GROUP')
                           then
                                l_distribution_status_id := 1;
                           elsif (l_owner_type  = 'RS_INDIVIDUAL')
                           then
                                l_distribution_status_id := 3;
                           else
                                l_distribution_status_id := 0;
                           end if;

                    elsif (l_dist_from = 'GROUP_OWNED') and
                          (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                    then

                          if (l_owner_type  = 'RS_GROUP') and
                             ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_OWNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP') and
                             ( (l_owner_type is null) OR (l_owner_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_owner_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP')
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                  end if;
*/
          end if; /* l_parent_dist_status */

      end if; /* l_set_dist_id_flag */

      IEU_WR_ITEMS_PKG.INSERT_ROW
       ( p_workitem_obj_code,
         p_workitem_pk_id,
         p_work_item_number,
         p_title,
         p_party_id,
         l_priority_id,
         l_priority_level,
         p_due_date,
         l_work_item_status_id,
         p_owner_id,
         l_owner_type,
         p_assignee_id,
         l_assignee_type,
         l_owner_type_actual,
         l_assignee_type_actual,
         p_source_object_id,
         p_source_object_type_code,
         p_application_id,
         p_ieu_enum_type_uuid,
         p_user_id,
         p_login_id,
         l_curr_ws_id,
         l_distribution_status_id,
         x_work_item_id,
         l_msg_data,
         x_return_status
       );


      IF (x_return_status = fnd_api.g_ret_sts_success)
      THEN

          -- Set the Distribution Status of Child Work Items which are on-hold
          -- If it is a primary Work Source with Dependent Items
              if (l_association_ws_id is null)
              then
                   BEGIN
                        l_not_valid_flag := 'N';
                        select a.ws_id
                        into   l_ws_id
                        from   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                        where (parent_ws_id =  l_curr_ws_id)
                        and   a.ws_id = b.ws_id
--                        and   nvl(b.not_valid_flag, 'N') = 'N';
                        and   nvl(b.not_valid_flag, 'N') = l_not_valid_flag;
                  EXCEPTION
                       WHEN OTHERS THEN
                              l_ws_id := null;
                 END;

                if (l_ws_id is not null)
                then

                          l_ctr := 0;
                         for cur_rec in c1(p_workitem_pk_id, p_workitem_obj_code)
                         loop
                                l_wr_item_list(l_ctr).work_item_id := cur_rec.work_item_id;
                                l_wr_item_list(l_ctr).workitem_pk_id := cur_rec.workitem_pk_id;
                                l_wr_item_list(l_ctr).workitem_obj_code := cur_rec.workitem_obj_code;
                                l_ctr := l_ctr + 1;
                          end loop;

                         if ( l_wr_item_list.count > 0)
                         then

                                 IEU_WR_PUB.SYNC_DEPENDENT_WR_ITEMS
                                 ( p_api_version    => 1,
                                    p_init_msg_list  => 'T',
                                    p_commit         => 'F',
                                    p_wr_item_list   => l_wr_item_list,
                                    x_msg_count      => l_msg_count,
                                    x_msg_data       => l_msg_data,
                                    x_return_status  => x_return_status);

                                   if (x_return_status <> 'S')
                                   then
                                            x_return_status := fnd_api.g_ret_sts_error;
                                            l_token_str := l_msg_data;

                                             FND_MESSAGE.SET_NAME('IEU', 'IEU_CREATE_WR_ITEM_FAILED');
                                             FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
                                             FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

                                             fnd_msg_pub.ADD;
                                             fnd_msg_pub.Count_and_Get
                                             (
                                                       p_count   =>   x_msg_count,
                                                       p_data    =>   x_msg_data
                                             );

                                            RAISE fnd_api.g_exc_error;
                                   end if; /* x_return_status */
                           end if; /*  l_wr_item_list.count */

                     end if; /*l_ws_code is not null */

                end if; /* association_ws_id is null */

       ELSIF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;
         l_token_str := l_msg_data;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_CREATE_WR_ITEM_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;

      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END IF;


EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO insert_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO insert_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK TO insert_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END CREATE_WR_ITEM;

PROCEDURE UPDATE_WR_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_title                           IN VARCHAR2 DEFAULT NULL,
  p_party_id                        IN NUMBER,
  p_priority_code             IN VARCHAR2 DEFAULT NULL,
  p_due_date                  IN DATE,
  p_owner_id                  IN NUMBER   DEFAULT NULL,
  p_owner_type                IN VARCHAR2 DEFAULT NULL,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER   DEFAULT NULL,
  p_work_item_status          IN VARCHAR2 DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  x_msg_count                 OUT NOCOPY  NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version  NUMBER        := 1.0;
  l_api_name     VARCHAR2(30);

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_token_str2          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_owner_id           NUMBER;
  l_assignee_id        NUMBER;
  l_owner_type         VARCHAR2(25);
  l_assignee_type      VARCHAR2(25);
  l_priority_id        NUMBER;
  l_priority_level     NUMBER;
  l_status_id          NUMBER := 0;
  l_title_len          NUMBER := 1990;
  l_work_item_status_id NUMBER;
  l_work_item_status_valid_flag VARCHAR2(10);

  l_source_object_type_code VARCHAR2(30);
  l_source_object_id   NUMBER;

  l_owner_type_actual  VARCHAR2(30);
  l_assignee_type_actual VARCHAR2(30);

  l_msg_data           VARCHAR2(4000);

  l_ws_id1            NUMBER;
  l_ws_id2            NUMBER;
  l_association_ws_id NUMBER;
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_curr_ws_id        NUMBER;

  l_dist_st_based_on_parent IEU_UWQM_WS_ASSCT_PROPS.DIST_ST_BASED_ON_PARENT_FLAG%TYPE;
  l_distribution_status_id NUMBER;
  l_parent_dist_status  NUMBER;
  l_set_dist_id_flag VARCHAR2(5);
  l_parent_status_id  NUMBER;
  l_ws_id NUMBER;
  l_ctr NUMBER;
  l_msg_count  NUMBER;
  l_wr_item_list  IEU_WR_PUB.IEU_WR_ITEM_LIST;

  cursor c1(p_source_object_id IN NUMBER, p_source_object_type_code IN VARCHAR2) is
   select work_item_id, workitem_pk_id, workitem_obj_code
   from   ieu_uwqm_items
   where  source_object_id = p_source_object_id
   and    source_object_type_code = p_source_object_type_code
   and ( distribution_status_id = 0 or distribution_status_id = 1);

  m_title                            VARCHAR2(1990);
  m_party_id                         NUMBER;
  m_priority_code              VARCHAR2(30);
  m_due_date                   DATE;
  m_owner_id                   NUMBER;
  m_owner_type                 VARCHAR2(25);
  m_assignee_id                NUMBER;
  m_assignee_type              VARCHAR2(25);
  m_source_object_id           NUMBER;
  m_source_object_type_code    VARCHAR2(30);
  m_application_id             NUMBER;
  m_work_item_status           VARCHAR2(30);
  l_due_date		       DATE;
  l_reschedule_time	       DATE;

BEGIN

      l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
      l_api_name := 'UPDATE_WR_ITEM';
      l_token_str := '';
      SAVEPOINT update_wr_items_sp;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      -- Check for NOT NULL columns

      IF (p_workitem_obj_code is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORKITEM_OBJECT_CODE  ';
      END IF;
      IF (p_workitem_pk_id is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORKITEM_PK_ID  ';
      END IF;
      IF (p_priority_code is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  PRIORITY_CODE  ';
      END IF;
      IF (p_work_item_status is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORK_ITEM_STATUS  ';
      END IF;
      IF (p_application_id is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  APPLICATION_ID ';
      END IF;
      IF (p_title is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  TITLE ';
      END IF;
      IF (p_user_id is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  USER_ID ';
      END IF;

      If (l_miss_param_flag = 1)
      THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;

      ---- validate if FND_API.G_MISS is passed

/***************
      select decode(p_title, FND_API.G_MISS_CHAR, title, p_title) title,
             decode(p_party_id, FND_API.G_MISS_NUM, party_id, p_party_id) party_id,
             decode(p_due_date, FND_API.G_MISS_DATE, due_date, p_due_date) due_date,
             decode(p_owner_id, FND_API.G_MISS_NUM, owner_id, p_owner_id) owner_id,
             decode(p_owner_type, FND_API.G_MISS_CHAR, owner_type_actual, p_owner_type) owner_type_actual,
             decode(p_assignee_id, FND_API.G_MISS_NUM, assignee_id, p_assignee_id) assignee_id,
             decode(p_assignee_type, FND_API.G_MISS_CHAR, assignee_type_actual, p_assignee_type) assignee_type_actual,
             decode(p_source_object_id, FND_API.G_MISS_NUM, source_object_id, p_source_object_id) source_object_id,
             decode(p_source_object_type_code, FND_API.G_MISS_CHAR, source_object_type_code, p_source_object_type_code) source_object_type_code,
             decode(p_application_id, FND_API.G_MISS_NUM, application_id, p_application_id) application_id
       into  m_title,
             m_party_id,
             m_due_date,
             m_owner_id,
             m_owner_type,
             m_assignee_id,
             m_assignee_type,
             m_source_object_id,
             m_source_object_type_code,
             m_application_id
       from ieu_uwqm_items
       where workitem_obj_code = p_workitem_obj_code
         and workitem_pk_id = p_workitem_pk_id;

*****************/
 /**** Modified this code due to performance reasons ********/
       BEGIN
	      select title,
		     party_id,
		     due_date,
		     owner_id,
		     owner_type_actual,
		     assignee_id,
		     assignee_type_actual,
		     source_object_id,
		     source_object_type_code,
		     application_id
	       into  m_title,
		     m_party_id,
		     m_due_date,
		     m_owner_id,
		     m_owner_type,
		     m_assignee_id,
		     m_assignee_type,
		     m_source_object_id,
		     m_source_object_type_code,
		     m_application_id
	       from ieu_uwqm_items
	       where workitem_obj_code = p_workitem_obj_code
		 and workitem_pk_id = p_workitem_pk_id;

       EXCEPTION WHEN OTHERS THEN
            l_token_str := 'TITLE, PARTY_ID, DUE_DATE, OWNER_ID, OWNER_TYPE, ';
	    l_token_str := l_token_str || 'ASSIGNEE_ID, APPLICATION_ID, SOURCE_OBJECT_ID, SOURCE_OBJ_TYPE';

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
       END;

      IF ((p_title <> FND_API.G_MISS_CHAR))
      THEN
		m_title := p_title;
      END IF;
      IF ((nvl(p_party_id, -9999) <> FND_API.G_MISS_NUM) )
      THEN
        m_party_id := p_party_id;
      END IF;
      IF ((nvl(p_due_date, sysdate) <> FND_API.G_MISS_DATE) )
      THEN
        m_due_date := p_due_date;
      END IF;
      IF ((nvl(p_owner_id, -9999) <> FND_API.G_MISS_NUM ))
      THEN
	m_owner_id := p_owner_id;
      END IF;
      IF ((nvl(p_owner_type, 'NULL') <> FND_API.G_MISS_CHAR ))
      then
 	m_owner_type := p_owner_type;
      END IF;
      IF ( (nvl( p_assignee_id, -9999)  <> FND_API.G_MISS_NUM ))
      THEN
	m_assignee_id := p_assignee_id;
      END IF;
      IF ( (nvl(p_assignee_type, 'NULL') <> FND_API.G_MISS_CHAR ))
      THEN
	m_assignee_type := p_assignee_type;
      END IF;
      IF ((p_application_id <> FND_API.G_MISS_NUM) )
      THEN
	m_application_id := p_application_id;
      END IF;
      IF ((nvl(p_source_object_id, -9999) <> FND_API.G_MISS_NUM) )
      THEN
        m_source_object_id := p_source_object_id;
      END IF;
      IF ((nvl(p_source_object_type_code, 'NULL') <> FND_API.G_MISS_CHAR) )
      THEN
	m_source_object_type_code := p_source_object_type_code;
      END IF;

      BEGIN
	select decode(p_priority_code, FND_API.G_MISS_CHAR, b.priority_code, p_priority_code) priority_code
	into m_priority_code
	from ieu_uwqm_items a, ieu_uwqm_priorities_b b
	where a.priority_id = b.priority_id
	  and a.priority_level = b.priority_level
	  and a.workitem_obj_code = p_workitem_obj_code
	  and a.workitem_pk_id = p_workitem_pk_id;
       EXCEPTION
        WHEN OTHERS THEN

           l_token_str := 'PRIORITY_CODE : '||p_priority_code;

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

       END;

       BEGIN
	       select decode(p_work_item_status, FND_API.G_MISS_CHAR, decode(status_id, 0, 'OPEN', 3, 'CLOSE', 4, 'DELETE', 5, 'SLEEP'), p_work_item_status) status_id
	       into m_work_item_status
	       from ieu_uwqm_items
	       where workitem_obj_code = p_workitem_obj_code
		 and workitem_pk_id = p_workitem_pk_id;
       EXCEPTION
        WHEN OTHERS THEN
           l_token_str := 'WORK_ITEM_STATUS : '||p_work_item_status;

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;



       END;
    --------  end of FND_API.G_MISS changes


      -- Validate object Code

      IF (p_workitem_obj_code is not NULL)
      THEN

         l_token_str := '';

         BEGIN
          SELECT 1
          INTO   l_workitem_obj_code
          FROM   jtf_objects_b
          WHERE  object_code = p_workitem_obj_code;
         EXCEPTION
         WHEN no_data_found THEN
          null;
         END;

         IF (l_workitem_obj_code is null)
         THEN

           l_param_valid_flag := 1;
           l_token_str := 'WORKITEM_OBJ_CODE : '||p_workitem_obj_code;

         END IF;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      IF (m_priority_code is NOT NULL)
      THEN

         l_token_str := '';

         BEGIN

             SELECT priority_id, priority_level
             INTO   l_priority_id, l_priority_level
             FROM   ieu_uwqm_priorities_b
             WHERE  priority_code = m_priority_code;

         EXCEPTION
         WHEN no_data_found THEN

             l_param_valid_flag := 1;
             l_token_str := l_token_str || 'PRIORITY_CODE : '||m_priority_code;

         END;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      IF (m_work_item_status = 'OPEN') OR
         (m_work_item_status = 'CLOSE') OR
         (m_work_item_status = 'DELETE') OR
            (m_work_item_status = 'SLEEP')
      THEN
            l_work_item_status_valid_flag := 'T';
      ELSE
            l_work_item_status_valid_flag := 'F';
            l_token_str := ' WORK_ITEM_STATUS : '||m_work_item_status;
      END IF;

      IF (l_work_item_status_valid_flag = 'F')
      THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

      END IF;

      IF (length(m_title) > l_title_len)
      THEN


            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_PARAM_EXCEED_MAX');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('IEU_UWQ_PARAM_MAX',' TITLE ');
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

      END IF;

      -- If OWNER_TYPE or ASSIGNEE_TYPE is not RS_GROUP then set it to RS_INDIVIDUAL

      IF ( (m_owner_type <> 'RS_GROUP')
           AND (m_owner_type <> 'RS_TEAM') )
      THEN

         l_owner_type:= 'RS_INDIVIDUAL';
         l_owner_type_actual := m_owner_type;

      else

         l_owner_type := m_owner_type;
         l_owner_type_actual := m_owner_type;

      END IF;

      IF ( (m_assignee_type <> 'RS_GROUP')
           AND (m_assignee_type <> 'RS_TEAM') )
      THEN

         l_assignee_type := 'RS_INDIVIDUAL';
         l_assignee_type_actual := m_assignee_type;

      else

         l_assignee_type := m_assignee_type;
         l_assignee_type_actual := m_assignee_type;

      END IF;

      if ( (m_owner_type is not null) and (m_owner_id is null)) OR
         ( (m_assignee_type is not null) and (m_assignee_id is null) )
      then
	  l_token_str := '';
	  l_token_str2 := '';
	  FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_OWN_OR_ASG_ID_NULL');
	  FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
          if ( (m_owner_id is null) and (m_owner_type is not null) OR
	       (m_owner_id is not null) and (m_owner_type is null) )
	  then
	    l_token_str := ' OWNER_ID';
	    l_token_str2 := 'OWNER_TYPE - '||m_owner_type;
          end if;
          if ( (m_assignee_id is null) and (m_assignee_type is not null) OR
	       (m_assignee_id is not null) and (m_assignee_type is null) )
	  then
	    if (l_token_str is not null)
	    then
	        l_token_str := l_token_str ||', ASSIGNEE_ID';
	    else
	        l_token_str := ' ASSIGNEE_ID';
	    end if;
	    if (l_token_str2 is not null)
	    then
	        l_token_str2 := l_token_str2 ||  ', ASSINGEE_TYPE - '||m_assignee_type;
	    else
	        l_token_str2 :=  ' ASSINGEE_TYPE - '||m_assignee_type;
	    end if;
          end if;
	  FND_MESSAGE.SET_TOKEN('ID_PARAM',l_token_str);
	  FND_MESSAGE.SET_TOKEN('TYPE_PARAM',l_token_str2);
	  fnd_msg_pub.ADD;
	  fnd_msg_pub.Count_and_Get
	    (
	       p_count   =>   x_msg_count,
	       p_data    =>   x_msg_data
	    );

	  RAISE fnd_api.g_exc_error;
       end if;
      -- Check Source_Object_type_code, Source_Object_id
/*
      IF (p_source_object_type_code is null)
      THEN
          l_source_object_type_code := p_workitem_obj_code;
      ELSE
          l_source_object_type_code := p_source_object_type_code;
      END IF;

      IF (p_source_object_id is null)
      THEN
         l_source_object_id := p_workitem_pk_id;
      ELSE
         l_source_object_id := p_source_object_id;
      END IF;
*/
      -- Set Work Item Status Id

      IF (m_work_item_status is not null)
      THEN
         IF (m_work_item_status = 'OPEN')
         THEN
             l_work_item_status_id := 0;
         ELSIF (m_work_item_status = 'CLOSE')
         THEN
             l_work_item_status_id := 3;
         ELSIF (m_work_item_status = 'DELETE')
         THEN
             l_work_item_status_id := 4;
         ELSIF (m_work_item_status = 'SLEEP')
        THEN
            l_work_item_status_id := 5;

         END IF;
      END IF;

     -- Set the Distribution states based on Business Rules

     -- Get the Work_source_id

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_id
       into   l_ws_id1
       from   ieu_uwqm_work_sources_b
       where  object_code = p_workitem_obj_code
--       and    nvl(not_valid_flag,'N') = 'N';
       and    nvl(not_valid_flag,'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'OBJECT_CODE:' ||p_workitem_obj_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;

     if (m_source_object_type_code is not null)
     then

       BEGIN
         l_not_valid_flag := 'N';
         Select ws_id
         into   l_ws_id2
         from   ieu_uwqm_work_sources_b
         where  object_code = m_source_object_type_code
--         and    nvl(not_valid_flag,'N') = 'N';
         and    nvl(not_valid_flag,'N') = l_not_valid_flag;

       EXCEPTION
        WHEN OTHERS THEN

         l_ws_id2 := null;
       END;

     end if;

     if (l_ws_id2 is not null)
     then

        -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
        BEGIN
                   l_not_valid_flag := 'N';
                   SELECT a.ws_id
                   INTO   l_association_ws_id
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
                   AND    a.ws_id = b.ws_id
--                   AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_association_ws_id := null;
        END;

      else
            l_association_ws_id := null;

      end if;

      -- Get the Distribute_from, Distribute_to

      if (l_association_ws_id is not null)
      then

         l_curr_ws_id := l_association_ws_id;

         BEGIN
           l_not_valid_flag := 'N';
           SELECT ws_a_props.dist_st_based_on_parent_flag
           INTO   l_dist_st_based_on_parent
           FROM   ieu_uwqm_work_sources_b ws_b, IEU_UWQM_WS_ASSCT_PROPS ws_a_props
           WHERE  ws_b.ws_id = l_association_ws_id
           AND    ws_b.ws_id = ws_a_props.ws_id
--           AND    nvl(ws_b.not_valid_flag, 'N') = 'N';
           AND    nvl(ws_b.not_valid_flag, 'N') = l_not_valid_flag;

         EXCEPTION
           WHEN OTHERS THEN
            -- Work Source does not exist for this Object Code
            l_token_str := 'OBJECT_CODE: '||p_workitem_obj_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
        END;
        l_dist_from := 'GROUP_OWNED';
        l_dist_to := 'INDIVIDUAL_ASSIGNED';
      else
        l_dist_from := 'GROUP_OWNED';
        l_dist_to := 'INDIVIDUAL_ASSIGNED';

         l_curr_ws_id := l_ws_id1;
/*
         BEGIN

           SELECT distribute_from, distribute_to
           INTO   l_dist_from, l_dist_to
           FROM   ieu_uwqm_work_sources_b
           WHERE  ws_id = l_ws_id1;

         EXCEPTION
           WHEN OTHERS THEN
            -- Work Source does not exist for this Object Code
            l_token_str := 'OBJECT_CODE: '||p_workitem_obj_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
         END;
*/
      end if;

      -- Set Distribution Status based on these rules

      -- If the Distribution State is based on the Parent, then check if the parent is distributed.

      if (l_dist_st_based_on_parent = 'Y')
      then
          BEGIN
              SELECT distribution_status_id, status_id
              INTO   l_parent_dist_status, l_parent_status_id
              FROM   ieu_uwqm_items
              WHERE  workitem_pk_id = m_source_object_id
              AND    workitem_obj_code = m_source_object_type_code;
          EXCEPTION
           WHEN OTHERS THEN
              l_parent_dist_status := null;
              l_parent_status_id := null;
          END;
      end if;

      -- If the parent is not distributed, then this item will be in "On-Hold/Unavailable" status
      -- else set the status based on distribute_from and distribute_to
     if (l_parent_status_id = 3)
     then

            l_set_dist_id_flag  :=    'T';

     else

          if   (l_parent_dist_status  <> 3)
          then

                l_distribution_status_id := 0;

           else

                l_set_dist_id_flag := 'T';

           end if; /* parent_dist_status */

     end if; /* l_parent_status_id */

     if (l_set_dist_id_flag = 'T')
     then

            if (l_parent_dist_status <> 3)
            then

                    l_distribution_status_id := 0;

            else
                if (l_dist_from = 'GROUP_OWNED') and
                   (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                then
                    if (l_owner_type  = 'RS_GROUP') and
                        ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                    then
                         l_distribution_status_id := 1;
                    elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                    then
                         l_distribution_status_id := 3;
                    else
                         l_distribution_status_id := 0;
                    end if;
                end if;

  /*                  if (l_dist_from = 'GROUP_OWNED') and
                        (l_dist_to = 'INDIVIDUAL_OWNED')
                     then

                           if (l_owner_type  = 'RS_GROUP')
                           then
                                l_distribution_status_id := 1;
                           elsif (l_owner_type  = 'RS_INDIVIDUAL')
                           then
                                l_distribution_status_id := 3;
                           else
                                l_distribution_status_id := 0;
                           end if;

                    elsif (l_dist_from = 'GROUP_OWNED') and
                          (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                    then

                          if (l_owner_type  = 'RS_GROUP') and
                             ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_OWNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP') and
                             ( (l_owner_type is null) OR (l_owner_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_owner_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP')
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                  end if;
*/
         end if; /* l_parent_dist_status */
      end if; /* l_set_dist_id_flag */

      IEU_WR_ITEMS_PKG.UPDATE_ROW
       ( p_workitem_obj_code,
         p_workitem_pk_id,
         m_title,
         m_party_id,
         l_priority_id,
         l_priority_level,
         m_due_date,
         m_owner_id,
         l_owner_type,
         m_assignee_id,
         l_assignee_type,
         l_owner_type_actual,
         l_assignee_type_actual,
         m_source_object_id,
         m_source_object_type_code,
         m_application_id,
         l_work_item_status_id,
         p_user_id,
         p_login_id,
         l_curr_ws_id,
         l_distribution_status_id,
         l_msg_data,
         x_return_status
        );

      IF (x_return_status = fnd_api.g_ret_sts_success)
      THEN

          -- Set the Distribution Status of Child Work Items which are on-hold
          -- If it is a primary Work Source with Dependent Items
              if (l_association_ws_id is null)
              then

                     BEGIN
                          l_not_valid_flag := 'N';
                          select a.ws_id
                          into   l_ws_id
                          from   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                          where  (parent_ws_id =  l_curr_ws_id)
                          and   a.ws_id = b.ws_id
--                          and   nvl(b.not_valid_flag, 'N') = 'N';
                          and   nvl(b.not_valid_flag, 'N') = l_not_valid_flag;
                     EXCEPTION
                         WHEN OTHERS THEN
                                l_ws_id  := null;
                     END;

                     if (l_ws_id  is not null)
                     then

                           l_ctr := 0;
                           for cur_rec in c1(p_workitem_pk_id, p_workitem_obj_code)
                           loop
                                  l_wr_item_list(l_ctr).work_item_id := cur_rec.work_item_id;
                                  l_wr_item_list(l_ctr).workitem_pk_id := cur_rec.workitem_pk_id;
                                  l_wr_item_list(l_ctr).workitem_obj_code := cur_rec.workitem_obj_code;
                                  l_ctr := l_ctr + 1;
                            end loop;

                           if ( l_wr_item_list.count > 0)
                           then
                                   IEU_WR_PUB.SYNC_DEPENDENT_WR_ITEMS
                                   ( p_api_version    => 1,
                                      p_init_msg_list  => 'T',
                                      p_commit         => 'F',
                                      p_wr_item_list   => l_wr_item_list,
                                      x_msg_count      => l_msg_count,
                                      x_msg_data       => l_msg_data,
                                      x_return_status  => x_return_status);

                                     if (x_return_status <> 'S')
                                     then
                                              x_return_status := fnd_api.g_ret_sts_error;
                                              l_token_str := l_msg_data;

                                               FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_WR_ITEM_FAILED');
                                               FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
                                               FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

                                               fnd_msg_pub.ADD;
                                               fnd_msg_pub.Count_and_Get
                                               (
                                                         p_count   =>   x_msg_count,
                                                         p_data    =>   x_msg_data
                                               );

                                              RAISE fnd_api.g_exc_error;
                                     end if;
                             end if;

                       end if; /*l_ws_id is not null */

                else

		   x_return_status := fnd_api.g_ret_sts_success;

                end if; /* association_ws_id is null */

      ELSIF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;
         l_token_str := l_msg_data;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_WR_ITEM_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;


      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END iF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO update_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO update_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK TO update_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END UPDATE_WR_ITEM;

PROCEDURE SYNC_WS_DETAILS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  x_msg_count                 OUT  NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'SYNC_WS_DETAILS';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_msg_data          VARCHAR2(4000);

  l_ws_id             NUMBER;
  l_parent_ws_id      NUMBER;
  l_child_ws_id       NUMBER;
  l_parent_obj_code   VARCHAR2(500);
  l_child_obj_code    VARCHAR2(500);
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_ws_type           VARCHAR2(500);
  l_obj_code          VARCHAR2(500);
  l_distribution_status_id NUMBER;
  l_parent_dist_status  NUMBER;
  l_dist_st_based_on_parent  VARCHAR2(5);
  l_parent_status_id NUMBER;
  l_set_dist_id_flag  VARCHAR2(5);

  l_tasks_rules_func varchar2(256);
  l_tasks_data_list  SYSTEM.WR_TASKS_DATA_NST;
  l_def_data_list    SYSTEM.DEF_WR_DATA_NST;
  l_uwqm_count       number;
  l_task_data_var    varchar2(20);
  l_msg_count      number;
  l_return_status  varchar2(1);

  l_task_id   number;
  l_task_number varchar2(30);
  l_customer_id number;
  l_owner_id  number;
  l_owner_type_code varchar2(30);
  l_source_object_id number;
  l_source_object_type_code varchar2(30);
  l_task_name varchar2(80);
  l_assignee_id  number;
  l_assignee_type varchar2(25);
  l_task_priority_id number;
  l_date_selected   varchar2(1);
  l_due_date      date;
  l_planned_end_date  date;
  l_actual_end_date   date;
  l_scheduled_end_date date;
  l_planned_start_date  date;
  l_actual_start_date   date;
  l_scheduled_start_date date;
  l_importance_level number;
  l_priority_code  varchar2(30);
  l_task_status varchar2(10);
  l_task_status_id  number;
  l_task_type_id number;

  l_tot_cnt NUMBER;
  l_success_cnt NUMBER;
  l_workitem_sum_msg VARCHAR2(4000);
  l_failure_cnt NUMBER;
  l_final_msg VARCHAR2(4000);

  -- Cursor for primary ws
  cursor c_pry_ws(p_obj_code in VARCHAR2) is
     select work_item_id, owner_type, assignee_type
     from   ieu_uwqm_items
     where  workitem_obj_code = p_obj_code;

  -- Cursor for association ws
  cursor c_assct_ws(p_parent_obj_code in VARCHAR2, p_child_obj_code in VARCHAR2) is
     select work_item_id, owner_type, assignee_type, source_object_id, source_object_type_code
     from   ieu_uwqm_items
     where  workitem_obj_code = p_child_obj_code
     and    source_object_type_code = p_parent_obj_code;

  cursor c_task(p_source_object_type_code in varchar2) is
   select tb.task_id, tb.task_number, tb.customer_id, tb.owner_id, tb.owner_type_code,
  tb.source_object_id, tb.source_object_type_code,
--  decode(tb.date_selected, 'P', tb.planned_end_date,
--         'A', tb.actual_end_date, 'S', tb.scheduled_end_date, null, tb.scheduled_end_date) due_date,
  tb.planned_start_date, tb.planned_end_date, tb.actual_start_date, tb.actual_end_date,
  tb.scheduled_start_date, tb.scheduled_end_date,tb.task_type_id,
  tb.task_status_id, tt.task_name, tp.importance_level, ip.priority_code, tb.task_priority_id
  from jtf_tasks_b tb, jtf_tasks_tl tt, jtf_task_priorities_vl tp, ieu_uwqm_priorities_b ip
  where tb.entity = 'TASK' and nvl(tb.deleted_flag, 'N') = 'N' and tb.task_id = tt.task_id
  and tt.language = userenv('LANG') and tp.task_priority_id = nvl(tb.task_priority_id, 4)
  and least(tp.importance_level, 4) = ip.priority_level
  and tb.open_flag = 'Y'
  and tb.source_object_type_code = p_source_object_type_code;

  CURSOR c_task_status(p_source_object_type_code in varchar2) IS
   SELECT TASK_ID,
          DECODE(DELETED_FLAG, 'Y', 4, 3) "STATUS_ID"
   FROM JTF_TASKS_B
   WHERE SOURCE_OBJECT_TYPE_CODE = p_source_object_type_code
   AND ((OPEN_FLAG = 'N' AND DELETED_FLAG = 'N') OR (DELETED_FLAG = 'Y'))
   AND ENTITY = 'TASK';

  TYPE NUMBER_TBL   is TABLE OF NUMBER        INDEX BY BINARY_INTEGER;

  TYPE status_rec is RECORD
  (
	  l_task_id_list		NUMBER_TBL,
	  l_status_id_list		NUMBER_TBL
  );

  l_task_status_rec status_rec;

  l_array_size NUMBER;
  l_done       BOOLEAN;

  dml_errors EXCEPTION;
  PRAGMA exception_init(dml_errors, -24381);
  errors number;

BEGIN

  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  l_token_str := '';
  l_dist_from := 'GROUP_OWNED';
  l_dist_to   := 'INDIVIDUAL_ASSIGNED';
  l_priority_code := 'LOW';
  l_array_size := 2000;

    SAVEPOINT sync_ws_details_sp;

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;


     -- Set the Distribution states based on Business Rules

     -- Get the Work_source_id

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_id, ws_type, object_code
       into   l_ws_id, l_ws_type, l_obj_code
       from   ieu_uwqm_work_sources_b
       where  ws_code = p_ws_code
--       and nvl(not_valid_flag, 'N') = 'N';
       and nvl(not_valid_flag, 'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;

     if (l_ws_type = 'PRIMARY')
     then
            -- The Sync script works only for Association Work Source
            -- If a primary Work Source is passed then it will throw an exception and exit
            -- Work Source does not exist for this Object Code
            l_token_str := 'WORK_SOURCE:' ||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;


     elsif (l_ws_type = 'ASSOCIATION')
     then
        BEGIN

           SELECT parent_ws_id, child_ws_id, dist_st_based_on_parent_flag , tasks_rules_function
           INTO   l_parent_ws_id, l_child_ws_id, l_dist_st_based_on_parent , l_tasks_rules_func
           FROM   IEU_UWQM_WS_ASSCT_PROPS
           WHERE  ws_id = l_ws_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

        BEGIN
           l_not_valid_flag := 'N';
           SELECT object_code
           INTO   l_parent_obj_code
           FROM   IEU_UWQM_WORK_SOURCES_B
           WHERE  ws_id = l_parent_ws_id
--           and nvl(not_valid_flag, 'N') = 'N';
           and nvl(not_valid_flag, 'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

        BEGIN
           l_not_valid_flag := 'N';
           SELECT object_code
           INTO   l_child_obj_code
           FROM   IEU_UWQM_WORK_SOURCES_B
           WHERE  ws_id = l_child_ws_id
--           and nvl(not_valid_flag, 'N') = 'N';
           and nvl(not_valid_flag, 'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;


     end if;

   /******************** This is not used now *****************************

     if (l_ws_type = 'PRIMARY')
     then

         for cur_rec in c_pry_ws(l_obj_code)
         loop

            if (l_dist_from = 'GROUP_OWNED') and
               (l_dist_to = 'INDIVIDUAL_OWNED')
            then

               if (cur_rec.owner_type = 'RS_GROUP')
               then
                   l_distribution_status_id := 1;
               elsif (cur_rec.owner_type = 'RS_INDIVIDUAL')
               then
                   l_distribution_status_id := 3;
               else
                   l_distribution_status_id := 0;
               end if;

           elsif (l_dist_from = 'GROUP_OWNED') and
                 (l_dist_to = 'INDIVIDUAL_ASSIGNED')
           then

               if (cur_rec.owner_type = 'RS_GROUP') and
                  ( (cur_rec.assignee_type is null) OR (cur_rec.assignee_type <> 'RS_INDIVIDUAL') )
               then
                  l_distribution_status_id := 1;
               elsif (cur_rec.assignee_type    = 'RS_INDIVIDUAL')
               then
                  l_distribution_status_id := 3;
               else
                  l_distribution_status_id := 0;
               end if;

           elsif (l_dist_from = 'GROUP_ASSIGNED') and
                 (l_dist_to = 'INDIVIDUAL_OWNED')
           then

               if (cur_rec.assignee_type = 'RS_GROUP') and
                  ( (cur_rec.owner_type is null) OR (cur_rec.owner_type <> 'RS_INDIVIDUAL') )
               then
                  l_distribution_status_id := 1;
               elsif (cur_rec.owner_type= 'RS_INDIVIDUAL')
               then
                  l_distribution_status_id := 3;
               else
                  l_distribution_status_id := 0;
               end if;

           elsif (l_dist_from = 'GROUP_ASSIGNED') and
                 (l_dist_to = 'INDIVIDUAL_ASSIGNED')
           then

               if (cur_rec.assignee_type   = 'RS_GROUP')
               then
                  l_distribution_status_id := 1;
               elsif (cur_rec.assignee_type   = 'RS_INDIVIDUAL')
               then
                  l_distribution_status_id := 3;
               else
                  l_distribution_status_id := 0;
               end if;

           end if;

           update ieu_uwqm_items
           set    ws_id = l_ws_id,
                  distribution_status_id = l_distribution_status_id
           where work_item_id = cur_rec.work_item_id;
           commit;

         end loop;

      elsif (l_ws_type = 'ASSOCIATION')
    ********************************************************************/
      if (l_ws_type = 'ASSOCIATION')
      then
         l_success_cnt := 0;
         if l_tasks_rules_func is not null
         then
	   fnd_file.new_line(FND_FILE.LOG, 1);
	   fnd_file.put_line(FND_FILE.LOG, 'SYNC_WS_DETAILS API');

           open c_task(l_parent_obj_code);
           loop

              fetch c_task into l_task_id, l_task_number, l_customer_id, l_owner_id, l_owner_type_code,
              l_source_object_id, l_source_object_type_code,
	      --l_due_date,
	      l_planned_start_date,
              l_planned_end_date, l_actual_start_date, l_actual_end_date, l_scheduled_start_date, l_scheduled_end_date,
              l_task_type_id, l_task_status_id, l_task_name, l_importance_level, l_priority_code, l_task_priority_id;

	    --  insert into p_temp(msg) values (' count after fetch: '||l_tmp_var);

              exit when c_task%notfound;

              begin
                select 'SLEEP' into l_task_status
                from jtf_task_statuses_vl
                where (nvl(on_hold_flag,'N') = 'Y')
                and task_status_id = l_task_status_id;
                EXCEPTION WHEN no_data_found
                THEN
                l_task_status := 'OPEN';
              end;

	      begin
	        select booking_end_date
		into   l_due_date
		from   jtf_task_all_assignments
		where  task_id = l_task_id
		and    assignee_role = 'OWNER';
	      exception when others then
		    -- Work Source does not exist for this Object Code
		    l_token_str := sqlcode||' '||sqlerrm;
		    fnd_msg_pub.ADD;
		    fnd_msg_pub.Count_and_Get
		    (
		       p_count   =>   x_msg_count,
		       p_data    =>   x_msg_data
		    );

		    RAISE fnd_api.g_exc_error;
	      end;

              begin
                 l_workitem_obj_code_1 := 'TASK';
                 select count(*) into l_uwqm_count
                 from ieu_uwqm_items
--                 where workitem_obj_code = 'TASK'
                 where workitem_obj_code = l_workitem_obj_code_1
                 and workitem_pk_id = l_task_id;
                 exception when others then
                 l_uwqm_count := 0;
              end;

              if l_uwqm_count = 0 then
                 l_task_data_var := 'CREATE_TASK';
              else
                 l_task_data_var := 'UPDATE_TASK';
              end if;

              l_tasks_data_list := SYSTEM.WR_TASKS_DATA_NST();

            --insert into p_temp(msg) values('type XSR');
              l_tasks_data_list.extend;

              l_tasks_data_list(l_tasks_data_list.last) := SYSTEM.WR_TASKS_DATA_OBJ (
                                                     l_task_data_var,
                                                     l_task_id,
                                                      null,
                                                     l_task_number,
                                                     l_task_name,
                                                     l_task_type_id,
                                                     l_task_status_id,
                                                     l_task_priority_id,
                                                     l_owner_id,
                                                     l_owner_type_code,
                                                     l_source_object_id,
                                                     l_source_object_type_code,
                                                     l_customer_id,
                                                     l_date_selected,
                                                     l_planned_start_date,
                                                     l_planned_end_date,
                                                     l_scheduled_start_date,
                                                     l_scheduled_end_date,
                                                     l_actual_start_date,
                                                     l_actual_end_date,
                                                     null,
                                                     null,
                                                     null);
                                                             --insert into p_temp(msg) values('calling SR Tasks');
              l_def_data_list := SYSTEM.DEF_WR_DATA_NST();

              l_def_data_list.extend;


              l_def_data_list(l_def_data_list.last) := SYSTEM.DEF_WR_DATA_OBJ(
                                                l_task_status,
                                                l_priority_code,
                                                l_due_date,
                                                'TASKS',
                                                null
                                                 );


              execute immediate
              'BEGIN '||l_tasks_rules_func ||' ( :1, :2, :3, :4 , :5); END ; '
              USING IN l_tasks_data_list, IN l_def_data_list , OUT l_msg_count, OUT l_msg_data, OUT l_return_status;

	      If (l_return_status = 'S')
	      then
		l_success_cnt := l_success_cnt + 1;
	      else
	        l_failure_cnt := l_failure_cnt + 1;

              if (l_failure_cnt < 20)
              then

			fnd_file.new_line(FND_FILE.LOG, 1);
			FND_MESSAGE.SET_NAME('IEU', 'IEU_SYNCH_WR_DIST_STATUS_FAIL');
			FND_MESSAGE.SET_TOKEN('OBJ_CODE', 'TASK');
			FND_MESSAGE.SET_TOKEN('WORKITEM_NUM', l_task_id);
			FND_MESSAGE.SET_TOKEN('DETAILS', l_msg_data);
			l_final_msg := FND_MESSAGE.GET;
			fnd_file.put_line(FND_FILE.LOG, l_final_msg);

		end if;

	      end if;

--	      insert into p_temp(msg) values (' called tsk rules func..ret sts. '||l_task_id||' '||l_return_status||'-'||l_msg_data);

           end loop;

	   if (l_failure_cnt < 0)
	   then
	      x_return_status := 'E';
	   else
	      x_return_status := 'S';
           end if;

	   l_tot_cnt := c_task%ROWCOUNT;
	   FND_MESSAGE.SET_NAME('IEU', 'IEU_SYNCH_WR_DIST_STATUS_SUM');
	   FND_MESSAGE.SET_TOKEN('SUCCESS_COUNT', l_success_cnt);
	   FND_MESSAGE.SET_TOKEN('FAILED_COUNT', (l_tot_cnt - l_success_cnt));
	   FND_MESSAGE.SET_TOKEN('TOTAL_COUNT', l_tot_cnt );
	   fnd_msg_pub.ADD;
	   fnd_msg_pub.Count_and_Get
	   (
	      p_count   =>   x_msg_count,
	      p_data    =>   x_msg_data
	   );

           -- Write to log. Have to set msg again as its been removed from stack.
	   FND_MESSAGE.SET_NAME('IEU', 'IEU_SYNCH_WR_DIST_STATUS_SUM');
	   FND_MESSAGE.SET_TOKEN('SUCCESS_COUNT', l_success_cnt);
	   FND_MESSAGE.SET_TOKEN('FAILED_COUNT', (l_tot_cnt - l_success_cnt));
	   FND_MESSAGE.SET_TOKEN('TOTAL_COUNT', l_tot_cnt );
	   l_final_msg := FND_MESSAGE.GET;
           fnd_file.put_line(FND_FILE.LOG, l_final_msg);

	   --dbms_output.put_line('msg: '||l_final_msg);

	   close c_task;

         else

           for cur_rec in c_assct_ws(l_parent_obj_code, l_child_obj_code)
           loop

             if (l_dist_st_based_on_parent = 'Y')
             then
               BEGIN
                 SELECT distribution_status_id, status_id
                 INTO   l_parent_dist_status, l_parent_status_id
                 FROM   ieu_uwqm_items
                 WHERE  workitem_pk_id = cur_rec.source_object_id
                 AND    workitem_obj_code = cur_rec.source_object_type_code;
                 EXCEPTION
                 WHEN OTHERS THEN
                   l_parent_dist_status := null;
                END;
              end if;

          -- If the parent is not distributed, then this item will be in "On-Hold/Unavailable" status
          -- else set the status based on distribute_from and distribute_to

             if (l_parent_status_id = 3)
             then

                    l_set_dist_id_flag  :=    'T';

             else

                  if   (l_parent_dist_status  <> 3)
                  then

                        l_distribution_status_id := 0;

                   else

                        l_set_dist_id_flag := 'T';

                   end if; /* parent_dist_status */

             end if; /* l_parent_status_id */

             if (l_set_dist_id_flag = 'T')
             then

                 if (l_dist_from = 'GROUP_OWNED') and
                    (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                 then
                     if (cur_rec.owner_type  = 'RS_GROUP') and
                        ( (cur_rec.assignee_type  is null) OR (cur_rec.assignee_type  <> 'RS_INDIVIDUAL') )
                     then
                         l_distribution_status_id := 1;
                     elsif (cur_rec.assignee_type   = 'RS_INDIVIDUAL')
                     then
                         l_distribution_status_id := 3;
                     else
                         l_distribution_status_id := 0;
                     end if;
                  end if;

              end if; /* l_set_dist_id_flag */


              update ieu_uwqm_items
              set    ws_id = l_ws_id,
                  distribution_status_id = l_distribution_status_id
              where work_item_id = cur_rec.work_item_id;
              commit;

           end loop; /* cur_rec */
         end if;

         -- Update Close and Delete Statuses

         open c_task_status(l_parent_obj_code);
	 loop

	     FETCH c_task_status
	     BULK COLLECT INTO
		  l_task_status_rec.l_task_id_list,
		  l_task_status_rec.l_status_id_list
             LIMIT l_array_size;

	     l_done := c_task_status%NOTFOUND;

	     BEGIN
	--	fnd_file.put_line(FND_FILE.LOG,'Begin update');
		     FORALL i in 1..l_task_status_rec.l_task_id_list.COUNT SAVE EXCEPTIONS
			update IEU_UWQM_ITEMS
			set	status_id = l_task_status_rec.l_status_id_list(i),
         			LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
	        		LAST_UPDATE_DATE       = SYSDATE,
		        	LAST_UPDATE_LOGIN      = FND_GLOBAL.LOGIN_ID
			where   workitem_obj_code = 'TASK'
                        and     workitem_pk_id = l_task_status_rec.l_task_id_list(i)
                        and     source_object_type_code = l_parent_obj_code;

	     EXCEPTION
		  WHEN dml_errors THEN
		   errors := SQL%BULK_EXCEPTIONS.COUNT;
		   FOR i IN 1..errors LOOP

                       fnd_file.new_line(FND_FILE.LOG, 1);
                       FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
                       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_WR_PUB.SYNC_WS_DETAILS');
                       FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_task_status_rec.l_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                      fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );
                    END LOOP;

                    RAISE fnd_api.g_exc_error;
	     END;

	     COMMIT;

             l_task_status_rec.l_task_id_list.DELETE;
             l_task_status_rec.l_status_id_list.DELETE;

	     exit when (l_done);

	   end loop;

	   close c_task_status;

      end if;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO sync_ws_details_sp;
  x_return_status := fnd_api.g_ret_sts_error;
  x_msg_data := SQLCODE||' - '||SQLERRM;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO sync_ws_details_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  x_msg_data := SQLCODE||' - '||SQLERRM;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK TO sync_ws_details_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  x_msg_data := SQLCODE||' - '||SQLERRM;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END SYNC_WS_DETAILS;

PROCEDURE GET_NEXT_WORK_FOR_APPS
 ( p_api_version               IN  NUMBER,
   p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
   p_commit                    IN VARCHAR2 DEFAULT NULL,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_ws_det_list      IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST,
   x_uwqm_workitem_data       OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2) IS

  l_dist_from_where        VARCHAR2(4000);
  l_dist_to_where          VARCHAR2(4000);

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'GET_NEXT_WORK_FOR_APPS';

  l_token_str          VARCHAR2(4000);

  l_ws_id             NUMBER;
  l_ws_type           IEU_UWQM_WORK_SOURCES_B.WS_TYPE%TYPE;
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_obj_code          IEU_UWQM_WORK_SOURCES_B.OBJECT_CODE%TYPE;
  l_bindvar_from_list IEU_UWQ_GET_NEXT_WORK_PVT.IEU_UWQ_BINDVAR_LIST;
  l_bindvar_to_list   IEU_UWQ_GET_NEXT_WORK_PVT.IEU_UWQ_BINDVAR_LIST;

BEGIN

  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  l_token_str := '';
  l_dist_from := 'GROUP_OWNED';
  l_dist_to   := 'INDIVIDUAL_ASSIGNED';
  SAVEPOINT next_work_for_apps;

  x_return_status := fnd_api.g_ret_sts_success;

  -- Check for API Version

  IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
  THEN
        RAISE fnd_api.g_exc_unexpected_error;
  END IF;

      -- Initialize Message list

  IF fnd_api.to_boolean(p_init_msg_list)
  THEN
         FND_MSG_PUB.INITIALIZE;
  END IF;


  for i in p_ws_det_list.first..p_ws_det_list.last
  loop

    --dbms_output.put_line('ws_code : '||p_ws_det_list(i).ws_code);
    BEGIN
       l_not_valid_flag := 'N';
       Select ws_id, ws_type, object_code
       into   l_ws_id, l_ws_type, l_obj_code
       from   ieu_uwqm_work_sources_b
       where  ws_code = p_ws_det_list(i).ws_code
--       and nvl(not_valid_flag, 'N') = 'N';
       and nvl(not_valid_flag, 'N') = l_not_valid_flag;

    EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_det_list(i).ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.GET_NEXT_WORK_FOR_APPS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

    END;

  end loop;

  -- Get the extra where clause for Distribute_from and distribute_to based ont he ws_code
  IEU_UWQ_GET_NEXT_WORK_PVT.GET_WS_WHERE_CLAUSE
    (p_type             => 'DELIVER',
     p_ws_det_list      => p_ws_det_list,
     p_resource_id      => p_resource_id,
     x_dist_from_where  => l_dist_from_where,
     x_dist_to_where    => l_dist_to_where,
     x_bindvar_from_list => l_bindvar_from_list,
     x_bindvar_to_list => l_bindvar_to_list );

  --dbms_output.put_line('calling dist and deliver.. ret status : '||x_return_status  );

  IEU_UWQ_GET_NEXT_WORK_PVT.DISTRIBUTE_AND_DELIVER_WR_ITEM
   ( p_api_version                  => p_api_version,
     p_resource_id                  => p_resource_id,
     p_language                     => p_language,
     p_source_lang                  => p_source_lang,
     p_dist_from_extra_where_clause    => l_dist_from_where,
     p_dist_to_extra_where_clause   => l_dist_to_where,
     p_bindvar_from_list =>  l_bindvar_from_list,
     p_bindvar_to_list => l_bindvar_to_list,
     x_uwqm_workitem_data           => x_uwqm_workitem_data,
     x_msg_count                    => x_msg_count,
     x_msg_data                     => x_msg_data,
     x_return_status                => x_return_status);



  --dbms_output.put_line('executed proc: '||x_return_status);
EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO next_work_for_apps;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO next_work_for_apps;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK TO next_work_for_apps;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END GET_NEXT_WORK_FOR_APPS;


PROCEDURE SYNC_DEPENDENT_WR_ITEMS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_wr_item_list              IN IEU_WR_PUB.IEU_WR_ITEM_LIST ,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'SYNC_DEPENDENT_WR_ITEMS';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_msg_data          VARCHAR2(4000);

  l_ws_id             NUMBER;
  l_parent_ws_id      NUMBER;
  l_child_ws_id       NUMBER;
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_ws_type           VARCHAR2(500);
  l_ws_code           VARCHAR2(500);
  l_owner_type        IEU_UWQM_ITEMS.OWNER_TYPE%TYPE;
  l_assignee_type     IEU_UWQM_ITEMS.ASSIGNEE_TYPE%TYPE;
  l_source_object_id  NUMBER;
  l_source_object_type_code  IEU_UWQM_ITEMS.SOURCE_OBJECT_TYPE_CODE%TYPE;
  l_distribution_status_id NUMBER;
  l_parent_dist_status  NUMBER;
  l_dist_st_based_on_parent  VARCHAR2(5);
  l_set_dist_id_flag VARCHAR2(5);
  l_parent_status_id  NUMBER;

BEGIN

  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  l_token_str := '';
  l_dist_from := 'GROUP_OWNED';
  l_dist_to   := 'INDIVIDUAL_ASSIGNED';
  SAVEPOINT sync_dependent_wr_items_sp;

  x_return_status := fnd_api.g_ret_sts_success;

  -- Check for API Version

  IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
  THEN
      RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize Message list

  IF fnd_api.to_boolean(p_init_msg_list)
  THEN
      FND_MSG_PUB.INITIALIZE;
  END IF;


  for i in p_wr_item_list.first .. p_wr_item_list.last
  loop


  -- dbms_output.put_line('work item pk id: '||p_wr_item_list(i).workitem_pk_id||' obj code: '||p_wr_item_list(i).workitem_obj_code);
     -- Get all the required Work Item details

     BEGIN

        select owner_type, assignee_type, ws_id, source_object_id, source_object_type_code
        into   l_owner_type , l_assignee_type, l_ws_id, l_source_object_id, l_source_object_type_code
        from   ieu_uwqm_items
        where  workitem_pk_id = p_wr_item_list(i).workitem_pk_id
        and    workitem_obj_code = p_wr_item_list(i).workitem_obj_code;

     EXCEPTION
       WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_error;

         l_token_str := p_wr_item_list(i).workitem_obj_code ||' WORKITEM_PK_ID : '|| p_wr_item_list(i).workitem_pk_id ||' - '||l_msg_data;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;

     END;


     BEGIN
       l_not_valid_flag := 'N';
       Select ws_code, ws_type
       into   l_ws_code, l_ws_type
       from   ieu_uwqm_work_sources_b
       where  ws_id = l_ws_id
--       and    nvl(not_valid_flag, 'N') = 'N';
       and    nvl(not_valid_flag, 'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||l_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;


     if (l_ws_type = 'ASSOCIATION')
     then
        BEGIN

           SELECT parent_ws_id, child_ws_id, dist_st_based_on_parent_flag
           INTO   l_parent_ws_id, l_child_ws_id, l_dist_st_based_on_parent
           FROM   IEU_UWQM_WS_ASSCT_PROPS
           WHERE  ws_id = l_ws_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||l_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

     end if;/* ws_type */

      -- Set Distribution Status based on these rules

      -- If the Distribution State is based on the Parent, then check if the parent is distributed.

      if (l_dist_st_based_on_parent = 'Y')
      then
          BEGIN
              SELECT distribution_status_id, status_id
              INTO   l_parent_dist_status, l_parent_status_id
              FROM   ieu_uwqm_items
              WHERE  workitem_pk_id = l_source_object_id
              AND    workitem_obj_code = l_source_object_type_code;
          EXCEPTION
           WHEN OTHERS THEN
              l_parent_dist_status := null;
          END;
      end if;

      --dbms_output.put_line('dist st based on parent; '||l_dist_st_based_on_parent ||'s id: '||l_source_object_id||' s obj: '||l_source_object_type_code||' parent dist st: '||l_parent_dist_status);


      -- If the parent is not distributed, then this item will be in "On-Hold/Unavailable" status
      -- else set the status based on distribute_from and distribute_to

     if (l_parent_status_id = 3)
     then

            l_set_dist_id_flag  :=    'T';

     else

          if   (l_parent_dist_status  <> 3)
          then

                l_distribution_status_id := 0;

           else

                l_set_dist_id_flag := 'T';

           end if; /* parent_dist_status */

     end if; /* l_parent_status_id */

     if (l_set_dist_id_flag = 'T')
     then

          if (l_dist_from = 'GROUP_OWNED') and
             (l_dist_to = 'INDIVIDUAL_ASSIGNED')
          then
               if (l_owner_type  = 'RS_GROUP') and
                  ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
               then
                   l_distribution_status_id := 1;
               elsif (l_assignee_type  = 'RS_INDIVIDUAL')
               then
                   l_distribution_status_id := 3;
               else
                   l_distribution_status_id := 0;
               end if;
           end if;

            /*         if (l_dist_from = 'GROUP_OWNED') and
                        (l_dist_to = 'INDIVIDUAL_OWNED')
                     then

                           if (l_owner_type  = 'RS_GROUP')
                           then
                                l_distribution_status_id := 1;
                           elsif (l_owner_type  = 'RS_INDIVIDUAL')
                           then
                                l_distribution_status_id := 3;
                           else
                                l_distribution_status_id := 0;
                           end if;

                    elsif (l_dist_from = 'GROUP_OWNED') and
                          (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                    then

                          if (l_owner_type  = 'RS_GROUP') and
                             ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_OWNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP') and
                             ( (l_owner_type is null) OR (l_owner_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_owner_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP')
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                  end if;
             */
      end if; /* l_set_dist_id_flag */

--     dbms_output.put_line('l_set_dist_id_flag: '||l_set_dist_id_flag|| ' dist status: '|| l_distribution_status_id);
      update ieu_uwqm_items
      set distribution_status_id = l_distribution_status_id
      where workitem_pk_id = p_wr_item_list(i).workitem_pk_id
      and   workitem_obj_code = p_wr_item_list(i).workitem_obj_code;

      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END iF;


  end loop; /* p_wr_item_list */

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO sync_dependent_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO sync_dependent_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK TO sync_dependent_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END SYNC_DEPENDENT_WR_ITEMS;




/******** overloaded Proc for Audit Log ***************/

      -- Get the Audit Log profile Option
  --    l_audit_log_val :=  FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');


PROCEDURE CREATE_WR_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_work_item_number          IN VARCHAR2 DEFAULT NULL,
  p_title                     IN VARCHAR2 DEFAULT NULL,
  p_party_id                  IN NUMBER,
  p_priority_code             IN VARCHAR2 DEFAULT NULL,
  p_due_date                  IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type                IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER   DEFAULT NULL,
  p_ieu_enum_type_uuid        IN VARCHAR2 DEFAULT NULL,
  p_work_item_status          IN VARCHAR2 DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_work_item_id              OUT NOCOPY NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'CREATE_WR_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_token_str2          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code  VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_source_object_type_code VARCHAR2(30);
  l_source_object_id   NUMBER;

  l_owner_id           NUMBER;
  l_assignee_id        NUMBER;
  l_owner_type         VARCHAR2(25);
  l_assignee_type      VARCHAR2(25);

  l_owner_type_actual  VARCHAR2(30);
  l_assignee_type_actual VARCHAR2(30);

  l_priority_id        NUMBER;
  l_priority_level     NUMBER;
  l_status_id          NUMBER := 0;
  l_title_len          NUMBER := 1990;
  l_work_item_status_valid_flag VARCHAR2(10);

--  l_status_update_user_id  NUMBER;
  l_work_item_status_id  NUMBER;

  l_msg_data          VARCHAR2(4000);

  l_ws_id1            NUMBER;
  l_ws_id2            NUMBER := null;
  l_association_ws_id NUMBER;
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_curr_ws_id        NUMBER;

  l_dist_st_based_on_parent IEU_UWQM_WS_ASSCT_PROPS.DIST_ST_BASED_ON_PARENT_FLAG%TYPE;
  l_distribution_status_id NUMBER;
  l_parent_dist_status  NUMBER;
  l_set_dist_id_flag VARCHAR2(5);
  l_parent_status_id  NUMBER;
  l_ws_id NUMBER;
  l_ctr NUMBER;
  l_msg_count  NUMBER;
  l_wr_item_list  IEU_WR_PUB.IEU_WR_ITEM_LIST;

  cursor c1(p_source_object_id IN NUMBER, p_source_object_type_code IN VARCHAR2) is
   select work_item_id, workitem_pk_id, workitem_obj_code
   from   ieu_uwqm_items
   where  source_object_id = p_source_object_id
   and    source_object_type_code = p_source_object_type_code
   and ( distribution_status_id = 0 or distribution_status_id = 1);

  -- Audit Log
l_action_key VARCHAR2(2000);
l_event_key VARCHAR2(2000);
l_module VARCHAR2(2000);
l_curr_ws_code VARCHAR2(2000);
l_application_id NUMBER;
l_ieu_comment_code1 VARCHAR2(2000);
l_ieu_comment_code2 VARCHAR2(2000);
l_ieu_comment_code3 VARCHAR2(2000);
l_ieu_comment_code4 VARCHAR2(2000);
l_ieu_comment_code5 VARCHAR2(2000);
l_workitem_comment_code1 VARCHAR2(2000);
l_workitem_comment_code2 VARCHAR2(2000);
l_workitem_comment_code3 VARCHAR2(2000);
l_workitem_comment_code4 VARCHAR2(2000);
l_workitem_comment_code5 VARCHAR2(2000);
l_ws_code1 VARCHAR2(50);
l_ws_code2 VARCHAR2(50);
l_assct_ws_code VARCHAR2(50);
L_LOG_DIST_FROM VARCHAR(100);
L_LOG_DIST_TO VARCHAR2(100);
l_return_status VARCHAR2(10);
l_audit_trail_rec SYSTEM.WR_AUDIT_TRAIL_NST;
l_prev_source_object_id NUMBER;
l_prev_source_object_type_code VARCHAR2(30);

l_audit_log_val VARCHAR2(100);
l_audit_log_id NUMBER;


BEGIN

      l_token_str := '';
      SAVEPOINT insert_wr_items_sp;
      l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      -- Check for NOT NULL columns

      IF ((p_workitem_obj_code = FND_API.G_MISS_CHAR)  or
        (p_workitem_obj_code is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || ' WORKITEM_OBJECT_CODE  ';
      END IF;
      IF ((p_workitem_pk_id = FND_API.G_MISS_NUM) or
         (p_workitem_pk_id is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORKITEM_PK_ID  ';
      END IF;
      IF ((p_work_item_number = FND_API.G_MISS_CHAR) or
         (p_work_item_number is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORK_ITEM_NUMBER  ';
      END IF;
      IF ((p_title = FND_API.G_MISS_CHAR) or
         (p_title is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  TITLE ';
      END IF;
      IF ((p_priority_code = FND_API.G_MISS_CHAR) or
         (p_priority_code is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  PRIORITY_CODE  ';
      END IF;
      IF ((p_work_item_status = FND_API.G_MISS_CHAR) or
         (p_work_item_status is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORK_ITEM_STATUS  ';
      END IF;
      IF ((p_ieu_enum_type_uuid = FND_API.G_MISS_CHAR) or
         (p_ieu_enum_type_uuid is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  ENUM_TYPE_UUID  ';
      END IF;
      IF ((p_application_id = FND_API.G_MISS_NUM) or
         (p_application_id is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  APPLICATION_ID ';
      END IF;
      IF ((p_user_id = FND_API.G_MISS_NUM) or
         (p_user_id is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  USER_ID ';
      END IF;

      If (l_miss_param_flag = 1)
      THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;

      -- Validate object Code, owner_id, owner_type, assignee_id, assignee_type

      IF (p_workitem_obj_code is not null)
      THEN

         l_token_str := '';

         BEGIN
          SELECT object_code, object_function
          INTO   l_workitem_obj_code, l_object_function
          FROM   jtf_objects_b
          WHERE  object_code = p_workitem_obj_code;
         EXCEPTION
         WHEN no_data_found THEN
          null;
         END;

         IF (l_workitem_obj_code is null)
         THEN

           l_param_valid_flag := 1;
           l_token_str := ' WORKITEM_OBJ_CODE : '||p_workitem_obj_code;

         END IF;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      IF (p_priority_code is not null)
      THEN

         l_token_str := '';

         BEGIN

             SELECT priority_id, priority_level
             INTO   l_priority_id, l_priority_level
             FROM   ieu_uwqm_priorities_b
             WHERE  priority_code = p_priority_code;

         EXCEPTION
         WHEN no_data_found THEN

             l_param_valid_flag := 1;
             l_token_str := 'PRIORITY_CODE : '||p_priority_code ;

         END;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      -- Validate Work Item Status

      IF (p_work_item_status = 'OPEN') OR
         (p_work_item_status = 'CLOSE') OR
         (p_work_item_status = 'DELETE') OR
            (p_work_item_status = 'SLEEP')
      THEN
            l_work_item_status_valid_flag := 'T';
      ELSE
            l_work_item_status_valid_flag := 'F';
            l_token_str := ' WORK_ITEM_STATUS : '||p_work_item_status;
      END IF;

      IF (l_work_item_status_valid_flag = 'F')
      THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

      END IF;


      IF (length(p_title) > l_title_len)
      THEN


            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_PARAM_EXCEED_MAX');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('IEU_UWQ_PARAM_MAX',' TITLE ');
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

      END IF;

      -- If OWNER_TYPE or ASSIGNEE_TYPE is not RS_GROUP then set it to RS_INDIVIDUAL

      IF ( (p_owner_type <> 'RS_GROUP')
           AND (p_owner_type <> 'RS_TEAM') )
      THEN

         l_owner_type:= 'RS_INDIVIDUAL';
         l_owner_type_actual := p_owner_type;

      else

         l_owner_type := p_owner_type;
         l_owner_type_actual := p_owner_type;

      END IF;

      IF ( (p_assignee_type <> 'RS_GROUP')
           AND (p_assignee_type <> 'RS_TEAM') )
      THEN

         l_assignee_type := 'RS_INDIVIDUAL';
         l_assignee_type_actual := p_assignee_type;

      else

         l_assignee_type := p_assignee_type;
         l_assignee_type_actual := p_assignee_type;

      END IF;

      if ( (p_owner_type is not null) and (p_owner_id is null)) OR
         ( (p_assignee_type is not null) and (p_assignee_id is null) )
      then
	  l_token_str := '';
	  l_token_str2 := '';
	  FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_OWN_OR_ASG_ID_NULL');
	  FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
          if ( (p_owner_id is null) and (p_owner_type is not null) OR
	       (p_owner_id is not null) and (p_owner_type is null) )
	  then
	    l_token_str := ' OWNER_ID';
	    l_token_str2 := 'OWNER_TYPE - '||p_owner_type;
          end if;

          if ( (p_assignee_id is null) and (p_assignee_type is not null) OR
	       (p_assignee_id is not null) and (p_assignee_type is null) )
	  then
	    if (l_token_str is not null)
	    then
	        l_token_str := l_token_str ||', ASSIGNEE_ID';
	    else
	        l_token_str := ' ASSIGNEE_ID';
	    end if;
	    if (l_token_str2 is not null)
	    then
	        l_token_str2 := l_token_str2 ||  ', ASSINGEE_TYPE - '||p_assignee_type;
	    else
	        l_token_str2 :=  ' ASSINGEE_TYPE - '||p_assignee_type;
	    end if;
          end if;
	  FND_MESSAGE.SET_TOKEN('ID_PARAM',l_token_str);
	  FND_MESSAGE.SET_TOKEN('TYPE_PARAM',l_token_str2);
	  fnd_msg_pub.ADD;
	  fnd_msg_pub.Count_and_Get
	    (
	       p_count   =>   x_msg_count,
	       p_data    =>   x_msg_data
	    );

	  RAISE fnd_api.g_exc_error;
       end if;

      -- Check Source_Object_type_code, Source_Object_id
/*
      IF (p_source_object_type_code is null)
      THEN
          l_source_object_type_code := p_workitem_obj_code;
      ELSE
          l_source_object_type_code := p_source_object_type_code;
      END IF;

      IF (p_source_object_id is null)
      THEN
         l_source_object_id := p_workitem_pk_id;
      ELSE
         l_source_object_id := p_source_object_id;
      END IF;
*/

      -- Set Work Item Status Id

      IF (p_work_item_status is not null)
      THEN
         IF (p_work_item_status = 'OPEN')
         THEN
             l_work_item_status_id := 0;
         ELSIF (p_work_item_status = 'CLOSE')
         THEN
             l_work_item_status_id := 3;
         ELSIF (p_work_item_status = 'DELETE')
         THEN
             l_work_item_status_id := 4;
         ELSIF (p_work_item_status = 'SLEEP')
         THEN
            l_work_item_status_id := 5;
         END IF;
      END IF;


     -- Set the Distribution states based on Business Rules

     -- Get the Work_source_id

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_id , ws_code
       into   l_ws_id1, l_ws_code1
       from   ieu_uwqm_work_sources_b
       where  object_code = p_workitem_obj_code
--       and    nvl(not_valid_flag,'N') = 'N';
       and    nvl(not_valid_flag,'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'OBJECT_CODE: '||p_workitem_obj_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;

     if (p_source_object_type_code is not null)
     then

       BEGIN
         l_not_valid_flag := 'N';
         Select ws_id , ws_code
         into   l_ws_id2, l_ws_code2
         from   ieu_uwqm_work_sources_b
         where  object_code = p_source_object_type_code
--         and    nvl(not_valid_flag,'N') = 'N';
         and    nvl(not_valid_flag,'N') = l_not_valid_flag;

       EXCEPTION
        WHEN OTHERS THEN

         l_ws_id2 := null;
       END;

     end if;

     if (l_ws_id2 is not null)
     then

        -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
        BEGIN
                   l_not_valid_flag := 'N';
                   SELECT a.ws_id, b.ws_code
                   INTO   l_association_ws_id, l_assct_ws_code
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
                   AND    a.ws_id = b.ws_id
--                   AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_association_ws_id := null;
        END;

      else
            l_association_ws_id := null;

      end if;

      -- Get the Distribute_from, Distribute_to

      if (l_association_ws_id is not null)
      then

         l_curr_ws_id := l_association_ws_id;
	 l_curr_ws_code := l_assct_ws_code;

         BEGIN
           l_not_valid_flag := 'N';
           SELECT  ws_a_props.dist_st_based_on_parent_flag
           INTO   l_dist_st_based_on_parent
           FROM   ieu_uwqm_work_sources_b ws_b, IEU_UWQM_WS_ASSCT_PROPS ws_a_props
           WHERE  ws_b.ws_id = l_association_ws_id
           AND    ws_b.ws_id = ws_a_props.ws_id
--           AND    nvl(ws_b.not_valid_flag,'N') = 'N';
           AND    nvl(ws_b.not_valid_flag,'N') = l_not_valid_flag;

         EXCEPTION
           WHEN OTHERS THEN
            -- Work Source Details does not exist for this Object Code
            l_token_str := '';
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
         END;
         l_dist_from := 'GROUP_OWNED';
         l_dist_to := 'INDIVIDUAL_ASSIGNED';

      else
         l_dist_from := 'GROUP_OWNED';
         l_dist_to := 'INDIVIDUAL_ASSIGNED';

         l_curr_ws_id := l_ws_id1;
	 l_curr_ws_code := l_ws_code1;
/*
         BEGIN

           SELECT distribute_from, distribute_to
           INTO   l_dist_from, l_dist_to
           FROM   ieu_uwqm_work_sources_b
           WHERE  ws_id = l_ws_id1;

         EXCEPTION
           WHEN OTHERS THEN
            -- Work Source Details does not exist for this Object Code
            l_token_str := '';
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
         END;
*/
      end if;

      -- Set Distribution Status based on these rules

      -- If the Distribution State is based on the Parent, then check if the parent is distributed.

      if (l_dist_st_based_on_parent = 'Y')
      then
          BEGIN
              SELECT distribution_status_id, status_id
              INTO   l_parent_dist_status, l_parent_status_id
              FROM   ieu_uwqm_items
              WHERE  workitem_pk_id = p_source_object_id
              AND    workitem_obj_code = p_source_object_type_code;
          EXCEPTION
           WHEN OTHERS THEN
              l_parent_dist_status := null;
          END;
      end if;

      -- If the parent is not distributed, then this item will be in "On-Hold/Unavailable" status
      -- else set the status based on distribute_from and distribute_to

     if (l_parent_status_id = 3)
     then

            l_set_dist_id_flag  :=    'T';

     else

          if   (l_parent_dist_status  <> 3)
          then

                l_distribution_status_id := 0;

           else

                l_set_dist_id_flag := 'T';

           end if; /* parent_dist_status */

     end if; /* l_parent_status_id */

     if (l_set_dist_id_flag = 'T')
     then

            if (l_parent_dist_status <> 3)
            then

                    l_distribution_status_id := 0;

            else
                  if (l_dist_from = 'GROUP_OWNED') and
                          (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                    then

                          if (l_owner_type  = 'RS_GROUP') and
                             ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;
                   end if;
 /*
                     if (l_dist_from = 'GROUP_OWNED') and
                        (l_dist_to = 'INDIVIDUAL_OWNED')
                     then

                           if (l_owner_type  = 'RS_GROUP')
                           then
                                l_distribution_status_id := 1;
                           elsif (l_owner_type  = 'RS_INDIVIDUAL')
                           then
                                l_distribution_status_id := 3;
                           else
                                l_distribution_status_id := 0;
                           end if;

                    elsif (l_dist_from = 'GROUP_OWNED') and
                          (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                    then

                          if (l_owner_type  = 'RS_GROUP') and
                             ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_OWNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP') and
                             ( (l_owner_type is null) OR (l_owner_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_owner_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP')
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                  end if;
*/
          end if; /* l_parent_dist_status */

      end if; /* l_set_dist_id_flag */

      -- Get the values of App Distribute From and To for Audit Logging
      if (l_audit_log_val = 'DETAILED')
      then
         BEGIN

           SELECT distribute_from, distribute_to
           INTO   l_log_dist_from, l_log_dist_to
           FROM   ieu_uwqm_work_sources_b
           WHERE  ws_id = l_curr_ws_id;

         EXCEPTION
           WHEN OTHERS THEN
               NULL;
	 END;

         l_ieu_comment_code1 := null;
	 l_ieu_comment_code2 := null;
         l_ieu_comment_code3 := null;
         l_ieu_comment_code4 := null;
         l_ieu_comment_code5 := null;

	 /******************************* Used only for Distribute **************************
	 if (l_log_dist_from = 'GROUP_OWNED') and
		(l_log_dist_to = 'INDIVIDUAL_OWNED')
	 then
		l_ieu_comment_code1 := 'GO_IO';
	 elsif (l_log_dist_from = 'GROUP_OWNED') and
		  (l_log_dist_to = 'INDIVIDUAL_ASSIGNED')
	 then
		l_ieu_comment_code1 := 'GO_IA';
	 elsif (l_log_dist_from = 'GROUP_ASSIGNED') and
		 (l_log_dist_to = 'INDIVIDUAL_OWNED')
	 then
		l_ieu_comment_code1 := 'GA_IO';
	 elsif (l_log_dist_from = 'GROUP_ASSIGNED') and
		 (l_log_dist_to = 'INDIVIDUAL_ASSIGNED')
	 then
		l_ieu_comment_code1 := 'GA_IA';
	 end if; *******************/ /* ieu comment code1 */

         if (l_dist_st_based_on_parent = 'Y')
         then
             if (l_parent_dist_status = 0) and (l_parent_status_id = 0)
	     then
	         l_ieu_comment_code2 := 'ON_HOLD_OPEN';
             elsif (l_parent_dist_status = 0) and (l_parent_status_id = 3)
	     then
	         l_ieu_comment_code2 := 'ON_HOLD_CLOSED';
             elsif (l_parent_dist_status = 0) and (l_parent_status_id = 5)
	     then
	         l_ieu_comment_code2 := 'ON_HOLD_SLEEP';
             elsif (l_parent_dist_status = 1) and (l_parent_status_id = 0)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTABLE_OPEN';
             elsif (l_parent_dist_status = 1) and (l_parent_status_id = 3)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTABLE_CLOSED';
             elsif (l_parent_dist_status = 1) and (l_parent_status_id = 5)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTABLE_SLEEP';
             elsif (l_parent_dist_status = 3) and (l_parent_status_id = 0)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTED_OPEN';
             elsif (l_parent_dist_status = 3) and (l_parent_status_id = 3)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTED_CLOSED';
             elsif (l_parent_dist_status = 3) and (l_parent_status_id = 5)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTED_SLEEP';
	     end if; /* ieu comment code 2 */
	  end if; /* dist st based on parent */

      end if; /* Audit Log Val */

      IEU_WR_ITEMS_PKG.INSERT_ROW
       ( p_workitem_obj_code,
         p_workitem_pk_id,
         p_work_item_number,
         p_title,
         p_party_id,
         l_priority_id,
         l_priority_level,
         p_due_date,
         l_work_item_status_id,
         p_owner_id,
         l_owner_type,
         p_assignee_id,
         l_assignee_type,
         l_owner_type_actual,
         l_assignee_type_actual,
         p_source_object_id,
         p_source_object_type_code,
         p_application_id,
         p_ieu_enum_type_uuid,
         p_user_id,
         p_login_id,
         l_curr_ws_id,
         l_distribution_status_id,
         x_work_item_id,
         l_msg_data,
         x_return_status
       );

     -- Insert values to Audit Log

     if p_audit_trail_rec.count > 0
     then
      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
      loop
        l_action_key := p_audit_trail_rec(n).action_key;
	l_event_key := p_audit_trail_rec(n).event_key;
	l_module := p_audit_trail_rec(n).module;
        if (l_audit_log_val = 'DETAILED')
	then
		l_workitem_comment_code1 := p_audit_trail_rec(n).workitem_comment_code1;
		l_workitem_comment_code2 := p_audit_trail_rec(n).workitem_comment_code2;
		l_workitem_comment_code3 := p_audit_trail_rec(n).workitem_comment_code3;
		l_workitem_comment_code4 := p_audit_trail_rec(n).workitem_comment_code4;
		l_workitem_comment_code5 := p_audit_trail_rec(n).workitem_comment_code5;
	else
		l_workitem_comment_code1 := null;
		l_workitem_comment_code2 := null;
		l_workitem_comment_code3 := null;
		l_workitem_comment_code4 := null;
		l_workitem_comment_code5 := null;
        end if; /* Audit log Val */
      end loop;
     end if; /* p_audit_trail_rec */


     -- Audit Logging should be done only if the Profile Option Value is Full or Detailed
     -- However, during the actual Work Item Creation, if the Apps are not integrated,
     -- the actions cannot be logged. Hence we will be conditionally logging for
     -- Profile Option Value - Minimal. In this case, the Event value will be Null.

     if (l_action_key is NULL)
     then
       l_action_key := 'WORKITEM_CREATION';
     end if;

     if (l_audit_log_val = 'MINIMAL')
     then
       l_event_key := null;
     elsif ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
     then
       if (l_event_key is NULL)
       then
          l_event_key := 'CREATE_WR_ITEM';
       end if;
     end if;


     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_CREATION')) )
     then

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => null,
		P_WORK_ITEM_STATUS_CURR	=> l_work_item_status_id,
		P_OWNER_ID_PREV	 => null,
		P_OWNER_ID_CURR	=> p_owner_id,
		P_OWNER_TYPE_PREV => null,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => null,
		P_ASSIGNEE_ID_CURR => p_assignee_id,
		P_ASSIGNEE_TYPE_PREV => null,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => null,
		P_SOURCE_OBJECT_ID_CURR => p_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => null,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => p_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => null,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => null,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => null,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => null,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> null,
		P_DUE_DATE_CURR	=> p_due_date,
		P_RESCHEDULE_TIME_PREV => null,
		P_RESCHEDULE_TIME_CURR => sysdate,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);

      end if;
      --dbms_output.put_line('insert audit rec..ret sts: '||x_return_status);
      IF (x_return_status = fnd_api.g_ret_sts_success)
      THEN

          -- Set the Distribution Status of Child Work Items which are on-hold
          -- If it is a primary Work Source with Dependent Items
              if (l_association_ws_id is null)
              then
                   BEGIN
                        l_not_valid_flag := 'N';
                        select a.ws_id
                        into   l_ws_id
                        from   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                        where  (parent_ws_id =  l_curr_ws_id)
                        and   a.ws_id = b.ws_id
--                        and   nvl(b.not_valid_flag, 'N') = 'N';
                        and   nvl(b.not_valid_flag, 'N') = l_not_valid_flag;
                  EXCEPTION
                       WHEN OTHERS THEN
                              l_ws_id := null;
                 END;

                if (l_ws_id is not null)
                then

                          l_ctr := 0;
                         for cur_rec in c1(p_workitem_pk_id, p_workitem_obj_code)
                         loop
                                l_wr_item_list(l_ctr).work_item_id := cur_rec.work_item_id;
                                l_wr_item_list(l_ctr).workitem_pk_id := cur_rec.workitem_pk_id;
                                l_wr_item_list(l_ctr).workitem_obj_code := cur_rec.workitem_obj_code;
				l_wr_item_list(l_ctr).prev_parent_dist_status_id := null;
				l_wr_item_list(l_ctr).prev_parent_workitem_status_id := null;
                                l_ctr := l_ctr + 1;
                          end loop;

                         if ( l_wr_item_list.count > 0)
                         then

				 l_event_key := null;
	                         l_audit_trail_rec := SYSTEM.WR_AUDIT_TRAIL_NST();
				 l_audit_trail_rec.extend;
				 l_audit_trail_rec(l_audit_trail_rec.LAST) := SYSTEM.WR_AUDIT_TRAIL_OBJ
									(l_action_key,
									l_event_key,
									p_application_id,
									'IEU_WR_PUB.CREATE_WR_ITEM',
									null,
									null,
									null,
									null,
									null);

                                 IEU_WR_PUB.SYNC_DEPENDENT_WR_ITEMS
                                 ( p_api_version    => 1,
                                    p_init_msg_list  => 'T',
                                    p_commit         => 'F',
                                    p_wr_item_list   => l_wr_item_list,
				    p_audit_trail_rec => l_audit_trail_rec,
                                    x_msg_count      => l_msg_count,
                                    x_msg_data       => l_msg_data,
                                    x_return_status  => x_return_status);

                                   if (x_return_status <> 'S')
                                   then
                                            x_return_status := fnd_api.g_ret_sts_error;
                                            l_token_str := l_msg_data;

                                             FND_MESSAGE.SET_NAME('IEU', 'IEU_CREATE_WR_ITEM_FAILED');
                                             FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
                                             FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

                                             fnd_msg_pub.ADD;
                                             fnd_msg_pub.Count_and_Get
                                             (
                                                       p_count   =>   x_msg_count,
                                                       p_data    =>   x_msg_data
                                             );

                                            RAISE fnd_api.g_exc_error;
                                   end if; /* x_return_status */
                           end if; /*  l_wr_item_list.count */

                     end if; /*l_ws_code is not null */

                end if; /* association_ws_id is null */

      ELSIF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

	 x_return_status := fnd_api.g_ret_sts_error;
         l_token_str := l_msg_data;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_CREATE_WR_ITEM_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;

      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END IF;


EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO insert_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_CREATION')) )
  then

	     if (l_action_key is NULL)
	     then
	       l_action_key := 'WORKITEM_CREATION';
	     end if;

	     if (l_audit_log_val = 'MINIMAL')
	     then
	       l_event_key := null;
	     elsif ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
	     then
	       l_event_key := 'CREATE_WR_ITEM';
	     end if;
	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => null,
		P_WORK_ITEM_STATUS_CURR	=> l_work_item_status_id,
		P_OWNER_ID_PREV	 => null,
		P_OWNER_ID_CURR	=> p_owner_id,
		P_OWNER_TYPE_PREV => null,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => null,
		P_ASSIGNEE_ID_CURR => p_assignee_id,
		P_ASSIGNEE_TYPE_PREV => null,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => null,
		P_SOURCE_OBJECT_ID_CURR => p_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => null,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => p_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => null,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => null,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => null,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => null,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> null,
		P_DUE_DATE_CURR	=> p_due_date,
		P_RESCHEDULE_TIME_PREV => null,
		P_RESCHEDULE_TIME_CURR => sysdate,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => x_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status); commit;
  end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO insert_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_CREATION')) )
  then

	     if (l_action_key is NULL)
	     then
	       l_action_key := 'WORKITEM_CREATION';
	     end if;

	     if (l_audit_log_val = 'MINIMAL')
	     then
	       l_event_key := null;
	     elsif ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
	     then
	       l_event_key := 'CREATE_WR_ITEM';
	     end if;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => null,
		P_WORK_ITEM_STATUS_CURR	=> l_work_item_status_id,
		P_OWNER_ID_PREV	 => null,
		P_OWNER_ID_CURR	=> p_owner_id,
		P_OWNER_TYPE_PREV => null,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => null,
		P_ASSIGNEE_ID_CURR => p_assignee_id,
		P_ASSIGNEE_TYPE_PREV => null,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => null,
		P_SOURCE_OBJECT_ID_CURR => p_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => null,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => p_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => null,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => null,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => null,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => null,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> null,
		P_DUE_DATE_CURR	=> p_due_date,
		P_RESCHEDULE_TIME_PREV => null,
		P_RESCHEDULE_TIME_CURR => sysdate,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => x_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status); commit;
  end if;
  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK TO insert_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_CREATION')) )
  then
	     if (l_action_key is NULL)
	     then
	       l_action_key := 'WORKITEM_CREATION';
	     end if;

	     if (l_audit_log_val = 'MINIMAL')
	     then
	       l_event_key := null;
	     elsif ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
	     then
	       l_event_key := 'CREATE_WR_ITEM';
	     end if;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => null,
		P_WORK_ITEM_STATUS_CURR	=> l_work_item_status_id,
		P_OWNER_ID_PREV	 => null,
		P_OWNER_ID_CURR	=> p_owner_id,
		P_OWNER_TYPE_PREV => null,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => null,
		P_ASSIGNEE_ID_CURR => p_assignee_id,
		P_ASSIGNEE_TYPE_PREV => null,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => null,
		P_SOURCE_OBJECT_ID_CURR => p_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => null,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => p_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => null,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => null,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => null,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => null,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> null,
		P_DUE_DATE_CURR	=> p_due_date,
		P_RESCHEDULE_TIME_PREV => null,
		P_RESCHEDULE_TIME_CURR => sysdate,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => x_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status); commit;
  end if;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END CREATE_WR_ITEM;

PROCEDURE UPDATE_WR_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_title                           IN VARCHAR2 DEFAULT NULL,
  p_party_id                        IN NUMBER,
  p_priority_code             IN VARCHAR2 DEFAULT NULL,
  p_due_date                  IN DATE,
  p_owner_id                  IN NUMBER   DEFAULT NULL,
  p_owner_type                IN VARCHAR2 DEFAULT NULL,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER   DEFAULT NULL,
  p_work_item_status          IN VARCHAR2 DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_msg_count                 OUT NOCOPY  NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version  NUMBER        := 1.0;
  l_api_name     VARCHAR2(30);

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_token_str2          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_owner_id           NUMBER;
  l_assignee_id        NUMBER;
  l_owner_type         VARCHAR2(25);
  l_assignee_type      VARCHAR2(25);
  l_priority_id        NUMBER;
  l_priority_level     NUMBER;
  l_status_id          NUMBER := 0;
  l_title_len          NUMBER := 1990;
  l_work_item_status_id NUMBER;
  l_work_item_status_valid_flag VARCHAR2(10);

  l_source_object_type_code VARCHAR2(30);
  l_source_object_id   NUMBER;

  l_owner_type_actual  VARCHAR2(30);
  l_assignee_type_actual VARCHAR2(30);

  l_msg_data           VARCHAR2(4000);

  l_ws_id1            NUMBER;
  l_ws_id2            NUMBER;
  l_association_ws_id NUMBER;
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_curr_ws_id        NUMBER;

  l_dist_st_based_on_parent IEU_UWQM_WS_ASSCT_PROPS.DIST_ST_BASED_ON_PARENT_FLAG%TYPE;
  l_distribution_status_id NUMBER;
  l_parent_dist_status  NUMBER;
  l_set_dist_id_flag VARCHAR2(5);
  l_parent_status_id  NUMBER;
  l_ws_id NUMBER;
  l_ctr NUMBER;
  l_msg_count  NUMBER;
  l_wr_item_list  IEU_WR_PUB.IEU_WR_ITEM_LIST;

  cursor c1(p_source_object_id IN NUMBER, p_source_object_type_code IN VARCHAR2) is
   select work_item_id, workitem_pk_id, workitem_obj_code
   from   ieu_uwqm_items
   where  source_object_id = p_source_object_id
   and    source_object_type_code = p_source_object_type_code
   and ( distribution_status_id = 0 or distribution_status_id = 1);

  m_title                            VARCHAR2(1990);
  m_party_id                         NUMBER;
  m_priority_code              VARCHAR2(30);
  m_due_date                   DATE;
  m_owner_id                   NUMBER;
  m_owner_type                 VARCHAR2(25);
  m_assignee_id                NUMBER;
  m_assignee_type              VARCHAR2(25);
  m_source_object_id           NUMBER;
  m_source_object_type_code    VARCHAR2(30);
  m_application_id             NUMBER;
  m_work_item_status           VARCHAR2(30);


  -- Audit Log
l_action_key VARCHAR2(2000);
l_event_key VARCHAR2(2000);
l_module VARCHAR2(2000);
l_curr_ws_code VARCHAR2(2000);
l_application_id NUMBER;
l_prev_status_id NUMBER;
l_prev_owner_id NUMBER;
l_prev_owner_type VARCHAR2(2000);
l_prev_assignee_id NUMBER;
l_prev_assignee_type VARCHAR2(2000);
l_prev_distribution_status_id NUMBER;
l_prev_priority_id NUMBER;
l_prev_due_date DATE;
l_prev_reschedule_time DATE;
l_ieu_comment_code1 VARCHAR2(2000);
l_ieu_comment_code2 VARCHAR2(2000);
l_ieu_comment_code3 VARCHAR2(2000);
l_ieu_comment_code4 VARCHAR2(2000);
l_ieu_comment_code5 VARCHAR2(2000);
l_workitem_comment_code1 VARCHAR2(2000);
l_workitem_comment_code2 VARCHAR2(2000);
l_workitem_comment_code3 VARCHAR2(2000);
l_workitem_comment_code4 VARCHAR2(2000);
l_workitem_comment_code5 VARCHAR2(2000);

l_ws_code1 VARCHAR2(50);
l_ws_code2 VARCHAR2(50);
l_assct_ws_code VARCHAR2(50);
L_LOG_DIST_FROM VARCHAR(100);
L_LOG_DIST_TO VARCHAR2(100);
l_return_status VARCHAR2(10);

l_audit_trail_rec  SYSTEM.WR_AUDIT_TRAIL_NST;
l_prev_source_object_id NUMBER;
l_prev_source_object_type_code VARCHAR2(30);
l_audit_log_id NUMBER;

BEGIN

  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  l_api_name  := 'UPDATE_WR_ITEM';
  l_token_str := '';
      SAVEPOINT update_wr_items_sp;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      -- Check for NOT NULL columns

      IF (p_workitem_obj_code is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORKITEM_OBJECT_CODE  ';
      END IF;
      IF (p_workitem_pk_id is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORKITEM_PK_ID  ';
      END IF;
      IF (p_priority_code is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  PRIORITY_CODE  ';
      END IF;
      IF (p_work_item_status is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORK_ITEM_STATUS  ';
      END IF;
      IF (p_application_id is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  APPLICATION_ID ';
      END IF;
      IF (p_title is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  TITLE ';
      END IF;
      IF (p_user_id is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  USER_ID ';
      END IF;

      If (l_miss_param_flag = 1)
      THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;

      ---- validate if FND_API.G_MISS is passed
/*******************
       BEGIN

	      select decode(p_title, FND_API.G_MISS_CHAR, title, p_title) title,
		     decode(p_party_id, FND_API.G_MISS_NUM, party_id, p_party_id) party_id,
		     decode(p_due_date, FND_API.G_MISS_DATE, due_date, p_due_date) due_date,
		     decode(p_owner_id, FND_API.G_MISS_NUM, owner_id, p_owner_id) owner_id,
		     decode(p_owner_type, FND_API.G_MISS_CHAR, owner_type_actual, p_owner_type) owner_type_actual,
		     decode(p_assignee_id, FND_API.G_MISS_NUM, assignee_id, p_assignee_id) assignee_id,
		     decode(p_assignee_type, FND_API.G_MISS_CHAR, assignee_type_actual, p_assignee_type) assignee_type_actual,
		     decode(p_source_object_id, FND_API.G_MISS_NUM, source_object_id, p_source_object_id) source_object_id,
		     decode(p_source_object_type_code, FND_API.G_MISS_CHAR, source_object_type_code, p_source_object_type_code) source_object_type_code,
		     decode(p_application_id, FND_API.G_MISS_NUM, application_id, p_application_id) application_id
	       into  m_title,
		     m_party_id,
		     m_due_date,
		     m_owner_id,
		     m_owner_type,
		     m_assignee_id,
		     m_assignee_type,
		     m_source_object_id,
		     m_source_object_type_code,
		     m_application_id
	       from ieu_uwqm_items
	       where workitem_obj_code = p_workitem_obj_code
		 and workitem_pk_id = p_workitem_pk_id;
       EXCEPTION
        WHEN OTHERS THEN

            l_token_str := 'TITLE, PARTY_ID, DUE_DATE, OWNER_ID, OWNER_TYPE, ';
	    l_token_str := l_token_str || 'ASSIGNEE_ID, APPLICATION_ID, SOURCE_OBJECT_ID, SOURCE_OBJ_TYPE';

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

       END;

********************/

 /**** Modified this code due to performance reasons ********/
       BEGIN
	      select title,
		     party_id,
		     due_date,
		     owner_id,
		     owner_type_actual,
		     assignee_id,
		     assignee_type_actual,
		     source_object_id,
		     source_object_type_code,
		     application_id
	       into  m_title,
		     m_party_id,
		     m_due_date,
		     m_owner_id,
		     m_owner_type,
		     m_assignee_id,
		     m_assignee_type,
		     m_source_object_id,
		     m_source_object_type_code,
		     m_application_id
	       from ieu_uwqm_items
	       where workitem_obj_code = p_workitem_obj_code
		 and workitem_pk_id = p_workitem_pk_id;

       EXCEPTION WHEN OTHERS THEN
            l_token_str := 'TITLE, PARTY_ID, DUE_DATE, OWNER_ID, OWNER_TYPE, ';
	    l_token_str := l_token_str || 'ASSIGNEE_ID, APPLICATION_ID, SOURCE_OBJECT_ID, SOURCE_OBJ_TYPE';

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
       END;

 --     insert into p_temp(msg) values('b4 asg: '||p_assignee_id||' '||p_assignee_type);

      IF ((p_title <> FND_API.G_MISS_CHAR))
      THEN
		m_title := p_title;
      END IF;
      IF ((nvl(p_party_id, -9999) <> FND_API.G_MISS_NUM) )
      THEN
        m_party_id := p_party_id;
      END IF;
      IF ((nvl(p_due_date, sysdate) <> FND_API.G_MISS_DATE) )
      THEN
        m_due_date := p_due_date;
      END IF;
      IF ((nvl(p_owner_id, -9999) <> FND_API.G_MISS_NUM ))
      THEN
	m_owner_id := p_owner_id;
      END IF;
      IF ((nvl(p_owner_type, 'NULL') <> FND_API.G_MISS_CHAR ))
      then
 	m_owner_type := p_owner_type;
      END IF;
      IF ( (nvl( p_assignee_id, -9999)  <> FND_API.G_MISS_NUM ))
      THEN
	m_assignee_id := p_assignee_id;
      END IF;
      IF ( (nvl(p_assignee_type, 'NULL') <> FND_API.G_MISS_CHAR ))
      THEN
	m_assignee_type := p_assignee_type;
      END IF;
      IF ((p_application_id <> FND_API.G_MISS_NUM) )
      THEN
	m_application_id := p_application_id;
      END IF;
      IF ((nvl(p_source_object_id, -9999) <> FND_API.G_MISS_NUM) )
      THEN
        m_source_object_id := p_source_object_id;
      END IF;
      IF ((nvl(p_source_object_type_code, 'NULL') <> FND_API.G_MISS_CHAR) )
      THEN
	m_source_object_type_code := p_source_object_type_code;
      END IF;
--      insert into p_temp(msg) values('after asg: '||p_assignee_id||' '||p_assignee_type||
 --     'm val: '||m_assignee_id||' '||m_assignee_type);


       BEGIN
		select decode(p_priority_code, FND_API.G_MISS_CHAR, b.priority_code, p_priority_code) priority_code
		into m_priority_code
		from ieu_uwqm_items a, ieu_uwqm_priorities_b b
		where a.priority_id = b.priority_id
		  and a.priority_level = b.priority_level
		  and a.workitem_obj_code = p_workitem_obj_code
		  and a.workitem_pk_id = p_workitem_pk_id;
       EXCEPTION
        WHEN OTHERS THEN

           l_token_str := 'PRIORITY_CODE : '||p_priority_code;

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

       END;

       BEGIN

	       select decode(p_work_item_status, FND_API.G_MISS_CHAR, decode(status_id, 0, 'OPEN', 3, 'CLOSE', 4, 'DELETE', 5, 'SLEEP'), p_work_item_status) status_id
	       into m_work_item_status
	       from ieu_uwqm_items
	       where workitem_obj_code = p_workitem_obj_code
		 and workitem_pk_id = p_workitem_pk_id;
       EXCEPTION
        WHEN OTHERS THEN
           l_token_str := 'WORK_ITEM_STATUS : '||p_work_item_status;

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;



       END;


    --------  end of FND_API.G_MISS changes


      -- Validate object Code

      IF (p_workitem_obj_code is not NULL)
      THEN

         l_token_str := '';

         BEGIN
          SELECT 1
          INTO   l_workitem_obj_code
          FROM   jtf_objects_b
          WHERE  object_code = p_workitem_obj_code;
         EXCEPTION
         WHEN no_data_found THEN
          null;
         END;

         IF (l_workitem_obj_code is null)
         THEN

           l_param_valid_flag := 1;
           l_token_str := 'WORKITEM_OBJ_CODE : '||p_workitem_obj_code;

         END IF;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      IF (m_priority_code is NOT NULL)
      THEN

         l_token_str := '';

         BEGIN

             SELECT priority_id, priority_level
             INTO   l_priority_id, l_priority_level
             FROM   ieu_uwqm_priorities_b
             WHERE  priority_code = m_priority_code;

         EXCEPTION
         WHEN no_data_found THEN

             l_param_valid_flag := 1;
             l_token_str := l_token_str || 'PRIORITY_CODE : '||m_priority_code;

         END;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      IF (m_work_item_status = 'OPEN') OR
         (m_work_item_status = 'CLOSE') OR
         (m_work_item_status = 'DELETE') OR
            (m_work_item_status = 'SLEEP')
      THEN
            l_work_item_status_valid_flag := 'T';
      ELSE
            l_work_item_status_valid_flag := 'F';
            l_token_str := ' WORK_ITEM_STATUS : '||m_work_item_status;
      END IF;

      IF (l_work_item_status_valid_flag = 'F')
      THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

      END IF;

      IF (length(m_title) > l_title_len)
      THEN


            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_PARAM_EXCEED_MAX');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('IEU_UWQ_PARAM_MAX',' TITLE ');
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

      END IF;

      -- If OWNER_TYPE or ASSIGNEE_TYPE is not RS_GROUP then set it to RS_INDIVIDUAL

      IF ( (m_owner_type <> 'RS_GROUP')
           AND (m_owner_type <> 'RS_TEAM') )
      THEN

         l_owner_type:= 'RS_INDIVIDUAL';
         l_owner_type_actual := m_owner_type;

      else

         l_owner_type := m_owner_type;
         l_owner_type_actual := m_owner_type;

      END IF;

      IF ( (m_assignee_type <> 'RS_GROUP')
           AND (m_assignee_type <> 'RS_TEAM') )
      THEN

         l_assignee_type := 'RS_INDIVIDUAL';
         l_assignee_type_actual := m_assignee_type;

      else

         l_assignee_type := m_assignee_type;
         l_assignee_type_actual := m_assignee_type;

      END IF;

      if ( (m_owner_type is not null) and (m_owner_id is null)) OR
         ( (m_assignee_type is not null) and (m_assignee_id is null) )
      then
	  l_token_str := '';
	  l_token_str2 := '';
	  FND_MESSAGE.SET_NAME('IEU', 'IEU_WR_OWN_OR_ASG_ID_NULL');
	  FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
          if ( (m_owner_id is null) and (m_owner_type is not null) OR
	       (m_owner_id is not null) and (m_owner_type is null) )
	  then
	    l_token_str := ' OWNER_ID';
	    l_token_str2 := 'OWNER_TYPE - '||m_owner_type;
          end if;
          if ( (m_assignee_id is null) and (m_assignee_type is not null) OR
	       (m_assignee_id is not null) and (m_assignee_type is null) )
	  then
	    if (l_token_str is not null)
	    then
	        l_token_str := l_token_str ||', ASSIGNEE_ID';
	    else
	        l_token_str := ' ASSIGNEE_ID';
	    end if;
	    if (l_token_str2 is not null)
	    then
	        l_token_str2 := l_token_str2 ||  ', ASSINGEE_TYPE - '||m_assignee_type;
	    else
	        l_token_str2 :=  ' ASSINGEE_TYPE - '||m_assignee_type;
	    end if;
          end if;
	  FND_MESSAGE.SET_TOKEN('ID_PARAM',l_token_str);
	  FND_MESSAGE.SET_TOKEN('TYPE_PARAM',l_token_str2);
	  fnd_msg_pub.ADD;
	  fnd_msg_pub.Count_and_Get
	    (
	       p_count   =>   x_msg_count,
	       p_data    =>   x_msg_data
	    );

	  RAISE fnd_api.g_exc_error;
       end if;
      -- Check Source_Object_type_code, Source_Object_id
/*
      IF (p_source_object_type_code is null)
      THEN
          l_source_object_type_code := p_workitem_obj_code;
      ELSE
          l_source_object_type_code := p_source_object_type_code;
      END IF;

      IF (p_source_object_id is null)
      THEN
         l_source_object_id := p_workitem_pk_id;
      ELSE
         l_source_object_id := p_source_object_id;
      END IF;
*/
      -- Set Work Item Status Id

      IF (m_work_item_status is not null)
      THEN
         IF (m_work_item_status = 'OPEN')
         THEN
             l_work_item_status_id := 0;
         ELSIF (m_work_item_status = 'CLOSE')
         THEN
             l_work_item_status_id := 3;
         ELSIF (m_work_item_status = 'DELETE')
         THEN
             l_work_item_status_id := 4;
         ELSIF (m_work_item_status = 'SLEEP')
        THEN
            l_work_item_status_id := 5;

         END IF;
      END IF;

     -- Set the Distribution states based on Business Rules

     -- Get the Work_source_id

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_id, ws_code
       into   l_ws_id1, l_ws_code1
       from   ieu_uwqm_work_sources_b
       where  object_code = p_workitem_obj_code
--       and    nvl(not_valid_flag,'N') = 'N';
       and    nvl(not_valid_flag,'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'OBJECT_CODE:' ||p_workitem_obj_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;

     if (m_source_object_type_code is not null)
     then

       BEGIN
         l_not_valid_flag := 'N';
         Select ws_id, ws_code
         into   l_ws_id2, l_ws_code2
         from   ieu_uwqm_work_sources_b
         where  object_code = m_source_object_type_code
--         and    nvl(not_valid_flag,'N') = 'N';
         and    nvl(not_valid_flag,'N') = l_not_valid_flag;

       EXCEPTION
        WHEN OTHERS THEN

         l_ws_id2 := null;
       END;

     end if;

     if (l_ws_id2 is not null)
     then

        -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code
        BEGIN
                   l_not_valid_flag := 'N';
                   SELECT a.ws_id, b.ws_code
                   INTO   l_association_ws_id, l_assct_ws_code
                   FROM   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                   WHERE  child_ws_id = l_ws_id1
                   AND    parent_ws_id = l_ws_id2
                   AND    a.ws_id = b.ws_id
--                   AND    nvl(b.not_valid_flag,'N') = 'N';
                   AND    nvl(b.not_valid_flag,'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_association_ws_id := null;
        END;

      else
            l_association_ws_id := null;

      end if;

      -- Get the Distribute_from, Distribute_to

      if (l_association_ws_id is not null)
      then

         l_curr_ws_id := l_association_ws_id;
	 l_curr_ws_code := l_assct_ws_code;

         BEGIN
           l_not_valid_flag := 'N';
           SELECT ws_a_props.dist_st_based_on_parent_flag
           INTO   l_dist_st_based_on_parent
           FROM   ieu_uwqm_work_sources_b ws_b, IEU_UWQM_WS_ASSCT_PROPS ws_a_props
           WHERE  ws_b.ws_id = l_association_ws_id
           AND    ws_b.ws_id = ws_a_props.ws_id
--           AND    nvl(ws_b.not_valid_flag, 'N') = 'N';
           AND    nvl(ws_b.not_valid_flag, 'N') = l_not_valid_flag;

         EXCEPTION
           WHEN OTHERS THEN
            -- Work Source does not exist for this Object Code
            l_token_str := 'OBJECT_CODE: '||p_workitem_obj_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
        END;
        l_dist_from := 'GROUP_OWNED';
        l_dist_to := 'INDIVIDUAL_ASSIGNED';
      else
        l_dist_from := 'GROUP_OWNED';
        l_dist_to := 'INDIVIDUAL_ASSIGNED';

         l_curr_ws_id := l_ws_id1;
	 l_curr_ws_code := l_ws_code1;
/*
         BEGIN

           SELECT distribute_from, distribute_to
           INTO   l_dist_from, l_dist_to
           FROM   ieu_uwqm_work_sources_b
           WHERE  ws_id = l_ws_id1;

         EXCEPTION
           WHEN OTHERS THEN
            -- Work Source does not exist for this Object Code
            l_token_str := 'OBJECT_CODE: '||p_workitem_obj_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.CREATE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;
         END;
*/
      end if;

      -- Set Distribution Status based on these rules

      -- If the Distribution State is based on the Parent, then check if the parent is distributed.

      if (l_dist_st_based_on_parent = 'Y')
      then
          BEGIN
              SELECT distribution_status_id, status_id
              INTO   l_parent_dist_status, l_parent_status_id
              FROM   ieu_uwqm_items
              WHERE  workitem_pk_id = m_source_object_id
              AND    workitem_obj_code = m_source_object_type_code;
          EXCEPTION
           WHEN OTHERS THEN
              l_parent_dist_status := null;
              l_parent_status_id := null;
          END;
      end if;

      -- If the parent is not distributed, then this item will be in "On-Hold/Unavailable" status
      -- else set the status based on distribute_from and distribute_to
     if (l_parent_status_id = 3)
     then

            l_set_dist_id_flag  :=    'T';

     else

          if   (l_parent_dist_status  <> 3)
          then

                l_distribution_status_id := 0;

           else

                l_set_dist_id_flag := 'T';

           end if; /* parent_dist_status */

     end if; /* l_parent_status_id */

     if (l_set_dist_id_flag = 'T')
     then

            if (l_parent_dist_status <> 3)
            then

                    l_distribution_status_id := 0;

            else
                if (l_dist_from = 'GROUP_OWNED') and
                   (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                then
                    if (l_owner_type  = 'RS_GROUP') and
                        ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                    then
                         l_distribution_status_id := 1;
                    elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                    then
                         l_distribution_status_id := 3;
                    else
                         l_distribution_status_id := 0;
                    end if;
                end if;

  /*                  if (l_dist_from = 'GROUP_OWNED') and
                        (l_dist_to = 'INDIVIDUAL_OWNED')
                     then

                           if (l_owner_type  = 'RS_GROUP')
                           then
                                l_distribution_status_id := 1;
                           elsif (l_owner_type  = 'RS_INDIVIDUAL')
                           then
                                l_distribution_status_id := 3;
                           else
                                l_distribution_status_id := 0;
                           end if;

                    elsif (l_dist_from = 'GROUP_OWNED') and
                          (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                    then

                          if (l_owner_type  = 'RS_GROUP') and
                             ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_OWNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP') and
                             ( (l_owner_type is null) OR (l_owner_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_owner_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP')
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                  end if;
*/
         end if; /* l_parent_dist_status */
      end if; /* l_set_dist_id_flag */

      -- Get the prev values for audit trail
     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL'))
     then

      	      BEGIN
		SELECT owner_id, owner_type, assignee_id, assignee_type, status_id,
		       priority_id, due_date, reschedule_time, distribution_status_id, source_object_id, source_object_type_code
		INTO   l_prev_owner_id, l_prev_owner_type, l_prev_assignee_id, l_prev_assignee_type, l_prev_status_id,
		       l_prev_priority_id, l_prev_due_date, l_prev_reschedule_time, l_prev_distribution_status_id,
		       l_prev_source_object_id, l_prev_source_object_type_code
		FROM IEU_UWQM_ITEMS
		WHERE  workitem_obj_code = p_workitem_obj_code
		AND    workitem_pk_id = p_workitem_pk_id;

	      EXCEPTION
	       WHEN OTHERS THEN
		    NULL;
	      END;
     end if;

     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
     then


	      -- Get the values of App Distribute From and To for Audit Logging
	      if (l_audit_log_val = 'DETAILED')
	      then
			 BEGIN

			   SELECT distribute_from, distribute_to
			   INTO   l_log_dist_from, l_log_dist_to
			   FROM   ieu_uwqm_work_sources_b
			   WHERE  ws_id = l_curr_ws_id;

			 EXCEPTION
			   WHEN OTHERS THEN
			       NULL;
			 END;

			 /*********************** Used only During Distribute ******************
			 l_ieu_comment_code1 := null;
			 l_ieu_comment_code2 := null;
			 l_ieu_comment_code3 := null;
			 l_ieu_comment_code4 := null;
			 l_ieu_comment_code5 := null;

			 if (l_log_dist_from = 'GROUP_OWNED') and
				(l_log_dist_to = 'INDIVIDUAL_OWNED')
			 then
				l_ieu_comment_code1 := 'GO_IO';
			 elsif (l_log_dist_from = 'GROUP_OWNED') and
				  (l_log_dist_to = 'INDIVIDUAL_ASSIGNED')
			 then
				l_ieu_comment_code1 := 'GO_IA';
			 elsif (l_log_dist_from = 'GROUP_ASSIGNED') and
				 (l_log_dist_to = 'INDIVIDUAL_OWNED')
			 then
				l_ieu_comment_code1 := 'GA_IO';
			 elsif (l_log_dist_from = 'GROUP_ASSIGNED') and
				 (l_log_dist_to = 'INDIVIDUAL_ASSIGNED')
			 then
				l_ieu_comment_code1 := 'GA_IA';
			 end if;
			 **********************************************************************/

			 if (l_dist_st_based_on_parent = 'Y')
			 then
			     if (l_parent_dist_status = 0) and (l_parent_status_id = 0)
			     then
				 l_ieu_comment_code2 := 'ON_HOLD_OPEN';
			     elsif (l_parent_dist_status = 0) and (l_parent_status_id = 3)
			     then
				 l_ieu_comment_code2 := 'ON_HOLD_CLOSED';
			     elsif (l_parent_dist_status = 0) and (l_parent_status_id = 5)
			     then
				 l_ieu_comment_code2 := 'ON_HOLD_SLEEP';
			     elsif (l_parent_dist_status = 1) and (l_parent_status_id = 0)
			     then
				 l_ieu_comment_code2 := 'DISTRIBUTABLE_OPEN';
			     elsif (l_parent_dist_status = 1) and (l_parent_status_id = 3)
			     then
				 l_ieu_comment_code2 := 'DISTRIBUTABLE_CLOSED';
			     elsif (l_parent_dist_status = 1) and (l_parent_status_id = 5)
			     then
				 l_ieu_comment_code2 := 'DISTRIBUTABLE_SLEEP';
			     elsif (l_parent_dist_status = 3) and (l_parent_status_id = 0)
			     then
				 l_ieu_comment_code2 := 'DISTRIBUTED_OPEN';
			     elsif (l_parent_dist_status = 3) and (l_parent_status_id = 3)
			     then
				 l_ieu_comment_code2 := 'DISTRIBUTED_CLOSED';
			     elsif (l_parent_dist_status = 3) and (l_parent_status_id = 5)
			     then
				 l_ieu_comment_code2 := 'DISTRIBUTED_SLEEP';
			     end if;
			  end if;

	      end if;
      end if;/* Full or Detailed */

      IEU_WR_ITEMS_PKG.UPDATE_ROW
       ( p_workitem_obj_code,
         p_workitem_pk_id,
         m_title,
         m_party_id,
         l_priority_id,
         l_priority_level,
         m_due_date,
         m_owner_id,
         l_owner_type,
         m_assignee_id,
         l_assignee_type,
         l_owner_type_actual,
         l_assignee_type_actual,
         m_source_object_id,
         m_source_object_type_code,
         m_application_id,
         l_work_item_status_id,
         p_user_id,
         p_login_id,
         l_curr_ws_id,
         l_distribution_status_id,
         l_msg_data,
         x_return_status
        );

     -- Insert values to Audit Log

     if p_audit_trail_rec.count > 0
     then
      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
      loop
        l_action_key := p_audit_trail_rec(n).action_key;
	l_event_key := p_audit_trail_rec(n).event_key;
	l_module := p_audit_trail_rec(n).module;
        if (l_audit_log_val = 'DETAILED')
	then
		l_workitem_comment_code1 := p_audit_trail_rec(n).workitem_comment_code1;
		l_workitem_comment_code2 := p_audit_trail_rec(n).workitem_comment_code2;
		l_workitem_comment_code3 := p_audit_trail_rec(n).workitem_comment_code3;
		l_workitem_comment_code4 := p_audit_trail_rec(n).workitem_comment_code4;
		l_workitem_comment_code5 := p_audit_trail_rec(n).workitem_comment_code5;
	else
		l_workitem_comment_code1 := null;
		l_workitem_comment_code2 := null;
		l_workitem_comment_code3 := null;
		l_workitem_comment_code4 := null;
		l_workitem_comment_code5 := null;
        end if;
      end loop;
     end if;


     -- Audit Logging should be done only if the Profile Option Value is Full or Detailed
     -- However, during the actual Work Item Creation, if the Apps are not integrated,
     -- the actions cannot be logged. Hence we will be conditionally logging for
     -- Profile Option Value - Minimal. In this case, the Event value will be Null.

     if (l_action_key is NULL)
     then
       l_action_key := 'WORKITEM_UPDATE';
     end if;

     if (l_audit_log_val = 'MINIMAL')
     then
       l_event_key := null;
     end if;

     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
     then
     /**
       dbms_output.put_line('prev asg: '||l_prev_assignee_type||'curr asg: '||l_assignee_type);
       dbms_output.put_line('prev asgid: '||l_prev_assignee_id||'curr asgid: '||m_assignee_id);
       dbms_output.put_line('prev owner: '||l_prev_owner_type||'curr own: '||l_owner_type);
       dbms_output.put_line('prev ownid: '||l_prev_owner_id||'curr ownid: '||m_owner_id);
      **/
       -- Requeue
       if (l_owner_type = 'RS_GROUP')
       then
	       if (l_prev_owner_type <> 'RS_GROUP')  and  (l_owner_type = 'RS_GROUP') and
	          (l_assignee_type is null)
	       then
		    l_event_key := 'REQUEUE';
		    --dbms_output.put_line('requeue');
	       elsif ( (l_prev_owner_type = 'RS_GROUP') and (l_owner_type = 'RS_GROUP') and
	             (l_assignee_type is null) and  (l_prev_owner_id <> m_owner_id))
	       then
			--  dbms_output.put_line('asg types are grp');
			  --if (l_prev_owner_id <> m_owner_id)
--			  then
			     l_event_key := 'REQUEUE';
			     --dbms_output.put_line('requeue');
--			  end if;
		elsif (l_prev_assignee_type is not null)  and  (l_assignee_type is null)
		then
			     l_event_key := 'REQUEUE';
		--	     dbms_output.put_line('requeue');
	/*	else
		       if (l_event_key is NULL)
		       then
			 l_event_key := 'UPDATE_WR_ITEM';
		       end if;
	     */  end if;
       end if; /* requeue */
       -- Reassign
       if ( (l_prev_assignee_type = 'RS_INDIVIDUAL') and (l_assignee_type = 'RS_INDIVIDUAL') )
       then
        --  dbms_output.put_line('asg types are ind');
          if (l_prev_assignee_id <> m_assignee_id)
	  then
               l_event_key := 'REASSIGN';
	  end if;
	      -- dbms_output.put_line('reasg');
       end if;

       if (l_event_key is NULL)
       then
              l_event_key := 'UPDATE_WR_ITEM';
       end if;
       --end if;
     end if;


     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_UPDATE')) )
     then

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_work_item_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> m_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => m_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => m_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => m_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> m_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_prev_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);

      end if;
      -- dbms_output.put_line('ret sts: '||x_return_status);
      IF (x_return_status = fnd_api.g_ret_sts_success)
      THEN

          -- Set the Distribution Status of Child Work Items which are on-hold
          -- If it is a primary Work Source with Dependent Items

              if (l_association_ws_id is null)
              then

                     BEGIN
                          l_not_valid_flag := 'N';
                          select a.ws_id
                          into   l_ws_id
                          from   ieu_uwqm_ws_assct_props a, ieu_uwqm_work_sources_b b
                          where  (parent_ws_id =  l_curr_ws_id)
                          and   a.ws_id = b.ws_id
--                          and   nvl(b.not_valid_flag, 'N') = 'N';
                          and   nvl(b.not_valid_flag, 'N') = l_not_valid_flag;
                     EXCEPTION
                         WHEN OTHERS THEN
                                l_ws_id  := null;
                     END;

                     if (l_ws_id  is not null)
                     then

                           l_ctr := 0;
                           for cur_rec in c1(p_workitem_pk_id, p_workitem_obj_code)
                           loop
                                  l_wr_item_list(l_ctr).work_item_id := cur_rec.work_item_id;
                                  l_wr_item_list(l_ctr).workitem_pk_id := cur_rec.workitem_pk_id;
                                  l_wr_item_list(l_ctr).workitem_obj_code := cur_rec.workitem_obj_code;
  				  l_wr_item_list(l_ctr).prev_parent_dist_status_id := l_prev_distribution_status_id;
				  l_wr_item_list(l_ctr).prev_parent_workitem_status_id := l_prev_status_id;

                                  l_ctr := l_ctr + 1;
				  --dbms_output.put_line('pk id: '||cur_rec.work_item_id);

                            end loop;

                           if ( l_wr_item_list.count > 0)
                           then
	                           l_audit_trail_rec := SYSTEM.WR_AUDIT_TRAIL_NST();
				   l_audit_trail_rec.extend;

				    if p_audit_trail_rec.count > 0
				    then
				      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
				      loop
					l_action_key := p_audit_trail_rec(n).action_key;
				      end loop;
				   end if;

				   if (l_action_key is null)
				   then
					 l_action_key := 'WORKITEM_UPDATE';
				   end if;
				   l_event_key := null;
				   --dbms_output.put_line('audit trail rec..act key:'||l_action_key||' app id: '||p_application_id);
				   BEGIN
					   l_audit_trail_rec(l_audit_trail_rec.LAST) := SYSTEM.WR_AUDIT_TRAIL_OBJ
										(l_action_key,
										 l_event_key,
										p_application_id,
										'IEU_WR_PUB.UPDATE_WR_ITEM',
										null,
										null,
										null,
										null,
										null);
				   EXCEPTION
				     WHEN OTHERS THEN
				   --dbms_output.put_line('err: '||SQLERRM||' '||SQLCODE);
				   null;
				   END;

                                   IEU_WR_PUB.SYNC_DEPENDENT_WR_ITEMS
                                   ( p_api_version    => 1,
                                      p_init_msg_list  => 'T',
                                      p_commit         => 'F',
                                      p_wr_item_list   => l_wr_item_list,
				      p_audit_trail_rec => l_audit_trail_rec,
                                      x_msg_count      => l_msg_count,
                                      x_msg_data       => l_msg_data,
                                      x_return_status  => x_return_status);
			             --dbms_output.put_line('ret sts from sync: '||x_return_status);
                                     if (x_return_status <> 'S')
                                     then
                                              x_return_status := fnd_api.g_ret_sts_error;
                                              l_token_str := l_msg_data;

                                               FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_WR_ITEM_FAILED');
                                               FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
                                               FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

                                               fnd_msg_pub.ADD;
                                               fnd_msg_pub.Count_and_Get
                                               (
                                                         p_count   =>   x_msg_count,
                                                         p_data    =>   x_msg_data
                                               );

                                              RAISE fnd_api.g_exc_error;
                                     end if;
                             end if;

                       end if; /*l_ws_id is not null */

                else

		   x_return_status := fnd_api.g_ret_sts_success;

                end if; /* association_ws_id is null */

      ELSIF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;
         l_token_str := l_msg_data;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_WR_ITEM_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;


      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END iF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO update_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_CREATION')) )
  then

	     if (l_action_key is NULL)
	     then
	       l_action_key := 'WORKITEM_UPDATE';
	     end if;

	     if (l_audit_log_val = 'MINIMAL')
	     then
	       l_event_key := null;
	     elsif ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
	     then
	       l_event_key := 'UPDATE_WR_ITEM';
	     end if;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_work_item_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> m_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => m_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => m_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => m_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> m_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_prev_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => x_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);
		commit;

  end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO update_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_CREATION')) )
  then

	     if (l_action_key is NULL)
	     then
	       l_action_key := 'WORKITEM_UPDATE';
	     end if;

	     if (l_audit_log_val = 'MINIMAL')
	     then
	       l_event_key := null;
	     elsif ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
	     then
	       l_event_key := 'UPDATE_WR_ITEM';
	     end if;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_work_item_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> m_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => m_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => m_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => m_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> m_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_prev_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => x_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);
		commit;

  end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK TO update_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_CREATION')) )
  then

	     if (l_action_key is NULL)
	     then
	       l_action_key := 'WORKITEM_UPDATE';
	     end if;

	     if (l_audit_log_val = 'MINIMAL')
	     then
	       l_event_key := null;
	     elsif ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
	     then
	       l_event_key := 'UPDATE_WR_ITEM';
	     end if;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_work_item_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> m_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => m_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => m_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => m_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> m_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_prev_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => x_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);
		commit;

  end if;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END UPDATE_WR_ITEM;

PROCEDURE RESCHEDULE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_work_item_id              IN NUMBER   DEFAULT NULL,
  p_reschedule_time           IN DATE     DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
--  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2) AS

  l_api_version  CONSTANT NUMBER        := 1.0;
  l_api_name     CONSTANT VARCHAR2(30)  := 'RESCHEDULE_UWQM_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_work_item_id       NUMBER;
  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_status_id          NUMBER := 0;

  l_old_status_update_user_id NUMBER;
  l_new_status_update_user_id NUMBER;

  l_miss_workitem_id_flag   NUMBER(1) := 0;
  l_miss_workitem_obj_code_flag NUMBER(1) := 0;

    -- Audit Log
l_action_key VARCHAR2(2000);
l_event_key VARCHAR2(2000);
l_module VARCHAR2(2000);
l_curr_ws_code VARCHAR2(2000);
l_application_id NUMBER;
l_prev_status_id NUMBER;
l_prev_owner_id NUMBER;
l_prev_owner_type VARCHAR2(2000);
l_prev_assignee_id NUMBER;
l_prev_assignee_type VARCHAR2(2000);
l_prev_distribution_status_id NUMBER;
l_prev_priority_id NUMBER;
l_prev_due_date DATE;
l_prev_reschedule_time DATE;
l_ieu_comment_code1 VARCHAR2(2000);
l_ieu_comment_code2 VARCHAR2(2000);
l_ieu_comment_code3 VARCHAR2(2000);
l_ieu_comment_code4 VARCHAR2(2000);
l_ieu_comment_code5 VARCHAR2(2000);
l_workitem_comment_code1 VARCHAR2(2000);
l_workitem_comment_code2 VARCHAR2(2000);
l_workitem_comment_code3 VARCHAR2(2000);
l_workitem_comment_code4 VARCHAR2(2000);
l_workitem_comment_code5 VARCHAR2(2000);
l_msg_data VARCHAR2(4000);
l_return_status VARCHAR2(10);

l_parent_status_id NUMBER;
l_parent_dist_status NUMBER;
l_distribution_status_id NUMBER;

l_ws_code1 VARCHAR2(50);
l_ws_code2 VARCHAR2(50);
l_assct_ws_code VARCHAR2(50);
L_LOG_DIST_FROM VARCHAR(100);
L_LOG_DIST_TO VARCHAR2(100);
l_prev_source_object_id NUMBER;
l_prev_source_object_type_code VARCHAR2(30);

l_ws_code VARCHAR2(50);
l_ws_id NUMBER;
l_audit_log_id NUMBER;

l_obj_code VARCHAR2(50);
l_workitem_pk_id NUMBER;

BEGIN

      l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
      l_token_str := '';

      SAVEPOINT reschedule_uwqm_items_sp;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      -- Check for NOT NULL columns

      IF ( p_work_item_id is null)
      THEN
--          l_miss_param_flag := 1;
          l_miss_workitem_id_flag := 1;
          l_token_str := l_token_str || '  WORK_ITEM_ID  ';
      END IF;

      IF (l_miss_workitem_id_flag = 1)
      THEN
         IF (p_workitem_obj_code is null)
         THEN
             l_miss_workitem_obj_code_flag := 1;
             l_token_str := l_token_str || ' WORKITEM_OBJECT_CODE  ';
         END IF;
         IF (p_workitem_pk_id is null)
         THEN
             l_miss_workitem_obj_code_flag := 1;
             l_token_str := l_token_str || '  WORKITEM_PK_ID  ';
         END IF;
      END IF;


      IF ( (l_miss_workitem_obj_code_flag = 1) and
           (l_miss_workitem_id_flag = 1) )
      THEN
         l_miss_param_flag := 1;
      END IF;

      IF  (p_user_id is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  USER_ID ';
      END IF;

      IF (p_reschedule_time is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  START_TIME ';
      END IF;

      If (l_miss_param_flag = 1)
      THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_UWQM_PUB.RESCHEDULE_UWQM_ITEM');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;

      IF (l_miss_workitem_obj_code_flag <> 1)
      THEN

        BEGIN
          SELECT work_item_id
          INTO   l_work_item_id
          FROM   ieu_uwqm_items
          WHERE  workitem_obj_code = p_workitem_obj_code
          AND    workitem_pk_id    = p_workitem_pk_id;
        EXCEPTION WHEN NO_DATA_FOUND
        THEN
          NULL;
        END;

        IF (p_work_item_id <> l_work_item_id)
        THEN

          l_token_str :=' WORKITEM_ID :'||
                          p_work_item_id||' WORKITEM_PK_ID: '||p_workitem_pk_id||
                         ' WORKITEM_OBJ_CODE: '||p_workitem_obj_code;
          FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_COMBINATION');
          FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_UWQM_PUB.RESCHEDULE_UWQM_ITEM');
          FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
          fnd_msg_pub.ADD;
          fnd_msg_pub.Count_and_Get
          (
           p_count   =>   x_msg_count,
           p_data    =>   x_msg_data
          );

          x_return_status := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;

         END IF;

       END IF;

      -- Validate object Code, owner_id, owner_type, assignee_id, assignee_type

      IF (p_workitem_obj_code is not null)
      THEN

         l_token_str := '';

         BEGIN
          SELECT object_code, object_function
          INTO   l_workitem_obj_code, l_object_function
          FROM   jtf_objects_b
          WHERE  object_code = p_workitem_obj_code;
         EXCEPTION
         WHEN no_data_found THEN
          null;
         END;

         IF (l_workitem_obj_code is null)
         THEN

           l_param_valid_flag := 1;
           l_token_str := 'WORKITEM_OBJ_CODE : '||p_workitem_obj_code;

/*         ELSIF ( (l_workitem_obj_code = p_workitem_obj_code) and (l_object_FUNCTION is null))
         THEN

           l_param_valid_flag := 1;
           l_token_str := 'Object Function for Object Code : '||p_workitem_obj_code; */

         END IF;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_UWQM_PUB.RESCHEDULE_UWQM_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      -- Get the prev values for audit trail

      if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL'))
      then
        IF (p_work_item_id is not null) THEN
	      BEGIN
		SELECT ws_id, owner_id, owner_type, assignee_id, assignee_type, status_id,
		       priority_id, due_date, reschedule_time, distribution_status_id, source_object_id, source_object_type_code, workitem_pk_id, workitem_obj_code
		INTO   l_ws_id, l_prev_owner_id, l_prev_owner_type, l_prev_assignee_id, l_prev_assignee_type, l_prev_status_id,
		       l_prev_priority_id, l_prev_due_date, l_prev_reschedule_time, l_prev_distribution_status_id,
		       l_prev_source_object_id, l_prev_source_object_type_code, l_workitem_pk_id, l_obj_code
		FROM IEU_UWQM_ITEMS
		WHERE  WORK_ITEM_ID = P_WORK_ITEM_ID;

	      EXCEPTION
	       WHEN OTHERS THEN
		    NULL;
	      END;

        ELSE
	      BEGIN
		SELECT ws_id, owner_id, owner_type, assignee_id, assignee_type, status_id,
		       priority_id, due_date, reschedule_time, distribution_status_id, source_object_id, source_object_type_code
		INTO   l_ws_id, l_prev_owner_id, l_prev_owner_type, l_prev_assignee_id, l_prev_assignee_type, l_prev_status_id,
		       l_prev_priority_id, l_prev_due_date, l_prev_reschedule_time, l_prev_distribution_status_id,
		       l_prev_source_object_id, l_prev_source_object_type_code
		FROM IEU_UWQM_ITEMS
		WHERE  workitem_obj_code = p_workitem_obj_code
		AND    workitem_pk_id = p_workitem_pk_id;

	      EXCEPTION
	       WHEN OTHERS THEN
		    NULL;
	      END;
        END IF;
      end if;

      IF (p_work_item_id is not null)
      THEN

            UPDATE IEU_UWQM_ITEMS
            SET    reschedule_time = P_reschedule_time
            WHERE  WORK_ITEM_ID = P_WORK_ITEM_ID;

      ELSE

            UPDATE IEU_UWQM_ITEMS
            SET    reschedule_time = P_reschedule_time
            WHERE  WORKITEM_PK_ID = P_WORKITEM_PK_ID
            AND    WORKITEM_OBJ_CODE = P_WORKITEM_OBJ_CODE;

            l_workitem_pk_id := P_WORKITEM_PK_ID;
            l_obj_code := P_WORKITEM_OBJ_CODE;

      END IF;


     -- Audit Logging should be done only if the Profile Option Value is Minimal, Full or Detailed

     l_action_key := 'RESCHEDULE';
     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
     then
	     l_event_key := 'RESCHEDULE_WR_ITEM';
     else
	     l_event_key := null;
     end if;
--     l_module := 'IEU_WR_PUB.RESCEDULE_WR_ITEM';
     l_module := 'IEU_WR_PUB.SNOOZE_UWQM_ITEM';

     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
     then

             BEGIN

		select ws_code
		into   l_ws_code
		from   ieu_uwqm_work_sources_b
		where  ws_id = l_ws_id;

	     EXCEPTION
	       when others then
	         null;
             END;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_ws_code,
		P_APPLICATION_ID => 696,
--		P_WORKITEM_PK_ID => p_workitem_pk_id,
--		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_prev_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> l_prev_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_prev_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => l_prev_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_prev_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_prev_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_prev_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_prev_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_prev_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> l_prev_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => P_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => fnd_api.g_ret_sts_success,
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);

      end if;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;

         l_token_str := 'WORKITEM_OBJ_CODE : '||p_workitem_obj_code||
                        ' WORKITEM_PK_ID : '||p_workitem_pk_id;
         FND_MESSAGE.SET_NAME('IEU', 'IEU_SUSPEND_UWQM_ITEM_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_UWQM_PUB.RESCHEDULE_UWQM_ITEM');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;


      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END iF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO reschedule_uwqm_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then
     l_action_key := 'RESCHEDULE';
     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
     then
	     l_event_key := 'RESCHEDULE_WR_ITEM';
     else
	     l_event_key := null;
     end if;
--     l_module := 'IEU_WR_PUB.RESCEDULE_WR_ITEM';
     l_module := 'IEU_WR_PUB.SNOOZE_UWQM_ITEM';

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => 696,
--		P_WORKITEM_PK_ID => p_workitem_pk_id,
--		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
         	P_WORKITEM_OBJ_CODE => l_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_prev_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> l_prev_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_prev_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => l_prev_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_prev_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_prev_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_prev_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_prev_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> l_prev_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => P_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => x_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status); commit;

  end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO reschedule_uwqm_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then

     l_action_key := 'RESCHEDULE';
     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
     then
	     l_event_key := 'RESCHEDULE_WR_ITEM';
     else
	     l_event_key := null;
     end if;
--     l_module := 'IEU_WR_PUB.RESCEDULE_WR_ITEM';
     l_module := 'IEU_WR_PUB.SNOOZE_UWQM_ITEM';

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => 696,
--		P_WORKITEM_PK_ID => p_workitem_pk_id,
--		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_prev_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> l_prev_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_prev_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => l_prev_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_prev_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_prev_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_prev_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_prev_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> l_prev_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => P_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => x_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status); commit;

  end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN

  ROLLBACK TO reschedule_uwqm_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then

     l_action_key := 'RESCHEDULE';
     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
     then
	     l_event_key := 'RESCHEDULE_WR_ITEM';
     else
	     l_event_key := null;
     end if;
--     l_module := 'IEU_WR_PUB.RESCEDULE_WR_ITEM';
     l_module := 'IEU_WR_PUB.SNOOZE_UWQM_ITEM';

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => 696,
--		P_WORKITEM_PK_ID => p_workitem_pk_id,
--		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_prev_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> l_prev_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_prev_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => l_prev_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_prev_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_prev_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_prev_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_prev_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> l_prev_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => P_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => x_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status); commit;

  end if;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END RESCHEDULE_UWQM_ITEM;


PROCEDURE SYNC_WS_DETAILS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_msg_count                 OUT  NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'SYNC_WS_DETAILS';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_msg_data          VARCHAR2(4000);

  l_ws_id             NUMBER;
  l_parent_ws_id      NUMBER;
  l_child_ws_id       NUMBER;
  l_parent_obj_code   VARCHAR2(500);
  l_child_obj_code    VARCHAR2(500);
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_ws_type           VARCHAR2(500);
  l_obj_code          VARCHAR2(500);
  l_distribution_status_id NUMBER;
  l_parent_dist_status  NUMBER;
  l_dist_st_based_on_parent  VARCHAR2(5);
  l_parent_status_id NUMBER;
  l_set_dist_id_flag  VARCHAR2(5);

  l_tasks_rules_func varchar2(256);
  l_tasks_data_list  SYSTEM.WR_TASKS_DATA_NST;
  l_def_data_list    SYSTEM.DEF_WR_DATA_NST;
  l_uwqm_count       number;
  l_task_data_var    varchar2(20);
  l_msg_count      number;
  l_return_status  varchar2(1);

  l_task_id   number;
  l_task_number varchar2(30);
  l_customer_id number;
  l_owner_id  number;
  l_owner_type_code varchar2(30);
  l_source_object_id number;
  l_source_object_type_code varchar2(30);
  l_task_name varchar2(80);
  l_assignee_id  number;
  l_assignee_type varchar2(25);
  l_task_priority_id number;
  l_date_selected   varchar2(1);
  l_due_date      date;
  l_planned_end_date  date;
  l_actual_end_date   date;
  l_scheduled_end_date date;
  l_planned_start_date  date;
  l_actual_start_date   date;
  l_scheduled_start_date date;
  l_importance_level number;
  l_priority_code  varchar2(30);
  l_task_status varchar2(10);
  l_task_status_id  number;
  l_task_type_id number;


  -- Cursor for primary ws
  cursor c_pry_ws(p_obj_code in VARCHAR2) is
     select work_item_id, owner_type, assignee_type
     from   ieu_uwqm_items
     where  workitem_obj_code = p_obj_code;

  -- Cursor for association ws
  cursor c_assct_ws(p_parent_obj_code in VARCHAR2, p_child_obj_code in VARCHAR2) is
     select work_item_id, workitem_pk_id, workitem_obj_code, owner_id, owner_type, assignee_id, assignee_type, source_object_id, source_object_type_code,
            status_id, priority_id, due_date
     from   ieu_uwqm_items
     where  workitem_obj_code = p_child_obj_code
     and    source_object_type_code = p_parent_obj_code;

  cursor c_task(p_source_object_type_code in varchar2) is
   select tb.task_id, tb.task_number, tb.customer_id, tb.owner_id, tb.owner_type_code,
  tb.source_object_id, tb.source_object_type_code,
--  decode(tb.date_selected, 'P', tb.planned_end_date,
--         'A', tb.actual_end_date, 'S', tb.scheduled_end_date, null, tb.scheduled_end_date) due_date,
  tb.planned_start_date, tb.planned_end_date, tb.actual_start_date, tb.actual_end_date,
  tb.scheduled_start_date, tb.scheduled_end_date,tb.task_type_id,
  tb.task_status_id, tt.task_name, tp.importance_level, ip.priority_code, tb.task_priority_id
  from jtf_tasks_b tb, jtf_tasks_tl tt, jtf_task_priorities_vl tp, ieu_uwqm_priorities_b ip
  where tb.entity = 'TASK' and nvl(tb.deleted_flag, 'N') = 'N' and tb.task_id = tt.task_id
  and tt.language = userenv('LANG') and tp.task_priority_id = nvl(tb.task_priority_id, 4)
  and least(tp.importance_level, 4) = ip.priority_level
  and tb.open_flag = 'Y'
  and tb.source_object_type_code = p_source_object_type_code;

  -- Audit Log
l_action_key VARCHAR2(2000);
l_event_key VARCHAR2(2000);
l_module VARCHAR2(2000);
l_curr_ws_code VARCHAR2(2000);
l_application_id NUMBER;
l_prev_status_id NUMBER;
l_prev_owner_id NUMBER;
l_prev_owner_type VARCHAR2(2000);
l_prev_assignee_id NUMBER;
l_prev_assignee_type VARCHAR2(2000);
l_prev_distribution_status_id NUMBER;
l_prev_priority_id NUMBER;
l_prev_due_date DATE;
l_prev_reschedule_time DATE;
l_ieu_comment_code1 VARCHAR2(2000);
l_ieu_comment_code2 VARCHAR2(2000);
l_ieu_comment_code3 VARCHAR2(2000);
l_ieu_comment_code4 VARCHAR2(2000);
l_ieu_comment_code5 VARCHAR2(2000);
l_workitem_comment_code1 VARCHAR2(2000);
l_workitem_comment_code2 VARCHAR2(2000);
l_workitem_comment_code3 VARCHAR2(2000);
l_workitem_comment_code4 VARCHAR2(2000);
l_workitem_comment_code5 VARCHAR2(2000);

l_status_id NUMBER;
l_priority_id NUMBER;
l_reschedule_time DATE;

l_ws_code1 VARCHAR2(50);
l_ws_code2 VARCHAR2(50);
l_assct_ws_code VARCHAR2(50);

L_LOG_DIST_FROM VARCHAR(100);
L_LOG_DIST_TO VARCHAR2(100);
l_prev_source_object_id NUMBER;
l_prev_source_object_type_code VARCHAR2(30);
l_audit_log_id NUMBER;

  CURSOR c_task_status(p_source_object_type_code in varchar2) IS
   SELECT TASK_ID,
          DECODE(DELETED_FLAG, 'Y', 4, 3) "STATUS_ID"
   FROM JTF_TASKS_B
   WHERE SOURCE_OBJECT_TYPE_CODE = p_source_object_type_code
   AND ((OPEN_FLAG = 'N' AND DELETED_FLAG = 'N') OR (DELETED_FLAG = 'Y'))
   AND ENTITY = 'TASK';

  TYPE NUMBER_TBL   is TABLE OF NUMBER        INDEX BY BINARY_INTEGER;

  TYPE status_rec is RECORD
  (
	  l_task_id_list		NUMBER_TBL,
	  l_status_id_list		NUMBER_TBL
  );

  l_task_status_rec status_rec;

  l_array_size NUMBER;
  l_done       BOOLEAN;

  dml_errors EXCEPTION;
  PRAGMA exception_init(dml_errors, -24381);
  errors number;

BEGIN

  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  l_priority_code := 'LOW';
  l_token_str := '';
  l_dist_from := 'GROUP_OWNED';
  l_dist_to   := 'INDIVIDUAL_ASSIGNED';
  l_array_size := 2000;

      SAVEPOINT sync_ws_details_sp;

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;


     -- Set the Distribution states based on Business Rules

     -- Get the Work_source_id

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_id, ws_type, object_code
       into   l_ws_id, l_ws_type, l_obj_code
       from   ieu_uwqm_work_sources_b
       where  ws_code = p_ws_code
--       and nvl(not_valid_flag, 'N') = 'N';
       and nvl(not_valid_flag, 'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;

     if (l_ws_type = 'PRIMARY')
     then
            -- The Sync script works only for Association Work Source
            -- If a primary Work Source is passed then it will throw an exception and exit
            -- Work Source does not exist for this Object Code
            l_token_str := 'WORK_SOURCE:' ||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;


     elsif (l_ws_type = 'ASSOCIATION')
     then
        BEGIN

           SELECT parent_ws_id, child_ws_id, dist_st_based_on_parent_flag , tasks_rules_function
           INTO   l_parent_ws_id, l_child_ws_id, l_dist_st_based_on_parent , l_tasks_rules_func
           FROM   IEU_UWQM_WS_ASSCT_PROPS
           WHERE  ws_id = l_ws_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

        BEGIN
           l_not_valid_flag := 'N';
           SELECT object_code
           INTO   l_parent_obj_code
           FROM   IEU_UWQM_WORK_SOURCES_B
           WHERE  ws_id = l_parent_ws_id
--           and nvl(not_valid_flag, 'N') = 'N';
           and nvl(not_valid_flag, 'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

        BEGIN
           l_not_valid_flag := 'N';
           SELECT object_code
           INTO   l_child_obj_code
           FROM   IEU_UWQM_WORK_SOURCES_B
           WHERE  ws_id = l_child_ws_id
--           and nvl(not_valid_flag, 'N') = 'N';
           and nvl(not_valid_flag, 'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;


     end if;

   /******************** This is not used now *****************************

     if (l_ws_type = 'PRIMARY')
     then

         for cur_rec in c_pry_ws(l_obj_code)
         loop

            if (l_dist_from = 'GROUP_OWNED') and
               (l_dist_to = 'INDIVIDUAL_OWNED')
            then

               if (cur_rec.owner_type = 'RS_GROUP')
               then
                   l_distribution_status_id := 1;
               elsif (cur_rec.owner_type = 'RS_INDIVIDUAL')
               then
                   l_distribution_status_id := 3;
               else
                   l_distribution_status_id := 0;
               end if;

           elsif (l_dist_from = 'GROUP_OWNED') and
                 (l_dist_to = 'INDIVIDUAL_ASSIGNED')
           then

               if (cur_rec.owner_type = 'RS_GROUP') and
                  ( (cur_rec.assignee_type is null) OR (cur_rec.assignee_type <> 'RS_INDIVIDUAL') )
               then
                  l_distribution_status_id := 1;
               elsif (cur_rec.assignee_type    = 'RS_INDIVIDUAL')
               then
                  l_distribution_status_id := 3;
               else
                  l_distribution_status_id := 0;
               end if;

           elsif (l_dist_from = 'GROUP_ASSIGNED') and
                 (l_dist_to = 'INDIVIDUAL_OWNED')
           then

               if (cur_rec.assignee_type = 'RS_GROUP') and
                  ( (cur_rec.owner_type is null) OR (cur_rec.owner_type <> 'RS_INDIVIDUAL') )
               then
                  l_distribution_status_id := 1;
               elsif (cur_rec.owner_type= 'RS_INDIVIDUAL')
               then
                  l_distribution_status_id := 3;
               else
                  l_distribution_status_id := 0;
               end if;

           elsif (l_dist_from = 'GROUP_ASSIGNED') and
                 (l_dist_to = 'INDIVIDUAL_ASSIGNED')
           then

               if (cur_rec.assignee_type   = 'RS_GROUP')
               then
                  l_distribution_status_id := 1;
               elsif (cur_rec.assignee_type   = 'RS_INDIVIDUAL')
               then
                  l_distribution_status_id := 3;
               else
                  l_distribution_status_id := 0;
               end if;

           end if;

           update ieu_uwqm_items
           set    ws_id = l_ws_id,
                  distribution_status_id = l_distribution_status_id
           where work_item_id = cur_rec.work_item_id;
           commit;

         end loop;

      elsif (l_ws_type = 'ASSOCIATION')
    ********************************************************************/
      if (l_ws_type = 'ASSOCIATION')
      then

	  -- Audit Logging should be done only when the Profile Option Value is Minimal, Full or Detailed
	  -- This will be logged as an action

	  if p_audit_trail_rec.count > 0
	  then
	      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
	      loop
		l_action_key := p_audit_trail_rec(n).action_key;
		l_module := p_audit_trail_rec(n).module;
		if (l_audit_log_val = 'DETAILED')
		then
			l_workitem_comment_code1 := p_audit_trail_rec(n).workitem_comment_code1;
			l_workitem_comment_code2 := p_audit_trail_rec(n).workitem_comment_code2;
			l_workitem_comment_code3 := p_audit_trail_rec(n).workitem_comment_code3;
			l_workitem_comment_code4 := p_audit_trail_rec(n).workitem_comment_code4;
			l_workitem_comment_code5 := p_audit_trail_rec(n).workitem_comment_code5;
		else
			l_workitem_comment_code1 := null;
			l_workitem_comment_code2 := null;
			l_workitem_comment_code3 := null;
			l_workitem_comment_code4 := null;
			l_workitem_comment_code5 := null;
		end if;
	      end loop;
	  end if;

	  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
	  then

	      l_action_key := 'SYNC_ASSCT_WS';
	      l_event_key := null;
	      l_module := 'IEU_WR_PUB.SYNC_WS_DETAILS';

	      -- Get the values of App Distribute From and To for Audit Logging
	      if (l_audit_log_val = 'DETAILED')
	      then
	           if l_tasks_rules_func is not null
                   then
		      l_ieu_comment_code1 := 'TASKS_RULES_FUNC ' ||l_tasks_rules_func;
		   else
		      l_ieu_comment_code1 := 'SYNC_PROC - IEU_WR_ITEMS.SYNC_WS_DETAILS';
		   end if;
              end if;
	  end if;

         if l_tasks_rules_func is not null
         then
           open c_task(l_parent_obj_code);
           loop
              fetch c_task into l_task_id, l_task_number, l_customer_id, l_owner_id, l_owner_type_code,
              l_source_object_id, l_source_object_type_code,
            --l_due_date,
            l_planned_start_date,
              l_planned_end_date, l_actual_start_date, l_actual_end_date, l_scheduled_start_date, l_scheduled_end_date,
              l_task_type_id, l_task_status_id, l_task_name, l_importance_level, l_priority_code, l_task_priority_id;
              exit when c_task%notfound;

              begin
                select 'SLEEP' into l_task_status
                from jtf_task_statuses_vl
                where (nvl(on_hold_flag,'N') = 'Y')
                and task_status_id = l_task_status_id;
                EXCEPTION WHEN no_data_found
                THEN
                l_task_status := 'OPEN';
              end;

	      begin
	        select booking_end_date
		into   l_due_date
		from   jtf_task_all_assignments
		where  task_id = l_task_id
		and    assignee_role = 'OWNER';
	      exception when others then
		    -- Work Source does not exist for this Object Code
		    l_token_str := sqlcode||' '||sqlerrm;
		    fnd_msg_pub.ADD;
		    fnd_msg_pub.Count_and_Get
		    (
		       p_count   =>   x_msg_count,
		       p_data    =>   x_msg_data
		    );

		    RAISE fnd_api.g_exc_error;
	      end;

              begin
                 l_workitem_obj_code_1 := 'TASK';
                 select count(*) into l_uwqm_count
                 from ieu_uwqm_items
--                 where workitem_obj_code = 'TASK'
                 where workitem_obj_code = l_workitem_obj_code_1
                 and workitem_pk_id = l_task_id;
                 exception when others then
                 l_uwqm_count := 0;
              end;

              if l_uwqm_count = 0 then
                 l_task_data_var := 'CREATE_TASK';
              else
                 l_task_data_var := 'UPDATE_TASK';
              end if;

              l_tasks_data_list := SYSTEM.WR_TASKS_DATA_NST();

              l_tasks_data_list.extend;

              l_tasks_data_list(l_tasks_data_list.last) := SYSTEM.WR_TASKS_DATA_OBJ (
                                                     l_task_data_var,
                                                     l_task_id,
                                                      null,
                                                     l_task_number,
                                                     l_task_name,
                                                     l_task_type_id,
                                                     l_task_status_id,
                                                     l_task_priority_id,
                                                     l_owner_id,
                                                     l_owner_type_code,
                                                     l_source_object_id,
                                                     l_source_object_type_code,
                                                     l_customer_id,
                                                     l_date_selected,
                                                     l_planned_start_date,
                                                     l_planned_end_date,
                                                     l_scheduled_start_date,
                                                     l_scheduled_end_date,
                                                     l_actual_start_date,
                                                     l_actual_end_date,
                                                     null,
                                                     null,
                                                     null);

              l_def_data_list := SYSTEM.DEF_WR_DATA_NST();

              l_def_data_list.extend;


              l_def_data_list(l_def_data_list.last) := SYSTEM.DEF_WR_DATA_OBJ(
                                                l_task_status,
                                                l_priority_code,
                                                l_due_date,
                                                'TASKS',
                                                null
                                                 );

              execute immediate
              'BEGIN '||l_tasks_rules_func ||' ( :1, :2, :3, :4 , :5); END ; '
              USING IN l_tasks_data_list, IN l_def_data_list , OUT l_msg_count, OUT l_msg_data, OUT l_return_status;

	      if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
              then

	             BEGIN
			SELECT priority_id
			into   l_priority_id
			from   ieu_uwqm_priorities_b
			where  priority_code = l_priority_code;
		     EXCEPTION
		     when others then
		        null;
		     END;


		     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
		     (
			P_ACTION_KEY => l_action_key,
			P_EVENT_KEY =>	l_event_key,
			P_MODULE => l_module,
			P_WS_CODE => p_ws_code,
			P_APPLICATION_ID => 696,
			P_WORKITEM_PK_ID => l_task_id,
			P_WORKITEM_OBJ_CODE => 'TASK',
			P_WORK_ITEM_STATUS_PREV => null,
			P_WORK_ITEM_STATUS_CURR	=> l_task_status_id,
			P_OWNER_ID_PREV	 => null,
			P_OWNER_ID_CURR	=> l_owner_id,
			P_OWNER_TYPE_PREV => null,
			P_OWNER_TYPE_CURR => l_owner_type_code,
			P_ASSIGNEE_ID_PREV => null,
			P_ASSIGNEE_ID_CURR => null,
			P_ASSIGNEE_TYPE_PREV => null,
			P_ASSIGNEE_TYPE_CURR => null,
			P_SOURCE_OBJECT_ID_PREV => null,
			P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
			P_SOURCE_OBJECT_TYPE_CODE_PREV => null,
			P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
			P_PARENT_WORKITEM_STATUS_PREV => null,
			P_PARENT_WORKITEM_STATUS_CURR => null,
			P_PARENT_DIST_STATUS_PREV => null,
			P_PARENT_DIST_STATUS_CURR => null,
			P_WORKITEM_DIST_STATUS_PREV => null,
			P_WORKITEM_DIST_STATUS_CURR => null,
			P_PRIORITY_PREV => null,
			P_PRIORITY_CURR	=> l_priority_id,
			P_DUE_DATE_PREV	=> null,
			P_DUE_DATE_CURR	=> l_due_date,
			P_RESCHEDULE_TIME_PREV => sysdate,
			P_RESCHEDULE_TIME_CURR => sysdate,
			P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
			P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
			P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
			P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
			P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
			P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
			P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
			P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
			P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
			P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
			P_STATUS => l_return_status,
			P_ERROR_CODE => l_msg_data ,
			X_AUDIT_LOG_ID => l_audit_log_id,
			X_MSG_DATA => l_msg_data,
			X_RETURN_STATUS => l_return_status);


	       end if;

	   end loop;
	   close c_task;
         else

           for cur_rec in c_assct_ws(l_parent_obj_code, l_child_obj_code)
           loop

             if (l_dist_st_based_on_parent = 'Y')
             then
               BEGIN
                 SELECT distribution_status_id, status_id
                 INTO   l_parent_dist_status, l_parent_status_id
                 FROM   ieu_uwqm_items
                 WHERE  workitem_pk_id = cur_rec.source_object_id
                 AND    workitem_obj_code = cur_rec.source_object_type_code;
                 EXCEPTION
                 WHEN OTHERS THEN
                   l_parent_dist_status := null;
                END;
              end if;

          -- If the parent is not distributed, then this item will be in "On-Hold/Unavailable" status
          -- else set the status based on distribute_from and distribute_to

             if (l_parent_status_id = 3)
             then

                    l_set_dist_id_flag  :=    'T';

             else

                  if   (l_parent_dist_status  <> 3)
                  then

                        l_distribution_status_id := 0;

                   else

                        l_set_dist_id_flag := 'T';

                   end if; /* parent_dist_status */

             end if; /* l_parent_status_id */

             if (l_set_dist_id_flag = 'T')
             then

                 if (l_dist_from = 'GROUP_OWNED') and
                    (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                 then
                     if (cur_rec.owner_type  = 'RS_GROUP') and
                        ( (cur_rec.assignee_type  is null) OR (cur_rec.assignee_type  <> 'RS_INDIVIDUAL') )
                     then
                         l_distribution_status_id := 1;
                     elsif (cur_rec.assignee_type   = 'RS_INDIVIDUAL')
                     then
                         l_distribution_status_id := 3;
                     else
                         l_distribution_status_id := 0;
                     end if;
                  end if;

              /*       if (l_dist_from = 'GROUP_OWNED') and
                        (l_dist_to = 'INDIVIDUAL_OWNED')
                     then

                           if (cur_rec.owner_type  = 'RS_GROUP')
                           then
                                l_distribution_status_id := 1;
                           elsif (cur_rec.owner_type  = 'RS_INDIVIDUAL')
                           then
                                l_distribution_status_id := 3;
                           else
                                l_distribution_status_id := 0;
                           end if;

                    elsif (l_dist_from = 'GROUP_OWNED') and
                          (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                    then

                          if (cur_rec.owner_type  = 'RS_GROUP') and
                             ( (cur_rec.assignee_type  is null) OR (cur_rec.assignee_type  <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (cur_rec.assignee_type   = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_OWNED')
                   then

                          if (cur_rec.assignee_type   = 'RS_GROUP') and
                             ( (cur_rec.owner_type is null) OR (cur_rec.owner_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (cur_rec.owner_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                   then

                          if (cur_rec.assignee_type   = 'RS_GROUP')
                          then
                              l_distribution_status_id := 1;
                          elsif (cur_rec.assignee_type   = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                  end if;
            */

              end if; /* l_set_dist_id_flag */


              update ieu_uwqm_items
              set    ws_id = l_ws_id,
                  distribution_status_id = l_distribution_status_id
              where work_item_id = cur_rec.work_item_id;
              commit;

	      if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
              then


		     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
		     (
			P_ACTION_KEY => l_action_key,
			P_EVENT_KEY =>	l_event_key,
			P_MODULE => l_module,
			P_WS_CODE => p_ws_code,
			P_APPLICATION_ID => 696,
			P_WORKITEM_PK_ID => cur_rec.workitem_pk_id,
			P_WORKITEM_OBJ_CODE => cur_rec.workitem_obj_code,
			P_WORK_ITEM_STATUS_PREV => null,
			P_WORK_ITEM_STATUS_CURR	=> cur_rec.status_id,
			P_OWNER_ID_PREV	 => null,
			P_OWNER_ID_CURR	=> cur_rec.owner_id,
			P_OWNER_TYPE_PREV => null,
			P_OWNER_TYPE_CURR => cur_rec.owner_type,
			P_ASSIGNEE_ID_PREV => null,
			P_ASSIGNEE_ID_CURR => cur_rec.assignee_id,
			P_ASSIGNEE_TYPE_PREV => null,
			P_ASSIGNEE_TYPE_CURR => cur_rec.assignee_type,
			P_SOURCE_OBJECT_ID_PREV => null,
			P_SOURCE_OBJECT_ID_CURR => cur_rec.source_object_id,
			P_SOURCE_OBJECT_TYPE_CODE_PREV => null,
			P_SOURCE_OBJECT_TYPE_CODE_CURR => cur_rec.source_object_type_code,
			P_PARENT_WORKITEM_STATUS_PREV => null,
			P_PARENT_WORKITEM_STATUS_CURR => null,
			P_PARENT_DIST_STATUS_PREV => null,
			P_PARENT_DIST_STATUS_CURR => null,
			P_WORKITEM_DIST_STATUS_PREV => null,
			P_WORKITEM_DIST_STATUS_CURR => null,
			P_PRIORITY_PREV => null,
			P_PRIORITY_CURR	=> cur_rec.priority_id,
			P_DUE_DATE_PREV	=> null,
			P_DUE_DATE_CURR	=> cur_rec.due_date,
			P_RESCHEDULE_TIME_PREV => null,
			P_RESCHEDULE_TIME_CURR => sysdate,
			P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
			P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
			P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
			P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
			P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
			P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
			P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
			P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
			P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
			P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
			P_STATUS => l_return_status,
			P_ERROR_CODE => l_msg_data ,
			X_AUDIT_LOG_ID => l_audit_log_id,
			X_MSG_DATA => l_msg_data,
			X_RETURN_STATUS => l_return_status);

              end if;

           end loop; /* cur_rec */
         end if;

         -- Update Close and Delete Statuses

         open c_task_status(l_parent_obj_code);
	 loop

	     FETCH c_task_status
	     BULK COLLECT INTO
		  l_task_status_rec.l_task_id_list,
		  l_task_status_rec.l_status_id_list
             LIMIT l_array_size;

	     l_done := c_task_status%NOTFOUND;

	     BEGIN
	--	fnd_file.put_line(FND_FILE.LOG,'Begin update');
		     FORALL i in 1..l_task_status_rec.l_task_id_list.COUNT SAVE EXCEPTIONS
			update IEU_UWQM_ITEMS
			set	status_id = l_task_status_rec.l_status_id_list(i),
         			LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
	        		LAST_UPDATE_DATE       = SYSDATE,
		        	LAST_UPDATE_LOGIN      = FND_GLOBAL.LOGIN_ID
			where   workitem_obj_code = 'TASK'
                        and     workitem_pk_id = l_task_status_rec.l_task_id_list(i)
                        and     source_object_type_code = l_parent_obj_code;

	     EXCEPTION
		  WHEN dml_errors THEN
		   errors := SQL%BULK_EXCEPTIONS.COUNT;
		   FOR i IN 1..errors LOOP

                       fnd_file.new_line(FND_FILE.LOG, 1);
                       FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
                       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_WR_PUB.SYNC_WS_DETAILS');
                       FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_task_status_rec.l_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                      fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );
                    END LOOP;
                    RAISE fnd_api.g_exc_error;
	     END;

             l_task_status_rec.l_task_id_list.DELETE;
             l_task_status_rec.l_status_id_list.DELETE;

	     exit when (l_done);

	   end loop;

	   close c_task_status;

      end if;

      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END IF;


EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO sync_ws_details_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then

     l_action_key := 'SYNC_ASSCT_WS';
     l_event_key := null;
     l_module := 'IEU_WR_PUB.SYNC_WS_DETAILS';

     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
     (
	P_ACTION_KEY => l_action_key,
	P_EVENT_KEY =>	l_event_key,
	P_MODULE => l_module,
	P_WS_CODE => p_ws_code,
	P_APPLICATION_ID => 696,
	P_WORKITEM_PK_ID => null,
	P_WORKITEM_OBJ_CODE => null,
	P_WORK_ITEM_STATUS_PREV => null,
	P_WORK_ITEM_STATUS_CURR	=> null,
	P_OWNER_ID_PREV	 => null,
	P_OWNER_ID_CURR	=> null,
	P_OWNER_TYPE_PREV => null,
	P_OWNER_TYPE_CURR => null,
	P_ASSIGNEE_ID_PREV => null,
	P_ASSIGNEE_ID_CURR => null,
	P_ASSIGNEE_TYPE_PREV => null,
	P_ASSIGNEE_TYPE_CURR => null,
	P_SOURCE_OBJECT_ID_PREV => null,
	P_SOURCE_OBJECT_ID_CURR => null,
	P_SOURCE_OBJECT_TYPE_CODE_PREV => null,
	P_SOURCE_OBJECT_TYPE_CODE_CURR => null,
	P_PARENT_WORKITEM_STATUS_PREV => null,
	P_PARENT_WORKITEM_STATUS_CURR => null,
	P_PARENT_DIST_STATUS_PREV => null,
	P_PARENT_DIST_STATUS_CURR => null,
	P_WORKITEM_DIST_STATUS_PREV => null,
	P_WORKITEM_DIST_STATUS_CURR => null,
	P_PRIORITY_PREV => null,
	P_PRIORITY_CURR	=> null,
	P_DUE_DATE_PREV	=> null,
	P_DUE_DATE_CURR	=> null,
	P_RESCHEDULE_TIME_PREV => null,
	P_RESCHEDULE_TIME_CURR => null,
	P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
	P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
	P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
	P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
	P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
	P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
	P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
	P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
	P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
	P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
	P_STATUS => x_return_status,
	P_ERROR_CODE => x_msg_data ,
	X_AUDIT_LOG_ID => l_audit_log_id,
	X_MSG_DATA => l_msg_data,
	X_RETURN_STATUS => l_return_status); commit;

  end if;
  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO sync_ws_details_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;


  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then

     l_action_key := 'SYNC_ASSCT_WS';
     l_event_key := null;
     l_module := 'IEU_WR_PUB.SYNC_WS_DETAILS';

     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
     (
	P_ACTION_KEY => l_action_key,
	P_EVENT_KEY =>	l_event_key,
	P_MODULE => l_module,
	P_WS_CODE => p_ws_code,
	P_APPLICATION_ID => 696,
	P_WORKITEM_PK_ID => null,
	P_WORKITEM_OBJ_CODE => null,
	P_WORK_ITEM_STATUS_PREV => null,
	P_WORK_ITEM_STATUS_CURR	=> null,
	P_OWNER_ID_PREV	 => null,
	P_OWNER_ID_CURR	=> null,
	P_OWNER_TYPE_PREV => null,
	P_OWNER_TYPE_CURR => null,
	P_ASSIGNEE_ID_PREV => null,
	P_ASSIGNEE_ID_CURR => null,
	P_ASSIGNEE_TYPE_PREV => null,
	P_ASSIGNEE_TYPE_CURR => null,
	P_SOURCE_OBJECT_ID_PREV => null,
	P_SOURCE_OBJECT_ID_CURR => null,
	P_SOURCE_OBJECT_TYPE_CODE_PREV => null,
	P_SOURCE_OBJECT_TYPE_CODE_CURR => null,
	P_PARENT_WORKITEM_STATUS_PREV => null,
	P_PARENT_WORKITEM_STATUS_CURR => null,
	P_PARENT_DIST_STATUS_PREV => null,
	P_PARENT_DIST_STATUS_CURR => null,
	P_WORKITEM_DIST_STATUS_PREV => null,
	P_WORKITEM_DIST_STATUS_CURR => null,
	P_PRIORITY_PREV => null,
	P_PRIORITY_CURR	=> null,
	P_DUE_DATE_PREV	=> null,
	P_DUE_DATE_CURR	=> null,
	P_RESCHEDULE_TIME_PREV => null,
	P_RESCHEDULE_TIME_CURR => null,
	P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
	P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
	P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
	P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
	P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
	P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
	P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
	P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
	P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
	P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
	P_STATUS => x_return_status,
	P_ERROR_CODE => x_msg_data ,
	X_AUDIT_LOG_ID => l_audit_log_id,
	X_MSG_DATA => l_msg_data,
	X_RETURN_STATUS => l_return_status); commit;

  end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN

  ROLLBACK TO sync_ws_details_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;


  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then

     l_action_key := 'SYNC_ASSCT_WS';
     l_event_key := null;
     l_module := 'IEU_WR_PUB.SYNC_WS_DETAILS';

     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
     (
	P_ACTION_KEY => l_action_key,
	P_EVENT_KEY =>	l_event_key,
	P_MODULE => l_module,
	P_WS_CODE => p_ws_code,
	P_APPLICATION_ID => 696,
	P_WORKITEM_PK_ID => null,
	P_WORKITEM_OBJ_CODE => null,
	P_WORK_ITEM_STATUS_PREV => null,
	P_WORK_ITEM_STATUS_CURR	=> null,
	P_OWNER_ID_PREV	 => null,
	P_OWNER_ID_CURR	=> null,
	P_OWNER_TYPE_PREV => null,
	P_OWNER_TYPE_CURR => null,
	P_ASSIGNEE_ID_PREV => null,
	P_ASSIGNEE_ID_CURR => null,
	P_ASSIGNEE_TYPE_PREV => null,
	P_ASSIGNEE_TYPE_CURR => null,
	P_SOURCE_OBJECT_ID_PREV => null,
	P_SOURCE_OBJECT_ID_CURR => null,
	P_SOURCE_OBJECT_TYPE_CODE_PREV => null,
	P_SOURCE_OBJECT_TYPE_CODE_CURR => null,
	P_PARENT_WORKITEM_STATUS_PREV => null,
	P_PARENT_WORKITEM_STATUS_CURR => null,
	P_PARENT_DIST_STATUS_PREV => null,
	P_PARENT_DIST_STATUS_CURR => null,
	P_WORKITEM_DIST_STATUS_PREV => null,
	P_WORKITEM_DIST_STATUS_CURR => null,
	P_PRIORITY_PREV => null,
	P_PRIORITY_CURR	=> null,
	P_DUE_DATE_PREV	=> null,
	P_DUE_DATE_CURR	=> null,
	P_RESCHEDULE_TIME_PREV => null,
	P_RESCHEDULE_TIME_CURR => null,
	P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
	P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
	P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
	P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
	P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
	P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
	P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
	P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
	P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
	P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
	P_STATUS => x_return_status,
	P_ERROR_CODE => x_msg_data ,
	X_AUDIT_LOG_ID => l_audit_log_id,
	X_MSG_DATA => l_msg_data,
	X_RETURN_STATUS => l_return_status); commit;

  end if;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END SYNC_WS_DETAILS;

PROCEDURE GET_NEXT_WORK_FOR_APPS
 ( p_api_version               IN  NUMBER,
   p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
   p_commit                    IN VARCHAR2 DEFAULT NULL,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_ws_det_list      IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST,
   p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
   x_uwqm_workitem_data       OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2) IS

  l_dist_from_where        VARCHAR2(4000);
  l_dist_to_where          VARCHAR2(4000);

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'GET_NEXT_WORK_FOR_APPS';

  l_token_str          VARCHAR2(4000);

  l_ws_id             NUMBER;
  l_ws_type           IEU_UWQM_WORK_SOURCES_B.WS_TYPE%TYPE;
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_obj_code          IEU_UWQM_WORK_SOURCES_B.OBJECT_CODE%TYPE;

  -- Audit Log
l_action_key VARCHAR2(2000);
l_event_key VARCHAR2(2000);
l_module VARCHAR2(2000);
l_curr_ws_code VARCHAR2(2000);
l_application_id NUMBER;
l_prev_status_id NUMBER;
l_prev_owner_id NUMBER;
l_prev_owner_type VARCHAR2(2000);
l_prev_assignee_id NUMBER;
l_prev_assignee_type VARCHAR2(2000);
l_prev_distribution_status_id NUMBER;
l_prev_priority_id NUMBER;
l_prev_due_date DATE;
l_prev_reschedule_time DATE;
l_ieu_comment_code1 VARCHAR2(2000);
l_ieu_comment_code2 VARCHAR2(2000);
l_ieu_comment_code3 VARCHAR2(2000);
l_ieu_comment_code4 VARCHAR2(2000);
l_ieu_comment_code5 VARCHAR2(2000);
l_workitem_comment_code1 VARCHAR2(2000);
l_workitem_comment_code2 VARCHAR2(2000);
l_workitem_comment_code3 VARCHAR2(2000);
l_workitem_comment_code4 VARCHAR2(2000);
l_workitem_comment_code5 VARCHAR2(2000);

l_ws_code1 VARCHAR2(50);
l_ws_code2 VARCHAR2(50);
l_assct_ws_code VARCHAR2(50);
L_LOG_DIST_FROM VARCHAR(100);
L_LOG_DIST_TO VARCHAR2(100);
l_msg_data VARCHAR2(4000);
l_return_status VARCHAR2(10);
l_message varchar2(4000);
l_prev_source_object_id NUMBER;
l_prev_source_object_type_code VARCHAR2(30);
l_workitem_pk_id NUMBER;
l_workitem_obj_code VARCHAR2(50);
l_owner_id NUMBER;
l_owner_type VARCHAR2(500);
l_assignee_id NUMBER;
l_assignee_type VARCHAR2(500);
l_priority_id  NUMBER;
l_due_date DATE;
l_source_object_id  NUMBER;
l_source_object_type_code VARCHAR2(500);
l_workitem_status_id NUMBER;
l_dist_status_id NUMBER;
l_reschedule_time DATE;
l_audit_log_id NUMBER;
l_bindvar_from_list IEU_UWQ_GET_NEXT_WORK_PVT.IEU_UWQ_BINDVAR_LIST;
l_bindvar_to_list   IEU_UWQ_GET_NEXT_WORK_PVT.IEU_UWQ_BINDVAR_LIST;


BEGIN

  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  l_token_str := '';
  l_dist_from := 'GROUP_OWNED';
  l_dist_to   := 'INDIVIDUAL_ASSIGNED';
  SAVEPOINT next_work_for_apps;

  x_return_status := fnd_api.g_ret_sts_success;

  -- Check for API Version

  IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
  THEN
        RAISE fnd_api.g_exc_unexpected_error;
  END IF;

      -- Initialize Message list

  IF fnd_api.to_boolean(p_init_msg_list)
  THEN
         FND_MSG_PUB.INITIALIZE;
  END IF;


  for i in p_ws_det_list.first..p_ws_det_list.last
  loop

    --dbms_output.put_line('ws_code : '||p_ws_det_list(i).ws_code);
    BEGIN
       l_not_valid_flag := 'N';
       Select ws_id, ws_type, object_code
       into   l_ws_id, l_ws_type, l_obj_code
       from   ieu_uwqm_work_sources_b
       where  ws_code = p_ws_det_list(i).ws_code
--       and nvl(not_valid_flag, 'N') = 'N';
       and nvl(not_valid_flag, 'N') = l_not_valid_flag;

    EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_det_list(i).ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'GET_NEXT_WORK_FOR_APPS');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','GET_NEXT_WORK_FOR_APPS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

    END;

  end loop;

  -- Get the extra where clause for Distribute_from and distribute_to based on the ws_code

  IEU_UWQ_GET_NEXT_WORK_PVT.GET_WS_WHERE_CLAUSE
    (p_type             => 'DELIVER',
     p_ws_det_list      => p_ws_det_list,
     p_resource_id      => p_resource_id,
     x_dist_from_where  => l_dist_from_where,
     x_dist_to_where    => l_dist_to_where,
     x_bindvar_from_list => l_bindvar_from_list,
     x_bindvar_to_list => l_bindvar_to_list);

--insert into p_temp(msg) values ('from: '||l_dist_from_where); commit;
--insert into p_temp(msg) values ('from: '||l_dist_to_where); commit;

  BEGIN
	  IEU_UWQ_GET_NEXT_WORK_PVT.DISTRIBUTE_AND_DELIVER_WR_ITEM
	   ( p_api_version                  => p_api_version,
	     p_resource_id                  => p_resource_id,
	     p_language                     => p_language,
	     p_source_lang                  => p_source_lang,
	     p_dist_from_extra_where_clause => l_dist_from_where,
	     p_dist_to_extra_where_clause   => l_dist_to_where,
             p_bindvar_from_list            => l_bindvar_from_list,
             p_bindvar_to_list              => l_bindvar_to_list,
	     x_uwqm_workitem_data           => x_uwqm_workitem_data,
	     x_msg_count                    => x_msg_count,
	     x_msg_data                     => x_msg_data,
	     x_return_status                => x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      l_msg_data := SQLCODE||SQLERRM;
      --dbms_output.put_line(SQLCODE||' '||SQLERRM); commit;
  END;
  -- Audit Logging should be done only when the Profile Option Value is Minimal, Full or Detailed
  -- This will be logged as an action
--insert into p_temp(msg) values ('ret sts: '||x_return_status); commit;

  if x_uwqm_workitem_data.count > 0
  then
       for j in x_uwqm_workitem_data.first .. x_uwqm_workitem_data.last
       loop
         if (x_uwqm_workitem_data(j).param_name = 'WORKITEM_PK_ID')
         then
             l_workitem_pk_id := x_uwqm_workitem_data(j).param_value;
         end if;
         if (x_uwqm_workitem_data(j).param_name = 'WORKITEM_OBJ_CODE')
         then
             l_workitem_obj_code := x_uwqm_workitem_data(j).param_value;
         end if;
	 if (x_uwqm_workitem_data(j).param_name = 'PRIORITY_ID')
	 then
		l_priority_id := x_uwqm_workitem_data(j).param_value;
	 end if;
	 if (x_uwqm_workitem_data(j).param_name = 'DUE_DATE')
	 then
		l_due_date := x_uwqm_workitem_data(j).param_value;
	 end if;
	 if (x_uwqm_workitem_data(j).param_name = 'OWNER_ID')
	 then
		l_owner_id := x_uwqm_workitem_data(j).param_value;
	 end if;
	 if (x_uwqm_workitem_data(j).param_name = 'OWNER_TYPE')
	 then
		l_owner_type := x_uwqm_workitem_data(j).param_value;
	 end if;
	 if (x_uwqm_workitem_data(j).param_name = 'ASSIGNEE_ID')
	 then
		l_assignee_id := x_uwqm_workitem_data(j).param_value;
	 end if;
	 if (x_uwqm_workitem_data(j).param_name = 'ASSIGNEE_TYPE')
	 then
		l_assignee_type := x_uwqm_workitem_data(j).param_value;
	 end if;
	 if (x_uwqm_workitem_data(j).param_name = 'SOURCE_OBJECT_ID')
	 then
		l_source_object_id := x_uwqm_workitem_data(j).param_value;
	 end if;
	 if (x_uwqm_workitem_data(j).param_name = 'SOURCE_OBJECT_TYPE_CODE')
	 then
		l_source_object_type_code := x_uwqm_workitem_data(j).param_value;
	 end if;
	 if (x_uwqm_workitem_data(j).param_name = 'STATUS_ID')
	 then
		l_workitem_status_id := x_uwqm_workitem_data(j).param_value;
	 end if;
       end loop;
  end if;

  BEGIN

    SELECT distribution_status_id, reschedule_time, due_date
    INTO   l_dist_status_id, l_reschedule_time, l_due_date
    FROM   ieu_uwqm_items
    WHERE  workitem_pk_id = l_workitem_pk_id
    AND    workitem_obj_code = l_workitem_obj_code;
  EXCEPTION
    when others then
      null;
  END;
  if p_audit_trail_rec.count > 0
  then
      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
      loop
        l_action_key := p_audit_trail_rec(n).action_key;
	l_module := p_audit_trail_rec(n).module;
        if (l_audit_log_val = 'DETAILED')
	then
		l_workitem_comment_code1 := p_audit_trail_rec(n).workitem_comment_code1;
		l_workitem_comment_code2 := p_audit_trail_rec(n).workitem_comment_code2;
		l_workitem_comment_code3 := p_audit_trail_rec(n).workitem_comment_code3;
		l_workitem_comment_code4 := p_audit_trail_rec(n).workitem_comment_code4;
		l_workitem_comment_code5 := p_audit_trail_rec(n).workitem_comment_code5;
	else
		l_workitem_comment_code1 := null;
		l_workitem_comment_code2 := null;
		l_workitem_comment_code3 := null;
		l_workitem_comment_code4 := null;
		l_workitem_comment_code5 := null;
        end if;
      end loop;
  end if;
 --insert into p_temp(msg) values ('audit log'); commit;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then

             l_action_key := 'DELIVERY';
             l_event_key := null;
	     l_module := 'IEU_WR_PUB.GET_NEXT_WORK_FOR_APPS';

             if x_msg_count > 0
	     then
	        FOR l_index IN 1..x_msg_count LOOP
	           l_message := l_message || FND_MSG_PUB.Get(p_msg_index => l_index,p_encoded => 'F');
	        END LOOP;
	     end if;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => null,
		P_APPLICATION_ID => 696,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_workitem_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_workitem_status_id,
		P_OWNER_ID_PREV	 => l_owner_id,
		P_OWNER_ID_CURR	=> l_owner_id,
		P_OWNER_TYPE_PREV => l_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_assignee_id,
		P_ASSIGNEE_ID_CURR => l_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => null,
		P_PARENT_WORKITEM_STATUS_CURR => null,
		P_PARENT_DIST_STATUS_PREV => null,
		P_PARENT_DIST_STATUS_CURR => null,
		P_WORKITEM_DIST_STATUS_PREV => l_dist_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_dist_status_id,
		P_PRIORITY_PREV => l_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_due_date,
		P_DUE_DATE_CURR	=> l_due_date,
		P_RESCHEDULE_TIME_PREV => l_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_message,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);
		commit;
--insert into p_temp(msg) values ('audit log2'); commit;
  end if;
-- insert into p_temp(msg) values ('commit work'); commit;
  IF FND_API.TO_BOOLEAN( p_commit )
  THEN
         COMMIT WORK;
  END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO next_work_for_apps;
  x_return_status := fnd_api.g_ret_sts_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then

             l_action_key := 'DELIVERY';
             l_event_key := null;
	     l_module := 'IEU_WR_PUB.GET_NEXT_WORK_FOR_APPS';

	     FOR l_index IN 1..x_msg_count LOOP
	        l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_msg_index => l_index,p_encoded => 'F');
	     END LOOP;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => null,
		P_APPLICATION_ID => 696,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_workitem_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_workitem_status_id,
		P_OWNER_ID_PREV	 => l_owner_id,
		P_OWNER_ID_CURR	=> l_owner_id,
		P_OWNER_TYPE_PREV => l_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_assignee_id,
		P_ASSIGNEE_ID_CURR => l_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => null,
		P_PARENT_WORKITEM_STATUS_CURR => null,
		P_PARENT_DIST_STATUS_PREV => null,
		P_PARENT_DIST_STATUS_CURR => null,
		P_WORKITEM_DIST_STATUS_PREV => l_dist_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_dist_status_id,
		P_PRIORITY_PREV => l_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_due_date,
		P_DUE_DATE_CURR	=> l_due_date,
		P_RESCHEDULE_TIME_PREV => l_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_message ,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status); commit;
  end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO next_work_for_apps;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then

             l_action_key := 'DELIVERY';
             l_event_key := null;
	     l_module := 'IEU_WR_PUB.GET_NEXT_WORK_FOR_APPS';

	     FOR l_index IN 1..x_msg_count LOOP
	        l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_msg_index => l_index,p_encoded => 'F');
	     END LOOP;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => null,
		P_APPLICATION_ID => 696,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_workitem_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_workitem_status_id,
		P_OWNER_ID_PREV	 => l_owner_id,
		P_OWNER_ID_CURR	=> l_owner_id,
		P_OWNER_TYPE_PREV => l_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_assignee_id,
		P_ASSIGNEE_ID_CURR => l_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => null,
		P_PARENT_WORKITEM_STATUS_CURR => null,
		P_PARENT_DIST_STATUS_PREV => null,
		P_PARENT_DIST_STATUS_CURR => null,
		P_WORKITEM_DIST_STATUS_PREV => l_dist_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_dist_status_id,
		P_PRIORITY_PREV => l_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_due_date,
		P_DUE_DATE_CURR	=> l_due_date,
		P_RESCHEDULE_TIME_PREV => l_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_message ,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status); commit;

  end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK TO next_work_for_apps;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL') )
  then

             l_action_key := 'DELIVERY';
             l_event_key := null;
	     l_module := 'IEU_WR_PUB.GET_NEXT_WORK_FOR_APPS';

	     FOR l_index IN 1..x_msg_count LOOP
	        l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_msg_index => l_index,p_encoded => 'F');
	     END LOOP;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => null,
		P_APPLICATION_ID => 696,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_workitem_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_workitem_status_id,
		P_OWNER_ID_PREV	 => l_owner_id,
		P_OWNER_ID_CURR	=> l_owner_id,
		P_OWNER_TYPE_PREV => l_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_assignee_id,
		P_ASSIGNEE_ID_CURR => l_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => null,
		P_PARENT_WORKITEM_STATUS_CURR => null,
		P_PARENT_DIST_STATUS_PREV => null,
		P_PARENT_DIST_STATUS_CURR => null,
		P_WORKITEM_DIST_STATUS_PREV => l_dist_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_dist_status_id,
		P_PRIORITY_PREV => l_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_due_date,
		P_DUE_DATE_CURR	=> l_due_date,
		P_RESCHEDULE_TIME_PREV => l_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_message ,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);commit;

  end if;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END GET_NEXT_WORK_FOR_APPS;


PROCEDURE SYNC_DEPENDENT_WR_ITEMS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_wr_item_list              IN IEU_WR_PUB.IEU_WR_ITEM_LIST ,
  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'SYNC_DEPENDENT_WR_ITEMS';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_msg_data          VARCHAR2(4000);

  l_ws_id             NUMBER;
  l_parent_ws_id      NUMBER;
  l_child_ws_id       NUMBER;
  l_dist_from         IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_ws_type           VARCHAR2(500);
  l_ws_code           VARCHAR2(500);
  l_owner_type        IEU_UWQM_ITEMS.OWNER_TYPE%TYPE;
  l_assignee_type     IEU_UWQM_ITEMS.ASSIGNEE_TYPE%TYPE;
  l_source_object_id  NUMBER;
  l_source_object_type_code  IEU_UWQM_ITEMS.SOURCE_OBJECT_TYPE_CODE%TYPE;
  l_distribution_status_id NUMBER;
  l_parent_dist_status  NUMBER;
  l_dist_st_based_on_parent  VARCHAR2(5);
  l_set_dist_id_flag VARCHAR2(5);
  l_parent_status_id  NUMBER;

  -- Audit Log
l_action_key VARCHAR2(2000);
l_event_key VARCHAR2(2000);
l_module VARCHAR2(2000);
l_curr_ws_code VARCHAR2(2000);
l_application_id NUMBER;
l_prev_status_id NUMBER;
l_prev_owner_id NUMBER;
l_prev_owner_type VARCHAR2(2000);
l_prev_assignee_id NUMBER;
l_prev_assignee_type VARCHAR2(2000);
l_prev_distribution_status_id NUMBER;
l_prev_priority_id NUMBER;
l_prev_due_date DATE;
l_prev_reschedule_time DATE;
l_ieu_comment_code1 VARCHAR2(2000);
l_ieu_comment_code2 VARCHAR2(2000);
l_ieu_comment_code3 VARCHAR2(2000);
l_ieu_comment_code4 VARCHAR2(2000);
l_ieu_comment_code5 VARCHAR2(2000);
l_workitem_comment_code1 VARCHAR2(2000);
l_workitem_comment_code2 VARCHAR2(2000);
l_workitem_comment_code3 VARCHAR2(2000);
l_workitem_comment_code4 VARCHAR2(2000);
l_workitem_comment_code5 VARCHAR2(2000);

l_owner_id NUMBER;
l_assignee_id NUMBER;
l_status_id NUMBER;
l_priority_id NUMBER;
l_due_date DATE;
l_reschedule_time DATE;

l_ws_code1 VARCHAR2(50);
l_ws_code2 VARCHAR2(50);
l_assct_ws_code VARCHAR2(50);

L_LOG_DIST_FROM VARCHAR(100);
L_LOG_DIST_TO VARCHAR2(100);
l_return_status VARCHAR2(10);
l_prev_source_object_id NUMBER;
l_prev_source_object_type_code VARCHAR2(30);
l_workitem_pk_id NUMBER;
l_workitem_obj_code VARCHAR2(30);
l_audit_log_id NUMBER;

BEGIN

  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  l_token_str := '';
  l_dist_from := 'GROUP_OWNED';
  l_dist_to   := 'INDIVIDUAL_ASSIGNED';
  SAVEPOINT sync_dependent_wr_items_sp;

  x_return_status := fnd_api.g_ret_sts_success;

  -- Check for API Version

  IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
  THEN
      RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize Message list

  IF fnd_api.to_boolean(p_init_msg_list)
  THEN
      FND_MSG_PUB.INITIALIZE;
  END IF;


  for i in p_wr_item_list.first .. p_wr_item_list.last
  loop


      --dbms_output.put_line('work item pk id: '||p_wr_item_list(i).workitem_pk_id||' obj code: '||p_wr_item_list(i).workitem_obj_code);
     -- Get all the required Work Item details
     -- some additional info is retrieved for Audit Log
     l_workitem_pk_id := p_wr_item_list(i).workitem_pk_id;
     l_workitem_obj_code := p_wr_item_list(i).workitem_obj_code;

     BEGIN
	select ws_id, owner_id, owner_type, assignee_id, assignee_type, status_id,
	       priority_id, due_date, reschedule_time, distribution_status_id,  source_object_id, source_object_type_code
	into   l_ws_id, l_owner_id, l_owner_type, l_assignee_id, l_assignee_type, l_prev_status_id,
	       l_priority_id, l_due_date, l_reschedule_time, l_prev_distribution_status_id,  l_source_object_id, l_source_object_type_code
        from   ieu_uwqm_items
        where  workitem_pk_id = p_wr_item_list(i).workitem_pk_id
        and    workitem_obj_code = p_wr_item_list(i).workitem_obj_code;

     EXCEPTION
       WHEN OTHERS THEN

         x_return_status := fnd_api.g_ret_sts_error;

         l_token_str := p_wr_item_list(i).workitem_obj_code ||' WORKITEM_PK_ID : '|| p_wr_item_list(i).workitem_pk_id ||' - '||l_msg_data;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;

     END;

     -- some additional info like Dist from and to are retrieved for Audit Log

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_code, ws_type, distribute_from, distribute_to
       into   l_ws_code, l_ws_type, l_log_dist_from, l_log_dist_to
       from   ieu_uwqm_work_sources_b
       where  ws_id = l_ws_id
--       and    nvl(not_valid_flag, 'N') = 'N';
       and    nvl(not_valid_flag, 'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||l_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;

     if (l_ws_type = 'ASSOCIATION')
     then
        BEGIN

           SELECT parent_ws_id, child_ws_id, dist_st_based_on_parent_flag
           INTO   l_parent_ws_id, l_child_ws_id, l_dist_st_based_on_parent
           FROM   IEU_UWQM_WS_ASSCT_PROPS
           WHERE  ws_id = l_ws_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||l_ws_code;
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WS_DETAILS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

     end if;/* ws_type */

      -- Set Distribution Status based on these rules

      -- If the Distribution State is based on the Parent, then check if the parent is distributed.

      if (l_dist_st_based_on_parent = 'Y')
      then
          BEGIN
              SELECT distribution_status_id, status_id
              INTO   l_parent_dist_status, l_parent_status_id
              FROM   ieu_uwqm_items
              WHERE  workitem_pk_id = l_source_object_id
              AND    workitem_obj_code = l_source_object_type_code;
          EXCEPTION
           WHEN OTHERS THEN
              l_parent_dist_status := null;
          END;
      end if;

      --dbms_output.put_line('dist st based on parent; '||l_dist_st_based_on_parent ||'s id: '||l_source_object_id||' s obj: '||l_source_object_type_code||' parent dist st: '||l_parent_dist_status);


      -- If the parent is not distributed, then this item will be in "On-Hold/Unavailable" status
      -- else set the status based on distribute_from and distribute_to

     if (l_parent_status_id = 3)
     then

            l_set_dist_id_flag  :=    'T';

     else

          if   (l_parent_dist_status  <> 3)
          then

                l_distribution_status_id := 0;

           else

                l_set_dist_id_flag := 'T';

           end if; /* parent_dist_status */

     end if; /* l_parent_status_id */

     if (l_set_dist_id_flag = 'T')
     then

          if (l_dist_from = 'GROUP_OWNED') and
             (l_dist_to = 'INDIVIDUAL_ASSIGNED')
          then
               if (l_owner_type  = 'RS_GROUP') and
                  ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
               then
                   l_distribution_status_id := 1;
               elsif (l_assignee_type  = 'RS_INDIVIDUAL')
               then
                   l_distribution_status_id := 3;
               else
                   l_distribution_status_id := 0;
               end if;
           end if;

            /*         if (l_dist_from = 'GROUP_OWNED') and
                        (l_dist_to = 'INDIVIDUAL_OWNED')
                     then

                           if (l_owner_type  = 'RS_GROUP')
                           then
                                l_distribution_status_id := 1;
                           elsif (l_owner_type  = 'RS_INDIVIDUAL')
                           then
                                l_distribution_status_id := 3;
                           else
                                l_distribution_status_id := 0;
                           end if;

                    elsif (l_dist_from = 'GROUP_OWNED') and
                          (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                    then

                          if (l_owner_type  = 'RS_GROUP') and
                             ( (l_assignee_type is null) OR (l_assignee_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_OWNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP') and
                             ( (l_owner_type is null) OR (l_owner_type <> 'RS_INDIVIDUAL') )
                          then
                              l_distribution_status_id := 1;
                          elsif (l_owner_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                   elsif (l_dist_from = 'GROUP_ASSIGNED') and
                         (l_dist_to = 'INDIVIDUAL_ASSIGNED')
                   then

                          if (l_assignee_type  = 'RS_GROUP')
                          then
                              l_distribution_status_id := 1;
                          elsif (l_assignee_type  = 'RS_INDIVIDUAL')
                          then
                              l_distribution_status_id := 3;
                          else
                              l_distribution_status_id := 0;
                          end if;

                  end if;
             */
      end if; /* l_set_dist_id_flag */

      --dbms_output.put_line('l_set_dist_id_flag: '||l_set_dist_id_flag|| ' dist status: '|| l_distribution_status_id);
      update ieu_uwqm_items
      set distribution_status_id = l_distribution_status_id
      where workitem_pk_id = p_wr_item_list(i).workitem_pk_id
      and   workitem_obj_code = p_wr_item_list(i).workitem_obj_code;

      if (sql%notfound)
      then
         l_return_status := 'E';
         l_msg_data := SQLERRM;
	 raise fnd_api.g_exc_error;
      else
         l_return_status := 'S';
      end if;

      -- Get the values of App Distribute From and To for Audit Logging
      if (l_audit_log_val = 'DETAILED')
      then

         l_ieu_comment_code1 := null;
	 l_ieu_comment_code2 := null;
         l_ieu_comment_code3 := null;
         l_ieu_comment_code4 := null;
         l_ieu_comment_code5 := null;

	 /******************************* Used only for Distribute **************************
	 if (l_log_dist_from = 'GROUP_OWNED') and
		(l_log_dist_to = 'INDIVIDUAL_OWNED')
	 then
		l_ieu_comment_code1 := 'GO_IO';
	 elsif (l_log_dist_from = 'GROUP_OWNED') and
		  (l_log_dist_to = 'INDIVIDUAL_ASSIGNED')
	 then
		l_ieu_comment_code1 := 'GO_IA';
	 elsif (l_log_dist_from = 'GROUP_ASSIGNED') and
		 (l_log_dist_to = 'INDIVIDUAL_OWNED')
	 then
		l_ieu_comment_code1 := 'GA_IO';
	 elsif (l_log_dist_from = 'GROUP_ASSIGNED') and
		 (l_log_dist_to = 'INDIVIDUAL_ASSIGNED')
	 then
		l_ieu_comment_code1 := 'GA_IA';
	 end if;
	 ********************************************************************/

         if (l_dist_st_based_on_parent = 'Y')
         then
             if (l_parent_dist_status = 0) and (l_parent_status_id = 0)
	     then
	         l_ieu_comment_code2 := 'ON_HOLD_OPEN';
             elsif (l_parent_dist_status = 0) and (l_parent_status_id = 3)
	     then
	         l_ieu_comment_code2 := 'ON_HOLD_CLOSED';
             elsif (l_parent_dist_status = 0) and (l_parent_status_id = 5)
	     then
	         l_ieu_comment_code2 := 'ON_HOLD_SLEEP';
             elsif (l_parent_dist_status = 1) and (l_parent_status_id = 0)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTABLE_OPEN';
             elsif (l_parent_dist_status = 1) and (l_parent_status_id = 3)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTABLE_CLOSED';
             elsif (l_parent_dist_status = 1) and (l_parent_status_id = 5)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTABLE_SLEEP';
             elsif (l_parent_dist_status = 3) and (l_parent_status_id = 0)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTED_OPEN';
             elsif (l_parent_dist_status = 3) and (l_parent_status_id = 3)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTED_CLOSED';
             elsif (l_parent_dist_status = 3) and (l_parent_status_id = 5)
	     then
	         l_ieu_comment_code2 := 'DISTRIBUTED_SLEEP';
	     end if;
	  end if;

      end if;

     -- Logging will be done only for profile value - FULL or DETAILED, as this is only a event
     -- Insert values to Audit Log

     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
     then

	     if p_audit_trail_rec.count > 0
	     then
	      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
	      loop
		l_action_key := p_audit_trail_rec(n).action_key;
		l_module := p_audit_trail_rec(n).module;
		if (l_audit_log_val = 'DETAILED')
		then
			l_workitem_comment_code1 := p_audit_trail_rec(n).workitem_comment_code1;
			l_workitem_comment_code2 := p_audit_trail_rec(n).workitem_comment_code2;
			l_workitem_comment_code3 := p_audit_trail_rec(n).workitem_comment_code3;
			l_workitem_comment_code4 := p_audit_trail_rec(n).workitem_comment_code4;
			l_workitem_comment_code5 := p_audit_trail_rec(n).workitem_comment_code5;
		else
			l_workitem_comment_code1 := null;
			l_workitem_comment_code2 := null;
			l_workitem_comment_code3 := null;
			l_workitem_comment_code4 := null;
			l_workitem_comment_code5 := null;
		end if;
	      end loop;
	     end if;

	     l_event_key := 'SYNC_CHILD_WORKITEM';
	     l_return_status := 'S';

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_ws_code,
		P_APPLICATION_ID => 696,
		P_WORKITEM_PK_ID => p_wr_item_list(i).workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_wr_item_list(i).workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_prev_status_id,
		P_OWNER_ID_PREV	 => l_owner_id,
		P_OWNER_ID_CURR	=> l_owner_id,
		P_OWNER_TYPE_PREV => l_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_assignee_id,
		P_ASSIGNEE_ID_CURR => l_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => p_wr_item_list(i).prev_parent_workitem_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => p_wr_item_list(i).prev_parent_dist_status_id,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_due_date,
		P_DUE_DATE_CURR	=> l_due_date,
		P_RESCHEDULE_TIME_PREV => l_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => 'S',
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);

      end if;

      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END iF;

  end loop; /* p_wr_item_list */

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO sync_dependent_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
  then

	     if p_audit_trail_rec.count > 0
	     then
	      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
	      loop
		l_action_key := p_audit_trail_rec(n).action_key;
		l_module := p_audit_trail_rec(n).module;
		if (l_audit_log_val = 'DETAILED')
		then
			l_workitem_comment_code1 := p_audit_trail_rec(n).workitem_comment_code1;
			l_workitem_comment_code2 := p_audit_trail_rec(n).workitem_comment_code2;
			l_workitem_comment_code3 := p_audit_trail_rec(n).workitem_comment_code3;
			l_workitem_comment_code4 := p_audit_trail_rec(n).workitem_comment_code4;
			l_workitem_comment_code5 := p_audit_trail_rec(n).workitem_comment_code5;
		else
			l_workitem_comment_code1 := null;
			l_workitem_comment_code2 := null;
			l_workitem_comment_code3 := null;
			l_workitem_comment_code4 := null;
			l_workitem_comment_code5 := null;
		end if;
	      end loop;
	     end if;

	     l_event_key := 'SYNC_CHILD_WORKITEM';

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_ws_code,
		P_APPLICATION_ID => 696,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_status_id,
		P_OWNER_ID_PREV	 => l_owner_id,
		P_OWNER_ID_CURR	=> l_owner_id,
		P_OWNER_TYPE_PREV => l_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_assignee_id,
		P_ASSIGNEE_ID_CURR => l_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_due_date,
		P_DUE_DATE_CURR	=> l_due_date,
		P_RESCHEDULE_TIME_PREV => l_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => 'E',
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);

   end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO sync_dependent_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
  then

	     if p_audit_trail_rec.count > 0
	     then
	      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
	      loop
		l_action_key := p_audit_trail_rec(n).action_key;
		l_module := p_audit_trail_rec(n).module;
		if (l_audit_log_val = 'DETAILED')
		then
			l_workitem_comment_code1 := p_audit_trail_rec(n).workitem_comment_code1;
			l_workitem_comment_code2 := p_audit_trail_rec(n).workitem_comment_code2;
			l_workitem_comment_code3 := p_audit_trail_rec(n).workitem_comment_code3;
			l_workitem_comment_code4 := p_audit_trail_rec(n).workitem_comment_code4;
			l_workitem_comment_code5 := p_audit_trail_rec(n).workitem_comment_code5;
		else
			l_workitem_comment_code1 := null;
			l_workitem_comment_code2 := null;
			l_workitem_comment_code3 := null;
			l_workitem_comment_code4 := null;
			l_workitem_comment_code5 := null;
		end if;
	      end loop;
	     end if;

	     l_event_key := 'SYNC_CHILD_WORKITEM';

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_ws_code,
		P_APPLICATION_ID => 696,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_status_id,
		P_OWNER_ID_PREV	 => l_owner_id,
		P_OWNER_ID_CURR	=> l_owner_id,
		P_OWNER_TYPE_PREV => l_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_assignee_id,
		P_ASSIGNEE_ID_CURR => l_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_due_date,
		P_DUE_DATE_CURR	=> l_due_date,
		P_RESCHEDULE_TIME_PREV => l_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => fnd_api.g_ret_sts_unexp_error,
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);

   end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK TO sync_dependent_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
  then

	     if p_audit_trail_rec.count > 0
	     then
	      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
	      loop
		l_action_key := p_audit_trail_rec(n).action_key;
		l_module := p_audit_trail_rec(n).module;
		if (l_audit_log_val = 'DETAILED')
		then
			l_workitem_comment_code1 := p_audit_trail_rec(n).workitem_comment_code1;
			l_workitem_comment_code2 := p_audit_trail_rec(n).workitem_comment_code2;
			l_workitem_comment_code3 := p_audit_trail_rec(n).workitem_comment_code3;
			l_workitem_comment_code4 := p_audit_trail_rec(n).workitem_comment_code4;
			l_workitem_comment_code5 := p_audit_trail_rec(n).workitem_comment_code5;
		else
			l_workitem_comment_code1 := null;
			l_workitem_comment_code2 := null;
			l_workitem_comment_code3 := null;
			l_workitem_comment_code4 := null;
			l_workitem_comment_code5 := null;
		end if;
	      end loop;
	     end if;

	     l_event_key := 'SYNC_CHILD_WORKITEM';

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_ws_code,
		P_APPLICATION_ID => 696,
		P_WORKITEM_PK_ID => l_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_status_id,
		P_OWNER_ID_PREV	 => l_owner_id,
		P_OWNER_ID_CURR	=> l_owner_id,
		P_OWNER_TYPE_PREV => l_owner_type,
		P_OWNER_TYPE_CURR => l_owner_type,
		P_ASSIGNEE_ID_PREV => l_assignee_id,
		P_ASSIGNEE_ID_CURR => l_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
		P_PRIORITY_PREV => l_priority_id,
		P_PRIORITY_CURR	=> l_priority_id,
		P_DUE_DATE_PREV	=> l_due_date,
		P_DUE_DATE_CURR	=> l_due_date,
		P_RESCHEDULE_TIME_PREV => l_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => fnd_api.g_ret_sts_unexp_error,
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data,
		X_RETURN_STATUS => l_return_status);

  end if;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END SYNC_DEPENDENT_WR_ITEMS;

PROCEDURE ACTIVATE_WS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

l_api_version CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'ACTIVATE_WS';

l_miss_param_flag   NUMBER(1) := 0;
l_token_str         VARCHAR2(4000);

l_ws_code     VARCHAR2(32);
BEGIN

  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  l_token_str := '';
  SAVEPOINT activate_ws_sp;
    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
    THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message list

    IF fnd_api.to_boolean(p_init_msg_list)
    THEN
       FND_MSG_PUB.INITIALIZE;
    END IF;

    -- validate parameters

    if p_ws_code is null
    then
        l_miss_param_flag := 1;
        l_token_str := l_token_str || '  WS_CODE ';
    END IF;

    If (l_miss_param_flag = 1)
    THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.ACTIVATE_WS');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

    END IF;

    IF p_ws_code is not null
    THEN

       BEGIN
         l_not_valid_flag := 'N';
         select ws_code
         into l_ws_code
         from ieu_uwqm_work_sources_b
         where ws_code = p_ws_code
--         and nvl(not_valid_flag, 'N') = 'N';
         and nvl(not_valid_flag, 'N') = l_not_valid_flag;
       EXCEPTION WHEN NO_DATA_FOUND
       THEN
        l_ws_code := '';
       END;

       IF (p_ws_code <> nvl(l_ws_code, '-1'))
       THEN
          l_token_str :=' WS_CODE:'||p_ws_code;
          FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_COMBINATION');
          FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.ACTIVATE_WS');
          FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
          fnd_msg_pub.ADD;
          fnd_msg_pub.Count_and_Get
          (
           p_count   =>   x_msg_count,
           p_data    =>   x_msg_data
          );

          x_return_status := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;

       ELSIF p_ws_code = l_ws_code
       THEN
	  l_active_flag := 'Y';
          update ieu_uwqm_work_sources_b
          set active_flag = l_active_flag
          where ws_code = p_ws_code;
       END IF;

     END IF;

     IF FND_API.TO_BOOLEAN(p_commit)
     THEN
        COMMIT WORK;
     END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO activate_ws_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO activate_ws_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN

  ROLLBACK TO activate_ws_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END ACTIVATE_WS;

PROCEDURE CHECK_WS_ACTIVATION_STATUS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2,
  x_ws_activation_status      OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

l_api_version CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'CHECK_WS_ACTIVATION_STATUS';

l_miss_param_flag   NUMBER(1) := 0;
l_token_str         VARCHAR2(4000);

l_ws_code     VARCHAR2(32);
l_ws_activation_status VARCHAR2(1);

BEGIN

    l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
    l_token_str := '';
    SAVEPOINT check_ws_activation_status_sp;
    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
    THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message list

    IF fnd_api.to_boolean(p_init_msg_list)
    THEN
       FND_MSG_PUB.INITIALIZE;
    END IF;

    -- validate parameters

    if p_ws_code is null
    then
        l_miss_param_flag := 1;
        l_token_str := l_token_str || '  WS_CODE ';
    END IF;

    If (l_miss_param_flag = 1)
    THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.ACTIVATE_WS');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

    END IF;

    IF p_ws_code is not null
    THEN

       BEGIN
         l_not_valid_flag := 'N';
         select ws_code, nvl(active_flag,'N')
         into l_ws_code, l_ws_activation_status
         from ieu_uwqm_work_sources_b
         where ws_code = p_ws_code
--         and nvl(not_valid_flag, 'N') = 'N';
         and nvl(not_valid_flag, 'N') = l_not_valid_flag;
       EXCEPTION WHEN NO_DATA_FOUND
       THEN
         l_ws_code := '';
       END;

       IF (p_ws_code <> nvl(l_ws_code, '-1'))
       THEN
          l_token_str :=' WS_CODE:'||p_ws_code;
          FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_COMBINATION');
          FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.ACTIVATE_WS');
          FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
          fnd_msg_pub.ADD;
          fnd_msg_pub.Count_and_Get
          (
           p_count   =>   x_msg_count,
           p_data    =>   x_msg_data
          );

          x_return_status := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;

       END IF;

       x_ws_activation_status := l_ws_activation_status;

     END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO check_ws_activation_status_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO check_ws_activation_status_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN

  ROLLBACK TO check_ws_activation_status_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;
END CHECK_WS_ACTIVATION_STATUS;


PROCEDURE PURGE_WR_ITEM
(
 P_API_VERSION_NUMBER	IN	NUMBER,
 P_INIT_MSG_LIST	IN	VARCHAR2,
 P_COMMIT	        IN	VARCHAR2,
 P_PROCESSING_SET_ID	IN	NUMBER,
 P_OBJECT_TYPE	        IN	VARCHAR2,
 X_RETURN_STATUS	OUT NOCOPY	VARCHAR2,
 X_MSG_COUNT	        OUT NOCOPY	NUMBER,
 X_MSG_DATA	        OUT NOCOPY	VARCHAR2
) AS

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;
  l_workitem_obj_code  VARCHAR2(30);

  l_msg_data           VARCHAR2(4000);
  l_msg_count          NUMBER;
  l_row_count          NUMBER;
  l_sqlerrm            VARCHAR2(2000);

BEGIN

      -- Initialize Message list
      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      -- Check for NOT NULL columns

      IF (p_object_type is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  OBJECT_TYPE  ';
      END IF;
      IF (p_processing_set_id is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  PROCESSING_SET_ID  ';
      END IF;

      If (l_miss_param_flag = 1)
      THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.PURGE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;

      -- Validate object Code

      IF (p_object_type is not NULL)
      THEN

         l_token_str := '';

         BEGIN
          SELECT 1
          INTO   l_workitem_obj_code
          FROM   jtf_objects_b
          WHERE  object_code = p_object_type;
         EXCEPTION
         WHEN no_data_found THEN
          null;
         END;

         IF (l_workitem_obj_code is null)
         THEN

           l_param_valid_flag := 1;
           l_token_str := 'WORKITEM_OBJ_CODE : '||p_object_type;

         END IF;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.PURGE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      fnd_file.put_line(FND_FILE.LOG, 'Deleting rows from table IEU_UWQM_ITEMS');
      -- This statement deletes the records from the UWQ work repository table
      -- that are linked to an SR that is available in the global temp table
      -- with purge status NULL.

       DELETE /*+ INDEX(IEU_UWQM_ITEMS IEU_UWQM_ITEMS_U2) */
	  from IEU_UWQM_ITEMS
       WHERE WORKITEM_OBJ_CODE = p_object_type
         and WORKITEM_PK_ID in
             (
              SELECT t.object_id
              FROM   JTF_OBJECT_PURGE_PARAM_TMP t
              WHERE t.object_type = p_object_type
		    AND   t.processing_set_id = p_processing_set_id
	         AND   nvl(t.purge_status,'S') <> 'E'
             );

      l_row_count := SQL%ROWCOUNT;
      fnd_file.put_line(FND_FILE.LOG, 'After deleting data from table IEU_UWQM_ITEMS ' || l_row_count || ' rows');

      x_return_status := fnd_api.g_ret_sts_success;

      fnd_file.put_line(FND_FILE.LOG, 'Completed work in ' || 'IEU_WR_PUB.PURGE_WR_ITEM' || ' with return status ' || x_return_status);
      fnd_file.put_line(FND_FILE.LOG, '--------------------------------------------------------------------------------');

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;
         l_token_str := l_msg_data;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_PURGE_WR_ITEM_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.PURGE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;

      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END iF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  x_return_status := fnd_api.g_ret_sts_error;
  fnd_file.put_line(FND_FILE.LOG, 'Inside WHEN FND_API.G_EXC_ERROR of ' || 'IEU_WR_PUB.PURGE_WR_ITEM');

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  x_return_status := fnd_api.g_ret_sts_unexp_error;
  fnd_file.put_line(FND_FILE.LOG, 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || 'IEU_WR_PUB.PURGE_WR_ITEM');

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN

  x_return_status := fnd_api.g_ret_sts_unexp_error;
  l_sqlerrm := SQLERRM;

  fnd_file.put_line(FND_FILE.LOG, 'Inside WHEN OTHERS of ' || 'IEU_WR_PUB.PURGE_WR_ITEM' || '. Oracle Error was:');
  fnd_file.put_line(FND_FILE.LOG, l_sqlerrm);

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END PURGE_WR_ITEM;


PROCEDURE PURGE_WR_ITEM
( p_api_version              IN NUMBER,
  p_init_msg_list            IN VARCHAR2 DEFAULT NULL,
  p_commit                   IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code        IN VARCHAR2,
  p_workitem_pk_id           IN NUMBER,
  p_application_id           IN NUMBER   DEFAULT NULL,
  p_audit_trail_rec	         IN SYSTEM.WR_AUDIT_TRAIL_NST DEFAULT NULL,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2) AS

  l_api_version  NUMBER        := 1.0;
  l_api_name     VARCHAR2(30);

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000);
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code  VARCHAR2(30);
  l_object_function    VARCHAR2(30);

  l_msg_data           VARCHAR2(4000);

  l_owner_id           NUMBER;
  l_assignee_id        NUMBER;
  l_owner_type         VARCHAR2(25);
  l_assignee_type      VARCHAR2(25);
  l_priority_id        NUMBER;
  l_priority_level     NUMBER;
  l_status_id          NUMBER := 0;
  l_title_len          NUMBER := 1990;
--  l_work_item_status_valid_flag VARCHAR2(10);

  -- Audit Log
l_action_key VARCHAR2(2000);
l_event_key VARCHAR2(2000);
l_module VARCHAR2(2000);
l_curr_ws_code VARCHAR2(2000);
l_application_id NUMBER;
l_prev_status_id NUMBER;
l_prev_owner_id NUMBER;
l_prev_owner_type VARCHAR2(2000);
l_prev_assignee_id NUMBER;
l_prev_assignee_type VARCHAR2(2000);
l_prev_distribution_status_id NUMBER;
l_prev_priority_id NUMBER;
l_prev_due_date DATE;
l_prev_reschedule_time DATE;
l_ieu_comment_code1 VARCHAR2(2000);
l_ieu_comment_code2 VARCHAR2(2000);
l_ieu_comment_code3 VARCHAR2(2000);
l_ieu_comment_code4 VARCHAR2(2000);
l_ieu_comment_code5 VARCHAR2(2000);
l_workitem_comment_code1 VARCHAR2(2000);
l_workitem_comment_code2 VARCHAR2(2000);
l_workitem_comment_code3 VARCHAR2(2000);
l_workitem_comment_code4 VARCHAR2(2000);
l_workitem_comment_code5 VARCHAR2(2000);

l_ws_code1 VARCHAR2(50);
l_ws_code2 VARCHAR2(50);
l_assct_ws_code VARCHAR2(50);
L_LOG_DIST_FROM VARCHAR(100);
L_LOG_DIST_TO VARCHAR2(100);
l_return_status VARCHAR2(10);

l_audit_trail_rec  SYSTEM.WR_AUDIT_TRAIL_NST;
l_prev_source_object_id NUMBER;
l_prev_source_object_type_code VARCHAR2(30);
l_audit_log_id NUMBER;

l_curr_ws_id        NUMBER;
l_dist_st_based_on_parent IEU_UWQM_WS_ASSCT_PROPS.DIST_ST_BASED_ON_PARENT_FLAG%TYPE;
l_distribution_status_id NUMBER;
l_parent_dist_status  NUMBER;
l_set_dist_id_flag VARCHAR2(5);
l_parent_status_id  NUMBER;
l_ws_id NUMBER;
l_ctr NUMBER;
l_msg_count  NUMBER;

l_work_item_status_id NUMBER;

l_msg_data2 varchar2(4000);

BEGIN

      l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
      l_api_name := 'PURGE_WR_ITEM';
      l_token_str := '';
      SAVEPOINT purge_wr_items_sp;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      -- Check for NOT NULL columns

      IF (p_workitem_obj_code is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORKITEM_OBJECT_CODE  ';
      END IF;
      IF (p_workitem_pk_id is null)
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || '  WORKITEM_PK_ID  ';
      END IF;

      If (l_miss_param_flag = 1)
      THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.PURGE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;

      -- Validate object Code

      IF (p_workitem_obj_code is not NULL)
      THEN

         l_token_str := '';

         BEGIN
          SELECT 1
          INTO   l_workitem_obj_code
          FROM   jtf_objects_b
          WHERE  object_code = p_workitem_obj_code;
         EXCEPTION
         WHEN no_data_found THEN
          null;
         END;

         IF (l_workitem_obj_code is null)
         THEN

           l_param_valid_flag := 1;
           l_token_str := 'WORKITEM_OBJ_CODE : '||p_workitem_obj_code;

         END IF;

         IF (l_param_valid_flag = 1)
         THEN

            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.PURGE_WR_ITEM');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

         END IF;

      END IF;

      -- Get the prev values for audit trail
     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR (l_audit_log_val = 'MINIMAL'))
     then
        BEGIN
		SELECT owner_id, owner_type, assignee_id, assignee_type, status_id,
		       priority_id, due_date, reschedule_time, distribution_status_id, source_object_id, source_object_type_code
		INTO   l_prev_owner_id, l_prev_owner_type, l_prev_assignee_id, l_prev_assignee_type, l_prev_status_id,
		       l_prev_priority_id, l_prev_due_date, l_prev_reschedule_time, l_prev_distribution_status_id,
		       l_prev_source_object_id, l_prev_source_object_type_code
		FROM IEU_UWQM_ITEMS
		WHERE  workitem_obj_code = p_workitem_obj_code
		AND    workitem_pk_id = p_workitem_pk_id;

        EXCEPTION
	       WHEN OTHERS THEN
		    NULL;
        END;
     end if;

      IEU_WR_ITEMS_PKG.DELETE_ROW
       ( p_workitem_obj_code,
         p_workitem_pk_id,
         l_msg_data,
         x_return_status
        );

     -- Insert values to Audit Log

  if p_audit_trail_rec is not null then

    if p_audit_trail_rec.count > 0
     then
      for n in p_audit_trail_rec.first..p_audit_trail_rec.last
      loop
        l_action_key := p_audit_trail_rec(n).action_key;
  	    l_event_key := p_audit_trail_rec(n).event_key;
 	    l_module := p_audit_trail_rec(n).module;
        if (l_audit_log_val = 'DETAILED')
	then
		l_workitem_comment_code1 := p_audit_trail_rec(n).workitem_comment_code1;
		l_workitem_comment_code2 := p_audit_trail_rec(n).workitem_comment_code2;
		l_workitem_comment_code3 := p_audit_trail_rec(n).workitem_comment_code3;
		l_workitem_comment_code4 := p_audit_trail_rec(n).workitem_comment_code4;
		l_workitem_comment_code5 := p_audit_trail_rec(n).workitem_comment_code5;
	else
		l_workitem_comment_code1 := null;
		l_workitem_comment_code2 := null;
		l_workitem_comment_code3 := null;
		l_workitem_comment_code4 := null;
		l_workitem_comment_code5 := null;
        end if;
      end loop;
    end if;
  end if;

     -- Audit Logging should be done only if the Profile Option Value is Full or Detailed
     -- However, during the actual Work Item Creation, if the Apps are not integrated,
     -- the actions cannot be logged. Hence we will be conditionally logging for
     -- Profile Option Value - Minimal. In this case, the Event value will be Null.

     if (l_action_key is NULL)
     then
       l_action_key := 'WORKITEM_PURGE';
     end if;

     if (l_audit_log_val = 'MINIMAL')
     then
       l_event_key := null;
     end if;

     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
     then

     /**
       dbms_output.put_line('prev asg: '||l_prev_assignee_type||'curr asg: '||l_assignee_type);
       dbms_output.put_line('prev asgid: '||l_prev_assignee_id||'curr asgid: '||m_assignee_id);
       dbms_output.put_line('prev owner: '||l_prev_owner_type||'curr own: '||l_owner_type);
       dbms_output.put_line('prev ownid: '||l_prev_owner_id||'curr ownid: '||m_owner_id);
      **/

       if (l_event_key is NULL)
       then
           l_event_key := 'PURGE_WR_ITEM';
       end if;
       --end if;
     end if;

     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_PURGE')) )
     then

        l_msg_data2 := l_msg_data;

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_prev_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> l_prev_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_prev_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => l_prev_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_prev_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_prev_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_prev_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_prev_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_prev_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> l_prev_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_prev_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data2,
		X_RETURN_STATUS => l_return_status);

      end if;

        x_return_status := fnd_api.g_ret_sts_success;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;
         l_token_str := l_msg_data;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_PURGE_WR_ITEM_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.PURGE_WR_ITEM');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;

      IF FND_API.TO_BOOLEAN( p_commit )
      THEN
         COMMIT WORK;
      END iF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO purge_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_PURGE')) )
     then

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_prev_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> l_prev_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_prev_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => l_prev_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_prev_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_prev_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_prev_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_prev_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_prev_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> l_prev_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_prev_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data2,
		X_RETURN_STATUS => l_return_status);
        commit;
      end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO purge_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_PURGE')) )
     then

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_prev_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> l_prev_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_prev_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => l_prev_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_prev_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_prev_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_prev_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_prev_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_prev_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> l_prev_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_prev_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data2,
		X_RETURN_STATUS => l_return_status);
        commit;
      end if;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN

  ROLLBACK TO purge_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') ) OR
        ( (l_audit_log_val = 'MINIMAL') AND ( (l_action_key is NULL) OR (l_action_key = 'WORKITEM_PURGE')) )
     then

	     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
	     (
		P_ACTION_KEY => l_action_key,
		P_EVENT_KEY =>	l_event_key,
		P_MODULE => l_module,
		P_WS_CODE => l_curr_ws_code,
		P_APPLICATION_ID => p_application_id,
		P_WORKITEM_PK_ID => p_workitem_pk_id,
		P_WORKITEM_OBJ_CODE => p_workitem_obj_code,
		P_WORK_ITEM_STATUS_PREV => l_prev_status_id,
		P_WORK_ITEM_STATUS_CURR	=> l_prev_status_id,
		P_OWNER_ID_PREV	 => l_prev_owner_id,
		P_OWNER_ID_CURR	=> l_prev_owner_id,
		P_OWNER_TYPE_PREV => l_prev_owner_type,
		P_OWNER_TYPE_CURR => l_prev_owner_type,
		P_ASSIGNEE_ID_PREV => l_prev_assignee_id,
		P_ASSIGNEE_ID_CURR => l_prev_assignee_id,
		P_ASSIGNEE_TYPE_PREV => l_prev_assignee_type,
		P_ASSIGNEE_TYPE_CURR => l_prev_assignee_type,
		P_SOURCE_OBJECT_ID_PREV => l_prev_source_object_id,
		P_SOURCE_OBJECT_ID_CURR => l_prev_source_object_id,
		P_SOURCE_OBJECT_TYPE_CODE_PREV => l_prev_source_object_type_code,
		P_SOURCE_OBJECT_TYPE_CODE_CURR => l_prev_source_object_type_code,
		P_PARENT_WORKITEM_STATUS_PREV => l_parent_status_id,
		P_PARENT_WORKITEM_STATUS_CURR => l_parent_status_id,
		P_PARENT_DIST_STATUS_PREV => l_parent_dist_status,
		P_PARENT_DIST_STATUS_CURR => l_parent_dist_status,
		P_WORKITEM_DIST_STATUS_PREV => l_prev_distribution_status_id,
		P_WORKITEM_DIST_STATUS_CURR => l_prev_distribution_status_id,
		P_PRIORITY_PREV => l_prev_priority_id,
		P_PRIORITY_CURR	=> l_prev_priority_id,
		P_DUE_DATE_PREV	=> l_prev_due_date,
		P_DUE_DATE_CURR	=> l_prev_due_date,
		P_RESCHEDULE_TIME_PREV => l_prev_reschedule_time,
		P_RESCHEDULE_TIME_CURR => l_prev_reschedule_time,
		P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
		P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
		P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
		P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
		P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
		P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
		P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
		P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
		P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
		P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
		P_STATUS => x_return_status,
		P_ERROR_CODE => l_msg_data,
		X_AUDIT_LOG_ID => l_audit_log_id,
		X_MSG_DATA => l_msg_data2,
		X_RETURN_STATUS => l_return_status);
        commit;
      end if;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END PURGE_WR_ITEM;

/**** Wrapper for RESCHEDULE_WORK_ITEM - ER# 4134808****/

PROCEDURE SNOOZE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_work_item_id              IN NUMBER   DEFAULT NULL,
  p_reschedule_time           IN DATE     DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2) AS
BEGIN
  IEU_WR_PUB.RESCHEDULE_UWQM_ITEM
   ( p_api_version,
     p_init_msg_list,
     p_commit,
     p_workitem_obj_code,
     p_workitem_pk_id,
     p_work_item_id,
     p_reschedule_time,
     p_user_id,
     p_login_id,
     x_msg_count,
     x_msg_data,
     x_return_status);
END SNOOZE_UWQM_ITEM;

PROCEDURE DEACTIVATE_WS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

l_api_version CONSTANT NUMBER := 1.0;
l_api_name CONSTANT VARCHAR2(30) := 'DEACTIVATE_WS';

l_miss_param_flag   NUMBER(1) := 0;
l_token_str         VARCHAR2(4000);

l_ws_code     VARCHAR2(32);
l_ws_id	      NUMBER;

CURSOR c_child_worksources IS
  select ws_code
  from  ieu_uwqm_work_sources_b b, ieu_uwqm_ws_assct_props p
  where b.ws_id = p.ws_id
  and   p.parent_ws_id = l_ws_id;

BEGIN

  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
  l_token_str := '';
  SAVEPOINT deactivate_ws_sp;
    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
    THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message list

    IF fnd_api.to_boolean(p_init_msg_list)
    THEN
       FND_MSG_PUB.INITIALIZE;
    END IF;

    -- validate parameters

    if p_ws_code is null
    then
        l_miss_param_flag := 1;
        l_token_str := l_token_str || '  WS_CODE ';
    END IF;

    If (l_miss_param_flag = 1)
    THEN

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_REQUIRED_PARAM_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.DEACTIVATE_WS');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

    END IF;

    IF p_ws_code is not null
    THEN

       BEGIN
         l_not_valid_flag := 'N';
         select ws_code, ws_id
         into l_ws_code, l_ws_id
         from ieu_uwqm_work_sources_b
         where ws_code = p_ws_code
--         and nvl(not_valid_flag, 'N') = 'N';
         and nvl(not_valid_flag, 'N') = l_not_valid_flag;
       EXCEPTION WHEN NO_DATA_FOUND
       THEN
        l_ws_code := '';
       END;


       IF (p_ws_code <> nvl(l_ws_code, '-1'))
       THEN
          l_token_str :=' WS_CODE:'||p_ws_code;
          FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_COMBINATION');
          FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.DEACTIVATE_WS');
          FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
          fnd_msg_pub.ADD;
          fnd_msg_pub.Count_and_Get
          (
           p_count   =>   x_msg_count,
           p_data    =>   x_msg_data
          );

          x_return_status := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;

       ELSIF p_ws_code = l_ws_code
       THEN
  	    l_active_flag := 'N';
          update ieu_uwqm_work_sources_b
          set active_flag = l_active_flag
          where ws_code = p_ws_code;

	  for cur_rec in c_child_worksources
	  loop
	    update ieu_uwqm_work_sources_b
	    set active_flag = l_active_flag
	    where ws_code = cur_rec.ws_code;
	  end loop;

       END IF;

     END IF;

     IF FND_API.TO_BOOLEAN(p_commit)
     THEN
        COMMIT WORK;
     END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO deactivate_ws_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO deactivate_ws_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN

  ROLLBACK TO deactivate_ws_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END DEACTIVATE_WS;

PROCEDURE SYNC_WR_ITEMS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_processing_set_id         IN NUMBER DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'SYNC_WR_ITEMS';

  l_token_str          VARCHAR2(4000);
  l_miss_param_flag    NUMBER(1);

  l_count NUMBER;
  L_MISS_NUM NUMBER;

  TYPE NUMBER_TAB                  IS TABLE OF NUMBER                                       INDEX BY BINARY_INTEGER;
  TYPE DATE_TAB                    IS TABLE OF DATE                                         INDEX BY BINARY_INTEGER;
  TYPE WORKITEM_OBJ_CODE_TAB       IS TABLE OF IEU_UWQM_ITEMS.WORKITEM_OBJ_CODE%TYPE        INDEX BY BINARY_INTEGER;
  TYPE TITLE_TAB                   IS TABLE OF VARCHAR2(4000)                               INDEX BY BINARY_INTEGER;
  TYPE OWNER_TYPE_TAB              IS TABLE OF IEU_UWQM_ITEMS.OWNER_TYPE%TYPE               INDEX BY BINARY_INTEGER;
  TYPE ASSIGNEE_TYPE_TAB           IS TABLE OF IEU_UWQM_ITEMS.ASSIGNEE_TYPE%TYPE            INDEX BY BINARY_INTEGER;
  TYPE SOURCE_OBJECT_TYPE_CODE_TAB IS TABLE OF IEU_UWQM_ITEMS.SOURCE_OBJECT_TYPE_CODE%TYPE  INDEX BY BINARY_INTEGER;
  TYPE OWNER_TYPE_ACTUAL_TAB       IS TABLE OF IEU_UWQM_ITEMS.OWNER_TYPE_ACTUAL%TYPE        INDEX BY BINARY_INTEGER;
  TYPE ASSIGNEE_TYPE_ACTUAL_TAB    IS TABLE OF IEU_UWQM_ITEMS.ASSIGNEE_TYPE_ACTUAL%TYPE     INDEX BY BINARY_INTEGER;
  TYPE IEU_ENUM_TYPE_UUID_TAB      IS TABLE OF IEU_UWQM_ITEMS.IEU_ENUM_TYPE_UUID%TYPE       INDEX BY BINARY_INTEGER;
  TYPE WORK_ITEM_NUMBER_TAB        IS TABLE OF IEU_UWQM_ITEMS.WORK_ITEM_NUMBER%TYPE         INDEX BY BINARY_INTEGER;
  TYPE CHAR_TAB                    IS TABLE OF VARCHAR2(30)                                 INDEX BY BINARY_INTEGER;

  WORKITEM_OBJ_CODE_LIST       WORKITEM_OBJ_CODE_TAB;
  WORKITEM_PK_ID_LIST          NUMBER_TAB;

  TYPE wr_items_rec IS RECORD
  ( WORKITEM_OBJ_CODE_LST        WORKITEM_OBJ_CODE_TAB
  , WORKITEM_PK_ID_LST           NUMBER_TAB
  , STATUS_ID_LIST               NUMBER_TAB
  , PRIORITY_ID_LIST             NUMBER_TAB
  , PRIORITY_LEVEL_LIST          NUMBER_TAB
  , DUE_DATE_LIST                DATE_TAB
  , TITLE_LIST                   TITLE_TAB
  , PARTY_ID_LIST                NUMBER_TAB
  , OWNER_TYPE_LIST              OWNER_TYPE_TAB
  , OWNER_ID_LIST                NUMBER_TAB
  , ASSIGNEE_TYPE_LIST           ASSIGNEE_TYPE_TAB
  , ASSIGNEE_ID_LIST             NUMBER_TAB
  , SOURCE_OBJECT_ID_LIST        NUMBER_TAB
  , SOURCE_OBJECT_TYPE_CODE_LIST SOURCE_OBJECT_TYPE_CODE_TAB
  , OWNER_TYPE_ACTUAL_LIST       OWNER_TYPE_ACTUAL_TAB
  , ASSIGNEE_TYPE_ACTUAL_LIST    ASSIGNEE_TYPE_ACTUAL_TAB
  , APPLICATION_ID_LIST          NUMBER_TAB
  , IEU_ENUM_TYPE_UUID_LIST      IEU_ENUM_TYPE_UUID_TAB
  , WORK_ITEM_NUMBER_LIST        WORK_ITEM_NUMBER_TAB
  , WS_ID_LIST                   NUMBER_TAB
  , DISTRIBUTION_STATUS_ID_LIST  NUMBER_TAB
  , l_ins_flag                   NUMBER_TAB
  );

  l_wr_items_rec          wr_items_rec;

  dml_errors EXCEPTION;
  PRAGMA exception_init(dml_errors, -24381);
  errors number;
  err_flag varchar2(1);

BEGIN
      l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
      l_token_str := '';
      l_not_valid_flag := 'N';
      errors := 0;
      err_flag := 'N';
      l_miss_param_flag := 0;
      L_MISS_NUM := FND_API.G_MISS_NUM;

      SAVEPOINT sync_wr_items_sp;
      x_return_status := fnd_api.g_ret_sts_success;


      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;


      -- Check for NOT NULL columns

      IF ((p_processing_set_id = L_MISS_NUM)  or
        (p_processing_set_id is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || ' PROCESSING_SET_ID ';
      END IF;


      IF ((p_user_id = L_MISS_NUM) or
         (p_user_id is null))
      THEN
          l_miss_param_flag := 1;
          l_token_str := l_token_str || ' USER_ID ';
      END IF;

      If (l_miss_param_flag = 1)
      THEN

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_RQD_VALUE_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEMS');
         FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;

      -- Validate Work Item Status

      l_token_str := '';
      l_count := '';
      WORKITEM_PK_ID_LIST.delete;
      WORKITEM_OBJ_CODE_LIST.delete;

      SELECT Count(*)
      INTO   l_count
      FROM  IEU_UWQM_ITEMS_GTT
      WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID
      AND  WORKITEM_STATUS NOT IN ('OPEN', 'CLOSE', 'DELETE', 'SLEEP');

      IF NVL(l_count, 0) > 0
      THEN

         SELECT   WORKITEM_PK_ID
                , WORKITEM_OBJ_CODE
         BULK COLLECT INTO
                  WORKITEM_PK_ID_LIST
                , WORKITEM_OBJ_CODE_LIST
         FROM  IEU_UWQM_ITEMS_GTT
         WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID
         AND  WORKITEM_STATUS NOT IN ('OPEN', 'CLOSE', 'DELETE', 'SLEEP')
         AND ROWNUM <= 5;

         FOR i IN WORKITEM_PK_ID_LIST.FIRST..WORKITEM_PK_ID_LIST.LAST
         LOOP
          l_token_str := l_token_str||WORKITEM_OBJ_CODE_LIST(i)||'-'||TO_CHAR(WORKITEM_PK_ID_LIST(i))||' ';
         END LOOP;

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_INVALID_STATUS');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEMS');
         FND_MESSAGE.SET_TOKEN('WORKITEM_OBJ_CODE_AND_PK_ID',l_token_str);
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;


      -- Validate object Code, owner_id, owner_type, assignee_id, assignee_type

      l_token_str := '';
      l_count := '';
      WORKITEM_PK_ID_LIST.delete;
      WORKITEM_OBJ_CODE_LIST.delete;

      SELECT count(*)
      INTO   l_count
      FROM   IEU_UWQM_ITEMS_GTT A
      WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
      AND NOT EXISTS
         ( SELECT 1
           FROM JTF_OBJECTS_B
           WHERE OBJECT_CODE = A.WORKITEM_OBJ_CODE );

      IF NVL(l_count, 0) > 0
      THEN
         SELECT   WORKITEM_PK_ID
                , WORKITEM_OBJ_CODE
         BULK COLLECT INTO
                  WORKITEM_PK_ID_LIST
                , WORKITEM_OBJ_CODE_LIST
         FROM   IEU_UWQM_ITEMS_GTT A
         WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
         AND    ROWNUM <= 5
         AND NOT EXISTS
            ( SELECT 1
              FROM JTF_OBJECTS_B
              WHERE OBJECT_CODE = A.WORKITEM_OBJ_CODE );

         FOR i IN WORKITEM_PK_ID_LIST.FIRST..WORKITEM_PK_ID_LIST.LAST
         LOOP
          l_token_str := l_token_str||WORKITEM_OBJ_CODE_LIST(i)||'-'||TO_CHAR(WORKITEM_PK_ID_LIST(i))||' ';
         END LOOP;

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_INVALID_VALUE');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEMS');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','WORKITEM_OBJ_CODE');
         FND_MESSAGE.SET_TOKEN('WORKITEM_OBJ_CODE_AND_PK_ID',l_token_str);
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;


      l_token_str := '';
      l_count := '';
      WORKITEM_PK_ID_LIST.delete;
      WORKITEM_OBJ_CODE_LIST.delete;

      SELECT count(*)
      INTO   l_count
      FROM   IEU_UWQM_ITEMS_GTT A
      WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
      AND NOT EXISTS
         ( SELECT 1
           FROM IEU_UWQM_PRIORITIES_B B
           WHERE B.PRIORITY_CODE = A.PRIORITY_CODE );

      IF nvl(l_count, 0) > 0
      THEN

         SELECT   WORKITEM_PK_ID
                , WORKITEM_OBJ_CODE
         BULK COLLECT INTO
                  WORKITEM_PK_ID_LIST
                , WORKITEM_OBJ_CODE_LIST
         FROM   IEU_UWQM_ITEMS_GTT A
         WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
         AND    ROWNUM <= 5
         AND NOT EXISTS
            ( SELECT 1
              FROM IEU_UWQM_PRIORITIES_B B
              WHERE B.PRIORITY_CODE = A.PRIORITY_CODE );

         FOR i IN WORKITEM_PK_ID_LIST.FIRST..WORKITEM_PK_ID_LIST.LAST
         LOOP
          l_token_str := l_token_str||WORKITEM_OBJ_CODE_LIST(i)||'-'||TO_CHAR(WORKITEM_PK_ID_LIST(i))||' ';
         END LOOP;

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_INVALID_VALUE');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEMS');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','PRIORITY_CODE');
         FND_MESSAGE.SET_TOKEN('WORKITEM_OBJ_CODE_AND_PK_ID',l_token_str);
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
          );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

      END IF;


     -- Set the Distribution states based on Business Rules

     -- Get the Work_source_id

      l_token_str := '';
      l_count := '';
      l_not_valid_flag := 'N';
      WORKITEM_PK_ID_LIST.delete;
      WORKITEM_OBJ_CODE_LIST.delete;

      SELECT count(*)
      INTO   l_count
      FROM   IEU_UWQM_ITEMS_GTT A
      WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
      AND NOT EXISTS
         ( SELECT 1
           FROM IEU_UWQM_WORK_SOURCES_B
           WHERE OBJECT_CODE = A.WORKITEM_OBJ_CODE
           AND NVL(NOT_VALID_FLAG, 'N') = L_NOT_VALID_FLAG );

      IF NVL(l_count, 0) > 0
      THEN

         SELECT   WORKITEM_PK_ID
                , WORKITEM_OBJ_CODE
         BULK COLLECT INTO
                  WORKITEM_PK_ID_LIST
                , WORKITEM_OBJ_CODE_LIST
         FROM   IEU_UWQM_ITEMS_GTT A
         WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
         AND    ROWNUM <= 5
         AND NOT EXISTS
            ( SELECT 1
              FROM IEU_UWQM_WORK_SOURCES_B
              WHERE OBJECT_CODE = A.WORKITEM_OBJ_CODE
              AND NVL(NOT_VALID_FLAG, 'N') = L_NOT_VALID_FLAG );

         FOR i IN WORKITEM_PK_ID_LIST.FIRST..WORKITEM_PK_ID_LIST.LAST
         LOOP
          l_token_str := l_token_str||WORKITEM_OBJ_CODE_LIST(i)||'-'||TO_CHAR(WORKITEM_PK_ID_LIST(i))||' ';
         END LOOP;

         -- Work Source does not exist for this Object Code

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_INVALID_WS');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEMS');
         FND_MESSAGE.SET_TOKEN('WORKITEM_OBJ_CODE_AND_PK_ID',l_token_str);
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;

     END IF;


      -- Set Distribution Status based on these rules
      -- Get the Work_source_id

     UPDATE IEU_UWQM_ITEMS_GTT A
     SET A.WS_ID1 =
         (SELECT B.WS_ID
          FROM IEU_UWQM_WORK_SOURCES_B B
          WHERE  A.WORKITEM_OBJ_CODE =  B.OBJECT_CODE
          AND    NVL(B.NOT_VALID_FLAG, 'N') = L_NOT_VALID_FLAG)
       , A.WS_ID2 =
         (SELECT C.WS_ID
          FROM IEU_UWQM_WORK_SOURCES_B C
          WHERE A.SOURCE_OBJECT_TYPE_CODE = C.OBJECT_CODE
          AND   NVL(C.NOT_VALID_FLAG, 'N') = L_NOT_VALID_FLAG)
     WHERE A.PROCESSING_SET_ID = P_PROCESSING_SET_ID;


     -- Check if Any Work Source Association exists for this combination of Object Code/Source Obj Code

     UPDATE IEU_UWQM_ITEMS_GTT A
     SET A.ASSOCIATION_WS_ID =
         (SELECT B.WS_ID
          FROM   IEU_UWQM_WS_ASSCT_PROPS B
               , IEU_UWQM_WORK_SOURCES_B C
          WHERE B.CHILD_WS_ID = A.WS_ID1
          AND   B.PARENT_WS_ID = A.WS_ID2
          AND   B.WS_ID = C.WS_ID
          AND   NVL(C.NOT_VALID_FLAG, 'N') = L_NOT_VALID_FLAG)
     WHERE A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
     AND   A.WS_ID2 IS NOT NULL;


     -- Get the Distribute_from, Distribute_to

     BEGIN
       l_not_valid_flag := 'N';

       UPDATE IEU_UWQM_ITEMS_GTT A
       SET ( A.DIST_ST_BASED_ON_PARENT_FLAG
           , A.DIST_FROM
           , A.DIST_TO
           ) =
           (SELECT  C.DIST_ST_BASED_ON_PARENT_FLAG
                  , 'GROUP_OWNED'
                  , 'INDIVIDUAL_ASSIGNED'
           FROM   IEU_UWQM_WORK_SOURCES_B B
                , IEU_UWQM_WS_ASSCT_PROPS C
           WHERE A.ASSOCIATION_WS_ID = B.WS_ID
           AND   B.WS_ID = C.WS_ID
           AND   NVL(B.NOT_VALID_FLAG, 'N') = L_NOT_VALID_FLAG)
       WHERE A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
       AND   A.ASSOCIATION_WS_ID IS NOT NULL;

     EXCEPTION
       WHEN OTHERS THEN

         -- Work Source Details does not exist for this Object Code
         l_token_str := '(IEU_UWQ_SYNC_WR_WS_DTLS_NULL) '||sqlcode||' '||sqlerrm;

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_WS_DTLS_NULL');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEMS');
         FND_MESSAGE.SET_TOKEN('DETAILS',l_token_str);
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
     END;


    -- All validations are successful and continue to set the required values

      -- If OWNER_TYPE or ASSIGNEE_TYPE is not RS_GROUP then set it to RS_INDIVIDUAL
      -- Set Work Item Status Id
      -- set PRIORITY_ID and PRIORITY_LEVEL

      UPDATE IEU_UWQM_ITEMS_GTT A
      SET  A.OWNER_TYPE = CASE WHEN (A.OWNER_TYPE_ACTUAL <> 'RS_GROUP' AND A.OWNER_TYPE_ACTUAL <> 'RS_TEAM') THEN 'RS_INDIVIDUAL'
                         ELSE A.OWNER_TYPE_ACTUAL
                         END
          , A.ASSIGNEE_TYPE = CASE WHEN (A.ASSIGNEE_TYPE_ACTUAL <> 'RS_GROUP' AND A.ASSIGNEE_TYPE_ACTUAL <> 'RS_TEAM') THEN 'RS_INDIVIDUAL'
                            ELSE A.ASSIGNEE_TYPE_ACTUAL
                            END
          , A.STATUS_ID = DECODE(A.WORKITEM_STATUS, 'OPEN', 0, 'CLOSE', 3, 'DELETE', 4, 'SLEEP', 5, A.STATUS_ID)
          , ( A.PRIORITY_ID
            , A.PRIORITY_LEVEL
            ) =
            (SELECT  B.PRIORITY_ID
                   , B.PRIORITY_LEVEL
             FROM IEU_UWQM_PRIORITIES_B B
             WHERE A.PRIORITY_CODE =  B.PRIORITY_CODE)
      WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID;


     UPDATE IEU_UWQM_ITEMS_GTT A
     SET   A.DIST_FROM = 'GROUP_OWNED'
         , A.DIST_TO = 'INDIVIDUAL_ASSIGNED'
     WHERE A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
     AND   A.ASSOCIATION_WS_ID IS NULL;

     UPDATE IEU_UWQM_ITEMS_GTT A
     SET A.WS_ID = NVL(A.ASSOCIATION_WS_ID, A.WS_ID1)
     WHERE A.PROCESSING_SET_ID = P_PROCESSING_SET_ID;


      -- If the Distribution State is based on the Parent, then check if the parent is distributed.

     UPDATE IEU_UWQM_ITEMS_GTT A
     SET ( A.PARENT_STATUS_ID
         , A.PARENT_DIST_STATUS_ID
         ) =
           (SELECT   B.STATUS_ID
                   , B.DISTRIBUTION_STATUS_ID
            FROM IEU_UWQM_ITEMS B
            WHERE A.SOURCE_OBJECT_ID = B.WORKITEM_PK_ID
            AND   A.SOURCE_OBJECT_TYPE_CODE = B.WORKITEM_OBJ_CODE)
     WHERE A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
     AND   A.DIST_ST_BASED_ON_PARENT_FLAG = 'Y';


      -- If the parent is not distributed, then this item will be in "On-Hold/Unavailable" status
      -- else set the status based on distribute_from and distribute_to

     UPDATE IEU_UWQM_ITEMS_GTT
     SET   DIST_ID_FLAG =  CASE WHEN DIST_ST_BASED_ON_PARENT_FLAG = 'Y' THEN
                            CASE WHEN PARENT_STATUS_ID = 3 THEN 'T'
                            ELSE CASE WHEN PARENT_DIST_STATUS_ID <> 3 THEN 'F'
                                 ELSE 'T'
                                 END
                            END
                           ELSE 'T'
                           END
     WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID;

     UPDATE IEU_UWQM_ITEMS_GTT
     SET DISTRIBUTION_STATUS_ID = CASE WHEN (DIST_ID_FLAG = 'T') THEN
                                   CASE WHEN (PARENT_DIST_STATUS_ID <> 3) THEN 0
                                   ELSE CASE WHEN (DIST_FROM = 'GROUP_OWNED') AND (DIST_TO = 'INDIVIDUAL_ASSIGNED') THEN
                                         CASE WHEN (OWNER_TYPE = 'RS_GROUP') AND ((ASSIGNEE_TYPE IS NULL)
                                                                         OR (ASSIGNEE_TYPE <> 'RS_INDIVIDUAL')) THEN 1
                                         ELSE CASE WHEN (ASSIGNEE_TYPE = 'RS_INDIVIDUAL') THEN 3
                                              ELSE 0
                                              END
                                         END
                                        ELSE 0
                                        END
                                   END
                                  ELSE 0
                                  END
     WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID;


     BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      l_wr_items_rec.WORKITEM_OBJ_CODE_LST.delete;
      l_wr_items_rec.WORKITEM_PK_ID_LST.delete;
      l_wr_items_rec.STATUS_ID_LIST.delete;
      l_wr_items_rec.PRIORITY_ID_LIST.delete;
      l_wr_items_rec.PRIORITY_LEVEL_LIST.delete;
      l_wr_items_rec.DUE_DATE_LIST.delete;
      l_wr_items_rec.TITLE_LIST.delete;
      l_wr_items_rec.PARTY_ID_LIST.delete;
      l_wr_items_rec.OWNER_TYPE_LIST.delete;
      l_wr_items_rec.OWNER_ID_LIST.delete;
      l_wr_items_rec.ASSIGNEE_TYPE_LIST.delete;
      l_wr_items_rec.ASSIGNEE_ID_LIST.delete;
      l_wr_items_rec.SOURCE_OBJECT_ID_LIST.delete;
      l_wr_items_rec.SOURCE_OBJECT_TYPE_CODE_LIST.delete;
      l_wr_items_rec.OWNER_TYPE_ACTUAL_LIST.delete;
      l_wr_items_rec.ASSIGNEE_TYPE_ACTUAL_LIST.delete;
      l_wr_items_rec.APPLICATION_ID_LIST.delete;
      l_wr_items_rec.IEU_ENUM_TYPE_UUID_LIST.delete;
      l_wr_items_rec.WORK_ITEM_NUMBER_LIST.delete;
      l_wr_items_rec.WS_ID_LIST.delete;
      l_wr_items_rec.DISTRIBUTION_STATUS_ID_LIST.delete;

      SELECT  WORKITEM_OBJ_CODE
            , WORKITEM_PK_ID
            , STATUS_ID
            , PRIORITY_ID
            , PRIORITY_LEVEL
            , DUE_DATE
            , TITLE
            , PARTY_ID
            , OWNER_TYPE
            , OWNER_ID
            , ASSIGNEE_TYPE
            , ASSIGNEE_ID
            , SOURCE_OBJECT_ID
            , SOURCE_OBJECT_TYPE_CODE
            , OWNER_TYPE_ACTUAL
            , ASSIGNEE_TYPE_ACTUAL
            , APPLICATION_ID
            , IEU_ENUM_TYPE_UUID
            , WORK_ITEM_NUMBER
            , WS_ID
            , DISTRIBUTION_STATUS_ID
            , 1
      BULK COLLECT INTO l_wr_items_rec.WORKITEM_OBJ_CODE_LST
            , l_wr_items_rec.WORKITEM_PK_ID_LST
            , l_wr_items_rec.STATUS_ID_LIST
            , l_wr_items_rec.PRIORITY_ID_LIST
            , l_wr_items_rec.PRIORITY_LEVEL_LIST
            , l_wr_items_rec.DUE_DATE_LIST
            , l_wr_items_rec.TITLE_LIST
            , l_wr_items_rec.PARTY_ID_LIST
            , l_wr_items_rec.OWNER_TYPE_LIST
            , l_wr_items_rec.OWNER_ID_LIST
            , l_wr_items_rec.ASSIGNEE_TYPE_LIST
            , l_wr_items_rec.ASSIGNEE_ID_LIST
            , l_wr_items_rec.SOURCE_OBJECT_ID_LIST
            , l_wr_items_rec.SOURCE_OBJECT_TYPE_CODE_LIST
            , l_wr_items_rec.OWNER_TYPE_ACTUAL_LIST
            , l_wr_items_rec.ASSIGNEE_TYPE_ACTUAL_LIST
            , l_wr_items_rec.APPLICATION_ID_LIST
            , l_wr_items_rec.IEU_ENUM_TYPE_UUID_LIST
            , l_wr_items_rec.WORK_ITEM_NUMBER_LIST
            , l_wr_items_rec.WS_ID_LIST
            , l_wr_items_rec.DISTRIBUTION_STATUS_ID_LIST
            , l_wr_items_rec.l_ins_flag
      FROM IEU_UWQM_ITEMS_GTT
      WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID;

      IF l_wr_items_rec.WORKITEM_OBJ_CODE_LST.FIRST IS NOT NULL THEN
       FORALL i IN l_wr_items_rec.WORKITEM_OBJ_CODE_LST.FIRST..l_wr_items_rec.WORKITEM_OBJ_CODE_LST.LAST SAVE EXCEPTIONS
        INSERT INTO IEU_UWQM_ITEMS
         ( WORK_ITEM_ID
         , OBJECT_VERSION_NUMBER
         , CREATED_BY
         , CREATION_DATE
         , LAST_UPDATED_BY
         , LAST_UPDATE_DATE
         , LAST_UPDATE_LOGIN
         , WORKITEM_OBJ_CODE
         , WORKITEM_PK_ID
         , WORK_ITEM_NUMBER
         , STATUS_ID
         , PRIORITY_ID
         , PRIORITY_LEVEL
         , DUE_DATE
         , TITLE
         , PARTY_ID
         , OWNER_ID
         , OWNER_TYPE
         , ASSIGNEE_ID
         , ASSIGNEE_TYPE
         , OWNER_TYPE_ACTUAL
         , ASSIGNEE_TYPE_ACTUAL
         , SOURCE_OBJECT_ID
         , SOURCE_OBJECT_TYPE_CODE
         , APPLICATION_ID
         , IEU_ENUM_TYPE_UUID
         , RESCHEDULE_TIME
         , STATUS_UPDATE_USER_ID
         , WS_ID
         , DISTRIBUTION_STATUS_ID
         ) VALUES
         ( IEU_UWQM_ITEMS_S1.NEXTVAL
         , 1
         , P_USER_ID
         , SYSDATE
         , P_USER_ID
         , SYSDATE
         , P_LOGIN_ID
         , l_wr_items_rec.WORKITEM_OBJ_CODE_LST(i)
         , l_wr_items_rec.WORKITEM_PK_ID_LST(i)
         , l_wr_items_rec.WORK_ITEM_NUMBER_LIST(i)
         , l_wr_items_rec.STATUS_ID_LIST(i)
         , l_wr_items_rec.PRIORITY_ID_LIST(i)
         , l_wr_items_rec.PRIORITY_LEVEL_LIST(i)
         , l_wr_items_rec.DUE_DATE_LIST(i)
         , l_wr_items_rec.TITLE_LIST(i)
         , l_wr_items_rec.PARTY_ID_LIST(i)
         , l_wr_items_rec.OWNER_ID_LIST(i)
         , l_wr_items_rec.OWNER_TYPE_LIST(i)
         , l_wr_items_rec.ASSIGNEE_ID_LIST(i)
         , l_wr_items_rec.ASSIGNEE_TYPE_LIST(i)
         , l_wr_items_rec.OWNER_TYPE_ACTUAL_LIST(i)
         , l_wr_items_rec.ASSIGNEE_TYPE_ACTUAL_LIST(i)
         , l_wr_items_rec.SOURCE_OBJECT_ID_LIST(i)
         , l_wr_items_rec.SOURCE_OBJECT_TYPE_CODE_LIST(i)
         , l_wr_items_rec.APPLICATION_ID_LIST(i)
         , l_wr_items_rec.IEU_ENUM_TYPE_UUID_LIST(i)
         , SYSDATE
         , P_USER_ID
         , l_wr_items_rec.WS_ID_LIST(i)
         , l_wr_items_rec.DISTRIBUTION_STATUS_ID_LIST(i)
         );
      END IF;
     EXCEPTION
      WHEN dml_errors THEN
       errors := SQL%BULK_EXCEPTIONS.COUNT;
	 FOR i IN 1..errors LOOP
	  l_wr_items_rec.l_ins_flag(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) := 0;

        IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE <> 1 then
         err_flag := 'Y';

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_INSERT_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_WR_PUB.SYNC_WR_ITEMS');
         FND_MESSAGE.SET_TOKEN('DETAILS', 'WORKITEM_PK_ID:'||l_wr_items_rec.WORKITEM_PK_ID_LST(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
         fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
             (
             p_count   =>   x_msg_count,
             p_data    =>   x_msg_data
             );

        END IF;
	 END LOOP;

       IF err_flag = 'Y' THEN
         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
       END IF;

       if (errors > 0) then
        BEGIN
         FORALL i in l_wr_items_rec.WORKITEM_OBJ_CODE_LST.FIRST..l_wr_items_rec.WORKITEM_OBJ_CODE_LST.LAST SAVE EXCEPTIONS
          UPDATE IEU_UWQM_ITEMS
          SET   OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
              , CREATED_BY = P_USER_ID
              , CREATION_DATE = SYSDATE
              , LAST_UPDATED_BY = P_USER_ID
              , LAST_UPDATE_DATE = SYSDATE
              , LAST_UPDATE_LOGIN = P_LOGIN_ID
              , STATUS_UPDATE_USER_ID = P_USER_ID
              , RESCHEDULE_TIME = SYSDATE
              , STATUS_ID = l_wr_items_rec.STATUS_ID_LIST(i)
              , PRIORITY_ID = l_wr_items_rec.PRIORITY_ID_LIST(i)
              , PRIORITY_LEVEL = l_wr_items_rec.PRIORITY_LEVEL_LIST(i)
              , DUE_DATE = l_wr_items_rec.DUE_DATE_LIST(i)
              , TITLE = l_wr_items_rec.TITLE_LIST(i)
              , PARTY_ID = l_wr_items_rec.PARTY_ID_LIST(i)
              , OWNER_TYPE = l_wr_items_rec.OWNER_TYPE_LIST(i)
              , OWNER_ID = l_wr_items_rec.OWNER_ID_LIST(i)
              , ASSIGNEE_TYPE = l_wr_items_rec.ASSIGNEE_TYPE_LIST(i)
              , ASSIGNEE_ID = l_wr_items_rec.ASSIGNEE_ID_LIST(i)
              , SOURCE_OBJECT_ID = l_wr_items_rec.SOURCE_OBJECT_ID_LIST(i)
              , SOURCE_OBJECT_TYPE_CODE = l_wr_items_rec.SOURCE_OBJECT_TYPE_CODE_LIST(i)
              , OWNER_TYPE_ACTUAL = l_wr_items_rec.OWNER_TYPE_ACTUAL_LIST(i)
              , ASSIGNEE_TYPE_ACTUAL = l_wr_items_rec.ASSIGNEE_TYPE_ACTUAL_LIST(i)
              , APPLICATION_ID = l_wr_items_rec.APPLICATION_ID_LIST(i)
              , IEU_ENUM_TYPE_UUID = l_wr_items_rec.IEU_ENUM_TYPE_UUID_LIST(i)
              , WORK_ITEM_NUMBER = l_wr_items_rec.WORK_ITEM_NUMBER_LIST(i)
              , WS_ID = l_wr_items_rec.WS_ID_LIST(i)
              , DISTRIBUTION_STATUS_ID = l_wr_items_rec.DISTRIBUTION_STATUS_ID_LIST(i)
          WHERE WORKITEM_OBJ_CODE = l_wr_items_rec.WORKITEM_OBJ_CODE_LST(i)
          AND WORKITEM_PK_ID = l_wr_items_rec.WORKITEM_PK_ID_LST(i)
  	    AND l_wr_items_rec.l_ins_flag(i) = 0;
	  EXCEPTION
	   WHEN dml_errors THEN
          errors := SQL%BULK_EXCEPTIONS.COUNT;

	    FOR i IN 1..errors LOOP
           fnd_file.new_line(FND_FILE.LOG, 1);
           FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_UPDATE_FAILED');
           FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_WR_PUB.SYNC_WR_ITEMS');
           FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_wr_items_rec.WORKITEM_PK_ID_LST(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

           fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
           fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

           fnd_msg_pub.ADD;
           fnd_msg_pub.Count_and_Get
           (
           p_count   =>   x_msg_count,
           p_data    =>   x_msg_data
           );
          END LOOP;

          x_return_status := fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;
	  END;
       end if;

       l_wr_items_rec.WORKITEM_OBJ_CODE_LST.delete;
       l_wr_items_rec.WORKITEM_PK_ID_LST.delete;
       l_wr_items_rec.STATUS_ID_LIST.delete;
       l_wr_items_rec.PRIORITY_ID_LIST.delete;
       l_wr_items_rec.PRIORITY_LEVEL_LIST.delete;
       l_wr_items_rec.DUE_DATE_LIST.delete;
       l_wr_items_rec.TITLE_LIST.delete;
       l_wr_items_rec.PARTY_ID_LIST.delete;
       l_wr_items_rec.OWNER_TYPE_LIST.delete;
       l_wr_items_rec.OWNER_ID_LIST.delete;
       l_wr_items_rec.ASSIGNEE_TYPE_LIST.delete;
       l_wr_items_rec.ASSIGNEE_ID_LIST.delete;
       l_wr_items_rec.SOURCE_OBJECT_ID_LIST.delete;
       l_wr_items_rec.SOURCE_OBJECT_TYPE_CODE_LIST.delete;
       l_wr_items_rec.OWNER_TYPE_ACTUAL_LIST.delete;
       l_wr_items_rec.ASSIGNEE_TYPE_ACTUAL_LIST.delete;
       l_wr_items_rec.APPLICATION_ID_LIST.delete;
       l_wr_items_rec.IEU_ENUM_TYPE_UUID_LIST.delete;
       l_wr_items_rec.WORK_ITEM_NUMBER_LIST.delete;
       l_wr_items_rec.WS_ID_LIST.delete;
       l_wr_items_rec.DISTRIBUTION_STATUS_ID_LIST.delete;
     END;

     IF FND_API.TO_BOOLEAN( p_commit ) THEN
      COMMIT WORK;
     END IF;


EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO sync_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO sync_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN
  x_msg_data := sqlcode||' '||sqlerrm;

  ROLLBACK TO sync_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  FND_FILE.PUT_LINE(FND_FILE.LOG, x_msg_data);
  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;
END SYNC_WR_ITEMS;

PROCEDURE SYNC_ASSCT_TASK_WR_ITEMS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'SYNC_ASSCT_TASK_WR_ITEMS';

  l_token_str         VARCHAR2(4000);

  l_ws_id             NUMBER;
  l_parent_ws_id      NUMBER;
  l_child_ws_id       NUMBER;
  l_parent_obj_code   VARCHAR2(500);
  l_child_obj_code    VARCHAR2(500);
  l_ws_type           VARCHAR2(500);
  l_obj_code          VARCHAR2(500);
  l_dist_st_based_on_parent  VARCHAR2(5);
  l_tasks_rules_func varchar2(256);

  l_msg_count      number;
  l_msg_data       VARCHAR2(4000);
  l_return_status  varchar2(1);
  l_error_count    number;

  cursor c_task(p_source_object_type_code in varchar2) is
   select  /*+ ordered parallel(tb) parallel(tt) use_nl(tp,ip,sts_b) */
           tb.task_id
         , tb.task_priority_id
         , tp.importance_level
         , decode(tb.date_selected, 'P', tb.planned_end_date, 'A', tb.actual_end_date, 'S', tb.scheduled_end_date, null, tb.scheduled_end_date) due_date
         , substr(tt.task_name,1,1990) task_name
         , tb.customer_id
         , tb.owner_type_code
         , tb.owner_id
         , tb.source_object_id
         , tb.source_object_type_code
         , tb.task_number
         , tb.planned_start_date
         , tb.planned_end_date
         , tb.actual_start_date
         , tb.actual_end_date
         , tb.scheduled_start_date
         , tb.scheduled_end_date
         , tb.task_type_id
         , ip.priority_code
         , tb.date_selected
         , decode(nvl(sts_b.on_hold_flag, 'N'), 'Y', 'SLEEP', 'OPEN') workitem_status
         , tb.task_status_id
  from   jtf_tasks_b tb
       , jtf_tasks_tl tt
       , jtf_task_priorities_vl tp
       , ieu_uwqm_priorities_b ip
       , jtf_task_statuses_b sts_b
  where tb.entity = 'TASK'
  and nvl(tb.deleted_flag, 'N') = 'N'
  and tb.task_id = tt.task_id
  and tt.language = userenv('LANG')
  and tp.task_priority_id = nvl(tb.task_priority_id, 4)
  and least(tp.importance_level, 4) = ip.priority_level
  and tb.open_flag = 'Y'
  and tb.task_status_id = sts_b.task_status_id
  and tb.source_object_type_code = p_source_object_type_code;

  TYPE NUMBER_TAB                  IS TABLE OF NUMBER                                       INDEX BY BINARY_INTEGER;
  TYPE DATE_TAB                    IS TABLE OF DATE                                         INDEX BY BINARY_INTEGER;
  TYPE TITLE_TAB                   IS TABLE OF VARCHAR2(4000)                               INDEX BY BINARY_INTEGER;
  TYPE WORK_ITEM_NUMBER_TAB        IS TABLE OF IEU_UWQM_ITEMS.WORK_ITEM_NUMBER%TYPE         INDEX BY BINARY_INTEGER;
  TYPE CHAR_TAB                    IS TABLE OF VARCHAR2(50)                                 INDEX BY BINARY_INTEGER;


  TYPE ws_details_rec IS RECORD
  ( WORKITEM_PK_ID_LIST          NUMBER_TAB
  , TASK_PRIORITY_ID_LIST        NUMBER_TAB
  , IMPORTANCE_LEVEL_LIST        NUMBER_TAB
  , DUE_DATE_LIST                DATE_TAB
  , TITLE_LIST                   TITLE_TAB
  , PARTY_ID_LIST                NUMBER_TAB
  , OWNER_TYPE_LIST              CHAR_TAB
  , OWNER_ID_LIST                NUMBER_TAB
  , SOURCE_OBJECT_ID_LIST        NUMBER_TAB
  , SOURCE_OBJECT_TYPE_CODE_LIST CHAR_TAB
  , WORK_ITEM_NUMBER_LIST        WORK_ITEM_NUMBER_TAB
  , PLANNED_START_DATE_LIST      DATE_TAB
  , PLANNED_END_DATE_LIST        DATE_TAB
  , ACTUAL_START_DATE_LIST       DATE_TAB
  , ACTUAL_END_DATE_LIST         DATE_TAB
  , SCHEDULED_START_DATE_LIST    DATE_TAB
  , SCHEDULED_END_DATE_LIST      DATE_TAB
  , TASK_TYPE_ID_LIST            NUMBER_TAB
  , PRIORITY_CODE_LIST           CHAR_TAB
  , DATE_SELECTED_LIST           CHAR_TAB
  , WORKITEM_STATUS_LIST         CHAR_TAB
  , STATUS_ID                    NUMBER_TAB
  );

  l_ws_details_rec          ws_details_rec;

  dml_errors EXCEPTION;
  PRAGMA exception_init(dml_errors, -24381);
  errors number;
  l_limit NUMBER;
  l_processing_set_id NUMBER;
  l_active_flag    varchar2(1);
  l_ws_name varchar2(1000);
  l_parent_ws_name varchar2(1000);

  CURSOR c_task_status(p_source_object_type_code in varchar2) IS
   SELECT TASK_ID,
          DECODE(DELETED_FLAG, 'Y', 4, 3) "STATUS_ID"
   FROM JTF_TASKS_B
   WHERE SOURCE_OBJECT_TYPE_CODE = p_source_object_type_code
   AND ((OPEN_FLAG = 'N' AND DELETED_FLAG = 'N') OR (DELETED_FLAG = 'Y'))
   AND ENTITY = 'TASK';

  TYPE status_rec is RECORD
  (
	  l_task_id_list		NUMBER_TAB,
	  l_status_id_list		NUMBER_TAB
  );

  l_task_status_rec status_rec;
  l_done       BOOLEAN;

BEGIN
    l_error_count := 0;
    l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
    l_token_str := '';
    l_limit := 2000;

    SAVEPOINT sync_assct_task_wr_items_sp;

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;


     -- Set the Distribution states based on Business Rules

     -- Get the Work_source_id

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_id, ws_type, object_code
       into   l_ws_id, l_ws_type, l_obj_code
       from   ieu_uwqm_work_sources_b
       where  ws_code = p_ws_code
       and nvl(not_valid_flag, 'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;

            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;

     if (l_ws_type = 'PRIMARY')
     then
            -- The Sync script works only for Association Work Source
            -- If a primary Work Source is passed then it will throw an exception and exit
            -- Work Source does not exist for this Object Code
            l_token_str := 'WORK_SOURCE:' ||p_ws_code;

            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_INVALID_WORK_SOURCE');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;


     elsif (l_ws_type = 'ASSOCIATION')
     then
        BEGIN

           SELECT parent_ws_id, child_ws_id, dist_st_based_on_parent_flag , tasks_rules_function
           INTO   l_parent_ws_id, l_child_ws_id, l_dist_st_based_on_parent , l_tasks_rules_func
           FROM   IEU_UWQM_WS_ASSCT_PROPS
           WHERE  ws_id = l_ws_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;

            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

        BEGIN
           l_not_valid_flag := 'N';
           SELECT object_code, NVL(active_flag, 'N')
           INTO   l_parent_obj_code, l_active_flag
           FROM   IEU_UWQM_WORK_SOURCES_B
           WHERE  ws_id = l_parent_ws_id
           and nvl(not_valid_flag, 'N') = l_not_valid_flag;

           IF l_active_flag = 'N' THEN
            BEGIN
             SELECT ws_name
             INTO   l_ws_name
             FROM IEU_UWQM_WORK_SOURCES_TL
             WHERE ws_id = l_ws_id
             AND language = userenv('LANG');
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
              l_token_str := 'WS_CODE: '||p_ws_code;

              fnd_file.new_line(FND_FILE.LOG, 1);
              FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
              FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
              FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
              fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

              fnd_msg_pub.ADD;
              fnd_msg_pub.Count_and_Get
              (
                 p_count   =>   x_msg_count,
                 p_data    =>   x_msg_data
              );

              RAISE fnd_api.g_exc_error;
            END;

            BEGIN
             SELECT ws_name
             INTO   l_parent_ws_name
             FROM IEU_UWQM_WORK_SOURCES_TL
             WHERE ws_id = l_parent_ws_id
             AND language = userenv('LANG');
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
              l_token_str := 'WS_CODE: '||p_ws_code;

              fnd_file.new_line(FND_FILE.LOG, 1);
              FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
              FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
              FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
              fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

              fnd_msg_pub.ADD;
              fnd_msg_pub.Count_and_Get
              (
                 p_count   =>   x_msg_count,
                 p_data    =>   x_msg_data
              );

              RAISE fnd_api.g_exc_error;
            END;


            -- The Sync script works only if Parent Work Source is ACTIVE
            -- Else it will throw an exception and exit

            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_PRNT_WS_INACTIVE');
            FND_MESSAGE.SET_TOKEN('PACKAGE.PROCEDURE','IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
            FND_MESSAGE.SET_TOKEN('WS_NAME', l_ws_name);
            FND_MESSAGE.SET_TOKEN('PRIMARY_WS_NAME', l_parent_ws_name);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

           END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;

            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

        BEGIN
           l_not_valid_flag := 'N';
           SELECT object_code
           INTO   l_child_obj_code
           FROM   IEU_UWQM_WORK_SOURCES_B
           WHERE  ws_id = l_child_ws_id
           and nvl(not_valid_flag, 'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;

            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

     end if;

      if (l_ws_type = 'ASSOCIATION')
      then

          select IEU_UWQM_ITEMS_GTT_S1.NEXTVAL into l_processing_set_id from dual;

           open c_task(l_parent_obj_code);
           loop

              delete from IEU_UWQM_ITEMS_GTT;
              l_ws_details_rec.WORKITEM_PK_ID_LIST.delete;
              l_ws_details_rec.TASK_PRIORITY_ID_LIST.delete;
              l_ws_details_rec.IMPORTANCE_LEVEL_LIST.delete;
              l_ws_details_rec.DUE_DATE_LIST.delete;
              l_ws_details_rec.TITLE_LIST.delete;
              l_ws_details_rec.PARTY_ID_LIST.delete;
              l_ws_details_rec.OWNER_TYPE_LIST.delete;
              l_ws_details_rec.OWNER_ID_LIST.delete;
              l_ws_details_rec.SOURCE_OBJECT_ID_LIST.delete;
              l_ws_details_rec.SOURCE_OBJECT_TYPE_CODE_LIST.delete;
              l_ws_details_rec.WORK_ITEM_NUMBER_LIST.delete;
              l_ws_details_rec.PLANNED_START_DATE_LIST.delete;
              l_ws_details_rec.PLANNED_END_DATE_LIST.delete;
              l_ws_details_rec.ACTUAL_START_DATE_LIST.delete;
              l_ws_details_rec.ACTUAL_END_DATE_LIST.delete;
              l_ws_details_rec.SCHEDULED_START_DATE_LIST.delete;
              l_ws_details_rec.SCHEDULED_END_DATE_LIST.delete;
              l_ws_details_rec.TASK_TYPE_ID_LIST.delete;
              l_ws_details_rec.PRIORITY_CODE_LIST.delete;
              l_ws_details_rec.DATE_SELECTED_LIST.delete;
              l_ws_details_rec.WORKITEM_STATUS_LIST.delete;
              l_ws_details_rec.STATUS_ID.delete;

              FETCH c_task BULK COLLECT INTO
                l_ws_details_rec.WORKITEM_PK_ID_LIST
              , l_ws_details_rec.TASK_PRIORITY_ID_LIST
              , l_ws_details_rec.IMPORTANCE_LEVEL_LIST
              , l_ws_details_rec.DUE_DATE_LIST
              , l_ws_details_rec.TITLE_LIST
              , l_ws_details_rec.PARTY_ID_LIST
              , l_ws_details_rec.OWNER_TYPE_LIST
              , l_ws_details_rec.OWNER_ID_LIST
              , l_ws_details_rec.SOURCE_OBJECT_ID_LIST
              , l_ws_details_rec.SOURCE_OBJECT_TYPE_CODE_LIST
              , l_ws_details_rec.WORK_ITEM_NUMBER_LIST
              , l_ws_details_rec.PLANNED_START_DATE_LIST
              , l_ws_details_rec.PLANNED_END_DATE_LIST
              , l_ws_details_rec.ACTUAL_START_DATE_LIST
              , l_ws_details_rec.ACTUAL_END_DATE_LIST
              , l_ws_details_rec.SCHEDULED_START_DATE_LIST
              , l_ws_details_rec.SCHEDULED_END_DATE_LIST
              , l_ws_details_rec.TASK_TYPE_ID_LIST
              , l_ws_details_rec.PRIORITY_CODE_LIST
              , l_ws_details_rec.DATE_SELECTED_LIST
              , l_ws_details_rec.WORKITEM_STATUS_LIST
              , l_ws_details_rec.STATUS_ID
              LIMIT l_limit;


              IF l_ws_details_rec.WORKITEM_PK_ID_LIST.FIRST IS NOT NULL THEN

              BEGIN
               FORALL i IN l_ws_details_rec.WORKITEM_PK_ID_LIST.FIRST..l_ws_details_rec.WORKITEM_PK_ID_LIST.LAST SAVE EXCEPTIONS
                Insert into  ieu_uwqm_items_gtt
                ( PROCESSING_SET_ID
                , WORKITEM_OBJ_CODE
                , WORKITEM_PK_ID
                , STATUS_ID
                , DUE_DATE
                , TITLE
                , PARTY_ID
                , OWNER_ID
                , SOURCE_OBJECT_ID
                , SOURCE_OBJECT_TYPE_CODE
                , OWNER_TYPE_ACTUAL
                , APPLICATION_ID
                , IEU_ENUM_TYPE_UUID
                , WORK_ITEM_NUMBER
                , WORKITEM_STATUS
                , PRIORITY_CODE
                , PLANNED_START_DATE
                , PLANNED_END_DATE
                , ACTUAL_START_DATE
                , ACTUAL_END_DATE
                , SCHEDULED_START_DATE
                , SCHEDULED_END_DATE
                , DATE_SELECTED
                , TASK_TYPE_ID
                , TASK_PRIORITY_ID
                , UWQ_DEF_WORK_ITEM_STATUS
                , UWQ_DEF_PRIORITY_CODE
                , UWQ_DEF_DUE_DATE
                , UWQ_DEF_IEU_ENUM_TYPE_UUID
                )
                values
                ( l_processing_set_id
                , l_child_obj_code
                , l_ws_details_rec.WORKITEM_PK_ID_LIST(i)
                , l_ws_details_rec.STATUS_ID(i)
                , l_ws_details_rec.DUE_DATE_LIST(i)
                , l_ws_details_rec.TITLE_LIST(i)
                , l_ws_details_rec.PARTY_ID_LIST(i)
                , l_ws_details_rec.OWNER_ID_LIST(i)
                , l_ws_details_rec.SOURCE_OBJECT_ID_LIST(i)
                , l_ws_details_rec.SOURCE_OBJECT_TYPE_CODE_LIST(i)
                , l_ws_details_rec.OWNER_TYPE_LIST(i)
                , 696
                , 'TASKS'
                , l_ws_details_rec.WORK_ITEM_NUMBER_LIST(i)
                , l_ws_details_rec.WORKITEM_STATUS_LIST(i)
                , l_ws_details_rec.PRIORITY_CODE_LIST(i)
                , l_ws_details_rec.PLANNED_START_DATE_LIST(i)
                , l_ws_details_rec.PLANNED_END_DATE_LIST(i)
                , l_ws_details_rec.ACTUAL_START_DATE_LIST(i)
                , l_ws_details_rec.ACTUAL_END_DATE_LIST(i)
                , l_ws_details_rec.SCHEDULED_START_DATE_LIST(i)
                , l_ws_details_rec.SCHEDULED_END_DATE_LIST(i)
                , l_ws_details_rec.DATE_SELECTED_LIST(i)
                , l_ws_details_rec.TASK_TYPE_ID_LIST(i)
                , l_ws_details_rec.TASK_PRIORITY_ID_LIST(i)
                , l_ws_details_rec.WORKITEM_STATUS_LIST(i)
                , l_ws_details_rec.PRIORITY_CODE_LIST(i)
                , l_ws_details_rec.DUE_DATE_LIST(i)
                , 'TASKS'
                );

	        EXCEPTION
               WHEN dml_errors THEN
                errors := SQL%BULK_EXCEPTIONS.COUNT;

      	       FOR i IN 1..errors LOOP

                   --** checking for error threshold **--

                   l_error_count := l_error_count + 1;
                   IF l_error_count > 1000 THEN
                      FND_MESSAGE.SET_NAME('IEU', 'IEU_ERROR_THRESHOLD');
                      FND_MESSAGE.SET_TOKEN('ERROR_COUNT', '1000');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );

                   RAISE fnd_api.g_exc_error;
                   END IF;
                 fnd_file.new_line(FND_FILE.LOG, 1);
                 FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_INSERT_FAILED');
                 FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
                 FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_ws_details_rec.WORKITEM_PK_ID_LIST(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                 fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                 fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

                 fnd_msg_pub.ADD;
                 fnd_msg_pub.Count_and_Get
                 (
                 p_count   =>   x_msg_count,
                 p_data    =>   x_msg_data
                 );
               END LOOP;

               -- RAISE fnd_api.g_exc_error;
	        END;
              END IF;

              l_msg_count     := '';
              l_msg_data      := '';
              l_return_status := '';

              BEGIN
		update ieu_uwqm_items_gtt gtt
		set due_date = (select booking_end_date
		from jtf_task_all_assignments asg
		where asg.task_id = gtt.workitem_pk_id
		and asg.assignee_role= 'OWNER');
              EXCEPTION
	         WHEN OTHERS THEN
			 fnd_file.new_line(FND_FILE.LOG, 1);
			 FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_UPDATE_FAILED');
			 FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
			 FND_MESSAGE.SET_TOKEN('DETAILS', sqlcode||' - '||sqlerrm);

			 fnd_file.put_line(FND_FILE.LOG, sqlcode||' - '||sqlerrm);
			 fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

			 fnd_msg_pub.ADD;
			 fnd_msg_pub.Count_and_Get
			 (
			 p_count   =>   x_msg_count,
			 p_data    =>   x_msg_data
			 );

			RAISE fnd_api.g_exc_error;
              END;


              if l_tasks_rules_func is not null
              then

                   execute immediate
                   'BEGIN '||l_tasks_rules_func ||' ( :1, :2, :3, :4); END ; '
                   USING IN l_processing_set_id, OUT l_msg_count, OUT l_msg_data, OUT l_return_status;
              else
                   IEU_WR_PUB.IEU_DEF_TASKS_RULES_FUNC (
                         p_processing_set_id => L_PROCESSING_SET_ID,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data,
                         x_return_status => l_return_status);

              end if;


           exit when c_task%notfound;

           end loop;
           close c_task;

         -- Update Close and Delete Statuses

         open c_task_status(l_parent_obj_code);
	 loop

	     FETCH c_task_status
	     BULK COLLECT INTO
		  l_task_status_rec.l_task_id_list,
		  l_task_status_rec.l_status_id_list
             LIMIT l_limit;

	     l_done := c_task_status%NOTFOUND;

	     BEGIN
	--	fnd_file.put_line(FND_FILE.LOG,'Begin update');
		     FORALL i in 1..l_task_status_rec.l_task_id_list.COUNT SAVE EXCEPTIONS
			update IEU_UWQM_ITEMS
			set	status_id = l_task_status_rec.l_status_id_list(i),
         			LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
	        		LAST_UPDATE_DATE       = SYSDATE,
		        	LAST_UPDATE_LOGIN      = FND_GLOBAL.LOGIN_ID
			where   workitem_obj_code = 'TASK'
                        and     workitem_pk_id = l_task_status_rec.l_task_id_list(i)
                        and     source_object_type_code = l_parent_obj_code;

	     EXCEPTION
		  WHEN dml_errors THEN
		   errors := SQL%BULK_EXCEPTIONS.COUNT;
		   FOR i IN 1..errors LOOP

                   --** checking for error threshold **--

                   l_error_count := l_error_count + 1;
                   IF l_error_count > 1000 THEN
                      FND_MESSAGE.SET_NAME('IEU', 'IEU_ERROR_THRESHOLD');
                      FND_MESSAGE.SET_TOKEN('ERROR_COUNT', '1000');
                      FND_MESSAGE.SET_TOKEN('WS_CODE', 'TASK');
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );

                   RAISE fnd_api.g_exc_error;
                   END IF;

                       fnd_file.new_line(FND_FILE.LOG, 1);
                       FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
                       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_WR_PUB.SYNC_ASSCT_TASK_WR_ITEMS');
                       FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_task_status_rec.l_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                      fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );
                    END LOOP;
                --    RAISE fnd_api.g_exc_error;
	     END;

             l_task_status_rec.l_task_id_list.DELETE;
             l_task_status_rec.l_status_id_list.DELETE;

	     exit when (l_done);

	   end loop;

	   close c_task_status;

      end if;

      IF l_return_status = 'E' THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = 'U' THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF FND_API.TO_BOOLEAN( p_commit ) THEN
       COMMIT WORK;
      END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO sync_assct_task_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO sync_assct_task_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN
  x_msg_data := sqlcode||' '||sqlerrm;

  ROLLBACK TO sync_assct_task_wr_items_sp;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  FND_FILE.PUT_LINE(FND_FILE.LOG, x_msg_data);
  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END SYNC_ASSCT_TASK_WR_ITEMS;

PROCEDURE IEU_DEF_TASKS_RULES_FUNC
( P_PROCESSING_SET_ID IN              NUMBER DEFAULT NULL,
  X_MSG_COUNT         OUT NOCOPY      NUMBER,
  X_MSG_DATA          OUT NOCOPY      VARCHAR2,
  X_RETURN_STATUS     OUT NOCOPY      VARCHAR2) AS

       cursor c_task_asg(p_processing_set_id in number) is
        SELECT resource_id, WORKITEM_PK_ID, resource_type_code
        from (SELECT GTT.WORKITEM_PK_ID, asg.resource_id, asg.resource_type_code,
                     max(asg.last_update_date) over (partition by asg.task_id) max_update_date, asg.last_update_date
                 FROM IEU_UWQM_ITEMS_GTT GTT, JTF_TASK_ASSIGNMENTS ASG
                 WHERE GTT.PROCESSING_SET_ID = P_PROCESSING_SET_ID
                 AND GTT.WORKITEM_PK_ID = ASG.TASK_ID
                 and GTT.OWNER_TYPE_ACTUAL = 'RS_GROUP'
                 and asg.resource_type_code not in ('RS_GROUP', 'RS_TEAM')
                 and asg.assignee_role = 'ASSIGNEE'
                 and exists
                 (SELECT /*+ index(a,JTF_RS_GROUP_MEMBERS_N1) */ null
                    FROM JTF_RS_GROUP_MEMBERS a
                   WHERE a.group_id= GTT.owner_id
                   and a.RESOURCE_ID = asg.resource_id
                   AND NVL(DELETE_FLAG,'N') <> 'Y' )
                 and exists
                 (select  1
                  from jtf_task_statuses_b sts
                  where sts.task_status_id = asg.assignment_status_id
                  and (nvl(sts.closed_flag, 'N') = 'N'
                  and nvl(sts.completed_flag, 'N') = 'N'
                  and nvl(sts.cancelled_flag, 'N') = 'N'
                  and nvl(sts.rejected_flag, 'N') = 'N'))) a
        where a.last_update_date = a.max_update_date;


     TYPE NUMBER_TBL   is TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
     TYPE DATE_TBL     is TABLE OF DATE          INDEX BY BINARY_INTEGER;
     TYPE VARCHAR2_TBL is TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;

     TYPE task_asg_rec is RECORD
     (
	  l_asg_id_list			 NUMBER_TBL,
	  l_asg_task_id_list		 NUMBER_TBL,
	  l_asg_type_act_list		 VARCHAR2_TBL
     );

     l_task_asg_rec task_asg_rec;

     dml_errors EXCEPTION;
     PRAGMA exception_init(dml_errors, -24381);
     errors number;

     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
     l_return_status VARCHAR2(1);

  BEGIN
        l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');

        errors := 0;
        l_return_status := FND_API.G_RET_STS_SUCCESS;

	  open c_task_asg (p_processing_set_id);

	     FETCH c_task_asg
  	     BULK COLLECT INTO
		  l_task_asg_rec.l_asg_id_list,
		  l_task_asg_rec.l_asg_task_id_list,
		  l_task_asg_rec.l_asg_type_act_list;

	     BEGIN
		     FORALL i in 1..l_task_asg_rec.l_asg_task_id_list.COUNT SAVE EXCEPTIONS
			update IEU_UWQM_ITEMS_GTT
			set	assignee_id = l_task_asg_rec.l_asg_id_list(i),
				assignee_type_actual = l_task_asg_rec.l_asg_type_act_list(i)
			where processing_set_id = p_processing_set_id
                  and   workitem_pk_id = l_task_asg_rec.l_asg_task_id_list(i);
--			and	workitem_obj_code = 'TASK';
	     EXCEPTION
		  WHEN dml_errors THEN
		   errors := SQL%BULK_EXCEPTIONS.COUNT;
		   FOR i IN 1..errors
                    LOOP
                       fnd_file.new_line(FND_FILE.LOG, 1);
                       FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
                       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_DEF_TASKS_RULES_FUNC');
                       FND_MESSAGE.SET_TOKEN('DETAILS', ' WORKITEM_PK_ID:'||l_task_asg_rec.l_asg_task_id_list(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                      fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                      fnd_msg_pub.ADD;
                      fnd_msg_pub.Count_and_Get
                      (
                      p_count   =>   x_msg_count,
                      p_data    =>   x_msg_data
                      );
                    END LOOP;

                    x_return_status := fnd_api.g_ret_sts_error;
                    RAISE fnd_api.g_exc_error;
	     END;

	     l_task_asg_rec.l_asg_id_list.DELETE;
	     l_task_asg_rec.l_asg_task_id_list.DELETE;
	     l_task_asg_rec.l_asg_type_act_list.DELETE;

	   close c_task_asg;

	    l_msg_count := null;
	    l_msg_data := null;
	    l_return_status := null;

        IEU_WR_PUB.SYNC_WR_ITEMS  (
              p_api_version  => 1.0,
              p_init_msg_list => FND_API.G_TRUE,
              p_commit => FND_API.G_FALSE,
              p_processing_set_id => P_PROCESSING_SET_ID,
              p_user_id  => FND_GLOBAL.USER_ID,
              p_login_id => FND_GLOBAL.LOGIN_ID,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              x_return_status => l_return_status);


        x_return_status := l_return_status;

END IEU_DEF_TASKS_RULES_FUNC;

PROCEDURE GET_NEXT_WORK_ITEM
      ( p_ws_code               IN VARCHAR2,
        p_resource_id           IN NUMBER,
        x_workitem_pk_id        OUT nocopy NUMBER,
	x_workitem_obj_code	OUT NOCOPY VARCHAR2,
	x_source_obj_id		OUT NOCOPY NUMBER,
	x_source_obj_type_code  OUT NOCOPY VARCHAR2,
        x_msg_count             OUT nocopy NUMBER,
        x_return_status         OUT nocopy VARCHAR2,
        x_msg_data              OUT nocopy VARCHAR2) IS

--declare variables
        l_ws_det_list		 IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST;
        l_uwqm_workitem_data     IEU_FRM_PVT.T_IEU_MEDIA_DATA;
        l_language               VARCHAR2(10);
        l_source_lang            VARCHAR2(10);
        j number;
	l_temp_str		 VARCHAR2(4000);
	l_search_ctr		 NUMBER;
	l_start_ctr		 NUMBER;
	l_ws_ctr		 NUMBER;
	l_ws_code_str		 VARCHAR2(50);
	l_search_str_ctr	 NUMBER;
	my_message		 VARCHAR2(4000);
	l_inc_ctr		 NUMBER;

  BEGIN
     -- insert into p_temp values(' Get work api..p_ws_code: '||p_ws_code, 1); commit;

 --     l_ws_det_list(1).ws_code := p_ws_code;

      If (LENGTH(p_ws_code) is not NULL)
      then

             l_temp_str := p_ws_code;
	     l_search_ctr := 1;
	     l_start_ctr := 0;
	     l_ws_ctr := 0;
	     l_inc_ctr := 0;

	     While (l_inc_ctr < LENGTH(p_ws_code) )
	     loop

		l_search_str_ctr := instr(l_temp_str, '^',1,l_search_ctr);

                /* insert into p_temp(msg, ctr) values('srchStrCtr: '||l_search_str_ctr, l_ws_ctr); commit;
		insert into p_temp(msg, ctr) values(' strt ctr: '||l_start_ctr, l_ws_ctr); commit;
                insert into p_temp(msg, ctr) values ('tmp str: '||l_temp_str, l_ws_ctr); commit;  */

		if ((l_search_str_ctr) = 0 )
		then
		    l_ws_code_str := l_temp_str;
		else
		    l_ws_code_str :=
			  substr (
			    l_temp_str,
			    l_start_ctr,
			    ( instr(l_temp_str, '^',1,l_search_ctr) -
			      (l_start_ctr + 1) )
			    );
		    l_temp_str :=
			  substr (
			    l_temp_str,
			    instr(l_temp_str, '^',1,l_search_ctr) + 1,
			    ( LENGTH(l_temp_str) -
			      instr(l_temp_str, '<',1,l_search_ctr)+1 )
			    );

	        end if;

		--insert into p_temp(msg, ctr) values('wsCode '||l_ws_code_str, l_ws_ctr); commit;
		--insert into p_temp(msg, ctr) values(' temp Str: '||l_temp_str, l_ws_ctr); commit;

		l_ws_det_list(l_ws_ctr).ws_code := l_ws_code_str;
                -- insert into p_temp(msg) values('ws code str: '||l_ws_code_str||'ws_code: '||l_ws_det_list(l_ws_ctr).ws_code||' temp str: '||l_temp_str); commit;

		--l_start_ctr := l_start_ctr + length(l_ws_det_list(l_ws_ctr).ws_code) +1;
		--l_search_ctr := l_search_ctr + 1;
	        l_inc_ctr := l_inc_ctr + length(l_ws_det_list(l_ws_ctr).ws_code) +1;
		l_ws_ctr := l_ws_ctr + 1;

	        --insert into p_temp(msg, ctr) values('strrt ctr: '||l_start_ctr||' srch ctr: '||l_search_ctr||' ws ctr: '||l_ws_ctr, l_ws_ctr); commit;

	      END LOOP;
      END IF;
/*
      for i in l_ws_det_list.first..l_ws_det_list.last
      loop
	insert into p_temp(msg) values ('ws code in list: '||l_ws_det_list(i).ws_code); commit;
      end loop; */

      l_language := userenv('lang');
      l_source_lang  := 'US';
      j :=0;

	  BEGIN
	  -- Invoke the IEU API to get the incident Id
		  IEU_WR_PUB.GET_NEXT_WORK_FOR_APPS
		      ( p_api_version                       => 1,
			     p_resource_id                  => p_resource_id,
			     p_language                     => l_language,
			     p_source_lang                  => l_source_lang,
			     p_ws_det_list                  => l_ws_det_list,
			     x_uwqm_workitem_data           => l_uwqm_workitem_data,
			     x_msg_count                    => x_msg_count,
			     x_msg_data                     => x_msg_data,
			     x_return_status                => x_return_status);

	 EXCEPTION
	    WHEN OTHERS THEN
		--insert into p_temp values('error in get work', 2); commit;
		fnd_msg_pub.Count_and_Get
			  (
			      p_count   =>   x_msg_count,
			     p_data    =>   x_msg_data
		      );
		RAISE fnd_api.g_exc_error;
	  END;

 -- If the return status is Success or if the OUT param l_uwqm_workitem_data
 -- has values. Then retrieve the first row and get the incident_id
 -- which in the WORKITEM_PK_ID
 -- insert into p_temp values ('ret sts from Getwork'||x_return_status, 3); commit;
   IF x_return_status <> 'S' THEN
             --insert into p_temp(msg) values('Error: '|| x_return_status || '; ' ||
            --  x_msg_count || '; ' || x_msg_data);
   FOR l_index IN 1..x_msg_count LOOP
      my_message := FND_MSG_PUB.Get(p_msg_index => l_index,p_encoded => 'F');
      --insert into p_temp(msg) values (l_index || ' = ' || my_message);
   END LOOP;
 end if;

  if (x_return_status = 'S') OR (l_uwqm_workitem_data.count >= 1)
  then

	 FOR j in l_uwqm_workitem_data.first .. l_uwqm_workitem_data.last
	  LOOP
		 if (l_uwqm_workitem_data(j).param_name = 'WORKITEM_PK_ID')
		 then
		     x_workitem_pk_id := l_uwqm_workitem_data(j).param_value;
		 end if;
		 if (l_uwqm_workitem_data(j).param_name = 'WORKITEM_OBJ_CODE')
		 then
		     x_workitem_obj_code := l_uwqm_workitem_data(j).param_value;
		 end if;
		 if (l_uwqm_workitem_data(j).param_name = 'SOURCE_OBJECT_ID')
		 then
		     x_source_obj_id := l_uwqm_workitem_data(j).param_value;
		 end if;
		 if (l_uwqm_workitem_data(j).param_name = 'SOURCE_OBJECT_TYPE_CODE')
		 then
		     x_source_obj_type_code := l_uwqm_workitem_data(j).param_value;
		 end if;
	end loop;
  end if;

--  insert into p_Temp(msg) values (x_workitem_pk_id||' '||x_workitem_obj_code||' '||x_source_obj_id||' '||x_source_obj_type_code);
Exception

	 WHEN fnd_api.g_exc_error THEN
	  x_return_status := 'E';
	  fnd_msg_pub.Count_and_Get
	  (
	    p_count   =>   x_msg_count,
	    p_data    =>   x_msg_data
	  );

	 WHEN fnd_api.g_exc_unexpected_error THEN
	  x_return_status := 'U';
	  fnd_msg_pub.Count_and_Get
	  (
	    p_count   =>   x_msg_count,
	    p_data    =>   x_msg_data
	  );

END;

PROCEDURE SYNC_WR_ITEM_STATUS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_processing_set_id         IN NUMBER   DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'SYNC_WR_ITEM_STATUS';

  l_token_str          VARCHAR2(4000);

  l_count NUMBER;
  L_MISS_NUM NUMBER;

  TYPE NUMBER_TAB                  IS TABLE OF NUMBER                                       INDEX BY BINARY_INTEGER;
  TYPE WORKITEM_OBJ_CODE_TAB       IS TABLE OF IEU_UWQM_ITEMS.WORKITEM_OBJ_CODE%TYPE        INDEX BY BINARY_INTEGER;
  TYPE SOURCE_OBJECT_TYPE_CODE_TAB IS TABLE OF IEU_UWQM_ITEMS.SOURCE_OBJECT_TYPE_CODE%TYPE  INDEX BY BINARY_INTEGER;

  WORKITEM_OBJ_CODE_LIST       WORKITEM_OBJ_CODE_TAB;
  WORKITEM_PK_ID_LIST          NUMBER_TAB;

  TYPE wr_item_status_rec IS RECORD
  ( WORKITEM_OBJ_CODE_LST        WORKITEM_OBJ_CODE_TAB
  , WORKITEM_PK_ID_LST           NUMBER_TAB
  , STATUS_ID_LIST               NUMBER_TAB
  );

  l_wr_item_status_rec          wr_item_status_rec;

  dml_errors EXCEPTION;
  PRAGMA exception_init(dml_errors, -24381);
  errors number;

  l_ws_id             NUMBER;
  l_parent_ws_id      NUMBER;
  l_child_ws_id       NUMBER;
  l_parent_obj_code   VARCHAR2(500);
  l_child_obj_code    VARCHAR2(500);
  l_ws_type           VARCHAR2(500);
  l_obj_code          VARCHAR2(500);
  l_not_valid_flag    VARCHAR2(1);

BEGIN
      l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
      l_token_str := '';
      l_not_valid_flag := 'N';
      L_MISS_NUM := FND_API.G_MISS_NUM;

      SAVEPOINT SYNC_WR_ITEM_STATUS_SP;
      x_return_status := fnd_api.g_ret_sts_success;


      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;


      -- Check for NOT NULL columns

      IF ((p_processing_set_id = L_MISS_NUM)  or
        (p_processing_set_id is null))
      THEN
          l_token_str := l_token_str || ' PROCESSING_SET_ID ';

          fnd_file.new_line(FND_FILE.LOG, 1);
          FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_RQD_VALUE_NULL');
          FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEM_STATUS');
          FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_token_str);
          fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

          fnd_msg_pub.ADD;
          fnd_msg_pub.Count_and_Get
          (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
          );

          RAISE fnd_api.g_exc_error;

      END IF;

     -- Get the Work_source_id

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_id, ws_type, object_code
       into   l_ws_id, l_ws_type, l_obj_code
       from   ieu_uwqm_work_sources_b
       where  ws_code = p_ws_code
       and nvl(not_valid_flag, 'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;

            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEM_STATUS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;

     if (l_ws_type = 'PRIMARY')
     then

       -- Validate object Code

       l_token_str := '';
       l_count := '';
       l_not_valid_flag := 'N';
       WORKITEM_PK_ID_LIST.delete;
       WORKITEM_OBJ_CODE_LIST.delete;

       SELECT count(*)
       INTO   l_count
       FROM   IEU_UWQM_ITEMS_GTT A
       WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
       AND    A.WORKITEM_OBJ_CODE <> L_OBJ_CODE;

       IF NVL(l_count, 0) > 0
       THEN

         SELECT   WORKITEM_PK_ID
                , WORKITEM_OBJ_CODE
         BULK COLLECT INTO
                  WORKITEM_PK_ID_LIST
                , WORKITEM_OBJ_CODE_LIST
         FROM   IEU_UWQM_ITEMS_GTT A
         WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
         AND    A.WORKITEM_OBJ_CODE <> L_OBJ_CODE
         AND    ROWNUM <= 5;

         FOR i IN WORKITEM_PK_ID_LIST.FIRST..WORKITEM_PK_ID_LIST.LAST
         LOOP
          l_token_str := l_token_str||WORKITEM_OBJ_CODE_LIST(i)||'-'||TO_CHAR(WORKITEM_PK_ID_LIST(i))||' ';
         END LOOP;

         -- Work Source does not exist for this Object Code

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_INVALID_WS');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEM_STATUS');
         FND_MESSAGE.SET_TOKEN('WORKITEM_OBJ_CODE_AND_PK_ID',l_token_str);
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;

      END IF;

     elsif (l_ws_type = 'ASSOCIATION')
     then
        BEGIN

           SELECT parent_ws_id, child_ws_id
           INTO   l_parent_ws_id, l_child_ws_id
           FROM   IEU_UWQM_WS_ASSCT_PROPS
           WHERE  ws_id = l_ws_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEM_STATUS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

        BEGIN
           l_not_valid_flag := 'N';
           SELECT object_code
           INTO   l_parent_obj_code
           FROM   IEU_UWQM_WORK_SOURCES_B
           WHERE  ws_id = l_parent_ws_id
           and nvl(not_valid_flag, 'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEM_STATUS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

        BEGIN
           l_not_valid_flag := 'N';
           SELECT object_code
           INTO   l_child_obj_code
           FROM   IEU_UWQM_WORK_SOURCES_B
           WHERE  ws_id = l_child_ws_id
           and nvl(not_valid_flag, 'N') = l_not_valid_flag;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;
            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEM_STATUS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

        END;

      -- Validate object Code

      l_token_str := '';
      l_count := '';
      l_not_valid_flag := 'N';
      WORKITEM_PK_ID_LIST.delete;
      WORKITEM_OBJ_CODE_LIST.delete;

      SELECT count(*)
      INTO   l_count
      FROM   IEU_UWQM_ITEMS_GTT A
      WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
      AND ( A.WORKITEM_OBJ_CODE <> L_CHILD_OBJ_CODE OR A.SOURCE_OBJECT_TYPE_CODE <> L_PARENT_OBJ_CODE);

      IF NVL(l_count, 0) > 0
      THEN

         SELECT   WORKITEM_PK_ID
                , WORKITEM_OBJ_CODE
         BULK COLLECT INTO
                  WORKITEM_PK_ID_LIST
                , WORKITEM_OBJ_CODE_LIST
         FROM   IEU_UWQM_ITEMS_GTT A
         WHERE  A.PROCESSING_SET_ID = P_PROCESSING_SET_ID
         AND    (A.WORKITEM_OBJ_CODE <> L_CHILD_OBJ_CODE OR A.SOURCE_OBJECT_TYPE_CODE <> L_PARENT_OBJ_CODE)
         AND    ROWNUM <= 5;

         FOR i IN WORKITEM_PK_ID_LIST.FIRST..WORKITEM_PK_ID_LIST.LAST
         LOOP
          l_token_str := l_token_str||WORKITEM_OBJ_CODE_LIST(i)||'-'||TO_CHAR(WORKITEM_PK_ID_LIST(i))||' ';
         END LOOP;

         -- Work Source does not exist for this Object Code

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_INVALID_WS');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEM_STATUS');
         FND_MESSAGE.SET_TOKEN('WORKITEM_OBJ_CODE_AND_PK_ID',l_token_str);
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;

      END IF;

     end if;

      -- Validate Work Item Status

      l_token_str := '';
      l_count := '';
      WORKITEM_PK_ID_LIST.delete;
      WORKITEM_OBJ_CODE_LIST.delete;

      SELECT Count(*)
      INTO   l_count
      FROM  IEU_UWQM_ITEMS_GTT
      WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID
      AND  WORKITEM_STATUS NOT IN ('CLOSE', 'DELETE');

      IF NVL(l_count, 0) > 0
      THEN

         SELECT   WORKITEM_PK_ID
                , WORKITEM_OBJ_CODE
         BULK COLLECT INTO
                  WORKITEM_PK_ID_LIST
                , WORKITEM_OBJ_CODE_LIST
         FROM  IEU_UWQM_ITEMS_GTT
         WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID
         AND  WORKITEM_STATUS NOT IN ('CLOSE', 'DELETE')
         AND ROWNUM <= 5;

         FOR i IN WORKITEM_PK_ID_LIST.FIRST..WORKITEM_PK_ID_LIST.LAST
         LOOP
          l_token_str := l_token_str||WORKITEM_OBJ_CODE_LIST(i)||'-'||TO_CHAR(WORKITEM_PK_ID_LIST(i))||' ';
         END LOOP;

         fnd_file.new_line(FND_FILE.LOG, 1);
         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_INVALID_STATUS');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.SYNC_WR_ITEM_STATUS');
         FND_MESSAGE.SET_TOKEN('WORKITEM_OBJ_CODE_AND_PK_ID',l_token_str);
         fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;

      END IF;


      x_return_status := fnd_api.g_ret_sts_success;
      l_wr_item_status_rec.WORKITEM_OBJ_CODE_LST.delete;
      l_wr_item_status_rec.WORKITEM_PK_ID_LST.delete;
      l_wr_item_status_rec.STATUS_ID_LIST.delete;

      SELECT  WORKITEM_OBJ_CODE
            , WORKITEM_PK_ID
            , DECODE(WORKITEM_STATUS, 'CLOSE', 3, 'DELETE', 4, STATUS_ID) "STATUS_ID"
      BULK COLLECT INTO l_wr_item_status_rec.WORKITEM_OBJ_CODE_LST
            , l_wr_item_status_rec.WORKITEM_PK_ID_LST
            , l_wr_item_status_rec.STATUS_ID_LIST
      FROM IEU_UWQM_ITEMS_GTT
      WHERE PROCESSING_SET_ID = P_PROCESSING_SET_ID;

      IF l_wr_item_status_rec.WORKITEM_OBJ_CODE_LST.FIRST IS NOT NULL THEN
       BEGIN
         FORALL i in l_wr_item_status_rec.WORKITEM_OBJ_CODE_LST.FIRST..l_wr_item_status_rec.WORKITEM_OBJ_CODE_LST.LAST SAVE EXCEPTIONS

          UPDATE IEU_UWQM_ITEMS
          SET   OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
              , LAST_UPDATED_BY = FND_GLOBAL.USER_ID
              , LAST_UPDATE_DATE = SYSDATE
              , LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
              , STATUS_UPDATE_USER_ID = FND_GLOBAL.USER_ID
              , STATUS_ID = l_wr_item_status_rec.STATUS_ID_LIST(i)
          WHERE WORKITEM_OBJ_CODE = l_wr_item_status_rec.WORKITEM_OBJ_CODE_LST(i)
          AND WORKITEM_PK_ID = l_wr_item_status_rec.WORKITEM_PK_ID_LST(i);

	EXCEPTION
	  WHEN dml_errors THEN
           errors := SQL%BULK_EXCEPTIONS.COUNT;

	   FOR i IN 1..errors LOOP
            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_SYNC_WR_UPDATE_FAILED');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_WR_PUB.SYNC_WR_ITEM_STATUS');
            FND_MESSAGE.SET_TOKEN('DETAILS', 'WORKITEM_PK_ID:'||l_wr_item_status_rec.WORKITEM_PK_ID_LST(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

            fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
            p_count   =>   x_msg_count,
            p_data    =>   x_msg_data
            );
           END LOOP;

           RAISE fnd_api.g_exc_error;
	END;
       END IF;

       l_wr_item_status_rec.WORKITEM_OBJ_CODE_LST.delete;
       l_wr_item_status_rec.WORKITEM_PK_ID_LST.delete;
       l_wr_item_status_rec.STATUS_ID_LIST.delete;

     IF FND_API.TO_BOOLEAN( p_commit ) THEN
      COMMIT WORK;
     END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO SYNC_WR_ITEM_STATUS_SP;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO SYNC_WR_ITEM_STATUS_SP;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN
  x_msg_data := sqlcode||' '||sqlerrm;

  ROLLBACK TO SYNC_WR_ITEM_STATUS_SP;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  FND_FILE.PUT_LINE(FND_FILE.LOG, x_msg_data);
  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END SYNC_WR_ITEM_STATUS;

PROCEDURE UPDATE_WR_ITEM_STATUS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'UPDATE_WR_ITEM_STATUS';

  l_token_str          VARCHAR2(4000);

  TYPE NUMBER_TAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  WORK_ITEM_ID_LIST  NUMBER_TAB;

  TYPE wr_item_status_rec IS RECORD
  ( WORK_ITEM_ID_LIST           NUMBER_TAB
  );

  l_wr_item_status_rec          wr_item_status_rec;

  dml_errors EXCEPTION;
  PRAGMA exception_init(dml_errors, -24381);
  errors number;

  l_ws_id             NUMBER;
  l_not_valid_flag    VARCHAR2(1);
  l_array_size	NUMBER;
  l_done        BOOLEAN;

  cursor c_status(p_ws_id IN NUMBER) is
   select work_item_id
   from ieu_uwqm_items
   where ws_id = p_ws_id
   and status_id = 0;

BEGIN

      l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');
      l_token_str := '';
      l_not_valid_flag := 'N';
      l_array_size := 2000;

      SAVEPOINT UPDATE_WR_ITEM_STATUS_SP;
      x_return_status := fnd_api.g_ret_sts_success;


      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;


     -- Get the Work_source_id

     BEGIN
       l_not_valid_flag := 'N';
       Select ws_id
       into   l_ws_id
       from   ieu_uwqm_work_sources_b
       where  ws_code = p_ws_code
       and nvl(not_valid_flag, 'N') = l_not_valid_flag;

     EXCEPTION
       WHEN OTHERS THEN

            -- Work Source does not exist for this Object Code
            l_token_str := 'WS_CODE: '||p_ws_code;

            fnd_file.new_line(FND_FILE.LOG, 1);
            FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_WS_DETAILS_NULL');
            FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_WR_PUB.UPDATE_WR_ITEM_STATUS');
            FND_MESSAGE.SET_TOKEN('COLUMN_VALUE',l_token_str);
            fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);

            fnd_msg_pub.ADD;
            fnd_msg_pub.Count_and_Get
            (
               p_count   =>   x_msg_count,
               p_data    =>   x_msg_data
            );

            RAISE fnd_api.g_exc_error;

     END;


     x_return_status := fnd_api.g_ret_sts_success;
     l_wr_item_status_rec.WORK_ITEM_ID_LIST.delete;

     open c_status (l_ws_id);
     loop

	  FETCH c_status
	  BULK COLLECT INTO
	       l_wr_item_status_rec.WORK_ITEM_ID_LIST
          LIMIT l_array_size;

--	     fnd_file.put_line(FND_FILE.LOG,'due date task id cnt: '||l_task_duedate_rec.l_task_id_list.COUNT);
	     l_done := c_status%NOTFOUND;

          BEGIN
	    FORALL i in 1..l_wr_item_status_rec.WORK_ITEM_ID_LIST.COUNT SAVE EXCEPTIONS
              UPDATE IEU_UWQM_ITEMS
              SET   OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
                  , LAST_UPDATED_BY = FND_GLOBAL.USER_ID
                  , LAST_UPDATE_DATE = SYSDATE
                  , LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
                  , STATUS_UPDATE_USER_ID = FND_GLOBAL.USER_ID
                  , STATUS_ID = 3
              WHERE WORK_ITEM_ID = l_wr_item_status_rec.WORK_ITEM_ID_LIST(i);
	  EXCEPTION
            WHEN dml_errors THEN
              errors := SQL%BULK_EXCEPTIONS.COUNT;
	      FOR i IN 1..errors LOOP

                fnd_file.new_line(FND_FILE.LOG, 1);
                FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_UWQM_ITEM_FAILED');
                FND_MESSAGE.SET_TOKEN('PACKAGE_NAME', 'IEU_WR_PUB.UPDATE_WR_ITEM_STATUS');
                FND_MESSAGE.SET_TOKEN('DETAILS', 'WORK_ITEM_ID:'||l_wr_item_status_rec.WORK_ITEM_ID_LIST(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX) ||' Error: '||SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                fnd_file.put_line(FND_FILE.LOG,SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
                fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                fnd_msg_pub.ADD;
                fnd_msg_pub.Count_and_Get
                (
                p_count   =>   x_msg_count,
                p_data    =>   x_msg_data
                );
              END LOOP;

              RAISE fnd_api.g_exc_error;
          END;

          IF FND_API.TO_BOOLEAN( p_commit ) THEN
             COMMIT WORK;
          END IF;

          l_wr_item_status_rec.WORK_ITEM_ID_LIST.DELETE;

     exit when (l_done);

     end loop;

     close c_status;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK TO UPDATE_WR_ITEM_STATUS_SP;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK TO UPDATE_WR_ITEM_STATUS_SP;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN OTHERS THEN
  x_msg_data := sqlcode||' '||sqlerrm;

  ROLLBACK TO UPDATE_WR_ITEM_STATUS_SP;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  FND_FILE.PUT_LINE(FND_FILE.LOG, x_msg_data);
  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END UPDATE_WR_ITEM_STATUS;

END IEU_WR_PUB;

/
