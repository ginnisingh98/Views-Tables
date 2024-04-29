--------------------------------------------------------
--  DDL for Package Body PA_CI_IMPACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_IMPACTS_PUB" AS
/* $Header: PACIIPPB.pls 120.0 2005/05/29 13:25:23 appldev noship $ */

PROCEDURE create_ci_impact (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ci_id IN NUMBER := null,
  p_impact_type_code IN VARCHAR2  := null,

  p_status_code IN VARCHAR2  := null,
  p_description IN VARCHAR2  := null,
  p_implementation_date IN DATE := null,
  p_implemented_by IN NUMBER := NULL,
  p_implementation_comment IN VARCHAR2 := null,
  p_impacted_task_id IN NUMBER := NULL,
  p_impacted_task_name IN VARCHAR2  := NULL,


  x_ci_impact_id		OUT NOCOPY NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
  IS
     l_msg_index_out        NUMBER;
     l_rowid VARCHAR2(30);
     l_task_id NUMBER;

     CURSOR get_task_id
       IS
	  select pt.task_id from pa_tasks pt,
	    pa_control_items pc
	    where pt.project_id = pc.project_id
	    and pt.task_name = p_impacted_task_name
	    AND pc.ci_id = p_ci_id;

BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACTS_PUB.CREATE_CI_IMPACTS');

  IF p_commit = 'T' THEN
    SAVEPOINT create_ci_impact;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_impacted_task_name IS NOT NULL THEN
     OPEN get_task_id;
     FETCH get_task_id INTO l_task_id;
     IF get_task_id%notfound THEN

	-- record already exists
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_TASK_NAME_INVALID');

        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     CLOSE get_task_id;     --Bug 3868121

   ELSE
     l_task_id := p_impacted_task_id;

  END IF;


  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN

     PA_CI_IMPACTS_pvt.create_ci_impact(
     p_api_version             => p_api_version,
     p_init_msg_list           => p_init_msg_list,
     p_commit                  => p_commit,
     p_validate_only           => p_validate_only,
     p_max_msg_count           => p_max_msg_count,

      p_ci_id => p_ci_id,
      p_impact_type_code => p_impact_type_code,
      p_status_code => p_status_code,
      p_description => p_description,
      p_implementation_date => p_implementation_date,
      p_implemented_by => p_implemented_by,
      p_implementation_comment => p_implementation_comment,
      p_impacted_task_id => l_task_id,
      x_ci_impact_id => x_ci_impact_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
				       );
  END IF;
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => 'T'
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = 'T' THEN
      ROLLBACK TO create_ci_impact;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACTS_PUB',
                            p_procedure_name => 'CREATE_CI_IMPACT',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END create_ci_impact;

PROCEDURE delete_ci_impact (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ci_impact_id	        IN NUMBER := null,
  p_record_version_number       IN NUMBER :=  null,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
   l_temp VARCHAR2(1);
   l_msg_index_out        NUMBER;
BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACTS_PUB.DELETE_CI_IMPACT');

  IF p_commit = 'T' THEN
    SAVEPOINT delete_ci_impact;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  -- Trying to lock the record

  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
     PA_CI_IMPACTS_pvt.delete_ci_impact(
				p_api_version             => p_api_version,
                                p_init_msg_list           => p_init_msg_list,
                                p_commit                  => p_commit,
                                p_validate_only           => p_validate_only,
                                p_max_msg_count           => p_max_msg_count,
				p_ci_impact_id => p_ci_impact_id,
				p_record_version_number => p_record_version_number,
                                x_return_status           => x_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data

					);
  END IF;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => 'T'
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;


  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = 'T' THEN
      ROLLBACK TO delete_ci_impact;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACT',
                            p_procedure_name => 'DELETE_CI_IMPACT',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_ci_impact;

PROCEDURE update_ci_impact (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,
  p_ci_impact_id		IN  NUMBER:= null,
  p_ci_id IN NUMBER := null,
  p_impact_type_code IN VARCHAR2  := null,
  p_status_code IN VARCHAR2  := null,
  p_description IN VARCHAR2   := FND_API.g_miss_char,
  p_implementation_date IN DATE := FND_API.g_miss_date,
  p_implemented_by IN NUMBER := FND_API.g_miss_num,
  p_impby_name IN VARCHAR2 := NULL,
  p_impby_type_id IN NUMBER := null,
  p_implementation_comment IN VARCHAR2 := FND_API.g_miss_char,
  p_record_version_number       IN NUMBER :=  null,
  p_impacted_task_id IN NUMBER := FND_API.g_miss_num,
  p_impacted_task_name IN VARCHAR2  := NULL,

  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
			    ) IS
   l_rowid VARCHAR2(30);
   l_msg_index_out        NUMBER;
   l_task_id NUMBER;

   l_description VARCHAR2(4000) ;
   l_implementation_date DATE ;
   l_implemented_by NUMBER;
   l_implementation_comment VARCHAR2(4000);



   CURSOR get_task_id
     IS
	select pt.task_id from pa_tasks pt,
	  pa_control_items pc
	  where pt.project_id = pc.project_id
	  and pt.task_name = p_impacted_task_name
	  AND pc.ci_id = p_ci_id;

   CURSOR get_ci_info
     IS
	SELECT * FROM pa_ci_impacts
	  WHERE ci_impact_id = p_ci_impact_id;

BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACTS_PUB.CREATE_CI_IMPACTS');

  IF p_commit = 'T' THEN
    SAVEPOINT update_ci_impact;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_impacted_task_name IS NOT NULL THEN
     OPEN get_task_id;
     FETCH get_task_id INTO l_task_id;
     IF get_task_id%notfound THEN

	-- record already exists
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_TASK_NAME_INVALID');

        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     CLOSE get_task_id;  --Bug 3868121
   ELSE
     l_task_id := p_impacted_task_id;

  END IF;
  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
      l_description := p_description ;
      l_implementation_date := p_implementation_date;
      l_implemented_by := p_implemented_by;
      l_implementation_comment := p_implementation_comment;



      FOR rec IN get_ci_info LOOP
	 IF p_description = FND_API.g_miss_char then
	    l_description := rec.description ;
	 END IF;

	 IF p_implementation_date = FND_API.g_miss_date then
	    l_implementation_date := rec.implementation_date;
	 END IF;

	 IF p_implemented_by = FND_API.g_miss_num  AND p_impby_name IS NULL then
	    l_implemented_by := rec.implemented_by;
	 END IF;

	 IF p_implementation_comment = FND_API.g_miss_char then
	    l_implementation_comment := rec.implementation_comment;
	 END IF;

	 IF p_impacted_task_id = FND_API.g_miss_num
	   AND p_impacted_task_name IS NULL then
	    l_task_id := rec.impacted_task_id;
	 END IF;


	 PA_CI_IMPACTS_pvt.update_ci_impact(
				p_api_version             => p_api_version,
                                p_init_msg_list           => p_init_msg_list,
                                p_commit                  => p_commit,
                                p_validate_only           => p_validate_only,
                                p_max_msg_count           => p_max_msg_count,
      p_ci_impact_id => p_ci_impact_id,
      p_ci_id => p_ci_id,
      p_impact_type_code => p_impact_type_code,
      p_status_code => p_status_code,
      p_description => l_description,
      p_implementation_date => l_implementation_date,
      p_implemented_by => l_implemented_by,
      p_impby_name => p_impby_name,
      p_impby_type_id => p_impby_type_id,
      p_implementation_comment => l_implementation_comment,
      p_record_version_number => p_record_version_number,
      p_impacted_task_id => l_task_id,
				x_return_status           => x_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data

      );
     END LOOP;


  END IF;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => 'T'
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;


  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
   WHEN no_data_found THEN
    IF p_commit = 'T' THEN
      ROLLBACK TO update_ci_impact;
    END IF;

    PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
    x_return_status := FND_API.G_RET_STS_ERROR;


  WHEN OTHERS THEN
    IF p_commit = 'T' THEN
      ROLLBACK TO update_ci_impact;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACTS_PUB',
                            p_procedure_name => 'UPDATE_CI_IMPACT',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END update_ci_impact;

END PA_CI_IMPACTS_pub;

/
