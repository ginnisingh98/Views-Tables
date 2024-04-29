--------------------------------------------------------
--  DDL for Package GMD_FOR_SEC1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FOR_SEC1" AUTHID CURRENT_USER AS
/* $Header: GMDFSPRS.pls 115.8 2002/10/24 21:52:44 santunes noship $ */

PROCEDURE sec_prof_form(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
	before_sec_prof_rec     IN      gmd_security_profiles%rowtype,
        sec_prof_rec            IN      gmd_security_profiles%rowtype   ,
	p_formula_id		IN      number,
        p_db_action_ind         IN      varchar2,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        x_return_code           OUT NOCOPY       NUMBER

);



END GMD_FOR_SEC1;


 

/
