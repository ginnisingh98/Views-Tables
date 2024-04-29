--------------------------------------------------------
--  DDL for Package IBY_FD_POST_PICP_PROGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FD_POST_PICP_PROGS_PVT" AUTHID CURRENT_USER AS
/* $Header: ibyppics.pls 120.22.12010000.3 2010/09/02 16:32:06 gmaheswa ship $ */

  -- module name used for the application debugging framework
  --
  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_FD_POST_PICP_PROGS_PVT';

-- --------------------------------------------------------------------------
--               API to Process Federal Summary Format
-- --------------------------------------------------------------------------
--  The following procedure will be called by Federal code to initiate
--  the extract, formatting and delivery of Federal summary formats.
--
--  Dependencies:
--  This API has the following pre-reqs:
--  1. The summary format control number must be stored in the FV_SUMMARY_CONSOLIDATE
--  table. The API will lookup the control number by the payment instruction ID.
--  2. The treasury symbol and amounts data must be stored in the
--  FV_TP_TS_AMT_DATA table. The API will retrieve the data with the payment
--  instruction ID during payment extract.
--  3. The setup must be correct. The input format code for the summary format
--  must be a valid format defined in IBY. The summary file will be saved to
--  the file system (and) transmitted according to the same settings as the
--  original bulk payment file.
--
--  Parameters:
--  Besides the standard FND parameters, the procedure has the parameters:
--  Input:
--  p_payment_instruction_id:  This is the PK of the payment instruction
--                             for the original bulk data payment file.
--
--  p_ecs_dos_seq_num:         ECS summary format requires a periodic
--                             sequence as part of the dos file name field.
--                             This number is generated by a FV sequence
--                             and passed to IBY via this parameter. IBY
--                             will use this number for generating the
--                             ECS dos file name during the formatting.
--
--  p_summary_format_code:     The PK in IBY_FORMATS_B table for the
--                             summary format.
--  Output:
--  x_request_id:              The concurrent request ID for the
--                             extract, formatting and delivery of the
--                             summary file.
--  Current version : 1.0
--  Previous version: 1.0
--  Initial version : 1.0
--  Created: 04/06/2005
--  Created by: frzhang
-- --------------------------------------------------------------------------
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
  );


  -- This is the main interface from the payment instruction
  -- creation program (PICP) to the post PI programs.
  -- This procedure will perform extract, formatting, printing
  -- and transmission for the payment format of a
  -- payment instruction.
  --
  PROCEDURE Run_Post_PI_Programs
  (
  p_payment_instruction_id   IN     NUMBER,
  p_is_reprint_flag          IN     VARCHAR2
  );


  -- Update transaction statuses and raise business events after
  -- successful completion of the post PICP programs.
  --
  PROCEDURE Post_Results
  (
  p_payment_instruction_id   IN     NUMBER,
  p_newStatus                IN     VARCHAR2,
  p_is_reprint_flag          IN     VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2
  );


  PROCEDURE Insert_Transmission_Error
  (
  p_payment_instruction_id   IN     NUMBER,
  p_error_code               IN     VARCHAR2,
  p_error_msg                IN     VARCHAR2
  );

  PROCEDURE save_last_periodic_seq_nums
  (
  p_payment_instruction_id   IN     NUMBER,
  p_seq_name1                IN     VARCHAR2,
  p_last_val1                IN     VARCHAR2,
  p_seq_name2                IN     VARCHAR2,
  p_last_val2                IN     VARCHAR2,
  p_seq_name3                IN     VARCHAR2,
  p_last_val3                IN     VARCHAR2
  );

  PROCEDURE set_sra_created
  (
  p_payment_instruction_id   IN     NUMBER
  );


  PROCEDURE set_pos_pay_created
  (
  p_payment_instruction_id   IN     NUMBER
  );

  PROCEDURE set_reg_rpt_created
  (
  p_payment_instruction_id   IN     NUMBER
  );


  PROCEDURE post_fv_summary_format_status
  (
  p_payment_instruction_id   IN     NUMBER,
  p_process_status           IN     VARCHAR2
  );


  FUNCTION get_instruction_format
  (
  p_payment_instruction_id   IN     NUMBER,
  p_format_type              IN     VARCHAR2
  ) RETURN VARCHAR2;


  FUNCTION get_allow_multiple_sra_flag
  (
  p_payment_instruction_id   IN     NUMBER
  ) RETURN VARCHAR2;


  FUNCTION val_instruction_accessible
  (
  p_payment_instruction_id   IN     NUMBER
  ) RETURN VARCHAR2;

  FUNCTION val_pmt_reg_instr_accessible
  (
  p_payment_instruction_id   IN     NUMBER
  ) RETURN VARCHAR2;

  FUNCTION val_ppr_st_rpt_accessible
  (
  p_payment_service_request_id   IN     NUMBER
  ) RETURN VARCHAR2;

  FUNCTION check_ppr_moac_blocking
  (
  p_payment_service_request_id   IN     NUMBER
  ) RETURN VARCHAR2;


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
  );


  FUNCTION submit_schedule
  (
  p_payment_profile_id   IN     NUMBER,
  p_sequence_number      IN     NUMBER,
  p_reset_value          IN     NUMBER
  ) RETURN NUMBER;


  PROCEDURE Test_CP
  (
  p_payment_instruction_id   IN     NUMBER,
  p_program_short_name       IN     VARCHAR2
  );

  PROCEDURE submit_acp_ltr
  (
  p_payment_instruction_id   IN     NUMBER
  );


  PROCEDURE Run_ECE_Formatting
  (
  p_payment_instruction_id   IN     NUMBER
  );

  PROCEDURE Retry_Completion
  (
    p_payment_instruction_id   IN     NUMBER,
    x_return_status	       OUT NOCOPY VARCHAR2
  );


END IBY_FD_POST_PICP_PROGS_PVT;

/
