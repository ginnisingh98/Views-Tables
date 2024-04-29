--------------------------------------------------------
--  DDL for Package Body IGI_EXP_HOLDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_HOLDS" AS
-- $Header: igiexprb.pls 120.16.12000000.1 2007/09/13 04:24:26 mbremkum ship $

   /* ============== FND LOG VARIABLES ================== */
      l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
      l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
      l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
      l_event_level   number := FND_LOG.LEVEL_EVENT ;
      l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
      l_error_level   number := FND_LOG.LEVEL_ERROR ;
      l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

   /* =================== DEBUG_LOG_UNEXP_ERROR =================== */
   Procedure Debug_log_unexp_error (P_module     IN VARCHAR2,
                                    P_error_type IN VARCHAR2)
   IS

   BEGIN

    IF (l_unexp_level >= l_debug_level) THEN

       IF   (P_error_type = 'DEFAULT') THEN
             FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
             FND_MESSAGE.SET_TOKEN('CODE',sqlcode);
             FND_MESSAGE.SET_TOKEN('MSG',sqlerrm);
             FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igiexprb.igi_exp_holds.' || P_module ,TRUE);
       ELSIF (P_error_type = 'USER') THEN
             FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igiexprb.igi_exp_holds.' || P_module ,TRUE);
       END IF;

    END IF;

  END Debug_log_unexp_error;

   /* =================== DEBUG_LOG_STRING =================== */
   Procedure Debug_log_string (P_level   IN NUMBER,
                               P_module  IN VARCHAR2,
                               P_Message IN VARCHAR2)
   IS

   BEGIN

     IF (P_level >= l_debug_level) THEN
         FND_LOG.STRING(P_level, 'igi.plsql.igiexprb.igi_exp_holds.' || P_module, P_message) ;
     END IF;

   END Debug_log_string;

   --============================================================================
   -- SET_HOLD: Puts an EXP hold on the invoice
   --============================================================================
   PROCEDURE Set_Hold(p_invoice_id       IN     NUMBER,
                      p_calling_sequence IN OUT NOCOPY VARCHAR2)
   IS
   -- Bug No:2517124
   -- using ap_lookup_codes table to get the hold reason
   CURSOR c_get_hold_reason
   IS
     select displayed_field from ap_lookup_codes
     where lookup_type = 'HOLD CODE'
     and  lookup_code = 'AWAIT EXP APP';

      l_debug_loc  VARCHAR2(30);
      l_debug_info VARCHAR2(250);
      -- Bug No:2517124
      l_get_hold_reason     c_get_hold_reason%rowtype;

   BEGIN

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Set_hold.Msg1',
                            ' ** BEGIN SET_HOLD ** ');
      -- =============== END DEBUG LOG ==================

      -- GSCC File.sql.35
      l_debug_loc := 'Set_Hold';

      -- Update the calling sequence
      p_calling_sequence := 'IGI_EXP_HOLDS.'||l_debug_loc||'<-'|| p_calling_sequence;

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Set_hold.Msg2',
                            ' p_Calling_Sequence --> ' || p_calling_sequence);
      -- =============== END DEBUG LOG ==================

      -- Bug No:2517124
      Open c_get_hold_reason;
      fetch c_get_hold_reason into l_get_hold_reason;
      close c_get_hold_reason;

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Set_hold.Msg3',
                           ' l_get_hold_reason --> ' || l_get_hold_reason.displayed_field);
      -- =============== END DEBUG LOG ==================

      -- Bug#5905190 : Add Hold Id, org_id column while inserting
      INSERT INTO ap_holds
         (invoice_id,
          hold_lookup_code,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          held_by,
          hold_date,
          hold_reason,
          status_flag,
          hold_id,
          org_id)
      SELECT p_invoice_id,
             'AWAIT EXP APP',
             SYSDATE,
             5,
             SYSDATE,
             5,
             5,
             SYSDATE,
             -- Bug No:2517124
             l_get_hold_reason.displayed_field,  --'Exchange Protocol Hold',
             'S',
             AP_HOLDS_S.NEXTVAL,
             mo_global.get_current_org_id()
      FROM   SYS.DUAL
      WHERE  NOT EXISTS(SELECT 'x'
                        FROM ap_holds_all ah2
                        WHERE ah2.invoice_id = p_invoice_id
                        AND ah2.hold_lookup_code = 'AWAIT EXP APP'
                        AND (NVL(ah2.release_lookup_code, 'NULL') <> 'HOLDS QUICK RELEASED'
        AND NVL(ah2.release_lookup_code, 'NULL') <> 'EXP HOLD RELEASE'));

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Set_hold.Msg4',
                           ' INSERT INTO ap_holds --> ' || SQL%ROWCOUNT);
          Debug_log_string (l_proc_level, 'Set_hold.Msg1',
                            ' ** END SET_HOLD ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Set_hold.unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
         END IF;
         RAISE_APPLICATION_ERROR(-20001, fnd_message.get);
   END Set_Hold;

   --============================================================================
   -- RELEASE_HOLD:  Procedure to release a hold from an invoice
   --============================================================================

   PROCEDURE Release_Hold(p_invoice_id       IN     NUMBER,
                          p_hold_lookup_code IN     VARCHAR2,
                          p_calling_sequence IN OUT NOCOPY VARCHAR2)
   IS
      l_release_lookup_code VARCHAR2(30);
      l_debug_loc           VARCHAR2(30);
      l_debug_info          VARCHAR2(250);
   BEGIN

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Release_hold.Msg1',
                            ' ** START RELEASE_HOLD ** ');
      -- =============== END DEBUG LOG ==================

      --Initialize variables inside BEGIN bacause of GSCC Standard - File.sql.35
      l_release_lookup_code := 'EXP HOLD RELEASE';
      l_debug_loc           :='Release_Hold';

      -- Update the calling sequence
      p_calling_sequence := 'IGI_EXP_HOLDS.'||l_debug_loc||'<-'||
                                 p_calling_sequence;

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Release_hold.Msg2',
                            ' p_calling_sequence --> ' || p_calling_sequence);
      -- =============== END DEBUG LOG ==================

      -- Bug No: 2517124 sowsubra changed the statement to select the
    -- displayed_field column instead of the description column.
      UPDATE ap_holds_all
      SET    release_lookup_code = l_release_lookup_code,
             release_reason = (SELECT displayed_field
                               FROM   ap_lookup_codes
                               WHERE  lookup_code = l_release_lookup_code
                               AND    lookup_type = 'HOLD CODE'),
             last_update_date = SYSDATE,
             last_updated_by = 5,
             status_flag = 'R'
      WHERE  invoice_id = p_invoice_id
      AND    hold_lookup_code = p_hold_lookup_code;

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Release_hold.Msg3',
                            ' UPDATE ap_holds_all --> ' || SQL%ROWCOUNT);
          Debug_log_string (l_proc_level, 'Set_hold.Msg4',
                            ' ** END RELEASE_HOLD ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Release_hold.unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
         END IF;
         RAISE_APPLICATION_ERROR(-20001, fnd_message.get);
   END Release_Hold;

   --===================================================================
   -- GET_HOLD_STATUS: Gets the status of the hold as -
   --                  ALREADY ON HOLD, RELEASED BY USER or NOT ON HOLD.
   --===================================================================

   PROCEDURE Get_Hold_Status(p_invoice_id       IN     NUMBER,
                             p_hold_lookup_code IN     VARCHAR2,
                             p_status           IN OUT NOCOPY VARCHAR2,
                             p_calling_sequence IN OUT NOCOPY VARCHAR2)
   IS
      l_debug_loc  VARCHAR2(30);
      l_debug_info VARCHAR2(250);

      CURSOR c_hold_status IS
         SELECT DECODE(release_lookup_code,
                       NULL, 'ALREADY ON HOLD',
                       'RELEASED BY USER')
         FROM   ap_holds_all
         WHERE  invoice_id = p_invoice_id
         AND    hold_lookup_code = p_hold_lookup_code
         AND    release_lookup_code IS NULL;
   BEGIN
      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Get_hold_status.Msg1',
                            ' ** START GET_HOLD_STATUS ** ');
      -- =============== END DEBUG LOG ==================

      --Initialize variables inside BEGIN bacause of GSCC Standard - File.sql.35
      l_debug_loc :='Get_Hold_Status';
      -- Initialize to NOT ON HOLD in case the CURSOR retrieves no records.
      p_status := 'NOT ON HOLD';
      -- Update the calling sequence
      p_calling_sequence := 'IGI_EXP_HOLDS.'||l_debug_loc||'<-'||
                                              p_calling_sequence;

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Get_hold_status.Msg2',
                            ' p_calling_sequence --> ' || p_calling_sequence);
      -- =============== END DEBUG LOG ==================

      OPEN c_hold_status;
      FETCH c_hold_status INTO p_status;
      CLOSE c_hold_status;

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Get_hold_status.Msg3',
                            ' p_status --> ' || p_status);
          Debug_log_string (l_proc_level, 'Get_hold_status.Msg4',
                            ' ** END GET_HOLD_STATUS ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Get_hold_status.unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
         END IF;
         RAISE_APPLICATION_ERROR(-20001, fnd_message.get);
   END Get_Hold_Status;

   --=====================================================================
   -- Get_Approval_Status: Gets the invoice level approval status as -
   --                      'APPROVED','NEEDS REAPPROVAL','NEVER APPROVED',
   --                      'CANCELLED'
   --====================================================================

   FUNCTION Get_Approval_Status(p_invoice_id       IN     NUMBER,
                                p_calling_sequence IN OUT NOCOPY VARCHAR2)
                                RETURN VARCHAR2
   IS
      l_invoice_approval_status    VARCHAR2(25);
      l_invoice_approval_flag      VARCHAR2(1);
      l_distribution_approval_flag VARCHAR2(1);
      l_encumbrance_flag           VARCHAR2(1);
      l_invoice_holds              NUMBER;
      l_cancelled_date             DATE;
      l_debug_loc                  VARCHAR2(30);
      l_debug_info                 VARCHAR2(250) ;

      CURSOR c_dist_approval_status
      IS
          SELECT match_status_flag
             FROM   ap_invoice_distributions_all
             WHERE  invoice_id = p_invoice_id
          UNION
          SELECT 'N'
             FROM   ap_invoice_distributions_all
             WHERE  invoice_id = p_invoice_id
             AND    match_status_flag IS NULL
             AND EXISTS
                (SELECT 'There are both untested and tested lines'
                 FROM   ap_invoice_distributions_all
                 WHERE  invoice_id = p_invoice_id
                 AND    match_status_flag IN ('T','A'));


   BEGIN

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Get_Approval_status.Msg1',
                            ' ** START GET_APPROVAL_STATUS ** ');
      -- =============== END DEBUG LOG ==================

      -- Initialize variables inside BEGIN bacause of GSCC Standard - File.sql.35
      l_debug_loc := 'get_approval_status';
      p_calling_sequence := 'IGI_EXP_HOLDS.'||l_debug_loc||'<-'||
                                 p_calling_sequence;

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Get_Approval_status.Msg2',
                            ' p_calling_sequence --> ' || p_calling_sequence);
      -- =============== END DEBUG LOG ==================

      -- Get the encumbrance flag
      SELECT NVL(purch_encumbrance_flag,'N')
      INTO   l_encumbrance_flag
      FROM   financials_system_parameters;

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Get_Approval_status.Msg3',
                            ' l_encumbrance_flag --> ' || l_encumbrance_flag);
      -- =============== END DEBUG LOG ==================

      -- Get the number of unreleased holds for the invoice
      SELECT COUNT(*)
      INTO   l_invoice_holds
      FROM   ap_holds_all
      WHERE  invoice_id = p_invoice_id
      AND    release_lookup_code IS NULL;

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Get_Approval_status.Msg4',
                            ' l_invoice_holds --> ' || l_invoice_holds);
      -- =============== END DEBUG LOG ==================

      --
      -- Establish the invoice-level approval flag
      --
      -- Use the following ordering sequence to determine the invoice-level
      -- approval flag:
      --                     'N' - Needs Reapproval
      --                     'T' - Tested
      --                     'A' - Approved
      --                     ''  - Never Approved
      --
      -- Initialize invoice-level approval flag
      --

      l_invoice_approval_flag := '';

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Get_Approval_status.Msg5',
                            ' Setting l_invoice_approval_flag to null' );
      -- =============== END DEBUG LOG ==================

      OPEN c_dist_approval_status;
      LOOP

         FETCH c_dist_approval_status INTO l_distribution_approval_flag;

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Get_Approval_status.Msg6',
                              ' l_distribution_approval_flag -->' || l_distribution_approval_flag );
         -- =============== END DEBUG LOG ==================

         EXIT WHEN c_dist_approval_status%NOTFOUND;

         IF    (l_distribution_approval_flag = 'N')
         THEN
                l_invoice_approval_flag := 'N';

         ELSIF (l_distribution_approval_flag = 'T' AND
               (l_invoice_approval_flag <> 'N' OR l_invoice_approval_flag IS NULL))
         THEN
                l_invoice_approval_flag := 'T';

         ELSIF (l_distribution_approval_flag = 'A' AND
               (l_invoice_approval_flag NOT IN ('N','T') OR l_invoice_approval_flag IS NULL))
         THEN

            l_invoice_approval_flag := 'A';
         -- BUG 3142049: Adding If condition to handle the scenario
         -- when value of l_distribution_approval_flag is 'S'
         ELSIF (l_distribution_approval_flag = 'S')
         THEN
                l_invoice_approval_flag := 'S';
         END IF;

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Get_Approval_status.Msg7',
                              ' l_invoice_approval_flag -->' || l_invoice_approval_flag );
         -- =============== END DEBUG LOG ==================
      END LOOP;
      CLOSE c_dist_approval_status;

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Get_Approval_status.Msg8',
                           ' end of loop c_dist_approval_status' );
         Debug_log_string (l_proc_level, 'Get_Approval_status.Msg9',
                           ' l_encumbrance_flag --> ' || l_encumbrance_flag );
         Debug_log_string (l_proc_level, 'Get_Approval_status.Msg10',
                           ' l_invoice_approval_flag --> ' || l_invoice_approval_flag );
         Debug_log_string (l_proc_level, 'Get_Approval_status.Msg11',
                           ' l_invoice_holds --> ' || l_invoice_holds );
      -- =============== END DEBUG LOG ==================

      -- Derive the translated approval status from the approval flag
      IF (l_encumbrance_flag = 'Y') THEN
         IF (l_invoice_approval_flag = 'A' AND l_invoice_holds = 0) THEN
             l_invoice_approval_status := 'APPROVED';
         ELSIF ((NVL(l_invoice_approval_flag,'A') = 'A' AND l_invoice_holds > 0)
                 OR (l_invoice_approval_flag IN ('T','N','S'))) THEN
                 l_invoice_approval_status := 'NEEDS REAPPROVAL';
         ELSIF (l_invoice_approval_flag IS NULL) THEN
            l_invoice_approval_status := 'NEVER APPROVED';
         END IF;

      ELSIF (l_encumbrance_flag = 'N') THEN
         IF (l_invoice_approval_flag IN ('A','T') AND l_invoice_holds = 0) THEN
            l_invoice_approval_status := 'APPROVED';
         ELSIF ((nvl(l_invoice_approval_flag,'A') IN ('A','T') AND
                 l_invoice_holds > 0) OR (l_invoice_approval_flag = 'N')) THEN
            l_invoice_approval_status := 'NEEDS REAPPROVAL';
         ELSIF (l_invoice_approval_flag IS NULL) THEN
            l_invoice_approval_status := 'NEVER APPROVED';
         ELSIF (l_invoice_approval_flag IS NULL AND l_invoice_holds > 0 ) THEN
            l_invoice_approval_status := 'NEEDS REAPPROVAL';
         END IF;

      END IF;

      -- =============== START DEBUG LOG ================
         Debug_log_string (l_proc_level, 'Get_Approval_status.Msg12',
                           ' RETURN l_invoice_approval_status --> ' || l_invoice_approval_status );
      -- =============== END DEBUG LOG ==================
      RETURN(l_invoice_approval_status);

   EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_UNEXP_ERROR ('Get_approval_status.unexp1','DEFAULT');
            -- =============== END DEBUG LOG ==================
         END IF;
         RAISE_APPLICATION_ERROR(-20001, fnd_message.get);

   END get_approval_status;

   --============================================================================
   -- INVOICE_NOT_EXCLUDED: Determine if the source of the invoice excludes it
   --                       from EXP.
   --============================================================================
   FUNCTION Invoice_Not_Excluded( p_invoice_id       NUMBER
                                , p_source           VARCHAR2
                                , p_calling_sequence VARCHAR2)
                                RETURN BOOLEAN
   IS
      -- For the following CURSOR the ap_invoice_distributions table is used
      -- instead of the ap_invoices table to avoid a mutating table problem.
      -- This occurs when this package which is called from the trigger
      -- igi_exp_hold_trx on the ap_invoices table queries the ap_invoices
      -- table. to avoid this use the ap_invoices_distribution table.
      -- also true for igi_exp_hold_t1 asmales

      -- bug 2885976
      CURSOR c_check_hold_exclusions ( pv_invoice_id NUMBER
                                     , pv_source VARCHAR2) IS
        select 1
        from  fnd_flex_values_vl ffv
        , fnd_flex_value_sets ffvs
        where  ffv.flex_value             = pv_source
        and    ffvs.flex_value_set_name   ='IGI_EXP_SOURCE_EXCLUSION'
        and    ffvs.flex_value_set_id     = ffv.flex_value_set_id
        and    ffv.enabled_flag           = 'Y'
        and    SYSDATE BETWEEN NVL(ffv.start_date_active, SYSDATE)
        and NVL(ffv.end_date_active, SYSDATE);

      l_debug_loc             VARCHAR2(30);
      l_debug_info            VARCHAR2(250) ;
      l_curr_calling_sequence VARCHAR2(2000);
      l_dummy                 NUMBER;

   BEGIN

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Invoice_not_included.Msg1',
                            ' ** START INVOCIE_NOT_INCLUDED ** ');
      -- =============== END DEBUG LOG ==================

      -- GSCC Standard - File.sql.35
      l_debug_loc := 'invoice_not_excluded';
      -- Update the calling sequence
      l_curr_calling_sequence := 'IGI_EXP_HOLDS.'||l_debug_loc||'<-'||
                                 p_calling_sequence;

      -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Invoice_not_included.Msg2',
                            ' l_curr_calling_sequence --> ' || l_curr_calling_sequence);
          Debug_log_string (l_proc_level, 'Invoice_not_included.Msg3',
                            ' p_invoice_id --> ' || p_invoice_id);
          Debug_log_string (l_proc_level, 'Invoice_not_included.Msg4',
                            ' p_source --> ' || p_source);

      -- =============== END DEBUG LOG ==================

      OPEN c_check_hold_exclusions ( p_invoice_id, p_source ) ;
      FETCH c_check_hold_exclusions INTO l_dummy ;

      IF c_check_hold_exclusions%NOTFOUND THEN
         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Invoice_not_included.Msg5',
                              ' RETURN TRUE --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================
         CLOSE c_check_hold_exclusions ;
         RETURN TRUE ;
      ELSE
         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Invoice_not_included.Msg6',
                              ' RETURN FALSE --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================
         CLOSE c_check_hold_exclusions ;
         RETURN FALSE ;
      END IF ;

   EXCEPTION
      WHEN OTHERS THEN
           IF c_check_hold_exclusions%ISOPEN THEN
              CLOSE c_check_hold_exclusions ;
           END IF ;

           IF (SQLCODE <> -20001) THEN
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_UNEXP_ERROR ('Invoice_not_included.unexp1','DEFAULT');
            -- =============== END DEBUG LOG ==================
           END IF;
           RAISE_APPLICATION_ERROR(-20001, fnd_message.get);
   END Invoice_Not_Excluded ;

   --========================================================================
   -- PROCEDURE: Igi_Exp_Ap_Holds_T2
   --            Called from Trigger IGI_EXP_AP_HOLDS_T2
   --========================================================================

   PROCEDURE Igi_Exp_Ap_Holds_T2(p_calling_sequence IN VARCHAR2)
   IS
      l_debug_loc             VARCHAR2(30);
      l_debug_info            VARCHAR2(250);
      l_invoice_id            NUMBER;
      l_source                VARCHAR2(25);
      l_cancelled_date        DATE;
      l_hold_lookup_code      VARCHAR2(200);
      l_calling_sequence      VARCHAR2(1000);
      l_temp_cancelled_amount NUMBER;
      l_exp_hold_released     VARCHAR2(1);

      CURSOR c_exp_hold_released(p_invoice_id NUMBER)
      IS
         SELECT 'x'
         FROM ap_holds_all ah
         WHERE ah.invoice_id = p_invoice_id
         AND ah.hold_lookup_code = 'AWAIT EXP APP'
         AND ah.release_lookup_code = 'EXP HOLD RELEASE'
         AND NOT EXISTS(SELECT 'x'
                        FROM ap_holds_all ah2
                        WHERE ah2.invoice_id = p_invoice_id
                        AND ah.hold_lookup_code = 'AWAIT EXP APP'
                        AND ah2.release_lookup_code IS NULL);


   BEGIN
    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Igi_exp_ap_holds_t2.Msg1',
                         ' ** START IGI_EXP_AP_HOLDS_T2 ** ');
    -- =============== END DEBUG LOG ==================

    --Initialize variables inside BEGIN bacause of GSCC Standard - File.sql.35
  l_debug_loc := 'IGI_EXP_AP_HOLDS_T2';
  l_calling_sequence := 'AWAIT EXP APP';
  -- Bug 5905190 Start - Variable not initialised
  l_hold_lookup_code := 'AWAIT EXP APP';
  -- Bug 5905190 End
    -- Update the calling sequence --
    l_calling_sequence := 'IGI_EXP_HOLDS.'||l_debug_loc||'<-'||
                          p_calling_sequence;

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Igi_exp_ap_holds_t2.Msg2',
                         ' l_calling_sequence --> ' || l_calling_sequence);
    -- =============== END DEBUG LOG ==================

      FOR i IN 1 .. igi_exp_holds.l_TableRow
    LOOP

         l_invoice_id := igi_exp_holds.l_InvoiceidTable(i);

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Igi_exp_ap_holds_t2.Msg3',
                              ' l_invoice_id --> ' || l_invoice_id);
         -- =============== END DEBUG LOG ==================

        OPEN c_exp_hold_released(l_invoice_id);
        FETCH c_exp_hold_released INTO l_exp_hold_released;
        IF c_exp_hold_released%NOTFOUND THEN


         SELECT a.source,
                a.cancelled_date,
                a.temp_cancelled_amount
         INTO   l_source,
                l_cancelled_date,
                l_temp_cancelled_amount
         FROM AP_INVOICES_ALL a
         WHERE a.invoice_id = l_invoice_id;

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Igi_exp_ap_holds_t2.Msg4',
                              ' l_source --> ' || l_source);
            Debug_log_string (l_proc_level, 'Igi_exp_ap_holds_t2.Msg5',
                              ' l_cancelled_date --> ' || l_cancelled_date);
            Debug_log_string (l_proc_level, 'Igi_exp_ap_holds_t2.Msg6',
                              ' l_temp_cancelled_amount --> ' || l_temp_cancelled_amount);
            Debug_log_string (l_proc_level, 'Igi_exp_ap_holds_t2.Msg7',
                              ' Calling igi_exp_holds.Place_Release_Hold ');
         -- =============== END DEBUG LOG ==================

         igi_exp_holds.Place_Release_Hold(l_invoice_id,
                                          -- Bug 2469158
                                          '', -- invoice amount
                                          l_source,
                                          l_cancelled_date,
                                          'P',
                                          l_hold_lookup_code,
                                          l_calling_sequence,
                                          l_temp_cancelled_Amount);

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Igi_exp_ap_holds_t2.Msg8',
                              ' out of igi_exp_holds.Place_Release_Hold');
         -- =============== END DEBUG LOG ==================

          END IF;
          CLOSE c_exp_hold_released;
      END LOOP;

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Igi_exp_ap_holds_t2.Msg9',
                         ' ** END IGI_EXP_AP_HOLDS_T2 ** ');
    -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_UNEXP_ERROR ('Invoice_not_included.unexp1','DEFAULT');
            -- =============== END DEBUG LOG ==================
         END IF;
         RAISE_APPLICATION_ERROR(-20001, fnd_message.get);
   END Igi_Exp_Ap_Holds_T2;

   -- Bug 2438858 Start
   --========================================================================
   -- PROCEDURE: Igi_Exp_Ap_Inv_Dist_T2
   --            Called from Trigger IGI_AP_Invoice_Dist_T2
   --========================================================================
   PROCEDURE Igi_Exp_Ap_Inv_Dist_T2(p_calling_sequence IN VARCHAR2)
   IS
      l_debug_loc             VARCHAR2(30);
      l_debug_info            VARCHAR2(250);
      l_invoice_id            NUMBER;
      l_source                VARCHAR2(25);
      l_cancelled_date        DATE;
      l_hold_lookup_code      VARCHAR2(200) := 'AWAIT EXP APP';
      l_calling_sequence      VARCHAR2(1000);
      l_temp_cancelled_amount NUMBER;

   BEGIN

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Dist_T2.Msg1',
                         ' ** START IGI_EXP_AP_INV_DIST_T2 ** ');
    -- =============== END DEBUG LOG ==================

    -- Initialize variables inside BEGIN bacause of GSCC Standard - File.sql.35
  l_debug_loc := 'IGI_EXP_AP_INV_DIST_T2';
  l_calling_sequence := 'AWAIT EXP APP';

      -- Update the calling sequence --
      l_calling_sequence := 'IGI_EXP_HOLDS.'||l_debug_loc||'<-'||
                                 p_calling_sequence;

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Dist_T2.Msg2',
                         ' l_calling_sequence --> ' || l_calling_sequence);
    -- =============== END DEBUG LOG ==================

      FOR i IN 1 .. igi_exp_holds.l_DistTableRow LOOP

         l_invoice_id := igi_exp_holds.l_InvoiceidDistTable(i);

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Dist_T2.Msg3',
                              ' l_invoice_id  --> ' || l_invoice_id );
         -- =============== END DEBUG LOG ==================

         SELECT a.source,
                a.cancelled_date,
                a.temp_cancelled_Amount
         INTO   l_source,
                l_cancelled_date,
                l_temp_cancelled_amount
         FROM AP_INVOICES_ALL a
         WHERE a.invoice_id = l_invoice_id;

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Dist_T2.Msg4',
                              ' l_source  --> ' || l_source );
            Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Dist_T2.Msg5',
                              ' l_cancelled_date  --> ' || l_cancelled_date );
            Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Dist_T2.Msg6',
                              ' l_temp_cancelled_amount  --> ' || l_temp_cancelled_amount );
            Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Dist_T2.Msg7',
                              ' Calling igi_exp_holds.Place_Release_Hold ' );
         -- =============== END DEBUG LOG ==================

         igi_exp_holds.Place_Release_Hold(l_invoice_id,
                                          -- Bug 2469158
                                          '', -- invoice amount
                                          l_source,
                                          l_cancelled_date,
                                          'P',
                                          l_hold_lookup_code,
                                          l_calling_sequence,
                                          l_temp_cancelled_amount
                                          );

         -- =============== START DEBUG LOG ================
            Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Dist_T2.Msg8',
                              ' Out of igi_exp_holds.Place_Release_Hold ' );
         -- =============== END DEBUG LOG ==================
      END LOOP;

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Dist_T2.Msg9',
                         ' ** END IGI_EXP_AP_INV_DIST_T2 ** ');
    -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_UNEXP_ERROR ('Igi_Exp_Ap_Inv_Dist_T2.unexp1','DEFAULT');
            -- =============== END DEBUG LOG ==================
         END IF;
         RAISE_APPLICATION_ERROR(-20001, fnd_message.get);
   END Igi_Exp_Ap_Inv_Dist_T2;



   -- Bug 5905190 Start
      --========================================================================
      -- PROCEDURE: Igi_Exp_Ap_Inv_Line_T2
      --            Called from Trigger IGI_AP_Invoice_Line_T2
      --========================================================================
      PROCEDURE Igi_Exp_Ap_Inv_Line_T2(p_calling_sequence IN VARCHAR2)
      IS
         l_debug_loc             VARCHAR2(30);
         l_debug_info            VARCHAR2(250);
         l_invoice_id            NUMBER;
         l_source                VARCHAR2(25);
         l_cancelled_date        DATE;
         l_hold_lookup_code      VARCHAR2(200) := 'AWAIT EXP APP';
         l_calling_sequence      VARCHAR2(1000);
         l_temp_cancelled_amount NUMBER;

      BEGIN

       -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Line_T2.Msg1',
                            ' ** START IGI_EXP_AP_INV_LINE_T2 ** ');
       -- =============== END DEBUG LOG ==================
       -- Initialize variables inside BEGIN bacause of GSCC Standard - File.sql.35
     l_debug_loc := 'IGI_EXP_AP_INV_LINE_T2';
     l_calling_sequence := 'AWAIT EXP APP';

         -- Update the calling sequence --
         l_calling_sequence := 'IGI_EXP_HOLDS.'||l_debug_loc||'<-'||
                                    p_calling_sequence;

       -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Line_T2.Msg2',
                            ' l_calling_sequence --> ' || l_calling_sequence);
       -- =============== END DEBUG LOG ==================

         FOR i IN 1 .. igi_exp_holds.l_LineTableRow LOOP

            l_invoice_id := igi_exp_holds.l_InvoiceidLineTable(i);

            -- =============== START DEBUG LOG ================
               Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Line_T2.Msg3',
                                 ' l_invoice_id  --> ' || l_invoice_id );
            -- =============== END DEBUG LOG ==================

            SELECT a.source,
                   a.cancelled_date,
                   a.temp_cancelled_Amount
            INTO   l_source,
                   l_cancelled_date,
                   l_temp_cancelled_amount
            FROM AP_INVOICES_ALL a
            WHERE a.invoice_id = l_invoice_id;

            -- =============== START DEBUG LOG ================
               Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Line_T2.Msg4',
                                 ' l_source  --> ' || l_source );
               Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Line_T2.Msg5',
                                 ' l_cancelled_date  --> ' || l_cancelled_date );
               Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Line_T2.Msg6',
                                 ' l_temp_cancelled_amount  --> ' || l_temp_cancelled_amount );
               Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Line_T2.Msg7',
                                 ' Calling igi_exp_holds.Place_Release_Hold ' );
            -- =============== END DEBUG LOG ==================

            igi_exp_holds.Place_Release_Hold(l_invoice_id,
                                             -- Bug 2469158
                                             '', -- invoice amount
                                             l_source,
                                             l_cancelled_date,
                                             'P',
                                             l_hold_lookup_code,
                                             l_calling_sequence,
                                             l_temp_cancelled_amount
                                             );

            -- =============== START DEBUG LOG ================
               Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Line_T2.Msg8',
                                 ' Out of igi_exp_holds.Place_Release_Hold ' );
            -- =============== END DEBUG LOG ==================
         END LOOP;

       -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Igi_Exp_Ap_Inv_Line_T2.Msg9',
                            ' ** END IGI_EXP_AP_INV_LINE_T2 ** ');
       -- =============== END DEBUG LOG ==================

      EXCEPTION
         WHEN OTHERS THEN
            IF (SQLCODE <> -20001) THEN
               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_UNEXP_ERROR ('Igi_Exp_Ap_Inv_Line_T2.unexp1','DEFAULT');
               -- =============== END DEBUG LOG ==================
            END IF;
            RAISE_APPLICATION_ERROR(-20001, fnd_message.get);
      END Igi_Exp_Ap_Inv_Line_T2;
    -- Bug 5905190 End

   --============================================================================
   -- PLACE_RELEASE_HOLD: Procedure that places or releases an EXP Hold if the
   --                     invoice status is APPROVED
   --============================================================================
   PROCEDURE Place_Release_Hold( p_invoice_id       IN NUMBER
                                 -- Bug 2469158.
                               , p_invoice_amt      IN NUMBER
                               , p_source           IN VARCHAR2
                               , p_cancelled_date   IN DATE
                               , p_place_release    IN VARCHAR2
                               , p_hold_lookup_code IN VARCHAR2
                               , p_calling_sequence IN VARCHAR2
                               -- Bug 3595853.
                               , p_temp_cancelled_amount IN NUMBER default NULL
                               )
   IS
      l_approval_status       VARCHAR2(80) ;
      l_system_user           NUMBER;
      l_debug_loc             VARCHAR2(30);
      l_debug_info            VARCHAR2(250) ;
      l_inv_hold_status       VARCHAR2(240);
      l_status                VARCHAR2(20);
      l_existing_hold_reason  VARCHAR2(240);
      l_calling_sequence      VARCHAR2(1000);
      -- Bug 2377571
      l_inv_amt               NUMBER;
      l_inv_dist_amt          NUMBER;
      l_temp_cancelled_amount NUMBER;
      l_inv_line_amt          NUMBER;

  CURSOR cur_get_SIA_Hold(p_inv_id ap_invoices_all.invoice_id%type)
  IS
  Select hold_lookup_code
  From   AP_HOLDS_ALL
  Where  invoice_id = p_inv_id
  And    hold_lookup_code = 'AWAIT_SEC_APP'
  And    release_lookup_code is not null;

  l_Hold_Lookup_Code AP_HOLDS.Hold_Lookup_Code%TYPE;
  l_SapStatusFlag VARCHAR2(1);
  l_SapErrorNum   NUMBER;

   BEGIN

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg1',
                         ' ** START PLACE_RELEASE_HOLD ** ');
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg1',
                         ' p_invoice_id --> ' || p_invoice_id);
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg2',
                         ' p_invoice_amt --> ' || p_invoice_amt);
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg3',
                         ' p_source --> ' || p_source);
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg4',
                         ' p_cancelled_date --> ' || p_cancelled_date);
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg5',
                         ' p_place_release --> ' || p_place_release);
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg6',
                         ' p_hold_lookup_code --> ' || p_hold_lookup_code);
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg7',
                         ' p_calling_sequence --> ' || p_calling_sequence);
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg8',
                         ' p_temp_cancelled_amount --> ' || p_temp_cancelled_amount);
    -- =============== END DEBUG LOG ==================

    --Initialize variables inside BEGIN bacause of GSCC Standard - File.sql.35
    l_debug_loc := 'place_release_hold';
    l_system_user := 5;

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg1',
                         ' Checking SIA ');
    -- =============== END DEBUG LOG ==================

    -- Bug 3409394
    IGI_GEN.get_option_status('SIA', l_SapStatusFlag, l_SapErrorNum);

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg9',
                         ' l_SapStatusFlag --> ' || l_SapStatusFlag);
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg10',
                         ' l_SapErrorNum --> ' || l_SapErrorNum);
    -- =============== END DEBUG LOG ==================

    -- Update the calling sequence
    l_calling_sequence := 'IGI_EXP_HOLDS.'||l_debug_loc||'<-'||p_calling_sequence;

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg11',
                         ' l_calling_sequence --> ' || l_calling_sequence);
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg12',
                         'Invoice Cancelled Date --> '||to_char(p_cancelled_date));
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg13',
                         'Calling invoice_not_excluded ' );
    -- =============== END DEBUG LOG ==================

      IF invoice_not_excluded( p_invoice_id
                             , p_source
                             , l_calling_sequence )
      THEN

       -- =============== START DEBUG LOG ================
          Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg14',
                            ' invoice_not_excluded Inside if  ');
       -- =============== END DEBUG LOG ==================

         IF p_cancelled_date IS NULL
         THEN

            -- =============== START DEBUG LOG ================
               Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg15',
                                 ' p_cancelled_date IS NULL  ');
               Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg16',
                                 ' Calling get_hold_status ');
            -- =============== END DEBUG LOG ==================

            Get_Hold_Status(p_invoice_id,
                            p_hold_lookup_code,
                            l_status,
                            l_calling_sequence);

            -- =============== START DEBUG LOG ================
               Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg17',
                                 ' Calling get_approval_status ');
            -- =============== END DEBUG LOG ==================

            l_approval_status := get_approval_status( p_invoice_id
                                                     ,l_calling_sequence ) ;

            -- =============== START DEBUG LOG ================
               Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg18',
                                 ' l_approval_status --> ' || l_approval_status);
            -- =============== END DEBUG LOG ==================

            -- Bug 2636989 sowsubra start (1)
            -- Moved the block below to this position as the l_inv_amt
            -- and l_inv_dist_amt are needed for the if condition for setting EXP hold
            --
            IF p_place_release = 'P' THEN

               -- =============== START DEBUG LOG ================
                  Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg19',
                                    ' IF p_place_release = P ');
               -- =============== END DEBUG LOG ==================

               IF p_invoice_amt IS NULL THEN

                  -- =============== START DEBUG LOG ================
                     Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg20',
                                       ' IF p_invoice_amt IS NULL ');
                  -- =============== END DEBUG LOG ==================

                  -- Check if invoice amount different from distribution amount
                  SELECT invoice_amount
                  INTO   l_inv_amt
                  FROM   ap_invoices
                  WHERE  invoice_id = p_invoice_id;

               ELSE
                  l_inv_amt := p_invoice_amt;
               END IF;

               -- =============== START DEBUG LOG ================
                  Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg21',
                                    ' l_inv_amt --> ' || l_inv_amt);
               -- =============== END DEBUG LOG ==================

               -- Bug 2505522
               -- Bug 2576238
               BEGIN
                 SELECT SUM(NVL(amount,0)) INTO   l_inv_dist_amt
                 FROM   ap_invoice_distributions
                 WHERE  invoice_id = p_invoice_id
                 AND    line_type_lookup_code NOT IN ('AWT','PREPAY')
                 AND    prepay_tax_parent_id IS NULL
                 GROUP BY invoice_id;
               EXCEPTION
                 WHEN OTHERS THEN
                      l_inv_dist_amt := 0;
               END;
               -- =============== START DEBUG LOG ================
                  Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg22',
                                    ' l_inv_dist_amt --> ' || l_inv_dist_amt);
               -- =============== END DEBUG LOG ==================

               -- Bug 5905190
               BEGIN
                 SELECT SUM(NVL(amount,0)) INTO   l_inv_line_amt
                 FROM   ap_invoice_lines
                 WHERE  invoice_id = p_invoice_id
                 AND    line_type_lookup_code NOT IN ('AWT','PREPAY');
                 --AND    prepay_tax_parent_id IS NULL;
               EXCEPTION
                 WHEN OTHERS THEN
                      l_inv_line_amt := 0;
               END;
               -- =============== START DEBUG LOG ================
                  Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg22',
                                    ' l_inv_line_amt --> ' || l_inv_line_amt);
               -- =============== END DEBUG LOG ==================


         END IF; -- 'P' to place hold


         -- Bug 2636989 sowsubra end(1)
         IF l_approval_status = 'APPROVED' THEN

            -- =============== START DEBUG LOG ================
               Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg23',
                                 ' IF l_approval_status = APPROVED' );
            -- =============== END DEBUG LOG ==================

              IF p_place_release = 'P' THEN

                 -- =============== START DEBUG LOG ================
                    Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg24',
                                      ' IF p_place_release = P' );
                 -- =============== END DEBUG LOG ==================

                  -- Bug 2636989
                  -- Added the following if  condition to chk before
                  -- setting the EXP hold whether invoice amount and distn amt are equal .
                  -- This is needed in case the usr changes the headers amt multiple times without approving invoice

                  /* Bug#5905190
                   Added code to check if invoice amount is equal to line amount
                  */

                  IF (l_inv_amt = l_inv_dist_amt) AND (l_inv_amt = l_inv_line_amt) THEN

                     -- =============== START DEBUG LOG ================
                        Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg25',
                                          ' IF l_inv_amt = l_inv_dist_amt ' );
                     -- =============== END DEBUG LOG ==================

                     --Bug 3409394
                     IF l_sapStatusFlag ='Y' then
                         OPEN cur_get_SIA_Hold(p_invoice_id);
                         FETCH cur_get_SIA_Hold INTO l_hold_lookup_code;
                         IF cur_get_SIA_Hold%NOTFOUND THEN
                      l_hold_lookup_code := null;
                         END IF;
                         CLOSE cur_get_SIA_Hold;

                         IF l_hold_lookup_code is NOT NULL then
                           Set_Hold(p_invoice_id,l_calling_sequence);
                         END IF;
                     ELSE
                         IF p_temp_cancelled_amount is null THEN
                            -- Bug 3409394 End(2) --
                            Set_Hold(p_invoice_id,l_calling_sequence);
                   END IF;
           END IF;
                 ELSE
                     NULL;
                     -- =============== START DEBUG LOG ================
                        Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg26',
                                          ' IF l_inv_amt <> l_inv_dist_amt ' );
                     -- =============== END DEBUG LOG ==================
                END IF; -- l_inv_amt = l_inv_dist_amt
            ELSE
                     -- =============== START DEBUG LOG ================
                        Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg27',
                                          ' IF p_place_release <> P  ' );
                     -- =============== END DEBUG LOG ==================
            END IF; -- p_place_release = 'P'

        ELSIF l_approval_status = 'NEEDS REAPPROVAL' THEN
              -- =============== START DEBUG LOG ================
                 Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg28',
                                   ' l_approval_status = NEEDS REAPPROVAL ' );
              -- =============== END DEBUG LOG ==================

               IF (l_status = 'ALREADY ON HOLD') THEN

                  -- =============== START DEBUG LOG ================
                     Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg29',
                                       ' l_status = ALREADY ON HOLD' );
                  -- =============== END DEBUG LOG ==================

                  IF p_place_release = 'R' THEN

                     -- =============== START DEBUG LOG ================
                        Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg30',
                                          'IF p_place_release = R' );
                        Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg31',
                                          'Calling Release_Hold ' );
                     -- =============== END DEBUG LOG ==================

                 Release_Hold(p_invoice_id,
                                  p_hold_lookup_code,
                                  l_calling_sequence);

                     -- =============== START DEBUG LOG ================
                        Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg32',
                                          'Out of Release_Hold ' );
                     -- =============== END DEBUG LOG ==================

                  END IF;  -- check p_place_release = 'R'
              ELSE
                  -- =============== START DEBUG LOG ================
                     Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg33',
                                       'IF l_status <> ALREADY ON HOLD ' );
                  -- =============== END DEBUG LOG ==================
              END IF; -- check invoice_status
            ELSE
              -- =============== START DEBUG LOG ================
                 Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg34',
                                   'IF l_approval_status <> NEEDS REAPPROVAL ' );
              -- =============== END DEBUG LOG ==================
            END IF;  --check l_approval_status

            -- Bug 2377571
            IF p_place_release = 'P' THEN
               -- =============== START DEBUG LOG ================
                  Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg35',
                                    'IF p_place_release = P ' );
               -- =============== END DEBUG LOG ==================
                -- For Bug 5905190, added statement (l_inv_amt <> l_inv_line_amt)
               IF (l_inv_amt <> l_inv_dist_amt) or (l_inv_amt <> l_inv_line_amt) THEN
                  -- =============== START DEBUG LOG ================
                     Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg36',
                                       'IF l_inv_amt <> l_inv_dist_amt ' );
                  -- =============== END DEBUG LOG ==================

                  IF (l_status = 'ALREADY ON HOLD') THEN
                     -- =============== START DEBUG LOG ================
                        Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg37',
                                          'IF (l_status = ALREADY ON HOLD ' );
                     -- =============== END DEBUG LOG ==================

                            Release_Hold(p_invoice_id,
                                  p_hold_lookup_code,
                                  l_calling_sequence);

                     -- =============== START DEBUG LOG ================
                        Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg38',
                                          'Deleting from AP_holds --> ' || SQL%ROWCOUNT );
                     -- =============== END DEBUG LOG ==================

                  END IF; -- already on hold

               END IF; -- amounts are different
            END IF; -- 'P' to place hold

/***********************************
The following code snippet below was originally put in to fix bug 3595853.
This was to delete the EXP hold from AP_HOLDS_ALL, so allow the invoice to
be cancelled (by AP - in package AP_CANCEL_PKG Function: ap_cancel_single_invoice).
However now that all EXP HOLDS are RELEASED, rather than deleted
(requirement by AX - bug 3801520).
This fix is no longer required as the above code snippet suffices; invoice amount
is not equal to the distribution amount (ie l_inv_amt <> l_inv_dist_amt), so the
hold is released anyway (Distribution amount has been changed in step 10. of
ap_cancel_single_invoice, while temp_cancelled_amount is populated in step 11.).
However the code snippet below will still be left in as a backup, incase AP change the
function ap_cancel_single_invoice, so that the above code does not work for both cases.
***********************************/


            IF p_place_release = 'P'  THEN
               -- =============== START DEBUG LOG ================
                  Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg39',
                                    'p_place_release = P ' );
               -- =============== END DEBUG LOG ==================

               IF l_status = 'ALREADY ON HOLD' THEN

                IF  (l_inv_amt = 0 and l_inv_dist_amt = 0 and l_inv_line_amt = 0 )  -- Bug 5905190
                AND (p_temp_cancelled_amount is not null) THEN

                  -- =============== START DEBUG LOG ================
                     Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg40',
                                       '(l_inv_amt = 0 and l_inv_dist_amt = 0) ' ||
                     ' AND (p_temp_cancelled_amount is not null)' );
                  -- =============== END DEBUG LOG ==================

                            Release_Hold(p_invoice_id,
                                  p_hold_lookup_code,
                                  l_calling_sequence);

                  -- =============== START DEBUG LOG ================
                     Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg41',
                                       'Deleting from AP_holds --> ' || SQL%ROWCOUNT );
                  -- =============== END DEBUG LOG ==================

                  END IF; -- amounts are different
              END IF;
            END IF; -- 'P' to place hold


         END IF ; --is cancelled date null
      END IF; -- is invoice excluded

    -- =============== START DEBUG LOG ================
       Debug_log_string (l_proc_level, 'Place_Release_Hold.Msg42',
                         ' ** END PLACE_RELEASE_HOLD ** ');
    -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN

         IF (SQLCODE <> -20001) THEN
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_UNEXP_ERROR ('Place_Release_Hold.unexp1','DEFAULT');
            -- =============== END DEBUG LOG ==================
         END IF;
         RAISE_APPLICATION_ERROR(-20001, fnd_message.get);
   END Place_Release_Hold;

END igi_exp_holds;

/
