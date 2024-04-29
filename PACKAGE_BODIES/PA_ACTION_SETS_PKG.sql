--------------------------------------------------------
--  DDL for Package Body PA_ACTION_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACTION_SETS_PKG" AS
/*$Header: PARASPKB.pls 120.2 2005/08/26 12:14:33 shyugen noship $*/
--

PROCEDURE insert_row
 (p_action_set_type_code   IN    pa_action_set_types.action_set_type_code%TYPE
 ,p_action_set_name        IN    pa_action_sets.action_set_name%TYPE
 ,p_object_type            IN    pa_action_sets.object_type%TYPE                     := NULL
 ,p_object_id              IN    pa_action_sets.object_id%TYPE                       := NULL
 ,p_start_date_active      IN    pa_action_sets.start_date_active%TYPE               := NULL
 ,p_end_date_active        IN    pa_action_sets.end_date_active%TYPE                 := NULL
 ,p_description            IN    pa_action_sets.description%TYPE                     := NULL
 ,p_source_action_set_id   IN    pa_action_sets.source_action_set_id%TYPE            := NULL
 ,p_status_code            IN    pa_action_sets.status_code%TYPE
 ,p_actual_start_date      IN    pa_action_sets.actual_start_date%TYPE               := NULL
 ,p_action_set_template_flag IN  pa_action_sets.action_set_template_flag%TYPE        := NULL
 ,p_attribute_category     IN    pa_action_sets.attribute_category%TYPE              := NULL
 ,p_attribute1             IN    pa_action_sets.attribute1%TYPE                      := NULL
 ,p_attribute2             IN    pa_action_sets.attribute2%TYPE                      := NULL
 ,p_attribute3             IN    pa_action_sets.attribute3%TYPE                      := NULL
 ,p_attribute4             IN    pa_action_sets.attribute4%TYPE                      := NULL
 ,p_attribute5             IN    pa_action_sets.attribute5%TYPE                      := NULL
 ,p_attribute6             IN    pa_action_sets.attribute6%TYPE                      := NULL
 ,p_attribute7             IN    pa_action_sets.attribute7%TYPE                      := NULL
 ,p_attribute8             IN    pa_action_sets.attribute8%TYPE                      := NULL
 ,p_attribute9             IN    pa_action_sets.attribute9%TYPE                      := NULL
 ,p_attribute10            IN    pa_action_sets.attribute10%TYPE                      := NULL
 ,p_attribute11            IN    pa_action_sets.attribute11%TYPE                      := NULL
 ,p_attribute12            IN    pa_action_sets.attribute12%TYPE                      := NULL
 ,p_attribute13            IN    pa_action_sets.attribute13%TYPE                      := NULL
 ,p_attribute14            IN    pa_action_sets.attribute14%TYPE                      := NULL
 ,p_attribute15            IN    pa_action_sets.attribute15%TYPE                      := NULL
 ,x_action_set_id         OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

  l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SET_Pkg.insert_row.begin'
                     ,x_msg         => 'Beginning of insert row'
                     ,x_log_level   => 5);
  END IF;

  INSERT INTO pa_action_sets
             (action_set_id
             ,action_set_type_code
             ,action_set_name
             ,object_type
             ,object_id
             ,start_date_active
             ,end_date_active
             ,description
             ,source_action_set_id
             ,status_code
             ,actual_start_date
             ,action_set_template_flag
             ,MOD_SOURCE_ACTION_SET_FLAG
             ,record_version_number
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,creation_date
             ,created_by
             ,last_update_date
             ,last_updated_by
             ,last_update_login)
       VALUES
            ( pa_action_sets_s.NEXTVAL
             ,p_action_set_type_code
             ,p_action_set_name
             ,p_object_type
             ,p_object_id
             ,p_start_date_active
             ,p_end_date_active
             ,p_description
             ,p_source_action_set_id
             ,p_status_code
             ,p_actual_start_date
             ,p_action_set_template_flag
             ,decode(p_action_set_template_flag,'N','N',null)
             ,1
             ,p_attribute_category
             ,p_attribute1
             ,p_attribute2
             ,p_attribute3
             ,p_attribute4
             ,p_attribute5
             ,p_attribute6
             ,p_attribute7
             ,p_attribute8
             ,p_attribute9
             ,p_attribute10
             ,p_attribute11
             ,p_attribute12
             ,p_attribute13
             ,p_attribute14
             ,p_attribute15
             ,sysdate
             ,fnd_global.user_id
             ,sysdate
             ,fnd_global.user_id
             ,fnd_global.login_id
            )
             RETURNING action_set_id INTO x_action_set_id;


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PKG.Insert_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Insert_Row;


PROCEDURE update_row
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE
 ,p_action_set_name        IN    pa_action_sets.action_set_name%TYPE              := FND_API.G_MISS_CHAR
 ,p_start_date_active      IN    pa_action_sets.start_date_active%TYPE            := FND_API.G_MISS_DATE
 ,p_end_date_active        IN    pa_action_sets.end_date_active%TYPE              := FND_API.G_MISS_DATE
 ,p_description            IN    pa_action_sets.description%TYPE                  := FND_API.G_MISS_CHAR
 ,p_source_action_set_id   IN    pa_action_sets.source_action_set_id%TYPE         := FND_API.G_MISS_NUM
 ,p_status_code            IN    pa_action_sets.status_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_actual_start_date      IN    pa_action_sets.actual_start_date%TYPE            := FND_API.G_MISS_DATE
 ,p_record_version_number  IN    pa_action_sets.record_version_number%TYPE        := NULL
 ,p_attribute_category     IN    pa_action_sets.attribute_category%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute1             IN    pa_action_sets.attribute1%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute2             IN    pa_action_sets.attribute2%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute3             IN    pa_action_sets.attribute3%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute4             IN    pa_action_sets.attribute4%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute5             IN    pa_action_sets.attribute5%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute6             IN    pa_action_sets.attribute6%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute7             IN    pa_action_sets.attribute7%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute8             IN    pa_action_sets.attribute8%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute9             IN    pa_action_sets.attribute9%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute10            IN    pa_action_sets.attribute10%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute11            IN    pa_action_sets.attribute11%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute12            IN    pa_action_sets.attribute12%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute13            IN    pa_action_sets.attribute13%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute14            IN    pa_action_sets.attribute14%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute15            IN    pa_action_sets.attribute15%TYPE                  := FND_API.G_MISS_CHAR
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

  l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message: 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SETS_Pkg.update_row.begin'
                     ,x_msg         => 'Beginning of update row'
                     ,x_log_level   => 5);
  END IF;

  UPDATE pa_action_sets
     SET action_set_name = decode(p_action_set_name, FND_API.G_MISS_CHAR, action_set_name, p_action_set_name)
        ,start_date_active = decode(p_start_date_active, FND_API.G_MISS_DATE, start_date_active, p_start_date_active)
        ,end_date_active = decode(p_end_date_active, FND_API.G_MISS_DATE, end_date_active, p_end_date_active)
        ,description = decode(p_description, FND_API.G_MISS_CHAR, description, p_description)
        ,status_code = decode(p_status_code, FND_API.G_MISS_CHAR, status_code, p_status_code)
        ,actual_start_date = decode(p_actual_start_date, FND_API.G_MISS_DATE, actual_start_date, p_actual_start_date)
        ,record_version_number = record_version_number+1
        ,attribute_category = decode(p_attribute_category, FND_API.G_MISS_CHAR, attribute_category, p_attribute_category)
        ,attribute1 = decode(p_attribute1, FND_API.G_MISS_CHAR, attribute1, p_attribute1)
        ,attribute2 = decode(p_attribute2, FND_API.G_MISS_CHAR, attribute2, p_attribute2)
        ,attribute3 = decode(p_attribute3, FND_API.G_MISS_CHAR, attribute3, p_attribute3)
        ,attribute4 = decode(p_attribute4, FND_API.G_MISS_CHAR, attribute4, p_attribute4)
        ,attribute5 = decode(p_attribute5, FND_API.G_MISS_CHAR, attribute5, p_attribute5)
        ,attribute6 = decode(p_attribute6, FND_API.G_MISS_CHAR, attribute6, p_attribute6)
        ,attribute7 = decode(p_attribute7, FND_API.G_MISS_CHAR, attribute7, p_attribute7)
        ,attribute8 = decode(p_attribute8, FND_API.G_MISS_CHAR, attribute8, p_attribute8)
        ,attribute9 = decode(p_attribute9, FND_API.G_MISS_CHAR, attribute9, p_attribute9)
        ,attribute10 = decode(p_attribute10, FND_API.G_MISS_CHAR, attribute10, p_attribute10)
        ,attribute11 = decode(p_attribute11, FND_API.G_MISS_CHAR, attribute11, p_attribute11)
        ,attribute12 = decode(p_attribute12, FND_API.G_MISS_CHAR, attribute12, p_attribute12)
        ,attribute13 = decode(p_attribute13, FND_API.G_MISS_CHAR, attribute13, p_attribute13)
        ,attribute14 = decode(p_attribute14, FND_API.G_MISS_CHAR, attribute14, p_attribute14)
        ,attribute15 = decode(p_attribute15, FND_API.G_MISS_CHAR, attribute15, p_attribute15)
        ,last_update_date = sysdate
        ,last_updated_by = fnd_global.user_id
        ,last_update_login = fnd_global.login_id
  WHERE action_set_id = p_action_set_id
    AND record_version_number = nvl(p_record_version_number, record_version_number);

  IF (SQL%NOTFOUND) THEN

       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SETS_PKG.update_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

  END update_row;

PROCEDURE Delete_Row
( p_action_set_id               IN    pa_action_sets.action_set_id%TYPE
 ,p_record_version_number       IN    NUMBER                                                := NULL
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM  pa_action_sets
          WHERE  action_set_id = p_action_set_id
            AND  nvl(p_record_version_number, record_version_number) = record_version_number;

  --
  IF (SQL%NOTFOUND) THEN

       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;
  --
  --

  EXCEPTION
    WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ACTION_SETS_PKG.Delete_Row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Row;


END pa_action_sets_pkg;

/
