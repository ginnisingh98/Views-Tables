--------------------------------------------------------
--  DDL for Package Body IGI_ITR_TIMEOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_TIMEOUT_PKG" as
-- $Header: igiitrxb.pls 120.9.12000000.1 2007/09/12 10:33:24 mbremkum ship $
--

--**************************************************************************
-- Private procedure: Display log messages
-- ****************************************************************************
    PROCEDURE WriteToLogFile  (pp_mesg in varchar2) IS
        l_debug boolean := TRUE;
    BEGIN
       if l_debug then
        fnd_file.put_line( fnd_file.log , pp_mesg );
       else
         null;
       end if;
    END WriteToLogFile;

--
-- ********************************************************************
--  Procedure find_services
-- *********************************************************************
--

  /* Find services for the required set of books/ data access set,
  which need to be auto-approved
  ** due to no response within the auto approval exceed days limit
  ** Set their statuses to approved
  Modified this package to find services of all ledgers in R12 Data Access Set
  and auto approve them on 14-06-2007.
  */


  PROCEDURE find_services(errbuf            OUT NOCOPY VARCHAR2,
                          retcode           OUT NOCOPY VARCHAR2,
                          p_set_of_books_id IN NUMBER,
                          p_access_set_id IN NUMBER)

  IS

 /* Added this cursor for R12uptake Bug#6028574.
 This cursor lists all the ledgers which have a write access */
    CURSOR c_get_ledgers(p_access_set_id NUMBER)
    IS
              select distinct asl.ledger_id ledger_id from
        gl_access_set_ledgers_v asl, gl_access_sets_v asv
        where asl.access_set_id = asv.access_set_id
        and asl.access_set_id = p_access_set_id
        and asl.access_privilege_code in ('B','F')
        and asl.object_type_code = 'L'
        and asv.security_segment_code <> 'M'
        order by ledger_id;
  p_ledger_id NUMBER;

  BEGIN

    /* If Ledger Name is not passed for Concurrent Program "Automatic Approval
    of Service Lines", then call "find_ledger_services" procedure for each
    ledger in a Data Access Set otherwise call "find_ledger_services" procedure
    for the specified ledger.
    **/

        IF p_set_of_books_id is null THEN
            OPEN c_get_ledgers(p_access_set_id);
            LOOP
              FETCH c_get_ledgers INTO p_ledger_id;
              EXIT WHEN c_get_ledgers%NOTFOUND;
           find_ledger_services(errbuf, retcode, p_ledger_id);
            END LOOP;
            CLOSE c_get_ledgers;
        ELSE
           find_ledger_services(errbuf, retcode, p_set_of_books_id);
        END IF;
   /* Commit the changes which have been made
    */
       commit;
END find_services;

--
-- ********************************************************************
--  Procedure find_ledger_services
-- *********************************************************************
--
 /* The code in procedure "find_services" has been moved to "find_ledger_service s", which will be called for each ledger in a Data Access Set */
PROCEDURE find_ledger_services( errbuf        OUT NOCOPY VARCHAR2,
                            retcode           OUT NOCOPY VARCHAR2,
                          p_set_of_books_id IN NUMBER)
  IS
    CURSOR c_is_workflow_enabled(p_set_of_books_id NUMBER)
    IS
      SELECT nvl(use_workflow_flag,'N')
      FROM   igi_itr_charge_setup
      WHERE  set_of_books_id = p_set_of_books_id;

    l_workflow_enabled VARCHAR2(1);

    /* This cursor retrieves the number of days after which
    ** auto-approval takes place.  If no value has been set up
    ** the default value of 7 days should be used
    **/

    CURSOR c_get_timeout_days(p_set_of_books_id NUMBER)
    IS
      SELECT nvl(auto_approve_exceed_days,7)
      FROM   igi_itr_charge_setup
      WHERE  set_of_books_id = p_set_of_books_id;

    l_timeout_days NUMBER;


    /* This cursor retrieves the services which have been awaiting approval
    ** for longer than the specified time limit.  The status flag must be
    ** equal to 'V' - Awaiting Reciever Approval
    */

    CURSOR c_get_waiting_services(p_set_of_books_id NUMBER,
                                  p_timeout_days    NUMBER,
                                  p_header_id igi_itr_charge_headers.it_header_id%type  )--shsaxena
    IS
      SELECT it_service_line_id
      FROM   igi_itr_charge_lines lines
      WHERE  lines.set_of_books_id = p_set_of_books_id
      AND    sysdate > (lines.submit_date + p_timeout_days)
      AND    lines.status_flag = 'V'
      AND    lines.it_header_id=p_header_id;

      /*shsaxena for bug no 2782312*/
      CURSOR c_header_id  (p_set_of_books_id NUMBER,
                           p_timeout_days    NUMBER)
    IS
      SELECT Distinct it_header_id from igi_itr_charge_lines lines
      WHERE  lines.set_of_books_id = p_set_of_books_id
      AND    sysdate > (lines.submit_date + p_timeout_days)
      AND    lines.status_flag = 'V';
      /*shsaxena for bug no 2782312*/


    l_it_service_line_id  NUMBER;
    l_it_header_id      igi_itr_charge_lines.it_header_id%type;  --shsaxena for bug 2782312
    l_sequence_num NUMBER;
    l_rec_fnd_user_id NUMBER;
    l_user_id NUMBER := fnd_global.user_id;
    l_conc_login_id NUMBER := fnd_global.conc_login_id;
    l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
    l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
    l_event_level number	:=	FND_LOG.LEVEL_EVENT;
    l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
    l_error_level number	:=	FND_LOG.LEVEL_ERROR;
    l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;



  BEGIN

    /* Check if workflow is enabled for the set of books
    ** If it is, do nothing and exit
    **/


    OPEN c_is_workflow_enabled(p_set_of_books_id);
    FETCH c_is_workflow_enabled INTO l_workflow_enabled;
    IF c_is_workflow_enabled%NOTFOUND THEN
      l_workflow_enabled := 'N';
    END IF;
    CLOSE c_is_workflow_enabled;

    IF l_workflow_enabled = 'Y' THEN
      IF (l_state_level >= l_debug_level ) THEN
         FND_LOG.STRING( l_state_level,'igi.plsql.igiitrxb.IGI_ITR_TIMEOUT_PKG.find_services','Workflow is enabled for the set of books ');
      END IF;

      return;
    END IF;


    /* Fetch the number of days after which auto-approval should occur.
    ** This is set up at the ITR set options level, per set of books.
    */

     OPEN c_get_timeout_days(p_set_of_books_id);
     FETCH c_get_timeout_days INTO l_timeout_days;
     IF c_get_timeout_days%NOTFOUND THEN
       l_timeout_days := 7;
     END IF;
     CLOSE c_get_timeout_days;

    	IF (l_state_level >= l_debug_level ) THEN
         FND_LOG.STRING( l_state_level,'igi.plsql.igiitrxb.IGI_ITR_TIMEOUT_PKG.find_services','Service lines will be auto approved if waiting for '||l_timeout_days );
        END IF;

     /*shsaxena for bug no 2782312*/
   OPEN  c_header_id (p_set_of_books_id ,l_timeout_days);
   LOOP
      FETCH c_header_id INTO l_it_header_id;
      IF c_header_id%NOTFOUND THEN
       IF (l_state_level >= l_debug_level ) THEN
         FND_LOG.STRING( l_state_level,'igi.plsql.igiitrxb.IGI_ITR_TIMEOUT_PKG.find_services','There are no more service lines awaiting approval for set of books '||p_set_of_books_id );
        END IF;
        EXIT;
      END IF;

      OPEN  c_get_waiting_services(p_set_of_books_id
                                 ,l_timeout_days,
                                  l_it_header_id);
      LOOP
      FETCH c_get_waiting_services INTO l_it_service_line_id;
      EXIT WHEN c_get_waiting_services%NOTFOUND;


      UPDATE igi_itr_charge_lines
      SET    status_flag = 'A'
            ,last_updated_by = l_user_id
            ,last_update_login = l_conc_login_id
            ,last_update_date = sysdate
      WHERE  it_service_line_id = l_it_service_line_id;

      IF (l_state_level >= l_debug_level ) THEN
         FND_LOG.STRING( l_state_level,'igi.plsql.igiitrxb.IGI_ITR_TIMEOUT_PKG.find_services','Service line id '||l_it_service_line_id||' has been auto approved');
      END IF;
      /* Now need to update the action history table with information
      ** indicating that the service line has been auto-approved.
      ** So start by fetching all the information needed for insertion
      ** into the action history table
      */

      SELECT max(sequence_num) + 1
      INTO   l_sequence_num
      FROM   igi_itr_action_history
      WHERE  it_service_line_id = l_it_service_line_id;

      /* Find the fnd user id of the receiver for the service line
      */

      SELECT auth.authoriser_id
      INTO   l_rec_fnd_user_id
      FROM   igi_itr_charge_ranges auth
            ,igi_itr_charge_lines itrl
      WHERE  itrl.it_service_line_id = l_it_service_line_id
      AND    itrl.charge_range_id = auth.charge_range_id;


      /* Call common package to insert record into action
      ** history table
      */

      igi_itr_action_history_ss_pkg.insert_row(
             X_Service_Line_Id   => l_it_service_line_id
            ,X_Sequence_Num      => l_sequence_num
            ,X_Action_Code       => 'U'
            ,X_Action_Date       => sysdate
            ,X_Employee_Id       => l_rec_fnd_user_id
            ,X_Use_Workflow_Flag => 'N'
            ,X_Note              => null
            ,X_Created_By        => l_user_id
            ,X_Creation_Date     => sysdate
            ,X_Last_Update_Login => l_conc_login_id
            ,X_Last_Update_Date  => sysdate
            ,X_Last_Updated_By   => l_user_id
             );

      IF (l_state_level >= l_debug_level ) THEN
         FND_LOG.STRING( l_state_level,'igi.plsql.igiitrxb.IGI_ITR_TIMEOUT_PKG.find_services','Action History table has been updated for service line id '||l_it_service_line_id );
      END IF;


    END LOOP;
    CLOSE c_get_waiting_services;
    IGIGITCH.update_header_status(l_it_header_id);

  END LOOP;
  CLOSE c_header_id;
 /*shsaxena for bug no 2782312*/

   EXCEPTION
    WHEN OTHERS
    THEN
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_TIMEOUT_TEST_PKG.find_services',TRUE);
    END IF;
    raise_application_error
    (-20001,'IGI_ITR_TIMEOUT_TEST_PKG.find_services'||SQLERRM);

END find_ledger_services;


END IGI_ITR_TIMEOUT_PKG;

/
