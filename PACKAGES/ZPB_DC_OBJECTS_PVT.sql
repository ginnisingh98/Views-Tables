--------------------------------------------------------
--  DDL for Package ZPB_DC_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DC_OBJECTS_PVT" AUTHID CURRENT_USER AS
/* $Header: ZPBDCGTS.pls 120.0.12010.4 2006/08/03 11:56:06 appldev noship $ */



PROCEDURE Generate_Template_CP(
  errbuf                OUT     NOCOPY      VARCHAR2,
  retcode               OUT     NOCOPY      VARCHAR2,
  --
  p_task_id             IN      NUMBER,
  p_ac_id               IN      NUMBER,
  p_instance_id         IN      NUMBER);

PROCEDURE Generate_Template(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2,
  p_commit              IN      VARCHAR2,
  p_validation_level    IN      NUMBER,
  x_return_status       OUT     NOCOPY     VARCHAR2,
  x_msg_count           OUT     NOCOPY     NUMBER,
  x_msg_data            OUT     NOCOPY     VARCHAR2,
  --
  p_task_id           	IN      NUMBER,
  p_ac_id               IN      NUMBER,
  p_instance_id         IN      NUMBER);

PROCEDURE Auto_Distribute_CP(
  errbuf                OUT     NOCOPY      VARCHAR2,
  retcode               OUT     NOCOPY      VARCHAR2,
  --
  p_task_id             IN      NUMBER,
  p_template_id         IN      NUMBER);


PROCEDURE Auto_Distribute(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2,
  p_commit              IN      VARCHAR2,
  p_validation_level    IN      NUMBER,
  x_return_status       OUT     NOCOPY     VARCHAR2,
  x_msg_count           OUT     NOCOPY     NUMBER,
  x_msg_data            OUT     NOCOPY     VARCHAR2,
  --
  p_task_id             IN      NUMBER,
  p_template_id       	IN      NUMBER);


PROCEDURE Manual_Distribute_CP(
  errbuf                OUT     NOCOPY      VARCHAR2,
  retcode               OUT     NOCOPY      VARCHAR2,
  --
  p_object_id       IN number,
  p_recipient_type  IN varchar2,
  p_dist_list_id    IN number,
  p_approver_type   IN varchar2,
  p_deadline_date   IN varchar2,
  p_overwrite_cust  IN varchar2,
  p_overwrite_data  IN varchar2);

PROCEDURE Manual_Distribute(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2,
  p_commit              IN      VARCHAR2,
  p_validation_level    IN      NUMBER,
  x_return_status       OUT     NOCOPY     VARCHAR2,
  x_msg_count           OUT     NOCOPY     NUMBER,
  x_msg_data            OUT     NOCOPY     VARCHAR2,
  --
  p_object_id       IN number,
  p_recipient_type  IN varchar2,
  p_dist_list_id    IN number,
  p_approver_type   IN varchar2,
  p_deadline_date   IN date,
  p_overwrite_cust  IN varchar2,
  p_overwrite_data  IN varchar2);

PROCEDURE Set_Template_Recipient(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_template_id         IN    NUMBER,
  x_role_name           OUT   NOCOPY VARCHAR2);


PROCEDURE Set_Ws_Recipient(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_task_id             IN      NUMBER,
  p_template_id         IN      NUMBER,
  p_dist_list_id        IN      NUMBER,
  p_object_id           IN      NUMBER,
  p_recipient_type      IN      VARCHAR2,
  x_role_name           OUT     NOCOPY VARCHAR2,
  x_resultout             OUT     nocopy varchar2  );


PROCEDURE Complete_Review(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2,
  p_commit              IN      VARCHAR2,
  p_validation_level    IN      NUMBER,
  x_return_status       OUT     NOCOPY     VARCHAR2,
  x_msg_count           OUT     NOCOPY     NUMBER,
  x_msg_data            OUT     NOCOPY     VARCHAR2,
  --
  p_template_id         IN      NUMBER);


PROCEDURE Delete_Template(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2,
  p_commit              IN      VARCHAR2,
  p_validation_level    IN      NUMBER,
  x_return_status       OUT     NOCOPY     VARCHAR2,
  x_msg_count           OUT     NOCOPY     NUMBER,
  x_msg_data            OUT     NOCOPY     VARCHAR2,
  --
  p_analysis_cycle_instance_id   IN      NUMBER);

 PROCEDURE Set_Submit_Ntf_Recipients(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_object_id           IN    NUMBER,
  x_role_name           OUT   NOCOPY VARCHAR2);


PROCEDURE Populate_Approvers(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_object_id           IN    NUMBER,
  p_approver_user_id    IN    NUMBER,
  p_approval_date       IN    DATE);


PROCEDURE Set_Source_Type(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_ac_instance_id      IN    NUMBER);

PROCEDURE Update_Template_View_Type(
  p_template_id		IN	NUMBER,
  p_view_type		IN	VARCHAR2,
  p_result_out		OUT	NOCOPY VARCHAR2);

PROCEDURE Update_Worksheet_View_Type(
  p_template_id		IN	NUMBER,
  p_object_id		IN	NUMBER,
  p_view_type		IN	VARCHAR2,
  p_result_out		OUT	NOCOPY VARCHAR2);

END ZPB_DC_OBJECTS_PVT;

 

/
