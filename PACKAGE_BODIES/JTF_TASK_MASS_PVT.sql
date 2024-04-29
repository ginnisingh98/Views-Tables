--------------------------------------------------------
--  DDL for Package Body JTF_TASK_MASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_MASS_PVT" AS
/* $Header: jtfvtkbb.pls 120.2 2005/09/29 05:12:39 knayyar ship $ */

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
      				      p_copy_task_dates         IN       VARCHAR2 DEFAULT fnd_api.g_false) IS


		--
		-- Declare a ref cursor
		--
		TYPE MassCurTyp IS REF CURSOR;
   		mass_task   MassCurTyp;

		--
		-- Declare local and bind variables
		--
		l_task_resource_id	number;
		l_resource_type         VARCHAR2(100);
		l_sql_stmt		VARCHAR2(1000);
		l_api_version   	CONSTANT NUMBER := 1.0;
      		l_api_name      	CONSTANT VARCHAR2(30)  := 'CREATE_MASS_TASKS';
		l_task_id		NUMBER;
		l_task_assignment_id	NUMBER;

		--
		-- Declare a cursor to return a resource_type for a given resource_id
		--
		CURSOR c_resource_type(b_task_resource_id in number) IS
		select resource_type
        -- Bug Fix 2909730, Bug# 4455786 MOAC.
		from jtf_task_resources_vl
		where resource_id = b_task_resource_id;

	BEGIN
		--
		-- Standard start of API savepoint
		--
		SAVEPOINT create_mass_tasks;

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
		--Call the private package JTF_TASK_UTL to validate a given task
		--
			jtf_task_utl.validate_task(
      				x_return_status   => x_return_status,
      				p_task_id         => p_task_id,
      				p_task_number     => p_task_number,
				x_task_id	  => l_task_id);

				IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      				THEN
         				x_return_status := fnd_api.g_ret_sts_unexp_error;
         				RAISE fnd_api.g_exc_unexpected_error;
      				END IF;

	      --
	      -- Check if the passed resource_id and resource_type are not null
	      --
	      IF (p_resource_id IS NOT NULL AND p_resource_type IS NOT NULL) THEN

		 --
	      	 -- If the resource_type is a Group resource then get all the members of a given group
	     	 --
		IF (p_resource_type = 'RS_GROUP') THEN
				--
				-- If p_keep_record is 'Y' then a new task should be created even if one already exists for the owner.
				--
				IF (p_keep_record = 'Y') THEN
					l_sql_stmt := 'SELECT resource_id FROM jtf_rs_group_members WHERE group_id = :id and delete_flag = ''N''';
				ELSE
			   		l_sql_stmt := 'SELECT resource_id FROM jtf_rs_group_members WHERE group_id = :id and resource_id != :keep_resource_id and delete_flag = ''N''';
				END IF;

		 --
	      	 --If the resource_type is a Team resource then get all the members of a given team
	     	 --
        	ELSIF (p_resource_type = 'RS_TEAM') THEN
			--
			-- If p_keep_record is 'Y' then a new task should be created even if one already exists for the owner.
			--
			IF (p_keep_record = 'Y') THEN
			    l_sql_stmt := 'SELECT team_resource_id FROM jtf_rs_team_members WHERE team_id = :id and resource_type = ''INDIVIDUAL'' and delete_flag = ''N''';
			ELSE
			     l_sql_stmt := 'SELECT team_resource_id FROM jtf_rs_team_members WHERE team_id = :id and resource_type = ''INDIVIDUAL'' and team_resource_id != :keep_resource_id and delete_flag = ''N''';
			END IF;
		END IF;

		IF (p_keep_record = 'Y' and p_keep_resource_id is not null) THEN
			--
			-- If p_keep_record is 'Y' then select all the members for a given group or a team
			--
			OPEN mass_task FOR l_sql_stmt USING p_resource_id;
		ELSE
			--
			-- If p_keep_record is 'N' then select all the members for a given group or a team except the task owner
			--
			OPEN mass_task FOR l_sql_stmt USING p_resource_id, p_keep_resource_id;
		END IF;
   			LOOP
				--
				-- Fetch the task_resource_id
				--
      				FETCH mass_task INTO l_task_resource_id;
				EXIT WHEN mass_task%NOTFOUND;

				--
				-- Get the resource_type for a given resource_id
				--
				OPEN c_resource_type(l_task_resource_id);
				FETCH c_resource_type into l_resource_type;
				CLOSE c_resource_type;

				--
				-- Call the public API JTF_TASKS_PUB to Copy a task for all the members of a group or a team
				--
				jtf_tasks_pub.copy_task (
      				p_api_version             => p_api_version,
      				p_init_msg_list           => p_init_msg_list,
      				p_commit                  => p_commit,
      				p_source_task_id          => p_task_id,
      				p_source_task_number      => p_task_number,
      				p_copy_task_references    => fnd_api.g_true,
				x_return_status           => x_return_status,
      				p_copy_notes		  => p_copy_notes,
				p_copy_task_assignments   => fnd_api.g_false,
      				p_resource_id		  => l_task_resource_id,
      				p_resource_type		  => l_resource_type,
      				x_msg_count               => x_msg_count,
      				x_msg_data                => x_msg_data,
      				x_task_id                 => l_task_id,
   			 	p_copy_task_contacts      => fnd_api.g_true,
				p_copy_task_contact_points => fnd_api.g_true
   				);

				--dbms_output.put_line('task_id :' ||l_task_id);

				IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      				THEN
         				x_return_status := fnd_api.g_ret_sts_unexp_error;
         				RAISE fnd_api.g_exc_unexpected_error;
      				END IF;

			END LOOP;
				--
				--Close the cursor
				--
   				CLOSE mass_task;
	     END IF;

		--
		--Close the cursor
		--
		IF mass_task%ISOPEN
      		THEN
         		CLOSE mass_task;
      		END IF;

		--
		--Close the cursor
		--
		IF c_resource_type%ISOPEN
      		THEN
         		CLOSE c_resource_type;
      		END IF;

	EXCEPTION

		WHEN fnd_api.g_exc_unexpected_error
      		THEN
         		ROLLBACK TO create_mass_tasks;
         		x_return_status := fnd_api.g_ret_sts_unexp_error;
         		fnd_msg_pub.count_and_get (
            			p_count => x_msg_count,
            			p_data => x_msg_data
         			);

		--
		--Close the cursor
		--
		IF mass_task%ISOPEN
      		THEN
         		CLOSE mass_task;
      		END IF;

		--
		--Close the cursor
		--
		IF c_resource_type%ISOPEN
      		THEN
         		CLOSE c_resource_type;
      		END IF;

		WHEN OTHERS
      		THEN
         		ROLLBACK TO create_mass_tasks;
         		fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         		fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         		x_return_status := fnd_api.g_ret_sts_unexp_error;
         		fnd_msg_pub.count_and_get (
            			p_count => x_msg_count,
            			p_data => x_msg_data
         			);
	END create_mass_tasks;


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
      	Procedure validate_resource(p_api_version 		in number,
                                         p_init_msg_list 	in varchar2,
                                         p_resource_type 	in varchar2,
                                         p_resource_type_id  	in number,
				         x_msg_count 		OUT NOCOPY  number,
                                         x_msg_data 		OUT NOCOPY varchar2,
                                         x_return_status 	OUT NOCOPY varchar2) is

		--
		-- Declare local variables
		--
		l_resource_id  number;

		--
		-- Declare a cursor to select the resource_id
		--
		cursor c_resource is
		select resource_id
        -- Bug Fix 2909730, Bug# 4455786 MOAC.
		from jtf_task_resources_vl
		where resource_id = p_resource_type_id
		and resource_type = p_resource_type;
	Begin

		--
		-- initialize API return status to success
		--
		x_return_status := fnd_api.g_ret_sts_success;

		--
		-- Fetch the resource_id into a local variable
		--
       		open c_resource;
       		fetch c_resource into l_resource_id;
       		close c_resource;

		--
		-- Check if the resource_id exists
		--
		If  l_resource_id is null then
         		x_return_status := fnd_api.g_ret_sts_unexp_error;
           		fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OWNER_ID');
            		fnd_message.set_token ('P_OWNER_ID', p_resource_type_id);
            		fnd_msg_pub.add;
            		RAISE fnd_api.g_exc_unexpected_error;
		end if;

		--
		--Close the cursor
		--
		IF c_resource%ISOPEN
      		THEN
         		CLOSE c_resource;
      		END IF;

	exception

		 WHEN fnd_api.g_exc_unexpected_error THEN
         		x_return_status := fnd_api.g_ret_sts_unexp_error;
         		fnd_msg_pub.count_and_get (
            			p_count => x_msg_count,
            			p_data => x_msg_data
         			);

		--
		--Close the cursor
		--
		IF c_resource%ISOPEN
      		THEN
         		CLOSE c_resource;
      		END IF;

		WHEN OTHERS THEN
            		x_return_status := fnd_api.g_ret_sts_unexp_error;
            		fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OWNER_ID');
            		fnd_message.set_token ('P_OWNER_ID', p_resource_type_id);
            		fnd_msg_pub.add;
            		RAISE fnd_api.g_exc_unexpected_error;

	End validate_resource;

   END;

/
