--------------------------------------------------------
--  DDL for Package IES_PANELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_PANELS_PVT" AUTHID CURRENT_USER AS
/* $Header: iesvieps.pls 115.9 2002/12/09 21:13:45 appldev ship $ */
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
  );

  PROCEDURE Insert_Panel
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count	        OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_dscript_id        IN  NUMBER                  ,
    p_panel_name        IN  VARCHAR2                ,
    p_panel_label       IN  VARCHAR2                ,
    p_panel_uid         IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_panel_id          OUT NOCOPY NUMBER
  );

  PROCEDURE Update_Panel
  ( p_api_version       IN  NUMBER   := 1           ,
    p_init_msg_list     IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit            IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level  IN  NUMBER   := 1           ,
    x_return_status     OUT NOCOPY VARCHAR2         ,
    x_msg_count         OUT NOCOPY NUMBER           ,
    x_msg_data          OUT NOCOPY VARCHAR2         ,
    p_panel_id          IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_panel_name        IN  VARCHAR2                ,
    p_panel_uid         IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_panel_id          OUT NOCOPY NUMBER
  );

  PROCEDURE Update_Panel
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
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
  );
END;

 

/
