--------------------------------------------------------
--  DDL for Package Body IBY_FD_POST_PICP_PROGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FD_POST_PICP_PROGS_PVT" AS
/* $Header: ibyppicb.pls 120.44.12010000.16 2010/09/02 16:33:08 gmaheswa ship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'IBY_FD_POST_PICP_PROGS_PVT';

  ce_sp_access_C NUMBER := 0;

  PROCEDURE Init_Security;


  FUNCTION get_accessible_ppr_org_count
  (
  p_payment_service_request_id   IN     NUMBER
  ) RETURN NUMBER;


  PROCEDURE Submit_FV_TS_Report
  (
  p_payment_instruction_id   IN     NUMBER,
  p_format_code              IN     VARCHAR2,
  l_Debug_Module             IN     VARCHAR2
  );


  PROCEDURE Turn_off_STP_Flag
  (
  p_payment_instruction_id   IN     NUMBER,
  p_newStatus                IN     VARCHAR2
  );

  -- APIs Start
  PROCEDURE Process_Federal_Summary_Format
  (
  p_api_version              IN  NUMBER,
  p_init_msg_list            IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                   IN  VARCHAR2  := FND_API.G_FALSE,
  x_return_status            OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  p_payment_instruction_id   IN  NUMBER,
  p_ecs_dos_seq_num          IN  NUMBER,
  p_summary_format_code      IN  VARCHAR2,
  x_request_id               OUT NOCOPY NUMBER
  )
  IS
    l_api_name                CONSTANT  VARCHAR2(30) := 'Process_Federal_Summary_Format';
    l_api_version             CONSTANT  NUMBER       := 1.0;
    l_rollback_point          CONSTANT  VARCHAR2(30) := 'Process_Federal_Summary_Format';
    l_Debug_Module                      VARCHAR2(255):= G_DEBUG_MODULE || l_api_name;
    l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
    l_bool_val   boolean;  -- Bug 6411356

  BEGIN
    -- standard start of api savepoint
    SAVEPOINT l_rollback_point;


    -- standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name)
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- initialize message list if p_init_msg_list is set to true.
    IF fnd_api.to_boolean(p_init_msg_list)
    THEN
        fnd_msg_pub.initialize;
    END IF;

    -- initialize api return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                   debug_level => FND_LOG.LEVEL_PROCEDURE,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input parameters: ',
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => '============================================',
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_payment_instruction_id: ' || p_payment_instruction_id,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_summary_format_code: ' || p_summary_format_code,
                    debug_level => FND_LOG.LEVEL_STATEMENT,
                    module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_ecs_dos_seq_num: ' || p_ecs_dos_seq_num,
                    debug_level => FND_LOG.LEVEL_STATEMENT,
                    module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => '============================================',
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Before Calling FND_REQUEST.SUBMIT_REQUEST().',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    --Bug 6411356
    --below code added to set the current nls character setting
    --before submitting a child requests.
    fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
    l_bool_val:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);


    -- submit the extract program
    x_request_id := FND_REQUEST.SUBMIT_REQUEST
    (
      'IBY',
      'IBY_FD_FEDERAL_SUMMARY',
      null,  -- description
      null,  -- start_time
      FALSE, -- sub_request
      p_payment_instruction_id,
      p_summary_format_code,
      p_ecs_dos_seq_num,
      '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', ''
    );

    iby_debug_pub.add(debug_msg => 'After Calling FND_REQUEST.SUBMIT_REQUEST().',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Request id: ' || x_request_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    --
    -- end of api body.
    --

    -- standard check for p_commit
    IF fnd_api.to_boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_count        =>   x_msg_count,
      p_data         =>   x_msg_data
    );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
  		ROLLBACK TO l_rollback_point;
  		x_return_status := FND_API.G_RET_STS_ERROR;

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO l_rollback_point;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  	WHEN OTHERS THEN
      ROLLBACK TO l_rollback_point;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)  THEN
      	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
  		END IF;

  END Process_Federal_Summary_Format;


  PROCEDURE Run_Post_PI_Programs
  (
  p_payment_instruction_id   IN     NUMBER,
  p_is_reprint_flag          IN     VARCHAR2
  )
  IS
    l_request_id            NUMBER;
    l_set_opt_ok            BOOLEAN;
    l_set_print_opt_ok      BOOLEAN;
    l_ins_notfound          BOOLEAN;
    l_run_print             BOOLEAN := false;
    l_printer_name          VARCHAR2(255);
    l_print_immed_flag      VARCHAR2(1);
    l_transmit_immed_flag   VARCHAR2(1);
    l_instr_status          VARCHAR2(30);
    l_processing_type       VARCHAR2(30);
    l_completion_point       VARCHAR2(30);
    l_mark_complete_status   VARCHAR2(30);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2550);
    l_return_status         VARCHAR2(1);
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Run_Post_PI_Programs';
    l_save_no_output        VARCHAR2(1);

    l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
    l_bool_val   boolean;  -- Bug 6411356

     --bug 6898689
     l_appl_name            VARCHAR2(20);
     l_template_code        VARCHAR2(150);
     l_template_lang        VARCHAR2(20);
     l_template_terr        VARCHAR2(20);
     l_output_format	    VARCHAR2(15);
     l_bool                 boolean;
    CURSOR l_ins_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT ins.PRINTER_NAME, ins.payment_instruction_status,
           ins.TRANSMIT_INSTR_IMMED_FLAG,
           ins.PRINT_INSTRUCTION_IMMED_FLAG, pp.processing_type, mark_complete_event
      FROM iby_pay_instructions_all ins,
           iby_payment_profiles pp
     WHERE ins.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_profile_id = pp.payment_profile_id;

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    OPEN l_ins_csr(p_payment_instruction_id);
    FETCH l_ins_csr INTO l_printer_name, l_instr_status, l_transmit_immed_flag,
                         l_print_immed_flag, l_processing_type, l_completion_point;

    l_ins_notfound := l_ins_csr%NOTFOUND;
    CLOSE l_ins_csr;

    IF l_ins_notfound THEN
      -- set error for invalid data
      fnd_message.set_name('IBY', 'IBY_FD_INVALID_PMT_INSTRUCTION');
      fnd_message.set_token('PARAM', p_payment_instruction_id);
      fnd_msg_pub.add;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*Bug 8760084 - Start*/
    iby_debug_pub.add(debug_msg => 'Completion point of the payment instruction :' || l_completion_point,debug_level => FND_LOG.LEVEL_STATEMENT, module => l_Debug_Module);

    IF l_completion_point IN ('CREATED') THEN
         iby_debug_pub.add(debug_msg => 'Avoided format payments program trigger',debug_level => FND_LOG.LEVEL_STATEMENT, module => l_Debug_Module);

         iby_debug_pub.add(debug_msg => 'Marking payments complete',debug_level => FND_LOG.LEVEL_STATEMENT, module => l_Debug_Module);

        IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete (
          p_instr_id       => p_payment_instruction_id,
          x_return_status  => l_mark_complete_status
          );

        IF l_mark_complete_status <> FND_API.G_RET_STS_SUCCESS THEN
          -- set error for invalid data
          fnd_message.set_name('IBY', 'IBY_FD_ERR_MARK_COMPLETE');
          fnd_message.set_token('PARAM', p_payment_instruction_id);
          fnd_msg_pub.add;
	        iby_debug_pub.add(debug_msg => 'Marking payment instruction as completed - failed',debug_level => FND_LOG.LEVEL_STATEMENT, module => l_Debug_Module);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

	iby_debug_pub.add(debug_msg => 'Marked payment instruction as complete',debug_level => FND_LOG.LEVEL_STATEMENT, module => l_Debug_Module);
	RETURN;

    END IF;
    /*Bug 8760084 - End*/

    IF l_instr_status not in ('FORMATTED_READY_FOR_PRINTING',
                              'SUBMITTED_FOR_PRINTING',
                              'CREATED_READY_FOR_PRINTING',
                              'CREATED_READY_FOR_FORMATTING',
                              'CREATED') THEN
      -- set error for invalid data
      fnd_message.set_name('IBY', 'IBY_FD_INVALID_PMT_INSTRUCTION');
      fnd_message.set_token('PARAM', p_payment_instruction_id);
      fnd_msg_pub.add;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- the default param values are
    -- implicit IN varchar2 default NO
    -- protected IN varchar2 default NO
    -- language IN varchar2 default NULL,
    -- territory IN varchar2 default NULL
    -- it appears that if the Use in SRS is turned off,
    -- the CM will set the implicit to YES
    l_set_opt_ok := FND_REQUEST.SET_OPTIONS;

    IF l_set_opt_ok THEN
      iby_debug_pub.add(debug_msg => 'Set request implicit to NO ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    ELSE
      iby_debug_pub.add(debug_msg => 'Warning: unable to set request options ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    END IF;


    IF l_instr_status in ('FORMATTED_READY_FOR_PRINTING', 'SUBMITTED_FOR_PRINTING') THEN
      l_run_print := true;
    ELSIF l_instr_status = 'CREATED_READY_FOR_PRINTING' AND l_print_immed_flag = 'Y' THEN
      l_run_print := true;
    END IF;

    IF l_run_print THEN
     iby_debug_pub.add(debug_msg => 'The payment instruction format output is to be printed.',
                       debug_level => FND_LOG.LEVEL_STATEMENT,
                       module => l_Debug_Module);

    SELECT nvl(pp.disallow_save_print_flag,'N') into l_save_no_output
     FROM iby_pay_instructions_all ins,
           iby_payment_profiles pp
     WHERE ins.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_profile_id = pp.payment_profile_id;

     IF l_save_no_output = 'Y' THEN
     l_set_print_opt_ok := FND_REQUEST.SET_PRINT_OPTIONS
                             (printer => l_printer_name,
                              style => null,
                              copies => 1,
                              save_output => FALSE);
     ELSE
     l_set_print_opt_ok := FND_REQUEST.SET_PRINT_OPTIONS
                             (printer => l_printer_name,
                              style => null,
                              copies => 1);
    END IF;
    END IF;


    IF l_set_print_opt_ok THEN
      iby_debug_pub.add(debug_msg => 'The printer is to: ' || l_printer_name,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    ELSE
      iby_debug_pub.add(debug_msg => 'Warning: unable to set printer',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    END IF;

    iby_debug_pub.add(debug_msg => 'Before Calling FND_REQUEST.SUBMIT_REQUEST().',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    --Bug 6411356
    --below code added to set the current nls character setting
    --before submitting a child requests.
    fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
    l_bool_val:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);


    SELECT  temp.application_short_name,
	     temp.template_code,
	     temp.default_language,
	     temp.default_territory,
	     decode(template_type_code,
	     'RTF','PDF',
	     'ETEXT','ETEXT',
             'XSL-XML','XML',
	     'XSL-FO','PDF',
	     'PDF','PDF')
                into
	       l_appl_name,
	       l_template_code,
	       l_template_lang,
	       l_template_terr,
	       l_output_format
	   FROM iby_pay_instructions_all ins,
	   iby_payment_profiles pp,
	   iby_formats_b format,
	   XDO_TEMPLATES_B temp
	 WHERE ins.payment_instruction_id  = p_payment_instruction_id
	 AND ins.payment_profile_id        = pp.payment_profile_id
	 AND format.FORMAT_CODE            = pp.PAYMENT_FORMAT_CODE
	 AND format.FORMAT_TEMPLATE_CODE   = temp.template_code
	 AND temp.application_id = 673
	 AND SYSDATE BETWEEN NVL(temp.start_date, SYSDATE) AND NVL(temp.end_date,SYSDATE);



	/* l_bool :=  FND_REQUEST.add_layout
           (
	    l_appl_name,
	    l_template_code,
            l_template_lang,
	    l_template_terr,
	    l_output_format

	    );
	*/

-- submit the extract program

	IF l_output_format ='PDF' THEN

	    l_request_id := FND_REQUEST.SUBMIT_REQUEST
	    (
	      'IBY',
	      'IBY_FD_PAYMENT_FORMAT',
	      null,  -- description
	      null,  -- start_time
	      FALSE, -- sub_request
	      p_payment_instruction_id,
	      p_is_reprint_flag,
	      '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', ''
	    );

	 iby_debug_pub.add(debug_msg => 'Submitting request for format payment program for PDF output',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

	 ELSE

	       l_request_id := FND_REQUEST.SUBMIT_REQUEST
	    (
	      'IBY',
	      'IBY_FD_PAYMENT_FORMAT_TEXT',
	      null,  -- description
	      null,  -- start_time
	      FALSE, -- sub_request
	      p_payment_instruction_id,
	      p_is_reprint_flag,
	      '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', '', '', '', '', '', '',
	      '', '', ''
	    );

	 iby_debug_pub.add(debug_msg => 'Submitting request for format payment program for text/xml output',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

	 END IF;

    iby_debug_pub.add(debug_msg => 'After Calling FND_REQUEST.SUBMIT_REQUEST().',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    iby_debug_pub.add(debug_msg => 'Request id: ' || l_request_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    IF l_request_id = 0 THEN
      RAISE FND_API.G_EXC_ERROR;
     --  Bug:7259529 - CAll to the lock_pmt_entity has been moved to the java layer
     --  Bug:9235888 - Reinstated instruction locking.
    ELSE

      iby_debug_pub.add(debug_msg => 'Calling the lock_pmt_entity() API to lock instruction: ' || p_payment_instruction_id
                        || ' for the extract/formatting/printing/delivery program',
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

      IBY_DISBURSE_UI_API_PUB_PKG.lock_pmt_entity(
             p_object_id         => p_payment_instruction_id,
             p_object_type       => 'PAYMENT_INSTRUCTION',
             p_conc_request_id   => l_request_id,
             x_return_status     => l_return_status
             );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        iby_debug_pub.add(debug_msg => 'lock_pmt_entity() API returned success',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);
      END IF;

    END IF;

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

  END Run_Post_PI_Programs;


  PROCEDURE Post_Results
  (
  p_payment_instruction_id   IN     NUMBER,
  p_newStatus                IN     VARCHAR2,
  p_is_reprint_flag          IN     VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2
  )
  IS
    l_instruction_ovn       NUMBER;
    l_instr_status          VARCHAR2(30);
    l_proc_type             VARCHAR2(30);
    l_mark_complete_event   VARCHAR2(30);
    l_format_code           VARCHAR2(30);
    l_process_type          VARCHAR2(30);
    l_mark_complete_status  VARCHAR2(240);
    l_pp_prt_immed          VARCHAR2(1);
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Post_Results';
    l_msg_data              VARCHAR2(2000);

    CURSOR l_instruction_ovn_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT ins.object_version_number, ins.payment_instruction_status,
           pp.processing_type, pp.mark_complete_event, pp.payment_format_code,
           pp.print_instruction_immed_flag, ins.process_type
      FROM iby_pay_instructions_all ins, iby_payment_profiles pp
     WHERE ins.payment_profile_id = pp.payment_profile_id
       AND payment_instruction_id = p_payment_instruction_id;

--  CURSOR l_pmt_csr (p_payment_instruction_id IN NUMBER) IS
--    SELECT payment_id, payment_status, object_version_number
--      FROM iby_payments_all
--     WHERE payment_instruction_id = p_payment_instruction_id
--       AND payment_status in ('FORMATTED', 'INSTRUCTION_CREATED');
--
--  CURSOR l_pmt_reprt_csr (p_payment_instruction_id IN NUMBER) IS
--    SELECT payment_id, payment_status, object_version_number
--      FROM iby_payments_all
--     WHERE payment_instruction_id = p_payment_instruction_id
--       AND payment_status in ('READY_TO_REPRINT', 'VOID_BY_SETUP_REPRINT', 'VOID_BY_OVERFLOW_REPRINT');

  BEGIN
    iby_debug_pub.log(debug_msg => 'Enter Post Results:Start:Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    iby_debug_pub.add(debug_msg => 'Enter: ' || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input instruction status: ' || p_newStatus,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input is_reprint_flag: ' || p_is_reprint_flag,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN  l_instruction_ovn_csr (p_payment_instruction_id);
    FETCH l_instruction_ovn_csr INTO l_instruction_ovn, l_instr_status, l_proc_type,
                                     l_mark_complete_event, l_format_code, l_pp_prt_immed, l_process_type;
    CLOSE l_instruction_ovn_csr;

    iby_debug_pub.add(debug_msg => 'Current instruction status is: ' || l_instr_status,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Setting instruction to the input status: ' || p_newStatus,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    -- bug 5121763: single payments handling. PICP would mark complete and set
    -- the complete statuses in its process - i.e., before the post-PICP CP
    -- as a result we skip the post formatting processing for single payments
    -- except 'TRANSMISSION_FAILED'
    IF l_process_type = 'IMMEDIATE' AND p_newStatus <> 'TRANSMISSION_FAILED' THEN
      RETURN;
    END IF;

    UPDATE
      iby_pay_instructions_all
    SET
      payment_instruction_status = p_newStatus,
      object_version_number     = l_instruction_ovn + 1,
      last_updated_by           = fnd_global.user_id,
      last_update_date          = SYSDATE,
      last_update_login         = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
    WHERE
      payment_instruction_id = p_payment_instruction_id;

    IF p_newStatus = 'SUBMITTED_FOR_PRINTING' THEN

      IF nvl(p_is_reprint_flag, 'N') = 'N' THEN

          iby_debug_pub.add(debug_msg => ' New status is SUBMITTED_FOR_PRINTING and reprint flag is N ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


--      FOR l_payment IN l_pmt_csr(p_payment_instruction_id) LOOP
--
--          IF l_payment.payment_status IN ('FORMATTED', 'INSTRUCTION_CREATED') THEN
--
--            iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                              ' status. Setting it to SUBMITTED_FOR_PRINTING',
--                              debug_level => FND_LOG.LEVEL_STATEMENT,
--                              module => l_Debug_Module);

            iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as FORMATTED,INSTRUCTION_CREATED' ||
                              ' to SUBMITTED_FOR_PRINTING',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);

            UPDATE
              iby_payments_all
            SET
              payment_status           = 'SUBMITTED_FOR_PRINTING',
              object_version_number    = object_version_number + 1,
              last_updated_by          = fnd_global.user_id,
              last_update_date         = SYSDATE,
              last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
            WHERE
              payment_instruction_id = p_payment_instruction_id
	      AND payment_status IN ('FORMATTED', 'INSTRUCTION_CREATED');


--          END IF;
--
--       END LOOP;

      ELSE -- reprint (individual or range)


          iby_debug_pub.add(debug_msg => ' New status is SUBMITTED_FOR_PRINTING and reprint flag is Y ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

--	FOR l_payment IN l_pmt_reprt_csr(p_payment_instruction_id) LOOP
--
--          IF l_payment.payment_status = 'READY_TO_REPRINT' THEN
--
--            iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                              ' status. Setting it to SUBMITTED_FOR_PRINTING',
--                              debug_level => FND_LOG.LEVEL_STATEMENT,
--                              module => l_Debug_Module);


            iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as READY_TO_REPRINT' ||
                              ' to SUBMITTED_FOR_PRINTING',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);


            UPDATE
              iby_payments_all
            SET
              payment_status           = decode(payment_status,
	                                  'READY_TO_REPRINT','SUBMITTED_FOR_PRINTING',
	                                  'VOID_BY_SETUP_REPRINT','VOID_BY_SETUP',
	                                  'VOID_BY_OVERFLOW_REPRINT','VOID_BY_OVERFLOW'),
              object_version_number    = object_version_number + 1,
              last_updated_by          = fnd_global.user_id,
              last_update_date         = SYSDATE,
              last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
            WHERE
              payment_instruction_id = p_payment_instruction_id
	      AND payment_status IN ('READY_TO_REPRINT','VOID_BY_SETUP_REPRINT','VOID_BY_OVERFLOW_REPRINT');

--          ELSIF l_payment.payment_status = 'VOID_BY_SETUP_REPRINT' THEN
--
--            iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                              ' status. Setting it to VOID_BY_SETUP',
--                              debug_level => FND_LOG.LEVEL_STATEMENT,
--                              module => l_Debug_Module);

              iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as VOID_BY_SETUP_REPRINT' ||
                              ' to VOID_BY_SETUP',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);


--            UPDATE
--              iby_payments_all
--            SET
--              payment_status           = 'VOID_BY_SETUP',
--              object_version_number    = object_version_number + 1,
--              last_updated_by          = fnd_global.user_id,
--              last_update_date         = SYSDATE,
--              last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
--            WHERE
--              payment_instruction_id = p_payment_instruction_id
--	      AND payment_status = 'VOID_BY_SETUP_REPRINT';

--          ELSIF l_payment.payment_status = 'VOID_BY_OVERFLOW_REPRINT' THEN
--
--            iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                              ' status. Setting it to VOID_BY_OVERFLOW',
--                              debug_level => FND_LOG.LEVEL_STATEMENT,
--                              module => l_Debug_Module);

              iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as VOID_BY_OVERFLOW_REPRINT' ||
                              ' to VOID_BY_OVERFLOW',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);


--            UPDATE
--              iby_payments_all
--            SET
--              payment_status           = 'VOID_BY_OVERFLOW',
--              object_version_number    = object_version_number + 1,
--              last_updated_by          = fnd_global.user_id,
--              last_update_date         = SYSDATE,
--              last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
--            WHERE
--              payment_instruction_id = p_payment_instruction_id
--	      AND payment_status = 'VOID_BY_OVERFLOW_REPRINT';

--          END IF;
--
--        END LOOP;

      END IF;

    -- for printing outside Oracle
    ELSIF p_newStatus = 'FORMATTED' AND l_proc_type = 'PRINTED' THEN


          iby_debug_pub.add(debug_msg => ' New status is FORMATTED and processing type is PRINTED ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


--      FOR l_payment IN l_pmt_csr(p_payment_instruction_id) LOOP
--
--        IF l_payment.payment_status = 'INSTRUCTION_CREATED' THEN
--
--          iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                            ' status. Setting it to FORMATTED',
--                            debug_level => FND_LOG.LEVEL_STATEMENT,
--                            module => l_Debug_Module);

            iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as INSTRUCTION_CREATED' ||
                              ' to FORMATTED',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);

          UPDATE
            iby_payments_all
          SET
            payment_status           = 'FORMATTED',
            object_version_number    = object_version_number + 1,
            last_updated_by          = fnd_global.user_id,
            last_update_date         = SYSDATE,
            last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
          WHERE
            payment_instruction_id = p_payment_instruction_id
	    AND payment_status = 'INSTRUCTION_CREATED';

--        END IF;
--
--      END LOOP;

    -- for transmitted outside Oracle
    -- (electronic and no tranmit config)
    ELSIF p_newStatus = 'FORMATTED_ELECTRONIC' AND l_proc_type = 'ELECTRONIC' THEN


          iby_debug_pub.add(debug_msg => ' New status is FORMATTED_ELECTRONIC and processing type is ELECTRONIC ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


--      FOR l_payment IN l_pmt_csr(p_payment_instruction_id) LOOP
--
--        IF l_payment.payment_status = 'INSTRUCTION_CREATED' THEN
--
--          iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                            ' status. Setting it to FORMATTED',
--                            debug_level => FND_LOG.LEVEL_STATEMENT,
--                            module => l_Debug_Module);

            iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as INSTRUCTION_CREATED' ||
                              ' to FORMATTED',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);

          UPDATE
            iby_payments_all
          SET
            payment_status           = 'FORMATTED',
            object_version_number    = object_version_number + 1,
            last_updated_by          = fnd_global.user_id,
            last_update_date         = SYSDATE,
            last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
          WHERE
            payment_instruction_id = p_payment_instruction_id
	    AND payment_status = 'INSTRUCTION_CREATED';

--	END IF;
--
--      END LOOP;

      IF l_mark_complete_event = 'FORMATTED' THEN

        iby_debug_pub.add(debug_msg => 'Before Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);

        -- the payment completion point must be set as FORMATTED in the PPP
        -- call the mark complete API
        iby_debug_pub.log(debug_msg => 'Enter Mark Pmts Complete: Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);
        IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete (
          p_instr_id       => p_payment_instruction_id,
          x_return_status  => l_mark_complete_status
        );
          iby_debug_pub.log(debug_msg => 'Exit Mark Pmts Complete: Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);
        iby_debug_pub.add(debug_msg => 'After Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);

        IF l_mark_complete_status <> FND_API.G_RET_STS_SUCCESS THEN
          -- set error for invalid data
          fnd_message.set_name('IBY', 'IBY_FD_ERR_MARK_COMPLETE');
          fnd_message.set_token('PARAM', p_payment_instruction_id);
          fnd_msg_pub.add;

          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

    -- for deferred printing with Oracle
    ELSIF p_newStatus = 'FORMATTED_READY_FOR_PRINTING' THEN


          iby_debug_pub.add(debug_msg => ' New status is FORMATTED_READY_FOR_PRINTING ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


--      FOR l_payment IN l_pmt_csr(p_payment_instruction_id) LOOP
--
--        IF l_payment.payment_status = 'INSTRUCTION_CREATED' THEN
--
--          iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                            ' status. Setting it to FORMATTED',
--                            debug_level => FND_LOG.LEVEL_STATEMENT,
--                            module => l_Debug_Module);

            iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as INSTRUCTION_CREATED' ||
                              ' to FORMATTED',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);

          UPDATE
            iby_payments_all
          SET
            payment_status           = 'FORMATTED',
            object_version_number    = object_version_number + 1,
            last_updated_by          = fnd_global.user_id,
            last_update_date         = SYSDATE,
            last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
          WHERE
            payment_instruction_id = p_payment_instruction_id
	    AND payment_status = 'INSTRUCTION_CREATED';

--        END IF;
--
--      END LOOP;

      -- if the printing is deferred due to payment document locking
      -- (i.e., ppp is set to print immed, but instruction is not)
      -- in case of multiple payment instructions, we need to set
      -- the doc level straight through processing flag to N
      IF l_pp_prt_immed = 'Y' THEN
        Turn_off_STP_Flag(p_payment_instruction_id, p_newStatus);
      END IF;

    -- for deferred transmission with Oracle
    ELSIF p_newStatus = 'FORMATTED_READY_TO_TRANSMIT' THEN


          iby_debug_pub.add(debug_msg => ' New status is FORMATTED_READY_TO_TRANSMIT ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


--      FOR l_payment IN l_pmt_csr(p_payment_instruction_id) LOOP
--
--        IF l_payment.payment_status = 'INSTRUCTION_CREATED' THEN
--
--          iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                            ' status. Setting it to FORMATTED',
--                            debug_level => FND_LOG.LEVEL_STATEMENT,
--                            module => l_Debug_Module);

            iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as INSTRUCTION_CREATED' ||
                              ' to FORMATTED',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);


          UPDATE
            iby_payments_all
          SET
            payment_status           = 'FORMATTED',
            object_version_number    = object_version_number + 1,
            last_updated_by          = fnd_global.user_id,
            last_update_date         = SYSDATE,
            last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
          WHERE
            payment_instruction_id = p_payment_instruction_id
	    AND payment_status = 'INSTRUCTION_CREATED';

--        END IF;
--
--      END LOOP;

      IF l_mark_complete_event = 'FORMATTED' THEN

        iby_debug_pub.add(debug_msg => 'Before Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);

        -- call the mark complete API
		iby_debug_pub.log(debug_msg => 'Enter Mark Pmts Complete: Formatted:Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);
        IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete (
          p_instr_id       => p_payment_instruction_id,
          x_return_status  => l_mark_complete_status
        );
		iby_debug_pub.log(debug_msg => 'Exit Mark Pmts Complete: Formatted:Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

        iby_debug_pub.add(debug_msg => 'After Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);

        IF l_mark_complete_status <> FND_API.G_RET_STS_SUCCESS THEN
          -- set error for invalid data
          fnd_message.set_name('IBY', 'IBY_FD_ERR_MARK_COMPLETE');
          fnd_message.set_token('PARAM', p_payment_instruction_id);
          fnd_msg_pub.add;

          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

    -- transmission success
    ELSIF p_newStatus = 'TRANSMITTED' THEN


          iby_debug_pub.add(debug_msg => ' New status is TRANSMITTED ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


--      FOR l_payment IN l_pmt_csr(p_payment_instruction_id) LOOP
--
--        IF l_payment.payment_status IN ('FORMATTED', 'INSTRUCTION_CREATED') THEN
--
--          iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                            ' status. Setting it to TRANSMITTED',
--                            debug_level => FND_LOG.LEVEL_STATEMENT,
--                            module => l_Debug_Module);

            iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as FORMATTED,INSTRUCTION_CREATED' ||
                              ' to TRANSMITTED',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);


          UPDATE
            iby_payments_all
          SET
            payment_status           = 'TRANSMITTED',
            object_version_number    = object_version_number + 1,
            last_updated_by          = fnd_global.user_id,
            last_update_date         = SYSDATE,
            last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
          WHERE
            payment_instruction_id = p_payment_instruction_id
	    AND payment_status IN ('FORMATTED', 'INSTRUCTION_CREATED');

	  COMMIT;
--	END IF;
--
--      END LOOP;

/* Bug 6026231: When payment instruction is set to 'TRANSMITTED', the api
                mark_all_pmts_complete should be called for both mark completion
                event status (i.e. 'FORMATTED', 'TRANSMITTED')
*/
      IF l_mark_complete_event in ('FORMATTED', 'TRANSMITTED') THEN

        iby_debug_pub.add(debug_msg => 'Before Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);

        -- call the mark complete API
	iby_debug_pub.log(debug_msg => 'Enter Mark Pmts Complete:Transmitted:Timestamp'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

	IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete (
		  p_instr_id       => p_payment_instruction_id,
		  x_return_status  => l_mark_complete_status
		);

        iby_debug_pub.log(debug_msg => 'Exit Mark Pmts Complete:Transmitted:Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);
        iby_debug_pub.add(debug_msg => 'After Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);

        IF l_mark_complete_status <> FND_API.G_RET_STS_SUCCESS THEN

          -- set error for invalid data
          fnd_message.set_name('IBY', 'IBY_FD_ERR_MARK_COMPLETE');
          fnd_message.set_token('PARAM', p_payment_instruction_id);
          fnd_msg_pub.add;

          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

    -- transmission failed
    -- no status change at the payment level
    -- only update doc level straight through flag
    ELSIF p_newStatus = 'TRANSMISSION_FAILED' THEN


          iby_debug_pub.add(debug_msg => ' New status is TRANSMISSION_FAILED ',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


      -- bug 5630411 for transmission right after formatting
      -- if transmission fails we need to set the payment status to formatted
      -- and kick off payment complete if applicable

--      FOR l_payment IN l_pmt_csr(p_payment_instruction_id) LOOP
--
--        IF l_payment.payment_status IN ('INSTRUCTION_CREATED') THEN
--
--          iby_debug_pub.add(debug_msg => 'Payment ' || l_payment.payment_id || ' is in ' || l_payment.payment_status ||
--                            ' status. Setting it to FORMATTED',
--                            debug_level => FND_LOG.LEVEL_STATEMENT,
--                            module => l_Debug_Module);

            iby_debug_pub.add(debug_msg => 'Setting status for Payments with ' ||
	                      ' payment_instruction_id as ' || p_payment_instruction_id ||
	                      ' payment_status as INSTRUCTION_CREATED' ||
                              ' to FORMATTED',
                              debug_level => FND_LOG.LEVEL_STATEMENT,
                              module => l_Debug_Module);

          UPDATE
            iby_payments_all
          SET
            payment_status           = 'FORMATTED',
            object_version_number    = object_version_number + 1,
            last_updated_by          = fnd_global.user_id,
            last_update_date         = SYSDATE,
            last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
          WHERE
            payment_instruction_id = p_payment_instruction_id
	    AND payment_status IN ('INSTRUCTION_CREATED');

--	END IF;
--
--      END LOOP;

      IF l_mark_complete_event = 'FORMATTED' THEN

        iby_debug_pub.add(debug_msg => 'Before Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);
        iby_debug_pub.log(debug_msg => 'Enter Mark Pmts Complete: Formatted2:Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);
        -- call the mark complete API
        IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete (
          p_instr_id       => p_payment_instruction_id,
          x_return_status  => l_mark_complete_status
        );
		iby_debug_pub.log(debug_msg => 'Exit Mark Pmts Complete: Formatted2:Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

        iby_debug_pub.add(debug_msg => 'After Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);

        IF l_mark_complete_status <> FND_API.G_RET_STS_SUCCESS THEN
          -- set error for invalid data
          fnd_message.set_name('IBY', 'IBY_FD_ERR_MARK_COMPLETE');
          fnd_message.set_token('PARAM', p_payment_instruction_id);
          fnd_msg_pub.add;

          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

      Turn_off_STP_Flag(p_payment_instruction_id, p_newStatus);

    END IF;

    -- finally kick off Federal "Payment Instruction Treasury Symbol Listing Report"
    -- if its a Federal format
    Submit_FV_TS_Report(p_payment_instruction_id, l_format_code, l_Debug_Module);

    iby_debug_pub.log(debug_msg => 'Exit: ' || l_Debug_Module||'Timestamp::'||systimestamp,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR;
      LOOP
        l_msg_data := FND_MSG_PUB.Get;

        IF l_msg_data IS NULL THEN
          EXIT;
        ELSE
          iby_debug_pub.add(debug_msg => l_msg_data,
                            debug_level => FND_LOG.LEVEL_STATEMENT,
                            module => l_Debug_Module);
        END IF;
      END LOOP;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      LOOP
        l_msg_data := FND_MSG_PUB.Get;

        IF l_msg_data IS NULL THEN
          EXIT;
        ELSE
          iby_debug_pub.add(debug_msg => l_msg_data,
                            debug_level => FND_LOG.LEVEL_STATEMENT,
                            module => l_Debug_Module);
        END IF;
      END LOOP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      LOOP
        l_msg_data := FND_MSG_PUB.Get;

        IF l_msg_data IS NULL THEN
          EXIT;
        ELSE
          iby_debug_pub.add(debug_msg => l_msg_data,
                            debug_level => FND_LOG.LEVEL_STATEMENT,
                            module => l_Debug_Module);
        END IF;
      END LOOP;

  END Post_Results;

  PROCEDURE Submit_FV_TS_Report
  (
  p_payment_instruction_id   IN     NUMBER,
  p_format_code              IN     VARCHAR2,
  l_Debug_Module             IN     VARCHAR2
  )
  IS
    l_fv_ts_req_id          NUMBER;
    l_fv_ts_req_status      VARCHAR2(1);
    l_fv_ts_req_msg_cnt     NUMBER;
    l_fv_ts_req_msg_dt      VARCHAR2(2000);

  BEGIN

    IF SUBSTR(p_format_code, 1, 16) = 'IBY_PAY_EFT_FED_' THEN

      FV_FEDERAL_PAYMENT_FIELDS_PKG.submit_pay_instr_ts_report
        (p_init_msg_list            => NULL,
         p_payment_instruction_id   => p_payment_instruction_id,
				 x_request_id               => l_fv_ts_req_id,
				 x_return_status            => l_fv_ts_req_status,
         x_msg_count                => l_fv_ts_req_msg_cnt,
				 x_msg_data		              => l_fv_ts_req_msg_dt
        );

      IF l_fv_ts_req_status = FND_API.G_RET_STS_SUCCESS THEN
        iby_debug_pub.add(debug_msg => 'Federal submit_pay_instr_ts_report() returns success.',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);
        iby_debug_pub.add(debug_msg => 'Payment Instruction Treasury Symbol Listing Report request id: ' || l_fv_ts_req_id,
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);
      ELSE
        iby_debug_pub.add(debug_msg => 'Federal submit_pay_instr_ts_report() returns error.',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);
      END IF;

    END IF;

  END Submit_FV_TS_Report;


  PROCEDURE Insert_Transmission_Error
  (
  p_payment_instruction_id   IN     NUMBER,
  p_error_code               IN     VARCHAR2,
  p_error_msg                IN     VARCHAR2
  )
  IS
    l_transaction_error_id  NUMBER;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Insert_Transmission_Error';

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: ' || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Error code: ' || p_error_code,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Error message: ' || p_error_msg,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    select IBY_TRANSACTION_ERRORS_S.nextval into l_transaction_error_id from dual;

    insert into
      iby_transaction_errors
    (transaction_error_id, transaction_type, transaction_id,
    error_code, error_date, error_status, created_by,
    creation_date, last_updated_by, last_update_date,
    object_version_number, override_allowed_on_error_flag,
    do_not_apply_error_flag, error_type, error_message)
    values
    (l_transaction_error_id, 'PAYMENT_INSTRUCTION', p_payment_instruction_id,
    p_error_code, sysdate, 'ACTIVE', fnd_global.user_id,
    sysdate, fnd_global.user_id, sysdate,
    1, 'Y',
    'N', 'BANK', p_error_msg);

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

  END Insert_Transmission_Error;


  PROCEDURE Turn_off_STP_Flag
  (
  p_payment_instruction_id   IN     NUMBER,
  p_newStatus                IN     VARCHAR2
  )
  IS

    CURSOR l_doc_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT document_payable_id
      FROM iby_docs_payable_all doc, iby_payments_all pmt,
           iby_pay_instructions_all ins
     WHERE ins.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_instruction_id = pmt.payment_instruction_id
       AND doc.straight_through_flag  = 'Y'
       AND pmt.payment_id = doc.payment_id;

    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Turn_off_STP_Flag';
  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: ' || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    FOR l_doc IN l_doc_csr(p_payment_instruction_id) LOOP

      UPDATE
        iby_docs_payable_all
      SET
        straight_through_flag    = 'N',
        object_version_number    = object_version_number + 1,
        last_updated_by          = fnd_global.user_id,
        last_update_date         = SYSDATE,
        last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE
        document_payable_id = l_doc.document_payable_id;

    END LOOP;

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

  END Turn_off_STP_Flag;


  PROCEDURE save_last_periodic_seq_nums
  (
  p_payment_instruction_id   IN     NUMBER,
  p_seq_name1                IN     VARCHAR2,
  p_last_val1                IN     VARCHAR2,
  p_seq_name2                IN     VARCHAR2,
  p_last_val2                IN     VARCHAR2,
  p_seq_name3                IN     VARCHAR2,
  p_last_val3                IN     VARCHAR2
  )
  IS
    l_payment_profile_id    NUMBER;
    l_seq_last1             NUMBER;
    l_seq_last2             NUMBER;
    l_seq_last3             NUMBER;
    l_seq_name1             VARCHAR2(80);
    l_seq_name2             VARCHAR2(80);
    l_seq_name3             VARCHAR2(80);
    l_obj_updated           BOOLEAN := FALSE;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.save_last_periodic_seq_nums';

    CURSOR l_seq_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT pp.payment_profile_id,
           pp.periodic_sequence_name_1,
           pp.periodic_sequence_name_2,
           pp.periodic_sequence_name_3,
           pp.last_used_number_1,
           pp.last_used_number_2,
           pp.last_used_number_3
      FROM iby_payment_profiles pp, iby_pay_instructions_all ins
     WHERE ins.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_profile_id = pp.payment_profile_id;

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: ' || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_seq_name1: ' || p_seq_name1,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_last_val1: ' || p_last_val1,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_seq_name2: ' || p_seq_name1,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_last_val2: ' || p_last_val1,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_seq_name3: ' || p_seq_name1,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_last_val3: ' || p_last_val1,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    OPEN  l_seq_csr (p_payment_instruction_id);
    FETCH l_seq_csr INTO l_payment_profile_id, l_seq_name1, l_seq_name2, l_seq_name3,
                         l_seq_last1, l_seq_last2, l_seq_last3;
    CLOSE l_seq_csr;

    -- input seq1
    IF l_seq_name1 IS NOT NULL AND l_seq_name1 = trim(p_seq_name1)
      AND p_last_val1 IS NOT NULL AND nvl(l_seq_last1, -99) <> p_last_val1 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             last_used_number_1     = p_last_val1
      WHERE
             payment_profile_id = l_payment_profile_id;

      l_obj_updated := TRUE;

    ELSIF l_seq_name2 IS NOT NULL AND l_seq_name2 = trim(p_seq_name1)
      AND p_last_val1 IS NOT NULL AND nvl(l_seq_last2, -99) <> p_last_val1 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             last_used_number_2     = p_last_val1
      WHERE
             payment_profile_id = l_payment_profile_id;

      l_obj_updated := TRUE;

    ELSIF l_seq_name3 IS NOT NULL AND l_seq_name3 = trim(p_seq_name1)
      AND p_last_val1 IS NOT NULL AND nvl(l_seq_last3, -99) <> p_last_val1 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             last_used_number_3     = p_last_val1
      WHERE
             payment_profile_id = l_payment_profile_id;

      l_obj_updated := TRUE;

    END IF;

    -- input seq2
    IF l_seq_name1 IS NOT NULL AND l_seq_name1 = trim(p_seq_name2)
      AND p_last_val2 IS NOT NULL AND nvl(l_seq_last1, -99) <> p_last_val2 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             last_used_number_1     = p_last_val2
      WHERE
             payment_profile_id = l_payment_profile_id;

      l_obj_updated := TRUE;

    ELSIF l_seq_name2 IS NOT NULL AND l_seq_name2 = trim(p_seq_name2)
      AND p_last_val2 IS NOT NULL AND nvl(l_seq_last2, -99) <> p_last_val2 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             last_used_number_2     = p_last_val2
      WHERE
             payment_profile_id = l_payment_profile_id;

      l_obj_updated := TRUE;

    ELSIF l_seq_name3 IS NOT NULL AND l_seq_name3 = trim(p_seq_name2)
      AND p_last_val2 IS NOT NULL AND nvl(l_seq_last3, -99) <> p_last_val2 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             last_used_number_3     = p_last_val2
      WHERE
             payment_profile_id = l_payment_profile_id;

      l_obj_updated := TRUE;

    END IF;

    -- input seq3
    IF l_seq_name1 IS NOT NULL AND l_seq_name1 = trim(p_seq_name3)
      AND p_last_val3 IS NOT NULL AND nvl(l_seq_last1, -99) <> p_last_val3 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             last_used_number_1     = p_last_val3
      WHERE
             payment_profile_id = l_payment_profile_id;

      l_obj_updated := TRUE;

    ELSIF l_seq_name2 IS NOT NULL AND l_seq_name2 = trim(p_seq_name3)
      AND p_last_val3 IS NOT NULL AND nvl(l_seq_last2, -99) <> p_last_val3 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             last_used_number_2     = p_last_val3
      WHERE
             payment_profile_id = l_payment_profile_id;

      l_obj_updated := TRUE;

    ELSIF l_seq_name3 IS NOT NULL AND l_seq_name3 = trim(p_seq_name3)
      AND p_last_val3 IS NOT NULL AND nvl(l_seq_last3, -99) <> p_last_val3 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             last_used_number_3     = p_last_val3
      WHERE
             payment_profile_id = l_payment_profile_id;

      l_obj_updated := TRUE;

    END IF;

    IF l_obj_updated THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             object_version_number  = object_version_number + 1,
             last_updated_by        = fnd_global.user_id,
             last_update_date       = SYSDATE,
             last_update_login      = fnd_global.LOGIN_ID
      WHERE
             payment_profile_id = l_payment_profile_id;

    END IF;

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

  END save_last_periodic_seq_nums;



  PROCEDURE set_sra_created
  (
  p_payment_instruction_id   IN     NUMBER
  )
  IS
    l_instruction_ovn       NUMBER;

    CURSOR l_instruction_ovn_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT object_version_number
      FROM iby_pay_instructions_all
     WHERE payment_instruction_id = p_payment_instruction_id;

  BEGIN

    OPEN  l_instruction_ovn_csr (p_payment_instruction_id);
    FETCH l_instruction_ovn_csr INTO l_instruction_ovn;
    CLOSE l_instruction_ovn_csr;

    UPDATE
      iby_pay_instructions_all
    SET
      remittance_advice_created_flag = 'Y',
      object_version_number     = l_instruction_ovn + 1,
      last_updated_by           = fnd_global.user_id,
      last_update_date          = SYSDATE,
      last_update_login         = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
    WHERE
      payment_instruction_id = p_payment_instruction_id;

  END set_sra_created;


  PROCEDURE set_pos_pay_created
  (
  p_payment_instruction_id   IN     NUMBER
  )
  IS
    l_instruction_ovn       NUMBER;

    CURSOR l_instruction_ovn_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT object_version_number
      FROM iby_pay_instructions_all
     WHERE payment_instruction_id = p_payment_instruction_id;

  BEGIN

    OPEN  l_instruction_ovn_csr (p_payment_instruction_id);
    FETCH l_instruction_ovn_csr INTO l_instruction_ovn;
    CLOSE l_instruction_ovn_csr;

    UPDATE
      iby_pay_instructions_all
    SET
      positive_pay_file_created_flag = 'Y',
      object_version_number     = l_instruction_ovn + 1,
      last_updated_by           = fnd_global.user_id,
      last_update_date          = SYSDATE,
      last_update_login         = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
    WHERE
      payment_instruction_id = p_payment_instruction_id;

  END set_pos_pay_created;


  PROCEDURE set_reg_rpt_created
  (
  p_payment_instruction_id   IN     NUMBER
  )
  IS
    l_instruction_ovn       NUMBER;

    CURSOR l_instruction_ovn_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT object_version_number
      FROM iby_pay_instructions_all
     WHERE payment_instruction_id = p_payment_instruction_id;

  BEGIN

    OPEN  l_instruction_ovn_csr (p_payment_instruction_id);
    FETCH l_instruction_ovn_csr INTO l_instruction_ovn;
    CLOSE l_instruction_ovn_csr;

    UPDATE
      iby_pay_instructions_all
    SET
      regulatory_report_created_flag = 'Y',
      object_version_number     = l_instruction_ovn + 1,
      last_updated_by           = fnd_global.user_id,
      last_update_date          = SYSDATE,
      last_update_login         = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
    WHERE
      payment_instruction_id = p_payment_instruction_id;

  END set_reg_rpt_created;


  PROCEDURE post_fv_summary_format_status
  (
  p_payment_instruction_id   IN     NUMBER,
  p_process_status           IN     VARCHAR2
  )
  IS
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

  BEGIN

    FV_FEDERAL_PAYMENT_FIELDS_PKG.Summary_Format_Prog_Completed(
      p_api_version  => 1.0 ,
      p_init_msg_list => NULL,
      p_commit => FND_API.G_FALSE,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data  => l_msg_data,
      p_payment_instruction_id => p_payment_instruction_id,
      p_format_complete_status => p_process_status
    );

  END post_fv_summary_format_status;


  FUNCTION get_instruction_format
  (
  p_payment_instruction_id   IN     NUMBER,
  p_format_type              IN     VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_format_code varchar2(30);
    l_acp_ltr_format_code varchar2(30);
    l_pos_pay_format_code varchar2(30);
    l_reg_rpt_format_code varchar2(30);

    CURSOR l_sra_format_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT sra.remittance_advice_format_code
      FROM iby_pay_instructions_all ins, iby_payment_profiles pp,
           iby_remit_advice_setup sra
     WHERE payment_instruction_id = p_payment_instruction_id
       AND ins.payment_profile_id = pp.payment_profile_id
       AND pp.system_profile_code = sra.system_profile_code;

    CURSOR l_aux_format_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT pp.pay_file_letter_format_code,
           pp.positive_pay_format_code,
           pp.declaration_report_name
      FROM iby_pay_instructions_all ins, iby_payment_profiles pp
     WHERE payment_instruction_id = p_payment_instruction_id
       AND ins.payment_profile_id = pp.payment_profile_id;

  BEGIN

    IF p_format_type = 'REMITTANCE_ADVICE' THEN

       OPEN l_sra_format_csr (p_payment_instruction_id);
      FETCH l_sra_format_csr INTO l_format_code;
      CLOSE l_sra_format_csr;

    ELSIF p_format_type = 'DISBURSEMENT_ACCOMPANY_LETTER' OR
          p_format_type = 'POSITIVE_PAY_FILE' OR
          p_format_type = 'REGULATORY_REPORTING' THEN

      OPEN  l_aux_format_csr (p_payment_instruction_id);
      FETCH l_aux_format_csr INTO l_acp_ltr_format_code, l_pos_pay_format_code, l_reg_rpt_format_code;
      CLOSE l_aux_format_csr;

      IF p_format_type = 'DISBURSEMENT_ACCOMPANY_LETTER' THEN
        l_format_code := l_acp_ltr_format_code;
      ELSIF p_format_type = 'POSITIVE_PAY_FILE' THEN
        l_format_code := l_pos_pay_format_code;
      ELSIF p_format_type = 'REGULATORY_REPORTING' THEN
        l_format_code := l_reg_rpt_format_code;
      END IF;
    END IF;

    return l_format_code;

  END get_instruction_format;


  FUNCTION get_allow_multiple_sra_flag
  (
  p_payment_instruction_id   IN     NUMBER
  ) RETURN VARCHAR2
  IS
    l_allow_multiple_sra_flag varchar2(1);

     CURSOR l_multi_sra_flag_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT sra.allow_multiple_copy_flag
      FROM iby_pay_instructions_all ins, iby_payment_profiles pp,
           iby_remit_advice_setup sra
     WHERE payment_instruction_id = p_payment_instruction_id
       AND ins.payment_profile_id = pp.payment_profile_id
       AND pp.system_profile_code = sra.system_profile_code;

  BEGIN

     OPEN l_multi_sra_flag_csr (p_payment_instruction_id);
    FETCH l_multi_sra_flag_csr INTO l_allow_multiple_sra_flag;
    CLOSE l_multi_sra_flag_csr;

    return l_allow_multiple_sra_flag;
  END get_allow_multiple_sra_flag;


  PROCEDURE Init_Security
  IS
    l_appl_name   VARCHAR2(50);
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Init_Security';

    CURSOR l_ce_spgt_csr IS
    SELECT organization_type, organization_id, name
      FROM ce_security_profiles_v;

  BEGIN

    IF ce_sp_access_C = 0 THEN

      -- can't use the CE function because
      -- we can be in a query
      -- have to init ourselves
      -- can't use the _gt. Have to use _v
      --CEP_STANDARD.init_security;

      IF MO_GLOBAL.is_mo_init_done = 'N' THEN
        select  APPLICATION_SHORT_NAME
        into    l_appl_name
        from    FND_APPLICATION
        where   APPLICATION_ID = FND_GLOBAL.resp_appl_id;

        -- Set MOAC security
        MO_GLOBAL.init(l_appl_name);
      END IF;

      iby_debug_pub.add(debug_msg => 'Checking accessible orgs',
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

      FOR l_ce_spgt IN l_ce_spgt_csr LOOP

        iby_debug_pub.add(debug_msg => 'Org type: ' || l_ce_spgt.organization_type ||
                          ' Org id: ' || l_ce_spgt.organization_id ||
                          ' Org name: ' || l_ce_spgt.name,
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);

      END LOOP;

      iby_debug_pub.add(debug_msg => 'Done checking accessible orgs',
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

      ce_sp_access_C := ce_sp_access_C + 1;

    END IF;

  END Init_Security;

  -- all orgs must be accessible
  -- also used to calculate moac data blocking flag
  FUNCTION val_instruction_accessible
  (
  p_payment_instruction_id   IN     NUMBER
  ) RETURN VARCHAR2
  IS
    l_dummy  VARCHAR2(30);
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.validate_instruction_accessible';

    -- all orgs belonging to the instruction
    CURSOR l_ins_org_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT po.org_type, po.org_id
      FROM iby_pay_instructions_all ins, iby_process_orgs po
     WHERE ins.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_instruction_id = po.object_id
       AND po.object_type = 'PAYMENT_INSTRUCTION';

    CURSOR l_validate_org_accessible_csr (p_org_type IN VARCHAR2, p_org_id IN NUMBER) IS
    SELECT 'exist'
      FROM ce_security_profiles_v
     WHERE organization_type = p_org_type
       AND organization_id = p_org_id;

  BEGIN

    iby_debug_pub.add(debug_msg => 'In validate_instruction_accessible(), before Init_Security',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    Init_Security;

    iby_debug_pub.add(debug_msg => 'In validate_instruction_accessible(), after Init_Security',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    FOR l_ins_org IN l_ins_org_csr(p_payment_instruction_id) LOOP

       OPEN l_validate_org_accessible_csr (l_ins_org.org_type, l_ins_org.org_id);
      FETCH l_validate_org_accessible_csr INTO l_dummy;

      IF l_validate_org_accessible_csr%NOTFOUND THEN

        iby_debug_pub.add(debug_msg => 'Org type: ' || l_ins_org.org_type || ' Org id: ' || l_ins_org.org_id ||
                          ' is not accessible for user',
                          debug_level => FND_LOG.LEVEL_STATEMENT,
                          module => l_Debug_Module);

        CLOSE l_validate_org_accessible_csr;
        return 'N';
      END IF;

      CLOSE l_validate_org_accessible_csr;

    END LOOP;

    return 'Y';

  END val_instruction_accessible;


  FUNCTION val_pmt_reg_instr_accessible
  (
  p_payment_instruction_id   IN     NUMBER
  ) RETURN VARCHAR2
  IS
    l_num_accessible_orgs   NUMBER;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.val_pmt_reg_instr_accessible';

    CURSOR l_accessible_orgs_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT count(po.org_id)
      FROM iby_pay_instructions_all ins, iby_process_orgs po, ce_security_profiles_v ce_sp
     WHERE ins.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_instruction_id = po.object_id
       AND po.object_type = 'PAYMENT_INSTRUCTION'
       AND ce_sp.organization_type = po.org_type
       AND ce_sp.organization_id = po.org_id;

  BEGIN

    Init_Security;

    iby_debug_pub.add(debug_msg => 'p_payment_instruction_id: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

     OPEN l_accessible_orgs_csr (p_payment_instruction_id);
    FETCH l_accessible_orgs_csr INTO l_num_accessible_orgs;
    CLOSE l_accessible_orgs_csr;

    iby_debug_pub.add(debug_msg => 'Number of orgs accessible for the user: ' || l_num_accessible_orgs,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    IF l_num_accessible_orgs >= 1 THEN

      return 'Y';
    END IF;

    return 'N';

  END val_pmt_reg_instr_accessible;


  FUNCTION val_ppr_st_rpt_accessible
  (
  p_payment_service_request_id   IN     NUMBER
  ) RETURN VARCHAR2
  IS
    l_num_accessible_orgs   NUMBER;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.val_ppr_st_rpt_accessible';

  BEGIN

    Init_Security;

    iby_debug_pub.add(debug_msg => 'p_payment_service_request_id: ' || p_payment_service_request_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    l_num_accessible_orgs := get_accessible_ppr_org_count(p_payment_service_request_id);

    iby_debug_pub.add(debug_msg => 'Number of orgs accessible for the user: ' || l_num_accessible_orgs,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    IF l_num_accessible_orgs >= 1 THEN

      return 'Y';
    END IF;

    return 'N';

  END val_ppr_st_rpt_accessible;


  FUNCTION get_accessible_ppr_org_count
  (
  p_payment_service_request_id   IN     NUMBER
  ) RETURN NUMBER
  IS
    l_num_accessible_orgs   NUMBER;

    CURSOR l_accessible_orgs_csr (p_payment_service_request_id IN NUMBER) IS
    SELECT count(po.org_id)
      FROM iby_pay_service_requests ppr, iby_process_orgs po, ce_security_profiles_v ce_sp
     WHERE ppr.payment_service_request_id = p_payment_service_request_id
       AND ppr.payment_service_request_id = po.object_id
       AND po.object_type = 'PAYMENT_REQUEST'
       AND ce_sp.organization_type = po.org_type
       AND ce_sp.organization_id = po.org_id;

  BEGIN

     OPEN l_accessible_orgs_csr (p_payment_service_request_id);
    FETCH l_accessible_orgs_csr INTO l_num_accessible_orgs;
    CLOSE l_accessible_orgs_csr;

    RETURN l_num_accessible_orgs;

  END get_accessible_ppr_org_count;


  FUNCTION check_ppr_moac_blocking
  (
  p_payment_service_request_id   IN     NUMBER
  ) RETURN VARCHAR2
  IS
    l_num_accessible_orgs    NUMBER;
    l_total_orgs             NUMBER;

    CURSOR l_total_orgs_csr (p_payment_service_request_id IN NUMBER) IS
    SELECT count(po.org_id)
      FROM iby_pay_service_requests ppr, iby_process_orgs po
     WHERE ppr.payment_service_request_id = p_payment_service_request_id
       AND ppr.payment_service_request_id = po.object_id
       AND po.object_type = 'PAYMENT_REQUEST';

  BEGIN

     OPEN l_total_orgs_csr (p_payment_service_request_id);
    FETCH l_total_orgs_csr INTO l_total_orgs;
    CLOSE l_total_orgs_csr;

    IF l_total_orgs > get_accessible_ppr_org_count(p_payment_service_request_id) THEN
      RETURN 'Y';
    END IF;

    RETURN 'N';

  END check_ppr_moac_blocking;




  PROCEDURE Reset_Periodic_Sequence_Value
  (
  x_errbuf OUT NOCOPY VARCHAR2,
  x_retcode OUT NOCOPY VARCHAR2,
  p_payment_profile_id IN  NUMBER,
  p_sequence_number IN  NUMBER,
  p_reset_value IN  NUMBER,
  p_arg2 IN VARCHAR2 DEFAULT NULL, p_arg3 IN VARCHAR2 DEFAULT NULL,
  p_arg4 IN VARCHAR2 DEFAULT NULL,p_arg5 IN VARCHAR2 DEFAULT NULL,
  p_arg6 IN VARCHAR2 DEFAULT NULL, p_arg7 IN VARCHAR2 DEFAULT NULL,
  p_arg8 IN VARCHAR2 DEFAULT NULL, p_arg9 IN VARCHAR2 DEFAULT NULL,
  p_arg10 IN VARCHAR2 DEFAULT NULL, p_arg11 IN VARCHAR2 DEFAULT NULL,
  p_arg12 IN VARCHAR2 DEFAULT NULL, p_arg13 IN VARCHAR2 DEFAULT NULL,
  p_arg14 IN VARCHAR2 DEFAULT NULL, p_arg15 IN VARCHAR2 DEFAULT NULL,
  p_arg16 IN VARCHAR2 DEFAULT NULL, p_arg17 IN VARCHAR2 DEFAULT NULL,
  p_arg18 IN VARCHAR2 DEFAULT NULL, p_arg19 IN VARCHAR2 DEFAULT NULL,
  p_arg20 IN VARCHAR2 DEFAULT NULL, p_arg21 IN VARCHAR2 DEFAULT NULL,
  p_arg22 IN VARCHAR2 DEFAULT NULL, p_arg23 IN VARCHAR2 DEFAULT NULL,
  p_arg24 IN VARCHAR2 DEFAULT NULL, p_arg25 IN VARCHAR2 DEFAULT NULL,
  p_arg26 IN VARCHAR2 DEFAULT NULL, p_arg27 IN VARCHAR2 DEFAULT NULL,
  p_arg28 IN VARCHAR2 DEFAULT NULL, p_arg29 IN VARCHAR2 DEFAULT NULL,
  p_arg30 IN VARCHAR2 DEFAULT NULL, p_arg31 IN VARCHAR2 DEFAULT NULL,
  p_arg32 IN VARCHAR2 DEFAULT NULL, p_arg33 IN VARCHAR2 DEFAULT NULL,
  p_arg34 IN VARCHAR2 DEFAULT NULL, p_arg35 IN VARCHAR2 DEFAULT NULL,
  p_arg36 IN VARCHAR2 DEFAULT NULL, p_arg37 IN VARCHAR2 DEFAULT NULL,
  p_arg38 IN VARCHAR2 DEFAULT NULL, p_arg39 IN VARCHAR2 DEFAULT NULL,
  p_arg40 IN VARCHAR2 DEFAULT NULL, p_arg41 IN VARCHAR2 DEFAULT NULL,
  p_arg42 IN VARCHAR2 DEFAULT NULL, p_arg43 IN VARCHAR2 DEFAULT NULL,
  p_arg44 IN VARCHAR2 DEFAULT NULL, p_arg45 IN VARCHAR2 DEFAULT NULL,
  p_arg46 IN VARCHAR2 DEFAULT NULL, p_arg47 IN VARCHAR2 DEFAULT NULL,
  p_arg48 IN VARCHAR2 DEFAULT NULL, p_arg49 IN VARCHAR2 DEFAULT NULL,
  p_arg50 IN VARCHAR2 DEFAULT NULL, p_arg51 IN VARCHAR2 DEFAULT NULL,
  p_arg52 IN VARCHAR2 DEFAULT NULL, p_arg53 IN VARCHAR2 DEFAULT NULL,
  p_arg54 IN VARCHAR2 DEFAULT NULL, p_arg55 IN VARCHAR2 DEFAULT NULL,
  p_arg56 IN VARCHAR2 DEFAULT NULL, p_arg57 IN VARCHAR2 DEFAULT NULL,
  p_arg58 IN VARCHAR2 DEFAULT NULL, p_arg59 IN VARCHAR2 DEFAULT NULL,
  p_arg60 IN VARCHAR2 DEFAULT NULL, p_arg61 IN VARCHAR2 DEFAULT NULL,
  p_arg62 IN VARCHAR2 DEFAULT NULL, p_arg63 IN VARCHAR2 DEFAULT NULL,
  p_arg64 IN VARCHAR2 DEFAULT NULL, p_arg65 IN VARCHAR2 DEFAULT NULL,
  p_arg66 IN VARCHAR2 DEFAULT NULL, p_arg67 IN VARCHAR2 DEFAULT NULL,
  p_arg68 IN VARCHAR2 DEFAULT NULL, p_arg69 IN VARCHAR2 DEFAULT NULL,
  p_arg70 IN VARCHAR2 DEFAULT NULL, p_arg71 IN VARCHAR2 DEFAULT NULL,
  p_arg72 IN VARCHAR2 DEFAULT NULL, p_arg73 IN VARCHAR2 DEFAULT NULL,
  p_arg74 IN VARCHAR2 DEFAULT NULL, p_arg75 IN VARCHAR2 DEFAULT NULL,
  p_arg76 IN VARCHAR2 DEFAULT NULL, p_arg77 IN VARCHAR2 DEFAULT NULL,
  p_arg78 IN VARCHAR2 DEFAULT NULL, p_arg79 IN VARCHAR2 DEFAULT NULL,
  p_arg80 IN VARCHAR2 DEFAULT NULL, p_arg81 IN VARCHAR2 DEFAULT NULL,
  p_arg82 IN VARCHAR2 DEFAULT NULL, p_arg83 IN VARCHAR2 DEFAULT NULL,
  p_arg84 IN VARCHAR2 DEFAULT NULL, p_arg85 IN VARCHAR2 DEFAULT NULL,
  p_arg86 IN VARCHAR2 DEFAULT NULL, p_arg87 IN VARCHAR2 DEFAULT NULL,
  p_arg88 IN VARCHAR2 DEFAULT NULL, p_arg89 IN VARCHAR2 DEFAULT NULL,
  p_arg90 IN VARCHAR2 DEFAULT NULL, p_arg91 IN VARCHAR2 DEFAULT NULL,
  p_arg92 IN VARCHAR2 DEFAULT NULL, p_arg93 IN VARCHAR2 DEFAULT NULL,
  p_arg94 IN VARCHAR2 DEFAULT NULL, p_arg95 IN VARCHAR2 DEFAULT NULL,
  p_arg96 IN VARCHAR2 DEFAULT NULL, p_arg97 IN VARCHAR2 DEFAULT NULL,
  p_arg98 IN VARCHAR2 DEFAULT NULL, p_arg99 IN VARCHAR2 DEFAULT NULL,
  p_arg100 IN VARCHAR2 DEFAULT NULL
  )
  IS

    l_payment_profile_name  VARCHAR2(100);
    l_seq_notfound          BOOLEAN;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Reset_Periodic_Sequence_Value';

    CURSOR l_val_seq_csr IS
    SELECT payment_profile_name
      FROM iby_payment_profiles
     WHERE payment_profile_id = p_payment_profile_id;

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input parameters: ',
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => '============================================',
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_payment_profile_id: ' || p_payment_profile_id,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_sequence_number: ' || p_sequence_number,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_reset_value: ' || p_reset_value,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => '============================================',
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);


     OPEN l_val_seq_csr;
    FETCH l_val_seq_csr INTO l_payment_profile_name;
    l_seq_notfound := l_val_seq_csr%NOTFOUND;
    CLOSE l_val_seq_csr;

    IF l_seq_notfound THEN
      -- set error for invalid data
      fnd_message.set_name('IBY', 'IBY_FD_PPP_SEQ_NOT_SAVED');
      fnd_msg_pub.add;

      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_sequence_number = 1 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             reset_value_1          = nvl(p_reset_value, reset_value_1),
             last_used_number_1     = nvl(p_reset_value, reset_value_1),
             reset_request_1        = fnd_global.CONC_REQUEST_ID,
             object_version_number  = object_version_number + 1,
             last_updated_by        = fnd_global.user_id,
             last_update_date       = SYSDATE,
             last_update_login      = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE
             payment_profile_id = p_payment_profile_id;

    ELSIF p_sequence_number = 2 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             reset_value_2          = nvl(p_reset_value, reset_value_2),
             last_used_number_2     = nvl(p_reset_value, reset_value_2),
             reset_request_2        = fnd_global.CONC_REQUEST_ID,
             object_version_number  = object_version_number + 1,
             last_updated_by        = fnd_global.user_id,
             last_update_date       = SYSDATE,
             last_update_login      = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE
             payment_profile_id = p_payment_profile_id;

    ELSIF p_sequence_number = 3 THEN

      UPDATE iby_acct_pmt_profiles_b
         SET
             reset_value_3          = nvl(p_reset_value, reset_value_3),
             last_used_number_3     = nvl(p_reset_value, reset_value_3),
             reset_request_3        = fnd_global.CONC_REQUEST_ID,
             object_version_number  = object_version_number + 1,
             last_updated_by        = fnd_global.user_id,
             last_update_date       = SYSDATE,
             last_update_login      = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE
             payment_profile_id = p_payment_profile_id;

    END IF;

    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

  END Reset_Periodic_Sequence_Value;


  FUNCTION submit_schedule
  (
  p_payment_profile_id   IN     NUMBER,
  p_sequence_number      IN     NUMBER,
  p_reset_value          IN     NUMBER
  ) RETURN NUMBER
  IS
    l_def_sts               BOOLEAN;
    l_request_id            NUMBER;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.submit_schedule';
    l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
    l_bool_val   boolean;  -- Bug 6411356

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_payment_profile_id: ' || p_payment_profile_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_sequence_number: ' || p_sequence_number,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_reset_value: ' || p_reset_value,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Setting request to deferred',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    l_def_sts := fnd_request.set_deferred();

    IF l_def_sts = FALSE THEN
      iby_debug_pub.add(debug_msg => 'Warning: failed to set request as deferred',
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

    END IF;

    iby_debug_pub.add(debug_msg => 'Before Calling FND_REQUEST.SUBMIT_REQUEST()',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


    --Bug 6411356
    --below code added to set the current nls character setting
    --before submitting a child requests.
    fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
    l_bool_val:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);


    -- submit the extract program
    l_request_id := FND_REQUEST.SUBMIT_REQUEST
    (
      'IBY',
      'IBY_RESET_PERIODIC_SEQ',
      null,  -- description
      null,  -- start_time
      FALSE, -- sub_request
      p_payment_profile_id,
      p_sequence_number,
      p_reset_value,
      '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', ''
    );

    iby_debug_pub.add(debug_msg => 'After Calling FND_REQUEST.SUBMIT_REQUEST()',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    iby_debug_pub.add(debug_msg => 'Request id: ' || l_request_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

    RETURN l_request_id;

  END submit_schedule;


  PROCEDURE submit_acp_ltr
  (
  p_payment_instruction_id   IN     NUMBER
  )
  IS
    l_acp_ltr_fmt_code      VARCHAR2(30);
    l_fmt_notfound          BOOLEAN;
    l_request_id            NUMBER;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.submit_acp_ltr';
    l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
    l_return_status   boolean;  -- Bug 6411356

    CURSOR l_acp_ltr_fmt_csr IS
    SELECT pay_file_letter_format_code
      FROM iby_payment_profiles pp, iby_pay_instructions_all ins
     WHERE ins.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_profile_id = pp.payment_profile_id;

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

     OPEN l_acp_ltr_fmt_csr;
    FETCH l_acp_ltr_fmt_csr INTO l_acp_ltr_fmt_code;
    l_fmt_notfound := l_acp_ltr_fmt_csr%NOTFOUND;
    CLOSE l_acp_ltr_fmt_csr;

    IF l_fmt_notfound THEN
      iby_debug_pub.add(debug_msg => 'The payment process profile for the instruction does not have an ' ||
                       'accompany letter format. So no action is required. ',
                       debug_level => FND_LOG.LEVEL_STATEMENT,
                       module => l_Debug_Module);
      RETURN;
    END IF;


    iby_debug_pub.add(debug_msg => 'Before Calling FND_REQUEST.SUBMIT_REQUEST()',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


    --Bug 6411356
    --below code added to set the current nls character setting
    --before submitting a child requests.
    fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
    l_return_status:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);


    -- submit the acp ltr program
    -- note the format code is not passed
    l_request_id := FND_REQUEST.SUBMIT_REQUEST
    (
      'IBY',
      'IBY_FD_ACP_LTR_FORMAT',
      null,  -- description
      null,  -- start_time
      FALSE, -- sub_request
      p_payment_instruction_id,
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', ''
    );

    iby_debug_pub.add(debug_msg => 'After Calling FND_REQUEST.SUBMIT_REQUEST()',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    iby_debug_pub.add(debug_msg => 'Request id: ' || l_request_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

    COMMIT;

  END submit_acp_ltr;


  PROCEDURE Run_ECE_Formatting
  (
  p_payment_instruction_id   IN     NUMBER
  )
  IS
    l_ece_status          VARCHAR2(1);
    l_post_status         VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_Debug_Module        VARCHAR2(255) := G_DEBUG_MODULE || '.Run_ECE_Formatting';

  BEGIN
   iby_debug_pub.log(debug_msg => 'Enter: Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Calling ECE_AP_PAYMENT.Extract_PYO_Outbound() API... ' || l_ece_status,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


    ECE_AP_PAYMENT.Extract_PYO_Outbound ( p_api_version => 1.0,
                               p_init_msg_list          => fnd_api.g_false,
                               p_commit                 => fnd_api.g_false,
                               x_return_status          => l_ece_status,
                               x_msg_count              => l_msg_count,
                               x_msg_data               => l_msg_data,
                               p_payment_instruction_id => p_payment_instruction_id);
    iby_debug_pub.log(debug_msg => 'Exit ECE_AP_PAYMENT: Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'After calling ECE_AP_PAYMENT.Extract_PYO_Outbound() API, return status: ' || l_ece_status,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    IF l_ece_status = FND_API.G_RET_STS_SUCCESS THEN

      iby_debug_pub.add(debug_msg => 'Calling Post_Results()',
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);
      iby_debug_pub.log(debug_msg => 'Enter: Post Results::Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);
      IBY_FD_POST_PICP_PROGS_PVT.Post_Results
      (
       p_payment_instruction_id   => p_payment_instruction_id,
       p_newStatus                => 'FORMATTED_ELECTRONIC',
       p_is_reprint_flag          => 'N',
       x_return_status            => l_post_status
      );
	  iby_debug_pub.log(debug_msg => 'Exit: Post Results::Timestamp:'  || systimestamp,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

      iby_debug_pub.add(debug_msg => 'After calling Post_Results(), return status: ' || l_post_status,
                        debug_level => FND_LOG.LEVEL_STATEMENT,
                        module => l_Debug_Module);

      IF l_post_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

  END Run_ECE_Formatting;


  PROCEDURE Test_CP
  (
  p_payment_instruction_id   IN     NUMBER,
  p_program_short_name       IN     VARCHAR2
  )
  IS
    l_request_id            NUMBER;
    l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Test_CP';

    l_icx_numeric_characters   VARCHAR2(30); -- Bug 6411356
    l_bool_val   boolean;  -- Bug 6411356

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


    iby_debug_pub.add(debug_msg => 'Before Calling FND_REQUEST.SUBMIT_REQUEST()',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


    --Bug 6411356
    --below code added to set the current nls character setting
    --before submitting a child requests.
    fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
    l_bool_val:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);

    -- submit the extract program
    l_request_id := FND_REQUEST.SUBMIT_REQUEST
    (
      'IBY',
      p_program_short_name,
      null,  -- description
      null,  -- start_time
      FALSE, -- sub_request
      p_payment_instruction_id,
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', '', '', '', '', '', '',
      '', '', ''
    );

    iby_debug_pub.add(debug_msg => 'After Calling FND_REQUEST.SUBMIT_REQUEST()',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);
    iby_debug_pub.add(debug_msg => 'Request id: ' || l_request_id,
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    IF l_request_id = 0 THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    iby_debug_pub.add(debug_msg => 'Exit: ' || l_Debug_Module,
                    debug_level => FND_LOG.LEVEL_PROCEDURE,
                    module => l_Debug_Module);

  END Test_CP;

 PROCEDURE Retry_Completion
  (
    p_payment_instruction_id   IN     NUMBER,
    x_return_status	       OUT NOCOPY  VARCHAR2
  ) IS

  l_mark_complete_status  VARCHAR2(240);
  l_format_code           VARCHAR2(30);

  l_Debug_Module          VARCHAR2(255) := G_DEBUG_MODULE || '.Post_Results';
  l_msg_data	VARCHAR2(2000);

  CURSOR l_instruction_ovn_csr (p_payment_instruction_id IN NUMBER) IS
  SELECT pp.payment_format_code
  FROM iby_pay_instructions_all ins, iby_payment_profiles pp
  WHERE ins.payment_profile_id = pp.payment_profile_id
  AND payment_instruction_id = p_payment_instruction_id;

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter IBY_FD_POST_PICP_PROGS_PVT.Run_Post_Transmit_Programs'  || systimestamp,
		      debug_level => FND_LOG.LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    iby_debug_pub.add(debug_msg => 'Before Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);

    IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete (
          p_instr_id       => p_payment_instruction_id,
          x_return_status  => l_mark_complete_status
    );

    iby_debug_pub.add(debug_msg => 'After Calling IBY_DISBURSE_UI_API_PUB_PKG.mark_all_pmts_complete().',
                      debug_level => FND_LOG.LEVEL_STATEMENT,
                      module => l_Debug_Module);


    IF l_mark_complete_status <> FND_API.G_RET_STS_SUCCESS THEN
          -- set error for invalid data
          fnd_message.set_name('IBY', 'IBY_FD_ERR_MARK_COMPLETE');
          fnd_message.set_token('PARAM', p_payment_instruction_id);
          fnd_msg_pub.add;

          RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN  l_instruction_ovn_csr (p_payment_instruction_id);
    FETCH l_instruction_ovn_csr INTO l_format_code;
    CLOSE l_instruction_ovn_csr;

    -- finally kick off Federal "Payment Instruction Treasury Symbol Listing Report"
    -- if its a Federal format
    Submit_FV_TS_Report(p_payment_instruction_id, l_format_code, l_Debug_Module);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      LOOP
        l_msg_data := FND_MSG_PUB.Get;
        IF l_msg_data IS NULL THEN
          EXIT;
        ELSE
          iby_debug_pub.add(debug_msg => l_msg_data,
                            debug_level => FND_LOG.LEVEL_STATEMENT,
                            module => l_Debug_Module);
        END IF;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      LOOP
        l_msg_data := FND_MSG_PUB.Get;

        IF l_msg_data IS NULL THEN
          EXIT;
        ELSE
          iby_debug_pub.add(debug_msg => l_msg_data,
                            debug_level => FND_LOG.LEVEL_STATEMENT,
                            module => l_Debug_Module);
        END IF;
      END LOOP;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      LOOP
        l_msg_data := FND_MSG_PUB.Get;

        IF l_msg_data IS NULL THEN
          EXIT;
        ELSE
          iby_debug_pub.add(debug_msg => l_msg_data,
                            debug_level => FND_LOG.LEVEL_STATEMENT,
                            module => l_Debug_Module);
        END IF;
      END LOOP;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END Retry_Completion;

END IBY_FD_POST_PICP_PROGS_PVT;



/
