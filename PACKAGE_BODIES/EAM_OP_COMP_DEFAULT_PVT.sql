--------------------------------------------------------
--  DDL for Package Body EAM_OP_COMP_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_COMP_DEFAULT_PVT" AS
/* $Header: EAMVOCDB.pls 120.1 2006/06/16 14:56:27 gbadoni noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVOCDB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_OP_COMP_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

PROCEDURE Populate_Null_Columns (
	  p_eam_op_comp_rec      IN  EAM_PROCESS_WO_PUB.eam_op_comp_rec_type
        , x_eam_op_comp_rec      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_comp_rec_type
	, x_return_status        OUT NOCOPY  VARCHAR2
         ) IS
	 BEGIN

	 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN  EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered Package EAM_OP_COMP_DEFAULT_PVT.Populate_Null_Columns procedure..'); END IF;

 	 x_return_status   := FND_API.G_RET_STS_SUCCESS;
	 x_eam_op_comp_rec := p_eam_op_comp_rec;

	 IF p_eam_op_comp_rec.transaction_id IS NULL THEN
		   SELECT eam_op_completion_txns_s.nextval
		     INTO x_eam_op_comp_rec.transaction_id
		     FROM DUAL;
	 END IF;

	 IF p_eam_op_comp_rec.qa_collection_id IS NULL THEN
	          SELECT qa_collection_id_s.nextval
		    INTO x_eam_op_comp_rec.qa_collection_id
		    FROM DUAL;
	 END IF;

	 IF p_eam_op_comp_rec.transaction_date IS NULL THEN
		  SELECT sysdate
		    INTO x_eam_op_comp_rec.transaction_date
		    FROM DUAL;
	 END IF;

	 IF p_eam_op_comp_rec.actual_start_date IS NOT NULL AND
	       p_eam_op_comp_rec.actual_end_date IS NOT NULL AND
               p_eam_op_comp_rec.actual_duration IS NULL THEN
		x_eam_op_comp_rec.actual_duration :=
			(p_eam_op_comp_rec.actual_end_date - p_eam_op_comp_rec.actual_start_date)*24;
	 END IF;

	 IF p_eam_op_comp_rec.actual_start_date IS NOT NULL AND
	   p_eam_op_comp_rec.actual_duration IS NOT NULL AND
           p_eam_op_comp_rec.actual_end_date IS NULL THEN
		x_eam_op_comp_rec.actual_end_date :=
			p_eam_op_comp_rec.actual_start_date + p_eam_op_comp_rec.actual_duration * 24;
	 END IF;

	 IF p_eam_op_comp_rec.actual_end_date IS NOT NULL AND
	   p_eam_op_comp_rec.actual_duration IS NOT NULL AND
           p_eam_op_comp_rec.actual_start_date IS NULL THEN
		x_eam_op_comp_rec.actual_start_date :=
			p_eam_op_comp_rec.actual_end_date - p_eam_op_comp_rec.actual_duration*24;
	 END IF;

	 IF p_eam_op_comp_rec.department_id IS NULL THEN
		SELECT department_id INTO x_eam_op_comp_rec.department_id
		  FROM WIP_OPERATIONS
		 WHERE organization_id   = p_eam_op_comp_rec.organization_id
		   AND wip_entity_id     = p_eam_op_comp_rec.wip_entity_id
		   AND operation_seq_num = p_eam_op_comp_rec.operation_seq_num;
	 END IF;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Exiting Package EAM_OP_COMP_DEFAULT_PVT.Populate_Null_Columns procedure without errors ....'); END IF;

  EXCEPTION WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Exception happened in EAM_OP_COMP_DEFAULT_PVT.Populate_Null_Columns procedure. exiting.'); END IF;

END Populate_Null_Columns;


END EAM_OP_COMP_DEFAULT_PVT;

/
