--------------------------------------------------------
--  DDL for Package Body GMF_PROCESS_COST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_PROCESS_COST_PUB" AS
/* $Header: GMFPPCPB.pls 120.0 2005/11/21 14:04:03 sschinch noship $ */

/************************************************************************************
  *  PROCEDURE
  *     Get_Priod_Period_Cost
  *
  *  DESCRIPTION
  *     This procedure will return prior period cost for an organization/item for the cost
  *     type defined in fiscal policy.
  *
  *  AUTHOR
  *    Sukarna Reddy Chinchod 21-NOV-2005
  *
  *  INPUT PARAMETERS
  *   p_inventory_item_id
  *   p_organization_id
  *   p_transaction_date
  *
  *  OUTPUT PARAMETERS
  *	Returns Prior cost of an item.
  *	Status 'S' or 'E'
  *
  * HISTORY
  *
  **************************************************************************************/

PROCEDURE Get_Prior_Period_Cost(p_inventory_item_id IN          NUMBER,
                                p_organization_id   IN          NUMBER,
                                p_transaction_date  IN          DATE,
                                x_unit_cost         OUT NOCOPY  NUMBER,
                                x_msg_data          OUT NOCOPY  VARCHAR2,
                                x_return_status     OUT NOCOPY  VARCHAR2
                               ) IS

  CURSOR cur_get_prior_period(p_le_id NUMBER,
                              p_ct_id NUMBER,
                              p_end_date DATE) IS
    SELECT gps.end_date
      FROM gmf_period_statuses gps
     WHERE end_date < p_end_date
       AND legal_entity_id = p_le_id
       AND cost_type_id    = p_ct_id
    ORDER BY end_date desc
  ;

  l_le_id                 NUMBER;
  l_cost_type_id          NUMBER;
  l_cost_type             NUMBER;
  l_end_date              DATE;
  l_prior_period_end_date DATE;
  l_msg_count         NUMBER;
  l_no_of_rows        NUMBER;
  l_cost_method	             cm_mthd_mst.cost_mthd_code%TYPE;
  l_cost_component_class_id  cm_cmpt_mst.cost_cmpntcls_id%TYPE;
  l_cost_analysis_code       cm_alys_mst.cost_analysis_code%TYPE;
  l_ret_val NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_inventory_item_id IS NULL OR p_organization_id IS NULL OR p_transaction_date IS NULL) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'Invalid Parameters';
    RETURN;
  END IF;

  BEGIN
  SELECT gfp.legal_entity_id,
         gfp.cost_type_id,
         mthd.cost_type
  INTO   l_le_id,
         l_cost_type_id,
         l_cost_type
  FROM   gmf_fiscal_policies gfp,
         cm_mthd_mst mthd,
         org_organization_definitions ood,
         mtl_parameters mp
  WHERE  gfp.cost_type_id = mthd.cost_type_id
       AND gfp.legal_entity_id = ood.legal_entity
       AND ood.organization_id = p_organization_id
       AND mp.organization_id = p_organization_id
       AND mp.process_enabled_flag = 'Y'
       AND mthd.delete_mark = 0
       AND gfp.delete_mark  = 0
       ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'Invalid value for organization parameter or Invalid Cost Type or Invalid Fiscal Policy';
    RETURN;
  END;
  /* If it is a lot cost type then its not supported */
  IF (l_cost_type = 6) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data      := 'Lot Cost Type is not applicable to retrieve Prior Period Cost';
    RETURN;
  END IF;


  -- Get Prior Period End Date
  OPEN cur_get_prior_period(l_le_id,l_cost_type_id,p_transaction_date);
  FETCH cur_get_prior_period INTO l_prior_period_end_date;
  CLOSE cur_get_prior_period;

  IF (l_prior_period_end_date IS NULL) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'No Prior Period for current transaction date.';
    RETURN;
  END IF;

  /* Call get cost routine from here */

  l_ret_val := GMF_CMCOMMON.Get_Process_Item_Cost (
                     1.0
                   , fnd_api.g_true
                   , x_return_status
                   , l_msg_count
                   , x_msg_data
                   , p_inventory_item_id
                   , p_organization_id
                   , l_prior_period_end_date
                   , 1
                   , l_cost_method
                   , l_cost_component_class_id
                   , l_cost_analysis_code
                   , x_unit_cost
                   , l_no_of_rows
                   );
END Get_Prior_Period_Cost;

END GMF_PROCESS_COST_PUB;

/
