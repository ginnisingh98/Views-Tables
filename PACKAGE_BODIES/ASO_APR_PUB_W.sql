--------------------------------------------------------
--  DDL for Package Body ASO_APR_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_APR_PUB_W" as
/* $Header: asowaprb.pls 120.1 2005/10/12 14:43:36 skulkarn noship $ */
-- Start of Comments
-- Package name     :  ASO_APR_PUB_W
-- Purpose          : Rosetta wrappers for ASO Approval APIs
-- History          : Created on 12/02/01
-- NOTE             :
-- END of Comments
ROSETTA_G_MISTAKE_DATE DATE   := TO_DATE('01/01/+4713', 'MM/DD/SYYYY');
ROSETTA_G_MISS_NUM     NUMBER := 0-1962.0724;

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'ASO_APR_PUB_W';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asowaprb.pls';

FUNCTION rosetta_g_miss_num_map(n number) RETURN number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
BEGIN
    IF n=a THEN RETURN b; END IF;
    IF n=b THEN RETURN a; END IF;
    RETURN n;
END;

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
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_approval_det_id := jtf_number_table();
   x_object_approval_id := jtf_number_table();
   x_approver_person_id := jtf_number_table();
   x_approver_user_id := jtf_number_table();
   x_notification_id := jtf_number_table();
   x_approver_sequence := jtf_number_table();
   x_approver_status := jtf_varchar2_table_100();
   x_approver_name := jtf_varchar2_table_100();
   x_approval_comments := jtf_varchar2_table_300();
   x_date_sent := jtf_date_table();
   x_date_received := jtf_date_table();
   IF p_qte_approvers_list_tbl.count > 0 THEN
     x_approval_det_id.extend(p_qte_approvers_list_tbl.count);
     x_object_approval_id.extend(p_qte_approvers_list_tbl.count);
     x_approver_person_id.extend(p_qte_approvers_list_tbl.count);
     x_approver_user_id.extend(p_qte_approvers_list_tbl.count);
     x_notification_id.extend(p_qte_approvers_list_tbl.count);
     x_approver_sequence.extend(p_qte_approvers_list_tbl.count);
     x_approver_status.extend(p_qte_approvers_list_tbl.count);
     x_approver_name.extend(p_qte_approvers_list_tbl.count);
     x_approval_comments.extend(p_qte_approvers_list_tbl.count);
     x_date_sent.extend(p_qte_approvers_list_tbl.count);
     x_date_received.extend(p_qte_approvers_list_tbl.count);
     ddindx := p_qte_approvers_list_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_approval_det_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).approval_det_id);
       x_object_approval_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).object_approval_id);
       x_approver_person_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).approver_person_id);
       x_approver_user_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).approver_user_id);
       x_notification_id(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).notification_id);
       x_approver_sequence(indx) := rosetta_g_miss_num_map(p_qte_approvers_list_tbl(ddindx).approver_sequence);
       x_approver_status(indx) := p_qte_approvers_list_tbl(ddindx).approver_status;
       x_approver_name(indx) := p_qte_approvers_list_tbl(ddindx).approver_name;
       x_approval_comments(indx) := p_qte_approvers_list_tbl(ddindx).approval_comments;
       x_date_sent(indx) := p_qte_approvers_list_tbl(ddindx).date_sent;
       x_date_received(indx) := p_qte_approvers_list_tbl(ddindx).date_recieved;
       indx := indx+1;
       IF p_qte_approvers_list_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_approvers_list_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Approvers_List_Tbl_Out;



PROCEDURE Set_Rules_List_Tbl_Out(
   p_qte_rules_list_tbl    IN  ASO_Apr_Pub.Rules_List_Tbl_Type,
   x_rule_id               OUT NOCOPY  jtf_number_table,
   x_object_approval_id    OUT NOCOPY  jtf_number_table,
   x_rule_action_id        OUT NOCOPY  jtf_number_table,
   x_rule_description      OUT NOCOPY  jtf_varchar2_table_300,
   x_approval_level        OUT NOCOPY  jtf_varchar2_table_300
)
AS
   ddindx binary_integer; indx binary_integer;
BEGIN
   x_rule_id := jtf_number_table();
   x_object_approval_id := jtf_number_table();
   x_rule_action_id := jtf_number_table();
   x_rule_description := jtf_varchar2_table_300();
   x_approval_level := jtf_varchar2_table_300();
   IF p_qte_rules_list_tbl.count > 0 THEN
     x_rule_id.extend(p_qte_rules_list_tbl.count);
     x_object_approval_id.extend(p_qte_rules_list_tbl.count);
     x_rule_action_id.extend(p_qte_rules_list_tbl.count);
     x_rule_description.extend(p_qte_rules_list_tbl.count);
     x_approval_level.extend(p_qte_rules_list_tbl.count);
     ddindx := p_qte_rules_list_tbl.first;
     indx := 1;
     WHILE true LOOP
       x_rule_id(indx) := rosetta_g_miss_num_map(p_qte_rules_list_tbl(ddindx).rule_id);
       x_object_approval_id(indx) := rosetta_g_miss_num_map(p_qte_rules_list_tbl(ddindx).object_approval_id);
       x_rule_action_id(indx) := rosetta_g_miss_num_map(p_qte_rules_list_tbl(ddindx).rule_action_id);
       x_rule_description(indx) := p_qte_rules_list_tbl(ddindx).rule_description;
       x_approval_level(indx) := p_qte_rules_list_tbl(ddindx).approval_level;
       indx := indx+1;
       IF p_qte_rules_list_tbl.last =ddindx
         THEN EXIT;
       END IF;
       ddindx := p_qte_rules_list_tbl.next(ddindx);
     END LOOP;
   END IF;
END Set_Rules_List_Tbl_Out;


PROCEDURE Get_All_Approvers(
   x_qa_approval_det_id         OUT NOCOPY jtf_number_table               ,
   x_qa_object_approval_id      OUT NOCOPY jtf_number_table               ,
   x_qa_approver_person_id      OUT NOCOPY jtf_number_table               ,
   x_qa_approver_user_id        OUT NOCOPY jtf_number_table               ,
   x_qa_notification_id         OUT NOCOPY jtf_number_table               ,
   x_qa_approver_sequence       OUT NOCOPY jtf_number_table               ,
   x_qa_approver_status         OUT NOCOPY jtf_varchar2_table_100         ,
   x_qa_approver_name           OUT NOCOPY jtf_varchar2_table_100         ,
   x_qa_approval_comments       OUT NOCOPY jtf_varchar2_table_300         ,
   x_qa_date_sent               OUT NOCOPY jtf_date_table                 ,
   x_qa_date_received           OUT NOCOPY jtf_date_table                 ,
   x_qr_rule_id                 OUT NOCOPY jtf_number_table               ,
   x_qr_object_approval_id      OUT NOCOPY jtf_number_table               ,
   x_qr_rule_action_id          OUT NOCOPY jtf_number_table               ,
   x_qr_rule_description        OUT NOCOPY jtf_varchar2_table_300         ,
   x_qr_approval_level          OUT NOCOPY jtf_varchar2_table_300         ,
   p_object_id                  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_object_type                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_application_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_api_version_number         IN  NUMBER   := 1                  ,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status              OUT NOCOPY VARCHAR2                       ,
   x_msg_count                  OUT NOCOPY NUMBER                         ,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
AS
  lx_approvers_list_tbl     ASO_Apr_Pub.Approvers_List_Tbl_Type;
  lx_rules_list_tbl         ASO_Apr_Pub.Rules_List_Tbl_Type;

  l_debug                   VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(10000);

BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin calling ASO_Apr_Pub.Get_All_Approvers',
        1,
        'N'
      );
    END IF;

   ASO_Apr_Pub.Get_All_Approvers(
      p_api_version_number  => p_api_version_number,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
      p_object_id           => p_object_id,
      p_object_type         => p_object_type,
      p_application_id      => p_application_id,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_approvers_list      => lx_approvers_list_tbl,
      x_rules_list          => lx_rules_list_tbl);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Returning from ASO_Apr_Pub.Get_All_Approvers',
        1,
        'N'
      );
    END IF;

   ASO_APR_PUB_W.Set_Approvers_List_Tbl_Out(
      p_qte_approvers_list_tbl  => lx_approvers_list_tbl,
      x_approval_det_id         => x_qa_approval_det_id,
      x_object_approval_id      => x_qa_object_approval_id,
      x_approver_person_id      => x_qa_approver_person_id,
      x_approver_user_id        => x_qa_approver_user_id,
      x_notification_id         => x_qa_notification_id,
      x_approver_sequence       => x_qa_approver_sequence,
      x_approver_status         => x_qa_approver_status,
      x_approver_name           => x_qa_approver_name,
      x_approval_comments       => x_qa_approval_comments,
      x_date_sent               => x_qa_date_sent,
      x_date_received           => x_qa_date_received
   );

   ASO_APR_PUB_W.Set_Rules_List_Tbl_Out(
      p_qte_rules_list_tbl    => lx_rules_list_tbl,
      x_rule_id               => x_qr_rule_id,
      x_object_approval_id    => x_qr_object_approval_id,
      x_rule_action_id        => x_qr_rule_action_id,
      x_rule_description      => x_qr_rule_description,
      x_approval_level        => x_qr_approval_level
   );

  x_msg_count := l_msg_count;

  for k in 1 .. l_msg_count loop

  x_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                   p_encoded => 'F');
  end loop;


END Get_All_Approvers;


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
)
AS
  lx_rules_list_tbl         ASO_Apr_Pub.Rules_List_Tbl_Type;
  l_debug                   VARCHAR2(1);
BEGIN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin calling ASO_Apr_Pub.Get_Rule_Details',
        1,
        'N'
      );
    END IF;

   ASO_Apr_Pub.Get_Rule_Details(
      p_api_version_number  => p_api_version_number,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
      p_object_approval_id  => p_object_approval_id,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_rules_list          => lx_rules_list_tbl);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Returning from ASO_Apr_Pub.Get_Rule_Details',
        1,
        'N'
      );
    END IF;

   ASO_APR_PUB_W.Set_Rules_List_Tbl_Out(
      p_qte_rules_list_tbl    => lx_rules_list_tbl,
      x_rule_id               => x_qr_rule_id,
      x_object_approval_id    => x_qr_object_approval_id,
      x_rule_action_id        => x_qr_rule_action_id,
      x_rule_description      => x_qr_rule_description,
      x_approval_level        => x_qr_approval_level
   );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Returning from Set_Rules_List_Tbl_Out',
        1,
        'N'
      );
    END IF;

END Get_Rule_Details;

END ASO_APR_PUB_W;

/
