--------------------------------------------------------
--  DDL for Package Body JTF_TASKS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASKS_IUHK" AS
/* $Header: jtfitktb.pls 115.6 2002/11/13 19:13:38 cjang ship $ */

   PROCEDURE create_task_pre (x_return_status OUT NOCOPY VARCHAR2)
   IS
   BEGIN
        jtf_task_utl.call_internal_hook( 'JTF_TASKS_PUB' , 'CREATE_TASK' , 'B' , x_return_status );
   END;

   PROCEDURE create_task_post (x_return_status OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      jtf_task_utl.call_internal_hook( 'JTF_TASKS_PUB' , 'CREATE_TASK' , 'A' , x_return_status );
   END;

   PROCEDURE update_task_pre (x_return_status OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      jtf_task_utl.call_internal_hook( 'JTF_TASKS_PUB' , 'UPDATE_TASK' , 'B' , x_return_status );
   END;

   PROCEDURE update_task_post (x_return_status OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      jtf_task_utl.call_internal_hook( 'JTF_TASKS_PUB' , 'UPDATE_TASK' , 'A' , x_return_status );
   END;

   PROCEDURE delete_task_pre (x_return_status OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      jtf_task_utl.call_internal_hook( 'JTF_TASKS_PUB' , 'DELETE_TASK' , 'B' , x_return_status );
   END;

   PROCEDURE delete_task_post (x_return_status OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      jtf_task_utl.call_internal_hook( 'JTF_TASKS_PUB' , 'DELETE_TASK' , 'A' , x_return_status );
   END;
END;

/
