--------------------------------------------------------
--  DDL for Package Body FV_FACTS_GL_PKG_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FACTS_GL_PKG_EXT" AS
/* $Header: FVFCVCUB.pls 120.1.12000000.3 2007/03/08 21:45:40 snama ship $*/
  g_module_name         VARCHAR2(100);
  g_FAILURE             NUMBER;
  g_SUCCESS             NUMBER;
  g_WARNING             NUMBER;
  g_request_id          NUMBER;
  g_user_id             NUMBER;
  g_login_id            NUMBER;
  g_set_of_books_id     NUMBER;
  g_enter               VARCHAR2(10);
  g_exit                VARCHAR2(10);
  g_conc_program_id     NUMBER;
  g_conc_program_name   fnd_concurrent_programs.concurrent_program_name%TYPE;

  --****************************************************************************************--
  --*          Name : initialize_global_variables                                          *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : To initialize all global variables                                   *--
  --*    Parameters : None                                                                 *--
  --*   Global Vars : As in procedure                                                      *--
  --*   Called from : Called when initializing the package                                 *--
  --*         Calls : None                                                                 *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : No Logic                                                             *--
  --****************************************************************************************--
  PROCEDURE initialize_global_variables
  IS
  BEGIN
    g_module_name         := 'fv.plsql.fv_facts_gl_pkg_ext.';
    g_FAILURE             := -1;
    g_SUCCESS             := 0;
    g_WARNING             := -2;
    g_request_id          := fnd_global.conc_request_id;
    g_user_id             := fnd_global.user_id;
    g_login_id            := fnd_global.login_id;
    g_conc_program_id     := fnd_global.conc_program_id;
    -- Commented out for la uptake
    -- g_set_of_books_id     := TO_NUMBER(fnd_profile.value('GL_SET_OF_BKS_ID'));
    g_enter               := 'ENTER';
    g_exit                := 'EXIT';
  END;

  --****************************************************************************************--
  --*          Name : get_fed_system_parameters                                            *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : To get the federal system parameters                                 *--
  --*    Parameters : p_vendor_attribute   OUT Vendor Attribute column                     *--
  --*               : p_customer_attribute OUT Customer Attribute Column                   *--
  --*               : p_errbuf             OUT Error Message                               *--
  --*               : p_retcode            OUT Return Code                                 *--
  --*   Global Vars : g_SUCCESS                                                            *--
  --*               : g_FAILURE                                                            *--
  --*               : g_enter                                                              *--
  --*               : g_exit                                                               *--
  --*               : fnd_log.level_procedure                                              *--
  --*               : g_module_name                                                        *--
  --*               : fnd_log.g_current_runtime_level                                      *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.level_unexpected                                             *--
  --*   Called from : process_parameters                                                   *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_system_parameters SELECT                                          *--
  --*         Logic : Select Vendor Attribute Column and Customer Attribute Column         *--
  --*               : from fv_system_parameters                                            *--
  --****************************************************************************************--
  PROCEDURE get_fed_system_parameters
  (
    p_vendor_attribute   OUT NOCOPY VARCHAR2,
    p_customer_attribute OUT NOCOPY VARCHAR2,
    p_errbuf             OUT NOCOPY VARCHAR2,
    p_retcode            OUT NOCOPY NUMBER
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'get_fed_system_parameters';
    p_retcode := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '*****INPUT PARAMETERS*******');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'None');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '****************************');
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'SELECT from fv_system_parameters');
    END IF;
    SELECT fsp.factsi_customer_attribute,
           fsp.factsi_vendor_attribute
      INTO p_customer_attribute,
           p_vendor_attribute
      FROM fv_system_parameters fsp;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '*****OUTPUT PARAMETERS******');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_vendor_attribute   = '||p_vendor_attribute);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_customer_attribute = '||p_customer_attribute);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_errbuf             = '||p_errbuf);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_retcode            = '||p_retcode);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '****************************');
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : process_parameters                                                   *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : To process all the input parameters to the program                   *--
  --*    Parameters : p_vendor_or_cust    IN  Vendor (V) or Customer (C).                  *--
  --*               : p_vendor_or_cust_id IN  Vendor or Customer Id                        *--
  --*               : p_from_period       IN  From Period                                  *--
  --*               : p_to_period         IN  To Period                                    *--
  --*               : p_vendor_type       OUT Vendor Type                                  *--
  --*               : p_elimination_id    OUT Edlimination Id                              *--
  --*               : p_period_year       OUT Period Year                                  *--
  --*               : p_from_period_num   OUT From Period Number                           *--
  --*               : p_to_period_num     OUT To Period Number                             *--
  --*               : p_errbuf            OUT Error Message                                *--
  --*               : p_retcode           OUT Return Code                                  *--
  --*   Global Vars : g_SUCCESS                                                            *--
  --*               : g_FAILURE                                                            *--
  --*               : g_enter                                                              *--
  --*               : g_exit                                                               *--
  --*               : fnd_log.level_procedure                                              *--
  --*               : g_module_name                                                        *--
  --*               : fnd_log.g_current_runtime_level                                      *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.level_unexpected                                             *--
  --*               : g_conc_program_id                                                    *--
  --*               : g_conc_program_id                  WRITE                             *--
  --*   Called from : main                                                                 *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*               : get_fed_system_parameters                                            *--
  --*   Tables Used : gl_period_statuses      SELECT                                       *--
  --*               : po_vendors              SELECT                                       *--
  --*               : ra_customers            SELECT                                       *--
  --*               : fnd_concurrent_programs SELECT                                       *--
  --*         Logic :                                                                      *--
  --****************************************************************************************--
  PROCEDURE process_parameters
  (
    p_ledger_id         IN  NUMBER,
    p_vendor_or_cust    IN  VARCHAR2,
    p_vendor_or_cust_id IN  NUMBER,
    p_from_period       IN  VARCHAR2,
    p_to_period         IN  VARCHAR2,
    p_vendor_type       OUT NOCOPY VARCHAR2,
    p_elimination_id    OUT NOCOPY VARCHAR2,
    p_period_year       OUT NOCOPY NUMBER,
    p_from_period_num   OUT NOCOPY NUMBER,
    p_to_period_num     OUT NOCOPY NUMBER,
    p_errbuf            OUT NOCOPY VARCHAR2,
    p_retcode           OUT NOCOPY NUMBER
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
    l_customer_attribute  fv_system_parameters.factsi_customer_attribute%TYPE;
    l_vendor_attribute    fv_system_parameters.factsi_vendor_attribute%TYPE;
    l_period_year         gl_period_statuses.period_year%TYPE;
    l_select_stmt         VARCHAR2(1024);
    l_cursor_id           INTEGER;
    l_ignore              INTEGER;
  BEGIN
    l_module_name := g_module_name || 'process_parameters';
    p_retcode := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '*****INPUT PARAMETERS*******');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_ledger_id         = '||p_ledger_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_vendor_or_cust    = '||p_vendor_or_cust);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_vendor_or_cust_id = '||p_vendor_or_cust_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_from_period       = '||p_from_period);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_to_period         = '||p_to_period);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '****************************');
    END IF;

    IF (NVL(p_vendor_or_cust, 'X') NOT IN ('V', 'C')) THEN
      p_retcode := g_FAILURE;
      p_errbuf := 'Unknown Vendor or Customer Type Idenfier. Should be either V or C.';
      l_location   := l_module_name||'p_vendor_or_cust_required';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
    END IF;

    IF (p_vendor_or_cust_id IS NULL) THEN
      p_retcode := g_FAILURE;
      p_errbuf := 'Vendor or Customer Information is required';
      l_location   := l_module_name||'p_vendor_or_cust_id_required';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
    END IF;

    IF (p_from_period IS NULL) THEN
      p_retcode := g_FAILURE;
      p_errbuf := 'From Period is required';
      l_location   := l_module_name||'from_period_required';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
    END IF;

    IF (p_to_period IS NULL) THEN
      p_retcode := g_FAILURE;
      p_errbuf := 'To Period is required';
      l_location   := l_module_name||'to_period_required';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        SELECT gps.period_year,
               gps.period_num
          INTO p_period_year,
               p_from_period_num
          FROM gl_period_statuses gps
         WHERE gps.application_id = 101
           AND gps.ledger_id = p_ledger_id         --g_set_of_books_id
           AND gps.period_name = p_from_period;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_retcode := g_FAILURE;
          p_errbuf := 'No From Period found '||p_from_period;
          l_location   := l_module_name||'select_gl_period_statuses1';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
          END IF;
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location   := l_module_name||'select_gl_period_statuses1';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
          END IF;
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        SELECT gps.period_year,
               gps.period_num
          INTO l_period_year,
               p_to_period_num
          FROM gl_period_statuses gps
         WHERE gps.application_id = 101
           AND gps.ledger_id = p_ledger_id         --g_set_of_books_id
           AND gps.period_name = p_to_period;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_retcode := g_FAILURE;
          p_errbuf := 'No To Period found '||p_from_period;
          l_location   := l_module_name||'select_gl_period_statuses1';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
          END IF;
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location   := l_module_name||'select_gl_period_statuses1';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
          END IF;
      END;
    END IF;

    IF (p_period_year <> l_period_year) THEN
      p_retcode := g_FAILURE;
      p_errbuf := 'From Period Name and To Period Name are from 2 different fiscal years.';
      l_location   := l_module_name||'period_year_mismatch';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
    END IF;

    IF (p_from_period_num > p_to_period_num) THEN
      p_retcode := g_FAILURE;
      p_errbuf := 'From Period Name is greater than To Period Name.';
      l_location   := l_module_name||'period_name_mismatch';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Calling get_fed_system_parameters');
      END IF;
      get_fed_system_parameters
      (
        p_vendor_attribute   => l_vendor_attribute,
        p_customer_attribute => l_customer_attribute,
        p_errbuf             => p_errbuf,
        p_retcode            => p_retcode
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'Returned from get_fed_system_parameters');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_vendor_attribute   = '||l_vendor_attribute);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_customer_attribute = '||l_customer_attribute);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_errbuf             = '||p_errbuf);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_retcode            = '||p_retcode);
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (p_vendor_or_cust = 'V') THEN
        l_select_stmt := 'SELECT vendor_type_lookup_code vendor_type, '||
                                 l_vendor_attribute||' elimnation_id '||
                           'FROM po_vendors
                           WHERE vendor_id = :p_vendor_or_cust_id';
      ELSE
        l_select_stmt := 'SELECT customer_class_code vendor_type, '||
                                 l_customer_attribute||' elimnation_id '||
                           'FROM ra_customers
                           WHERE customer_id = :p_vendor_or_cust_id';
      END IF;

      BEGIN
        l_cursor_id := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor_id, l_select_stmt, dbms_sql.v7);
        dbms_sql.define_column(l_cursor_id, 1, p_vendor_type, 30);
        dbms_sql.define_column(l_cursor_id, 2, p_elimination_id, 150);
        dbms_sql.bind_variable(l_cursor_id,':p_vendor_or_cust_id',p_vendor_or_cust_id);
        l_ignore := dbms_sql.execute(l_cursor_id);
        p_vendor_type := NULL;
        p_elimination_id := NULL;
        LOOP
          l_ignore := dbms_sql.fetch_rows(l_cursor_id);
          EXIT WHEN l_ignore= 0;
          dbms_sql.column_value(l_cursor_id, 1, p_vendor_type);
          dbms_sql.column_value(l_cursor_id, 2, p_elimination_id);
          EXIT;
        END LOOP;
        dbms_sql.close_cursor(l_cursor_id);
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location   := l_module_name||'select_gl_period_statuses1';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
          END IF;
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        SELECT concurrent_program_name
          INTO g_conc_program_name
          FROM fnd_concurrent_programs fcp
         WHERE fcp.concurrent_program_id = g_conc_program_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          g_conc_program_name := 'UNKNOWN ('||g_conc_program_id||')';
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location   := l_module_name||'select_fnd_concurrent_programs';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
          END IF;
      END;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '*****OUTPUT PARAMETERS******');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_vendor_type     = '||p_vendor_type);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_elimination_id  = '||p_elimination_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_period_year     = '||p_period_year);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_from_period_num = '||p_from_period_num);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_to_period_num   = '||p_to_period_num);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_errbuf          = '||p_errbuf);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_retcode         = '||p_retcode);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '****************************');
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : main                                                                 *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Called from the concurrent programs FACTS I Update Customer DFF and  *--
  --*               : FACTS I Update Vendor DFF,                                           *--
  --*    Parameters : p_errbuf            OUT Error Message                                *--
  --*               : p_retcode           OUT Return Code                                  *--
  --*               : p_ledger_id         IN  Ledger_id     (added for LA uptake)          *--
  --*               : p_vendor_or_cust_id IN  Vendor or Customer Id                        *--
  --*               : p_from_period       IN  From Period                                  *--
  --*               : p_to_period         IN  To Period                                    *--
  --*               : p_vendor_or_cust    IN  Vendor (V) or Customer (C).                  *--
  --*   Global Vars : g_SUCCESS                                                            *--
  --*               : g_FAILURE                                                            *--
  --*               : g_enter                                                              *--
  --*               : g_exit                                                               *--
  --*               : fnd_log.level_procedure                                              *--
  --*               : g_module_name                                                        *--
  --*               : fnd_log.g_current_runtime_level                                      *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.level_unexpected                                             *--
  --*               : g_conc_program_name                                                  *--
  --*               : g_user_id                                                            *--
  --*               : g_login_id                                                           *--
  --*               : g_set_of_books_id                                                    *--
  --*   Called from : FACTS I Update Vendor DFF (Concurrent Program) (FVFCTUVE)            *--
  --*               : FACTS I Update Customer DFF (Concurrent Program) (FVFCTUCU)          *--
  --*         Calls : process_parameters                                                   *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_facts_line_balances                                               *--
  --*         Logic :                                                                      *--
  --****************************************************************************************--
  PROCEDURE main
  (
    p_errbuf            OUT NOCOPY VARCHAR2,
    p_retcode           OUT NOCOPY NUMBER,
    p_ledger_id         IN  NUMBER,
    p_vendor_or_cust_id IN  NUMBER,
    p_from_period       IN  VARCHAR2,
    p_to_period         IN  VARCHAR2,
    p_vendor_or_cust    IN  VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);

    l_vendor_type         po_vendors.vendor_type_lookup_code%TYPE;
    l_elimination_id      po_vendors.attribute1%TYPE;
    l_from_period_num     gl_period_statuses.period_num%TYPE;
    l_to_period_num       gl_period_statuses.period_num%TYPE;
    l_period_year         gl_period_statuses.period_year%TYPE;
    l_rows                NUMBER := 0;
    l_tot_rows            NUMBER := 0;


  BEGIN
    l_module_name := g_module_name || 'main';
    p_retcode := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '*****INPUT PARAMETERS*******');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_ledger_id         = '||p_ledger_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_vendor_or_cust    = '||p_vendor_or_cust);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_vendor_or_cust_id = '||p_vendor_or_cust_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_from_period       = '||p_from_period);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_to_period         = '||p_to_period);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '****************************');
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling process_parameters');
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      process_parameters
      (
        p_ledger_id         => p_ledger_id,
        p_vendor_or_cust    => p_vendor_or_cust,
        p_vendor_or_cust_id => p_vendor_or_cust_id,
        p_from_period       => p_from_period,
        p_to_period         => p_to_period,
        p_vendor_type       => l_vendor_type,
        p_elimination_id    => l_elimination_id,
        p_period_year       => l_period_year,
        p_from_period_num   => l_from_period_num,
        p_to_period_num     => l_to_period_num,
        p_errbuf            => p_errbuf,
        p_retcode           => p_retcode
      );
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Returned from process_parameters');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_vendor_type     = '||l_vendor_type);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_elimination_id  = '||l_elimination_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_period_year     = '||l_period_year);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_from_period_num = '||l_from_period_num);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_to_period_num   = '||l_to_period_num);
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Updating fv_facts_period_balances');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_elimination_id    = '||l_elimination_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_vendor_type       = '||l_vendor_type);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_period_year       = '||l_period_year);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_from_period_num   = '||l_from_period_num);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_to_period_num     = '||l_to_period_num);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'g_set_of_books_id   = '||g_set_of_books_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_vendor_or_cust    = '||p_vendor_or_cust);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_ledger_id         = '||p_ledger_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_vendor_or_cust_id = '||p_vendor_or_cust_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'g_conc_program_name = '||g_conc_program_name);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'g_user_id           = '||g_user_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'g_login_id          = '||g_login_id);
        END IF;

        FOR sob_rec IN (SELECT set_of_books_id
                        FROM   fv_facts1_run
                        WHERE  fiscal_year = l_period_year)
         LOOP

           UPDATE fv_facts1_line_balances ffpb
              SET ffpb.party_classification = l_vendor_type,
                  ffpb.eliminations_dept =
                    DECODE (l_vendor_type, 'FEDERAL', SUBSTR(NVL(l_elimination_id, '00'), 1, 6), '  '),
                  g_ng_indicator = DECODE(l_vendor_type, 'FEDERAL', 'F', 'N')
            WHERE ffpb.party_id = p_vendor_or_cust_id
              AND ffpb.party_type = p_vendor_or_cust
              AND ffpb.set_of_books_id = sob_rec.set_of_books_id
              AND ffpb.period_year = l_period_year
              AND ffpb.period_num BETWEEN l_from_period_num AND l_to_period_num;

	   l_rows := SQL%ROWCOUNT;
           l_tot_rows := l_tot_rows + SQL%ROWCOUNT;


           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,
                 'Updated fv_facts1_line_balances');
             fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,l_rows||' rows updated.');
             fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'for set of books id: '|| sob_rec.set_of_books_id);
           END IF;


        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location   := l_module_name||'update_fv_facts1_line_balances';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
          END IF;
      END;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '*****OUTPUT PARAMETERS******');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_errbuf         = '||p_errbuf);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'p_retcode        = '||p_retcode);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, '****************************');
    END IF;

    fv_utility.log_mesg(fnd_log.level_statement, l_module_name, 'UPDATED '||l_tot_rows||' ROWS IN FV_FACTS1_LINE_BALANCES.');

    l_tot_rows := 0;


    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
      ROLLBACK;
  END;

BEGIN
  initialize_global_variables;
END fv_facts_gl_pkg_ext;

/
