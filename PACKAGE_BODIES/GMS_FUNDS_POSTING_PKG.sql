--------------------------------------------------------
--  DDL for Package Body GMS_FUNDS_POSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_FUNDS_POSTING_PKG" AS
/* $Header: gmsglfcb.pls 120.6 2006/08/09 12:04:38 cmishra noship $ */

  -- =================================
  -- Declare Global package Variables.
  -- =================================
  g_error_program_name   CONSTANT VARCHAR2 (30)  := 'GMS_FUNDS_POSTING_PKG';
  g_error_procedure_name VARCHAR2 (30);
  g_error_stage          VARCHAR2 (30);
  g_non_gms_txn 	 BOOLEAN;
  TYPE g_type_number  is table of NUMBER index by binary_integer ;


  -- ==================================
  -- Declare Local program routines.
  -- ==================================

  -- R12 Funds Management uptake : Deleted specification of FUNCTION misc_non_gms_txn

  FUNCTION get_gl_return_code ( p_packet_id IN NUMBER,
				p_gms_partial_flag IN VARCHAR2) RETURN VARCHAR2 ;

  PROCEDURE gl_result_code_update ( p_packet_id IN NUMBER)   ;

  -- bug 3478028 11.5.10 grants accounting patch.
  -- BUG: 3517362 forward port funds check related changes.
  -- R12 Funds Management uptake : Deleted specification of obsolete procedure adjust_burden_ref14

  PROCEDURE gms_result_code_update ( x_gl_return_code   IN OUT NOCOPY VARCHAR2,
                                     p_packet_id        IN            NUMBER,
                                     p_mode             IN            VARCHAR2) ;

  PROCEDURE budget_ver_check ( x_return           OUT NOCOPY VARCHAR2,
                               p_packet_id        IN         NUMBER,
                               p_gms_partial_flag IN         VARCHAR2 ) ;


  PROCEDURE gms_posting ( x_gl_return_code   IN OUT NOCOPY VARCHAR2,
                          p_packet_id        IN            NUMBER,
                          p_mode             IN            VARCHAR2,
                          p_gms_partial_flag IN            VARCHAR2) ;

   PROCEDURE status_code_update ( p_packet_id IN NUMBER,
                                  p_mode      IN VARCHAR2,
                                  p_partial   IN VARCHAR2 DEFAULT 'N')  ;
  -- ===============================================================================
  -- Main API.
  -- GMS_GL_RETURN_CODE : Code change is done to integrate bug fixes for GL bug
  -- 1751696. As part of GL code change GMS_GL_RETURN_CODE may be called three
  -- times now.
  --   Phase 1: Update the status code on GL/GMS bc_packets based on
  --            GL failure/GMS failure. (gms_result_code_update)
  --   Phase 2: POSTING MODE. This is to update the burden posting to ADL's
  --            and summary tables. It is called after bc_packet update and after
  --            GL updates for gms burden posting.
  --   Phase 3: PANIC MODE. This call occurs only if POSTING failed for unhandled
  --            exceptions.
  -- ==============================================================================
  PROCEDURE gms_gl_return_code (x_er_code          IN OUT NOCOPY VARCHAR2,
                                x_er_stage         IN OUT NOCOPY VARCHAR2,
                                x_gl_return_code   IN OUT NOCOPY VARCHAR2,
                                p_packet_id        IN            NUMBER,
                                p_mode             IN            VARCHAR2,
                                p_gms_return_code  IN            VARCHAR2,
                                p_gms_partial_flag IN            VARCHAR2) IS

      t_stage            VARCHAR2 (40);
      v_error_code       NUMBER;
      l_new_partial_flag VARCHAR2 (2) := 'N' ;
      l_error_message	 VARCHAR2(2000);
      l_gl_update        VARCHAR2(1);
      l_bc_packet_id     G_TYPE_NUMBER ;
      l_packet_id        G_TYPE_NUMBER ;
      l_burdenable_cost  G_TYPE_NUMBER ;
      l_count            NUMBER; -- R12 Funds Management uptake :

      -- R12 Funds Management uptake : Cursor to check if gms txns exists for processing
      CURSOR C_gms_pkt_rec_exist IS
      SELECT count(*)
        FROM gms_bc_packets
       WHERE packet_id = p_packet_id;

   BEGIN
        g_error_procedure_name := 'gms_gl_return_code';

        -- R12 Funds Management uptake : Logic to check if any gms txns exists for processing
	-- Removed call to obsolete misc_non_gms_txn procedure
	OPEN C_gms_pkt_rec_exist;
	FETCH C_gms_pkt_rec_exist INTO l_count;
	CLOSE C_gms_pkt_rec_exist;

        IF l_count = 0 THEN
           return ;
      	END IF ;

        -- R12 Funds Management uptake : Code to derive partial/full mode based on p_gms_partial_flag
        l_new_partial_flag := p_gms_partial_flag ;
        --
	-- When others exception was returning success funds checking status.
	-- t_stage STATUS will allow x_gl_return_code to have failure value set.
	t_stage := 'STATUS' ;

        -- =========================================
        -- Determine the gl_return_code value
        -- =========================================
        IF  l_new_partial_flag = 'N' AND
            NVL(x_gl_return_code,'S') NOT IN ('F','T') AND
            get_gl_return_code(p_packet_id, l_new_partial_flag) = 'F'  THEN

            x_gl_return_code := 'F';

        END IF;

        budget_ver_check (l_gl_update, p_packet_id, l_new_partial_flag);

	-- R12 Funds Management uptake : Return GL status as Failed only if FULL mode
	-- If all packets have failed then above call to get_gl_return_code will
	-- assign x_gl_return_code to 'F'.

        IF (p_gms_return_code IN ('F','T') AND p_gms_partial_flag = 'N') OR
           NVL (l_gl_update,'N') = 'Y'    THEN

	   -- Bug : 2557041 - Added for IP check funds Enhancement
	   -- Set the value of gl return code, in case of grants failing
           -- in full mode comment out NOCOPY call to update_gl_packet
	   --
           x_gl_return_code := p_gms_return_code;
        END IF;

        -- =====================================================
        -- We want to make sure that GL failure has not happened
        -- after the last call to GMS GL return code changes.
        -- So updating the gms packet just in case GL panic
        -- occured.
        -- We are expecting only GMS BC packet update at this
        -- Point and X_gl_return_code doesn't change here.
        -- =====================================================
        gms_result_code_update(x_gl_return_code, p_packet_id, p_mode);

        IF p_gms_return_code = 'X' THEN
	   g_error_stage := 'POSTING';
           t_stage       := 'POSTING';

           -- POSTING MODE and return
           -- x_gl_return_code = 'Z' during failure.
	   --
	   -- bug: 3523583
	   -- allocate the burden from the summarized lines when reference14 is populated for the tax lines.
	   -- Burden is allocated to the tax line.
           -- bug 3478028 11.5.10 grants accounting patch.
           -- BUG: 3517362 forward port funds check related changes.
           -- R12 Funds Management uptake : Removed call to obsolete procedure adjust_burden_ref14

	   gms_posting(x_gl_return_code,
                       p_packet_id,
                       p_mode,
                       l_new_partial_flag);

	   -- bug: 3523583
	   -- De allocate the burden from the summarized lines when reference14 is populated for the tax lines.
	   -- Burden is de allocated to the tax line.
	   -- This is to keep the burdenable raw cost in synch with PO match and results to match in
	   -- funds check results form.
           -- bug 3478028 11.5.10 grants accounting patch.
            -- BUG: 3517362 forward port funds check related changes.
	   IF l_bc_packet_id.count > 0 THEN
	      forall l_index in l_bc_packet_id.FIRST..l_bc_packet_id.LAST
		  update gms_bc_packets
		     set burdenable_raw_cost =  l_burdenable_cost(l_index)
                   where bc_packet_id        =  l_bc_packet_id(l_index)
		     and packet_id           =  p_packet_id ;
	   END IF ;
        END IF;

        IF p_mode IN ('U', 'C', 'R')  THEN
	   -- ===============================================================
           -- status_code_update should be called in p_gms_return_code='X'
	   -- filter condition was added. without filter condition burdenable
	   -- raw cost was not getting updated and burden posting expects
	   -- packet in the pending status.
	   -- ===============================================================
	   IF ( p_mode = 'C' OR p_gms_return_code = 'X' ) THEN
	      -- Bug 5039545 : status_code_update is called with p_partial parameter as p_gms_partial_flag.
              status_code_update (p_packet_id, p_mode,p_gms_partial_flag);
	   END IF ;
        END IF;

        gl_result_code_update(p_packet_id);
        x_gl_return_code := get_gl_return_code(p_packet_id, l_new_partial_flag) ;

   EXCEPTION
      WHEN OTHERS THEN
           x_er_code := 'U';
           x_er_stage := SQLCODE||' '||SQLERRM;

	   IF t_stage = 'STATUS'  AND
              p_gms_return_code <> 'Z' THEN
              x_gl_return_code := 'F';
           ELSIF t_stage = 'POSTING' THEN
              x_gl_return_code := 'Z';
	   END IF;   -- Bug 2337897 : Added End If

           UPDATE gl_bc_packets gl
              SET gl.result_code = DECODE (
                                       NVL (SUBSTR (result_code, 1, 1), 'P'),
                                       'P', 'F71',
                                       result_code)
            WHERE gl.packet_id = p_packet_id;

	   l_error_message := SUBSTR((g_error_program_name || '.'
                               ||g_error_procedure_name || '.' || g_error_stage
                               ||' SQLCODE :'||SQLCODE||' SQLERRM :'||SQLERRM),1,2000);

           UPDATE gms_bc_packets gms
              SET gms.status_code = 'T',
		          gms.fc_error_message =  l_error_message,
		          gms.result_code = DECODE (
                                     NVL (SUBSTR (result_code, 1, 1), 'P'),
                                     'P', 'F68',
                                     result_code)
            WHERE gms.packet_id = p_packet_id;

   END gms_gl_return_code;

   -- ================================================================
   -- STATUS_CODE_UPDATE
   -- Following procedure will update funds check ststus on BC packets
   -- and gms award distributions table records.
   -- ================================================================
   PROCEDURE status_code_update (p_packet_id NUMBER,
                                 p_mode VARCHAR2,
                                 p_partial VARCHAR2 DEFAULT 'N') IS
      x_err_code   NUMBER;
      x_dummy      NUMBER;          -- Bug 2181546, Added
      x_err_buff   VARCHAR2 (2000);

      CURSOR c_failed_packet IS  -- Bug 2181546, Added
         SELECT 1
           FROM gms_bc_packets
          WHERE packet_id = p_packet_id
            AND SUBSTR (nvl(result_code,'F65'), 1, 1) = 'F' ;

      CURSOR update_status IS
         SELECT document_header_id,
                document_type,
                result_code,
                status_code,
                entered_dr,
                entered_cr,
                bud_task_id,
                project_id,
                resource_list_member_id,
                document_distribution_id,
                task_id,
                expenditure_item_date,
                expenditure_type , -- Bug 3003584
                award_id,
                expenditure_organization_id,
                packet_id,
                bc_packet_id -- Added for bug : 2927485
           FROM gms_bc_packets
          WHERE packet_id = p_packet_id
            AND parent_bc_packet_id IS NULL
            AND nvl(burden_adjustment_flag,'N') = 'N'
            AND status_code in ('A','B')	; --Added to fix bug 2138376 from 'B'

   BEGIN

      g_error_procedure_name := 'status_code_update';
      g_error_stage := 'SCU : START';

      --R12 Funds Management Uptake : Whole packet should be updated only in full mode
      IF NVL(p_mode,'R') in ('U','S','B','C', 'R' ) AND p_partial = 'N' THEN

         g_error_stage := 'SCU : PARTIAL NO RES';
         --Bug 2181546, Added the cursor and failing packet if atleast one failed record exists in packet

         OPEN c_failed_packet;
         FETCH c_failed_packet INTO x_dummy;

         IF c_failed_packet%FOUND THEN
              UPDATE gms_bc_packets
                 SET status_code = decode(p_mode,'S','E','C','F','R'),
	                 result_code =
                                  DECODE (SUBSTR (NVL (result_code, 'F65'), 1, 1),
                                                  'P','F65',
                                                  NVL(result_code,'F65'))
               WHERE packet_id = p_packet_id;

             --IF SQL%NOTFOUND THEN
             -- Bug 2181546, Replaced with ELSE clause
         ELSE

              UPDATE gms_bc_packets
                 SET status_code = decode(p_mode,'S','S','B','B','C','C','A')
               WHERE packet_id = p_packet_id;
         END IF;
         CLOSE c_failed_packet;


      /* Bug 5039545 : When p_partial is 'Y' , the status_code of all the records in gms_bc_packets for the current packet id
                       is updated correctly. */
      /* Bug 5217281 : Modified the code such that when the GL funds check fails but the GMS fundscheck passes then
                       the status_code is updated correctly on gms_bc_packets. */
      ELSIF NVL(p_mode,'R') in ('U','S','B','C', 'R') AND p_partial = 'Y' THEN

              UPDATE gms_bc_packets
                 SET status_code =
		 DECODE(status_code,'P',decode(p_mode,'S',DECODE (SUBSTR (result_code, 1, 1), 'P', 'S', 'E')
		                                     ,'B',DECODE (SUBSTR (result_code, 1, 1), 'P', 'B', 'R')
						     ,'C',DECODE (SUBSTR (result_code, 1, 1), 'P', 'C', 'F')
						     ,DECODE (SUBSTR (result_code, 1, 1), 'P', 'A', 'R')) -- This will cover p_mode 'U' and 'R'
				       ,status_code)
               WHERE packet_id = p_packet_id;


      ELSIF ( NVL(p_mode,'R') in ('E') ) THEN

            UPDATE gms_bc_packets
               SET status_code = DECODE (SUBSTR (nvl(result_code,'F65'), 1, 1), 'P', 'A', 'R')
             WHERE packet_id = p_packet_id;

            g_error_stage := 'SCU : PARTIAL YES RES';
      END IF ;

      IF p_mode not IN ('R','U','B','E') THEN
        return ;
      END IF ;

      FOR bc_records IN update_status  LOOP

            IF bc_records.document_type = 'REQ' THEN
               g_error_stage := 'UPDATE_ADL:REQ';

               UPDATE gms_award_distributions
                  SET resource_list_member_id = bc_records.resource_list_member_id,
                      bud_task_id = bc_records.bud_task_id,
                      fc_status = DECODE(P_MODE,'B',FC_STATUS,DECODE (SUBSTR (bc_records.result_code, 1, 1), 'P', 'A', 'R'))
                WHERE distribution_id = bc_records.document_distribution_id
                  AND adl_status      = 'A'
                  AND document_type   = 'REQ'
                  AND project_id      = bc_records.project_id
                  AND task_id         = bc_records.task_id
                  AND award_id        = bc_records.award_id ;

            ELSIF bc_records.document_type = 'PO' THEN
               g_error_stage := 'UPDATE_ADL:PO';

               UPDATE gms_award_distributions
                  SET resource_list_member_id = bc_records.resource_list_member_id,
                      bud_task_id = bc_records.bud_task_id,
                      fc_status = DECODE(P_MODE,'B',FC_STATUS,DECODE (SUBSTR (bc_records.result_code, 1, 1), 'P', 'A', 'R'))
                WHERE po_distribution_id = bc_records.document_distribution_id
                  AND adl_status         = 'A'
                  AND document_type      = 'PO'
                  AND project_id         = bc_records.project_id
                  AND task_id            = bc_records.task_id
                  AND award_id           = bc_records.award_id;

            ELSIF bc_records.document_type = 'AP' THEN
               g_error_stage := 'UPDATE_ADL:AP';

               UPDATE gms_award_distributions
                  SET resource_list_member_id = bc_records.resource_list_member_id,
                      bud_task_id = bc_records.bud_task_id,
                      fc_status = DECODE(P_MODE,'B',FC_STATUS,DECODE (SUBSTR (bc_records.result_code, 1, 1), 'P', 'A', 'R'))
                WHERE invoice_id               = bc_records.document_header_id
                /* Bug 5453662 : bc_records.document_distribution_id stores the invoice_distribution_id for an AP invoice.
		   So for an AP invoice , bc_records.document_distribution_id should be compared with invoice_distribution_id. */
                  AND invoice_distribution_id  = bc_records.document_distribution_id
                  AND adl_status               = 'A'
                  AND document_type            = 'AP'
                  AND project_id               = bc_records.project_id
                  AND task_id                  = bc_records.task_id
                  AND award_id                 = bc_records.award_id;
         END IF;
      END LOOP;

   EXCEPTION
     WHEN OTHERS THEN
	  IF update_status%ISOPEN THEN
	      CLOSE update_status;
	  END IF;
          RAISE;    -- Bug 2181546, Added
  END status_code_update;

  -- ==========================================================
  -- MISC_NON_GMS_TXN
  -- Following function returns TRUE if there are non sponsored
  -- project related transactions.
  -- ==========================================================

  FUNCTION misc_non_gms_txn (p_packet_id  IN NUMBER ) RETURN BOOLEAN IS

   l_temp            NUMBER := 0;
   l_record          NUMBER;
   l_return          BOOLEAN;
   l_document_type   VARCHAR2 (30);		--Bug 2069079
   l_source_name     VARCHAR2 (30);
   l_category_name   VARCHAR2 (30);

   CURSOR c_non_gms_ap_trans IS
      SELECT gl.packet_id
        FROM ap_invoice_distributions_all ap,
             gms_award_distributions      adl,
             pa_projects_all              pp,
             gms_project_types            gpt,
             gl_bc_packets                gl
       WHERE gl.packet_id = p_packet_id
         AND gl.je_source_name = 'Payables'
         AND gl.template_id IS NULL
         AND gl.je_category_name = 'Purchase Invoices'
         AND gl.reference2 = ap.invoice_id
         AND gl.reference3 = ap.distribution_line_number
         AND ap.project_id IS NOT NULL
         AND (NVL (ap.pa_addition_flag, 'X') = 'T')
         AND ap.project_id = pp.project_id
         AND pp.project_type = gpt.project_type
         AND gpt.sponsored_flag = 'Y'
         AND ap.award_id = adl.award_set_id
         AND ap.invoice_id = NVL (adl.invoice_id, ap.invoice_id)
         AND ap.distribution_line_number =
                                    NVL (adl.distribution_line_number, ap.distribution_line_number)
         AND ap.invoice_distribution_id =
                                      NVL (adl.invoice_distribution_id, ap.invoice_distribution_id)
         AND ap.project_id = NVL (adl.project_id, ap.project_id)
         AND ap.task_id = NVL (adl.task_id, ap.task_id)
         AND NVL (adl.adl_status, 'I') = 'A'	 			  	   -- Bug 2092791
         AND NVL (adl.document_type, 'AP') IN ('AP', 'DST')
         AND NVL (adl.fc_status, 'X') <> 'A';

   CURSOR c_non_gms_ap IS
      SELECT gl.packet_id
        FROM ap_invoice_distributions_all ap,
             pa_projects_all pp,
             gms_project_types gpt,
             gl_bc_packets gl
       WHERE gl.packet_id = p_packet_id
         AND gl.je_source_name = 'Payables'
         AND gl.template_id IS NULL
         AND gl.je_category_name = 'Purchase Invoices'
         AND gl.reference2 = ap.invoice_id
         AND gl.reference3 = ap.distribution_line_number
         AND ap.project_id IS NOT NULL
         AND (NVL (ap.pa_addition_flag, 'X') <> 'T')
         AND ap.project_id = pp.project_id
         AND pp.project_type = gpt.project_type
         AND gpt.sponsored_flag = 'Y';

   CURSOR c_non_gms_req IS
      SELECT gl.packet_id
        FROM pa_projects_all pp,
             gms_project_types gpt,
             po_req_distributions_all pord,
             gl_bc_packets gl
       WHERE gl.packet_id = p_packet_id
         AND gl.reference1 = 'REQ'
         AND gl.template_id IS NULL
         AND gl.reference3 = pord.distribution_id
         AND pord.project_id IS NOT NULL
         AND pord.project_id = pp.project_id
         AND pp.project_type = gpt.project_type
         AND gpt.sponsored_flag = 'Y';

    CURSOR c_non_gms_ip is
         SELECT gl.packet_id
           FROM gl_bc_packets gl,
                pa_projects pp,
                gms_project_types gpt
          WHERE gl.packet_id       = p_packet_id
            AND pp.project_id      = TO_NUMBER (gl.reference7)
            AND pp.project_type    = gpt.project_type
            AND gpt.sponsored_flag = 'Y'
            AND NVL (gl.reference6, 'XXXXX') = 'GMSIP' ;

   CURSOR c_non_gms_po IS
      SELECT gl.packet_id
        FROM po_distributions_all pod, pa_projects_all pp, gms_project_types gpt, gl_bc_packets gl
       WHERE gl.packet_id = p_packet_id
         AND gl.reference1 = 'PO'
         AND gl.template_id IS NULL
         AND gl.reference3 = pod.po_distribution_id
         AND pod.project_id IS NOT NULL
         AND pod.project_id = pp.project_id
         AND pod.distribution_type <> 'PREPAYMENT' -- subcontractor/complex work uptake
         AND pp.project_type = gpt.project_type
         AND gpt.sponsored_flag = 'Y';


   CURSOR c_document_type IS
      SELECT DISTINCT NVL (reference1, 'X'),
                      je_source_name,
                      je_category_name
                 FROM gl_bc_packets
                WHERE packet_id = p_packet_id
                  AND template_id IS NULL
                  AND ( ( reference1 in ('PO', 'REQ') ) OR
		        ( je_source_name = 'Payables' AND je_category_name = 'Purchase Invoices' ) OR
			( reference6     = 'GMSIP' )
                      ) ;

  BEGIN

   g_error_procedure_name  :=  'misc_non_gms_txn' ;

   l_return := TRUE;

   g_error_stage := 'MISC_NON_GMS : START';

   LOOP
      OPEN c_document_type;
      FETCH c_document_type INTO l_document_type, l_source_name, l_category_name;
      EXIT WHEN c_document_type%NOTFOUND;

      IF l_source_name = 'Payables' AND
         l_category_name = 'Purchase Invoices' THEN

         g_error_stage := 'MISC_NON_GMS : AP';

         OPEN c_non_gms_ap_trans;
         FETCH c_non_gms_ap_trans INTO l_record;

         IF c_non_gms_ap_trans%FOUND THEN
            l_return := TRUE;
         END IF;

         CLOSE c_non_gms_ap_trans;

         OPEN c_non_gms_ap;
         FETCH c_non_gms_ap INTO l_record;

         IF c_non_gms_ap%FOUND THEN
            l_return := FALSE;
         END IF;

         CLOSE c_non_gms_ap;
      ELSIF l_document_type = 'REQ' THEN
         g_error_stage := 'MISC_NON_GMS : REQ';

         OPEN c_non_gms_req;
         FETCH c_non_gms_req INTO l_record;

         IF c_non_gms_req%FOUND THEN
            l_return := FALSE;
         END IF;
         CLOSE c_non_gms_req;

         OPEN c_non_gms_ip;
         FETCH c_non_gms_ip INTO l_record;

         IF c_non_gms_ip%FOUND THEN
            l_return := FALSE;
         END IF;
         CLOSE c_non_gms_ip;
      ELSIF l_document_type = 'PO' THEN
         g_error_stage := 'MISC_NON_GMS : PO';
         OPEN c_non_gms_po;
         FETCH c_non_gms_po INTO l_record;

         IF c_non_gms_po%FOUND THEN
            l_return := FALSE;
         END IF;

         CLOSE c_non_gms_po;
      END IF;

      CLOSE c_document_type;
      EXIT;
   END LOOP;

   g_non_gms_txn := l_return ;

   RETURN l_return;

  END misc_non_gms_txn;

  -- ===============================================================
  -- BUDGET_VER_CHECK
  -- Check if award budget baseline process is not in progress.
  -- fail funds check if award budget baseline process is in
  -- progress.
  -- ===============================================================
  PROCEDURE budget_ver_check (x_return           OUT NOCOPY VARCHAR2,
                              p_packet_id        IN         NUMBER,
                              p_gms_partial_flag IN         VARCHAR2 ) IS

      l_budget_version_id   NUMBER (15);

      CURSOR cur_valid_bvid IS
         SELECT DISTINCT budget_version_id
           FROM gms_bc_packets
          WHERE packet_id                  = p_packet_id
            AND SUBSTR (result_code, 1, 1) = 'P';

      CURSOR c_budget_rec IS
         SELECT budget_version_id
           FROM gms_budget_versions
          WHERE budget_version_id  = l_budget_version_id
            AND current_flag       = 'Y'
            AND budget_status_code = 'B';

  BEGIN
      g_error_procedure_name := 'budget_ver_check';
      ----------------------------------------------------------------
      -- CHECK IF BASELINED BUDGET EXITS FOR THE BUDGET VERSION ID.
      ----------------------------------------------------------------
      x_return := 'N';

      FOR records IN cur_valid_bvid   LOOP

         l_budget_version_id := records.budget_version_id;

         OPEN c_budget_rec;
         FETCH c_budget_rec INTO l_budget_version_id;

         IF c_budget_rec%NOTFOUND THEN
	    -- R12 Funds management uptake : Fail the full packet only if FULL mode
            --x_return := 'Y';

            UPDATE gms_bc_packets
               SET budget_version_id = NULL,
                   result_code = 'F10'
             WHERE packet_id = p_packet_id
               AND budget_version_id = records.budget_version_id
               AND SUBSTR (result_code, 1, 1) = 'P';

            -- R12 Funds management uptake : Fail the full packet only if FULL mode
            IF p_gms_partial_flag = 'N' THEN

	     x_return := 'Y';

             UPDATE gms_bc_packets
                SET result_code = 'F11'
              WHERE packet_id = p_packet_id
                AND substr(result_code,1,1) = 'P';   -- Bug 2181546, Added
            END IF;
         END IF;

	 -- 3688308
         -- 3684986 IPST:MFGST11I: CHECK FUNDS FAILS FOR MULTIPLE AWARD DISTRIBUTIONS/LINES
         -- GMS_FUNDS_POSTING_PKG.budget_ver_check.MISC_NON_GMS : PO SQLCODE :-6511
         -- SQLERRM :ORA-06511: PL/SQL: cursor already open c_budget_rec was not closed
         -- in the loop which has resulted into  PL/SQL: cursor already open exception.
	 -- ===============================================================================

         CLOSE c_budget_rec;
         IF x_return = 'Y' THEN
            EXIT ;
         END IF ;

      END LOOP;

  END budget_ver_check;

  -- ==================================================================
  -- Bug : 2557041 - Added for IP check funds Enhancement
  -- This procedure is called from procedure gms_gl_return_code .
  -- Procedure will update the result codes on gl_bc_packets record,
  -- if the records have:
  -- A. Failed grants funds check process.
  -- B. Passed grants funds check process in advisory mode.
  -- ==================================================================
   PROCEDURE gl_result_code_update (p_packet_id IN NUMBER)   IS

     -- =================================================================
     -- This cursor return records in following scenario's
     -- A. In gms_bc_packets there exists Funds check failed records
     --        for the current packet.
     -- B. In gms_bc_packets there exists records which passed Funds
     --        check in advisory mode for the current packet.
     -- =================================================================
     CURSOR c_gl_update_required IS
      SELECT 1
        FROM DUAL
       WHERE EXISTS ( SELECT 1
                        FROM gms_bc_packets
                       WHERE packet_id = p_packet_id
                         AND (   result_code IN ('P61', 'P65', 'P69', 'P73', 'P80')
                              OR NVL (SUBSTR (result_code, 1, 1), 'P') = 'F'
                             ));
      l_dummy NUMBER;
   BEGIN

       g_error_procedure_name := 'gl_result_code_update';
       g_error_stage := 'GL_RESULT_CODE UPD :START';
       -- If cursor c_gl_update_required returns any records then only execute
       -- the update statement. This will impove performance.
      OPEN  c_gl_update_required;
      FETCH c_gl_update_required INTO l_dummy;
      IF c_gl_update_required%FOUND THEN

         g_error_stage := 'GL_RESULT_CODE UPD :REC_FOUND';
         UPDATE gl_bc_packets glc
            SET glc.result_code	= (SELECT DECODE (
                                          SUBSTR (bp.result_code, 1, 1),
                                          'P', DECODE (
                                                  bp.result_code,
                                                  'P61', 'P39', -- advisory  result code
                                                  'P65', 'P39', -- advisory  result code
                                                  'P69', 'P39', -- advisory  result code
                                                  'P73', 'P39', -- advisory  result code
                                                  'P80', 'P39', -- advisory  result code
                                                  glc.result_code
                                               ),
                                          'F', DECODE (
                                                  bp.result_code,
                                                  'F21', 'F68', --Invalid award number
                                                  'F60', 'F69', --Top Task Failure
                                                  'F90', 'F71', --Award Failure
                                                  'F91', 'F72', --Task Failure
                                                  'F92', 'F73', --Resource Failure
                                                  'F93', 'F74', --Resource Group Failure
                                                  'F65', 'F70', --Full Mode
                                                  'F68', 'F67', --Funds Check processing error
                                                  'F89', 'F67', --Funds Check processing error
                                                  'F09', 'F67', --Funds Check processing error
                                                  'F10', 'F67', --Funds Check processing error
                                                  'F11', 'F67', --Funds Check processing error
                                                  'F12', 'F67', --Funds Check processing error
                                                  'F13', 'F67', --Funds Check processing error
                                                  'F14', 'F67', --Funds Check processing error
                                                  'F15', 'F67', --Funds Check processing error
                                                  'F16', 'F67', --Funds Check processing error
                                                  'F17', 'F67', --Funds Check processing error
                                                  'F18', 'F67', --Funds Check processing error
                                                  'F19', 'F67', --Funds Check processing error
                                                  'F40', 'F67', --Funds Check processing error
                                                  'F41', 'F67', --Funds Check processing error
                                                  'F42', 'F67', --Funds Check processing error
                                                  'F43', 'F67', --Funds Check processing error
                                                  'F44', 'F67', --Funds Check processing error
                                                  'F45', 'F67', --Funds Check processing error
                                                  'F46', 'F67', --Funds Check processing error
                                                  'F47', 'F67', --Funds Check processing error
                                                  'F48', 'F67', --Funds Check processing error
                                                  'F49', 'F67', --Funds Check processing error
                                                  'F50', 'F67', --Funds Check processing error
                                                  'F51', 'F67', --Funds Check processing error
                                                  'F52', 'F67', --Funds Check processing error
                                                  'F53', 'F67', --Funds Check processing error
                                                  'F54', 'F67', --Funds Check processing error
                                                  'F62', 'F67', --Funds Check processing error
                                                  'F64', 'F67', --Funds Check processing error
                                                  'F73', 'F67', --Funds Check processing error
                                                  'F76', 'F67', --Funds Check processing error
                                                  'F78', 'F67', --Funds Check processing error
                                                  'F79', 'F67', --Funds Check processing error
                                                  'F82', 'F67', --Funds Check processing error
                                                  'F94', 'F67', --Funds Check processing error
                                                  'F95', 'F67', --Funds Check processing error
						  -- Update gl_bc_packets with Failure status if gl.result_code
						  -- is Pxx and  gms.result_code is Fxx but the result_code is
						  -- not there in the above List
						  DECODE(NVL(SUBSTR(glc.result_code,1,1),'P'),'P','F67',glc.result_code)
                                               )
                                       )
                                     FROM gms_bc_packets bp
                                    WHERE bp.gl_bc_packets_rowid = ROWIDTOCHAR(glc.ROWID)
                                      AND bp.result_code NOT IN ('F63', 'F75')
				                      AND bp.packet_id = p_packet_id
                                      AND ROWNUM = 1)
          WHERE glc.packet_id = p_packet_id
            AND glc.template_id IS NULL
            AND substr(nvl(glc.result_code,'P'),1,1) = 'P'
            -- Bug 2896476 : We should only override if GL Funds check passed
            -- Bug 3277370 : Added following exists statement to filter out non-GMS transactions , we shouldn't
            --               update result_code on Non-GMS Transactions.
            AND EXISTS (SELECT 1
                         FROM gms_bc_packets gms1
                        WHERE gms1.packet_id = glc.packet_id
                          AND gms1.gl_bc_packets_rowid = ROWIDTOCHAR(glc.ROWID)
                       );

      END IF;

      CLOSE c_gl_update_required;

      g_error_stage := 'GL_RESULT_CODE UPD :END';

   EXCEPTION
	WHEN OTHERS THEN
	  IF c_gl_update_required%ISOPEN THEN
 	     CLOSE c_gl_update_required;
          END IF;
	  RAISE;
   END gl_result_code_update;

  -- =============================================================================
  -- GMS_RESULT_CODE_UPDATE
  -- Purpose: This is called from gms_gl_return_code to have gms_bc_packet
  --          in synch with gl_bc_Packets and updates the result_code in
  --          gms_bc_packets with 'F30', 'F31', 'F32' values.
  -- =============================================================================
  PROCEDURE gms_result_code_update ( x_gl_return_code   IN OUT NOCOPY VARCHAR2,
                                     p_packet_id        IN            NUMBER,
                                     p_mode             IN            VARCHAR2) IS


      l_result_code varchar2(3) ;
  BEGIN
      g_error_procedure_name := 'gms_result_code_update';

      IF x_gl_return_code IN ('F', 'T') THEN
         g_error_procedure_name := 'update_gms_packet';

	 l_result_code := 'F30' ;

         IF p_mode = 'C' and x_gl_return_code ='T' THEN
	    l_result_code := 'F31' ;
	 END IF ;

         IF p_mode IN ('R', 'U') THEN
	    l_result_code := 'F32' ;
         END IF;

         UPDATE gms_bc_packets
            SET result_code = l_result_code
          WHERE packet_id = p_packet_id
            AND SUBSTR (result_code, 1, 1) = 'P';
      END IF;
  EXCEPTION
      WHEN OTHERS THEN
           x_gl_return_code := 'T';
           RAISE;
  END gms_result_code_update;

  -- =======================================================================
  -- GMS_POSTING: This procedure will be called during the 2nd phase of
  --              gms_gl_return_code i.e., after the GMS/GL packet updates.
  --              This will post the burdenable raw cost to ADL's and update
  --              the summary table.
  -- =======================================================================
   PROCEDURE gms_posting ( x_gl_return_code   IN OUT NOCOPY VARCHAR2,
                           p_packet_id        IN            NUMBER,
                           p_mode             IN            VARCHAR2,
                           p_gms_partial_flag IN            VARCHAR2) IS

      l_gms_return_code NUMBER;
      l_gl_update       VARCHAR2 (1);
      l_posting_return  BOOLEAN;
      l_dummy		    NUMBER;

      l_cursor_name     INTEGER;
      l_string_execute  INTEGER;
      l_sql_string      VARCHAR2(1000);

   BEGIN
      g_error_procedure_name := 'gms_posting';
      -- =======================================================================
      -- Bug 2337897 : commented out NOCOPY following code as this procedure is
      --               getting called in gms_result_code_update which is called before
      --               gms_posting in gms_gl_retunrn_code procedure, there is no
      --               need to call this procedure again for budget_ver_check
      -- =======================================================================

      savepoint SAVE_GMSGL_POSTING;

      -- Update burdenable raw cost in source REQ, PO, AP, EXP if fundscheck is
      -- successful

      IF p_mode IN ('R', 'U') THEN
         -- =================================================================
	 -- The following code was commented and Dynamic call was added ,This
	 -- is to provide 11.5.3 base level compatibility.
	 --
         --l_posting_return := gms_cost_plus_extn.update_source_burden_raw_cost
         --                    ( p_packet_id,
         --                     p_mode,
         --                      p_gms_partial_flag
         --                    );
         --
         -- =================================================================
         l_sql_string :=
         ' DECLARE
              l_post_ret BOOLEAN ;
           begin
            l_post_ret := gms_cost_plus_extn.update_source_burden_raw_cost
                                 ( :l_packet_id,
                                   :l_mode,
                                   :l_gms_partial_flag
                                 );
         end ;'  ;
         l_cursor_name := dbms_sql.open_cursor;
         dbms_sql.parse(l_cursor_name,l_sql_string,dbms_sql.native);
         DBMS_SQL.BIND_VARIABLE(l_cursor_name,':l_packet_id', p_packet_id, 20);
         DBMS_SQL.BIND_VARIABLE(l_cursor_name,':l_mode', p_mode, 2);
         DBMS_SQL.BIND_VARIABLE(l_cursor_name,':l_gms_partial_flag', p_gms_partial_flag, 2);
         l_string_execute := dbms_sql.execute(l_cursor_name);
         dbms_sql.close_cursor(l_cursor_name);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
        -- Bug 2181546, Added
         rollback to SAVE_GMSGL_POSTING;
         x_gl_return_code := 'Z';
         RAISE;
   END gms_posting;

   -- ====================================================================
   -- GET_GL_RETURN_CODE
   -- Following function determines the gl return code based on the result
   -- code value assigned to gl bc packets record.
   -- ====================================================================
   FUNCTION get_gl_return_code ( p_packet_id IN NUMBER,
                                 p_gms_partial_flag IN VARCHAR2)
         RETURN VARCHAR2 IS

         t_return_code   VARCHAR2 (1);
   BEGIN
         g_error_procedure_name := 'get_return_code';
         SELECT DECODE (
                   COUNT (*),
                   COUNT (DECODE (SUBSTR (bp.result_code, 1, 1), 'P', 1)),
				   		  DECODE (SIGN(COUNT (DECODE (bp.result_code,
									      'P20', 1,
									      'P22', 1,
									      'P25', 1,
									      'P27', 1,
									      'P39', 1))), -- Bug 2469309 : Added P39
                                                                              0, 'S',
                                                                              1, 'A'),
                   COUNT (DECODE (SUBSTR (bp.result_code, 1, 1), 'F', 1)), 'F',
                   DECODE (p_gms_partial_flag, 'Y', 'P', 'F'))
           INTO t_return_code
           FROM gl_bc_packets bp
          WHERE bp.packet_id = p_packet_id
            AND bp.template_id IS NULL;           /* detail transactions only */

         RETURN t_return_code;

   END get_gl_return_code;

   -- R12 Funds Management uptake : Logic of procedure adjust_burden_ref14 is obsolete as
   -- reference3 and reference14 columns are not used anymore with new architecture.

END GMS_FUNDS_POSTING_PKG ;

/
