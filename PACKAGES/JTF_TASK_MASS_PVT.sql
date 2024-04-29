--------------------------------------------------------
--  DDL for Package JTF_TASK_MASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_MASS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkbs.pls 115.4 2002/12/04 02:19:16 cjang ship $ */


G_PKG_NAME      CONSTANT        VARCHAR2(30):='JTF_TASK_MASS_PVT';
G_USER          CONSTANT        VARCHAR2(30):=FND_GLOBAL.USER_ID;
G_FALSE         CONSTANT        VARCHAR2(30):=FND_API.G_FALSE;
G_TRUE          CONSTANT        VARCHAR2(30):=FND_API.G_TRUE;

	----------------------------------------------------------------------------------------------------
	-- Start of comments
	-- Procedure Name : create_mass_tasks
	-- Type  	  : Private
	-- Function	  : Create tasks for all the members of a group or a team.
	-- Pre reqs	  : None
	-- Parameters	  :
	--      name			direction	type		required
        --     ------			---------	----		--------
	--     p_api_version		  IN		NUMBER		required
	--     p_init_msg_list		  IN		VARCHAR2	optional
	--     p_commit			  IN            VARCHAR2        optional
	--     x_msg_count		  OUT NOCOPY		NUMBER		required
	--     x_msg_data		  OUT NOCOPY		VARCHAR2	required
	--     x_return_status		  OUT NOCOPY		VARCHAR2	required
	--     p_resource_type    	  IN       	VARCHAR2	required
	--     p_resource_id      	  IN       	NUMBER		required
	--     p_task_id          	  IN       	NUMBER		required
	--     p_task_number      	  IN       	VARCHAR2	required
	--     p_keep_record		  IN       	VARCHAR2 	optional
	--     p_keep_resource_id	  IN       	NUMBER		optional
	--     p_copy_notes       	  IN       	VARCHAR2	optional
	--     p_copy_task_assignments    IN       	VARCHAR2	optional
	--     p_copy_task_rsc_reqs       IN       	VARCHAR2	optional
	--     p_copy_task_depends        IN       	VARCHAR2	optional
	--     p_create_recurrences       IN       	VARCHAR2	optional
	--     p_copy_task_references     IN       	VARCHAR2	optional
	--     p_copy_task_dates          IN       	VARCHAR2	optional

	-----------------------------------------------------------------------------------------------------

	PROCEDURE create_mass_tasks( p_api_version      	IN       NUMBER,
      				      p_init_msg_list    	IN       VARCHAR2 DEFAULT fnd_api.g_false,
				      p_commit			IN       VARCHAR2 DEFAULT fnd_api.g_true,
				      x_msg_count        	OUT NOCOPY      NUMBER,
      				      x_msg_data         	OUT NOCOPY      VARCHAR2,
     				      x_return_status    	OUT NOCOPY      VARCHAR2,
				      p_resource_type    	IN       VARCHAR2,
				      p_resource_id      	IN       NUMBER,
				      p_task_id          	IN       NUMBER,
				      p_task_number      	IN       VARCHAR2,
				      p_keep_record		IN       VARCHAR2 DEFAULT NULL,
				      p_keep_resource_id	IN       NUMBER   DEFAULT NULL,
				      p_copy_notes       	IN       VARCHAR2 DEFAULT fnd_api.g_false,
				      p_copy_task_assignments   IN       VARCHAR2 DEFAULT fnd_api.g_false,
      				      p_copy_task_rsc_reqs      IN       VARCHAR2 DEFAULT fnd_api.g_false,
      				      p_copy_task_depends       IN       VARCHAR2 DEFAULT fnd_api.g_false,
      				      p_create_recurrences      IN       VARCHAR2 DEFAULT fnd_api.g_false,
      				      p_copy_task_references    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      				      p_copy_task_dates         IN       VARCHAR2 DEFAULT fnd_api.g_false);

	----------------------------------------------------------------------------------------------------
	-- Start of comments
	-- Procedure Name : validate_resource
	-- Type  	  : private
	-- Function	  : Validate a given resource.
	-- Pre reqs	  : None
	-- Parameters	  :
	--      name			direction	type		required
        --     ------			---------	----		--------
	--     p_api_version		  IN		NUMBER		required
	--     p_init_msg_list		  IN		VARCHAR2	optional
	--     p_resource_type    	  IN       	VARCHAR2	required
	--     p_resource_type_id      	  IN       	NUMBER		required
	--     x_msg_count		  OUT NOCOPY		NUMBER		required
	--     x_msg_data		  OUT NOCOPY		VARCHAR2	required
	--     x_return_status		  OUT NOCOPY		VARCHAR2	required

	-----------------------------------------------------------------------------------------------------

     PROCEDURE validate_resource(p_api_version 		in number,
                                         p_init_msg_list 	in varchar2,
                                         p_resource_type 	in varchar2,
                                         p_resource_type_id  	in number,
				         x_msg_count 		OUT NOCOPY  number,
                                         x_msg_data 		OUT NOCOPY varchar2,
                                         x_return_status 	OUT NOCOPY varchar2);
END jtf_task_mass_pvt;

 

/
