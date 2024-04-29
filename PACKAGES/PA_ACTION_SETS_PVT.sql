--------------------------------------------------------
--  DDL for Package PA_ACTION_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACTION_SETS_PVT" AUTHID CURRENT_USER AS
/*$Header: PARASPVS.pls 120.1 2005/08/19 16:48:26 mwasowic noship $*/
--

g_line_number_msg_tbl    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
g_info_msg_tbl           SYSTEm.pa_varchar2_2000_tbl_type := SYSTEm.pa_varchar2_2000_tbl_type();

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
);

PROCEDURE update_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE            := NULL
 ,p_action_set_name        IN    pa_action_sets.action_set_name%TYPE          := FND_API.G_MISS_CHAR
 ,p_action_set_type_code   IN    pa_action_sets.action_set_type_code%TYPE     := FND_API.G_MISS_CHAR
 ,p_start_date_active      IN    pa_action_sets.start_date_active%TYPE        := FND_API.G_MISS_DATE
 ,p_end_date_active        IN    pa_action_sets.end_date_active%TYPE          := FND_API.G_MISS_DATE
 ,p_action_set_template_flag IN  pa_action_sets.action_set_template_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_status_code            IN    pa_action_sets.status_code%TYPE              := FND_API.G_MISS_CHAR
 ,p_description            IN    pa_action_sets.description%TYPE              := FND_API.G_MISS_CHAR
 ,p_record_version_number  IN    pa_action_sets.record_version_number%TYPE
 ,p_attribute_category     IN    pa_action_sets.attribute_category%TYPE       := FND_API.G_MISS_CHAR
 ,p_attribute1             IN    pa_action_sets.attribute1%TYPE               := FND_API.G_MISS_CHAR
 ,p_attribute2             IN    pa_action_sets.attribute2%TYPE               := FND_API.G_MISS_CHAR
 ,p_attribute3             IN    pa_action_sets.attribute3%TYPE               := FND_API.G_MISS_CHAR
 ,p_attribute4             IN    pa_action_sets.attribute4%TYPE               := FND_API.G_MISS_CHAR
 ,p_attribute5             IN    pa_action_sets.attribute5%TYPE               := FND_API.G_MISS_CHAR
 ,p_attribute6             IN    pa_action_sets.attribute6%TYPE               := FND_API.G_MISS_CHAR
 ,p_attribute7             IN    pa_action_sets.attribute7%TYPE               := FND_API.G_MISS_CHAR
 ,p_attribute8             IN    pa_action_sets.attribute8%TYPE               := FND_API.G_MISS_CHAR
 ,p_attribute9             IN    pa_action_sets.attribute9%TYPE               := FND_API.G_MISS_CHAR
 ,p_attribute10            IN    pa_action_sets.attribute10%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute11            IN    pa_action_sets.attribute11%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute12            IN    pa_action_sets.attribute12%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute13            IN    pa_action_sets.attribute13%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute14            IN    pa_action_sets.attribute14%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute15            IN    pa_action_sets.attribute15%TYPE             := FND_API.G_MISS_CHAR
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE delete_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE
 ,p_record_version_number  IN    pa_action_sets.record_version_number%TYPE   := NULL
 ,x_return_status         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE create_action_set_line
 (p_action_set_id            IN    pa_action_sets.action_set_id%TYPE
 ,p_use_def_description_flag IN    VARCHAR2                                        := 'Y'
 ,p_description              IN    pa_action_set_lines.description%TYPE            := NULL
 ,p_action_set_line_number   IN    pa_action_set_lines.action_set_line_number%TYPE := NULL
 ,p_action_code              IN    pa_action_set_lines.action_code%TYPE
 ,p_action_attribute1        IN    pa_action_set_lines.action_attribute1%TYPE      := NULL
 ,p_action_attribute2        IN    pa_action_set_lines.action_attribute2%TYPE      := NULL
 ,p_action_attribute3        IN    pa_action_set_lines.action_attribute3%TYPE      := NULL
 ,p_action_attribute4        IN    pa_action_set_lines.action_attribute4%TYPE      := NULL
 ,p_action_attribute5        IN    pa_action_set_lines.action_attribute5%TYPE      := NULL
 ,p_action_attribute6        IN    pa_action_set_lines.action_attribute6%TYPE      := NULL
 ,p_action_attribute7        IN    pa_action_set_lines.action_attribute7%TYPE      := NULL
 ,p_action_attribute8        IN    pa_action_set_lines.action_attribute8%TYPE      := NULL
 ,p_action_attribute9        IN    pa_action_set_lines.action_attribute9%TYPE      := NULL
 ,p_action_attribute10       IN    pa_action_set_lines.action_attribute10%TYPE     := NULL
 ,p_condition_tbl            IN    pa_action_set_utils.action_line_cond_tbl_type
 ,x_action_set_line_id      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

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
);

PROCEDURE delete_action_set_line
 (p_action_set_line_id     IN    pa_action_sets.action_set_id%TYPE
 ,p_record_version_number  IN    pa_action_set_lines.record_version_number%TYPE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

FUNCTION get_def_reverse_audit_lines(p_action_set_line_id            IN  pa_action_set_lines.action_set_line_id%TYPE,
                                     p_reason                        IN  VARCHAR2) RETURN pa_action_set_utils.insert_audit_lines_tbl_type;

PROCEDURE bulk_insert_audit_lines(p_audit_lines_tbl      IN  pa_action_set_utils.insert_audit_lines_tbl_type,
                                  p_action_set_line_id   IN  pa_action_set_lines.action_set_line_id%TYPE,
                                  p_object_type          IN  pa_action_sets.object_type%TYPE,
                                  p_object_id            IN  pa_action_sets.object_id%TYPE,
                                  p_action_set_type_code IN  pa_action_sets.action_set_type_code%TYPE,
                                  p_status_code         IN  VARCHAR2,
                                  x_return_status      OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE perform_action_set_line
 (p_action_set_type_code   IN    pa_action_set_types.action_set_type_code%TYPE
 ,p_action_set_line_id     IN    pa_action_sets.action_set_id%TYPE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE bulk_update_line_number(p_action_set_line_id_tbl      IN  pa_action_set_utils.number_tbl_type,
                                  p_line_number_tbl             IN  pa_action_set_utils.number_tbl_type,
                                  x_return_status              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE bulk_update_condition_date(p_action_line_condition_id_tbl      IN  pa_action_set_utils.number_tbl_type,
                                     p_condition_date_tbl                IN  pa_action_set_utils.date_tbl_type,
                                     x_return_status                    OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE bulk_update_line_status(p_action_set_line_id_tbl      IN  pa_action_set_utils.number_tbl_type,
                                  p_line_status_tbl             IN  pa_action_set_utils.varchar_tbl_type,
                                  x_return_status              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END;

 

/
