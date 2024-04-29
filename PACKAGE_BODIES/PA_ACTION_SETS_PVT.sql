--------------------------------------------------------
--  DDL for Package Body PA_ACTION_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACTION_SETS_PVT" AS
/*$Header: PARASPVB.pls 120.2.12010000.2 2008/08/22 16:11:53 mumohan ship $*/
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
 ,x_action_set_id         OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status           VARCHAR2(1);
 l_unique                  VARCHAR2(1);
 l_existing_action_set_id  NUMBER;
 l_status_code             pa_action_sets.status_code%TYPE;
 l_actual_start_date       DATE;
 l_is_action_set_started   VARCHAR2(1);
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Create_Action_Set.begin'
                     ,x_msg         => 'Beginning of Create_Action_Set pvt'
                     ,x_log_level   => 5);
  END IF;

  IF p_action_set_template_flag = 'Y' THEN

     l_unique := PA_ACTION_SET_UTILS.is_name_unique_in_type(
                                                p_action_set_type_code => p_action_set_type_code,
                                                p_action_set_name => p_action_set_name);

     IF l_unique = 'N' THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_ACTION_SET_NAME_NOT_UNIQUE');
     END IF;

     IF p_end_date_active IS NOT NULL THEN
        IF p_start_date_active > p_end_date_active THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name => 'PA_INVALID_START_DATE');
        END IF;
     END IF;

  ELSE

     l_existing_action_set_id := PA_ACTION_SET_UTILS.get_action_set_id(
                                           p_action_set_type_code => p_action_set_type_code,
                                           p_object_type          => p_object_type,
                                           p_object_id            => p_object_id);

     IF l_existing_action_set_id IS NOT NULL THEN
                   PA_UTILS.Add_Message (p_app_short_name => 'PA'
                                        ,p_msg_name => 'PA_OBJECT_HAS_ACTION_SET');

       --Log Message: 4403338
       IF l_debug_mode = 'Y' THEN
         PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.create_action_set'
                     ,x_msg         => 'Message: PA_OBJECT_HAS_ACTION_SET'
                     ,x_log_level   => 5);
       END IF;

     END IF;

     l_is_action_set_started := PA_ACTION_SETS_DYN.Is_Action_Set_Started_On_Apply(
                                           p_action_set_type_code => p_action_set_type_code,
                                           p_object_type          => p_object_type,
                                           p_object_id            => p_object_id);
     --Log Message: 4403338
     IF l_debug_mode = 'Y' THEN
       PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Create_Action_Set'
                     ,x_msg         => 'l_is_action_set_started = '|| l_is_action_set_started
                     ,x_log_level   => 5);
     END IF;

     IF l_is_action_set_started = 'Y' THEN
        l_status_code := 'STARTED';
     ELSE
        l_status_code := 'NOT_STARTED';
     END IF;

     IF l_status_code = 'STARTED' THEN
        l_actual_start_date := SYSDATE;
     END IF;

  END IF;

  IF FND_MSG_PUB.Count_Msg =0 THEN

     --Log Message: 4403338
     IF l_debug_mode = 'Y' THEN
       PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Create_Action_Set'
                     ,x_msg         => 'before pa_action_sets_pkg.insert_row'
                     ,x_log_level   => 5);
     END IF;

     PA_ACTION_SETS_PKG.insert_row
          (p_action_set_type_code   =>   p_action_set_type_code
          ,p_action_set_name        =>   p_action_set_name
          ,p_object_type            =>   p_object_type
          ,p_object_id              =>   p_object_id
          ,p_start_date_active      =>   p_start_date_active
          ,p_end_date_active        =>   p_end_date_active
          ,p_description            =>   p_description
          ,p_source_action_set_id   =>   p_source_action_set_id
          ,p_status_code            =>   l_status_code
          ,p_actual_start_date      =>   l_actual_start_date
          ,p_action_set_template_flag => p_action_set_template_flag
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

  END IF;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Create_Action_Set'
                     ,x_msg         => 'x_action_set_id = '|| x_action_set_id
                     ,x_log_level   => 5);
  END IF;

  IF FND_MSG_PUB.Count_Msg > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Create_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Create_Action_Set;


PROCEDURE update_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_name        IN    pa_action_sets.action_set_name%TYPE         := FND_API.G_MISS_CHAR
 ,p_action_set_type_code   IN    pa_action_sets.action_set_type_code%TYPE    := FND_API.G_MISS_CHAR
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
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status             VARCHAR2(1);
 l_action_set_id             NUMBER;
 l_record_version_number     NUMBER;
 l_existing_action_set_id    NUMBER;
 l_previous_status           pa_action_sets.status_code%TYPE;
 l_status_code               pa_action_sets.status_code%TYPE;
 l_unique                    VARCHAR2(1);
 l_actual_start_date         DATE := FND_API.G_MISS_DATE;
 l_action_set_type_code      pa_action_set_types.action_set_type_code%TYPE;
 l_action_set_template_flag  VARCHAR2(1);
 l_msg_count                 NUMBER;
 l_msg_data                  VARCHAR2(2000);
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message: 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Update_Action_Set.begin'
                     ,x_msg         => 'Beginning of Update_Action_Set pvt'
                     ,x_log_level   => 5);
  END IF;

    SELECT action_set_type_code,
           action_set_template_flag
      INTO l_action_set_type_code,
           l_action_set_template_flag
      FROM pa_action_sets
     WHERE action_set_id = p_action_set_id;

  IF l_action_set_template_flag = 'Y' THEN

   IF  p_action_set_name IS NOT NULL THEN

     l_unique := PA_ACTION_SET_UTILS.is_name_unique_in_type(
                                                p_action_set_type_code => l_action_set_type_code,
                                                p_action_set_name => p_action_set_name,
                                                p_action_set_id => p_action_set_id);

     IF l_unique = 'N' THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_ACTION_SET_NAME_NOT_UNIQUE');
     END IF;

   END IF;

   IF p_end_date_active IS NOT NULL THEN
        IF p_start_date_active > p_end_date_active THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name => 'PA_INVALID_START_DATE');
        END IF;
   END IF;

  ELSE

     IF p_status_code IS NOT NULL THEN
        --validate that status is a valid next status
        null;

        SELECT status_code INTO l_previous_status
          FROM pa_action_sets
         WHERE action_set_id = p_action_set_id;

        IF p_status_code = 'STARTED' AND l_previous_status <> 'STARTED' THEN
           l_actual_start_date := SYSDATE;
        END IF;

     END IF;

  END IF;

  IF FND_MSG_PUB.Count_Msg =0 THEN

     PA_ACTION_SETS_PKG.update_row
          (p_action_set_id          =>   p_action_set_id
          ,p_action_set_name        =>   p_action_set_name
          ,p_start_date_active      =>   p_start_date_active
          ,p_end_date_active        =>   p_end_date_active
          ,p_description            =>   p_description
          ,p_status_code            =>   p_status_code
          ,p_actual_start_date      =>   l_actual_start_date
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

     --only need to call process action set if status is changed to stated - may
     --be needed in order to update line numbers based on the actual start date.
     -- 2334717: When RESUMED, should be performed as well.
     IF p_status_code = 'STARTED' OR p_status_code = 'RESUMED'THEN

        PA_ACTION_SETS_DYN.Process_Action_Set(p_action_set_type_code       => l_action_set_type_code,
                                               p_action_set_id              => p_action_set_id,
                                               p_action_set_template_flag   => l_action_set_template_flag,
                                               x_return_status              => l_return_status);

        IF l_action_set_template_flag = 'N' AND FND_MSG_PUB.Count_Msg = 0 THEN

           PA_ACTION_SETS_PUB.perform_single_action_set
                               (p_action_set_id        =>   p_action_set_id,
                                p_init_msg_list        =>   FND_API.G_FALSE,
                                x_return_status        =>   l_return_status,
                                x_msg_count            =>   l_msg_count,
                                x_msg_data             =>   l_msg_data);

        END IF;

     END IF;

  END IF;

  IF FND_MSG_PUB.Count_Msg > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Update_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Update_Action_Set;


PROCEDURE delete_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE
 ,p_record_version_number  IN    pa_action_sets.record_version_number%TYPE   := NULL
 ,x_return_status         OUT    NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS

 l_return_status          VARCHAR2(1);
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(2000);
 l_action_set_id          NUMBER;
 l_record_version_number  NUMBER;
 l_is_source              VARCHAR2(1);
 l_do_lines_exist         VARCHAR2(1);
 l_action_set_lines_tbl   pa_action_set_utils.action_set_lines_tbl_type;
 l_action_set_template_flag VARCHAR2(1);
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN


  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message: 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Delete_Action_Set'
                     ,x_msg         => 'Beginning of Delete_Action_Set pvt'
                     ,x_log_level   => 5);
  END IF;

   SELECT action_set_template_flag INTO l_action_set_template_flag
     FROM pa_action_sets
    WHERE action_set_id = p_action_set_id;

  IF l_action_set_template_flag = 'Y' THEN

     l_is_source := PA_ACTION_SET_UTILS.is_action_set_a_source(p_action_set_id => p_action_set_id);

     IF l_is_source = 'Y' THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_ACTION_SET_IS_SOURCE');
     END IF;

  END IF;

  IF FND_MSG_PUB.Count_Msg = 0 THEN

     l_action_set_lines_tbl := pa_action_set_utils.get_action_set_lines(p_action_set_id => p_action_set_id);

     IF l_action_set_lines_tbl.COUNT > 0 THEN

     FOR i IN l_action_set_lines_tbl.FIRST .. l_action_set_lines_tbl.LAST LOOP

        delete_action_set_line(p_action_set_line_id    => l_action_set_lines_tbl(i).action_set_line_id,
                               p_record_version_number => l_action_set_lines_tbl(i).record_version_number,
                               x_return_status         => l_return_status);

     END LOOP;

    END IF;

  END IF;

  IF FND_MSG_PUB.Count_Msg = 0 THEN

     l_do_lines_exist := PA_ACTION_SET_UTILS.do_lines_exist(p_action_set_id => p_action_set_id);

     IF l_do_lines_exist = 'N' THEN

        PA_ACTION_SETS_PKG.delete_row
               (p_action_set_id         => p_action_set_id,
                p_record_version_number => p_record_version_number,
                x_return_status         => l_return_status);

     ELSE

        IF l_action_set_template_flag = 'N' THEN

           PA_ACTION_SETS_PUB.perform_single_action_set(p_action_set_id            =>   p_action_set_id
                                                       ,p_init_msg_list            =>   FND_API.G_FALSE
                                                       ,x_return_status            =>   l_return_status
                                                       ,x_msg_count                =>   l_msg_count
                                                       ,x_msg_data                 =>   l_msg_data);
        END IF;


        PA_ACTION_SETS_PKG.update_row(p_action_set_id         => p_action_set_id,
                                      p_record_version_number => p_record_version_number,
                                      p_status_code           => 'DELETED',
                                      x_return_status         => l_return_status);


     END IF;

  END IF;

  IF FND_MSG_PUB.Count_Msg > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Delete_Action_Set'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Delete_Action_Set;




PROCEDURE create_action_set_line
 (p_action_set_id            IN    pa_action_sets.action_set_id%TYPE
 ,p_use_def_description_flag IN    VARCHAR2                                     := 'Y'
 ,p_description              IN    pa_action_set_lines.description%TYPE         := NULL
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
 ,x_action_set_line_id      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status            VARCHAR2(1);
 l_msg_index_out            NUMBER;
 l_action_set_line_rec      pa_action_set_lines%ROWTYPE;
 l_action_set_type_code     pa_action_set_types.action_set_type_code%TYPE;
 l_action_set_template_flag pa_action_sets.action_set_template_flag%TYPE;
 l_action_set_line_id       NUMBER;
 l_action_line_condition_id NUMBER;
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message: 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Create_Action_Set_Line.begin'
                     ,x_msg         => 'Beginning of Create_Action_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  l_action_set_line_rec.action_set_id := p_action_set_id;
  l_action_set_line_rec.action_set_line_number := p_action_set_line_number;
  l_action_set_line_rec.action_code := p_action_code;
  l_action_set_line_rec.action_attribute1 := p_action_attribute1;
  l_action_set_line_rec.action_attribute2 := p_action_attribute2;
  l_action_set_line_rec.action_attribute3 := p_action_attribute3;
  l_action_set_line_rec.action_attribute4 := p_action_attribute4;
  l_action_set_line_rec.action_attribute5 := p_action_attribute5;
  l_action_set_line_rec.action_attribute6 := p_action_attribute6;
  l_action_set_line_rec.action_attribute7 := p_action_attribute7;
  l_action_set_line_rec.action_attribute8 := p_action_attribute8;
  l_action_set_line_rec.action_attribute9 := p_action_attribute9;
  l_action_set_line_rec.action_attribute10 := p_action_attribute10;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Create_Action_Set_Line.begin'
                     ,x_msg         => 'p_action_set_id = '|| p_action_set_id
                     ,x_log_level   => 5);
  END IF;

  SELECT action_set_type_code, action_set_template_flag
    INTO l_action_set_type_code, l_action_set_template_flag
    FROM pa_action_sets
   WHERE action_set_id = p_action_set_id;

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Create_Action_Set_Line.begin'
                     ,x_msg         => 'Before validate_action_set_line: '||'action_set_type_code = '||l_action_set_type_code
                     ,x_log_level   => 5);
  END IF;

  PA_ACTION_SETS_DYN.Validate_Action_Set_Line(p_action_set_type_code       => l_action_set_type_code,
                                              p_action_set_line_rec        => l_action_set_line_rec,
                                              p_action_line_conditions_tbl => p_condition_tbl,
                                              x_return_status              => l_return_status);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Create_Action_Set_Line.begin'
                     ,x_msg         => 'After validate_action_set_line: x_retun_status = '||l_return_status
                     ,x_log_level   => 5);
  END IF;

  IF FND_MSG_PUB.Count_Msg = 0 THEN

     PA_ACTION_SET_LINES_PKG.Insert_Row
          (p_action_set_id          =>   p_action_set_id
          ,p_action_set_line_number =>   p_action_set_line_number
          ,p_description            =>   p_description
          ,p_status_code            =>   'PENDING'
          ,p_action_code            =>   p_action_code
          ,p_action_attribute1      =>   p_action_attribute1
          ,p_action_attribute2      =>   p_action_attribute2
          ,p_action_attribute3      =>   p_action_attribute3
          ,p_action_attribute4      =>   p_action_attribute4
          ,p_action_attribute5      =>   p_action_attribute5
          ,p_action_attribute6      =>   p_action_attribute6
          ,p_action_attribute7      =>   p_action_attribute7
          ,p_action_attribute8      =>   p_action_attribute8
          ,p_action_attribute9      =>   p_action_attribute9
          ,p_action_attribute10     =>   p_action_attribute10
          ,x_action_set_line_id     =>   l_action_set_line_id
          ,x_return_status          =>   l_return_status);

     FOR i IN p_condition_tbl.FIRST .. p_condition_tbl.LAST LOOP


        PA_ACTION_SET_LINE_COND_PKG.Insert_Row
          (p_action_set_line_id        =>   l_action_set_line_id
          ,p_condition_date            =>   p_condition_tbl(i).condition_date
          ,p_condition_code            =>   p_condition_tbl(i).condition_code
          ,p_description               =>   p_condition_tbl(i).description
          ,p_condition_attribute1      =>   p_condition_tbl(i).condition_attribute1
          ,p_condition_attribute2      =>   p_condition_tbl(i).condition_attribute2
          ,p_condition_attribute3      =>   p_condition_tbl(i).condition_attribute3
          ,p_condition_attribute4      =>   p_condition_tbl(i).condition_attribute4
          ,p_condition_attribute5      =>   p_condition_tbl(i).condition_attribute5
          ,p_condition_attribute6      =>   p_condition_tbl(i).condition_attribute6
          ,p_condition_attribute7      =>   p_condition_tbl(i).condition_attribute7
          ,p_condition_attribute8      =>   p_condition_tbl(i).condition_attribute8
          ,p_condition_attribute9      =>   p_condition_tbl(i).condition_attribute9
          ,p_condition_attribute10     =>   p_condition_tbl(i).condition_attribute10
          ,x_action_set_line_condition_id   =>   l_action_line_condition_id
          ,x_return_status             =>   l_return_status);

     END LOOP;

  END IF;

  -- If any errors exist then set the x_return_status to 'E'
  IF FND_MSG_PUB.Count_Msg > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Create_Action_Set_Line'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

 END Create_Action_Set_Line;


PROCEDURE update_action_set_line
 (p_action_set_line_id       IN    pa_action_set_lines.action_set_line_id%TYPE
 ,p_record_version_number    IN    pa_action_set_lines.record_version_number%TYPE
 ,p_action_set_line_number   IN    pa_action_set_lines.action_set_line_number%TYPE := FND_API.G_MISS_NUM
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
 ,p_condition_tbl            IN    pa_action_set_utils.action_line_cond_tbl_type := pa_action_set_utils.l_empty_condition_tbl
 ,x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status           VARCHAR2(1);
 l_record_version_number   NUMBER;
 l_current_line_status     pa_action_set_lines.status_code%TYPE;
 l_action_set_type_code    pa_action_set_types.action_set_type_code%TYPE;
 l_action_set_id           pa_action_sets.action_set_id%TYPE;
 l_action_set_line_rec     pa_action_set_lines%ROWTYPE;
 l_action_set_template_flag VARCHAR2(1);
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message: 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Update_Action_Set_Line.begin'
                     ,x_msg         => 'Beginning of Update_Action_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  SELECT sets.action_set_type_code,
         sets.action_set_id,
         sets.action_set_template_flag,
         lines.status_code
    INTO l_action_set_type_code,
         l_action_set_id,
         l_action_set_template_flag,
         l_current_line_status
    FROM pa_action_sets sets,
         pa_action_set_lines lines
   WHERE lines.action_set_line_id = p_action_set_line_id
     AND sets.action_set_id = lines.action_set_id;

  IF l_current_line_status = 'ACTIVE' OR l_current_line_status='COMPLETE' THEN
     PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_LINE_ALREADY_PERFORMED');
  ELSE

  l_action_set_line_rec.action_set_id := l_action_set_id;
  l_action_set_line_rec.action_set_line_number := p_action_set_line_number;
  l_action_set_line_rec.action_code := p_action_code;
  l_action_set_line_rec.action_attribute1 := p_action_attribute1;
  l_action_set_line_rec.action_attribute2 := p_action_attribute2;
  l_action_set_line_rec.action_attribute3 := p_action_attribute3;
  l_action_set_line_rec.action_attribute4 := p_action_attribute4;
  l_action_set_line_rec.action_attribute5 := p_action_attribute5;
  l_action_set_line_rec.action_attribute6 := p_action_attribute6;
  l_action_set_line_rec.action_attribute7 := p_action_attribute7;
  l_action_set_line_rec.action_attribute8 := p_action_attribute8;
  l_action_set_line_rec.action_attribute9 := p_action_attribute9;
  l_action_set_line_rec.action_attribute10 := p_action_attribute10;


     PA_ACTION_SETS_DYN.Validate_Action_Set_Line(p_action_set_type_code       => l_action_set_type_code,
                                                 p_action_set_line_rec        => l_action_set_line_rec,
                                                 p_action_line_conditions_tbl => p_condition_tbl,
                                                 x_return_status              => l_return_status);



     IF FND_MSG_PUB.Count_Msg = 0 THEN

        PA_ACTION_SET_LINES_PKG.Update_Row
             (p_action_set_line_id     =>   p_action_set_line_id
             ,p_action_set_line_number =>   p_action_set_line_number
             ,p_description            =>   p_description
             ,p_action_code            =>   p_action_code
             ,p_action_attribute1      =>   p_action_attribute1
             ,p_action_attribute2      =>   p_action_attribute2
             ,p_action_attribute3      =>   p_action_attribute3
             ,p_action_attribute4      =>   p_action_attribute4
             ,p_action_attribute5      =>   p_action_attribute5
             ,p_action_attribute6      =>   p_action_attribute6
             ,p_action_attribute7      =>   p_action_attribute7
             ,p_action_attribute8      =>   p_action_attribute8
             ,p_action_attribute9      =>   p_action_attribute9
             ,p_action_attribute10     =>   p_action_attribute10
             ,x_return_status          =>   l_return_status);


        FOR i IN p_condition_tbl.FIRST .. p_condition_tbl.LAST LOOP

           PA_ACTION_SET_LINE_COND_PKG.Update_Row
             (p_action_set_line_condition_id   =>   p_condition_tbl(i).action_set_line_condition_id
             ,p_condition_date            =>   p_condition_tbl(i).condition_date
             ,p_condition_code            =>   p_condition_tbl(i).condition_code
             ,p_description               =>   p_condition_tbl(i).description
             ,p_condition_attribute1      =>   p_condition_tbl(i).condition_attribute1
             ,p_condition_attribute2      =>   p_condition_tbl(i).condition_attribute2
             ,p_condition_attribute3      =>   p_condition_tbl(i).condition_attribute3
             ,p_condition_attribute4      =>   p_condition_tbl(i).condition_attribute4
             ,p_condition_attribute5      =>   p_condition_tbl(i).condition_attribute5
             ,p_condition_attribute6      =>   p_condition_tbl(i).condition_attribute6
             ,p_condition_attribute7      =>   p_condition_tbl(i).condition_attribute7
             ,p_condition_attribute8      =>   p_condition_tbl(i).condition_attribute8
             ,p_condition_attribute9      =>   p_condition_tbl(i).condition_attribute9
             ,p_condition_attribute10     =>   p_condition_tbl(i).condition_attribute10
             ,x_return_status             =>   l_return_status);

        END LOOP;

     END IF;

  END IF;

  -- If any errors exist then set the x_return_status to 'E'
  IF FND_MSG_PUB.Count_Msg > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Update_Action_Set_Line'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Update_Action_Set_Line;


PROCEDURE delete_action_set_line
 (p_action_set_line_id     IN    pa_action_sets.action_set_id%TYPE
 ,p_record_version_number  IN    pa_action_set_lines.record_version_number%TYPE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status               VARCHAR2(1);
 l_action_set_type_code        pa_action_set_types.action_set_type_code%TYPE;
 l_action_set_id               pa_action_sets.action_set_id%TYPE;
 l_action_set_template_flag    pa_action_sets.action_set_template_flag%TYPE;
 l_current_line_status         pa_action_set_lines.status_code%TYPE;
 l_do_audit_lines_exist        VARCHAR2(1);
 l_action_line_conditions_tbl  pa_action_set_utils.action_line_cond_tbl_type;
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message: 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Delete_Action_Set_Line.begin'
                     ,x_msg         => 'Beginning of Delete_Action_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  SELECT sets.action_set_type_code,
         sets.action_set_id,
         sets.action_set_template_flag,
         lines.status_code
    INTO l_action_set_type_code,
         l_action_set_id,
         l_action_set_template_flag,
         l_current_line_status
    FROM pa_action_sets sets,
         pa_action_set_lines lines
   WHERE lines.action_set_line_id = p_action_set_line_id
     AND sets.action_set_id = lines.action_set_id;

  IF l_current_line_status = 'REVERSE_PENDING' OR l_current_line_status = 'UPDATE_PENDING' THEN

          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name => 'PA_ACTION_LINE_CHANGE_PENDING');

  ELSIF l_current_line_status = 'REVERSED' THEN

     -- 2411522 : Need to set MOD_SOURCE_ACTION_SET_FLAG = 'Y' when deleting a line.
     IF l_action_set_template_flag = 'N' THEN
           UPDATE pa_action_sets
              SET MOD_SOURCE_ACTION_SET_FLAG = 'Y'
            WHERE action_set_id = l_action_set_id;
     END IF;

     PA_ACTION_SET_LINES_PKG.update_row(p_action_set_line_id      => p_action_set_line_id,
                                        p_line_deleted_flag       => 'Y',
                                        x_return_status           => l_return_status);

  ELSE

     l_do_audit_lines_exist := PA_ACTION_SET_UTILS.do_audit_lines_exist(p_action_set_line_id => p_action_set_line_id);
     -- Bug Ref : 6797508
     IF ( l_action_set_type_code = 'ADVERTISEMENT' ) THEN
        IF ( l_do_audit_lines_exist = 'Y'  )THEN
    	   DELETE
	     FROM PA_ACTION_SET_LINE_AUD
	    WHERE ACTION_SET_LINE_ID = P_ACTION_SET_LINE_ID;
        END IF;
        -- 2411522 : Need to set MOD_SOURCE_ACTION_SET_FLAG = 'Y' when deleting a line.
        l_do_audit_lines_exist :=
        PA_ACTION_SET_UTILS.do_audit_lines_exist(p_action_set_line_id => p_action_set_line_id);
        IF ( l_do_audit_lines_exist = 'N' AND l_current_line_status <> 'ACTIVE' ) THEN
          IF l_action_set_template_flag = 'N' THEN
           UPDATE pa_action_sets
              SET MOD_SOURCE_ACTION_SET_FLAG = 'Y'
            WHERE action_set_id = l_action_set_id;
          END IF;
          l_action_line_conditions_tbl :=
	    PA_ACTION_SET_UTILS.get_action_line_conditions(p_action_set_line_id => p_action_set_line_id);
          FOR i IN l_action_line_conditions_tbl.FIRST .. l_action_line_conditions_tbl.LAST LOOP
            PA_ACTION_SET_LINE_COND_PKG.delete_row
                  (p_action_set_line_condition_id    => l_action_line_conditions_tbl(i).action_set_line_condition_id,
                   p_record_version_number           => p_record_version_number,
                   x_return_status                   => l_return_status);
          END LOOP;
          PA_ACTION_SET_LINES_PKG.delete_row
                  (p_action_set_line_id    => p_action_set_line_id,
                   p_record_version_number => p_record_version_number,
                   x_return_status         => l_return_status);
         ELSE
         PA_ACTION_SET_LINES_PKG.update_row(p_action_set_line_id      => p_action_set_line_id,
                                            p_record_version_number   => p_record_version_number,
                                            p_status_code             => 'REVERSE_PENDING',
                                            p_line_deleted_flag       => 'Y',
                                            x_return_status           => l_return_status);
        END IF;
     ELSE -- l_action_set_type_code = 'ADVERTISEMENT' ) THEN
       IF ( l_do_audit_lines_exist = 'N' AND l_current_line_status <> 'ACTIVE' AND l_current_line_status <> 'COMPLETE' ) THEN
          -- 2411522 : Need to set MOD_SOURCE_ACTION_SET_FLAG = 'Y' when deleting a line.
          IF l_action_set_template_flag = 'N' THEN
             UPDATE pa_action_sets
                SET MOD_SOURCE_ACTION_SET_FLAG = 'Y'
              WHERE action_set_id = l_action_set_id;
          END IF;
          l_action_line_conditions_tbl :=
	    PA_ACTION_SET_UTILS.get_action_line_conditions(p_action_set_line_id => p_action_set_line_id);
          FOR i IN l_action_line_conditions_tbl.FIRST .. l_action_line_conditions_tbl.LAST LOOP

           PA_ACTION_SET_LINE_COND_PKG.delete_row
                  (p_action_set_line_condition_id    => l_action_line_conditions_tbl(i).action_set_line_condition_id,
                   p_record_version_number           => p_record_version_number,
                   x_return_status                   => l_return_status);

        END LOOP;

        PA_ACTION_SET_LINES_PKG.delete_row
                  (p_action_set_line_id    => p_action_set_line_id,
                   p_record_version_number => p_record_version_number,
                   x_return_status         => l_return_status);

      ELSE

         PA_ACTION_SET_LINES_PKG.update_row(p_action_set_line_id      => p_action_set_line_id,
                                            p_record_version_number   => p_record_version_number,
                                            p_status_code             => 'REVERSE_PENDING',
                                            p_line_deleted_flag       => 'Y',
                                            x_return_status           => l_return_status);

        END IF;
      END IF;

  END IF;

  IF FND_MSG_PUB.Count_Msg > 0  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

    -- Set the excetption Message and the stack
    FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Delete_Action_Set_Line'
                             ,p_procedure_name => PA_DEBUG.G_Err_Stack );
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;

 END Delete_Action_Set_Line;


FUNCTION get_def_reverse_audit_lines(p_action_set_line_id            IN  pa_action_set_lines.action_set_line_id%TYPE,
                                     p_reason                        IN  VARCHAR2) RETURN pa_action_set_utils.insert_audit_lines_tbl_type
IS

   l_action_set_details_rec           pa_action_sets%ROWTYPE;

   l_active_audit_lines_tbl           pa_action_set_utils.audit_lines_tbl_type;
   l_insert_audit_lines_tbl           pa_action_set_utils.insert_audit_lines_tbl_type;
   l_reason_code_tbl                  pa_action_set_utils.varchar_tbl_type;
   l_action_code_tbl                  pa_action_set_utils.varchar_tbl_type;
   l_audit_display_attribute_tbl      pa_action_set_utils.varchar_tbl_type;
   l_audit_attribute_tbl              pa_action_set_utils.varchar_tbl_type;
   l_action_date_tbl                  pa_action_set_utils.date_tbl_type;
   l_active_flag_tbl                  pa_action_set_utils.varchar_tbl_type;
   l_rev_action_set_line_id_tbl       pa_action_set_utils.number_tbl_type;

   l_return_status                    VARCHAR2(1);

BEGIN

 l_action_set_details_rec := PA_ACTION_SET_UTILS.get_action_set_details(p_action_set_line_id => p_action_set_line_id);

 l_active_audit_lines_tbl := PA_ACTION_SET_UTILS.get_active_audit_lines(p_action_set_line_id => p_action_set_line_id);

 IF l_active_audit_lines_tbl.COUNT > 0 THEN

    FOR i IN l_active_audit_lines_tbl.FIRST .. l_active_audit_lines_tbl.LAST LOOP

        l_insert_audit_lines_tbl(i).action_code             := l_active_audit_lines_tbl(i).action_code;
        l_insert_audit_lines_tbl(i).audit_display_attribute := l_active_audit_lines_tbl(i).audit_display_attribute;
        l_insert_audit_lines_tbl(i).audit_attribute         := l_active_audit_lines_tbl(i).audit_attribute;
        IF p_reason='REVERSED' THEN
           l_insert_audit_lines_tbl(i).reason_code          := 'DELETED';
        ELSIF p_reason='UPDATED' THEN
           l_insert_audit_lines_tbl(i).reason_code          := 'UPDATED';
        END IF;
        l_insert_audit_lines_tbl(i).reversed_action_set_line_id  := p_action_set_line_id;

    END LOOP;

  END IF;

  RETURN l_insert_audit_lines_tbl;

  EXCEPTION
    WHEN OTHERS THEN

    -- Set the excetption Message and the stack
    FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.reverse_action_audit_lines'
                             ,p_procedure_name => PA_DEBUG.G_Err_Stack );
    --
    RAISE;


END;


PROCEDURE bulk_insert_audit_lines(p_audit_lines_tbl      IN  pa_action_set_utils.insert_audit_lines_tbl_type,
                                  p_action_set_line_id   IN  pa_action_set_lines.action_set_line_id%TYPE,
                                  p_object_type          IN  pa_action_sets.object_type%TYPE,
                                  p_object_id            IN  pa_action_sets.object_id%TYPE,
                                  p_action_set_type_code IN  pa_action_sets.action_set_type_code%TYPE,
                                  p_status_code          IN  VARCHAR2,
                                  x_return_status       OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

   l_audit_lines_tbl                  pa_action_set_utils.insert_audit_lines_tbl_type;
   l_reason_code_tbl                  pa_action_set_utils.varchar_tbl_type;
   l_action_code_tbl                  pa_action_set_utils.varchar_tbl_type;
   l_audit_display_attribute_tbl      pa_action_set_utils.varchar_tbl_type;
   l_audit_attribute_tbl              pa_action_set_utils.varchar_tbl_type;
   l_rev_action_set_line_id_tbl       pa_action_set_utils.number_tbl_type;
   l_encoded_error_message_tbl        pa_action_set_utils.varchar_tbl_type;

BEGIN

 IF p_status_code = 'REVERSED' THEN

       UPDATE pa_action_set_line_aud
          SET active_flag = 'N'
        WHERE action_set_line_id = p_action_set_line_id;

 END IF;

 IF p_audit_lines_tbl.COUNT > 0 THEN

    FOR i IN p_audit_lines_tbl.FIRST .. p_audit_lines_tbl.LAST LOOP

        l_action_code_tbl(i) := p_audit_lines_tbl(i).action_code;
        l_reason_code_tbl(i) := p_audit_lines_tbl(i).reason_code;
        l_audit_display_attribute_tbl(i) := p_audit_lines_tbl(i).audit_display_attribute;
        l_audit_attribute_tbl(i) := p_audit_lines_tbl(i).audit_attribute;
        l_rev_action_set_line_id_tbl(i) := p_audit_lines_tbl(i).reversed_action_set_line_id;
        l_encoded_error_message_tbl(i) := p_audit_lines_tbl(i).encoded_error_message;

    END LOOP;

    FORALL i IN p_audit_lines_tbl.FIRST .. p_audit_lines_tbl.LAST
       INSERT INTO pa_action_set_line_aud
                   (action_set_line_id,
                    object_type,
                    object_id,
                    action_set_type_code,
                    status_code,
                    reason_code,
                    action_code,
                    audit_display_attribute,
                    audit_attribute,
                    encoded_error_message,
                    action_date,
                    active_flag,
                    reversed_action_set_line_id,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date
                    )
          VALUES   (p_action_set_line_id,
                   p_object_type,
                   p_object_id,
                   p_action_set_type_code,
                   p_status_code,
                   l_reason_code_tbl(i),
                   l_action_code_tbl(i),
                   l_audit_display_attribute_tbl(i),
                   l_audit_attribute_tbl(i),
                   l_encoded_error_message_tbl(i),
                   SYSDATE,
                   decode(p_status_code,'REVERSED',decode(l_rev_action_set_line_id_tbl(i),NULL,'Y','N'),'Y'),
                   l_rev_action_set_line_id_tbl(i),
                   SYSDATE,
                   FND_GLOBAL.user_id,
                   SYSDATE,
                   FND_GLOBAL.user_id,
                   FND_GLOBAL.user_id,
                   FND_GLOBAL.CONC_REQUEST_ID,
                   FND_GLOBAL.PROG_APPL_ID,
                   FND_GLOBAL.CONC_PROGRAM_ID,
                   SYSDATE);

  END IF;

  EXCEPTION
    WHEN OTHERS THEN

    -- Set the excetption Message and the stack
    FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.bulk_insert_audit_lines'
                             ,p_procedure_name => PA_DEBUG.G_Err_Stack );
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;


END;


PROCEDURE bulk_update_line_number(p_action_set_line_id_tbl      IN  pa_action_set_utils.number_tbl_type,
                                  p_line_number_tbl             IN  pa_action_set_utils.number_tbl_type,
                                  x_return_status              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

TYPE rowid_tbl IS TABLE OF ROWID
  INDEX BY BINARY_INTEGER;

l_rowid_tbl    rowid_tbl;

e_row_is_locked   EXCEPTION;
PRAGMA EXCEPTION_INIT(e_row_is_locked, -54);

BEGIN

 IF p_action_set_line_id_tbl.COUNT > 0 THEN

    FOR i IN p_action_set_line_id_tbl.FIRST .. p_action_set_line_id_tbl.LAST LOOP

       SELECT rowid INTO l_rowid_tbl(i)
         FROM pa_action_set_lines
        WHERE action_set_line_id = p_action_set_line_id_tbl(i)
         FOR UPDATE NOWAIT;

    END LOOP;

    FORALL i IN l_rowid_tbl.FIRST .. l_rowid_tbl.LAST
       UPDATE pa_action_set_lines
          SET action_set_line_number = p_line_number_tbl(i)
        WHERE rowid = l_rowid_tbl(i);

  END IF;

  EXCEPTION
    WHEN e_row_is_locked THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_ACTION_LINE_CHANGE_PENDING');
       x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN

    -- Set the excetption Message and the stack
    FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.bulk_update_line_number'
                             ,p_procedure_name => PA_DEBUG.G_Err_Stack );
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;

END;

PROCEDURE bulk_update_condition_date(p_action_line_condition_id_tbl      IN  pa_action_set_utils.number_tbl_type,
                                     p_condition_date_tbl                IN  pa_action_set_utils.date_tbl_type,
                                     x_return_status                    OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

TYPE rowid_tbl IS TABLE OF ROWID
  INDEX BY BINARY_INTEGER;

l_rowid_tbl    rowid_tbl;

e_row_is_locked   EXCEPTION;
PRAGMA EXCEPTION_INIT(e_row_is_locked, -54);

BEGIN

 IF p_action_line_condition_id_tbl.COUNT > 0 THEN

    FOR i IN p_action_line_condition_id_tbl.FIRST .. p_action_line_condition_id_tbl.LAST LOOP

       SELECT rowid INTO l_rowid_tbl(i)
         FROM pa_action_set_line_cond
        WHERE action_set_line_condition_id = p_action_line_condition_id_tbl(i)
         FOR UPDATE NOWAIT;

    END LOOP;

    FORALL i IN l_rowid_tbl.FIRST .. l_rowid_tbl.LAST
       UPDATE pa_action_set_line_cond
          SET condition_date = p_condition_date_tbl(i)
        WHERE rowid = l_rowid_tbl(i);

  END IF;

  EXCEPTION
    WHEN e_row_is_locked THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_ACTION_LINE_CHANGE_PENDING');
       x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
    -- Set the excetption Message and the stack
    FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.bulk_update_condition_date'
                             ,p_procedure_name => PA_DEBUG.G_Err_Stack );
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;

END;

PROCEDURE bulk_update_line_status(p_action_set_line_id_tbl      IN  pa_action_set_utils.number_tbl_type,
                                  p_line_status_tbl             IN  pa_action_set_utils.varchar_tbl_type,
                                  x_return_status              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

TYPE rowid_tbl IS TABLE OF ROWID
  INDEX BY BINARY_INTEGER;

l_rowid_tbl    rowid_tbl;

e_row_is_locked   EXCEPTION;
PRAGMA EXCEPTION_INIT(e_row_is_locked, -54);

BEGIN

 IF p_action_set_line_id_tbl.COUNT > 0 THEN

    FOR i IN p_action_set_line_id_tbl.FIRST .. p_action_set_line_id_tbl.LAST LOOP

       SELECT rowid INTO l_rowid_tbl(i)
         FROM pa_action_set_lines
        WHERE action_set_line_id = p_action_set_line_id_tbl(i)
         FOR UPDATE NOWAIT;

    END LOOP;

    FORALL i IN l_rowid_tbl.FIRST .. l_rowid_tbl.LAST
       UPDATE pa_action_set_lines
          SET status_code = p_line_status_tbl(i)
        WHERE rowid = l_rowid_tbl(i);

  END IF;

  EXCEPTION
    WHEN e_row_is_locked THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_ACTION_LINE_CHANGE_PENDING');
       x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- Set the excetption Message and the stack
    FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.bulk_update_line_status'
                             ,p_procedure_name => PA_DEBUG.G_Err_Stack );
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;

END;


PROCEDURE perform_action_set_line
 (p_action_set_type_code   IN    pa_action_set_types.action_set_type_code%TYPE
 ,p_action_set_line_id     IN    pa_action_sets.action_set_id%TYPE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_return_status               VARCHAR2(1);
 l_action_set_line_rec         pa_action_set_lines%ROWTYPE;
 l_action_line_conditions_tbl  pa_action_set_utils.action_line_cond_tbl_type;
 l_action_line_audit_tbl       pa_action_set_utils.insert_audit_lines_tbl_type;
 l_action_line_complete_flag   VARCHAR2(1);
 l_action_line_result_code     VARCHAR2(240);
 l_action_set_details_rec      pa_action_sets%ROWTYPE;
 l_audit_status_code           VARCHAR2(30);
 l_new_line_status_code        VARCHAR2(30);
 l_line_deleted_flag           VARCHAR2(1);
 l_action_set_line_number      NUMBER;
 L_MSG_DATA                    VARCHAR2(2000);
 l_msg_index_out               NUMBER;
 e_invalid_result_code         EXCEPTION;
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message: 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Perform_Action_Set_Line.begin'
                     ,x_msg         => 'Beginning of Perform_Action_Set_Line pvt'
                     ,x_log_level   => 5);
  END IF;

  l_action_set_details_rec := PA_ACTION_SET_UTILS.get_action_set_details(p_action_set_line_id => p_action_set_line_id);

  l_action_set_line_rec := PA_ACTION_SET_UTILS.get_action_set_line(p_action_set_line_id => p_action_set_line_id);

  l_action_line_conditions_tbl := PA_ACTION_SET_UTILS.get_action_line_conditions(p_action_set_line_id => p_action_set_line_id);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Perform_Action_Set_Line.begin'
                     ,x_msg         => 'Before calling PA_ACTION_SETS_DYN.perform_action_set_line'
                     ,x_log_level   => 5);
  END IF;

  PA_ACTION_SETS_DYN.perform_action_set_line
                            (p_action_set_type_code        =>   p_action_set_type_code,
                             p_action_set_details_rec      =>   l_action_set_details_rec,
                             p_action_set_line_rec         =>   l_action_set_line_rec,
                             p_action_line_conditions_tbl  =>   l_action_line_conditions_tbl,
                             x_action_line_audit_tbl       =>   l_action_line_audit_tbl,
                             x_action_line_result_code     =>   l_action_line_result_code);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_PVT.Perform_Action_Set_Line.begin'
                     ,x_msg         => 'After calling PA_ACTION_SETS_DYN.perform_action_set_line'
                     ,x_log_level   => 5);
  END IF;

     IF l_action_line_result_code = PA_ACTION_SET_UTILS.G_PERFORMED_COMPLETE THEN

            l_audit_status_code := 'PERFORMED';

            l_new_line_status_code := 'COMPLETE';

     ELSIF l_action_line_result_code = PA_ACTION_SET_UTILS.G_PERFORMED_ACTIVE THEN

            l_audit_status_code := 'PERFORMED';

            l_new_line_status_code := 'ACTIVE';

     ELSIF l_action_line_result_code = PA_ACTION_SET_UTILS.G_REVERSED_DEFAULT_AUDIT THEN

            l_action_line_audit_tbl := get_def_reverse_audit_lines(p_action_set_line_id      => p_action_set_line_id
                                                                  ,p_reason                  => 'REVERSED');

            l_audit_status_code := 'REVERSED';

            l_new_line_status_code := 'REVERSED';

     ELSIF l_action_line_result_code = PA_ACTION_SET_UTILS.G_REVERSED_CUSTOM_AUDIT THEN

            l_audit_status_code := 'REVERSED';

            l_new_line_status_code := 'REVERSED';

     ELSIF l_action_line_result_code = PA_ACTION_SET_UTILS.G_UPDATED_DEFAULT_AUDIT THEN

            l_action_line_audit_tbl := get_def_reverse_audit_lines(p_action_set_line_id    => p_action_set_line_id
                                                                  ,p_reason                  => 'UPDATED');

            l_audit_status_code := 'REVERSED';

            l_new_line_status_code := 'PENDING';

     ELSIF l_action_line_result_code = PA_ACTION_SET_UTILS.G_UPDATED_CUSTOM_AUDIT THEN

            l_audit_status_code := 'REVERSED';

            l_new_line_status_code := 'PENDING';

     END IF;

/*
HOW SHOULD THIS BE HANDLED???
     IF l_new_line_status_code = 'REVERSED' AND FND_MSG_PUB.Count_Msg > 0 THEN
        l_line_deleted_flag := 'N';
     ELSE
        l_line_deleted_flag := FND_API.G_MISS_CHAR;
     END IF;
*/


     IF l_action_line_result_code <> PA_ACTION_SET_UTILS.G_NOT_PERFORMED THEN


        PA_ACTION_SET_LINES_PKG.update_row
                 (p_action_set_line_id    => p_action_set_line_id,
                  p_status_code           => l_new_line_status_code,
--                  p_line_deleted_flag     => l_line_deleted_flag,
                  x_return_status         => l_return_status);

        bulk_insert_audit_lines
                         (p_audit_lines_tbl       => l_action_line_audit_tbl,
                          p_action_set_line_id    => p_action_set_line_id,
                          p_object_type           => l_action_set_details_rec.object_type,
                          p_object_id             => l_action_set_details_rec.object_id,
                          p_action_set_type_code  => p_action_set_type_code,
                          p_status_code           => l_audit_status_code,
                          x_return_status         => l_return_status);

      END IF;
/*

  --only do if line not performed from concurrent program
  IF FND_MSG_PUB.Count_Msg > 0 AND FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
     FOR i IN 1 .. FND_MSG_PUB.Count_Msg LOOP
        pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                             ,p_msg_index     => i
                                             ,p_data          => l_msg_data
                                             ,p_msg_index_out => l_msg_index_out
                                             );

        SELECT action_set_line_number INTO l_action_set_line_number
          FROM pa_action_set_lines
         WHERE action_set_line_id = p_action_set_line_id;

        g_line_number_msg_tbl.EXTEND();
        g_info_msg_tbl.EXTEND();
        g_line_number_msg_tbl(g_line_number_msg_tbl.LAST) := l_action_set_line_number;
        g_info_msg_tbl(g_info_msg_tbl.LAST)   := l_msg_data;

     END LOOP;
  END IF;

*/

  EXCEPTION
    WHEN e_invalid_result_code THEN
      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Perform_Action_Set_Line'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack
                               ,p_error_text => 'INVALID RESULT CODE:  '||l_action_line_result_code);
      --
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE e_invalid_result_code;

    WHEN OTHERS THEN
      -- Set the excetption Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PVT.Perform_Action_Set_Line'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
      --
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE;

 END Perform_Action_Set_Line;



END;

/
