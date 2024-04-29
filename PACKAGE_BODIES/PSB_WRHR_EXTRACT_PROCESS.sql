--------------------------------------------------------
--  DDL for Package Body PSB_WRHR_EXTRACT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WRHR_EXTRACT_PROCESS" AS
/* $Header: PSBWHRCB.pls 120.30 2005/12/21 12:16:39 maniskum ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WRHR_EXTRACT_PROCESS';
  g_dbug      VARCHAR2(2000);

  TYPE TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens

  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  -- Number of Message Tokens

  no_msg_tokens       NUMBER := 0;

  -- Message Token Name

  msg_tok_names       TokNameArray;

  -- Message Token Value

  msg_tok_val         TokValArray;

  PROCEDURE message_token
  ( tokname  IN  VARCHAR2,
    tokval   IN  VARCHAR2
  );

  PROCEDURE add_message
  ( appname  IN  VARCHAR2,
    msgname  IN  VARCHAR2
  );

  PROCEDURE Pre_Create_Data_Extract
  ( p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_return_status     OUT  NOCOPY VARCHAR2,
    p_msg_count         OUT  NOCOPY NUMBER,
    p_msg_data          OUT  NOCOPY VARCHAR2,
    p_data_extract_id   IN  NUMBER);


 g_business_group_id         number := 0;
 g_data_extract_id           number := 0;
 g_data_extract_name         varchar2(30) := 'X';
 g_data_extract_method       varchar2(30) := 'X';
 g_set_of_books_id           number := 0;
 g_req_data_as_of_date       date;
 g_copy_defaults_flag        varchar2(1) := 'N';
 g_copy_defaults_status      varchar2(1) := 'I';
 g_populate_interface_flag   varchar2(1) := 'N';
 g_populate_interface_status varchar2(1) := 'I';
 g_validate_data_flag        varchar2(1) := 'N';
 g_validate_data_status      varchar2(1) := 'I';
 g_populate_data_flag        varchar2(1) := 'N';
 g_populate_data_status      varchar2(1) := 'I';
 g_default_data_flag         varchar2(1) := 'N';
 g_default_data_status       varchar2(1) := 'I';
 g_copy_data_extract_id      number := 0;
 g_copy_salary_flag          varchar2(1);
 g_position_id_flex_num      number;
 gc_return_status            varchar2(1);
 gi_return_status            varchar2(1);
 gv_return_status            varchar2(1);
 gp_return_status            varchar2(1);


  PROCEDURE Perform_Data_Extract
  ( p_api_version         IN     NUMBER,
    p_init_msg_list       IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_return_status       OUT  NOCOPY    VARCHAR2,
    p_msg_count           OUT  NOCOPY    NUMBER,
    p_msg_data            OUT  NOCOPY    VARCHAR2,
    p_data_extract_id     IN     NUMBER
  ) AS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Perform_Data_Extract';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_return_status       varchar2(1);
  l_msg_count           number;
  l_msg_data            varchar2(2000);
  l_validate_flag       varchar2(1);
  l_req_id              number;
  l_rep_req_id          number;
  l_reqid               NUMBER;
  l_userid              NUMBER ;

  Cursor C_DataExtract is
    SELECT BUSINESS_GROUP_ID,
	   SET_OF_BOOKS_ID,
	   DATA_EXTRACT_METHOD,
	   REQ_DATA_AS_OF_DATE,
	   NVL(POPULATE_INTERFACE_FLAG,'I') POPULATE_INTERFACE_FLAG,
	   NVL(POPULATE_INTERFACE_STATUS,'I') POPULATE_INTERFACE_STATUS,
	   NVL(VALIDATE_DATA_FLAG,'I') VALIDATE_DATA_FLAG,
	   NVL(VALIDATE_DATA_STATUS,'I') VALIDATE_DATA_STATUS,
	   NVL(POPULATE_DATA_FLAG,'I') POPULATE_DATA_FLAG,
	   NVL(POPULATE_DATA_STATUS,'I') POPULATE_DATA_STATUS,
	   NVL(DEFAULT_DATA_FLAG,'I') DEFAULT_DATA_FLAG,
	   NVL(DEFAULT_DATA_STATUS,'I') DEFAULT_DATA_STATUS,
	   NVL(COPY_DEFAULTS_FLAG,'I') COPY_DEFAULTS_FLAG,
	   NVL(COPY_DEFAULTS_STATUS,'I') COPY_DEFAULTS_STATUS,
	   COPY_DEFAULTS_EXTRACT_ID,
	   COPY_SALARY_FLAG,
	   POSITION_ID_FLEX_NUM
      FROM PSB_DATA_EXTRACTS
     WHERE data_extract_id = p_data_extract_id;

BEGIN

    -- Standard call to check for call compatibility.

    if not FND_API.Compatible_API_Call (l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME)
    then
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    -- Initialize message list if p_init_msg_list is set to TRUE.

    if FND_API.to_Boolean (p_init_msg_list) then
       FND_MSG_PUB.initialize;
    end if;

    -- Initialize API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body


    For C_DataRec in C_DataExtract
    Loop
     l_validate_flag := 'N';
     if (C_DataRec.validate_data_flag = 'Y') then
	if (C_DataRec.validate_data_status <> 'C') then
	l_validate_flag := 'Y';
       end if;
     end if;

     if (C_DataRec.populate_data_flag = 'Y') then
	if (C_DataRec.populate_data_status <> 'C') then

	    Update Psb_Data_Extracts
	       set data_extract_status = 'I'
	     where data_extract_id = p_data_extract_id;

	end if;

     end if;

     if (C_DataRec.default_data_flag = 'Y') then
	if (C_DataRec.default_data_status <> 'C') then
	PSB_HR_POPULATE_DATA_PVT.Apply_Defaults
	( p_api_version         =>   1.0,
	  p_init_msg_list       =>   FND_API.G_FALSE,
	  p_commit              =>   FND_API.G_FALSE,
	  p_validation_level    =>   FND_API.G_VALID_LEVEL_FULL,
	  p_return_status       =>   l_return_status,
	  p_msg_count           =>   l_msg_count,
	  p_msg_data            =>   l_msg_data,
	  p_data_extract_id     =>   p_data_extract_id,
	  p_extract_method      =>   C_DataRec.data_extract_method
	);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   message_token('PROCESS', 'Apply Defaults');
	   add_message('PSB', 'PSB_EXTRACT_FAILURE_MESSAGE');
	   p_return_status := FND_API.G_RET_STS_ERROR;
	   --raise FND_API.G_EXC_ERROR;
	else
	   message_token('PROCESS', 'Apply Defaults');
	   add_message('PSB', 'PSB_EXTRACT_SUCCESS_MESSAGE');
	end if;
     end if;
    end if;

    End Loop;

    -- End of API body.
    --Add message stack to PSB_ERROR_MESSAGES

    DELETE FROM PSB_ERROR_MESSAGES
    WHERE process_id = p_data_extract_id;

    l_reqid  := FND_GLOBAL.CONC_REQUEST_ID;
    l_userid := FND_GLOBAL.USER_ID;

    FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			       p_data  => l_msg_data );
    IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

    END IF;

    -- Standard check of p_commit.
    if FND_API.to_Boolean (p_commit) then
       commit work;
    end if;

    if (l_msg_count > 0) then

       l_req_id := FND_GLOBAL.CONC_REQUEST_ID;

       l_rep_req_id := Fnd_Request.Submit_Request
		       (application   => 'PSB'                          ,
			program       => 'PSBRPERR'                     ,
			description   => 'Error Messages Listing'       ,
			start_time    =>  NULL                          ,
			sub_request   =>  FALSE                         ,
			argument1     =>  NULL                          ,
			argument2     =>  p_data_extract_id             ,
			argument3     =>  'DATA_EXTRACT_VALIDATION'
		      );
       --
       if l_rep_req_id = 0 then
       --
	  fnd_message.set_name('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
	  raise FND_API.G_EXC_ERROR ;
       --
       end if;

    end if;

    -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);

    EXCEPTION

    when FND_API.G_EXC_ERROR then

      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);


    when FND_API.G_EXC_UNEXPECTED_ERROR then

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);


    when OTHERS then

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

	 FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				  l_api_name);
      end if;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

 END Perform_Data_Extract;


 PROCEDURE Interface_Purge
 (  p_api_version                 IN     NUMBER,
    p_init_msg_list               IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                      IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level            IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    /* Start bug #4386374 */
    p_data_extract_id             IN     NUMBER := null, -- Fixed for Bug#4683895
    p_populate_interface_flag     IN     VARCHAR2 := null, -- Added this for Bug#4683895
    /* End bug #4386374 */
    p_return_status       OUT  NOCOPY    VARCHAR2,
    p_msg_count           OUT  NOCOPY    NUMBER,
    p_msg_data            OUT  NOCOPY    VARCHAR2)
 as
  /* Start bug #4386374 */
-- Commented the following cursor and redefined.
--
-- Cursor C_Interface is
--  Select data_extract_id
--    from psb_data_extracts
--   where decode(copy_defaults_flag,'Y',copy_defaults_status,'C') = 'C'
--     and decode(populate_interface_flag,'Y',populate_interface_status,'C') = 'C'
--     and decode(validate_data_flag,'Y',validate_data_status,'C') = 'C'
--     and decode(populate_data_flag,'Y',populate_data_status,'C') = 'C'
--     and decode(default_data_flag,'Y',default_data_status,'C') = 'C'
--     and nvl(data_extract_status,'I')  = 'C'
--     and nvl(rerun_flag,'X') <> 'Y'
--   order by data_extract_id;


 CURSOR C_Interface is
  SELECT data_extract_id
    FROM psb_data_extracts
   WHERE (data_extract_id = (DECODE(p_populate_interface_flag, 'Y', p_data_extract_id, 0))
      OR (data_extract_id <> DECODE(p_populate_interface_flag, 'Y', 0, p_data_extract_id)
     AND populate_interface_status = 'C'
     AND validate_data_status = 'C'
     AND populate_data_status = 'C'
     AND DECODE(default_data_flag,'Y',default_data_status,'C') = 'C' -- Added this for Bug#4683895
     AND DECODE(copy_defaults_flag,'Y',copy_defaults_status,'C') = 'C' -- Added this for Bug#4683895
     AND data_extract_status = 'C'))
     AND NVL(rerun_flag,'X') <> 'Y' -- Added this for Bug#4683895
   ORDER BY data_extract_id;

  /* End bug #4386374 */

  l_api_name            CONSTANT VARCHAR2(30)   := 'Interface_Purge';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_return_status       varchar2(1);
  l_msg_count           number;
  l_msg_data            varchar2(2000);

 Begin

    -- Standard call to check for call compatibility.

    if not FND_API.Compatible_API_Call (l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME)
    then
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    -- Initialize message list if p_init_msg_list is set to TRUE.

    if FND_API.to_Boolean (p_init_msg_list) then
       FND_MSG_PUB.initialize;
    end if;

    -- Initialize API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

   For C_Interface_Rec in C_Interface
   Loop
     begin
     delete psb_positions_i
      where data_extract_id = C_Interface_Rec.data_extract_id;

     commit work;

     exception
       when NO_DATA_FOUND then
	null;
     end;
     begin
     delete psb_salary_i
      where data_extract_id = C_Interface_Rec.data_extract_id;

     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;
     begin
     delete psb_employees_i
      where data_extract_id = C_Interface_Rec.data_extract_id;

     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;

     begin
     delete psb_cost_distributions_i
      where data_extract_id = C_Interface_Rec.data_extract_id;

     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;

     begin
     delete psb_attribute_values_i
      where data_extract_id = C_Interface_Rec.data_extract_id;

     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;

     begin
     delete psb_employee_assignments_i
      where data_extract_id = C_Interface_Rec.data_extract_id;

     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;

   /* Commented for bug 3325056 .. Start
    begin
     delete psb_reentrant_process_status
      where process_uid = C_Interface_Rec.data_extract_id
	and process_type = 'HR DATA EXTRACT';

     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;
    bug 3325056 end ..  */

   End Loop;

    -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);

    EXCEPTION

    when FND_API.G_EXC_ERROR then

      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);


    when FND_API.G_EXC_UNEXPECTED_ERROR then

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);


    when OTHERS then

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

	 FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				  l_api_name);
      end if;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);


 End Interface_Purge;

 -- de by org
 -- This procedure inserts into psb_data_extract_orgs all organizations
 -- belonging to a Business Group.

 PROCEDURE Insert_Organizations
 (  p_api_version         IN     NUMBER,
    p_init_msg_list       IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_data_extract_id     IN     NUMBER,
    p_as_of_date          IN      DATE,
    p_business_group_id   IN     NUMBER,
    p_return_status       OUT    NOCOPY    VARCHAR2,
    p_msg_count           OUT    NOCOPY    NUMBER,
    p_msg_data            OUT    NOCOPY    VARCHAR2)
  as
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Organizations';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_return_status       varchar2(1);
  l_msg_count           number;
  l_msg_data            varchar2(2000);
  l_organization_id     number;
  l_organization_name   varchar2(240);
  l_completion_status   varchar2(1);
  l_completion_time     DATE;
  l_last_update_date    DATE;
  l_last_updated_BY     number;
  l_last_update_login   number;
  l_creation_date       DATE;
  l_created_by          number;

  Begin

     -- Standard call to check for call compatibility.

       if not FND_API.Compatible_API_Call (l_api_version,
          				   p_api_version,
					   l_api_name,
					   G_PKG_NAME)
        then
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

     -- Initialize message list if p_init_msg_list is set to TRUE.

	if FND_API.to_Boolean (p_init_msg_list) then
	       FND_MSG_PUB.initialize;
        end if;

     -- Initialize API return status to success

        p_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body


     -- The following statement will insert the organization details into
     -- PSB_DATA_EXTRACT_ORGS table.
     -- This is used to ensure that all the organizations available
     -- in HR are extracted into PSB_DATA_EXTRACT_ORGS table.


     IF (p_data_extract_id IS NOT NULL) THEN

	      INSERT INTO PSB_DATA_EXTRACT_ORGS
	        (
	         data_extract_id,
	         organization_id,
	         organization_name,
                 select_flag, -- For Bug: 4248378. Select_flag has to be inserted initially.
	         completion_status,
	         completion_time,
                 last_update_date,
                 last_updated_BY,
                 last_update_login,
                 creation_date,
                 created_by
	        )
               SELECT
	        de.data_extract_id,
	        org.organization_id,
	        org.name,
                'N', -- For Bug: 4248378. Select_flag has to be inserted initially.
	        NULL,  --For Bug No:3071201. For every new organization first insert Null status into Psb_Data_Extract_Orgs table.
	        NULL,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID
	      FROM PSB_DATA_EXTRACTS de,
	           PER_ORGANIZATION_UNITS org
	      WHERE de.data_extract_id = p_data_extract_id
	       AND de.business_group_id = org.business_group_id
	       AND p_as_of_date between date_from and nvl(date_to, p_as_of_date)
	       AND NOT EXISTS (
		        SELECT 1
	       	          FROM PSB_DATA_EXTRACT_ORGS C
		         WHERE c.data_extract_id = p_data_extract_id
		         AND c.organization_id = org.organization_id);
     END IF;

     -- Standard call to get message count and if count is 1, get message info.

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
       			        p_data  => p_msg_data);
     COMMIT WORK;

     EXCEPTION
     when FND_API.G_EXC_ERROR then

       p_return_status := FND_API.G_RET_STS_ERROR;

       FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
       				  p_data  => p_msg_data);


     when FND_API.G_EXC_UNEXPECTED_ERROR then

       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
       				  p_data  => p_msg_data);


     when OTHERS then

       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

	 FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				  l_api_name);
       end if;

       FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				  p_data  => p_msg_data);


End insert_organizations;


/*===========================================================================+
 |                   PROCEDURE Perform_Data_Extract_CP                   |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Extract Data
-- From Human Resources'
--
PROCEDURE Perform_Data_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_data_extract_id            IN      NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Perform_Data_Extract_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_data_extract_name       VARCHAR2(30);

  -- de by org
  l_extract_by_org          VARCHAR2(1);
  l_data_extract_id         VARCHAR2(1);
  l_data_extract_status     VARCHAR2(1);

  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;

BEGIN

  -- de by org
   Select data_extract_name,
          nvl(extract_by_organization_flag,'N'),
          nvl(data_extract_status,'I')
    into l_data_extract_name, l_extract_by_org, l_data_extract_status
    from psb_data_extracts
  where data_extract_id = p_data_extract_id;

  message_token('DATA_EXTRACT_NAME',l_data_extract_name);
  add_message('PSB', 'PSB_DATA_EXTRACT');

  FND_FILE.Put_Line( FND_FILE.OUTPUT,
		    'Processing the given Data Extract : ' ||l_data_extract_name);

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_concurrency_class        => 'DATAEXTRACT_CREATION',
   p_concurrency_entity_name  => 'DATA_EXTRACT',
   p_concurrency_entity_id    => p_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
  end if;


  PSB_WRHR_EXTRACT_PROCESS.Perform_Data_Extract
  ( p_api_version         =>   1.0,
    p_init_msg_list       =>   FND_API.G_TRUE,
    p_commit              =>   FND_API.G_TRUE,
    p_validation_level    =>   FND_API.G_VALID_LEVEL_FULL,
    p_return_status       =>   l_return_status,
    p_msg_count           =>   l_msg_count,
    p_msg_data            =>   l_msg_data,
    p_data_extract_id     =>   p_data_extract_id
  ) ;

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;
  --

  PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name => 'DATA_EXTRACT',
      p_concurrency_entity_id    => p_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
  end if;

  PSB_MESSAGE_S.Print_Success;
  PSB_MESSAGE_S.Print_Error( p_mode         => FND_FILE.OUTPUT,
			     p_print_header => FND_API.G_FALSE);
  retcode := 0 ;
  --
  COMMIT WORK;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    --

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
    (p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_concurrency_class        => 'DATAEXTRACT_CREATION',
     p_concurrency_entity_name  => 'DATA_EXTRACT',
     p_concurrency_entity_id    => p_data_extract_id);


    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
    (p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_concurrency_class        => 'DATAEXTRACT_CREATION',
     p_concurrency_entity_name  => 'DATA_EXTRACT',
     p_concurrency_entity_id    => p_data_extract_id);

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;
  --
  WHEN OTHERS THEN

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
    (p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_concurrency_class        => 'DATAEXTRACT_CREATION',
     p_concurrency_entity_name  => 'DATA_EXTRACT',
     p_concurrency_entity_id    => p_data_extract_id);

    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    --
    retcode := 2 ;
    COMMIT WORK ;

END Perform_Data_Extract_CP;

/*===========================================================================+
 |                   PROCEDURE Assign_Position_Defaults_CP                   |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Assign Position
-- Defaults'
-- 1308558 Mass Position Assignment Rules Enhancement
-- added the extra parameter p_ruleset_id for passing the
-- id for the default ruleset

-- Bug # 4683895
-- Fixed this concurrent program to work for both Pre and Post MPA Code.
-- There are many subtle changes. So please see the difference with
-- the previous version.

PROCEDURE Assign_Position_Defaults_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_data_extract_id            IN      NUMBER    ,
  p_request_set_flag           IN      VARCHAR2 := 'N',
  p_ruleset_id                 IN      NUMBER := NULL
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Assign_Position_Defaults_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_data_extract_name       VARCHAR2(30);
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  l_default_data_flag       VARCHAR2(1);
  l_default_data_status     VARCHAR2(1);
  l_data_extract_method     VARCHAR2(30);

  -- fix for bug 1787566
  cursor c_extract is
  select nvl(default_data_flag,'I') default_data_flag,
	 nvl(default_data_status,'I') default_data_status,
	 data_extract_method,
         data_extract_name
    from PSB_DATA_EXTRACTS
   where data_extract_id = p_data_extract_id;

BEGIN

  for c_extract_rec in c_extract loop
    l_default_data_flag := c_extract_rec.default_data_flag;
    l_default_data_status := c_extract_rec.default_data_status;
    l_data_extract_method := c_extract_rec.data_extract_method;
    l_data_extract_name := c_extract_rec.data_extract_name;
  end loop;

  message_token('DATA_EXTRACT_NAME',l_data_extract_name);
  add_message('PSB', 'PSB_DATA_EXTRACT');

  if (    ((l_default_data_flag = 'Y') and (p_request_set_flag = 'Y')) -- for Pre MPA DE
       OR (p_request_set_flag = 'N') -- for Pre MPA SRS and for Post MPA Rule Set form button.
     ) then

    PSB_BUDGET_POSITION_PVT.Populate_Budget_Positions
       (p_api_version       =>  1.0,
	p_commit            =>  FND_API.G_TRUE,
	p_return_status     =>  l_return_status,
	p_msg_count         =>  l_msg_count,
	p_msg_data          =>  l_msg_data,
	p_data_extract_id   =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;
  end if;

  if ( (p_request_set_flag = 'Y') and (l_default_data_flag = 'Y') ) then -- for Pre MPA DE

	if (l_default_data_status <> 'C') then

	  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
	  (p_api_version              => 1.0  ,
	   p_return_status            => l_return_status,
	   p_concurrency_class        => 'DATAEXTRACT_CREATION',
	   p_concurrency_entity_name  => 'DATA_EXTRACT',
	   p_concurrency_entity_id    => p_data_extract_id);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     raise FND_API.G_EXC_ERROR;
	  end if;

          -- Bug 4649730 removed the extra in parameter p_ruleset_id
	  PSB_HR_POPULATE_DATA_PVT.Apply_Defaults
	  ( p_api_version         =>   1.0,
	  p_init_msg_list       =>   FND_API.G_FALSE,
	  p_commit              =>   FND_API.G_FALSE,
	  p_validation_level    =>   FND_API.G_VALID_LEVEL_FULL,
	  p_return_status       =>   l_return_status,
	  p_msg_count           =>   l_msg_count,
	  p_msg_data            =>   l_msg_data,
	  p_data_extract_id     =>   p_data_extract_id,
	  p_extract_method      =>   l_data_extract_method
	  );

         if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   raise FND_API.G_EXC_ERROR;
         END IF;

         PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
         (p_api_version              => 1.0  ,
  	  p_return_status            => l_return_status,
	  p_concurrency_class        => 'DATAEXTRACT_CREATION',
	  p_concurrency_entity_name  => 'DATA_EXTRACT',
	  p_concurrency_entity_id    =>  p_data_extract_id);

         if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
         end if;

     end if;

  end if;

  -- for Pre MPA SRS and
  -- for Post MPA Rule Set form button.
  if (p_request_set_flag = 'N') then

    PSB_POSITIONS_PVT.Create_Default_Assignments(
	p_api_version           => 1.0,
	p_init_msg_list         => FND_API.G_TRUE,
	p_commit                => FND_API.G_TRUE,
	p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
	p_return_status         => l_return_status,
	p_msg_count             => l_msg_count,
	p_msg_data              => l_msg_data,
	p_data_extract_id       => p_data_extract_id,
        p_ruleset_id            => p_ruleset_id) ; --1308558

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    END IF;

  end if;
  --

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;
  --
  COMMIT WORK;

EXCEPTION

  WHEN OTHERS THEN

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
       (p_api_version              => 1.0  ,
	p_return_status            => l_return_status,
	p_concurrency_class        => 'DATAEXTRACT_CREATION',
	p_concurrency_entity_name  => 'DATA_EXTRACT',
	p_concurrency_entity_id    =>  p_data_extract_id);

    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error( p_mode         => FND_FILE.LOG,
			       p_print_header => FND_API.G_TRUE);
    --
    retcode := 2 ;
    --
END Assign_Position_Defaults_CP;

/* ----------------------------------------------------------------------- */

-- Add Token and Value to the Message Token array

PROCEDURE message_token(tokname IN VARCHAR2,
			tokval  IN VARCHAR2) AS

BEGIN

  if no_msg_tokens is null then
    no_msg_tokens := 1;
  else
    no_msg_tokens := no_msg_tokens + 1;
  end if;

  msg_tok_names(no_msg_tokens) := tokname;
  msg_tok_val(no_msg_tokens) := tokval;

END message_token;

/* ----------------------------------------------------------------------- */

-- Define a Message Token with a Value and set the Message Name

-- Calls FND_MESSAGE server package to set the Message Stack. This message is
-- retrieved by the calling program.

PROCEDURE add_message(appname IN VARCHAR2,
		      msgname IN VARCHAR2) AS

  i  BINARY_INTEGER;

BEGIN

  if ((appname is not null) and
      (msgname is not null)) then

    FND_MESSAGE.SET_NAME(appname, msgname);

    if no_msg_tokens is not null then

      for i in 1..no_msg_tokens loop
	FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
      end loop;

    end if;

    FND_MSG_PUB.Add;

  end if;

  -- Clear Message Token stack

  no_msg_tokens := 0;

END add_message;

PROCEDURE Pre_Create_Data_Extract( p_api_version       IN  NUMBER,
				   p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
				   p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
				   p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
				   p_return_status     OUT  NOCOPY VARCHAR2,
				   p_msg_count         OUT  NOCOPY NUMBER,
				   p_msg_data          OUT  NOCOPY VARCHAR2,
				   p_data_extract_id   IN  NUMBER)
IS
  Cursor C_Data_Extract is
    SELECT BUSINESS_GROUP_ID,
	   SET_OF_BOOKS_ID,
	   DATA_EXTRACT_NAME,
	   DATA_EXTRACT_METHOD,
	   REQ_DATA_AS_OF_DATE,
	   NVL(POPULATE_INTERFACE_FLAG,'I') POPULATE_INTERFACE_FLAG,
	   NVL(POPULATE_INTERFACE_STATUS,'I') POPULATE_INTERFACE_STATUS,
	   NVL(VALIDATE_DATA_FLAG,'I') VALIDATE_DATA_FLAG,
	   NVL(VALIDATE_DATA_STATUS,'I') VALIDATE_DATA_STATUS,
	   NVL(POPULATE_DATA_FLAG,'I') POPULATE_DATA_FLAG,
	   NVL(POPULATE_DATA_STATUS,'I') POPULATE_DATA_STATUS,
	   NVL(DEFAULT_DATA_FLAG,'I') DEFAULT_DATA_FLAG,
	   NVL(DEFAULT_DATA_STATUS,'I') DEFAULT_DATA_STATUS,
	   NVL(COPY_DEFAULTS_FLAG,'I') COPY_DEFAULTS_FLAG,
	   NVL(COPY_DEFAULTS_STATUS,'I') COPY_DEFAULTS_STATUS,
	   COPY_DEFAULTS_EXTRACT_ID,
	   COPY_SALARY_FLAG,
	   POSITION_ID_FLEX_NUM,
	   -- de by org
	   NVL(EXTRACT_BY_ORGANIZATION_FLAG,'N') EXTRACT_BY_ORG
      FROM PSB_DATA_EXTRACTS
     WHERE data_extract_id = p_data_extract_id;

  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_api_name                CONSTANT VARCHAR2(30) := 'Pre_Create_Data_Extract';
  l_extract_by_org          VARCHAR2(1);

BEGIN

     p_return_status := FND_API.G_RET_STS_SUCCESS;

     DELETE FROM PSB_ERROR_MESSAGES
     WHERE process_id = p_data_extract_id;

     For C_Data_Extract_Rec in C_Data_extract
     Loop
      g_business_group_id        := C_Data_Extract_Rec.business_group_id;
      g_data_extract_id          := p_data_extract_id;
      g_data_extract_name        := C_Data_Extract_Rec.data_extract_name;
      g_data_extract_method      := C_Data_Extract_Rec.data_extract_method;
      g_set_of_books_id          := C_Data_Extract_Rec.set_of_books_id;
      g_req_data_as_of_date      := C_Data_Extract_Rec.req_data_as_of_date;
      g_copy_defaults_flag       := C_Data_Extract_Rec.copy_defaults_flag;
      g_copy_defaults_status     := C_Data_Extract_Rec.copy_defaults_status;
      g_populate_interface_flag := C_Data_Extract_Rec.populate_interface_flag;
      g_populate_interface_status := C_Data_Extract_Rec.populate_interface_status;
      g_validate_data_flag       := C_Data_Extract_Rec.validate_data_flag;
      g_validate_data_status     := C_Data_Extract_Rec.validate_data_status;
      g_populate_data_flag       := C_Data_Extract_Rec.populate_data_flag;
      g_populate_data_status     := C_Data_Extract_Rec.populate_data_status;
      g_default_data_flag        := C_Data_Extract_Rec.default_data_flag;
      g_default_data_status      := C_Data_Extract_Rec.default_data_status;
      g_copy_data_extract_id     := C_Data_Extract_Rec.copy_Defaults_Extract_id;
      g_copy_salary_flag         := C_Data_Extract_Rec.copy_salary_flag;
      g_position_id_flex_num     := C_Data_Extract_Rec.position_id_flex_num;
      -- de by org
      l_extract_by_org           := C_Data_Extract_Rec.extract_by_org;
     End Loop;

     PSB_HR_EXTRACT_DATA_PVT.Init(g_req_data_as_of_date);

     -- de by org
     if l_extract_by_org = 'Y' then
     	   PSB_WRHR_EXTRACT_PROCESS.INSERT_ORGANIZATIONS
   	   (  p_api_version           	=> 1.0,
      	      p_data_extract_id 	=> p_data_extract_id,
    	      p_as_of_date              => g_req_data_as_of_date,
	      p_business_group_id      	=> g_business_group_id,
	      p_return_status          	=> l_return_status,
      	      p_msg_count              	=> l_msg_count,
     	      p_msg_data               	=> l_msg_data);

           if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      raise FND_API.G_EXC_ERROR;
           end if;
     end if;

     message_token('DATA_EXTRACT_NAME',g_data_extract_name);
     add_message('PSB', 'PSB_DATA_EXTRACT');

     FND_FILE.Put_Line( FND_FILE.OUTPUT,
		    'Processing the given Data Extract : ' ||g_data_extract_name);

     if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	raise FND_API.G_EXC_ERROR;
     end if;


    EXCEPTION

    when FND_API.G_EXC_ERROR then

      p_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);


    when FND_API.G_EXC_UNEXPECTED_ERROR then

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);


    when OTHERS then

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

	 FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				  l_api_name);
      end if;

      FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

     --
End Pre_Create_Data_Extract;

Procedure Pre_Create_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_data_extract_id            IN      NUMBER
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Pre_Create_Extract_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status  VARCHAR2(1);
  l_msg_data       VARCHAR2(2000) ;
  l_msg_count      number;

BEGIN
   Pre_Create_Data_Extract
     (p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_TRUE,
      p_commit               => FND_API.G_TRUE,
      p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
      p_return_status        => l_return_status,
      p_msg_count            => l_msg_count,
      p_msg_data             => l_msg_data,
      p_data_extract_id      => p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

  PSB_HR_EXTRACT_DATA_PVT.Final_Process;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			       p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

  COMMIT WORK;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Pre_Create_Extract_CP;

Procedure Copy_Attributes_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_defaults_status       IN      VARCHAR2  ,
  p_copy_data_extract_id       IN      NUMBER,
  p_data_extract_method        IN      VARCHAR2,
  p_data_extract_id            IN      NUMBER
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Copy_Attributes_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

/* Bug No 2579818 Start */
-- for the time being NULLING OUT this procedure since
-- it is called from copy_elements also
    RETURN;
/* Bug No 2579818 End */


    if (p_copy_defaults_flag = 'Y') then

    if ((p_copy_defaults_status is null) or (p_copy_defaults_status <> 'C')) then

     PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    => p_data_extract_id);

     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
     end if;

     PSB_COPY_DATA_EXTRACT_PVT.Copy_Attributes
     (p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_TRUE,
      p_commit               => FND_API.G_TRUE,
      p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
      p_return_status        => l_return_status,
      p_msg_count            => l_msg_count,
      p_msg_data             => l_msg_data,
      p_extract_method       => p_data_extract_method,
      p_src_data_extract_id  => p_copy_data_extract_id,
      p_data_extract_id      => p_data_extract_id
    );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       FND_FILE.put_line(FND_FILE.LOG,'Copy Attribute Values Failed');
    end if;


    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;

    end if;
    end if;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			      p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;

  FND_FILE.put_line(FND_FILE.LOG,'After Call');
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

  COMMIT WORK;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Copy_Attributes_CP;

Procedure Copy_Elements_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_defaults_status       IN      VARCHAR2  ,
  p_copy_data_extract_id       IN      NUMBER,
  p_copy_salary_flag           IN      VARCHAR2,
  p_data_extract_method        IN      VARCHAR2,
  p_data_extract_id            IN      NUMBER
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Copy_Elements_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

    if (p_copy_defaults_flag = 'Y') then
    if ((p_copy_defaults_status is null) or (p_copy_defaults_status <> 'C')) then
     PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    => p_data_extract_id);

     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
     end if;


    PSB_COPY_DATA_EXTRACT_PVT.Copy_Elements
    ( p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_TRUE,
      p_commit               => FND_API.G_TRUE,
      p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
      p_return_status        => l_return_status,
      p_msg_count            => l_msg_count,
      p_msg_data             => l_msg_data,
      p_extract_method       => p_data_extract_method,
      p_src_data_extract_id  => p_copy_data_extract_id,
      p_copy_salary_flag     => p_copy_salary_flag,
      p_data_extract_id      => p_data_extract_id
    );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       FND_FILE.put_line(FND_FILE.LOG,'Copy Elements Failed');
    end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;

    end if;
    end if;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			      p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Copy_Elements_CP;

Procedure Copy_Position_Sets_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_defaults_status       IN      VARCHAR2  ,
  p_copy_data_extract_id       IN      NUMBER,
  p_data_extract_method        IN      VARCHAR2,
  p_data_extract_id            IN      NUMBER
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Copy_Position_Sets_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

    if (p_copy_defaults_flag = 'Y') then
    if ((p_copy_defaults_status is null) or (p_copy_defaults_status <> 'C')) then

     PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    => p_data_extract_id);

     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
     end if;

    PSB_COPY_DATA_EXTRACT_PVT.Copy_Position_Sets
    ( p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_TRUE,
      p_commit               => FND_API.G_TRUE,
      p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
      p_return_status        => l_return_status,
      p_msg_count            => l_msg_count,
      p_msg_data             => l_msg_data,
      p_extract_method       => p_data_extract_method,
      p_src_data_extract_id  => p_copy_data_extract_id,
      p_data_extract_id      => p_data_extract_id
    );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       FND_FILE.put_line(FND_FILE.LOG,'Copy Position Sets Failed');
    end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;

    end if;
    end if;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			       p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Copy_Position_Sets_CP;


Procedure Copy_Default_Rules_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_defaults_status       IN      VARCHAR2  ,
  p_copy_data_extract_id       IN      NUMBER,
  p_data_extract_method        IN      VARCHAR2,
  p_data_extract_id            IN      NUMBER
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Copy_Default_Rules_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

    if (p_copy_defaults_flag = 'Y') then
    if ((p_copy_defaults_status is null) or (p_copy_defaults_status <> 'C')) then

     PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    => p_data_extract_id);

     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
     end if;

    PSB_COPY_DATA_EXTRACT_PVT.Copy_Default_Rules
    ( p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_TRUE,
      p_commit               => FND_API.G_TRUE,
      p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
      p_return_status        => l_return_status,
      p_msg_count            => l_msg_count,
      p_msg_data             => l_msg_data,
      p_extract_method       => p_data_extract_method,
      p_src_data_extract_id  => p_copy_data_extract_id,
      p_data_extract_id      => p_data_extract_id
    );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       FND_FILE.put_line(FND_FILE.LOG,'Copy Default Rules Failed');
    end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;
    end if;
    end if;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			       p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Copy_Default_Rules_CP;

Procedure Populate_Positions_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_req_data_as_of_date        IN      DATE      ,
  p_position_id_flex_num       IN      NUMBER    ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_data_extract_id            IN      NUMBER    ,
  -- de by org
  p_extract_by_org             IN      VARCHAR2 := 'N'
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Populate_Positions_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_effective_date DATE;
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

    if (p_populate_interface_flag = 'Y') then
    if ((p_populate_interface_status is null) or (p_populate_interface_status <> 'C')) then

     l_effective_date := p_req_data_as_of_date;
     PSB_HR_EXTRACT_DATA_PVT.Init(l_effective_date);

     PSB_HR_EXTRACT_DATA_PVT.Get_Position_Information
       ( p_api_version          => 1.0,
	 p_init_msg_list        => FND_API.G_TRUE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
         -- de by org
         p_extract_by_org       => p_extract_by_org,
	 p_extract_method       => p_data_extract_method,
	 p_date                 => p_req_data_as_of_date,
	 p_id_flex_num          => p_position_id_flex_num,
	 p_business_group_id    => p_business_group_id,
	 p_set_of_books_id      => p_set_of_books_id
       );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Get Position Information Failed');
      end if;

      PSB_DE_Client_Extensions_Pub.Run_Client_Extension_Pub
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 x_return_status        => l_return_status,
	 x_msg_count            => l_msg_count,
	 x_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_mode                 => 'P'
      );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'The Client Extension for Position Interface Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

    end if;
    end if;

    if (p_populate_data_flag = 'Y') then
    if ((p_populate_data_status is null) or (p_populate_data_status <> 'C')) then
	PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
       (p_api_version              => 1.0  ,
	p_return_status            => l_return_status,
	p_concurrency_class        => 'DATAEXTRACT_CREATION',
	p_concurrency_entity_name  => 'DATA_EXTRACT',
	p_concurrency_entity_id    => p_data_extract_id);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
       end if;

       PSB_HR_POPULATE_DATA_PVT.Populate_Position_Information
       ( p_api_version       => 1.0,
	 p_init_msg_list     => FND_API.G_FALSE,
	 p_commit            => FND_API.G_TRUE,
	 p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status     => l_return_status,
	 p_msg_count         => l_msg_count,
	 p_msg_data          => l_msg_data,
	 p_data_extract_id   => p_data_extract_id,
         -- de by org
         p_extract_by_org    => p_extract_by_org,
	 p_extract_method    => p_data_extract_method,
	 p_business_group_id => p_business_group_id,
	 p_set_of_books_id   => p_set_of_books_id
      );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Populate Position Failed');

      end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;
    end if;
    end if;

  PSB_HR_EXTRACT_DATA_PVT.Final_Process;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			      p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

  COMMIT WORK ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Populate_Positions_CP;

Procedure Populate_Elements_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_req_data_as_of_date        IN      DATE      ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_data_extract_id            IN      NUMBER
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Populate_Elements_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_effective_date DATE;
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);
  -- de by org
    l_extract_by_org VARCHAR2(1);

  -- Following cursor checks if extract by org is enabled or not.
  Cursor c_data_extract_org is
    Select nvl(extract_by_organization_flag,'N') extract_by_org
    from psb_data_extracts
    where data_extract_id = p_data_extract_id;

BEGIN
    -- de by org


    if (p_populate_interface_flag = 'Y') then
    if ((p_populate_interface_status is null) or (p_populate_interface_status <> 'C')) then
       l_effective_date := p_req_data_as_of_date;
       PSB_HR_EXTRACT_DATA_PVT.Init(l_effective_date);

       PSB_HR_EXTRACT_DATA_PVT.Get_Salary_Information
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_TRUE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_extract_method       => p_data_extract_method,
	 p_business_group_id    => p_business_group_id
       );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Get Salary Information Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

      PSB_DE_Client_Extensions_Pub.Run_Client_Extension_Pub
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 x_return_status        => l_return_status,
	 x_msg_count            => l_msg_count,
	 x_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_mode                 => 'S'
      );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'The Client Extension for Salary Interface Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

    end if;
    end if;

    if (p_populate_data_flag = 'Y') then
    if ((p_populate_data_status is null) or (p_populate_data_status <> 'C')) then

	PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
       (p_api_version              => 1.0  ,
	p_return_status            => l_return_status,
	p_concurrency_class        => 'DATAEXTRACT_CREATION',
	p_concurrency_entity_name  => 'DATA_EXTRACT',
	p_concurrency_entity_id    => p_data_extract_id);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
       end if;

       PSB_HR_POPULATE_DATA_PVT.Populate_Element_Information
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_extract_method       => p_data_extract_method,
	 p_business_group_id    => p_business_group_id,
	 p_set_of_books_id      => p_set_of_books_id
       );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Populate Elements Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;
    end if;
    end if;


  PSB_HR_EXTRACT_DATA_PVT.Final_Process;
  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			      p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

  COMMIT WORK;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
      FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
				  p_data  => l_msg_data );
      IF l_msg_count > 0 THEN

	 l_msg_data := FND_MSG_PUB.Get
		      (p_msg_index    => FND_MSG_PUB.G_NEXT,
		       p_encoded      => FND_API.G_FALSE);

	PSB_MESSAGE_S.INSERT_ERROR
	(p_source_process   => 'DATA_EXTRACT_VALIDATION',
	 p_process_id       =>  p_data_extract_id,
	 p_msg_count        =>  l_msg_count,
	 p_msg_data         =>  l_msg_data);

     END IF;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Populate_Elements_CP;

Procedure Populate_Attributes_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_req_data_as_of_date        IN      DATE      ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_data_extract_id            IN      NUMBER
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Populate_Attributes_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_effective_date DATE;
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);
  -- de by org
  l_extract_by_org VARCHAR2(1);


  -- Following cursor checks if extract by org is enabled or not.
  Cursor c_data_extract_org is
    Select nvl(extract_by_organization_flag,'N') extract_by_org
    from psb_data_extracts
    where data_extract_id = p_data_extract_id;

BEGIN
    -- de by org
    FOR c_data_extract_org_rec in c_data_extract_org LOOP
          l_extract_by_org := c_data_extract_org_rec.extract_by_org;
    END LOOP;

    if (p_populate_interface_flag = 'Y') then
    if ((p_populate_interface_status is null) or (p_populate_interface_status <> 'C')) then
       l_effective_date := p_req_data_as_of_date;
       PSB_HR_EXTRACT_DATA_PVT.Init(l_effective_date);

       PSB_HR_EXTRACT_DATA_PVT.Get_Attributes
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_TRUE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_extract_method       => p_data_extract_method,
	 p_business_group_id    => p_business_group_id
       );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Get Attributes Failed');
      end if;

      PSB_DE_Client_Extensions_Pub.Run_Client_Extension_Pub
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 x_return_status        => l_return_status,
	 x_msg_count            => l_msg_count,
	 x_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_mode                 => 'V'
      );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'The Client Extension for Attribute Values Interface Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

    end if;
    end if;

    if (p_populate_data_flag = 'Y') then
    if ((p_populate_data_status is null) or (p_populate_data_status <> 'C')) then

	PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'DATAEXTRACT_CREATION',
	 p_concurrency_entity_name  => 'DATA_EXTRACT',
	 p_concurrency_entity_id    => p_data_extract_id);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   raise FND_API.G_EXC_ERROR;
       end if;

       PSB_HR_POPULATE_DATA_PVT.Populate_Attribute_Values
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_extract_method       => p_data_extract_method,
	 p_business_group_id    => p_business_group_id
       );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Populate Attribute Values Failed');
      end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;
    end if;
    end if;


  PSB_HR_EXTRACT_DATA_PVT.Final_Process;
  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			      p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;
  COMMIT WORK ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Populate_Attributes_CP;

Procedure Populate_Employees_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_req_data_as_of_date        IN      DATE      ,
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_salary_flag           IN      VARCHAR2  ,
  p_data_extract_id            IN      NUMBER    ,
  -- de by org
  p_extract_by_org             IN      VARCHAR2 := 'N'
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Populate_Employees_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_effective_date DATE;
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

    if (p_populate_interface_flag = 'Y') then
    if ((p_populate_interface_status is null) or (p_populate_interface_status <> 'C')) then
       l_effective_date := p_req_data_as_of_date;
       PSB_HR_EXTRACT_DATA_PVT.Init(l_effective_date);

       PSB_HR_EXTRACT_DATA_PVT.Get_Employee_Information
       ( p_api_version        => 1.0,
	 p_init_msg_list        => FND_API.G_TRUE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
         -- de by org
         p_extract_by_org       => p_extract_by_org,
	 p_extract_method       => p_data_extract_method,
	 p_date                 => p_req_data_as_of_date,
	 p_business_group_id    => p_business_group_id,
	 p_set_of_books_id      => p_set_of_books_id,
	 p_copy_defaults_flag   => p_copy_defaults_flag,
	 p_copy_salary_flag     => p_copy_salary_flag
       );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Get Employee Information Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

      PSB_DE_Client_Extensions_Pub.Run_Client_Extension_Pub
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 x_return_status        => l_return_status,
	 x_msg_count            => l_msg_count,
	 x_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_mode                 => 'E'
      );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'The Client Extension for Employee Interface Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

    end if;
    end if;

    if (p_populate_data_flag = 'Y') then
    if ((p_populate_data_status is null) or (p_populate_data_status <> 'C')) then

	PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'DATAEXTRACT_CREATION',
	 p_concurrency_entity_name  => 'DATA_EXTRACT',
	 p_concurrency_entity_id    => p_data_extract_id);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   raise FND_API.G_EXC_ERROR;
       end if;

       PSB_HR_POPULATE_DATA_PVT.Populate_Employee_Information
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
         -- de by org
         p_extract_by_org       => p_extract_by_org,
	 p_extract_method       => p_data_extract_method,
	 p_business_group_id    => p_business_group_id,
	 p_set_of_books_id      => p_set_of_books_id
       );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Populate Employees Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;
    end if;
    end if;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			      p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;

  PSB_HR_EXTRACT_DATA_PVT.Final_Process;
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;
  COMMIT WORK ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
				p_data  => l_msg_data );
     IF l_msg_count > 0 THEN

	 l_msg_data := FND_MSG_PUB.Get
		    (p_msg_index    => FND_MSG_PUB.G_NEXT,
		     p_encoded      => FND_API.G_FALSE);

	 PSB_MESSAGE_S.INSERT_ERROR
	 (p_source_process   => 'DATA_EXTRACT_VALIDATION',
	  p_process_id       =>  p_data_extract_id,
	  p_msg_count        =>  l_msg_count,
	  p_msg_data         =>  l_msg_data);
     END IF;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Populate_Employees_CP;


Procedure Populate_Cost_Distributions_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_req_data_as_of_date        IN      DATE      ,
  p_data_extract_id            IN      NUMBER    ,
  -- de by org
  p_extract_by_org	       IN      VARCHAR2 := 'N'
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Populate_Cost_Distributions_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_effective_date DATE;
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

    if (p_populate_interface_flag = 'Y') then
    if ((p_populate_interface_status is null) or (p_populate_interface_status <> 'C')) then

       l_effective_date := p_req_data_as_of_date;
       PSB_HR_EXTRACT_DATA_PVT.Init(l_effective_date);

       PSB_HR_EXTRACT_DATA_PVT.Get_Costing_Information
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_TRUE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
         -- de by org
         p_extract_by_org       => p_extract_by_org,
	 p_date                 => p_req_data_as_of_date,
	 p_extract_method       => p_data_extract_method,
	 p_business_group_id    => p_business_group_id,
	 p_set_of_books_id      => p_set_of_books_id
	);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /* Bug 3677529 Start */
        PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
                                     p_print_header =>  FND_API.G_TRUE );
        /* Bug 3677529 End */
        FND_FILE.put_line(FND_FILE.LOG,'Get Cost Distributions Failed');
        FND_MSG_PUB.Initialize;
      end if;

      PSB_DE_Client_Extensions_Pub.Run_Client_Extension_Pub
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 x_return_status        => l_return_status,
	 x_msg_count            => l_msg_count,
	 x_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_mode                 => 'C'
      );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'The Client Extension for Cost Distributions Interface Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

    end if;
    end if;

    if (p_populate_data_flag = 'Y') then
    if ((p_populate_data_status is null) or (p_populate_data_status <> 'C')) then
	PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'DATAEXTRACT_CREATION',
	 p_concurrency_entity_name  => 'DATA_EXTRACT',
	 p_concurrency_entity_id    => p_data_extract_id);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   raise FND_API.G_EXC_ERROR;
       end if;

       PSB_HR_POPULATE_DATA_PVT.Populate_Costing_Information
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
         -- de by org
         p_extract_by_org       => p_extract_by_org,
	 p_extract_method       => p_data_extract_method,
	 p_business_group_id    => p_business_group_id
       );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Populate Costing Failed');
      end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;
    end if;
    end if;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			      p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;

  PSB_HR_EXTRACT_DATA_PVT.Final_Process;
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

  COMMIT WORK;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Populate_Cost_Distributions_CP;

Procedure Populate_Pos_Assignments_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_req_data_as_of_date        IN      DATE      ,
  p_data_extract_id            IN      NUMBER    ,
  -- de by org
  p_extract_by_org             IN      VARCHAR2 := 'N'
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Populate_Pos_Assginments_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_effective_date DATE;
  l_return_status  VARCHAR2(1);
  l_msg_count      number;
  l_msg_data       varchar2(2000);

BEGIN

    if (p_populate_interface_flag = 'Y') then
    if ((p_populate_interface_status is null) or (p_populate_interface_status <> 'C')) then
       l_effective_date := p_req_data_as_of_date;
       PSB_HR_EXTRACT_DATA_PVT.Init(l_effective_date);

       PSB_HR_EXTRACT_DATA_PVT.Get_Employee_Attributes
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_TRUE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
         p_extract_by_org       => p_extract_by_org,
	 p_extract_method       => p_data_extract_method,
	 p_date                 => p_req_data_as_of_date,
	 p_business_group_id    => p_business_group_id,
	 p_set_of_books_id      => p_set_of_books_id
	);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Get Employee Attributes Failed');
      end if;

      PSB_DE_Client_Extensions_Pub.Run_Client_Extension_Pub
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 x_return_status        => l_return_status,
	 x_msg_count            => l_msg_count,
	 x_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
	 p_mode                 => 'A'
      );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'The Client Extension for Employee Attributes Interface Failed');
	 raise FND_API.G_EXC_ERROR;
      end if;

    end if;
    end if;

    if (p_populate_data_flag = 'Y') then
    if ((p_populate_data_status is null) or (p_populate_data_status <> 'C')) then
	PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'DATAEXTRACT_CREATION',
	 p_concurrency_entity_name  => 'DATA_EXTRACT',
	 p_concurrency_entity_id    => p_data_extract_id);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   raise FND_API.G_EXC_ERROR;
       end if;

       PSB_HR_POPULATE_DATA_PVT.Populate_Pos_Assignments
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_data_extract_id      => p_data_extract_id,
         -- de by org
         p_extract_by_org       => p_extract_by_org,
	 p_extract_method       => p_data_extract_method,
	 p_business_group_id    => p_business_group_id,
	 p_set_of_books_id      => p_set_of_books_id
	);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Populate Position Assign Failed');
      end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'DATAEXTRACT_CREATION',
      p_concurrency_entity_name  => 'DATA_EXTRACT',
      p_concurrency_entity_id    =>  p_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;
    end if;
    end if;


  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			      p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;
  PSB_HR_EXTRACT_DATA_PVT.Final_Process;
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

  COMMIT WORK;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Populate_Pos_Assignments_CP;

Procedure Validate_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_validate_data_flag         IN      VARCHAR2  ,
  p_validate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_req_data_as_of_date        IN      DATE  ,
  p_business_group_id          IN      NUMBER    ,
  p_data_extract_id            IN      NUMBER
)

IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Validate_Extract_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_effective_date DATE;
  l_rep_req_id     NUMBER;
  l_req_id         NUMBER;
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

BEGIN

    if p_validate_data_flag = 'Y' then
       l_effective_date := p_req_data_as_of_date;
       PSB_HR_EXTRACT_DATA_PVT.Init(l_effective_date);

       PSB_VALIDATE_DATA_EXTRACT_PVT.Data_Extract_Summary
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_extract_method       => p_data_extract_method,
	 p_data_extract_id      => p_data_extract_id
       );


      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Data Extract Summary failed');
      end if;

      PSB_VALIDATE_DATA_EXTRACT_PVT.Validate_Data_Extract
       ( p_api_version       => 1.0,
	 p_init_msg_list        => FND_API.G_FALSE,
	 p_commit               => FND_API.G_TRUE,
	 p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status        => l_return_status,
	 p_msg_count            => l_msg_count,
	 p_msg_data             => l_msg_data,
	 p_extract_method       => p_data_extract_method,
	 p_data_extract_id      => p_data_extract_id,
	 p_business_group_id    => p_business_group_id
       );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_FILE.put_line(FND_FILE.LOG,'Validate Data Extract failed');
      end if;
    end if;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			      p_data  => l_msg_data );
  IF l_msg_count > 0 THEN

      l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

  END IF;

  COMMIT WORK;

  if (l_msg_count > 0) then

     l_req_id := FND_GLOBAL.CONC_REQUEST_ID;

     l_rep_req_id := Fnd_Request.Submit_Request
		       (application   => 'PSB'                          ,
			program       => 'PSBRPERR'                     ,
			description   => 'Error Messages Listing'       ,
			start_time    =>  NULL                          ,
			sub_request   =>  FALSE                         ,
			argument1     =>  'DATA_EXTRACT_VALIDATION'     ,
			argument2     =>  p_data_extract_id             ,
			argument3     =>  l_req_id
		      );
       --
       if l_rep_req_id = 0 then
       --
	  fnd_message.set_name('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
	  raise FND_API.G_EXC_ERROR ;
       --
       end if;

    end if;
  PSB_HR_EXTRACT_DATA_PVT.Final_Process;
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Validate_Extract_CP;

PROCEDURE Post_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_validate_data_flag         IN      VARCHAR2  ,
  p_data_extract_id            IN      NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Post_Extract_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_sp9_status    VARCHAR2(1);
  l_sp10_status    VARCHAR2(1);
  l_sp11_status    VARCHAR2(1);
  l_sp12_status    VARCHAR2(1);
  l_sp13_status    VARCHAR2(1);
  l_sp14_status    VARCHAR2(1);
  l_sp15_status    VARCHAR2(1);
  l_sp16_status    VARCHAR2(1);
  l_sp17_status    VARCHAR2(1);
  l_sp18_status    VARCHAR2(1);
  lc_return_status VARCHAR2(1);
  lc_status VARCHAR2(1) := 'I';
  li_status VARCHAR2(1) := 'I';
  lv_status VARCHAR2(1) := 'I';
  lp_status VARCHAR2(1) := 'I';
  -- de by org
  l_extract_by_org          VARCHAR2(1);
  l_data_extract_status     VARCHAR2(1) := 'I';
  -- de by org

  l_return_status  VARCHAR2(1);

  Cursor C_Dataextract is
     Select nvl(sp1_status,'I') sp1_status,
	    nvl(sp2_status,'I') sp2_status,
	    nvl(sp3_status,'I') sp3_status,
	    nvl(sp4_status,'I') sp4_status,
	    nvl(sp5_status,'I') sp5_status,
	    nvl(sp6_status,'I') sp6_status,
	    nvl(sp7_status,'I') sp7_status,
	    nvl(sp8_status,'I') sp8_status,
	    nvl(sp9_status,'I') sp9_status,
	    nvl(sp10_status,'I') sp10_status,
	    nvl(sp11_status,'I') sp11_status,
	    nvl(sp12_status,'I') sp12_status,
	    nvl(sp13_status,'I') sp13_status,
	    nvl(sp14_status,'I') sp14_status,
	    nvl(sp15_status,'I') sp15_status,
	    nvl(sp16_status,'I') sp16_status,
	    nvl(sp17_status,'I') sp17_status,
	    nvl(sp18_status,'I') sp18_status
       from psb_reentrant_process_status
      where process_type = 'HR DATA EXTRACT'
	and process_uid  = p_data_extract_id;

   Cursor C_Extract_Status is
     Select nvl(populate_interface_status,'I') populate_interface_status,
            nvl(populate_data_status,'I') populate_data_status,
            nvl(copy_defaults_status,'I') copy_defaults_status,
            nvl(validate_data_status,'I') validate_data_status
     from   psb_data_extracts
     where  data_extract_id = p_data_extract_id;

  -- de by org

  -- Following cursor checks if extract by org is enabled or not.
  Cursor c_data_extract_org is
    Select nvl(extract_by_organization_flag,'N') extract_by_org
    from psb_data_extracts
    where data_extract_id = p_data_extract_id;

BEGIN
    -- de by org
    for c_data_extract_org_rec in c_data_extract_org LOOP
        l_extract_by_org := c_data_extract_org_rec.extract_by_org;
    END LOOP;

 for c_extract_status_rec in C_Extract_Status
 loop
  for c_data_extract_rec in C_Dataextract
  loop
   if (c_extract_status_rec.copy_defaults_status <> 'C') then
   if (p_copy_defaults_flag = 'Y') then
       if (c_data_extract_rec.sp9_status = 'C') and
	  (c_data_extract_rec.sp10_status = 'C') and
	  (c_data_extract_rec.sp11_status = 'C') and
	  (c_data_extract_rec.sp12_status = 'C') then
	   lc_status := 'C';
       else
	   lc_return_status := 'E';
       end if;
   end if;
   else
	   lc_status := 'C';
   end if;

   if (c_extract_status_rec.populate_interface_status <> 'C') then
   if (p_populate_interface_flag = 'Y') then
       if (c_data_extract_rec.sp1_status = 'C') and
	  (c_data_extract_rec.sp2_status = 'C') and
	  (c_data_extract_rec.sp3_status = 'C') and
	  (c_data_extract_rec.sp4_status = 'C') and
	  (c_data_extract_rec.sp5_status = 'C') and
	  (c_data_extract_rec.sp6_status = 'C') then
	   li_status := 'C';
       else
	   lc_return_status := 'E';
       end if;
   end if;
   else
	   li_status := 'C';
   end if;

   if (c_extract_status_rec.validate_data_status <> 'C') then
   if (p_validate_data_flag = 'Y') then
       if (c_data_extract_rec.sp7_status = 'C') and
	  (c_data_extract_rec.sp8_status = 'C') then
	  lv_status := 'C';
       else
	   lc_return_status := 'E';
       end if;
   end if;
   else
	   lv_status := 'C';
   end if;

   if (c_extract_status_rec.populate_data_status <> 'C') then
   if (p_populate_data_flag = 'Y') then
       if (c_data_extract_rec.sp13_status = 'C') and
	  (c_data_extract_rec.sp14_status = 'C') and
	  (c_data_extract_rec.sp15_status = 'C') and
	  (c_data_extract_rec.sp16_status = 'C') and
	  (c_data_extract_rec.sp17_status = 'C') and
	  (c_data_extract_rec.sp18_status = 'C') then
	   lp_status := 'C';
       else
	   lc_return_status := 'E';
       end if;
   end if;
   else
	   lp_status := 'C';
   end if;

   Update psb_data_extracts
      set copy_defaults_status = lc_status,
	  populate_interface_status = li_status,
	  validate_data_status = lv_status,
	  populate_data_status = lp_status
    where data_extract_id = p_data_extract_id;

   End loop;
   End loop;

   --PSB_HR_EXTRACT_DATA_PVT.Final_Process;

    /* Bug 3451357 Start */
    IF (lc_return_status = 'E') then
      l_return_status := FND_API.G_RET_STS_ERROR;

      UPDATE psb_data_extracts
         SET data_extract_status  = 'I'
       WHERE data_extract_id = p_data_extract_id;
    ELSE
      UPDATE psb_data_extracts
         SET data_extract_status  = 'C'
       WHERE data_extract_id = p_data_extract_id;
      /* Start bug #4248348 */
      l_data_extract_status := 'C';
      /* End bug #4248348 */
    END IF;
    /* Bug 3451357 End */

-- Bug 3451357 Start (commented the following code as part of bug fix)
/*
  IF (lc_return_status = 'E') then
       l_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
      Begin
	 Select nvl(sp9_status,'I'),
	        nvl(sp10_status,'I'),
	        nvl(sp11_status,'I'),
	        nvl(sp12_status,'I'),
	        nvl(sp13_status,'I'),
		nvl(sp14_status,'I'),
		nvl(sp15_status,'I'),
		nvl(sp16_status,'I'),
		nvl(sp17_status,'I'),
		nvl(sp18_status,'I')
	   into l_sp9_status,
	        l_sp10_status,
	        l_sp11_status,
	        l_sp12_status,
	        l_sp13_status,
		l_sp14_status,
		l_sp15_status,
		l_sp16_status,
		l_sp17_status,
		l_sp18_status
	   from psb_reentrant_process_status
	  where process_type = 'HR DATA EXTRACT'
	    and process_uid  = p_data_extract_id;

       exception
       when NO_DATA_FOUND then
	null;
       end;

      IF ((l_sp13_status = 'C') and
	  (l_sp14_status = 'C') and
	  (l_sp15_status = 'C') and
	  (l_sp16_status = 'C') and
	  (l_sp17_status = 'C') and
	  (l_sp18_status = 'C') and p_copy_defaults_flag <> 'Y') THEN

      Update PSB_DATA_EXTRACTS
	 set populate_data_status = 'C',
	     data_extract_status  = 'C'
       where data_extract_id = p_data_extract_id;
    -- de by org
      l_data_extract_status := 'C';

--        Bug 3249834 Start

      ELSIF ((l_sp9_status = 'C') and
	 (l_sp10_status = 'C') and
	 (l_sp11_status = 'C') and
	 (l_sp12_status = 'C') and p_copy_defaults_flag = 'Y') THEN

	UPDATE PSB_DATA_EXTRACTS
	   SET copy_defaults_status = 'C',
	       data_extract_status  = 'C'
         WHERE data_extract_id = p_data_extract_id;
      END IF;
--         Bug 3249834 End

  END IF;
*/
-- Bug 3451357 End

    -- de by org

    if l_data_extract_status = 'C' then
      if l_extract_by_org = 'Y' then
        UPDATE PSB_DATA_EXTRACT_ORGS
         set completion_status = 'C',
          completion_time = sysdate,
          select_flag = 'N'
         where data_extract_id = p_data_extract_id
         and select_flag = 'Y' ;
      else
        UPDATE PSB_DATA_EXTRACT_ORGS
         set completion_status = 'C',
          completion_time = sysdate,
          select_flag = 'N'
         where data_extract_id = p_data_extract_id;
      end if;
    end if;

    PSB_MESSAGE_S.Print_Success;
    retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
End Post_Extract_CP;



/* ----------------------------------------------------------------------- */

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for this routine. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 AS

  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */

--This module is used to submit a set of concurrent programs for data extract.

PROCEDURE Submit_Data_Extract
(
  p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY    VARCHAR2,
  p_msg_count                 OUT  NOCOPY    NUMBER,
  p_msg_data                  OUT  NOCOPY    VARCHAR2,
  p_data_extract_id           IN     NUMBER,
  p_data_extract_method       IN     VARCHAR2,
  p_req_data_as_of_date       IN     DATE,
  p_business_group_id         IN     NUMBER,
  p_set_of_books_id           IN     NUMBER,
  p_copy_defaults_flag        IN     VARCHAR2,
  p_copy_defaults_extract_id  IN     NUMBER,
  p_copy_defaults_status      IN     VARCHAR2,
  p_populate_interface_flag   IN     VARCHAR2,
  p_populate_interface_status IN     VARCHAR2,
  p_populate_data_flag        IN     VARCHAR2,
  p_populate_data_status      IN     VARCHAR2,
  p_validate_data_flag        IN     VARCHAR2,
  p_validate_data_status      IN     VARCHAR2,
  p_position_id_flex_num      IN     NUMBER,
  p_request_id                OUT  NOCOPY    NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'Submit_Data_Extract';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_success                      BOOLEAN;
  l_request_id                   NUMBER;
  l_refresh_method               VARCHAR2(30)   := 'REFRESH';
  l_extract_by_org               VARCHAR2(1)    := 'N';

  CURSOR c_data_extract_org IS
    SELECT nvl(extract_by_organization_flag,'N') extract_by_org
    FROM psb_data_extracts
    WHERE data_extract_id = p_data_extract_id;

BEGIN
  p_request_id := 0; -- Bug #4451621

  IF FND_API.to_Boolean ( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize ;
  END IF;

  FOR c_data_extract_org_rec IN c_data_extract_org LOOP
    l_extract_by_org := c_data_extract_org_rec.extract_by_org;
  END LOOP;

  l_success := fnd_submit.set_request_set('PSB', 'PSBRSDER');

  IF NOT(l_success)
  THEN
    FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE', 'Set_Request_Set Failed');
    FND_MSG_PUB.Add;

    RAISE FND_API.G_EXC_ERROR; -- Bug #4451621
  END IF;

  IF (l_success)
  THEN -- SET_REQUEST_SET Successful.

    /* submit program PSBCPPDE which is in stage ST1 */
    l_success := fnd_submit.submit_program
  	( application => 'PSB',
      program     => 'PSBCPPDE',
      stage       => 'ST1',
      argument1   =>  p_data_extract_id,
  		argument2   =>  chr(0)
   	);

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 1 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* submit program PSBCPCDA which is in stage ST2 */
    l_success := fnd_submit.submit_program
    (	 application => 'PSB',
       program     => 'PSBCPCDA',
       stage       => 'ST2',
       argument1   =>  p_copy_defaults_flag,
       argument2   =>  p_copy_defaults_status,
       argument3   =>  p_copy_defaults_extract_id,
       argument4   =>  p_data_extract_method,
       argument5   =>  p_data_extract_id,
       argument6   =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 2 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* submit program PSBCPCDE which is in stage ST2 */
    l_success := fnd_submit.submit_program
    (  application => 'PSB',
       program     => 'PSBCPCDE',
       stage       => 'ST2',
       argument1   =>  p_copy_defaults_flag,
       argument2   =>  p_copy_defaults_status,
       argument3   =>  p_copy_defaults_extract_id,
       argument4   =>  '',
       argument5   =>  p_data_extract_method,
       argument6   =>  p_data_extract_id,
       argument7   =>  chr(0)
    );

    IF ( NOT l_success ) THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '2nd program in Stage 2 failed');
	    FND_MSG_PUB.Add;
    END IF;

    /* submit program PSBCPCPS which is in stage ST3 */
    l_success := fnd_submit.submit_program
		(  application => 'PSB',
       program     => 'PSBCPCPS',
       stage       => 'ST3',
       argument1   =>  p_copy_defaults_flag,
       argument2   =>  p_copy_defaults_status,
       argument3   =>  p_copy_defaults_extract_id,
       argument4   =>  p_data_extract_method,
       argument5   =>  p_data_extract_id,
       argument6   =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 3 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* submit program PSBCPSAL which is in stage ST5 */
    l_success := fnd_submit.submit_program
		(  application => 'PSB',
			 program     => 'PSBCPSAL',
		   stage       => 'ST5',
		 	 argument1   =>  p_populate_interface_flag,
		   argument2   =>  p_populate_interface_status,
       argument3   =>  p_populate_data_flag,
       argument4   =>  p_populate_data_status,
       argument5   =>  l_refresh_method,
       argument6   =>  p_req_data_as_of_date,
       argument7   =>  p_business_group_id,
       argument8   =>  p_set_of_books_id,
       argument9   =>  p_data_extract_id,
       argument10   =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 5 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* submit program PSBCPATT which is in stage ST5 */
    l_success := fnd_submit.submit_program
		(  application => 'PSB',
			 program     => 'PSBCPATT',
			 stage       => 'ST5',
			 argument1   =>  p_populate_interface_flag,
			 argument2   =>  p_populate_interface_status,
       argument3   =>  p_populate_data_flag,
       argument4   =>  p_populate_data_status,
       argument5   =>  l_refresh_method,
       argument6   =>  p_req_data_as_of_date,
       argument7   =>  p_business_group_id,
       argument8   =>  p_set_of_books_id,
       argument9   =>  p_data_extract_id,
       argument10  =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '2ndprogram in Stage 5 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* submit program PSBCPPOS which is in stage ST5 */
    l_success := fnd_submit.submit_program
		(  application => 'PSB',
       program     => 'PSBCPPOS',
       stage       => 'ST5',
       argument1   =>  p_populate_interface_flag,
       argument2   =>  p_populate_interface_status,
       argument3   =>  p_populate_data_flag,
       argument4   =>  p_populate_data_status,
       argument5   =>  p_data_extract_method,
       argument6   =>  p_req_data_as_of_date,
       argument7   =>  p_position_id_flex_num,
       argument8   =>  p_business_group_id,
       argument9   =>  p_set_of_books_id,
       argument10  =>  p_data_extract_id,
       argument11  =>  l_extract_by_org,
       argument12  =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '3rd program in Stage 5 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* submit program PSBCPEMP which is in stage ST6 */
	  l_success := fnd_submit.submit_program
		(  application => 'PSB',
       program     => 'PSBCPEMP',
       stage       => 'ST6',
       argument1   =>  p_populate_interface_flag,
       argument2   =>  p_populate_interface_status,
       argument3   =>  p_populate_data_flag,
       argument4   =>  p_populate_data_status,
       argument5   =>  p_data_extract_method,
       argument6   =>  p_business_group_id,
       argument7   =>  p_set_of_books_id,
       argument8   =>  p_req_data_as_of_date,
       argument9   =>  P_copy_defaults_flag,
       argument10  =>  '',
       argument11  =>  p_data_extract_id,
       argument12  =>  l_extract_by_org,
       argument13  =>  chr(0)
    );


    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 6 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* submit program PSBCPDIS which is in stage ST7 */
    l_success := fnd_submit.submit_program
		(  application => 'PSB',
       program     => 'PSBCPDIS',
       stage       => 'ST7',
       argument1   =>  p_populate_interface_flag,
       argument2   =>  p_populate_interface_status,
       argument3   =>  p_populate_data_flag,
       argument4   =>  p_populate_data_status,
       argument5   =>  p_data_extract_method,
       argument6   =>  p_business_group_id,
       argument7   =>  p_set_of_books_id,
       argument8   =>  p_req_data_as_of_date,
       argument9   =>  p_data_extract_id,
       argument10  =>  l_extract_by_org,
       argument11  =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 7 failed');
      FND_MSG_PUB.Add;
    END IF;


    /* submit program PSBCPEAA which is in stage ST7 */
    l_success := fnd_submit.submit_program
		(  application => 'PSB',
       program     => 'PSBCPEAA',
       stage       => 'ST7',
       argument1   =>  p_populate_interface_flag,
       argument2   =>  p_populate_interface_status,
       argument3   =>  p_populate_data_flag,
       argument4   =>  p_populate_data_status,
       argument5   =>  p_data_extract_method,
       argument6   =>  p_business_group_id,
       argument7   =>  p_set_of_books_id,
       argument8   =>  p_req_data_as_of_date,
       argument9   =>  p_data_extract_id,
       argument10  =>  l_extract_by_org,
       argument11  =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '2nd program in Stage 7 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* Bug 4179764 Start */
    /* submit program PSBCPCDR which is in stage ST4 */
    l_success := fnd_submit.submit_program
		(  application => 'PSB',
			 program     => 'PSBCPCDR',
       stage       => 'ST4',
       argument1   =>  p_copy_defaults_flag,
       argument2   =>  p_copy_defaults_status,
       argument3   =>  p_copy_defaults_extract_id,
       argument4   =>  p_data_extract_method,
       argument5   =>  p_data_extract_id,
       argument6   =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 4 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* Bug 4179764 End */
    /* submit program PSBCPVDE which is in stage ST8 */
    l_success := fnd_submit.submit_program
    (  application => 'PSB',
       program     => 'PSBCPVDE',
       stage       => 'ST8',
       argument1   =>  p_validate_data_flag,
       argument2   =>  p_validate_data_status,
       argument3   =>  p_data_extract_method,
       argument4   =>  p_req_data_as_of_date,
       argument5   =>  p_business_group_id,
       argument6   =>  p_data_extract_id,
       argument7   =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 8 failed');
      FND_MSG_PUB.Add;
    END IF;


    -- Bug 4683895: Always call Assign_Position_Defaults_CP.
    -- This call was earlier commented for MPA (Bug 1308558),
    -- but now it has been un-commented as part of bug 4683895.

    -- submit program PSBCPDFL which is in stage ST9
    l_success := fnd_submit.submit_program
    (  application => 'PSB',
       program     => 'PSBCPDFL',
       stage       => 'ST9',
       argument1   =>  p_data_extract_id,
       argument2   =>  'Y',
       argument3   =>  CHR(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 9 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* submit program PSBCPFPD which is in stage ST10  */
    l_success := fnd_submit.submit_program
    (  application => 'PSB',
       program     => 'PSBCPFPD',
       stage       => 'ST10',
       argument1   =>  p_copy_defaults_flag,
       argument2   =>  p_populate_interface_flag,
       argument3   =>  p_populate_data_flag,
       argument4   =>  p_validate_data_flag,
       argument5   =>  p_data_extract_id,
       argument6   =>  chr(0)
    );

    IF ( NOT l_success )
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', '1st program in Stage 10 failed');
      FND_MSG_PUB.Add;
    END IF;

    /* Submit the Request set */
    l_request_id := fnd_submit.submit_set(NULL, FALSE);
    p_request_id := l_request_id ;

    IF (l_request_id = 0)
    THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE', 'Set Submission Failed');
      FND_MSG_PUB.Add;
    END IF;

  END IF; -- SET_REQUEST_SET Successful.

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    P_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (p_count => P_msg_count,
			       p_data  => P_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (p_count => P_msg_count,
			       p_data  => P_msg_data);

  WHEN OTHERS THEN

    P_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
			       l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count => P_msg_count,
			       p_data  => P_msg_data);

END Submit_Data_Extract;

/* ----------------------------------------------------------------------- */

/* Bug No. 1308558 Start */
PROCEDURE Create_Default_Rule_Set
( x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,
  x_msg_init_list     IN         VARCHAR2 := FND_API.G_TRUE,
  p_commit            IN         VARCHAR2 := FND_API.G_FALSE,
  p_api_version       IN         NUMBER,
  p_data_extract_id   IN         NUMBER,
  p_rule_set_name     IN         VARCHAR2
)
IS
  l_api_version         CONSTANT VARCHAR2(10) := '1.0';
  l_api_name            CONSTANT VARCHAR2(30) := 'create_default_rule_set';
  l_last_update_date    DATE;
  l_last_updated_by     NUMBER(15);
  l_last_update_login   NUMBER(15);
  l_creation_date       DATE;
  l_created_by          NUMBER(15);
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(1000);
  l_new_entity_set_id   PSB_ENTITY_SET.ENTITY_SET_ID%TYPE;
  l_entity_type         CONSTANT
      PSB_ENTITY_SET.ENTITY_TYPE%TYPE    := 'DEFAULT_RULE';
  l_set_of_books_id     PSB_ENTITY_SET.SET_OF_BOOKS_ID%TYPE;
  l_budget_group_id     PSB_ENTITY_SET.BUDGET_GROUP_ID%TYPE;
  l_dummy_rowid         VARCHAR2(100);
  l_name_already_exist  NUMBER;

  CURSOR l_defaults_csr
  IS
  SELECT default_rule_id, priority
    FROM psb_non_fte_rules_v
   WHERE data_extract_id = p_data_extract_id;

BEGIN
  -- check for compatibility
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version,
      l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- check whether we need to initialize message list
  IF FND_API.to_boolean(x_msg_init_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  SAVEPOINT create_default_rule_set;

  l_last_update_date  := sysdate;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  --verify if the rule set name provided by the user already exists
  SELECT COUNT(1) INTO l_name_already_exist
    FROM psb_entity_set
   WHERE name = p_rule_set_name;

  --in case the name is already in use, abort the process and report the
  --user through the logs generated
  IF l_name_already_exist > 0 THEN
    FND_MESSAGE.SET_NAME('PSB', 'PSB_DUPLICATE_NAME');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --get a new PSB_ENTITY_SET_ID for the new rule set
  FOR l_entity_set_rec IN (SELECT psb_entity_set_s.NEXTVAL entity_set_id
                             FROM dual)
  LOOP
    l_new_entity_set_id := l_entity_set_rec.entity_set_id;
  END LOOP;

  --Fetch set_of_books_id and budget_group_id
  FOR l_data_extracts_rec IN (SELECT set_of_books_id, business_group_id
                                FROM psb_data_extracts
                               WHERE data_extract_id = p_data_extract_id)
  LOOP
    l_set_of_books_id := l_data_extracts_rec.set_of_books_id;
    l_budget_group_id := l_data_extracts_rec.business_group_id;
  END LOOP;

  PSB_ENTITY_SET_PVT.Insert_Row
  (  p_api_version              => 1.0,
     p_init_msg_list            => FND_API.G_FALSE,
     p_commit                   => FND_API.G_FALSE,
     p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     P_ROWID                    => l_dummy_rowid,
     P_ENTITY_SET_ID            => l_new_entity_set_id,
     P_ENTITY_TYPE              => l_entity_type,
     P_NAME                     => p_rule_set_name,
     P_DESCRIPTION              => NULL,
     P_BUDGET_GROUP_ID          => l_budget_group_id,
     P_SET_OF_BOOKS_ID          => l_set_of_books_id,
     P_DATA_EXTRACT_ID          => p_data_extract_id,
     P_CONSTRAINT_THRESHOLD     => NULL,
     P_ENABLE_FLAG              => NULL,
     P_ATTRIBUTE1               => NULL,
     P_ATTRIBUTE2               => NULL,
     P_ATTRIBUTE3               => NULL,
     P_ATTRIBUTE4               => NULL,
     P_ATTRIBUTE5               => NULL,
     P_ATTRIBUTE6               => NULL,
     P_ATTRIBUTE7               => NULL,
     P_ATTRIBUTE8               => NULL,
     P_ATTRIBUTE9               => NULL,
     P_ATTRIBUTE10              => NULL,
     P_CONTEXT                  => NULL,
     p_Last_Update_Date         => l_last_update_date,
     p_Last_Updated_By          => l_last_updated_by,
     p_Last_Update_Login        => l_last_update_login,
     p_Created_By               => l_created_by,
     p_Creation_Date            => l_creation_date
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR l_defaults_rec in l_defaults_csr
  LOOP
    PSB_ENTITY_ASSIGNMENT_PVT.Insert_Row
    ( p_api_version            => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_commit                 => FND_API.G_FALSE,
      p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
      p_return_status          => l_return_status,
      p_msg_count              => l_msg_count,
      p_msg_data               => l_msg_data,
      P_ROWID                  => l_dummy_rowid,
      P_ENTITY_SET_ID          => l_new_entity_set_id,
      P_ENTITY_ID              => l_defaults_rec.default_rule_id,
      P_PRIORITY               => l_defaults_rec.priority,
      P_SEVERITY_LEVEL         => NULL,
      P_EFFECTIVE_START_DATE   => SYSDATE,
      P_EFFECTIVE_END_DATE     => NULL,
      p_Last_Update_Date       => l_last_update_date,
      p_Last_Updated_By        => l_last_updated_by,
      p_Last_Update_Login      => l_last_update_login,
      p_Created_By             => l_created_by,
      p_Creation_Date          => l_creation_date
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;

  IF FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_default_rule_set;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count,
                  p_data => x_msg_data
                );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_default_rule_set;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count,
                  p_data => x_msg_data
                );

  WHEN OTHERS THEN
    ROLLBACK TO create_default_rule_set;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg
                  ( G_PKG_NAME,
                    l_api_name
                  );
    END IF;

    FND_MSG_PUB.Count_And_Get
                ( p_count => x_msg_count,
                  p_data => x_msg_data
                );
END Create_Default_Rule_Set;
/* Bug No. 1308558 End */

/* ----------------------------------------------------------------------- */

/* Bug No. 1308558 Start */
PROCEDURE Create_Default_Rule_Set_CP
( errbuf                OUT  NOCOPY  VARCHAR2,
  retcode               OUT  NOCOPY  VARCHAR2,
  p_data_extract_id     IN           NUMBER,
  p_rule_set_name       IN           VARCHAR2
)
IS
  l_api_version     CONSTANT VARCHAR2(10) := '1.0';
  l_api_name        CONSTANT VARCHAR2(30) := 'create_default_rule_set_CP';
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);

BEGIN
  Create_Default_Rule_Set
  ( x_return_status     => l_return_status,
    x_msg_count         => l_msg_count,
    x_msg_data          => l_msg_data,
    x_msg_init_list     => FND_API.G_TRUE,
    p_commit            => FND_API.G_TRUE,
    p_api_version       => 1.0,
    p_data_extract_id   => p_data_extract_id,
    p_rule_set_name     => p_rule_set_name
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     PSB_MESSAGE_S.Print_Error
                   ( p_mode => FND_FILE.LOG,
                     p_print_header => FND_API.G_TRUE
                   );
     retcode := 2;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     PSB_MESSAGE_S.Print_Error
                   ( p_mode => FND_FILE.LOG,
                     p_print_header => FND_API.G_TRUE
                   );
     retcode := 2;

   WHEN OTHERS THEN
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     end if;

     PSB_MESSAGE_S.Print_Error
                   ( p_mode => FND_FILE.LOG,
                     p_print_header => FND_API.G_TRUE
                   );
     retcode := 2;
END;
/* Bug No. 1308558 End */

/* ----------------------------------------------------------------------- */


END PSB_WRHR_EXTRACT_PROCESS;

/
