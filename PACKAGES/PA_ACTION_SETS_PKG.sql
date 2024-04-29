--------------------------------------------------------
--  DDL for Package PA_ACTION_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACTION_SETS_PKG" AUTHID CURRENT_USER AS
/*$Header: PARASPKS.pls 120.1 2005/08/19 16:48:09 mwasowic noship $*/
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
);


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
);


PROCEDURE Delete_Row
( p_action_set_id               IN    pa_action_sets.action_set_id%TYPE
 ,p_record_version_number       IN    NUMBER                                                := NULL
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END;

 

/
