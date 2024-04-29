--------------------------------------------------------
--  DDL for Package Body PA_CI_IMPACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_IMPACTS_PVT" AS
/* $Header: PACIIPVB.pls 120.1 2005/08/02 03:58:29 raluthra noship $ */

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
  p_implemented_by IN NUMBER := null,
  p_implementation_comment IN VARCHAR2 := null,
  p_impacted_task_id IN NUMBER := null,

  x_ci_impact_id		OUT NOCOPY NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
   l_rowid VARCHAR2(30);


   CURSOR check_exists is
     SELECT 'Y' FROM dual
     WHERE exists (SELECT ci_impact_id FROM
		   pa_ci_impacts
		   WHERE
		   ci_id = p_ci_id
		   AND impact_type_code = p_impact_type_code);

   l_dummy VARCHAR2(1);

BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACTS_PVT.CREATE_CI_IMPACTS');

  IF p_commit = 'T' THEN
    SAVEPOINT create_ci_impact;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  OPEN check_exists;
  FETCH check_exists INTO l_dummy;
  IF check_exists%found THEN
     -- record already exists
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CI_IMPACT_EXIST');

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;
  CLOSE check_exists;

  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
    PA_CI_IMPACTS_pkg.insert_row(
      x_rowid => l_rowid,
      x_ci_impact_id => x_ci_impact_id,
      x_ci_id => p_ci_id,
      x_impact_type_code => p_impact_type_code,
      x_status_code => p_status_code,
      x_description => p_description,
      x_implementation_date => p_implementation_date,
      x_implemented_by => p_implemented_by,
      x_implementation_comment => p_implementation_comment,
      x_impacted_task_id => p_impacted_task_id,
      x_creation_date => sysdate,
      x_created_by => fnd_global.user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => fnd_global.user_id,
      x_last_update_login => fnd_global.login_id);
  END IF;

  IF p_commit = 'T' THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO create_ci_impact;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = 'T' THEN
      ROLLBACK TO create_ci_impact;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACTS_PVT',
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
BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACTS_PVT.DELETE_CI_IMPACT');

  IF p_commit = 'T' THEN
    SAVEPOINT delete_ci_impact;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  -- check if it is OK to delete
  pa_ci_impacts_util.is_delete_impact_ok
    (
     p_ci_impact_id,
     x_return_status		,
     x_msg_count			,
     x_msg_data
     );

  IF x_return_status = 'S' then
  -- Trying to lock the record
/*  PA_CI_IMPACTS_pkg.lock_row (
    x_ci_impact_id => p_ci_impact_id,
    x_impact_type_code => p_impact_type_code,
    x_record_version_number => p_record_version_number,
     x_ci_id => p_ci_id);*/

  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
    PA_CI_IMPACTS_pkg.delete_row(
				 x_ci_impact_id => p_ci_impact_id,
				 x_record_version_number => p_record_version_number
				 );
  END IF;

  END IF;

  IF p_commit = 'T' THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO delete_ci_impact;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

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
  p_description IN VARCHAR2  := null,
  p_implementation_date IN DATE := null,
  p_implemented_by IN NUMBER := null,
  p_impby_name IN VARCHAR2 := null,
  p_impby_type_id IN NUMBER := null,
  p_implementation_comment IN VARCHAR2 := null,
  p_record_version_number       IN NUMBER :=  null,
  p_impacted_task_id IN NUMBER := null,

  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
   l_rowid VARCHAR2(30);
   l_party_id NUMBER;
   l_impact_name VARCHAR2(80);

   CURSOR get_internal_party_id
     IS
	select hp.party_id from fnd_user fu,
	  hz_parties hp
	  where
	  user_id = FND_GLOBAL.user_id
	  and employee_id is not null
	    and hp.orig_system_reference = 'PER:' || fu.employee_id;


   CURSOR get_external_party_id
     IS
	       select hp.party_id from fnd_user fu,
		 hz_parties hp
		 where
		 user_id = FND_GLOBAL.user_id
		 and employee_id is null
		   and hp.party_id =  fu.person_party_id; -- fu.customer_id; Changed for Bug 4527617

   CURSOR get_party_id is
      SELECT party_id FROM
		   hz_parties
		     WHERE party_name = p_impby_name;


   CURSOR get_impact_name
     IS SELECT pl.meaning
       FROM pa_lookups pl
       WHERE p_impact_type_code = pl.lookup_code
       and pl.lookup_type = 'PA_CI_IMPACT_TYPES';

BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACTS_PVT.UPDATE_CI_IMPACTS');

  IF p_commit = 'T' THEN
    SAVEPOINT update_ci_impact;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

   OPEN get_impact_name;
   FETCH get_impact_name INTO l_impact_name;
   CLOSE get_impact_name;

--   debug_msg_s1 ('p_implemented_by = ' ||p_implemented_by);
--   debug_msg_s1 ('p_implemented_by = ' ||p_impby_name);

   IF p_implemented_by = 0 THEN
      IF  p_impby_name IS NULL THEN
     -- we need to use the FND_GLOBAL.user_id;
     OPEN get_internal_party_id;
     FETCH get_internal_party_id INTO l_party_id;
     IF get_internal_party_id%notfound THEN
	CLOSE get_internal_party_id;
	OPEN get_external_party_id;
	FETCH get_external_party_id INTO l_party_id;
	CLOSE get_internal_party_id;

      ELSE
	CLOSE get_internal_party_id;
     END IF;
       ELSE
	 -- the implemented by is passed in, we need to get the ID
	OPEN get_party_id;
	FETCH get_party_id INTO l_party_id;
	IF get_party_id%notfound THEN
	   PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_CI_IMPACT_IMPBY_INV');
				   -- p_token1 => 'IMPACT_TYPE'
			  --, p_value1 => l_impact_name);
				  x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	CLOSE get_party_id;

      END IF;


   ELSE
     IF p_impby_name IS NULL then
	l_party_id := p_implemented_by;
      ELSE
	-- the implemented by is passed in, we need to get the ID
	OPEN get_party_id;
	FETCH get_party_id INTO l_party_id;
	IF get_party_id%notfound THEN
	   PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_CI_IMPACT_IMPBY_INV');
				--    p_token1 => 'IMPACT_TYPE'
			 -- , p_value1 => l_impact_name);
				  x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	CLOSE get_party_id;

     END IF;

  END IF;


  IF (p_implementation_date > Sysdate) THEN


     PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_CI_IMPACT_IMP_DATE_INV');
			 --     p_token1 => 'IMPACT_TYPE'
			    --, p_value1 => l_impact_name

     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
    PA_CI_IMPACTS_pkg.update_row(
      x_ci_impact_id => p_ci_impact_id,
      x_ci_id => p_ci_id,
      x_impact_type_code => p_impact_type_code,
      x_status_code => p_status_code,
      x_description => p_description,
      x_implementation_date => p_implementation_date,
      x_implemented_by => l_party_id,
      x_implementation_comment => p_implementation_comment,
      x_record_version_number => p_record_version_number,
      x_impacted_task_id => p_impacted_task_id,
      x_last_update_date => sysdate,
      x_last_updated_by => fnd_global.user_id,
      x_last_update_login => fnd_global.login_id	 );

  END IF;

  IF p_commit = 'T' THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO update_ci_impact;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

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
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACTS_PVT',
                            p_procedure_name => 'UPDATE_CI_IMPACT',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END update_ci_impact;

END PA_CI_IMPACTS_pvt;

/
