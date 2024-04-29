--------------------------------------------------------
--  DDL for Package Body PO_RESERVATION_MAINTAIN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RESERVATION_MAINTAIN_SV" AS
/* $Header: POXMRESB.pls 120.8.12010000.2 2011/02/24 08:14:13 sknandip ship $ */
--
-- Purpose: To maintain reservation
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- rsnair      08/31/01 Created Package
-- ksareddy	   04/29/2002 Bug fix 2341308
--


  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: MAINTAIN_RESERVATION
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  This  would call out to INV_MAINTAIN_RESERVATION_PUB.MAINTAIN_RESERVATION
  --  to maintain reservation for PO supply sources.
  --Parameters:
  --IN:
  -- p_header_id
  --     header id of the supply source
  -- p_line_id
  --     line id of the supply source
  -- p_line_location_id
  --      shipment id of the supply source
  -- p_distribution_id
  --      distribution id of the supply source
  -- p_recreate_demand_flag
  --       indicates whether the demand would be recreated
  --       upon cancellation of supply source
  --        values
  --        'Y'   Demand would be recreated
  --        'N'   Demand would not be recreated
  -- p_called_from_reqimport
  --        indicates whether it is called from req import
  -- p_ordered_quantity
  --        passed from OM to reflect the new ordered quantity
  --        incase the qunatity on SO is updated
  -- p_ordered_uom
  --        passed from OM to reflect the uom which might have been changed on ISO
  --OUT:
  -- x_return_status
  --        return status of the reservation routines
  --End of Comments
  -------------------------------------------------------------------------------
  PROCEDURE MAINTAIN_RESERVATION
  (
   p_header_id                IN NUMBER
  ,p_line_id                  IN NUMBER
  ,p_line_location_id         IN NUMBER
  ,p_distribution_id          IN NUMBER
  ,p_action                   IN VARCHAR2
  ,p_recreate_demand_flag     IN VARCHAR2
  ,p_called_from_reqimport    IN VARCHAR2
  ,p_ordered_quantity         IN NUMBER   DEFAULT NULL --<R12 PLAN CROSS DOCK>
  ,p_transaction_id           IN NUMBER   DEFAULT NULL --<R12 PLAN CROSS DOCK>
  ,p_ordered_uom              IN VARCHAR2 DEFAULT NULL --5253916
  ,x_return_status            OUT NOCOPY VARCHAR2)
  IS


  l_ret_sts         VARCHAR2(1);
  l_bool_ret_sts    BOOLEAN;

  l_msg_data        VARCHAR2(2000);
  l_msg_count       NUMBER;
  l_return_status VARCHAR2(1);

  d_progress        NUMBER;
  d_module          VARCHAR2(60) := 'po.plsql.PO_RESERVATION_MAINTAIN_SV.maintain_reservation';

BEGIN


    d_progress := 0;
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module);
      PO_LOG.proc_begin(d_module, 'p_header_id', p_header_id);
      PO_LOG.proc_begin(d_module, 'p_line_id',p_line_id );
      PO_LOG.proc_begin(d_module, 'p_line_location_id',p_line_location_id );
      PO_LOG.proc_begin(d_module, 'p_distribution_id',p_distribution_id );
      PO_LOG.proc_begin(d_module, 'p_action',p_action );
      PO_LOG.proc_begin(d_module, 'p_recreate_demand_flag',p_recreate_demand_flag );
      PO_LOG.proc_begin(d_module, 'p_called_from_reqimport',p_called_from_reqimport );
      PO_LOG.proc_begin(d_module, 'p_ordered_quantity',p_ordered_quantity );
      PO_LOG.proc_begin(d_module, 'p_transaction_id',p_transaction_id );
      PO_LOG.proc_begin(d_module, 'p_ordered_uom',p_ordered_uom );
    END IF;

    d_progress := 10;

        IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'Calling Maintain rervations');
        END IF;

       inv_maintain_reservation_pub.maintain_reservation
       (
          x_return_status             => l_return_status
        , x_msg_count                 => l_msg_count
        , x_msg_data                  => l_msg_data
        , p_api_version_number        => 1.0
        , p_init_msg_lst              => fnd_api.g_true
        , p_header_id                 => p_header_id
        , p_line_id                   => p_line_id
        , p_line_location_id          => p_line_location_id
        , p_distribution_id           => p_distribution_id
        , p_transaction_id            => p_transaction_id
        , p_action                    => p_action
        , p_ordered_quantity          => p_ordered_quantity
	, p_ordered_uom               => p_ordered_uom
       );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.g_exc_unexpected_error;
        ELSE
          x_return_status := l_return_status;
        END IF;


      d_progress := 20;

       IF (PO_LOG.d_proc) THEN
          PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
          PO_LOG.proc_end(d_module);
       END IF;


  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (PO_LOG.d_exc) THEN
           PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
           PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
           PO_LOG.proc_end(d_module);
       END IF;

END MAINTAIN_RESERVATION;


END PO_RESERVATION_MAINTAIN_SV;

/
