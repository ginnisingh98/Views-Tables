--------------------------------------------------------
--  DDL for Package PA_PROJECT_SETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_SETS_PUB" AUTHID CURRENT_USER AS
/*$Header: PAPPSPUS.pls 120.1 2005/08/19 16:43:45 mwasowic noship $*/
--
PROCEDURE create_project_set
( p_project_set_name       IN    pa_project_sets_tl.name%TYPE
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE       := NULL
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE
 ,p_description            IN    pa_project_sets_tl.description%TYPE             := NULL
 ,p_party_name             IN    hz_parties.party_name%TYPE
 ,p_attribute_category     IN    pa_project_sets_b.attribute_category%TYPE       := NULL
 ,p_attribute1             IN    pa_project_sets_b.attribute1%TYPE               := NULL
 ,p_attribute2             IN    pa_project_sets_b.attribute2%TYPE               := NULL
 ,p_attribute3             IN    pa_project_sets_b.attribute3%TYPE               := NULL
 ,p_attribute4             IN    pa_project_sets_b.attribute4%TYPE               := NULL
 ,p_attribute5             IN    pa_project_sets_b.attribute5%TYPE               := NULL
 ,p_attribute6             IN    pa_project_sets_b.attribute6%TYPE               := NULL
 ,p_attribute7             IN    pa_project_sets_b.attribute7%TYPE               := NULL
 ,p_attribute8             IN    pa_project_sets_b.attribute8%TYPE               := NULL
 ,p_attribute9             IN    pa_project_sets_b.attribute9%TYPE               := NULL
 ,p_attribute10            IN    pa_project_sets_b.attribute10%TYPE              := NULL
 ,p_attribute11            IN    pa_project_sets_b.attribute11%TYPE              := NULL
 ,p_attribute12            IN    pa_project_sets_b.attribute12%TYPE              := NULL
 ,p_attribute13            IN    pa_project_sets_b.attribute13%TYPE              := NULL
 ,p_attribute14            IN    pa_project_sets_b.attribute14%TYPE              := NULL
 ,p_attribute15            IN    pa_project_sets_b.attribute15%TYPE              := NULL
 ,p_api_version            IN    NUMBER                                          := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                 IN    VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                        := FND_API.G_TRUE
 ,x_project_set_id        OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE update_project_set
 (p_project_set_id         IN    pa_project_sets_b.project_set_id%TYPE
 ,p_project_set_name       IN    pa_project_sets_tl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE                := FND_API.G_MISS_NUM
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE    := FND_API.G_MISS_DATE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE      := FND_API.G_MISS_DATE
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE            := FND_API.G_MISS_NUM
 ,p_description            IN    pa_project_sets_tl.description%TYPE            := FND_API.G_MISS_CHAR
 ,p_party_name             IN    hz_parties.party_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_attribute_category     IN    pa_project_sets_b.attribute_category%TYPE      := FND_API.G_MISS_CHAR
 ,p_attribute1             IN    pa_project_sets_b.attribute1%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute2             IN    pa_project_sets_b.attribute2%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute3             IN    pa_project_sets_b.attribute3%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute4             IN    pa_project_sets_b.attribute4%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute5             IN    pa_project_sets_b.attribute5%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute6             IN    pa_project_sets_b.attribute6%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute7             IN    pa_project_sets_b.attribute7%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute8             IN    pa_project_sets_b.attribute8%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute9             IN    pa_project_sets_b.attribute9%TYPE              := FND_API.G_MISS_CHAR
 ,p_attribute10            IN    pa_project_sets_b.attribute10%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute11            IN    pa_project_sets_b.attribute11%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute12            IN    pa_project_sets_b.attribute12%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute13            IN    pa_project_sets_b.attribute13%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute14            IN    pa_project_sets_b.attribute14%TYPE             := FND_API.G_MISS_CHAR
 ,p_attribute15            IN    pa_project_sets_b.attribute15%TYPE             := FND_API.G_MISS_CHAR
 ,p_record_version_number  IN    pa_project_sets_b.record_version_number%TYPE   := NULL
 ,p_api_version            IN    NUMBER                                         := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                       := FND_API.G_FALSE
 ,p_commit                 IN    VARCHAR2                                       := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                       := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE delete_project_set
 (p_project_set_id         IN    pa_project_sets_b.project_set_id%TYPE            := NULL
 ,p_record_version_number  IN    pa_project_sets_b.record_version_number%TYPE     := NULL
 ,p_api_version            IN    NUMBER                                           := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                         := FND_API.G_FALSE
 ,p_commit                 IN    VARCHAR2                                         := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                         := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE create_project_set_line
 (p_project_set_id           IN    pa_project_set_lines.project_set_id%TYPE
 ,p_project_id               IN    pa_project_set_lines.project_id%TYPE
 ,p_api_version              IN    NUMBER                                       := 1.0
 ,p_init_msg_list            IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_commit                   IN    VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only            IN    VARCHAR2                                     := FND_API.G_TRUE
 ,x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE delete_project_set_line
 (p_project_set_id         IN    pa_project_set_lines.project_set_id%TYPE
 ,p_project_id             IN    pa_project_set_lines.project_id%TYPE
 ,p_api_version            IN    NUMBER                                           := 1.0
 ,p_init_msg_list          IN    VARCHAR2                                         := FND_API.G_TRUE
 ,p_commit                 IN    VARCHAR2                                         := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2                                         := FND_API.G_TRUE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

procedure party_merge(
  p_entity_name            IN     varchar2
 ,p_from_id                IN     number
 ,p_to_id in               OUT    nocopy number
 ,p_from_fk_id             IN     number
 ,p_to_fk_id               IN     number
 ,p_parent_entity_name     IN     varchar2
 ,p_batch_id               IN     number
 ,p_batch_party_id         IN     number
 ,p_return_status          IN OUT nocopy varchar2
);

END;

 

/
