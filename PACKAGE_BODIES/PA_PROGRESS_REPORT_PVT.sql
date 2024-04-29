--------------------------------------------------------
--  DDL for Package Body PA_PROGRESS_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROGRESS_REPORT_PVT" as
/* $Header: PAPRRPVB.pls 120.4.12010000.2 2009/06/17 07:21:15 jngeorge ship $ */

PROCEDURE Create_REPORT_REGION
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_version_id                  IN NUMBER,
 P_REGION_SOURCE_TYPE in VARCHAR2 default 'STD',
 P_REGION_CODE in VARCHAR2,
 P_RECORD_SEQUENCE in NUMBER,
 P_ATTRIBUTE1 in VARCHAR2,
 P_ATTRIBUTE2 in VARCHAR2,
 P_ATTRIBUTE3 in VARCHAR2,
 P_ATTRIBUTE4 in VARCHAR2,
 P_ATTRIBUTE5 in VARCHAR2,
 P_ATTRIBUTE6 in VARCHAR2,
 P_ATTRIBUTE7 in VARCHAR2,
 P_ATTRIBUTE8 in VARCHAR2,
 P_ATTRIBUTE9 in VARCHAR2,
 P_ATTRIBUTE10 in VARCHAR2,
 P_ATTRIBUTE11 in VARCHAR2,
 P_ATTRIBUTE12 in VARCHAR2,
 P_ATTRIBUTE13 in VARCHAR2,
 P_ATTRIBUTE14 in VARCHAR2,
 P_ATTRIBUTE15 in VARCHAR2,
 P_ATTRIBUTE16 in VARCHAR2,
 P_ATTRIBUTE17 in VARCHAR2,
 P_ATTRIBUTE18 in VARCHAR2,
 P_ATTRIBUTE19 in VARCHAR2,
 P_ATTRIBUTE20 in VARCHAR2,
  P_UDS_ATTRIBUTE_CATEGORY in VARCHAR2 default null,
  P_UDS_ATTRIBUTE1 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE2 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE3 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE4 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE5 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE6 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE7 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE8 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE9 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE10 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE11 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE12 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE13 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE14 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE15 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE16 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE17 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE18 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE19 in VARCHAR2 default null,
  P_UDS_ATTRIBUTE20 in VARCHAR2 default null,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS

      l_rowid ROWID;
      l_record_sequence NUMBER;
      l_page_id NUMBER;
      l_status VARCHAR2 (30);

      CURSOR get_report_status IS
	 SELECT report_status_code
	   FROM pa_progress_report_vers
	   WHERE version_id = p_version_id;

       CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

l_type VARCHAR2(80); /* bug 2447763 */


BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Create_Report_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT Create_Report_Region;
  END IF;


  -- if the report in WORKING status, we continue
  -- otherwise, we quit
  OPEN get_report_status;
  FETCH get_report_status INTO l_status;

  CLOSE get_report_status;

  IF l_status <> 'PROGRESS_REPORT_WORKING' THEN

     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PR_STATUS_NOT_WORKING');
     x_return_status := FND_API.G_RET_STS_ERROR;

   ELSE

     IF (p_region_code IS NULL) then
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_REGION_CODE_INV');
	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

  END IF;

  IF  x_return_status <> FND_API.g_ret_sts_success THEN
     PA_DEBUG.Reset_Err_Stack;
     RETURN;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check if exists in pa_object_page_versions

  IF (p_version_id IS NULL) THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			   ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			   , p_token1 => 'TEMPLATE_TYPE'
			   , p_value1 => l_type);
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF (x_return_status = FND_API.g_ret_sts_success AND  p_validate_only <>FND_API.g_true) THEN
     -- we insert to the pa_object_page_values

    -- IF p_record_sequence IS NULL THEN
--	SELECT pa_object_page_versions_s.NEXTVAL
--	  INTO   l_record_sequence
--	  FROM   dual;
 --    ELSE
--	l_record_sequence := p_record_sequence;
 --    END IF;

     pa_progress_report_pkg.INSERT_progress_report_VAL_ROW (
			   P_VERSION_ID,
                           P_REGION_SOURCE_TYPE,
			   P_REGION_CODE,
			   P_RECORD_SEQUENCE,
			   P_ATTRIBUTE1 ,
			   P_ATTRIBUTE2 ,
			   P_ATTRIBUTE3 ,
			   P_ATTRIBUTE4 ,
			   P_ATTRIBUTE5 ,
			   P_ATTRIBUTE6 ,
			   P_ATTRIBUTE7 ,
			   P_ATTRIBUTE8 ,
			   P_ATTRIBUTE9 ,
			   P_ATTRIBUTE10 ,
			   P_ATTRIBUTE11 ,
			   P_ATTRIBUTE12 ,
			   P_ATTRIBUTE13 ,
			   P_ATTRIBUTE14 ,
			   P_ATTRIBUTE15 ,
			   P_ATTRIBUTE16 ,
			   P_ATTRIBUTE17 ,
			   P_ATTRIBUTE18 ,
			   P_ATTRIBUTE19 ,
			   P_ATTRIBUTE20 ,
  		 	   P_UDS_ATTRIBUTE_CATEGORY ,
  			   P_UDS_ATTRIBUTE1 ,
  			   P_UDS_ATTRIBUTE2 ,
  			   P_UDS_ATTRIBUTE3 ,
  			   P_UDS_ATTRIBUTE4 ,
 			    P_UDS_ATTRIBUTE5 ,
  			   P_UDS_ATTRIBUTE6 ,
  			   P_UDS_ATTRIBUTE7 ,
  			   P_UDS_ATTRIBUTE8 ,
  			   P_UDS_ATTRIBUTE9 ,
  			   P_UDS_ATTRIBUTE10 ,
  			   P_UDS_ATTRIBUTE11 ,
  			   P_UDS_ATTRIBUTE12 ,
  			   P_UDS_ATTRIBUTE13 ,
  			   P_UDS_ATTRIBUTE14 ,
  			   P_UDS_ATTRIBUTE15 ,
  			   P_UDS_ATTRIBUTE16 ,
  			   P_UDS_ATTRIBUTE17 ,
  			   P_UDS_ATTRIBUTE18 ,
  			   P_UDS_ATTRIBUTE19 ,
  			   P_UDS_ATTRIBUTE20 ,
			   x_return_status,
			   x_msg_count,
			   x_msg_data
			   ) ;


  END IF;

   -- update percent complete table

   IF (x_return_status = FND_API.g_ret_sts_success) then
      --IF p_region_code = 'PA_PROGRESS_PROJ_DATES_TOP_IN' THEN
      -- todo demo
	IF p_region_code = 'PA_PROGRESS_PROJECT_DATES' then
	 --update_project_perccomplete(p_version_id,
		--		      x_return_status,
			--	      x_msg_count,
	   --      x_msg_data);
	   NULL;

      END IF;
   END IF;

  -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO Create_Progress_Report;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_Progress_Report_PVT.Create_Progress_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END create_report_region;



PROCEDURE Update_REPORT_REGION
(

 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 P_VERSION_ID in NUMBER,
 P_REGION_SOURCE_TYPE in VARCHAR2,
 P_REGION_CODE in VARCHAR2,
 P_RECORD_SEQUENCE in NUMBER,
 P_RECORD_VERSION_NUMBER in NUMBER,
 P_ATTRIBUTE1 in VARCHAR2,
 P_ATTRIBUTE2 in VARCHAR2,
 P_ATTRIBUTE3 in VARCHAR2,
 P_ATTRIBUTE4 in VARCHAR2,
 P_ATTRIBUTE5 in VARCHAR2,
 P_ATTRIBUTE6 in VARCHAR2,
 P_ATTRIBUTE7 in VARCHAR2,
 P_ATTRIBUTE8 in VARCHAR2,
 P_ATTRIBUTE9 in VARCHAR2,
 P_ATTRIBUTE10 in VARCHAR2,
 P_ATTRIBUTE11 in VARCHAR2,
 P_ATTRIBUTE12 in VARCHAR2,
 P_ATTRIBUTE13 in VARCHAR2,
 P_ATTRIBUTE14 in VARCHAR2,
 P_ATTRIBUTE15 in VARCHAR2,
 P_ATTRIBUTE16 in VARCHAR2,
 P_ATTRIBUTE17 in VARCHAR2,
 P_ATTRIBUTE18 in VARCHAR2,
 P_ATTRIBUTE19 in VARCHAR2,
 P_ATTRIBUTE20 in VARCHAR2,
  P_UDS_ATTRIBUTE_CATEGORY in VARCHAR2 ,
  P_UDS_ATTRIBUTE1 in VARCHAR2 ,
  P_UDS_ATTRIBUTE2 in VARCHAR2 ,
  P_UDS_ATTRIBUTE3 in VARCHAR2 ,
  P_UDS_ATTRIBUTE4 in VARCHAR2 ,
  P_UDS_ATTRIBUTE5 in VARCHAR2 ,
  P_UDS_ATTRIBUTE6 in VARCHAR2 ,
  P_UDS_ATTRIBUTE7 in VARCHAR2 ,
  P_UDS_ATTRIBUTE8 in VARCHAR2 ,
  P_UDS_ATTRIBUTE9 in VARCHAR2 ,
  P_UDS_ATTRIBUTE10 in VARCHAR2 ,
  P_UDS_ATTRIBUTE11 in VARCHAR2 ,
  P_UDS_ATTRIBUTE12 in VARCHAR2 ,
  P_UDS_ATTRIBUTE13 in VARCHAR2 ,
  P_UDS_ATTRIBUTE14 in VARCHAR2 ,
  P_UDS_ATTRIBUTE15 in VARCHAR2 ,
  P_UDS_ATTRIBUTE16 in VARCHAR2 ,
  P_UDS_ATTRIBUTE17 in VARCHAR2 ,
  P_UDS_ATTRIBUTE18 in VARCHAR2 ,
  P_UDS_ATTRIBUTE19 in VARCHAR2 ,
  P_UDS_ATTRIBUTE20 in VARCHAR2 ,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS


   l_rowid ROWID;

CURSOR check_record_version IS
SELECT ROWID
FROM   PA_Progress_report_VALS
WHERE  version_id = p_version_id
  AND region_source_type = p_region_source_type
  AND region_code = p_region_code
  AND record_sequence = p_record_sequence
  AND    record_version_number = p_record_version_number;

 l_status VARCHAR2 (30);

      CURSOR get_report_status IS
	 SELECT report_status_code
	   FROM pa_progress_report_vers
	   WHERE version_id = p_version_id;

      CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

l_type VARCHAR2(80); /* bug 2447763 */

BEGIN

 -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Update_Report_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT Update_Report_Region;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  --Check mandatory region source type
IF (p_region_source_type IS NULL OR
    p_region_source_type NOT IN ('STD','DFF', 'STD_CUST')) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_PR_REGION_SRC_INV'
                          , p_token1 => 'TEMPLATE_TYPE'
                          , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- check mandatory region_code
  IF (p_region_code IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_REGION_CODE_INV');
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

    -- check mandatory record_sequence
  IF (p_record_sequence IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_RECORD_SEQUENCE_INV'
			   , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;

  END IF;


  -- if the report in WORKING status, we continue
  -- otherwise, we quit
  OPEN get_report_status;
  FETCH get_report_status INTO l_status;

  CLOSE get_report_status;

  IF l_status <> 'PROGRESS_REPORT_WORKING' THEN

     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PR_STATUS_NOT_WORKING');
     x_return_status := FND_API.G_RET_STS_ERROR;
     RETURN;

  END IF;


   OPEN check_record_version;

   FETCH check_record_version INTO l_rowid;

   IF check_record_version%NOTFOUND THEN

	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PR_RECORD_CHANGED');

	x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

   CLOSE check_record_version;


   IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) THEN

      --debug_msg ('In UPdate report region **********************');


      --debug_msg ('update report P_version_id' || p_version_id);

      --debug_msg ('update report P_version_id' || p_region_code);
      --debug_msg ('update report P_version_id' || p_record_sequence);

      --debug_msg ('P_ATTRIBUTE7' || P_ATTRIBUTE1);
      --debug_msg ('P_ATTRIBUTE7' || P_ATTRIBUTE2);
      --debug_msg ('P_ATTRIBUTE7' || P_ATTRIBUTE3);
      --debug_msg ('P_ATTRIBUTE7' || P_ATTRIBUTE4);
      --debug_msg ('P_ATTRIBUTE7' || P_ATTRIBUTE5);
      --debug_msg ('P_ATTRIBUTE7' || P_ATTRIBUTE6);
      --debug_msg ('P_ATTRIBUTE7' || P_ATTRIBUTE7);
      --debug_msg ('P_ATTRIBUTE7' || P_ATTRIBUTE8);
      --debug_msg ('P_ATTRIBUTE7' || P_ATTRIBUTE9);

     -- we can update it now
     PA_PROGRESS_REPORT_PKG.update_progress_report_val_row
       (
	P_VERSION_ID ,
        P_REGION_SOURCE_TYPE,
	P_REGION_CODE ,
	P_RECORD_SEQUENCE ,
	P_RECORD_VERSION_NUMBER ,
	P_ATTRIBUTE1 ,
	P_ATTRIBUTE2 ,
	P_ATTRIBUTE3 ,
	P_ATTRIBUTE4 ,
	P_ATTRIBUTE5 ,
	P_ATTRIBUTE6 ,
	P_ATTRIBUTE7 ,
	P_ATTRIBUTE8 ,
	P_ATTRIBUTE9 ,
	P_ATTRIBUTE10 ,
	P_ATTRIBUTE11 ,
	P_ATTRIBUTE12 ,
	P_ATTRIBUTE13 ,
	P_ATTRIBUTE14 ,
	P_ATTRIBUTE15 ,
	P_ATTRIBUTE16 ,
	P_ATTRIBUTE17 ,
	P_ATTRIBUTE18 ,
	P_ATTRIBUTE19 ,
	P_ATTRIBUTE20 ,
	P_UDS_ATTRIBUTE_CATEGORY ,
        P_UDS_ATTRIBUTE1 ,
        P_UDS_ATTRIBUTE2 ,
        P_UDS_ATTRIBUTE3 ,
        P_UDS_ATTRIBUTE4 ,
        P_UDS_ATTRIBUTE5 ,
        P_UDS_ATTRIBUTE6 ,
        P_UDS_ATTRIBUTE7 ,
        P_UDS_ATTRIBUTE8 ,
        P_UDS_ATTRIBUTE9 ,
        P_UDS_ATTRIBUTE10 ,
        P_UDS_ATTRIBUTE11 ,
        P_UDS_ATTRIBUTE12 ,
        P_UDS_ATTRIBUTE13 ,
        P_UDS_ATTRIBUTE14 ,
        P_UDS_ATTRIBUTE15 ,
        P_UDS_ATTRIBUTE16 ,
        P_UDS_ATTRIBUTE17 ,
        P_UDS_ATTRIBUTE18 ,
        P_UDS_ATTRIBUTE19 ,
        P_UDS_ATTRIBUTE20 ,
	x_return_status,
	x_msg_count,
	x_msg_data
	);


  END IF;

  -- update percent complete table

  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) THEN

     --debug_msg ('update percent complete ');
     --debug_msg ('region_code ' || p_region_code);
     --IF p_region_code = 'PA_PROGRESS_PROJ_DATES_TOP_IN' then

     --todo demo
     IF p_region_code = 'PA_PROGRESS_PROJECT_DATES' then
	--update_project_perccomplete(p_version_id,
		--		     x_return_status,
			--	     x_msg_count,
	--     x_msg_data);
	NULL;

     END IF;
  END IF;

  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) THEN
     UPDATE pa_progress_report_vers
       SET summary_version_number = summary_version_number +1
     WHERE version_id = p_version_id;

  END IF;


 -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND x_return_status = FND_API.g_ret_sts_success) THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  COMMIT;

  --debug_msg ('update percent complete: end ');

EXCEPTION
   WHEN OTHERS THEN

      --debug_msg ('update percent complete: exception ');
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO update_report_region;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.Update_Progress_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END update_report_region;

PROCEDURE Delete_Report_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_version_id                  IN     number,
 P_REGION_SOURCE_TYPE          in VARCHAR2,
 P_REGION_CODE                 in VARCHAR2,
 P_RECORD_SEQUENCE             in NUMBER,
 p_record_version_number       IN NUMBER ,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

    l_rowid ROWID;

    CURSOR check_record_version IS
       SELECT ROWID
	 FROM   PA_progress_report_VALS
	 WHERE  version_id = p_version_id
	 AND region_source_type = p_region_source_type
	 AND region_code = p_region_code
	 AND record_sequence = p_record_sequence
	 AND record_version_number = p_record_version_number;


    l_status VARCHAR2 (30);

    CURSOR get_report_status IS
	 SELECT report_status_code
	   FROM pa_progress_report_vers
	   WHERE version_id = p_version_id;

     CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

      l_type VARCHAR2(80); /* bug 2447763 */


BEGIN

    -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Update_Report_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT Delete_Progress_Report;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

    --Check mandatory region source type
  IF (p_region_source_type IS NULL OR
    p_region_source_type NOT IN ('STD','DFF', 'STD_CUST')) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_PR_REGION_SRC_INV'
                          , p_token1 => 'TEMPLATE_TYPE'
                          , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- check mandatory region_code
  IF (p_region_code IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_REGION_CODE_INV');
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- if the report in WORKING status, we continue
  -- otherwise, we quit
  OPEN get_report_status;
  FETCH get_report_status INTO l_status;

  CLOSE get_report_status;

  IF l_status <> 'PROGRESS_REPORT_WORKING' THEN

     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PR_STATUS_NOT_WORKING');
     x_return_status := FND_API.G_RET_STS_ERROR;
     RETURN;

  END IF;


    -- check mandatory record_sequence
/*  IF (p_record_sequence IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_RECORD_SEQUENCE_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
     */

  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) THEN
     IF (p_record_sequence IS null) THEN
	pa_progress_report_pkg.delete_progress_report_region(
						     P_VERSION_ID,
						     P_REGION_SOURCE_TYPE,
						     P_REGION_CODE,
						     x_return_status,
						     x_msg_count,
						     x_msg_data
						     );

      else
	pa_progress_report_pkg.DELETE_progress_report_VAL_ROW (
						       P_VERSION_ID,
						       P_REGION_SOURCE_TYPE,
						       P_REGION_CODE,
						       P_RECORD_SEQUENCE,
						       P_RECORD_VERSION_NUMBER,
						       x_return_status,
						       x_msg_count,
						       x_msg_data);

     END IF;

  END IF;


  -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


 EXCEPTION
   WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO Delete_Progress_Report;
         END IF;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROGRESS_Report_PVT.Delete_Progress_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs

END delete_report_region;


PROCEDURE cancel_report
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_version_id                  IN     NUMBER :=NULL,
 p_record_version_number       IN     NUMBER := NULL,
 p_cancel_comments             IN     VARCHAR2 := NULL,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_rowid ROWID;

   CURSOR check_status_published IS
      SELECT  ROWID
	FROM pa_progress_report_vers
	WHERE version_id = p_version_id
	AND report_status_code = 'PROGRESS_REPORT_PUBLISHED';

    CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

    l_type VARCHAR2(80); /* bug 2447763 */

    l_object_id number;
    l_object_type  VARCHAR2(30);
    l_version_id   number;
    l_current_flag  varchar2(1);
    l_record_version_number  number;
    l_summary_version_number number;
    l_report_Type_id         number;

    CURSOR update_last_published_rep is
    SELECT version_id,record_version_number,summary_version_number
       FROM pa_progress_report_vers p1
       WHERE
       p1.object_id = l_object_id
       AND p1.object_type = l_object_type
       and p1.report_type_id = l_report_type_id
       AND p1.report_status_code = 'PROGRESS_REPORT_PUBLISHED'
       AND p1.version_id =
       (
        SELECT MAX(version_id)
        FROM pa_progress_report_vers
        WHERE
        object_id = l_object_id
        AND object_type = l_object_type
        and report_type_id = l_report_type_id
        AND report_status_code = 'PROGRESS_REPORT_PUBLISHED'
        and current_flag <> 'Y'
        AND report_end_Date =
       (SELECT max(report_end_date)
        FROM pa_progress_report_vers
        WHERE
        object_id = l_object_id
        AND object_type = l_object_type
        and report_Type_id = l_report_type_id
        AND report_status_code = 'PROGRESS_REPORT_PUBLISHED'
        and current_flag <> 'Y'));

    cursor get_current_report_details is
    select object_id, object_Type, current_flag, report_Type_id
      from pa_progress_report_vers
     where version_id = p_version_id;

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Cancel_Report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT cancel_report;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- can only obsolete the published report
  IF x_return_status = FND_API.g_ret_sts_success THEN

     OPEN check_status_published;
     FETCH check_status_published INTO l_rowid;

     IF check_status_published%NOTFOUND THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_OBSOLETE_REPORT_INV');

	x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE
	CLOSE check_status_published;
     END IF;

   END IF;

   -- change the status of report to obsoleted.
   IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

/*	pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
	  (
	   p_version_id,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   'PROGRESS_REPORT_CANCELED',

	   NULL  ,
	   NULL ,
	   NULL,
	   NULL ,
	   NULL ,
	   NULL,
	   NULL,
	   p_cancel_comments,
	   sysdate,

	   p_record_version_number,
	   NULL,
	   x_return_status        ,
	   x_msg_count            ,
	   x_msg_data

	    );*/
     open get_current_report_details;
     fetch get_current_report_details into l_object_id, l_object_type, l_current_flag, l_report_type_id;
     close get_current_report_details;

	change_report_status
	    (
	     p_version_id => p_version_id         ,
	     p_report_status => 'PROGRESS_REPORT_CANCELED',
	     p_record_version_number => p_record_version_number,
	    -- p_summary_version_number => NULL,
	     p_cancel_comment=> p_cancel_comments,
	     p_cancel_date =>Sysdate,

	     x_return_status     => x_return_status,
	     x_msg_count         => x_msg_count,
	     x_msg_data          => x_msg_data
	     ) ;

   END IF;

   if ( x_return_status = FND_API.g_ret_sts_success  )THEN

     if (l_current_flag  = 'Y') then
       open update_last_published_rep;
       fetch update_last_published_rep into l_version_id,l_RECORD_VERSION_NUMBER,l_summary_version_number;
       IF update_last_published_rep%found then

           pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
          (
           l_version_id,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           'Y',
           null,
           null,
           null,
           l_RECORD_VERSION_NUMBER   ,
           l_summary_version_number  ,
           l_report_type_id,
           x_return_status           ,
           x_msg_count               ,
           x_msg_data
           );
       END IF;
       close update_last_published_rep;

     end if;

   end if;



     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO cancel_report;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.Cancel_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs


END cancel_report;

PROCEDURE approve_report (
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

  p_version_id IN NUMBER := null,
  p_record_version_number       IN     NUMBER := NULL,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			  )
  IS

   l_rowid rowid;

   CURSOR check_status_submitted IS
      SELECT  ROWID
	FROM pa_progress_report_vers
	WHERE version_id = p_version_id
	AND report_status_code = 'PROGRESS_REPORT_SUBMITTED';

   CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

      l_type VARCHAR2(80); /* bug 2447763 */


BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Approve_Report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT approve_report;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- can only approve the submitted report
  IF x_return_status = FND_API.g_ret_sts_success THEN

     OPEN check_status_submitted;
     FETCH check_status_submitted INTO l_rowid;

     IF check_status_submitted%NOTFOUND THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PR_RECORD_CHANGED');

	x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE
	CLOSE check_status_submitted;
     END IF;

   END IF;

   IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

      /*
	pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
	  (
	   p_version_id,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   'PROGRESS_REPORT_APPROVED',

	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,

	   p_record_version_number,
	   null,
	   x_return_status        ,
	   x_msg_count            ,
	   x_msg_data

	  );*/
	  change_report_status
	    (
	     p_version_id => p_version_id         ,
	     p_report_status => 'PROGRESS_REPORT_APPROVED',
	     p_record_version_number => p_record_version_number,
	    -- p_summary_version_number => NULL,
	     --p_cancel_comment=> p_cancel_comments,
	     --p_cancel_date =>Sysdate,

	     x_return_status     => x_return_status,
	     x_msg_count         => x_msg_count,
	     x_msg_data          => x_msg_data
	     ) ;



   END IF;


     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO approve_report;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.Approve_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs


END approve_report;

PROCEDURE reject_report (
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

  p_version_id IN NUMBER := null,
  p_record_version_number       IN     NUMBER := NULL,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 )
   IS

   l_rowid ROWID;

   CURSOR check_status_submitted IS
      SELECT  ROWID
	FROM pa_progress_report_vers
	WHERE version_id = p_version_id
	AND report_status_code = 'PROGRESS_REPORT_SUBMITTED';

   CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

      l_type VARCHAR2(80); /* bug 2447763 */



BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Approve_Report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT reject_report;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- can only reject the submitted report
  IF x_return_status = FND_API.g_ret_sts_success THEN

     OPEN check_status_submitted;
     FETCH check_status_submitted INTO l_rowid;

     IF check_status_submitted%NOTFOUND THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PR_RECORD_CHANGED');

	x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE
	CLOSE check_status_submitted;
     END IF;

   END IF;


   IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

      /*
	pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
	  (
	   p_version_id,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   'PROGRESS_REPORT_REJECTED',

	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,

	   p_record_version_number,
	   NULL,
	   x_return_status        ,
	   x_msg_count            ,
	   x_msg_data


	  );*/

	   change_report_status
	    (
	     p_version_id => p_version_id         ,
	     p_report_status => 'PROGRESS_REPORT_REJECTED',
	     p_record_version_number => p_record_version_number,
	    -- p_summary_version_number => NULL,
	     --p_cancel_comment=> p_cancel_comments,
	     --p_cancel_date =>Sysdate,

	     x_return_status     => x_return_status,
	     x_msg_count         => x_msg_count,
	     x_msg_data          => x_msg_data
	     ) ;

   END IF;


     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO reject_report;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.Reject_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END reject_report;


PROCEDURE update_report_details
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER := NULL,

   p_report_start_date           IN     DATE:= NULL,
   p_report_end_date             IN     DATE:= NULL,
   p_reported_by                 IN     NUMBER:= NULL,
   p_reported_by_name            IN     VARCHAR2:= NULL,
   p_progress_status             IN     VARCHAR2:= NULL,
   p_overview                    IN     VARCHAR2:= NULL,
   p_record_version_number       IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
  )
IS

   l_reported_by NUMBER;

   l_ret VARCHAR2(4);

   CURSOR is_report_status_working
     IS
	SELECT Decode(report_status_code, 'PROGRESS_REPORT_WORKING','Y', 'N')
	  FROM pa_progress_report_vers
	  WHERE version_id = p_version_id;

   CURSOR get_person_id
     IS
	SELECT person_id
	  FROM pa_employees
	  WHERE full_name = p_reported_by_name
	  AND active = '*';

       CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

      l_type VARCHAR2(80); /* bug 2447763 */


BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.update_report_details');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT update_report_details;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			   , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  --debug_msg ('before update 1' );

  IF (Trunc(p_report_end_date) < Trunc(p_report_start_date)) THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			   ,p_msg_name       => 'PA_REPORT_END_DATE_INV');
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  --debug_msg ('before update 1' || x_return_status );

  --debug_msg ('before update 1' || p_reported_by_name);

  --debug_msg ('before update reported_by ' || To_char(p_reported_by));
  --debug_msg ('before update reported_by ' || p_reported_by_name);

   -- check mandatory version_id
  IF (p_reported_by IS NULL) THEN
     -- we will try to get reported_by from reported_by_name
     OPEN get_person_id;
     FETCH get_person_id INTO l_reported_by;

     IF (get_person_id%notfound) THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_PR_REPORTED_BY_INV');
	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE get_person_id;
   ELSE
     l_reported_by := p_reported_by;
  END IF;

  --debug_msg ('before update 1' || x_return_status );
  --debug_msg ('validate_only' ||  p_validate_only);

  OPEN is_report_status_working;
  FETCH is_report_status_working INTO l_ret;
  CLOSE is_report_status_working;

/* Commenting below for bug 7521888
  IF l_ret <> 'Y' THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			   ,p_msg_name       => 'PA_UPDATE_REPORT_INV');
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
   IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then
*/
IF (p_validate_only <>FND_API.g_true AND l_ret = 'Y') then -- bug 7521888
      --debug_msg ('before update 2' || To_char(l_reported_by));
      --debug_msg ('before update 3' || p_overview);
      --debug_msg ('before update 4' || p_progress_status);

	pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
	  (
	   p_version_id,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,

	   Trunc(p_report_start_date)  ,
	   Trunc(p_report_end_date) ,
	   l_reported_by,
	   p_progress_status ,
	   p_overview ,
	   'N',
	   NULL,
	   NULL,
	   NULL,

	   p_record_version_number,
	   NULL,
           null,
	   x_return_status        ,
	   x_msg_count            ,
	   x_msg_data
	   );

   END IF;


     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  --debug_msg ('after update in PVT ');

  EXCEPTION
   WHEN OTHERS THEN
      --debug_msg ('exception ');
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO update_report_details;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.update_report_details'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END update_report_details;


PROCEDURE define_progress_report_setup
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_object_id                   IN     NUMBER := NULL,
   p_object_type                 IN     VARCHAR2 := NULL,
   p_page_type_code              IN     VARCHAR2 := 'PPR',
   p_page_id                     IN     NUMBER := NULL,
   p_page_name                   IN     VARCHAR2 := NULL,
   p_approval_required           IN     VARCHAR2 := NULL,
   --p_auto_publish                IN     VARCHAR2 := NULL,
   p_report_cycle_id             IN     NUMBER := NULL,
   p_report_offset_days          IN     NUMBER := NULL,
   p_next_reporting_date         IN     DATE := NULL,
   p_reminder_days              IN     NUMBER := NULL,
   p_reminder_days_type         IN     VARCHAR2 := NULL,
   p_initial_progress_status 	IN	VARCHAR2 := NULL,
   p_final_progress_status	IN	VARCHAR2 := NULL,
   p_rollup_progress_status	IN	VARCHAR2 := NULL,
   p_report_type_id              IN     NUMBER:= NULL,
   p_approver_source_id          IN     NUMBER:= NULL,
   p_approver_source_name        IN     VARCHAR2:= NULL,
   p_approver_source_type        IN     NUMBER:= NULL,
   p_effective_from              IN     DATE:= NULL,
   p_effective_to                IN     DATE:= NULL,
   p_object_page_layout_id       IN     NUMBER := NULL,
   p_action_set_id               IN     NUMBER := NULL,
   p_record_version_number       IN     NUMBER := NULL,
   p_function_name	         IN     VARCHAR2,
   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
  )
IS

   l_rowid ROWID;
   l_report_end_date date;
   l_next_reporting_date DATE;
   l_list_id   number;
   x_object_page_layout_id  number;
   l_list_item_id   number;
   l_page_id  NUMBER;
   page_id_l  NUMBER;
   approval_required_l  VARCHAR2(1);
   l_approver_source_id   NUMBER;
   l_approver_source_type NUMBER;
   l_new_action_set_id NUMBER;
   l_object_page_layout_id NUMBER := NULL;
   l_return_status VARCHAR2(10) := NULL;
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(10) := NULL;

   CURSOR check_object_page_layout_exits
     IS
	SELECT page_id, approval_required
	  FROM pa_object_page_layouts
	  WHERE
	  object_page_layout_id = p_object_page_layout_id;


   CURSOR get_page_id
     IS
	SELECT page_id
	  FROM pa_page_layouts
	  WHERE page_name = p_page_name
	  AND page_type_code = p_page_type_code;

   CURSOR report_type_exists
     IS
        SELECT ROWID
          FROM pa_report_types
          WHERE
          report_type_id = p_report_type_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.define_progress_report_setup');
  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_object_page_layout_id := p_object_page_layout_id;
  -- Issue API savepoint if the transaction is to be committed

  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT define_progress_report_setup;
  END IF;


  -- Bug# ,3302984 Added the code to handle OA Personalization.
  l_page_id  := p_page_id;
  IF ((l_page_id is null) AND (p_function_name is not null)) THEN

	PA_PAGE_LAYOUT_PUB.Create_Page_Layout(
		p_validate_only => fnd_api.g_false,
		p_page_name	=> p_page_name,
		p_page_type	=> p_page_type_code,
		p_function_name	=> p_function_name,
		p_description	=> null,
		p_start_date	=> sysdate,
		p_shortcut_menu_id	=> null,
		x_page_id	=> l_page_id,
		x_return_status		=> l_return_status,
		x_msg_count	=> l_msg_count,
		x_msg_data	=> l_msg_data
		);
  END IF;

  --To keep the code in sync with the existing one, return is issued.
  IF (x_return_status <> FND_API.g_ret_sts_success) THEN
     ROLLBACK TO define_progress_report_setup;
  END IF;

  -- check mandatory version_id
  --Bug#3302984 use l_page_id
  --IF (p_page_id IS NULL) THEN
  IF (l_page_id IS NULL) THEN

     -- added by syao
     -- for PPR if there is any non published progress report
     -- do not allow delete

   IF (p_page_type_code = 'PPR') THEN
     IF pa_progress_report_utils.is_delete_page_layout_ok(p_page_type_code, p_object_type, p_object_id, p_report_Type_id ) <> 'Y' THEN
	   -- we have to quit,
	   PA_UTILS.Add_Message( p_app_short_name => 'PA'
				 ,p_msg_name       => 'PA_REPORT_TYPE_REMOVE_INV');
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   RETURN;

     END IF;

   END IF;


     -- if page_name is not passed in, we will remove the pagelayout
     IF (p_page_name IS NULL) then
     -- remove from pa_object_page_layouts table

     --debug_msg('delete from pa_object_page_layouts' );

     DELETE FROM pa_object_page_layouts
       WHERE object_id = p_object_id AND object_type = p_object_type
       AND page_type_code = p_page_type_code
       and nvl(report_Type_id,-99) = nvl(p_report_type_id,-99);

     if (p_page_type_code = 'PPR') then
        PA_OBJECT_DIST_LISTS_PVT.DELETE_ASSOC_DIST_LISTS(p_validate_only => 'F',
                                               P_OBJECT_TYPE => 'PA_OBJECT_PAGE_LAYOUT',
                                               P_OBJECT_ID     => p_object_page_layout_id,
                                               x_return_status => x_return_status,
                                               x_msg_count  => x_msg_count,
                                               x_msg_data   => x_msg_data);

        pa_proj_stat_actset.delete_action_set (p_object_id   => p_object_page_layout_id
                                              ,p_validate_only => 'F'
                                              ,x_return_status => x_return_status
                                              ,x_msg_count => x_msg_count
                                              ,x_msg_data => x_msg_data);
     end if;

     --debug_msg('delete from pa_object_page_layouts done' );


     RETURN;
     ELSE

	-- we need to check the page_name
	OPEN get_page_id;
	FETCH get_page_id INTO l_page_id;


	IF (get_page_id%notfound ) THEN
	   PA_UTILS.Add_Message( p_app_short_name => 'PA'
				 ,p_msg_name       => 'PA_PAGE_LAYOUT_NAME_INV');
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   RETURN;

	 ELSE
	   -- we have the valid page_id now
	   NULL;
	END if;

	CLOSE get_page_id;

     END IF;

   --Bug#3302984 Commented Else.
   --ELSE
    -- l_page_id := p_page_id;

    --PA_UTILS.Add_Message( p_app_short_name => 'PA'
    --                     ,p_msg_name       => 'PA_PAGE_ID_INV');
    --x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  --debug_msg('object_id ' || To_char(p_object_id));
  --debug_msg('object_type ' || p_object_type);
  --debug_msg('p_report_cycle_id ' || To_char(p_report_cycle_id));
  --debug_msg('p_report_cycle_id ' || To_char(p_report_offset_days));

  --debug_msg ('approval_required:' || p_approval_required);

  IF ( p_page_type_code = 'PPR') then

     IF pa_progress_report_utils.is_edit_page_layout_ok(p_page_type_code, p_object_type, p_object_id, p_report_Type_id ) <> 'Y' THEN
           OPEN check_object_page_layout_exits;
           FETCH check_object_page_layout_exits INTO page_id_l, approval_required_l;
           close check_object_page_layout_exits;
           if (page_id_l <> l_page_id or approval_required_l <> p_approval_required) then
              -- we have to quit,
              PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                   ,p_msg_name       => 'PA_REPORT_TYPE_EDIT_INV');
              x_return_status := FND_API.G_RET_STS_ERROR;
              RETURN;
           end if;

     END IF;

    If (p_effective_to is not null and p_effective_from is null) or
          (p_effective_to < p_effective_from) THEN
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_EFFECTIVE_ED_DATE_INV');
      x_return_status := 'E';
    End If;

    if (p_approver_source_id is null and p_approver_source_name is not null) then
       begin
         SELECT resource_source_id, resource_type_id
          INTO l_approver_source_id, l_approver_source_type
          FROM pa_people_lov_v
         WHERE name = p_approver_source_name;
        exception when TOO_MANY_ROWS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_APPR_SOURCE_NAME_MULTIPLE');
           x_return_status := 'E';
        when OTHERS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_APPR_SOURCE_NAME_INV');
           x_return_status := 'E';
       end;

    else
        l_approver_source_id := p_approver_source_id;
        l_approver_source_type := p_approver_source_type;
    End if;

   /* Bug No. 2636791 -- Changed the error message and logic for its display
      Now the user gets error message when approval required checkbox is checked
      and the user has not entered any approver name */

   /* Bug No. 2636791 -- commented this */
   /* If (l_approver_source_id is not null and p_approval_required = 'N') then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PS_APPROVER_ERR');
      x_return_status := 'E';
    End If;  */

   /* Bug 2753246 no need for this check as HR manager is the default approver)
   If (l_approver_source_id is null and p_approval_required <> 'N') then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_APPR_SOURCE_NAME_INV');
      x_return_status := 'E';
    End If; */



    IF (p_next_reporting_date IS NULL AND
      p_report_cycle_id IS NOT null) THEN
     pa_progress_report_utils.get_report_start_end_dates
       (
	p_object_type,
	p_object_id,
        p_report_type_id,
	p_report_cycle_id,
	p_report_offset_days,

	'Y',
        p_effective_from,
	l_next_reporting_date,
	l_report_end_date

	--x_return_status               ,
	--x_msg_count                   ,
	--x_msg_data
	);
   ELSE
     l_next_reporting_date := NULL;
     l_report_end_date := NULL;

    END IF;
  ELSIF (p_page_type_code = 'TPR') then
	l_report_end_date := p_next_reporting_date;
  ELSE
     l_next_reporting_date := NULL;
     l_report_end_date := NULL;
  END IF;

  IF (p_page_type_code = 'PPR') THEN
           OPEN report_type_exists;
           FETCH report_type_exists INTO l_rowid;
           IF report_type_exists%NOTFOUND THEN
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_PS_REPORT_TYPE_INVALID');
               x_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
           ELSE
              -- we have the valid report_type_id
              NULL;
           END if;
           CLOSE report_type_exists;
  END IF;

  IF x_return_status = FND_API.g_ret_sts_success THEN

     OPEN check_object_page_layout_exits;
     FETCH check_object_page_layout_exits INTO page_id_l, approval_required_l;

     IF check_object_page_layout_exits%NOTFOUND THEN
	CLOSE check_object_page_layout_exits;

	-- we will insert into pa_object_page_layouts
	IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) THEN

	   pa_progress_report_pkg.insert_object_page_layout_row
	     (
	      P_OBJECT_ID ,
	      P_OBJECT_TYPE ,
	      L_PAGE_ID ,
	      P_PAGE_TYPE_CODE ,

	      P_APPROVAL_REQUIRED ,
	      --P_AUTO_PUBLISH ,
	      P_REPORT_CYCLE_ID ,
	      P_REPORT_OFFSET_DAYS ,

	      -- by msundare request, store end date in the table
	      l_report_end_date ,
	      P_REMINDER_DAYS ,
	      P_REMINDER_DAYS_TYPE ,
      	      P_INITIAL_PROGRESS_STATUS,
	      P_FINAL_PROGRESS_STATUS,
	      P_ROLLUP_PROGRESS_STATUS,
              p_report_type_id,
              l_approver_source_id,
              l_approver_source_type,
              p_effective_from,
              p_effective_to,
	      p_function_name,
              x_object_page_layout_id       ,
	      x_return_status               ,
	      x_msg_count                   ,
	      x_msg_data

	      );

        if (p_page_type_code = 'PPR' and x_return_status = 'S') then
          PA_DISTRIBUTION_LISTS_PVT.CREATE_DIST_LIST(p_validate_only => 'F',
                                                   p_init_msg_list           => 'F',
                                                   P_LIST_ID     => l_list_id,
                                                   p_name          => null,
                                                   p_description   => null,
                                                   x_return_status => x_return_status,
                                                   x_msg_count     => x_msg_count,
                                                   x_msg_data      => x_msg_data);

          if (x_return_status = 'S') then
            PA_DISTRIBUTION_LISTS_PVT.CREATE_DIST_LIST_ITEM(p_validate_only => 'F',
                                                       p_init_msg_list           => 'F',
                                                       P_LIST_ITEM_ID => l_list_item_id,
                                                       P_LIST_ID        => l_list_id,
                                                       P_RECIPIENT_TYPE => 'PROJECT_ROLE',
                                                       P_RECIPIENT_ID   => 1,
                                                       P_ACCESS_LEVEL   => 2,
                                                       p_menu_id        => null,
                                                       x_return_status => x_return_status,
                                                       x_msg_count     => x_msg_count,
                                                       x_msg_data      => x_msg_data);
           end if;

           if (x_return_status = 'S') then
             PA_OBJECT_DIST_LISTS_PVT.CREATE_OBJECT_DIST_LIST(p_validate_only => 'F',
                                                p_init_msg_list           => 'F',
                                                P_LIST_ID => l_list_id,
                                                P_OBJECT_TYPE => 'PA_OBJECT_PAGE_LAYOUT',
                                                P_OBJECT_ID   => x_object_page_layout_id,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data);
           end if;


        end if;

	END IF;
        -- Save object_page_layout_id to update action sets - mw
        l_object_page_layout_id := x_object_page_layout_id;
      ELSE
	CLOSE check_object_page_layout_exits;

	   -- we will insert into pa_object_page_layouts
	IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) THEN


	   pa_progress_report_pkg.update_object_page_layout_row
	     (
	      P_OBJECT_ID ,
	      P_OBJECT_TYPE ,
	      L_PAGE_ID ,
	      P_PAGE_TYPE_CODE ,

	      P_APPROVAL_REQUIRED ,
	      --P_AUTO_PUBLISH ,
	      P_REPORT_CYCLE_ID ,
	      P_REPORT_OFFSET_DAYS ,
	      l_report_end_date ,

	      P_REMINDER_DAYS ,
	      P_REMINDER_DAYS_TYPE ,
	      P_INITIAL_PROGRESS_STATUS,
	      P_FINAL_PROGRESS_STATUS,
	      P_ROLLUP_PROGRESS_STATUS,

              p_report_type_id,
              l_approver_source_id,
              l_approver_source_type,
              p_effective_from,
              p_effective_to,
              p_object_page_layout_id,

	      p_record_version_number,
	      p_function_name,
	      x_return_status               ,
	      x_msg_count                   ,
	      x_msg_data

	      );


	END IF;

     END IF;

  END IF;


  --Add, Delete or replace action sets
  IF (x_return_status = 'S') THEN
      IF p_page_type_code = 'PPR' and l_object_page_layout_id is NOT NULL THEN
             PA_PROJ_STAT_ACTSET.update_action_set(
             p_action_set_id           => p_action_set_id
            ,p_object_id               => l_object_page_layout_id
            ,p_commit                  => p_commit
            ,p_validate_only           => p_validate_only
            ,p_init_msg_list           => 'F'
            ,x_new_action_set_id       => l_new_action_set_id
            ,x_return_status           => x_return_status
            ,x_msg_count               => x_msg_count
            ,x_msg_data                => x_msg_data);
      ELSE
         IF p_page_type_code = 'TPR' and l_object_page_layout_id is NOT NULL THEN
             PA_TASK_PROG_ACTSET.update_action_set(
             p_action_set_id           => p_action_set_id
            ,p_object_id               => p_object_id
            ,p_commit                  => p_commit
            ,p_validate_only           => p_validate_only
            ,p_init_msg_list           => 'F'
            ,x_new_action_set_id       => l_new_action_set_id
            ,x_return_status           => x_return_status
            ,x_msg_count               => x_msg_count
            ,x_msg_data                => x_msg_data);
         END IF;
      END IF;
   END IF;

  -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;

  if (x_msg_count >= 1) then
     x_return_status := FND_API.g_ret_sts_Error;
  end if;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO define_progress_report_setup;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.define_progress_report_setup'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs



END define_progress_report_setup;

PROCEDURE delete_report
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER :=NULL,
   p_record_version_number       IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   )

 IS

    l_rowid ROWID;
    l_item_key wf_item_activity_statuses.item_key%TYPE;         --Bug 5217292
    l_wf_status VARCHAR2(30);
    l_dummy VARCHAR2(1);

    l_item_type VARCHAR2(30);


     CURSOR get_item_key IS
       SELECT MAX(pwp.item_key), max(pwp.item_type)
         from pa_wf_processes pwp, pa_project_statuses pps,
	 pa_progress_report_vers pprv
	 where pwp.item_type = pps.WORKFLOW_ITEM_TYPE
	 and pps.status_type = 'PROGRESS_REPORT'
	 and pps.project_status_code =  'PROGRESS_REPORT_SUBMITTED'
	 AND entity_key2 = p_version_id
	 AND pwp.wf_type_code = 'Progress Report'
	 AND entity_key1 = pprv.object_id
	 AND pprv.version_id = p_version_id
	 AND pprv.object_type = 'PA_PROJECTS';

--    CURSOR get_wf_status IS
 --      select  'Y' FROM dual
--	 WHERE exists
--	 (SELECT *
--	 from wf_item_activity_statuses
--	 WHERE item_type = 'PAWFPPRA'
--	 AND item_key = l_item_key
	-- AND activity_status = 'ACTIVE');
 CURSOR get_wf_status IS
       select  'Y' FROM dual
	 WHERE exists
	 (SELECT *
	 from wf_item_activity_statuses wias, pa_project_statuses pps
	 WHERE wias.item_type = pps.WORKFLOW_ITEM_TYPE
	 AND wias.item_key = l_item_key
	  AND wias.activity_status = 'ACTIVE'
	  AND pps.status_type = 'PROGRESS_REPORT'
	  AND pps.project_status_code =  'PROGRESS_REPORT_SUBMITTED');


    CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';


   CURSOR check_status_submitted IS
      SELECT  ROWID
	FROM pa_progress_report_vers
	WHERE version_id = p_version_id
	AND report_status_code = 'PROGRESS_REPORT_SUBMITTED';


l_type VARCHAR2(80); /* bug 2447763 */


BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Delete_Report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT delete_report;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			   , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  -- cancel the workflow which if it is already launched.
  open  check_status_submitted;
  FETCH check_status_submitted    INTO l_rowid;

  IF check_status_submitted%FOUND THEN
     CLOSE check_status_submitted;
     OPEN get_item_key;
     FETCH get_item_key INTO l_item_key, l_item_type;

     IF get_item_key%found THEN
	CLOSE get_item_key;

	-- is the workflow running
	-- only cancel when the workflow is running

	OPEN get_wf_status;
	FETCH get_wf_status INTO l_wf_status;

	IF (get_wf_status%notfound or
	    l_wf_status <> 'Y' ) THEN
	   NULL;

	 else

	   pa_progress_report_workflow.cancel_workflow
	     (
	      l_item_type
	      , l_item_key
	      , x_msg_count
	      , x_msg_data
	      , x_return_status
	      );

	   IF  (l_dummy = 'N') THEN
	      x_return_status := FND_API.G_RET_STS_SUCCESS;
	   END IF;

	END IF;

	CLOSE get_wf_status;

      ELSE

	CLOSE get_item_key;
	-- does not find item key for the workflow
	-- return

	-- if workflow is required, we are canceling the submission
	-- failed, return error.
	--  IF (l_dummy = 'Y' or l_dummy = 'A' )THEN
	--	 PA_UTILS.Add_Message( p_app_short_name => 'PA'
	--			       ,p_msg_name       => 'PA_PR_CANCEL_WORKFLOW_INV');
	--	 x_return_status := FND_API.G_RET_STS_ERROR;
	NULL;
     END IF;
   ELSE
     CLOSE check_status_submitted;

  END IF;


  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

      -- delete all records in pa_progress_report_vals under the p_version_id
      pa_progress_report_pkg.delete_progress_report_vals
	(
	 p_version_id,
	 x_return_status           ,
	 x_msg_count               ,
	 x_msg_data
	 );

      IF (x_return_status = FND_API.g_ret_sts_success) THEN

	 -- delete record in pa_progress_report_vers under the p_version_id
	 pa_progress_report_pkg.delete_progress_report_ver_row
	   (
	    p_version_id,
	    p_record_version_number,
	    x_return_status           ,
	    x_msg_count               ,
	    x_msg_data
	    );

      END IF;

   END IF;


     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO delete_report;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.Delete_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END delete_report;

PROCEDURE rework_report
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER := NULL,
   p_record_version_number       IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   ) IS

   l_rowid ROWID;
   l_item_key wf_item_activity_statuses.item_key%TYPE;      --Bug 5217292
   l_wf_status VARCHAR2(30);
   l_item_type VARCHAR2(30);
   l_dummy VARCHAR2(30) := 'N';

   CURSOR check_auto_approve IS
      SELECT 'Y' FROM dual
	WHERE exists
	(
      SELECT p1.approval_required
	FROM pa_object_page_layouts p1,
	pa_progress_report_vers p2
	WHERE
	p2.version_id = p_version_id
	AND p2.object_id =  p1.object_id
	AND p2.object_type = p1.object_type
	 AND (p1.approval_required = 'Y'
	      OR p1.approval_required = 'A'
	      )
	 );


     CURSOR get_item_key IS
       SELECT MAX(pwp.item_key), max(pwp.item_type)
         from pa_wf_processes pwp, pa_project_statuses pps,
	 pa_progress_report_vers pprv
	 where pwp.item_type = pps.WORKFLOW_ITEM_TYPE
	 and pps.status_type = 'PROGRESS_REPORT'
	 and pps.project_status_code =  'PROGRESS_REPORT_SUBMITTED'
	 AND entity_key2 = p_version_id
	 AND entity_key1 = pprv.object_id
	 AND wf_type_code = 'Progress Report'
	 AND pprv.version_id = p_version_id
	 AND pprv.object_type = 'PA_PROJECTS';

   -- CURSOR get_wf_status IS
     --  select  'Y' FROM dual
--	 WHERE exists
--	 (SELECT *
--	 from wf_item_activity_statuses
--	 WHERE item_type = 'PAWFPPRA'
--	 AND item_key = l_item_key
--	 AND activity_status = 'ACTIVE');

       CURSOR get_wf_status IS
       select  'Y' FROM dual
	 WHERE exists
	 (SELECT *
	 from wf_item_activity_statuses wias, pa_project_statuses pps
	 WHERE wias.item_type = pps.WORKFLOW_ITEM_TYPE
	 AND wias.item_key = l_item_key
	  AND wias.activity_status = 'ACTIVE'
	  AND pps.status_type = 'PROGRESS_REPORT'
	  AND pps.project_status_code =  'PROGRESS_REPORT_SUBMITTED');

    CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

l_type VARCHAR2(80); /* bug 2447763 */

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Rework_Report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  SAVEPOINT rework_report;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

     -- set the status to working first

     /*
	pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
	  (
	   p_version_id         ,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   'PROGRESS_REPORT_WORKING',


	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,

	   P_RECORD_VERSION_NUMBER    ,
	   NULL,
	   x_return_status        ,
	   x_msg_count             ,
	   x_msg_data
	  );*/
	   change_report_status
	    (
	     p_version_id => p_version_id         ,
	     p_report_status => 'PROGRESS_REPORT_WORKING',
	     p_record_version_number => p_record_version_number,
	    -- p_summary_version_number => NULL,
	     --p_cancel_comment=> p_cancel_comments,
	     --p_cancel_date =>Sysdate,

	     x_return_status     => x_return_status,
	     x_msg_count         => x_msg_count,
	     x_msg_data          => x_msg_data
	     ) ;

	IF (x_return_status = FND_API.g_ret_sts_success) THEN
	   -- cancel the approval workflow process if that is already launched
	   -- todo

	   -- check whether report approval is required.

	   OPEN check_auto_approve;
	   FETCH check_auto_approve INTO l_dummy;
	   IF (check_auto_approve%notfound OR l_dummy <> 'Y') THEN
	      l_dummy := 'N';
	   END if;

	   CLOSE check_auto_approve;


	   OPEN get_item_key;
	   FETCH get_item_key INTO l_item_key, l_item_type;

	   IF get_item_key%found THEN
	      CLOSE get_item_key;

	      -- is the workflow running
	      -- only cancel when the workflow is running

	      OPEN get_wf_status;
	      FETCH get_wf_status INTO l_wf_status;

	      IF (get_wf_status%notfound or
		l_wf_status <> 'Y' ) THEN
		 IF (l_dummy = 'Y' or l_dummy = 'A') then
		    PA_UTILS.Add_Message( p_app_short_name => 'PA'
					  ,p_msg_name       => 'PA_PR_CANCEL_WORKFLOW_INV');
		    --todo
		    --   x_return_status := FND_API.G_RET_STS_ERROR;
		 END IF;

	      else

		 pa_progress_report_workflow.cancel_workflow
		   (
		    l_item_type
		    , l_item_key
		    , x_msg_count
		    , x_msg_data
		    , x_return_status
		    );

		 IF  (l_dummy = 'N') THEN
		    x_return_status := FND_API.G_RET_STS_SUCCESS;
		 END IF;

	      END IF;

	      CLOSE get_wf_status;

	    ELSE
	      -- does not find item key for the workflow
	      -- return

	      -- if workflow is required, we are canceling the submission
	      -- failed, return error.
	      IF (l_dummy = 'Y' or l_dummy = 'A' )THEN
		 PA_UTILS.Add_Message( p_app_short_name => 'PA'
				       ,p_msg_name       => 'PA_PR_CANCEL_WORKFLOW_INV');
		 x_return_status := FND_API.G_RET_STS_ERROR;

	      END IF;

	   END IF;

	END IF;


  END IF;


  -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;

  IF (x_return_status <> FND_API.g_ret_sts_success  )THEN
     ROLLBACK TO rework_report;
  END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO rework_report;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.Rework_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END rework_report;

PROCEDURE publish_report
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER := NULL,
   p_record_version_number       IN     NUMBER := NULL,
   p_summary_version_number       IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   ) IS

   l_rowid ROWID;
   l_dummy VARCHAR2(1);

   l_version_id NUMBER;

   CURSOR check_auto_approve IS
      SELECT p1.approval_required
	FROM pa_object_page_layouts p1,
	pa_progress_report_vers p2
	WHERE
	p2.version_id = l_version_id
	AND p2.object_id =  p1.object_id
	AND p2.object_type = p1.object_type;

    CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

   --Bug#3302984, added the function name parameter
    CURSOR get_setup_info
      IS SELECT
	popl.object_id, popl.object_type,  popl.reporting_cycle_id,
	popl.report_offset_days, popl.approval_required,
	popl.reminder_days, popl.reminder_days_type, popl.record_version_number,popl.pers_function_name,
	popl.page_type_code, popl.initial_progress_status, popl.final_progress_status,popl.rollup_progress_status,
        popl.report_type_id, popl.approver_source_id, popl.approver_source_type, popl.effective_from,
        popl.effective_to, popl.object_page_layout_id
	FROM pa_object_page_layouts popl, pa_progress_report_vers pprv
	WHERE pprv.version_id = p_version_id
	AND popl.object_id = pprv.object_id
	AND popl.object_type = pprv.object_type
        AND popl.page_type_code = 'PPR'
        AND popl.report_type_id = pprv.report_type_id;

    l_approval_required VARCHAR2(1);
    l_reminder_days NUMBER;
    l_reminder_days_type VARCHAR2(30);
    l_type VARCHAR2(80); /* bug 2447763 */

    l_next_reporting_date DATE;
    l_report_end_date    DATE;

    l_object_type VARCHAR2(30);
    l_object_id NUMBER;
    l_report_cycle_id NUMBER;
    l_report_offset_days number;
    l_record_version_number NUMBER;
    l_function_name VARCHAR2(30);
    l_page_type_code VARCHAR2(30);
    l_initial_progress_status VARCHAR2(30);
    l_final_progress_status VARCHAR2(30);
    l_rollup_progress_status VARCHAR2(1);

    l_report_type_id NUMBER;
    l_approver_source_id NUMBER;
    l_approver_source_type NUMBER;
    l_effective_from DATE;
    l_effective_to DATE;
    l_object_page_layout_id NUMBER;

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Publish_Report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  SAVEPOINT publish_report;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;


  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

     -- set the status to working first

     --debug_msg('UPDATE_PROGRESS_REPORT_VER_ROW');
     /*
	pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
	  (
	   p_version_id,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   'PROGRESS_REPORT_PUBLISHED',


	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   SYSDATE,
	   NULL,
	   NULL,


	   --NULL,
	   P_RECORD_VERSION_NUMBER   ,
	   P_SUMMARY_VERSION_NUMBER   ,
	   x_return_status           ,
	   x_msg_count               ,
	   x_msg_data
	  );*/

	   change_report_status
	    (
	     p_version_id => p_version_id         ,
	     p_report_status => 'PROGRESS_REPORT_PUBLISHED',
	     p_record_version_number => p_record_version_number,
	     p_summary_version_number => p_summary_version_number,
	     p_published_date => Sysdate,
	     --p_cancel_comment=> p_cancel_comments,
	     --p_cancel_date =>Sysdate,

	     x_return_status     => x_return_status,
	     x_msg_count         => x_msg_count,
	     x_msg_data          => x_msg_data
	     ) ;

	IF (x_return_status = FND_API.g_ret_sts_success) THEN

	   OPEN check_auto_approve;

	   FETCH check_auto_approve INTO l_dummy;

	   IF (l_dummy = 'Y' or l_dummy = 'A') THEN
	      -- if auto approve, the information has been saved already
	      -- we do not need to save anything
	      NULL;
	    else
	      -- update information in other tables
	      --update_project_perccomplete(p_version_id,
		--			x_return_status,
			--		x_msg_count,
	      --	   x_msg_data);

	      NULL;

	   END IF;

	   -- by msundare request, need to change the next report end date

	   OPEN get_setup_info;
	   FETCH get_setup_info INTO l_object_id, l_object_type, l_report_cycle_id,l_report_offset_days, l_approval_required, l_reminder_days,
	     l_reminder_days_type, l_record_version_number, l_function_name,l_page_type_code, l_initial_progress_status, l_final_progress_status, l_rollup_progress_status,
    l_report_type_id,
    l_approver_source_id,
    l_approver_source_type,
    l_effective_from,
    l_effective_to,
    l_object_page_layout_id;

	   CLOSE get_setup_info;

	   IF (l_report_cycle_id IS NOT null) then


	   --debug_msg('get_report_start_end_dates');
	   pa_progress_report_utils.get_report_start_end_dates
	      (
	       l_object_type,
	       l_object_id,
               l_report_type_id,
	       l_report_cycle_id,
	       l_report_offset_days,

	       'Y',
               null,
	       l_next_reporting_date,
	       l_report_end_date
	       );


	   --debug_msg('update_object_page_layout_row');
	     pa_progress_report_pkg.update_object_page_layout_row
	     (
	      l_OBJECT_ID ,
	      l_OBJECT_TYPE ,
	      null ,
	      l_page_type_code ,

	      l_approval_required ,
	      --P_AUTO_PUBLISH ,
	      l_report_cycle_id ,
	      l_report_offset_days,

	      l_report_end_date ,
	      l_REMINDER_DAYS ,
	      l_REMINDER_DAYS_TYPE ,
	      l_initial_progress_status,
	      l_final_progress_status,
	      l_rollup_progress_status,
              l_report_type_id,
              l_approver_source_id,
              l_approver_source_type,
              l_effective_from,
              l_effective_to,
              l_object_page_layout_id,

	      l_record_version_number,
	      l_function_name,
	      x_return_status               ,
	      x_msg_count                   ,
	      x_msg_data

	      );
	   END IF;


	     -- debug_msg('update_object_page_layout_row' || x_return_status);



	   CLOSE check_auto_approve;
	END IF;

  END IF;





  -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;

  IF (x_return_status <> FND_API.g_ret_sts_success  )THEN
     ROLLBACK TO publish_report;
  END IF;
 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO publish_report;

        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.Publish_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END publish_report;

PROCEDURE submit_report
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER := NULL,
   p_record_version_number       IN     NUMBER := NULL,
   p_summary_version_number       IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   ) IS

   l_rowid ROWID;

   l_err_code NUMBER;
   l_err_stage VARCHAR2(30);
   l_err_stack VARCHAR2(240);
   l_project_id NUMBER;


   CURSOR get_object_id IS
	 SELECT object_id
	   FROM pa_progress_report_vers
	   WHERE version_id = p_version_id
	   AND object_type = 'PA_PROJECTS'
	   AND report_status_code = 'PROGRESS_REPORT_WORKING';



   l_item_key wf_item_activity_statuses.item_key%TYPE;    --Bug 5217292
   l_dummy VARCHAR2(1);

   CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = 'PPR';

      l_type VARCHAR2(80); /* bug 2447763 */

      l_wf_item_type VARCHAR2(30);
      l_wf_process_name VARCHAR2(30);
      l_wf_enable VARCHAR2(1);

      CURSOR get_wf_process_name
	IS
	   select
	     WORKFLOW_ITEM_TYPE,
	     workflow_process, enable_wf_flag from pa_project_statuses
	     where status_type = 'PROGRESS_REPORT'
	     AND project_status_code =  'PROGRESS_REPORT_SUBMITTED';

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Submit_Report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  SAVEPOINT submit_report;


  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check mandatory version_id
  IF (p_version_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PR_VERSION_ID_INV'
			   , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  OPEN get_object_id;

  FETCH get_object_id INTO l_project_id;

  IF get_object_id%notfound THEN
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PR_STATUS_NOT_WORKING');
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CLOSE get_object_id;

  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

     -- set the status to working first

	pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
	  (
	   p_version_id,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   'PROGRESS_REPORT_SUBMITTED',


	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   'N',
	   NULL,
	   NULL,
	   NULL,


	   P_RECORD_VERSION_NUMBER   ,
	   p_summary_version_number  ,

           null,
	   x_return_status           ,
	   x_msg_count               ,
	   x_msg_data
	   );

	IF (x_return_status = FND_API.g_ret_sts_success) THEN
	   -- update information in other tables
	   --update_project_perccomplete(p_version_id,
		--			x_return_status,
			--		x_msg_count,
				--	x_msg_data);

	   IF(x_return_status =   FND_API.g_ret_sts_success  )THEN
	      -- launch the workflow process

	      -- added by syao
	      -- get the workflow process name
	      open get_wf_process_name;
	      fetch get_wf_process_name INTO l_wf_item_type,
		l_wf_process_name, l_wf_enable;

	       IF get_wf_process_name%found AND l_wf_enable = 'Y'THEN
		  CLOSE get_wf_process_name;

		  pa_progress_report_workflow.start_workflow
		    (
		    -- 'PAWFPPRA'
		     -- , 'PA_PROG_REP_APPRVL_MP'
		     l_wf_item_type
		     , l_wf_process_name
		     , p_version_id
		     , l_item_key
		     , x_msg_count
		     , x_msg_data
		     , x_return_status
		     );

		  IF(x_return_status =   FND_API.g_ret_sts_success  )THEN

		    -- update pa_wf_process_table
		    PA_WORKFLOW_UTILS.Insert_WF_Processes
		      (p_wf_type_code           => 'Progress Report'
		       --	       ,p_item_type              => 'PAWFPPRA'
		       ,p_item_type              => l_wf_item_type
		       ,p_item_key               => l_item_key
		       ,p_entity_key1            => l_project_id
		       ,p_entity_key2            => p_version_id
		       ,p_description            => l_wf_process_name
		       ,p_err_code               => l_err_code
		       ,p_err_stage              => l_err_stage
		       ,p_err_stack              => l_err_stack
		       );

		    IF l_err_code <> 0 THEN
		       PA_UTILS.Add_Message( p_app_short_name => 'PA'
					     ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
		       x_return_status := FND_API.G_RET_STS_ERROR;

		    END IF;


		   ELSE
		     PA_UTILS.Add_Message( p_app_short_name => 'PA'
					   ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
		     x_return_status := FND_API.G_RET_STS_ERROR;

		  END IF;
		ELSE
		  CLOSE get_wf_process_name;

	       END IF;

	   END IF;


	END IF;


  END IF;



  -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;

  IF (x_return_status <> FND_API.g_ret_sts_success  )THEN
     ROLLBACK TO submit_report;
  END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN

        ROLLBACK TO submit_report;

        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.Submit_Report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END submit_report;

PROCEDURE change_report_status
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_false,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER := NULL,
   p_report_status               IN     VARCHAR2 := NULL,
   p_record_version_number       IN     NUMBER := NULL,
   p_summary_version_number      IN     NUMBER := NULL,
   p_published_date                 IN     DATE := NULL,
   p_cancel_comment              IN     VARCHAR2 := NULL,
   p_cancel_date                 IN     DATE := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   ) IS

      l_wf_enable VARCHAR2(1);
      l_wf_item_type VARCHAR2(30);
      l_wf_process VARCHAR2(30);
      l_success_code VARCHAR2(30);
      l_failure_code VARCHAR2(30);
      l_err_code NUMBER;
      l_err_stage VARCHAR2(30);
      l_err_stack VARCHAR2(240);
      l_project_id NUMBER;
      l_report_end_date DATE;
      l_report_type_id NUMBER;
      l_current_flag VARCHAR2(1);
      x_report_end_date DATE;
      x_version_id  NUMBER;
      l_record_version_number NUMBER;
      l_summary_version_number  NUMBER;
      l_item_key wf_item_activity_statuses.item_key%TYPE;      --Bug 5217292
      l_dummy VARCHAR2(1);

      CURSOR get_object_id IS
	 SELECT object_id, report_end_date, report_type_id
	   FROM pa_progress_report_vers
	   WHERE version_id = p_version_id
	   AND object_type = 'PA_PROJECTS';

      CURSOR get_wf_info is
	 select enable_wf_flag, workflow_item_type,
	   workflow_process,wf_success_status_code,
	   wf_failure_status_code  from pa_project_statuses
	   where project_status_code = p_report_status;


	   --like 'PROGRESS_REPORT%'

BEGIN
   -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.Change_Report_Status');

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- get the project_id
   OPEN get_object_id;

   FETCH get_object_id INTO l_project_id,l_report_end_date, l_report_type_id;

--   IF get_object_id%notfound THEN
  --    PA_UTILS.Add_Message( p_app_short_name => 'PA'
	--		    ,p_msg_name       => 'PA_PR_STATUS_NOT_WORKING');
      --x_return_status := FND_API.G_RET_STS_ERROR;
   --END IF;
   CLOSE get_object_id;

  --- Check for the last published report and compare dates. If date is
  --- greater than last one then current_flag = 'Y' else 'N'

  if (p_report_status = 'PROGRESS_REPORT_PUBLISHED') then
       begin
          select version_id,report_end_Date ,
                 record_version_number, summary_version_number
          into x_version_id,x_report_end_date,
                 l_record_version_number, l_summary_version_number
          from pa_progress_report_vers
         where object_id = l_project_id
           and object_Type = 'PA_PROJECTS'
           and report_type_id = l_report_Type_id
           and page_type_code = 'PPR'
           and current_flag = 'Y';

       if (l_report_end_date >= x_report_end_Date) then
           l_current_flag := 'Y';
           pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
          (
           x_version_id,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,


           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           'N',
           null,
           null,
           null,


           l_RECORD_VERSION_NUMBER   ,
           l_summary_version_number  ,

           null,
           x_return_status           ,
           x_msg_count               ,
           x_msg_data
           );
       else
           l_current_flag := 'N';
       end if;
       exception
         when no_data_found then
              l_current_flag := 'Y';
         when others then
           l_current_flag := 'N';
       end;
  else
       l_current_flag := 'N';
  end if;

   -- change the progress status, launch the workflow if necessary
    IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then
       pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW
	  (
	   p_version_id,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   p_report_status,


	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   NULL,
	   l_current_flag,
	   p_published_date,
	   p_cancel_comment,
	   p_cancel_date,


	   P_RECORD_VERSION_NUMBER   ,
	   p_summary_version_number  ,

           null,
	   x_return_status           ,
	   x_msg_count               ,
	   x_msg_data
	   );
       IF (x_return_status =   FND_API.g_ret_sts_success  )THEN


	  -- check whether to launch the workflow
	  OPEN get_wf_info;
	  FETCH get_wf_info INTO  l_wf_enable, l_wf_item_type, l_wf_process,
	    l_success_code,l_failure_code;
	  IF (get_wf_info%found) then
	     IF l_wf_enable = 'Y' THEN



		-- launch the workflow for the report status change

		  pa_progress_report_workflow.start_workflow
		    (
		    -- 'PAWFPPRA'
		     -- , 'PA_PROG_REP_APPRVL_MP'
		     l_wf_item_type
		     , l_wf_process
		     , p_version_id
		     , l_item_key
		     , x_msg_count
		     , x_msg_data
		     , x_return_status
		     );

		  IF(x_return_status =   FND_API.g_ret_sts_success  )THEN

		    -- update pa_wf_process_table
		    PA_WORKFLOW_UTILS.Insert_WF_Processes
		      (p_wf_type_code           => 'Progress Report'
		       --	       ,p_item_type              => 'PAWFPPRA'
		       ,p_item_type              => l_wf_item_type
		       ,p_item_key               => l_item_key
		       ,p_entity_key1            => l_project_id
		       ,p_entity_key2            => p_version_id
		       ,p_description            => l_wf_process
		       ,p_err_code               => l_err_code
		       ,p_err_stage              => l_err_stage
		       ,p_err_stack              => l_err_stack
		       );

		    IF l_err_code <> 0 THEN
		       PA_UTILS.Add_Message( p_app_short_name => 'PA'
					     ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
		       x_return_status := FND_API.G_RET_STS_ERROR;

		    END IF;


		   ELSE
		     PA_UTILS.Add_Message( p_app_short_name => 'PA'
					   ,p_msg_name       => 'PA_PR_CREATE_WF_FAILED');
		     x_return_status := FND_API.G_RET_STS_ERROR;

		  END IF;
	     END IF;
	  END IF;
	  CLOSE get_wf_info;



       END IF;

    END IF;

     -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;

   -- Reset the error stack when returning to the calling program
   PA_DEBUG.Reset_Err_Stack;

EXCEPTION
    WHEN OTHERS THEN

        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.Change_Report_Status'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs
END change_report_status;


PROCEDURE create_report
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_object_id                   IN     NUMBER := NULL,
   p_object_type                 IN     VARCHAR2 := NULL,
   p_report_type_id              IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2,    --File.Sql.39 bug 4440895
   x_version_id                  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
   ) IS

  l_rowid ROWID;
  l_report_start_date DATE;
  l_report_end_date DATE;
  l_last_published_version_id  NUMBER;
  l_page_id NUMBER;
  l_page_type VARCHAR2(30);
  l_reporting_cycle_id NUMBER;
  l_report_offset_days NUMBER;
  l_progress_status_code VARCHAR2(30);
  l_effective_from_date Date;

  CURSOR get_page_id_type
    IS
       SELECT popl.page_id, popl.page_type_code, popl.reporting_cycle_id, popl.report_offset_days,popl.effective_from
	 FROM pa_object_page_layouts popl, pa_page_layouts ppl
	 WHERE popl.object_id = p_object_id
	 AND popl.object_type = p_object_type
         AND popl.report_type_id = p_report_type_id
	 AND popl.page_id = ppl.page_id
         AND popl.page_type_code = 'PPR';


  CURSOR report_exist
    IS
     SELECT rowid
       FROM pa_progress_report_vers
       WHERE object_id = p_object_id
       AND object_type = p_object_type
       AND report_type_id = p_report_type_id
       AND report_status_code = 'PROGRESS_REPORT_PUBLISHED';

  /*  Commented and changed as below for bug 5956107
  CURSOR get_last_published_version_id
    IS
     SELECT version_id
       FROM pa_progress_report_vers p1
       WHERE
       p1.object_id = p_object_id
       AND p1.object_type = p_object_type
       ANd p1.report_type_id = p_report_type_id
       AND p1.report_status_code = 'PROGRESS_REPORT_PUBLISHED'
       AND ROWNUM =1
       AND p1.report_end_date =
       (
	SELECT MAX(report_end_date)
	FROM pa_progress_report_vers
	WHERE
	object_id = p_object_id
	AND object_type = p_object_type
        AND report_type_id = p_report_type_id
	AND report_status_code = 'PROGRESS_REPORT_PUBLISHED'
	); */

  CURSOR get_last_published_version_id
    IS
     SELECT version_id
       FROM pa_progress_report_vers p1
       WHERE
       p1.object_id = p_object_id
       AND p1.object_type = p_object_type
       ANd p1.report_type_id = p_report_type_id
       AND p1.report_status_code = 'PROGRESS_REPORT_PUBLISHED'
       AND ROWNUM =1
       AND p1.published_date =
       (
        SELECT MAX(published_date)
        FROM pa_progress_report_vers
        WHERE
        object_id = p_object_id
        AND object_type = p_object_type
        AND report_type_id = p_report_type_id
        AND report_status_code = 'PROGRESS_REPORT_PUBLISHED'
        );

  CURSOR get_all_regions IS
      SELECT *
	FROM pa_progress_report_vals
	WHERE version_id = l_last_published_version_id;

  CURSOR get_publish_overview IS
      SELECT overview, progress_status_code, REPORT_START_DATE
	FROM pa_progress_report_vers
	WHERE version_id = l_last_published_version_id;

  CURSOR get_all_regions_from_template IS
      SELECT pplr.*
	FROM pa_page_layout_regions pplr
	WHERE pplr.page_id = l_page_id;

  CURSOR get_project_manager
    IS
       select RESOURCE_SOURCE_ID
	 from pa_project_parties where project_id = p_object_id;

  CURSOR get_max_report_end_date
    IS SELECT MAX(report_end_date)
      FROM pa_progress_report_vers
      WHERE object_id = p_object_id
      AND object_type = p_object_type
      AND report_Type_id = p_report_Type_id
      ;

  CURSOR get_person_id
    IS
       select usr.employee_id
	 from
	 fnd_user usr
	 WHERE
	 usr.user_id = fnd_global.user_id
	 and    trunc(sysdate) between USR.START_DATE and nvl(USR.END_DATE, sysdate+1);

   /*CURSOR get_resource_id
     IS
        select resource_id
          from pa_project_parties_v
         where user_id = fnd_global.user_id;*/

  l_mgr_id number;
  l_overview VARCHAR2(240);
  l_person_id NUMBER;
  l_report_cycle_flag VARCHAR2(1) := 'Y';  -- flag to determine if there is a report cycle
  l_call_setup        VARCHAR2(1);

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.create_next_progress_report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed

  SAVEPOINT create_next_progress_report;


  -- check mandatory version_id
  IF (p_object_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_OBJECT_ID_INV');
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  l_page_id := -99;
  l_call_setup := 'N';

  OPEN get_page_id_type;
  FETCH get_page_id_type INTO l_page_id, l_page_type, l_reporting_cycle_id,
    l_report_offset_days, l_effective_from_date;

  IF get_page_id_type%notfound THEN
     l_page_id := pa_progress_report_utils.get_object_page_id(p_page_type_code => 'PPR',
                                                              p_object_Type => 'PA_PROJECTS',
                                                              p_object_id => p_object_id,
                                                              p_report_Type_id => p_report_Type_id);
     l_page_type := 'PPR';
     l_call_setup := 'Y';
     l_effective_from_date := trunc(sysdate);
  End if;

  if (l_page_id = -99) then
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
		          ,p_msg_name       => 'PA_NO_PRJ_REP_TEMPLATE');
     x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  CLOSE get_page_id_type;

  IF (l_call_setup = 'Y' and x_return_status = FND_API.g_ret_sts_success) then
       ---- call setup api
      define_progress_report_setup
      (
       p_validate_only            => FND_API.g_false,
       p_init_msg_list            => FND_API.g_false,
       p_object_id                => p_object_id,
       p_object_type              => p_object_type,
       p_page_type_code           => l_page_type,
       p_page_id                  => l_page_id,
       p_approval_required        => 'N',
       p_report_Type_id           => p_report_Type_id,
       p_effective_from           => l_effective_from_date,
       x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data
       );

  END IF;

  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

     -- create an entry in pa_progress_report_vers table

     --debug_msg('before get dates' || To_char(l_reporting_cycle_id));

     IF l_reporting_cycle_id IS NOT NULL then
	l_report_cycle_flag := 'Y';
	pa_progress_report_utils.get_report_start_end_dates
	  (
	   p_object_type,
	   p_object_id,
           p_report_type_id,
	   l_reporting_cycle_id,
	   l_report_offset_days,

	   'N',
           l_effective_from_date,
	   l_report_start_date,
	   l_report_end_date

	   --	x_return_status               ,
	   --x_msg_count                   ,
	   --x_msg_data
	   );

	--debug_msg('before get dates  end');

	IF (Trunc(l_report_end_date) < Trunc(l_report_start_date)) THEN
	   PA_UTILS.Add_Message( p_app_short_name => 'PA'
				 ,p_msg_name       => 'PA_REPORT_END_DATE_INV');
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   return;
	END IF;
      ELSE
	l_report_cycle_flag := 'N';
	-- not report cycle ID
	l_report_start_date:= Trunc(Sysdate);
	l_report_end_date:= Trunc(Sysdate);
     END IF;


     IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) THEN


	--debug_msg('*********before insert: reported by ' || To_char(fnd_global.user_id));

     /* Get the Reported by Person Id

	   OPEN get_person_id;
	   FETCH get_person_id INTO l_person_id;
	   CLOSE get_person_id; */

           ------OPEN get_resource_id;
           ------FETCH get_resource_id INTO l_person_id;
           ------CLOSE get_resource_id;
           l_person_id := pa_resource_utils.get_resource_id(p_user_id => FND_GLOBAL.user_id);

	--debug_msg ('l_person_id' || To_char(l_person_id));
	pa_progress_report_pkg.insert_PROGRESS_REPORT_ver_row
	  (
	   p_object_id,
	   p_object_type,
	   l_page_id,
	   l_page_type,
	   'PROGRESS_REPORT_WORKING',

	   Trunc(l_report_start_date) ,
	   Trunc(l_report_end_date) ,

	   --fnd_global.user_id ,
	   l_person_id,
	   'PROGRESS_STAT_ON_TRACK',
	   --'PROGRESS_STAT_NOT_STARTED',
	   l_overview,
	   'N',  --- current_flag
	   NULL,
	   NULL,
	   NULL,

           p_report_Type_id,
	   X_version_id,
	   x_return_status,
	   x_msg_count,
	   x_msg_data
	   );
     END IF;


     --debug_msg('before get_last_published_version_id');
     OPEN get_last_published_version_id;

     FETCH get_last_published_version_id INTO l_last_published_version_id;


     IF (get_last_published_version_id%notfound) THEN
	CLOSE get_last_published_version_id;


	-- if it is the first progress report

	--debug_msg ('no published report');

	-- if there is existing published report
	-- copy it, create entries in pa_progress_report_vals table
   /* No need to create an empty region rows if there is no prior publised
      Report - msundare */
       /******************
	 FOR obj_page_value_rec IN get_all_regions_from_template LOOP

	    --debug_msg ('no published report' || obj_page_value_rec.view_region_code);

	        -- debug_msg('insert val' || obj_page_value_rec.view_region_code);
	      pa_progress_report_pkg.insert_progress_report_val_row
		(
		 x_version_id,
		 obj_page_value_rec.region_source_type,
		 obj_page_value_rec.region_source_code,
		 1,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,
		 NULL,

                 NULL, -- uds_attribute_category
                 NULL, -- uds_attribute1
                 NULL, -- uds_attribute2
                 NULL, -- uds_attribute3
                 NULL, -- uds_attribute4
                 NULL, -- uds_attribute5
                 NULL, -- uds_attribute6
                 NULL, -- uds_attribute7
                 NULL, -- uds_attribute8
                 NULL, -- uds_attribute9
                 NULL, -- uds_attribute10
                 NULL, -- uds_attribute11
                 NULL, -- uds_attribute12
                 NULL, -- uds_attribute13
                 NULL, -- uds_attribute14
                 NULL, -- uds_attribute15
                 NULL, -- uds_attribute16
                 NULL, -- uds_attribute17
                 NULL, -- uds_attribute18
                 NULL, -- uds_attribute19
                 NULL, -- uds_attribute20
		 x_return_status    ,
		 x_msg_count        ,
		 x_msg_data
		 );
	 END LOOP;
        *************************/
        null;
      ELSE
	CLOSE get_last_published_version_id;

	-- update the overview field

	OPEN get_publish_overview;
	FETCH get_publish_overview INTO l_overview, l_progress_status_code, l_report_start_date;

	IF (get_publish_overview%found) THEN

	   CLOSE get_publish_overview;

	   -- if there is report cycle ID, report_start and end date are
	   -- already set, we do not need to change it
	   -- set report_start_date to null, so we are not updating the
	   -- vers table

	   --IF l_report_cycle_flag = 'Y' THEN
	   --   l_report_start_date := NULL;
	   -- ELSE

	   --   OPEN get_max_report_end_date;
	   --   FETCH get_max_report_end_date INTO l_report_start_date;
	   --   IF get_max_report_end_date%found THEN
	--	 l_report_start_date := l_report_start_date+1;
	  --     ELSE
	--	 l_report_start_date := sysdate+1;
	 --     END IF;
	   --   CLOSE get_max_report_end_date;


	   --END IF;

	   --debug_msg ('copying overview ' || l_overview);
	   pa_progress_report_pkg.UPDATE_PROGRESS_REPORT_VER_ROW (
							       x_version_id,
							       null,
							       NULL,
							       NULL,
							       NULL,
							       NULL,

							       NULL,
							       NULL,
							       NULL,
							       l_PROGRESS_STATUS_CODE,
							       l_overview,

							       'N',
							       NULL,
							       NULL,
							       NULL,

							       NULL,
							       NULL,
						               p_report_Type_id,
							       x_return_status,
							       x_msg_count     ,
							       x_msg_data
							       ) ;

	 ELSE
	   CLOSE get_publish_overview;
	END IF;


	IF x_return_status = FND_API.g_ret_sts_success then
	--debug_msg ('published report' || To_char(l_last_published_version_id));
	-- if there is existing published report
	-- copy it, create entries in pa_progress_report_vals table
	 FOR obj_page_value_rec IN get_all_regions LOOP

	    --debug_msg ('published report' || obj_page_value_rec.region_code);
	      pa_progress_report_pkg.insert_progress_report_val_row
		(
		 x_version_id,
		 obj_page_value_rec.region_source_type,
		 obj_page_value_rec.region_code,
		 obj_page_value_rec.record_sequence,
		 obj_page_value_rec.ATTRIBUTE1 ,
		 obj_page_value_rec.ATTRIBUTE2 ,
		 obj_page_value_rec.ATTRIBUTE3 ,
		 obj_page_value_rec.ATTRIBUTE4 ,
		 obj_page_value_rec.ATTRIBUTE5 ,
		 obj_page_value_rec.ATTRIBUTE6 ,
		 obj_page_value_rec.ATTRIBUTE7 ,
		 obj_page_value_rec.ATTRIBUTE8 ,
		 obj_page_value_rec.ATTRIBUTE9 ,
		 obj_page_value_rec.ATTRIBUTE10 ,
		 obj_page_value_rec.ATTRIBUTE11 ,
		 obj_page_value_rec.ATTRIBUTE12 ,
		 obj_page_value_rec.ATTRIBUTE13 ,
		 obj_page_value_rec.ATTRIBUTE14 ,
		 obj_page_value_rec.ATTRIBUTE15 ,
		 obj_page_value_rec.ATTRIBUTE16 ,
		 obj_page_value_rec.ATTRIBUTE17 ,
		 obj_page_value_rec.ATTRIBUTE18 ,
		 obj_page_value_rec.ATTRIBUTE19 ,
		 obj_page_value_rec.ATTRIBUTE20 ,
		 obj_page_value_rec.UDS_ATTRIBUTE_CATEGORY ,
                 obj_page_value_rec.UDS_ATTRIBUTE1 ,
                 obj_page_value_rec.UDS_ATTRIBUTE2 ,
                 obj_page_value_rec.UDS_ATTRIBUTE3 ,
                 obj_page_value_rec.UDS_ATTRIBUTE4 ,
                 obj_page_value_rec.UDS_ATTRIBUTE5 ,
                 obj_page_value_rec.UDS_ATTRIBUTE6 ,
                 obj_page_value_rec.UDS_ATTRIBUTE7 ,
                 obj_page_value_rec.UDS_ATTRIBUTE8 ,
                 obj_page_value_rec.UDS_ATTRIBUTE9 ,
                 obj_page_value_rec.UDS_ATTRIBUTE10 ,
                 obj_page_value_rec.UDS_ATTRIBUTE11 ,
                 obj_page_value_rec.UDS_ATTRIBUTE12 ,
                 obj_page_value_rec.UDS_ATTRIBUTE13 ,
                 obj_page_value_rec.UDS_ATTRIBUTE14 ,
                 obj_page_value_rec.UDS_ATTRIBUTE15 ,
                 obj_page_value_rec.UDS_ATTRIBUTE16 ,
                 obj_page_value_rec.UDS_ATTRIBUTE17 ,
                 obj_page_value_rec.UDS_ATTRIBUTE18 ,
                 obj_page_value_rec.UDS_ATTRIBUTE19 ,
                 obj_page_value_rec.UDS_ATTRIBUTE20 ,
		 x_return_status    ,
		 x_msg_count        ,
		 x_msg_data
		 );
	 END LOOP;
	END IF;

     END IF;
  END IF;

  --debug_msg('***end');

  -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;


  IF (x_return_status <> FND_API.g_ret_sts_success  )THEN
     ROLLBACK TO create_next_progress_report;
  END IF;


 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO create_next_progress_report;
        END IF;
        --
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PVT.create_next_progress_report'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs


END create_report;

PROCEDURE update_project_perccomplete
  (
   p_version_id NUMBER,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS

      l_percent_complete number;
      l_sch_start_date DATE;
      l_sch_end_date DATE;
      l_est_start_date DATE;
      l_est_end_date DATE;
      l_act_start_date DATE;
      l_act_end_date DATE;

      l_project_id number;
      l_task_id number;
      l_object_id number;
      l_object_type VARCHAR2(30);
      l_asof_date DATE;



      CURSOR get_percent_complete IS
	 SELECT attribute7 FROM pa_progress_report_vals
	   WHERE version_id = p_version_id
	   AND region_code = 'PA_PROGRESS_PROJECT_DATES';

      CURSOR get_object_info IS
	 SELECT object_id, object_type, report_end_date
	   FROM pa_progress_report_vers
	   WHERE version_id = p_version_id;


      CURSOR get_project_id IS
	 SELECT project_id FROM pa_tasks
	   WHERE task_id = l_task_id;

      CURSOR get_dates IS
	 SELECT scheduled_start_date, scheduled_finish_date,
	   start_date,completion_date,actual_start_date
	   ,actual_finish_date
	   FROM pa_projects_all
	   WHERE project_id = l_project_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PVT.update_project_perccomplete');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT update_project_perccomplete;

  OPEN get_object_info;

  FETCH get_object_info INTO l_object_id, l_object_type, l_asof_date;

  IF get_object_info%notfound THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			   ,p_msg_name       => 'PA_NO_PRJ_REP');
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CLOSE get_object_info;

  IF l_object_type = 'PA_PROJECTS' THEN
     l_project_id := l_object_id;
     l_task_id := 0;
   ELSE
     l_task_id := l_object_id;

     OPEN get_project_id;
     fetch get_project_id INTO l_project_id;
     CLOSE get_project_id;
  END IF;

  --debug_msg ('before get_percent_complete');


  OPEN get_percent_complete;
  FETCH get_percent_complete INTO l_percent_complete;

  --debug_msg ('before get_percent_complete' || To_char(l_percent_complete));

  IF get_percent_complete%notfound THEN
--     PA_UTILS.Add_Message( p_app_short_name => 'PA'
--			   ,p_msg_name       => 'PA_PR_PERCENT_COMPLETE_INV');
--     x_return_status := FND_API.G_RET_STS_ERROR;
     NULL;
     -- todo when perc complete is null, do we update?

   ELSE
     -- todo

     --debug_msg ('before get_percent_complete 2' );
       pa_percent_complete_pkg.insert_row
       (
	l_project_id,
	l_task_id,
	l_percent_complete,
	l_asof_date,
	NULL,
	Sysdate,
	fnd_global.user_id,
	Sysdate,
	fnd_global.user_id,
	fnd_global.user_id,
	x_return_status,
	x_msg_data
	 );

       --debug_msg('x_return_status' || x_return_status);
	-- debug_msg('x_msg_data' || x_msg_data);
	 NULL;

  END IF;

  CLOSE get_percent_complete;

  IF (x_return_status <> FND_API.g_ret_sts_success) THEN

     ROLLBACK TO update_project_perccomplete;
     RETURN;
  END IF;

  -- we need to update the dates from PA_PROJECTS_ALL table
  OPEN get_dates;
  fetch get_dates INTO l_sch_start_date, l_sch_end_date,
    l_est_start_date, l_est_end_date, l_act_start_date,
    l_act_end_date;
  IF get_dates%notfound THEN
     CLOSE get_dates;
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			   ,p_msg_name       => 'PA_PR_DATES_INV');
     x_return_status := FND_API.G_RET_STS_ERROR;

     ROLLBACK TO update_project_perccomplete;
     PA_DEBUG.Reset_Err_Stack;
     RETURN;
  END IF;
  CLOSE get_dates;


  IF l_object_type = 'PA_PROJECTS' THEN

     -- UPDATE pa_progress_report_vals
--	SET
--	attribute1= To_char(l_sch_start_date, 'YYYY-MM-DD')
--	,attribute2= To_char(l_sch_end_date, 'YYYY-MM-DD')
--	,attribute3 = To_char(l_est_start_date, 'YYYY-MM-DD')
--	,attribute4= To_char(l_est_end_date, 'YYYY-MM-DD')
--	,attribute5= To_char(l_act_start_date, 'YYYY-MM-DD')
--	,attribute6= To_char(l_act_end_date, 'YYYY-MM-DD')
--	WHERE version_id = p_version_id
--	AND region_code = 'PA_PROGRESS_PROJECT_DATES';

     NULL;
  END IF;

  IF (x_return_status <> FND_API.g_ret_sts_success) THEN

     ROLLBACK TO update_project_perccomplete;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO update_project_perccomplete;

       --
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_Progress_Report_PVT.update_project_perccomplete'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END update_project_perccomplete;

/*
     Bug 3684164. This API is called when the user updates a status
     report page layout. If any sections have been deleted, this API
     would take care of deleting the data from the working and rejected
     status report versions using this page layout.
*/
PROCEDURE delete_version_data
   (
     p_page_id                 IN     pa_page_layouts.page_id%TYPE
    ,p_region_source_type_tbl  IN     SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_region_code_tbl         IN     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
    ,p_region_source_code_tbl  IN     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
    ,x_return_status           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_return_status                 VARCHAR2(1);
l_debug_mode                    VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_debug_level                   NUMBER;

/*
   This cursor fetches all non mandatory regions selected currently for this page
   Currently data can be associated only for the regions of style STD,
   STD_CUST and DFF. So this cursor will fetch only these regions.
*/
cursor c_page_layout_regions(c_page_id pa_page_layouts.page_id%TYPE)
is
select
   layout.region_source_type,
   layout.view_region_code,
   layout.region_source_code
from pa_page_layout_regions layout, pa_page_type_regions type
where layout.page_id = c_page_id
and layout.region_source_type in ('STD','STD_CUST','DFF')
and type.page_type_code = 'PPR'
and type.region_source_type = layout.region_source_type
and type.region_source_code = decode(layout.region_source_type,'STD_CUST',layout.view_region_code,layout.region_source_code)
and nvl(layout.region_style, 'N') <> 'LINK'
and type.mandatory_flag = 'N';

Type region_source_type_tbl_typ  is table of pa_page_layout_regions.region_source_type%TYPE  index by binary_integer;
Type view_region_code_tbl_typ  is table of   pa_page_layout_regions.view_region_code%TYPE  index by binary_integer;
Type region_source_code_tbl_typ  is table of pa_page_layout_regions.region_source_code%TYPE  index by binary_integer;

l_region_source_type_tbl  region_source_type_tbl_typ;
l_view_region_code_tbl    view_region_code_tbl_typ;
l_region_source_code_tbl  region_source_code_tbl_typ;

l_found boolean;
j number;
l_temp_region_src_code  pa_page_layout_regions.region_source_code%TYPE;
l_module_name varchar2(100) := 'PA_PROGRESS_REPORT_PVT';

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_PROGRESS_REPORT_PVT.delete_version_data');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      fnd_profile.get('AFLOG_LEVEL',l_debug_level);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      if nvl(l_debug_mode,'N') = 'N' then
          --if debug is not enabled, set the level to a higher level
          l_debug_level := 10;
      end if;

      open c_page_layout_regions(p_page_id);
      fetch c_page_layout_regions
      bulk collect into l_region_source_type_tbl, l_view_region_code_tbl, l_region_source_code_tbl;
      close c_page_layout_regions;

      if (l_debug_level <= 3) then
          pa_debug.g_err_stage := 'number of records fetched :'||l_region_source_type_tbl.count;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      end if;
      --If no records exist for the page layout do nothing and return.
      if(nvl(l_region_source_type_tbl.count,0) = 0) then
          return;
      end if;
      --Loop through the fetched records. If any of the record is not
      --available in the passed in record, delete the corresponding records
      --from the status report versions data table.
      for i in 1..l_region_source_type_tbl.count loop
          l_found := false;
          j := 1;
          if (l_debug_level <= 3) then
              pa_debug.g_err_stage := 'fetched source type:'||l_region_source_type_tbl(i);
              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
              pa_debug.g_err_stage := 'fetched region code:'||l_view_region_code_tbl(i);
              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
              pa_debug.g_err_stage := 'fetched region source code:'||l_region_source_code_tbl(i);
              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
          end if;
          while l_found = false and j <= p_region_source_type_tbl.count loop
               if (l_debug_level <= 3) then
                   pa_debug.g_err_stage := 'passed source type:'||p_region_source_type_tbl(j);
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                   pa_debug.g_err_stage := 'passed region code:'||p_region_code_tbl(j);
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                   pa_debug.g_err_stage := 'passed region source code:'||p_region_source_code_tbl(j);
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
               end if;
               if p_region_source_type_tbl(j) = 'STD_CUST' then
                    l_temp_region_src_code := p_region_code_tbl(j) || ':' || p_region_source_code_tbl(j);
               else
                    l_temp_region_src_code := p_region_source_code_tbl(j);
               end if;

               if( l_region_source_type_tbl(i)  = p_region_source_type_tbl(j) and
                   l_view_region_code_tbl(i)    = p_region_code_tbl(j) and
                   l_region_source_code_tbl(i)  = l_temp_region_src_code
                 ) then
                    if (l_debug_level <= 3) then
                        pa_debug.g_err_stage := 'found the above region';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                    end if;
                    l_found := true;
                end if;
                j := j + 1;
          end loop;

          --If the above region was not found, then we need to delete any usage of this region of this page
          --in the status reports. For STD_CUST sections the region code is stored as <_oracle_apps..._viewid>
          if l_found = false then
              l_temp_region_src_code := null;
              if l_region_source_type_tbl(i) = 'STD_CUST' then
                    l_temp_region_src_code := replace(l_region_source_code_tbl(i),'/','_');
                    l_temp_region_src_code := replace(l_temp_region_src_code,':','_');
              else
                    l_temp_region_src_code := l_region_source_code_tbl(i);
              end if;

              if (l_debug_level <= 3) then
                   pa_debug.g_err_stage := 'l_temp_region_src_code :'||l_temp_region_src_code;
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
              end if;

              delete from pa_progress_report_vals
              where region_code = l_temp_region_src_code
                and region_source_type = l_region_source_type_tbl(i)
                and version_id in
                    (select version_id
                     from pa_progress_report_vers
                     where page_id = p_page_id
                     and report_status_code in ('PROGRESS_REPORT_WORKING','PROGRESS_REPORT_REJECTED'));
          end if;
      end loop;

      pa_debug.reset_err_stack;
  EXCEPTION
      WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_PROGRESS_REPORT_PVT'
                                  ,p_procedure_name  => 'delete_version_data');
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          pa_debug.reset_err_stack;
          RAISE;
END delete_version_data;

END  PA_PROGRESS_REPORT_PVT;


/
