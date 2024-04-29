--------------------------------------------------------
--  DDL for Package JTF_TASK_RESOURCES_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RESOURCES_CUHK" AUTHID CURRENT_USER AS
/* $Header: jtfctkrs.pls 115.6 2002/12/05 23:30:50 sachoudh ship $ */
   g_pkg_name   CONSTANT VARCHAR2(30) := 'JTF_TASK_RESOURCES_CUHK';

   PROCEDURE create_task_rsrc_req_pre (
      p_task_rsc_req_rec   IN       jtf_task_resources_pub.task_rsc_req_rec,
      x_return_status      OUT NOCOPY      VARCHAR2
   );

   PROCEDURE create_task_rsrc_req_post (
      p_task_rsc_req_rec   IN       jtf_task_resources_pub.task_rsc_req_rec,
      x_return_status      OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_task_rsrc_req_pre (
      p_task_rsc_req_rec   IN       jtf_task_resources_pub.task_rsc_req_rec,
      x_return_status      OUT NOCOPY      VARCHAR2
   );

   PROCEDURE update_task_rsrc_req_post (
      p_task_rsc_req_rec   IN       jtf_task_resources_pub.task_rsc_req_rec,
      x_return_status      OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_task_rsrc_req_pre (
      p_task_rsc_req_rec   IN       jtf_task_resources_pub.task_rsc_req_rec,
      x_return_status      OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_task_rsrc_req_post (
      p_task_rsc_req_rec   IN       jtf_task_resources_pub.task_rsc_req_rec,
      x_return_status      OUT NOCOPY      VARCHAR2
   );
END;

 

/
