--------------------------------------------------------
--  DDL for Package Body JTF_PHYSICALMAP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PHYSICALMAP_GRP" AS
/* $Header: JTFGPSLB.pls 115.6 2004/07/09 18:50:12 applrt ship $ */
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
--   3. First delete all the records in JTF_LGL_PHYS_MAP for the given
--	   attachment and mini-site; then insert a record into
--	   JTF_LGL_PHYS_MAP for each language_code in
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
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,
	p_attachment_id		IN	NUMBER,
	p_msite_id			IN	NUMBER,
	p_language_code_tbl		IN	LANGUAGE_CODE_TBL_TYPE) IS

	l_api_name CONSTANT VARCHAR2(30) := 'save_physicalmap';
	l_full_name CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

	l_msite_type VARCHAR2(10) := 'SITE';
	l_default_msite VARCHAR2(1) := g_no;
	l_default_lang VARCHAR2(1) := g_no;

	l_deliverable_id NUMBER;
	l_msite_id NUMBER;
	l_language_code VARCHAR2(4);
	l_lgl_phys_map_id NUMBER;

	l_index NUMBER;

   	CURSOR lgl_phys_map_id_seq IS
		SELECT JTF_DSP_LGL_PHYS_MAP_S1.NEXTVAL FROM DUAL;

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

   	-- Check if the attachment id exists
	l_deliverable_id := JTF_DSPMGRVALIDATION_GRP.check_attachment_deliverable(
		p_attachment_id);
	IF l_deliverable_id IS NULL THEN
		RAISE FND_API.g_exc_error;
	END IF;

	-- Check if the mini-site id exists
	l_msite_id := p_msite_id;
	IF p_msite_id IS NOT NULL THEN
		IF NOT JTF_DSPMGRVALIDATION_GRP.check_msite_exists(p_msite_id) THEN
			RAISE FND_API.g_exc_error;
		END IF;

		-- Delete all the existing mappings
		DELETE FROM JTF_DSP_LGL_PHYS_MAP
			WHERE ( (attachment_id = p_attachment_id)
			AND (default_site = l_default_msite)
			AND (msite_id = p_msite_id) );
	ELSE
		l_msite_type := 'ALLSITES';
		l_default_msite := g_yes;

		l_msite_id := JTF_DSPMGRVALIDATION_GRP.check_master_msite_exists;
		IF l_msite_id IS NULL THEN
			RAISE FND_API.g_exc_error;
		END IF;

		-- Delete all the existing mappings
		DELETE FROM JTF_DSP_LGL_PHYS_MAP
			WHERE ( (attachment_id = p_attachment_id)
			AND (default_site = g_yes) );
	END IF;

	-- Check if the language code exists or supported at the given mini-site

	IF p_language_code_tbl IS NOT NULL THEN
		l_language_code := TRIM(p_language_code_tbl(1));
		IF l_language_code IS NULL THEN
			-- temporarily using US. change later
			l_language_code := 'US';
			l_default_lang := g_yes;

			OPEN lgl_phys_map_id_seq;
			FETCH lgl_phys_map_id_seq INTO l_lgl_phys_map_id;
			CLOSE lgl_phys_map_id_seq;

			INSERT INTO JTF_DSP_LGL_PHYS_MAP (
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

		ELSE
			FOR l_index IN 1..p_language_code_tbl.COUNT LOOP
			BEGIN

				SAVEPOINT save_one_physicalmap_grp;

				-- Check if the language is supported at the given site
				IF (l_msite_type = 'SITE') THEN
					IF NOT JTF_DSPMGRVALIDATION_GRP.check_language_supported(
						p_msite_id,
						p_language_code_tbl(l_index)) THEN
						RAISE FND_API.g_exc_error;
					END IF;
		    		END IF;

	        		OPEN lgl_phys_map_id_seq;
	        		FETCH lgl_phys_map_id_seq INTO l_lgl_phys_map_id;
	        		CLOSE lgl_phys_map_id_seq;

				INSERT INTO JTF_DSP_LGL_PHYS_MAP (
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
								'JTF',
								'JTF_DSP_PHYSMAP_ALL_LNG_EXISTS');
							FND_MESSAGE.set_token(
								'LANG',
								p_language_code_tbl(l_index));
						ELSE
							FND_MESSAGE.set_name(
								'JTF',
								'JTF_DSP_PHYSMAP_EXISTS');
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

			IF l_default_msite = g_no THEN
				FND_MESSAGE.set_name('JTF', 'JTF_DSP_PHYSMAP_ALL_ALL_EXISTS');
			ELSE
				FND_MESSAGE.set_name('JTF', 'JTF_DSP_PHYSMAP_STE_ALL_EXISTS');
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
--   3. First delete all the records in JTF_LGL_PHYS_MAP for the given
--      attachment and mini-sites; then insert a record into
--      JTF_LGL_PHYS_MAP for each language_code in
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
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,
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
	l_deliverable_id := JTF_DSPMGRVALIDATION_GRP.check_attachment_deliverable(
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
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,
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
			IF NOT JTF_DSPMGRVALIDATION_GRP.check_physicalmap_exists(
				p_lgl_phys_map_id_tbl(l_index)) THEN
				RAISE FND_API.g_exc_error;
			END IF;

			DELETE FROM JTF_DSP_LGL_PHYS_MAP
				WHERE lgl_phys_map_id = p_lgl_phys_map_id_tbl(l_index);
			IF SQL%NOTFOUND THEN
				-- RAISE JTF_DSPMGRVALIDATION_GRP.physmap_not_exists_exception;
				IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
					FND_MESSAGE.set_name('JTF', 'JTF_DSP_PHYSMAP_NOT_EXISTS');
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
			WHEN JTF_DSPMGRVALIDATION_GRP.physmap_not_exists_exception THEN
				-- only warning; no error
				IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
					FND_MESSAGE.set_name('JTF', 'JTF_DSP_PHYSMAP_NOT_EXISTS');
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

	DELETE FROM JTF_DSP_LGL_PHYS_MAP
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

BEGIN

	-- Standard start of API savepoint
	SAVEPOINT delete_deliverable_grp;

	-- API body

	DELETE FROM JTF_DSP_LGL_PHYS_MAP
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

	DELETE FROM JTF_DSP_LGL_PHYS_MAP
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

	DELETE FROM JTF_DSP_LGL_PHYS_MAP
		WHERE msite_id = p_msite_id
		AND default_site = g_no
		AND default_language = g_no
		AND language_code NOT IN (SELECT language_code
		FROM JTF_MSITE_LANGUAGES WHERE msite_id = p_msite_id);

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
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,
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
				DELETE FROM JTF_DSP_LGL_PHYS_MAP
					WHERE ( (attachment_id = p_attachment_id)
					AND (default_site = g_yes) );
			ELSE
				DELETE FROM JTF_DSP_LGL_PHYS_MAP
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

	DELETE FROM JTF_DSP_LGL_PHYS_MAP
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


END JTF_PhysicalMap_GRP;

/
