--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_ADJUSTMENT_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_ADJUSTMENT_PROC" AUTHID CURRENT_USER AS
--$Header: JMFRSKDS.pls 120.10 2006/06/22 10:17:46 nesoni noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|  FILENAME :           JMFRSKDS.pls                                        |
--|                                                                           |
--|  DESCRIPTION:         Specification file for the private package          |
--|                       containing the logic of Component Consumption       |
--|                       Adjustments.                                        |
--|                       It includes the main procedures to be invoked       |
--|                       by the Consumption Adjusments Concurrent Program.   |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    28-MAY-2005        shu   Created.                                      |
--|    12-JUL-2005        vchu  Removed the init procedure.                   |
--|    06-OCT-2005        shu   Added x_chr_errbuff,x_chr_retcode parameters  |
--|                             to adjustments_worker.                        |
--|    12-DEC-2005        shu   added check_workers_status procedure for      |
--|                             checking the status of adjustment workers     |
--|    21-JUN-2006        nesoni added get_total_adjustments function for     |
--|                              getting total adjustments corresponding to   |
--|                              poShipmentId and ShikyuComponentId.          |
--+===========================================================================+

  g_pkg_name CONSTANT VARCHAR2(30) := 'JMF_SHIKYU_ADJUSTMENT_PROC';

  --========================================================================
  -- PROCEDURE : adjustments_manager    PUBLIC ,
  -- PARAMETERS: x_chr_errbuff          varchar out parameter for current program
  --             x_chr_retcode          varchar out parameter for current program
  --             p_batch_size           Number of records in a batch
  --             p_max_workers          Maximum number of workers allowed
  -- COMMENT   : for submit adjustment concurrent manually , the group_id is ignored
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjustments_manager
  ( x_chr_errbuff OUT NOCOPY VARCHAR2 /*to store error msg*/
  , x_chr_retcode OUT NOCOPY VARCHAR2 /*to store return code*/
  , p_batch_size  IN NUMBER
  , p_max_workers IN NUMBER
  );

  --========================================================================
  -- PROCEDURE : check_workers_status    PUBLIC
  -- PARAMETERS: p_workers            Identifier of the submitted requests
  --             x_return_status      the status of worker request, if not 'NORMAL'
  -- COMMENT   :
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE check_workers_status
  (p_workers	      IN  jmf_shikyu_util.g_request_tbl_type
  ,x_return_status  OUT NOCOPY VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : adjustments_worker    PUBLIC
  -- PARAMETERS: x_chr_errbuff         varchar out parameter for current program
  --             x_chr_retcode         varchar out parameter for current program
  --             p_batch_id            Identifier of the batch of rows to be processed
  -- COMMENT   :
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjustments_worker
  (
    x_chr_errbuff   OUT NOCOPY VARCHAR2 /*to store error msg*/ --errbuf??
   ,x_chr_retcode   OUT NOCOPY VARCHAR2 /*to store return code*/ --retcode ??
   ,p_batch_id      IN NUMBER
  );

  --========================================================================
  -- PROCEDURE : adjust_consumption    PUBLIC ,
  -- PARAMETERS: p_batch_id            Identifier of the batch of rows to be processed
  --           : x_return_status       return status
  -- COMMENT   :  This is the main procedure to be kicked off by the Consumptioin Adjustments
  --              Concurrent Program.  It sorts the adjustment records in ascending order of
  --              the adjustment amount and then processes each record by calling either the
  --              Adjust_Positive or the Adjust_Negative procedure.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjust_consumption
  ( p_batch_id      IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : adjust_positive       PUBLIC ,
  -- PARAMETERS: p_subcontract_po_shipment_id    Unique Identifier of the Subcontracting
  --                                             Order Shipment whose component consumption is to be adjusted.
  --             p_component_id                  p_component_id Identifier of the SHIKYU Component
  --                                             for which the consumption is to be adjusted.
  --             p_adjustment_amount             Amount to adjust the component consumtion by.
  --             p_uom                           Unit of Measure of the adjustment amount.
  --             x_return_status                 return status.
  -- COMMENT   :  This procedure processes an adjustment record with a positive adjustment amount,
  --              meaning that the Manufacturing Partner has over-utilized the SHIKYU Component.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjust_positive
  ( p_subcontract_po_shipment_id IN NUMBER
  , p_component_id               IN NUMBER
  , p_adjustment_amount          IN NUMBER
  , p_uom                        IN VARCHAR2
  , x_return_status              OUT NOCOPY VARCHAR2
  );

  --========================================================================
  -- PROCEDURE : adjust_negative       PUBLIC ,
  -- PARAMETERS: p_subcontract_po_shipment_id    Unique Identifier of the Subcontracting
  --                                             Order Shipment whose component consumption is to be adjusted.
  --             p_component_id                  p_component_id Identifier of the SHIKYU Component
  --                                             for which the consumption is to be adjusted.
  --             p_adjustment_amount             Amount to adjust the component consumtion by.
  --             p_uom                           Unit of Measure of the adjustment amount.
  --             x_return_status                 return status.
  -- COMMENT   :    This procedure processes an adjustment record with a negative adjustment amount,
  --                meaning that the Manufacturing Partner has under-utilized the SHIKYU Component.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE adjust_negative
  ( p_subcontract_po_shipment_id IN NUMBER
  , p_component_id               IN NUMBER
  , p_adjustment_amount          IN NUMBER
  , p_uom                        IN VARCHAR2
  , x_return_status              OUT NOCOPY VARCHAR2
  );

  --========================================================================
  -- FUNCTION  : get_total_adjustments  PUBLIC ,
  -- PARAMETERS: p_po_shipment_id       Subcontracting Purchase Order Shipment Id
  --             p_component_id         component Id of OSA item
  -- COMMENT   : Function for getting total adjustments corresponding to
  --             poShipmentId and ShikyuComponentId.
  -- RETURN   : NUMBER                 Returns total adjusted value
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_total_adjustments
  ( p_po_shipment_id      IN NUMBER
  , p_component_id IN NUMBER
  ) RETURN NUMBER;

END jmf_shikyu_adjustment_proc;


 

/
