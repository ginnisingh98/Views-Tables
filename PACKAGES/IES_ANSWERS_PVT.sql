--------------------------------------------------------
--  DDL for Package IES_ANSWERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_ANSWERS_PVT" AUTHID CURRENT_USER AS
/* $Header: iesvieas.pls 115.5 2002/12/09 21:13:35 appldev ship $ */

  PROCEDURE Insert_Answer
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER           ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_answer_value      IN  VARCHAR2                ,
    p_display_value     IN  VARCHAR2                ,
    p_answer_order      IN  NUMBER                  ,
    p_answer_active     IN  NUMBER                  ,
    p_active_status     IN  NUMBER                  ,
    x_answer_id         OUT NOCOPY NUMBER
  ) ;

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
  ) ;
END;

 

/
