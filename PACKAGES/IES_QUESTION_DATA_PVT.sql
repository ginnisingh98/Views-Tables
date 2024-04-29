--------------------------------------------------------
--  DDL for Package IES_QUESTION_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_QUESTION_DATA_PVT" AUTHID CURRENT_USER AS
/* $Header: iesviqds.pls 115.5 2002/12/09 21:13:55 appldev ship $ */

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
  );
END;

 

/
