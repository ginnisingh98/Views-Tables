--------------------------------------------------------
--  DDL for Package IES_LOOKUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_LOOKUPS_PVT" AUTHID CURRENT_USER AS
/* $Header: iesviels.pls 115.6 2002/12/09 21:13:42 appldev ship $ */

  PROCEDURE Insert_Lookup
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count	        OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_created_by        IN  NUMBER                  ,
    p_dscript_id        IN  NUMBER                  ,
    p_lookup_table_id   IN  NUMBER                  ,
    p_lookup_name       IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_lookup_id         OUT NOCOPY NUMBER
  );

  PROCEDURE Update_Lookup
  ( p_api_version       IN  NUMBER   := 1	    ,
    p_init_msg_list	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_commit	    	IN  VARCHAR2 := 'DUMMY VAL' ,
    p_validation_level	IN  NUMBER   := 1           ,
    x_return_status	OUT NOCOPY VARCHAR2         ,
    x_msg_count		OUT NOCOPY NUMBER	    ,
    x_msg_data		OUT NOCOPY VARCHAR2         ,
    p_lookup_id         IN  NUMBER                  ,
    p_lookup_table_id   IN  NUMBER                  ,
    p_last_updated_by   IN  NUMBER                  ,
    p_lookup_name       IN  VARCHAR2                ,
    p_active_status     IN  NUMBER                  ,
    x_lookup_id         OUT NOCOPY NUMBER
  );
END;

 

/
