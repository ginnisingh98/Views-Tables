--------------------------------------------------------
--  DDL for Package Body EAM_AUTOMATICEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_AUTOMATICEST" AS
/* $Header: EAMPARCB.pls 115.4 2004/06/23 12:51:32 cboppana ship $ */
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'EAM_AutomaticEst';

/*---------------------------------------------------------------------------*
PROCEDURE       Call_Validate_for_Reestimation
DESCRIPTION
   This procedure expects wip_entity_id as input parameter and finds out NOCOPY
   whether that job qualifies for reestimation or not by calling procedure
   CST_eamCost_PUB.validate_for_reestimation. If it does it update
   the estimation_status to reestimate in wip_discrete_jobs.
*----------------------------------------------------------------------------*/


PROCEDURE  Call_Validate_for_Reestimation(
        p_wip_entity_id    IN   NUMBER ,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_data         OUT NOCOPY  VARCHAR2
        ) IS

        l_est_status          NUMBER := 0;
        l_job_status          NUMBER := 0;
        l_msg_count           NUMBER := 0;
        l_validate            NUMBER := 0;
        l_stmt_num            NUMBER := 0;
        l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
        l_msg_data            VARCHAR2(8000) := '';

BEGIN

  l_stmt_num := 10;

  SELECT  estimation_status , status_type
    INTO  l_est_status , l_job_status
    FROM  WIP_DISCRETE_JOBS
   WHERE  wip_entity_id  = p_wip_entity_id;

  l_stmt_num := 20;

  CST_eamCost_PUB.validate_for_reestimation(
    p_api_version => 1.0,
    p_init_msg_list => NULL,
    p_commit => NULL,
    p_validation_level => NULL,
    p_wip_entity_id =>p_wip_entity_id,
    p_job_status => l_job_status,
    p_curr_est_status => l_est_status,
    x_validate_flag => l_validate,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data
    );
    x_return_status := l_return_status;
    x_msg_data := l_msg_data;

    l_stmt_num := 30;

    IF (l_return_status = fnd_api.g_ret_sts_success) THEN

      l_stmt_num := 40;

      -- Work order qualifies for reestimation
      IF (l_validate = 1)  THEN

        l_stmt_num := 50;

        IF (l_est_status = EAM_CONSTANTS.COMPLETE) THEN

          l_stmt_num := 60;

          UPDATE  WIP_DISCRETE_JOBS
             SET  estimation_status = EAM_CONSTANTS.REESTIMATE
           WHERE  wip_entity_id = p_wip_entity_id;

        ELSIF (l_est_status = EAM_CONSTANTS.RUNNING) THEN

          l_stmt_num := 70;

          UPDATE  WIP_DISCRETE_JOBS
             SET  estimation_status = EAM_CONSTANTS.RUNREEST
           WHERE  wip_entity_id = p_wip_entity_id;

        END IF; /* ENDIF for l_est_status IF */

      END IF;  /* ENDIF for l_validate IF */

    END IF;  /* ENDIF for l_return_status IF */

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := ' Call_Validate_for_Reestimation : Statement - '||l_stmt_num||' Error Message - '||SQLERRM ;

END  Call_Validate_for_Reestimation;

/*---------------------------------------------------------------------------*
PROCEDURE       CST_Item_Cost_Change
DESCRIPTION
   This procedure expects Inventory_item_id and organization_id as input
   parameter. This is called by costing if item cost gets changed. This API
   finds out NOCOPY all the jobs that are using this inventory item and then check
   for each job for reestimation by calling Call_Validate_for_Reestimation.
*----------------------------------------------------------------------------*/

PROCEDURE  CST_Item_Cost_Change(
        p_inv_item_id      IN   NUMBER ,
        p_org_id           IN   NUMBER ,
        x_return_status    OUT NOCOPY  VARCHAR2 ,
        x_msg_data         OUT NOCOPY  VARCHAR2
        ) IS

        l_wip_entity_tbl      wip_entity_tbl_type;
        l_stmt_num            NUMBER := 0;
        l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
        l_msg_data            VARCHAR2(8000) := '';

BEGIN

  l_stmt_num := 10;

  SELECT  wro.wip_entity_id BULK COLLECT
    INTO  l_wip_entity_tbl
    FROM  WIP_REQUIREMENT_OPERATIONS wro , WIP_DISCRETE_JOBS wdj
   WHERE  wdj.wip_entity_id = wro.wip_entity_id
     AND  wdj.status_type
      IN  ( WIP_CONSTANTS.UNRELEASED , WIP_CONSTANTS.RELEASED ,
            WIP_CONSTANTS.COMP_CHRG , WIP_CONSTANTS.HOLD ,
            WIP_CONSTANTS.DRAFT )
     AND  wro.inventory_item_id = p_inv_item_id
     AND  wro.organization_id = p_org_id;

  l_stmt_num := 20;

    /* if no data is selected */
  IF ( l_wip_entity_tbl.count = 0 ) THEN

    l_msg_data := ' OR  no data found ' ;

  END IF; /* ENDIF for l_wip_entity_tbl.count */

  FOR i IN l_wip_entity_tbl.FIRST..l_wip_entity_tbl.LAST LOOP

    l_stmt_num := 30;

    Call_Validate_for_Reestimation (
      p_wip_entity_id => l_wip_entity_tbl(i),
      x_return_status => l_return_status,
      x_msg_data => l_msg_data
      );
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;

  END LOOP;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data := ' CST_Item_Cost_Change : Statement - '||l_stmt_num||' Error Message - '||SQLERRM ||l_msg_data ;

END  CST_Item_Cost_Change;

/*---------------------------------------------------------------------------*
PROCEDURE       CST_Usage_Rate_Change
DESCRIPTION
   This procedure expects resource_id and organization_id as input
   parameter. This is called by costing if resource rate gets changed. This API
   finds out NOCOPY all the jobs that are using this resource and then check
   for each job for reestimation by calling Call_Validate_for_Reestimation.
*----------------------------------------------------------------------------*/

PROCEDURE  CST_Usage_Rate_Change(
        p_resource_id      IN   NUMBER,
        p_org_id           IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_data         OUT NOCOPY  VARCHAR2
        ) IS

        l_wip_entity_tbl      wip_entity_tbl_type;
        l_stmt_num            NUMBER := 0;
        l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
        l_msg_data            VARCHAR2(8000) := '';

BEGIN

  l_stmt_num := 10;

  SELECT  wor.wip_entity_id BULK COLLECT
    INTO  l_wip_entity_tbl
    FROM  WIP_OPERATION_RESOURCES wor , WIP_DISCRETE_JOBS wdj
   WHERE  wdj.wip_entity_id = wor.wip_entity_id
     AND  wdj.status_type
      IN  ( WIP_CONSTANTS.UNRELEASED , WIP_CONSTANTS.RELEASED ,
            WIP_CONSTANTS.COMP_CHRG , WIP_CONSTANTS.HOLD ,
            WIP_CONSTANTS.DRAFT )
     AND  wor.resource_id = p_resource_id
     AND  wor.organization_id = p_org_id;

  l_stmt_num := 20;

    /* if no data is selected */
  IF ( l_wip_entity_tbl.count = 0 ) THEN

    l_msg_data := ' OR  no data found ' ;

  END IF; /* ENDIF for l_wip_entity_tbl.count */

  FOR i IN l_wip_entity_tbl.FIRST..l_wip_entity_tbl.LAST LOOP

    l_stmt_num := 30;

    Call_Validate_for_Reestimation (
      p_wip_entity_id => l_wip_entity_tbl(i),
      x_return_status => l_return_status ,
      x_msg_data => l_msg_data
      );

      x_return_status := l_return_status;
      x_msg_data := l_msg_data;

  END LOOP;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := ' CST_Usage_Rate_Change : Statement - '||l_stmt_num||' Error Message - '||SQLERRM ||l_msg_data ;

END  CST_Usage_Rate_Change;

/*---------------------------------------------------------------------------*
PROCEDURE       PO_Req_Logic
DESCRIPTION
   This procedure expects requisition_line_id as input parameter.
   This is called by 'PO' when a requisition is saved. They need to call this API for
    each requisition line.
   This API first checks for Authorization_Status , it shoud not be in ('CANCELLED',
   'REJECTED'). Then it checks for Destination_Type  , it should be 'SHOP FLOOR'.
   Then it checks for Cancel_Flag , it should not be 'Yes'. Then it checks for
   osp flag, if this is 'NO' then it checks whether
   that requisition line exists in cst_eam_wo_estimate_details table. If it
   exists then this compares for required quantity, rate and unit price in PO
   table and EAM table. If there is any change  or requisition does not exist
   in EAM table then this calls 'Call_Validate_for_Reestimation' procedure
   to set the estimation status to reestimate.
*----------------------------------------------------------------------------*/

PROCEDURE  PO_Req_Logic(
        p_req_line_id      IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_data         OUT NOCOPY  VARCHAR2
        ) IS

        l_count               NUMBER := 0;
        l_req_qty             NUMBER := 0;
        l_rate                NUMBER := 0;
        l_unit_price          NUMBER := 0;
        l_req_qty_p           NUMBER := 0;
        l_rate_p              NUMBER := 0;
        l_unit_price_p        NUMBER := 0;
        l_stmt_num            NUMBER := 0;
        l_wip_entity_id       NUMBER := 0;
        l_osp                 VARCHAR2(1)    := 'N';
        l_cancel_flag         VARCHAR2(1)    := 'N';
        l_auth_status         VARCHAR2(25)   := '';
        l_dest_type           VARCHAR2(25)   := '';
        l_return_status       VARCHAR2(1)    := fnd_api.g_ret_sts_success;
        l_msg_data            VARCHAR2(8000) := '';

BEGIN

  l_stmt_num := 10;

  IF ( p_req_line_id IS NOT NULL ) THEN

    l_stmt_num := 20;

    SELECT  nvl( prha.authorization_status , 'INCOMPLETE') , prla.destination_type_code,
            nvl( prla.cancel_flag , 'N') , nvl( prla.wip_entity_id , 0) ,
            nvl( plt.outside_operation_flag, 'N' )
      INTO  l_auth_status , l_dest_type ,
            l_cancel_flag , l_wip_entity_id ,
            l_osp
      FROM  PO_REQUISITION_LINES_ALL prla , PO_REQUISITION_HEADERS_ALL prha ,
            PO_LINE_TYPES plt
     WHERE  prla.requisition_line_id = p_req_line_id
       AND  prla.requisition_header_id = prha.requisition_header_id
       AND  prla.line_type_id = plt.line_type_id;

    l_stmt_num := 30;

        --Line type for requisition is not outside processing
    IF ( l_auth_status NOT IN ( 'CANCELLED' , 'REJECTED')  AND
         l_dest_type = 'SHOP FLOOR'  AND
         l_cancel_flag <> 'Y'  AND
         l_osp = 'N'  AND
         l_wip_entity_id <> 0 ) THEN

      l_stmt_num := 40;

      BEGIN

        SELECT  requisition_line_id
          INTO  l_count
          FROM  CST_EAM_WO_ESTIMATE_DETAILS
         WHERE  requisition_line_id = p_req_line_id
           AND  wip_entity_id = l_wip_entity_id;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN

          l_count := 0;
      END;

      l_stmt_num := 50;

        -- Requisition line id exists in cst_eam_wo_estimate_details
      IF ( l_count <> 0 ) THEN

        l_stmt_num := 60;

        SELECT  nvl( required_quantity, 0) , nvl( rate, 0) ,
               nvl( item_cost, 0)
          INTO  l_req_qty , l_rate , l_unit_price
          FROM  CST_EAM_WO_ESTIMATE_DETAILS
         WHERE  requisition_line_id = p_req_line_id
           AND  wip_entity_id = l_wip_entity_id;

        l_stmt_num := 70;

        SELECT  quantity , nvl( rate, 0 ) , unit_price
          INTO  l_req_qty_p , l_rate_p , l_unit_price_p
          FROM  PO_REQUISITION_LINES_ALL
         WHERE  requisition_line_id = p_req_line_id
           AND  wip_entity_id = l_wip_entity_id;

        l_stmt_num := 80;

        -- IF required quantity/rate/cost has changed
        IF ( l_req_qty <> l_req_qty_p  OR
             l_rate <> l_rate_p  OR
             l_unit_price <> l_unit_price_p ) THEN

          l_stmt_num := 90;

          Call_Validate_for_Reestimation (
            p_wip_entity_id => l_wip_entity_id,
            x_return_status => l_return_status,
            x_msg_data => l_msg_data
            );

            x_return_status := l_return_status;
            x_msg_data := l_msg_data;

        END IF; /* ENDIF for comparing values IF */

      -- Requisition line id does not exist in cst_eam_wo_estimate_details
      ELSIF ( l_count = 0 ) THEN

        l_stmt_num := 100;

        Call_Validate_for_Reestimation (
          p_wip_entity_id => l_wip_entity_id,
          x_return_status => l_return_status,
          x_msg_data => l_msg_data
          );

          x_return_status := l_return_status;
          x_msg_data := l_msg_data;

      END IF; /* ENDIF for l_count IF */

    END IF; /* ENDIF for l_osp IF */

  END IF; /* ENDIF of main IF */

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := ' PO_Req_Logic : Statement - '||l_stmt_num||' Error Message - '||SQLERRM ;


END PO_Req_Logic;

/*---------------------------------------------------------------------------*
PROCEDURE       PO_Po_Logic
DESCRIPTION
   This procedure expects po_distribution_id as input parameter.
   This is called by 'PO' when a purchase order is saved. They need to call this API
   for each distribution line. This API first checks for Authorization_Status ,
   it shoud not be in ('CANCELLED','REJECTED'). Then it checks for Destination_Type  ,
   it should  be 'SHOP FLOOR'.Then it checks for Cancel_Flag , it should not be 'Yes'.
   Then it checks forF osp flag, if this is 'NO' then it checks whether
   that distribution line exists in cst_eam_wo_estimate_details table. If it
   exists then this compares for required quantity, rate and unit price in PO
   table and EAM table. If there is any change in the values then call the procedure
   Call_Validate_for_Reestimation'. If distribution line does not exist in EAM
   table then it checks whether requisition has been converted into 'PO' or not
   and calls'Call_Validate_for_Reestimation' procedure to set the estimation
   status to reestimate.
*----------------------------------------------------------------------------*/

PROCEDURE  PO_Po_Logic(
        p_po_dist_id       IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_data         OUT NOCOPY  VARCHAR2
        ) IS

        l_count               NUMBER := 0;
        l_req_qty             NUMBER := 0;
        l_rate                NUMBER := 0;
        l_unit_price          NUMBER := 0;
        l_req_qty_p           NUMBER := 0;
        l_rate_p              NUMBER := 0;
        l_unit_price_p        NUMBER := 0;
        l_line_location_id    NUMBER := 0;
        l_estimate_flag       NUMBER := 0;
        l_stmt_num            NUMBER := 0;
        l_wip_entity_id       NUMBER := 0;
        l_req_line_id         NUMBER := 0;
        l_osp                 VARCHAR2(1)    := 'N';
        l_cancel_flag         VARCHAR2(1)    := 'N';
        l_auth_status         VARCHAR2(25)   := '';
        l_dest_type           VARCHAR2(25)   := '';
        l_return_status       VARCHAR2(1)    := fnd_api.g_ret_sts_success;
        l_msg_data            VARCHAR2(8000) := '';


BEGIN

  l_stmt_num := 10;

  IF ( p_po_dist_id IS NOT NULL ) THEN

    l_stmt_num := 20;

    SELECT  nvl( pha.authorization_status , 'INCOMPLETE') , pda.destination_type_code,
            nvl( pla.cancel_flag , 'N') , nvl( pda.wip_entity_id , 0) ,
            nvl( plt.outside_operation_flag, 'N' )
      INTO  l_auth_status , l_dest_type ,
            l_cancel_flag , l_wip_entity_id ,
            l_osp
      FROM  PO_DISTRIBUTIONS_ALL pda , PO_LINE_TYPES plt ,
            PO_LINES_ALL pla , PO_HEADERS_ALL pha
     WHERE  pda.po_line_id = pla.po_line_id
       AND  pla.line_type_id = plt.line_type_id
       AND  pda.po_distribution_id = p_po_dist_id
       AND  pda.po_header_id = pha.po_header_id ;

    l_stmt_num := 30;

        --Line type for requisition is not outside processing
    IF ( l_auth_status NOT IN ( 'CANCELLED' , 'REJECTED')  AND
         l_dest_type = 'SHOP FLOOR'  AND
         l_cancel_flag <> 'Y'  AND
         l_osp = 'N'  AND
         l_wip_entity_id <> 0 ) THEN

      l_stmt_num := 40;

      BEGIN

        SELECT  po_distribution_id , nvl( required_quantity, 0 ) , nvl( rate, 0 ) ,
                nvl( item_cost , 0 )
          INTO  l_count, l_req_qty , l_rate , l_unit_price
          FROM  CST_EAM_WO_ESTIMATE_DETAILS
         WHERE  po_distribution_id = p_po_dist_id
           AND  wip_entity_id = l_wip_entity_id;

       EXCEPTION

         WHEN NO_DATA_FOUND THEN

           l_count := 0;
      END;

      l_stmt_num := 50;

        --po_distribution_id exists in cst_eam_wo_estimate_details
      IF( l_count <> 0) then

        l_stmt_num := 60;

       /* SELECT  nvl( required_quantity, 0 ) , nvl( rate, 0 ) ,
                nvl( item_cost , 0 )
          INTO  l_req_qty , l_rate ,
                l_unit_price
          FROM  CST_EAM_WO_ESTIMATE_DETAILS
         WHERE  po_distribution_id = p_po_dist_id
           AND  wip_entity_id = l_wip_entity_id ; */

          l_estimate_flag := 1;

        --Po distribution id does not exist in cst_eam_wo_estimate_details
      ELSIF ( l_count = 0 ) THEN

        BEGIN

          l_stmt_num := 70;

          SELECT  prla.line_location_id
            INTO  l_line_location_id
            FROM  PO_DISTRIBUTIONS_ALL pda , PO_REQUISITION_LINES_ALL prla
           WHERE  pda.line_location_id = nvl( prla.line_location_id , -999 )
             AND  pda.po_distribution_id = p_po_dist_id ;

        EXCEPTION

          WHEN NO_DATA_FOUND THEN

             l_stmt_num := 80;
             l_line_location_id := 0;
        END;

          --requisition has been converted INTO PO
        IF ( l_line_location_id <> 0) THEN

          l_stmt_num := 90;

          SELECT  requisition_line_id
            INTO  l_req_line_id
            FROM  CST_EAM_WO_ESTIMATE_DETAILS
           WHERE  line_location_id = l_line_location_id
             AND  wip_entity_id = l_wip_entity_id;

          l_stmt_num := 100;

          SELECT  nvl( required_quantity , 0 ) , nvl( rate , 0 ) ,
                  nvl( item_cost , 0 )
            INTO  l_req_qty , l_rate ,
                  l_unit_price
            FROM  CST_EAM_WO_ESTIMATE_DETAILS
           WHERE  requisition_line_id = l_req_line_id
             AND  wip_entity_id = l_wip_entity_id;

          l_estimate_flag := 1;

          --PO is created independent of requisition
        ELSIF ( l_line_location_id = 0 ) THEN

          l_stmt_num := 110;

          Call_Validate_for_Reestimation (
            p_wip_entity_id => l_wip_entity_id,
            x_return_status => l_return_status,
            x_msg_data => l_msg_data
            );

            x_return_status := l_return_status;
            x_msg_data := l_msg_data;

        END IF ; /* end if for l_line_location_id if */

      END IF; /* end if for l_count if */

        IF ( l_estimate_flag = 1 ) THEN

          l_stmt_num := 120;

          SELECT  pda.quantity_ordered , nvl( pda.rate , 0 ) ,
                  nvl( pla.unit_price,0)
            INTO  l_req_qty_p , l_rate_p ,
                  l_unit_price_p
            FROM  PO_DISTRIBUTIONS_ALL pda , PO_LINES_ALL pla
           WHERE  pda.wip_entity_id = l_wip_entity_id
             AND  pda.po_distribution_id = p_po_dist_id
             AND  pda.po_line_id = pla.po_line_id;

          -- required quanity/cost/rate has changed
          IF ( l_req_qty <> l_req_qty_p OR
               l_rate <> l_rate_p OR
               l_unit_price <> l_unit_price_p) THEN

            l_stmt_num := 130;

            Call_Validate_for_Reestimation (
              p_wip_entity_id => l_wip_entity_id,
              x_return_status => l_return_status,
              x_msg_data => l_msg_data
              );

              x_return_status := l_return_status;
              x_msg_data := l_msg_data;

          END IF; /* end if for comparing if */

        END IF; /* end if for l_estimate_flag if */

    END IF; /* end if for l_osp if */

  END IF; /* end if for main if */

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data := ' PO_Po_Logic : Statement - '||l_stmt_num||' Error Message - '||SQLERRM ;

END PO_Po_Logic;

/*---------------------------------------------------------------------------*
PROCEDURE       PO_Line_Logic
DESCRIPTION
   This procedure expects po_line_id as input parameter.
   This is called by 'PO' when a purchase order is saved. They need to call this API
   for each PO line. This API finds out NOCOPY all the distribution lines for each PO line.
   Then it loops through all the distribution lines and calls PO_Po_logic.
*----------------------------------------------------------------------------*/

PROCEDURE  PO_Line_Logic(
        p_po_line_id       IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_data         OUT NOCOPY  VARCHAR2
        ) IS

       l_po_dist_tbl      po_dist_tbl_type;
       l_stmt_num         NUMBER := 0;
       l_return_status    VARCHAR2(1) := fnd_api.g_ret_sts_success;
       l_msg_data         VARCHAR2(8000) := '';

BEGIN

  l_stmt_num := 10;

  IF ( p_po_line_id IS NOT NULL ) THEN

    SELECT  pda.po_distribution_id  BULK COLLECT
      INTO  l_po_dist_tbl
      FROM  PO_LINES_ALL pla , PO_DISTRIBUTIONS_ALL pda
     WHERE  pla.po_line_id = p_po_line_id
       AND  pla.po_line_id = pda.po_line_id ;

    l_stmt_num := 20;

    /* if no data is selected */
    IF ( l_po_dist_tbl.count = 0 ) THEN

      l_msg_data := ' OR  no data found ' ;

    END IF; /* ENDIF for l_po_dist_tbl.count */

    FOR i IN l_po_dist_tbl.FIRST..l_po_dist_tbl.LAST LOOP

      l_stmt_num := 30;

      PO_Po_Logic(
         p_po_dist_id => l_po_dist_tbl(i),
         x_return_status => l_return_status,
         x_msg_data => l_msg_data
         );

         x_return_status := l_return_status;
         x_msg_data := l_msg_data;

    END LOOP;

  END IF ; /* ENDIF for p_po_line_id IF */

  EXCEPTION

    WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := ' PO_Line_Logic : Statement - '||l_stmt_num||' Error Message - '||SQLERRM ||l_msg_data ;

END PO_Line_Logic;

/*---------------------------------------------------------------------------*
PUBLIC PROCEDURE        Auto_Reest_of_Cost
DESCRIPTION
        This API will be called by different products. 'EAM' will call this API
 if the material quantity or usage rate gets changed. 'WIP' will call this API
 whenever new job is created. 'CST' will call this API if item cost or
 resource rate gets changed. 'PO' will call this API while saving a requisition
 or purchase order.
*----------------------------------------------------------------------------*/

PROCEDURE Auto_Reest_of_Cost(
        p_wip_entity_id    IN   NUMBER,
        p_api_name         IN   VARCHAR2,
        p_req_line_id      IN   NUMBER,
        p_po_dist_id       IN   NUMBER,
        p_po_line_id       IN   NUMBER,
        p_inv_item_id      IN   NUMBER,
        p_org_id           IN   NUMBER,
        p_resource_id      IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_count        OUT NOCOPY  NUMBER,
        x_msg_data         OUT NOCOPY  VARCHAR2
        ) IS

        l_api_version         CONSTANT NUMBER := 1.0;
        l_api_name            CONSTANT VARCHAR2(30) := 'Auto_Reest_of_Cost';
        l_stmt_num            NUMBER := 0;
        l_msg_data            VARCHAR2(8000) := '';
        l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;

BEGIN
   --  Standard Start of API savepoint
  SAVEPOINT Auto_Reest_of_Cost_PUB;

  /* Called by 'EAM' and wip_entity_id is required parameter */
  IF ( p_api_name = 'EAM'  AND  p_wip_entity_id IS NOT NULL ) THEN

    l_stmt_num := 10;

    Call_Validate_for_Reestimation (
      p_wip_entity_id => p_wip_entity_id,
      x_return_status => l_return_status,
      x_msg_data => l_msg_data
      );

      x_msg_data := l_msg_data;
      x_return_status := l_return_status;

  END IF; /* END IF for  'EAM' IF */

  /* Called by 'WIP' and wip_entity_id is required parameter */
  IF ( p_api_name = 'WIP'  AND  p_wip_entity_id IS NOT NULL ) THEN

    l_stmt_num := 20;

    Call_Validate_for_Reestimation (
      p_wip_entity_id => p_wip_entity_id,
      x_return_status => l_return_status,
      x_msg_data => l_msg_data
      );

      x_msg_data := l_msg_data;
      x_return_status := l_return_status;

  END IF; /* END IF for  'WIP' IF */

   /* Called by 'CST' and inventory_item_id and organization_id are required parameters */
 IF ( p_api_name = 'CST'  AND
       p_inv_item_id IS NOT NULL AND
       p_org_id IS NOT NULL ) THEN

    l_stmt_num := 30;

    CST_Item_Cost_Change(
      p_inv_item_id => p_inv_item_id,
      p_org_id => p_org_id,
      x_return_status => l_return_status,
      x_msg_data => l_msg_data
      );

      x_msg_data := l_msg_data;
      x_return_status := l_return_status;

  END IF; /* END IF for  'CST_Item' IF */

  /* Called by 'CST' and resource_id and organization_id are required parameters */
  IF ( p_api_name = 'CST'  AND
       p_resource_id IS NOT NULL AND
       p_org_id IS NOT NULL ) THEN

    l_stmt_num := 40;

    CST_Usage_Rate_Change(
      p_resource_id => p_resource_id,
      p_org_id => p_org_id,
      x_return_status => l_return_status,
      x_msg_data => l_msg_data
      );

      x_msg_data := l_msg_data;
      x_return_status := l_return_status;

  END IF; /* END IF for  'CST_Usage' IF */

  /* Called by 'PO' and requisition_line_id are required paramaters */
  IF ( p_api_name = 'PO'  AND
       p_req_line_id IS NOT NULL ) THEN

    l_stmt_num := 50;

    PO_Req_Logic(
      p_req_line_id => p_req_line_id,
      x_return_status => l_return_status,
      x_msg_data => l_msg_data
      );

      x_msg_data := l_msg_data;
      x_return_status := l_return_status;

  END IF; /* END IF for  'Req' IF */

  /* Called by 'PO' and po_distribution_id are required paramaters */
  IF ( p_api_name = 'PO'  AND
       p_po_dist_id IS NOT NULL ) THEN

    l_stmt_num := 60;

    PO_Po_Logic(
      p_po_dist_id => p_po_dist_id,
      x_return_status => l_return_status,
      x_msg_data => l_msg_data
      );

      x_msg_data := l_msg_data;
      x_return_status := l_return_status;

  END IF; /* END IF for  'PO' IF */

  /* Called by 'PO' and po_line_id are required paramaters */
  IF ( p_api_name = 'PO'  AND
       p_po_line_id IS NOT NULL ) THEN

    l_stmt_num := 60;

    PO_Line_Logic(
      p_po_line_id => p_po_line_id,
      x_return_status => l_return_status,
      x_msg_data => l_msg_data
      );

      x_msg_data := l_msg_data;
      x_return_status := l_return_status;

  END IF; /* END IF for  'PO_Line' IF */

--fix for 3550864
if(x_msg_data is not null) then
    x_msg_data := substr(x_msg_data,1,2000);
end if;

EXCEPTION

       WHEN OTHERS THEN
         ROLLBACK TO Auto_Reest_of_Cost_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;
         x_msg_data := ' Auto_Reest_of_Cost : Statement - '||l_stmt_num||' Error Message - '||SQLERRM ||l_msg_data ;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
               FND_MSG_PUB.add_exc_msg
                 (  'EAM_AutomaticEst'
                  , '.Auto_Reest_of_Cost : Statement -'||to_char(l_stmt_num)||'Error Message -'||SQLERRM
                 );
         END IF;

  --  Get message count and data
        FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
          if(x_msg_data is not null) then
	        x_msg_data := substr(x_msg_data,1,2000);
	  end if;

END Auto_Reest_of_Cost;

END EAM_AutomaticEst;

/
