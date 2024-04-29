--------------------------------------------------------
--  DDL for Package CSD_ESTIMATE_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_ESTIMATE_UTILS_PVT" AUTHID CURRENT_USER AS
    /* $Header: csdueuts.pls 120.3 2005/08/26 17:09:21 takwong noship $ */

    /*-------------------------------------------------------*/
    /* function name: validate_estimate_id                   */
    /* DEscription: Validates the estimate in the context    */
    /*              of repair_line_Id                        */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_ESTIMATE_ID(p_estimate_id    NUMBER,
                                  p_repair_line_id NUMBER) RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_estiamte_status               */
    /* DEscription: Validates the estimate status            */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_EST_STATUS(p_estimate_status VARCHAR2) RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_reject_Reason                 */
    /* DEscription: Validates the estimate reject reason     */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*                                                       */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_REASON(p_reason_code VARCHAR2, p_status VARCHAR2)
        RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_uom_Code                      */
    /* DEscription: Validates the uom code                   */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_UOM_CODE(p_uom_code VARCHAR2, p_item_id NUMBER)
        RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_lead_time_uom                 */
    /* DEscription: Validates the uom code of th elead time  */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_LEAD_TIME_UOM(p_lead_time_uom VARCHAR2) RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_price_list                    */
    /* DEscription: Validates price_list                     */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_PRICE_LIST(p_price_list_id NUMBER) RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_Item_pl_uom                   */
    /* DEscription: Validates the item/pl/uom code           */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    -- FUNCTION VALIDATE_ITEM_PL_UOM
    --          ( p_item_id       NUMBER,
    --            p_price_list_id NUMBER,
    --            p_uom           VARCHAR2) RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_order                         */
    /* DEscription: Validates the order header and line      */
    /*              and returns the order number             */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_ORDER(p_order_header_id NUMBER) RETURN VARCHAR2;

    /*-------------------------------------------------------*/
    /* function name: validate_item_instance                 */
    /* DEscription: Validates the item instance and returns  */
    /*              the itme instance number                 */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_ITEM_INSTANCE(p_instance_id NUMBER) RETURN VARCHAR2;

    /*-------------------------------------------------------*/
    /* function name: validate_revision                      */
    /* DEscription: Validates the revision                   */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_REVISION(p_revision VARCHAR2,
                               p_item_id  NUMBER,
                               p_org_id   NUMBER) RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_serial_number                 */
    /* DEscription: Validates the serial number              */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_SERIAL_NUMBER(p_serial_number VARCHAR2,
                                    p_item_id       NUMBER) RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_billing_type                  */
    /* DEscription: Validates the billing type from looks    */
    /* table                                                 */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION VALIDATE_BILLING_TYPE(p_billing_type VARCHAR2) RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_rep_line_id                  */
    /* DEscription: Validates the repair line id             */
    /*                                                       */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION validate_rep_line_id(p_repair_line_id IN NUMBER) RETURN BOOLEAN;

    /*-------------------------------------------------------*/
    /* function name: validate_incident_id                  */
    /* DEscription: Validates the incident    id             */
    /*                                                       */
    /*  Change History  : Created 24th June 2005 by Vijay     */
    /*-------------------------------------------------------*/
    FUNCTION validate_incident_id(p_incident_id IN NUMBER) RETURN BOOLEAN;

  /*-------------------------------------------------------*/
  /* procedure name: validate_est_hdr_rec                  */
  /* DEscription: Validates estimates header record        */
  /*                                                       */
  /*  Change History  : Created 25th June2005 by Vijay     */
  /*-------------------------------------------------------*/
   PROCEDURE validate_est_hdr_rec(p_estimate_hdr_rec  IN Csd_Repair_Estimate_Pub.estimate_hdr_Rec,
                                 p_validation_level   IN NUMBER) ;


   FUNCTION get_pricing_rec(p_estimate_line_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC)
   			RETURN Csd_Process_Util.PRICING_ATTR_REC;
  /*------------------------------------------------------------------------*/
  /* procedure name: DEFAULT_EST_HDR_REC                                    */
  /* DEscription: DEfault values are set in  estimates header record        */
  /*                                                                        */
  /*  Change History  : Created 25th June2005 by Vijay                      */
  /*------------------------------------------------------------------------*/

  PROCEDURE DEFAULT_EST_HDR_REC(p_estimate_hdr_rec IN OUT NOCOPY Csd_Repair_Estimate_Pub.estimate_hdr_Rec);


  /*------------------------------------------------------------------------*/
  /* procedure name: VALIDATE_DEFAULTED_EST_HDR                             */
  /* DEscription: Validate the defaulted  estimates header record           */
  /*                                                                        */
  /*  Change History  : Created 25th June2005 by Vijay                      */
  /*------------------------------------------------------------------------*/
  PROCEDURE VALIDATE_DEFAULTED_EST_HDR(p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.estimate_hdr_Rec,
                                       p_validation_level IN NUMBER);
  /*-------------------------------------------------------*/
  /* procedure name: validate_est_line_rec                  */
  /* DEscription: Validates estimates line record          */
  /*                                                       */
  /*  Change History  : Created 25th June2005 by Vijay     */
  /*-------------------------------------------------------*/

  PROCEDURE VALIDATE_EST_LINE_REC(p_estimate_line_rec IN Csd_Repair_Estimate_Pub.estimate_line_Rec,
                                  p_validation_level  IN NUMBER) ;
/*------------------------------------------------------------------------*/
/* procedure name: DEFAULT_EST_LINE_REC                                    */
/* DEscription: DEfault values are set in  estimates line record         */
/*                                                                        */
/*  Change History  : Created 25th June2005 by Vijay                      */
/*------------------------------------------------------------------------*/

PROCEDURE DEFAULT_EST_LINE_REC(px_estimate_line_rec IN OUT NOCOPY Csd_Repair_Estimate_Pub.estimate_line_Rec);


 PROCEDURE COPY_TO_EST_HDR_REC(p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.estimate_hdr_Rec,
                                x_est_pvt_hdr_rec  OUT NOCOPY Csd_Repair_Estimate_Pvt.REPAIR_ESTIMATE_REC);

  PROCEDURE COPY_TO_EST_HDR_REC_UPD(p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.estimate_hdr_Rec,
                                    x_est_pvt_hdr_rec  OUT NOCOPY Csd_Repair_Estimate_Pvt.REPAIR_ESTIMATE_REC) ;

/*------------------------------------------------------------------------*/
/* procedure name: VALIDATE_DEFAULTED_EST_LINE                            */
/* DEscription: Validate the defaulted  estimates header record           */
/*                                                                        */
/*  Change History  : Created 25th June2005 by Vijay                      */
/*------------------------------------------------------------------------*/
PROCEDURE VALIDATE_DEFAULTED_EST_LINE(p_estimate_line_rec IN Csd_Repair_Estimate_Pub.estimate_line_Rec,
                                      p_validation_level  IN NUMBER) ;


--PROCEDURE COPY_TO_EST_pvt_line_REC(p_estimate_line_rec IN Csd_Repair_Estimate_Pub.estimate_line_Rec,
--                                x_est_pvt_line_rec  OUT NOCOPY Csd_Repair_Estimate_Pvt.REPAIR_ESTIMATE_LINE_REC) ;

END Csd_Estimate_Utils_Pvt;
 

/
