--------------------------------------------------------
--  DDL for Package Body GMF_ALLOC_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ALLOC_PROC" AS
/* $Header: gmfalocb.pls 120.4.12010000.5 2010/01/08 18:35:09 uphadtar ship $ */

/*****************************************************************************
 * PROCEDURE
 *    cost_alloc_proc
 *
 *  DESCRIPTION
 *    This procedure allocates the expenses and is the
 *   main call.
 *
 *  INPUT PARAMETERS
 *
 *    v_from_alloc_code   = From Allocation Code.
 *    v_to_alloc_code     = To Allocation Code.
 *    v_refresh_interface = 0  do not refresh the interface table
 *                          1  Refresh the interface table.
 *
 *  OUTPUT PARAMETERS
 *    errbuf    holds the exception information
 *
 *  HISTORY
 *  Jatinder Gogna - Changed fnd_flex_value to fnd_flex_values_vl
 *      for description columns
 *
 *     Manish Gupta                 02-MAR-99      Bug 841019
 *               Commented Package DBMS_OUTPUT.
 *    Jatinder Gogna -05/05/99 -Changed substr and instr to substrb and instrb
 *        as per AOL standards.
 *    Chetan Nagar    09/21/1999    Bug# 1001193
 *        Changed the format for variable X_amount from NUMBER(15) to NUMBER
 *        in procedure put_alloc_expenses.
 *  28-Sep-1999 Jatinder Gogna - B1008555
 *    Modified to get the segment reference form Oracle Apps
 *    to take care of cases where segment_number and segment_name
 *    may be out of sequence.
 *    Chetan Nagar    10/20/1999    B1043070
 *        UTF issues resolved.
 *    05-Nov-1999 Rajesh Seshadri Bug 1039469 - Performance enhancement
 *  The gmf_gl_get_balances package is redesigned to fill a table with
 *  the code combinations and then select from this table.  The queries
 *  were also rewritten to enhance their performance.
 *  Wrapped all calls to fnd_file inside a procedure and included
 *  trace messages throughout for easier debugging
 *    30-Oct-2002    R.Sharath Kumar     Bug# 2641405
 *                                       Added NOCOPY hint
 *    24-SEP-2003    Venkat Chukkapalli  Bug# 3150227
 *  Modified code in parse_account() to parse OPM/OF accounts based on
 *  OF segment_num and not based on OF application_column_name.
 *    26-SEP-2003    Venkat Chukkapalli  Bug# 3163804
 *  Removed 3150227 fix and added code in parse_account() to
 *  initialize PL/SQL table x_segment.
 * 26-JUL-2007 Himadri Chakroborty Bug #6133153
 *changed the size of the variables l_fiscal_year and  l_period_type to 15
 *  09-Oct-2008 Pramod B.H. Bug 7458002
 *    a)Modified procedure process_alloc_dtl() to merge records into gl_aloc_dtl
 *      instead of deleting and inserting rows in gl_aloc_dtl.
 *    b)Modified procedure delete_allocations() to delete only obsoleted rows
 *      in gl_aloc_dtl.
 ******************************************************************************/
 /* Package body global variables */
 g_calendar_code cm_cldr_hdr.calendar_code%type;
 g_period_code   cm_cldr_dtl.period_code%type;
 g_start_date    DATE;
 g_end_date      DATE;
 g_cost_type_id  NUMBER(15);
 g_le_name   VARCHAR2(240);
 g_structure_number NUMBER;
 g_calling_module  VARCHAR2(4000);
 g_period_id NUMBER(15);
 g_cost_mthd_code cm_mthd_mst.cost_mthd_code%type;
 g_legal_entity_id NUMBER(15);
 g_segment_delimeter VARCHAR2(2);
 g_ledgername VARCHAR2(30);
 g_chart_of_accounts_id NUMBER;


 g_periodname        VARCHAR2(15);
 g_periodstatus      VARCHAR2(1);
 g_periodyear 	     NUMBER(5);
 g_periodnumber      NUMBER(15);
 g_quarternum        NUMBER(15);
 g_fiscal_year_desc  VARCHAR2(240);
 g_statuscode        NUMBER(19);
 g_period_start_date DATE;
 g_period_end_date   DATE;
 g_calendar_name     VARCHAR2(15);
 g_period_type       VARCHAR2(15);
 g_fiscal_year       VARCHAR2(10);

 PROCEDURE end_proc (errbuf varchar2);

 PROCEDURE alloc_log_msg( pi_file IN NUMBER, pi_msg  IN VARCHAR2);

 PROCEDURE cost_alloc_proc(errbuf              OUT NOCOPY VARCHAR2,
                          retcode             OUT NOCOPY VARCHAR2,
                          p_legal_entity_id   IN NUMBER,
                          p_calendar_code     IN VARCHAR2,
                          p_period_code       IN VARCHAR2,
                          p_cost_type_id      IN NUMBER,
                          p_fiscal_year       IN VARCHAR2,
                          p_period_num        IN NUMBER,
                          v_from_alloc_code   IN gl_aloc_mst.alloc_code%TYPE,
                          v_to_alloc_code     IN gl_aloc_mst.alloc_code%TYPE,
                          v_refresh_interface IN VARCHAR2
                         )
 IS
   x_status NUMBER(10);
   x_refresh_int NUMBER;
   x_retval  BOOLEAN;
   l_prev_req_count NUMBER;
 BEGIN
  g_cost_type_id    := p_cost_type_id;
  g_legal_entity_id := p_legal_entity_id;
  g_periodyear := p_fiscal_year;
  g_periodnumber := p_period_num;
  g_calendar_code := p_calendar_code;
  g_period_code := p_period_code;

  BEGIN
    SELECT COUNT(1)
    INTO l_prev_req_count
    FROM  fnd_concurrent_requests
    WHERE concurrent_program_id IN  (SELECT      a.concurrent_program_id
                                    FROM        fnd_concurrent_programs a,
                                                fnd_application b
                                    WHERE       a.application_id = b.application_id
                                    AND         b.application_short_name = 'GMF'
                                    AND         a.concurrent_program_name = 'COSTALOC')
    AND   status_code in ('I','Q')
    AND   argument1 = p_legal_entity_id
    AND   argument2 = p_calendar_code
    AND   argument3 = p_period_code
    AND   argument4 = p_cost_type_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_prev_req_count := 0;
  END;

   IF (nvl(l_prev_req_count,0) > 0) THEN
     alloc_log_msg(C_LOG_FILE, 'Process is already submitted for these parameters.');
     retcode := 3;
     errbuf  := 'Process is already submitted for these parameters.';
     RETURN;
   END IF;

  /**
  * Uncomment the line below to wrote to a local file
  * fnd_file.put_names( 'gmfaloc.log','gmfaloc.out','/tmp' );
  */
     alloc_log_msg( C_LOG_FILE, 'Starting Cost Allocation process' );
     alloc_log_msg( C_LOG_FILE, 'Allocation Codes: ' || v_from_alloc_code || ' - ' ||v_to_alloc_code );
     gmf_util.trace( 'Refresh Option: ' || v_refresh_interface , 1, 2 );


   x_refresh_int := TO_NUMBER(v_refresh_interface);

    IF( x_refresh_int = 1 )
     THEN
      alloc_log_msg( C_LOG_FILE, 'Refresh Interface: Yes' );
     ELSE
      alloc_log_msg( C_LOG_FILE, 'Refresh Interface: No' );
     END IF;
   /* sschinch INVCONV*/
   BEGIN
     IF (p_calendar_code IS NOT NULL AND p_period_code IS NOT NULL) THEN
       SELECT   period_id
       INTO     g_period_id
       FROM     gmf_period_statuses
       WHERE    legal_entity_id = p_legal_entity_id
       AND      calendar_code = p_calendar_code
       AND      period_code = p_period_code
       AND      cost_type_id = p_cost_type_id;

       SELECT   cost_mthd_code
       INTO     g_cost_mthd_code
       FROM     cm_mthd_mst
       WHERE    cost_type_id = p_cost_type_id;
     END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       alloc_log_msg(C_LOG_FILE, 'Invalid period ID');
       retcode := 3;
       errbuf  := 'Invalid Period ID ';
      RETURN;
   END;

   x_status := get_legal_entity_details;
   IF (x_status < 0) THEN
     retcode := 3;
     errbuf  := 'No fiscal policy defined ';
     RETURN;
   END IF;

   alloc_log_msg(C_LOG_FILE, 'Legal Entity: ' || g_le_name);
   alloc_log_msg(C_LOG_FILE, 'Ledger Id: ' || ' ('||to_char(p_fiscal_plcy.ledger_id)||')');
   /*alloc_log_msg(C_LOG_FILE, 'Segment Delimiter '||''''||p_fiscal_plcy.segment_delimiter||'''');*/

   /*The procedure below allocates the cost.*/

   cost_allocate(v_from_alloc_code,v_to_alloc_code,x_refresh_int,x_status);

   IF (x_status < 0) THEN
    x_retval := fnd_concurrent.set_completion_status('ERROR',NULL);
   END IF;
   COMMIT;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,C_MODULE||'.end','Cost Allocation process completed successfully');
    END IF;

 EXCEPTION
  WHEN utl_file.invalid_path THEN
    retcode := 3;
    errbuf := 'Invalid path - '||to_char(SQLCODE) || ' ' || SQLERRM;
    end_proc (errbuf);
  WHEN utl_file.invalid_mode THEN
    retcode := 3;
    errbuf := 'Invalid Mode - '||to_char(SQLCODE) || ' ' || SQLERRM;
    end_proc (errbuf);
  WHEN utl_file.invalid_filehandle then
    retcode := 3;
    errbuf := 'Invalid filehandle - '||to_char(SQLCODE) || ' ' || SQLERRM;
    end_proc (errbuf);
  WHEN utl_file.invalid_operation then
    retcode := 3;
    errbuf := 'Invalid operation - '||to_char(SQLCODE) || ' ' || SQLERRM;
    end_proc (errbuf);
  WHEN utl_file.write_error then
    retcode := 3;
    errbuf := 'Write error - '||to_char(SQLCODE) || ' ' || SQLERRM;
    end_proc (errbuf);
      WHEN others THEN
    retcode := 3;
      errbuf := to_char(SQLCODE) || ' ' || SQLERRM;
    end_proc (errbuf);
  END cost_alloc_proc;


PROCEDURE end_proc (errbuf varchar2) IS
  x_retval boolean;
BEGIN
  x_retval := fnd_concurrent.set_completion_status('ERROR',NULL);
  /* INVCONV sschinch */
  -- Update the status to not running
/*  UPDATE cm_alpr_ctl
  SET    running_ind = 0,
    ended_on    = sysdate
  WHERE  calendar_code   = P_control_record.calendar_code
    AND period_code = P_control_record.period_code;
 */
  COMMIT;

END end_proc;


 /******************************************************************************
  *  PROCEDURE
  *    delete_allocations
  *  DESCRIPTION
  *    Deletes all allocations for the current calendar and period.
  *
  *  INPUT PARAMETERS
  *    v_from_alloc_code
  *     v_to_alloc_code
  *   v_calendar_code
  *   v_period
  *
  *   AUTHOR
  *     Sukarna Reddy    09/24/98
  *
  *   OUTPUT PARAMETERS
  *     v_status = 0  No row found for deletion and can continue
  *            = -1 Fatal Error
  *
  *******************************************************************************/

  PROCEDURE delete_allocations(
                                v_from_alloc_code   VARCHAR2,
                                v_to_alloc_code     VARCHAR2,
                                v_status       OUT NOCOPY NUMBER
                              )
  IS
  l_local_module VARCHAR2(80) := '.delete_allocations';
  BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,c_module||l_local_module||'.begin','Deleting Allocations');
    END IF;
    /* Bug 7458002 - Commented
    DELETE FROM
        gl_aloc_dtl
    WHERE
       period_id = g_period_id AND
       cost_type_id = g_cost_type_id
  AND alloc_id IN (
    SELECT alloc_id
    FROM  gl_aloc_mst
    WHERE legal_entity_id = g_legal_entity_id
    AND alloc_code between nvl(v_from_alloc_code,alloc_code)
      AND nvl(v_to_alloc_code,alloc_code)
    ); */

   /* Bug 7458002 - To delete only obsoleted rows in gl_aloc_dtl */
   DELETE FROM
        gl_aloc_dtl
   WHERE period_id = g_period_id
     AND cost_type_id = g_cost_type_id
     AND (alloc_id,line_no) NOT IN (
    	SELECT b.alloc_id, b.line_no
        FROM gl_aloc_mst m,gl_aloc_bas b
        WHERE m.alloc_id = b.alloc_id
        	AND m.legal_entity_id = g_legal_entity_id
        	AND b.delete_mark = 0
        	AND m.delete_mark = 0
        	AND m.alloc_code BETWEEN nvl(v_from_alloc_code,m.alloc_code) and
           		nvl(v_to_alloc_code  ,m.alloc_code)
	);

  alloc_log_msg( C_LOG_FILE, TO_CHAR(SQL%ROWCOUNT) || ' Rows deleted from Allocations table gl_aloc_dtl' );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,c_module||l_local_module||'.end','Deleting Allocations');
   END IF;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    alloc_log_msg(C_LOG_FILE, '0 Rows deleted from gl_aloc_dtl ');
    v_status := 0;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,c_module||l_local_module,'0 Rows deleted from gl_aloc_dtl');
    END IF;

  WHEN OTHERS THEN
    alloc_log_msg(C_LOG_FILE,  to_char(SQLCODE) || ' ' || SQLERRM);
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,c_module||l_local_module,to_char(SQLCODE) || ' ' || SQLERRM);
    END IF;
    v_status := -1;

  END delete_allocations;

  /********************************************************************************
   *  FUNCTION
   *    get_legal_entity_details
   *
   *  DESCRIPTION
   *
   *    The procedure below retrives the company details and caches the information
   *    in package specification variable record.
   *
   *  AUTHOR
   *     sukarna Reddy
   *
   *  INPUT PARAMETERS
   *     <None>
   *  OUTPUT PARAMETERS
   *     <None>
   *  RETURN
   *     -1  = No Calendar Exist
   *     -2  = No Fiscal policy Exist
   *     -3  = Failed to retrives Account Masks
   *   HISTORY
   *  10-Nov-99 Rajesh Seshadri - changed the cur_get_of_seg_deli to use a
   *  a parameter instead of a global variable
   *
   ********************************************************************************/

  FUNCTION get_legal_entity_details RETURN NUMBER IS
   CURSOR Cur_get_le(p_period_id NUMBER)  IS
      SELECT gps.legal_entity_id,
             xep.name
       FROM  gmf_period_statuses gps,
             xle_entity_profiles xep
       WHERE gps.period_id = p_period_id
       AND   gps.legal_entity_id = xep.legal_entity_id
       AND   gps.delete_mark = 0;

   CURSOR Cur_get_fiscal_plcy(p_le_id NUMBER) IS
     SELECT gfp.*
     FROM  gmf_fiscal_policies gfp
     WHERE gfp.legal_entity_id = p_le_id
      AND gfp.delete_mark = 0;

   CURSOR cur_get_of_seg_deli( p_ledger_id gl_ledgers.ledger_id%TYPE )
   IS
  SELECT
    concatenated_segment_delimiter,fifstr.id_flex_num
  FROM
    gl_ledger_le_v gll,
    fnd_id_flex_structures fifstr,
    fnd_application fa
  WHERE
    gll.chart_of_accounts_id = fifstr.id_flex_num
  AND gll.ledger_id = p_ledger_id
  AND fifstr.id_flex_code = 'GL#'
  AND fifstr.application_id = fa.application_id
  AND fa.application_short_name = 'SQLGL';

    Cur_fiscal_plcy Cur_get_fiscal_plcy%ROWTYPE;
    /*x_co_code  sy_orgn_mst.co_code%TYPE; INVCONV sschinch*/
    x_le_id NUMBER(15);
    x_status NUMBER(10);
    l_local_module VARCHAR2(80);
  BEGIN
    l_local_module := c_module||'.get_legal_entity_details';

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_local_module||'.begin','Starting');
    END IF;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,l_local_module,'Retrieving Legal Entity information for calendar: '|| g_calendar_code ||' and Period: '||g_period_code);
    END IF;

    OPEN Cur_get_le(g_period_id);
    FETCH Cur_get_le INTO x_le_id,g_le_name;
    IF (Cur_get_le%NOTFOUND) THEN
      CLOSE Cur_get_le;

      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        /*alloc_log_msg(2, 'No legal entity exists for cost calendar: ' ||g_calendar_code);*/
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,l_local_module,'No legal entity exists for cost calendar: ' ||g_calendar_code  ||' and Period: '||g_period_code);
      END IF;
      RETURN(-1);  /* No calendar exists.*/
    END IF;
    CLOSE Cur_get_le;

    /* Fetch the fiscal policy information for the company retrieved */
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      /*alloc_log_msg( 2,'Retrieving Fiscal policy for legal entity: ' ||g_le_name );*/
      FND_LOG.STRING(FND_LOG.LEVEL_ERROR,l_local_module,'Retrieving Fiscal policy for legal entity: ' ||g_le_name);
    END IF;

    OPEN Cur_get_fiscal_plcy(X_le_id);
    FETCH Cur_get_fiscal_plcy INTO P_fiscal_plcy;
    IF (Cur_get_fiscal_plcy%NOTFOUND) THEN
      CLOSE Cur_get_fiscal_plcy;
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,l_local_module,'Retrieving Fiscal policy for legal entity: ' ||g_le_name);
      END IF;
      alloc_log_msg(C_LOG_FILE, 'No fiscal policy is defined for legal_entity ' || g_le_name);
      RETURN(-2);  /* No fiscal policy is defined for this company.*/
    END IF;
    CLOSE Cur_get_fiscal_plcy;

    OPEN cur_get_of_seg_deli( P_fiscal_plcy.ledger_id);
    FETCH cur_get_of_seg_deli INTO g_segment_delimeter,g_structure_number;
    CLOSE cur_get_of_seg_deli;

   /* When Failed to retrieve Segment Delimiter from oracle Financials then
      assign the default segment delimeter defined in the fiscal policy */

    /*IF (P_of_segment_delimeter IS NULL) THEN
      P_of_segment_delimeter := P_fiscal_plcy.segment_delimiter;
      alloc_log_msg(2, 'No OF Delimiter defined, using OPM delimiter: ' || P_fiscal_plcy.segment_delimiter);
    END IF;
    */

    alloc_log_msg( C_LOG_FILE, 'Retrieved Fiscal Policy Details successfully' );

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_local_module||'.end','Retrieved discal policy details successfully');
    END IF;
    RETURN(0);
  END get_legal_entity_details;


  /****************************************************************************
  * PROCEDURE
  *  Delete_interface
  *
  * DESCRIPTION
  *   Deletes the interface row for a given criteria when refresh ind is set.
  *
  * AUTHOR
  *   Sukarna Reddy
  *
  * INPUT PARAMETERS
  *
  *   v_calendar_code = Calendar code
  *   v_period_code   = period code
  *
  * OUTPUT PARAMETERS
  *
  *   v_status     =  0   No rows to delete
  *                = -1   Fatal Error
  * HISTORY
  *   Sukarna Reddy Modified code for convergence July 20
  ****************************************************************************/

  PROCEDURE delete_interface(v_status OUT NOCOPY NUMBER) IS
    l_local_module VARCHAR2(80) := '.delete_interface';
  BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,c_module||l_local_module||'.begin','Delete interface');
   END IF;

   alloc_log_msg(C_LOG_FILE, 'Deleting rows from gl_aloc_inp for calendar  '||
   g_calendar_code||' and period '||g_period_code || ' and cost type '||g_cost_mthd_code);

    DELETE
      FROM gl_aloc_inp
    WHERE calendar_code = g_calendar_code
    AND period_code = g_period_code;

  v_status :=0;

  alloc_log_msg( C_LOG_FILE, TO_CHAR(SQL%ROWCOUNT) || ' Rows deleted from Interface table gl_aloc_inp' );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,c_module||l_local_module||'.end','Delete interface');
  END IF;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
    alloc_log_msg(C_LOG_FILE, '0 rows deleted from gl_aloc_inp');
    v_status := 0;
   WHEN OTHERS THEN
     alloc_log_msg(C_LOG_FILE, to_char(SQLCODE) || ' ' || SQLERRM);
     v_status := -1;
  END delete_interface;

 /****************************************************************************
  *  PROCEDURE
  *    cost_allocate
  *  DESCRIPTION
  *    Deletes the existing allocations for current calendar and period specified
  *    if refresh indicator is 1 , deletes interface rows from gl_alloc_inp for
  *    calendar and period specified.Populates the interface table picking
  *    rows from expense table, allocation basis table. if refresh interface is
  *    not set , refreshes the interface table with fixed percentages in the
  *    allocation basis. Finally calculates the percentages and expense amount
  *    and populates allocation table.
  *
  *  AUTHOR
  *    Sukarna Reddy      Date : 09/18/98
  *
  *  INPUT PARAMETERS
  *
  *   v_from_alloc_code
  *   v_to_alloc_code
  *   v_refresh_interface
  *
  *  OUTPUT PARAMETERS
  *   v_status   = -1 Fatal error occured while deleting allocations
  *              = -2 Fatal error occured while deleting interface rows.
  *              =  0 Successfull
  *
  *  HISTORY
  * Chetan Nagar  19-Feb-2001 B1418787
  *   List out all the burden codes that have total fixed percentage
  *   more than 100. These allocation codes will be ignored from processing.
  *  Sukarna Reddy Modified code for convergence July 2005
  ***************************************************************************/

  PROCEDURE cost_allocate(v_from_alloc_code      VARCHAR2,
                          v_to_alloc_code        VARCHAR2,
                          v_refresh_interface    NUMBER,
                          v_status             OUT NOCOPY NUMBER
  )
  IS
  x_status NUMBER;

  CURSOR cur_alloc_fixed_invalid IS
    SELECT m.alloc_code alloc_code,
           sum(b.fixed_percent) total_percentage
    FROM   gl_aloc_mst m, gl_aloc_bas b
    WHERE  m.alloc_id = b.alloc_id
      AND  m.legal_entity_id = g_legal_entity_id
      AND  b.alloc_method = 1
      AND  m.alloc_code BETWEEN NVL(v_from_alloc_code,m.alloc_code)
        AND nvl(v_to_alloc_code,m.alloc_code)
      AND  m.delete_mark = 0
      AND  b.delete_mark = 0
    GROUP BY m.alloc_code
    HAVING sum(b.fixed_percent) <> 100
    ORDER BY 1;
    l_local_module VARCHAR2(80) := '.cost_allocate';
    l_previous_module VARCHAR2(4000);
  BEGIN
    l_previous_module := g_calling_module;
    g_calling_module := g_calling_module||l_local_module;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,g_calling_module||'.begin','Allocating Cost');
    END IF;

    /* B1418787 List out all the allocation codes that exceed 100% */
    alloc_log_msg( C_LOG_FILE, 'Following allocation codes will be ignored as the total percentage does not equal 100.');

    alloc_log_msg( C_LOG_FILE, 'Allocation Code  -  Total Percentage');
    alloc_log_msg( C_LOG_FILE, '===============     ================');

    FOR cur_alloc_fixed_invalid_tmp IN cur_alloc_fixed_invalid LOOP
      alloc_log_msg( C_LOG_FILE, rpad(cur_alloc_fixed_invalid_tmp.alloc_code, 15, ' ') || '  -  ' ||rpad(cur_alloc_fixed_invalid_tmp.total_percentage, 16, ' '));
    END LOOP;
    /* Bug 7458002 - Commented
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT,g_calling_module||'.delete_allocations','deleting Allocations ...');
    END IF;
    delete_allocations(v_from_alloc_code, v_to_alloc_code, x_status);

    IF (x_status < 0)
    THEN
      v_status := -1;
      return;
    END IF;*/

    IF (v_refresh_interface = 1)
    THEN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EVENT,g_calling_module||'.delete_interface','deleting Interface data...');
      END IF;

      delete_interface(x_status);
      IF (x_status < 0)
      THEN
        v_status := -2;
        return;
      END IF;
      alloc_log_msg( C_LOG_FILE, 'Retrieving Expenses ...');

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EVENT,g_calling_module||'.get_expenses','Retrieving Expenses ....');
      END IF;
      get_expenses(v_from_alloc_code, v_to_alloc_code);

      g_calling_module := l_previous_module||l_local_module;

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EVENT,g_calling_module||'.get_alloc_basis','Retrieving Basis Information ....');
      END IF;
      alloc_log_msg( C_LOG_FILE, 'Retrieving Basis Information ...');
      get_alloc_basis(v_from_alloc_code, v_to_alloc_code);
      g_calling_module := l_previous_module||l_local_module;
    ELSE
      /* Do not refresh the interface */

      alloc_log_msg( C_LOG_FILE, 'Processing Fixed Precentage Information ...');

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EVENT,g_calling_module||'.refresh_fixed','Processing Fixed Percentage Information ....');
      END IF;
      refresh_fixed(v_from_alloc_code,v_to_alloc_code);
      g_calling_module := l_previous_module||l_local_module;
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EVENT,g_calling_module||'.process_alloc_dtl','Allocating Expenses ...');
    END IF;

    alloc_log_msg( C_LOG_FILE, 'Allocating Expenses ...');
    process_alloc_dtl(v_from_alloc_code,v_to_alloc_code);
    g_calling_module := l_previous_module||l_local_module;

    COMMIT;
    v_status := 0;

  EXCEPTION
    WHEN others THEN
    alloc_log_msg( C_LOG_FILE, to_char(SQLCODE) || ' ' || SQLERRM);
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,g_calling_module,to_char(SQLCODE) || ' ' || SQLERRM);
    END IF;
    v_status := -1;
  END cost_allocate;


/*****************************************************************
 * PROCEDURE
 *    get_expenses
 *
 * DESCRIPTION
 *   Retrieves the expense accounts from expenses table such as
 *   gl_aloc_exp and populates the interface table with the
 *   expense amount retrieved from oracle financials.
 *
 * AUTHOR
 *   sukarna Reddy    09/18/98
 *
 * INPUT PARAMETERS
 *   v_from_alloc_code
 *   v_to_alloc_code
 *
 * OUTPUT PARAMETERS
 *     <None>
 * HISTORY
 *  Sukarna Reddy modified code for convergence July 2005.
 ******************************************************************/

  PROCEDURE get_expenses(v_from_alloc_code VARCHAR2,
                         v_to_alloc_code   VARCHAR2)
  IS

    CURSOR cur_get_exp IS
  SELECT
    a.alloc_code as exp_alloc_code,
    e.alloc_id as exp_alloc_id,
    e.line_no as exp_line_no,
    e.from_account_id as exp_from_account,
    e.to_account_id as exp_to_account,
    e.balance_type as exp_balance_type, e.exp_ytd_ptd
  FROM
    gl_aloc_exp e,
    gl_aloc_mst a
  WHERE
    e.alloc_id = a.alloc_id
    and a.legal_entity_id = g_legal_entity_id
    and e.delete_mark = 0
    and a.delete_mark = 0
    and a.alloc_code between nvl(v_from_alloc_code,a.alloc_code) and
           nvl(v_to_alloc_code,a.alloc_code)
                and 100 =
                        (select decode(max(b.alloc_method), 0, 100, 1, sum(fixed_percent))
                         from gl_aloc_bas b
                         where b.alloc_id = a.alloc_id
                         and b.delete_mark = 0
                        )
  ;

   l_local_module  VARCHAR2(80) := '.get_expenses';
   l_previous_module VARCHAR2(4000);
  BEGIN
    l_previous_module := g_calling_module;
    g_calling_module := g_calling_module||l_local_module;

    FOR cur_get_exp_tmp IN cur_get_exp
    LOOP
      alloc_log_msg( C_LOG_FILE, '  Processing allocation code '||cur_get_exp_tmp.exp_alloc_code);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,g_calling_module||'.put_alloc_expenses','  Processing allocation code '||cur_get_exp_tmp.exp_alloc_code);
      END IF;

      put_alloc_expenses(
                          cur_get_exp_tmp.exp_alloc_id,
                          cur_get_exp_tmp.exp_line_no,
                          cur_get_exp_tmp.exp_from_account,
                          cur_get_exp_tmp.exp_to_account,
                          cur_get_exp_tmp.exp_balance_type,
                          cur_get_exp_tmp.exp_ytd_ptd,
                          1
                         );

    END LOOP;

    g_calling_module := l_previous_module;

  END get_expenses;

/********************************************************************
 *  PROCEDURE
 *    put_alloc_expenses
 *
 *   DESCRIPTION
 *    Retrieves the balances from Oracle financials for a range of
 *    accounts specified and populates the interface table with the
 *    expense information.
 *
 *   AUTHOR
 *    Sukarna Reddy     09/18/98
 *
 *   INPUT PARAMETERS
 *    v_alloc_id
 *    v_line_no
 *    v_from_segment
 *    v_to_segment
 *    v_balance_type
 *    v_ytd_ptd
 *    v_account_type
 *
 *  OUTPUT PARAMETERS
 *    <None>
 *
 *  HISTORY
 *  Sukarna Reddy Modified code for convergence. July 2005.
 *  Himadri Chakroborty Modified code for Bug 6133153.July 2007.
 *  31-DEC-2009 Uday Phadtare Bug 9241807.
 *    When enabled segments in Accounting Flexfield are not in sequence, concatenated_segments
 *    string need to be formatted properly before passing it to API fnd_flex_ext.get_ccid()
 *    to avoid error 'Values have not been entered for one or more required segments'.
 **********************************************************************/

  PROCEDURE put_alloc_expenses
  (
  v_alloc_id     NUMBER,
  v_line_no      VARCHAR2,
  v_from_segment NUMBER,
  v_to_segment   NUMBER,
  v_balance_type NUMBER,
  v_ytd_ptd      NUMBER,
  v_account_type NUMBER
  )
  IS
    CURSOR          cur_bal_type IS
    SELECT          decode(v_balance_type,'0','A','1','B','2','A')
    FROM            dual;

    CURSOR          cur_currency IS
    SELECT          decode(v_balance_type,'0','STAT',NULL)
    FROM            dual;

    CURSOR          Cur_get_ledgerinfo
    (
    p_ledger_id       gl_period_statuses.ledger_id%TYPE
    )
    IS
    SELECT          gl.short_name,
		                gl.period_set_name,
                    gl.accounted_period_type,
                    gl.chart_of_accounts_id
    FROM            gl_ledgers gl
    WHERE           gl.ledger_id = P_ledger_id
    AND             rownum = 1;

    X_chart_of_accounts NUMBER(10);
    X_period_num        NUMBER(10);
    X_period_year       NUMBER(10);
    X_currency_code     VARCHAR2(4);
    X_to_segment        VARCHAR2(4000);
    X_in_actual_flag    VARCHAR2(2);
    X_amount            NUMBER DEFAULT 0;
    X_segment_delimiter VARCHAR(2);
    X_row_to_fetch      NUMBER(10) DEFAULT 0;
    X_error_status      NUMBER(10) DEFAULT 0;
    X_from_segment      VARCHAR2(4000);
    X_in_ytd_ptd        NUMBER(10);
    x_created_by        NUMBER(10) DEFAULT FND_PROFILE.VALUE('USER_ID');
    x_return_status     BOOLEAN;
    l_local_module VARCHAR2(80) := '.put_alloc_expenses';
    l_previous_module VARCHAR2(4000);
    l_mesg_text VARCHAR2(100);
    l_prev_local_module VARCHAR2(4000);
    x_to_account_id NUMBER(15);
    l_to_segment_id NUMBER;
    l_from_segment_id NUMBER;
    l_n_segs   NUMBER;
    l_seg_array fnd_flex_ext.SegmentArray;
    l_gl_fiscal_year NUMBER(15);
    l_gl_period      NUMBER(15);
    l_return_status NUMBER(5);
     /* B6133153 GL allocation of expenses are not showing after running the GL allocation process */
   -- l_fiscal_year VARCHAR2(10);
   -- l_period_type VARCHAR2(10);
     l_fiscal_year VARCHAR2(15);
     l_period_type VARCHAR2(15);
    x_ledger_id NUMBER := P_fiscal_plcy.ledger_id;
    X_account_type VARCHAR2(4);
    l_new_x_to_segment   VARCHAR2(4000); --Bug 9241807

 BEGIN
     l_previous_module := g_calling_module;
     g_calling_module := g_calling_module||l_local_module;
     l_from_segment_id := v_from_segment;
     l_to_segment_id := v_to_segment;

     IF x_ledger_id IS NOT NULL THEN
       OPEN Cur_get_ledgerinfo(x_ledger_id);
       FETCH Cur_get_ledgerinfo INTO g_ledgername, l_fiscal_year, l_period_type, g_chart_of_accounts_id;
       IF Cur_get_ledgerinfo%NOTFOUND THEN
         CLOSE Cur_get_ledgerinfo;
         FND_MESSAGE.SET_NAME('GMF', 'GL_NO_FISCAL_POLICY');
         alloc_log_msg(C_LOG_FILE,FND_MESSAGE.GET);
       END IF;
       CLOSE Cur_get_ledgerinfo;
       IF g_ledgername IS NULL THEN
           FND_MESSAGE.SET_NAME('GMF', 'GL_SOB_NOTSETUP');
           alloc_log_msg(C_LOG_FILE,FND_MESSAGE.GET);
       END IF;
    END IF;

    open cur_bal_type;
    fetch cur_bal_type INTO x_in_actual_flag;
    close cur_bal_type;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,g_calling_module,'Calling FND_FLEX_EXT.GET_SEGMENTS() API');
    END IF;

    x_return_status := fnd_flex_ext.get_segments  (
                                                  application_short_name => 'SQLGL',
                                                  key_flex_code          => 'GL#',
                                                  structure_number       => g_structure_number,
                                                  combination_id         => v_from_segment,
                                                  n_segments	            => l_n_segs,
  			                                          segments		            => l_seg_array
                                                  );

    IF (l_n_segs > 0) THEN
      FOR i IN 1..l_n_segs LOOP
        IF (l_seg_array(i) IS NOT NULL) THEN
          IF x_from_segment IS NOT NULL THEN
            x_from_segment := x_from_segment||g_segment_delimeter||l_seg_array(i);
          ELSE
            x_from_segment := l_seg_array(i);
          END IF;
        END IF;
      END LOOP;
      gmf_util.trace( 'From segment '||x_from_segment, 2, 2 );
    ELSE
      alloc_log_msg(C_LOG_FILE,FND_MESSAGE.GET);
      RETURN;
    END IF;

    x_return_status := fnd_flex_ext.get_segments(application_short_name => 'SQLGL',
                                                 key_flex_code          => 'GL#',
                                                 structure_number       => g_structure_number,
                                                 combination_id         => v_to_segment,
                                                 n_segments	            => l_n_segs,
			                                           segments		            => l_seg_array
                                                );
    IF (l_n_segs > 0) THEN
      FOR i IN 1..l_n_segs LOOP
        IF x_to_segment IS NOT NULL THEN
          x_to_segment := x_to_segment||g_segment_delimeter||l_seg_array(i);
        ELSE
          x_to_segment := l_seg_array(i);
        END IF;
      END LOOP;
      gmf_util.trace( 'To segment '||x_to_segment, 2, 2 );
    ELSE
      alloc_log_msg(C_LOG_FILE,FND_MESSAGE.GET);
      RETURN;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,g_calling_module,'Finished Calling FND_FLEX_EXT.GET_SEGMENTS() API');
    END IF;

    x_in_ytd_ptd      := v_ytd_ptd;

    /* B8432783 Added back the currency code selection */
    /* Decode the currency code value for GEMMS balance_type. */
    OPEN cur_currency;
    FETCH cur_currency INTO X_currency_code;
    CLOSE cur_currency;

    IF X_CURRENCY_CODE IS NULL THEN
       X_CURRENCY_CODE := P_fiscal_plcy.base_currency_code;
    END IF;

	  l_prev_local_module := g_calling_module;

    WHILE (x_error_status <> 100 or x_error_status < 0)
    LOOP

  gmf_util.trace( 'Values before call to get balances: ' ||
    X_ledger_id || ' , ' ||
    g_chart_of_accounts_id || ' , ' ||
    g_periodyear || ' , ' ||
    g_periodnumber || ' , ' ||
    X_account_type || ' , ' ||
    X_currency_code || ' , ' ||
    X_from_segment || ' , ' ||
    X_to_segment || ' , ' ||
    X_in_actual_flag || ' , ' ||
    X_in_ytd_ptd || ' , ' ||
    X_amount || ' , ' ||
    X_segment_delimiter || ' , ' ||
    X_row_to_fetch || ' , ' ||
    X_error_status
    , 3, 2 );


    gmf_gl_get_balances.proc_gl_get_balances(
    X_ledger_id,
    g_chart_of_accounts_id,
    g_periodyear,
    g_periodnumber,
    X_account_type,
    X_currency_code,
    X_from_segment,
    X_to_segment,
    X_in_actual_flag,
    X_in_ytd_ptd,
    X_amount,
    X_segment_delimiter,
    X_row_to_fetch,
    X_error_status
    );

    --Begin Bug 9241807
    SELECT REPLACE(
                   REPLACE(
                           REPLACE(
                                   x_to_segment,
                                   X_segment_delimiter||X_segment_delimiter,
                                   X_segment_delimiter
                                  ),
                           X_segment_delimiter||X_segment_delimiter,
                           X_segment_delimiter
                          ),
                   X_segment_delimiter||X_segment_delimiter,
                   X_segment_delimiter
                  )
    INTO l_new_x_to_segment FROM dual;
    --End Bug 9241807

  gmf_util.trace( 'Values after call to get balances: ' ||
    X_ledger_id || ' , ' ||
    g_chart_of_accounts_id || ' , ' ||
    g_periodyear || ' , ' ||
    g_periodnumber || ' , ' ||
    X_account_type || ' , ' ||
    X_currency_code || ' , ' ||
    X_from_segment || ' , ' ||
    X_to_segment || ' , ' ||
    l_new_x_to_segment || ' , ' ||
    X_in_actual_flag || ' , ' ||
    X_in_ytd_ptd || ' , ' ||
    X_amount || ' , ' ||
    X_segment_delimiter || ' , ' ||
    X_row_to_fetch || ' , ' ||
    X_error_status
    , 3, 2 );

       /* Format the to segment brought from of table to OPM account key.*/

       x_error_status := nvl(x_error_status,0);

       IF (x_error_status <> 100 AND x_error_status >= 0) THEN
          /* INVCONV sschinch */
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,g_calling_module,'Calling FND_FLEX_EXT.GET_COMBINATION_ID() API');
         END IF;
         x_to_account_id := fnd_flex_ext.get_ccid(application_short_name => 'SQLGL',
			                                            key_flex_code	         => 'GL#',
			                                            structure_number	     => g_structure_number,
			                                            validation_date	       => to_char(SYSDATE,FND_FLEX_EXT.DATE_FORMAT),
			                                            concatenated_segments	 => l_new_x_to_segment               /* x_to_segment Bug 9241807 */
			                                           );
          IF (x_to_account_id > 0) THEN
           insert_alloc_inp(v_alloc_id,
                            v_line_no,
                            v_account_type,
                            x_to_account_id,
                            x_amount
                           );
           alloc_log_msg(C_LOG_FILE, '  Account: '||x_to_segment|| ' Amount = '||to_char(x_amount));
         ELSE
           l_mesg_text := FND_MESSAGE.GET;
           alloc_log_msg(C_LOG_FILE,l_mesg_text);
           IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_ERROR,g_calling_module,'Error returned from FND_FLEX_EXT.GET_COMBINATION_ID() API '||l_mesg_text);
           END IF;
         END IF;
       END IF;
      /* end SSCHINCH */
     END LOOP;

     x_error_status := 0;
     g_calling_module := l_previous_module;

   END put_alloc_expenses;

 /*******************************************************************
 *  PROCEDURE
 *    insert_alloc_inp
 *
 *  DESCRIPTION
 *    Inserts a row in to gl_aloc_inp.
 *
 *  AUTHOR
 *    Sukarna Reddy      09/18/98
 *
 *  INPUT PARAMETERS
 *   v_alloc_id
 *   v_line_no
 *   v_account_type
 *   v_amount
 *
 *  OUTPUT PARAMETERS
 *    <None>
 *
 *  HISTORY
 *  Modified code for inventory convergence sschinch July 2005
 *******************************************************************/

 PROCEDURE insert_alloc_inp(
  v_alloc_id     NUMBER,
  v_line_no      VARCHAR2,
  v_account_type NUMBER,
  v_to_segment   NUMBER,
  v_amount       NUMBER
  )

 IS
   l_local_module VARCHAR2(80):= '.insert_alloc_inp';
  BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,g_calling_module||l_local_module||'.begin','Inserting ...');
    END IF;

     INSERT
     INTO
  gl_aloc_inp
  (
    gl_aloc_inp_id,
    calendar_code,
    period_code,
    alloc_id,
    line_no,
    account_key_type,
    account_id,
    amount,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    trans_cnt,
    delete_mark,
    text_code
  )
  VALUES
  (
    gem5_gl_aloc_inp_id_s.nextval,
    g_calendar_code,
    g_period_code,
    v_alloc_id,
    v_line_no,
    v_account_type,
    v_to_segment,
    nvl(v_amount,0),
    sysdate,
    P_created_by,
    sysdate,
    P_created_by,
    NULL,
    0,
    0,
    NULL
   );
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,g_calling_module||l_local_module||'.end','Completed Inserting data into interface...');
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,g_calling_module||l_local_module,to_char(SQLCODE)||' '||SQLERRM);
    END IF;
  END insert_alloc_inp;

  /* *********************************************************
   * PROCEDURE
   *    get_alloc_basis
   *
   *  DESCRIPTION
   *   Retrieves the allocation basis information,Inserts basis
   *   Information with balances retrieved from financials
   *  AUTHOR
   *     Sukarna Reddy    09/18/98
   *
   *  INPUT PARAMETERS
   *    v_co_code
   *    v_from_alloc_code
   *  v_to_alloc_code
   *
   *  OUTPUT PARAMETERS
   *      <None>
   *
   *  HISTORY
   *    Ignore all the burden codes that have total
   *    fixed percentage not equal to 100.
   ************************************************************/
  PROCEDURE get_alloc_basis(
  v_from_alloc_code VARCHAR2,
  v_to_alloc_code   VARCHAR2
  )
  IS

    CURSOR cur_alloc_basis IS
      SELECT m.alloc_id,
             m.alloc_code,
             b.line_no,
             b.alloc_method,
             b.basis_account_id,
             b.balance_type,
             b.bas_ytd_ptd,
             b.fixed_percent
      FROM  gl_aloc_mst m, gl_aloc_bas b
      WHERE m.alloc_id = b.alloc_id
            AND m.legal_entity_id = g_legal_entity_id
            AND m.alloc_code BETWEEN NVL(v_from_alloc_code,m.alloc_code) AND nvl(v_to_alloc_code,m.alloc_code)
            AND m.delete_mark = 0
            AND b.delete_mark = 0
            AND  (b.alloc_method = 0 OR
                  (b.alloc_method = 1 AND 100 = ( SELECT sum(bb.fixed_percent)
                                                 FROM   gl_aloc_bas bb
                                                 WHERE  bb.alloc_id = b.alloc_id and
              bb.delete_mark = 0
                                                )
                  )
                 )

      ORDER BY 1,2;


  BEGIN
    FOR cur_alloc_basis_tmp IN cur_alloc_basis LOOP
      IF (cur_alloc_basis_tmp.alloc_method = 0) THEN

        alloc_log_msg(C_LOG_FILE, '  Allocation code: '||cur_alloc_basis_tmp.alloc_code);
        put_alloc_expenses(cur_alloc_basis_tmp.alloc_id,
                           cur_alloc_basis_tmp.line_no,
                           cur_alloc_basis_tmp.basis_account_id, /* INVCONV sschinch */
                           cur_alloc_basis_tmp.basis_account_id,
                           cur_alloc_basis_tmp.balance_type,
                           cur_alloc_basis_tmp.bas_ytd_ptd,
                           0);
      ELSIF(cur_alloc_basis_tmp.alloc_method = 1) THEN
        insert_alloc_inp(cur_alloc_basis_tmp.alloc_id,
                         cur_alloc_basis_tmp.line_no,
                         0,
                         NULL,
                         cur_alloc_basis_tmp.fixed_percent);
      END IF;
    END LOOP;
  END get_alloc_basis;

 /***************************************************************
  * PROCEDURE
  *  refresh_fixed
  *
  * DESCRIPTION
  *   Refreshes the interface table with the fixed percent information
  *   from allocation basis table if at all it got modified. This
  *   procedure deletes all the fixed percent rows from interface table
  *   and inserts into the interface table with new fixed percent rows
  *   values from allocation basis table.
  *
  *  AUTHOR
  *    Sukarna Reddy  09/17/98
  *
    INPUT PARAMETERS
  *  v_from_alloc_code
  *  v_to_alloc_code
  *
  * OUTPUT PARAMETERS
  *  <None>
  *
  * HISTORY
  * Ignore all the burden codes that have total fixed percentage
  * not equal to 100.
  ***************************************************************/

  PROCEDURE refresh_fixed(v_from_alloc_code VARCHAR2,v_to_alloc_code VARCHAR2) IS
    CURSOR cur_alloc_fixed IS
      SELECT m.alloc_id,
             b.line_no,
             b.alloc_method,
             b.fixed_percent
      FROM   gl_aloc_mst m, gl_aloc_bas b
      WHERE  m.alloc_id = b.alloc_id
            AND  m.legal_entity_id = g_legal_entity_id
            AND  b.alloc_method = 1
            AND  m.alloc_code BETWEEN NVL(v_from_alloc_code,m.alloc_code) AND nvl(v_to_alloc_code,m.alloc_code)
            AND  m.delete_mark = 0
            AND  b.delete_mark = 0
            AND  100 = ( SELECT sum(bb.fixed_percent)
                         FROM   gl_aloc_bas bb
                         WHERE  bb.alloc_id = b.alloc_id and
        bb.delete_mark = 0
      )
      ORDER BY 1,2;
      l_local_module VARCHAR2(80) := '.refresh_fixed';
      l_previous_module VARCHAR2(4000);
   BEGIN
     l_previous_module := g_calling_module;
     g_calling_module := g_calling_module||l_local_module;
     alloc_log_msg( C_LOG_FILE, 'Deleting rows from Interface table gl_aloc_inp ...' );

    BEGIN
      DELETE
      FROM  gl_aloc_inp a
      WHERE  a.account_key_type = 0
        and a.calendar_code = g_calendar_code
    AND a.period_code = g_period_code
    and a.alloc_id in (
    select m.alloc_id
    from  gl_aloc_mst m,gl_aloc_bas b
    where m.legal_entity_id = g_legal_entity_id
    and m.alloc_id = b.alloc_id
    and b.alloc_method = 1
    and m.alloc_code between nvl(v_from_alloc_code,m.alloc_code)
      and nvl(v_to_alloc_code,m.alloc_code)
    );

    alloc_log_msg( C_LOG_FILE, TO_CHAR(SQL%ROWCOUNT) || ' Rows deleted from Interface table gl_aloc_inp' );
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       alloc_log_msg(C_LOG_FILE, '0 Rows deleted from gl_aloc_inp for fixed');

       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,g_calling_module,'0 Rows deleted from gl_aloc_inp for fixed');
       END IF;
    WHEN OTHERS THEN
     alloc_log_msg(C_LOG_FILE, to_char(SQLCODE) || ' ' || SQLERRM);

     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
     THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,g_calling_module,to_char(SQLCODE) || ' ' || SQLERRM);
     END IF;
    END ;
    g_calling_module := g_calling_module||l_local_module;
    FOR cur_aloc_fixed_tmp IN cur_alloc_fixed LOOP
      insert_alloc_inp(cur_aloc_fixed_tmp.alloc_id,
                       cur_aloc_fixed_tmp.line_no,
                       0,
                       NULL,
                       cur_aloc_fixed_tmp.fixed_percent
                      );

    END LOOP;
    g_calling_module := l_previous_module;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,g_calling_module||l_local_module||'.end','Completed successfully');
    END IF;

  END refresh_fixed;

 /********************************************************
  * PROCEDURE
  *    process_alloc_dtl
  *
  *  DESCRIPTION
  *    Retrieves all interface rows for a particular calendar
  *    and period and calculates the allocated amount,
  *    allocated percentage and populate allocation detail
  *    table.
  *  AUTHOR
  *    Sukarna Reddy      09/18/98
  *
  *  INPUT PARAMETERS
  *     v_from_alloc_code
  *     v_to_alloc_code
  *
  *  OUTPUT PARAMETERS
  *    <None>
  *
  *  HISTORY
  *
  *
  ********************************************************/

  PROCEDURE process_alloc_dtl(v_from_alloc_code VARCHAR2,
                              v_to_alloc_code   VARCHAR2) IS

    x_status NUMBER; /*B7458002*/

    CURSOR cur_glaloc_inp IS
      SELECT *
       FROM gl_aloc_inp i
      WHERE i.calendar_code = g_calendar_code
    AND i.period_code = g_period_code
            AND i.delete_mark = 0
            AND account_key_type = 0
        AND i.alloc_id IN (SELECT b.alloc_id
                               FROM gl_aloc_mst m,gl_aloc_bas b
                               where m.alloc_id = b.alloc_id
                                     AND m.legal_entity_id = g_legal_entity_id
                                     AND b.delete_mark = 0
                                     AND m.delete_mark = 0
                                     AND m.alloc_code BETWEEN nvl(v_from_alloc_code,m.alloc_code) and
                                                    nvl(v_to_alloc_code  ,m.alloc_code))
      ORDER BY alloc_id;
    CURSOR cur_alloc_code(v_alloc_id gl_aloc_mst.alloc_id%TYPE) IS
    SELECT alloc_code
    FROM gl_aloc_mst
    WHERE alloc_id = v_alloc_id;

    x_prev_alloc_id      gl_aloc_mst.alloc_id%TYPE   DEFAULT -99;
    x_prev_basis_amount  gl_aloc_inp.amount%TYPE     DEFAULT -99;
    x_expense_amount     gl_aloc_inp.amount%TYPE;
    x_alloc_percent      NUMBER;
    x_allocated_amount    gl_aloc_inp.amount%type;
    x_alloc_code    gl_aloc_mst.alloc_code%TYPE;
    l_local_module VARCHAR2(80) := '.process_aloc_dtl';
  BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,g_calling_module||l_local_module||'.begin',' Starting..');
    END IF;

    FOR cur_alocinp_tmp IN cur_glaloc_inp LOOP
      IF (X_prev_alloc_id <> cur_alocinp_tmp.alloc_id) THEN
        OPEN cur_alloc_code (cur_alocinp_tmp.alloc_id);
        FETCH cur_alloc_code INTO X_alloc_code;
        CLOSE cur_alloc_code;

        alloc_log_msg(C_LOG_FILE, '  Allocation Code: ' || x_alloc_code);

    /* Select total basis amount for calculating percentage.*/
        SELECT sum(amount) INTO X_prev_basis_amount
        FROM  gl_aloc_inp
        WHERE alloc_id = cur_alocinp_tmp.alloc_id
              AND calendar_code = g_calendar_code
              AND period_code = g_period_code
              AND account_key_type = 0;
        alloc_log_msg(C_LOG_FILE, '    Total Basis amount '||to_char(x_prev_basis_amount));

    /* Select total expense amount for allocation.*/
        SELECT sum(amount)
        INTO   x_expense_amount
        FROM   gl_aloc_inp
        WHERE alloc_id = cur_alocinp_tmp.alloc_id
              AND calendar_code = g_calendar_code
              AND period_code = g_period_code
              AND account_key_type = 1;
        alloc_log_msg(C_LOG_FILE, '    Total Expense amount '||to_char(X_expense_amount));
        x_prev_alloc_id := cur_alocinp_tmp.alloc_id;
      END IF;
      IF (X_prev_basis_amount > 0) THEN
       /* If the basis row is for fixed percentage.*/
        IF cur_alocinp_tmp.account_id IS NULL THEN
          x_alloc_percent := cur_alocinp_tmp.amount/100;
        ELSE
          x_alloc_percent := (cur_alocinp_tmp.amount/X_prev_basis_amount);
        END IF;
        x_allocated_amount := x_expense_amount*x_alloc_percent;
        x_alloc_percent := x_alloc_percent * 100;

      alloc_log_msg(C_LOG_FILE, '    Line: '||to_char (cur_alocinp_tmp.line_no) || ', % = '||to_char(round(x_alloc_percent,4)) ||
    ', Allocated Expense = ' ||to_char(round(x_allocated_amount,4)));

    /* Bug 7458002 - Commented
    INSERT INTO gl_aloc_dtl
      (
       PERIOD_ID,
       COST_TYPE_ID,
       ALLOC_ID,
       LINE_NO,
       ALLOCDTL_ID,
       PERCENT_ALLOCATION,
       ALLOCATED_EXPENSE_AMT,
       AC_STATUS,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       TRANS_CNT,
       DELETE_MARK,
       TEXT_CODE,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE
      )
     VALUES
     (
      g_period_id,
      g_cost_type_id,
      cur_alocinp_tmp.alloc_id,
      cur_alocinp_tmp.line_no,
      gem5_allocdtl_id_s.nextval,
      NVL(x_alloc_percent,0),
      NVL(x_allocated_amount,0),
      0,
      SYSDATE,
    P_created_by,
    P_login_id,
    SYSDATE,
    P_created_by,
    0,
    0,
    NULL,
    P_request_id,
    P_prog_application_id,
    P_program_id,
    SYSDATE
  ); */
    /* Bug 7458002 - replaced Insert with Merge */
    MERGE INTO gl_aloc_dtl gdtl
    USING ( SELECT g_period_id 		period_id,
      		g_cost_type_id 		cost_type_id,
      		cur_alocinp_tmp.alloc_id 	alloc_id,
      		cur_alocinp_tmp.line_no 	line_no
	    FROM dual
	  ) ginp
    ON    (    gdtl.period_id     = ginp.period_id
           AND gdtl.cost_type_id  = ginp.cost_type_id
           AND gdtl.alloc_id      = ginp.alloc_id
           AND gdtl.line_no       = ginp.line_no
          )
    WHEN MATCHED THEN
      UPDATE SET
       gdtl.PERCENT_ALLOCATION 		= NVL(x_alloc_percent,0)
       , gdtl.ALLOCATED_EXPENSE_AMT 	= NVL(x_allocated_amount,0)
       , gdtl.AC_STATUS 		= 0
       , gdtl.LAST_UPDATE_LOGIN 	= P_login_id
       , gdtl.LAST_UPDATE_DATE 		= SYSDATE
       , gdtl.LAST_UPDATED_BY 		= P_created_by
       , gdtl.TRANS_CNT 		= 0
       , gdtl.DELETE_MARK 		= 0
       , gdtl.TEXT_CODE 		= NULL
       , gdtl.REQUEST_ID 		= P_request_id
       , gdtl.PROGRAM_APPLICATION_ID 	= P_prog_application_id
       , gdtl.PROGRAM_ID 		= P_program_id
       , gdtl.PROGRAM_UPDATE_DATE 	= SYSDATE
    WHEN NOT MATCHED THEN
      INSERT
        (
        PERIOD_ID,
        COST_TYPE_ID,
        ALLOC_ID,
        LINE_NO,
        ALLOCDTL_ID,
        PERCENT_ALLOCATION,
        ALLOCATED_EXPENSE_AMT,
        AC_STATUS,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        TRANS_CNT,
        DELETE_MARK,
        TEXT_CODE,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE
        )
      VALUES
        (
        g_period_id,
        g_cost_type_id,
        cur_alocinp_tmp.alloc_id,
        cur_alocinp_tmp.line_no,
        gem5_allocdtl_id_s.nextval,
        NVL(x_alloc_percent,0),
        NVL(x_allocated_amount,0),
        0,
        SYSDATE,
        P_created_by,
        P_login_id,
        SYSDATE,
        P_created_by,
        0,
        0,
        NULL,
        P_request_id,
        P_prog_application_id,
        P_program_id,
        SYSDATE
        )
    ;
    END IF;
  END LOOP;

    /* Bug 7458002 - To delete obsoleted rows in gl_aloc_dtl (Start) */
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,g_calling_module||l_local_module||'.delete_allocations','deleting Allocations ...');
    END IF;
    delete_allocations(v_from_alloc_code, v_to_alloc_code, x_status);

    IF (x_status < 0)
    THEN
      return;
    END IF;
    /* Bug 7458002 - End */

  EXCEPTION
    WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,g_calling_module||l_local_module,to_char(SQLCODE)||' '||SQLERRM);
    END IF;
  END process_alloc_dtl;





 /*********************************************************************
  * PROCEDURE
  *   alloc_log_msg
  * DESCRIPTION
  *   Writes messages to FND_FILE.LOG or FND_FILE.OUTPUT
  *
  * INPUT PARAMETERS
  *   pi_file : indicates LOG(=1) or OUTPUT(=2) file
  *   pi_msg  : message to be printed
  *
  * OUTPUT PARAMETERS
  *   <None>
  *
  * HISTORY
  *   11-Nov-99 Rajesh Seshadri
  *
  *********************************************************************/

  PROCEDURE alloc_log_msg(
  pi_file IN NUMBER,
  pi_msg  IN VARCHAR2
  )
  IS
  l_dt  VARCHAR2(64);
  BEGIN

  l_dt := TO_CHAR( SYSDATE, 'YYYY-MM-DD HH24:MI:SS' );
  IF( pi_file = C_OUT_FILE)
  THEN
    FND_FILE.PUT_LINE( FND_FILE.OUTPUT, pi_msg || '   ' || l_dt );
  ELSE
    FND_FILE.PUT_LINE( FND_FILE.LOG, pi_msg || '   ' || l_dt );
  END IF;
  END alloc_log_msg;
END GMF_ALLOC_PROC;

/
