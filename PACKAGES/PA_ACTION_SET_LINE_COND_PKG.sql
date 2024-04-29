--------------------------------------------------------
--  DDL for Package PA_ACTION_SET_LINE_COND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACTION_SET_LINE_COND_PKG" AUTHID CURRENT_USER AS
/*$Header: PARASCKS.pls 120.1 2005/08/19 16:47:51 mwasowic noship $*/
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
);


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
);


PROCEDURE Delete_Row
( p_action_set_line_condition_id IN    pa_action_set_line_cond.action_set_line_condition_id%TYPE
 ,p_record_version_number        IN    NUMBER                                                := NULL
 ,x_return_status                OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END;

 

/
