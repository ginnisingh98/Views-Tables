--------------------------------------------------------
--  DDL for Package Body EAM_LINEAR_LOCATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_LINEAR_LOCATIONS_PUB" AS
/* $Header: EAMPELLB.pls 120.4 2006/02/24 15:18:31 sraval noship $*/
   -- Start of comments
   -- API name : eam_linear_locations_pub
   -- Type     : Public.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN    p_api_version      IN NUMBER    Required
   --       p_init_msg_list    IN VARCHAR2  Optional  Default = FND_API.G_FALSE
   --       p_commit           IN VARCHAR2  Optional  Default = FND_API.G_FALSE
   --       p_validation_level IN NUMBER    Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       parameter1
   --       parameter2
   --       .
   --       .
   -- OUT   x_return_status   OUT   VARCHAR2(1)
   --       x_msg_count       OUT   NUMBER
   --       x_msg_data        OUT   VARCHAR2(2000)
   --       parameter1
   --       parameter2
   --       .
   --       .
   -- Version  Current version x.x
   --          Changed....
   --          previous version   y.y
   --          Changed....
   --         .
   --         .
   --          previous version   2.0
   --          Changed....
   --          Initial version    1.0
   --
   -- Notes    : Note text
   --
   -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_linear_locations_pub';

   function return_user_id(p_user_name in varchar2) return number
   is
   	l_user_id number;
   begin
   	select user_id into l_user_id
   	from fnd_user
   	where user_name = p_user_name;

   	return l_user_id;
   end;

   function check_valid_user(p_user_name in varchar2) return number is
   	l_user_id	number;
   	l_resp_id	number;
	l_appl_id 	number;
   	l_check		number;
	l_lang		varchar2(10);
	l_resp 		varchar2(35);
   begin
   	-- populate with the new responsibility id.
   	l_resp_id := 111;
	l_lang := 'US';
	l_appl_id := 426;
	l_resp := 'Linear Asset Management User';

	select responsibility_id into l_resp_id
	from fnd_responsibility_tl
	where responsibility_name = l_resp
	and application_id = l_appl_id
	and language = l_lang;

   	l_user_id := -1;
   	begin
   		l_user_id := return_user_id(p_user_name);


   		begin
   			select 1
   			into l_check
   			from fnd_user_resp_groups
   			where user_id = l_user_id
   			and responsibility_id = l_resp_id;
   		exception
   			when no_data_found then
   				return l_user_id;
   		end;

   		return l_user_id;
   	exception
   		when no_data_found then
   			return l_user_id;

   	end;

   end check_valid_user;



   PROCEDURE insert_row
   (
      p_api_version          IN  NUMBER
     ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
     ,p_commit               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_external_linear_id   IN  NUMBER
     ,p_external_linear_name IN  VARCHAR2
     ,p_external_source_name IN  VARCHAR2
     ,p_external_linear_type IN  VARCHAR2
     ,x_eam_linear_id        OUT NOCOPY NUMBER
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'insert_row';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
     l_count                   NUMBER       := 0;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_linear_locations_pub;

     -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     -- API body

     -- Validation of external_source_name
     SELECT count(*) INTO l_count FROM dual WHERE EXISTS
       (SELECT 1 FROM mfg_lookups WHERE lookup_code = p_external_source_name
                                    AND lookup_type = 'EAM_EXTERNAL_SOURCE_NAME');

     IF (l_count = 0) THEN
        fnd_message.set_name('EAM', 'EAM_INVALID_PARAMETER');
        fnd_message.set_token('NAME', 'p_external_source_name : ' || p_external_source_name);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;

     -- Validation of external_linear_id
     IF (p_external_linear_id IS NULL) THEN
        fnd_message.set_name('EAM', 'EAM_INVALID_PARAMETER');
        fnd_message.set_token('NAME', 'p_external_linear_id : ' || p_external_linear_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;

     SELECT count(*) INTO l_count FROM dual WHERE EXISTS
       (SELECT 1 FROM eam_linear_locations WHERE external_linear_id = p_external_linear_id
                                             AND external_source_name = p_external_source_name
                                             AND external_linear_type = p_external_linear_type);

     IF (l_count > 0) THEN
        fnd_message.set_name('EAM', 'EAM_EXT_LINEAR_ID_EXISTS');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;

     -- insert into eam_linear_locations table
     INSERT INTO eam_linear_locations
     (
       external_linear_id
       ,external_source_name
       ,external_linear_name
       ,external_linear_type
       ,eam_linear_id
     ) VALUES
     (
       p_external_linear_id
       ,p_external_source_name
       ,p_external_linear_name
       ,p_external_linear_type
       ,eam_linear_locations_s.nextval
     ) RETURNING eam_linear_id INTO x_eam_linear_id;

     -- End of API body.

     -- Standard check of p_commit.
     IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END insert_row;


   PROCEDURE update_row
   (
      p_api_version          IN  NUMBER
     ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
     ,p_commit               IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_external_linear_id   IN  NUMBER
     ,p_external_linear_name IN  VARCHAR2
     ,p_external_source_name IN  VARCHAR2
     ,p_external_linear_type IN VARCHAR2
     ,p_eam_linear_id        IN  NUMBER
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'update_row';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
     l_count                   NUMBER       := 0;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_linear_locations_pub;

     -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     -- API body

     -- Validation of eam_linear_id
     SELECT count(*) INTO l_count FROM dual WHERE EXISTS
       (SELECT 1 FROM eam_linear_locations WHERE eam_linear_id = p_eam_linear_id);

     IF (l_count = 0) THEN
        fnd_message.set_name('EAM', 'EAM_INVALID_PARAMETER');
        fnd_message.set_token('NAME', 'p_eam_linear_id : ' || p_eam_linear_id);
	fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;

     -- Validation of external_source_name
     SELECT count(*) INTO l_count FROM dual WHERE EXISTS
       (SELECT 1 FROM mfg_lookups WHERE lookup_code = p_external_source_name
                                    AND lookup_type = 'EAM_EXTERNAL_SOURCE_NAME');

     IF (l_count = 0) THEN
        fnd_message.set_name('EAM', 'EAM_INVALID_PARAMETER');
        fnd_message.set_token('NAME', 'p_external_source_name : ' || p_external_source_name);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;

     -- Validation of external_linear_id
     IF (p_external_linear_id IS NULL) THEN
        fnd_message.set_name('EAM', 'EAM_INVALID_PARAMETER');
        fnd_message.set_token('NAME', 'p_external_linear_id : ' || p_external_linear_id);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;

     SELECT count(*) INTO l_count FROM dual WHERE EXISTS
       (SELECT 1 FROM eam_linear_locations WHERE external_linear_id = p_external_linear_id
                                             AND external_source_name = p_external_source_name
                                             AND external_linear_type = p_external_linear_type
                                             AND eam_linear_id <> p_eam_linear_id);

     IF (l_count > 0) THEN
        fnd_message.set_name('EAM', 'EAM_EXT_LINEAR_ID_EXISTS');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;

     -- Update the record in eam_linear_locations table
     UPDATE eam_linear_locations SET
       external_linear_id     =  p_external_linear_id
      ,external_source_name   =  p_external_source_name
      ,external_linear_name   =  p_external_linear_name
      ,external_linear_type   =  p_external_linear_type
     WHERE
       eam_linear_id	      =  p_eam_linear_id;

     -- End of API body.

     -- Standard check of p_commit.
     IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END update_row;


   PROCEDURE get_eam_linear_id
   (
      p_api_version          IN  NUMBER
     ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_external_linear_id   IN  NUMBER
     ,p_external_source_name IN  VARCHAR2
     ,p_external_linear_type IN  VARCHAR2
     ,x_eam_linear_id        OUT NOCOPY NUMBER
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'get_eam_linear_id';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
     l_count                   NUMBER       := 0;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_linear_locations_pub;

     -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     -- API body

     -- Validation of external_source_name
     SELECT count(*) INTO l_count FROM dual WHERE EXISTS
       (SELECT 1 FROM mfg_lookups WHERE lookup_code = p_external_source_name
                                    AND lookup_type = 'EAM_EXTERNAL_SOURCE_NAME');

     IF (l_count = 0) THEN
        fnd_message.set_name('EAM', 'EAM_INVALID_PARAMETER');
        fnd_message.set_token('NAME', 'p_external_source_name : ' || p_external_source_name);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;


     BEGIN
       SELECT eam_linear_id INTO x_eam_linear_id FROM eam_linear_locations
         WHERE external_linear_id = p_external_linear_id
         AND external_source_name = p_external_source_name
         AND external_linear_type = p_external_linear_type;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       	 x_eam_linear_id := -1;
         --fnd_message.set_name('EAM', 'EAM_INVALID_EXT_LINEAR_ID');
         --fnd_msg_pub.add;
         --RAISE fnd_api.g_exc_error;
     END;

     -- Standard call to get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END get_eam_linear_id;

   procedure create_asset(
         p_api_version          IN  NUMBER
         ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
         ,p_commit               IN  VARCHAR2 := fnd_api.g_false
         ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
         ,p_external_linear_id   IN  NUMBER
         ,p_external_linear_name IN  VARCHAR2
         ,p_external_source_name IN  VARCHAR2
         ,p_external_linear_type IN  VARCHAR2
         ,p_serial_number	 IN  VARCHAR2
         ,p_user_name	      	 IN  VARCHAR2
         ,p_inventory_item_id    IN NUMBER
         ,p_current_organization_id IN NUMBER
         ,p_owning_department_id IN NUMBER
         ,p_descriptive_text     IN VARCHAR2
         ,x_object_id	         OUT NOCOPY VARCHAR2
         ,x_return_status        OUT NOCOPY VARCHAR2
         ,x_msg_count            OUT NOCOPY NUMBER
         ,x_msg_data             OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'create_asset';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
     l_count                   NUMBER       := 0;
     l_x_return_status varchar2(30);
     l_x_msg_count number;
     l_x_msg_data varchar2(2000);
     l_x_eam_linear_id number;
     l_boolean boolean;

     l_user_id number;
     l_resp_id number := 111;
     l_resp_appl_id number := 426;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_linear_locations_pub;


     -- validate and set the user context
      	l_user_id := return_user_id(p_user_name);


	if (l_user_id <> -1) then
	    	fnd_global.apps_initialize
    		(
			user_id => l_user_id,
			resp_id => l_resp_id,
			resp_appl_id => l_resp_appl_id
		);
	else
	         RAISE fnd_api.g_exc_unexpected_error;
	end if;

     -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     -- API body
     	--first check if asset already exists in EAM
	eam_linear_locations_pub.get_eam_linear_id(
		p_api_version          => p_api_version
		,p_init_msg_list        => p_init_msg_list
		,p_validation_level     => p_validation_level
		,p_external_linear_id   => p_external_linear_id
		,p_external_source_name => p_external_source_name
		,p_external_linear_type => p_external_linear_type
		,x_eam_linear_id        => l_x_eam_linear_id
		,x_return_status        => l_x_return_status
		,x_msg_count            => l_x_msg_count
     		,x_msg_data             => l_x_msg_data
	);

     	-- if asset does not exist in  ELL, then insert row and get EAM linear id
     	if (l_x_eam_linear_id = -1) then
     		 eam_linear_locations_pub.insert_row(
		      p_api_version          => p_api_version
		     ,p_init_msg_list        => p_init_msg_list
		     ,p_commit              => p_commit
		     ,p_validation_level     => p_validation_level
		     ,p_external_linear_id   => p_external_linear_id
		     ,p_external_linear_name => p_external_linear_name
		     ,p_external_source_name => p_external_source_name
		     ,p_external_linear_type => p_external_linear_type
		     ,x_eam_linear_id        => l_x_eam_linear_id
		     ,x_return_status        => l_x_return_status
		     ,x_msg_count            => l_x_msg_count
     		     ,x_msg_data             => l_x_msg_data
   		) ;
     	end if;

     	-- create asset with EAM linear Id
	EAM_AssetNumber_Pub.Insert_Asset_Number
	(
		p_api_version => 1.0
		,p_init_msg_list => p_init_msg_list
		,p_commit => p_commit
		,p_validation_level => p_validation_level

		,x_return_status	=> x_return_status
		,x_msg_count => x_msg_count
		,x_msg_data => x_msg_data
		,x_object_id => x_object_id
		,p_INVENTORY_ITEM_ID => p_inventory_item_id
		,p_SERIAL_NUMBER  => p_serial_number
		,p_CURRENT_STATUS => 3
		,p_DESCRIPTIVE_TEXT => p_descriptive_text
		,p_CURRENT_ORGANIZATION_ID => p_current_organization_id

		,p_MAINTAINABLE_FLAG => 'Y'
		,p_OWNING_DEPARTMENT_ID => p_OWNING_DEPARTMENT_ID
		,p_NETWORK_ASSET_FLAG => 'N'

		,p_instantiate_flag => TRUE
		,p_eam_linear_id => l_x_eam_linear_id
	);


     -- End API body
     -- Standard check of p_commit.
     	IF FND_API.To_Boolean( p_commit ) THEN
     		COMMIT WORK;
	END IF;
     -- Standard call to get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_linear_locations_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END create_asset;

   procedure create_work_request(
               p_api_version          IN  NUMBER
               ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
               ,p_commit               IN  VARCHAR2 := fnd_api.g_false
               ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
               ,p_external_linear_id   IN  NUMBER
               ,p_external_linear_name IN  VARCHAR2
               ,p_external_source_name IN  VARCHAR2
               ,p_external_linear_type IN  VARCHAR2
               ,p_work_request_rec     IN  WIP_EAM_WORK_REQUESTS%ROWTYPE
               ,p_user_name 		IN VARCHAR2
               ,p_mode 		    IN VARCHAR2
               ,p_request_log	    IN VARCHAR2
               ,x_work_request_id	    OUT NOCOPY VARCHAR2
               ,x_return_status        OUT NOCOPY VARCHAR2
               ,x_msg_count            OUT NOCOPY NUMBER
               ,x_msg_data             OUT NOCOPY VARCHAR2
   )

   IS

        l_api_name       CONSTANT VARCHAR2(30) := 'create_work_request';
        l_api_version    CONSTANT NUMBER       := 1.0;
        l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_count                   NUMBER       := 0;
        l_x_return_status varchar2(30);
        l_x_msg_count number;
        l_x_msg_data varchar2(2000);
        l_x_eam_linear_id number;
	l_work_request_rec      WIP_EAM_WORK_REQUESTS%ROWTYPE;

	l_user_id number;
	l_resp_id number := 111;
	l_resp_appl_id number := 426;

      BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT eam_linear_locations_pub;


     -- validate and set the user context
      	l_user_id := return_user_id(p_user_name);


	if (l_user_id <> -1) then
	    	fnd_global.apps_initialize
    		(
			user_id => l_user_id,
			resp_id => l_resp_id,
			resp_appl_id => l_resp_appl_id
		);
	else
	         RAISE fnd_api.g_exc_unexpected_error;
	end if;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call(
               l_api_version
              ,p_api_version
              ,l_api_name
              ,g_pkg_name) THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF fnd_api.to_boolean(p_init_msg_list) THEN
           fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

     -- API body

	     eam_linear_locations_pub.get_eam_linear_id(
			p_api_version          => p_api_version
			,p_init_msg_list        => p_init_msg_list
			,p_validation_level     => p_validation_level
			,p_external_linear_id   => p_external_linear_id
			,p_external_source_name => p_external_source_name
			,p_external_linear_type => p_external_linear_type
			,x_eam_linear_id        => l_x_eam_linear_id
			,x_return_status        => l_x_return_status
			,x_msg_count            => l_x_msg_count
				,x_msg_data             => l_x_msg_data
		);

		-- if asset does not exist in  ELL, then insert row and get EAM linear id
		if (l_x_eam_linear_id = -1) then
			  eam_linear_locations_pub.insert_row(
			      p_api_version          => p_api_version
			     ,p_init_msg_list        => p_init_msg_list
			     ,p_commit              => p_commit
			     ,p_validation_level     => p_validation_level
			     ,p_external_linear_id   => p_external_linear_id
			     ,p_external_linear_name => p_external_linear_name
			     ,p_external_source_name => p_external_source_name
			     ,p_external_linear_type => p_external_linear_type
			     ,x_eam_linear_id        => l_x_eam_linear_id
			     ,x_return_status        => l_x_return_status
			     ,x_msg_count            => l_x_msg_count
			     ,x_msg_data             => l_x_msg_data
			  ) ;
		end if;

                l_work_request_rec  :=  p_work_request_rec;
		l_work_request_rec.eam_linear_location_id := l_x_eam_linear_id;

		WIP_EAM_WORKREQUEST_PUB.work_request_import
		(
			p_api_version => 1.0
			,p_mode => p_mode
			,p_work_request_rec => l_work_request_rec
			,p_request_log => p_request_log
			,p_user_id => l_user_id
			,x_work_request_id=>x_work_request_id
			,x_return_status => x_return_status
			,x_msg_count => x_msg_count
			,x_msg_data => x_msg_data
		);


     --END API body
     -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
          		COMMIT WORK;
     	END IF;
          -- Standard call to get message count and if count is 1, get message info.
          fnd_msg_pub.count_and_get(p_count => x_msg_count
                                   ,p_data => x_msg_data);
        EXCEPTION
           WHEN fnd_api.g_exc_error THEN
              ROLLBACK TO eam_linear_locations_pub;
              x_return_status := fnd_api.g_ret_sts_error;
              fnd_msg_pub.count_and_get(p_count => x_msg_count
                                       ,p_data => x_msg_data);
           WHEN fnd_api.g_exc_unexpected_error THEN
              ROLLBACK TO eam_linear_locations_pub;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
              fnd_msg_pub.count_and_get(p_count => x_msg_count
                                       ,p_data => x_msg_data);
           WHEN OTHERS THEN
              ROLLBACK TO eam_linear_locations_pub;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
              END IF;
              fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);

   end create_work_request;









        PROCEDURE CREATE_EAM_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version             IN  NUMBER := 1.0
         , p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
         , p_commit                  IN  VARCHAR2 := fnd_api.g_false
         , p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
         , p_external_source_name    IN  VARCHAR2
         , p_external_linear_type    IN  VARCHAR2 := 'ASSET'
         , p_external_linear_name    IN  VARCHAR2
         , p_external_linear_id      IN  NUMBER
         , p_user_name	      	     IN  VARCHAR2
         , x_wip_entity_id           OUT NOCOPY NUMBER
         , x_msg_data                OUT NOCOPY VARCHAR2
         , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
         , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
         , p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
	 , x_eam_wo_comp_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_eam_wo_quality_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_eam_meter_reading_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
	, x_eam_wo_comp_rebuild_tbl  OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
	, x_eam_wo_comp_mr_read_tbl  OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
	, x_eam_op_comp_tbl          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, x_eam_request_tbl          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := fnd_api.g_false
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         )
   IS

        l_api_name       CONSTANT VARCHAR2(30) := 'create_eam_wo';
        l_api_version    CONSTANT NUMBER       := 1.0;
        l_full_name      CONSTANT VARCHAR2(60) := 'eam_linear_locations_pub' || '.' || l_api_name;
        l_count                   NUMBER       := 0;
        l_message        VARCHAR2(2000);
        l_x_return_status varchar2(30);
        l_x_msg_count number;
        l_x_msg_data varchar2(2000);
        l_x_eam_linear_id number;

        l_bo_identifier            VARCHAR2(30);
        l_api_version_number       NUMBER;
        l_init_msg_list            VARCHAR2(10);
        l_commit                   VARCHAR2(2);

        l_external_source_name     VARCHAR2(240);
        l_external_linear_type     VARCHAR2(240);
        l_external_linear_name     VARCHAR2(240);
        l_external_linear_id       NUMBER;
        l_wip_entity_id            NUMBER;
        l_class_code               VARCHAR2(10);

        l_eam_wo_rec               EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_direct_items_tbl     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
        l_x_eam_wo_rec             EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_x_eam_op_tbl             EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_x_eam_op_network_tbl     EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_x_eam_res_tbl            EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_x_eam_res_inst_tbl       EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_x_eam_sub_res_tbl        EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_x_eam_res_usage_tbl      EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_x_eam_mat_req_tbl        EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_x_eam_direct_items_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_x_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

        l_return_status            VARCHAR2(10);
        l_msg_count                NUMBER;
        l_debug                    VARCHAR2(2);
        l_output_dir               VARCHAR2(240);
        l_debug_filename           VARCHAR2(512);
        l_debug_file_mode          VARCHAR2(2);

        l_user_id                  number;
        l_resp_id                  number := 111;
        l_resp_appl_id             number := 426;

	l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

      BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT create_eam_wo;

     -- validate and set the user context
        l_user_id := return_user_id(p_user_name);


        if (l_user_id <> -1) then
                fnd_global.apps_initialize
                (
                        user_id => l_user_id,
                        resp_id => l_resp_id,
                        resp_appl_id => l_resp_appl_id
                );
        else
                 RAISE fnd_api.g_exc_unexpected_error;
        end if;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call(
               l_api_version
              ,p_api_version
              ,l_api_name
              ,g_pkg_name) THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF fnd_api.to_boolean(p_init_msg_list) THEN
           fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        -- API body

        l_bo_identifier            := p_bo_identifier;
        l_api_version_number       := p_api_version;
        l_init_msg_list            := p_init_msg_list;
        l_commit                   := p_commit;

        l_external_source_name     := p_external_source_name;
        l_external_linear_type     := p_external_linear_type;
        l_external_linear_name     := p_external_linear_name;
        l_external_linear_id       := p_external_linear_id;

        l_eam_wo_rec               := p_eam_wo_rec;
        l_eam_op_tbl               := p_eam_op_tbl;
        l_eam_op_network_tbl       := p_eam_op_network_tbl;
        l_eam_res_tbl              := p_eam_res_tbl;
        l_eam_res_inst_tbl         := p_eam_res_inst_tbl;
        l_eam_sub_res_tbl          := p_eam_sub_res_tbl;
        l_eam_res_usage_tbl        := p_eam_res_usage_tbl;
        l_eam_mat_req_tbl          := p_eam_mat_req_tbl;
        l_eam_direct_items_tbl     := p_eam_direct_items_tbl;

        l_debug                    := p_debug;
        l_output_dir               := p_output_dir;
        l_debug_filename           := p_debug_filename;
        l_debug_file_mode          := p_debug_file_mode;


	     eam_linear_locations_pub.get_eam_linear_id(
	 		 p_api_version          => p_api_version
			,p_init_msg_list        => p_init_msg_list
			,p_validation_level     => p_validation_level
			,p_external_linear_id   => p_external_linear_id
			,p_external_source_name => p_external_source_name
			,p_external_linear_type => p_external_linear_type
			,x_eam_linear_id        => l_x_eam_linear_id
			,x_return_status        => l_x_return_status
			,x_msg_count            => l_x_msg_count
	        	,x_msg_data             => l_x_msg_data
		);

		-- if asset does not exist in  ELL, then insert row and get EAM linear id
		if (l_x_eam_linear_id = -1) then
			  eam_linear_locations_pub.insert_row(
			      p_api_version          => p_api_version
			     ,p_init_msg_list        => p_init_msg_list
			     ,p_commit              => p_commit
			     ,p_validation_level     => p_validation_level
			     ,p_external_linear_id   => p_external_linear_id
			     ,p_external_linear_name => p_external_linear_name
			     ,p_external_source_name => p_external_source_name
			     ,p_external_linear_type => p_external_linear_type
			     ,x_eam_linear_id        => l_x_eam_linear_id
			     ,x_return_status        => l_x_return_status
			     ,x_msg_count            => l_x_msg_count
			     ,x_msg_data             => l_x_msg_data
			  ) ;
		end if;

                l_eam_wo_rec  :=  p_eam_wo_rec;
		l_eam_wo_rec.eam_linear_location_id := l_x_eam_linear_id;


                -- If the external source has not passed a WAC, then default it
                if l_eam_wo_rec.class_code is null then

                       -- First get the asset number for the maintenance_object_id
                       -- if it has not been passed.
                       if l_eam_wo_rec.asset_number is null then
                         select serial_number into l_eam_wo_rec.asset_number
                           from mtl_serial_numbers
                           where gen_object_id = l_eam_wo_rec.maintenance_object_id
                           and current_organization_id = l_eam_wo_rec.organization_id;
                       end if;

                       WIP_EAM_UTILS.DEFAULT_ACC_CLASS(
                         p_org_id            => l_eam_wo_rec.organization_id,
                         p_job_type          => 1,
                         p_serial_number     => l_eam_wo_rec.asset_number,
                         p_asset_group_id    => l_eam_wo_rec.asset_group_id,
                         p_parent_wo_id      => l_eam_wo_rec.parent_wip_entity_id,
                         p_asset_activity_id => l_eam_wo_rec.asset_activity_id,
                         p_project_id        => l_eam_wo_rec.project_id,
                         p_task_id           => l_eam_wo_rec.task_id,
                         x_class_code        => l_class_code,
                         x_return_status     => l_x_return_status,
                         x_msg_data          => l_x_msg_data
                        );

                       l_eam_wo_rec.class_code := l_class_code;

                end if;


        if p_debug = fnd_api.g_false then l_debug := 'N';
        else l_debug := 'Y';end if;
        if p_commit = fnd_api.g_false then l_commit := 'N';
        else l_commit := 'Y';end if;

        EAM_PROCESS_WO_PUB.PROCESS_WO
        (  p_bo_identifier           => l_bo_identifier
         , p_api_version_number      => l_api_version_number
         , p_init_msg_list           => fnd_api.to_boolean(l_init_msg_list)
         , p_commit                  => l_commit
         , p_eam_wo_rec              => l_eam_wo_rec
         , p_eam_op_tbl              => l_eam_op_tbl
         , p_eam_op_network_tbl      => l_eam_op_network_tbl
         , p_eam_res_tbl             => l_eam_res_tbl
         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
         , p_eam_direct_items_tbl    => l_eam_direct_items_tbl
	 , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
	, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
	, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
	, p_eam_counter_prop_tbl    => l_x_eam_counter_prop_tbl
	, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
	, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
	, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
	, p_eam_request_tbl          => l_eam_request_tbl
         , x_eam_wo_rec              => l_x_eam_wo_rec
         , x_eam_op_tbl              => l_x_eam_op_tbl
         , x_eam_op_network_tbl      => l_x_eam_op_network_tbl
         , x_eam_res_tbl             => l_x_eam_res_tbl
         , x_eam_res_inst_tbl        => l_x_eam_res_inst_tbl
         , x_eam_sub_res_tbl         => l_x_eam_sub_res_tbl
         , x_eam_res_usage_tbl       => l_x_eam_res_usage_tbl
         , x_eam_mat_req_tbl         => l_x_eam_mat_req_tbl
         , x_eam_direct_items_tbl    => l_x_eam_direct_items_tbl
	  , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
	 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
	 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
	 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
	 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
	 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
	 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
	 , x_eam_request_tbl          => l_out_eam_request_tbl
         , x_return_status           => x_return_status
         , x_msg_count               => x_msg_count
         , p_debug                   => l_debug
         , p_output_dir              => l_output_dir
         , p_debug_filename          => l_debug_filename
         , p_debug_file_mode         => l_debug_file_mode
         );

         if x_return_status <> 'S' and x_msg_count > 0 then
             fnd_msg_pub.get(p_msg_index => FND_MSG_PUB.G_NEXT,
                             p_encoded   => 'F',
                             p_data      => x_msg_data,
                             p_msg_index_out => l_count);
         end if;

         x_wip_entity_id           := l_x_eam_wo_rec.wip_entity_id;
         x_eam_wo_rec              := l_x_eam_wo_rec;
         x_eam_op_tbl              := l_x_eam_op_tbl;
         x_eam_op_network_tbl      := l_x_eam_op_network_tbl;
         x_eam_res_tbl             := l_x_eam_res_tbl;
         x_eam_res_inst_tbl        := l_x_eam_res_inst_tbl;
         x_eam_sub_res_tbl         := l_x_eam_sub_res_tbl;
         x_eam_res_usage_tbl       := l_x_eam_res_usage_tbl;
         x_eam_mat_req_tbl         := l_x_eam_mat_req_tbl;
         x_eam_direct_items_tbl    := l_x_eam_direct_items_tbl;



     --END API body
     -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
          		COMMIT WORK;
     	END IF;
          -- Standard call to get message count and if count is 1, get message info.
          fnd_msg_pub.count_and_get(p_count => x_msg_count
                                   ,p_data => x_msg_data);
        EXCEPTION
           WHEN fnd_api.g_exc_error THEN
              ROLLBACK TO create_eam_wo;
              x_return_status := fnd_api.g_ret_sts_error;
              fnd_msg_pub.count_and_get(p_count => x_msg_count
                                       ,p_data => x_msg_data);
           WHEN fnd_api.g_exc_unexpected_error THEN
              ROLLBACK TO create_eam_wo;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
              fnd_msg_pub.count_and_get(p_count => x_msg_count
                                       ,p_data => x_msg_data);
           WHEN OTHERS THEN
              ROLLBACK TO create_eam_wo;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
              END IF;
              fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);

   end create_eam_wo;

    procedure return_bom_departments
    (		p_organization_id in number
    		,p_user_name 	in VARCHAR2
               ,x_bom_departments_table out nocopy eam_linear_locations_pub.bom_departments_table
    ) is
    l_user_id number;
    l_resp_id	number;
    l_resp_appl_id number;
    l_dept_index binary_integer;

    cursor dept_cursor (p_organization_id in number) is
    select  department_id, department_code,description,organization_id
    from bom_departments
    where organization_id = p_organization_id
	and nvl(disable_date, sysdate+1) >= sysdate;

    begin

    	if (check_valid_user(p_user_name) <> -1) then

    		l_user_id := return_user_id(p_user_name);
/*
    		fnd_global.apps_initialize
    		(
			user_id => l_user_id,
			resp_id => l_resp_id,
			resp_appl_id => l_resp_appl_id
		);
*/
		l_dept_index := 1;

    		FOR l_bom_dept_row in dept_cursor(p_organization_id) LOOP
    			x_bom_departments_table(l_dept_index).Department_Id := l_bom_dept_row.department_id;
    			x_bom_departments_table(l_dept_index).Department_Code := l_bom_dept_row.department_Code;
    			x_bom_departments_table(l_dept_index).Description := l_bom_dept_row.Description;
    			x_bom_departments_table(l_dept_index).Organization_Id := l_bom_dept_row.Organization_Id;
    			l_dept_index := l_dept_index + 1;
    		END LOOP;
        end if;

    end return_bom_departments;

    Procedure return_organizations
    (
             	p_user_name		VARCHAR2
             	,x_organizations_table	OUT NOCOPY EAM_LINEAR_LOCATIONS_PUB.Org_Access_Table
    )
    is
    	l_user_id	number;
    	l_organizations_index binary_integer;

    cursor org_cursor is
    	select distinct(hou.organization_id) org_id, mp.organization_code org_code,hout.name org_name
 from hr_all_organization_units hou,
  hr_all_organization_units_tl hout,
  mtl_parameters mp,wip_eam_parameters wep
where hou.organization_id =  mp.organization_id
and hou.organization_id = hout.organization_id
and hou.organization_id =  wep.organization_id
AND hout.LANGUAGE = USERENV('LANG')
and    NVL(mp.eam_enabled_flag,'N') = 'Y';


    begin
    	l_user_id := check_valid_user(p_user_name);

    	l_organizations_index := 1;
    	if (l_user_id <> -1) then
	    	FOR l_org_row	IN org_cursor
	    	LOOP
	    		x_organizations_table(l_organizations_index).Organization_Id := l_org_row.Org_Id;
	    		x_organizations_table(l_organizations_index).Organization_Code := l_org_row.Org_Code;
	    		x_organizations_table(l_organizations_index).Organization_Name := l_org_row.Org_Name;
	    		l_organizations_index := l_organizations_index + 1;
	    	END LOOP;


        end if;

    end return_organizations;



	Procedure return_work_request_details
	(
		p_user_name	VARCHAR2
		, p_work_request_id number
		, x_work_request_table OUT NOCOPY EAM_LINEAR_LOCATIONS_PUB.Work_Request_Table
	)

    is
    	l_user_id	number;
    	l_wr_index binary_integer;
	l_lang		varchar2(10);
	l_resp 		varchar2(35);
	l_resp_id 	number;
	l_appl_id 	number;

    cursor wr_cursor(resp in number, appl in number) is
    	select wewr.work_request_number work_request_number, wewr.asset_number asset_number,
		oav.organization_code organization_code, oav.organization_name organization_name,
                ml.meaning work_request_status, ml1.meaning work_request_priority,
		bd.department_code owning_dept_code, bd.description owning_dept_description,
		we.wip_entity_name work_order, wewr.description description,
		wewr.expected_resolution_date expected_resolution_date,
		ml2.meaning work_request_type, wewr.phone_number phone_number,
		wewr.e_mail e_mail, wewr.contact_preference contact_preference
	from   org_access_view oav, mfg_lookups ml, mfg_lookups ml1,
		mfg_lookups ml2,  wip_eam_work_requests wewr, wip_entities we,
		bom_departments bd
	where  wewr.work_request_id = p_work_request_id
	and oav.organization_id = wewr.organization_id
	and oav.resp_application_id = appl
	and oav.responsibility_id = resp
	and ml.lookup_type(+) = 'WIP_EAM_WORK_REQ_STATUS'
	and ml.lookup_code(+) = wewr.work_request_status_id
	and ml1.lookup_type(+) = 'WIP_EAM_ACTIVITY_PRIORITY'
	and ml1.lookup_code(+) = wewr.work_request_priority_id
	and ml2.lookup_type(+) = 'WIP_EAM_WORK_REQ_TYPE'
	and ml2.lookup_code(+) = wewr.work_request_type_id
	and bd.department_id(+) = wewr.work_request_owning_dept
	and we.wip_entity_id(+) = wewr.wip_entity_id;




    begin
    	l_user_id := check_valid_user(p_user_name);
	l_appl_id := 426;
	l_lang := 'US';
	l_resp := 'Linear Asset Management User';

	select responsibility_id
	into l_resp_id
	from fnd_responsibility_tl
	where responsibility_name = l_resp
	and application_id = l_appl_id
	and language = l_lang;

    	l_wr_index := 1;
    	if (l_user_id <> -1) then
	    	FOR l_wr_row	IN wr_cursor(l_resp_id, l_appl_id)
	    	LOOP
	    		x_work_request_table(l_wr_index).Work_Request_Number := l_wr_row.Work_Request_Number;
	    		x_work_request_table(l_wr_index).Asset_Number := l_wr_row.Asset_Number;
	    		x_work_request_table(l_wr_index).ORGANIZATION_CODE := l_wr_row.ORGANIZATION_CODE;
	    		x_work_request_table(l_wr_index).ORGANIZATION_NAME := l_wr_row.ORGANIZATION_NAME;
	    		x_work_request_table(l_wr_index).work_request_status := l_wr_row.work_request_status;
	    		x_work_request_table(l_wr_index).work_request_priority := l_wr_row.work_request_priority;
	    		x_work_request_table(l_wr_index).owning_dept_code := l_wr_row.owning_dept_code;
	    		x_work_request_table(l_wr_index).owning_dept_description := l_wr_row.owning_dept_description;
	    		x_work_request_table(l_wr_index).EXPECTED_RESOLUTION_DATE := l_wr_row.EXPECTED_RESOLUTION_DATE;
	    		x_work_request_table(l_wr_index).work_order := l_wr_row.work_order;
	    		x_work_request_table(l_wr_index).DESCRIPTION := l_wr_row.DESCRIPTION;
	    		x_work_request_table(l_wr_index).WORK_REQUEST_TYPE := l_wr_row.WORK_REQUEST_TYPE;
	    		x_work_request_table(l_wr_index).PHONE_NUMBER := l_wr_row.PHONE_NUMBER;
	    		x_work_request_table(l_wr_index).E_MAIL := l_wr_row.E_MAIL;
	    		x_work_request_table(l_wr_index).CONTACT_PREFERENCE := l_wr_row.CONTACT_PREFERENCE;
	    		l_wr_index := l_wr_index + 1;
	    	END LOOP;

        end if;

    end return_work_request_details;




	Procedure return_work_order_details
	(
		p_user_name	VARCHAR2
		, p_wip_entity_id number
		, x_work_order_rec OUT NOCOPY EAM_LINEAR_LOCATIONS_PUB.Work_Order_Record
	)

        IS

           l_user_id       number;

        BEGIN

          l_user_id := check_valid_user(p_user_name);

          if (l_user_id <> -1) then


                SELECT   we.wip_entity_name
                       , wdj.wip_entity_id
                       , wdj.organization_id
                       , wdj.description
                       , wdj.asset_number
                       , wdj.asset_group_id
                       , wdj.rebuild_item_id
                       , wdj.rebuild_serial_number
                       , we.gen_object_id
                       , wdj.maintenance_object_id
                       , wdj.maintenance_object_type
                       , wdj.maintenance_object_source
                       , wdj.eam_linear_location_id
                       , wdj.class_code
                       , wdj.primary_item_id
                       , wdj.activity_type
                       , wdj.activity_cause
                       , wdj.activity_source
                       , wdj.work_order_type
                       , wdj.status_type
                       , ml.meaning as wo_status
                       , wdj.start_quantity
                       , wdj.date_released
                       , wdj.owning_department
                       , wdj.priority
                       , wdj.requested_start_date
                       , wdj.due_date
                       , wdj.shutdown_type
                       , wdj.firm_planned_flag
                       , wdj.notification_required
                       , wdj.tagout_required
                       , wdj.plan_maintenance
                       , wdj.project_id
                       , wdj.task_id
                       , wdj.end_item_unit_number
                       , wdj.schedule_group_id
                       , wdj.bom_revision_date
                       , wdj.routing_revision_date
                       , wdj.alternate_routing_designator
                       , wdj.alternate_bom_designator
                       , wdj.routing_revision
                       , wdj.bom_revision
                       , wdj.parent_wip_entity_id
                       , wdj.manual_rebuild_flag
                       , wdj.pm_schedule_id
                       , wdj.material_account
                       , wdj.material_overhead_account
                       , wdj.resource_account
                       , wdj.outside_processing_account
                       , wdj.material_variance_account
                       , wdj.resource_variance_account
                       , wdj.outside_proc_variance_account
                       , wdj.std_cost_adjustment_account
                       , wdj.overhead_account
                       , wdj.overhead_variance_account
                       , wdj.scheduled_start_date
                       , wdj.scheduled_completion_date
                       , wdj.common_bom_sequence_id
                       , wdj.common_routing_sequence_id
                       , wdj.po_creation_time
                       , wdj.attribute_category
                       , wdj.attribute1
                       , wdj.attribute2
                       , wdj.attribute3
                       , wdj.attribute4
                       , wdj.attribute5
                       , wdj.attribute6
                       , wdj.attribute7
                       , wdj.attribute8
                       , wdj.attribute9
                       , wdj.attribute10
                       , wdj.attribute11
                       , wdj.attribute12
                       , wdj.attribute13
                       , wdj.attribute14
                       , wdj.attribute15
                       , wdj.material_issue_by_mo
                       , wdj.source_line_id
                       , wdj.source_code
                       , wdj.issue_zero_cost_flag
                INTO
                         x_work_order_rec.wip_entity_name
                       , x_work_order_rec.wip_entity_id
                       , x_work_order_rec.organization_id
                       , x_work_order_rec.description
                       , x_work_order_rec.asset_number
                       , x_work_order_rec.asset_group_id
                       , x_work_order_rec.rebuild_item_id
                       , x_work_order_rec.rebuild_serial_number
                       , x_work_order_rec.gen_object_id
                       , x_work_order_rec.maintenance_object_id
                       , x_work_order_rec.maintenance_object_type
                       , x_work_order_rec.maintenance_object_source
                       , x_work_order_rec.eam_linear_location_id
                       , x_work_order_rec.class_code
                       , x_work_order_rec.asset_activity_id
                       , x_work_order_rec.activity_type
                       , x_work_order_rec.activity_cause
                       , x_work_order_rec.activity_source
                       , x_work_order_rec.work_order_type
                       , x_work_order_rec.status_type
                       , x_work_order_rec.wo_status
                       , x_work_order_rec.job_quantity
                       , x_work_order_rec.date_released
                       , x_work_order_rec.owning_department
                       , x_work_order_rec.priority
                       , x_work_order_rec.requested_start_date
                       , x_work_order_rec.due_date
                       , x_work_order_rec.shutdown_type
                       , x_work_order_rec.firm_planned_flag
                       , x_work_order_rec.notification_required
                       , x_work_order_rec.tagout_required
                       , x_work_order_rec.plan_maintenance
                       , x_work_order_rec.project_id
                       , x_work_order_rec.task_id
                       , x_work_order_rec.end_item_unit_number
                       , x_work_order_rec.schedule_group_id
                       , x_work_order_rec.bom_revision_date
                       , x_work_order_rec.routing_revision_date
                       , x_work_order_rec.alternate_routing_designator
                       , x_work_order_rec.alternate_bom_designator
                       , x_work_order_rec.routing_revision
                       , x_work_order_rec.bom_revision
                       , x_work_order_rec.parent_wip_entity_id
                       , x_work_order_rec.manual_rebuild_flag
                       , x_work_order_rec.pm_schedule_id
                       , x_work_order_rec.material_account
                       , x_work_order_rec.material_overhead_account
                       , x_work_order_rec.resource_account
                       , x_work_order_rec.outside_processing_account
                       , x_work_order_rec.material_variance_account
                       , x_work_order_rec.resource_variance_account
                       , x_work_order_rec.outside_proc_variance_account
                       , x_work_order_rec.std_cost_adjustment_account
                       , x_work_order_rec.overhead_account
                       , x_work_order_rec.overhead_variance_account
                       , x_work_order_rec.scheduled_start_date
                       , x_work_order_rec.scheduled_completion_date
                       , x_work_order_rec.common_bom_sequence_id
                       , x_work_order_rec.common_routing_sequence_id
                       , x_work_order_rec.po_creation_time
                       , x_work_order_rec.attribute_category
                       , x_work_order_rec.attribute1
                       , x_work_order_rec.attribute2
                       , x_work_order_rec.attribute3
                       , x_work_order_rec.attribute4
                       , x_work_order_rec.attribute5
                       , x_work_order_rec.attribute6
                       , x_work_order_rec.attribute7
                       , x_work_order_rec.attribute8
                       , x_work_order_rec.attribute9
                       , x_work_order_rec.attribute10
                       , x_work_order_rec.attribute11
                       , x_work_order_rec.attribute12
                       , x_work_order_rec.attribute13
                       , x_work_order_rec.attribute14
                       , x_work_order_rec.attribute15
                       , x_work_order_rec.material_issue_by_mo
                       , x_work_order_rec.source_line_id
                       , x_work_order_rec.source_code
                       , x_work_order_rec.issue_zero_cost_flag
                FROM  wip_discrete_jobs wdj, wip_entities we, mfg_lookups ml
                WHERE wdj.wip_entity_id = we.wip_entity_id
                AND   wdj.organization_id = we.organization_id
                AND   wdj.wip_entity_id = p_wip_entity_id
                AND   wdj.status_type = ml.lookup_code
                AND   ml.lookup_type = 'WIP_JOB_STATUS';

          end if;

        END;




END eam_linear_locations_pub;

/
