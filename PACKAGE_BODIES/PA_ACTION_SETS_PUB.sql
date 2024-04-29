--------------------------------------------------------
--  DDL for Package Body PA_ACTION_SETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACTION_SETS_PUB" AS
/*$Header: PARASPUB.pls 120.3 2007/02/06 09:45:50 dthakker ship $*/
--
PROCEDURE create_action_set
 (p_action_set_type_code   IN    pa_action_set_types.action_set_type_code%TYPE
 ,p_action_set_name        IN    pa_action_sets.action_set_name%TYPE
 ,p_object_type            IN    pa_action_sets.object_type%TYPE              := NULL
 ,p_object_id              IN    pa_action_sets.object_id%TYPE                := NULL
 ,p_start_date_active      IN    pa_action_sets.start_date_active%TYPE        := NULL
 ,p_end_date_active        IN    pa_action_sets.end_date_active%TYPE          := NULL
 ,p_action_set_template_flag IN  pa_action_sets.action_set_template_flag%TYPE := NULL
 ,p_source_action_set_id   IN    pa_action_sets.source_action_set_id%TYPE     := NULL
 ,p_status_code            IN    pa_action_sets.status_code%TYPE              := NULL
 ,p_description            IN    pa_action_sets.description%TYPE              := NULL
 ,p_attribute_category     IN    pa_action_sets.attribute_category%TYPE       := NULL
 ,p_attribute1             IN    pa_action_sets.attribute1%TYPE               := NULL
 ,p_attribute2             IN    pa_action_sets.attribute2%TYPE               := NULL
 ,p_attribute3             IN    pa_action_sets.attribute3%TYPE               := NULL
 ,p_attribute4             IN    pa_action_sets.attribute4%TYPE               := NULL
 ,p_attribute5             IN    pa_action_sets.attribute5%TYPE               := NULL
 ,p_attribute6             IN    pa_action_sets.attribute6%TYPE               := NULL
 ,p_attribute7             IN    pa_action_sets.attribute7%TYPE               := NULL
 ,p_attribute8             IN    pa_action_sets.attribute8%TYPE               := NULL
 ,p_attribute9             IN    pa_action_sets.attribute9%TYPE               := NULL
 ,p_attribute10            IN    pa_action_sets.attribute10%TYPE              := NULL
 ,p_attribute11            IN    pa_action_sets.attribute11%TYPE              := NULL
 ,p_attribute12            IN    pa_action_sets.attribute12%TYPE              := NULL
 ,p_attribute13            IN    pa_action_sets.attribute13%TYPE              := NULL
 ,p_attribute14            IN    pa_action_sets.attribute14%TYPE              := NULL
 ,p_attribute15            IN    pa_action_sets.attribute15%TYPE              := NULL
 ,p_api_version            IN    NUMBER                                       := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                     := FND_API.G_TRUE
 ,x_action_set_id         OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status   VARCHAR2(1);
 l_msg_index_out   NUMBER;
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.Create_Action_Set');

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT CREATE_ACTION_SETS_PUB;
  END IF;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Create_Action_Set.begin'
                     ,x_msg         => 'Beginning of Create_Action_Set pub'
                     ,x_log_level   => 5);

    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Create_Action_Set.begin'
                     ,x_msg         => 'calling create_Action_Set pvt'
                     ,x_log_level   => 5);
  END IF;


  PA_ACTION_SETS_PVT.create_action_set
          (p_action_set_type_code   =>   p_action_set_type_code
          ,p_action_set_name        =>   p_action_set_name
          ,p_object_type            =>   p_object_type
          ,p_object_id              =>   p_object_id
          ,p_start_date_active      =>   p_start_date_active
          ,p_end_date_active        =>   p_end_date_active
          ,p_action_set_template_flag => p_action_set_template_flag
          ,p_source_action_set_id   =>   p_source_action_set_id
          ,p_status_code            =>   p_status_code
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
          ,x_action_set_id          =>   x_action_set_id
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
  PA_DEBUG.Reset_Err_Stack;
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
          ROLLBACK TO CREATE_ACTION_SETS_PUB;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Create_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Create_Action_Set;


PROCEDURE update_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_name        IN    pa_action_sets.action_set_name%TYPE         := FND_API.G_MISS_CHAR
 ,p_object_type            IN    pa_action_sets.object_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_action_set_type_code   IN    pa_action_sets.action_set_type_code%TYPE    := FND_API.G_MISS_CHAR
 ,p_object_id              IN    pa_action_sets.object_id%TYPE               := FND_API.G_MISS_NUM
 ,p_start_date_active      IN    pa_action_sets.start_date_active%TYPE       := FND_API.G_MISS_DATE
 ,p_end_date_active        IN    pa_action_sets.end_date_active%TYPE         := FND_API.G_MISS_DATE
 ,p_action_set_template_flag IN  pa_action_sets.action_set_template_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_status_code            IN    pa_action_sets.status_code%TYPE              := FND_API.G_MISS_CHAR
 ,p_description            IN    pa_action_sets.description%TYPE             := FND_API.G_MISS_CHAR
 ,p_record_version_number  IN    pa_action_sets.record_version_number%TYPE
 ,p_attribute_category     IN    pa_action_sets.attribute_category%TYPE      := FND_API.G_MISS_CHAR
 ,p_attribute1             IN    pa_action_sets.attribute1%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute2             IN    pa_action_sets.attribute2%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute3             IN    pa_action_sets.attribute3%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute4             IN    pa_action_sets.attribute4%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute5             IN    pa_action_sets.attribute5%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute6             IN    pa_action_sets.attribute6%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute7             IN    pa_action_sets.attribute7%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute8             IN    pa_action_sets.attribute8%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute9             IN    pa_action_sets.attribute9%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute10            IN    pa_action_sets.attribute10%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute11            IN    pa_action_sets.attribute11%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute12            IN    pa_action_sets.attribute12%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute13            IN    pa_action_sets.attribute13%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute14            IN    pa_action_sets.attribute14%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute15            IN    pa_action_sets.attribute15%TYPE             := FND_API.G_MISS_CHAR
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
 l_action_set_id          NUMBER;
 l_record_version_number  NUMBER;
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.Update_Action_Set');

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT UPDATE_ACTION_SETS_PUB;
  END IF;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Update_Action_Set.begin'
                     ,x_msg         => 'Beginning of Update_Action_Set pub'
                     ,x_log_level   => 5);
  END IF;

  l_action_set_id := p_action_set_id;

  IF l_action_set_id IS NULL THEN
     l_action_set_id := PA_ACTION_SET_UTILS.get_action_set_id
                                       (p_action_set_type_code => p_action_set_type_code,
                                        p_object_type          => p_object_type,
                                        p_object_id            => p_object_id);
  END IF;

  BEGIN

     SELECT record_version_number INTO l_record_version_number
       FROM pa_action_sets
      WHERE action_set_id = l_action_set_id
        AND record_version_number = p_record_version_number;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');

  END;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Update_Action_Set.begin'
                     ,x_msg         => 'calling Update_Action_Set pvt'
                     ,x_log_level   => 5);
  END IF;

  PA_ACTION_SETS_PVT.update_action_set
          (p_action_set_id          =>   l_action_set_id
          ,p_action_set_name        =>   p_action_set_name
          ,p_action_set_type_code   =>   p_action_set_type_code
          ,p_start_date_active      =>   p_start_date_active
          ,p_end_date_active        =>   p_end_date_active
          ,p_status_code            =>   p_status_code
          ,p_description            =>   p_description
          ,p_record_version_number  =>   p_record_version_number
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
  PA_DEBUG.Reset_Err_Stack;
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
          ROLLBACK TO UPDATE_ACTION_SETS_PUB;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Update_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Update_Action_Set;


PROCEDURE delete_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_type_code   IN    pa_action_sets.action_set_type_code%TYPE    := NULL
 ,p_object_type            IN    pa_action_sets.object_type%TYPE             := NULL
 ,p_object_id              IN    pa_action_sets.object_id%TYPE               := NULL
 ,p_record_version_number  IN    pa_action_sets.record_version_number%TYPE
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
 l_action_set_id          NUMBER;
 l_record_version_number  NUMBER;
 l_debug_mode            VARCHAR2(20) := 'N';

-- Start 5130421
 l_start_msg_count        NUMBER;
 l_end_msg_count          NUMBER;
 l_current_api_msg_count  NUMBER;
-- End 5130421
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.Delete_Action_Set');

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- 5130421
  l_start_msg_count := FND_MSG_PUB.count_msg ;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT Delete_ACTION_SETS_PUB;
  END IF;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Delete_Action_Set.begin'
                     ,x_msg         => 'Beginning of Delete_Action_Set pub'
                     ,x_log_level   => 5);
  END IF;

  l_action_set_id := p_action_set_id;

  IF l_action_set_id IS NULL THEN
     l_action_set_id := PA_ACTION_SET_UTILS.get_action_set_id
                                       (p_action_set_type_code => p_action_set_type_code,
                                        p_object_type          => p_object_type,
                                        p_object_id            => p_object_id);
  END IF;

  BEGIN

     SELECT record_version_number INTO l_record_version_number
       FROM pa_action_sets
      WHERE action_set_id = l_action_set_id
        AND record_version_number = p_record_version_number;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');

  END;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Delete_Action_Set.begin'
                     ,x_msg         => 'calling Delete_Action_Set pvt'
                     ,x_log_level   => 5);
  END IF;

  PA_ACTION_SETS_PVT.delete_action_set
          (p_action_set_id          =>   l_action_set_id
          ,p_record_version_number  =>   p_record_version_number
          ,x_return_status          =>   l_return_status);

  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  -- 5130421
  l_end_msg_count := FND_MSG_PUB.Count_Msg;

  l_current_api_msg_count := l_end_msg_count - l_start_msg_count;

  -- 5130421 IF x_msg_count = 1 THEN
  IF l_current_api_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
  -- If any errors exist then set the x_return_status to 'E'

  -- 5130421 IF x_msg_count > 0  THEN
  IF l_current_api_msg_count > 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO Delete_ACTION_SETS_PUB;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Delete_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Delete_Action_Set;




PROCEDURE create_action_set_line
 (p_action_set_id            IN    pa_action_sets.action_set_id%TYPE
 ,p_use_def_description_flag IN    VARCHAR2                                        := 'Y'
 ,p_description              IN    pa_action_set_lines.description%TYPE            := NULL
 ,p_action_set_line_number   IN    pa_action_set_lines.action_set_line_number%TYPE := NULL
 ,p_action_code              IN    pa_action_set_lines.action_code%TYPE
 ,p_action_attribute1        IN    pa_action_set_lines.action_attribute1%TYPE   := NULL
 ,p_action_attribute2        IN    pa_action_set_lines.action_attribute2%TYPE   := NULL
 ,p_action_attribute3        IN    pa_action_set_lines.action_attribute3%TYPE   := NULL
 ,p_action_attribute4        IN    pa_action_set_lines.action_attribute4%TYPE   := NULL
 ,p_action_attribute5        IN    pa_action_set_lines.action_attribute5%TYPE   := NULL
 ,p_action_attribute6        IN    pa_action_set_lines.action_attribute6%TYPE   := NULL
 ,p_action_attribute7        IN    pa_action_set_lines.action_attribute7%TYPE   := NULL
 ,p_action_attribute8        IN    pa_action_set_lines.action_attribute8%TYPE   := NULL
 ,p_action_attribute9        IN    pa_action_set_lines.action_attribute9%TYPE   := NULL
 ,p_action_attribute10       IN    pa_action_set_lines.action_attribute10%TYPE  := NULL
 ,p_condition_tbl            IN    pa_action_set_utils.action_line_cond_tbl_type
 ,p_api_version              IN    NUMBER                                       := 1.0
 ,p_init_msg_list            IN    VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                   IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only            IN    VARCHAR2                                     := FND_API.G_TRUE
 ,x_action_set_line_id      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status   VARCHAR2(1);
 l_msg_index_out   NUMBER;
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.Create_Action_Set_Line');

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT CREATE_ACTION_SET_LINE_PUB;
  END IF;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Create_Action_Set_Line.begin'
                     ,x_msg         => 'Beginning of Create_Action_Set_Line pub'
                     ,x_log_level   => 5);

    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Create_Action_SetLine.begin'
                     ,x_msg         => 'calling create_Action_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  PA_ACTION_SETS_PVT.create_action_set_line
          (p_action_set_id            =>   p_action_set_id
          ,p_use_def_description_flag =>   p_use_def_description_flag
          ,p_description              =>   p_description
          ,p_action_set_line_number   =>   p_action_set_line_number
          ,p_action_code              =>   p_action_code
          ,p_action_attribute1        =>   p_action_attribute1
          ,p_action_attribute2        =>   p_action_attribute2
          ,p_action_attribute3        =>   p_action_attribute3
          ,p_action_attribute4        =>   p_action_attribute4
          ,p_action_attribute5        =>   p_action_attribute5
          ,p_action_attribute6        =>   p_action_attribute6
          ,p_action_attribute7        =>   p_action_attribute7
          ,p_action_attribute8        =>   p_action_attribute8
          ,p_action_attribute9        =>   p_action_attribute9
          ,p_action_attribute10       =>   p_action_attribute10
          ,p_condition_tbl            =>   p_condition_tbl
          ,x_action_set_line_id       =>   x_action_set_line_id
          ,x_return_status            =>   l_return_status);

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
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
          ROLLBACK TO CREATE_ACTION_SET_LINE_PUB;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Create_Action_Set_Line'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Create_Action_Set_Line;


PROCEDURE update_action_set_line
 (p_action_set_line_id       IN    pa_action_set_lines.action_set_line_id%TYPE
 ,p_record_version_number    IN    pa_action_set_lines.record_version_number%TYPE
 ,p_action_set_line_number   IN    pa_action_set_lines.action_set_line_number%TYPE := FND_API.G_MISS_NUM
 ,p_use_def_description_flag IN    VARCHAR2                                     := 'Y'
 ,p_description              IN    pa_action_set_lines.description%TYPE         := FND_API.G_MISS_CHAR
 ,p_action_code              IN    pa_action_set_lines.action_code%TYPE         := FND_API.G_MISS_CHAR
 ,p_action_attribute1        IN    pa_action_set_lines.action_attribute1%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute2        IN    pa_action_set_lines.action_attribute2%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute3        IN    pa_action_set_lines.action_attribute3%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute4        IN    pa_action_set_lines.action_attribute4%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute5        IN    pa_action_set_lines.action_attribute5%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute6        IN    pa_action_set_lines.action_attribute6%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute7        IN    pa_action_set_lines.action_attribute7%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute8        IN    pa_action_set_lines.action_attribute8%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute9        IN    pa_action_set_lines.action_attribute9%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute10       IN    pa_action_set_lines.action_attribute10%TYPE  := FND_API.G_MISS_CHAR
 ,p_condition_tbl            IN    pa_action_set_utils.action_line_cond_tbl_type
 ,p_api_version            IN    NUMBER                                           := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                         := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                         := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                         := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status           VARCHAR2(1);
 l_msg_index_out           NUMBER;
 l_action_set_id           NUMBER;
 l_record_version_number   NUMBER;
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.Update_Action_Set_Line');

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT UPDATE_ACTION_SET_LINE_PUB;
  END IF;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Update_Action_Set_Line.begin'
                     ,x_msg         => 'Beginning of Update_Action_Set_Line pub'
                     ,x_log_level   => 5);

    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Update_Action_Set_Line.begin'
                     ,x_msg         => 'calling Update_Action_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  PA_ACTION_SETS_PVT.update_action_set_line
          (p_action_set_line_id       =>   p_action_set_line_id
          ,p_record_version_number    =>   p_record_version_number
          ,p_description              =>   p_description
          ,p_action_set_line_number   =>   p_action_set_line_number
          ,p_action_code              =>   p_action_code
          ,p_action_attribute1        =>   p_action_attribute1
          ,p_action_attribute2        =>   p_action_attribute2
          ,p_action_attribute3        =>   p_action_attribute3
          ,p_action_attribute4        =>   p_action_attribute4
          ,p_action_attribute5        =>   p_action_attribute5
          ,p_action_attribute6        =>   p_action_attribute6
          ,p_action_attribute7        =>   p_action_attribute7
          ,p_action_attribute8        =>   p_action_attribute8
          ,p_action_attribute9        =>   p_action_attribute9
          ,p_action_attribute10       =>   p_action_attribute10
          ,p_condition_tbl            =>   p_condition_tbl
          ,x_return_status            =>   l_return_status);

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
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
          ROLLBACK TO UPDATE_ACTION_SET_LINE_PUB;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Update_Action_Set_Line'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Update_Action_Set_Line;


PROCEDURE delete_action_set_line
 (p_action_set_line_id     IN    pa_action_sets.action_set_id%TYPE                := NULL
 ,p_record_version_number  IN    pa_action_set_lines.record_version_number%TYPE   := NULL
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
 l_action_set_id          NUMBER;
 l_record_version_number  NUMBER;
 l_exists                 VARCHAR2(1);
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.Delete_Action_Set_Line');

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT Delete_ACTION_SET_LINE_PUB;
  END IF;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Delete_Action_Set_Line.begin'
                     ,x_msg         => 'Beginning of Delete_Action_Set_Line pub'
                     ,x_log_level   => 5);
  END IF;

  BEGIN

     SELECT record_version_number INTO l_record_version_number
       FROM pa_action_set_lines
      WHERE action_set_line_id = p_action_set_line_id
        AND record_version_number = p_record_version_number;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');

  END;

  PA_ACTION_SETS_PVT.delete_action_set_line
          (p_action_set_line_id     =>   p_action_set_line_id
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
  PA_DEBUG.Reset_Err_Stack;
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
          ROLLBACK TO Delete_ACTION_SET_LINE_PUB;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Delete_Action_Set_Line'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Delete_Action_Set_Line;


PROCEDURE apply_action_set
 (p_action_set_id           IN    pa_action_sets.action_set_id%TYPE            := NULL
 ,p_object_type             IN    pa_action_sets.object_type%TYPE              := NULL
 ,p_object_id               IN    pa_action_sets.object_id%TYPE                := NULL
 ,p_perform_action_set_flag IN    VARCHAR2                                     := 'N'
 ,p_api_version             IN    NUMBER                                       := 1.0
 ,p_init_msg_list           IN    VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                  IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only           IN    VARCHAR2                                     := FND_API.G_TRUE
 ,x_new_action_set_id      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status          OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count              OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_action_set_lines_tbl          pa_action_set_utils.action_set_lines_tbl_type;
l_action_line_conditions_tbl    pa_action_set_utils.action_line_cond_tbl_type;
l_new_action_set_id             pa_action_sets.action_set_id%TYPE;
l_action_set_name               pa_action_sets.action_set_name%TYPE;
l_action_set_type_code          pa_action_set_types.action_set_type_code%TYPE;
l_description                   pa_action_sets.description%TYPE;
l_attribute_category            pa_action_sets.attribute_category%TYPE;
l_attribute1                    pa_action_sets.attribute1%TYPE;
l_attribute2                    pa_action_sets.attribute2%TYPE;
l_attribute3                    pa_action_sets.attribute3%TYPE;
l_attribute4                    pa_action_sets.attribute4%TYPE;
l_attribute5                    pa_action_sets.attribute5%TYPE;
l_attribute6                    pa_action_sets.attribute6%TYPE;
l_attribute7                    pa_action_sets.attribute7%TYPE;
l_attribute8                    pa_action_sets.attribute8%TYPE;
l_attribute9                    pa_action_sets.attribute9%TYPE;
l_attribute10                   pa_action_sets.attribute10%TYPE;
l_attribute11                   pa_action_sets.attribute11%TYPE;
l_attribute12                   pa_action_sets.attribute12%TYPE;
l_attribute13                   pa_action_sets.attribute13%TYPE;
l_attribute14                   pa_action_sets.attribute14%TYPE;
l_attribute15                   pa_action_sets.attribute15%TYPE;
l_action_set_line_id            pa_action_set_line_cond.action_set_line_id%TYPE;
l_return_status                 VARCHAR2(1);
l_msg_index_out                 NUMBER;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
e_invalid_result_code           EXCEPTION;
l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.Apply_Action_Set');

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT APPLY_ACTION_SET_PUB;
  END IF;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Apply_Action_Set.begin'
                     ,x_msg         => 'Beginning of Apply_Action_Set pub'
                     ,x_log_level   => 5);

    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Apply_Action_Set'
                     ,x_msg         => 'FND_MSG_PUB.Count_Msg = '||FND_MSG_PUB.Count_Msg
                     ,x_log_level   => 5);
  END IF;

  SELECT
         action_set_name,
         action_set_type_code,
         description,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15
    INTO
         l_action_set_name,
         l_action_set_type_code,
         l_description,
         l_attribute_category,
         l_attribute1,
         l_attribute2,
         l_attribute3,
         l_attribute4,
         l_attribute5,
         l_attribute6,
         l_attribute7,
         l_attribute8,
         l_attribute9,
         l_attribute10,
         l_attribute11,
         l_attribute12,
         l_attribute13,
         l_attribute14,
         l_attribute15
    FROM pa_action_sets
   WHERE action_set_id = p_action_set_id;

   create_action_set(
           p_action_set_type_code     =>   l_action_set_type_code
          ,p_action_set_name          =>   l_action_set_name
          ,p_object_type              =>   p_object_type
          ,p_object_id                =>   p_object_id
          ,p_start_date_active        =>   NULL
          ,p_end_date_active          =>   NULL
          ,p_action_set_template_flag => 'N'
          ,p_source_action_set_id     =>   p_action_set_id
          ,p_description              =>   l_description
          ,p_attribute_category       =>   l_attribute_category
          ,p_attribute1               =>   l_attribute1
          ,p_attribute2               =>   l_attribute2
          ,p_attribute3               =>   l_attribute3
          ,p_attribute4               =>   l_attribute4
          ,p_attribute5               =>   l_attribute5
          ,p_attribute6               =>   l_attribute6
          ,p_attribute7               =>   l_attribute7
          ,p_attribute8               =>   l_attribute8
          ,p_attribute9               =>   l_attribute9
          ,p_attribute10              =>   l_attribute10
          ,p_attribute11              =>   l_attribute11
          ,p_attribute12              =>   l_attribute12
          ,p_attribute13              =>   l_attribute13
          ,p_attribute14              =>   l_attribute14
          ,p_attribute15              =>   l_attribute15
          ,p_init_msg_list            =>   FND_API.G_FALSE
          ,x_action_set_id            =>   x_new_action_set_id
          ,x_return_status            =>   l_return_status
          ,x_msg_count                =>   l_msg_count
          ,x_msg_data                 =>   l_msg_data);



  l_action_set_lines_tbl := PA_ACTION_SET_UTILS.get_action_set_lines(p_action_set_id => p_action_set_id);

  IF l_action_set_lines_tbl.COUNT >0 THEN
  FOR i IN l_action_set_lines_tbl.FIRST .. l_action_set_lines_tbl.LAST LOOP

      l_action_line_conditions_tbl := PA_ACTION_SET_UTILS.get_action_line_conditions
                                          (p_action_set_line_id => l_action_set_lines_tbl(i).action_set_line_id);

     create_action_set_line(
           p_action_set_id            =>   x_new_action_set_id
          ,p_description              =>   l_action_set_lines_tbl(i).description
          ,p_action_code              =>   l_action_set_lines_tbl(i).action_code
          ,p_action_attribute1        =>   l_action_set_lines_tbl(i).action_attribute1
          ,p_action_attribute2        =>   l_action_set_lines_tbl(i).action_attribute2
          ,p_action_attribute3        =>   l_action_set_lines_tbl(i).action_attribute3
          ,p_action_attribute4        =>   l_action_set_lines_tbl(i).action_attribute4
          ,p_action_attribute5        =>   l_action_set_lines_tbl(i).action_attribute5
          ,p_action_attribute6        =>   l_action_set_lines_tbl(i).action_attribute6
          ,p_action_attribute7        =>   l_action_set_lines_tbl(i).action_attribute7
          ,p_action_attribute8        =>   l_action_set_lines_tbl(i).action_attribute8
          ,p_action_attribute9        =>   l_action_set_lines_tbl(i).action_attribute9
          ,p_action_attribute10       =>   l_action_set_lines_tbl(i).action_attribute10
          ,p_condition_tbl            =>   l_action_line_conditions_tbl
          ,x_action_set_line_id       =>   l_action_set_line_id
          ,p_init_msg_list            =>   FND_API.G_FALSE
          ,x_return_status            =>   l_return_status
          ,x_msg_count                =>   l_msg_count
          ,x_msg_data                 =>   l_msg_data);

  END LOOP;
  END IF;

  process_action_set(p_action_set_id            =>   x_new_action_set_id
                    ,x_return_status            =>   l_return_status
                    ,x_msg_count                =>   l_msg_count
                    ,x_msg_data                 =>   l_msg_data);

  IF p_perform_action_set_flag = 'Y' AND FND_MSG_PUB.Count_Msg = 0 THEN

     Perform_Single_Action_Set(p_action_set_id            =>   x_new_action_set_id
                              ,p_init_msg_list            =>   FND_API.G_FALSE
                              ,x_return_status            =>   l_return_status
                              ,x_msg_count                =>   l_msg_count
                              ,x_msg_data                 =>   l_msg_data);

  END IF;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Apply_Action_Set.begin'
                     ,x_msg         => 'calling Perform_Action_Set_Line pub'
                     ,x_log_level   => 5);
  END IF;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
  -- If any errors exist then set the x_return_status to 'E'

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO APPLY_ACTION_SET_PUB;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Apply_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END;


PROCEDURE replace_action_set
 (p_current_action_set_id  IN    pa_action_sets.action_set_id%TYPE             := NULL
 ,p_action_set_type_code   IN    pa_action_set_types.action_set_type_code%TYPE := NULL
 ,p_object_type            IN    pa_action_sets.object_type%TYPE               := NULL
 ,p_object_id              IN    pa_action_sets.object_id%TYPE                 := NULL
 ,p_record_version_number  IN    pa_action_sets.record_version_number%TYPE
 ,p_new_action_set_id      IN    pa_action_sets.action_set_id%TYPE
 ,p_api_version            IN    NUMBER                                        := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                      := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                      := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                      := FND_API.G_TRUE
 ,x_new_action_set_id     OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

l_return_status                 VARCHAR2(1);
l_msg_index_out                 NUMBER;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_action_set_id                 pa_action_sets.action_set_id%TYPE;
l_new_action_set_id             pa_action_sets.action_set_id%TYPE;
l_current_action_set_id         pa_action_sets.action_set_id%TYPE;
e_invalid_result_code           EXCEPTION;
l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.Replace_Action_Set');

  -- Bug 4370082
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT REPLACE_ACTION_SET_PUB;
  END IF;

  --Log Message: 4370082
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Replace_Action_Set.begin'
                     ,x_msg         => 'Beginning of Replace_Action_Set pub'
                     ,x_log_level   => 5);
  END IF;

  l_current_action_set_id := p_current_action_set_id;

  IF l_current_action_set_id IS NULL THEN
     l_current_action_set_id := PA_ACTION_SET_UTILS.get_action_set_id
                                        (p_action_set_type_code => p_action_set_type_code,
                                         p_object_type          => p_object_type,
                                         p_object_id            => p_object_id);
  END IF;


   delete_action_set(
           p_action_set_id          =>   l_current_action_set_id
          ,p_record_version_number  =>   p_record_version_number
          ,p_init_msg_list          =>   FND_API.G_FALSE
          ,x_return_status          =>   l_return_status
          ,x_msg_count              =>   l_msg_count
          ,x_msg_data               =>   l_msg_data);

  IF FND_MSG_PUB.Count_Msg = 0 THEN

     --Log Message: 4370082
     IF l_debug_mode = 'Y' THEN
       PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Replace_Action_Set.begin'
                        ,x_msg         => 'calling Apply_Action_Set pub'
                        ,x_log_level   => 5);
     END IF;

     Apply_Action_Set(p_action_set_id            =>   p_new_action_set_id
                     ,p_object_type              =>   p_object_type
                     ,p_object_id                =>   p_object_id
                     ,p_init_msg_list            =>   FND_API.G_FALSE
                     ,x_new_action_set_id        =>   x_new_action_set_id
                     ,x_return_status            =>   l_return_status
                     ,x_msg_count                =>   l_msg_count
                     ,x_msg_data                 =>   l_msg_data);

  END IF;


  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN e_invalid_result_code THEN
/*
      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Perform_Action_Set_Line'
                               ,p_procedure_name => 'INVALID RESULTS CODE:  '||l_action_line_result_code);
      --
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
*/
      RAISE;
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO REPLACE_ACTION_SET;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Replace_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END;



PROCEDURE perform_single_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE             := NULL
 ,p_action_set_type_code   IN    pa_action_set_types.action_set_type_code%TYPE := NULL
 ,p_object_type            IN    pa_action_sets.object_type%TYPE               := NULL
 ,p_object_id              IN    pa_action_sets.object_id%TYPE                 := NULL
 ,p_api_version            IN    NUMBER                                        := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                      := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                      := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                      := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)  IS

l_return_status                 VARCHAR2(1);
l_msg_index_out                 NUMBER;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_action_set_id                 pa_action_sets.action_set_id%TYPE;
l_action_set_type_code          pa_action_set_types.action_set_type_code%TYPE;
e_invalid_result_code           EXCEPTION;

CURSOR get_action_set_lines(p_action_set_id IN NUMBER) IS
SELECT action_set_line_id
  FROM pa_action_set_lines l,
       pa_action_sets s
 WHERE s.action_set_id = p_action_set_id
   AND s.action_set_id = l.action_set_id
   AND s.status_code IN ('STARTED','RESUMED')
   AND l.status_code IN ('PENDING','ACTIVE','REVERSE_PENDING','UPDATE_PENDING')
ORDER BY l.action_set_line_number;

TYPE number_tbl_type IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
l_action_set_line_id_tbl  number_tbl_type;

l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.Perform_Single_Action_Set');

  -- Bug 4370082
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT PERFORM_SINGLE_ACTION_SET_PUB;
  END IF;

  --Log Message: 4370082
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PUB.Perform_Single_Action_Set.begin'
                     ,x_msg         => 'Beginning of Perform_Single_Action_Set pub'
                     ,x_log_level   => 5);
  END IF;

  PA_ACTION_SET_UTILS.G_ERROR_EXISTS := 'N';
--  PA_ACTION_SETS_PVT.g_line_errors_tbl.DELETE;

  l_action_set_type_code := p_action_set_type_code;

  IF l_action_set_type_code IS NULL THEN
     SELECT action_set_type_code INTO l_action_set_type_code
       FROM pa_action_sets
      WHERE action_set_id = p_action_set_id;
  END IF;

  l_action_set_id := p_action_set_id;

  IF l_action_set_id IS NULL THEN
     l_action_set_id := PA_ACTION_SET_UTILS.get_action_set_id
                                       (p_action_set_type_code => l_action_set_type_code,
                                        p_object_type          => p_object_type,
                                        p_object_id            => p_object_id);
  END IF;

   OPEN  get_action_set_lines(l_action_set_id);
   FETCH get_action_set_lines BULK COLLECT INTO l_action_set_line_id_tbl;
   CLOSE get_action_set_lines;

  --Log Message: 4370082
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Perform_Action_Set_Line'
                     ,x_msg         => 'calling Perform_ActionSet_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  IF l_action_set_line_id_tbl.COUNT > 0 THEN

     FOR i IN l_action_set_line_id_tbl.FIRST .. l_action_set_line_id_tbl.LAST LOOP

        FND_MSG_PUB.initialize;

        PA_ACTION_SETS_PVT.Perform_Action_Set_Line(p_action_set_type_code  => l_action_set_type_code ,
                                                   p_action_set_line_id    => l_action_set_line_id_tbl(i)
                                                  ,x_return_status         => l_return_status);

     END LOOP;

     -- 2452311: Need to initialize the error stack after performing the last
     -- action set line.
     FND_MSG_PUB.initialize;

  END IF;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0 OR PA_ACTION_SET_UTILS.G_ERROR_EXISTS = 'Y' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND x_msg_count = 0 THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO PERFORM_SINGLE_ACTION_SET;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Perform_Single_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END;


PROCEDURE Perform_Action_Sets(p_action_set_type_code  IN VARCHAR2,
                              p_project_number_from   IN VARCHAR2,
                              p_project_number_to     IN VARCHAR2,
                              p_debug_mode            IN VARCHAR2,
                              x_return_status        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_action_set_type_code_tbl      pa_action_set_utils.varchar_tbl_type;
l_action_set_line_id_tbl        pa_action_set_utils.action_set_line_id_tbl_type;
l_object_name_tbl               pa_action_set_utils.object_name_tbl_type;
l_project_number_tbl            pa_action_set_utils.project_number_tbl_type;
l_return_status                 VARCHAR2(1);
e_invalid_result_code           EXCEPTION;

BEGIN
/*
--TESTING
             DELETE from pa_action_set_report_temp;
             INSERT INTO pa_action_set_report_temp(action_set_line_id,
                                                   project_number,
                                                   object_name)
                                            select action_set_line_id, 'OBJ NAME', 'PROJ NAME'
                                               from pa_action_set_lines;
*/

IF p_debug_mode = 'Y' THEN

   FND_FILE.PUT_LINE(FND_FILE.LOG,'p_action_set_type_code='||p_action_set_type_code);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'p_project_number_from='||p_project_number_from);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'p_project_number_to='||p_project_number_to);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'user_id='||FND_GLOBAL.user_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'concurrent request id='||FND_GLOBAL.CONC_REQUEST_ID);

END IF;

  DELETE FROM pa_action_set_report_temp;

  IF p_action_set_type_code IS NULL THEN
     SELECT action_set_type_code BULK COLLECT INTO l_action_set_type_code_tbl
       FROM pa_action_set_types;
  ELSE
     l_action_set_type_code_tbl(1) := p_action_set_type_code;
  END IF;

  IF l_action_set_type_code_tbl.COUNT > 0 THEN

    FOR i IN l_action_set_type_code_tbl.FIRST .. l_action_set_type_code_tbl.LAST LOOP

       IF p_debug_mode = 'Y' THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Action Set Type Code = '||l_action_set_type_code_tbl(i));
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'About to get action set line ids');
       END IF;

       PA_ACTION_SETS_DYN.get_action_set_line_ids(p_action_set_type_code   =>   l_action_set_type_code_tbl(i),
                                                  p_project_number_from    =>   p_project_number_from,
                                                  p_project_number_to      =>   p_project_number_to,
                                                  x_action_set_line_id_tbl =>   l_action_set_line_id_tbl,
                                                  x_object_name_tbl        =>   l_object_name_tbl,
                                                  x_project_number_tbl     =>   l_project_number_tbl);

       IF p_debug_mode = 'Y' THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done getting action set line ids');
       END IF;

       IF l_action_set_line_id_tbl.COUNT > 0 THEN

          FORALL k IN l_action_set_line_id_tbl.FIRST .. l_action_set_line_id_tbl.LAST
             INSERT INTO pa_action_set_report_temp(action_set_line_id,
                                                   project_number,
                                                   object_name)
                                            VALUES(l_action_set_line_id_tbl(k),
                                                   l_project_number_tbl(k),
                                                   l_object_name_tbl(k));

          FOR j IN l_action_set_line_id_tbl.FIRST .. l_action_set_line_id_tbl.LAST LOOP

             FND_MSG_PUB.initialize;

             IF p_debug_mode = 'Y' THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'About to perform action set line id '||l_action_set_line_id_tbl(j));
             END IF;

             PA_ACTION_SETS_PVT.perform_action_set_line(p_action_set_type_code => l_action_set_type_code_tbl(i),
                                                        p_action_set_line_id   => l_action_set_line_id_tbl(j),
                                                        x_return_status        => l_return_status);

             COMMIT;

             IF p_debug_mode = 'Y' THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done performing action set line id '||l_action_set_line_id_tbl(j));
             END IF;

          END LOOP;

       END IF;

     END LOOP;

   END IF;

  EXCEPTION
    WHEN e_invalid_result_code THEN
/*
      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Perform_Action_Set_Line'
                               ,p_procedure_name => 'INVALID RESULTS CODE:  '||l_action_line_result_code);
      --
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
*/
      RAISE;

    WHEN OTHERS THEN
      -- Set the excetption Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Perform_Action_Set_Line'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
      --
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE;


END;



PROCEDURE create_line_single_cond
 (p_action_set_id            IN    pa_action_sets.action_set_id%TYPE
 ,p_use_def_description_flag IN    VARCHAR2                                        := 'Y'
 ,p_action_description       IN    pa_action_set_lines.description%TYPE            := NULL
 ,p_action_set_line_number   IN    pa_action_set_lines.action_set_line_number%TYPE := NULL
 ,p_action_code              IN    pa_action_set_lines.action_code%TYPE
 ,p_action_attribute1        IN    pa_action_set_lines.action_attribute1%TYPE   := NULL
 ,p_action_attribute2        IN    pa_action_set_lines.action_attribute2%TYPE   := NULL
 ,p_action_attribute3        IN    pa_action_set_lines.action_attribute3%TYPE   := NULL
 ,p_action_attribute4        IN    pa_action_set_lines.action_attribute4%TYPE   := NULL
 ,p_action_attribute5        IN    pa_action_set_lines.action_attribute5%TYPE   := NULL
 ,p_action_attribute6        IN    pa_action_set_lines.action_attribute6%TYPE   := NULL
 ,p_action_attribute7        IN    pa_action_set_lines.action_attribute7%TYPE   := NULL
 ,p_action_attribute8        IN    pa_action_set_lines.action_attribute8%TYPE   := NULL
 ,p_action_attribute9        IN    pa_action_set_lines.action_attribute9%TYPE   := NULL
 ,p_action_attribute10       IN    pa_action_set_lines.action_attribute10%TYPE  := NULL
 ,p_condition_description    IN    pa_action_set_line_cond.description%TYPE     := NULL
 ,p_condition_code           IN    pa_action_set_line_cond.condition_code%TYPE
 ,p_condition_attribute1     IN    pa_action_set_line_cond.condition_attribute1%TYPE   := NULL
 ,p_condition_attribute2     IN    pa_action_set_line_cond.condition_attribute2%TYPE   := NULL
 ,p_condition_attribute3     IN    pa_action_set_line_cond.condition_attribute3%TYPE   := NULL
 ,p_condition_attribute4     IN    pa_action_set_line_cond.condition_attribute4%TYPE   := NULL
 ,p_condition_attribute5     IN    pa_action_set_line_cond.condition_attribute5%TYPE   := NULL
 ,p_condition_attribute6     IN    pa_action_set_line_cond.condition_attribute6%TYPE   := NULL
 ,p_condition_attribute7     IN    pa_action_set_line_cond.condition_attribute7%TYPE   := NULL
 ,p_condition_attribute8     IN    pa_action_set_line_cond.condition_attribute8%TYPE   := NULL
 ,p_condition_attribute9     IN    pa_action_set_line_cond.condition_attribute9%TYPE   := NULL
 ,p_condition_attribute10    IN    pa_action_set_line_cond.condition_attribute10%TYPE  := NULL
 ,p_api_version              IN    NUMBER                                       := 1.0
 ,p_init_msg_list            IN    VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                   IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only            IN    VARCHAR2                                     := FND_API.G_TRUE
 ,x_action_set_line_id      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_condition_tbl    pa_action_set_utils.action_line_cond_tbl_type;
 l_action_set_template_flag    pa_action_sets.action_set_template_flag%TYPE;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.create_line_single_cond');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_condition_tbl(1).condition_code := p_condition_code;
  l_condition_tbl(1).description := p_condition_description;
  l_condition_tbl(1).condition_attribute1 := p_condition_attribute1;
  l_condition_tbl(1).condition_attribute2 := p_condition_attribute2;
  l_condition_tbl(1).condition_attribute3 := p_condition_attribute3;
  l_condition_tbl(1).condition_attribute4 := p_condition_attribute4;
  l_condition_tbl(1).condition_attribute5 := p_condition_attribute5;
  l_condition_tbl(1).condition_attribute6 := p_condition_attribute6;
  l_condition_tbl(1).condition_attribute7 := p_condition_attribute7;
  l_condition_tbl(1).condition_attribute8 := p_condition_attribute8;
  l_condition_tbl(1).condition_attribute9 := p_condition_attribute9;
  l_condition_tbl(1).condition_attribute10 := p_condition_attribute10;

  create_action_set_line
          (p_action_set_id            =>   p_action_set_id
          ,p_description              =>   p_action_description
          ,p_action_set_line_number   =>   p_action_set_line_number
          ,p_action_code              =>   p_action_code
          ,p_action_attribute1        =>   p_action_attribute1
          ,p_action_attribute2        =>   p_action_attribute2
          ,p_action_attribute3        =>   p_action_attribute3
          ,p_action_attribute4        =>   p_action_attribute4
          ,p_action_attribute5        =>   p_action_attribute5
          ,p_action_attribute6        =>   p_action_attribute6
          ,p_action_attribute7        =>   p_action_attribute7
          ,p_action_attribute8        =>   p_action_attribute8
          ,p_action_attribute9        =>   p_action_attribute9
          ,p_action_attribute10       =>   p_action_attribute10
          ,p_condition_tbl            =>   l_condition_tbl
          ,p_init_msg_list            =>   p_init_msg_list
          ,p_commit                   =>   p_commit
          ,p_validate_only            =>   p_validate_only
          ,x_action_set_line_id       =>   x_action_set_line_id
          ,x_return_status            =>   x_return_status
          ,x_msg_count                =>   x_msg_count
          ,x_msg_data                 =>   x_msg_data);

  -- 2452316: Need to set MOD_SOURCE_ACTION_SET_FLAG = 'Y' when a new line
  -- is added from self-service page. Should not put this logic in
  -- PA_ACTION_SET_PVT.create_action_set_line because that is also called when
  -- an action set is created for the first time.
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    SELECT action_set_template_flag
      INTO l_action_set_template_flag
      FROM pa_action_sets
      WHERE action_set_id = p_action_set_id;

    IF l_action_set_template_flag = 'N' THEN
      UPDATE pa_action_sets
        SET MOD_SOURCE_ACTION_SET_FLAG = 'Y'
        WHERE action_set_id = p_action_set_id;
    END IF;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.create_line_single_cond'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END;


PROCEDURE update_line_single_cond
 (p_action_set_line_id       IN    pa_action_sets.action_set_id%TYPE
 ,p_record_version_number    IN    NUMBER                                       := NULL
 ,p_action_description       IN    pa_action_set_lines.description%TYPE         := FND_API.G_MISS_CHAR
 ,p_action_code              IN    pa_action_set_lines.action_code%TYPE
 ,p_action_attribute1        IN    pa_action_set_lines.action_attribute1%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute2        IN    pa_action_set_lines.action_attribute2%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute3        IN    pa_action_set_lines.action_attribute3%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute4        IN    pa_action_set_lines.action_attribute4%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute5        IN    pa_action_set_lines.action_attribute5%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute6        IN    pa_action_set_lines.action_attribute6%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute7        IN    pa_action_set_lines.action_attribute7%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute8        IN    pa_action_set_lines.action_attribute8%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute9        IN    pa_action_set_lines.action_attribute9%TYPE   := FND_API.G_MISS_CHAR
 ,p_action_attribute10       IN    pa_action_set_lines.action_attribute10%TYPE  := FND_API.G_MISS_CHAR
 ,p_condition_description    IN    pa_action_set_line_cond.description%TYPE     := FND_API.G_MISS_CHAR
 ,p_condition_code           IN    pa_action_set_line_cond.condition_code%TYPE
 ,p_condition_attribute1     IN    pa_action_set_line_cond.condition_attribute1%TYPE   := FND_API.G_MISS_CHAR
 ,p_condition_attribute2     IN    pa_action_set_line_cond.condition_attribute2%TYPE   := FND_API.G_MISS_CHAR
 ,p_condition_attribute3     IN    pa_action_set_line_cond.condition_attribute3%TYPE   := FND_API.G_MISS_CHAR
 ,p_condition_attribute4     IN    pa_action_set_line_cond.condition_attribute4%TYPE   := FND_API.G_MISS_CHAR
 ,p_condition_attribute5     IN    pa_action_set_line_cond.condition_attribute5%TYPE   := FND_API.G_MISS_CHAR
 ,p_condition_attribute6     IN    pa_action_set_line_cond.condition_attribute6%TYPE   := FND_API.G_MISS_CHAR
 ,p_condition_attribute7     IN    pa_action_set_line_cond.condition_attribute7%TYPE   := FND_API.G_MISS_CHAR
 ,p_condition_attribute8     IN    pa_action_set_line_cond.condition_attribute8%TYPE   := FND_API.G_MISS_CHAR
 ,p_condition_attribute9     IN    pa_action_set_line_cond.condition_attribute9%TYPE   := FND_API.G_MISS_CHAR
 ,p_condition_attribute10    IN    pa_action_set_line_cond.condition_attribute10%TYPE  := FND_API.G_MISS_CHAR
 ,p_api_version              IN    NUMBER                                       := 1.0
 ,p_init_msg_list            IN    VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                   IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only            IN    VARCHAR2                                     := FND_API.G_TRUE
 ,x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_condition_tbl    pa_action_set_utils.action_line_cond_tbl_type;
 l_action_set_template_flag    pa_action_sets.action_set_template_flag%TYPE;
 l_action_set_id   pa_action_sets.action_set_id%TYPE;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ACTION_SETS_PUB.update_line_single_cond');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_condition_tbl(1).condition_code := p_condition_code;
  l_condition_tbl(1).description := p_condition_description;
  l_condition_tbl(1).condition_attribute1 := p_condition_attribute1;
  l_condition_tbl(1).condition_attribute2 := p_condition_attribute2;
  l_condition_tbl(1).condition_attribute3 := p_condition_attribute3;
  l_condition_tbl(1).condition_attribute4 := p_condition_attribute4;
  l_condition_tbl(1).condition_attribute5 := p_condition_attribute5;
  l_condition_tbl(1).condition_attribute6 := p_condition_attribute6;
  l_condition_tbl(1).condition_attribute7 := p_condition_attribute7;
  l_condition_tbl(1).condition_attribute8 := p_condition_attribute8;
  l_condition_tbl(1).condition_attribute9 := p_condition_attribute9;
  l_condition_tbl(1).condition_attribute10 := p_condition_attribute10;

  SELECT action_set_line_condition_id INTO l_condition_tbl(1).action_set_line_condition_id
    FROM pa_action_set_line_cond
   WHERE action_set_line_id = p_action_set_line_id;

  update_action_set_line
          (p_action_set_line_id       =>   p_action_set_line_id
          ,p_record_version_number    =>   p_record_version_number
          ,p_description              =>   p_action_description
          ,p_action_code              =>   p_action_code
          ,p_action_attribute1        =>   p_action_attribute1
          ,p_action_attribute2        =>   p_action_attribute2
          ,p_action_attribute3        =>   p_action_attribute3
          ,p_action_attribute4        =>   p_action_attribute4
          ,p_action_attribute5        =>   p_action_attribute5
          ,p_action_attribute6        =>   p_action_attribute6
          ,p_action_attribute7        =>   p_action_attribute7
          ,p_action_attribute8        =>   p_action_attribute8
          ,p_action_attribute9        =>   p_action_attribute9
          ,p_action_attribute10       =>   p_action_attribute10
          ,p_condition_tbl            =>   l_condition_tbl
          ,p_init_msg_list            =>   p_init_msg_list
          ,p_commit                   =>   p_commit
          ,p_validate_only            =>   p_validate_only
          ,x_return_status            =>   x_return_status
          ,x_msg_count                =>   x_msg_count
          ,x_msg_data                 =>   x_msg_data);

  -- 2452316: Need to set MOD_SOURCE_ACTION_SET_FLAG = 'Y' when updating a line
  -- from self-service page. Should not put this logic in
  -- PA_ACTION_SET_PVT.update_action_set_line because that could be called when
  -- a line is performed.
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    SELECT s.action_set_template_flag, s.action_set_id
      INTO l_action_set_template_flag, l_action_set_id
      FROM pa_action_sets s, pa_action_set_lines l
      WHERE l.action_set_line_id = p_action_set_line_id
      AND s.action_set_id = l.action_set_id;

    IF l_action_set_template_flag = 'N' THEN
      UPDATE pa_action_sets
        SET MOD_SOURCE_ACTION_SET_FLAG = 'Y'
        WHERE action_set_id = l_action_set_id;
    END IF;
  END IF;

 EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.update_line_single_cond'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END;


PROCEDURE process_action_set(p_action_set_id                IN   NUMBER,
                              x_return_status               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_msg_count                   OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_msg_data                    OUT   NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS

 l_return_status   VARCHAR2(1);
 l_msg_index_out   NUMBER;
 l_action_set_template_flag VARCHAR2(1);
 l_action_set_type_code     VARCHAR2(30);

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    FND_MSG_PUB.initialize;

     SELECT action_set_template_flag, action_set_type_code INTO l_action_set_template_flag, l_action_set_type_code
       FROM pa_action_sets
      WHERE action_set_id = p_action_set_id;

     PA_ACTION_SETS_DYN.Process_Action_Set(p_action_set_type_code       => l_action_set_type_code,
                                            p_action_set_id              => p_action_set_id,
                                            p_action_set_template_flag   => l_action_set_template_flag,
                                            x_return_status              => l_return_status);

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;
  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PUB.Validate_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END;


END pa_action_sets_pub;

/
