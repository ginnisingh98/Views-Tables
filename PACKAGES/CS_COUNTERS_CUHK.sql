--------------------------------------------------------
--  DDL for Package CS_COUNTERS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_COUNTERS_CUHK" AUTHID CURRENT_USER as
/* $Header: csxcctrs.pls 120.1 2005/06/20 11:16:42 appldev ship $*/
-- Start of Comments
-- Package name     : CS_COUNTERS_CUHK
-- Purpose          : Customer Hookup for Counters
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE CREATE_CTR_GRP_TEMPLATE_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_grp_rec                IN  CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    x_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    );

PROCEDURE CREATE_CTR_GRP_TEMPLATE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    x_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_CTR_GRP_INSTANCE_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER,
    x_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_CTR_GRP_INSTANCE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER,
    x_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_rec                    IN   CS_COUNTERS_PUB.Ctr_Rec_Type,
    x_ctr_id                     IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_rec                    IN   CS_COUNTERS_PUB.Ctr_Rec_Type,
    x_ctr_id                     IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_prop_rec               IN   CS_COUNTERS_PUB.Ctr_Prop_Rec_Type,
    x_ctr_prop_id                IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_prop_rec               IN   CS_COUNTERS_PUB.Ctr_Prop_Rec_Type,
    x_ctr_prop_id                IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_FORMULA_REF_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_counter_id                 IN   NUMBER,
    p_bind_var_name              IN   VARCHAR2,
    p_mapped_item_id             IN   NUMBER  default null,
    p_mapped_counter_id          IN   NUMBER,
    x_ctr_formula_bvar_id        IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER,
    p_reading_type               IN   VARCHAR2
    );

PROCEDURE CREATE_FORMULA_REF_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_counter_id                 IN   NUMBER,
    p_bind_var_name              IN   VARCHAR2,
    p_mapped_item_id             IN   NUMBER  default null,
    p_mapped_counter_id          IN   NUMBER,
    x_ctr_formula_bvar_id        IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER,
    p_reading_type               IN   VARCHAR2
    );

PROCEDURE CREATE_GRPOP_FILTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_seq_no                     IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_left_paren                 IN   VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_rel_op                     IN   VARCHAR2,
    p_right_val                  IN   VARCHAR2,
    p_right_paren                IN   VARCHAR2,
    p_log_op                     IN   VARCHAR2,
    x_ctr_der_filter_id          IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_GRPOP_FILTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_seq_no                     IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_left_paren                 IN   VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_rel_op                     IN   VARCHAR2,
    p_right_val                  IN   VARCHAR2,
    p_right_paren                IN   VARCHAR2,
    p_log_op                     IN   VARCHAR2,
    x_ctr_der_filter_id          IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_CTR_ASSOCIATION_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_source_object_id           IN   NUMBER,
    x_ctr_association_id         IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE CREATE_CTR_ASSOCIATION_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_source_object_id           IN   NUMBER,
    x_ctr_association_id         IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
    );

PROCEDURE AUTOINSTANTIATE_COUNTERS_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_source_object_id_template  IN   NUMBER,
    p_source_object_id_instance  IN   NUMBER,
    x_ctr_grp_id_template        IN   NUMBER,
    x_ctr_grp_id_instance        IN   NUMBER
    );

PROCEDURE AUTOINSTANTIATE_COUNTERS_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_source_object_id_template  IN   NUMBER,
    p_source_object_id_instance  IN   NUMBER,
    x_ctr_grp_id_template        IN   NUMBER,
    x_ctr_grp_id_instance        IN   NUMBER
    );

PROCEDURE INSTANTIATE_COUNTERS_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_group_id_template  IN   NUMBER,
    p_source_object_code_instance IN  VARCHAR2,
    p_source_object_id_instance   IN  NUMBER,
    x_ctr_grp_id_template        IN   NUMBER,
    x_ctr_grp_id_instance        IN   NUMBER
    );

PROCEDURE INSTANTIATE_COUNTERS_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_counter_group_id_template  IN   NUMBER,
    p_source_object_code_instance IN  VARCHAR2,
    p_source_object_id_instance   IN  NUMBER,
    x_ctr_grp_id_template        IN   NUMBER,
    x_ctr_grp_id_instance        IN   NUMBER
    );

PROCEDURE UPDATE_CTR_GRP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE UPDATE_CTR_GRP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE UPDATE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_rec                    IN   CS_COUNTERS_PUB.Ctr_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE UPDATE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_rec                    IN   CS_COUNTERS_PUB.Ctr_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE UPDATE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_prop_rec               IN   CS_COUNTERS_PUB.Ctr_Prop_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE UPDATE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_prop_rec               IN   CS_COUNTERS_PUB.Ctr_Prop_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE UPDATE_FORMULA_REF_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_formula_bvar_id        IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_bind_var_name              IN   VARCHAR2,
    p_mapped_item_id             IN   NUMBER,
    p_mapped_counter_id          IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER,
    p_reading_type               IN   VARCHAR2
    );

PROCEDURE UPDATE_FORMULA_REF_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_formula_bvar_id        IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_bind_var_name              IN   VARCHAR2,
    p_mapped_item_id             IN   NUMBER,
    p_mapped_counter_id          IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER,
    p_reading_type               IN   VARCHAR2
    );

PROCEDURE UPDATE_GRPOP_FILTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_der_filter_id          IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_seq_no                     IN   NUMBER  DEFAULT null,
    p_counter_id                 IN   NUMBER,
    p_left_paren                 IN   VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_rel_op                     IN   VARCHAR2,
    p_right_val                  IN   VARCHAR2,
    p_right_paren                IN   VARCHAR2,
    p_log_op                     IN   VARCHAR2,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE UPDATE_GRPOP_FILTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_der_filter_id          IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_seq_no                     IN   NUMBER  DEFAULT null,
    p_counter_id                 IN   NUMBER,
    p_left_paren                 IN   VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_rel_op                     IN   VARCHAR2,
    p_right_val                  IN   VARCHAR2,
    p_right_paren                IN   VARCHAR2,
    p_log_op                     IN   VARCHAR2,
    p_cascade_upd_to_instances   IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE UPDATE_CTR_ASSOCIATION_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_association_id         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_grp_id                 IN   NUMBER,
    p_source_object_id           IN   NUMBER,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE UPDATE_CTR_ASSOCIATION_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_association_id         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_grp_id                 IN   NUMBER,
    p_source_object_id           IN   NUMBER,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE DELETE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_id			 IN   NUMBER
    );

PROCEDURE DELETE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_id                     IN   NUMBER
    );

PROCEDURE DELETE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_prop_id		 IN   NUMBER
    );
PROCEDURE DELETE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_prop_id                IN   NUMBER
    );

PROCEDURE DELETE_FORMULA_REF_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_formula_bvar_id        IN   NUMBER
    );

PROCEDURE DELETE_FORMULA_REF_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_formula_bvar_id        IN   NUMBER
    );

PROCEDURE DELETE_GRPOP_FILTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_der_filter_id          IN   NUMBER
    );

PROCEDURE DELETE_GRPOP_FILTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_der_filter_id          IN   NUMBER
    );

PROCEDURE DELETE_CTR_ASSOCIATION_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_association_id	 IN   NUMBER
    );
PROCEDURE DELETE_CTR_ASSOCIATION_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_ctr_association_id         IN   NUMBER
    );

PROCEDURE DELETE_COUNTER_INSTANCE_PRE (
    p_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_SOURCE_OBJECT_ID           IN   NUMBER,
    p_SOURCE_OBJECT_CODE         IN   VARCHAR2,
    x_Return_status              OUT NOCOPY  VARCHAR2,
    x_Msg_Count                  OUT NOCOPY  NUMBER,
    x_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE DELETE_COUNTER_INSTANCE_POST (
    p_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_SOURCE_OBJECT_ID           IN   NUMBER,
    p_SOURCE_OBJECT_CODE         IN   VARCHAR2,
    x_Return_status              OUT NOCOPY  VARCHAR2,
    x_Msg_Count                  OUT NOCOPY  NUMBER,
    x_Msg_Data                   OUT NOCOPY  VARCHAR2
    );
End CS_COUNTERS_CUHK;

 

/
