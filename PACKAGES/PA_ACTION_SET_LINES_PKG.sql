--------------------------------------------------------
--  DDL for Package PA_ACTION_SET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACTION_SET_LINES_PKG" AUTHID CURRENT_USER AS
/*$Header: PARASLKS.pls 120.1 2005/08/19 16:48:03 mwasowic noship $*/
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
);


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
);


PROCEDURE Delete_Row
( p_action_set_line_id          IN    pa_action_set_lines.action_set_line_id%TYPE
 ,p_record_version_number       IN    NUMBER                                                := NULL
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END;

 

/
