--------------------------------------------------------
--  DDL for Package ZPB_EXCP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_EXCP_PVT" AUTHID CURRENT_USER AS
/* $Header: ZPBVEXCS.pls 120.0.12010.2 2005/12/23 06:06:18 appldev noship $  */

  g_req_child_nodes       CONSTANT number := 0;
  g_child_nodes_populated CONSTANT number := 1;
  g_req_explanation       CONSTANT number := 2;
  g_value_none            CONSTANT number := 0;
  g_value_number          CONSTANT number := 1;
  g_value_char            CONSTANT number := 2;
  g_value_date            CONSTANT number := 3;

  EXCEPTION_LIMIT	  		  CONSTANT varchar2(15) := 'EXCEPTION_LIMIT';
  QUERY_OBJECT_PATH       CONSTANT varchar2(17) := 'QUERY_OBJECT_PATH';
  QUERY_OBJECT_NAME       CONSTANT varchar2(17) := 'QUERY_OBJECT_NAME';

PROCEDURE request_children (
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY number,
  x_msg_data          OUT NOCOPY varchar2,
  p_notification_id   IN  zpb_excp_explanations.notification_id%type,
  p_task_id           IN  zpb_excp_explanations.task_id%type);

PROCEDURE run_exception (
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY varchar2,
  x_msg_count         OUT NOCOPY number,
  x_msg_data          OUT NOCOPY varchar2,
  p_task_id           IN  NUMBER,
  p_user_id           IN  NUMBER );

PROCEDURE test_run_exception;

procedure request_child_nodes(
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY number,
  x_msg_data          OUT NOCOPY varchar2,
  p_task_id           IN  zpb_excp_explanations.task_id%type,
  p_notification_id   IN  zpb_excp_explanations.notification_id%type);

PROCEDURE test_req_child;

END zpb_excp_pvt;

 

/
