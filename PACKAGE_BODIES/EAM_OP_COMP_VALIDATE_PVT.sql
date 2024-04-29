--------------------------------------------------------
--  DDL for Package Body EAM_OP_COMP_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_COMP_VALIDATE_PVT" AS
/* $Header: EAMVOCVB.pls 120.4 2006/08/22 10:16:20 sdandapa noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVOCVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_OP_COMP_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/


PROCEDURE Check_Required
   (
	  p_eam_op_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_op_comp_rec_type
        , x_return_status           OUT NOCOPY  VARCHAR2
        , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
    )IS

      l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
      l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
      l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
      l_shutdown_type	      varchar2(30);
    BEGIN

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion Populate null columns'); END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF p_eam_op_comp_rec.operation_seq_num IS NULL
        THEN
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Op Comp : operation_seq_num ...'); END IF;
            l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
            l_token_tbl(1).token_value :=  p_eam_op_comp_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OPCL_OP_REQUIRED'
             , p_token_tbl	=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            x_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

	IF p_eam_op_comp_rec.actual_start_date IS NULL
        THEN
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Op Comp : actual_start_date ...'); END IF;
            l_token_tbl(1).token_name  := 'OP_SEQ_NO';
            l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OPCL_ACTSTD_REQUIRED'
             , p_token_tbl	=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            x_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

	IF p_eam_op_comp_rec.actual_end_date IS NULL
        THEN
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Op Comp : Actual end date ...'); END IF;
            l_token_tbl(1).token_name  := 'OP_SEQ_NO';
            l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OPCL_ACTEND_REQUIRED'
             , p_token_tbl	=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            x_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

	IF p_eam_op_comp_rec.actual_duration IS NULL
        THEN
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Op Comp : Actual duration ...'); END IF;
            l_token_tbl(1).token_name  := 'OP_SEQ_NO';
            l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OPCL_ACTDUR_REQUIRED'
             , p_token_tbl	=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            x_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


	IF p_eam_op_comp_rec.transaction_type IS NULL
        THEN
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Op Comp : transaction_type  ...'); END IF;
            l_token_tbl(1).token_name  := 'OP_SEQ_NO';
            l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OPCL_TRANX_REQUIRED'
             , p_token_tbl	=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            x_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

	IF p_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE
        THEN
		SELECT shutdown_type into l_shutdown_type
		  FROM wip_discrete_jobs
                 WHERE wip_entity_id =    p_eam_op_comp_rec.wip_entity_id;

		IF l_shutdown_type IS NOT NULL THEN
		  IF p_eam_op_comp_rec.shutdown_start_date IS NULL  OR p_eam_op_comp_rec.shutdown_end_date IS NULL THEN
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Op Comp : shutdown information  ...'); END IF;

	            l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	            l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_OPCL_SHUTDOWN_REQUIRED'
		     , p_token_tbl		=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    x_mesg_token_tbl      := l_out_mesg_token_tbl;

		    x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
              END IF;
        END IF;

END Check_Required;



PROCEDURE Check_Attributes
   (
	p_eam_op_comp_rec      IN  EAM_PROCESS_WO_PUB. eam_op_comp_rec_type
      , x_return_status        OUT NOCOPY  VARCHAR2
      , x_mesg_token_tbl       OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
   )IS
        l_err_text              VARCHAR2(2000) := NULL;
	l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
	l_open_acct_per_date    DATE;
	l_reconciliation_code   VARCHAR2(30);
	l_prev_uncomplete	NUMBER	:= 0;
	l_prev_completed_after  NUMBER  := 0;
	l_job_status		NUMBER;
	l_max_prior_end_date    DATE;
	l_shutdown_type		VARCHAR2(30);

	CURSOR CON IS
	    select count(won.prior_operation)
	    from wip_operation_networks won
	    where
		won.wip_entity_id  = p_eam_op_comp_rec.wip_entity_id and
		won.next_operation = p_eam_op_comp_rec.operation_seq_num and
		exists (
			select 1 from wip_operations
			where
			    wip_entity_id = p_eam_op_comp_rec.wip_entity_id and
			    operation_seq_num = won.prior_operation and
			    nvl(operation_completed,'N') <> 'Y'
		);

	CURSOR CON1 IS
	    select count(won.next_operation)
	    from wip_operation_networks won
	    where
		won.wip_entity_id = p_eam_op_comp_rec.wip_entity_id and
		won.prior_operation = p_eam_op_comp_rec.operation_seq_num and
		exists (
			select 1 from wip_operations
			where
			    wip_entity_id = p_eam_op_comp_rec.wip_entity_id and
			    operation_seq_num = won.next_operation and
			    operation_completed = 'Y'
		);

	 --added for fix to bug 3543834:
	 CURSOR CON3 IS
	      select nvl(max(actual_end_date),sysdate-20000)
	      from eam_op_completion_txns eoct,wip_operation_networks won
	      where eoct.wip_entity_id = p_eam_op_comp_rec.wip_entity_id
	      and eoct.operation_seq_num=won.prior_operation
	      and won.wip_entity_id=eoct.wip_entity_id
	      and won.next_operation=p_eam_op_comp_rec.operation_seq_num
	      and transaction_type=1
	       and transaction_id = (select max(transaction_id)
				  from eam_op_completion_txns
				  where wip_entity_id = p_eam_op_comp_rec.wip_entity_id
					and operation_seq_num = eoct.operation_seq_num
					);

    BEGIN

    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Completeion Check Attributes'); END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking actual start and end date  ...'); END IF;
    BEGIN
	IF p_eam_op_comp_rec.actual_start_date  > p_eam_op_comp_rec.actual_end_date THEN
	    raise fnd_api.g_exc_unexpected_error;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN
	      l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	      l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_OPCMPL_DATE_BAD'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
    END;

    BEGIN
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking shutdown start and end date  ...'); END IF;
	IF p_eam_op_comp_rec.shutdown_start_date  > p_eam_op_comp_rec.shutdown_end_date THEN
	    raise fnd_api.g_exc_unexpected_error;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN
	      l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	      l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_OP_SHUTDOWN_DATE_BAD'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
    END;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking actual duration  ...'); END IF;
    BEGIN
	IF p_eam_op_comp_rec.actual_duration < 0 THEN
	    raise fnd_api.g_exc_unexpected_error;
       END IF;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN
	      l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	      l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_OP_COMP_DURATION_BAD'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
    END;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking actual end date  ...'); END IF;
    BEGIN
	IF p_eam_op_comp_rec.actual_end_date > sysdate THEN
	    raise fnd_api.g_exc_unexpected_error;
       END IF;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN

	      l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	      l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_OP_END_LATER_THAN_TODAY'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
    END;

--also added following code as part of bug 5476770
    BEGIN
	IF p_eam_op_comp_rec.shutdown_end_date > sysdate THEN
	    raise fnd_api.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN

	      l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	      l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_SHUTDOWN_DATE_IN_FUTURE'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
    END;

--end of code as part of bug 5476770


        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking open period ...'); END IF;
    BEGIN
      SELECT NVL(MIN(period_start_date), sysdate+1)
        INTO l_open_acct_per_date
        FROM org_acct_periods
       WHERE organization_id = (select organization_id from wip_discrete_jobs where wip_entity_id = p_eam_op_comp_rec.wip_entity_id)
         AND open_flag = 'Y';

	IF sysdate < l_open_acct_per_date THEN  -- p_transaction_date < l_open_acct_per_date
	    raise fnd_api.g_exc_unexpected_error;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN

	      l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	      l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_OP_TRANSACTION_DATE_INVALID'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
  END;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking reconciliation code ...'); END IF;
  BEGIN
	IF p_eam_op_comp_rec.reconciliation_code  IS NOT NULL THEN

	  SELECT ml.lookup_code
            INTO l_reconciliation_code
            FROM mfg_lookups ml			-- Fix for Bug 3509465
           WHERE ml.lookup_type = 'WIP_EAM_RECONCILIATION_CODE'
             AND ml.lookup_code = p_eam_op_comp_rec.reconciliation_code;

       END IF;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN NO_DATA_FOUND  THEN

	      l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	      l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_OP_RECONCILIATION_CODE'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
  END;


  IF p_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
     BEGIN
	SELECT shutdown_type
	  INTO l_shutdown_type
	  FROM wip_operations
	 WHERE wip_entity_id    = p_eam_op_comp_rec.wip_entity_id
	  AND operation_seq_num = p_eam_op_comp_rec.operation_seq_num;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking shutdown start and end date ...'); END IF;

	  IF l_shutdown_type IS NOT NULL AND to_number(l_shutdown_type) = 2 THEN
		IF p_eam_op_comp_rec.shutdown_start_date IS NULL OR p_eam_op_comp_rec.shutdown_end_date IS NULL THEN
		    raise fnd_api.g_exc_unexpected_error;
		END IF;
	  END IF;

	  x_return_status := FND_API.G_RET_STS_SUCCESS;

     EXCEPTION
        WHEN NO_DATA_FOUND  THEN

	      l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	      l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_OP_SHUTDOWN_DATE_MISS'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
     END;
  END IF;

  IF p_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE THEN
	BEGIN
	  open CON1;
	    fetch CON1 into l_prev_uncomplete;
	    if (CON1%NOTFOUND) then
		l_prev_uncomplete := 0;
	    end if;
	    close CON1;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking prev_uncomplete ...'); END IF;
	    IF l_prev_uncomplete > 0 THEN
		raise fnd_api.g_exc_unexpected_error;
	    END IF;

            x_return_status := FND_API.G_RET_STS_SUCCESS;

	EXCEPTION
          WHEN OTHERS THEN

		--following 2 lines removed as part of bug 5440339
		--l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	    --l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_NEXT_OP_COMPLETED'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
        END;
  END IF;

  IF p_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
	BEGIN
	   open CON;
	      fetch CON into l_prev_uncomplete;
	      if (CON%NOTFOUND) then
		l_prev_uncomplete := 0;
	      end if;
	   close CON;
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking prev_uncomplete ...'); END IF;

	   IF l_prev_uncomplete > 0 THEN
		raise fnd_api.g_exc_unexpected_error;
	   END IF;

           x_return_status := FND_API.G_RET_STS_SUCCESS;

	EXCEPTION
           WHEN OTHERS THEN

		--following 2 lines removed as part of bug 5440339
	    --l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	    --l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_PREV_OP_NOT_COMPLETED'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
       END;
  END IF;

  IF p_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE THEN
      begin
         SELECT status_type
           INTO l_job_status
           FROM wip_discrete_jobs
          WHERE wip_entity_id = p_eam_op_comp_rec.wip_entity_id;
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking status_type ...'); END IF;

         IF (l_job_status = 4 ) THEN
		raise fnd_api.g_exc_unexpected_error;
         END IF;

	 x_return_status := FND_API.G_RET_STS_SUCCESS;

      EXCEPTION
         WHEN OTHERS THEN

	      l_token_tbl(1).token_name  := 'OP_SEQ_NO';
	      l_token_tbl(1).token_value :=  p_eam_op_comp_rec.operation_seq_num;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_OP_COMP_WOCOMP_TEST'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      RETURN;
       END;
  END IF;

  IF p_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
      BEGIN
		  open CON3;
			fetch CON3 into l_max_prior_end_date;
		  close CON3;
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking actual start date and max_prior_end_date ...'); END IF;

		  if(p_eam_op_comp_rec.actual_start_date < l_max_prior_end_date) then
		     raise fnd_api.g_exc_unexpected_error;
		  end if;

		  x_return_status := FND_API.G_RET_STS_SUCCESS;

      EXCEPTION
	       WHEN OTHERS THEN
		      l_token_tbl(1).token_name  := 'MIN_START_DATE';
		      l_token_tbl(1).token_value :=  TO_CHAR(l_max_prior_end_date,'dd-MON-yyyy HH24:MI:SS');

		      l_out_mesg_token_tbl  := l_mesg_token_tbl;
		      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		      (  p_message_name  => 'EAM_PRIOR_OP_COMPLETED_AFTER'
		       , p_token_tbl     => l_token_tbl
		       , p_mesg_token_tbl     => l_mesg_token_tbl
		       , x_mesg_token_tbl     => l_out_mesg_token_tbl
		      );
		      l_mesg_token_tbl      := l_out_mesg_token_tbl;

		      x_return_status := FND_API.G_RET_STS_ERROR;
		      x_mesg_token_tbl := l_mesg_token_tbl ;
		      RETURN;
      END;
  END IF;

 END Check_Attributes;

END EAM_OP_COMP_VALIDATE_PVT;

/
