--------------------------------------------------------
--  DDL for Package Body IES_QUESTION_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_QUESTION_DATA_PVT" AS
/* $Header: iesviqdb.pls 115.5 2002/12/09 21:13:57 appldev ship $ */

  PROCEDURE Insert_Question_Data
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_transaction_id    IN  NUMBER                  ,
    p_question_id       IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_answer_id         IN  NUMBER                  ,
    p_freeform_int      IN  NUMBER                  ,
    p_freeform_string   IN  VARCHAR2                ,
    p_freeform_date     IN  DATE
  ) IS
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	Insert_Question_Data_PVT;
    INSERT INTO ies_question_data ( question_data_id     ,
                                    created_by           ,
                                    creation_date        ,
                                    transaction_id       ,
                                    question_id          ,
                                    lookup_id            ,
                                    answer_id            ,
                                    freeform_int         ,
                                    freeform_string      ,
                                    freeform_date        )
                         VALUES    ( ies_question_data_s.nextval ,
                                     p_created_by         ,
                                     sysdate              ,
                                     p_transaction_id     ,
                                     p_question_id        ,
                                     p_lookup_id          ,
                                     p_answer_id          ,
                                     p_freeform_int       ,
                                     p_freeform_string    ,
                                     p_freeform_date      );
  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Insert_Question_Data_PVT;
       x_return_status := 'E';
       x_msg_data := 'Error ' || TO_CHAR(SQLCODE) ||':'||SQLERRM;
  END Insert_Question_Data;
END IES_Question_Data_PVT;

/
