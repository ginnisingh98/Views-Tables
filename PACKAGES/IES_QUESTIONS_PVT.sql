--------------------------------------------------------
--  DDL for Package IES_QUESTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_QUESTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: iesvieqs.pls 120.0 2005/06/03 07:45:33 appldev noship $ */

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
    p_lookup_id         IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  );

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
    p_question_type_id  IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_question_label    IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  );

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
    p_question_type_id  IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_question_label    IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    p_question_order    IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  );


  PROCEDURE Update_Question
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_question_id       IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  );

  PROCEDURE Update_Question
  ( p_api_version       IN  NUMBER   := 1           ,
    p_init_msg_list     IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit            IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level  IN  NUMBER   := 1           ,
    x_return_status     OUT NOCOPY VARCHAR2         ,
    x_msg_count         OUT NOCOPY NUMBER           ,
    x_msg_data          OUT NOCOPY VARCHAR2         ,
    p_question_id       IN  NUMBER                  ,
    p_question_type_id  IN  NUMBER                  ,
    p_lookup_id         IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_node_name         IN  VARCHAR2                ,
    p_node_uid          IN  VARCHAR2                ,
    p_question_label    IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_question_id       OUT NOCOPY NUMBER
  );

  PROCEDURE Update_Question
  ( p_api_version       IN  NUMBER   := 1           ,
    p_init_msg_list     IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit            IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level  IN  NUMBER   := 1           ,
    x_return_status     OUT NOCOPY VARCHAR2         ,
    x_msg_count         OUT NOCOPY NUMBER           ,
    x_msg_data          OUT NOCOPY VARCHAR2         ,
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
  );

END;

 

/
