--------------------------------------------------------
--  DDL for Package Body PA_CI_IMPACT_TYPE_USAGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_IMPACT_TYPE_USAGE_PUB" AS
/* $Header: PACIIMPB.pls 120.0.12010000.2 2009/06/08 18:42:24 cklee ship $ */

PROCEDURE create_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_impact_type_code IN VARCHAR2  := null,
  p_ci_type_class_code IN VARCHAR2  := null,
  p_CI_TYPE_ID in NUMBER := null,

  p_created_by			IN NUMBER DEFAULT fnd_global.user_id,
  p_creation_date		IN DATE DEFAULT SYSDATE,
  p_last_update_login		IN NUMBER DEFAULT fnd_global.login_id,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

  x_ci_impact_type_usage_id		OUT NOCOPY NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS

   l_msg_index_out        NUMBER;

BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACT_TYPE_USAGE_PUB.CREATE_CI_IMPACT_TYPE_USAGE');

  IF p_commit = 'T' THEN
    SAVEPOINT create_ci_impact_type_usage;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
    PA_CI_IMPACT_TYPE_USAGE_pvt.create_ci_impact_type_usage(
     p_api_version             => p_api_version,
     p_init_msg_list           => p_init_msg_list,
     p_commit                  => p_commit,
     p_validate_only           => p_validate_only,
     p_max_msg_count           => p_max_msg_count,

      p_impact_type_code => p_impact_type_code,
      p_ci_type_class_code => p_ci_type_class_code,
      p_ci_type_id => p_ci_type_id,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_IMPACT_TYPE_CODE_ORDER => P_IMPACT_TYPE_CODE_ORDER,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
      x_ci_impact_type_usage_id => x_ci_impact_type_usage_id,

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
      ROLLBACK TO create_ci_impact_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACT_TYPE_USAGE_PUB',
                            p_procedure_name => 'CREATE_CI_IMPACT_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END create_ci_impact_type_usage;

--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

PROCEDURE update_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ci_impact_type_usage_id	IN NUMBER,
  P_IMPACT_TYPE_CODE_ORDER IN NUMBER,

  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
   l_msg_index_out        NUMBER;

BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACT_TYPE_USAGE_PUB.UPDATE_CI_IMPACT_TYPE_USAGE');

  IF p_commit = 'T' THEN
    SAVEPOINT update_ci_impact_type_usage;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
    PA_CI_IMPACT_TYPE_USAGE_pvt.update_ci_impact_type_usage(
     p_api_version             => p_api_version,
     p_init_msg_list           => p_init_msg_list,
     p_commit                  => p_commit,
     p_validate_only           => p_validate_only,
     p_max_msg_count           => p_max_msg_count,

     P_IMPACT_TYPE_CODE_ORDER => P_IMPACT_TYPE_CODE_ORDER,
     p_ci_impact_type_usage_id => p_ci_impact_type_usage_id,

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
      ROLLBACK TO create_ci_impact_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACT_TYPE_USAGE_PUB',
                            p_procedure_name => 'UPDATE_CI_IMPACT_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END update_ci_impact_type_usage;

--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement


PROCEDURE delete_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ci_impact_type_usage_id	IN NUMBER := null,
  p_impact_type_code            IN VARCHAR2 := null,
  p_ci_type_class_code          IN VARCHAR2 := null,
  p_ci_type_id                  IN NUMBER := null,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
 x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
  IS
     l_msg_index_out        NUMBER;
     l_temp VARCHAR2(1);
BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACT_TYPE_USAGE_PUB.DELETE_CI_IMPACT_TYPE_USAGE');

  IF p_commit = 'T' THEN
    SAVEPOINT delete_ci_impact_type_usage;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  -- Trying to lock the record
  PA_CI_IMPACT_TYPE_USAGE_pvt.delete_ci_impact_type_usage (
     p_api_version             => p_api_version,
     p_init_msg_list           => p_init_msg_list,
     p_commit                  => p_commit,
     p_validate_only           => p_validate_only,
     p_max_msg_count           => p_max_msg_count,

     p_ci_impact_type_usage_id => p_ci_impact_type_usage_id,
     p_impact_type_code => p_impact_type_code,
     p_ci_type_class_code => p_ci_type_class_code,
     p_ci_type_id => p_ci_type_id,
  --start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_IMPACT_TYPE_CODE_ORDER => P_IMPACT_TYPE_CODE_ORDER,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
   x_return_status           => x_return_status,
     x_msg_count               => x_msg_count,
     x_msg_data                => x_msg_data

					  );
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
      ROLLBACK TO delete_ci_impact_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACT_TYPES_PUB',
                            p_procedure_name => 'DELETE_CI_IMPACT_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_ci_impact_type_usage;


FUNCTION delete_impact_type_usage_ok
  (
   p_impact_type_code            IN VARCHAR2 ,
   p_ci_type_id                  IN NUMBER
   ) RETURN varchar2
  IS
     l_dummy VARCHAR2(1);

BEGIN


   SELECT 'N'
     INTO l_dummy
     FROM dual
     WHERE exists (Select pci.ci_id from
		   pa_control_items  pci,
		   pa_ci_impacts pc
		   where pci.ci_type_id = p_ci_type_id
		   and pci.ci_id = pc.ci_id
		   and pc.impact_type_code = p_impact_type_code
		   );

   RETURN l_dummy;
EXCEPTION


   WHEN NO_DATA_FOUND THEN

      RETURN 'Y';

END ;

END PA_CI_IMPACT_TYPE_USAGE_PUB;

/
