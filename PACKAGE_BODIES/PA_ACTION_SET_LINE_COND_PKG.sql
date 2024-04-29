--------------------------------------------------------
--  DDL for Package Body PA_ACTION_SET_LINE_COND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACTION_SET_LINE_COND_PKG" AS
/*$Header: PARASCKB.pls 120.2 2005/08/26 11:59:22 shyugen noship $*/
--

PROCEDURE insert_row
 (p_action_set_line_id        IN    pa_action_set_lines.action_set_line_id%TYPE
 ,p_condition_date            IN    pa_action_set_line_cond.condition_date%TYPE                     := NULL
 ,p_description               IN    pa_action_set_line_cond.description%TYPE                        := NULL
 ,p_condition_code            IN    pa_action_set_line_cond.condition_code%TYPE
 ,p_condition_attribute1      IN    pa_action_set_line_cond.condition_attribute1%TYPE               := NULL
 ,p_condition_attribute2      IN    pa_action_set_line_cond.condition_attribute2%TYPE               := NULL
 ,p_condition_attribute3      IN    pa_action_set_line_cond.condition_attribute3%TYPE               := NULL
 ,p_condition_attribute4      IN    pa_action_set_line_cond.condition_attribute4%TYPE               := NULL
 ,p_condition_attribute5      IN    pa_action_set_line_cond.condition_attribute5%TYPE               := NULL
 ,p_condition_attribute6      IN    pa_action_set_line_cond.condition_attribute6%TYPE               := NULL
 ,p_condition_attribute7      IN    pa_action_set_line_cond.condition_attribute7%TYPE               := NULL
 ,p_condition_attribute8      IN    pa_action_set_line_cond.condition_attribute8%TYPE               := NULL
 ,p_condition_attribute9      IN    pa_action_set_line_cond.condition_attribute9%TYPE               := NULL
 ,p_condition_attribute10     IN    pa_action_set_line_cond.condition_attribute10%TYPE              := NULL
 ,x_action_set_line_condition_id    OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

  l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message - 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SET_LINE_COND_Pkg.insert_row.begin'
                     ,x_msg         => 'Beginning of insert row'
                     ,x_log_level   => 5);
  END IF;

  INSERT INTO pa_action_set_line_cond
             (action_set_line_condition_id
             ,action_set_line_id
             ,condition_date
             ,description
             ,condition_code
             ,condition_attribute1
             ,condition_attribute2
             ,condition_attribute3
             ,condition_attribute4
             ,condition_attribute5
             ,condition_attribute6
             ,condition_attribute7
             ,condition_attribute8
             ,condition_attribute9
             ,condition_attribute10
             ,creation_date
             ,created_by
             ,last_update_date
             ,last_updated_by
             ,last_update_login)
       VALUES
            ( pa_action_set_line_cond_s.NEXTVAL
             ,p_action_set_line_id
             ,p_condition_date
             ,p_description
             ,p_condition_code
             ,p_condition_attribute1
             ,p_condition_attribute2
             ,p_condition_attribute3
             ,p_condition_attribute4
             ,p_condition_attribute5
             ,p_condition_attribute6
             ,p_condition_attribute7
             ,p_condition_attribute8
             ,p_condition_attribute9
             ,p_condition_attribute10
             ,sysdate
             ,fnd_global.user_id
             ,sysdate
             ,fnd_global.user_id
             ,fnd_global.login_id
            )
             RETURNING action_set_line_condition_id INTO x_action_set_line_condition_id;


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SET_LINE_COND_PKG.Insert_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Insert_Row;


PROCEDURE update_row
 (p_action_set_line_condition_id  IN    pa_action_set_line_cond.action_set_line_condition_id%TYPE
 ,p_condition_date            IN    pa_action_set_line_cond.condition_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_description               IN    pa_action_set_line_cond.description%TYPE                     := FND_API.G_MISS_CHAR
 ,p_record_version_number     IN    NUMBER                                                       := NULL
 ,p_condition_code            IN    pa_action_set_line_cond.condition_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_condition_attribute1      IN    pa_action_set_line_cond.condition_attribute1%TYPE            := FND_API.G_MISS_CHAR
 ,p_condition_attribute2      IN    pa_action_set_line_cond.condition_attribute2%TYPE            := FND_API.G_MISS_CHAR
 ,p_condition_attribute3      IN    pa_action_set_line_cond.condition_attribute3%TYPE            := FND_API.G_MISS_CHAR
 ,p_condition_attribute4      IN    pa_action_set_line_cond.condition_attribute4%TYPE            := FND_API.G_MISS_CHAR
 ,p_condition_attribute5      IN    pa_action_set_line_cond.condition_attribute5%TYPE            := FND_API.G_MISS_CHAR
 ,p_condition_attribute6      IN    pa_action_set_line_cond.condition_attribute6%TYPE            := FND_API.G_MISS_CHAR
 ,p_condition_attribute7      IN    pa_action_set_line_cond.condition_attribute7%TYPE            := FND_API.G_MISS_CHAR
 ,p_condition_attribute8      IN    pa_action_set_line_cond.condition_attribute8%TYPE            := FND_API.G_MISS_CHAR
 ,p_condition_attribute9      IN    pa_action_set_line_cond.condition_attribute9%TYPE            := FND_API.G_MISS_CHAR
 ,p_condition_attribute10     IN    pa_action_set_line_cond.condition_attribute10%TYPE           := FND_API.G_MISS_CHAR
 ,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
e_row_is_locked  EXCEPTION;
PRAGMA EXCEPTION_INIT(e_row_is_locked, -54);

l_rowid  ROWID;
l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message - 4403338
  IF l_debug_mode = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SET_LINE_COND_Pkg.update_row.begin'
                     ,x_msg         => 'Beginning of update row'
                     ,x_log_level   => 5);
  END IF;

  SELECT rowid INTO l_rowid
    FROM pa_action_set_line_cond
   WHERE action_set_line_condition_id = p_action_set_line_condition_id
     FOR UPDATE NOWAIT;

  UPDATE pa_action_set_line_cond
     SET condition_date = decode(p_condition_date, FND_API.G_MISS_DATE, condition_date, p_condition_date)
        ,description = decode(p_description, FND_API.G_MISS_CHAR, description, p_description)
        ,condition_code = decode(p_condition_code, FND_API.G_MISS_CHAR, condition_code, p_condition_code)
        ,condition_attribute1 = decode(p_condition_attribute1, FND_API.G_MISS_CHAR, condition_attribute1, p_condition_attribute1)
        ,condition_attribute2 = decode(p_condition_attribute2, FND_API.G_MISS_CHAR, condition_attribute2, p_condition_attribute2)
        ,condition_attribute3 = decode(p_condition_attribute3, FND_API.G_MISS_CHAR, condition_attribute3, p_condition_attribute3)
        ,condition_attribute4 = decode(p_condition_attribute4, FND_API.G_MISS_CHAR, condition_attribute4, p_condition_attribute4)
        ,condition_attribute5 = decode(p_condition_attribute5, FND_API.G_MISS_CHAR, condition_attribute5, p_condition_attribute5)
        ,condition_attribute6 = decode(p_condition_attribute6, FND_API.G_MISS_CHAR, condition_attribute6, p_condition_attribute6)
        ,condition_attribute7 = decode(p_condition_attribute7, FND_API.G_MISS_CHAR, condition_attribute7, p_condition_attribute7)
        ,condition_attribute8 = decode(p_condition_attribute8, FND_API.G_MISS_CHAR, condition_attribute8, p_condition_attribute8)
        ,condition_attribute9 = decode(p_condition_attribute9, FND_API.G_MISS_CHAR, condition_attribute9, p_condition_attribute9)
        ,condition_attribute10 = decode(p_condition_attribute10, FND_API.G_MISS_CHAR, condition_attribute10, p_condition_attribute10)
        ,last_update_date = sysdate
        ,last_updated_by = fnd_global.user_id
        ,last_update_login = fnd_global.login_id
  WHERE rowid = l_rowid;

  IF (SQL%NOTFOUND) THEN

       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
    WHEN e_row_is_locked THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_ACTION_LINE_CHANGE_PENDING');
       x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SET_LINE_COND_PKG.update_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

  END update_row;

PROCEDURE Delete_Row
( p_action_set_line_condition_id IN    pa_action_set_line_cond.action_set_line_condition_id%TYPE
 ,p_record_version_number        IN    NUMBER                                                := NULL
 ,x_return_status                OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM  pa_action_set_line_cond
          WHERE  action_set_line_condition_id = p_action_set_line_condition_id;

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
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ACTION_SET_LINE_COND_PKG.Delete_Row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Row;


END pa_action_set_line_cond_pkg;

/
