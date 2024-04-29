--------------------------------------------------------
--  DDL for Package Body ZPB_DC_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DC_OBJECTS_PVT" AS
/* $Header: ZPBDCGTB.pls 120.10 2008/01/24 09:57:46 maniskum ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'ZPB_DC_OBJECTS_PVT';


/*---------------------------Private Procedure-----------------------------*/
/*=========================================================================+
 |                       PROCEDURE Populate_Distributors
 |
 | DESCRIPTION
 |   Procedure gets the list of data owners by calling the distribution
 |   list api.
 +========================================================================*/

PROCEDURE Get_User_Id_Clob(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2,
  p_commit              IN      VARCHAR2,
  p_validation_level    IN      NUMBER,
  x_return_status       OUT     NOCOPY VARCHAR2,
  x_msg_count           OUT     NOCOPY NUMBER,
  x_msg_data            OUT     NOCOPY VARCHAR2,
  --
  p_object_id           IN      NUMBER,
  p_object_user_id      IN      NUMBER,
  p_recipient_type      IN      VARCHAR2,
  p_resp_key            IN      VARCHAR2,
  x_user_id_clob        OUT     NOCOPY      CLOB
) IS

  PRAGMA autonomous_transaction;

  l_api_name            CONSTANT VARCHAR2(30) := 'Get_User_Id_Clob';
  l_api_version         CONSTANT NUMBER       :=  1.0;
  l_business_area_id             ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;
  l_template_id                  NUMBER;
  l_master_object_id             NUMBER;

BEGIN

  SAVEPOINT Get_User_Id_Clob_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  -- Get the Business Area ID for the object in question
  --
  select B.BUSINESS_AREA_ID, A.TEMPLATE_ID
       into l_business_area_id , l_template_id
       from ZPB_DC_OBJECTS A,
       ZPB_ANALYSIS_CYCLES B
       where A.OBJECT_ID = p_object_id
       and A.AC_INSTANCE_ID = B.ANALYSIS_CYCLE_ID;

  select OBJECT_ID into l_master_object_id
	from ZPB_DC_OBJECTS
   	where TEMPLATE_ID = l_template_id
     	and OBJECT_TYPE = 'M';


  -- Initialize the parameters

  -- API Body

  ZPB_AW.INITIALIZE_USER(p_api_version   => 1.0,
                    p_init_msg_list     => FND_API.G_FALSE,
                    p_validation_level  => p_validation_level,
                    x_return_status     => x_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    p_user              => p_object_user_id,
                    p_business_area_id  => l_business_area_id,
                    p_attach_readwrite  => FND_API.G_FALSE);


  ZPB_DATA_COLLECTION_UTIL_PVT.get_dc_owners(
      p_object_id         => l_master_object_id,
      p_user_id           => p_object_user_id,
      p_query_type        => p_recipient_type,
      p_api_version       => p_api_version,
      p_init_msg_list     => p_init_msg_list,
      p_commit            => p_commit,
      p_validation_level  => p_validation_level,
      x_owner_list        => x_user_id_clob,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);

  ZPB_AW.clean_workspace (
      p_api_version       => p_api_version,
          p_init_msg_list     => p_init_msg_list,
          p_validation_level  => p_validation_level,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data);

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Get_User_Id_Clob_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Get_User_Id_Clob_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Get_User_Id_Clob_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Get_User_Id_Clob;


/*=========================================================================+
 |                       PROCEDURE Populate_Distributors
 |
 | DESCRIPTION
 |   Procedure populates the zpb_dc_distributors table to keep
 |   track of the distributors for a specific worksheet.
 |
 +=========================================================================*/

PROCEDURE Populate_Distributors
(
  p_object_id               IN NUMBER ,
  p_distributor_user_id     IN NUMBER ,
  p_approver_type           IN VARCHAR2
) IS
BEGIN
  INSERT INTO ZPB_DC_DISTRIBUTORS(
            OBJECT_ID,
                DISTRIBUTOR_USER_ID,
                DISTRIBUTION_DATE,
                APPROVER_TYPE,
                LAST_UPDATE_LOGIN,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                CREATED_BY,
                CREATION_DATE
  )
  VALUES(
            p_object_id,
                p_distributor_user_id,
                SYSDATE,
                p_approver_type,
                fnd_global.LOGIN_ID,
                fnd_global.user_id,
                SYSDATE,
                fnd_global.user_id,
                SYSDATE
  );
END Populate_Distributors;


/*=========================================================================+
 |                       PROCEDURE Populate_Approvers
 |
 | DESCRIPTION
 |   Procedure populates the zpb_dc_approvers table to keep
 |   track of the approvers for a specific worksheet.
 |
 +=========================================================================*/

PROCEDURE Populate_Approvers(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_object_id           IN    NUMBER,
  p_approver_user_id    IN    NUMBER,
  p_approval_date       IN    DATE)

IS

  l_api_name            CONSTANT VARCHAR2(30) := 'Populate_Approvers';
  l_api_version         CONSTANT NUMBER       :=  1.0;

BEGIN

  SAVEPOINT Populate_Approvers ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the parameters

  -- API Body
  INSERT INTO zpb_dc_approvers
    (OBJECT_ID,
         APPROVER_USER_ID,
         APPROVAL_DATE,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_LOGIN,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE)
  VALUES
    (p_object_id,
         p_approver_user_id,
         p_approval_date,
     fnd_global.user_id,
         SYSDATE,
         fnd_global.LOGIN_ID,
         fnd_global.user_id,
         SYSDATE);

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Populate_Approvers ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Populate_Approvers ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Populate_Approvers ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Populate_Approvers;

/*=========================================================================+
 |                       PROCEDURE Override_Customization
 |
 | DESCRIPTION
 |   Procedure overrides the users Worksheet with the Master record
 |
 +=========================================================================*/

PROCEDURE Override_Customization(
p_overwrite_cust      IN    VARCHAR2,
p_template_id         IN    NUMBER
)
IS
  CURSOR dist_template_csr IS
  SELECT ANALYSIS_CYCLE_ID       ,
         AC_INSTANCE_ID          ,
                 GENERATE_TEMPLATE_TASK_ID,
         OBJECT_USER_ID          ,
                 AC_TEMPLATE_ID          ,
         TEMPLATE_NAME           ,
                 DATAENTRY_OBJ_PATH      ,
         DATAENTRY_OBJ_NAME      ,
         TARGET_OBJ_PATH         ,
         TARGET_OBJ_NAME         ,
         INSTRUCTION_TEXT_ID     ,
         FREEZE_FLAG             ,
                 DISTRIBUTION_METHOD     ,
                 DISTRIBUTION_DIMENSION  ,
                 DISTRIBUTION_HIERARCHY  ,
                 DESCRIPTION             ,
                 DEADLINE_DATE           ,
                 APPROVAL_REQUIRED_FLAG  ,
                 ENABLE_TARGET_FLAG      ,
                 CREATE_INSTANCE_MEASURES_FLAG
    FROM ZPB_DC_OBJECTS
   WHERE TEMPLATE_ID = p_template_id
     AND OBJECT_TYPE = 'M';
BEGIN
  -- Populate the layout and properties to all ws for this template
  FOR l_dist_template_row_rec IN dist_template_csr
  LOOP
        IF (p_overwrite_cust = 'OVERWRITE') THEN
       UPDATE ZPB_DC_OBJECTS
       SET TEMPLATE_NAME           = l_dist_template_row_rec.template_name,
           DISTRIBUTION_DATE       = SYSDATE,
           DATAENTRY_OBJ_PATH      = l_dist_template_row_rec.dataentry_obj_path,
           DATAENTRY_OBJ_NAME      = l_dist_template_row_rec.dataentry_obj_name,
           TARGET_OBJ_PATH         = l_dist_template_row_rec.target_obj_path,
           TARGET_OBJ_NAME         = l_dist_template_row_rec.target_obj_name,
                   PERSONAL_DATA_QUERY_FLAG      = 'N',
                   PERSONAL_TARGET_QUERY_FLAG    = 'N',
                   CREATE_SOLVE_PROGRAM_FLAG     = 'Y',
                   -- template properties
           DEADLINE_DATE           = l_dist_template_row_rec.deadline_date,
           APPROVER_TYPE           = 'DISTRIBUTOR',
                   DESCRIPTION             = l_dist_template_row_rec.description,
                   -- WHO columns
           LAST_UPDATE_DATE        = SYSDATE,
           LAST_UPDATED_BY         = fnd_global.user_id,
           LAST_UPDATE_LOGIN       = fnd_global.LOGIN_ID
       WHERE TEMPLATE_ID = p_template_id
           AND OBJECT_TYPE in ('W','C');
    END IF;
  END LOOP;

END Override_Customization;

/*=========================================================================+
 |                       PROCEDURE Distribute
 |
 | DESCRIPTION
 |   Procedure creates a new worksheet for each user on the
 |   distribution user list or users in the parameter table.
 |
 +=========================================================================*/
PROCEDURE Distribute
(
  p_object_id               IN NUMBER ,
  p_object_type             IN VARCHAR2,
  p_template_id             IN NUMBER ,
  p_ac_template_id          IN NUMBER ,
  p_analysis_cycle_id       IN NUMBER ,
  p_ac_instance_id          IN NUMBER ,
  p_generate_template_task_id IN NUMBER ,
  p_object_user_id          IN NUMBER ,
  p_distributor_user_id     IN NUMBER,
  p_template_name           IN VARCHAR2 ,
  p_dataentry_obj_path      IN VARCHAR2 ,
  p_dataentry_obj_name      IN VARCHAR2 ,
  p_target_obj_path         IN VARCHAR2 ,
  p_target_obj_name         IN VARCHAR2 ,
  p_deadline_date           IN DATE ,
  p_instruction_text_id     IN NUMBER,
  p_freeze_flag             IN VARCHAR2 ,
  p_distribution_method     IN VARCHAR2 ,
  p_distribution_dimension  IN VARCHAR2 ,
  p_distribution_hierarchy  IN VARCHAR2 ,
  p_description             IN VARCHAR2 ,
  p_approval_required_flag  IN VARCHAR2 ,
  p_enable_target_flag      IN VARCHAR2 ,
  p_create_inst_mea_flag    IN VARCHAR2 ,
  p_per_data_query_flag     IN VARCHAR2 ,
  p_per_target_query_flag   IN VARCHAR2 ,
  p_approver_type           IN VARCHAR2 ,
  p_overwrite_custm         IN VARCHAR2 ,
  p_overwrite_ws_data       IN VARCHAR2 ,
  p_insert_type             IN VARCHAR2,
  p_distribute_type         IN VARCHAR2,
  p_currency_flag           IN VARCHAR2,
  p_view_type               IN VARCHAR2,
  p_business_area_id        IN NUMBER,
  p_multiple_submissions_flag IN VARCHAR2
)
IS
  l_template_type   zpb_dc_objects.object_type%TYPE;
  l_status          zpb_dc_objects.status%TYPE;
  l_approver_type   zpb_dc_objects.approver_type%TYPE;
  l_instance_flag   VARCHAR2(20);
  l_copy_target_data_flag VARCHAR2(1);

  --PRAGMA autonomous_transaction;

BEGIN



  -- These are for worksheets --
  l_template_type := 'W';
  l_approver_type := 'DISTRIBUTOR'; -- no multiple distributor/approvers
  l_status := 'DISTRIBUTION_PENDING';

  -- Update 'M' template with changes in 'E' for manual dist --
  IF (p_distribute_type = 'MANUAL' and p_object_type = 'E') THEN

    UPDATE ZPB_DC_OBJECTS
        SET  TEMPLATE_NAME           = p_template_name,
                 DESCRIPTION             = p_description,
                 DATAENTRY_OBJ_PATH      = p_dataentry_obj_path,
                 -- These 2 lines are commented out because they are already updated
                 -- before distribution wf starts
         --DATAENTRY_OBJ_NAME      = p_dataentry_obj_name,
         TARGET_OBJ_PATH         = p_target_obj_path,
         --TARGET_OBJ_NAME         = p_target_obj_name,
         INSTRUCTION_TEXT_ID     = p_instruction_text_id,
         DEADLINE_DATE           = p_deadline_date,
         FREEZE_FLAG             = p_freeze_flag,
                 APPROVAL_REQUIRED_FLAG  = p_approval_required_flag,
                 DISTRIBUTION_DIMENSION  = p_distribution_dimension,
                 DISTRIBUTION_METHOD     = p_distribution_method,
                 DISTRIBUTION_HIERARCHY  = p_distribution_hierarchy,
                 APPROVER_TYPE           = p_approver_type,
                 ENABLE_TARGET_FLAG      = p_enable_target_flag,
                 CREATE_INSTANCE_MEASURES_FLAG = p_create_inst_mea_flag,
		     MULTIPLE_SUBMISSIONS_FLAG = p_multiple_submissions_flag,
         LAST_UPDATED_BY             = fnd_global.USER_ID,
         LAST_UPDATE_DATE        = SYSDATE,
         LAST_UPDATE_LOGIN       = fnd_global.LOGIN_ID
    WHERE TEMPLATE_ID = p_template_id
    AND OBJECT_TYPE = 'M';
  END IF;

  IF (p_object_type <> 'W') THEN
    -- Ater the distribution, the status of templates changes --
    UPDATE ZPB_DC_OBJECTS
    SET STATUS = 'DISTRIBUTED',
        DISTRIBUTION_DATE = SYSDATE,
        LAST_UPDATED_BY = fnd_global.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
    WHERE TEMPLATE_ID = p_template_id
    AND OBJECT_TYPE in ('M','E');
  END IF;


  -- if overwrite, reload the data from template --
  IF (p_overwrite_ws_data = 'OVERWRITE') THEN
    l_instance_flag := 'Y';
  ELSE
    l_instance_flag := 'N';
  END IF;
 FOR c1 in (SELECT 1  from zpb_dc_objects WHERE object_id = p_object_id
              and create_instance_measures_flag = 'Y')
 LOOP
   l_instance_flag := 'Y';
 END LOOP;

  -- l_copy_target_data_flag gets populated --
  IF (p_enable_target_flag = 'Y') THEN
    l_copy_target_data_flag := 'Y';
  ELSE
    l_copy_target_data_flag := 'N';
  END IF;

  IF p_insert_type = 'Insert' THEN
    -- Populate Distributors tables --

    Populate_Distributors(
          p_object_id              => p_object_id,
          p_distributor_user_id    => p_distributor_user_id,
          p_approver_type          => l_approver_type);
    INSERT INTO ZPB_DC_OBJECTS (
        OBJECT_ID               ,
        TEMPLATE_ID             ,
                AC_TEMPLATE_ID          ,
        ANALYSIS_CYCLE_ID       ,
        AC_INSTANCE_ID          ,
                GENERATE_TEMPLATE_TASK_ID,
        OBJECT_USER_ID          ,
        DISTRIBUTOR_USER_ID     ,
        DISTRIBUTION_DATE       ,
        OBJECT_TYPE             ,
        TEMPLATE_NAME           ,
        DATAENTRY_OBJ_PATH      ,
        DATAENTRY_OBJ_NAME      ,
        TARGET_OBJ_PATH         ,
        TARGET_OBJ_NAME         ,
        STATUS                  ,
        DEADLINE_DATE           ,
        INSTRUCTION_TEXT_ID     ,
        FREEZE_FLAG             ,
                DISTRIBUTION_METHOD     ,
                DISTRIBUTION_DIMENSION  ,
                DISTRIBUTION_HIERARCHY  ,
                DESCRIPTION             ,
                APPROVAL_REQUIRED_FLAG  ,
                ENABLE_TARGET_FLAG      ,
        APPROVER_TYPE           ,
        COPY_INSTANCE_DATA_FLAG ,
        COPY_TARGET_DATA_FLAG   ,
                CREATE_INSTANCE_MEASURES_FLAG,
                PERSONAL_DATA_QUERY_FLAG,
                PERSONAL_TARGET_QUERY_FLAG,
                CREATE_SOLVE_PROGRAM_FLAG,
        COPY_SOURCE_TYPE_FLAG,
            LAST_UPDATE_DATE        ,
        LAST_UPDATED_BY         ,
        LAST_UPDATE_LOGIN       ,
        CREATION_DATE           ,
        CREATED_BY,
        CURRENCY_FLAG,
        VIEW_TYPE,
        BUSINESS_AREA_ID,
	  MULTIPLE_SUBMISSIONS_FLAG)
    VALUES (
        p_object_id            ,
        p_template_id          ,
        p_ac_template_id       ,
        p_analysis_cycle_id    ,
        p_ac_instance_id       ,
                p_generate_template_task_id,
        p_object_user_id       ,
        p_distributor_user_id  ,
        SYSDATE                ,
        l_template_type        ,
        p_template_name      ,
        p_dataentry_obj_path   ,
        p_dataentry_obj_name   ,
        p_target_obj_path      ,
        p_target_obj_name      ,
        l_status               ,
        p_deadline_date        ,
        p_instruction_text_id  ,
        p_freeze_flag          ,
                p_distribution_method  ,
                p_distribution_dimension ,
                p_distribution_hierarchy ,
                p_description          ,
                p_approval_required_flag,
                p_enable_target_flag   ,
        l_approver_type        ,
                'Y'                    ,
                l_copy_target_data_flag,
                'Y',
                'N',
                'N',
                'Y',
                'Y',
                SYSDATE                ,
        fnd_global.user_id     ,
        fnd_global.LOGIN_ID,
        SYSDATE                ,
        fnd_global.user_id,
        p_currency_flag,
        p_view_type,
        p_business_area_id,
	  p_multiple_submissions_flag);
  ELSE -- update
    -- Update  distributors table
        UPDATE ZPB_DC_DISTRIBUTORS
        SET DISTRIBUTION_DATE = SYSDATE,
                APPROVER_TYPE     = l_approver_type,
                LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID,
                LAST_UPDATED_BY   = fnd_global.user_id,
                LAST_UPDATE_DATE  = SYSDATE,
                CREATED_BY        = fnd_global.user_id,
                CREATION_DATE     = SYSDATE
    WHERE object_id = p_object_id;
        UPDATE ZPB_DC_OBJECTS
    SET DISTRIBUTOR_USER_ID     = p_distributor_user_id,
        DISTRIBUTION_DATE       = SYSDATE,
                -- data overwrite or not
        DEADLINE_DATE           = p_deadline_date,
                STATUS                  = l_status,
                FREEZE_FLAG             = 'N',
        COPY_INSTANCE_DATA_FLAG = l_instance_flag,
                --WHO columns
        LAST_UPDATE_DATE        = SYSDATE,
        LAST_UPDATED_BY         = fnd_global.user_id,
        LAST_UPDATE_LOGIN       = fnd_global.LOGIN_ID
    WHERE object_id = p_object_id;

  END IF; -- insert or update

  --COMMIT WORK;
  exception
    when others then
          fnd_file.PUT_LINE(FND_FILE.LOG, sqlcode);
END Distribute;

/*------------------- End Private Procedures ---------------*/


/*=========================================================================+
 |                       PROCEDURE Generate_Template_CP
 |
 | DESCRIPTION
 |   Procedure calls Generate_Template procedure and pass in necessary
 |   parameters.
 |
 +=========================================================================*/
PROCEDURE Generate_Template_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_task_id                   IN       NUMBER,
  p_ac_id                     IN       NUMBER,
  p_instance_id               IN       NUMBER)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Generate_Template_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --

BEGIN

  Generate_Template(
    p_api_version         => 1.0,
    p_init_msg_list       => FND_API.G_TRUE,
    p_commit              => FND_API.G_FALSE,
    p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
    x_return_status       => l_return_status,
    x_msg_count           => l_msg_count,
    x_msg_data            => l_msg_data,
    --
    p_task_id             => p_task_id,
    p_ac_id               => p_ac_id,
    p_instance_id         => p_instance_id);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  retcode := '0';
  COMMIT;
  RETURN;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     retcode := '2' ;
         errbuf:=substr(sqlerrm, 1, 255);

   WHEN OTHERS THEN
     retcode := '2' ;
     errbuf:=substr(sqlerrm, 1, 255);
END Generate_Template_CP ;


/*=========================================================================+
 |                       PROCEDURE Generate_Template
 |
 | DESCRIPTION
 |   Procedure retrieves parameters defined in Generate Template Task,
 |   then creates 3 records in ZPB_DC_OBJECTS - one as the
 |   read-only master version, one as an editable template v
 |   for controller to edit layout and other template properties and data
 |   and one for controller to edit worksheet data and target plus layout.
 |   Procedure also creates an empty record for instruction text as well.
 |
 +=========================================================================*/

PROCEDURE Generate_Template(
    p_api_version         IN    NUMBER,
    p_init_msg_list       IN    VARCHAR2,
    p_commit              IN    VARCHAR2,
    p_validation_level    IN    NUMBER,
    x_return_status       OUT   NOCOPY VARCHAR2,
    x_msg_count           OUT   NOCOPY NUMBER,
    x_msg_data            OUT   NOCOPY VARCHAR2,
    --
        p_task_id             IN    NUMBER,
        p_ac_id               IN    NUMBER,
        p_instance_id         IN    NUMBER)
IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Generate_Template';
  l_api_version         CONSTANT NUMBER       :=  1.0;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_param_name                    zpb_task_parameters.name%TYPE;
  l_param_value                   zpb_task_parameters.value%TYPE;
  l_instance_name         zpb_analysis_cycle_instances.instance_description%TYPE;
  l_template_id                   zpb_dc_objects.template_id%TYPE;
  l_ac_template_id        zpb_dc_objects.ac_template_id%TYPE;
  l_object_m_id               zpb_dc_objects.object_id%TYPE;
  l_object_e_id               zpb_dc_objects.object_id%TYPE;
  l_object_c_id               zpb_dc_objects.object_id%TYPE;
  l_template_name             zpb_dc_objects.template_name%TYPE;
  l_dataentry_path                zpb_dc_objects.dataentry_obj_path%TYPE;
  l_dataentry_name                zpb_dc_objects.dataentry_obj_name%TYPE;
  l_target_path               zpb_dc_objects.target_obj_path%TYPE;
  l_target_name               zpb_dc_objects.target_obj_name%TYPE;
  l_use_last_reviewed     zpb_dc_objects.use_last_reviewed%TYPE;
  l_dist_dim                      zpb_dc_objects.distribution_dimension%TYPE;
  l_dist_hier                     zpb_dc_objects.distribution_hierarchy%TYPE;
  l_dist_method           zpb_dc_objects.distribution_method%TYPE;
  l_approval_req_flag     zpb_dc_objects.approval_required_flag%TYPE;
  l_wait_review_flag      zpb_dc_objects.wait_for_review_flag%TYPE;
  l_review_complete_flag  zpb_dc_objects.review_complete_flag%TYPE;
  l_enable_target_flag    zpb_dc_objects.enable_target_flag%TYPE;
  l_copy_target_data_flag zpb_dc_objects.copy_target_data_flag%TYPE;
  l_status                zpb_dc_objects.status%TYPE;
  l_short_instr_text      zpb_dc_instruction_text.short_text%TYPE;
  l_viewType              zpb_dc_objects.view_type%TYPE;
  l_currency_flag         zpb_dc_objects.currency_flag%TYPE;
  l_bus_area_id           zpb_dc_objects.business_area_id%TYPE;
  l_multiple_submissions_flag zpb_dc_objects.multiple_submissions_flag%TYPE;

  l_ac_count              NUMBER;
  l_view_value            VARCHAR2(100);
  l_currency_param_id     NUMBER;
  l_entered               NUMBER;
  l_have_entered_currency NUMBER;
  l_last_ac_id            NUMBER;
  l_count_changed_dim     NUMBER;
  l_master_exists         NUMBER;


  CURSOR l_task_params_csr IS
  SELECT name,
             value
        FROM zpb_task_parameters
   WHERE task_id = p_task_id;

  CURSOR l_ac_param_val_cursor IS
  SELECT value FROM ZPB_AC_PARAM_VALUES
  WHERE ANALYSIS_CYCLE_ID = p_ac_id
  AND PARAM_ID = l_currency_param_id;

  CURSOR c_bus_area IS
  SELECT business_area_id FROM zpb_analysis_cycles
  WHERE ANALYSIS_CYCLE_ID = p_ac_id;

  --PRAGMA autonomous_transaction;

BEGIN

  SAVEPOINT Generate_Template_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the parameters

  -- API Body

  SELECT ZPB_TEMPLATE_WS_ID_SEQ.nextval
  INTO l_object_m_id
  FROM dual;
  --Template id should be from object_id of the M record
  l_template_id := l_object_m_id;

  SELECT ZPB_TEMPLATE_WS_ID_SEQ.nextval
  INTO l_object_e_id
  FROM dual;

  SELECT ZPB_TEMPLATE_WS_ID_SEQ.nextval
  INTO l_object_c_id
  FROM dual;

  -- Get the instance name to append to template name
  SELECT instance_description
  INTO l_instance_name
  FROM zpb_analysis_cycle_instances
  WHERE instance_ac_id = p_instance_id;

  SELECT tag INTO l_currency_param_id
  FROM fnd_lookup_values_vl
  WHERE LOOKUP_CODE = 'BUSINESS_PROCESS_CURRENCY'
  and LOOKUP_TYPE = 'ZPB_PARAMS';

  SELECT tag INTO l_entered
  FROM fnd_lookup_values_vl
  WHERE LOOKUP_CODE = 'LOAD_ENTERED'
  and LOOKUP_TYPE = 'ZPB_PARAMS';

  l_currency_flag := 'N';
  l_viewType := 'BASE';

  open c_bus_area;
  fetch c_bus_area into l_bus_area_id;
  close c_bus_area;

  open l_ac_param_val_cursor;
  fetch l_ac_param_val_cursor into l_view_value;

  if l_ac_param_val_cursor %FOUND then
    l_currency_flag := 'Y';

    SELECT count(*) into l_have_entered_currency FROM ZPB_AC_PARAM_VALUES
    WHERE ANALYSIS_CYCLE_ID = p_ac_id
    AND PARAM_ID = l_entered AND value = 'Y';

    if l_have_entered_currency > 0 then
	l_viewType := 'ENTERED';
    end if;

    close l_ac_param_val_cursor;
  end if;


  -- Get parameters from Generate Template Process
  FOR l_task_params_row_rec IN l_task_params_csr
    LOOP
      l_param_name := l_task_params_row_rec.name;
      l_param_value := l_task_params_row_rec.value;

      /* Template id should be from object_id of the M record
             this template id should be ac_template_id */
      IF l_param_name='TEMPLATE_ID' THEN
        l_ac_template_id := l_param_value;
      ELSIF l_param_name='TEMPLATE_NAME' THEN
        l_template_name := l_param_value;
        IF (l_instance_name is not null) THEN
          l_template_name := l_template_name ||': '||l_instance_name;
        END IF;
      ELSIF l_param_name='TEMPLATE_LAYOUT' THEN
        IF l_param_value='DEFAULT_LAYOUT' THEN
               l_use_last_reviewed:='N';
            ELSE
              l_use_last_reviewed:='Y';
            END IF;
      ELSIF l_param_name='TEMPLATE_DISTRIBUTE_DIMENSION' THEN
        l_dist_dim := l_param_value;
      ELSIF l_param_name='TEMPLATE_DISTRIBUTE_HIERARCHY' THEN
        l_dist_hier := l_param_value;
      ELSIF l_param_name='TEMPLATE_DISTRIBUTION_METHOD' THEN
        l_dist_method := l_param_value;
      ELSIF l_param_name='TEMPLATE_DATAENTRY_OBJ_PATH' THEN
        l_dataentry_path := l_param_value;
      ELSIF l_param_name='TEMPLATE_TARGET_OBJ_PATH' THEN
        l_target_path := l_param_value;
      ELSIF l_param_name='TEMPLATE_TARGET_OBJ_NAME' THEN
        l_target_name := l_param_value;
      ELSIF l_param_name='TEMPLATE_DATAENTRY_OBJ_NAME' THEN
        l_dataentry_name := l_param_value;
      ELSIF l_param_name='TEMPLATE_WAIT_FOR_REVIEW' THEN
        l_wait_review_flag := l_param_value;
        IF l_wait_review_flag = 'Y' THEN
          l_review_complete_flag := 'N';
          l_status := 'REVIEW_PENDING';
        ELSE
          l_review_complete_flag := 'Y';
          l_status := 'REVIEW_COMPLETED';
        END IF;
      ELSIF l_param_name='TEMPLATE_APPROVAL_REQUIRED' THEN
        l_approval_req_flag := l_param_value;
        IF (l_dist_method = 'CASCADE_DISTRIBUTION') THEN
          l_approval_req_flag := 'Y';
        END IF;
      ELSIF l_param_name = 'TEMPLATE_ENABLE_TARGET' THEN
        l_enable_target_flag := l_param_value;
        IF (l_enable_target_flag = 'Y') THEN
          l_copy_target_data_flag := 'Y';
        ELSE
          l_copy_target_data_flag := 'N';
        END IF;
	ELSIF l_param_name = 'TEMPLATE_ALLOW_MULTIPLE_SUBS' THEN
	    l_multiple_submissions_flag := l_param_value;
      END IF;

  END LOOP;

    IF (l_use_last_reviewed = 'Y') THEN
          /* Only when a bp already has a template does 'user last
             reviewed' hold true */
    /*   SELECT count(*)
       INTO l_ac_count
       FROM zpb_dc_objects
       WHERE analysis_cycle_id = p_ac_id
       AND  ac_template_id =  l_ac_template_id;*/

  /*  IF (l_ac_count <> 0) THEN
	SELECT max(ac_instance_id)
	INTO l_last_ac_id
	FROM zpb_dc_objects
	WHERE analysis_cycle_id = p_ac_id
	AND  ac_template_id =  l_ac_template_id;*/

  /*  IF (l_ac_count <> 0) THEN*/
      SELECT max(a2.analysis_cycle_id)
      INTO l_last_ac_id
      FROM zpb_analysis_cycles a1, zpb_analysis_cycles a2
      WHERE a1.analysis_cycle_id = p_ac_id
      AND a2.status_code = 'ENABLE_TASK_OLD'
      AND a1.current_instance_id = a2.current_instance_id
      AND a2.analysis_cycle_id <> p_ac_id;

	SELECT count(*)
	INTO l_count_changed_dim
	FROM (
	 (SELECT dimension_name
	  FROM zpb_cycle_model_dimensions
	  WHERE analysis_cycle_id = l_last_ac_id
	  MINUS
	  SELECT dimension_name
	  FROM zpb_cycle_model_dimensions
	  WHERE analysis_cycle_id =  p_ac_id
	  )
	 UNION
	 (SELECT dimension_name
	  FROM zpb_cycle_model_dimensions
	  WHERE analysis_cycle_id = p_ac_id
	  MINUS
	  SELECT dimension_name
	  FROM zpb_cycle_model_dimensions
	  WHERE analysis_cycle_id =  l_last_ac_id)
	  );

    /*  IF (l_count_changed_dim = 0)THEN
         SELECT dataentry_obj_name, target_obj_name
         INTO l_dataentry_name, l_target_name
         FROM zpb_dc_objects
         WHERE object_type = 'M'
         AND ac_template_id =  l_ac_template_id
         AND ac_instance_id IN
           (SELECT max(ac_instance_id)
            FROM zpb_dc_objects
            WHERE analysis_cycle_id = p_ac_id
            AND  ac_template_id =  l_ac_template_id);
        END IF;
       END IF;
     END IF;
*/

       IF (l_count_changed_dim = 0)THEN
 -- ensure there is a master records to copy from
         SELECT count(*) INTO l_master_exists
         FROM zpb_dc_objects
         WHERE object_type = 'M'
         AND ac_template_id =  l_ac_template_id
         AND analysis_cycle_id = l_last_ac_id;

         IF (l_master_exists > 0)THEN
           SELECT
dataentry_obj_path,dataentry_obj_name,target_obj_path,target_obj_name
           INTO l_dataentry_path,l_dataentry_name,l_target_path,l_target_name
           FROM zpb_dc_objects
           WHERE object_type = 'M'
           AND ac_template_id =  l_ac_template_id
           AND analysis_cycle_id = l_last_ac_id;
          END IF;
        END IF;
    /*   END IF;*/
     END IF;


  -- Get the short text from fnd messages
-- FND_MESSAGE.SET_NAME('ZPB', 'ZPB_DC_INSTR_TEXT_MSG');
-- l_short_instr_text := FND_MESSAGE.GET;

 l_short_instr_text := '';
  /* Insert a record for the Master Template,
  this template is updated when distribute and submit, the changes from E template*/
  INSERT INTO ZPB_DC_OBJECTS (
    OBJECT_ID,
    TEMPLATE_ID,
        AC_TEMPLATE_ID,
    ANALYSIS_CYCLE_ID,
    AC_INSTANCE_ID,
        GENERATE_TEMPLATE_TASK_ID,
        OBJECT_USER_ID,
        DISTRIBUTOR_USER_ID,
    OBJECT_TYPE,
        STATUS,
        TEMPLATE_NAME,
    USE_LAST_REVIEWED,
    DATAENTRY_OBJ_PATH,
    DATAENTRY_OBJ_NAME,
        TARGET_OBJ_PATH,
        TARGET_OBJ_NAME,
        APPROVAL_REQUIRED_FLAG,
    DISTRIBUTION_DIMENSION,
        DISTRIBUTION_METHOD,
    DISTRIBUTION_HIERARCHY,
    INSTRUCTION_TEXT_ID,
        WAIT_FOR_REVIEW_FLAG,
        FREEZE_FLAG,
        REVIEW_COMPLETE_FLAG,
        ENABLE_TARGET_FLAG,
        CREATE_INSTANCE_MEASURES_FLAG,
        COPY_INSTANCE_DATA_FLAG,
        COPY_TARGET_DATA_FLAG,
    PERSONAL_DATA_QUERY_FLAG,
        PERSONAL_TARGET_QUERY_FLAG,
        CREATE_SOLVE_PROGRAM_FLAG,
    COPY_SOURCE_TYPE_FLAG,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CURRENCY_FLAG,
    VIEW_TYPE,
    BUSINESS_AREA_ID,
    MULTIPLE_SUBMISSIONS_FLAG)
  VALUES (
    l_object_m_id,
    l_template_id,
        l_ac_template_id,
    p_ac_id,
    p_instance_id,
        p_task_id,
        fnd_global.user_id,
        -100,
    'M',
        l_status,
    l_template_name,
        l_use_last_reviewed,
    l_dataentry_path,
    l_dataentry_name,
    l_target_path,
    l_target_name,
        l_approval_req_flag,
    l_dist_dim,
        l_dist_method,
    l_dist_hier,
    l_object_m_id,
    l_wait_review_flag,
        'N',
        l_review_complete_flag,
        l_enable_target_flag,
        'Y',
        'Y',
        l_copy_target_data_flag,
        'N',
        'N',
        'Y',
        'Y',
    SYSDATE,
        fnd_global.user_id,
    SYSDATE,
        fnd_global.user_id,
    fnd_global.LOGIN_ID,
    l_currency_flag,
    l_viewType,
    l_bus_area_id,
    l_multiple_submissions_flag);

  -- Insert an empty record in instruction text M template
  INSERT INTO ZPB_DC_INSTRUCTION_TEXT (
    INSTRUCTION_TEXT_ID         ,
    LONG_TEXT                   ,
    SHORT_TEXT                  ,
    LAST_UPDATE_LOGIN           ,
    LAST_UPDATE_DATE            ,
    LAST_UPDATED_BY             ,
    CREATION_DATE               ,
    CREATED_BY) Values (
    l_object_m_id               ,
    ''                          ,
    l_short_instr_text          ,
        fnd_global.LOGIN_ID        ,
        SYSDATE                     ,
        fnd_global.user_id          ,
        SYSDATE                     ,
        fnd_global.user_id
        );

  /* Generate an editable version of the template.
      controller make changes then distribute. so the changes be copied
          to M template when distribute*/
  INSERT INTO ZPB_DC_OBJECTS (
    OBJECT_ID,
    TEMPLATE_ID,
        AC_TEMPLATE_ID,
    ANALYSIS_CYCLE_ID,
    AC_INSTANCE_ID,
        GENERATE_TEMPLATE_TASK_ID,
        OBJECT_USER_ID,
        DISTRIBUTOR_USER_ID,
    OBJECT_TYPE,
        STATUS,
        TEMPLATE_NAME,
    USE_LAST_REVIEWED,
    DATAENTRY_OBJ_PATH,
    DATAENTRY_OBJ_NAME,
        TARGET_OBJ_PATH,
        TARGET_OBJ_NAME,
        APPROVAL_REQUIRED_FLAG,
    DISTRIBUTION_DIMENSION,
        DISTRIBUTION_METHOD,
    DISTRIBUTION_HIERARCHY,
    INSTRUCTION_TEXT_ID,
        WAIT_FOR_REVIEW_FLAG,
        FREEZE_FLAG,
        REVIEW_COMPLETE_FLAG,
        ENABLE_TARGET_FLAG,
        CREATE_INSTANCE_MEASURES_FLAG,
        COPY_INSTANCE_DATA_FLAG,
        COPY_TARGET_DATA_FLAG,
    PERSONAL_DATA_QUERY_FLAG,
        PERSONAL_TARGET_QUERY_FLAG,
        CREATE_SOLVE_PROGRAM_FLAG,
        COPY_SOURCE_TYPE_FLAG,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CURRENCY_FLAG,
    VIEW_TYPE,
    BUSINESS_AREA_ID,
    MULTIPLE_SUBMISSIONS_FLAG)
  VALUES (
    l_object_e_id,
    l_template_id,
        l_ac_template_id,
    p_ac_id,
    p_instance_id,
        p_task_id,
        fnd_global.user_id,
        -100,
    'E',
        l_status,
    l_template_name,
        l_use_last_reviewed,
    l_dataentry_path,
    l_dataentry_name,
    l_target_path,
    l_target_name,
        l_approval_req_flag,
    l_dist_dim,
        l_dist_method,
    l_dist_hier,
    l_object_e_id,
    l_wait_review_flag,
        'N',
        l_review_complete_flag,
        l_enable_target_flag,
        'Y',
        'Y',
        l_copy_target_data_flag,
        'N',
        'N',
        'Y',
        'Y',
    SYSDATE,
        fnd_global.user_id,
    SYSDATE,
        fnd_global.user_id,
    fnd_global.LOGIN_ID,
    l_currency_flag,
    l_viewType,
    l_bus_area_id,
    l_multiple_submissions_flag);


  -- Insert an empty record in instruction text for editable template
  INSERT INTO ZPB_DC_INSTRUCTION_TEXT (
    INSTRUCTION_TEXT_ID         ,
    LONG_TEXT                   ,
    SHORT_TEXT                  ,
    LAST_UPDATE_LOGIN           ,
    LAST_UPDATE_DATE            ,
    LAST_UPDATED_BY             ,
    CREATION_DATE               ,
    CREATED_BY) Values (
    l_object_e_id               ,
    ''                          ,
    l_short_instr_text          ,
        fnd_global.LOGIN_ID       ,
        SYSDATE                     ,
        fnd_global.user_id          ,
        SYSDATE                     ,
        fnd_global.user_id
        );


  /* Generate a controller worksheet, need to set measures flag
     for him to work on his own ws */
  INSERT INTO ZPB_DC_OBJECTS (
    OBJECT_ID,
    TEMPLATE_ID,
        AC_TEMPLATE_ID,
    ANALYSIS_CYCLE_ID,
    AC_INSTANCE_ID,
        GENERATE_TEMPLATE_TASK_ID,
        OBJECT_USER_ID,
        DISTRIBUTOR_USER_ID,
    OBJECT_TYPE,
        TEMPLATE_NAME,
        STATUS,
    USE_LAST_REVIEWED,
    DATAENTRY_OBJ_PATH,
    DATAENTRY_OBJ_NAME,
        TARGET_OBJ_PATH,
    TARGET_OBJ_NAME,
        APPROVAL_REQUIRED_FLAG,
    DISTRIBUTION_DIMENSION,
        DISTRIBUTION_METHOD,
    DISTRIBUTION_HIERARCHY,
    INSTRUCTION_TEXT_ID,
        WAIT_FOR_REVIEW_FLAG,
        FREEZE_FLAG,
        REVIEW_COMPLETE_FLAG,
        ENABLE_TARGET_FLAG,
        CREATE_INSTANCE_MEASURES_FLAG,
        COPY_INSTANCE_DATA_FLAG,
        COPY_TARGET_DATA_FLAG,
    PERSONAL_DATA_QUERY_FLAG,
        PERSONAL_TARGET_QUERY_FLAG,
        CREATE_SOLVE_PROGRAM_FLAG,
        COPY_SOURCE_TYPE_FLAG,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    CURRENCY_FLAG,
    VIEW_TYPE,
    BUSINESS_AREA_ID,
    MULTIPLE_SUBMISSIONS_FLAG)
  VALUES (
    l_object_c_id,
    l_template_id,
        l_ac_template_id,
    p_ac_id,
    p_instance_id,
        p_task_id,
        fnd_global.user_id,
        -100,
    'C',
    l_template_name,
        'DISTRIBUTION_PENDING',
        l_use_last_reviewed,
    l_dataentry_path,
    l_dataentry_name,
    l_target_path,
    l_target_name,
        l_approval_req_flag,
    l_dist_dim,
        l_dist_method,
    l_dist_hier,
        l_object_m_id,
    l_wait_review_flag,
        'N',
        l_review_complete_flag,
        l_enable_target_flag,
        'Y',
        'Y',
        l_copy_target_data_flag,
        'N',
        'N',
        'Y',
        'Y',
    SYSDATE,
        fnd_global.user_id,
    SYSDATE,
        fnd_global.user_id,
    fnd_global.LOGIN_ID,
    l_currency_flag,
    l_viewType,
    l_bus_area_id,
    l_multiple_submissions_flag);

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
  --COMMIT WORK;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Generate_Template_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Generate_Template_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  WHEN OTHERS THEN

    ROLLBACK TO Generate_Template_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );


END Generate_Template;

/*=========================================================================+
 |                       PROCEDURE Auto_Distribute_CP
 |
 | DESCRIPTION
 |   Procedure calls Auto_Distribute procedure and pass in necessary
 |   parameters.
 |
 +=========================================================================*/
PROCEDURE Auto_Distribute_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_task_id                   IN       NUMBER,
  p_template_id               IN       NUMBER)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Auto_Distribute_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
BEGIN
  --
  Auto_Distribute(
    p_api_version         => 1.0,
    p_init_msg_list       => FND_API.G_TRUE,
    p_commit              => FND_API.G_FALSE,
    p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
    x_return_status       => l_return_status,
    x_msg_count           => l_msg_count,
    x_msg_data            => l_msg_data,
    --
    p_task_id             => p_task_id,
    p_template_id         => p_template_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  retcode := '0';
  COMMIT;
  RETURN;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     retcode := '2' ;
         errbuf:=substr(sqlerrm, 1, 255);

   WHEN OTHERS THEN
     retcode := '2' ;
     errbuf:=substr(sqlerrm, 1, 255);
END Auto_Distribute_CP ;


/*=========================================================================+
 |                       PROCEDURE Auto_Distribute
 |
 |
 | DESCRIPTION
 |   Procedure creates a new worksheet for each user
 |   specified on the distribute template task ui. It copies the
 |   Master template to the user's worksheet folder.
 |
 |
 +=========================================================================*/

PROCEDURE Auto_Distribute(
    p_api_version         IN    NUMBER,
    p_init_msg_list       IN    VARCHAR2,
    p_commit              IN    VARCHAR2,
    p_validation_level    IN    NUMBER,
    x_return_status       OUT   NOCOPY VARCHAR2,
    x_msg_count           OUT   NOCOPY NUMBER,
    x_msg_data            OUT   NOCOPY VARCHAR2,
    --
    p_task_id             IN    NUMBER,
    p_template_id         IN    NUMBER
    )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Auto_Distribute';
  l_api_version           CONSTANT NUMBER       :=  1.0;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_object_id             NUMBER;
  l_object_user_id        NUMBER;
  l_distributor_user_id   NUMBER;
  l_param_name                zpb_task_parameters.name%TYPE;
  l_param_value               zpb_task_parameters.value%TYPE;
  l_recipient_type        zpb_task_parameters.value%TYPE;
  l_approver_type         zpb_dc_objects.approver_type%TYPE;
  l_object_type           zpb_dc_objects.object_type%TYPE;
  l_wait_for_review       VARCHAR2(1);
  l_review_complete_flag  VARCHAR2(1);
  l_deadline_date         DATE;
  l_deadline_type         VARCHAR2(10);
  l_deadline_duration     NUMBER;
  l_amt                   INTEGER;
  l_buffer                VARCHAR2(30);
  l_user_id_clob          CLOB;
  l_lob_length            BINARY_INTEGER;
  l_ind                   BINARY_INTEGER;

  l_pattern               VARCHAR2(1);
  l_position              BINARY_INTEGER;
  l_pattern_position      BINARY_INTEGER;

  l_user_id               NUMBER;
  l_user                  zpb_task_parameters.value%TYPE;
  l_insert_type           VARCHAR2(10);
  l_count                 NUMBER;
  l_resp_key              fnd_responsibility.responsibility_key%TYPE;

  -- Get the all the parameter values for the task id
  CURSOR task_params_csr IS
  SELECT name, value
    FROM zpb_task_parameters
   WHERE task_id = p_task_id;

  --Get all the info of this template id and of type M
  CURSOR dist_template_csr IS
  SELECT ANALYSIS_CYCLE_ID       ,
         AC_INSTANCE_ID          ,
                 GENERATE_TEMPLATE_TASK_ID,
         OBJECT_USER_ID          ,
                 DISTRIBUTOR_USER_ID     ,
                 AC_TEMPLATE_ID          ,
         TEMPLATE_NAME           ,
         DATAENTRY_OBJ_PATH      ,
         DATAENTRY_OBJ_NAME      ,
         TARGET_OBJ_PATH         ,
         TARGET_OBJ_NAME         ,
         INSTRUCTION_TEXT_ID     ,
         FREEZE_FLAG             ,
                 DISTRIBUTION_METHOD     ,
                 DISTRIBUTION_DIMENSION  ,
                 DISTRIBUTION_HIERARCHY  ,
                 DESCRIPTION             ,
                 APPROVAL_REQUIRED_FLAG  ,
                 ENABLE_TARGET_FLAG      ,
                 CREATE_INSTANCE_MEASURES_FLAG,
         PERSONAL_DATA_QUERY_FLAG,
         PERSONAL_TARGET_QUERY_FLAG,
         CURRENCY_FLAG,
         VIEW_TYPE,
         BUSINESS_AREA_ID,
	   MULTIPLE_SUBMISSIONS_FLAG
    FROM ZPB_DC_OBJECTS
   WHERE TEMPLATE_ID = p_template_id
     AND OBJECT_TYPE = 'M';

  -- Get all the specified users from the task param table
  CURSOR specific_user_csr IS
  SELECT value
   FROM  zpb_task_parameters
  WHERE  task_id = p_task_id
    AND  name = 'DISTRIBUTION_SPECIFIED_USERS';

  -- Check whether a specific user was distributed to
  CURSOR check_exist_csr IS
  SELECT count(*)
    FROM ZPB_DC_OBJECTS
   WHERE TEMPLATE_ID = p_template_id
     AND OBJECT_USER_ID = l_user_id;

BEGIN

  SAVEPOINT Auto_Distribute_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the parameters
  l_amt                   := 255;
  l_ind                   := 1;
  l_pattern               := ',';
  l_position              := 1;
  l_pattern_position      := 1;
  l_count                 := 0;
  l_object_type           := 'E';

  -- API Body

  -- Get parameters from Distribute Template Task definition
  FOR l_task_params_row_rec IN task_params_csr
  LOOP
    l_param_name := l_task_params_row_rec.name;
    l_param_value := l_task_params_row_rec.value;

        IF l_param_name='DISTRIBUTION_APPROVER_TYPE' THEN
      l_approver_type  := l_param_value;
    END IF;

        IF l_param_name='DISTRIBUTION_RECIPIENT_TYPE' THEN
      l_recipient_type  := l_param_value;
          IF (l_recipient_type = 'ALL_TOP_LEVEL_OWNERS') THEN
            l_recipient_type := 'ALL_TOP_LVL';
          ELSIF (l_recipient_type = 'ALL_DATA_OWNERS') THEN
            l_recipient_type := 'ALL';
          END IF;
    END IF;

    IF l_param_name='DISTRIBUTION_DEADLINE_TYPE' THEN
      l_deadline_type  := l_param_value;
    END IF;

    IF l_param_name='DISTRIBUTION_DEADLINE_DURATION' THEN
      l_deadline_duration  := l_param_value;
    END IF;

        IF l_deadline_type = 'DAYS' THEN
      l_deadline_date := sysdate + l_deadline_duration;
        ELSIF l_deadline_type = 'WEEKS' THEN
      l_deadline_date := sysdate + l_deadline_duration*7;
        ELSIF l_deadline_type = 'MONTHS' THEN
      l_deadline_date := ADD_MONTHS(sysdate,l_deadline_duration);
        ELSIF l_deadline_type = 'YEARS' THEN
      l_deadline_date := ADD_MONTHS(sysdate,l_deadline_duration*12);
        END IF;
  END LOOP;

  -- Call the following api to get the clob of user ids comma separated
  SELECT object_id, object_user_id, wait_for_review_flag, review_complete_flag
  INTO l_object_id, l_object_user_id, l_wait_for_review, l_review_complete_flag
  FROM zpb_dc_objects
  WHERE template_id = p_template_id
  AND object_type = 'M';

  /* Only the controller can distribute ws automatically
     Here we use the defaule manager resp to get the user ids */
  l_resp_key := 'ZPB_CONTROLLER_RESP';

  -- The insertion of the records
  IF l_recipient_type <> 'SPECIFIC_USERS' THEN

    get_user_id_clob(
      p_api_version         => p_api_version,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
      p_validation_level    => p_validation_level,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      --
      p_object_id           => l_object_id,
      p_object_user_id      => l_object_user_id,
      p_recipient_type      => l_recipient_type,
          p_resp_key            => l_resp_key,
      x_user_id_clob        => l_user_id_clob);

        l_position:= 1;
    l_lob_length := dbms_lob.getlength(l_user_id_clob);

    IF l_lob_length > 0 THEN
    LOOP
      l_pattern_position :=
             DBMS_LOB.INSTR(l_user_id_clob, l_pattern, l_position, 1);

          IF  l_pattern_position = 0 THEN
        l_amt := l_lob_length - l_position + 1;
      ELSE
        l_amt := l_pattern_position - l_position;
      END IF;

      dbms_lob.read (l_user_id_clob, l_amt, l_position, l_buffer);

      l_user_id := to_number(l_buffer);
          -- Check duplicates
          OPEN check_exist_csr;
          FETCH check_exist_csr INTO l_count;
          CLOSE check_exist_csr;

      IF (l_count = 0 ) THEN -- do the insert, otherwise ignore
        l_insert_type := 'Insert';

            -- Object id is unique - ws id
        SELECT ZPB_TEMPLATE_WS_ID_SEQ.nextval
        INTO l_object_id
        FROM dual;

        -- Retrieving the master template row
        FOR l_dist_template_row_rec IN dist_template_csr
        LOOP -- only one record

              /* The dist id is -100 (shared aw). If review is Y, pa opens the ws
                     (load data from share aw) before the distributee does. Otherwise,
                     distributee gets data from shared to avoid blank ws */
              l_distributor_user_id := l_dist_template_row_rec.distributor_user_id;
                  IF (l_wait_for_review  = 'Y' AND l_review_complete_flag = 'Y') THEN
                l_distributor_user_id := l_dist_template_row_rec.object_user_id;
                  END IF;

          Distribute
          (
          p_object_id               => l_object_id,
              p_object_type             => l_object_type, -- 'E'
          p_template_id             => p_template_id,
          p_ac_template_id          => l_dist_template_row_rec.ac_template_id,
          p_analysis_cycle_id       => l_dist_template_row_rec.analysis_cycle_id,
          p_ac_instance_id          => l_dist_template_row_rec.ac_instance_id,
                  p_generate_template_task_id => l_dist_template_row_rec.generate_template_task_id,
          p_object_user_id          => l_user_id,
          p_distributor_user_id     => l_distributor_user_id,
          p_template_name           => l_dist_template_row_rec.template_name,
          p_dataentry_obj_path      => l_dist_template_row_rec.dataentry_obj_path,
          p_dataentry_obj_name      => l_dist_template_row_rec.dataentry_obj_name,
          p_target_obj_path         => l_dist_template_row_rec.target_obj_path,
          p_target_obj_name         => l_dist_template_row_rec.target_obj_name,
          p_deadline_date           => l_deadline_date,
          p_instruction_text_id     => l_dist_template_row_rec.instruction_text_id,
          p_freeze_flag             => l_dist_template_row_rec.freeze_flag,
                  p_distribution_method     => l_dist_template_row_rec.distribution_method,
                  p_distribution_dimension  => l_dist_template_row_rec.distribution_dimension,
                  p_distribution_hierarchy  => l_dist_template_row_rec.distribution_hierarchy,
                  p_description             => l_dist_template_row_rec.description,
                  p_approval_required_flag  => l_dist_template_row_rec.approval_required_flag,
                  p_enable_target_flag      => l_dist_template_row_rec.enable_target_flag,
                  p_create_inst_mea_flag    => l_dist_template_row_rec.create_instance_measures_flag,
                  p_per_data_query_flag     => l_dist_template_row_rec.personal_data_query_flag,
                  p_per_target_query_flag   => l_dist_template_row_rec.personal_target_query_flag,
                  p_approver_type           => l_approver_type,
                  p_overwrite_custm         => NULL,
                  p_overwrite_ws_data       => NULL,
          p_insert_type             => l_insert_type,
                  p_distribute_type         => 'AUTO',
                  p_currency_flag	    => l_dist_template_row_rec.currency_flag,
                  p_view_type 		    => l_dist_template_row_rec.view_type,
                  p_business_area_id        => l_dist_template_row_rec.business_area_id,
			p_multiple_submissions_flag => l_dist_template_row_rec.multiple_submissions_flag
          );
        END LOOP; -- Retrieving the master template row
      END IF; -- check duplicates

      -- get clob
      l_position := l_pattern_position+1 ;
      IF  l_pattern_position = 0 THEN
        EXIT;
      END IF;

    END LOOP; -- clob loop
    END IF; -- clob length limit

  ELSE  -- recipients are specified

    OPEN specific_user_csr;
    -- Loop through the parameter table to get the user id
    LOOP
      FETCH specific_user_csr INTO l_user;
      EXIT WHEN specific_user_csr%NOTFOUND;

      -- Get the user id by user name
      SELECT user_id INTO l_user_id
      FROM fnd_user
      WHERE user_name = upper(l_user);

          -- Check duplicates
          OPEN check_exist_csr;
          FETCH check_exist_csr INTO l_count;
          CLOSE check_exist_csr;

      IF (l_count = 0 ) THEN -- do the insert, otherwise ignore

        -- Object id is unique = ws id
        SELECT ZPB_TEMPLATE_WS_ID_SEQ.nextval
        INTO l_object_id
        FROM dual;

        l_insert_type := 'Insert';

        -- Retrieving the master template row
        FOR l_dist_template_row_rec IN dist_template_csr
        LOOP -- only one record

              l_distributor_user_id := l_dist_template_row_rec.distributor_user_id;
                  IF (l_wait_for_review = 'Y' AND l_review_complete_flag = 'Y') THEN
                l_distributor_user_id := l_dist_template_row_rec.object_user_id;
                  END IF;

          Distribute
          (
          p_object_id               => l_object_id,
                  p_object_type             => l_object_type,
          p_template_id             => p_template_id,
          p_ac_template_id          => l_dist_template_row_rec.ac_template_id,
          p_analysis_cycle_id       => l_dist_template_row_rec.analysis_cycle_id,
          p_ac_instance_id          => l_dist_template_row_rec.ac_instance_id,
                  p_generate_template_task_id => l_dist_template_row_rec.generate_template_task_id,
          p_object_user_id          => l_user_id,
          p_distributor_user_id     => l_distributor_user_id,
          p_template_name           => l_dist_template_row_rec.template_name,
          p_dataentry_obj_path      => l_dist_template_row_rec.dataentry_obj_path,
          p_dataentry_obj_name      => l_dist_template_row_rec.dataentry_obj_name,
          p_target_obj_path         => l_dist_template_row_rec.target_obj_path,
          p_target_obj_name         => l_dist_template_row_rec.target_obj_name,
          p_deadline_date           => l_deadline_date,
          p_instruction_text_id     => l_dist_template_row_rec.instruction_text_id,
          p_freeze_flag             => l_dist_template_row_rec.freeze_flag,
                  p_distribution_method     => l_dist_template_row_rec.distribution_method,
                  p_distribution_dimension  => l_dist_template_row_rec.distribution_dimension,
                  p_distribution_hierarchy  => l_dist_template_row_rec.distribution_hierarchy,
                  p_description             => l_dist_template_row_rec.description,
                  p_approval_required_flag  => l_dist_template_row_rec.approval_required_flag,
                  p_enable_target_flag      => l_dist_template_row_rec.enable_target_flag,
                  p_create_inst_mea_flag    => l_dist_template_row_rec.create_instance_measures_flag,
                  p_per_data_query_flag     => l_dist_template_row_rec.personal_data_query_flag,
                  p_per_target_query_flag   => l_dist_template_row_rec.personal_target_query_flag,
                  p_approver_type           => l_approver_type,
                  p_overwrite_custm         => NULL,
                  p_overwrite_ws_data       => NULL,
          p_insert_type             => l_insert_type,
                  p_distribute_type         => 'AUTO',
                  p_currency_flag	    => l_dist_template_row_rec.currency_flag,
                  p_view_type 		    => l_dist_template_row_rec.view_type,
                  p_business_area_id        => l_dist_template_row_rec.business_area_id,
			p_multiple_submissions_flag => l_dist_template_row_rec.multiple_submissions_flag
          );
        END LOOP; -- Retrieving the master template row
          END IF; -- Check duplicates

    END LOOP; -- loop through task parameter table
  END IF; -- Specified user or not

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Auto_Distribute_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Auto_Distribute_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Auto_Distribute_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );


END Auto_Distribute;


/*=========================================================================+
 |                       PROCEDURE Manual_Distribute_CP
 |
 | DESCRIPTION
 |   Procedure calls Manual_Distributeprocedure and pass in necessary
 |   parameters.
 |
 +=========================================================================*/
PROCEDURE Manual_Distribute_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_object_id                 IN number,
  p_recipient_type            IN varchar2,
  p_dist_list_id              IN number,
  p_approver_type             IN varchar2,
  p_deadline_date             IN varchar2,
  p_overwrite_cust            IN varchar2,
  p_overwrite_data            IN varchar2)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Manual_Distribute_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --

BEGIN

  Manual_Distribute(
    p_api_version         => 1.0,
    p_init_msg_list       => FND_API.G_TRUE,
    p_commit              => FND_API.G_FALSE,
    p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
    x_return_status       => l_return_status,
    x_msg_count           => l_msg_count,
    x_msg_data            => l_msg_data,
    --
    p_object_id           => p_object_id,
    p_recipient_type      => p_recipient_type,
    p_dist_list_id        => p_dist_list_id,
    p_approver_type       => p_approver_type,
    p_deadline_date       => FND_DATE.CANONICAL_TO_DATE(p_deadline_date),
    p_overwrite_cust      => p_overwrite_cust,
    p_overwrite_data      => p_overwrite_data);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  retcode := '0';
  COMMIT;
  RETURN;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     retcode := '2' ;
         errbuf:=substr(sqlerrm, 1, 255);

   WHEN OTHERS THEN
     retcode := '2' ;
     errbuf:=substr(sqlerrm, 1, 255);
END Manual_Distribute_CP ;



/*=========================================================================+
 |                       PROCEDURE Manual_Distribute
 |
 |
 | DESCRIPTION
 |   Procedure updates the Master template copies the changes,
 |   if any, that the user makes
 |   creates a new worksheet for each user on the
 |   distribution user list.
 +=========================================================================*/

PROCEDURE Manual_Distribute(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_object_id       IN number,
  p_recipient_type  IN varchar2,
  p_dist_list_id    IN number,
  p_approver_type   IN varchar2,
  p_deadline_date   IN date,
  p_overwrite_cust  IN varchar2,
  p_overwrite_data  IN varchar2)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Manual_Distribute';
  l_api_version           CONSTANT NUMBER       :=  1.0;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_template_id           NUMBER;
  l_object_id                 NUMBER;
  l_object_user_id        NUMBER;
  l_deadline_date         DATE;
  l_object_type           zpb_dc_objects.object_type%TYPE;
  l_template_name         zpb_dc_objects.template_name%TYPE;
  l_data_obj_name         zpb_dc_objects.dataentry_obj_name%TYPE;
  l_target_obj_name       zpb_dc_objects.target_obj_name%TYPE;
  l_data_obj_path         zpb_dc_objects.dataentry_obj_path%TYPE;
  l_target_obj_path       zpb_dc_objects.target_obj_path%TYPE;
  l_multiple_submissions_flag zpb_dc_objects.multiple_submissions_flag%TYPE;
  l_user_id               NUMBER;
  l_user                  zpb_task_parameters.value%TYPE;
  l_insert_type           VARCHAR2(10);
  l_distribute_type       VARCHAR2(10);
  l_count                 NUMBER;
  l_raise_count           NUMBER;

  l_amt                   INTEGER;
  l_buffer                VARCHAR2(30);
  l_user_id_clob          CLOB;
  x_user_id_clob          CLOB;
  l_lob_length            BINARY_INTEGER;
  l_ind                   BINARY_INTEGER;

  l_pattern               VARCHAR2(1);
  l_position              BINARY_INTEGER;
  l_pattern_position      BINARY_INTEGER;
  l_resp_key              fnd_responsibility.responsibility_key%TYPE;

  -- Get template id and more
  CURSOR template_info_csr IS
  SELECT template_id,
         object_user_id,
                 object_type
    FROM zpb_dc_objects
   WHERE object_id = p_object_id;

    -- Analyst distributes his ws in cascade distribution
  CURSOR dist_worksheet_csr IS
  SELECT ANALYSIS_CYCLE_ID       ,
         AC_INSTANCE_ID          ,
                 GENERATE_TEMPLATE_TASK_ID,
         OBJECT_USER_ID          ,
                 AC_TEMPLATE_ID          ,
         TEMPLATE_NAME           ,
                 DATAENTRY_OBJ_PATH      ,
         DATAENTRY_OBJ_NAME      ,
         TARGET_OBJ_PATH         ,
         TARGET_OBJ_NAME         ,
         INSTRUCTION_TEXT_ID     ,
         FREEZE_FLAG             ,
                 DISTRIBUTION_METHOD     ,
                 DISTRIBUTION_DIMENSION  ,
                 DISTRIBUTION_HIERARCHY  ,
                 DESCRIPTION             ,
                 DEADLINE_DATE           ,
                 APPROVAL_REQUIRED_FLAG  ,
                 ENABLE_TARGET_FLAG      ,
                 CREATE_INSTANCE_MEASURES_FLAG,
                 CURRENCY_FLAG,
                 VIEW_TYPE,
                 BUSINESS_AREA_ID,
		     MULTIPLE_SUBMISSIONS_FLAG
    FROM ZPB_DC_OBJECTS
   WHERE TEMPLATE_ID = l_template_id
     AND OBJECT_TYPE = 'M';

  -- Get all the specified users from the task param table
  CURSOR specific_user_csr IS
  SELECT user_name
   FROM  zpb_dc_distribution_list_items
  WHERE  distribution_list_id = p_dist_list_id;

  -- Check whether a specific user was distributed to
  CURSOR check_exist_csr IS
  SELECT count(*)
    FROM ZPB_DC_OBJECTS
   WHERE TEMPLATE_ID = l_template_id
     AND OBJECT_USER_ID = l_user_id;

BEGIN
  SAVEPOINT Manual_Distribute_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the parameters
  l_resp_key              := null;
  l_count                 := 0;
  l_raise_count           := 0;
  l_amt                   := 255;
  l_ind                   := 1;
  l_pattern               := ',';
  l_position              := 1;
  l_pattern_position      := 1;

  -- API Body

  OPEN template_info_csr;
  FETCH template_info_csr
  INTO l_template_id, l_object_user_id, l_object_type;
  CLOSE template_info_csr;
  -- Populate resp key
    l_resp_key := 'ZPB_CONTROLLER_RESP';

  /* M needs a separate query object in the repostory
     so that the changes won't automatically populated to distributed ws */
  --l_data_obj_name := 'TEMPL_DATA_'||l_template_id||'_MASTER';
  --l_target_obj_name := 'TEMPL_TARGET_'||l_template_id||'_MASTER';
  --code moved to ui java file

  --override the users Worksheet with the Master copy('M' record)
  Override_Customization(
              p_overwrite_cust          => p_overwrite_cust,
                          p_template_id             => l_template_id );
  --Populate the object names from M record for BPO distribution
  FOR master_name_rec IN dist_worksheet_csr
  LOOP
    l_data_obj_name := master_name_rec.dataentry_obj_name;
        l_data_obj_path := master_name_rec.dataentry_obj_path;
    l_target_obj_name := master_name_rec.target_obj_name;
    l_target_obj_path := master_name_rec.target_obj_path;
  END LOOP;

  -- The insert/update the records
  IF p_recipient_type <> 'SPECIFIC_USERS' THEN
    get_user_id_clob(
      p_api_version         => l_api_version,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
      p_validation_level    => p_validation_level,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      --
      p_object_id           => p_object_id,
      p_object_user_id      => l_object_user_id,
      p_recipient_type      => p_recipient_type,
          p_resp_key            => l_resp_key,
      x_user_id_clob        => l_user_id_clob);

        l_position:= 1;
    l_lob_length := dbms_lob.getlength(l_user_id_clob);

    IF l_lob_length > 0 THEN
    LOOP
      l_pattern_position :=
             DBMS_LOB.INSTR(l_user_id_clob, l_pattern, l_position, 1);

      IF  l_pattern_position = 0 THEN
        l_amt := l_lob_length - l_position + 1;
      ELSE
        l_amt := l_pattern_position - l_position;
      END IF;

      dbms_lob.read (l_user_id_clob, l_amt, l_position, l_buffer);

      l_user_id := to_number(l_buffer);

          -- Check whether the distribution exists already
      OPEN check_exist_csr;
      FETCH check_exist_csr INTO l_count;
      CLOSE check_exist_csr;

      IF (l_count = 0) THEN -- first time dist
        l_insert_type := 'Insert';
        -- Object id is unique - ws id
        SELECT ZPB_TEMPLATE_WS_ID_SEQ.nextval
        INTO l_object_id
        FROM dual;

      ELSIF (l_count > 0) THEN -- distributed before
        l_insert_type := 'Update';
                SELECT object_id
                INTO l_object_id
        FROM ZPB_DC_OBJECTS
        WHERE TEMPLATE_ID = l_template_id
        AND OBJECT_USER_ID = l_user_id;
      END IF; -- count = or > 0

        FOR l_dist_worksheet_row_rec IN dist_worksheet_csr
        LOOP
                  IF (p_deadline_date is null) THEN
                    l_deadline_date := l_dist_worksheet_row_rec.deadline_date;
                  ELSE
                        l_deadline_date := p_deadline_date;
                  END IF;
          Distribute
          (
            p_object_id               => l_object_id,
                    p_object_type             => l_object_type,
            p_template_id             => l_template_id,
            p_ac_template_id          => l_dist_worksheet_row_rec.ac_template_id,
            p_analysis_cycle_id       => l_dist_worksheet_row_rec.analysis_cycle_id,
            p_ac_instance_id          => l_dist_worksheet_row_rec.ac_instance_id,
            p_generate_template_task_id => l_dist_worksheet_row_rec.generate_template_task_id,
            p_object_user_id          => l_user_id,
            p_distributor_user_id     => l_object_user_id,
            p_template_name           => l_dist_worksheet_row_rec.template_name,
                        p_dataentry_obj_path      => l_dist_worksheet_row_rec.dataentry_obj_path,
            p_dataentry_obj_name      => l_dist_worksheet_row_rec.dataentry_obj_name,
            p_target_obj_path         => l_dist_worksheet_row_rec.target_obj_path,
            p_target_obj_name         => l_dist_worksheet_row_rec.target_obj_name,
            p_deadline_date           => l_deadline_date,
            p_instruction_text_id     => l_dist_worksheet_row_rec.instruction_text_id,
            p_freeze_flag             => l_dist_worksheet_row_rec.freeze_flag,
                    p_distribution_method     => l_dist_worksheet_row_rec.distribution_method,
                    p_distribution_dimension  => l_dist_worksheet_row_rec.distribution_dimension,
                    p_distribution_hierarchy  => l_dist_worksheet_row_rec.distribution_hierarchy,
                    p_description             => l_dist_worksheet_row_rec.description,
                    p_approval_required_flag  => l_dist_worksheet_row_rec.approval_required_flag,
                    p_enable_target_flag      => l_dist_worksheet_row_rec.enable_target_flag,
                        p_create_inst_mea_flag    => l_dist_worksheet_row_rec.create_instance_measures_flag,
                        p_per_data_query_flag     => 'N',
                        p_per_target_query_flag   => 'N',
                    p_approver_type           => p_approver_type,
                    p_overwrite_custm         => p_overwrite_cust,
                    p_overwrite_ws_data       => p_overwrite_data,
            p_insert_type             => l_insert_type,
                    p_distribute_type         => 'MANUAL',
                  p_currency_flag	    => l_dist_worksheet_row_rec.currency_flag,
                  p_view_type 		    => l_dist_worksheet_row_rec.view_type,
                  p_business_area_id        => l_dist_worksheet_row_rec.business_area_id,
			p_multiple_submissions_flag => l_dist_worksheet_row_rec.multiple_submissions_flag
          );
        END LOOP;

          -- get clob next user
          l_position := l_pattern_position+1 ;
      IF  l_pattern_position = 0 THEN
        EXIT;
      END IF;

        END LOOP; -- clob loop
    END IF; -- clob length limit

  ELSE  -- recipients are specified
  OPEN specific_user_csr;
    -- Loop through the parameter table to get the user id
    LOOP
      FETCH specific_user_csr INTO l_user;
      EXIT WHEN specific_user_csr%NOTFOUND;

      -- Get the user id by user name
      SELECT user_id INTO l_user_id
      FROM fnd_user
      WHERE user_name = upper(l_user);

          -- Check whether the distribution exists already
      OPEN check_exist_csr;
      FETCH check_exist_csr INTO l_count;
      CLOSE check_exist_csr;

      -- Check whether the distribution exists already
      IF (l_count = 0) THEN
        l_insert_type := 'Insert';
        -- Object id is unique = ws id
        SELECT ZPB_TEMPLATE_WS_ID_SEQ.nextval
        INTO l_object_id
        FROM dual;

      ELSIF (l_count > 0) THEN
        l_insert_type := 'Update';
                SELECT object_id
                INTO l_object_id
        FROM ZPB_DC_OBJECTS
        WHERE TEMPLATE_ID = l_template_id
        AND OBJECT_USER_ID = l_user_id;

      END IF; -- l_count
              FOR l_dist_worksheet_row_rec IN dist_worksheet_csr
        LOOP
                  IF (p_deadline_date is null) THEN
                    l_deadline_date := l_dist_worksheet_row_rec.deadline_date;
                  ELSE
                        l_deadline_date := p_deadline_date;
                  END IF;
         Distribute
          (
            p_object_id               => l_object_id,
                    p_object_type             => l_object_type,
            p_template_id             => l_template_id,
            p_ac_template_id          => l_dist_worksheet_row_rec.ac_template_id,
            p_analysis_cycle_id       => l_dist_worksheet_row_rec.analysis_cycle_id,
            p_ac_instance_id          => l_dist_worksheet_row_rec.ac_instance_id,
            p_generate_template_task_id => l_dist_worksheet_row_rec.generate_template_task_id,
            p_object_user_id          => l_user_id,
            p_distributor_user_id     => l_object_user_id,
            p_template_name           => l_dist_worksheet_row_rec.template_name,
                        p_dataentry_obj_path      => l_dist_worksheet_row_rec.dataentry_obj_path,
            p_dataentry_obj_name      => l_dist_worksheet_row_rec.dataentry_obj_name,
            p_target_obj_path         => l_dist_worksheet_row_rec.target_obj_path,
            p_target_obj_name         => l_dist_worksheet_row_rec.target_obj_name,
            p_deadline_date           => l_deadline_date,
            p_instruction_text_id     => l_dist_worksheet_row_rec.instruction_text_id,
            p_freeze_flag             => l_dist_worksheet_row_rec.freeze_flag,
                    p_distribution_method     => l_dist_worksheet_row_rec.distribution_method,
                    p_distribution_dimension  => l_dist_worksheet_row_rec.distribution_dimension,
                    p_distribution_hierarchy  => l_dist_worksheet_row_rec.distribution_hierarchy,
                    p_description             => l_dist_worksheet_row_rec.description,
                    p_approval_required_flag  => l_dist_worksheet_row_rec.approval_required_flag,
                    p_enable_target_flag      => l_dist_worksheet_row_rec.enable_target_flag,
                        p_create_inst_mea_flag    => l_dist_worksheet_row_rec.create_instance_measures_flag,
                        p_per_data_query_flag     => 'N',
                        p_per_target_query_flag   => 'N',
                    p_approver_type           => p_approver_type,
                    p_overwrite_custm         => p_overwrite_cust,
                    p_overwrite_ws_data       => p_overwrite_data,
            p_insert_type             => l_insert_type,
                    p_distribute_type         => 'MANUAL',
                  p_currency_flag	    => l_dist_worksheet_row_rec.currency_flag,
                  p_view_type 		    => l_dist_worksheet_row_rec.view_type,
                  p_business_area_id        => l_dist_worksheet_row_rec.business_area_id,
			p_multiple_submissions_flag => l_dist_worksheet_row_rec.multiple_submissions_flag
          );
        END LOOP;

    END LOOP; -- loop through specific users
  END IF; -- recipient is specified or not
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Manual_Distribute_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Manual_Distribute_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Manual_Distribute_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );


END Manual_Distribute;

/*=========================================================================+
 |                       PROCEDURE Set_Template_Recipient
 |
 |
 | DESCRIPTION
 | This procedure sets the notification recipients for the template
 | distribution.
 |
 |
 +=========================================================================*/

PROCEDURE Set_Template_Recipient(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_template_id         IN    NUMBER,
  x_role_name           OUT   NOCOPY VARCHAR2)
IS

  l_api_name            CONSTANT VARCHAR2(30) := 'Set_Template_Recipient';
  l_api_version         CONSTANT NUMBER       :=  1.0;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_object_user_id      NUMBER;
  l_exp_days            NUMBER;
  l_charDate            VARCHAR2(20);
  l_rolename            VARCHAR2(320);

  CURSOR template_user_csr IS
  SELECT fnd.user_name
  FROM zpb_dc_objects obj, fnd_user fnd
  WHERE obj.template_id = p_template_id
  AND obj.object_user_id = fnd.user_id
  AND obj.object_type in ('W');
  --
BEGIN

  SAVEPOINT Set_Template_Recipient ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the parameters
  l_exp_days      := 7;

  -- API Body

  -- Create the role
  l_charDate := to_char(sysdate, 'J-SSSSS');
  l_rolename := 'ZPB_DC_TMPL_USER'|| to_char(p_template_id) || '-' || l_charDate;
  zpb_wf_ntf.SetRole(l_rolename, l_exp_days);

  FND_FILE.Put_Line ( FND_FILE.LOG, 'set_template_recipient -  l_rolename=' || l_rolename ) ;
  FOR template_user_rec IN template_user_csr
  LOOP
    FND_FILE.Put_Line ( FND_FILE.LOG, 'set_template_recipient -  template_user_rec.user_name=' || template_user_rec.user_name ) ;
    l_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_rolename, template_user_rec.user_name);
    FND_FILE.Put_Line ( FND_FILE.LOG, 'set_template_recipient - after call to update_Role_with_Shadows') ;
  END LOOP;
  x_role_name := l_rolename;
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Set_Template_Recipient ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Set_Template_Recipient ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Set_Template_Recipient ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );


END Set_Template_Recipient;



/*=========================================================================+
 |                       PROCEDURE Set_Ws_Recipient
 |
 |
 | DESCRIPTION
 | This procedure sets the notification users for worksheet distribution.
 |
 +=========================================================================*/
PROCEDURE Set_Ws_Recipient(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_task_id             IN      NUMBER,
  p_template_id         IN      NUMBER,
  p_dist_list_id        IN      NUMBER,
  p_object_id           IN      NUMBER,
  p_recipient_type      IN      VARCHAR2,
  x_role_name           OUT     NOCOPY VARCHAR2,
  x_resultout             OUT     NOCOPY VARCHAR2  )
IS
  l_api_name  CONSTANT  VARCHAR2(30) := 'Set_Ws_Recipient';

  l_param_value           zpb_task_parameters.value%TYPE;
  l_object_type           zpb_dc_objects.object_type%TYPE;
  l_exp_days              NUMBER;
  l_user                  VARCHAR2(4000);
  l_upper_user            VARCHAR2(100);
  l_charDate              VARCHAR2(20);
  l_rolename              VARCHAR2(320);
  l_dist_list_id          NUMBER := 0;
  l_recipient_type        VARCHAR2(30);
  l_object_user_id        NUMBER;
  l_template_id           NUMBER;
  l_object_id             NUMBER;
  l_resp_key              fnd_responsibility.responsibility_key%TYPE;
  --
  l_amt                   INTEGER;
  l_buffer                VARCHAR2(30);
  l_user_id_clob          CLOB;
  l_lob_length            BINARY_INTEGER;
  l_ind                   BINARY_INTEGER;

  l_pattern               VARCHAR2(1);
  l_role_has_users        VARCHAR2(1);
  l_position              BINARY_INTEGER;
  l_pattern_position      BINARY_INTEGER;

  aw_user_list  zpb_num_tbl_type;

  -- Auto distribution
  CURSOR param_type_csr IS
  SELECT value
  FROM   zpb_task_parameters
  WHERE  task_id = p_task_id
  AND    name = 'DISTRIBUTION_RECIPIENT_TYPE';

  -- Auto distribution
  CURSOR specific_user_csr IS
  SELECT value
  FROM   zpb_task_parameters
  WHERE  task_id = p_task_id
  AND    name = 'DISTRIBUTION_SPECIFIED_USERS';

  -- Manual distribution
  CURSOR dist_list_csr IS
  SELECT user_name
    FROM zpb_dc_distribution_list_items
   WHERE distribution_list_id = p_dist_list_id;

BEGIN
  ZPB_LOG.WRITE(G_PKG_NAME||'.'||l_api_name, 'BEGIN');
  ZPB_LOG.WRITE(G_PKG_NAME||'.'||l_api_name, 'IN Parameter:'
    || ' p_init_msg_list='           || p_init_msg_list
    || ' p_commit='                  || p_commit
    || ' p_task_id='                 || p_task_id
    || ' p_template_id='             || p_template_id
    || ' p_dist_list_id='            || p_dist_list_id
    || ' p_object_id='               || p_object_id
    || ' p_recipient_type='          || p_recipient_type);

  -- Initialize the parameters
  l_exp_days              := 7;
  l_dist_list_id          := 0;
  l_amt                   := 255;
  l_ind                   := 1;
  l_pattern               := ',';
  l_position              := 1;
  l_pattern_position      := 1;

  -- API Body

  IF (p_task_id is not null) THEN -- Auto distribution

    ZPB_LOG.WRITE(G_PKG_NAME||'.'||l_api_name, 'Auto Distribution');
    -- Set the resp key
        l_resp_key := 'ZPB_CONTROLLER_RESP';

    -- Get the recipient type
    OPEN param_type_csr;
    FETCH param_type_csr INTO l_param_value;
    CLOSE param_type_csr;

    -- Create the role
        l_charDate := to_char(sysdate, 'J-SSSSS');
    l_rolename := 'ZPB_DC_AUTO'|| to_char(p_task_id) || '-' || l_charDate;
    zpb_wf_ntf.SetRole(l_rolename, l_exp_days);
    l_role_has_users :=  'N';

        SELECT object_id, object_user_id
        INTO l_object_id, l_object_user_id
        FROM zpb_dc_objects
        WHERE template_id = p_template_id
        AND object_type = 'M';

    IF l_param_value = 'SPECIFIC_USERS' THEN
      OPEN specific_user_csr;
      LOOP
            FETCH specific_user_csr INTO l_user;
            EXIT WHEN specific_user_csr%NOTFOUND;
        l_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_rolename, l_user );
        l_role_has_users := 'Y';
      END LOOP;
          CLOSE specific_user_csr;


    ELSE -- other than specific users -- auto
      -- Get the clob of user ids
      get_user_id_clob(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        --
        p_object_id           => l_object_id,
        p_object_user_id      => l_object_user_id,
        p_recipient_type      => l_param_value,
                p_resp_key            => l_resp_key,
        x_user_id_clob        => l_user_id_clob);

          l_ind := 1;
      l_position:= 1;
      l_lob_length := dbms_lob.getlength(l_user_id_clob);

          -- Parse the clob and put the ids in a tab type object
          IF l_lob_length > 0 THEN
        aw_user_list := zpb_num_tbl_type(0);
      END IF;

      IF l_lob_length > 0 THEN
      LOOP
        l_pattern_position := DBMS_LOB.INSTR(l_user_id_clob, l_pattern, l_position, 1);

        IF  l_pattern_position = 0 THEN
          l_amt := l_lob_length - l_position+1;
        ELSE
          l_amt := l_pattern_position - l_position;
        END IF;

        dbms_lob.read (l_user_id_clob, l_amt, l_position, l_buffer);
        aw_user_list.extend;
        aw_user_list(l_ind):= to_number(l_buffer);
        l_ind:= l_ind+1;

        l_position := l_pattern_position+1 ;
        IF  l_pattern_position = 0 THEN
          EXIT;
        END IF;

      END LOOP;
      END IF; -- parse and store the ids

       -- Join the fnd user to get the user names
      FOR fnd_rec IN
          (select column_value , fndu.user_name user_name
           from
           table( cast(aw_user_list as zpb_num_tbl_type)) aw_users,
           fnd_user fndu
           where fndu.user_id = aw_users.column_value
              )
      LOOP
        l_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_rolename, fnd_rec.user_name);
        l_role_has_users := 'Y';
      END LOOP;

    END IF; --recipients types

  ELSE -- Manual distribution

    ZPB_LOG.WRITE(G_PKG_NAME||'.'||l_api_name, 'Manual Distribution');

    -- Populate resp key based on object type and object id/user id
    SELECT object_type, object_id, object_user_id
        INTO l_object_type, l_object_id, l_object_user_id
        FROM zpb_dc_objects
        WHERE object_id = p_object_id;

    IF (l_object_type = 'E') THEN
      l_resp_key := 'ZPB_CONTROLLER_RESP';
    ELSE
      l_resp_key := 'ZPB_ANALYST_RESP';
    END IF;

        -- Create the role
    l_charDate := to_char(sysdate, 'J-SSSSS');
    l_rolename := 'ZPB_DC_MAN'|| to_char(p_dist_list_id) || '-' || l_charDate;
    ZPB_LOG.WRITE(G_PKG_NAME||'.'||l_api_name, ' l_rolename='||l_rolename);

    zpb_wf_ntf.SetRole(l_rolename, l_exp_days);

    l_role_has_users :=  'N';

    IF (p_recipient_type ='SPECIFIC_USERS') THEN

      ZPB_LOG.WRITE(G_PKG_NAME||'.'||l_api_name, 'SPECIFIC_USERS');

      OPEN dist_list_csr;
      LOOP
            FETCH dist_list_csr INTO l_user;
            EXIT WHEN dist_list_csr%NOTFOUND;
        l_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_rolename, l_user);
        l_role_has_users := 'Y';
      END LOOP;
      CLOSE dist_list_csr;

    ELSE -- Other than specific users -manual

      ZPB_LOG.WRITE(G_PKG_NAME||'.'||l_api_name, 'ALL DATA OWNERS');

      -- Get the clob of user ids
      get_user_id_clob(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        --
        p_object_id           => l_object_id,
        p_object_user_id      => l_object_user_id,
        p_recipient_type      => p_recipient_type,
                p_resp_key            => l_resp_key,
        x_user_id_clob        => l_user_id_clob);

      -- Parse the clob and put the ids in a tab type object
      l_ind := 1;
      l_position:= 1;
      l_lob_length := dbms_lob.getlength(l_user_id_clob);

      IF l_lob_length > 0 THEN
        aw_user_list := zpb_num_tbl_type(0);
      END IF;

      IF l_lob_length > 0 THEN
        LOOP
          l_pattern_position := DBMS_LOB.INSTR(l_user_id_clob, l_pattern, l_position, 1);

          IF  l_pattern_position = 0 THEN
            l_amt := l_lob_length - l_position+1;
          ELSE
            l_amt := l_pattern_position - l_position;
          END IF;

          dbms_lob.read (l_user_id_clob, l_amt, l_position, l_buffer);
          aw_user_list.extend;
          aw_user_list(l_ind):= to_number(l_buffer);
          l_ind:= l_ind+1;

          l_position := l_pattern_position+1 ;
          IF  l_pattern_position = 0 THEN
            EXIT;
          END IF;

        END LOOP;
      END IF; -- parse and store the ids

      FOR fnd_rec IN
          (select column_value , fndu.user_name user_name
           from
           table( cast(aw_user_list as zpb_num_tbl_type)) aw_users,
           fnd_user fndu
           where fndu.user_id = aw_users.column_value
              )
      LOOP
        l_rolename := zpb_wf_ntf.update_Role_with_Shadows(l_rolename, fnd_rec.user_name);
        l_role_has_users := 'Y';
      END LOOP;

    END IF; --recipients types
  END IF; -- Auto or manual

  -- Return role_name only if it has any Users.
  IF (l_role_has_users = 'Y') THEN
      x_resultout := 'COMPLETE:Y';
      x_role_name := l_rolename;
  ELSE
      x_resultout := 'COMPLETE:N';
  END IF;

  ZPB_LOG.WRITE(G_PKG_NAME||'.'||l_api_name, 'END. Out Parameters:'
    || ' x_resultout='||x_resultout
    || ' x_role_name='||x_role_name);

  EXCEPTION
  WHEN OTHERS THEN
    ZPB_LOG.WRITE(G_PKG_NAME||'.'||l_api_name, 'EXCEPTION');
    raise;

END Set_Ws_Recipient;


/*=========================================================================+
 |                       PROCEDURE Complete_Review
 |
 |
 | DESCRIPTION
 | This procedure changes the complete_review_flag to 'Y' when
 | user finishes review and clicks on Finish Reciew button from the UI.
 |
 +=========================================================================*/
PROCEDURE Complete_Review(
    p_api_version         IN    NUMBER,
    p_init_msg_list       IN    VARCHAR2,
    p_commit              IN    VARCHAR2,
    p_validation_level    IN    NUMBER,
    x_return_status       OUT   NOCOPY VARCHAR2,
    x_msg_count           OUT   NOCOPY NUMBER,
    x_msg_data            OUT   NOCOPY VARCHAR2,
    --
        p_template_id         IN      NUMBER)
IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Complete_Review';
  l_api_version         CONSTANT NUMBER       :=  1.0;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_data_obj_name         zpb_dc_objects.dataentry_obj_name%TYPE;
  l_target_obj_name       zpb_dc_objects.target_obj_name%TYPE;


BEGIN

  SAVEPOINT Complete_Review_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the parameters

  -- API Body

  -- M needs a separate object in the repostory
  --l_data_obj_name := 'TEMPL_DATA_'||p_template_id||'_MASTER';
  --l_target_obj_name := 'TEMPL_TARGET_'||p_template_id||'_MASTER';
  -- logic moved to ui java file --

  -- Update C with 'M' record
  FOR e_rec IN
         (SELECT TEMPLATE_NAME           ,
                 DATAENTRY_OBJ_PATH      ,
                 DATAENTRY_OBJ_NAME      ,
                 TARGET_OBJ_PATH         ,
                 TARGET_OBJ_NAME         ,
                 INSTRUCTION_TEXT_ID     ,
                 DESCRIPTION             ,
                 DEADLINE_DATE
          FROM   ZPB_DC_OBJECTS
          WHERE  TEMPLATE_ID = p_template_id
          AND    OBJECT_TYPE = 'M')
  LOOP
    UPDATE ZPB_DC_OBJECTS
        SET      TEMPLATE_NAME           = e_rec.template_name,
                 DESCRIPTION             = e_rec.description,
                 DATAENTRY_OBJ_PATH      = e_rec.dataentry_obj_path,
                 DATAENTRY_OBJ_NAME      = e_rec.dataentry_obj_name,
                 TARGET_OBJ_PATH         = e_rec.target_obj_path,
                 TARGET_OBJ_NAME         = e_rec.target_obj_name,
		 PERSONAL_DATA_QUERY_FLAG   = 'N',
		 PERSONAL_TARGET_QUERY_FLAG = 'N',
		 CREATE_SOLVE_PROGRAM_FLAG  = 'Y',
                 INSTRUCTION_TEXT_ID     = e_rec.instruction_text_id,
                 DEADLINE_DATE           = e_rec.deadline_date,
                 LAST_UPDATED_BY         = fnd_global.USER_ID,
                 LAST_UPDATE_DATE        = SYSDATE,
                 LAST_UPDATE_LOGIN       = fnd_global.LOGIN_ID
                 WHERE TEMPLATE_ID       = p_template_id
                 AND OBJECT_TYPE = 'C';
  END LOOP;

  UPDATE ZPB_DC_OBJECTS
     SET REVIEW_COMPLETE_FLAG = 'Y',
         STATUS = 'REVIEW_COMPLETED',
         LAST_UPDATED_BY        = fnd_global.USER_ID,
         LAST_UPDATE_DATE   = SYSDATE,
         LAST_UPDATE_LOGIN  = fnd_global.LOGIN_ID
   WHERE TEMPLATE_ID = p_template_id
     AND OBJECT_TYPE in ('E','M');

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
  COMMIT WORK;
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Complete_Review_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Complete_Review_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Complete_Review_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );


END Complete_Review;



/*=========================================================================+
 |                       PROCEDURE Delete_Template
 |
 |
 | DESCRIPTION
 | This procedure is called by zpbac.plb. When the analysis cycle gets deleted
 | the template gets deleted too.
 |
 +=========================================================================*/
PROCEDURE Delete_Template(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2,
  p_commit              IN      VARCHAR2,
  p_validation_level    IN      NUMBER,
  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2,
  --
  p_analysis_cycle_instance_id   IN      NUMBER)
IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Template';
  l_api_version         CONSTANT NUMBER       :=  1.0;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

BEGIN

  SAVEPOINT Delete_Template_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the parameters

  -- API Body

  UPDATE zpb_dc_objects
  SET delete_instance_measures_flag = 'Y'
  WHERE ac_instance_id = p_analysis_cycle_instance_id;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Template_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Template_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Template_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Delete_Template;

/*=========================================================================+
 |                       PROCEDURE Set_Submit_Ntf_Recipients
 |
 |
 | DESCRIPTION
 | This procedure will set the recipients for the submission activity.
 |
 +=========================================================================*/
PROCEDURE Set_Submit_Ntf_Recipients(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_object_id           IN    NUMBER,
  x_role_name           OUT   NOCOPY VARCHAR2)
IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Set_Submit_Ntf_Recipients';
  l_api_version         CONSTANT NUMBER       :=  1.0;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_exp_days              NUMBER;
  l_user                  VARCHAR2(4000);
  l_charDate              VARCHAR2(20);
  l_rolename              VARCHAR2(320);
  l_recipient_type        VARCHAR2(30);
  l_object_user_id        NUMBER;
  l_resp_key              fnd_responsibility.responsibility_key%TYPE;
  --
  l_amt                   INTEGER;
  l_buffer                VARCHAR2(30);
  l_user_id_clob          CLOB;
  l_lob_length            BINARY_INTEGER;
  l_ind                   BINARY_INTEGER;

  l_pattern               VARCHAR2(1);
  l_position              BINARY_INTEGER;
  l_pattern_position      BINARY_INTEGER;
  aw_user_list            zpb_num_tbl_type;

BEGIN

  SAVEPOINT Set_Submit_Ntf_Recipients;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the parameters
  l_exp_days := 7;
  l_amt      := 255;
  l_ind      := 1;
  l_pattern  := ',';
  l_position := 1;
  l_pattern_position := 1;

  -- API Body

  SELECT object_user_id
  INTO l_object_user_id
  FROM zpb_dc_objects
  WHERE object_id = p_object_id;

  l_recipient_type := 'ALL_RPT';

  -- Create the role
  l_charDate := to_char(sysdate, 'J-SSSSS');
  l_rolename := 'ZPB_DC_SUB'|| to_char(p_object_id) || '-' || l_charDate;
  zpb_wf_ntf.SetRole(l_rolename, l_exp_days);

  get_user_id_clob(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        --
        p_object_id           => p_object_id,
        p_object_user_id      => l_object_user_id,
        p_recipient_type      => l_recipient_type,
                p_resp_key            => l_resp_key,
        x_user_id_clob        => l_user_id_clob);

  -- Parse the clob and put the ids in a tab type object
  l_ind := 1;
  l_position:= 1;
  l_lob_length := dbms_lob.getlength(l_user_id_clob);

  IF (l_lob_length > 0) THEN
    aw_user_list := zpb_num_tbl_type(0);
  END IF ;

  IF l_lob_length > 0 THEN
  LOOP
    l_pattern_position := DBMS_LOB.INSTR(l_user_id_clob, l_pattern, l_position, 1);

    IF  l_pattern_position = 0 THEN
      l_amt := l_lob_length - l_position+1;
    ELSE
      l_amt := l_pattern_position - l_position;
    END IF;

    dbms_lob.read (l_user_id_clob, l_amt, l_position, l_buffer);
    aw_user_list.extend;
    aw_user_list(l_ind):= to_number(l_buffer);
    l_ind:= l_ind+1;

    l_position := l_pattern_position+1 ;
    IF  l_pattern_position = 0 THEN
      EXIT;
    END IF;

  END LOOP;
  END IF; -- parse and store the ids

  -- Join the fnd user to get the user names
  FOR fnd_rec IN
    (select column_value , fndu.user_name user_name
     from
     table( cast(aw_user_list as zpb_num_tbl_type)) aw_users,
     fnd_user fndu
     where fndu.user_id = aw_users.column_value
     )
     LOOP
       ZPB_UTIL_PVT.AddUsersToAdHocRole(l_rolename, fnd_rec.user_name);
     END LOOP;
         x_role_name := l_rolename;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Set_Submit_Ntf_Recipients ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Set_Submit_Ntf_Recipients;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Set_Submit_Ntf_Recipients ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Set_Submit_Ntf_Recipients;

/*=========================================================================+
 |                       PROCEDURE Set_Source_Type
 |
 |
 | DESCRIPTION
 | This procedure will be called by backend api to change the
 | copy_source_type_flag to 'Y' at redistribution.
 |
 +=========================================================================*/

PROCEDURE Set_Source_Type(
  p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2,
  p_commit              IN    VARCHAR2,
  p_validation_level    IN    NUMBER,
  x_return_status       OUT   NOCOPY VARCHAR2,
  x_msg_count           OUT   NOCOPY NUMBER,
  x_msg_data            OUT   NOCOPY VARCHAR2,
  --
  p_ac_instance_id      IN    NUMBER)

IS

  l_api_name            CONSTANT VARCHAR2(30) := 'Set_Source_Type';
  l_api_version         CONSTANT NUMBER       :=  1.0;

BEGIN

  SAVEPOINT Set_Source_Type;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the parameters

  -- API Body
  UPDATE zpb_dc_objects
  SET copy_source_type_flag = 'Y',
      create_solve_program_flag = 'Y',
      LAST_UPDATED_BY       = fnd_global.USER_ID,
      LAST_UPDATE_DATE      = SYSDATE,
      LAST_UPDATE_LOGIN     = fnd_global.LOGIN_ID
  WHERE ac_instance_id = p_ac_instance_id;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Set_Source_Type ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Set_Source_Type ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Set_Source_Type ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Set_Source_Type;


PROCEDURE Update_Template_View_Type(
  p_template_id		IN	NUMBER,
  p_view_type		IN	VARCHAR2,
  p_result_out		OUT	NOCOPY VARCHAR2)

IS

BEGIN

  SAVEPOINT Update_Template_View_Type;

  UPDATE ZPB_DC_OBJECTS SET view_type = p_view_type,
    create_solve_program_flag = 'Y'  where
  template_id = p_template_id and (object_type = 'M' or object_type = 'E' or object_type = 'C');

  p_result_out := 'S';

EXCEPTION

  WHEN OTHERS THEN
   	ROLLBACK TO Update_Template_View_Type;
   	p_result_out := 'E';

END Update_Template_View_Type;


PROCEDURE Update_Worksheet_View_Type(
  p_template_id		IN	NUMBER,
  p_object_id		IN	NUMBER,
  p_view_type		IN	VARCHAR2,
  p_result_out		OUT	NOCOPY VARCHAR2)

IS
  s_object_type		VARCHAR2(1);

BEGIN

  SAVEPOINT Update_Worksheet_View_Type;

  SELECT object_type INTO s_object_type FROM zpb_dc_objects where
  object_id = p_object_id;

  --Check if it is a Controller's Worksheet, If it is then we need to update
  --the records of type 'M' and 'E' also
  IF s_object_type = 'C' THEN
     Update_Template_View_Type(p_template_id,p_view_type,p_result_out);
  ELSE
     UPDATE zpb_dc_objects SET view_type = p_view_type,
     create_solve_program_flag = 'Y' where
     template_id = p_template_id and object_id = p_object_id;
  END IF;

  p_result_out := 'S';

EXCEPTION

   WHEN OTHERS THEN
   	ROLLBACK TO Update_Worksheet_View_Type;
   	p_result_out := 'E';

END Update_Worksheet_View_Type;

END ZPB_DC_OBJECTS_PVT;

/
