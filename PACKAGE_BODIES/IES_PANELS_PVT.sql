--------------------------------------------------------
--  DDL for Package Body IES_PANELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_PANELS_PVT" AS
/* $Header: iesviepb.pls 115.11 2003/06/06 20:16:18 prkotha ship $ */

  PROCEDURE Insert_Panel
  ( p_api_version       IN  NUMBER   := 1           ,
    p_init_msg_list     IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit            IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level  IN  NUMBER   := 1           ,
    x_return_status     OUT NOCOPY VARCHAR2         ,
    x_msg_count         OUT NOCOPY NUMBER           ,
    x_msg_data          OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_dscript_id        IN  NUMBER                  ,
    p_panel_name        IN  VARCHAR2                ,
    p_panel_uid         IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_panel_id          OUT NOCOPY NUMBER
  ) IS
  BEGIN
    Insert_Panel ( p_api_version ,
                   p_init_msg_list,
                   p_commit,
                   p_validation_level,
                   x_return_status,
		   x_msg_count,
                   x_msg_data,
	           p_created_by,
                   p_dscript_id,
                   p_panel_name,
                   null,
                   p_panel_uid,
                   p_active_status,
                   x_panel_id);

  END Insert_Panel;

  PROCEDURE Insert_Panel
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_dscript_id        IN  NUMBER                  ,
    p_panel_name        IN  VARCHAR2                ,
    p_panel_label       IN  VARCHAR2                ,
    p_panel_uid         IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_panel_id          OUT NOCOPY NUMBER
  ) IS
        seqval NUMBER;
    insertstmt varchar2(4000);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Insert_Panel_PVT;

    EXECUTE immediate 'select ies_panels_s.nextval from dual' INTO seqval;

    insertStmt := 'INSERT INTO ies_panels ( panel_id      ,
                             created_by    ,
                             creation_date ,
                             dscript_id    ,
                             panel_name    ,
                             panel_label   ,
                             panel_uid     ,
                             active_status )
                 VALUES    ( :1,
                             :2,
                             :3,
                             :4,
                             :5,
                             :6,
                             :7,
                             :8)
     RETURNING panel_id INTO :9';

     execute immediate insertStmt using seqval    ,
                                  p_created_by    ,
                                  sysdate         ,
                                  p_dscript_id    ,
                                  p_panel_name    ,
                                  p_panel_label   ,
                                  p_panel_uid     ,
                                  p_active_status   RETURNING INTO x_panel_id;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Insert_Panel_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Insert_Panel;

 PROCEDURE Update_Panel
  ( p_api_version       IN  NUMBER   := 1           ,
    p_init_msg_list     IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit            IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level  IN  NUMBER       := 1       ,
    x_return_status     OUT NOCOPY VARCHAR2         ,
    x_msg_count         OUT NOCOPY NUMBER           ,
    x_msg_data          OUT NOCOPY VARCHAR2         ,
    p_panel_id          IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_panel_name        IN  VARCHAR2                ,
    p_panel_uid         IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_panel_id          OUT NOCOPY NUMBER
  ) IS
  BEGIN
    Update_panel
  ( p_api_version,
    p_init_msg_list,
    p_commit,
    p_validation_level,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_panel_id,
    p_last_updated_by,
    p_panel_name,
    null,
    p_panel_uid,
    p_active_status,
    x_panel_id);
  END Update_Panel;

 PROCEDURE Update_Panel
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER	 := 1       ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_panel_id          IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_panel_name        IN  VARCHAR2                ,
    p_panel_label       IN  VARCHAR2                ,
    p_panel_uid         IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_panel_id          OUT NOCOPY NUMBER
  ) IS
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Update_Panel_PVT;
    execute immediate 'UPDATE ies_panels SET    last_updated_by  = :1  ,
                             last_update_date = :2,
                             panel_name       = :3,
                             panel_label      = :4,
                             panel_uid        = :5,
                             active_status    = :6
                     WHERE   panel_id = :7
            RETURNING panel_id INTO :8' using p_last_updated_by  ,
	                                 sysdate            ,
	                                 p_panel_name       ,
	                                 p_panel_label      ,
	                                 p_panel_uid        ,
	                                 p_active_status,
	                                 p_panel_id RETURNING INTO x_panel_id;

  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Update_Panel_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Update_Panel;
END IES_PANELS_PVT;

/
