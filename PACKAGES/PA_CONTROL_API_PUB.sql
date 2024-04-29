--------------------------------------------------------
--  DDL for Package PA_CONTROL_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CONTROL_API_PUB" AUTHID DEFINER as
/*$Header: PACIAMPS.pls 120.0 2006/11/24 08:34:51 vgottimu noship $*/


G_PA_MISS_NUM   CONSTANT   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
G_PA_MISS_DATE  CONSTANT   DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
G_PA_MISS_CHAR  CONSTANT   VARCHAR2(3) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;



type ci_action_in_rec_type is record(
                             action_type_code           pa_ci_actions.type_code%type     := 'REVIEW',
                             assignee_id                number,
                             date_required              pa_ci_actions.date_required%type,
                             request_text               pa_ci_comments.comment_text%type,
                             sign_off_requested_flag    pa_ci_actions.sign_off_required_flag%type := 'N',
                             action_status              pa_ci_actions.status_code%type,
                             signed_off                 pa_ci_actions.sign_off_flag%type := 'N',
                             source_ci_action_id        number,
                             start_wf                   VARCHAR2(1) := 'N',
                             closed_date                pa_ci_actions.date_closed%type
                                    );

type ci_action_out_rec_type is record(
                                      action_id           pa_ci_actions.ci_action_id%type,
                                      action_number       pa_ci_actions.ci_action_number%type
                                     );

type ci_actions_in_tbl_type  is table of ci_action_in_rec_type
index by binary_integer;

type ci_actions_out_tbl_type  is table of ci_action_out_rec_type
index by binary_integer;

--Record and table type definitions
TYPE supp_det_rec_type IS RECORD
                (
                change_type          pa_ci_supplier_details.change_type%type := G_PA_MISS_CHAR,
                change_description   pa_ci_supplier_details.change_description%type  := G_PA_MISS_CHAR,
                vendor_id	     NUMBER		:= G_PA_MISS_NUM,
                po_header_id	     NUMBER		:= G_PA_MISS_NUM,
                po_number	     varchar2(40)	:= G_PA_MISS_CHAR,
                po_line_id	     number		:= G_PA_MISS_NUM,
                po_line_num	     number		:= G_PA_MISS_NUM,
                currency	     pa_ci_supplier_details.CURRENCY_CODE%type:= G_PA_MISS_CHAR,
                change_amount	     number		:= G_PA_MISS_NUM
                );


TYPE SUPP_DET_TBL_TYPE IS TABLE OF supp_det_rec_type
      INDEX BY BINARY_INTEGER;


TYPE REL_ITEM_IN_TABLE_TYPE IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

TYPE CI_COMMENTS_TBL_TYPE IS TABLE OF PA_CI_COMMENTS.COMMENT_TEXT%TYPE INDEX BY BINARY_INTEGER;

/* Procedure to the add the Workplan impacts*/
Procedure Add_Workplan_Impact (
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        x_impact_id            OUT NOCOPY  NUMBER
        );

/* Procedure to the add the Staffing impacts*/
Procedure Add_Staffing_Impact(
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        x_impact_id            OUT NOCOPY  NUMBER
        );

/* Procedure to the add the Contract impacts*/
Procedure Add_Contract_Impact(
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        x_impact_id            OUT NOCOPY  NUMBER
        );

/* Procedure to the add the Other impacts*/
Procedure Add_Other_Impact(
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        x_impact_id            OUT NOCOPY  NUMBER
        );

/* Procedure to the add the Supplier impacts*/
/* Parameter is included to pass the table with supplier details*/

Procedure Add_Supplier_Impact (
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        p_supplier_det_tbl     IN          SUPP_DET_TBL_TYPE,    --Table with supplier details
        x_impact_id            OUT NOCOPY  NUMBER
        );


/*Procedure to update the impact and to implement the workplan impact*/
Procedure  Update_Workplan_Impact (
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        );

/*Procedure to update the impact and to implement the Staffing impact*/
Procedure   Update_Staffing_Impact(
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        );

/*Procedure to update the impact and to implement the Contract impact*/
Procedure Update_Contract_Impact(
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        );

/*Procedure to update the impact and to implement the Staffing impact*/
Procedure   Update_Other_Impact(
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        );

/*Procedure to update the impact and to implement the Supplier impact*/
Procedure  Update_Supplier_Impact (
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        );


/*Procudure to delete the supplier details*/
Procedure Delete_Supplier_Impact_Details
		(
		P_COMMIT              IN      VARCHAR2  := FND_API.G_FALSE,
		P_INIT_MSG_LIST       IN      VARCHAR2  := FND_API.G_FALSE,
		P_API_VERSION_NUMBER  IN      NUMBER,
		X_RETURN_STATUS	      OUT  NOCOPY  VARCHAR2,
		X_MSG_COUNT	      OUT  NOCOPY  NUMBER,
		X_MSG_DATA 	      OUT  NOCOPY  VARCHAR2,
		P_CI_TRANSACTION_ID   IN      NUMBER);



/*Procedure to update the Progress details and resolution details in pa_control_item*/
Procedure Update_Progress(
                        p_commit                 IN    VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number     IN    NUMBER,
                        x_return_status          OUT NOCOPY  VARCHAR2,
                        x_msg_count              OUT NOCOPY  NUMBER,
                        x_msg_data               OUT NOCOPY  VARCHAR2,
                        p_ci_id                  IN    NUMBER   := G_PA_MISS_NUM,
                        p_ci_status_code         IN    VARCHAR2 := G_PA_MISS_CHAR,
  		        p_status_comment         IN    VARCHAR2 := G_PA_MISS_CHAR,
                        p_as_of_date             IN    DATE     := G_PA_MISS_DATE,
                        p_progress_status_code   IN    VARCHAR2 := G_PA_MISS_CHAR,
                        p_progress_overview      IN    VARCHAR2 := G_PA_MISS_CHAR,
                        p_resolution_code        IN    VARCHAR2 := G_PA_MISS_CHAR,
                        p_resolution_comment     IN    VARCHAR2 := G_PA_MISS_CHAR
                        );



PROCEDURE CREATE_ISSUE
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
x_ci_id                                         OUT NOCOPY NUMBER,
x_ci_number                                     OUT NOCOPY NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          IN DATE     := G_PA_MISS_DATE,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute_category                            IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   IN VARCHAR2 := G_PA_MISS_CHAR
);

PROCEDURE CREATE_CHANGE_REQUEST
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
x_ci_id                                         OUT NOCOPY NUMBER,
x_ci_number                                     OUT NOCOPY NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          IN DATE     := G_PA_MISS_DATE,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute_category                            IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   IN VARCHAR2 := G_PA_MISS_CHAR
);

PROCEDURE CREATE_CHANGE_ORDER
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
x_ci_id                                         OUT NOCOPY NUMBER,
x_ci_number                                     OUT NOCOPY NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          IN DATE     := G_PA_MISS_DATE,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute_category                            IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   IN VARCHAR2 := G_PA_MISS_CHAR
);



PROCEDURE CREATE_ACTION
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
p_ci_id                                         IN NUMBER := G_PA_MISS_NUM,
p_action_tbl                                    IN ci_actions_in_tbl_type,
x_action_tbl                                    OUT NOCOPY ci_actions_out_tbl_type
);

PROCEDURE TAKE_ACTION
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
p_ci_id                                         IN NUMBER := G_PA_MISS_NUM,
p_action_id                                     IN NUMBER := G_PA_MISS_NUM,
p_action_number                                 IN NUMBER := G_PA_MISS_NUM,
p_close_action_flag                             IN VARCHAR2 := 'N',
p_response_text                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_sign_off_flag                                 IN VARCHAR2 := 'N',
p_reassign_action_flag                          IN VARCHAR2 := 'N',
p_reassign_to_id                                IN NUMBER := G_PA_MISS_NUM,
p_reassign_request_text                         IN VARCHAR2 := G_PA_MISS_CHAR,
p_required_by_date                              IN DATE := G_PA_MISS_DATE
);


/*Procedure to cancel the action*/
Procedure Cancel_Action(
                        p_commit              IN    VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number  IN    NUMBER,
                        x_return_status       OUT NOCOPY  VARCHAR2,
                        x_msg_count           OUT NOCOPY  NUMBER,
                        x_msg_data            OUT NOCOPY  VARCHAR2,
                        p_ci_id               IN    NUMBER := G_PA_MISS_NUM,
                        p_action_id           IN    NUMBER := G_PA_MISS_NUM,
                        p_action_number       IN    NUMBER := G_PA_MISS_NUM,
                        p_cancel_comment      IN    VARCHAR2 := G_PA_MISS_CHAR
                        );


Procedure Delete_Issue (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        );


Procedure Delete_Change_Request (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        );
Procedure Delete_Change_Order (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        );

Procedure Add_Comments (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , p_Comments_Tbl        IN CI_COMMENTS_TBL_TYPE
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        );
Procedure Add_Related_Items (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , p_Related_Items_Tbl   IN REL_ITEM_IN_TABLE_TYPE
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        );
Procedure Delete_Related_Item (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , p_To_Ci_Id            IN NUMBER
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        );

PROCEDURE UPDATE_ISSUE (
                        p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number    IN      NUMBER,
                        x_return_status         OUT NOCOPY    VARCHAR2,
                        x_msg_count             OUT NOCOPY    NUMBER,
                        x_msg_data              OUT NOCOPY    VARCHAR2,
                        p_ci_id                 IN      NUMBER,
                        P_RECORD_VERSION_NUMBER IN      NUMBER   := G_PA_MISS_NUM,
                        P_SUMMARY               IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DESCRIPTION           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_OWNER_ID              IN      NUMBER   := G_PA_MISS_NUM,
                        P_OWNER_COMMENT         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CLASSIFICATION_CODE   IN      NUMBER   := G_PA_MISS_NUM,
                        P_REASON_CODE           IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_ID             IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_TYPE           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_NUMBER             IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DATE_REQUIRED         IN      DATE     := G_PA_MISS_DATE,
                        P_PRIORITY_CODE         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_EFFORT_LEVEL_CODE     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PRICE                 IN      NUMBER   := G_PA_MISS_NUM,
                        P_PRICE_CURRENCY_CODE   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_TYPE_CODE      IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_NUMBER         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_DATE_RECEIVED  IN      DATE     := G_PA_MISS_DATE,
                        P_SOURCE_ORGANIZATION   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_PERSON         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_STATUS_CODE        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_STATUS_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_AS_OF_DATE   IN      DATE     := G_PA_MISS_DATE,
                        P_PROGRESS_STATUS_CODE  IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_OVERVIEW     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_CODE       IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_COMMENT    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE_CATEGORY    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE1            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE2            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE3            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE4            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE5            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE6            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE7            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE8            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE9            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE10           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE11           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE12           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE13           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE14           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE15           IN      VARCHAR2 := G_PA_MISS_CHAR
                        );

PROCEDURE UPDATE_CHANGE_REQUEST (
                        p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number    IN      NUMBER,
                        x_return_status         OUT  NOCOPY   VARCHAR2,
                        x_msg_count             OUT  NOCOPY   NUMBER,
                        x_msg_data              OUT  NOCOPY   VARCHAR2,
                        p_ci_id                 IN      NUMBER,
                        P_RECORD_VERSION_NUMBER IN      NUMBER   := G_PA_MISS_NUM,
                        P_SUMMARY               IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DESCRIPTION           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_OWNER_ID              IN      NUMBER   := G_PA_MISS_NUM,
                        P_OWNER_COMMENT         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CLASSIFICATION_CODE   IN      NUMBER   := G_PA_MISS_NUM,
                        P_REASON_CODE           IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_ID             IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_TYPE           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_NUMBER             IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DATE_REQUIRED         IN      DATE     := G_PA_MISS_DATE,
                        P_PRIORITY_CODE         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_EFFORT_LEVEL_CODE     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PRICE                 IN      NUMBER   := G_PA_MISS_NUM,
                        P_PRICE_CURRENCY_CODE   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_TYPE_CODE      IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_NUMBER         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_DATE_RECEIVED  IN      DATE     := G_PA_MISS_DATE,
                        P_SOURCE_ORGANIZATION   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_PERSON         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_STATUS_CODE        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_STATUS_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_AS_OF_DATE   IN      DATE     := G_PA_MISS_DATE,
                        P_PROGRESS_STATUS_CODE  IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_OVERVIEW     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_CODE       IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_COMMENT    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE_CATEGORY    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE1            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE2            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE3            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE4            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE5            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE6            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE7            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE8            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE9            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE10           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE11           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE12           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE13           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE14           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE15           IN      VARCHAR2 := G_PA_MISS_CHAR
                        );

PROCEDURE UPDATE_CHANGE_ORDER (
                        p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number    IN      NUMBER,
                        x_return_status         OUT  NOCOPY   VARCHAR2,
                        x_msg_count             OUT  NOCOPY   NUMBER,
                        x_msg_data              OUT  NOCOPY   VARCHAR2,
                        p_ci_id                 IN      NUMBER,
                        P_RECORD_VERSION_NUMBER IN      NUMBER   := G_PA_MISS_NUM,
                        P_SUMMARY               IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DESCRIPTION           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_OWNER_ID              IN      NUMBER   := G_PA_MISS_NUM,
                        P_OWNER_COMMENT         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CLASSIFICATION_CODE   IN      NUMBER   := G_PA_MISS_NUM,
                        P_REASON_CODE           IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_ID             IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_TYPE           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_NUMBER             IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DATE_REQUIRED         IN      DATE     := G_PA_MISS_DATE,
                        P_PRIORITY_CODE         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_EFFORT_LEVEL_CODE     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PRICE                 IN      NUMBER   := G_PA_MISS_NUM,
                        P_PRICE_CURRENCY_CODE   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_TYPE_CODE      IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_NUMBER         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_DATE_RECEIVED  IN      DATE     := G_PA_MISS_DATE,
                        P_SOURCE_ORGANIZATION   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_PERSON         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_STATUS_CODE        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_STATUS_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_AS_OF_DATE   IN      DATE     := G_PA_MISS_DATE,
                        P_PROGRESS_STATUS_CODE  IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_OVERVIEW     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_CODE       IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_COMMENT    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE_CATEGORY    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE1            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE2            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE3            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE4            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE5            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE6            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE7            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE8            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE9            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE10           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE11           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE12           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE13           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE14           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE15           IN      VARCHAR2 := G_PA_MISS_CHAR
                        );

END PA_CONTROL_API_PUB;

/
