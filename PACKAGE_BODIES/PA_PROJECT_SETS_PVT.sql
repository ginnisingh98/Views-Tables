--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SETS_PVT" AS
/*$Header: PAPPSPVB.pls 120.2 2005/08/23 05:29:31 avaithia noship $*/

--
PROCEDURE create_project_set
( p_project_set_name       IN    pa_project_sets_tl.name%TYPE
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE
 ,p_description            IN    pa_project_sets_tl.description%TYPE
 ,p_party_name             IN    hz_parties.party_name%TYPE
 ,p_attribute_category     IN    pa_project_sets_b.attribute_category%TYPE
 ,p_attribute1             IN    pa_project_sets_b.attribute1%TYPE
 ,p_attribute2             IN    pa_project_sets_b.attribute2%TYPE
 ,p_attribute3             IN    pa_project_sets_b.attribute3%TYPE
 ,p_attribute4             IN    pa_project_sets_b.attribute4%TYPE
 ,p_attribute5             IN    pa_project_sets_b.attribute5%TYPE
 ,p_attribute6             IN    pa_project_sets_b.attribute6%TYPE
 ,p_attribute7             IN    pa_project_sets_b.attribute7%TYPE
 ,p_attribute8             IN    pa_project_sets_b.attribute8%TYPE
 ,p_attribute9             IN    pa_project_sets_b.attribute9%TYPE
 ,p_attribute10            IN    pa_project_sets_b.attribute10%TYPE
 ,p_attribute11            IN    pa_project_sets_b.attribute11%TYPE
 ,p_attribute12            IN    pa_project_sets_b.attribute12%TYPE
 ,p_attribute13            IN    pa_project_sets_b.attribute13%TYPE
 ,p_attribute14            IN    pa_project_sets_b.attribute14%TYPE
 ,p_attribute15            IN    pa_project_sets_b.attribute15%TYPE
 ,x_project_set_id        OUT    NOCOPY pa_project_sets_b.project_set_id%TYPE           --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_party_id                pa_project_sets_b.party_id%TYPE := p_party_id;
  l_return_status           VARCHAR2(1);
  l_unique                  VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(240);
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PVT.Create_Project_Set.begin'
                     ,x_msg         => 'Beginning of Create_Project_Set pvt'
                     ,x_log_level   => 5);
  END IF;
  -- have to get the party_id of the owner if party_id passed in is NULL
  IF p_party_id IS NULL THEN
     PA_PROJECT_SET_UTILS.Check_PartyName_Or_Id (
        p_party_id         => p_party_id,
        p_party_name	     => p_party_name,
        p_check_id_flag    => 'Y',
        x_party_id         => l_party_id,
        x_return_status    => l_return_status,
        x_error_msg_code	 => l_msg_data);
  END IF;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name       => l_msg_data);
  END IF;

  -- perform a check that the project set name must be unique
  l_unique := PA_PROJECT_SET_UTILS.is_name_unique(p_project_set_name);

  IF l_unique = 'N' THEN
      PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                            ,p_msg_name => 'PA_PROJECT_SET_NAME_NOT_UNIQUE');
  END IF;

  -- check the dates
  IF p_effective_end_date IS NOT NULL THEN
        IF p_effective_start_date > p_effective_end_date THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name => 'PA_INVALID_START_DATE');
        END IF;
  END IF;


  IF FND_MSG_PUB.Count_Msg =0 THEN

     IF l_enable_log = 'Y' THEN
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PVT.Create_Project_Set'
                        ,x_msg         => 'before pa_project_sets_pkg.insert_row'
                        ,x_log_level   => 5);
     END IF;

     PA_PROJECT_SETS_PKG.insert_row
          (p_project_set_name       =>   p_project_set_name
          ,p_party_id               =>   l_party_id
          ,p_effective_start_date   =>   p_effective_start_date
          ,p_effective_end_date     =>   p_effective_end_date
          ,p_access_level           =>   p_access_level
          ,p_description            =>   p_description
          ,p_attribute_category     =>   p_attribute_category
          ,p_attribute1             =>   p_attribute1
          ,p_attribute2             =>   p_attribute2
          ,p_attribute3             =>   p_attribute3
          ,p_attribute4             =>   p_attribute4
          ,p_attribute5             =>   p_attribute5
          ,p_attribute6             =>   p_attribute6
          ,p_attribute7             =>   p_attribute7
          ,p_attribute8             =>   p_attribute8
          ,p_attribute9             =>   p_attribute9
          ,p_attribute10            =>   p_attribute10
          ,p_attribute11            =>   p_attribute11
          ,p_attribute12            =>   p_attribute12
          ,p_attribute13            =>   p_attribute13
          ,p_attribute14            =>   p_attribute14
          ,p_attribute15            =>   p_attribute15
          ,x_project_set_id         =>   x_project_set_id
          ,x_return_status          =>   l_return_status);

  END IF;

  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PVT.Create_Project_Set'
                     ,x_msg         => 'x_project_set_id = '|| x_project_set_id
                     ,x_log_level   => 5);
  END IF;

  IF FND_MSG_PUB.Count_Msg > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PVT.Create_Project_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      -- Start : RESET other OUT param too : 4537865
	x_project_set_id := NULL ;
      -- ENd : 4537865

       --RAISE;

END Create_Project_Set;


PROCEDURE update_project_set
( p_project_set_id         IN    pa_project_sets_b.project_set_id%TYPE
 ,p_project_set_name       IN    pa_project_sets_tl.name%TYPE
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE
 ,p_description            IN    pa_project_sets_tl.description%TYPE
 ,p_party_name             IN    hz_parties.party_name%TYPE
 ,p_attribute_category     IN    pa_project_sets_b.attribute_category%TYPE
 ,p_attribute1             IN    pa_project_sets_b.attribute1%TYPE
 ,p_attribute2             IN    pa_project_sets_b.attribute2%TYPE
 ,p_attribute3             IN    pa_project_sets_b.attribute3%TYPE
 ,p_attribute4             IN    pa_project_sets_b.attribute4%TYPE
 ,p_attribute5             IN    pa_project_sets_b.attribute5%TYPE
 ,p_attribute6             IN    pa_project_sets_b.attribute6%TYPE
 ,p_attribute7             IN    pa_project_sets_b.attribute7%TYPE
 ,p_attribute8             IN    pa_project_sets_b.attribute8%TYPE
 ,p_attribute9             IN    pa_project_sets_b.attribute9%TYPE
 ,p_attribute10            IN    pa_project_sets_b.attribute10%TYPE
 ,p_attribute11            IN    pa_project_sets_b.attribute11%TYPE
 ,p_attribute12            IN    pa_project_sets_b.attribute12%TYPE
 ,p_attribute13            IN    pa_project_sets_b.attribute13%TYPE
 ,p_attribute14            IN    pa_project_sets_b.attribute14%TYPE
 ,p_attribute15            IN    pa_project_sets_b.attribute15%TYPE
 ,p_record_version_number  IN    pa_project_sets_b.record_version_number%TYPE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_party_id                pa_project_sets_b.party_id%TYPE := p_party_id;
  l_return_status           VARCHAR2(1);
  l_unique                  VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(240);
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PVT.Update_Project_Set.begin'
                     ,x_msg         => 'Beginning of Update_Project_Set pvt'
                     ,x_log_level   => 5);
  END IF;

  -- have to get the party_id of the owner if party_id passed in is NULL
  IF p_party_id IS NULL THEN
     PA_PROJECT_SET_UTILS.Check_PartyName_Or_Id (
        p_party_id           => p_party_id,
        p_party_name	       => p_party_name,
        p_check_id_flag      => 'Y',
        x_party_id           => l_party_id,
        x_return_status      => l_return_status,
        x_error_msg_code	   => l_msg_data);
  END IF;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name       => l_msg_data);
  END IF;

  l_unique := PA_PROJECT_SET_UTILS.is_name_unique(p_project_set_name, p_project_set_id);

  IF l_unique = 'N' THEN
      PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                            ,p_msg_name => 'PA_PROJECT_SET_NAME_NOT_UNIQUE');
  END IF;

  IF p_effective_end_date IS NOT NULL THEN
        IF p_effective_start_date > p_effective_end_date THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name => 'PA_INVALID_START_DATE');
        END IF;
  END IF;


  IF FND_MSG_PUB.Count_Msg =0 THEN
     IF l_enable_log = 'Y' THEN
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PVT.Update_Project_Set'
                        ,x_msg         => 'before pa_project_sets_pkg.insert_row'
                        ,x_log_level   => 5);
     END IF;

     PA_PROJECT_SETS_PKG.update_row
          (p_project_set_id         =>   p_project_set_id
          ,p_project_set_name       =>   p_project_set_name
          ,p_party_id               =>   l_party_id
          ,p_effective_start_date   =>   p_effective_start_date
          ,p_effective_end_date     =>   p_effective_end_date
          ,p_access_level           =>   p_access_level
          ,p_description            =>   p_description
          ,p_attribute_category     =>   p_attribute_category
          ,p_attribute1             =>   p_attribute1
          ,p_attribute2             =>   p_attribute2
          ,p_attribute3             =>   p_attribute3
          ,p_attribute4             =>   p_attribute4
          ,p_attribute5             =>   p_attribute5
          ,p_attribute6             =>   p_attribute6
          ,p_attribute7             =>   p_attribute7
          ,p_attribute8             =>   p_attribute8
          ,p_attribute9             =>   p_attribute9
          ,p_attribute10            =>   p_attribute10
          ,p_attribute11            =>   p_attribute11
          ,p_attribute12            =>   p_attribute12
          ,p_attribute13            =>   p_attribute13
          ,p_attribute14            =>   p_attribute14
          ,p_attribute15            =>   p_attribute15
          ,p_record_version_number  =>   p_record_version_number
          ,x_return_status          =>   l_return_status);

  END IF;

  IF FND_MSG_PUB.Count_Msg > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PVT.Update_Project_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       --RAISE;

END Update_Project_Set;


PROCEDURE delete_project_set
(  p_project_set_id        IN  pa_project_sets_b.project_set_id%TYPE
  ,p_record_version_number IN  pa_project_sets_b.record_version_number%TYPE
  ,x_return_status        OUT  NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
)
IS
 l_return_status          VARCHAR2(1);
 l_do_lines_exist         VARCHAR2(1);
 l_project_set_lines_tbl  pa_project_set_utils.project_set_lines_tbl_type;
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PVT.Delete_Project_Set'
                     ,x_msg         => 'Beginning of Delete_Project_Set pvt'
                     ,x_log_level   => 5);
  END IF;

  l_project_set_lines_tbl := pa_project_set_utils.get_project_set_lines(p_project_set_id => p_project_set_id);

  IF l_project_set_lines_tbl.COUNT > 0 THEN

     FOR i IN l_project_set_lines_tbl.FIRST .. l_project_set_lines_tbl.LAST LOOP

        delete_project_set_line(p_project_set_id   => l_project_set_lines_tbl(i).project_set_id
                               ,p_project_id       => l_project_set_lines_tbl(i).project_id
                               ,x_return_status    => l_return_status);

     END LOOP;

  END IF;

  IF FND_MSG_PUB.Count_Msg = 0 THEN

     l_do_lines_exist := PA_PROJECT_SET_UTILS.do_lines_exist(p_project_set_id);

     IF l_do_lines_exist = 'N' THEN

        PA_PROJECT_SETS_PKG.delete_row
               (p_project_set_id     => p_project_set_id,
                p_record_version_number => p_record_version_number,
                x_return_status      => l_return_status);

     END IF;

  END IF;

  IF FND_MSG_PUB.Count_Msg > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PVT.Delete_Project_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       --RAISE;

END Delete_Project_Set;

PROCEDURE create_project_set_line
(  p_project_set_id     IN   pa_project_set_lines.project_set_id%TYPE
  ,p_project_id         IN   pa_project_set_lines.project_id%TYPE
  ,x_return_status     OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
)
IS
  l_return_status    VARCHAR2(1);
  l_exists           VARCHAR2(1);
  l_project_set_id   PA_PROJECT_SETS_B.project_set_id%TYPE;
  e_row_is_locked    EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_row_is_locked, -54);
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

   -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PVT.Create_Project_Set_Line.begin'
                     ,x_msg         => 'Beginning of Create_Project_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  SELECT project_set_id
    INTO l_project_set_id
    FROM pa_project_sets_b
   WHERE project_set_id = p_project_set_id
     FOR UPDATE NOWAIT;

  l_exists := PA_PROJECT_SET_UTILS.check_projects_in_set(
                              p_project_set_id  => p_project_set_id
                             ,p_project_id      => p_project_id);

  IF l_exists = 'N' THEN

     PA_PROJECT_SETS_PKG.insert_row_lines(
          p_project_set_id    =>   p_project_set_id
         ,p_project_id        =>   p_project_id
         ,x_return_status     =>   x_return_status);

  END IF;

  EXCEPTION
    WHEN e_row_is_locked THEN
      PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_PROJECT_SET_LOCKED');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PVT.create_project_set_line'
                             ,p_procedure_name => PA_DEBUG.G_Err_Stack );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE;

END create_project_set_line;


PROCEDURE delete_project_set_line
(  p_project_set_id     IN   pa_project_set_lines.project_set_id%TYPE
  ,p_project_id         IN   pa_project_set_lines.project_id%TYPE
  ,x_return_status     OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
)
IS
  l_return_status    VARCHAR2(1);
  l_exists           VARCHAR2(1);
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

   -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PVT.Delete_Project_Set_Line.begin'
                     ,x_msg         => 'Beginning of Delete_Project_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  l_exists := PA_PROJECT_SET_UTILS.check_projects_in_set(
                              p_project_set_id  => p_project_set_id
                             ,p_project_id      => p_project_id);

  IF l_exists = 'Y' THEN

     -- if the project exists in project set, delete the row
     PA_PROJECT_SETS_PKG.delete_row_lines(
          p_project_set_id    =>   p_project_set_id
         ,p_project_id        =>   p_project_id
         ,x_return_status     =>   x_return_status);
  END IF;
-- 4537865 : Included Exception Block
EXCEPTION
    WHEN OTHERS THEN

       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PVT'
                                ,p_procedure_name => 'Delete_Project_Set_line',
				p_error_text => SUBSTRB(SQLERRM,1,120)
				);
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	-- Not RAISING because caller doesnt expect a RAISE

END delete_project_set_line;

PROCEDURE delete_proj_from_proj_set
( p_project_id         IN   pa_project_set_lines.project_id%TYPE
 ,x_return_status     OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN
  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM pa_project_set_lines
  WHERE project_id = p_project_id;

EXCEPTION
    WHEN OTHERS THEN
       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SET_LINES_PKG.Delete_project_from_project_sets'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END delete_proj_from_proj_set;

END;

/
