--------------------------------------------------------
--  DDL for Package Body JTF_TASK_MASS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_MASS_PUB" AS
/* $Header: jtfptkbb.pls 115.6 2002/12/05 18:39:41 sachoudh ship $ */

	----------------------------------------------------------------------------------------------------
	-- Start of comments
	-- Procedure Name : create_mass_tasks
	-- Type  	  : Public
	-- Function	  : Create tasks for all the members of a group or a team.
	-- Pre reqs	  : None
	-- Parameters	  :
	--      name			direction	type		required
        --     ------			---------	----		--------
	--     p_api_version		  IN		NUMBER		required
	--     p_init_msg_list		  IN		VARCHAR2	optional
	--     p_commit			  IN            VARCHAR2        optional
	--     x_msg_count		  OUT		NUMBER		required
	--     x_msg_data		  OUT		VARCHAR2	required
	--     x_return_status		  OUT		VARCHAR2	required
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
      				      p_copy_task_dates         IN       VARCHAR2 DEFAULT fnd_api.g_false) IS

		l_api_version      CONSTANT NUMBER := 1.0;
      		l_api_name         CONSTANT VARCHAR2(30) := 'CREATE_TASK';
	BEGIN
		--
		-- Standard start of API savepoint
		--
		SAVEPOINT create_mass_task_pub;

		--
		-- initialize API return status to success
		--
      		x_return_status := fnd_api.g_ret_sts_success;

		--
		-- Standard call to check for call compatibility
		--
      		IF NOT fnd_api.compatible_api_call (
                		l_api_version,
                		p_api_version,
                		l_api_name,
                		g_pkg_name
             			)
      		THEN
         			RAISE fnd_api.g_exc_unexpected_error;
      		END IF;

		--
		-- Initialize message list if p_init_msg_list is set to TRUE
		--
      		IF fnd_api.to_boolean (p_init_msg_list)
      		THEN
         		fnd_msg_pub.initialize;
      		END IF;

		--
		--Call the private package JTF_TASK_MASS_CREATE_PVT to create tasks
		--
		jtf_task_mass_pvt.create_mass_tasks( p_api_version  	   => 1.0,
      				      		     p_init_msg_list       => fnd_api.g_false,
				      		     x_msg_count           => x_msg_count,
      				      		     x_msg_data            => x_msg_data,
     				      		     x_return_status       => x_return_status,
				      		     p_resource_type       => p_resource_type,
				      		     p_resource_id         => p_resource_id,
				      		     p_task_id             => p_task_id,
				      		     p_task_number         => p_task_number,
						     p_keep_record         => p_keep_record,
						     p_keep_resource_id	   => p_keep_resource_id,
						     p_copy_notes	   => p_copy_notes,
                                                     p_copy_task_references => 'T');

				IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         				x_return_status := fnd_api.g_ret_sts_unexp_error;
         				RAISE fnd_api.g_exc_unexpected_error;
				ELSIF (x_return_status = fnd_api.g_ret_sts_success) THEN
					If p_commit = 'T' then
						commit;
					end if;
      				END IF;


	EXCEPTION
		WHEN fnd_api.g_exc_unexpected_error
      		 THEN
         		ROLLBACK TO create_mass_task_pub;
         		x_return_status := fnd_api.g_ret_sts_unexp_error;
         		fnd_msg_pub.count_and_get (
            			p_count => x_msg_count,
            			p_data => x_msg_data
         			);
		WHEN OTHERS
      		THEN
         		ROLLBACK TO create_mass_task_pub;
         		fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         		fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         		x_return_status := fnd_api.g_ret_sts_unexp_error;
         		fnd_msg_pub.count_and_get (
            			p_count => x_msg_count,
            			p_data => x_msg_data
         			);
	END create_mass_tasks;

END jtf_task_mass_pub;

/
