--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SETS_PUB" AS
/*$Header: PAPPSPUB.pls 120.2 2005/08/23 21:50:24 avaithia noship $*/

--
PROCEDURE create_project_set
( p_project_set_name       IN    pa_project_sets_tl.name%TYPE
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE       := NULL
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE
 ,p_description            IN    pa_project_sets_tl.description%TYPE             := NULL
 ,p_party_name             IN    hz_parties.party_name%TYPE
 ,p_attribute_category     IN    pa_project_sets_b.attribute_category%TYPE       := NULL
 ,p_attribute1             IN    pa_project_sets_b.attribute1%TYPE               := NULL
 ,p_attribute2             IN    pa_project_sets_b.attribute2%TYPE               := NULL
 ,p_attribute3             IN    pa_project_sets_b.attribute3%TYPE               := NULL
 ,p_attribute4             IN    pa_project_sets_b.attribute4%TYPE               := NULL
 ,p_attribute5             IN    pa_project_sets_b.attribute5%TYPE               := NULL
 ,p_attribute6             IN    pa_project_sets_b.attribute6%TYPE               := NULL
 ,p_attribute7             IN    pa_project_sets_b.attribute7%TYPE               := NULL
 ,p_attribute8             IN    pa_project_sets_b.attribute8%TYPE               := NULL
 ,p_attribute9             IN    pa_project_sets_b.attribute9%TYPE               := NULL
 ,p_attribute10            IN    pa_project_sets_b.attribute10%TYPE              := NULL
 ,p_attribute11            IN    pa_project_sets_b.attribute11%TYPE              := NULL
 ,p_attribute12            IN    pa_project_sets_b.attribute12%TYPE              := NULL
 ,p_attribute13            IN    pa_project_sets_b.attribute13%TYPE              := NULL
 ,p_attribute14            IN    pa_project_sets_b.attribute14%TYPE              := NULL
 ,p_attribute15            IN    pa_project_sets_b.attribute15%TYPE              := NULL
 ,p_api_version            IN    NUMBER                                          := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                 IN    VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                        := FND_API.G_TRUE
 ,x_project_set_id        OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status   VARCHAR2(1);
 l_msg_index_out   NUMBER;
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

  -- Initialize the Error Stack
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.init_err_stack('PA_PROJECT_SETS_PUB.Create_Project_Set');
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT CREATE_PROJECT_SETS_PUB;
  END IF;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Create_Project_Set.begin'
                     ,x_msg         => 'Beginning of Create_Project_Set pub'
                     ,x_log_level   => 5);

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Create_Project_Set.begin'
                     ,x_msg         => 'calling create_Project_Set pvt'
                     ,x_log_level   => 5);
  END IF;


  PA_PROJECT_SETS_PVT.create_project_set(
           p_project_set_name       =>   p_project_set_name
          ,p_party_id               =>   p_party_id
          ,p_effective_start_date   =>   p_effective_start_date
          ,p_effective_end_date     =>   p_effective_end_date
          ,p_access_level           =>   p_access_level
          ,p_description            =>   p_description
          ,p_party_name             =>   p_party_name
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

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.Reset_Err_Stack;
  END IF;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
             ROLLBACK TO CREATE_PROJECT_SETS_PUB;
        END IF;

	-- 4537865  : RESET the OUT params properly
	x_project_set_id := NULL ;
	x_msg_count := 1;
	x_msg_data := SUBSTRB(SQLERRM,1,120);

       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PUB.Create_Project_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       --RAISE;

END create_project_set;


PROCEDURE update_project_set
 (p_project_set_id         IN    pa_project_sets_b.project_set_id%TYPE
 ,p_project_set_name       IN    pa_project_sets_tl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE                := FND_API.G_MISS_NUM
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE    := FND_API.G_MISS_DATE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE      := FND_API.G_MISS_DATE
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE            := FND_API.G_MISS_NUM
 ,p_description            IN    pa_project_sets_tl.description%TYPE            := FND_API.G_MISS_CHAR
 ,p_party_name             IN    hz_parties.party_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_attribute_category     IN    pa_project_sets_b.attribute_category%TYPE      := FND_API.G_MISS_CHAR
 ,p_attribute1             IN    pa_project_sets_b.attribute1%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute2             IN    pa_project_sets_b.attribute2%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute3             IN    pa_project_sets_b.attribute3%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute4             IN    pa_project_sets_b.attribute4%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute5             IN    pa_project_sets_b.attribute5%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute6             IN    pa_project_sets_b.attribute6%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute7             IN    pa_project_sets_b.attribute7%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute8             IN    pa_project_sets_b.attribute8%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute9             IN    pa_project_sets_b.attribute9%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute10            IN    pa_project_sets_b.attribute10%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute11            IN    pa_project_sets_b.attribute11%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute12            IN    pa_project_sets_b.attribute12%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute13            IN    pa_project_sets_b.attribute13%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute14            IN    pa_project_sets_b.attribute14%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute15            IN    pa_project_sets_b.attribute15%TYPE             := FND_API.G_MISS_CHAR
 ,p_record_version_number  IN    pa_project_sets_b.record_version_number%TYPE   := NULL
 ,p_api_version            IN    NUMBER                                         := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                       := FND_API.G_FALSE
 ,p_commit                 IN    VARCHAR2                                       := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                       := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status          VARCHAR2(1);
 l_msg_index_out          NUMBER;
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

  -- Initialize the Error Stack
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.init_err_stack('PA_PROJECT_SETS_PUB.Update_Project_Set');
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT UPDATE_PROJECT_SETS_PUB;
  END IF;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Update_Project_Set.begin'
                     ,x_msg         => 'Beginning of Update_Project_Set pub'
                     ,x_log_level   => 5);

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Update_Project_Set.begin'
                     ,x_msg         => 'calling Update_Project_Set pvt'
                     ,x_log_level   => 5);
  END IF;

  PA_PROJECT_SETS_PVT.update_project_set(
           p_project_set_id         =>   p_project_set_id
          ,p_project_set_name       =>   p_project_set_name
          ,p_party_id               =>   p_party_id
          ,p_effective_start_date   =>   p_effective_start_date
          ,p_effective_end_date     =>   p_effective_end_date
          ,p_access_level           =>   p_access_level
          ,p_description            =>   p_description
          ,p_party_name             =>   p_party_name
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


  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.Reset_Err_Stack;
  END IF;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO UPDATE_PROJECT_SETS_PUB;
        END IF;

        -- 4537865  : RESET the OUT params properly
        x_msg_count := 1;
        x_msg_data := SUBSTRB(SQLERRM,1,120);

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PUB.Update_Project_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       --RAISE;

END update_project_set;


PROCEDURE delete_project_set
 (p_project_set_id         IN    pa_project_sets_b.project_set_id%TYPE            := NULL
 ,p_record_version_number  IN    pa_project_sets_b.record_version_number%TYPE     := NULL
 ,p_api_version            IN    NUMBER                                           := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                         := FND_API.G_FALSE
 ,p_commit                 IN    VARCHAR2                                         := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                         := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status          VARCHAR2(1);
 l_msg_index_out          NUMBER;
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

  -- Initialize the Error Stack
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.init_err_stack('PA_PROJECT_SETS_PUB.Delete_Project_Set');
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transproject is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT Delete_PROJECT_SETS_PUB;
  END IF;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Delete_Project_Set.begin'
                     ,x_msg         => 'Beginning of Delete_Project_Set pub'
                     ,x_log_level   => 5);

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Delete_Project_Set.begin'
                     ,x_msg         => 'calling Delete_Project_Set pvt'
                     ,x_log_level   => 5);
  END IF;

  PA_PROJECT_SETS_PVT.delete_project_set
          (p_project_set_id         =>   p_project_set_id
          ,p_record_version_number  =>   p_record_version_number
          ,x_return_status          =>   l_return_status);

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.Reset_Err_Stack;
  END IF;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO Delete_PROJECT_SETS_PUB;
        END IF;

         -- 4537865  : RESET the OUT params properly
        x_msg_count := 1;
        x_msg_data := SUBSTRB(SQLERRM,1,120);

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PUB.Delete_Project_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END delete_project_set;


PROCEDURE create_project_set_line
 (p_project_set_id           IN    pa_project_set_lines.project_set_id%TYPE
 ,p_project_id               IN    pa_project_set_lines.project_id%TYPE
 ,p_api_version              IN    NUMBER                                       := 1.0
 ,p_init_msg_list            IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_commit                   IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only            IN    VARCHAR2                                     := FND_API.G_TRUE
 ,x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status   VARCHAR2(1);
 l_msg_index_out   NUMBER;
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

  -- Initialize the Error Stack
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.init_err_stack('PA_PROJECT_SETS_PUB.Create_Project_Set_Line');
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transproject is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT CREATE_PROJECT_SET_LINE_PUB;
  END IF;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Create_Project_Set_Line.begin'
                     ,x_msg         => 'Beginning of Create_Project_Set_Line pub'
                     ,x_log_level   => 5);

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Create_Project_Set_Line.begin'
                     ,x_msg         => 'calling create_Project_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;


  PA_PROJECT_SETS_PVT.create_project_set_line
          (p_project_set_id     =>   p_project_set_id
          ,p_project_id         =>   p_project_id
          ,x_return_status      =>   l_return_status);

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.Reset_Err_Stack;
  END IF;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO CREATE_PROJECT_SET_LINE_PUB;
        END IF;

         -- 4537865  : RESET the OUT params properly
        x_msg_count := 1;
        x_msg_data := SUBSTRB(SQLERRM,1,120);

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PUB.Create_Project_Set_Line'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       --RAISE;

 END create_project_set_line;



PROCEDURE delete_project_set_line
 (p_project_set_id         IN    pa_project_set_lines.project_set_id%TYPE
 ,p_project_id             IN    pa_project_set_lines.project_id%TYPE
 ,p_api_version            IN    NUMBER                                           := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                         := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                         := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                         := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status          VARCHAR2(1);
 l_msg_index_out          NUMBER;
 l_project_set_id         NUMBER;
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

  -- Initialize the Error Stack
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.init_err_stack('PA_PROJECT_SETS_PUB.Delete_Project_Set_Line');
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transproject is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT Delete_PROJECT_SET_LINE_PUB;
  END IF;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Delete_Project_Set_Line.begin'
                     ,x_msg         => 'Beginning of Delete_Project_Set_Line pub'
                     ,x_log_level   => 5);

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_PUB.Delete_Project_Set_Line.begin'
                     ,x_msg         => 'calling Delete_Project_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  PA_PROJECT_SETS_PVT.delete_project_set_line
          (p_project_set_id     =>   p_project_set_id
          ,p_project_id         =>   p_project_id
          ,x_return_status      =>   l_return_status);

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.Reset_Err_Stack;
  END IF;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO Delete_PROJECT_SET_LINE_PUB;
        END IF;

        -- 4537865  : RESET the OUT params properly
        x_msg_count := 1;
        x_msg_data := SUBSTRB(SQLERRM,1,120);

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PUB.Delete_Project_Set_Line'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       --RAISE;

END delete_project_set_line;

-- Update_PC_PARTY_MAERGE (PUBLIC)
--   This is the procedure being called during the Party Merge.
--   The input/output arguments format matches the document PartyMergeDD.doc.
--   The goal is to fix PARTY_ID in pa_project_sets_b table to point to the
--   same party when two parties are begin merged.
--
-- Usage example in pl/sql
--   This procedure should only be called from the PartyMerge utility.

procedure party_merge(
  p_entity_name            IN     varchar2
 ,p_from_id                IN     number
 ,p_to_id in               OUT    nocopy number
 ,p_from_fk_id             IN     number
 ,p_to_fk_id               IN     number
 ,p_parent_entity_name     IN     varchar2
 ,p_batch_id               IN     number
 ,p_batch_party_id         IN     number
 ,p_return_status          IN OUT nocopy varchar2
) IS
l_incoming_p_to_id NUMBER ; -- 4537865
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  l_incoming_p_to_id := p_to_id ; -- 4537865

  if (p_from_fk_id <> p_to_fk_id) then

    update PA_PROJECT_SETS_B
    set PARTY_ID              = p_to_fk_id,
        last_update_date      = hz_utility_pub.last_update_date,
        last_updated_by       = hz_utility_pub.user_id,
        last_update_login     = hz_utility_pub.last_update_login,
        record_version_number = nvl(record_Version_number,0) +1
    where PARTY_ID = p_from_fk_id;

    p_to_id := p_from_id;

  end if;
-- 4537865
EXCEPTION
	WHEN OTHERS THEN
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	p_to_id := l_incoming_p_to_id ; --  RESET this IN OUT param to the same IN value got

	FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_PROJECT_SETS_PUB'
         , p_procedure_name      => 'Party_Merge'
	 , p_error_text		=> SUBSTRB(SQLERRM,1,240));

	-- Not RAISING because all similar APIs to this one doesnt raise
END Party_Merge;

END pa_project_sets_pub;

/
