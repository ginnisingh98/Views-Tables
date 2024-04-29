--------------------------------------------------------
--  DDL for Package Body IES_QUESTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_QUESTIONS_PVT" AS
/* $Header: iesvieqb.pls 115.15 2003/06/06 20:16:17 prkotha ship $ */

  PROCEDURE Insert_Question
  ( p_api_version       IN  NUMBER   := 1           ,
    p_init_msg_list     IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit            IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level  IN  NUMBER   := 1           ,
    x_return_status     OUT NOCOPY VARCHAR2         ,
    x_msg_count         OUT NOCOPY NUMBER           ,
    x_msg_data          OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_panel_id          IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  ) IS
  BEGIN
    Insert_Question(  p_api_version       ,
                     p_init_msg_list     ,
                     p_commit            ,
                     p_validation_level  ,
                     x_return_status     ,
                     x_msg_count         ,
                     x_msg_data          ,
                     p_created_by        ,
                     p_panel_id          ,
                     null                ,
                     p_lookup_id         ,
                     p_node_name         ,
                     p_node_uid          ,
                     null                ,
                     p_active_status     ,
                     x_question_id );
  END Insert_Question;

  PROCEDURE Insert_Question
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count	        OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_panel_id          IN  NUMBER                  ,
    p_question_type_id  IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_question_label    IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  ) IS
  BEGIN
    Insert_Question(  p_api_version       ,
                         p_init_msg_list     ,
                         p_commit            ,
                         p_validation_level  ,
                         x_return_status     ,
                         x_msg_count         ,
                         x_msg_data          ,
                         p_created_by        ,
                         p_panel_id          ,
                         p_question_type_id  ,
                         p_lookup_id         ,
                         p_node_name         ,
                         p_node_uid          ,
                         p_question_label    ,
                         p_active_status     ,
                         null                ,
                     x_question_id );
  END Insert_Question;

  PROCEDURE Insert_Question
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count	        OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_panel_id          IN  NUMBER                  ,
    p_question_type_id  IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_question_label    IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    p_question_order    IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  ) IS
        seqval NUMBER;
    insertstmt varchar2(4000);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Insert_Question_PVT;

    EXECUTE immediate 'select ies_questions_s.nextval from dual' INTO seqval;

    insertstmt := 'INSERT INTO ies_questions ( question_id        ,
                                created_by         ,
                                creation_date      ,
                                panel_id           ,
                                question_type_id   ,
                                lookup_id          ,
                                node_name          ,
                                node_uid           ,
                                question_label     ,
                                question_order     ,
                                active_status )
                    VALUES    ( :1 ,
                                :2 ,
                                :3 ,
                                :4 ,
                                :5 ,
                                :6 ,
                                :7 ,
                                :8 ,
                                :9 ,
                                :10 ,
                                :11 )
     RETURNING question_id INTO :12';

     execute immediate insertStmt using seqval,
                                p_created_by       ,
                                sysdate            ,
                                p_panel_id         ,
                                p_question_type_id ,
                                p_lookup_id        ,
                                p_node_name        ,
                                p_node_uid         ,
                                p_question_label   ,
                                p_question_order   ,
                                p_active_status
     RETURNING INTO x_question_id;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Insert_Question_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Insert_Question;

 PROCEDURE Update_Question
 ( p_api_version        IN  NUMBER   := 1           ,
    p_init_msg_list     IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit            IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level  IN  NUMBER   := 1           ,
    x_return_status     OUT NOCOPY VARCHAR2         ,
    x_msg_count         OUT NOCOPY NUMBER           ,
    x_msg_data          OUT NOCOPY VARCHAR2         ,
    p_question_id       IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  ) IS
  BEGIN
    Update_Question (  p_api_version       ,
                       p_init_msg_list     ,
                       p_commit            ,
                       p_validation_level  ,
                       x_return_status     ,
                       x_msg_count         ,
                       x_msg_data          ,
                       p_question_id       ,
                       null                ,
                       p_lookup_id         ,
                       p_last_updated_by   ,
                       p_node_name         ,
                       p_node_uid          ,
                       null                ,
                       p_active_status     ,
                       x_question_id );
  END Update_Question;

 PROCEDURE Update_Question
 ( p_api_version        IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_question_id       IN  NUMBER                  ,
    p_question_type_id  IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_question_label    IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  ) IS
  BEGIN
    Update_Question (  p_api_version       ,
                       p_init_msg_list     ,
                       p_commit            ,
                       p_validation_level  ,
                       x_return_status     ,
                       x_msg_count         ,
                       x_msg_data          ,
                       p_question_id       ,
                       p_question_type_id  ,
                       p_lookup_id         ,
                       p_last_updated_by   ,
                       p_node_name         ,
                       p_node_uid          ,
                       p_question_label    ,
                       p_active_status     ,
                       null                ,
                       x_question_id );
 END Update_Question;

 PROCEDURE Update_Question
 ( p_api_version        IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_question_id       IN  NUMBER                  ,
    p_question_type_id  IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_question_label    IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    p_question_order    IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  ) IS
    updateStmt varchar2(2000);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Update_Question_PVT;
    updateStmt := 'UPDATE ies_questions SET last_updated_by  = :1  ,
                             last_update_date = :2 ,
                             lookup_id        = :3 ,
                             node_name        = :4 ,
                             question_id      = :5 ,
                             question_type_id = :6 ,
                             node_uid         = :7 ,
                             question_label   = :8 ,
                             active_status    = :9  ,
                             question_order   = :10
                     WHERE   question_id = :11
            RETURNING question_id INTO :12';

    execute immediate updateStmt using p_last_updated_by  ,
                             sysdate            ,
                             p_lookup_id        ,
                             p_node_name        ,
                             p_question_id      ,
                             p_question_type_id ,
                             p_node_uid         ,
                             p_question_label   ,
                             p_active_status    ,
                             p_question_order,
                             p_question_id
            RETURNING INTO x_question_id;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Update_Question_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Update_Question;
END IES_QUESTIONS_PVT;

/
