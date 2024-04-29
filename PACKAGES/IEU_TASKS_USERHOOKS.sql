--------------------------------------------------------
--  DDL for Package IEU_TASKS_USERHOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_TASKS_USERHOOKS" AUTHID CURRENT_USER AS
/* $Header: IEUVTUHS.pls 115.5 2003/06/27 18:27:24 pkumble ship $ */


     PROCEDURE create_task_uwqm_pre (
        x_return_status           OUT NOCOPY      VARCHAR2
    ) ;


    PROCEDURE update_task_uwqm_pre (
       x_return_status           OUT NOCOPY      VARCHAR2
    ) ;

    PROCEDURE delete_task_uwqm_pre (
       x_return_status           OUT NOCOPY      VARCHAR2
    ) ;

   PROCEDURE create_task_assign_uwqm_pre (
      x_return_status OUT NOCOPY VARCHAR2
   ) ;

   PROCEDURE update_task_assign_uwqm_pre (
       x_return_status           OUT NOCOPY      VARCHAR2
    ) ;

   PROCEDURE delete_task_assign_uwqm_pre (
       x_return_status           OUT NOCOPY      VARCHAR2
    ) ;

END IEU_TASKS_USERHOOKS;

 

/
