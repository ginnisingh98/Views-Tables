--------------------------------------------------------
--  DDL for Package Body AMS_TASK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TASK_PVT" AS
/* $Header: amsvtskb.pls 115.37 2004/05/12 08:12:24 vmodur ship $ */

--------------------------------------------------------------
-- PROCEDURE
--    create_task
--
-- HISTORY
--    10/12/99  abhola  Create.
--    09/15/00  gjoby   Modified to add workfow
--    09/21/00  gjoby   Modified to close thee cursor in delete tasks procedure
--    04/15/01  musman  commented out the call to the ams_object_attribute.
--    05/12/04  vmodur  Changed query to use wf_item_activity_statuses instead
--                      of wf_item_activity_statuses_v for SQL Repository Perf Fix
---------------------------------------------------------------------
--
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE validate_task (
     p_actual_start_date       IN       DATE ,--DEFAULT NULL,
     p_actual_end_date         IN       DATE ,--DEFAULT NULL,
     x_return_status           OUT NOCOPY      VARCHAR2,
     x_msg_count               OUT NOCOPY      NUMBER,
     x_msg_data                OUT NOCOPY      VARCHAR2 )
IS
l_api_version             CONSTANT NUMBER       := 1.0;
BEGIN
  if p_actual_start_date is not null AND p_actual_end_date is not null  then
    if p_actual_start_date > p_actual_end_date then
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MESSAGE.SET_NAME('AMS','AMS_TASK_INVALID_DATE');
	 FND_MSG_PUB.Add;
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MSG_PUB.Count_and_Get
	 (
	    p_count => x_msg_count,
	    p_data => x_msg_data
	 );
	 return;
   END IF;
  END IF;
	 x_return_status := FND_API.G_RET_STS_SUCCESS;
END;


procedure check_ntf_required  (p_task_id 	in number,
			                x_return_status OUT NOCOPY varchar2	) is
--
cursor c_check_ntf_required is
SELECT importance_level
 FROM  jtf_tasks_vl jtv, JTF_TASK_PRIORITIES_VL jtp
where jtv.task_id = p_task_id
  and jtp.task_priority_id = jtv.task_priority_id;
p_flag number;
p_prof_flag number;
begin
        open c_check_ntf_required ;
        fetch c_check_ntf_required into p_flag;
        close c_check_ntf_required;
        fnd_profile.get('AMS_LOWEST_NOTFICATION_LEVEL',p_prof_flag);
        if (p_flag >  p_prof_flag )then
		    x_return_status := 'N';
        else
		    x_return_status := 'Y';
        end if;
end check_ntf_required;

PROCEDURE create_task (
     p_api_version             IN       NUMBER,
     p_init_msg_list           IN       VARCHAR2 ,--DEFAULT fnd_api.g_false,
     p_commit                  IN       VARCHAR2 ,--DEFAULT fnd_api.g_false,
     p_task_id                 IN       NUMBER ,--DEFAULT NULL,
     p_task_name               IN       VARCHAR2,
     p_task_type_id            IN       NUMBER ,--DEFAULT NULL,
     p_task_status_id          IN       NUMBER ,--DEFAULT NULL,
     p_task_priority_id        IN       NUMBER ,--DEFAULT NULL,
     p_owner_id                IN       NUMBER ,--DEFAULT NULL,
     p_owner_type_code         IN       VARCHAR2 ,--DEFAULT NULL,
     p_private_flag            IN       VARCHAR2 ,--DEFAULT NULL,
     p_planned_start_date      IN       DATE ,--DEFAULT NULL,
     p_planned_end_date        IN       DATE ,--DEFAULT NULL,
     p_actual_start_date       IN       DATE ,--DEFAULT NULL,
     p_actual_end_date         IN       DATE ,--DEFAULT NULL,
     p_source_object_type_code IN       VARCHAR2 ,--DEFAULT NULL,
     p_source_object_id        IN       NUMBER ,--DEFAULT NULL,
     p_source_object_name      IN       VARCHAR2 ,--DEFAULT NULL,
     x_return_status           OUT NOCOPY      VARCHAR2,
     x_msg_count               OUT NOCOPY      NUMBER,
     x_msg_data                OUT NOCOPY      VARCHAR2,
     x_task_id                 OUT NOCOPY      NUMBER
     )
IS

   l_api_version             CONSTANT NUMBER       := 1.0;
   l_task_type_id            NUMBER := p_task_type_id;
   l_task_status_id          NUMBER := p_task_status_id;
   l_task_priority_id        NUMBER := p_task_priority_id;
   l_task_name               VARCHAR2(80) := p_task_name  ;
   l_owner_id                NUMBER := p_owner_id  ;
   l_actual_start_date       DATE  := p_actual_start_date;
   l_actual_end_date         DATE  := p_actual_end_date;
   l_source_object_type_code VARCHAR2(80)  :=  p_source_object_type_code ;
   l_source_object_id        NUMBER  := p_source_object_id ;
   l_source_object_name      VARCHAR2(80) := p_source_object_name ;
   l_owner_type_code         VARCHAR2(90) := p_owner_type_code;
   l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_private_flag            VARCHAR2(1) := p_private_flag    ;
   l_planned_start_date      DATE := p_planned_start_date ;
   l_planned_end_date        DATE := p_planned_end_date ;

   BEGIN

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

     validate_task (
          p_actual_start_date    =>p_actual_start_date,
          p_actual_end_date      =>p_actual_start_date,
          x_return_status        =>l_return_status,
          x_msg_count            =>x_msg_count,
          x_msg_data             =>x_msg_data)  ;
   if l_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR ;
   elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   end if;
   if (l_source_object_id = 0 ) then
      l_source_object_id := NULL;
   end if;

   JTF_TASKS_PUB.create_task (
      p_api_version             => l_api_version,
      p_task_name               => l_task_name,
      p_task_type_id            => l_task_type_id,
      p_task_status_id          => l_task_status_id,
      p_task_priority_id        => l_task_priority_id,
      p_owner_id                => l_owner_id,
      p_owner_type_code         => l_owner_type_code,
      p_private_flag            => l_private_flag,
      p_planned_start_date      => l_planned_start_date,
      p_planned_end_date        => l_planned_end_date,
      p_actual_start_date       => l_actual_start_date,
      p_actual_end_date         => l_actual_end_date ,
      p_source_object_type_code => l_source_object_type_code,
      p_source_object_id        => l_source_object_id ,
      p_source_object_name      => l_source_object_name ,
      x_return_status           =>  x_return_status,
      x_msg_count               =>  x_msg_count ,
      x_msg_data                =>  x_msg_data ,
      x_task_id                 =>  x_task_id   );

/*************  Modify Attribute ******************************/
-- Commenting the call to the ams_object_attribute
--      if (x_return_status = 'S') then
--         if (l_source_object_type_code = 'AMS_CAMP') then
--            l_source_object_type_code := 'CAMP';
--         elsif (l_source_object_type_code = 'AMS_EVEO') then
--            l_source_object_type_code := 'EVEO';
--         elsif (l_source_object_type_code = 'AMS_EVEH') then
--            l_source_object_type_code := 'EVEH';
--         elsif (l_source_object_type_code = 'AMS_DELV') then
--            l_source_object_type_code := 'DELV';
--         end if;


--      AMS_ObjectAttribute_PVT.modify_object_attribute(
--          p_api_version        => l_api_version,
--          p_init_msg_list      => FND_API.g_false,
--          p_commit             => FND_API.g_false,
--          p_validation_level   => FND_API.g_valid_level_full,
--          x_return_status      => l_return_status,
--          x_msg_count          => x_msg_count,
--          x_msg_data           => x_msg_data,
--          p_object_type        => l_source_object_type_code,
--          p_object_id          => l_source_object_id ,
--          p_attr               => 'TASK',
--          p_attr_defined_flag  => 'Y'
--          );

--      end if;

	  /**** ADDED BY ABHOLA ****/

	  IF FND_API.to_boolean(p_commit) THEN
		 COMMIT;
	  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_And_Get
       ( p_count => x_msg_count,
	    p_data => x_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_And_Get
       ( p_count => x_msg_count,
	    p_data => x_msg_data);
/*****************************************************************/
END create_task;
---------------------------------------------------------------

PROCEDURE update_task (
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 ,--DEFAULT fnd_api.g_false,
    p_commit                  IN   VARCHAR2 ,--DEFAULT fnd_api.g_false,
    p_object_version_number   IN   NUMBER ,
    p_task_id                 IN   NUMBER ,--DEFAULT fnd_api.g_miss_num,
    p_task_name               IN   VARCHAR2 ,--DEFAULT fnd_api.g_miss_char,
    p_task_type_id            IN   NUMBER ,--DEFAULT NULL,
    p_task_status_id          IN   NUMBER ,--DEFAULT NULL,
    p_task_priority_id        IN   NUMBER ,--DEFAULT NULL,
    p_owner_id                IN   NUMBER ,--DEFAULT NULL,
    p_private_flag            IN   VARCHAR2 ,--DEFAULT NULL,
    p_planned_start_date      IN   DATE ,--DEFAULT NULL,
    p_planned_end_date        IN   DATE ,--DEFAULT NULL,
    p_actual_start_date       IN   DATE ,--DEFAULT fnd_api.g_miss_date,
    p_actual_end_date         IN   DATE ,--DEFAULT fnd_api.g_miss_date,
    p_source_object_type_code IN   VARCHAR2 ,--DEFAULT fnd_api.g_miss_char,
    p_source_object_id        IN   NUMBER ,--DEFAULT fnd_api.g_miss_num,
    p_source_object_name      IN   VARCHAR2 ,--DEFAULT fnd_api.g_miss_char,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2 )
IS

    l_init_msg_list           VARCHAR2(1) := fnd_api.g_true;
    l_api_version             CONSTANT NUMBER       := 1.0;
    l_task_name               VARCHAR2(80) := p_task_name  ;
    l_owner_id                NUMBER := p_owner_id  ;
    l_actual_start_date       DATE  := p_actual_start_date;
    l_actual_end_date         DATE  := p_actual_end_date;
    l_source_object_type_code VARCHAR2(80)  :=  p_source_object_type_code ;
    l_source_object_id        NUMBER  := p_source_object_id ;
    l_source_object_name      VARCHAR2(80) := p_source_object_name ;
    l_object_version_number   NUMBER := p_object_version_number ;
    l_task_id                 NUMBER := p_task_id;
    l_task_type_id            NUMBER := p_task_type_id;
    l_task_status_id          NUMBER := p_task_status_id;
    l_task_priority_id        NUMBER := p_task_priority_id;
    l_private_flag            VARCHAR2(1) := p_private_flag    ;
    l_planned_start_date      DATE := p_planned_start_date ;
    l_planned_end_date        DATE := p_planned_end_date ;
    l_return_status           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    -- For checking if workflow exists for this task
    -- Workflow is with item_key as task_id || object_version_number
    CURSOR c_check_wfprocess is
    SELECT 'x'
      FROM wf_item_activity_statuses
     WHERE item_type = 'AMSTASK'
       AND item_key like l_task_id || '%'
       AND activity_status = 'ACTIVE';
    CURSOR c_check_status is
    SELECT task_status_id
	 FROM jtf_task_statuses_vl
    -- WHERE name = 'Assigned';
    WHERE task_status_id  = 14 ;-- 'Assigned';
    l_status_id number;
    l_return_flag varchar2(1);
    l_item_type varchar2(100) := FND_API.G_MISS_CHAR;

BEGIN
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

     validate_task (
          p_actual_start_date    =>p_actual_start_date,
          p_actual_end_date      =>p_actual_end_date,
          x_return_status        =>x_return_status,
          x_msg_count            =>x_msg_count,
          x_msg_data             =>x_msg_data)  ;
   if x_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR ;
   elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   end if;

   if (l_owner_id = 0) then
      l_owner_id := null;
   end if;
   if (l_source_object_id = 0) then
      l_source_object_id := null;
   end if;


   JTF_TASKS_PUB.update_task (
      p_api_version             => l_api_version,
      p_object_version_number   => l_object_version_number,
      p_task_id                 => l_task_id,
      p_task_name               => l_task_name,
      p_task_type_id            => l_task_type_id,
      p_task_status_id          => l_task_status_id,
      p_task_priority_id        => l_task_priority_id,
      p_owner_id                => l_owner_id,
      p_private_flag            => l_private_flag,
      p_planned_start_date      => l_planned_start_date,
      p_planned_end_date        => l_planned_end_date,
      p_actual_start_date       => l_actual_start_date,
      p_actual_end_date         => l_actual_end_date ,
      p_source_object_type_code => l_source_object_type_code,
      p_source_object_id        => l_source_object_id ,
      p_source_object_name      => l_source_object_name ,
      x_return_status           =>  x_return_status,
      x_msg_count               =>  x_msg_count ,
      x_msg_data                =>  x_msg_data );

/*  no longer required  -- gjoby */
/*
    check_ntf_required  (p_task_id,
			      l_return_flag );
 if l_return_flag  = 'Y' then
    OPEN  c_check_status;
        FETCH c_check_status
         into l_status_id;
    CLOSE  c_check_status;
    if l_status_id = l_task_status_id  then
       OPEN c_check_wfprocess;
           FETCH c_check_wfprocess into l_item_type ;
       CLOSE  c_check_wfprocess;
       if ( l_item_type = FND_API.G_MISS_CHAR
	       and l_source_object_type_code is not null )then
            AMS_TASKS_WF.AmsStartWorkflow(
               p_api_version => l_api_version,
               --p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
               --p_commit            IN  VARCHAR2  := FND_API.g_false,
               p_task_id           => l_task_id,
               p_object_version    => l_object_version_number,
               x_return_status      =>  l_return_status
               --x_msg_count         OUT NOCOPY NUMBER,
               --x_msg_data          OUT NOCOPY VARCHAR2
               ) ;

      end if;
   end if;
 end if;
*/

 /**** ADDED BY ABHOLA ****/

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_And_Get
       ( p_count => x_msg_count,
	    p_data => x_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_And_Get
       ( p_count => x_msg_count,
	    p_data => x_msg_data);
END update_task;

-----------------------------------------------------------

PROCEDURE delete_task (
    p_api_version             IN       NUMBER,
    p_init_msg_list           IN       VARCHAR2 ,--DEFAULT fnd_api.g_false,
    p_commit                  IN       VARCHAR2 ,--DEFAULT fnd_api.g_false,
    p_object_version_number   IN       NUMBER ,
    p_task_id                 IN       NUMBER ,--DEFAULT NULL,
    x_return_status           OUT NOCOPY      VARCHAR2,
    x_msg_count               OUT NOCOPY      NUMBER,
    x_msg_data                OUT NOCOPY      VARCHAR2
    )
    IS
  l_api_version CONSTANT    NUMBER       := 1.0;
  l_object_version_number   NUMBER := p_object_version_number ;
  l_task_id                 NUMBER := p_task_id;

  CURSOR  c_task_type_id(l_task_id IN NUMBER)  IS
  SELECT source_object_type_code,
         source_object_id
    FROM jtf_tasks_b
   WHERE task_id = l_task_id;

  CURSOR  c_task_attr ( p_obj_id in NUMBER, p_obj_type IN VARCHAR2) IS
  SELECT 'x'
    FROM jtf_tasks_b
   WHERE source_object_type_code = p_obj_type
     AND source_object_id = p_obj_id
     AND deleted_flag <> 'Y'   ;

  l_object_id       NUMBER;
  l_object_type     VARCHAR2(100);
  l_dummy           VARCHAR2(1);
  l_return_status   VARCHAR2(1);

BEGIN
-----  Get the object type and obj id for this access id ----

   OPEN   c_task_type_id(p_task_id);
   FETCH c_task_type_id into
	    l_object_type,
         l_object_id;
   CLOSE c_task_type_id;

--------------------------------------------------------------

   JTF_TASKS_PUB.delete_task (
       p_api_version             => l_api_version,
       p_object_version_number   => l_object_version_number,
       p_task_id                 => l_task_id,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count ,
       x_msg_data                => x_msg_data );

-----          Modify Object Attribute ---------------
-- commenting the call to create ams_object_attribute
--   OPEN   c_task_attr( l_object_id, l_object_type);
--   FETCH  c_task_attr into l_dummy;
--   if (c_task_attr%NOTFOUND) then
--      if (l_object_type = 'AMS_CAMP') then
--         l_object_type := 'CAMP';
--      elsif (l_object_type = 'AMS_EVEO') then
--         l_object_type := 'EVEO';
--      elsif (l_object_type = 'AMS_EVEH') then
--         l_object_type := 'EVEH';
--      elsif (l_object_type = 'AMS_DELV') then
--         l_object_type := 'DELV';
--      end if;

--   AMS_ObjectAttribute_PVT.modify_object_attribute(
--      p_api_version        => l_api_version,
--      p_init_msg_list      => FND_API.g_false,
--      p_commit             => FND_API.g_false,
--      p_validation_level   => FND_API.g_valid_level_full,
--      x_return_status      => l_return_status,
--      x_msg_count          => x_msg_count,
--      x_msg_data           => x_msg_data,
--      p_object_type        => l_object_type,
--      p_object_id          => l_object_id ,
--      p_attr               => 'TASK',
--      p_attr_defined_flag  => 'N'
--   );

--   end if;
-- CLOSE c_task_attr;
------------------------------------------------------

 /**** ADDED BY ABHOLA ****/

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
   END IF;

END delete_task;

---------------------------------------------------------

Procedure  Create_Task_Assignment (
    P_API_VERSION          IN   NUMBER       ,
    P_INIT_MSG_LIST        IN   VARCHAR2     ,--DEFAULT FND_API.G_FALSE ,
    P_COMMIT               IN   VARCHAR2     ,--DEFAULT FND_API.G_FALSE ,
    P_TASK_ID              IN   NUMBER       ,
    P_RESOURCE_TYPE_CODE   IN   VARCHAR2     ,
    P_RESOURCE_ID          IN   NUMBER       ,
    P_ASSIGNMENT_STATUS_ID IN   NUMBER       ,
    X_RETURN_STATUS        OUT NOCOPY  VARCHAR2     ,
    X_MSG_COUNT            OUT NOCOPY  NUMBER       ,
    X_MSG_DATA             OUT NOCOPY  VARCHAR2     ,
    X_TASK_ASSIGNMENT_ID   OUT NOCOPY  NUMBER )
IS
  l_api_version CONSTANT    NUMBER       := 1.0;
  l_task_id                 NUMBER       := p_task_id;
  l_resource_type_code      VARCHAR2(50) := p_resource_type_code;
  l_resource_id             NUMBER       := p_resource_id;
  l_assignment_status_id    NUMBER := p_assignment_status_id;

    -- For checking if workflow exists for this task
    -- Workflow is with item_key as task_id || object_version_number
    CURSOR c_check_wfprocess is
    SELECT 'x'
      FROM wf_item_activity_statuses
     WHERE item_type = 'AMSTASK'
       AND item_key like l_task_id || '%'
       AND activity_status = 'ACTIVE';

    CURSOR c_check_status is
    SELECT task_status_id
	 FROM jtf_task_statuses_vl
    -- WHERE name = 'Assigned';
    WHERE task_status_id  = 14 ;-- 'Assigned';
    CURSOR c_get_status is
    SELECT task_status_id  ,source_object_type_code,object_version_number
	 FROM jtf_tasks_b
     WHERE task_id  = l_task_id;
    l_object_version_number   number;
    l_source_object_type_code   varchar2(80);
    l_return_status varchar2(1);
    l_status_id number;
    l_task_status_id number;
    l_item_type varchar2(100) := FND_API.G_MISS_CHAR;
    l_return_flag varchar2(1);

BEGIN

  JTF_TASK_ASSIGNMENTS_PUB.create_task_assignment (
    p_api_version             => l_api_version,
    p_task_id                 => l_task_id,
    P_RESOURCE_TYPE_CODE      => l_resource_type_code,
    P_RESOURCE_ID             => l_resource_id ,
    p_assignment_status_id    => l_assignment_status_id,
    x_return_status             =>  x_return_status,
    x_msg_count                  =>  x_msg_count ,
    x_msg_data                       =>  x_msg_data,
    X_TASK_ASSIGNMENT_ID      =>  X_TASK_ASSIGNMENT_ID );

/* No longer required gjoby */
/*
    check_ntf_required  (p_task_id,
			      l_return_flag );
 if l_return_flag  = 'Y' then
    -- Added code for notification
    OPEN  c_check_status;
        FETCH c_check_status
         into l_status_id;
    CLOSE  c_check_status;
    OPEN  c_get_status;
        FETCH c_get_status
         into l_task_status_id,
		    l_source_object_type_code, l_object_version_number;
    CLOSE  c_get_status;
    if l_status_id = l_task_status_id  then
       OPEN c_check_wfprocess;
           FETCH c_check_wfprocess into l_item_type ;
       CLOSE  c_check_wfprocess;
       if ( l_item_type = FND_API.G_MISS_CHAR
	       and l_source_object_type_code is not null )then
            AMS_TASKS_WF.AmsStartWorkflow(
               p_api_version => l_api_version,
               p_task_id           => l_task_id,
               p_object_version    => l_object_version_number,
               x_return_status      =>  l_return_status
               ) ;

      end if;
   end if;
 end if;
*/

END;

--Procedure to Delete Task Assignment

Procedure  Delete_Task_Assignment
     (P_API_VERSION               IN     NUMBER     ,
      P_INIT_MSG_LIST               IN     VARCHAR2 ,
      P_COMMIT                   IN     VARCHAR2 ,
      p_object_version_number IN     NUMBER     ,
      P_TASK_ASSIGNMENT_ID     IN     NUMBER      ,
      X_RETURN_STATUS               OUT NOCOPY     VARCHAR2,
      X_MSG_COUNT                   OUT NOCOPY     NUMBER      ,
      X_MSG_DATA                   OUT NOCOPY     VARCHAR2 )

IS

   l_api_version CONSTANT    NUMBER  := 1.0;
   l_task_assignment_id  NUMBER := p_task_assignment_id;
   l_object_version_number NUMBER := p_object_version_number;
   l_INIT_MSG_LIST VARCHAR2(100) := P_INIT_MSG_LIST;
   l_commit VARCHAR2(100) := p_commit;
BEGIN

   JTF_TASK_ASSIGNMENTS_PUB.delete_task_assignment (
      p_api_version             => l_api_version,
      P_INIT_MSG_LIST               => l_init_msg_list,
      p_commit                  => l_commit,
      p_object_version_number   => l_object_version_number,
      p_task_assignment_id      => l_task_assignment_id ,
      x_return_status             =>  x_return_status,
      x_msg_count                  =>  x_msg_count ,
      x_msg_data                  =>  x_msg_data );
END;


--Procedure to Update Task Assignment

Procedure  Update_Task_Assignment(
    P_API_VERSION           IN   NUMBER,
    p_object_version_number IN   NUMBER,
    P_INIT_MSG_LIST         IN   VARCHAR2   ,--DEFAULT G_FALSE ,
    P_COMMIT                IN   VARCHAR2   ,--DEFAULT G_FALSE ,
    P_TASK_ASSIGNMENT_ID    IN   NUMBER ,
    P_TASK_ID               IN   NUMBER     ,--default fnd_api.g_miss_num ,
    P_RESOURCE_TYPE_CODE    IN   VARCHAR2   ,--DEFAULT NULL,
    P_RESOURCE_ID           IN   NUMBER,
    P_ASSIGNMENT_STATUS_ID  IN   NUMBER,
    X_RETURN_STATUS         OUT NOCOPY  VARCHAR2 ,
    X_MSG_COUNT             OUT NOCOPY  NUMBER ,
    X_MSG_DATA              OUT NOCOPY  VARCHAR2)

IS
   l_api_version CONSTANT    NUMBER  := 1.0;
   l_task_assignment_id  NUMBER := p_task_assignment_id;
   l_task_id             NUMBER := p_task_id;
   l_object_version_number NUMBER := p_object_version_number;
   l_resource_territory_id   NUMBER;
   l_assignment_status_id    NUMBER := P_ASSIGNMENT_STATUS_ID;
   l_resource_id NUMBER := p_resource_id;
   l_resource_type_code VARCHAR2(20)  := p_resource_type_code;

BEGIN

   JTF_TASK_ASSIGNMENTS_PUB.update_task_assignment (
      p_api_version           => l_api_version,
      p_object_version_number => l_object_version_number,
      p_task_assignment_id    => l_task_assignment_id ,
      P_TASK_ID               => l_task_id,
      p_resource_id           => l_resource_id,
      p_resource_type_code    => l_resource_type_code,
      p_assignment_status_id  => l_assignment_status_id,
      x_return_status         =>  x_return_status,
      x_msg_count             =>  x_msg_count ,
      x_msg_data              =>  x_msg_data );
END;



-- Wrapper on JTF Workflow API

PROCEDURE start_task_workflow (
   p_api_version         IN       NUMBER,
   p_init_msg_list       IN       VARCHAR2 ,--DEFAULT fnd_api.g_false,
   p_commit              IN       VARCHAR2 ,--DEFAULT fnd_api.g_false,
   p_task_id             IN       NUMBER,
   p_old_assignee_code   IN       VARCHAR2 ,--DEFAULT NULL,
   p_old_assignee_id     IN       NUMBER ,--DEFAULT NULL,
   p_new_assignee_code   IN       VARCHAR2 ,--DEFAULT NULL,
   p_new_assignee_id     IN       NUMBER ,--DEFAULT NULL,
   p_old_owner_code      IN       VARCHAR2 ,--DEFAULT NULL,
   p_old_owner_id        IN       NUMBER ,--DEFAULT NULL,
   p_new_owner_code      IN       VARCHAR2 ,--DEFAULT NULL,
   p_new_owner_id        IN       NUMBER ,--DEFAULT NULL,
   p_task_attribute      IN       VARCHAR2 ,--DEFAULT NULL,
   p_old_value           IN       VARCHAR2 ,--DEFAULT NULL,
   p_new_value           IN       VARCHAR2 ,--DEFAULT NULL,
   p_event               IN       VARCHAR2,
   p_wf_display_name     IN       VARCHAR2 ,--DEFAULT NULL,
   p_wf_process          IN       VARCHAR2
                  ,--DEFAULT jtf_task_workflow_pkg.jtf_task_default_process,
   p_wf_item_type        IN       VARCHAR2
                  ,--DEFAULT jtf_task_workflow_pkg.jtf_task_item_type,
   x_return_status       OUT NOCOPY      VARCHAR2,
   x_msg_count           OUT NOCOPY      NUMBER,
   x_msg_data            OUT NOCOPY      VARCHAR2  ) is


   l_api_version             CONSTANT NUMBER := 1.0;
   l_init_msg_list           VARCHAR2(1000) := p_init_msg_list;
   l_commit                  VARCHAR2(100) := p_commit;
   l_task_id                 NUMBER := p_task_id;
   l_old_assignee_code       VARCHAR2(100) := p_old_assignee_code;
   l_old_assignee_id         NUMBER := p_old_assignee_id;
   l_new_assignee_code       VARCHAR2(100) := p_new_assignee_code;
   l_new_assignee_id         NUMBER := p_new_assignee_id;
   l_old_owner_code          VARCHAR2(100) := p_old_owner_code;
   l_old_owner_id            NUMBER := p_old_owner_id;
   l_new_owner_code          VARCHAR2(100)  := p_new_owner_code;
   l_new_owner_id            NUMBER := p_new_owner_id;

   l_task_details_tbl        JTF_TASK_WORKFLOW_PKG.task_details_tbl;
   l_event                   VARCHAR2(100) := p_event;
   l_wf_display_name         VARCHAR2(100) := p_wf_display_name;
   l_wf_process              VARCHAR2(100) := p_wf_process ;
   l_wf_item_type            VARCHAR2(100) := p_wf_item_type;

Begin

   l_task_details_tbl(1).old_value := p_old_value;
   l_task_details_tbl(1).new_value := p_new_value;

   JTF_TASK_WORKFLOW_PKG.start_task_workflow (
      p_api_version         =>    l_api_version,
      p_init_msg_list       =>    l_init_msg_list,
      p_commit              =>    l_commit,
      p_task_id             =>    l_task_id,
      p_old_assignee_code   =>    l_old_assignee_code,
      p_old_assignee_id     =>    l_old_assignee_id,
      p_new_assignee_code   =>    l_new_assignee_code,
      p_new_assignee_id     =>    l_new_assignee_id,
      p_old_owner_code      =>    l_old_owner_code,
      p_old_owner_id        =>    l_old_owner_id,
      p_new_owner_code      =>    l_new_owner_code,
      p_new_owner_id        =>    l_new_owner_id,
      p_task_details_tbl    =>    l_task_details_tbl,
      p_event               =>    l_event,
      p_wf_display_name     =>    l_wf_display_name,
      p_wf_process          =>    l_wf_process,
      p_wf_item_type        =>    l_wf_item_type,
      x_return_status       =>    x_return_status,
      x_msg_count           =>    x_msg_count,
      x_msg_data            =>    x_msg_data
      );
end;

END AMS_TASK_PVT;

/
