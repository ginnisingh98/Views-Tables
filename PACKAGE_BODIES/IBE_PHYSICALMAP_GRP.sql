--------------------------------------------------------
--  DDL for Package Body IBE_PHYSICALMAP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PHYSICALMAP_GRP" AS
/* $Header: IBEGPSLB.pls 120.2 2005/10/19 14:08:48 abhandar ship $ */
g_yes VARCHAR2(1) := 'Y';
g_no VARCHAR2(1) := 'N';

---------------------------------------------------------------------
-- PROCEDURE
--	save_physicalmap
--
-- PURPOSE
--   Save a collection of physical_site_language mappings for a physical
--	attachment and one mini-site
--
-- PARAMETERS
--	p_attachment_id: the associated attachment
--	p_msite_id: the associated mini-site
--	p_language_code_tbl: A collection of associated language codes for the
--		the given physical attachment and mini-site
--
-- NOTES
--   1. Raises an exception if the api_version is not valid
--   2. Raises an exception if the attachment or mini-site doesn't exist
--   3. First delete all the records in IBE_LGL_PHYS_MAP for the given
--	   attachment and mini-site; then insert a record into
--	   IBE_LGL_PHYS_MAP for each language_code in
--	   p_language_code_tbl which is supported at the given site
--   4. Raises an exception if there is any duplicate mappings defined
--	   for the same logical deliverable - roll back
--   5. Ignore the non-existent or the non-supported language code
--	   for the given site; pass out a warning message
--   6. Raise an exception for any other errors
---------------------------------------------------------------------
PROCEDURE save_physicalmap (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	p_attachment_id		IN	NUMBER,
	p_msite_id			IN	NUMBER,
	p_language_code_tbl		IN	LANGUAGE_CODE_TBL_TYPE) IS

	l_api_name CONSTANT VARCHAR2(30) := 'save_physicalmap';
	l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

	l_msite_type VARCHAR2(10);
	l_default_msite VARCHAR2(1);
	l_default_lang VARCHAR2(1);

	l_deliverable_id NUMBER;
	l_msite_id NUMBER;
	l_language_code VARCHAR2(4);
	l_lgl_phys_map_id NUMBER;

	l_index NUMBER;
    l_seed_data_exists Boolean := false;

   	CURSOR lgl_phys_map_id_seq IS
		SELECT IBE_DSP_LGL_PHYS_MAP_S1.NEXTVAL FROM DUAL;

BEGIN

   	-- Standard start of API savepoint
   	SAVEPOINT save_physicalmap_grp;
	l_msite_type := 'SITE';
	l_default_msite := g_no;
	l_default_lang := g_no;

   	-- Standard call to check for call compatibility
   	IF NOT FND_API.compatible_api_call(
         g_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   	) THEN
      	RAISE FND_API.g_exc_unexpected_error;
   	END IF;

   	-- Initialize message list if p_init_msg_list is set to TRUE
   	IF FND_API.to_boolean(p_init_msg_list) THEN
      	FND_MSG_PUB.initialize;
   	END IF;

   	-- Initialize API rturn status to success
   	x_return_status := FND_API.g_ret_sts_success;

   	-- API body

   	-- Check if the attachment id exists
	l_deliverable_id := IBE_DSPMGRVALIDATION_GRP.check_attachment_deliverable(
		p_attachment_id);
	IF l_deliverable_id IS NULL THEN
		RAISE FND_API.g_exc_error;
	END IF;

	-- Check if the mini-site id exists
	l_msite_id := p_msite_id;
	IF p_msite_id IS NOT NULL THEN
		IF NOT IBE_DSPMGRVALIDATION_GRP.check_msite_exists(p_msite_id) THEN
			RAISE FND_API.g_exc_error;
		END IF;

		-- Delete all the existing mappings
		DELETE FROM IBE_DSP_LGL_PHYS_MAP
			WHERE ( (attachment_id = p_attachment_id)
			AND (default_site = l_default_msite)
			AND (msite_id = p_msite_id) );
	ELSE
		l_msite_type := 'ALLSITES';
		l_default_msite := g_yes;

		l_msite_id := IBE_DSPMGRVALIDATION_GRP.check_master_msite_exists;
		IF l_msite_id IS NULL THEN
			RAISE FND_API.g_exc_error;
		END IF;

        -- Added by YAXU, check if the seeded physicalMap exists
    	IF p_language_code_tbl IS NOT NULL THEN
		    l_language_code := TRIM(p_language_code_tbl(1));
   		    IF l_language_code IS NULL THEN
              l_seed_data_exists := true;
              BEGIN
               SELECT lgl_phys_map_id  INTO l_lgl_phys_map_id
               FROM  IBE_DSP_LGL_PHYS_MAP
               WHERE attachment_id = p_attachment_id
			   AND default_site = g_yes
               AND default_language = g_yes
               AND lgl_phys_map_id < 10000;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
               l_seed_data_exists := false;
             END;
            END IF;
         END IF;


		-- Delete all the existing mappings
       IF l_seed_data_exists = false THEN -- Added by YAXU, don't delete the seeded physicalMap
		DELETE FROM IBE_DSP_LGL_PHYS_MAP
			WHERE ( (attachment_id = p_attachment_id)
			AND (default_site = g_yes)
            AND (lgl_phys_map_id > 10000) );
       END IF;
	END IF;

	-- Check if the language code exists or supported at the given mini-site

	IF p_language_code_tbl IS NOT NULL THEN
		l_language_code := TRIM(p_language_code_tbl(1));
		IF l_language_code IS NULL THEN
			-- temporarily using US. change later
			l_language_code := 'US';
			l_default_lang := g_yes;

          IF l_seed_data_exists = false THEN  -- Added by YAXU, don't insert the seeded physicalMap again
          	OPEN lgl_phys_map_id_seq;
			FETCH lgl_phys_map_id_seq INTO l_lgl_phys_map_id;
			CLOSE lgl_phys_map_id_seq;

			INSERT INTO IBE_DSP_LGL_PHYS_MAP (
				lgl_phys_map_id,
				object_version_number,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				msite_id,
				language_code,
				attachment_id,
				item_id,
				default_site,
				default_language
			) VALUES (
				l_lgl_phys_map_id,
				1,
				SYSDATE,
				FND_GLOBAL.user_id,
				SYSDATE,
				FND_GLOBAL.user_id,
				FND_GLOBAL.login_id,
				l_msite_id,
				l_language_code,
				p_attachment_id,
				l_deliverable_id,
				l_default_msite,
				l_default_lang);
          END IF;
		ELSE
			FOR l_index IN 1..p_language_code_tbl.COUNT LOOP
			BEGIN

				SAVEPOINT save_one_physicalmap_grp;

				-- Check if the language is supported at the given site
				IF (l_msite_type = 'SITE') THEN
					IF NOT IBE_DSPMGRVALIDATION_GRP.check_language_supported(
						p_msite_id,
						p_language_code_tbl(l_index)) THEN
						RAISE FND_API.g_exc_error;
					END IF;
		    		END IF;

	        		OPEN lgl_phys_map_id_seq;
	        		FETCH lgl_phys_map_id_seq INTO l_lgl_phys_map_id;
	        		CLOSE lgl_phys_map_id_seq;

				INSERT INTO IBE_DSP_LGL_PHYS_MAP (
		    			lgl_phys_map_id,
					object_version_number,
		    			last_update_date,
		    			last_updated_by,
		    			creation_date,
		    			created_by,
		    			last_update_login,
		    			msite_id,
		    			language_code,
		    			attachment_id,
					item_id,
					default_site,
					default_language
	    			) VALUES (
		    			l_lgl_phys_map_id,
					1,
		    			SYSDATE,
		    			FND_GLOBAL.user_id,
		    			SYSDATE,
		    			FND_GLOBAL.user_id,
		    			FND_GLOBAL.login_id,
		    			l_msite_id,
					p_language_code_tbl(l_index),
					p_attachment_id,
					l_deliverable_id,
					l_default_msite,
					l_default_lang
	    			);

			EXCEPTION

				WHEN FND_API.g_exc_error THEN
					ROLLBACK TO save_one_physicalmap_grp;
					IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
						x_return_status := FND_API.g_ret_sts_error;
					END IF;

				WHEN dup_val_on_index THEN
					ROLLBACK TO save_one_physicalmap_grp;
					IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
						x_return_status := FND_API.g_ret_sts_error;
					END IF;
					IF FND_MSG_PUB.check_msg_level(
						FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
						FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);

						IF l_default_msite = g_yes THEN
							FND_MESSAGE.set_name(
								'IBE',
								'IBE_DSP_PHYSMAP_ALL_LNG_EXISTS');
							FND_MESSAGE.set_token(
								'LANG',
								p_language_code_tbl(l_index));
						ELSE
							FND_MESSAGE.set_name(
								'IBE',
								'IBE_DSP_PHYSMAP_EXISTS');
							FND_MESSAGE.set_token(
								'MSITE_ID',
								TO_CHAR(l_msite_id));
							FND_MESSAGE.set_token(
								'LANG',
								p_language_code_tbl(l_index));
						END IF;
						FND_MESSAGE.set_token(
							'ID',
							TO_CHAR(l_deliverable_id));
						FND_MSG_PUB.add;
					END IF;

				WHEN OTHERS THEN
					ROLLBACK TO save_one_physicalmap_grp;
					x_return_status := FND_API.g_ret_sts_unexp_error ;

					IF FND_MSG_PUB.check_msg_level(
						FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
						FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
					END IF;

			END;
			END LOOP;
	    END IF;

	END IF;

	-- Check if the caller requested to commit ,
	-- If p_commit set to true, commit the transaction
	IF  FND_API.to_boolean(p_commit) THEN
		COMMIT;
	END IF;

     -- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
		p_encoded      =>   FND_API.g_false,
		p_count        =>   x_msg_count,
		p_data         =>   x_msg_data
	);


EXCEPTION

     WHEN FND_API.g_exc_error THEN
		ROLLBACK TO save_physicalmap_grp;
		x_return_status := FND_API.g_ret_sts_error;
		FND_MSG_PUB.count_and_get(
			p_encoded      =>   FND_API.g_false,
			p_count        =>   x_msg_count,
			p_data         =>   x_msg_data
		);

	WHEN FND_API.g_exc_unexpected_error THEN
		ROLLBACK TO save_physicalmap_grp;
		x_return_status := FND_API.g_ret_sts_unexp_error;
		FND_MSG_PUB.count_and_get(
			p_encoded      =>   FND_API.g_false,
			p_count        =>   x_msg_count,
			p_data         =>   x_msg_data
		);

	WHEN dup_val_on_index THEN
		ROLLBACK TO save_physicalmap_grp;
		x_return_status := FND_API.g_ret_sts_error;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);

            --added by YAXU on 08/02/2002
	       IF l_default_msite = g_yes and l_default_lang = g_yes THEN
		 FND_MESSAGE.set_name('IBE', 'IBE_DSP_PHYSMAP_ALL_ALL_EXISTS');
               END IF;
	       IF l_default_msite = g_yes and l_default_lang = g_no THEN
	         FND_MESSAGE.set_name('IBE', 'IBE_DSP_PHYSMAP_ALL_LNG_EXISTS');
		 FND_MESSAGE.set_token('LANG', p_language_code_tbl(l_index));
               END IF;
	       IF l_default_msite = g_no and l_default_lang = g_yes THEN
		 FND_MESSAGE.set_name('IBE', 'IBE_DSP_PHYSMAP_STE_ALL_EXISTS');
		 FND_MESSAGE.set_token('MSITE_ID', TO_CHAR(l_msite_id));
               END IF;
	       IF l_default_msite = g_no and l_default_lang = g_no THEN
		 FND_MESSAGE.set_name('IBE', 'IBE_DSP_PHYSMAP_EXISTS');
		 FND_MESSAGE.set_token('LANG', p_language_code_tbl(l_index));
		 FND_MESSAGE.set_token('MSITE_ID', TO_CHAR(l_msite_id));
               END IF;
	       FND_MESSAGE.set_token('ID', TO_CHAR(l_deliverable_id));
	       FND_MSG_PUB.add;

         END IF;

          FND_MSG_PUB.count_and_get(
			p_encoded => FND_API.g_false,
			p_count   => x_msg_count,
			p_data    => x_msg_data
		);

	WHEN OTHERS THEN
		ROLLBACK TO save_physicalmap_grp;
		x_return_status := FND_API.g_ret_sts_unexp_error ;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;

      	FND_MSG_PUB.count_and_get(
            	p_encoded => FND_API.g_false,
            	p_count   => x_msg_count,
            	p_data    => x_msg_data
      	);

END save_physicalmap;


---------------------------------------------------------------------
-- PROCEDURE
--   save_physicalmap
--
-- PURPOSE
--   Save a collection of physical_site_language mappings for a physical
--   attachment and multiple mini-sites
--
-- PARAMETERS
--   p_attachment_id: the associated attachment
--	p_msite_lang_tbl: a collection of records of associated mini-site and
--		the number of language codes selected for this mini-site
--   p_language_code_tbl: A collection of associated language codes for the
--        the given physical attachment and mini-sites. The language codes
--		are grouped by associted mini-site and keep in the same order as
--		p_msite_lang_tbl
--
-- NOTES
--   1. Raises an exception if the api_version is not valid
--   2. Raises an exception if the attachment or mini-sites doesn't exist
--   3. First delete all the records in IBE_LGL_PHYS_MAP for the given
--      attachment and mini-sites; then insert a record into
--      IBE_LGL_PHYS_MAP for each language_code in
--      p_language_code_tbl which is supported at the given site
--   4. Raises an exception if there is any duplicate mappings defined
--      for the same logical deliverable - roll back
--   5. Ignore the non-existent or the non-supported language code
--      for the given site; pass out a warning message
--   6. Raise an exception for any other errors
---------------------------------------------------------------------
PROCEDURE save_physicalmap (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	p_attachment_id          IN   NUMBER,
	p_msite_lang_tbl         IN   MSITE_LANG_TBL_TYPE,
	p_language_code_tbl      IN   LANGUAGE_CODE_TBL_TYPE) IS

     l_api_name CONSTANT VARCHAR2(30) := 'save_physicalmap';
	l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

	l_deliverable_id NUMBER;

	l_language_code_tbl LANGUAGE_CODE_TBL_TYPE;
	l_return_status VARCHAR2(1) := FND_API.g_ret_sts_success;

	l_index NUMBER;
	l_index1 NUMBER;
	l_count NUMBER := 0;

	-- l_msg_data VARCHAR2(200);

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT save_physicalmap_grp;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(
		g_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	) THEN
		RAISE FND_API.g_exc_unexpected_error;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.to_boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
     END IF;

	-- Initialize API rturn status to success
	x_return_status := FND_API.g_ret_sts_success;

	-- API body

	-- Check if the input parameters are valid
	IF p_msite_lang_tbl IS NOT NULL THEN
		l_count := 0;
		FOR l_index1 IN 1..p_msite_lang_tbl.COUNT LOOP
			IF p_msite_lang_tbl(l_index1).lang_count IS NULL
				OR p_msite_lang_tbl(l_index1).lang_count < 0 THEN
				RAISE FND_API.g_exc_unexpected_error;
			END IF;

			l_count := l_count + p_msite_lang_tbl(l_index1).lang_count;
		END LOOP;

		IF l_count > 0 THEN
			IF p_language_code_tbl IS NULL OR
				l_count <> p_language_code_tbl.COUNT THEN
				RAISE FND_API.g_exc_unexpected_error;
			END IF;
		END IF;

	ELSE
		RETURN;

	END IF;

	-- Check if the attachment id exists
	l_deliverable_id := IBE_DSPMGRVALIDATION_GRP.check_attachment_deliverable(
		p_attachment_id);
	IF l_deliverable_id IS NULL THEN
		RAISE FND_API.g_exc_error;
	END IF;

	l_count := 0;
	FOR l_index1 IN 1..p_msite_lang_tbl.COUNT LOOP

		l_return_status := FND_API.g_ret_sts_success;
		l_language_code_tbl := NULL;

		IF p_msite_lang_tbl(l_index1).lang_count > 0 THEN
			/*
			l_language_code_tbl := p_language_code_tbl;
			l_language_code_tbl.DELETE(1, l_count);
			IF l_language_code_tbl.COUNT >
				p_msite_lang_tbl(l_index1).lang_count THEN
				l_language_code_tbl.DELETE(
					p_msite_lang_tbl(l_index1).lang_count + 1,
					l_language_code_tbl.COUNT);
			END IF;
			*/

			l_language_code_tbl := LANGUAGE_CODE_TBL_TYPE(
				p_language_code_tbl(l_count + 1));

			IF p_msite_lang_tbl(l_index1).lang_count > 1 THEN
				l_language_code_tbl.EXTEND(
					p_msite_lang_tbl(l_index1).lang_count - 1);
				FOR l_index IN 2..p_msite_lang_tbl(l_index1).lang_count LOOP
					l_language_code_tbl(l_index)
						:= p_language_code_tbl(l_count + l_index);
				END LOOP;
			END IF;

			l_count := l_count + p_msite_lang_tbl(l_index1).lang_count;

		END IF;

		save_physicalmap(
			p_api_version			=>	p_api_version,
			x_return_status		=>	l_return_status,
			x_msg_count			=>	x_msg_count,
			x_msg_data			=>	x_msg_data,
			p_attachment_id		=>	p_attachment_id,
			p_msite_id => p_msite_lang_tbl(l_index1).msite_id,
			p_language_code_tbl		=>	l_language_code_tbl
			);

		IF l_return_status <> FND_API.g_ret_sts_success THEN
			x_return_status := l_return_status;
		END IF;

		/*
		if p_msite_lang_tbl(l_index1).msite_id IS NULL THEN
			l_msg_data := l_msg_data || ' null';
		ELSE
			l_msg_data := l_msg_data || p_msite_lang_tbl(l_index1).msite_id;
		END IF;

		l_msg_data := l_msg_data || ' ' || l_language_code_tbl.COUNT;
		FOR l_index IN 1..l_language_code_tbl.COUNT LOOP
		-- null;
		l_msg_data := l_msg_data || ' ' || l_language_code_tbl(l_index);
		-- l_msg_data := l_msg_data || ' ' || p_language_code_tbl(l_index);
		END LOOP;
		*/

	END LOOP;

	/*
	x_msg_data := l_msg_data;
	return;
	*/

     -- Check if the caller requested to commit ,
	-- If p_commit set to true, commit the transaction
	IF  FND_API.to_boolean(p_commit) THEN
		COMMIT;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
		p_encoded      =>   FND_API.g_false,
		p_count        =>   x_msg_count,
		p_data         =>   x_msg_data
	);

EXCEPTION

	WHEN FND_API.g_exc_error THEN
		ROLLBACK TO save_physicalmap_grp;
		x_return_status := FND_API.g_ret_sts_error;
		FND_MSG_PUB.count_and_get(
			p_encoded      =>   FND_API.g_false,
			p_count        =>   x_msg_count,
			p_data         =>   x_msg_data
		);

	WHEN FND_API.g_exc_unexpected_error THEN
		ROLLBACK TO save_physicalmap_grp;
		x_return_status := FND_API.g_ret_sts_unexp_error;
		FND_MSG_PUB.count_and_get(
			p_encoded      =>   FND_API.g_false,
			p_count        =>   x_msg_count,
			p_data         =>   x_msg_data
		);

     WHEN OTHERS THEN
		ROLLBACK TO save_physicalmap_grp;
		x_return_status := FND_API.g_ret_sts_unexp_error ;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		END IF;

		FND_MSG_PUB.count_and_get(
			p_encoded => FND_API.g_false,
			p_count   => x_msg_count,
			p_data    => x_msg_data
		);

END save_physicalmap;


--------------------------------------------------------------------
-- PROCEDURE
--    delete_physicalmap
--
-- PURPOSE
--    To delete a collection of physical_site_language mappings
--
-- PARAMETERS
--    p_lgl_phys_map_id_tbl : A collection of physical_site_language mappings
--    to be deleted
--
-- NOTES
--    1. Deletes all the mappings in the table based on lgl_phys_map_id
--    2. Ignore the non-existing physical_site_language mappings; pass out
--	    a warning message
--    3. Raise an exception for any other errors
--------------------------------------------------------------------
PROCEDURE delete_physicalmap(
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	p_lgl_phys_map_id_tbl    IN   LGL_PHYS_MAP_ID_TBL_TYPE) IS

	l_api_name    CONSTANT VARCHAR2(30) := 'delete_physicalmap';
	l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

	l_index NUMBER;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT delete_physicalmap_grp;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(
         g_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
	) THEN
		RAISE FND_API.g_exc_unexpected_error;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
   	IF FND_API.to_boolean(p_init_msg_list) THEN
      	FND_MSG_PUB.initialize;
   	END IF;

   	-- Initialize API rturn status to success
   	x_return_status := FND_API.g_ret_sts_success;

	-- API body

	IF p_lgl_phys_map_id_tbl IS NOT NULL THEN
		FOR l_index IN 1..p_lgl_phys_map_id_tbl.COUNT LOOP
		BEGIN

			-- Check if the physicalMap id exists
			IF NOT IBE_DSPMGRVALIDATION_GRP.check_physicalmap_exists(
				p_lgl_phys_map_id_tbl(l_index)) THEN
				RAISE FND_API.g_exc_error;
			END IF;

			DELETE FROM IBE_DSP_LGL_PHYS_MAP
				WHERE lgl_phys_map_id = p_lgl_phys_map_id_tbl(l_index);
			IF SQL%NOTFOUND THEN
				-- RAISE IBE_DSPMGRVALIDATION_GRP.physmap_not_exists_exception;
				IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
					FND_MESSAGE.set_name('IBE', 'IBE_DSP_PHYSMAP_NOT_EXISTS');
					FND_MESSAGE.set_token(
						'ID',
						TO_CHAR(p_lgl_phys_map_id_tbl(l_index)));
					FND_MSG_PUB.add;
				END IF;
				RAISE FND_API.g_exc_error;
			END IF;

		EXCEPTION

			WHEN FND_API.g_exc_error THEN
				/*
				IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
					x_return_status := FND_API.g_ret_sts_error;
				ENF IF;
				*/
				-- only warning; no error status
				NULL;

			/*
			WHEN IBE_DSPMGRVALIDATION_GRP.physmap_not_exists_exception THEN
				-- only warning; no error
				IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
					FND_MESSAGE.set_name('IBE', 'IBE_DSP_PHYSMAP_NOT_EXISTS');
					FND_MESSAGE.set_token(
						'ID',
						TO_CHAR(p_lgl_phys_map_id_tbl(l_index)));
					FND_MSG_PUB.add;
				END IF;
			*/

			WHEN OTHERS THEN
				x_return_status := FND_API.g_ret_sts_unexp_error ;
				IF FND_MSG_PUB.check_msg_level(
					FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
					FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
				END IF;

		END;
		END LOOP;
	END IF;

	-- Check if the caller requested to commit ,
	-- If p_commit set to true, commit the transaction
	IF  FND_API.to_boolean(p_commit) THEN
	     COMMIT;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
		p_encoded      =>   FND_API.g_false,
		p_count        =>   x_msg_count,
		p_data         =>   x_msg_data
	);

EXCEPTION

	WHEN FND_API.g_exc_error THEN
    		ROLLBACK TO delete_physicalmap_grp;
		x_return_status := FND_API.g_ret_sts_error;
		FND_MSG_PUB.count_and_get(
			p_encoded => FND_API.g_false,
			p_count   => x_msg_count,
			p_data    => x_msg_data
		);

	WHEN FND_API.g_exc_unexpected_error THEN
     	ROLLBACK TO delete_physicalmap_grp;
      	x_return_status := FND_API.g_ret_sts_unexp_error ;
      	FND_MSG_PUB.count_and_get(
          	p_encoded => FND_API.g_false,
            	p_count   => x_msg_count,
            	p_data    => x_msg_data
      	);

   	WHEN OTHERS THEN
      	ROLLBACK TO delete_physicalmap_grp;
      	x_return_status := FND_API.g_ret_sts_unexp_error ;

      	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;

      	FND_MSG_PUB.count_and_get(
            	p_encoded => FND_API.g_false,
            	p_count   => x_msg_count,
            	p_data    => x_msg_data
      	);

END delete_physicalmap;


-- PROCEDURE
--    delete_attachment
--
-- PURPOSE
--    To delete all the physical_site_language_mappings for the given attachment
--
-- PARAMETERS
--    p_attachment_id : ID of the associated physical attachment
--
-- NOTES
--    1. Deletes all the mappings associated with the physical attachment
--    2. Raise an exception for any other errors
--------------------------------------------------------------------
PROCEDURE delete_attachment(
	p_attachment_id          IN   NUMBER) IS

     l_api_name    CONSTANT VARCHAR2(30) := 'delete_attachment';
	l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   	-- Standard start of API savepoint
   	SAVEPOINT delete_attachment_grp;

   	-- API body

	DELETE FROM IBE_DSP_LGL_PHYS_MAP
		WHERE attachment_id = p_attachment_id;

EXCEPTION

   	WHEN OTHERS THEN
      	ROLLBACK TO delete_attachment_grp;

      	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;

END delete_attachment;


-- PROCEDURE
--   delete_deliverable
--
-- PURPOSE
--   To delete all the physical_site_language_mappings for the given deliverable
--
-- PARAMETERS
--   p_deliverable_id: ID of the associated deliverable
--
-- NOTES
--   1. Delete all the mappings associated with the deliverable
--   2. Raise an exception for any other errors
--------------------------------------------------------------------
PROCEDURE delete_deliverable(
	p_deliverable_id         IN   NUMBER) IS

     l_api_name    CONSTANT VARCHAR2(30) := 'delete_deliverable';
	l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_attachment_id NUMBER;
    l_api_version NUMBER := 1.0;
    x_return_status VARCHAR2(1);
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);

    l_obj_ver NUMBER;


   CURSOR attachment_ids IS
    SELECT  distinct b.attachment_id
    from    ibe_dsp_lgl_phys_map a, jtf_amv_attachments b
    where   a.item_id = p_deliverable_id
    and     a.attachment_id = b.attachment_id
    and     b.attachment_used_by_id = -1
    and     (b.file_id <=0 or b.file_id is null)
    and     b.application_id = 671
    and     b.attachment_id >= 10000;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT delete_deliverable_grp;

   	-- API body

    -- delete the associated attachments if theie attachment_used_by_id = -1 and file_id is not >0
    open attachment_ids;
    fetch attachment_ids into l_attachment_id;
    while attachment_ids%found
    loop
--hft
--      delete from jtf_amv_attachments
--      where attachment_id = l_attachment_id;
         SELECT OBJECT_VERSION_NUMBER into l_obj_ver FROM JTF_AMV_ATTACHMENTS
         WHERE attachment_id = l_attachment_id;
         JTF_AMV_ATTACHMENT_PUB.delete_act_attachment(
            p_api_version		=> l_api_version,
            x_return_status	=> x_return_status,
            x_msg_count		=> x_msg_count,
            x_msg_data		=> x_msg_data,
            p_act_attachment_id	=>l_attachment_id,
            p_object_version	=>l_obj_ver);
--hft end
    fetch attachment_ids into l_attachment_id;
    end loop;
    close attachment_ids;

    -- delete the mappings
	DELETE FROM IBE_DSP_LGL_PHYS_MAP
		WHERE item_id = p_deliverable_id;

EXCEPTION

     WHEN OTHERS THEN
		ROLLBACK TO delete_deliverable_grp;

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		END IF;

END delete_deliverable;


-- PROCEDURE
-- 	delete_msite
--
-- PURPOSE
--	To delete all the physical_site_language_mappings for the given mini-site
--
-- PARAMETERS
--	p_msite_id: ID of the associated mini-site
--
-- NOTES
--	1. Delete all the mappings associated with the mini-site
--	2. Raise an exception for any other errors
--------------------------------------------------------------------
PROCEDURE delete_msite(
	p_msite_id			IN	NUMBER) IS

     l_api_name CONSTANT VARCHAR2(30) := 'delete_msite';
	l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN

	-- Standard start of API savepint
	SAVEPOINT delete_msite_grp;

	-- API body

	DELETE FROM IBE_DSP_LGL_PHYS_MAP
		WHERE ( (msite_id = p_msite_id) AND (default_site = g_no) );

EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO delete_msite_grp;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		END IF;

END delete_msite;


-- PROCEDURE
--   delete_msite_language
--
-- PURPOSE
--	To delete all the physical_site_language_mappings involved the given
--	mini-site and the languages which have been de-supported at the mini-site
--
-- PARAMETERS
--   p_msite_id: ID of the associated mini-site
--
-- NOTES
--   1. Delete all the mappings associated with the mini-site and the languages
--	   which have been de-supported
--   2. Raise an exception for any other errors
--------------------------------------------------------------------
PROCEDURE delete_msite_language(
	p_msite_id               IN   NUMBER) IS

     l_api_name CONSTANT VARCHAR2(30) := 'delete_msite_language';
	l_full_name CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

BEGIN

	-- Standard start of API savepint
	SAVEPOINT delete_msite_language_grp;

	-- API body

	DELETE FROM IBE_DSP_LGL_PHYS_MAP
		WHERE msite_id = p_msite_id
		AND default_site = g_no
		AND default_language = g_no
		AND language_code NOT IN (SELECT language_code
		FROM IBE_MSITE_LANGUAGES WHERE msite_id = p_msite_id);

EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO delete_msite_language_grp;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		END IF;

END delete_msite_language;


-- PROCEDURE
--	delete_attachment_msite
--
-- PURPOSE
--   To delete all the physical_site_language_mappings for the given mini-sites
--   and attachment
--
-- PARAMETERS
--	p_attachment_id: ID of the associated attachment
--   p_msite_id_tbl: the collction of IDs of the associated mini-sites
--
-- NOTES
--   1. Delete all the mappings associated with the mini-sites and attachment
--   2. Raise an exception for any other errors
PROCEDURE delete_attachment_msite(
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	p_attachment_id          IN   NUMBER,
	p_msite_id_tbl           IN   MSITE_ID_TBL_TYPE) IS

     l_api_name    CONSTANT VARCHAR2(30) := 'delete_attachment_msite';
	l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT delete_attachment_msite_grp;

	-- Standard call to check for call compatibility
	IF NOT FND_API.compatible_api_call(
		g_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	) THEN
		RAISE FND_API.g_exc_unexpected_error;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.to_boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API rturn status to success
	x_return_status := FND_API.g_ret_sts_success;

	-- API body

	IF p_msite_id_tbl IS NOT NULL THEN
		FOR  l_index IN 1..p_msite_id_tbl.COUNT LOOP
		BEGIN

			SAVEPOINT delete_one_ath_msite_grp;

			-- Check if it is all-sites
			IF p_msite_id_tbl(l_index) IS NULL THEN
				DELETE FROM IBE_DSP_LGL_PHYS_MAP
					WHERE ( (attachment_id = p_attachment_id)
					AND (default_site = g_yes) );
			ELSE
				DELETE FROM IBE_DSP_LGL_PHYS_MAP
					WHERE ( (attachment_id = p_attachment_id)
					AND (msite_id = p_msite_id_tbl(l_index))
					AND (default_site = g_no) );
			END IF;

		EXCEPTION

			WHEN OTHERS THEN
				ROLLBACK TO delete_one_ath_msite_grp;
				x_return_status := FND_API.g_ret_sts_unexp_error ;
				IF FND_MSG_PUB.check_msg_level(
					FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
					FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
				END IF;

		END;
		END LOOP;
	END IF;

     -- Check if the caller requested to commit ,
	-- If p_commit set to true, commit the transaction
	IF  FND_API.to_boolean(p_commit) THEN
		COMMIT;
	END IF;

	-- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
		p_encoded      =>   FND_API.g_false,
		p_count        =>   x_msg_count,
		p_data         =>   x_msg_data
	);

EXCEPTION

     WHEN FND_API.g_exc_error THEN
		ROLLBACK TO delete_attachment_msite_grp;
		x_return_status := FND_API.g_ret_sts_error;
		FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
			p_count   => x_msg_count,
			p_data    => x_msg_data
		);

	WHEN FND_API.g_exc_unexpected_error THEN
		ROLLBACK TO delete_attachment_msite_grp;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
		FND_MSG_PUB.count_and_get(
			p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
			p_data    => x_msg_data
		);

     WHEN OTHERS THEN
		ROLLBACK TO delete_attachment_msite_grp;
		x_return_status := FND_API.g_ret_sts_unexp_error ;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		END IF;

          FND_MSG_PUB.count_and_get(
			p_encoded => FND_API.g_false,
			p_count   => x_msg_count,
			p_data    => x_msg_data
		);


END delete_attachment_msite;


-- PROCEDURE
--	delete_dlv_all_all
--
-- PURPOSE
--	To delete the all-site and all-language mappings for the given deliverable
--
-- PARAMETERS
--   p_deliverable_id: ID of the associated deliverable
--
-- NOTES
--   1. Delete the all-site and all-language mappings for the given deliverable
--   2. Raise an exception for any other errors
PROCEDURE delete_dlv_all_all(
	p_deliverable_id         IN   NUMBER) IS

	l_api_name	CONSTANT VARCHAR2(30) := 'delete_dlv_all_all';
	l_full_name	CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT delete_dlv_all_all_grp;

	-- API body

	DELETE FROM IBE_DSP_LGL_PHYS_MAP
		WHERE item_id = p_deliverable_id
		AND default_site = g_yes
		AND default_language = g_yes;

EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK TO delete_dlv_all_all_grp;

		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		END IF;

END delete_dlv_all_all;


PROCEDURE save_physicalmap(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.g_false, --modified by YAXU, ewmove DEFAULT
  p_commit IN VARCHAR2 := FND_API.g_false,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  p_deliverable_id IN NUMBER,
  p_old_content_key IN VARCHAR2,
  p_new_content_key IN VARCHAR2,
  p_msite_id IN NUMBER,
  p_language_code_tbl IN LANGUAGE_CODE_TBL_TYPE)
IS
  l_api_name CONSTANT VARCHAR2(50) := 'save_physicalmap';
  l_api_version NUMBER := 1.0;

  l_ocm_integration VARCHAR2(30);
  l_msite_id NUMBER;

  l_index NUMBER;
  l_deliverable_id NUMBER;
  l_old_attachment_id NUMBER;
  l_old_content_item_key VARCHAR2(100);
  l_attachment_id NUMBER;
  l_content_item_key VARCHAR2(100);

  l_msite_type VARCHAR2(10);
  l_default_msite VARCHAR2(1);
  l_default_lang VARCHAR2(1);
  l_language_code VARCHAR2(4);
  l_lgl_phys_map_id NUMBER;
  l_index NUMBER;

  -- added by YAXU
  l_seed_lgl_phys_map_id NUMBER;
  l_seed_data_exists Boolean := false;
  l_object_version_number NUMBER;

  CURSOR lgl_phys_map_id_seq IS
    SELECT IBE_DSP_LGL_PHYS_MAP_S1.NEXTVAL FROM DUAL;
BEGIN
  SAVEPOINT SAVE_PHYSICALMAP;
  l_deliverable_id := p_deliverable_id;
  l_msite_type  := 'SITE';
  l_default_msite  := g_no;
  l_default_lang  := g_no;


  IF NOT FND_API.Compatible_API_Call(l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_ocm_integration
    := FND_PROFILE.value('IBE_M_USE_CONTENT_INTEGRATION');
  IF (l_ocm_integration IS NOT NULL)
    AND (l_ocm_integration = 'Y') THEN
    l_attachment_id := -1;
    l_content_item_key := p_new_content_key;
    l_old_attachment_id := -1;
    l_old_content_item_key := NVL(p_old_content_key,'-1');
  ELSE
    l_attachment_id := TO_NUMBER(p_new_content_key);
    l_content_item_key := NULL;
    l_old_attachment_id := TO_NUMBER(NVL(p_old_content_key,'-1'));
    l_old_content_item_key := NULL;
  END IF;

  -- Validate minisite id
  l_msite_id := p_msite_id;
  IF p_msite_id IS NOT NULL THEN
    IF NOT IBE_DSPMGRVALIDATION_GRP.check_msite_exists
	 (p_msite_id) THEN
	 RAISE FND_API.g_exc_error;
    END IF;
  ELSE
    l_msite_type := 'ALLSITES';
    l_default_msite := g_yes;
    l_msite_id :=
	 IBE_DSPMGRVALIDATION_GRP.check_master_msite_exists;
    IF l_msite_id IS NULL THEN
	 RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  IF (l_ocm_integration IS NULL)
    OR (l_ocm_integration = 'N') THEN
     -- Delete all the mappings fro the minisites, added by YAXU
     DELETE FROM IBE_DSP_LGL_PHYS_MAP
     WHERE ((item_id = l_deliverable_id)
       AND (attachment_id = l_attachment_id)
       AND (content_item_key is null)
       AND (default_site = l_default_msite)
       AND (msite_id = l_msite_id)
       AND (lgl_phys_map_id >= 10000));
  END IF;

  -- Validate language code
  IF p_language_code_tbl IS NOT NULL THEN
    l_language_code := TRIM(p_language_code_tbl(1));
    IF l_language_code IS NULL THEN
      -- temporarily using US. change later
	 IF (l_ocm_integration IS NOT NULL) AND (l_ocm_integration = 'Y') THEN
	   l_language_code := 'OCM';
      ELSE
	   l_language_code := 'US';
	 END IF;
	 l_default_lang := g_yes;

     IF(l_default_msite = g_yes) -- check if the seed default mapping exists
     THEN
         l_seed_data_exists := true;
          IF (l_ocm_integration IS NOT NULL) AND (l_ocm_integration = 'Y')
          THEN
            BEGIN
              SELECT lgl_phys_map_id, object_version_number
              INTO l_seed_lgl_phys_map_id,l_object_version_number
              FROM  IBE_DSP_LGL_PHYS_MAP
              WHERE item_id = l_deliverable_id
                AND content_item_key = l_old_content_item_key
                AND attachment_id = -1
	        AND default_site = g_yes
                AND default_language = g_yes
                AND lgl_phys_map_id < 10000;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_seed_data_exists := false;
             END;
          ELSE
            BEGIN
              SELECT lgl_phys_map_id, object_version_number
              INTO l_seed_lgl_phys_map_id,l_object_version_number
              FROM  IBE_DSP_LGL_PHYS_MAP
              WHERE item_id = l_deliverable_id
                AND attachment_id = l_attachment_id
                AND content_item_key is null
    	        AND default_site = g_yes
                AND default_language = g_yes
                AND lgl_phys_map_id < 10000;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_seed_data_exists := false;
             END;
          END IF;
     END IF;

     IF(l_seed_data_exists = false)
     THEN
       OPEN lgl_phys_map_id_seq;
	   FETCH lgl_phys_map_id_seq INTO l_lgl_phys_map_id;
	   CLOSE lgl_phys_map_id_seq;
	   INSERT INTO IBE_DSP_LGL_PHYS_MAP (
	     lgl_phys_map_id, object_version_number, last_update_date,
	     last_updated_by, creation_date, created_by,
	     last_update_login, msite_id, language_code,
	     attachment_id, item_id, default_site,
	     default_language, content_item_key)
       VALUES(l_lgl_phys_map_id, 1, SYSDATE,
	     FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.user_id,
	     FND_GLOBAL.login_id, l_msite_id, l_language_code,
	     l_attachment_id, l_deliverable_id, l_default_msite,
	     l_default_lang, l_content_item_key);
    ELSE -- update the seeded mapping
        IF((l_ocm_integration IS NOT NULL)
           AND (l_ocm_integration = 'Y')
           AND (p_old_content_key <> p_new_content_key))
        THEN
          UPDATE IBE_DSP_LGL_PHYS_MAP
          SET attachment_id = l_attachment_id,
              content_item_key = l_content_item_key,
              object_version_number = l_object_version_number+1,
              last_update_date = SYSDATE,
              last_updated_by = FND_GLOBAL.user_id,
              last_update_login = FND_GLOBAL.login_id
          WHERE lgl_phys_map_id = l_seed_lgl_phys_map_id;
        END IF;
    END IF;
    ELSE
	 FOR l_index IN 1..p_language_code_tbl.COUNT LOOP
	 BEGIN
	   SAVEPOINT SAVE_ONE_PHYSICALMAP;
	   IF (l_ocm_integration IS NOT NULL) AND (l_ocm_integration = 'Y') THEN
	     l_language_code := 'OCM';
        ELSE
	     IF (l_msite_type = 'SITE') THEN
	       -- Check if the language is supported at the given site
		  -- For OCM integration, this check is not necessary.
		  IF NOT IBE_DSPMGRVALIDATION_GRP.check_language_supported
		    (p_msite_id, p_language_code_tbl(l_index)) THEN
		    RAISE FND_API.g_exc_error;
            END IF;
          END IF;
		l_language_code := p_language_code_tbl(l_index);
        END IF;
	   OPEN lgl_phys_map_id_seq;
	   FETCH lgl_phys_map_id_seq INTO l_lgl_phys_map_id;
	   CLOSE lgl_phys_map_id_seq;
	   INSERT INTO IBE_DSP_LGL_PHYS_MAP (
		lgl_phys_map_id, object_version_number, last_update_date,
		last_updated_by, creation_date, created_by,
		last_update_login, msite_id, language_code,
		attachment_id, item_id, default_site,
		default_language, content_item_key)
        VALUES(l_lgl_phys_map_id, 1, SYSDATE,
		FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.user_id,
		FND_GLOBAL.login_id, l_msite_id, l_language_code,
		l_attachment_id, l_deliverable_id, l_default_msite,
		l_default_lang, l_content_item_key);
     EXCEPTION
		WHEN FND_API.g_exc_error THEN
		  ROLLBACK TO SAVE_ONE_PHYSICALMAP;
		  IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
			x_return_status := FND_API.g_ret_sts_error;
		  END IF;
		WHEN dup_val_on_index THEN
		  ROLLBACK TO SAVE_ONE_PHYSICALMAP;
		  IF x_return_status <> FND_API.g_ret_sts_unexp_error THEN
		    x_return_status := FND_API.g_ret_sts_error;
		  END IF;
		  IF FND_MSG_PUB.check_msg_level
		    (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
		    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		    IF l_default_msite = g_yes THEN
			 FND_MESSAGE.set_name('IBE',
			   'IBE_DSP_PHYSMAP_ALL_LNG_EXISTS');
                FND_MESSAGE.set_token('LANG',
			   p_language_code_tbl(l_index));
		    ELSE
			 FND_MESSAGE.set_name('IBE',
			   'IBE_DSP_PHYSMAP_EXISTS');
                FND_MESSAGE.set_token('MSITE_ID',
			   TO_CHAR(l_msite_id));
                FND_MESSAGE.set_token(
			   'LANG', p_language_code_tbl(l_index));
		    END IF;
		    FND_MESSAGE.set_token('ID', TO_CHAR(l_deliverable_id));
		    FND_MSG_PUB.add;
		  END IF;
		WHEN OTHERS THEN
		  ROLLBACK TO SAVE_ONE_PHYSICALMAP;
		  x_return_status := FND_API.g_ret_sts_unexp_error;
		  IF FND_MSG_PUB.check_msg_level(
		    FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
		    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		  END IF;
	 END;
	 END LOOP;
    END IF;
  END IF;
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO SAVE_PHYSICALMAP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO SAVE_PHYSICALMAP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');

    --added by YAXU on 01/02/2004
	WHEN dup_val_on_index THEN
		ROLLBACK TO SAVE_PHYSICALMAP;
		x_return_status := FND_API.g_ret_sts_error;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);

            IF l_default_msite = g_yes and l_default_lang = g_yes THEN
	    	   FND_MESSAGE.set_name('IBE', 'IBE_DSP_PHYSMAP_ALL_ALL_EXISTS');
            END IF;
     	    IF l_default_msite = g_no and l_default_lang = g_yes THEN
        	   FND_MESSAGE.set_name('IBE', 'IBE_DSP_PHYSMAP_STE_ALL_EXISTS');
		       FND_MESSAGE.set_token('MSITE_ID', TO_CHAR(l_msite_id));
            END IF;
            FND_MESSAGE.set_token('ID', TO_CHAR(l_deliverable_id));
	        FND_MSG_PUB.add;

         END IF;

          FND_MSG_PUB.count_and_get(
			p_encoded => FND_API.g_false,
			p_count   => x_msg_count,
			p_data    => x_msg_data
		);


  WHEN OTHERS THEN
    ROLLBACK TO SAVE_PHYSICALMAP;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
    FND_MESSAGE.Set_Token('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
END save_physicalmap;

PROCEDURE save_physicalmap(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.g_false, --modified by YAXU, ewmove DEFAULT
  p_commit IN VARCHAR2 := FND_API.g_false,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  p_deliverable_id IN NUMBER,
  p_old_content_key IN VARCHAR2,
  p_new_content_key IN VARCHAR2,
  p_msite_lang_tbl IN MSITE_LANG_TBL_TYPE,
  p_language_code_tbl IN LANGUAGE_CODE_TBL_TYPE)
IS
  l_api_name CONSTANT VARCHAR2(50) := 'save_physicalmap';
  l_api_version NUMBER := 1.0;

  l_count NUMBER;
  l_index NUMBER;

  l_language_code_tbl LANGUAGE_CODE_TBL_TYPE;
  l_return_status VARCHAR2(1);

  l_ocm_integration VARCHAR2(30);
  l_attachment_id NUMBER;
  l_old_attachment_id NUMBER;
  l_content_item_key VARCHAR2(100);
  l_old_content_item_key VARCHAR2(100);

BEGIN
  SAVEPOINT SAVE_PHYSICALMAP;
  l_return_status  := FND_API.g_ret_sts_success;
  IF NOT FND_API.Compatible_API_Call(l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Validate the input parameters
  IF p_msite_lang_tbl IS NOT NULL THEN
    l_count := 0;
    FOR l_index IN 1..p_msite_lang_tbl.COUNT LOOP
	 IF p_msite_lang_tbl(l_index).lang_count IS NULL
	   OR p_msite_lang_tbl(l_index).lang_count < 0 THEN
	   RAISE FND_API.g_exc_unexpected_error;
	 END IF;
	 l_count := l_count + p_msite_lang_tbl(l_index).lang_count;
    END LOOP;
    IF (l_count > 0) THEN
	 IF (p_language_code_tbl IS NULL) OR
	   l_count <> p_language_code_tbl.COUNT THEN
	   RAISE FND_API.g_exc_unexpected_error;
	 END IF;
    END IF;
  -- ELSE  -- removed by YAXU
    -- RETURN;
  END IF;

  IF (p_old_content_key IS NOT NULL) THEN
    l_ocm_integration
	 := FND_PROFILE.value('IBE_M_USE_CONTENT_INTEGRATION');
    IF (l_ocm_integration IS NOT NULL)
	 AND (l_ocm_integration = 'Y') THEN
     -- delete all the exisitng mapping for the p_old_content_key
	 l_old_content_item_key := p_old_content_key;
	 DELETE FROM IBE_DSP_LGL_PHYS_MAP
	  WHERE ((attachment_id = -1)
	    AND (item_id = p_deliverable_id)
	    AND (content_item_key = l_old_content_item_key)
            AND (lgl_phys_map_id >=10000));
    ELSE
      IF(p_old_content_key <> p_new_content_key) -- modified by YAXU to update the mapping
      THEN
   	    l_old_attachment_id := TO_NUMBER(p_old_content_key);
   	    l_attachment_id := TO_NUMBER(p_new_content_key);
        UPDATE IBE_DSP_LGL_PHYS_MAP
        set attachment_id = l_attachment_id,
            last_update_date = SYSDATE,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
        WHERE ((attachment_id = l_old_attachment_id)
	    AND  (item_id = p_deliverable_id)
            AND (content_item_key is null));
      END IF;
    END IF;
  END IF;

  -- Start saving
 IF( p_msite_lang_tbl IS NOT NULL) THEN -- added by YAXU
  l_count := 0;
  FOR l_index IN 1..p_msite_lang_tbl.COUNT LOOP
    l_return_status := FND_API.g_ret_sts_success;
    l_language_code_tbl := NULL;
    IF p_msite_lang_tbl(l_index).lang_count > 0 THEN
	 l_language_code_tbl := LANGUAGE_CODE_TBL_TYPE(
	   p_language_code_tbl(l_count + 1));
      IF p_msite_lang_tbl(l_index).lang_count > 1 THEN
	   l_language_code_tbl.EXTEND(p_msite_lang_tbl(l_index).lang_count - 1);
        FOR l_i IN 2..p_msite_lang_tbl(l_index).lang_count LOOP
		l_language_code_tbl(l_i) := p_language_code_tbl(l_count + l_i);
	   END LOOP;
	 END IF;
      l_count := l_count + p_msite_lang_tbl(l_index).lang_count;
    END IF;
    save_physicalmap(
	 p_api_version => p_api_version,
	 x_return_status => l_return_status,
	 x_msg_count => x_msg_count,
	 x_msg_data => x_msg_data,
      p_deliverable_id => p_deliverable_id,
      p_old_content_key => p_old_content_key,
      p_new_content_key => p_new_content_key,
      p_msite_id => p_msite_lang_tbl(l_index).msite_id,
      p_language_code_tbl => l_language_code_tbl);
    IF l_return_status <> FND_API.g_ret_sts_success THEN
	 x_return_status := l_return_status;
    END IF;
  END LOOP;
 END IF;

  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO SAVE_PHYSICALMAP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO SAVE_PHYSICALMAP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO SAVE_PHYSICALMAP;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
    FND_MESSAGE.Set_Token('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
END save_physicalmap;

PROCEDURE delete_physicalmap(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.g_false, --modified by YAXU, ewmove DEFAULT
  p_commit IN VARCHAR2 := FND_API.g_false,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  p_deliverable_id IN NUMBER,
  p_content_key IN VARCHAR2)
IS
  l_api_name CONSTANT VARCHAR2(50) := 'delete_physicalmap';
  l_api_version NUMBER := 1.0;

  l_ocm_integration VARCHAR2(30);
  l_deliverable_id NUMBER;
  l_attachment_id NUMBER;
  l_content_item_key VARCHAR2(100);

  l_file_id NUMBER;
  l_other_item_count NUMBER;
  l_obj_ver NUMBER;

BEGIN
  SAVEPOINT DELETE_PHYSICALMAP;
  l_deliverable_id := p_deliverable_id;
  IF NOT FND_API.Compatible_API_Call(l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_ocm_integration
    := FND_PROFILE.value('IBE_M_USE_CONTENT_INTEGRATION');
  IF (l_ocm_integration IS NOT NULL)
    AND (l_ocm_integration = 'Y') THEN
    l_content_item_key := p_content_key;
    DELETE FROM IBE_DSP_LGL_PHYS_MAP
      WHERE attachment_id = -1
        AND content_item_key = l_content_item_key
        AND item_id = l_deliverable_id;
  ELSE
    l_attachment_id := TO_NUMBER(p_content_key);
    DELETE FROM IBE_DSP_LGL_PHYS_MAP
      WHERE attachment_id = l_attachment_id
        AND content_item_key IS NULL
        AND item_id = l_deliverable_id;

    -- added by YAXU, delete the attachment if the its file_id =0 and no realted mapping
    SELECT file_id into l_file_id
    FROM JTF_AMV_ATTACHMENTS
    WHERE attachment_id = l_attachment_id;

    IF l_file_id <= 0 or l_file_id is null THEN
      SELECT count(1) into l_other_item_count
      FROM  IBE_DSP_LGL_PHYS_MAP
      WHERE attachment_id = l_attachment_id
        AND content_item_key IS NULL
        AND item_id <> l_deliverable_id;

      IF l_other_item_count = 0 THEN
         -- delete the attachment
--hft
--         DELETE FROM JTF_AMV_ATTACHMENTS
--         WHERE attachment_id = l_attachment_id;
          SELECT OBJECT_VERSION_NUMBER into l_obj_ver FROM JTF_AMV_ATTACHMENTS
            WHERE attachment_id = l_attachment_id;
          JTF_AMV_ATTACHMENT_PUB.delete_act_attachment(
            p_api_version		=> l_api_version,
            x_return_status	=> x_return_status,
            x_msg_count		=> x_msg_count,
            x_msg_data		=> x_msg_data,
            p_act_attachment_id	=>l_attachment_id,
            p_object_version	=>l_obj_ver);
--hft end
      END IF;
    END IF;

  END IF;
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_PHYSICALMAP;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_PHYSICALMAP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO DELETE_PHYSICALMAP;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
    FND_MESSAGE.Set_Token('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
END delete_physicalmap;

PROCEDURE replace_content(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.g_false, --modified by YAXU, ewmove DEFAULT
  p_commit IN VARCHAR2 := FND_API.g_false,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  p_old_content_key IN VARCHAR2,
  p_new_content_key IN VARCHAR2)
IS
  l_api_name CONSTANT VARCHAR2(50) := 'replace_content';
  l_api_version NUMBER := 1.0;

  l_ocm_integration VARCHAR2(30);
  l_attachment_id NUMBER;
  l_content_item_key VARCHAR2(100);
  l_old_attachment_id NUMBER;
  l_old_content_item_key VARCHAR2(100);
BEGIN
  SAVEPOINT REPLACE_CONTENT;
  IF NOT FND_API.Compatible_API_Call(l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_ocm_integration
    := FND_PROFILE.value('IBE_M_USE_CONTENT_INTEGRATION');
  IF (l_ocm_integration IS NOT NULL)
    AND (l_ocm_integration = 'Y') THEN
    l_content_item_key := p_new_content_key;
    l_old_content_item_key := p_old_content_key;
    UPDATE IBE_DSP_LGL_PHYS_MAP
      SET content_item_key = l_content_item_key
      WHERE content_item_key = l_old_content_item_key
        AND attachment_id = -1;
  ELSE
    l_attachment_id := TO_NUMBER(p_new_content_key);
    l_old_attachment_id := TO_NUMBER(p_old_content_key);
    UPDATE IBE_DSP_LGL_PHYS_MAP
      SET attachment_id = l_attachment_id
      WHERE attachment_id = l_old_attachment_id
        AND content_item_key IS NULL;
  END IF;
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO REPLACE_CONTENT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO REPLACE_CONTENT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO REPLACE_CONTENT;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
    FND_MESSAGE.Set_Token('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
END replace_content;



PROCEDURE LOAD_SEED_ROW(
  P_LGL_PHYS_MAP_ID          IN NUMBER,
  P_OBJECT_VERSION_NUMBER    IN NUMBER,
  P_MSITE_ID                 IN NUMBER,
  P_LANGUAGE_CODE            IN VARCHAR2,
  P_ATTACHMENT_ID            IN NUMBER,
  P_ITEM_ID                  IN NUMBER,
  P_DEFAULT_LANGUAGE         IN VARCHAR2,
  P_DEFAULT_SITE             IN VARCHAR2,
  P_OWNER                    IN VARCHAR2,
  P_LAST_UPDATE_DATE         IN VARCHAR2,
  P_CUSTOM_MODE              IN VARCHAR2,
  P_UPLOAD_MODE              IN VARCHAR2)

IS
BEGIN
   IF (P_UPLOAD_MODE = 'NLS') THEN
      null;
   ELSE
      LOAD_ROW(
         P_LGL_PHYS_MAP_ID,
         P_OBJECT_VERSION_NUMBER,
         P_MSITE_ID,
         P_LANGUAGE_CODE,
         P_ATTACHMENT_ID,
         P_ITEM_ID,
         P_DEFAULT_LANGUAGE,
         P_DEFAULT_SITE,
         P_OWNER,
         P_LAST_UPDATE_DATE,
         P_CUSTOM_MODE);
   END IF;
END LOAD_SEED_ROW;



PROCEDURE LOAD_ROW(
  P_LGL_PHYS_MAP_ID          IN NUMBER,
  P_OBJECT_VERSION_NUMBER    IN NUMBER,
  P_MSITE_ID                 IN NUMBER,
  P_LANGUAGE_CODE            IN VARCHAR2,
  P_ATTACHMENT_ID            IN NUMBER,
  P_ITEM_ID                  IN NUMBER,
  P_DEFAULT_LANGUAGE         IN VARCHAR2,
  P_DEFAULT_SITE             IN VARCHAR2,
  P_OWNER                    IN VARCHAR2,
  P_LAST_UPDATE_DATE         IN VARCHAR2,
  P_CUSTOM_MODE              IN VARCHAR2)

IS
  l_rowExists     NUMBER;
  l_indexExists   NUMBER;
  f_luby          NUMBER;  -- entity owner in file
  f_ludate        DATE;    -- entity update date in file
  db_luby         NUMBER;  -- entity owner in db
  db_ludate       DATE;    -- entity update date in db

BEGIN

   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.owner_id(P_OWNER);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

   -- Get the value of the db_luby and db_ludate from the database.
   SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE
     INTO db_luby, db_ludate
     FROM ibe_dsp_lgl_phys_map
     WHERE lgl_phys_map_id = P_LGL_PHYS_MAP_ID;


   --Invoke standard merge comparison routine UPLOAD_TEST.
   IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, P_CUSTOM_MODE)) THEN
      UPDATE ibe_dsp_lgl_phys_map
        SET LGL_PHYS_MAP_ID = P_LGL_PHYS_MAP_ID,
            OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
            LAST_UPDATED_BY = f_luby,
            LAST_UPDATE_DATE = f_ludate,
            MSITE_ID = P_MSITE_ID,
			   LANGUAGE_CODE = userenv('LANG'),
			   ATTACHMENT_ID = P_ATTACHMENT_ID,
			   ITEM_ID = P_ITEM_ID,
			   DEFAULT_LANGUAGE = P_DEFAULT_LANGUAGE,
			   DEFAULT_SITE = P_DEFAULT_SITE
			WHERE lgl_phys_map_id = P_LGL_PHYS_MAP_ID;
   END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- bug fix 4685390
        -- check for unique index, insert the new row only if there is no unique
        -- constraint violation. This is required because we allow the Customer to
        -- delete the  default All All mapping for the media object. Customer can
        -- then create their own mapping similar to the default seeded mapping.
        -- If we do not do this check then while inserting a seeded mapping row
        -- a unique contraint violation will be encountered

        BEGIN
          select 1 into l_indexExists from ibe_dsp_lgl_phys_map where
                                   item_id= to_number(P_ITEM_ID) and
                                   language_code= P_LANGUAGE_CODE and
	                               msite_id = to_number(P_MSITE_ID) and
                                   default_language= P_DEFAULT_LANGUAGE and
                                   default_site= P_DEFAULT_SITE ;
        EXCEPTION
           when NO_DATA_FOUND then
                l_indexExists:=null;
        END;
        IF (l_indexExists is null) then
           INSERT INTO ibe_dsp_lgl_phys_map (
              LGL_PHYS_MAP_ID,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN,
              MSITE_ID,
              LANGUAGE_CODE,
              ATTACHMENT_ID,
              ITEM_ID,
              DEFAULT_LANGUAGE,
              DEFAULT_SITE)
           VALUES (
              P_LGL_PHYS_MAP_ID,
              P_OBJECT_VERSION_NUMBER,
              f_luby,
              f_ludate,
              f_luby,
              f_ludate,
              f_luby,
              P_MSITE_ID,
              P_LANGUAGE_CODE,
              P_ATTACHMENT_ID,
              P_ITEM_ID,
              P_DEFAULT_LANGUAGE,
              P_DEFAULT_SITE);
    END IF;

END LOAD_ROW;


END IBE_PhysicalMap_GRP;

/
