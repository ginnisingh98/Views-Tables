--------------------------------------------------------
--  DDL for Package Body AMS_IMPORT_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMPORT_LIST_PVT" as
/* $Header: amsvimpb.pls 120.2 2005/12/29 20:12:59 ryedator noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Import_List_PVT
-- Purpose
--
-- History
--    09-May-2002   HUILI      added code into the "Create_Import_List" not to pick up
--                             the list import id if the value is passed.
--    12-June-2002  HUILI      pick up new batch id for the "Duplicate_Import_List" module.
--    18-JUNE-2002  huili      added the "RECORD_UPDATE_FLAG" and "ERROR_THRESHOLD" to
--                             the create and update module.
--    08-JULY-2002  huili      added the export concurrent program submission.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Import_List_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvimpb.pls';

G_ARC_IMPORT_HEADER  CONSTANT VARCHAR2(30) := 'IMPH';
G_ARC_EXPORT_HEADER  CONSTANT VARCHAR2(30) := 'EXPH';
G_APP_NAME CONSTANT VARCHAR2(10) := 'AMS';
G_IMPORT_CONCURRENT_PROGRAM CONSTANT VARCHAR2(100) := 'AMSIMPREC';
G_EXPORT_CONCURRENT_PROGRAM CONSTANT VARCHAR2(100) := 'AMSEXPREC';
G_JAVA_CONCURRENT_PROGRAM CONSTANT VARCHAR2(100) := 'Java Concurrent Program';
G_PLSQL_CONCURRENT_PROGRAM CONSTANT VARCHAR2(100) := 'PL/SQL Stored Procedure';
G_JAVA_CON_PROG_PATH CONSTANT VARCHAR2(100) := 'oracle.apps.ams.list';
G_PLSQL_CON_PROG_PACKNAME CONSTANT VARCHAR2(100) := 'AMS_EXPORT_PVT';
G_IMPORT_JAVA_CON_PROG_NAME CONSTANT VARCHAR2(100) := 'ImportRepConCurrent';
G_EXPORT_PLSQL_CON_PROG_NAME CONSTANT VARCHAR2(100) := 'generate_xml_util';
G_IMP_REC_CON_PARA_NAME CONSTANT VARCHAR2(30) := 'P_STRIMPORTLISTHEADERID';
G_EXP_REC_CON_PARA_NAME CONSTANT VARCHAR2(30) := 'p_export_header_id';
G_IMP_REC_CON_SEQ CONSTANT NUMBER := 10;
G_DEFAULT_VALUE_SET CONSTANT VARCHAR2(60) := '30 Characters Optional';
G_DEFAULT_DISPLAY_SIZE CONSTANT NUMBER := 30;
G_REPEAT_NONE CONSTANT VARCHAR2(30) := 'NONE';
G_REPEAT_ASAP CONSTANT VARCHAR2(30) := 'ASAP';
G_REPEAT_ONCE CONSTANT VARCHAR2(30) := 'ONCE';
G_REPEAT_PERIODICALLY CONSTANT VARCHAR2(30) := 'PERIODICALLY';
G_MSG_COUNT NUMBER := 10000;
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE write_msg(p_message IN VARCHAR2)
IS

BEGIN
     NULL;
     --INSERT INTO ams_concurrent_test
     --VALUES
     --(G_MSG_COUNT||':'||DBMS_UTILITY.get_time ||':'||p_message);
     --           G_MSG_COUNT := G_MSG_COUNT + 1;
     --COMMIT;
END;

/*
PROCEDURE Do_Recurring (
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_obj_id		IN   NUMBER,
	 p_repeat_mode  IN   VARCHAR2,
	 p_repeate_time    IN   VARCHAR2,
	 p_repeate_end_time  IN   VARCHAR2,
	 p_repeate_unit      IN   VARCHAR2,
	 p_repeate_interval  IN   NUMBER,
	 p_recur_type        IN   VARCHAR2)

IS
	L_API_NAME                  CONSTANT VARCHAR2(30) := 'Do_Recurring';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

	l_con_program_name VARCHAR2(2000) := G_IMPORT_CONCURRENT_PROGRAM;
	l_obj_type VARCHAR2(2000) := G_ARC_IMPORT_HEADER;
	l_java_executable_name VARCHAR2(2000) := G_IMPORT_JAVA_CON_PROG_NAME;
	l_parameter_name VARCHAR(2000) := G_IMP_REC_CON_PARA_NAME;
	l_request_id NUMBER;
	l_repeat_option_set BOOLEAN := TRUE;
	l_repeat_mode VARCHAR2(2000) := UPPER (p_repeat_mode);

	l_cancel_date DATE := NULL;
	l_cancel_flag VARCHAR2(1) := 'N';
	l_repeat_time VARCHAR2(2000) := NULL;
	l_repeat_interval NUMBER := NULL;
	l_repeat_unit VARCHAR2(2000) := NULL;
	l_repeate_end_time VARCHAR2(2000) := NULL;
	l_repeate_start_time VARCHAR2(2000) := NULL;

	l_error VARCHAR2(2000) := '';

BEGIN

	-- Standard Start of API savepoint
   --SAVEPOINT Do_Recurring;

		-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

	-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (AMS_DEBUG_HIGH_ON) THEN


	NULL;
	--AMS_UTILITY_PVT.debug_message('Do_Recurring::p_recur_type::::' || p_recur_type);

	END IF;
	write_msg('Do_Recurring::p_recur_type::::' || p_recur_type);

	IF p_recur_type IS NOT NULL AND UPPER(p_recur_type) <> G_ARC_IMPORT_HEADER THEN
		l_con_program_name := G_EXPORT_CONCURRENT_PROGRAM;
		l_obj_type := G_ARC_EXPORT_HEADER;
		l_java_executable_name := G_EXPORT_PLSQL_CON_PROG_NAME;
		l_parameter_name := G_EXP_REC_CON_PARA_NAME;
	END IF;
	IF (AMS_DEBUG_HIGH_ON) THEN
	NULL;
	--AMS_UTILITY_PVT.debug_message('Do_Recurring::l_con_program_name::' || l_con_program_name
	--	|| ' l_obj_type::' || l_obj_type || ' l_java_executable_name::' || l_java_executable_name
	--	|| ' l_parameter_name::' || l_parameter_name);
	END IF;

	IF (AMS_DEBUG_HIGH_ON) THEN
	NULL;


	--AMS_UTILITY_PVT.debug_message('Do_Recurring::l_con_program_name::' || l_con_program_name
	--	|| ' l_obj_type::' || l_obj_type || ' l_java_executable_name::' || l_java_executable_name
	--	|| ' l_parameter_name::' || l_parameter_name);

	END IF;
	l_con_program_name := l_con_program_name || p_obj_id;

	IF (AMS_DEBUG_HIGH_ON) THEN



	--AMS_UTILITY_PVT.debug_message('Do_Recurring::l_con_program_name::' || l_con_program_name);
	NULL;
	END IF;
	write_msg('Do_Recurring::l_con_program_name::' || l_con_program_name);
	--
	--clean up the program and executable if any
	--
   FND_PROGRAM.DELETE_PROGRAM (
		program_short_name   => l_con_program_name,
      application          => G_APP_NAME
   );

	IF (AMS_DEBUG_HIGH_ON) THEN


	NULL;
	--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 1');

	END IF;
	write_msg('Do_Recurring::test 1');
   FND_PROGRAM.DELETE_EXECUTABLE (
		executable_short_name      => l_con_program_name,
      application                => G_APP_NAME
	);
	IF (AMS_DEBUG_HIGH_ON) THEN
	 NULL;
	--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 2');
	END IF;
	write_msg('Do_Recurring::test 2');

	--
	--update the headers table, need to add the export stuff
	--
	IF l_repeat_mode = G_REPEAT_NONE THEN --cancel
			l_cancel_date := SYSDATE;
			l_cancel_flag := 'Y';
		ELSIF l_repeat_mode = G_REPEAT_ASAP THEN --'ASAP'
			l_repeat_time := SYSDATE;
		ELSIF l_repeat_mode = G_REPEAT_ONCE THEN --'ONCE'
			l_repeat_time := p_repeate_time;
		ELSIF l_repeat_mode = G_REPEAT_PERIODICALLY THEN --'PERIODICALLY'
			l_repeat_time := p_repeate_time;
			l_repeat_interval := p_repeate_interval;
			l_repeat_unit := p_repeate_unit;
			l_repeate_end_time := p_repeate_end_time;
			l_repeate_start_time := p_repeate_time;
	END IF;

	IF p_recur_type IS NOT NULL AND UPPER(p_recur_type) = G_ARC_IMPORT_HEADER THEN --import
		IF (AMS_DEBUG_HIGH_ON) THEN

		--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 2 ::l_cancel_date::' || l_cancel_date
		--	|| ' l_cancel_flag::' || l_cancel_flag || ' l_repeat_time::' || l_repeat_time
		--	|| ' l_repeat_interval::' || l_repeat_interval || ' l_repeat_unit::' || l_repeat_unit
		--	|| ' l_repeate_end_time::' || l_repeate_end_time || ' l_repeate_start_time::' || l_repeate_start_time);
		NULL;
		END IF;
		UPDATE AMS_IMP_LIST_HEADERS_ALL
		SET REPEAT_MODE = l_repeat_mode, CANCEL_DATE = l_cancel_date,
			 CANCEL_FLAG = l_cancel_flag, REPEAT_TIME = l_repeat_time,
			 REPEAT_INTERVAL = l_repeat_interval, REPEAT_UNIT = l_repeat_unit,
			 REPEAT_END_TIME = l_repeate_end_time, REPEAT_START_TIME = l_repeate_start_time
		WHERE IMPORT_LIST_HEADER_ID = p_obj_id;
	ELSE
		UPDATE AMS_EXP_LIST_HEADERS_ALL
		SET REPEAT_MODE = l_repeat_mode, CANCEL_DATE = l_cancel_date,
			 CANCEL_FLAG = l_cancel_flag, REPEAT_TIME = l_repeat_time,
			 REPEAT_INTERVAL = l_repeat_interval, REPEAT_UNIT = l_repeat_unit,
			 REPEAT_END_TIME = l_repeate_end_time, REPEAT_START_TIME = l_repeate_start_time
		WHERE EXPORT_LIST_HEADER_ID = p_obj_id;
	END IF;

	AMS_Utility_PVT.Create_Log (
		x_return_status   => x_return_status,
      p_arc_log_used_by => l_obj_type,
      p_log_used_by_id  => p_obj_id,
      p_msg_data        => 'After deleting executable:' || l_con_program_name,
      p_msg_type        => 'DEBUG'
   );

	IF l_repeat_mode IS NOT NULL AND l_repeat_mode <> G_REPEAT_NONE THEN
		IF (AMS_DEBUG_HIGH_ON) THEN
		   NULL;
		--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 4');
		END IF;
		write_msg('Do_Recurring::test 4');
		-- Create the Executable entry.
		IF p_recur_type IS NOT NULL AND UPPER(p_recur_type) = G_ARC_IMPORT_HEADER THEN
			FND_PROGRAM.EXECUTABLE (
				executable           => l_con_program_name,
				application          => G_APP_NAME,
				short_name           => l_con_program_name,
				description          => p_obj_id,
				execution_method     => G_JAVA_CONCURRENT_PROGRAM,
				execution_file_name  => l_java_executable_name,
				language_code        => USERENV ('LANG'),
				execution_file_path  => G_JAVA_CON_PROG_PATH
			);
		ELSE
			FND_PROGRAM.EXECUTABLE (
				executable           => l_con_program_name,
				application          => G_APP_NAME,
				short_name           => l_con_program_name,
				description          => p_obj_id,
				execution_method     => G_PLSQL_CONCURRENT_PROGRAM,
				execution_file_name  => G_PLSQL_CON_PROG_PACKNAME || '.' || G_EXPORT_PLSQL_CON_PROG_NAME,
				language_code        => USERENV ('LANG'));
		END IF;
		IF (AMS_DEBUG_HIGH_ON) THEN
		   NULL;
		--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 5');
		END IF;
		write_msg('Do_Recurring::test 5');
		AMS_Utility_PVT.Create_Log (
			x_return_status   => x_return_status,
			p_arc_log_used_by => l_obj_type,
			p_log_used_by_id  => p_obj_id,
			p_msg_data        => 'Executable:' || l_con_program_name || ' is created successfully.',
			p_msg_type        => 'DEBUG'
		);

		IF (AMS_DEBUG_HIGH_ON) THEN



		--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 6');
                   NULL;
		END IF;
		write_msg('Do_Recurring::test 6');
		--
		-- Register the concurrent program.
		FND_PROGRAM.REGISTER (
			program                 => l_con_program_name,
			application             => G_APP_NAME,
			enabled                 => 'Y',
			short_name              => l_con_program_name,
			executable_short_name   => l_con_program_name,
			executable_application  => G_APP_NAME,
			language_code           => USERENV ('LANG'),
			use_in_srs              => 'Y'
		);

		IF (AMS_DEBUG_HIGH_ON) THEN



		--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 7::l_con_program_name::' || l_con_program_name
		--	|| ' G_APP_NAME::' || G_APP_NAME || ' G_IMP_REC_CON_SEQ::' || G_IMP_REC_CON_SEQ
		--	|| ' l_parameter_name::' || l_parameter_name || ' G_DEFAULT_VALUE_SET::' || G_DEFAULT_VALUE_SET
		--	|| ' G_DEFAULT_DISPLAY_SIZE::' || G_DEFAULT_DISPLAY_SIZE  );
		   NULL;
		END IF;

		write_msg('Do_Recurring::test 7::l_con_program_name::' || l_con_program_name
			|| ' G_APP_NAME::' || G_APP_NAME || ' G_IMP_REC_CON_SEQ::' || G_IMP_REC_CON_SEQ
			|| ' l_parameter_name::' || l_parameter_name || ' G_DEFAULT_VALUE_SET::' || G_DEFAULT_VALUE_SET
			|| ' G_DEFAULT_DISPLAY_SIZE::' || G_DEFAULT_DISPLAY_SIZE  );

		AMS_Utility_PVT.Create_Log (
			x_return_status   => x_return_status,
			p_arc_log_used_by => l_obj_type,
			p_log_used_by_id  => p_obj_id,
			p_msg_data        => l_con_program_name || ' is registered successfully.',
			p_msg_type        => 'DEBUG'
		);

		IF p_recur_type IS NOT NULL AND UPPER(p_recur_type) = G_ARC_IMPORT_HEADER THEN
			FND_PROGRAM.parameter(
				program_short_name      => l_con_program_name,
				application             => G_APP_NAME,
				sequence                => G_IMP_REC_CON_SEQ,
				parameter               => l_parameter_name,
				value_set               => G_DEFAULT_VALUE_SET,
				display_size            => G_DEFAULT_DISPLAY_SIZE,
				description_size        => G_DEFAULT_DISPLAY_SIZE,
				concatenated_description_size => G_DEFAULT_DISPLAY_SIZE,
				token                         => l_parameter_name,
				prompt                        => l_parameter_name);
		ELSE
			FND_PROGRAM.parameter(
				program_short_name      => l_con_program_name,
				application             => G_APP_NAME,
				sequence                => G_IMP_REC_CON_SEQ,
				parameter               => l_parameter_name,
				value_set               => G_DEFAULT_VALUE_SET,
				display_size            => G_DEFAULT_DISPLAY_SIZE,
				description_size        => G_DEFAULT_DISPLAY_SIZE,
				concatenated_description_size => G_DEFAULT_DISPLAY_SIZE,
				prompt                        => l_parameter_name);
		END IF;

		IF (AMS_DEBUG_HIGH_ON) THEN



		--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 8:l_repeat_mode::' || l_repeat_mode);
		   NULL;
		END IF;
		write_msg('Do_Recurring::test 8:l_repeat_mode::' || l_repeat_mode);

		 AMS_Utility_PVT.Create_Log (
			x_return_status   => x_return_status,
			p_arc_log_used_by => l_obj_type,
			p_log_used_by_id  => p_obj_id,
			p_msg_data        => l_con_program_name || ' parameters are set successfully.',
			p_msg_type        => 'DEBUG'
		);

		IF l_repeat_mode = G_REPEAT_ASAP THEN
			write_msg('Do_Recurring::test 801 -1::' || TO_CHAR(SYSDATE, 'HH24:MI:SS') );
			--l_repeat_option_set := FND_REQUEST.set_repeat_options (repeat_time	=> TO_CHAR(SYSDATE, 'HH24:MI:SS'));
		ELSIF l_repeat_mode = G_REPEAT_ONCE THEN
			write_msg('Do_Recurring::test 802 -1:p_repeate_time' || p_repeate_time);
			l_repeat_option_set := FND_REQUEST.set_repeat_options (repeat_time	=> p_repeate_time);
		ELSIF l_repeat_mode = G_REPEAT_PERIODICALLY THEN
			write_msg('Do_Recurring::test 803 - 02:p_repeate_time' || p_repeate_time
				|| ' p_repeate_interval::' || p_repeate_interval || ' p_repeate_unit::' || p_repeate_unit
				|| ' p_repeate_end_time::' || p_repeate_end_time);
			l_repeat_option_set := FND_REQUEST.set_repeat_options (
				repeat_end_time => p_repeate_end_time,
			   repeat_interval => p_repeate_interval,
			   repeat_unit	=> p_repeate_unit);
		END IF;

		IF (AMS_DEBUG_HIGH_ON) THEN



		--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 9');
                   NULL;
		END IF;
		write_msg('Do_Recurring::test 9');

		IF l_repeat_option_set THEN
			IF (AMS_DEBUG_HIGH_ON) THEN
			   NULL;
			--AMS_UTILITY_PVT.debug_message('Do_Recurring::success in set_repeat_options');
			END IF;
			write_msg('Do_Recurring::success in set_repeat_options');
			AMS_Utility_PVT.Create_Log (
				x_return_status   => x_return_status,
				p_arc_log_used_by => l_obj_type,
				p_log_used_by_id  => p_obj_id,
				p_msg_data        => l_con_program_name || ' schedules are set successfully.',
				p_msg_type        => 'DEBUG'
			);
		ELSE
			IF (AMS_DEBUG_HIGH_ON) THEN

			   AMS_UTILITY_PVT.debug_message('Do_Recurring::fails in set_repeat_options');
			--AMS_UTILITY_PVT.debug_message('AMS_IMP_REC_SCH_ERROR');
			END IF;
			--write_msg('Do_Recurring::fails in set_repeat_options');
			AMS_Utility_PVT.Create_Log (
				x_return_status   => x_return_status,
				p_arc_log_used_by => l_obj_type,
				p_log_used_by_id  => p_obj_id,
				p_msg_data        => l_con_program_name || ' schedules fail.',
				p_msg_type        => 'DEBUG'
			);
			-- Initialize message list if p_init_msg_list is set to TRUE.
			IF FND_API.to_Boolean( p_init_msg_list ) THEN
			   FND_MSG_PUB.initialize;
			END IF;
			AMS_UTILITY_PVT.debug_message('AMS_IMP_REC_SCH_ERROR');
			RAISE FND_API.g_exc_unexpected_error;
		END IF;

		--
		-- submit request
		--
		l_request_id := FND_REQUEST.SUBMIT_REQUEST (
			application      => G_APP_NAME,
			program          => l_con_program_name,
			argument1        => p_obj_id);
		IF (AMS_DEBUG_HIGH_ON) THEN
		NULL;
		--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 10::l_request_id:: '
		--	|| l_request_id);
		END IF;
		write_msg('Do_Recurring::test 10::l_request_id:: '
			|| l_request_id);
		IF l_request_id = 0 THEN
			IF (AMS_DEBUG_HIGH_ON) THEN
			   NULL;
			--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 11::l_request_id is 0:: ');
			END IF;
			RAISE FND_API.g_exc_unexpected_error;
		ELSE
			IF (AMS_DEBUG_HIGH_ON) THEN
			   NULL;
			--AMS_UTILITY_PVT.debug_message('Do_Recurring::test 11::l_request_id is not 0:: ');
			END IF;
			Ams_Utility_PVT.Create_Log (
				x_return_status   => x_return_status,
				p_arc_log_used_by => l_obj_type,
				p_log_used_by_id  => p_obj_id,
				p_msg_data        => 'Can not submit:' || l_con_program_name,
				p_msg_type        => 'MILESTONE'
			  );
		END IF;
	END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
			p_count   => x_msg_count,
			p_data    => x_msg_data
		);

   WHEN FND_API.g_exc_unexpected_error THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
		);

	WHEN OTHERS THEN
		l_error := SQLERRM;
		IF (AMS_DEBUG_HIGH_ON) THEN

		AMS_UTILITY_PVT.debug_message('Do_Recurring::The error is:: ' || l_error);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
			p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
		);
END Do_Recurring;

*/

PROCEDURE Duplicate_Import_List (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_import_list_header_id      IN   NUMBER,
    x_ams_import_rec		OUT NOCOPY  ams_import_rec_type,
	 x_file_type            OUT NOCOPY  VARCHAR2)
IS
	L_API_NAME             CONSTANT VARCHAR2(30) := 'Duplicate_Import_List';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

	CURSOR c_list_import_rec (p_import_list_header_id NUMBER) IS
	SELECT	import_list_header_id,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				object_version_number,
				view_application_id,
				name,
				version,
				import_type,
				owner_user_id,
				list_source_type_id,
				status_code,
				status_date,
				user_status_id,
				source_system,
				vendor_id,
				pin_id,
				org_id,
				scheduled_time,
				null,--loaded_no_of_rows,
				loaded_date,
				rows_to_skip,
				processed_rows,
				headings_flag,
				expiry_date,
				purge_date,
				description,
				keywords,
				transactional_cost,
				transactional_currency_code,
				functional_cost,
				functional_currency_code,
				terminated_by,
				enclosed_by,
				data_filename,
				process_immed_flag,
				dedupe_flag,
				attribute_category,
				attribute1,
				attribute2,
				attribute3,
				attribute4,
				attribute5,
				attribute6,
				attribute7,
				attribute8,
				attribute9,
				attribute10,
				attribute11,
				attribute12,
				attribute13,
				attribute14,
				attribute15,
				custom_setup_id,
				country,
				usage,
				number_of_records,
				data_file_name,
				b2b_flag,
				rented_list_flag,
				server_flag,
				log_file_name,
				null,--number_of_failed_records,
				null,--number_of_duplicate_records,
				enable_word_replacement_flag,
				validate_file,
				server_name,
				user_name,
				password,
				upload_flag,
				parent_imp_header_id,
				record_update_flag,
				error_threshold,
				charset
	FROM AMS_IMP_LIST_HEADERS_ALL
	WHERE IMPORT_LIST_HEADER_ID = p_import_list_header_id;

	l_current_date DATE := SYSDATE;

        -- SOLIN, SQL repository
        CURSOR c_get_status_id(c_status_type VARCHAR2, c_status_code VARCHAR2,
               c_flag VARCHAR2) IS
        SELECT user_status_id
        FROM ams_user_statuses_b
        WHERE system_status_type = c_status_type -- 'AMS_IMPORT_STATUS'
        AND system_status_code = c_status_code -- 'NEW'
        AND default_flag = c_flag; -- 'Y';


	CURSOR c_get_file_type (p_import_header_id NUMBER) IS
   SELECT FILE_TYPE
	FROM AMS_IMP_DOCUMENTS
	WHERE IMPORT_LIST_HEADER_ID = p_import_header_id;

	l_status_id c_get_status_id%ROWTYPE;

BEGIN
	-- Standard Start of API savepoint
   SAVEPOINT Duplicate_Import_List;

		-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

	-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

	OPEN c_list_import_rec (p_import_list_header_id);
	FETCH c_list_import_rec INTO x_ams_import_rec;
	CLOSE c_list_import_rec;

	OPEN c_get_status_id('AMS_IMPORT_STATUS', 'NEW', 'Y');
	FETCH c_get_status_id INTO l_status_id;
	CLOSE c_get_status_id;

	SELECT AMS_IMP_LIST_HEADERS_ALL_S.NEXTVAL INTO x_ams_import_rec.import_list_header_id
	FROM DUAL;

  AMS_Utility_PVT.Write_Conc_Log (' Start Duplicate_Import_List');

	x_ams_import_rec.last_update_date := l_current_date;
	x_ams_import_rec.creation_date := l_current_date;
	x_ams_import_rec.name := x_ams_import_rec.name || x_ams_import_rec.import_list_header_id;
	x_ams_import_rec.object_version_number := 1.0;
	x_ams_import_rec.status_code := 'NEW';
	x_ams_import_rec.status_date := l_current_date;
	x_ams_import_rec.user_status_id := l_status_id.user_status_id;
	x_ams_import_rec.scheduled_time := l_current_date;
	x_ams_import_rec.loaded_date := l_current_date;
	x_ams_import_rec.expiry_date := l_current_date;
	x_ams_import_rec.purge_date := l_current_date;
	x_ams_import_rec.parent_imp_header_id := p_import_list_header_id;
  AMS_Utility_PVT.Write_Conc_Log (' Start Duplicate_Import_List before Get_DeEncrypt_String ');
  IF (x_ams_import_rec.password IS NOT NULL AND LENGTH (x_ams_import_rec.password) > 0) THEN
	  x_ams_import_rec.password := AMS_Import_Security_PVT.Get_DeEncrypt_String (
	p_input_string	=> x_ams_import_rec.password,
	p_header_id	=> p_import_list_header_id,
	p_encrypt_flag	=> FALSE);
  END IF;
  AMS_Utility_PVT.Write_Conc_Log (' Start Duplicate_Import_List after Get_DeEncrypt_String ');

	Create_Import_List(
		p_api_version_number     => 1.0,
		p_commit                 => FND_API.G_TRUE,
		x_return_status          => x_return_status,
		x_msg_count              => x_msg_count,
		x_msg_data               => x_msg_data,
		p_ams_import_rec         => x_ams_import_rec,
		x_import_list_header_id  => x_ams_import_rec.import_list_header_id);

  AMS_Utility_PVT.Write_Conc_Log (' Start Duplicate_Import_List after Create_Import_List '
    || ' the p_import_list_header_id::' || p_import_list_header_id
    || ' and the x_ams_import_rec.import_list_header_id::'
    || x_ams_import_rec.import_list_header_id);

  update AMS_IMP_LIST_HEADERS_ALL
  set ( generate_list, number_of_instances)=
	(select  generate_list, number_of_instances
   	 from  AMS_IMP_LIST_HEADERS_ALL
     where import_list_header_id = p_import_list_header_id),
	 generated_list_name = name
  where  import_list_header_id =  x_ams_import_rec.import_list_header_id;

  AMS_Utility_PVT.Write_Conc_Log (' Start Duplicate_Import_List after update AMS_IMP_LIST_HEADERS_ALL ');

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
   END IF;

  AMS_Utility_PVT.Write_Conc_Log (' Start Duplicate_Import_List 4444444 ');
	OPEN c_get_file_type (p_import_list_header_id);
	FETCH c_get_file_type INTO x_file_type;
	CLOSE c_get_file_type;

  AMS_Utility_PVT.Write_Conc_Log (' Start Duplicate_Import_List 4444444 after c_get_file_type ');

	-- Standard check for p_commit
	IF FND_API.to_Boolean( p_commit) THEN
		COMMIT WORK;
	END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
		(p_count   =>   x_msg_count,
		p_data     =>   x_msg_data);

EXCEPTION
	WHEN AMS_Utility_PVT.resource_locked THEN
		x_return_status := FND_API.g_ret_sts_error;
		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Duplicate_Import_List;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Duplicate_Import_List;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Duplicate_Import_List;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Duplicate_Import_List;


-- Hint: Primary key needs to be returned.
PROCEDURE Create_Import_List(
    p_api_version_number      IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,

    p_ams_import_rec          IN   ams_import_rec_type := g_miss_ams_import_rec,
    x_import_list_header_id   OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Import_List';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_IMPORT_LIST_HEADER_ID                  NUMBER;
   l_dummy       NUMBER;
   l_country     NUMBER;
   l_terminated_by VARCHAR2(30) := p_ams_import_rec.terminated_by;
   l_enclosed_by VARCHAR2(30) := p_ams_import_rec.enclosed_by;
   l_batch_id    NUMBER := FND_API.G_MISS_NUM;

	l_encrpted_password VARCHAR2 (2000);

   CURSOR c_id IS
      SELECT AMS_IMP_LIST_HEADERS_ALL_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_IMP_LIST_HEADERS_ALL
      WHERE IMPORT_LIST_HEADER_ID = l_id;

   CURSOR c_get_record (l_id IN NUMBER) IS
      SELECT version, object_version_number, status_code, status_date,
             user_status_id, country, validate_file
      FROM AMS_IMP_LIST_HEADERS_ALL
      WHERE IMPORT_LIST_HEADER_ID = l_id;

   -- SOLIN, SQL repository
   CURSOR c_get_status_id(c_status_type VARCHAR2, c_status_code VARCHAR2,
          c_flag VARCHAR2) IS
   SELECT user_status_id
   FROM ams_user_statuses_b
   WHERE system_status_type = c_status_type -- 'AMS_IMPORT_STATUS'
   AND system_status_code = c_status_code -- 'NEW'
   AND default_flag = c_flag; -- 'Y';

   l_user_status_id NUMBER;


   -- SOLIN
   l_return_status         VARCHAR2(30);
   l_ams_import_rec        ams_import_rec_type := g_miss_ams_import_rec;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Import_List_PVT;


      -- Standard call to check for call compatibility.

      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization
   OPEN c_get_status_id('AMS_IMPORT_STATUS', 'NEW', 'Y');
   FETCH c_get_status_id INTO l_user_status_id;
   CLOSE c_get_status_id;

   IF p_ams_import_rec.IMPORT_LIST_HEADER_ID IS NULL OR p_ams_import_rec.IMPORT_LIST_HEADER_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_IMPORT_LIST_HEADER_ID;
         CLOSE c_id;
         ams_utility_pvt.create_log(l_return_status, 'IMPH', l_IMPORT_LIST_HEADER_ID, 'Get ID from sequence ' || l_IMPORT_LIST_HEADER_ID);

         OPEN c_id_exists(l_IMPORT_LIST_HEADER_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
	ELSE
	    l_IMPORT_LIST_HEADER_ID := p_ams_import_rec.IMPORT_LIST_HEADER_ID;
            -- SOLIN, bug 4377876
            -- If the record exists, call update API.
            ams_utility_pvt.create_log(l_return_status, 'IMPH',
                l_IMPORT_LIST_HEADER_ID, 'Get ID from passed in value  ' || l_IMPORT_LIST_HEADER_ID);
            l_dummy := null;
            OPEN c_id_exists(l_IMPORT_LIST_HEADER_ID);
            FETCH c_id_exists INTO l_dummy;
            CLOSE c_id_exists;
            IF l_dummy IS NOT NULL
            THEN
                l_ams_import_rec := p_ams_import_rec;
                OPEN c_get_record(l_IMPORT_LIST_HEADER_ID);
                FETCH c_get_record INTO l_ams_import_rec.version,
                    l_ams_import_rec.object_version_number,
                    l_ams_import_rec.status_code,
                    l_ams_import_rec.status_date,
                    l_ams_import_rec.user_status_id,
                    l_ams_import_rec.country,
                    l_ams_import_rec.validate_file;
                CLOSE c_get_record;
                l_encrpted_password := p_ams_import_rec.password;

                IF UPPER(LTRIM(RTRIM(l_encrpted_password))) = 'NULL' THEN
                    l_encrpted_password := NULL;
                END IF;
		IF l_encrpted_password IS NOT NULL
                   AND LENGTH(l_encrpted_password) > 0
                THEN
                    l_encrpted_password := AMS_Import_Security_PVT.Get_DeEncrypt_String (
                        p_input_string => l_encrpted_password,
                        p_header_id    => l_import_list_header_id,
                        p_encrypt_flag => TRUE);

                    l_ams_import_rec.password := l_encrpted_password;
		END IF;
                -- The record is already there, call update API.
                Update_Import_List(
                    p_api_version_number         => 1.0,
                    p_init_msg_list              => FND_API.G_FALSE,
                    p_commit                     => FND_API.G_FALSE,
                    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status              => x_return_status,
                    x_msg_count                  => x_msg_count,
                    x_msg_data                   => x_msg_data,
                    p_ams_import_rec             => l_ams_import_rec,
                    x_object_version_number      => l_object_version_number);
                x_import_list_header_id := l_IMPORT_LIST_HEADER_ID;
                RETURN;
            END IF;
            -- SOLIN, end
   END IF;

      -- initialize any default values

      IF p_ams_import_rec.country IS NULL OR p_ams_import_rec.country = FND_API.g_miss_num THEN
         l_country := FND_PROFILE.value ('AMS_SRCGEN_USER_CITY');
      END IF;



      IF (AMS_DEBUG_HIGH_ON) THEN







      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name);



      END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name);
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Import_List');
          END IF;

          -- Invoke validation procedures
          Validate_import_list(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ams_import_rec  =>  p_ams_import_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
/*
      -- translate single quote to the real one for terminated by
      IF (p_ams_import_rec.terminated_by = 'SINGLEQUOTE') AND
         (p_ams_import_rec.server_flag = 'N')
      THEN
         l_terminated_by := '''';
      END IF;

      IF (p_ams_import_rec.terminated_by = 'SINGLEQUOTE') AND
         (p_ams_import_rec.server_flag = 'Y')
      THEN
         l_terminated_by := '\''';
      END IF;

      -- translate doulbe quote to the real one for terminated by
      IF p_ams_import_rec.terminated_by = 'DOUBLEQUOTE'
      THEN
         l_terminated_by := '"';
      END IF;

      -- translate single quote to the real one for enclosed by
      IF (p_ams_import_rec.enclosed_by = 'SINGLEQUOTE') AND
         (p_ams_import_rec.server_flag = 'N')
      THEN
         l_enclosed_by := '''';
      END IF;

      IF (p_ams_import_rec.enclosed_by = 'SINGLEQUOTE') AND
         (p_ams_import_rec.server_flag = 'Y')
      THEN
         l_enclosed_by := '\''';
      END IF;

      -- translate doulbe quote to the real one for enclosed by
      IF p_ams_import_rec.enclosed_by = 'DOUBLEQUOTE'
      THEN
         l_enclosed_by := '"';
      END IF;
*/

      -- insert batch id when import type is lead
/*
      IF p_ams_import_rec.import_type = 'LEAD'
      THEN
	  select as_import_interface_s.nextval into l_batch_id  from dual;
      END IF;
*/
      -- insert batch id in any cases
      select as_import_interface_s.nextval into l_batch_id  from dual;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      l_encrpted_password := p_ams_import_rec.password;

      IF UPPER(LTRIM(RTRIM(l_encrpted_password))) = 'NULL' THEN
        l_encrpted_password := NULL;
      END IF;

      -- Invoke table handler(AMS_IMP_LIST_HEADERS_PKG.Insert_Row)
      AMS_IMP_LIST_HEADERS_PKG.Insert_Row(
          px_import_list_header_id  => l_import_list_header_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          p_view_application_id  => p_ams_import_rec.view_application_id,
          p_name  => p_ams_import_rec.name,
          p_version  => '1.0',--p_ams_import_rec.version,
          p_import_type  => p_ams_import_rec.import_type,
          p_owner_user_id  => p_ams_import_rec.owner_user_id,
          p_list_source_type_id  => p_ams_import_rec.list_source_type_id,
          p_status_code  => 'NEW',--p_ams_import_rec.status_code,
          p_status_date  => sysdate,--p_ams_import_rec.status_date,
          p_user_status_id  => l_user_status_id, --3001,--p_ams_import_rec.user_status_id,
          p_source_system  => p_ams_import_rec.source_system,
          p_vendor_id  => p_ams_import_rec.vendor_id,
          p_pin_id  => p_ams_import_rec.pin_id,
          px_org_id  => l_org_id,
          p_scheduled_time  => p_ams_import_rec.scheduled_time,
          p_loaded_no_of_rows  => p_ams_import_rec.loaded_no_of_rows,
          p_loaded_date  => p_ams_import_rec.loaded_date,
          p_rows_to_skip  => p_ams_import_rec.rows_to_skip,
          p_processed_rows  => p_ams_import_rec.processed_rows,
          p_headings_flag  => p_ams_import_rec.headings_flag,
          p_expiry_date  => p_ams_import_rec.expiry_date,
          p_purge_date  => p_ams_import_rec.purge_date,
          p_description  => p_ams_import_rec.description,
          p_keywords  => p_ams_import_rec.keywords,
          p_transactional_cost  => p_ams_import_rec.transactional_cost,
          p_transactional_currency_code  => p_ams_import_rec.transactional_currency_code,
          p_functional_cost  => p_ams_import_rec.functional_cost,
          p_functional_currency_code  => p_ams_import_rec.functional_currency_code,
          p_terminated_by  => l_terminated_by,
          p_enclosed_by  => l_enclosed_by,
          p_data_filename  => p_ams_import_rec.data_filename,
          p_process_immed_flag  => p_ams_import_rec.process_immed_flag,
          p_dedupe_flag  => p_ams_import_rec.dedupe_flag,
          p_attribute_category  => p_ams_import_rec.attribute_category,
          p_attribute1  => p_ams_import_rec.attribute1,
          p_attribute2  => p_ams_import_rec.attribute2,
          p_attribute3  => p_ams_import_rec.attribute3,
          p_attribute4  => p_ams_import_rec.attribute4,
          p_attribute5  => p_ams_import_rec.attribute5,
          p_attribute6  => p_ams_import_rec.attribute6,
          p_attribute7  => p_ams_import_rec.attribute7,
          p_attribute8  => p_ams_import_rec.attribute8,
          p_attribute9  => p_ams_import_rec.attribute9,
          p_attribute10  => p_ams_import_rec.attribute10,
          p_attribute11  => p_ams_import_rec.attribute11,
          p_attribute12  => p_ams_import_rec.attribute12,
          p_attribute13  => p_ams_import_rec.attribute13,
          p_attribute14  => p_ams_import_rec.attribute14,
          p_attribute15  => p_ams_import_rec.attribute15,
          p_custom_setup_id  => p_ams_import_rec.custom_setup_id,
          p_country  => l_country,
          p_usage  => p_ams_import_rec.usage,
          p_number_of_records  => p_ams_import_rec.number_of_records,
          p_data_file_name  => p_ams_import_rec.data_file_name,
          p_b2b_flag  => p_ams_import_rec.b2b_flag,
          p_rented_list_flag  => p_ams_import_rec.rented_list_flag,
          p_server_flag  => p_ams_import_rec.server_flag,
          p_log_file_name  => p_ams_import_rec.log_file_name,
          p_number_of_failed_records  => p_ams_import_rec.number_of_failed_records,
          p_number_of_duplicate_records  => p_ams_import_rec.number_of_duplicate_records,
          p_enable_word_replacement_flag  => p_ams_import_rec.enable_word_replacement_flag,
			 p_batch_id => l_batch_id,
			 p_server_name => p_ams_import_rec.server_name,
			 p_user_name   => p_ams_import_rec.user_name,
			 p_password  => l_encrpted_password, --p_ams_import_rec.password,
			 p_upload_flag	=> p_ams_import_rec.upload_flag,
			 p_parent_imp_header_id => p_ams_import_rec.parent_imp_header_id,
			 p_record_update_flag => p_ams_import_rec.record_update_flag,
		    p_error_threshold => p_ams_import_rec.error_threshold,
			 p_charset => p_ams_import_rec.charset);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_import_list_header_id:=l_import_list_header_id;

		IF l_encrpted_password IS NOT NULL AND LENGTH(l_encrpted_password) > 0 THEN
			l_encrpted_password := AMS_Import_Security_PVT.Get_DeEncrypt_String (
										p_input_string	=>	l_encrpted_password,
										p_header_id		=> l_import_list_header_id,
										p_encrypt_flag => TRUE);
			UPDATE AMS_IMP_LIST_HEADERS_ALL
			SET PASSWORD = l_encrpted_password
			WHERE IMPORT_LIST_HEADER_ID = l_import_list_header_id;
		END IF;

-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Import_List;


PROCEDURE Update_Import_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_import_rec               IN    ams_import_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_import_list(import_list_header_id NUMBER) IS
    SELECT *
    FROM  AMS_IMP_LIST_HEADERS_ALL
    WHERE import_list_header_id=p_ams_import_rec.import_list_header_id;

    -- Hint: Developer need to provide Where clause
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Import_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_IMPORT_LIST_HEADER_ID    NUMBER;
l_ref_ams_import_rec  c_get_Import_List%ROWTYPE ;
l_tar_ams_import_rec  AMS_Import_List_PVT.ams_import_rec_type := P_ams_import_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Import_List_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

/*
      OPEN c_get_Import_List( l_tar_ams_import_rec.import_list_header_id);

      FETCH c_get_Import_List INTO l_ref_ams_import_rec  ;

       If ( c_get_Import_List%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Import_List') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Import_List;
*/


      If (l_tar_ams_import_rec.object_version_number is NULL or
          l_tar_ams_import_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ams_import_rec.object_version_number <> l_ref_ams_import_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Import_List') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_UTILITY_PVT.debug_message('Private API: Validate_Import_List');
          END IF;

          -- Invoke validation procedures
          Validate_import_list(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_ams_import_rec  =>  p_ams_import_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AMS_IMP_LIST_HEADERS_PKG.Update_Row)
      AMS_IMP_LIST_HEADERS_PKG.Update_Row(
          p_import_list_header_id  => p_ams_import_rec.import_list_header_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_version_number  => p_ams_import_rec.object_version_number,
          p_view_application_id  => p_ams_import_rec.view_application_id,
          p_name  => p_ams_import_rec.name,
          p_version  => p_ams_import_rec.version,
          p_import_type  => p_ams_import_rec.import_type,
          p_owner_user_id  => p_ams_import_rec.owner_user_id,
          p_list_source_type_id  => p_ams_import_rec.list_source_type_id,
          p_status_code  => p_ams_import_rec.status_code,
          p_status_date  => p_ams_import_rec.status_date,
          p_user_status_id  => p_ams_import_rec.user_status_id,
          p_source_system  => p_ams_import_rec.source_system,
          p_vendor_id  => p_ams_import_rec.vendor_id,
          p_pin_id  => p_ams_import_rec.pin_id,
          p_org_id  => p_ams_import_rec.org_id,
          p_scheduled_time  => p_ams_import_rec.scheduled_time,
          p_loaded_no_of_rows  => p_ams_import_rec.loaded_no_of_rows,
          p_loaded_date  => p_ams_import_rec.loaded_date,
          p_rows_to_skip  => p_ams_import_rec.rows_to_skip,
          p_processed_rows  => p_ams_import_rec.processed_rows,
          p_headings_flag  => p_ams_import_rec.headings_flag,
          p_expiry_date  => p_ams_import_rec.expiry_date,
          p_purge_date  => p_ams_import_rec.purge_date,
          p_description  => p_ams_import_rec.description,
          p_keywords  => p_ams_import_rec.keywords,
          p_transactional_cost  => p_ams_import_rec.transactional_cost,
          p_transactional_currency_code  => p_ams_import_rec.transactional_currency_code,
          p_functional_cost  => p_ams_import_rec.functional_cost,
          p_functional_currency_code  => p_ams_import_rec.functional_currency_code,
          p_terminated_by  => p_ams_import_rec.terminated_by,
          p_enclosed_by  => p_ams_import_rec.enclosed_by,
          p_data_filename  => p_ams_import_rec.data_filename,
          p_process_immed_flag  => p_ams_import_rec.process_immed_flag,
          p_dedupe_flag  => p_ams_import_rec.dedupe_flag,
          p_attribute_category  => p_ams_import_rec.attribute_category,
          p_attribute1  => p_ams_import_rec.attribute1,
          p_attribute2  => p_ams_import_rec.attribute2,
          p_attribute3  => p_ams_import_rec.attribute3,
          p_attribute4  => p_ams_import_rec.attribute4,
          p_attribute5  => p_ams_import_rec.attribute5,
          p_attribute6  => p_ams_import_rec.attribute6,
          p_attribute7  => p_ams_import_rec.attribute7,
          p_attribute8  => p_ams_import_rec.attribute8,
          p_attribute9  => p_ams_import_rec.attribute9,
          p_attribute10  => p_ams_import_rec.attribute10,
          p_attribute11  => p_ams_import_rec.attribute11,
          p_attribute12  => p_ams_import_rec.attribute12,
          p_attribute13  => p_ams_import_rec.attribute13,
          p_attribute14  => p_ams_import_rec.attribute14,
          p_attribute15  => p_ams_import_rec.attribute15,
          p_custom_setup_id  => p_ams_import_rec.custom_setup_id,
          p_country  => p_ams_import_rec.country,
          p_usage  => p_ams_import_rec.usage,
          p_number_of_records  => p_ams_import_rec.number_of_records,
          p_data_file_name  => p_ams_import_rec.data_file_name,
          p_b2b_flag  => p_ams_import_rec.b2b_flag,
          p_rented_list_flag  => p_ams_import_rec.rented_list_flag,
          p_server_flag  => p_ams_import_rec.server_flag,
          p_log_file_name  => p_ams_import_rec.log_file_name,
          p_number_of_failed_records  => p_ams_import_rec.number_of_failed_records,
          p_number_of_duplicate_records  => p_ams_import_rec.number_of_duplicate_records,
          p_enable_word_replacement_flag  => p_ams_import_rec.enable_word_replacement_flag,
	       p_validate_file => p_ams_import_rec.validate_file,
			 p_record_update_flag => p_ams_import_rec.record_update_flag,
		    p_error_threshold => p_ams_import_rec.error_threshold);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Import_List;


PROCEDURE Delete_Import_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_import_list_header_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Import_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Import_List_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AMS_IMP_LIST_HEADERS_PKG.Delete_Row)
      AMS_IMP_LIST_HEADERS_PKG.Delete_Row(
          p_IMPORT_LIST_HEADER_ID  => p_IMPORT_LIST_HEADER_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_Import_List;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Import_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_import_list_header_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Import_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_IMPORT_LIST_HEADER_ID                  NUMBER;

CURSOR c_Import_List IS
   SELECT IMPORT_LIST_HEADER_ID
   FROM AMS_IMP_LIST_HEADERS_ALL
   WHERE IMPORT_LIST_HEADER_ID = p_IMPORT_LIST_HEADER_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name||': start');

  END IF;
  OPEN c_Import_List;

  FETCH c_Import_List INTO l_IMPORT_LIST_HEADER_ID;

  IF (c_Import_List%NOTFOUND) THEN
    CLOSE c_Import_List;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Import_List;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Import_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Lock_Import_List;


PROCEDURE check_ams_import_uk_items(
    p_ams_import_rec               IN   ams_import_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);


BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IMP_LIST_HEADERS_ALL',
         'IMPORT_LIST_HEADER_ID = ''' || p_ams_import_rec.IMPORT_LIST_HEADER_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_IMP_LIST_HEADERS_ALL',
         'IMPORT_LIST_HEADER_ID = ''' || p_ams_import_rec.IMPORT_LIST_HEADER_ID ||
         ''' AND IMPORT_LIST_HEADER_ID <> ' || p_ams_import_rec.IMPORT_LIST_HEADER_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_IMPORT_LIST_HEADER_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;




END check_ams_import_uk_items;

PROCEDURE check_ams_import_req_items(
    p_ams_import_rec               IN  ams_import_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ams_import_rec.import_list_header_id = FND_API.g_miss_num OR p_ams_import_rec.import_list_header_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_import_list_header_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.last_update_date = FND_API.g_miss_date OR p_ams_import_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.last_updated_by = FND_API.g_miss_num OR p_ams_import_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.creation_date = FND_API.g_miss_date OR p_ams_import_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.created_by = FND_API.g_miss_num OR p_ams_import_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.view_application_id = FND_API.g_miss_num OR p_ams_import_rec.view_application_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_view_application_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.name = FND_API.g_miss_char OR p_ams_import_rec.name IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_name');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.version = FND_API.g_miss_char OR p_ams_import_rec.version IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_version');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.import_type = FND_API.g_miss_char OR p_ams_import_rec.import_type IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_import_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.owner_user_id = FND_API.g_miss_num OR p_ams_import_rec.owner_user_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_owner_user_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.status_code = FND_API.g_miss_char OR p_ams_import_rec.status_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_status_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.status_date = FND_API.g_miss_date OR p_ams_import_rec.status_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_status_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.user_status_id = FND_API.g_miss_num OR p_ams_import_rec.user_status_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_user_status_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.import_list_header_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_import_list_header_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.last_update_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.last_updated_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.creation_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.created_by IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.view_application_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_view_application_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.name IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_name');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.version IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_version');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.import_type IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_import_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.owner_user_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_owner_user_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.status_code IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_status_code');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.status_date IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_status_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ams_import_rec.user_status_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_user_status_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_ams_import_req_items;

PROCEDURE check_ams_import_FK_items(
    p_ams_import_rec IN ams_import_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ams_import_FK_items;

PROCEDURE check_ams_import_Lookup_items(
    p_ams_import_rec IN ams_import_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_ams_import_Lookup_items;

PROCEDURE check_ams_import_Business(
    p_ams_import_rec IN ams_import_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
CURSOR c_get_import_list(import_list_header_id NUMBER) IS
    SELECT *
    FROM  AMS_IMP_LIST_HEADERS_ALL
    WHERE import_list_header_id=p_ams_import_rec.import_list_header_id;
l_import_rec c_get_import_list%ROWTYPE;

CURSOR c_get_import_list_name(name VARCHAR2) IS
    SELECT *
    FROM  AMS_IMP_LIST_HEADERS_VL
    WHERE name=p_ams_import_rec.name;
l_import_name_rec c_get_import_list_name%ROWTYPE;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_ams_import_rec.server_flag = 'Y'
   THEN
      if fnd_profile.value('AMS_IMP_CTL_PATH') is NULL then
         FND_MESSAGE.set_name('AMS', 'AMS_IMP_CTL_PATH');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      end if;

      if fnd_profile.value('AMS_IMP_DATA_PATH') is NULL then
         FND_MESSAGE.set_name('AMS', 'AMS_IMP_DATA_PATH');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      end if;
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_update
   THEN
      --Exp date and Usage validation only applied to Rented lists
      IF (p_ams_import_rec.rented_list_flag = 'R') and
         (p_ams_import_rec.expiry_date <> FND_API.g_miss_date) and
         (p_ams_import_rec.expiry_date < SYSDATE)
      THEN
         --AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_ams_import_NO_name');
         FND_MESSAGE.set_name('AMS', 'AMS_IMP_EXP_DATE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- Rented list must enter exp date and/or usage
      IF (p_ams_import_rec.rented_list_flag = 'R') AND
         ((p_ams_import_rec.usage is NULL AND p_ams_import_rec.expiry_date is NULL) OR
          (p_ams_import_rec.usage = FND_API.g_miss_num AND p_ams_import_rec.expiry_date = FND_API.g_miss_date))
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_IMP_RENTED_LIST');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   OPEN c_get_Import_List( p_ams_import_rec.import_list_header_id);
   FETCH c_get_Import_List INTO l_import_rec  ;
   -- NOFOUND means create mode
   IF (c_get_Import_List%NOTFOUND)
   THEN

      IF (p_ams_import_rec.data_filename = FND_API.g_miss_char) OR
         (p_ams_import_rec.data_filename is NULL)
      THEN
         FND_MESSAGE.set_name('AMS', 'API_MISS_DATA_FILENAME');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         close c_get_Import_list;
         RETURN;
      END IF;

      IF (p_ams_import_rec.terminated_by = p_ams_import_rec.enclosed_by)
      THEN
         FND_MESSAGE.set_name('AMS', 'API_SAME_TERMIN_ENCLOSED');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         close c_get_Import_list;
         RETURN;
      END IF;

      -- check import name uniqueness
      OPEN c_get_Import_List_name( p_ams_import_rec.name);
      FETCH c_get_Import_List_name INTO l_import_name_rec  ;
      IF (c_get_Import_List_name%FOUND)
      THEN
         --AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_IMPORT_NAME_DUPLICATE');
         FND_MESSAGE.set_name('AMS', 'AMS_IMPORT_NAME_DUPLICATE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
         close c_get_Import_list_name;
         RETURN;
      END IF;

   END IF;

END check_ams_import_Business;

PROCEDURE Check_ams_import_Items (
    P_ams_import_rec     IN    ams_import_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Private API: ' || 'before check_ams_import_uk_items');
        END IF;

   check_ams_import_uk_items(
      p_ams_import_rec => p_ams_import_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Private API: ' || 'before check_ams_import_req_items');
        END IF;

   check_ams_import_req_items(
      p_ams_import_rec => p_ams_import_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Private API: ' || 'before check_ams_import_FK_items');
        END IF;

   check_ams_import_FK_items(
      p_ams_import_rec => p_ams_import_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Private API: ' || 'before check_ams_import_Lookup_items');
        END IF;

   check_ams_import_Lookup_items(
      p_ams_import_rec => p_ams_import_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Private API: ' || 'after check_ams_import_Lookup_items');
        END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Private API: ' || 'before check_ams_import_Business');

   END IF;
   check_ams_import_Business(
      p_ams_import_rec => p_ams_import_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Private API: ' || 'after check_ams_import_Business');
   END IF;
END Check_ams_import_Items;


PROCEDURE Complete_ams_import_Rec (
   p_ams_import_rec IN ams_import_rec_type,
   x_complete_rec OUT NOCOPY ams_import_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_imp_list_headers_all
      WHERE import_list_header_id = p_ams_import_rec.import_list_header_id;
   l_ams_import_rec c_complete%ROWTYPE;

     CURSOR c_status_id IS
   SELECT user_status_id
   FROM ams_user_statuses_vl
   WHERE system_status_type = 'AMS_IMPORT_STATUS' AND
         system_status_code = 'NEW' and default_flag = 'Y';
   l_user_status_id NUMBER;
BEGIN
   x_complete_rec := p_ams_import_rec;

   OPEN c_status_id;
   FETCH c_status_id INTO l_user_status_id;
   CLOSE c_status_id;


   OPEN c_complete;
   FETCH c_complete INTO l_ams_import_rec;
   CLOSE c_complete;

   -- import_list_header_id
   IF p_ams_import_rec.import_list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.import_list_header_id := l_ams_import_rec.import_list_header_id;
   END IF;

   -- last_update_date
   IF p_ams_import_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_ams_import_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_ams_import_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_ams_import_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_ams_import_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_ams_import_rec.creation_date;
   END IF;

   -- created_by
   IF p_ams_import_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_ams_import_rec.created_by;
   END IF;

   -- last_update_login
   IF p_ams_import_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_ams_import_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_ams_import_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_ams_import_rec.object_version_number;
   END IF;

   -- view_application_id
   IF p_ams_import_rec.view_application_id = FND_API.g_miss_num THEN
      x_complete_rec.view_application_id := l_ams_import_rec.view_application_id;
   END IF;

   -- name
   IF p_ams_import_rec.name = FND_API.g_miss_char THEN
      x_complete_rec.name := l_ams_import_rec.name;
   END IF;

   -- version
   IF p_ams_import_rec.version = FND_API.g_miss_char THEN
      x_complete_rec.version := '1.0';--l_ams_import_rec.version;
   END IF;

   -- import_type
   IF p_ams_import_rec.import_type = FND_API.g_miss_char THEN
      x_complete_rec.import_type := l_ams_import_rec.import_type;
   END IF;

   -- owner_user_id
   IF p_ams_import_rec.owner_user_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_user_id := l_ams_import_rec.owner_user_id;
   END IF;

   -- list_source_type_id
   IF p_ams_import_rec.list_source_type_id = FND_API.g_miss_num THEN
      x_complete_rec.list_source_type_id := l_ams_import_rec.list_source_type_id;
   END IF;

   -- status_code
   IF p_ams_import_rec.status_code = FND_API.g_miss_char THEN
      x_complete_rec.status_code := 'NEW';--l_ams_import_rec.status_code;
   END IF;

   -- status_date
   IF p_ams_import_rec.status_date = FND_API.g_miss_date THEN
      x_complete_rec.status_date := sysdate;--l_ams_import_rec.status_date;
   END IF;

   -- user_status_id
   IF p_ams_import_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_user_status_id;--3001;--l_ams_import_rec.user_status_id;
   END IF;

   -- source_system
   IF p_ams_import_rec.source_system = FND_API.g_miss_char THEN
      x_complete_rec.source_system := l_ams_import_rec.source_system;
   END IF;

   -- vendor_id
   IF p_ams_import_rec.vendor_id = FND_API.g_miss_num THEN
      x_complete_rec.vendor_id := l_ams_import_rec.vendor_id;
   END IF;

   -- pin_id
   IF p_ams_import_rec.pin_id = FND_API.g_miss_num THEN
      x_complete_rec.pin_id := l_ams_import_rec.pin_id;
   END IF;

   -- org_id
   IF p_ams_import_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := l_ams_import_rec.org_id;
   END IF;

   -- scheduled_time
   IF p_ams_import_rec.scheduled_time = FND_API.g_miss_date THEN
      x_complete_rec.scheduled_time := l_ams_import_rec.scheduled_time;
   END IF;

   -- loaded_no_of_rows
   IF p_ams_import_rec.loaded_no_of_rows = FND_API.g_miss_num THEN
      x_complete_rec.loaded_no_of_rows := l_ams_import_rec.loaded_no_of_rows;
   END IF;

   -- loaded_date
   IF p_ams_import_rec.loaded_date = FND_API.g_miss_date THEN
      x_complete_rec.loaded_date := l_ams_import_rec.loaded_date;
   END IF;

   -- rows_to_skip
   IF p_ams_import_rec.rows_to_skip = FND_API.g_miss_num THEN
      x_complete_rec.rows_to_skip := l_ams_import_rec.rows_to_skip;
   END IF;

   -- processed_rows
   IF p_ams_import_rec.processed_rows = FND_API.g_miss_num THEN
      x_complete_rec.processed_rows := l_ams_import_rec.processed_rows;
   END IF;

   -- headings_flag
   IF p_ams_import_rec.headings_flag = FND_API.g_miss_char THEN
      x_complete_rec.headings_flag := l_ams_import_rec.headings_flag;
   END IF;

   -- expiry_date
   IF p_ams_import_rec.expiry_date = FND_API.g_miss_date THEN
      x_complete_rec.expiry_date := l_ams_import_rec.expiry_date;
   END IF;


   -- purge_date
   IF p_ams_import_rec.purge_date = FND_API.g_miss_date THEN
      x_complete_rec.purge_date := l_ams_import_rec.purge_date;
   END IF;

   -- description
   IF p_ams_import_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_ams_import_rec.description;
   END IF;

   -- keywords
   IF p_ams_import_rec.keywords = FND_API.g_miss_char THEN
      x_complete_rec.keywords := l_ams_import_rec.keywords;
   END IF;

   -- transactional_cost
   IF p_ams_import_rec.transactional_cost = FND_API.g_miss_num THEN
      x_complete_rec.transactional_cost := l_ams_import_rec.transactional_cost;
   END IF;

   -- transactional_currency_code
   IF p_ams_import_rec.transactional_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.transactional_currency_code := l_ams_import_rec.transactional_currency_code;
   END IF;

   -- functional_cost
   IF p_ams_import_rec.functional_cost = FND_API.g_miss_num THEN
      x_complete_rec.functional_cost := l_ams_import_rec.functional_cost;
   END IF;

   -- functional_currency_code
   IF p_ams_import_rec.functional_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.functional_currency_code := l_ams_import_rec.functional_currency_code;
   END IF;

   -- terminated_by
   IF p_ams_import_rec.terminated_by = FND_API.g_miss_char THEN
      x_complete_rec.terminated_by := l_ams_import_rec.terminated_by;
   END IF;

   -- enclosed_by
   IF p_ams_import_rec.enclosed_by = FND_API.g_miss_char THEN
      x_complete_rec.enclosed_by := l_ams_import_rec.enclosed_by;
   END IF;

   -- data_filename
   IF p_ams_import_rec.data_filename = FND_API.g_miss_char THEN
      x_complete_rec.data_filename := l_ams_import_rec.data_filename;
   END IF;

   -- process_immed_flag
   IF p_ams_import_rec.process_immed_flag = FND_API.g_miss_char THEN
      x_complete_rec.process_immed_flag := l_ams_import_rec.process_immed_flag;
   END IF;

   -- dedupe_flag
   IF p_ams_import_rec.dedupe_flag = FND_API.g_miss_char THEN
      x_complete_rec.dedupe_flag := l_ams_import_rec.dedupe_flag;
   END IF;

   -- attribute_category
   IF p_ams_import_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_ams_import_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_ams_import_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_ams_import_rec.attribute1;
   END IF;

   -- attribute2
   IF p_ams_import_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_ams_import_rec.attribute2;
   END IF;

   -- attribute3
   IF p_ams_import_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_ams_import_rec.attribute3;
   END IF;

   -- attribute4
   IF p_ams_import_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_ams_import_rec.attribute4;
   END IF;

   -- attribute5
   IF p_ams_import_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_ams_import_rec.attribute5;
   END IF;

   -- attribute6
   IF p_ams_import_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_ams_import_rec.attribute6;
   END IF;

   -- attribute7
   IF p_ams_import_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_ams_import_rec.attribute7;
   END IF;

   -- attribute8
   IF p_ams_import_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_ams_import_rec.attribute8;
   END IF;

   -- attribute9
   IF p_ams_import_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_ams_import_rec.attribute9;
   END IF;

   -- attribute10
   IF p_ams_import_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_ams_import_rec.attribute10;
   END IF;

   -- attribute11
   IF p_ams_import_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_ams_import_rec.attribute11;
   END IF;

   -- attribute12
   IF p_ams_import_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_ams_import_rec.attribute12;
   END IF;

   -- attribute13
   IF p_ams_import_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_ams_import_rec.attribute13;
   END IF;

   -- attribute14
   IF p_ams_import_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_ams_import_rec.attribute14;
   END IF;

   -- attribute15
   IF p_ams_import_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_ams_import_rec.attribute15;
   END IF;


   -- custom_setup_id
   IF p_ams_import_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := l_ams_import_rec.custom_setup_id;
   END IF;

   -- country
   IF p_ams_import_rec.country = FND_API.g_miss_num THEN
      x_complete_rec.country := l_ams_import_rec.country;
   END IF;

   -- usage
   IF p_ams_import_rec.usage = FND_API.g_miss_num THEN
      x_complete_rec.usage := l_ams_import_rec.usage;
   END IF;

   -- number_of_records
   IF p_ams_import_rec.number_of_records = FND_API.g_miss_num THEN
      x_complete_rec.number_of_records := l_ams_import_rec.number_of_records;
   END IF;

   -- data_file_name
   IF p_ams_import_rec.data_file_name = FND_API.g_miss_char THEN
      x_complete_rec.data_file_name := l_ams_import_rec.data_file_name;
   END IF;

   -- b2b_flag
   IF p_ams_import_rec.b2b_flag = FND_API.g_miss_char THEN
      x_complete_rec.b2b_flag := l_ams_import_rec.b2b_flag;
   END IF;

   -- rented_list_flag
   IF p_ams_import_rec.rented_list_flag = FND_API.g_miss_char THEN
      x_complete_rec.rented_list_flag := l_ams_import_rec.rented_list_flag;
   END IF;

   -- server_flag
   IF p_ams_import_rec.server_flag = FND_API.g_miss_char THEN
      x_complete_rec.server_flag := l_ams_import_rec.server_flag;
   END IF;

   -- log_file_name
   IF p_ams_import_rec.log_file_name = FND_API.g_miss_num THEN
      x_complete_rec.log_file_name := l_ams_import_rec.log_file_name;
   END IF;

   -- number_of_failed_records
   IF p_ams_import_rec.number_of_failed_records = FND_API.g_miss_num THEN
      x_complete_rec.number_of_failed_records := l_ams_import_rec.number_of_failed_records;
   END IF;

   -- number_of_duplicate_records
   IF p_ams_import_rec.number_of_duplicate_records = FND_API.g_miss_num THEN
      x_complete_rec.number_of_duplicate_records := l_ams_import_rec.number_of_duplicate_records;
   END IF;

   -- enable_word_replacement_flag
   IF p_ams_import_rec.enable_word_replacement_flag = FND_API.g_miss_char THEN
      x_complete_rec.enable_word_replacement_flag := l_ams_import_rec.enable_word_replacement_flag;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_ams_import_Rec;
PROCEDURE Validate_import_list(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ams_import_rec               IN   ams_import_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Import_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ams_import_rec  AMS_Import_List_PVT.ams_import_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Import_List_;
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || 'inside validate_import_list');
       END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Private API: ' || 'after Compatible_API_Call');
        END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;
      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_ams_import_Items(
                 p_ams_import_rec        => p_ams_import_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Private API: ' || 'after Check_ams_import_Items');
        END IF;

      Complete_ams_import_Rec(
         p_ams_import_rec        => p_ams_import_rec,
         x_complete_rec        => l_ams_import_rec
      );
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Private API: ' || 'after Complete_ams_import_Rec');
        END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ams_import_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ams_import_rec           =>    l_ams_import_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('after Count_And_Get');
      END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Import_List_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Import_List_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Import_List_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_Import_List;


PROCEDURE Validate_ams_import_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ams_import_rec               IN    ams_import_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Validate_ams_import_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_ams_import_Rec;

END AMS_Import_List_PVT;

/
