--------------------------------------------------------
--  DDL for Package Body JTF_TASK_DATES_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_DATES_IUHK" AS
/* $Header: jtfitkdb.pls 115.6 2002/12/05 23:47:23 sachoudh ship $ */



   PROCEDURE create_task_dates_pre (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
      x_return_status    OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        null;
    END ;


   PROCEDURE create_task_dates_post (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
      x_return_status    OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        null;
    END ;

    PROCEDURE update_task_dates_pre (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    )    is
    BEGIN
        null;
    END ;

    PROCEDURE update_task_dates_post (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
        x_return_status           OUT NOCOPY      VARCHAR2
    )    is
    BEGIN
        null;
    END ;

 PROCEDURE delete_task_dates_pre (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
      x_return_status   OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        null;
    END ;

   PROCEDURE delete_task_dates_post (
      p_task_dates_rec   in       jtf_task_dates_pub.task_dates_rec,
      x_return_status   OUT NOCOPY      VARCHAR2
   )    is
    BEGIN
        null;
    END ;

END;

/
