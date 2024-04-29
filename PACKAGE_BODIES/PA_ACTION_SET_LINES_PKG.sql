--------------------------------------------------------
--  DDL for Package Body PA_ACTION_SET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACTION_SET_LINES_PKG" AS
/*$Header: PARASLKB.pls 120.2 2005/08/26 12:11:37 shyugen noship $*/
--

PROCEDURE insert_row
 (p_action_set_id          IN    pa_action_set_lines.action_set_id%TYPE
 ,p_action_set_line_number IN    pa_action_set_lines.action_set_line_number%TYPE          := NULL
 ,p_status_code            IN    pa_action_set_lines.status_code%TYPE
 ,p_description            IN    pa_action_set_lines.description%TYPE                     := NULL
 ,p_line_deleted_flag      IN    pa_action_set_lines.line_deleted_flag%TYPE               :='N'
 ,p_action_code            IN    pa_action_set_lines.action_code%TYPE
 ,p_action_attribute1      IN    pa_action_set_lines.action_attribute1%TYPE               := NULL
 ,p_action_attribute2      IN    pa_action_set_lines.action_attribute2%TYPE               := NULL
 ,p_action_attribute3      IN    pa_action_set_lines.action_attribute3%TYPE               := NULL
 ,p_action_attribute4      IN    pa_action_set_lines.action_attribute4%TYPE               := NULL
 ,p_action_attribute5      IN    pa_action_set_lines.action_attribute5%TYPE               := NULL
 ,p_action_attribute6      IN    pa_action_set_lines.action_attribute6%TYPE               := NULL
 ,p_action_attribute7      IN    pa_action_set_lines.action_attribute7%TYPE               := NULL
 ,p_action_attribute8      IN    pa_action_set_lines.action_attribute8%TYPE               := NULL
 ,p_action_attribute9      IN    pa_action_set_lines.action_attribute9%TYPE               := NULL
 ,p_action_attribute10     IN    pa_action_set_lines.action_attribute10%TYPE              := NULL
 ,x_action_set_line_id    OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
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
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SET_Pkg.insert_row.begin'
                     ,x_msg         => 'Beginning of insert row'
                     ,x_log_level   => 5);
  END IF;

  INSERT INTO pa_action_set_lines
             (action_set_line_id
             ,action_set_id
             ,action_set_line_number
             ,status_code
             ,description
             ,line_deleted_flag
             ,action_code
             ,action_attribute1
             ,action_attribute2
             ,action_attribute3
             ,action_attribute4
             ,action_attribute5
             ,action_attribute6
             ,action_attribute7
             ,action_attribute8
             ,action_attribute9
             ,action_attribute10
             ,record_version_number
             ,creation_date
             ,created_by
             ,last_update_date
             ,last_updated_by
             ,last_update_login)
       VALUES
            ( pa_action_set_lines_s.NEXTVAL
             ,p_action_set_id
             ,p_action_set_line_number
             ,p_status_code
             ,p_description
             ,p_line_deleted_flag
             ,p_action_code
             ,p_action_attribute1
             ,p_action_attribute2
             ,p_action_attribute3
             ,p_action_attribute4
             ,p_action_attribute5
             ,p_action_attribute6
             ,p_action_attribute7
             ,p_action_attribute8
             ,p_action_attribute9
             ,p_action_attribute10
             ,1
             ,sysdate
             ,fnd_global.user_id
             ,sysdate
             ,fnd_global.user_id
             ,fnd_global.login_id
            )
             RETURNING action_set_line_id INTO x_action_set_line_id;


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SET_LINES_PKG.Insert_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Insert_Row;


PROCEDURE update_row
 (p_action_set_line_id     IN    pa_action_set_lines.action_set_line_id%TYPE
 ,p_action_set_line_number IN    pa_action_set_lines.action_set_line_number%TYPE          := FND_API.G_MISS_NUM
 ,p_record_version_number  IN    NUMBER                                                   := NULL
 ,p_status_code            IN    pa_action_set_lines.status_code%TYPE                     := FND_API.G_MISS_CHAR
 ,p_description            IN    pa_action_set_lines.description%TYPE                     := FND_API.G_MISS_CHAR
 ,p_line_deleted_flag      IN    pa_action_set_lines.line_deleted_flag%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_code            IN    pa_action_set_lines.action_code%TYPE                     := FND_API.G_MISS_CHAR
 ,p_action_attribute1      IN    pa_action_set_lines.action_attribute1%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_attribute2      IN    pa_action_set_lines.action_attribute2%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_attribute3      IN    pa_action_set_lines.action_attribute3%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_attribute4      IN    pa_action_set_lines.action_attribute4%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_attribute5      IN    pa_action_set_lines.action_attribute5%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_attribute6      IN    pa_action_set_lines.action_attribute6%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_attribute7      IN    pa_action_set_lines.action_attribute7%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_attribute8      IN    pa_action_set_lines.action_attribute8%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_attribute9      IN    pa_action_set_lines.action_attribute9%TYPE               := FND_API.G_MISS_CHAR
 ,p_action_attribute10     IN    pa_action_set_lines.action_attribute10%TYPE              := FND_API.G_MISS_CHAR
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

e_row_is_locked EXCEPTION;
PRAGMA EXCEPTION_INIT(e_row_is_locked, -54);

l_rowid   ROWID;
l_debug_mode            VARCHAR2(20) := 'N';

BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Bug 4403338
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  --Log Message - 4403338
  IF l_debug_mode = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ACTION_SET_LINES_Pkg.update_row.begin'
                     ,x_msg         => 'Beginning of update row'
                     ,x_log_level   => 5);
  END IF;

  SELECT rowid INTO l_rowid
    FROM pa_action_set_lines
   WHERE action_set_line_id = p_action_set_line_id
     FOR UPDATE NOWAIT;

  UPDATE pa_action_set_lines
     SET action_set_line_number = decode(p_action_set_line_number, FND_API.G_MISS_NUM, action_set_line_number, p_action_set_line_number)
        ,status_code = decode(p_status_code, FND_API.G_MISS_CHAR, status_code, p_status_code)
        ,description = decode(p_description, FND_API.G_MISS_CHAR, description, p_description)
        ,line_deleted_flag = decode(p_line_deleted_flag, FND_API.G_MISS_CHAR, line_deleted_flag, p_line_deleted_flag)
        ,record_version_number = record_version_number+1
        ,action_code = decode(p_action_code, FND_API.G_MISS_CHAR, action_code, p_action_code)
        ,action_attribute1 = decode(p_action_attribute1, FND_API.G_MISS_CHAR, action_attribute1, p_action_attribute1)
        ,action_attribute2 = decode(p_action_attribute2, FND_API.G_MISS_CHAR, action_attribute2, p_action_attribute2)
        ,action_attribute3 = decode(p_action_attribute3, FND_API.G_MISS_CHAR, action_attribute3, p_action_attribute3)
        ,action_attribute4 = decode(p_action_attribute4, FND_API.G_MISS_CHAR, action_attribute4, p_action_attribute4)
        ,action_attribute5 = decode(p_action_attribute5, FND_API.G_MISS_CHAR, action_attribute5, p_action_attribute5)
        ,action_attribute6 = decode(p_action_attribute6, FND_API.G_MISS_CHAR, action_attribute6, p_action_attribute6)
        ,action_attribute7 = decode(p_action_attribute7, FND_API.G_MISS_CHAR, action_attribute7, p_action_attribute7)
        ,action_attribute8 = decode(p_action_attribute8, FND_API.G_MISS_CHAR, action_attribute8, p_action_attribute8)
        ,action_attribute9 = decode(p_action_attribute9, FND_API.G_MISS_CHAR, action_attribute9, p_action_attribute9)
        ,action_attribute10 = decode(p_action_attribute10, FND_API.G_MISS_CHAR, action_attribute10, p_action_attribute10)
        ,last_update_date = sysdate
        ,last_updated_by = fnd_global.user_id
        ,last_update_login = fnd_global.login_id
  WHERE rowid = l_rowid
    AND record_version_number = nvl(p_record_version_number, record_version_number);

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
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ACTION_SET_LINES_PKG.update_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

  END update_row;

PROCEDURE Delete_Row
( p_action_set_line_id          IN    pa_action_set_lines.action_set_line_id%TYPE
 ,p_record_version_number       IN    NUMBER                                                := NULL
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM  pa_action_set_lines
          WHERE  action_set_line_id = p_action_set_line_id
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
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ACTION_SET_LINES_PKG.Delete_Row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Row;


END pa_action_set_lines_pkg;

/
