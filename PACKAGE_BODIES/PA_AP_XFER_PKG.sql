--------------------------------------------------------
--  DDL for Package Body PA_AP_XFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AP_XFER_PKG" AS
/* $Header: PAAPXFRB.pls 115.4 2003/08/15 02:14:24 vgade noship $ */


PROCEDURE upd_cdl_xfer_status( p_request_id     IN  NUMBER
                              ,x_return_status  OUT NOCOPY NUMBER
                              ,x_error_code     OUT NOCOPY VARCHAR2
                              ,x_error_stage    OUT NOCOPY NUMBER
                              )
IS

  g_request_id                              pa_cost_distribution_lines.request_id%TYPE ;
  l_expenditure_item_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_line_num_tab                            PA_PLSQL_DATATYPES.NumTabTyp;
  l_line_num_reversed_tab                   PA_PLSQL_DATATYPES.NumTabTyp;
  l_dr_code_combination_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_return_status                           NUMBER := -1;
  l_error_code                              VARCHAR2(30):= FND_API.G_RET_STS_ERROR;
  l_error_stage                             VARCHAR2(30);
  l_debug_mode                              VARCHAR2(1);
  l_stage                                   NUMBER ;
  l_this_fetch                              PLS_INTEGER := 0;
  l_totally_fetched                         PLS_INTEGER := 0;
  l_accrue_on_receipt_num                   NUMBER := 0;
  l_system_reference2                       pa_cost_distribution_lines_all.system_reference2%TYPE;

/*Cursor to select the invoices for the newly created cdls after recalc*/
CURSOR Inv_stat_cur
 IS
   Select distinct system_reference2
   from pa_cost_distribution_lines cdl,
        pa_expenditure_items ei
   where ei.cost_distributed_flag ='S'
     AND ei.request_id = g_request_id
     AND ei.system_linkage_function = 'VI'
     AND cdl.transfer_status_code = 'P'
     AND cdl.line_type ='R'
     AND cdl.request_id = g_request_id
     AND cdl.expenditure_item_id = ei.expenditure_item_id;

/*Cursor to select all the reversal cdls (line_type 'R') for the expenditure_item_ids
  marked with cost_distributed_flag as 'S'  */

CURSOR rev_cdl_cur
  IS
  SELECT cdl.expenditure_item_id
        ,cdl.line_num
        ,cdl.line_num_reversed
        ,cdl.dr_code_combination_id
   FROM  pa_expenditure_items_all ei
        ,pa_cost_distribution_lines_all cdl
   WHERE ei.cost_distributed_flag = 'S'
     AND ei.request_id = g_request_id
     AND ei.system_linkage_function = 'VI'
     AND cdl.transfer_status_code = 'P'
     AND cdl.request_id = g_request_id
     AND cdl.line_type = 'R'
     AND cdl.expenditure_item_id = ei.expenditure_item_id
     AND cdl.line_num_reversed is NOT NULL
  ORDER BY cdl.expenditure_item_id
          ,cdl.line_num;

BEGIN
  pa_debug.init_err_stack('pa_ap_xfer_pkg.upd_cdl_xfer_status');

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'Y');

  pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  l_stage := 10;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':From upd_cdl_xfer_status';
  pa_debug.write_file(pa_debug.g_err_stage);

  g_request_id     := p_request_id ;

  l_stage := 20;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Opening Cursor Inv_stat_cur';
  pa_debug.write_file(pa_debug.g_err_stage);

  OPEN Inv_stat_cur;

  LOOP
  Fetch Inv_stat_cur
  into  l_system_reference2;
  EXIT WHEN Inv_stat_cur%NOTFOUND;

  l_stage := 30;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Checking for Inv Status';
  pa_debug.write_file(pa_debug.g_err_stage);

/*Bug 3094341. Added an NVL condition to system_reference2, as it was calling
AP_PA_API_PKG, which was erroring out when NULL was passed. No records were retrieved when NULL is passed. */
  IF pa_integration.check_ap_invoices(nvl(l_system_reference2,0),'ADJUSTMENTS') <> 'N'
  THEN
   UPDATE PA_COST_DISTRIBUTION_LINES
    SET transfer_status_code ='B'
   WHERE system_reference2 =l_system_reference2
   AND   transfer_status_code = 'P'
   AND   line_type ='R'
   AND   request_id = g_request_id ;

  l_stage := 40;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After updating cdls for restricted invoice';
  pa_debug.write_file(pa_debug.g_err_stage);

  END IF;

  l_stage := 50;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After check for Inv status';
  pa_debug.write_file(pa_debug.g_err_stage);

  END LOOP;
  CLOSE Inv_stat_cur;

  l_stage :=60 ;
  pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Closing Cursor Inv_stat_cur';
  pa_debug.write_file(pa_debug.g_err_stage);

  OPEN rev_cdl_cur;
    l_this_fetch        := 0;
    l_totally_fetched   := 0;
    l_stage := 70;
    PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ':Fetching a Set of reversal CDLs to Process.';
    PA_DEBUG.write_file(PA_DEBUG.g_err_stage);

    l_stage := 80;

    LOOP

      FETCH rev_cdl_cur
       BULK COLLECT
         INTO l_expenditure_item_id_tab
             ,l_line_num_tab
             ,l_line_num_reversed_tab
             ,l_dr_code_combination_id_tab;

      l_this_fetch := rev_cdl_cur%ROWCOUNT - l_totally_fetched;
      l_totally_fetched := rev_cdl_cur%ROWCOUNT;

      PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ':Fetched [' || l_this_fetch || '] CDLs to process.';
      PA_DEBUG.write_file(PA_DEBUG.g_err_stage);


      IF (l_this_fetch = 0) THEN
        l_stage := 90;
        PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ':No more Reversal CDLs to process. Exiting';
        PA_DEBUG.write_file(PA_DEBUG.g_err_stage);

        x_return_status := 0;
        x_error_code := FND_API.G_RET_STS_SUCCESS;
        x_error_stage := l_stage;
        EXIT;
      END IF;

      l_stage :=100;

      FORALL i IN l_expenditure_item_id_tab.FIRST..l_expenditure_item_id_tab.LAST
        UPDATE PA_COST_DISTRIBUTION_LINES_ALL a
         SET a.TRANSFER_STATUS_CODE ='B'
        WHERE a.expenditure_item_id = l_expenditure_item_id_tab(i)
        AND   a.line_num in (l_line_num_tab(i) ,l_line_num_tab(i)+ 1)
        AND   EXISTS (SELECT 1
                      FROM PA_COST_DISTRIBUTION_LINES_ALL cdl
                      WHERE cdl.expenditure_item_id = a.expenditure_item_id
                      AND   cdl.line_num = l_line_num_tab(i) +1
                      AND   cdl.dr_code_combination_id =l_dr_code_combination_id_tab(i));

END LOOP;
l_stage := 110;
PA_DEBUG.g_err_stage := TO_CHAR(l_stage) || ': Closing the Cursor';
PA_DEBUG.write_file(PA_DEBUG.g_err_stage);
pa_debug.reset_err_stack; --Added for Bug#3094341
CLOSE rev_cdl_cur;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    l_stage := 120 ;
    pa_debug.write_file(pa_debug.g_err_stage);
    PA_DEBUG.g_err_stage := TO_CHAR(l_stage) ||'In UnExpected Exception';
    pa_debug.write_file(pa_debug.g_err_stage);

    x_return_status := -1;
    x_error_code    := FND_API.G_RET_STS_ERROR;
    x_error_stage   := l_stage ;
    pa_debug.reset_err_stack;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS
    THEN
      l_stage := 130 ;
      pa_debug.write_file(pa_debug.g_err_stage);
      PA_DEBUG.g_err_stage := TO_CHAR(l_stage) ||'In Others Exception';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(SQLCODE) || SQLERRM ;
      pa_debug.write_file(pa_debug.g_err_stage);

      x_return_status := -1;
      x_error_code    := TO_CHAR(SQLCODE) || SQLERRM ;
      x_error_stage   := l_stage ;
      pa_debug.reset_err_stack;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END upd_cdl_xfer_status;
END pa_ap_xfer_pkg;

/
