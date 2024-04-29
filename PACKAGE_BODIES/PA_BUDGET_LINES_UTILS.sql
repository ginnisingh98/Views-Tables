--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_LINES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_LINES_UTILS" as
/* $Header: PAFPBLUB.pls 120.2 2007/02/06 09:44:28 dthakker noship $
   Start of Comments
   Package name     : PA_BUDGET_LINES_UTILS
   Purpose          : utility API's for pa_budget_lines table
   NOTE             : Used in Generation, WebADI, Change Document, upgrade, etc flows
                      in which pa_budget_lines are updated directly without going
                      through calculate API.
   End of Comments
*/


-- bug 5067200: Added this private API to null out display_quantity for
-- non rate based planning txns. It is called from populate_display_qty.
PROCEDURE clear_non_rate_res_disp_qty
    (p_budget_version_id           IN    pa_budget_versions.budget_version_id%TYPE,
     x_return_status               OUT   NOCOPY VARCHAR2)
IS

CURSOR get_non_rate_based_asgn
IS
SELECT resource_assignment_id
FROM   pa_resource_assignments
WHERE  budget_version_id = p_budget_version_id
AND    rate_based_flag = 'N';

l_non_rate_based_asgmt_id_tab SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
L_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
li_curr_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF L_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
        pa_debug.g_err_stage:='In PA_BUDGET_LINES_UTILS.clear_non_rate_res_disp_qty';
        pa_debug.write('PA_BUDGET_LINES_UTILS',pa_debug.g_err_stage,3);
    END IF;

    OPEN  get_non_rate_based_asgn;
    FETCH get_non_rate_based_asgn BULK COLLECT INTO l_non_rate_based_asgmt_id_tab;
    CLOSE get_non_rate_based_asgn;

      IF l_non_rate_based_asgmt_id_tab.COUNT > 0 THEN

        FORALL i IN l_non_rate_based_asgmt_id_tab.FIRST .. l_non_rate_based_asgmt_id_tab.LAST
        UPDATE pa_budget_lines
           SET display_quantity = null
         WHERE budget_version_id = p_budget_version_id
           AND resource_assignment_id = l_non_rate_based_asgmt_id_tab(i);
      END IF;

EXCEPTION
    WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF L_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
               PA_DEBUG.write_log (x_module    => 'PA_BUDGET_LINES_UTILS',
                                   x_msg       => 'Unexp. Error:' || 'clear_non_rate_res_disp_qty' || SQLERRM,
                                   x_log_level => 6);
           END IF;
           FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_BUDGET_LINES_UTILS',
                                    p_procedure_name => 'clear_non_rate_res_disp_qty');
           RAISE;
END clear_non_rate_res_disp_qty;

procedure Populate_Display_Qty
    (p_budget_version_id           IN  NUMBER,
     p_context                     IN  VARCHAR2,
     p_use_temp_table_flag         IN  VARCHAR2 DEFAULT 'N',
     p_resource_assignment_id_tab  IN  SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.pa_num_tbl_type(),
     p_set_disp_qty_null_for_nrbf  IN  VARCHAR2,
     x_return_status               OUT NOCOPY VARCHAR2) is

CURSOR get_rate_based_assignments IS
SELECT resource_assignment_id
FROM pa_resource_assignments
WHERE budget_version_id = p_budget_version_id
AND rate_based_flag = 'Y';

CURSOR get_rate_based_asgmts_temp_fp IS
SELECT ra.resource_assignment_id
FROM pa_resource_assignments ra,
     pa_resource_asgn_curr_tmp ract
WHERE ra.budget_version_id = p_budget_version_id
AND ra.resource_assignment_id = ract.resource_assignment_id
AND ra.rate_based_flag = 'Y';

CURSOR get_rate_based_asgmts_temp_wp IS
SELECT resource_assignment_id
FROM pa_resource_asgn_curr_tmp;

l_rate_based_asgmt_id_tab SYSTEM.pa_num_tbl_type;
L_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
li_curr_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF L_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
    pa_debug.g_err_stage:='In PA_BUDGET_LINES_UTILS.Populate_Display_Qty';
    pa_debug.write('PA_BUDGET_LINES_UTILS',pa_debug.g_err_stage,3);
  END IF;

  -- Option #1: Process all pa_budget_lines of resource_assignment_id's read
  --            from the pa_resource_asgn_curr_tmp temporary table.
  -- Option #2: Process all pa_budget_lines of resource_assignment_id's read
  --            from the IN parameter, p_resource_assignment_id_tab.
  -- Option #3: Process all pa_budget_lines in the given budget version id.

  -- IF p_context = 'WORKPLAN', simply copy quantity to display_quantity
  -- IF p_context = 'FINANCIAL', copy quantity according to rate_based_flag

  IF p_use_temp_table_flag = 'Y' THEN

    IF p_context = 'WORKPLAN' THEN
      OPEN get_rate_based_asgmts_temp_wp;
      FETCH get_rate_based_asgmts_temp_wp BULK COLLECT INTO l_rate_based_asgmt_id_tab;
      CLOSE  get_rate_based_asgmts_temp_wp;
    ELSE
      OPEN get_rate_based_asgmts_temp_fp;
      FETCH get_rate_based_asgmts_temp_fp BULK COLLECT INTO l_rate_based_asgmt_id_tab;
      CLOSE  get_rate_based_asgmts_temp_fp;
    END IF;

    IF l_rate_based_asgmt_id_tab IS NOT NULL AND l_rate_based_asgmt_id_tab.COUNT > 0 THEN

      FORALL i IN l_rate_based_asgmt_id_tab.FIRST..l_rate_based_asgmt_id_tab.LAST
      UPDATE pa_budget_lines
         SET display_quantity = quantity
       WHERE budget_version_id = p_budget_version_id
         AND resource_assignment_id = l_rate_based_asgmt_id_tab(i);
    END IF;

  ELSIF p_resource_assignment_id_tab is not null AND p_resource_assignment_id_tab.count > 0 THEN

    IF p_context = 'WORKPLAN' THEN

      FORALL i IN p_resource_assignment_id_tab.FIRST..p_resource_assignment_id_tab.LAST
        UPDATE pa_budget_lines
           SET display_quantity = quantity
         WHERE budget_version_id = p_budget_version_id
           AND resource_assignment_id = p_resource_assignment_id_tab(i);

    ELSE

      FORALL i IN p_resource_assignment_id_tab.FIRST..p_resource_assignment_id_tab.LAST
      UPDATE pa_budget_lines
         SET display_quantity = quantity
       WHERE budget_version_id = p_budget_version_id
         AND resource_assignment_id = p_resource_assignment_id_tab(i)
         AND resource_assignment_id in
             (select resource_assignment_id
                from pa_resource_assignments
               where rate_based_flag = 'Y'
                 and budget_version_id = p_budget_version_id
                 and resource_assignment_id = p_resource_assignment_id_tab(i));
    END IF;

  ELSE

    IF p_context = 'WORKPLAN' THEN

        UPDATE pa_budget_lines
           SET display_quantity = quantity
         WHERE budget_version_id = p_budget_version_id;

    ELSE

      OPEN get_rate_based_assignments;
      FETCH get_rate_based_assignments BULK COLLECT INTO l_rate_based_asgmt_id_tab;
      CLOSE  get_rate_based_assignments;

      IF l_rate_based_asgmt_id_tab IS NOT NULL AND l_rate_based_asgmt_id_tab.COUNT > 0 THEN

        FORALL i IN l_rate_based_asgmt_id_tab.FIRST .. l_rate_based_asgmt_id_tab.LAST
        UPDATE pa_budget_lines
           SET display_quantity = quantity
         WHERE budget_version_id = p_budget_version_id
           AND resource_assignment_id = l_rate_based_asgmt_id_tab(i);
      END IF;
    END IF;

  END IF;

    -- bug 5067200: Calling a private API clear_non_rate_res_disp_qty to clear out
    -- display_quantity column for non rate based planning txns, as it is possible
    -- that some rate based planning txn have been converted to a non rate based one
    -- and we need to null out values from display_quantity in pa_budget_lines
    IF p_context = 'FINANCIAL' AND
       p_set_disp_qty_null_for_nrbf = 'Y' THEN -- bug 5006029: added this condition.
        clear_non_rate_res_disp_qty
            (p_budget_version_id => p_budget_version_id,
             x_return_status     => x_return_status);
    END IF;

EXCEPTION

  WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF L_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
               PA_DEBUG.write_log (x_module    => 'PA_BUDGET_LINES_UTILS',
                                   x_msg       => 'Unexp. Error:' || 'Populate_Display_Qty' || SQLERRM,
                                   x_log_level => 6);
           END IF;
           FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_BUDGET_LINES_UTILS',
                                    p_procedure_name => 'Populate_Display_Qty');
           RAISE;


END Populate_Display_Qty;


END PA_BUDGET_LINES_UTILS;

/
