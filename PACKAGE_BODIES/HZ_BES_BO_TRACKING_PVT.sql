--------------------------------------------------------
--  DDL for Package Body HZ_BES_BO_TRACKING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BES_BO_TRACKING_PVT" AS
/*$Header: ARHBOTVB.pls 120.1 2005/09/01 19:16:04 smattegu noship $ */
---------------------------------------------------------------------------
---------------------------------------------------------------------------
G_DEBUG_PREFIX              VARCHAR2(30) := 'HZ_BES_BOT_PVT';
---------------------------------------------------------------------------
/*
	List of internal procedures.
	do_create_bot() -- this does actual insert into bot
	do_val_mandatory() -- does check mandatory validations
	do_val_gp() -- does check for existence of grand parent info
*/
---------------------------------------------------------------------------
---------------------------------------------------------------------------
/*
  Name: do_val_lkup
	Scope: Internal
	Purpose: to check the values of some columns
*/
PROCEDURE  do_val_lkup(
  P_lkup_code  IN VARCHAR2,
  P_lkup_type    IN VARCHAR2
)IS

  -- cursor to identify if the given name is part of BOD or not.
  CURSOR c_entity IS
   SELECT distinct ENTITY_NAME
	 FROM HZ_BUS_OBJ_DEFINITIONS
   WHERE entity_name = P_lkup_code;

  -- cursor to check if there exists a valid code in the system for a given lookup type.
  CURSOR C_bo_code IS
	  SELECT 1
		 FROM  ar_lookups b
		 WHERE b.lookup_type = P_lkup_type
		 AND   b.lookup_code  = P_lkup_code;

	-- temporary variables
	l_tmp_var VARCHAR2(40);
	l_tmp_no  NUMBER;


BEGIN
	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'do_val_lkup()+',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;
/*
	 The following columns must have valid values.
  P_PARENT_BO_CODE  IN VARCHAR2,
  P_CHILD_BO_CODE   IN VARCHAR2,
	P_CHILD_TBL_NAME  IN VARCHAR2,
	P_CHILD_OPR_FLAG  IN VARCHAR2,
  P_PARENT_OPR_FLAG IN VARCHAR2,
	P_PARENT_TBL_NAME IN VARCHAR2,
	p_GPARENT_BO_CODE IN VARCHAR2


  CASE P_lkup_type
	  WHEN 'HZ_BUSINESS_OBJECTS' THEN
	    OPEN c_entity;
	    FETCH c_entity INTO l_tmp_var;
			CLOSE c_entity;
			IF l_tmp_var IS NOT NULL THEN
			  NULL;
			ELSE
				fnd_message.set_name('AR', 'HZ_API_INVALID_LOOKUP');
				fnd_message.set_token('COLUMN' ,P_lkup_code);
				fnd_message.set_token('LOOKUP_TYPE' ,P_lkup_type);
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
	  WHEN 'INSERT_UPDATE_FLAG' THEN
		  IF P_lkup_code IN ('I','U') THEN
		    NULL;
		  ELSE
				fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
				fnd_message.set_token('PARAMETER' ,P_lkup_code);
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_ERROR;
		  END IF;
	  WHEN 'HZ_BUSINESS_ENTITIES' THEN
	    OPEN C_bo_code;
	    FETCH C_bo_code INTO l_tmp_no;
			CLOSE C_bo_code;
			IF l_tmp_no IS NOT NULL THEN
			  NULL;
			ELSE
				fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
				fnd_message.set_token('PARAMETER' ,P_lkup_code);
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		ELSE
		  		RAISE FND_API.G_EXC_ERROR;
	END CASE;
*/
	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'do_val_lkup()-',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;
END do_val_lkup;
---------------------------------------------------------------------------
---------------------------------------------------------------------------
/*
  Name: do_create_bot
	Scope: Internal
	Purpose: to check mandatory validations
	Input parameters: None. Will access all the input parameters of create_bot()
	Output parameters: None.
*/
PROCEDURE  do_create_bot(
  POPULATED_FLAG        IN VARCHAR2,
  p_CHILD_BO_CODE       IN VARCHAR2,
  P_CHILD_TBL_NAME      IN VARCHAR2,
  p_CHILD_ID            IN NUMBER,
  P_CHILD_OPR_FLAG      IN VARCHAR2,
	P_CHILD_UPDATE_DT     IN DATE,
	P_CREATION_DATE       IN DATE,
  p_PARENT_BO_CODE      IN VARCHAR2,
  P_PARENT_TBL_NAME     IN VARCHAR2,
  p_PARENT_ID           IN NUMBER
)IS
   l_child_rec_exists_no     NUMBER;
BEGIN
	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'do_create_bot()+',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;
	-- check for existence of the record.
	-- if the record is not existing in BOT, only then insert.
	BEGIN
	 l_child_rec_exists_no := 0;
	 SELECT child_id INTO  l_child_rec_exists_no
	 FROM  HZ_BUS_OBJ_TRACKING
	 WHERE event_id IS NULL
	 AND CHILD_ENTITY_NAME  = P_CHILD_TBL_NAME
	 AND CHILD_ID           = p_CHILD_ID
	 AND PARENT_ENTITY_NAME = P_PARENT_TBL_NAME
	 AND PARENT_BO_CODE     = p_PARENT_BO_CODE
	 AND PARENT_ID          = p_PARENT_ID;
	 IF l_child_rec_exists_no <> 0 THEN
	   -- data already exists, no need to write
	   hz_utility_v2pub.DEBUG
	   (p_message=> 'CHILD record already exists in BOT',
	    p_prefix=>G_DEBUG_PREFIX,
	    p_msg_level=>fnd_log.level_procedure);
	 END IF;
	EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		INSERT INTO HZ_BUS_OBJ_TRACKING  (
			POPULATED_FLAG         ,
			CHILD_BO_CODE          ,
			CHILD_ENTITY_NAME      ,
			CHILD_ID             ,
			CHILD_OPERATION_FLAG ,
			LAST_UPDATE_DATE     ,
			CREATION_DATE        ,
			PARENT_BO_CODE       ,
			PARENT_ENTITY_NAME    ,
			PARENT_ID )
		VALUES (
			POPULATED_FLAG   ,
			p_CHILD_BO_CODE  ,
			P_CHILD_TBL_NAME ,
			p_CHILD_ID       ,
			P_CHILD_OPR_FLAG ,
			P_CHILD_UPDATE_DT,
			P_CREATION_DATE  ,
			p_PARENT_BO_CODE ,
			P_PARENT_TBL_NAME,
			p_PARENT_ID);
	END; -- end of anonymous block
	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'do_create_bot()-',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;
END do_create_bot;
---------------------------------------------------------------------------
/*
  Name: do_val_gp
	Scope: Internal
	Purpose: to check mandatory validations
*/
PROCEDURE  do_val_gp(
	P_CHILD_TBL_NAME   IN VARCHAR2,
  p_GPARENT_BO_CODE  IN VARCHAR2,
  P_GPARENT_TBL_NAME IN VARCHAR2,
  p_GPARENT_ID       IN NUMBER
)IS
BEGIN
	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'do_val_gp()+',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;

	IF P_CHILD_TBL_NAME IN (
		'RA_CUST_RECEIPT_METHODS',
		'IBY_FNDCPT_PAYER_ASSGN_INSTR_V')
	THEN
		CASE
			WHEN LTRIM(RTRIM(p_GPARENT_BO_CODE)) IS NULL THEN
				fnd_message.set_name('AR', 'HZ_API_NULL_PARAM');
				fnd_message.set_token('PARAMETER' ,'p_GPARENT_BO_CODE');
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_ERROR;
			WHEN (p_GPARENT_ID IS NULL OR p_GPARENT_ID = 0)THEN
				fnd_message.set_name('AR', 'HZ_API_NULL_PARAM');
				fnd_message.set_token('PARAMETER' ,'p_GPARENT_ID');
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_ERROR;
			WHEN LTRIM(RTRIM(P_GPARENT_TBL_NAME)) IS NULL THEN
				fnd_message.set_name('AR', 'HZ_API_NULL_PARAM');
				fnd_message.set_token('PARAMETER' ,'P_GPARENT_TBL_NAME');
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_ERROR;
			ELSE NULL;
		END CASE;
	END IF ;

	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'do_val_gp()-',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;
END do_val_gp;
---------------------------------------------------------------------------
---------------------------------------------------------------------------
/*
  Name: do_val_mandatory
	Scope: Internal
	Purpose: to check mandatory validations
*/
PROCEDURE  do_val_mandatory(
	P_CHILD_TBL_NAME IN VARCHAR2,
	P_CHILD_ID       IN NUMBER,
	P_CHILD_OPR_FLAG IN VARCHAR2,
	P_CHILD_UPDATE_DT IN DATE,
	P_PARENT_TBL_NAME IN VARCHAR2,
	P_PARENT_ID IN NUMBER
)IS
BEGIN
	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'do_val_mandatory()+',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;
/*
	 The following columns must be present.
   P_CHILD_TBL_NAME
   P_CHILD_ID
   P_CHILD_OPR_FLAG
	 P_CHILD_UPDATE_DT
   P_PARENT_TBL_NAME
   P_PARENT_ID
*/
	CASE
	WHEN LTRIM(RTRIM(P_CHILD_TBL_NAME)) IS NULL THEN
		fnd_message.set_name('AR', 'HZ_API_NULL_PARAM');
		fnd_message.set_token('PARAMETER' ,'P_CHILD_TBL_NAME');
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_ERROR;
	WHEN (P_CHILD_ID IS NULL OR P_CHILD_ID = 0)THEN
		fnd_message.set_name('AR', 'HZ_API_NULL_PARAM');
		fnd_message.set_token('PARAMETER' ,'P_CHILD_ID');
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_ERROR;
	WHEN LTRIM(RTRIM(P_CHILD_OPR_FLAG)) IS NULL THEN
		fnd_message.set_name('AR', 'HZ_API_NULL_PARAM');
		fnd_message.set_token('PARAMETER' ,'P_CHILD_OPR_FLAG');
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_ERROR;
	WHEN P_CHILD_UPDATE_DT IS NULL THEN
		fnd_message.set_name('AR', 'HZ_API_NULL_PARAM');
		fnd_message.set_token('PARAMETER' ,'P_CHILD_UPDATE_DT');
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_ERROR;
	WHEN P_PARENT_TBL_NAME IS NULL THEN
		fnd_message.set_name('AR', 'HZ_API_NULL_PARAM');
		fnd_message.set_token('PARAMETER' ,'P_PARENT_TBL_NAME');
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_ERROR;
	WHEN (P_PARENT_ID IS NULL OR P_PARENT_ID = 0)THEN
		fnd_message.set_name('AR', 'HZ_API_NULL_PARAM');
		fnd_message.set_token('PARAMETER' ,'P_PARENT_ID');
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_ERROR;
	ELSE NULL;
	END CASE;
	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'do_val_mandatory()-',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;
END do_val_mandatory;
---------------------------------------------------------------------------
---------------------------------------------------------------------------
PROCEDURE create_bot(
  P_INIT_MSG_LIST       IN  VARCHAR2 := FND_API.G_FALSE,
  P_CHILD_BO_CODE       IN VARCHAR2,
  P_CHILD_TBL_NAME      IN VARCHAR2,
  P_CHILD_ID            IN NUMBER,
  P_CHILD_OPR_FLAG      IN VARCHAR2,
	P_CHILD_UPDATE_DT     IN DATE,
  P_PARENT_BO_CODE      IN VARCHAR2,
  P_PARENT_TBL_NAME     IN VARCHAR2,
  P_PARENT_ID            IN NUMBER,
  P_PARENT_OPR_FLAG      IN VARCHAR2,
  P_GPARENT_BO_CODE      IN VARCHAR2,
  P_GPARENT_TBL_NAME     IN VARCHAR2,
  P_GPARENT_ID            IN NUMBER,
  X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
  X_MSG_COUNT           OUT NOCOPY    NUMBER,
  X_MSG_DATA            OUT NOCOPY    VARCHAR2
)IS

BEGIN

	-- initialize API return status to success.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.to_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'create_bot()+',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;

	SAVEPOINT cre_bot;

/* Flow:
	 . do the validations
	 . after existence checking,
	 .    insert into BOT (child info, parent info)
	 . after existence checking,
	 .  insert into BOT (paremt info as child info, grant parent info as parent info)
*/

/*  To insert first record,
	 . do the validations by calling the do_val_mandatory() procedure
	 . insert BOT (child info, parent info) by calling do_create_bot
*/

IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
  do_val_mandatory(
  	P_CHILD_TBL_NAME ,
  	P_CHILD_ID       ,
  	P_CHILD_OPR_FLAG ,
  	P_CHILD_UPDATE_DT,
  	P_PARENT_TBL_NAME,
  	P_PARENT_ID);

  do_create_bot(
  POPULATED_FLAG     => 'N',
  p_CHILD_BO_CODE    => p_CHILD_BO_CODE,
  P_CHILD_TBL_NAME   => P_CHILD_TBL_NAME,
  p_CHILD_ID         => p_CHILD_ID,
  P_CHILD_OPR_FLAG   => P_CHILD_OPR_FLAG,
  P_CHILD_UPDATE_DT  => P_CHILD_UPDATE_DT,
  P_CREATION_DATE    => P_CHILD_UPDATE_DT,
  p_PARENT_BO_CODE   => p_PARENT_BO_CODE,
  P_PARENT_TBL_NAME  => P_PARENT_TBL_NAME,
  p_PARENT_ID        => p_PARENT_ID);

  /* As a second step, create the parent, grand parent info in BOT
     . validate the grand parent info  by calling do_val_gp()
  	 . then, if rec bot existing, insert a record in BOT as.
  	    bot.child info => parent info
  	    bot.parent info => grand parent info
  */

  do_val_gp(
  	P_CHILD_TBL_NAME   ,
    p_GPARENT_BO_CODE  ,
    P_GPARENT_TBL_NAME ,
    p_GPARENT_ID);

  do_create_bot(
  POPULATED_FLAG     => 'Y',
  p_CHILD_BO_CODE    => p_PARENT_BO_CODE,
  P_CHILD_TBL_NAME   => P_PARENT_TBL_NAME,
  p_CHILD_ID         => p_PARENT_ID,
  P_CHILD_OPR_FLAG   => 'U',
  P_CHILD_UPDATE_DT  => P_CHILD_UPDATE_DT,
  P_CREATION_DATE    => P_CHILD_UPDATE_DT,
  p_PARENT_BO_CODE   => P_GPARENT_BO_CODE,
  P_PARENT_TBL_NAME  => P_GPARENT_TBL_NAME,
  p_PARENT_ID        => P_GPARENT_ID);

END IF; -- profile check

	-- Debug info.
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(
			p_message=>'create_bot()-',
			p_prefix=>G_DEBUG_PREFIX,
			p_msg_level=>fnd_log.level_procedure);
	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
	    ROLLBACK TO cre_bot;
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bot()-',
                               p_prefix=>G_DEBUG_PREFIX,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
	    ROLLBACK TO cre_bot;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bot()-',
                               p_prefix=>G_DEBUG_PREFIX,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
	    ROLLBACK TO cre_bot;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bot()-',
                               p_prefix=>G_DEBUG_PREFIX,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
END create_bot;
---------------------------------------------------------------------------
END HZ_BES_BO_TRACKING_PVT;

/
