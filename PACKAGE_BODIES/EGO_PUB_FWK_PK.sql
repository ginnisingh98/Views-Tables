--------------------------------------------------------
--  DDL for Package Body EGO_PUB_FWK_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_PUB_FWK_PK" AS
/* $Header: EGOPFWKB.pls 120.0.12010000.15 2009/10/22 23:14:31 trudave noship $*/

/*----------------------------------------------------------------------------+
| Copyright (c) 2003 Oracle Corporation    RedwoodShores, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : EGOPFWKB.pls
|
|DESCRIPTION :
|
-- Start of comments
--	API name 	:
--	Type		:
--	Function	:
--	Pre-reqs	:
--	Parameters	:
--	IN		:
--	OUT		:
-- End of comments
*/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'EGO_PUB_FWK_PK';


--Start procedural declaration
PROCEDURE process_entities
(  p_batch_id        IN NUMBER
  ,x_return_status	OUT	  NOCOPY 		VARCHAR2
	,x_msg_count	    OUT	  NOCOPY		NUMBER
	,x_msg_data	      OUT	  NOCOPY		VARCHAR2
);


PROCEDURE Basic_Validation(
	p_batch_id IN NUMBER
	,p_mode In Number
	,x_return_status  OUT NOCOPY  VARCHAR2
	,x_msg_count      OUT NOCOPY  NUMBER
	,x_msg_data       OUT NOCOPY  VARCHAR2);


Procedure validate_batch_id(p_batch_id In Number
			    ,x_return_status  OUT NOCOPY  VARCHAR2
		            ,x_msg_count      OUT NOCOPY  NUMBER
	                    ,x_msg_data       OUT NOCOPY  VARCHAR2);

Procedure validateStatus(p_batch_id In Number);

Procedure valdiateBatSystem(p_batch_id IN Number);

Procedure validateBatSysEnt(p_batch_id IN Number);

Procedure Process_Pub_Status(
        p_mode IN Number
	,p_batch_id IN Number
        ,x_return_status  OUT NOCOPY  VARCHAR2
	,x_msg_count      OUT NOCOPY  NUMBER
	,x_msg_data       OUT NOCOPY  VARCHAR2
);

FUNCTION calc_return_status(p_batch_id IN NUMBER) RETURN VARCHAR2;
--end procedural declaration

PROCEDURE add_derived_entities
(
   der_bat_ent_objs  IN TBL_OF_BAT_ENT_OBJ_TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
)
IS
user_entered  CHAR1_ARR_TBL_TYPE;
pk1_value     CHAR150_ARR_TBL_TYPE;
pk2_value     CHAR150_ARR_TBL_TYPE;
pk3_value     CHAR150_ARR_TBL_TYPE;
pk4_value     CHAR150_ARR_TBL_TYPE;
pk5_value     CHAR150_ARR_TBL_TYPE;

l_batch_id NUMBER;
EGO_NO_DERIVED_ENTITIES  EXCEPTION;
EGO_PUB_BATCHID_NULL  EXCEPTION;
l_stmt_num NUMBER;
--i	NUMBER; --FOR LOOP


BEGIN --Procedure add_derived_entities

  l_stmt_num := 0;
delete from Ego_Publication_Batch_GT;
  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.add_derived_entities'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.add_derived_entities ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --check if  der_bat_ent_objs is null
  --return error message
  IF ( der_bat_ent_objs.count() = 0 OR der_bat_ent_objs IS NULL )  THEN
    RAISE EGO_NO_DERIVED_ENTITIES;
  END IF;

  l_batch_id := der_bat_ent_objs(1).batch_id;

   l_stmt_num := 5;
   validate_batch_id(p_batch_id => l_batch_id
				   ,x_return_status => x_return_status
				    ,x_msg_count => x_msg_count
                                    ,x_msg_data => x_msg_data
				   );

  If (x_return_status = C_FAILED) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
  Elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  End if;

/*  IF ( l_batch_id IS NULL )  THEN
    RAISE EGO_PUB_BATCHID_NULL;
  END IF;*/

  l_stmt_num := 10;

  EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                     ,p_module => 'EGO_PUB_FWK_PK.add_derived_entities'
                                     ,p_message =>' i --' ||
                                                  ' pk1_value(i) --' ||
                                                  ' pk2_value(i) --' ||
                                                  ' pk3_value(i) --' ||
                                                  ' pk4_value(i) --' ||
                                                  ' pk5_value(i) --' ||
                                                  ' user_entered(i)' );
  FOR i IN der_bat_ent_objs.FIRST..der_bat_ent_objs.LAST LOOP
    pk1_value(i) := der_bat_ent_objs(i).pk1_value;
    pk2_value(i) := der_bat_ent_objs(i).pk2_value;
    pk3_value(i) := der_bat_ent_objs(i).pk3_value;
    pk4_value(i) := der_bat_ent_objs(i).pk4_value;
    pk5_value(i) := der_bat_ent_objs(i).pk5_value;
    user_entered(i) := nvl(der_bat_ent_objs(i).user_entered, C_NO);
    EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                     ,p_module => 'EGO_PUB_FWK_PK.add_derived_entities'
                                     ,p_message =>  i || ' --' ||
                                                  der_bat_ent_objs(i).pk1_value || ' --' ||
                                                  der_bat_ent_objs(i).pk2_value || ' --' ||
                                                  der_bat_ent_objs(i).pk3_value || ' --' ||
                                                  der_bat_ent_objs(i).pk4_value || ' --' ||
                                                  der_bat_ent_objs(i).pk5_value || ' --' ||
                                                  der_bat_ent_objs(i).user_entered );

  END LOOP;

  l_stmt_num := 20;
  FORALL i IN pk1_value.FIRST..pk1_value.LAST
    INSERT INTO EGO_PUBLICATION_BATCH_GT
    (
         Batch_id
        ,Pk1_Value
        ,Pk2_value
        ,Pk3_value
        ,Pk4_Value
        ,Pk5_value
        ,user_entered
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_LOGIN

    )
    VALUES
    (
         l_batch_id
        ,pk1_value(i)
        ,pk2_value(i)
        ,pk3_value(i)
        ,pk4_value(i)
        ,pk5_value(i)
        ,user_entered(i)
        ,SYSDATE
        ,FND_GLOBAL.USER_ID
        ,SYSDATE
        ,FND_GLOBAL.USER_ID
        ,FND_GLOBAL.LOGIN_ID
    );
    EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                     ,p_module => 'EGO_PUB_FWK_PK.add_derived_entities'
                                     ,p_message => 'lStmtNum=' || to_char(l_stmt_num)
                                     ||' ' || sql%rowcount || ' rows are inserted into EGO_PUBLICATION_BATCH_GT.');


  l_stmt_num := 30;
  process_entities ( p_batch_id => l_batch_id
                      ,x_return_status => x_return_status
                      ,x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);

--we need to check return messages
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  delete from EGO_PUBLICATION_BATCH_GT;

  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.add_derived_entities'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.add_derived_entities successfully... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

  EXCEPTION
    WHEN EGO_NO_DERIVED_ENTITIES THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_EXCEPTION
                                      ,p_module  => 'EGO_PUB_FWK_PK.add_derived_entities'
                                      ,p_message  => 'Exception EGO_NO_DERIVED_ENTITIES in stmt num: ' || l_stmt_num|| ': '||'sqlerrm=>' ||sqlerrm);


      EGO_UTIL_PK.put_fnd_stack_msg (p_appln_short_name=>'EGO'
                                       ,p_message =>'EGO_NO_DERIVED_ENTITIES');
      x_return_status := FND_API.G_RET_STS_ERROR;
      EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                    ,p_msg_data  => x_msg_data );
    WHEN EGO_PUB_BATCHID_NULL THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_EXCEPTION
                                      ,p_module  => 'EGO_PUB_FWK_PK.add_derived_entities'
                                      ,p_message  => 'Exception EGO_PUB_BATCHID_NULL in stmt num: ' || l_stmt_num|| ': '||'sqlerrm=>' ||sqlerrm );
      EGO_UTIL_PK.put_fnd_stack_msg (p_appln_short_name=>'EGO'
                                       ,p_message =>'EGO_PUB_BATCHID_NULL');
      x_return_status := FND_API.G_RET_STS_ERROR;
      EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                    ,p_msg_data  => x_msg_data );

    WHEN FND_API.G_EXC_ERROR THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_EXCEPTION
                                     ,p_module  => 'EGO_PUB_FWK_PK.add_derived_entities'
                                     ,p_message  => 'Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );

      x_return_status := FND_API.G_RET_STS_ERROR;
      EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                    ,p_msg_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                    ,p_module  => 'EGO_PUB_FWK_PK.add_derived_entities'
                                    ,p_message  => 'Unexpedted Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                    ,p_msg_data  => x_msg_data );

    WHEN OTHERS THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                      ,p_module  => 'EGO_PUB_FWK_PK.add_derived_entities'
                                      ,p_message  => 'Others Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                    ,p_msg_data  => x_msg_data );

END add_derived_entities;


PROCEDURE process_entities
(  p_batch_id        IN NUMBER
  ,x_return_status	OUT	  NOCOPY 		VARCHAR2
	,x_msg_count	    OUT	  NOCOPY		NUMBER
	,X_msg_data	      OUT	  NOCOPY		VARCHAR2
)
IS


l_bat_ent_obj_id  NUMBER;
l_system_code     VARCHAR2(30); --Fixed number 30 is fine? Is it possible to use TYPE%cur_systems

t_batch_ent_obj_id  NUMBER_ARR_TBL_TYPE;
t_system_code       CHAR30_ARR_TBL_TYPE;

EGO_NO_BATCH_SYSTEMS  EXCEPTION;
l_stmt_num NUMBER;
--i	NUMBER; --FOR LOOP

BEGIN
  l_stmt_num := 0;
  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.add_derived_entities'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.process_entities ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 10;
  INSERT INTO Ego_Pub_Bat_Ent_Objs_B
  ( Batch_Entity_Object_id
    ,Batch_id
    ,PK1_value
    ,PK2_value
    ,PK3_value
    ,PK4_value
    ,PK5_value
    ,user_entered
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_LOGIN
    ,object_version_number
  )
  SELECT
     Ego_Pub_Bat_Ent_Objs_S1.NEXTVAL
    ,Batch_Id
    ,Pk1_Value
    ,Pk2_Value
    ,Pk3_Value
    ,Pk4_Value
    ,Pk5_Value
    ,User_Entered
    ,SYSDATE
    ,FND_GLOBAL.USER_ID
    ,SYSDATE
    ,FND_GLOBAL.USER_ID
    ,FND_GLOBAL.LOGIN_ID
    ,1
  FROM Ego_Publication_Batch_GT
  WHERE Batch_Id = p_batch_id;
  EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                   ,p_module => 'EGO_PUB_FWK_PK.process_entities'
                                   ,p_message => 'lStmtNum=' || to_char(l_stmt_num)
                                   ||' ' || sql%rowcount || ' rows are inserted into EGO_PUB_BAT_ENT_OBJS_B.');


  l_stmt_num := 20;
  SELECT   Batch_Entity_Object_id
          ,System_Code
  BULK COLLECT INTO
           t_batch_ent_obj_id
          ,t_system_code
  FROM  Ego_Pub_Bat_Ent_Objs_B EO,
        EGO_PUB_BAT_SYSTEMS_B SYS
  WHERE EO.Batch_Id = p_batch_id
  AND   EO.User_Entered = C_NO
  AND   SYS.Batch_Id = EO.Batch_Id;

  IF t_system_code.count() = 0 THEN
    RAISE EGO_NO_BATCH_SYSTEMS;
  END IF;

  EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                   ,p_module => 'EGO_PUB_FWK_PK.process_entities'
                                   ,p_message => 'i'|| '---' || 't_batch_ent_obj_id(i)' || '---'|| 't_system_code(i)'
                                   );
  FOR i in t_batch_ent_obj_id.FIRST..t_batch_ent_obj_id.LAST
  LOOP
    EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                     ,p_module => 'EGO_PUB_FWK_PK.process_entities'
                                     ,p_message => i ||'---' || t_batch_ent_obj_id(i) || '---'|| t_system_code(i)
                                   );
  END LOOP; --for debugging message


  l_stmt_num := 30;
  FORALL i in t_batch_ent_obj_id.FIRST..t_batch_ent_obj_id.LAST
        INSERT INTO Ego_Pub_Bat_Status_B
        (
           Batch_Id
          ,System_Code
          ,Batch_Entity_Object_id
          ,Status_Code
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,object_version_number
        )
        VALUES
        (
           p_batch_id
          ,t_system_code(i)
          ,t_batch_ent_obj_id(i)
          ,C_IN_PROCESS
          ,SYSDATE
          ,FND_GLOBAL.USER_ID
          ,SYSDATE
          ,FND_GLOBAL.USER_ID
          ,FND_GLOBAL.LOGIN_ID
          ,1
        );
  EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                   ,p_module => 'EGO_PUB_FWK_PK.process_entities'
                                   ,p_message => 'lStmtNum=' || to_char(l_stmt_num)
                                   ||' ' || sql%rowcount || ' rows are inserted into EGO_PUB_BAT_STATUS_B.');

  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.add_derived_entities'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.process_entities successfully... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

  EXCEPTION
    WHEN EGO_NO_BATCH_SYSTEMS THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_EXCEPTION
                                     ,p_module  => 'EGO_PUB_FWK_PK.process_entities'
                                     ,p_message => 'Exception EGO_NO_BATCH_SYSTEMS in stmt num: '||l_stmt_num || ':' ||'sqlerrm=>'|| sqlerrm);
      EGO_UTIL_PK.put_fnd_stack_msg (p_appln_short_name=>'EGO'
                                       ,p_message =>'EGO_NO_BATCH_SYSTEMS');
      x_return_status := FND_API.G_RET_STS_ERROR;
      EGO_UTIL_PK.count_and_get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data );

    WHEN OTHERS THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                     ,p_module  => 'EGO_PUB_FWK_PK.process_entities'
                                     ,p_message => 'Others Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      EGO_UTIL_PK.count_and_get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data );


END process_entities;

--Returns S =Success
--          F = failure
--	  W = warning
--	  U= Unexpected Error
Procedure Update_Pub_Status_Thru_AIA(p_batch_id IN NUMBER
				    ,p_mode In Number
				    ,x_return_status  OUT NOCOPY  VARCHAR2
				    ,x_msg_count      OUT NOCOPY  NUMBER
	                            ,x_msg_data       OUT NOCOPY  VARCHAR2)
IS
  l_stmt_num NUMBER;
  l_ret_status VARCHAR2(1);

dbg_pk1_value     CHAR150_ARR_TBL_TYPE;
dbg_pk2_value     CHAR150_ARR_TBL_TYPE;
dbg_pk3_value     CHAR150_ARR_TBL_TYPE;
dbg_pk4_value     CHAR150_ARR_TBL_TYPE;
dbg_pk5_value     CHAR150_ARR_TBL_TYPE;
t_dbg_batchid 	NUMBER_ARR_TBL_TYPE;
t_dbg_system_code   CHAR30_ARR_TBL_TYPE;
t_dbg_err_msg_lang CHAR4_ARR_TBL_TYPE;
t_dbg_status	CHAR1_ARR_TBL_TYPE;
t_dbg_msg CHAR_ARR_TBL_TYPE;
t_dbg_err_code CHAR_ARR_TBL_TYPE;

BEGIN
     l_stmt_num := 0;

     EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.Update_Pub_Status_Thru_AIA'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.Update_Pub_Status_Thru_AIA ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));






	Basic_Validation(
		          p_batch_id => p_batch_id
	                 ,p_mode => p_mode
	                 ,x_return_status => x_return_status
			 ,x_msg_count => x_msg_count
			 ,x_msg_data =>x_msg_data);

        If (x_return_status = C_FAILED) THEN
		return;
	Elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
		--revisit
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	End if;

	--debug statement to look at Input GT data
	 Select  Batch_id
		,System_Code
		,Pk1_Value
		,Pk2_value
		,Pk3_value
		,Pk4_Value
		,Pk5_value
		,Status
		,Message
	   BULK COLLECT INTO
		t_dbg_batchid
	       ,t_dbg_system_code
	       ,dbg_pk1_value
	       ,dbg_pk2_value
	       ,dbg_pk3_value
	       ,dbg_pk4_value
	       ,dbg_pk5_value
	       ,t_dbg_status
	       ,t_dbg_msg
	   FROM Ego_Publication_Batch_GT
	   WHERE Batch_id = p_batch_id;


	   EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
					     ,p_module => 'EGO_PUB_FWK_PK.Update_Pub_Status_Thru_AIA'
					     ,p_message =>' i --' ||
							  ' batch_id(i) --' ||
							  ' pk1_value(i) --' ||
							  ' pk2_value(i) --' ||
							  ' pk3_value(i) --' ||
							  ' pk4_value(i) --' ||
							  ' pk5_value(i) --' ||
							  ' system_code(i) --' ||
							  ' status(i) --' ||
							  ' msg(i)--'
							   );

	FOR i IN t_dbg_batchid.FIRST..t_dbg_batchid.LAST LOOP
		 EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
				,p_module => 'EGO_PUB_FWK_PK.Update_Pub_Status_Thru_AIA'
				,p_message =>  i || ' --' ||
				     t_dbg_batchid(i) || ' --' ||
				     dbg_pk1_value(i) || ' --' ||
				     dbg_pk2_value(i) || ' --' ||
				     dbg_pk3_value(i) || ' --' ||
				     dbg_pk4_value(i) || ' --' ||
				     dbg_pk5_value(i) || ' --' ||
				     t_dbg_system_code(i) || ' --' ||
				     t_dbg_status(i)|| ' --' ||
				     t_dbg_msg(i)
				     );
	  END LOOP;

	Process_Pub_Status(
			 p_mode  => p_mode
			,p_batch_id => p_batch_id
			,x_return_status  => l_ret_status
			,x_msg_count   => x_msg_count
			,x_msg_data   => x_msg_data)
;

        IF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  x_return_status := l_ret_status;
	  return;
	END IF;

	x_return_status := calc_return_status(p_batch_id=>p_batch_id);

	EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
					      ,p_module  => 'EGO_PUB_FWK_PK.Update_Pub_Status_Thru_AIA'
					      ,p_message  => 'Exit EGO_PUB_FWK_PK.Update_Pub_Status_Thru_AIA successfully... '
					      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));




Exception

  When OTHERS Then
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                    ,p_module  => 'EGO_PUB_FWK_PK.Update_Pub_Status_Thru_AIA'
                                    ,p_message  => 'Unexpedted Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                    ,p_msg_data  => x_msg_data );


END Update_Pub_Status_Thru_AIA;

FUNCTION calc_return_status(p_batch_id IN NUMBER)
RETURN VARCHAR2
IS
l_ct_S NUMBER  ;
l_ct_bat NUMBER;
 l_stmt_num NUMBER;
BEGIN
  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.calc_return_status'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.calc_return_status ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

  BEGIN
           l_stmt_num := 10;
	  Select count(*)
	  into l_ct_S
	  from ego_publication_batch_gt
	  WHERE batch_id = p_batch_id
	  and RETURN_STATUS = C_SUCCESS;
  EXCEPTION
  WHEN no_data_found THEN
    return C_FAILED;
  END;

  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_STATEMENT
                                      ,p_module  => 'EGO_PUB_FWK_PK.calc_return_status'
                                      ,p_message  => 'row_count_Success=> '||l_ct_S
                                      );

  IF l_ct_S = 0 THEN
     l_stmt_num := 20;
    return C_FAILED;
  END IF;

  l_stmt_num := 30;
  select count(*)
  into l_ct_bat
  from ego_publication_batch_gt
  WHERE batch_id = p_batch_id;

  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_STATEMENT
                                      ,p_module  => 'EGO_PUB_FWK_PK.calc_return_status'
                                      ,p_message  => 'total rows=> '||l_ct_bat
                                      );

  IF l_ct_bat = l_ct_S THEN
    l_stmt_num := 40;
    return  C_SUCCESS;
  ELSE
    l_stmt_num := 50;
    return C_WARNING;

  END IF;

   EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.calc_return_status'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.calc_return_status ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

END calc_return_status;


--Basic Validation Validates batchId and Mode
PROCEDURE Basic_Validation(
		           p_batch_id IN NUMBER
	                 ,p_mode In Number
	                 ,x_return_status  OUT NOCOPY  VARCHAR2
			 ,x_msg_count      OUT NOCOPY  NUMBER
			 ,x_msg_data       OUT NOCOPY  VARCHAR2)
IS
-- l_ret_status VARCHAR2(1);
 l_stmt_num NUMBER;

 EGO_INVALID_MODE Exception;
BEGIN
  l_stmt_num := 0;
   EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.Basic_Validation'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.Basic_Validation ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

   x_return_status := C_SUCCESS;

   l_stmt_num := 10;
   validate_batch_id(p_batch_id => p_batch_id
				   ,x_return_status => x_return_status
				    ,x_msg_count => x_msg_count
                                    ,x_msg_data => x_msg_data
				   );

  If (x_return_status = C_FAILED) THEN
      return;
  Elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  End if;

 l_stmt_num := 20;
 -- 8773131 for mode validation, added mode C_BATCH_MODE
 If ( nvl(p_mode,-99) not in (C_BATCH_MODE, C_BATCH_SYSTEM_MODE,
		   C_BATCH_SYSTEM_ENTITY_MODE)) THEN
    Raise EGO_INVALID_MODE;
 END IF;

 EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.Basic_Validation'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.Basic_Validation ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

Exception

  When FND_API.G_EXC_UNEXPECTED_ERROR Then
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                    ,p_module  => 'EGO_PUB_FWK_PK.Basic_validation'
                                    ,p_message  => 'Unexpedted Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                    ,p_msg_data  => x_msg_data );


  When EGO_INVALID_MODE Then
     EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                    ,p_module  => 'EGO_PUB_FWK_PK.Basic_validation'
                                    ,p_message  => 'Inavlid Batch mode in stmt num: ' || l_stmt_num );

       l_stmt_num := 30;
       Update ego_publication_batch_gt
	set return_status = C_FAILED,
	    return_error_code = 'EGO_INVALID_MODE',
	     return_error_message  = FND_MESSAGE.get_string ('EGO', 'EGO_INVALID_MODE'),
	   ret_err_msg_lang = USERENV('LANG')
	where batch_id = p_batch_id;

       EGO_UTIL_PK.put_fnd_stack_msg (p_appln_short_name=>'EGO'
                                    ,p_message =>'EGO_INVALID_MODE');
       EGO_UTIL_PK.count_and_get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data );




        x_return_status := C_FAILED;

END Basic_Validation;

--validates batch id
--
Procedure validate_batch_id(p_batch_id In Number
			    ,x_return_status  OUT NOCOPY  VARCHAR2
		            ,x_msg_count      OUT NOCOPY  NUMBER
	                    ,x_msg_data       OUT NOCOPY  VARCHAR2)
IS
l_batch_id NUMBER;
l_stmt_num NUMBER;

EGO_NULL_BATCH_ID  EXCEPTION;
EGO_NO_HEADER EXCEPTION;
BEGIN
       l_stmt_num := 0;
	 EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.validate_batch_id'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.validate_batch_id ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

       x_return_status := C_SUCCESS;

	   If p_batch_id is  null THEN
	     Raise EGO_NULL_BATCH_ID;
           END IF;



	   l_stmt_num := 10;
	   Begin

		   Select batch_id
		   into l_batch_id
		   from Ego_Pub_Bat_Hdr_B
		   where batch_id = p_batch_Id;
	   Exception
	     When No_Data_Found THEN
		RAISE EGO_NO_HEADER;
	   End;

	 EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.validate_batch_id'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.validate_batch_id ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));



EXCEPTION
  When EGO_NULL_BATCH_ID Then
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_EXCEPTION
                                     ,p_module  => 'EGO_PUB_FWK_PK.validate_batch_id'
                                     ,p_message => 'Exception EGO_PUB_BATCHID_NULL in stmt num: '||l_stmt_num || ':' ||'sqlerrm=>'|| sqlerrm);


     l_stmt_num := 20;
     Update ego_publication_batch_gt
	set return_status = C_FAILED,
	    return_error_code = 'EGO_PUB_BATCHID_NULL',
	   return_error_message  = FND_MESSAGE.get_string ('EGO', 'EGO_PUB_BATCHID_NULL'),
	   ret_err_msg_lang = USERENV('LANG')
     where batch_id =p_batch_id;

     EGO_UTIL_PK.put_fnd_stack_msg (p_appln_short_name=>'EGO'
                                    ,p_message =>'EGO_PUB_BATCHID_NULL');
     EGO_UTIL_PK.count_and_get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data );

     x_return_status := C_FAILED;

  WHEN  EGO_NO_HEADER THEN

       EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_EXCEPTION
                                     ,p_module  => 'EGO_PUB_FWK_PK.validate_batch_id'
                                     ,p_message => 'Exception EGO_NO_HEADER in stmt num: '||l_stmt_num || ':' ||'sqlerrm=>'|| sqlerrm);


        l_stmt_num := 30;
        Update ego_publication_batch_gt
	set return_status = C_FAILED,
	    return_error_code = 'EGO_NO_HEADER',
	    return_error_message  = FND_MESSAGE.get_string ('EGO', 'EGO_NO_HEADER'),
	   ret_err_msg_lang = USERENV('LANG')
	where batch_id =p_batch_id;

        EGO_UTIL_PK.put_fnd_stack_msg (p_appln_short_name=>'EGO'
                                    ,p_message =>'EGO_NO_HEADER');
        EGO_UTIL_PK.count_and_get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data );




         x_return_status := C_FAILED;
  WHEN OTHERS THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                     ,p_module  => 'EGO_PUB_FWK_PK.validate_batch_id'
                                     ,p_message => 'Others Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );


      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      EGO_UTIL_PK.count_and_get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data );

END validate_batch_id;

Procedure validateStatus(p_batch_id In Number)
IS
l_stmt_num NUMBER;
BEGIN
  l_stmt_num := 0;
   EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.validateStatus'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.validateStatus ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

  l_stmt_num := 10;
  Update Ego_Publication_Batch_GT
  Set Return_status = C_FAILED,
    process_flag = 1,
    return_error_code = 'EGO_INVALID_STATUS_CODE',
    return_error_message  = FND_MESSAGE.get_string ('EGO', 'EGO_INVALID_STATUS_CODE'),
    ret_err_msg_lang = USERENV('LANG')
  where Status not in (select lookup_code
                      from fnd_lookups
                      where Lookup_Type  = 'EGO_PUBLICATION_STATUS')
  and batch_id = p_batch_id;

  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.validateStatus'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.validateStatus ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));



EXCEPTION
WHEN OTHERS THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                     ,p_module  => 'EGO_PUB_FWK_PK.validate_status'
                                     ,p_message => 'Others Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );



      RAISE;


END  validateStatus;


Procedure valdiateBatSystem(p_batch_id IN Number)
IS

l_stmt_num NUMBER;
BEGIN
  l_stmt_num := 0;
   EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.valdiateBatSystem'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.valdiateBatSystem ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));


   l_stmt_num := 10;
   Update Ego_Publication_Batch_GT
   Set Return_status = C_FAILED,
       process_flag = 2,
       return_error_code = 'EGO_INVALID_BAT_SYS',
        return_error_message  = FND_MESSAGE.get_string ('EGO', 'EGO_INVALID_BAT_SYS'),
        ret_err_msg_lang = USERENV('LANG')
   where (batch_id,
          system_Code) not in (select batch_id,
                                      system_code
                               from Ego_Pub_Bat_status_b
                               where batch_id = p_batch_id)
   and batch_id  = p_batch_id
   and process_flag is null;

    EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.valdiateBatSystem'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.valdiateBatSystem ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));


EXCEPTION
WHEN OTHERS THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                     ,p_module  => 'EGO_PUB_FWK_PK.valdiateBatSystem'
                                     ,p_message => 'Others Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );



      RAISE;

END valdiateBatSystem;



Procedure validateBatSysEnt(p_batch_id IN Number)
IS
l_stmt_num NUMBER;

BEGIN
  l_stmt_num := 0;
    EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.validateBatSysEnt'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.validateBatSysEnt ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));


   l_stmt_num := 10;

   UPDATE ego_publication_batch_gt gt
   SET batch_entity_object_id =
	  (SELECT eo.batch_entity_object_id
	   FROM ego_pub_bat_ent_objs_b eo
	   WHERE batch_id = gt.batch_id
	   AND eo.pk1_value = nvl(gt.pk1_value, -99)
	   AND nvl(eo.pk2_value, -99) = nvl(gt.pk2_value, -99)
	   AND nvl(eo.pk3_value, -99) = nvl(gt.pk3_value, -99)
	   AND nvl(eo.pk4_value, -99) = nvl(gt.pk4_value, -99)
	   AND nvl(eo.pk5_value, -99) = nvl(gt.pk5_value, -99)
	   and gt.batch_id = p_batch_id);

   l_stmt_num := 20;
  UPDATE ego_publication_batch_gt
  SET return_status = C_FAILED,
      process_flag = 3,
      return_error_code = 'EGO_INVALID_BAT_SYS_ENT',
      return_error_message  = FND_MESSAGE.get_string ('EGO', 'EGO_INVALID_BAT_SYS_ENT'),
      ret_err_msg_lang = USERENV('LANG')
  WHERE ( nvl(batch_entity_object_id,-99),
         nvl(batch_id,-99),
         nvl(system_code,-99)) NOT IN
                                  (SELECT
                                          batch_entity_object_id,
                                          batch_id,
                                          system_code
                                   FROM ego_pub_bat_status_b
                                   WHERE batch_id = p_batch_id)
  AND batch_id = p_batch_id
  and process_flag is null;

     EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.validateBatSysEnt'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.validateBatSysEnt ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));


EXCEPTION
WHEN OTHERS THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                     ,p_module  => 'EGO_PUB_FWK_PK.validateBatSysEnt'
                                     ,p_message => 'Others Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );


      RAISE;


END validateBatSysEnt;




PROCEDURE Process_Pub_Status(
			p_mode IN Number
			,p_batch_id IN Number
			,x_return_status  OUT NOCOPY  VARCHAR2
			,x_msg_count      OUT NOCOPY  NUMBER
			,x_msg_data       OUT NOCOPY  VARCHAR2
)
IS

t_batch_ent_obj_id  NUMBER_ARR_TBL_TYPE;
t_batch_id          NUMBER_ARR_TBL_TYPE;
t_system_code       CHAR30_ARR_TBL_TYPE;
t_status            CHAR1_ARR_TBL_TYPE;
t_message           CHAR_ARR_TBL_TYPE;
l_stmt_num  NUMBER;
--i	NUMBER; --FOR LOOP
BEGIN
  l_stmt_num := 0;
    EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.Process_Pub_Status'
                                      ,p_message  => 'Enter EGO_PUB_FWK_PK.Process_Pub_Status ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

   x_return_status  := C_SUCCESS;

   --Validity check of status in GT table against lookup
   l_stmt_num :=10;
   validateStatus(p_batch_id=>p_batch_id);

   l_stmt_num :=20;

   IF  p_mode = C_BATCH_SYSTEM_MODE THEN

      l_stmt_num := 30;
      valdiateBatSystem(p_batch_id =>p_batch_id);
   ELSIF p_mode  = C_BATCH_SYSTEM_ENTITY_MODE THEN

       l_stmt_num := 40;
       validateBatSysEnt(p_batch_id =>p_batch_id);
   END IF;

   l_stmt_num:=50;
   SELECT batch_entity_object_id,
          batch_id,
	  system_code,
          status,
          message
   BULK COLLECT INTO
        t_batch_ent_obj_id,
	t_batch_id,
	t_system_code,
        t_status,
	t_message
   from ego_publication_batch_gt
   where batch_id = p_batch_id
   and  return_status is null
   and  process_flag is null;

   l_stmt_num  := 60;

   -- 8773131 added IF condition for mode BATCH_MODE
   IF p_mode  = C_BATCH_MODE THEN

      l_stmt_num := 65;
      FORALL i IN t_batch_id.FIRST .. t_batch_id.LAST
        UPDATE ego_pub_bat_status_b
        SET    status_code = t_status(i),
               message = t_message(i)
        WHERE  batch_id = t_batch_id(i);

   ELSIF p_mode = C_BATCH_SYSTEM_MODE THEN

      l_stmt_num := 70;
      FORALL i IN t_batch_id.FIRST .. t_batch_id.LAST
	UPDATE ego_pub_bat_status_b
	SET    status_code = t_status(i),
	       message = t_message(i)
	WHERE  batch_id = t_batch_id(i)
	AND    system_code = t_system_code(i);

   ELSIF p_mode  = C_BATCH_SYSTEM_ENTITY_MODE THEN

       l_stmt_num := 80;
       FORALL i IN t_batch_id.FIRST .. t_batch_id.LAST
	UPDATE ego_pub_bat_status_b
	SET    status_code = t_status(i),
	       message = t_message(i)
	WHERE  batch_entity_object_id = t_batch_ent_obj_id(i)
	AND    batch_id = t_batch_id(i)
	AND    system_code = t_system_code(i);

   END IF;

      l_stmt_num := 90;
     update ego_publication_batch_gt
     set return_status = C_SUCCESS
     where batch_id = p_batch_id
     and process_flag is null;

     EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.Process_Pub_Status'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.Process_Pub_Status ... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));


EXCEPTION
   WHEN OTHERS THEN
      EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                      ,p_module  => 'EGO_PUB_FWK_PK.Process_Pub_Status'
                                      ,p_message  => 'Others Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                    ,p_msg_data  => x_msg_data );

END Process_Pub_Status;


--Returns S =Success
--          F = failure
--	  W = warning
--	  U= Unexpected Error
PROCEDURE Update_Pub_Status ( p_batch_id IN NUMBER
			     ,p_mode In Number
			     ,p_bat_status_in  IN TBL_OF_BAT_ENT_OBJ_STAT_TYPE
			     ,x_bat_status_out OUT NOCOPY  TBL_OF_BAT_ENT_OBJ_RSTS_TYPE
			     ,x_return_status  OUT NOCOPY  VARCHAR2
			     ,x_msg_count      OUT NOCOPY  NUMBER
	                     ,x_msg_data       OUT NOCOPY  VARCHAR2)
IS
--The following variables types should match with Ego_Publication_Batch_GT
pk1_value     CHAR150_ARR_TBL_TYPE;
pk2_value     CHAR150_ARR_TBL_TYPE;
pk3_value     CHAR150_ARR_TBL_TYPE;
pk4_value     CHAR150_ARR_TBL_TYPE;
pk5_value     CHAR150_ARR_TBL_TYPE;
t_system_code   CHAR30_ARR_TBL_TYPE;
t_message	CHAR_ARR_TBL_TYPE;
t_status   	CHAR1_ARR_TBL_TYPE;

ret_pk1_value     CHAR150_ARR_TBL_TYPE;
ret_pk2_value     CHAR150_ARR_TBL_TYPE;
ret_pk3_value     CHAR150_ARR_TBL_TYPE;
ret_pk4_value     CHAR150_ARR_TBL_TYPE;
ret_pk5_value     CHAR150_ARR_TBL_TYPE;
t_ret_batchid 	NUMBER_ARR_TBL_TYPE;
t_ret_system_code   CHAR30_ARR_TBL_TYPE;
t_ret_err_msg_lang CHAR4_ARR_TBL_TYPE;
t_ret_status	CHAR1_ARR_TBL_TYPE;
t_ret_err_msg CHAR_ARR_TBL_TYPE;
t_ret_err_code CHAR_ARR_TBL_TYPE;

--i    		NUMBER; --FOR LOOP
l_stmt_num 	NUMBER;
l_ret_status 	VARCHAR2(1);

EGO_NO_DATA EXCEPTION;
EGO_NO_BAT_STS_IN EXCEPTION;

BEGIN
   delete from Ego_Publication_Batch_GT;

  l_stmt_num := 0;
    EGO_COMMON_PVT.WRITE_DIAGNOSTIC( p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                    ,p_module  => 'EGO_PUB_FWK_PK.Update_Pub_Status'
                                    ,p_message  => 'Enter EGO_PUB_FWK_PK.Update_Pub_Status ...'
	         		    ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

    l_stmt_num := 10;
    Basic_Validation ( p_batch_id => p_batch_id
		      ,p_mode => p_mode
		      ,x_return_status => x_return_status
 		      ,x_msg_count => x_msg_count
		      ,x_msg_data  => x_msg_data);

    IF (x_return_status = C_FAILED) THEN
        return;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	--revisit
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    End if;

    IF ( p_bat_status_in.count() = 0 OR p_bat_status_in IS NULL )  THEN
         RAISE EGO_NO_BAT_STS_IN; --!!!!!!!!! should I raise exception or put error message into GT
    END IF;

    EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                     ,p_module => 'EGO_PUB_FWK_PK.Update_Pub_Status'
                                     ,p_message =>' i --' ||
                                                  ' pk1_value(i) --' ||
                                                  ' pk2_value(i) --' ||
                                                  ' pk3_value(i) --' ||
                                                  ' pk4_value(i) --' ||
                                                  ' pk5_value(i) --' ||
                                                  ' system_code(i) --' ||
                                                  ' status(i) --' ||
                                                  ' message(i)' );
    l_stmt_num := 20;
    FOR i IN p_bat_status_in.FIRST..p_bat_status_in.LAST LOOP
    	pk1_value(i) := p_bat_status_in(i).pk1_value;
        pk2_value(i) := p_bat_status_in(i).pk2_value;
    	pk3_value(i) := p_bat_status_in(i).pk3_value;
        pk4_value(i) := p_bat_status_in(i).pk4_value;
        pk5_value(i) := p_bat_status_in(i).pk5_value;
        t_system_code(i) := p_bat_status_in(i).system_code;
        t_status(i)  := p_bat_status_in(i).status;
        t_message(i) := p_bat_status_in(i).message;
        EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                         ,p_module => 'EGO_PUB_FWK_PK.Update_Pub_Status'
                                         ,p_message =>  i || ' --' ||
					  p_bat_status_in(i).pk1_value || ' --' ||
                                          p_bat_status_in(i).pk2_value || ' --' ||
                                          p_bat_status_in(i).pk3_value || ' --' ||
                                          p_bat_status_in(i).pk4_value || ' --' ||
                                          p_bat_status_in(i).pk5_value || ' --' ||
                                          p_bat_status_in(i).system_code || ' --' ||
                                          p_bat_status_in(i).status || ' --' ||
                                          p_bat_status_in(i).message);
                                       END LOOP;

   l_stmt_num := 30;
   FORALL i IN t_system_code.FIRST..t_system_code.LAST
   	INSERT INTO EGO_PUBLICATION_BATCH_GT
   	(
           Batch_id
	  ,pk1_value
       	  ,pk2_value
       	  ,pk3_value
	  ,pk4_value
       	  ,pk5_value
       	  ,system_code
   	  ,status
   	  ,message
       	  ,LAST_UPDATE_DATE
	  ,LAST_UPDATED_BY
	  ,CREATION_DATE
	  ,CREATED_BY
       	  ,LAST_UPDATE_LOGIN
        )
   	VALUES
   	(
          p_batch_id
         ,pk1_value(i)
         ,pk2_value(i)
         ,pk3_value(i)
         ,pk4_value(i)
         ,pk5_value(i)
         ,t_system_code(i)
         ,t_status(i)
         ,t_message(i)
         ,SYSDATE
         ,FND_GLOBAL.USER_ID
         ,SYSDATE
         ,FND_GLOBAL.USER_ID
         ,FND_GLOBAL.LOGIN_ID
        );
 	EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                         ,p_module => 'EGO_PUB_FWK_PK.Update_Pub_Status'
                                         ,p_message => 'lStmtNum=' || to_char(l_stmt_num)
                                         ||' ' ||sql%rowcount || ' rows are inserted into EGO_PUBLICATION_BATCH_GT.');


   l_stmt_num := 40;
   Process_Pub_Status( p_mode  => p_mode
       		   ,p_batch_id => p_batch_id
       		   ,x_return_status  => l_ret_status
       		   ,x_msg_count   => x_msg_count
              	   ,x_msg_data   => x_msg_data);

   IF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   	x_return_status := l_ret_status;
   return;
   END IF;
   x_return_status := calc_return_status(p_batch_id=>p_batch_id);

   l_stmt_num := 50;

   Select  Batch_id
 	,System_Code
  	,Pk1_Value
  	,Pk2_value
       	,Pk3_value
       	,Pk4_Value
        ,Pk5_value
        ,Return_Status
        ,Return_Error_Message
        ,RETURN_ERROR_CODE
        ,RET_ERR_MSG_LANG
   BULK COLLECT INTO
      	t_ret_batchid
       ,t_ret_system_code
       ,ret_pk1_value
       ,ret_pk2_value
       ,ret_pk3_value
       ,ret_pk4_value
       ,ret_pk5_value
       ,t_ret_status
       ,t_ret_err_msg
       ,t_ret_err_code
       ,t_ret_err_msg_lang
   FROM Ego_Publication_Batch_GT
   WHERE Batch_id = p_batch_id;


   EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                                     ,p_module => 'EGO_PUB_FWK_PK.Update_Pub_Status'
                                     ,p_message =>' i --' ||
                                                  ' batch_id(i) --' ||
                                                  ' pk1_value(i) --' ||
                                                  ' pk2_value(i) --' ||
                                                  ' pk3_value(i) --' ||
                                                  ' pk4_value(i) --' ||
                                                  ' pk5_value(i) --' ||
                                                  ' system_code(i) --' ||
                                                  ' ret_status(i) --' ||
                                                  ' ret_err_msg(i) --' ||
                                                  ' ret_err_code(i) --' ||
                                                  ' ret_err_msg_lang(i)' );
  l_stmt_num := 60;
  FOR i IN t_ret_batchid.FIRST..t_ret_batchid.LAST LOOP
	 x_bat_status_out(i).batch_id := t_ret_batchid(i);
         x_bat_status_out(i).pk1_value := ret_pk1_value(i);
         x_bat_status_out(i).pk2_value := ret_pk2_value(i);
         x_bat_status_out(i).pk3_value := ret_pk3_value(i);
         x_bat_status_out(i).pk4_value := ret_pk4_value(i);
         x_bat_status_out(i).pk5_value := ret_pk5_value(i);
	 x_bat_status_out(i).system_code := t_ret_system_code(i);
	 x_bat_status_out(i).ret_status := t_ret_status(i);
	 x_bat_status_out(i).ret_err_msg := t_ret_err_msg(i);
	 x_bat_status_out(i).ret_err_code := t_ret_err_code(i);
	 x_bat_status_out(i).ret_err_msg_lang := t_ret_err_msg_lang(i);
         EGO_COMMON_PVT.WRITE_DIAGNOSTIC ( p_log_level => FND_LOG.LEVEL_STATEMENT
                        ,p_module => 'EGO_PUB_FWK_PK.Update_Pub_Status'
                        ,p_message =>  i || ' --' ||
                             t_ret_batchid(i) || ' --' ||
                             ret_pk1_value(i) || ' --' ||
                             ret_pk2_value(i) || ' --' ||
                             ret_pk3_value(i) || ' --' ||
                             ret_pk4_value(i) || ' --' ||
                             ret_pk5_value(i) || ' --' ||
                             t_ret_system_code(i) || ' --' ||
                             t_ret_status(i)|| ' --' ||
                             t_ret_err_msg(i) || ' --' ||
                             t_ret_err_code(i)  || ' --' ||
                             t_ret_err_msg_lang(i)  );
  END LOOP;

  delete from Ego_Publication_Batch_GT;

  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_PROCEDURE
                                      ,p_module  => 'EGO_PUB_FWK_PK.Update_Pub_Status'
                                      ,p_message  => 'Exit EGO_PUB_FWK_PK.Update_Pub_Status successfully... '
                                      ||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));

  EXCEPTION
        WHEN EGO_NO_BAT_STS_IN THEN
            EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_EXCEPTION
                                                           ,p_module  => 'EGO_PUB_FWK_PK.Update_Pub_Status'
                                                           ,p_message  => 'Exception EGO_NO_BAT_STS_IN in stmt num: ' || l_stmt_num|| ': '||'sqlerrm=>' ||sqlerrm);


            EGO_UTIL_PK.put_fnd_stack_msg (p_appln_short_name=>'EGO'
                                          ,p_message =>'EGO_NO_BAT_STS_IN');
            x_return_status := FND_API.G_RET_STS_ERROR;
            EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                      ,p_msg_data  => x_msg_data );
	WHEN OTHERS THEN
      	    EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                           ,p_module  => 'EGO_PUB_FWK_PK.Update_Pub_Status'
                                           ,p_message => 'Others Exception in stmt num: ' || l_stmt_num || ': '||'sqlerrm=>' ||sqlerrm );


            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            EGO_UTIL_PK.count_and_get (p_msg_count => x_msg_count
                                      ,p_msg_data  => x_msg_data );


END Update_Pub_Status;

Procedure DeleteGTTableData(x_return_status OUT NOCOPY  VARCHAR2)
IS

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Delete from Ego_Publication_Batch_GT;

EXCEPTION
WHEN OTHERS THEN
    EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_log_level  => FND_LOG.LEVEL_UNEXPECTED
                                           ,p_module  => 'EGO_PUB_FWK_PK.DeleteGTTableData'
                                           ,p_message => 'sqlerrm=>' ||sqlerrm );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END DeleteGTTableData;


END EGO_PUB_FWK_PK;

/
