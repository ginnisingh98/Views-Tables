--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SETS_PKG" AS
/*$Header: PAPPSPKB.pls 120.1 2005/08/19 16:43:34 mwasowic noship $*/
--+

PROCEDURE insert_row
( p_project_set_name       IN    pa_project_sets_tl.name%TYPE
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE
 ,p_description            IN    pa_project_sets_tl.description%TYPE
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
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SET_Pkg.insert_row.begin'
                     ,x_msg         => 'Beginning of insert row'
                     ,x_log_level   => 5);
  END IF;

  INSERT INTO pa_project_sets_b
             (project_set_id
             ,party_id
             ,effective_start_date
             ,effective_end_date
             ,access_level
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
             ,record_version_number
             ,creation_date
             ,created_by
             ,last_update_date
             ,last_updated_by
             ,last_update_login)
       VALUES
            ( pa_project_sets_b_s.NEXTVAL
             ,p_party_id
             ,p_effective_start_date
             ,p_effective_end_date
             ,p_access_level
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
             ,1
             ,sysdate
             ,fnd_global.user_id
             ,sysdate
             ,fnd_global.user_id
             ,fnd_global.login_id
            )
       RETURNING project_set_id INTO x_project_set_id;

  INSERT INTO pa_project_sets_tl
           ( project_set_id
            ,language
            ,source_lang
            ,name
            ,description
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login)
      SELECT
            x_project_set_id
           ,L.language_code
           ,userenv('LANG')
           ,p_project_set_name
           ,p_description
           ,sysdate
           ,fnd_global.user_id
           ,sysdate
           ,fnd_global.user_id
           ,fnd_global.login_id
      FROM fnd_languages L
      WHERE l.installed_flag IN ('I', 'B')
        AND NOT EXISTS
          (select null
           from pa_project_sets_tl T
           where T.project_set_id = x_project_set_id
             and T.language = L.language_code);


  -- Put any message text from message stack into the Message ARRAY
EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PKG.Insert_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Insert_Row;


PROCEDURE update_row
( p_project_set_id         IN    pa_project_sets_b.project_set_id%TYPE
 ,p_project_set_name       IN    pa_project_sets_tl.name%TYPE
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE
 ,p_description            IN    pa_project_sets_tl.description%TYPE
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
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SETS_Pkg.update_row.begin'
                     ,x_msg         => 'Beginning of update row'
                     ,x_log_level   => 5);
  END IF;

  UPDATE pa_project_sets_b
     SET party_id = decode(p_party_id, FND_API.G_MISS_NUM, party_id, p_party_id)
        ,effective_start_date = decode(p_effective_start_date, FND_API.G_MISS_DATE, effective_start_date, p_effective_start_date)
        ,effective_end_date = decode(p_effective_end_date, FND_API.G_MISS_DATE, effective_end_date, p_effective_end_date)
        ,access_level = decode(p_access_level, FND_API.G_MISS_NUM, access_level, p_access_level)
        ,record_version_number = record_version_number + 1
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
  WHERE project_set_id = p_project_set_id
    AND record_version_number = nvl(p_record_version_number, record_version_number);

  IF (sql%notfound) THEN
    PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE

    UPDATE pa_project_sets_tl
      SET name = decode(p_project_set_name, FND_API.G_MISS_CHAR, name, p_project_set_name)
       ,description = decode(p_description, FND_API.G_MISS_CHAR, description, p_description)
       ,last_update_date = sysdate
       ,last_updated_by = fnd_global.user_id
       ,last_update_login = fnd_global.login_id
    WHERE project_set_id = p_project_set_id
      AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    IF (sql%notfound) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  -- Put any message text from message stack into the Message ARRAY
EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SETS_PKG.update_row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END update_row;


PROCEDURE delete_row
(  p_project_set_id        IN  pa_project_sets_b.project_set_id%TYPE
  ,p_record_version_number IN  pa_project_sets_b.record_version_number%TYPE
  ,x_return_status        OUT  NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
)
IS
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM  pa_project_sets_b
  WHERE  project_set_id = p_project_set_id
    AND  nvl(p_record_version_number, record_version_number) = record_version_number;

  IF (SQL%NOTFOUND) THEN
      PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
      x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE

    DELETE FROM  pa_project_sets_tl
    WHERE  project_set_id = p_project_set_id;

    IF (SQL%NOTFOUND) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_SETS_PKG.Delete_Row'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Row;


PROCEDURE insert_row_lines
( p_project_set_id   IN   pa_project_set_lines.project_set_id%TYPE
 ,p_project_id       IN   pa_project_set_lines.project_id%TYPE
 ,x_return_status   OUT   NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
)
IS
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SET_Pkg.insert_row_lines.begin'
                     ,x_msg         => 'Beginning of insert row lines'
                     ,x_log_level   => 5);
  END IF;

  INSERT INTO pa_project_set_lines(
         project_set_id
        ,project_id
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login)
  VALUES ( p_project_set_id
          ,p_project_id
          ,sysdate
          ,fnd_global.user_id
          ,sysdate
          ,fnd_global.user_id
          ,fnd_global.login_id);

  -- Put any message text from message stack into the Message ARRAY
EXCEPTION
    WHEN OTHERS THEN
       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SET_LINES_PKG.Insert_row_lines'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Insert_Row_Lines;


PROCEDURE delete_row_lines
( p_project_set_id   IN   pa_project_set_lines.project_set_id%TYPE
 ,p_project_id       IN   pa_project_set_lines.project_id%TYPE
 ,x_return_status   OUT   NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
)
IS
 l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Log Message
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_PROJECT_SET_Pkg.delete_row_lines.begin'
                     ,x_msg         => 'Beginning of delete row lines'
                     ,x_log_level   => 5);
  END IF;

  DELETE FROM pa_project_set_lines
  WHERE project_set_id = p_project_set_id
    AND project_id     = p_project_id;


  -- Put any message text from message stack into the Message ARRAY
EXCEPTION
    WHEN OTHERS THEN
       -- Set the exception Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SET_LINES_PKG.Delete_row_lines'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END Delete_Row_Lines;


--
-- The following procedure is generated by utility /fnddev/fnd/11.5/bin/tltblgen
-- This is needed by MLS processing. See bug 3024610 for details.
--
procedure ADD_LANGUAGE
is
begin
  delete from PA_PROJECT_SETS_TL T
  where not exists
    (select NULL
    from PA_PROJECT_SETS_B B
    where B.PROJECT_SET_ID = T.PROJECT_SET_ID
    );

  update PA_PROJECT_SETS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PA_PROJECT_SETS_TL B
    where B.PROJECT_SET_ID = T.PROJECT_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PROJECT_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PROJECT_SET_ID,
      SUBT.LANGUAGE
    from PA_PROJECT_SETS_TL SUBB, PA_PROJECT_SETS_TL SUBT
    where SUBB.PROJECT_SET_ID = SUBT.PROJECT_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PA_PROJECT_SETS_TL (
    PROJECT_SET_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PROJECT_SET_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PA_PROJECT_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PA_PROJECT_SETS_TL T
    where T.PROJECT_SET_ID = B.PROJECT_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end PA_PROJECT_SETS_PKG;

/
