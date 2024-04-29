--------------------------------------------------------
--  DDL for Package JTF_TASK_REFERENCES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_REFERENCES_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtfttkns.pls 115.4 2002/12/04 23:49:37 cjang ship $ */


   PROCEDURE create_references_PRE (
      p_references_rec       in    jtf_task_references_pub.references_rec ,
      x_return_status        OUT NOCOPY      VARCHAR2
   );

      PROCEDURE create_references_Post (
      p_references_rec       in    jtf_task_references_pub.references_rec ,
      x_return_status        OUT NOCOPY      VARCHAR2
   );

      PROCEDURE update_references_Pre (
      p_references_rec       in    jtf_task_references_pub.references_rec ,
      x_return_status        OUT NOCOPY      VARCHAR2
   );

      PROCEDURE update_references_Post (
      p_references_rec       in    jtf_task_references_pub.references_rec ,
      x_return_status        OUT NOCOPY      VARCHAR2
   );

      PROCEDURE delete_references_Pre (
      p_references_rec       in    jtf_task_references_pub.references_rec ,
      x_return_status        OUT NOCOPY      VARCHAR2
   );

      PROCEDURE delete_references_Post (
      p_references_rec       in    jtf_task_references_pub.references_rec ,
      x_return_status        OUT NOCOPY      VARCHAR2
   );

END;

 

/
