--------------------------------------------------------
--  DDL for Package Body IES_ANSWERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_ANSWERS_PVT" AS
/* $Header: iesvieab.pls 115.7 2003/06/06 20:16:22 prkotha ship $ */

  PROCEDURE Insert_Answer
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level  IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count	        OUT NOCOPY NUMBER           ,
    x_msg_data		OUT  NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_answer_value      IN  VARCHAR2                ,
    p_display_value     IN  VARCHAR2                ,
    p_answer_order      IN  NUMBER                  ,
    p_answer_active     IN  NUMBER                  ,
    p_active_status     IN  NUMBER                  ,
    x_answer_id         OUT NOCOPY NUMBER
  ) IS
    seqval NUMBER;
    insertstmt varchar2(4000);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Insert_Answer_PVT;

    EXECUTE immediate 'select ies_answers_s.nextval from dual' INTO seqval;

    insertStmt := 'INSERT INTO ies_answers ( answer_id            ,
                              created_by           ,
                              creation_date        ,
                              lookup_id            ,
                              answer_value         ,
                              answer_display_value ,
                              answer_order         ,
                              answer_active        ,
                              active_status )
                 VALUES    ( :1 ,
                             :2 ,
                             :3 ,
                             :4 ,
                             :5 ,
                             :6 ,
                             :7 ,
                             :8 ,
                             :9 ) RETURNING answer_id INTO :10';
     EXECUTE immediate insertStmt using seqval, p_created_by, sysdate, p_lookup_id,
                                        p_answer_value, p_display_value, p_answer_order, p_answer_active,
                                        p_active_status returning into x_answer_id ;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Insert_Answer_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Insert_Answer;

 PROCEDURE Update_Answer
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level  IN  NUMBER	 := 1       ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count	        OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_answer_id         IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_answer_value      IN  VARCHAR2                ,
    p_display_value     IN  VARCHAR2                ,
    p_answer_order      IN  NUMBER                  ,
    p_answer_active     IN  NUMBER                  ,
    p_active_status     IN  NUMBER                  ,
    x_answer_id         OUT NOCOPY NUMBER
  ) IS
    updateStmt varchar2(4000);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Update_Answer_PVT;
    updateStmt := 'UPDATE ies_answers SET   last_updated_by      = :1 ,
                             last_update_date     = :2,
                             answer_value         = :3,
                             answer_display_value = :4,
                             answer_order         = :5,
                             answer_active        = :6,
                             active_status    = :7
                     WHERE   answer_id = :8 RETURNING answer_id INTO :9';

    execute immediate updateStmt USING p_last_updated_by,
                                                        sysdate            ,
                                                        p_answer_value     ,
                                                        p_display_value    ,
                                                        p_answer_order     ,
                                                        p_answer_active    ,
                                                        p_active_status,
                                                        p_answer_id returning     into x_answer_id      ;
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Update_Answer_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Update_Answer;
END IES_ANSWERS_PVT;

/
