--------------------------------------------------------
--  DDL for Package ASO_APR_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_APR_PUB_W" AUTHID CURRENT_USER as
/* $Header: asowaprs.pls 120.0 2005/06/01 17:59:08 appldev noship $ */

PROCEDURE Set_Approvers_List_Tbl_Out(
   p_qte_approvers_list_tbl  IN  ASO_Apr_Pub.Approvers_List_Tbl_Type,
   x_approval_det_id         OUT NOCOPY  jtf_number_table,
   x_object_approval_id      OUT NOCOPY  jtf_number_table,
   x_approver_person_id      OUT NOCOPY  jtf_number_table,
   x_approver_user_id        OUT NOCOPY  jtf_number_table,
   x_notification_id         OUT NOCOPY  jtf_number_table,
   x_approver_sequence       OUT NOCOPY  jtf_number_table,
   x_approver_status         OUT NOCOPY  jtf_varchar2_table_100,
   x_approver_name           OUT NOCOPY  jtf_varchar2_table_100,
   x_approval_comments       OUT NOCOPY  jtf_varchar2_table_300,
   x_date_sent               OUT NOCOPY  jtf_date_table,
   x_date_received           OUT NOCOPY  jtf_date_table
);

PROCEDURE Set_Rules_List_Tbl_Out(
   p_qte_rules_list_tbl    IN  ASO_Apr_Pub.Rules_List_Tbl_Type,
   x_rule_id               OUT NOCOPY  jtf_number_table,
   x_object_approval_id    OUT NOCOPY  jtf_number_table,
   x_rule_action_id        OUT NOCOPY  jtf_number_table,
   x_rule_description      OUT NOCOPY  jtf_varchar2_table_300,
   x_approval_level        OUT NOCOPY  jtf_varchar2_table_300
);

PROCEDURE Get_All_Approvers(
   x_qa_approval_det_id         OUT NOCOPY jtf_number_table        ,
   x_qa_object_approval_id      OUT NOCOPY jtf_number_table        ,
   x_qa_approver_person_id      OUT NOCOPY jtf_number_table        ,
   x_qa_approver_user_id        OUT NOCOPY jtf_number_table        ,
   x_qa_notification_id         OUT NOCOPY jtf_number_table        ,
   x_qa_approver_sequence       OUT NOCOPY jtf_number_table        ,
   x_qa_approver_status         OUT NOCOPY jtf_varchar2_table_100  ,
   x_qa_approver_name           OUT NOCOPY jtf_varchar2_table_100  ,
   x_qa_approval_comments       OUT NOCOPY jtf_varchar2_table_300  ,
   x_qa_date_sent               OUT NOCOPY jtf_date_table          ,
   x_qa_date_received           OUT NOCOPY jtf_date_table          ,
   x_qr_rule_id                 OUT NOCOPY jtf_number_table        ,
   x_qr_object_approval_id      OUT NOCOPY jtf_number_table        ,
   x_qr_rule_action_id          OUT NOCOPY jtf_number_table        ,
   x_qr_rule_description        OUT NOCOPY jtf_varchar2_table_300  ,
   x_qr_approval_level          OUT NOCOPY jtf_varchar2_table_300  ,
   p_object_id                  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_object_type                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_application_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_api_version_number         IN  NUMBER   := 1                  ,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status              OUT NOCOPY VARCHAR2                ,
   x_msg_count                  OUT NOCOPY NUMBER                  ,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Rule_Details(
   x_qr_rule_id                 OUT NOCOPY jtf_number_table        ,
   x_qr_object_approval_id      OUT NOCOPY jtf_number_table        ,
   x_qr_rule_action_id          OUT NOCOPY jtf_number_table        ,
   x_qr_rule_description        OUT NOCOPY jtf_varchar2_table_300  ,
   x_qr_approval_level          OUT NOCOPY jtf_varchar2_table_300  ,
   p_object_approval_id         IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_api_version_number         IN  NUMBER   := 1                  ,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status              OUT NOCOPY VARCHAR2                ,
   x_msg_count                  OUT NOCOPY NUMBER                  ,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

END ASO_APR_PUB_W;

 

/
