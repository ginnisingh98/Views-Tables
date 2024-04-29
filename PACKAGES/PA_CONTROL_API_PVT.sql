--------------------------------------------------------
--  DDL for Package PA_CONTROL_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CONTROL_API_PVT" AUTHID DEFINER as
/*$Header: PACIAMVS.pls 120.0 2006/11/24 08:24:46 vgottimu noship $*/

G_PA_MISS_NUM   CONSTANT   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
G_PA_MISS_DATE  CONSTANT   DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
G_PA_MISS_CHAR  CONSTANT   VARCHAR2(3) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;



/*The update_impacts procedure will be called from Add_<impact_type>_impact and
update_<impact_type>_impact to create the impact, to update the details of impact and also
to implement the impact.*/
Procedure update_impacts (
        p_ci_id                        IN NUMBER    := G_PA_MISS_NUM,
        x_ci_impact_id                 OUT NOCOPY NUMBER,
        p_impact_type_code             IN VARCHAR2  := G_PA_MISS_CHAR,
        p_impact_description           IN VARCHAR2  := G_PA_MISS_CHAR,
        p_mode                         IN VARCHAR2,
        p_commit                       IN VARCHAR2  := FND_API.G_FALSE,
        p_init_msg_list                IN VARCHAR2  := FND_API.G_FALSE,
        p_api_version_number           IN NUMBER ,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2
        );



/*This Procedure will be called from add_supplier_impact procedure
to insert the details of the supplier*/
Procedure add_supplier_details (
         p_ci_id                IN         NUMBER   := G_PA_MISS_NUM,
         p_ci_impact_id         IN         NUMBER ,
         p_supplier_det_tbl     IN  PA_CONTROL_API_PUB.SUPP_DET_TBL_TYPE,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        );


PROCEDURE check_create_ci_allowed
(
p_project_id                                    IN OUT NOCOPY NUMBER,
p_project_name                                  IN VARCHAR2 := null,
p_project_number                                IN VARCHAR2 := null,
p_ci_type_class_code                            IN VARCHAR2 := null,
p_ci_type_id                                    IN OUT NOCOPY NUMBER,
x_ci_type_class_code                            OUT NOCOPY VARCHAR2,
x_auto_number_flag                              OUT NOCOPY VARCHAR2,
x_source_attrs_enabled_flag                     OUT NOCOPY VARCHAR2,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2
);

PROCEDURE validate_param_and_create(
                                    p_orig_system_code              IN VARCHAR2
                                   ,p_orig_system_reference         IN VARCHAR2
                                   ,p_project_id                    IN NUMBER := null
                                   ,p_ci_type_id                    IN NUMBER := null
                                   ,p_auto_number_flag              IN VARCHAR2 := null
                                   ,p_source_attrs_enabled_flag     IN VARCHAR2 := null
                                   ,p_ci_type_class_code            IN VARCHAR2 := null
                                   ,p_summary                       IN VARCHAR2
                                   ,p_ci_number                     IN VARCHAR2 := null
                                   ,p_description                   IN VARCHAR2 := null
                                   ,p_status_code                   IN VARCHAR2 := null
                                   ,p_status                        IN VARCHAR2 := null
                                   ,p_owner_id                      IN NUMBER := null
                                   ,p_highlighted_flag              IN  VARCHAR2 := 'N'
                                   ,p_progress_status_code          IN VARCHAR2 := null
                                   ,p_progress_as_of_date           IN DATE := null
                                   ,p_status_overview               IN VARCHAR2 := null
                                   ,p_classification_code           IN NUMBER
                                   ,p_reason_code                   IN NUMBER
                                   ,p_object_id                     IN NUMBER := null
                                   ,p_object_type                   IN VARCHAR2 := null
                                   ,p_date_required                 IN DATE := null
                                   ,p_date_closed                   IN DATE := null
                                   ,p_closed_by_id                  IN NUMBER := null
                                   ,p_resolution                    IN VARCHAR2 := null
                                   ,p_resolution_code               IN NUMBER := null
                                   ,p_priority_code                 IN VARCHAR2 := null
                                   ,p_effort_level_code             IN VARCHAR2 := null
                                   ,p_price                         IN NUMBER := null
                                   ,p_price_currency_code           IN VARCHAR2 := null
                                   ,p_source_type_name              IN VARCHAR2 := null
                                   ,p_source_type_code              IN VARCHAR2 := null
                                   ,p_source_number                 IN VARCHAR2 := null
                                   ,p_source_comment                IN VARCHAR2 := null
                                   ,p_source_date_received          IN DATE := null
                                   ,p_source_organization           IN VARCHAR2 := null
                                   ,p_source_person                 IN VARCHAR2 := null
                                   ,p_attribute_category            IN VARCHAR2 := null
                                   ,p_attribute1                    IN VARCHAR2 := null
                                   ,p_attribute2                    IN VARCHAR2 := null
                                   ,p_attribute3                    IN VARCHAR2 := null
                                   ,p_attribute4                    IN VARCHAR2 := null
                                   ,p_attribute5                    IN VARCHAR2 := null
                                   ,p_attribute6                    IN VARCHAR2 := null
                                   ,p_attribute7                    IN VARCHAR2 := null
                                   ,p_attribute8                    IN VARCHAR2 := null
                                   ,p_attribute9                    IN VARCHAR2 := null
                                   ,p_attribute10                   IN VARCHAR2 := null
                                   ,p_attribute11                   IN VARCHAR2 := null
                                   ,p_attribute12                   IN VARCHAR2 := null
                                   ,p_attribute13                   IN VARCHAR2 := null
                                   ,p_attribute14                   IN VARCHAR2 := null
                                   ,p_attribute15                   IN VARCHAR2 := null
                                   ,x_ci_id                         OUT NOCOPY NUMBER
                                   ,x_ci_number                     OUT NOCOPY NUMBER
                                   ,x_return_status                 OUT NOCOPY VARCHAR2
                                   ,x_msg_count                     OUT NOCOPY NUMBER
                                   ,x_msg_data                      OUT NOCOPY VARCHAR2
                                   );

procedure check_create_action_allow(
                                    p_ci_id                  IN NUMBER := null,
                                    x_project_id             OUT NOCOPY NUMBER,
                                    x_return_status          OUT NOCOPY VARCHAR2,
                                    x_msg_count              OUT NOCOPY NUMBER,
                                    x_msg_data               OUT NOCOPY VARCHAR2);

procedure validate_assignee_id(
                                p_assignee_id           IN NUMBER
                               ,p_project_id            IN NUMBER
                               ,p_msg_token_num         IN NUMBER DEFAULT NULL
                               ,x_assignee_id           OUT NOCOPY NUMBER
                               ,x_return_status         OUT NOCOPY VARCHAR2
                               ,x_msg_count             OUT NOCOPY NUMBER
                               ,x_msg_data              OUT NOCOPY VARCHAR2
                              );

procedure validate_action_attributes(
                                     p_ci_id                 IN NUMBER
                                    ,p_project_id            IN NUMBER
                                    ,p_action_tbl            IN  pa_control_api_pub.ci_actions_in_tbl_type
                                    ,x_action_tbl            OUT NOCOPY pa_control_api_pub.ci_actions_in_tbl_type
                                    ,x_return_status         OUT NOCOPY VARCHAR2
                                    ,x_msg_count             OUT NOCOPY NUMBER
                                    ,x_msg_data              OUT NOCOPY VARCHAR2
                                    );

procedure create_action(
                        p_action_tbl              IN  pa_control_api_pub.ci_actions_in_tbl_type
                       ,p_ci_id                   IN NUMBER := null
                       ,x_action_tbl              OUT NOCOPY pa_control_api_pub.ci_actions_out_tbl_type
                       ,x_return_status           OUT NOCOPY VARCHAR2
                       ,x_msg_count               OUT NOCOPY NUMBER
                       ,x_msg_data                OUT NOCOPY VARCHAR2
                       );

procedure validate_priv_and_action(
                                    p_ci_id                   IN NUMBER
                                   ,p_action_id               IN NUMBER
                                   ,p_action_number           IN NUMBER
                                   ,x_action_id               OUT NOCOPY NUMBER
                                   ,x_assignee_id             OUT NOCOPY NUMBER
                                   ,x_project_id              OUT NOCOPY NUMBER
                                   ,x_return_status           OUT NOCOPY VARCHAR2
                                   ,x_msg_count               OUT NOCOPY NUMBER
                                   ,x_msg_data                OUT NOCOPY VARCHAR2
                                   );


Procedure Delete_CI     (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        );


END PA_CONTROL_API_PVT;

/
