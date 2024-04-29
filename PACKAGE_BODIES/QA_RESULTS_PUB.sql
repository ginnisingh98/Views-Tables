--------------------------------------------------------
--  DDL for Package Body QA_RESULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_RESULTS_PUB" AS
/* $Header: qltpresb.plb 120.3.12010000.2 2008/11/12 11:49:41 rvalsan ship $ */


    g_pkg_name CONSTANT VARCHAR2(30):= 'qa_results_pub';
    g_message_table mesg_table;

--  Start of comments
--
--	API name 	: insert_row
--	Type		: Public
--	Function	: insert_row
--	Pre-reqs	: None.
--
--  End of comments


PROCEDURE populate_message_table IS

BEGIN

    g_message_table(qa_validation_api.not_enabled_error) :=
        'QA_API_NOT_ENABLED';
    g_message_table(qa_validation_api.no_values_error) := 'QA_API_NO_VALUES';
    g_message_table(qa_validation_api.mandatory_error) := 'QA_API_MANDATORY';
    g_message_table(qa_validation_api.not_revision_controlled_error) :=
        'QA_API_REVISION_CONTROLLED';
    g_message_table(qa_validation_api.mandatory_revision_error) :=
     	'QA_API_MANDATORY_REVISION';
    g_message_table(qa_validation_api.no_values_error) := 'QA_API_NO_VALUES';
    g_message_table(qa_validation_api.keyflex_error) := 'QA_API_KEYFLEX';
    g_message_table(qa_validation_api.id_not_found_error) :=
        'QA_API_ID_NOT_FOUND';
    g_message_table(qa_validation_api.spec_limit_error) := 'QA_API_SPEC_LIMIT';
    g_message_table(qa_validation_api.immediate_action_error) :=
        'QA_API_IMMEDIATE_ACTION';
    g_message_table(qa_validation_api.lower_limit_error) :=
        'QA_API_LOWER_LIMIT';
    g_message_table(qa_validation_api.upper_limit_error) :=
        'QA_API_UPPER_LIMIT';
    g_message_table(qa_validation_api.value_not_in_sql_error) :=
        'QA_API_VALUE_NOT_IN_SQL';
    g_message_table(qa_validation_api.sql_validation_error) :=
        'QA_API_SQL_VALIDATION';
    g_message_table(qa_validation_api.date_conversion_error) :=
        'QA_API_INVALID_DATE';
    g_message_table(qa_validation_api.data_type_error) := 'QA_API_DATA_TYPE';
    g_message_table(qa_validation_api.number_conversion_error) :=
        'QA_API_INVALID_NUMBER';
    g_message_table(qa_validation_api.no_data_found_error) :=
        'QA_API_NO_DATA_FOUND';
    g_message_table(qa_validation_api.not_locator_controlled_error) :=
        'QA_API_NOT_LOCATOR_CONTROLLED';
    g_message_table(qa_validation_api.item_keyflex_error) :=
        'QA_API_ITEM_KEYFLEX';
    g_message_table(qa_validation_api.comp_item_keyflex_error) :=
        'QA_API_COMP_ITEM_KEYFLEX';
    g_message_table(qa_validation_api.locator_keyflex_error) :=
        'QA_API_LOCATOR_KEYFLEX';
    g_message_table(qa_validation_api.comp_locator_keyflex_error) :=
        'QA_API_COMP_LOCATOR_KEYFLEX';
    g_message_table(qa_validation_api.invalid_number_error) :=
        'QA_API_INVALID_NUMBER';
    g_message_table(qa_validation_api.invalid_date_error) :=
        'QA_API_INVALID_DATE';
    g_message_table(qa_validation_api.spec_error) := 'QA_API_SPEC';
    g_message_table(qa_validation_api.ok) := 'QA_API_NO_ERROR';
    g_message_table(qa_validation_api.unknown_error) := 'QA_API_UNKNOWN';
    g_message_table(qa_validation_api.reject_an_entry_error) :=
        'QA_API_REJECT_AN_ENTRY';


       -- Bug 3679762.Initialising the message array for the "missing assign a value target
       -- column" error message.
       -- srhariha.Wed Jun 16 06:54:06 PDT 2004

    g_message_table(qa_validation_api.missing_assign_column) :=
        'QA_MISSING_ASSIGN_COLUMN';

END populate_message_table;

    -- Added an argument plan_id for the Procedure post_error_messages
    -- which would be used to get the collection element prompt from
    -- qa_plan_element_api.get_prompt and which in turn will be used
    -- in the error messages shown to the user.
    -- Bug 2910202.suramasw.Wed May 14 23:29:55 PDT 2003.

PROCEDURE post_error_messages (p_errors IN qa_validation_api.ErrorArray,plan_id NUMBER)
    IS

    l_message_name VARCHAR2(30);
    l_char_prompt VARCHAR2(100);

BEGIN

    FOR i IN p_errors.FIRST .. p_errors.LAST LOOP
	l_message_name := g_message_table(p_errors(i).error_code);
        l_char_prompt := qa_plan_element_api.get_prompt(plan_id,p_errors(i).element_id);

	fnd_message.set_name('QA', l_message_name);
	fnd_message.set_token('CHAR_ID', p_errors(i).element_id);
        fnd_message.set_token('CHAR_PROMPT',l_char_prompt);
        fnd_msg_pub.add();
    END LOOP;

END post_error_messages;

--
-- 12.1 QWB Usablility improvement
-- Added the parameter p_ssqr_operation to make
-- sure that the validation is not done againg while
-- inserting the data through QWB application
--
PROCEDURE insert_row (
    p_api_version          	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit			IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    p_plan_id               	IN  	NUMBER,
    p_spec_id               	IN  	NUMBER DEFAULT NULL,
    p_org_id                	IN  	NUMBER,
    p_transaction_number    	IN  	NUMBER DEFAULT NULL,
    p_transaction_id        	IN  	NUMBER DEFAULT NULL,
    p_who_last_updated_by   	IN  	NUMBER := fnd_global.user_id,
    p_who_created_by        	IN  	NUMBER := fnd_global.user_id,
    p_who_last_update_login 	IN  	NUMBER := fnd_global.user_id,
    p_enabled_flag	      	IN  	NUMBER,
    x_collection_id         	IN OUT  NOCOPY NUMBER,
    x_row_elements          	IN OUT 	NOCOPY qa_validation_api.ElementsArray,
    x_return_status		OUT	NOCOPY VARCHAR2,
    x_msg_count			OUT	NOCOPY NUMBER,
    x_msg_data			OUT	NOCOPY VARCHAR2,
    x_occurrence            	IN OUT 	NOCOPY NUMBER,
    x_action_result		OUT 	NOCOPY VARCHAR2,
    x_message_array 		OUT 	NOCOPY qa_validation_api.MessageArray,
    x_error_array 		OUT 	NOCOPY qa_validation_api.ErrorArray,
    p_txn_header_id             IN      NUMBER DEFAULT NULL,
    p_ssqr_operation            IN      NUMBER DEFAULT NULL,
    p_last_update_date          IN      DATE   DEFAULT SYSDATE) IS

    l_api_name			CONSTANT VARCHAR2(30)	:= 'insert_row';
    l_api_version		CONSTANT NUMBER 	:= 1.0;
    l_action_return		BOOLEAN;
    l_error_found		BOOLEAN;


BEGIN
    -- Standard Start of API savepoint

    SAVEPOINT	insert_row_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 2290747.Added parameter p_txn_header_id to enable
    -- history plan record when parent plan gets updated
    -- rponnusa Mon Apr  1 22:25:49 PST 2002
    -- 12.1 QWB Usability Improvements
    -- Passing the value for the p_ssqr_operation parameter
    -- so that the validation is not called while inserting
    -- rows through the QWB application.
    --
    x_error_array := qa_results_api.insert_row(p_plan_id,
                                               p_spec_id,
                                               p_org_id,
                                               p_transaction_number,
                                               p_transaction_id,
                                               x_collection_id,
                                               p_who_last_updated_by,
                                               p_who_created_by,
                                               p_who_last_update_login,
                                               p_enabled_flag,
                                               FND_API.To_Boolean(p_commit),
                                               l_error_found,
                                               x_occurrence,
                                               l_action_return,
                                               x_message_array,
                                               x_row_elements,
                                               p_txn_header_id,
                                               p_ssqr_operation,
                                               p_last_update_date
                                              );

    IF (l_error_found = TRUE) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        -- Added the argument p_plan_id.
        -- Bug 2910202.suramasw.Wed May 14 23:29:55 PDT 2003.

	        --
 	        -- Bug 7552630
 	        -- Making a call to the post_error_messages API in
 	        -- qa_ss_results package since that API does appropriate
 	        -- handling of the error messages raised by the reject
 	        -- an input action which was fixed in bug 5307450
 	        --
 	        -- post_error_messages(x_error_array,p_plan_id);
 	        qa_ss_results.post_error_messages(p_errors => x_error_array,
 	                                          plan_id  => p_plan_id);
    -- Bug 5355933. Do not call commit if above returns error
    -- saugupta Wed, 26 Jul 2006 03:57:30 -0700 PDT
    ELSE
      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT;
      END IF;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO insert_row_pub;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO insert_row_pub;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN OTHERS THEN
	ROLLBACK TO insert_row_pub;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       	    FND_MSG_PUB.Add_Exc_Msg
    	    (G_PKG_NAME,
    	     l_api_name
	    );
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

END insert_row;


-- anagarwa Sep 30 2003
-- SSQR project relies upon txn_header_id to enable and fire actions
-- update_row is hence modified to take in txn_header_id
--
-- 12.1 QWB Usability Improvements
-- Added a new parameter p_ssqr_operation
-- so that the validation is not called while updating
-- rows through the QWB application.
--
PROCEDURE update_row (
    p_api_version          	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit			IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    p_plan_id               	IN  	NUMBER,
    p_spec_id               	IN  	NUMBER DEFAULT NULL,
    p_org_id                	IN  	NUMBER,
    p_transaction_number    	IN  	NUMBER DEFAULT NULL,
    p_transaction_id        	IN  	NUMBER DEFAULT NULL,
    p_who_last_updated_by   	IN  	NUMBER := fnd_global.user_id,
    p_who_created_by        	IN  	NUMBER := fnd_global.user_id,
    p_who_last_update_login 	IN  	NUMBER := fnd_global.user_id,
    p_enabled_flag	      	IN  	NUMBER,
    p_collection_id         	IN      NUMBER,
    p_occurrence            	IN 	NUMBER,
    x_row_elements          	IN OUT 	NOCOPY qa_validation_api.ElementsArray,
    x_return_status		OUT	NOCOPY VARCHAR2,
    x_msg_count			OUT	NOCOPY NUMBER,
    x_msg_data			OUT	NOCOPY VARCHAR2,
    x_action_result		OUT 	NOCOPY VARCHAR2,
    x_message_array 		OUT 	NOCOPY qa_validation_api.MessageArray,
    x_error_array 		OUT 	NOCOPY qa_validation_api.ErrorArray,
    p_txn_header_id             IN      NUMBER DEFAULT NULL,
    p_ssqr_operation            IN      NUMBER DEFAULT NULL,
    p_last_update_date          IN      DATE   DEFAULT SYSDATE) IS

    l_api_name			CONSTANT VARCHAR2(30)	:= 'update_row';
    l_api_version		CONSTANT NUMBER 	:= 1.0;
    l_action_return		BOOLEAN;
    l_error_found		BOOLEAN;


BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT	update_row_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- 12.1 QWB Usability Improvements
    -- Passing the value for the p_ssqr_operation parameter
    -- so that the validation is not called while updating
    -- rows through the QWB application.
    --
    x_error_array := qa_results_api.update_row(p_plan_id,
                                               p_spec_id,
                                               p_org_id,
                                               p_transaction_number,
                                               p_transaction_id,
                                               p_collection_id,
                                               p_who_last_updated_by,
                                               p_who_created_by,
                                               p_who_last_update_login,
                                               p_enabled_flag,
                                               FND_API.To_Boolean(p_commit),
                                               l_error_found,
                                               p_occurrence,
                                               l_action_return,
                                               x_message_array,
                                               x_row_elements,
                                               p_txn_header_id,
                                               p_ssqr_operation,
                                               p_last_update_date
                                              );


    IF (l_error_found = TRUE) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_row_pub;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_row_pub;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN OTHERS THEN
	ROLLBACK TO update_row_pub;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       	    FND_MSG_PUB.Add_Exc_Msg
    	    (G_PKG_NAME,
    	     l_api_name
	    );
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

END update_row;


PROCEDURE enable_and_fire_action (
    p_api_version      	IN	NUMBER,
    p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    p_collection_id	IN	NUMBER,
    x_return_status	OUT 	NOCOPY VARCHAR2,
    x_msg_count		OUT 	NOCOPY NUMBER,
    x_msg_data		OUT 	NOCOPY VARCHAR2) IS

    l_api_name		CONSTANT VARCHAR2(30)	:= 'enable_and_fire_action';
    l_api_version	CONSTANT NUMBER 	:= 1.0;
    l_error_found	BOOLEAN;


BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT	enable_and_fire_actions_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to error
    x_return_status := FND_API.G_RET_STS_ERROR;

    qa_results_api.enable_and_fire_action(p_collection_id);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO enable_fire_actions_pub;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO enable_fire_actions_pub;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN OTHERS THEN
	ROLLBACK TO enable_fire_actions_pub;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       	    FND_MSG_PUB.Add_Exc_Msg
    	    (G_PKG_NAME,
    	     l_api_name
	    );
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

END enable_and_fire_action;


PROCEDURE commit_qa_results (
    p_api_version      	IN	NUMBER,
    p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    p_collection_id	IN	NUMBER,
    x_return_status	OUT 	NOCOPY VARCHAR2,
    x_msg_count		OUT 	NOCOPY NUMBER,
    x_msg_data		OUT 	NOCOPY VARCHAR2) IS

    l_api_name		CONSTANT VARCHAR2(30)	:= 'enable_and_fire_actions';
    l_api_version	CONSTANT NUMBER 	:= 1.0;
    l_error_found	BOOLEAN;


BEGIN

    -- Standard Start of API savepoint

    SAVEPOINT	commit_qa_results_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to error
    x_return_status := FND_API.G_RET_STS_ERROR;

    qa_results_api.commit_qa_results(p_collection_id);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO commit_qa_results_pub;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO qa_results_pub;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN OTHERS THEN
	ROLLBACK TO commit_qa_results_pub;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       	    FND_MSG_PUB.Add_Exc_Msg
    	    (G_PKG_NAME,
    	     l_api_name
	    );
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

END commit_qa_results;

BEGIN

    populate_message_table;

END qa_results_pub;


/
