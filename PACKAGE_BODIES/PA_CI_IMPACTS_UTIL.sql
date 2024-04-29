--------------------------------------------------------
--  DDL for Package Body PA_CI_IMPACTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_IMPACTS_UTIL" AS
/* $Header: PACIIPUB.pls 120.1.12010000.5 2010/06/22 12:05:41 racheruv ship $ */

function is_any_impact_implemented (
  p_ci_id IN NUMBER := null
) RETURN boolean
IS
   l_temp VARCHAR2(1);


BEGIN
   SELECT 'X'
     INTO l_temp from dual
     WHERE exists(
		  SELECT ci_impact_id
		  FROM pa_ci_impacts
		  WHERE ci_id = p_ci_id
		  AND (implementation_date IS NOT NULL
		       OR implemented_by IS NOT NULL));

   RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;

END is_any_impact_implemented;


function is_render_true (
			 impact_type_code IN VARCHAR2,
			 project_id IN NUMBER :=  null
) RETURN varchar2
  IS
     l_ret  VARCHAR2(1) := 'Y';

BEGIN

   IF impact_type_code = 'FINPLAN' THEN
      l_ret:= pa_fp_control_items_utils.Is_Financial_Planning_Allowed(project_id);

   END IF;

   RETURN l_ret;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';

END ;


function is_impact_implemented (
				p_ci_id IN NUMBER ,
				p_impact_type_code IN VARCHAR2
) RETURN boolean
IS
   l_temp VARCHAR2(1);


BEGIN
   SELECT 'X'
     INTO l_temp from dual
     WHERE exists(
		  SELECT ci_impact_id
		  FROM pa_ci_impacts
		  WHERE ci_id = p_ci_id
		  AND (implementation_date IS NOT NULL
		       OR implemented_by IS NOT NULL)
		  AND impact_type_code = p_impact_type_code);

   RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;

END is_impact_implemented;

function is_impact_exist (
				p_ci_id IN NUMBER ,
				p_impact_type_code IN VARCHAR2
) RETURN boolean
IS
   l_temp VARCHAR2(1);


BEGIN
   SELECT 'X'
     INTO l_temp from dual
     WHERE exists(
		  SELECT ci_impact_id
		  FROM pa_ci_impacts
		  WHERE ci_id = p_ci_id
		  AND impact_type_code = p_impact_type_code);

   RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;

END is_impact_exist;

function is_all_impact_implemented (
				p_ci_id IN NUMBER
				) RETURN boolean
IS
   l_temp VARCHAR2(1);


BEGIN
   SELECT 'X'
     INTO l_temp from dual
     WHERE exists(
		  SELECT ci_impact_id
		  FROM pa_ci_impacts
		  WHERE ci_id = p_ci_id
		  AND (implementation_date IS NULL
		       OR implemented_by IS NULL)
                  AND impact_type_code <> 'FINPLAN'  /* Bug 4153868 */
		  );

   RETURN FALSE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN TRUE;

END is_all_impact_implemented;



procedure delete_all_impacts
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := 'T',
   p_commit                      IN     VARCHAR2 := 'F',
   p_validate_only               IN     VARCHAR2 := 'T',
   p_max_msg_count               IN     NUMBER := null,

   p_ci_id IN NUMBER,
   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2
)
  IS
BEGIN
    -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('Pa_ci_impacts_util.delete_all_impacts');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

   IF (p_validate_only = 'F') THEN
      DELETE FROM pa_ci_impacts
	WHERE ci_id = p_ci_id;
   END IF;

    -- Commit if the flag is set and there is no error
  IF (p_commit = 'T' AND x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


END delete_all_impacts;

procedure copy_impact
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := 'T',
   p_commit                      IN     VARCHAR2 := 'F',
   p_validate_only               IN     VARCHAR2 := 'T',
   p_max_msg_count               IN     NUMBER := null,

   p_dest_ci_id IN NUMBER,
   p_source_ci_id IN NUMBER,
   p_include_flag IN VARCHAR2,
   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2
)
  IS
     l_impact_type_code VARCHAR2(30);
     l_desp VARCHAR2(4000);
     l_comment VARCHAR2(4000);
     l_ci_impact_id NUMBER;
     l_implementation_date DATE;
     l_implemented_by NUMBER;
     l_record_ver_number NUMBER;
     l_temp VARCHAR2(1);
     l_project_id pa_budget_versions.project_id%TYPE;
     l_src_project_id pa_budget_versions.project_id%TYPE;

     l_source PA_PLSQL_DATATYPES.idtabtyp;

     -- get copy from CI impacts
     -- Bug 3677924 Jul 07 2004 Raja
     -- Modified the cursor such that finplan impact records are not selected
     -- And also an impact record is selected only if destination ci type allows
     -- the impact to be created
     CURSOR get_include_impact_info
       IS
	  SELECT sourceImpacts.*
      FROM   pa_ci_impacts sourceImpacts,
             pa_control_items targetCi,
             pa_ci_impact_type_usage targetUsage
      WHERE  sourceImpacts.ci_id = p_source_ci_id
        AND  sourceImpacts.impact_type_code NOT IN ('FINPLAN_COST','FINPLAN_REVENUE','FINPLAN')
        AND  targetCi.ci_id = p_dest_ci_id
        AND  targetCi.ci_type_id = targetUsage.ci_type_id
        AND  targetUsage.impact_type_code = sourceImpacts.impact_type_code;

     -- Bug 9693010: to populate the source impacts for target
     CURSOR get_impact_info
       IS
	  SELECT sourceImpacts.*
      FROM   pa_ci_impacts sourceImpacts,
             pa_control_items sourceCi,
             pa_control_items targetCi
      WHERE  sourceImpacts.ci_id = p_source_ci_id
        and  sourceImpacts.impact_type_code in ('FINPLAN', 'FINPLAN_REVENUE')
        and  sourceImpacts.ci_id = sourceCi.ci_id
        and  targetCi.ci_id = p_dest_ci_id
        and  sourceCi.ci_type_id = targetCi.ci_type_id;

     -- get the copy to CI impacts
     CURSOR get_orig_info
       is
       SELECT ci_impact_id, description, implementation_comment,
       implementation_date, implemented_by, record_version_number, impacted_task_id
       FROM pa_ci_impacts
       WHERE ci_id = p_dest_ci_id
       AND impact_type_code = l_impact_type_code;

     CURSOR is_ok_to_copy
       IS
	  select 'N' from dual
	    where exists
	    (
	     select ci_impact_id from pa_ci_impacts pci
	     where pci.ci_id = p_source_ci_id
	       and pci.impact_type_code <> 'FINPLAN'  /* Bug 3724520 */
               and pci.impact_type_code <> 'SUPPLIER'
	     and not exists
	     (
	      select * from
	      pa_control_items pci2,
	      pa_ci_impact_type_usage pcit
	      where    pci2.ci_type_id = pcit.ci_type_id
	      AND pci2.ci_id = p_dest_ci_id
	      and pcit.impact_type_code = pci.impact_type_code
	      )
	     );

     CURSOR get_project_id is
       select project_id from pa_control_items pci
       where
       pci.ci_id = p_dest_ci_id;

      CURSOR get_src_project_id is
       select project_id from pa_control_items pci
       where
       pci.ci_id = p_source_ci_id;

     l_rowid VARCHAR(100);
     l_new_ci_impact_id NUMBER;
     l_task_id NUMBER;

     -- talked to Selva, the warning flag is ignored for now
     l_warning_flag VARCHAR2(20);

     l_temp2 VARCHAR2(4000);
     l_ret VARCHAR2(1) := 'Y';

BEGIN
    -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('Pa_ci_impacts_util.copy_impact');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF p_include_flag = 'Y' THEN
     -- in the case of including impact
     -- we can not include the source impact if the it has
     -- more impact type region
     -- then the ones allowed in the dest impact
  OPEN is_ok_to_copy;
  FETCH is_ok_to_copy INTO l_temp;
  IF is_ok_to_copy%found THEN
     -- can not copy
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CI_NO_IMP_INCLUDE_TYPE');

     x_return_status := FND_API.G_RET_STS_ERROR;

     CLOSE is_ok_to_copy;
     RETURN;

  END IF;
  CLOSE is_ok_to_copy;
  END IF;

  IF (p_validate_only = 'F') THEN

  -- Bug 9693010: populate the target impact from source
  -- to the target.
  -- start of change.

    FOR rec IN get_impact_info LOOP
	  l_impact_type_code := rec.impact_type_code;
	  OPEN get_orig_info;
	  FETCH get_orig_info INTO l_ci_impact_id, l_desp, l_comment,
	    l_implementation_date, l_implemented_by, l_record_ver_number, l_task_id;

	  IF get_orig_info%notfound THEN
	     -- insert a new record to the new impact
	     pa_ci_impacts_pkg.insert_row(
				     l_rowid,
				     l_new_ci_impact_id,
				     p_dest_ci_id,
				     rec.impact_type_code,
				     'CI_IMPACT_PENDING',
				     rec.description,
				     NULL,
				     NULL,
					 NULL,
					 rec.impacted_task_id,
				     sysdate,
				     fnd_global.user_id,
				     Sysdate,
				     fnd_global.user_id,
	                 fnd_global.login_id
					);
	   ELSE
	     l_temp2 := Substr(l_desp || ' ' || rec.description, 1, 4000);

	     -- update the existing one
	     pa_ci_impacts_pkg.update_row(
				     l_ci_impact_id,
				     p_dest_ci_id,
				     l_impact_type_code,
				     NULL,
				     l_temp2,
				     l_implementation_date,
				     l_implemented_by,
				     l_comment,
				     Nvl(l_task_id, rec.impacted_task_id),
				     sysdate,
	                 fnd_global.user_id,
	                 fnd_global.login_id,
				     l_record_ver_number
					);
	   END IF;

	   CLOSE get_orig_info;
     END loop;

     -- end of changes for 9693010

     FOR rec IN get_include_impact_info LOOP
	l_impact_type_code := rec.impact_type_code;
	OPEN get_orig_info;
	FETCH get_orig_info INTO l_ci_impact_id, l_desp, l_comment,
	  l_implementation_date, l_implemented_by, l_record_ver_number, l_task_id;

	IF get_orig_info%notfound THEN
	   -- insert a new record to the new impact
	   pa_ci_impacts_pkg.insert_row(
				     l_rowid,
				     l_new_ci_impact_id,
				     p_dest_ci_id,
				     rec.impact_type_code,
				     'CI_IMPACT_PENDING',
				     rec.description,
				     NULL,
				     NULL,
					NULL,
					rec.impacted_task_id,
				     sysdate,
				     fnd_global.user_id,
				     Sysdate,
				     fnd_global.user_id,
	                             fnd_global.login_id
					);
	 ELSE
	   l_temp2 := Substr(l_desp || ' ' || rec.description, 1, 4000);

	   -- update the existing one
	   pa_ci_impacts_pkg.update_row(
				     l_ci_impact_id,
				     p_dest_ci_id,
				     l_impact_type_code,
				     NULL,
				     l_temp2,
				     l_implementation_date,
				     l_implemented_by,
				     l_comment,
				     Nvl(l_task_id, rec.impacted_task_id),
				     sysdate,
	                             fnd_global.user_id,
	                             fnd_global.login_id,
				     l_record_ver_number
					);
	END IF;

	CLOSE get_orig_info;
     END loop;

     -- copy and include financial impact
     OPEN get_project_id;
     FETCH get_project_id INTO l_project_id;
     CLOSE get_project_id;

     l_source.DELETE;
     l_source(1) := p_source_ci_id;

     OPEN get_src_project_id;
     FETCH get_src_project_id INTO l_src_project_id;
     CLOSE get_src_project_id;
/* -- Bug 3677924 Jul 07 2004 Raja fp apis are to be called unconditionally
     Pa_Fp_Control_Items_Utils.CHECK_FP_PLAN_VERSION_EXISTS
       (
	 p_project_id      => l_src_project_id,
	 p_ci_id              => p_source_ci_id,
	 x_call_fp_api_flag      => l_ret,
	 x_return_status         => x_return_status,
	 x_msg_count             => x_msg_count,
	 x_msg_data              =>  x_msg_data
	 );

*/

     IF l_ret = 'Y' THEN

     IF p_include_flag = 'Y' THEN
	pa_fp_ci_include_pkg.fp_ci_copy_control_items
	  (
	   p_project_id => l_project_id,
	   p_source_ci_id_tbl  => l_source,
	   p_target_ci_id  => p_dest_ci_id,
	   p_calling_context => 'INCLUDE',
	   x_warning_flag  => l_warning_flag,
	   x_msg_data       => x_msg_data,
	   x_msg_count      => x_msg_count,
	   x_return_status  => x_return_status
	   );
      ELSE
	pa_fp_ci_include_pkg.fp_ci_copy_control_items
	  (
	   p_project_id => l_project_id,
	   p_source_ci_id_tbl  => l_source,
	   p_target_ci_id  => p_dest_ci_id,
	   p_calling_context => 'COPY',
	   x_warning_flag  => l_warning_flag,
	   x_msg_data       => x_msg_data,
	   x_msg_count      => x_msg_count,
	   x_return_status  => x_return_status
	   );
     END IF;
     END IF;


  END IF;

    -- Commit if the flag is set and there is no error
  IF (p_commit = 'T' AND x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


END copy_impact;

procedure is_delete_impact_ok
  (
   p_ci_impact_id IN NUMBER,

   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2
)
  IS
     CURSOR get_type_code
       IS
	  select impact_type_code,ci_id
          From pa_ci_impacts
	  WHERE ci_impact_id = p_ci_impact_id;

     l_temp VARCHAR2(30);
     l_ciid NUMBER;

BEGIN


  -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN get_type_code;
   FETCH get_type_code INTO l_temp,l_ciid;
   CLOSE get_type_code;

   IF l_temp = 'FINPLAN' THEN

      NULL;
      -- to be added

   ELSIF l_temp = 'SUPPLIER' THEN
	/** Added for Supplier Impact details This API returns error 'E' if there
         ** detail transactions exists for the supplier impact
         **/
	PA_CI_SUPPLIER_UTILS.IS_SI_DELETE_OK
		       (p_ci_id              => l_ciid
                        ,x_return_status     => x_return_status
                        ,x_msg_data          => x_msg_data
                        ,x_msg_count         => x_msg_count
                        );

   END IF;

END is_delete_impact_ok;

function get_edit_mode (
  p_ci_id IN NUMBER := null
) RETURN varchar2
IS
   l_temp VARCHAR2(10) := 'NONE';
   l_context VARCHAR2(30);


   l_status_code VARCHAR2(30);
   l_type_class VARCHAR2(30);
   l_ret VARCHAR2(1);
   l_ret2 VARCHAR2(1);


   CURSOR get_ci_info
     IS
	select pci.status_code,
	  pctb.ci_type_class_code from pa_control_items pci,
	  pa_ci_types_b pctb
	  where pci.ci_type_id = pctb.ci_type_id
	  AND pci.ci_id = p_ci_id;

   /*
   CURSOR is_implement_ok
     IS
	SELECT
	  pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM',l_status_code,'CI_ALLOW_IMPACT_IMPLEMENT') from dual;

   CURSOR is_update_ok
     IS
	SELECT
	  pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM',l_status_code,'CONTROL_ITEM_ALLOW_UPDATE') from dual;
     */

BEGIN

   OPEN get_ci_info;
   FETCH get_ci_info INTO l_status_code, l_type_class;
   CLOSE get_ci_info;

   /*
   OPEN is_update_ok;
   FETCH is_update_ok INTO l_ret;
   CLOSE is_update_ok;
     */
     l_ret := pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM',l_status_code,'CONTROL_ITEM_ALLOW_UPDATE');

   IF l_ret <>'Y' THEN
      -- need to check whether we can implement it
      IF l_type_class = 'CHANGE_ORDER' OR l_type_class = 'CHANGE_REQUEST' then
	/* OPEN is_implement_ok;
	 FETCH is_implement_ok INTO l_ret;
	 CLOSE is_implement_ok;
	   */

	   l_ret2 :=   pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM',l_status_code,'CI_ALLOW_IMPACT_IMPLEMENT');

	 IF l_ret2 <> 'Y' THEN
	    RETURN 'NONE';
	 END IF;
	 l_context := 'IMPLEMENT';
       ELSE
	 -- not a change request
	 RETURN 'NONE';
      END IF;

    ELSE
      l_context := 'DETAIL';
   END IF;

   IF l_context = 'DETAIL' THEN
      l_ret := pa_ci_security_pkg.check_update_access(p_ci_id);
      IF l_ret = 'T' THEN
	 l_temp := 'EDIT';
       ELSE
	 l_temp := 'VIEW';
      END IF;
    ELSIF l_context = 'IMPLEMENT' THEN
      l_ret := pa_ci_security_pkg.check_implement_impact_access(p_ci_id);
      IF l_ret = 'T' THEN
	 l_temp := 'EDIT';
       ELSE
	 l_temp := 'VIEW';
      END IF;

   END IF;

   RETURN l_temp;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'NONE';

END get_edit_mode;


function get_update_impact_mode (
  p_ci_id IN NUMBER := null
) RETURN varchar2
IS
   l_temp VARCHAR2(10) := 'NONE';
   l_context VARCHAR2(30);


   l_status_code pa_control_items.status_code%TYPE;
   l_type_class pa_ci_types_b.ci_type_class_code%TYPE;
   l_ret VARCHAR2(1);
   l_ret2 VARCHAR2(1);


   CURSOR get_ci_info
     IS
	select pci.status_code,
	  pctb.ci_type_class_code from pa_control_items pci,
	  pa_ci_types_b pctb
	  where pci.ci_type_id = pctb.ci_type_id
	  AND pci.ci_id = p_ci_id;

BEGIN
   OPEN get_ci_info;
   FETCH get_ci_info INTO l_status_code, l_type_class;
   CLOSE get_ci_info;

	l_ret := pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM',l_status_code,'CONTROL_ITEM_ALLOW_UPDATE');

   IF l_ret = 'Y' THEN
      l_ret2 := pa_ci_security_pkg.check_update_access(p_ci_id);
      IF l_ret2 = 'T' THEN  /* Bug#3815040: Modified the variable l_ret to l_ret2 */
	 l_temp := 'EDIT';
       ELSE
	 l_temp := 'VIEW';
      END IF;
   ELSE
      RETURN 'NONE';
   END IF;

   RETURN l_temp;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'NONE';

END get_update_impact_mode;

function get_implement_impact_mode (
  p_ci_id IN NUMBER := null
) RETURN varchar2
IS
   l_temp VARCHAR2(10) := 'NONE';
   l_context VARCHAR2(30);


   l_status_code pa_control_items.status_code%TYPE;
   l_type_class pa_ci_types_b.ci_type_class_code%TYPE;
   l_ret VARCHAR2(1);
   l_ret2 VARCHAR2(1);


   CURSOR get_ci_info
     IS
	select pci.status_code,
	  pctb.ci_type_class_code from pa_control_items pci,
	  pa_ci_types_b pctb
	  where pci.ci_type_id = pctb.ci_type_id
	  AND pci.ci_id = p_ci_id;

BEGIN
   OPEN get_ci_info;
   FETCH get_ci_info INTO l_status_code, l_type_class;
   CLOSE get_ci_info;

   IF l_type_class = 'CHANGE_ORDER' OR l_type_class = 'CHANGE_REQUEST' THEN
     l_ret2 := pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM',l_status_code,'CI_ALLOW_IMPACT_IMPLEMENT');

     IF l_ret2 <> 'Y' THEN
        RETURN 'NONE';
     END IF;

     l_context := 'IMPLEMENT';
   ELSE
     RETURN 'NONE';
   END IF;

   IF l_context = 'IMPLEMENT' THEN
      l_ret := pa_ci_security_pkg.check_implement_impact_access(p_ci_id);
      IF l_ret = 'T' THEN
	 l_temp := 'EDIT';
       ELSE
	 l_temp := 'VIEW';
      END IF;
   END IF;

   RETURN l_temp;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'NONE';

END get_implement_impact_mode;


function get_update_impact_mode (
  p_ci_id IN NUMBER := null,
  p_status_code IN VARCHAR2
) RETURN varchar2
IS
   l_temp VARCHAR2(10) := 'NONE';
   l_context VARCHAR2(30);

   l_status_code pa_control_items.status_code%TYPE;
   l_type_class pa_ci_types_b.ci_type_class_code%TYPE;
   l_ret VARCHAR2(1);
   l_ret2 VARCHAR2(1);

BEGIN

     l_status_code := p_status_code;
     l_ret := pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM',l_status_code,'CONTROL_ITEM_ALLOW_UPDATE');

   IF l_ret = 'Y' THEN
      l_ret2 := pa_ci_security_pkg.check_update_access(p_ci_id);
      IF l_ret2 = 'T' THEN  /* Bug#3815040: Modified the variable l_ret to l_ret2 */
	 l_temp := 'EDIT';
       ELSE
	 l_temp := 'VIEW';
      END IF;
   ELSE
      RETURN 'NONE';
   END IF;

   RETURN l_temp;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'NONE';

END get_update_impact_mode;

function get_implement_impact_mode (
  p_ci_id IN NUMBER := null,
  p_status_code IN VARCHAR2,
  p_type_class VARCHAR2
) RETURN varchar2
IS
   l_temp VARCHAR2(10) := 'NONE';
   l_context VARCHAR2(30);


   l_status_code pa_control_items.status_code%TYPE;
   l_type_class pa_ci_types_b.ci_type_class_code%TYPE;
   l_ret VARCHAR2(1);
   l_ret2 VARCHAR2(1);

BEGIN

   l_status_code := p_status_code;
   l_type_class  := p_type_class;

   IF l_type_class = 'CHANGE_ORDER' OR l_type_class = 'CHANGE_REQUEST' THEN
     l_ret2 := pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM',l_status_code,'CI_ALLOW_IMPACT_IMPLEMENT');

     IF l_ret2 <> 'Y' THEN
        RETURN 'NONE';
     END IF;

     l_context := 'IMPLEMENT';
   ELSE
     RETURN 'NONE';
   END IF;

   IF l_context = 'IMPLEMENT' THEN
      l_ret := pa_ci_security_pkg.check_implement_impact_access(p_ci_id);
      IF l_ret = 'T' THEN
	 l_temp := 'EDIT';
       ELSE
	 l_temp := 'VIEW';
      END IF;
   END IF;

   RETURN l_temp;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'NONE';

END get_implement_impact_mode;

END Pa_ci_impacts_util;

/
