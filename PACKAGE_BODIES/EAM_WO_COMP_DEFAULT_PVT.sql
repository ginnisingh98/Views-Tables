--------------------------------------------------------
--  DDL for Package Body EAM_WO_COMP_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_COMP_DEFAULT_PVT" AS
/* $Header: EAMVWCDB.pls 120.1 2006/06/16 13:21:21 yjhabak noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWCDB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_COMP_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

PROCEDURE Populate_Null_Columns
(
  p_eam_wo_comp_rec      IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
, x_eam_wo_comp_rec      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
, x_return_status        OUT NOCOPY  VARCHAR2
)
   IS
   i_open_past_period     BOOLEAN;
   l_asset_group_id	  NUMBER;

   BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion processing Populate null columns'); END IF;

	x_eam_wo_comp_rec  := p_eam_wo_comp_rec;
	i_open_past_period :=FALSE;

	 SELECT eam_job_completion_txns_s.nextval
	   INTO x_eam_wo_comp_rec.transaction_id
	   FROM DUAL;

	 IF x_eam_wo_comp_rec.transaction_date IS NULL THEN
		 SELECT sysdate
		   INTO x_eam_wo_comp_rec.transaction_date
		   FROM DUAL;
	 END IF;

	 IF p_eam_wo_comp_rec.qa_collection_id IS NULL THEN
		  SELECT qa_collection_id_s.nextval
		    INTO x_eam_wo_comp_rec.qa_collection_id
		    FROM DUAL;
	 END IF;

	invttmtx.tdatechk(p_eam_wo_comp_rec.organization_id,x_eam_wo_comp_rec.transaction_date,
			  x_eam_wo_comp_rec.acct_period_id,i_open_past_period);

	IF p_eam_wo_comp_rec.actual_start_date IS NOT NULL AND
	   p_eam_wo_comp_rec.actual_end_date IS NOT NULL AND
           p_eam_wo_comp_rec.actual_duration IS NULL THEN
		x_eam_wo_comp_rec.actual_duration :=
			(p_eam_wo_comp_rec.actual_end_date - p_eam_wo_comp_rec.actual_start_date)*24;
	END IF;

	IF p_eam_wo_comp_rec.actual_start_date IS NOT NULL AND
	   p_eam_wo_comp_rec.actual_duration IS NOT NULL AND
           p_eam_wo_comp_rec.actual_end_date IS NULL THEN
		x_eam_wo_comp_rec.actual_end_date :=
			p_eam_wo_comp_rec.actual_start_date + p_eam_wo_comp_rec.actual_duration * 24;
	END IF;

	IF p_eam_wo_comp_rec.actual_end_date IS NOT NULL AND
	   p_eam_wo_comp_rec.actual_duration IS NOT NULL AND
           p_eam_wo_comp_rec.actual_start_date IS NULL THEN
		x_eam_wo_comp_rec.actual_start_date :=
			p_eam_wo_comp_rec.actual_end_date - p_eam_wo_comp_rec.actual_duration*24;
	END IF;

	IF p_eam_wo_comp_rec.rebuild_job IS NULL THEN
	   SELECT asset_group_id
   	     INTO l_asset_group_id
	     FROM wip_discrete_jobs
	    WHERE wip_entity_id = p_eam_wo_comp_rec.wip_entity_id;

	    IF l_asset_group_id IS NULL THEN
		x_eam_wo_comp_rec.REBUILD_JOB := 'Y';
            ELSE
	    	x_eam_wo_comp_rec.REBUILD_JOB := 'N';
	    END IF;

	END IF;

	SELECT 	primary_item_id,
		asset_group_id,
		rebuild_item_id,
		asset_number,
		rebuild_serial_number,
		manual_rebuild_flag
	  INTO  x_eam_wo_comp_rec.primary_item_id,
	        x_eam_wo_comp_rec.asset_group_id,
		x_eam_wo_comp_rec.rebuild_item_id,
		x_eam_wo_comp_rec.asset_number,
		x_eam_wo_comp_rec.rebuild_serial_number,
		x_eam_wo_comp_rec.manual_rebuild_flag
	   FROM wip_discrete_jobs
	  WHERE wip_entity_id = p_eam_wo_comp_rec.wip_entity_id;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion Done processing populate null columns'); END IF;

EXCEPTION WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
           EAM_ERROR_MESSAGE_PVT.Write_Debug('EAM_WO_COMP_DEFAULT_PVT.Populate_Null_Columns  : Exception');
        END IF;
END Populate_Null_Columns;


END EAM_WO_COMP_DEFAULT_PVT;

/
